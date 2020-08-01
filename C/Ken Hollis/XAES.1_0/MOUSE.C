/********************************************************************
 *																1.20*
 *	XAES: New mouse driver and creation								*
 *	Code by Ken Hollis, GNU C Extensions by Sascha Blank			*
 *																	*
 *	Copyright (C) 1994, Bitgate Software							*
 *																	*
 *	The incredibly, revolutionary mouse routines.  These routines	*
 *	are about 20 times smarter than normal GEM's routines.  They	*
 *	don't flicker the mouse like normal GEM does.  What a concept.	*
 *																	*
 ********************************************************************/

#include <aes.h>
#include <stdio.h>
#include <string.h>
#ifdef __GNUC__
#include <stdarg.h>
#endif

#include "xaes.h"

#ifndef __MOUSE__
#define __MOUSE__
#endif

MICE mouseform;	/* forms */
int cur_mouse = 1, cur_mouse_form = BUSYBEE;

int init_mouse[37] =
{ 8, 8, 1, 0, 1, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF,
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0x7FFE, 0xFFFF,
  0xFFFF, 0xFFFF, 0x0000, 0x7FFE, 0x4002, 0x43C2, 0x47E2, 0x47E2,
  0x43C2, 0x4002, 0x43C2, 0x4002, 0x7FFE, 0x1008, 0x2D74, 0x4002,
  0x7FFE, 0x0000 };

int loadresource_mouse[37] =
{ 8, 8, 1, 0, 1, 0x3FFF, 0x7FFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF,
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF,
  0xFFFF, 0xFFFF, 0x0000, 0x1FFE, 0x28F2, 0x48F2, 0x48F2, 0x48F2,
  0x4FF2, 0x4002, 0x5DDA, 0x5512, 0x59D2, 0x5452, 0x55DA, 0x4002,
  0x7FFE, 0x0000 };

int lrmove_mouse[37] =
{ 8, 8, 1, 0, 1, 0x0000, 0x0000, 0x0000, 0x1E78, 0x3E7C, 0x7E7E,
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0x7E7E, 0x3E7C, 0x1E78, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0C30, 0x1C38,
  0x3C3C, 0x7FFE, 0x7FFE, 0x3C3C, 0x1C38, 0x0C30, 0x0000, 0x0000,
  0x0000, 0x0000 };

int lrsize_mouse[37] =
{ 8, 8, 1, 0, 1, 0x081F, 0x1C1F, 0x3E3F, 0x7F7F, 0xFFFF, 0x7FFF,
  0x3FFF, 0x1FFF, 0x0FFF, 0x1FFF, 0x3FFF, 0xFFFF, 0xFFFF, 0xFFFF,
  0xFFFF, 0xFFFF, 0x0000, 0x080E, 0x1C0E, 0x3E2E, 0x7F6E, 0x3FEE,
  0x1FEE, 0x0FEE, 0x07EE, 0x0FEE, 0x1FEE, 0x000E, 0x7FFE, 0x7FFE,
  0x7FFE, 0x0000 };

int llsize_mouse[37] =
{ 8, 8, 1, 0, 1, 0xF810, 0xF838, 0xFC7C, 0xFEFE, 0xFFFF, 0xFFFE,
  0xFFFC, 0xFFF8, 0xFFF0, 0xFFF8, 0xFFFC, 0xFFFF, 0xFFFF, 0xFFFF,
  0xFFFF, 0xFFFF, 0x0000, 0x7010, 0x7038, 0x747C, 0x76FE, 0x77FC,
  0x77F8, 0x77F0, 0x77E0, 0x77F0, 0x77F8, 0x7000, 0x7FFE, 0x7FFE,
  0x7FFE, 0x0000 };

int ulsize_mouse[37] =
{ 8, 8, 1, 0, 1, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFC,
  0xFFF8, 0xFFF0, 0xFFF8, 0xFFFC, 0xFFFE, 0xFFFF, 0xFEFE, 0xFC7C,
  0xF838, 0xF810, 0x0000, 0x7FFE, 0x7FFE, 0x7FFE, 0x7000, 0x77F8,
  0x77F0, 0x77E0, 0x77F0, 0x77F8, 0x77FC, 0x76FE, 0x747C, 0x7038,
  0x7010, 0x0000 };

int ursize_mouse[37] =
{ 8, 8, 1, 0, 1, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0x3FFF,
  0x1FFF, 0x0FFF, 0x1FFF, 0x3FFF, 0x7FFF, 0xFFFF, 0x7F7F, 0x3E3F,
  0x1C1F, 0x081F, 0x0000, 0x7FFE, 0x7FFE, 0x7FFE, 0x000E, 0x1FEE,
  0x0FEE, 0x07EE, 0x0FEE, 0x1FEE, 0x3FEE, 0x7F6E, 0x3E2E, 0x1C0E,
  0x080E, 0x0000 };

int udmove_mouse[37] =
{ 8, 8, 1, 0, 1, 0x0000, 0x03C0, 0x07E0, 0x0FF0, 0x1FF8, 0x1FF8,
  0x1FF8, 0x03C0, 0x03C0, 0x1FF8, 0x1FF8, 0x1FF8, 0x0FF0, 0x07E0,
  0x03C0, 0x0000, 0x0000, 0x0000, 0x0180, 0x03C0, 0x07E0, 0x0FF0,
  0x0180, 0x0180, 0x0180, 0x0180, 0x0FF0, 0x07E0, 0x03C0, 0x0180,
  0x0000, 0x0000 };

int help_mouse[37] =
{ 0, 0, 1, 0, 1, 0xC07E, 0xE0FF, 0xF0FF, 0xF8FF, 0xFCFF, 0xFE3F,
  0xFF3E, 0xFFBC, 0xFFFC, 0xFFFC, 0xFE3C, 0xEF3C, 0xCF00, 0x8780,
  0x0780, 0x0780, 0x0000, 0x403C, 0x607E, 0x7066, 0x780E, 0x7C1C,
  0x7E18, 0x7F18, 0x7F80, 0x7C18, 0x6C18, 0x4600, 0x0600, 0x0300,
  0x0300, 0x0000 };

int ibarhelp_mouse[37] =
{ 8, 8, 1, 0, 1, 0xFFFE, 0xFFFF, 0xFFFF, 0x3FFF, 0x1EFF, 0x1E3F,
  0x1E3E, 0x1E3C, 0x1E3C, 0x1E3C, 0x1E3C, 0x1E3C, 0x3F00, 0xFFC0,
  0xFFC0, 0xFFC0, 0x0000, 0x73BC, 0x1E7E, 0x0C66, 0x0C0E, 0x0C1C,
  0x0C18, 0x0C18, 0x0C00, 0x0C18, 0x0C18, 0x0C00, 0x0C00, 0x1E00,
  0x7380, 0x0000 };

int tsizer_mouse[37] =
{ 8, 8, 1, 0, 1, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0x0FF0,
  0x1FF8, 0x3FFC, 0x7FFE, 0xFFFF, 0xFFFF, 0xFFFF, 0x07E0, 0x07E0,
  0x07E0, 0x07E0, 0x0000, 0x7FFE, 0x7FFE, 0x7FFE, 0x0180, 0x03C0,
  0x07E0, 0x0FF0, 0x1FF8, 0x3FFC, 0x7FFE, 0x03C0, 0x03C0, 0x03C0,
  0x03C0, 0x0000 };

int lsizer_mouse[37] =
{ 8, 8, 1, 0, 1, 0xF870, 0xF8F0, 0xF9F0, 0xFBF0, 0xFFF0, 0xFFFF,
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFF0, 0xFBF0, 0xF9F0,
  0xF8F0, 0xF870, 0x0000, 0x7020, 0x7060, 0x70E0, 0x71E0, 0x73E0,
  0x77FE, 0x7FFE, 0x7FFE, 0x77FE, 0x73E0, 0x71E0, 0x70E0, 0x7060,
  0x7020, 0x0000 };

int rsizer_mouse[37] =
{ 8, 8, 1, 0, 1, 0x0E1F, 0x0F1F, 0x0F9F, 0x0FDF, 0x0FFF, 0xFFFF,
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0x0FFF, 0x0FDF, 0x0F9F,
  0x0F1F, 0x0E1F, 0x0000, 0x040E, 0x060E, 0x070E, 0x078E, 0x07CE,
  0x7FEE, 0x7FFE, 0x7FFE, 0x7FEE, 0x07CE, 0x078E, 0x070E, 0x060E,
  0x040E, 0x0000 };

int bsizer_mouse[37] =
{ 8, 8, 1, 0, 1, 0x07E0, 0x07E0, 0x07E0, 0x07E0, 0xFFFF, 0xFFFF,
  0xFFFF, 0x7FFE, 0x3FFC, 0x1FF8, 0x0FF0, 0xFFFF, 0xFFFF, 0xFFFF,
  0xFFFF, 0xFFFF, 0x0000, 0x03C0, 0x03C0, 0x03C0, 0x03C0, 0x7FFE,
  0x3FFC, 0x1FF8, 0x0FF0, 0x07E0, 0x03C0, 0x0180, 0x7FFE, 0x7FFE,
  0x7FFE, 0x0000 };

int mover_mouse[37] =
{ 8, 8, 1, 0, 1, 0x0380, 0x07C0, 0x0FE0, 0x0FE0, 0x37D8, 0x7FFC,
  0xFFFE, 0xFFFF, 0xFFFE, 0x7FFC, 0x37D8, 0x0FE0, 0x0FE0, 0x07C0,
  0x0380, 0x0100, 0x0100, 0x0380, 0x07C0, 0x0380, 0x0380, 0x2388,
  0x7FFC, 0xFFFE, 0x7FFC, 0x2388, 0x0380, 0x0380, 0x07C0, 0x0380,
  0x0100, 0x0000 };

int nomodal_mouse[37] =
{ 8, 8, 1, 0, 1, 0x03C0, 0x0FF0, 0x1FF8, 0x3FFC, 0x7FFE, 0x7FFE,
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0x7FFE, 0x7FFE, 0x3FFC, 0x1FF8,
  0x0FF0, 0x03C0, 0x0000, 0x03C0, 0x0FF0, 0x1FF8, 0x3E7C, 0x38FC,
  0x79FE, 0x73EE, 0x77CE, 0x7F9E, 0x3F1C, 0x3E7C, 0x1FF8, 0x0FF0,
  0x03C0, 0x0000 };

int nowindow_mouse[37] =
{ 8, 8, 1, 0, 1, 0x1008, 0x381C, 0x7C3E, 0xFE7F, 0x7FFE, 0x3FFC,
  0x1FF8, 0x0FF0, 0x0FF0, 0x1FF8, 0x3FFC, 0x7FFE, 0xFE7F, 0x7C3E,
  0x381C, 0x1008, 0x0000, 0x1008, 0x381C, 0x7C3E, 0x3E7C, 0x1FF8,
  0x0FF0, 0x07E0, 0x07E0, 0x0FF0, 0x1FF8, 0x3E7C, 0x7C3E, 0x381C,
  0x1008, 0x0000 };

/*
 *	Custom mouse routine
 *	by Ken Hollis
 *
 *	Returns: (0) on any type of failure
 *			 (-1) on successful custom mouse transaction
 *			 (any other number) to report the mouse result or a
 *								successful AES mouse transaction
 */
GLOBAL int WGrafMouse(int mo_sfield, ...)
{
	va_list	argptr;
	int	mform, store;

	switch(mo_sfield) {
		case GET_MOUSE:
			va_start(argptr, mo_sfield);
			mform = va_arg(argptr, int);
			store = va_arg(argptr, int);
			va_end(argptr);

			if (mouseform.forms[cur_mouse]!=0) {
				if (store) cur_mouse_form = (mouseform.forms[cur_mouse] == 0) ? cur_mouse_form : mouseform.forms[cur_mouse];
				return((mouseform.forms[cur_mouse] == 0) ? 0 : mouseform.forms[cur_mouse]);
			} else
				return(0);

		case SAVE_MOUSE:
			va_start(argptr, mo_sfield);
			mform = va_arg(argptr, int);
			store = va_arg(argptr, int);
			va_end(argptr);

			if (cur_mouse==16)
				return(0);
			else {
				if (store) cur_mouse_form = mform;
				mouseform.forms[cur_mouse++] = mform;
			}

			return(-1);

		case PREV_MOUSE:
			va_start(argptr, mo_sfield);
			mform = va_arg(argptr, int);
			store = va_arg(argptr, int);
			va_end(argptr);

			if (cur_mouse==1)
				return(0);
			else {
				if (store) cur_mouse_form = (mouseform.forms[(cur_mouse-1)] == 0) ? cur_mouse_form : mouseform.forms[(cur_mouse-1)];
				return((mouseform.forms[(cur_mouse-1)] == 0) ? 0 : mouseform.forms[(cur_mouse-1)]);
			}

		case NEXT_MOUSE:
			va_start(argptr, mo_sfield);
			mform = va_arg(argptr, int);
			store = va_arg(argptr, int);
			va_end(argptr);

			if (cur_mouse==16)
				return(0);
			else {
				if (store) cur_mouse_form = (mouseform.forms[(cur_mouse+1)] == 0) ? cur_mouse_form : mouseform.forms[(cur_mouse+1)];
				return((mouseform.forms[(cur_mouse+1)] == 0) ? 0 : mouseform.forms[(cur_mouse+1)]);
			}

		case FIRST_MOUSE:
			va_start(argptr, mo_sfield);
			mform = va_arg(argptr, int);
			store = va_arg(argptr, int);
			va_end(argptr);

			if (cur_mouse==1) {
				if (store) cur_mouse_form = (mouseform.forms[cur_mouse] == 0) ? cur_mouse_form : mouseform.forms[cur_mouse];
				return((mouseform.forms[cur_mouse] == 0) ? 0 : mouseform.forms[cur_mouse]);
			} else {
				if (store) cur_mouse_form = (mouseform.forms[1] == 0) ? cur_mouse_form : mouseform.forms[1];
				return((mouseform.forms[1] == 0) ? 0 : mouseform.forms[1]);
			}

		case LAST_MOUSE:
			{
				int pos = 1;

				va_start(argptr, mo_sfield);
				mform = va_arg(argptr, int);
				store = va_arg(argptr, int);
				va_end(argptr);

				do {
					if(mouseform.forms[pos]!=0) pos++;
					else {
						if (store) cur_mouse_form = mouseform.forms[pos];
						return(mouseform.forms[pos]);
					}
				} while(pos<16);

				return(0);
			}

		case CLEAR_MOUSE:
			{
				int pos = 1;

				do {
					mouseform.forms[pos++] = 0;
				} while(pos<16);

				return(-1);
			}

		case FIND_MOUSE:
			{
				int pos = 1;

				va_start(argptr, mo_sfield);
				mform = va_arg(argptr, int);
				store = va_arg(argptr, int);
				va_end(argptr);

				do {
					if(mouseform.forms[pos]==mform) {
						if (store) cur_mouse_form = mouseform.forms[pos];
						return(pos);
					} else pos++;
				} while(pos<16);

				return(0);
			}

		case NEWPOS_MOUSE:
			va_start(argptr, mo_sfield);
			mform = va_arg(argptr, int);
			va_end(argptr);

			cur_mouse = mform;

			return(-1);

		case TEXT_CRSR:
		case BUSYBEE:
		case POINT_HAND:
		case FLAT_HAND:
		case THIN_CROSS:
		case THICK_CROSS:
		case OUTLN_CROSS:
		case M_OFF:
		case M_ON:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				return(graf_mouse(mo_sfield, 0L));
			}
			break;

		case ARROW:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				helpmode = FALSE;
				if (helpmode)
					return(graf_mouse(USER_DEF, (MFORM *) help_mouse));
				else
					return(graf_mouse(mo_sfield, 0L));
			}
			break;

		case INIT_MOUSE:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				return(graf_mouse(USER_DEF, (MFORM *) init_mouse));
			}
			break;

		case LOAD_MOUSE:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				return(graf_mouse(USER_DEF, (MFORM *) loadresource_mouse));
			}
			break;

		case LRSLIDE_MOUSE:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				return(graf_mouse(USER_DEF, (MFORM *) lrmove_mouse));
			}
			break;

		case UDSLIDE_MOUSE:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				return(graf_mouse(USER_DEF, (MFORM *) udmove_mouse));
			}
			break;

		case URMOVE_MOUSE:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				return(graf_mouse(USER_DEF, (MFORM *) ursize_mouse));
			}
			break;

		case ULMOVE_MOUSE:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				return(graf_mouse(USER_DEF, (MFORM *) ulsize_mouse));
			}
			break;

		case LLMOVE_MOUSE:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				return(graf_mouse(USER_DEF, (MFORM *) llsize_mouse));
			}
			break;

		case LRMOVE_MOUSE:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				return(graf_mouse(USER_DEF, (MFORM *) lrsize_mouse));
			}
			break;

		case HELP_MOUSE:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				helpmode = TRUE;
				return(graf_mouse(USER_DEF, (MFORM *) help_mouse));
			}
			break;

		case IBARHELP_MOUSE:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				helpmode = TRUE;
				return(graf_mouse(USER_DEF, (MFORM *) ibarhelp_mouse));
			}
			break;

		case TSIZER_MOUSE:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				return(graf_mouse(USER_DEF, (MFORM *) tsizer_mouse));
			}
			break;

		case LSIZER_MOUSE:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				return(graf_mouse(USER_DEF, (MFORM *) lsizer_mouse));
			}
			break;

		case RSIZER_MOUSE:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				return(graf_mouse(USER_DEF, (MFORM *) rsizer_mouse));
			}
			break;

		case BSIZER_MOUSE:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				return(graf_mouse(USER_DEF, (MFORM *) bsizer_mouse));
			}
			break;

		case MOVER_MOUSE:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				return(graf_mouse(USER_DEF, (MFORM *) mover_mouse));
			}
			break;

		case NOMODAL_MOUSE:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				return(graf_mouse(USER_DEF, (MFORM *) nomodal_mouse));
			}
			break;

		case NOWINDOW_MOUSE:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				return(graf_mouse(USER_DEF, (MFORM *) nowindow_mouse));
			}
			break;

		default:
			if (cur_mouse_form != mo_sfield) {
				mouseform.forms[cur_mouse] = cur_mouse_form = mo_sfield;
				return(graf_mouse(mo_sfield, 0L));
			}
			break;
	}
	return(-1);
}