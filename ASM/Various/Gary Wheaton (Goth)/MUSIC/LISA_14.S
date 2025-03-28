; this is Gary Wheaton music driver
; the tune will play during the vertical blank.
; the slot chosen in the v/b queue is fairly high up
; which means that it is immune from interference
; this code is copyright Gary Wheaton  Nov 1989
; Gary Wheaton and the Shapeshifters are members
; of the Budgie UK group.
; Budgie UK Licenceware: the fairer face of PD
;   lisa     January 1990
	MOVE.L A7,A5
	MOVE.L 4(A5),A5
	MOVE.L $C(A5),D0
	ADD.L $14(A5),D0
	ADD.L $1C(A5),D0
	ADD.L #$1100,D0
	MOVE.L A5,D1
	ADD.L D0,D1
	AND.L #-2,D1
	MOVE.L D1,A7
	MOVE.L D0,-(SP)
	MOVE.L A5,-(SP)
	MOVE.W D0,-(SP)
	MOVE.W #$4A,-(SP) ; Setblock.
	TRAP #1
	ADD.L #12,SP

	CLR.L -(SP)       ; Enter supervisor mode.
	MOVE.W #$20,-(SP) ; Super.
	TRAP #1
	ADDQ.L #6,SP
	MOVE.L D0,SUPER   ; Save old status
*******


	dc.w	$a000
	MOVEA.L	8(A0),A0
	CLR.W	(A0)
	DC.W	$A00A		hidemouse

	movem.l	$ff8240,d0-d7
	movem.l	d0-d7,palette


getrez	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,res

setlowrez
	CLR.W	-(A7)		0=low res
	MOVE.L	$44e,-(A7)	-1=ignore physbase
	MOVE.L	$44e,-(A7)	-1=ignore logbase
	MOVE.W	#5,-(A7)
	TRAP	#14		
	LEA	$0C(A7),A7	

	clr.l	$200
	not.l	$200		on/off switch
	bclr 	#0,$484		no keyclick
	bclr 	#1,$484		no repeat key

	move.l	#vbi,$4de	start vbi interrupt

* load a degas picture at a specific address 
	MOVE.W	#0,-(A7)
	pea	name(pc)
	MOVE.W	#$3D,-(A7)
	TRAP	#1
	add.l	#8,sp
	MOVE.W	D0,d7	handle

	move.l	$44e,d0		load direct to current screen
	sub.l	#34,d0
	MOVE.L	d0,-(sp) 
	MOVE.L	#34,-(A7)	read it
	MOVE.W	d7,-(A7)	handle
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	ADDA.L	#$C,A7

	move.l	$44e,a0
	sub.l	#32,a0		palette
	MOVE.L	A0,-(SP)  
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP

	move.l	$44e,d0		load direct to current screen
	MOVE.L	d0,-(sp) 
	MOVE.L	#32000,-(A7)	read it
	MOVE.W	d7,-(A7)	handle
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	ADDA.L	#$C,A7


	MOVE.W 	d7,-(SP)	close
	MOVE.W 	#$3E,-(SP)
	TRAP 	#1
	ADDQ.L 	#4,SP

	move.l	$44e,a0
	sub.l	#32,a0		palette
	MOVE.L	A0,-(SP)  
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP

getkey	MOVE.W	#$07,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	ANDI.W	#$DF,D0		force upper case

* restore res
	move.w	res,-(A7)	
	MOVE.L	$44e,-(A7)	-1=ignore physbase
	MOVE.L	$44e,-(A7)	-1=ignore logbase
	MOVE.W	#5,-(A7)
	TRAP	#14		
	LEA	$0C(A7),A7	

	movem.l	palette,d0-d7
	movem.l	d0-d7,$ff8240



	MOVE.L SUPER,-(SP)	user mode
	MOVE.W #$20,-(SP)
	TRAP #1
	ADDQ.L #6,SP

	MOVE.W #0,-(SP)		quit and stay
	MOVE.L #1024*10,-(SP)
	MOVE.W #$31,-(SP)
	TRAP #1

SL EQU $FF8800
SD EQU $FF8802
 move.b #7,sl
 move.b #%11111000,sd

 MOVE.B #$08,SL
 MOVE.B #15,SD
 MOVE.B #$0,SL
 MOVE.B #96,SD

 MOVE.B #$01,SL
 MOVE.B #$00,SD

vbi 
	movem.l	d0-d7/a0-a6,-(sp)

	lea	$fffc00,a1		acia
	cmp.b	#$61,2(a1)		undo
	beq	end_it
	cmp.b	#$62,2(a1)		help
	beq	on_off

	lea	$200,a0
	tst.l	(a0)
	beq	quiet

 	move.b #7,sl
	move.b #%11111000,sd		mixer


 MOVE.L UPTO,A2
 MOVE CUNT,D3
 MOVE.B 33(A2),D4
SSU SUBQ.W #1,D3
 BPL.S PART1

COP
 MOVE.L #1,PNT0
 MOVE.L #1,PNT1
 MOVE.L #1,PNT2
 MOVE.L #1,PNT3
 MOVE.L #1,PNT4
 MOVE.L #1,PNT5
 MOVE.L #$9000000,SL

 ADD.L #36,a2
 CMP.L #CHAN0,A2
 BNE.S LLA
 LEA DOTH,A2
LLA
 MOVE 34(A2),D3
 MOVE.B 33(A2),D4
PART1
 CLR.B D2
 BTST #1,D4
 BEQ.S W1
 MOVE.L (A2),A1
 MOVE.L 4(A2),A0
 BSR CHAN0
W1 BTST #2,D4
 BEQ.S W2
 MOVE.L 8(A2),A1
 MOVE.L 12(A2),A0
 BSR CHAN0
W2 MOVEQ.B #1,D2
 BTST #3,D4
 BEQ.S W3
 MOVE.L 16(A2),A1
 MOVE.L 20(A2),A0
 BSR CHAN0
W3 BTST #4,D4
 BEQ.S W4
 MOVE.L 24(A2),A1
 MOVE.L 28(A2),A0
 BSR CHAN0
W4 MOVE.L A2,UPTO
 MOVE D3,CUNT


	movem.l (sp)+,d0-d7/a0-a6
 	RTS
end_it
	bclr	#6,$fffa11	acknowledge key press interrupt
	lea	$ff8800,a0
	move.b	#7,(a0)
	move.b	#%11111111,2(a0)
	move.l	#0,$4de		end interrupt
	movem.l (sp)+,d0-d7/a0-a6
 	rts
on_off	bclr	#6,$fffa11	
	not.l	$200		toggle on/off
	lea	$ff8800,a0
	move.b	#7,(a0)
	move.b	#%11111111,2(a0)
	movem.l (sp)+,d0-d7/a0-a6
 	rts

quiet	movem.l (sp)+,d0-d7/a0-a6
return	rts
	even
quiet_flag	
	dc.b	0
	even

 DC.B "  G.WHEATON. 45 GOLDRILL AVE, BOLTON, LANCS, U.K. "
;EVEN

super dc.l 0

res	dc.w 0
palette	ds.w 16
*------------------------
 ; TITLE    **** LISA'S SONG ***    
 ; COMOPOSED BY G.WHEATON. JAN. 1990.




SV DC.L 0

 DC.B " (C) G.WHEATON.  45 GOLDRILL AVE BOLTON. LANCS, U.K. "

 DC.B  " TITLE    **** LISA'S SONG ***    "
 DC.B  " COMOPOSED BY G.WHEATON. JAN. 1990."


UPTO DC.L EE-36
CUNT DC.W 0
 EVEN
;\\RUNNING ORDER SEQUENCE

ee
doth
 DC.L PNT4,bass
 DC.L PNT0,tron DRIFT BASS
 DC.L PNT2,NULL
 DC.L PNT3,DRSM
 DC.B 2,%00011110
 DC.W 64*8

 DC.L PNT4,bass
 DC.L PNT0,JIV git
 DC.L PNT2,gt1
 DC.L PNT3,DRM
 DC.B 2,%00011110
 DC.W 64*8

 DC.L PNT4,bass
 DC.L PNT1,pian bass
 DC.L PNT2,bass
 DC.L PNT3,DRSM
 DC.B 1,%00011110
 DC.W 64*8

 DC.L PNT1,dit
 DC.L PNT4,bass
 DC.L PNT2,blond
 DC.L PNT3,DRSM
 DC.B 1,%00011110
 DC.W 64*8
 
 DC.L PNT1,octb 
 DC.L PNT4,bass
 DC.L PNT2,JIV blond
 DC.L PNT3,DRSM
 DC.B 2,%00011110
 DC.W 64*8

 DC.L PNT1,octb 
 DC.L PNT4,tron JIV bass
 DC.L PNT2,jiv tron blondI
 DC.L PNT3,DRSM
 DC.B 2,%00011110
 DC.W 64*8

 DC.L PNT1,gd null octb 
 DC.L PNT4,bass
 DC.L PNT2,null
 DC.L PNT3,DRSM
 DC.B 2,%00011110
 DC.W 64*8

 DC.L PNT1,octb 
 DC.L PNT4,blond
 DC.L PNT2,git
 DC.L PNT3,DRTM
 DC.B 2,%00011110
 DC.W 64*8

 DC.L PNT1,octb 
 DC.L PNT4,blondi
 DC.L PNT2,GIT
 DC.L PNT3,DRM
 DC.B 2,%00011110
 DC.W 64*8




CHAN0
;\\\\\\\\\\\\\\\\\\\\\\
 MOVE (A1),D0
 ADD D0,A0
 MOVE.L (A0),D1  ;GET NOTE 0 & DURATION
 MOVE.B 13(A1),D5
 EXT.W D5
 SWAP D1
 ADD D5,D1
 SWAP D1
 CMP #$FFFF,D1
 BNE CON2
 CLR (A1)        ;RESET TO START
 SUB D0,A0
 MOVE.L (A0),D1
CON2
 SUBQ.B #1,3(A1)    ;NP0
 BNE STILLON
 MOVE.L D1,6(A1) ;TMP0  \D1.W IS DURATION
 MOVE.L D1,20(A1);TEMP  HOLD NOTE
 MOVE.B 26(A1),4(A1)   ;VOL0
 MOVE D1,2(A1)   ;NP0  \SET NEW DURATION
 ADDQ.W #4,(A1)        ; & INC POINTER
STILLON
;\\VOLUME
RFF
;\\\\\\\\\EFFECTS\\\\\\\\\\
NV0 
 MOVE.B 2(A1),D0
 CMP.B #4,D0
 BNE DOIT
 ADDQ.B #1,4(A1)
 RTS
DOIT 

DZZ
 MOVE.B #7,SL
 MOVE.B #%11111000,SD
 BRA.S FCC
EFCT

 DC.L FINK,VIB,WARB,DRUM,slip,WB1,WRP,SLW
 DC.L SLR,HOLD,TWERP,SLR1,inup,HOLDLOW,Half,holl

FCC
 AND.L #15,D0
 ASL #2,D0
 MOVE.L EFCT(PC,D0),A0
 JSR (A0)

MAZ ADDQ.B #1,4(A1)          ;VOL0
 MOVE.B 11(A1),SL
 MOVE.B 21(A1),SD   ;TMP0+1
 MOVE.B 12(A1),SL
 MOVE.B 20(A1),SD   ;TMP0
 CLR D0
 MOVE.B 4(A1),D0
 MOVE.B 10(A1),SL
 MOVE.B 28(A1,D0),D2    ;VOL0
 MOVE.B D2,SD

fink rts

;-------EFFECTS ROUTINES--------
;1-256---DELAYED--VIBRATO-------
VV EOR.B #1,MC
 BEQ.S SDC
VIB CMP.B #8,4(A1)
 BLT SDC

WWQ SUB.B #1,24(A1)
 BNE SDC
 MOVE.B 25(A1),24(A1)
 MOVE 16(A1),D1
 ADD D1,18(A1)
 MOVE 14(A1),D1
 CMP 18(A1),D1
 BLT.S RIST
KJ NEG D1
 CMP 18(A1),D1
 BGT.S RIST
SAZ MOVE 6(A1),D1
 ADD 18(A1),D1
 MOVE D1,20(A1)
SDC RTS
RIST NEG 16(A1)
 BRA.S SAZ
;2-512------WARB DW-----------
XX DC.B 0,0

WARB addq.b #5,4(A1)
SAX 
 Lsr 20(A1)
 ;Lsr 20(A1)
 CMP #30,20(A1)
 BGT.S PLOP
 MOVE 6(A1),20(A1)
PLOP RTS


;3--768--------DRUM-----------
DRUM 
 ;eor.b #1,lil
 ;bne.s junk
 SUBQ.B #4,19(A1)
 MOVE.B #7,SL
 MOVE.B #%11011000,SD
 MOVE.B #6,SL
 MOVE.B 19(A1),SD
 MOVE.B #5,SL
 MOVE.B 32(A2),SD
 MOVE.B #4,SL
 MOVE.B 19(A1),D0
 ASL.B #5,D0
 MOVE.B D0,SD
JUNK RTS


lil dc.b 0,0

;------4 1024
slip 


;5--1280--WARB CONSTANT VOLUME
WB1 MOVE.B #5,4(A1)
 BRA.s SAX

;6--1536-----WARB UP---------
WRP 
 MOVE.B #12,4(A1)
SDX LSR 20(A1)
 CMP #35,20(A1)
 BGT PLAP
 MOVE 6(A1),20(A1)
PLAP RTS


;7--1792---SLIDE-UP--WARBLE
SLW 
 MOVE.B #7,4(a1)
 BRA wwq

;--2048---SLIDE UP CONST VOL 
SLR 
 ADD.W #80,20(A1)
 RTS

YIN DC.B 0,0
;9--2304-------HOLD-------------
HOLD MOVE.B #20,4(A1)
 RTS

;------10 1024
TWERP MOVE.B #128,DRI
 MOVE.B #28,4(a1)
 BRA SDX


;11-------2816 SLIDE UP WITH ADSR
SLR1
 CMP #72,6(A1)
 BGT WAQ

 BTST #1,$469
 BEQ.S F1

 MOVE #72,6(A1)
 BRA WWQ

F1 MOVE #36/2,6(A1)
 BRA WWQ


WAQ SUBQ.W #8,6(A1)
 MOVE.B #16,4(A1)
 BRA SDX


tp dc.b 0,0
;12-------3072  inc up
inup
 move.b #10,4(a1)
 add #53,6(a1)
 bra vib

;13-------3328--HOLD VOL LOW
HOLDLOW
 move.b #27,4(a1)
 rts
;
;14--------3584 half adsr
half
 ;addq.b #1,4(a1)
 move.b $469,d1
 and #3,d1
 asl #1,d1
 move dw(pc,d1),20(a1)
 rts

dw dc.w 144,96,72,96/2

;15--------3584 half adsr
holl
 addq.b #1,4(a1)
 move.b $469,d1
 and #3,d1
 asl #1,d1
 move dq(pc,d1),20(a1)
 rts

dq dc.w 162,108,81,64






;\\\\\\\\\\\\\\DATAS\\\\\\\\\\\\\\\
;\\NOTE 1ST WORD. DURATION 2ND WORD
;\\\LEAD
PNT0 DC.W 0
NP0 DC.W 1
 DC.W 0
 DC.L 0
 DC.B 9,2,3
 DC.B 1      ;ADD TO NOTE
 DC.W 7      ;VIB LIMIT
 DC.W 4      ;16(A1)  ADD
 DC.W 0      ;VIB 18(A1)
 DC.L 0      ;TMP NOTE 20(A1)
 DC.B 1,1    ;VIB RATE 24(A1)
 DC.B 0,0    ;INITIAL VOL
;ADSR  28(A1)
 DC.B 5,7,9,12,13,14,15,15
 dcb.b	60,9
 dcb.b	60,7
 dcb.b	60,5
 dcb.b	60,3

 EVEN
;\\\MIDDLE
PNT1 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 9,2,3
 DC.B 1       ;ADD  13(A1)
 DC.W 6       ;VIB LIMIT
 DC.W 2       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)
 DC.B 15,14,12,10,9,8,8,8,9,9,8
 DC.B 8,8,7,7,6,6,7,6,6,5,4,4

 DCB.B 10,5
 DCB.B 10,6
 DCB.B 10,7
 DCB.B 10,8
 DCB.B 10,9
 DCB.B 10,10
 DCB.B 10,12
 DCB.B 10,10
 DCB.B 10,9
 DCB.B 10,7
 DCB.B 10,4

 EVEN
;\\\BASS
PNT2 DC.W 0
 DC.W 1          ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,4,5     ;10(A1) VOL REG
 DC.B 0          ;ADD TO NOTE 13(A1)
 DC.W 7          ;VIB LIMIT
 DC.W 5          ;VIBRATO ADD 16(A1)
 DC.W 2          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
ADSR
 DC.B 15,12,13,12,15,14,14,13,11,8
 DC.B 7,6,5,4,3,3,2,2

 REPT 180
 DC.B 2
 ENDR

 EVEN
PNT3 DC.W 0
NP3 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,6,11    ;10(A1) VOL REG
 DC.B -1         ;ADD  13(A1)
 DC.W 4         ;VIB LIMIT
 DC.W 1          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
 DC.B 15,15,13,10,12,11
 DC.B 11,10,10,9,8,7

 dc.b 10,9,8,10,9,8,10,9,8,10,9,8
 dc.b 10,9,8,10,9,8,10,9,8,10,9,8
 dc.b 10,9,8,10,9,8,10,9,8,10,9,8

 dcb.b 50,7

 EVEN
PNT4 DC.W 0
NP4 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0
 DC.B 8,0,1      ;10(A1) VOL REG
 DC.B 0          ;ADD 13(A1)
 DC.W 15          ;VIB LIMIT
 DC.W 13          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)

 DC.B 15,15,15,14,14,14,13,13,12,12
 REPT 22
 DC.B 11
 ENDR

 REPT 22
 DC.B 9
 ENDR

 REPT 22
 DC.B 8
 ENDR

 REPT 22
 DC.B 7
 ENDR

 REPT 22
 DC.B 5
 ENDR

 REPT 24
 DC.B 3
 ENDR

 REPT 24
 DC.B 2
 ENDR

 REPT 64
 DC.B 1
 ENDR


PNT5 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 8,0,1
 DC.B 0       ;ADD  13(A1)
 DC.W 6       ;VIB LIMIT
 DC.W 4       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)
 DC.B 15,15,14,14,13,13,12,11,10,9,8,7
 DC.B 6,6,7,7,8,8,7,7,7,6,6,7,7,6,6,7,6,6

 REPT 10
 DC.B 14
 ENDR




 EVEN
TE2 DC.W 2,3




MAX DC.B 71,32,87,72,69,65,84,79,78
DRI DC.B 251,0
MIN DC.B 0,0
MC DC.B 0,0
 EVEN
;-----------MUSIC DATA


DRSM
 dc.w 28,4+768
 DC.W 0,28+1024

 dc.w 8,4+768
 DC.W 0,28+1024

 dc.w 3,2+768
 DC.W 0,30+1024

 dc.w 4,4+768
 DC.W 0,28+1024

 dc.w 30,3+768
 DC.W 0,29+1024

 dc.w 4,4+768
 DC.W 0,28+1024

 dc.w 24,2+768
 DC.W 0,30+1024

 dc.w 1,32+768

 DC.W $FFFF,$FFFF


DRTM
 dc.w 28,4+768
 DC.W 0,28+1024

 dc.w 8,4+768
 DC.W 0,28+1024

 dc.w 3,2+768
 DC.W 0,30+1024

 dc.w 4,4+768
 DC.W 0,28+1024

 dc.w 30,3+768
 DC.W 0,29+1024

 dc.w 4,4+768
 DC.W 0,28+1024

 dc.w 24,2+768
 DC.W 0,30+1024

 dc.w 8,4+768
 dc.w 7,4+768
 dc.w 6,4+768
 dc.w 5,4+768
 dc.w 4,8+768
 ;dc.w 3,4+768
 dc.w 5,8+768
 ;dc.w 7,4+768

 DC.W $FFFF,$FFFF



NULL DC.W 2,128+2304
 DC.W $FFFF,$FFFF



u=8

octb
 dc.w 144*u,8,72*u,8 
 dc.w 144*u,8,72*u,8 
 dc.w 144*u,8,72*u,8 
 dc.w 144*u,8,72*u,8 
 dc.w 144*u,8,72*u,8 
 dc.w 144*u,8,72*u,8 
 dc.w 144*u,8,72*u,8 
 dc.w 144*u,8,72*u,8 
 dc.w 162*u,8,81*u,8 
 dc.w 162*u,8,81*u,8 
 dc.w 162*u,8,81*u,8 
 dc.w 162*u,8,81*u,8 
 dc.w 162*u,8,81*u,8 
 dc.w 162*u,8,81*u,8 
 dc.w 162*u,8,81*u,8 
 dc.w 162*u,8,81*u,8 
 dc.w 217*u,8,108*u,8 
 dc.w 217*u,8,108*u,8 
 dc.w 217*u,8,108*u,8 
 dc.w 217*u,8,108*u,8 
 dc.w 217*u,8,109*u,8 
 dc.w 217*u,8,108*u,8 
 dc.w 217*u,8,108*u,8 
 dc.w 217*u,8,108*u,8 
 dc.w $ffff,$ffff

j=8
bass
 dc.w 144*j,8
 dc.w 144*j,8
 dc.w 0,24
 dc.w 193*j,8
 dc.w 162*j,8
 dc.w 193*j,8
 dc.w 144*j,8
 dc.w 0,8
 dc.w 128*j,8
 dc.w 0,8
 dc.w 144*j,8
 dc.w 162*j,16
 dc.w 144*j,8
 dc.w 162*j,8
 dc.w 162*j,8
 dc.w 0,24

 dc.w 217*j,8
 dc.w 193*j,8
 dc.w 217*j,8
 dc.w 162*j,8
 dc.w 0,8
 dc.w 144*j,8
 dc.w 0,8
 dc.w 162*j,8
 dc.w 193*j,16
 dc.w 162*j,8
 dc.w 217*j,8
 dc.w 217*j,8
 dc.w 0,24
 
 dc.w 217*j,8
 dc.w 193*j,8
 dc.w 217*j,8
 dc.w 162*j,8
 dc.w 0,8
 dc.w 144*j,8
 dc.w 0,8
 dc.w 162*j,8
 dc.w 144*j,16
 dc.w 162*j,8
 dc.w 144*j,8
 dc.w 144*j,8
 dc.w 0,48
 dc.w 0,64
 dc.w $ffff,$ffff

i=1
pian
 dc.w 0,64+64*2
 dc.w 108*i,4
 dc.w 102*i,4
 dc.w 96*i,6
 dc.w 47*i,2
 dc.w 96*i,6
 dc.w 47*i,2
 dc.w 96*i,6
 dc.w 47*i,2
 dc.w 96*i,6
 dc.w 47*i,2
 dc.w 96*i,6
 dc.w 47*i,2
 dc.w 96*i,6
 dc.w 47*i,2

 dc.w 53*i,3
 dc.w 108*i,5

 dc.w 0,255+2304
 dc.w $ffff,$ffff


blond
 dc.w 144*2,128+1536
 dc.w 162,1
 dc.w 162*2,127+1536
 dc.w 217,1
 dc.w 217*2,127+1536
 dc.w 144,1
 dc.w 144*2,127+1536
 dc.w $ffff,$ffff
p=4
pp=2
g=1536
dit
 dc.w 144*P,128+G
 DC.W 162*P,56+G

 dc.w 144*pp,4
 dc.w 136*pp,4
 dc.w 128*pp,8
 dc.w 144*pp,8
 dc.w 162*pp,8
 dc.w 193*pp,8
 dc.w 217*pp,8
 dc.w 243*pp,8
 dc.w 288*pp,8
 dc.w 2*162*pp,8
; dc.w 108*p,64+g

 DC.W 144*8,255+2816

 dc.w 288*p,255+g
 dc.w $ffff,$f fff

blondi
 dc.w 144*2,112+1536

 dc.w 148*2,4+1536
 dc.w 152*2,2+1536
 dc.w 153*2,8+1536
 dc.w 154*2,2+1536
 dc.w 158*2,4+1536

 dc.w 162*2,128+1536
 dc.w 217*2,120-32+1536
 dc.w 162,1+1536
 dc.w 162*2,11+1536
 dc.w 144*2,16+1536
 dc.w 162*2,8+1536
 dc.w 144*2,128-16+1536
 dc.w 164*2,2+1536
 dc.w 184*2,2+1536
 dc.w 204*2,2+1536
 dc.w 224*2,2+1536
 dc.w 244*2,2+1536
 dc.w 264*2,2+1536
 dc.w 284*2,2+1536
 dc.w 304*2,2+1536
 dc.w $ffff,$ffff

X=2
O=1792
GIT
 DC.W 0,255
 dc.w 0,64+2304

 dc.w 193*X,4+O
 dc.w 144*X,4+O
 dc.w 108*X,4+O
 dc.w 121*X,8+O
 dc.w 144*X,8+O
 dc.w 162*X,16+O
 dc.w 193*X,16+O
 dc.w 144*X,120+O
 dc.w 154*X,1+O
 dc.w 164*X,1+O
 dc.w 174*X,1+O
 dc.w 184*X,1+O
 dc.w 194*X,1+O
 dc.w 212*X,1+O
 dc.w 222*X,1+O
 dc.w 232*X,1+O
 dc.w 242*X,1+O
 dc.w 262*X,1+O
 dc.w 272*X,1+O
 dc.w 282*X,1+O

 dc.w $ffff,$ffff

gt1
 DC.W 0,255
 dc.w 121,1
 dc.w 121,1
 dc.w 121,1
 dc.w 121,1
 dc.w 121,1
 dc.w 121,1
 dc.w 120,1
 dc.w 119,1
 dc.w 118,1
 dc.w 117,1
 dc.w 116,1
 dc.w 115,1
 dc.w 114,1
 dc.w 113,1
 dc.w 112,1
 dc.w 111,1
 dc.w 110,1
 dc.w 109,1
 dc.w 108,64-18+1792
 dc.w 108,58+1792

 dc.w 118,2+1792
 dc.w 128,2+1792
 dc.w 138,2+1792

 dc.w 144,128-40+1792
 dc.w 154,1+1792
 dc.w 174,1+1792
 dc.w 194,1+1792
 dc.w 224,1+1792
 dc.w 254,1+1792
 dc.w 274,1+1792
 dc.w 288,1+1792
 dc.w 310,1
 dc.w 340,1
 dc.w 374,1
 dc.w 404,1
 dc.w 434,1
 dc.w 464,1
 dc.w 534,1
 dc.w 634,1
 dc.w 734,1
 dc.w 834,1
 dc.w 934,1
 dc.w 1434,1
 dc.w 1834,1
 dc.w 2034,1
 dc.w 3434,1+2816
 dc.w 4000,61

 dc.w 0,255 


DRM
 DC.W 0,32+1024

 dc.w 2,1+768,8,3+768
 DC.W 0,28+1024

 dc.w $ffff,$ffff


K=512
N=1
JIV
 DC.W 144*N,8+K
 DC.W 144*N,8+K
 DC.W 144*N,8+K
 DC.W 162*N,8+K
 DC.W 0,8+2304
 DC.W 144*N,8+K
 DC.W 0,8+2304
 DC.W 162*N,8+K
 DC.W 144*N,8+K
 DC.W 144*N,8+K
 DC.W 144*N,8+K
 DC.W 162*N,24+K
 DC.W 0,16+2304
 ;DC.W 144*N,8+K
 ;DC.W 0,8+2304
 ;DC.W 144*N,8+K

 DC.W 162*N,8+K
 DC.W 162*N,8+K
 DC.W 162*N,8+K
 DC.W 182*N,8+K
 DC.W 0,8+2304
 DC.W 162*N,8+K
 DC.W 0,8+2304
 DC.W 182*N,8+K
 DC.W 162*N,8+K
 DC.W 162*N,8+K
 DC.W 162*N,8+K
 DC.W 182*N,8+K
 DC.W 0,8+2304
 DC.W 162*N,8+K
 DC.W 0,8+2304
 DC.W 162*N,8+K

 DC.W 108*N,8+K
 DC.W 108*N,8+K
 DC.W 108*N,8+K
 DC.W 121*N,8+K
 DC.W 0,8+2304
 DC.W 108*N,8+K
 DC.W 0,8+2304
 DC.W 121*N,8+K
 DC.W 108*N,8+K
 DC.W 108*N,8+K
 DC.W 108*N,8+K
 DC.W 121*N,8+K
 DC.W 0,8+2304
 DC.W 108*N,8+K
 DC.W 0,8+2304
 DC.W 108*N,8+K

 DC.W $FFFF,$FFFF


DRIFT
 DC.W 0,255+2304
 DC.W 0,128+2304
 DC.W 144*4,255+2816

r=512
b=4
tron
 dc.w 144*8,128+3584
 dc.w 162*8,64+15*256

 dc.w 217*8,64+r
 dc.w 108*2,64+r
 dc.w 96*2,32+r
 dc.w 60*2,32+r
 dc.w 144*2,120+r

 dc.w $ffff,$ffff

gd 
   dc.w 0,128+32+32+2304
   dc.w 162*4,8+g
   dc.w 0,8+2304
   dc.w 217*4,8+g
   dc.w 0,96+8+2304
   dc.w 108*2,12+g
   dc.w 0,4+2304
   dc.w 144*4,12+g
   dc.w 0,128-24+2304
   dc.w 144*2,8+g
   dc.w 0,8+2304
   dc.w 196*2,8+g
 dc.w $ffff,$ffff




name	dc.b "a:\*.pi1",0