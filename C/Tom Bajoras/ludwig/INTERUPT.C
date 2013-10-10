/******************************************************************************

                                    Ludwig

                                      by
                                  Tom Bajoras

                        Copyright 1988 Hybrid Arts, Inc.
								 
	module:	interupt -- interrupt handlers (must be kept in main overlay)

	newmvec, transmit, clock, playclock, saveA4, tran_byte
	play_pitch, play_rhythm, play_this, record_r

******************************************************************************/

overlay "main"

/* include header files .....................................................*/

#include <asm.h>				  /* needed for in-line assembly language */
#include "defines.h"         /* program-specific */
#include <gemdefs.h>         /* AES                  */
#include <obdefs.h>          /* more AES  */
#include <osbind.h>          /* GEMDOS, BIOS, XBIOS  */
#include "ludwig.h"          /* created by RCS       */

/* global variables .........................................................*/

#include "externs.h"
char clockflag;

/* declare extern any asm entry points ......................................*/

extern int transmit(),clock(),playclock();
extern int tran_byte(),MPoutput();

/* storage for Megamax's global data pointer ................................*/

saveA4()
{
	;
}  /* end saveA4() */

/* put single byte in transmit buffer .......................................*/

asm {		/* 5(a7).b = byte to transmit, 6(a7).w= port # (0,1-3) */
tran_byte:
	movem.l		d0-d7/a0-a6,-(a7)
	tst.w			midiplex(a4)			; if no midiplexer, use internal port
	blt			tran_intern
	move.w		66(a7),d1
	beq			tran_intern
	subq.w		#1,d1						; midiplexer port 0-3
	move.b		65(a7),d0				; byte to be transmitted
	jsr			MPoutput
	bra			tran_exit

tran_intern:
	move.l		trantail(a4),d1		; transmit buffer full if
	move.l		tranhead(a4),d0		; trantail 1 byte before tranhead
	sub.b			d1,d0
	cmpi.b		#1,d0
	beq			tran_intern				; trantail/head might move in interrupt

not_full:
	movea.l		d1,a0
	move.b		65(a7),(a0)
	addq.b		#1,d1
	move.l		d1,trantail(a4)
	move.b		#0xB5,MIDIACIA			;  enable transmit
}
#if ALOCKFLAG
asm {
	lea		alock1,a0
	move.w	8,(a0)
	move.w	36,(a0)
	addq.w	#4,a7
alock1:
	rts
	dc.w		4
}
#endif
asm {
tran_exit:
	movem.l		(a7)+,d0-d7/a0-a6
	rts
}	/* end tran_byte() */

/* custom mouse interrupt handler ...........................................*/

newmvec()
{
	register int mstate,mousex,mousey,deskstate;
	int saveA4();

	asm {
		move.w	SR,-(a7)
		andi.w	#0xFDFF,SR		; allow timer A interrupt
		movem.l	a2-a6,-(a7)
		lea		saveA4,a4		; restore Megamax's global variable pointer
		movea.l	(a4),a4

		tst.b		Freezex(a4)     ; optionally freeze either mouse movement
		beq		skipfrzx
		clr.b		1(a0)
skipfrzx:
		tst.b		Freezey(a4)
		beq		skipfrzy
		clr.b		2(a0)
skipfrzy:
		move.l   savemvec(a4),a2
		jsr      (a2)            ; call old mouse vector
	}

	mstate= 1 & *Mstate;  /* only the left button matters */
	deskstate = menuaddr[LUDESK].ob_state & SELECTED;
	mousex= *Mousex;
	mousey= *Mousey;

#if ALOCKFLAG
asm {
	lea		alock6,a0
	move.w	28,(a0)
	move.w	20,(a0)
	addq.w	#4,a7
alock6:
	rts
	dc.w		4
}
#endif

	asm {
		tst.w    mstate               ; check to see if mouse buttons state
		beq      up                   ; matches the state we're waiting for
		tst.b    wait_for(a4)         ; if not, exit
		beq      exit
												; waiting for button down, and we got it
		clr.b    wait_for(a4)         ; next we're waiting for button up
		move.w   mousex,Downx(a4)     ; record mouse position when button went
		move.w   mousey,Downy(a4)     ; down

		cmp.w    acc_lo_x(a4),mousex  ; check for type 1 desk acc:
		blt      exit                 ; button went down within desk acc
		cmp.w    acc_hi_x(a4),mousex  ; part of desk menu, while desk title
		bgt      exit                 ; was selected
		cmp.w    acc_lo_y(a4),mousey  
		blt      exit
		cmp.w    acc_hi_y(a4),mousey
		bgt      exit
		tst.b    deskstate            
		beq      exit                
		st       deskacc(a4)
		bra      exit

up:
		tst.b    wait_for(a4)
		bne      exit
												; waiting for button up, and we got it
		st       wait_for(a4)         ; next we're waiting for button down
		move.w   mousex,Upx(a4)       ; record mouse position when button went
		move.w   mousey,Upy(a4)       ; up

type2:                              ; check for type 2 desk acc:
		move.w   Downx(a4),d0         ; button went down in menu bar..
		cmp.w    menu_lo_x(a4),d0
		blt      exit
		cmp.w    menu_hi_x(a4),d0
		bgt      exit
		move.w   Downy(a4),d0
		cmp.w    menu_hi_y(a4),d0
		bgt      exit
		cmp.w    acc_lo_x(a4),mousex  ; ..and button went up in desk acc part
		blt      exit                 ; of the desk menu..
		cmp.w    acc_hi_x(a4),mousex
		bgt      exit
		cmp.w    acc_lo_y(a4),mousey
		blt      exit
		cmp.w    acc_hi_y(a4),d0
		bgt      exit
		tst.b    deskstate            ; .. desk menu title was selected when
		beq      exit                 ; the button went up
		st       deskacc(a4)
exit:
		movem.l    (a7)+,a2-a6
		move.w	  (a7)+,SR
	}
#if ALOCKFLAG
asm {
	lea		alock2,a0
	move.w	12,(a0)
	move.w	32,(a0)
	addq.w	#4,a7
alock2:
	rts
	dc.w		4
}
#endif
}  /* end newmvec() */

/* midi-transmit-ready interrupt routine ....................................*/

asm {
transmit:
	movem.l	d0-d1/a0-a4,-(a7)

	lea		saveA4,a4		; restore Megamax's global variable pointer
	move.l	(a4),a4
	move.l	rectail(a4),a0 	; where to record

	btst.b	#0,MIDIACIA		; receive ready?
	beq		skip_rcv
	move.b	MIDIDATA,d0		; read byte

	cmpi.b	#0xF0,d0			; skip from SOX to EOX inclusive
	bne		skip_F0
	st			sysexflag(a4)
	bra		skip_rcv
skip_F0:
	cmpi.b	#0xF7,d0
	bne		skip_F7
	clr.b		sysexflag(a4)
	bra		skip_rcv
skip_F7:	
	tst.b		sysexflag(a4)
	bne		skip_rcv

	tst.b		d0
	bge		databyte
	cmpi.b	#0xF7,d0					; ignore system real time messages
	bhi      skip_rcv
	tst.b		midithru(a4)
	beq		nostatthru
	tst.b		thruchan(a4)
	blt		nochanlize
	andi.b	#0xF0,d0
	or.b		thruchan(a4),d0
nochanlize:
	tst.w		midiplex(a4)
	blt		thru_intern
	clr.w		d1
	move.b	thruport(a4),d1
	beq		thru_intern
	subq.w	#1,d1						; midiplexer port # 0-2
	tst.b		plexer_on(a4)
	beq		nostatthru
	jsr		MPoutput
	bra		nostatthru
thru_intern:
	move.b	d0,MIDIDATA
nostatthru:
	andi.b	#0xF0,d0					; turn all channels into channel 1
	move.b	d0,runningstat(a4)	; update running status
	cmpi.b	#0x80,d0					; record only note-on and note-off status
	beq		record_it
	cmpi.b	#0x90,d0
	beq		record_it
	bra		skip_rcv
databyte:
	tst.b		midithru(a4)
	beq		nodatathru
	tst.w		midiplex(a4)
	blt		data_intern
	clr.w		d1
	move.b	thruport(a4),d1
	beq		data_intern
	subq.w	#1,d1						; midiplexer port # 0-2
	tst.b		plexer_on(a4)
	beq		nodatathru
	jsr		MPoutput
	bra		nodatathru
data_intern:
	move.b	d0,MIDIDATA
nodatathru:
	cmpi.b	#0x80,runningstat(a4)
	beq		record_it
	cmpi.b	#0x90,runningstat(a4)
	bne		skip_rcv
record_it:
	tst.b		record_on(a4)		; record enabled ?
	beq		skip_rcv

	move.l	timestamp(a4),d1
stamploop:
	cmpi.l	#127,d1
	ble		stamp_it
	cmpa.l	recend(a4),a0
	beq		skip_rcv				; receive buffer full
	move.w	#0xff7f,(a0)+
	subi.l	#127,d1
	bra		stamploop
stamp_it:
	cmpa.l	recend(a4),a0
	beq		skip_rcv				; receive buffer full
	move.b	d0,(a0)+				; the midi byte
	move.b	d1,(a0)+				; the time stamp <= 127
	move.l	#0,timestamp(a4)

skip_rcv:
	move.l	a0,rectail(a4)		; update record pointer
	btst.b	#1,MIDIACIA			; transmit ready?
	beq		end_tran

	tst.b		clockflag(a4)
	beq		notclock
	move.b	#MIDICLOCK,MIDIDATA
	clr.b		clockflag(a4)
	bra		end_tran
notclock:

	movea.l	tranhead(a4),a0
	cmpa.l	trantail(a4),a0
	beq		tran_off			; there's nothing to be transmitted
	move.b	(a0),MIDIDATA
	addq.b	#1,tranhead+3(a4)
	bra		end_tran
tran_off:
	move.b	#0x95,MIDIACIA	; disable transmit
}
#if ALOCKFLAG
asm {
	lea		alock3,a0
	move.w	16,(a0)
	move.w	8,(a0)
	addq.w	#4,a7
alock3:
	rts
	dc.w		4
}
#endif
asm {
end_tran:
	movem.l	(a7)+,d0-d1/a0-a4
	rts
}	/* end transmit() */

/* master clock .............................................................*/

asm {
clock:
	move.w	SR,-(a7)
	andi.w	#0xFDFF,SR					; allow transmit interrupts
	movem.l	d0/a0-a1,-(a7)

	lea		saveA4,a0					; restore Megamax global variable pointer
	movea.l	(a0),a0

	tst.b		play_pause(a0)
	bne		clockexit

	subq.b	#1,throwaway(a0)			; convert 2400 to 2304 hz
	bne		not_thrown
	move.b	#25,throwaway(a0)
	bra		clockexit
not_thrown:
	subq.b	#1,clockdivider(a0)		; generate tempo
	bne		clockexit
	move.w	masterclock+2(a0),d0
	andi.w	#7,d0
	lea		clockdivs(a0),a1
	move.b	0(a1,d0),clockdivider(a0)
	addq.l	#1,masterclock(a0)
	addq.l	#1,timestamp(a0)
}
#if ALOCKFLAG
asm {
	lea		alock4,a0
	move.w	20,(a0)
	move.w	36,(a0)
	addq.w	#4,a7
alock4:
	rts
	dc.w		4
}
#endif
asm {
clockexit:
	movem.l	(a7)+,d0/a0-a1
	move.w	(a7)+,SR
	bclr		#5,0xFFFFFA0F		;  clear interrupt-being-serviced bit
	rte
}	/* end clock() */

asm {
playclock:
	move.w	SR,-(a7)
	andi.w	#0xFDFF,SR					; allow clock and transmit interrupts
	movem.l	d0-d7/a0-a6,-(a7)			; save all regs
	lea		saveA4,a4					; restore Megamax global variable pointer
	movea.l	(a4),a4
	tst.w		play_mode(a4)
	ble		skipabort

	tst.b		play_pause(a4)
	bne		skipabort

	move.b	mutebyte(a4),d4			; d4.w = mute bit field
	moveq		#16,d5						; d5.w = abort counter
	move.l	softclock(a4),d7			; d7.l = softclock
	lea		playhead(a4),a6			; a6 --> playhead array
	lea		playtail(a4),a5			; a5 --> playtail array
	lea		nextevent(a4),a3			; a3 --> nextevent array
	movea.l	notestat(a4),a2			; a2 --> notestat array

whileloop:
	subq.w	#1,d5
	beq		abortclock
	cmp.l		masterclock(a4),d7		; loop while softclock <= masterclock
	bgt		endwhile

	tst.b		midi_sync(a4)
	beq		no_sync
	cmp.l		nextclock(a4),d7
	blt		no_sync
	move.b	#1,clockflag(a4)
	move.b	#0xB5,MIDIACIA
	addq.l	#4,nextclock(a4)
no_sync:

	moveq		#(4*NSEQ),d6				; loop for d6 = 4*NSEQ-4 to 0 by -4
	adda.w	d6,a6
	adda.w	d6,a5
	adda.w	d6,a3
	adda.w	#(128*NSEQ),a2
loopseq:
	subq.w	#4,d6
	subq.w	#4,a6
	subq.w	#4,a5
	subq.w	#4,a3
	suba.w	#128,a2
	movea.l	(a6),a1						; a1 = playhead for this sequence
loopevnt:
	cmpa.l	(a5),a1						; playhead >= playtail ?
	bge		endseq

	moveq		#0,d0
	move.l	(a1),d3						; pending event
	move.w	d3,d0
	andi.w	#0xffL,d0					; its delta-time
	add.l		(a3),d0						; its absolute time
	cmp.l		d7,d0							; its abs time > softclock
	bgt		endseq
	move.l	d0,(a3)						; accumulate seq time
	addq.w	#4,a1							; move playhead for this seq

	lsr.l		#8,d3							; shift out time
	cmpi.b	#0x10,d3						; this event is a NOP ?
	bne		not_a_nop
	lsr.l		#8,d3
	beq		loopevnt
	btst		#14,d3						; xorp marker
	bne		xorr
	lea		pxor_ppp(a4),a0
	bra		endxor
xorr:
	lea		pxor_rrr(a4),a0
endxor:
	andi.w	#0x3fff,d3					; cell number
	move.w	d6,d0
	lsr.w		#1,d0							; index into ppp/rrr array= 2*seq
	move.w	d3,0(a0,d0)
	bra		loopevnt
not_a_nop:

	move.w	d6,d0
	lsr.w		#2,d0							; d0.w= seq # (0-7)
	btst		d0,d4							; this seq muted ?
	beq		loopevnt

	lea		nonr1data(a4),a0
	move.l	0(a0,d6),a0					; a0 --> nonr1data[seq]
	clr.w		d0
	move.b	N_PLEXER(a0),d0
	move.w	d0,-(a7)

	move.w	d3,-(a7)
	jsr		tran_byte
	btst		#4,d3
	sne		d2					; d2 = 0 for note-off, non-0 for note-on
	lsr.l		#8,d3
	move.w	d3,d0
	andi.w	#0x7f,d0			; note #
	move.b	d2,0(a2,d0)		; update notestat
	move.w	d3,(a7)
	jsr		tran_byte
	lsr.w		#8,d3
	move.w	d3,(a7)
	jsr		tran_byte
	addq.w	#4,a7
	bra		loopevnt

endseq:
	move.l	a1,(a6)					; update playhead for this seq
	tst.w		d6
	bgt		loopseq
	addq.l	#1,d7
	bra		whileloop
endwhile:
	move.l	d7,softclock(a4)		; update softclock
	bra		skipabort
abortclock:
	move.w	#-1,play_mode(a4)
}
#if ALOCKFLAG
asm {
	lea		alock5,a0
	move.w	24,(a0)
	move.w	12,(a0)
	addq.w	#4,a7
alock5:
	rts
	dc.w		4
}
#endif
asm {
skipabort:
	movem.l	(a7)+,d0-d7/a0-a6
	move.w	(a7)+,SR
	bclr		#4,0xFFFFFA11
	rte
}

/* play a pitch pattern .....................................................*/

play_pitch(end_col,notes,notebase,edpchan,plex,spdx,linkptrw,mesh)
int end_col;
int *notes;
char *notebase;
int edpchan,plex;
int spdx;
int *linkptrw;			/* 0L or --> linked rhythm pattern */
int mesh;				/* if this and linkptrw, skip chords for rests */
{
	register int i,j,note;
	char playnotes[NCHD][16];
	int playdur[NCHD];
	char nnotes[NCHD];
	char *linkptrc;
	int notefield;

	if ( linkptrc= (char*)linkptrw ) end_col= max(end_col,linkptrw[R_NCOLS/2]);

	for (i=0; i<=end_col; i++)
	{
		playdur[i]= linkptrw ? 12*(linkptrw[(R_DUR/2)+i]+1) : 96 ;
		nnotes[i]=0;
		note= *notebase++;
		notefield= *notes++;
		if ( linkptrw && !linkptrc[R_NTRST+i] )
		{	/* don't waste this chord */
			if (mesh && note) { notebase--; notes--; }
			continue;
		}
		for (j=0; j<16; j++,note++)
			if (BITTEST(j,notefield))
				playnotes[i][nnotes[i]++]=note;
	}	/* end for all chords */

	play_this(end_col+1,nnotes,playnotes,playdur,edpchan,plex,spdx,-1,-1,-1);

}	/* end play_pitch() */

/* play a rhythm pattern ....................................................*/

play_rhythm(end_col,vals,ntrst,note,chan,plex,spdx,metro_n,metro_c,metroplex,
				linkptrw,mesh)
int end_col;
int *vals;
char *ntrst;
int note,chan,spdx,plex,metroplex;
int metro_n,metro_c;		/* metronome note (-1 for none) and channel */
int *linkptrw;				/* 0L or --> linked pitch pattern */
int mesh;					/* if this and linkptrw, skip chords for rests */
{
	char notes[NCHD][16];
	char nnotes[NCHD];
	int durs[NCHD];
	register int i,j;
	char *linkptrc;
	int notefield;

	if ( linkptrc= (char*)(linkptrw) )
	{
		end_col= max(end_col,linkptrw[P_NCOLS/2]);
		for (i=0; i<=end_col; i++,linkptrc++,linkptrw++)
		{
			nnotes[i]=0;
			note= linkptrc[P_NTREF];
			notefield= linkptrw[P_NOTE/2];
			if (!ntrst[i])
			{	/* don't waste this chord */
				if (mesh && notefield) { linkptrc--; linkptrw--; }
				continue;
			}
			for (j=0; j<16; j++,note++)
				if (BITTEST(j,notefield))
					notes[i][nnotes[i]++]=note;
		}	/* end for all chords */
	}
	else
	{
		set_bytes(notes,NCHD*16,note);	/* default note */
		copy_bytes(ntrst,nnotes,NCHD);	/* 0 or 1 note for each chord */
	}

	for (i=0; i<=end_col; i++) durs[i]= 12*(vals[i]+1);
	play_this(end_col+1,nnotes,notes,durs,chan,plex,spdx,
					metro_n,metro_c,metroplex);

}	/* end play_rhythm() */

play_this(nchd,nnotes,notes,dur,chan,plex,spdx,metro_n,metro_c,metroplex)
int nchd;					/* 1-32 */
char nnotes[];				/* 0-16 for each chord */
char notes[NCHD][16];	/* array of note #s for each chord */
int dur[];					/* duration of each chord, in ticks (96 ppq) */
int chan,spdx;
int metro_n,metro_c;		/* metronome note (-1 for none) and channel */
int metroplex;				/* metronome midiplexer port */
{
	register int i,j;
	register legato;
	char savethru,on,onm;
	char save_a=timer_a;
	long next,nextm;
	int savepause;
	unsigned int savetempo;
	long saveclock;
	int clock();

	/* save/install timer A */
	saveclock=masterclock;
	masterclock= 0L;
	savepause=play_pause;
	play_pause=1;
	throwaway=25;
	clockdivider=1;
	savetempo= masterdata[M_TEMPO];
	set_tempo(spdx);
	if (!save_a)
	{
		/* install clock() on timer A, 2400 hz */
		asm {	
			pea		clock
			move.w  	#64,-(a7)   		; on 2400hz timer A
			move.w  	#3,-(a7)				; div 16
			clr.w   	-(a7)
			move.w  	#31,-(a7)
			trap		#14
			adda.w	#12,a7
		}
		timer_a=1;
	}
	play_pause=0;	/* let 'er rip */

	/* save and disable midi thru */
	savethru=midithru;
	midithru=0;

	*keyb_head= *keyb_tail;
	on=onm=0;
	next=nextm=0L;
	for (i=0; (i<nchd)&&(*keyb_head==*keyb_tail)&&(!(*Mstate&3)); )
	{
		if (masterclock>=next)
		{
			if (on)
			{
				for (j=0; j<nnotes[i]; j++)
				{
					tran_byte(NOTE_OFF|chan,plex);
					tran_byte(notes[i][j],plex);
					tran_byte(MIDDLE_V,plex);
				}
				next += legato;
				i++;
			}
			else
			{
				for (j=0; j<nnotes[i]; j++)
				{
					tran_byte(NOTE_ON|chan,plex);
					tran_byte(notes[i][j],plex);
					tran_byte(MIDDLE_V,plex);
				}
				legato= (85*dur[i])/100;
				next += legato;
				legato= dur[i]-legato;
			}
			on= !on;
		}	/* end if masterclock >= next */
		if ((masterclock>=nextm)&&(metro_n>=0)&&(i<nchd))
		{
			if (onm)
			{
				tran_byte(NOTE_OFF|metro_c,metroplex);
				tran_byte(metro_n,metroplex);
				tran_byte(MIDDLE_V,metroplex);
				nextm+=48L;
			}
			else
			{
				tran_byte(NOTE_ON|metro_c,metroplex);
				tran_byte(metro_n,metroplex);
				tran_byte(MIDDLE_V,metroplex);
				nextm+=48L;
			}
			onm= !onm;
		}	/* end if masterclock >= nextm */
	}	/* end for all chords, or key typed or mouse button clicked */
	*keyb_head= *keyb_tail;
	if (on)
	{
		for (j=0; j<nnotes[i]; j++)
		{
			tran_byte(NOTE_OFF|chan,plex);
			tran_byte(notes[i][j],plex);
			tran_byte(MIDDLE_V,plex);
		}
	}
	if (onm)
	{
		tran_byte(NOTE_OFF|metro_c,metroplex);
		tran_byte(metro_n,metroplex);
		tran_byte(MIDDLE_V,metroplex);
	}

	/* restore midi thru */
	midithru=savethru;

	/* restore timer A */
	play_pause=savepause;
	masterclock=saveclock;
	set_tempo(savetempo);
	if (!save_a)
	{
		asm {
			move.w  	#13,-(a7)
			move.w  	#26,-(a7)
			trap		#14
			addq.w  	#4,a7
		}
		timer_a=0;
	}

}	/* end play_this() */

/* record rhythm pattern ....................................................*/

record_r(spdx,metro_n,metro_c,metroplex)	/* returns 0 error, 1 ok */
int spdx;
int metro_n,metro_c;		/* metronome note (-1 for none) and channel */
int metroplex;				/* metronome midiplexer port */
{
	char onm;
	int result=0;
	long nextm;
	char save_a=timer_a;
	char savethru=midithru;
	register char *thruptr;
	register unsigned int temp;
	int running;
	int savepause;
	unsigned int savetempo;
	long saveclock;
	int clock();

	midithru=0;
	waitmouse();
	*keyb_head= *keyb_tail;
	onm=0;
	nextm=0L;

	/* save/install timer A */
	saveclock=masterclock;
	timestamp= masterclock= 0L;
	savepause=play_pause;
	play_pause=1;
	throwaway=25;
	clockdivider=1;
	savetempo= masterdata[M_TEMPO];
	set_tempo(spdx);
	if (!save_a)
	{
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
	}
	play_pause=0;	/* let 'er rip */

	thruptr=rectail=recstart;
	record_on=1;
	while ( (*keyb_head==*keyb_tail) && (rectail!=recend) && !(*Mstate&3) )
	{
		if ( savethru && (rectail-thruptr>=4) )
		{
			temp= *thruptr++;	thruptr++;
			if (temp!=0xff)
			{
				if ((temp==0x80)||(temp==0x90))
				{
					while ( rectail-thruptr < 4 ) ;
					running= temp==0x90;
					if (thruchan>=0) temp|=thruchan;
					tran_byte(temp,thruport);
					tran_byte(*thruptr++,thruport);	thruptr++;
					tran_byte(temp=*thruptr++,thruport);	thruptr++;
					if (!temp) running=0;
				}
				else
				{
					asm { move.w temp,-(a7) }
					temp= running ? 0x90 : 0x80 ;
					if (thruchan>=0) temp|=thruchan;
					tran_byte(temp,thruport);
					asm { move.w (a7)+,temp }
					tran_byte(temp,thruport);
					tran_byte(*thruptr++,thruport);	thruptr++;
				}
			}	/* end if NOP */
		}

		if ((masterclock>=nextm)&&(metro_n>=0))
		{
			if (onm)
			{
				tran_byte(NOTE_OFF|metro_c,metroplex);
				tran_byte(metro_n,metroplex);
				tran_byte(MIDDLE_V,metroplex);
				nextm+=48L;
			}
			else
			{
				tran_byte(NOTE_ON|metro_c,metroplex);
				tran_byte(metro_n,metroplex);
				tran_byte(MIDDLE_V,metroplex);
				nextm+=48L;
			}
			onm= !onm;
		}	/* end if masterclock >= nextm */

	}	/* end while */

	record_on=0;
	*keyb_head= *keyb_tail;
	if (onm)
	{
		tran_byte(NOTE_OFF|metro_c,metroplex);
		tran_byte(metro_n,metroplex);
		tran_byte(MIDDLE_V,metroplex);
	}
	while ( savethru && (thruptr<rectail) )
	{
		temp= *thruptr++;	thruptr++;
		if ((temp==0x80)||(temp==0x90))
			if (thruchan>=0) temp |= thruchan;
		tran_byte(temp,thruport);
	}

	/* restore timer A */
	play_pause=savepause;
	masterclock=saveclock;
	set_tempo(savetempo);
	if (!save_a)
	{
		asm {
			move.w  	#13,-(a7)
			move.w  	#26,-(a7)
			trap		#14
			addq.w  	#4,a7
		}
		timer_a=0;
	}

	if (rectail==recend)
		form_alert(1,BADMIDINP);
	else
		result= !result;

	waitmouse();
	midithru=savethru;
	return(result);

}	/* end record_r() */

/* EOF: interupt.c */
