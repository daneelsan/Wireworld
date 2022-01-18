#include <stdint.h>

enum WIREWORLD_CELL {
	EMPTY           = 0,
	ELECTRON_HEAD   = 1,
	ELECTRON_TAIL   = 2,
	WIRE            = 3,

	PHOTON_HEAD     = 4,
	PHOTON_TAIL     = 5,
	VACUUM          = 6,

	CELL_COUNT,
};

/*
	Electron tails, wire cells, photon tails, and vacuum cells
	are considered to be dead.

	Electron heads and photon heads are considered to be alive.
*/
static inline int is_alive(uint8_t cell)
{
	return (ELECTRON_HEAD == cell || PHOTON_HEAD == cell);
}

static inline int cyclic_pos(int pos, int size)
{
	return (pos + size) % size;
}

static inline int count_live_neighbors(uint16_t *state, int rows, int cols, int row, int col)
{
	int count = 0;
	int pad;

	int row_before = cyclic_pos(row - 1, rows);
	int row_after = cyclic_pos(row + 1, rows);
	int col_before = cyclic_pos(col - 1, cols);
	int col_after = cyclic_pos(col + 1, cols);

	pad = row_before * cols;
	/* NW: {-1, -1} */
	count += is_alive(state[pad + col_before]);
	/* N: {0, -1} */
	count += is_alive(state[pad + col]);
	/* NE: {1, -1} */
	count += is_alive(state[pad + col_after]);

	pad = row * cols;
	/* W: {-1, 0} */
	count += is_alive(state[pad + col_before]);
	/* E: {1, 0} */
	count += is_alive(state[pad + col_after]);

	pad = row_after * cols;
	/* SW: {-1, 1} */
	count += is_alive(state[pad + col_before]);
	/* S: {0, 1} */
	count += is_alive(state[pad + col]);
	/* SE: {1, 1} */
	count += is_alive(state[pad + col_after]);

	return count;
}

static inline uint8_t evolve_cell(uint16_t* state, int rows, int cols, int row, int col, uint8_t cell_in)
{
	uint8_t cell_out;
	switch (cell_in) {
		/*
			1. Wire cells with 1 or 2 live neighbors (electron heads or
			photon heads) turn into electron heads.
		*/
		case WIRE: {
			int count = count_live_neighbors(state, rows, cols, row, col);
			cell_out = (1 == count || 2 == count) ? ELECTRON_HEAD : WIRE;
		} break;
		/*
			2. Electron heads turn into electron tails.
		*/
		case ELECTRON_HEAD: {
			cell_out = ELECTRON_TAIL;
		} break;
		/*
			3. Electron tails turn into wire cells.
		*/
		case ELECTRON_TAIL: {
			cell_out = WIRE;
		} break;
		/*
			4. Vacuum cells with 2 or 3 live neighbors (electron heads or
			photon heads) turn into photon heads.
		*/
		case VACUUM: {
			int count = count_live_neighbors(state, rows, cols, row, col);
			cell_out = (2 == count || 3 == count) ? PHOTON_HEAD : VACUUM;
		} break;
		/*
			5. Photon heads turn into photon tails.
		*/
		case PHOTON_HEAD: {
			cell_out = PHOTON_TAIL;
		} break;
		/*
			6. Photon tails turn into vacuum cells.
		*/
		case PHOTON_TAIL: {
			cell_out = VACUUM;
		} break;

		/* Empty cells do not evolve. */
		case EMPTY: {
			cell_out = EMPTY;
		} break;

		/* Unknown cells become empty cells. */
		default: {
			cell_out = EMPTY;
		} break;
	}
	return cell_out;
}

static void wireworld_step_immutable_impl(uint16_t *state_in, uint16_t *state_out, int rows, int cols)
{
	uint16_t *cell_in = state_in;
	uint16_t *cell_out = state_out;
	for (int row = 0; row < rows; row += 1) {
		for (int col = 0; col < cols; col += 1) {
			*cell_out = evolve_cell(state_in, rows, cols, row, col, *cell_in);
			cell_in += 1;
			cell_out += 1;
		}
	}
}

static void wireworld_step_mutable_impl(uint16_t *state, int rows, int cols)
{
	uint16_t *raw_cell;

	raw_cell = state;
	for (int row = 0; row < rows; row += 1) {
		for (int col = 0; col < cols; col += 1) {
			/* Store the old value in the low 16-bits of the cell. */
			int cell_out = evolve_cell(state, rows, cols, row, col, *raw_cell);
			/* Store the new value in the high 16-bits of the cell. */
			*raw_cell |= cell_out << 8;
			raw_cell += 1;
		}
	}

	raw_cell = state;
	/* Move the high 16-bits to the low 16-bits. */
	for (int i = 0; i < rows * cols; i += 1) {
		*raw_cell >>= 8;
		raw_cell += 1;
	}
}
