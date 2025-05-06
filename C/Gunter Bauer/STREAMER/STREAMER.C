/* Archivierungsprogramm fuer ganze (Festplatten)-Pfade */
/* Åbersetzt mit Turbo - C v 2.03 dt. */
/* (c) Gunter Bauer , Acherstraûe 5 , 7500 Karlsruhe 51 */

/* Include-Dateien */

#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <ext.h>
#include <string.h>
#include <ctype.h>
#include <time.h>

/* Definitionen */

#define TRUE (-1)
#define FALSE 0

/* Variablentypendefinition */

typedef struct
{
	char	name[13];
	int		time, date;
}DIRECTORY;

/* Globale Variablen */

char out[100];
char ddest = 'A';
char dsrc  = 'C';
int supress = FALSE;
int print = FALSE;
struct ftime zeit;
unsigned int date;
				 
/* Prototypen */

int	read_file (char *fname, char **in, size_t *in_len);
int write_file (char *fname, char *out, size_t out_len);
int scan (char *path, char *maske, DIRECTORY **dir, int *index);
int set_path (char *pathname);
int make_path (char *pathname);
void path_separate (char *pname, char *dname);
int copy (DIRECTORY *dirsrc, int indsrc, DIRECTORY *dirdest, int indest);
int get_answer (void);
void output (void);
void printer (char *line);
void dest_drive (char *line);
void supress_msg (char *line);
void message (char *line);
void reset_drive (void);
void interprete (char *pointer, size_t laenge);
int main (void);

/*****************************************************
int	read_file (char *fname, char **in, size_t *in_len)

Liest eine Datei aus dem aktuellen Directory. 
Der Datumseintrag wird in 'zeit' gespeichert.

input 	: 	char *fname 	: der Dateiname

output	: 	char **in		: Zeiger auf Datei im Speicher
	  		size_t *in_len	: Dateigroesse

result	:	TRUE, wenn erfolgreich. 
			Es wurde Speicher fuer die Datei alloziert.
			FALSE, wenn - zu wenig Speicher fuer die ganze Datei
						- Lesefehler
			Es wurde kein Speicher alloziert.

*****************************************************/

int	read_file (char *fname, char **in, size_t *in_len)
{
	FILE *stream;

	if ((stream = fopen (fname, "rb")) == NULL)
	{
		sprintf (out, "Datei %s konnte nicht geîffnet werden !\n", fname);
		output ();
		return (FALSE);
	}
	*in_len = filelength (stream->Handle);
	getftime (stream->Handle, &zeit);
	if ((*in = (char *) malloc (*in_len)) == NULL)
	{
		sprintf (out, "Datei %s hat nicht genug Speicherplatz !\n", fname);
		output ();
		fclose (stream);
		free (*in);
		return (FALSE);
	}
	if (fread (*in, sizeof (**in), *in_len, stream) != *in_len)
	{
		sprintf(out, "Fehler beim Lesen von %s !\n",fname);
		output ();
		fclose (stream);
		free (*in);
		return (FALSE);
	}
	fclose (stream);
	return (TRUE);
}

/**********************************************************
int write_file (char *fname, char *out_buf, size_t out_len)

Schreibt eine Datei in das aktuelle Verzeichnis.
Der Datumseintrag wird auf 'zeit' gesetzt.
Der Speicher wird in jedem Fall wieder freigegeben.

input	:	char *fname		: der Dateiname
			char *out_buf	: Zeiger auf Speicherplatz der Datei
			size_t out_len	: Laenge der Datei im Speicher

output  :	-

result	:	TRUE wenn erfolgreich
			FALSE wenn Schreibfehler
**********************************************************/
			
int write_file (char *fname, char *out_buf, size_t out_len)
{
	FILE	*stream;
	
	if ((stream = fopen (fname, "wb")) == NULL)
	{
		sprintf(out, "Datei %s konnte nicht zum Schreiben geîffnet werden !\n", fname);
		output ();
		free (out_buf);
		return (FALSE);
	}
	if (fwrite (out_buf, sizeof (*out_buf), out_len, stream) != out_len)
	{
		sprintf(out, "Fehler beim Schreiben von %s !\n", fname);
		output ();
		fclose (stream);
		free (out);
		return (FALSE);
	}
	setftime (stream->Handle, &zeit);
	fclose (stream);
	free (out_buf);
	return (TRUE);
}

/**************************************************************
int scan (char *path, char *maske, DIRECTORY **dir, int *index)

Speichert den Inhalt eines Verzeichnisses.
Speicher wird selbststaendig alloziert.

input	:	char *path		: das zu untersuchende Verzeichnis 
			char *maske		: Dateimaske (mit Wildcards)
			DIRECTORY **dir : Zeiger auf Speicherstruktur
		
ouput	:	int *index		: Anzahl der gelesenen Dateien

result	:	TRUE wenn erfolgreich.
			Es wurde Speicher alloziert.
			FALSE wenn - Verzeichnis nicht gesetzt werden kann.
						index ist dann = -1.
					   - Verzeichnis leer ist.
					   	index ist dann = 0.
					   - nicht genug Speicher vorhanden ist.
			Es wurde kein Speicher alloziert.
**************************************************************/

int scan (char *path, char *maske, DIRECTORY **dir, int *index)
{
	int i = 0, flag;
	struct ffblk fblock;
	
	
	*index = -1;
	if (!set_path(path))
	{
		return (FALSE);
	}
	flag = findfirst (maske, &fblock, 0);
	while (!flag)
	{
		if ((fblock.ff_attrib & (FA_LABEL | FA_DIREC)) == 0)
			i++;
		flag = findnext (&fblock);
	}
	*index = i;
	if (i == 0) 
	{
		if (path[0] != ddest)
		{
			sprintf(out,"Verzeichnis %s mit Maske %s enthÑlt keine Dateien!\n", path, maske);
			output ();
		}
		return (FALSE);
	}
	if ((*dir = (DIRECTORY *) malloc (i * sizeof(DIRECTORY))) == NULL)
	{
		sprintf(out, "Kein Speicherplatz fÅr Directory %s !\n", path);
		output ();
		return (FALSE);
	}
	i = 0;
	flag = findfirst (maske, &fblock, 0);
	while (!flag)
	{
		if ((fblock.ff_attrib & (FA_LABEL | FA_DIREC)) == 0)
		{
			strcpy((*dir+i)->name, fblock.ff_name);
			(*dir+i)->time = fblock.ff_ftime;
			(*dir+i)->date = fblock.ff_fdate;
			i++;
		}
		flag = findnext (&fblock);
	}
	return (TRUE);
}

/****************************
int set_path (char *pathname)

setzt Verzeichnis (inclusive Laufwerk).

input	:	char *pathname : zu setzendes Verzeichnis.
output	:   -
result	:	TRUE wenn erfolgreich oder wenn es nicht das 
			Quelllaufwerk ist, so wird das Verzeichnis angelegt.
		  	FALSE wenn 
		  		- Laufwerk nicht angeschlossen ist.
		  		- Laufwerksbezeichnung ungÅltig ist.
		 		- Verzeichnis nicht existiert.
				- das Verzeichnis nicht angelegt werden kann.
****************************/

int set_path (char *pathname)
{
	if (*pathname<='P' && *pathname>='A')
		if ((Drvmap()) & ((long) (1<<(*pathname-'A'))))
			Dsetdrv((int)(*pathname-'A'));
		else
		{
			sprintf (out, "Laufwerk %c ist nicht angeschlossen !\n", *pathname);			
			output ();
			return (FALSE);
		}
	else
	{
		sprintf(out, "UngÅltige Laufwerksbezeichnung <%c> !\n",*pathname);
		output ();
		return (FALSE);
	}
	if (!Dsetpath(pathname+2))
		return (TRUE);
	else
	{
		sprintf (out, "Pfad %s ist nicht vorhanden !\n", pathname);			
		output ();
		if (pathname[0] == ddest)
		{
			if (make_path(&pathname[2]))
			{
				Dsetpath(pathname+2);	
				return (TRUE);
			}
			else
			{
				sprintf(out, "Fehler beim Anlegen von %s\n", pathname);
				output ();
			}
		}
		return (FALSE);
	}
}

/*************************
int make_path (char *work)

Legt ein Verzeichnis auf dem aktuellen Laufwerk an.

input	: Verzeichnisname 
output	: -
result	: TRUE wenn erfolgreich, sonst FALSE
*************************/

int make_path (char *work)
{
	int i, j = 1, len;
	
	sprintf(out, "Lege Pfad %s an\n", &work[-2]);
	output ();
	if (Dsetpath ("\\") != 0)
		return (FALSE);
	len = (int) strlen (work);
	for (i = 1; i < len; i++)
	{
		if (work[i] == '\\')
		{
			work[i] = '\0';
			if (Dsetpath (work) != 0)
			{
				if (Dcreate (&work[j]) != 0)
					return (FALSE);
				else	
					if (Dsetpath (work) != 0)
						return (FALSE);
			}
			work[i] = '\\';
			j = i + 1;
		}
	}
	return (TRUE);
}

/********************************************
void path_separate (char *pname, char *dname)

Trennt Verzeichnisname vom Dateiname (auch mit Wildcards)

input	:	char *pname	: komplette Pfadangabe (aber ohne Laufwerksbezeichnung)
output	:	char *pname : Verzeichnisname
			char *dname : Dateiname
result	: 	-
********************************************/

void path_separate (char *pname, char *dname)
{
	int i, j, cspn = 0; 
	char pathchr[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
					 "0123456789\\:ÅîÑöôé_*?.";
	
	do
	{
		cspn++;
		i = 0;
		while ((pname[cspn] != pathchr[i]) 
				&& (pathchr[i] != '\0'))
			i++;
	}		
	while (pname[cspn] == pathchr[i] && (pname[cspn] != '\0'));
	pname[cspn] = '\0';
	for (i = 0; pname[i] != '\0'; i++, j++)
	{
		if ((pname[i] == '\\') || (pname[i] == '.'))
		{
			j = 0;
			continue;
		}
		if ((j == 9) && pname[i] != '.')
		{
			for (j = ++cspn; j > i; j--)
				pname[j] = pname[j - 1];
			pname[i] = '.';
		}
	}
	for (i = 0; pname[i] != '\0'; i++)
		;
	while (pname[i] != '\\')
		i--;
	strcpy (dname, &pname[++i]);
	pname[i] = '\0';	
}

/***********************************************************************
int copy (DIRECTORY *dirsrc, int indsrc, DIRECTORY *dirdest, int indest)

Kopiert EintrÑge von *dirsrc, wenn sie nicht identisch in *dirdest
vorhanden sind. 

input	:	DIRECTORY *dirsrc : DateieintrÑge des Quellpfades
			int indsrc : Anzahl der EintrÑge
			DIRECTORY *dirdest : DateieintrÑge des Zielpfades
			int indest : Anzahl der EintrÑge
output	:	TRUE, wenn alle Operationen erfolgreich waren, 
			sonst FALSE
***********************************************************************/

int copy (DIRECTORY *dirsrc, int indsrc, DIRECTORY *dirdest, int indest)
{
	int i = -1, j;
	size_t len;
	char *buffer;
	int ret = TRUE;
	
	if (indsrc != 0)
	{
		do
		{
			i++;
			j = 0;
			while ((j < indest) &&
					strcmp((dirsrc+i)->name, (dirdest+j)->name))
				j++;
			if ((j >= indest) ||
				(((dirsrc+i)->time) != ((dirdest+j)->time)) ||
				(((dirsrc+i)->date) != ((dirdest+j)->date)))
			{
				Dsetdrv ((int)(dsrc-'A')); 
				if (!read_file ((dirsrc+i)->name, &buffer, &len))
					ret = FALSE;
				else
				{	
					Dsetdrv ((int) (ddest-'A'));
					if (!write_file ((dirsrc+i)->name, buffer, len))
						ret = FALSE;
					else
					{
						sprintf(out, "%13s ist kopiert\n", (dirsrc+i)->name);
						output ();
					}
				}				
			}
			else
			{
				if (!supress)
				{
					sprintf(out, "%13s ist aktuell\n", (dirsrc+i)->name);
					output ();
				}
			}
		}
		while (i < indsrc - 1);
		sprintf (out, "\n");
		output ();
	}
	return (ret);
}

/*********************************************
void interprete (char *pointer, size_t laenge)

Interpretiert ein Commandofile der LÑnge laenge.
Trennt dabei zwischen Optionen und KopierauftrÑgen.

input	:	char *pointer : Zeiger auf Zeile
			size_t laenge : LÑnge der Zeile
output	:	-
result	:	-
*********************************************/

void interprete (char *pointer, size_t laenge)
{
	DIRECTORY *dirsrc, *dirdest;
	char pname[128], dname[13];
	int spalte, zeile = 0;
	int indsrc, indest;

	while ((zeile) < laenge)
	{ 
		for (spalte = 0; ((*(pointer + spalte + zeile) != '\x0d') &&
		 	((zeile + spalte) <= laenge)); spalte++)
			;
		*(pointer + zeile + spalte) = '\0';
		strcpy (pname, pointer + zeile);
		strupr (pname);
		zeile += spalte + 2;
		if (isalpha (pname[0]))
		{
			path_separate (pname, dname);
			dsrc = pname[0];
			if (scan (pname, dname, &dirsrc, &indsrc))
			{
				pname[0] = ddest;
				if (scan (pname, dname, &dirdest, &indest) || 
				(indest == 0))
				{
					sprintf(out, "Untersuche %c%s%s :\n",dsrc, &pname[1], dname);
					output ();
					if (!copy (dirsrc, indsrc, dirdest, indest))
					{
						sprintf(out, "Achtung : Backup fehlerhaft!\n");
						output ();
					}
					if (indest > 0)
						free (dirdest);
				}
				free (dirsrc);
			}
		}
		if (pname[0] == '-')
			switch (pname[1])
			{
				case 'D': printer (pname+2); break;
				case 'Z': dest_drive (pname+2); break;
				case 'U': supress_msg (pname+2); break;
				case 'N': message (pname+2); break;
			}
	}
}

/*****************
void output (void)

Ausgaberoutine. Gibt entweder nur auf Bildschirm oder 
auf Bildschirm und Drucker den inhalt von out[] aus.

input	:	-
output	:	-
result	:	-

*****************/

void output (void)
{
	int i = 0;
	
	while (out[i] != '\0')
	{
		putch (out[i]);
		if (out[i] == '\n')
			putch ('\x0d');
		if (print)
		{
			while (Cprnos () == 0)
				;
			Cprnout ((int)out[i]);
		}
	i++;
	}
}

/************************
void printer (char *line)

Interpretiert die Option D. Schaltet entsprechend 
+ oder - den Drucker an oder aus.

input	:	char *line : Zeiger auf Zeichen nach "-d"
output	:	-
result	:	-

************************/

void printer (char *line)
{
	struct tm *heute;
	time_t secs;
	
	if (*line == '+')
	{
		while (Cprnos () == 0)
		{
			printf("Drucker nicht bereit ! Noch ein Versuch <j/n> ?\n");
			if (!get_answer())
				return;
		}
		print = TRUE;
		time (&secs);
		heute = localtime (&secs);
		strftime (out, (time_t) 99, "Backup vom %d.%m.%Y um %H Uhr %M\n\n", heute);
		output ();
	}
	else
	{
		print = FALSE;
	}
}

/***************************
void dest_drive (char *line)

Interpretiert die Option Z. Setzt Ziellaufwerk entsprechend.

input	:	char *line : Zeiger auf Zeichen nach -z
output	:	-
result	:	-

***************************/

void dest_drive (char *line)
{
	if (*line<='P' && *line>='A')
		if ((Drvmap()) & ((long) (1<<(*line-'A'))))
		{
			sprintf (out,"Ziellaufwerk ist <%c>\n", *line);
			output ();
			ddest = *line;
		}
		else
		{
			sprintf (out, "Laufwerk %c ist nicht angeschlossen !\n", *line);
			output ();
			return;
		}
	else
	{
		sprintf(out, "UngÅltige Laufwerksbezeichnung <%c> !\n",*line);
		output ();
		return;
	}
}

/********************
int get_answer (void)

Liest Eingabe solange bis j oder n und wertet aus.

input	:	-
output	: 	-
result	:	TRUE, wenn j, sonst FALSE

********************/

int get_answer (void)
{
	char quest;
	
	do
		quest = (char) toupper ((int) getch());
	while ((quest != 'J' ) && (quest != 'N'));
	return (quest == 'J');
}	

/****************************
void supress_msg (char *line)

Wertet option U aus. 

input	:	char *line : Zeiger auf Zeichen nach "-u"
output	:	-
result	:	-

****************************/

void supress_msg (char *line)
{
	if (*line == '+')
	{
		supress = TRUE;
		sprintf (out, "UnterdrÅcke \"ist aktuell\" !\n");
		output ();
	}
	else
	{
		supress = FALSE;
		sprintf (out, "UnterdrÅcke \"ist aktuell\" nicht !\n");
		output ();
	}
}	
/************************
void message (char *line)

Wertet Option n aus. Lîst einen "Disk-Reset" auf Ziellaufwerk aus.

input	:	char *line : Zeiger auf Zeichen nach "-n"
ouput	:	-
result	:	-

************************/

void message (char *line)
{
	sprintf (out, "%s\nWeiter mit Taste !\n", line);
	output ();
	getch ();
	reset_drive ();
}

/*********************
void reset_drive (void)

Disk-Reset auf dem Ziellaufwerk

input	:	-
output	:	-
result	:	-

**********************/

void reset_drive (void)
{
	char pfad[] = "A:\\";
	FILE *stream;

	pfad[0] = ddest;
	set_path (pfad);
	if ((stream = fopen ("ZZZZZZZZ.ZZZ", "rb")) != NULL)
	{
		fclose (stream);
	}
}

/**************
int main (void)

Hauptfunktion. Liest entweder Streamer.inf ein und lÑût die
Datei interpretieren, oder fordert den Benutzer zur Eingabe 
eines Commandofile-Namens auf. Die Datei muû im gleichen 
Verzeichnis wie das Programm stehen.

**************/

int main (void)
{
	size_t laenge;
	char *pointer;
	char filename[80];
	char save_path[128];
	int save_drive;
	
	printf("Festplatten - Backup (c) Gunther Bauer\n");
	printf("======================================\n");
	printf("Version vom %s um %s\n\n", __DATE__, __TIME__);
	if (read_file ("STREAMER.INF", &pointer, &laenge))
	{
		interprete (pointer, laenge);
		free (pointer);
		sprintf(out,"Fertig ! <RET>\n");
		output ();
		getch();
		return (0);
	}
	else
	{
		save_drive = Dgetdrv ();
		Dgetpath (save_path, (int)(save_drive + 1));
		do
		{
			printf ("Bitte geben Sie die Eingabedatei an <*> = Ende !\nSTREAMER> ");
			scanf ("%s\n", filename);
			strupr (filename);
			Dsetdrv (save_drive);
			Dsetpath (save_path);
			if ((filename[0] != '*') && read_file (filename, &pointer, &laenge))
			{
				interprete (pointer, laenge);
				free (pointer);
				reset_drive ();
			}
		}while (filename[0] != '*');
	}
	return (0);
}
