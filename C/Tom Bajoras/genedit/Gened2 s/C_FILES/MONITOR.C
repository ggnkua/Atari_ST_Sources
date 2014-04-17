/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                          Copyright 1990 Tom Bajoras

	module MONITOR :	midi monitoring / monitor options

	entry points :		ex_monitor

******************************************************************************/

overlay "monitor"

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

/* monitoring variables .....................................................*/

int filtmoni=1,abbrmoni=1,annomoni=1;

char *annotate[21]= {
"Nt Off","Nt On ","Poly P","Cntrol","Patch ","Chan P","P Bend",
"SOX   ","MTC   ","Sngptr","Select","Tune  ","EOX   ","Clock ",
"C.Myer","Start ","Cont  ","Stop  ","Sense ","Reset ","Undef " };
long scrolfrom,scrol_to,scrolzero;
int scrol_amt,runningx;
int col,row;			/* position for next byte to be written */
int mincol;				/* leftmost byte position */
int monipause;			/* pause mode */

/* monitoring ...............................................................*/

ex_monitor()
{
#if MONITORFLAG
	register int i;
	int edit_obj,exit_obj,mstate,done,key;
	static int filt_obj[3]= { FLT1MONI, FLT2MONI, FLT3MONI };

	do
	{
		done=0;
		putdial(moniaddr,-1,0);
		edit_obj= -1;
		do
		{
			waitmouse();	/* don't allow mouse repeat */
			key=0;
			exit_obj= my_form_do(moniaddr,&edit_obj,&mstate,1,&key);
			switch (key>>=8)	/* scan code */
			{
				case SCAN_CR: 	exit_obj= MONIMONI; break;
				case SCAN_ESC:	exit_obj= MONIEXIT;
			}
			switch (exit_obj)
			{
				case MONIEXIT:		done=  1;	break;
				case MONIMONI:		done= -1;	break;

				default:
				for (i=0; i<3; i++)
					if (exit_obj==filt_obj[i]) break;
				if (i<3)
				{
					filtmoni= filtmoni == (i+1) ? 0 : (i+1) ;
					for (i=0; i<3; i++)
						if (filtmoni>i)
							moniaddr[filt_obj[i]].ob_state |= SELECTED ;
						else
							moniaddr[filt_obj[i]].ob_state &= ~SELECTED ;
					draw_object(moniaddr,FLT3MONI);
				}
			}	/* end switch */
		}
		while (!done);
		putdial(0L,0,exit_obj);

		annomoni= moniaddr[ANNOMONI].ob_state & SELECTED ;
		abbrmoni= moniaddr[ABBRMONI].ob_state & SELECTED ;

		if (done<0) do_monitor();	/* chain to monitor screen */
	}
	while (done<=0);
#endif
}	/* end ex_monitor() */

#if MONITORFLAG

do_monitor()
{
	char *save_start,*save_end;
	int monitormem;

	HIDEMOUSE;

	/* screen */
	save_screen(0,200*rez-1);
	monipause=0;
	moni_screen();
	runningx= strlen(RUNNGMSG)+1;

	scrolfrom= scrbase+5120L;
	scrol_to=  scrbase+3840L;
	scrol_amt= (SCRLENG-5120L)/32;
	scrolzero= scrbase+SCRLENG;

	/* extended midi input buffer */
	save_start= recv_start;
	save_end= recv_end;
	monitormem= alloc_mem(0L);
	if (monitormem<0) return;
	fill_mem(monitormem);
	recv_start= (char*)(heap[monitormem].start);
	recv_end= recv_start + heap[monitormem].nbytes;
	reset_midi();

	/* disable mouse, otherwise midi overrun errors */
	mouse_enable(0);

	monitor();

	/* enable mouse */
	mouse_enable(1);

	/* normal midi input buffer */
	recv_start= save_start;	recv_end= save_end;
	reset_midi();
	dealloc_mem(monitormem);

	/* restore screen */
	rest_screen(0,200*rez-1);

	SHOWMOUSE;

}	/* end do_monitor() */

monitor()
{
	register unsigned int i,laststat,sysex;
	register long sysxcount;
	register char *charptr,*annoptr;
	int *lengptr;
	int ndata,ndatacnt,sysxqcnt;
	int scan,kstate,color;
	unsigned int sysxq[4];
	char countbuf[7],bigbuf[13];

again:
	/* initialize mode */
	monipause=0;
	sysex=0;
	sysxcount=0L;
	sysxqcnt=0;
	ndatacnt= -1;

	/* initialize terminal */
	init_terminal();

	while (1)
	{
		/* handle keyboard input */
		if ( *keyb_head != *keyb_tail )
		{
			scan= Crawcin() >> 16 ;
			kstate= Kbshift(-1) & 0x0F;			/* only alt/ctrl/shift */
			if (scan==SCAN_TAB) moni_pause();	/* pause/continue */
			if ((scan==SCAN_CR)||(scan==SCAN_ESC)) break;	/* exit */
			if (scan==SCAN_CLR)						/* <clr/home> = re-init screen */
			{
				set_longs(scrbase+3840L,SCRLENG/4-960L,0L);
				init_terminal();
			}
			/* macros */
			if ( (kstate==K_LSHIFT) || (kstate==K_RSHIFT) )
			{
				for (i=0; i<NMACROS; i++)
					if (scan==macroscan[i]) break;
			}
			else
				i= NMACROS;
			if (i<NMACROS)
			{
				if (send_macro(i))
				{
					charptr= macrobuf + 8 + 2*NMACROS;
					lengptr= (int*)(macrobuf + 8);
					for (scan=0; scan<i; scan++) charptr+=lengptr[scan];
					if ( annomoni && (col!=mincol) ) new_line();
					if (annomoni)
					{
						gr_color= WH_ON_BL;
						gr_text("<<",0,charh*row);
						gr_text(macroasci[i],2,charh*row);
						gr_text(">>",3,charh*row);
						gr_color= BL_ON_WH;
					}
					else
						terminal("<<",2,WH_ON_BL,0);
					for (scan=lengptr[i]; scan>0; scan--)
					{
						i= *charptr++;
						terminal(hextext[i],2,WH_ON_BL,0);
					}
					if (!annomoni)
						terminal(">>",2,WH_ON_BL,0);
					else
						if (col!=mincol) new_line();
				}
			}
		}	/* end if key typed */

		if (monipause) continue;			/* pause mode */
		i= recv_byte();
		if (i==0xFF) continue;				/* no midi byte ready */

		/* handle midi overflow condition */
		if (midiovfl)
		{
			gr_color= RD_ON_WH;
			gr_text(OVFL_MSG,0,0);
			gr_color= BL_ON_WH;
			Crawcin();
			moni_screen();
			reset_midi();
			goto again;
		}

		/* filtering options, and is the byte part of a sysex message
			including F0 and F7 and imbedded real-time bytes */
		if ( (filtmoni==1) && (i==midiACTV) ) continue;
		if ( (filtmoni==2) && (i>midiEOX) ) continue;  	/* real-time */
		if ( (i&0x80) && (i<midiCLCK) )
			sysex= ( (i==midiSOX) || (i==midiEOX) ) ;
		if ( (filtmoni==3) && !sysex ) continue;		/* all but sysex */

		/* encode the byte */
		charptr= hextext[i];

		/* sysex abbreviation */
		if ( abbrmoni && sysex && (i!=midiEOX) )
		{
			if (sysxcount==12L) terminal("..",2,RD_ON_WH,0);
			if (sysxcount>=12L) charptr= (char*)(0L);
			/* manage sysex queue */
			if (sysxcount>12L)
			{
				if (sysxqcnt<4)
					sysxq[sysxqcnt++]=i;
				else
				{
					sysxq[0]=sysxq[1];
					sysxq[1]=sysxq[2];
					sysxq[2]=sysxq[3];
					sysxq[3]=i;
				}
			}
		}

		if (charptr)
		{
			if (annomoni)
			{
				if ( !ndatacnt && !sysex && !(i&0x80) )	/* running status */
				{
					if (col+1+3*ndata >= 79) new_line();
					terminal(hextext[laststat],2,GR_ON_WH,1);
					ndatacnt=ndata;
				}
				if ( i&0x80 )
				{
					if (i!=laststat)
					{
						if ( (col!=mincol)&&(i!=midiEOX) ) new_line();
						annoptr=annotate[ndata=whichstat(i)];
						gr_color= GR_ON_WH;
						if (col==mincol) gr_text(annoptr,0,charh*row);
						gr_text(annoptr,runningx,charh);
						gr_color= BL_ON_WH;
						laststat=i;
					}
					else
					{
						if (col+1+3*ndata >= 79) new_line();
					}
					ndatacnt= ndata= ndatabyte[ndata];
				}
				else
					if (ndatacnt>=0) ndatacnt--;
			}
			if ( !sysex || (i==midiEOX) )
			{
				asm { move.w i,-(a7) }
				for (i=0; i<sysxqcnt; i++)
				{
					if ((sysxq[i]==midiSOX)||(sysxq[i]==midiEOX))
						color= RD_ON_WH;
					else
						color= sysxq[i]&0x80 ? GR_ON_WH : BL_ON_WH;
					terminal(hextext[sysxq[i]],2,color,0);
				}
				asm { move.w (a7)+,i }
			}
			if ((i==midiSOX)||(i==midiEOX))
				color= RD_ON_WH;
			else
				color= i&0x80 ? GR_ON_WH : BL_ON_WH;
			terminal(charptr,2,color,0);
			if ( (i&0x80) && (!annomoni) )
			{
				gr_color= GR_ON_WH;
				gr_text(charptr,runningx,charh);
				gr_color= BL_ON_WH;
			}
		}
		if (i==midiEOX) sysex=0;
		/* keep track of how many sysex bytes have been received */
		if (sysex)
			sysxcount++;
		else
		{
			if (sysxcount)
			{
				if (i==midiEOX) sysxcount++;	/* count the EOX */
				ltoa(sysxcount,countbuf,6);
				gr_color= RD_ON_WH;
				gr_text(countbuf,74,charh);
				gr_color= BL_ON_WH;
				if (annomoni)
				{
					strcpy(bigbuf,countbuf);
					strcat(bigbuf," bytes");
					terminal(bigbuf,12,RD_ON_WH,0);
				}
			}
			sysxcount=0L;
			sysxqcnt=0;
		}
	}	/* end while (1) */

}	/* end monitor() */

moni_screen()
{
	set_longs(scrbase,SCRLENG/4,0L);
	gr_text(monipause ? MONIPMSG : MONI_MSG,0,0);
	gr_color= monipause ? RD_ON_WH : BL_ON_WH ;
	gr_text(monipause ? MONIPMSG2 : MONI_MSG2,0,2*charh);
	gr_color= BL_ON_WH;
	gr_text(RUNNGMSG,0,charh);
	gr_text(NSYSXMSG,74-strlen(NSYSXMSG),charh);
}	/* end moni_screen() */

moni_pause()
{
	monipause = !monipause;
	gr_text(monipause ? MONIPMSG : MONI_MSG,0,0);
	gr_color= monipause ? RD_ON_WH : BL_ON_WH ;
	gr_text(monipause ? MONIPMSG2 : MONI_MSG2,0,2*charh);
	gr_color= BL_ON_WH;
}	/* end moni_pause() */

/* midi terminal routines ...................................................*/

terminal(str,leng,color,halftone)
char *str;
int leng,color,halftone;
{
	int nextrow,nextcol;

	nextcol= col+leng+1;
	if (nextcol>=79)
	{
		new_line();
		nextcol= col+leng+1;
	}

	gr_color= color;
	gr_text(str,col,charh*row);
	gr_color= BL_ON_WH;
	if (halftone) halftext(leng,col,charh*row);

	if (!annomoni)
	{
		nextrow=row+1;
		if (nextrow>24) nextrow=3;
		gr_text("  ",col,charh*nextrow);
	}
	col= nextcol;
}	/* end terminal() */

new_line()
{
	col=mincol;
	row++;
	if (row>24)
	{
		if (annomoni)
		{
			row=24;
			scrollup();
		}
		else
			row=3;
	}
}	/* end new_line() */

init_terminal()
{
	col= mincol= annomoni ? 10 : 0 ;	/* indented for annotations */
	row= 3;
}	/* end init_terminal() */

extern scrollup();
asm {
scrollup:
	movea.l	scrolfrom(a4),a0
	movea.l	scrol_to(a4),a1
	move.w	scrol_amt(a4),d0
	subq.w	#1,d0
scrolloop:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbf		d0,scrolloop

	movea.l	scrolzero(a4),a0
	moveq		#39,d0
zeroloop:
	clr.l		-(a0)			clr.l		-(a0)
	clr.l		-(a0)			clr.l		-(a0)
	clr.l		-(a0)			clr.l		-(a0)
	clr.l		-(a0)			clr.l		-(a0)
	dbf		d0,zeroloop
	rts
}	/* end scrollup() */

#endif

/* EOF */
