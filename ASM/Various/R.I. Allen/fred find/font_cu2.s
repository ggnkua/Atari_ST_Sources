colours		equ		$ff8240

* program macros
set_res		macro
			move.w	#0,-(sp)
			move.l	#$78000,-(sp)
			move.l	#$78000,-(sp)
			move.w	#5,-(sp)
			trap	#14
			lea		12(sp),sp
			endm


			;set_res
			;pea		my_pallette
			;move.w	#6,-(sp)
			;trap	#14
			;lea		6(sp),sp

			move.w	#3,-(sp)
			trap	#14
			lea		2(sp),sp
			move.l	d0,scr1

			jsr		cut_graphics
			jsr		save_icons
			jsr		save_font
			jsr		save_mouse

			lea		string1,a6
			jsr		print_text
			lea		string2,a6
			jsr		print_text
			lea		string3,a6
			jsr		print_text
			lea		string4,a6
			jsr		print_text
			lea		string5,a6
			jsr		print_text
wait		move.w	#$ff,-(sp)
			move.w	#6,-(sp)
			trap	#1
			lea		4(sp),sp
			tst.w	d0
			beq.s	wait
			
			clr.w	-(sp)
			trap	#1
			
save_icons	
			clr.w	-(sp)			; read/write ststuts
			pea		icon_name		; filname
			move.w	#$3c,-(sp)		; create call
			trap	#1
			lea		8(sp),sp
			move.w	d0,handle
			
			pea		icons
			move.l	#1738,-(sp)
			move.w	handle,-(sp)
			move.w	#$40,-(sp)
			trap	#1
			lea		12(sp),sp
			
			move.w	handle,-(sp)
			move.w	#$3e,-(sp)
			trap	#1
			lea		4(sp),sp
			rts
save_mouse	
			clr.w	-(sp)			; read/write ststuts
			pea		mouse_name		; filname
			move.w	#$3c,-(sp)		; create call
			trap	#1
			lea		8(sp),sp
			move.w	d0,handle
			
			pea		mouse_ch
			move.l	#512,-(sp)
			move.w	handle,-(sp)
			move.w	#$40,-(sp)
			trap	#1
			lea		12(sp),sp
			
			move.w	handle,-(sp)
			move.w	#$3e,-(sp)
			trap	#1
			lea		4(sp),sp
rts

save_font	clr.w	-(sp)			; read/write ststuts
			pea		font_name		; filname
			move.w	#$3c,-(sp)		; create call
			trap	#1
			lea		8(sp),sp
			move.w	d0,handle
			
			pea		characters
			move.l	#3200,-(sp)
			move.w	handle,-(sp)
			move.w	#$40,-(sp)
			trap	#1
			lea		12(sp),sp
			
			move.w	handle,-(sp)
			move.w	#$3e,-(sp)
			trap	#1
			lea		4(sp),sp
			rts

			
cut_graphics
			lea		graphics+128,a0	; screen start
			lea		icons,a1		; data area
			move.w	#19,d7			; 40 to cut (38/2 -1)
cg000		move.w	#7,d4			; 8 lines of chars
cg010		move.b	(a0),(a1)
			move.b	2(a0),1(a1)
			move.b	4(a0),2(a1)
			move.b	6(a0),3(a1)
			move.b	1(a0),32(a1)
			move.b	3(a0),33(a1)
			move.b	5(a0),34(a1)
			move.b	7(a0),35(a1)
			lea		160(a0),a0
			lea		4(a1),a1
			dbra	d4,cg010
			lea		-1272(a0),a0	; point to next pair
			lea		32(a1),a1		; next data area
			dbra	d7,cg000		; do all 28

* second line
			lea		graphics+1408,a0	; screen start
			move.w	#19,d7			; 40 to cut (38/2 -1)
cg0002		move.w	#7,d4			; 8 lines of chars
cg0102		move.b	(a0),(a1)
			move.b	2(a0),1(a1)
			move.b	4(a0),2(a1)
			move.b	6(a0),3(a1)
			move.b	1(a0),32(a1)
			move.b	3(a0),33(a1)
			move.b	5(a0),34(a1)
			move.b	7(a0),35(a1)
			lea		160(a0),a0
			lea		4(a1),a1
			dbra	d4,cg0102
			lea		-1272(a0),a0	; point to next pair
			lea		32(a1),a1		; next data area
			dbra	d7,cg0002		; do all 28

* now cut out the 8 * 8 font

			lea		graphics+2688,a0; font start
			lea		characters,a1	; data area
			move.w	#2,d7			; 3 lines of characters
cg020		move.w	#19,d6			; 40 characters per line
cg030		move.w	#7,d3			; 8 lines of chars
cg040		move.b	(a0),(a1)
			move.b	2(a0),1(a1)
			move.b	4(a0),2(a1)
			move.b	6(a0),3(a1)
			move.b	1(a0),32(a1)
			move.b	3(a0),33(a1)
			move.b	5(a0),34(a1)
			move.b	7(a0),35(a1)
			lea		160(a0),a0
			lea		4(a1),a1
			dbra	d3,cg040
			lea		-1272(a0),a0	; point to next pair
			lea		32(a1),a1		; next data area
			dbra	d6,cg030		; do all 40 per line
			lea		1120(a0),a0		; next line of characters
			dbra	d7,cg020		; do all the lines

* now cut out the mouse character 

			lea		graphics+6528,a0; mouse ch start
			lea		mouse_ch,a1		; data area
			move.w	#7,d7			; 3 lines of characters
cg050		move.w	(a0),d0			; get a line of character
			clr.w	d1
			movem.w	d0-d1,(a1)		; store graphic character
			lea		32(a1),a1
			move.w	#14,d6			; 15 rolls to perform
cg060		lsr.w	#1,d0			; shift graphic char
			roxr.w	#1,d1
			movem.w	d0-d1,(a1)		; store
			lea		32(a1),a1
			dbra	d6,cg060		; do all rolls
			lea		-508(a1),a1
			lea		160(a0),a0		; next screen line
			dbra	d7,cg050		; do all 8 lines
			rts

print_text	movem.l	d0-d1/d6-d7/a0-a3/a6,-(sp)
			move.l	scr1,a0		; screen pointers
			lea		char_lu,a3		; character look up table
			clr.w	d6				; x location
			clr.w	d7				; y location
			move.b	(a6),d6
			move.b	1(a6),d7		; get print co-ords
			and.w	#$fffe,d6		; clear lsb
			lsl.w	#2,d6			; effective * 8
			mulu.w	#1280,d7		; y offset
			add.w	d6,d7			; total offset
			add.w	d7,a0			; make screen pointer
			clr.w	d6				; x location
			clr.w	d7				; y location
			move.b	(a6)+,d6
			move.b	(a6)+,d7		; get print co-ords
pt010		clr.w	d0
			move.b	(a6)+,d0		; get a character 
			beq.s	pt_end			; exit if no more text
			sub.b	#' ',d0			; normalise it
			lsl.w	#2,d0			; *4 to make l_word pntr
			move.l	(a3,d0.w),a1	; get character pointer
			movem.w	d6-d7,-(sp)		; save x/y co-ords
			lsr.w	#1,d6			; get odd/even bit
			bcs.s	pt020			; skip if in odd position
			jsr		plot_even		; plot the even character
			movem.w	(sp)+,d6-d7		; recover co-ordinates
			addq.w	#1,d6			; next x position
			bra.s	pt010			; and loop
pt020		jsr		plot_odd		; plot in odd position
			movem.w	(sp)+,d6-d7		; recover co-ords
			addq.w	#1,d6			; next x location
			bra.s	pt010			; and loop
pt_end		movem.l	(sp)+,d0-d1/d6-d7/a0-a3/a6
			rts						; return,all done

plot_even	move.w	#7,d7			; line counter
pe000		movem.l	(a1)+,d0-d1		; get bit plane data
			and.l	#$00ff00ff,(a0)	; clear old character
			and.l	#$00ff00ff,4(a0)
			or.l	d0,(a0)			; plot planes 1 & 2
			or.l	d1,4(a0)		; plot planes 3 & 4
			lea		160(a0),a0		; next screen line
			dbra	d7,pe000		; do all the lines
			lea		-1280(a0),a0	; next char position
			rts						; return, all done

plot_odd	move.w	#7,d7			; line counter
po000		movem.l	(a1)+,d0-d1		; get bit plane data
			lsr.l	#8,d0			; shift right
			lsr.l	#8,d1			; shift right
			and.l	#$ff00ff00,(a0)	; clear old character
			and.l	#$ff00ff00,4(a0)
			or.l	d0,(a0)			; plot planes 1 & 2
			or.l	d1,4(a0)		; plot planes 3 & 4
			lea		160(a0),a0		; next screen line
			dbra	d7,po000		; do all the lines
			lea		-1272(a0),a0	; next char position
			rts
			

graphics	incbin	fredfind.neo			
scr1		dc.l	0
my_pallette	dc.w	$000,$700,$770,$037
			dc.w	$070,$642,$555,$742
			dc.w	$357,$000,$000,$000
			dc.w	$000,$000,$000,$777
font_name	dc.b	'FONT.BIN',0
icon_name	dc.b	'ICONS.BIN',0
mouse_name	dc.b	'mouse.bin',0
handle		dc.w	0

mouse_ch	ds.b	4*8*16			; mouse pointer character
			even
icons		ds.w	80*8*8			; editor icon characters
characters	ds.w	100*8*8			; 8*8 font
char_lu		dc.l	characters+64*0
			dc.l	characters+64*1
			dc.l	characters+64*2
			dc.l	characters+64*3
			dc.l	characters+64*4
			dc.l	characters+64*5
			dc.l	characters+64*6
			dc.l	characters+64*7
			dc.l	characters+64*8
			dc.l	characters+64*9
			dc.l	characters+64*10
			dc.l	characters+64*11
			dc.l	characters+64*12
			dc.l	characters+64*13
			dc.l	characters+64*14
			dc.l	characters+64*15
			dc.l	characters+64*16
			dc.l	characters+64*17
			dc.l	characters+64*18
			dc.l	characters+64*19
			dc.l	characters+64*20
			dc.l	characters+64*21
			dc.l	characters+64*22
			dc.l	characters+64*23
			dc.l	characters+64*24
			dc.l	characters+64*25
			dc.l	characters+64*26
			dc.l	characters+64*27
			dc.l	characters+64*28
			dc.l	characters+64*29
			dc.l	characters+64*30
			dc.l	characters+64*31
			dc.l	characters+64*32
			dc.l	characters+64*33
			dc.l	characters+64*34
			dc.l	characters+64*35
			dc.l	characters+64*36
			dc.l	characters+64*37
			dc.l	characters+64*38
			dc.l	characters+64*39
			dc.l	characters+64*40
			dc.l	characters+64*41
			dc.l	characters+64*42
			dc.l	characters+64*43
			dc.l	characters+64*44
			dc.l	characters+64*45
			dc.l	characters+64*46
			dc.l	characters+64*47
			dc.l	characters+64*48
			dc.l	characters+64*49
			dc.l	characters+64*50
			dc.l	characters+64*51
			dc.l	characters+64*52
			dc.l	characters+64*53
			dc.l	characters+64*54
			dc.l	characters+64*55
			dc.l	characters+64*56
			dc.l	characters+64*57
			dc.l	characters+64*58
			dc.l	characters+64*59
			dc.l	characters+64*60
			dc.l	characters+64*61
			dc.l	characters+64*62
			dc.l	characters+64*63
			dc.l	characters+64*64
			dc.l	characters+64*65
			dc.l	characters+64*66
			dc.l	characters+64*67
			dc.l	characters+64*68
			dc.l	characters+64*69
			dc.l	characters+64*70
			dc.l	characters+64*71
			dc.l	characters+64*72
			dc.l	characters+64*73
			dc.l	characters+64*74
			dc.l	characters+64*75
			dc.l	characters+64*76
			dc.l	characters+64*77
			dc.l	characters+64*78
			dc.l	characters+64*79
			dc.l	characters+64*80
			dc.l	characters+64*81
			dc.l	characters+64*82
			dc.l	characters+64*83
			dc.l	characters+64*84
			dc.l	characters+64*85
			dc.l	characters+64*86
			dc.l	characters+64*87
			dc.l	characters+64*88
			dc.l	characters+64*89
			dc.l	characters+64*90
			dc.l	characters+64*91
			dc.l	characters+64*92
			dc.l	characters+64*93
			dc.l	characters+64*94
			dc.l	characters+64*95
			dc.l	characters+64*96
			dc.l	characters+64*97
			dc.l	characters+64*98
			dc.l	characters+64*99
string1		dc.b	0,0,' !"#$%&',"'",'()*+,-.',0
string2		dc.b	0,1,'/0123456789:;<=>?@',0
string3		dc.b	0,2,'ABCDEFGHIJKLMNOPQRSTUVWXYZ',0
string4		dc.b	0,3,'[\]^_`abcdefghijklmnopqrstuvwxyz',0
string5		dc.b	0,4,'{|}~',0