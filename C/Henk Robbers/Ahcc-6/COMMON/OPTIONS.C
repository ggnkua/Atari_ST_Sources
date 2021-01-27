/*  Copyright (c) 1992 - present by Henk Robbers Amsterdam.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* 	OPTIONS.C
 *	=========
 */

#include <string.h>

#include "aaaa_lib.h"
#include "hierarch.h"

#define __OPTIONS
#include "aaaa.h"
#ifdef KIT
#include "kit.h"
#endif
#if TTD_KIT
#include "digger/ttd_kit.h"
#include "wdial.h"
#endif
#include "config.h"
#include "text/editor.h"
#include "options.h"

#if DIGGER
VpV listconfig;
#endif

void send_msg  (char *text, ...);
void send_msg_n(char *text, ...);

bool diagnostics=false;
long nkcc_opt=0;
bool align_mode=false;
bool low_exp=false;

static
char *find_opt_text(OBJECT *m,short t, short f)
{
	char *s=get_freestring(m,0);

	while (*s)
		if ( *(s+1) ne ' ' and (*s eq t or *s eq f) )		/* trigger */
			break;
		else
			s++;
	return s;
}

static
char flip_option(OBJECT *m, char *truestr, char *falsestr)
{
	short t=*truestr,f=*falsestr;
	char *s=find_opt_text(m,t,f);
	char r=*s;

	if (r eq f)
		strcpy(s,truestr);
	else
	if (r eq t)
		strcpy(s,falsestr);

	return r;		/* from before the flipflop: returns requested state */
}

global
void initoptions(void)
{
/* NOTE: if the Menu entry contains the falsestr then the initial state
	is the opposite; hence 'eq falsestr'.
	if the Menu entry contains neither strings, then the initial state
	becomes false
	truestr = T_..., falsestr = F_...
*/
#ifdef MNFLYMODE
	move_mode  =*find_opt_text(&Menu[MNFLYMODE],*frstr(T_FLY  ),*frstr(F_FLY  )) eq *frstr(F_FLY  );
#endif
#ifdef MNMALIGN
	align_mode =*find_opt_text(&Menu[MNMALIGN ],*frstr(T_ALIGN),*frstr(F_ALIGN)) eq *frstr(F_ALIGN);
#endif
#ifdef MNLREXP
	low_exp =*find_opt_text(&Menu[MNLREXP ],*frstr(T_LEXP),*frstr(F_LEXP)) eq *frstr(F_LEXP);
#endif
}

typedef RECT WIDIV(RECT r, short up);

static
WIDIV bih
{	r.h/=2;
	if (up)
	{	r.y+=r.h+half_h();
		r.h-=    half_h();
	}
	return r;
}

static
WIDIV trih
{	r.h/=3;
	while (up--)
		r.y+=r.h;
	return r;
}

static
WIDIV biw
{	r.w/=2;
	if (up)
		r.x+=r.w;
	return r;
}

static
WIDIV triw
{	short u=up;
	r.w/=3;
	while (u--)
		r.x+=r.w;
	return r;
}

global
void do_Mode(IT *wt, short mt)
{
	if (is_drop(wt))
		wt = nil;

	switch(mt)
	{
#ifdef MNFLYMODE
		case MNFLYMODE:
		{
			char s=flip_option(&menu[MNFLYMODE],frstr(T_FLY),frstr(F_FLY));

			if (s)
				if (s eq *frstr(T_FLY))
					move_mode=HOLD;
				else
					move_mode=CLICK;
		}
		break;
#endif
#ifdef MNMALIGN
		case MNMALIGN:
		{
			char s=flip_option(&menu[MNMALIGN],frstr(T_ALIGN),frstr(F_ALIGN));

			if (s)
				if (s eq *frstr(T_ALIGN))
					align_mode=ALMOUSE;
				else
					align_mode=ALMENU;
		}
		break;
#endif
#if MNLREXP		/* Mandelbrot expand low res */
		case MNLREXP:
		{
			char s=flip_option(&Menu[MNLREXP],frstr(T_LEXP),frstr(F_LEXP));

			if (s)
				if (s eq *frstr(T_LEXP))
					low_exp=true;
				else
					low_exp=false;
		}
		break;
#endif
#ifdef MNWINDOW
		case MNWINDOW:
			kit_dial(wt,  0, MNWINDOW);
		break;
#endif
#ifdef MNMULT
		case MNMULT:
			kit_dial(nil, 0, MNMULT);
		break;
#endif
#ifdef MNFOLDERS					/* 07'14 HR v5.1 */
		case MNFOLDERS:
			kit_dial(nil, 0, MNFCOMP);
		break;
#endif
#ifdef MNFCOMP
		case MNFCOMP:
			comp_folder(0);
		break;
#endif
#ifdef MNFDIFF
		case MNFDIFF:
			comp_folder(1);
		break;
#endif

#ifdef MNTILE
		case MNTILE:
		{
			RECT wrs[WIDIVMAX],d=wwa;
			short wi;
			short i=w_handles(whs,for_tile);
			/* to do: determine horizontal division from screen width: */
			if (i)
			{
#if TEXTFILE
				switch (i)
				{
				case 1:
					if (wwa.w < 1600)
						wrs[0]=biw(d,0);
					else
						wrs[0]=triw(d,0);
				break;
				case 2:
					if (wwa.w < 1600)
					{
						wrs[0]=biw(d,0);
						wrs[1]=biw(d,1);
					othw
						wrs[0]=triw(d,0);
						wrs[1]=triw(d,1);
					}
				break;
				case 3:
					if (wwa.w < 1600)
					{
						wrs[0]=biw(d,       0);
						wrs[1]=biw(bih(d,0),1);
						wrs[2]=biw(bih(d,1),1);
					othw
						wrs[0]=triw(d,0);
						wrs[1]=triw(d,1);
						wrs[2]=triw(d,2);
					}
				break;
				case 4:
					if (wwa.w < 1600)
					{
						wrs[0]=biw(bih(d,0),0);
						wrs[1]=biw(bih(d,0),1);
						wrs[2]=biw(bih(d,1),0);
						wrs[3]=biw(bih(d,1),1);
					othw
						wrs[0]=triw(d,       0);
						wrs[1]=triw(d,       1);
						wrs[2]=triw(bih(d,0),2);
						wrs[3]=triw(bih(d,1),2);
					}
				break;
				case 5:
					if (wwa.w < 1600)
					{
						wrs[0]=biw(bih (d,0),0);
						wrs[1]=biw(bih (d,1),0);
						wrs[2]=biw(trih(d,0),1);
						wrs[3]=biw(trih(d,1),1);
						wrs[4]=biw(trih(d,2),1);
					othw
						wrs[0]=triw(d,       0);
						wrs[1]=triw(bih(d,0),1);
						wrs[2]=triw(bih(d,0),2);
						wrs[3]=triw(bih(d,1),1);
						wrs[4]=triw(bih(d,1),2);
					}
				break;
				case 6:
					wrs[0]=triw(bih(d,0),0);
					wrs[1]=triw(bih(d,0),1);
					wrs[2]=triw(bih(d,0),2);
					wrs[3]=triw(bih(d,1),0);
					wrs[4]=triw(bih(d,1),1);
					wrs[5]=triw(bih(d,1),2);
				break;
				case 7:
					wrs[0]=triw(bih (d,0),0);
					wrs[1]=triw(bih (d,0),1);
					wrs[2]=triw(trih(d,0),2);
					wrs[3]=triw(bih (d,1),0);
					wrs[4]=triw(bih (d,1),1);
					wrs[5]=triw(trih(d,1),2);
					wrs[6]=triw(trih(d,2),2);
				break;
				case 8:
					wrs[0]=triw(bih (d,0),0);
					wrs[1]=triw(bih (d,1),0);
					wrs[2]=triw(trih(d,0),1);
					wrs[3]=triw(trih(d,0),2);
					wrs[4]=triw(trih(d,1),1);
					wrs[5]=triw(trih(d,1),2);
					wrs[6]=triw(trih(d,2),1);
					wrs[7]=triw(trih(d,2),2);
				break;
				case 9:
					wrs[0]=triw(trih(d,0),0);
					wrs[1]=triw(trih(d,0),1);
					wrs[2]=triw(trih(d,0),2);
					wrs[3]=triw(trih(d,1),0);
					wrs[4]=triw(trih(d,1),1);
					wrs[5]=triw(trih(d,1),2);
					wrs[6]=triw(trih(d,2),0);
					wrs[7]=triw(trih(d,2),1);
					wrs[8]=triw(trih(d,2),2);
				break;
				}
#else
				switch (i)
				{
				case 1:
					wrs[0]=d;		/* same as full */
				break;
				case 2:
					wrs[0]=biw(d,0);
					wrs[1]=biw(d,1);
				break;
				case 3:
					wrs[0]=biw(bih(d,0),0);
					wrs[1]=biw(bih(d,0),1);
					wrs[2]=    bih(d,1)   ;
				break;
				case 4:
					wrs[0]=biw(bih(d,0),0);
					wrs[1]=biw(bih(d,0),1);
					wrs[2]=biw(bih(d,1),0);
					wrs[3]=biw(bih(d,1),1);
				break;
				case 5:
					wrs[0]=biw(trih(d,0),0);
					wrs[1]=biw(trih(d,0),1);
					wrs[2]=biw(trih(d,1),0);
					wrs[3]=biw(trih(d,1),1);
					wrs[4]=    trih(d,2)   ;
				break;
				case 6:
					wrs[0]=triw(bih(d,0),0);
					wrs[1]=triw(bih(d,0),1);
					wrs[2]=triw(bih(d,0),2);
					wrs[3]=triw(bih(d,1),0);
					wrs[4]=triw(bih(d,1),1);
					wrs[5]=triw(bih(d,1),2);
				break;
				case 7:
					wrs[0]=triw(trih(d,0),0);
					wrs[1]=triw(trih(d,0),1);
					wrs[2]=triw(trih(d,0),2);
					wrs[3]=triw(trih(d,1),0);
					wrs[4]=triw(trih(d,1),1);
					wrs[5]=triw(trih(d,1),2);
					wrs[6]=     trih(d,2)   ;
				break;
				case 8:
					wrs[0]=triw(trih(d,0),0);
					wrs[1]=triw(trih(d,0),1);
					wrs[2]=triw(trih(d,0),2);
					wrs[3]=triw(trih(d,1),0);
					wrs[4]=triw(trih(d,1),1);
					wrs[5]=triw(trih(d,1),2);
					wrs[6]= biw(trih(d,2),0);
					wrs[7]= biw(trih(d,2),1);
				break;
				case 9:
					wrs[0]=triw(trih(d,0),0);
					wrs[1]=triw(trih(d,0),1);
					wrs[2]=triw(trih(d,0),2);
					wrs[3]=triw(trih(d,1),0);
					wrs[4]=triw(trih(d,1),1);
					wrs[5]=triw(trih(d,1),2);
					wrs[6]=triw(trih(d,2),0);
					wrs[7]=triw(trih(d,2),1);
					wrs[8]=triw(trih(d,2),2);
				break;
				}
#endif
				loop(wi,i)
				{
					IT *w = get_it(whs[wi],-1);
					if (w)
					{
						via (w->sized)(w,&wrs[wi]);
#if IMGS
						via (w->slide)(w,500,500,false);		/* keep images centered :-) */
#endif
					}
				}
			}
		}
		break;
#endif
#ifdef MNOVLAP
		case MNOVLAP:
		{
			RECT d;
			short wi;
			short i=w_handles(whs,no_dial);
			loop (wi,i)
			{
				short h_h=half_h();
				IT *w = get_it(whs[wi],-1);
				d=wwa;
				d.x+=wi*h_h;
				d.y+=wi*h_h;
				d.w-=WIDIVMAX*h_h;
				d.h-=WIDIVMAX*h_h;
				if (w)
					via (w->sized)(w,&d);
			}
		}
		break;
#endif
#ifdef MNFKEYS
	#if FKS
		case MNFKEYS:
		{
			extern char fkeystr[FKS][FKL];
			short i;
			send_msg("%%: position of cursor if present, else after last character.\n");
			loop(i, FKS)
				if (fkeystr[i][0])
					send_msg("Function key%3d = %s\n", i+1, fkeystr[i]);
			send_msg("\n");
		}
		break;
	#endif
#endif
#ifdef MNBUF
		case MNBUF:
			open_buf();
		break;
#endif
#ifdef MNCYCL
		case MNCYCL:
			cyclewindows(wt);
		break;
#endif
#ifdef MNHOOKS
		case MNHOOKS:
			kit_dial(nil, 0, MNHOOKS);
		break;
#endif
#ifdef HELP
		case HELP:
		{
			char word[MAXL+1];
			*word = 0;
			{
	#if SELECTION
				void select_and_get_word(IT *w, char *word);
				IT *w = get_top_it();		/* get top window if one of mine */
				if (w)
					select_and_get_word(w, word);
	#endif
				start_help(word);
			}
		}
		break;
#endif
#if defined MNPRINFO and defined PRWINFO
		case MNPRINFO:
		{
			short sd=diagnostics;
			STMC *ws;
			IT *w;

			diagnostics=true;		/* independant of ... */

			ws=stmfifirst(&winbase);

			while (ws)
			{
				w=ws->wit;
				print_it(w,"Menu");
				ws=stmfinext(&winbase);
			}

			print_it(&deskw,"Menu");
			diagnostics=sd;
		}
		break;
#endif
#ifdef MNCONFIG
		case MNCONFIG:
			wind_dial(TTD_KIT, TTDK1);		/* opens window or puts on top
									           with TTDK1 visible        */
		break;
#endif
#ifdef MNLCONF
		case MNLCONF:
			listconfig();
		break;
#endif
#if !WKS and !MFRAC
		default:
	#if DIGGER
			opt_to_cfg(ttdcfg,mt,AMENU,pkit.tree,Menu);
			if (!wt)
				wt = &deskw;
			opt_to_cfg(wt->cg_tab,mt,AMENU,pkit.tree,Menu);
	#else
			opt_to_cfg(settab,mt,AMENU,pkit.tree,Menu);
			if (!wt)
				wt = &deskw;
			opt_to_cfg(wt->loctab,mt,AMENU,pkit.tree,Menu);
	#endif
#endif
	}
	menu_tnormal(Menu,MTM,true);
}
