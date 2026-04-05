/*
 * freopen.c
 *
 *  Created on: 12.07.2017
 *      Author: og
 */

#include <stdio.h>


FILE *freopen(const char *path, const char *mode, FILE *stream)
{
    if (fclose(stream))
        return NULL;

    return fopen(path, mode);
}
