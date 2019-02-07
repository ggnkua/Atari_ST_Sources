/* Copyright 1990 by Antic Publishing, Inc. */
/* This file contains the definitions of some variables that are
   required for the gem routines. */

#define HIDEMOUSE v_hide_c(handle)
#define SHOWMOUSE v_show_c(handle, 0)
#define MOUSEARROW graf_mouse(0, 0)
#define MOUSEBEE graf_mouse(2, 0)

short   contrl[12];
short   intin[256];
short   ptsin[256];
short   intout[256];
short   ptsout[256];
short   workin[] = {1,1,1,1,1,1,1,1,1,1,2};
short   workout[57];
short   handle;
short   xrez, yrez, nplanes;
short   letterh, letterw, charboxh, charboxw;   /* returned by graf_handle */

struct rastblk    /* Raster block */
      {
      short x, y, w, h;
      short *rastadr;
      };
