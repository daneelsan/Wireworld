#include "WolframLibrary.h"
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

EXTERN_C DLLEXPORT int wireworld_step_immutable(WolframLibraryData libData, mint argc, MArgument *args, MArgument res)
{
	mint error = LIBRARY_NO_ERROR;

	if (argc != 1)
	{
		return LIBRARY_FUNCTION_ERROR;
	}

	MTensor state_tensor_in = MArgument_getMTensor(args[0]);
	if (libData->MTensor_getRank(state_tensor_in) != 2)
	{
		return LIBRARY_RANK_ERROR;
	}
	if (libData->MTensor_getType(state_tensor_in) != MType_Integer)
	{
		return LIBRARY_TYPE_ERROR;
	}

	const mint *dims = libData->MTensor_getDimensions(state_tensor_in);

	MTensor state_tensor_out;
	error = libData->MTensor_new(MType_Integer, 2, dims, &state_tensor_out);
	if (error)
	{
		return error;
	}

	mint *state_in = libData->MTensor_getIntegerData(state_tensor_in);
	mint *state_out = libData->MTensor_getIntegerData(state_tensor_out);

	wireworld_step_immutable_impl(state_in, state_out, dims[0], dims[1]);

	MArgument_setMTensor(res, state_tensor_out);
	return error;
}

EXTERN_C DLLEXPORT int wireworld_run_immutable(WolframLibraryData libData, mint argc, MArgument *args, MArgument res)
{
	WolframSparseLibrary_Functions sparseFuns = libData->sparseLibraryFunctions;

	mint error = LIBRARY_NO_ERROR;

	if (argc != 2)
	{
		return LIBRARY_FUNCTION_ERROR;
	}

	MSparseArray state_array_in = MArgument_getMSparseArray(args[0]);
	if (sparseFuns->MSparseArray_getRank(state_array_in) != 2)
	{
		return LIBRARY_RANK_ERROR;
	}

	mint n_steps = MArgument_getInteger(args[1]);
	if (n_steps < 0)
	{
		return LIBRARY_FUNCTION_ERROR;
	}

	MTensor state_tensor_in;
	error = sparseFuns->MSparseArray_toMTensor(state_array_in, &state_tensor_in);
	if (error)
	{
		return LIBRARY_FUNCTION_ERROR;
	}

	if (libData->MTensor_getType(state_tensor_in) != MType_Integer)
	{
		return LIBRARY_TYPE_ERROR;
	}

	const mint *dims = libData->MTensor_getDimensions(state_tensor_in);

	MTensor state_tensor_out;
	error = libData->MTensor_new(MType_Integer, 2, dims, &state_tensor_out);
	if (error)
	{
		return error;
	}

	mint *state_in = libData->MTensor_getIntegerData(state_tensor_in);
	mint *state_out = libData->MTensor_getIntegerData(state_tensor_out);

	wireworld_run_immutable_impl(state_in, state_out, dims[0], dims[1], n_steps);

	MSparseArray state_array_out;
	error = sparseFuns->MSparseArray_fromMTensor(state_tensor_out, NULL, &state_array_out);

	// Free tensors after conversion
	libData->MTensor_free(state_tensor_in);
	libData->MTensor_free(state_tensor_out);

	if (error)
	{
		return error;
	}

	MArgument_setMSparseArray(res, state_array_out);
	return error;
}

EXTERN_C DLLEXPORT int wireworld_step_mutable(WolframLibraryData libData, mint argc, MArgument *args, MArgument res)
{
	mint error = LIBRARY_NO_ERROR;

	if (argc != 2)
	{
		return LIBRARY_FUNCTION_ERROR;
	}

	MTensor state_tensor = MArgument_getMTensor(args[0]);
	if (libData->MTensor_getRank(state_tensor) != 2)
	{
		return LIBRARY_RANK_ERROR;
	}
	if (libData->MTensor_getType(state_tensor) != MType_Integer)
	{
		return LIBRARY_TYPE_ERROR;
	}

	mint steps = MArgument_getInteger(args[1]);
	if (steps < 0)
	{
		return LIBRARY_FUNCTION_ERROR;
	}

	const mint *dims = libData->MTensor_getDimensions(state_tensor);
	mint *state = libData->MTensor_getIntegerData(state_tensor);

	for (int i = 0; i < steps; i += 1)
	{
		wireworld_step_mutable_impl(state, dims[0], dims[1]);
	}

	return error;
}
