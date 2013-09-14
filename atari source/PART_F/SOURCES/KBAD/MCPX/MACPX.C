/* macpx.c - mouse accelerator CPX
 * =================================================================
 * 900503 kbad arose from the ashes of maccel3
 */

/* INCLUDE FILES
 * ================================================================
 */
#include <string.h>
#include <tos.h>
#include <sys\gemskel.h>

#include "maccel.h"
#pragma warn -apt		   /* 1 Non-portable pointer assignment */
#pragma warn -rpt		   /* 1 Non-portable pointer conversion */
#include "maccel.rsh"
#pragma warn .apt
#pragma warn .rpt
#include "..\cpxdata.h"


/* PROTOTYPES
 * ================================================================
 */
CPXINFO * cdecl cpx_init( XCPB *Xcpb );
BOOLEAN  cdecl cpx_call( GRECT *rect );


/* DEFINES
 * ================================================================
 */
#define COOKIE	    0xAA006EL

/* slider min and max values */
#define SCRN_MIN    1
#define SCRN_MAX    9
#define SCRN_PAGE   1
#define PARK_MIN    1
#define PARK_MAX    30
#define PARK_PAGE   5
/* slider time delay definitions */
#define SL_MAX_DELAY 150
#define SL_MIN_DELAY 50
#define SL_INC	     10

/* bits in SHADOW */
#define SH_SCREEN   '\004'
#define SH_LIGHT    '\010'

typedef struct _ma_info {
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
} MA_INFO;

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


/* EXTERNALS
 * ================================================================
 */
extern MA_INFO save_info;


/* GLOBALS
 * ================================================================
 */
XCPB *xcpb;
CPXINFO cpxinfo;

MA_INFO *ma_info, ma_work, ma_cancel;
int	parktime;
int	ma_installed;
int	sl_time;
BOOLEAN dodelay;
char	*alertbox;

/* FUNCTIONS
 * ================================================================
 */

/*
 * 2 digit itoa
 */
void
itoa2( int n, char *s )
{
    *s++ = n / 10 + '0';
    *s++ = n % 10 + '0';
    *s = 0;
}

/*
 * Get autopark timeout from HD driver pun structure
 */
void
get_ptime( void )
{
    if( pun_ptr->cookie == 0x41484449L &&
    	pun_ptr->cookptr == &(pun_ptr->cookie) &&
    	pun_ptr->idle.flag == 0xff )
	parktime = (int)((pun_ptr->idle.time & 0xffffffL) / 12000L);
    else parktime = -1;
}


/*
 * Set autopark timeout in HD driver pun structure
 */
void
set_ptime( void )
{
    if( parktime >= 0 &&
	pun_ptr->cookie == 0x41484449L && /*AHDI*/
    	pun_ptr->cookptr == &(pun_ptr->cookie) )
        pun_ptr->idle.time = (parktime * 12000L) | 0xff000000L;
}


/*
 * Update MA_INFO structure from local data.
 */
void
set_info( MA_INFO *dst, MA_INFO *src )
{
    dst->updown = dst->udset = src->udset;
    dst->linear = src->linear;
    dst->watch = src->watch;
    if( dst->stacy )
	dst->stacmask = src->stacmask;
    dst->timeout = src->timeout;
    dst->savepark = src->savepark;
    Supexec( (long(*)())set_ptime );
}


/*
 * Initialize CPX
 */
CPXINFO * cdecl
cpx_init( XCPB *Xcpb )
{
    OBJECT *tree;
    xcpb = Xcpb;

    ma_installed = xcpb->getcookie( COOKIE, (long *)(&ma_info) );

    if( xcpb->booting )
    {
	Supexec( (long(*)())get_ptime );
      /* Read in defaults and set the options */
	if( ma_installed )
	    set_info( ma_info, &save_info );
    }
    else
    {
      if( !xcpb->SkipRshFix )
      {
           xcpb->rsh_fix( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE, rs_object,
			  rs_tedinfo, rs_strings, rs_iconblk, rs_bitblk,
			  rs_frstr, rs_frimg, rs_trindex, rs_imdope );
           tree = (OBJECT *)rs_trindex[MACCEL];
	   switch (xcpb->Country_Code) {
	   case CP_FRG:
		ObString(OK) = (char *)rs_frstr[FRGOK];
                ObString(CANCEL) = (char *)rs_frstr[FRGCAN];
                ObString(SAVE) = (char *)rs_frstr[FRGSAVE];
		alertbox = (char *)rs_frstr[FRGLOAD];
	   break;
	   case CP_FRA:
		ObString(OK) = (char *)rs_frstr[FRAOK];
                ObString(CANCEL) = (char *)rs_frstr[FRACAN];
                ObString(SAVE) = (char *)rs_frstr[FRASAVE];
		alertbox = (char *)rs_frstr[FRALOAD];
	   break;
           case CP_SPA:
		ObString(OK) = (char *)rs_frstr[SPAOK];
                ObString(CANCEL) = (char *)rs_frstr[SPACAN];
                ObString(SAVE) = (char *)rs_frstr[SPASAVE];
		alertbox = (char *)rs_frstr[SPALOAD];
	   break;
           case CP_ITA:
		ObString(OK) = (char *)rs_frstr[ITAOK];
                ObString(CANCEL) = (char *)rs_frstr[ITACAN];
                ObString(SAVE) = (char *)rs_frstr[ITASAVE];
		alertbox = (char *)rs_frstr[ITALOAD];
	   break;
           case CP_SWE:
		ObString(OK) = (char *)rs_frstr[SWEOK];
                ObString(CANCEL) = (char *)rs_frstr[SWECAN];
                ObString(SAVE) = (char *)rs_frstr[SWESAVE];
		alertbox = (char *)rs_frstr[SWELOAD];
	   break;
	   default:
	   	alertbox = (char *)rs_frstr[NOLOAD];
	   }
      }
      cpxinfo.cpx_call   = cpx_call;
      cpxinfo.cpx_draw   = NULL;
      cpxinfo.cpx_wmove  = NULL;
      cpxinfo.cpx_timer  = NULL;
      cpxinfo.cpx_key    = NULL;
      cpxinfo.cpx_button = NULL;
      cpxinfo.cpx_m1 	 = NULL;
      cpxinfo.cpx_m2	 = NULL;
      cpxinfo.cpx_hook   = NULL;
      cpxinfo.cpx_close  = NULL;
    }

    return &cpxinfo;
}


/*
 * Set MA speed buttons
 */
void
set_accelbox( OBJECT *tree, int linear )
{
    Deselect(OFF);
    Deselect(SLOW);
    Deselect(FAST);

    if( linear < 0 )
	Select(OFF);
    else if( linear > 0 )
	Select(SLOW);
    else
	Select(FAST);
}

/*
 * Delay for slider auto-repeat.
 */
void
sl_delay( void )
{
    evnt_timer( sl_time, 0 );
    if( sl_time > SL_MIN_DELAY )
	sl_time -= SL_INC;
}


/*
 * Update and redraw thumb text of screensave timeout slider.
 */
void
update_screenbox( void )
{
    OBJECT *tree  = (OBJECT *)rs_trindex[MACCEL];

    if( dodelay ) sl_delay();
    TedText(SCRNTHUM)[0] = '0' + ma_work.timeout;
    Objc_draw( tree, SCRNTHUM, MAX_DEPTH, NULL );
}

/*
 * Set up buttons and covers in screensave box.
 */
void
set_screenbox( OBJECT *tree, int enabled )
{
    if( !ma_info->stacy )
    	HideObj(STACBOX);
    else
    	ShowObj(STACBOX);

    if( enabled ) {
	Select(SCRN);
	ObFlags(STACSCRN) = ObFlags(STACLITE) = TOUCHEXIT;
	ObState(STACSCRN) =
	  ObState(STACLITE) =
	  ObState(SCRNUP) =
	  ObState(SCRNBACK) =
	  ObState(SCRNTHUM) =
	  ObState(SCRNDN) =
	  ObState(PHONE) = NORMAL;
	HideObj(SCRNCOVR);
    } else {
	Deselect(SCRN);
	ObFlags(STACSCRN) = ObFlags(STACLITE) = NONE;
	ObState(STACSCRN) =
	  ObState(STACLITE) =
	  ObState(SCRNUP) =
	  ObState(SCRNBACK) =
	  ObState(SCRNTHUM) =
	  ObState(SCRNDN) =
	  ObState(PHONE) = DISABLED;
	ShowObj(SCRNCOVR);
    }

}

/*
 * Update and redraw thumb text of autopark timeout slider.
 */
void
update_parkbox( void )
{
    OBJECT *tree  = (OBJECT *)rs_trindex[MACCEL];

    if( dodelay ) sl_delay();
    itoa2( ma_work.savepark, TedText(PARKTHUM) );
    Objc_draw( tree, PARKTHUM, MAX_DEPTH, NULL );
}


/*
 * Set up buttons and covers in autopark box.
 */
void
set_parkbox( OBJECT *tree )
{
extern int parktime;

    if( parktime < 0 ) {
	HideObj(PARKBOX);
    } else if( parktime > 0 ) {
	Select(PARK);
	ObState(PARKUP) =
	  ObState(PARKBACK) =
	  ObState(PARKTHUM) =
	  ObState(PARKDN) = NORMAL;
	HideObj(PARKCOVR);
    } else {
	Deselect(PARK);
	ObState(PARKUP) =
	  ObState(PARKBACK) =
	  ObState(PARKTHUM) =
	  ObState(PARKDN) = DISABLED;
	ShowObj(PARKCOVR);
    }
}

/*
 * Update MA_INFO struct from buttons in form.
 */
void
update_info( OBJECT *tree, MA_INFO *info )
{
    if( info->stacy )
    {
	if( IsSelected(STACSCRN) )
	    info->stacmask |= SH_SCREEN;
	else
	    info->stacmask &= ~SH_SCREEN;
	if( IsSelected(STACLITE) )
	    info->stacmask |= SH_LIGHT;
	else
	    info->stacmask &= ~SH_LIGHT;
    }

    if( IsSelected(PHONE) )
	info->watch = TRUE;
    else
    	info->watch = FALSE;

}




/*
 * CPX user interaction
 */
BOOLEAN cdecl
cpx_call( GRECT *rect )
{
    OBJECT *tree  = (OBJECT *)rs_trindex[MACCEL];

    int	    button;
    int	    quit = 0;
    int	    saveptime;
    WORD    msg[8];
    MA_INFO *src;

    int ox, oy;
    MRETS mk;

    if( !ma_installed )
    {
	form_alert( 1, alertbox );
	return FALSE;
    }

    ma_work = ma_cancel = *ma_info;

    ObX( ROOT ) = rect->g_x;
    ObY( ROOT ) = rect->g_y;

    set_accelbox( tree, ma_info->linear );

    set_screenbox( tree, ma_info->udset );
    ma_work.timeout /= 3600;
    ma_cancel.timeout /= 3600;
    xcpb->Sl_x( tree, SCRNBACK, SCRNTHUM, ma_work.timeout,
		SCRN_MIN, SCRN_MAX, NULLFUNC );
    TedText(SCRNTHUM)[0] = '0' + ma_work.timeout;
    if( ma_info->watch )
	Select(PHONE);
    else
	Deselect(PHONE);

    if( ma_info->stacy )
    {
	ObFlags(STACSCRN) = ObFlags(STACLITE) = TOUCHEXIT;
	if( ma_info->stacmask & SH_SCREEN ) Select( STACSCRN );
	if( ma_info->stacmask & SH_LIGHT ) Select( STACLITE );
    } else {
	ObFlags(STACSCRN) = ObFlags(STACLITE) = NONE;
	ObState(STACSCRN) = ObState(STACLITE) = DISABLED; /* deselects */
    }

    Supexec( (long(*)())get_ptime );
    saveptime = ma_work.savepark = parktime;
    if( saveptime == 0 ) saveptime = 1;
    set_parkbox( tree );
    if( parktime >= 0 )
    {
	xcpb->Sl_x( tree, PARKBACK, PARKTHUM, parktime,
		    PARK_MIN, PARK_MAX, NULLFUNC );
	itoa2( ma_work.savepark, TedText(PARKTHUM) );

    }

    Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
    do
    {
	dodelay = FALSE;
	sl_time = SL_MAX_DELAY;
	button = xcpb->Xform_do( tree, 0, msg );
	if( button == -1 )
	    if( msg[0] == AC_CLOSE )
		button = CANCEL;
	    else if( msg[0] == WM_CLOSED )
		button = OK;
	else
	    button &= 0x7fff;

	switch( button )
	{
	    case OK:
		src = &ma_work;
		update_info( tree, src );
	    	quit = OK;
	    break;

	    case CANCEL:
		src = &ma_cancel;
		quit = CANCEL;
	    break;

	    case SAVE:
		if( xcpb->XGen_Alert( SAVE_DEFAULTS ) )
		{
		    src = &ma_work;
		    update_info( tree, src );
		    src->timeout *= 3600;
		    if( xcpb->CPX_Save( src, sizeof(MA_INFO) ) )
		    {
			set_info( ma_info, src );
			src->timeout /= 3600;
			ma_cancel = ma_work;
		    }
		    else
		    {
			src->timeout /= 3600;
		    }
		}
		deselect( tree, SAVE );
	    break;

	    case OFF:
		ma_work.linear = ma_info->linear = -1;
	    break;
	    case SLOW:
		ma_work.linear = ma_info->linear = 1;
	    break;
	    case FAST:
		ma_work.linear = ma_info->linear = 0;
	    break;

	    case PARK:
		if( IsSelected(PARK) ) /* deselecting */
		{
		    saveptime = ma_work.savepark;
		    ma_work.savepark = 0;
		}
		else
		{
		    ma_work.savepark = saveptime;
		    xcpb->Sl_x( tree, PARKBACK, PARKTHUM, parktime,
				PARK_MIN, PARK_MAX, update_parkbox );
		}
		set_parkbox( tree );
		Objc_draw( tree, PARKBOX, MAX_DEPTH, NULL );
	    break;
	    case PARKUP:
		dodelay = TRUE;
		xcpb->Sl_arrow( tree, PARKBACK, PARKTHUM, PARKUP,
				1, PARK_MIN, PARK_MAX, &ma_work.savepark,
				HORIZONTAL, update_parkbox );
	    break;
	    case PARKDN:
		dodelay = TRUE;
		xcpb->Sl_arrow( tree, PARKBACK, PARKTHUM, PARKDN,
				-1, PARK_MIN, PARK_MAX, &ma_work.savepark,
				HORIZONTAL, update_parkbox );
	    break;
	    case PARKTHUM:
		xcpb->Sl_dragx( tree, PARKBACK, PARKTHUM, PARK_MIN, PARK_MAX,
				&ma_work.savepark, update_parkbox );
	    break;
	    case PARKBACK:
		dodelay = TRUE;
		Graf_mkstate( &mk );
		objc_offset( tree, PARKTHUM, &ox, &oy );
		if( mk.x < ox )
		    oy = -PARK_PAGE;
		else
		    oy = PARK_PAGE;
		xcpb->Sl_arrow( tree, PARKBACK, PARKTHUM, -1, oy,
				PARK_MIN, PARK_MAX, &ma_work.savepark,
				HORIZONTAL, update_parkbox );
	    break;

	    case SCRN:
		ma_work.udset ^= 1;		
		set_screenbox( tree, ma_work.udset );
		Objc_draw( tree, SCRNBOX, MAX_DEPTH, NULL );
	    break;
	    case SCRNUP:
		dodelay = TRUE;
		xcpb->Sl_arrow( tree, SCRNBACK, SCRNTHUM, SCRNUP,
				1, SCRN_MIN, SCRN_MAX, &ma_work.timeout,
				HORIZONTAL, update_screenbox );
	    break;
	    case SCRNDN:
		dodelay = TRUE;
		xcpb->Sl_arrow( tree, SCRNBACK, SCRNTHUM, SCRNDN,
				-1, SCRN_MIN, SCRN_MAX, &ma_work.timeout,
				HORIZONTAL, update_screenbox );
	    break;
	    case SCRNTHUM:
		xcpb->Sl_dragx( tree, SCRNBACK, SCRNTHUM, SCRN_MIN, SCRN_MAX,
				&ma_work.timeout, update_screenbox );
	    break;
	    case SCRNBACK:
		dodelay = TRUE;
		Graf_mkstate( &mk );
		objc_offset( tree, SCRNTHUM, &ox, &oy );
		if( mk.x < ox )
		    oy = -SCRN_PAGE;
		else
		    oy = SCRN_PAGE;
		xcpb->Sl_arrow( tree, SCRNBACK, SCRNTHUM, -1, oy,
				SCRN_MIN, SCRN_MAX, &ma_work.timeout,
				HORIZONTAL, update_screenbox );
	    break;


     	}

    } while (!quit);
    Deselect(quit);

    src->timeout *= 3600;
    set_info( ma_info, src );

    return FALSE;
}
