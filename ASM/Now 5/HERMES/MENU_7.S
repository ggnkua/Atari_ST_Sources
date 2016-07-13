***************************************************************************
*        NOW 5 INTRO 7 Version 1.01 Coded by TERMINATOR of NOW 5          *
*       Do NOT spread outside of NOW 5 Members.Or beware the WORM.        *
***************************************************************************
* Features:	Up to 9 Files						  *
*		16 Colour Bottom Border Scroller			  *
*		Top Border Picture					  *
*		Credits 'Flashline¿'					  *
*		Volume Graphic Equalizer				  *
*		Crap chip music ( Well there had to be something naff! )  *
*		Some time left with the CPU sat on it's arse....	  *
***************************************************************************
* Valid Options:Load Games/Programs 		1-9 (If set-see below)	  *
*		Change Hertz Rate for Exit	0 			  *
***************************************************************************
* Things to Change:	Title			Search for...		  *
*			Picture			'piccy'			  *
*			Font			'font'			  *
*			Flashline Font		'smallfont'		  *
*			Music			'music'			  *
*			Filenames		'file1'			  *
*			Equalizer Palette	'volpalette'		  *
***************************************************************************

		section text
		opt	o-,d-,s-	DO NOT CHANGE

num_fil		equ	2		number of files (max 9)

trans		macro	
		movep.l	\1(a0),d0
		movep.l	d0,\1-7(a0)
		movep.l	\1+1(a0),d0
		movep.l	d0,\1(a0)
		endm
		
trans1		macro	
		movep.l	\1(a1),d0
		movep.l	d0,\1-7(a1)
		movep.l	\1+1(a1),d0
		movep.l	d0,\1(a1)
		endm
		
start		move.l	4(a7),a5
		lea	stack,a7
		move.l	$c(a5),d0
		addi.l	#$100,d0
		move.l	d0,-(sp)
		move.l	a5,-(sp)
		move.l	#$4a0000,-(sp)
		trap	#1
		lea	12(sp),sp
		
		move.w	#4,-(sp)
		trap	#14
		addq.l	#2,sp
		move.w	d0,old_rez
		cmpi.w	#2,d0
		beq	quit_2

		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,old_sp
		
		pea	mse_off(pc)
		move.l	#$190000,-(sp)
		trap	#14
		addq.l	#8,sp

		dc.w	$a00a
		
		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,savepal
		
		move.w	#2,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,old_scr

		move.l	#big_scr+256,d0
		clr.b	d0
		move.l	d0,scr_adr
	
		move.l	d0,a0
		move.w	#280*160,d7
clr_scr		clr.b	(a0)+
		dbf	d7,clr_scr

		move.b	$ffff820a.w,hz
		move.b	#254,$ffff820a.w

		clr.w	-(sp)
		move.l	scr_adr,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	12(sp),sp

		moveq.w	#6,d1
fadeout		rept	3
		move.w	#37,-(sp)
		trap	#14
		addq.l	#2,sp
		endr	
		sub.w	#$111,$ffff8240.w
		dbf	d1,fadeout
		
		lea	$ffff8240.w,a0
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		
		lea	font,a0
		move.w	4(a0),hieght
		move.w	4+2(a0),width
		movem.l	4+2+2+2(a0),d0-d7
		movem.l	d0-d7,fontpal
		move.w	#0,fontpal	makes sure border black

		lea	scrolltext,a0
		move.l	a0,scrollptr

		lea	creditstext,a0
		move.l	a0,creditstextptr

		move.w	#1,$4ee.w

		lea	old_mfp,a0
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa13.w,(a0)+
		move.b	$fffffa15.w,(a0)+
		move.b	$fffffa1f.w,(a0)+
		move.b	$fffffa19.w,(a0)+
		move.b	$fffffa17.w,(a0)+

		clr.b	$484.w
	
		move.w	#$2700,sr
		move.l	#hblank1,$120.w
		lea	keyvec,a0
		move.l	$118.w,6(a0)
		move.l	$118.w,key_vec
		move.l	a0,$118.w
		lea	new_vbl(pc),a0
		move.l	$70.w,2(a0)
		move.l	$70.w,old_vbl
		move.l	#vblank,$70.w
		move.b	#%01000000,$fffffa15.w
		move.b	#%00000001,$fffffa07.w
		bset.b	#3,$fffffa17.w
		move.w	#$2300,sr
		moveq	#-1,d7
over		nop
		dbf	d7,over	
		move.l	#vol_bar,$4e2.w
		move.l	#scroll,$4e6.w
		bsr	mus_on

		cmpi.b	#252,hz
		bne	next
		bsr	changec

next		lea	piccy(pc),a0
		addq.l	#2,a0
		move.l	(a0),col0
		move.l	4(a0),col1
		move.l	8(a0),col2
		move.l	12(a0),col3
		move.l	16(a0),col4
		move.l	20(a0),col5
		move.l	24(a0),col6
		move.l	28(a0),col7
		lea	32(a0),a0

		move.l	scr_adr,a1
		lea	32000(a0),a2
		lea	32000(a1),a3
		moveq	#49,d7
.pic1		moveq	#39,d6
.pic2		move.l	(a0)+,(a1)+
		move.l	-(a2),-(a3)
		nop
		dbf	d6,.pic2 
		adda.l	#160,a0
		adda.l	#160,a1
		suba.l	#160,a2
		suba.l	#160,a3
		moveq	#39,d6
.pic22		move.l	(a0)+,(a1)+
		move.l	-(a2),-(a3)
		nop
		dbf	d6,.pic22 

		move.w	#-1,$468.w
.vsync		tst.w	$468.w
		bne.s	.vsync

		adda.l	#160,a0
		adda.l	#160,a1
		suba.l	#160,a2
		suba.l	#160,a3

		dbf	d7,.pic1
	
vblank_loop	move.b	$469.w,d0
vbl		cmp.b	$469.w,d0
		beq.s	vbl
		move.l	#$600ff,-(sp)
		trap	#1
		addq.l	#4,sp
		swap	d0
		tst.b	d0
		beq.s	finished
		swap	d0
		cmpi.b	#48,d0
		beq	hertz
		sub.b	#48,d0
		cmpi.b	#1,d0
		bge.s	.lmax
		bra.s	finished
.lmax		cmpi.b	#num_fil,d0
		bgt.s	finished
		move.b	d0,file+1
		bra	quit
finished	subq.w	#1,pause	check to see if we do a line
		tst.w	pause
		bpl	vblank_loop
		move.w	#0,d3	x coordinate	start of x
		move.l	scr_adr,a0
		move.l	#160*202,d4
		adda.l	d4,a0
		move.l	a0,a5
		lea	x_table,a3	get x offset
		move.l	creditstextptr,a2	text address
		lsl	d3		
		add.w	d3,a3		offset into x table
nextletter	move.w	(a3)+,d3
		move.l	a5,a0
		adda.w	d3,a0		x offset
		moveq.w	#0,d1
		move.b	(a2)+,d1
		cmp.b	#255,d1
		beq	wraptext
		cmp.b	#"@",d1
		beq	endline
		sub.w	#32,d1
		lsl.w	#3,d1
		lea	smallfont,a1
		adda.l	d1,a1
num		set	0
		rept	8
		move.b	(a1)+,num(a0)
num		set	num+160
		endr
		bra	nextletter
endline		move.b	(a2)+,d7
		ext.w	d7
		move.w	d7,pause
		move.l	a2,creditstextptr
		bra	vblank_loop
wraptext	lea	creditstext,a0
		move.l	a0,creditstextptr
		move.b	(a2)+,d7
		ext.w	d7
		move.w	d7,pause
		bra	vblank_loop

quit		bsr	hbl_off

		pea	mse_on(pc)
		move.l	#$190000,-(sp)
		trap	#14
		addq.l	#8,sp

		dc.w	$a009

		move.w	#-1,$4ee.w
		
		move.w	old_rez,-(sp)
		move.l	old_scr,-(sp)
		move.l	old_scr,-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	12(sp),sp

		move.b	hz,$ffff820a.w
		
		bsr	mus_off
		clr.l	$4e2.w
		clr.l	$4e6.w
		
		move.l	$44e.w,a0
		move.w	#1999,d7
clp21		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		dbra	d7,clp21

		moveq.w	#6,d1
fadeback	rept	3
		move.w	#37,-(sp)
		trap	#14
		addq.l	#2,sp
		endr
		add.w	#$111,$ffff8240.w
		dbf	d1,fadeback
		
		movem.l	savepal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.l	old_sp,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		
		move.w	file,d0
		moveq	#0,d1
		move.w	d0,d1
		subq.w	#1,d1
		lsl	#2,d1
		lea	fnames(pc),a0
		adda.l	d1,a0
		move.l	(a0),a6
		pea	env_com(pc)
		pea	env_com(pc)
		move.l	a6,-(sp)
		move.l	#$4b0000,-(sp)
		trap	#1
		lea	16(sp),sp
env_com		dc.b	0
		even
file		dc.b	0
		even
file1		dc.b	'a:\auto\final.prg',0	
file2   	dc.b    'a:\cj.prg',0
file3		dc.b	'a:\genstd.prg',0	
file4   	dc.b    'a:\genstd.prg',0
file5		dc.b	'a:\genstd.prg',0	
file6   	dc.b    'a:\genstd.prg',0
file7		dc.b	'a:\genstd.prg',0	
file8   	dc.b    'a:\genstd.prg',0
file9		dc.b	'a:\genstd.prg',0	
        	even
fnames		dc.l	file1,file2,file3,file4,file5
		dc.l	file6,file7,file8,file9
 		even

quit_2		clr.w	-(sp)
		trap	#1
scroll		bsr	do_scroll
		addq.b	#1,count1
		cmp.b	#4,count1
		beq.s	nextlet
		rts
nextlet		clr.b	count1
		move.l	scrollptr,a0
		move.b	(a0)+,d0
		cmp.b	#255,d0
		beq	wrap
		move.l	a0,scrollptr
		sub.b	#32,d0
		move.w	width,d1
		addq.w	#1,d1
		mulu	d1,d0
		move.w	hieght,d1
		addq.w	#1,d1
		mulu	d1,d0
		lea	font,a0
		adda.l	#42,a0
		adda.l	d0,a0
		lea	scrollbuffer,a1
		move.w	hieght,d0
prepare		move.w	(a0),(a1)
		move.w	2(a0),2(a1)
		move.w	4(a0),4(a1)
		move.w	6(a0),6(a1)
		move.w	8(a0),8(a1)
		move.w	10(a0),10(a1)
		move.w	12(a0),12(a1)
		move.w	14(a0),14(a1)
		adda.l	#16,a1
		adda.l	#16,a0		font width
		dbra	d0,prepare
		rts
		
do_scroll	lea	scrollbuffer,a1
		move.l	$44e.w,a0
		adda.l	#160*228,a0
		move.w	hieght,d1
scrolline	movep.l	1(a0),d0
		movep.l	d0,(a0)
		trans	8
		trans	16
		trans	24
		trans	32
		trans	40
		trans	48
		trans	56
		trans	64
		trans	72
		trans	80
		trans	88
		trans	96
		trans	104
		trans	112
		trans	120
		trans	128
		trans	136
		trans	144
		trans	152
		movep.l	(a1),d0
		movep.l	d0,153(a0)
		trans1	0
		trans1	8
		adda.l	#16,a1
		adda.l	#160,a0
		dbf	d1,scrolline
		rts

wrap		move.b	#32,d0
		lea	scrolltext,a0
		move.l	a0,scrollptr
		rts	
		
hblank1		move.w	#$0,$ffff8240.w
		clr.b	$fffffa1b.w
		move.l	#hblank1a,$120.w
		move.b	#176,$fffffa21.w
		move.b	#8,$fffffa1b.w
		bclr.b	#0,$fffffa0f.w
		rte

hblank1a	move.l	volpalette,$ffff8240.w
		move.l	volpalette+4,$ffff8244.w
		move.l	volpalette+8,$ffff8248.w
		move.l	volpalette+12,$ffff824c.w
		move.l	volpalette+16,$ffff8250.w
		move.l	volpalette+20,$ffff8254.w
		move.l	volpalette+24,$ffff8258.w
		move.l	volpalette+28,$ffff825c.w
		clr.b	$fffffa1b.w
		move.l	#hblank2,$120.w
		move.b	#26,$fffffa21.w
		move.b	#8,$fffffa1b.w
		bclr.b	#0,$fffffa0f.w
		rte	

hblank2		clr.b	$fffffa1b.w
		move.l	#hblank3,$120.w
		move.b	#2,$fffffa21.w
		move.b	#8,$fffffa1b.w
		move.w	hzcol,$ffff8240.w
		move.w	fontpal+2,$ffff8242.w
		move.l	fontpal+4,$ffff8244.w
		move.l	fontpal+8,$ffff8248.w
		move.l	fontpal+12,$ffff824c.w
		move.l	fontpal+16,$ffff8250.w
		move.l	fontpal+20,$ffff8254.w
		move.l	fontpal+24,$ffff8258.w
		move.l	fontpal+28,$ffff825c.w
		bclr.b	#0,$fffffa0f.w
		rte

hblank3		move.l	d0,-(sp)
		move.w	sr,-(sp)
		move.w	#$2700,sr
		moveq	#24,d0
.hbl1		nop
		dbf	d0,.hbl1
		clr.b	$ffff820a.w
		moveq	#4,d0
.hbl2		nop
		dbf	d0,.hbl2
		move.b	#2,$ffff820a.w
		move.w	(sp)+,sr
		move.l	(sp)+,d0
		bclr.b	#0,$fffffa0f.w
		rte

vblank		move.l	col0,$ffff8240.w
		move.l	col1,$ffff8244.w
		move.l	col2,$ffff8248.w
		move.l	col3,$ffff824c.w
		move.l	col4,$ffff8250.w
		move.l	col5,$ffff8254.w
		move.l	col6,$ffff8258.w
		move.l	col7,$ffff825c.w
		move.b	#1,$fffffa21.w
		move.b	#8,$fffffa1b.w
		ori.b	#1,$fffffa07.w
		ori.b	#1,$fffffa13.w
		move.l	d0,-(sp)
		move	sr,-(sp)
		move.w	#$2700,sr
		move.l	#1399,d0	
.wait		dbra	d0,.wait
		move.b	#0,$ffff820a.w
		move.w	#3,d0
.wait2		dbf	d0,.wait2
		move.b	#2,$ffff820a.w
		move.w	(sp)+,sr
		move.l	#hblank1,$120.w
.wait3		move.l	(sp)+,d0
		clr.b	$fffffa1b.w
		move.b	#24,$fffffa21.w
		move.b	#8,$fffffa1b.w
new_vbl		jmp	$0.l

keyvec		move.w	#$2500,sr
		jmp	$0.l

ipl_nul		bclr.b	#5,$fffffa0f.w
		rte

hbl_off		move.w	#$2700,sr
		move.l	key_vec,$118.w
		move.l	old_vbl,$70.w
		move.l	#ipl_nul,$120.w
		lea	old_mfp,a0
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa13.w
		move.b	(a0)+,$fffffa15.w
		move.b	(a0)+,$fffffa1f.w
		move.b	(a0)+,$fffffa19.w
		move.b	(a0)+,$fffffa17.w
		move.w	#$2300,sr
		rts

hertz		eori.b	#2,hz
		jsr	changec
.end		bra	finished

changec		eori.w	#2,hzcol
		rts


mus_off		lea	$456.w,a0
		move.l	(a0),a0
.slot		tst.l	(a0)+
		bne.s	.slot
		clr.l	-8(a0) 
		lea	$ffff8800.w,a0
		move.l 	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)
		move.b	#$7,$484.w
		rts

mus_on		moveq #1,d0
		jsr music	
		lea	$456.w,a0
		move.l	(a0),a0
.slot		tst.l	(a0)+
		bne.s	.slot
		move.l	#music+8,-(a0)
		rts

vol_bar		movem.l	d4-d7/a0-a1,-(sp)
		lea	$ffff8800.w,a0
		moveq.w	#2,d5
.chans		moveq.w	#8,d4
		add.w	d5,d4
		move.b	d4,(a0)
		move.b	(a0),d4
		andi.b	#15,d4
		moveq.w	#0,d7
		move.l	scr_adr,a1
		adda.l	#160*211+2,a1
		adda.l	#16,a1
		move.l	d5,d6
		mulu	#(5*160),d6
		add.w	d5,d6
		add.w	d5,d6
		adda.w	d6,a1
		move.b	d4,d7
.plot		move.w	#%1111111111111111,(0*160)(a1)
		move.w	#%1111111111111111,(1*160)(a1)
		move.w	#%1111111111111111,(2*160)(a1)
		move.w	#%1111111111111111,(3*160)(a1)
		addq.l	#8,a1
		dbf	d7,.plot
		moveq	#15,d7
		sub.b	d4,d7
.unplot		clr.w	(0*160)(a1)
		clr.w	(1*160)(a1)
		clr.w	(2*160)(a1)
		clr.w	(3*160)(a1)
		addq.l	#8,a1
		dbf	d7,.unplot
		dbf	d5,.chans
		movem.l	(sp)+,d4-d7/a0-a1
		rts


		section data
mse_off		dc.b	$12,$00
mse_on		dc.b	$08,$00
count1		dc.b	3
		even
volpalette	dc.w	$000
		dc.w	$666	Flashline colour
		dc.w	$707	Equalizer 1 colour
		dc.w	$000
		dc.w	$077	Equalizer 2 colour
		dc.w	$000,$000,$000
		dc.w	$770	Equalizer 3 Colour
		dc.w	$000,$000,$000,$000,$000,$000,$000
speed		dc.w	6
hz		dc.b	252
		even
* Scrolltext.Use whatever chars are in the font.Wrap with $ff or 255.
scrolltext	dc.b	"  WELL, HERE I AM WITH ANOTHER MENU FOR YOU ALL. AND JUST IN CASE YOU HAD NOT NOTICED WE HAVE NOW JOINED THE COLLABORATION. WE WERE INVITED ON FRIDAY NIGHT AT COMPUTER CLUB. THIS MENU WOULD HAVE HAD SOME TRACKER MUSIC ON IT"
		DC.B	" BUT THERE ARE ONLY A FEW MODULES THAT WORK WITH OUR CODE SO WE WILL HAVE TO GET IT FIXED BEFORE WE CAN GIVE YOU MORE. DO NOT WORRY ABOUT IT, THOUGH BECAUSE THE GAMES ON THIS MENU ARE FINAL FIGHT (CRACKED BY THE MEDWAY BOYS)"
		DC.B	" AND CJ S ELEPHANT ANTICS (CRACKED BY LETHAL AND PACKED BY THE ALIEN). THERE HAS BEEN A SUDDEN INCREASE IN SOFTWARE RECENTLY SO WE MAY MAKE MENU 25 BY CHRISTMAS (SPECIALLY FOR SONIC), BUT WILL THE SPECIAL CHRISTMAS MODULE"
		DC.B	" WE HAVE GOT WORK WITH OUR TRACKER MENU CODE? WELL YOU WILL JUST HAVE TO WAIT AND SEE.     IT IS A BUMMER NOT HAVING APOSTROPHES ON THIS FONT BECAUSE I HAVE GOT TO MAKE ALL ABBREVIATIONS FULL OR THEY WILL LOOK STUPID....."
		dc.b	255
		even
* Flashline Text.Up to 40 chars per line.Use any char in the font.
* End with '@' to signify end of line.Next number is delay in 50ths of 
* a second.ie 100=2 seconds before the next line is displayed.
* Wrap with 255 or $ff:-don't forget the delay after it. 
* Screen width guide:-	 0123456789 123456789 123456789 123456789
creditstext	dc.b	"    THE BLUES BROTHERS MENU 15 DISK A   ","@",150
		dc.b	"                                        ","@",100
		dc.b	"PRESS 1 FOR FINAL FIGHT(DISK B IN DRIVE)","@",100
		dc.b	"                                        ","@",100
		dc.b	"    PRESS 2 FOR CJ'S ELEPHANT ANTICS    ","@",100
		dc.b	"                                        ","@",100
		dc.b	"    THANKS TO TERMINATOR FOR THIS CODE  ","@",100
		dc.b	"                                        ","@",100
		dc.b	"    MEMBERS OF THE BLUES BROTHERS ARE:  ","@",100
		dc.b	"    GRIM REAPER:CODER AND MENU SORTING  ","@",100
		dc.b	"    SONIC:CODER,ARTIST + MENU SORTING   ","@",100
		dc.b	"    SAMURI PIZZA CAT:CODER AND SAMPLER  ","@",100
		DC.B	"                EWOK:MUSICIAN           ","@",100
		DC.B	"     DAMAGE INC.:CURRENTLY SPREADER     ","@",100
		DC.B	"      STICK:CURRENTLY ONLY SPREADER     ","@",100
                DC.B	"                                        ","@",250
		dc.b	"                                        ",255,50
		even
creditstextptr	ds.l	1
		even
piccy		incbin	chaos.pi1	low res degas un-compressed
		even
music		incbin	fletch.mus	menu music.See previous 'music'
				       *to change format ie MadMax/Countzero
		even
font		incbin	gcslight.f32	* Font for scroller in Death's Format.
					*this is not 100% Death compatible
				    	*it only works with 32 pixel wide fonts
				    	*otherwise fully self configuring.
				    	*fix for non 32 pixel wide fonts soon
				    	*guaranteed works with;
				    	*			Soundemo.F31
				    	*			Rplicnts.F32
				    	*			Flips.F33
		even
smallfont	incbin	88font.fn1 Small font for Flashline.See Font.s
x_table		
num		set	0
		rept	20
		dc.w	num
		dc.w	num+1
num		set	num+8
		endr
pause		dc.w	10
		ds.w	1
		even
		section bss
hzcol		ds.w	1
chradd		ds.l	1
old_mfp		ds.b	8
icol1		ds.w	1
col0		ds.l	1
col1		ds.l	1
col2		ds.l	1
col3		ds.l	1
col4		ds.l	1
col5		ds.l	1
col6		ds.l	1
col7		ds.l	1
old_rez		ds.w	1
tune_no		ds.w	1
var		ds.w	1
savepal		ds.w	16
fontpal		ds.w	16
width		ds.w	1
hieght		ds.w	1
scrollptr	ds.l	1
key_vec		ds.l	1
old_sp		ds.l	1
old_vbl		ds.l	1
old_scr		ds.l	1
scr_adr		ds.l	1
wve_pos		ds.l	1
sct_pad		ds.l	11
		ds.l	100
stack		ds.l	1
oldint		ds.l	1
scrollbuffer	ds.w	8*32
		ds.b	256
big_scr		ds.l	1
		ds.b	160*280	screen
