/******************************************************************************/
/*	"Easy Gem" library Copyright (c)1994 by		Christophe BOYANIQUE				*/
/*																29 Rue RÇpublique					*/
/*																37230 FONDETTES					*/
/*																FRANCE								*/
/*						*small* mail at email adress:	cb@spia.freenix.fr				*/
/******************************************************************************/
/*	This program is free software; you can redistribute it and/or modify it		*/
/*	under the terms of the GNU General Public License as published by the Free	*/
/*	Software Foundation; either version 2 of the License, or any later version.*/
/*	This program is distributed in the hope that it will be useful, but WITHOUT*/
/*	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or		*/
/* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for	*/
/*	more details.																					*/
/*	You should have received a copy of the GNU General Public License along		*/
/*	with this program; if not, write to the Free Software Foundation, Inc.,		*/
/*	675 Mass Ave, Cambridge, MA 02139, USA.												*/
/******************************************************************************/
/*																										*/
/*		fsel_inp.c			Ein universeller fsel_(ex)input() Call						*/
/*								und Routinen fÅr den Selectric Support						*/
/*															(c) 1992 by Oliver Scheel			*/
/*																										*/
/*		linked to EGlib by Christophe Boyanique											*/
/*																										*/
/******************************************************************************/
/*	TABULATION: 3 CARACTERES																	*/
/******************************************************************************/

#include		"EG_MAIN.H"

/******************************************************************************/
/*	fsel_check																						*/
/******************************************************************************/
/*	int fsel_check(void)																			*/
/*																										*/
/*	Funktion:	PrÅft nach, ob ein FSEL-Cookie vorhanden ist.						*/
/*																										*/
/*	Parameter:	keine																				*/
/*																										*/
/*	Return:		TRUE	FSEL-Cookie vorhanden.												*/
/*					FALSE	-----"----- nicht vorhanden.										*/
/******************************************************************************/
int fsel_check(void)
{
	if (!fsel)
		fsel=(long *)_cookie('FSEL');
	return (fsel ? TRUE : FALSE);
}


/******************************************************************************/
/*	_slctCheck																						*/
/******************************************************************************/
/*	int _slctCheck(uint version)																*/
/*																										*/
/*	Funktion:	Checkt, ob Selectric installiert ist und ob es						*/
/*					die Mindest-Versionsnummer besitzt.										*/
/*																										*/
/*	Parameter:	version	EnhÑlt die zu prÅfende Versionsnummer						*/
/*					(es wird ein '>='-Test gemacht!!)										*/
/*																										*/
/*	Return:		TRUE	Selectric ist installiert und die Versionsnummer ist ok.	*/
/*					FALSE	Entweder nicht installiert oder zu								*/
/*							niedrige Versionsnummer.											*/
/******************************************************************************/
int _slctCheck(uint version)
{
	if (fsel_check())
	{
		slct=(SLCT_STR *)fsel;
		if (slct->id != 'SLCT')
			slct = 0L;
	}
	if (slct && (slct->version >= version))
		return TRUE;
	else
		return FALSE;
}


/******************************************************************************/
/*	_fselect																							*/
/******************************************************************************/
/*	int _fselect(char *pfname,char *pname,char *fname,char *ext,char *title)	*/
/*																										*/
/*	Funktion:	Ruft den FileSelector in komfortabler Art und Weise				*/
/*					auf. Dabei kann man alle Parts (Filename, Pathname,				*/
/*					etc.) einzeln Åbergeben. Man kann aber auch Pathname				*/
/*					und den kompletten Namen in `pfname' Åbergeben. Diese				*/
/*					Routine sucht sich schon das, was ihr fehlt in						*/
/*					bestimmten Grenzen selbst heraus.										*/
/*					Diese Funktion unterstÅtzt den FSEL-Cookie und lÑuft				*/
/*					auch ohne Selectric.															*/
/*																										*/
/*	Parameter:	*pfname	EnthÑlt abschlieûend den fertigen Pfad, den				*/
/*								man sofort in ein `open' einsetzen kann.					*/
/*					*pname	Der Startpfad (ohne Wildcards!).								*/
/*					*fname	Ein voreingestellte Filenamen.								*/
/*					*ext		Eine Extension.													*/
/*					*title	Einen Boxtitel. Dabei wird a) die TOS-Version			*/
/*								als auch der FSEL-Cookie ÅberprÅft.							*/
/*																										*/
/*	Return:		Der Button mit dem der Selector verlassen wurde.					*/
/*																										*/
/*	Bemerkung:	Beim Aufruf aus Accessories nicht vergessen ein						*/
/*					BEG/END_UPDATE um diesen Aufruf zu legen!!!!!!!!!!					*/
/*					Die meisten File-Selector Clones (incl. Selectric)					*/
/*					machen das eh, nicht aber das Original ...							*/
/******************************************************************************/
int _fselect(char *pfname,char *pname,char *fname,char *ext,char *title)
{
	int		but;
	char		*p;

	if (!fname[0])
	{
		p=strrchr(pfname,'\\');
		if (p)
			strcpy(fname,p+1);
		else
			strcpy(fname,pfname);
	}
	if (!pname[0])
	{
		p=strrchr(pfname,'\\');
		if (p)
		{
			p[1]='\0';
			strcpy(pname,pfname);
		}
	}
	else if (pname[strlen(pname)-1] != '\\')
		strcat(pname,"\\");
	strcat(pname,ext);

	if (fsel_check() || (_vTOS() >= 0x0104))
		fsel_exinput(pname,fname,&but,title);
	else
		fsel_input(pname,fname,&but);

	p=strrchr(pname,'\\');
	if (p)
		*p='\0';
	strcpy(pfname,pname);
	strcat(pfname,"\\");
	strcat(pfname,fname);
	return but;
}


/******************************************************************************/
/*	_slctExtPath																					*/
/******************************************************************************/
/*	int _slctExtPath(int ext_num,char *ext[],int path_num,char *paths[])			*/
/*																										*/
/*	Funktion:	Setzt benutzerdefinierte Extensions und Pfade, welche dann		*/
/*					von Selectric benutzt werden. Die Extensions und Pfade mÅssen	*/
/*					vor jedem Selectric-Aufruf gesetzt werden!							*/
/*																										*/
/*	Parameter:	ext_num		Anzahl der Extensions										*/
/*					*ext[]		Die Extensions													*/
/*					path_num		Anzahl Pfade													*/
/*					*paths[]		Die Pfade														*/
/*																										*/
/*	Return:		TRUE			Selectric ist installiert									*/
/*					FALSE			Selectric ist nicht installiert							*/
/*																										*/
/*	I have patched this function to allow setting either extension or path		*/
/*		(Christophe Boyanique																	*/
/******************************************************************************/
int _slctExtPath(int ext_num, char *(*ext)[], int path_num, char *(*paths)[])
{
	if(_slctCheck(0x0100))
	{
		if (ext_num>0)
		{
			slct->num_ext=ext_num;
			slct->ext=ext;
		}
		if (path_num>0)
		{
			slct->num_paths=path_num;
			slct->paths=paths;
		}
		return TRUE;
	}
	else
		return FALSE;
}


/******************************************************************************/
/*	_slctMoreNames																					*/
/******************************************************************************/
/*	int _slctMoreNames(int mode,int num,void *ptr)										*/
/*																										*/
/*	Funktion:	Initialisiert Selectric so, daû es weiû, daû mehr					*/
/*					als ein Name zurÅckgegeben werden kann.								*/
/*																										*/
/*	Parameter:	mode	Gibt den Modus an. Z.Zt sind folgende Modi vorhanden:		*/
/*								0	Files in Pointerlist zurÅckgeben.						*/
/*								1	Files in einem einzigen String -"-.						*/
/*					num	Anzahl der Namen die maximal zurÅckgegeben werden sollen.*/
/*					*ptr	Der Zeiger auf die entsprechende Struktur.					*/
/*																										*/
/*	Return:		TRUE	Selectric ist installiert											*/
/*					FALSE	Selectric ist nicht installiert									*/
/******************************************************************************/
int _slctMoreNames(int mode,int num,void *ptr)
{
	if (_slctCheck(0x0100))
	{
		slct->comm|=CMD_FILES_OUT;
		if (mode)
			slct->comm|=CFG_ONESTRING;
		slct->out_count=num;
		slct->out_ptr=ptr;
		return TRUE;
	}
	else
		return FALSE;
}


/******************************************************************************/
/*	_slctFirst																						*/
/******************************************************************************/
/*	int _slctFirst(DTA *mydta,int attr)														*/
/*																										*/
/*	Funktion:	Wurde das Communication-Byte auf CFG_FIRSTNEXT gesetzt, so		*/
/*					kann man Åber diese Funktion den ersten selektierten Namen		*/
/*					mit dem entsprechenden Attribut bekommen.								*/
/*																										*/
/*	Parameter:	mydta	Die DTA in der die Informationen gespeichert werden		*/
/*							sollen.																	*/
/*					attr	Die Attribute (s.a. Fsfirst). Selectric verknÅpft beide	*/
/*							Attribute mit UND und prÅft auf != 0.							*/
/*																										*/
/*	Return:		0		OK																			*/
/*					-49	keine weiteren Dateien												*/
/*					-32	Funktion nicht vorhanden (Version < 1.02)						*/
/******************************************************************************/
int _slctFirst(DTA *mydta,int attr)
{
	if (_slctCheck(0x0102))
		return slct->get_first(mydta, attr);
	else
		return -32;
}


/******************************************************************************/
/*	_slctNext																						*/
/******************************************************************************/
/*	int _slctNext(DTA *mydta)																	*/
/*																										*/
/*	Funktion:	Nachdem man mit _slctFirst() den ersten Namen zurÅckbekommt,	*/
/*					kann man Åber diese Funktion weitere Namen erhalten.				*/
/*																										*/
/*	Parameter:	mydta	s.o.																		*/
/*																										*/
/*	Return:		s.o.																				*/
/******************************************************************************/
int _slctNext(DTA *mydta)
{
	if (_slctCheck(0x0102))
		return slct->get_next(mydta);
	else
		return -32;
}


/******************************************************************************/
/*	_slctRelease																					*/
/******************************************************************************/
/*	int _slctRelease(void)																		*/
/*																										*/
/*	Funktion:	Gibt das Verzeichnis wieder frei (Wichtig!).							*/
/*																										*/
/*	Parameter:	keine																				*/
/*																										*/
/*	Return:		TRUE	Verzeichnis konnte freigegeben werden.							*/
/*					FALSE	Fehler																	*/
/******************************************************************************/
int _slctRelease(void)
{
	if (_slctCheck(0x0102))
		return slct->release_dir();
	else
		return -32;
}

/******************************************************************************/
/*	Test if a file/folder exists																*/
/******************************************************************************/
int _fexist(char *name,int type)
{
	int	ok=FALSE;
	DTA	*old,dta;

	old=Fgetdta();
	Fsetdta(&dta);

	if ( !Fsfirst(name,FA_READONLY+FA_HIDDEN+FA_SYSTEM+FA_ARCHIVE+FA_SUBDIR) )
		if ( type==0 || (type==FA_SUBDIR && dta.d_attrib&FA_SUBDIR) )
			ok=TRUE;
	Fsetdta(old);
	return ok;
}
