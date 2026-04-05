#include <limits.h>
#include <stdlib.h>
#include "lib.h"

long strtol(const char *nptr, char **endptr, int base) {
	int sign;
	unsigned long ret = __strtoul_internal(nptr, endptr, base, &sign);
	return ret>LONG_MAX ? (sign ? LONG_MIN : LONG_MAX) : (sign ? -ret : ret); 
}
