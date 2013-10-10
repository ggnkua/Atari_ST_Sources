/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - RSRC-Bibliothek kompatibel zu PureC							*/
/*																										*/
/*	(c) 1998-2003 by Martin ElsÑsser															*/
/******************************************************************************/

/* Wir brauchen die KompatibilitÑts-Funktionen, keine Makro-Definitionen! */
#define __COMPATIBLE_FKT__

/******************************************************************************/

#include <AES.H>
#include <String.H>
#include <StdArg.H>

/******************************************************************************/
/*																										*/
/* AES 110:	rsrc_load																			*/
/*																										*/
/******************************************************************************/

int16 rsrc_load( char *name )
{
	return mt_rsrc_load(name, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 111:	rsrc_free																			*/
/*																										*/
/******************************************************************************/

int16 rsrc_free( void )
{
	return mt_rsrc_free(_globl);
}

/******************************************************************************/
/*																										*/
/* AES 112:	rsrc_gaddr																			*/
/*																										*/
/******************************************************************************/

int16 rsrc_gaddr( const int16 type, const int16 id, void *addr )
{
	return mt_rsrc_gaddr(type, id, addr, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 113:	rsrc_saddr																			*/
/*																										*/
/******************************************************************************/

int16 rsrc_saddr( const int16 type, const int16 id, void *addr )
{
	return mt_rsrc_saddr(type, id, addr, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 114:	rsrc_obfix																			*/
/*																										*/
/******************************************************************************/

int16 rsrc_obfix( OBJECT *tree, const int16 obj )
{
	return mt_rsrc_obfix(tree, obj, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 115:	rsrc_rcfix																			*/
/*																										*/
/******************************************************************************/

int16 rsrc_rcfix( void *rc_header )
{
	return mt_rsrc_rcfix(rc_header, _globl);
}
