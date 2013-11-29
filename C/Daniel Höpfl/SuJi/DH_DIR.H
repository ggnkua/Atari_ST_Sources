#ifndef DH_DHDIR_H
#define DH_DHDIR_H

#include <tos.h>
#include <string.h>

	/* ™ffne ein Verzeichnis zum Einlesen der darin enthaltenen Dateien/Ordner */
	/* pfad: Zu ”ffnender Pfad (incl. abschlieendem '\') */
	/* Rckgabe: internes Handle */
void *DHopendir(char *pfad);

	/* Hol n„chste Datei */
	/* info: Pointer auf Pointer auf DTA */
	/* 		 auch lange Namen werden in der DTA zurckgeliefert! */
	/* Rckgabe: 0, wenn OK, !0 sonst */
int DHxreaddir(void *handle,DTA **info);

	/* Schliee mit DHopendir ge”ffnetes Verzeichnis */
	/* vorher zurckgelieferte DTA-Adressen werden damit ungltig! */
void DHclosedir(void *handle);

#endif
