***************************************************************************
* THE LEMMINGS¿ Menu 4 Source                                             *
***************************************************************************

number_of_programs	equ	4
trans			macro	
			movep.l	\1(a0),d0
			movep.l	d0,\1-7(a0)
			movep.l	\1+1(a0),d0
			movep.l	d0,\1(a0)
			endm
trans1			macro	
			movep.l	\1(a1),d0
			movep.l	d0,\1-7(a1)
			movep.l	\1+1(a1),d0
			movep.l	d0,\1(a1)
			endm
start			move.l	4(sp),a5
			move.l	12(a5),d0
			addi.l	#$100,d0
			move.l	d0,-(sp)
			move.l	a5,-(sp)
			move.w	#0,-(sp)
			move.w	#$4a,-(sp)
			trap	#1
			lea.l	12(sp),sp
			clr.l 	-(sp)
			move.w	#32,-(sp)
			trap	#1
			lea.l	6(sp),sp
			move.l	d0,old_stack_pointer
			lea.l	program_stack,a7
			move.l	$44e.w,old_screen_address
			move.b	$ffff8260.w,old_screen_resolution
			move.b	$ffff820a.w,old_hertz_rate
			movem.l	$ffff8240.w,d0-d7	
			movem.l	d0-d7,old_palette
			cmp.l	#$e00000,$4.w
			bge.s	not_ste			
			move.w	#1,ste_flag
not_ste			move.w	#$777,$ffff8240.w
			moveq.w	#6,d1
fadeout			rept	3
			move.w	#37,-(sp)
			trap	#14
			addq.l	#2,sp
			endr	
			sub.w	#$111,$ffff8240.w
			dbf	d1,fadeout
			lea.l	$ffff8240.w,a0
			clr.l	(a0)+
			clr.l	(a0)+
			clr.l	(a0)+
			clr.l	(a0)+
			clr.l	(a0)+
			clr.l	(a0)+
			clr.l	(a0)+
			clr.l	(a0)+
			lea.l	font,a0
			move.w	4(a0),font_height
			move.w	4+2(a0),font_width
			movem.l	4+2+2+2(a0),d0-d7
			movem.l	d0-d7,font_palette
			moveq.w	#1,d0			
			jsr	music
			moveq.w	#$12,d1			
			bsr	send_to_keyboard		
			move.b	#0,$ffff8260.w
			move.l	screen,a0
			bsr	clear_screen
			move.l	screen,a0
			adda.l	#32000,a0
			bsr	clear_screen
			lea.l	picture+34,a0
			move.l	screen,a1
			move.w	#7999,d7
.drawscreen		move.l	(a0)+,(a1)+
			dbf	d7,.drawscreen
			movem.l	picture+2,d0-d7
			movem.l	d0-d7,$ffff8240.w
			move.l	screen,d1
			bsr	set_screen_address
			bsr	interrupts_on
wait_loop		bsr	vblank_sync
			bsr	flashlineB
			bsr	volume_meter
			bsr	flashline
			bsr	scroll
.check1			cmp.b	#"1",keyboard_buffer
			bne.s	.check2
			bra	finish
.check2			cmp.b	#"2",keyboard_buffer
			bne.s	.check3
			move.w	#1,program_to_load
			bra	loader
.check3			cmp.b	#"3",keyboard_buffer
			bne.s	.check4
			move.w	#2,program_to_load
			bra	loader
.check4			cmp.b	#"4",keyboard_buffer
			bne.s	.check5
			move.w	#3,program_to_load
			bra	loader
.check5			cmp.b	#"5",keyboard_buffer
			bne.s	.check_space
			move.w	#4,program_to_load
			bra	loader
.check_space		bne	wait_loop
finish			move.l	old_screen_address,d1
			bsr	set_screen_address
			moveq.w	#8,d1	
			bsr	send_to_keyboard
			bsr	interrupts_off
			move.l	#$8080000,$ffff8800.w
			move.l	#$9090000,$ffff8800.w
			move.l	#$a0a0000,$ffff8800.w
			move.w	#-1,$4ee.w
			movem.l	old_palette,d0-d7
			movem.l	d0-d7,$ffff8240.w
			move.b	old_hertz_rate,$ffff820a.w
			move.b	old_screen_resolution,$ffff8260.w
			move.l	old_stack_pointer,-(sp)
			move.w	#32,-(sp)
			trap	#1
			lea.l	6(sp),sp
			clr.w	-(sp)
			trap	#1
loader			move.w	program_to_load,d0
			cmp.b	#number_of_programs,d0
			ble.s	.continue_load
			bra	wait_loop
.continue_load		move.l	old_screen_address,d1
			bsr	set_screen_address
			moveq.w	#8,d1		
			bsr	send_to_keyboard
			bsr	interrupts_off
			move.l	#$8080000,$ffff8800.w
			move.l	#$9090000,$ffff8800.w
			move.l	#$a0a0000,$ffff8800.w
			move.w	#-1,$4ee.w	
			movem.l	old_palette,d0-d7
			movem.l	d0-d7,$ffff8240.w
			move.b	old_screen_resolution,$ffff8260.w
			move.b	old_hertz_rate,$ffff820a.w
			move.l	old_stack_pointer,-(sp)
			move.w	#32,-(sp)
			trap	#1
			lea.l	6(sp),sp
			move.w	program_to_load,d0
			moveq.w	#0,d1
			move.w	d0,d1
			subq.w	#1,d1
			lsl.w	#2,d1
			lea.l	filenames(pc),a0
			adda.l	d1,a0
			move.l	(a0),a6
			pea	env_com(pc)
			pea	env_com(pc)
			move.l	a6,-(sp)
			move.w	#0,-(sp)	
			move.w	#$4b,-(sp)
			trap	#1
			lea	16(sp),sp
			clr.w	-(sp)
			trap	#1
env_com			dc.b	0
			even
file1			dc.b	'a:\2.gem',0		The Filenames	
file2   		dc.b    'a:\4.gem',0		8 chars,"."
file3			dc.b	'a:\5.gem',0		then the
file4   		dc.b    'a:\6.gem',0		extension.
file5			dc.b	'a:\genstd.prg',0	End in ",0"
file6   		dc.b    'a:\genstd.prg',0
file7			dc.b	'a:\genstd.prg',0	
file8   		dc.b    'a:\genstd.prg',0
file9			dc.b	'a:\genstd.prg',0
        		even
filenames		dc.l	file1,file2,file3,file4,file5
			dc.l	file6,file7,file8,file9
 			even
		
interrupts_on		move.w	#$2700,sr
			move.b	$fffffa09.w,old_enable_timerb
			move.b	$fffffa07.w,old_enable_timera
			move.b	$fffffa13.w,old_mask_timera
			clr.b	$fffffa07.w
			clr.b	$fffffa09.w
			move.l	$118.w,old_keyboard_vector
			move.l	$120.w,old_hor_blank_vector
			move.l	$70.w,old_ver_blank_vector
			move.l	$68.w,old_level2_interrupt
			move.l	$134.w,old_timer_a_vector
			move.b	$484.w,old_keyclick
			clr.b	$484.w
			move.l	#key_handler,$118.w
			move.l	#hbl_palette,$120.w
			move.l	#vbl_handler,$70.w
			move.l	#handler_68,$68.w
			move.l	#timer_a,$134.w
			bset	#0,$fffffa07.w			
			bset	#0,$fffffa13.w
			bset	#5,$fffffa07.w			
			bset	#5,$fffffa13.w
			bset	#6,$fffffa09.w			
			bset	#6,$fffffa15.w
			move.w	#$2300,sr
			rts
			
interrupts_off		move.w	#$2700,sr
			move.b	old_enable_timerb,$fffffa09.w
			move.b	old_enable_timera,$fffffa07.w
			move.b	old_mask_timera,$fffffa13.w
  			move.l	old_keyboard_vector,$118.w
			move.l	old_hor_blank_vector,$120.w
			move.l	old_ver_blank_vector,$70.w
			move.l	old_level2_interrupt,$68.w
			move.l	old_timer_a_vector,$134.w
			move.b	old_keyclick,$484.w
			move.w	#$2300,sr
			rts

handler_68		nop
			rte
send_to_keyboard	lea.l	$fffffc00.w,a0
.wait			move.b	(a0),d2
			btst	#1,d2
			beq.s	.wait
			move.b	d1,2(a0)
			rts

flip_screen		eor.w	#1,switch
			bne.s	.flip_screen1
			move.l	screen1,d1		
			move.l	screen,screen		
			bra.s	set_screen_address
.flip_screen1		move.l	screen,d1
			move.l	screen1,screen
set_screen_address	lsr.l	#8,d1	
			move.b	d1,$ffff8203.w
			lsr.l	#8,d1
			move.b	d1,$ffff8201.w
			rts
		
vblank_sync		move.w	frame_count,d0
.vlop			cmp.w	frame_count,d0
			beq.s	.vlop
			rts
		
clear_screen		move.w	#7999,d0
			clr.l	d7
.cls			move.l	d7,(a0)+
			dbf	d0,.cls
			rts
		
key_handler		move.w	#$2500,sr
			movem.l	d0-d7/a0-a6,-(sp)
			clr.w	keyboard_buffer
			lea.l	$fffffc00.w,a1
			move.b	(a1),d2
			btst	#7,d2
			beq	.exit
			btst	#0,d2
			beq	.clear
			movem.l	d2/a0-a2,-(a7)
			bsr	.getbyte
			movem.l	(a7)+,d2/a0-a2
.clear			and.b	#32,d2
			beq	.exit
			move.b	2(a1),d0
.exit			movem.l	(sp)+,d0-d7/a0-a6
			bclr	#6,$fffffa11.w
			btst	#4,$fffffa01.w
			beq.s	key_handler
			move.w	#$2300,sr
			rte
		
.getbyte		move.b	2(a1),d0
			btst	#7,d0
			bne.s	.db
			cmp.w	#1,debounce
			beq.s	.pass
			lea.l	keycodes,a0
			ext.w	d0
			move.b	(a0,d0.w),keyboard_buffer
			move.w	#1,debounce
.pass			rts
.db			clr.w	debounce
			rts

hbl_palette		clr.b	$fffffa1b.w
			movem.l	a0/d0,-(sp)
			lea.l	$fffffa21.w,a0
			move.b	#200,(a0)
			move.b	#8,$fffffa1b.w
			move.b	(a0),d0
.wait_scanline		cmp.b	(a0),d0		
			beq.s	.wait_scanline		
			move.l	text_palette,$ffff8240.w
			move.l	text_palette+4,$ffff8244.w
			move.l	text_palette+8,$ffff8248.w
			move.l	text_palette+12,$ffff824c.w
			move.l	text_palette+16,$ffff8250.w
			move.l	text_palette+20,$ffff8254.w
			move.l	text_palette+24,$ffff8258.w
			move.l	text_palette+28,$ffff825c.w
			movem.l	(sp)+,a0/d0
			bclr	#0,$fffffa0f.w
			clr.b	$fffffa1b.w
			move.b	#28,$fffffa21.w
			move.l	#hbl_handler,$120.w
			move.b	#8,$fffffa1b.w
			rte

hbl_handler		clr.b	$fffffa1b.w
			movem.l	a0/d0,-(sp)
			lea.l	$fffffa21.w,a0
			move.b	#229,(a0)
			move.b	#8,$fffffa1b.w
			move.b	(a0),d0
			move.l	font_palette,$ffff8240.w
			move.l	font_palette+4,$ffff8244.w
			move.l	font_palette+8,$ffff8248.w
			move.l	font_palette+12,$ffff824c.w
			move.l	font_palette+16,$ffff8250.w
			move.l	font_palette+20,$ffff8254.w
			move.l	font_palette+24,$ffff8258.w
			move.l	font_palette+28,$ffff825c.w
.wait_scanline		cmp.b	(a0),d0		
			beq.s	.wait_scanline		
			clr.b	$ffff820a.w     
                	moveq.w	#3,d0
.remove_border		nop
			dbf	d0,.remove_border
                	move.b  #2,$ffff820a.w 
			movem.l	(sp)+,a0/d0
			bclr	#0,$fffffa0f.w
			clr.b	$fffffa1b.w
			rte

vbl_handler		clr.b	$fffffa19.w
			move.b	#99,$fffffa1f.w		
			move.b	#4,$fffffa19.w
			addq.w	#1,frame_count
			move.l	picture+2,$ffff8240.w
			move.l	picture+2+4,$ffff8244.w
			move.l	picture+2+8,$ffff8248.w
			move.l	picture+2+12,$ffff824c.w
			move.l	picture+2+16,$ffff8250.w
			move.l	picture+2+20,$ffff8254.w
			move.l	picture+2+24,$ffff8258.w
			move.l	picture+2+28,$ffff825c.w
			movem.l	d0-d7/a0-a6,-(sp)
			jsr	music+8
			movem.l	(sp)+,d0-d7/a0-a6
			rte	
	
timer_a			clr.b	$fffffa19.w
			clr.b	$fffffa1b.w		
			move.b	#199,$fffffa21.w
			move.l	#hbl_palette,$120.w
			move.b	#8,$fffffa1b.w
			stop	#$2100
			stop	#$2100
			move.w	#$2700,sr
			dcb.w	86,$4e71
			move.b	#0,$ffff820a.w
			dcb.w	18,$4e71
			move.b	#2,$ffff820a.w
			move.w	#$2300,sr
			bclr	#5,$fffffa0f.w
			rte

scroll			bsr	do_scroll
			addq.b	#1,scroll_counter
			cmp.b	#4,scroll_counter
			beq.s	nextlet
			rts
nextlet			clr.b	scroll_counter
			move.l	scrollptr,a0
			move.b	(a0)+,d0
			cmp.b	#255,d0
			beq	wrap
			move.l	a0,scrollptr
			sub.b	#32,d0
			move.w	font_width,d1
			addq.w	#1,d1
			mulu	d1,d0
			move.w	font_height,d1
			addq.w	#1,d1
			mulu	d1,d0
			lea.l	font,a0
			adda.l	#42,a0
			adda.l	d0,a0
			lea.l	scrollbuffer,a1
			move.w	font_height,d0
prepare			move.w	(a0),(a1)
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
		
do_scroll		lea.l	scrollbuffer,a1
			move.l	screen,a0
			adda.l	#160*230,a0
			move.w	font_height,d1
scrolline		movep.l	1(a0),d0
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

wrap			move.b	#32,d0
			lea.l	scrolltext,a0
			move.l	a0,scrollptr
			rts	

volume_meter		lea.l	$ffff8800.w,a0
			moveq.w	#2,d5
.chans			moveq.w	#8,d4
			add.w	d5,d4
			move.b	d4,(a0)
			move.b	(a0),d4
			andi.b	#15,d4
			moveq.w	#0,d7
			move.l	screen,a1
			adda.l	#210*160+2,a1
			adda.l	#16,a1
			move.l	d5,d6
			mulu	#(3*160),d6
			add.w	d5,d6
			add.w	d5,d6
			adda.w	d6,a1
			move.b	d4,d7
.plot			move.w	#%1111111111111111,(0*160)(a1)
			move.w	#%1111111111111111,(1*160)(a1)
			move.w	#%1111111111111111,(2*160)(a1)
			addq.l	#8,a1
			dbf	d7,.plot
			moveq	#15,d7
			sub.b	d4,d7
.unplot			clr.w	(0*160)(a1)
			clr.w	(1*160)(a1)
			clr.w	(2*160)(a1)
			addq.l	#8,a1
			dbf	d7,.unplot
			dbf	d5,.chans
			rts
*********************************************************
flashline		subq.w	#1,pause		*was 1
			tst.w	pause
			bpl	exit_flashline
			move.w	#0,d3
			move.l	screen,a0
			move.l	#220*160,d4
			adda.l	d4,a0
			move.l	a0,a5
			lea	x_table,a3	
			move.l	flashline_ptr,a2
			lsl	d3		
			add.w	d3,a3		
nextletter		move.w	(a3)+,d3
			move.l	a5,a0
			adda.w	d3,a0		
			moveq.w	#0,d1
			move.b	(a2)+,d1
			cmp.b	#255,d1
			beq.s	.wraptext
			cmp.b	#"@",d1
			beq.s	.endline
			sub.w	#32,d1
			lsl.w	#3,d1
			lea	smallfont,a1
			adda.l	d1,a1
num			set	0
			rept	8
			move.b	(a1)+,num(a0)
num			set	num+160
			endr
			bra.s	nextletter
.endline		move.b	(a2)+,d7
			ext.w	d7
			move.w	d7,pause
			move.l	a2,flashline_ptr
			bra.s	exit_flashline
.wraptext		lea	flashline_text,a0
			move.l	a0,flashline_ptr
			move.b	(a2)+,d7
			ext.w	d7
			move.w	d7,pause
exit_flashline		rts
*************************************************************
flashlineB		subq.w	#1,pause	
			tst.w	pause
			bpl	exit_flashlineB
			move.w	#0,d3
			move.l	screen,a0
			move.l	#201*160,d4		* 220*160
			adda.l	d4,a0
			move.l	a0,a5
			lea	x_table,a3	
			move.l	flashline_ptrB,a2
			lsl	d3		
			add.w	d3,a3		
nextletterB		move.w	(a3)+,d3
			move.l	a5,a0
			adda.w	d3,a0		
			moveq.w	#0,d1
			move.b	(a2)+,d1
			cmp.b	#255,d1
			beq.s	.wraptextB
			cmp.b	#"@",d1
			beq.s	.endlineB
			sub.w	#32,d1
			lsl.w	#3,d1
			lea	smallfont,a1
			adda.l	d1,a1
num			set	0
			rept	8
			move.b	(a1)+,num(a0)
num			set	num+160
			endr
			bra.s	nextletterB
.endlineB		move.b	(a2)+,d7
			ext.w	d7
			move.w	d7,pause
			move.l	a2,flashline_ptrB
			bra.s	exit_flashlineB
.wraptextB		lea	flashline_textB,a0	* change to 2
			move.l	a0,flashline_ptrB
			move.b	(a2)+,d7
			ext.w	d7
			move.w	d7,pause
exit_flashlineB		rts
*************************************************************
			section data
x_table		
num			set	0
			rept	20
			dc.w	num
			dc.w	num+1
num			set	num+8
			endr
pause			dc.w	10
			dc.w	0
			even
			
old_ver_blank_vector	dc.l	0
old_keyboard_vector	dc.l	0
old_hor_blank_vector	dc.l	0
old_enable_timerb	dc.b	0
old_enable_timera	dc.b	0
old_mask_timera		dc.b	0
old_screen_resolution	dc.b	0
old_stack_pointer	dc.l	0
screen			dc.l	$70000
screen1			dc.l	$70000
keyboard_buffer		dc.w	0
debounce		dc.w	0
direction		dc.w	0
ste_flag		dc.w	0	
cartridge_flag		dc.w	0
scroll_counter		dc.b	3
			even
			even
*Palette*******************************************************************
text_palette		dc.w	$000
			dc.w	$666	Flashline/Text colour
			dc.w	$060	Equalizer 1 colour
			dc.w	$000
			dc.w	$040	Equalizer 2 colour
			dc.w	$000,$000,$000
			dc.w	$020	Equalizer 3 Colour
			dc.w	$000,$000,$000,$000,$000,$000,$000
keycodes		dc.b	0,0,"1","2","3","4","5","6"
			dc.b	"7","8","9","0","-","=",$ff,0
			dc.b	"Q","W","E","R","T","Y","U","I"
			dc.b	"O","P","[","]",13,0,"A","S"
			dc.b	"D","F","G","H","J","K","L",":"
			dc.b	"'","`",0,"#","Z","X","C","V"
			dc.b	"B","N","M",",",".","/",0,0
			dc.b	0," ",0,0,0,0,0,0
			dc.b	0,0,0,0,0,0,0,0
			dc.b	0,0,"-",0,0,0,"+",0
			dc.b	0,0,0,$ff,0,0,0,0
			dc.b	0,0,0,0,0,0,0,0
			dc.b	"<",0,0,"(",")","/","*","7"
			dc.b	"8","9","4","5","6","1","2","3"
			dc.b	"0",".",13,0,0,0,0,0
			dc.b	0,0,0,0,0,0,0,0
*Main Scroller*************************************************************
* Scrolltext for the 16 colour scroller.End with 255			  *
***************************************************************************
scrolltext
	DC.B	"                    THEY'RE LEAN........"
	DC.B	"                    THEY'RE MEAN........"
	DC.B	"                    AND THEY'RE SUICIDAL !!!!!!!!"
	DC.B	"                    THE LEMMINGS ARE BACK AFTER THE"
	DC.B	" MASSIVE WAIT WITH ANOTHER MENU. WE'RE BACK ON THE RIGHT"
	DC.B	" ROAD WITH SEVERAL RELEASES LINED UP FOR THE NEXT FEW"
	DC.B	" WEEKS. WATCH OUT FOR TITUS THE FOX AMONGST OTHERS."
	DC.B	" WE ARE SORRY ABOUT THE DELAY BUT WE HAD SOME PROBLEMS"
	DC.B	" CODING MENU 3. IT'S FINISHED NOW THOUGH AND WE'RE READY"
	DC.B	" TO BRING YOU THE STUFF WE WANTED TO BEFORE."
	DC.B	" ONE THING YOU WILL HAVE NOTICED ABOUT THIS MENU IS THE"
	DC.B	" NEW SOURCE WE'RE USING. IT'S CODED BY AN OLD FRIEND OF"
	DC.B	" MINE WHO IS AT THE MOMENT WORKING ON A MEGA-DEMO. IT"
	DC.B	" SHOULD BE EXCELLENT. WE MAY USE THIS CODE QUITE A BIT"
	DC.B	" WITH IT BEING SO GOOD BUT WE NEED MORE SOUNDCHIP MUSIC"
	DC.B	" TO USE IT EFFECTIVELY. THERE IS QUITE A LARGE BACKLOG OF"
	DC.B	" MUSIC BUT YOU'VE HEARD IT ALL BEFORE. WE ARE CURRENTLY"
	DC.B	" LOOKING FOR NEW MAD MAX MUSIC AND BIG ALEC MUSIC. OF"
	DC.B	" COURSE A MUSICIAN WOULD BE A LOT MORE HELPFUL, BUT EVEN"
	DC.B	" THEN MUSICIANS PREFER TO COMPOSE USING SOUNDTRACKERS"
	DC.B	" THESE DAYS. IF YOU ARE A GOOD MUSICIAN, WE WOULD LIKE TO"
	DC.B	" HEAR FROM YOU SO TRY AND GET HOLD OF OUR ADDRESS FROM"
	DC.B	" SOMEWHERE.          WHAT DOES EVERYONE THINK TO THE"
	DC.B	" TORIES GETTING INTO POWER AGAIN?     THE DAMNED"
	DC.B	" POLITICIANS WILL NEVER DO ANYTHING RIGHT FOR US. WE WANT"
	DC.B	" INVESTMENT NOT PRIVATISATION. WE COULD ALSO DO WITH MORE"
	DC.B	" ATTENTION PAYING TO THE COMPUTER INDUSTRY. THE ST IS"
	DC.B	" FAST BECOMING A DERELICT COMPUTER. AT THE MOMENT, THE"
	DC.B	" ONLY PEOPLE WHO CAN SAVE IT ARE ATARI WITH THEIR NEW ST"
	DC.B	" OR THE DEMO CREATORS (WHY DON'T THEY WRITE MORE GAMES?)."
	DC.B	" ANYWAY, TIME TO WRAP.........            "
 	DC.B	255
	EVEN
scrollptr
	dc.l	scrolltext
*Flashline 1***************************************************************
* Must be 40 Chars across. End line with '@'				  *
* Delay in 50ths of a second. Put 255 instead of '@' for wrap		  *
*		 0123456789012345678901234567890123456789		  *
***************************************************************************
flashline_text
	dc.b	" Hello out there and welcome to Menu 4. ","@",100
	dc.b	"                                        ","@",100
	dc.b	" After the long delay of menu 3, we are ","@",100
	dc.b	"now back on the right road to fast menus","@",100
	dc.b	"so, watch out for some nice stuff coming","@",100
	dc.b	"soon, like Titus The Fox and Shadowlands","@",100
	dc.b	"                                        ","@",100
	dc.b	"  The current LEMMINGS members list is: ","@",100
	dc.b	"                                        ","@",100
	dc.b	"    INFO FREAKO:Coding and Compiling    ","@",100
	dc.b	"   DARK SORCERER:Coding and Compiling   ","@",100
	dc.b	"  CAPTAIN CLUCK:Supplying and Spreading ","@",100
	DC.B	" WARMGLOW VINDALOO:Supplying and Coding ","@",100
 	DC.B	"                                        ","@",100
	DC.B	"We are expecting a couple of new members","@",100
        DC.B	"soon, one a nice coder and maybe even a ","@",100
	DC.B	"        proper artist. Who knows?       ","@",100
	DC.B	"                                        ","@",100
	DC.B	"    Greetings on this menu go out to:   ","@",100
	DC.B	"                                        ","@",100
	DC.B	"         WILD! (Especially Snaz)        ","@",100
	DC.B	"      ADRENALIN (Especially T.M.B.)     ","@",100
	DC.B	"   PURE ENERGY (Especially The Mutant)  ","@",100
	DC.B	"    SYNCRO SYSTEMS (Especially Stick)   ","@",100
	DC.B	"       I.C.S. (Especially Illegal)      ","@",100
	DC.B	"      QUARTEX (Especially D Coder)      ","@",100
	DC.B	"      CYNIX (Especially Skywalker)      ","@",100
	DC.B	"        SUPERIOR (Especially Axe)       ","@",100
	DC.B	"         ELITE (Especially Lotus)       ","@",100
	DC.B	" POMPEY PIRATES (If you're still around)","@",100
	DC.B	"    INSANITY (Especially The Outcast)   ","@",100
	DC.B	"         FUZION (Nice compacts!)        ","@",100
	DC.B	"    DELTA FORCE (Especially Big Alec)   ","@",100
	DC.B	"     THE LOST BOYS (Especially Spaz)    ","@",100
	DC.B	"    THE CAREBEARS (Especially Tanis)    ","@",100
	DC.B	"    THE CLOCKWORK ORANGE (Nice menus)   ","@",100
	DC.B	" GENESIS INC. (I agree about Roofless!) ","@",100
	DC.B	"          FACTORY (Nice cracks)         ","@",100
	DC.B	"               REPLICANTS               ","@",100
	DC.B	"                                        ","@",100
	DC.B	"                                        ",255,100
	even
flashline_ptr
	dc.l	flashline_text			
*Flashline 2***************************************************************
flashline_textB
	dc.b	"    Please press the following keys:    ","@",100
	dc.b	"                                        ","@",100
	dc.b	"  1:Gem 'X - Cracked + Trained by ICS   ","@",100
	dc.b	"      Filed + Docs by Info Freako       ","@",100	
	dc.b	"       Supplied by Captain Cluck        ","@",100
	dc.b	"                                        ","@",100
	dc.b	"   2:Annihilator - Supplied by T.M.B.   ","@",100
	dc.b	"                                        ","@",100
	dc.b	"3:Offbeat Duplicator - Supplied by Stick","@",100
	dc.b	"                                        ","@",100
	dc.b	"  4:Menu 3 Docs - Typed by Info Freako  ","@",100
	dc.b	"                                        ","@",100
	dc.b	"  5:Menu 4 Docs - Typed by Info Freako  ","@",100
	dc.b	"                                        ","@",100
	dc.b	"   This menu was coded by Neuromancer   ","@",100
	dc.b	" It was compiled 21.4.92 by Info Freako ","@",100
	dc.b	"                                        ",255,100
flashline_ptrB
	dc.l	flashline_textB
*Picture*******************************************************************
picture
	incbin	menu4.pi1
	even
*Music*********************************************************************
*      Count Zero - 6      *      Mad Max/Lap - 8      *      SMF - 4     *
***************************************************************************
music
	incbin	menu4.mus
	even
*Font**********************************************************************
font
	incbin	axxis.f32
	even
*Smallfont*****************************************************************
smallfont
	incbin	smallfnt.fnt
	even
***************************************************************************
			section	bss
			
frame_count		ds.w	1
program_to_load		ds.w	1
old_timer_a_vector	ds.l	1
old_level2_interrupt	ds.l	1
old_screen_address	ds.l	1
old_palette		ds.l	16
old_hertz_rate		ds.w	1
old_keyclick		ds.b	1
switch			ds.w	1
font_height		ds.w	1
font_width		ds.w	1
font_palette		ds.w	16
tex_buffer		ds.w	7*40
scrollbuffer		ds.w	8*32
			ds.l	100
program_stack		ds.l	1