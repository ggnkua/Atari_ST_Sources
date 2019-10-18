start:		opt	o+

		bra	install

scroll_vbl:	movem.l	d0-d2/d7,-(sp)		;save registers
		move.w	screen_pos(pc),d0	;top of screen
		move.w	d0,d7
save_mouse_y:	move.w	$0.l,d1			;mouse y-pos
		move.w	d1,d2
margin1:	addi.w	#50,d0			;x lines from top
		sub.w	d0,d1			;mouse-screen
		blt.s	scroll_down
margin2:	addi.w	#400-(2*50),d0		;x lines from bottom			
		sub.w	d0,d2			;mouse-screen
		bgt.s	scroll_up

end_vbl:	movem.l	(sp)+,d0-d2/d7		;save registers
vbl_return:	jmp	$0.l			;return to real vbl

scroll_down:	add.w	d1,d7			;scroll screen down
		bgt.s	set_new_pos		;past top of screen ?
		clr.w	d7			;yes, set to top
		bra.s	set_new_pos
		
scroll_up:	add.w	d2,d7			;scroll screen up
lines1:		cmpi.w	#800-400,d7		;past end of screen
		blt.s	set_new_pos
lines2:		move.w	#800-400,d7		;yes, set to bottom
		
set_new_pos:	move.w	d7,screen_pos		;save new position
offset1:	mulu.w	#80,d7			;byte position
		add.l	logical(pc),d7		;offset for screen

set_video_adr:	move.l	d7,screen_adr
		move.b	screen_adr+1(pc),$FFFF8201.w	;high
		move.b	screen_adr+2(pc),$FFFF8203.w	;middle
		move.b	screen_adr+3(pc),$FFFF820D.w	;low (only ste)
		bra.s	end_vbl

interl_vbl:	movem.l	d0-d2/d7,-(sp)
		move.l	logical(pc),d7
		tst.b	screen_pos
		beq.s	second_screen
		clr.b	screen_pos
		bra.s	set_video_adr	
second_screen:	move.b	#1,screen_pos
offset2:	addi.l	#80,d7
		bra.s	set_video_adr


new_gem:	cmpi.w	#$73,d0			;vdi call ?
		bne.s	return			;no - return
		
		move.l	d1,a0			;pointer to pb
		move.l	(a0),a1			;pointer to control
		cmpi.w	#1,(a1)			;control(0)=1 ?
		bne.s	return			;no - return

		move.l	12(a0),after_call+2	;pointer to int_out
		move.l	2(a7),save_return+2	;real return adress
		move.l	#after_call,2(a7)	;fake return adress
	
return:		jmp	$0.l			;to standard trap #2

after_call:	move.l	#$0,a0			;pointer to int_out
lines3:		move.w	#800-1,2(a0)		;y-size in int_out(1)
save_linea:	move.l	#$0,a0			;linea pointer
lines4:		move.w	#800,-4(a0)		;vertical res
chars1:		move.w	#25-1,-42(a0)		;chars height -1
lines5:		move.w	#800-1,-690(a0)		;int_out(1)
		move.w	return(pc),new_gem
		move.l	return+2(pc),new_gem+2
save_return:	jmp	$0.l			;and to program

screen_pos:	dc.w	0			;line at top of screen
screen_adr:	ds.l	1			;to calculate adress
logical:	ds.l	1			;logical screen adress

print_info:	pea	info(pc)		;info text
		move.w	#$09,-(sp)		;print line
		trap	#1			;gemdos
		addq.l	#6,sp
		rts

install:	move.w	#-1,-(sp)		;read status
		move.w	#11,-(sp)		;kbshift
		trap	#13			;bios
		addq.l	#4,sp
		
		andi.b	#3,d0			;SHIFT pressed ?
		move.b	d0,d7			;Save SHIFT status
		bne.s	set_it_up		;yep, install

		bsr.s	print_info		;print info & help
		clr.w	-(sp)			;terminate
		trap	#1			;gemdos

set_it_up:	lea	stack(pc),sp		;set up new stack

		move.l	#(stack-start)+$100,-(sp)	;reserve only
		move.l	#start-$100,-(sp)		;needed memory
		clr.w	-(sp)
		move.w	#$4A,-(sp)		;setblock
		trap	#1			;gemdos
		lea	12(sp),sp

		clr.l	-(sp)			;super mode
		move.w	#$20,-(sp)		;super
		trap	#1			;gemdos
		addq.l	#6,sp

		move.l	#-1,-(sp)		;get free bytes
		move.w	#$48,-(sp)		;malloc
		trap	#1			;gemdos
		addq.l	#6,sp
		
		subi.l	#32000,d0		;everything except
		move.l	d0,-(sp)		;32000 bytes extra
		move.w	#$48,-(sp)		;malloc
		trap	#1			;gemdos
		addq.l	#6,sp
		move.l	d0,d6			;save start (for mfree)
		
		move.l	#32000,-(sp)		;get last 32000 bytes
		move.w	#$48,-(sp)		;malloc
		trap	#1			;gemdos
		addq.l	#6,sp
		
		move.l	d0,$436.w		;new _memtop
		move.l	d0,logical		;new logical screen

		move.l	d6,-(sp)		;area to free again
		move.w	#$49,-(sp)		;mfree
		trap	#1
		addq.l	#6,sp

		cmpi.b	#2,$44C.w		;monochrome ?
		beq.s	countinue		;yes, do nothing
		bsr	set_up_color		;no, set up for color

countinue:	move.w	#-1,-(sp)		;retain resolution
		move.l	logical(pc),-(sp)
		move.l	logical(pc),-(sp)
		move.w	#5,-(sp)		;setscreen
		trap	#14			;xbios
		lea	12(sp),sp

		dc.w	$A000			;get linea adress
		move.l	a0,save_linea+2
lines6:		move.w	#800,-4(a0)		;vertical res
		move.w	#800/16-1,-42(a0)	;chars-1
		suba.l	#600,a0			;mouse y variable
		move.l	a0,save_mouse_y+2	;and save adress

		clr.b	info2			;skip help info
		bsr	print_info		;info text on screen

		move.l	$88.w,return+2		;save trap #2 adress
		move.l	#new_gem,$88.w		;set new trap #2 adress

		move.l	$70.w,vbl_return+2	;save old vbl

		btst.l	#0,d7			;Interlace mode
		beq.s	offset3			;yes, install it

		move.l	#scroll_vbl,$70.w	;no, set new vbl
		bra.s	exit			;and exit

offset3:	move.b	#40,$FFFF820F.w		;80 bytes offset
		move.w	#50-1,chars1+2		;50 chars heigth -1
		move.l	#interl_vbl,$70.w	;set new vbl

exit:		clr.w	-(sp)			
		move.l	#(print_info-start)+$100,-(sp)
		move.w	#$31,-(sp)
		trap	#1

set_up_color:	move.w	#400,d0			;all 400 places
		move.w	d0,lines4+2
		move.w	d0,lines6+2
		subq.w	#1,d0			;all 400-1 places
		move.w	d0,lines3+2
		move.w	d0,lines5+2
		move.w	#400-200,d0		;all 400-200 places
		move.w	d0,lines1+2
		move.w	d0,lines2+2
		move.l	#160,d0			;all 160 places
		move.w	d0,offset1+2
		move.l	d0,offset2+2
		move.w	#80,offset3+2		;all 80 places
		move.w	#25,margin1+2		;all 25 places
		move.w	#200-(2*25),margin2+2	;all 200-(2*25) places
		rts

info:		dc.b	27,'E',10,'  STE  Double-Height Emulator  2.01'
		dc.b	13,10,10, '  (C) Lars-Erik ²sterud  02/07-1991'
		dc.b	13,10,10
		
info2:		dc.b	10,'  RIGHT-SHIFT for Scrolling Display',13,10,10
		dc.b	'  LEFT-SHIFT for Interlaced Display',13,10,10,0

		section	bss
		
		ds.l	10	;place for program stack
stack: