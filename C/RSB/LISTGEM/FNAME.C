/************************************************************************
 * Datei: FName.c    	Zweck: 	Dateinamen-Behandlung					*
 * Autor: RSB                                                           *
 * Datum 23.05.90       Grund: 	TOS-Magazin								*
 ************************************************************************/

#include <string.h>		/* strcpy(), strlen() */
#include <stddef.h>		/* NULL */
#include "FName.h"

/************************************************************************
 * lokale Konstanten													*  
 ************************************************************************/

const static char PKT 	= '.';
const static char DPKT 	= ':';
const static char NUL	= '\0';	/* ASCII-Code 0 */

/************************************************************************
 * Funktionen															*  
 *	Beschreibungen im Headerfile										*
 ************************************************************************/

void strsfn(const char *file, char *drive,char *path,char *node,char *ext)
{
	register int l = (int)strlen(file);
	register char *p;
	char s[128];
	
	strcpy(s,file);
	/* . von rechts her suchen */
	for (l--; l && *(s+l) != PKT; l--)
		; 
	if (ext != NULL) { /* Extension erwÅnscht */
		if (*(p = s+l) == PKT) {
			*p = NUL;
			strcpy(ext,p+1);
		}
		else {
			*ext = NUL;
			l = (int)strlen(s);
		}
	}
	/* \ oder : von rechts suchen */
	for (; l && *(p = s+l) != DPKT && *p != _SLASH; l--)
		;
	if (node != NULL) { /* Node erwÅnscht */
		if (*p == _SLASH) { /* \ wird gelîscht */
			*p = NUL; 
			strcpy(node,p+1);
			l--;
		}
		else if (*(p = s+l) == DPKT) { /* : wird nicht gelîscht */
			strcpy(node,p += 1); 
			*p = NUL;
		}
		else { /* kein path, kein drive */
			strcpy(node,s); 
			*s = NUL;
		}
	}
	/* : von links suchen */
	for (l = 0; *(p = s+l) && *p != DPKT; l++)
		;
	if (path != NULL) { /* Pfad erwÅnscht */
		if (*p == DPKT) { /* : wird nicht Åbernommen */
			strcpy(path,p += 1); 
			*p = NUL;
		}
		else {
			strcpy(path,s);
			*s = NUL;
		}
	}
	/* der Rest ist drive */
	if (drive != NULL) /* Laufwerk erwÅnscht */
		strcpy(drive,s);
	return;
}

void strmfp(char *name, char *path, char *node)
{
#	pragma warn -pia
	while (*name = *path++) 
	  name++;
#	pragma warn +pia
	if (*(name-1) != _SLASH)
		*name++ = _SLASH; 
	*name = '\0';  
	strcat(name,node);
}

int stcgfp(char *path, char *name)
{
	char *p;
	strcpy(path,name);
	if ((p = strrchr(path,_SLASH)) == NULL)
		if ((p = strrchr(path,':')) == NULL) {
			*path = '\0';
			return 0;
		}
	*++p = '\0';
	return (int) (p-path);
}
