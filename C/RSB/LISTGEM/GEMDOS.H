/************************************************************************
 * Datei: GEMDOS.h   	Zweck: 	Schnittstelle fÅr nicht zu vermeidende	*
 *                              TOS-AbhÑngigkeiten                      *
 * Autor: RSB                                                           *
 * Datum: 05.05.90      Grund: 	SetDisk(), setzt aktuelles Laufwerk, da *
 *								setdisk() bei ATC 2.0 nicht lÑuft		*
 ************************************************************************/

#define setdisk(l) SetDisk(l)

int SetDisk(int Laufwerk);
