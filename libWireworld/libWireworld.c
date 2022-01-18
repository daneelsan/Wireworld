#include "wireworld.c"

#include "WolframNumericArrayLibrary.h"

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

EXTERN_C DLLEXPORT int wireworld_step_immutable(WolframLibraryData libData, mint argc, MArgument *args, MArgument res)
{
	mint error = LIBRARY_NO_ERROR;

	if (argc != 1) {
		return LIBRARY_FUNCTION_ERROR;
	}

	WolframNumericArrayLibrary_Functions naFuns = libData->numericarrayLibraryFunctions;
	MNumericArray state_array_in = MArgument_getMNumericArray(args[0]);
	if (naFuns->MNumericArray_getRank(state_array_in) != 2) {
		return LIBRARY_RANK_ERROR;
	}
	if (naFuns->MNumericArray_getType(state_array_in) != MNumericArray_Type_UBit16) {
		return LIBRARY_TYPE_ERROR;
	}

	const mint *dims = naFuns->MNumericArray_getDimensions(state_array_in);

	MNumericArray state_array_out;
	error = naFuns->MNumericArray_new(MNumericArray_Type_UBit16, 2, dims, &state_array_out);
	if (error) {
		return error;
	}

	uint16_t *state_in = naFuns->MNumericArray_getData(state_array_in);
	uint16_t *state_out = naFuns->MNumericArray_getData(state_array_out);

	wireworld_step_immutable_impl(state_in, state_out, dims[0], dims[1]);

	MArgument_setMNumericArray(res, state_array_out);
	return error;
}

EXTERN_C DLLEXPORT int wireworld_step_mutable(WolframLibraryData libData, mint argc, MArgument *args, MArgument res)
{
	mint error = LIBRARY_NO_ERROR;

	if (argc != 1) {
		return LIBRARY_FUNCTION_ERROR;
	}

	WolframNumericArrayLibrary_Functions naFuns = libData->numericarrayLibraryFunctions;
	MNumericArray state_array = MArgument_getMNumericArray(args[0]);
	if (naFuns->MNumericArray_getRank(state_array) != 2) {
		return LIBRARY_RANK_ERROR;
	}
	if (naFuns->MNumericArray_getType(state_array) != MNumericArray_Type_UBit16) {
		return LIBRARY_TYPE_ERROR;
	}

	const mint *dims = naFuns->MNumericArray_getDimensions(state_array);
	uint16_t *state = naFuns->MNumericArray_getData(state_array);

	wireworld_step_mutable_impl(state, dims[0], dims[1]);

	return error;
}
