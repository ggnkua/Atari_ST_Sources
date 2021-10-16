	SECTION	TEXT
	OPT	O+,D-,S-


num_fil	EQU	3			;number of files
txt_log	EQU	$0700000		;scroll text and logo colours
items	EQU	$111			;items colour

mus_yn	EQU	0			;music 0=yes / 1=no


iera	EQU	$FFFFFA07		;MFP Equates
isra	EQU	$FFFFFA0F
imra	EQU	$FFFFFA13
tbcr	EQU	$FFFFFA1B
cdcr	EQU	$FFFFFA1D
tbdr	EQU	$FFFFFA21
start	MOVE.L	4(A7),A5
	MOVE.L	#$400,-(SP)
	MOVE.L	A5,-(SP)
	MOVE.L	#$4A0000,-(SP)
	TRAP	#1
	LEA	12(SP),SP

	clr.l -(sp)
	move.w #32,-(sp)
	trap #1
	move.l d0,ssp
	addq.l #6,sp
	bsr.s code
	move.l ssp,-(sp)
	move.w #32,-(sp)
	trap #1
	addq.l #6,sp
	clr.l $60000
	pea $60000
	pea $60000
	move.l fadd,-(sp)
	move.l #$4b0000,-(sp)
	trap #1
	lea 10(a7),a7
	CLR.W	-(SP)			;p_term
	TRAP	#1

code	MOVE.W	#4,-(SP)
	TRAP	#14			;get rez
	ADDQ.L	#2,SP
	MOVE.W	D0,rez
	SUBQ.W	#2,D0
	BNE.S	.ok
	RTS

.ok	PEA	mse_off(PC)
	MOVE.L	#$190000,-(SP)		;die rodent
	TRAP	#14
	ADDQ.L	#8,SP
	CLR.W	-(SP)
	PEA	-1.W
	MOVE.L	(SP),-(SP)
	MOVE.W	#5,-(SP)		;set screen
	TRAP	#14
	LEA	12(SP),SP

	MOVEM.L	$FFFF8240.W,D0-D7
	MOVEM.L	D0-D7,def_pal		;store colours
	MOVE.L	#txt_log,$FFFF8242.W
	MOVE.W	#items,$FFFF825E.W
	PEA	message(PC)
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	LEA	logo(PC),A0
	MOVE.L	$44E.W,A1
	LEA	4043(A1),A1
	MOVE.W	#268,D7
.loop	MOVE.B	(A0)+,(A1)
	ADDQ.L	#7,A1
	MOVE.B	(A0)+,(A1)+
	DBF	D7,.loop

gen	LEA	colour(PC),A0
	MOVEQ	#0,D0
	MOVEQ	#5,D4
main	MOVEQ	#7,D5
gen3	MOVEQ	#7,D6
gen2	MOVEQ	#40,D7
gen1	MOVE.W	D0,(A0)+
	ADDI.W	#$100,D0
	ANDI.W	#$777,D0
.ok1	DBF	D7,gen1
	ADDI.W	#$001,D0
	AND.W	#$077,D0
	DBF	D6,gen2
	ADDI.W	#$010,D0
	AND.W	#$070,D0
	DBF	D5,gen3
	DBF	D4,main

	MOVE.L	#tab,posi

	MOVE.W	$468.W,D0		;wait for vblank
vsync	CMP.W	$468.W,D0
	BEQ.S	vsync

	LEA	old_mfp(PC),A0
	MOVE.B	(iera).W,(A0)+
	MOVE.B	(isra).W,(A0)+
	MOVE.B	(imra).W,(A0)+
	MOVE.B	(tbcr).W,(A0)+
	MOVE.B	(cdcr).W,(A0)+
	MOVE.B	(tbdr).W,(A0)+

	BSR	mus_on

	MOVE.W	#$2700,SR
	MOVE.L	$70.W,vbl_jmp+2
	MOVE.L	#vblank,$70.W
	CLR.B	(cdcr).W		;disable Timers C & D
	CLR.B	(tbcr).W
	move.l	$120.w,sav120
	MOVE.L	#hblank,$120.W
	MOVE.B	#1,(tbdr).W
	MOVE.B	#8,(tbcr).W
	MOVE.B	#200,(tbdr).W
	BSET	#0,(iera).W
	BSET	#0,(imra).W
	MOVE.W	#$2300,SR

MORE	Move.l #$600ff,-(sp)
	trap #1
	addq.l #4,sp
	CMP.B #$31,D0
	beq gone
	cmp.b #$33,d0
	beq thr
	cmp.b #$32,d0
	BNE.S MORE
	move.l #gam2,fadd
	bra.s ENDIT
thr	move.l #gam3,fadd
	bra.s ENDIT
gone	move.l #gam1,fadd
	***********************************
	*stick a key check routine in here*
	***********************************

ENDIT		
	LEA	old_mfp(PC),A0
	MOVE.W	#$2700,SR
	MOVE.B	(A0)+,(iera).W
	MOVE.B	(A0)+,(isra).W
	MOVE.B	(A0)+,(imra).W
	MOVE.B	(A0)+,(tbcr).W
	MOVE.B	(A0)+,(cdcr).W
	MOVE.B	(A0)+,(tbdr).W
	MOVE.L	vbl_jmp+2(PC),$70.W

	BSR	mus_off
	move.w #$2300,sr
	move.l #$1a0008,-(sp)
	trap #14
	addq.l #4,sp
	move.l sav120,$120.w
	move.b  #8,$fffffc02.w
	clr.l $426.w
	clr.l $42a.w
	clr.l $24.w
	clr.l $420.w
	MOVE.W	rez(PC),-(SP)
	PEA	-1.W
	MOVE.L	(SP),-(SP)
	MOVE.W	#5,-(SP)		;set screen
	TRAP	#14
	LEA	12(SP),SP

	MOVEM.L	def_pal(PC),D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W	;restore colours
	PEA	mse_on(PC)
	MOVE.L	#$190001,-(SP)		;re-carnate rodent
	TRAP	#14
	ADDQ.L	#8,SP

.exit	RTS
sav120	dc.l 0
ssp	dc.l 0 
vblank	MOVEM.L	D0-D7/A0-A6,-(SP)
	BSR	zak+8
	SUBQ.W	#1,pix
	BNE.S	.main
	MOVEQ	#0,D0
	MOVE.L	scrlpos,A0
	MOVE.B	(A0)+,D0
	BNE.S	.chrval
	MOVE.L	#scrltxt,scrlpos
	MOVE.L	scrlpos,A0
	MOVE.B	(A0)+,D0
.chrval	MOVE.L	A0,scrlpos
	SUBI.B	#32,D0
	LSL.W	#3,D0
	LEA	font,A1
	ADDA.L	D0,A1

	LEA	sct_pad,A0
	MOVEQ	#7,D0
.copy	MOVE.B	(A1)+,(A0)
	ADDQ.L	#2,A0
	DBF	D0,.copy

	MOVE.W	#4,pix
.main	MOVEQ	#1,D1
.shift	MOVEQ	#7,D0
	MOVE.L	$44E.W,A1
	LEA	sct_pad,A0
.lines	LSL	(A0)+

	ROXL	152(A1)
	ROXL	144(A1)
	ROXL	136(A1)
	ROXL	128(A1)
	ROXL	120(A1)
	ROXL	112(A1)
	ROXL	104(A1)
	ROXL	96(A1)
	ROXL	88(A1)
	ROXL	80(A1)
	ROXL	72(A1)
	ROXL	64(A1)
	ROXL	56(A1)
	ROXL	48(A1)
	ROXL	40(A1)
	ROXL	32(A1)
	ROXL	24(A1)
	ROXL	16(A1)
	ROXL	8(A1)
	ROXL	(A1)
	LEA	160(A1),A1
	DBF	D0,.lines
	DBF	D1,.shift
.lap	MOVE.L	posi(PC),A0
	MOVE.W	(A0)+,D0
	MOVE.L	A0,posi
	CMP.W	#-1,D0
	BNE.S	.ok1
	MOVE.L	#tab,posi
	BRA.S	.lap
.ok1	MOVE.W	D0,xxx+2
	
	MOVE.B	#7,(tbdr).W
	MOVE.B	#8,(tbcr).W
	MOVE.B	#200,(tbdr).W
	BSET	#0,(iera).W
	BSET	#0,(imra).W
	ADDQ.W	#2,x+2
	CMPI.W	#22,x+2
	BNE.S	k
	MOVE.W	#16,x+2
	ADDQ.W	#2,xx+2
	CMPI.W	#16,xx+2
	BNE.S	k
	MOVE.W	#16,x+2
	CLR.W	xx+2
k	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTE
vbl_jmp	JMP	$0.L

hblank	MOVEM.L	D0-D7/A0-A6,-(SP)
	CLR.B	(tbcr).W
	MOVE.W	#$2700,SR

	LEA	$FFFF8209.W,A0		;video address counter low
	LEA	(tbdr).W,A1		;timer B data
	LEA	colour+340(PC),A2
	LEA	$FFFF8240.W,A3

	MOVEQ	#0,D0
	MOVEQ	#58,D2
x	MOVE.W	#16,D1
xx	SUB.W	#0,A2
xxx	LEA	82(A2),A2

wait	MOVE.B	(A0),D0
	BEQ.S	wait

	SUB.W	D0,D1
	LSL.W	D1,D0
edge	DBF	D2,edge
	
	MOVE.W	#235,D7
loop1	REPT	41
	MOVE.W	(A2)+,(A3)
	ENDR
	NOP
	NOP
	DBF	D7,loop1
	CLR.W	(A3)

	MOVEM.L	(SP)+,D0-D7/A0-A6
	BCLR	#0,(isra).W
	RTE

fadd	dc.l 0
gam1	dc.b 'tale',0
gam2	dc.b 'acevap',0
gam3	dc.b 'exor2',0
	even
mus_off	 
	LEA	$FFFF8800.W,A0
	MOVEQ	#8,D0
.clear	MOVE.B	D0,(A0)
	CLR.B	2(A0)
	ADDQ.W	#1,D0
	CMPI.W	#$A,D0
	BLE.S	.clear
	RTS

mus_on	
	bclr #0,$484.w				
	moveq	#1,d0
	jsr	zak
	rts


zak		incbin ipcf_res.mus
zakend

; Change file name     ^^^^^^^^

; ipcf.mus     - In demo music  BY Beast Of TSC
; ipcf_res.mus - Reset music    BY Frazer Of TSC
; groove.mus   - Excellence in Art's Get Into The Groove Demo
;		 By ??? Cuold be Frz/Beast or Jedi ?



	even


	SECTION	DATA



message	DC.B	27,"Y",38,43," MENU - 500 PART J"		;enter all tex
	DC.B	27,"Y",40,43," "		;use 27,"Y",32+x,32+y
	dc.b	27,"Y",42,43," 1-TALESPIN"
	DC.B	27,"Y",44,43," "
	DC.B	27,"Y",46,43," 2-SPACE ACE"		;to position your
	DC.B	27,"Y",48,43," "			;message
	DC.B	27,"Y",50,43," 3-EXORCIST II"
	DC.B	27,"Y",52,43," "
	DC.B	27,"Y",54,43," "
	DC.B	27,"Y",56,33,"All Coding Copyright  MONSTER INC 1990"
	DC.B	0					;terminator
	EVEN

scrltxt dc.b	'        '  
	DC.B	'      ' 
	DC.B	'   HERE IS A FEW CRAPPY BITS I FOUND LYING AROUND IN MY DISK BOXES   '
	DC.B	'  VAP GREETS GO TO SNAKE OF THE REPLICANTS    JABBA OF DELIGHT    AXE AND ANNETTA    THE MEDWAY BOYS  '
	DC.B	' THE BBC (HI LAWRENCE)   FLAME OF FINLAND     MOB   MIKEY   THE PUP   PURSY (GIMME MORE GRAPHICS)    WIZPOP (GIZ SOME PICS)   THE HIGHLANDER    '
	DC.B	'  VOODOO    STEVE.C    THE MONSTER   M.M.M    INNER CIRCLE (NICE CODE!)    EGB (WHERE IS YOUR INTRO)    THE UN-NAMEABLE ONE (WHERE IS YOUR INTRO)    MONTY PYTHON    '
	DC.B	'  BIG EDDIE    AND THE POMPEY PIRATES...    '
	DC.B	'    '
	DC.B	' OVER AND OUT. NOW HERE IS THE MONSTER!   '
	DC.B	"           HELLO GUYS,  THIS IS ANOTHER PIECE OF CODE BY THE MONSTER   -   "
	DC.B	"WELL I HOPE YOU LIKE IT, THIS MENU ISN'T DESIGNED TO BE THE BEST EVER MENU, BUT IT IS "
	DC.B	"DESIGNED TO BE SMALL SO THAT IT'LL FIT THE DISKS WITH VIRTUALLY NO SPACE....     "
	DC.B	"PS THE RECTANGLES CONTAIN ALL 512 POSSIBLE COLOURS!!!    -    TIME TO WRAP...            "
	DC.B	0
	EVEN
scrlpos	DC.L	scrltxt
pix	DC.W	1
font	DC.W	$0000,$0000,$0000,$0000,$0018,$1818,$1800,$1800,$0066,$6666,$0000,$0000,$0066,$FF66,$66FF,$6600
	DC.W	$183E,$603C,$067C,$1800,$0066,$6C18,$3066,$4600,$1C36,$1C38,$6F66,$3B00,$0038,$3838,$1830,$0000
	DC.W	$000E,$1C18,$181C,$0E00,$0070,$3818,$1838,$7000,$0066,$3CFF,$3C66,$0000,$0018,$187E,$1818,$0000
	DC.W	$0000,$0000,$0018,$1830,$0000,$007E,$0000,$0000,$0000,$0000,$0018,$1800,$0006,$0C18,$3060,$4000
	DC.W	$007C,$E6EE,$F6FE,$FE7C,$0038,$7838,$38FE,$FEFE,$007C,$CE1C,$78FE,$FEFE,$007E,$061C,$C6FE,$FE7C
	DC.W	$001C,$3C7C,$DCFE,$FE1C,$00FE,$E0FC,$06E6,$FE7C,$007C,$E0FC,$E6FE,$FE7C,$00FE,$0E1E,$3C7C,$F8F8
	DC.W	$007C,$EE7C,$EEFE,$FE7C,$007C,$E67E,$0EFE,$FCF8,$0038,$3838,$0038,$3838,$0000,$1818,$0018,$1830
	DC.W	$060C,$1830,$180C,$0600,$0000,$FEFE,$00FE,$FE00,$6030,$180C,$1830,$6000,$003C,$660C,$1800,$1800
	DC.W	$003C,$666E,$6E60,$7E3E,$0038,$7C6C,$C6DE,$DEDE,$00F8,$CCF8,$CCFE,$FEFC,$007C,$E6C0,$E6FE,$FE7C
	DC.W	$00F8,$ECE6,$EEFE,$FEFC,$00F0,$C0F8,$C0FE,$FEFE,$00FE,$F0FC,$F0F0,$F0F0,$007C,$E0EC,$E6FE,$FE7C
	DC.W	$00E6,$E6E6,$FEE6,$E6E6,$00FE,$3838,$38FE,$FEFE,$0006,$06E6,$E6FE,$FE7C,$00E4,$ECF8,$F8FC,$EEEE
	DC.W	$00C0,$C0C0,$C0FE,$FEFE,$00C6,$EEFE,$FEFE,$E6E6,$00E6,$E6F6,$FEFE,$EEE6,$007C,$E6E6,$E6FE,$FE7C
	DC.W	$00FC,$E6E6,$FEFC,$F0F0,$007C,$E6E6,$EEFC,$FE7E,$00FC,$E6E6,$FEFC,$EEEE,$007C,$E07C,$0EFE,$FEFC
	DC.W	$00FE,$FEFE,$3838,$3838,$00E6,$E6E6,$E6FE,$FEFE,$00E6,$E6E6,$E67C,$7C38,$00E6,$E6E6,$FEFE,$EEC6
	DC.W	$00E6,$E63C,$3CFE,$E6E6,$00E6,$E6FE,$7C38,$3838,$007E,$1C38,$70FE,$FEFE	
logo	DC.W	$0004,$03F3,$FFFF,$FFCF,$80F8,$023F,$FFFF,$8FFC,$F81F,$8000,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W	$0000,$0000,$0000,$0000,$000A,$0212,$0000,$0030,$4108,$0520,$0000,$9003,$0410,$8000,$0000,$0000
	DC.W	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0011,$0212,$0000,$0010,$2208,$08A0,$0000,$A001
	DC.W	$0210,$8000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0020,$8212,$0000,$0010
	DC.W	$1408,$1060,$0000,$A001,$0110,$8000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W	$0040,$4212,$1E1E,$1E10,$0808,$203F,$0F87,$A1E1,$0090,$8000,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W	$0000,$0000,$0000,$0000,$0080,$2212,$1212,$1210,$0008,$4011,$0884,$2121,$0050,$8000,$0000,$0000
	DC.W	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0104,$1212,$1212,$1210,$C108,$8209,$0884,$2121
	DC.W	$0830,$8000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$020A,$0A12,$1212,$1210
	DC.W	$A309,$0505,$0884,$2121,$0C10,$8000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W	$0411,$0612,$1212,$1210,$950A,$0883,$0884,$2121,$0A00,$8000,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W	$0000,$0000,$0000,$0000,$083F,$821E,$1212,$1E10,$890C,$1FC1,$0B87,$E1E1,$0900,$8000,$0000,$0000
	DC.W	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$1001,$4000,$1212,$0010,$8100,$00A0,$0A00,$0001
	DC.W	$0880,$8000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$2001,$2000,$1212,$0010
	DC.W	$8100,$0090,$0A00,$0001,$0840,$8000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W	$4001,$1000,$2211,$0030,$8100,$0088,$0A00,$0003,$0820,$8000,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W	$0000,$0000,$0000,$0000,$FFFF,$0FFF,$C3F0,$FFCF,$81FF,$FF87,$FBFF,$FFFC,$F81F	
tab	DC.W	$0F60,$1004,$10FA,$11F0,$12E6,$13DC,$14D2,$1576,$166C,$1762,$1806,$18AA,$19A0,$1A44,$1AE8,$1B8C,$1BDE,$1C82,$1CD4,$1D78
	DC.W	$1DCA,$1E1C,$1E1C,$1E6E,$1E6E,$1E6E,$1E6E,$1E6E,$1E6E,$1E6E,$1E1C,$1DCA,$1D78,$1D26,$1C82,$1C30,$1B8C,$1B3A,$1A96,$19F2
	DC.W	$18FC,$1858,$17B4,$16BE,$161A,$1524,$142E,$1338,$1242,$119E,$10A8,$0FB2,$0EBC,$0DC6,$0CD0,$0BDA,$0AE4,$09EE,$094A,$0854
	DC.W	$07B0,$06BA,$0616,$0520,$047C,$03D8,$0334,$0290,$023E,$019A,$0148,$00F6,$00A4,$0052,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W	$0000,$0052,$00A4,$00F6,$0148,$019A,$01EC,$0290,$0334,$03D8,$047C,$0520,$05C4,$0668,$075E,$0802,$08F8,$09EE,$0A92,$0B88
	DC.W	$0C7E,$0D74,$0E6A,-1
mse_on	DC.B	$80,$1
mse_off	DC.B	$12
	EVEN
posi	DC.L	0

	trap	#1			*


xspace	DS.L	1


	SECTION	BSS



rez	DS.W	1
old_mfp	DS.B	6
sct_pad	DS.W	8
def_pal	DS.W	16
colour	DS.W	20000

