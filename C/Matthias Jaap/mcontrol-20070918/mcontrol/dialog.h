/*----------------------------------------------------------------------------------------*
 * MControl                                                                               *
 *----------------------------------------------------------------------------------------*
 * Copyright (c) 2000 - 2002 Joachim Fornallaz                                            *
 *----------------------------------------------------------------------------------------*
 * This source file is subject to the BSD license.                                        *
 *----------------------------------------------------------------------------------------*
 * Authors: Joachim Fornallaz <jf@omnis.ch>                                               *
 *----------------------------------------------------------------------------------------*/

#ifndef	_dialog_h_
#define	_dialog_h_

#include	<cflib.h>
#include	<types2b.h>

/*----------------------------------------------------------------------------------------*/
/* global variables																								*/
/*----------------------------------------------------------------------------------------*/

extern	WDIALOG	*wdial;

/*----------------------------------------------------------------------------------------*/
/* function prototypes																							*/
/*----------------------------------------------------------------------------------------*/

void	init_dial( void );
void	exit_dial( void );
void	maindial_open_cb(WDIALOG *wd);
int16	maindial_exit_cb(WDIALOG *wd, int16 obj);
void	sld_adjust( OBJECT *tree, int16 pos );
void	resize_main( WDIALOG *wd );

int16	key_sdial(int16 kreturn, int16 kstate);
void	wdial_deselect( WDIALOG *wd, int16 obj, int16 close );
int16	menu_context( int16 mx, int16 my );
int16 wdial_hover( int16 mx, int16 my, GRECT *r1, boolean *leave );

#endif