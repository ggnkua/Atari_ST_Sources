#include <stdio.h>
#include <stdlib.h>
#include <mint/osbind.h>
#include "lib.h"


FILE *fdopen(int fd, const char *mode)
{
    FILE* fp;

	if (mode == NULL) {
		return NULL;
	}

	fp = calloc(sizeof(FILE), 1);

	if (fp == NULL) {
		return NULL;
	} else {
		register int i;

        switch (*mode) {
            case 'a':
                fp->__mode.__write  = 1;
                fp->__mode.__create = 1;
                fp->__mode.__append = 1;
                break;

            case 'w':
                fp->__mode.__write  = 1;
                fp->__mode.__create = 1;
                break;

            case 'r':
                fp->__mode.__read = 1;
                break;

            default:
                free(fp);
                return NULL;

        }

        for (i = 1; i < 4; ++i) {
            switch (*++mode) {
                case '\0':
                default:
                    break;

                case '+':
                    fp->__mode.__read  = 1;
                    fp->__mode.__write = 1;
                    continue;

                case 'b':
                    fp->__mode.__binary = 1;
                    continue;

                case 'x':
                    fp->__mode.__exclusive = 1;
                    continue;

            }

            break;
        }

        if (fp->__mode.__append) {
            if(fd >= 0) {
                Fseek(0, fd, SEEK_END);
            }
        }
	}

    fp->__magic = _IOMAGIC;
    FILE_SET_HANDLE(fp, fd);
    fp->__pushback = EOF;
#ifdef STDIO_MAP_NEWLINE
    fp->__last_char = EOF;
#endif /* defined STDIO_MAP_NEWLINE */
    fp->__next = __stdio_head;
    fp->__eof = 0;
    fp->__error = 0;
    __stdio_head = fp;

	return fp;
}
