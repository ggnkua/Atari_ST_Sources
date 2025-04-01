/********************************************************************/
/*	EASYFSEL.H																											*/
/*																																	*/
/*	Include-Datei zu EASYFSEL.C.																		*/
/*																																	*/
/*	Revision: 6																											*/
/*	Datum   : 15.06.1992																						*/
/*  Autor   : Andreas Papula																				*/
/*																																	*/
/*	Copyright 1992 by MAXON Computer GmbH.													*/
/********************************************************************/

#include <aes.h>
#include <ext.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <portab.h>

/*------------------------------------------------------------------*/
/*	Funktionsprototypen.																						*/
/*------------------------------------------------------------------*/

BOOLEAN easy_fsel(BYTE *pfad, BYTE *dateiname, BYTE *text);
VOID build_filename(BYTE *dest, BYTE *pfad, BYTE *dateiname);
BOOLEAN exist(const BYTE *dateiname);
BYTE *get_akt_path(BYTE *path);
BOOLEAN get_cookie(BYTE *cookie_name, LONG *cookie_value);

/*----------------------- Ende der Datei. --------------------------*/