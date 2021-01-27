/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1995, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        "kernel.h"
#include        <stdio.h>
#include        <string.h>

/* ------------------------------------------------------------------- */

EXTERN  SYSGEM  sysgem;

/* ------------------------------------------------------------------- */

LOCAL INT   Wert;
LOCAL	LONG	spy_id;

/* ------------------------------------------------------------------- */

VOID SG_HandleConfigDebug ( VOID )

{
  BYTE		str	[500];
  INT k;
  INI_CFG	*i;
  
  BeginListUpdate ( spy_id );
  DelCompleteList ( spy_id );
  i = sysgem.pini;
  while ( i )
    {
    	if(Wert && i->len==2)														/* [GS]	*/
    	{																								/* [GS] */
      	memcpy ( &k, i->value, 2 );										/* [GS] */
	      sprintf ( str, " %-40.40s  %8ld  %8lx  %d", i->keyword, i->len, (LONG)( i->value ), k );	/* [GS] */
	    }																								/* [GS] */
    	else																						/* [GS] */
	      sprintf ( str, " %-40.40s  %8ld  %8lx  %-40.40s", i->keyword, i->len, (LONG)( i->value ), ((BYTE *) i->value ));
      AddToList ( spy_id, str );
      i = i->next;
    }
  EndListUpdate ( spy_id );
}

/* ------------------------------------------------------------------- */
/* [GS] 																															 */

VOID DebugConfigInt ( INT a )

{
	WINDOW  *win;
	
	Wert=a;
	win = find_window(-1,'DSpy');
	if ( win == NULL ) return;
	SG_HandleConfigDebug ();
}

/* ------------------------------------------------------------------- */

VOID DebugTheConfig ( INT x, INT y, INT w_char, INT h_char )

{
  spy_id 	= 'DSpy';
  
  if ( OpenTextWindow ( spy_id, "|List of Config-Values", " Keyword                                        Len   Address  Value", NULL, x, y, w_char, h_char, NULL, (APROC) NULL ) >= 0 )
    {
    	Wert=0;
      sysgem.spy_ini = SG_HandleConfigDebug;
      SG_HandleConfigDebug ();
    }
}

/* ------------------------------------------------------------------- */

/* ------------------------------------------------------------------- */
/* [GS]																																 */
/*--------------
BOOL DebugConfigInfo ( INT nr, BYTE *name, LONG *len, BYTE *Wert )

{
  BYTE		str	[500];
  INT k, i;
  INI_CFG	*config;
  
	i=0;
  config = sysgem.pini;
  while ( config )
    {
			if( i == nr)
				{    	
		    	if(Wert && config->len==2)										/* [GS]	*/
    				{																						/* [GS] */
			      	memcpy ( &k, config->value, 2 );					/* [GS] */
	      sprintf ( str, " %-40.40s  %8ld  %8lx  %d", i->keyword, i->len, (LONG)( i->value ), k );	/* [GS] */
	    }																								/* [GS] */
    	else																						/* [GS] */
	      sprintf ( str, " %-40.40s  %8ld  %8lx  %-40.40s", i->keyword, i->len, (LONG)( i->value ), ((BYTE *) i->value ));
      i = i->next;
    }
   return ( FALSE );
}

-------------*/
