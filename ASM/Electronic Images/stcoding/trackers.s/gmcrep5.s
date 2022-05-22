;----------------  GameMusicCreator Replay-routine v1.0  ---------------;
;									;
;      ST Version Programmed By Martin Griffiths (C) MARCH 1991		;
;									;
; - Uses NO Registers except USP(so you must run in supervisor mode)	;
; - All commands + full voluming at 11khz takes about 61% cpu time	;
; - This version also copes with instruments up to 128k as it should do!;
; - Also copes with small instruments without variation in cpu time.	;
;-----------------------------------------------------------------------;
; Completed 4.30Am 29/03/1991 (Off to bed....) 


;-----------------------------------------------------------------------;

speed	EQU 45  			; (10.791khz)

; The 'speed' is the timer D Delay value and can be in range of 
; about 40 to 150 (note that 40 would use ALL CPU time!!!)
; To calculate the frequency from the timer D value use the following
; formula :-
; (2457600/speed)/4 so if speed = 40 then we would have the following
;                        (2457600/45)/4=13653HZ = 13.653Khz
;    	
;-----------------------------------------------------------------------;

; Example setup code :-

	CLR.L -(SP)
	MOVE #$20,-(SP)
	TRAP #1				; go for supervisor mode
	ADDQ.L #6,SP
	LEA filename,A4
	LEA MUSICDATA,a5
	MOVE.L #5000000,D7
	BSR Load_file			; load the module!
	MOVE #$2700,SR			; switch off ints
	LEA $FFFFFA00.W,A1
	LEA old_stuff(PC),A0
	MOVE.B $07(A1),(A0)+
	MOVE.B $09(A1),(A0)+
	MOVE.B $13(A1),(A0)+
	MOVE.B $15(A1),(A0)+		; Save mfp registers 
	MOVE.B $1D(A1),(A0)+
	MOVE.B $25(A1),(A0)+
	MOVE.L $70.W,(A0)+		
	MOVE.L $110.W,(A0)+		; + timer d vector
	CLR.B $fffffa07.W
	MOVE.B #$10,$fffffa09.W
	CLR.B $fffffa13.W
	MOVE.B #$10,$fffffa15.W
	BCLR.B #3,$fffffa17.W		; software end of interrupt mode
	CLR.B $fffffa1d.W
	MOVE.B rotfile+17(PC),$fffffa25.W
	MOVE.L rotfile+12(PC),$110.W
	MOVE.B #1,$fffffa1d.W
	MOVE.L #my_vbl,$70.W
	LEA MUSICDATA,a0     		; pointer to datablock to play 
	BSR rotfile     		; initalise music
	LEA sndbuff(PC),A0
	MOVE.L A0,USP
	MOVE #$2300,SR			; go!

waitk	BTST.B #0,$FFFFFC00.W
	BEQ.S waitk
	MOVE.B $FFFFFC02.W,D0
	CMP.B #$39+$80,D0		; wait for spacebar
	BNE.S waitk

out	MOVE #$2700,SR
	LEA old_stuff(PC),A0
	MOVE.B (A0)+,$FFFFFA07.W
	MOVE.B (A0)+,$FFFFFA09.W
	MOVE.B (A0)+,$FFFFFA13.W
	MOVE.B (A0)+,$FFFFFA15.W	; restore system!
	MOVE.B (A0)+,$FFFFFA1D.W
	MOVE.B (A0)+,$FFFFFA25.W	
	MOVE.L (A0)+,$70.W
	MOVE.L (A0)+,$110.W
	BSET.B #3,$FFFFFA17.W
	MOVE #$2300,SR
	CLR -(SP)			; bye...
	TRAP #1
old_stuff
	DS.L 5

; The vbl - calls sequencer and vbl filler

my_vbl	MOVEM.L D0-D7/A0-A6,-(SP)
	BSR rotfile+4
	MOVEM.L (SP)+,D0-D7/A0-A6
	RTE

; The rotfile

rotfile:BRA.W Mu_startmusic     	; initalise music
	BRA.W playframe			; vbl play (call from vbl!)
	BRA.W setpos
	DC.L player
timerspd:
	DC.W speed
	DC.B "GMC ST Music Driver (C) 1991 Martin Griffiths"
	EVEN

; Make buffer and call sequencer
 	
playframe:
	BSR Vbl_play
	BRA MU_playsong

; Vbl player - this is a kind of 'Paula' Emulator(!)

Vbl_play:
	MOVE.L USP,A4
	MOVE.L A4,D0
	MOVEA.L	buff_ptr(PC),A4
	MOVE.L D0,buff_ptr
	SUB.L A4,D0
	BEQ skipit
	BHI.S higher
	ADDI.W #$800,D0
higher	LSR.W #1,D0
	MOVE.L #endbuff,D1
	SUB.L A4,D1
	LSR.W #1,D1
	CLR.W fillx1
	CMP.W D1,D0
	BCS.S higher1
	MOVE.W D1,fillx1
higher1	SUB.W fillx1(PC),D0
	MOVE.W D0,fillx2
; A4 points to place to fill
	LEA.L ch1s(PC),A5
	LEA (A4),A0
	BSR add1
	LEA.L ch2s(PC),A5
	LEA (A4),A0
	BSR add1
	LEA.L ch3s(PC),A5
	LEA (A4),A0
	BSR add1
	LEA.L ch4s(PC),A5
	LEA (A4),A0
	BSR add1
	RTS

; Routine to add/move one voice to buffer. The real Paula emulation part!!

add1	MOVE.L (A5),A2			; current sample end address(shadow amiga!)
	MOVEM.W 8(A5),D1/D2		; period/volume
	EXT.L D1
	BEQ.S zero
const	MOVE.L #$12345678,D0
; 32 bit divide stolen from GFA Basic 3.5. D0=D0/D1
	MOVEQ	#0,D5			
	MOVEQ	#1,D4
	CMP.L	D1,D0
	BCS.S	L23030
L2301E	ADD.L	D1,D1
	ADD.L	D4,D4
	CMP.L	D1,D0
	BCC.S	L2301E
	BRA.S	L23030
L23028	CMP.L	D1,D0
	BCS.S	L23030
	OR.L	D4,D5
	SUB.L	D1,D0
L23030	LSR.L	#1,D1
	LSR.L	#1,D4
	BNE.S	L23028
	MOVE.L	D5,D1
	
zero	MOVE.W D1,D4
	CLR D1
	SWAP D1
	LEA  vols(PC),A1
	LSL.W #8,D2
	ADD.W D2,A1			; ptr to volume table
	MOVE.L 4(A5),D6			; sample length
	NEG.L D6
	CMP.L #MU_empty+4,A2
	BNE.S vcison
	MOVEQ.L #0,D4
	MOVEQ.L #0,D1
vcison	MOVEQ.L	#0,D2			; clr top byte for sample
	MOVE.W 20(a5),D3		; get fraction part
; Setup Loop stuff
	MOVE.L 12(a5),A6		; loop addr
	MOVE.L 16(a5),D5		; loop length
	NEG.L D5
	MOVE.L D1,D7
	MOVE.W D4,A3
	CMP.L #-4,D5
	BNE.S isloop
noloop	MOVE.L D2,D7			; no loop-no frequency
	MOVE.W D2,A3			; 
isloop	MOVE.W fillx1(PC),D0
	BSR.S addit		
	MOVE.W fillx2(PC),D0
	TST.W fillx1
	BEQ.S nores
	LEA.L sndbuff(PC),A0
nores	BSR.S addit
	NEG.L D6			; +ve offset(as original!)
	MOVE.L A2,(A5)			; store voice address
	MOVE.L D6,4(A5)			; store offset for next time
	MOVE.W D3,20(A5)		; restore fraction part
skipit	RTS

; ADD D0 sample bytes to buffer

addit	CMP.L #ch1s,A5
	BEQ moveit
	PEA (A5)
	MULU #18,D0
	LEA jmpadd(PC),A5
	SUB D0,A5
	JMP (A5)
i	SET 0
sa	REPT 350
	MOVE.B (A2,D6.L),D2
	MOVE.B (A1,D2),D2
	ADD.W D2,(A0)+
	ADD.W D4,D3
	ADDX.L D1,D6
	BCS lp+i
i	SET i+16
	ENDR
jmpadd	MOVE.L (SP)+,A5
	RTS

i	SET 18
lp	REPT 350
	MOVE.L A6,A2
	MOVE.L D5,D6
	MOVE.L D7,D1
	MOVE.W A3,D4
	MOVE #0,CCR
	BRA.W sa+i 
i	SET i+18
	ENDR

; MOVE D0 sample bytes to buffer

moveit	PEA (A5)
	MULU #18,D0
	LEA jmpmove(PC),A5
	SUB D0,A5
	JMP (A5)
i	SET 0
sm	REPT 350
	MOVE.B (A2,D6.L),D2
	MOVE.B (A1,D2),D2
	MOVE.W D2,(A0)+
	ADD.W D4,D3
	ADDX.L D1,D6
	BCS lpm+i
i	SET i+16
	ENDR
jmpmove	MOVE.L (SP)+,A5
	RTS

i	SET 18
lpm	REPT 350
	MOVE.L A6,A2
	MOVE.L D5,D6
	MOVE.L D7,D1
	MOVE.W A3,D4
	MOVE #0,CCR
	BRA.W sm+i 
i	SET i+18
	ENDR

buff_ptr
	dc.l sndbuff
sndbuff	ds.b $800
endbuff	dc.w -1
fillx1	DC.W 0
fillx2	DC.W 0
	
; YM2149 Soundchip.

player:	MOVE.L D7,-(SP)
	PEA (A0)
	move.l usp,a0
	move.w (a0)+,d7
	tst.w (a0)
	bmi.s loopit
contsnd	move.l a0,usp
	add d7,d7
	add d7,d7
	lea $ffff8800.w,a0
	move.l sound_look(pc,d7.w),d7
	movep.l	d7,(a0)
	MOVE.L (SP)+,A0
	MOVE.L (SP)+,D7
	rte
loopit	lea sndbuff(pc),a0
	bra.w contsnd
sound_look:
	incbin player.dat\2chansnd.tab

; ST specific initialisation - sets up shadow amiga registers

STspecific:
	MOVEQ #0,D0
	LEA 	MU_empty+4(PC),A2
	LEA	ch1s(pc),A0
	BSR	initvoice
	LEA	ch2s(pc),A0
	BSR	initvoice
	LEA	ch3s(pc),A0
	BSR	initvoice
	LEA	ch4s(pc),A0
	BSR	initvoice
	MOVE	#$8800,A0
	MOVE.B	#7,(A0)
	MOVE.B	#$C0,D0
	AND.B	(A0),D0
	OR.B	#$38,D0
	MOVE.B	D0,2(A0)
	MOVE	#$600,D0
.setup	MOVEP.W D0,(A0)
	SUB	#$100,D0
	BPL.S 	.setup
	LEA	sndbuff(PC),A0
	MOVE	#$1FF,D0
	MOVE.L	#$00800080,D1
.setbuf	MOVE.L	D1,(A0)+
	DBF	D0,.setbuf
	MOVE.W timerspd(PC),D0
	ADD D0,D0
	ADD D0,D0
	LEA freqs(PC),A0
	MOVE.L (A0,D0),const+2
	RTS
initvoice:
	MOVE.L	A2,(A0)			; point voice to nul sample
	MOVE.W	#4,4(A0)		; length=4(nul)
	MOVE.W	D0,6(A0)		; period=0
	MOVE.W	D0,8(A0)		; volume=0
	MOVE.L	A2,10(A0)		; and loop point to nul sample
	MOVE.W	#4,14(A0)		; replength=4(nul)
	RTS

setpos	rts

; Shadow Amiga Hardware Registers.

shadow_dmacon:				; shadow dma control register(!)	
	DS.L 1

ch1s	DS.B 22				; shadow dff0a0 -> dff0e0
ch2s	DS.B 22
ch3s	DS.B 22
ch4s	DS.B 22

; Load a file of D7 bytes, Filename at A4 into address A5.

Load_file
	MOVE #2,-(SP)
	MOVE.L A4,-(SP)
	MOVE #$3D,-(SP)
	TRAP #1
	ADDQ.L #8,SP
	MOVE D0,D4
read	MOVE.L A5,-(SP)
	MOVE.L D7,-(SP)
	MOVE D4,-(SP)
	MOVE #$3F,-(SP)
	TRAP #1
	LEA 12(SP),SP
close	MOVE D4,-(SP)
	MOVE #$3E,-(SP)
	TRAP #1
	ADDQ.L #4,SP
	RTS

*******************************************************
******** GameMusicCreator Replay-routine v1.0 *********
*******************************************************

MU_startmusic:
 move.l  a0,MU_data
 move.l  a0,MU_tablepos
 move.l  a0,MU_songpointer
 add.l   #242,MU_tablepos
 add.l   #444,MU_songpointer
 move.w  #64,MU_patterncount
 move.w  #$f,shadow_dmacon
 clr.l   MU_vol0
 clr.l   MU_vol2
 clr.l   MU_pospointer
 clr.w   MU_songspeed
 clr.w   MU_note0
 clr.w   MU_note1
 clr.w   MU_note2
 clr.w   MU_note3
 clr.w   MU_slide0
 clr.w   MU_slide1
 clr.w   MU_slide2
 clr.w   MU_slide3
 clr.w   MU_stop
 clr.l   MU_chan0
 clr.l   MU_chan1
 clr.l   MU_chan2
 clr.l   MU_chan3
 move.w  #6,MU_songstep
 move.l  a0,a2
 add.l   #244,a2
 move.l  240(a0),d1
 sub.l   #1,d1
 clr.l   d0
MU_sizeloop:
 move.w  (a2)+,d2
 cmp.w   d2,d0
 bge     MU_nosizeadd
 move.w  d2,d0
MU_nosizeadd:
 dbf     d1,MU_sizeloop
 add.l   #1024,d0
 move.l  a0,a1
 add.l   #444,a1
 add.l   d0,a1
 move.l  #14,d7
 bsr     MU_calcins
 BRA Stspecific

MU_calcins:
 cmp.l   #0,(a0)
 bne     MU_calcit
 add.l   #16,a0
 dbf     d7,MU_calcins
 rts
MU_calcit:
 move.l  (a0),d0
 move.l  8(a0),d1
 sub.l   d0,d1  ;repeat
 move.l  a1,(a0)
 move.l  a1,d0
 add.l   d1,d0
 move.l  d0,8(a0) ;set repeat
 cmp.w   #2,12(a0)
 bne     mu_looping
 move.l  #MU_empty,8(a0)
mu_looping:
 clr.l   d0
 move.w  4(a0),d0 ;add sampletable
 lsl.l   #1,d0
 add.l   d0,a1
 add.l   #16,a0
 dbf     d7,MU_calcins
 rts

MU_playsong:
 bsr     MU_everyvert
 add.w   #1,MU_songspeed
 move.w  MU_songstep,d0
 cmp.w   MU_songspeed,d0
 ble     MU_okplay
 rts
MU_okplay: 
 clr.w   MU_songspeed
 add.w   #1,MU_patterncount
 cmp.w   #65,MU_patterncount
 bne     MU_playit
MU_setnewpat:
******* calc position ****
 add.l   #1,MU_pospointer
 move.l  MU_pospointer,d0
 move.l  MU_data,a5
 cmp.l   240(a5),d0
 bhi     MU_setstart
***********************
 move.w  #1,MU_patterncount
 add.l   #2,MU_tablepos
 move.l  MU_tablepos,a0
 clr.l   d0
 move.w  (a0),d0
 move.l  MU_data,a0
 add.l   #444,a0
 add.l   d0,a0
 move.l  a0,MU_songpointer
 bra     MU_playit
************************
MU_setstart:
 clr.l   MU_pospointer
 move.l  MU_data,MU_tablepos
 add.l   #242,MU_tablepos
 bra     MU_setnewpat
MU_playit:
 move.l  MU_songpointer,a0
 add.l   #16,MU_songpointer
 move.l  (a0),d0
 clr.w   d3
 move.w  #1,d2
 bsr     MU_setinstr
 bsr     MU_seteffect
 move.l  4(a0),d0
 move.w  #2,d2
 bsr     MU_setinstr
 bsr     MU_seteffect
 move.l  8(a0),d0
 move.w  #3,d2
 bsr     MU_setinstr
 bsr     MU_seteffect
 move.l  12(a0),d0
 move.w  #4,d2
 bsr     MU_setinstr
 bsr     MU_seteffect
 move.w  d3,shadow_dmacon
 rts
MU_setinstr:
 move.w  d0,d5
 and.w   #$f000,d0
 cmp.w   #0,d0
 bne     MU_setit
 rts
MU_setit:
 swap    d0
 move.w  d0,d1
 clr.w   d0
 swap    d0
 lsr.w   #8,d0
 lsr.w   #4,d0
 sub.w   #1,d0
 lsl.w   #4,d0
 move.l  MU_data,a6
 add.l   d0,a6
 cmp.w   #1,d2
 bne     MU_conti1
 clr.w   ch1s+10
 move.l  a6,MU_chan0

 move.l  (a6),ch1s
 moveq #0,d0
 move.w  4(a6),d0
 add.l d0,d0
 move.l d0,ch1s+4
 add.l d0,ch1s

 move.w  d1,ch1s+8
 move.w  d1,MU_note0
 move.w  6(a6),MU_vol0
 clr.w   MU_slide0
 bset    #0,d3
 rts
MU_conti1:
 cmp.w   #2,d2
 bne     MU_conti2
 clr.w   ch2s+10
 move.l  a6,MU_chan1

 move.l  (a6),ch2s
 moveq #0,d0
 move.w  4(a6),d0
 add.l d0,d0
 move.l d0,ch2s+4
 add.l d0,ch2s

 move.w  d1,ch2s+8
 move.w  d1,MU_note1
 move.w  6(a6),MU_vol1
 clr.w   MU_slide1
 bset    #1,d3
 rts
MU_conti2:
 cmp.w   #3,d2
 bne     MU_conti3
 clr.w   ch3s+10
 move.l  a6,MU_chan2
 move.l  (a6),ch3s

 moveq #0,d0
 move.w  4(a6),d0
 add.l d0,d0
 move.l d0,ch3s+4
 add.l d0,ch3s

 move.w  d1,ch3s+8
 move.w  d1,MU_note2
 move.w  6(a6),MU_vol2
 clr.w   MU_slide2
 bset    #2,d3
 rts
MU_conti3:
 clr.w   ch4s+10
 move.l  a6,MU_chan3
 move.l  (a6),ch4s

 moveq #0,d0
 move.w  4(a6),d0
 add.l d0,d0
 move.l d0,ch4s+4
 add.l d0,ch4s

 move.w  d1,ch4s+8
 move.w  d1,MU_note3
 move.w  6(a6),MU_vol3
 clr.w   MU_slide3
 bset    #3,d3
 rts
MU_seteffect:
 move.w  d5,d6
 and.w   #$00ff,d5
 and.w   #$0f00,d6
 cmp.w   #0,d6
 beq     MU_effjump2
 cmp.w   #$0100,d6
 beq     MU_slideup
 cmp.w   #$0200,d6
 beq     MU_slidedown
 cmp.w   #$0300,d6
 beq     MU_setvolume
 cmp.w   #$0500,d6
 beq     MU_posjump
 cmp.w   #$0400,d6
 bne     MU_nobreak
MU_itsabreak:
 move.w  #64,MU_patterncount
 rts
MU_nobreak:
 cmp.w   #$0800,d6
 bne     MU_effjump0
 move.w  d5,MU_songstep
 rts
MU_effjump0:
 cmp.w   #$0600,d6
 bne     MU_effjump1
 ;bclr    #1,$bfe001
 rts
MU_effjump1:
 cmp.w   #$0700,d6
 bne     MU_effjump2
 ;bset    #1,$bfe001
MU_effjump2:
 rts
MU_posjump:
 clr.l   d4
 move.w  d5,d4
 sub.l   #1,d4
 move.l  d4,MU_pospointer
 add.l   #1,d4
 lsl.w   #1,d4
 sub.w   #2,d4
 move.l  MU_data,a0
 add.l   #244,a0
 add.l   d4,a0
 move.l  a0,MU_tablepos
 bra     MU_itsabreak
MU_slideup:
 neg.w   d5
MU_slidedown:
 cmp.w   #1,d2
 bne     MU_j1
 move.w  d5,MU_slide0
 rts
MU_j1:
 cmp.w   #2,d2
 bne     MU_j2
 move.w  d5,MU_slide1
 rts
MU_j2:
 cmp.w   #3,d2
 bne     MU_j3
 move.w  d5,MU_slide2
 rts
MU_j3:
 move.w  d5,MU_slide3
 rts
MU_setvolume:
 cmp.w   #1,d2
 bne     MU_j00
 move.w  d5,MU_vol0
; move.w  d5,ch1s+10
 rts
MU_j00:
 cmp.w   #2,d2
 bne     MU_j22
 move.w  d5,MU_vol1
; move.w  d5,ch2s+10
 rts
MU_j22:
 cmp.w   #3,d2
 bne     MU_j33
 move.w  d5,MU_vol2
; move.w  d5,ch3s+10
 rts
MU_j33:
 move.w  d5,MU_vol3
; move.w  d5,ch4s+10
 rts
MU_everyvert:
 move.w  MU_slide0,d0
 add.w   d0,MU_note0
 move.w  MU_note0,ch1s+8
 move.w  MU_slide1,d0
 add.w   d0,MU_note1
 move.w  MU_note1,ch2s+8
 move.w  MU_slide2,d0
 add.w   d0,MU_note2
 move.w  MU_note2,ch3s+8
 move.w  MU_slide3,d0
 add.w   d0,MU_note3
 move.w  MU_note3,ch4s+8
 btst    #0,MU_stop
 beq     MU_ok1
 bclr    #0,MU_stop
 move.l  MU_chan0,a0
 move.l  8(a0),ch1s+12

 moveq #0,d0
 move.w  12(a0),d0
 add.l d0,d0
 move.l d0,ch1s+16
 add.l d0,ch1s+12

 clr.l   MU_chan0
MU_ok1:
 btst    #1,MU_stop
 beq     MU_ok2
 bclr    #1,MU_stop
 move.l  MU_chan1,a0
 move.l  8(a0),ch2s+12

 moveq #0,d0
 move.w  12(a0),d0
 add.l d0,d0
 move.l d0,ch2s+16
 add.l d0,ch2s+12

 clr.l   MU_chan1
MU_ok2:
 btst    #2,MU_stop
 beq     MU_ok3
 bclr    #2,MU_stop
 move.l  MU_chan2,a0
 move.l  8(a0),ch3s+12

 moveq #0,d0
 move.w  12(a0),d0
 add.l d0,d0
 move.l d0,ch3s+16
 add.l d0,ch3s+12

 clr.l   MU_chan2
MU_ok3:
 btst    #3,MU_stop
 beq     MU_ok4
 bclr    #3,MU_stop
 move.l  MU_chan3,a0
 move.l  8(a0),ch4s+12

 moveq #0,d0
 move.w  12(a0),d0
 add.l d0,d0
 move.l d0,ch4s+16
 add.l d0,ch4s+12
 clr.l   MU_chan3

MU_ok4:
 move.w   #$8000,d3
 cmp.l    #0,MU_chan0
 beq      MU_okk1
 bset     #0,MU_stop
 bset     #0,d3
MU_okk1:
 cmp.l    #0,MU_chan1
 beq      MU_okk2
 bset     #1,MU_stop
 bset     #1,d3
MU_okk2:
 cmp.l    #0,MU_chan2
 beq      MU_okk3
 bset     #2,MU_stop
 bset     #2,d3
MU_okk3:
 cmp.l    #0,MU_chan3
 beq      MU_okk4
 bset     #3,MU_stop
 bset     #3,d3
MU_okk4:
 move.w   d3,shadow_dmacon
 move.w   MU_vol0,ch1s+10
 move.w   MU_vol1,ch2s+10
 move.w   MU_vol2,ch3s+10
 move.w   MU_vol3,ch4s+10
 rts
********** variables *****
MU_stop:  	dc.w 0
MU_slide0:	dc.w 0
MU_slide1: 	dc.w 0
MU_slide2: 	dc.w 0
MU_slide3:	dc.w 0
MU_chan0: 	dc.l 0
MU_chan1: 	dc.l 0
MU_chan2:	dc.l 0
MU_chan3: 	dc.l 0
MU_note0:	dc.w 0
MU_note1:	dc.w 0
MU_note2:	dc.w 0
MU_note3: 	dc.w 0
MU_vol0: 	dc.w 0
MU_vol1: 	dc.w 0
MU_vol2:	dc.w 0
MU_vol3: 	dc.w 0
MU_songspeed: 	dc.w 0
MU_songstep:  	dc.w 5
MU_patterncount:dc.w 0
MU_songpointer: dc.l 0
MU_tablepos: 	dc.l 0
MU_pospointer: 	dc.l 0 
MU_empty: 	ds.l 3
MU_data: 	dc.l 0
vols		INCBIN player.dat\pt_volta.dat	; volume table
		EVEN
freqs		DS.L 30
		INCBIN player.dat\frqconst.dat	; frequency table
		EVEN
filename:
	DC.B "ATMOS.GMC",0
	EVEN

MUSICDATA:
