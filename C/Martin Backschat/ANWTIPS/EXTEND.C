/*

                       The Extension Manager V1

                             (c) 1990 by

                          Martin Backschat

	Achtung: Dieses Programm (und der Quelltext) ist Bestandteil
             der Diskette zum TOS-Magazin 9/90.

	Compilierhinweise: Bei Turbo-C bitte Warning-Level auf 0!

*/

#include <stdio.h>
#include <string.h>
#include <tos.h>

#define	MAXINFO	100	/* 100 Eintr„ge im Extend.inf sollten reichen! */
struct INFO {
	char ext[3];
    int drive;
	char pfad[80];
	char name[14];
} *info[MAXINFO];
int infos = 0;	/* Anzahl der eingelesenen Eintr„ge */

FILE *inffile;	/* Stream der inf-Datei */
char filename[80];

main(int argc,char *argv[])
{
  char infname[20];
  char *ext;
  char *spvi;
  int i;

	if (argc != 2) {	/* Zuviele bzw. zuwenig Parameter ! */
		printf("\nFormat: extend.ttp datei");
		getch();
		exit(-1);
	}

	strupr(argv[1]);	/* in Grožbuchstaben wandeln! */
	if ((ext = strrchr(argv[1],'.')) != 0)	/* Besitzt Dateiname eine Endung? */
		ext++;	/* auf Endung positionieren */
	else	/* Datei besitzt keine Endung! */
		ext = "*";	/* auf alle F„lle *-Endung! */

	/* Dateiname aus Laufwerk,Pfad und Name zusammensetzen */
	filename[0] = Dgetdrv()+'A';
	filename[1] = filename[0];
	filename[2] = ':';
	Dgetpath(&filename[3],0);
	strcat(filename,"\\");
	strcat(filename,argv[1]);

	spvi = Super((char*)0l);
	infname[0] = *((int *)0x446)+'A';	/* Boot-Laufwerk ermitteln */
	Super(spvi);
	strcpy(&infname[1],":\\extend.inf");
	if ((inffile = fopen(infname,"r")) == 0) {	/* inf-Datei ”ffnen */
		printf("\nKann <extend.inf> auf dem Boot-Laufwerk nicht ”ffnen!\n");
		getch();
		exit(-1);
	}

	while (read_info())	/* Jetzt zeilenweise die Eintr„ge einlesen */
		if (!strcmp(ext,info[infos-1]->ext))	/* Hat aktueller Eintr„g die gewnschte Endung? */
			load(infos-1);	/* Ja, dann entspr. Programm laden */

	/* Keine entspr. Datei -> Eintrag mit Endung >>*<< suchen! */
	for (i = 0; i < infos; i++)
		if (!strcmp(info[i]->ext,"*"))
			load(i);

	printf("\nKann kein entsprechendes Programm finden!\n");
	getch();
	fclose(inffile);
	exit(-1);
}

/* Programm, das im Eintrag <pos> definiert ist, nachladen */
load(int pos)
{
  int i;

	for (i = 0; i < pos; i++)	/* Alle vorherigen Eintr„ge l”schen */
		free(info[i]);
	for (i = pos+1; i < infos; i++)	/* Alle folgenden Eintr„ge l”schen */
		free(info[i]);
	fclose(inffile);	/* inf-Datei schliežen */

	Dsetdrv(info[pos]->drive);
	Dsetpath(info[pos]->pfad);	/* Pfad und Laufwerk setzen */

	if (Pexec(0,info[pos]->name,filename,0l) < 0) {
		printf("\nKann Programm nicht ausfhren!\n");
		getch();
		exit(-1);
	}
	exit(0);
}

/* In der inf-Datei in die n„chste Zeile springen */
int skip_line()
{
	while (fgetc(inffile) != 0xa)	/* End of Line */
		if (feof(inffile))
			return 0;
}

/* Leerzeichen, Tab, Ret, und Newline berlesen */
int skip_space()
{
  int chr;

	while (isspace(chr = fgetc(inffile)))
		if (feof(inffile))
			return 0;
	return chr;
}

/* Aus inf-Datei einen String mit maximal <max> L„nge nach <str> lesen */
read_str(int max,char *str)
{
  int i,chr;

	i = 0;
	while (1) {
		chr = toupper(fgetc(inffile));	/* in Grožbuchstaben wandeln */
		if (feof(inffile))
			return 0;
		if (isspace(chr) || ++i > max)
			break;
		*str++ = chr;
	}
	*str = 0;
	return 1;
}

/* einen Eintrag lesen */
read_info()
{
  char ext[3];
  char name[80];
  char *ptr;
  int chr;
  int i;

	while (1) {
		if (!(chr = skip_space()))	/* Leerzeichen, Tab... berlesen */
			return 0;
	
		if (chr == '#') {	/* Kommentarzeile ? */
			if (!skip_line())
				return 0;
		}
		else {	/* ansonsten Eintrag einlesen */
			ungetc(chr,inffile);
			if (!read_str(3,ext))	/* Extension (max. 3 Buchstaben) */
				return 0;

			if (!(chr = skip_space()))
				return 0;

			ungetc(chr,inffile);
			if (!read_str(80,name))	/* Programmpfad und -name */
				return 0;

			break;
		}
	}

	/* Jetzt Speicherplatz fr Eintrag reservieren und zuordnen */
	if ( (info[infos] = malloc(sizeof(struct INFO))) == 0 ) {
		printf("\nZuwenig Speicherplatz!\n");
		getch();
		exit(-1);
	}
	strcpy(info[infos]->ext,ext);
	if (name[1] == ':')
		info[infos]->drive = toupper(name[0])-'A';
	if ((ptr = strrchr(name,'\\')) == 0) {
		printf("\n<%s> enth„lt keinen Programmnamen!",name);
		getch();
		free(info[infos]);
		return 1;
	}
	strcpy(info[infos]->name,ptr+1);
	*ptr = 0;
	strcpy(info[infos]->pfad,name);

	infos++;
	return 1;
}
