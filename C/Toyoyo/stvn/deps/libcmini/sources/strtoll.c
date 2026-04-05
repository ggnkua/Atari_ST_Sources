#include <limits.h>
#include <stdlib.h>
#include "lib.h"

# ifndef LLONG_MIN
#  define LLONG_MIN	(-LLONG_MAX-1)
# endif
# ifndef LLONG_MAX
#  define LLONG_MAX	__LONG_LONG_MAX__
# endif
# ifndef ULLONG_MAX
#  define ULLONG_MAX	(LLONG_MAX * 2ULL + 1)
# endif

long long strtoll(const char *nptr, char **endptr, int base) {
	int sign;
	unsigned long long ret = __strtoull_internal(nptr, endptr, base, &sign);
	return ret>LLONG_MAX ? (sign ? LLONG_MIN : LLONG_MAX) : (sign ? -ret : ret); 
}
