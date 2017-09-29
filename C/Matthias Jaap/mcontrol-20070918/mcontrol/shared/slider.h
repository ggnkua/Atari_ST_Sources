/*----------------------------------------------------------------------------------------*
 * MControl                                                                               *
 *----------------------------------------------------------------------------------------*
 * Copyright (c) 2000 - 2002 Joachim Fornallaz                                            *
 *----------------------------------------------------------------------------------------*
 * This source file is subject to the BSD license.                                        *
 *----------------------------------------------------------------------------------------*
 * Authors: Joachim Fornallaz <jf@omnis.ch>                                               *
 *----------------------------------------------------------------------------------------*/

#ifndef	_slider_h_
#define	_slider_h_

#include	<types2b.h>
#include <cflib.h>

/*----------------------------------------------------------------------------------------*/
/* struct definitions																							*/
/*----------------------------------------------------------------------------------------*/

typedef struct _sld
{
	WDIALOG	*wd;
	int16		up;
	int16		down;
	int16		back;
	int16		white;

	int16		pos_old;
	int16		pos_new;			/* 0 .. 1000 */
	int16		size_old;
	int16		size_new;		/* -1, 0 .. 1000 */
	int16		(*scroll) (WDIALOG *wd, int16 kind, int16 val);
/*	int16		(*scroll) (struct _sld *slider, int16 value); */
} SLD;

typedef int16 (* SLIDE_SCB )(WDIALOG *wd, int16 kind, int16 val);

#define	SCROLL_LIVE	0
#define	SCROLL_LINE	1
#define	SCROLL_PAGE	2
#define	SCROLL_HOME	3

/*----------------------------------------------------------------------------------------*/
/* global variables																								*/
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* function prototypes																							*/
/*----------------------------------------------------------------------------------------*/

void	wdset_state( WDIALOG *wd, int16 obj, int16 state, int16 set );

int16	sld_create( SLD *slider, WDIALOG *wd, int16 up, int16 down, int16 back, int16 white, SLIDE_SCB scroll );
int16	sld_event( SLD *slider, int16 obj );
int16	sld_redraw( SLD *slider );
void	sld_arrow( SLD *slider, int16 scroll, int16 val );
int16	sld_setsize( SLD *slider, int16 size );
int16	sld_getsize( SLD *slider );
int16	sld_setpos( SLD *slider, int16 pos );
int16	sld_getpos( SLD *slider );
int16	objc_scroll( OBJECT *tree, int16 vdihandle, int16 obj, int16 whdl, int32 yscroll, int16 xscroll, int16 ydraw );


#endif