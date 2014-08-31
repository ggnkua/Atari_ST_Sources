; this is Gary Wheaton music driver
; the tune will play during the vertical blank.
; the slot chosen in the v/b queue is fairly high up
; which means that it is immune from interference
; this code is copyright Gary Wheaton  Nov 1989
; Gary Wheaton and the Shapeshifters are members
; of the Budgie UK group.
; Budgie UK Licenceware: the fairer face of PD
	MOVE.L A7,A5		startup sequence: give all
	MOVE.L 4(A5),A5		un -necessary memory back to gem
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



********

	MOVE.L SUPER,-(SP)	back to user mode
	MOVE.W #$20,-(SP)
	TRAP #1
	ADDQ.L #6,SP

	MOVE.W #0,-(SP)		goodbye: quit but stay
	MOVE.L #1024*6,-(SP)
	MOVE.W #$31,-(SP)
	TRAP #1


R EQU 2
J EQU 8
I EQU 2
C EQU 16
W EQU 1
X EQU 2
T EQU 4
Q EQU 1
Z EQU 4
U EQU 8
O EQU 2
SL EQU $FF8800
SD EQU $FF8802

; this is the actual routine.
vbi             
	movem.l d0-d7/a0-a6,-(sp)	prevent corruption

;	lea	$fffc00,a1		keyboard acia
;	cmp.b	#$61,2(a1)		undo ?
;	beq	end_it
;;	cmp.b	#$62,2(a1)		help ?
;	beq	on_off

	lea	$200,a0
	tst.l	(a0)
	beq	quiet

 TST.B FL
 BEQ PPP
 MOVE.B #7,SL
 MOVE.B #%11000000,SD
 MOVE.B #1,FL
PPP
;\\\\\\\\\\\\\
 MOVE.L UPTO,A2
SSU TST FBRA
 BPL WELLS


 MOVE.L #$08000000,SL
 MOVE.L #$09000000,SL
 MOVE.L #$0A000000,SL
 MOVE.L #1,PNT0
 MOVE.L #1,PNT1
 MOVE.L #1,PNT2
 MOVE.L #1,PNT3
 MOVE.L #1,PNT4



 MOVE 34(A2),FBRA
WELLS MOVE.B 33(A2),D4
PART1 CLR.B D2

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
W2 MOVE.B #1,D2
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
W4 
 SUBQ.W #1,FBRA
 BPL.S TTH
 ADD.L #36,UPTO
 CMP.L #CHAN0,UPTO
 BLT TTH
 MOVE.L #DOTH,UPTO

TTH
	movem.l (sp)+,d0-d7/a0-a6
	rts
end_it
;	bclr	#6,$fffa11	acknowledge key press interrupt
	lea	$ff8800,a0
	move.b	#7,(a0)		cut out sound chip
	move.b	#%11111111,2(a0)
	move.l	#0,$4de		end interrupt
	movem.l (sp)+,d0-d7/a0-a6  restore all registers
 	rts
on_off	bclr	#6,$fffa11	
	not.l	$200		toggle on/off
	lea	$ff8800,a0
	move.b	#7,(a0)
	move.b	#%11111111,2(a0)
	movem.l (sp)+,d0-d7/a0-a6
 	rts

quiet	movem.l (sp)+,d0-d7/a0-a6
	rts
	even


 DC.B "  G.WHEATON. 45 GOLDRILL AVE, BOLTON, LANCS, U.K. "
;EVEN



super 	dc.l 	0
handle	dc.w	0,0
hit	dc.b	0,0
name	dc.b	"title2.pi1",0
	even
res	dc.w 0
palette ds.w 16
dosound
	movem.l	a0-a6/d0-d6,-(sp)
	MOVE.L	A0,-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#14                     
	ADDQ.L	#6,SP
	movem.l	(sp)+,a0-a6/d0-d6
	RTS
	EVEN
silence
	DC.B 0,0,1,0,2,0,3,0,4,0,5,0,6,0,7,0,8,0
	DC.B 9,0,10,0,11,0,12,0,13,0,14,0,15,0,255,0
**************************




;\\SEQUENCE
DOTH
 DC.L PNT0,_NOTE2
 DC.L PNT1,_NOTE2
 DC.L PNT2,_NOTE2
 DC.L PNT3,DRMM
 DC.B 1,%00001100
 DC.W 511
 DC.L PNT0,_NOTE2+4
 DC.L PNT1,_NOTE2+8
 DC.L PNT2,_NOTE2
 DC.L PNT3,DRMM
 DC.B 1,%00011111
 DC.W 511
 DC.L PNT0,_NOTE2+8
 DC.L PNT1,_NOTE2+4
 DC.L PNT2,_NOTE2
 DC.L PNT3,DRMM
 DC.B 2,%00011111
 DC.W 511
 DC.L PNT0,_NOTE0
 DC.L PNT1,TUNE2
 DC.L PNT2,_NOTE2
 DC.L PNT3,DRMM
 DC.B 3,%00011111
 DC.W 511
 DC.L PNT0,_NOTE0
 DC.L PNT1,_NOTE1
 DC.L PNT2,_NOTE2
 DC.L PNT3,DRMM
 DC.B 1,%00011111
 DC.W 511
 DC.L PNT0,GE0
 DC.L PNT1,GE1
 DC.L PNT2,GE2
 DC.L PNT3,DRMM
 DC.B 2,%00011111
 DC.W 511
 DC.L PNT0,GE0
 DC.L PNT1,TUNE
 DC.L PNT2,GE2
 DC.L PNT3,DRMM
 DC.B 3,%00001111
 DC.W 511
 DC.L PNT0,_NOTE0
 DC.L PNT1,TUNE2
 DC.L PNT2,_NOTE2
 DC.L PNT3,DRMM
 DC.B 7,%00111111
 DC.W 511
 DC.L PNT0,_NOTE0
 DC.L PNT1,XX1
 DC.L PNT2,_NOTE2
 DC.L PNT3,DRMM
 DC.B 12,%00011111
 DC.W 511
 DC.L PNT0,GE0
 DC.L PNT1,TUNE
 DC.L PNT2,GE2
 DC.L PNT3,DRMM
 DC.B 1,%00011111
 DC.W 511
 DC.L PNT4,N5
 DC.L PNT1,N5
 DC.L PNT2,N5
 DC.L PNT3,DRMM
 DC.B 1,%00011111
 DC.W 127
 DC.L PNT4,N1
 DC.L PNT1,N0
 DC.L PNT2,N0+4
 DC.L PNT3,DRMM
 DC.B 1,%00011111
 DC.W 511
 DC.L PNT4,N3
 DC.L PNT1,N0
 DC.L PNT2,N0+4
 DC.L PNT3,DRMM
 DC.B 2,%00011111
 DC.W 511
 DC.L PNT4,N5
 DC.L PNT1,N5
 DC.L PNT2,N5
 DC.L PNT3,DRMM
 DC.B 0,%00011011
 DC.W 127
 DC.L PNT4,N0+4
 DC.L PNT1,N0
 DC.L PNT2,N0
 DC.L PNT3,DRMM
 DC.B 0,%00011101
 DC.W 511
 DC.L PNT4,N5
 DC.L PNT1,N5
 DC.L PNT2,N5
 DC.L PNT3,DRMM
 DC.B 0,%00011101
 DC.W 127
 DC.L PNT2,N0
 DC.L PNT0,N0
 DC.L PNT1,N2
 DC.L PNT3,DRMM
 DC.B 0,%00011111
 DC.W 511
 DC.L PNT4,N5
 DC.L PNT1,N5
 DC.L PNT2,N5
 DC.L PNT3,DRMM
 DC.B 0,%00011111
 DC.W 511
 DC.L PNT4,LOWB
 DC.L PNT1,LOWB
 DC.L PNT2,LOWB
 DC.L PNT3,DRMM
 DC.B 2,%00011111
 DC.W 127
;DOTH
 DC.L PNT1,GE2+4
 DC.L PNT0,GE2
 DC.L PNT2,GE2
 DC.L PNT3,DRMM
 DC.B 3,%00011011
 DC.W 1023+511
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
 SUB.B #1,3(A1)    ;NP0
 BNE STILLON
 MOVE.L D1,6(A1) ;TMP0 \D1.W IS DURATION
 MOVE.L D1,20(A1);TEMP HOLD NOTE
 MOVE.B 26(A1),4(A1)  ;VOL0
 MOVE D1,2(A1)   ;NP0  \SET NEW DURATION
 ADD #4,(A1)     ;& INC POINTER
STILLON
;\\VOLUME
RFF
;\\\\\\\\\EFFECTS\\\\\\\\\\
NV0 MOVE.B 2(A1),D0
 CMP.B #4,D0
 BNE DOIT
 ADDQ.B #1,4(A1)
 RTS
DOIT TST.B D2
 BEQ FCC
 CMP.B #3,D0
 BNE DZZ
 BSR DRUM
 BRA.S FCC
DZZ
 MOVE.B #7,SL
 MOVE.B #%11111000,SD
FCC
 CMP.B #1,D0
 BNE EF1
 BSR VIB
 BRA HOV
EF1 CMP.B #2,D0
 BNE EF2
 BSR WARB
 BRA HOV
EF2
 CMP.B #4,D0
 BNE.S HOV
 BRA HOLD
HOV
 ADDQ.B #1,4(A1)          ;VOL0
HOLD
 MOVE.B 11(A1),SL
 MOVE.B 21(A1),SD   ;TMP0+1
 MOVE.B 12(A1),SL
 MOVE.B 20(A1),SD   ;TMP0
 CLR D0
 MOVE.B 4(A1),D0
 MOVE.B 10(A1),SL
 MOVE.B 28(A1,D0),SD    ;VOL0
FINK RTS
SSV DC.L 0
;1\\\\\\\\\VIBRATO\\\\\\\\\\\\\\
VIB
 CMP.B #9,4(A1)
 BLT SDC
;SUB.B #1,4(A1)
 SUB.B #1,24(A1)
 BNE SDC
 MOVE.B 25(A1),24(A1)
 MOVE 16(A1),D0
 ADD D0,18(A1)
 MOVE 14(A1),D0
 CMP 18(A1),D0
 BGT KJ
 NEG 16(A1)
 BRA SAZ
KJ NEG D0
 CMP 18(A1),D0
 BLT SAZ
 NEG 16(A1)
SAZ MOVE 6(A1),D0
 ADD 18(A1),D0
 MOVE D0,20(A1)
SDC RTS
;2\\\\\\\\\\\WARB\\\\\\\\\\\\\\\
WARB
 EOR.B #1,MIN
 BEQ SAX
 SUB.B #1,4(A1)

SAX 
 LSR 20(a1)
 BNE PLOP
 move 6(a1),20(a1) 
PLOP 
 RTS
;3\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
DRUM
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
 RTS
;\\\\\\\\\\\\\DATAS\\\\\\\\\\\\\\\
;\\NOTE 1ST WORD. DURATION 2ND WORD
;\\POINTERS TO NOTES MUST INC BY 4
;\\\LEAD
PNT0 DC.W 0
NP0 DC.W 1
 DC.W 0
 DC.L 0
 DC.B 8,0,1
 DC.B 1      ;ADD TO NOTE
 DC.W 6      ;VIB LIMIT
 DC.W 2      ;16(A1)  ADD
 DC.W 0      ;VIB 18(A1)
 DC.L 0      ;TMP NOTE 20(A1)
 DC.B 1,1    ;VIB RATE 24(A1)
 DC.B 0,0    ;INITIAL VOL
;ADSR  28(A1)
 DC.B 15,15,14,13,12,11,9,8,9
 DC.B 10,12,10,8,10,12,10,8,10,10
 DC.B 11,10,10,9,8,7,5,5,6,7,7
 DS.B 80
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
 DC.B 15,15,15,15,14,14,13,13,12,12
 DC.B 11,11,11,11,10,10,10,10,10,10
 DC.B 12,12,11,11,10,9,8,7,9,7,10,7,11,10,10,9,10
 DS.B 90
 EVEN
;\\\BASS
PNT2 DC.W 0
 DC.W 1          ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,4,5     ;10(A1) VOL REG
 DC.B -2         ;ADD TO NOTE 13(A1)
 DC.W 6          ;VIB LIMIT
 DC.W 2          ;VIBRATO ADD 16(A1)
 DC.W 2       ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 2,2        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
ADSR
 DC.B 15,15,14,14,14,13,13,13,13,13
 DC.B 13,13,12,12,11,11,10,10,10,9
 DC.B 8,7,6,5,4,3,4,2,1
 DS.B 80
 EVEN
PNT3 DC.W 0
NP3 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,6,11    ;10(A1) VOL REG
 DC.B -1         ;DECAY  13(A1)
 DC.W 14         ;VIB LIMIT
 DC.W 4          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
 DC.B 15,15,15,14,13,12
 DC.B 11,10,9,8,0,0,0,0,0,0
 DC.B 0,0,0,0,0,0,0,0,0,0
 EVEN
PNT4 DC.W 0
NP4 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0
 DC.B 8,0,1      ;10(A1) VOL REG
 DC.B 0          ;ADD 13(A1)
 DC.W 4          ;VIB LIMIT
 DC.W 2          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1	 ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
 DC.B 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
 DC.B 13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13
 DC.B 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
 DC.B 9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9
 DC.B 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7

 EVEN
FL DC.B 0,0
 EVEN
_NOTE0
;Dm
 DC.W 108*Q,8,91*Q,8,72*Q,8,53*Q,8
 DC.W 72*Q,8,91*Q,8,53*Q,8
 DC.W 72*Q,8,40*Q,8,53*Q,8,72*Q,8
 DC.W 40*Q,8,45*Q,8,91*Q,8,72*Q,8
 DC.W 45*Q,8
;F
 DC.W 91*Q,8,72*Q,8,60*Q,8
 DC.W 45*Q,8,60*Q,8,72*Q,8,53*Q,8
 DC.W 72*Q,8
 DC.W 40*Q,8,53*Q,8,72*Q,8
 DC.W 40*Q,8
 DC.W 45*Q,8,91*Q,8,72*Q,8,45*Q,8
;G
 DC.W 81*Q,8,64*Q,8,53*Q,8
 DC.W 40*Q,8,53*Q,8,64*Q,8,47*Q,8
 DC.W 64*Q,8
 DC.W 35*Q,8,47*Q,8,64*Q,8
 DC.W 35*Q,8
 DC.W 40*Q,8,81*Q,8,64*Q,8,40*Q,8
;Dm
 DC.W 108*Q,8,91*Q,8,72*Q,8,53*Q,8
 DC.W 72*Q,8,91*Q,8,53*Q,8
 DC.W 72*Q,8,40*Q,8,53*Q,8,72*Q,8
 DC.W 40*Q,8,45*Q,8,91*Q,8,72*Q,8
 DC.W 45*Q,8
 DC.W $FFFF,$FFFF,0
_NOTE2    ;BASS
;D
 DC.W 217*U,24+256,217*U,8,217*U,24
 DC.W 217*U,16,217*U,16
 DC.W 217*U,8,217*U,8,144*U,8
 DC.W 217*U,8
;DC.W $FFFF,$FFFF
;F
 DC.W 193*U,8,182*U,24,182*U,8
 DC.W 182*U,24
 DC.W 182*U,16,182*8,16
 DC.W 182*U,8,182*U,8,121*U,8
 DC.W 182*U,8
;G
 DC.W 172*U,8,162*U,24,162*U,8
 DC.W 162*U,24
 DC.W 162*U,16,162*U,16
 DC.W 162*U,8,162*U,8,108*U,8
 DC.W 162*U,8,182*U,8
;D
 DC.W 217*U,24,217*U,8,217*U,24
 DC.W 217*U,16,217*U,16
 DC.W 217*U,8,217*U,8,288*U,8
 DC.W 243*U,8
 DC.W 230*U,8
 DC.W $FFFF,$FFFF
_NOTE1     ;LEAD TUNE
 DC.W 0,16,91*Z,16,91*Z,8,96*Z,8,108*Z,8,96*Z,16,91*Z,24+256
 DC.W 45*T,8+512,40*T,8+512,36*T,8+512,31*T,8+512,30*T,16+512
 DC.W 91*Z,16,91*Z,8,96*Z,8,108*Z,8,121*Z,72+256
 DC.W 0,16,108*Z,16,108*Z,8,121*Z,8,128*Z,8,121*Z,16,108*Z,56+256
 DC.W 91*Z,16,96*Z,16,108*Z,96+256
 DC.W $FFFF,$FFFF
XX1     ;LEAD TUNE
 DC.W 0,16,91*Z,16,91*Z,8,96*Z,8,108*Z,8,96*Z,16,91*Z,24+256
 DC.W 45*R,8,40*R,8,36*R,8,31*R,8,30*R,16
 DC.W 91*Z,16,91*Z,8,96*Z,8,108*Z,8,121*Z,72+256
 DC.W 0,16,108*Z,16,108*Z,8,121*Z,8,128*Z,8,121*Z,16,108*Z,56+256
 DC.W 91*Z,16,96*Z,16,108*Z,96+256
 DC.W $FFFF,$FFFF
TUNE2     ;LEAD TUNE
 DC.W 0,16,91*Z,16,91*Z,8,96*Z,8,108*Z,8,96*Z,16,91*Z,24+256
 DC.W 0,48
 DC.W 91*Z,16,91*Z,8,96*Z,8,108*Z,8,121*Z,72+256
 DC.W 0,16,108*Z,16,108*Z,8,121*Z,8,128*Z,8,121*Z,16,108*Z,56+256
 DC.W 91*Z,16,96*Z,16,108*Z,96+256
 DC.W $FFFF,$FFFF
;\\\\\\\\\SECT2
GE0
;Am
 DC.W 91*W,8,72*W,8,60*W,8,45*W,8
 DC.W 60*W,8,72*W,8,53*W,8,72*W,8
 DC.W 40*W,8,53*W,8,72*W,8,40*W,8
 DC.W 45*W,8,91*W,8,72*W,8,45*W,8
;G
 DC.W 81*W,8,72*W,8,60*W,8,45*W,8
 DC.W 60*W,8,72*W,8,53*W,8,72*W,8
 DC.W 40*W,8,53*W,8,72*W,8,40*W,8
 DC.W 45*W,8,91*W,8,72*W,8,45*W,8
;Dm
 DC.W 108*W,8,91*W,8,72*W,8,53*W,8
 DC.W 72*W,8,91*W,8,53*W,8,72*W,8
 DC.W 40*W,8,53*W,8,72*W,8,40*W,8
 DC.W 45*W,8,91*W,8,72*W,8,45*W,8
 DC.W 108*W,8,91*W,8,72*W,8,53*W,8
 DC.W 72*W,8,91*W,8,53*W,8,72*W,8
 DC.W 40*W,8,53*W,8,72*W,8,40*W,8
 DC.W 45*W,8,91*W,8,72*W,8,45*W,8
 DC.W $FFFF,$FFFF,0

gee2
 dc.w 0,8
GE2    ;BASS
;Am
 DC.W 144*U,24,144*U,8,144*U,24
 DC.W 144*U,16,144*U,16
 DC.W 144*U,8,144*U,8,96*U,16
 DC.W 144*U,8
;G
 DC.W 162*U,24,162*U,8,162*U,24
 DC.W 162*U,16,162*8,16
 DC.W 162*U,8,162*U,8,108*U,8
 DC.W 182*U,8,121*U,8
;DC.W 162*U,8
;D
 DC.W 217*U,24,217*U,8,217*U,24
 DC.W 217*U,16,217*U,16
 DC.W 217*U,8,217*U,8,144*U,16
 DC.W 182*U,8
;D
 DC.W 217*U,24,217*U,8,217*U,24
 DC.W 217*U,16,217*U,16
 DC.W 217*U,8,217*U,8,144*U,16
 DC.W 217*U,8
 DC.W $FFFF,$FFFF
GE1     ;LEAD TUNE
 DC.W 0,16,72*X,16,72*X,8,81*X,8,91*X,8
 DC.W 81*X,16,72*X,56
 DC.W 0,16,81*X,16,81*X,8,91*X,8,96*X,8
 DC.W 81*X,72
 DC.W 0,16,91*X,16,91*X,8,96*X,8,108*X,8
 DC.W 96*X,16,91*X,56
 DC.W 0,16,91*X,16,91*X,8,96*X,8,121*X,8
 DC.W 108*X,72
 DC.W $FFFF,$FFFF
TUNE     ;LEAD TUNE
 DC.W 0,16,72*X,8,72*X,8,72*X,8+256,81*X,8,91*X,8
 DC.W 81*X,16,72*X,56+256
 DC.W 0,16,81*X,8,81*X,8,81*X,8,91*X,8,96*X,8
 DC.W 81*X,72+256
 DC.W 0,16,91*X,8,91*X,8,91*X,8,96*X,8,108*X,8
 DC.W 96*X,16,91*X,56+256
 DC.W 0,16,91*X,8+256,81*X,8+256,91*X,8+256,96*X,8+256,121*X,8+256
 DC.W 108*X,72+256
 DC.W $FFFF,$FFFF
DRMM
 DC.W 0,16+1024,18,8+768
 DC.W 0,24+1024,20,8+768
 DC.W 0,8+1024
 DC.W $FFFF,$FFFF
N0
 DC.W 96*C,8,96*C,8,0,8
 DC.W 96*C,8,96*C,8,96*C,8,0,8
 DC.W 96*C,8
 DC.W 96*C,8,96*C,8,0,8
 DC.W 96*C,8,96*C,8,96*C,8,0,8
 DC.W 96*C,8
;
 DC.W 128*C,8,128*C,8,0,8
 DC.W 128*C,8,128*C,8,128*C,8,0,8
 DC.W 128*C,8
 DC.W 128*C,8,128*C,8,0,8
 DC.W 128*C,8,128*C,8,128*C,8,0,8
 DC.W 128*C,8
;
 DC.W 108*C,8,108*C,8,0,8
 DC.W 108*C,8,108*C,8,108*C,8,0,8
 DC.W 108*C,8
;
 DC.W 96*C,8,96*C,8,0,8
 DC.W 96*C,8,96*C,8,96*C,8,0,8
 DC.W 96*C,8
;
 DC.W 108*C,8,108*C,8,0,8
 DC.W 108*C,8,108*C,8,108*C,8,0,8
 DC.W 108*C,8
 DC.W 108*C,8,108*C,8,0,8
 DC.W 108*C,8,108*C,8,108*C,8,0,8
 DC.W 108*C,8
 DC.W $FFFF,$FFFF
N2
 DC.W 47*I,8,64*I,16+256,96*I,8
 DC.W 47*I,8,64*I,16+256,96*I,8
 DC.W 47*I,8,64*I,16+256,96*I,8
 DC.W 47*I,8,64*I,16+256,96*I,8
 DC.W 64*I,8,85*I,16+256,128*I,8
 DC.W 64*I,8,85*I,16+256,128*I,8
 DC.W 64*I,8,85*I,16+256,128*I,8
 DC.W 64*I,8,85*I,16+256,128*I,8
 DC.W 53*I,8,72*I,16+256,108*I,8
 DC.W 53*I,8,72*I,16+256,108*I,8
 DC.W 47*I,8,64*I,16+256,96*I,8
 DC.W 47*I,8,64*I,16+256,96*I,8
 DC.W 53*I,8,72*I,16+256,108*I,8
 DC.W 53*I,8,72*I,16+256,108*I,8
 DC.W 53*I,8,72*I,16+256,108*I,8
 DC.W 53*I,8,72*I,16+256,108*I,8
 DC.W $FFFF,$FFFF
N1
 DC.W 96*Q,96+512,0,8
 DC.W 96*Q,8+512
 DC.W 108*Q,8+512,114*Q,8+512
 DC.W 128*Q,128+512             ;256
 DC.W 108*Q,64+512
 DC.W 96*Q,32+512,108*Q,16+512
 DC.W 114*Q,16+512,108*Q,96+32+512
 DC.W $FFFF,$FFFF
N3
 DC.W 96*Q,96+256,0,8
 DC.W 96*Q,8+256
 DC.W 108*Q,8+256,114*Q,8+256
 DC.W 128*Q,128+256             ;256
 DC.W 108*Q,64+256
 DC.W 128*Q,32+256,144*Q,16+256
 DC.W 128*Q,16+256,108*Q,96+32+256
 DC.W $FFFF,$FFFF
N5
 DC.W 144*J,8,96*J,8
 DC.W 144*J,8,162*J,8
 DC.W 144*J,8,96*J,8
 DC.W 144*J,8,162*J,8
 DC.W 144*J,8,96*J,8
 DC.W 144*J,8,162*J,8
 DC.W 144*J,8,96*J,8
 DC.W 144*J,8,162*J,8
 DC.W 128*J,8,85*J,8
 DC.W 128*J,8,144*J,8
 DC.W 128*J,8,85*J,8
 DC.W 128*J,8,144*J,8
 DC.W 128*J,8,85*J,8
 DC.W 128*J,8,144*J,8
 DC.W 128*J,8,85*J,8
 DC.W 128*J,8,144*J,8
 DC.W 108*J,8,72*J,8
 DC.W 108*J,8,121*J,8
 DC.W 108*J,8,72*J,8
 DC.W 108*J,8,121*J,8
 DC.W 96*J,8,64*J,8
 DC.W 96*J,8,108*J,8
 DC.W 96*J,8,64*J,8
 DC.W 96*J,8,108*J,8
LOWB
 DC.W 217*J,8,144*J,8
 DC.W 217*J,8,243*J,8
 DC.W 217*J,8,144*J,8
 DC.W 217*J,8,243*J,8
 DC.W 217*J,8,144*J,8
 DC.W 217*J,8,243*J,8
 DC.W 217*J,8,144*J,8
 DC.W 217*J,8,243*J,8
 DC.W $FFFF,$FFFF
MIN DC.B 1,0
UPTO DC.L DOTH
FBRA DC.W -1
DED

