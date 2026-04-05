/*
 * getcwd.c
 *
 *  Created on: 25.07.2019
 *      Author: og
 */

#include <ext.h>
#include <errno.h>
#include <string.h>
#include <mint/osbind.h>
#include "lib.h"


char* getcwd(char* buffer, int bufflen)
{
    if (bufflen < 0)
    {
        __set_errno(ERANGE);
        buffer = NULL;
    } else
    {
        char path[MAXPATH];

        if (buffer == NULL && bufflen > 0)
        {
            buffer = malloc(bufflen);

            if (buffer == NULL)
                return NULL;
        }

        if (Dgetpath(&path[2], 0) < 0)
        {
            __set_errno(ENODEV);
        } else
        {
            path[0] = 'A' + Dgetdrv();
            path[1] = ':';

            if (buffer == NULL)
            {
                /* buffer is NULL and bufflen <= 0 -> allocate as much bytes as needed */
                buffer = strdup(path);
            } else if (bufflen > strlen(path))
            {
                strcpy(buffer, path);
            } else
            {
                /* bufflen is too small */
                buffer = NULL;
                __set_errno(ERANGE);
            }
        }
    }

    return buffer;
}
