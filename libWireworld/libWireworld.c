#include "wireworld.c"

#include "WolframLibrary.h"

EXTERN_C DLLEXPORT mint WolframLibrary_getVersion(void)
{
	return WolframLibraryVersion;
}

EXTERN_C DLLEXPORT int WolframLibrary_initialize(WolframLibraryData libData)
{
	return 0;
}

/*****************************************************************************/

EXTERN_C DLLEXPORT int wireworld_step(WolframLibraryData libData, mint argc, MArgument *args, MArgument res)
{
	mint error = LIBRARY_NO_ERROR;

	if (argc != 1) {
		return LIBRARY_FUNCTION_ERROR;
	}

	MTensor state_tensor_in = MArgument_getMTensor(args[0]);
	if (libData->MTensor_getRank(state_tensor_in) != 2) {
		return LIBRARY_RANK_ERROR;
	}
	if (libData->MTensor_getType(state_tensor_in) != MType_Integer) {
		return LIBRARY_TYPE_ERROR;
	}

	const mint *dims = libData->MTensor_getDimensions(state_tensor_in);

	MTensor state_tensor_out;
	error = libData->MTensor_new(MType_Integer, 2, dims, &state_tensor_out);
	if (error) {
		return error;
	}

	mint *state_in = libData->MTensor_getIntegerData(state_tensor_in);
	mint *state_out = libData->MTensor_getIntegerData(state_tensor_out);

	wireworld_step_impl(state_in, state_out, dims[0], dims[1]);

	MArgument_setMTensor(res, state_tensor_out);
	return error;
}
