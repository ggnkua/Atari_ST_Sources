empty		equ	0
rleft		equ	1
rright		equ	2
ruleft		equ	3
ruright		equ	4
key		equ	5
safe		equ	6
diamond		equ	7
rock		equ	8
balloon		equ	9
plunger		equ	10
bomb		equ	11
exit		equ	12
egg		equ	13
trans		equ	14
fred		equ	15
earth		equ	16
weed		equ	17
capsule		equ	18
skull		equ	19
solid1		equ	20
solid2		equ	21
solid3		equ	22
solid4		equ	23
solid5		equ	24
cage		equ	25
spirit1		equ	26
spirit2		equ	27
spirit3		equ	28
cracked		equ	29
monster1	equ	30
monster2	equ	31
monster3	equ	32
lookleft	equ	33
lookright	equ	34
up_down1	equ	35
up_down2	equ	36
up_down3	equ	37
up_down4	equ	38
left1		equ	39
left2		equ	40
left3		equ	41
left4		equ	42
left5		equ	43
left6		equ	44
right1		equ	45
right2		equ	46
right3		equ	47
right4		equ	48
right5		equ	49
right6		equ	50
cursor		equ	51
fred2		equ	52
old_rock	equ	52
cage2		equ	53
colours		equ	$ff8240
acia_con	equ	$fffc00
acia_dat	equ	$fffc02
escape		equ	$1
enter		equ	13
delete		equ	8
return		equ	$1c
z		equ	$2c
x		equ	$2d
quote		equ	$28
slash		equ	$35
space		equ	$39
m		equ	$32
p		equ	$19
d		equ	$20
k		equ	$25
j		equ	$24
l		equ	$26
quit		equ	$10
uarrow		equ	$48
darrow		equ	$50
num_errs	equ	9

		pea	0
		move.w	#$20,-(sp)		; supervisor mode
		trap	#1
		lea	6(sp),sp
		move.l	d0,old_ssp		; save old stack pointer
		lea	end_stack,a7		; point to my stack

* ST or STE ?
		move.b	$ffff820d.w,d0		; low screen reg address
		sub.b	#10,d0			; modify for check
		move.b	d0,$ffff820d.w		; won't program if ST
		cmp.b	$ffff820d.w,d0		; check it
		bne.s	st_machine		; skip if ST
		add.b	#10,d0
		move.b	d0,$ffff820d.w		; restore offset
		move.w	#-1,st_ste		; set STE flag
st_machine
		move.l	#screens+256,d0		; screen start
		and.l	#$ffffff00,d0		; 256 byte boundary
		move.l	d0,scr1			; screen start
		add.l	#38400,d0		; next screen start
		move.l	d0,scr2
			
		move.w	#3,-(sp)		; physbase call
		trap	#14
		lea	2(sp),sp
		move.l	d0,old_scr		; save old screen start
			
		move.w	#4,-(sp)		; get res call
		trap	#14
		lea	2(sp),sp
		move.w	d0,old_res		; save old screen resolution
			
		move.b	#$12,acia_dat		; mouse ints off

		move.w	#0,-(sp)		; low res screen
		move.l	scr2,-(sp)
		move.l	scr2,-(sp)		; screen start address
		move.w	#5,-(sp)		; set res & screen start
		trap	#14
		lea	12(sp),sp
		movem.l	colours,d0-d7
		movem.l	d0-d7,old_pal
		movem.l	d0-d7,color_buff
		jsr	create_fade

		clr.w	wfnc
		jsr	fade_out
		jsr	main

		jsr	fade_out

		move.l	old_scr,d1		; restore old screen
		lsr.l	#8,d1
		move.b	d1,$ff8203		; set screen address
		lsr.w	#8,d1
		move.b	d1,$ff8201		; change screen

		movem.l	old_pal,d0-d5
		movem.l	d0-d5,color_buff
		movem.l	old_pal+24,d0-d1
		movem.l	d0-d1,color_buff+24
		jsr	create_fade
		jsr	fade_in
			
		move.b	#$08,acia_dat		; mouse ints on
			
		movem.l	old_pal,d0-d7
		movem.l	d0-d7,colours

		move.w	old_res,-(sp)		; restore resolution
		move.l	old_scr,-(sp)
		move.l	old_scr,-(sp)		; screen start address
		move.w	#5,-(sp)		; set res & screen start
		trap	#14
		lea	12(sp),sp

		move.l	old_ssp,-(sp)		; back to user mode
		move.w	#$20,-(sp)
		trap	#1
		lea	6(sp),sp

		clr.w	-(sp)
		trap	#1			; end program

main:		
		lea	menu_lu,a3		; main menu look up
		jsr	plot_block
		jsr	vsync_wait
		lea	menu_lu,a3		; main menu look up
		jsr	plot_block			
		jsr	fade_in

demo_loop:	jsr	vsync_wait
		move.l	#$ff0006,-(sp)
		trap	#1
		lea	4(sp),sp
		cmp.b	#'q',d0
		bne.s	demo_loop
		rts

vsync_wait	clr.w	wfnc
		movem.l	scr1,d0-d1		; swap screen starts
		exg	d0,d1
		movem.l	d0-d1,scr1
		lsr.l	#8,d1
		move.b	d1,$ff8203		; set screen address
		lsr.w	#8,d1
		move.b	d1,$ff8201		; change screen

		movem.l	d0-d7/a0-a6,-(sp)
		move.w	#37,-(sp)
		trap	#14
		lea	2(sp),sp
		movem.l	(sp)+,d0-d7/a0-a6
		
		rts

*************************************
*          HSync routine            *
*************************************


hsync		move	#$2700,sr		; interupts off
		movem.l	d0-d1/a2,-(sp)

		lea	$ff8207,a2
		move.b	$ff8203,d0
		add.w	#124,d0
		move.w	#55,d1
.lp1		subq.w	#1,d1
		beq.s	lp_quit
		cmp.b	(a2),d0
		bne.s	.lp1
lp_quit		lea	2(a2),a2

.lp2		tst.b	(a2)
		bne.s	.lp2
		move.b	(a2),d0
		lsr.w	d0,d0

		dcb.w	7,$4e71

		clr.b	$ffff820a.w
		dcb.w	10,$4e71
		move.b	#2,$ffff820a.w
		
		movem.l	(sp)+,d0-d1/a2
		bclr	#0,$fffffa2f.w		; clear int service flag
		bclr	#0,$fffffa27.w		; disable timer b ints
		move.w	#2,wfnc
		rte

			
* print string routine.
* pointer to text supplied in a2, 1st byte is x start,2nd byte is
* y start. String terminated by null byte. No end of line wrap.
* writes to background screen and the hidden screen being updated.

print_text	move.l	scr1,a3			; screen start
		clr.w	d0			; x location
		clr.w	d1			; y location
		move.b	(a2)+,d0
		move.b	(a2)+,d1		; get print co-ords
		and.w	#$fffe,d0		; clear lsb
		lsl.w	#2,d0			; effective * 8
		mulu.w	#1280,d1		; y offset 8*160 per line down
		add.w	d0,d1			; total offset
		add.l	d1,a3			; make screen pointer
		clr.w	d0
		move.b	-2(a2),d0		; x location
		move.l	a2,-(sp)
pt010		move.l	(sp)+,a2
		clr.w	d1			; character buildup
		move.b	(a2)+,d1		; get a character 
		beq.s	pt_end			; exit if no more text
		move.l	a2,-(sp)
		lea	font,a2			; font start
		sub.b	#' ',d1			; normalise it
		lsl.w	#5,d1			; *32 to make character offset
		add.w	d1,a2			; pointer to character
		btst	#0,d0			; get odd/even bit in carry flag
		bne.s	pt020			; skip if in odd position
		jsr	plot_even		; plot the even character
		addq.w	#1,d0			; next x position
		bra.s	pt010			; and loop
pt020		jsr	plot_odd		; plot in odd position
		addq.w	#1,d0			; next x location
		bra.s	pt010			; and loop
pt_end		rts				; return,all done


plot_even	movem.l	(a2)+,d1-d4
		movep.l	d1,(a3)
		movep.l	d2,160(a3)
		movep.l	d3,320(a3)
		movep.l	d4,480(a3)
		movem.l	(a2)+,d1-d4
		movep.l	d1,640(a3)
		movep.l	d2,800(a3)
		movep.l	d3,960(a3)
		movep.l	d4,1120(a3)
		rts				; return, all done

plot_odd	movem.l	(a2)+,d1-d4
		movep.l	d1,1(a3)
		movep.l	d2,161(a3)
		movep.l	d3,321(a3)
		movep.l	d4,481(a3)
		movem.l	(a2)+,d1-d4
		movep.l	d1,641(a3)
		movep.l	d2,801(a3)
		movep.l	d3,961(a3)
		movep.l	d4,1121(a3)
		lea	8(a3),a3
		rts
			
* call with pointer to block look up table in a3.
* 1st long word contains no of lines to be plotted
plot_block	move.l	(a3)+,d5		; number of lines to dbra+1
		subq.w	#1,d5
pb000		move.l	(a3)+,a2		; line pointer
		move.l	a3,-(sp)
		jsr	print_text		; print the line of text
		move.l	(sp)+,a3
		dbra	d5,pb000		; do them all
		rts

create_fade	lea	fade_data,a2		; point to fade data
		lea	fade_data+32,a3		; fade data
		movem.l	color_buff,d0-d5
		movem.l	d0-d5,(a2)		; level 1 data
		movem.l	color_buff+24,d0-d1
		movem.l	d0-d1,24(a2)
		move.w	#14,d5			; 15 levels to fade
cf000		move.w	#15,d4			; 16 colours to fade
cf005		move.w	#2,d3			; red,green & blue levels
		move.w	#$f00,d2
		move.w	#$100,d1		; modify amount
		clr.w	(a3)
cf010		move.w	(a2),d0			; get a colour
		and.w	d2,d0			; make colour level
		tst.w	d0			; level to modify ?
		beq.s	cf020			; skip if not
		sub.w	d1,d0			; modify colour level
cf020		or.w	d0,(a3)			; setup the data
		lsr.w	#4,d2			; move mask to next colour
		lsr.w	#4,d1			; move modify amount
		dbra	d3,cf010		; do all 3 colour levels
		lea	2(a2),a2		; next colour
		lea	2(a3),a3		; next colour in buffer
		dbra	d4,cf005		; do all 16 colours
		dbra	d5,cf000		; do all 7 fade levels
		rts
			
fade_out	lea	fade_data,a2		; point to fade data
		move.w	#15,d5
fo000		move.w	d5,-(sp)
		jsr	vsync_wait
		movem.l	(a2)+,d0-d5		; colour data
		tst.w	st_ste
		bmi	fo010
		lsr.l	d0
		lsr.l	d1
		lsr.l	d2
		lsr.l	d3
		lsr.l	d4
		lsr.l	d5
		and.l	#$07770777,d0
		and.l	#$07770777,d1
		and.l	#$07770777,d2
		and.l	#$07770777,d3
		and.l	#$07770777,d4
		and.l	#$07770777,d5
fo010		movem.l	d0-d5,colours		; install
		swap	d0
		move.w	d0,flash
		movem.l	(a2)+,d0-d1		; colour data
		tst.w	st_ste
		bmi	fo020
		lsr.l	d0
		lsr.l	d1
		and.l	#$07770777,d0
		and.l	#$07770777,d1
fo020		movem.l	d0-d1,colours+24
		move.w	(sp)+,d5
		dbra	d5,fo000
		clr.w	flash
		rts

fade_out2	lea	fade_data,a2		; point to fade data
		move.w	#15,d5
fo0002		move.w	d5,-(sp)
		move.w	#37,-(sp)
		trap	#14
		lea	2(sp),sp
		movem.l	(a2)+,d0-d5		; colour data
		tst.w	st_ste
		bmi	fo0102
		lsr.l	d0
		lsr.l	d1
		lsr.l	d2
		lsr.l	d3
		lsr.l	d4
		lsr.l	d5
		and.l	#$07770777,d0
		and.l	#$07770777,d1
		and.l	#$07770777,d2
		and.l	#$07770777,d3
		and.l	#$07770777,d4
		and.l	#$07770777,d5
fo0102		movem.l	d0-d5,colours		; install
		swap	d0
		move.w	d0,flash
		movem.l	(a2)+,d0-d1		; colour data
		tst.w	st_ste
		bmi	fo0202
		lsr.l	d0
		lsr.l	d1
		and.l	#$07770777,d0
		and.l	#$07770777,d1
fo0202		movem.l	d0-d1,colours+24
		move.w	(sp)+,d5
		dbra	d5,fo0002
		clr.w	flash
		rts
			
fade_in		lea	fade_data+15*32,a2	; bottom of table
		move.w	#15,d5
fi000		move.w	d5,-(sp)
		jsr	vsync_wait
		movem.l	(a2),d0-d5		; colour data
		tst.w	st_ste
		bmi	fi010
		lsr.l	d0
		lsr.l	d1
		lsr.l	d2
		lsr.l	d3
		lsr.l	d4
		lsr.l	d5
		and.l	#$07770777,d0
		and.l	#$07770777,d1
		and.l	#$07770777,d2
		and.l	#$07770777,d3
		and.l	#$07770777,d4
		and.l	#$07770777,d5
fi010		movem.l	d0-d5,colours		; install
		swap	d0
		move.w	d0,flash
		movem.l	24(a2),d0-d1		; colour data
		tst.w	st_ste
		bmi	fi020
		lsr.l	d0
		lsr.l	d1
		and.l	#$07770777,d0
		and.l	#$07770777,d1
fi020		movem.l	d0-d1,colours+24
		lea	-32(a2),a2		; next set of colours
		move.w	(sp)+,d5
		dbra	d5,fi000
		clr.w	flash
		rts

fade_in2	lea	fade_data+15*32,a2	; bottom of table
		move.w	#15,d5
fi0002		move.w	d5,-(sp)
		move.l	a2,-(sp)
		move.w	#37,-(sp)
		trap	#14
		lea	2(sp),sp
		move.l	(sp)+,a2
		movem.l	(a2),d0-d5		; colour data
		tst.w	st_ste
		bmi	fi0102
		lsr.l	d0
		lsr.l	d1
		lsr.l	d2
		lsr.l	d3
		lsr.l	d4
		lsr.l	d5
		and.l	#$07770777,d0
		and.l	#$07770777,d1
		and.l	#$07770777,d2
		and.l	#$07770777,d3
		and.l	#$07770777,d4
		and.l	#$07770777,d5
fi0102		movem.l	d0-d5,colours		; install
		swap	d0
		move.w	d0,flash
		movem.l	24(a2),d0-d1		; colour data
		tst.w	st_ste
		bmi	fi0202
		lsr.l	d0
		lsr.l	d1
		and.l	#$07770777,d0
		and.l	#$07770777,d1
fi0202		movem.l	d0-d1,colours+24
		lea	-32(a2),a2		; next set of colours
		move.w	(sp)+,d5
		dbra	d5,fi0002
		clr.w	flash
		rts

**************************************************************************
i1		dc.b	0,00,'eiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiif',0
i2		dc.b	0,01,'j                st                    j',0
i3		dc.b	0,02,'j swt swt swt wwt v swt  swt x swt wwt j',0
i4		dc.b	0,03,'j x   x v x   z z   x    x   x x z z z j',0
i5		dc.b	0,04,'j xww xw  xww z z   uwt  xww x x z z z j',0
i6		dc.b	0,05,'j x   x t x   z z     z  x   x x z z z j',0
i7		dc.b	0,06,'j x   x z uyv yyv   uyv  x   x x z yyv j',0
i8		dc.b	0,07,'j                                      j',0
i9		dc.b	0,08,'j                                      j',0
ia		dc.b	0,09,'j                                      j',0
ib		dc.b	0,10,'j                                      j',0
ic		dc.b	0,11,'j                                      j',0
id		dc.b	0,12,'j                                      j',0
ie		dc.b	0,13,'j                                      j',0
if		dc.b	0,14,'j                                      j',0
ig		dc.b	0,15,'j                                      j',0
ih		dc.b	0,16,'kiiiiiiiiniiiiiiiiiiiiniiiiiiiiiiiiiiiil',0
ii		dc.b	0,17,'j  MAP   j  PASSWORD  j  EDITOR  CODE  j',0
ij		dc.b	0,18,'kiiiiiiiioiiiiiiiiiiiioiiiiiiiiiiiiiiiil',0
ik		dc.b	0,19,'j   A    j  --------  j     -----      j',0
il		dc.b	0,20,'j   B    j  --------  j     -----      j',0
im		dc.b	0,21,'j   C    j  --------  j     -----      j',0
in		dc.b	0,22,'j   D    j  --------  j     -----      j',0
io		dc.b	0,23,'j   E    j  --------  j     -----      j',0
ip		dc.b	0,24,'j   F    j  --------  j     -----      j',0
iq		dc.b	0,25,'j   G    j  --------  j     -----      j',0
ir		dc.b	0,26,'j   H    j  --------  j     -----      j',0
is		dc.b	0,27,'giiiiiiiimiiiiiiiiiiiimiiiiiiiiiiiiiiiih',0
menu_lu		dc.l	28,i1,i2,i3,i4,i5,i6,i7,i8,i9,ia,ib,ic,id,ie
		dc.l	if,ig,ih,ii,ij,ik,il,im,in,io,ip,iq,ir,is
mouse_rout	dc.l	0
old_mouse	dc.l	0
mouse_x		dc.w	100
mouse_y		dc.w	100
m_buttons	dc.b	0
x_max		dc.w	312
x_min		dc.w	2
y_max		dc.w	191
y_min		dc.w	2
font		incbin	font.bin
icons		incbin	icons.bin
char_cols	incbin	fredfind.chr
chars		equ	char_cols+32
		section	bss
conv_flag	ds.w	1
off_chars	ds.w	256*45					; character offset
old_hsync	ds.l	1
mbuffer		ds.w	8*8
mfpa27:		ds.b	1		*vars for interrupt saving
mfpa29:		ds.b	1
mfpa33:		ds.b	1
mfpa35:		ds.b	1
mfpa39:		ds.b	1
mfpa3f:		ds.b	1
old134:		ds.l	1
oldvbl:		ds.l	1
oldhbl		ds.l	1
old_ssp		ds.l	1
old_scr		ds.l	1
old_res		ds.w	1
oldkey		ds.l	1
scr1		ds.l	1
scr2		ds.l	1
wfnc		ds.w	1
flash		ds.w	1
st_ste		ds.w	1
old_pal		ds.w	16
color_buff	ds.w	16
fade_data	ds.w	16*16
screens		ds.b	84480
my_stack	ds.b	6000
end_stack