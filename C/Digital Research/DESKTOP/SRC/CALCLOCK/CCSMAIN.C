/*	CCSMAIN.C	08/03/84 - 06/20/85	Andrew Muir		*/
/*	took out wm_yfix	2/27/86		LKW			*/
/*	added drive for spooler		11/3/87		mdf		*/

/*** INCLUDE FILES ******************************************************/

#include <portab.h>
#include <machine.h>
#if GEMDOS
#if TURBO_C
#include <aes.h>
#include <vdi.h>
#endif
#else
#include <obdefs.h>
#include <gembind.h>
#endif
#include <rclib.h>
#include "taddr.h"
#include "ccsmain.h"

/*** DEFINES ***********************************************************/

#define SPOLFILE 100

/*** GLOBAL VARIABLES ***************************************************/

EXTERN LONG	ini_calc(VOID);
EXTERN LONG	ini_clok(VOID);
EXTERN LONG	ini_spol(VOID);

EXTERN LONG	set_timer(VOID);

WORD	gl_apid;
WORD	gl_handle;

EXTERN LONG	ad_calc;
EXTERN WORD	wh_calc;
EXTERN WORD	gl_itcalc;

EXTERN LONG	ad_clok;
EXTERN WORD	wh_clok;
EXTERN WORD	gl_itclok;	

EXTERN LONG	ad_spol;
EXTERN WORD	wh_spol;
EXTERN WORD	gl_itspol;	
EXTERN WORD	gl_spnxt;

EXTERN BYTE	*gl_disp;

EXTERN WORD	last_op, last_key;
EXTERN BYTE	inp_str[DISP_LEN+1], inp_idx;

EXTERN WORD	last_calc;
EXTERN WORD	last_clok;

EXTERN BYTE	stack_num;
EXTERN BYTE	dec_pt1,dec_pt2;
EXTERN UBYTE	neg1,neg2;
EXTERN BYTE	num_dig;
EXTERN WORD	add_on;
EXTERN BYTE	stack_pt;
EXTERN BYTE	pt_seen,eror;
EXTERN UBYTE	op1[10],op2[10],result[10],memory[10];
EXTERN BYTE	temp_pt;
EXTERN WORD	al_min,al_hour;
EXTERN WORD	done_one;
EXTERN WORD	al_set;
EXTERN WORD	not_zero;
EXTERN LONG MEMEMPTY;
EXTERN LONG MEMFULL;
EXTERN LONG TIMEON;
EXTERN LONG ALARMON;
 
GLOBAL WORD	gl_rmsg[8];
GLOBAL LONG	ad_rmsg;

GLOBAL WORD	gl_xdesk;
GLOBAL WORD	gl_ydesk;
GLOBAL WORD	gl_wdesk;
GLOBAL WORD	gl_hdesk;

GLOBAL WORD	gl_flags;
GLOBAL WORD	gl_button;
GLOBAL WORD	gl_wtop;

GLOBAL WORD	gl_wchar;
GLOBAL WORD	gl_hchar;
GLOBAL WORD	gl_wbox;
GLOBAL WORD	gl_hbox;
GLOBAL WORD     color;


/*
*		Opens the desk accessorie's window.
*/
VOID do_open(WORD wh, WORD x, WORD y, WORD w, WORD h)
{
	graf_mouse(2, 0x0L);
	graf_growbox(2*gl_wchar, 0, 4*gl_wchar, gl_hchar, x, y, w, h);
	wind_open(wh, x, y, w, h);
	graf_mouse(0, 0x0L);
} /* do_open */


/*
*		Closes the desk accessorie's window.
*/
VOID do_close(WORD wh)
{
	WORD		x, y, w, h;

	graf_mouse(2, 0x0L);
	wind_get(wh, WF_CURRXYWH, &x, &y, &w, &h);
	wind_close(wh);
	graf_shrinkbox(2*gl_wchar, 0, 4*gl_wchar, gl_hchar, x, y, w, h);
	graf_mouse(0, 0x0L);
} /* do_close */


/*
*		Draws the object "obj_disp",from either the clock
*		or the calculator or the spooler trees.
*/
VOID do_redraw(WORD w_handle, WORD obj_disp, WORD depth,
		WORD xc, WORD yc, WORD wc, WORD hc)
{
	GRECT	redraw, coord;
	LONG	tree;

 	tree = 0x0L;
	if (w_handle)
	{
		if (w_handle == wh_calc)
			tree = ad_calc;
		if (w_handle == wh_clok)
			tree = ad_clok;
		if (w_handle == wh_spol)
			tree = ad_spol;
	}
	if (tree)
	{
		graf_mouse(M_OFF, 0x0L);
		wind_get(w_handle, WF_FIRSTXYWH,
			&redraw.g_x, &redraw.g_y, &redraw.g_w, &redraw.g_h);
		coord.g_x = xc;
		coord.g_y = yc;
		coord.g_w = wc;
		coord.g_h = hc;
		while ( coord.g_w && coord.g_h )
		{
			if ( rc_intersect(&coord, &redraw) )  
				objc_draw((OBJECT FAR *)tree, obj_disp, depth,
					redraw.g_x, redraw.g_y, redraw.g_w, redraw.g_h);
			wind_get(w_handle, WF_NEXTXYWH,
				&redraw.g_x, &redraw.g_y, &redraw.g_w, &redraw.g_h);
		}
		graf_mouse(M_ON, 0x0L);
	}
}


/*
*		Creates and positions the desk accessorie's window
*		and opens the accessory onto the window.
*/
WORD ac_open(OBJECT olist[], BYTE *pname)
{
	WORD		wh;
	WORD		x, y, w, h;

	/* 0x0B = NAME | CLOSER | MOVER	*/
	wh = wind_create(0x000B, gl_xdesk, gl_ydesk, gl_wdesk, gl_hdesk);
	if (wh != -1)
	{
		wind_set(wh, WF_NAME, ADDR(pname), 0, 0);
		wind_calc(WC_BORDER, 0x000B, olist[0].ob_x, olist[0].ob_y,
			olist[0].ob_width, olist[0].ob_height, &x, &y, &w, &h);
		x = wm_xfix(x); 
		wind_calc(WC_WORK, 0x000B, x, y, w, h, 
			&olist[0].ob_x, &olist[0].ob_y,
			&olist[0].ob_width, &olist[0].ob_height);
		do_open(wh, x, y, w, h);
	}
	return(wh);
}


/*
*		aligns the desk accessories window with a byte
*		boundary.
*/
WORD wm_xfix(WORD rx)
{ 	       
	return((rx & 0xfff0) + ((rx & 0x000c) ? 0x10 : 0));
}


WORD do_accopen(WORD rm4, WORD itnum, WORD *pwh,
		OBJECT oblist[], BYTE *pstr)
{
	/* Opens the clock. */
	if (rm4 == itnum)
	{	
		if (*pwh)
			wind_set(*pwh, WF_TOP, 0, 0, 0, 0);
		else
		{
			*pwh = ac_open(&oblist[0], pstr); 
			if (*pwh == -1)
				*pwh = 0;
			else
				return( TRUE );
		}
	}
	return( FALSE );
}


/*
*		Processes all messages sent to the desk accessories
*/
VOID hndl_mesag(VOID)
{
	WORD		ii;
	WORD		x, y, w, h;

	x = gl_rmsg[4];
	y = gl_rmsg[5];
	w = gl_rmsg[6];
	h = gl_rmsg[7];

	switch( gl_rmsg[0] )
	{
		case SPOLFILE:
			hndl_spmsg(gl_rmsg[3], 
				LW(gl_rmsg[4]) + HW(gl_rmsg[5]),
				gl_rmsg[6], gl_rmsg[7], gl_rmsg[2]);
			spol_ansr(gl_rmsg[1]);
			break;
		case AC_OPEN:	   
			/* Opens the calculator    */
			/* and clears the display. */
			if (do_accopen(gl_rmsg[4], gl_itcalc, &wh_calc, &the_calc[0],
				" Calculator ") )
			{
				calc_reset();
			}
			/* Opens the clock. */
			do_accopen(gl_rmsg[4], gl_itclok, &wh_clok, &the_clok[0],
				" Clock ");
			/* Opens the spooler. */
			do_accopen(gl_rmsg[4], gl_itspol, &wh_spol, &the_spol[0],
				" Print Spooler ");
			break;
		case WM_REDRAW:
			/* Draws the desk accessory */
			/* whose handle is in	    */
			/* gl_rmsg[3].		    */
			do_redraw(gl_rmsg[3], ROOT, MAX_DEPTH, x, y, w, h);
			/* If the clock was drawn  */
			/* it displays the correct */
			/* time and date.	*/
			if (gl_rmsg[3] == wh_clok)
			{
				show_hour();
				show_min();
				show_ampm();    
				show_month();
				show_date();
				show_year();	 
			}
			break;				    
		case WM_TOPPED:
			/* Brings the desk  */
			/* accessory whose  */
			/* handle is in     */
			/* gl_rmsg[3] to    */
			/* top.		    */
			wind_set(gl_rmsg[3], WF_TOP, 0, 0, 0, 0);
			break;
		case WM_CLOSED:
			/* Close the top desk ac- */
			/* cesory.	          */
			do_close(gl_rmsg[3]);
			wind_delete(gl_rmsg[3]);
			if (gl_wtop == wh_calc)
			{
				wh_calc = 0;	      
				calc_reset();
			}
			if (gl_wtop == wh_clok)
			{		     
				wh_clok = 0;
#if TURBO_C
				the_clok[SW_TIME].ob_spec.index = TIMEON;
#else
				the_clok[SW_TIME].ob_spec = TIMEON;
#endif
			}
			if (gl_wtop == wh_spol)
				wh_spol = 0;	     
			break;
		case AC_CLOSE:
			/* Close the desk accessory */
			/* when an application ter- */
			/* ates.		    */	
			wh_clok = 0;
			wh_calc = 0;
			wh_spol = 0;
			/* clear spooler stuff	*/
			if (gl_rmsg[4] == gl_itspol)
			{
				/* to be determined	*/
			}
			/* clear clock time	*/
			if (gl_rmsg[4] == gl_itclok)
			{
#if TURBO_C
				the_clok[SW_TIME].ob_spec.index = TIMEON;
#else
				the_clok[SW_TIME].ob_spec = TIMEON;
#endif
			}
			/* Clear the calc display */
			if  (gl_rmsg[4] == gl_itcalc)
			{	
				calc_reset();
				/* Clear memory. */
#if TURBO_C
				the_calc[MEMFLG].ob_spec.index = MEMEMPTY;
#else
				the_calc[MEMFLG].ob_spec = MEMEMPTY;
#endif
				for (ii = 0;ii < 10;memory[ii++] = 0)
					;
			}
			break;
		case WM_MOVED:
			/* Move the desk accessory */
			x = wm_xfix(gl_rmsg[4]);
			y = gl_rmsg[5];
			wind_set(gl_rmsg[3], WF_CURRXYWH, x, y, w, h);
			wind_get(gl_rmsg[3], WF_WORKXYWH, &x, &y, &w, &h);
			if (gl_rmsg[3] == wh_calc)
			{
				the_calc[ROOT].ob_x = x;
				the_calc[ROOT].ob_y = y;
			}
			if (gl_rmsg[3] == wh_clok)
			{
				the_clok[ROOT].ob_x = x;
				the_clok[ROOT].ob_y = y;
			}
			if (gl_rmsg[3] == wh_spol)
			{
				the_spol[ROOT].ob_x = x;
				the_spol[ROOT].ob_y = y;
			}
			break;
	} /* switch */
	gl_rmsg[0] = 0;
} /* hndl_mesag */


/************************************************************************/
/* m a i n								*/
/************************************************************************/
VOID main(VOID)
{
	LONG		tree;
	UWORD		amnt_wait;
	WORD		ev_which;
	WORD		spec[4];
	WORD		mx, my, mb, ks, kret, bret;
	WORD		curr_ob;
	OBJECT		*pobs;
	WORD		x, y, w, h;

	gl_apid = appl_init();
	gl_handle = graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
	color = 2;
	/* register as desk accessory */
	gl_itcalc = menu_register(gl_apid, ADDR("  Calculator") );
	gl_itclok = menu_register(gl_apid, ADDR("  Clock"));
	gl_itspol = menu_register(gl_apid, ADDR("  Print Spooler"));
	/* init. message address*/
	ad_rmsg = (LONG)ADDR(&gl_rmsg[0]);
	/* get desktop size	*/
	wind_get(0, WF_WORKXYWH, &gl_xdesk, &gl_ydesk, &gl_wdesk, &gl_hdesk);
	/* initialize mouse	*/
	graf_mouse(0, 0x0L);
	/* initialize calc	*/		  
	ad_calc = ini_calc();
   	ad_clok = ini_clok();
	ad_spol = ini_spol();
	/* starting spot is	centered on desk */
	the_calc[ROOT].ob_y = (gl_hdesk - the_calc[ROOT].ob_height) / 2;
	the_calc[ROOT].ob_x = (gl_wdesk - the_calc[ROOT].ob_width) / 2;
	/* starting spot is the upper left corner */
	the_clok[ROOT].ob_y = (the_clok[ROOT].ob_height + 2); 
	the_clok[ROOT].ob_x = 6;
	/* starting spot is the lower left corner */
	the_spol[ROOT].ob_y = gl_hdesk - the_spol[ROOT].ob_height; 
	the_spol[ROOT].ob_x = 6;
	/* get ready for main loop */
	gl_flags = MU_BUTTON | MU_MESAG | MU_KEYBD | MU_TIMER;
	gl_button = 0x01;
	/* Clear display	*/
	al_min = 0;
	al_hour = 0;
	al_set = FALSE;
	/* kludge to init calc */
	calc_reset();
	hndl_calc(ZERO);	
	hndl_calc(TIMES);	
	hndl_calc(ZERO);	
	hndl_calc(EQUAL);	
	last_clok = 0;
	wh_calc = 0;
	wh_clok = 0;
	wh_spol = 0;
	gl_wtop = 0;
	/* init spooler */
	spol_int();
	/* begin main loop */
	while (TRUE)
	{
		/* wait for mouse button to go down */
		ev_which = evnt_multi(gl_flags, 0x01, 0x01, gl_button,
				0, 0, 0, 0, 0,
				0, 0, 0, 0, 0,
				(WORD *)ad_rmsg, (WORD)set_timer(), 0,
				&mx, &my, &mb, &ks, &kret, &bret);

		/* handle timer */
		if (ev_which == MU_TIMER)
		{
			if (gl_spnxt)
			{
				if ( !spol_doit() )
					spol_more();
				if ( (amnt_wait++ % 16000) != 0 )
					ev_which = 0;
			}
		}

		if (ev_which)
		{
			wind_update(TRUE);
			wind_get(0, WF_TOP, &gl_wtop, &spec[1], &spec[2], &spec[3]);
			if (!gl_wtop)
				gl_wtop = -1;
		}
		/* handle timer		*/

		if (ev_which & MU_TIMER)
			change_time();	
		/* handle message	*/
		if (ev_which & MU_MESAG)
			hndl_mesag();
		/* handle keyboard	*/
		if (ev_which & MU_KEYBD)
		{
			/* if spooler on top	*/
			if (gl_wtop == wh_spol)
			{	
			}
			/* if clock on top	*/
			if (gl_wtop == wh_clok)
			{	
				curr_ob = (kret & 0x00ff);
				hndl_clok(curr_ob);
			}
			/* if calculator on top	*/
			if (gl_wtop == wh_calc)
			{
				if (set_timer() > 58000L)
					change_time();
				/* find key entered	*/
				curr_ob = find_chr( (kret & 0x00ff));	
				last_key = curr_ob;
				if ( (curr_ob) && 
					(curr_ob != THE_E) && 
					(curr_ob != THE_M) )
				{
					/* highlight the selected key */
					tree = ad_calc;
					objc_offset((OBJECT FAR *)tree, curr_ob, &x, &y);
					pobs = (OBJECT *) (LLOWD(tree) + (curr_ob * sizeof(OBJECT)));
					w = pobs->ob_width;
					h = pobs->ob_height;
					objc_change((OBJECT FAR *)tree, curr_ob, 0, x, y, w, h, SELECTED, TRUE);
					evnt_timer(0, 0);
					objc_change((OBJECT FAR *)tree, curr_ob, 0, x, y, w, h, NORMAL, TRUE);
					hndl_calc(curr_ob);	
				}
			}
		}
		/* handle mouse		*/  
		if (ev_which & MU_BUTTON)
		{
			if (gl_wtop == wh_spol)
				tree = ad_spol;
			if (gl_wtop == wh_clok)
				tree = ad_clok;
			if (gl_wtop == wh_calc)
			{
				if (set_timer() > 58000L)
					change_time();
				tree = ad_calc;
			}
			/* find out what the	*/
			/*   mouse is over	*/
			curr_ob = objc_find((OBJECT FAR *)tree, ROOT, MAX_DEPTH, mx, my);
			/* find out what the	*/
			/*   mouse is over	*/
			if (gl_wtop == wh_spol)
			{
				/* do rubber box	*/
				if ( (curr_ob >= 0) && (curr_ob <= F12NAME) )
				{
					hndl_spsel(mx, my, mb, ks);
					curr_ob = 0;
				}
				else
				{
					if (curr_ob == NIL)
						curr_ob = 0;	
				}
			}
			if (gl_wtop == wh_clok)
			{
				if ( (curr_ob == NIL) ||
					(curr_ob == THECLOCK) ||
					(curr_ob == TOPBOX) ||
					(curr_ob == LOWBOX) )
				{
					curr_ob = 0;
				}
			}
			if (gl_wtop == wh_calc)
			{
				if ( (curr_ob == NIL) ||
					(curr_ob == THECALC) ||
					(curr_ob == THEDISP) )
				{
					curr_ob = 0;
				}
			}

			if (curr_ob)
			{
				if ( graf_watchbox((OBJECT FAR *)tree, curr_ob, SELECTED, NORMAL) )
				{
					objc_offset((OBJECT FAR *)tree, curr_ob, &x, &y);
					pobs = (OBJECT *) (LLOWD(tree) + (curr_ob * sizeof(OBJECT)));
					w = pobs->ob_width;
					h = pobs->ob_height;
					objc_change((OBJECT FAR *)tree, curr_ob, 0, x, y, w, h, NORMAL, TRUE);
				}
				else
					curr_ob = 0;
			}

			if ( (gl_wtop == wh_spol) && (curr_ob) )
				hndl_spbut(curr_ob);  

			if ( (gl_wtop == wh_clok) && (curr_ob) )
				hndl_clok(curr_ob);  

			if ( (gl_wtop == wh_calc) && (curr_ob) )
				hndl_calc(curr_ob);  
		}

		if (ev_which)
		{
			wind_get(0, WF_TOP, &gl_wtop, &spec[1], &spec[2], &spec[3]);
			if (!gl_wtop)
				gl_wtop = -1;
			wind_update(FALSE);
		}
	}

	/* since we're a desk	*/
	/*   accessory we should*/
	/*   never terminate	*/
} /* main */
