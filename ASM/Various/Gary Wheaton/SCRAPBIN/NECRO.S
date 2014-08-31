 CLR.L -(SP)       
 MOVE.W #$20,-(SP) ; Super.
 TRAP #1
 ADDQ.L #6,SP
 MOVE.L D0,SUPER   ; Save old status.

play
******************
 move.b $469,d0  *
ww cmp.b $469,d0 *
 beq.s ww	 *
******************


 bsr vbi


 cmp.b #97,$fffc02
 bne play


	lea	$ff8800,a0	get sound chip 
	move.b	#7,(a0)
	move.b	#%11111111,2(a0) cut out lingering noise
	move.l #$8000000,$ff8800 
	move.l #$9000000,$ff8800 
	move.l #$a000000,$ff8800 


 MOVE.L SUPER,-(SP)
 MOVE.W #$20,-(SP)
 TRAP #1
 ADDQ.L #6,SP

 CLR -(SP)
 TRAP #1





*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

SL EQU $FF8800
SD EQU $FF8802


VBI 

 movem.l d0-d5/a0-a2,-(sp)
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
 clr.b q1
 clr.b q2
 clr.b q3
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
W4 MOVE.L A2,UPTO
 MOVE D3,CUNT
;--END OF VBI
;--------EXIT
 movem.l (sp)+,d0-d5/a0-a2
 ;killer jmp $ffff

asd rts


SUPER DC.L 0
flo dc.b 0,0

UPTO DC.L EE-36
CUNT DC.W 0


 EVEN
;\\RUNNING ORDER SEQUENCE


* don't use pnt4 and pnt0 together
* 	or pnt5 and 1 together

ee
doth
 DC.L PNT4,t1
 DC.L PNT1,j1
 DC.L PNT2,b1
 DC.L PNT3,drm
 DC.B 1,%0001110
 DC.W 511

 DC.L PNT4,wopg
 DC.L PNT1,wopg
 DC.L PNT2,wopg
 DC.L PNT3,drn
 DC.B 1,%0011110
 DC.W 255

 DC.L PNT4,seq
 DC.L PNT1,seq1
 DC.L PNT2,seq2
 DC.L PNT3,drn
 DC.B 1,%0011110
 DC.W 511

 DC.L PNT4,seqd
 DC.L PNT1,seqd
 DC.L PNT2,seqd
 DC.L PNT3,drn
 DC.B 1,%0011110
 DC.W 255

 DC.L PNT4,seq
 DC.L PNT1,seq
 DC.L PNT2,seq2
 DC.L PNT3,drn
 DC.B 1,%0011110
 DC.W 511




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
 MOVE.L D1,6(A1) ;TMP0 \D1.W IS DURATION
 MOVE.L D1,20(A1);TEMP HOLD NOTE
 MOVE.B 26(A1),4(A1)  ;VOL0
 MOVE D1,2(A1)   ;NP0  \SET NEW DURATION
 ADDQ.W #4,(A1)     ;& INC POINTER
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
 BRA.S FCC
EFCT
 DC.L FINK,VIB,WARB,DRUM,HOLD,WB1
 DC.L wrp,wwq,SLR,HOLD,sly,si,dddd,aaaa,dddm

FCC
 AND.L #15,D0
 ASL #2,D0
 MOVE.L EFCT(PC,D0),A0
 JSR (A0)
MAZ CMP #2,20(A1)
 BNE.S DIP
 MOVE.B #35,4(A1)
DIP
 ADDQ.B #1,4(A1)          ;VOL0
 MOVE.B 11(A1),SL
 MOVE.B 21(A1),SD   ;TMP0+1
 MOVE.B 12(A1),SL
 MOVE.B 20(A1),SD   ;TMP0
 CLR D0
 MOVE.B 4(A1),D0
 MOVE.B 10(A1),SL
 MOVE.B 28(A1,D0),SD    ;VOL0
FINK RTS


 DC.B " (C) G.WHEATON.  45 GOLDRILL AVE BOLTON. LANCS, U.K. "
 DC.B " title... ACIDHEAD.     "
 DC.B " Composed by G.Wheaton. "
 DC.B " March 1990. "
 DC.B "   DON'T FUCK AROUND.   "



;-------EFFECTS ROUTINES--------
;1-256---DELAYED--VIBRATO-------
VV EOR.B #1,MC
 BEQ.S SDC
VIB 
 moveq #0,d1
 move.b 4(a1),d1
 CMP #8,d1
 BLT SDC
 SUB.B #1,24(A1)
 BNE SDC
wwq MOVE.B 25(A1),24(A1)
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
 tst.b 4(a1)
 beq.s sax
 move.b #12,4(a1)
SAX addq.b #1,4(a1)
 bra wwq
 ;Lsr 20(A1)
 ;CMP #100*4,20(A1)
 ;BgT.S PLOP
 ;MOVE 6(A1),20(A1)
PLOP RTS


;3--768--------DRUM-----------
DRUM SUBQ.B #4,19(A1)
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
;4 DRUM


;5--1280--
WB1 
 addq.w #2,20(A1)
 rts

;6--1536-----WARB UP---------
WRP 
 addq.b #1,4(a1)
 LSR 20(A1)
 CMP #19,20(A1)
 BGT PLAP
 MOVE 6(A1),20(A1)
PLAP RTS 


;7--1792---


;8--2048---
SLR 
 cmp #144*8,6(a1)
 bge warb
 addq.w #3,6(a1)
 bra warb



;9--2304-------HOLD----------
HOLD move.b #30,4(A1)
 bra wwq
 RTS

;10 slide
sly
 ADDQ.B #3,26(A1)
 addq.b #1,4(a1)
 rts

;11 silent
si move.b #141,4(a1)
 rts


;12
dddd
 addq.b #1,ron+1
 move.b ron+1,d1
 and #6,d1
 move dtb(pc,d1),20(a1)
 rts
 
dtb dc.w 162,108,81/2,53/2
ron dc.b 0,0

;13
aaaa
 addq.b #1,ron
 move.b ron,d1
 and #6,d1
 move atb(pc,d1),20(a1)
 rts
 
atb dc.w 144*1,96*1,72*1,60*1

;14
dddm
 addq.b #1,ron
 move.b ron,d1
 and #6,d1
 move dmt(pc,d1),20(a1)
 rts
 
dmt dc.w 162,108,91/2,53/2






MC DC.B 1,1
MIN DC.B 1,0
;\\\\\\\\\\\\\\DATAS\\\\\\\\\\\\\\\
;\\NOTE 1ST WORD. DURATION 2ND WORD
;\\\LEAD
PNT0 DC.W 0
VC DC.W 1
 DC.W 0
 DC.L 0
 DC.B 8,0,1
 DC.B 0      ;ADD TO NOTE
 DC.W 3      ;VIB LIMIT
 DC.W 2      ;16(A1)  ADD
 DC.W 0      ;VIB 18(A1)
WQ DC.L 0      ;TMP NOTE 20(A1)
 DC.B 1,1    ;VIB RATE 24(A1)
q1 DC.B 0,0    ;INITIAL VOL
;ADSR  28(A1)

 DC.B 15,15,14,13,12,11,9,8,9
 DC.B 10,12,10,8,10,12,10,8,10,10
 DC.B 11,10,10,9,8,7,5,5,6,7,7
 DC.B 6,5,4,3,2,1
 REPT 70
 DS.B 1
 ENDR

 EVEN
;\\\MIDDLE
PNT1 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 9,2,3
 DC.B -1      ;ADD  13(A1)
 DC.W 3       ;VIB LIMIT
 DC.W 2       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
q2 DC.B 245,0     ;INITIAL VOL
;ADSR  28(A1)
 dcb.b 8,12
 dcb.b 8,11
 dcb.b 8,10
 dcb.b 8,9
 dcb.b 8,7
 dcb.b 8,6
 dcb.b 8,5
 dcb.b 16,4
 dcb.b 16,3
 dcb.b 16,2
 dcb.b 16,2
 dcb.b 180,2



 EVEN
;\\\BASS
PNT2 DC.W 0
 DC.W 1          ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,4,5     ;10(A1) VOL REG
 DC.B 1          ;ADD TO NOTE 13(A1)
 DC.W 8          ;VIB LIMIT
 DC.W 7          ;VIBRATO ADD 16(A1)
CC DC.W 2        ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
q3 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
ADSR
 dc.b 15,15,14,13,13,12,11,11,11,10
 dcb.b 8,12
 dcb.b 8,11
 dcb.b 8,10
 dcb.b 8,9
 dcb.b 8,7
 dcb.b 8,6
 dcb.b 8,5
 dcb.b 8,4
 dcb.b 8,3
 dcb.b 8,2
 dcb.b 8,1
 dcb.b 180,0




 EVEN
PNT3 DC.W 0
NP3 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,6,11    ;10(A1) VOL REG
 DC.B 0          ;ADD  13(A1)
 DC.W 0          ;VIB LIMIT
 DC.W 0          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 0,0        ;VIB RATE
q4 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
 DC.B 15,15
 dc.b 13,12,11,10,9
 dc.b 7,5,5,5,3,3,2,1
 
 dcb.b 20,3 
 EVEN


PNT4 DC.W 0
NP4 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0
 DC.B 8,0,1      ;10(A1) VOL REG
 DC.B 0          ;ADD 13(A1)
 DC.W 3          ;VIB LIMIT
 DC.W 4          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
q5 DC.B 1,1        ;VIB RATE
taz DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
 DC.B 14,13,14,13,13,12
 dcb.b 8,12
 dcb.b 8,11
 dcb.b 8,10
 dcb.b 8,9
 dcb.b 8,7
 dcb.b 8,6
 dc.b 7,7,7,7,8,8,8,9,9,9,9
 dcb.b 220,11

 EVEN

PNT5 DC.W 0
 DC.W 1          ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0
 DC.B 9,2,3      ;10(A1) VOL REG
 DC.B 1          ;ADD 13(A1)
 DC.W 3          ;VIB LIMIT
 DC.W 2          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
q6 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)

 dc.b 15,15,14,13,13,12,12,11
 dc.b 10,10,10,9,9
 dcb.b 20,8
 dcb.b 20,9
 dcb.b 8,10
 dcb.b 2,11
 dcb.b 2,12
 dcb.b 2,13
 dcb.b 10,14
 dcb.b 8,13
 dcb.b 8,12
 dcb.b 8,11
 dcb.b 8,10
 dcb.b 8,9
 dcb.b 8,8
 dcb.b 8,7
 dcb.b 16,6 
 dcb.b 16,5 
 dcb.b 16,4 
 dcb.b 16,3 
 dc.b 4,5,6,7,8,9,10,10,10,9,9,8,8,7,7,6,6
 dcb.b 80,5
 EVEN



;-----------MUSIC DATA

s=11*256
v=256
drmm
 dc.w 2,41+1024
 dc.w 11,6+768
 dc.w 2,17+1024
 DC.W $FFFF,$FFFF 



drm
 dc.w 2,41+1024
 dc.w 11,4+768
 dc.w 2,19+1024

 dc.w 2,41+1024
 dc.w 11,4+768
 dc.w 2,19+1024

 dc.w 2,41+1024
 dc.w 11,4+768
 dc.w 2,19+1024

 dc.w 2,41+1024
 dc.w 11,4+768
 dc.w 2,19+1024


 dc.w 2,33+1024
 dc.w 0,1+768
 dc.w 2,7+1024

 dc.w 11,4+768
 dc.w 2,19+1024

 dc.w 2,41+1024
 dc.w 11,4+768
 dc.w 2,19+1024

 dc.w 2,41+1024
 dc.w 11,4+768
 dc.w 2,19+1024

 dc.w 2,41+1024
 dc.w 11,4+768
 dc.w 2,19+1024

 DC.W $FFFF,$FFFF 


de=11*256

null dc.w 0,255+de
 DC.W $FFFF,$FFFF 


w=0
t=1792
i=2

t1
 dc.w 96*i,15+w
 dc.w 0,1+t
 dc.w 121*i,16+w
 dc.w 144*i,16+w

 dc.w 96*i,16+w
 dc.w 91*i,16+w
 dc.w 121*i,16+w
 dc.w 144*i,16+w

 dc.w 91*i,16+w
 dc.w 85*i,16+w
 dc.w 121*i,16+w
 dc.w 144*i,16+w

 dc.w 85*i,16+w
 dc.w 91*i,16+w
 dc.w 121*i,16+w
 dc.w 144*i,16+w

 dc.w 91*i,16+w

 DC.W $FFFF,$FFFF 



q=16
b1
 dc.w 144*q,32+256
 dc.w 96*q,16
 dc.w 144*q,16
 
 dc.w 136*q,32+256
 dc.w 91*q,16
 dc.w 136*q,16

 dc.w 128*q,32+256
 dc.w 85*q,16
 dc.w 128*q,16

 dc.w 136*q,32+256
 dc.w 91*q,16
 dc.w 136*q,16
 DC.W $FFFF,$FFFF 

o=2304

m=1
j1
 dc.w 144*m,32+o
 dc.w 96*m,16+o
 dc.w 144*m,16+o

 dc.w 136*m,32+o
 dc.w 91*m,16+o
 dc.w 136*m,16+o

 dc.w 128*m,32+o
 dc.w 85*m,16+o
 dc.w 128*m,16+o
 
 dc.w 136*m,32+o
 dc.w 91*m,16+o
 dc.w 136*m,16+o

 dc.w $ffff,$ffff

drn
 dc.w 6,4+768
 dc.w 0,12+1024
 dc.w $ffff,$ffff


f=8
wopg
 dc.w 162*f,8
 dc.w 144*f,8
 dc.w 144*f,8
 dc.w 0,8
 dc.w 144*f,24
 dc.w 144*f,8
 dc.w $ffff,$ffff

d=16
seq
 dc.w 72*d,8
 dc.w 81*d,8
 dc.w 96*d,8

 dc.w 144*d,8
 dc.w 121*d,8
 dc.w 128*d,8
 dc.w 144*d,8
 dc.w 144*d,8
 dc.w $ffff,$ffff


seqd
 dc.w 54*d,8
 dc.w 60*d,8

 dc.w 72*d,8
 dc.w 108*d,8
 dc.w 91*d,8
 dc.w 96*d,8
 dc.w 108*d,8
 dc.w 108*d,8
 dc.w $ffff,$ffff


r=d/2
seq1
 dc.w 72*r,4
 dc.w 72*r,4
 dc.w 81*r,4
 dc.w 81*r,4
 dc.w 96*r,4
 dc.w 96*r,4

 dc.w 144*r,8
 dc.w 121*r,8
 dc.w 128*r,8
 dc.w 144*r,8
 dc.w 144*r,8
 dc.w $ffff,$ffff


seq2
 dc.w 144*16,16
 dc.w 144*8,8
 dc.w 144*8,8
 dc.w 144*8,8
 dc.w 144*4,8
 dc.w 144*8,8
 dc.w 144*4,8

 dc.w $ffff,$ffff
