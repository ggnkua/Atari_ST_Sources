

 CLR.L -(SP)       ; Enter supervisor mode.
 MOVE.W #$20,-(SP) ; Super.
 TRAP #1
 ADDQ.L #6,SP
 MOVE.L D0,SV


SL EQU $FF8800
SD EQU $FF8802

 LEA SL,A0
 move.b #7,(a0)
 move.b #%11111000,2(a0)
 MOVE.L #$08000000,(A0)
 MOVE.L #$09000000,(A0)
 MOVE.L #$0A000000,(A0)


bi
 MOVE.B $469,D0
FT CMP.B $469,D0
 BEQ.S FT

 bsr vbi
; bsr guitar

 CMP.B #97,$FFFC02
 BNE BI


 MOVE.L SV,-(SP)
 MOVE #$20,-(SP)
 TRAP #1
 ADDQ.L #6,SP
 
 CLR -(SP)
 TRAP #1



guitar
 move.b #8,(a0)
 move.b #15,2(a0)

 move.b #0,(a0)
 move.b #192,2(a0)
 move.b #1,(a0)
 move.b #0,2(a0)
 rts









 
VBI  
 lea sl,a3


;\\\\\\\\\\\\\
 MOVE.L UPTO,A2
 MOVE CUNT,D3
 MOVE.B 33(A2),D4
SSU SUBQ.W #1,D3
 BPL PART1

 moveq.l #1,d1
 MOVE.L d1,PNT1
 MOVE.L d1,PNT2
 MOVE.L d1,PNT3
 MOVE.L d1,PNT5
 MOVE.L d1,PNT6
 ;MOVE.L #$9000000,(a3)

 Lea 36(a2),a2
 CMP.L #CHAN0,A2
 BNE.S LLA

 LEA DOTH,A2

LLA
 MOVE 34(A2),D3
 MOVE.B 33(A2),D4

PART1

 

W0 
 move.l #r1,pppp

 BTST #1,D4
 BEQ.S W1
 MOVE.L (A2),A1
 MOVE.L 4(A2),A0
 BSR CHAN0

W1 BTST #2,D4
 BEQ.S W2
 addq.b #1,pppp+3
 MOVE.L 8(A2),A1
 MOVE.L 12(A2),A0
 BSR CHAN0

W2 BTST #3,D4
 BEQ.S W3
 addq.b #1,pppp+3
 MOVE.L 16(A2),A1
 MOVE.L 20(A2),A0
 BSR CHAN0

W3 BTST #4,D4
 BEQ.S W4
 addq.b #1,pppp+3
 MOVE.L 24(A2),A1
 MOVE.L 28(A2),A0
 BSR CHAN0


W4 
 MOVE.L A2,UPTO
 MOVE D3,CUNT
;--END OF VBI
;--------EXIT


flo
killer rts





SV DC.L 0

 DC.B " (C) G.WHEATON.  45 GOLDRILL AVE BOLTON. LANCS, U.K. "
 
 even

UPTO DC.L ee-36
CUNT DC.W 0
 EVEN
;\\RUNNING ORDER SEQUENCE

ee
doth
 DC.L PNT6,arp
 DC.L PNT1,arp1 +4 bas
 DC.L PNT2,rrrr
 DC.L PNT3,drm
 DC.B 0,%00011110
 DC.W -1+48*10

 DC.L PNT6,arp
 DC.L PNT1,bas
 DC.L PNT2,rrrr1
 DC.L PNT3,drm
 DC.B 0,%00011110
 DC.W -1+48*10

 DC.L PNT6,arp
 DC.L PNT1,bas1
 DC.L PNT2,rrrr
 DC.L PNT3,drm
 DC.B 0,%00011110
 DC.W -1+48*10

 DC.L PNT6,bas1
 DC.L PNT1,bas
 DC.L PNT2,arp
 DC.L PNT3,drm
 DC.B 0,%00011110
 DC.W -1+48*10




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
 MOVE.B #7,(a3)
 MOVE.B #%11111000,2(a3)
 BRA FCC
EFCT

	 DC.L FINK
 	 dc.l vib,warb
	 dc.l drum,SLIP
	 DC.L sile,quiet,slid,sliq
 

FCC LEA EFCT,A6
 AND #31,D0 
 ASL #2,D0
 MOVE.L (A6,D0),A0
 JSR (A0)

MAZ ADDQ.B #1,4(A1)          ;VOL0

 MOVE.B 11(A1),(a3)
 MOVE.B 21(A1),2(a3)   ;TMP0+1
 MOVE.B 12(A1),(a3)
 MOVE.B 20(A1),2(a3)   ;TMP0
 moveq.w #0,D0
 MOVE.B 4(A1),D0
 MOVE.B 10(A1),(a3)
 MOVE.B 28(A1,D0),2(a3)    ;VOL0

fink rts

;-------EFFECTS ROUTINES--------
;1-256---DELAYED--VIBRATO-------

 
VIB 
 move.l pppp,a4
 tst.b 4(a1)
 bne.s moog

 clr.b (a4)

moog
 cmp.b #190,(a4)
 beq.s ewqq
 addq.b #1,(a4)

ewqq clr d1
 move.b (a4),d1
 move.b vvvb(pc,d1),d1
 ext.w d1
 move 6(a1),20(a1)
 add d1,20(a1)


SDC RTS
vvvb incbin vib.dat

pppp dc.l 0
r1 dc.b 0
r2 dc.b 0
r3 dc.b 0
r4 dc.b 0

;2-512------WARB DW-----------

WARB   
 rts


;3--768--------DRUM-----------
DRUM 
 SUBQ.B #1,21(A1)
 MOVE.B #7,(a3)
 MOVE.B #%11011000,2(a3)
 MOVE.B #6,(a3)
 MOVE.B 21(A1),2(a3)

 MOVE.B #5,(a3)
 MOVE.B 32(A2),2(a3)

 MOVE.B #4,(a3)
 MOVE.B 21(A1),D0
 ASL.B #4,D0
 MOVE.B D0,2(a3)
 RTS


slip rts

;------5*256
sile
 move.b #150,4(a1)
 rts 


quiet
 tst.b 4(a1)
 bne.s llz
 move.b #8,4(a1)
llz
 rts


slid
 bsr quiet
 cmp.b #16,4(a1)
 blt.s llz
 add #25,20(a1)
 rts



sliq
 bsr quiet

 cmp.b #10,4(a1)
 blt.s llz

 sub #15,20(a1)
 rts






;\\\\\\\\\\\\\\DATAS\\\\\\\\\\\\\\\
;\\NOTE 1ST WORD. DURATION 2ND WORD
;\\\LEAD

;\\\MIDDLE
PNT1 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 9,2,3
 DC.B 0       ;ADD  13(A1)
 DC.W 3       ;VIB LIMIT
 DC.W 2       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
ti DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)

 DC.B 12,13,14,15,14,15,15,14,14,13,13,12,12

 dcb.b 16,11
 dcb.b 16,10
 dcb.b 16,9
 dcb.b 16,8
 dcb.b 32,7
 dcb.b 32,6
 dcb.b 32,5
 dcb.b 16,4
 dcb.b 20,3
 dcb.b 8,4
 dcb.b 8,5
 dcb.b 8,6
 dcb.b 8,7
 dcb.b 8,8
 dcb.b 8,9
 dcb.b 8,10



 EVEN
;\\\BASS
PNT2 DC.W 0
 DC.W 1          ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,4,5     ;10(A1) VOL REG
 DC.B 1          ;ADD TO NOTE 13(A1)
 DC.W 11         ;VIB LIMIT
 DC.W 6          ;VIBRATO ADD 16(A1)
 DC.W 2          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
li DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
ADSR
*-*

 DC.b 9,10,11,12,13,12,11,12,11,10,11,10
 DC.B 10,9,10,9,10,9,10,9
 DCb.B 8,9
 DCb.B 8,7
 DCb.B 28,6
 dcb.b 20,5
 dcb.b 16,4
 dcb.b 32,3
 dcb.b 64,2




 EVEN
PNT3 DC.W 0
NP3 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,6,11    ;10(A1) VOL REG
 DC.B 0          ;ADD  13(A1)
 DC.W 5          ;VIB LIMIT
 DC.W 3          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
fluk DC.B 0,0        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)


 DC.B 14,13,12,11,11,10,9,8,7


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

 dc.b 11,10,9
 dcb.b 8,8
 dcb.b 8,10
 dcb.b 16,9
 dcb.b 16,8
 dcb.b 16,7

PNT6 DC.W 0
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

 dc.b 15,13
 dcb.b 8,10
 dcb.b 8,9
 dcb.b 8,8
 dcb.b 8,7
 dcb.b 8,6
 dcb.b 8,5
 dcb.b 8,4






MAX DC.B 71,32,87,72,69,65,84,79,78
 EVEN

;-----------MUSIC DATA

D=1024+256
v=256
vv=6*256

NULL DC.W 2,128+5*256
 DC.W $FFFF,$FFFF


drm
 dc.w 6,2+768
 dc.w 0,14+1024

 dc.w 2,1+768
 dc.w 0,15+1024

 dc.w 2,1+768
 dc.w 0,15+1024

 DC.W $FFFF,$FFFF




f=512
u=8

bas
 dc.w 108*16,2
 dc.w 108*u,46+f
 dc.w 96*16,2
 dc.w 96*u,46+f
 dc.w 91*16,2
 dc.w 91*u,46+f

 dc.w 81*u,32+f
 dc.w 72*u,16+f

 dc.w 96*u,32+f

q=6*256
***
 dc.w 72*u,5+q
 dc.w 72*u,5+q
 dc.w 72*u,6+q
 dc.w 72*u,16+7*256
***



 dc.w 120*u,16+f
 dc.w 128*u,16+f
 dc.w 136*u,48+16+f

 dc.w 120*u,16+f
 dc.w 108*u,16+f

 dc.w 144*u,48+16+f
 
 dc.w 182*u,16+f
 dc.w 192*u,16+f

 DC.W $FFFF,$FFFF





rrrr
 dc.w 108*r,6*16
 dc.w 91*r,6*16
 dc.w 96*r,6*16
 dc.w 91*r,6*16
 dc.w 96*r,6*16

rrrr1
 dc.w 108*4,6*16+v
 dc.w 91*4,6*16
 dc.w 96*4,6*16
 dc.w 91*4,6*16
 dc.w 96*4,6*16



t=256
r=4 
arp
 dc.w 108*r,16+t
 dc.w 72*r,16
 dc.w 54*r,16
 dc.w 45*r,16
 dc.w 54*r,16
 dc.w 72*r,16

 dc.w 91*r,16+t
 dc.w 72*r,16
 dc.w 54*r,16
 dc.w 45*r,16
 dc.w 54*r,16
 dc.w 72*r,16

**
 dc.w 96*r,16+t
 dc.w 72*r,16
 dc.w 54*r,16
 dc.w 45*r,32
 dc.w 45*r,16

 dc.w 91*r,16+t
 dc.w 72*r,16
 dc.w 54*r,16
 dc.w 45*r,16
 dc.w 54*r,16
 dc.w 72*r,16

 dc.w 96*r,16+t
 dc.w 72*r,16
 dc.w 54*r,16
 dc.w 45*r,16
 dc.w 54*r,16
 dc.w 72*r,16

 DC.W $FFFF,$FFFF



arp1
 dc.w 108*r,16+t
 dc.w 72*r,16+v
 dc.w 54*r,16+v
 dc.w 45*r,16+v
 dc.w 54*r,16+v
 dc.w 72*r,16+v

 dc.w 91*r,16+t
 dc.w 72*r,16+v
 dc.w 54*r,16+v
 dc.w 45*r,16+v
 dc.w 54*r,16+v
 dc.w 72*r,16+v

**
 dc.w 96*r,16+t
 dc.w 72*r,16+v
 dc.w 54*r,16+v
 dc.w 45*r,32
 dc.w 45*r,16+v

 dc.w 91*r,16+t
 dc.w 72*r,16+v
 dc.w 54*r,16+v
 dc.w 45*r,16+v
 dc.w 54*r,16+v
 dc.w 72*r,16+v

 dc.w 96*r,16+t
 dc.w 72*r,16+v
 dc.w 54*r,16
 dc.w 45*r,16
 dc.w 54*r,16
 dc.w 72*r,16

 DC.W $FFFF,$FFFF







o=8
bas1
 dc.w 108*8,2
 dc.w 1+108*o,46+f
 dc.w 96*8,2
 dc.w 1+96*o,46+f
 dc.w 91*8,2
 dc.w 1+91*o,46+f

 dc.w 1+81*o,32+f
 dc.w 1+72*o,16+f

 dc.w 1+96*o,64+f

****

 dc.w 1+120*o,16+f
 dc.w 1+128*o,16+f
 dc.w 1+136*o,48+16+f

 dc.w 1+120*o,16+f
 dc.w 1+108*o,16+f

 dc.w 1+144*o,48+16+f
 
 dc.w 1+182*o,16+f
 dc.w 1+192*o,16+f

 DC.W $FFFF,$FFFF
