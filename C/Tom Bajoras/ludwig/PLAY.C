/******************************************************************************

                                    Ludwig

                                      by
                                  Tom Bajoras

                        Copyright 1988 Hybrid Arts, Inc.

	module:	PLAY -- play mode, play-again mode

******************************************************************************/

overlay "main"		/* must be in main overlay */

/* include header files .....................................................*/

#include <asm.h>				  /* needed for in-line assembly language */
#include "defines.h"         /* program-specific */
#include <gemdefs.h>         /* AES                  */
#include <obdefs.h>          /* more AES  */
#include <osbind.h>          /* GEMDOS, BIOS, XBIOS  */
#include "ludwig.h"          /* created by RCS       */

/* global variables .........................................................*/

#include "externs.h"

/* assembly language routines ...............................................*/

extern int saveA4();

/* play mode ................................................................*/

ex_play()
{
	register int i,j;

	/* play buffers not empty? */
	if (play_safe)
		if (play_buffer())
			if (form_alert(1,CHEKPLAY)==2) return;
	/* clear play buffers */
	for (i=0; i<NSEQ; i++)
	{
		playhead[i]=playtail[i]=playstart[i];
		nchords[i]= nntrsts[i]=0;
		playend[i]-=128;	/* make room for final note-off's */
	}

	build_seq(-1);		/* reset play buffer building */
	set_words(px,NSEQ,0);
	set_words(rx,NSEQ,0);
	set_words(pready,NSEQ,0);
	set_words(rready,NSEQ,0);
	/* every sequence must start with U or ?, or + followed by U or ?  */
	for (i=0; i<NSEQ; i++)
	{
		j= seq1data[i][S_PSERIES];
		if (j==4) j= seq1data[i][S_PSERIES+2];
		if ((j!=0)&&(j!=3))
		{	form_alert(1,BADSTART); return; }
		j= seq1data[i][S_RSERIES];
		if (j==4) j= seq1data[i][S_RSERIES+2];
		if ((j!=0)&&(j!=3))
		{	form_alert(1,BADSTART); return; }
	}

	play_mode=1;
	build_any();

	play();		/* returns when play_mode=0 */

	/* play buffers not empty: enable save sng and play again */
	menu_ienable(menuaddr,LUSNG,play_buffer());
	menu_ienable(menuaddr,LUAGAIN,play_buffer());

	for (i=0; i<NSEQ; i++) playend[i]+=128;

}	/* end ex_play() */

/* play-again mode ..........................................................*/

ex_again()
{
	register int i;

	for (i=0; i<NSEQ; i++) playhead[i]=playstart[i];	/* play from the top */

	play_mode=2;
	play();		/* returns when play_mode=0 */

}	/* end ex_again() */

/* play or play again .......................................................*/

play()
{
	register long templong;
	register int i,j;
	int clock(),playclock();
	int save_mode;
	int channel;
	register char *ptr;
	char menu_save[1600];

	/* change screen */
	HIDEMOUSE;
	copy_bytes(scrbase,menu_save,1600);
	set_longs(scrbase,(menu_hi_y-1)*bytesperline/4,0L);
	outchar(5,X_CLOSE,1);		/* close box */
	gr_text("||",X_PAUSE,1);	/* pause button */
	SHOWMOUSE;

	set_play();

	/* start with all notes on all tracks off */
	set_bytes(notestat,128*NSEQ,0);
	set_words(loopcnt,NSEQ*NCELL,0);
	masterclock= softclock= nextclock= 0L;		/* reset counters */
	set_words(pxor_p,NSEQ,-1);
	set_words(pxor_pp,NSEQ,-1);
	set_words(pxor_ppp,NSEQ,-1);
	set_words(pxor_r,NSEQ,-1);
	set_words(pxor_rr,NSEQ,-1);
	set_words(pxor_rrr,NSEQ,-1);
	play_pause=0;	/* not paused */
	set_longs(nextevent,NSEQ,0L);
	throwaway=25;
	clockdivider=1;

	/* install clock() on timer A, 2400 hz */
	asm {	
		pea		clock
		move.w  	#64,-(a7)   		; on 2400hz timer A
		move.w  	#3,-(a7)			; div 16
		clr.w   	-(a7)
		move.w  	#31,-(a7)
		trap		#14
		adda.w	#12,a7
	}
	timer_a=1;
	/* install playclock() on timer D, 600 hz */
	asm {	
		pea		playclock
		move.w  	#64,-(a7)
		move.w  	#5,-(a7)				; div 64
		move.w 	#3,-(a7)
		move.w  	#31,-(a7)
		trap		#14
		adda.w	#12,a7
	}
	timer_d=1;

	/* go ! */
	save_mode=play_mode;
	play_exec();	/* returns when play_mode=0 */

	/* disable timer A */
	asm {
		move.w  	#13,-(a7)
		move.w  	#26,-(a7)
		trap		#14
		addq.w  	#4,a7
	}
	timer_a=0;

	/* disable timer D */
	asm {
		move.w  	#4,-(a7)
		move.w  	#26,-(a7)
		trap		#14
		addq.w  	#4,a7
	}
	play_pause=0;
	timer_d=0;

	/* clear stuck notes resulting from play loop aborted */
	if (save_mode==1)
	{
		ptr=notestat;
		for (i=0; i<NSEQ; i++,ptr+=128)
		{
			playtail[i]=playhead[i];
			channel= *(int*)(nonr1data[i]+N_MIDICH);
			templong=96L;
			for (j=0; j<128; j++)
			{
				if (ptr[j])
				{
					note_off(i,j,channel,MIDDLE_V,templong);
					templong=0L;
				}
			}
		}
	}
	for (i=0; i<NSEQ; i++) seq_off(i);

	/* get rid of xor cursors */
	for (i=0; i<NWIND; i++)
	{
		if (xorc_col[i]) outcurs(xorc_col[i],xorc_row[i]);
		xorc_col[i]=0;
		if (xorp_col[i]) outcurs(xorp_col[i],xorp_row[i]);
		xorp_col[i]=0;
	}

	/* change screen back */
	HIDEMOUSE;
	copy_bytes(menu_save,scrbase,1600);
	disp_name();		/* name might have changed during play mode */
	SHOWMOUSE;

}	/* end play() */

/* display tempo and mutes; define global variables for interrupt routines */

set_play()
{
	char play_msg[81];	/* oversized */
	register int i,j;
	unsigned int temp;

	HIDEMOUSE;

	set_tempo( temp=masterdata[M_TEMPO] );
	gr_text(TEMPO_MSG,24,1);
	tempotoa(temp,play_msg);
	gr_text(play_msg,X_TEMPO,1);

	mutebyte=0;
	midi_sync= masterdata[M_SYNC];
	for (i=0; i<NSEQ; i++)
	{
		if ( nonr1data[i][N_MUTE] )
		{
			j=1;
			BITSET(i,mutebyte);
		}
		else
			j=2;
		outchar(j,X_MUTE+2*i,1);
	}
	SHOWMOUSE;

}	/* end set_play() */

/* play exec ................................................................*/

play_exec()
{
	register long templong;
	register int i,j,temp;
	int mstate,mousex,mousey;
	int mbefore=0;
	int error=0;
	int rts=0x4e75;
	long save_mot,save_but;
	int savethru;

	/* disable GEM mouse tracking */
	vdi_motv(&rts,&save_mot);
	vdi_butv(&rts,&save_but);

	savethru=midithru;	midithru=0;

	if (midi_sync) tran_byte(MIDISTART,0);
	while (1)
	{
		if (play_mode==(-1))		/* softclock can't catch masterclock */
		{
			error=2;
			play_mode=0;
			break;
		}
		if (play_mode==(-2))		/* null loop encountered */
		{
			error=3;
			play_mode=0;
			break;
		}

		/* play again can't go past where we stopped */
		if ((play_mode==2)&&(masterclock>=stop_time))
		{
			play_mode=0;
			break;
		}

		/* mouse button clicked */
		mstate= getmouse(&mousex,&mousey);
		if (mstate && !mbefore)
		{
			do_mouse(mousex,mousey,mstate);
			if (!play_mode) break;
		}
		mbefore=mstate;

		/* key typed */
		if ( *keyb_head != *keyb_tail )
		{
			templong=Crawcin();
			i= templong | (templong>>8);
			do_key(i,(int)(Kbshift(-1)));
			if (!play_mode) break;
		}

		/* do the following stuff for play-mode, but not for play-again mode */
		if (play_mode==1)
		{
		/* play buffer overflowed? */
			for (i=0; (i<NSEQ)&&play_mode; i++)
				if (playend[i]==playtail[i]) play_mode=0;
			if (!play_mode)
			{
				error=1;
				break;
			}
			build_any();
		}	/* end of play-mode-not-again stuff */
		xorp_any();
	}	/* end while */
	if (midi_sync) tran_byte(MIDISTOP,0);

	midithru=savethru;
	vdi_motv(save_mot,&save_mot);
	vdi_butv(save_but,&save_but);

	if (error==1) form_alert(1,BADPLAY);
	if (error==2) form_alert(1,BADMIDI);
	if (error==3) form_alert(1,BADLOOP);

}	/* end play_exec() */

/* add to play buffer? ......................................................*/

build_seq(seq)
register int seq;
{
	static int ch[NSEQ],nr[NSEQ];
	static long vel_time[NSEQ];

	register int i,j;
	register long dur;

	long fulldur;
	int channel,lego;
	int note[16],vel[16];
	int c,n,nch,nnt;

	if (seq<0) /* reset array indexes */
	{
		set_words(ch,NSEQ,0);
		set_words(nr,NSEQ,0);
		set_longs(vel_time,NSEQ,0L);
		set_words(vdx,NSEQ,0);
		return;
	}

	if ( (playtail[seq]-playhead[seq]) < 2 )
	{
		if (nchords[seq]==nchords1[seq])
		{
			dur= pxor_p[seq];
			asm {
				lsl.l	 #8,dur
				ori.l	 #PLAY_NOP,dur
				lsl.l	 #8,dur
				bset	 #31,dur
				clr.l	 -(a7)
				move.l dur,-(a7)
			}
			put_play(seq);
			asm { addq.w #8,a7 }
		}
		if (nntrsts[seq]==nntrsts1[seq])
		{
			dur= pxor_r[seq];
			asm {
				lsl.l	 #8,dur
				ori.l  #PLAY_NOP,dur
				lsl.l	 #8,dur
				bset	 #31,dur
				bset	 #30,dur
				clr.l	 -(a7)
				move.l dur,-(a7)
			}
			put_play(seq);
			asm { addq.w #8,a7 }
		}

		channel= *(int*)(nonr1data[seq]+N_MIDICH);
		lego= legato[seq];
		c= ch[seq];				n= nr[seq];
		nch= nchords[seq];	nnt= nntrsts[seq];
		while ( nch && nnt )
		{
			dur= fulldur= duration[seq][n];
			if ( nt_or_rst[seq][n] && nnotes[seq][c] )		/* a chord */
			{
				for (i=j=nnotes[seq][c]-1; i>=0; i--)
				{
					note[i]= notes[seq][c][i];
					vel[i]=  get_vel(seq,note[i],dur,vel_time[seq]);
					note_on(seq,note[i],channel,vel[i],0L);
				/* optionally default the corresponding release velocity */
					if (nonr1data[seq][N_VWHICH]<2) vel[i]=nonr1data[seq][N_VDEFRL];
				}
				dur= (lego*dur)/100;
				if (dur==fulldur) dur--;
				if (!dur) dur=1L;
				for (i=j; i>=0; i--)
					note_off(seq,note[i],channel,vel[i], i==j ? dur : 0L );
				put_play(seq,PLAY_NOP<<8,fulldur-dur);
				c++; nch--;
			}
			else		/* a rest */
			{
				/* optionally waste a velocity */
				if (!seq1data[seq][S_VOPTS+S_VREST])
					get_vel(seq,-1,dur,vel_time[seq]);
				put_play(seq,PLAY_NOP<<8,dur);
				/* if meshing, don't waste chord on a rest */
				if (!nonr1data[seq][N_MESH] || !nnotes[seq][c] || nt_or_rst[seq][n])
				{	c++; nch--; }
			}
			n++; nnt--;
			vel_time[seq] += fulldur;
		}
	/* re-sync velocity */
		i= seq1data[seq][S_VOPTS+S_VSYNC];		/* re-sync option */
		if ( (i&1) && !nch ) vdx[seq]=0;			/* re-sync on pitch */
		if ( (i&2) && !nnt ) vdx[seq]=0;			/* re-sync on rhythm */
	
		ch[seq]= nch ? c : 0 ;
		nr[seq]= nnt ? n : 0 ;
		nchords[seq]=nch;		nntrsts[seq]=nnt;
	}
}	/* end build_seq() */

/* get a velocity for a chord or rest .......................................*/
/* returns 1-127 */

get_vel(seq,note,dur,time)
int seq;
int note;		/* note # 0-127, -1 for a rest */
long dur,time;	/* length of note, ticks since start of sequence */
{
	register char *nonr1,*seq1;
	register int v,i,amt;
	static int rand_dir;		/* 1 = up, 0 = down */

	/* register variables */
	nonr1= nonr1data[seq];	seq1= seq1data[seq];
	/* if attack velocity isn't mapped */
	if (!BITTEST(0,nonr1[N_VWHICH])) return(nonr1[N_VDEFAT]);

	if (seq1[S_VOPTS+S_VSTEP])	/* step by time */
	{
		time /= 12L * (1 + seq1[S_VOPTS+S_VTIME]);
		v= time%NPERPAGE;
	}
	else								/* step by chord */
	{
		v= vdx[seq]++;
		if (vdx[seq]>=NPERPAGE) vdx[seq]=0;
	}
	v= nonr1[ N_VELMAP + seq1[S_VSERIES+v] ];		/* the "basic" velocity */

	/* (un)accent */
	amt= nonr1[N_ACCENT];
	if ( (note%12) == seq1[S_VOPTS+S_VATON] ) v+=amt;	/* chromatic accent */
	if ( (note%12) == seq1[S_VOPTS+S_VUTON] ) v-=amt;	/* chromatic un-accent */
	for (i=0; i<31; i++)	/* find what duration this is closest to */
		if (dur<=(12L*(i+1))) break;
	if ( i == seq1[S_VOPTS+S_VADUR] ) v+=amt;		/* duration accent */
	if ( i == seq1[S_VOPTS+S_VUDUR] ) v-=amt;		/* duration un-accent */

	/* randomize */
	if (amt=seq1[S_VOPTS+S_VRAMT])
	{
		i= random(amt);
		switch ( seq1[S_VOPTS+S_VRAND] )
		{
			case 0:	/* up or down */
			if (rand_dir)
				v += i;
			else
				v -= i;
			break;
			
			case 1:	/* up */
			v += i;
			break;

			case 2:	/* down */
			v -= i;
		}
	}
	rand_dir = !rand_dir;
	if (v<1) v=1;	if (v>127) v=127;		/* midi velocity limits */
	return(v);
}	/* end get_vel() */

/* add to pdata? ............................................................*/

p_handler(seq,nforce)
register int seq;
int nforce;
{
	register int i,p;
	register char *pptr;
	static int pxor_pppp[NSEQ];

	if (play_mode!=1) return;

	/* register variables */
	p= px[seq];
	pptr= seq1data[seq]+S_PSERIES;

	if (!pready[seq])
	{
		i= pptr[p];		/* operator */
		if (i==4)		/* combine */
		{
			pxor_pppp[seq]=p;
			i= pptr[p+1];
			if (!i) i= random(15)+1;
			for (; i>0; i--)
			{
				p+=2;
				if (p>=2*NCELL) p=0;
				pfunc(pptr[p],seq,pptr[p+1]);
			}
			pready[seq]=1;
			p+=2;				/* --> next operator */
			if (p>=2*NCELL) p=0;
			i=4;
		}
		while (i==1)	/* start of loop */
		{
			p+=2;
			if (p==2*NCELL) p=0;
			i= pptr[p];
		}
		if (i==2)		/* end of loop */
		{
			switch (loopcnt[ seq*(2*NCELL) + P_TYPE*NCELL + p/2])
			{
				case -1:		/* infinite loop */
				p= loopback(seq1data[seq]+S_PSERIES,p);
				break;
				
				case 0:		/* first encounter */
				i= pptr[p+1];
				loopcnt[ seq*(2*NCELL) + P_TYPE*NCELL + p/2]= i ? i : -1 ;
				break;

				case 1:		/* break */
				loopcnt[ seq*(2*NCELL) + P_TYPE*NCELL + p/2]= 0;
				p+=2;
				if (p==2*NCELL) p=0;
				break;

				default:		/* loop in progress */
				loopcnt[ seq*(2*NCELL) + P_TYPE*NCELL + p/2]--;
				p= loopback(seq1data[seq]+S_PSERIES,p);
			}
			i= pptr[p];
		}	/* end if end of loop */
		move_xorc(seq,P_TYPE,p);

		if ((i!=1)&&(i!=2)&&(i!=4))
		{
			pxor_pppp[seq]=p;
			pfunc(i,seq,pptr[p+1]);
			pready[seq]=1;
			p+=2;				/* --> next operator */
			if (p>=2*NCELL) p=0;
		}

		if (pready[seq]&&(nforce>=0))
		{
			if (_nchords[seq]<nforce) pfunc_A(seq,NCHD);
			asm { move.w p,-(a7) }
			for (i=0,p=_nchords[seq]; p<nforce; i++,p++)
				copy_bytes( _notes[seq][i],_notes[seq][p],
								_nnotes[seq][p]=_nnotes[seq][i] ) ;
			_nchords[seq]=nforce;
			asm { move.w (a7)+,p }
		}
	}

	if ( !nchords[seq] && pready[seq] )
	{
		pxor_p[seq]= pxor_pppp[seq];
		nchords1[seq]= nchords[seq]= _nchords[seq];
		copy_bytes(&_nnotes[seq][0],&nnotes[seq][0],NCHD);
		copy_bytes(&_notes[seq][0][0],&notes[seq][0][0],16*NCHD);
		pready[seq]=0;
	}

	/* un-register variables */
	px[seq]=p;

}	/* end p_handler() */

pfunc(func,seq,arg)
int func,seq,arg;
{
	long templong;

	templong= p_func[func];
	asm {
		move.w	arg(a6),-(a7)
		move.w	seq(a6),-(a7)
		move.l	templong(a6),a0
		jsr		(a0)
		addq.w	#4,a7
	}
}	/* end pfunc() */

/* add to rdata? ............................................................*/

r_handler(seq,nforce,tforce)
register int seq;
int nforce;
long tforce;
{
	register int i,r;
	register char *rptr;
	static int pxor_rrrr[NSEQ];

	if (play_mode!=1) return;

	/* register variables */
	r= rx[seq];
	rptr= seq1data[seq]+S_RSERIES;

	if (!rready[seq])
	{
		i= rptr[r];		/* operator */
		if (i==4)		/* combine */
		{
			pxor_rrrr[seq]=r;
			i= rptr[r+1];
			if (!i) i= random(15)+1;
			for (; i>0; i--)
			{
				r+=2;
				if (r>=2*NCELL) r=0;
				rfunc(rptr[r],seq,rptr[r+1]);
			}
			rready[seq]=1;
			r+=2;				/* --> next operator */
			if (r>=2*NCELL) r=0;
			i=4;
		}
		while (i==1)	/* start of loop */
		{
			r+=2;
			if (r==2*NCELL) r=0;
			i= rptr[r];
		}
		if (i==2)		/* end of loop */
		{
			switch (loopcnt[ seq*(2*NCELL) + R_TYPE*NCELL + r/2])
			{
				case -1:		/* infinite loop */
				r= loopback(seq1data[seq]+S_RSERIES,r);
				break;
				
				case 0:		/* first encounter */
				i= rptr[r+1];
				loopcnt[ seq*(2*NCELL) + R_TYPE*NCELL + r/2]= i ? i : -1 ;
				break;

				case 1:		/* break */
				loopcnt[ seq*(2*NCELL) + R_TYPE*NCELL + r/2]= 0;
				r+=2;
				if (r==2*NCELL) r=0;
				break;

				default:		/* loop in progress */
				loopcnt[ seq*(2*NCELL) + R_TYPE*NCELL + r/2]--;
				r= loopback(seq1data[seq]+S_RSERIES,r);
			}
			i= rptr[r];
		}	/* end if end of loop */
		move_xorc(seq,R_TYPE,r);

		if ((i!=1)&&(i!=2)&&(i!=4))
		{
			pxor_rrrr[seq]=r;
			rfunc(i,seq,rptr[r+1]);
			rready[seq]=1;
			r+=2;				/* --> next operator */
			if (r>=2*NCELL) r=0;
		}

		if (rready[seq])
		{
			if (nforce>=0)
			{
				if (_nntrsts[seq]<nforce) rfunc_A(seq,NCHD);
				asm { move.w r,-(a7) }
				for (i=0,r=_nntrsts[seq]; r<nforce; i++,r++)
				{
					_duration[seq][r]= _duration[seq][i];
					_nt_or_rst[seq][r]= _nt_or_rst[seq][i];
				}
				_nntrsts[seq]=nforce;
				asm { move.w (a7)+,r }
			}
			if (tforce>=0L) forceticks(seq,tforce);
		}
	}

	if ( !nntrsts[seq] && rready[seq] )
	{
		pxor_r[seq]= pxor_rrrr[seq];
		nntrsts1[seq]= nntrsts[seq]= _nntrsts[seq];
		copy_longs(&_duration[seq][0],&duration[seq][0],NCHD);
		copy_bytes(&_nt_or_rst[seq][0],&nt_or_rst[seq][0],NCHD);
		legato[seq]= _legato[seq];
		rready[seq]=0;
	}

	/* un-register variables */
	rx[seq]=r;

}	/* end r_handler() */

rfunc(func,seq,arg)
int func,seq,arg;
{
	long templong;

	templong= r_func[func];
	asm {
		move.w	arg(a6),-(a7)
		move.w	seq(a6),-(a7)
		move.l	templong(a6),a0
		jsr		(a0)
		addq.w	#4,a7
	}
}	/* end rfunc() */

/* anything to be built? ....................................................*/

build_any()
{
	register int i,j;
	long t;

	if (play_mode!=1) return;
	if (play_pause) return;

	for (i=0; i<NSEQ; i++)
		if (nonr1data[i][N_PSYNCTRK]<0)
			p_handler(i,-1);
	for (i=0; i<NSEQ; i++)
		if (nonr1data[i][N_RSYNCTRK]<0)
			r_handler(i,-1,-1L);
	for (i=0; i<NSEQ; i++)
	{
		if ((j=nonr1data[i][N_PSYNCTRK])>=0)
		{
			j= nonr1data[i][N_PSYNCTYP] ? _nntrsts[j] : _nchords[j] ;
			if (j>0) p_handler(i,j);
		}
	}
	for (i=0; i<NSEQ; i++)
	{
		if ((j=nonr1data[i][N_RSYNCTRK])>=0)
		{
			if (nonr1data[i][N_RSYNCTYP])
			{
				t= 0L;
				asm { move.w i,-(a7) }
				for (i=0; i<_nntrsts[j]; i++) t += _duration[j][i];
				asm { move.w (a7)+,i }
				j= -1;
			}
			else
			{
				t= -1L;
				j= _nchords[j];
			}
			if ((j>0)||(t>0L)) r_handler(i,j,t);
		}
	}
	for (i=0; i<NSEQ; i++) build_seq(i);
}	/* end build_any() */

/* track the now-playing xor cursor .........................................*/

xorp_any()
{
	register int i;

	for (i=0; i<NSEQ; i++)
	{
		if (pxor_pp[i]!=pxor_ppp[i])
			move_xorp(i,0,pxor_pp[i]=pxor_ppp[i]);
		if (pxor_rr[i]!=pxor_rrr[i])
			move_xorp(i,1,pxor_rr[i]=pxor_rrr[i]);
	}
}	/* end xorp_any() */

move_xorc(seq,type,p)
int seq,type,p;
{
	register int i;

	if (xor_lock) return;
	i= get_wind(seq,type);
	if (i>=0)
	{
		seq= i-dialwind;
		if ( (editmode==2) && ((seq==0)||(seq==1)) ) return;
		if (xorc_col[i]) outcurs(xorc_col[i],xorc_row[i]);
		p= p/2 - wind_start[i];
		if ( (p>=0) && (p<NPERPAGE) )
		{
			xorc_col[i]= (X_SERIES-1) + 3 * (p%(NPERPAGE/2)) ;
			p= p<NPERPAGE/2 ? 0 : 2 ;
			xorc_row[i]= wind_y[i] + val_y[p];
			outcurs(xorc_col[i],xorc_row[i]);
		}
		else
			xorc_col[i]= 0;
	}
}	/* end move_xorc() */

move_xorp(seq,type,p)
int seq,type,p;
{
	register int i;

	if (xor_lock) return;
	i= get_wind(seq,type);
	if (i>=0)
	{
		seq= i-dialwind;
		if ( (editmode==2) && ((seq==0)||(seq==1)) ) return;
		if (xorp_col[i]) outcurs(xorp_col[i],xorp_row[i]);
		p= p/2 - wind_start[i];
		if ( (p>=0) && (p<NPERPAGE) )
		{
			xorp_col[i]= (X_SERIES-1) + 3 * (p%(NPERPAGE/2)) ;
			p= p<NPERPAGE/2 ? 1 : 3 ;
			xorp_row[i]= wind_y[i] + val_y[p];
			outcurs(xorp_col[i],xorp_row[i]);
		}
		else
			xorp_col[i]= 0;
	}
}	/* end move_xorp() */

/* find corresponding start of loop .........................................*/
/* returns 2*cell */

loopback(ptr,end)
register char *ptr;	/* --> pitch or rhythm series */
int end;					/* 2*cell # having end of loop */
{
	register int nest=0;
	register int i;

	if (i=end)
		while (i-=2)
		{
			if (ptr[i]==2) nest++;
			if (ptr[i]==1)
			{
				if (nest)
					nest--;
				else
					break;
			}
		}
	/* break out of null loop */
	if (i==end) play_mode= (-2);
	if ( (i==(end-2)) && (ptr[i]==1) ) play_mode= (-2);

	return(i);
}	/* end loopback */

/* turn note on/off .........................................................*/

note_on(seq,note,channel,velocity,time)
int seq,note,channel,velocity;
long time;
{
	register long packet;

	asm {
		clr.l		packet
		move.w	velocity(a6),packet
		lsl.l		#8,packet
		or.w		note(a6),packet
		lsl.l		#8,packet
		or.w		#NOTE_ON,packet
		or.w		channel(a6),packet
		lsl.l		#8,packet
	}
	put_play(seq,packet,time);
}	/* end note_on() */

note_off(seq,note,channel,velocity,time)
int seq,note,channel,velocity;
long time;
{
	register long packet;

	asm {
		clr.l		packet
		move.w	velocity(a6),packet
		lsl.l		#8,packet
		or.w		note(a6),packet
		lsl.l		#8,packet
		or.w		#NOTE_OFF,packet
		or.w		channel(a6),packet
		lsl.l		#8,packet
	}
	put_play(seq,packet,time);
}	/* end note_off() */

/* append packet to play buffer .............................................*/

put_play(seq,packet,time)
int seq;
long packet;	/* low byte is 0 */
long time;		/* time elapsed, if >240 break packet into nop's + packet */
{
	if (time)
	{
		while (time>240L)
		{
			put_play(seq,PLAY_NOP<<8, 240L );
			time-=240L;
		}
	}

	if (playtail[seq]<playend[seq]) *(playtail[seq])++ = packet|time;
}	/* end put_play() */

/* set play tempo ...........................................................*/

set_tempo(tempo)
int tempo;
{
	copy_bytes(&tempodivs[tempo][0],clockdivs,8);
}	/* end set_tempo() */

/* play buffer not empty? ...................................................*/
/* returns 1 if not empty, 0 if empty */

play_buffer()
{
	register int i;

	for (i=0; i<NSEQ; i++)
		if (playtail[i]!=playstart[i]) return(1);
	return(0);
}	/* end play_buffer() */

/* turn off all notes in a given sequence ...................................*/
seq_off(seq)
register int seq;
{
	register int channel,note;
	register char *ptr;
	char save_pause;
	int port;

	save_pause= play_pause;
	play_pause=1;
	port= nonr1data[seq][N_PLEXER];
	ptr= notestat + 128*seq;
	channel= *(int*)(nonr1data[seq]+N_MIDICH);
	for (note=0; note<128; note++)
	{
		if (ptr[note])
		{
			tran_byte(NOTE_OFF|channel , port );
			tran_byte(note,port);
			tran_byte(MIDDLE_V,port);
			ptr[note]=0;
		}
	}
	play_pause=save_pause;

}	/* end seq_off() */

/* EOF play.c */
