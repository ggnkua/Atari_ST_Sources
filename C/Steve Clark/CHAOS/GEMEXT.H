/* Copyright 1990 by Antic Publishing, Inc. */
/* This file contains some definitions of global variables that are required
   for any routine that uses gem functions. */

#define HIDEMOUSE v_hide_c(handle)
#define SHOWMOUSE v_show_c(handle, 0)
#define MOUSEARROW graf_mouse(0, 0)
#define MOUSEBEE graf_mouse(2, 0)

extern short   contrl[12];
extern short   intin[256];
extern short   ptsin[256];
extern short   intout[256];
extern short   ptsout[256];
extern short   workin[11];
extern short   workout[57];
extern short   handle;
extern short   xrez, yrez, nplanes;
extern short   letterw, letterh, charboxw, charboxh; /* from graf_handle() */

struct rastblk    /* Raster block */
      {
      short x, y, w, h;
      short *rastadr;
      };
