***********************************************
*
* Falcon Extension for STOS, Audio sub-system
*
* V0.10a
*
* Compiler version
*

	OUTPUT	D:\STOS\COMPILER\FAUDIO.ECY

* Offsets to parts of the extension

START	dc.l	PARA-START
	dc.l	DATA-START
	dc.l	LIB1-START

* here is the library catalogue - ie length of each routine

CATALOG	dc.w	LIB2-LIB1	; I have 31 routines (inc. dummy's)
	dc.w	LIB3-LIB2
	dc.w	LIB4-LIB3
	dc.w	LIB5-LIB4
	dc.w	LIB6-LIB5
	dc.w	LIB7-LIB6
	dc.w	LIB8-LIB7
	dc.w	LIB9-LIB8
	dc.w	LIB10-LIB9
	dc.w	LIB11-LIB10
	dc.w	LIB12-LIB11
	dc.w	LIB13-LIB12
	dc.w	LIB14-LIB13
	dc.w	LIB15-LIB14
	dc.w	LIB16-LIB15
	dc.w	LIB17-LIB16
	dc.w	LIB18-LIB17
	dc.w	LIB19-LIB18
	dc.w	LIB20-LIB19
	dc.w	LIB21-LIB20
	dc.w	LIB22-LIB21
	dc.w	LIB23-LIB22
	dc.w	LIB24-LIB23
	dc.w	LIB25-LIB24
	dc.w	LIB26-LIB25
	dc.w	LIB27-LIB26
	dc.w	LIB28-LIB27
	dc.w	LIB29-LIB28
	dc.w	LIB30-LIB29
	dc.w	LIB31-LIB30
	dc.w	LIB32-LIB31
	dc.w	LIB33-LIB32
	dc.w	LIBEX-LIB33

* Here is the parameter table header

PARA	dc.w	33,33
	dc.w	pspeak_on-PARA
	dc.w	pgain-PARA
	dc.w	pdsp_play-PARA
	dc.w	patten-PARA
	dc.w	pdsp_stop-PARA
	dc.w	pfalc_sampos-PARA
	dc.w	pspeak_off-PARA
	dc.w	prgain-PARA
	dc.w	pset_gain-PARA
	dc.w	pratten-PARA
	dc.w	pset_atten-PARA
	dc.w	ptrack_name-PARA
	dc.w	pfalc_play-PARA
	dc.w	pdtm_name-PARA
	dc.w	pdtmplay-PARA
	dc.w	pdtm_inst-PARA
	dc.w	pdtmstop-PARA
	dc.w	ptracker_inst-PARA
	dc.w	psam_mode-PARA
	dc.w	pdtm_voices-PARA
	dc.w	pfalc_sample-PARA
	dc.w	pdummy-PARA
	dc.w	pfalc_samstop-PARA
	dc.w	pdummy-PARA
	dc.w	pfalc_micthru-PARA
	dc.w	pdummy-PARA
	dc.w	pdsp_process-PARA
	dc.w	pdummy-PARA
	dc.w	pdsp_clear-PARA
	dc.w	pdummy-PARA
	dc.w	pfalc_freq-PARA
	dc.w	pdummy-PARA
	dc.w	pdummy-PARA

* Here are the actual parameter definitions

pspeak_on	dc.b	0,1,1,0
pdsp_play	dc.b	0,0,1,1,0
pdsp_stop	dc.b	0,1,1,0
pspeak_off	dc.b	0,1,1,0
pset_gain	dc.b	0,0,",",0,1,1,0
pgain		dc.b	0,1,1,0
pset_atten	dc.b	0,0,",",0,1,1,0
patten		dc.b	0,1,1,0
pfalc_sampos	dc.b	0,0,1,1,0
prgain		dc.b	0,1,1,0
pfalc_play	dc.b	0,0,",",0,",",0,1,1,0
pratten		dc.b	0,1,1,0
pdtmplay	dc.b	0,0,",",0,1,1,0
pdtmstop	dc.b	0,1,1,0
psam_mode	dc.b	0,0,1,1,0
ptrack_name	dc.b	$80,0,1,1,0
pdtm_name	dc.b	$80,0,1,1,0
pfalc_sample	dc.b	0,0,",",0,1,1,0
pfalc_samstop	dc.b	0,1,1,0
pfalc_micthru	dc.b	0,1,1,0
pdtm_voices	dc.b	0,0,1,1,0
pdtm_inst	dc.b	$80,0,",",0,1,1,0
ptracker_inst	dc.b	$80,0,",",0,1,1,0
pdsp_process	dc.b	0,$80,",",0,",",0,1,1,0
pdsp_clear	dc.b	0,1,1,0
pfalc_freq	dc.b	0,0,1,1,0

pdummy		dc.b	0,1,1,0


* Here is the initialization code / data space

	EVEN

DATA	bra	COLDST


SaveArea079:    ds.b	6
dspname:	dc.b	'dspmod.bsw',0

*player079:      ds.b	11636
player079:	dc.l	0
	
Boot_dsp	MACRO
	move.w #113,-(sp)
	trap #14
	addq.w #2,sp

	move.w d0,-(sp)
	move.l \1,-(sp)
	lea.l \2,a2
	move.l	a2,-(sp)
	move.w #110,-(sp)
	trap #14
	add.w #12,sp
 	ENDM

TEMPS		equ	0


p_end		ds.l	1
dsp_buff	incbin	'digidsp2.out'
dsp_buff_end


soundflags	dc.b	0

freq		ds.w	1

pos_ptrs	ds.l	4

track_string	ds.b	24

COLDST	lea	player079(pc),a2
	move.l	a0,(a2)
	lea	11636(a0),a0
	cmp.l	a1,a0
	bcc	OUTOFMEM
	clr.w	d0
	lea	END(pc),a2
	rts

END	rts


OUTOFMEM
	moveq	#1,d0
	rts


************************************************
*
* My instructions / functions
*

* Speaker on
LIB1	dc.w	0
	move.b	#14,$ffff8800
	move.b	$ffff8800,d0
	and.b	#%10111111,d0
	move.b	#14,$ffff8800
	move.b	d0,$ffff8802
	rts

* lgain
LIB2	dc.w	0
	move.w	#-1,-(sp)
	move.w	#2,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	lsr.l	#4,d0
	andi.l	#$f,d0
	clr.l	d3
	move.w	d0,d3
	move.l	d3,-(a6)
	rts


* DSP play

LIB3	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,d3

	move.b	soundflags-DATA(a3),d0
	andi.b	#%11,d0
	tst.b	d0
*	bne	ntdne

	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#0,-(sp)		; load the dsp play routine
	lea.l	dspname-DATA(a3),a0
	move.l	a0,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	add.l	#8,sp

	tst	d0
*	blt	ntdne


	move	d0,d6


	move.l	player079-DATA(a3),a0
	lea.l	tbplay(pc),a1
	move.l	a0,(a1)

	move.l	a0,-(sp)
	move.l	#11636,-(sp)	
	move.w	d6,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp

	move.w	d6,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp

	movem.l	(sp)+,d0-d7/a0-a6
	move.l	d3,a0

	move.l	a0,-(sp)		; call it
        move.l  player079-DATA(a3),a0
	move.l  2(a0),d0        ;Relozieren
        add.l   6(a0),d0
        add.l   14(a0),d0
        adda.l  #$1c,a0
        move.l  a0,d1
        movea.l a0,a1
        movea.l a1,a2
        adda.l  d0,a1
        move.l  (a1)+,d0
        adda.l  d0,a2
        add.l   d1,(a2)
        clr.l   d0
L000A:  move.b  (a1)+,d0
        beq     L000C
        cmp.b   #1,d0
        beq     L000B
        adda.l  d0,a2
        add.l   d1,(a2)
        bra     L000A
L000B:  adda.l  #$fe,a2
        bra     L000A
L000C:

	move.l	(sp)+,a0
        moveq   #1,d0
	move.l	a6,-(sp)
	move.l	player079-DATA(a3),a6
	add.l	#28,a6
        jsr     (a6)
	move.l	(sp)+,a6
        lea     SaveArea079-DATA(a3),a0
        move.l  $0120.w,(a0)+
        move.b  $fffffa1b.w,(a0)+
        move.b  $fffffa21.w,(a0)+
        move.b  #246,$fffffa21.w
        move.b  #7,$fffffa1b.w
	lea.l	timer_b079(pc),a0
        move.l  a0,$0120.w
        bset    #0,$fffffa13.w
        bset    #0,$fffffa07.w

	move.w	#128,-(sp)	* lock sound-system
	trap	#14
	addq.l	#2,sp

	move.w	#104,-(sp)	* lock the DSP
	trap	#14
	addq.l	#2,sp

	move.b	soundflags-DATA(a3),d0
	ori.b	#%11,d0
	move.b	d0,soundflags-DATA(a3)
	rts

timer_b079:     movem.l d0-d7/a0-a6,-(sp)
		lea.l	tbplay(pc),a6
		move.l	(a6),a6
		add.l	#36,a6
                jsr     (a6)
                movem.l (sp)+,d0-d7/a0-a6
                bclr    #0,$fffffa0f.w
                rte

tbplay	dc.l	0

* lvolume
LIB4	dc.w	0
	move.w	#-1,-(sp)
	move.w	#0,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	lsr.l	#4,d0
	andi.l	#$f,d0
	clr.l	d3
	move.w	d0,d3
	move.l	d3,-(a6)
	rts


* DSP stop
LIB5	dc.w	0
	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.b	soundflags-DATA(a3),d0
	andi.b	#%11,d0
*	beq	ntdne

        bclr    #0,$fffffa07.w
        bclr    #0,$fffffa13.w
        lea     SaveArea079-DATA(a3),a0
        move.l  (a0)+,$0120.w
        move.b  (a0)+,$fffffa1b.w
        move.b  (a0)+,$fffffa21.w
	move.l	player079-DATA(a3),a0
	add.l	#32,a0
        jsr     (a0)

	move.w	#129,-(sp)	* unlock sound-system
	trap	#14
	addq.l	#2,sp

	move.w	#105,-(sp)	* unlock the DSP
	trap	#14
	addq.l	#2,sp

	move.b	soundflags-DATA(a3),d0
	andi.b	#%11111100,d0
	move.b	d0,soundflags-DATA(a3)

	rts


* Falc sampos
LIB6	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,d3

	lea.l	pos_ptrs-DATA(a3),a0
	move.l	a0,-(sp)
	move.w	#141,-(sp)
	trap	#14
	addq.l	#6,sp

	tst.l	d3
	bne.s	.recptr

	move.l	(a0),-(a6)
	bra.s	.retptr

.recptr	move.l	4(a0),-(a6)

.retptr	rts


* speaker off
LIB7	dc.w	0
	move.b	#14,$ffff8800
	move.b	$ffff8800,d0
	or.b	#%01000000,d0
	move.b	#14,$ffff8800
	move.b	d0,$ffff8802
	rts


* rgain
LIB8	dc.w	0
	move.w	#-1,-(sp)
	move.w	#3,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	lsr.l	#4,d0
	andi.l	#$f,d0
	clr.l	d3
	move.w	d0,d3
	move.l	d3,-(a6)

	rts


* set gain
LIB9	dc.w	0
	movem.l	(a6)+,d5/d3
	lsl.l	#4,d5	
	lsl.l	#4,d3

	move.w	d3,-(sp)
	move.w	#2,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	d5,-(sp)
	move.w	#3,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	rts


* rvolume
LIB10	dc.w	0
	move.l	(a6)+,d3
	lsl.l	#4,d3
	andi.l	#$f0,d3
	move.w	d3,-(sp)
	move.w	#1,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp	
	rts


* set volume
LIB11	dc.w	0
	move.l	(a6)+,d5
	move.l	(a6)+,d3
	lsl.l	#4,d5
	lsl.l	#4,d3
	
	move.w	d3,-(sp)
	move.w	#0,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	d5,-(sp)
	move.w	#1,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	rts


* track name
LIB12	dc.w	0
	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,a2
	lea	track_string-DATA(a3),a0
	move.l	a0,a1

	move.w	#20,(a0)+

	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+

	move.l	a1,-(a6)
	rts


* falc play
LIB13	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,d5
	move.w	freq-DATA(a3),d6
	move.l	(a6)+,d1
	move.l	(a6)+,d2

	move.b	soundflags-DATA(a3),d7
	move.b	d7,-(sp)
	andi.b	#%1,d7
	bne	ntdnesf
	move.b	(sp)+,d7

	move.l	d1,-(sp)	; setbuffer (XBIOS 131)
	move.l	d2,-(sp)	; ie. set the DMA playback buffer pointers
	move.w	#0,-(sp)
	move.w	#131,-(sp)
	trap	#14
	add.l	#12,sp

	move.w	#0,-(sp)	; Settrack (XBIOS 133)
	move.w	#0,-(sp)	; ie set number of tracks=1
	move.w	#133,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	#0,-(sp)	; Setmontrack (XBIOS 134)
	move.w	#134,-(sp)	; ie set output to track 1
	trap	#14
	addq.l	#4,sp

	andi.b	#%1000,d7
	tst.b	d7
	bne.s	.pldsp

	move.w	#1,-(sp)	; Devconnect (XBIOS 139)
	move.w	d6,-(sp)	; connect DMA play to DAC
	move.w	#0,-(sp)
	move.w	#$8,-(sp)
	move.w	#0,-(sp)
	move.w	#139,-(sp)
	trap	#14
	add.l	#12,sp

.pldsp	move.w	#-1,-(sp)	; Buffoper (XBIOS 136)
	move.w	#136,-(sp)	; set DMA play to go!
	trap	#14
	addq.l	#4,sp

	tst	d5
	beq.s	.nolp
	ori.w	#%10,d0

.nolp	ori.w	#1,d0		
	move.w	d0,-(sp)	; enable buffer...
	move.w	#136,-(sp)
	trap	#14
	addq.l	#4,sp	

ntdne	rts

ntdnesf	move.b	(sp)+,d7


* DTM name
LIB14	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,a2
	add.l	#22,a2
	lea	track_string-DATA(a3),a0
	move.l	a0,a1

	move.w	#20,(a0)+

	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+

	move.l	a1,-(a6)
	rts


* DTM play
LIB15	dc.w	0
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,d0
	move.l	(a6)+,d3

*	move.b	soundflags-DATA(a3),d0
*	andi.b	#%11,d0
**	bne	ntdne
*
*	move.l	d3,-(sp)
*
*	add.l	d3,d0
*	move.l	d0,p_end-DATA(a3)
*	move.l	d0,a3
*	move.l	#0,2(a3)
*
*	jsr do_note
*
*	move.l	a3,-(sp)
*
*	Boot_dsp #(dsp_buff_end-dsp_buff)/3,dsp_buff-DATA(a3)
*	
*	jsr init_adc	;Initialise le son
*	jsr Init_all	;
*	move.l (sp)+,a0
*	jsr Init_module	;Initialisation du module
*	tst.b d0		;Y'a une erreur ?
*	bne FIN		;Si oui alors terminus
*	
*	jsr joue		;Player en marche
*
*	move.l	(sp)+,a3
*
*	move.w	#128,-(sp)	* lock sound-system
*	trap	#14
*	addq.l	#2,sp
*
*	move.w	#104,-(sp)	* lock the DSP
*	trap	#14
*	addq.l	#2,sp
*
*	move.b	soundflags-DATA(a3),d0
*	ori.b	#%11,d0
*	move.b	d0,soundflags-DATA(a3)
*FIN
*	movem.l	(sp)+,d0-d7/a0-a6

	rts

* include "dtm_com2.s"



* dtm inst
LIB16	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,a0
	move.l	(a6)+,d0

	cmpi.l	#'D.T.',(a0)
	bne	estr

.dilp	cmpi.l	#'INST',(a0)
	beq.s	.difnd
	addq.l	#1,a0
	bra.s	.dilp

.difnd	move.w	8(a0),d2
	cmp	d0,d2
	blt	estr

	add.l	#10,a0

	subq.l	#1,d0
.di2lp	tst	d0
	beq	.di2fnd
	subq	#1,d0
	add.l	#50,a0
	bra.s	.di2lp

.di2fnd	add.l	#18,a0
	lea	track_string-DATA(a3),a2
	move.l	a2,a1
	
	move.w	#22,(a2)+

	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.w	(a0)+,(a2)+

	move.l	a1,-(a6)

	rts

estr	move.w	#0,track_string-DATA(a3)
	lea.l	track_string-DATA(a3),a0
	move.l	a0,-(a6)
	rts


* DTM stop
LIB17	dc.w	0
	rts
	

* tracker inst
LIB18	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,a0
	move.l	(a6)+,d0

	add.l	#20,a0
	subq	#1,d0
.tilp	tst	d0
	beq.s	.tifnd
	subq	#1,d0
	add.l	#30,a0
	bra.s	.tilp

.tifnd	lea	track_string-DATA(a3),a2
	move.l	a2,a1
	move.w	#22,(a2)+

	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.w	(a0)+,(a2)+

	move.l	a1,-(a6)
	rts


* sammode
LIB19	dc.w	0
	move.l	(a6)+,d0
	move.w	d0,-(sp)
	move.w	#132,-(sp)
	trap	#14
	addq.l	#4,sp
	rts


* dtm voices
LIB20	dc.w	0
	move.l	(a6)+,a0

	cmpi.l	#'D.T.',(a0)
	bne	dtmndne

.vlp	cmpi.l	#'PATT',(a0)
	beq.s	.vfnd
	addq.l	#1,a0
	bra.s	.vlp

.vfnd	move.w	8(a0),d3
	clr.l	d2
	clr.l	d4
	andi.l	#$ffff,d3
	move.l	d3,-(a6)
	rts

dtmndne	move.l	#-1,-(a6)
	rts

* falc_sample
LIB21	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.w	freq-DATA(a3),d6
	move.l	(a6)+,d1
	move.l	(a6)+,d2

	move.b	soundflags-DATA(a3),d7
	move.b	d7,d5
	andi.b	#%1,d7
	bne	.ntdne

	move.l	d1,-(sp)	; setbuffer (XBIOS 131)
	move.l	d2,-(sp)	; ie. set the DMA record buffer pointers
	move.w	#1,-(sp)
	move.w	#131,-(sp)
	trap	#14
	add.l	#12,sp

	andi.b	#%100,d5
	tst.b	d5
	bne.s	.rcdsp

	move.w	#1,-(sp)	; Devconnect (XBIOS 139)
	move.w	d6,-(sp)	; connect ADC to DMA record
	move.w	#0,-(sp)
	move.w	#1,-(sp)
	move.w	#3,-(sp)
	move.w	#139,-(sp)
	trap	#14
	add.l	#12,sp

.rcdsp	clr.w	-(sp)		; ensure mic is connected
	move.w	#5,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	#4,-(sp)
	move.w	#136,-(sp)
	trap	#14
	addq.l	#4,sp

.ntdne	rts

* dummy
LIB22	dc.w	0
	rts

* falc_samstop
LIB23	dc.w	0

	move.w	#0,-(sp)	; Buffoper (XBIOS 136)
	move.w	#136,-(sp)	; disable all DMA buffers
	trap	#14
	addq.l	#4,sp

	rts

* dummy
LIB24	dc.w	0
	rts

* falc_micthru
LIB25	dc.w	0

	move.w	#-1,-(sp)	; get current value
	move.w	#5,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp	

	andi.w	#%11,d0
	tst.w	d0
	bne.s	.setmic

	move.w	#3,-(sp)	; disable mic thru
	move.w	#5,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	bra.s	.finmic

.setmic	clr.w	-(sp)
	move.w	#5,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	#%11,-(sp)
	move.w	#4,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

.finmic	rts


* dummy
LIB26	dc.w	0
	rts

* dsp process
LIB27	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,d7
	move.l	(a6)+,a4
	move.l	(a6)+,d3

	move.b	soundflags-DATA(a3),d4
	tst.b	d4
	bne	ntdneproc

	movem.l	a0-a6,-(sp)

	move.l	d3,a1		convert string to TOS format
	move.w	(a1)+,d2	
	move.w	d2,d1		d1=length of string
	move.l	d3,a2
strl1	move.b	(a1)+,(a2)+
	dbra	d2,strl1
	move.w	#0,(a2)+
	movem.l	d1/d3,-(sp)	store for later

	move.w	#2,-(sp)	; set adder in to matrix
	move.w	#4,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	#0,-(sp)	; set adc in to microphone
	move.w	#5,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	move.l	availy(pc),-(sp)	; get free DSP memory
	move.l	availx(pc),-(sp)
	move.w	#106,-(sp)
	trap	#14
	add.l	#10,sp

	lea.l	availy(pc),a0
	move.l	(a0),-(sp)	; reserve the DSP memory
	lea.l	availx(pc),a0
	move.l	(a0),-(sp)
	move.w	#107,-(sp)
	trap	#14
	add.l	#10,sp

	move.l	a4,-(sp)	; Download .LOD with ability 'AJ'
	move.w	#'AJ',-(sp)
	move.l	d3,-(sp)
	move.w	#108,-(sp)
	trap	#14
	add.l	#12,sp

	move.w	#1,-(sp)	; ensure DSP is not tri-stated
	move.w	#1,-(sp)
	move.w	#137,-(sp)
	trap	#14
	addq.l	#6,sp

	cmpi	#1,d7
	beq	dsprocmd1
	
	cmpi	#2,d7
	beq	dsprocmd2

*	cmpi	#3,d7
*	beq	dsprocmd3

	move.w	#1,-(sp)	ADC -> DSP
	move.w	freq-DATA(a3),-(sp)
	move.w	#0,-(sp)
	move.w	#2,-(sp)
	move.w	#3,-(sp)
	move.w	#139,-(sp)
	trap	#14
	add.l	#12,sp

	move.w	#1,-(sp)	DSP -> DAC
	move.w	freq-DATA(a3),-(sp)
	move.w	#0,-(sp)
	move.w	#8,-(sp)
	move.w	#1,-(sp)
	move.w	#139,-(sp)
	trap	#14
	add.l	#12,sp

	move.w	#128,-(sp)	* lock sound-system
	trap	#14
	addq.l	#2,sp

	move.w	#104,-(sp)	* lock the DSP
	trap	#14
	addq.l	#2,sp

	move.b	soundflags-DATA(a3),d1
	ori.b	#%11,d1
	move.b	d1,soundflags-DATA(a3)

	bra	dsprocfin

dsprocmd1
	move.w	#1,-(sp)	DMA -> DSP
	move.w	freq-DATA(a3),-(sp)
	move.w	#0,-(sp)
	move.w	#2,-(sp)
	move.w	#0,-(sp)
	move.w	#139,-(sp)
	trap	#14
	add.l	#12,sp

	move.w	#1,-(sp)	DSP -> DAC
	move.w	freq-DATA(a3),-(sp)
	move.w	#0,-(sp)
	move.w	#8,-(sp)
	move.w	#1,-(sp)
	move.w	#139,-(sp)
	trap	#14
	add.l	#12,sp

	move.w	#128,-(sp)	* lock sound-system
	trap	#14
	addq.l	#2,sp

	move.w	#104,-(sp)	* lock the DSP
	trap	#14
	addq.l	#2,sp

	move.b	soundflags-DATA(a3),d1
	ori.b	#%1010,d1
	move.b	d1,soundflags-DATA(a3)

	bra	dsprocfin

dsprocmd2
	move.w	#1,-(sp)	ADC -> DSP
	move.w	freq-DATA(a3),-(sp)
	move.w	#0,-(sp)
	move.w	#2,-(sp)
	move.w	#3,-(sp)
	move.w	#139,-(sp)
	trap	#14
	add.l	#12,sp

	move.w	#1,-(sp)	DSP -> DMA
	move.w	freq-DATA(a3),-(sp)
	move.w	#0,-(sp)
	move.w	#1,-(sp)
	move.w	#1,-(sp)
	move.w	#139,-(sp)
	trap	#14
	add.l	#12,sp

	move.w	#128,-(sp)	* lock sound-system
	trap	#14
	addq.l	#2,sp

	move.w	#104,-(sp)	* lock the DSP
	trap	#14
	addq.l	#2,sp

	move.b	soundflags-DATA(a3),d1
	ori.b	#%110,d1
	move.b	d1,soundflags-DATA(a3)

*	bra.s	dsprocfin
*
*dsprocmd3
*	move.w	#1,-(sp)	DMA -> DSP
*	move.w	freq-DATA(a3),-(sp)
*	move.w	#0,-(sp)
*	move.w	#2,-(sp)
*	move.w	#0,-(sp)
*	move.w	#139,-(sp)
*	trap	#14
*	add.l	#12,sp
*
*	move.w	#1,-(sp)	DSP -> DMA
*	move.w	freq-DATA(a3),-(sp)
*	move.w	#0,-(sp)
*	move.w	#1,-(sp)
*	move.w	#1,-(sp)
*	move.w	#139,-(sp)
*	trap	#14
*	add.l	#12,sp

dsprocfin
	movem.l	(sp)+,d1/d3
	move.l	d3,a1		restore string to STOS format
	move.l	d3,a2
	add.l	#2,a2
	move.w	d1,d0
strl2	move.b	(a1)+,(a2)+
	dbra	d0,strl2
	move.l	d3,a1
	move.w	d1,(a1)

	movem.l	(sp)+,a0-a6

	rts

availy	ds.l	1
availx	ds.l	1

ntdneproc
	rts

* dummy
LIB28	dc.w	0
	rts

* dsp clear
LIB29	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.w	#-1,-(sp)	; store left vol.
	move.w	#0,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp
	move.l	d0,d7

	move.w	#-1,-(sp)	; store right vol.
	move.w	#1,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp
	move.l	d0,d6

	move.w	#-1,-(sp)	; store left gain
	move.w	#2,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp
	move.l	d0,d5

	move.w	#-1,-(sp)	; store right gain
	move.w	#3,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp
	move.l	d0,d4

	move.w	#1,-(sp)	; reset sub-system
	move.w	#140,-(sp)
	trap	#14
	addq.l	#4,sp

	move.w	#115,-(sp)	; flush DSP
	trap	#14
	addq.l	#2,sp

	move.w	#129,-(sp)	* unlock sound-system
	trap	#14
	addq.l	#2,sp

	move.w	#105,-(sp)	* unlock the DSP
	trap	#14
	addq.l	#2,sp

	move.b	#0,soundflags-DATA(a3)	; clear sound-flags
	move.w	#1,freq-DATA(a3)

	move.w	d7,-(sp)	; restore left vol.
	move.w	#0,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	d6,-(sp)	; restore right vol.
	move.w	#1,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	d5,-(sp)	; restore left gain
	move.w	#2,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	d4,-(sp)	; restore right gain
	move.w	#3,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	#3,-(sp)	; connect PSG to the ADC
	move.w	#5,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	#3,-(sp)	; connect both ADC and matrix to adder
	move.w	#4,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	rts


* dummy
LIB30	dc.w	0
	rts


* falc frequency
LIB31	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,d3
	move.w	d3,freq-DATA(a3)
	rts

* dummy
LIB32	dc.w	0
	rts

* dummy
LIB33	dc.w	0
	rts



*** The end.....

LIBEX	dc.w	0