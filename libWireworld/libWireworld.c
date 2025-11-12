#include "WolframLibrary.h"
#include "WolframNumericArrayLibrary.h"
#include "WolframSparseLibrary.h"

#include "wireworld.c"

EXTERN_C DLLEXPORT mint WolframLibrary_getVersion(void)
{
	return WolframLibraryVersion;
}

EXTERN_C DLLEXPORT int WolframLibrary_initialize(WolframLibraryData libData)
{
	return 0;
}

/*****************************************************************************/

EXTERN_C DLLEXPORT int wireworld_numeric_array_step_immutable(WolframLibraryData libData, mint argc, MArgument* args,
															  MArgument res)
{
	WolframNumericArrayLibrary_Functions numericFuns = libData->numericarrayLibraryFunctions;

	mint error = LIBRARY_NO_ERROR;

	if (argc != 1)
	{
		return LIBRARY_FUNCTION_ERROR;
	}

	MNumericArray state_array_in = MArgument_getMNumericArray(args[0]);
	if (numericFuns->MNumericArray_getRank(state_array_in) != 2)
	{
		return LIBRARY_RANK_ERROR;
	}
	if (numericFuns->MNumericArray_getType(state_array_in) != MNumericArray_Type_UBit8)
	{
		return LIBRARY_TYPE_ERROR;
	}

	MNumericArray state_array_out = NULL;
	error = numericFuns->MNumericArray_clone(state_array_in, &state_array_out);
	if (error)
	{
		return LIBRARY_FUNCTION_ERROR;
	}

	const mint* dims = numericFuns->MNumericArray_getDimensions(state_array_out);

	uint8_t* data_in = (uint8_t*) numericFuns->MNumericArray_getData(state_array_in);
	uint8_t* data_out = (uint8_t*) numericFuns->MNumericArray_getData(state_array_out);
	wireworld_step_immutable_impl(data_in, data_out, dims[0], dims[1]);

	MArgument_setMNumericArray(res, state_array_out);
	return error;
}

EXTERN_C DLLEXPORT int wireworld_numeric_array_run_mutable(WolframLibraryData libData, mint argc, MArgument* args,
														   MArgument res)
{
	WolframNumericArrayLibrary_Functions numericFuns = libData->numericarrayLibraryFunctions;

	mint error = LIBRARY_NO_ERROR;

	if (argc != 2)
	{
		return LIBRARY_FUNCTION_ERROR;
	}

	MNumericArray state_array_in = MArgument_getMNumericArray(args[0]);
	if (numericFuns->MNumericArray_getRank(state_array_in) != 2)
	{
		return LIBRARY_RANK_ERROR;
	}
	if (numericFuns->MNumericArray_getType(state_array_in) != MNumericArray_Type_UBit8)
	{
		return LIBRARY_TYPE_ERROR;
	}

	mint n_steps = MArgument_getInteger(args[1]);
	if (n_steps < 0)
	{
		return LIBRARY_FUNCTION_ERROR;
	}

	MNumericArray state_array_out = NULL;
	error = numericFuns->MNumericArray_clone(state_array_in, &state_array_out);
	if (error)
	{
		return LIBRARY_FUNCTION_ERROR;
	}

	const mint* dims = numericFuns->MNumericArray_getDimensions(state_array_out);

	uint8_t* data_out = (uint8_t*) (numericFuns->MNumericArray_getData(state_array_out));
	wireworld_run_mutable_impl(data_out, dims[0], dims[1], n_steps);

	MArgument_setMNumericArray(res, state_array_out);
	return error;
}

static MNumericArray state = NULL;

EXTERN_C DLLEXPORT int wireworld_load_state(WolframLibraryData libData, mint argc, MArgument* args, MArgument res)
{
	WolframNumericArrayLibrary_Functions numericFuns = libData->numericarrayLibraryFunctions;

	mint error = LIBRARY_NO_ERROR;

	if (argc != 1)
	{
		return LIBRARY_FUNCTION_ERROR;
	}

	state = MArgument_getMNumericArray(args[0]);
	// MNumericArray state_array_in = MArgument_getMNumericArray(args[0]);
	// if (numericFuns->MNumericArray_getRank(state_array_in) != 2)
	// {
	// 	return LIBRARY_RANK_ERROR;
	// }
	// if (numericFuns->MNumericArray_getType(state_array_in) != MNumericArray_Type_UBit8)
	// {
	// 	return LIBRARY_TYPE_ERROR;
	// }

	// if (state != NULL)
	// {
	// 	return LIBRARY_FUNCTION_ERROR;
	// }

	// state = state_array_in;

	return error;
}

EXTERN_C DLLEXPORT int wireworld_unload_state(WolframLibraryData libData, mint argc, MArgument* args, MArgument res)
{
	WolframNumericArrayLibrary_Functions numericFuns = libData->numericarrayLibraryFunctions;

	if (argc != 0)
	{
		return LIBRARY_FUNCTION_ERROR;
	}

	if (state == NULL)
	{
		return LIBRARY_NO_ERROR;
	}
	else
	{
		numericFuns->MNumericArray_disown(state);
		state = NULL;
	}

	return LIBRARY_NO_ERROR;
}

EXTERN_C DLLEXPORT int wireworld_run_state(WolframLibraryData libData, mint argc, MArgument* args, MArgument res)
{
	WolframNumericArrayLibrary_Functions numericFuns = libData->numericarrayLibraryFunctions;

	if (argc != 1)
	{
		return LIBRARY_FUNCTION_ERROR;
	}

	if (state == NULL)
	{
		return LIBRARY_FUNCTION_ERROR;
	}

	mint n_steps = MArgument_getInteger(args[0]);
	if (n_steps < 0)
	{
		return LIBRARY_FUNCTION_ERROR;
	}

	const mint* dims = numericFuns->MNumericArray_getDimensions(state);

	uint8_t* data_out = (uint8_t*) (numericFuns->MNumericArray_getData(state));
	wireworld_run_mutable_impl(data_out, dims[0], dims[1], n_steps);

	return LIBRARY_NO_ERROR;
}
