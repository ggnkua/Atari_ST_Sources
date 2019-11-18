/*
 * slb/png.h - Utility functions for the application,
 * when using the shared library.
 *
 * Copyright (C) 2018 Thorsten Otto
 *
 * This code is released under the libpng license.
 * For conditions of distribution and use, see the disclaimer
 * and license in png.h
 */
#ifndef __SLB_PNG_H__
#define __SLB_PNG_H__ 1

#ifndef PNGLIB_SLB
#define PNGLIB_SLB 1
#endif

#include "..\tools\png\png.h"

#ifndef _CDECL
#define _CDECL
#endif

#ifdef __cplusplus
extern "C" {
#endif

#if PNG_LIBPNG_VER >= 10600
#define PNG_SHAREDLIB_NAME "pnglib16.slb"
#elif PNG_LIBPNG_VER >= 10500
#define PNG_SHAREDLIB_NAME "pnglib15.slb"
#elif PNG_LIBPNG_VER >= 10400
#define PNG_SHAREDLIB_NAME "pnglib14.slb"
#elif PNG_LIBPNG_VER >= 10200
#define PNG_SHAREDLIB_NAME "pnglib12.slb"
#endif

long slb_pnglib_open(const char *slbpath);
void slb_pnglib_close(void);
void *slb_pnglib_get(void);

#if !defined(__GNUC__)
#include "..\tools\png\slb\purec\png.h"
#endif

#ifdef __cplusplus
}
#endif

#endif /* __SLB_PNGLIB_H__ */
