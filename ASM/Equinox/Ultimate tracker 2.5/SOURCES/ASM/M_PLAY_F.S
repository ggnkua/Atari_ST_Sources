
	opt	o+
	
;	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	~~              ProTracker v1.1b Replay routine            ~~
;	~~                  Falcon030 int i7 version               ~~
;	~~  	   Adapted and improved by CHECKSUM/EQUINOX        ~~
;	~~       Based upon a playroutine of Noisetracker 1.0      ~~
;	~~        tab=8; DRI & EXEC assembling possibilities       ~~
;	~~          Bordelis‚e et massacr‚e par Sharp Man          ~~
;	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		xdef	fmt_init,fmt_play,fmt_stop,fmt_rewind,fmt_forward
		xdef	fmt_pause,fmt_freq,fmt_end,fmt_loop,cache_falcon
		xdef	fmt_taille,fmt_songpos,fmt_vum,fmt_rvum
		xdef	fmt_ecran,fmt_raz,fmt_io,fmt_oscil,fmt_off
		xdef	fmt_heure,fmt_minute,fmt_seconde

		output	\utrack25\sources\asm\m_play_f.o

larg		equ	80
nbpts		equ	111
d_timer		equ	50

* ----------------------------------------------------------------------------------
* START MUZAK
* ----------------------------------------------------------------------------------

* Installation routine

fmt_play	movem.l	d0-d7/a0-a6,-(a7)	
		move.w	#0,fmt_end
		bra	init_falcon
s_fmt_play	pea	init_i7
		move.w	#$26,-(a7)
		trap	#14
		addq.l	#6,a7
		bsr.s	mt_setlmc
		movem.l	(a7)+,d0-d7/a0-a6
		rts

* Supervisor installation routine

init_i7		move.w	sr,d0			
		ori.w	#$700,sr		
		move.b	$fffffa03.w,old_a03
		move.b	$fffffa0b.w,old_a0b
		move.b	$fffffa13.w,old_a13
		move.b	$fffffa07.w,old_a07
		btst	#7,$fffffa01.w		
		bne.s	s__1			
		bclr	#7,$fffffa03.w		
		bra.s	s__2			
s__1		bset	#7,$fffffa03.w		
s__2		move.l	$13c.w,old_13c		
		move.l	#mfp_i7,$13c.w		
		bclr	#7,$fffffa0b.w		
		bset	#7,$fffffa13.w		
		bset	#7,$fffffa07.w		
		move.w	d0,sr			
		rts

* Start the music

mt_setlmc:	move.l	mt_buffers,d0
		MOVE.L	#250,D1
		MOVE.W	FREQ,D2
		AND.W	#3,D2
		LSL.W	D2,D1
		ADD.L	D0,D1
		MOVE.L	D1,-(A7)
		MOVE.L	D0,-(A7)
		CLR.W	-(A7)
		MOVE.W	#131,-(A7)
		TRAP	#14
		LEA	12(A7),A7
		MOVE.W	#3,-(A7)
		MOVE.W	#136,-(A7)
		TRAP	#14
		ADDQ.L	#4,A7
		rts

* ----------------------------------------------------------------------------------
* STOP MUZAK
* ----------------------------------------------------------------------------------

fmt_stop	movem.l	d0-d7/a0-a6,-(a7)
		pea	stop_i7
		move.w	#$26,-(a7)
		trap	#14
		addq.l	#6,a7
		move.w	#d_timer,cpt_seconde
                MOVE.W  #$81,-(A7)		
                TRAP    #14
                ADDQ.L  #2,A7 
                PEA     NO_SOUND		
                PEA     NO_SOUND
                CLR.W   -(A7)
                MOVE.W  #$83,-(A7)
                TRAP    #14
                LEA     12(A7),A7
                MOVEM.L   (A7)+,D0-D7/A0-A6
		RTS

stop_i7		move.w	sr,d0
		ori.w	#$700,sr
		move.b	old_a03,$fffffa03.w
		move.b	old_a0b,$fffffa0b.w
		move.b	old_a13,$fffffa13.w
		move.b	old_a07,$fffffa07.w
		move.l	old_13c,$13c.w
		move.w	d0,sr
		rts

NO_SOUND:	DS.L	64		
old_a03:	ds.b	1
old_a0b:	ds.b	1
old_a13:	ds.b	1
old_a07:	ds.b	1

* -----------------------------------------------------------------------------------
* INITIALISE FREQUENCY
* D0 : frequence
* -----------------------------------------------------------------------------------

fmt_freq:	MOVE.W	D0,FREQ
		MOVEM.L	D0-D7/A0-A6,-(A7)
		MOVE.W	D0,-(A7)
		MOVE.W	#6,-(A7)
		MOVE.W	#130,-(A7)
		TRAP	#14
		ADDQ.L	#6,A7
		MOVEM.L	(A7)+,D0-D7/A0-A6
		RTS

FREQ:		DC.W	2

* ----------------------------------------------------------------------------------
* Initialise Falcon
* ----------------------------------------------------------------------------------

init_falcon:	MOVE.W	#$80,-(A7)		* LOCKSOUND
		TRAP	#14
		ADDQ.L	#2,A7
		CMPI.W	#-129,D0
		BEQ	ERR_LOCK
		
          	MOVE.W  #-1,-(A7)		; volume A & B
	        CLR.W   -(A7)
	        MOVE.W  #130,-(A7)
		TRAP  	#14
		ADDQ.L  #6,A7
		MOVE.W  D0,VOL_A
		  
		MOVE.W  #-1,-(A7)
		MOVE.W  #1,-(A7)
		MOVE.W  #130,-(A7)
		TRAP    #14
		ADDQ.L  #6,A7
		MOVE.W  D0,VOL_B

		MOVE.W  #1,-(A7)		; reset sound
		MOVE.W  #140,-(A7)
		TRAP    #14
		ADDQ.L  #4,A7

                MOVE.W  #0,-(A7)		; settracks 0
                MOVE.W  #0,-(A7)
                MOVE.W  #133,-(A7)
                TRAP    #14
                ADDQ.L  #6,A7 
		
		MOVE.W  #%00000010,-(A7)	; adder on matrix
		MOVE.W  #4,-(A7)
		MOVE.W  #130,-(A7)
		TRAP    #14
		ADDQ.L  #6,A7

                MOVE.W  #0,-(A7)		; mode replay
                MOVE.W  #$88,-(A7)		
                TRAP    #$E 
                ADDQ.L  #4,A7 

		MOVE.W	FREQ,-(A7)		; frequency
		MOVE.W	#6,-(A7)
		MOVE.W	#130,-(A7)
		TRAP	#14
		ADDQ.L	#6,A7

                MOVE.W  #1,-(A7)		; no handcheck
                MOVE.W  #0,-(A7)		; division par soundcmd
                MOVE.W  #0,-(A7)		; horloge interne 25 MHz
                MOVE.W  #$C,-(A7) 		; dest HP+DAC
                MOVE.W  #0,-(A7)		; source dmaplay
                MOVE.W  #$8B,-(A7)		; devconnect
                TRAP    #$E 
                LEA     12(A7),A7 

                MOVE.W  #0,-(A7)		; 8 bits stereo
                MOVE.W  #$84,-(A7)		; setmode
                TRAP    #$E 
                ADDQ.L  #4,A7 

		MOVE.W  #1,-(A7)		; type int -> i7
		MOVE.W  #1,-(A7)
		MOVE.W  #135,-(A7)
		TRAP    #14
		ADDQ.L  #6,A7
		  
		MOVE.W  VOL_A,-(A7)		; REPLACE VOLS
		CLR.W	-(A7)
		MOVE.W  #130,-(A7)
		TRAP	#14
		ADDQ.L  #6,A7
		
		MOVE.W  VOL_B,-(A7)
		MOVE.W  #1,-(A7)
		MOVE.W  #130,-(A7)
		TRAP    #14
		ADDQ.L  #6,A7
		bra	s_fmt_play

ERR_LOCK	movem.l	(a7)+,d0-d7/a0-a6
		move.w	#-129,d0
		rts

* ------------------------------------------------------------------------------------
* INIT MUZAK
* A0 = ADDRESS BUFFER
* ------------------------------------------------------------------------------------

fmt_init:	movem.l	d0-d7/a0-a6,-(a7)
		move.l	a0,mt_data
		MOVE.L  950(A0),_pt_fin_mod
		move.b	_pt_fin_mod,fmt_taille
		MOVE.L	#$43C,NB1
		MOVE.L	#$3B8,NB2
		MOVE.W	#$1E,DINO
		CMPI.L	#"M.K.",1080(A0)
		BEQ.S	NEWVERSI
		MOVE.L	#$1D8,NB2
		MOVE.L	#$258,NB1
		MOVE.W	#$E,DINO
NEWVERSI	LEA	(A0),A1
		LEA	(A0),A2
		LEA	42(A0),A0
		ADDA.L	NB1,A1
		ADDA.L	NB2,A2
		MOVE.L  A2,L003D
                SUBQ.L  #2,L003D
                MOVE.L  A2,LFMTFWD
                SUBQ.L  #2,LFMTFWD
		lea	mt_samplestarts,a3
		moveq	#0,d1
		moveq	#0,d2
		moveq	#127,d0
mt_loop1:	move.b	(a2)+,d1
		cmp.w	d1,d2
		bgt.s	mt_loop2
		move.w	d1,d2
mt_loop2:	dbra	d0,mt_loop1
		addq.w	#1,d2
		lsl.l	#8,d2
		lsl.l	#2,d2
		adda.l	d2,a1
		movea.l a1,a4
		move.W	DINO,d0
mt_loop3:	move.l	a1,(a3)+
		moveq	#0,d1
		move.w	(a0),d1
		add.w	d1,d1
		adda.l	d1,a4
		add.l	#1024,d1
		adda.l	d1,a1
		tst.l	4(a0)
		bne.s	mt_test1
		move.l	#1,4(a0)
mt_test1	cmp.l	#1,4(a0)
		bne.s	mt_samplerep
		move.w	(a0),4(a0)
mt_samplerep	lea	30(a0),a0
		dbra	d0,mt_loop3
		move.W	DINO,d0
mt_loop4:	lea	-30(a0),a0
		moveq	#0,d2
		move.w	#(1024/8)-1,d1
mt_loop5:	move.l	d2,-(a1)
		move.l	d2,-(a1)
		dbra	d1,mt_loop5
		move.w	(a0),d1
		bra.s	mt_loop7
mt_loop6:	move.w	-(a4),-(a1)
mt_loop7:	dbra	d1,mt_loop6
		dbra	d0,mt_loop4
		lea	mt_samplestarts,a1
		move.W	DINO,d0
mt_loop8:	movea.l (a1)+,a4
		movea.l a4,a3
		moveq	#0,d1
		move.w	4(a0),d1
		add.w	6(a0),d1
		add.w	d1,d1
		adda.l	d1,a3
		move.w	4(a0),d1
		add.w	d1,d1
		adda.l	d1,a4
		move.w	#1024/2,d1
		divu	6(a0),d1
		bra.s	mt_loop12
mt_loop9:	movea.l a4,a2
		move.w	6(a0),d2
		bra.s	mt_loop11
mt_loop10:	move.w	(a2)+,(a3)+
mt_loop11:	dbra	d2,mt_loop10
mt_loop12:	dbra	d1,mt_loop9
		movea.l a4,a2
		swap	d1
		bra.s	mt_loop14
mt_loop13:	move.w	(a2)+,(a3)+
mt_loop14:	dbra	d1,mt_loop13
		lea	30(a0),a0
		dbra	d0,mt_loop8
		move.l	#mt_voltab,d0
		sf	d0
		add.l	#256,d0
		move.l	d0,mt_voladr
		move.l	d0,a0
		lea	256*65(a0),a0
		moveq	#64,d0
mt_loop15	move.w	#255,d1
mt_loop16	move.w	d1,d2
		ext.w	d2
		muls	d0,d2
		divs	#$80,d2
		move.b	d2,-(a0)
		dbra	d1,mt_loop16
		dbra	d0,mt_loop15

finit2		clr.b	mt_counter
		clr.w	mt_pattpos
		clr.b	fmt_songpos
		clr.b	mt_pattdelay
		move.b	#6,mt_speed
		movem.w	vide,d0-d7/a0-a1
		movem.l	d0-d3,ldff0a0
		movem.l	d0-d3,ldff0b0
		movem.l	d0-d3,ldff0c0
		movem.l	d0-d3,ldff0d0
		move.l	#$10000,d5
		lea	mt_voice1,a2
		movem.l	d0-d7/a0-a1,(a2)
		add.l	d5,d5
		movem.l	d0-d7/a0-a1,40(a2)
		add.l	d5,d5
		movem.l	d0-d7/a0-a1,80(a2)
		add.l	d5,d5
		movem.l	d0-d7/a0-a1,120(a2)
		move.w	d0,ldff0a0+$10
		move.w	d0,ldff0b0+$10
		move.w	d0,ldff0c0+$10
		move.w	d0,ldff0d0+$10
		lea	mt_buffer1,a0
		lea	mt_buffer2,a1
		move.w	#249,d0
mt_clr_buff	move.l	d1,(a0)+
		move.l	d1,(a0)+
		move.l	d1,(a1)+
		move.l	d1,(a1)+
		dbra	d0,mt_clr_buff
		move.l	#mt_buffer1,mt_buffers
		move.l	#mt_buffer2,mt_sharpox
		bsr.s	fmt_io
		bra.s	f_init	

fmt_off		movem.l	d0-d7/a0-a6,-(a7)
		bsr.s	fmt_io
		bsr	fmt_raz
		bra	finit2

* ----------------------------------------------------------------------
* Erase oscillo + vu meter
* ----------------------------------------------------------------------
fmt_io:		movem.l	d0-d7/a0-a6,-(a7)
		lea	cakos,a0
		lea	cakos2,a1
		move.w	#nbpts-1,d0
mt_clr_cak	move.w	#32*larg,(a0)+
		move.w	#32*larg,(a1)+
		dbf	d0,mt_clr_cak

		lea	fmt_ecran,a0
		move.w	#((64*larg)/4)-1,d0
		moveq	#0,d1
mt_clr_ecran	move.l	d1,(a0)+
		dbf	d0,mt_clr_ecran

		lea	fmt_ecran,a0
		lea	12(a0),a0
		move.w	#63,d0
trait		move.w	#1,(a0)
		lea	larg(a0),a0
		dbf	d0,trait
		bsr	fmt_raz

f_init		movem.l	(sp)+,d0-d7/a0-a6
		rts

VOL_A		DS.W	1
VOL_B		DS.W	1
fmt_loop	ds.w	1
fmt_end		ds.w	1
fmt_taille	ds.b	1
		even

NB1		DS.L 1
NB2		DS.L 1
DINO		DS.W 1

* ------------------------------------------------------------------------------------
* REWIND 
* ------------------------------------------------------------------------------------

fmt_rewind:	move.l	d0,-(a7)
		moveq	#0,d0			
		move.b	fmt_songpos,d0
		subq.b	#1,d0
		blt.s	mt_rewind2
		clr.w	mt_pattpos
		clr.b	mt_break
		move.b	d0,fmt_songpos
mt_rewind2:	move.l	(a7)+,d0
		rts
	
* -----------------------------------------------------------------------------------
* FORWARD
* -----------------------------------------------------------------------------------
	
fmt_forward:	move.l	d0,-(a7)
		moveq	#0,d0			
		move.b	fmt_songpos,d0
		addq.b	#1,d0
		andi.b	#$7f,D0
		CMP.B	_pt_fin_mod,D0
LFMTFWD		EQU	*-4
		BEQ.S	mt_forward2
		move.b	d0,fmt_songpos
		clr.w	mt_pattpos
		clr.b	mt_break
mt_forward2:	move.l	(a7)+,d0
		rts

_pt_fin_mod	DS.L	1

* -----------------------------------------------------------------------------------
* PAUSE
* -----------------------------------------------------------------------------------

PAUSE		DC.W	-1

fmt_pause:	movem.l	d0-d7/a0-a6,-(a7)
		tst.w	d0
		beq.s	pause_off
		pea	stop_i7
		move.w	#$26,-(a7)
		trap	#14
		addq.l	#6,a7
		move.w	#0,-(a7)
		move.w	#$88,-(a7)
		trap	#14
		addq.l	#4,a7
fin_pause:	movem.l	(a7)+,d0-d7/a0-a6
		NEG.W	PAUSE
		RTS
		
pause_off:	pea	init_i7
		move.w	#$26,-(a7)
		trap	#14
		addq.l	#6,a7
		move.w	#3,-(a7)
		move.w	#$88,-(a7)
		trap	#14
		addq.l	#4,a7
		bra.s	fin_pause

* -----------------------------------------------------------------------------------
* ROUTINE TIMER
* -----------------------------------------------------------------------------------

xbra		dc.l	'XBRA'
		dc.l	'UTRK'
old_13c		ds.l	1

mfp_i7		move.w	#$2300,sr
		bclr	#7,$FFFFFA0F.W
		tst.w	PAUSE
		BGT.S	f_mfp_i7
		movem.l	d0-D7/A0-a6,-(sp)

* ~~~~~~~~~~~~~~~~~~~~
* Test 50 KHz no cache 
* ~~~~~~~~~~~~~~~~~~~~
 
		cmpi.w	#3,FREQ			* frequence = 50 Khz ?
		bne.s	suite_tf		* non -> suite
		bsr	tc			* teste le cache
		tst.w	rcf			* resultat dans d0 (true/false)
		bne.s	s_mfp_i7		* cache on -> suite

		bclr	#1,$ffff8921.w		* 12 Khz
		bset	#0,$ffff8921.w
		move.w	#1,FREQ
		bra.s	s_mfp_i7
	
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Test 25 KHz no cache + oscillo
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		
suite_tf	cmpi.w	#2,FREQ			* 25 KHz ?
		bne.s	s_mfp_i7		* non -> suite
		move.w	fmt_oscil,d0		* d0=activit‚ oscillo
		add.w	fmt_vum,d0		* + activit‚ vu metre		
		tst.w	d0			* un des 2 actif ?
		beq.s	s_mfp_i7		* non -> suite
		bsr.s	tc			* test cache
		tst.w	rcf			* cache ON ?
		bne.s	s_mfp_i7		* oui -> suite
		move.w	#0,fmt_oscil		* non -> coupe oscillo
		move.w	#0,fmt_vum		* et coupe vu metre

* ~~~~~~~
* Routine
* ~~~~~~~
		
s_mfp_i7	BSR	MT_TA_SETLMC
		bsr	mt_calcvoice
		bsr	mt_music
		bsr.s	calc_duree
		bsr	oscillo
		movem.l	(sp)+,d0-D7/A0-a6
f_mfp_i7	rte

* ----------------
* Test cache 68030
* ----------------

cache_falcon	movem.l	d1-d7/a0-a6,-(a7)
		pea	tc
		move.w	#$26,-(a7)
		trap	#14
		addq.l	#6,a7
		movem.l	(a7)+,d1-d7/a0-a6
		move.w	rcf,d0
		rts

tc		movec	cacr,d0
		btst	#0,d0
		beq.s	tc_false
		btst	#8,d0
		beq.s	tc_false
		move.w	#1,rcf
		rts
tc_false	move.w	#0,rcf
kassetoi	rts
		
rcf		ds.w	1

* ------------------------------------------------------------------------------------
* Calcul duration & return time
* ------------------------------------------------------------------------------------

calc_duree:	subq.w	#1,cpt_seconde
		beq.s	s_calc_duree
		rts

s_calc_duree:	move.w	#d_timer,cpt_seconde
		addq.w	#1,fmt_seconde
		cmp.w	#60,fmt_seconde
		beq.s	reinit_minutes
		rts
reinit_minutes:	move.w	#0,fmt_seconde
		addq.w	#1,fmt_minute
		cmp.w	#60,fmt_minute
		beq.s	reinit_heure
		rts
reinit_heure:	move.w	#0,fmt_minute
		addq.w	#1,fmt_heure
		cmp.w	#24,fmt_heure
		beq.s	reinit_jour
		rts
reinit_jour:	move.w	#0,fmt_heure
		rts

cpt_seconde:	dc.w	d_timer

* ------------------------------------------------------------------------------------
* OSCILLOSCOPE
* Bon je sais, c'est pas tres optimis‚, il ne tient qu'… vous de le faire !!
* ------------------------------------------------------------------------------------

fmt_oscil	dc.w	0
frqtable	dc.w	62*2/nbpts,125*2/nbpts,250*2/nbpts,900*2/nbpts

oscillo:	tst.w	fmt_oscil
		beq.s	kassetoi

		movem.l	d0-d7/a0-a6,-(a7)

		move.l	mt_buffers+4,a0
		move.w	#256,d6
		move.w	FREQ,d0	
		move.w	frqtable(pc,d0*2),d3
		lea	cakos,a1
		lea	cakos2,a2
		lea	tab_y,a3
		lea	fmt_ecran,a4
		lea	14(a4),a5
		move.w	#%1000000000000000,d5

		moveq	#nbpts-1,d7
mt_osci		move.b	(a0)+,d1
		ext.w	d1
		move.b	(a0)+,d0
		ext.w	d0
	
		move.w	(a1),d2
		move.w	(a4,d2),d4
		eor.w	d5,d4
		move.w	d4,(a4,d2)

		neg.w	d1
		add.w	d6,d1
		lsr	#3,d1
		move.w	(a3,d1*2),d2
		move.w	d2,(a1)+
		move.w	(a4,d2),d4
		or.w	d5,d4
		move.w	d4,(a4,d2)

		move.w	(a2),d2
		move.w	(a5,d2),d4
		eor.w	d5,d4
		move.w	d4,(a5,d2)

		neg	d0
		add.w	d6,d0
		lsr	#3,d0
		move.w	(a3,d0*2),d2
		move.w	d2,(a2)+
		move.w	(a5,d2),d4
		or.w	d5,d4
		move.w	d4,(a5,d2)
	
		lsr	#1,d5
		ble.s	nw

		add.w	d3,a0
		dbra	d7,mt_osci	

		movem.l	(a7)+,d0-d7/a0-a6
		rts

nw		move.w	#%1000000000000000,d5
		addq.w	#2,a4
		addq.w	#2,a5
		add.w	d3,a0
		dbf	d7,mt_osci

* --------------------------------------------------------------------------
* Remise … z‚ro de l'oscilloscope
* --------------------------------------------------------------------------

fmt_raz:	movem.l	d0-d7/a0-a6,-(a7)

		lea	cakos,a0
		lea	cakos2,a1
		lea	fmt_ecran,a2
		lea	14(a2),a3
		move.w	#%1000000000000000,d5
		move.w	#larg*32,d6
		move.w	#nbpts-1,d0

eff		move.w	(a0),d1			
		move.w	(a2,d1),d2		
		eor.w	d5,d2			
		move.w	d2,(a2,d1)			
		move.w	d6,(a0)+		
		move.w	(a2,d6),d2		
		or.w	d5,d2			
		move.w	d2,(a2,d6)		

		move.w	(a1),d1
		move.w	(a3,d1),d2
		eor.w	d5,d2
		move.w	d2,(a3,d1)
		move.w	d6,(a1)+
		move.w	(a3,d6),d2
		or.w	d5,d2
		move.w	d2,(a3,d6)

		lsr	#1,d5
		ble.s	nfr
		dbf	d0,eff		
		
		movem.l	(a7)+,d0-d7/a0-a6
		rts
		
nfr		move.w	#%1000000000000000,d5
		addq.w	#2,a3
		addq.w	#2,a2
		dbf	d0,eff

* -----------------
* Variables oscillo
* -----------------
cakos		
		rept	nbpts
		dc.w	32*larg
		endr

cakos2	
		rept	nbpts
		dc.w	32*larg
		endr

i		set	0
tab_y	
		rept	63
		dc.w	i
i		set	i+larg
		endr

* ------------------------------------------------------------------------------------
* VU metre
* ------------------------------------------------------------------------------------

vu_metre:	tst.w	fmt_vum
		beq.s	fin_vu_metre
		bsr.s	Spectrum_Analyse
		bsr	aff_spectrum
fin_vu_metre:	rts

fmt_vum		ds.w	1

* Calcul du spectrum analyser
		
Spectrum_Analyse
		lea	SpectreData+1,a0
		move.l	#$0fff0f00,d0
		moveq	#0,d2

		move.l	mt_voice1,d1
		bsr.s	FrqAnalyse
		move.l	mt_voice2,d1
		bsr.s	FrqAnalyse
		move.l	mt_voice3,d1
		bsr.s	FrqAnalyse
		move.l	mt_voice4,d1
		bsr.s	FrqAnalyse
		rts

FrqAnalyse
		and.l	d0,d1
		cmp.w	#$0300,d1
		beq.s	.NoSpectrum
		clr.w	d1
		swap	d1
		tst.w	d1
		beq.s	.NoSpectrum
		sub.w	#$70,d1
		cmp.w	#$358-$71+1,d1
		bgt.s	.NoSpectrum
		divu	#34,d1
		neg.w	d1
		add.w	#21,d1

		move.b	(a0,d1.w),d2
		and.b	#$7f,d2
		add.b	#32,d2
		cmp.b	#48,d2
		bmi.s	.Spectre
		moveq	#48,d2
.Spectre
		or.b	#$80,d2
		move.b	d2,(a0,d1.w)
		move.b	-1(a0,d1.w),d2
		and.b	#$7f,d2
		add.b	#14,d2
		cmp.b	#48,d2
		bmi.s	.LeftSpectre
		moveq	#48,d2
.LeftSpectre
		or.b	#$80,d2
		move.b	d2,-1(a0,d1.w)
		move.b	1(a0,d1.w),d2
		and.b	#$7f,d2
		add.b	#14,d2
		cmp.b	#48,d2
		bmi.s	.RightSpectre
		moveq	#48,d2
.RightSpectre
		or.b	#$80,d2
		move.b	d2,1(a0,d1.w)

.NoSpectrum
		rts

* Affichage spectrum

aff_spectrum
		lea	fmt_ecran,a6
		lea	(48*80)+40(a6),a5
		lea	SpectreData+1,a0
		moveq	#21,d7
.SpectrumDisplay
		moveq	#0,d0
		move.b	(a0),d0
		beq.s	.NoSpectrumDisplay
		bsr.s	HighDisplay
.NoSpectrumDisplay
		addq.w	#1,a0
		dbra	d7,.SpectrumDisplay
		rts

HighDisplay
		btst	#7,d0
		bne.s	HighPrintSpectre
		subq.b	#2,(a0)
		moveq	#21,d2
		sub.w	d7,d2
		lea	(a5,d2),a4
		lsl.w	#4,d0
		sub.w	d0,a4
		add.w	d0,d0
		add.w	d0,d0
		sub.w	d0,a4
		moveq	#0,d0
		move.b	d0,80(a4)
		move.b	d0,160(a4)
		rts	
HighPrintSpectre
		and.b	#$7f,d0
		move.b	d0,(a0)
		moveq	#48,d1
		sub.w	d0,d1
		subq.w	#1,d0
		moveq	#21,d2
		sub.w	d7,d2
		lea	(a5,d2),a4
		
		move.l	#%11111110,d2
zaza		move.b	d2,(a4)
		lea	-80(a4),a4
		dbf	d0,zaza
		rts	

* clear vu metre


fmt_rvum	movem.l	d0-d6/a0,-(a7)
		lea	fmt_ecran,a0
		lea	40(a0),a0
		movem.l	NO_SOUND,d1-d6
		move.w	#50,d0
bcl_rvum	movem.l	d1-d6,(a0)
		lea	80(a0),a0
		dbf	d0,bcl_rvum
		movem.l	(a7)+,d0-d6/a0
		rts

* ------------------------------------------------------------------------------------
* NOUVELLE ROUTINE DE PLAY
* ------------------------------------------------------------------------------------

MT_TA_SETLMC:	move.l	mt_sharpox,d0
		MOVE.L	#250,D1
		MOVE.W	FREQ,D2
		AND.W	#3,D2
		LSL.W	D2,D1
		ADD.L	D0,D1
		
                BCLR	#7,$FFFF8901.W
		MOVEQ	#0,D2
		LEA	TAMP,A0
		MOVE.L  D0,(A0)

		move.b	3(a0),$ffff8907.w
		move.b	2(a0),$ffff8905.w
		move.b	1(a0),$ffff8903.w
		move.l	d1,(a0)
		move.b	3(a0),$ffff8913.w
		move.b	2(a0),$ffff8911.w
		move.b	1(a0),$ffff890f.w
		
		BCLR	#7,$FFFF8901.W
		BSET	#0,$FFFF8901.W
		BSET	#1,$FFFF8901.W	
	
		RTS

TAMP		DS.L	1

* ------------------------------------------------------------------------------------

mt_calcvoice	lea	ldff0a0,a0
		lea	mt_buff1,a1
		bsr.s	mt_one_voice
		lea	ldff0b0,a0
		lea	mt_buff2,a1
		bsr.s	mt_one_voice
		lea	ldff0c0,a0
		lea	mt_buff3,a1
		bsr.s	mt_one_voice
		lea	ldff0d0,a0
		lea	mt_buff4,a1
		bsr.s	mt_one_voice
		bsr	mt_mixe_ste
fin_calcvoice	rts

mt_one_voice	move.l	(a0),d1			
		andi.l	#$00ffffff,d1
		move.l	d1,a2
		moveq	#0,d1
		move.l	#$11a*2,d3
		move.w	6(a0),d2
		beq.s	mt_div0
		divu	d2,d3
		move.w	d3,d1
		move.w	#$3989*2,d3
		divu	d2,d3
		swap	d1
		move.w	d3,d1
		move.b	$ff8921,d2
		and.w	#3,d2
		lsr.l	d2,d1
		swap	d1
mt_div0		moveq	#0,d2
		move.b	9(a0),d2
		cmp.w	#$40,d2
		ble.s	mt_vol_in_range
		moveq	#$40,d2
mt_vol_in_range	lsl.w	#8,d2
		add.l	mt_voladr,d2
		moveq	#0,d0
		move.b	$a(a0),d0
		lsl.w	#8,d0
		move.b	(a0),d0
		swap	d0
		moveq	#1,d3
		move.w	FREQ,d4
		and.w	#3,d4
		lsl.w	d4,d3
		subq.w	#1,d3
		move.w	$10(a0),d4
		move.b	d4,ccr
mt_calc_one	move.w	#124,d7
mt_zloop1	
		move.b	(a2,d0.w),d2
		move.l	d2,a3
		move.b	(a3),(a1)+
		addx.l	d1,d0
		dbf	d7,mt_zloop1
		dbra	d3,mt_calc_one
		move.w	sr,$10(a0)
		swap	d0
		move.b	d0,(a0)
		lsr.w	#8,d0
		move.b	d0,$a(a0)
		clr.w	d0
		swap	d0
		add.l	d0,(a0)
		sub.w	d0,4(a0)
		bcc.s	no_sample_end
		moveq	#0,d0
		moveq	#0,d1
		move.w	4(a0),d0
		neg.w	d0
		move.b	(a0),d4
		move.l	$a(a0),(a0)
		move.b	d4,(a0)
		move.w	$e(a0),d1
		add.w	d1,d1
		divu	d1,d0
		clr.w	d0
		swap	d0
		add.l	d0,(a0)
		sub.w	d0,d1
		move.w	d1,4(a0)
no_sample_end	rts

mt_mixe_ste	lea	mt_buff1,a0
		lea	mt_buff4,a1
		lea	mt_buff2,a2
		lea	mt_buff3,a3
		movem.l	mt_buffers,d0-d1
		exg	d0,d1
		movem.l	d0-d1,mt_buffers
		move.l	d0,a4
		moveq	#0,d0
		moveq	#1,d1
		move.w	FREQ,d2
		and.w	#3,d2
		lsl.w	d2,d1
		subq.w	#1,d1
mt_mixe		move.w	#31,d7
mt_zloop2	move.l	(a0)+,d0
		add.l	(a1)+,d0
		movep.l	d0,(a4)
		move.l	(a2)+,d0
		add.l	(a3)+,d0
		movep.l	d0,1(a4)
		addq.w	#8,a4
		dbf	d7,mt_zloop2
		dbra	d1,mt_mixe
		rts

* --------------------------------------------------------------------------------

mt_music:	movem.l d0-a6,-(sp)
		addq.b	#$01,mt_counter
		move.b	mt_counter,d0
		cmp.b	mt_speed,d0
		blt.s	mt_nonew
		clr.b	mt_counter
		tst.b	mt_pattdelay
		beq	mt_getnew
		subq.b	#1,mt_pattdelay
		bne.s	mt_nonew
		bra	mt_getnew
mt_nonew:	lea	mt_voice1,a6
		lea	ldff0a0,a5
		bsr	mt_checkcom
		lea	mt_voice2,a6
		lea	ldff0b0,a5
		bsr	mt_checkcom
		lea	mt_voice3,a6
		lea	ldff0c0,a5
		bsr	mt_checkcom
		lea	mt_voice4,a6
		lea	ldff0d0,a5
		bsr	mt_checkcom
		bsr	vu_metre
		bra	mt_endr

mt_arpeggio:	moveq	#0,d0
		move.b	mt_counter,d0
		divs	#$03,d0
		swap	d0
		cmp.w	#$00,d0
		beq.s	mt_arp2
		cmp.w	#$02,d0
		beq.s	mt_arp1
		moveq	#0,d0
		move.b	$03(a6),d0
		lsr.b	#4,d0
		bra.s	mt_arp3
mt_arp1:	moveq	#0,d0
		move.b	$03(a6),d0
		and.b	#$0f,d0
		bra.s	mt_arp3
mt_arp2:	move.w	$10(a6),d2
		bra.s	mt_arp4
mt_arp3:	add.w	d0,d0
		moveq	#0,d1
		move.w	$10(a6),d1
		lea	mt_periods,a0
		moveq	#0,d7
		move.b	$12(a6),d7
		mulu	#$4a,d7
		adda.l	d7,a0
		moveq	#$24,d7

mt_arploop:	move.w	0(a0,d0.w),d2
		cmp.w	(a0),d1
		bge.s	mt_arp4
		addq.l	#2,a0
		dbra	d7,mt_arploop
		rts
mt_arp4:	move.w	d2,$06(a5)
		rts

mt_getnew:	move.l	mt_data,a0
		movea.l a0,a3
		movea.l a0,a2
		adda.w	#$0c,a3
		adda.L	NB2,a2
		adda.L	NB1,a0
		moveq	#0,d0
		move.l	d0,d1
		move.b	fmt_songpos,d0
		move.b	0(a2,d0.w),d1
		asl.l	#8,d1
		asl.l	#2,d1
		move.w	mt_pattpos,d0
		add.l	d0,d1
		clr.w	mt_dmacon
		lea	ldff0a0,a5
		lea	mt_voice1,a6
		bsr.s	mt_playvoice
		addq.l	#4,d1
		lea	ldff0b0,a5
		lea	mt_voice2,a6
		bsr.s	mt_playvoice
		addq.l	#4,d1
		lea	ldff0c0,a5
		lea	mt_voice3,a6
		bsr.s	mt_playvoice
		addq.l	#4,d1
		lea	ldff0d0,a5
		lea	mt_voice4,a6
		bsr.s	mt_playvoice
		bra	mt_setdma

mt_playvoice:	move.l	(a0,d1.l),(a6)
		moveq	#0,d2
		move.b	$02(a6),d2
		and.b	#$f0,d2
		lsr.b	#4,d2
		move.b	(a6),d0
		and.b	#$f0,d0
		or.b	d0,d2
		tst.b	d2
		beq.s	mt_setregs
		moveq	#0,d3
		lea	mt_samplestarts,a1
		move.l	d2,d4
		subq.l	#1,d2
		asl.l	#2,d2
		mulu	#$1e,d4
		move.l	0(a1,d2.l),$04(a6)
		move.w	0(a3,d4.l),$08(a6)
		move.w	$02(a3,d4.l),$12(a6)
		move.w	$04(a3,d4.l),d3
		beq.s	mt_noloop
		move.l	4(a6),d2
		add.w	d3,d3
		add.l	d3,d2
		move.l	d2,$a(a6)
		move.w	4(a3,d4.l),d0
		add.w	6(a3,d4.l),d0
		move.w	d0,8(a6)
		move.w	6(a3,d4.l),$e(a6)
		move.b	$13(a6),$09(a5)
		move.l	$0a(a6),$0a(a5)
		move.w	$0e(a6),$0e(a5)
		bra.s	mt_setregs
mt_noloop:	move.l	$04(a6),$0a(a6)
		move.w	$06(a3,d4.l),$0e(a6)
		move.b	$13(a6),$09(a5)
		move.l	$0a(a6),$0a(a5)
		move.w	$0e(a6),$0e(a5)

mt_setregs:	move.w	(a6),d0
		and.w	#$0fff,d0
		beq	mt_checkcom2
		lea	mt_periods,a4
		moveq	#36,d2
mt_finetune:	cmp.w	(a4)+,d0
		dbcc	d2,mt_finetune
mt_found:	moveq	#0,d0
		move.b	$12(a6),d0
		mulu	#74,d0
		move.w	-2(a4,d0.w),d2
		move.b	$02(a6),d0
		and.b	#$0f,d0
		cmp.b	#$03,d0
		beq	mt_setmyport
		cmp.b	#$05,d0
		beq	mt_setmyport
		move.w	d2,$10(a6)
		cmp.b	#$08,d0
		beq	mt_phasing
		cmp.b	#$09,d0
		beq	mt_sampleoffset
mt_setregs2:	move.w	$14(a6),d0
		btst	#2,$1e(a6)
		bne.s	mt_noclrvib
		clr.b	$1b(a6)
mt_noclrvib:	btst	#6,$1e(a6)
		bne.s	mt_noclrtrem
		clr.b	$1d(a6)
mt_noclrtrem:	move.l	$04(a6),(a5)
		move.w	$08(a6),d0
		add.w	d0,d0
		move.w	d0,$04(a5)
		move.w	$10(a6),6(a5)
		move.w	$14(a6),d0
		or.w	d0,mt_dmacon
		bra	mt_checkcom2

mt_setdma:	addi.w	#$10,mt_pattpos
		cmpi.w	#$0400,mt_pattpos
		bne.s	mt_endr

mt_nex: 	clr.w	mt_pattpos
		clr.b	mt_break
		addq.b	#1,fmt_songpos
		andi.b	#$7f,fmt_songpos
		move.b	fmt_songpos,d1
		CMP.B	_pt_fin_mod,D1
L003D		EQU	*-4
		BNE.S	mt_endr
		tst.w	fmt_loop
		beq.s	no_boucle
		clr.b	fmt_songpos
mt_endr:	moveq	#0,d0
		tst.b	mt_break
		bne.s	mt_nex
		movem.l (sp)+,d0-a6
		rts

no_boucle:	bsr	fmt_stop
		move.w	#1,fmt_end
		movem.l	(sp)+,d0-a6
		rts

mt_setmyport:	move.w	d2,$18(a6)
		move.w	$10(a6),d0
		clr.b	$16(a6)
		cmp.w	d0,d2
		beq.s	mt_clrport
		bge.s	mt_rt
		move.b	#$01,$16(a6)
		bra	mt_checkcom2

mt_clrport:	clr.w	$18(a6)
mt_rt:		bra	mt_checkcom2

mt_myport:	move.b	$03(a6),d0
		beq.s	mt_myslide
		move.b	d0,$17(a6)
		clr.b	$03(a6)

mt_myslide:	tst.w	$18(a6)
		beq.s	mt_rt
		moveq	#0,d0
		move.b	$17(a6),d0
		tst.b	$16(a6)
		bne.s	mt_mysub
		add.w	d0,$10(a6)
		move.w	$18(a6),d0
		cmp.w	$10(a6),d0
		bgt.s	mt_myok
		move.w	$18(a6),$10(a6)
		clr.w	$18(a6)
		bra.s	mt_myok

mt_mysub:	sub.w	d0,$10(a6)
		move.w	$18(a6),d0
		cmp.w	$10(a6),d0
		blt.s	mt_myok
		move.w	$18(a6),$10(a6)
		clr.w	$18(a6)

mt_myok:	move.w	$10(a6),d2
		move.b	$1f(a6),d0
		and.b	#$0f,d0
		beq.s	mt_portnorm
		moveq	#0,d0
		move.b	$12(a6),d0
		mulu	#$4a,d0
		lea	mt_periods,a0
		adda.w	d0,a0
		moveq	#45,d0
mt_fineport:	cmp.w	(a0)+,d2
		dbcc	d0,mt_fineport
		move.w	-2(a0),d2
mt_portnorm:	move.w	d2,6(a5)
		rts

mt_vib: 	move.b	$03(a6),d0
		beq.s	mt_vi
		move.b	$1a(a6),d2
		and.b	#$0f,d0
		beq.s	mt_novibampl
		and.b	#$f0,d2
		or.b	d0,d2
mt_novibampl:	move.b	3(a6),d0
		and.b	#$f0,d0
		beq.s	mt_novibspeed
		and.b	#$0f,d2
		or.b	d0,d2
mt_novibspeed:	move.b	d2,$1a(a6)
mt_vi:		move.b	$1b(a6),d0
		lea	mt_sin,a4
		lsr.w	#2,d0
		and.w	#$1f,d0
		moveq	#0,d2
		move.b	$1e(a6),d2
		and.b	#3,d2
		beq.s	mt_dosinus
		lsl.b	#3,d0
		cmp.b	#1,d2
		beq.s	mt_scie
		move.b	#$ff,d2
		bra.s	mt_dovib
mt_scie:	tst.b	$1b(a6)
		bpl.s	mt_noinitscie
		move.b	#$ff,d2
		sub.b	d0,d2
		bra.s	mt_dovib
mt_noinitscie:	move.b	d0,d2
		bra.s	mt_dovib
mt_dosinus:	move.b	0(a4,d0.w),d2
mt_dovib:	move.b	$1a(a6),d0
		and.w	#$0f,d0
		mulu	d0,d2
		lsr.w	#7,d2
		move.w	$10(a6),d0
		tst.b	$1b(a6)
		bmi.s	mt_vibmin
		add.w	d2,d0
		bra.s	mt_vib2
mt_vibmin:	sub.w	d2,d0
mt_vib2:	move.w	d0,$06(a5)
		move.b	$1a(a6),d0
		lsr.w	#$02,d0
		and.w	#$3c,d0
		add.b	d0,$1b(a6)
		rts

mt_tremolo:	move.b	$03(a6),d0
		beq.s	mt_trem
		move.b	$1c(a6),d2
		and.b	#$0f,d0
		beq.s	mt_notreampl
		and.b	#$f0,d2
		or.b	d0,d2
mt_notreampl:	move.b	3(a6),d0
		and.b	#$f0,d0
		beq.s	mt_notrespeed
		and.b	#$0f,d2
		or.b	d0,d2
mt_notrespeed:	move.b	d2,$1c(a6)
mt_trem:	move.b	$1d(a6),d0
		lea	mt_sin,a4
		lsr.w	#2,d0
		and.w	#$1f,d0
		moveq	#0,d2
		move.b	$1e(a6),d2
		lsr.b	#4,d2
		and.b	#3,d2
		beq.s	mt_dosinus2
		lsl.b	#3,d0
		cmp.b	#1,d2
		beq.s	mt_scie2
		move.b	#$ff,d2
		bra.s	mt_dotrem
mt_scie2:	tst.b	$1d(a6)
		bpl.s	mt_noinitscie2
		move.b	#$ff,d2
		sub.b	d0,d2
		bra.s	mt_dotrem
mt_noinitscie2: move.b	d0,d2
		bra.s	mt_dotrem
mt_dosinus2:	move.b	0(a4,d0.w),d2
mt_dotrem:	move.b	$1c(a6),d0
		and.w	#$0f,d0
		mulu	d0,d2
		lsr.w	#$06,d2
		moveq	#0,d0
		move.b	$13(a6),d0
		tst.b	$1d(a6)
		bmi.s	mt_tremin
		add.w	d2,d0
		bra.s	mt_trem2
mt_tremin:	sub.w	d2,d0
		bcc.s	mt_trem2
		moveq	#0,d0
mt_trem2:	cmp.w	#$40,d0
		ble.s	mt_trem3
		moveq	#$40,d0
mt_trem3:	move.w	d0,$08(a5)
		move.b	$1c(a6),d0
		lsr.w	#$02,d0
		and.w	#$3c,d0
		add.b	d0,$1d(a6)
		rts

mt_nop: 	move.w	$10(a6),$06(a5)
		rts

mt_checkcom:	move.w	$02(a6),d0
		and.w	#$0fff,d0
		beq.s	mt_nop
		move.b	$02(a6),d0
		and.b	#$0f,d0
		beq	mt_arpeggio
		cmp.b	#$01,d0
		beq	mt_portup
		cmp.b	#$02,d0
		beq	mt_portdown
		cmp.b	#$03,d0
		beq	mt_myport
		cmp.b	#$04,d0
		beq	mt_vib
		cmp.b	#$05,d0
		beq.s	mt_volport
		cmp.b	#$06,d0
		beq.s	mt_volvib
		cmp.b	#$0e,d0
		beq	mt_ext_com
		move.w	$10(a6),$06(a5)
		cmp.b	#$07,d0
		beq	mt_tremolo
		cmp.b	#$0a,d0
		beq.s	mt_volslide
		rts

mt_phasing:	moveq	#0,d0
		move.b	3(a6),d0
		add.l	d0,4(a6)
		add.w	d0,d0
		sub.w	d0,8(a6)
		bcs.s	mt_offsetmax
		bra	mt_setregs2

mt_sampleoffset:moveq	#0,d0
		move.b	3(a6),d0
		beq.s	mt_no_offset
		move.b	d0,$20(a6)
mt_no_offset:	move.b	$20(a6),d0
		lsl.w	#7,d0
		cmp.w	8(a6),d0
		bge.s	mt_offsetmax
		sub.w	d0,8(a6)
		add.w	d0,d0
		add.l	d0,4(a6)
		bra	mt_setregs2
mt_offsetmax:	move.l	$a(a6),4(a6)
		move.w	$e(a6),8(a6)
		bra	mt_setregs2

mt_volvib:	bsr	mt_vi
		bra.s	mt_volslide

mt_volport:	bsr	mt_myslide
		bra.s	mt_volslide

mt_fine_vol_up:	move.b	$03(a6),d0
		and.b	#$0f,d0
		bra.s	mt_dovolup

mt_volslide:	move.b	$03(a6),d0
		lsr.b	#4,d0
		beq.s	mt_voldown
mt_dovolup:	add.b	d0,$13(a6)
		cmpi.b	#$40,$13(a6)
		bcs.s	mt_vol2
		move.b	#$40,$13(a6)
mt_vol2:	move.b	$13(a6),$09(a5)
		rts

mt_voldown:	move.b	$03(a6),d0
		and.b	#$0f,d0
		sub.b	d0,$13(a6)
		bcc.s	mt_vol3
		clr.b	$13(a6)
mt_vol3:	move.b	$13(a6),$09(a5)
		rts

mt_fine_portup:	move.b	$03(a6),d0
		and.w	#$0f,d0
		bra.s	mt_doportup

mt_portup:	moveq	#0,d0
		move.b	$03(a6),d0
mt_doportup:	sub.w	d0,$10(a6)
		move.w	$10(a6),d0
		and.w	#$0fff,d0
		cmp.w	#$71,d0
		bpl.s	mt_por2
		andi.w	#$f000,$10(a6)
		ori.w	#$71,$10(a6)
mt_por2:	move.w	$10(a6),d0
		and.w	#$0fff,d0
		move.w	d0,$06(a5)
		rts

mt_fine_portdwn:
		move.b	3(a6),d0
		and.w	#$0f,d0
		bra.s	mt_doportdwn

mt_portdown:	clr.w	d0
		move.b	$03(a6),d0
mt_doportdwn:	add.w	d0,$10(a6)
		move.w	$10(a6),d0
		and.w	#$0fff,d0
		cmp.w	#$0358,d0
		bmi.s	mt_por3
		andi.w	#$f000,$10(a6)
		ori.w	#$0358,$10(a6)
mt_por3:	move.w	$10(a6),d0
		and.w	#$0fff,d0
		move.w	d0,$06(a5)
		rts

mt_checkcom2:	move.b	$02(a6),d0
		and.b	#$0f,d0
		cmp.b	#$0e,d0
		beq.s	mt_ext_com
		cmp.b	#$0d,d0
		beq.s	mt_pattbreak
		cmp.b	#$0b,d0
		beq.s	mt_posjmp
		cmp.b	#$0c,d0
		beq.s	mt_setvol
		cmp.b	#$0f,d0
		beq.s	mt_setspeed
		rts

mt_setfilt:	move.b	$03(a6),d0
		and.b	#$01,d0
		rts

mt_pattbreak:	not.b	mt_break
		rts

mt_posjmp:	move.b	$03(a6),d0
		subq.b	#$01,d0
		move.b	d0,fmt_songpos
		not.b	mt_break
		rts

mt_setvol:	moveq	#0,d0
		move.b	$03(a6),d0
		cmp.w	#$40,d0
		ble.s	mt_vol4
		move.b	#$40,$03(a6)
mt_vol4:	move.b	$03(a6),$09(a5)
		move.b	$03(a6),$13(a6)
		rts

mt_setspeed:	moveq	#0,d0
		move.b	$03(a6),d0
		cmp.w	#$20,d0
		bge.s	mt_rts2
		clr.b	mt_counter
		move.b	d0,mt_speed
mt_rts2:	rts

mt_ext_com:	move.b	3(a6),d0
		lsr.b	#4,d0
		beq.s	mt_setfilt
		tst.b	mt_counter
		bne.s	mt_res_com
		cmp.b	#1,d0
		beq	mt_fine_portup
		cmp.b	#2,d0
		beq	mt_fine_portdwn
		cmp.b	#3,d0
		beq.s	mt_setportctrl
		cmp.b	#4,d0
		beq.s	mt_setvibform
		cmp.b	#5,d0
		beq.s	mt_setfinetune
		cmp.b	#6,d0
		beq.s	mt_pattern_loop
		cmp.b	#7,d0
		beq	mt_settremform
		cmp.b	#8,d0
		beq	mt_stop_seq
		cmp.b	#$0a,d0
		beq	mt_fine_vol_up
		cmp.b	#$0b,d0
		beq	mt_voldown
		cmp.b	#$0e,d0
		beq	mt_pattern_delay
mt_res_com:	cmp.b	#$09,d0
		beq	mt_roll
		cmp.b	#$0c,d0
		beq	mt_notecut
		cmp.b	#$0d,d0
		beq	mt_notedelay
		rts

mt_setportctrl:	move.b	3(a6),d0
		and.b	#$0f,d0
		andi.b	#$f0,$1f(a6)
		or.b	d0,$1f(a6)
		rts

mt_setvibform:	move.b	3(a6),d0
		and.b	#$0f,d0
		andi.b	#$f0,$1e(a6)
		or.b	d0,$1e(a6)
		rts

mt_setfinetune:	move.b	3(a6),d0
		and.b	#$0f,d0
		move.b	d0,$12(a6)
		rts

mt_pattern_loop:move.b	3(a6),d0
		and.b	#$0f,d0
		beq.s	mt_setloopstart
		tst.b	$22(a6)
		beq.s	mt_setnumloop
		subq.b	#1,$22(a6)
		beq	mt_rts2
mt_doloop:	moveq	#0,d0
		move.b	$21(a6),d0
		ext.w	d0
		lsl.w	#4,d0
		move.w	d0,mt_pattpos
		rts
mt_setnumloop:	move.b	d0,$22(a6)
		bra.s	mt_doloop
mt_setloopstart:move.w	mt_pattpos,d0
		lsr.w	#4,d0
		subq.b	#1,d0
		move.b	d0,$21(a6)
		rts

mt_settremform:	move.b	3(a6),d0
		lsl.b	#4,d0
		andi.b	#$0f,$1e(a6)
		or.b	d0,$1e(a6)
		rts

mt_notecut:	move.b	$03(a6),d0
		and.b	#$0f,d0
		cmp.b	mt_counter,d0
		bne	mt_rts2
		clr.b	$13(a6)
		clr.w	$08(a5)
		rts

mt_notedelay:	tst.b	mt_counter
		bne.s	mt_waitdelay
		clr.w	6(a5)

mt_waitdelay:	move.b	$03(a6),d0
		and.b	#$0f,d0
		cmp.b	mt_counter,d0
		bne	mt_rts2
		move.w	$10(a6),6(a5)
		rts

mt_pattern_delay:
		tst.b	mt_pattdelay
		bne	mt_rts2
		move.b	$03(a6),d0
		and.b	#$0f,d0
		move.b	d0,mt_pattdelay
		rts

mt_roll:	move.l	d1,-(sp)
		moveq	#0,d0
		move.b	3(a6),d0
		and.b	#$0f,d0
		beq.s	mt_roll_ret
		moveq	#0,d1
		move.b	mt_counter,d1
		divu	d0,d1
		swap	d1
		tst.w	d1
		bne.s	mt_roll_ret
		move.l	4(a6),(a5)
		move.w	8(a6),d0
		add.w	d0,d0
		move.w	d0,4(a5)
		move.l	$10(a6),6(a5)
		move.b	$13(a6),9(a5)
mt_roll_ret:	move.l	(sp)+,d1
		rts

mt_stop_seq:	rts

		Section	DATA

mt_sin: 	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
		dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods:	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0,$01c5
		dc.w $01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$fe,$f0,$e2,$d6,$ca,$be,$b4
		dc.w $aa,$a0,$97,$8f,$87,$7f,$78,$71,0
		dc.w $0352,$0322,$02f5,$02cb,$02a2,$027d,$0259,$0237,$0217,$01f9,$01dd
		dc.w $01c2,$01a9,$0191,$017b,$0165,$0151,$013e,$012c,$011c,$010c,$fd,$ef
		dc.w $e1,$d5,$c9,$bd,$b3,$a9,$9f,$96,$8e,$86,$7e,$77,$71,0
		dc.w $034c,$031c,$02f0,$02c5,$029e,$0278,$0255,$0233,$0214,$01f6,$01da,$01bf,$01a6,$018e
		dc.w $0178,$0163,$014f,$013c,$012a,$011a,$010a,$fb,$ed,$e0,$d3,$c7,$bc,$b1,$a7,$9e
		dc.w $95,$8d,$85,$7d,$76,$70,0
		dc.w $0346,$0317,$02ea,$02c0,$0299,$0274,$0250,$022f,$0210,$01f2,$01d6,$01bc,$01a3
		dc.w $018b,$0175,$0160,$014c,$013a,$0128,$0118,$0108,$f9,$eb,$de,$d1,$c6,$bb,$b0,$a6
		dc.w $9d,$94,$8c,$84,$7d,$76,$6f,0
		dc.w $0340,$0311,$02e5,$02bb,$0294,$026f,$024c,$022b,$020c,$01ef,$01d3,$01b9
		dc.w $01a0,$0188,$0172,$015e,$014a,$0138,$0126,$0116,$0106,$f7,$e9,$dc,$d0,$c4,$b9,$af
		dc.w $a5,$9c,$93,$8b,$83,$7c,$75,$6e,0
		dc.w $033a,$030b,$02e0
		dc.w $02b6,$028f,$026b,$0248
		dc.w $0227,$0208,$01eb,$01cf
		dc.w $01b5,$019d,$0186,$0170
		dc.w $015b,$0148,$0135,$0124
		dc.w $0114,$0104,$f5,$e8
		dc.w $db,$ce,$c3,$b8
		dc.w $ae,$a4,$9b,$92
		dc.w $8a,$82,$7b,$74
		dc.w $6d,0,$0334,$0306
		dc.w $02da,$02b1,$028b,$0266
		dc.w $0244,$0223,$0204,$01e7
		dc.w $01cc,$01b2,$019a,$0183
		dc.w $016d,$0159,$0145,$0133
		dc.w $0122,$0112,$0102,$f4
		dc.w $e6,$d9,$cd,$c1
		dc.w $b7,$ac,$a3,$9a
		dc.w $91,$89,$81,$7a
		dc.w $73,$6d,0,$032e
		dc.w $0300,$02d5,$02ac,$0286
		dc.w $0262,$023f,$021f,$0201
		dc.w $01e4,$01c9,$01af,$0197
		dc.w $0180,$016b,$0156,$0143
		dc.w $0131,$0120,$0110,$0100
		dc.w $f2,$e4,$d8,$cc
		dc.w $c0,$b5,$ab,$a1
		dc.w $98,$90,$88,$80
		dc.w $79,$72,$6c,0
		dc.w $038b,$0358,$0328,$02fa
		dc.w $02d0,$02a6,$0280,$025c
		dc.w $023a,$021a,$01fc,$01e0
		dc.w $01c5,$01ac,$0194,$017d
		dc.w $0168,$0153,$0140,$012e
		dc.w $011d,$010d,$fe,$f0
		dc.w $e2,$d6,$ca,$be
		dc.w $b4,$aa,$a0,$97
		dc.w $8f,$87,$7f,$78
		dc.w 0,$0384,$0352,$0322
		dc.w $02f5,$02cb,$02a3,$027c
		dc.w $0259,$0237,$0217,$01f9
		dc.w $01dd,$01c2,$01a9,$0191
		dc.w $017b,$0165,$0151,$013e
		dc.w $012c,$011c,$010c,$fd
		dc.w $ee,$e1,$d4,$c8
		dc.w $bd,$b3,$a9,$9f
		dc.w $96,$8e,$86,$7e
		dc.w $77,0,$037e,$034c
		dc.w $031c,$02f0,$02c5,$029e
		dc.w $0278,$0255,$0233,$0214
		dc.w $01f6,$01da,$01bf,$01a6
		dc.w $018e,$0178,$0163,$014f
		dc.w $013c,$012a,$011a,$010a
		dc.w $fb,$ed,$df,$d3
		dc.w $c7,$bc,$b1,$a7
		dc.w $9e,$95,$8d,$85
		dc.w $7d,$76,0,$0377
		dc.w $0346,$0317,$02ea,$02c0
		dc.w $0299,$0274,$0250,$022f
		dc.w $0210,$01f2,$01d6,$01bc
		dc.w $01a3,$018b,$0175,$0160
		dc.w $014c,$013a,$0128,$0118
		dc.w $0108,$f9,$eb,$de
		dc.w $d1,$c6,$bb,$b0
		dc.w $a6,$9d,$94,$8c
		dc.w $84,$7d,$76,0
		dc.w $0371,$0340,$0311,$02e5
		dc.w $02bb,$0294,$026f,$024c
		dc.w $022b,$020c,$01ee,$01d3
		dc.w $01b9,$01a0,$0188,$0172
		dc.w $015e,$014a,$0138,$0126
		dc.w $0116,$0106,$f7,$e9
		dc.w $dc,$d0,$c4,$b9
		dc.w $af,$a5,$9c,$93
		dc.w $8b,$83,$7b,$75
		dc.w 0,$036b,$033a,$030b
		dc.w $02e0,$02b6,$028f,$026b
		dc.w $0248,$0227,$0208,$01eb
		dc.w $01cf,$01b5,$019d,$0186
		dc.w $0170,$015b,$0148,$0135
		dc.w $0124,$0114,$0104,$f5
		dc.w $e8,$db,$ce,$c3
		dc.w $b8,$ae,$a4,$9b
		dc.w $92,$8a,$82,$7b
		dc.w $74,0,$0364,$0334
		dc.w $0306,$02da,$02b1,$028b
		dc.w $0266,$0244,$0223,$0204
		dc.w $01e7,$01cc,$01b2,$019a
		dc.w $0183,$016d,$0159,$0145
		dc.w $0133,$0122,$0112,$0102
		dc.w $f4,$e6,$d9,$cd
		dc.w $c1,$b7,$ac,$a3
		dc.w $9a,$91,$89,$81
		dc.w $7a,$73,0,$035e
		dc.w $032e,$0300,$02d5,$02ac
		dc.w $0286,$0262,$023f,$021f
		dc.w $0201,$01e4,$01c9,$01af
		dc.w $0197,$0180,$016b,$0156
		dc.w $0143,$0131,$0120,$0110
		dc.w $0100,$f2,$e4,$d8
		dc.w $cb,$c0,$b5,$ab
		dc.w $a1,$98,$90,$88
		dc.w $80,$79,$72,0
mt_buffers	dc.l mt_buffer1
mt_sharpox	dc.l mt_buffer2
mt_speed:	dc.b $06
fmt_songpos:	dc.b $00
mt_counter:	dc.b $00
mt_break:	dc.b $00
mt_pattdelay:	dc.b $00
		even

		Section BSS

fmt_heure	ds.w 1
fmt_minute	ds.w 1
fmt_seconde     ds.w 1
mt_voladr	ds.l 1
mt_pattpos:	ds.w 1
mt_dmacon:	ds.w 1
mt_samplestarts:ds.l 31
mt_voice1:	ds.w 20
mt_voice2:	ds.w 20
mt_voice3:	ds.w 20
mt_voice4:	ds.w 20
ldff0a0:	ds.l 2
ldff0a8:	ds.l 2
		ds.w 1
ldff0b0:	ds.l 2
ldff0b8:	ds.l 2
		ds.w 1
ldff0c0:	ds.l 2
ldff0c8:	ds.l 2
		ds.w 1
ldff0d0:	ds.l 2
ldff0d8:	ds.l 2
		ds.w 1
vide		ds.w 10
mt_buffer1	ds.w	128<<3
mt_buffer2	ds.w	128<<3
mt_buff1	ds.b	128<<3
mt_buff2	ds.b	128<<3
mt_buff3	ds.b	128<<3
mt_buff4	ds.b	128<<3
mt_voltab	ds.l	64*66
mt_data		ds.l	1
SpectreData	ds.l	20
fmt_ecran	ds.b	66*larg


