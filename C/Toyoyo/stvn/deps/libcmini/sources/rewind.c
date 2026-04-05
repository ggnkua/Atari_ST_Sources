/*
 * rewind.c
 *
 *  Created on: 12.07.2017
 *      Author: og
 */

#include <stdio.h>


void rewind(FILE *stream)
{
    fseek(stream, 0, SEEK_SET);
    clearerr(stream);
    stream->__pushback = EOF;
#ifdef STDIO_MAP_NEWLINE
    stream->__last_char = EOF;
#endif /* defined STDIO_MAP_NEWLINE */
}
