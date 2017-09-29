/*----------------------------------------------------------------------------------------*
 * MControl                                                                               *
 *----------------------------------------------------------------------------------------*
 * Copyright (c) 2000 - 2002 Joachim Fornallaz                                            *
 *----------------------------------------------------------------------------------------*
 * This source file is subject to the BSD license.                                        *
 *----------------------------------------------------------------------------------------*
 * Authors: Joachim Fornallaz <jf@omnis.ch>                                               *
 *----------------------------------------------------------------------------------------*/

#ifndef _alert_h_
#define _alert_h_

#include	<types2b.h>

/*------------------------------------------------------------------*/
/* Funktionsprototypen															  */
/*------------------------------------------------------------------*/

static  int16	do_note(int16 def, int16 undo, uint8 *s);

int16		note( int16 def, int16 undo, int16 index );
int16		alert( int16 def, int16 undo, uint8 *string );
int16		inote( int16 def, int16 undo, int16 index, int16 val );
int16		i2note(int16 def, int16 undo, int16 index, int16 val1, int16 val2);
int16		snote( int16 def, int16 undo, int16 index, uint8 *val );
int16		s2note(int16 def, int16 undo, int16 index, char *val1, char *val2);

#endif
