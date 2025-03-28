
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



	lea	$ff8800,a0	get sound chip 
	move.b	#7,(a0)
	move.b	#%11111111,2(a0) cut out lingering noise
	move.l #$8000000,$ff8800 
	move.l #$9000000,$ff8800 
	move.l #$a000000,$ff8800 

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
 add.b #240,flo
 bcc killer

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
 BTST #1,D4
 BEQ.S W1
 MOVE.L (A2),A1
 MOVE.L 4(A2),A0
 BSR CHAN0

W1  BTST #2,D4
 BEQ.S W2
 MOVE.L 8(A2),A1
 MOVE.L 12(A2),A0
 BSR CHAN0

W2  BTST #3,D4
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
 MOVE.L A2,UPTO
 MOVE D3,CUNT
;--END OF VBI
;--------EXIT


killer rts



flo dc.b 0,0


SV DC.L 0

 DC.B " (C) G.WHEATON.  60 NEVIS GROVE. BOLTON. U.K. "
 
 even

UPTO DC.L ee-36
CUNT DC.W 0
 EVEN
;\\RUNNING ORDER SEQUENCE

ee
doth
 DC.L PNT5,yy
 DC.L PNT1,dd
 DC.L PNT2,bb
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*4

 DC.L PNT5,yy1
 DC.L PNT1,ff
 DC.L PNT2,bb1
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*4

 DC.L PNT5,yy2
 DC.L PNT1,ff1
 DC.L PNT2,bb2 null
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
 	 dc.l vib,warb
	 dc.l drum,SLIP
	 dc.l silent,mug
	 dc.l mug1,mug2
	 DC.L git
 

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

mug
 bra.s wwq 
 
VIB 

 moveq.w #0,d1
 move.b 4(a1),d1
 cmp #24,d1
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
warb
 lsr 20(a1)
 cmp #60,20(a1)
 bgt.s gaz

 move 6(a1),20(a1) 
gaz rts



fty dc.w 128


mug2
 move.b #149,4(a1)
 rts

mug1 
 move.b #139,4(a1)
 addq #1,lol
 move lol,d1
 and #3,d1
 asl #1,d1

 move 6(a1),20(a1)
 move pap(pc,d1),d1
 add d1,20(a1)
 rts


pap dc.w -1,0,1,0
lol dc.w 0

;3--768--------DRUM-----------
DRUM 
 SUBQ.B #2,21(A1)
 MOVE.B #7,(a3)
 MOVE.B #%11011000,2(a3)
 MOVE.B #6,(a3)
 MOVE.B 21(A1),2(a3)

 MOVE.B #5,(a3)
 MOVE.B 32(A2),2(a3)

 MOVE.B #4,(a3)
 MOVE.B 21(A1),D0
 ASL.B #3,D0
 MOVE.B D0,2(a3)
 RTS



;------5*256
silent
 move.b #150,4(a1)
 rts 

slip
 rts



;------9*256
git
 tst.b 4(a1)
 bne.s palp

 clr bab


palp 
 move.b #99,4(a1) 
 addq.w #1,bab

 move bab,d1
 move.b gitr(pc,d1),d2
 ext.w d2
 move 6(a1),d1
 add d2,d1
 move d1,20(a1)
 rts 

bab dc.w 0

gitr
 dc.b 0,0,0,0,0,0,0,0
 dc.b 0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13
 dc.b 15,14,15,14,11,10,11,15,14,16,15,14,13,15,13,14
 dc.b 12,11,10,9,8,7,6,5,4,3,2,1,0

 dc.b 1,1,0,1,1,1,0,-1,-1,0,0,0,1,1,0,1,0
 dc.b 1,1,0,1,0,1,1,0,-1,-1,0,-1,0,0,1,1,2,1,0
 dc.b 1,1,0,1,0,1,1,0,-1,-1,0,-1,0,0,1,1,2,1,0

 even

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

 DC.B 15,14,14,14,13,13,13,13

 dcb.b 16,12
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
 DC.W 2         ;VIB LIMIT
 DC.W 1          ;VIBRATO ADD 16(A1)
 DC.W 2          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
li DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
ADSR
*-*

 DC.B 13,12,11,12,11,10,11
 DCb.B 8,10
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


 DC.B 10,9,14,13,12,11,11,10,9,8,7


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

 dc.b 15,14,13,12
 dc.b 11,10

 dcb.b 8,9
 dcb.b 8,8
 dcb.b 16,7
 dcb.b 10,6
 dcb.b 16,7






MAX DC.B 71,32,87,72,69,65,84,79,78
 EVEN

;-----------MUSIC DATA

D=1024+256
v=256
vv=6*256

NULL DC.W 2,128+5*256
 DC.W $FFFF,$FFFF

drm
 dc.w 0,1+768
 dc.w 0,15+1024
 dc.w 12,3+768
 dc.w 0,13+1024

 dc.w 0,1+768
 dc.w 0,15+1024
 dc.w 10,5+768
 dc.w 0,11+1024


 DC.W $FFFF,$FFFF

u=2
x=512

yy
 dc.w 0,40+d
 dc.w 204*u,8+x
 dc.w 192*u,8+x
 dc.w 204*u,8+x
 dc.w 192*u,8+x  1st beat
 dc.w 204*u,8+x
 dc.w 192*u,8+x
 dc.w 120*u,8+x
 dc.w 0,8+d

 dc.w 204*u,8+x
 dc.w 192*u,8+x
 dc.w 204*u,8+x
 dc.w 192*u,8+x
 dc.w 204*u,8+x
 dc.w 192*u,8+x
 dc.w 120*u,16+x
 dc.w 0,16+d

 dc.w 128*u,8+x
 dc.w 128*u,8+x
 dc.w 120*u,8+x
 dc.w 0,8+d
 dc.w 182*u,8+x
 dc.w 0,8+d

 dc.w 0,32+d

 DC.W $FFFF,$FFFF

yy1
 dc.w 0,40+d
 dc.w 204*u,8+x
 dc.w 192*u,8+x
 dc.w 204*u,8+x
 dc.w 192*u,8+x  1st beat
 dc.w 204*u,8+x
 dc.w 192*u,8+x
 dc.w 120*u,8+x
 dc.w 0,8+d

 dc.w 204*u,8+x
 dc.w 192*u,8+x
 dc.w 204*u,8+x
 dc.w 192*u,8+x
 dc.w 204*u,8+x
 dc.w 192*u,8+x
 dc.w 120*u,8+x
 dc.w 0,24+d

 dc.w 96*u,8+x
 dc.w 96*u,8+x
 dc.w 91*u,8+x
 dc.w 0,8+d
 dc.w 121*u,8+x
 dc.w 0,8+d

 dc.w 0,32+d

 DC.W $FFFF,$FFFF


yy2
 dc.w 0,48+d
 dc.w 91*u,16+x
 dc.w 128*u,8+x
 dc.w 0,48+56+d
 dc.w 128*u,16+x
 dc.w 144*u,8+x
 dc.w 0,255+d
 
 DC.W $FFFF,$FFFF

e=1536
i=8
bb
 dc.w 144*i,8+e
 dc.w 144*i,8+e
 dc.w 0,8+d
 dc.w 144*i,8+e
 dc.w 0,8+d
 dc.w 192*i,8+e
 dc.w 162*i,8+e
 dc.w 153*i,8+e
 DC.W $FFFF,$FFFF

bb1
 dc.w 144*i,8
 dc.w 144*i,8
 dc.w 0,8+d
 dc.w 144*i,8
 dc.w 0,8+d
 dc.w 192*i,8
 dc.w 162*i,8 +d
 dc.w 153*i,8

 dc.w 144*i,8
 dc.w 144*i,8
 dc.w 0,8+d
 dc.w 144*i,8
 dc.w 0,8+d
 dc.w 192*i,8
 dc.w 162*i,8 +d
 dc.w 153*i,8

 dc.w 144*i,8
 dc.w 144*i,8
 dc.w 0,8+d
 dc.w 144*i,8
 dc.w 0,8+d
 dc.w 192*i,8
 dc.w 162*i,8 +d
 dc.w 153*i,8

bb2
 dc.w 121*i,8
 dc.w 121*i,8
 dc.w 0,8+d
 dc.w 121*i,8
 dc.w 0,8+d
 dc.w 121*i,8
 dc.w 121*i,8 +d
 dc.w 128*i,16 8

; dc.w 128*i,8
 dc.w 128*i,8
 dc.w 0,8+d
 dc.w 128*i,8
 dc.w 0,8+d
 dc.w 128*i,8
 dc.w 128*i,8 +d
 dc.w 128*i,8

 dc.w 128*i,8
 dc.w 128*i,8
 dc.w 0,8+d
 dc.w 128*i,8
 dc.w 0,8+d
 dc.w 128*i,8
 dc.w 128*i,8 +d
 dc.w 128*i,8

 dc.w 144*i,8
 dc.w 144*i,8
 dc.w 0,8+d
 dc.w 144*i,8
 dc.w 0,8+d
 dc.w 192*i,8
 dc.w 162*i,8 +d
 dc.w 153*i,8


 dc.w 128*i,8
 dc.w 128*i,8
 dc.w 0,8+d
 dc.w 128*i,8
 dc.w 0,8+d
 dc.w 128*i,8
 dc.w 128*i,8 +d
 dc.w 128*i,8

 DC.W $FFFF,$FFFF
 
g=8*256
r=7*256
dd
 dc.w 36,196+d
 dc.w 36,50+r

 dc.w 44,1+g
 dc.w 48,1+g
 dc.w 52,1+g
 dc.w 56,1+g
 dc.w 60,1+g
 dc.w 64,1+g
 dc.w 68,1+g
 dc.w 72,1+g
 dc.w 76,1+g
 dc.w 80,1+g
 dc.w 84,1+g
 dc.w 88,1+g
 dc.w 89,1+g
 dc.w 90,1+g
 
 DC.W $FFFF,$FFFF

ff
 dc.w 90,64+r
 dc.w 96,128+r
 dc.w 36,64+r
 DC.W $FFFF,$FFFF

ff1
 dc.w 90,64+r
 dc.w 45,64+r
 dc.w 64,64+r
 dc.w 72,16+r
 dc.w 36,48+d
 DC.W $FFFF,$FFFF





