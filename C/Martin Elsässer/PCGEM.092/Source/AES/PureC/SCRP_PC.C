/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - SCRP-Bibliothek kompatibel zu PureC							*/
/*																										*/
/*	(c) 1998-2003 by Martin ElsÑsser															*/
/******************************************************************************/

/* Wir brauchen die KompatibilitÑts-Funktionen, keine Makro-Definitionen! */
#define __COMPATIBLE_FKT__

/******************************************************************************/

#include <AES.H>
#include <String.H>

/******************************************************************************/
/*																										*/
/* AES 80:	scrp_read																			*/
/*																										*/
/******************************************************************************/

int16 scrp_read( char *pathname )
{
	return mt_scrp_read(pathname, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 81:	scrp_write																			*/
/*																										*/
/******************************************************************************/

int16 scrp_write( char *pathname )
{
	return mt_scrp_write(pathname, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 82:	scrp_clear																			*/
/*																										*/
/******************************************************************************/

int16 scrp_clear( void )
{
	return mt_scrp_clear(_globl);
}
