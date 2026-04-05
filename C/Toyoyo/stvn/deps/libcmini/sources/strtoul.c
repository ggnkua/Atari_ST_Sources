#include <stdlib.h>
#include "lib.h"

unsigned long strtoul(const char *nptr, char **endptr, int base) {
	int sign;
	unsigned long ret = __strtoul_internal(nptr, endptr, base, &sign);
	return sign ? -ret : ret;
}
