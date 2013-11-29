/*
 * Konfigurations-CPX fÅr BubbleGEM 07
 * tm 98-04-28
 *
 */

#include	<PORTAB.H>
#include <STDIO.H>
#include	<TOS.H>
#include <AES.H>
#include <VDI.H>
#include <string.h>

#define FALSE 0
#define TRUE  1

/* define ENGLISH */

#define BHLP_DEFAULT 0x00c8ffffL
#define BHLP_DEFMASK 0x0000ffe0L
#define BGEM_DEFAULT 0L

#define BGC_FONTCHANGED 0x00000001L;
#define BGC_NOWINSTYLE  0x00000002L;
#define BGC_SENDKEY     0x00000004L;
#define BGC_DEMONACTIVE 0x00000008L;
#define BGC_TOPONLY     0x00000010L;

#define BUBBLEGEM_REQUEST 0xbaba

#ifndef	EXTERN
#define	EXTERN	extern
#endif

#include "CPXDATA.H"

#define	max( A,B ) ( (A)>(B) ? (A) : (B) )
#define	min( A,B ) ( (A)<(B) ? (A) : (B) )


typedef struct
{
	long id;
	long value;
} COOKIE;


typedef struct
{
	long   magic;
	long   size;
	int    release;
	int    active;
	MFORM *mhelp;
	int    dtimer;
} BGEM;


long getjar(void);
int  new_cookie(long id, long value);
int  remove_cookie(long id);

WORD open_screen_wk( WORD aes_handle, WORD *work_out );
CPXINFO *cdecl cpx_init( XCPB *Xcpb );
WORD	cdecl	cpx_call( GRECT *rect );
void	redraw_obj(OBJECT *tree, WORD obj);
WORD	rc_intersect( GRECT *p1, GRECT *p2 );
void  send_request(void);
void	read_config( void );
void	set_config( void );
WORD	handle_button( WORD button, WORD *msg );


extern	LONG save_vars;
extern	WORD bg_fontchg;
extern	WORD bg_nowinstyle;
extern  WORD bg_sendkey;
extern  WORD bg_demonactive;
extern  WORD bg_toponly;
extern  WORD bg_opentime;
extern  WORD bg_closetime;

WORD		v_handle;
OBJECT	*cpx_tree;
USERBLK	user;
char    *helpdemon;

XCPB		*xcpb;

CPXINFO	cpxinfo =
{
	cpx_call,
	0L,
	0L,
	0L,
	0L,
	0L,
	0L,
	0L,
	0L,
	0L
};


#ifdef ENGLISH
#include "BUBGEM_E.RH" 
#include "BUBGEM_E.RSH"
#else
#include "BUBBLGEM.RH" 
#include "BUBBLGEM.RSH"
#endif

#include	"ADAPTRSC.H"

#define	fstring_addr	rs_frstr

WORD	aes_handle;
WORD	pwchar;
WORD	phchar;
WORD	pwbox;
WORD	phbox;
WORD	aes_flags;
WORD	aes_font;
WORD	aes_height;

WORD	vdi_handle;
WORD	work_out[57];



CPXINFO * cdecl cpx_init(XCPB *Xcpb)
{
	extern XCPB		*xcpb;
	long   bhlp,bgem;

	xcpb = Xcpb;

	if ( xcpb->booting )
	{
		if (!xcpb->getcookie((LONG) 'BHLP', &bhlp)) bhlp = BHLP_DEFAULT;

		bhlp &= BHLP_DEFMASK;

		if (bg_fontchg)     bhlp |= BGC_FONTCHANGED;
		if (bg_nowinstyle)  bhlp |= BGC_NOWINSTYLE;
		if (bg_sendkey)     bhlp |= BGC_SENDKEY;
		if (bg_demonactive) bhlp |= BGC_DEMONACTIVE;
		if (bg_toponly)     bhlp |= BGC_TOPONLY;
		
		bhlp |= ((long)bg_closetime << 16);

		remove_cookie('BHLP');
		new_cookie('BHLP',bhlp);
		send_request();

		if (xcpb->getcookie((LONG) 'BGEM', &bgem))
		{
			if (bgem)
			{
				if (((BGEM *)bgem)->magic == 'BGEM')
				{
					if (((BGEM *)bgem)->size >= 18)
					{
						((BGEM *)bgem)->dtimer = bg_opentime;
					}
				}
			}
		}

		return((CPXINFO *) 1 );
	}
	else
	{
	    cpx_tree = (OBJECT *) rs_trindex[BGMAIN];
	
			if ( xcpb->SkipRshFix == 0 )
			{
				WORD	i;
	
				for ( i = 0; i < NUM_OBS; i++ )
					xcpb->rsh_obfix( cpx_tree, i );
			}
			
			if (!xcpb->getcookie((LONG) 'BHLP', 0L))
			{
				bhlp = (BHLP_DEFAULT & BHLP_DEFMASK);
				
				if (bg_fontchg)     bhlp |= BGC_FONTCHANGED;
				if (bg_nowinstyle)  bhlp |= BGC_NOWINSTYLE;
				if (bg_sendkey)     bhlp |= BGC_SENDKEY;
				if (bg_demonactive) bhlp |= BGC_DEMONACTIVE;
				if (bg_toponly)     bhlp |= BGC_TOPONLY;

				bhlp |= ((long)bg_closetime << 16);

				new_cookie('BHLP',bhlp);

				if (xcpb->getcookie((LONG) 'BGEM', &bgem))
				{
					if (bgem)
					{
						if (((BGEM *)bgem)->magic == 'BGEM')
						{
							if (((BGEM *)bgem)->size >= 18)
							{
								((BGEM *)bgem)->dtimer = bg_opentime;
							}
						}
					}
				}

				send_request();
			}
	}
	return( &cpxinfo );
}


void send_request(void)
{
	int bid = appl_find("BUBBLE  ");
	
	if (bid >= 0)
	{
		int pipe[8];
		
		pipe[0] = BUBBLEGEM_REQUEST;
		pipe[1] = 0;
		pipe[2] = 0;
		pipe[3] = 0;
		pipe[4] = 0;
		pipe[5] = 0;
		pipe[6] = 0;
		pipe[7] = 0;
		
		appl_write(bid,16,pipe);
	}
}


void itoa(int i, char *c)
{
	if (i <= 0) strcpy(c,"0");
	else
	{
		char *cn = c;

		while (i != 0)
		{
			*cn++ = (i % 10) + '0';
			i /= 10;
		}

		*cn=0;
		
		strrev(c);
	}
}


int atoi(char *c)
{
	int ret = 0;

	if (c)
	{
		while (*c)
		{
			if ((*c < '0') || (*c > '9')) break;
			
			ret = ret*10 + *c++ - '0';
		}
	}

	return(ret);
}


void read_config( void )
{
	long bhlp;

	if (!xcpb->getcookie((LONG) 'BHLP', &bhlp)) bhlp = BHLP_DEFAULT;
	
	if (bhlp & 0x0001)
		Select(BGMFONTCHANGED);
	else
		Deselect(BGMFONTCHANGED);

	if (bhlp & 0x0002)
		Select( BGMBUBBLES );
	else
		Select( BGMWINSTYLE );

	if (bhlp & 0x0004)
		Select(BGMSENDKEY);
	else
		Deselect(BGMSENDKEY);

	if (bhlp & 0x0008)
		Select(BGMDEMON);
	else
		Deselect(BGMDEMON);

	if (bhlp & 0x0010)
		Select(BGMTOPONLY);
	else
		Deselect(BGMTOPONLY);

	itoa(bg_opentime,rs_object[BGMOPEN].ob_spec.tedinfo->te_ptext);
	itoa(bg_closetime,rs_object[BGMCLOSE].ob_spec.tedinfo->te_ptext);
}


void set_config( void )
{
	long bhlp,bgem;

	bg_fontchg     = IsSelected(BGMFONTCHANGED) ? 1 : 0;
	bg_nowinstyle  = IsSelected(BGMBUBBLES)     ? 1 : 0;
	bg_sendkey     = IsSelected(BGMSENDKEY)     ? 1 : 0;
	bg_demonactive = IsSelected(BGMDEMON)       ? 1 : 0;
	bg_toponly     = IsSelected(BGMTOPONLY)     ? 1 : 0;

	bg_opentime    = max(10,atoi(rs_object[BGMOPEN].ob_spec.tedinfo->te_ptext));
	bg_closetime   = atoi(rs_object[BGMCLOSE].ob_spec.tedinfo->te_ptext);

	if (!xcpb->getcookie((LONG) 'BHLP', &bhlp)) bhlp = BHLP_DEFAULT;

	bhlp &= BHLP_DEFMASK;

	if (bg_fontchg)     bhlp |= BGC_FONTCHANGED;
	if (bg_nowinstyle)  bhlp |= BGC_NOWINSTYLE;
	if (bg_sendkey)     bhlp |= BGC_SENDKEY;
	if (bg_demonactive) bhlp |= BGC_DEMONACTIVE;
	if (bg_toponly)     bhlp |= BGC_TOPONLY;

	bhlp |= ((long)bg_closetime << 16);

	remove_cookie('BHLP');
	new_cookie('BHLP',bhlp);

	if (xcpb->getcookie((LONG) 'BGEM', &bgem))
	{
		if (bgem)
		{
			if (((BGEM *)bgem)->magic == 'BGEM')
			{
				if (((BGEM *)bgem)->size >= 18)
				{
					((BGEM *)bgem)->dtimer = bg_opentime;
				}
			}
		}
	}

	send_request();
}


void redraw_obj( OBJECT *tree, WORD obj )
{
	GRECT *clip_p;
	GRECT	clip;
	GRECT xywh;
	GRECT full;

	wind_get( 0, WF_WORKXYWH, &full.g_x, &full.g_y,
					&full.g_w, &full.g_h);

	objc_offset( tree, ROOT ,&xywh.g_x, &xywh.g_y);
	xywh.g_w = tree->ob_width;
	xywh.g_h = tree->ob_height;

	
	clip_p = xcpb->GetFirstRect( &xywh );

	while( clip_p )
	{
		clip = *clip_p;
		
		if( rc_intersect(&full, &clip) )
			objc_draw(tree,obj,MAX_DEPTH,clip.g_x,clip.g_y,clip.g_w,clip.g_h);
		
		clip_p = xcpb->GetNextRect();
	}
}

WORD rc_intersect( GRECT *p1, GRECT *p2 )
{
	WORD tx, ty, tw, th;

	tw = min( p2->g_x + p2->g_w, p1->g_x + p1->g_w );
	th = min( p2->g_y + p2->g_h, p1->g_y + p1->g_h );
	tx = max( p2->g_x, p1->g_x );
	ty = max( p2->g_y, p1->g_y );
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
	return( (tw > tx) && (th > ty) );
}

WORD handle_button( WORD button, WORD *msg )
{
	WORD quit = FALSE;
	/*
	 *	button: -1 		: msg[] enthÑlt ein auszuwertende Nachricht
	 *			  sonst	: Nummer des angeklickten Objekts
	 *						  (gesetzes Bit 15: Doppelklick auf Objekt)
	 */	
	if( button != -1 ) button &= 0x7fff; /* Doppelklick interessiert nicht */
	
	switch( button )
	{
		case BGMOK:
		{
			Deselect( BGMOK );
			set_config( );
			quit = TRUE;
			break;
		}
		case BGMCANCEL: 
		{
			Deselect( BGMCANCEL );
			quit = TRUE;
			break;
		}
		case BGMSAVE:
		{
			set_config( );
			xcpb->CPX_Save( &save_vars, 14 );
			Deselect( BGMSAVE );
			redraw_obj( cpx_tree,BGMSAVE );
			break;
		}
   	case -1:	
  		 {
  		   switch( msg[0] )
  		   {
				case AC_CLOSE:
					quit = TRUE;
					break;
				case WM_CLOSED:
					set_config( );
					quit = TRUE;
					break;
			}
		}
	}

	return( quit );
}


WORD cdecl cpx_call( GRECT *rect )
{
	extern WORD	vdi_handle;
	extern WORD	work_out[57];
	WORD	hor_3d;
	WORD	ver_3d;
	WORD msg[8];
	WORD button;
	WORD quit = FALSE;

	_GemParBlk.global[0] = 0;
	_GemParBlk.global[2] = 0;
	
	aes_handle = graf_handle( &pwchar, &phchar, &pwbox, &phbox );
	vdi_handle = open_screen_wk( aes_handle, work_out );
	aes_flags = get_aes_info( &aes_font, &aes_height, &hor_3d, &ver_3d );

	if ( aes_flags & GAI_3D )
		adapt3d_rsrc( rs_object, NUM_OBS, hor_3d, ver_3d );
	else
		no3d_rsrc( rs_object, NUM_OBS, 1 );
	
	if (( aes_flags & GAI_MAGIC ) == 0 )
	{
		OBJECT	*slct;
		OBJECT	*deslct;
		
		if ( phchar < 15 )
		{
			slct   = (OBJECT *) rs_trindex[IMAGE_DIALOG] + RADIO_M_SLCT;
			deslct = (OBJECT *) rs_trindex[IMAGE_DIALOG] + RADIO_M_DESLCT;
		}
		else
		{
			slct   = (OBJECT *) rs_trindex[IMAGE_DIALOG] + RADIO_SLCT;
			deslct = (OBJECT *) rs_trindex[IMAGE_DIALOG] + RADIO_DESLCT;
		}

		substitute_objects( rs_object, NUM_OBS, aes_flags, slct, deslct );
	}
	else
		substitute_objects( rs_object, NUM_OBS, aes_flags, (OBJECT *) 0L, (OBJECT *) 0L );

	cpx_tree->ob_x = rect->g_x;
	cpx_tree->ob_y = rect->g_y;

	read_config();
	
	redraw_obj( cpx_tree,ROOT);
	do
	{
		/* BubbleHelp */
		button = (*xcpb->Xform_do)(rs_object, 0, msg);
		quit = handle_button( button, msg );
	}
	while( !quit );

	substitute_free();
	v_clsvwk( vdi_handle );
		
	return(0);
}



/*----------------------------------------------------------------------------------------*/ 
/* Virtuelle Bildschirm-Workstation îffnen																*/
/* Funktionsresultat:	VDI-Handle oder 0 als Fehlernummer											*/
/* work_out:				GerÑteinformationen																*/
/*----------------------------------------------------------------------------------------*/ 
WORD open_screen_wk( WORD aes_handle, WORD *work_out )
{
	WORD	work_in[11];
	WORD	handle;
	WORD	i;

	for( i = 1; i < 10; i++ )
		work_in[i] = 1;

	work_in[0] = Getrez() + 2;											/* Auflîsung */
	work_in[10] = 2;														/* Rasterkoordinaten benutzen */
	handle = aes_handle;

	v_opnvwk( work_in, &handle, work_out );
	return( handle );
}


long getjar(void)
{
	return((long)(* (COOKIE **) 0x5a0));
}


int new_cookie(long id, long value)
{
	COOKIE *cookiejar = (COOKIE *)Supexec(getjar);
	
	if (cookiejar)
	{
		long maxc, anz = 1;
		
		while (cookiejar->id)
		{
			anz++;
			cookiejar++;
		}
		
		maxc = cookiejar->value;
		
		if (anz < maxc)
		{
			cookiejar->id    = id;
			cookiejar->value = value;
			
			cookiejar++;
			
			cookiejar->id    = 0L;
			cookiejar->value = maxc;
			
			return(1);
		}
	}
	
	return(0);
}


int remove_cookie(long id)
{
	COOKIE *cookiejar = (COOKIE *)Supexec(getjar);
	
	if (cookiejar)
	{
		while ((cookiejar->id) && (cookiejar->id != id)) cookiejar++;
		
		if (cookiejar->id)
		{
			COOKIE *cjo;
			
			do
			{
				cjo = cookiejar++;
			
				cjo->id    = cookiejar->id;
				cjo->value = cookiejar->value;

			} while(cookiejar->id);
			
			return(1);
		}
	}
	
	return(0);
}
