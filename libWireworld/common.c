#include <stdint.h>

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

/* Electron heads and photon heads are considered to be alive. */
static inline int is_alive(uint8_t cell)
{
	uint8_t cell_low = cell & 0b1111;
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

static inline int count_live_neighbors(uint8_t* state, int rows, int cols, int row, int col)
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

static inline uint8_t evolve_cell(uint8_t* state, int rows, int cols, int row, int col, uint8_t cell_in)
{
	uint8_t cell = cell_in & 0b1111;
	int count = 0;
	// Only WIRE and VACUUM depend on neighbor count
	if (cell == WIRE || cell == VACUUM)
		count = count_live_neighbors(state, rows, cols, row, col);
	return wireworld_next_state[cell][count];
}