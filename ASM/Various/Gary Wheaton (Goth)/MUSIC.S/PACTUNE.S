SL EQU $FF8800
SD EQU $FF8802
 

 CLR.L -(SP)       ; Enter supervisor mode.
 MOVE.W #$20,-(SP) ; Super.
 TRAP #1
 ADDQ.L #6,SP
 MOVE.L D0,SV

***********
 move.b #7,sl
 move.b #%11111000,sd

 move.b #13,sl
 move.b #0,sd

 move.l #$c000000,sl
 move.b #11,sl
 move.b #0,sd
***********




PLAY
 MOVE.B $469,D0
FT CMP.B $469,D0
 BEQ.S FT

 BSR VBI

 CMP.B #97,$FFFC02
 BNE PLAY

;X
 move.l #$8000000,sl
 move.l #$9000000,sl
 move.l #$a000000,sl

 MOVE.L SV,-(SP)
 MOVE #$20,-(SP)
 TRAP #1
 ADDQ.L #6,SP
 
 CLR -(SP)
 TRAP #1










ty = 3584
e equ 2
J EQU 8
I EQU 4
H EQU 2
T EQU 4
A EQU 2
Z EQU 4
f EQU 8
d=16


VBI  movem.l d0-d3/a0-a2,-(sp)



;\\\\\\\\\\\\\
 MOVE.L UPTO,A2
 MOVE CUNT,D3
 MOVE.B 33(A2),D4
SSU SUBQ.W #1,D3
 BPL.S PART1
 MOVE.L #1,PNT0
 MOVE.L #1,PNT1
 MOVE.L #1,PNT2
 MOVE.L #1,PNT3
 MOVE.L #1,PNT4
 MOVE.L #1,PNT5
 MOVE.L #$8000000,SL

 ADD.L #36,a2
 CMP.L #CHAN0,A2
 BNE.S LLA
 LEA DOTH,A2
LLA
 MOVE 34(A2),D3
 MOVE.B 33(A2),D4

PART1

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

W2 
 BTST #3,D4
 BEQ.S W3
 MOVE.L 16(A2),A1
 MOVE.L 20(A2),A0
 BSR CHAN0

W3 

 BTST #4,D4
 BEQ.S W4
 MOVE.L 24(A2),A1
 MOVE.L 28(A2),A0
 BSR CHAN0

W4 MOVE.L A2,UPTO
 MOVE D3,CUNT
;--END OF VBI
;--------EXIT





;--------BAR CHARTS


 movem.l (sp)+,d0-d3/a0-a2 
killer rts





SV DC.L 0

 DC.B " (C) G.WHEATON.  45 GOLDRILL AVE BOLTON. LANCS, U.K. "
 DC.B " by JIMI HENDRIX    G.W. 1989. "

UPTO DC.L doth-36
CUNT DC.W 0
 EVEN
;\\RUNNING ORDER SEQUENCE

DOTH

 DC.L PNT4,pacma
 DC.L PNT0,pb
 DC.L PNT2,pbass
 DC.L PNT3,sdum
 DC.B 0,%00011110
 DC.W 127

 DC.L PNT4,pacm1
 DC.L PNT0,pb1
 DC.L PNT2,pbass1
 DC.L PNT3,sdum
 DC.B 0,%00011110
 DC.W 127

 DC.L PNT4,pacm
 DC.L PNT0,pb ass
 DC.L PNT2,pbass bas1
 DC.L PNT3,sdum
 DC.B 0,%00011110
 DC.W 127

 DC.L PNT4,pacm2
 DC.L PNT0,pbass2
 DC.L PNT2,longbas
 DC.L PNT3,sdum
 DC.B 0,%00011110
 DC.W 127

 DC.L PNT4,null
 DC.L PNT0,null
 DC.L PNT2,null
 DC.L PNT3,sdum
 DC.B 0,%00001110
 DC.W 127



chan0
;\\\\\\\\\\\\\\\
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
 ;MOVE.B 26(A1),4(A1)   ;VOL0
 CLR.B 4(A1)
 MOVE D1,2(A1)   ;NP0  \SET NEW DURATION
 ADDQ.W #4,(A1)        ; & INC POINTER
STILLON
;\\VOLUME
RFF
;\\\\\\\\\EFFECTS\\\\\\\\\\
NV0 
 MOVE.B 2(A1),D0
 cmp.b #4,d0
 beq fink
DOIT 

 MOVE.B #7,SL
 MOVE.B #%11111000,SD
 BRA.S FCC
EFCT

 DC.L FINK,VIB,WARB,DRUM,FINK,WB1,WRP,SLW
 DC.L SLR,HOLD,TWERP,SLR1,inup,HOLDLOW,Half

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
 MOVE.B 28(A1,D0),SD    ;VOL0
FINK RTS

;-------EFFECTS ROUTINES--------
;1-256---DELAYED--VIBRATO-------
VV EOR.B #1,MC
 BEQ.S SDC
VIB CMP.B #8,4(A1)
 BLT SDC
wwq SUB.B #1,24(A1)
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
WARB
 eor.b #1,la
 beq.s WQ
 SUBQ.B #1,4(A1)

WQ 
 btst #2,$469
 beq wrp wq
 addq.b #1,4(a1)
 asl 20(A1)
 asl 20(A1)
 CMP #443,20(A1)
 BlT.S SAX
 move 6(a1),20(a1)
SAX  RTS


;PLOP rts BRA.S VV

la dc.b 0,0

;3--768--------DRUM-----------
DRUM 

 SUBQ.B #4,19(A1)
 MOVE.B #7,SL
 MOVE.B #%11011000,SD
 MOVE.B #6,SL
 MOVE.B 19(A1),SD
 MOVE.B #5,SL
 MOVE.B HERE+1,SD
 MOVE.B #4,SL
 MOVE.B 19(A1),D0

 asl.b #4,d0
 MOVE.B D0,SD
JUNK RTS

;-4--------DRUM OFF

;5--1280--WARB CONSTANT VOLUME
WB1 MOVE.B #5,4(A1)
 BRA.S JUNK

;6--1536-----WARB UP---------
WRP 
 ;MOVE.B #17,4(A1)
SDX LSR 20(A1)
 CMP #70,20(A1)
 BGT PLAP
 MOVE 6(A1),20(A1)
PLAP RTS

;7--1792---SLIDE-UP--WARBLE
SLW CMP.B #9,4(A1)
 BLT.S WRP
 ADDQ.W #2,6(A1)
 BRA.S WRP

;--2048---SLIDE UP CONST VOL 
SLR 
 clr.b 4(a1)
 bra wwq


YIN DC.B 0,0
;9--2304-------HOLD-------------
HOLD MOVE.B #99,4(A1)
 RTS

;10--2560---HIGH NOTE WARB------
TWERP 
 MOVE.B #17,4(A1)
 LSR 20(A1)
 CMP #8,20(A1)
 BGT TETSYFLY
 MOVE 6(A1),20(A1)
TETSYFLY BRA VV 

;11-------2816 SLIDE UP WITH ADSR
SLR1
 SUBQ.W #6,20(A1)
 RTS

;12-------3072  inc up
inup
 sub.b #1,nije
 bne.s pod
 sub.w #4,6(a1)
 move.b #5,nije
 sub.b #6,4(a1)
pod bra wrp rts

;13-------3328--HOLD VOL LOW
HOLDLOW
 MOVE.B #18,4(A1)
 BRA WWQ RTS 

;1--------3584 2* adsr
half
 ;ADD.B #150,nije+1
 ;bCC.s aslef
 addq.b #8,4(a1)
aslef rts



nije dc.b 1,0

;\\\\\\\\\\\\\\DATAS\\\\\\\\\\\\\\\
;\\NOTE 1ST WORD. DURATION 2ND WORD
;\\\LEAD
PNT0 DC.W 0
NP0 DC.W 1
 DC.W 0
 DC.L 0
 DC.B 9,2,3
 DC.B 1      ;ADD TO NOTE
 DC.W 14      ;VIB LIMIT
 DC.W 7      ;16(A1)  ADD
 DC.W 0      ;VIB 18(A1)
 DC.L 0      ;TMP NOTE 20(A1)
 DC.B 1,1    ;VIB RATE 24(A1)
 DC.B 0,0    ;INITIAL VOL
;ADSR  28(A1)

 DC.B 13,9,13,14,13
 DCB.B 8,12
 DCB.B 16,11
 DCB.B 16,10
 DCB.B 4,9
 DCB.B 24,8
 DCB.B 60,0


 EVEN
;\\\MIDDLE
PNT1 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 9,2,3
 DC.B 144       ;ADD  13(A1)
 DC.W 72      ;VIB LIMIT
 DC.W 2       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)
 DC.B 15,14,9,13,12,14,14,13,12,12
 DC.B 12,12,12,12

 DCB.B 64,10
 DCB.B 60,0

 EVEN
;\\\BASS
PNT2 DC.W 0
 DC.W 1          ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,4,5     ;10(A1) VOL REG
 DC.B 2          ;ADD TO NOTE 13(A1)
 DC.W 6          ;VIB LIMIT
 DC.W 2          ;VIBRATO ADD 16(A1)
 DC.W 2          ;VIB 18(A1)
HERE DC.L 0     ;TMP NOTE 20(A1)
 DC.B 2,2        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
ADSR
 DC.B 15,15,15,14,14,14,13,13,13,13,13
 DC.B 13,13,12,12,11,11,10,10,16,16

 DCB.B 64,10
 DCB.B 60,0

 EVEN
PNT3 DC.W 0
NP3 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,6,11    ;10(A1) VOL REG
 DC.B -1         ;ADD  13(A1)
 DC.W 10         ;VIB LIMIT
 DC.W 4          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
 DC.B 15,15,15,14,13,12
 DC.B 11,11,11,11,10
 DC.B 11,11,11,11,10
 

 EVEN
PNT4 DC.W 0
NP4 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0
 DC.B 8,0,1      ;10(A1) VOL REG
 DC.B 0          ;ADD 13(A1)
 DC.W 7          ;VIB LIMIT
 DC.W 5          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)

 DC.B 14,14,15,14,14,14,13,13
 dc.b 13,12,12,13,12,13,12,13,12,16,16
 REPT 8
 DC.B 11
 ENDR

 REPT 12
 DC.B 9
 ENDR

 REPT 8
 DC.B 7
 ENDR

 REPT 16
 DC.B 6
 ENDR

 REPT 16
 DC.B 5
 ENDR

 REPT 104
 DC.B 4
 ENDR

 EVEN
PNT5 DC.W 0
 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0
 DC.B 8,0,1      ;10(A1) VOL REG
 DC.B 1          ;ADD 13(A1)
 DC.W 144        ;VIB LIMIT
 DC.W 36         ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)

 dc.b 15,14,13,13,12,13,12,13,12,16,16

 DCB.B 8,10
 DCB.B 8,12
 DCB.B 8,11
 DCB.B 8,10
 DCB.B 8,9



TE2 DC.W 2,3





MIN DC.B 0,0
MC DC.B 0,0
;-----------MUSIC DATA



SDUM
 dc.w 8,16+1024
 dc.w 16,8+768
 dc.w 0,8+1024
 DC.W $FFFF,$FFFF

q=16
v=256

longbas
 dc.w 192*q,32+v
 dc.w 192*q,32+v
 dc.w 192*q,32+v
 dc.w 144*q,16+v
 dc.w 0,68+d
 DC.W $FFFF,$FFFF

riff
 dc.w 81,1+3328
 dc.w 81*h,3+3328
 dc.w 76*h,1+3328
 dc.w 72*h,3+3328
 DC.W $FFFF,$FFFF



null
 dc.w 2,255+2304
 DC.W $FFFF,$FFFF


bass 
 dc.w 144*q,16,72*q,8
 dc.w 72*q,8
 DC.W $FFFF,$FFFF

bas1 
 dc.w 144*q,16,72*q,8
 dc.w 2,8
 DC.W $FFFF,$FFFF



r=2
pacm  
 dc.w 144*r,8
 dc.w 0,8
 dc.w 96*r,8
 dc.w 0,8
 dc.w 114*r,16+256
 dc.w 144*r,8
 dc.w 0,8
 dc.w 96*r,8
 dc.w 114*r,8
 dc.w 0,8
 dc.w 144*r,40+256
 dc.w $ffff,$ffff

pacma  
 dc.w 144*r,8
 dc.w 0,8
 dc.w 96*r,8
 dc.w 0,8
 dc.w 114*r,16+256
 dc.w 144*r,8
 dc.w 0,8
 dc.w 96*r,8
 dc.w 114*r,8
 dc.w 0,8
 dc.w 144*r,32+256
 dc.w 144*r,6+aa
 dc.w 140*r,2+aa

pacm1
 dc.w 136*r,8
 dc.w 0,8
 dc.w 91*r,8
 dc.w 0,8
 dc.w 108*r,16
 dc.w 136*r,8
 dc.w 0,8
 dc.w 91*r,8
 dc.w 108*r,8
 dc.w 0,8
 dc.w 136*r,40+256
 dc.w $ffff,$ffff

pacm2
 dc.w 193*r,8+256
 dc.w 172*r,8+256
 dc.w 153*r,8+256
 dc.w 0,8

 dc.w 193*r,8
 dc.w 172*r,8
 dc.w 153*r,8
 dc.w 0,8
 
 dc.w 193*r,8
 dc.w 172*r,8
 dc.w 153*r,8
 dc.w 144*r,12

 dc.w 0,128

 dc.w $ffff,$ffff


pbass
 dc.w 144*16,16
 dc.w 144*8,8
 dc.w 144*8,8
 dc.w $ffff,$ffff


pbass1
 dc.w 136*16,8
 dc.w 136*8,8
 dc.w 136*4,8
 dc.w 136*8,8

 dc.w 136*16,8
 dc.w 68*16,8
 dc.w 33*16,8
 dc.w 68*8,8

 dc.w 136*16,8
 dc.w 68*16,8
 dc.w 33*16,8
 dc.w 68*8,8

 dc.w 136*16,24
 dc.w 136*16,8

 dc.w $ffff,$ffff

pbass2
 dc.w 193*8,16
 dc.w 193*4,8
 dc.w 193*4,8

 dc.w 193*8,16
 dc.w 193*4,8
 dc.w 193*4,8

 dc.w 193*8,8
 dc.w 170*8,8
 dc.w 153*8,16
 dc.w 144*8,16+256
 dc.w 0,16+d
 
 dc.w $ffff,$ffff


aa=2048

pb
 dc.w 72*2,128+aa
pb1
 dc.w 68*2,128+aa













