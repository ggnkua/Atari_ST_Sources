*************************************************
*
* Falcon Extension for STOS, Audio sub-system
*
* V0.11
*
*

	OUTPUT	D:\STOS\STOS\FAUDIO.EXY

* Jump header

	bra	INIT

***********************************************
*
* Header
*

* Start of token list

	dc.b	128

TOKENS	dc.b	"speaker on",128
	dc.b	"lgain",129
	dc.b	"dsp play",130
	dc.b	"lvolume",131
	dc.b	"dsp stop",132
	dc.b	"falc sampos",133
	dc.b	"speaker off",134
	dc.b	"rgain",135
	dc.b	"set gain",136
	dc.b	"rvolume",137
	dc.b	"set volume",138
	dc.b	"tracker name",139
	dc.b	"falc play",140
	dc.b	"dtm name",141
	dc.b	"dtm play",142
	dc.b	"dtm inst",143
	dc.b	"dtm stop",144
	dc.b	"tracker inst",145
	dc.b	"falc sammde",146
	dc.b	"dtm voices",147
	dc.b	"falc sample",148
	dc.b	"falc samstop",150
	dc.b	"falc micthru",152
	dc.b	"dsp process",154
	dc.b	"dsp clear",156
	dc.b	"falc frequency",158
	dc.b	"ntk play",160
	dc.b	"ntk stop",162

* The end of the token list

	dc.b	0

	even

* Now the jump table

JUMPS	dc.w	35
	dc.l	speak_on
	dc.l	gain	
	dc.l	dsp_play	
	dc.l	atten
	dc.l	dsp_stop	
	dc.l	falc_sampos
	dc.l	speak_off	
	dc.l	rgain
	dc.l	set_gain	
	dc.l	ratten
	dc.l	set_atten	
	dc.l	track_name
	dc.l	falc_play
	dc.l	dtm_name
	dc.l	dtmplay
	dc.l	dtm_inst
	dc.l	dtmstop
	dc.l	tracker_inst
	dc.l	sam_mode
	dc.l	dtm_voices
	dc.l	falc_sample
	dc.l	dummy
	dc.l	falc_samstop
	dc.l	dummy
	dc.l	falc_micthru
	dc.l	dummy
	dc.l	dsp_process
	dc.l	dummy
	dc.l	dsp_clear
	dc.l	dummy
	dc.l	falc_freq
	dc.l	dummy
	dc.l	ntk_play
	dc.l	dummy
	dc.l	ntk_stop

* The welcome mesages in English and French

WELCOME	dc.b	10,"Audio sub-system installed.",0
	dc.b	10,"le sub-system audio est active.",0
	dc.b	0
	even

* Reserve return and system address space

SYSTEM	dc.l	0
RETURN	dc.l	0	


* The routine that is called on start-up

INIT	lea	END,a0
	lea	COLDST,a1
	rts

COLDST	move.l	a0,SYSTEM

	move.w	#105,-(sp)
	trap	#14
	addq.l	#2,sp

	move.w	#129,-(sp)
	trap	#14
	addq.l	#2,sp

	move.b	#0,soundflags

	lea	WELCOME,a0	; vital stuff
	lea	WARMST,a1
	lea	TOKENS,a2
	lea	JUMPS,a3
	rts

* Executed on UNDO in editor

WARMST
	rts

************************************************
*
* My instructions / functions
*

* Heres some stuff for DTM play
	
Boot_dsp	MACRO
	move.w #113,-(sp)
	trap #14
	addq.w #2,sp

	move.w d0,-(sp)
	move.l \1,-(sp)
	move.l \2,-(sp)
	move.w #110,-(sp)
	trap #14
	add.w #12,sp
 	ENDM

TEMPS		equ	0

	SECTION TEXT


* instruction starts DSP tracker
dsp_play
	move.l	(sp)+,RETURN		; save return address

	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4		; get parameters
	tst.b	d2
	bne	TYPEMIS

	move.b	soundflags,d0
	andi.b	#%11,d0
	tst.b	d0
	bne	ntdne

	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#0,-(sp)		; load the dsp play routine
	move.l	#dspname,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	add.l	#8,sp

	tst	d0
	blt	ntdne

	move	d0,d6

	move.l	#player079,-(sp)
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
        lea     player079,a0
        bsr     reloziere079
	move.l	(sp)+,a0
        moveq   #1,d0
        jsr     player079+28
	jsr	init079

	move.w	#104,-(sp)	* lock the dsp
	trap	#14
	addq.l	#2,sp

	move.w	#128,-(sp)	* lock sound system
	trap	#14
	addq.l	#2,sp

	move.b	soundflags,d0
	ori.b	#%11,d0
	move.b	d0,soundflags

	move.l	RETURN,a0
	jmp	(a0)

* instruction stops DSP tracker
dsp_stop
	move.l	(sp)+,RETURN

	tst	d0
	bne	SYNTAX

	move.b	soundflags,d0
	andi.b	#%11,d0
	beq	ntdne

	bsr	off079
        jsr     player079+28+4

	move.w	#105,-(sp)	* unlock dsp
	trap	#14
	addq.l	#2,sp

	move.w	#129,-(sp)	* unlock sound
	trap	#14
	addq.l	#2,sp

	move.b	soundflags,d0
	andi.b	#%11111100,d0
	move.b	d0,soundflags

	move.l	RETURN,a0
	jmp	(a0)


timer_b079:     movem.l d0-a6,-(sp)
                jsr     player079+28+8
                movem.l (sp)+,d0-a6
                bclr    #0,$fffffa0f.w
                rte


init079:        lea     SaveArea079,a0
                move.l  $120.w,(a0)+
                move.b  $fffffa1b.w,(a0)+
                move.b  $fffffa21.w,(a0)+
                move.b  #246,$fffffa21.w
                move.b  #7,$fffffa1b.w
                move.l  #timer_b079,$120.w
                bset    #0,$fffffa13.w
                bset    #0,$fffffa07.w
                rts

off079:         bclr    #0,$fffffa07.w
                bclr    #0,$fffffa13.w
                lea     SaveArea079,a0
                move.l  (a0)+,$120.w
                move.b  (a0)+,$fffffa1b.w
                move.b  (a0)+,$fffffa21.w
                rts

reloziere079:   move.l  2(a0),d0        ;Relozieren
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
L000A:          move.b  (a1)+,d0
                beq     L000C
                cmp.b   #1,d0
                beq     L000B
                adda.l  d0,a2
                add.l   d1,(a2)
                bra     L000A
L000B:          adda.l  #$fe,a2
                bra     L000A
L000C:          rts


* instruction switches off the speaker
speak_off
	move.l	(sp)+,RETURN

	tst	d0
	bne	SYNTAX

	move.b	#14,$ffff8800
	move.b	$ffff8800,d0
	or.b	#%01000000,d0
	move.b	#14,$ffff8800
	move.b	d0,$ffff8802

	move.l	RETURN,a0
	jmp	(a0)


* instruction switches on the speaker
speak_on
	move.l	(sp)+,RETURN

	tst	d0
	bne	SYNTAX

	move.b	#14,$ffff8800
	move.b	$ffff8800,d0
	and.b	#%10111111,d0
	move.b	#14,$ffff8800
	move.b	d0,$ffff8802

	move.l	RETURN,a0
	jmp	(a0)


* instruction sets the input gain
set_gain
	move.l	(sp)+,RETURN
	cmpi	#2,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	; get right gain
	tst.b	d2
	bne	TYPEMIS
	lsl.l	#4,d3
	move.l	d3,d5

	movem.l	(sp)+,d2-d4	; get left gain
	tst.b	d2
	bne	TYPEMIS
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
	

	move.l	RETURN,a0
	jmp	(a0)


* function returns the left input gain
gain	move.l	(sp)+,RETURN

	tst	d0
	bne	SYNTAX

	move.w	#-1,-(sp)
	move.w	#2,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp	
	lsr.l	#4,d0
	
	clr.l	d2
	clr.l	d3
	move.b	d0,d3

	move.l	RETURN,a0
	jmp	(a0)


* function returns the right input gain
rgain	move.l	(sp)+,RETURN

	tst	d0
	bne	SYNTAX

	move.w	#-1,-(sp)
	move.w	#3,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp	
	lsr.l	#4,d0
	
	clr.l	d2
	clr.l	d3
	move.b	d0,d3

	move.l	RETURN,a0
	jmp	(a0)


* instruction sets the attenuation
set_atten
	move.l	(sp)+,RETURN

	cmpi	#2,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	; get right attenuation
	tst.b	d2
	bne	TYPEMIS
	lsl.l	#4,d3
	move.l	d3,d5

	movem.l	(sp)+,d2-d4	; get left attenuation
	tst.b	d2
	bne	TYPEMIS
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

	move.l	RETURN,a0
	jmp	(a0)


* function returns the left attenuation
atten	move.l	(sp)+,RETURN

	tst	d0
	bne	SYNTAX

	move.w	#-1,-(sp)
	move.w	#0,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp
	lsr.l	#4,d0

	clr.l	d2
	clr.l	d3
	move.w	d0,d3

	move.l	RETURN,a0
	jmp	(a0)


* function returns the right attenuation
ratten	move.l	(sp)+,RETURN

	tst	d0
	bne	SYNTAX

	move.w	#-1,-(sp)
	move.w	#1,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp
	lsr.l	#4,d0

	clr.l	d2
	clr.l	d3
	move.w	d0,d3

	move.l	RETURN,a0
	jmp	(a0)


* instruction plays a DTM module

dtmplay	move.l	(sp)+,RETURN

	cmpi	#2,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	; get length
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d0

	movem.l	(sp)+,d2-d4	; get start address
	tst.b	d2
	bne	TYPEMIS

	move.b	soundflags,d0
	andi.b	#%11,d0
	bne	ntdne

	movem.l	a3/a5/a6,-(sp)

	move.l	d3,-(sp)

	add.l	d3,d0
	move.l	d0,p_end
	move.l	d0,a3
	move.l	#0,2(a3)

	jsr do_note

	Boot_dsp #(dsp_buff_end-dsp_buff)/3,#dsp_buff
	
	jsr init_adc	;Initialise le son
	jsr Init_all	;
	move.l (sp)+,a0
	jsr Init_module	;Initialisation du module
	tst.b d0		;Y'a une erreur ?
	bne FIN		;Si oui alors terminus
	
	jsr joue		;Player en marche

	move.w	#104,-(sp)	* lock the dsp
	trap	#14
	addq.l	#2,sp

	move.w	#128,-(sp)	* lock sound system
	trap	#14
	addq.l	#2,sp

	move.b	soundflags,d0
	ori.b	#%11,d0
	move.b	d0,soundflags
FIN
	movem.l	(sp)+,a3/a5/a6

	move.l	RETURN,a0
	jmp	(a0)


* instruction stops a DTM module

dtmstop	move.l	(sp)+,RETURN

	tst	d0
	bne	SYNTAX

	move.b	soundflags,d0
	andi.b	#%11,d0
	beq	ntdne

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

	jsr	jouepas

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

	move.w	#105,-(sp)	* unlock dsp
	trap	#14
	addq.l	#2,sp

	move.w	#129,-(sp)	* unlock sound
	trap	#14
	addq.l	#2,sp

	move.b	soundflags,d0
	andi.b	#%11111100,d0
	move.b	d0,soundflags

	move.l	RETURN,a0
	jmp	(a0)


* Function returns the name of a .DTM module

dtm_name
	move.l	(sp)+,RETURN

	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS

	move.l	d3,a2
	add.l	#22,a2
	lea	track_string,a0
	move.l	a0,a1

	move.w	#20,(a0)+

	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+

*	bsr	.remnul

	move.l	a1,d3
	move.b	#$80,d2	
	clr.l	d4

	move.l	RETURN,a0
	jmp	(a0)

* removes chr(0)'s from a STOS string
* a1=STOS format string
.remnul	move.b	(a1),d0
	moveq.l	#1,d1
.nullp	cmp.w	d1,d0
	bgt	.nulfin
	move.b	0(a1,d1.w),d3
	beq.s	.nul
	addq.w	#1,d1
	bra.s	.nullp
.nulfin	rts
.nul	subq.w	#1,d1
	move.b	d1,(a1)
	rts	

* Function returns the name of a .MOD module

track_name
	move.l	(sp)+,RETURN

	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS

	move.l	d3,a2
	lea	track_string,a0
	move.l	a0,a1

	move.w	#20,(a0)+

	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+

*	bsr	remnl

	move.l	a1,d3
	move.b	#$80,d2	
	clr.l	d4

	move.l	RETURN,a0
	jmp	(a0)

track_string	ds.b	24

* removes chr(0)'s from a STOS string
* a1=STOS format string
remnl	move.b	(a1),d0
	moveq.l	#1,d1
.nullp	cmp.w	d1,d0
	bgt	.nulfin
	move.b	0(a1,d1.w),d3
	beq.s	.nul
	addq.w	#1,d1
	bra.s	.nullp
.nulfin	rts
.nul	subq.w	#1,d1
	move.b	d1,(a1)
	rts	


* Instruction plays a sample with the DMA

falc_play
	move.l	(sp)+,RETURN

	cmpi	#3,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	; get loop
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d5

	move.w	freq,d6

	movem.l	(sp)+,d2-d4	; get end
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d1

	movem.l	(sp)+,d2-d4	; get start
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d2

	move.b	soundflags,d7
	move.b	d7,-(sp)
	andi.b	#%1,d7
	bne	ntdne
	move.b	(sp)+,d7

	move.l	d1,-(sp)	; setbuffer (XBIOS 131)
	move.l	d3,-(sp)	; ie. set the DMA playback buffer pointers
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

	tst.l	d5
	beq.s	.nolp
	ori.w	#%10,d0

.nolp	ori.w	#1,d0		
	move.w	d0,-(sp)	; enable buffer...
	move.w	#136,-(sp)
	trap	#14
	addq.l	#4,sp	

	move.l	RETURN,a0
	jmp	(a0)


* Instruction sets the sample replay rez

sam_mode
	move.l	(sp)+,RETURN

	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS

	move.w	d3,-(sp)
	move.w	#132,-(sp)
	trap	#14
	addq.l	#4,sp

	move.l	RETURN,a0
	jmp	(a0)


* Instruction records a sample with the DMA

falc_sample
	move.l	(sp)+,RETURN

	cmpi	#2,d0
	bne	SYNTAX

	move.w	freq,d6

	movem.l	(sp)+,d2-d4	; get end
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d1

	movem.l	(sp)+,d2-d4	; get start
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d2

	move.b	soundflags,d7
	move.b	d7,d5
	andi.b	#%1,d7
	bne	ntdne


	move.l	d1,-(sp)	; setbuffer (XBIOS 131)
	move.l	d3,-(sp)	; ie. set the DMA record buffer pointers
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

.rcdsp	clr.w	-(sp)		; ensure mic is connected...
	move.w	#5,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	#4,-(sp)	; go!!
	move.w	#136,-(sp)
	trap	#14
	addq.l	#4,sp

	move.l	RETURN,a0
	jmp	(a0)


* Function returns the possition of the DMA buffers

falc_sampos
	move.l	(sp)+,RETURN
	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS

	move.l	#pos_ptrs,-(sp)
	move.w	#141,-(sp)
	trap	#14
	addq.l	#6,sp

	lea.l	pos_ptrs,a0

	tst.l	d3
	bne.s	.recptr

	move.l	(a0),d3
	bra.s	.retptr

.recptr	move.l	4(a0),d3

.retptr	clr.l	d2

	move.l	RETURN,a0
	jmp	(a0)



* Instruction stops all DMA sample transfer

falc_samstop
	move.l	(sp)+,RETURN
	tst	d0
	bne	SYNTAX

	move.w	#0,-(sp)	; Buffoper (XBIOS 136)
	move.w	#136,-(sp)	; disable all DMA buffers
	trap	#14
	addq.l	#4,sp

	move.l	RETURN,a0
	jmp	(a0)


* Instruction enables/disables the microphone through line....

falc_micthru
	move.l	(sp)+,RETURN
	tst	d0
	bne	SYNTAX

	move.w	#-1,-(sp)	; get current value
	move.w	#5,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp	

	andi.w	#%11,d0
	tst.w	d0
	bne.s	.setmic

	move.w	#3,-(sp)	; disable mic thru.
	move.w	#5,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	bra.s	.finmic

.setmic	clr.w	-(sp)		; enable mic thru
	move.w	#5,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

.finmic	move.l	RETURN,a0
	jmp	(a0)


* Function returns the number of voices in a .DTM module
dtm_voices
	move.l	(sp)+,RETURN
	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

	cmpi.l	#'D.T.',(a0)
	bne	ntdne

.vlp	cmpi.l	#'PATT',(a0)
	beq.s	.vfnd
	addq.l	#1,a0
	bra.s	.vlp

.vfnd	move.w	8(a0),d3
	clr.l	d2
	clr.l	d4
	andi.l	#$ffff,d3

	move.l	RETURN,a0
	jmp	(a0)


* Function returns the name of a sample in a .DTM module
dtm_inst
	move.l	(sp)+,RETURN
	cmpi	#2,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d0

	cmpi.l	#'D.T.',(a0)
	bne	ntdne

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
	lea	track_name,a2
	move.l	a2,a1
	
	move.w	#22,(a2)+

	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.w	(a0)+,(a2)+

*	bsr	rmnul

	move.b	#$80,d2
	move.l	a1,d3
	clr.l	d4

	move.l	RETURN,a0
	jmp	(a0)

estr	lea	track_string,a0
	move.w	#0,(a0)
	move.b	#$80,d2
	move.l	a0,d3
	clr.l	d4

	move.l	RETURN,a0
	jmp	(a0)

* removes chr(0)'s from a STOS string
* a1=STOS format string
rmnul	move.b	(a1),d0
	moveq.l	#1,d1
.nullp	cmp.w	d1,d0
	bgt	.nulfin
	move.b	0(a1,d1.w),d3
	beq.s	.nul
	addq.w	#1,d1
	bra.s	.nullp
.nulfin	rts
.nul	subq.w	#1,d1
	move.b	d1,(a1)
	rts	


* Function returns the name of a sample in a .MOD module
tracker_inst
	move.l	(sp)+,RETURN
	cmpi	#2,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d0

	add.l	#20,a0
	subq	#1,d0
.tilp	tst	d0
	beq.s	.tifnd
	subq	#1,d0
	add.l	#30,a0
	bra.s	.tilp

.tifnd	lea	track_string,a2
	move.l	a2,a1
	move.w	#22,(a2)+

	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.w	(a0)+,(a2)+

*	bsr	.remnul

	move.b	#$80,d2
	move.l	a1,d3
	clr.l	d4

	move.l	RETURN,a0
	jmp	(a0)

* removes chr(0)'s from a STOS string
* a1=STOS format string
.remnul	move.b	(a1),d0
	moveq.l	#1,d1
.nullp	cmp.w	d1,d0
	bgt	.nulfin
	move.b	0(a1,d1.w),d3
	beq.s	.nul
	addq.w	#1,d1
	bra.s	.nullp
.nulfin	rts
.nul	subq.w	#1,d1
	move.b	d1,(a1)
	rts	


* Instruction sets the dsp processing audio data...

dsp_process
	move.l	(sp)+,RETURN
	cmpi	#3,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d7

	movem.l	(sp)+,d2-d4	get buffer address
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a4

	movem.l	(sp)+,d2-d4	get .LOD filename (STOS format)
	cmpi.b	#$80,d2
	bne	TYPEMIS

	move.b	soundflags,d4
	tst.b	d4
	bne	ntdne

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

	move.l	#availy,-(sp)	; get free DSP memory
	move.l	#availx,-(sp)
	move.w	#106,-(sp)
	trap	#14
	add.l	#10,sp

	move.l	availy,-(sp)	; reserve the DSP memory
	move.l	availx,-(sp)
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
	move.w	freq,-(sp)
	move.w	#0,-(sp)
	move.w	#2,-(sp)
	move.w	#3,-(sp)
	move.w	#139,-(sp)
	trap	#14
	add.l	#12,sp

	move.w	#1,-(sp)	DSP -> DAC
	move.w	freq,-(sp)
	move.w	#0,-(sp)
	move.w	#8,-(sp)
	move.w	#1,-(sp)
	move.w	#139,-(sp)
	trap	#14
	add.l	#12,sp

	move.w	#104,-(sp)	* lock the dsp
	trap	#14
	addq.l	#2,sp

	move.w	#128,-(sp)	* lock sound system
	trap	#14
	addq.l	#2,sp

	move.b	soundflags,d1
	ori.b	#%11,d1
	move.b	d1,soundflags

	bra	dsprocfin

dsprocmd1
	move.w	#1,-(sp)	DMA -> DSP
	move.w	freq,-(sp)
	move.w	#0,-(sp)
	move.w	#2,-(sp)
	move.w	#0,-(sp)
	move.w	#139,-(sp)
	trap	#14
	add.l	#12,sp

	move.w	#1,-(sp)	DSP -> DAC
	move.w	freq,-(sp)
	move.w	#0,-(sp)
	move.w	#8,-(sp)
	move.w	#1,-(sp)
	move.w	#139,-(sp)
	trap	#14
	add.l	#12,sp

	move.b	soundflags,d1
	ori.b	#%1010,d1
	move.b	d1,soundflags

	bra	dsprocfin

dsprocmd2
	move.w	#1,-(sp)	ADC -> DSP
	move.w	freq,-(sp)
	move.w	#0,-(sp)
	move.w	#2,-(sp)
	move.w	#3,-(sp)
	move.w	#139,-(sp)
	trap	#14
	add.l	#12,sp

	move.w	#1,-(sp)	DSP -> DMA
	move.w	freq,-(sp)
	move.w	#0,-(sp)
	move.w	#1,-(sp)
	move.w	#1,-(sp)
	move.w	#139,-(sp)
	trap	#14
	add.l	#12,sp

	move.b	soundflags,d1
	ori.b	#%110,d1
	move.b	d1,soundflags

*	bra.s	dsprocfin
*
*dsprocmd3
*	move.w	#1,-(sp)	DMA -> DSP
*	move.w	freq,-(sp)
*	move.w	#0,-(sp)
*	move.w	#2,-(sp)
*	move.w	#0,-(sp)
*	move.w	#139,-(sp)
*	trap	#14
*	add.l	#12,sp
*
*	move.w	#1,-(sp)	DSP -> DMA
*	move.w	freq,-(sp)
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

	move.l	RETURN,a0
	jmp	(a0)

availy	ds.l	1
availx	ds.l	1


* Instruction resets the audio sub-system (retaining gain/atten)
dsp_clear
	move.l	(sp)+,RETURN
	tst	d0
	bne	SYNTAX

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

	move.w	#105,-(sp)	; unlock the DSP
	trap	#14
	addq.l	#2,sp

	move.w	#129,-(sp)	; unlock the sound sub-system
	trap	#14
	addq.l	#2,sp

	move.b	#0,soundflags	; clear sound-flags
	move.w	#1,freq

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

	move.l	RETURN,a0
	jmp	(a0)


* Instruction sets the frequency of DSP PROCESS / Falc play / Falc sample

falc_freq
	move.l	(sp)+,RETURN
	cmpi	#1,d0
	bne	TYPEMIS

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	SYNTAX
	move.w	d3,freq

	move.l	RETURN,a0
	jmp	(a0)


* Instruction starts a NTK mod on the DSP
ntk_play
	move.l	(sp)+,RETURN
	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS

*	movem.l	a0-a6,-(sp)
*
*	move.l	d3,a0
*
*	lea	freq_buf,a1	;Buffer pour les fr‚quences
*	jsr	ntk_player	;Pof, la routine s'initialise
*
*	move.l	ntk_player+8,a0	;Adresse des variables internes
*	clr.b	song_stop(a0)	;->D‚bloque
*	clr.b	dma2dsp(a0)	;->Transfert par le DMA
*
*	lea	$fffffa01.w,a6	;Installe le TimerD en 50Hz
**	move.b	$16(a6),-(sp)	;MFP en mode AEI
*	bclr	#3,$16(a6)	;
**	move.l	$110.w,-(sp)	;
*
*	move.l	$110.w,nxt_i
*
*	andi.b	#$f0,$1c(a6)	;
*	move.l	#interruption_50Hz,$110.w
*	bset	#4,$8(a6)	;
*	bset	#4,$14(a6)	;
*	move.b	#246,$24(a6)	;~50Hz
*	ori.b	#7,$1c(a6)	;
*	clr.w	$200.w		;
*
**	move.b	#-1,dma2dsp(a0)
*
*	movem.l	(sp)+,a0-a6
*
	move.l	RETURN,a0
	jmp	(a0)

*interruption_50Hz		;comme son nom l'indique
**	bsr	ntk_play+12	;
*	move.l	nxt_i,a0
*	jmp	(a0)
*	rte			;
*
*nxt_i	ds.l	1
*
*interruption_50Hz			;comme son nom l'indique
*	move.w	d0,-(sp)		;
*	move.w	$ffff82a0.w,d0		;
*
*	not.l	v_color030.w	;
*	bsr	ntk_play+12	;
*	not.l	v_color030.w	;
*
*	sub.w	$ffff82a0.w,d0		;Temps machine...
*	neg.w	d0		;
*	cmp.w	$200.w,d0		;
*	ble.s	.0		;
*	move.w	d0,$200.w		;
*
*.0	move.w	(sp)+,d0		;
**	addq.w	#1,count		;
*	rte			;

*count	dc.w	0

* Instruction stops a NTK mod on the DSP
ntk_stop
	move.l	(sp)+,RETURN

	move.l	RETURN,a0
	jmp	(a0)


***********************************
* General stuff (error messages etc)

dummy	move.l	(sp)+,RETURN
	bra	SYNTAX

		
SYNTAX	moveq	#12,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)

TYPEMIS	moveq	#19,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)

ILLEGAL	moveq	#82,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)

ntdne	moveq	#0,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)


	include 'd:\devpac3\sources\load_dt2.s'

even

 TEXT

 Include	'TRACKER.S'

Module		ds.l	1

dspname:	dc.b	'dspmod.bsw',0

dsp_buff	incbin	'digidsp2.out'
dsp_buff_end

ntk_buff	incbin	'ntk_play.bin'
ntk_player	equ	ntk_buff+$1c
 
freq_buf	ds.l	907-108+1

p_end		ds.l	1
pos_ptrs	ds.l	4
player079:      ds.b	11636
SaveArea079:    ds.b	6

* flags showing status of Sound sub-system
* bit 0 = DMA
* bit 1 = DSP
* bit 2 = DSP recording...
* bit 3 = DSP playback...
soundflags	ds.b	1
freq		ds.w	1

 
**************************************************
*
* End of code

	dc.l	0
END