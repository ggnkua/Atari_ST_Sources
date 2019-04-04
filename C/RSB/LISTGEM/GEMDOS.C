/************************************************************************
 * Datei: GEMDOS.c   	Zweck: 	Schnittstelle fÅr nicht zu vermeidende	*
 *								TOS-AbhÑngigkeiten 						*
 * Autor: RSB                                                           *
 * Datum 05.05.90       Grund: 	SetDisk(), setzt aktuelles Laufwerk		*
 ************************************************************************/

/************************************************************************
 * Aktuelles Laufwerk setzen, setdisk() funktioniert bei Atari nicht	*
 ************************************************************************/

#include <tos.h>
#include "GEMDOS.h"

int SetDisk(int Laufwerk)
{
	return Dsetdrv(Laufwerk);
} /* SetDisk */
