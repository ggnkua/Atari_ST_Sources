/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                          Copyright 1990 Tom Bajoras

	module CNXEDIT : CNX editor

	edit_cnx

******************************************************************************/

overlay "cnxedit"

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "scan.h"			/* keyboard scan codes */
#include "genedit.h"		/* created by RCS */
#include "externs.h"		/* global variables */

/* local defines and global variables .......................................*/

#define LNSPERWIND 21	/* how many lines fit in window */
#define WDELTA (CNXESEGR - CNXESEGL)

int cnxsegscan[NSEGTYPES]= {
	SCAN_T, SCAN_R, SCAN_M, SCAN_U, SCAN_S, SCAN_I,
	SCAN_G, SCAN_P, SCAN_V, SCAN_C
};

int linemem;				/* heap block containing text in top window */
int home_c[2];				/* 1st column in window */
char *otherbuf;			/* --> untopped window contents */
long whichseg[2]= { cnxTRAN, cnxRECV }; /* which segment is in each window */
char dispmode[2]={1,1};		/* 0= hidden behind full window,
										1= half window, 2= full window */
int topwindow;				/* which window is topped: 0= left, 1= right */
int half_full;				/* amount to stretch/squeeze window */
int hometoken[2];			/* 1st token in window */
int ntokens[NSEGTYPES];	/* how many tokens (lines) in segment (can be 0) */
int nlines[2];				/* how many lines of source code in windows */
int curs_r,curs_c;		/* cursor position relative to window home */
int curs_hx,curs_hy;		/* cursor home (y-coord of top of cursor) */
int ncols;					/* # columns in top window */
int curs_lx,curs_ly;		/* cursor anti-home (y-coord of bottom of cursor) */
int sourcechanged;		/* set when text in top window gets changed */
int whichcnx;				/* 0 - (NCNX-1) */

/* edit a config ............................................................*/

edit_cnx(i)
register int i;
{
#if CNXFLAG
	static int fixed;
	register int j,w;
	register long templong;
	register char *cptr;
	int exit_obj,mstate,done,mousex,mousey;
	int edit_obj= -1;
	int kstate,key,error,font;
	int x1,y1,w1,h1,x2,y2,w2,h2;
	int segmenu[NSEGTYPES];
	long *ptr1,*ptr2,*end,ptr;

	whichcnx=i;

	/* run-time resource modification */
	if (!fixed)
	{
		full_dial(cnxeaddr);
		i= rez<<2;
		cnxeaddr[CNXEWNDL].ob_y += i;
		cnxeaddr[CNXEWNDR].ob_y += i;
		half_full= cnxeaddr[CNXEWNDR].ob_x - cnxeaddr[CNXEWNDL].ob_x;
		fixed=1;
	}

	/* start with nothing changed */
	sourcechanged=0;

	linemem= -1;							/* start with no source code buffer */
	otherbuf= (char*)(cnxscrsave);	/* non-topped window contents */

	/* count tokens in each segment, un-tokenize segments in windows */
	for (i=0; i<NSEGTYPES; i++)
	{
		j= ntokens[i]= detoken_seg(whichcnx,i,0,0L);
		if (i==whichseg[topwindow])
		{
		/* allocate source buffer for top window: one blank line at end */
			nlines[topwindow]= j+1;
			linemem= alloc_mem( CNXTOKENW * (j+1) );
			if (linemem<0) return;
			templong= heap[linemem].start;
			detoken_seg(whichcnx,i,-1,templong);
			set_bytes(templong+CNXTOKENW*j,CNXTOKENW,' ');
		}
		if (i==whichseg[!topwindow])
		{
		/* allocate source buffer for non-top window: assumes window is homed */
			set_bytes(otherbuf,CNXTOKENW*LNSPERWIND,' ');
			nlines[!topwindow]= j+1;
			detoken_seg(whichcnx,i,min(j,LNSPERWIND),otherbuf);
		}
	}

	/* encode into dialog box */
	cptr= cnxeaddr[CNXETITL].ob_spec;
	for (i=0; i<NCHPERCNX; i++)
		cptr[i]= cnxname[whichcnx][i] ? cnxname[whichcnx][i] : '-' ;
	findhomecnxe(topwindow);
	curs_r= curs_c= 0;
	for (w=0; w<2; w++)
	{
		i= CNXESEGL + w*WDELTA;
	/* which segment is in each window */
		strcpy(cnxeaddr[i].ob_spec,cnxsegname[whichseg[w]]);
	/* which window is topped */
		if (w==topwindow)
			cnxeaddr[i].ob_state &= ~DISABLED;
		else
			cnxeaddr[i].ob_state |= DISABLED;
		home_c[w]= hometoken[w]= 0;	/* home the cursor */
		cnxe_vert(w,0);					/* position the scroll bars */
		cnxe_horz(w,0);
	}
	setcnxeclp(0);
	do_cnxlink(whichcnx,0);	/* get cnx/tem link */

	/* draw dialog box without saving screen */
	drawcnxeall();

	done=0;
	waitmouse();
	do
	{
		key=0;								/* clear out previous key */
		*keyb_head= *keyb_tail;			/* no type-ahead */
		exit_obj= my_form_do(cnxeaddr,&edit_obj,&mstate,1,&key);
		kstate= Kbshift(-1) & 0x0F;	/* only alt/ctrl/shift */
		getmouse(&mousex,&mousey);		/* snapshot mouse position */
		if (key) exit_obj= cnxe_key(key,kstate);

		switch (exit_obj)
		{
			case CNXEEXIT:
			done= tokenize(whichcnx,0);
			if (!done)
			{
				sel_obj(0,cnxeaddr,CNXEEXIT);
				draw_object(cnxeaddr,CNXEEXIT);
			}
			break;

			case CNXEWNDL:
			case CNXEWNDR:			/* clicked in window work area */
			w= exit_obj==CNXEWNDR;
			if ( (w!=topwindow) && (dispmode[w]==1) )
			{
				if (!tokenize(whichcnx,1)) break;

				/* copy top window's contents into otherbuf */
				copy_bytes(heap[linemem].start+CNXTOKENW*hometoken[!w],
							  otherbuf,CNXTOKENW*LNSPERWIND);
				cnxe_cursor();		/* get rid of cursor */
				i= CNXESEGL+(!w)*WDELTA;
				cnxeaddr[i].ob_state |= DISABLED;
				draw_object(cnxeaddr,i);

				topwindow=w;

				i= CNXESEGL+w*WDELTA;
				cnxeaddr[i].ob_state &= ~DISABLED;
				draw_object(cnxeaddr,i);

				i= whichseg[w];
				j= ntokens[i]= detoken_seg(whichcnx,i,0,0L);
				nlines[w]= j+1;
				change_mem(linemem,CNXTOKENW*(j+1) );
				templong= heap[linemem].start;
				detoken_seg(whichcnx,i,-1,templong);
				/* 1 blank line at end */
				set_bytes(templong+CNXTOKENW*j,CNXTOKENW,' ');
				findhomecnxe(w);
				cnxe_vert(topwindow,1);
				curs_r= curs_c= 0;
				cnxe_wind(topwindow,-1);
				break;
			}	/* end if clicked in non-topped window */

			/* L-click in top window */
			if (mstate<0)	/* set cursor position (not beyond last line+1) */
			{
				i= (mousey - curs_hy) / charh;			/* line # */
				if (i<0) i=0;
				if (i>=LNSPERWIND) i=LNSPERWIND-1;
				if ( (i+hometoken[w]) < nlines[w] )
				{
					cnxe_cursor();
					curs_r= i;
					curs_c= val_curs_c(mousex/charw - curs_hx);
					cnxe_cursor();
				}
				break;
			}	/* end if left-clicked in top window */

			/* R-click in top window */
			cnxe_cursor();
			j= -1;	/* default: nothing happened */
			if (kstate==K_CTRL)	/* select from cursor to end of window */
			{
				i= (mousey - curs_hy) / charh;			/* line # */
				if (i<0) i=0;
				if (i>=LNSPERWIND) i=LNSPERWIND-1;
				y1= i+hometoken[w];
				if ( (i<LNSPERWIND) && (y1<(nlines[w]-1)) )
				{
					for (j=i; j<LNSPERWIND; j++)
					{
						if ( (j+hometoken[w]) == (nlines[w]-1) ) break;
						xortext(ncols,curs_hx,curs_hy+j*charh);
					}
				}
				y2= nlines[w]-2;
			}
			else
			{
				while ( getmouse(&dummy,&mousey) )
				{
					i= (mousey - curs_hy) / charh;			/* line # */
					if (i<0) i=0;
					if (i>=LNSPERWIND) i=LNSPERWIND-1;
					if ( (i>j) && ((i+hometoken[w])<(nlines[w]-1)) )
					{
						if (j<0) y1=i;	/* mark first line in range */
						y2=j=i;
						xortext(ncols,curs_hx,curs_hy+i*charh);
					}
				}
				y1 += hometoken[w];
				y2 += hometoken[w];
			}
			if (j<0)	/* no range was selected */
			{
				cnxe_cursor();
				break;
			}
			menuprompt(CNXECLPMSG);
			i= Crawcin()>>16;
			kstate= Kbshift(-1)&0x0F;	/* ignore caps lock */
			menuprompt(0L);
			j= y2-y1+1;	/* how many lines */
			if ((i==SCAN_C)||(i==SCAN_X))	/* copy range to clipboard */
			{
				templong= (kstate==K_LSHIFT)||(kstate==K_RSHIFT) ?
							 heap[cnxeclpmem].nbytes : 0L ;
				if (change_mem(cnxeclpmem,templong+CNXTOKENW*j))
					copy_longs(heap[linemem].start+y1*CNXTOKENW,
								  heap[cnxeclpmem].start+templong,j*CNXTOKENW/4L);
			}
			if (i==SCAN_X)	/* delete range */
			{
				if (j<nlines[w])
				{
					templong= heap[linemem].start;
					ptr2= (long*)(templong) + (y2+1)*CNXTOKENW/4;
					ptr1= (long*)(templong) + y1*CNXTOKENW/4;
					end= (long*)(templong) + heap[linemem].nbytes/4;
					while (ptr2<end) *ptr1++ = *ptr2++ ;
					nlines[w]-=j;
					hometoken[w]= min(hometoken[w],nlines[w]-LNSPERWIND-1);
					hometoken[w]= max(hometoken[w],0);
				}
				else
				{
					nlines[w]=1;
					set_bytes(heap[linemem].start,CNXTOKENW,' ');
				}
				change_mem(linemem,nlines[w]*CNXTOKENW);
				curs_r= min(y1,nlines[w]-1) - hometoken[w] ;
				curs_r= min(curs_r,LNSPERWIND-1);
				curs_c= 0;
				sourcechanged=1;
			}
			setcnxeclp(1);
			cnxe_vert(w,1);
			cnxe_horz(w,1);
			cnxe_wind(w,-1);
			break;

			case CNXEUPL:
			case CNXEUPL+WDELTA:			/* up-scroll arrow */
			w= exit_obj!=CNXEUPL;
			if (w!=topwindow) break;
			if (hometoken[w])				/* if somewhere to scroll to */
			{
				hometoken[w]--;
				if (curs_r) curs_r++;
				curs_r= min(curs_r,nlines[w]-hometoken[w]-1);
				curs_r= min(curs_r,LNSPERWIND-1);
				cnxe_vert(w,1);
				cnxe_wind(topwindow,-1);
				mstate=0;					/* allow mouse repeat */
			}
			break;

			case CNXEDWNL:
			case CNXEDWNL+WDELTA:			/* down-scroll arrow */
			w= exit_obj!=CNXEDWNL;
			if (w!=topwindow) break;
			if (hometoken[w]<(nlines[w]-LNSPERWIND))
			{
				hometoken[w]++;
				if ( (curs_r<(nlines[w]-hometoken[w]-1)) &&
					  (curs_r<(LNSPERWIND-1)) ) curs_r--;
				curs_r= max(curs_r,0);
				cnxe_vert(w,1);
				cnxe_wind(topwindow,-1);
				mstate=0;						/* allow mouse repeat */
			}
			break;

			case CNXELFTL:
			case CNXELFTL+WDELTA:			/* left-scroll arrow */
			w= exit_obj!=CNXELFTL;
			if (w!=topwindow) break;
			if (cnxe_hscroll(w,-1)) mstate=0; /* allow mouse repeat */
			break;

			case CNXERITL:
			case CNXERITL+WDELTA:			/* right-scroll arrow */
			w= exit_obj!=CNXERITL;
			if (w!=topwindow) break;
			if (cnxe_hscroll(w,1)) mstate=0;	/* allow mouse repeat */
			break;

			case CNXEVRTL:
			case CNXEVRTL+WDELTA:			/*  vertical scroll bar */
			w= exit_obj!=CNXEVRTL;
			if (w!=topwindow) break;
			w *= WDELTA;
			objc_offset(cnxeaddr,CNXESLVL+w,&dummy,&y1);
			h1= cnxeaddr[CNXESLVL+w].ob_height;
			if (mousey<y1)
				cnxevpage(0);
			else
				cnxevpage(1);
			mstate=0;	/* allow mouse repeat */
			break;

			case CNXEHORL:
			case CNXEHORL+WDELTA:			/* horizontal scroll bar */
			w= exit_obj!=CNXEHORL;
			if (w!=topwindow) break;
			w *= WDELTA;
			objc_offset(cnxeaddr,CNXESLHL+w,&x1,&dummy);
			w1= cnxeaddr[CNXESLHL+w].ob_width;
			if (mousex<x1)
				cnxe_key(SCAN_LEFT<<8,K_LSHIFT);
			else
				cnxe_key(SCAN_RIGHT<<8,K_LSHIFT);
			mstate=0;	/* allow mouse repeat */
			break;

			case CNXESLVL:
			case CNXESLVL+WDELTA:			/* vertical slider */
			w= exit_obj!=CNXESLVL;
			if (w!=topwindow) break;
			w *= WDELTA;
			objc_offset(cnxeaddr,exit_obj,&x1,&y1);
			w1= cnxeaddr[exit_obj].ob_width;
			h1= cnxeaddr[exit_obj].ob_height,
			objc_offset(cnxeaddr,CNXEVRTL+w,&x2,&y2);
			y2 += cnxeaddr[CNXEUPL].ob_height;
			w2= cnxeaddr[CNXEVRTL+w].ob_width;
			h2= cnxeaddr[CNXEVRTL+w].ob_height
				 - cnxeaddr[CNXEUPL+w].ob_height
				 - cnxeaddr[CNXEDWNL+w].ob_height;
			i=y1;
			slide_box(&x1,&y1,w1,h1,x2,y2,w2,h2,0,0L,0L,0L,0L,0L,0L,0L,0L);
			if (y1!=i)
			{
				w= topwindow;
				j= (cnxeaddr[CNXESLVL+w*WDELTA].ob_y += (y1-i)) ;
				i= nlines[w];
				y1= cnxeaddr[CNXEUPL ].ob_height;
				y2= cnxeaddr[CNXEVRTL].ob_height
					 - cnxeaddr[CNXEDWNL].ob_height
			 		 - h1 ;
				h2= hometoken[w];
				hometoken[w]= (long)(j-y1)*(i-LNSPERWIND)/(y2-y1);
				curs_r -= hometoken[w]-h2;
				curs_r= max(curs_r,0);
				curs_r= min(curs_r+1,nlines[w]-hometoken[w]-1);
				curs_r= min(curs_r,LNSPERWIND-1);
				cnxe_vert(w,1);
				cnxe_wind(w,-1);
			}
			break;

			case CNXESLHL:
			case CNXESLHL+WDELTA:			/* horizontal slider */
			w= exit_obj!=CNXESLHL;
			if (w!=topwindow) break;
			w *= WDELTA;
			objc_offset(cnxeaddr,exit_obj,&x1,&y1);
			w1= cnxeaddr[exit_obj].ob_width;
			h1= cnxeaddr[exit_obj].ob_height,
			objc_offset(cnxeaddr,CNXEHORL+w,&x2,&y2);
			x2 += cnxeaddr[CNXELFTL+w].ob_width;
			h2= cnxeaddr[CNXEHORL+w].ob_height;
			w2= cnxeaddr[CNXEHORL+w].ob_width
				 - cnxeaddr[CNXELFTL+w].ob_width
				 - cnxeaddr[CNXERITL+w].ob_width;
			i=x1;
			slide_box(&x1,&y1,w1,h1,x2,y2,w2,h2,0,0L,0L,0L,0L,0L,0L,0L,0L);
			if (x1!=i)
			{
				j= (cnxeaddr[CNXESLHL+w].ob_x += (x1-i) ) ;
				x1= cnxeaddr[CNXELFTL].ob_width;
				x2= cnxeaddr[CNXEHORL].ob_width
					 - cnxeaddr[CNXERITL].ob_width
			 		 - cnxeaddr[CNXESLHL].ob_width ;
				w2= home_c[topwindow];
				home_c[topwindow]= (j-x1)*(CNXTOKENW-ncols)/(x2-x1);
				curs_c -= home_c[topwindow]-w2;
				curs_c= val_curs_c(curs_c);
				cnxe_horz(topwindow,1);
				cnxe_wind(topwindow,-1);
			}
			break;

			case CNXESEGL:			/* segment */
			case CNXESEGL+WDELTA:
			w= exit_obj!=CNXESEGL;
			if (w!=topwindow) break;

			if (!tokenize(whichcnx,1)) break;

			objc_offset(cnxeaddr,exit_obj,&x1,&y1);
			segaddr[0].ob_x=x1;
			segaddr[0].ob_y=y1;

			for (i=0,j=SEGSEG0; i<NSEGTYPES; i++,j++)
			{
				((TEDINFO*)(segaddr[j].ob_spec))->te_ptext= cnxsegname[i];
				if (i==whichseg[w])
					segaddr[j].ob_state |=  SELECTED ;
				else
					segaddr[j].ob_state &= ~SELECTED ;
				if (i==whichseg[!w])
				{
					segaddr[j].ob_flags &= ~TOUCHEXIT ;
					segaddr[j].ob_state |=  DISABLED ;
					font= 3;
				}
				else
				{
					segaddr[j].ob_flags |=  TOUCHEXIT ;
					segaddr[j].ob_state &= ~DISABLED ;
					font= detoken_seg(whichcnx,i,0,0L) ? 3 : 5 ;
				}
				((TEDINFO*)(segaddr[j].ob_spec))->te_font= font;
			}
			objc_draw(segaddr,ROOT,MAX_DEPTH,0,0,640,200*rez);
			waitmouse();
			i= my_form_do(segaddr,&edit_obj,&dummy,0,&dummy) - SEGSEG0;
			if (i==whichseg[w])
				draw_object(cnxeaddr,CNXETOPL+w*WDELTA);
			else
			{
				whichseg[w]= i;
				strcpy(cnxeaddr[exit_obj].ob_spec,cnxsegname[i]);
				draw_object(cnxeaddr,CNXETOPL+w*WDELTA);
				i= whichseg[w];
				j= ntokens[i]= detoken_seg(whichcnx,i,0,0L);
				nlines[w]= j+1;
				change_mem(linemem, CNXTOKENW*(j+1) );
				templong= heap[linemem].start;
				detoken_seg(whichcnx,i,-1,templong);
				set_bytes(templong+CNXTOKENW*j,CNXTOKENW,' ');
				home_c[w]= hometoken[w]= 0;
				curs_r= curs_c= 0;
				cnxe_vert(w,1);
				cnxe_horz(w,1);
			}
			cnxe_wind(topwindow,-1);
			break;

			case CNXEMODL:
			case CNXEMODL+WDELTA:
			w= exit_obj!=CNXEMODL;
			if (w!=topwindow) break;
			if (!dispmode[w]) break;
			if (w==1) swap_kludge();
			w=0;
			/* stretch/squeeze */
			cnxeaddr[CNXEWNDL].ob_width += half_full;
			cnxeaddr[CNXETOPL].ob_width += half_full;
			cnxeaddr[CNXEHORL].ob_width += half_full;
			cnxeaddr[CNXEMODL].ob_x += half_full;
			cnxeaddr[CNXEVRTL].ob_x += half_full;
			cnxeaddr[CNXERITL].ob_x += half_full;
			half_full= -half_full;
			if (dispmode[w]==1)	/* go from half to full */
			{
				cnxeaddr[CNXEWNDR].ob_flags |= HIDETREE;
				dispmode[w]=2;
				dispmode[!w]=0;
			}
			else
			{
				cnxeaddr[CNXEWNDR].ob_flags &= ~HIDETREE;
				dispmode[w]=1;
				dispmode[!w]=1;
			}
			findhomecnxe(topwindow);
			if (home_c[w])
			{
				home_c[w]=0;
				curs_c=0;
			}
			curs_c= val_curs_c(curs_c);
			cnxe_vert(w,0);
			cnxe_horz(w,0);
			drawcnxeall();			
			break;

			case CNXECLRL:			/* clear and shrink linemem */
			case CNXECLRL+WDELTA:
			w= exit_obj!=CNXECLRL;
			if (w!=topwindow) break;
			if (form_alert(1,CHEKCLRCNX)==1)
			{
				nlines[w]=1;
				change_mem(linemem,CNXTOKENW);
				set_bytes(heap[linemem].start,CNXTOKENW,' ');
				curs_r= curs_c= home_c[w]= hometoken[w]= 0;
				cnxe_wind(w,-1);
				cnxe_vert(w,1);
				cnxe_horz(w,1);
				sourcechanged=1;
			}
			break;

			case CNXEUNDL:
			case CNXEUNDL+WDELTA:
			w= exit_obj!=CNXEUNDL;
			if (w!=topwindow) break;
			if (form_alert(1,CHEKUNDCNX)==1)
			{
				i= whichseg[w];
				j= ntokens[i]= detoken_seg(whichcnx,i,0,0L);
				nlines[w]= j+1;
				change_mem(linemem, CNXTOKENW * (j+1) );
				templong= heap[linemem].start;
				detoken_seg(whichcnx,i,-1,templong);
				set_bytes(templong+CNXTOKENW*j,CNXTOKENW,' ');
				curs_r= curs_c= 0;
				home_c[w]= hometoken[w]= 0;
				cnxe_vert(w,1);
				cnxe_horz(w,1);
				cnxe_wind(w,-1);
				sourcechanged=0;
			}
			break;

			case CNXEPCLP:
			if (templong= heap[cnxeclpmem].nbytes)
			{
				if (change_mem(linemem,heap[linemem].nbytes+templong))
				{
					w= topwindow;
					ptr= heap[linemem].start + CNXTOKENW*(hometoken[w]+curs_r);
					insert_bytes(templong,heap[cnxeclpmem].start,ptr,
									 heap[linemem].start+heap[linemem].nbytes-templong);
					nlines[w] += templong/CNXTOKENW ;
					sourcechanged=1;
					cnxe_wind(w,-1);
					cnxe_vert(w,1);
				}
			}	/* end if clipboard not empty */
			break;

			case CNXECCLP:
			if (heap[cnxeclpmem].nbytes)
			{
				if (form_alert(1,CHEKCLRCLIP)==1)
				{
					change_mem(cnxeclpmem,0L);
					setcnxeclp(1);
				}
			}
			break;

			case CNXEIMPT:
			import_cnxe();
			drawcnxeall();
			break;

			case CNXELINK:
			link_cnxe();
			drawcnxeall();
			break;

			case CNXEEXPT:
			if (heap[cnxeclpmem].nbytes)
			{
				export_cnxe();
				drawcnxeall();
			}
			break;

			case CNXEPRNT:
			print_cnxe();

		}	/* end switch */
		if (mstate) waitmouse();
	}
	while (!done);
	sel_obj(0,cnxeaddr,exit_obj);
	/* replace or add cnx/tem link */
	if (cnxoffset[whichcnx]!=cnxoffset[whichcnx+1])
	{
		graf_mouse(BEE_MOUSE);
		change_flag[cnxCHANGE] |= do_cnxlink(whichcnx,1);
		graf_mouse(ARROWMOUSE);
	}
	dealloc_mem(linemem);

#endif
}	/* end edit_cnx() */

/* prompt for template file to be linked to .................................*/

link_cnxe()
{
	char filename[13],pathname[80];

	strcpy(filename,cnxeaddr[CNXELINK].ob_spec);
	Dsetdrv(tem_drive); dsetpath(tem_path);
	/* note: do menuprompt outside getfile so that scrsave isn't clobbered */
	menuprompt(LINKCNXMSG);
	if (getfile(pathname,filename,TE_EXT,0L))
		strcpy(cnxeaddr[CNXELINK].ob_spec,filename);
	menuprompt(0L);
}	/* end link_cnxe() */

/* import text file to clipboard ............................................*/

import_cnxe()
{
	char filename[13],pathname[80];

	tempmem= -1;
	filename[0]=0;
	Dsetdrv(cnx_drive); dsetpath(cnx_path);
	/* note: do menuprompt outside getfile so that scrsave isn't clobbered */
	menuprompt(IMPCNXEMSG);
	if (getfile(pathname,filename,TXT_EXT,0L)>0)
	{
		if (load_file(pathname,filename))
		{
			graf_mouse(BEE_MOUSE);
			txt_to_cnx();
			graf_mouse(ARROWMOUSE);
		}
	}
	menuprompt(0L);
	dealloc_mem(tempmem);
}	/* end import_cnxe() */

txt_to_cnx()
{
	register char *fromptr,*toptr;
	register long ii,txt_leng,jj;
	int ch,lastch;

	/* count lines in text file */
	txt_leng= heap[tempmem].nbytes;
	fromptr= (char*)(heap[tempmem].start);
	lastch= jj= 0;
	for (ii=0; ii<txt_leng; ii++)
	{
		ch= *fromptr++;
		if (ch==9) ch=' ';				/* treat tab as displayable */
		ch= ((ch>=' ')&&(ch<='~')) ;	/* displayable ascii? */
		if (ch && !lastch) jj++;
		lastch= ch;
	}

	/* resize clipboard */
	if (!change_mem(cnxeclpmem,CNXTOKENW*jj)) return;

	/* copy and convert:  each line of txt file ends with undisplayable ascii,
		each line of cnxe clipboard is 128 bytes / space-padded on right */
	/* note:  This assumes that no line of txt file will result in a clipboard
		line longer than 128 bytes */
	fromptr= (char*)(heap[tempmem].start);
	toptr=	(char*)(heap[cnxeclpmem].start);
	for (ii=jj=lastch=0; ii<txt_leng; ii++)
	{
		ch= *fromptr++;
		if (ch==9)	/* tabs at 3,6,9,... */
		{
			for (ch=2-(jj%3); ch>0; ch--) toptr[jj++]=' ';
			ch= ' ';
		}
		if ((ch>=' ')&&(ch<='~'))
		{
			toptr[jj++] = ch;
			lastch=1;
		}
		else
		{
			if (lastch)
			{
				for (; jj<CNXTOKENW; jj++) toptr[jj]=' ';
				toptr += CNXTOKENW;
				jj=lastch=0;
			}
		}
	}
	/* finish last line */
	if (lastch)
		for (; jj<CNXTOKENW; jj++) toptr[jj]=' ';

	setcnxeclp(0);
}	/* end txt_to_cnx() */

/* export clipboard to text file ............................................*/

export_cnxe()
{
	char filename[13],pathname[80];
	long addr[1],leng[1];
	long cnx_to_txt();

	tempmem= -1;
	graf_mouse(BEE_MOUSE);
	leng[0]= cnx_to_txt();
	graf_mouse(ARROWMOUSE);
	if (leng[0])
	{
		filename[0]=0;
		Dsetdrv(cnx_drive); dsetpath(cnx_path);
		/* note: do menuprompt outside getfile so that scrsave isn't clobbered */
		menuprompt(EXPCNXEMSG);
		if (getfile(pathname,filename,TXT_EXT,0L)>0)
		{
			addr[0]= heap[tempmem].start;
			save_file(filename,pathname,1,addr,leng);
		}
		menuprompt(0L);
	}
	dealloc_mem(tempmem);

}	/* end export_cnxe() */

/* returns length (bytes) of text file, 0L for error (alert inside here) */
long cnx_to_txt()
{
	register long ii,size;
	register int i,j;
	register char *fromptr,*toptr;
	long maxsize,nlines;

	/* allocate largest possible text buffer */
	tempmem= alloc_mem(0L);
	if (tempmem<0) return 0L;
	fill_mem(tempmem);
	maxsize= heap[tempmem].nbytes;

	/* where and how big is source (clipboard) */
	fromptr=	(char*)(heap[cnxeclpmem].start);
	nlines= heap[cnxeclpmem].nbytes / CNXTOKENW ;
	/* init building of destination (text) */
	toptr=	(char*)(heap[tempmem].start);
	size=0;
	/* loop through all clipboard lines */
	for (ii=0; ii<nlines; ii++,fromptr+=CNXTOKENW)
	{
		/* find end of clipboard line */
		for (j=CNXTOKENW-1; j>0; j--) if (fromptr[j]!=' ') break;
		if ( (size+j+3) > maxsize ) break;
		for (i=0; i<=j; i++) toptr[size++]= fromptr[i];
		toptr[size++]= 0x0D;
		toptr[size++]= 0x0A;
	}
	if (ii<nlines)
	{
		form_alert(1,BADMEM2);
		size=0;
	}
	return size;
}	/* end cnx_to_txt() */

/* scroll the top window horizontally .......................................*/
/* returns 1= scrolled, 0= nowhere to scroll to */

cnxe_hscroll(w,del)
register int w;	/* which window */
int del;				/* scroll amount (columns) */
{
	register int temp;

	temp= min(home_c[w]+del,CNXTOKENW-ncols);
	temp = max(temp,0);
	if (temp!=home_c[w])
	{
		home_c[w]=temp;
		curs_c= val_curs_c(curs_c-del);
		cnxe_horz(w,1);
		cnxe_wind(w,-1);
		return 1;
	}
	return 0;
}	/* end cnxe_hscroll() */

/* set horizontal slider position ...........................................*/

cnxe_horz(w,draw)
int w;		/* 0= left, 1= right */
int draw;	/* 0= compute slider position, 1= also draw it */
{
#if CNXFLAG
	int x1,x2,width,obj;
	register OBJECT *addr= cnxeaddr;

	obj= CNXESLHL + w*WDELTA;		/* which object we're working with */

	width= addr[CNXEHORL].ob_width - addr[CNXELFTL].ob_width
			 - addr[CNXERITL].ob_width;
	addr[obj].ob_width= width=
		max( (ncols*width)/CNXTOKENW , addr[obj].ob_height );
	x1= addr[CNXELFTL].ob_width;
	x2= addr[CNXEHORL].ob_width - addr[CNXERITL].ob_width - width;
	addr[obj].ob_x= x1 + (x2-x1)*home_c[w]/(CNXTOKENW-ncols);

	if (draw) draw_object(cnxeaddr,CNXEHORL+w*WDELTA);
#endif
}	/* end cnxe_horz() */

/* set vertical slider position .............................................*/

cnxe_vert(w,draw)
int w;		/* 0= left, 1= right */
int draw;	/* 0= compute slider position, 1= also draw it */
{
#if CNXFLAG
	register OBJECT *addr= cnxeaddr;
	int y1,y2,h,hmax,nwindow;
	int obj= CNXESLVL + w*WDELTA;
	int n;

	n= nlines[w];
	hmax= addr[CNXEVRTL].ob_height - addr[CNXEUPL ].ob_height
			- addr[CNXEDWNL].ob_height ;
	nwindow= min(n-hometoken[w],LNSPERWIND);
	h= n ? (long)(nwindow*hmax)/n : hmax ;
	addr[obj].ob_height=	h= max(h,addr[obj].ob_width);
	y1= addr[CNXEUPL ].ob_height;
	y2= addr[CNXEVRTL].ob_height - addr[CNXEDWNL].ob_height - h;
	addr[obj].ob_y= h==hmax ? y1 :
									  y1 + (long)(y2-y1)*hometoken[w]/(n-LNSPERWIND);

	if (draw) draw_object(cnxeaddr,CNXEVRTL+w*WDELTA);
#endif
}	/* end cnxe_vert() */

/* display text in window ...................................................*/

cnxe_wind(w,whichline)
register int w;	/* 0= left, 1= right */
int whichline;		/* which line to display, -1 for all */
{
#if CNXFLAG
	register int t,y,ln;
	register char *line,*linebuf;
	char templine[256];

	HIDEMOUSE;

	linebuf= w==topwindow ?
				(char*)(heap[linemem].start) + CNXTOKENW*hometoken[w]
				: linebuf= otherbuf ;

	findhomecnxe(w);

	t= nlines[w];
	t= min(t,LNSPERWIND);
	ln=0;
	for (y=curs_hy; t>0; t--,ln++,y+=charh,linebuf+=CNXTOKENW)
	{
		if ( (whichline<0) || (whichline==ln) )
		{
			copy_bytes(linebuf,templine,CNXTOKENW);
			pad_str(255,templine,' ');
			line= &templine[home_c[w]];
			line[ncols]=0;
			gr_text(line,curs_hx,y);
		}
	}
	if (whichline<0)	/* if display all lines */
	{
		/* clear out rest of window */
		if (y<curs_ly) gr_fill(curs_hx,curs_lx+1,y,curs_ly,0);

		findhomecnxe(topwindow);
		if (w==topwindow) cnxe_cursor();
	}
	SHOWMOUSE;
#endif
}	/* end cnxe_wind() */

/* handle key typed in cnx editor ...........................................*/
/* returns equivalent dialog box exit object (-1 for none) */

cnxe_key(temp,kstate)
register int temp;		/* high byte is scan code, low byte is ascii */
int kstate;
{
#if CNXFLAG
	register int i,j;
	register int w=topwindow;
	int exit_obj= -1;	/* default: no mouse equivalent */
	int scan,asci;
	char *ptr;
	long templong;

	scan= temp>>8;			/* scan code */
	asci= temp&0x7F;		/* ascii */

	/* switch segment being edited */
	if (kstate==K_ALT)
	{
		for (i=0; i<NSEGTYPES; i++)
		{
			if (scan==cnxsegscan[i])
			{
				if ( (i!=whichseg[w]) && (i!=whichseg[!w]) )
				{
					if (tokenize(whichcnx,0))
					{
						whichseg[w]= i;
						strcpy(cnxeaddr[CNXESEGL+w*WDELTA].ob_spec,cnxsegname[i]);
						draw_object(cnxeaddr,CNXETOPL+w*WDELTA);
						j= ntokens[i]= detoken_seg(whichcnx,i,0,0L);
						nlines[w]= j+1;
						change_mem(linemem, CNXTOKENW*(j+1) );
						templong= heap[linemem].start;
						detoken_seg(whichcnx,i,-1,templong);
						set_bytes(templong+CNXTOKENW*j,CNXTOKENW,' ');
						home_c[w]= hometoken[w]= curs_r= curs_c= 0;
						cnxe_vert(w,1);
						cnxe_horz(w,1);
						cnxe_wind(w,-1);
						break;
					}
				}
			}
		}	/* end loop through cnxsegscan[] */
		return -1;
	}	/* end if kstate == K_ALT */

	/* pointer to start of cursor's line */
	ptr= (char*)(heap[linemem].start) + CNXTOKENW*(hometoken[w]+curs_r);

	switch (scan)
	{
		case SCAN_UNDO:
		exit_obj= CNXEUNDL+w*WDELTA;
		break;

		case SCAN_ESC:
		exit_obj= CNXEEXIT;
		break;

		case SCAN_UP:
		case SCAN_DOWN:
		if (kstate==K_CTRL)
		{
			cnxevpage(scan==SCAN_DOWN);
			asci=0;
			break;
		}
		temp= curs_r;
		if ( (kstate==K_LSHIFT) || (kstate==K_RSHIFT) )	/* scroll window */
			temp= scan==SCAN_UP ? -1 : LNSPERWIND ;
		if (kstate==0)												/* move cursor */
			temp= curs_r + (scan==SCAN_UP ? -1 : 1) ;
		if (temp<0) exit_obj= CNXEUPL+w*WDELTA;
		if ( (temp>(nlines[w]-hometoken[w]-1)) ||
			  (temp>(LNSPERWIND-1)) ) exit_obj= CNXEDWNL+w*WDELTA;
		if ( (curs_r!=temp) && (exit_obj<0) )
		{
			cnxe_cursor();
			curs_r=temp;
			cnxe_cursor();
		}
		asci=0;
		break;

		case SCAN_LEFT:
		case SCAN_RIGHT:
		cnxe_cursor();
		if (!kstate)			/* left/right: move cursor single character */
			curs_c += (scan==SCAN_LEFT ? -1 : 1) ;
		if ((kstate==K_LSHIFT)||(kstate==K_RSHIFT))	/* shift: scroll horz */
			curs_c= (scan==SCAN_LEFT ? -1 : ncols) ;
		temp=0;
		if (curs_c<0)
			temp= cnxe_hscroll(w,-ncols/2);
		else
		{
			if (curs_c>=ncols) temp= cnxe_hscroll(w,ncols/2);
		}
		if (!temp)
		{
			curs_c= val_curs_c(curs_c);
			cnxe_cursor();
		}
		asci=0;
		break;

		case SCAN_CLEFT:		/* control-left: move cursor to start of line */
		if (home_c[w])
		{
			home_c[w]= curs_c= 0;
			cnxe_wind(w,-1);
			cnxe_horz(w,1);
		}
		else
		{
			cnxe_cursor();
			curs_c=0;
			cnxe_cursor();
		}
		asci=0;
		break;

		case SCAN_CRIGHT:			/* ctrl-right: move cursor to end of line */
		for (temp=CNXTOKENW-1; temp>0; temp--) if (ptr[temp]!=' ') break;
		temp= min(temp+1,CNXTOKENW-2);	/* 1 column after last non-space */
		while (temp>(home_c[w]+ncols-1)) home_c[w]++;
		while (temp<home_c[w]) home_c[w]--;
		curs_c= temp-home_c[w];
		cnxe_wind(w,-1);
		cnxe_horz(w,1);
		asci=0;
		break;

		case SCAN_BS:
		case SCAN_DEL:
		if (!kstate)
		{
			temp= scan==SCAN_BS ? curs_c-1 : curs_c ;
			if (temp>=0)
			{
				cnxe_cursor();
				curs_c=temp;
				for (temp+=home_c[w]; temp<(CNXTOKENW-1); temp++)
					ptr[temp]=ptr[temp+1];
				sourcechanged=1;
				ptr[CNXTOKENW-1]=' ';
				cnxe_wind(w,curs_r);
				cnxe_cursor();
			}
		}
		if ( (scan==SCAN_DEL) && ((kstate==K_LSHIFT)||(kstate==K_RSHIFT)) )
		{	/* delete to end of line */
			temp= home_c[w]+curs_c;
			cnxe_cursor();
			for (; temp<CNXTOKENW; temp++) ptr[temp]=' ';
			sourcechanged=1;
			cnxe_wind(w,curs_r);
			cnxe_cursor();
		}
		if ( (scan==SCAN_DEL) && (kstate==K_CTRL) )
		{
			temp= curs_r+hometoken[w];
			if (temp<(nlines[w]-1))	/* can't delete last line */
			{
				for (; temp<nlines[w]; temp++,ptr+=CNXTOKENW)
					copy_bytes(ptr+CNXTOKENW,ptr,CNXTOKENW);
				sourcechanged=1;
				nlines[w]--;
				change_mem(linemem,heap[linemem].nbytes-CNXTOKENW);
				if (hometoken[w])
				{
					hometoken[w]--;
					if ( curs_r < (LNSPERWIND-1) )
					{
						cnxe_vert(w,1);
						cnxe_wind(w,-1);
					}
					return cnxe_key(SCAN_DOWN<<8,0);
				}
				cnxe_vert(w,1);
				cnxe_wind(w,-1);
			}
		}
		asci=0;
		break;

		case SCAN_ENTER:
		case SCAN_CR:
		temp=0;
		if ( (curs_r+hometoken[w]) == (nlines[w]-1) )	/* add line to end */
		{
			if (change_mem(linemem,heap[linemem].nbytes+CNXTOKENW))
			{
				set_bytes( heap[linemem].start + CNXTOKENW*nlines[w] ,
							  CNXTOKENW,' ');
				nlines[w]++;
				sourcechanged=1;
				temp=1;
			}
		}
		if (home_c[w])
		{
			home_c[w]=0;
			cnxe_horz(w,1);
			temp=1;
		}
		if ( (curs_r+1) == LNSPERWIND )
		{
			curs_r--;
			hometoken[w]++;
			temp=1;
		}
		if (temp)
		{
			curs_c=0;
			curs_r++;
			cnxe_vert(w,1);
			cnxe_wind(w,-1);
		}
		else
		{
			cnxe_cursor();
			curs_c=0;
			curs_r++;
			cnxe_cursor();
		}
		asci=0;
		break;

		case SCAN_INS:
		asci= kstate ? 0 : ' ';	/* insert space at cursor */
		if (kstate==K_CTRL)	/* insert blank line before cursor */
		{
			temp= curs_r+hometoken[w];
			if (change_mem(linemem,heap[linemem].nbytes+CNXTOKENW))
			{
				ptr= (char*)(heap[linemem].start) + CNXTOKENW*nlines[w];
				for (i=nlines[w]; i>=temp; i--,ptr-=CNXTOKENW)
					copy_bytes(ptr,ptr+CNXTOKENW,CNXTOKENW);
				sourcechanged=1;
				set_bytes(ptr+CNXTOKENW,CNXTOKENW,' ');
				nlines[w]++;
				cnxe_vert(w,1);
				cnxe_wind(w,-1);
			}
		}
		break;

		case SCAN_CLR:
		exit_obj= CNXECLRL + w*WDELTA ;
		break;

		case SCAN_V:
		if (kstate==K_CTRL) exit_obj= CNXEPCLP;
		break;

		case SCAN_P:
		if (kstate==K_CTRL) exit_obj= CNXEPCLP;
		break;

		case SCAN_C:
		if (kstate==K_CTRL) exit_obj= CNXECCLP;
		break;

		case SCAN_I:
		if (kstate==K_CTRL) exit_obj= CNXEIMPT;
		break;

		case SCAN_E:
		if (kstate==K_CTRL) exit_obj= CNXEEXPT;

	}	/* end switch */

	/* insert character into source line */
	if ((asci>=0x20)&&(asci<=0x7e)&&(exit_obj<0))
	{
		cnxe_cursor();						/* blank cursor */
		temp= home_c[w]+curs_c;
		for (i=CNXTOKENW-2; i>temp; i--) ptr[i]=ptr[i-1];
		ptr[temp]= asci;
		sourcechanged=1;
		cnxe_wind(w,curs_r);
		cnxe_cursor();						/* show cursor */
		exit_obj= cnxe_key(SCAN_RIGHT<<8,0);	/* move cursor forward */
	}

	return exit_obj;
#endif
}	/* end cnxe_key() */

/* disable/enable clipboard buttons .........................................*/

setcnxeclp(draw)
int draw;
{
	static int clip_obj[3]= { CNXEPCLP,CNXECCLP,CNXEEXPT };
	register int i,obj;

	for (i=0; i<3; i++)
	{
		obj= clip_obj[i];
		if (heap[cnxeclpmem].nbytes)
			cnxeaddr[obj].ob_state &= ~DISABLED ;
		else
			cnxeaddr[obj].ob_state |= DISABLED ;
		if (draw) draw_object(cnxeaddr,obj);
	}
}	/* end setcnxeclp() */

/* compute curs_hx, curs_lx, curs_hy, curs_ly, ncols ........................*/

findhomecnxe(w)
register int w;
{
#if CNXFLAG
	int curs_obj;
	register OBJECT *addr= cnxeaddr;

	curs_obj= CNXECURL + w*WDELTA;

	/* find screen coords of home position */
	objc_offset(addr,curs_obj,&curs_hx,&curs_hy);
	curs_hy++;
	curs_hx /= charw;
	/* and of diagonally opposite position */
	ncols= (addr[CNXEWNDL].ob_width-addr[CNXEVRTL].ob_width) / charw ;
	curs_lx= curs_hx + ncols - 1 ;
	curs_ly= addr[CNXEWNDL].ob_height - addr[CNXETOPL].ob_height
				- addr[CNXEHORL].ob_height + curs_hy;
#endif
}	/* end findhomecnxe() */

/* xor the cnxe cursor ......................................................*/

cnxe_cursor()
{
#if CNXFLAG
	xortext(1,curs_hx+curs_c,curs_hy+charh*curs_r);
#endif
}	/* end cnxe_cursor() */

/* validate cursor column ...................................................*/

val_curs_c(i)
register int i;
{
	i= max(i,0);
	i= min(i,ncols-1);
	return i;
}	/* end val_curs_c() */

/* tokenize the text in the top window ......................................*/
/* returns 1= ok, 0= error */

tokenize(whichcnx,redraw)
int whichcnx;	/* which cnx (0-(NCNX-1)) */
int redraw;		/* 0= no redraw unless error */
{
#if CNXFLAG
	register char *toptr,*fromptr;
	register int i,j,n;
	int result=1;
	long leng,oldnbytes,newptr;
	int *iptr;
	int seg;

	/* source not changed: no need to tokenize it */
	if (!sourcechanged) return 1;

	graf_mouse(BEE_MOUSE);		/* this could take a while */

	seg= whichseg[topwindow];	/* which segment in cnx */

	/* don't tokenize blank lines at end */
	fromptr= (char*)(heap[linemem].start);		/* source to be tokenized */
	n= nlines[topwindow];							/* # of source lines */
	for (i= n-1; i>=0; i--)							/* scan all lines in reverse */
	{
		toptr= fromptr + CNXTOKENW*i;				/* --> start of line i */
		for (j=0; j<CNXTOKENW; j++)
			if (toptr[j]!=' ') break;
		if (j==CNXTOKENW)
			n--;
		else
			break;
	}

	/* check for bad tokens */
	i= token_seg(fromptr,0L,n,0,&leng);
	if (i>=0)
	{
		graf_mouse(ARROWMOUSE);
		n=topwindow;
		hometoken[n]= min(i,nlines[n]-LNSPERWIND);
		hometoken[n]= max(hometoken[n],0);
		cnxe_vert(n,1);
		cnxe_wind(n,-1);
		j= curs_hy + charh*(i-hometoken[n]);
		i= (cnxeaddr[CNXEWNDL+n*WDELTA].ob_width -
			 cnxeaddr[CNXEVRTL+n*WDELTA].ob_width ) / charw ;
		cnxe_cursor();
		xortext(i,curs_hx,j);
		menuprompt(BADTOKENMSG);
		Crawcin();
		menuprompt(0L);
		xortext(i,curs_hx,j);
		curs_r= (j-curs_hy)/charh;
		cnxe_cursor();
		result=0;
	}

	/* if segment already exists, get rid of it */
	if (result) delete_seg(whichcnx,seg);

	/* add new segment */
	if (result)
	{
		result= insert_seg(whichcnx,seg,leng,&newptr);
		if (result)
		{
			token_seg(heap[linemem].start,newptr,n,1,&leng);
			change_flag[cnxCHANGE] |= sourcechanged;
			sourcechanged=0;
		}
	}

	if (!redraw && result)
	{
		graf_mouse(ARROWMOUSE);
		return result;	/* skip redraw */
	}
	if (!result)
	{
		graf_mouse(ARROWMOUSE);
		return 0;
	}

	/* re-un-tokenize */
	j= topwindow;
	nlines[j]= ntokens[seg]=
		detoken_seg(whichcnx,seg,0,0L);
	n= ++nlines[j];
	change_mem(linemem,CNXTOKENW*n);
	leng= heap[linemem].start;
	detoken_seg(whichcnx,seg,-1,leng);
	/* 1 blank line at end */
	set_bytes(leng+CNXTOKENW*(n-1),CNXTOKENW,' ');

	graf_mouse(ARROWMOUSE);

	/* re-display */
	if ( hometoken[j] >= (n-LNSPERWIND) )
	{
		curs_r= hometoken[j]= 0;
	}
	cnxe_wind(j,-1);
	cnxe_vert(j,1);

	return 1;
#endif
}	/* end tokenize() */

/* delete a CNX segment .....................................................*/
/* returns 1= ok, 0= error (segment doesn't exist) */

delete_seg(whichcnx,seg)
int whichcnx,seg;
{
	long segstart,segend,oldleng,oldnbytes;
	register int *iptr1,*iptr2;
	int *endptr;
	register int i;
	int result=0;

	if ( findcnxseg(whichcnx,seg,&segstart,&segend) )
	{
		segstart -= 8;		/* --> type + length + code */
		oldleng= *(long*)(segstart+4) + 8 ;	/* length includes type and length */
		iptr2= (int*)(segstart);
		oldnbytes= heap[cnxmem].nbytes;
		endptr= (int*)( heap[cnxmem].start + oldnbytes );
		for (iptr1= (int*)segend; iptr1<endptr; ) *iptr2++ = *iptr1++;
		for (i=whichcnx+1; i<=NCNX; i++) cnxoffset[i] -= oldleng;
		change_mem(cnxmem,oldnbytes-oldleng);
		result=1;
	}
	return result;
}	/* end delete_seg() */

/* insert a blank CNX segment ...............................................*/
/* returns 1= ok, 0= error */

insert_seg(whichcnx,seg,leng,newptr)
int whichcnx;	/* 0 - (NCNX-1) */
int seg;			/* seg type */
long leng;		/* length of new segment (without segtype and seglength) */
long *newptr;	/* output: where new segment will go */
{
	long oldnbytes;
	register long ptr1,ptr2;
	register int i;
	int result;

	leng+=8;												/* includes type and length */
	oldnbytes= heap[cnxmem].nbytes;
	result= change_mem(cnxmem,oldnbytes+leng);
	if (result)
	{
		/* insert blank space where new seg will go */
		ptr1= heap[cnxmem].start;
		ptr2= ptr1+oldnbytes;
		ptr1 += cnxoffset[whichcnx+1];
		insert_bytes(leng,0L,ptr1,ptr2);
		*(long*)(ptr1)= seg;
		*(long*)(ptr1+4)= leng-8;
		*newptr= ptr1+8;
		/* adjust offsets of configs after this one */
		for (i=whichcnx+1; i<=NCNX; i++) cnxoffset[i] += leng;
	}
	return result;
}	/* end insert_seg() */

/* prize-winning code! ......................................................*/

swap_kludge()
{
#if CNXFLAG
	int i;

	i= home_c[0]; home_c[0]=home_c[1]; home_c[1]=i;
	i= whichseg[0]; whichseg[0]=whichseg[1]; whichseg[1]=i;
	i= hometoken[0]; hometoken[0]=hometoken[1]; hometoken[1]=i;		
	i= nlines[0]; nlines[0]=nlines[1]; nlines[1]=i;		
	cnxe_cursor();
	topwindow= !topwindow;
	i= CNXESEGL + topwindow*WDELTA;
	strcpy(cnxeaddr[i].ob_spec,cnxsegname[whichseg[topwindow]]);
	cnxeaddr[i].ob_state ^= DISABLED;
	i= CNXESEGL + (!topwindow)*WDELTA;
	strcpy(cnxeaddr[i].ob_spec,cnxsegname[whichseg[!topwindow]]);
	cnxeaddr[i].ob_state ^= DISABLED;
#endif
}	/* end swap_kludge() */

/* print contents of linemem ................................................*/

print_cnxe()
{
#if CNXFLAG
	register int i,temp;
	register char *lineptr;
	char buf[CNXTOKENW],heading[80];

	waitmouse();
	temp=1;
	while ( !(temp=Cprnos()) )
		if (form_alert(1,BADPRINT)!=1) break;
	if (!temp) return;

	menuprompt(NOWPRINTMSG);
	graf_mouse(BEE_MOUSE);

	/* reset printer pagination */
	cprnwsrow=0;

	/* heading */
	strcpy(heading,CONFIG_MSG);
	strcat(heading,cnxeaddr[CNXETITL].ob_spec);
	strcat(heading,"  ");
	strcat(heading,SEG_MSG);
	strcat(heading,cnxeaddr[CNXESEGL+topwindow*WDELTA].ob_spec);
	Cprnws(heading,1);
	Cprnws(" ",1);

	lineptr= (char*)(heap[linemem].start);
	for (i=0; i<nlines[topwindow]; i++,lineptr+=CNXTOKENW)
	{
		/* mouse button aborts */
		if ( getmouse(&dummy,&dummy) )
		{
			cprnwsrow=0;
			break;
		}
		copy_bytes(lineptr,buf,CNXTOKENW);
		for (temp= CNXTOKENW-1; temp>0; temp--)
			if (buf[temp]==' ')
				buf[temp]=0;
			else
				break;
		temp= buf[80]; buf[80]=0;
		Cprnws(buf,1);
		if (temp)
		{
			buf[80]=temp;
			buf[CNXTOKENW-1]=0;
			Cprnws(&buf[80],1);
		}
	}	/* end loop through all lines */
	if (cprnwsrow) Cprnout(0x0C);	/* form feed at end */

	waitmouse();
	graf_mouse(ARROWMOUSE);
	menuprompt(0L);

#endif
}	/* end print_cnxe() */

/* draw dialog box and both windows .........................................*/

drawcnxeall()
{
	objc_draw(cnxeaddr,ROOT,MAX_DEPTH,0,0,640,200*rez);
	/* draw topped window contents */
	cnxe_wind(topwindow,-1);
	/* draw untopped window contents if not hidden behind topped window */
	if (dispmode[!topwindow]) cnxe_wind(!topwindow,-1);
}	/* end drawcnxeall() */

/* scroll top window up/down by half page ...................................*/

cnxevpage(down)
int down;	/* 1= down, 0= up */
{
	register int w,newhome;

	w= topwindow;
	newhome= hometoken[w];

	if (down)
		newhome += LNSPERWIND/2;
	else
		newhome -= LNSPERWIND/2;
	newhome= min(newhome,nlines[w]-LNSPERWIND);
	newhome= max(newhome,0);
	if (newhome!=hometoken[w])
	{
		hometoken[w]= newhome;
		cnxe_vert(w,1);
		cnxe_horz(w,1);
		cnxe_wind(w,-1);
	}
}	/* end cnxevpage() */

/* get/put cnx/tem link .....................................................*/
/* returns 1= segment added or replaced, 0= no change */

do_cnxlink(whichcnx,getput)
int whichcnx;
int getput;				/* 0= encode, 1= decode */
{
	long find_const();
	long segstart,segend;
	char *ptr;
	int result=0;
	static char oldlink[12];
	NAMEDCONST *foundptr;

	ptr= cnxeaddr[CNXELINK].ob_spec;
	foundptr= (NAMEDCONST*)(0L);
	if ( findcnxseg(whichcnx,(int)(cnxCNST),&segstart,&segend) )
		foundptr= (NAMEDCONST*)find_const(C_TEMLINK,segstart,segend-segstart);

	if (getput)			/* replace or add link */
	{
		if (foundptr)
		{
			if (strcmp(ptr,oldlink))	/* replace */
			{
				result=1;
				delete_seg(whichcnx,(int)(cnxCNST));
			}
		}
		else									/* add */
			result=1;
		if (result)
		{
			if (insert_seg(whichcnx,(int)cnxCNST,8L+2L+32L,&segstart))
			{
				copy_bytes(C_TEMLINK,segstart,8L);	segstart+=8;
				*(int*)segstart= 32;						segstart+=2;
				set_bytes(segstart,32L,0);
				strcpy(segstart,ptr);
			}
		}
	}
	else					/* copy link to dialog box, store old value */
	{
		if (foundptr)
			strcpy(ptr,foundptr->value);
		else
			ptr[0]=0;
		strcpy(oldlink,ptr);
	}
	return result;
}	/* end do_cnxlink() */

/* EOF */
