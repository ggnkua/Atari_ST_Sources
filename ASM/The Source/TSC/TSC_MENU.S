;
; The Syndicate Menu Source by ????
;
; Additional bits & pieces by MUG U.K
;

	opt	o+

start	bra.s	begin
	dc.b	'The Source present Menu 120 - disk compiled '
	dc.b	'and presented to you by: MUG U.K',191,' !!'
	even

begin	bra	stack

**	Execute the Program...(PEXEC)

gotit	pea	envcom
	move.l	(sp),-(sp)
	pea	(a0)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
desk	clr.w	-(sp)		Back to desktop
	trap	#1
envcom	ds.l	200		Stack space
mystack	dc.l	0
*YOUR GAME NAMES HERE.....

games	dc.b	"game1.prg",0,"game2.prg",0,"game3.prg",0
	even

;**	Allocate Memory

stack	move.l 	$4(a7),a5			Reserve Memory.. a5=basepage..
 	move.l 	#stack-(begin-$100),-(a7)	Reserve xxxxx bytes..
	move.l 	a5,-(a7)			..start of reserved memory	
	move.l 	#$4a0000,-(a7)
	trap 	#1
	lea	12(a7),a7
	tst.l	d0
	bne	desk			Error occured?

	lea	mystack,sp
	bsr	super
	
	move.w	#0,$452.w

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,save_pal

	move.l	$fffffa06.w,save_ierx+2
	move.l	$fffffa12.w,save_imrx+2
	move.b	$fffffa17.w,save_vec+3
	move.l	#$ff00ff00,$fffffa06.w
	move.l	#$ff00ff00,$fffffa12.w

	move.l	$120.w,save_hbi+2

	move.w	#3,-(sp)
	trap	#14
	move.l	d0,log+2

	move.w	#2,-(sp)
	trap	#14
	move.l	d0,phys+2

	move.w	#0,-(sp)
	move.l	#$75000,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.b	#$1a,$fffffc02.w

	lea	$75000,a0
	lea	piccy+34,a1
	move.w	#7999,d0

cls:	move.l	(a1)+,(a0)+
	dbra	d0,cls
	
	moveq	#1,d0
	jsr	muzak

	jsr	pre_dist
	jsr	scroll

	move.l	#$0f000f00,dist_pal+16
	move.l	#$0f000f00,dist_pal+20
	move.l	#$0f000f00,dist_pal+24
	move.l	#$0f000f00,dist_pal+28

	move.l	#$ff01ff00,$fffffa06.w
	move.l	#$ff01ff00,$fffffa12.w
	and.b	#$f7,$fffffa17.w

	move.b	#$12,$fffffc02.w

	move.l	#hbi,$120.w
	lea	$ffff8248.w,a5

	move.b	#0,$fffffa1b.w
	move.b	#-1,$fffffa21.w
	move.b	#8,$fffffa1b.w

wrap_y_sin:
	move.l	#s_sinus,h+2
*******************************
*          MAIN LOOP          *
*******************************
prog	move.l	#$75004-1280,display_big+2
	moveq	#0,d0
h:	move.w	s_sinus,d0
	bmi.s	wrap_y_sin
	addq.l	#2,h+2
	mulu	#160,d0
	add.l	d0,display_big+2

	move.l	#colors,a0
	move.l	a0,do_m+2
	lea	2(a0),a1

	move.w	(a0),d7
	rept	49
	move.w	(a1)+,(a0)+
	endr
	move.w	d7,(a0)

	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp

	move.b	#0,$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w

	movem.l	dist_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	jsr	scroll
	jsr	fix_into_big_buf
	jsr	display_big
	jsr	do_dist
	jsr	muzak+4

	addq.w	#1,lite_vi_countar
	and.w	#$7,lite_vi_countar
	bne	no_acid_diz_time

	jsr	printer

	add.l	#$01100110,dist_pal+$10
	add.l	#$01100110,dist_pal+$14
	add.l	#$01100110,dist_pal+$18
	add.l	#$01100110,dist_pal+$1c

	and.l	#$07770777,dist_pal+$10
	and.l	#$07770777,dist_pal+$14
	and.l	#$07770777,dist_pal+$18
	and.l	#$07770777,dist_pal+$1c
	
	bra.s	no_acid_diz_time
lite_vi_countar:	ds.l	1
lite_vi_countar2:	ds.l	1
no_acid_diz_time:
**********************
* key routine        *
**********************
	move.b	$fffc02,key
	beq	prog
	cmp.b	#4,key		Numbers 1-2-3 keys Increase/decrease as nessesary
	bgt	prog
	cmp.b	#2,key
	blt	prog
	subq.b	#2,key
**************************
*      exit routine      *
**************************
	move.b	#$8,$fffffc02.w
;	jsr	muzak+2
	move.l	#$08080000,$ffff8800.w
	move.l	#$09090000,$ffff8800.w
	move.l	#$0a0a0000,$ffff8800.w
	move.l	#$0707ffff,$ffff8800.w

	movem.l	save_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

save_ierx	move.l	#"MUG ",$fffffa06.w
save_imrx	move.l	#"U.K.",$fffffa12.w
save_vec	move.b	#"!",$fffffa17.w
save_hbi	move.l	#"1992",$120.w

	move.w	#1,$452.w

rez:	move.w	#"HI",-(sp)
log:	move.l	#"to",-(sp)
phys:	move.l	#"you",-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

user	move.l	oldsp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

;----- Get filename using key selected.-----

gamekey	clr.l	d0
	move.b	key,d0		Get selected program number
	bmi	desk		Desktop here we come...
	lea	games,a0
.2	subq.b	#1,d0
	bmi	gotit
.1	tst.b	(a0)+
	bne.s	.1
	bra.s	.2
	cmp.l	#'dtop',(a0)
	beq	desk
	bra	gotit
	even
;RIGHT!  GO LOAD THE BLOODY GAME!!!!
************************************
pre_dist:
	lea	logo,a0
	move.w	#399,d7			*2 bitplanes
pre_dist_logo_loop:
	move.w	(a0),d0
	ror.w	d0
	move.w	d0,1*1024(a0)
	ror.w	d0
	move.w	d0,2*1024(a0)
	ror.w	d0
	move.w	d0,3*1024(a0)
	ror.w	d0
	move.w	d0,4*1024(a0)
	ror.w	d0
	move.w	d0,5*1024(a0)
	ror.w	d0
	move.w	d0,6*1024(a0)
	ror.w	d0
	move.w	d0,7*1024(a0)
	ror.w	d0
	move.w	d0,8*1024(a0)
	ror.w	d0
	move.w	d0,9*1024(a0)
	ror.w	d0
	move.w	d0,10*1024(a0)
	ror.w	d0
	move.w	d0,11*1024(a0)
	ror.w	d0
	move.w	d0,12*1024(a0)
	ror.w	d0
	move.w	d0,13*1024(a0)
	ror.w	d0
	move.w	d0,14*1024(a0)
	ror.w	d0
	move.w	d0,15*1024(a0)
	addq.l	#2,a0
	dbra	d7,pre_dist_logo_loop

	lea	sin_point,a0
	lea	end_sin,a1
fix_f:	and.w	#$f,(a0)+
	cmp.l	a1,a0
	blt.s	fix_f	
	rts

do_dist:
	move.l	#sin_point,a0
	add.l	#2,do_dist+2
	cmp.l	#end_sin-400,a0
	blt.s	no_sin_wrap
	move.l	#sin_point,a0
	move.l	a0,do_dist+2
no_sin_wrap:

	lea	logo,a6
	move.w	#199,d7

	move.l	screen_ptr,a4
	moveq	#10,d1
	moveq	#0,d0

do_distxct_loop:
	move.w	(a0)+,d0
	lsl.l	d1,d0
	move.l	0(a6,d0.w),d6
	move.l	d6,(a4)
	move.l	d6,8(a4)
	move.l	d6,16(a4)
	move.l	d6,24(a4)
	move.l	d6,32(a4)
	move.l	d6,40(a4)
	move.l	d6,48(a4)
	move.l	d6,56(a4)
	move.l	d6,64(a4)
	move.l	d6,72(a4)
	move.l	d6,80(a4)
	move.l	d6,88(a4)
	move.l	d6,96(a4)
	move.l	d6,104(a4)
	move.l	d6,112(a4)
	move.l	d6,120(a4)
	move.l	d6,128(a4)
	move.l	d6,136(a4)
	move.l	d6,144(a4)
	move.l	d6,152(a4)

	lea	160(a4),a4
	addq.l	#4,a6
	dbra	d7,do_distxct_loop
	rts

char_count:	ds.l	1
scroll:	addq.l	#1,char_count
	and.l	#$f,char_count
	bne	no_new_char

	lea	scroll_buff+6,a1
	lea	font,a0

	moveq	#0,d7
heje:	move.b	real_text,d7
	bpl.s	no_wrap_m
	move.l	#real_text-1,heje+2
	moveq	#$20,d7
no_wrap_m:
	addq.l	#1,heje+2

	sub.b	#$20,d7
	lsl.l	#5,d7
	add.l	d7,a0
	
count	set	0
	rept	16
	move.w	(a0)+,count(a1)
count	set	count+8
	endr

no_new_char:
	lea	scroll_buff,a0

	moveq	#15,d0
loop_er:
	and.w	#$ff00,sr
	roxl.w	6(a0)
	roxl.w	4(a0)
	roxl.w	2(a0)
	roxl.w	(a0)
	addq.l	#8,a0	
	dbra	d0,loop_er
	rts

fix_into_big_buf:

	moveq	#15,d0
	lea	scroll_buff,a0
	lea	big_buff,a1
	lea	big_tab,a6

convert_loop:
	move.l	(a0)+,d7

	rept	8
	rol.l	#4,d7
	move.l	d7,d6
	and.l	#$f,d6
	lsl.l	#2,d6
	cmp.l	#$3c,d6
	bgt	error

	moveq	#0,d1
	move.l	0(a6,d6.w),(a1)+
	endr

	move.w	(a0),d7
	rol.w	#4,d7
	move.w	d7,d6
	and.l	#$f,d6
	lsl.l	#2,d6

	move.l	0(a6,d6),(a1)+

	rol.w	#4,d7
	move.w	d7,d6
	and.l	#$f,d6
	lsl.l	#2,d6
	move.l	0(a6,d6),(a1)+

	addq.l	#4,a0
	dbra	d0,convert_loop
	rts

error:	add.w	#1,$ffff8240.w
	bra.s	error

display_big:
	move.l	#$75004-1280,a0
	moveq	#17,d0
	lea	big_buff-40,a1
	
display_big_loop:
fuck_you	set	0
	rept	2
	movem.w	(a1)+,d1-d7/a2-a4
	
	move.w	d1,fuck_you(a0)
	move.w	d1,160+fuck_you(a0)
	move.w	d1,320+fuck_you(a0)
	move.w	d1,480+fuck_you(a0)
	move.w	d1,640+fuck_you(a0)
	move.w	d1,800+fuck_you(a0)
	move.w	d1,960+fuck_you(a0)
	move.w	d1,1120+fuck_you(a0)
fuck_you	set	fuck_you+8
	move.w	d2,fuck_you(a0)
	move.w	d2,160+fuck_you(a0)
	move.w	d2,320+fuck_you(a0)
	move.w	d2,480+fuck_you(a0)
	move.w	d2,640+fuck_you(a0)
	move.w	d2,800+fuck_you(a0)
	move.w	d2,960+fuck_you(a0)
	move.w	d2,1120+fuck_you(a0)
fuck_you	set	fuck_you+8
	move.w	d3,fuck_you(a0)
	move.w	d3,160+fuck_you(a0)
	move.w	d3,320+fuck_you(a0)
	move.w	d3,480+fuck_you(a0)
	move.w	d3,640+fuck_you(a0)
	move.w	d3,800+fuck_you(a0)
	move.w	d3,960+fuck_you(a0)
	move.w	d3,1120+fuck_you(a0)
fuck_you	set	fuck_you+8
	move.w	d4,fuck_you(a0)
	move.w	d4,160+fuck_you(a0)
	move.w	d4,320+fuck_you(a0)
	move.w	d4,480+fuck_you(a0)
	move.w	d4,640+fuck_you(a0)
	move.w	d4,800+fuck_you(a0)
	move.w	d4,960+fuck_you(a0)
	move.w	d4,1120+fuck_you(a0)
fuck_you	set	fuck_you+8
	move.w	d5,fuck_you(a0)
	move.w	d5,160+fuck_you(a0)
	move.w	d5,320+fuck_you(a0)
	move.w	d5,480+fuck_you(a0)
	move.w	d5,640+fuck_you(a0)
	move.w	d5,800+fuck_you(a0)
	move.w	d5,960+fuck_you(a0)
	move.w	d5,1120+fuck_you(a0)
fuck_you	set	fuck_you+8
	move.w	d6,fuck_you(a0)
	move.w	d6,160+fuck_you(a0)
	move.w	d6,320+fuck_you(a0)
	move.w	d6,480+fuck_you(a0)
	move.w	d6,640+fuck_you(a0)
	move.w	d6,800+fuck_you(a0)
	move.w	d6,960+fuck_you(a0)
	move.w	d6,1120+fuck_you(a0)
fuck_you	set	fuck_you+8
	move.w	d7,fuck_you(a0)
	move.w	d7,160+fuck_you(a0)
	move.w	d7,320+fuck_you(a0)
	move.w	d7,480+fuck_you(a0)
	move.w	d7,640+fuck_you(a0)
	move.w	d7,800+fuck_you(a0)
	move.w	d7,960+fuck_you(a0)
	move.w	d7,1120+fuck_you(a0)
fuck_you	set	fuck_you+8
	move.w	a2,fuck_you(a0)
	move.w	a2,160+fuck_you(a0)
	move.w	a2,320+fuck_you(a0)
	move.w	a2,480+fuck_you(a0)
	move.w	a2,640+fuck_you(a0)
	move.w	a2,800+fuck_you(a0)
	move.w	a2,960+fuck_you(a0)
	move.w	a2,1120+fuck_you(a0)
fuck_you	set	fuck_you+8
	move.w	a3,fuck_you(a0)
	move.w	a3,160+fuck_you(a0)
	move.w	a3,320+fuck_you(a0)
	move.w	a3,480+fuck_you(a0)
	move.w	a3,640+fuck_you(a0)
	move.w	a3,800+fuck_you(a0)
	move.w	a3,960+fuck_you(a0)
	move.w	a3,1120+fuck_you(a0)
fuck_you	set	fuck_you+8
	move.w	a4,fuck_you(a0)
	move.w	a4,160+fuck_you(a0)
	move.w	a4,320+fuck_you(a0)
	move.w	a4,480+fuck_you(a0)
	move.w	a4,640+fuck_you(a0)
	move.w	a4,800+fuck_you(a0)
	move.w	a4,960+fuck_you(a0)
	move.w	a4,1120+fuck_you(a0)
fuck_you	set	fuck_you+8
	endr
	lea	1280(a0),a0
	dbra	d0,display_big_loop
	rts

super	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp
	rts

printer:
	move.l	#print_msg,a0
	moveq	#0,d0
	move.b	(a0),d0

	cmp.b	#$fd,d0
	blt.s	no_do

	cmp.b	#-1,(a0)
	bne.s	no_wrap

	move.l	#print_msg,printer+2
	move.b	#0,x_pos
	move.b	#0,y_pos
	bra.s	printer

no_wrap:
	cmp.b	#$fe,(a0)
	bne.s	no_do
	addq.l	#1,a0
	move.b	(a0)+,x_pos
	move.b	(a0)+,y_pos
	move.l	a0,printer+2
	bra	home

no_do:	cmp.b	#$fd,(a0)
	bne.s	no_home

	move.b	#0,x_pos
	move.b	#0,y_pos

no_home:
	move.b	(a0)+,d0
	move.l	a0,printer+2
	cmp.b	#$d,d0
	bne	no_lf

	addq.b	#1,y_pos
	move.b	#0,x_pos

	bra	home

no_lf:	cmp.b	#$8,d0
	bne.s	no_bs
	subq.w	#1,x_pos
	bra	home

no_bs:	tst.b	d0
	bne.s	draw
	bra	home

draw:	lea	font_8x8,a0
	moveq	#0,d7
	moveq	#0,d6

	move.b	y_pos,d7
	move.b	x_pos,d6

	lsl.l	#3,d7
	mulu	#160,d7
	add.l	#$75006,d7
	move.l	d7,a1

	moveq	#0,d5
	move.w	d6,d5
	and.w	#1,d5
	and.w	#$fffe,d6
	lsl.l	#2,d6
	add.l	d5,d6
	add.l	d6,a1

	sub.b	#$20,d0
	lsl.l	#3,d0
	add.l	d0,a0

	move.b	(a0)+,(a1)
	move.b	(a0)+,1*160(a1)
	move.b	(a0)+,2*160(a1)
	move.b	(a0)+,3*160(a1)
	move.b	(a0)+,4*160(a1)
	move.b	(a0)+,5*160(a1)
	move.b	(a0)+,6*160(a1)
	move.b	(a0)+,7*160(a1)

	addq.b	#1,x_pos

	cmp.b	#40,x_pos
	bne.s	no_x_wrap
	addq.b	#1,y_pos
	move.b	#0,x_pos
no_x_wrap:
home:	and.b	#7,y_pos
	rts

hbi:	move.w	d0,-(sp)
do_m:	move.w	colors,d0
	move.w	d0,$ffff8248.w
	move.w	d0,2+$ffff8248.w
	move.w	d0,4+$ffff8248.w
	move.w	d0,6+$ffff8248.w
	move.w	(sp)+,d0
	addq.l	#2,do_m+2
	move.b	#0,$fffffa1b.w
	move.b	#4,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

x_pos:	ds.w	1
y_pos:	ds.w	1

font_8x8:	incbin	font.8x8
print_msg:
	dc.b	    "          SPECIAL FX MENU MAKER           ",$d 
	dc.b        "  CODE FOUR.    CREDITS... CODER UNKNOWN  ",$d
	dc.b        "  MUSIC... MAD MAX.   ADDITIONAL CODE BY  ",$d
	dc.b        "                 JAM!                     ",$d
	dc.b        "                                          ",$d
	dc.b        "                                          ",$d
	dc.b        "                                          ",$d
	dc.b        "                                          ",$d
	dc.b        "                                          ",$d
	
	dc.b	0,0,0,0,0
	dcb.b	50,0
	dc.b	-1
 	even

colors:					*64 words

 DC.W $710,$720,$730,$740,$750,$760,$770,$770,$770,$770,$770,$770,$770,$770,$670,$570,$470
 DC.W $370,$270,$170,$070,$071,$072,$073,$074,$075,$076,$077,$076,$075,$074,$073,$072,$071,$070,$171,$272,$373,$474,$575,$676,$777,$777,$766,$755,$744,$733,$722,$711,$700,$700,$700,$700

;
; Scroller goes here
;

real_text	dc.b	"THE SOURCE ARE PROUD TO PRESENT YOU WITH"
	dc.b	"                MENU 120                "
	dc.b	""
	dc.b	"DISK COMPILATION BY: MUG U.K",$bf," 1992"
	dc.b	-1
		even

	ds.l	7770

big_tab:	include	copyb2.s

dist_pal:	incbin	dist_pal.pal
	even
logo:		incbin	dist_pic.dst
		ds.b	15*1024
	even
screen_ptr:	dc.l	$75000
	even
sin_point:	dcb.w	200,0
		include	s_sinus.s
		dcb.w	250,0
end_sin:

s_sinus:	include	sinus.s
	dc.l	-1

muzak:	incbin	misfit.mus
	even

font:	incbin	font.fnt
	even

piccy:	incbin	SFXPIC2.pi1	;your piccy
	even

key	dc.b	0
oldsp	dc.l	0
	section bss
	even
null:	ds.l	1
save_pal:	ds.w	16
	ds.b	160
big_buff:	ds.b	200*40
	ds.b	160
	ds.b	160
	ds.b	160
scroll_buff:	ds.b	6000
		ds.l	7770
