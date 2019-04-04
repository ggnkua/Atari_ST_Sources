/************************************************************************
 * Datei: MSDOS.h   	Zweck: 	Schnittstelle fÅr nicht zu vermeidende	*
 *                              BS-AbhÑngigkeiten                      	*
 * Autor: RSB                                                           *
 * Datum: 30.06.90      Grund: 	exec() fÅr MSDOS in Shel_write umsetzen	*
 * Datum: 01.07.90      Grund: 	alloc in dos_alloc() umwandelt, da 		*
 *								Fehler bei der Freispeicherverwaltung	*
 * -------------------------------------------------------------------- *
 * Speicherallozierung funktioniert nicht mit den TC Funktionen. Statt-	*
 * dessen mÅssen die Funktionen aus dem Toolkit verwendet werden.		*
 * DR verwendet historisch bedingt die Datei portab.h. Bei einer Fest-	*
 * legung auf ANSI-Compiler ist es vernÅnftiger, die vollen FÑhigkeiten *
 * des Sprachstandards bez. TypprÅfung auszunutzen. Im Inside GEM		*
 * ist eine erweiterte portab.h enthalten, die diese Anforderungen		*
 * weitgehend erfÅllt. Um unnîtigen Aufwand zu vermeiden, werden die 	*
 * Prototypen der benîtigten Funktionen hier explizit vereinbart.		*
 ************************************************************************/

void ReInstallDesktop(void); /* setzt Desktop.app als Shell */
int exec(char *head, char *tail, char *env, int *rc);
int execDOS(char *head, char *tail, char *env, int *rc);

#define calloc(i,n) 	dos_calloc(i,n)
#define malloc(n) 		dos_alloc(n)
#define free(p) 		dos_free(p)
#define realloc(p,n) 	dos_realloc(p,n)

void *dos_realloc(void *p, long n);
void *dos_calloc(long i, long n);
void *dos_alloc(long nbytes);
void dos_free(void *maddr);

