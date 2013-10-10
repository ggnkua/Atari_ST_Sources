/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - SHEL-Bibliothek kompatibel zu PureC							*/
/*																										*/
/*	(c) 1998-2000 by Martin ElsÑsser															*/
/******************************************************************************/

/* Wir brauchen die KompatibilitÑts-Funktionen, keine Makro-Definitionen! */
#define __COMPATIBLE_FKT__

/******************************************************************************/

#include <AES.H>
#include <String.H>
#include <StdArg.H>

/******************************************************************************/
/*																										*/
/* AES 120:	shel_read																			*/
/*																										*/
/******************************************************************************/

int16 shel_read( char *cmd, char *tail )
{
	return mt_shel_read(cmd, tail, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 121:	shel_write																			*/
/*																										*/
/******************************************************************************/

int16 shel_write( const int16 do_execute, const int16 is_graph, const int16 is_overlay,
				char *cmd, char *tail )
{
	return mt_shel_write(do_execute, is_graph, is_overlay, cmd, tail, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 122:	shel_get																				*/
/*																										*/
/******************************************************************************/

int16 shel_get( char *addr, const int16 len )
{
	return mt_shel_get(addr, len, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 123:	shel_put																				*/
/*																										*/
/******************************************************************************/

int16 shel_put( char *addr, const int16 len )
{
	return mt_shel_put(addr, len, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 124:	shel_find																			*/
/*																										*/
/******************************************************************************/

int16 shel_find( char *path )
{
	return mt_shel_find(path, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 125:	shel_envrn																			*/
/*																										*/
/******************************************************************************/

int16 shel_envrn( char **value, char *name )
{
	return mt_shel_envrn(value, name, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 126:	shel_rdef																			*/
/*																										*/
/******************************************************************************/

int16 shel_rdef( char *cmd, char *dir )
{
	return mt_shel_rdef(cmd, dir, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 127:	shel_wdef																			*/
/*																										*/
/******************************************************************************/

int16 shel_wdef( char *cmd, char *dir )
{
	return mt_shel_wdef(cmd, dir, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 128:	shel_help																			*/
/*																										*/
/******************************************************************************/

int16 shel_help( const int16 mode, char *file, char *key )
{
	return mt_shel_help(mode, file, key, _globl);
}
