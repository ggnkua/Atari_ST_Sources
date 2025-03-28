
;       DON'T FUCK ROUND
; the angel of death is my mother.


 CLR.L -(SP)       ; Enter supervisor mode.
 MOVE.W #$20,-(SP) ; Super.
 TRAP #1
 ADDQ.L #6,SP
 MOVE.L D0,SV


SL EQU $FF8800
SD EQU $FF8802

 LEA SL,A0

 moveq #14,d0

ipa
 move.l d0,(a0)
 dbra d0,ipa



 move.b #7,(a0)
 move.b #%11111000,2(a0)
 MOVE.L #$08000000,(A0)
 MOVE.L #$09000000,(A0)
 MOVE.L #$0A000000,(A0)


bi
 MOVE.B $469,D0
FT CMP.B $469,D0
 BEQ.S FT

 move #4000,d0
aaa dbra d0,aaa

 clr $ff8240

 bsr vbi

 move #$666,$ff8240

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
 MOVE.L d1,PNT4
 MOVE.L d1,PNT5
 MOVE.L #$9000000,(a3)

 Lea 36(a2),a2
 CMP.L #CHAN0,A2
 BNE.S LLA

 LEA DOTH,A2

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







killer rts


flo dc.b 0,0


SV DC.L 0


 DC.B " (C) G.WHEATON.  45 GOLDRILL AVE BOLTON. LANCS, U.K. "
 
 even

UPTO DC.L EE-36
CUNT DC.W 0
 EVEN
;\\RUNNING ORDER SEQUENCE

ee

 DC.L PNT5,boo
 DC.L PNT1,boo
 DC.L PNT2,goo
 DC.L PNT3,drm
 DC.B 1,%00001110
 DC.W -1+64*8

 DC.L PNT5,noo
 DC.L PNT1,boo
 DC.L PNT2,doo
 DC.L PNT3,drm1
 DC.B 2,%00011110
 DC.W -1+64*8

 DC.L PNT5,boo
 DC.L PNT1,yoo
 DC.L PNT2,doo
 DC.L PNT3,drm1
 DC.B 2,%00011110
 DC.W -1+64*8

 DC.L PNT5,la
 DC.L PNT1,la
 DC.L PNT2,ba
 DC.L PNT3,drm1
 DC.B 0,%00011110
 DC.W 255

 DC.L PNT5,lc
 DC.L PNT1,lc
 DC.L PNT2,bc
 DC.L PNT3,drm1
 DC.B 0,%00011110
 DC.W 127

 DC.L PNT5,ld
 DC.L PNT1,bd
 DC.L PNT2,ld
 DC.L PNT3,drm1
 DC.B 1,%00011110
 DC.W 127

 DC.L PNT5,le
 DC.L PNT1,be
 DC.L PNT2,le
 DC.L PNT3,drm1
 DC.B 1,%00011110
 DC.W 127

 DC.L PNT5,lee
 DC.L PNT1,be
 DC.L PNT2,le
 DC.L PNT3,drm1
 DC.B 1,%00011110
 DC.W 127

 DC.L PNT5,lee
 DC.L PNT1,be
 DC.L PNT2,le
 DC.L PNT3,drm1
 DC.B 1,%00011110
 DC.W 127

 DC.L PNT5,lee
 DC.L PNT1,be
 DC.L PNT2,le
 DC.L PNT3,drm1
 DC.B 1,%00011110
 DC.W 127

 DC.L PNT5,bb
 DC.L PNT1,be
 DC.L PNT2,bb4 
 DC.L PNT3,drm1
 DC.B 1,%00001110
 DC.W 511 

 DC.L PNT5,null
 DC.L PNT1,be
 DC.L PNT2,null
 DC.L PNT3,drm
 DC.B 1,%00001110
 DC.W 255

 DC.L PNT4,www
 DC.L PNT1,www1
 DC.L PNT2,www
 DC.L PNT3,DRM
 DC.B 1,%00011110
 DC.W 767

DOTH
 DC.L PNT4,NT1
 DC.L PNT1,www nt1
 DC.L PNT2,wwX
 DC.L PNT3,DRM
 DC.B 1,%00011110
 DC.W 767

 DC.L PNT4,tune
 DC.L PNT1,www tune
 DC.L PNT2,tune22
 DC.L PNT3,DRM
 DC.B 1,%00011110
 DC.W -1+8*64 

 DC.L PNT4,tunes
 DC.L PNT1,ww8
 DC.L PNT2,ww88
 DC.L PNT3,DRM
 DC.B 1,%00011110
 DC.W -1+3*64 

 DC.L PNT4,tunes1
 DC.L PNT1,ww12
 DC.L PNT2,ww12
 DC.L PNT3,DRM
 DC.B 1,%00011110
 DC.W 63 


 DC.L PNT4,NT1
 DC.L PNT1,reg nt1
 DC.L PNT2,www
 DC.L PNT3,DRM
 DC.B 1,%00011110
 DC.W 767

 DC.L PNT4,NT1
 DC.L PNT1,git nt1
 DC.L PNT2,www
 DC.L PNT3,DRM
 DC.B 1,%00011110
 DC.W 767

 DC.L PNT4,www
 DC.L PNT1,git
 DC.L PNT2,git1
 DC.L PNT3,DRM1
 DC.B 1,%00011110
 DC.W 767

 DC.L PNT4,www
 DC.L PNT1,www
 DC.L PNT2,www1
 DC.L PNT3,DRM
 DC.B 1,%00011110
 DC.W 767

 DC.L PNT4,www
 DC.L PNT1,nt1
 DC.L PNT2,reg
 DC.L PNT3,DRM1
 DC.B 1,%00011110
 DC.W 767

 DC.L PNT4,www
 DC.L PNT1,nt1
 DC.L PNT2,git
 DC.L PNT3,DRM1
 DC.B 1,%00011110
 DC.W 767



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
 	 dc.l VIB,WARB
	 dc.l DRUM,slip
	 dc.l silent

	dc.l amin
	dc.l cmin
	dc.l dmin
	dc.l emin
 
	dc.l sub
	dc.l gmin
	dc.l slide
	dc.l qdrum
	dc.l warb1

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



 
VIB 

 moveq.w #0,d1
 move.b 4(a1),d1
 cmp #10,d1
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
 addq.b  #1,4(A1)

warb1
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
 move.b #50,4(a1)
 rts 

slip
 move.b #12,4(a1)
 rts


; 1536
*-*-*-*-* amin *-*-*-*-*
amin
 lea am,a4
 bra.s routn

;7
*-*-*-*-* cmin *-*-*-*-*
cmin
 lea cm,a4
 bra.s routn

;8
*-*-*-*-* dmin *-*-*-*-*
dmin
 lea dm,a4
 bra.s routn

;9
*-*-*-*-* emin *-*-*-*-*
emin
 lea em,a4



routn
 addq #1,mon
 move mon,d1
 and #7,d1
 asl #1,d1

 move (a4,d1),20(a1)
 rts 

am dc.w 144,121,96,72,60,47,288,36
cm dc.w 121,81,47,60,242,30,81,30
dm dc.w 108,54,85,288,54,108,72,54
em dc.w 96,91,72,47,192,182,47/2 
gm dc.w 162,108,81,64,54,128,162,81 

mon dc.w 0

;10
sub
 move.b #150,4(A1)
 RTS 

;11
*-*-*-*-* gmin *-*-*-*-*
gmin
 lea gm,a4
 bra.s routn

;12 
slide
; cmp.b #5,4(a1)
; blt.s xzaa
 subq #1,20(a1)
 move.b #46,4(a1)
xzaa
 rts

; 13 qdrum

qdrum
 move.b #5,4(a1) 
 subq.w #2,20(a1)
 subq.w #2,6(a1)
 bra warb
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
 DC.W 4       ;VIB LIMIT
 DC.W 3       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
ti DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)

 dc.b 15,15,15,14,14,13,13,12,11
 dcb.b 12,9
 dcb.b 8,10
 dcb.b 8,10
 dcb.b 8,11
 dcb.b 8,12
 dcb.b 8,13
 dcb.b 16,14
 dc.b 13,13,13,13,12,12,12,11,11,11,11
 dcb.b 32,10
 dcb.b 32,9
 dcb.b 8,2


 EVEN
;\\\BASS
PNT2 DC.W 0
 DC.W 1          ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,4,5     ;10(A1) VOL REG
 DC.B 1          ;ADD TO NOTE 13(A1)
 DC.W 5          ;VIB LIMIT
 DC.W 6          ;VIBRATO ADD 16(A1)
 DC.W 2          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
li DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
ADSR
*-*

 DC.B 15,15,14,14,13,13,12,12,11,11,10,10,9,9,9,9
 dcb.b 10,8
 DC.B 8,9,9,9,10,10,10,9,8,7,6
 dcb.b 10,5
 dc.b 5,3,5,6,5,4,5,6,5,4,5,4
 dcb.b 100,3
 

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


 DC.B 15,15,15,14,13,12,11,10,9,8
 dcb.b 5,0

PNT4 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 8,0,1
 DC.B 0       ;ADD  13(A1)
 DC.W 4       ;VIB LIMIT
 DC.W 3       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)

 DC.B 15,15,15,14,14,13,12,11,11,10,10,10
 DCB.B 8,11
 DC.B 10,9
 DCb.B 32,8
 DCb.B 16,7
 DCb.B 16,9
 DCb.B 16,10
 DCb.B 8,11
 DCb.B 8,12
 DCb.B 8,13
 DCb.B 16,14
 DCb.B 8,12
 DCb.B 8,11
 DCb.B 8,10
 DCb.B 32,9
 DCb.B 32,8
 DCb.B 32,5
 

PNT5 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 8,0,1
 DC.B 0       ;ADD  13(A1)
 DC.W 2       ;VIB LIMIT
 DC.W 2       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)

 DC.B 15,13,12,12,11,11,11,11,10
 DCb.B 8,10
 DCb.B 8,9
 DCb.B 16,7
 DCb.B 16,6
 DCb.B 32,5
 DCb.B 32,4
 DCb.B 32,3






MAX DC.B 71,32,87,72,69,65,84,79,78
 EVEN

;-----------MUSIC DATA

D=1024+256
v=256
vv=6*256

NULL 
 DC.W 2,128+5*256
 DC.W $FFFF,$FFFF


drm
 dc.w 16,3+768
 dc.w 0,13+1024
 dc.w 2,1+768
 dc.w 0,7+1024
 dc.w 2,1+768
 dc.w 0,7+1024

 DC.W $FFFF,$FFFF


drm1
 dc.w 0,1+1024
 dc.w 3,1+768
 dc.w 0,15+1024

 dc.w 1,1+768
 dc.w 0,14+1024

 DC.W $FFFF,$FFFF


t=512
x=2
q=2
doo
 dc.w 144*q,8+t,193*q,8+t
 dc.w 121*q,8+t,144*q,16+t

 dc.w 192*16,1,193*x,7+v
 dc.w 216*16,1,216*x,7+v
 dc.w 242*16,1,242*x,7+v

 dc.w 121*q,8+t,162*q,8+t
 dc.w 96*q,8+t,121*q,16+t

 dc.w 162*x,8+v,144*x,8+v,121*x,8+v

 dc.w 108*q,8+t,144*q,8+t
 dc.w 85*q,8+t

 dc.w 108*q,16+t
 dc.w 54*x,16+v
 dc.w 51*x,5+v
 dc.w 47*x,3+v


 dc.w 96*q,8+t,128*q,8+t
 dc.w 76*q,8+t,96*q,16+t

 dc.w 193*x,8,216*x,8,242*x,8

 DC.W $FFFF,$FFFF


i=1
noo 
 dc.w 144*i,64+v 512
 dc.w 121*i,64+512
 dc.w 108*i,64+v 512
 dc.w 96*i,64+512
 DC.W $FFFF,$FFFF

u=8
boo 
 dc.w 144*u,64+v
 dc.w 121*u,64+v
 dc.w 108*u,64+v
 dc.w 96*u,64+v
 DC.W $FFFF,$FFFF

h=8
yoo 
 dc.w 144*h,64+v
 dc.w 121*h,64+v
 dc.w 108*h,64+v
 dc.w 96*h,64+v
 DC.W $FFFF,$FFFF


aa=1536
cc=7*256
dd=8*256
en=9*256

la
 dc.w 0,128+aa
 DC.W $FFFF,$FFFF
lc
 dc.w 0,64+cc
 DC.W $FFFF,$FFFF
ld
 dc.w 0,32+dd
 DC.W $FFFF,$FFFF

ld1
 dc.w 0,8+dd
 dc.w 0,255+d
 DC.W $FFFF,$FFFF



lee
leb
 dc.w 0,8+en
 DC.W $FFFF,$FFFF

le
 dc.w 0,16+en
 dc.w 0,8+en
 DC.W $FFFF,$FFFF


bb
 dc.w 96*8,8
 dc.w 96*16,12
 dc.w 0,4+d
 dc.w 96*8,8
 DC.W $FFFF,$FFFF

bb4
 dc.w 96*8,16
 dc.w 144*8,8
 DC.W $FFFF,$FFFF



r=16
ba 
 dc.w 144*r,64+512
 DC.W $FFFF,$FFFF

bc 
 dc.w 121*r,64+512
 DC.W $FFFF,$FFFF

bd 
 dc.w 108*r,64+512
 DC.W $FFFF,$FFFF

be 
 dc.w 96*r,64+512
 DC.W $FFFF,$FFFF









www1 
 dc.w 121*u,2
www2 
 dc.w 128*u,2
 dc.w 136*u,1

www
 dc.w 144*u,16+v
 dc.w 96*u,16+v
 dc.w 121*u,16+v
 dc.w 144*u,8
 dc.w 144*u,8

 dc.w 121*u,8
 dc.w 96*u,8+v
 dc.w 0,8+d
 dc.w 96*u,8+v
 dc.w 121*u,16+v
 dc.w 144*u,8
 dc.w 144*u,8

 dc.w 182*u,16+v
 dc.w 121*u,16+v
 dc.w 144*u,16+v
 dc.w 182*u,8
 dc.w 182*u,8

 dc.w 144*u,8
 dc.w 144*u,8
 dc.w 121*u,8+v
 dc.w 121*u,8+v
 dc.w 144*u,16+v

 dc.w 182*u,8
 dc.w 182*u,8 ;4bar

 dc.w 144*u,8
 dc.w 144*u,8
 dc.w 96*u,8+v
 dc.w 96*u,8+v
 dc.w 121*u,16+v
 dc.w 144*u,8
 dc.w 144*u,8

 dc.w 121*u,16+v
 dc.w 96*u,16+v
 dc.w 121*u,16+v
 dc.w 144*u,8
 dc.w 144*u,8

 dc.w 182*u,8+v
 dc.w 182*u,8+v
 dc.w 121*u,16
 dc.w 144*u,16+v
 dc.w 182*u,16

 dc.w 144*u,16+v
 dc.w 121*u,16
 dc.w 144*u,16+v
 dc.w 182*u,8
 dc.w 182*u,8 ;

ww8
 dc.w 192*u,16+v
 dc.w 128*u,16
 dc.w 153*u,16+v
 dc.w 192*u,8
 dc.w 192*u,8

 dc.w 153*u,16+v
 dc.w 128*u,8
 dc.w 128*u,8
 dc.w 153*u,16+v
 dc.w 96*u,8
 dc.w 108*u,8

 dc.w 121*u,8
 dc.w 108*u,8
 dc.w 128*u,16+v
 dc.w 153*u,16+v
 dc.w 192*u,8+v
 dc.w 192*u,8+v

ww12
 dc.w 153*u,16+v
 dc.w 0,16+d
 dc.w 153*u,8
 dc.w 172*u,16+v
 dc.w 153*u,8
 dc.w $ffff,$ffff




j=4

NT1
;Am
 DC.W 0,12+d

 dc.w 85*j,2
 dc.w 91*j,2

 DC.W 96*j,8
 DC.W 96*j,8
 dc.w 121*j,8
 dc.w 121*j,8
 DC.W 144*j,8
 DC.W 144*j,8
 dc.w 121*j,8
 dc.w 121*j,8
 dc.w 96*j,8
 dc.w 0,8+d
 DC.W 72*j,32+256


;Dm
 DC.W 2,12+d

 dc.w 96*j,2
 dc.w 102*j,2

 dc.w 108*j,8,91*j,8
 DC.W 108*j,8,91*j,8
 DC.W 108*j,8,91*j,8

 DC.W 108*j,8
 DC.W 108*j,8
 dc.w 91*j,8
 dc.w 0,8+d

 dc.w 81*j,2
 dc.w 76*j,2
 dc.w 72*j,28+256

;Am
 DC.W 2,12+d

 dc.w 128*j,2
 dc.w 136*j,2

 dc.w 144*j,8
 dc.w 121*j,8
 dc.w 144*j,16

 dc.w 121*j,8
 DC.W 96*j,8
 dc.w 121*j,16

 DC.W 144*j,8
 DC.W 144*j,8
 dc.w 121*j,8
 dc.w 121*j,8 
 dc.w 96*j,8
 DC.W 0,8
 DC.W 72*j,16


 DC.W 108*j,8,91*j,8
 DC.W 108*j,8,91*j,8
 DC.W 108*j,8,91*j,8
 DC.W 108*j,8,91*j,8
 DC.W 108*j,8,91*j,8
 DC.W 108*j,8,91*j,8

 DC.W 96*j,8


 dc.w 85*j,1
 dc.w 81*j,1
 dc.w 76*j,14

 DC.W 76*j,8
 DC.W 96*j,8,76*j,8
 DC.W 96*j,8,76*j,8
 DC.W 96*j,8

 dc.w 85*j,1
 dc.w 81*j,1
 dc.w 76*j,14

 dc.w 76*j,8
 DC.W 96*j,8,76*j,8
 DC.W 96*j,8,76*j,8
 DC.W 96*j,8
 dc.w 76*j,16
 DC.W 76*j,8
 DC.W 96*j,8,76*j,8
 DC.W 96*j,8,76*j,8

 dc.w 96*j,8
 DC.W 108*j,8
 DC.W 96*j,8

 dc.w 76*j,8
 DC.W 96*j,8+v 8
 DC.W 96*j,48+v 8

 DC.W $FFFF,$FFFF



z=2
git1 dc.w 0,3 
git
 dc.w 81*z,8+v
 dc.w 72*z,8
 DC.W 0,8
 dc.w 60*z,8+v
 dc.w 72*z,8
 DC.W 0,8
 dc.w 81*z,8+v
 dc.w 72*z,8
 DC.W 0,8
 dc.w 81*z,8+v
 dc.w 72*z,8
 dc.w 81*z,8+v
 dc.w 72*z,8
 dc.w 81*z,8+v
 dc.w 96*z,8
 dc.w 121*z,8+v

 dc.w 108*z,8
 dc.w 96*z,8+v
 DC.W 0,8
 dc.w 108*z,8+v
 dc.w 96*z,8
 DC.W 0,8
 dc.w 108*z,8+v
 dc.w 96*z,8
 DC.W 0,8
 dc.w 108*z,8+v
 dc.w 96*z,16+v


 DC.W 121*z,6
 DC.W 0,2+d
 DC.W 121*z,6
 DC.W 0,2+d

 DC.W 144*z,8
 DC.W 0,8+d

 dc.w 81*z,8
 dc.w 72*z,8
 DC.W 0,8
 dc.w 81*z,8
 dc.w 108*z,8
 DC.W 0,8
 dc.w 121*z,8
 dc.w 72*z,8
 DC.W 0,8
 dc.w 81*z,8
 dc.w 96*z,8
 dc.w 108*z,8
 dc.w 72*z,8
 dc.w 121*z,8
 dc.w 96*z,8
 dc.w 121*z,8

 DC.W 81*z,2
 DC.W 76*z,2
 DC.W 72*z,8

 DC.W 81*z,2
 DC.W 76*z,2
 DC.W 72*z,8

 DC.W 81*z,2
 DC.W 76*z,2
 DC.W 72*z,8

 DC.W 81*z,2
 DC.W 76*z,2
 DC.W 72*z,8

 DC.W 81*z,2
 DC.W 76*z,2
 DC.W 72*z,12

 DC.W 81*z,2
 DC.W 76*z,2
 DC.W 72*z,6

 DC.W 81*z,2
 DC.W 76*z,2
 DC.W 72*z,8

 DC.W 81*z,2
 DC.W 76*z,2
 DC.W 72*z,6

 DC.W 81*z,2
 DC.W 76*z,2
 DC.W 72*z,8

 DC.W 81*z,2
 DC.W 76*z,2
 DC.W 72*z,8
 
 DC.W 81*z,2
 DC.W 76*z,2
 DC.W 72*z,4

 DC.W 81*z,2
 DC.W 76*z,2
 DC.W 72*z,12

 DC.W 72*z,8
 DC.W 81*z,8
 DC.W 96*z,8
 DC.W 108*z,8
 DC.W 121*z,8
 DC.W 144*z,16

 DC.W 144*z,8
 DC.W 121*z,8
 DC.W 108*z,8

 DC.W 96*z,8
 DC.W 96*z,8
 DC.W 81*z,8

 DC.W 81*z,8
 DC.W 72*z,8

 DC.W 72*z,8
 DC.W 81*z,8
 DC.W 96*z,8
 DC.W 108*z,8
 DC.W 108*z,8
 DC.W 121*z,8

 DC.W 108*z,8
 DC.W 108*z,8
 DC.W 96*z,8
 DC.W 72*z,8
 DC.W 144*z,48+v 
 
 DC.W $FFFF,$FFFF


reg
 dc.w 216,1+512
 dc.w 0,31+d

 dc.w 54,1+512
 dc.w 192,1+512
 dc.w 0,30+d
 DC.W $FFFF,$FFFF

goo
 dc.w 0,255+d
 dc.w 72,16+12*256
 dc.w 72,16+12*256
 dc.w 72,16+12*256
 dc.w 72,16+12*256
 dc.w 72,16+12*256
 dc.w 72,16+12*256
 dc.w 72,16+12*256
 dc.w 0,255+d



uu=4
wwx
 dc.w 144*uu,16+v
 dc.w 96*uu,16+v
 dc.w 121*uu,16+v
 dc.w 144*uu,8
 dc.w 144*uu,8

 dc.w 121*uu,8
 dc.w 96*uu,8+v
 dc.w 16,8+12*256 d
 dc.w 96*uu,8+v
 dc.w 121*uu,16+v
 dc.w 144*uu,8
 dc.w 144*uu,8

 dc.w 182*uu,16+v
 dc.w 121*uu,16+v
 dc.w 144*uu,16+v
 dc.w 182*uu,8
 dc.w 182*uu,8

 dc.w 144*uu,8
 dc.w 144*uu,8
 dc.w 121*uu,16+v
 dc.w 144*uu,16+v
 dc.w 182*uu,8
 dc.w 182*uu,8

 dc.w 144*uu,8
 dc.w 144*uu,8
 dc.w 96*uu,16+v
 dc.w 121*uu,16+v
 dc.w 144*uu,8
 dc.w 144*uu,8

 dc.w 121*uu,16+v
 dc.w 96*uu,16+v
 dc.w 121*uu,16+v
 dc.w 144*uu,8
 dc.w 144*uu,8

 dc.w 182*uu,16+v
 dc.w 121*uu,16
 dc.w 144*uu,16+v
 dc.w 182*uu,16

 dc.w 144*uu,16+v
 dc.w 121*uu,16
 dc.w 144*uu,16+v
 dc.w 182*uu,8
 dc.w 182*uu,8

ww88
 dc.w 192*uu,16+v
 dc.w 128*uu,16
 dc.w 153*uu,16+v
 dc.w 192*uu,8
 dc.w 192*uu,8
 dc.w 153*uu,16+v
 dc.w 128*uu,8
 dc.w 128*uu,8
 dc.w 153*uu,16+v

 dc.w 96*uu,8
 dc.w 108*uu,8
 dc.w 121*uu,8
 dc.w 108*uu,8

 dc.w 128*uu,16+v
 dc.w 153*uu,16+v
 dc.w 192*uu,8+v
 dc.w 192*uu,8+v

ww12a
 dc.w 153*uu,16+v
 dc.w 0,24+d
 dc.w 144*zz,8+se
 DC.W 128*zz,16+tt
 dc.w $ffff,$ffff


tt=512
se=13*256
zz=2
tune22 dc.w 0,3+d
TUNE
 dc.w 60*zz,2+tt
 dc.w 120*zz,94+tt
 DC.W 128*zz,16+tt,120*zz,16+tt,108*zz,32+tt
 DC.W 120*zz,16+tt,128*zz,16+tt,120*zz,32+tt
 DC.W 144*zz,12+tt,144*zz,20+se

 DC.W 60*zz,8+tt
 DC.W 60*zz,8+tt
 DC.W 60*zz,8+tt
 DC.W 60*zz,8+tt

 DC.W 72*zz,8+tt
 DC.W 72*zz,8+tt
 DC.W 72*zz,8+tt
 DC.W 72*zz,8+tt

 DC.W 96*zz,8+tt
 DC.W 96*zz,8+tt
 DC.W 96*zz,8+tt
 DC.W 96*zz,8+tt

 DC.W 121*zz,8+tt
 DC.W 121*zz,8+tt
 DC.W 121*zz,8+tt
 DC.W 121*zz,8+tt


 DC.W 144*zz,88+tt

 dc.w 96*zz,8+tt
 dc.w 96*zz,8+tt
 dc.w 96*zz,8+tt
 dc.w 91*zz,8+tt
 dc.w 91*zz,8+tt
; dc.w 0,8+D



tunes1
 dc.w 96*zz,4+tt
 dc.w 96*zz,4+tt
 dc.w 0,16+d
 dc.w 96*4,4+D
 dc.w 0,12+d
 dc.w 96*2,4+D
 dc.w 0,12+d
 dc.w 96,4+D
 dc.w 0,12+d
 DC.W $FFFF,$FFFF

tunes
 dc.w 96,1+tt
 dc.w 96*zz,7+tt
 dc.w 91,1+tt
 dc.w 91*zz,7+tt
 DC.W $FFFF,$FFFF





