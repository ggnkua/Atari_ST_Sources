/************************************************************************
 * Datei: GEMDOS.h   	Zweck: 	Schnittstelle f�r nicht zu vermeidende	*
 *                              TOS-Abh�ngigkeiten                      *
 * Autor: RSB                                                           *
 * Datum: 05.05.90      Grund: 	SetDisk(), setzt aktuelles Laufwerk, da *
 *								setdisk() bei ATC 2.0 nicht l�uft		*
 ************************************************************************/

#define setdisk(l) SetDisk(l)

int SetDisk(int Laufwerk);
