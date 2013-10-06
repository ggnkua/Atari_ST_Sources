/*******************************************************************************
	Bitmap view Copyright (c) 1995 by	Christophe BOYANIQUE
													http://www.raceme.org
													tof@raceme.org
********************************************************************************
	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the Free
	Software Foundation; either version 2 of the License, or any later version.
	This program is distributed in the hope that it will be useful, but WITHOUT
	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
	FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
	more details.
	You should have received a copy of the GNU General Public License along
	with this program; if not, write to the Free Software Foundation, Inc.,
	59 Temple Place - Suite 330, Boston, MA 02111, USA.
********************************************************************************
	TABULATION: 3 CARACTERES
*******************************************************************************/

#include		"PROTO.H"

static int	_fsel_check(void);
static int	_slctCheck(uint version);
static int	_slctMoreNames(int mode,int num,void *ptr);
static int	_slctFirst(DTA *mydta,int attr);
static int	_slctNext(DTA *mydta);
static int	_slctRelease(void);

/*******************************************************************************
	Multi FileSelect

	FileSelect ÇvoluÇ permettant de traiter un ensemble de fichiers en une
	seule passe.
	SÇlection des fichiers avec Selectric; ou Ö l'aide de joker.
	On appelle ensuite en boucle la fonction (*call) avec comme unique
	paramätre le nom complet du fichier.
	De plus; le joker # permet de remplacer un numÇro de fichier. Par exemple
	le masque TOTO####.TXT cherchera le fichier TOTO0001.TXT puis les suivants.
*******************************************************************************/
int _multifsel(char *pfname,char *pname,char *fname,char *ext,char *title,int cdecl (*call)(char *name))
{
	DTA	*dta;
	long	k,n,m;
	char	path[FILENAME_MAX];
	char	mask[20];
	char	*p;
	int	drvold=-1;
	int	is_slct_da,num=0;
	int	i,j=1,Break;

	p=glb.div.buf;
	is_slct_da=_slctMoreNames(1,512,glb.div.buf);
	i=_fselect(pfname,pname,fname,ext,title);
	if (i)
	{
		Break=FALSE;
		if (is_slct_da)
		{
			while (*p && j && !Break)
			{
				num+=1;
				strcpy(path,pname);
				fname[0]=0;
				while (*p && *p!=' ')
					strncat(fname,p++,1L);
				strcat(path,"\\");
				strcat(path,fname);
				p++;
				if (call)
					j=(*call)(path);
			}
		}
		if (num==0)
		{
			if (pname[1]==':')
			{
				drvold=Dgetdrv();
				Dsetdrv((int)pfname[0]-65);
			}

			p=strchr(pfname,'#');
			if (p)		/*	Gestion du masque #	*/
			{
				n=0L;
				while (*p++=='#')
					n+=1L;

				p=strchr(pfname,'#');					/*	pfname=C:\TOTO\TITI.EXT\TATA##O.JPG"	n=2	*/
				*p='\0';
				strcpy(path,pfname);						/*	path=C:\TOTO\TITI.EXT\TATA							*/
				sprintf(mask,"%%s%%0%lili%%s",n);	/*	mask='%s%02li%s'										*/
				m=1L;
				for (k=0;k<n;k++)
					m*=10L;
				for (k=0;k<m;k++)
				{
					sprintf(path,mask,pfname,k,&p[n]);
					if (!_fexist(path,NULL))
						k=m;
					else if (call)
						j=(*call)(path);
					if (!j)
						k=m;
				}
			}
			else
			if (!Fsfirst(pfname,FA_READONLY+FA_HIDDEN+FA_SYSTEM+FA_ARCHIVE))
			{
				dta=Fgetdta();
				do
				{
					strcpy(path,pname);
					strcat(path,"\\");
					strcat(path,dta->d_fname);
					if (call)
						j=(*call)(path);
				}	while (!Fsnext() && j && !Break);
			}
			if (drvold!=-1)
				Dsetdrv(drvold);
		}
		Break=FALSE;
	}
	return num;
}


/*******************************************************************************
	Test if a file exists
*******************************************************************************/
int _fexist(char *name,DTA *res)
{
	char	old_path[FILENAME_MAX];
	int	old_drv;
	int	ok=FALSE;
	DTA	*old,dta;

	old=Fgetdta();
	old_drv=Dgetdrv();
	Dgetpath(old_path,1+old_drv);
	if (name[1]==':')
		Dsetdrv((int)name[1]-65);
	Fsetdta(&dta);

	if (!Fsfirst(name,FA_READONLY+FA_HIDDEN+FA_SYSTEM+FA_ARCHIVE+FA_SUBDIR))
		ok=TRUE;
	if (ok && res)
		memcpy((void *)res,(void *)&dta,sizeof(DTA));
	Dsetdrv(old_drv);
	Dsetpath(old_path);
	Fsetdta(old);
	return ok;
}
/*******************************************************************************
	Test if a folder exists
*******************************************************************************/
int _dexist(char *name)
{
	char	old_path[FILENAME_MAX];
	char	myname[FILENAME_MAX];
	int	old_drv;
	int	i,ok=FALSE;
	DTA	*old,dta;

	old=Fgetdta();
	old_drv=Dgetdrv();
	Dgetpath(old_path,1+old_drv);
	if (name[1]==':')
		Dsetdrv((int)name[1]-65);
	Fsetdta(&dta);

	strcpy(myname,name);
	i=(int)strlen(myname);
	if (myname[i-1]=='\\')
		strcat(myname,"*.*");
	else
		strcat(myname,"\\*.*");
	if (!Fsfirst(myname,FA_READONLY+FA_HIDDEN+FA_SYSTEM+FA_ARCHIVE+FA_SUBDIR))
		ok=TRUE;
	Dsetdrv(old_drv);
	Dsetpath(old_path);
	Fsetdta(old);
	return ok;
}


/*******************************************************************************
	_fsel_check
********************************************************************************
	int _fsel_check(void)

	Funktion:	PrÅft nach, ob ein FSEL-Cookie vorhanden ist.

	Parameter:	keine

	Return:		TRUE	FSEL-Cookie vorhanden.
					FALSE	-----"----- nicht vorhanden.
*******************************************************************************/
static int _fsel_check(void)
{
	if (!glb.div.fsel)
		glb.div.fsel=(long *)_cookie('FSEL');
	return (glb.div.fsel ? TRUE : FALSE);
}


/*******************************************************************************
	_slctCheck
********************************************************************************
	int _slctCheck(uint version)

	Funktion:	Checkt, ob Selectric installiert ist und ob es
					die Mindest-Versionsnummer besitzt.

	Parameter:	version	EnhÑlt die zu prÅfende Versionsnummer
					(es wird ein '>='-Test gemacht!!)

	Return:		TRUE	Selectric ist installiert und die Versionsnummer ist ok.
					FALSE	Entweder nicht installiert oder zu
							niedrige Versionsnummer.
*******************************************************************************/
static int _slctCheck(uint version)
{
	if (_fsel_check())
	{
		slct=(SLCT_STR *)glb.div.fsel;
		if (slct->id != 'SLCT')
			slct = 0L;
	}
	if (slct && (slct->version >= version))
		return TRUE;
	else
		return FALSE;
}


/*******************************************************************************
	_fselect
********************************************************************************
	int _fselect(char *pfname,char *pname,char *fname,char *ext,char *title)

	Funktion:	Ruft den FileSelector in komfortabler Art und Weise auf. Dabei
					kann man alle Parts (Filename, Pathname, etc.) einzeln
					Åbergeben. Man kann aber auch Pathname und den kompletten Namen
					in `pfname' Åbergeben. Diese Routine sucht sich schon das, was
					ihr fehlt in bestimmten Grenzen selbst heraus.
					Diese Funktion unterstÅtzt den FSEL-Cookie und lÑuft
					auch ohne Selectric.

	Parameter:	*pfname	EnthÑlt abschlieûend den fertigen Pfad, den
								man sofort in ein `open' einsetzen kann.
					*pname	Der Startpfad (ohne Wildcards!).
					*fname	Ein voreingestellte Filenamen.
					*ext		Eine Extension.
					*title	Einen Boxtitel. Dabei wird a) die TOS-Version
								als auch der FSEL-Cookie ÅberprÅft.

	Return:		Der Button mit dem der Selector verlassen wurde.

	Bemerkung:	Beim Aufruf aus Accessories nicht vergessen ein
					BEG/END_UPDATE um diesen Aufruf zu legen!!!!!!!!!!
					Die meisten File-Selector Clones (incl. Selectric)
					machen das eh, nicht aber das Original ...
*******************************************************************************/
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

	wind_update(BEG_MCTRL);
	form_dial(FMD_START,0,0,0,0,glb.aes.desk.x,glb.aes.desk.y,glb.aes.desk.w,glb.aes.desk.h);
	if (_fsel_check() || (_vTOS() >= 0x0104))
		fsel_exinput(pname,fname,&but,title);
	else
		fsel_input(pname,fname,&but);
	form_dial(FMD_FINISH,0,0,0,0,glb.aes.desk.x,glb.aes.desk.y,glb.aes.desk.w,glb.aes.desk.h);
	_clearAesBuffer();
	wind_update(END_MCTRL);

	p=strrchr(pname,'\\');
	if (p)
		*p='\0';
	strcpy(pfname,pname);
	strcat(pfname,"\\");
	strcat(pfname,fname);
	return but;
}


/*******************************************************************************
	_slctExtPath
********************************************************************************
	int _slctExtPath(int ext_num,char *ext[],int path_num,char *paths[])

	Funktion:	Setzt benutzerdefinierte Extensions und Pfade, welche dann
					von Selectric benutzt werden. Die Extensions und Pfade mÅssen
					vor jedem Selectric-Aufruf gesetzt werden!

	Parameter:	ext_num		Anzahl der Extensions
					*ext[]		Die Extensions
					path_num		Anzahl Pfade
					*paths[]		Die Pfade

	Return:		TRUE			Selectric ist installiert
					FALSE			Selectric ist nicht installiert

	I have patched this function to allow setting either extension or path
		(Christophe Boyanique)
*******************************************************************************/
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


/*******************************************************************************
	_slctMoreNames
********************************************************************************
	int _slctMoreNames(int mode,int num,void *ptr)

	Funktion:	Initialisiert Selectric so, daû es weiû, daû mehr
					als ein Name zurÅckgegeben werden kann.

	Parameter:	mode	Gibt den Modus an. Z.Zt sind folgende Modi vorhanden:
								0	Files in Pointerlist zurÅckgeben.
								1	Files in einem einzigen String -"-.
					num	Anzahl der Namen die maximal zurÅckgegeben werden sollen.
					*ptr	Der Zeiger auf die entsprechende Struktur.

	Return:		TRUE	Selectric ist installiert
					FALSE	Selectric ist nicht installiert
*******************************************************************************/
static int _slctMoreNames(int mode,int num,void *ptr)
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


/*******************************************************************************
	_slctFirst
********************************************************************************
	int _slctFirst(DTA *mydta,int attr)

	Funktion:	Wurde das Communication-Byte auf CFG_FIRSTNEXT gesetzt, so
					kann man Åber diese Funktion den ersten selektierten Namen
					mit dem entsprechenden Attribut bekommen.

	Parameter:	mydta	Die DTA in der die Informationen gespeichert werden
							sollen.
					attr	Die Attribute (s.a. Fsfirst). Selectric verknÅpft beide
							Attribute mit UND und prÅft auf != 0.

	Return:		0		OK
					-49	keine weiteren Dateien
					-32	Funktion nicht vorhanden (Version < 1.02)
*******************************************************************************/
static int _slctFirst(DTA *mydta,int attr)
{
	if (_slctCheck(0x0102))
		return slct->get_first(mydta, attr);
	else
		return -32;
}


/*******************************************************************************
	_slctNext
********************************************************************************
	int _slctNext(DTA *mydta)

	Funktion:	Nachdem man mit _slctFirst() den ersten Namen zurÅckbekommt,
					kann man Åber diese Funktion weitere Namen erhalten.

	Parameter:	mydta	s.o.

	Return:		s.o.
*******************************************************************************/
static int _slctNext(DTA *mydta)
{
	if (_slctCheck(0x0102))
		return slct->get_next(mydta);
	else
		return -32;
}


/*******************************************************************************
	_slctRelease
********************************************************************************
	int _slctRelease(void)

	Funktion:	Gibt das Verzeichnis wieder frei (Wichtig!).

	Parameter:	keine

	Return:		TRUE	Verzeichnis konnte freigegeben werden.
					FALSE	Fehler
*******************************************************************************/
static int _slctRelease(void)
{
	if (_slctCheck(0x0102))
		return slct->release_dir();
	else
		return -32;
}
