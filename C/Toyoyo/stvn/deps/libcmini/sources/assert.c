#include "stdlib.h"
#include "stdio.h"
#include "assert.h"

void __assert_fail(const char * assertion, const char * file, unsigned int line, const char * function) {
    fprintf(stderr, "%s:%d: Assertion %s failed\r\n",
            file,
            line,
            assertion);
    abort();
}


