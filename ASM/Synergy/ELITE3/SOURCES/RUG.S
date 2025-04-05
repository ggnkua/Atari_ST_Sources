
		text

NO_SPRITES	=	1
SET_PLANES	=	6
ERA_PLANES	=	8

movem_opcode	=	$4ca800ff	;movem.w 0(a0),d0-d7
not_opcode	=	$4640		;not.w dx.w     ;0-2 => register
or_opcode	=	$8040		;or.w dx.w,dx.w ;0-2 => dest, 9-11 => source
or_opcode2	=	$8168		;or.w dx.w,0(a0)
or_opcode3	=	$8158		;or.w dx.w,(a0)+
and_opcode	=	$c040		;and.w dx.w,dx.w
and_opcode2	=	$c168		;and.w dx.w,0(a0)
and_opcode3	=	$c158		;and.w dx.w,(a0)+
lea_opcode	=	$41e8		;lea 0(a0),a0
move_opcode	=	$3247		;move.w d7,a1
move_opcode2	=	$3e09		;move.w a1,d7
move_opcode3	=	$3019		;move.w (a1)+,d0
move_opcode4	=	$3200		;move.w	d0,d1
dbra_opcode	=	$51cf		;dbra d7,0
rts_opcode	=	$4e75		;rts

maxie = 62

init_rug:	bsr	create_sprites
		lea	sprite_1,a0
		bsr	init_sprite
		move.w	#1,draw_color
		move.w	#1,erase_color
		clr.w	erase_active
		move.w	#maxie*2,erase_delay
	
		lea	tracks,a0
.loop:		move.l	(a0),d0
		bmi.s	.done
		movem.l	(tracks_list_x.l,d0.w*8),d0-d1
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		move.l	(a0),d0
		movem.l	(tracks_list_y.l,d0.w*8),d0-d1
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d1,(a0)+			
		bra	.loop
.done:		rts
		
screen_bit:	dc.w	0		
draw_color:	dc.w	0
erase_color:	dc.w	0
erase_active:	dc.w	0
erase_delay:	dc.w	0		
		
vbl_rug:	bsr	update_sprites
		bsr	erase_sprites
		bsr	draw_sprites
		rts

draw_list_ptr:	dc.l	draw_list
erase_list_ptr:	dc.l	erase_list

erase_list:	dc.w	-1			;sprite number
		dc.w 	0			;x
		dc.w	0			;y
		dc.w	-1,0,0
		dc.w	-1,0,0
		dc.w	-1,0,0
		dc.w	-1

draw_list:	dc.w	0			;sprite number
		dc.w	0			;x
		dc.w	0			;y
		dc.w	0,0,0
		dc.w	0,0,0
		dc.w	0,0,0
		dc.w	-1

update_sprites:	not.w	screen_bit
		beq.s	.cok
		addq.w	#1,draw_color
		cmp.w	#maxie+1,draw_color
		blt.s	.cok
		move.w	#1,draw_color	
.cok:			
		bsr	update_erase
		bsr	update_draw

		lea	current_pal+4,a0
		move.w	#maxie,d0
		sub.w	draw_color,d0
		lea	(palette.l,d0.w*4),a1
		move.w	#63-1,d0
loop:		move.l	(a1)+,(a0)+
		dbra	d0,loop
		rts
		
		
update_erase:	tst.w	erase_active
		bne.s	update_erase2
		subq.w	#1,erase_delay
		bmi.s	erase_ok
		rts

erase_ok	st	erase_active
	
update_erase2:	lea	tracks+24,a6

		lea	erase_list,a0
.loop:		tst.l	-24(a6)
		bmi.s	.ue_done
		clr.w	(a0)+
		move.l	4(a6),a1
		move.w	(a1)+,(a0)+
		cmp.l	8(a6),a1
		blt.s	.xok
		move.l	(a6),a1
.xok:		move.l	a1,4(a6)
		move.l	16(a6),a1
		move.w	(a1)+,(a0)+
		cmp.l	20(a6),a1
		blt.s	.yok
		move.l	12(a6),a1
.yok:		move.l	a1,16(a6)
		lea	24*2(a6),a6
		bra	.loop
.ue_done:	rts
		
update_draw:	lea	tracks,a6
		lea	draw_list,a0
.loop:		tst.l	(a6)
		bmi.s	.ud_done
		clr.w	(a0)+
		move.l	4(a6),a1
		move.w	(a1)+,(a0)+
		cmp.l	8(a6),a1
		blt.s	.xok
		move.l	(a6),a1
.xok:		move.l	a1,4(a6)
		move.l	16(a6),a1
		move.w	(a1)+,(a0)+
		cmp.l	20(a6),a1
		blt.s	.yok
		move.l	12(a6),a1
.yok:		move.l	a1,16(a6)
		lea	24*2(a6),a6
		bra	.loop
.ud_done:	rts
		
erase_sprites:	move.l	erase_list_ptr,a6
erase_loop:	move.w	(a6)+,d0
		bmi.s	no_erase
		move.l	(sprite_list,d0.w*4),a1
		move.w	2(a1),d7		;height
		movem.w	(a6)+,d0-d1		;x,y
		move.w	draw_color,d2
		move.l	screen1,a0
		add.w	(x_table+2.l,d0.w*4),a0
		move.w	(x_table.l,d0.w*4),d0
		add.l	(y_table.l,d1.w*4),a0
		jsr	([col2_era_ptrs,d2.w*4])
		bra	erase_loop
no_erase:	rts
			
draw_sprites:	move.l	draw_list_ptr,a6
draw_loop:	move.w	(a6)+,d0
		bmi.s	no_draw
		move.l	(sprite_list,d0.w*4),a1
		addq.l	#2,a1
		move.w	(a1)+,d7
		movem.w	(a6)+,d0-d1
		move.w	draw_color,d2
		move.l	screen1,a0
		add.w	(x_table+2.l,d0.w*4),a0
		move.w	(x_table.l,d0.w*4),d0
		add.l	(y_table.l,d1.w*4),a0		;screen
		mulu	(a1)+,d0
		lea	(a1,d0.w),a1			;sprite
		jsr	([col2_set_ptrs,d2.w*4])	;a0=data,d7=height,
		bra.s	draw_loop
no_draw:	rts		
	
init_sprite:	
* in:  a0.l = sprite

		move.w	(a0),d0		;sprite x
		move.w	2(a0),d1	;sprite y
		addq.w	#1,d1
		add.w	#15+16,d0
		lsr.w	#4,d0
		lea	6(a0),a2	;data start	
		move.w	d0,d2
		mulu	d1,d2
		move.w	d2,d3
		add.w	d3,d3
		lea	(a2,d3.w),a1
		move.w	d3,4(a0)
		subq.w	#1,d2
		moveq	#15-1,d4
.cp3:		move.l	a1,a3
		move.w	d2,d3
.cp1:		move.w	(a2)+,(a3)+
		dbra	d3,.cp1
		move.w	d2,d3
.cp2:		roxr.w	(a1)+
		dbra	d3,.cp2
		dbra	d4,.cp3
		rts

create_sprites:	lea	code,a6
		move.w	#1,columns		;code 1 column routines
		lea	col1_set_ptrs,a0
		lea	col1_era_ptrs,a1
		bsr	coder
		move.w	#2,columns		;code 2 column routines
		lea	col2_set_ptrs,a0
		lea	col2_era_ptrs,a1
		bsr	coder
		
		lea	x_table,a0
		moveq	#0,d0
		move.w	#X_SIZE-1,d1
.xloop:		move.w	d0,d2
		move.w	d2,d3
		and.w	#$000f,d3
		move.w	d3,(a0)+
		lsr.w	#4,d2
		mulu	#COLUMN_SIZE,d2
		move.w	d2,(a0)+
		addq.w	#1,d0
		dbra	d1,.xloop

		lea	y_table,a0
		moveq	#0,d0
		move.w	#Y_SIZE-1,d1
.y_loop:	move.w	d0,d2
		mulu	#LINE_SIZE,d2
		move.l	d2,(a0)+
		addq.w	#1,d0
		dbra	d1,.y_loop
		rts
		
coder:		move.l	#rts_rout,(a0)+
		move.l	#rts_rout,(a1)+
		
		move.w	#1,color		;start at color 1
.loop:		move.w	color,d0		;get current color
		bsr	count_planes		;create some tables
		move.l	a6,(a0)+		;store ptr to draw code
		bsr	code_set		;create draw code
		move.l	a6,(a1)+		;store ptr to era code
		bsr	code_erase		;create erase code
		addq.w	#1,color		;next color
		cmp.w	#65,color		;loop for 255 colors
		bne.s	.loop
rts_rout:	rts	

code_set:	movem.l	d0-a5,-(sp)		;save regs

		moveq	#0,d6			;screen offset
		move.w	columns,d7		;numb of columns to do
		subq.w	#1,d7			;dbra
		move.l	a6,a5			;copy start adr of code
.loop2:		
		move.l	#(move_opcode3<<16)|move_opcode4,(a6)+ ;
		move.w	#not_opcode|1,(a6)+

		lea	plane_list+8,a0
		moveq	#SET_PLANES-1,d0
.loop:		tst.b	-(a0)
		beq.s	.clear
		move.w	#or_opcode2|(0<<9),(a6)+
		bra.s	.set
.clear:		move.w	#and_opcode2|(1<<9),(a6)+
.set:		move.w	d6,(a6)+
		addq.w	#2,d6
		dbra	d0,.loop
		add.w	#(8-SET_PLANES)*2,d6
		dbra	d7,.loop2
		
		move.l	#(lea_opcode<<16)|LINE_SIZE,(a6)+
		move.w	#dbra_opcode,(a6)+
		move.l	a5,d0
		sub.l	a6,d0
		move.w	d0,(a6)+
		move.w	#rts_opcode,(a6)+	

		movem.l	(sp)+,d0-a5
		rts

code_erase:	movem.l	d0-a5,-(sp)
	
		moveq	#9,d5
		moveq	#0,d6		;base_offset		
		move.w	columns,d7
		subq.w	#1,d7
		move.l	a6,a5

		move.w	#move_opcode,(a6)+
column_loop:	move.l	#movem_opcode,(a6)+	;movem.w 0(a0),d0-d7
		move.w	d6,(a6)+
	
		lea	plane_list2,a0		;planes not to set
		move.w	(a0)+,d0
		bmi.s	.full_color
		move.w	d0,d1
		lsl.w	d5,d1
		or.w	#or_opcode,d1		;base 'or.w'
.loop:		move.w	(a0)+,d2
		bmi.s	.done
		or.w	d1,d2
		move.w	d2,(a6)+
		bra.s	.loop
.full_color:	moveq	#0,d0
		bra.s	.full
.done:		move.w	#not_opcode,(a6)
		or.w	d0,(a6)+
.full:		
		lea	plane_list3,a0
		move.w	d0,d1
		lsl.w	d5,d1
		or.w	#and_opcode,d1
.loop2:		move.w	(a0)+,d2
		bmi.s	.done2
		cmp.w	d0,d2
		beq.s	.loop2
		or.w	d1,d2
		move.w	d2,(a6)+
		bra.s	.loop2
.done2:		move.w	#not_opcode,(a6)
		or.w	d0,(a6)+
		
		lea	plane_list3,a0
		move.w	d0,d1
		lsl.w	d5,d1
		or.w	#and_opcode2,d1
		swap	d1
.loop3:		move.w	(a0)+,d1
		bmi.s	.done3
		add.w	d1,d1
		add.w	d6,d1
		move.l	d1,(a6)+
		bra.s	.loop3
.done3:	
		add.w	#COLUMN_SIZE,d6
		dbra	d7,column_loop

		move.l	#(lea_opcode<<16)|LINE_SIZE,(a6)+
		move.l	#(move_opcode2<<16)|dbra_opcode,(a6)+
		move.l	a5,d0
		sub.l	a6,d0
		move.w	d0,(a6)+
		move.w	#rts_opcode,(a6)+	

		movem.l	(sp)+,d0-a5
		rts
		
		
count_planes:	
* in:  d0.b = color
		movem.l	d0-a5,-(sp)
		
		lea	plane_list,a0
		moveq	#0,d1
		moveq	#8-1,d2
.count:		add.b	d0,d0
		scs	(a0)+
		dbra	d2,.count

		lea	plane_list+8,a0
		lea	plane_list2,a1
		lea	plane_list3,a2
		moveq	#-1,d0
		moveq	#ERA_PLANES-1,d1
.next:		addq.w	#1,d0
		tst.b	-(a0)
		bne	.set_case
.clear_case:	move.w	d0,(a1)+
		bra.s	.goh
.set_case:	move.w	d0,(a2)+		
.goh:		dbra	d1,.next
.exit:		move.w	#-1,(a1)+
		move.w	#-1,(a2)+		
		
		movem.l	(sp)+,d0-a5
		rts
		
		data

sprite_list:	dc.l	sprite_1
				
sprite_1:	dc.w	16		;x size (without shift column)
		dc.w	8-1		;y size-1
		dc.w	0		;calced x*y 
		dc.w	%0000001110000000,0
		dc.w	%0000111111100000,0
		dc.w	%0001111111110000,0
		dc.w	%0011111111111000,0
		dc.w	%0011111111111000,0
		dc.w	%0001111111110000,0
		dc.w	%0000111111100000,0
		dc.w	%0000001110000000,0
		ds.l	15*8		;shifted data


palette:	
.offset		set	$fc-8
		rept	62
		dc.l	$000000fc-.offset
.offset		set	.offset-4
		endr
		
.offset		set	$fc-8
		rept	62
		dc.l	$000000fc-.offset	
.offset		set	.offset-4
		endr				


tracks:		dc.l	0,0,0,0,0,0	;initx,ctrx,endx
		dc.l	0,0,0,0,0,0	
		dc.l	0,0,0,1,0,0
		dc.l	0,0,0,1,0,0
		dc.l	1,0,0,0,0,0
		dc.l	1,0,0,0,0,0
		dc.l	1,0,0,1,0,0
		dc.l	1,0,0,1,0,0
		dc.l	-1
		
tracks_list_x:	dc.l	t1x,t1xe
		dc.l	t2x,t2xe
tracks_list_y:	dc.l	t1y,t1ye
		dc.l	t2y,t2ye				
		
t1x:		incbin	"f:\sources\ELITE.3\binary\xtable2.bin"		
t1xe:
t1y:		incbin	"f:\sources\ELITE.3\binary\ytable2.bin"		
t1ye
t2x:		incbin	"f:\sources\ELITE.3\binary\xtable3.bin"		
t2xe:
t2y:		incbin	"f:\sources\ELITE.3\binary\ytable3.bin"		
t2ye:		
		
		bss
	
color:		ds.w	1
columns:	ds.w	1
plane_list:	ds.b	8
plane_list2:	ds.w	9		
plane_list3:	ds.w	9		
		
col1_set_ptrs:	ds.l	64
col1_era_ptrs:	ds.l	64
col2_set_ptrs:	ds.l	64
col2_era_ptrs:	ds.l 	64

x_table:	ds.l	X_SIZE
y_table:	ds.l	Y_SIZE

code:		ds.b	60000	
