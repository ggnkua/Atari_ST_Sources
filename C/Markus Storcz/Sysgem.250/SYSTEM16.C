/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        "kernel.h"
#include        "nkcc.h"
#include        <scan.h>
#include        <tos.h>
#include        <string.h>
#include        <stdlib.h>

/* ------------------------------------------------------------------- */

EXTERN  XEVENT  xevent;
EXTERN  SYSGEM  sysgem;
EXTERN  BOOL    on_screen;
EXTERN  VOID    SetTopProc ( MPROC p );

/* ------------------------------------------------------------------- */

GLOBAL  INT     turn_back       = 0;

/* ------------------------------------------------------------------- */

LOCAL   INT     xflags          = 0;
LOCAL   INT     xstate          = 0;
LOCAL   BOOL    draw_3d         = FALSE;
LOCAL   USERB   *user           = NULL;
LOCAL   UINT    arr [16];
LOCAL   TPROC   userproc        = NULL;
LOCAL   UPROC   unknown         = NULL;
LOCAL   RECT    ic_minus        = { -1, -1, -1, -1 };
LOCAL	USR_PROC userkeyp;

/* ------------------------------------------------------------------- */

LOCAL   BOOL    terminate       = FALSE;

/* ------------------------------------------------------------------- */

LOCAL   UINT    IMG_PFEIL1 [] = { 0x0000, 0x0000, 0x0000, 0x03C0,
                                  0x03C0, 0x03C0, 0x03C0, 0x03C0,
                                  0x0FF0, 0x0FF0, 0x07E0, 0x03C0,
                                  0x0180, 0x0000, 0x0000, 0x0000 };

LOCAL   UINT    IMG_PFEIL4 [] = { 0x0000, 0x0000, 0x0000, 0x0000,
                                  0x00C0, 0x00E0, 0x1FF0, 0x1FF8,
                                  0x1FF8, 0x1FF0, 0x00E0, 0x00C0,
                                  0x0000, 0x0000, 0x0000, 0x0000 };

LOCAL   UINT    IMG_PFEIL5 [] = { 0x0000, 0x0000, 0x0000, 0x0000,
                                  0x0300, 0x0700, 0x0FF8, 0x1FF8,
                                  0x1FF8, 0x0FF8, 0x0700, 0x0300,
                                  0x0000, 0x0000, 0x0000, 0x0000 };

LOCAL   UINT    IMG_PFEIL6 [] = { 0x0000, 0x0000, 0x0000, 0x0180,
                                  0x03C0, 0x07E0, 0x0FF0, 0x0FF0,
                                  0x03C0, 0x03C0, 0x03C0, 0x03C0,
                                  0x03C0, 0x0000, 0x0000, 0x0000 };

LOCAL   UINT    IMG_CIRCLE [] = { 0x0000, 0x0000, 0x13C0, 0x1C30,
                                  0x1C08, 0x0008, 0x2004, 0x2004,
                                  0x2004, 0x2004, 0x1000, 0x1038,
                                  0x0C38, 0x03C8, 0x0000, 0x0000 };

/* ------------------------------------------------------------------- */

LOCAL   UINT    IMG_SELLNH [] = { 0x0000, 0x7FFE, 0x4002, 0x4002,
                                  0x4002, 0x4002, 0x4002, 0x4002,
                                  0x4002, 0x4002, 0x4002, 0x4002,
                                  0x4002, 0x4002, 0x7FFE, 0x0000 };

LOCAL   UINT    IMG_SELVNH [] = { 0x0000, 0x7FFE, 0x4002, 0x581A,
                                  0x5C3A, 0x4E72, 0x47E2, 0x43C2,
                                  0x43C2, 0x47E2, 0x4E72, 0x5C3A,
                                  0x581A, 0x4002, 0x7FFE, 0x0000 };

LOCAL   UINT    IMG_SELLDH [] = { 0x0000, 0x5554, 0x0002, 0x4000,
                                  0x0002, 0x4000, 0x0002, 0x4000,
                                  0x0002, 0x4000, 0x0002, 0x4000,
                                  0x0002, 0x4000, 0x2AAA, 0x0000 };

LOCAL   UINT    IMG_SELVDH [] = { 0x0000, 0x5554, 0x0002, 0x4810,
                                  0x142A, 0x4A50, 0x04A2, 0x4140,
                                  0x0282, 0x4520, 0x0A52, 0x5428,
                                  0x0812, 0x4000, 0x2AAA, 0x0000 };

LOCAL   UINT    IMG_CIRLNH [] = { 0x0000, 0x0000, 0x0380, 0x0C60,
                                  0x1010, 0x2008, 0x2008, 0x4004,
                                  0x4004, 0x4004, 0x2008, 0x2008,
                                  0x1010, 0x0C60, 0x0380, 0x0000 };

LOCAL   UINT    IMG_CIRVNH [] = { 0x0000, 0x0000, 0x0380, 0x0C60,
                                  0x1010, 0x2388, 0x27C8, 0x4FE4,
                                  0x4FE4, 0x4FE4, 0x27C8, 0x2388,
                                  0x1010, 0x0C60, 0x0380, 0x0000 };

LOCAL   UINT    IMG_CIRLDH [] = { 0x0000, 0x0000, 0x0280, 0x0820,
                                  0x0000, 0x2008, 0x0000, 0x4004,
                                  0x0000, 0x4004, 0x0000, 0x2008,
                                  0x0000, 0x0820, 0x0280, 0x0000 };

LOCAL   UINT    IMG_CIRVDH [] = { 0x0000, 0x0000, 0x0280, 0x0820,
                                  0x0000, 0x2288, 0x0540, 0x4AA4,
                                  0x0540, 0x4AA4, 0x0540, 0x2288,
                                  0x0000, 0x0820, 0x0280, 0x0000 };

LOCAL   UINT    IMG_SELLNN [] = { 0x3FFC, 0x2004, 0x2004, 0x2004,
                                  0x2004, 0x2004, 0x3FFC, 0x0000 };

LOCAL   UINT    IMG_SELVNN [] = { 0x3FFC, 0x381C, 0x2664, 0x2184,
                                  0x2664, 0x381C, 0x3FFC, 0x0000 };

LOCAL   UINT    IMG_SELLDN [] = { 0x2AA8, 0x0004, 0x2000, 0x0004,
                                  0x2000, 0x0004, 0x2AA8, 0x0000 };

LOCAL   UINT    IMG_SELVDN [] = { 0x2AA4, 0x1008, 0x2244, 0x0180,
                                  0x2244, 0x1000, 0x2AAC, 0x0000 };

LOCAL   UINT    IMG_CIRLNN [] = { 0x0FF0, 0x781E, 0xE007, 0xC003,
                                  0xC003, 0xE007, 0x781E, 0x0FF0 };

LOCAL   UINT    IMG_CIRVNN [] = { 0x0FF0, 0x781E, 0xE3C7, 0xCFF3,
                                  0xCFF3, 0xE3C7, 0x781E, 0x0FF0 };

LOCAL   UINT    IMG_CIRLDN [] = { 0x0FF0, 0x781E, 0xE007, 0xC003,
                                  0xC003, 0xE007, 0x781E, 0x0FF0 };

LOCAL   UINT    IMG_CIRVDN [] = { 0x0AA0, 0x5014, 0xA285, 0x4542,
                                  0x8AA1, 0x4282, 0x500A, 0x0550 };

/* ------------------------------------------------------------------- */

VOID rect3d ( INT x0, INT y0, INT x1, INT y1, BOOL sel )

{
  INT   col_do  = BLACK;
  INT   col_du  = BLACK;

  if ( draw_3d )
    {
      col_do = WHITE;
      col_du = LBLACK;
      if ( sel )
        {
          col_do = LBLACK;
          col_du = WHITE;
        }
    }
  Line ( x0, y1, x0, y0, col_do );
  Line ( x0, y0, x1, y0, col_do );
  Line ( x0, y1, x1, y1, col_du );
  Line ( x1, y1, x1, y0, col_du );
}

/* ------------------------------------------------------------------- */

VOID draw_box0 ( INT x0, INT y0, INT x1, INT y1 )

{
  if ( draw_3d )
    {
      FilledRect ( x0, y0, x1, y1, sysgem.lwhite );
    }
  else
    {
      FilledRect ( x0, y0, x1, y1, WHITE );
    }
}

/* ------------------------------------------------------------------- */

VOID draw_box1 ( INT x0, INT y0, INT x1, INT y1 )

{
  draw_box0 ( x0, y0, x1, y1 );
  Frame     ( x0 - 1, y0 - 1, x1 + 1, y1 + 1, -1, ( draw_3d ) ? LBLACK : BLACK );
}

/* ------------------------------------------------------------------- */

VOID draw_box4 ( INT x0, INT y0, INT x1, INT y1, INT color )

{
  if ( draw_3d )
    {
      x0 -= 3;
      y0 -= 3;
      x1 += 3;
      y1 += 3;

      FilledRect ( x0 - 1, y0 - 1, x1 - 1, y1 - 1, WHITE );

      Line ( x0, y1, x0, y0, color );
      Line ( x0, y0, x1, y0, color );

      x0--;  y0--;  x1++;  y1++;

      Line ( x0, y1, x0, y0, color );
      Line ( x0, y0, x1, y0, color );
      Line ( x0 + 1, y1, x1, y1, LWHITE  );
      Line ( x1, y1, x1, y0 + 1, LWHITE  );
    }
}

/* ------------------------------------------------------------------- */

VOID draw_box5 ( INT x0, INT y0, INT x1, INT y1 )

{
  INT   color;

  color = BLACK;
  if ( draw_3d )
    {
      color = LBLACK;
      x1--;  y1--;
    }

  Line ( x0, y0, x0, y1, color );
  Line ( x0, y1, x1, y1, color );
  Line ( x1, y1, x1, y0, color );
  Line ( x0, y0, x1, y0, color );

  if ( draw_3d )
    {
      Line ( x0 + 1, y0 + 1, x0 + 1, y1 - 1, WHITE );
      Line ( x0, y1 + 1, x1 + 1, y1 + 1,     WHITE );
      Line ( x1 + 1, y1 + 1, x1 + 1, y0,     WHITE );
      Line ( x0 + 1, y0 + 1, x1 - 1, y0 + 1, WHITE );
    }
}

/* ------------------------------------------------------------------- */

VOID PaintShortCut ( INT x, INT y )

{
  REG   INT   x0;
        INT   w;
        BYTE  sh        [2];
        BYTE  ch;
        INT   col;

  col = sysgem.shortcut_color;
  if ( user->pos == -1 ) return;
  if ( xstate & DISABLED )
    {
      if ( draw_3d ) col = LWHITE;
                else col = WHITE;
    }
  if ( xflags & HIDETREE ) return;

  y--;

  y  += StringHeight ();
  sh [0] = user->text [user->pos];
  sh [1] = 0;
  ch = user->text [user->pos];
  user->text [user->pos] = 0;
  x0 = StringWidth ( user->text );
  user->text [user->pos] = ch;
  w  = StringWidth ( sh );
  x0 = x + x0 - 1;
  Line ( x0, y, x0 + w, y, col );
}

/* ------------------------------------------------------------------- */

VOID draw_button ( PARMBLK *p )

{
  REG   INT     x0, y0, x1, y1;
        INT     x, y;
        INT     fill;
        INT     txt;

  x0    = p->pb_x;
  y0    = p->pb_y;
  x1    = x0 + p->pb_w - 1;
  y1    = y0 + p->pb_h - 1;
  fill  = WHITE;
  txt   = BLACK;

  if ( xstate & DISABLED )
    {
      x0++;  y0++;  x1--;  y1--;
      x0++;  y0++;  x1--;  y1--;
      TextEffect ( 2 );
      if ( draw_3d )
        {
          rect3d ( x0, y0, x1, y1, TRUE );
        }
      else
        {
          Frame ( x0, y0, x1, y1, BLACK, -1 );
        }
      goto button_text;
    }

  if ( xstate & SELECTED )
    {
      fill = BLACK;
      if ( draw_3d == FALSE ) txt = WHITE;
    }

  if ( xflags & DEFAULT )
    {
      if ( sysgem.like_mac )
        {
          Line ( x0 + 1, y0, x1 - 1, y0, BLACK );
          Line ( x1, y0 + 1, x1, y1 - 1, BLACK );
          Line ( x0, y0 + 1, x0, y1 - 1, BLACK );
          Line ( x0 + 1, y1, x1 - 1, y1, BLACK );
        }
      else
        {
          Frame ( x0, y0, x1, y1, -1, BLACK );
        }
      x0++;  y0++;  x1--;  y1--;
      x0++;  y0++;  x1--;  y1--;
      Frame ( x0, y0, x1, y1, -2, BLACK );
      x0++;  y0++;  x1--;  y1--;
      FilledRect ( x0, y0, x1, y1, ( draw_3d ) ? sysgem.lblack : fill );
      if ( draw_3d )
        {
          rect3d ( x0, y0, x1, y1, ( xstate & SELECTED ));
        }
      goto button_text;
    }

  if ( xflags & TOUCHEXIT )
    {
      x0++;  y0++;  x1--;  y1--;
      x0++;  y0++;  x1--;  y1--;
      FilledRect ( x0, y0, x1, y1, ( draw_3d ) ? sysgem.lwhite : WHITE );
      draw_box5  ( x0, y0, x1, y1 );
      goto button_text;
    }

  if ( xflags & EXIT )
    {
      x0++;  y0++;  x1--;  y1--;
      if ( sysgem.like_mac )
        {
          Line ( x0 + 1, y0, x1 - 1, y0, BLACK );
          Line ( x1, y0 + 1, x1, y1 - 1, BLACK );
          Line ( x0, y0 + 1, x0, y1 - 1, BLACK );
          Line ( x0 + 1, y1, x1 - 1, y1, BLACK );
        }
      else
        {
          Frame ( x0, y0, x1, y1, -1, BLACK );
        }
      x0++;  y0++;  x1--;  y1--;
      Frame ( x0, y0, x1, y1, -1, BLACK );
      x0++;  y0++;  x1--;  y1--;
      FilledRect ( x0, y0, x1, y1, ( draw_3d ) ? sysgem.lblack : fill );
      if ( draw_3d )
        {
          rect3d ( x0, y0, x1, y1, ( xstate & SELECTED ));
        }
    }

  button_text:

  TransMode ();
  x = CenterX ( x0, x1, user->text );
  y = CenterY ( y0, y1 );
  v_stext ( txt, x, y, user->text );
  TextColor ( BLACK );
  TextEffect ( 0 );
  ReplaceMode ();
  PaintShortCut ( x, y );
}

#ifdef RSMOVL

/* ------------------------------------------------------------------- */

VOID draw_radio_Area ( OBJECT *Objc, GRECT *Area )
{
  Area->g_w= Objc->ob_w +24;
}

#endif

/* ------------------------------------------------------------------- */

VOID draw_radio ( PARMBLK *p )

{
  REG   INT   x0, y0;
        INT   effect;

  x0    = p->pb_x;
  y0    = p->pb_y;
  y0    = CenterY ( y0, y0 + p->pb_h - 1 );

  effect = 0;

  if ( xstate & SELECTED )
    {
      if ( xstate & DISABLED )
        {
          CopyToScreen ( draw_3d, IMG_CIRVDH, IMG_CIRVDN, x0, y0 );
          effect = 2;
        }
      else
        {
          CopyToScreen ( draw_3d, IMG_CIRVNH, IMG_CIRVNN, x0, y0 );
        }
    }
  else
    {
      if ( xstate & DISABLED )
        {
          CopyToScreen ( draw_3d, IMG_CIRLDH, IMG_CIRLDN, x0, y0 );
          effect = 2;
        }
      else
        {
          CopyToScreen ( draw_3d, IMG_CIRLNH, IMG_CIRLNN, x0, y0 );
        }
    }
  TransMode ();
  TextEffect ( effect );
  v_stext ( BLACK, x0 + 24, y0, user->text );
  TextEffect ( 0 );
  ReplaceMode ();
  PaintShortCut ( x0 + 24, y0 );
}

/* ------------------------------------------------------------------- */

VOID draw_select ( PARMBLK *p )

{
  REG   INT   x0, y0;
        INT   effect;

  x0    = p->pb_x;
  y0    = p->pb_y;
  y0    = CenterY ( y0, y0 + p->pb_h - 1 );

  effect = 0;

  if ( xstate & SELECTED )
    {
      if ( xstate & DISABLED )
        {
          CopyToScreen ( draw_3d, IMG_SELVDH, IMG_SELVDN, x0, y0 );
          effect = 2;
        }
      else
        {
          CopyToScreen ( draw_3d, IMG_SELVNH, IMG_SELVNN, x0, y0 );
        }
    }
  else
    {
      if ( xstate & DISABLED )
        {
          CopyToScreen ( draw_3d, IMG_SELLDH, IMG_SELLDN, x0, y0 );
          effect = 2;
        }
      else
        {
          CopyToScreen ( draw_3d, IMG_SELLNH, IMG_SELLNN, x0, y0 );
        }
    }
  TransMode ();
  TextEffect ( effect );
  v_stext ( BLACK, x0 + 24, y0, user->text );
  TextEffect ( 0 );
  ReplaceMode ();
  PaintShortCut ( x0 + 24, y0 );
}

/* ------------------------------------------------------------------- */

UINT *xdisable ( UINT *image )

{
  REG   INT     i;

  for ( i = 0; i < 16; i++ )
    {
      arr [i] = image [i];
    }
  arr [ 0] = arr [ 0] & ~0xAAAA;
  arr [ 1] = arr [ 1] & ~0x5555;
  arr [ 2] = arr [ 2] & ~0xAAAA;
  arr [ 3] = arr [ 3] & ~0x5555;
  arr [ 4] = arr [ 4] & ~0xAAAA;
  arr [ 5] = arr [ 5] & ~0x5555;
  arr [ 6] = arr [ 6] & ~0xAAAA;
  arr [ 7] = arr [ 7] & ~0x5555;
  arr [ 8] = arr [ 8] & ~0xAAAA;
  arr [ 9] = arr [ 9] & ~0x5555;
  arr [10] = arr [10] & ~0xAAAA;
  arr [11] = arr [11] & ~0x5555;
  arr [12] = arr [12] & ~0xAAAA;
  arr [13] = arr [13] & ~0x5555;
  arr [14] = arr [14] & ~0xAAAA;
  arr [15] = arr [15] & ~0x5555;

  return ( &arr [0] );
}

/* ------------------------------------------------------------------- */

VOID draw_boxchar ( PARMBLK *p )

{
  REG   INT             x0, y0, x1, y1;
        INT             x, y;
        INT             txt_col;
        INT             fill_col;
        BYTE            text [2];
        COLOR_INF       cinf;
        INT             ext;
        UINT            *image;

  txt_col  = ( xstate & SELECTED ) ? WHITE : BLACK;
  fill_col = ( xstate & SELECTED ) ? BLACK : WHITE;
  x0       = p->pb_x;
  y0       = p->pb_y;
  x1       = x0 + p->pb_w - 1;
  y1       = y0 + p->pb_h - 1;
  cinf.p   = user->parm;
  text [0] = cinf.b.character;
  text [1] = 0;
  ext      = user->ext;

  if ( sysgem.ymax <= 200 ) ext = 0;

  if ( xstate & SHADOWED )
    {
      x1 -= 2;
      y1 -= 2;
    }
  if ( draw_3d )
    {
      txt_col  = BLACK;
      fill_col = LWHITE;
    }
  x = (( x1 - x0 ) / 2 ) - 8 + x0 + 1;
  y = (( y1 - y0 ) / 2 ) - 8 + y0 + 1;

  FilledRect ( x0 + 1, y0 + 1, x1 - 1, y1 - 1, fill_col );

  switch ( ext )
    {
      case  1 : image = IMG_PFEIL1; if ( xstate & DISABLED ) image = xdisable ( image );
                CopyToScreen ( draw_3d, image, NULL, x, y );       goto do_3d;
      case  2 : text [0] = 240;
                goto normal;
      case  3 : image = IMG_PFEIL4; if ( xstate & DISABLED ) image = xdisable ( image );
                CopyToScreen ( draw_3d, image, NULL, x, y );       goto do_3d;
      case  4 : image = IMG_PFEIL5; if ( xstate & DISABLED ) image = xdisable ( image );
                CopyToScreen ( draw_3d, image, NULL, x, y );       goto do_3d;
      case  5 : image = IMG_PFEIL6; if ( xstate & DISABLED ) image = xdisable ( image );
                CopyToScreen ( draw_3d, image, NULL, x, y );       goto do_3d;
      case  6 : image = IMG_CIRCLE; if ( xstate & DISABLED ) image = xdisable ( image );
                CopyToScreen ( draw_3d, image, NULL, x, y );       goto do_3d;
      case  7 : image = IMG_PFEIL1; if ( xstate & DISABLED ) image = xdisable ( image );
                CopyToScreen ( draw_3d, image, NULL, x, y );       goto frame;
      case  8 : image = IMG_PFEIL4; if ( xstate & DISABLED ) image = xdisable ( image );
                CopyToScreen ( draw_3d, image, NULL, x, y );       goto frame;
      case  9 : image = IMG_PFEIL5; if ( xstate & DISABLED ) image = xdisable ( image );
                CopyToScreen ( draw_3d, image, NULL, x, y );       goto frame;
      case 10 : image = IMG_PFEIL6; if ( xstate & DISABLED ) image = xdisable ( image );
                CopyToScreen ( draw_3d, image, NULL, x, y );       goto frame;
      case 12 :
      default : normal:
                x = CenterX ( x0, x1, text );
                y = CenterY ( y0, y1 );
                if (( text [0] == '\003' ) || ( text [0] == '\004' ))
                  {
                    y++;
                  }
                TransMode ();
                TextEffect ( 0 );
                if ( xstate & DISABLED ) TextEffect ( 2 );
                v_stext ( txt_col, x, y, text );
                TextEffect ( 0 );
                ReplaceMode ();
                Frame ( x0, y0, x1, y1, -1, BLACK );
                if ( ext == 12 ) goto frame;
                break;
    }

  do_3d:

  if (( xstate & SHADOWED ) == 0 )
    {
      rect3d ( x0, y0, x1, y1, (( xstate & SELECTED ) == 0 ) ? FALSE : TRUE );
    }
  else
    {
      rect3d ( x0, y0, x1, y1, FALSE );
    }
  if ( xstate & SHADOWED )
    {
      Line ( x0 + 1, y1 + 1, x1 + 1, y1 + 1, BLACK );
      Line ( x1 + 1, y1 + 1, x1 + 1, y0 + 1, BLACK );
      if ( ! draw_3d )
        {
          Line ( x0 + 1, y1 + 2, x1 + 1, y1 + 2, BLACK );
          Line ( x1 + 2, y1 + 2, x1 + 2, y0 + 1, BLACK );
        }
    }

  return;
  frame:

  Frame ( x0, y0, x1, y1, -1, BLACK );
  if ( draw_3d ) rect3d ( x0 + 1, y0 + 1, x1 - 1, y1 - 1, (( xstate & SELECTED ) == 0 ) ? FALSE : TRUE );
}

/* ------------------------------------------------------------------- */

VOID draw_text ( PARMBLK *p )

{
  REG   INT       x0, y0, x1, y1;
        TEDINFO   *ted;
        COLOR_INF cinf;
        INT       x, y;
        INT       eff;

  ted      = (TEDINFO *) user->parm;
  cinf.p   = ted->te_color;
  x0       = p->pb_x + 1;
  y0       = p->pb_y + 1;
  x1       = p->pb_x + p->pb_w - 2;
  y1       = p->pb_y + p->pb_h - 3;
  eff      = 0;

  if ( xstate & DISABLED ) eff = 2;

  if ( draw_3d )
    {
      FilledRect ( x0, y0, x1 + 1, y1 + 2, ( user->ext == 1 ) ? WHITE : sysgem.lwhite );
    }
  else
    {
      FilledRect ( x0, y0, x1 + 1, y1 + 2, WHITE );
    }

  if ( user->typ == G_BOXTEXT )
    {
      x0--;
      y0--;
      x1++;
      y1++;
      if ( cinf.b.framesize != 0 )
        {
          rect3d ( x0, y0, x1, y1, FALSE );
          if ( xstate & SHADOWED )
            {
              Line ( x0 + 1, y1 + 1, x1 + 1, y1 + 1, BLACK );
              Line ( x1 + 1, y1 + 1, x1 + 1, y0 + 1, BLACK );
              if ( ! draw_3d )
                {
                  Line ( x0 + 1, y1 + 2, x1 + 1, y1 + 2, BLACK );
                  Line ( x1 + 2, y1 + 2, x1 + 2, y0 + 1, BLACK );
                }
            }
        }
    }
  else
    {
      if ( xstate & SELECTED ) eff |= 1;
    }

  if ( ted->te_font == 5 ) SmallFont ();

  switch ( ted->te_just )
    {
      case 0 : x = x0;
               break;
      case 1 : x = x1 - StringWidth ( user->text ) + 1;
               break;
      case 2 : x = CenterX ( x0, x1, ted->te_ptext );
               break;
    }


  TransMode ();
  y = CenterY ( y0, y1 );
  TextEffect ( eff );
  v_stext ( cinf.b.textcol, x, y, user->text );
  TextEffect ( 0 );
  if ( user->typ == G_BOXTEXT ) y--;
  ReplaceMode ();
  NormalFont ();
  PaintShortCut ( x, y );
}

/* ------------------------------------------------------------------- */

VOID draw_frame ( PARMBLK *p )

{
  REG   INT       x0, y0, x1, y1;
        INT       x, y;
        INT       len;

  x0       = p->pb_x;
  y0       = p->pb_y + 1;
  x1       = p->pb_x + p->pb_w - 2;
  y1       = p->pb_y + p->pb_h - 2;

  if ( xstate & 0x0040 ) /* Whiteback gesetzt? */
    {
      FilledRect ( x0, y0, x1, y1, ( draw_3d ) ? sysgem.lwhite : WHITE );
    }

  draw_box5 ( x0, y0, x1, y1 );

  len = StringWidth ( user->text );
  if ( len == 0 ) return;

  if ( xstate & CHECKED )
    {
      SmallFont ();
    }

  if ( xstate & CROSSED )
    {
      x = CenterX ( x0, x1, user->text );
    }
  else
    {
      x = x0 + 10;
    }
  y = y0 - ( StringHeight () / 2 );
  y++;
  if (( draw_3d ) && ( xstate & CHECKED )) y++;
  len = StringWidth ( user->text );
  if ( draw_3d )
    {
      Line ( x, y0, x + len - 1, y0, sysgem.lwhite );
      Line ( x, y0 + 1, x + len - 1, y0 + 1, sysgem.lwhite );
    }
  else
    {
      Line ( x, y0, x + len - 1, y0, WHITE );
    }
  TransMode ();
  v_stext ( sysgem.frametext_color, x, y, user->text );
  ReplaceMode ();
  NormalFont ();
}

/* ------------------------------------------------------------------- */

VOID draw_string ( PARMBLK *p )

{
  REG   INT     x0, y0, x1, y1;
        INT     y, x;
        INT     text;
        INT     eff;

  x0       = p->pb_x/* + 1*/;
  y0       = p->pb_y/* + 1*/;
  x1       = p->pb_x + p->pb_w - 1;
  y1       = p->pb_y + p->pb_h - 1/*2*/;
  eff      = 0;

  if ( xstate & DISABLED ) eff = 2;

  text = BLACK;

  if ( xstate & SELECTED )
    {
      if ( draw_3d )
        {
          text = LWHITE;
          FilledRect ( x0, y0, x1, y1, BLACK );
        }
      else
        {
          text = WHITE;
          FilledRect ( x0, y0, x1, y1, BLACK );
        }
    }
  else
    {
      if ( draw_3d )
        {
          FilledRect ( x0, y0, x1, y1, sysgem.lwhite );
        }
      else
        {
          FilledRect ( x0, y0, x1, y1, WHITE );
        }
    }

  TransMode ();
  y = CenterY ( y0, y1 );
  TextEffect ( eff );
  if ( user->ext == 1 )
    {
      x = x1 - StringWidth ( user->text ) - 1;
    }
  else
    {
      x = x0;
    }
  v_stext ( text, x, y, user->text );
  TextEffect ( 0 );
  if (( xstate & SHADOWED ) || ( xstate & OUTLINED ))
    {
      Line ( x0, y1 + 1, x1, y1 + 1, BLACK );
      if ( xstate & OUTLINED )
        {
          Line ( x0, y1 + 3, x1, y1 + 3, BLACK );
        }
    }
  else
    {
      PaintShortCut ( x, y );
    }
  ReplaceMode ();
}

#ifdef RSMOVL

/* ------------------------------------------------------------------- */

VOID draw_box_Area ( OBJECT *Objc, GRECT *Area )
{
  INT        x0, y0, x1, y1;

  x0    = Objc->ob_x;
  y0    = Objc->ob_y;
  x1    = x0 + Objc->ob_w - 1;
  y1    = y0 + Objc->ob_h - 1;

  switch ( Objc->ob_type >> 8 )
	{
		default:
		break;
    case 6    : if ( draw_3d )
                  {
/*
printf("Anfang\r\n");
printf("Obj      :  %i, %i, %i, %i \r\n",Objc->ob_x,Objc->ob_y,Objc->ob_w,Objc->ob_h);
printf("Area vor : %i, %i, %i, %i \r\n",Area->g_x,Area->g_y,Area->g_w,Area->g_h);
*/
                  	Area->g_x= x0 -3;
                  	Area->g_y= y0 -3;

                  	Area->g_w /*+=3*/ = x1+3 - (x0 -3);
                  	Area->g_h /*+=3*/ = y1+3 - (y0 -3);
/*
printf("Area nach: %i, %i, %i, %i \r\n",Area->g_x,Area->g_y,Area->g_w,Area->g_h);
printf("\r\n");
*/
                  }
                else
                  {
/*
                  	Area->g_x= x0 -3;
                  	Area->g_y= y0 -3;
                  	Area->g_w= x1+3 - x0 -3;
                  	Area->g_y= y1+3 - y0 -3;
                    Frame ( x0, y0, x1, y1, -1, BLACK );
*/
                  }
                break;
		
	}
}

#endif

/* ------------------------------------------------------------------- */

VOID draw_box ( PARMBLK *p )

{
  REG   INT        x0, y0, x1, y1;
        COLOR_INF  cinf;

  x0    = p->pb_x;
  y0    = p->pb_y;
  x1    = x0 + p->pb_w - 1;
  y1    = y0 + p->pb_h - 1;

  if (( p->pb_obj == 0 ) && ( user->ext != 16 ))
    {
      draw_box0 ( x0 - 1, y0, x1 + 1, y1 + 1 );
      return;
    }

  switch ( user->ext )
    {
      default   :
      case 0    : normal:
                  cinf.p = user->parm;
                  PaintPattern ( x0, y0, x1, y1, &cinf.b );
                  break;
      case 3    : rect3d ( x0 + 1, y0 + 1, x1 - 1, y1 - 1, ( ! ( xstate & SELECTED )));
      case 2    : rect3d ( x0, y0, x1, y1, ( ! ( xstate & SELECTED )));
                  break;
      case 4    : if (( draw_3d ) || ( sysgem.edit_mono ) || ( xstate & 0x040 ))
                    {
                      x0 -= 2; y0 -= 3; x1 += 2; y1 += 3;

                      Frame ( x0, y0, x1, y1, -1, BLACK );
                      x0++; y0++; x1--; y1--;
                      FilledRect ( x0, y0, x1, y1, WHITE );
                    }
                  break;
      case 5    : draw_box5 ( x0, y0, x1, y1 );
                  break;
      case 6    : if ( draw_3d )
                    {
                      draw_box4 ( x0 - 3, y0 - 3, x1 + 3, y1 + 3, BLACK );
                    }
                  else
                    {
                      Frame ( x0, y0, x1, y1, -1, BLACK );
                    }
                  break;
      case 7    : Frame ( x0, y0, x1, y1, -1, BLACK );
                  x0++; y0++; x1--; y1--;
                  FilledRect ( x0, y0, x1, y1, WHITE );
                  break;
      case 8    : if ( draw_3d == FALSE ) goto normal;
                  Frame ( x0, y0, x1, y1, -1, BLACK );
                  x0++; y0++; x1--; y1--;
                  rect3d ( x0, y0, x1, y1, FALSE );
                  x0++; y0++; x1--; y1--;
                  FilledRect ( x0, y0, x1, y1, sysgem.lwhite );
                  break;
      case 9    : if ( draw_3d == FALSE ) goto normal;
                  Frame ( x0, y0, x1, y1, -1, BLACK );
                  x0++; y0++; x1--; y1--;
                  FilledRect ( x0, y0, x1, y1, sysgem.lblack );
                  break;
      case 11   : draw_box0 ( x0, y0, x1, y1 );
                  break;
      case 12   : draw_box1 ( x0, y0, x1, y1 );
                  break;
      case 13   : x0++;
                  x1--;
                  if ( draw_3d )
                    {
                      rect3d ( x0, y0, x1, y1, ! ( xstate & SELECTED ));
                      x0++; y0++; x1--; y1--;
                    }
      case 14   : u14:
                  if ( xstate & SELECTED )
                    {
                      FilledRect ( x0, y0, x1, y1, ( draw_3d ) ? LBLACK : BLACK );
                    }
                  else
                    {
                      FilledRect ( x0, y0, x1, y1, ( draw_3d ) ? LWHITE : WHITE );
                    }
                  break;
      case 15   : x0++;
                  x1--;
                  y0--;
                  Line ( x0, y0, x1, y0, BLACK );
                  Line ( x0, y1, x1, y1, BLACK );
                  y0++;
                  y1--;
                  goto u14;
      case 16   :														/* Untergrund fr Reiter [GS] */
      						FilledRect ( x0, y0, x1, y1, ( draw_3d ) ? sysgem.lwhite : WHITE );
                  Line ( x0, y1 + 1, x1, y1 + 1, BLACK );
                  break;
      case 17   : if ( draw_3d )
                    {
                      y1--;
                      Line ( x0, y1, x1, y1, LBLACK );
                      y1++;
                      Line ( x0, y1, x1, y1, WHITE );
                    }
                  else
                    {
                      Line ( x0, y1, x1, y1, BLACK );
                    }
                  break;
      case 18   : if ( draw_3d )
                    {
                      Line ( x0 + 1, y0, x0 + 1, y1, WHITE  );
                      Line ( x0 + 0, y0, x0 + 1, y1, LBLACK );
                    }
                  else
                    {
                      Line ( x0 + 1, y0, x0 + 1, y1, BLACK );
                    }
                  break;
    }
}

/* ------------------------------------------------------------------- */

VOID draw_reiter ( PARMBLK *p )

{
  REG   INT     x0, y0, x1, y1;

  ReplaceMode ();
  x0     = p->pb_x;
  y0     = p->pb_y;
  x1     = x0 + p->pb_w - 1;
  y1     = y0 + p->pb_h - 1;

  y0++;
  y1++;

  Line ( x0, y1, x0, y0 + 4,     BLACK );
  Line ( x0, y0 + 4, x0 + 4, y0, BLACK );
  Line ( x0 + 4, y0, x1 - 4, y0, BLACK );
  Line ( x1 - 4, y0, x1, y0 + 4, BLACK );
  Line ( x1, y0 + 4, x1, y1,     BLACK );

  if ( xstate & SELECTED )
    {
      Line ( x0 + 1, y1, x1 - 1, y1, ( draw_3d ) ? sysgem.lwhite : WHITE );
    }
  if ( draw_3d )
    {
      x0++; y0++; x1--; y1--;
      Line ( x0, y1, x0, y0 + 4,     WHITE  );
      Line ( x0, y0 + 4, x0 + 4, y0, WHITE  );
      Line ( x0 + 4, y0, x1 - 4, y0, WHITE  );
      Line ( x1 - 4, y0, x1, y0 + 4, LBLACK );
      Line ( x1, y0 + 4, x1, y1,     LBLACK );
    }

  TransMode ();
  x0 = CenterX ( x0, x1, user->text );
  y0 = CenterY ( y0, y1 );
  TextEffect ( 0 );
  if ( xstate & DISABLED )
    {
      TextEffect ( 2 );
    }
  v_stext ( BLACK, x0, y0, user->text );
  ReplaceMode ();
  PaintShortCut ( x0, y0 );
  TextEffect ( 0 );
}

/* ------------------------------------------------------------------- */

VOID draw_edit ( PARMBLK *p )

{
  REG   INT             x0, y0, x1, y1;
        TEDINFO         *ted;
        COLOR_INF       cinf;

  ReplaceMode ();
  x0     = p->pb_x;
  y0     = p->pb_y;
  x1     = x0 + p->pb_w - 0; /* 2 */
  y1     = y0 + p->pb_h - 1;
  ted    = (TEDINFO *) user->parm;
  cinf.p = ted->te_color;

  if (( xstate & 0x0040 ) == 0 ) /* whiteback */
    {
      Frame ( x0, y0, x1, y1, -1, BLACK );
    }
  x0++; y0++; x1--; y1--;
  FilledRect ( x0, y0, x1, y1, WHITE );

  x0++; y0++; x1--; y1--;
  TransMode ();
  v_stext ( cinf.b.textcol, x0 + 2, y0, ted->te_ptext );
  ReplaceMode ();
}

/* ------------------------------------------------------------------- */

VOID draw_help ( PARMBLK *p )

{
  REG   INT     x0, y0, x1, y1;
        INT     col;

  if ( p->pb_tree [p->pb_obj].ob_flags & EXIT )
    {
      draw_button ( p );
      return;
    }

  ReplaceMode ();
  x0     = p->pb_x;
  y0     = p->pb_y;
  x1     = x0 + p->pb_w - 1;
  y1     = y0 + p->pb_h - 1;
  col    = BLACK;

  x0++; y0++; x1--; y1--;
  if ( draw_3d == FALSE )
    {
      Line ( x0 + 1, y1 + 1, x1 + 1, y1 + 1, BLACK );
      Line ( x1 + 1, y0 + 1, x1 + 1, y1 + 1, BLACK );
    }
  rect3d ( x0, y0, x1, y1, xstate & SELECTED );
  x0++; y0++; x1--; y1--;
  if ( draw_3d )
    {
      FilledRect ( x0, y0, x1, y1, sysgem.lwhite );
    }
  else
    {
      if ( xstate & SELECTED )
        {
          FilledRect ( x0, y0, x1, y1, BLACK );
          col = WHITE;
        }
      else
        {
          FilledRect ( x0, y0, x1, y1, WHITE );
        }
    }

  SmallFont ();
  TransMode ();
  x0 = CenterX ( x0, x1, user->text );
  y0 = CenterY ( y0, y1 );
  TextEffect ( 0 );
  if ( xstate & DISABLED )
    {
      TextEffect ( 2 );
    }
  v_stext ( col, x0, y0, user->text );
  NormalFont ();
  ReplaceMode ();
  TextEffect ( 0 );
}

#ifdef RSMOVL

/* ------------------------------------------------------------------- */
/* Neue Funktion zum ermittel der Gr”že der Listebox									 */

VOID draw_listbox_Area ( OBJECT *Objc, GRECT *Area )
{
  INT     w;

  w      = ( 2 * sysgem.charw ) + 1;

	Area->g_w = Objc->ob_w + w + 2 + 12;
}

#endif

/* ------------------------------------------------------------------- */

VOID draw_listbox ( PARMBLK *p )

{
  REG   INT     x0, y0, x1, y1;
        INT     x, y;
        INT     w;

  ReplaceMode ();
  w      = ( 2 * sysgem.charw ) + 1;
  x0     = p->pb_x;
  y0     = p->pb_y;
  x1     = x0 + p->pb_w - 2;
  y1     = y0 + p->pb_h - 2;

  if (( p->pb_currstate ^ p->pb_prevstate ) & SELECTED ) goto do_draw;

  Frame      ( x0, y0, x1 - w, y1, -1, BLACK );
  FilledRect ( x0 + 1, y0 + 1, x1 - w - 1, y1 - 1, WHITE );
  x = x1 - w - 2;
  Frame      ( x, y0, x1, y1, -1, BLACK );
  FilledRect ( x + 1, y0 + 1, x1 - 1, y1 - 1, ( draw_3d ) ? sysgem.lwhite : WHITE );

  x = (( x1 - x  ) / 2 ) - 8 + x  + 1;
  y = (( y1 - y0 ) / 2 ) - 8 + y0 + 1;

  if ( user->ob_typ == OBJ_LISTBOX )
    {
      if ( sysgem.ymax <= 200 )
        {
          TransMode ();
          v_stext ( BLACK, x + ( sysgem.charw / 2 ), y, "\002" );
          ReplaceMode ();
        }
      else
        {
          CopyToScreen ( draw_3d, IMG_PFEIL1, NULL, x, y );
        }
    }
  else
    {
      if ( sysgem.ymax <= 200 )
        {
          TransMode ();
          v_stext ( BLACK, x + ( sysgem.charw / 2 ), y, "O" );
          ReplaceMode ();
        }
      else
        {
          CopyToScreen ( draw_3d, IMG_CIRCLE, NULL, x, y );
        }
    }

  do_draw:

  x = x1 - w - 2;

  if ( draw_3d )
    {
      rect3d ( x + 1, y0 + 1, x1 - 1, y1 - 1, xstate & SELECTED );
    }
  else
    {
      Line ( x0 + 1, y1 + 1, x1 + 1, y1 + 1, BLACK );
      Line ( x1 + 1, y1 + 1, x1 + 1, y0 + 1, BLACK );
    }

  TransMode ();
  x0 = x0 + 3;
  y0 = CenterY ( y0, y1 );
  TextEffect ( 0 );
  if ( xstate & DISABLED )
    {
      TextEffect ( 2 );
    }
  v_stext ( BLACK, x0, y0, user->text );
  ReplaceMode ();
  PaintShortCut ( x0, y0 );
  TextEffect ( 0 );
}

/* ------------------------------------------------------------------- */

INT CDECL draw_mline ( PARMBLK *p )

{
  INT   pxy [4];

  vswr_mode     ( sysgem.vdi_handle, MD_REPLACE );
  vsf_style     ( sysgem.vdi_handle, 4 );
  vsf_interior  ( sysgem.vdi_handle, FIS_PATTERN );
  vsf_color     ( sysgem.vdi_handle, BLACK );
  vsf_perimeter ( sysgem.vdi_handle, 0 );
  pxy [0] = p->pb_x;
  pxy [1] = p->pb_y + ( sysgem.charh / 2 ) - 1;
  pxy [2] = p->pb_x + p->pb_w - 1;
  pxy [3] = p->pb_y + ( sysgem.charh / 2 );
  v_bar ( sysgem.vdi_handle, pxy );
  vsf_style     ( sysgem.vdi_handle, 0 );

  return ( 0 );
}

/* ------------------------------------------------------------------- */

VOID draw_mentry ( PARMBLK *p )

{
  REG   INT     x0, y0, x1, y1, y;

  ReplaceMode ();
  NormalFont ();
  x0     = p->pb_x;
  y0     = p->pb_y;
  x1     = x0 + p->pb_w - 1;
  y1     = y0 + p->pb_h - 1;

  if ( user->text != NULL )
    {
      if (( user->text [0] == '-' ) && ( user->text [1] == '-' ) && ( user->text [2] == '-' ) && ( xstate & DISABLED ))
        {
          if ( draw_3d )
            {
              x0 += 2;
              y0 += ( sysgem.charh / 2 );
              x1 -= 2;
              Line ( x0, y0, x1, y0, sysgem.lblack );
              y0++;
              Line ( x0, y0, x1, y0, WHITE );
            }
          else
            {
              draw_mline ( p );
            }
          return;
        }
      if ( user->ob_typ == OBJ_MTITLE )
        {
          y = y1 - 1;
        }
      else
        {
          y = y1;
        }
      if ( xstate & SELECTED )
        {
          FilledRect ( x0, y0, x1, y, ( draw_3d ) ? sysgem.selb_color : BLACK );
        }
      else
        {
          FilledRect ( x0, y0, x1, y, ( draw_3d ) ? sysgem.lwhite : WHITE );
        }
      y0 = CenterY ( y0, y1 - 1 );
      TransMode ();
      if ( xstate & DISABLED )
        {
          TextEffect ( 2 );
        }
      if ( xstate & SELECTED )
        {
          if ( xstate & CHECKED )
            {
              v_stext (( draw_3d ) ? sysgem.selt_color : WHITE, x0 + 2, y0, "" );
            }
          v_stext (( draw_3d ) ? sysgem.selt_color : WHITE, x0, y0, user->text );
        }
      else
        {
          if ( xstate & CHECKED )
            {
              v_stext ( BLACK, x0  + 2, y0, "" );
            }
          v_stext ( BLACK, x0, y0, user->text );
        }
    }
  TextEffect ( 0 );
  ReplaceMode ();
}

/* ------------------------------------------------------------------- */

VOID draw_mbox ( PARMBLK *p )

{
  REG   INT     x0, y0, x1, y1;

  ReplaceMode ();
  x0     = p->pb_x;
  y0     = p->pb_y;
  x1     = x0 + p->pb_w - 1;
  y1     = y0 + p->pb_h - 1;

  if ( p->pb_obj <= 3 )
    {
      x0--;  x1++;  y0--;  y1++;
      Frame ( x0, y0, x1, y1, -1, BLACK );
      x0++;  x1--;  y0++;  y1--;
      FilledRect ( x0, y0, x1, y1, ( draw_3d ) ? sysgem.lwhite : WHITE );
      return;
    }
  x0--;  x1++;  y1++;
  Frame ( x0, y0, x1, y1, -1, BLACK );
  x0++;  x1--;  y1--;
  FilledRect ( x0, y0, x1, y1, ( draw_3d ) ? sysgem.lwhite : WHITE );
}

/* ------------------------------------------------------------------- */

VOID draw_balken ( PARMBLK *p, BOOL percent )

{
  REG   INT        x0, y0, x1, y1;
        INT        w, h, i;
        COLOR_INF  cinf;
        BYTE       txt [10];

  x0    = p->pb_x;
  y0    = p->pb_y;
  x1    = x0 + p->pb_w - 1;
  y1    = y0 + p->pb_h - 1;

  ReplaceMode ();
  cinf.p = user->next->parm;
  Frame ( x0, y0, x1, y1, -1, BLACK );

  w = p->pb_tree [p->pb_obj + 1].ob_width;
  h = p->pb_tree [p->pb_obj + 1].ob_height;

  if ( p->pb_w > p->pb_h )
    {
      x0++; y0++; x1--; y1--;
      if ( x0 + w >= x1 ) w = x1 - x0;
      PaintPattern ( x0, y0, x0 + w, y1, &cinf.b );
      x0 += w;
      if ( x0 < x1 ) FilledRect ( x0, y0, x1, y1, WHITE );
    }
  else
    {
      x0++; y0++; x1--; y1--;
      PaintPattern ( x0, y0 + h, x1, y1, &cinf.b );
      y1 -= h;
      if ( y0 < y1 ) FilledRect ( x0, y0, x1, y1, WHITE );
    }

  if ( percent )
    {
      x0 = p->pb_x;
      y0 = p->pb_y;
      x1 = x0 + p->pb_w - 1;
      y1 = y0 + p->pb_h - 1;
      w = p->pb_tree [p->pb_obj + 1].ob_width;
      h = p->pb_tree [p->pb_obj + 1].ob_height;

      NormalFont ();
      if ( p->pb_w > p->pb_h )
        {
          i = (INT)(((LONG)( w ) * 100L ) / (LONG)( p->pb_w ));
          if ( h < 16 ) SmallFont ();
        }
      else
        {
          i = (INT)(((LONG)( h ) * 100L ) / (LONG)( p->pb_h ));
          if ( w < 40 ) SmallFont ();
        }
      sprintf ( txt, "%d %%", i );
      x0 = CenterX ( x0, x1, txt );
      y0 = CenterY ( y0, y1 );

      if ( sysgem.act_color >= 16 )
        {
          if (( cinf.b.interiorcol == WHITE ) || ( cinf.b.interiorcol == BLACK ))
            {
              vswr_mode ( sysgem.vdi_handle, MD_XOR );
            }
          else
            {
              TransMode ();
            }
        }
      else
        {
          vswr_mode ( sysgem.vdi_handle, MD_XOR );
        }
      v_stext ( BLACK, x0, y0, txt );
    }
  NormalFont ();
  ReplaceMode ();
}

/* ------------------------------------------------------------------- */

INT CDECL DrawUserDef ( PARMBLK *p )

{
  user   = (USERB *) p->pb_parm;

#ifndef RSMOVL															/* [GS] */
  xflags = p->pb_tree [p->pb_obj].ob_flags;
  xstate = p->pb_tree [p->pb_obj].ob_state;
#else																				/* [GS] */
  xflags = p->pb_tree [0].ob_flags;						/* Da immer nur ein Objekt [GS] */
 	xstate = p->pb_tree [0].ob_state;						/* [GS] */
#endif																			/* [GS] */

  ReplaceMode ();
  NormalFont ();
  
  switch ( user->ob_typ )
    {
      case OBJ_BUTTON  :
      case OBJ_TOUCH   : draw_button  ( p );    return ( 0 );
      case OBJ_RADIO   : draw_radio   ( p );    return ( 0 );
      case OBJ_SELECT  : draw_select  ( p );    return ( 0 );
      case OBJ_BOX     : draw_box     ( p );    return ( 0 );
      case OBJ_CHAR    : draw_boxchar ( p );    return ( 0 );
      case OBJ_TEXT    : draw_text    ( p );    return ( 0 );
      case OBJ_STRING  : draw_string  ( p );    return ( 0 );
      case OBJ_FRAME   : draw_frame   ( p );    return ( 0 );
      case OBJ_MENTRY  : draw_mentry  ( p );    return ( 0 );
      case OBJ_MTITLE  : draw_mentry  ( p );    return ( 0 );
      case OBJ_MBOX    : draw_mbox    ( p );    return ( 0 );
      case OBJ_EDIT    : draw_edit    ( p );    return ( 0 );
      case OBJ_HELP    : draw_help    ( p );    return ( 0 );
      case OBJ_REITER  : draw_reiter  ( p );    return ( 0 );
      case OBJ_LISTBOX : draw_listbox ( p );    return ( 0 );
      case OBJ_CIRCLE  : draw_listbox ( p );    return ( 0 );
      case OBJ_BALKEN1 : draw_balken  ( p, 0 ); return ( 0 );
      case OBJ_BALKEN2 : draw_balken  ( p, 1 ); return ( 0 );
      case OBJ_BALKEN3 : break;
      default          : break;
    }
  return ( 0 );
}

/* ------------------------------------------------------------------- */

VOID Enable3D ( VOID )

{
  WINDOW        *win;

  if ( draw_3d == TRUE ) return;

  if ( sysgem.act_color >= 16 )
    {
      draw_3d = TRUE;
    }
  else
    {
      draw_3d = FALSE;
    }
#ifndef RSMOVL															/* [GS] */
  win = sysgem.window;
  while ( win != NULL )
    {
      SendMessage ( SG_3DSTATE, win, NULL, NULL, 0, 0, 0, 0 );
      RedrawWindow ( win->handle );
      win = win->next;
    }
#endif																			/* [GS] */
}

/* ------------------------------------------------------------------- */

VOID Disable3D ( VOID )

{
  WINDOW        *win;

  if ( draw_3d == FALSE ) return;

  draw_3d = FALSE;

#ifndef RSMOVL															/* [GS] */
  win = sysgem.window;
  while ( win != NULL )
    {
      SendMessage ( SG_3DSTATE, win, NULL, NULL, 0, 0, 0, 0 );
      RedrawWindow ( win->handle );
      win = win->next;
    }
#endif																			/* [GS] */
}

/* ------------------------------------------------------------------- */

BOOL SysGem3D ( VOID )

{
  return ( draw_3d );
}

/* ------------------------------------------------------------------- */

INT DrawSlider ( OBJECT *tree, INT hide, LONG p1, LONG p2, BOOL draw )

{
  INT   percent;
  INT   old;
  INT   new;
  LONG  perc;
  LONG  obw;


  if ( p2 == 0L )
    {
      p1 = 0L;
      p2 = 1L;
    }
  percent = (INT)(( p1 * 100L ) / p2 );

  if ( tree [hide].ob_width > tree [hide].ob_height )
    {
      old  = tree [hide + 1].ob_width;
      perc = (LONG)( percent );
      obw  = (LONG)( tree [hide].ob_width );
      perc = ( perc * obw ) / 100L;
      tree [hide + 1].ob_width = (INT)( perc );
      if ( tree [hide + 1].ob_width < 1 ) tree [hide + 1].ob_width = 1;
      if ( tree [hide + 1].ob_width > tree [hide].ob_width ) tree [hide + 1].ob_width = tree [hide].ob_width;
      new = tree [hide + 1].ob_width;
    }
  else
    {
      old = tree [hide + 1].ob_y;
      perc = (LONG)( percent );
      obw  = (LONG)( tree [hide].ob_height );
      perc = ( perc * obw ) / 100L;
      tree [hide + 1].ob_height = (INT)( perc );
      if ( tree [hide + 1].ob_height < 2 ) tree [hide + 1].ob_height = 1;
      if ( tree [hide + 1].ob_height > tree [hide].ob_height ) tree [hide + 1].ob_height = tree [hide].ob_height;
      tree [hide + 1].ob_y = tree [hide].ob_height - tree [hide + 1].ob_height;
      new = tree [hide + 1].ob_y;
    }

  if ( draw )
    {
      if ( old != new )
        {
          RedrawObj ( tree, hide, 8, NONE, UPD_STATE );
        }
    }
  if ( percent <   0 ) percent = 0;
  if ( percent > 100 ) percent = 100;
  return ( percent );
}

/* ------------------------------------------------------------------- */

#ifndef EXTOB

/* ------------------------------------------------------------------- */

INT is_object ( WINDOW *win, LONG *id, INT x, INT y )

{
  WTREE         *wt;
  INT           obj;

  wt = win->tree;
  while ( wt != NULL )
    {
      if ( wt->pos == LINK_MENU ) goto weiter;
      obj = objc_find ( wt->dial->tree, wt->start, wt->depth, x, y );
      if ( obj != -1 )
        {
          *id = wt->id;
          return ( obj );
        }
      weiter:
      wt = wt->next;
    }
  *id = 0L;
  return ( -1 );
}

/* ------------------------------------------------------------------- */

#define DD_OK   0
#define DD_NAK  1

/* ------------------------------------------------------------------- */

LOCAL BOOL PutValue ( INT handle, LONG len, VOID *data )

{
  LONG  l;

  l = Fwrite ( handle, len, data );
  if ( l != len )
    {
      Fclose ( handle );
      return ( FALSE );
    }
  return ( TRUE );
}

/* ------------------------------------------------------------------- */

LOCAL BOOL GetValue ( INT handle, LONG len, VOID *data )

{
  LONG  l;

  l = Fread ( handle, len, data );
  if ( l != len )
    {
      Fclose ( handle );
      return ( FALSE );
    }
  return ( TRUE );
}

/* ------------------------------------------------------------------- */

LOCAL BOOL HandleDDProtocol ( DRAG_DROP *d, BYTE *ext )

{
  BYTE  *pipe           = "U:\\PIPE\\DRAGDROP.AA";
  BYTE  *p;
  LONG  exts       [8]  = { 'ARGS', '.TXT', '.FLT', 0L, 0L, 0L, 0L, 0L };
  LONG  file;
  INT   handle;
  INT   hlen;
  BYTE  cmd;

  pipe [17] = ext [0];
  pipe [18] = ext [1];
  cmd       = DD_OK;

  file = Fopen ( pipe, FO_RW );
  if ( file < 0L )
    {
      return ( FALSE );
    }
  handle = (INT)( file );
  if ( ! PutValue ( handle,  1L, &cmd )) return ( FALSE );
  if ( ! PutValue ( handle, 32L, &exts [0] )) return ( FALSE );
  if ( ! GetValue ( handle,  2L, &hlen )) return ( FALSE );
  if ( ! GetValue ( handle,  4L, &d->data_type )) return ( FALSE );
  if ( ! GetValue ( handle,  4L, &d->data_len  )) return ( FALSE );

  d->data = (BYTE *) Allocate ( d->data_len + 20L );
  if ( d->data == NULL )
    {
      Fclose ( handle );
      return ( FALSE );
    }

  hlen -= 8;
  p = &d->data_id [0];
  forever
    {
      if ( ! GetValue ( handle, 1L, &cmd )) return ( FALSE );
      hlen--;
      if ( cmd == 0 ) break;
      *p++ = cmd;
    }
  p = &d->filename [0];
  forever
    {
      if ( hlen <= 0 ) break;
      if ( ! GetValue ( handle, 1L, &cmd )) return ( FALSE );
      if ( cmd == 0 ) break;
      *p++ = cmd;
    }

  if ( ! PutValue ( handle, 1L, &cmd )) return ( FALSE );
  if ( ! GetValue ( handle, d->data_len, d->data )) return ( FALSE );

  Fclose ( handle );

  return ( TRUE );
}

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */

VOID SetProcEvent ( TPROC proc )

{
  userproc = proc;
}

/* ------------------------------------------------------------------- */

VOID IchBinThorsten ( VOID )

{
  sysgem.bergner = TRUE;
}

/* ------------------------------------------------------------------- */

INT TerminateSysGem ( VOID )

{
  if ( sysgem.app )
    {
      terminate = TRUE;
      return ( TERM_OK );
    }
  return ( TERM_DENIED_ACC );
}

/* ------------------------------------------------------------------- */

#ifndef EXTOB

/* ------------------------------------------------------------------- */

VOID SetOnlineHelp ( BYTE *prg_name1, BYTE *prg_name2, BYTE *file_name )

{
  assign ( prg_name1, sysgem.help_prg_name );
  assign ( prg_name2, sysgem.help_prg_path );
  assign ( file_name, sysgem.help_prg_file );
}

/* ------------------------------------------------------------------- */

BOOL CallOnlineHelp ( BYTE *help )

{
  WINDOW        *win;
  INT           viewer;
  INT           msg [8];

  win = find_window ( GetTopWindow (), 0L );
  if ( win != NULL )
    {
      hide_cursor ( win->dial );
    }

  sprintf ( sysgem.global_mem, "%s %s", sysgem.help_prg_file, help );

  viewer = SearchProgram ( sysgem.help_prg_name );
  if ( viewer != -1 ) goto weiter;

  if ( sysgem.multitasking )
    {
      if ( length ( sysgem.help_prg_path ) > 0 )
        {
          shel_write ( 1, 1, 100, sysgem.help_prg_path, sysgem.global_mem );
          evnt_timer ( 20, 0 );
          return ( TRUE );
        }
    }
  return ( FALSE );

  weiter:

  msg [0] = VA_START;
  msg [1] = sysgem.appl_id;
  msg [2] = 0;
  msg [3] = (INT)((LONG)( sysgem.global_mem ) >> 16 );
  msg [4] = (INT)((LONG)( sysgem.global_mem ) >>  0 );
  msg [5] = 0;
  msg [6] = 0;
  msg [7] = 0;

  appl_write ( viewer, 16, msg );
  evnt_timer ( 20, 0 );
  return ( TRUE );
}

/* ------------------------------------------------------------------- */

VOID TakeEvent ( INT event, INT x, INT y, INT state, INT kstate, INT key, INT clicks, INT *msg )

{
  xevent.mwich   = event;
  xevent.x       = x;
  xevent.y       = y;
  xevent.state   = state;
  xevent.kstate  = kstate;
  xevent.key     = key;
  xevent.clicks  = clicks;
  xevent.msg [0] = msg [0];
  xevent.msg [1] = msg [1];
  xevent.msg [2] = msg [2];
  xevent.msg [3] = msg [3];
  xevent.msg [4] = msg [4];
  xevent.msg [5] = msg [5];
  xevent.msg [6] = msg [6];
  xevent.msg [7] = msg [7];
  sysgem.new_event = TRUE;
}

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */

LOCAL VOID DelKeyboard ( VOID )

{
  EVENT event;
  INT   d;

  memset ( &event, 0, sizeof ( event ));
  event.ev_mflags = MU_KEYBD | MU_TIMER;

  d = MU_KEYBD;
  while (( d & MU_KEYBD ) != 0 )
    {
      d = EvntMulti ((EVENT *) &event );
    }
}

/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */

/* ------------------------------------------------------------------- */

VOID DelButton ( VOID )

{
  EVENT event;
  INT   d;

  memset ( &event, 0, sizeof ( event ));
  event.ev_mflags   = MU_BUTTON | MU_TIMER;
  event.ev_mbclicks = 0x0102;
  event.ev_bmask    = 0x0003;
  event.ev_mbstate  = 0x0000;

  d = MU_BUTTON;
  while (( d & MU_BUTTON ) != 0 )
    {
      d = EvntMulti ((EVENT *) &event );
    }
}

/* ------------------------------------------------------------------- */

VOID SetUserKeyProc ( USR_PROC u )

{
  userkeyp = u;
}

/* ------------------------------------------------------------------- */

VOID HandleEvents ( VOID )

{
  WINDOW        *win;
  INT           title;
  INT           event;
  UINT          key;

  event = GetTopWindow ();
  win   = find_window ( event, 0L );
  if ( win != NULL )
    {
      if (( win->flags & WIN_VISIBLE ) && ( win->flags & WIN_DRAWN ))
        {
          if ( ! sysgem.cursor_off ) show_cursor ( win->dial );
        }
    }

  if ( sysgem.new_event )
    {
      event = xevent.mwich;
      sysgem.new_event = FALSE;
    }
  else
    {
      event = EvntMulti ((EVENT *) &xevent );
    }

	if ( sysgem.fslx )																	/* [GS] */
		{																									/* [GS]	*/
			HandleFslx ( (EVENT *) &xevent );								/* [GS] */
		}																									/* [GS] */
		
  if ( event & MU_MESAG )
    {
      if ( sysgem.msg_shown )
        {
          if ( xevent.msg [0] != WM_REDRAW ) return;
        }

      if ( sysgem.fslx  )															/* [GS] */
        {																							/* [GS] */
          if ( xevent.msg [0] != WM_REDRAW &&					/* [GS] */
          		 xevent.msg [0] != WM_MOVED ) return;		/* [GS] */
        }																							/* [GS] */

      switch ( xevent.msg [0] )
        {
          case MN_SELECTED      : title = xevent.msg [3];
                                  if ( sysgem.menu_proc != NULL )
                                    {
                                      if ( sysgem.menu_proc ( &xevent.msg [0], xevent.msg [4] ) == SG_TERM ) /* [GS] */
                                        {
                                          TerminateSysGem ();
                                        }
                                    }
                                  menu_tnormal ( sysgem.menu_tree, title, 1 );
                                  break;
          case WM_REDRAW        : if (( win = find_window ( xevent.msg [3], 0L )) != NULL )
                                    {
                                      DoRedraw ( win, (RECT *) &xevent.msg [4] );
                                    }
                                  break;
          case WM_TOPPED        : 
#ifndef EXTOB
                                  DelBlub ();
#endif
                                  TopWindow ( xevent.msg [3] );
                                  break;
          case WM_BACKDROP      :
          case WM_BOTTOMED      :
          case WM_UNTOPPED      : win = find_window ( xevent.msg [3], 0L );
                                  if ( win != NULL )
                                    {
                                      if ( win->log.txt != NULL )
                                        {
#ifndef EXTOB
                                          if ( win->log.cursor == 1 ) do_blink ();
#endif
                                        }
                                      if ( win->dial != NULL )
                                        {
                                          hide_cursor ( win->dial );
                                          SendMessage ( SG_UNTOP, win, NULL, NULL, 0, 0, 0, 0 );
                                        }
                                    }
                                  break;
          case WM_CLOSED        : win = forced ();
                                  if ( win != NULL )
                                    {
                                      if ( win->handle != xevent.msg [3] ) break;
                                    }
                                  win = find_window ( xevent.msg [3], 0L );
                                  if ( win != NULL )
                                    {
                                      if ( win->icon != 0 ) return;
                                      if (( xevent.kstate & K_ALT ) || ( xevent.kstate & K_CTRL ) || ( xevent.kstate & K_LSHIFT ) || ( xevent.kstate & K_RSHIFT ))
                                        {
#ifndef EXTOB
                                          if (( xevent.kstate & K_ALT ) && ( sysgem.iconify != ICONIFY_AES ))
                                            {
                                              if ( Iconify ( win->handle, &ic_minus )) break;
                                            }
                                          if (( xevent.kstate & K_CTRL ) && ( sysgem.iconify != ICONIFY_AES ))
                                            {
                                              if ( IconifyAllInOne ( win->handle, &ic_minus )) break;
                                            }
                                          if (( xevent.kstate & K_LSHIFT ) || ( xevent.kstate & K_RSHIFT ))
                                            {
                                              if ( sysgem.iconify == ICONIFY_ICFS )
                                                {
                                                  IconifyAll ();
                                                }
                                            }
                                          return;
#endif
                                        }
                                      else
                                        {
                                          CloseWindow ( win->handle );
                                        }
                                    }
                                  break;
#ifndef EXTOB
          case WM_FULLED        : win = find_window ( xevent.msg [3], 0L );
                                  if ( win != NULL ) FullWindow ( win );
                                  break;
          case WM_SIZED         : win = find_window ( xevent.msg [3], 0L );
                                  if ( win != NULL )
                                    {
                                      excl       ( win->flags, WIN_FULLED );
                                      MoveWindow ( win, (RECT *) &xevent.msg [4], SG_SIZED );
                                    }
                                  break;
          case WM_MOVED         : win = find_window ( xevent.msg [3], 0L );
                                  if ( win != NULL )
                                    {
                                      MoveWindow ( win, (RECT *) &xevent.msg [4], SG_MOVED );
                                      excl ( win->flags, WIN_FULLED );
                                    }
                                  break;
          case WM_ARROWED       : do_arrow ( xevent.msg [3], xevent.msg [4] );
                                  break;
          case WM_HSLID         : SetTheSlider ( xevent.msg [3], HSLIDE, xevent.msg [4] );
                                  break;
          case WM_VSLID         : SetTheSlider ( xevent.msg [3], VSLIDE, xevent.msg [4] );
                                  break;
          case VA_START         : if ( unknown != NULL )					/* [GS] */
                                    {
                                      unknown ( &xevent.msg [0] );
                                    }
                                  else
                                    {
                                      if ( _app == 0 )
                                        {
                                          goto openxacc;
                                        }
                                      SendStart ();
                                    }
                                  break;
          case WM_ICONIFY       : Iconify ( xevent.msg [3], (RECT *)( &xevent.msg [4] ));
                                  break;
          case WM_UNICONIFY     : UnIconify ( xevent.msg [3] );
                                  break;
          case WM_ALLICONIFY    : if ( iconified () != NULL ) break;
                                  IconifyAllInOne ( xevent.msg [3], (RECT *)( &xevent.msg [4] ));
                                  break;
          case VA_DRAGDROP      : if ( forced () != NULL ) break;
                                  memset ( &sysgem.drag, 0, sizeof ( DRAG_DROP ));
                                  sysgem.drag.gemini         = TRUE;
                                  sysgem.drag.x              = xevent.msg [4];
                                  sysgem.drag.y              = xevent.msg [5];
                                  sysgem.drag.state          = xevent.kstate;
                                  sysgem.drag.data           = (BYTE *)(*(LONG *) &xevent.msg [6] );
                                  win = find_window ( xevent.msg [3], 0L );
                                  sysgem.drag.obj            = is_object ( win, &sysgem.drag.id, xevent.msg [4], xevent.msg [5] );
                                  if ( win != NULL )
                                    {
                                      if ( win->flags & WIN_VISIBLE )
                                        {
                                          SendMessage ( SG_DRAGDROP, win, NULL, NULL, 0, 0, 0, 0 );
                                        }
                                    }
                                  break;
          case AP_DRAGDROP      : if ( forced () != NULL ) break;
                                  memset ( &sysgem.drag, 0, sizeof ( DRAG_DROP ));
                                  sysgem.drag.gemini         = FALSE;
                                  sysgem.drag.x              = xevent.msg [4];
                                  sysgem.drag.y              = xevent.msg [5];
                                  sysgem.drag.state          = xevent.msg [6];
                                  sysgem.drag.data           = NULL;
                                  if ( HandleDDProtocol ( &sysgem.drag, (BYTE *) &xevent.msg [7] ) == FALSE ) break;
                                  win = find_window ( xevent.msg [3], 0L );
                                  sysgem.drag.obj            = is_object ( win, &sysgem.drag.id, xevent.msg [4], xevent.msg [5] );
                                  if ( win != NULL )
                                    {
                                      if ( win->flags & WIN_VISIBLE )
                                        {
                                          SendMessage ( SG_DRAGDROP, win, NULL, NULL, 0, 0, 0, 0 );
                                        }
                                    }
                                  if ( sysgem.drag.data != NULL ) Dispose ( sysgem.drag.data );
                                  break;
          case AC_OPEN          : openxacc:
                                  GetsyColors ();
                                  MakeStartup ();
                                  incl ( xevent.event, MU_BUTTON );
                                  incl ( xevent.event, MU_KEYBD  );
                                  if ( sysgem.acc_open != NULL )
                                    {
                                      sysgem.acc_open ();
                                    }
                                  break;
          case AC_CLOSE         : while ( sysgem.window != NULL )
                                    {
                                      DestroyWindow ( sysgem.window, FALSE );
                                    }
                                  excl ( xevent.event, MU_BUTTON );
                                  excl ( xevent.event, MU_KEYBD  );
                                  SendToGemini ( AV_EXIT, sysgem.appl_id );
                                  if ( sysgem.acc_close != NULL )
                                    {
                                      sysgem.acc_close ();
                                    }
                                  break;
#endif
          case AP_TERM          : TerminateSysGem ();
                                  break;
          case CH_EXIT          : SendExit ( xevent.msg [3], xevent.msg [4] );
                                  break;
          case SC_CHANGED       : SendChanged ();
                                  break;
          case WM_SHADE         : win = find_window ( xevent.msg [3], 0L );
                                  if ( win != NULL )
                                    {
                                      excl ( win->flags, WIN_VISIBLE );
                                      if ( win->dial != NULL )
                                        {
                                          on_screen = FALSE;
                                          if ( sysgem.self_edit ) hide_cursor ( win->dial );
                                          win->dial->cursor = FALSE;
                                        }
                                      if ( win->icon == 0 ) SendMessage ( SG_INVISIBLE, win, NULL, NULL, 0, 0, 0, 0 );
                                    }
                                  break;
          case WM_UNSHADE       : win = find_window ( xevent.msg [3], 0L );
                                  if ( win != NULL )
                                    {
                                      if ( win->icon == 0 )
                                        {
                                          incl ( win->flags, WIN_VISIBLE );
                                          SendMessage ( SG_VISIBLE, win, NULL, NULL, 0, 0, 0, 0 );
                                        }
                                    }
                                  break;

          case VA_CONFONT       : if ( sysgem.allow_change )					/* [GS] */
                                    {
                                      sysgem.confont_hid = xevent.msg [3];
                                      sysgem.confont_hpt = xevent.msg [4];
                                    }
                                  break;

					case AV_SENDCLICK			: /* Mausklick empfangen: an interne Routinen weiterreichen */
																 xevent.x = xevent.msg [3];
																 xevent.y = xevent.msg [4];
																 xevent.clicks = xevent.msg [7];
																 xevent.state = xevent.msg [5];
																 event = event | MU_BUTTON;
																 break;
					case AV_SENDKEY      : /* Tastendruck empfangen: an interne Routine weiterreichen */
																 xevent.key = xevent.msg [4];
																 xevent.kstate = xevent.msg [3];
																 event = event | MU_KEYBD;
																 break;

#ifndef EXTOB
          case VA_FONTCHANGED   : if ( sysgem.allow_change )					/* [GS] */
                                    {
                                      sysgem.confont_hid = xevent.msg [5];
                                      sysgem.confont_hpt = xevent.msg [6];
                                      if ( sysgem.check_logfont )
                                        {
                                          win = sysgem.window;
                                          while ( win != NULL )
                                            {
                                              if ( win->log.txt != NULL )
                                                {
                                                  SetWindowFont ( win->id, sysgem.confont_hid, sysgem.confont_hpt );
                                                }
                                              win = win->next;
                                            }
                                        }
                                    }
                                  break;
          case GS_REQUEST	:
          case GS_REPLY		:
          case GS_COMMAND	:
          case GS_ACK		:
          case GS_QUIT		: if ( sysgem.gs_proc != NULL )
                                    {
                                      sgHandleGemScript ( &xevent.msg [0] );
                                    }
                                  else
                                    {
                                      if ( unknown != NULL ) unknown ( &xevent.msg [0] );
                                    }
                                  break;
#endif
          default               : if ( unknown != NULL )
                                    {
                                      unknown ( &xevent.msg [0] );
                                    }
                                  break;
        }
    }
  if ( event & MU_KEYBD )
    {
      if ( turn_back )
        {
          turn_back = MU_KEYBD;
          return;
        }
      DelKeyboard ();
      if ( sysgem.msg_shown || sysgem.fslx ) return;		/* [GS] */

      key = make_nkc ( xevent.key, xevent.kstate );
      if ( key == CTLALTSPACE )
        {
          win = find_window ( GetTopWindow (), 0L );
          if ( win != NULL )
            {
#ifndef EXTOB
              if ( win->icon != 0 )
                {
                  UnIconify ( win->handle );
                }
              else
                {
                  if ( forced () != win )
                    {
                      Iconify ( win->handle, &ic_minus );
                    }
                }
#endif
            }
          return;
        }
      if ( key == 0xce20 ) /* ctrl alt left-shift space */
        {
          win = find_window ( GetTopWindow (), 0L );
          if ( win != NULL )
            {
#ifndef EXTOB
              if ( win->icon == 0 ) IconifyAllInOne ( win->handle, &ic_minus );
#endif
            }
          return;
        }
      if ( userkeyp )
        {
          if ( userkeyp ( xevent.key ) == 0 )
            {
              HandleKey ( xevent.key, xevent.kstate );
            }
        }
      else
        {
          HandleKey ( xevent.key, xevent.kstate );
        }
    }
  if ( event & MU_BUTTON )
    {
      if ( turn_back )
        {
          if (( xevent.clicks == 1 ) && ( xevent.state == 1 ))
            {
              turn_back = MU_BUTTON;
              return;
            }
          goto do_timer;
        }
      HandleButton ( xevent.x, xevent.y, xevent.clicks, xevent.state );
    }

  do_timer:

  if ( event & MU_TIMER )
    {
      if ( turn_back == 0 ) HandleTimer ();
    }
  if ( userproc != NULL ) userproc ();
}

/* ------------------------------------------------------------------- */

VOID AllowFontChange ( BOOL allow )

{
  sysgem.allow_change = allow;
}

/* ------------------------------------------------------------------- */

VOID DispatchEvents ( VOID )

{
  HandleEvents ();
}

/* ------------------------------------------------------------------- */

VOID HandleSysGem ( VOID )

{
  graf_mouse ( ARROW, NULL );
  forever
    {
      HandleEvents ();
      if ( terminate ) break;
    }
}

/* ------------------------------------------------------------------- */

VOID SetMonoEditFrame ( BOOL paint )

{
  if ( paint )
    {
      sysgem.edit_mono = TRUE;
    }
  else
    {
      sysgem.edit_mono = FALSE;
    }
}

/* ------------------------------------------------------------------- */

VOID SetButton ( INT just )

{
  sysgem.button_just = just;
}

/* ------------------------------------------------------------------- */

VOID SetAccProc ( TPROC acc_open, TPROC acc_close )

{
  sysgem.acc_open  = acc_open;
  sysgem.acc_close = acc_close;
}

/* ------------------------------------------------------------------- */

VOID Set3DAlertColor ( INT icn1, INT icn2, INT icn3 )

{
  if ( icn1 >= 0 ) sysgem.icon_ausr = icn1;
  if ( icn2 >= 0 ) sysgem.icon_frag = icn2;
  if ( icn3 >= 0 ) sysgem.icon_stop = icn3;
}

/* ------------------------------------------------------------------- */

VOID SetAlertColor ( INT icn1, INT icn2, INT icn3 )

{
  if ( icn1 >= 0 ) sysgem.mono_ausr = icn1;
  if ( icn2 >= 0 ) sysgem.mono_frag = icn2;
  if ( icn3 >= 0 ) sysgem.mono_stop = icn3;
}

/* ------------------------------------------------------------------- */

VOID TellKeyStrokes ( BOOL tell )

{
  sysgem.tell = ( tell == TRUE );
}

/* ------------------------------------------------------------------- */

VOID DialPosXY ( BOOL center )

{
  sysgem.center = ( center == TRUE );
}

/* ------------------------------------------------------------------- */

VOID FrameTextColor ( INT color )

{
  sysgem.frametext_color = color;
}

/* ------------------------------------------------------------------- */

VOID ShortCutColor ( INT color )

{
  sysgem.shortcut_color = color;
}

/* ------------------------------------------------------------------- */

VOID UseRoundButtons ( BOOL use )

{
  sysgem.like_mac = ( use != FALSE );
}

/* ------------------------------------------------------------------- */

VOID WaitAfterClose ( BOOL wait )

{
  sysgem.wait = ( wait != FALSE );
}

/* ------------------------------------------------------------------- */

VOID SetAlertTitle ( BYTE *name )

{
  memset ( &sysgem.win_name, 0, sizeof ( sysgem.win_name ));
  strncpy ( sysgem.win_name, name, 40L );
}

/* ------------------------------------------------------------------- */

VOID SetProgramName ( BYTE *name )

{
  memset ( &sysgem.prg_name, 0, sizeof ( sysgem.prg_name ));
  memset ( &sysgem.win_name, 0, sizeof ( sysgem.win_name ));
  strncpy ( sysgem.prg_name, name, 40L );
  strncpy ( sysgem.win_name, name, 40L );
}

/* ------------------------------------------------------------------- */

INT SetSelColor ( INT color )

{
  INT   i;

  if ( sysgem.act_color < 16 ) return ( BLACK );
  i = sysgem.selb_color;
  if ( color >= 0 ) sysgem.selb_color = color;
  return ( i );
}

/* ------------------------------------------------------------------- */

INT SetSelTextColor ( INT color )

{
  INT   i;

  if ( sysgem.act_color < 16 ) return ( WHITE );
  i = sysgem.selt_color;
  if ( color >= 0 ) sysgem.selt_color = color;
  return ( i );
}

/* ------------------------------------------------------------------- */

VOID SetTextColor ( OBJECT *tree, INT obj, INT color )

{
  COLOR_INF     inf;
  TEDINFO       *ted;
  INT           typ;

  ted = (TEDINFO *) GetObjType ( tree, obj, &typ, NULL );
  if ( ted == NULL ) return;
  if (( typ == G_TEXT ) || ( typ == G_BOXTEXT ))
    {
      inf.p  = 0L;
      inf.p |= (LONG)( ted->te_color );
      inf.b.textcol = color;
      ted->te_color = (INT)( inf.p );
    }
}

/* ------------------------------------------------------------------- */
/* [GS]																																 */

VOID SetObjTextColor ( OBJECT *tree, INT obj, INT framecol, INT textcol,
                       INT textmode, INT fillpattern, INT interiorcol)

{
  COLOR_INF     inf;
  TEDINFO       *ted;
  INT           typ;

  ted = (TEDINFO *) GetObjType ( tree, obj, &typ, NULL );
  if ( ted == NULL ) return;
  if (( typ == G_TEXT ) || ( typ == G_BOXTEXT ))
    {
      inf.p  = 0L;
      inf.p |= (LONG)( ted->te_color );
      if ( framecol != -1 )
      	inf.b.framecol = framecol;
      if ( textcol != -1 )
      	inf.b.textcol = textcol;
      if ( textmode != -1 )
      	inf.b.textmode = textmode;
      if ( fillpattern != -1 )
      	inf.b.fillpattern = fillpattern;
      if ( interiorcol != -1 )
      	inf.b.interiorcol = interiorcol;
      ted->te_color = (INT)( inf.p );
    }
}

/* ------------------------------------------------------------------- */
/* [GS]																																 */

INT GetObjTextColor ( OBJECT *tree, INT obj, INT *framecol, INT *textcol,
                       INT *textmode, INT *fillpattern, INT *interiorcol)

{
  COLOR_INF     inf;
  TEDINFO       *ted;
  INT           typ;

  ted = (TEDINFO *) GetObjType ( tree, obj, &typ, NULL );
  if ( ted == NULL ) return FALSE;
  if (( typ == G_TEXT ) || ( typ == G_BOXTEXT ))
    {
      inf.p  = 0L;
      inf.p |= (LONG)( ted->te_color );
      if ( framecol != NULL )
      	 *framecol = inf.b.framecol;
      if ( textcol != NULL )
      	 *textcol = inf.b.textcol;
      if ( textmode != NULL )
      	 *textmode = inf.b.textmode;
      if ( fillpattern != NULL )
      	 *fillpattern = inf.b.fillpattern;
      if ( interiorcol != NULL )
      	 *interiorcol = inf.b.interiorcol;
      ted->te_color = (INT)( inf.p );
      return ( TRUE );
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */
/* [GS]																																 */

VOID SetObjColor ( OBJECT *tree, INT obj, INT color )

{
  COLOR_INF     inf;
  TEDINFO				*ted;
  bfobspec      *obspec;
  INT           typ;
  INT           ext;
  VOID          *q;
	USERB         *ub;

  if ( tree [obj].ob_type == G_USERDEF )
    {
      ub      = find_user ( tree, obj );
      if ( ub == NULL )
        {
          return;
        }
      typ     = ub->typ;
      ext     = ub->ext;
      q       = &ub->parm;
    }
  else
    {
      typ     = (INT)((BYTE)( tree [obj].ob_type ));
      ext     = tree [obj].ob_type >> 8;
      q       = &tree [obj].ob_spec.index;
    }
  inf.p  = 0L;
  switch ( typ )
  	{
  		case G_BOXCHAR :
  		case G_BOX		 : obspec = (bfobspec *) q;
  										 obspec->interiorcol = color;
  										 break;
  		case G_TEXT		 :
  		case G_BOXTEXT : ted = (TEDINFO *) q;
  										 inf.p |= (LONG)( ted->te_color );
      								 inf.b.textcol = color;
      								 ted->te_color = (INT)( inf.p );
      								 break;
      default				 : break;
    }
}

/* ------------------------------------------------------------------- */
/* [GS]																																 */

INT GetObjColor ( OBJECT *tree, INT obj )

{
  COLOR_INF     inf;
  TEDINFO				*ted;
  bfobspec      *obspec;
  INT						color;
  INT           typ;
  INT           ext;
  VOID          *q;
	USERB         *ub;

  if ( tree [obj].ob_type == G_USERDEF )
    {
      ub      = find_user ( tree, obj );
      if ( ub == NULL )
        {
          return ( -1 );
        }
      typ     = ub->typ;
      ext     = ub->ext;
      q       = &ub->parm;
    }
  else
    {
      typ     = (INT)((BYTE)( tree [obj].ob_type ));
      ext     = tree [obj].ob_type >> 8;
      q       = &tree [obj].ob_spec.index;
    }
  inf.p  = 0L;
  switch ( typ )
  	{
  		case G_BOXCHAR :
  		case G_BOX		 : obspec = (bfobspec *) q;
  										 color = obspec->interiorcol;
  										 break;
  		case G_TEXT		 :
  		case G_BOXTEXT : ted = (TEDINFO *) q;
  										 inf.p |= (LONG)( ted->te_color );
      								 color = inf.b.textcol;
      								 break;
      default				 : color = -1;
      							   break;
    }
  return ( color );
}

/* ------------------------------------------------------------------- */

VOID SetWinBackground ( LONG win_id, INT color )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      if ( sysgem.act_color >= 16 )
        {
          win->back = color;
        }
    }
}

/* ------------------------------------------------------------------- */

VOID UseOwnEditFields ( VOID )

{
  if ( sysgem.new_dial == FALSE ) sysgem.self_edit = TRUE;
}

/* ------------------------------------------------------------------- */

VOID SetReturn ( BOOL like_sysgem )

{
  sysgem.sg_return = ( like_sysgem != FALSE );
}

/* ------------------------------------------------------------------- */

VOID SetLanguage ( BOOL english )

{
  sysgem.english = ( english != FALSE );
}

/* ------------------------------------------------------------------- */

VOID SetUnknownEvent ( UPROC proc )

{
  unknown = proc;
}

/* ------------------------------------------------------------------- */

VOID GetParStruct ( PARAMETER *par )

{
  memcpy ( par, &sysgem.param, sizeof ( PARAMETER ));
}

/* ------------------------------------------------------------------- */

VOID CheckLogFont ( BOOL check )

{
  sysgem.check_logfont = ( check != FALSE );
}

/* ------------------------------------------------------------------- */

INT GetParam ( INT par )

{
  PARAMETER     *p;

  p = &sysgem.param;

  switch ( par )
    {
      case PAR_HANDLE    : return ( p->vdi_handle       );
      case PAR_CHARW     : return ( p->charw            );
      case PAR_CHARH     : return ( p->charh            );
      case PAR_BOXW      : return ( p->boxw             );
      case PAR_BOXH      : return ( p->boxh             );
      case PAR_APPLID    : return ( p->appl_id          );
      case PAR_XMAX      : return ( p->xmax             );
      case PAR_YMAX      : return ( p->ymax             );
      case PAR_DESKX     : return ( p->desktop.x        );
      case PAR_DESKY     : return ( p->desktop.y        );
      case PAR_DESKW     : return ( p->desktop.w        );
      case PAR_DESKH     : return ( p->desktop.h        );
      case PAR_BITPLANES : return ( p->bitplanes        );
      case PAR_MAXCOLOR  : return ( p->max_colors       );
      case PAR_ACTCOLOR  : return ( p->act_colors       );
      case PAR_COLOR     : return ( p->color_avail      );
      case PAR_ACCENTRY  : return ( p->acc_entry        );
      case PAR_MULTI     : return ( p->multitask        );
      case PAR_VAES      : return ( p->aes_version      );
      case PAR_VTOS      : return ( p->tos_version      );
      case PAR_VMAGX     : return ( p->magx             );
      case PAR_RMAGX     : return ( p->magx_rel         );
      case PAR_MINT      : return ( p->mint             );
      case PAR_WINX      : return ( p->winx             );
      case PAR_SEARCH    : return ( p->search           );
      case PAR_AGI       : return ( p->agi              );
      case PAR_ICFS      : return ( sysgem.icfs_version );
      case PAR_BACKCOL   : return ( sysgem.lwhite       );
      case PAR_ACTICOL   : return ( sysgem.lblack       );
      case PAR_SYSPT     : return ( sysgem.font_hpt     );
    }
  return ( 0 );
}

/* ------------------------------------------------------------------- */

VOID Init16System ( VOID )

{
  turn_back       = 0;
  xflags          = 0;
  xstate          = 0;
  draw_3d         = FALSE;
  user            = NULL;
  userproc        = NULL;
  unknown         = NULL;
  ic_minus.x      = -1;
  ic_minus.y      = -1;
  ic_minus.w      = -1;
  ic_minus.h      = -1;
  terminate       = FALSE;
  userkeyp	  = (USR_PROC) NULL;
#ifndef RSMOVL
  SetTopProc ((MPROC)( NULL ));
#endif
}

/* ------------------------------------------------------------------- */
