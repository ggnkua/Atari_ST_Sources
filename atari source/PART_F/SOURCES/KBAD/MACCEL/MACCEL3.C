/* maccel3.c - installation part of mouse accelerator
 * =================================================================
 * 890927 kbad added Stacy support, iconized interface
 */

/*#define TESTES*/

#include <tos.h>
#include <alt\aesalt.h> /* gets aes, portab */

#include "rsc\maccel3.h"

#pragma warn -apt	/* 1 Non-portable pointer assignment */
#pragma warn -rpt	/* 1 Non-portable pointer conversion */
#include "rsc\maccel3.rsh"
#pragma warn .apt
#pragma warn .rpt

typedef struct _osheader { /* offset description		    */
			    /* --- -------------------------------- */
    unsigned	os_entry;   /* $00 BRA to reset handler 	    */
    unsigned	os_version; /* $02 TOS version number		    */
    void	*reseth;    /* $04 -> reset handler		    */
struct _osheader *os_beg;   /* $08 -> base of OS		    */
    void	*os_end;    /* $0c -> end BIOS/GEMDOS/VDI ram usage */
    void	*os_rsv1;   /* $10 << unused, reserved >>	    */
    void	*os_magic;  /* $14 -> GEM memory usage parm. block  */
    long	os_date;    /* $18 Date of system build ($MMDDYYYY) */
    unsigned	os_conf;    /* $1c OS configuration bits	    */
    unsigned	os_dosdate; /* $1e DOS-format date of system build  */
/* The next three fields are only available in TOS versions 1.2 and greater */
    void	*root;	    /* $20 -> base of OS pool		    */
    char	*kbshift;   /* $24 -> keyboard shift state variable */
    void	*run;	    /* $28 -> GEMDOS PID of current process */
    void	*rsv2;	    /* $2c << unused, reserved >>	    */
} OSHEADER;
#define sysbase     (*(OSHEADER **)0x4f2)


struct MA_INFO {
	long	branch; 	/* branch past handlers 	*/
	long	cookie;
	char	watch;		/* watch modem flag		*/
	char	linear; 	/* linear (slow) flag		*/
	char	lbdown; 	/* left button debounce 	*/
	char	rbdown; 	/* right button debounce	*/
	long	mvloc;		/* location of mouse vector	*/
	long	vdivec; 	/* saved vdi mouse vector	*/
	int	timeout;	/* vbls before scrnsave kicks in*/
	int	fliptime;	/* vbls while flipping		*/
	int	udset;
	int	updown; 	/* adder for vbl count, also	*/
				/* serves as an "enable" flag	*/
	int	vblcount;
	int	colors[16];
	int	flipped;	/* nonzero if scrnsave activated*/
	char	stacy;		/* nonzero if we're running on stacy */
	char	stacmask;	/* mask for stacy screen control */
	int	savepark;	/* save location for park time	*/
} *ma_info;

struct MA_FILE {
	int	magic;
	long	tsize;
	long	dsize;
	long	bsize;
	long	ssize;
	long	res1;
	long	flags;
	int	abs;
	struct MA_INFO minfo;
} mafile;
    
typedef struct jar_entry {
	long	cookie;
	long	value;
} JAR_ENTRY;

#define MAXUNITS 16
typedef struct pun_info {
	int	puns;			/* # physical units */
	char	pun[MAXUNITS];		/* pun table (incl dummy A&B puns */
	long	partstart[MAXUNITS];	/* partition start table  (incl dums) */
	long	cookie;			/* cookie ('AHDI') */
	long	*cookptr;		/* ->cookie */
	int	version;		/* AHDI version: MMmm */
	int	maxssz;			/* max sector size in system */
	union {
	    unsigned char flag;
	    unsigned long time;
	} idle;			/* hi byte = 0xff :: time is valid */
				/* 24 bit idle time b4 spinning down ACSI 0 */
				/* (in 200Hz ticks - 5 min default) */
	long	reserved[15];
} PUN_INFO;


#define pun_ptr	    (*(PUN_INFO **)0x516)
#define p_cookies   (*(JAR_ENTRY **)0x5a0)
#define resvector   (*(void (**)())0x42a)
#define resvalid    (*(long *)0x426)
#define RESMAGIC    0x31415926L

#define COOKIE	    0xAA006EL
#define JARSIZE     40L
#define KBS10	    ((char *)0xe1bL)
#define VBLQUEUE    (*(long **)0x456)

/* slider time delay definitions */
#define SL_MAX_DELAY 150
#define SL_MIN_DELAY 50
#define SL_INC	     10

/* slider min and max values */
#define SAVE_MIN    1
#define SAVE_MAX    9
#define SAVE_PAGE   1
#define PARK_MIN    1
#define PARK_MAX    30
#define PARK_PAGE   5

/* bits in SHADOW */
#define SH_SCREEN   '\004'
#define SH_LIGHT    '\010'

extern	struct MA_INFO start;		/* start of text segment */
extern	JAR_ENTRY   cookie_jar[];
extern	void	    myreset();
extern	void	    (*oldrvec)();
extern	long	    oldrval;
extern	void	    (*oldmvec)();
extern	void	    (*oldkbd)();
extern	void	    (**mvloc)();
extern	void	    (*oldrs)();
extern	char	    *kbshift;
extern	void	    mouse( void );
extern	void	    ikbd( void );
extern	void	    rs232( void );
extern	void	    myvbl( void );
extern	long	    video;

extern	void	IPL7( void );
extern	void	IPL_RESTORE( void );

KBDVBASE    *kbase;
long	    *vbentry;
int	    parktime;

void	get_cookie( void );
void	sethooks( void );
void	unhook( void );
void	set_cookie( void );
int	configure( void );
void	fix_rsh( void );

void
main( void )
{
    int abort;
#define AES_active ( _GemParBlk.global[0] )

    appl_init();
    fix_rsh();	/* needed for addresses of "hello" strings */
/* get_cookie is now called from the startup
    Supexec((long(*)())get_cookie);
*/
    if( !ma_info ) {
	ma_info = &start;
    /* Not installed, set vectors */
	Supexec( (long(*)())sethooks );
    }

    if( AES_active ) {
	abort = configure();
	appl_exit();
	if( abort && (ma_info == &start) ) {
	    Supexec( (long(*)())unhook );
	    Pterm0();
	}
    }
    if( ma_info == &start )
	Supexec( (long(*)())set_cookie );
    if( !AES_active ) {
	Cconws( (char *)rs_frstr[HELLO1] );
	Cconws( (char *)rs_frstr[HELLO2] );
    }
}


void
get_cookie( void )
{
    JAR_ENTRY	*pjar;

    pjar = p_cookies;
    if( !pjar ) return;
    while( pjar->cookie ) {
	if( pjar->cookie == 0x5f56444fL ) /* _VDO */
	    video = pjar->value;
	if( pjar->cookie == COOKIE )
	    ma_info = (struct MA_INFO *)(pjar->value);
	++pjar;
    }
}

unsigned int *SHADOW = (unsigned int *)0xFFFF827EL;
#define NPATTERNS	6
unsigned int wPattern[NPATTERNS] = {0x01, 0x02, 0x04, 0x08, 0x05, 0x0A};
char isStacy = 1;

void
sethooks( void )
{
    unsigned int wOriginalValue;
    int i;

/* find out if we're on Stacy */
    wOriginalValue = *SHADOW;
    for(i=0; (i<NPATTERNS)&&(isStacy); ++i){
	*SHADOW = wPattern[i];
	isStacy = ((*SHADOW & 0xF) == wPattern[i]);
    }
    *SHADOW = wOriginalValue;
    ma_info->stacy = isStacy;

#ifdef CLICK_CONFIG
/* get kbshift address */
    if( sysbase->os_version == 0x100 ) kbshift = KBS10;
    else kbshift = sysbase->kbshift;
#endif
/* install maccel vectors */
    kbase = Kbdvbase();
    mvloc = &kbase->kb_mousevec;
/*  IPL7();*/
    oldrvec = resvector;
    oldrval = resvalid;
    resvector = myreset;
    resvalid = RESMAGIC;
    oldmvec = kbase->kb_mousevec;
    kbase->kb_mousevec = mouse;
    oldkbd = kbase->kb_kbdsys;
    kbase->kb_kbdsys = ikbd;
    oldrs = Setexc( 76, rs232 );
    vbentry = VBLQUEUE;
    while( *(++vbentry) ); /* skip the VDI entry */
    *(void(**)())vbentry = myvbl;
/*  IPL_RESTORE();*/
}

void
unhook( void )
{
/*  IPL7();*/
    resvector = oldrvec;
    resvalid = oldrval;
    kbase->kb_mousevec = oldmvec;
    kbase->kb_kbdsys = oldkbd;
    Setexc( 76, oldrs );
    *vbentry = 0;
/*  IPL_RESTORE();*/
}

void
get_parktime( void )
{
#ifdef TESTES
    parktime = 0;
#else

    if( pun_ptr->cookie == 0x41484449L &&
    	pun_ptr->cookptr == &(pun_ptr->cookie) &&
    	pun_ptr->idle.flag == 0xff )
	parktime = (int)((pun_ptr->idle.time & 0xffffffL) / 12000L);
    else parktime = -1;
#endif
}

void
set_ptime( void )
{
#ifdef TESTES
    return;
#else
    if( parktime >= 0 )
        pun_ptr->idle.time = (parktime * 12000L) | 0xff000000L;
#endif
}

#if 0
/* this is now located in maccel.s */
void
set_cookie( void )
{
    int 	count;
    JAR_ENTRY	*pjar, *qjar;


/* set up park time first (no better place to do it) */
    get_parktime();
    if( parktime >= 0 ) parktime = ma_info->savepark;
    set_ptime();

    pjar = p_cookies;

    if( !pjar ) {
    /* no jar found, set one up */
	qjar = p_cookies = cookie_jar;
	qjar->cookie = COOKIE;
	qjar->value = (long)ma_info;
	++qjar;
	qjar->cookie = 0L;
	qjar->value = JARSIZE;
    } else {
    /* find the end of the cookie jar */
	for( count = 0; pjar[count].cookie; ++count );

	if( pjar[count].value < count ) {
	/* there's room in the jar */
	    pjar[count+1].cookie = 0L;
	    pjar[count+1].value = pjar[count].value;
	    pjar[count].cookie = COOKIE;
	    pjar[count].value = (long)ma_info;
	} else {
	/* no room, copy the jar to cookie_jar */
	    qjar = p_cookies = cookie_jar;
	    while( pjar->cookie )
		*qjar++ = *pjar++;
	    qjar->cookie = COOKIE;
	    qjar->value = (long)ma_info;
	    ++qjar;
	    qjar->cookie = 0L;
	    qjar->value = JARSIZE;
	}
    }
}
#endif

static char *savepath;

void
fixalert( char *ppath )
{
    savepath = ppath;
    while( *(++savepath) != 'C' )
    ;
    if( !(Drvmap() & 4) ) *savepath = 'A';
}

void
fix_rsh( void )
{
    int     i;
    long    index;

    for( i = 0; i < NUM_OBS; i++ ) {
	index = rs_object[i].ob_spec.index;
	switch( rs_object[i].ob_type ) {
	/* ob_spec -> TEDINFO */
	case G_TEXT:
	case G_BOXTEXT:
	case G_FTEXT:
	case G_FBOXTEXT:
	    /* fix pointers in TEDINFO */
	    rs_tedinfo[index].te_ptext =
		rs_strings[(long)(rs_tedinfo[index].te_ptext)];
	    rs_tedinfo[index].te_ptmplt =
		rs_strings[(long)(rs_tedinfo[index].te_ptmplt)];
	    rs_tedinfo[index].te_pvalid =
		rs_strings[(long)(rs_tedinfo[index].te_pvalid)];
	    /* fix ob_spec */
	    rs_object[i].ob_spec.tedinfo = &rs_tedinfo[index];
	    break;
#if 0 /* no icons in maccel resource */
	/* ob_spec -> ICONBLK */
	case G_ICON:
	    /* fix pointers in ICONBLK */
#pragma warn -sus
	    rs_iconblk[index].ib_pmask =
		rs_imdope[(long)(rs_iconblk[index].ib_pmask)].image;
	    rs_iconblk[index].ib_pdata =
		rs_imdope[(long)(rs_iconblk[index].ib_pdata)].image;
#pragma warn .sus
	    rs_iconblk[index].ib_ptext =
		rs_strings[(long)(rs_iconblk[index].ib_ptext)];
	    rs_object[i].ob_spec.iconblk = &rs_iconblk[index];
	    break;
#endif
	/* ob_spec -> BITBLK */
	case G_IMAGE:
	    /* fix pointers in BITBLK */
#pragma warn -sus
	    rs_bitblk[index].bi_pdata =
		rs_imdope[(long)(rs_bitblk[index].bi_pdata)].image;
#pragma warn .sus
	    rs_object[i].ob_spec.bitblk = &rs_bitblk[index];
	    break;
	/* ob_spec -> string */
	case G_BUTTON:
	case G_STRING:
	case G_TITLE:
	    rs_object[i].ob_spec.free_string = rs_strings[index];
	    break;
	/* ob_specs not requiring fixups */
	case G_USERDEF:
	case G_BOX:
	case G_IBOX:
	case G_BOXCHAR:
	    break;
	}
	rsrc_obfix( rs_object, i );
    }

/* fix up free strings & images */
    for( i = 0; i < NUM_FRSTR; i++ )
	rs_frstr[i] = (long)(rs_strings[rs_frstr[i]]);
    for( i = 0; i < NUM_FRIMG; i++ ) {
	index = rs_frimg[i];
#pragma warn -sus
	rs_bitblk[index].bi_pdata =
	    rs_imdope[(long)(rs_bitblk[index].bi_pdata)].image;
#pragma warn .sus
	rs_frimg[i] = (long)(&rs_bitblk[rs_frimg[i]]);
    }

#if 0 /* only one tree in MACCEL resource */
/* fix up tree index references */
    for( i = 0; i < NUM_TREE; i++ )
    	rs_trindex[i] = (long)(&rs_object[rs_trindex[i]]);
#endif

/* fix up filename in save alert */
    fixalert( (char *)rs_frstr[SAVELERT] );
}


void
save_conf( int timeout )
{
    OBJECT *tree = rs_object;
    char *ppath, *endpath, *qpath, *pfsel;
    char *alert = (char *)rs_frstr[SAVELERT];
    char path[128],file[14];
    int ret, button;

/* get filename from alert */
    endpath = ppath = savepath;
    while( *(++endpath) != '?');

/* find out what user wants to do */
    ret = form_alert( 1, alert );
/* Cancel */
    if( ret == 3 ) return;
/* Locate */
    if( ret == 2 ) {
	qpath = ppath;
	pfsel = path;
	while( *qpath != 'M' ) *pfsel++ = *qpath++;
	*pfsel++ = '*'; *pfsel++ = '.'; *pfsel++ = '*'; *pfsel++ = 0;
	file[0] = 0;
	ret = fsel_input( path, file, &button );
	if( ret < 0 ) {
saverr:     form_alert( 1, (char *)rs_frstr[SAVERR] );
	    if( !*endpath ) *endpath = '?';
	    return;
	}
	if( !button ) return;
	pfsel = path;
	qpath = file;
	while( *(++pfsel) );
	while( *(--pfsel) != '\\' );
	while( *qpath ) *(++pfsel) = *qpath++;
	*(++pfsel) = 0;
	ppath = path;
    }
    if( ret == 1 ) {
	*endpath = 0;
    }
    ret = (int)Fopen( ppath, 0 );
    if( ret < 0 ) goto saverr;
    if( Fread(ret, sizeof(struct MA_FILE), &mafile) != sizeof(struct MA_FILE)
	|| mafile.magic != 0x601a
	|| mafile.minfo.cookie != COOKIE ) {
	Fclose( ret );
	goto saverr;
    }
    mafile.minfo.udset = ma_info->udset;
    mafile.minfo.linear = ma_info->linear;
    if( IsSelected(MODEM) ) mafile.minfo.watch = 1;
    else mafile.minfo.watch = 0;
    if( ma_info->stacy ) {
	mafile.minfo.stacy = 1;
	if( IsSelected(SWITCH) ) {
	    mafile.minfo.stacmask |= SH_SCREEN;
	} else {
	    mafile.minfo.stacmask &= ~SH_SCREEN;
	}
	if( IsSelected(LITE) ) {
	    mafile.minfo.stacmask |= SH_LIGHT;
	} else {
	    mafile.minfo.stacmask &= ~SH_SCREEN;
	}
    } else mafile.minfo.stacy = mafile.minfo.stacmask = 0;
/* save the park time for Leonard */
    mafile.minfo.savepark = (parktime >= 0) ? parktime : 0;

    mafile.minfo.timeout = timeout * 3600;

    mafile.flags |= 7;
    Fseek( 0L, ret, 0 );
    button = (int)Fwrite( ret, sizeof(struct MA_FILE), &mafile );
    Fclose( ret );
    if( button != (int)sizeof(struct MA_FILE) ) goto saverr;
    else if( !*endpath ) *endpath = '?';
}

void
set_accelbox( int linear )
{
    OBJECT *tree = rs_object;

    Deselect(ACCOFF);
    Deselect(ACCSLOW);
    Deselect(ACCFAST);

    if( linear < 0 )
	Select(ACCOFF);
    else if( linear > 0 )
	Select(ACCSLOW);
    else
	Select(ACCFAST);
}

void
set_screenbox( int enabled )
{
    OBJECT *tree = rs_object;

    if( !ma_info->stacy )
    	HideObj(STACOPTS);
    else
    	ShowObj(STACOPTS);

    if( enabled ) {
	Select(SCREEN);
	ObFlags(SWITCH) = ObFlags(LITE) = TOUCHEXIT;
	ObState(SWITCH) =
	  ObState(LITE) =
	  ObState(SAVEUP) =
	  ObState(SAVEBOX) =
	  ObState(SAVESLID) =
	  ObState(SAVEDOWN) =
	  ObState(MODEM) = NORMAL;
	HideObj(SAVECOVR);
    } else {
	Deselect(SCREEN);
	ObFlags(SWITCH) = ObFlags(LITE) = NONE;
	ObState(SWITCH) =
	  ObState(LITE) =
	  ObState(SAVEUP) =
	  ObState(SAVEBOX) =
	  ObState(SAVESLID) =
	  ObState(SAVEDOWN) =
	  ObState(MODEM) = DISABLED;
	ShowObj(SAVECOVR);
    }

}

void
set_parkbox( void )
{
    OBJECT *tree = rs_object;
extern int parktime;

    if( parktime < 0 ) {
	HideObj(PARKSECT);
    } else if( parktime > 0 ) {
	Select(PARK);
	ObState(PARKUP) =
	  ObState(PARKBOX) =
	  ObState(PARKSLID) =
	  ObState(PARKDOWN) = NORMAL;
	HideObj(PARKCOVR);
    } else {
	Deselect(PARK);
	ObState(PARKUP) =
	  ObState(PARKDOWN) =
	  ObState(PARKBOX) =
	  ObState(PARKSLID) =
	  ObState(PARKDOWN) = DISABLED;
	ShowObj(PARKCOVR);
    }
}


void
itoa2( int n, char *s )
{
    *s++ = n / 10 + '0';
    *s++ = n % 10 + '0';
    *s = 0;
}

void
sl_x( int base, int value, int min, int max )
{
    OBJECT *tree = rs_object;
    int slider = ObHead(base);


    if( value == max ) {
	ObX(slider) = ObW(base) - ObW(slider);
    } else {
	ObX(slider) =
	    (int)( ( (long)(value-min) * ( (long)(ObW(base) - ObW(slider)) * 1000L )
	    	   ) /
	    	   ( (long)(max-min) * 1000L )
	    	 );
    }

    if( max < 10 )
    	TedText(slider)[0] = '0' + value;
    else
    	itoa2( value, TedText(slider) );
}

void
sl_arrow( int base, int obj, int inc, int min, int max, int *numvar )
{
    OBJECT *tree = rs_object;
    int slider = ObHead(base);
    MRETS mk;
    int newvalue, oldvalue, delay = SL_MAX_DELAY;
    GRECT slidrect;

    slidrect = ObRect( slider );
    objc_offset( tree, slider, &slidrect.g_x, &slidrect.g_y );
/* account for outlines */
    slidrect.g_x--;
    slidrect.g_y--;
    slidrect.g_w += 2;
    slidrect.g_h += 2;

    if( obj > 0 )
	select( tree, obj );

    oldvalue = *numvar;
    do {
	newvalue = *numvar + inc;
	if( newvalue < min ) newvalue = min;
	else if( newvalue > max ) newvalue = max;
	/* if in bounds, change the slider thumb */
	if( newvalue != oldvalue ) {
	    oldvalue = newvalue;
	    *numvar = newvalue;
	    sl_x( base, newvalue, min, max );
	/* undraw old */
	    Objc_draw( tree, base, 0, &slidrect );
	/* draw new */
	    objc_offset( tree, slider, &slidrect.g_x, &slidrect.g_y );
	    slidrect.g_x--;
	    slidrect.g_y--;
	    Objc_draw( tree, base, MAX_DEPTH, &slidrect );
	    evnt_timer( delay, 0 );
	    if( delay > SL_MIN_DELAY )
		delay -= SL_INC;
        }
	Graf_mkstate( &mk );
    } while( mk.buttons != 0 );

    if( obj > 0 )
	deselect( tree, obj );
    Objc_draw( tree, base, MAX_DEPTH, &slidrect );
}


void
sl_drag( int base, int min, int max, int *numvar )
{
    OBJECT *tree = rs_object;
    int slider = ObHead(base);
    int newvalue, xoffset, slidx, lastvalue;
    MRETS mk;
    GRECT baserect, slidrect;

    newvalue = *numvar;

/* get slider extent */
    baserect = ObRect( base );
    objc_offset( tree, base, &baserect.g_x, &baserect.g_y );

/* get slide box extent */
    slidrect = ObRect( slider );
    objc_offset( tree, slider, &slidrect.g_x, &slidrect.g_y );
/* find mouse offset into slide box */
    Graf_mkstate( &mk );
    xoffset = mk.x - (slidrect.g_x + (slidrect.g_w / 2));
/* adjust box w/h for clip */
    slidrect.g_x--;
    slidrect.g_y--;
    slidrect.g_w += 2;
    slidrect.g_h += 2;

    lastvalue = min-1;
    while( mk.buttons != 0 ) {
    /* get current slide box X coordinate */
	slidx = mk.x - xoffset;
    /* translate it to a value */
	if( slidx < baserect.g_x + ObW(slider)/2 )
	    newvalue = min;
	else if( slidx > baserect.g_x + baserect.g_w - ObW(slider)/2 )
	    newvalue = max;
	else {
	    newvalue = min + (int)( ( (long)(max-min) *
	    		       (long)(slidx-baserect.g_x-ObW(slider)/2) * 1000L ) /
	    		      ((long)(baserect.g_w - ObW(slider))
	    		        * 1000L) );
	}
	if( newvalue != lastvalue ) {
	    lastvalue = newvalue;
        /* update the value, and draw the slidebox */
	    sl_x( base, newvalue, min, max );
        /* undraw old */
	    Objc_draw( tree, base, 2, &slidrect );
	    objc_offset( tree, slider, &slidrect.g_x, &slidrect.g_y );
            slidrect.g_x--;
            slidrect.g_y--;
       /* draw new */
	    Objc_draw( tree, slider, 2, &slidrect );
	}
	Graf_mkstate( &mk );
    }
    *numvar = newvalue;
}


void
wait_bup( void )
{
    MRETS mk;
    do { Graf_mkstate( &mk ); } while( mk.buttons != 0 );
}

/* show configuration dial, return 1 to cancel installation */
int
configure( void )
{
    OBJECT *tree = rs_object;
    int quit = 0;
    int x, y, w, h, ox, oy;
    MRETS mk;
    int savelinear, saveudset, savetime, saveptime;

    if( ma_info == &start ) /* ma_info points at our start */
	ObString(OK) = (char *)(rs_frstr[INSTRING]);

/* set accel buttons */
    savelinear = ma_info->linear;
    set_accelbox( savelinear );
/* set screensave buttons */
    saveudset = ma_info->udset;
    set_screenbox( saveudset );
    savetime = (ma_info->timeout)/3600;
    sl_x( SAVEBOX, savetime, SAVE_MIN, SAVE_MAX );
    /* set modem switch */
    if( ma_info->watch ) {
	Select(MODEM);
    } else {
	Deselect(MODEM);
    }
/* set stacy options box */
    if( ma_info->stacy ) {
	ObFlags( SWITCH ) = ObFlags( LITE ) = TOUCHEXIT;
    	if( ma_info->stacmask & SH_SCREEN ) Select( SWITCH );
    	if( ma_info->stacmask & SH_LIGHT ) Select( LITE );
    } else {
	ObFlags(SWITCH) = ObFlags(LITE) = NONE;
	ObState(SWITCH) = ObState(LITE) = DISABLED; /* deselects */
    }

/* set up park box */
    Supexec((long(*)())get_parktime);
    if( parktime >= 0 ) parktime = ma_info->savepark;
    saveptime = parktime;
    if( saveptime == 0 ) saveptime = 1;
    set_parkbox();
    if( parktime >= 0 )
    	sl_x( PARKBOX, parktime, PARK_MIN, PARK_MAX );
    	

/* set appropriate icons */
    graf_handle( &x, &y, &w, &h );
    if( y < 16 ) {
    /* if char cell is < 16 pixels high, use 8 pixel icons */
	ObSpec(IACCOFF).bitblk = (BITBLK *)(rs_frimg[ACCOFF8]);
	ObSpec(IACCSLOW).bitblk = (BITBLK *)(rs_frimg[ACCSLOW8]);
	ObSpec(IACCFAST).bitblk = (BITBLK *)(rs_frimg[ACCFAST8]);
	ObSpec(ISCREEN).bitblk = (BITBLK *)(rs_frimg[SCREEN8]);
	ObSpec(SAVEUP).bitblk = (BITBLK *)(rs_frimg[TIMEHI8]);
	ObSpec(SAVEDOWN).bitblk = (BITBLK *)(rs_frimg[TIMELO8]);
	ObSpec(IMODEM).bitblk = (BITBLK *)(rs_frimg[MODEM8]);
	ObSpec(IPARK).bitblk = (BITBLK *)(rs_frimg[PARK8]);
	ObSpec(PARKUP).bitblk = (BITBLK *)(rs_frimg[TIMEHI8]);
	ObSpec(PARKDOWN).bitblk = (BITBLK *)(rs_frimg[TIMELO8]);
	ObSpec(ILITE).bitblk = (BITBLK *)(rs_frimg[LITE8]);
	ObSpec(ISWITCH).bitblk = (BITBLK *)(rs_frimg[SCREEN8]);
    }

    form_center( rs_object, &x, &y, &w, &h );
    form_dial( FMD_START, 0, 0, 0, 0, x, y, w, h );
    form_dial( FMD_GROW, 0, 0, 0, 0, x, y, w, h );
    objc_draw( tree, 0, MAX_DEPTH, x, y, w, h );
    graf_mouse( ARROW, 0L );
    do {
	switch( form_do( rs_object, 0 ) & 0x7fff ) {
	case LITE:
	    if( IsSelected(LITE) ) { /* deselecting */
	    /* don't allow user to select screensave without litesave */
	    	Deselect(SWITCH);
	    	Deselect(LITE);
	    } else {
	    	Select(LITE);
	    }
	    Objc_draw( tree, STACOPTS, MAX_DEPTH, NULL );
	    break;
	case SWITCH:
	    if( IsSelected(SWITCH) ) { /* deselecting */
	    	Deselect(SWITCH);
	    } else {
	    /* don't allow user to select screensave without litesave */
		Select(LITE);
		Select(SWITCH);
	    }
	    Objc_draw( tree, STACOPTS, MAX_DEPTH, NULL );
	    break;
	case SCREEN:
	/* floggle the bit */
	    ma_info->udset ^= 1;
	    ma_info->updown = ma_info->udset;
	    set_screenbox( ma_info->udset );
	    Objc_draw( tree, SCRNSECT, MAX_DEPTH, NULL);
	    break;
	case ACCOFF:
	    ma_info->linear = -1;
	    break;
	case ACCSLOW:
	    ma_info->linear = 1;
	    break;
	case ACCFAST:
	    ma_info->linear = 0;
	    break;
	case SAVEUP:
	    sl_arrow( SAVEBOX, SAVEUP, 1, SAVE_MIN, SAVE_MAX, &savetime );
	    break;
	case SAVEDOWN:
	    sl_arrow( SAVEBOX, SAVEDOWN, -1, SAVE_MIN, SAVE_MAX, &savetime );
	    break;
	case SAVESLID:
	    sl_drag( SAVEBOX, SAVE_MIN, SAVE_MAX, &savetime );
	    break;
	case SAVEBOX:
    	    Graf_mkstate( &mk );
    	    objc_offset( tree, SAVESLID, &ox, &oy );
    	    if( mk.x < ox )
    	    	oy = -SAVE_PAGE;
    	    else
    	        oy = SAVE_PAGE;
	    sl_arrow( SAVEBOX, -1, oy, SAVE_MIN, SAVE_MAX, &savetime );
	    break;
	case PARK:
	    if( IsSelected( PARK ) ) { /* deselecting */
		saveptime = parktime;
	    	parktime = 0;
	    } else {
	    	parktime = saveptime;
		sl_x( PARKBOX, parktime, PARK_MIN, PARK_MAX );
	    }
	    set_parkbox();
	    Objc_draw( tree, PARKSECT, MAX_DEPTH, NULL );
	    break;
	case PARKUP:
	    sl_arrow( PARKBOX, PARKUP, 1, PARK_MIN, PARK_MAX, &parktime );
	    break;
	case PARKDOWN:
	    sl_arrow( PARKBOX, PARKDOWN, -1, PARK_MIN, PARK_MAX, &parktime );
	    break;
	case PARKSLID:
	    sl_drag( PARKBOX, PARK_MIN, PARK_MAX, &parktime );
	    break;
	case PARKBOX:
    	    Graf_mkstate( &mk );
    	    objc_offset( tree, PARKSLID, &ox, &oy );
    	    if( mk.x < ox )
    	    	oy = -PARK_PAGE;
    	    else
    	        oy = PARK_PAGE;
	    sl_arrow( PARKBOX, -1, oy, PARK_MIN, PARK_MAX, &parktime );
	    break;
	case SAVE:
	    save_conf( savetime );
	    rs_object[SAVE].ob_state = NORMAL;
	    Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
	    break;
	case OK:
	    quit = OK;
	    break;
	case CANCEL:
	    quit = CANCEL;
	    break;
	}
	/* delay after touchexit objects */
	wait_bup();
    } while (!quit);


    form_dial( FMD_SHRINK, 0, 0, 0, 0, x, y, w, h );
    form_dial( FMD_FINISH, 0, 0, 0, 0, x, y, w, h );

    if( quit == CANCEL ) {
	ma_info->updown = ma_info->udset = saveudset;
	ma_info->linear = savelinear;
    } else {
    	if( IsSelected(MODEM) ) ma_info->watch = 1;
    	else ma_info->watch = 0;
	if( ma_info->stacy ) {
	    if( IsSelected(SWITCH) ) {
		ma_info->stacmask |= SH_SCREEN;
	    } else {
		ma_info->stacmask &= ~SH_SCREEN;
	    }
	    if( IsSelected(LITE) ) {
		ma_info->stacmask |= SH_LIGHT;
	    } else {
		ma_info->stacmask &= ~SH_LIGHT;
	    }
	}
 
	ma_info->timeout = savetime * 3600;
	ma_info->savepark = parktime;
	Supexec((long(*)())set_ptime);
    }
    return (quit == CANCEL);
}
