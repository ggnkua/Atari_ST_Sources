; Font Convertor for 2 bit vertical distort with 1 bit horizontal speed
; techno-scrolly-fing !!
; (R) Tony Bennett 08.11.1991
; font = 16x16
;
; Run from MON-ST and save from font2,fontend!



	opt	d+

	lea	font2,a1
	
	moveq	#2-1,d4		;amount of rows
	moveq	#0,d3
	moveq	#0,d7
get_row
	moveq	#20-1,d1		;chars/line
	moveq	#0,d2
get_char
	lea	font1+128(pc),a0
	add.l	d2,a0		;next char on row
	add.l	d3,a0		;next row of chars
	
i	set	0
	rept	16
	move	i(a0),(a1)+
i	set	i+160
	endr

	addq.l	#8,d2	
	dbf	d1,get_char
	
	add.l	#16*160,d3
	dbf	d4,get_row
	
	illegal


font1	incbin	16x16fon.neo

font2	ds.b	16*2*2*20
fontend
