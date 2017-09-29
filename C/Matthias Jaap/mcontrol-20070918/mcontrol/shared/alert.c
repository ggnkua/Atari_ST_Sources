/*----------------------------------------------------------------------------------------*
 * MControl                                                                               *
 *----------------------------------------------------------------------------------------*
 * Copyright (c) 2000 - 2002 Joachim Fornallaz                                            *
 *----------------------------------------------------------------------------------------*
 * This source file is subject to the BSD license.                                        *
 *----------------------------------------------------------------------------------------*
 * Authors: Joachim Fornallaz <jf@omnis.ch>                                               *
 *----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* global includes																								*/
/*----------------------------------------------------------------------------------------*/

#include	<mgx_dos.h>
#include	<cflib.h>
#include	<stdio.h>
#include	<string.h>
#include	<stdlib.h>
#include	<types2b.h>

/*----------------------------------------------------------------------------------------*/
/* local includes																									*/
/*----------------------------------------------------------------------------------------*/

#include	"strcmd.h"
#include	"..\rsrc.h"

/*----------------------------------------------------------------------------------------*/
/* global variables																								*/
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* functions																										*/
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* Variable Alert-Meldungen																					*/
/* Funktionsergebnis: GedrÅckter Button																	*/
/*----------------------------------------------------------------------------------------*/

static int16 do_note(int16 def, int16 undo, char *s)
{
	return do_walert(def, undo, s, ALERT_TITLE);
}

int16 note(int16 def, int16 undo, int16 index)
{
	return do_note(def, undo, fstring_addr[index]);
}

int16 alert(int16 def, int16 undo, char *string)
{
	return do_note(def, undo, string);
}

int16 inote(int16 def, int16 undo, int16 index, int16 val)
{
	char	buf[256];

	sprintf(buf, (uint8 *)fstring_addr[index], val);
	return do_note(def, undo, buf);
}

int16 i2note(int16 def, int16 undo, int16 index, int16 val1, int16 val2)
{
	char	buf[256];

	sprintf(buf, (uint8 *)fstring_addr[index], val1, val2);
	return do_note(def, undo, buf);
}

int16 snote(int16 def, int16 undo, int16 index, char *val)
{
	char	buf[256];
	char	val2[41];

	strncpy( val2, val, 40 );
	val2[40] = EOS;

	str_delchr( val2, '[' );
	str_delchr( val2, ']' );
	sprintf(buf, (char *)fstring_addr[index], val2);
	return do_note(def, undo, buf);
}

int16 s2note(int16 def, int16 undo, int16 index, char *val1, char *val2)
{
	char	buf[256];

	sprintf(buf, (char *)fstring_addr[index], val1, val2);
	return do_note(def, undo, buf);
}
