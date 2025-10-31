#include "./common.c"

static void wireworld_step_immutable_impl(uint8_t *state_in, uint8_t *state_out, int rows, int cols)
{
	uint8_t *cell_in = state_in;
	uint8_t *cell_out = state_out;
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

static void wireworld_step_mutable_impl(uint8_t *state, int rows, int cols)
{
	// First pass: compute new state and store in high 8 bits
	int size = rows * cols;
	for (int i = 0; i < size; i += 1)
	{
		uint8_t cell_out = evolve_cell(state, rows, cols, i / cols, i % cols, state[i]);
		state[i] |= (cell_out) << 4 & 0xF0;
	}
	// Second pass: move new state to low 8 bits
	for (int i = 0; i < size; i += 1)
	{
		state[i] = (state[i] >> 4) & 0x0F;
	}
}

static void wireworld_run_mutable_impl(uint8_t *state, int rows, int cols, int steps)
{
	for (int step = 0; step < steps; ++step)
	{
		wireworld_step_mutable_impl(state, rows, cols);
	}
}
