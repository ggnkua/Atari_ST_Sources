/*
 *	COLOR.C - CPX for  setting color palettes
 *	=================================================================
 *	Using TURBO C Version 2.0
 */


/*
 *  Per Slavik Lozben (06/13/90) -
 *  Color register 254 is used for border color in ST high rez.
 *  Pen 0 is for background color.
 *  Pen 1 is for foreground color.
 *  Default setting:  Pen0 - bg - 255
 *                    Pen1 - fg - 254
 *
 *  07/09/92 cjg If AES Version >= 3.2, use MFsave, else skip it
 */
 
 
#pragma cdecl

/*
 * Include files
 */
#include	<stdio.h>
#include	<tos.h>
#include	<vdi.h>
#include	<alt\aesalt.h>
#include	<alt\auxtos.h>
#include	<sys\portab.h>
#include	<sys\cpxdata.h>		   /* CPX data structures */	
#include	"color.h"
#include	"country.h"
#include	"colrsc.h"
#include	"colrsc.rsh"



/*
 * Prototypes
 */
CPXINFO	*cdecl cpx_init(XCPB *Xcpb);
BOOLEAN	cdecl  colpnl(GRECT *rect);
void	init(DEFAULTS *info);
void	slidtext(void);
void	adjcol(void);
void	nxtrow(void);
void	nxtgrp(void);
void	nxtpage(void);
void	nxt_to_show(int toscroll);
void	nxtbnk(void);
void	visit_bnk(int set);
void	reinitcol(void);
void	outline(int obj, int flag);
void	update_rgb(int draw);
void	update_slid(int direction, int base, int slider, int value, 
					int min, int max, int draw);
void	draw_boxes(void);
void	cnclchgs(void);
void	cnclbnk(void);
void	do_redraw(GRECT *dirty_rect, int *oldclip);
void	slamcol(RGB col_array[]);
void	savergb(void);
void	cpyrgb(RGB *dest, RGB *src, int count);
void	swaprgb(RGB *rgb1, RGB *rgb2);
void	flip(int set, int *val);
void	myitoa(unsigned int inword, char *numbuf);
int		calc_bpg(unsigned int palsize);
int		val2int(int value);
int		int2val(int intensity);
void	draw_button(int button);
void	open_vwork(void);
void	close_vwork(void);


/*
 * Externals
 */
extern	int			saved;		/* 0: no user-preference saved yet */
extern	DEFAULTS	usr_vals;	/* saved user-preference */
extern	DEFAULTS	def_vals;	/* system defaults */


/*
 * Global Variables
 */
XCPB 	*xcpb;				/* XControl parameter block   */
CPXINFO cpxinfo;			/* CPX information structure  */
OBJECT	*tree;				/* the big picture */
RGB		oldrgb[NUMREG],		/* old RGBs for all colors */
		*curold=NULL,		/* pointer to old RGBs for current bank */
		newrgb[NUMREG],		/* new RGBs for all colors */
		*curnew=NULL;		/* pointer to new RGBs for current bank */
int		curscrn[3],			/* current RGB gun values on screen */
		oldscrn[3];			/* old RGB gun values on screen */
int 	bpg,				/* number of bits per color gun */
		numbnk=1,			/* number of banks of color available */
		numcol=0,			/* # colors that can be displayed at once */
		totcol=0;			/* total # colors dealing with */
int		headbox,			/* object number of 1st color box */
		headcol=0;			/* color # of 1st color box */
int		val_min=0,			/* smallest RGB index */
		val_max=0;			/* biggest RGB index */
int		col_min=0,			/* smallest color number */
		col_max=0,			/* biggest color number */
		col_page;			/* color pager value */
int		curcol,				/* current color number */
		curbox,				/* current color box selected */
		curslid;			/* current slider */
long 	curmode;			/* current video mode */
int		currez,				/* current resolution */
		curbnk=BNK_MIN,		/* current bank value */
		curinv=-1,			/* current invert state */
		curgray=-1;			/* current state of hypermono switch */
int		oldbnk,				/* old bank value */
		oldinv,				/* old invert state */
		oldgray;			/* old state of hypermono switch */
char	touch_bnk[NUM_BNK],	/* DIRTY: has modified the bank */
		setup_bnk[NUM_BNK],	/* DIRTY: has setup structures for the bank */
		dirt_col[NUMREG],	/* dirty list for all colors */
		*curdirt=NULL;		/* dirty list for current bank of colors */


/*  VDI and AES related variables */
MFORM	orig_mf;		/* original mouse form */
int		vhandle=-1;		/* virtual workstation handle */
int		hcnt=0;			/* handle count */
int		contrl[12];
int 	intin[128];
int 	ptsin[128];
int 	intout[128];
int 	ptsout[128];	/* storage wasted for idiotic bindings */
int		work_in[11];	/* input to GSX parameter array */
int 	work_out[57];	/* output from GSX parameter array */
int 	pxyarray[10];	/* input point array */
int     AES_Version;

/*
 * Initialize the color panel
 * Passed:  XCPB	*Xcpb		= pointer to the XControl parameter block
 * Returns: CPXINFO	*cpxinfo	= pointer to the CPX information structure
 */
CPXINFO
*cdecl	cpx_init(XCPB *Xcpb)
{
	int i;				/* counter */
	
	xcpb = Xcpb;
	
	currez = Getrez();						/* find current resolution */
	open_vwork();
	close_vwork();
	numcol = work_out[13];					/* size of CLUT */
	
	if (!(*xcpb->getcookie)(_VDO, &curmode)) /* find current video mode */
		curmode = STVDO;	/* if no cookie, assume it's an ST */
	curmode >>= 16;			/* keep only upper word */	
		
	if (xcpb->booting) {		/* if just booted, read saved values */
	
		if (saved)				/* if user-preference saved */
			init(&usr_vals);	/* init to saved user-preference */
		return((CPXINFO *)TRUE);
		
	} else {					/* else run cpx */
	
		appl_init();
		AES_Version = _GemParBlk.global[0];
		
		bpg = calc_bpg(work_out[39]);	/* calculate bits per gun */
		val_max = (1 << bpg) - 1;		/* init RGB sliders max value */
		
		if(!xcpb->SkipRshFix)			/* fix up the resource */
			(*xcpb->rsh_fix)(NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
						rs_object, rs_tedinfo, rs_strings, rs_iconblk,
						rs_bitblk, rs_frstr, rs_frimg, rs_trindex,
						rs_imdope);
	
		ActiveTree(rs_object);			/* tree -> color panel */
	
		/* set up color boxes on screen */
		switch (numcol) {
			case 2:							/* can show 2 colors */
				headbox = curbox = DUO0;
				col_page = 1;				/* page by 1 color */
				ShowObj(DUOBOXES);			/* show 2 boxes */
				break;
			
			case 4:							/* can show 4 colors */
				headbox = curbox = QUARTRO0;
				col_page = 1;				/* page by 1 color */
				ShowObj(QTBOXES);			/* show 4 boxes */
				break;
		
			default:						/* can show >= 16 colors */
				headbox = curbox = BOX0;
				ShowObj(ALLBOXES);			/* show 16 boxes */
				if (numcol == 16)			/* if 16 colors */
					col_page = 2;			/* page by 2 colors */
				else						/* if > 16 colors */
					col_page = MAX_COL_SHOWN; /* page by max displayed */
				break;
		}
		
		if (currez == STHI) {				/* if in ST High rez */
			ShowObj(INVRSVDO);				/* show Invert button */
			flip(0, &curinv);				/* init and save current */
			oldinv = curinv;				/*   inverse state       */
			if (!(curinv & NOT_FLIPPED))	
				Select(INVRSVDO);
		}
		
		if((int)curmode == TTVDO) {
			switch(currez) {			/* what's the current rez? */
				case TTHI:				/* if TT high */
					HideObj(COLSAVE);	/* nothing to be saved */
					HideObj(COLCNCEL);	/* nothing to be cancelled */
					HideObj(COLRLOAD);	/* nothing to be reload */
					break;
					
				default:				/* if ST Low, ST Med or TT Med */
					ShowObj(BNKBOX);	/* allow bank switching */
					numbnk = NUM_BNK;	/* there are NUM_BNKs */
					oldbnk = curbnk		/* save bank number */
						= EsetBank(-1);
					update_slid(HORIZONTAL, BNKBASE, BNKSLID, curbnk, 
							BNK_MIN, BNK_MAX, 0);
				
				case STHI:				/* if ST high or TT Low */
				case TTLOW:
					/* init and save hypermono mode */
					if ((oldgray = curgray = EsetGray(-1)) != 0) {
						HideObj(SETGRAY);
						ShowObj(SETCOL);
					} else {
						HideObj(SETCOL);
						ShowObj(SETGRAY);
					}
					break;
			}
		}
		
		headcol = curcol = 0;		/* init color on screen */
		
		if (!bpg) {					/* if monochrome */
			HideObj(RGBSLID);		/* don't need color controls */
		} else {					/* if color */
			totcol = numbnk * numcol;	/* number of color dealing with */
			
			/* no bank has been set up or touched yet */
			for (i = BNK_MIN; i < numbnk; i++)
				setup_bnk[i] = touch_bnk[i] = CLEAN;
				
			visit_bnk(0);	/* init data structures of current bank */
			curscrn[R] = curscrn[G] = curscrn[B] = -1;
			update_rgb(0);	/* init RGBs on screen */
		}
		
		/* set up color # slider */
		col_max = numcol - 1;			
		(*xcpb->Sl_size)(tree, COLBASE, COLSLID, numcol, 1, 
			VERTICAL, 16);
		update_slid(VERTICAL, COLBASE, COLSLID, curcol, col_max, 
			col_min, 0);
		
		/* Initialize the CPXINFO structure */           
		cpxinfo.cpx_call = colpnl;
		cpxinfo.cpx_draw = NULL;
		cpxinfo.cpx_wmove = NULL;
		cpxinfo.cpx_timer = NULL;
		cpxinfo.cpx_key = NULL;
		cpxinfo.cpx_button = NULL;
		cpxinfo.cpx_m1 = NULL;
		cpxinfo.cpx_m2 = NULL;
		cpxinfo.cpx_hook = NULL;
		cpxinfo.cpx_close = NULL;
      
		/* Return the pointer to the CPXINFO structure to XCONTROL */
		return(&cpxinfo);
		
	}
}


/* 
 * Show color panel
 * Passed:  GRECT *rect		= pointer to rectangle CPX resides in 
 * Returns: BOOLEAN	FALSE	= to exit CPX
 */
BOOLEAN	
cdecl  colpnl(GRECT *rect)
{
    MRETS mk;
    int quit=0;
    int obj, ox, oy;
    WORD msg[8], clip[4];
	GRECT obrect;		/* object rectangle */
    
    
    Wind_get(0, WF_WORKXYWH, (WARGS *)&obrect);	/* set clipping to */
    rc_2xy(&obrect, clip);						/*   Desktop space */
    
    open_vwork();
    vs_clip(vhandle, 1, (int *)clip);
    
  	ObX(COLPNL) = rect->g_x;					/* position panel */
 	ObY(COLPNL) = rect->g_y;
    Objc_draw(tree, COLPNL, MAX_DEPTH, NULL);	/* draw panel */
   	draw_boxes();								/* draw the color boxes */
   	outline(curbox, HILITE);					/* show selected box */
    close_vwork();
    
    if (IsSelected(INVRSVDO))	/* if Invert button is selected */
    	Deselect(INVRSVDO);		/* deselect it */
    	
    do {
    if ((obj = (*xcpb->Xform_do)(tree, COLPNL, msg)) != -1) {
    	obj &= 0x7fff;				/* mask out double clicks */
 		switch(obj) {
			case RUP:
				curslid = RSLID;
	    		(*xcpb->Sl_arrow)(tree, RBASE, RSLID, RUP, 1, val_min, 
	    			val_max, &curscrn[R], VERTICAL, adjcol);
	    		break;
			case RDOWN:
				curslid = RSLID;
	    		(*xcpb->Sl_arrow)(tree, RBASE, RSLID, RDOWN, -1, 
	    			val_min, val_max, &curscrn[R], VERTICAL, adjcol);
	    		break;
			case RSLID:
				(*xcpb->MFsave)(MFSAVE, &orig_mf);
				if( AES_Version >= 0x0320 )
				    DRAG_MOUSE;
				curslid = RSLID;
	    		(*xcpb->Sl_dragy)(tree, RBASE, RSLID, val_min, val_max, 
	    			&curscrn[R], adjcol);
	    		(*xcpb->MFsave)(MFRESTORE, &orig_mf);
	    		break;
			case RBASE:
    	   		Graf_mkstate(&mk);
    	   		objc_offset(tree, RSLID, &ox, &oy);
    	   		if(mk.y < oy)
    	   			oy = VAL_PAGE;
    	   		else
    	       		oy = -VAL_PAGE;
				curslid = RSLID;
	    		(*xcpb->Sl_arrow)(tree, RBASE, RSLID, -1, oy, val_min, 
	    			val_max, &curscrn[R], VERTICAL, adjcol);
	    		break;
	        
			case GUP:
				curslid = GSLID;
	    		(*xcpb->Sl_arrow)(tree, GBASE, GSLID, GUP, 1, val_min, 
	    			val_max, &curscrn[G], VERTICAL, adjcol);
	    		break;
			case GDOWN:
				curslid = GSLID;
	    		(*xcpb->Sl_arrow)(tree, GBASE, GSLID, GDOWN, -1, 
	    			val_min, val_max, &curscrn[G], VERTICAL, adjcol);
	    		break;
			case GSLID:
				(*xcpb->MFsave)(MFSAVE, &orig_mf);
				if( AES_Version >= 0x0320 )
				    DRAG_MOUSE;
				curslid = GSLID;
	    		(*xcpb->Sl_dragy)(tree, GBASE, GSLID, val_min, val_max, 
	    			&curscrn[G], adjcol);
	    		(*xcpb->MFsave)(MFRESTORE, &orig_mf);
	    		break;
			case GBASE:
    	   		Graf_mkstate(&mk);
    	   		objc_offset(tree, GSLID, &ox, &oy);
    	   		if(mk.y < oy)
    	   			oy = VAL_PAGE;
    	   		else
    	   	    	oy = -VAL_PAGE;
				curslid = GSLID;
	    		(*xcpb->Sl_arrow)(tree, GBASE, GSLID, -1, oy, val_min, 
	    			val_max, &curscrn[G], VERTICAL, adjcol);
	    		break;
	        
			case BUP:
				curslid = BSLID;
	    		(*xcpb->Sl_arrow)(tree, BBASE, BSLID, BUP, 1, val_min, 
	    			val_max, &curscrn[B], VERTICAL, adjcol);
	    		break;
			case BDOWN:
				curslid = BSLID;
	    		(*xcpb->Sl_arrow)(tree, BBASE, BSLID, BDOWN, -1, 
	    			val_min, val_max, &curscrn[B], VERTICAL, adjcol);
	    		break;
			case BSLID:
				(*xcpb->MFsave)(MFSAVE, &orig_mf);
				if( AES_Version >= 0x0320 )
				    DRAG_MOUSE;
				curslid = BSLID;
	    		(*xcpb->Sl_dragy)(tree, BBASE, BSLID, val_min, val_max, 
	    			&curscrn[B], adjcol);
	    		(*xcpb->MFsave)(MFRESTORE, &orig_mf);
	    		break;
			case BBASE:
    			Graf_mkstate(&mk);
    			objc_offset(tree, BSLID, &ox, &oy);
    			if(mk.y < oy)
    	  				oy = VAL_PAGE;
    			else
					oy = -VAL_PAGE;
				curslid = BSLID;
	    		(*xcpb->Sl_arrow)(tree, BBASE, BSLID, -1, oy, val_min, 
	    			val_max, &curscrn[B], VERTICAL, adjcol);
	    		break;
	    		
	    	case COLUP:
	    		(*xcpb->Sl_arrow)(tree, COLBASE, COLSLID, COLUP, -1, 
	    			col_max, col_min, &curcol, VERTICAL, nxtrow);
	    		break;
			case COLDOWN:
	    		(*xcpb->Sl_arrow)(tree, COLBASE, COLSLID, COLDOWN, 1, 
	    			col_max, col_min, &curcol, VERTICAL, nxtrow);
	    		break;
			case COLSLID:
				(*xcpb->MFsave)(MFSAVE, &orig_mf);
				if( AES_Version >= 0x0320 )
				    DRAG_MOUSE;
	    		(*xcpb->Sl_dragy)(tree, COLBASE, COLSLID, col_max, 
	    			col_min, &curcol, nxtgrp);
	    		(*xcpb->MFsave)(MFRESTORE, &orig_mf);
	    		break;
			case COLBASE:
    			Graf_mkstate(&mk);
    			objc_offset(tree, COLSLID, &ox, &oy);
    			if(mk.y < oy)
    	   			oy = -col_page;
       			else
    	    		oy = col_page;
				curslid = COLSLID;
	    		(*xcpb->Sl_arrow)(tree, COLBASE, COLSLID, -1, oy, 
	    			col_max, col_min, &curcol, VERTICAL, nxtpage);
	    		break;
	    
			case BNKRIGHT:
	    		(*xcpb->Sl_arrow)(tree, BNKBASE, BNKSLID, BNKRIGHT, 1, 
	    			BNK_MIN, BNK_MAX, &curbnk, HORIZONTAL, nxtbnk);
	    		break;
			case BNKLEFT:
	    		(*xcpb->Sl_arrow)(tree, BNKBASE, BNKSLID, BNKLEFT, -1, 
	    			BNK_MIN, BNK_MAX, &curbnk, HORIZONTAL, nxtbnk);
	    		break;
			case BNKSLID:
				(*xcpb->MFsave)(MFSAVE, &orig_mf);
				if( AES_Version >= 0x0320 )
				    DRAG_MOUSE;
	    		(*xcpb->Sl_dragx)(tree, BNKBASE, BNKSLID, BNK_MIN, 
	    			BNK_MAX, &curbnk, nxtbnk);
	    		(*xcpb->MFsave)(MFRESTORE, &orig_mf);
	    		break;
			case BNKBASE:
    			Graf_mkstate(&mk);
    			objc_offset(tree, BNKSLID, &ox, &oy);
    			if(mk.x < ox)
    	   			oy = -BNK_PAGE;
    			else
    	    		oy = BNK_PAGE;
	    		(*xcpb->Sl_arrow)(tree, BNKBASE, BNKSLID, -1, oy, 
	    			BNK_MIN, BNK_MAX, &curbnk, HORIZONTAL, nxtbnk);
	    		break;
	
			case DUO0:			/* for ST High rez */
			case DUO1:
	
			case QUARTRO0:		/* for ST Medium rez */
			case QUARTRO1:
			case QUARTRO2:
			case QUARTRO3:
		
			case BOX0:    		/* for all other rez */
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
				if (obj != curbox) {	/* select requested color */
					curcol = obj - headbox + headcol;
					nxt_to_show(0);
					update_slid(VERTICAL, COLBASE, COLSLID, curcol, 
						col_max, col_min, 1);
				}
	   			break;
	    
	   		case INVRSVDO:
	   			Deselect(obj);				/* deselect button */
				flip(0, &curinv);			/* read invert state */
	   			if (curinv & NOT_FLIPPED) {	/* inverted? */
	   				curinv &= 0xfffe;		/* if not, invert it */
	   			} else {					/* else */
	   				curinv |= NOT_FLIPPED;	/* restore it */
	   				draw_button(obj);		/* redraw button */
	   			}
	   			flip(1, &curinv);			/* set new invert state */
	   			
	   			if (bpg) {						/* if color */
	   				swaprgb(curnew, curnew+1);	/* swap pen 0 and 1 */
	   				open_vwork();
	   				vs_color(vhandle, 0, (int *)curnew);
	   				vs_color(vhandle, 1, (int *)(curnew+1));
	   				close_vwork();
	   				*curdirt = *(curdirt+1) = *touch_bnk = DIRTY;
	   				update_rgb(1);			/* update RGB sliders */
	   			}
	   			break;
	    
	   		case SETGRAY:
	   		case SETCOL:
	   			Deselect(obj);			/* deselect selected button */
	   			HideObj(obj);			/* hide selected button */
	   			if (obj == SETGRAY) {
	   				obj = SETCOL;		/* change to Color button */
	   				curgray = TRUE;		/* turn on hypermono */
	   			} else {
	   				obj = SETGRAY;		/* change to Gray button */
	   				curgray = FALSE;	/* turn off hypermono */
	   			}
	   			ShowObj(obj);			/* show new button */
	   			draw_button(obj);		/* draw it */
	   			Vsync();
	   			EsetGray(curgray);		/* set to selected mode */
	   			reinitcol();			/* reinit color regs */
	   			break;
	   				
			case COLSAVE:				/* save current values */
				if ((*xcpb->XGen_Alert)(SAVE_DEFAULTS) == TRUE) {
					(*xcpb->MFsave)(MFSAVE, &orig_mf);
					if( AES_Version >= 0x0320 )
					    BEE_MOUSE;
					
					if (bpg) {					/* if color */
						usr_vals.bnk = curbnk;	/* save bank # */
						savergb();				/* save color info */
												/* update RGBs */
						cpyrgb((RGB *)&oldrgb, (RGB *)&newrgb, totcol);	
					}
			
					if (currez == STHI)			/* if in ST high rez */
						usr_vals.inv = curinv;	/* save invert state */
					
					/* if hypermono supported, save state */
					if (curmode == TTVDO && currez != TTHI)
						usr_vals.gray = curgray;
		
					/* save current data to file */
					saved = 1;
					(*xcpb->CPX_Save)((void *)&saved, sizeof(DEFAULTS)+2);
					
	    			(*xcpb->MFsave)(MFRESTORE, &orig_mf);
				}
				Deselect(obj);
				draw_button(obj);	
	   			break;
	   	
			case COLCNCEL:
				cnclchgs();			/* cancel all changes made */
	   	
			case COLOK:				/* accept all changes made */
				Deselect(obj);				/* deselect button */
	   			quit = TRUE;				/* ready to quit */
	   			break;
	   			
	   		case COLRLOAD:			/* reload saved user-preference */
	   			if (saved)
	   				init(&usr_vals);
	   			else
	   				init(&def_vals);
	   			Deselect(obj);
	   			draw_button(obj);
	   			break;
	   	}
	} else {
		switch(msg[0]) {
			case WM_REDRAW:				/* redraw cpx */
				do_redraw((GRECT *)&msg[4], (int *)clip);
				break;
			
			case KEY_CODE:
				switch(msg[3]) {	/* check which key is returned */
					case UNDO:				/* if Undo key */
						/* reset to original invert state */
						if (currez == STHI && oldinv != curinv) {
							flip(1, &oldinv);
							if (!(oldinv & NOT_FLIPPED))
								Select(INVRSVDO);
							draw_button(INVRSVDO);
							Deselect(INVRSVDO);
							curinv = oldinv;
						}
						
						if (bpg) {			/* if there is color */
							if ((int)curmode == TTVDO && currez != TTHI
								&& curgray != oldgray) {
								Vsync();
								EsetGray(oldgray);
								reinitcol();
								if (oldgray) {
									HideObj(SETGRAY);
									obj = SETCOL;
								} else {
									HideObj(SETCOL);
									obj = SETGRAY;
								}
								ShowObj(obj);
								draw_button(obj);
								curgray = oldgray;
							}
							cnclbnk();		/* cancel color changes */
							update_rgb(1);	/* update RGB on screen */
						}
						break;
						
					case HOME:					/* if Clr Home key */
						if (currez != TTHI)		/* if not in TT High rez */
							init(&def_vals);	/* init to system defs */
						break;
				}
				break;
						
			case AC_CLOSE:
				cnclchgs();			/* cancel changes made */
					
			case WM_CLOSED:
				quit = TRUE;				/* ready to quit */
				break;
		}
	}
    } while (!quit);

    return (FALSE);
}


/*
 * Initialize system with given information.
 */
void
init(DEFAULTS *info)
{
	int i;	/* counter */
	
	open_vwork();
	
	/* if not boot time, on a color system and has more than 1 bank */
	if (!xcpb->booting && bpg && numbnk > 1) {
		for (curbnk = BNK_MIN; curbnk < NUM_BNK; curbnk++) {
			if (setup_bnk[curbnk] == CLEAN) {
				setup_bnk[curbnk] = DIRTY;
				visit_bnk(1);
				for (i = 0; i < numcol; i++) {
					vq_color(vhandle, i, 0, (int *)(curold+i));
				}
			}
		}
	}

	switch((int)curmode) {
		case TTVDO:					/* if TT video */
		
			if (info->gray != -1) {	/* set to color or gray scales */
				Vsync();
				EsetGray(info->gray);
			}
					
			switch(currez) {
				default:					/* in ST Low/Med, TT Med rez */
					if (info->bnk != -1) {
						EsetBank(0);
						slamcol(info->ubnk0.orez);
						/* set up colors in every bank */
						for (i = BNK_MIN+1; i < NUM_BNK; i++) {
							EsetBank(i);
							slamcol(info->obnk[i-1]);
						}
					
						/* set to desired bank */
						EsetBank(info->bnk);
					}
					break;	
					
				case STHI:					/* if in ST high rez */
					/* if invert state is saved, set it */
					if (info->inv != -1) {
						flip(1, &info->inv);
						if (!(info->inv & NOT_FLIPPED)) {
							swaprgb(&info->ubnk0.orez[0],
									&info->ubnk0.orez[1]);
							slamcol(info->ubnk0.orez);
							swaprgb(&info->ubnk0.orez[0],
									&info->ubnk0.orez[1]);
						} else {
							slamcol(info->ubnk0.orez);
						}
					} else {
						slamcol(info->ubnk0.orez);
					}
					break;
				
				case TTLOW:					/* if in TT low rez */
					slamcol(info->ubnk0.ttlow);
					break;
						
				case TTHI:					/* if in TT high rez */
					/* do nothing */
					break;
			}
			break;
			
		case STVDO:					/* if ST or STE video */
		case STEVDO:
			if (currez == STHI)	{			/* if in ST high rez */
				if (info->inv != -1)			/* if invert state saved */
					flip(1, &info->inv);		/* set to it */
			} else {
				slamcol(info->ubnk0.orez);
			}
			break;
	}
	
	if (!xcpb->booting) {		/* if not boot time */
		if (currez == STHI) {
			if (curinv != info->inv) {
				if (!(info->inv & NOT_FLIPPED))
					Select(INVRSVDO);
				draw_button(INVRSVDO);
				Deselect(INVRSVDO);
				curinv = info->inv;
			}
		}
						
		if ((int)curmode == TTVDO && currez != TTHI) {
			if (curgray != info->gray) {
				if (info->gray) {
					HideObj(SETGRAY);
					i = SETCOL;
				} else {
					HideObj(SETCOL);
					i = SETGRAY;
				}
				ShowObj(i);
				draw_button(i);
				curgray = info->gray;
			}
		}
		
		if (bpg) {				
			if (numbnk == 1) {
				touch_bnk[0] = DIRTY;
				for (i = 0; i < numcol; i++) {
					vq_color(vhandle, i, 0, (int *)(curnew+i));
					*(curdirt+i) = DIRTY;
				}
			} else {
				for (curbnk = BNK_MIN; curbnk < numbnk; curbnk++) {
					touch_bnk[curbnk] = setup_bnk[curbnk] = DIRTY;
					visit_bnk(1);
					for (i = 0; i < numcol; i++) {
						vq_color(vhandle, i, 0, (int *)(curnew+i));
						*(curdirt+i) = DIRTY;
					}
				}
				curbnk = info->bnk;
				visit_bnk(1);
				update_slid(HORIZONTAL, BNKBASE, BNKSLID, curbnk, 
					BNK_MIN, BNK_MAX, 1);
			}
			update_rgb(1);
		}
	}
	close_vwork();
 }


/*
 * Update R, G, B, color or bank index on screen.
 */
void
slidtext()
{
	switch (curslid) {
		
		case RSLID:
    		myitoa(curscrn[R], TedText(curslid));
			break;
			
		case GSLID:
    		myitoa(curscrn[G], TedText(curslid));
			break;
			
		case BSLID:
    		myitoa(curscrn[B], TedText(curslid));
			break;
			
		case BNKSLID:
    		myitoa(curbnk, TedText(curslid));
			break;
			
		case COLSLID:
    		myitoa(curcol, TedText(curslid));
			break;
			
		default:
			break;
	}
}


/*
 * Adjust color of selected color pen with
 * RGB gun values requested.
 */
void
adjcol()
{
	switch (curslid) {
		
		case RSLID:
			(curnew+curcol)->rint = val2int(curscrn[R]);
 			break;
			
		case GSLID:
			(curnew+curcol)->gint = val2int(curscrn[G]);
			break;
			
		case BSLID:
			(curnew+curcol)->bint = val2int(curscrn[B]);
			break;
	}
	slidtext();
	open_vwork();
	vs_color(vhandle, curcol, (int *)(curnew+curcol));
	close_vwork();
	*(curdirt+curcol) = touch_bnk[curbnk] = DIRTY;
}


/*
 * Show the next row of colors
 * (when using arrows to scroll through color map)
 */
void
nxtrow(void)
{
	nxt_to_show(COL_PER_ROW);
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
 * Show the next page of colors
 * (when using base to page through color map)
 */
void
nxtpage(void)
{
	nxt_to_show(MAX_COL_SHOWN);
}


/*
 * Show the selected color of the appropiate line or page 
 */
void
nxt_to_show(int toscroll)
{
	int obj;
	
	open_vwork();
	
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
	curslid = COLSLID;
	slidtext();				/* update color # */
	if (bpg)				/* if there is color */
		update_rgb(1);		/* update and draw RGB gun values */
		
	close_vwork();
}


/*
 * Update to next bank of available colors
 */
void
nxtbnk(void)
{
	curslid = BNKSLID;
	slidtext();					/* update bank # */
	Vsync();					/* wait for next vblank to occur */
	visit_bnk(1);				/* visit the desired Bank */
	reinitcol();				/* re-initialize color */
	update_rgb(1);				/* update and draw the RGB indices */
}


/*
 * Update all data structures of current bank
 *
 * set - 0: no need to set to current bank
 *       1: set to current bank
 */
void
visit_bnk(int set)
{	
	int i;		/* counter */
	RGB *ptr;	/* temp pointer */
	
	/* init pointers to offset to current bank */
	i = curbnk * numcol;			/* color 0 of current bank */
	curold = (RGB *)&oldrgb[i];		/* old RGBs of current bank */
	curnew = (RGB *)&newrgb[i];		/* new RGBs of current bank */
	curdirt = (char *)&dirt_col[i];	/* dirty list for current bank */
	
	if (set)						/* set to current bank if requested */
		EsetBank(curbnk);
		
	/* if bank has never been setup before, fill data structures */
	if (setup_bnk[curbnk] == CLEAN) {
		open_vwork();
		for (i = 0, ptr = curnew; i < numcol; i++, ptr = curnew+i) {
				vq_color(vhandle, i, 0, (int *)ptr);
				*(curold+i) = *ptr;
				*(curdirt+i) = CLEAN;
		}
		close_vwork();
		setup_bnk[curbnk] = DIRTY;	/* remember it's been setup */
	}

}


/*
 * Re-initialize color registers with the last requested values
 */
void
reinitcol(void)
{
	int i, *ptr;		/* index */
	
	open_vwork();
	for (i = 0, ptr = (int *)curnew; 
		i < numcol; 
		i++, ptr = (int *)(curnew+i)) {
		vq_color(vhandle, i, 0, ptr);
		vs_color(vhandle, i, ptr);
	}
	close_vwork();
}


/*
 * Highlight or de-highlight a color box
 */
void
outline(int obj, int flag)
{
	int	color;
	GRECT obrect;
	
	if (flag == HILITE)
		color = 1;			/* highlight box with foreground color */
	else
		color = 0;			/* de-light box with background color */
	
	wind_update(TRUE);
	HIDE_MOUSE;
	vsl_color(vhandle, color);
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
	SHOW_MOUSE;
	wind_update(FALSE);
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
    vq_color(vhandle, curcol, 0, (int *)ptr);
    close_vwork();
	
    /* Update the RGB gun values for current pen */
    oldscrn[R] = curscrn[R];
    oldscrn[G] = curscrn[G];
    oldscrn[B] = curscrn[B];
    curscrn[R] = int2val(ptr->rint);
    curscrn[G] = int2val(ptr->gint);
    curscrn[B] = int2val(ptr->bint);
	    		
	/* Record old location of sliders, and update indices	*/
    /* on R, G and B sliders if necessary 					*/
    if (oldscrn[R] != curscrn[R])
		update_slid(VERTICAL, RBASE, RSLID, curscrn[R], val_min, 
			val_max, draw);
    
    if (oldscrn[G] != curscrn[G])
		update_slid(VERTICAL, GBASE, GSLID, curscrn[G], val_min, 
			val_max, draw);
    
    if (oldscrn[B] != curscrn[B])
		update_slid(VERTICAL, BBASE, BSLID, curscrn[B], val_min, 
			val_max, draw);
}


/*
 * Update and draw (if requested) a specified slider
 */
void
update_slid(int direction, int base, int slider, int value, 
			int min, int max, int draw)
{
	GRECT	obrect;			/* location of slider */

	obrect = ObRect(slider);
	objc_offset(tree, slider, &obrect.g_x, &obrect.g_y);
	curslid = slider;
	
	if (direction == VERTICAL)
		(*xcpb->Sl_y)(tree, base, slider, value, min, max, slidtext);
	else
		(*xcpb->Sl_x)(tree, base, slider, value, min, max, slidtext);
	
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
 * Draw the color boxes
 */
void
draw_boxes(void)
{
	GRECT obrect;
	int obj, objcol;
	int lastbox;		
	
	wind_update(TRUE);
	HIDE_MOUSE;
	
	if (numcol < MAX_COL_SHOWN)				/* init last box to be drawn */
		lastbox = headbox + numcol - 1;
	else
		lastbox = headbox + MAX_COL_SHOWN - 1;
	
	vsf_interior(vhandle, SOLID);		/* fill with SOLID pattern */
	for (obj = headbox, objcol = headcol; 
		obj <= lastbox;
		obj++, objcol++) {
		
		vsf_color(vhandle, objcol);	/* fill with color of obj */
		obrect = ObRect(obj);
		objc_offset(tree, obj, &obrect.g_x, &obrect.g_y);
		pxyarray[0] = obrect.g_x;
		pxyarray[1] = obrect.g_y;
		pxyarray[2] = obrect.g_x + obrect.g_w - 1;
		pxyarray[3] = obrect.g_y + obrect.g_h - 1;
		v_bar(vhandle, pxyarray);
		
	}
	SHOW_MOUSE;
	wind_update(FALSE);
}


/*
 * Cancel changes made to any color
 */
void
cnclchgs(void)
{
	/* if in ST high rez and invert state has been changed */
	if (currez == STHI && oldinv != curinv)
		flip(1, &oldinv);		/* reset to original invert state */
		
	if (bpg > 0) {				/* if it's a color system */
		/* restore modified colors with old values for all banks */
		for (curbnk = BNK_MIN; curbnk < numbnk; curbnk++) {
			if (touch_bnk[curbnk] == DIRTY) {
				visit_bnk(1);
				cnclbnk();
			}
		}
		
		/* if hypermono mode supported, reset to original mode */
		if (curmode == TTVDO && currez != TTHI && oldgray != curgray) {
			Vsync();
			EsetGray(oldgray);
			reinitcol();
		}
	}
	
	if (numbnk > 1)	{				/* if there's bank switching */
		EsetBank(oldbnk);			/* reset to original bank */
		reinitcol();
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
	for (j = 0; j < numcol; j++) {		/* for all colors */
		if (*(curdirt+j) == DIRTY) {	/* if color modified */
										/* reset it */
			vs_color(vhandle, j, (int *)(curold+j));
			*(curnew+j) = *(curold+j);
		}
	}
	close_vwork();
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
			outline(curbox, HILITE);
			r1 = (*xcpb->GetNextRect)();
		}
		vs_clip(vhandle, 1, oldclip);	/* restore original clipping */
		close_vwork();
	}
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
 	for (i = 0; i < numcol; i++) {
 		if (col_array[i].rint == -1) {
 			vq_color(vhandle, i, 0, (int *)&col_array[i]);
		}
		vs_color(vhandle, i, (int *)&col_array[i]);
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
	RGB *savptr;		/* temp pointer */
	
	/* save RGBs of bank 0 */
	if (setup_bnk[0] == CLEAN) {
		curbnk = 0;
		visit_bnk(1);
	}
	
	if (currez == STHI && !(curinv & NOT_FLIPPED)) {
		swaprgb(&newrgb[0], &newrgb[1]);
		cpyrgb(usr_vals.ubnk0.ttlow, newrgb, numcol);
		swaprgb(&newrgb[0], &newrgb[1]);
	} else {
		cpyrgb(usr_vals.ubnk0.ttlow, newrgb, numcol);
	}
	
	/* if more banks of color, save RGBs of other banks */
	if (numbnk > 1) {
		for (curbnk = BNK_MIN+1, savptr = usr_vals.obnk[0];
			curbnk < numbnk; 
			curbnk++, savptr += COL_PER_BNK) {
			
			if (setup_bnk[curbnk] == CLEAN) {
				visit_bnk(1);
			} else {
				visit_bnk(0);
			}
			cpyrgb(savptr, curnew, numcol);
		}
		/* go back to desired bank */
		curbnk = usr_vals.bnk;
		visit_bnk(1);
	}
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



/*
 * Swap two RGB structures
 */
void
swaprgb(RGB *rgb1, RGB *rgb2)
{
	RGB temp;
	
	temp = *rgb1;
	*rgb1 = *rgb2;
	*rgb2 = temp;
}


/*
 * Read or set the word at FLIPLOC
 * set - flag to signify whether we are setting or reading the bit.
 *     - 1 means setting the word with the given value.
 *     - 0 means reading the word and returning the value.
 */
void
flip(int set, int *val)
{
	long ostack;		/* old stack value */
	
	ostack = Super(0L);
	if (set)
		*FLIPLOC = *val;
	else
		*val = *FLIPLOC;
	Super(ostack);
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
 * Convert a color gun value into a VDI color intensity.
 */
int
val2int(int val)
{
	return (val * 1000 / val_max);
}


/*
 * Convert a VDI color intensity into a color gun value.
 * Gun value = (Intensity * maximum gun value + 500) / 1000
 * (+500 for rounding)
 */
int
int2val(int intensity)
{
	return ((intensity * val_max + 500) / 1000);
}


/*
 * Draw a button
 */
void
draw_button(int button)
{
	GRECT obrect;
	
	obrect = ObRect(button);
	objc_offset(tree, button, &obrect.g_x, &obrect.g_y);
	Objc_draw(tree, button, 1, &obrect);
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
	if (!hcnt) {
		v_clsvwk(vhandle);
		vhandle = -1;
	}
}
