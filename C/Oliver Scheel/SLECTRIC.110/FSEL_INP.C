/* ------------------------------------------------------------------------- */
/* ----- fsel_inp.c ----- Ein universeller fsel_(ex)input() Call ----------- */
/* ---------------------- und Routinen fÅr den Selectric Support ----------- */
/* ------------------------------------------------------------------------- */
/* ----------------------------------------- (c) 1992 by Oliver Scheel ----- */
/* ------------------------------------------------------------------------- */

#include <string.h>
#include <tos.h>
#include <vdi.h>

#include "fsel_inp.h"

#define NULL	((void *) 0l)
#define FALSE	0
#define TRUE	(!FALSE)

/* ------------------------------------------------------------------------- */

SLCT_STR	*slct = NULL;
long		*fsel = NULL;

SYSHDR		*sys_header;

/* ----- Cookie Jar -------------------------------------------------------- */

typedef struct
{
	long	id,
		*ptr;
} COOKJAR;

/* ------------------------------------------------------------------------- */
/* ----- get_cookie -------------------------------------------------------- */
/* ------------------------------------------------------------------------- */

long *get_cookie(long cookie)
{
	long	sav;
	COOKJAR	*cookiejar;
	int	i = 0;

	sav = Super((void *)1L);
	if(sav == 0L)
		sav = Super(0L);
	cookiejar = *((COOKJAR **)0x05a0l);
	sys_header = *((SYSHDR **)0x04f2L);	/* ... wenn wir schonmal
							super drauf sind */
	if(sav != -1L)
		Super((void *)sav);
	if(cookiejar)
	{
		while(cookiejar[i].id)
		{
			if(cookiejar[i].id == cookie)
				return(cookiejar[i].ptr);
			i++;
		}
	}
	return(0l);
}

/* ------------------------------------------------------------------------- */
/* ----- fsel_check -------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
**	int fsel_check(void)
**
**	Funktion:	PrÅft nach, ob ein FSEL-Cookie vorhanden ist.
**
**	Parameter:	keine
**
**	Return:		TRUE	FSEL-Cookie vorhanden.
**			FALSE	-----"----- nicht vorhanden.
**
** ------------------------------------------------------------------------- */

int fsel_check(void)
{
	if(!fsel)
		fsel = get_cookie('FSEL');
	return(fsel ? TRUE : FALSE);
}

/* ------------------------------------------------------------------------- */
/* ----- slct_check -------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
**	int slct_check(unsigned int version)
**
**	Funktion:	Checkt, ob Selectric installiert ist und ob es
**			die Mindest-Versionsnummer besitzt.
**
**	Parameter:	version	EnhÑlt die zu prÅfende Versionsnummer
**				(es wird ein '>='-Test gemacht!!)
**
**	Return:		TRUE	Selectric ist installiert und
**				die Versionsnummer ist ok.
**			FALSE	Entweder nicht installiert oder zu
**				niedrige Versionsnummer.
**
** ------------------------------------------------------------------------- */

int slct_check(unsigned int version)
{
	if(fsel_check())
	{
		slct = (SLCT_STR *)fsel;
		if(slct->id != 'SLCT')
			slct = 0L;
	}
	if(slct && (slct->version >= version))
		return(TRUE);
	else
		return(FALSE);
}

/* ------------------------------------------------------------------------- */
/* ----- file_select ------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
**	int file_select(char *pfname, char *pname, char *fname, char *ext,
**			char *title)
**
**	Funktion:	Ruft den FileSelector in komfortabler Art und Weise
**			auf. Dabei kann man alle Parts (Filename, Pathname,
**			etc.) einzeln Åbergeben. Man kann aber auch Pathname
**			und den kompletten Namen in `pfname' Åbergeben. Diese
**			Routine sucht sich schon das, was ihr fehlt in
**			bestimmten Grenzen selbst heraus.
**			Diese Funktion unterstÅtzt den FSEL-Cookie und lÑuft
**			auch ohne Selectric.
**
**	Parameter:	*pfname	EnthÑlt abschlieûend den fertigen Pfad, den
**				man sofort in ein `open' einsetzen kann.
**			*pname	Der Startpfad (ohne Wildcards!).
**			*fname	Ein voreingestellte Filenamen.
**			*ext	Eine Extension.
**			*title	Einen Boxtitel. Dabei wird a) die TOS-Version
**				als auch der FSEL-Cookie ÅberprÅft.
**
**	Return:		Der Button mit dem der Selector verlassen wurde.
**
**	Bemerkung:	Beim Aufruf aus Accessories nicht vergessen ein
**			BEG/END_UPDATE um diesen Aufruf zu legen!!!!!!!!!!
**			Die meisten File-Selector Clones (incl. Selectric)
**			machen das eh, nicht aber das Original ...
**
** ------------------------------------------------------------------------- */

int file_select(char *pfname, char *pname, char *fname, const char *ext, char *title)
{
	int	but;
	char	*p;

	if(!fname[0])
	{
		p = strrchr(pfname, '\\');
		if(p)
			strcpy(fname, p+1);
		else
			strcpy(fname, pfname);
	}
	if(!pname[0])
	{
		p = strrchr(pfname, '\\');
		if(p)
		{
			p[1] = '\0';
			strcpy(pname, pfname);
		}
	}
	else if(pname[strlen(pname)-1] != '\\')
		strcat(pname, "\\");
	strcat(pname, ext);

	if(fsel_check() || (sys_header->os_version >= 0x0104))
		fsel_exinput(pname, fname, &but, title);
	else
		fsel_input(pname, fname, &but);

	p = strrchr(pname, '\\');
	if(p)
		*p = '\0';
	strcpy(pfname, pname);
	strcat(pfname, "\\");
	strcat(pfname, fname);
	return(but);
}

/* ------------------------------------------------------------------------- */
/* ----- slct_extpath ------------------------------------------------------ */
/* ------------------------------------------------------------------------- */
/*
**	int slct_extpath(int ext_num, char *ext[], int path_num, char *paths[])
**
**	Funktion:	Setzt benutzerdefinierte Extensions und Pfade,
**			welche dann von Selectric benutzt werden. Die
**			Extensions und Pfade mÅssen vor jedem Selectric-
**			Aufruf gesetzt werden!
**
**	Parameter:	ext_num		Anzahl der Extensions
**			*ext[]		Die Extensions
**			path_num	Anzahl Pfade
**			*paths[]	Die Pfade
**
**	Return:		TRUE	Selectric ist installiert
**			FALSE	Selectric ist nicht installiert
**
** ------------------------------------------------------------------------- */

int slct_extpath(int ext_num, char *(*ext)[], int path_num, char *(*paths)[])
{
	if(slct_check(0x0100))
	{
		slct->num_ext = ext_num;
		slct->ext = ext;
		slct->num_paths = path_num;
		slct->paths = paths;
		return(TRUE);
	}
	else
		return(FALSE);
}
/* ------------------------------------------------------------------------- */
/* ----- slct_morenames ---------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
**	int slct_morenames(int mode, int num, void *ptr)
**
**	Funktion:	Initialisiert Selectric so, daû es weiû, daû mehr
**			als ein Name zurÅckgegeben werden kann.
**
**	Parameter:	mode	Gibt den Modus an. Z.Zt sind folgende Modi
**				vorhanden:
**				0	Files in Pointerlist zurÅckgeben.
**				1	Files in einem einzigen String -"-.
**			num	Anzahl der Namen die maximal zu-
**				rÅckgegeben werden sollen.
**			*ptr	Der Zeiger auf die entsprechende
**				Struktur.
**
**	Return:		TRUE	Selectric ist installiert
**			FALSE	Selectric ist nicht installiert
**
** ------------------------------------------------------------------------- */

int slct_morenames(int mode, int num, void *ptr)
{
	if(slct_check(0x0100))
	{
		slct->comm |= CMD_FILES_OUT;
		if(mode)
			slct->comm |= CFG_ONESTRING;
		slct->out_count = num;
		slct->out_ptr = ptr;
		return(TRUE);
	}
	else
		return(FALSE);
}

/* ------------------------------------------------------------------------- */
/* ----- slct_first -------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
**	int slct_first(DTA *mydta, int attr)
**
**	Funktion:	Wurde das Communication-Byte auf CFG_FIRSTNEXT
**			gesetzt, so kann man Åber diese Funktion den
**			ersten selektierten Namen mit dem entsprechenden
**			Attribut bekommen.
**
**	Parameter:	mydta	Die DTA in der die Informationen
**				gespeichert werden sollen.
**			attr	Die Attribute (s.a. Fsfirst). Selectric
**				verknÅpft beide Attribute mit UND und
**				prÅft auf != 0.
**
**	Return:		0	OK
**			-49	keine weiteren Dateien
**			-32	Funktion nicht vorhanden (Version < 1.02)
**
** ------------------------------------------------------------------------- */

int slct_first(DTA *mydta, int attr)
{
	if(slct_check(0x0102))
		return(slct->get_first(mydta, attr));
	else
		return(-32);
}

/* ------------------------------------------------------------------------- */
/* ----- slct_next --------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
**	int slct_next(DTA *mydta)
**
**	Funktion:	Nachdem man mit slct_first() den ersten Namen
**			zurÅckbekommt, kann man Åber diese Funktion weitere
**			Namen erhalten.
**
**	Parameter:	mydta	s.o.
**
**	Return:		s.o.
**
** ------------------------------------------------------------------------- */

int slct_next(DTA *mydta)
{
	if(slct_check(0x0102))
		return(slct->get_next(mydta));
	else
		return(-32);
}

/* ------------------------------------------------------------------------- */
/* ----- release_dir ------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
**	int release_dir(void)
**
**	Funktion:	Gibt das Verzeichnis wieder frei (Wichtig!).
**
**	Parameter:	keine
**
**	Return:		TRUE	Verzeichnis konnte freigegeben werden.
**			FALSE	Fehler
**
** ------------------------------------------------------------------------- */

int slct_release(void)
{
	if(slct_check(0x0102))
		return(slct->release_dir());
	else
		return(-32);
}
