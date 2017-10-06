/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die (N)VDI-Funktionen - Allgemeines														*/
/*																										*/
/*	(c) 1998-2000 by Martin ElsÑsser															*/
/******************************************************************************/

#include <ACSVDI.H>
#include <ACSCook.H>

/******************************************************************************/
/*																										*/
/* Lokale Variablen																				*/
/*																										*/
/******************************************************************************/

#if defined(__COMPATIBLE__) && defined(__GNU_C__)
	#undef __COMPATIBLE__
#endif

/* Globaler Parameterblock fÅr "Dummy-Zwecke" */
VDIPARBLK _VDIParBlk;

/******************************************************************************/
/*																										*/
/* Funktion:	Umrechnen von fix31-Einheiten (Vektorfonts) in Pixel				*/
/*																										*/
/******************************************************************************/

INT16 fix31ToPixel( fix31 a )
{
	return (INT16)((a+32768l)>>16);
}
