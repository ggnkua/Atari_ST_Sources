/*  endian.h -- MiNTLib.
    Copyright (C) 1999 Guido Flohr <gufl0000@stud.uni-sb.de>

    This file is part of the MiNTLib project, and may only be used
    modified and distributed under the terms of the MiNTLib project
    license, COPYMINT.  By continuing to use, modify, or distribute
    this file you indicate that you have read the license and
    understand and accept it fully.
*/

#ifndef	_ENDIAN_H
# define _ENDIAN_H 1  /* Allow multiple inclusion.  */

/* This include file is mainly used for cross-compiling purposes.  */

#define __LITTLE_ENDIAN 1234
#define __BIG_ENDIAN    4321
#define __PDP_ENDIAN    3412

#define __BYTE_ORDER BIG_ENDIAN

#if defined (__USE_BSD) && !defined (__STRICT_ANSI__)

#ifndef LITTLE_ENDIAN
# define LITTLE_ENDIAN __LITTLE_ENDIAN
#endif

#ifndef BIG_ENDIAN
# define BIG_ENDIAN __BIG_ENDIAN
#endif

#ifndef PDP_ENDIAN
# define PDP_ENDIAN __PDP_ENDIAN
#endif

#define BYTE_ORDER __BYTE_ORDER

#endif

#endif /* _ENDIAN_H  */
