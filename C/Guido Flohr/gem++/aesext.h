/* GEM++.
   Copyright (C) 1997 by Guido Flohr <gufl0000@stud.uni-sb.de>.

   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  */

/*  $Date$
 *  $Revision$
 *  $State$
 */

/*
 * New AES features.
 */

#ifndef _AESEXT_H
#define _AESEXT_H

#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif
#include <common.h>
#ifdef __cplusplus
}
#endif

#include <gemfast.h>

#include <system.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifndef HAVE_APPL_GETINFO
extern int appl_getinfo PARAM ((int type, int* out1, int* out2, int* out3, int* out4));
#endif

#ifndef HAVE_APPL_XGETINFO
extern int appl_getinfo PARAM ((int type, int* out1, int* out2, int* out3, int* out4));
#endif

#ifndef HAVE_GET_COOKIE
int get_cookie PARAM ((long int cookie, long int* value));
#endif

#ifdef __cplusplus
}
#endif

/* New messages.  */
#ifndef WM_NEWTOP
# define WM_NEWTOP 29
#endif
#ifndef WM_UNTOPPED
# define WM_UNTOPPED 30
#endif
#ifndef WM_ONTOP
# define WM_ONTOP 31
#endif
#ifndef WM_ICONIFY
# define WM_ICONIFY 34
#endif
#ifndef WM_UNICONIFY
# define WM_UNICONIFY 35
#endif
#ifndef WM_ALLICONIFY
# define WM_ALLICONIFY 36
#endif
#ifndef WM_TOOLBAR
# define WM_TOOLBAR 37
#endif
#ifndef AP_TERM
# define AP_TERM 50
#endif
#ifndef AP_TFAIL
# define AP_TFAIL 51
#endif
#ifndef AP_AESTERM
# define AP_AESTERM 52
#endif
#ifndef CT_KEY
# define CT_KEY 53
#endif
#ifndef AP_RESCHG
# define AP_RESCHG 57
#endif
#ifndef SHUT_COMPLETED
# define SHUT_COMPLETED 60
#endif
#ifndef RESCH_COMPLETED
# define RESCH_COMPLETED 61
#endif
#ifndef AP_DRAGDROP
# define AP_DRAGDROP 63
#endif
#ifndef SH_WDRAW
# define SH_WDRAW 72
#endif
#ifndef SC_CHANGED
# define SC_CHANGED 80
#endif
#ifndef CH_EXIT
# define CH_EXIT 90
#endif
#ifndef WM_M_BDROPPED
# define WM_M_BDROPPED 100
#endif
#ifndef SM_M_SPECIAL
# define SM_M_SPECIAL 101
#endif

/* New parameters for wind_get and wind_set.  */
#ifndef WF_KIND
# define WF_KIND 1
#endif
#ifndef WF_COLOR
# define WF_COLOR 18
#endif
#ifndef WF_DCOLOR
# define WF_DCOLOR 19
#endif
#ifndef WF_BEVENT
# define WF_BEVENT 24
#endif
#ifndef WF_BOTTOM
# define WF_BOTTOM 25
#endif
#ifndef WF_ICONIFY
# define WF_ICONIFY 26
#endif
#ifndef WF_UNICONIFY
# define WF_UNICONIFY 27
#endif
#ifndef WF_UNICONIFYXYWH
# define WF_UNICONIFYXYWH 28
#endif
#ifndef WF_TOOLBAR
# define WF_TOOLBAR 30
#endif

/* Window elements when calling wind_set (WF_COLOR, ...).  */
#ifndef W_BOX
# define W_BOX 0
#endif
#ifndef W_TITLE
# define W_TITLE 1
#endif
#ifndef W_CLOSER
# define W_CLOSER 2
#endif
#ifndef W_NAME
# define W_NAME 3
#endif
#ifndef W_MOVER
# define W_MOVER W_NAME
#endif
#ifndef W_FULLER
# define W_FULLER 4
#endif
#ifndef W_INFO
# define W_INFO 5
#endif
#ifndef W_DATA
# define W_DATA 6
#endif
#ifndef W_WORK
# define W_WORK 7
#endif
#ifndef W_VBAR
# define W_VBAR 9
#endif
#ifndef W_UPARROW
# define W_UPARROW 10
#endif
#ifndef W_VSLIDE
# define W_VSLIDE 12
#endif
#ifndef W_VELEV
# define W_VELEV 13
#endif
#ifndef W_HBAR
# define W_HBAR 14
#endif
#ifndef W_RTARROW
# define W_RTARROW 16
#endif
#ifndef W_HSLIDE
# define W_HSLIDE 17
#endif
#ifndef W_HELEV
# define W_HELEV 18
#endif
#ifndef W_BOTTOMER
# define W_BOTTOMER 20
#endif

/* VDI stuff.  */
/* VDI 18: Set polymarker type vsm_type.  */
#ifndef MT_DOTS
# define MT_DOTS 1
#endif
#ifndef MT_PLUS
# define MT_PLUS 2
#endif
#ifndef MT_ASTERISK
# define MT_ASTERISK 3
#endif
#ifndef MT_SQUARE
# define MT_SQUARE 4
#endif
#ifndef MT_DCROSS
# define MT_DCROSS 5
#endif
#ifndef MT_DIAMOND
# define MT_DIAMOND 6
#endif
/* VDI 39: Set graphic text alignment vst_alignment.  */
#ifndef TA_LEFT
# define TA_LEFT 0
#endif
#ifndef TA_CENTER
# define TA_CENTER 1
#endif
#ifndef TA_RIGHT
# define TA_RIGHT 2
#endif
#ifndef TA_BASELINE
# define TA_BASELINE 0
#endif
#ifndef TA_HALF
# define TA_HALF 1
#endif
#ifndef TA_ASCENT
# define TA_ASCENT 2
#endif
#ifndef TA_BOTTOM
# define TA_BOTTOM 3
#endif
#ifndef TA_DESCENT
# define TA_DESCENT 4
#endif
#ifndef TA_TOP
# define TA_TOP 5
#endif
/* VDI 106: Set graphic text special effects vst_effects.  */
#ifndef TF_NORMAL
# define TF_NORMAL 0x0000
#endif
#ifndef TF_THICKENED
# define TF_THICKENED 0x0001
#endif
#ifndef TF_LIGHTENED
# define TF_LIGHTENED 0x0002
#endif
#ifndef TF_SLANTED
# define TF_SLANTED 0x0004
#endif
#ifndef TF_UNDERLINED
# define TF_UNDERLINED 0x0008
#endif
#ifndef TF_OUTLINED
# define TF_OUTLINED 0x0010
#endif
#ifndef TF_SHADOWED
# define TF_SHADOWED 0x0020
#endif
/* VDI 108: Set polyline end styles vsl_ends.  */
#ifndef LE_SQUARED
# define LE_SQUARED 0
#endif
#ifndef LE_ARROWED
# define LE_ARROWED 1
#endif
#ifndef LE_ROUNDED
# define LE_ROUNDED 2
#endif
#endif /* not _AESEXT_H */
