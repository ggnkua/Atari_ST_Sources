
ugh:		move.w	#97,x_size
		move.w	#137,y_size
		bsr	convert_palette
		bsr	remap_palette
		bsr	remap_graphics
		bsr	link_palette_and_graphics
		
		move.l	start_file,a0
		move.l	graph_end,a1			
		nop
		illegal	

remap_list:	dc.w	1,0,2,3

link_palette_and_graphics:
		lea	logo,a0
		move.l	graph_start,a1
		move.w	6(a0),d0
		lea	(128,a0,d0.w*4),a0
		subq.w	#1,d0
.copy:		move.l	-(a0),-(a1)
		dbra	d0,.copy
		move.l	a1,start_file
		rts

convert_palette:	
		lea	logo,a0
		lea	128(a0),a1
		move.l	a1,a2
		move.w	6(a0),d0
		subq.w	#1,d0
		moveq	#2,d1
		move.w	#%11111100,d2
.lo:		move.w	(a1)+,d3
		move.w	(a1)+,d4
		move.w	(a1)+,d5
		lsr.w	d1,d3
		lsr.w	d1,d4
		lsr.w	d1,d5
		and.w	d2,d3
		and.w	d2,d4
		and.w	d2,d5
		move.b	d3,(a2)+
		move.b	d4,(a2)+
		clr.b	(a2)+
		move.b	d5,(a2)+
		dbra	d0,.lo
		rts

remap_palette:	lea	logo,a0
		lea	remap_list,a1
		movem.l	(128,a0),d0-d3
		movem.w	(a1)+,d4-d7
		move.l	d0,(128,a0,d4.w*4)
		move.l	d1,(128,a0,d5.w*4)
		move.l	d2,(128,a0,d6.w*4)
		move.l	d3,(128,a0,d7.w*4)
		rts
		

remap_graphics:	lea	logo,a0
		
		moveq	#6,d0
		mulu	6(a0),d0
		lea	(128,a0,d0.w),a1
		move.l	a1,graph_start
		
		move.w	8(a0),d0
		move.w	x_size,d1
		add.w	#15,d0		;x size
		add.w	#15,d1
		lsr.w	#4,d0		;x columns 
		lsr.w	#4,d1
		move.w	d0,columns
		move.w	d1,rcolumns
		sub.w	d1,d0
		lsl.w	#2,d0
		move.w	d0,x_skip
		
		move.l	graph_start,a0
		move.l	a0,a1
	
		move.w	y_size,d2
		subq.w	#1,d2
.loop3:		move.w	rcolumns,d3
		subq.w	#1,d3
.loop:		move.w	(a0)+,d5
		move.w	(a0)+,d6
		moveq	#0,d7
		moveq	#16-1,d4
.loop2:		add.w	d5,d5
		addx.l	d7,d7
		add.w	d6,d6
		addx.l	d7,d7				
		dbra	d4,.loop2								
		move.l	d7,(a1)+
		dbra	d3,.loop
		add.w	x_skip,a0
		dbra	d2,.loop3
			
		move.l	graph_start,a0			
		lea	remap_list,a1
		move.w	rcolumns,d7
		mulu	y_size,d7
			
.lop2:		move.l	(a0),d0
		moveq	#0,d1
		moveq	#16-1,d3
.lop:		rol.l	#2,d0
		rol.l	#2,d1
		move.w	d0,d2
		and.w	#%11,d2
		or.w	(a1,d2.w*2),d1
		dbra	d3,.lop						
		move.l	d1,(a0)+
		subq.l	#1,d7
		bne.s	.lop2
		
		move.l	graph_start,a0
		move.w	rcolumns,d7
		mulu	y_size,d7
		
.x2:		move.l	(a0),d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#16-1,d3
.x:		add.l	d0,d0
		addx.w	d1,d1
		add.l	d0,d0
		addx.w	d2,d2
		dbra	d3,.x
		move.w	d1,(a0)+
		move.w	d2,(a0)+
		subq.l	#1,d7
		bne.s	.x2
		move.l	a0,graph_end		
		rts


		bss

graph_start:	ds.l	1
graph_end:	ds.l	1
start_file:	ds.l	1
x_size:		ds.w	1
y_size:		ds.w	1
columns:	ds.w	1
rcolumns:	ds.w	1
x_skip:		ds.w	1
			
		data			
			
logo:		incbin	"e:\elite.3\graphics\jigsaw.tpi"
		even

		end				
		
		