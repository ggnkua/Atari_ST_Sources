/*----------------------------------------------------------------------------------------*
 * MControl                                                                               *
 *----------------------------------------------------------------------------------------*
 * Copyright (c) 2000 - 2002 Joachim Fornallaz                                            *
 *----------------------------------------------------------------------------------------*
 * This source file is subject to the BSD license.                                        *
 *----------------------------------------------------------------------------------------*
 * Authors: Joachim Fornallaz <jf@omnis.ch>                                               *
 *----------------------------------------------------------------------------------------*/

#ifndef _appcomm_h_
#define _appcomm_h_

#include	<types2b.h>

/*----------------------------------------------------------------------------------------*/
/* global variables																								*/
/*----------------------------------------------------------------------------------------*/

extern	int16		msgbuff[];

/*----------------------------------------------------------------------------------------*/
/* function prototypes																							*/
/*----------------------------------------------------------------------------------------*/

void		init_comm( void );
void		exit_comm( void );
int16		av_server( void );
void		av_xwind( uint8 *path );
void		av_path_update( uint8 *path );
void		av_startprog( uint8 *path, uint8 *cmd );
void		bgem_askfont( void );
boolean	bgem_font( int16 *FontID, int16 *FontPt );
boolean	bgem_show( uint8* bubble_text, int16 mx, int16 my );
boolean	va_progstart( int16 *code );
boolean	open_hyp( uint8 *file, uint8 *arg );
boolean	make_name( uint8 *longname, uint8 *shortname );
void		open_url( uint8 *url );

#endif
