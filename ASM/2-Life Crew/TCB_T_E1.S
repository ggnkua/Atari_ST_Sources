**************************************************************************
*		  TCB:s STE-replay-rout for TCB-tracker,		 *
*        disassembled, edited, commented, improved and bugfixed by	 *
*		       The greatest man around:				 *
*			     - Greenface -				 *
*			        - of -					 *
*		            - 2-Life Crew -				 *
**************************************************************************
*		Changes made to the STE-replay-rout:			 *
*		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			 *
*									 *
*	Initialisation is now faster, because it now checks if the	 *
*	  volume is to be changed, and the frequency list calculation	 *
*	  time has been reduced. But it is also slower, because it now	 *
*	  converts the samples to pcm-format...				 *
*	The bug with tempo 0 is now fixed.				 *
*	The sequencer is a little bit faster. (not much though)		 *
*	The dma-interrupt now occurs with 10072 Hz resp. 8302 Hz instead *
*	  of 10240 Hz and 8474 Hz. Thus gives you little more time and	 *
*	  a little bit more correct sound.				 *
*	The dma-interrupt is now optimised, and uses less regs...	 *
*	  Now it only uses a2-a6 and the replay-rout is now approx.	 *
*	  6600-8000 clockcycles faster (depending on Amiga-button)	 *
*	The dma replay-speed is increased to 50 kHz, thus giving us a	 *
*	  better sound. (lower replay-speed is said to giva a more	 *
*	  distinct bass)						 *
*	In my disassembly there was a major bug in the pitch-bend fx	 *
*	  that is now fixed, but it was so 'big', that I don't think	 *
*	  AN Cool is responsible for that one...			 *
**************************************************************************
*	jsr	init_mod	;inits module, adress to module in a0
*	jsr	sequenser	;the sequenser runs every VBI

test:
	movem.l a0-a6/d0-d7,-(sp)
	pea	0
	move.w	#32,-(sp)	;super
	trap	#1
	addq.l	#6,sp
	move.l	d0,xsavesp
	bclr	#0,$484
	lea	module,a0
	jsr	init_mod
	move.w	#0,$ffff8900.w
	lea	xmwdata,a0
	move.w	#3,d0
mwwrite:
	move.w	#$7ff,$ffff8924.w
mwwrite2:
	cmpi.w	#$7ff,$ffff8924.w
	bne.s	mwwrite2
	move.w	(a0)+,$ffff8922.w
	dbf	d0,mwwrite
	move.l	#$486,xtemp
	move.b	xtemp+1,$ffff8903.w
	move.b	xtemp+2,$ffff8905.w
	move.b	xtemp+3,$ffff8907.w
	move.l	#$48a,xtemp
	move.b	xtemp+1,$ffff890f.w
	move.b	xtemp+2,$ffff8911.w
	move.b	xtemp+3,$ffff8913.w
	move.w	#3,$ffff8920.w
	move.w	#3,$ffff8900.w
	jsr	x_save_ints
	jsr	x_init_ints
	clr.w	xvflag
demoloop:
	cmpi.w	#1,xvflag
	bne	demoloop
	clr.w	xvflag

	lea	$ffff8209.w,a0
	moveq	#0,d0
wfhc:
	move.b	(a0),d0
	beq.s	wfhc
	not.w	d0
	lsr.w	d0,d0

	move.w	#$700,$ffff8240.w
	jsr	sequenser
	move.w	#$777,$ffff8240.w

	cmpi.b	#$3b,$fffffc02.w	;"F1"
	bne	demoloop

	jsr	x_restore_ints
	move.w	#0,$ffff8900.w
	move.l	xsavesp,-(sp)
	move.w	#32,-(sp)	;super
	trap	#1
	addq.l	#6,sp
	movem.l (sp)+,a0-a6/d0-d7
	clr.w	(sp)		;eXit
	trap	#1

x_VBI:
	move.w	#1,xvflag
	rte
xsavesp:
	ds.l	1
xvflag:
	ds.w	1
xtemp:
	ds.l	1
xmwdata:
	dc.w	%0000000011010100	*mastervolume
	dc.w	%0000010010000110	*treble
	dc.w	%0000010001000110	*bass
	dc.w	%0000000000000001	*mixer

x_save_ints:
	move.b	$fffffa07.w,xsave_mfp07
	move.b	$fffffa09.w,xsave_mfp09
	move.b	$fffffa13.w,xsave_mfp13
	move.b	$fffffa15.w,xsave_mfp15
	move.b	$fffffa19.w,xsave_mfp19
	move.b	$fffffa1f.w,xsave_mfp1f
	move.l	$134.l,xsave_dma_int
	move.l	$70.w,xsave_VBI
	rts
x_init_ints:
	clr.b	$fffffa09.w
	clr.b	$fffffa15.w
	lea	module,a0
	move.w	$90(a0),d0
	lea	mfp_freqs,a0
	move.b	0(a0,d0.w),$fffffa1f.w
	move.b	#1,$fffffa19.w
	move.b	#32,$fffffa07.w
	move.b	#32,$fffffa13.w
	bclr	#3,$fffffa17.w
	move.l	#dma_int,$134.l
	move.l	#x_VBI,$70.w
	rts
mfp_freqs:
	dc.b	61	;amiga button off
	dc.b	74	;amiga button on
x_restore_ints:
	move.b	xsave_mfp07,$fffffa07.w
	move.b	xsave_mfp09,$fffffa09.w
	move.b	xsave_mfp13,$fffffa13.w
	move.b	xsave_mfp15,$fffffa15.w
	move.b	xsave_mfp19,$fffffa19.w
	move.b	xsave_mfp1f,$fffffa1f.w
	move.l	xsave_dma_int,$134.l
	move.l	xsave_VBI,$70.w
	move.w	#$000,$ffff8246.w	;set character-colour
	rts
xsave_mfp07:
	ds.b	1
xsave_mfp09:
	ds.b	1
xsave_mfp13:
	ds.b	1
xsave_mfp15:
	ds.b	1
xsave_mfp19:
	ds.b	1
xsave_mfp1f:
	ds.b	1
xsave_dma_int:
	ds.l	1
xsave_VBI:
	ds.l	1

*	here it ends
**********************************************************

init_mod:
	moveq	#0,d0			;(a0 = modulestart)
	move.l	8(a0),d0		;number of patterns
	mulu	#512,d0 		;each pattern = 512 bytes
	addi.l	#306,d0 		;add 306 for samplesection
	add.l	a0,d0			;add modulestart
	move.l	d0,end_of_patterns	;store samplesectionstart
	addq.l	#4,d0
	move.l	d0,sample_control	;store adress to sample-control values
	addi.l	#64,d0
	move.l	d0,sample_table 	;store adress to sample-offset
	move.b	14(a0),seq_point	;sequens table
	move.l	a0,module_start 	;modulestart
	jsr	init_samples		;inits sample volume
	jsr	sample_loop		;sets sample loop
	jsr	calc_freq_tab		;calculate frequency table
	jsr	sample_convert
	move.b	#0,event_count

	movea.l module_start,a0
	move.b	12(a0),d0		;get tempo
	not.b	d0			;invert
	andi	#15,d0			;and make sure it is not
	move.b	d0,12(a0)		;a value over 15
	move.b	d0,tempo_count

	move.w	#1,loop_onoff1		;set no loop and no sound
	move.w	#1,loop_onoff2		;for all channels
	move.w	#1,loop_onoff3
	move.w	#1,loop_onoff4
	movea.l #freq_tab,a2
	lea	no_sound,a3		;track 1
	move.l	a3,samp_endtr1
	lea	no_sound,a4		;track 2
	move.l	a4,samp_endtr2
	lea	no_sound,a5		;track 3
	move.l	a5,samp_endtr3
	lea	no_sound,a6		;track 4
	move.l	a6,samp_endtr4
	jsr	handle_event		;get going
	rts
sample_convert:
	movea.l	end_of_patterns,a0
	movea.l	(a0),a1
	lea	196(a0),a0
	adda.l	a0,a1
.loop
	add.b	#$80,(a0)+
	cmpa.l	a0,a1
	bne	.loop
	rts
init_samples:
	moveq	#15,d2
next_sample:
	move.l	d2,d3
	lsl.l	#3,d3			; *8
	movea.l sample_table,a1
	movea.l 0(a1,d3.w),a0
	adda.l	end_of_patterns,a0	;get sample start
	move.l	a0,d4
	add.l	4(a1,d3.w),d4		;get sample end adress
	movea.l sample_control,a1
	move.l	d2,d3
	lsl.l	#2,d3			; *4
	moveq	#0,d0
	move.b	0(a1,d3.w),d0		;get sample volume
	cmpi.b	#$7f,d0			;check if volume need altering
	beq	no_volume_change	;nope
	movea.l d4,a1
	jsr	set_volume
no_volume_change:
	dbf	d2,next_sample		;next sample
	rts
set_volume:
	moveq	#0,d3
	move.b	d0,d3		;get sample volume
	not.b	d3		; 0-d3 -> d3
	andi.b	#127,d3		; max 127...
volume_loop:
	moveq	#0,d1
	move.b	(a0),d1
	mulu	d0,d1
	asr.w	#7,d1		; /128
	add.b	d3,d1
	move.b	d1,(a0)+
	cmpa.l	a1,a0		;sample end?
	bne	volume_loop
	rts
sample_loop:
	moveq	#15,d7
next_sample_loop:
	jsr	set_loop
	dbf	d7,next_sample_loop
	rts
set_loop:
	moveq	#0,d1
	move.b	d7,d1		;sample no
	lsl.w	#3,d1		; *8
	movea.l sample_table,a0
	movea.l 0(a0,d1.w),a1		;sample start (offset)
	adda.l	4(a0,d1.w),a1		;sample length
	suba.l	#700,a1
	cmpa.l	#-1,a1
	ble.s	next_sample2		;short sample, take care of next
	adda.l	end_of_patterns,a1	;sample end adress
	movea.l a1,a0
	moveq	#0,d0
	moveq	#0,d1
	move.b	d7,d0		;sample no
	lsl.l	#2,d0		; *4
	movea.l sample_control,a1
	move.w	2(a1,d0.w),d1	;get loop value
	cmp.w	#0,d1		;check if sample should loop
	beq.s	no_loop		;nope
	movea.l a0,a1
	suba.l	d1,a1
	move.w	#699,d0
.loop1:
	move.b	(a1)+,(a0)+
	dbf	d0,.loop1
next_sample2:
	rts			;next sample
no_loop:
	move.w	#699,d0
.loop:
	move.b	#127,(a0)+
	dbf	d0,.loop
	rts			;next sample

**************************************************************
*   This part calcylates tabs for the frequency-conversion

calc_freq_tab:
	moveq	#36,d0
	lea	freq_calc_tab,a0
	lea	freq_tab,a1		;empty buffer (28800 bytes)
	lea	point_freq,a2	;empty buffer (36*4 bytes)
l0028:
	move.l	(a0)+,d1
	move.l	a1,(a2)+
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	move.w	#399,d7
l0029:
	add.l	d1,d2
	move.l	d2,d3
	swap	d3		;actually it is a divide by 65536
	sub.w	d3,d4
	neg.w	d4
	move.w	d4,(a1)+
	move.w	d3,d4
	dbf	d7,l0029
	dbf	d0,l0028
	rts
freq_calc_tab:
	dc.l	32768,34716,36780,38967,41285,43740,46340,49096
	dc.l	52015,55108,58385,61857,65536,69432,73561,77935
	dc.l	82570,87480,92681,98193,104031,110217,116771,123715
	dc.l	131072,138865,147123,155871,165140,174960,185363
	dc.l	196386,208063,220435,233543,247430,262144,277731
	dc.l	294246,311743,330280,349920,370727,392772,416127
	dc.l	440871,467087,494861,524288 

end_of_patterns:
	ds.l	1
sample_table:
	ds.l	1
sample_control:
	ds.l	1
tempo_count:
	ds.w	1
event_count:
	ds.w	1
curr_seq:
	ds.w	1
seq_point:
	ds.l	1
curr_event:
	ds.l	4
module_start:
	ds.l	1
****************************************************************************
*	This is the sequenser-part that runs each VBI			   *
*	I've made it just a little bit faster, but who knows, that little  *
*	bit could be just what U needed.....				   *

sequenser:
	jsr	special_fx			;special fx
	subq.b	#1,tempo_count
	bge.s	gettoutahere		;tempo 0.....
	moveq	#0,d0
	movea.l module_start,a0
	move.b	12(a0),tempo_count	;get tempo
	move.b	event_count,d0
	addq.b	#1,d0
	andi.b	#63,d0
	move.b	d0,event_count
	beq.s	next_patt
	bra.s	handle_event
gettoutahere:
	rts
next_patt:
	move.b	curr_seq,d1
	addq.b	#1,d1
	cmp.b	142(a0),d1	;restart_value
	bcs.s	next_patt2	;nope
	move.w	#1,loop_onoff1
	move.w	#1,loop_onoff2
	move.w	#1,loop_onoff3
	move.w	#1,loop_onoff4
	lea	no_sound,a3
	move.l	a3,samp_endtr1
	lea	no_sound,a4
	move.l	a4,samp_endtr2
	lea	no_sound,a5
	move.l	a5,samp_endtr3
	lea	no_sound,a6
	move.l	a6,samp_endtr4
	moveq	#0,d1
next_patt2:
	andi.b	#127,d1		;max 128 seq_point
	move.b	d1,curr_seq
	moveq	#0,d0
	move.b	d1,d0
	lea	14(a0),a0
	adda.l	d0,a0
	move.b	(a0),seq_point
handle_event:
	moveq	#0,d0
	moveq	#0,d1
	move.b	event_count,d1
	movea.l module_start,a0
	lea	306(a0),a0	;pattern start
	move.b	seq_point,d0
	lsl.w	#8,d0
	add.l	d0,d0		; =*512
	lsl.w	#3,d1		; *8
	add.l	d1,d0
	adda.l	d0,a0		;pattern adress
;	lea	curr_event,a1	;this little part is not necessary
;	move.l	(a0)+,(a1)+	;if you're not interested in what
;	move.l	(a0)+,(a1)+	;the rout currently is playing
track_1:
	move	#$2700,sr	;stop interrupts
;	lea	-8(a1),a0
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0)+,d0	;track 1 - tone/octav
	move.b	(a0)+,d1	;track 1 - sample/special
	tst.b	d0
	beq	track_2		;none of the above
	lea	tone_octavtab,a1
	move.b	0(a1,d0.w),d0
	add.w	d0,d0			;*2
	add.w	d0,d0			;*2=*4
	lea	point_freq,a1
	move.l	0(a1,d0.w),freq_tr1
	move.w	d1,d2
	andi.w	#-16,d2			;and sample
	lsr.w	#1,d2			; /2
	movea.l sample_table,a1
	movea.l 0(a1,d2.w),a3
	adda.l	end_of_patterns,a3	;sample start
	move.l	4(a1,d2.w),samp_endtr1
	move.l	a3,d0
	add.l	d0,samp_endtr1
	subi.l	#700,samp_endtr1	;sample_end
	moveq	#0,d0
	movea.l sample_control,a1
	lsr.w	#1,d2			; /2
	move.w	2(a1,d2.w),d0		;get loop value
	cmp.w	#0,d0
	beq.s	l003b
	move.l	samp_endtr1,l0090
	move.l	samp_endtr1,l0094
	sub.l	d0,l0090
	clr.w	loop_onoff1
	bra.s	track_2
l003b:
	move.w	#1,loop_onoff1
	move.l	#no_sound,l0090
	move.l	#no_sound,l0094
track_2:
	andi.w	#15,d1			;and track 1 specials
	move.w	d1,special_tr1		;save track 1 specials
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0)+,d0	;track 2 tone/octav
	move.b	(a0)+,d1	;track 2 sample/specials
	tst.b	d0
	beq	track_3		;none of the above, next track
	lea	tone_octavtab,a1
	move.b	0(a1,d0.w),d0
	add.w	d0,d0			; *2
	add.w	d0,d0			; *2=*4
	lea	point_freq,a1
	move.l	0(a1,d0.w),freq_tr2
	move.w	d1,d2
	andi.w	#-16,d2			;and sample
	lsr.w	#1,d2			; /2
	movea.l sample_table,a1
	movea.l 0(a1,d2.w),a4
	adda.l	end_of_patterns,a4
	move.l	4(a1,d2.w),samp_endtr2
	move.l	a4,d0
	add.l	d0,samp_endtr2
	subi.l	#700,samp_endtr2
	moveq	#0,d0
	movea.l sample_control,a1
	lsr.w	#1,d2			; /2
	move.w	2(a1,d2.w),d0
	cmp.w	#0,d0
	beq.s	l003d
	move.l	samp_endtr2,l0091
	move.l	samp_endtr2,l0095
	sub.l	d0,l0091
	clr.w	loop_onoff2
	bra.s	track_3
l003d:
	move.w	#1,loop_onoff2
	move.l	#no_sound,l0091
	move.l	#no_sound,l0095
track_3:
	andi.w	#15,d1			;and track 2 specials
	move.w	d1,special_tr2		;save track 2 specials
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0)+,d0		;track 3 tone/octav
	move.b	(a0)+,d1		;track 3 sample/specials
	tst.b	d0
	beq	track_4			;none, next track
	lea	tone_octavtab,a1
	move.b	0(a1,d0.w),d0
	add.w	d0,d0
	add.w	d0,d0			; =*4
	lea	point_freq,a1
	move.l	0(a1,d0.w),freq_tr3
	move.w	d1,d2
	andi.w	#-16,d2			;and sample
	lsr.w	#1,d2			; /2
	movea.l sample_table,a1
	movea.l 0(a1,d2.w),a5
	adda.l	end_of_patterns,a5
	move.l	4(a1,d2.w),samp_endtr3
	move.l	a5,d0
	add.l	d0,samp_endtr3
	subi.l	#700,samp_endtr3
	moveq	#0,d0
	movea.l sample_control,a1
	lsr.w	#1,d2
	move.w	2(a1,d2.w),d0
	cmp.w	#0,d0
	beq.s	l003f
	move.l	samp_endtr3,l0092
	move.l	samp_endtr3,l0096
	sub.l	d0,l0092
	clr.w	loop_onoff3
	bra.s	track_4
l003f:
	move.w	#1,loop_onoff3
	move.l	#no_sound,l0092
	move.l	#no_sound,l0096
track_4:
	andi.w	#15,d1			;and track 3 specials
	move.w	d1,special_tr3		;save track 3 specials
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0)+,d0		;track 4 tone/octav
	move.b	(a0)+,d1		;track 4 sample/specials
	tst.b	d0
	beq	l0042			;none, go on
	lea	tone_octavtab,a1
	move.b	0(a1,d0.w),d0
	add.w	d0,d0
	add.w	d0,d0			; =*4
	lea	point_freq,a1
	move.l	0(a1,d0.w),freq_tr4
	move.w	d1,d2
	andi.w	#-16,d2			;and sample
	lsr.w	#1,d2			; /2
	movea.l sample_table,a1
	movea.l 0(a1,d2.w),a6
	adda.l	end_of_patterns,a6
	move.l	4(a1,d2.w),samp_endtr4
	move.l	a6,d0
	add.l	d0,samp_endtr4
	subi.l	#700,samp_endtr4
	moveq	#0,d0
	movea.l sample_control,a1
	lsr.w	#1,d2			; /2
	move.w	2(a1,d2.w),d0
	cmp.w	#0,d0
	beq.s	l0041
	move.l	samp_endtr4,l0093
	move.l	samp_endtr4,l0097
	sub.l	d0,l0093
	clr.w	loop_onoff4
	bra.s	l0042
l0041:
	move.w	#1,loop_onoff4
	move.l	#no_sound,l0093
	move.l	#no_sound,l0097
l0042:
	andi.w	#15,d1			;and track 4 specials
	move.w	d1,special_tr4		;save track 4 specials
	move.l	freq_tr1,d3
	move.l	freq_tr2,d0
	sub.l	d3,d0
	move.l	freq_tr3,d1
	sub.l	d3,d1
	move.l	freq_tr4,d2
	sub.l	d3,d2
	lea	l00ad,a0		;frequency add value for track 2
	move.w	d0,2(a0)
	lea	l00ae,a0		;frequency add value for track 2
	move.w	d1,2(a0)
	lea	l00af,a0		;frequency add value for track 2
	move.w	d2,2(a0)
	movea.l d3,a2			;   -"- track 1
	move	#$2300,sr		;allow interrupts
	rts

*	end of sequenser part
*******************************************************************************
*	start of special FX rout!

pitch_bend1:
	move.w	276(a1),d2	;get pitch/bend value
	jmp	(a0)
pitch_bend2:
	move.w	278(a1),d2	;get pitch/bend value
	jmp	(a0)
pitch_bend3:
	move.w	280(a1),d2	;get pitch/bend value
	jmp	(a0)
pitch_bend4:
	move.w	282(a1),d2	;get pitch/bend value
	jmp	(a0)
pitch_bend5:
	move.w	284(a1),d2	;get pitch/bend value
	jmp	(a0)
pitch_bend6:
	move.w	286(a1),d2	;get pitch/bend value
	jmp	(a0)
pitch_bend7:
	move.w	288(a1),d2	;get pitch/bend value
	jmp	(a0)
pitch_bend8:
	move.w	290(a1),d2	;get pitch/bend value
	jmp	(a0)
pitch_bend9:
	move.w	292(a1),d2	;get pitch/bend value
	jmp	(a0)
pitch_benda:
	move.w	294(a1),d2	;get pitch/bend value
	jmp	(a0)
**************************************************************
*	so far so good, here comes the routs that does the
*	actual pitch/bending....

pitchit_tr1:
	ext.l	d2
	move.l	freq_tr1,d1
	sub.l	d2,d1
	cmp.l	#freq_tab,d1
	bcs.s	l004f
	cmp.l	#freq_tab_end,d1
	bge	l0050
l004e:
	move.l	d1,freq_tr1
	jsr	l005d
	bra	spec_tr2
l004f:
	move.l	#freq_tab,d1
	bra.s	l004e
l0050:
	move.l	#freq_tab_end,d1
	bra.s	l004e
*****************************************************
*	for track 2.....

l0051:
	ext.l	d2
	move.l	freq_tr2,d1
	sub.l	d2,d1
	cmp.l	#freq_tab,d1
	bcs.s	l0053
	cmp.l	#freq_tab_end,d1
	bge.s	l0054
l0052:
	move.l	d1,freq_tr2
	jsr	l005d
	bra	spec_tr3
l0053:
	move.l	#freq_tab,d1
	bra.s	l0052
l0054:
	move.l	#freq_tab_end,d1
	bra.s	l0052
**********************************************************
*	track 3.....

l0055:
	ext.l	d2
	move.l	freq_tr3,d1
	sub.l	d2,d1
	cmp.l	#freq_tab,d1
	bcs.s	l0057
	cmp.l	#freq_tab_end,d1
	bge.s	l0058
l0056:
	move.l	d1,freq_tr3
	jsr	l005d
	bra	spec_tr4
l0057:
	move.l	#freq_tab,d1
	bra.s	l0056
l0058:
	move.l	#freq_tab_end,d1
	bra.s	l0056
**********************************************************
*	and finally track 4

l0059:
	ext.l	d2
	move.l	freq_tr4,d1
	sub.l	d2,d1
	cmp.l	#freq_tab,d1
	bcs.s	l005b
	cmp.l	#freq_tab_end,d1
	bge.s	l005c
l005a:
	move.l	d1,freq_tr4
	jsr	l005d
	bra	return_to_special_fx
l005b:
	move.l	#freq_tab,d1
	bra.s	l005a
l005c:
	move.l	#freq_tab_end,d1
	bra.s	l005a

l005d:
	move.l	freq_tr1,d3
	move.l	freq_tr2,d0
	sub.l	d3,d0
	move.l	freq_tr3,d1
	sub.l	d3,d1
	move.l	freq_tr4,d2
	sub.l	d3,d2
	lea	l00ad,a0		;frequency add value for track 2
	move.w	d0,2(a0)
	lea	l00ae,a0		;frequency add value for track 2
	move.w	d1,2(a0)
	lea	l00af,a0		;frequency add value for track 2
	move.w	d2,2(a0)
	rts

*	and here it ends!
*********************************************************
*	dis routs does the cut sample fx!

cut_sample1:
	move.l	a3,l0067
	move.l	samp_endtr1,l0068
	move.l	l0090,l0069
	move.l	l0094,l006a
	move.w	loop_onoff1,l006b
	movea.l module_start,a0
	cmpi.w	#2,296(a0)
	beq	spec_tr2
	lea	no_sound,a3
	move.l	#no_sound,samp_endtr1
	move.w	#1,loop_onoff1
	clr.w	special_tr1
	bra	spec_tr2

cont_sample1:
	cmpi.l	#0,l0067
	beq	spec_tr2
	movea.l l0067,a3
	move.l	l0068,samp_endtr1
	move.l	l0069,l0090
	move.l	l006a,l0094
	move.w	l006b,loop_onoff1
	clr.w	special_tr1
	jsr	l005d
	bra	spec_tr2


cut_sample2:
	move.l	a4,l006c
	move.l	samp_endtr2,l006d
	move.l	l0091,l006e
	move.l	l0095,l006f
	move.w	loop_onoff2,l0070
	movea.l module_start,a0
	cmpi.w	#2,296(a0)
	beq	spec_tr3
	lea	no_sound,a4
	move.l	#no_sound,samp_endtr2
	move.w	#1,loop_onoff2
	clr.w	special_tr2
	bra	spec_tr3

cont_sample2:
	cmpi.l	#0,l006c
	beq	spec_tr3
	movea.l l006c,a4
	move.l	l006d,samp_endtr2
	move.l	l006e,l0091
	move.l	l006f,l0095
	move.w	l0070,loop_onoff2
	clr.w	special_tr2
	jsr	l005d
	bra	spec_tr3
cut_sample3:
	move.l	a5,l0071
	move.l	samp_endtr3,l0072
	move.l	l0092,l0073
	move.l	l0096,l0074
	move.w	loop_onoff3,l0075
	movea.l module_start,a0
	cmpi.w	#2,296(a0)
	beq	spec_tr4
	lea	no_sound,a5
	move.l	#no_sound,samp_endtr3
	move.w	#1,loop_onoff3
	clr.w	special_tr3
	bra	spec_tr4

cont_sample3:
	cmpi.l	#0,l0071
	beq	spec_tr4
	movea.l l0071,a5
	move.l	l0072,samp_endtr3
	move.l	l0073,l0092
	move.l	l0074,l0096
	move.w	l0075,loop_onoff3
	clr.w	special_tr3
	jsr	l005d
	bra	spec_tr4
cut_sample4:
	move.l	a6,l0076
	move.l	samp_endtr4,l0077
	move.l	l0093,l0078
	move.l	l0097,l0079
	move.w	loop_onoff4,l007a
	movea.l module_start,a0
	cmpi.w	#2,296(a0)
	beq	return_to_special_fx
	lea	no_sound,a6
	move.l	#no_sound,samp_endtr4
	move.w	#1,loop_onoff4
	clr.w	special_tr4
	bra	return_to_special_fx

cont_sample4:
	cmpi.l	#0,l0076
	beq	return_to_special_fx
	movea.l l0076,a6
	move.l	l0077,samp_endtr4
	move.l	l0078,l0093
	move.l	l0079,l0097
	move.w	l007a,loop_onoff4
	clr.w	special_tr4
	jsr	l005d
	bra	return_to_special_fx

l0067:
	ds.l	1
l0068:
	ds.l	1
l0069:
	ds.l	1
l006a:
	ds.l	1
l006b:
	ds.l	1
l006c:
	ds.l	1
l006d:
	ds.l	1
l006e:
	ds.l	1
l006f:
	ds.l	1
l0070:
	ds.l	1
l0071:
	ds.l	1
l0072:
	ds.l	1
l0073:
	ds.l	1
l0074:
	ds.l	1
l0075:
	ds.l	1
l0076:
	ds.l	1
l0077:
	ds.l	1
l0078:
	ds.l	1
l0079:
	ds.l	1
l007a:
	ds.l	1

**************************************************************************
*	this part does the end pattern special
l007b:
	move.b	#-1,event_count
	clr.w	special_tr1
	bra	spec_tr2
l007c:
	move.b	#-1,event_count
	clr.w	special_tr2
	bra	spec_tr3
l007d:
	move.b	#-1,event_count
	clr.w	special_tr3
	bra	spec_tr4
l007e:
	move.b	#-1,event_count
	clr.w	special_tr4
	bra	return_to_special_fx

************************************************************************
spec_tr1:
	movea.l module_start,a1
	move.w	special_tr1,d0
	beq	spec_tr2
	lea	pitchit_tr1,a0
	cmp.w	#1,d0
	beq	pitch_bend1
	cmp.w	#2,d0
	beq	pitch_bend2
	cmp.w	#3,d0
	beq	pitch_bend3
	cmp.w	#4,d0
	beq	pitch_bend4
	cmp.w	#5,d0
	beq	pitch_bend5
	cmp.w	#6,d0
	beq	pitch_bend6
	cmp.w	#7,d0
	beq	pitch_bend7
	cmp.w	#8,d0
	beq	pitch_bend8
	cmp.w	#9,d0
	beq	pitch_bend9
	cmp.w	#$a,d0
	beq	pitch_benda
	cmp.w	#$b,d0
	beq	cut_sample1
	cmp.w	#$c,d0
	beq	cont_sample1
	cmp.w	#$d,d0
	beq	l007b
spec_tr2:
	movea.l module_start,a1
	tst.w	special_tr2
	beq	spec_tr3
	lea	l0051,a0
	move.w	special_tr2,d0
	cmp.w	#1,d0
	beq	pitch_bend1
	cmp.w	#2,d0
	beq	pitch_bend2
	cmp.w	#3,d0
	beq	pitch_bend3
	cmp.w	#4,d0
	beq	pitch_bend4
	cmp.w	#5,d0
	beq	pitch_bend5
	cmp.w	#6,d0
	beq	pitch_bend6
	cmp.w	#7,d0
	beq	pitch_bend7
	cmp.w	#8,d0
	beq	pitch_bend8
	cmp.w	#9,d0
	beq	pitch_bend9
	cmp.w	#10,d0
	beq	pitch_benda
	cmp.w	#11,d0
	beq	cut_sample2
	cmp.w	#12,d0
	beq	cont_sample2
	cmp.w	#13,d0
	beq	l007c
spec_tr3:
	movea.l module_start,a1
	tst.w	special_tr3
	beq	spec_tr4
	lea	l0055,a0
	move.w	special_tr3,d0
	cmp.w	#1,d0
	beq	pitch_bend1
	cmp.w	#2,d0
	beq	pitch_bend2
	cmp.w	#3,d0
	beq	pitch_bend3
	cmp.w	#4,d0
	beq	pitch_bend4
	cmp.w	#5,d0
	beq	pitch_bend5
	cmp.w	#6,d0
	beq	pitch_bend6
	cmp.w	#7,d0
	beq	pitch_bend7
	cmp.w	#8,d0
	beq	pitch_bend8
	cmp.w	#9,d0
	beq	pitch_bend9
	cmp.w	#10,d0
	beq	pitch_benda
	cmp.w	#11,d0
	beq	cut_sample3
	cmp.w	#12,d0
	beq	cont_sample3
	cmp.w	#13,d0
	beq	l007d
spec_tr4:
	movea.l module_start,a1
	tst.w	special_tr4
	beq	return_to_special_fx
	lea	l0059,a0
	move.w	special_tr4,d0
	cmp.w	#1,d0
	beq	pitch_bend1
	cmp.w	#2,d0
	beq	pitch_bend2
	cmp.w	#3,d0
	beq	pitch_bend3
	cmp.w	#4,d0
	beq	pitch_bend4
	cmp.w	#5,d0
	beq	pitch_bend5
	cmp.w	#6,d0
	beq	pitch_bend6
	cmp.w	#7,d0
	beq	pitch_bend7
	cmp.w	#8,d0
	beq	pitch_bend8
	cmp.w	#9,d0
	beq	pitch_bend9
	cmp.w	#10,d0
	beq	pitch_benda
	cmp.w	#11,d0
	beq	cut_sample4
	cmp.w	#12,d0
	beq	cont_sample4
	cmp.w	#13,d0
	beq	l007e
return_to_special_fx:
	rts

special_fx:
	jsr	spec_tr1
	movea.l freq_tr1,a2
	cmpa.l	samp_endtr1,a3
	blt.s	l0086
	cmpi.w	#1,loop_onoff1
	beq.s	l0085
	suba.l	samp_endtr1,a3
	adda.l	l0090,a3
	move.l	l0094,samp_endtr1
	bra.s	l0086
l0085:
	lea	no_sound,a3
	move.l	a3,samp_endtr1
l0086:
	cmpa.l	samp_endtr2,a4
	blt.s	l0088
	cmpi.w	#1,loop_onoff2
	beq.s	l0087
	suba.l	samp_endtr2,a4
	adda.l	l0091,a4
	move.l	l0095,samp_endtr2
	bra.s	l0088
l0087:
	lea	no_sound,a4
	move.l	a4,samp_endtr2
l0088:
	cmpa.l	samp_endtr3,a5
	blt.s	l008a
	cmpi.w	#1,loop_onoff3
	beq.s	l0089
	suba.l	samp_endtr3,a5
	adda.l	l0092,a5
	move.l	l0096,samp_endtr3
	bra.s	l008a
l0089:
	lea	no_sound,a5
	move.l	a5,samp_endtr3
l008a:
	cmpa.l	samp_endtr4,a6
	blt.s	l008c
	cmpi.w	#1,loop_onoff4
	beq.s	l008b
	suba.l	samp_endtr4,a6
	adda.l	l0093,a6
	move.l	l0097,samp_endtr4
	bra.s	l008c
l008b:
	lea	no_sound,a6
	move.l	a6,samp_endtr4
l008c:
	rts

*******************************************************************
*	Here is the part that runs the PCM-chip.....
dma_int:
	move.b	(a3),$486.w	;track 1 Left
	move.b	(a4),$487.w	;track 2 Right
	move.b	(a6),$488.w	;track 4 Left
	move.b	(a5),$489.w	;track 3 Right
l00ad:	adda.w	0(a2),a4	;increase pointers
l00ae:	adda.w	0(a2),a5
l00af:	adda.w	0(a2),a6
	adda.w	(a2)+,a3
	rte
*	...and guess what?!?  It is OPTIMISED!
*******************************************************************
addfr_2:
	dc.l	l00ad
addfr_3:
	dc.l	l00ae
addfr_4:
	dc.l	l00af
l0090:
	dc.l	no_sound
l0091:
	dc.l	no_sound
l0092:
	dc.l	no_sound
l0093:
	dc.l	no_sound
l0094:
	dc.l	no_sound
l0095:
	dc.l	no_sound
l0096:
	dc.l	no_sound
l0097:
	dc.l	no_sound
loop_onoff1:
	dc.w	1
loop_onoff2:
	dc.w	1
loop_onoff3:
	dc.w	1
loop_onoff4:
	dc.w	1
tone_octavtab:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,0,0,0,0
	dc.b	12,13,14,15,16,17,18,19,20,21,22,23
	dc.b	0,0,0,0,24,25,26,27,28,29,30,31,32,33
	dc.b	34,35,0,0,0,0
freq_tr1:
	dc.l	freq_tab
freq_tr2:
	dc.l	freq_tab
freq_tr3:
	dc.l	freq_tab
freq_tr4:
	dc.l	freq_tab
	dc.l	freq_tab
special_tr1:
	dc.w	0
special_tr2:
	dc.w	0
special_tr3:
	dc.w	0
special_tr4:
	dc.w	0
samp_endtr1:
	dc.l	no_sound
samp_endtr2:
	dc.l	no_sound
samp_endtr3:
	dc.l	no_sound
samp_endtr4:
	dc.l	no_sound
no_sound:
	dcb.b	1000,0
point_freq:
	ds.l	37
freq_tab:
	ds.b	29600
freq_tab_end:
module:
	incbin	E:\tcb_mods.mod\chaos.mod
zuend:
	end
