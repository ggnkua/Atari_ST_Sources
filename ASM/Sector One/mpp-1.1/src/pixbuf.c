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

#include <stdio.h>
#include <stdlib.h>

#include "pixbuf.h"

void
__mem_error(const void *ptr, const char *name, const char* file, int line) {
  if (!ptr) {
    fprintf(stderr, "%s:%d:allocation for pointer `%s' failed\n",
            file, line, name);
    exit(1);
  }
}

#define MEM_ERROR(ptr) __mem_error(ptr, #ptr, __FILE__, __LINE__)

static void write16(void *ptr, uint16_t val) {
  char *p = (char *)ptr;
  p[0] = val;
  p[1] = val>>8;
}

static void write32(void *ptr, uint16_t val) {
  char *p = (char *)ptr;
  p[0] = val;
  p[1] = val>>8;
  p[2] = val>>16;
  p[3] = val>>24;
}

static int rgb_encode(uint8_t *dest, const Pixel *src, int w) {
  int x;
  for (x = 0; x < w; x++) {
    *dest++ = src->cp.b;
    *dest++ = src->cp.g;
    *dest++ = src->cp.r;
    src++;
  }
  return w * 3;
}

void pixbuf_export_bmp(const PixBuf *pb, const char *filename) {
  int y;
  uint8_t row[pb->width*4];
  uint8_t header[54];
  const Pixel *pic = pb->array + (pb->height-1)*pb->width;
  FILE *out = fopen(filename, "wb");
  if (!out) {
    perror(filename);
    exit(1);
  }

  write16(header, 19778);
  write32(header + 2, pb->width*pb->height*3+14+40);
  write32(header + 6, 0);
  write32(header + 10, 14+40);

  write32(header + 14, 40);
  write32(header + 18, pb->width);
  write32(header + 22, pb->height);
  write16(header + 26, 1);
  write16(header + 28, 24);
  write32(header + 30, 0);
  write32(header + 34, pb->width*pb->height*3);
  write32(header + 38, 3780);
  write32(header + 42, 3780);
  write32(header + 46, 0x0);
  write32(header + 50, 0x0);

  fwrite(&header, sizeof(header), 1, out);
  for (y = 0; y < pb->height; y++) {
    fwrite(row, rgb_encode(row, pic, pb->width), 1, out);
    pic -= pb->width;
  }
  fclose(out);
}

PixBuf *pixbuf_new(int width, int height) {
  PixBuf *pb = malloc(sizeof(PixBuf));
  MEM_ERROR(pb);
  pb->_ptr = malloc(width * height * sizeof(Pixel) + 15);
  MEM_ERROR(pb->_ptr);
  intptr_t adr = (intptr_t)pb->_ptr;
  adr = (adr+15)&-16;
  pb->array = (Pixel*)adr;
  pb->width = width;
  pb->height = height;
  return pb;
}

void pixbuf_delete(PixBuf *pb) {
  free(pb->_ptr);
  free(pb);
}
