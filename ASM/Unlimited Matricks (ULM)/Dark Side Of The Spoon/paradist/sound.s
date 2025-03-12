
; The Paralax distorter by Gunstick from Unlimited Matricks
parallax	equ	0
parallay	equ	0
bus		equ	10
digitest	equ	10

;	config:

def_version	equ	10
d0_for_mcp	equ	0
mcp_adr		equ	$500
keyboard	set	10

test	equ	10

	ifeq	def_version
	opt	d-
	org	$2500
keyboard	set	0
	endc

	section	text

	ifne	def_version
	pea	start(pc)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1
	endc

start:
	lea	oldcpu(pc),a0
	move.l	sp,(a0)+
	lea	my_stack,sp
	move.w	sr,(a0)+
	move.w	#$2700,sr
	move.l	usp,a1
	move.l	a1,(a0)+

	ifne	def_version
	moveq	#$12,d0
	bsr	ikbd_wrt
	moveq	#$1a,d0
	bsr	ikbd_wrt

	move.l	$408.w,old_408
	move.l	#exit_with_408,$408.w
	endc

	lea	oldvideo(pc),a0
	move.b	$ffff8260.w,(a0)+
	move.b	$ffff820a.w,(a0)+
	move.l	$ffff8200.w,(a0)+
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)

	movem.l	black(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w


	lea	oldvectors(pc),a0
	move.l	$68.w,(a0)+
	move.l	$70.w,(a0)+
	move.l	$114.w,(a0)+
	move.l	$118.w,(a0)+
	move.l	$120.w,(a0)+
	move.l	$134.w,(a0)+
	move.l	#nix,$68.w
	move.l	#nix,$70.w
	move.l	#nix,$114.w
	ifeq	keyboard
	move.l	#nix,$118.w
	endc
	move.l	#nix,$120.w
	move.l	#nix,$134.w

	lea	oldmfp(pc),a0
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa17.w,(a0)+
	move.b	$fffffa19.w,(a0)+
	move.b	$fffffa1b.w,(a0)+
	move.b	$fffffa1d.w,(a0)+

	bclr	#3,$fffffa17.w
	clr.b	$fffffa07.w
	ifeq	keyboard
	clr.b	$fffffa09.w
	endc
	ifne	keyboard
	move.b	#%01000000,$fffffa09.w
	endc

	bsr	waitvbl1
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820a.w

	bsr	psginit
	bsr	mfp_test

;	jmp	screen
back:

	lea	my_stack,sp

	bsr	psginit

	lea	oldmfp(pc),a0
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	move.b	(a0)+,$fffffa19.w
	move.b	(a0)+,$fffffa1b.w
	move.b	(a0)+,$fffffa1d.w

	lea	oldvectors(pc),a0
	move.l	(a0)+,$68.w
	move.l	(a0)+,$70.w
	move.l	(a0)+,$114.w
	move.l	(a0)+,$118.w
	move.l	(a0)+,$120.w
	move.l	(a0)+,$134.w

	move.b	#2,$ffff820a.w
	bsr.s	waitvbl1
	move.b	#0,$ffff820a.w
	bsr.s	waitvbl1
	move.b	#2,$ffff820a.w
	bsr.s	waitvbl1

	lea	oldvideo(pc),a0
	move.b	(a0)+,$ffff8260.w
	move.b	(a0)+,$ffff820a.w
	move.l	(a0)+,$ffff8200.w
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

	ifne	def_version
	moveq	#$14,d0
	bsr.s	ikbd_wrt
	moveq	#$8,d0
	bsr.s	ikbd_wrt
	endc

	lea	oldcpu(pc),a0
	move.l	(a0)+,sp
	move.w	(a0)+,sr
	move.l	(a0)+,a1
	move.l	a1,usp

	ifne	def_version
	move.l	old_408(pc),$408.w

	rts
	endc

	ifeq	def_version
	moveq	#d0_for_mcp,d0
	jsr	mcp_adr+0.w
	endc

psginit:
	moveq	#15,d0
	lea	psginittab,a1
	lea	$ffff8800.w,a0
nextinit:
	move.b	(a1)+,(a0)
	move.b	(a1)+,2(a0)
	dbf	d0,nextinit
;	move.b	#7,(a0)
;	move.b	#$7f,2(a0)
;	move.b	#14,(a0)
;	move.b	#$26,2(a0)
	rts

waitvbl1:
	move.w	#9000,d0
waitvbl2:
	dbf	d0,waitvbl2
waitvbl:
	lea	$ffff8209.w,a0
	movep.w	-8(a0),d0
waitvbl3:
	tst.b	(a0)
	bne.s	waitvbl3
	movep.w	-4(a0),d1
	cmp.w	d0,d1
	bne.s	waitvbl3
	rts

ikbd_wrt:
	lea	$fffffc00.w,a0
ik_wait:
	move.b	(a0),d1
	btst	#1,d1
	beq.s	ik_wait
	move.b	d0,2(a0)
	rts

mfp_test:
	move.w	#$2700,sr

	bsr.s	waitvbl
	bsr.s	waitvbl

	move.b	#0,$fffffa19.w
	move.b	#255,$fffffa1f.w
	move.b	#$20,$fffffa07.w
	move.b	#0,$fffffa13.w

	moveq	#30,d1
	lea	$ffff8209.w,a0
check_mfp_s1:
	move.b	(a0),d0
	beq.s	check_mfp_s1
	sub.w	d0,d1
	lsl.w	d1,d1
	move.b	#0,$fffffa0b.w
	move.b	#1,$fffffa19.w

	moveq	#-1,d0
mfp_test_loop:
	dbf	d0,mfp_test_loop

	moveq	#0,d0
	move.b	$fffffa1f.w,d0
	move.b	#0,$fffffa19.w
	cmp.w	#$9b,d0
	ble.s	mfp_of_my_st
	move.w	#-1,mfp_type
mfp_of_my_st:
	rts

	ifne	def_version
	dc.l	'XBRA'
	dc.l	'TFSY'
old_408:
	dc.l	0
exit_with_408:
	bsr.s	exit
	move.l	old_408(pc),a0
	jmp	(a0)
	endc

exit:
	movem.l	black(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

	bra	back

nix:
	rte

oldcpu:		ds.w	4
oldvideo:	ds.w	19
oldvectors:	ds.l	6
oldmfp:		ds.w	5
mfp_type:	ds.w	1
black:		ds.l	16


****************************************************************

;overscan:equ 0
; Double Megadistorter by Gunstick   (c) ULM 1990
; we know! it's long, but it works ! And it's from ULM !!!





;	dc.w	$c8*4
;	dc.w	138*4
	dc.w	195*4
;	dc.w	167*4
;	dc.w	197*4
;	dc.w	167*4
;	dc.w	255*4
	dc.w	128*4
digisound:
;	incbin	"includes\telgraph.dmn"
;	incbin	"includes\jasy75.dmn"
;	incbin	"includes\senn_l1.dmn"
;	incbin	"includes\senn_l2.dmn"
;	incbin	"includes\luna.dmn"
;	incbin	"includes\luna2.dmn"
;	incbin	"includes\infinity.dmn"
digiend:
	dc.w	159*4
digisound2:
digiend2:
	even

font:
	even
fontend:
kotz:
	dc.l	0
noswreset:
	rts

	;--------------------------------------------------------

calc_mdist	MACRO
	move.w	(a3)+,d6
	sub.w	(a4)+,d6
	movem.l	(a5,d6),d3/d4/d5/d6
	ENDM
do_mdist	MACRO
	lea	64(a5),a5
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
	movem.l	d3/d4/d5,$ffff8250.w	;mdist
;	move.l	buffer,buffer
;	dcb	9,$4e71
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d6,$ffff825c.w	;mdist
;	dcb	4,$4e71
	ENDM
	

calc_mdist2	MACRO
	move.w	(a3)+,d6
	sub.w	(a4)+,d6
	movem.l	(a5,d6),d4/d5/d6/a2
	ENDM
do_mdist2	MACRO
	lea	64(a5),a5
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
	movem.l	d4/d5/d6,$ffff8250.w	;mdist
;	move.l	buffer,buffer
;	dcb	9,$4e71
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	a2,$ffff825c.w	;mdist
;	dcb	4,$4e71
	ENDM


calc_mdist02	MACRO
	move.w	(a3)+,d6
	sub.w	(a4)+,d6
	movem.l	(a5,d6),d2/d4/d5/d6
	ENDM
do_mdist02	MACRO
	lea	64(a5),a5
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
	movem.l	d2/d4/d5,$ffff8250.w	;mdist
;	dcb	9,$4e71
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d6,$ffff825c.w	;mdist
;	dcb	4,$4e71
	ENDM

	
	dcb	17-1-11,$4e71
	moveq	#0,d7
; megadistorter test
;	lea	0(a0,d7),a0
	movem.l	(a0),d4/d5/d6/d7


digi1	MACRO
;	not.w	kotz
;	bne.s	*+4
;	illegal	
	
	ifne	digitest
	moveq	#-1,d6		;~1
	move.b	(a6),d6		;~2
	add.w	d6,d6		;~1
	add.w	(a7,d6),d7	;~4
	endc
	ifeq	digitest
	move.w	#$700,$ffff8240.w
	move.w	#$200,$ffff8240.w
	endc
	andi.w	#$ff*4,d7	;~2
	
	move.l	(a7,d7),d6
	movep.l	d6,$ffff8800-512-downthere(a7)		;~7

	ENDM
	

digi2	MACRO
;	not.w	kotz
;	beq.s	*+4
;	illegal
	
	ifne	digitest
	moveq	#-1,d6		;~1
	move.b	(a6)+,d6	;~2
	add.w	d6,d6		;~1
	add.w	2(a7,d6),d7	;~4
	endc
	ifeq	digitest
	move.w	#$070,$ffff8240.w
	move.w	#$020,$ffff8240.w
	endc
	andi.w	#$ff*4,d7	;~2
	
	move.l	(a7,d7),d6	;~5
	movep.l	d6,$ffff8800-512-downthere(a7)		;~7

	ENDM
	even



	;**********************************************************

prt:
	dc.b 27,"Y",32+20,32+1,"     000"
str:	dc.b "0    ",0



	even
psginittab:dc.b 0,$ff,1,$ff,2,$ff,3,$ff,4,$ff,5,$ff,6,0
	dc.b 7,%11111111,8,16,9,0,10,0,11,60,12,0,13,14,$ff,0
	even
hwpalette:
	dc.w	$000,$227,$005,$654,$543,$432,$321,$777
;	dc.w	$000,$227,$005,$740,$730,$720,$710,$777
	dc.w $777,$666,$555,$444,$333,$222,$111,$002 
	dc.w $0700,$0707,$0474,$0777,$0606,$0505,$0404,$303
graphic:
	dc.w $d555,$3333,$0f0f,$ff
cheatcodepos:
	dc.l	cheatcode
cheatcode:  ;  B         U         S         cr
	dc.b 48,22,48+$80,31,22+$80,28,31+$80,28+$80,0
	even
lowbyte:
	dc.b 0

	even	
hwscrolldat:			

	even

	section	bss

bss_start:		;here starts the bss

screenad:	ds.l	1

	ds.l	20
my_stack:

stack:	ds.l 1
oldpal: ds.w 16
oldres: ds.w 1
screenad1:ds.w 1
screenad2:ds.l 1
screenadr:ds.l 1
resync:		ds.w	1
digswitch:	ds.w	1	;use digi1 or digi2
logbase:	ds.l	1	;screen where to put scroll
tabentry:
	ds.l	1	;for hwscroll
cpybufdest:
	ds.l	1	;copy from (this+4buffers-1scroll) to (this) 
shiftcnt:
	ds.w	1	;counter for shifter
count:
	ds.l	1	;for some dbf without register
nextscrn:	
	ds.l	1	;points to next screenadress to be used
distcalc:
	ds.w	1
distwaveptr:
	ds.l	1	;pointer in one distwave
wavetabptr:
	ds.l	1	;pointer to the next wave to be played

disttableptr:
	ds.l	1	;pointer to scrolldisttable
disttable:
	ds.w	20*2	;scrolldisttable
digiptr:
	ds.l	1	;ptr to begin digi after vbl
predigi:
	ds.l	40	;40 lines predigitized (20*2 values)
mactcurv:
	ds.l	1	;ptr in active curve
mnextcurv:
	ds.l	1	;next mdist curv
mdistcurvval:
	ds.w	1	;curve
mdistcurvptr:
	ds.l	1
mdistadjustptr:
	ds.l	1	;pointer to the distorter adjust table
mdistadjust:
	ds.w	300*2	;adjusttable for the two distorters

linebuffbegin:
textptr:
	ds.l	1	;letter not completly copied into buffer (forward)
bufptr:
	ds.l	1	;pos where graphic is added in preshift 0
bufcnt:
	ds.w	1	;which one of the 26 routs to be used to copy
shift:
	ds.w	1	;which preshift to copy
buffer:
	ds.l	2*26*16	;16 shifts of the 1st line of the scrolling
linebuffend:
;	ds.l	1
;	ds.l	1
;	ds.w	1
;	ds.w	1
	ds.l	2*26*16+1+1+1

screenmem:
	ds.w	230*6
ecran: 
	rept	5
	ds.l 	15700
	endr
endprg:
bss_end:		;here ends the bss
	end

