#include <stdio.h>
#include <mint/osbind.h>
#include "lib.h"

long ftell(FILE *stream) {
	return Fseek(0, FILE_GET_HANDLE(stream), SEEK_CUR);
}
