/* ======================================================================
 * FILE: MAINSTUF.C
 * ======================================================================
 * DATE: February 4, 1992 - created Color Version 2.0
 *			  - from work by m.lai from the original color.cpx
 *
 * DESCRIPTION: SPARROW VERSION - COLOR CPX
 * COMPILER: TURBO C Version 2.0
 */
 

/* INCLUDE FILES
 * ======================================================================
 */
#include <sys\gemskel.h>
#include <string.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>


#include "country.h"
#include "color.h"

#pragma warn -apt		   /* 1 Non-portable pointer assignment */
#pragma warn -rpt		   /* 1 Non-portable pointer conversion */
#include "color.rsh"
#pragma warn .apt
#pragma warn .rpt

#include "..\cpxdata.h"		   /* Our CPX Data Structures */	


	
/* DEFINES
 * ======================================================================
 */
/* State of a color */
#define	DIRTY	0x01				/* color has been modified */
#define	CLEAN	0x00				/* color has NOT been modified */

 
#define MAX_COL_SHOWN	16
#define COL_PER_ROW	4
#define	COL_PER_BNK	16				/* number of colors per bank */
#define	NUMREG		256


/* RGB gun value related */
#define VAL_PAGE	50				/* pager increment */


/* Key codes */
#define	UNDO	0x6100		/* Undo key */
#define	HOME	0x4700		/* Clr Home Key */


/* Palette size */
#define	MONO	2					/* monochrome */


/* Indices into array of RGB gun values for VDI */
#define	R	0					/* red gun value */
#define	G	1					/* green gun value */
#define	B	2					/* blue gun value */

/* Flags */
#define	HILITE		0				/* highlight an object */
#define	DEHILITE	1				/* de-highlight an object */




/* Structure for RGB gun values of each color */
typedef struct
{
	int	rint;					/* red intensity */
	int	gint;					/* green intensity */
	int	bint;					/* blue intensity */
} RGB;


/* Structure for variables saved at data segment of CPX */
typedef struct
{
    union
    {
	RGB num256[ NUMREG ];			/* for 256 pen modes   */
	RGB num16[ COL_PER_BNK ];		/* for all other modes */
    }bank;	
} DEFAULTS;



/* PROTOTYPES
 * ======================================================================
 */
CPXINFO	 *cdecl cpx_init( XCPB *Xcpb );
BOOLEAN  cdecl  cpx_call( GRECT *rect );

void	 open_vwork( void );
void	 close_vwork( void );

void	 draw_boxes( void );
void	 outline( int obj, int flag );
void 	 update_slid( int base, int slider, int value, 	
		      int min, int max, int draw);
void	 slidtext( void );
void	 myitoa(unsigned int inword, char *numbuf );
void	 update_rgb(int draw);

int	 calc_bpg(unsigned int palsize);
void	 do_redraw(GRECT *dirty_rect, int *oldclip);

void	 nxtrow(void);
void	 nxtpage(void);
void	 nxtgrp(void);
void	 nxt_to_show(int toscroll);
void	 adjcol( void );

void	 init( DEFAULTS *info );
void	 slamcol(RGB col_array[] );
void	 visit_bnk( void );

void	 cnclchgs(void);
void	 cnclbnk(void);
void	 savergb(void);
void	 cpyrgb(RGB *dest, RGB *src, int count);



/* EXTERNALS
 * ======================================================================
 */
extern	int		saved;		/* 0: no user-preference saved yet */
extern	DEFAULTS	usr_vals;	/* saved user-preference */
extern	DEFAULTS	def_vals;	/* system defaults */


/* GLOBALS
 * ======================================================================
 */
XCPB    *xcpb;			/* XControl Parameter Block   */
CPXINFO cpxinfo;		/* CPX Information Structure  */

OBJECT  *tree;
OBJECT  *ad_tree;

RGB	oldrgb[NUMREG],		/* old RGBs for all colors */
	*curold=NULL,		/* pointer to old RGBs for current bank */
	newrgb[NUMREG],		/* new RGBs for all colors */
	*curnew=NULL;		/* pointer to new RGBs for current bank */

int	currez;			/* current resolution */
int	headbox,		/* object number of 1st color box */
	headcol=0;		/* color # of 1st color box */
int	curcol,			/* current color number */
	curbox,			/* current color box selected */
	curslid;		/* current slider */
int	col_min=0,		/* smallest color number */
	col_max=0,		/* biggest color number */
	col_page;		/* color pager value */
int	curscrn[3],		/* current RGB gun values on screen */
	oldscrn[3];		/* old RGB gun values on screen */
int 	bpg,			/* number of bits per color gun */
	numcol=0;		/* # colors that can be displayed at once */
char    setup_bnk,
	touch_bnk,
	dirt_col[NUMREG],	/* dirty list for all colors */
	*curdirt=NULL;		/* dirty list for current bank of colors */


/* VDI arrays */
int	contrl[12], intin[128], intout[128], ptsin[128], ptsout[128],
	work_in[12], work_out[57];
int 	pxyarray[10];		/* input point array */
int	vhandle=-1;		/* virtual workstation handle */
int	hcnt=0;			/* handle count */


/* AES variables */
int	gl_apid, gl_hchar, gl_wchar, gl_hbox, gl_wbox;
GRECT	desk;
int	errno;
MFORM	orig_mf;		/* original mouse form */



/* FUNCTIONS
 * ======================================================================
 */
	

/* cpx_init()
 * ======================================================================
 * cpx_init() is where a CPX is first initialized.
 * There are TWO parts.
 *
 * PART ONE: cpx_init() is called when the CPX is first 'booted'. This is
 *	     where the CPX should read in its defaults and then set the
 *	     hardware based on those defaults.  
 *
 * PART TWO: The other time cpx_init() is called is when the CPX is being
 *	     executed.  This is where the resource is fixed up and current
 *	     cpx variables are updated from the hardware.  In addition,
 *	     this is where the CPXINFO structure should be filled out.
 *
 * IN:  XCPB	*Xcpb:	Pointer to the XControl Parameter Block
 * OUT: CPXINFO  *ptr:	Pointer to the CP Information Structure
 */			
CPXINFO
*cdecl cpx_init( XCPB *Xcpb )
{
    xcpb = Xcpb;

    currez = Getrez();				/* find current resolution */
    open_vwork();
    close_vwork();
    numcol = work_out[13];			/* size of CLUT */
    
    if( xcpb->booting )
    {
	if( saved )		/* if user-preference saved */
  	   init( &usr_vals );	/* init to saved user-preference */
        return( ( CPXINFO *)TRUE );  
    }
    else
    {    
      if( !xcpb->SkipRshFix )
      {
           (*xcpb->rsh_fix)( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
                            rs_object, rs_tedinfo, rs_strings, rs_iconblk,
                            rs_bitblk, rs_frstr, rs_frimg, rs_trindex,
                            rs_imdope );
      }
 
      ad_tree = (OBJECT *)rs_trindex[ COLOR ];
      ActiveTree( ad_tree );
      HideObj( BASE2 );
      HideObj( BASE4 );
      HideObj( BASE16 );
      
      Disable( CSAVE );
      Disable( CRELOAD );
      
      /* set up color boxes on screen */
      switch( numcol )
      {
        case 2:   headbox = curbox = TWO01;
        	  col_page = 1;
        	  ShowObj( BASE2 );
        	  break;
        	  
        case 4:	  headbox = curbox = FOUR01;
        	  col_page = 1;
        	  ShowObj( BASE4 );
        	  break;
        	  
        default:  headbox = curbox = BOX0;
		  if (numcol == 16)			/* if 16 colors */
		      col_page = 2;			/* page by 2 colors */
		  else					/* if > 16 colors */
		      col_page = MAX_COL_SHOWN; /* page by max displayed */
        	  ShowObj( BASE16 );
        	  break;
      }


      /* set up color # slider */
      headcol = curcol = 0;		/* init color on screen */
      bpg = calc_bpg(work_out[39]);	/* calculate bits per gun */
      if( !bpg )
      {
        HideObj( RGBSLIDE );
      }
      else
      {
        Enable( CSAVE );
        Enable( CRELOAD );
	setup_bnk = touch_bnk = CLEAN;
	visit_bnk();	/* init data structures of current bank */

        curscrn[R] = curscrn[G] = curscrn[B] = -1;
        update_rgb(0);	/* init RGBs on screen */
      }
      col_max = numcol - 1;			
      (*xcpb->Sl_size)( tree, CBASE, CSLIDE, numcol, 1, VERTICAL, 16 );
      update_slid( CBASE, CSLIDE, curcol, col_max, col_min, 0 );
      
      /* Initialize the CPXINFO structure */           
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

      /* Return the pointer to the CPXINFO structure to XCONTROL */
      return( &cpxinfo );
    }
}




/* cpx_call()
 * ======================================================================
 * Called ONLY when the CPX is being executed. Note that it is CPX_INIT()
 * that returned the ptr to cpx_call().
 * CPX_CALL() is the entry point to displaying and manipulating the
 * dialog box.
 *
 * IN: GRECT *rect:	Ptr to a GRECT that describes the current work
 *			area of the XControl window.
 *
 * OUT:
 *   FALSE:     The CPX has exited and no more messages are
 *		needed.  XControl will either return to its
 *		main menu or close its windows.
 *		This is used by XForm_do() type CPXs.
 *
 *   TRUE:	The CPX requests that XCONTROL continue to
 *		send AES messages.  This is used by Call-type CPXs.
 */
BOOLEAN
cdecl cpx_call( GRECT *rect )
{
     int   button;
     int   quit = 0;
     WORD  msg[8], clip[4];
     MRETS mk;
     int   ox, oy;
     
     ad_tree = (OBJECT *)rs_trindex[ COLOR ];
     ActiveTree( ad_tree );

     Wind_get(0, WF_WORKXYWH, (WARGS *)&desk );	/* set clipping to */
     rc_2xy( &desk, clip );			/*   Desktop space */

     open_vwork();
     vs_clip( vhandle, 1, ( int *)clip );
     
     ObX( ROOT ) = rect->g_x;
     ObY( ROOT ) = rect->g_y;
     Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
     draw_boxes();								/* draw the color boxes */
     outline( curbox, HILITE );		/* show selected box */
     close_vwork();
     
     do
     {
	button = (*xcpb->Xform_do)( tree, 0, msg );
     	switch( button )
     	{
	   case CCANCEL:
		         cnclchgs();			/* cancel all changes made */
     	
     	   case COK: quit = TRUE;
     	   	     Deselect( button );
     	   	     break;

 	   case CRELOAD:		/* reload saved user-preference */
 	   		if( bpg )
 	   		{
	   		  if( saved )
	   		     init(&usr_vals);
	   		  else
	   		     init(&def_vals);
		          update_rgb(1);	/* update RGB on screen */
		        }   
	   		Deselect( button );
	   		Objc_draw( tree, button, MAX_DEPTH, NULL );
			break;


	   case CSAVE:	/* save current values */
	   		if( bpg )
	   		{
			  if ((*xcpb->XGen_Alert)(SAVE_DEFAULTS) == TRUE)
			  {
			    (*xcpb->MFsave)(MFSAVE, &orig_mf);
			    graf_mouse( BUSYBEE, 0L );
					
			    if( bpg )			/* if color */
			    {
				savergb();		/* save color info */
							/* update RGBs */
				cpyrgb((RGB *)&oldrgb, (RGB *)&newrgb, numcol );	
			    }

			    /* save current data to file */
			    saved = 1;
			    (*xcpb->CPX_Save)((void *)&saved, sizeof(DEFAULTS)+2);
	    		    (*xcpb->MFsave)(MFRESTORE, &orig_mf);
			  }
			}  
			Deselect( button );
			Objc_draw( tree, button, MAX_DEPTH, NULL );
	   		break;


	   case CUP:
	   		(*xcpb->Sl_arrow)(tree, CBASE, CSLIDE, CUP, -1, 
	    			col_max, col_min, &curcol, VERTICAL, nxtrow);
	    		break;
	    		
	   case CDOWN:
	    		(*xcpb->Sl_arrow)(tree, CBASE, CSLIDE, CDOWN, 1, 
	    			col_max, col_min, &curcol, VERTICAL, nxtrow);
	    		break;

   	   case CSLIDE:
			(*xcpb->MFsave)(MFSAVE, &orig_mf);
			graf_mouse( FLAT_HAND, 0L );
	    		(*xcpb->Sl_dragy)(tree, CBASE, CSLIDE, col_max, 
	    			col_min, &curcol, nxtgrp);
	    		(*xcpb->MFsave)(MFRESTORE, &orig_mf);
			break;

	   case CBASE:
    			Graf_mkstate(&mk);
    			objc_offset(tree, CSLIDE, &ox, &oy);
    			if(mk.y < oy)
    	   		    oy = -col_page;
       			else
    	    		    oy = col_page;
			curslid = CSLIDE;
	    		(*xcpb->Sl_arrow)(tree, CBASE, CSLIDE, -1, oy, 
	    			col_max, col_min, &curcol, VERTICAL, nxtpage);
	    		break;


	   case RUP:
			curslid = RSLIDE;
	    		(*xcpb->Sl_arrow)(tree, RBASE, RSLIDE, RUP, 1, 0, 
	    			1000, &curscrn[R], VERTICAL, adjcol);
	    		break;
	    		
	   case RDOWN:
			curslid = RSLIDE;
	    		(*xcpb->Sl_arrow)(tree, RBASE, RSLIDE, RDOWN, -1, 
	    			0, 1000, &curscrn[R], VERTICAL, adjcol);
	    		break;
	    		
	   case RSLIDE:
			(*xcpb->MFsave)(MFSAVE, &orig_mf);
			graf_mouse( FLAT_HAND, 0L );
			curslid = RSLIDE;
	    		(*xcpb->Sl_dragy)(tree, RBASE, RSLIDE, 0, 1000, 
	    			&curscrn[R], adjcol);
	    		(*xcpb->MFsave)(MFRESTORE, &orig_mf);
	    		break;
	    		
	   case RBASE:
    	   		Graf_mkstate(&mk);
    	   		objc_offset(tree, RSLIDE, &ox, &oy);
    	   		if( mk.y < oy)
    	   		     oy = VAL_PAGE;
    	   		else
    	       		     oy = -VAL_PAGE;
			curslid = RSLIDE;
	    		(*xcpb->Sl_arrow)(tree, RBASE, RSLIDE, -1, oy, 0, 
	    			1000, &curscrn[R], VERTICAL, adjcol);
	    		break;
	        
  	   case GUP:
			curslid = GSLIDE;
	    		(*xcpb->Sl_arrow)(tree, GBASE, GSLIDE, GUP, 1, 0, 
	    			1000, &curscrn[G], VERTICAL, adjcol);
	    		break;
	    		
	   case GDOWN:
			curslid = GSLIDE;
	    		(*xcpb->Sl_arrow)(tree, GBASE, GSLIDE, GDOWN, -1, 
	    			0, 1000, &curscrn[G], VERTICAL, adjcol);
	    		break;
	    		
	   case GSLIDE:
			(*xcpb->MFsave)(MFSAVE, &orig_mf);
			graf_mouse( FLAT_HAND, 0L );
			curslid = GSLIDE;
	    		(*xcpb->Sl_dragy)(tree, GBASE, GSLIDE, 0, 1000, 
	    			&curscrn[G], adjcol);
	    		(*xcpb->MFsave)(MFRESTORE, &orig_mf);
	    		break;
	    		
	   case GBASE:
    	   		Graf_mkstate(&mk);
    	   		objc_offset(tree, GSLIDE, &ox, &oy);
    	   		if(mk.y < oy)
    	   		     oy = VAL_PAGE;
    	   		else
    	   	    	     oy = -VAL_PAGE;
			curslid = GSLIDE;
	    		(*xcpb->Sl_arrow)(tree, GBASE, GSLIDE, -1, oy, 0, 
	    			1000, &curscrn[G], VERTICAL, adjcol);
	    		break;
	   
	        
	   case BUP:
			curslid = BSLIDE;
	    		(*xcpb->Sl_arrow)(tree, BBASE, BSLIDE, BUP, 1, 0, 
	    			1000, &curscrn[B], VERTICAL, adjcol);
	    		break;
	    		
	   case BDOWN:
			curslid = BSLIDE;
	    		(*xcpb->Sl_arrow)(tree, BBASE, BSLIDE, BDOWN, -1, 
	    			0, 1000, &curscrn[B], VERTICAL, adjcol);
	    		break;
	    		
	   case BSLIDE:
			(*xcpb->MFsave)(MFSAVE, &orig_mf);
			graf_mouse( FLAT_HAND, 0L );
			curslid = BSLIDE;
	    		(*xcpb->Sl_dragy)(tree, BBASE, BSLIDE, 0, 1000, 
	    			&curscrn[B], adjcol);
	    		(*xcpb->MFsave)(MFRESTORE, &orig_mf);
	    		break;
	    		
	   case BBASE:
    			Graf_mkstate(&mk);
    			objc_offset(tree, BSLIDE, &ox, &oy);
    			if(mk.y < oy)
	  		   oy = VAL_PAGE;
    			else
			   oy = -VAL_PAGE;
			curslid = BSLIDE;
	    		(*xcpb->Sl_arrow)(tree, BBASE, BSLIDE, -1, oy, 0, 
	    			1000, &curscrn[B], VERTICAL, adjcol);
	    		break;


  	   case TWO01:		/* for ST High rez */
	   case TWO02:
	
	   case FOUR01:		/* for ST Medium rez */
	   case FOUR02:
	   case FOUR03:
	   case FOUR04:
		
	   case BOX0:    	/* for all other rez */
	   case BOX1:
	   case BOX2:
	   case BOX3:
	   case BOX4:
	   case BOX5:
	   case BOX6:
	   case BOX7:
	   case BOX8:
	   case BOX9:
	   case BOX10:
	   case BOX11:
	   case BOX12:
	   case BOX13:
	   case BOX14:
	   case BOX15:
	  		if( button != curbox)	/* select requested color */
	  		{
			    curcol = button - headbox + headcol;
			    nxt_to_show(0);
			    update_slid( CBASE, CSLIDE, curcol, col_max, col_min, 1);
			}
	   		break;

     	   default:	if( button == -1 )
     			{
     			   switch( msg[0] )
     			   {
     			     case WM_REDRAW: /* redraw the cpx */
		  			     do_redraw((GRECT *)&msg[4], (int *)clip);
     			     		     break;
     			     		     
     			     case AC_CLOSE:  /* treated like a cancel */
	 				     cnclchgs();	/* cancel changes made */
     			     case WM_CLOSED: quit = TRUE; 	/* treated like an OK */
					     break;
					     
			     case CT_KEY:
			     	switch( msg[3] )	/* check which key is returned */
			     	{
					case UNDO:				/* if Undo key */
						if( bpg )			/* if there is color */
						{
						   cnclbnk();		/* cancel color changes */
						   update_rgb(1);	/* update RGB on screen */
						}
						break;
						
					case HOME:				/* if Clr Home key */
						if( bpg )
						{
						   init(&def_vals);	/* init to system defs */
						   update_rgb(1);	/* update RGB on screen */
						}   
						break;
				}

			     		     break;		     
     			     default:
     			     		break;
     			   }
     			}
     			break;
     	}
     }while( !quit);
     return( FALSE );
}



/*
 * Open virtual workstation
 */
void
open_vwork(void)
{
  int i;
  
  if (hcnt == 0) {
  	for (i = 1; i < 10;)
    	work_in[i++] = 1;
  	work_in[0] = currez + 2;
  	work_in[10] = 2;
  	vhandle = xcpb->handle;
  	v_opnvwk(work_in, &vhandle, work_out);
  }
  hcnt++;
}


/*
 * Close virtual workstation
 */
void
close_vwork(void)
{
    hcnt--;
    if( !hcnt )
    {
 	v_clsvwk(vhandle);
	vhandle = -1;
    }
}


/*
 * Draw the color boxes
 */
void
draw_boxes(void)
{
	GRECT obrect;
	int obj, objcol;
	int lastbox;		
	
	wind_update(TRUE);
	graf_mouse( M_OFF, 0L );
	
	if (numcol < MAX_COL_SHOWN)				/* init last box to be drawn */
		lastbox = headbox + numcol - 1;
	else
		lastbox = headbox + MAX_COL_SHOWN - 1;
	
	vsf_interior( vhandle, FIS_SOLID );		/* fill with SOLID pattern */
	for (obj = headbox, objcol = headcol; 
		obj <= lastbox;
		obj++, objcol++)
	{
		
		vsf_color( vhandle, objcol );	/* fill with color of obj */
		obrect = ObRect(obj);
		objc_offset(tree, obj, &obrect.g_x, &obrect.g_y);
		pxyarray[0] = obrect.g_x;
		pxyarray[1] = obrect.g_y;
		pxyarray[2] = obrect.g_x + obrect.g_w - 1;
		pxyarray[3] = obrect.g_y + obrect.g_h - 1;
		v_bar(vhandle, pxyarray);
		
	}
	graf_mouse( M_ON, 0L );
	wind_update(FALSE);
}


/*
 * Highlight or de-highlight a color box
 */
void
outline( int obj, int flag )
{
	int   color;
	GRECT obrect;
	
	if( flag == HILITE )
		color = 1;			/* highlight box with foreground color */
	else
		color = 0;			/* de-light box with background color */
	
	wind_update( TRUE );
	graf_mouse( M_OFF, 0L );
	vsl_color( vhandle, color );
	obrect = ObRect(obj);
	objc_offset(tree, obj, &obrect.g_x, &obrect.g_y);
	pxyarray[0] = pxyarray[2] = pxyarray[8] = obrect.g_x - 2;
	pxyarray[1] = pxyarray[7] = pxyarray[9] = obrect.g_y - 2;
	pxyarray[3] = pxyarray[5] = obrect.g_y + obrect.g_h + 1;
	pxyarray[4] = pxyarray[6] = obrect.g_x + obrect.g_w + 1;
	v_pline(vhandle, 5, pxyarray);
	pxyarray[0] = pxyarray[2] = pxyarray[8] = obrect.g_x - 3;
	pxyarray[1] = pxyarray[7] = pxyarray[9] = obrect.g_y - 3;
	pxyarray[3] = pxyarray[5] = obrect.g_y + obrect.g_h + 2;
	pxyarray[4] = pxyarray[6] = obrect.g_x + obrect.g_w + 2;
	v_pline(vhandle, 5, pxyarray);
	graf_mouse( M_ON, 0L );
	wind_update(FALSE);
}


/*
 * Update and draw (if requested) a specified slider
 */
void
update_slid( int base, int slider, int value, 
	     int min, int max, int draw)
{
	GRECT	obrect;			/* location of slider */

	obrect = ObRect(slider);
	objc_offset(tree, slider, &obrect.g_x, &obrect.g_y);
	curslid = slider;
	
	(*xcpb->Sl_y)(tree, base, slider, value, min, max, slidtext);
	
	if (draw) {				/* if requested to draw, draw the slider */
		obrect.g_x--;		/* account for outline */
		obrect.g_y--;
		obrect.g_w += 2;
		obrect.g_h += 2;
		Objc_draw(tree, base, MAX_DEPTH, &obrect);		/* undraw old */
		objc_offset(tree, slider, &obrect.g_x, &obrect.g_y);
		obrect.g_x--;		/* account for outline */
		obrect.g_y--;
		Objc_draw(tree, base, MAX_DEPTH, &obrect);		/* draw new */
	}
}



/*
 * Update R, G, B, color or bank index on screen.
 */
void
slidtext( void )
{
	switch (curslid) {
		
		case RSLIDE:
    		myitoa(curscrn[R], TedText(curslid));
			break;
			
		case GSLIDE:
    		myitoa(curscrn[G], TedText(curslid));
			break;
			
		case BSLIDE:
    		myitoa(curscrn[B], TedText(curslid));
			break;
			
		case CSLIDE:
    		myitoa(curcol, TedText(curslid));
			break;
			
		default:
			break;
	}
}


/*	
 * Convert binary number to ascii value
 */
void
myitoa(unsigned int inword, char *numbuf)			
{	
    unsigned int temp1, value;
    register int i, j;
    char tmpbuf[10];
    register char *ascbuf;
	
    ascbuf = numbuf;
    i = 0;				/* if the value is non zero  */

    if (!inword)	
	*ascbuf++ = '0';
    else {
	value = inword;
	while(value) {
	    temp1 = value % 10;		/*  find the remainder	*/
	    temp1 += 0x0030;		/*  convert to ASCII	*/
	    tmpbuf[i++] = temp1;	/*  buffer is reverse	*/
	    value = value / 10;
	}

	for (j = i-1; j >= 0; j--) 	/* reverse it back	*/
	    *ascbuf++ = tmpbuf[j];
    }

    *ascbuf = 0;			/* end of string mark	*/
    return;
}



/*
 * Update and draw (if requested) text in the RGB sliders
 */
void
update_rgb(int draw)
{
    RGB *ptr;		/* ptr to RGB intensities of current color */
	
    /* Inquire the RGB intensities for current pen */
    ptr = curnew + curcol;
    open_vwork();
    vq_color( vhandle, curcol, 0, ( int *)ptr );
    close_vwork();
	
    /* Update the RGB gun values for current pen */
    oldscrn[R] = curscrn[R];
    oldscrn[G] = curscrn[G];
    oldscrn[B] = curscrn[B];
    curscrn[R] = ptr->rint;
    curscrn[G] = ptr->gint;
    curscrn[B] = ptr->bint;
	    		
	/* Record old location of sliders, and update indices	*/
    /* on R, G and B sliders if necessary 					*/
    if (oldscrn[R] != curscrn[R])
		update_slid( RBASE, RSLIDE, curscrn[R], 0, 
			1000, draw);
    
    if (oldscrn[G] != curscrn[G])
		update_slid( GBASE, GSLIDE, curscrn[G], 0, 
			1000, draw);
    
    if (oldscrn[B] != curscrn[B])
		update_slid( BBASE, BSLIDE, curscrn[B], 0, 
			1000, draw);
}


/*
 * Calculte number of bits of data per color gun.
 * The given number is the size of the color palette.
 */
int
calc_bpg(unsigned int palsize)
{
	int result;
	
	result = 0;
	while (palsize >>= 1)
		result++;
	return(result /= 3);
}


/*
 * Find and redraw all clipping rectangles
 */
void
do_redraw(GRECT *dirty_rect, int *oldclip)
{
	GRECT *r1;
	WORD clip[4];
  	if (bpg > 0) {		/* only need to draw when there is color */
  		open_vwork();
		r1 = (*xcpb->GetFirstRect)(dirty_rect);
		while (r1) {
			/* set clipping rectangle */
			rc_2xy(r1, clip);
			vs_clip(vhandle, 1, (int *)clip);
			draw_boxes();
			outline( curbox, HILITE );
			r1 = (*xcpb->GetNextRect)();
		}
		vs_clip(vhandle, 1, oldclip);	/* restore original clipping */
		close_vwork();
	}
}


/*
 * Show the next row of colors
 * (when using arrows to scroll through color map)
 */
void
nxtrow(void)
{
	nxt_to_show( COL_PER_ROW );
}


/*
 * Show the next page of colors
 * (when using base to page through color map)
 */
void
nxtpage(void)
{
	nxt_to_show(MAX_COL_SHOWN);
}


/*
 * Show the next group
 * (when using slider to drag through color map)
 */
void
nxtgrp(void)
{
	if (curcol < headcol)		/* dragging backwards */
		nxt_to_show(headcol-curcol);
	else						/* dragging forward */
		nxt_to_show(curcol-headcol-MAX_COL_SHOWN+1);
}


/*
 * Show the selected color of the appropiate line or page 
 */
void
nxt_to_show(int toscroll)
{
	int obj;
	WORD clip[4];
	
	open_vwork();
	rc_2xy( &desk, clip );	
	vs_clip( vhandle, 1, ( int *)clip );
	
	/* if current color is not shown, page accordingly to show it */ 
	if (curcol < headcol) {							/* page backwards */
		if ((headcol -= toscroll) < 0)	/* update color to start with */
			headcol = 0;	
		draw_boxes();					/* redraw color boxes */
	} else if (curcol >= headcol + MAX_COL_SHOWN) {	/* page forward */
		if ((headcol += toscroll) > numcol - MAX_COL_SHOWN)
			headcol = numcol - MAX_COL_SHOWN;
		draw_boxes();					/* redraw color boxes */
	}
	
	/* deselect previous color and select current one */
	obj = curcol - headcol + headbox;
	if (obj != curbox) {
		outline(curbox, DEHILITE);
		outline(obj, HILITE);
		curbox = obj;			/* update current box selected */
	}
	
	/* update color # and RGB sliders */		
	curslid = CSLIDE;
	slidtext();				/* update color # */
	if (bpg)				/* if there is color */
		update_rgb(1);		/* update and draw RGB gun values */

	close_vwork();
}



/*
 * Adjust color of selected color pen with
 * RGB gun values requested.
 */
void
adjcol( void )
{
	(curnew+curcol)->rint = curscrn[R];
	(curnew+curcol)->gint = curscrn[G];
	(curnew+curcol)->bint = curscrn[B];
        
	slidtext();
	open_vwork();
	vs_color(vhandle, curcol, (int *)(curnew+curcol) );
	close_vwork();
	*( curdirt+curcol ) = touch_bnk = DIRTY;
}



/*
 * Initialize system with given information.
 */
void
init(DEFAULTS *info)
{
	open_vwork();

  	switch( numcol )
  	{
  	   case 1:	
  	   case 2:
  	   case 4:
  	   case 16:     slamcol( info->bank.num16 );
  	   		break;
  	   		
  	   case 256:    slamcol( info->bank.num256 );
  	   		break;
  	   		
  	   default:     slamcol( info->bank.num16 );
  	   		break;
  	}
	close_vwork();
 }


/*
 * Set VDI color lookup table with the given RGB intensities
 * Passed:
 *			RGB col_array[] - array of RGB intensities
 */
void
slamcol(RGB col_array[])
{
	int i;		/* counter */
	
	open_vwork();
 	for (i = 0; i < numcol; i++ )
 	{
 	    if( col_array[i].rint == -1 )
 	        vq_color(vhandle, i, 0, (int *)&col_array[i]);
	    vs_color(vhandle, i, (int *)&col_array[i]);
	}
	close_vwork();
}


/*
 * Update all data structures of current bank
 */
void
visit_bnk( void )
{	
	int i;		/* counter */
	RGB *ptr;	/* temp pointer */
	
	/* init pointers to offset to current bank */
	curold = (RGB *)&oldrgb[0];		/* old RGBs of current bank */
	curnew = (RGB *)&newrgb[0];		/* new RGBs of current bank */
	curdirt = (char *)&dirt_col[0];	/* dirty list for current bank */
	
	/* if bank has never been setup before, fill data structures */
	if( setup_bnk == CLEAN )
	{
		open_vwork();
		for (i = 0, ptr = curnew; i < numcol; i++, ptr = curnew+i)
		{
		    vq_color(vhandle, i, 0, (int *)ptr);
		    *(curold+i)  = *ptr;
		    *(curdirt+i) = CLEAN;
		}
		close_vwork();
		setup_bnk = DIRTY;	/* remember it's been setup */
	}

}



/*
 * Cancel changes made to any color
 */
void
cnclchgs(void)
{
	if( touch_bnk == DIRTY )
	{
	   visit_bnk();
	   cnclbnk();
	}
}


/*
 * Cancel changes made to current bank
 */
void
cnclbnk(void)
{
	int j;
	
	open_vwork();
	for (j = 0; j < numcol; j++)		/* for all colors */
	{
		if( * ( curdirt+j ) == DIRTY )	/* if color modified */
		{
										/* reset it */
			vs_color(vhandle, j, (int *)(curold+j));
			*(curnew+j) = *(curold+j);
		}
	}
	close_vwork();
}


/*
 * Save current RGB intensities of all colors for all banks
 * to their save area
 */
void
savergb(void)
{
	/* save RGBs of bank 0 */
	if( setup_bnk == CLEAN)
	    visit_bnk();
	
	cpyrgb(usr_vals.bank.num256, newrgb, numcol);
}


/*
 * Copy RGB values from source buffer to destination buffer
 * for given number of colors.
 */
void
cpyrgb(RGB *dest, RGB *src, int count)
{
	int i;
	
	for (i = 0; i < count; i++)
		*(dest+i) = *(src+i);
}
