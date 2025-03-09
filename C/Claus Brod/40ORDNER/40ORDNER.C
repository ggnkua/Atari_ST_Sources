#include <stdio.h>
#include <tos.h>
#include <ctype.h>
#include <string.h>

#define OUT(a)			Cconout(a)
#define CLS 			OUT(0x1b);OUT('E')
#define PRINTAT(a,b) OUT(0x1b);OUT('Y');OUT(b+32);OUT(a+32)

void immunisiere(char *);
void main(void);

/*	void immunisiere(char *)
**	Immunisiert ein Verzeichnis gegen den im Artikel beschriebenen
**	Fehler. Dazu muž die Routine mit dem passenden Pfad aufgerufen
**	werden. Will man das Wurzelverzeichnis von D: immunisieren,
**	lautet der Pfad "D:\".
*/	
void immunisiere(pfad)
char *pfad;
{
	Fsfirst(pfad, -1);
}

void main()
{
	char c, dname[8];
	int error,i = 0;
	DTA *mydta;
	
	CLS; puts("Immunisierung gegen den 40-Ordner-Fehler");
	puts("Idee: Prof. Dr. G. Bruhn, C-Version: Claus Brod");

	puts("\nZu testendes Laufwerk (C, D,...): ");
	dname[0] = toupper(Cnecin());
	
	strcpy(&dname[1], ":\\");
	
	puts("\nImmunisieren (j/n)?");
	do
		c = toupper(Cnecin());
	while ( (c != 'J') && (c != 'N') );
	
	if (c == 'J')
		immunisiere(dname);

	strcpy(&dname[3], "*.*");
	
	mydta = Fgetdta();
	do
	{
		error = Fsfirst(dname, -1);
		PRINTAT(10,12); printf("%d %d %s\n", i++, error, mydta->d_fname);
	} while ( (error >= 0) && (Bconstat(2) == 0) );
	
	printf("GEMDOS-Fehler %d\n", error);
}
