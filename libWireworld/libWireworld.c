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
	const mint *dims = libData->MTensor_getDimensions(state_tensor_in);

	MTensor state_tensor_out = NULL;
	error = libData->MTensor_clone(state_tensor_in, &state_tensor_out);
	if (error) {
		return error;
	}

	mint *state_in = libData->MTensor_getIntegerData(state_tensor_in);
	mint *state_out = libData->MTensor_getIntegerData(state_tensor_out);

	wireworld(state_in, state_out, dims[0], dims[1]);

	MArgument_setMTensor(res, state_tensor_out);
	return error;
}

/*
EXTERN_C DLLEXPORT int wireworld_run(WolframLibraryData libData, mint argc, MArgument *args, MArgument res)
{
	mint error = LIBRARY_NO_ERROR;

	if (argc != 2) {
		return LIBRARY_FUNCTION_ERROR;
	}

	MTensor state_tensor = MArgument_getMTensor(args[0]);
	mint steps = MArgument_getInteger(args[1]);

	mint *state = libData->MTensor_getIntegerData(state_tensor);
	mint *dims = libData->MTensor_getDimensions(state_tensor);

	for (int i = 0; i < steps; i += 1) {
		wireworld_step(state, dims[0], dims[1]);
	}

	MArgument_setMTensor(res, state_tensor);
	return error;
}
*/
