/***********************************************************************/
/*
 * HANDLER.C:
 * ----------
 *
 * > Funktionsprimitiven des Players
 * > Multiplay Listenverwaltung
 * > Read & Save Parameters
 *
 *
 * last modified: 24-Dec-1992
 */
/***********************************************************************/

/* -------------------------------------------------------------------- */
/*	  Include Header-files												*/
/* -------------------------------------------------------------------- */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>

#include "PROTO.H"
#include "GEMUTIL.H"
#include "PAUL_RSC.H"
#include "PAUL_RSC.RH"

#define EINVFN -32L
#define ENMFIL -49L

#define	BIGBLOCK	(1000L)
#define	EVEN(addr)	(((addr)+1L) & -2L)

/* prototype from PATMAT.C */
int patmat(char *raw,char *pat);


/* -------------------------------------------------------------------- */
/*	  Variables 														*/
/* -------------------------------------------------------------------- */

extern int		repeat; 			/* global repeat? */
extern int		shuffle;			/* random play */
extern int		transpose;			/* tone */
extern int		detune; 			/* pitch */
extern int		wi_handle;			/* current window handle */
int				registered;			/* dummy */

PRIVATE char	infpath[128]=INFOFILE;
									/* info file */
char			modpath[256]=AUTOMOD_PATH,
									/* pfadangabe */
				modfile[64]=MOD_MASK;
									/* dateiname */

PRIVATE filename_block_t *listmemory;		/* Zeiger auf gemerkte Namen */

/* -------------------------------------------------------------------- */
/*	  Code																*/
/* -------------------------------------------------------------------- */

/* read_dir:
 * in 'path' angegebenes Directory lesen, unter Zuhilfename der mit
 * 'mask' angegebenen Auswahlmaske.
 * return: TRUE on success
 */
int read_dir( char *path, char *mask )
{
	long 	error;
	DTA 	dta, *old_dta;
	char	longbuf[256+64];

	if (path[1]==':')			/* pfad korrekt setzen */
	{
		Dsetdrv(path[0]-'A');
		error = Dsetpath(&path[2]);
	}
	else
		error = Dsetpath(path);

	if (error<0)	return FALSE;		/* Fehler melden */

#if 0

	long	dirhandle;

	/* try new functions first... */
	Dgetpath(longbuf, 0);
	dirhandle = Dopendir(longbuf, 1);
printf("Path=%s, Dirhandle=$%lX\n",longbuf,dirhandle);

	if (dirhandle==EINVFN) goto oldfilesystem;
	if (dirhandle<0) return FALSE;
	do {
		error = Dreaddir(256+64-1, dirhandle, longbuf);

puts (longbuf);

		if (error==E_OK)
		{
			if (patmat(longbuf+4, mask)==1)
				add_modfile_to_list(longbuf+4);
		}
	} while (error!=ENMFIL);
	Dclosedir(dirhandle);
	return TRUE;

	/* Now, that was much cleaner, wasn't it? */

oldfilesystem:
#endif

	old_dta = Fgetdta();			/* wegen 'anderem' User !? */
	Fsetdta(&dta);					/* eigene DTA setzen */
	error = Fsfirst( mask, FA_READONLY | FA_HIDDEN | FA_ARCHIVE );
	if (error==0)
	{
		longbuf[0]=0;
		do {
			trim_path(longbuf, NULL);
			strncat(longbuf, dta.d_fname, 13);
			/* puts(longbuf); */
			add_modfile_to_list(longbuf);
		} while (Fsnext()==0);
		Fsetdta(old_dta);
		return TRUE;
	}
	else return FALSE;
}



/* Erzeuge die intern ben”tigte MODFile-Liste aus dem String 'arg'.
 * Param:	arg: String mit den Dateinamen, durch ; oder , getrennt.
 * Return:	Anzahl Elemente oder negative Fehlernummer.
 * Global:	Bei mehr als 2 Elementen wird eine Liste erzeugt und
 *			listentries wird auf die Anzahl der Filenames gesetzt.
 *			Auf jeden Fall enth„lt 'modpath' nach dieser Operation den
 *			ersten gltigen Filenamen.
 */
BOOL make_modlist( char *arg )
{
	char	*p;
	int		i = 0;
	
#define DELIMITER " ,;"

	if ( arg==NULL) return FALSE;			/* NULLptr */

	clear_modfile_list();				/* evtl. alte Liste wegwerfen */

	arg += strspn( arg, DELIMITER );	/* skip delimiter */
	if (*arg==0) return FALSE;			/* no data -> stop */

	while (*arg)
	{
		if (*arg=='\'')						/* string in quotes */
		{									/* read filename */
			p = ++arg;
			while (*arg!='\'') arg++;
			strncpy(modpath, p, arg-p); modpath[arg-p]=0;
			arg++;
		}
		else
		{
			p = arg; arg += strcspn(arg, DELIMITER);
			strncpy(modpath, p, arg-p); modpath[arg-p]=0;
		}
		arg += strspn( arg, DELIMITER );	/* skip delimiters */

		if (i==0 && *arg==0)			/* only one name given */
			return TRUE;

		/* one name given, and another follows */
		add_modfile_to_list( modpath );		/* save name */
	}	
	get_first_mod();

	return TRUE;
}



/* L”sche eine Liste aus dem Speicher.
 * Param:	keine
 * Return:	nichts
 * Global:	listentries und listmemory werden auf Null gesetzt, der
 *			allozierte Speicher freigegeben.
 */
void clear_modfile_list( void )
{
	if (listmemory) Mfree(listmemory);
	listmemory	= NULL;
}

/*
 *
 *
 *
 *
 */
BOOL add_modfile_to_list( const char *name )
{
	string_t	*s;
	size_t		req;
	void		*p;
	filename_block_t *new;

	/* printf("Add name: <%s>\n",name); */

	req = EVEN(sizeof(string_t) + strlen(name) + 1);	/* required storage */

	if (listmemory==NULL)
	{
		new = (filename_block_t*)acc_malloc( sizeof(filename_block_t)
					+ BIGBLOCK );

		if (new==NULL) return FALSE;
		memset(new, 0, sizeof(filename_block_t)+BIGBLOCK );
		new->len = BIGBLOCK;
		listmemory = new;
	}
							
	if (listmemory->len - listmemory->pos < req+10)
	{
		/* allocate more space! */
		new = (filename_block_t*)acc_malloc( sizeof(filename_block_t)
					+ listmemory->len + BIGBLOCK );
		if (new==NULL) return FALSE;
		memcpy(new, listmemory,
				sizeof(filename_block_t)+listmemory->len);
		new->len = listmemory->len + BIGBLOCK;
		/* new->entries = listmemory->entries; */
		Mfree(listmemory);
		listmemory = new;
	}	

	p = &((listmemory->data)[listmemory->pos]);	/* ptr to next free position */
	if (listmemory->len - listmemory->pos < req)
	{
		puts("internal error in add_modfile_to_list()");
		return FALSE;
	}
	s = (string_t *)p;
	s->flag = 0;
	s->siz = (int)req;
	strcpy ( s->str, name );
	listmemory->pos += req;
	listmemory->entries ++;

	return TRUE;
}


/* Kopiere den ersten MODFile-namen in modpath.
 * Param:	keine
 * Return:	TRUE bei Erfolg.
 * Global:	'modpath' wird ver„ndert.
 */
BOOL get_first_mod( void )
{
	long		i;
	string_t	*s;
	
	if (listmemory==NULL) return FALSE;

	listmemory->play = 0;			/* reset position variable */

	i = listmemory->entries;
	s = (void*)listmemory->data;	/* first position */
	while (i-- > 0) 				/* reset access flag */
	{
		s->flag=0;
		((char*)s) += s->siz;		/* next pos */
	}
	
	return get_next_mod();
}


/* Kopiere den n„chsten abzuspielenden MODfile-namen in die globale
 * variable 'modpath'. Wenn in der Liste NUR ein Name angegeben ist,
 * wird der Pfad, der noch in MODPATH liegt, benutzt.
 * Param:	keine
 * Return:	TRUE bei Erfolg.
 * Global:	'modpath' wird ver„ndert.
 */
BOOL get_next_mod( void )
{
	char		*p;
	long 		i;
	string_t	*s;

	if (listmemory == NULL) return FALSE;

	if (listmemory->play >= listmemory->entries)	return FALSE;

	if (shuffle)
	{
		do {
			i=(int)(((long)rand()*listmemory->entries)>>15);
			s = (string_t*)listmemory->data;	/* first position */
			while (i-- > 0)
				((char *)s) += s->siz;					/* next pos */
		} while (s->flag != 0);
	}
	else
	{
		i = listmemory->play;
		s = (string_t*)listmemory->data;		/* first position */
		while (i-- > 0)
			((char*)s) += s->siz;			/* next pos */
	}

	listmemory->play++;
	p = s->str;						/* point to file name */
	s->flag ++;						/* selected once more */

	if (strpbrk(p, ":\\"))			/* Backslash od. ':'	*/
		strcpy( modpath, p );		/* return path...		*/
	else
	{
		trim_path(modpath, NULL);	/* rest abschneiden!	*/
		strcat(modpath,p);			/* anh„ngen!			*/
	}
	return TRUE;
}


long get_num_listentries( void )
{
	if (listmemory == NULL) return 0;
	else return (listmemory->entries);
}



/* Expandiere Wildcards nach der Fileselektorbox.
 * Param:	path:	Zugriffspfad
 *			wild:	Wildcard, Leerstring gilt als '*.MOD'
 *					Achtung! Wird ver„ndert!
 * Return:	nichts
 * Global:	wenn mehr als ein Name passt, wird eine Liste erzeugt!
 */
void expand_wildcards( char *path, char *wild )
{
	if (*wild==0) strcpy(wild, "*.MOD");

	/* printf("path=%s, wild=%s\n", path, wild); */
	
	if (strpbrk(wild, "*?"))			/* Wildcards angegeben? */
	{
		read_dir(path, wild);				/* Directory lesen */
	}
	else
	{
		trim_path(path,NULL);
		strcat(path,wild);				/* kein Wildcard. */
		add_modfile_to_list(path);
	}
}



/* mp_load:
 *	- fileselect,
 *	- make_list (und entscheide ob Multimode oder nicht)
 *	- p_load (first one)
 *	- p_pause (MULTI only)
 */
int mp_load( void )
{
	int 	e=E_OK;

	if (fileselect(modpath, modfile, "Load MODfile" ))
	{ /*
		get_first_mod();
		puts(modpath);
		while (get_next_mod())
			puts(modpath);
 		*/
		get_first_mod();
	
		if (get_num_listentries()>1)
			p_stop();	/* Multi: Stop player */

		if (*modpath)
		{
			graf_mouse(BUSYBEE, NULL);
			e=p_load( modpath );
			if (get_num_listentries()>1) {
				p_repeat=0;
				p_pause();			/* Multimode: -> pause mode! */
			}
			graf_mouse(ARROW, NULL);
		}
	}
	return e;
}



/* autoload:
 *	- make_list
 *	- p_load (first one)
 *	- p_play!
 */
void autoload( void )
{
	if (read_dir( modpath, MOD_MASK ))
	{
		p_load( modpath );			/* LADE erste Datei */
		p_repeat = (get_num_listentries()>1) ? 0 : repeat;
		p_play();
	} else modpath[3]=0;
}



/* mp_stop:
 *	Beendet das Abspielen.
 *	SINGLE: stop player.
 *	MULTI:	kill modlist, stop player.
 */
int mp_stop( void )
{
	if (get_num_listentries()>1)				/* Multi Modus */
	{
		clear_modfile_list(); 			/* Liste zerst”ren */
	}
	return p_stop();
}



/* mp_play:
 *	Startet das Abspielen.
 *	SINGLE: p_play().
 *	MULTI:	while playing: skip to next song, else start player.
 */
int mp_play( void )
{
	if (p_get_state() == P_IDLE)	 /* Zuerst evtl. Laden! */
		error_alert(mp_load());

	if (get_num_listentries()>1)				/* Multi Modus */
	{
		p_repeat = 0;
		if (p_get_state() == P_PLAYING)
			return p_stop();	/* player stop, dadurch den
								 * Sequenzer ausl”sen!
								 */
		else
			return p_play();
	}
	else							/* Single Modus */
	{
		p_repeat = repeat;
		return p_play();
	}
}



/* mp_free: release everything!
 *
 */
void mp_free( void )
{
	clear_modfile_list();
	p_free();
}



/* mp_pause:
 *	p_pause!
 */
#define mp_pause p_pause
/* mp_fastforward:
 *	p_fastforward!
 */
#define mp_fastforward p_fastforward
/* mp_rewind:
 *	p_rewind!
 */
#define mp_rewind p_rewind



/* mod_sequencer:
 *	Holt die n„chste Datei falls n”tig. Diese Funktion sollte regelm„žig
 *	durch evnt_timer aufgerufen werden.
 *  Aužerdem wird die Sound DMA Funktion gecheckt. Bei STOP -> relaunch
 * Param:	keine.
 * Return:	letzte gltige Fehlernummer.
 * Global:	liest die Listen aus. Wenn alles ausgelesen ist und 'repeat'
 *			nicht gesetzt, erfolgt ein mp_stop.
 */
int mod_sequencer( void )
{
	int 	e=E_OK,
			st;
	/* supexec aus einem Assemblermodul! */
	void	supexec( void (*func)() );

	st = p_get_state();
	if (st==P_PLAYING) supexec(check_sound_running);
	if (get_num_listentries()>1 && st<=P_STOPPED )		/* Multi-Modus && FERTIG */
	{										/* ja! */
		e=get_next_mod();					/* hole die n„chste Datei */
		if ( e==FALSE && repeat ) e=get_first_mod();

		if (e)								/* einen hab ich noch! */
		{
			if (wi_handle>0)	graf_mouse(BUSYBEE, NULL);
			e=p_load(modpath);				/* MOD laden */
			if (e==E_OK)		p_play();	/* restart player */
			if (wi_handle>0) 	graf_mouse(ARROW, NULL);
		}
		else
			mp_stop();						/* Ende der fahnenstange */

		draw_indicators( 0x8000 );			/* force status line redraw */
	}
	return(e);
}



/* -------------------------------------------------------------------- */
/*	Save & Read Parameters												*/
/* -------------------------------------------------------------------- */

/* Struktur der INF-Datei: */
typedef struct infofile {
	char	magic[8];			/* 'PAULA2.0' */
	int 	samplefreq,
			framefreq,
			transpose,
			pitch,
			interpolate,
			boost,
			shuffle,
			compatibility,
			repeat,
			swapchannel;
	long	checksum;
} t_infofile;



/* Parameter abspeicheln...
 */
int save_parameters( void )
{
	t_infofile	data;
	int 		i, *p, handle;
	long		chk;

	strcpy( data.magic, FILEMAGIC );
	data.samplefreq 	= p_set_samplefreq(-1);
	data.interpolate	= p_interpolate;
	data.boost			= p_boost;
	data.shuffle		= shuffle;
	data.compatibility	= p_compatibility;
	data.repeat 		= repeat;
	data.pitch			= detune;
	data.transpose		= transpose;
	data.framefreq		= p_set_framefreq(-1);
	data.swapchannel	= p_swapchannel;
	data.checksum		= 0;

	p = (int *)&data;
	chk = 0;					/* Berechne einfache Checksumme */
	for( i=(int)(sizeof(t_infofile)-sizeof(long)); i>0; i-=2)
		chk += *p++;
	data.checksum		= chk;

	handle = (int)Fcreate(infpath, 0);
	if (handle>0)
	{
		Fwrite(handle, sizeof(t_infofile), &data);
		Fclose(handle);
		return E_OK;
	}
	else
		return handle;				/* TOS Errorcode */
}


/* read_parameters: lese INF datei und setze interne vars danach.
 */
int read_parameters( void )
{
	t_infofile	data;
	int 		i, *p, handle;
	long		chk;
	char		*k;
/*	OBJECT		*rg = rs_trindex[REGISTER]; */

	/*--------------------- get active path ! */
	k=infpath;
	*k++ = Dgetdrv()+'A';
	*k++ = ':';
	Dgetpath(k, 0);
	k += strlen(k);
	if (k[-1]!='\\') *k++='\\';
	strcpy(k,INFOFILE);

	/*--------------------- read config. */
	registered=0;							/* not registered... */
	handle = (int)Fopen(INFOFILE, FO_READ);
	if (handle>0)
	{
		Fread(handle, sizeof(t_infofile), &data);
		Fclose(handle);

		if (strncmp(data.magic, FILEMAGIC, sizeof(FILEMAGIC)-1) == 0)
		{
			p = (int *)&data;
			chk = 0;				/* Berechne einfache Checksumme */
			for( i=(int)(sizeof(t_infofile)-sizeof(long)); i>0; i-=2)
				chk += *p++;
			if (chk == data.checksum)
			{
				p_set_samplefreq(data.samplefreq);
				p_set_framefreq(data.framefreq);
				detune			= data.pitch;
				transpose		= data.transpose;
				set_amigafreq(transpose, detune);
				p_interpolate	= data.interpolate;
				p_boost 		= data.boost;
				shuffle 		= data.shuffle;
				p_compatibility = data.compatibility;
				repeat			= data.repeat;
				p_swapchannel	= data.swapchannel;
				return 0;
			}
			else return -1;
		}
		else return -1; 			/* allg. Fehler */
	}
	else
		return handle; 			/* TOS Errorcode */
}



/* -------------------------------------------------------------------- */
/* -------------------------------------------------------------------- */
