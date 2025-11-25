/*
 * Beispiel-Programm zur Benutzung des Selectric-Protokolls mit BoxKite
 * unter MiNT/MultiTOS
 * (c) Harald Becker, 12.5.1994. öbersetzt mit Pure C und DEFAULT.PRJ.
 *
 * Diesen Code dÅrfen Sie nach Belieben verwenden und ganz oder in in AuszÅgen
 * in Ihre Programme aufnehmen.
 * Erweitert um eine Anwendung fÅr den Message-Callback in BoxKite 1.71
 * Dazu wird hinter dem Fileselector ein kleines Fenster geîffnet,
 * das Åber den Message-Callback gezeichnet wird. Es kann auch
 * verschoben werden, falls das Betriebssystem das Verschieben hinten-
 * liegender Fenster erlaubt.
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

SLCT_STR *slct_cookie;
int	cdecl (*p_get_first)(XDTA *dta, int attrib);
int	cdecl (*p_get_next)(XDTA *dta);
int	cdecl (*p_release_dir)(void);

int window;			/* Fensterkennung */
OBJECT contents = 	/* Fensterinhalt */
	{ -1, -1, -1, G_BOXCHAR, 0, 0, 0x2aff11f0, 1, 1, 1, 1 };

int xdesk, ydesk, wdesk, hdesk;

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

/* 
 * Die folgenden vier Funktionen befassen sich nur mit dem Zeichnen
 * des Fensterinhaltes. Ich denke, die Methode hat sich inzwischen
 * herumgesprochen.
 */
int min(int a, int b)
{	return ( a < b ? a : b );
}

int max(int a, int b)
{	return ( a > b ? a : b );
}

int rc_intersect(GRECT *p1, GRECT *p2)
{	int tx, ty, tw, th;

	tw = min(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
	th = min(p2->g_y + p2->g_h, p1->g_y + p1->g_h);
	tx = max(p2->g_x, p1->g_x);
	ty = max(p2->g_y, p1->g_y);

	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;

	return( (tw > tx) && (th > ty) );
}

void window_redraw(int handle, int x, int y, int w, int h)
{	GRECT r1, r2, world;

	wind_update(BEG_UPDATE);

	r2.g_x = x;
	r2.g_y = y;
	r2.g_w = w;
	r2.g_h = h;

	world.g_x = xdesk;
	world.g_y = ydesk;
	world.g_w = wdesk;
	world.g_h = hdesk;

	wind_get(handle, WF_FIRSTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
	while ( r1.g_w && r1.g_h )
	{	if ( rc_intersect(&world, &r1) && rc_intersect(&r2, &r1) )
			objc_draw(&contents, ROOT, MAX_DEPTH, r1.g_x, r1.g_y, r1.g_w, r1.g_h);
		wind_get(handle, WF_NEXTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
	}
	wind_update(END_UPDATE);
}

/* 
 * Die Einsprungadresse dieser Funktion wird als Callback an BoxKite Åbergeben.
 */
void cdecl message_handler(int *msg)
{	switch ( msg[0] )
	{	case WM_REDRAW:
			wind_get(msg[3], WF_WORKXYWH, &contents.ob_x, &contents.ob_y, &contents.ob_width, &contents.ob_height);
			window_redraw(msg[3], msg[4], msg[5], msg[6], msg[7]);
			break;
		case WM_MOVED:
			wind_set(msg[3], WF_CURRXYWH, msg[4], msg[5], msg[6], msg[7]);
			break;
	}
}

typedef void cdecl (* FSEL_CALLBACK)(int *msg);

/*
 * Ein alternatives Binding fÅr fsel_exinput() (Die Funktionsnummer ist
 * identisch!), das die öbergabe der Callback-Adresse erlaubt. Andere
 * Fileselectoren sollten den ÅberzÑhligen Parameter einfach ignorieren.
 *
 * Eine Assembler-Version dieses Bindings, die keine Annahmen Åber das
 * Vorhandensein eines generellen GEM-Traps (hier: '_crystal') im
 * verwendeten Entwicklungssystem macht, befindet sich im Quelltext in
 * 'BOXINPUT.S' und als Objektdatei im DRI-Format in 'BOXINPUT.O'.
 */
int cdecl fsel_boxinput(char *path, char *name, int *button, char *label, FSEL_CALLBACK callback)
{	void *aespb[6], *addrin[6], *addrout[6];
	int contrl[5], global[15], intin[16], intout[7];

	aespb[0] = contrl;
	aespb[1] = global;
	aespb[2] = intin;
	aespb[3] = intout;
	aespb[4] = addrin;
	aespb[5] = addrout;

	contrl[0] = 91;
	contrl[1] = 0;
	contrl[2] = 2;
	contrl[3] = 4;
	contrl[4] = 0;

	addrin[0] = path;
	addrin[1] = name;
	addrin[2] = label;
	addrin[3] = callback;

	_crystal((AESPB *)aespb);

	*button = intout[1];
	return intout[0];
}

int main(void)
{	XDTA mydta;
	char path[130], name[34], outbuf[128];
	int exbtn, rv, d, i;

	appl_init();
	wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);

	slct_cookie = (SLCT_STR *)get_cookie('FSEL');

	if ( !Supexec(setup_selector) )
	{	form_alert(1, "[1][Kein kompatibler Fileselector|installiert.][   Ok   ]");
		appl_exit();
		return 0;
	}

	Pdomain(1);			/* Damit auch wirklich lange Namen rauskommen */

	/*
	 * Ein Fenster hinter dem Fileselector îffenen, damit man sieht,
	 * daû auch etwas beim Message-Callback ankommt.
	 */
	window = wind_create(NAME | MOVER, xdesk, ydesk, wdesk, hdesk);
	if ( window < 0 )
	{	form_alert(1, "[1][Das Fenster klemmt mal wieder!][   Ok   ]");
		appl_exit();
		return 0;
	}
	wind_set(window, WF_NAME, "Noch'n Fenster");
	wind_open(window, xdesk + 50, ydesk + 50, 300, 200);
	window_redraw(window, xdesk, ydesk, wdesk, hdesk);

	getpath(path);
	strcat(path, "*.*");
	*name = 0;
	rv = fsel_boxinput(path, name, &exbtn, "BoxKite", &message_handler);

	if ( rv && exbtn )
	{	wind_update(BEG_UPDATE);
		d = p_get_first(&mydta, 0xff);
		i = 1;
		while( !d )
		{	sprintf(outbuf, "[1][Datei Nr %d:|%s %02x][   Ok   ]", i, mydta.d_fname, mydta.d_attrib);
			form_alert(1, outbuf);
			d = p_get_next(&mydta);
			i++;
		}
		p_release_dir();
		wind_update(END_UPDATE);
	}
	wind_close(window);
	wind_delete(window);
	appl_exit();
	return 0;
}
