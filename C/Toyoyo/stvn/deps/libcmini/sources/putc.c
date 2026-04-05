#include <stdio.h>
#include "lib.h"

int putc(int c, FILE *stream)
{
    int ret;
    unsigned char uc;

    uc = (unsigned char) c;
    ret = (int)fwrite(&uc, 1, 1, stream);

    return ret <= 0 ? EOF : uc;
}
int fputc(int c, FILE *stream) __attribute__((alias("putc")));
