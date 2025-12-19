/*
 * Beispiel-Programm zur Benutzung des Selectric-Protokolls mit BoxKite
 * unter MiNT/MultiTOS
 * (c) Harald Becker, 12.5.1994. öbersetzt mit Pure C und DEFAULT.PRJ.
 *
 * Diesen Code dÅrfen Sie nach Belieben verwenden und ganz oder in in AuszÅgen
 * in Ihre Programme aufnehmen.
 */
#include <stdio.h>
#include <aes.h>
#include <tos.h>
#include <string.h>


/*
 * Diese Struktur wird von BoxKite gefÅllt. Sie ist identisch mit der
 * TOS-DTA, sieht jedoch Platz fÅr lange Datenamen vor.
 */
typedef struct
{	char			d_reserved[21];
	unsigned char	d_attrib;
	unsigned int	d_time;
	unsigned int	d_date;
	unsigned long	d_length;
	char			d_fname[34];
} XDTA;

/*
 * Die Selectric-Struktur.
 */
typedef struct
{	unsigned long	id;			/* Selectric ID (SLCT)		*/
	unsigned int	version;	/* version (BCD-Format)		*/
	struct
	{	unsigned           : 7;    /* reserved                     */
		unsigned pthsav    : 1;
		unsigned stdest    : 1;
		unsigned           : 1;
		unsigned numsrt    : 1;   /* numerisches Sortieren     */
		unsigned lower     : 1;
		unsigned dclick    : 1;   /* Ordner mit Doppelklick    */
		unsigned hidden    : 1;   /* versteckte Dateien        */
		unsigned onoff     : 1;   /* Fileselector AN/AUS       */
	} config;
	int	sort;			/* sort-mode (neg. = rev.)	*/
	int	num_ext;		/* number of extensions		*/
	char *(*ext)[];		/* preset extensions		*/
	int	num_paths;		/* number of paths		*/
	char *(*paths)[];		/* preset paths			*/
	int	comm;			/* communication word		*/
	int	in_count;		/* input counter		*/
	void *in_ptr;		/* input pointer		*/
	int	out_count;		/* output counter		*/
	void *out_ptr;		/* output pointer		*/
	int	cdecl	(*get_first)(XDTA *dta, int attrib);
	int	cdecl 	(*get_next)(XDTA *dta);
	int	cdecl	(*release_dir)(void);
} SLCT_STR;

typedef struct
{	long	id;
	long	value;
} COOKIE;

long Supexec(long (*codeptr)());

long mint_cookie;
SLCT_STR *slct_cookie;
int	cdecl (*p_get_first)(XDTA *dta, int attrib);
int	cdecl (*p_get_next)(XDTA *dta);
int	cdecl (*p_release_dir)(void);

/*
 * Gibt die Adresse des Cookie-Jar zurÅck. Mit Supexec() aufrufen.
 */
long get_cookiejar(void)
{	return *((long *)0x05a0l);
}

/*
 * Durchsucht den Cookie Jar nach einem cookie mit gegebener id und
 * liefert dessen Wert zurÅck.
 */
long get_cookie(long id)
{	long sav;
	COOKIE *cookiejar;
	int	i = 0;

	cookiejar = (COOKIE *)Supexec(get_cookiejar);

	if ( cookiejar )
	{	while ( cookiejar[i].id )
		{	if ( cookiejar[i].id == id )
				return cookiejar[i].value;
			i++;
		}
	}
	return 0L;
}

/*
 * PrÅft, ob am 'FSEL'-cookie ein Selectric-1.02-kompatibler Fileselector hÑngt.
 * Im Erfolgsfall werden die Zeiger auf die Directory-Routinen ausgelesen und
 * irgendwohin kopiert, wo sie ohne memory protection violation erreichbar sind.
 */
long setup_selector(void)
{	if ( slct_cookie && slct_cookie->id == 'SLCT' && slct_cookie->version >= 0x102 )
	{	slct_cookie->comm = 9;
		p_get_first = slct_cookie->get_first;
		p_get_next = slct_cookie->get_next;
		p_release_dir = slct_cookie->release_dir;
		return 1;
	}
	return 0;
}

/*
 * Fragt das aktuelle Laufwerk und den aktuellen Pfad ab.
 */
void getpath(char *p)
{	int drv;

	drv = Dgetdrv();
	*p++ = drv + 'A';
	*p++ = ':';
	Dgetpath(p, drv);
	p += strlen(p) - 1;
	if ( *p != '\\' )
	{	p++;
		*p++ = '\\';
		*p = 0;
	}
}

int main(void)
{	XDTA mydta;
	char path[130], name[34], outbuf[128];
	int exbtn, rv, d, i;

	appl_init();

	slct_cookie = (SLCT_STR *)get_cookie('FSEL');
	mint_cookie = get_cookie('MiNT');

	if ( !Supexec(setup_selector) )
	{	form_alert(1, "[1][Kein kompatibler Fileselector|installiert.][   Ok   ]");
		appl_exit();
		return 0;
	}

	if ( mint_cookie )			/* Damit auch wirklich lange Namen rauskommen */
		Pdomain(1);

	getpath(path);
	strcat(path, "*.*");
	*name = 0;
	wind_update(BEG_MCTRL);		/* Wichtig */
	rv = fsel_input(path, name, &exbtn);
	if ( rv && exbtn )
	{	d = p_get_first(&mydta, 0xff);
		i = 1;
		while( !d )
		{	sprintf(outbuf, "[1][Datei Nr %d:|%s %02x][   Ok   ]", i, mydta.d_fname, mydta.d_attrib);
			form_alert(1, outbuf);
			d = p_get_next(&mydta);
			i++;
		}
		p_release_dir();
	}
	wind_update(END_MCTRL);		/* Wichtig */

	appl_exit();
	return 0;
}
