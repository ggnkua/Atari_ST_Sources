/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - APPL-Bibliothek kompatibel zu PureC							*/
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
/* Lokale Variablen																				*/
/*																										*/
/******************************************************************************/

GEMPARBLK _GemParBlk;
GlobalArray *_globl = (GlobalArray *)_GemParBlk.global;

/******************************************************************************/
/*																										*/
/* AES 10:	appl_init																			*/
/*																										*/
/******************************************************************************/

int16 appl_init( void )
{
	return mt_appl_init(_globl);
}

/******************************************************************************/
/*																										*/
/* AES 11:	appl_read																			*/
/*																										*/
/******************************************************************************/

int16 appl_read( const int16 rwid, const int16 length, void *pbuff )
{
	return mt_appl_read(rwid, length, pbuff, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 12:	appl_write																			*/
/*																										*/
/******************************************************************************/

int16 appl_write( const int16 rwid, const int16 length, void *pbuff )
{
	return mt_appl_write(rwid, length, pbuff, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 13:	appl_find																			*/
/*																										*/
/******************************************************************************/

int16 appl_find( char *pname )
{
	return mt_appl_find(pname, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 14:	appl_tplay																			*/
/*																										*/
/******************************************************************************/

int16 appl_tplay( APPLRECORD *tbuffer, const int16 tlength, const int16 tscale )
{
	return mt_appl_tplay(tbuffer, tlength, tscale, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 15:	appl_trecord																		*/
/*																										*/
/******************************************************************************/

int16 appl_trecord( APPLRECORD *tbuffer, const int16 tlength )
{
	return mt_appl_trecord(tbuffer, tlength, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 16:	appl_bvset																			*/
/*																										*/
/******************************************************************************/

int16 appl_bvset( const uint16 bvdisk, const uint16 bvhard )
{
	return mt_appl_bvset(bvdisk, bvhard, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 17:	appl_yield																			*/
/*																										*/
/******************************************************************************/

int16 appl_yield( void )
{
	return mt_appl_yield(_globl);
}

/******************************************************************************/
/*																										*/
/* AES 18:	appl_search																			*/
/*																										*/
/******************************************************************************/

int16 appl_search( const int16 mode, char *fname, int16 *type, int16 *ap_id )
{
	return mt_appl_search(mode, fname, type, ap_id, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 19:	appl_exit																			*/
/*																										*/
/******************************************************************************/

int16 appl_exit( void )
{
	return mt_appl_exit(_globl);
}

/******************************************************************************/
/*																										*/
/* AES 130:	appl_getinfo																		*/
/*																										*/
/******************************************************************************/

int16 appl_getinfo( const int16 type, int16 *out1, int16 *out2, int16 *out3, int16 *out4 )
{
	return mt_appl_getinfo(type, out1, out2, out3, out4, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 130:	appl_getinfo_str																	*/
/*																										*/
/******************************************************************************/

int16 appl_getinfo_str( const int16 type, char *str1, char *str2, char *str3, char *str4 )
{
	return mt_appl_getinfo_str(type, str1, str2, str3, str4, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 129:	appl_control																		*/
/*																										*/
/******************************************************************************/

int16 appl_control( const int16 ap_cid, const int16 ap_cwhat, void *ap_cout )
{
	return mt_appl_control(ap_cid, ap_cwhat, ap_cout, _globl);
}
