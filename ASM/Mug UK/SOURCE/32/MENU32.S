	pea.l	$100.w
	move.l	8(a7),-(a7)
	move.l	#$004a0000,-(a7)
	trap	#1
	move.l a7,sav7 
	lea.l	$80000,a7
	bra intro
music	incbin	"axel_f.mus"
	even
sav7	dc.l 0
intro	lea.l	bss1,a0
	lea.l	bss2,a1
clrbss	clr.b	(a0)+
	cmp.l	a0,a1
	bne.s	clrbss

	lea.l	cols+198,a0
	moveq.l	#6,d0
do_cols	move.l	#$00000111,(a0)+
	move.l	#$02220333,(a0)+
	move.l	#$04440555,(a0)+
	move.l	#$06660777,(a0)+
	move.l	#$06660555,(a0)+
	move.l	#$04440333,(a0)+
	move.l	#$02220111,(a0)+
	dbra.w	d0,do_cols

	lea.l	cols+400,a0
	moveq.l	#99,d0
docols2	lea.l	rainbow(pc),a1
docols3	cmp.l	#rainbow_end,a1
	beq.s	docols2
	move.w	(a1)+,(a0)+
	dbra.w	d0,docols3

	lea.l	font32(pc),a0
	lea.l	shift32(pc),a1
	move.w	#179,d0
expand1	moveq.l	#24,d1
expand2	move.b	(a0)+,d2
	move.b	d2,d3
	and.w	#%0000000011110000,d2
	rol.w	#8,d2
	move.w	d2,(a1)+
	and.w	#%0000000000001111,d3
	ror.w	#4,d3
	move.w	d3,48(a1)
	dbra.w	d1,expand2
	lea.l	50(a1),a1
	dbra.w	d0,expand1

	lea.l	text3(pc),a0
	lea.l	shftxt1(pc),a1
	lea.l	translt-32(pc),a2
	move.w	#((endtxt3-text3)-1),d1
expand3	moveq.l	#0,d0
	move.b	(a0)+,d0
	move.b	00(a2,d0.l),d0
	mulu.w	#400,d0
	add.l	#shift32,d0
	move.l	d0,(a1)+
	dbra.w	d1,expand3
	clr.l	-(a1)

	move.l	#$35400000,d2
	lea.l	scrlcod,a0
	moveq.l	#24,d0
expand4	moveq.l	#18,d1
expand5	move.l	#$20104840,(a0)+
	move.l	#$e3b830c0,(a0)+
	move.l	d2,(a0)+
	addq.l	#8,d2
	dbra.w	d1,expand5

	move.l	#$20103019,(a0)+
	move.l	#$4840e3b8,(a0)+
	move.w	#$30c0,(a0)+
	move.l	d2,(a0)+
	addq.l	#8,d2
	dbra.w	d0,expand4
	move.w	#$4e75,(a0)

	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,oldsp

	move.w	#2,-(a7)
	trap	#$e
	addq.l	#2,a7
	move.l	d0,oldphys

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldcols
	movem.l	newcols,d0-d7
	movem.l	d0-d7,$ffff8240.w

	clr.w	-(a7)
	pea.l	$78000
	move.l	(a7),-(a7)
	move.w	#5,-(a7)
	trap	#$e
	lea.l	12(a7),a7

	lea.l	text1(pc),a0
	lea.l	$78000+(3*160),a1
	bsr.w	print
	lea.l	$78008+(31*160),a1
	bsr.w	print
	lea.l	$78000+(59*160),a1
	bsr.w	print
	lea.l	$78000+(87*160),a1
	bsr.w	print
	lea.l	$78008+(114*160),a1
	bsr.w	print
	lea.l	$78008+(142*160),a1
	bsr.w	print
	lea.l	$78000+(170*160),a1
	bsr.w	print

	lea.l	text2,a0
	lea.l	$78005+(119*160),a1
	bsr.w	print8
	lea.l	$78075+(114*160),a1
	bsr.w	print8

	or.w	#$700,sr
	move.l	$70.w,old70
	move.b	$fffffa07.w,oldfa07
	move.b	$fffffa09.w,oldfa09
	move.b	$fffffa17.w,oldfa17
	move.l	#my70,$70.w
	move.l	#my120,$120.w
	move.b	#1,$fffffa07.w
	clr.b	$fffffa09.w
	bclr.b	#0,$fffffa0f.w
	bset.b	#0,$fffffa13.w
	bclr.b	#3,$fffffa17.w
	clr.b	$fffffa1b.w
	clr.b	$fffffa21.w
	move.w	#$2300,sr

	moveq.l	#1,d0
	bsr.w	music

loop	bsr.w	vblind
	bsr.w	scroll

	move.w	clock,d0
pause	cmp.w	clock,d0
	beq.s	pause
	CMP.B #2,$FFFFFC02.W
	BEQ.S mm1
;	cmp.b #3,$fffffc02.w
;	beq.s mm2
;	cmp.b	#4,$fffffc02.w
;	beq.s mm3
;	cmp.b	#5,$fffffc02.w
;	beq.s mm4
	bra.s	loop
;mm	move.l #gam3,fadd+2
	bra.s exx
mm1	move.l #gam1,fadd+2
;	bra.s exx
;mm2	move.l #gam2,fadd+2
;	bra.s exx
;mm3	move.l #gam3,fadd+2
;	bra.s exx
;mm4	move.l #gam4,fadd+2
		
exx	or.w	#$700,sr
	move.l	old70,$70.w
	move.b	oldfa07,$fffffa07.w
	move.b	oldfa09,$fffffa09.w
	move.b	oldfa17,$fffffa17.w
	clr.b	$fffffa1b.w
	move.w	#$2300,sr

	lea.l	$ffff8800.w,a0
	move.b	#7,(a0)
	move.b	(a0),d1
	or.b	#$3f,d1
	moveq.w	#12,d0
clrsnd	move.b	d0,(a0)
	clr.b	2(a0)
	dbra.w	d0,clrsnd
	move.b	#7,(a0)
	move.b	d1,2(a0)

	movem.l	oldcols,d0-d7
	movem.l	d0-d7,$ffff8240.w

	clr.w	-(a7)
	move.l	oldphys,-(a7)
	move.l	(a7),-(a7)
	move.w	#5,-(a7)
	trap	#$e
	lea.l	12(a7),a7

	move.l	oldsp,-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l sav7,a7
	clr.l $60000
	pea $60000
	pea $60000
fadd	move.l #0,-(sp)
	move.l #$4b0000,-(sp)
	trap #1
	lea $10(a7),a7
	clr.w -(sp)
	trap #1
	rts
gam1	dc.b "tnmmod.kal",0
;gam2	dc.b "fname2.kal",0
;gam3	dc.b "fname3.kal",0
;gam4	dc.b "fname4.kal",0
	even
my70	move.w	#$2700,sr
	bsr.w	music+$8

 	addq.w	#1,clock
	lea.l	cols,a6
	move.l	#my120,$120.w
	move.b	#8,$fffffa1b.w
	move.b	#2,$fffffa21.w
	clr.w	$ffff8242.w
	rte

my120	move.w	(a6)+,$ffff8242.w
	clr.w	$ffff8240.w
	move.w	398(a6),$ffff8244.w
	move.w	398(a6),$ffff8246.w
	move.w	398(a6),$ffff824c.w
	rte

print	moveq.l	#0,d0
	move.b	(a0)+,d0
	bmi.s	print3
	lea.l	translt-32(pc),a2
	move.b	00(a2,d0.w),d0
	lea.l	font32(pc),a2
	mulu.w	#100,d0
	add.l	d0,a2
	moveq.w	#24,d0
print2	move.b	(a2)+,(a1)
	move.b	24(a2),1(a1)
	move.b	49(a2),8(a1)
	move.b	74(a2),9(a1)
	lea.l	$a0(a1),a1
	dbra.w	d0,print2
	lea.l	-(25*160)+16(a1),a1
	bra.s	print
print3	rts

vblind	subq.b	#1,vblcntr
 	bne.s	print3
	move.b	#2,vblcntr

	lea.l	cols(pc),a0
	move.l	a0,a1
	lea.l	18(a1),a1

	rept	8
	movem.l	(a1)+,d1-d5
	movem.l	d1-d5,(a0)
	lea.l	20(a0),a0
	move.w	(a1)+,(a0)+
	endr

	move.l	a0,a1
	addq.l	#2,a1

	movem.l	(a1),d1-d4
	movem.l	d1-d4,(a0)
	lea.l	16(a0),a0

	move.l	vblpntr(pc),a1
	cmp.l	#endvbl,a1
	bne.s	vblind3
	lea.l	vblcols(pc),a1
vblind3	move.w	(a1)+,(a0)
	move.l	a1,vblpntr
	rts

scrwrap	lea.l	shftxt1(pc),a2
	bra.w	scroll0

scroll	moveq.l	#0,d0
	move.l	scroll2+2,a0
	move.w	d0,(a0)
	move.w	d0,8(a0)
	move.w	d0,16(a0)
	move.w	d0,24(a0)
	move.w	d0,32(a0)
	move.w	d0,40(a0)
	move.w	d0,48(a0)
	move.w	d0,56(a0)
	move.w	d0,64(a0)
	move.w	d0,72(a0)
	move.w	d0,80(a0)
	move.w	d0,88(a0)
	move.w	d0,96(a0)
	move.w	d0,104(a0)
	move.w	d0,112(a0)
	move.w	d0,120(a0)
	move.w	d0,128(a0)
	move.w	d0,136(a0)
	move.w	d0,144(a0)
	move.w	d0,152(a0)

	move.w	d0,160(a0)
	move.w	d0,168(a0)
	move.w	d0,176(a0)
	move.w	d0,184(a0)
	move.w	d0,192(a0)
	move.w	d0,200(a0)
	move.w	d0,208(a0)
	move.w	d0,216(a0)
	move.w	d0,224(a0)
	move.w	d0,232(a0)
	move.w	d0,240(a0)
	move.w	d0,248(a0)
	move.w	d0,256(a0)
	move.w	d0,264(a0)
	move.w	d0,272(a0)
	move.w	d0,280(a0)
	move.w	d0,288(a0)
	move.w	d0,296(a0)
	move.w	d0,304(a0)
	move.w	d0,312(a0)

	move.w	d0,320(a0)
	move.w	d0,328(a0)
	move.w	d0,336(a0)
	move.w	d0,344(a0)
	move.w	d0,352(a0)
	move.w	d0,360(a0)
	move.w	d0,368(a0)
	move.w	d0,376(a0)
	move.w	d0,384(a0)
	move.w	d0,392(a0)
	move.w	d0,400(a0)
	move.w	d0,408(a0)
	move.w	d0,416(a0)
	move.w	d0,424(a0)
	move.w	d0,432(a0)
	move.w	d0,440(a0)
	move.w	d0,448(a0)
	move.w	d0,456(a0)
	move.w	d0,464(a0)
	move.w	d0,472(a0)

	move.w	d0,3520(a0)
	move.w	d0,3528(a0)
	move.w	d0,3536(a0)
	move.w	d0,3544(a0)
	move.w	d0,3552(a0)
	move.w	d0,3560(a0)
	move.w	d0,3568(a0)
	move.w	d0,3576(a0)
	move.w	d0,3584(a0)
	move.w	d0,3592(a0)
	move.w	d0,3600(a0)
	move.w	d0,3608(a0)
	move.w	d0,3616(a0)
	move.w	d0,3624(a0)
	move.w	d0,3632(a0)
	move.w	d0,3640(a0)
	move.w	d0,3648(a0)
	move.w	d0,3656(a0)
	move.w	d0,3664(a0)
	move.w	d0,3672(a0)

	move.w	d0,3680(a0)
	move.w	d0,3688(a0)
	move.w	d0,3696(a0)
	move.w	d0,3704(a0)
	move.w	d0,3712(a0)
	move.w	d0,3720(a0)
	move.w	d0,3728(a0)
	move.w	d0,3736(a0)
	move.w	d0,3744(a0)
	move.w	d0,3752(a0)
	move.w	d0,3760(a0)
	move.w	d0,3768(a0)
	move.w	d0,3776(a0)
	move.w	d0,3784(a0)
	move.w	d0,3792(a0)
	move.w	d0,3800(a0)
	move.w	d0,3808(a0)
	move.w	d0,3816(a0)
	move.w	d0,3824(a0)
	move.w	d0,3832(a0)

	move.w	d0,3840(a0)
	move.w	d0,3848(a0)
	move.w	d0,3856(a0)
	move.w	d0,3864(a0)
	move.w	d0,3872(a0)
	move.w	d0,3880(a0)
	move.w	d0,3888(a0)
	move.w	d0,3896(a0)
	move.w	d0,3904(a0)
	move.w	d0,3912(a0)
	move.w	d0,3920(a0)
	move.w	d0,3928(a0)
	move.w	d0,3936(a0)
	move.w	d0,3944(a0)
	move.w	d0,3952(a0)
	move.w	d0,3960(a0)
	move.w	d0,3968(a0)
	move.w	d0,3976(a0)
	move.w	d0,3984(a0)
	move.w	d0,3992(a0)
 
	move.w	scrlfrm(pc),d0
	move.l	scrlptr(pc),a1
	dbra.w	d0,scroll1

	move.l	scrltxt(pc),a2
scroll0	move.l	(a2)+,d1
	beq.w	scrwrap
	move.l	d1,a1
	move.l	a2,scrltxt
	move.l	a1,scrlptr
	moveq.l	#7,d0

scroll1	move.w	d0,scrlfrm
	MOVE.l	#scrlbuf,a0
	move.l	scrlpt2(pc),a3
scroll2	lea.l	$78002+(55*160),a2
	add.l	(a3)+,a2
	cmp.l	#endupdn,a3
	bne.s	scroll3
	lea.l	updndat(pc),a3

scroll3	move.l	a3,scrlpt2
	move.l	a2,scroll2+2
	moveq.l	#4,d1
	jsr	scrlcod
	move.l	a1,scrlptr
	rts

print8	moveq.l	#0,d6
	moveq.l	#1,d7
	move.l	a1,d0
	btst.l	#0,d0
	beq.s	print8b
	moveq.l	#7,d7

print8b	moveq.l	#0,d0
	move.b	(a0)+,d0
	bmi.s	exit

	cmp.b	#13,d0
	beq.s	newline

	move.b	chr8tab-32(pc,d0.w),d0
	asl.w	#3,d0
	lea.l	font8(pc),a2
	add.l	d0,a2

	move.b	(a2)+,(a1)
	move.b	(a2)+,160(a1)
	move.b	(a2)+,320(a1)
	move.b	(a2)+,480(a1)
	move.b	(a2)+,640(a1)
	move.b	(a2)+,800(a1)
	move.b	(a2)+,960(a1)
	move.b	(a2)+,1120(a1)

	add.l	d7,a1
	add.l	d7,d6
	eor.b	#6,d7
	bra.s	print8b

newline	sub.l	d6,a1
	lea.l	9*160(a1),a1
	bra.s	print8

exit	rts

chr8tab	dc.b	0,27,00,0,0,0,0,32,28,29,0,0,31,30,31,0,15,33,34,35,36,37,38,39,40,41,0,0,0,0,0,42,0
	dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26


translt	dc.b	44,28,44,44,44,44,44,30,33,34,44,44,26,31,27,44
	dc.b	14,35,36,37,38,39,40,41,42,43,44,32,33,44,34,29
	dc.b	44,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,45,46,47,48,-1

vblcntr	dc.b	3

text1	dc.b	"THE SOURCE",-1
	dc.b	"MENU DISK",-1
	DC.B	"    32",-1
	dc.b	" ",-1
	dc.b	" ",-1
	dc.b	"   FROM",-1
	dc.b	" KALAMAZOO",-1

text2	dc.b	' ',-1
	DC.B	'2.2.91',-1

text3	dc.b	"     AAAARRRGGGHHH!!!!!      IT'S ME - KALAMAZOO, AND"
	DC.B	" LIKE J.J.F. I'M DOING THE TIMEWARP!!!!          THIS"
	DC.B	" MENU WAS SUPPOSED TO BE FINISHED AROUND THE END OF"
	DC.B	" NOVEMBER BY CAPTAIN WIBBLE,  BUT DUE TO A LACK OF"
	DC.B	" DEMO'S AT WIBBLE HQ, I'M HAVING TO DO THIS MENU FOR HIM,"
	DC.B	" TWO MONTHS LATER!!!          "
	dc.b	" THERE IS ONLY ONE DEMO ON THIS DISK!    WHAT? ONLY ONE!   "
	DC.B	" I HEAR YOU SCREEM....   YES, BUT ITS QUITE A BIG DEMO...     "
	DC.B	" ITS CALLED THE NECHROMANCER MODULE PLAYER.....     "
	DC.B	" WHAT I'VE DONE IS DISCARDED ALL OF THE MODULES THAT"
	DC.B	" CAME WITH IT THAT WE'VE ALREADY DONE.....     I'VE UNPACKED"
	DC.B	" THE OTHER MODULES FROM PACK-ICE V.2 AND REPACKED THEM"
	DC.B	" WITH PACK-ICE V.1 (WHICH IS WHAT ALL OF OUR OTHER MODULES"
	DC.B	" ARE PACKED WITH) SO NOW THE PLAYER IS COMPATABLE WITH"
	DC.B	" ALL OF THE MODULES ON PREVIOUS MENU'S.....       THIS"
	DC.B	" PLAYER WILL ALSO PLAY TCB TRACKER MODULES....  SO I'VE"
	DC.B	" PUT A FEW OF THOSE IN A FOLDER CALLED 'TCB.MOD'.......                     "
	DC.B	"           SORRY BUT THERE'S NO GREETZ ON THIS MENU.   "
	DC.B	'  IF YOU WANT TO SEE YOUR GREET THEN LOOK AT  "THE SOURCE'
	DC.B	' 41"                      OH YEAH!  THIS IS AUTOMATION'
	DC.B	' CODE - SO THANX GUYS!                    LETS WRAP THIS THING     '
	DC.B	"                                                  "
	dc.b	"_"
endtxt3

; end of odds...

newcols	dc.w	$000,$000,$000,$000,$111,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

font32	incbin	"chrset32.nel"
font8	incbin	"chrset08.nel"

vblpntr	dc.l	vblcols

scrltxt	dc.l	shftxt1
scrlptr	dc.l	0
scrlpt2	dc.l	updndat
scrlfrm	dc.w	0

rainbow	dc.w	$070,$071,$072,$073,$074,$075,$076
	dc.w	$077,$067,$057,$047,$037,$027,$017
	dc.w	$007,$107,$207,$307,$407,$507,$607
	dc.w	$707,$706,$705,$704,$703,$702,$701
	dc.w	$700,$710,$720,$730,$740,$750,$760
	dc.w	$770,$670,$570,$470,$370,$270,$170
rainbow_end

vblcols	dc.w	$001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003,$002,$001
	ds.w	20
	dc.w	$010,$020,$030,$040,$050,$060,$070,$060,$050,$040,$030,$020,$010
	ds.w	20
	dc.w	$100,$200,$300,$400,$500,$600,$700,$600,$500,$400,$300,$200,$100
	ds.w	20
	dc.w	$211,$222,$233,$244,$255,$266,$277,$266,$255,$244,$233,$222,$211
	ds.w	20
	dc.w	$121,$222,$323,$424,$525,$626,$727,$626,$525,$424,$323,$222,$121
	ds.w	20
	dc.w	$112,$222,$332,$442,$552,$662,$772,$662,$552,$442,$332,$222,$112
	ds.w	20
endvbl

updndat	dc.l	$a0,$a0,$a0,$a0,$140,$140,$140,$140,$140,$140,$1e0,$1e0,$1e0,$1e0,$1e0,$1e0,$1e0,$1e0,$1e0,$1e0,$140,$140,$140,$140,$140,$140,$a0,$a0,$a0,$a0
	dc.l	0,0,0,0
	dc.l	-$a0,-$a0,-$a0,-$a0,-$140,-$140,-$140,-$140,-$140,-$140,-$1e0,-$1e0,-$1e0,-$1e0,-$1e0,-$1e0,-$1e0,-$1e0,-$1e0,-$1e0,-$140,-$140,-$140,-$140,-$140,-$140,-$a0,-$a0,-$a0,-$a0
	dc.l	0,0,0,0
endupdn

	section	bss

bss1

clock	ds.w	1

oldsp	ds.l	1
oldphys	ds.l	1
oldcols	ds.w	16

old70	ds.l	1
oldfa07	ds.b	1
oldfa09	ds.b	1
oldfa17	ds.b	1

	even

cols	ds.w	100 ; background
	ds.w	100 ; background names
	ds.w	100 ; scroller

shift32	ds.b	18000
shftxt1	ds.b	((endtxt3-text3)*4)
scrlbuf	ds.w	25*20
scrlcod	ds.b	6052

bss2