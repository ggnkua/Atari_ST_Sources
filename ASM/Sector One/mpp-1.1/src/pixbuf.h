/* -------------------------------------------------------------------
 Management of a basic pixel buffer with export to BMP file format.
 by Zerkman / Sector One
------------------------------------------------------------------- */

/* Copyright © 2012-2013 François Galea <fgalea at free.fr>
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * the COPYING file or http://www.wtfpl.net/ for more details. */

#ifndef _PIXBUF_H_
#define _PIXBUF_H_

#include <stdint.h>

typedef union pixel {
  uint32_t rgb;
  struct { uint8_t a, r, g, b; } cp;
} Pixel;

typedef struct _pixbuf {
  int width;
  int height;
  Pixel *array;
  void *_ptr;
} PixBuf;


PixBuf *pixbuf_new(int width, int height);
void pixbuf_delete(PixBuf *pb);
void pixbuf_export_bmp(const PixBuf *pb, const char *filename);

#endif
