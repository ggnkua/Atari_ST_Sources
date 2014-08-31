 CLR.L -(SP)       
 MOVE.W #$20,-(SP) ; Super.
 TRAP #1
 ADDQ.L #6,SP
 MOVE.L D0,SV   ; Save old status.

play
******************
 move.b $469,d0  *
ww cmp.b $469,d0 *
 beq.s ww	 *
******************

; move.b #8,sl
; move.b #15,sd
; move.b #0,sl
; move.b #96,sd
; move.b #1,sl
; move.b #0,sd
 bsr vbi


 cmp.b #97,$fffc02
 bne play


	lea	$ff8800,a0	get sound chip 
	move.b	#7,(a0)
	move.b	#%11111111,2(a0) cut out lingering noise
	move.l #$8000000,$ff8800 
	move.l #$9000000,$ff8800 
	move.l #$a000000,$ff8800 


 MOVE.L SV,-(SP)
 MOVE.W #$20,-(SP)
 TRAP #1
 ADDQ.L #6,SP

 CLR -(SP)
 TRAP #1





*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


SL EQU $FF8800
SD EQU $FF8802
 move.b #7,sl
 move.b #%11111000,sd


 
VBI  

 movem.l d0-d3/a0-a6,-(sp)

 move.b $fffc02,d0
 cmp.b #68,d0
 bne.s saxa

 cmp.b flag+1,d0
 beq.s saxa

 eor.b #1,flag

saxa
 move.b d0,flag+1
 tst.b flag
 beq out


;\\\\\\\\\\\\\
 MOVE.L UPTO,A2
 MOVE CUNT,D3
 MOVE.B 33(A2),D4
SSU SUBQ.W #1,D3
 BPL.S PART1

COP
 MOVE.L #1,PNT0
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
;--END OF VBI
;--------EXIT


out





 movem.l (sp)+,d0-d3/a0-a6 
killer rts


flag dc.b 1,1
SV DC.L 0

 DC.B " (C) G.WHEATON.  45 GOLDRILL AVE BOLTON. LANCS, U.K. "

 EVEN
UPTO DC.L EE-36
CUNT DC.W 0
 EVEN
;\\RUNNING ORDER SEQUENCE
ee
doth
 DC.L PNT4,LEAD
 DC.L PNT0,bB1
 DC.L PNT2,basa
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+16*64

 DC.L PNT5,HONEY
 DC.L PNT0,bB1
 DC.L PNT2,basa
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+16*64

 DC.L PNT4,YOU
 DC.L PNT0,B2
 DC.L PNT2,STR
 DC.L PNT3,drm
 DC.B 3,%00011110
 DC.W -1+8*64

 DC.L PNT4,HONE
 DC.L PNT0,bB1
 DC.L PNT2,basa
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+16*64

 DC.L PNT4,WILL
 DC.L PNT0,B2
 DC.L PNT2,STR8
 DC.L PNT3,drm
 DC.B 4,%00011110
 DC.W -1+8*64

 DC.L PNT4,basa
 DC.L PNT0,bB1
 DC.L PNT2,fb1
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+16*64

 DC.L PNT4,b52
 DC.L PNT0,str8
 DC.L PNT2,will
 DC.L PNT3,drm
 DC.B 4,%00011110
 DC.W -1+8*64

 DC.L PNT4,b2
 DC.L PNT0,b52
 DC.L PNT2,str8 
 DC.L PNT3,drm
 DC.B 4,%00011110
 DC.W -1+8*64

 DC.L PNT5,bb1 HONEY
 DC.L PNT0,basa
 DC.L PNT2,honey basa
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+16*64

 DC.L PNT4,str8
 DC.L PNT0,B2
 DC.L PNT2,STR
 DC.L PNT3,drm
 DC.B 3,%00011110
 DC.W -1+8*64

 DC.L PNT4,bb1 
 DC.L PNT0,hone
 DC.L PNT2,basa
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+16*64

 DC.L PNT4,WILL1
 DC.L PNT0,B2
 DC.L PNT2,STR8
 DC.L PNT3,drm
 DC.B 4,%00011110
 DC.W -1+8*64


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
 BRA FCC
EFCT

 DC.L FINK,VIB,WARB,DRUM,slip,WB1,WRP,SLW
 DC.L SLR,HOLD,TWERP,SLR1,inup,HOLDLOW,Half
 dc.l wwq,coll,foll,aoll,eoll

 REPT 11
 DC.L FINK
 ENDR

FCC LEA EFCT,A6
 AND #31,D0 
 ASL #2,D0
 MOVE.L (A6,D0),A0
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

fink 
  rts

;-------EFFECTS ROUTINES--------
;1-256---DELAYED--VIBRATO-------
VV EOR.B #1,MC
 BEQ.S SDC
VIB CMP.B #8,4(A1)
 BLT SDC

WWQ 

 SUB.B #1,24(A1)
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

WARB
 Lsr 20(A1)
 Lsr 20(A1)
 CMP #30,20(A1)
 BGT.S PLOP
 MOVE 6(A1),20(A1)
PLOP BRA VIB RTS


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

slip 


WB1


;6--1536-----WARB UP---------
WRP 
 LSR 20(A1)
 CMP #200,20(A1)
 BGT.S SDX
 MOVE 6(A1),20(A1)
 RTS

SDX RTS
PLAP

;7--1792---SLIDE-UP--WARBLE
SLW 
 ADDQ.B #1,4(A1)
 LSR 20(A1)
 CMP #136,20(A1)
 BGT.S SDX
 MOVE 6(A1),20(A1)
 RTS



;--2048---SLIDE UP CONST VOL 
SLR 

YIN DC.B 0,0
;9--2304-------HOLD-------------
HOLD
 move.b #65,4(a1)
 rts

;------10 2560
TWERP 
 CMP.B #7,4(A1)
 BLT.S SA
 SUBQ.W #1,20(A1)
SA RTS

;11-------2816 SLIDE UP WITH ADSR
SLR1
 CMP.B #7,4(A1)
 BLT.S XA
 ADDQ.W #2,20(A1)
XA RTS


tp dc.b 0,0
;12-------3072  
inup
 move.b #8,4(a1)
 bra WWQ


;13-------3328--HOLD VOL LOW
HOLDLOW
 addq.b #1,4(a1)
 rts 

;
;14--------dw A
half

;15--------DW G
holl
 ADDQ.B #1,RONK
 move.b RONK,d1
 and #3,d1
 asl #1,d1
 move dq(pc,d1),20(a1)
 rts

dq dc.w 162,108,81,64

;16--------DW C
Coll
wop ADDQ.B #1,RONK+1
 move.b RONK+1,d1
 and #1,d1
 asl #1,d1
 move Eq(pc,d1),20(a1)
 rts

Eq dc.w 102*2,136*4

;17--------DW F
Foll
aoll
eoll
 rts

RONK DC.B 0,0





;\\\\\\\\\\\\\\DATAS\\\\\\\\\\\\\\\
;\\NOTE 1ST WORD. DURATION 2ND WORD
;\\\LEAD
PNT0 DC.W 0
NP0 DC.W 1
 DC.W 0
 DC.L 0
 DC.B 9,2,3
 DC.B 1      ;ADD TO NOTE
 DC.W 4      ;VIB LIMIT
 DC.W 3      ;16(A1)  ADD
 DC.W 0      ;VIB 18(A1)
 DC.L 0      ;TMP NOTE 20(A1)
 DC.B 1,1    ;VIB RATE 24(A1)
 DC.B 0,0    ;INITIAL VOL
;ADSR  28(A1)

 DC.B 15,15,14,13,12,11,10,10,10,10,11,10,10,10,10,10
 
 dcb.b	10,9
 dcb.b	10,8
 dcb.b	20,7
 dcb.b	30,6
 dcb.b	40,5



 EVEN

;\\\BASS
PNT2 DC.W 0
 DC.W 1          ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,4,5     ;10(A1) VOL REG
 DC.B 0          ;ADD TO NOTE 13(A1)
 DC.W 5          ;VIB LIMIT
 DC.W 3          ;VIBRATO ADD 16(A1)
 DC.W 2          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
ADSR

 DC.B 14,12,11,9,8,7,8
 dcb.b	3,8
 dcb.b	8,9
 dcb.b	8,10
 dcb.b	8,9
 dcb.b	8,8
 dcb.b	8,7
 DCB.B 20,6
 DCB.B 40,5
 DCB.B 40,4




 EVEN
PNT3 DC.W 0
NP3 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,6,11    ;10(A1) VOL REG
 DC.B -1         ;ADD  13(A1)
 DC.W 12          ;VIB LIMIT
 DC.W 4          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
 DC.B 15,15,13,11,9
 DC.B 9,8,7,6,7,8
 DC.B 50,0



 EVEN
PNT4 DC.W 0
NP4 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0
 DC.B 8,0,1      ;10(A1) VOL REG
 DC.B 0          ;ADD 13(A1)
 DC.W 3          ;VIB LIMIT
 DC.W 2          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)

 DC.B 12,15,14,13,13,12


 DCB.B 8,11
 DCB.B 8,9
 DCB.B 8,8
 DCB.B 8,7
 DCB.B 8,6
 DCB.B 15,5
 DCB.B 20,4
 DCB.B 20,3
 DCB.B 20,2
 DCB.B 20,1
 DC.B 20,0


 even

PNT5 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 8,0,1
 DC.B 0       ;ADD  13(A1)
 DC.W 2       ;VIB LIMIT
 DC.W 3       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)
 DC.B 15,15,14,13,12,11,10,10,10
 DCB.B 10,9
 DCB.B 10,8
 DCB.B 10,7
 DCB.B 10,6
 DCB.B 10,5
 DCB.B 20,4





 EVEN
TE2 DC.W 2,3

MAX DC.B 71,32,87,72,69,65,84,79,78
DRI DC.B 251,0
MIN DC.B 0,0
MC DC.B 0,0
 EVEN

;-----------MUSIC DATA

drm
 dc.w 0,32+1024
 dc.w 7,4+768
 dc.w 0,28+1024

 dc.w 0,32+1024
 dc.w 7,4+768
 dc.w 0,28+1024

 dc.w 0,32+1024
 dc.w 7,4+768
 dc.w 0,28+1024

 dc.w 0,32+1024
 dc.w 7,4+768
 dc.w 0,28+1024


 dc.w 0,32+1024
 dc.w 7,4+768
 dc.w 0,28+1024

 dc.w 0,32+1024
 dc.w 7,4+768
 dc.w 0,28+1024

 dc.w 0,32+1024
 dc.w 7,4+768
 dc.w 0,28+1024

 dc.w 0,24+1024
 dc.w 7,1+768
 dc.w 0,7+1024
 dc.w 7,4+768
 dc.w 0,12+1024

 dc.w 4,1+768
 dc.w 0,7+1024
 dc.w 2,1+768
 dc.w 0,6+1024

 DC.W $FFFF,$FFFF


NULL DC.W 2,128+2304
 DC.W $FFFF,$FFFF

v=15*256
u=8
K=1536

fb1 dc.w 0,2
basa
 dc.w 153*u,16+K
 dc.w 153*u,4+K
 dc.w 0,4+S
 dc.w 153*u,8+K
 dc.w 153*u,8+K
 dc.w 153*u,8+K
 dc.w 153*u,8+K
 dc.w 153*u,8+K

 dc.w 153*u,16+K
 dc.w 153*u,4+K
 dc.w 0,4+S
 dc.w 153*u,8+K
 dc.w 153*u,8+K
 dc.w 153*u,8+K
 dc.w 153*u,8+K
 dc.w 153*u,8+K


 dc.w 128*u,4+48+K

 dc.w 127*u,2+K
 dc.w 126*u,2+K
 dc.w 125*u,2+K
 dc.w 124*u,2+K
 dc.w 123*u,2+K
 dc.w 122*u,2+K


 dc.w 121*u,16+K
 dc.w 121*u,4
 dc.w 0,4+S
 dc.w 121*u,40+K
 dc.w 153*u,16+K
 dc.w 153*U,16+K


 dc.w 153*16,12+K
 dc.w 0,4+S

 dc.w 91*16,12+K
 dc.w 0,4+S

 dc.w 102*16,32+K

 dc.w 102*16,16+K
 dc.w 91*16,16+K

 dc.w 153*u,16+K

TX=512
L=4
 DC.W 153*L,16+TX
 DC.W 102*L,16+TX
 DC.W 91*L,16+TX
 DC.W 76*L,16+TX
 DC.W 91*L,16+TX
 DC.W 102*L,16+TX
 DC.W 121*L,16+TX


 DC.W $FFFF,$FFFF

i=2
VB=256


SLU=2560
SLD=2816

HONEY
 DC.W 121*i,16+VB
 DC.W 102*i,8
 DC.W 153*i,48+VB

 DC.W 102*i,8
 DC.W 91*i,8
 DC.W 76*i,16+VB

 DC.W 91*i,8
 DC.W 102*i,16+VB

hon1
 DC.W 128*i,16+SLD
 DC.W 153*i,8
 DC.W 128*i,48+VB

hon2
;i'm
 DC.W 128*i,8
 DC.W 121*i,8
 DC.W 102*i,16+VB

 DC.W 121*i,8
 DC.W 136*i,16+VB

hon3
 DC.W 153*i,16+SLD
 DC.W 182*i,8
 DC.W 153*i,48+VB

;SO WONT
hon4
 DC.W 136*i,8
 DC.W 136*i,8
 DC.W 121*i,8
 DC.W 102*i,8
 DC.W 121*i,16+SLD
 DC.W 153*i,48+VB
 dc.w 0,88+S



 DC.W $FFFF,$FFFF


*-*-*
HONE
 DC.W 121*i,8+VB
 DC.W 0,8+S
 DC.W 102*i,8
 DC.W 153*i,48+VB

 DC.W 102*i,8
 DC.W 91*i,8
 DC.W 76*i,8+VB
 DC.W 0,8+S

 DC.W 91*i,8
 DC.W 102*i,16+VB

;TRAGIC
 DC.W 128*i,16+SLD
 DC.W 153*i,8
 DC.W 128*i,48+VB

;COME ON SHOW ME THE MAGIC
;i'm
 DC.W 128*i,8
 DC.W 121*i,8
 DC.W 102*i,8+VB
 DC.W 0,8+S

 DC.W 121*i,8
 DC.W 136*i,8+VB
 DC.W 121*i,8

;
 DC.W 153*i,16+SLD
 DC.W 182*i,8
 DC.W 153*i,48+VB

;OF YOUR HOLLYWOOD SONGS

 DC.W 128*i,8
 DC.W 121*i,8
 DC.W 102*i,16+vb
 DC.W 121*i,8
 DC.W 136*i,8
 DC.W 153*i,48+VB
 dc.w 0,88+S



 DC.W $FFFF,$FFFF








O=8 
BB1
 dc.w 153*O,32+V
 dc.w 153*O,32+V
 dc.w 153*O,32+V
 dc.w 153*O,32+V

 dc.w 193*O,32+V
 dc.w 193*O,8+V
 dc.w 0,8+S
 dc.w 193*O,16+V
 
 dc.w 182*O,32+V
 dc.w 182*O,32+V

 dc.w 153*O,32+V

 dc.w 153*O,16

 dc.w 182*O,16

 dc.w 204*O,32+V
 dc.w 204*O,32+V

 dc.w 153*O,32+V
 dc.w 153*O,24

 dc.w 204*O,8
 dc.w 193*O,16
 dc.w 193*O,8
 dc.w 193*O,8

 dc.w 204*O,16+VB
 dc.w 204*O,8+VB
 dc.w 204*O,8+VB
 DC.W $FFFF,$FFFF


STR1 DC.W 0,8+S
STR
 DC.W 91*4,64+V
 DC.W 91*4,64+V
 DC.W 121*4,40+V

 DC.W 120*4,24+2560

 DC.W 102*4,64+V


 DC.W 91*4,64+V
 DC.W 81*4,40+V
 DC.W 81*4,24+sld 2816

 DC.W 136*4,64+Vb
 DC.W 136*4,64+V
 DC.W 121*4,64+V
 DC.W 136*4,64+V


;YOU BECAME A LEGEND

J=2
YOU
 DC.W 91*J,16
 DC.W 76*J,8
 DC.W 91*J,24
 DC.W 102*J,16
 DC.W 121*J,16
 DC.W 136*J,16+V

;OF
 DC.W 153*J,16+V
 DC.W 136*J,16+V
 DC.W 121*J,16
 DC.W 153*J,8
 DC.W 102*J,56+V

;AND NOW
 DC.W 153*J,16
 DC.W 114*J,16
 DC.W 102*J,16

;THOUGHT
 DC.W 91*J,16
 DC.W 85*J,8
 DC.W 91*J,16
 DC.W 85*J,8
 DC.W 91*J,16

 DC.W 91*J,16
 DC.W 91*J,8
 DC.W 91*J,16
 DC.W 91*J,8
 DC.W 91*J,16+sld

;KNEE
 DC.W 136*J,64+V
 DC.W 0,64+S



;WILL THE WIND

WILL
 DC.W 91*J,16+V
 DC.W 76*J,8
 DC.W 91*J,24
 DC.W 102*J,16
 DC.W 121*J,16
 DC.W 136*J,16

;BOAT
 DC.W 153*J,16
 DC.W 136*J,16+Vb
 DC.W 121*J,16+Vb
 DC.W 153*J,8
 DC.W 102*J,24+V

E=1536
C=5
H=4

A=1792
*-*
 DC.W 102*H,C+A
 DC.W 96*H,C+A
 DC.W 91*H,6+A

 DC.W 81*H,C+A
 DC.W 85*H,C+A
 DC.W 91*H,6+A

 DC.W 96*H,C+A
 DC.W 102*H,C+A
 DC.W 108*H,6+A

 DC.W 114*H,16+A
 DC.W 121*H,16+A
*-*

;KINDLY
 DC.W 91*J,8
 DC.W 0,8+S
 DC.W 81*J,8
 DC.W 0,8+S
 DC.W 91*J,8
 DC.W 0,8+S
 DC.W 81*J,8
 DC.W 0,8+S

 DC.W 91*J,8
 DC.W 0,8+S
 DC.W 81*J,8
 DC.W 0,8+S

 DC.W 81*J,8
 DC.W 0,8+S

 DC.W 91*J,16+SLD
 DC.W 102*J,128+vb 




P=8
pp=p/2
B21 DC.W 0,3+S

B2
 DC.W 182*P,16
 DC.W 182*PP,16

 DC.W 182*P,16
 DC.W 182*PP,16

 DC.W 182*P,16
 DC.W 182*PP,16

 DC.W 182*P,16
 DC.W 182*PP,16

 DC.W 153*P,16
 DC.W 153*PP,16

 DC.W 153*P,16
 DC.W 153*PP,16

 DC.W 153*P,16
 DC.W 153*PP,16

 DC.W 153*P,16
 DC.W 153*PP,16

 DC.W 136*P,16
 DC.W 136*PP,8
 DC.W 136*PP,8

 DC.W 136*P,16
 DC.W 136*PP,8
 DC.W 136*PP,8
 
 DC.W 121*P,16
 DC.W 121*PP,8
 DC.W 121*PP,8

 DC.W 121*P,16
 DC.W 121*PP,8
 DC.W 121*PP,8

 DC.W 136*P,16
 DC.W 136*PP,8
 DC.W 136*PP,8

 DC.W 136*P,16
 DC.W 136*PP,8
 DC.W 136*PP,8

 DC.W 121*P,16
 DC.W 121*PP,8
 DC.W 121*PP,8

 DC.W 136*P,16
 DC.W 136*PP,8
 DC.W 136*PP,8

S=2304
R=2
LEAD
 DC.W 0,255+S
 DC.W 0,255+S

 DC.W 121*R,8+f
 DC.W 102*R,5+v
 DC.W 0,64+8+3+S

 DC.W 153*R,8+f
 DC.W 121*R,8+f
 DC.W 114*R,8+f
 DC.W 121*R,8+f
 DC.W 153*R,8

 DC.W 191*R,8+f

 DC.W 153*R,8
 DC.W 136*R,8
 DC.W 121*R,8

 DC.W 114*R,8
 DC.W 108*R,8
 DC.W 102*R,8
 DC.W 96*R,8
 DC.W 81*R,32+VB

 DC.W 85*R,16
 DC.W 91*R,8

 DC.W 0,255+S
 DC.W 0,255+S



f=13*256
pq=16

B52
 DC.W 182*pq,32

 DC.W 182*P,32

 DC.W 182*P,32
 DC.W 182*P,16
 DC.W 182*P,8
 DC.W 182*P,8+f

 DC.W 153*P,32
 DC.W 153*P,32
 DC.W 153*P,32

 DC.W 153*P,16
 DC.W 153*P,16+f

 DC.W 136*P,32+f

 DC.W 136*P,32+f
 
 DC.W 121*P,32

 DC.W 121*P,32

 DC.W 136*P,32

 DC.W 136*P,24
 DC.W 136*P,8

 DC.W 121*P,16
 DC.W 121*P,8
 DC.W 121*P,8

 DC.W 136*P,16
 DC.W 136*pq,8
 DC.W 136*pq,8+f

STR8
 DC.W 91*4,64+V
 DC.W 91*4,64+V
 DC.W 121*4,40+V

 DC.W 120*4,24+2560

 DC.W 102*4,64+V


 DC.W 91*4,64+V
 DC.W 81*4,40+V
 DC.W 81*4,24+sld 2816

 DC.W 102*4,64+Vb
 DC.W 102*4,64+V
 DC.W 121*4,64+V
 DC.W 102*4,64+V

ha=1
ca=2
WILL1
 DC.W 91*ca,8 +V
 DC.W 91*ca,8 +V
 DC.W 76*ca,8
 DC.W 91*ca,8
 DC.W 0,8+s
 DC.W 102*ca,8
 DC.W 102*ca,8
 DC.W 102*ca,8
 DC.W 121*ca,8
 DC.W 121*ca,8
 DC.W 136*ca,8
 DC.W 0,8+s

;BOAT
 DC.W 153*ca,8
 DC.W 0,8+s
 DC.W 136*ca,8 +Vb
 DC.W 0,8+s
 DC.W 121*ca,8 +Vb
 DC.W 121*ca,8 +Vb
; DC.W 0,8+s
 DC.W 153*ca,8
 DC.W 102*ca,8
 DC.W 0,16+s

 DC.W 102*ha,C+A
 DC.W 96*ha,C+A
 DC.W 91*ha,6+A

 DC.W 81*ha,C+A
 DC.W 85*ha,C+A
 DC.W 91*ha,6+A

 DC.W 96*ha,C+A
 DC.W 102*ha,C+A
 DC.W 108*ha,6+A

 DC.W 114*ha,16+A
 DC.W 121*ha,16+A
*-*

;KINDLY
 DC.W 91*ca,8
 DC.W 0,8+S
 DC.W 91*ca,8
 DC.W 0,8+S
 DC.W 91*ca,8
 DC.W 0,8+S
 DC.W 91*ca,8
 DC.W 0,8+S

 DC.W 81*ca,8
 DC.W 81*ca,8
 DC.W 81*ca,8
 DC.W 0,8+S
 DC.W 81*ca,8
 DC.W 0,8+S

 DC.W 91*ca,16+sld

 DC.W 102*ca,8 +vb 
 DC.W 0,120+s

