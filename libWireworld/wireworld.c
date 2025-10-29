#include "WolframLibrary.h"

enum WIREWORLD_CELL
{
	EMPTY = 0,
	ELECTRON_HEAD = 1,
	ELECTRON_TAIL = 2,
	WIRE = 3,

	PHOTON_HEAD = 4,
	PHOTON_TAIL = 5,
	VACUUM = 6,

	CELL_COUNT,
};

/*
	Electron tails, wire cells, photon tails, and vacuum cells
	are considered to be dead.

	Electron heads and photon heads are considered to be alive.
*/
static inline int is_alive(mint cell)
{
	uint8_t cell_low = cell & 0xFF;
	return (ELECTRON_HEAD == cell_low || PHOTON_HEAD == cell_low);
}

static inline int cyclic_pos(int pos, int size)
{
	return (pos + size) % size;
}

// clang-format off
static const int neighbor_offsets[8][2] = {
	{-1, -1}, {-1, 0}, {-1, 1},
	{ 0, -1},          { 0, 1},
	{ 1, -1}, { 1, 0}, { 1, 1}
};
// clang-format on

static inline int count_live_neighbors(mint *state, int rows, int cols, int row, int col)
{
	int count = 0;
	for (int i = 0; i < 8; ++i)
	{
		int n_row = cyclic_pos(row + neighbor_offsets[i][0], rows);
		int n_col = cyclic_pos(col + neighbor_offsets[i][1], cols);
		count += is_alive(state[n_row * cols + n_col]);
	}
	return count;
}

// clang-format off
// Lookup table: [cell_type][live_neighbor_count]
static const uint8_t wireworld_next_state[CELL_COUNT][9] = {
	// EMPTY
	{EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY},
	// ELECTRON_HEAD
	{ELECTRON_TAIL, ELECTRON_TAIL, ELECTRON_TAIL, ELECTRON_TAIL, ELECTRON_TAIL, ELECTRON_TAIL, ELECTRON_TAIL, ELECTRON_TAIL, ELECTRON_TAIL},
	// ELECTRON_TAIL
	{WIRE, WIRE, WIRE, WIRE, WIRE, WIRE, WIRE, WIRE, WIRE},
	// WIRE
	{WIRE, ELECTRON_HEAD, ELECTRON_HEAD, WIRE, WIRE, WIRE, WIRE, WIRE, WIRE},
	// PHOTON_HEAD
	{PHOTON_TAIL, PHOTON_TAIL, PHOTON_TAIL, PHOTON_TAIL, PHOTON_TAIL, PHOTON_TAIL, PHOTON_TAIL, PHOTON_TAIL, PHOTON_TAIL},
	// PHOTON_TAIL
	{VACUUM, VACUUM, VACUUM, VACUUM, VACUUM, VACUUM, VACUUM, VACUUM, VACUUM},
	// VACUUM
	{VACUUM, VACUUM, PHOTON_HEAD, PHOTON_HEAD, VACUUM, VACUUM, VACUUM, VACUUM, VACUUM}
};
// clang-format on

static inline mint evolve_cell(mint *state, int rows, int cols, int row, int col, mint cell_in)
{
	uint8_t cell = cell_in & 0xFF;
	int count = 0;
	// Only WIRE and VACUUM depend on neighbor count
	if (cell == WIRE || cell == VACUUM)
		count = count_live_neighbors(state, rows, cols, row, col);
	return wireworld_next_state[cell][count];
}

/*=============================================================================
	Wireworld step and run implementations
=============================================================================*/

static void wireworld_step_immutable_impl(mint *state_in, mint *state_out, int rows, int cols)
{
	mint *cell_in = state_in;
	mint *cell_out = state_out;
	for (int row = 0; row < rows; row += 1)
	{
		for (int col = 0; col < cols; col += 1)
		{
			*cell_out = evolve_cell(state_in, rows, cols, row, col, *cell_in);
			cell_in += 1;
			cell_out += 1;
		}
	}
}

static void wireworld_step_mutable_impl(mint *state, int rows, int cols)
{
	// First pass: compute new state and store in high 8 bits
	int size = rows * cols;
	for (int i = 0; i < size; i += 1)
	{
		mint cell_out = evolve_cell(state, rows, cols, i / cols, i % cols, state[i]);
		state[i] |= (cell_out & 0xFF) << 8;
	}
	// Second pass: move new state to low 8 bits
	for (int i = 0; i < size; i += 1)
	{
		state[i] = (state[i] >> 8) & 0xFF;
	}
}

static void wireworld_run_impl(mint *state, int rows, int cols, int steps)
{
	for (int step = 0; step < steps; step += 1)
	{
		wireworld_step_mutable_impl(state, rows, cols);
	}
}
