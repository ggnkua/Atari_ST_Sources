* This code is BUDGIE UK licenceware (C) LOST BOYS 1989, 1990

* To assemble, DEVPAC 2 is required.
* Set PREFERENCES to 300K text buffer
* Assemble to disk. Choose SYMBOLS dependent.
* We recommend that you put GENST2 on the main disk in A and assemble
* to B drive if you have a B drive
* ex: assemble to b:\power.prg
* If you only have one drive, split these two demos.
* Put the Megabang on one double-sided disk with GENST2 on it
* and plenty of room for assembly.
* Put the POWER demo on another disk, again with GENST2 and spare room on it
* The POWER demo will assemble to 247961 bytes



* This is the Source Code of the first ever 68000 Lost Boys demo, that's 
* why the code is not the best. If you are interested in more Source or
* demos write to :
*			The Lost Boys PD library
*			12 Cambridge Rd
*			Teddington
*			Middx
*			TW11	8DR
* If you want our Pd list, send us a blank disk and we will get it to you 
* straight away, we have got tons of demos....
* sorry that the code is not documented
*						Sammy Joe of TLB

		clr.l -(sp)
		move.w #$20,-(sp)
		trap #1
		addq.l #6,sp
		move.b #4,$484
		move.l #$31415926,$426  
		move.l #reset,$42a
	even
		lea oldssp,a0
		move.l d0,(a0)
		dc.w $a00a
		move.l #colors,-(a7)
		move.w #6,-(a7)
		trap #14
		addq.l #6,sp
		pea string
		move.w #$1,-(sp)
		move.w #25,-(sp)
		trap #14
		addq.l #8,sp
		move #2,-(sp)
		trap #14
		addq.l #2,sp
		add.l #$5dc0,d0
		move.l d0,phys
		add.l #$500,d0
		move.l d0,phys1
		lea scrolline,a0
		move.b (a0)+,d0
		move.l a0,store
	pea text
	move.w #$9,-(sp)
	trap #1
	addq.l #6,sp
	move.w #2,-(a7)
	trap #14
	addq.l #2,a7
	move.l d0,a1
	lea $12c0(a1),a1
	lea graphix,a0
	move.w #$667,d6
jere	move.l (a0)+,(a1)+
	clr.l (a1)+
	dbf d6,jere
	lea graphix,a0
	lea $19a0(a0),a0
	move.l d0,a1
	lea $76c0(a1),a1
	move.w #$b3,d6
sfere	move.l (a0)+,(a1)+
	clr.l (a1)+
	dbf d6,sfere
		move.l #data-2,a0
		lea data+$1770,a1
		move.w #31,d0
sdere		clr.w (a1)
		clr.w 2(a1)
		clr.w 4(a1)
		clr.w 8(a1)
		clr.w 10(a1)
		clr.w 12(a1)
		adda.l #160,a1				
		add.l #12,a0
		dbf d0,sdere

iea	equ $fffa07
ieb	equ $fffa09
isra	equ $fffa0f
ima	equ $fffa13
tbcr	equ $fffa1b
tbdr 	equ $fffa21
scrn_ram	equ $ff8201
syspal	 	equ $ff8240
shftmod	equ $ff8260
vbl	equ $70
key	equ $118
hbl	equ $120
rawin	equ $7
smode	equ $20
	move.w #$f,d0
	lea syspal,a1
	lea oldpal,a0
sp	move.w (a1)+,(a0)+
	dbra d0,sp
	lea oldieb,a1
	move.b ieb,(a1)
	lea oldiea,a1
	move.b iea,(a1)
	lea oldima,a1
	move.b ima,(a1)
	lea oldshftmod,a1
	move.b shftmod,(a1)
	lea oldkey+2,a1
	move.l key,(a1)
	lea keyhand,a0
	move.l a0,key
	and.b #$df,ieb
	and.b #$fe,iea
	lea oldhbl,a1
	move.l hbl,(a1)
	lea hblhand,a0
	move.l a0,hbl
	or.b #1,iea
	or.b #1,ima
	move.b #0,shftmod
	lea oldvbl+2,a1
	move.l vbl,(a1)
	lea vblhand,a0
	move.l a0,vbl
	move.l #exthun,musicvbl+2
	Jsr sound
gere	move.w #$ff,-(sp)
	move.w #6,-(sp)
	trap #1
	addq.l #4,a7
	tst.w d0
	beq gere
	cmp.b #'1',d0
	beq tri
	cmp.b #'2',d0
	beq tracker
	CMP.B #'3',D0
	BEQ MEGABARS
	cmp.b #'4',d0
	beq CHEAT
	and.b #%11011111,d0
	cmp.b #'M',d0
	beq select
	CMP.B #'B',D0
	beq bigscroll
	bra gere
clear	move.l musicvbl+2,MUSIC2+2
	move.l phys1,a0
	sub.l #$5dc0,a0
	lea 6(a0),a0
	move.w #$aef,d6
cl1	clr.w (a0)+
	adda.l #6,a0
	dbf d6,cl1
	bra.s gere	
select	move.l phys1,a0
	sub.l #$5dc0,a0
	lea 6(a0),a0
	move.l #graphix1,a1
	move.w #$aef,d6
sel1	move.w (a1)+,(a0)+
	adda.l #6,a0
	dbf d6,sel1
loop	move.w #$ff,-(sp)
	move.w #6,-(sp)
	trap #1
	addq.l #4,a7
	tst.w d0
	beq loop
	cmp.b #$31,d0
	beq thunder
	cmp.b #$32,d0
	beq warhawk
	cmp.b #$33,d0
	beq thrust
	cmp.b #$34,d0
	beq xenon1
	cmp.b #$35,d0
	beq xenon2
	cmp.b #$36,d0
	beq ramp1
	cmp.b #$37,d0
	beq ramp2
	cmp.b #$38,d0
	beq leather1
	cmp.b #$39,d0
	beq leather2
	cmp.b #$30,d0
	beq outrun1
	and.b #%11011111,d0
	cmp.b #'W',d0
	beq xenon3
	cmp.b #'Q',d0
	beq outrun2
	cmp.b #'E',d0
	beq gold1
	cmp.b #'R',d0
	beq gold2
	cmp.b #'T',d0
	beq enduro1
	cmp.b #'Y',d0
	beq enduro2
	cmp.b #'U',d0
	beq enduro3
	cmp.b #'I',d0
	beq genesis
	cmp.b #$20,d0
	beq end
	bra loop
thunder move.l #exthun,musicvbl+2
	jsr sound
	bra clear
warhawk move.l #exwar,musicvbl+2
	jsr sound+$17be
	bra clear
thrust	move.l #exthrust,musicvbl+2
	jsr sound+$2b9c
	bra clear
xenon1	move.w #0,d0
	move.l #exxenon,musicvbl+2
	jsr sound+$3e3c
	bra clear
xenon2	move.w #1,d0
	move.l #exxenon,musicvbl+2
	jsr sound+$3e3c
	bra clear
xenon3	move.w #2,d0
	move.l #exxenon,musicvbl+2
	jsr sound+$3e3c
	bra clear
ramp1   move.w #0,d0
	move.l #exramp,musicvbl+2
	jsr sound+$4d3c
	bra clear
ramp2   move.w #1,d0
	move.l #exramp,musicvbl+2
	jsr sound+$4d3c
	bra clear
leather1	move.w #0,d0
	move.l #exleather,musicvbl+2
	jsr sound+$5b02
	bra clear
leather2	move.w #1,d0
	move.l #exleather,musicvbl+2
	jsr sound+$5b02
	bra clear
outrun1	move.w #0,d0
	move.l #exoutrun,musicvbl+2
	jsr sound+$6bd8
	bra clear
outrun2 move.w #1,d0
	move.l #exoutrun,musicvbl+2
	jsr sound+$6bd8
	bra clear
gold1	move.w #0,d0
	move.l #exgold,musicvbl+2
	jsr gold
	bra clear
gold2	move.w #2,d0
	move.l #exgold,musicvbl+2
	jsr gold
	bra clear
enduro1	move.w #0,d0
	move.l #exenduro,musicvbl+2
	jsr enduro
	bra clear
enduro2	move.w #1,d0
	move.l #exenduro,musicvbl+2
	jsr enduro
	bra clear
enduro3	move.w #2,d0
	move.l #exenduro,musicvbl+2
	jsr enduro
	bra clear
genesis	move.w #0,d0
	move.l #exgenesis,musicvbl+2
	jsr gens
	bra clear
reset 	move.w #$2700,sr
	move.b #$2,$ff820a        color palette register 2-13
	lea $23de6,a7
	move.w #2,-(sp)
	trap #14
	addq.l #2,sp
	move.l d0,a1
	lea news+34,a0
	move.w #$fa0,d6
res1	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	dbf d6,res1
 	move.w #-1,-(sp)
 	move.l d0,-(sp)
 	move.l d0,-(sp)
 	move.w #5,-(SP)
 	TRAP #14
 	ADD.L #12,SP
	move.l #$07770000,$ff8240
	move.l #$07000555,$ff8244
	move.l #$06660222,$ff8248
	move.l #$01170227,$ff824c
	move.l #$04440532,$ff8250
	move.l #$06430654,$ff8254
	move.l #$07540765,$ff8258
	move.l #$07210000,$ff825c

ther	bra.s ther

nextcoil		clr.b count
movlcoil		
		move.l #data-2,a0
		lea data+$1770,a1
		move.w #31,d0
here		move.w 2(a0),(a1)
		move.w 4(a0),2(a1)
		move.w 6(a0),4(a1)
		move.w 8(a0),8(a1)
		move.w 10(a0),10(a1)
		move.w 12(a0),12(a1)
		adda.l #160,a1				
		add.l #12,a0
		dbf d0,here
	movem.l (a7)+,d0-d7/a0-a6

		rte
netcoil		clr.b count
		move.l #data-2,a0
		lea data+$1770,a1
		move.w #31,d0
zere		move.w 2(a0),(a1)
		move.w 4(a0),2(a1)
		move.w 6(a0),4(a1)
		move.w 8(a0),8(a1)
		move.w 10(a0),10(a1)
		move.w 12(a0),12(a1)
		adda.l #160,a1				
		add.l #12,a0
		dbf d0,zere
		rte

do_coil:      
dos		move.w #31,d0
		lea data+$1770,a1
		movea.l phys,a0
dos1:           
		lsr.w (a1)
		roxr.w 8(a1)
		roxr.w (a0)
		roxr.w 8(a0)
		roxr.w 16(a0)
		roxr.w 24(a0)
		roxr.w 32(a0)
		roxr.w 40(a0)
		roxr.w 48(a0)
		roxr.w 56(a0)
		roxr.w 64(a0)
		roxr.w 72(a0)
		roxr.w 80(a0)
		roxr.w 88(a0)
		roxr.w 96(a0)
		roxr.w 104(a0)
		roxr.w 112(a0)
		roxr.w 120(a0)
		roxr.w 128(a0)
		roxr.w 136(a0)
		roxr.w 144(a0)
		roxr.w 152(a0)
		lsr.w 2(a1)
		roxr.w 10(a1)
		roxr.w 2(a0)
		roxr.w 10(a0)
		roxr.w 18(a0)
		roxr.w 26(a0)
		roxr.w 34(a0)
		roxr.w 42(a0)
		roxr.w 50(a0)
		roxr.w 58(a0)
		roxr.w 66(a0)
		roxr.w 74(a0)
		roxr.w 82(a0)
		roxr.w 90(a0)
		roxr.w 98(a0)
		roxr.w 106(a0)
		roxr.w 114(a0)
		roxr.w 122(a0)
		roxr.w 130(a0)
		roxr.w 138(a0)
		roxr.w 146(a0)
		roxr.w 154(a0)
		lsr.w 4(a1)
		roxr.w 12(a1)
		roxr.w 4(a0)
		roxr.w 12(a0)
		roxr.w 20(a0)
		roxr.w 28(a0)
		roxr.w 36(a0)
		roxr.w 44(a0)
		roxr.w 52(a0)
		roxr.w 60(a0)
		roxr.w 68(a0)
		roxr.w 76(a0)
		roxr.w 84(a0)
		roxr.w 92(a0)
		roxr.w 100(a0)
		roxr.w 108(a0)
		roxr.w 116(a0)
		roxr.w 124(a0)
		roxr.w 132(a0)
		roxr.w 140(a0)
		roxr.w 148(a0)
		roxr.w 156(a0)
		
                adda.l  #160,a1 
                adda.l  #160,a0 ; 160 bytes: one screen line down
                dbra    d0,dos1 ; do the next screen line
                rts             ; end of routine
nextlet		clr.b count1
movlet		move.l store,a0
		move.b (a0)+,d0
		cmp.b #$ff,d0
		beq wrap
		subi.b #$20,d0
		move.l a0,store
		move.b d0,b
		move.w a,d0
		mulu #$44,d0
		clr.l a
		move.w d0,c
		add.l #font,a
		sub.l #2,a
		move.l a,a0
		move.l a2,a1
		move.w #16,d0
there		move.w 2(a0),6(a1)
		move.w 4(a0),14(a1)

		adda.l #160,a1				
		addq.l #4,a0
		dbf d0,there
	movem.l (a7)+,d0-d7/a0-a6

		rte
netlet		clr.b count1
		move.l store,a0
		move.b (a0)+,d0
		cmp.b #$ff,d0
		beq wrap
		subi.b #$20,d0
		move.l a0,store
		move.b d0,b
		move.w a,d0
		mulu #$44,d0
		clr.l a
		move.w d0,c
		add.l #font,a
		sub.l #2,a
		move.l a,a0
		move.l a2,a1
		move.w #16,d0
fhere		move.w 2(a0),6(a1)
		move.w 4(a0),14(a1)

		adda.l #160,a1				
		addq.l #4,a0
		dbf d0,fhere
		rte

do_scroll:      move.w  #3,d1  ; the letters are 37 pixels high
dosy		move.w #16,d0
		move.l a2,a1
		movea.l phys1,a0
dosy1:           lsl.w   30(a1)  ; scroll 1 pixel to the left
		roxl.w  22(a1)
		roxl.w  14(a1)
                roxl.w  6(a1)   ; the letters are 32 pixels wide
                roxl.w  158(a0) ; scroll the screen
                roxl.w  150(a0) ; steps of -8, scroll one plane
                roxl.w  142(a0)
                roxl.w  134(a0)
                roxl.w  126(a0)
                roxl.w  118(a0)
                roxl.w  110(a0)
                roxl.w  102(a0)
                roxl.w  94(a0)
                roxl.w  86(a0)
                roxl.w  78(a0)
                roxl.w  70(a0)
                roxl.w  62(a0)
                roxl.w  54(a0)
                roxl.w  46(a0)
                roxl.w  38(a0)
                roxl.w  30(a0)
                roxl.w  22(a0)
                roxl.w  14(a0)
                roxl.w  6(a0)
                adda.l  #160,a1 
                adda.l  #160,a0 ; 160 bytes: one screen line down
                dbra    d0,dosy1 ; do the next screen line
		dbra    d1,dosy
                rts             ; end of routine
wrap 		move.b #$20,d0
		lea scrolline,a0
		move.l a0,store
	movem.l (a7)+,d0-d7/a0-a6

		rte
end	move.b oldieb,ieb
	move.b oldiea,iea
	move.b oldima,ima
	move.b oldshftmod,shftmod
	move.l oldkey+2,key
	move.l oldhbl,hbl
	move.l oldvbl+2,vbl
	move.w #$f,d0
	lea syspal,a1
	lea oldpal,a0
respal	move.w (a0)+,(a1)+
	dbra d0,respal
	move.l oldssp,-(sp)
	move.w #smode,-(sp)
	trap #1
	addq.l #6,sp
	clr.w -(sp)
	trap #1


keyhand
	move #$2500,sr
oldkey  jmp $0
hblhand	move.l a1,-(sp)
	move.l palpoint,a1
	move.w (a1)+,$ff8240
	move.l a1,palpoint
	move.l (sp)+,a1
	bclr #0,isra
	move.b #4,tbdr
	rte
vblhand	movem.l d0-d7/a0-a6,-(a7)
musicvbl	jsr exthun
	tst.w test
	beq op1
	clr.w test
	move.l #palettes,palpoint
	bra.s op3
op1	move.l #palettes1,palpoint
	move.w #1,test
op3
	move.w #$137,$ff8240
	move.b #0,tbcr
	move.b #4,tbdr
	move.b #8,tbcr
		move.w #$7d0,d3
de	nop
	dbf d3,de
		bsr do_coil
		move.l #data+$3000,a2
		bsr do_scroll
		addq.b #1,count
		cmp.b #32,count
		move.l #data+$3000,a2
		beq nextcoil
fut		addq.b #1,count1
		cmp.b #8,count1
		beq nextlet
	movem.l (a7)+,d0-d7/a0-a6
	rte

bigscroll
		MOVE.B #$12,$FFFC02
		BSR SCREENPOS
		BSR DECRYPT
		BSR FLIP
		move.w #$2300,sr
		BSR SETINT
		BSR SCRDRAW
		move.w #$0,$ff8240
		MOVE.L SHYS2,D0
MAIN		BSR SCROLL
		BSR PAUSE
		MOVE.W #2,-(A7)
		MOVE.W #1,-(A7)
		TRAP #13
		ADDQ.L #4,A7
		TST.W D0
		BEQ MAIN
		MOVE.W #2,-(A7)
		MOVE.W #2,-(A7)
		TRAP #13
		ADDQ.L #4,A7
		move #2,-(sp)
		trap #14
		addq.l #2,sp
CL	move.l d0,a0
	move.w #$fa0,d2
s	clr.l (a0)+
	clr.l (a0)+
	dbra d2,s
ned		MOVE.W #$2700,SR
		MOVE.L #vblhand,$70
		MOVE.L $44E,D0
		BSR FLIP
		move.l #keyhand,key
		and.b #$df,ieb
		and.b #$fe,iea
		move.l #hblhand,hbl
		or.b #1,iea
		or.b #1,ima
		MOVE.W #$2300,SR
		move.l #$556,$ff8240
		move.l #$05460003,$ff8244
		move.l #$02230334,$ff8248
		move.l #$04450667,$ff824c
		move.l #$07000700,$ff8250
		move.l #$07000700,$ff8254
		move.l #$07000700,$ff8258
		move.l #$04450667,$ff825c
		bra gere
FLIP		MOVE.W D0,-(A7)
		LSR.W #8,D0
		MOVE.L D0,$FF8200
		MOVE.W (A7)+,D0
		RTS



SETINT		MOVE.W #$2700,SR
		MOVE.L #VBL,$70
		MOVE.L #TIMERB,$120
		BCLR #5,$FFFA09
		MOVE.W #$2300,SR
		RTS
SCREENPOS
		MOVE.W #2,-(SP)
		TRAP #14
		ADD.L #2,SP
		SUB.L #$8000,D0
		MOVE.L D0,SHYS1
		MOVE.L D0,SHYS2
		CLR.W PHYSDEC
		CLR.W $FF8240
		RTS
DECRYPT		LEA FONT1,A0
		MOVEA.L SHYS1,A5
		BSR LOAD
		LEA 4(A5),A0
		LEA ENDING,A1
		LEA ENDING+$12c00,A2
		BSR DEC
		LEA FONT2,A0
		MOVEA.L SHYS1,A5
		BSR LOAD
		LEA 4(A5),A0
		LEA ENDING+$4B00,A1
		LEA ENDING+$17700,A2
		BSR DEC
		LEA FONT3,A0
		MOVEA.L SHYS1,A5
		BSR LOAD
		LEA 4(A5),A0
		LEA ENDING+$9600,A1
		LEA ENDING+$1C200,A2
		BSR DEC
		LEA FONT4,A0
		MOVEA.L SHYS1,A5
		BSR LOAD
		LEA 4(A5),A0
		LEA ENDING+$E100,A1
		LEA ENDING+$20D00,A2
		BSR DEC
		RTS
DEC		MOVE.W #4,D5
THERE		MOVE.W #$BF,D4
HERE		CLR.L (A1)+
		MOVE.L (A0),(A1)+
		CLR.B (A2)
		CLR.B 2(A2)
		MOVE.B (A0)+,1(A2)
		MOVE.B (A0)+,4(A2)
		MOVE.B (A0)+,3(A2)
		MOVE.B (A0),6(A2)
		ADDQ.L #5,A0
		ADDQ.L #4,A2
		MOVE.L (A0),(A1)+
		MOVE.B (A0)+,1(A2)
		MOVE.B (A0)+,4(A2)
		MOVE.B (A0)+,3(A2)
		MOVE.B (A0),6(A2)
		ADDQ.L #5,A0
		ADDQ.L #4,A2
		MOVE.L (A0),(A1)+
		MOVE.B (A0)+,1(A2)
		MOVE.B (A0)+,4(A2)
		MOVE.B (A0)+,3(A2)
		MOVE.B (A0),6(A2)
		ADDQ.L #5,A0
		ADDQ.L #4,A2
		MOVE.L (A0),(A1)+
		MOVE.B (A0)+,1(A2)
		MOVE.B (A0)+,4(A2)
		MOVE.B (A0)+,3(A2)
		MOVE.B (A0),6(A2)
		CLR.B  5(A2)
		CLR.B 7(A2)
		LEA $85(A0),A0
		ADDQ.L #8,A2
		DBF D4,HERE
		LEA -$77E0(A0),A0
		DBF D5,THERE
		RTS
LOAD		MOVE.W #$eec,D7
		LEA 4(A5),A5
THA		MOVE.L (A0)+,(A5)+
		CLR.L (A5)+
		DBF D7,THA
		MOVEA.L SHYS1,A5
		RTS
SCROLL		LEA ENDING,A1
		MOVE.W SCTEST,D7
		LSR.W #1,D7
		BCS NEXT
		ADDA.L #$12C00,A1
NEXT		LEA UPPER,A0
		MOVE.W BCOUNT1,D0
		LEA 0(A0,D0.W),A0
		MOVEA.L SHYS2,A3
		LEA $1e04(A3),A3
		BSR S1
		BSR S2
		BSR S2
		BSR S2
		BSR NEW
		SUBI.W #1,SCTEST
		BGE.S JUMP
		MOVE.W #9,SCTEST
		ADDI.W #1,BCOUNT1
		TST.B (A0)
		BNE.S JUMP
		CLR.W BCOUNT1
JUMP		LEA ENDING,A1
		MOVE.W SCTEST1,D7
		LSR.W #1,D7
		BCS JUMP1
		ADDA.L #$12C00,A1
JUMP1		LEA LOWER,A0
		MOVE.W BCOUNT2,D0
		LEA 0(A0,D0.W),A0
		MOVEA.L SHYS2,A3
		LEA $4b04(A3),A3
		BSR S1
		BSR S2
		BSR S2
		BSR S2
		BSR NEW
		SUBI.W #1,SCTEST1
		BGE.S JUMP2
		MOVE.W #9,SCTEST1
		ADDI.W #1,BCOUNT2
		TST.B (A0)
		BNE.S JUMP2
		CLR.W BCOUNT2
JUMP2		RTS
S2		BSR NEXTCHAR
		MOVE.W #$3F,D4
NC		MOVE.L (A2)+,(A3)
		MOVE.L (A2)+,8(A3)
		MOVE.L (A2)+,$10(A3)
		MOVE.L (A2)+,$18(A3)
		MOVE.L (A2)+,$20(A3)
		LEA $A0(A3),A3
		DBF D4,NC
		LEA -$27D8(A3),A3
		RTS
S1		BSR NEXTCHAR
		MOVE.W #4,D0
		SUB.W D7,D0
		LSL.W #2,D0
		LEA 0(A2,D0.W),A2
		MOVE.W #$3F,D4
SC		MOVEA.L A2,A5
		MOVEA.L A3,A4
		MOVE.W D7,D5
MC		MOVE.L (A5)+,(A4)
		ADDQ.L #8,A4
		DBF D5,MC
		LEA $14(A2),A2
		LEA $A0(A3),A3
		DBF D4,SC
		MOVE.W D7,D0
		LSL.W #3,D0
		SUBI.W #$27F8,D0
		LEA 0(A3,D0.W),A3
		RTS
NEW		CMP.W #4,D7
		BEQ.S OUT
		BSR NEXTCHAR
		MOVE.W #3,D6
		SUB.W D7,D6
		MOVE.W #$3F,D4
JKL		MOVEA.L A2,A5
		MOVEA.L A3,A4
		MOVE.W D6,D5
BG		MOVE.L (A5)+,(A4)
		ADDQ.L #8,A4
		DBF D5,BG
		LEA $14(A2),A2
		LEA $A0(A3),A3
		DBF D4,JKL
OUT		RTS
NEXTCHAR	MOVE.B (A0)+,D0
		ANDI.W #$FF,D0
		SUBI.W #$20,D0
		MULU #$500,D0
		LEA 0(A1,D0.L),A2
		RTS
PAUSE		
		MOVE.W D0,-(A7)
		MOVE.W WAIT,D0
NON		CMP.W WAIT,D0
		BEQ.S NON
		MOVE.W (A7)+,D0
		RTS

VBL		MOVEM.L D0-D7/A0-A6,-(A7)
MUSIC2		JSR exthun
		ADDI.W #1,WAIT
		CLR.B $FF8260
		LEA COLS,A0
		MOVEA.L #$FF8242,A1
		MOVE.L (A0)+,(A1)+
		MOVE.W (A0)+,(A1)+
		MOVE.L #$2270022,(A1)+
		MOVE.L #$0220022,(A1)+
		MOVE.L #$3370033,(A1)+
		MOVE.L #$0330033,(A1)+
		MOVE.L #$4470044,(A1)+
		MOVE.L #$0440044,(A1)+
		MOVE.L A0,COLCOUNT
		MOVE.W #$C,CCOUNT
		MOVEA.L #$FFFA00,A0
		MOVE.B #$10,$21(A0)
		MOVE.B #$18,$1B(A0)
		BSET #0,7(A0)
		BSET #0,$13(A0)
		MOVEM.L (A7)+,D0-D7/A0-A6
		RTE
TIMERB		MOVEM.L D0/A0-A1,-(A7)
		MOVEA.L COLCOUNT,A0
		MOVEA.L #$FF8242,A1
		MOVE.L (A0)+,(A1)+
		MOVE.W (A0)+,(A1)+
		MOVE.L A0,COLCOUNT
		ADDI.W #1,MAN
		MOVE.W CCOUNT,D0
		SUBI.W #1,D0
		BEQ.S TB1
		MOVE.W D0,CCOUNT
		CMP.W #5,D0
		BNE.S TB2
		MOVE.L #$0300030,(A1)+
		MOVE.L #$0300030,(A1)+
		MOVE.L #$0400040,(A1)+
		MOVE.L #$0400040,(A1)+
		MOVE.L #$0500050,(A1)+
		MOVE.L #$0500050,(A1)+
lair		MOVEM.L (A7)+,D0/A0-A1
		BCLR #0,$FFFA0F
		RTE
TB2		CMP.W #9,D0
		BNE.S TB3
		MOVE.W #$22,(A1)+
		ADDA.L #6,A1
		MOVE.W #$33,(A1)+
		ADDA.L #6,A1
		MOVE.W #$44,(A1)+
TB3		MOVEM.L (A7)+,D0/A0-A1
		BCLR #0,$FFFA0F
		RTE
TB1		MOVEA.L #$FFFA00,A0
		BCLR #0,7(A0)
		CLR.B $1B(A0)
		MOVEM.L (A7)+,D0/A0-A1
		BCLR #0,$FFFA0F
		RTE
SCRDRAW		MOVEA.L SHYS2,A1
		MOVE.W #5,D7
DUC		LEA SRAPHIX,A0
		MOVE.W #$27F,D6
GUP		MOVE.L (A0)+,(A1)+
		CLR.L (A1)+
		DBF D6,GUP
		DBF D7,DUC
		LEA SRAPHIX1,A0
		MOVEA.L SHYS2,A1
		ADD.L #$A00,A1
		MOVE.W #$27F,D6
HUP		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		DBF D6,HUP
		RTS
trackvbl        movem.l d0-d7/a0-a6,-(sp)
muv		jsr exthun
		move.l #trpal,ppoint
		move.b #0,tbcr
		move.b #2,tbdr
		move.b #8,tbcr
		movem.l (sp)+,d0-d7/a0-a6
oldtrack	jmp $0
trackhbl	
	move.l a1,-(sp)
	move.l ppoint,a1
	move.w (a1)+,$ff8258
	move.l a1,ppoint
	move.l (sp)+,a1
	bclr #0,isra
	move.b #2,tbdr
	rte
ppoint	dc.l trpal
trpal   dc.w $710,$720,$730,$740,$750,$760,$770,$670,$570,$470,$370
	dc.w $270,$170,$70,$71,$72,$73,$74,$75,$76,$77,$67,$57,$47,$37
	dc.w $27,$17,$7,$107,$207,$307,$407,$507,$607,$707,$706,$705
	dc.w $704,$703,$702,$701,$700,$710,$720,$730,$740,$750,$760
	dc.w $770,$670,$570,$470,$370,$270,$170,$70,$71,$72,$73,$74
	dc.w $75,$76,$77,$67,$57,$47,$37,$27,$17,$7,$107,$207,$307
	dc.w $407,$507,$607,$707,$706,$705,$704,$703,$702,$701,$700
	dc.w $710,$720,$730,$740,$750,$760,$770,$670,$570,$470,$370
	dc.w $270,$170,$70,$71,$72,$73,$74,$75,$76,$77,$67,$57,$47
	dc.w $37,$27,$17,$7,$107,$207,$307,$407,$507,$607,$707,$706
	dc.w $705,$704,$703,$702,$701,$700

tracker
	move.l oldvbl+2,oldtrack+2
	move.l musicvbl+2,muv+2
	move.l #trackhbl,hbl
	move.l #trackvbl,vbl
	move.w #2,-(a7)
	trap #14
	addq.l #2,a7
	move.l d0,oldphys
	move.w #3,-(sp)
	trap #14
	addq.l #2,a7
	move.l d0,oldlog

	MOVE.L #SPR_PALETTE,-(SP)
	MOVE.W #6,-(SP)
	TRAP #14
	ADDQ.L #6,SP
	bsr INITIALIZE
	Bra LOW

GO	
fere	move.w #$ff,-(sp)
	move.w #6,-(sp)
	trap #1
	addq.l #4,a7
	tst.w d0
	beq WO
	CMP.B #' ',D0
	BEQ TRACKEX
WO	
	move.w #37,-(sp)
	trap #14
	addq.l #2,sp
	bsr CLEAR
	MOVE.L #sprite1,SPDATA
	move.l  xpoint,a2
	move.w  (a2)+,XXX
	cmp.l #xend,a2
	bge xp1n
dp1	move.l a2,xpoint
	move.l	ypoint,a2
	move.w (a2)+,YYY
	adda.l #2,a2
	cmp.l #yend,a2
	bge yp1n
sp1	move.l a2,ypoint
	BSR	DRAWSPRITE
	MOVE.L #sprite2,SPDATA
	move.l  xpoint1,a2
	move.w  (a2)+,XXX
	cmp.l #xend,a2
	bge xp2n
dp2	move.l a2,xpoint1
	move.l	ypoint1,a2
	move.w (a2)+,YYY
	adda.l #2,a2
	cmp.l #yend,a2
	bge yp2n
sp2	move.l a2,ypoint1

	BSR	DRAWSPRITE
	move.l #sprite3,SPDATA
	move.l  xpoint2,a2
	move.w  (a2)+,XXX
	cmp.l #xend,a2
	bge xp3n
dp3	move.l a2,xpoint2
	move.l	ypoint2,a2
	move.w (a2)+,YYY
	adda.l #2,a2
	cmp.l #yend,a2
	bge yp3n
sp3	move.l a2,ypoint2

	BSR	DRAWSPRITE
	move.l #sprite4,SPDATA
	move.l  xpoint3,a2
	move.w  (a2)+,XXX
	cmp.l #xend,a2
	bge xp4n
dp4	move.l a2,xpoint3
	move.l	ypoint3,a2
	move.w (a2)+,YYY
	adda.l #2,a2
	cmp.l #yend,a2
	bge yp4n
sp4	move.l a2,ypoint3

	BSR	DRAWSPRITE
	move.l #sprite5,SPDATA
	move.l  xpoint4,a2
	move.w  (a2)+,XXX
	cmp.l #xend,a2
	bge xp5n
dp5	move.l a2,xpoint4
	move.l	ypoint4,a2
	move.w (a2)+,YYY
	adda.l #2,a2
	cmp.l #yend,a2
	bge yp5n
sp5	move.l a2,ypoint4

	BSR	DRAWSPRITE
	move.l #sprite2,SPDATA
	move.l  xpoint5,a2
	move.w  (a2)+,XXX
	cmp.l #xend,a2
	bge xp6n
dp6	move.l a2,xpoint5
	move.l	ypoint5,a2
	move.w (a2)+,YYY
	adda.l #2,a2
	cmp.l #yend,a2
	bge yp6n
sp6	move.l a2,ypoint5

	BSR	DRAWSPRITE
	move.l #sprite6,SPDATA
	move.l  xpoint6,a2
	move.w  (a2)+,XXX
	cmp.l #xend,a2
	bge xp7n
dp7	move.l a2,xpoint6
	move.l	ypoint6,a2
	move.w (a2)+,YYY
	adda.l #2,a2
	cmp.l #yend,a2
	bge yp7n
sp7	move.l a2,ypoint6

	BSR	DRAWSPRITE
	move.l #sprite3,SPDATA
	move.l  xpoint7,a2
	move.w  (a2)+,XXX
	cmp.l #xend,a2
	bge xp8n
dp8	move.l a2,xpoint7
	move.l	ypoint7,a2
	move.w (a2)+,YYY
	
	adda.l #2,a2
	cmp.l #yend,a2
	bge yp8n
sp8	move.l a2,ypoint7

	BSR	DRAWSPRITE
	move.l #sprite8,SPDATA
	move.l  xpoint8,a2
	move.w  (a2)+,XXX
	cmp.l #xend,a2
	bge xp9n
dp9	move.l a2,xpoint8
	move.l	ypoint8,a2
	move.w (a2)+,YYY
	
	adda.l #2,a2
	cmp.l #yend,a2
	bge yp9n
sp9	move.l a2,ypoint8
	BSR DRAWSPRITE
	move.l #sprite7,SPDATA
	move.l  xpoint9,a2
	move.w  (a2)+,XXX
	cmp.l #xend,a2
	bge xp10n
dp10	move.l a2,xpoint9
	move.l	ypoint9,a2
	move.w (a2)+,YYY
	
	adda.l #2,a2
	cmp.l #yend,a2
	bge yp10n
sp10	move.l a2,ypoint9
	BSR DRAWSPRITE
	move.l #sprite4,SPDATA
	move.l  xpoint10,a2
	move.w  (a2)+,XXX
	cmp.l #xend,a2
	bge xp11n
dp11	move.l a2,xpoint10
	move.l	ypoint10,a2
	move.w (a2)+,YYY
	
	adda.l #2,a2
	cmp.l #yend,a2
	bge yp11n
sp11    move.l a2,ypoint10
	BSR DRAWSPRITE

	TST.W LSD
	BNE HIGH
	BRA LOW
TRACKEX
		move.w #-1,-(a7)
		move.l oldphys,-(a7)
		move.l oldlog,-(a7)
		move.w #5,-(sp)
		trap #14
		add.l #12,sp
		MOVE.W #$2700,SR
		MOVE.L #vblhand,$70
		move.l #keyhand,key
		and.b #$df,ieb
		and.b #$fe,iea
		move.l #hblhand,hbl
		or.b #1,iea
		or.b #1,ima
		MOVE.W #$2300,SR
		move.l #$556,$ff8240
		move.l #$05460003,$ff8244
		move.l #$02230334,$ff8248
		move.l #$04450667,$ff824c
		move.l #$07000700,$ff8250
		move.l #$07000700,$ff8254
		move.l #$07000700,$ff8258
		move.l #$04450667,$ff825c
		bra gere

list:
XXX:	dc.w	0
YYY:	dc.w	0
SPDATA DC.L 0


*    INSTALLATION ROUTINE   *

INITIALIZE:
	move.w #2,-(sp)
	trap #14
	add.l #2,sp
	sub.l #$8000,d0
	MOVE.L d0,SCREEN1
	SUB.L #$8000,D0
	MOVE.L D0,SCREEN2
	rts

CLEAR 	move.l $44e,a0
	move.l #track,a1
	move.w #$e9b,d2
t	clr.l (a0)+
	move.l (a1)+,(a0)+
	dbra d2,t
	move.w #$105,d2
ld	clr.l (a0)+
	clr.l (a0)+
	dbra d2,ld
	RTS
DRAWSPRITE:
	movem.l 	d0-d7/a0-a3,-(sp)
	move.l 		#0,d0
	move.l 		#0,d1
	lea 		list(pc),a3
	move.w 		(a3)+,d2  * x
	move.w 		(a3)+,d1  * y
	move.l 		(a3),a2   * sdata
	lea		$44e,a1
	move.l 		(a1),a1
	divs   		#16,d2
	swap   		d2
	move.w 		d2,d0
	move.w 		#0,d2
	swap   		d2
	muls   		#8,d2
	add.l  		d2,a1
	muls   		#160,d1
	add.l  		d1,a1
	move.w 		#16,d1
	sub.w  		d0,d1
	move.w 		#15,d7
highs:
	move.l 		#0,d2
	move.w 		#1,d6

	move.w  	(a2),d2
	or.w   		2(a2),d2
	or.w   		4(a2),d2
	or.w   		6(a2),d2
	not.l  		d2      
	ror.l  		d0,d2
lengs	lea 		temp(pc),a3

	move.w 		#1,d3
planes:
	move.w 		(a1),d4
	and.w d2,d4
	move.l 		(a3),d5
	move.w 		(a2)+,d5
	ror.l  		d0,d5     * sprite shift offset
	or.w   		d5,d4
	move.w 		d4,(a1)+  * poke to screen
	move.w 		#0,d5
	ror.l  		d1,d5
	move.l 		d5,(a3)+
	dbra   		d3,planes
	adda.l		#4,a1
	not.l  		d2
	move.w 		#$ffff,d2
	ror.l d1,d2
	not.l d2
	ror.l d0,d2
	dbra   		d6,lengs
	lea 		temp(pc),a3
	move.w 		#1,d3
planes1:
	move.w 		(a1),d4
	move.l 		(a3),d5
	move.l 		#0,(a3)+
	ror.l  		d0,d5   
	or.w   		d5,d4
	move.w 		d4,(a1)+
	dbra   		d3,planes1
	adda.l		#4,a1
	add.l  		#136,a1
	dbra   		d7,highs
	movem.l 	(sp)+,d0-d7/a0-a3
	rts


LOW
	move.l SCREEN2,D0
	LSR.W #8,D0
	MOVE.L D0,$FF8200
	MOVE.L SCREEN1,$44E
	move.w #1,LSD
	BRA GO
HIGH
	MOVE.L SCREEN1,D0
	LSR.W #8,D0
	MOVE.L D0,$FF8200
	MOVE.L SCREEN2,$44E
	CLR.W LSD
	BRA GO

LSD	DS.W 1
*   WORKSPACE  *
temp:   dc.l 0,0,0,0

SPR_PALETTE  dc.w $000,561,593,1136,$333,$333,$333,$333
 dc.w $555,$555,$555,$555,$777,561,593,1136

; data for sprite 1
sprite1   dc.w 64512,0,0,0
 dc.w 33792,63488,0,0
 dc.w 33792,63488,0,0
 dc.w 33792,63488,0,0
 dc.w 33792,63488,0,0
 dc.w 33792,63488,0,0
 dc.w 33792,63488,0,0
 dc.w 33792,63488,0,0
 dc.w 33792,63488,0,0
 dc.w 33792,63488,0,0
 dc.w 34814,63488,0,0
 dc.w 32769,65534,0,0
 dc.w 32769,65534,0,0
 dc.w 32769,65534,0,0
 dc.w 32769,65534,0,0
 dc.w 32766,32766,0,0

; data for sprite 2
sprite2   dc.w 8184,0,0,0
 dc.w 8196,8184,0,0
 dc.w 16386,32764,0,0
 dc.w 32769,65534,0,0
 dc.w 32769,65534,0,0
 dc.w 33153,65534,0,0
 dc.w 33345,64638,0,0
 dc.w 33825,63550,0,0
 dc.w 33825,63550,0,0
 dc.w 33345,64638,0,0
 dc.w 33153,65150,0,0
 dc.w 32769,65534,0,0
 dc.w 32769,65534,0,0
 dc.w 16386,32764,0,0
 dc.w 8196,16380,0,0
 dc.w 8184,8184,0,0


; data for sprite 3
sprite3   dc.w 8184,0,0,0
 dc.w 8196,8184,0,0
 dc.w 16388,32760,0,0
 dc.w 32772,65528,0,0
 dc.w 33784,65528,0,0
 dc.w 33792,63488,0,0
 dc.w 33784,64512,0,0
 dc.w 16388,32760,0,0
 dc.w 8194,16380,0,0
 dc.w 8129,8190,0,0
 dc.w 33,30,0,0
 dc.w 16321,62,0,0
 dc.w 16385,32766,0,0
 dc.w 16386,32764,0,0
 dc.w 16388,32764,0,0
 dc.w 16376,16376,0,0


; data for sprite 4
sprite4   dc.w 32766,0,0,0
 dc.w 32769,65534,0,0
 dc.w 32769,65534,0,0
 dc.w 32769,65534,0,0
 dc.w 32769,65534,0,0
 dc.w 31806,32766,0,0
 dc.w 1056,1984,0,0
 dc.w 1056,1984,0,0
 dc.w 1056,1984,0,0
 dc.w 1056,1984,0,0
 dc.w 1056,1984,0,0
 dc.w 1056,1984,0,0
 dc.w 1056,1984,0,0
 dc.w 1056,1984,0,0
 dc.w 1056,1984,0,0
 dc.w 960,960,0,0


; data for sprite 5
sprite5   dc.w 65528,32768,0,0
 dc.w 32772,65528,0,0
 dc.w 32770,65532,0,0
 dc.w 32769,65534,0,0
 dc.w 34753,65534,0,0
 dc.w 33825,63550,0,0
 dc.w 34753,63550,0,0
 dc.w 32770,65532,0,0
 dc.w 34754,65532,0,0
 dc.w 33825,63550,0,0
 dc.w 34753,63550,0,0
 dc.w 32769,65534,0,0
 dc.w 32769,65534,0,0
 dc.w 32770,65532,0,0
 dc.w 32772,65532,0,0
 dc.w 65528,65528,0,0


; data for sprite 6
sprite6   dc.w 30750,0,0,0
 dc.w 33825,63550,0,0
 dc.w 33345,64638,0,0
 dc.w 33153,65278,0,0
 dc.w 32769,65534,0,0
 dc.w 16386,32764,0,0
 dc.w 8196,16376,0,0
 dc.w 4104,8176,0,0
 dc.w 2064,4064,0,0
 dc.w 1056,1984,0,0
 dc.w 1056,1984,0,0
 dc.w 1056,1984,0,0
 dc.w 1056,1984,0,0
 dc.w 1056,1984,0,0
 dc.w 1056,1984,0,0
 dc.w 960,960,0,0
sprite7   dc.w 30750,0,0,0
 dc.w 33825,63550,0,0
 dc.w 33825,63550,0,0
 dc.w 33825,63550,0,0
 dc.w 33825,63550,0,0
 dc.w 33825,63550,0,0
 dc.w 33729,64574,0,0
 dc.w 32769,65534,0,0
 dc.w 32769,65534,0,0
 dc.w 33729,65534,0,0
 dc.w 33825,63550,0,0
 dc.w 33825,63550,0,0
 dc.w 33825,63550,0,0
 dc.w 33825,63550,0,0
 dc.w 33825,63550,0,0
 dc.w 30750,30750,0,0
sprite8   dc.w 65534,32768,0,0
 dc.w 32769,65534,0,0
 dc.w 32769,65534,0,0
 dc.w 32769,65534,0,0
 dc.w 34814,65534,0,0
 dc.w 34812,63488,0,0
 dc.w 32770,65532,0,0
 dc.w 32770,65532,0,0
 dc.w 32770,65532,0,0
 dc.w 34812,65532,0,0
 dc.w 33792,63488,0,0
 dc.w 34814,63488,0,0
 dc.w 32769,65534,0,0
 dc.w 32769,65534,0,0
 dc.w 32769,65534,0,0
 dc.w 65534,65534,0,0

SCREEN1 DS.L 1
SCREEN2 DS.L 1
yend1
ydat
	dc.w 106,106,112,112,118,118,123,123,128,128,132,132,136,136,139,139,142,142,144,144,146,146,147,147,148,148
	dc.w 147,147,146,146,144,144,142,142,139,139,136,136,132,132,128,128,123,123,118,118,112,112,106,106
	dc.w 99,99,92,92,86,86,80,80,75,75,70,70,66,66,62,62,59,59,56,56,54,54,52,52,51,51
	dc.w 50,50,51,51,52,52,54,54,56,56,59,59,62,62,66,66,70,70,75,75,80,80,86,86,92,92,99,99


	dc.w 106,106,112,112,118,118,123,123,128,128,132,132,136,136,139,139,142,142,144,144,146,146,147,147,148,148
	dc.w 147,147,146,146,144,144,142,142,139,139,136,136,132,132,128,128,123,123,118,118,112,112,106,106
	dc.w 99,99,92,92,86,86,80,80,75,75,70,70,66,66,62,62,59,59,56,56,54,54,52,52,51,51
	dc.w 50,50,51,51,52,52,54,54,56,56,59,59,62,62,66,66,70,70,75,75,80,80,86,86,92,92,99,99


	dc.w 106,106,112,112,118,118,123,123,128,128,132,132,136,136,139,139,142,142,144,144,146,146,147,147,148,148
	dc.w 147,147,146,146,144,144,142,142,139,139,136,136,132,132,128,128,123,123,118,118,112,112,106,106
	dc.w 99,99,92,92,86,86,80,80,75,75,70,70,66,66,62,62,59,59,56,56,54,54,52,52,51,51
	dc.w 50,50,51,51,52,52,54,54,56,56,59,59,62,62,66,66,70,70,75,75,80,80,86,86,92,92,99,99


	dc.w 106,106,112,112,118,118,123,123,128,128,132,132,136,136,139,139,142,142,144,144,146,146,147,147,148,148
	dc.w 147,147,146,146,144,144,142,142,139,139,136,136,132,132,128,128,123,123,118,118,112,112,106,106
	dc.w 99,99,92,92,86,86,80,80,75,75,70,70,66,66,62,62,59,59,56,56,54,54,52,52,51,51
	dc.w 50,50,51,51,52,52,54,54,56,56,59,59,62,62,66,66,72,76,80,85,90,95,100,106,112,118,124,131,138,145,152,160,168

	dc.w 160,152,144,136,128,120,112,105,98,91,84,78,72,66,60,55,50,45,40,36,32,28,24,21,18,15,12,10,8,6,4,3,2,1

	dc.w 0,1,2,3,4,6,8,10,12,15,18,21,24,28,32,36,40,45,50,55,60,66,72,78,84,91,98,105,112,120,128,136,144,152,160,168
	dc.w 160,152,144,136,128,120,112,105,98,91,84,78,72,66,60,55,50,45,40,36,32,28,24,21,18,15,12,10,8,6,4,3,2,1

	dc.w 0,1,2,3,4,6,8,10,12,15,18,21,24,28,32,36,40,45,50,55,60,66,72,78,84,91,98,105,112,120,128,136,144,152,160,168
	dc.w 160,152,144,136,128,120,112,105,98,91,84,78,72,66,60,55,50,45,40,36,32,28,24,21,18,15,12,10,8,6,4,3,2,1

	dc.w 0,1,2,3,4,6,8,10,12,15,18,21,24,28,32,36,40,45,50,55,60,66,72,78,84,91,98,105,112,120,128,136,144,152,160,168
	dc.w 160,152,144,136,128,120,112,105,98,91,84,78,72,66,60,55,50,45,40,36,32,28,24,21,18,15,12,10,8,6,4,3,2,1
	dc.w 0,1,2,3,4,6,8,10,12,15,18,21,24,28,32,36,40,45,50,55,60,66,72,78,84,88,93,99,99

yend	
ypoint	dc.l ydat+32
ypoint1 dc.l ydat+28
ypoint2 dc.l ydat+24
ypoint3 dc.l ydat+20
ypoint4 dc.l ydat+12
ypoint5 dc.l ydat+8
ypoint6 dc.l ydat+4
ypoint7 dc.l ydat
ypoint8 dc.l ydat+40
ypoint9 dc.l ydat+44
ypoint10 dc.l ydat+48
xdat
	dc.w 110,111,112,114,116,119,122,126,130,135,140,146,152,159
xnew	dc.w 166,172,178,183,188,192,196,199,202,204,206,207,208
	dc.w 207,206,204,202,199,196,192,188,183,178,172,166
	dc.w 159,152,146,140,135,130,126,122,119,116,114,112,111

	dc.w 110,111,112,114,116,119,122,126,130,135,140,146,152,159
	dc.w 166,172,178,183,188,192,196,199,202,204,206,207,208
	dc.w 207,206,204,202,199,196,192,188,183,178,172,166
	dc.w 159,152,146,140,135,130,126,122,119,116,114,112,111

	dc.w 110,111,112,114,116,119,122,126,130,135,140,146,152,159
	dc.w 166,172,178,183,188,192,196,199,202,204,206,207,208
	dc.w 207,206,204,202,199,196,192,188,183,178,172,166
	dc.w 159,152,146,140,135,130,126,122,119,116,114,112,111

	dc.w 110,111,112,114,116,119,122,126,130,135,140,146,152,159
	dc.w 166,172,178,183,188,192,196,199,202,204,206,207,208
	dc.w 207,206,204,202,199,196,192,188,183,178,172,166
	dc.w 159,152,146,140,135,130,126,122,119,116,114,112,111

	dc.w 110,111,112,114,116,119,122,126,130,135,140,145,150,156
	dc.w 162,169,176,183,190,197,204,211,218,225,232,239,246,253
	dc.w 259,265,271,276,281,285,289,292,295,297,299,300,301,302
	dc.w 302,301,300,299,297,295,292,289,285,281,276,271,265,259,253,246,239,232,225,218,211,204,197,190,183,176,169,162,155,148,141,134,127
	dc.w 120,113,106,99,92,85,78,71,64,57,50,43,37,31,26,21,17,13,10,7,5,3,2,1

	dc.w 0,1,2,3,5,7,10,13,17,21,26,31,37,43,50,57,64,71,78,85,92,99,106,113,120,127,134,141,148,155,162,169,176,183,190,197,204,211,218,225,232,239,246,253
	dc.w 259,265,271,276,281,285,289,292,295,297,299,300,301,302
	dc.w 302,301,300,299,297,295,292,289,285,281,276,271,265,259,253,246,239,232,225,218,211,204,197,190,183,176,169,162,155,148,141,134,127
	dc.w 120,113,106,99,92,85,78,71,64,57,50,43,37,31,26,21,17,13,10,7,5,3,2,1
	dc.w 0,1,2,3,5,7,10,13,17,21,26,31,37,43,50,57,64,71,78,85,92,99,106,113,120,126,133,139,145,152,159

xend
	
xpoint  dc.l xdat+32
xpoint1	dc.l xdat+28
xpoint2	dc.l xdat+24
xpoint3	dc.l xdat+20
xpoint4	dc.l xdat+12
xpoint5	dc.l xdat+8
xpoint6	dc.l xdat+4
xpoint7 dc.l xdat
xpoint8 dc.l xdat+40
xpoint9 dc.l xdat+44
xpoint10 dc.l xdat+48
	
yp1n	move.l #ydat,a2
	bra sp1	
yp2n	move.l #ydat,a2
	bra sp2	
yp3n	move.l #ydat,a2
	bra sp3	
yp4n	move.l #ydat,a2
	bra sp4	
yp5n	move.l #ydat,a2
	bra sp5	
yp6n	move.l #ydat,a2
	bra sp6	
yp7n	move.l #ydat,a2
	bra sp7	
yp8n	move.l #ydat,a2
	bra sp8	
yp9n	move.l #ydat,a2
	bra sp9	
yp10n	move.l #ydat,a2
	bra sp10	
yp11n	move.l #ydat,a2
	bra sp11	

xp1n	move.l #xnew,a2
	bra dp1		
xp2n	move.l #xnew,a2
	bra dp2		
xp3n	move.l #xnew,a2
	bra dp3		
xp4n	move.l #xnew,a2
	bra dp4		
xp5n	move.l #xnew,a2
	bra dp5		
xp6n	move.l #xnew,a2
	bra dp6		
xp7n	move.l #xnew,a2
	bra dp7		
xp8n	move.l #xnew,a2
	bra dp8		
xp9n	move.l #xnew,a2
	bra dp9		
xp10n	move.l #xnew,a2
	bra dp10		
xp11n	move.l #xnew,a2
	bra dp11		

newmu	movem.l d0-d7/a0-a6,-(sp)
mj	jsr exthun
	movem.l (sp)+,d0-d7/a0-a6


oldvbl		jmp $0
oldphys dc.l 0
oldlog	dc.l 0
FO	DC.W 0
tri
	movem.l d0-d7/a0-a6,-(a7)
	bsr trian
	movem.l (a7)+,d0-d7/a0-a6
	bsr gere

trian	move.l musicvbl+2,mj+2
	move.b oldieb,ieb
	move.b oldiea,iea
	move.b oldima,ima
	move.l oldkey+2,key
	move.l oldhbl,hbl
	move.l #newmu,vbl
	move.l #$0000777,$ff8240
	move.w #2,-(a7)
	trap #14
	addq.l #2,a7
	move.l d0,oldphys
	move.w #3,-(sp)
	trap #14
	addq.l #2,a7
	move.l d0,oldlog

		JSR START1
		JSR INLINEA
		JSR DRAIN
MA		move.w #-1,-(a7)
		move.l oldphys,-(a7)
		move.l oldlog,-(a7)
		move.w #5,-(sp)
		trap #14
		add.l #12,sp
		MOVE.W #$2700,SR
		MOVE.L #vblhand,$70
		move.l #keyhand,key
		and.b #$df,ieb
		and.b #$fe,iea
		move.l #hblhand,hbl
		or.b #1,iea
		or.b #1,ima
		MOVE.W #$2300,SR
		move.l #$556,$ff8240
		move.l #$05460003,$ff8244
		move.l #$02230334,$ff8248
		move.l #$04450667,$ff824c
		move.l #$07000700,$ff8250
		move.l #$07000700,$ff8254
		move.l #$07000700,$ff8258
		move.l #$04450667,$ff825c
		rts

PAGEUP		MOVE.W #-1,-(A7)
		MOVE.L PHYSBASE,-(A7)
		MOVE.L LOGBASE,-(A7)
		MOVE.W #5,-(A7)
		TRAP #14
		ADD.L #12,A7
		RTS

PAGEDOWN	MOVE.W #-1,-(A7)
		MOVE.L LOGBASE,-(A7)
		MOVE.L PHYSBASE,-(A7)
		MOVE.W #5,-(A7)
		TRAP #14
		ADD.L #12,A7
		RTS

CLWORK		
	pea text
	move.w #$9,-(sp)
	trap #1
	addq.l #6,sp
	rts



START1		MOVE.W #2,-(A7)
		TRAP #14
		ADDQ.L #2,A7
		SUB.L #$8000,D0
		MOVE.L D0,PHYSBASE
		SUB.L #$8000,D0
		MOVE.L D0,LOGBASE
		move.w #-1,-(a7)
		move.l PHYSBASE,-(SP)
		MOVE.L LOGBASE,-(SP)
		MOVE.W #5,-(SP)
		TRAP #14
		ADD.L #12,SP
		RTS


DRAW1		MOVEM.L D0-D7/A0-A6,-(A7)
		MOVE.W D2,D6
		MOVE.W D3,D7
		JSR REL_POS
		MOVE.W D1,CODE1
		MOVE.W A2,D6
		MOVE.W A3,D7
		JSR REL_POS
		MOVE.W D1,CODE2
		TST.W D1
		BNE TESTW1
		TST.W CODE1
		BEQ DRAWIT2
TESTW1 		MOVE.W D1,D0
		AND.W CODE1,D0
		BNE DRAWEND
		MOVE.W D2,A0
		MOVE.W D3,A1
		MOVE.W A2,A4
		MOVE.W A3,A5
		TST.W CODE2
		BNE TESTW2
		MOVE.W A2,RIGHTX
		MOVE.W A3,RIGHTY
		BRA TESTW3
TESTW2		MOVE.W CODE1,P1CODE
		MOVE.W CODE2,P2CODE
		JSR FNDPOINT
		TST.W P1CODE
		BNE DRAWEND
		MOVE.W D2,RIGHTX
		MOVE.W D3,RIGHTY
TESTW3		MOVE.W A4,D2
		MOVE.W A5,D3
		MOVE.W A0,A2
		MOVE.W A1,A3
		MOVE.W CODE2,P1CODE
		MOVE.W CODE1,P2CODE
		TST.W P2CODE
		BNE TESTW4
		MOVE.W A2,LEFTX
		MOVE.W A3,LEFTY
		BRA DRAWIT1
TESTW4		JSR FNDPOINT
		MOVE.W D2,LEFTX
		MOVE.W D3,LEFTY
DRAWIT1		MOVE.W LEFTX,D2
		MOVE.W LEFTY,D3
		MOVE.L #0,A2
		MOVE.L #0,A3
		MOVE.W RIGHTX,A2
		MOVE.W RIGHTY,A3
DRAWIT2		MOVE.L LINEAVAR,A0
		MOVE.W D2,38(A0)
		MOVE.W D3,40(A0)
		MOVE.W A2,42(A0)
		MOVE.W A3,44(A0)
		DC.W $A003
DRAWEND
ENDIT		MOVEM.L (A7)+,D0-D7/A0-A6
		RTS


SINCOS		TST.W D0
		BPL NOADDI
		ADD.W #360,D0
NOADDI		MOVE.L #SINTAB,A1
		MOVE.L D0,D2
		LSL.W #1,D0
		MOVE.W 0(A1,D0.W),D1
		CMP.W #270,D2
		BLT PLUS9
		SUB.W #270,D2
		BRA SENDSIN
PLUS9		ADD.W #90,D2
SENDSIN		LSL.W #1,D2
		MOVE.W 0(A1,D2.W),D2
		RTS

SIN		MOVE.L #SINTAB,A1
		TST.W D0
		BPL SIN1
		ADD.W #360,D0
SIN1		LSL.W #1,D0
		MOVE.W 0(A1,D0.W),D1
		RTS

MATINIT		MOVE.W #0,D1
		MOVE.W #16384,D2
		MOVE.W D2,MATRIX11
		MOVE.W D1,MATRIX12
		MOVE.W D1,MATRIX13
		MOVE.W D1,MATRIX21
		MOVE.W D2,MATRIX22
		MOVE.W D1,MATRIX23
		MOVE.W D1,MATRIX31
		MOVE.W D1,MATRIX32
		MOVE.W D2,MATRIX33
		RTS

XROTATE		MOVE.W XANGLE,D0
		JSR SINCOS
		MOVE.W D1,SINX
		MOVE.W D2,COSX
		MOVE.W D1,D3
		MOVE.W D2,D4
		MOVE.W MATRIX11,ROTX11
		MOVE.W MATRIX21,ROTX21
		MOVE.W MATRIX31,ROTX31
		MULS MATRIX12,D2
		MULS MATRIX13,D1
		SUB.L D1,D2
		LSL.L #2,D2
		SWAP D2
		MOVE.W D2,ROTX12
		MOVE.W D3,D1
		MOVE.W D4,D2
		MULS MATRIX22,D2
		MULS MATRIX23,D1
		SUB.L D1,D2
		LSL.L #2,D2
		SWAP D2
		MOVE.W D2,ROTX22
		MOVE.W D3,D1
		MOVE.W D4,D2
		MULS MATRIX32,D2
		MULS MATRIX33,D1
		SUB.L D1,D2
		LSL.L #2,D2
		SWAP D2
		MOVE.W D2,ROTX32
		MOVE.W D3,D1
		MOVE.W D4,D2
		MULS MATRIX12,D1
		MULS MATRIX13,D2
		ADD.L D1,D2
		LSL.L #2,D2
		SWAP D2
		MOVE.W D2,ROTX13
		MOVE.W D3,D1
		MOVE.W D4,D2
		MULS MATRIX22,D1
		MULS MATRIX23,D2
		ADD.L D1,D2
		LSL.L #2,D2
		SWAP D2
		MOVE.W D2,ROTX23
		MULS MATRIX32,D3
		MULS MATRIX33,D4
		ADD.L D3,D4
		LSL.L #2,D4
		SWAP D4
		MOVE.W D4,ROTX33
		MOVE.L #ROTX11,A1
		MOVE.L #MATRIX11,A2
		MOVE.L #9,D7
		SUBQ.L #1,D7
ROTXLOP1	MOVE.W (A1)+,(A2)+
		DBRA D7,ROTXLOP1
		RTS

YROTATE		MOVE.W YANGLE,D0
		JSR SINCOS
		MOVE.W D1,SINY
		MOVE.W D2,COSY
		MOVE.W D1,D3
		MOVE.W D2,D4
		MULS MATRIX11,D2
		MULS MATRIX13,D1
		ADD.L D1,D2
		LSL.L #2,D2
		SWAP D2
		MOVE.W D2,ROTX11
		MOVE.W D3,D1
		MOVE.W D4,D2
		MULS MATRIX21,D2
		MULS MATRIX23,D1
		ADD.L D1,D2
		LSL.L #2,D2
		SWAP D2
		MOVE.W D2,ROTX21
		MOVE.W D3,D1
		MOVE.W D4,D2
		MULS MATRIX31,D2
		MULS MATRIX33,D1
		ADD.L D1,D2
		LSL.L #2,D2
		SWAP D2
		MOVE.W D2,ROTX31
		NEG.W D3
		MOVE.W D3,D1
		MOVE.W D4,D2
		MOVE.W MATRIX12,ROTX12
		MOVE.W MATRIX22,ROTX22
		MOVE.W MATRIX32,ROTX32
		MULS MATRIX11,D1
		MULS MATRIX13,D2
		ADD.L D1,D2
		LSL.L #2,D2
		SWAP D2
		MOVE.W D2,ROTX13
		MOVE.W D3,D1
		MOVE.W D4,D2
		MULS MATRIX21,D1
		MULS MATRIX23,D2
		ADD.L D1,D2
		LSL.L #2,D2
		SWAP D2
		MOVE.W D2,ROTX23
		MULS MATRIX31,D3
		MULS MATRIX33,D4
		ADD.L D3,D4
		LSL.L #2,D4
		SWAP D4
		MOVE.W D4,ROTX33
		MOVE.L #8,D7
		MOVE.L #ROTX11,A1
		MOVE.L #MATRIX11,A2
YROTLOP1	MOVE.W (A1)+,(A2)+
		DBRA D7,YROTLOP1
		RTS

ZROTATE		MOVE.W ZANGLE,D0
		JSR SINCOS
		MOVE.W D1,SINZ
		MOVE.W D2,COSZ
		MOVE.W D1,D3
		MOVE.W D2,D4
		MULS MATRIX11,D2
		MULS MATRIX12,D1
		SUB.L D1,D2	
		LSL.L #2,D2
		SWAP D2
		MOVE.W D2,ROTX11
		MOVE.W D3,D1
		MOVE.W D4,D2
		MULS MATRIX21,D2
		MULS MATRIX22,D1
		SUB.L D1,D2
		LSL.L #2,D2
		SWAP D2
		MOVE.W D2,ROTX21
		MOVE.W D3,D1
		MOVE.W D4,D2
		MULS MATRIX31,D2
		MULS MATRIX32,D1
		SUB.L D1,D2
		LSL.L #2,D2
		SWAP D2
		MOVE.W D2,ROTX31
		MOVE.W D3,D1
		MOVE.W D4,D2
		MULS MATRIX11,D1
		MULS MATRIX12,D2
		ADD.L D1,D2
		LSL.L #2,D2
		SWAP D2
	 	MOVE.W D2,ROTX12
		MOVE.W D3,D1
		MOVE.W D4,D2
		MULS MATRIX21,D1
		MULS MATRIX22,D2
		ADD.L D1,D2
		LSL.L #2,D2
		SWAP D2
		MOVE.W D2,ROTX22
		MULS MATRIX31,D3
		MULS MATRIX32,D4
		ADD.L D3,D4
		LSL.L #2,D4
		SWAP D4
		MOVE.W D4,ROTX32
		MOVE.W MATRIX13,ROTX13
		MOVE.W MATRIX23,ROTX23
		MOVE.W MATRIX33,ROTX33
		MOVE.L #8,D7
		MOVE.L #ROTX11,A1
		MOVE.L #MATRIX11,A2
ZROTLOP1	MOVE.W (A1)+,(A2)+
		DBRA D7,ZROTLOP1
		RTS

ROTATE 		MOVE.W NUMMARK,D0
		EXT.L D0
		SUBQ.L #1,D0
		MOVE.L DATX,A1
		MOVE.L DATY,A2
		MOVE.L DATZ,A3
		MOVE.L POINTX,A4
		MOVE.L POINTY,A5
		MOVE.L POINTZ,A6
ROTATE1		MOVE.W (A1)+,D1
		ADD.W OFFX,D1
		MOVE.W D1,D4
		MOVE.W (A2)+,D2
		ADD.W OFFY,D2
		MOVE.W D2,D5
		MOVE.W (A3)+,D3
		ADD.W OFFZ,D3
		MOVE.W D3,D6
		MULS MATRIX11,D1
		MULS MATRIX21,D2
		MULS MATRIX31,D3
		ADD.L D1,D2
		ADD.L D2,D3
		LSL.L #2,D3
		SWAP D3
		ADD.W XOFFS,D3	
		MOVE.W D3,(A4)+
		MOVE.W D4,D1
		MOVE.W D5,D2
		MOVE.W D6,D3
		MULS MATRIX12,D1
		MULS MATRIX22,D2
		MULS MATRIX32,D3
		ADD.L D1,D2
		ADD.L D2,D3
		LSL.L #2,D3
		SWAP D3
		ADD.W YOFFS,D3
		MOVE.W D3,(A5)+
		MULS MATRIX13,D4
		MULS MATRIX23,D5
		MULS MATRIX33,D6
		ADD.L D4,D5
		ADD.L D5,D6
		LSL.L #2,D6
		SWAP D6
		ADD.W ZOFFS,D6
		MOVE.W D6,(A6)+
		DBRA D0,ROTATE1
		RTS

PERS		MOVE.L POINTX,A1
		MOVE.L POINTY,A2
		MOVE.L POINTZ,A3
		MOVE.L XPLOT,A4
		MOVE.L YPLOT,A5
		MOVE.W NUMMARK,D0
		EXT.L D0
		SUBQ.L #1,D0
PERLOP		MOVE.W (A3)+,D5
		MOVE.W D5,D6
		MOVE.W DIST,D4
		SUB.W D5,D4
		EXT.L D4
		LSL.L #8,D4
		MOVE.W ZOBS,D3
		EXT.L D3
		SUB.L D6,D3
		BNE PERS1
		MOVE.W #0,D1
		ADDQ.L #2,A1
		ADDQ.L #2,A2
		MOVE.W D1,(A4)+
		MOVE.W D1,(A5)+
		BRA PEREND1
PERS1		DIVS D3,D4
		MOVE.W D4,D3
		MOVE.W (A1)+,D1
		MOVE.W D1,D2
		NEG.W D1
		MULS D1,D3
		LSR.L #8,D3
		ADD.W D3,D2
		ADD.W X0,D2
		MOVE.W D2,(A4)+	
		MOVE.W (A2)+,D1
		MOVE.W D1,D2
		NEG.W D1
		MULS D1,D4
		LSR.L #8,D4
		ADD.W D4,D2
		NEG.W D2
		ADD.W Y0,D2
		MOVE.W D2,(A5)+
PEREND1		DBRA D0,PERLOP
		RTS

DRAWN1		MOVE.L XPLOT,A4
		MOVE.L YPLOT,A5
		MOVE.W NUMLINE,D0
		EXT.L D0
		SUBQ.L #1,D0
		MOVE.L LINXY,A6
DRLOP		MOVE.L (A6)+,D1
		SUBQ.W #1,D1
		LSL.W #1,D1
		MOVE.W 0(A4,D1.W),D2
		MOVE.W 0(A5,D1.W),D3
		SWAP D1
		SUBQ.W #1,D1
		LSL.W #1,D1
		MOVE.W 0(A4,D1.W),A2
		MOVE.W 0(A5,D1.W),A3
		JSR DRAW1
		DBRA D0,DRLOP
		RTS


INKEY		MOVE.W #2,-(A7)
		MOVE.W #1,-(A7)
		TRAP #13
		ADDQ.L #4,A7
		TST.W D0
		BPL ENDKEY
		MOVE.W #7,-(A7)
		TRAP #1
		ADDQ.L #2,A7
ENDKEY		RTS

YROT		MOVE.W YANGLE,D0
		JSR SINCOS
		MOVE.W D1,SINY
		MOVE.W D2,COSY
		MOVE.L DATX,A1
		MOVE.L DATY,A2
		MOVE.L DATZ,A3
		MOVE.L POINTX,A4
		MOVE.L POINTY,A5
		MOVE.L POINTZ,A6
		MOVE.W NUMMARK,D0
		EXT.L D0
		SUBQ.L #1,D0
YLOP		MOVE.W (A1)+,D1
		MOVE.W D1,D3
		MOVE.W (A3)+,D2
		MOVE.W D2,D4
		MULS COSY,D2
		LSL.L #2,D2
		SWAP D2
		MULS SINY,D1
		LSL.L #2,D1
		SWAP D1		
		ADD.W D1,D2
		MOVE.W D2,(A6)+
		MULS SINY,D4
		LSL.L #2,D4
		SWAP D4
		NEG.W D4
		MULS COSY,D3
		LSL.L #2,D3
		SWAP D3
		ADD.W D3,D4
		MOVE.W D4,(A4)+
		MOVE.W (A2)+,(A5)+
		DBRA D0,YLOP
		RTS
REL_POS		CLR.L D1
		MOVE.W D7,D1
		SUB.W CLIPYULE,D1
		LSL.L #1,D1
		MOVE.W D7,D1
		SUB.W CLIPYLRI,D1
		NEG.W D1
		LSL.L #1,D1
		MOVE.W D6,D1
		SUB.W CLIPXLRI,D1
		NEG.W D1
		LSL.L #1,D1
		MOVE.W D6,D1
		SUB.W CLIPXULE,D1
		LSL.L #1,D1
		SWAP D1
		RTS

FNDPOINT	MOVE.W D2,D4
		MOVE.W D3,D5
		ADD.W A2,D4
		EXT.L D4
		LSR.L #1,D4
		ADD.W A3,D5
		EXT.L D5
		LSR.L #1,D5
		MOVE.W D4,D6
		MOVE.W D5,D7
		JSR REL_POS
		MOVE.W P2CODE,D6
		AND.W D1,D6
		BNE FOTHER
		CMP.W D4,D2
		BNE FINDW1
		CMP.W D5,D3
		BEQ FENDIT
FINDW1		CMP.W D4,A2
		BNE FINDW2
		CMP.W D5,A3
		BNE FINDW2
		BRA FENDIT
FINDW2		MOVE.W D4,D2
		MOVE.W D5,D3
		MOVE.W D1,P1CODE
		BRA FNDPOINT
FOTHER		CMP.W D4,A2
		BNE FOTHER1
		CMP.W D5,A3
		BEQ FENDIT
FOTHER1		CMP.W D4,D2
		BNE FOTHER2
		CMP.W D5,D3
		BEQ FENDIT
FOTHER2		TST.W P1CODE
		BEQ FOTHER3
		MOVE.W D1,D7
		AND.W P1CODE,D7
		BNE FEXIT
FOTHER3 	MOVE.W D4,A2
		MOVE.W D5,A3
		MOVE.W D1,P2CODE
		BRA FNDPOINT
FEXIT		MOVE.W #1,P1CODE
FENDIT		RTS

SINTAB		DC.W 0,286,572,857,1143,1428,1713,1997,2280
		DC.W 2563,2845,3126,3406,3686,3964,4240,4516
		DC.W 4790,5063,5334,5604,5872,6138,6402,6664
		DC.W 6924,7182,7438,7692,7943,8192,8438,8682
		DC.W 8923,9162,9397,9630,9860,10087,10311,10531
		DC.W 10749,10963,11174,11381,11585,11786,11982,12176
		DC.W 12365,12551,12733,12911,13085,13255,13421,13583
		DC.W 13741,13894,14044,14189,14330,14466,14598,14726
		DC.W 14849,14962,15082,15191,15296,15396,15491,15582
		DC.W 15668,15749,15826,15897,15964,16026,16083,16135
		DC.W 16182,16225,16262,16294,16322,16344,16362,16374
		DC.W 16382,16384
		DC.W 16382,16374,16362,16344,16322,16294,16262,16225
		DC.W 16182
		DC.W 16135,16083,16026,15964,15897,15826,15749,15668
		DC.W 15582,15491,15396,15296,15191,15082,14962,14849
		DC.W 14726,14598,14466,14330,14189,14044,13894,13741
		DC.W 13583,13421,13255,13085,12911,12733,12551,12365
		DC.W 12176,11982,11786,11585,11381,11174,10963,10749
		DC.W 10531,10311,10087,9860,9630,9397,9162,8923
		DC.W 8682,8438,8192,7943,7692,7438,7182,6924
		DC.W 6664,6402,6138,5872,5604,5334,5063,4790
		DC.W 4516,4240,3964,3686,3406,3126,2845,2563
		DC.W 2280,1997,1713,1428,1143,857,572,286,0
		DC.W -286,-572,-857,-1143,-1428,-1713,-1997,-2280
		DC.W -2563,-2845,-3126,-3406,-3686,-3694,-4240,-4516
		DC.W -4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
		DC.W -6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682
		DC.W -8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
		DC.W -10749,-10963,-11174,-11381,-11585,-11786,-11982
		DC.W -12176
		DC.W -12365,-12551,-12733,-12911,-13085,-13255,-13421
		DC.W -13583
		DC.W -13741,-13894,-14044,-14189,-14330,-14466,-14598
		DC.W -14726
		DC.W -14849,-14962,-15082,-15191,-15296,-15396,-15491
		DC.W -15582
		DC.W -15668,-15749,-15826,-15897,-15964,-16026,-16083
		DC.W -16135
		DC.W -16182,-16225,-16262,-16294,-16322,-16344,-16362
		DC.W -16374,-16382,-16384
		DC.W -16382,-16374,-16362,-16344,-16322,-16294,-16262
		DC.W -16225,-16182
		DC.W -16135,-16083,-16026,-15964,-15897,-15826,-15749
		DC.W -15668
		DC.W -15582,-15491,-15396,-15296,-15191,-15082,-14962
		DC.W -14849
		DC.W -14726,-14598,-14466,-14330,-14189,-14044,-13894
		DC.W -13741
		DC.W -13583,-13421,-13255,-13085,-12911,-12733,-12551
		DC.W -12365
		DC.W -12176,-11982,-11786,-11585,-11381,-11174,-10963
		DC.W -10749
		DC.W -10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
		DC.W -8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
		DC.W -6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
		DC.W -4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
		DC.W -2280,-1997,-1713,-1428,-1143,-857,-572,-286,0

INLINEA		DC.W $A000
		MOVE.L A0,LINEAVAR
		MOVE.W #0,32(A0)
		MOVE.W #$FFFF,34(A0)
		MOVE.W #0,36(A0)
		MOVE.W #1,24(A0)
		RTS

X0		DS.W 1
Y0		DS.W 1
Z0		DS.W 1
Z1		DS.W 1
LINXY		DS.L 1
NUMMARK		DS.W 1
NUMLINE		DS.W 1
POINTX		DS.L 1
POINTY		DS.L 1
POINTZ		DS.L 1
XPLOT		DS.L 1
YPLOT 		DS.L 1
DATX		DS.L 1
DATY		DS.L 1
DATZ		DS.L 1
SINX		DS.W 1
SINZ		DS.W 1
SINY		DS.W 1
COSX		DS.W 1
COSZ		DS.W 1
COSY		DS.W 1
VAR1		DS.W 1
VAR2		DS.W 1
VAR3		DS.W 1
XANGLE		DS.W 1
YANGLE		DS.W 1
ZANGLE 		DS.W 1
PHYSBASE	DS.L 1
LOGBASE		DS.L 1

CONTRL
OPCODE		DS.W 1
SINTIN 		DS.W 1
SINTOUT 	DS.W 1
SADDRIN		DS.W 1
SADDROUT	DS.W 1
		DS.W 6
GLOBAL
APVERSION	DS.W 1
APCOUNT		DS.W 1
APID		DS.W 1
APPRIVATE	DS.L 1
APPTREE		DS.L 1
AP1RESV		DS.L 1
AP2RESV		DS.L 1
AP3RESV		DS.L 1
AP4RESV		DS.L 1
INTIN		DS.W 128
PTSIN 		DS.W 256
INTOUT		DS.W 128
PTSOUT 		DS.W 128
ADDRIN		DS.W 128
ADDROUT		DS.W 128
GRHANDLE	DS.W 1
LINEAVAR	DS.L 1
VDIPB 		DC.L CONTRL,INTIN,PTSIN,INTOUT,PTSOUT
AESPB		DC.L CONTRL,GLOBAL,INTIN,INTOUT,ADDRIN,ADDROUT
LEFTX		DC.W 0
LEFTY		DC.W 0
RIGHTX		DC.W 0
RIGHTY		DC.W 0
P1CODE		DC.W 0
P2CODE		DC.W 0
CODE1		DC.W 0
CODE2		DC.W 0
MID_CODE	DC.W 0
CLIPXULE	DC.W 0
CLIPYULE	DC.W 0
CLIPXLRI	DC.W 319
CLIPYLRI	DC.W 199
DIST 		DC.W 0
ZOBS		DC.W 1500
ROTX11		DC.W 16384
ROTX12		DC.W 0
ROTX13		DC.W 0
ROTX21		DC.W 0
ROTX22		DC.W 16384
ROTX23		DC.W 0
ROTX31		DC.W 0
ROTX32		DC.W 0
ROTX33		DC.W 16384
MATRIX11	DS.W 1
MATRIX12	DS.W 1
MATRIX13	DS.W 1
MATRIX21	DS.W 1
MATRIX22	DS.W 1
MATRIX23	DS.W 1
MATRIX31	DS.W 1
MATRIX32	DS.W 1
MATRIX33	DS.W 1

DRAIN
		jSR GETRESO
		JSR SETCOCLI
		JSR MAKEWRLD
		JSR WORLDSET
		JSR SETROTDP
		JSR CLWORK
		JSR PAGEDOWN
		JSR CLWORK
		JSR INP_CHAN
MAINLOP1	JSR POINTROT
		JSR PERS
		JSR DRAWN1
		JSR PAGEUP
		JSR INP_CHAN
		JSR CLWORK
		JSR POINTROT
		JSR PERS
		JSR DRAWN1
		JSR PAGEDOWN
		JSR INP_CHAN
		JSR CLWORK
		JMP MAINLOP1
MAINEND		
		RTS
	EVEN
CLEARBUF	MOVE.W #$B,-(A7)
		TRAP #1
		ADDQ.L #2,A7
		TST.W D0
		BEQ CLEAREND
		MOVE.W #1,-(A7)
		TRAP #1
		ADDQ.L #2,A7
		BRA CLEARBUF
CLEAREND	RTS

INP_CHAN	JSR INKEY
		CMP.B #"D",D0
		BNE INPWAIT
		JSR SCRDUMP
INPWAIT		SWAP D0
		CMP.B #$4D,D0
		BNE INP1
		ADDQ.W #1,YWPLUS
		BRA INPEND1
INP1		CMP.B #$4B,D0
		BNE INP2
		SUBQ.W #1,YWPLUS
		BRA INPEND1
INP2		CMP.B #$50,D0
		BNE INP3
		ADDQ.W #1,XWPLUS
		BRA INPEND1
INP3		CMP.B #$48,D0
		BNE INP3A
		SUBQ.W #1,XWPLUS
		BRA INPEND1
INP3A		CMP.B #$61,D0
		BNE INP3B
		SUBQ.W #1,ZWPLUS
		BRA INPEND1
INP3B		CMP.B #$62,D0
		BNE INP4
		ADDQ.W #1,ZWPLUS
		BRA INPEND1
INP4		CMP.B #$4E,D0
		BNE INP5
		SUB.W #25,DIST
		BRA INPEND1
INP5		CMP.B #$4A,D0
		BNE INP6
		ADD.W #25,DIST
		BRA INPEND1
INP6		CMP.B #$66,D0
		BNE INP7
		SUB.W #15,ROTDPZ
		BRA INPEND1
INP7		CMP.B #$65,D0
		BNE INP10
		ADD.W #15,ROTDPZ
		BRA INPEND1
INP10		CMP.B #$0,D0
		Beq INPEND1
		ADDQ.L #4,A7
		BRA MAINEND

INPEND1		MOVE.W HYANGLE,D1
		ADD.W YWPLUS,D1
		CMP.W #360,D1
		BGE INPEND2
		CMP.W #-360,D1
		BLE INPEND3
		BRA INPEND4
INPEND2		SUB.W #360,D1
		BRA INPEND4
INPEND3		ADD.W #360,D1
INPEND4		MOVE.W D1,HYANGLE
		MOVE.W HXANGLE,D1
		ADD.W XWPLUS,D1
		CMP.W #360,D1
		BGE INPEND5
		CMP.W #-360,D1
		BLE INPEND6
		BRA INPEND7
INPEND5 	SUB.W #360,D1
		BRA INPEND7
INPEND6		ADD.W #360,D1
INPEND7		MOVE.W D1,HXANGLE
		MOVE.W HZANGLE,D1
		ADD.W ZWPLUS,D1
		CMP.W #360,D1
		BGE INPEND8
		CMP.W #-360,D1
		BLE INPEND9
		BRA INPEND10
INPEND8		SUB.W #360,D1
		BRA INPEND10
INPEND9		ADD.W #360,D1
INPEND10	MOVE.W D1,HZANGLE
		RTS

SETROTDP	MOVE.W #0,D1
		MOVE.W D1,ROTDPX
		MOVE.W D1,ROTDPY
		MOVE.W D1,ROTDPZ
		MOVE.W #0,HYANGLE
		MOVE.W #0,HZANGLE
		MOVE.W #0,HXANGLE
		RTS

POINTROT	MOVE.W HXANGLE,XANGLE
		MOVE.W HYANGLE,YANGLE
		MOVE.W HZANGLE,ZANGLE
		MOVE.W ROTDPX,D0
		MOVE.W ROTDPY,D1
		MOVE.W ROTDPZ,D2
		MOVE.W D0,XOFFS
		MOVE.W D1,YOFFS
		MOVE.W D2,ZOFFS
		NEG.W D0
		NEG.W D1
		NEG.W D2
		MOVE.W D0,OFFX
		MOVE.W D1,OFFY
		MOVE.W D2,OFFZ
		JSR MATINIT
		JSR ZROTATE
		JSR YROTATE
		JSR XROTATE
		JSR ROTATE
		RTS

MAKEWRLD	MOVE.L #HOUSDATX,A1
		MOVE.L #HOUSDATY,A2
		MOVE.L #HOUSDATZ,A3
		MOVE.L #WORLDX,A4
		MOVE.L #WORLDY,A5
		MOVE.L #WORLDZ,A6
		MOVE.W HNUMMARK,D0
		EXT.L D0
		SUBQ.L #1,D0
MAKEWL1		MOVE.W (A1)+,(A4)+
		MOVE.W (A2)+,(A5)+
		MOVE.W (A3)+,(A6)+
		DBRA D0,MAKEWL1
		MOVE.W HNUMLINE,D0
		EXT.L D0
		SUBQ.L #1,D0
		MOVE.L #HOUSLIN,A1
		MOVE.L #WLINXY,A2
MAKEWL2		MOVE.L (A1)+,(A2)+
		DBRA D0,MAKEWL2
		RTS

WORLDSET	MOVE.L #WORLDX,DATX
		MOVE.L #WORLDY,DATY
		MOVE.L #WORLDZ,DATZ
		MOVE.L #VIEWX,POINTX
		MOVE.L #VIEWY,POINTY
		MOVE.L #VIEWZ,POINTZ
		MOVE.L #WLINXY,LINXY
		MOVE.W PICTUREX,X0
		MOVE.W PICTUREY,Y0
		MOVE.W PROZ,ZOBS
		MOVE.W R1Z1,DIST
		MOVE.L #SCREENX,XPLOT
		MOVE.L #SCREENY,YPLOT
		MOVE.W HNUMLINE,NUMLINE
		MOVE.W HNUMMARK,NUMMARK
		RTS
GETRESO		MOVE.W #4,-(A7)
		TRAP #14
		ADDQ.L #2,A7
		CMP.W #2,D0
		BNE GETR1
		MOVE.W #320,PICTUREX
		MOVE.W #200,PICTUREY
		BRA GETREND
GETR1		CMP.W #1,D0
		BNE GETR2
		MOVE.W #320,PICTUREX
		MOVE.W #100,PICTUREY
		BRA GETREND
GETR2		MOVE.W #160,PICTUREX
		MOVE.W #100,PICTUREY
GETREND		RTS

SCRDUMP		MOVE.W #20,-(A7)
		TRAP #14
		ADDQ.L #2,A7
		JSR CLEARBUF
		RTS

SETCOCLI	MOVE.W #0,CLIPXULE
		MOVE.W #0,CLIPYULE
		MOVE.W PICTUREX,D1
		LSL.W #1,D1
		SUBQ.W #1,D1
		MOVE.W D1,CLIPXLRI
		MOVE.W PICTUREY,D1
		LSL.W #1,D1
		SUBQ.W #1,D1
		MOVE.W D1,CLIPYLRI
		RTS

HOUSDATX	DC.W -50,50,50,-45,-50,-50,-50,50,50,-45,-50,-50,-30,-30,-30,-30,30,30,30,30
		dc.w -40,-40,-40,-40,40,40,40,40,43,47,47,43,43,47,47,43
		dc.w -25,-25,-15,-10,-10,-15,-25,10,20,25,25,20,10
HOUSDATY	DC.W 50,50,-50,-50,-45,50,50,50,-50,-50,-45,50,-15,-50,-50,-15,-15,-50,-50,-15
		dc.w -5,50,50,-5,-5,50,50,-5,47,47,43,43,47,47,43,43
		dc.w 10,35,35,30,25,20,20,35,35,30,15,10,10
HOUSDATZ	DC.W 5,5,5,5,5,5,-5,-5,-5,-5,-5,-5,5,5,-5,-5,5,5,-5,-5
		dc.w -5,-5,5,5,-5,-5,5,5,-5,-5,-5,-5,5,5,5,5
		dc.w 5,5,5,5,5,5,5,5,5,5,5,5,5
HOUSLIN		dc.w 1,2,2,3,3,4,4,5,5,6,7,8,8,9,9,10,10,11,11,12,6,7,2,8,3,9,4,10,5,11,6,12
		dc.w 13,14,14,15,15,16,17,18,18,19,19,20,20,16,13,17,14,18
		dc.w 25,26,26,27,27,28,21,22,22,23,23,24,21,25,24,28
		dc.w 29,30,30,31,31,32,32,29,33,34,34,35,35,36,36,33
		dc.w 37,38,38,39,39,40,40,41,41,42,42,43
		dc.w 44,45,45,46,46,47,47,48,48,49,49,44
HNUMMARK	DC.W 49
HNUMLINE	DC.W 53
HXANGLE 	DC.W 0
HYANGLE		DC.W 0
HZANGLE		DC.W 0
XWPLUS		DC.W 0
YWPLUS		DC.W 0
ZWPLUS		DC.W 0
PICTUREX	DC.W 320
PICTUREY	DC.W 200
ROTDPX		DC.W 0
ROTDPY		DC.W 0
ROTDPZ		DC.W 0
R1Z1		DC.W 0
NORMZ		DC.W 1500

PLUSROT		DS.L 1
FIRST		DS.L 1
SECOND		DS.W 1
DELTA1		DS.W 1
FLAG 		DC.B 1

DIFFZ		DS.W 1
DX		DS.W 1
DY		DS.W 1
DZ		DS.W 1

PROX		DC.W 0
PROY		DC.W 0
PROZ		DC.W 1500
OFFX 		DC.W 0
OFFY		DC.W 0
OFFZ		DC.W 0
XOFFS		DC.W 0
YOFFS		DC.W 0
ZOFFS		DC.W 0
LOOPC DS.L 1

MEGABARS
	movem.l d0-d7/a0-a6,-(sp)
	MOVE.L musicvbl+2,spliv+2
	move.l phys1,oldphys1
		lea nscrolline,a0
		move.b (a0)+,d0
		move.l a0,store1
	bsr clebuf

	move.w #2,-(a7)
	trap #14
	addq.l #2,a7
	move.l d0,oldphys
	move.l d0,d2
	sub.l #$8000,d2
	move.w #3,-(sp)
	trap #14
	addq.l #2,a7
	move.l d0,oldlog
	move.w #-1,-(sp)
	move.l d2,-(sp)
	move.l d2,-(sp)
	move.w #5,-(sp)
	trap #14
	add.l #12,sp
	add.l #$3b60,d2
	pea terx
	move.w #$9,-(sp)
	trap #1
	addq.l #6,sp
	move.w #$2700,sr
	move.l d2,phys1
	move.l #megahbl,hbl
	move.l #megavbl,vbl
	move.w #$2300,sr
spere	move.w #$ff,-(sp)
	move.w #6,-(sp)
	trap #1
	addq.l #4,a7
	tst.w d0
	beq spere
	CMP.B #' ',D0
	BEQ megaex
	bra.s spere

megahbl	move.l a1,-(sp)
	move.l palpoint,a1
	move.w (a1)+,$ff8240
	move.w (a1)+,$ff8250
	move.l a1,palpoint
	move.l (sp)+,a1
	bclr #0,isra
	move.b #1,tbdr
	rte
megavbl movem.l d0-d7/a0-a6,-(sp)
spliv	jsr exthun
	move.l #APAL,palpoint
	move.b #0,tbcr
	move.b #1,tbdr
	move.b #8,tbcr
	bsr clrbar
	bsr incregs
	bsr drawbars
		move.l #data+$5000,a2
		bsr do_scroll
		addq.b #1,count2
		cmp.b #8,count2
		beq nextletter

	MOVEM.L (sp)+,D0-D7/A0-A6
	rte	
count2	dc.b 0,0
incregs cmp.l #defend,point1
	beq p1a

e1	move.l point1,a0
	move.l (a0)+,palpoin1
	move.l a0,point1

	move.l point2,a0
	move.l (a0)+,palpoin2
	move.l a0,point2
	cmp.l #defend,point2
	beq p2a
e2	move.l point3,a0
	move.l (a0)+,palpoin3
	move.l a0,point3
	cmp.l #defend,point3
	beq p3a
e3	move.l point4,a0
	move.l (a0)+,palpoin4
	move.l a0,point4
	cmp.l #defend,point4
	beq p4a
e4	move.l point5,a0
	move.l (a0)+,palpoin5
	move.l a0,point5
	cmp.l #defend,point5
	beq p5a
e5	move.l point6,a0
	move.l (a0)+,palpoin6
	move.l a0,point6
	cmp.l #defend,point6
	beq p6a
e6 	move.l point7,a0
	move.l (a0)+,palpoin7
	move.l a0,point7
	cmp.l #def2end,point7
	beq p7a
e7	cmp.l #def3end,point8
	beq p8a
e8      move.l point8,a0
	move.l (a0)+,palpoin8
	move.l a0,point8
	move.l point9,a0
	move.l (a0)+,palpoin9
	move.l a0,point9
	cmp.l #def2end,point9
	beq p9a
e9	cmp.l #def3end,point10
	beq p10a
e10	move.l point10,a0
	move.l (a0)+,palpoin10
	move.l a0,point10
	rts
p1a	move.l #def,point1
	bra e1
p2a	move.l #def,point2
	bra e2
p3a	move.l #def,point3
	bra e3
p4a 	move.l #def,point4
	bra e4
p5a 	move.l #def,point5
	bra e5
p6a 	move.l #def,point6
	bra e6
p7a 	move.l #def2,point7
	bra e7
p8a	move.l #def3,point8
	tst.b ind
	beq ne
	move.b #0,ind
	bra e8
ne	move.b #1,ind
	bra e8
p9a	move.l #def2,point9
	bra e9
p10a 	move.l #def3,point10
	tst.b ind1
	beq per
	move.b #0,ind1
	bra e10
per	move.b #1,ind1
	bra e10
drawbars 
	move.l palpoin8,a0
	tst.b ind 
	beq net
	move.l #bigbar1,a1
	bsr fart
con	move.l palpoin10,a0
	tst.b ind1
	beq vet
	move.l #bigbar2,a1
	bsr fart
bert
	move.l  palpoin1,a0
	move.l #baris1,a1
	bsr bar
	move.l palpoin2,a0
	move.l #baris1,a1
	bsr bar
	move.l palpoin3,a0
	move.l #baris1,a1
	bsr bar
	move.l palpoin4,a0
	move.l #baris1,a1
	bsr bar
	move.l palpoin5,a0
	move.l #baris1,a1
	bsr bar
	move.l palpoin6,a0
	move.l #baris1,a1
	bsr bar
	move.l palpoin9,a0
	tst.b ind1
	beq set
	move.l #bigbar3,a1
	bsr bart
fhe
	move.l palpoin7,a0
	tst.b ind
	beq met
	move.l #bigbar,a1
	bsr bart
	rts
met	move.l #bigbar1,a1
	bsr bart
	rts
net	move.l #bigbar,a1
	bsr fart
	bra con
vet	move.l #bigbar3,a1
	bsr fart
	bra bert
set	move.l #bigbar2,a1
	bsr bart
	bra fhe
bar 	
	move.l #baris,a2
	move.w #14,d1
nere	move.w (a1)+,(a0)+
	move.w (a2)+,(a0)+
	dbf d1,nere
 	rts
bart    move.w #25,d1
	move.l a1,a2
pere	move.w (a1)+,(a0)+
	move.w (a2)+,(a0)+
	dbf d1,pere
	rts
clrbar 	lea gg,a0
	move.w #180,d2
mere    clr.w (a0)+
	move.w #$34,(a0)+
	dbf d2,mere
	rts	
fart    move.w #25,d1
	move.l a1,a2
dpere	move.w (a1)+,(a0)+
	move.w #$34,(a0)+
	dbf d1,dpere
	rts
megaex
		move.w #-1,-(a7)
		move.l oldphys,-(a7)
		move.l oldlog,-(a7)
		move.w #5,-(sp)
		trap #14
		add.l #12,sp
		MOVE.W #$2700,SR
		MOVE.L #vblhand,$70
		move.l #keyhand,key
		and.b #$df,ieb
		and.b #$fe,iea
		move.l #hblhand,hbl
		or.b #1,iea
		or.b #1,ima
		MOVE.W #$2300,SR
		move.l #$556,$ff8240
		move.l #$05460003,$ff8244
		move.l #$02230334,$ff8248
		move.l #$04450667,$ff824c
		move.l #$07000700,$ff8250
		move.l #$07000700,$ff8254
		move.l #$07000700,$ff8258
		move.l #$04450667,$ff825c
		move.l oldphys1,phys1
		movem.l (a7)+,d0-d7/a0-a6
		bra gere
oldphys1	dc.l 0
nextletter		clr.b count2
movleter		move.l store1,a0
		move.b (a0)+,d0
		cmp.b #$ff,d0
		beq srap
		subi.b #$20,d0
		move.l a0,store1
		move.b d0,b
		move.w a,d0
		mulu #$44,d0
		clr.l a
		move.w d0,c
		add.l #font,a
		sub.l #2,a
		move.l a,a0
		move.l a2,a1
		move.w #16,d0
shere		move.w 2(a0),6(a1)
		move.w 4(a0),14(a1)

		adda.l #160,a1				
		addq.l #4,a0
		dbf d0,shere
	movem.l (a7)+,d0-d7/a0-a6

		rte
srap 		move.b #$20,d0
		lea nscrolline,a0
		move.l a0,store1
	movem.l (a7)+,d0-d7/a0-a6

		rte
clebuf		lea data+$5000,a1
		move.w #$320,d2
cle		clr.l (a1)+
		dbf d2,cle
	rts
baris1  dc.w $100,$200,$300,$400,$510,$620,$730,$730,$620,$510,$400,$300,$200,$100,$0
baris	dc.w $35,$45,$46,$56,$57,$67,$77,$77,$67,$57,$56,$46,$45,$35,$0
bigbar dc.w $10,$120,$130,$230,$240,$340,$350,$450,$460,$560,$570,$670,$770,$770,$670,$570,$560,$460,$450,$350,$340,$240,$230,$130,$120,$10
bigbar1 dc.w $1,$12,$13,$23,$24,$34,$35,$45,$46,$56,$57,$67,$77,$77,$67,$57,$56,$46,$45,$35,$34,$24,$23,$13,$12,$1
bigbar2 dc.w $1,$102,$103,$203,$204,$304,$305,$405,$406,$506,$507,$607,$707,$707,$607,$507,$506,$406,$405,$305,$304,$204,$203,$103,$102,$1
bigbar3 dc.w $111,$111,$222,$222,$333,$333,$444,$444,$555,$555,$666,$666,$777,$777,$666,$666,$555,$555,$444,$444,$333,$333,$222,$222,$111,$111
APAL	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
gg	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0
pp      dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
point1	dc.l def
point2  dc.l def+12
point3  dc.l def+24
point4  dc.l def+36
point5  dc.l def+48
point6	dc.l def+60
point7  dc.l def2
point8  dc.l def3
point9  dc.l def2+124
point10 dc.l def3+124
terx	dc.b $1b,$45,0,0
def	dc.l pp,pp,pp,pp+4,pp+4,pp+4,pp+8,pp+8,pp+12,pp+12,pp+16,pp+20,pp+24,pp+28,pp+32,pp+40,pp+48,pp+56,pp+64,pp+76,pp+84,pp+96,pp+108,pp+124,pp+140,pp+156,pp+176,pp+196,pp+216,pp+236,pp+256
	dc.l pp+236,pp+216,pp+196,pp+176,pp+156,pp+140,pp+124,pp+108,pp+96,pp+84,pp+76,pp+64,pp+56,pp+48,pp+40,pp+32,pp+28,pp+24,pp+20,pp+16,pp+12,pp+12,pp+8,pp+8,pp+4,pp+4,pp+4,pp,pp,pp
defend
def2    dc.l gg,gg,gg,gg+4,gg+4,gg+4,gg+8,gg+8,gg+12,gg+12,gg+16,gg+20,gg+24,gg+28,gg+32,gg+40,gg+48,gg+56,gg+64,gg+76,gg+84,gg+96,gg+108,gg+124,gg+140,gg+156,gg+176,gg+196,gg+216,gg+236,gg+256
	dc.l gg+276,gg+296,gg+316,gg+336,gg+356,gg+372,gg+388,gg+404,gg+416,gg+428,gg+436,gg+448,gg+456,gg+464,gg+472,gg+480,gg+484,gg+488,gg+492,gg+496,gg+500,gg+500,gg+504,gg+504,gg+508,gg+508,gg+508
def2end
def3	dc.l gg+512,gg+512,gg+512,gg+508,gg+508,gg+508,gg+504,gg+504,gg+500,gg+500,gg+496,gg+492,gg+488,gg+484,gg+480,gg+472,gg+464,gg+456,gg+448,gg+436,gg+428,gg+416,gg+404,gg+388,gg+372,gg+352,gg+332,gg+312,gg+296,gg+276
	dc.l gg+256,gg+236,gg+216,gg+196,gg+176,gg+156,gg+140,gg+124,gg+108,gg+96,gg+84,gg+76,gg+64,gg+56,gg+48,gg+40,gg+32,gg+28,gg+24,gg+20,gg+16,gg+12,gg+12,gg+8,gg+8,gg+4,gg+4,gg+4

def3end
ind 	dc.w 0
ind1	dc.w 0
palpoin1	dc.l 0
palpoin2	dc.l 0
palpoin3	dc.l 0
palpoin4	dc.l 0
palpoin5	dc.l 0
palpoin6	dc.l 0
palpoin7	dc.l 0
palpoin8	dc.l 0
palpoin9	dc.l 0
palpoin10	dc.l 0
	even
CHEAT
	bsr cletbuf
	movem.l d0-d7/a0-a6,-(a7)
	move.w #2,-(a7)
	trap #14
	addq.l #2,a7
	move.l d0,oldphys
	move.l d0,d2
	sub.l #$10000,d2
	move.w #3,-(sp)
	trap #14
	addq.l #2,a7
	move.l d0,oldlog
	move.w #-1,-(sp)
	move.l d2,-(sp)
	move.l d2,-(sp)
	move.w #5,-(sp)
	trap #14
	add.l #12,sp
	move.w #$2700,sr
	move.l musicvbl+2,cheatmus+2
	move.l phys,oldphys1
	move #3,-(a7)
	trap #14
	addq.l #2,a7
	move.l d0,a1
	move.w #$6,d5
klm lea cheatdata,a0
 move.w #$27f,d4
mkl move.w (a0)+,(a1)+
	move.w (a0)+,(a1)+
	move.w (a0)+,(a1)+
	move.w #$0,(a1)+
	dbf d4,mkl
	dbf d5,klm
	move.l d0,a1
	add.l #$5000,a1
	lea cheatdata+$f00,a0
	move.w #$437,d4
mjs     move.w (a0)+,(a1)+
	move.w (a0)+,(a1)+
	move.w (a0)+,(a1)+
	move.w #$0,(a1)+
	dbf d4,mjs
	move.l d0,a1
	add.l #$1400,a1
	lea cheatdata+$2850,a0
	move.w #$63f,d4
mjt	move.w (a0)+,(a1)+
	move.w (a0)+,(a1)+
	move.w (a0)+,(a1)+
	move.w #$0,(a1)+
	dbf d4,mjt
		move #2,-(sp)
		trap #14
		addq.l #2,sp
		add.l #$5a00,d0
		move.l d0,phys
		lea CHEATSCROLL,a0
		move.b (a0)+,d0
		move.l a0,btore
	move.l #chhblhand,$120
	move.l #chvblhand,$70
	move.w #$2300,sr
	move.l #$02220433,$ff8240
	move.l #$05440655,$ff8244
	move.l #$07660020,$ff8248
	move.l #$01300240,$ff824c
	move.l #$02000300,$ff8250
	move.l #$04000500,$ff8254
	move.l #$06000020,$ff8258
	move.l #$01300240,$ff825c
start	
	move.w #$ff,-(sp)
	move.w #6,-(sp)
	trap #1
	addq.l #4,sp
	tst.l d0
	beq start
	CMP.B #' ',D0
	beq cheatex
		bra start
cletbuf		lea data+$8000,a1
		move.w #$640,d2
ble		clr.l (a1)+
		dbf d2,ble
	rts

netlett  	clr.b pount
movlett		move.l btore,a0
		move.b (a0)+,d0
		cmp.b #$ff,d0
		beq pwrap
		subi.b #$20,d0
		move.l a0,btore
		move.b d0,f
		move.w e,d0
		mulu #$80,d0
		clr.l e
		move.w d0,g
		add.l #newfont,e
		sub.l #2,e
		move.l e,d0
		move.l d0,a0
		lea data+$8000,a1
		move.w #30,d0
sfhere		move.w (a0)+,(a1)+
		move.w (a0),(a1)+
		move.w (a0),(a1)+
		move.w (a0),(a1)+
		move.w (a0)+,(a1)+
		move.w (a0),(a1)+
		move.w (a0),(a1)+
		move.w (a0),(a1)+
		adda.l #144,a1				
		dbf d0,sfhere
	movem.l (a7)+,d0-d7/a0-a6
		rte
do_scrolli:      move.w  #30,d0  ; the letters are 37 pixels high
doss1:           lsl.w   14(a1)  ; scroll 1 pixel to the left
                roxl.w  6(a1)   ; the letters are 32 pixels wide
                roxl.w  158(a0) ; scroll the screen
                roxl.w  150(a0) ; steps of -8, scroll one plane
                roxl.w  142(a0)
                roxl.w  134(a0)
                roxl.w  126(a0)
                roxl.w  118(a0)
                roxl.w  110(a0)
                roxl.w  102(a0)
                roxl.w  94(a0)
                roxl.w  86(a0)
                roxl.w  78(a0)
                roxl.w  70(a0)
                roxl.w  62(a0)
                roxl.w  54(a0)
                roxl.w  46(a0)
                roxl.w  38(a0)
                roxl.w  30(a0)
                roxl.w  22(a0)
                roxl.w  14(a0)
                roxl.w  6(a0)
                adda.l  #160,a1 
                adda.l  #160,a0 ; 160 bytes: one screen line down
                dbra    d0,doss1 ; do the next screen line
                rts             ; end of routine
pwrap 		move.b #$20,d0
		lea CHEATSCROLL,a0
		move.l a0,btore
	movem.l (a7)+,d0-d7/a0-a6
		rte
e dc.b 0
f dc.b 0
g dc.b 0
h dc.b 0
chhblhand	movem.l a1,-(sp)
	move.l npalpoint,a1
	move.w (a1)+,$FF824A
	move.l a1,npalpoint
	movem.l (sp)+,a1
	bclr #0,isra
	rte
chvblhand	
	movem.l d0-d7/a0-a6,-(sp)
	move.w #$222,$ff8240
	addq.l #2,coter
	cmpi.l #$54,coter
	bne.s goi
	clr.l coter
goi	move.l #npalettes,a0
	add.l coter,a0
	move.l a0,npalpoint
	move.b #0,tbcr
	move.b #1,tbdr
	move.b #8,tbcr

cheatmus	jsr data+$6cf6
cont
		movea.l phys,a0
		lea data+$8000,a1
		bsr do_scrolli
		lea data+$8000,a1
		movea.l phys,a0
		bsr do_scrolli
		movea.l phys,a0
		lea data+$8000,a1
		bsr do_scrolli
		lea data+$8000,a1
		movea.l phys,a0
		bsr do_scrolli
		addq.b #1,pount
		cmp.b #8,pount
		beq netlett
	movem.l (a7)+,d0-d7/a0-a6

	RTE
cheatex
	pea text
	move.w #$9,-(sp)
	trap #1
	addq.l #6,sp
		move.w #-1,-(a7)
		move.l oldphys,-(a7)
		move.l oldlog,-(a7)
		move.w #5,-(sp)
		trap #14
		add.l #12,sp
		MOVE.W #$2700,SR
		MOVE.L #vblhand,$70
		move.l #keyhand,key
		and.b #$df,ieb
		and.b #$fe,iea
		move.l #hblhand,hbl
		or.b #1,iea
		or.b #1,ima
		MOVE.W #$2300,SR
		move.l #$556,$ff8240
		move.l #$05460003,$ff8244
		move.l #$02230334,$ff8248
		move.l #$04450667,$ff824c
		move.l #$07000700,$ff8250
		move.l #$07000700,$ff8254
		move.l #$07000700,$ff8258
		move.l #$04450667,$ff825c
		move.l oldphys1,phys
		movem.l (a7)+,d0-d7/a0-a6
		bra gere

npalpoint	dc.l 0
coter dc.l 0
npalettes  dc.w $710,$720,$730,$740,$750,$760,$770,$670,$570,$470,$370
	dc.w $270,$170,$70,$71,$72,$73,$74,$75,$76,$77,$67,$57,$47,$37
	dc.w $27,$17,$7,$107,$207,$307,$407,$507,$607,$707,$706,$705
	dc.w $704,$703,$702,$701,$700,$710,$720,$730,$740,$750,$760
	dc.w $770,$670,$570,$470,$370,$270,$170,$70,$71,$72,$73,$74
	dc.w $75,$76,$77,$67,$57,$47,$37,$27,$17,$7,$107,$207,$307
	dc.w $407,$507,$607,$707,$706,$705,$704,$703,$702,$701,$700
	dc.w $710,$720,$730,$740,$750,$760,$770,$670,$570,$470,$370
	dc.w $270,$170,$70,$71,$72,$73,$74,$75,$76,$77,$67,$57,$47
	dc.w $37,$27,$17,$7,$107,$207,$307,$407,$507,$607,$707,$706
	dc.w $705,$704,$703,$702,$701,$700,$710,$720,$730,$740,$750
	dc.w $760,$770,$670,$570,$470,$370,$270,$170,$70,$71,$72
	dc.w $73,$74,$75,$76,$77,$67,$57,$47,$37,$27,$17,$7,$107
	dc.w $207,$307,$407,$507,$607,$707,$706,$705,$704,$703,$702
	dc.w $701,$700,$710,$720,$730,$740,$750,$760,$770,$670,$570
	dc.w $470,$370,$270,$170,$70,$71,$72,$73,$74,$75,$76,$77,$67
	dc.w $57,$47,$37,$27,$17,$7,$107,$207,$307,$407,$507,$607,$707
	dc.w $706,$705,$704,$703,$702,$701,$700,$710,$720,$730,$740
	dc.w $750,$760,$770,$670,$570,$470,$370,$270,$170,$70,$71,$72
	dc.w $73,$74,$75,$76,$77,$67,$57,$47,$37,$27,$17,$7,$107,$207
btore ds.l 1
pount  dc.b 7
cols ds.w 17
handle ds.w 1
cheatdata
	incbin "cheat.dat"
newfont
	incbin "newlost.fon"
oldhbl	dc.l 0
palpoint	dc.l 0
oldieb	dc.b 0
oldiea	dc.b 0
oldima	dc.b 0
oldshftmod	dc.b 0
oldpal  dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
test	dc.w 0
text dc.b	$1b,$45,0
palettes	dc.w $147,$147,$157,$157,$167,$167,$267,$267,$367,$367,$467,$567,$667,$577,$577,$677,$677,$777,$777,$776,$776,$775,$775,$774,$774,$773,$773
		dc.w 3,4,4,$104,$104,$104,$5,$5,$5,$105,$105,$105,$105,$105,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106
palettes1	dc.w $147,$147,$157,$157,$167,$167,$267,$267,$367,$367,$467,$567,$667,$577,$677,$677,$777,$777,$776,$776,$775,$775,$774,$774,$773,$773,$773
		dc.w 3,4,4,$104,$104,$104,$5,$5,$5,$105,$105,$105,$105,$105,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106,$106
nscrolline	dc.b "             THIS IS THE CREDITS SCROLLINE FOR THE POWER DEMO.  CREDITS FOR THIS MARVELLOUS PIECE OF WORK (HEAD SWELL!!) GO TO SPAZ FOR SOME GRAPHIXX, SAMMY JOE  SOME ORIGINAL SCROLLINE PROGRAMMING AND SCROLLINE "
		DC.B " TYPING, MANIKIN FOR TRACKING SPRITES, 3D PROGRAMMING, COLOR BARS AND MAIN TITLE SCREEN.  MUSIC HACKS BY SAMMY JOE, THE SPROG FROM DEL MONTE AND MANIKIN. ORIGINAL BIGSCROLL TECHNIQUE BY ALEX HERBERT, REPROGRAMMED BY MANIKIN."
		DC.B " DEMO DISTRIBUTION BY MUG, MJS, ELECTRONIC IMAGES, BARKMANS AND GCA.  FOR YOUR INFORMATION THE LOST BOYS CONSIST OF SAMMY JOE AGE 15, SPROG FROM DEL MONTE AGE 15, MANIKIN AGE 17 AND SPAZ (MANIKINS LITTLE BROTHER!!) AGE 14. ALL LIVE AND"
		DC.B " PROGRAM IN WEST LONDON (AT LEAST FOR THE PRESENT). IF YOU WANT TO CONTACT US THEN JUST PUT A BIG HI IN A DEMO OR INTRO OR SOMETHING, OUR MOST RESOURCEFULL FRIEND MUG WILL ALMOST UNDOUBTEDLY BE ABLE TO FIND YOU FOR US..."
		DC.B "  MANIKIN WISHES IT TO BE KNOWN THAT THIS DEMO IS DEDICATED TO AJP (SHE'S GREAT !!), SAMMY JOE DEDICATES IT TO EVA AND KRISTINA (TWO AT ONCE THE DIRTY BOY!!!) AND SPAZ DEDICATES IT TO LASSIE THE WONDERDOG. "
		dc.b " AND FINALLY A SPECIAL MESSAGE FOR MUG.    BAAAAAAAAAA! HOPE YOU LIKE WALES BOYYO!!!"
		DC.B "   THATS ALL FOR THIS SCROLLINE FOR NOW BYE BYE          THIS LINE WILL SELF DESTRUCT IN 5 SECONDS    5      4      3      2"
		DC.B "      1     BANG!            ",$FF                               
		EVEN
graphix1	incbin "select.dat"

track	incbin "track.dat"
	even
a dc.b 0
b dc.b 0
c dc.b 0
d dc.b 0
string dc.b $12,$1a
oldssp ds.l 1
phys ds.l 1
phys1 ds.l 1
store ds.l 1
store1 ds.l 1
	even
count  dc.b 12
count1 dc.b 7
colors	dc.w 0,$556,$546,$3,$223,$334,$445,$667,$700,$700,$700,$700,$700,$700,$445,$667
scrolline	dc.b "           WELL ISN'T THIS NICE,   WE FINALLY MANAGED TO PRODUCE OUR FIRST DEMO, PERFECT ENGLISH IN THE SCROLLINE (WELL I HAVE LIVED HERE FOR 17 YEARS!!).  MY NAME IS MANIKIN AND AIDED BY SAMMY JOE"
		dc.b " ( GERMAN BY ORIGIN, LIVED IN BRITAIN FOR 18 MONTHS) WE ARE NOW TYPING THE MAIN SCROLL OF THE POWER DEMO IN MY BEDROOM IN TEDDINGTON IN WEST LONDON. "
		DC.B " THIS DEMO COMES FROM LONDON IN ENGLAND (ENGLAND NOT SCOTLAND), PRODUCED IN 8 WEEKS OF FRANTIC ACTIVITY DURING JULY AND AUGUST 1988. A BIG SET OF HELLOS TO "
		DC.B "(IN ORDER OF MERIT)  MUG, MJS, GCA(ESPECIALLY BW), BARKMANS (MIKE, NICK AND THE REST OF THE CROWD), ELECTRONIC IMAGES (GIZMO, I HOPE YOUR NICE AND BROWN!!), NIKO(BBJ), VOLKMAR DES TEEBAEUERLE, DYLAN, DAVID, CHRIS AND COLIN"
		DC.B ", ROY (TRANSVESTITE AMIGA LOVER!! OR MIND YOUR BOTTOMS HERE COMES ROY!!), MAULWURF     RIGHT, THATS ALL THE PEOPLE WE DO KNOW, NOW HERE ARE GREETINGS TO SOME WE DON'T.     TNT-CREW, TEX (NOT BAD FOR A BUNCH OF BRITONS IS IT!!)"
		DC.B ", DELTA FORCE  (HAVE YOU SEEN THE NEW UNION STUFF FROM THESE GUYS.  SHHEEEEET!!)"
		DC.B ", B.O.S.S, BLADERUNNERS, SCC, 007 (NICE HACKS RECENTLY!!), WAS(NOT WAS), ALEX HERBERT AND YOU OF COURSE FOR SPREADING THIS DEMO!!.     AND NOW A POTTED HISTORY OF THE LOST BOYS. "
		DC.B "    HELLO, YOU'VE PROBABLY NEVER HEARD OF US BEFORE, WE DON'T HACK BUT WE LOVE PROGRAMMING. OUR FIRST DEMO WAS RELEASED ONLY IN STUTTGART AT CHRISTMAS '87. IT WAS JUST A SAMPLE OF THE PET SHOP BOYS. THIS WAS CLOSELY "
		DC.B "FOLLOWED BY ANOTHER DEMO CONSISTING OF A SAMPLE OF ZOOLOOK BY JEAN MICHEL JARRE AND THEN THERE WAS SILENCE FOR 6 MONTHS WHILE WE LEARNED MACHINE CODE AT BREAKNECK SPEED..  THIS IS THE RESULT OF OUR EFFORTS."
		DC.B " THE DEMO FEATURES IN KEYBOARD ORDER. A SIMPLE PIECE OF 3D GRAPHICS. "
		dc.b " THE DISK CAN BE ROTATED IN THE X,Y AND Z PLANES USING THE ARROW KEYS AND HELP AND UNDO. + AND - ENLARGE OR MAKE SMALLER THE DISK. NEXT"
		dc.b " SOME FAIRLY GOOD (BUT COULD BE BETTER) TRACKING SPRITES, ALSO INVOLVING CAREFUL USE OF PLANES ENABLING THEM TO GO BEHIND THE GRID.  SOME WELL WICKED COLOR "
		DC.B "BARS AND A SCROLLINE, THIS INVOLVED SOME CLEVER MANIPULATION OF THE BACKGROUND COLOR (OUR FAVOURITE SCREEN!!).   ANOTHER SCREEN AND ANOTHER SCROLLINE, THIS TIME ITS CRYSTAL (THOSE PLANES AGAIN!!), WITH SOME USEFUL (WE HOPE) "
		DC.B " CHEAT CODES AND SOLUTIONS TO YOUR FAVOURITE GAMES.  AND FINALLY A BIG BIG BIG SCROLL (IN FACT 2!!), THIS IS AS FAR AS WE CAN FIND THE BIGGEST SCROLL EVER PROGRAMMED ON THE ST...       ALL THE MUSIC ON THE DEMO COMES FROM "
		DC.B " DAVID WHITTAKER AND ROB HUBBARD THOSE TWO BASTIONS OF MUSIC PROGRAMMING ON THE ST...     THE INSPIRATION FOR THIS DEMO CAME FROM THE EMBARRASSMENT OF THE LACK OF DEMOS COMING OUT OF BRITAIN. WE DECIDED THAT WE SHOULD RECTIFY"
		DC.B " THAT SAD STATE OF AFFAIRS WITH A DEMO THAT AT LEAST EQUALLED ANYTHING PREVIOUSLY ATTEMPTED!!!  AND SO HERE IT IS!!!!  "
		DC.B "  AFTER THIS, WHO KNOWS WHAT WE'LL DO, WE'RE THOUGHRULLY PISSED OFF WITH WRITING DEMOS AT THE MOMENT SO MAYBE SOMETHING A BIT SMALLER WILL COME YOUR WAY NEXT.  3D GRAPHICS LOOK INTERESTING ( I WONDER??? ) ANYWAY UNTIL WE "
		DC.B " MEET AGAIN THIS IS GOODBYE, LOTS OF LOVE AND KISSES FROM MANIKIN, SAMMY JOE, SPAZ AND THE SPROG FROM DEL MONTE     TA! TA!              ",$FF


        even
sound
	incbin "music.dat"
	even
exthun equ sound+$64
exwar equ sound+$181e
exthrust equ sound+$2bfc
exxenon	equ sound+$3f4e
exramp	equ sound+$4e42
exleather	equ sound+$5c0c
exoutrun	equ sound+$66ba
gold	incbin "gold.dat"
	even
exgold		equ gold+$10a
enduro	incbin "enduro.mus"
exenduro	equ enduro+$116
	even
gens	incbin "wca.2"
exgenesis equ	gens+$106
WAIT		DC.W $FDb9
MAN		DC.W $32A7
CCOUNT		DS.W 1
COLCOUNT	DS.L 1
PHYSDEC		DS.W 1
SHYS1		DS.L 1
SHYS2		DS.L 1
BCOUNT1		DS.W 1
BCOUNT2		DS.W 1
SCTEST		DC.W $9
SCTEST1		DC.W $4
COLS
		DC.W $755,$766,$777,$733,$744,$755,$722,$732,$733,$700,$711,$722,$500,$600,$700,$400,$500,$600
		DC.W $400,$500,$600,$500,$600,$700,$700,$711,$722,$722,$732,$733,$733,$744,$755,$755,$766,$777

UPPER		DC.B "       HELLO THERE ALL! ISN'T THIS JUST THE BIGGEST SMOOTHEST MULTI PLANE SCROLLINE YOU'VE EVER SEEN??? YES??    WELL HOW ABOUT HAVING TWO THEN!!!                                WELL HOW ABOUT AT THE SAME TIME!!!!!!  "
		DC.B " WHAT CAN I SAY BUT THANKS ALEX FOR THE TECHNIQUE.    ADVERT TIME.... FOR ALL THE BEST IN COMPUTER SOFTWARE AND HARDWARE FOR THE ST GO TO BARKMANS OF KINGSTON.  THE CHEAPEST AND THE BEST IN LONDON TOWN.....  TELEPHONE (01) 546 5941"   ",$0
		DC.B "    THAT'S   (01) 546 5941 TO CONTACT THIS SHOP OR US !!!!!!.            ",$0

LOWER		DC.B "                                                                                                                                                        TWO I HEAR YOU SAY!!                     AT THE SAME TIME!!!!!!  "
		DC.B " WHAT CAN I SAY BUT THANKS ALEX FOR THE TECHNIQUE.    ADVERT TIME.... FOR ALL THE BEST IN COMPUTER SOFTWARE AND HARDWARE FOR THE ST GO TO BARKMANS OF KINGSTON.  THE CHEAPEST AND THE BEST IN LONDON TOWN.....  TELEPHONE (01) 546 5941"
		DC.B "    THAT'S   (01) 546 5941 TO CONTACT THIS SHOP OR US !!!!!!.            ",$0


		EVEN
CHEATSCROLL
	dc.b "       WELCOME TO THE LOST BOYS CHEAT CODE SCROLL LINE , THIS WILL TELL YOU A LOT OF CHEAT CODES !!! "
	DC.B "   ALL RIGHT NOW LET'S START WITH OUTRUN, TYPE IN STARION AND PRESS S TO GO ON A STAGE.   "
	DC.B " ON LEATHERNECK YOU'VE GOT TO TYPE IN CUTHBERTNECK AND BY PRESSING F3 YOU BECOME INVINCIBLE. "
	DC.B " BUT BE CAREFUL THE OTHER PLAYERS CAN STILL SHOOT YOU !!! "
	DC.B " IN THE GAME ECO, CONTROL+S UNLOCKS ANOTHER GENE. "
	DC.B " WHILE PLAYING RETURN TO GENESIS, TYPE IN WASP.ASM AND HIT F5 (BUT NOT TO HARD !!!!),YOU WILL NOW BECOME INDISTRUCTABLE. THE ONLY WAY TO END THE GAME IS BY SELECTING FESTUS AND DESTROY YOUR SHIP BY PRESSING THE SPACEBAR. "
	DC.B " WHEN YOU PLAY GAUNTLET II YOU CAN GET EXTRA HEALTH (50,000) AND PERMANENT BOUNCING SUPERSHOTS BY PRESSING INSERT WHILE OPENING LOCKED TREASURE CHESTS. "
	DC.B " WHEN YOU GET TO TRACK 8 ON SUPER SPRINT YOU MUST STAY AT THE LINE SO ALL THE OTHER CARS GO ROUND, THEN WHEN THE CARS PASS YOU AT THE LINE, YOU CAN SMASH THEM INTO THE BOTTOM WALL. "
	DC.B " NONE OF THE CARS WILL APPEAR AGAIN, SO YOU CAN GO ROUND COLLECTING ALL THE SPANNERS. "
	DC.B " WHEN YOU'RE PLAYING TIME BANDITS YOU'LL SEE 1A WRITTEN AT THE BOTTOM OF THE SCREEN, BY USING THE CURSOR KEYS YOU CAN SELECT DIFFERENT LEVELS OR TIME ZONES."
	dc.b " ON SKYRIDER YOU'VE GOT TO GET ONTO THE HIGH SCORE TABLE AND TYPE IN >SHELFFIELD AND IT WILL TELL YOU THAT THE TEST MODE IS ACTIVATED.  "
	DC.B " IN BUBBLE BOBBLE, YOU HAVE TO KILL ONLY THREE MONSTERS AND THEN  MAKE AS MANY BUBBLES AS YOU CAN, THEN KILL THE OTHER MONSTERS AND ALL THE BUBBLES WILL TURN INTO FRUIT, EACH ONE WILL BE WORTH 500 POINTS. "
	DC.B " IF YOU'RE GETTING BORED WITH THE FIRST LEVELS OF IMPACT, WHY NOT USE THE PASSWORDS, HERE THEY ARE :   LEVEL 11 (GOLD), LEVEL 21 (FISH), LEVEL 31 (WALL), LEVEL 41 (PLUS), LEVEL 51 (HEAD), LEVEL 61 (FORK), LEVEL 71 (ROAD)"
	DC.B " AND FOR LEVEL 81 (USER).    "
	DC.B " WHEN YOU PLAY ENDURO RACER LET THE TIMER COUNT DOWN AND THEN TYPE IN CHEAT, THEN PRESS S TO SKIP A LEVEL, F FOR TURBO SPEED, T FOR EXTRA TIME. "
	DC.B " THE ONLY WAY YOU CAN FINISH DUNGEON MASTER IS BY STARTING OFF WITH HISSSSAR LIZAR OF MAKAN BECAUSE HE IS THE COUSIN OF A BIG BIG RED DRAGON YOU WILL MEET LATER ON. "
	DC.B " NOW SOME SPELLS FOR DUNGEON MASTER: X1-MAN PROTECTION POTION, X2-HEAL POTION, X4-MAGIC TORCH, X6-DISPEL MAGIC(OPEN DOORS), X14-GROUP PROTECTION, X15-SHIELD POTION, X25-VENOM POTION, X31-POTION CLOUD, X44-FIREBALL, X51-MAGIC MISSILE,"
	DC.B " X52-WEAKEN IMMATERIAL BEINGS, X61-VENOM POTION, X152-LEAVE TRAIL, X153-WISDOM POTION, X154-VITALITY POTION, X320-SEE THROUGH SOLID MATTER, X326-INVISIBLITY, X335-LIGHTNING BOLT, X345-SPECIAL LIGHT, X352-DEXTERITY POTION,"
	DC.B " X451-STRENGH POTION, X454-FIRE SHIELD, X546-DARKNESS, X635-ZOKATHRA SPELL, X665-MANA POTION. "
	DC.B " NOW HOW TO USE THESE POTIONS.   X STANDS FOR FIRST ROW OF SYMBOLS WHICH YOU CAN SELECT ANY SYMBOL FROM. THEN FOR THE NEXT ROWS THE NUMBERS INDICATE WHICH SYMBOL TO TAKE, O.K ? "
	DC.B " FROM NOW ON YOU'LL ONLY FIND HINTS FOR SOME ADVENTURES. WE'LL START WITH ZORK I. CAN'T MOVE THE GRATING ? FIND A KEY, UNLOCK THE GRATING FROM BELOW, YOU CAN MAP YOU WAY THROUGH THE MAZE BY DROPPING OBJECTS (MIND THE THIEF),"
	DC.B " YOU CAN GO IN A LOT OF DIRECTIONS THERE !!   DO YOU WANT TO GET OVER THE WATERFALL IN THE BOAT ?? YOU CAN'T DO THAT, READ ARAGAIN BACKWARDS, TRY WAVING A SCEPTRE AT THE RAINBOW, IT MAY HELP YOU .    "
	DC.B " THE NEXT ONE WE LOOKED AT WAS ZORK II, YOU CAN'T OPEN THE DOOR TO THE TINY ROOM BECAUSE THE KEY IS IN THE LOCK ON THE INSIDE, TRY PUTTING SOMETHING UNDER THE DOOR TO CATCH THE KEY, THEN PUSH IT OUT USING ANOTHER OBJECT."
	DC.B " THE BUCKET ??  IT WAS MADE BY THE FROBOZZ MAGIC WELL COMPANY, READ THE ENGRAVING, STAND IN IT AND POUR SOME WATER INTO IT. TO LAUNCH THE BALLON, JUST BURN SOMETHING IN THE RECEPTACLE.  YOU'LL NEED A KEY FROM THE UNICORN AND"
	DC.B " A BOX OF CANDY FROM THE POOL OF WATER.   "
	DC.B " NOW, YOU MAY GUESS AT WHAT WE LOOKED NEXT,                                 RIGHT, IT WAS ZORK III. IF YOU CAN'T GET THROUGH THE GREAT DOOR, WAIT FOR THE EARTHQUAKE WHEN A CLEFT WILL APPEAR IN THE ROCK THROUGH WHICH YOU CAN GO."
	DC.B "       KINGS QUEST II IS QUITE A HARD ONE, IS MERMAID A MYSTERY FOR YOU ? SHE WILL APPEAR ON A ROCK IN THE SEA, NEAR THE SHORE BY THE WITCH'S CAVE. FIND THE DOOR ACROSS THE BRIDGE AND READ THE INSCRIPTION. GIVE THE MERAMID A GIFT. "
	DC.B " HAVEN'T YOU GOT ANY KEYS TO THE DOORS ? NEPTUN WILL GIVE YOU THE FIRST KEY IN RETURN  FOR A TRIDENT. TO GET THE SECOND, RUB THE OIL LAMP FROM THE ANTIQUE SHOP AND USE THE CARPET TO FLY TO THE MOUNTAIN. THE LAST KEY IS IN THE COFFIN"
	DC.B " IN THE CASTLE, YOU'LL NEED A CLOAK AND RING TO GET THERE. DO YOU FIND THE SUGAR LUMP USELESS ? EAT IT AND YOU WILL BE ABLE TO WALK THROUGH THE PATH OF POISONED THORNS AND BRAMBLES WITHOUT HARM.    VIPER OBSTRUCTING PROGRESS ? PUT THE"
	DC.B " BRIDDLE ON IT, IT WILL TRANSFORM INTO A FLYING HORSE AND GIVE YOU A LUMP OF SUGAR. "
 	DC.B "       KINGS QUEST III IS EASIER (WE THINK) THAN THE FIRST ONE. DO YOU WANT SOME MONEY FOR FOR A DRINK ? PULL THE ROPE IN THE HOLE OF THE TREE NEAR THE DESERT, BE SURE WHEN YOU CLIMB THE TREE THAT THERE ARE NO BANDITS WAITING ABOVE !!"
	DC.B " WAND NOT AVAILABLE ? TRY SEARCHING IN THE STUDY. CAN'T YOU READ A SPELL ? OPEN BOOK OF SORCERY AND FOLLOW THE INSTRUCTIONS GIVEN. SPIDER'S WEB IN THE CAVE OFF-PUTTING ? TURN YOURSELF INTO AN EAGLE !!!  NO TALK IN THE TAVERN ? TYPE"
	DC.B " TALK TO CAPTAIN NAD YOU MAY GET A PASSAGE ON HIS SHIP.             "
	DC.B " AFTER LOOKING THROUGH OUR DISKS, I FOUND THIS ADVENTURE, IT'S CALLED STATIONFALL, LARGE DRILL BIT A PROBLEM ? JUST FORGET IT, WHAT YOU NEED IS THE ALL PURPOSE TIMER.   ARE YOUR HANDS TOO BIG FOR THE DISPENSING MACHINE ? LURE THE"
	DC.B " OSTRICH TO THE DISPENSING MACHINE WITH THE OSTRICH NIP, PUT THE COIN IN THE SLOT, TYPE 6, THEN PUT THE OSTRICH NIP IN THE HOLE.  DRILL BIT TOO HOT TO HANDLE ? YOU ONLY HAVE TO ASK FLOYD TO GET IT FOR YOU.  CAN'T YOU GET ON WITH THE"
	DC.B " BALLOON CREATURE ? MOVE NEXT DOOR AND USE THE ITEM FROM THE PAWN SHOP.    CAN'T YOU MANAGE TO LAUNCH THE SPACE TRUCK ? INSERT THE ACTIVATION  FROM THEN LOOK AT YOUR CHRONOMETER."
	DC.B " CHECK THE TIME GIVEN AGAINST THE LIST OF TIME RANGES GIVEN IN THE PACKAGE'S DOCUMENTATION. AGAINST EACH RANGE IS A THREE DIGIT NUMBER, THIS IS THE NUMBER YOU MUST TYPE ON THE KEYPAD TO LAUNCH.  CAN'T YOU FIND A COIN ? TRY BLASTING"
	DC.B " THE BOX IN THE LOAN SHARK'S OFFICE.        "
	DC.B " NOW LET'S HAVE A LOOK AT KNIGHT ORC.   DO YOU NEED A LONG ROPE TO CROSS THE VIADUCT ? HERE'S WHAT YOU NEED TO TIE TOGETHER AND WHERE TO FIND THEM:  BELT(HERMIT), CORD(CHEST), HAIR(RAPUNZEL), HALYARD(FLAGPOLE), HAWSER(WELL), LASSOO"
	DC.B "(HUNTER), WASHING LINE(ROYAL OAK), NOOSE(GRIBBET), REINS(GREEN NIGHT) AND TETHER(GOAT).        "
	DC.B " YOU DON'T WANT TO MISS LEATHER GODDESSES OF PHOBOS, OR DO YOU ? CAGED WITH A GORILLA ? BEFORE YOU ARE STRAPPED DOWN BY THE MAD SCIENTIST, HURL THE CHOCOLATE INTI THE CAGE. WHEN INSIDE THE CAGE, EAT THE CHOCOLATE AND YOU'LL BECOME TOUGH"
	DC.B " ENOUGH TO PULL THE BARS APART.  CAN'T YOU ENTER THE ORPHANAGE ? PLACE THE BABY IN THE BASKET AND PUT THE BASKET INTO THE STOOP. THEN HIDE AND WAIT FOR THE BABY TO BE TAKEN INTO THE ORPHANAGE.  IS THE CODED MESSAGE PUZZLING YOU ? REPLACE "
	DC.B " EACH LETTER BY ITS THRIRD PREVIOUS ONE IN THE ALPHABET, FOR ESAMPLE, E BY B AND B BY Y. THEN READ THE MESSAGE BACKWARDS.   CAN'T YOU GIVE THE FROG A SMACKER ?  CLOSE YOUR EYES, PUT PIN ON NOSE, COVER EARS WITH HANDS AND PUT BALM ON LIPS. "
	DC.B " BY NOW YOU HAVE TO THINK THE LOST BOYS JUST CONSIST OF ADVENTURE FREAKS, NOT REALLY BUT SOMEONE GOT TO DO THE HARD WORK !!!!      BUREAUCRACY, THAT'S THE NEXT ONE.    ARE YOU STUCK IN THE PLANE WITH THE ILAMA STEW ?  SIT IN SEAT 3C GO TO"
	DC.B " SEAT 8D AND PRESS THE LIGHT BUTTON THERE, NOW RETURN TO SEAT 3C , IF THE PHONE RINGS, GO TO THE BACKAND ANSWER IT THEN SAY STINGLAI KA'ABI. COMPUTER PASSWORD IN THE HQ A MYSTERY ?"
	DC.B " IDENTIFY YOURSELF AS RANDOM Q HACKER, THE PASSWORD IS RAINBOW TURTL. WE BET YOU DON'T KNOW HOW TO ANSWER THE INTERCOM ? SAY THE"
	DC.B " SAME THING TO THE WEIRDO IN THE FARMHOUSE AND LISTEN CARFULLY TO HIS RESPONSE.  STUCK IN JAIL WITH THE WEIRDO  ?   ASK HIM TO GIVE YOU HIS PEN KNIFE !!   DELAYED THE PLANE BUT STILL STUCK AT THE AIRPORT ?  CLIMB UP THE PILLAR AND PULL OUT"
	DC.B " THE RED AND BLACK WIRES FROM THE SPEAKER UP THE PILLAR. BEFORE YOU CLIMB DOWN AGAIN, CONNECT THE RED WIRE TO THE BLACK.       "
	DC.B " NEXT: BALLYHOO.  DETECTIVE NOT CO OPERATING? WAIT UNTIL YOU FIND HIM DRUNK. POUR WATER OVER HIM THEN ASK HIM FOR THE NOTE. THAT'S IT ALREADY WITH BALLYHOO, I GOT A LITTLE BORED WITH IT, SO I JUST QUIT IT !!!        "
	DC.B " THE     LURKING HORROR   , MONSTERS KEEP FLYING OFF WITH THE HAND ? THROW THE STONE AT THE MONSTER INSIDE THE DOME THEN ESCAPE TO THE SKYSCRAPER ROOF AND THROW THE STONE AGAIN.    URCHIN CONSEALING SOMETHING ABOUT HIS PERSON ?  SHOW HIM"
	DC.B " THE REVITALISED HAND.  CAN'T YOU PASS THE GLASS WALL ? JUST FORGET IT, IT'S IMPASSABLE.  DO YOU WANT TO DESTROY THE BRICK WALL? STOP THE LIFT ON A HIGHER FLOOR THEN LEVER OPEN THE DOORS ON A LOWER LEVEL. USE THE ROD TO KEEP THE DOOR OPEN"
	DC.B ". YOU SHOULD SOON FIND SOMETHING TO HELP WITH THE WALL...       "
	DC.B "  WE LOOKED AT GUILD OF THIEVES AS WELL, DOES THE OPAGUE REFUSE TO OPEN ?  ROLL THE COLOURED DICE  ONE AT A TIME UNTIL EACH ONE SHOWS A FIVE,   THEN INSERT EACH INTO ITS RESPECTIVE COLOURED SLOT ON THE CASE.    GEM STILL STUCK IN THE WAX ?"
	DC.B " GET THE MIRROR FROM THE MAIN BEDROOM, USE IT TO POINT THE BEAM OF LIGHT AT THE GEM.  STUNG WITH ANGER AT YOUR FAILURE TO GET THE HONEY ?  FORGET IT, YOU WON'T NEED IT AS FAR AS WE KNOW.   STRUGGLING TO CROSS THE COLOURED SQUARES ?"
	DC.B " WOBINAR IS RAINBOW BACKWARDS (RED, ORANGE, YELLOW, GREEN, BLUE, INDIGO, VIOLET).  CROSS THE SQUARES BY FOLLOWING THE COLOURS OF THE RAINBOW BACKWARDS. ON RETURN DO THE OPPOSITE.   IS THE HOT COAL ROOM BURNING YOU UP ?  RUB YOUR FEET WITH"
	DC.B " THE SUCCLENTS. YOU'LL NEED TO OVERCOME THE SPIDER FIRST BUT A FEW FLIES AND A JAM JAR COULD HELP.  WONDERING WHAT TO DO IN THE TOILET ?  NOTHING THAT'S OF ANY USE REALLY, TRY HANGING AROUND A BIT, YOU MAY BE REWARDED BY THE MASTER THIEF."
	DC.B " CAN'T ENTER THE UNDERTAKER'S ?  BREAK THE WINDOW TO GET INSIDE.  NEED A FISHING ROD ?  TIE THE COTTON TO THE CUE, PUT THE MAGGOT ON THE NEEDLE.  CAN'T FIND THE SECRET LABATORY ?  STAND ON THE BED IN THE MAIN BEDROOM, PRESS THE TOP BUTTON"
	DC.B " WITH THE CUE.  WANT THE MILLER'S LUTE ? BUY IT FROM HIM WITH YOUR WINNINGS FROM THE RAT RACE, BET ON THE RACE WITH THE NOTE HIDDEN IN THE CUSHION.   ARE THE RATS ON THE STAIRS A PROBLEM ?  JUST OPEN THE STOPCOCK, PULL THE PIPE, WAIT CLOSE"
	DC.B " THE STOPCOCK AND THEN PROCEED THE DOWN THE STAIRS.   BANK MANAGER WON'T LET YOU GET TO THE VAULT ?   FIRST CHEW THE GUM AND TEACH THE BIRD TO SAY HOORAY, IN THE OFFICE, SHAKE THE CHAMPAGNE BOTTLE, DROP THE CAGE AND BOTTLE AND WAIT TO BE"
	DC.B " ESCORTED OUT, WHEN THE DOOR HAS BEEN LOCKED BEHIND YOU, PUT THE GUM  IN THE KEYHOLE, THEN SING AND FLY.               "
	DC.B " SPACE QUEST: COMPARTMENT NEAR THE SPACESUIT A PUZZLE ? TYPE LOOK AROUND, LOOK IN THE CLOSET AND GET THE GADGET, IT'S A TRANSLATOR.  CAN'T PASS THROUGH THE UNDERGROUND CAVE ?  GET THE ROCK FROM OUTSIDE THE LIFT, WALK ACROSS THE TOP OF"
	DC.B " THE GRATE ON THE FLOOR THEN PUT THE ROCK ON THE GEYSER.   CAN'T YOU FIND A USEFUL PIECE OF GLASS ? EXAMINE THE BACK OF THE CRASHED POT.      SPACE QUEST II :    CAUGHT UP BY A SNARE ?  YOU CAN'T AVOID BEING SNARED AND IMPRISONED  BY THE"
	DC.B " HUNTER,  IN THE CAGE, CALL HIM TWICE AND WHEN HE COMES NEAR, LET HIM HAVE IT WITH THE SPORE,  THEN TAKE THE KEY FROM HIS INERT BODY."    
	DC.B " HITCH HIKER'S GUIDE TO THE GALAXY IS NEXT :  DON'T KNOW WHAT TO DO WITH THE FOUR PIECES OF FLUFF ?  READ THE GUIDE, PUT THE FLUFF IN THE FLOWERPOT AND TAKE IT SOMEWHERE WARM AND HUMIT.   SREENING DOOR WON'T OPEN ?  YOU NEED TO SHOW YOUR"
	DC.B " INTELLIGENCE BY HOLDING TEA AND NO TEA AT THE SAME TIME.  BUG-BLATTER BEAST OF TRAAL BEING BEASTLY ?  CONFUSE IT BY CARVING YOUR NAME ON THE SANDSTONE MEMORIAL, THEN COVER YOUR HEAD WITH THE TOWEL AND TELL HIM YOUR NAME WHEN HE ASKS."
	DC.B "  GUARDS ON DAMOGRAN A PROBLEM ?  WAIT FOR TRILLIAN THEN TELL THE GUARDS TO DROP THEIR PHOTON RIFLES, NEXT STEP IS TO DISPOSE OF THE PILE OF RIFLES.  DON'T KNOW HOW TO HANDLE THE ELECTRONIC HITCH-HIKING DEVICE ?  PRESS THE GREEN BUTTON, IN"
	DC.B " THE DARK KEEP WAITING AND READ THE RESPONSES VERY CARFULLY , NOTICE THAT YOU CAN NOW SMELL ? SO SMELL !!!          "
	DC.B " J I N X T E R :    NEED THE METAL STOOL FROM THE CLOCKMAKER'S SHOP  ?   KNOCK AT THE DOOR, THROW SOMETHING AT THE OIL LAMP,  OOJIMY THE HOT STOOL.   WHY DOES THE GARDENER  RUN AWAY WITH THE SACK ?  HE MUST HERE YOU COMING, TRY PUTTING"
	DC.B " SOME OIL ON THE RUNNERS OF THE BOATHOUSE DOOR.   HOW DO I GET THE COIL ?  GET THE PLASTIC BOTTLE, POUR THE CONTENTS INTO A SUITABLE CONTAINER AND TRY SOME COLD MAGIC.   CAN'T OPEN XAM'S MAILBOX ?  WARM THE PLASTIC KEY WITH SOMETHING HOT"
	DC.B ".    HOLE IN THE CANOE A PROBLEM ?  YOU COULD TRY BLOCKING IT UP WITH THE DEAD MOUSE, IT WORKS BUT LATER YOU'LL WISH YOU HADN'T. INSTEAD YOU FIND SOMETHING THAT PONGS, PUT THE BUNG INSIDE IT THEN PUT THE CHEESY THING IN THE HOLE.         "
	DC.B "   PLUNDERED HEARTS :   CAN'T STOP THE EXPLOSIVE SITUATION DOWN BELOW ?   TEAR A PIECE FROM YOUR FROCK, SOAK IT IN LIQUID AND THROW IT OVER TH GATE.  IS THE ESCAPE FROM THE SHIP IMPOSSIBEL ? CLIMB INTO THE CASK AND CUT THE LINE, BON VOYAGE"
	DC.B "  DUELLING PISTOLS STUCK TO THE WALL ? IGNORE THEM !!    CHANDELIER ROPE A PUZZLE ?   WAIT UNTIL LATER EVENTUALLY THE FALCON AND LAFOND WILL BE FIGHTING BELOW YOU IN THE BALLROOM.                 " 
   	DC.B " HOLLYWOOD HI-JINKS IS THE LAST ONE WE LOOKED AT.    CAN'T GET OVER THE BROKEN STEPS ?   TRY A SPOT OF SKIING.   DO YOU NEED A LIGHT IN THE UNDERGROUND CAVE ?  DRIP WAX FROM THE"
	DC.B " STATUETTES ON TO THE GREEN MATCH TO MAKE IT WATERPROOF.  FILM A BIT FUZZY ?  REMOVE THE LENS CAP AND RUN BOTH THE SLIDE AND FILM PROJECTOR AT THE SAME TIME.  THAT'S IT FOR NOW"
	DC.B " WITH THE CHEAT CODES AND SOLUTIONS, WE HOPE YOU FIND THEM USEFUL.   WE HAVE SOME MORE, BUT WE NEED SOME FOR OUR NEXT DEMO, DON'T WE ??      MANY, MANY THANKS TO ALL THE GUYS"
	DC.B " OF WHOM WE GOT THE CHEAT CODES .....    JUST A SEC,     THIS SCROLLINE IS ABOUT 18K WORTH OF SOURCECODE, IT TOOK US 2 TO 3 HOURS TO TYPE ALL OF IT IN.    WHY DON'T YOU CHANGE THE MUSIC NOW, I'M"
	DC.B " GETTING BORED WITH THE SAME MUSIC ALL THE TIME !!!    ANYWAY, THAT'S IT FOR NOW. IT'S HALF PAST ONE IN THE MORNING, MY FATHER IS JUST COMING UPSTAIRS, THAT MEANS TROUBLE, BECAUSE I GO TO GO TO SCHOOL TOMORROW, TO THE   D S L (DEUTSCHE"
	DC.B " SCHULE LONDON !!!), GREAT SCHOOL, IN THIS TERM THERE CAME A LOT OF NEW GIRLS, SOME OF THEM LOOK QUITE NICE .......    ALL RIGHT, I'M GOING TO BED NOW,.......       SEE YOU AGAIN IN A HUNDRED AND FIFTY YEARS,      GOOD NIGHT......"
	DC.B ".    YOUR STILL THERE MY GOD YOUR BORING, STILL LISTENING TO THE SAME MUSIC.   I HOPE YOU CAN UNDERSTAND MY ENGLISH, IT ISN'T THAT BAD ALTHOUGH MY TEACHER GAVE ME A D. OR FOR THE GERMANS A 4. THAT'S IT,  SEE YOU SOMETIME,.......  "
	DC.B "                                          ",$FF           

   

news	incbin "news.pi1"
	even
SRAPHIX
		INCBIN "BACK.DAT"
SRAPHIX1	EQU SRAPHIX+$A00
		EVEN
FONT1		INCBIN "NEWFONT.DAT"
FONT2		EQU FONT1+15360
FONT3		EQU FONT1+30780
FONT4		EQU FONT1+46080

data
	incbin "coil.dat"
	even
font
	incbin "lost.fon"
	even
graphix
	incbin "main.dat"
ENDING	equ font+$4000
WORLDX		equ ENDING
WORLDY		EQU ENDING+3200
WORLDZ		EQU ENDING+6400
VIEWX 		EQU ENDING+9600
VIEWY		EQU ENDING+12800
VIEWZ		EQU ENDING+16000
SCREENX		EQU ENDING+19200
SCREENY		EQU ENDING+22400
WLINXY		EQU ENDING+25600


