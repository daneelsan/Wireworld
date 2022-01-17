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
static inline int is_alive(int cell)
{
	return (ELECTRON_HEAD == cell || PHOTON_HEAD == cell) ? 1 : 0;
}

static inline int cyclic_pos(int pos, int size)
{
	return (pos + size) % size;
}

static inline int count_live_neighbors(int64_t *state, int rows, int cols, int row, int col)
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

static void wireworld_step_impl(int64_t *state_in, int64_t *state_out, int rows, int cols)
{
	int64_t *cell_in = state_in;
	int64_t *cell_out = state_out;
	for (int row = 0; row < rows; row += 1) {
		for (int col = 0; col < cols; col += 1) {
			switch (*cell_in) {
				/*
					1. Wire cells with 1 or 2 live neighbors (electron heads or
					photon heads) turn into electron heads.
				*/
				case WIRE: {
					int count = count_live_neighbors(state_in, rows, cols, row, col);
					*cell_out = (1 == count || 2 == count) ? ELECTRON_HEAD : WIRE;
				} break;
				/*
					2. Electron heads turn into electron tails.
				*/
				case ELECTRON_HEAD: {
					*cell_out = ELECTRON_TAIL;
				} break;
				/*
					3. Electron tails turn into wire cells.
				*/
				case ELECTRON_TAIL: {
					*cell_out = WIRE;
				} break;
				/*
					4. Vacuum cells with 2 or 3 live neighbors (electron heads or
					photon heads) turn into photon heads.
				*/
				case VACUUM: {
					int count = count_live_neighbors(state_in, rows, cols, row, col);
					*cell_out = (2 == count || 3 == count) ? PHOTON_HEAD : VACUUM;
				} break;
				/*
					5. Photon heads turn into photon tails.
				*/
				case PHOTON_HEAD: {
					*cell_out = PHOTON_TAIL;
				} break;
				/*
					6. Photon tails turn into vacuum cells.
				*/
				case PHOTON_TAIL: {
					*cell_out = VACUUM;
				} break;

				/* Empty cells do not evolve. */
				case EMPTY: {
					*cell_out = EMPTY;
				} break;

				/* Unknown cells become empty cells. */
				default: {
					*cell_out = EMPTY;
				} break;
			}
			cell_in += 1;
			cell_out += 1;
		}
	}
}
