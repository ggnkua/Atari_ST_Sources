

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

 move #3000,d0
sss dbra d0,sss

 move #$606,$ff8240
 bsr vbi
 move ort,$ff8240

 CMP.B #97,$FFFC02
 BNE BI



	lea	$ff8800,a0	get sound chip 
	move.b	#7,(a0)
	move.b	#%11111111,2(a0) cut out lingering noise
	move.l #$8000000,$ff8800 
	move.l #$9000000,$ff8800 
	move.l #$a000000,$ff8800 


 MOVE #$777,$FF8240  
 clr $FF8240+30
 MOVE.L SV,-(SP)
 MOVE #$20,-(SP)
 TRAP #1
 ADDQ.L #6,SP
 
 CLR -(SP)
 TRAP #1



 
VBI  
 lea sl,a3


;\\\\\\\\\\\\\
 MOVE.L UPTO,A2
 MOVE CUNT,D3
 MOVE.B 33(A2),D4
SSU SUBQ.W #1,D3
 BPL PART1

COP 
 move.l #1,d1
 MOVE.L d1,PNT1
 MOVE.L d1,PNT2
 MOVE.L d1,PNT3
 MOVE.L d1,PNT5
 MOVE.L #$9000000,(a3)

 ADD.L #36,a2
 CMP.L #CHAN0,A2
 BNE.S LLA

 LEA DOTH,A2
 move.l e1,d1
 move.l e1+4,e1
 move.l d1,e1+4 

 move.l e2,d1
 move.l e2+4,e2
 move.l d1,e2+4 

 eor.b #1,ti
 beq.s lla

 addq.w #1,ji
 and #3,ji

LLA
 MOVE 34(A2),D3
 MOVE.B 33(A2),D4
PART1

 
 moveq.w #0,d2
 
 BTST #1,D4
 BEQ.S W1
 MOVE.L (A2),A1
 MOVE.L 4(A2),A0
 BSR CHAN0

W1 
 cmp.b #0,ji+1
 beq.s w2

 BTST #2,D4
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






flo

killer rts


ji dc.w 1 



SV DC.L 0


 DC.B " (C) G.WHEATON.  45 GOLDRILL AVE BOLTON. LANCS, U.K. "
 
 even

UPTO DC.L start
CUNT DC.W 0
 EVEN
;\\RUNNING ORDER SEQUENCE

ee
doth


 DC.L PNT5,b1
 DC.L PNT1,acc
 DC.L PNT2,bt2
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*7


 DC.L PNT5,b11 
 DC.L PNT1,acc1
 DC.L PNT2,bt2
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*1

 DC.L PNT5,b2
 DC.L PNT1,morn
 DC.L PNT2,bt3
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*2


 DC.L PNT5,b11
 DC.L PNT1,in
 DC.L PNT2,bt2
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*2

 DC.L PNT5,b2
 DC.L PNT1,mornin
 DC.L PNT2,bt3
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*2

 DC.L PNT5,b12
 DC.L PNT1,rise
 DC.L PNT2,bt2
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*2

 DC.L PNT5,b3
 DC.L PNT1,time
 DC.L PNT2,bt4
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*2

start
 DC.L PNT5,b5
 DC.L PNT1,time1
 DC.L PNT2,bt3
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*2

 DC.L PNT5,bt2
 DC.L PNT1,acc
 DC.L PNT2,b1
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*4




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
e1 	 dc.l WARB,vib
e2	 dc.l slip,drum
	 dc.l silent,mug
 

FCC LEA EFCT,A6
 AND #31,D0 
 ASL #2,D0
 MOVE.L (A6,D0),A0
 JSR (A0)

MAZ ADDQ.B #1,4(A1)          ;VOL0

 ;move ji,d0
 ;move 20(a1),d1
 ;lsr d0,d1
 ;move d1,20(a1)

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

mug
 addq.b #1,4(a1)
 bra.s wwq 
 
VIB 

 moveq.w #0,d1
 move.b 4(a1),d1
 cmp #16,d1
 blt.s sac 


WWQ 
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

sac move 6(a1),20(a1)
 rts

;2-512------WARB DW-----------

WARB  
 add.w  #100,4(A1)

 addq.w #1,fluk
 and #7,fluk

 lsr 20(A1)

 add.b #90,li
 bcc.s plop


 MOVE 6(A1),20(A1)
 move fluk,d1
 asl #1,d1
 move ha(pc,d1),d1
 add d1,20(a1)

PLOP  RTS

ha dc.w 0,1,0,1,0,-1,0,-1

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



;------5*256
silent
 move.b #150,4(a1)
 rts 

slip
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

 DC.B 15,15,15,14,14,14,13,13,12,12,12

 dcb.b 10,11
 dcb.b 10,10
 dcb.b 10,9
 dcb.b 10,8
 dcb.b 10,7
 dcb.b 10,6
 dcb.b 10,5
 dcb.b 10,4
 dcb.b 20,3
 dcb.b 10,2



 EVEN
;\\\BASS
PNT2 DC.W 0
 DC.W 1          ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,4,5     ;10(A1) VOL REG
 DC.B 1          ;ADD TO NOTE 13(A1)
 DC.W 2          ;VIB LIMIT
 DC.W 3          ;VIBRATO ADD 16(A1)
 DC.W 2          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
li DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
ADSR
*-*

 DC.B 14,13,12,12,11,11
 DCb.B 2,10
 DCb.B 2,9
 DCb.B 10,7
 DCb.B 28,6
 dcb.b 20,5
 dcb.b 10,4
 dcb.b 10,3
 dcb.b 32,2




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


 DC.B 14,14,13,12,11,11,10,9,8,7


PNT5 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 8,0,1
 DC.B 0       ;ADD  13(A1)
 DC.W 5       ;VIB LIMIT
 DC.W 4       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)


 dc.b 14,13,13,12,12,11

 dcb.b 10,11
 dcb.b 10,10
 dcb.b 10,9
 dcb.b 10,8
 dcb.b 10,7







MAX DC.B 71,32,87,72,69,65,84,79,78
 EVEN

;-----------MUSIC DATA

D=1024+256
v=256
vv=6*256

NULL DC.W 2,128+5*256
 DC.W $FFFF,$FFFF


drm
 dc.w 3,32+1024
 dc.w 6,6+768
 dc.w 0,10+16+1024


 DC.W $FFFF,$FFFF


a=4
b=512

BT2
 dc.w 120*a,16+b
 dc.w 60*a,24+b

 dc.w 81*a,8+b

 dc.w 108*a,8+b
 dc.w 96*a,8+b

 dc.w 120*a,16+b


 dc.w 81*a,16+b
 dc.w 108*a,8+b
 dc.w 96*a,8+b
 dc.w 81*a,16+b
 DC.W $FFFF,$FFFF


g=8

b111
 dc.w 121*g,16+vv
 dc.w 96*g,4
 DC.W 0,12+d
 dc.w 162*g,16+vv
 dc.w 96*g,4
 DC.W 0,12+d


b11

 dc.w 121*g,16+vv
 dc.w 121*g,16+vv
 dc.w 108*g,8+vv
 dc.w 108*g,8+vv
 dc.w 96*g,8+vv
 dc.w 96*g,8+vv



b1
 dc.w 121*g,16+vv
 dc.w 96*g,4
 DC.W 0,12+d
 dc.w 162*g,16+vv
 dc.w 96*g,4
 DC.W 0,12+d

 DC.W $FFFF,$FFFF

b12
 dc.w 121*g,16+vv
 dc.w 96*g,4
 DC.W 0,12+d
 dc.w 162*g,16+vv
 dc.w 96*g,4
 DC.W 0,12+d
 dc.w 121*g,16+vv

 dc.w 121*g,16+vv
 dc.w 128*g,16+vv
 dc.w 144*g,16+vv

 DC.W $FFFF,$FFFF


b2
 dc.w 91*g,16+vv
 dc.w 72*g,4
 DC.W 0,12+d
 dc.w 121*g,16+vv
 dc.w 72*g,4
 DC.W 0,12+d

 dc.w 91*g,16+vv

 dc.w 91*g,16+vv
 dc.w 96*g,16+vv
 dc.w 108*g,16+vv

 DC.W $FFFF,$FFFF

b3
 dc.w 81*g,16+vv
 dc.w 64*g,4
 DC.W 0,12+d

 dc.w 108*g,16+vv
 dc.w 64*g,4
 DC.W 0,12+d

 dc.w 81*g,16+vv


 dc.w 162*g,16+vv
 dc.w 108*g,16+vv
 dc.w 96*g,16+vv



 DC.W $FFFF,$FFFF


b5
 dc.w 91*g,16+vv
 dc.w 72*g,4
 DC.W 0,12+d

 dc.w 121*g,16+vv
 dc.w 72*g,4
 DC.W 0,12+d

 dc.w 91*g,16+vv


 dc.w 81*g,16+vv
 dc.w 96*g,16+vv
 dc.w 108*g,16+vv



 DC.W $FFFF,$FFFF





BT3
 dc.w 91*a,16+b
 dc.w 60*a,24+b

 dc.w 60*a,8+b

 dc.w 81*a,8+b
 dc.w 72*a,8+b

 dc.w 91*a,16+b


 dc.w 60*a,16+b
 dc.w 81*a,8+b
 dc.w 72*a,8+b
 dc.w 60*a,16+b
 DC.W $FFFF,$FFFF



x=8
BT4
 dc.w 81*x,16+b
 dc.w 54*x,24+b

 dc.w 54*x,8+b

 dc.w 68*x,8+b
 dc.w 64*x,8+b

 dc.w 81*x,16+b


 dc.w 64*x,16+b
 dc.w 68*x,8+b
 dc.w 64*x,8+b
 dc.w 54*x,16+b
 DC.W $FFFF,$FFFF











t=256
e=2

acc
 dc.w 96*e,64+t
 dc.w 121*e,16+t

 dc.w 162*g,16+vv
 dc.w 144*g,16 +vv
 dc.w 128*g,16+vv

 dc.w 121*g,16+vv

 dc.w 193,32+v
 dc.w 193,16+v
 dc.w 242,16+v

 dc.w 162*g,16+vv
 dc.w 144*g,16 +vv
 dc.w 128*g,16+vv



 DC.W 96*e,32+t  ;blue
 DC.W 96*e,16+t
 DC.W 91*e,16+t

 DC.W 96*e,32+t

 DC.W 96*e,16+t
 DC.W 108*e,16+t

 DC.W 121*e,48+t  ;baby
 DC.W 144*e,16+t  ;

acc1
 DC.W 162*e,32+t  ;wore

 DC.W 162*e,16+t   ;in 
 DC.W 162*e,16    ;the 



morn

 dc.w 144*e,16+t
 dc.w 121*e,64+16+v

 dc.w 121*e,16+t ;when we 
 dc.w 144*e,16+t

 DC.W $FFFF,$FFFF

in
 dc.w 162*e,64+32+t ;rise

 dc.w 96*e,16+t
 dc.w 121*e,16+t
 DC.W $FFFF,$FFFF

mornin
 dc.w 108*e,16+t
 dc.w 121*e,64+16+t

 dc.w 121*e,16+t
 dc.w 108*e,16+t

 DC.W $FFFF,$FFFF

rise
 dc.w 96*e,64+32+t

 dc.w 96*e,16+t
 dc.w 121*e,16+t
 DC.W $FFFF,$FFFF
 
time
 dc.w 108*e,64+32+t

 dc.w 96*e,16+t
 dc.w 108*e,16+t


time1
 dc.w 121*e,64+16+t

 dc.w 121*e,16+t
 dc.w 121*e,16+t
 dc.w 108*e,16+t
 DC.W $FFFF,$FFFF


