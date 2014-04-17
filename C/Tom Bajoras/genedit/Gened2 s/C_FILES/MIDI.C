/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                        Copyright 1990/1991 Tom Bajoras

	midi parameters, sequencer, low-level midi

	ex_midi, new_midi, reset_midi,
	send_midi, whichstat, get_midi
	send_pmidi

	record_seq, play_seq, load_seq, save_seq

	recv_byte, tran_byte
	which_opsys
	midi_motv, thru_nts_off
	thru_recv,track_thru

******************************************************************************/

/* has to be in main overlay */

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "genedit.h"		/* created by RCS */
#include "externs.h"		/* global variables */

/* asm entry points .........................................................*/

extern saveA4(),MPoutput(),TRena();		/* imported */
extern thru_recv(),track_thru();			/* exported */

/* local globals ............................................................*/

char thru_note[128],thru_sust;
long masterclock;
char ndattable[128 + 7*16]= {
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			/* data bytes */
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,			/* note off */
	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,			/* note on */
	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,			/* aftertouch */
	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,			/* controller */
	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,			/* patch */
	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,			/* poly-P */
	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2			/* pitch bend */
};
	
/* edit global midi parameters ..............................................*/

ex_midi()
{
	int edit_obj,exit_obj,mstate,done;
	register int i;
	static int filtbox[2]= { FILTBOX0, FILTBOX1 };
	static int thrubox[2]= { THRUBOX0, THRUBOX1 };
	static char *opsysstr[3]= { "", CLAB_MSG, MROS_MSG };
	char *delayptr;

	/* encode into dialog box */
	strcpy(midiaddr[THRUCHAN].ob_spec,chanchar[thruchan+1]);
	strcpy(midiaddr[MIDIPCHN].ob_spec,chanchar[midipchan+1]);
	delayptr= ((TEDINFO*)(midiaddr[MIDIPDLY].ob_spec))->te_ptext;
	itoa(midipdelay,delayptr,3);
	sel_obj(midithru,midiaddr,THRUON);
	for (i=0; i<6; i++)
		if (midi_speed==speedtable[i]) break;
	set_rbutton(midiaddr,MIDIRATE,6,i);
	for (i=0; i<4; i++)
		sel_obj(BITTEST(i,midi_filter),midiaddr,MIDIFILT+i);
	ena_obj(midiplexer,midiaddr,MIDIITHR);
	ena_obj(midiplexer,midiaddr,MIDIOTHR);
	ena_obj(midiplexer,midiaddr,MIDIIPRT);
	ena_obj(midiplexer,midiaddr,MIDIOPRT);
	ena_obj(midiplexer,midiaddr,MIDIPPRT);

	midiaddr[MIDIITHR].ob_spec[0]= 'A' + thru_rport*(midiplexer&1);
	midiaddr[MIDIOTHR].ob_spec[0]= 'A' + thru_tport*(midiplexer&1);
	midiaddr[MIDIIPRT].ob_spec[0]= 'A' + midi_rport*(midiplexer&1);
	midiaddr[MIDIOPRT].ob_spec[0]= 'A' + midi_tport*(midiplexer&1);
	midiaddr[MIDIPPRT].ob_spec[0]= 'A' + midi_pport*(midiplexer&1);

	/* hide options that are irrelevant while running under midi op sys */
	i= midi_opsys>0 ;	/* 0= normal, 1= SoftLink, etc. */
	midiaddr[filtbox[i]].ob_flags &= ~HIDETREE;
	midiaddr[thrubox[i]].ob_flags &= ~HIDETREE;
	midiaddr[filtbox[!i]].ob_flags |= HIDETREE;
	midiaddr[thrubox[!i]].ob_flags |= HIDETREE;
	midiaddr[filtbox[1]].ob_spec= opsysstr[midi_opsys];
	midiaddr[thrubox[1]].ob_spec= opsysstr[midi_opsys];

	done=0;
	putdial(midiaddr,-1,0);
	edit_obj= MIDIPDLY;
	do
	{
		exit_obj= my_form_do(midiaddr,&edit_obj,&mstate,0,&dummy);
		switch (exit_obj)
		{
			case THRUCHAN:
			i= thruchan+mstate;
			if (i<0) i= 15;
			if (i>15) i= 0;
			if (midithru) thru_nts_off();
			thruchan=i;
			strcpy(midiaddr[THRUCHAN].ob_spec,chanchar[thruchan+1]);
			draw_object(midiaddr,exit_obj);
			break;

			case MIDIPCHN:
			i= midipchan+mstate;
			if (i<0) i= 15;
			if (i>15) i= 0;
			midipchan=i;
			strcpy(midiaddr[MIDIPCHN].ob_spec,chanchar[midipchan+1]);
			draw_object(midiaddr,exit_obj);
			break;

			case MIDIITHR:
			change_port(&thru_rport,1,exit_obj,mstate);
			break;
			
			case MIDIOTHR:
			change_port(&thru_tport,3,exit_obj,mstate);
			break;

			case MIDIIPRT:
			change_port(&midi_rport,1,exit_obj,mstate);
			break;

			case MIDIOPRT:
			change_port(&midi_tport,3,exit_obj,mstate);
			break;

			case MIDIPPRT:
			change_port(&midi_pport,3,exit_obj,mstate);
			break;

			case THRUON:
			midithru= is_obj_sel(midiaddr,THRUON);
			if (!midithru) thru_nts_off();
			break;
			
			case OKMIDI:
			done=1;
		}
		waitmouse();	/* none of these auto-repeat */
	}
	while (!done);

	/* decode out of dialog box */
	midi_speed= speedtable[ whichbutton(midiaddr,MIDIRATE,6) ];
	midi_filter= 0;
	for (i=0; i<4; i++)
		if (is_obj_sel(midiaddr,MIDIFILT+i))
			BITSET(i,midi_filter);
	i= atoi(delayptr);
	if ((i>=0)&&(i<=255)) midipdelay=i;

	putdial(0L,0,exit_obj);
}	/* end ex_midi() */

change_port(portptr,max_port,exit_obj,del)
char *portptr;
int max_port,exit_obj;
int del;
{
	register int i;

	i= *portptr + del;
	if (i<0) i=max_port;
	if (i>max_port) i=0;
	if (midithru) thru_nts_off();
	*portptr=i;
	midiaddr[exit_obj].ob_spec[0]= 'A' + i*(midiplexer&1);
	draw_object(midiaddr,exit_obj);
}	/* end change_port() */

/* midi interrupt code ......................................................*/

extern new_midi(),tran_prot();
asm
{
new_midi:
	movem.l	d0-d1/a0-a4,-(a7)
	lea		saveA4,a4					; restore Megamax's global variable pointer
	move.l	(a4),a4

	TESTACIA(5)								; btst.b #5,MIDIACIA (overrun?)
	sne		d0								; latch overrun
	or.b		d0,midiovfl(a4)

	TESTACIA(0)								; btst.b #0,MIDIACIA (receive ready?)
	beq		skip_recv

	READ_MIDI								; move.b MIDIDATA,d0

	tst.b		midithru(a4)				; optional midi thru
	beq		skip_thru
	move.b	thru_rport(a4),d1
	and.b		midiplexer(a4),d1
	bne		skip_thru					; thru is being received by midiplexer
	bsr		thru_recv
skip_thru:

	move.b	midi_rport(a4),d1
	and.b		midiplexer(a4),d1			; receiving from input A?
	bne		skip_recv
	movea.l	recv_tail(a4),a0			; put byte into receive buffer
	move.b	d0,(a0)+
	cmpa.l	recv_end(a4),a0
	blt		no_wrap
	movea.l	recv_start(a4),a0
no_wrap:
	move.l	a0,recv_tail(a4)
	cmpa.l	recv_head(a4),a0			; buffer overflowed?
	seq		d0
	or.b		d0,midiovfl(a4)
skip_recv:

	TESTACIA(1)							; btst.b	#1,MIDIACIA (transmit ready?)
	beq		end_tran

	move.b	thru_tport(a4),d1
	and.b		midiplexer(a4),d1
	bne		no_thru					; thru being sent to midiplexer?
	move.b	thru_head+3(a4),d0
	cmp.b		thru_tail+3(a4),d0
	beq		no_thru					; there's nothing to be thru'd
	move.l	thru_head(a4),a0
	clr.w		d0
	move.b	(a0),d0
	addq.b	#1,thru_head+3(a4)
	WRITEMIDI							; move.b d0,MIDIDATA
	bsr		track_thru
	bra		end_tran

no_thru:	
	move.b	tran_head+3(a4),d0
	cmp.b		tran_tail+3(a4),d0
	beq		tran_off				; there's nothing to be transmitted
	move.l	tran_head(a4),a0
	move.b	(a0),d0
tran_prot:							; modified by copy protection
	WRITEMIDI						; move.b d0,MIDIDATA
	addq.b	#1,tran_head+3(a4)
	bra		end_tran

tran_off:
	DIS_TRAN							; move.b #0x95,MIDIACIA
end_tran:
	movem.l	(a7)+,d0-d1/a0-a4
	rts

/* keep track of notes and sustain pedal being thru'd .......................*/
/* input d0.w = midi byte, preserves all registers */

track_thru:
	movem.l	d0-d1/a0-a1,-(a7)
	lea		localvars,a1
	tst.b		d0
	bge		thru_data
	andi.b	#0xF0,d0
	move.b	d0,1(a1)				; start packet (ignore channel)
	lea		ndattable(a4),a0
	move.b	0(a0,d0),4(a1)		; ndata for this status byte
	clr.b		5(a1)					; reset ndatacnt
	bra		end_track
thru_data:
	addq.b	#1,5(a1)				; increment ndatacnt
	clr.w		d1
	move.b	5(a1),d1
	move.b	d0,1(a1,d1)			; put data byte into packet
	cmp.b		4(a1),d1
	bne		end_track
	clr.b		5(a1)					; start new packet
	cmpi.b	#midiCTRL,1(a1)
	beq		thru_ctrl
	cmpi.b	#midiNTON,1(a1)
	beq		thru_nton
	cmpi.b	#midiNTOF,1(a1)
	bne		end_track
thru_ntof:
	clr.w		d1
	move.b	2(a1),d1
	lea		thru_note(a4),a0
	clr.b		0(a0,d1)
	bra		end_track
thru_nton:
	tst.b		d0
	beq		thru_ntof			; pseudo note off
	clr.w		d1
	move.b	2(a1),d1
	lea		thru_note(a4),a0
	st			0(a0,d1)
	bra		end_track
thru_ctrl:							; track sustain pedal on/off
	cmpi.b	#SUSTCTRL,2(a1)
	bne		end_track
	move.b	d0,thru_sust(a4)
end_track:
	movem.l	(a7)+,d0-d1/a0-a1
	rts

/* thru a byte to thru_tport ................................................*/
/* input: d0.b = midi byte, preserves all registers */
/* assumes midithru is on */

thru_recv:
	movem.l	d0-d1/a0,-(a7)
	lea		localvars,a0
	tst.b		d0
	bge		databyte
	move.b	d0,(a0)
	cmpi.b	#midiSOX,d0				; don't thru system messages
	beq		endthru
	bhi      endthru
	andi.b	#0xF0,d0					; channelize it
	or.b		thruchan(a4),d0
	bra		thru_d0
databyte:
	cmpi.b	#midiSOX,(a0)			; don't thru between SOX and EOX
	beq		endthru
thru_d0:
	move.l	thru_tail(a4),a0
	move.b	d0,(a0)
	addq.b	#1,thru_tail+3(a4)
	clr.w		d0
	move.b	thru_tport(a4),d0
	and.b		midiplexer(a4),d0
	bne		thru_plex
	ENA_TRAN								; move.b	#0xB5,MIDIACIA thru_tport
	bra		endthru
thru_plex:
	subq.b	#1,d0
	jsr		TRena						; trashes D1
endthru:
	movem.l	(a7)+,d0-d1/a0
	rts

localvars:
	dc.b		0							; + 0 current status byte
	dc.b		0							; + 1 thru packet status byte
	dc.b		0							; + 2 thru packet data byte 1
	dc.b		0							; + 3 thru packet data byte 2
	dc.b		0							; + 4 thru ndata[status byte]
	dc.b		0							; + 5 thru ndata counter

}	/* end new_midi() */

/* clear midi input buffer ..................................................*/

reset_midi()
{
	if (midi_opsys)
		while (Bconstat(3)) Bconin(3);
	else
	{
		recv_head = recv_tail = recv_start ;
		midiovfl=0;
	}
}	/* end reset_midi() */

/* transmit midi string .....................................................*/

send_midi(midistr,n)
register char *midistr;
register int n;
{
	int savethru;

	/* temporarily disable midi-thru */
	savethru= midithru;
	midithru= 0;
	if (savethru) thru_nts_off();

	for (--n; n>=0; n--)
	{
		asm { move.b (midistr)+,d2 }
		tran_byte();
	}
	/* wait for midi string to finish transmitting */
	while (tran_head!=tran_tail) ;
	midithru= savethru;	/* restore midi-thru */
}	/* end send_midi() */

/* send midi string to patch bay ............................................*/

send_pmidi(str)
char *str;		/* null-term'd ascii string */
{
	register unsigned int hi,lo,midibyte;
	int savethru,save_tport;

	if (!str[0]) return;

	/* temporarily disable midi-thru */
	savethru= midithru;
	midithru= 0;
	if (savethru) thru_nts_off();

	save_tport= midi_tport;
	midi_tport= midi_pport;
	while (1)
	{
		hi= *str++;
		lo= *str++;
		if (!hi || !lo) break;
		if (hi == 'n')
			hi = midipchan;
		else
			hi = hexvalue(hi);
		if (hi<0) break;
		if (lo == 'n')
			lo = midipchan;
		else
			lo = hexvalue(lo);
		if (lo<0) break;
		midibyte= (hi<<4) | lo;
		if (midibyte&0xF0) wait(midipdelay/10L);
		asm {
			move.b	midibyte,d2
		}
		tran_byte();
	}
	wait(midipdelay/10L);
	while (tran_head!=tran_tail) ;
	midi_tport= save_tport;
	midithru= savethru;	/* restore midi-thru */
}	/* end send_pmidi() */

/* transmit single midi byte ................................................*/

extern tran_byte();
asm {		/* d2.b = byte to transmit */
tran_byte:
	move.w		midi_speed(a4),d0		; optionally slow down midi
tran_delay:
	dbf			d0,tran_delay

	tst.w			midi_opsys(a4)			; decide how to send the byte
	bne			tran_opsys
	move.b		midi_tport(a4),d1
	beq			tran_intrnl
	tst.b			midiplexer(a4)
	bne			tran_plexer

tran_intrnl:
	move.b		tran_tail+3(a4),d0
	subq.b		#1,d0
tran_full:
	cmp.b			tran_head+3(a4),d0
	beq			tran_full
	movea.l		tran_tail(a4),a0
	move.b		d2,(a0)
	addq.b		#1,tran_tail+3(a4)
	ENA_TRAN									; move.b #0xB5,MIDIACIA
	rts

tran_plexer:								; d1.b = midi_tport (>0)
	move.b		d2,d0
	jsr			MPoutput
	rts

tran_opsys:
	andi.w		#0xFF,d2					; Bconout(3)
	move.w		d2,-(a7)
	move.w		#3,-(a7)
	move.w		#3,-(a7)
	trap			#13
	addq.w		#6,a7
	rts

}	/* end tran_byte() */

/* receive single midi byte .................................................*/
/* returns byte received, 0xFF for none */

recv_byte()
{
   unsigned int i= 0xFF;

   if (midi_opsys)   /* SoftLink, etc. */
	{
      if (Bconstat(3)) i= Bconin(3);
	}
   else
   {
      if (recv_head != recv_tail)
		{
	      i= *recv_head++;
   	   if (recv_head==recv_end) recv_head=recv_start;
		}
   }
   return i;
}	/* end recv_byte() */

/* classify a status byte ...................................................*/
/* do it with a table, use midiXXXX bytes defined in defines.h !!! */

whichstat(i)
unsigned int i;
{
	switch (i)
	{
		case 0xF0: return 7;
		case 0xF1: return 8;
		case 0xF2: return 9;
		case 0xF3: return 10;
		case 0xF4: return 20;
		case 0xF5: return 20;
		case 0xF6: return 11;
		case 0xF7: return 12;
		case 0xF8: return 13;
		case 0xF9: return 14;
		case 0xFA: return 15;
		case 0xFB: return 16;
		case 0xFC: return 17;
		case 0xFD: return 20;
		case 0xFE: return 18;
		case 0xFF: return 19;
	}
	switch (i & 0xF0)
	{
		case 0x80: return 0;
		case 0x90: return 1;
		case 0xA0: return 2;
		case 0xB0: return 3;
		case 0xC0: return 4;
		case 0xD0: return 5;
		case 0xE0: return 6;
	}
}	/* end whichstat() */

/* record internal sequencer ................................................*/

record_seq()
{
	register long *seqbuf;
	register unsigned int midibyte;
	register long seq_i;
	long maxseq_i;
	int save_filter;
	int firstbyte=1;
	int clock();

	/* overwrite existing sequence? */
	if (heap[seqmem].nbytes)
		if (form_alert(1,CHEKSEQ)==2) return;

	fill_mem(seqmem);
	seqbuf= (long*)(heap[seqmem].start);
	maxseq_i= (heap[seqmem].nbytes)/4;

	/* install clock() on timer A, 1000 hz (1/1024 close enough) */
	asm {	
		pea		clock
		move.w  	#24,-(a7)
		move.w  	#6,-(a7)
		clr.w   	-(a7)
		move.w  	#31,-(a7)
		trap		#14
		adda.w	#12,a7
	}

	menuprompt(RECORDMSG);

	masterclock=0L;
	reset_midi();
	runningstat= -1;
	/* filter real-time only */
	save_filter= midi_filter;
	midi_filter=1;

	for (seq_i=0; seq_i<maxseq_i; )
	{
		/* either mouse button or any key = stop */
		if ( getmouse(&dummy,&dummy) ) break;
		if ( *keyb_head != *keyb_tail )
		{
			Crawcin();
			break;
		}
		midibyte= get_midi();
		if (midibyte==0xFF) continue;	/* no midi byte ready */

		/* handle midi overflow condition */
		if (midiovfl)
		{
			form_alert(1,BADOVFL);
			seq_i=0;
			break;
		}

		/* put first byte at time 0 */
		if (firstbyte) masterclock=0;
		firstbyte=0;

		seqbuf[seq_i++]= (masterclock<<8)|midibyte;

	}	/* end while (1) */

	/* disable timer A */
	asm {
		move.w  	#13,-(a7)
		move.w  	#26,-(a7)
		trap		#14
		addq.w  	#4,a7
	}

	menuprompt(0L);
	midi_filter= save_filter;

	if (seq_i==maxseq_i)
		if (form_alert(1,BADNRECORD)==2)
			seq_i=0;

	change_mem(seqmem,4*seq_i);
	waitmouse();
}	/* end record_seq() */

/* play internal sequencer ..................................................*/

play_seq(overchan)
int overchan;	/* channel override (-1 for none) */
{
	register long *seqbuf;
	register unsigned int midibyte;
	register long nseq,seq_i,thistime;
	int clock();
	int ndata,ndata_i,chan,note;
	unsigned int statbyte;
	char *notestat;
	char noteoffstr[3],suststat[16];
	int savethru;

	waitmouse();

	seqbuf= (long*)(heap[seqmem].start);
	nseq= (heap[seqmem].nbytes)/4;
	if (!nseq) return;

	/* install clock() on timer A, 1000 hz, (1/1024 close enough) */
	asm {	
		pea		clock
		move.w  	#24,-(a7)
		move.w  	#6,-(a7)
		clr.w   	-(a7)
		move.w  	#31,-(a7)
		trap		#14
		adda.w	#12,a7
	}

	/* start with all notes on all channels off */
	notestat= (char*)(cnxscrsave);
	set_bytes(notestat,16*128L,0);

	savethru=midithru;	/* disable thru during this */
	midithru=0;
	if (savethru) thru_nts_off();

	graf_mouse(255,note_icon);
	masterclock=0L;
	ndata=0;
	for (seq_i=0; seq_i<nseq; )
	{
		/* either mouse button or any key = stop */
		if ( getmouse(&dummy,&dummy) ) break;
		if ( *keyb_head != *keyb_tail )
		{
			Crawcin();
			break;
		}

		thistime= seqbuf[seq_i]>>8;
		if (thistime<=masterclock)
		{
			midibyte= seqbuf[seq_i++] & 0x000000FFL ;

			if (midibyte&0x80)
			{
				statbyte= midibyte&0xF0;
				if (overchan>=0)
					midibyte= statbyte|(chan=overchan);
				else
					chan= midibyte&0x0F ;
				ndata= ndata_i= ndatabyte[ whichstat(statbyte) ];
			}
			else
			{
				if (ndata)
				{
					if (!ndata_i) ndata_i=ndata;
					ndata_i--;
					/* track note status */
					if ( (statbyte==midiNTON) || (statbyte==midiNTOF) )
					{
						if (ndata_i==1) note= midibyte;
						if (!ndata_i)
							notestat[128*chan+note]= (statbyte==midiNTON) && midibyte;
					}
					/* track sustain pedal (actually all controllers) */
					if ((statbyte==midiCTRL)&&!ndata_i) suststat[chan]=midibyte;
				}
			}
			asm { move.w midibyte,d2 }
			tran_byte();
		}
	}	/* end while (1) */

	/* turn off notes, sust ped */
	for (chan=0; chan<16; chan++)
	{
		for (note=0; note<128; note++)
		{
			if (notestat[128*chan+note])
			{
				noteoffstr[0]= midiNTOF | chan;
				noteoffstr[1]= note;
				noteoffstr[2]= 127;
				send_midi(noteoffstr,3);
			}
		}	/* end loop through notes */
		if (suststat[chan])
		{
			noteoffstr[0]= midiCTRL | chan;
			noteoffstr[1]= SUSTCTRL;
			noteoffstr[2]= 0;
			send_midi(noteoffstr,3);
		}
	}	/* end loop through channels */

	midithru=savethru;			/* restore thru */
	graf_mouse(ARROWMOUSE);		/* restore mouse */

	/* disable timer A */
	asm {
		move.w  	#13,-(a7)
		move.w  	#26,-(a7)
		trap		#14
		addq.w  	#4,a7
	}
	waitmouse();
}	/* end play_seq() */

/* master clock .............................................................*/

extern clock();
asm {
clock:
	move.w	SR,-(a7)
	andi.w	#0xFDFF,SR					; allow transmit interrupts
	move.l	a0,-(a7)

	lea		saveA4,a0					; restore Megamax global variable pointer
	movea.l	(a0),a0
	addq.l	#1,masterclock(a0)
clockexit:
	move.l	(a7)+,a0
	move.w	(a7)+,SR
	bclr		#5,0xFFFFFA0FL				;  clear interrupt-being-serviced bit
	rte
}	/* end clock() */

/* load sequencer file ......................................................*/

load_seq()
{
	char filename[13],pathname[80];
	int error;
	long load_file();

	filename[0]=0;
	tempmem= -1;
	Dsetdrv(orig_drive); dsetpath(orig_path);
	if (getfile(pathname,filename,SQC_EXT,QLDETITL)>0)
		if (load_file(pathname,filename))
			load_sqc(filename);
	dealloc_mem(tempmem);

}	/* end load_seq() */

load_sqc(filename)
char *filename;
{
	FILEHEADER *header;
	register long ptr,templong;
	int i;
	RECHEADER *recheader;

	ptr= heap[tempmem].start;
	header= (FILEHEADER*)(ptr);

	/* error if wrong kind of file */
	if (header->magic != sqcheader.magic )
	{
		big_alert(1,BADREAD1,filename,BADREAD2);
		return 1;
	}
	/* error if file version too high */
	if (header->version > sqcheader.version )
	{
		form_alert(1,BADVERSION);
		return 1;
	}

	/* delete start of file, leave only data */
	recheader= (RECHEADER*)(ptr + sizeof(*header));
	templong= recheader->length;
	copy_bytes(ptr+sizeof(*header)+sizeof(*recheader),ptr,templong);
	change_mem(tempmem,templong);

	/* swap heap handles */
	i= seqmem;
	seqmem= tempmem;
	tempmem= i;

	return 0;

}	/* end load_seq() */

/* save sequencer file ......................................................*/

save_seq()
{
	char filename[13],pathname[80];
	long endrecord= idEND;
	RECHEADER recheader;
	long addr[4],leng[4];
	register int j;
	long thisleng;

	/* can't save empty sequence */
	if (!heap[seqmem].nbytes) return;

	filename[0]=0;
	Dsetdrv(orig_drive);
	dsetpath(orig_path);
	if (getfile(pathname,filename,SQC_EXT,QSAVTITL)>0)
	{
		j=0;
		addr[j]= (long)(&sqcheader);	leng[j++]= sizeof(sqcheader);

		recheader.type= idSQC;
		recheader.length= heap[seqmem].nbytes;
		addr[j]= (long)(&recheader);	leng[j++]= sizeof(recheader);

		addr[j]= heap[seqmem].start;	leng[j++]= heap[seqmem].nbytes;
		addr[j]= (long)(&endrecord);	leng[j++]= 4;

		save_file(filename,pathname,j,addr,leng);
	}	/* end if got a file from file selector */
}	/* end save_seq() */

/* read midi bytes, with filter .............................................*/
/* returns byte, 0xFF for no byte */

get_midi()
{
	register unsigned int midibyte;
	register int which;

	midibyte= recv_byte();
	if (midibyte==0xFF) return 0xFF;		/* no byte to be received */
	if (midi_opsys) return midibyte;		/* midi op system already filtered */

	if (midibyte>0xF7)
	{
		if (midi_filter&1) return 0xFF;	/* filter real-time msgs */
		return midibyte;						/* doesn't affect running status */
	}
	else
	{	/* track running status */
		if (midibyte&0x80) runningstat= midibyte&0xF0;
	}

	/* selectively filter events */
	if ( midi_filter && (runningstat==0xFF) ) return 0xFF;	/* no status */
	which= whichstat(runningstat);
	if ( (which<7) && (which>=0) )
	{	/* filter p-bend/chan-p/controllers */
		if ((midi_filter&2) && ((which==6)||(which==5)||(which==3))) return 0xFF;
		/* filter patch changes */
		if ((midi_filter&4) && (which==4)) return 0xFF;
		/* filter note-on/note-off/poly-p */
		if ((midi_filter&8) && ((which==0)||(which==1)||(which==2))) return 0xFF;
	}

	/* !!! throughout all code, use #define'd midi status bytes (chan 1) */

	return midibyte;

}	/* end get_midi() */

/* which midi "operating system" is installed? .............................*/
/* returns 0= normal, 1= SoftLink, 2= MROS, etc. */

which_opsys()
{
   if ( xbios(27778)==15200259L ) return 1 ;   /* SoftLink */
	if ( *(long*)( *(long*)(0xA0) - 4 ) == 0xb0aeb31fL ) return 2;	/* MROS */
	/* others go here in future (MidiTasker, etc.) !!! */
	return 0;
}	/* end which_opsys() */

/* enable/disable VDI mouse tracking ........................................*/

midi_motv(on_off)
int on_off;		/* 1= enable GEM / disable thru, 0= disable GEM / enable thru */
{
	static long save_motv,save_butv,save_crit;
	static int save_thru= -1;
	static int last=1;
	int my_critical();

	if (midi_opsys) return;						/* not needed */

	if (last==on_off) return;
	last=on_off;

	if (on_off==1)		/* restore GEM */
	{
		*(long*)(Abase-50)= save_motv;
		*(long*)(Abase-58)= save_butv;
		*(long*)(0x404)= save_crit;
		save_thru= midithru;
		midithru=0;
		if (save_thru) thru_nts_off();
	}

	if (on_off==0)		/* save and disable GEM */
	{
		save_motv= *(long*)(Abase-50);
		save_butv= *(long*)(Abase-58);
		*(long*)(Abase-50)= (long)(&an_rts);
		*(long*)(Abase-58)= (long)(&an_rts);
		save_crit= *(long*)(0x404);
		*(long*)(0x404)= (long)(&my_critical);
		midithru=save_thru;
	/* fool GEM into thinking that mouse button has been released */
		asm {
			move.w	SR,-(a7)
			ori.w		#0x700,SR
			clr.w		d0
			move.l	save_butv(a4),a0
			jsr		(a0)
			move.w	(a7)+,SR
		}
	}

}	/* end midi_motv() */

extern my_critical();
asm {
my_critical:
	moveq		#0xFF,d0
	rts
}

/* turn off notes on midi thru channel ......................................*/
/* note: this routine can't call send_midi(), because send_midi() calls it! */

thru_nts_off()
{
	register int i;
	int savethru,saveport;
	int thru_recv();

	if (midi_opsys) return;	/* not needed */

	/* reset thru running status */
	asm {
		move.b	#midiSOX,d0
		jsr		thru_recv
	}

	savethru=midithru;
	midithru=0;
	saveport=midi_tport;
	midi_tport=thru_tport;

	/* turn off all notes:  Many instruments don't recognize "all notes off" */
	for (i=0; i<127; i++)
	{
		if (thru_note[i])
		{
			asm {
				move.w	#midiNTOF,d2
				or.b		thruchan(a4),d2
				jsr		tran_byte
				move.w	i,d2
				jsr		tran_byte
				move.w	#127,d2
				jsr		tran_byte
			}
		}
	}
	set_bytes(thru_note,128L,0);
	thru_head=thru_tail;

	/* sustain pedal off */
	if (thru_sust)
	{
		asm {
			move.w	#midiCTRL,d2
			or.b		thruchan(a4),d2
			jsr		tran_byte
			move.w	#SUSTCTRL,d2
			jsr		tran_byte
			move.w	#0,d2
			jsr		tran_byte
		}
	}
	thru_sust=0;
	midi_tport=saveport;
	midithru=savethru;

}	/* end thru_nts_off() */

/* EOF */
