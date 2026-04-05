/* Copyright (C) 1992,1995-2001,2004, 2008 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

#if HAVE_CONFIG_H
# include <config.h>
#endif

#include "lib.h"
#include <errno.h>
#if !_LIBC
# if !defined errno && !defined HAVE_ERRNO_DECL
extern int errno;
# endif
# undef __set_errno
# define __set_errno(ev) ((errno) = (ev))
#endif

#include <stdlib.h>
#include <string.h>

/* In the GNU C library we must keep the namespace clean.  */
#ifdef _LIBC
# define setenv __setenv
# define unsetenv __unsetenv
# define clearenv __clearenv
# define tfind __tfind
# define tsearch __tsearch
#endif

static int __add_to_environ(const char* name, const char* value, const char* combined, int replace);

/* If this variable is not a null pointer we allocated the current
   environment.  */
static char **last_environ;


/* This function is used by `setenv' and `putenv'.  The difference between
   the two functions is that for the former must create a new string which
   is then placed in the environment, while the argument of `putenv'
   must be used directly.  This is all complicated by the fact that we try
   to reuse values once generated for a `setenv' call since we can never
   free the strings.  */
int
__add_to_environ(const char* name, const char* value, const char* combined, int replace)
{
    register char** ep      = environ;
    register size_t size    = 0;
    const size_t    namelen = strlen(name);
    const size_t    vallen  = (value != NULL) ? (strlen(value) + 1) : 0;

    if (ep != NULL) {
        while (*ep != NULL) {
            if (strncmp(*ep, name, namelen) == 0 && (*ep)[namelen] == '=') {
                break;
            } else {
                ++size;
                ++ep;
            }
        }
    }

    if (ep == NULL || __builtin_expect(*ep == NULL, 1)) {
        char** new_environ;

        /* We allocated this space; we can extend it.  */
        new_environ = realloc(last_environ, sizeof(char*) * (size + 2));

        if (new_environ == NULL) {
            return -1;
        }

        /* If the whole entry is given add it.  */
        if (combined != NULL) {
            /* We must not add the string to the search tree since it belongs
               to the user.  */
            new_environ[size] = (char*)combined;
        } else {
            /* See whether the value is already known.  */
            new_environ[size] = malloc(namelen + 1 + vallen);

            if (__builtin_expect(new_environ[size] == NULL, 0)) {
                __set_errno(ENOMEM);
                return -1;
            }

            memcpy(new_environ[size], name, namelen);
            new_environ[size][namelen] = '=';
            memcpy(&new_environ[size][namelen + 1], value, vallen);
        }

        if (environ != last_environ) {
            memcpy(new_environ, environ, sizeof (char*) * size);
        }

        new_environ[size + 1] = NULL;
        last_environ = environ = new_environ;
    } else if (replace) {
        char *np;

        /* Use the user string if given.  */
        if (combined != NULL) {
            np = (char*)combined;
        } else {
            np = malloc(namelen + 1 + vallen);

            if (__builtin_expect(np == NULL, 0)) {
                return -1;
            }

            memcpy(np, name, namelen);
            np[namelen] = '=';
            memcpy(&np[namelen + 1], value, vallen);
        }

        *ep = np;
    }

    return 0;
}


int
setenv(const char* name, const char* value, int replace)
{
    if (name == NULL || *name == '\0' || strchr (name, '=') != NULL) {
        __set_errno(EINVAL);
        return -1;
    }

    return __add_to_environ(name, value, NULL, replace);
}


int
unsetenv(const char* name)
{
    size_t len;
    char** ep;

    if (name == NULL || *name == '\0' || strchr(name, '=') != NULL) {
        __set_errno(EINVAL);
        return -1;
    }

    len = strlen (name);
    ep  = environ;

    if (ep != NULL) {
        while (*ep != NULL) {
            if (strncmp(*ep, name, len) == 0 && (*ep)[len] == '=') {
                /* Found it.  Remove this pointer by moving later ones back.  */
                char** dp = ep;

                do {
                    dp[0] = dp[1];
                } while (*dp++ != NULL);

                /* Continue the loop in case NAME appears again.  */
            } else {
                ++ep;
            }
        }
    }

    return 0;
}
