;Initialise sprite data files and table
;For use with .OBJ files from Neochrome Master
;ENTRY 'sprite_file' string holds path and filename of sprite data file
;EXIT  various registers corrupted
;      (screen) holds screen start address
;      (sprite_tab..) buffer holds table of sprite data
;      (sprite_data..) buffer holds sprite data
;      (sprite_mask..) buffer holds sprite mask data
;      d0 = 0 = file loaded OK or
;      d0 = negative value = file error (d0=error code)

sprite_init	move	#3,-(sp)	   fetch screen address
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen	   save screen start address

	move	#2,-(sp)	   open sprite data file
	pea	sprite_file   define path & filename
	move	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	move	d0,file_handle
	tst.l	d0
	bmi	sprite_init3          quit if error

	lea	sprite_mask,a5	a5 points at mask data
	lea	sprite_tab,a1	a1 points at sprite table

	pea	sprite_data	read sprite data
	move.l	#$7fffffff,-(sp)      into sprite data buffer
	move	file_handle,-(sp)
	move	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi	sprite_init3	quit if error

	move	file_handle,-(sp)     close file
	move	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	bmi	sprite_init3	quit if error

	lea	sprite_data+8,a0	calc No of sprites
	add	(a0),a0
	add	#2+4,a0	set a0 to 1st spr header
	move	(a0)+,d5	fetch No of sprites &
	sub	#1,d5	correct for dbra instr
	move.l	a0,d4	save a0 in d4

sprite_init1	move	10(a0),(a1)+	copy width to sprite table
	move	6(a0),d0	copy height-1 to sprite table
	sub	#1,d0	
	move	d0,(a1)+	
	move.b	16(a0),d0	copy x offset to table ?
	and.l	#$ff,d0
	move	d0,(a1)+
	move.b	17(a0),d0	copy y offset to table ?
	move	d0,(a1)+
	move.l	(a0),d0	copy sprite data address 
	add.l	d4,d0	to sprite table
	move.l	d0,(a1)+
	move.l	d0,a2	and into a2
	move	10(a0),d0	calc size of sprite data
	mulu	6(a0),d0
	move.l	a5,(a1)+	copy sprite mask address to table
	lsr	#3,d0	calc width of mask-1
	sub	#1,d0
sprite_init2	clr	(a5)	generate mask data
	move	(a2)+,d2
	or	d2,(a5)	and copy to buffer
	move	(a2)+,d2
	or	d2,(a5)
	move	(a2)+,d2
	or	d2,(a5)
	move	(a2)+,d2
	or	d2,(a5)+
	dbra	d0,sprite_init2	repeat
	add.l	#20,a0	access next sprite
	dbra	d5,sprite_init1	repeat for all sprites
	clr.l	d0	file loaded OK (d0=0)
sprite_init3	rts
	


;Draw stationary sprite image 
;ENTRY d0=x co-ord of hot spot (0-319)
;      d1=y co-ord of hot spot (0-199)
;      d2=sprite number (1-n)
;      sprite_tab table initialised by sprite_init
;      (screen) holds screen or buffer addr
;EXIT  No regs changed

s_sprite	movem.l	d0-d5/a0-a3,-(sp)
	lea	sprite_tab,a0	set table pointer
	and.l	#$ffff,d2
	sub	#1,d2
	lsl	#4,d2
	add.l	d2,a0

	move	(a0)+,d2	d2=width in bytes
	move	(a0)+,d5	d5=No of scanlines-1
	sub	(a0)+,d0	x hot spot
	sub	(a0)+,d1	y hot spot
	move.l	(a0)+,a1	a1=sprite data
	move.l	(a0)+,a3	a3=mask data

	move.l	screen,a0	a0=screen start
	move.l	a0,a2
	add	#32000,a2	a2=screen end
	mulu	#160,d1
	add.l	d1,a0	a0=sprite line address
	move	d0,d4
	lsr	#4,d0
	lsl	#3,d0
	add	d0,a0	a0=sprite byte address
	lsr	#3,d2
	subq	#2,d2	d2=corrected width
	and	#$0f,d4	d4=bit shift value
s_sprite6	cmp.l	a2,a0	chk if sprite off bottom of scrn
	bgt	s_sprite2
	cmp.l	screen,a0	chk if sprite off top of scrn
	blt	s_sprite2

	movem.l	d2/a0,-(sp) display left chunk
	moveq	#0,d3
	move	(a3),d3
	lsr.l	d4,d3
	not.l	d3
	move	#4-1,d1
s_sprite8	moveq	#0,d0
	move	(a1)+,d0
	lsr.l	d4,d0
	and	d3,(a0)
	or	d0,(a0)+
	dbra	d1,s_sprite8
	subq.l	#8,a1
	cmp	#-1,d2
	beq	s_sprite1

s_sprite7	move.l	(a3),d3	display centre chunks
	lsr.l	d4,d3
	not.l	d3
	addq.l	#2,a3
	move	#4-1,d1
s_sprite9	move.l	(a1),d0
	move	8(a1),d0
	addq.l	#2,a1
	lsr.l	d4,d0
	and	d3,(a0)
	or	d0,(a0)+
	dbra	d1,s_sprite9
	dbra	d2,s_sprite7

s_sprite1	move.l	(a3),d3	display right chunk
	clr	d3
	addq.l	#2,a3
	lsr.l	d4,d3
	not.l	d3
	move	#4-1,d1
s_sprite0	move.l	(a1),d0
	clr	d0
	addq.l	#2,a1
	lsr.l	d4,d0
	and	d3,(a0)
	or	d0,(a0)+
	dbra	d1,s_sprite0	
	movem.l	(sp)+,d2/a0
	add.l	#160,a0
	dbra	d5,s_sprite6  repeat lines
s_sprite2	movem.l	(sp)+,d0-d5/a0-a3
	rts

;Draw sprite and save backgrnd
;ENTRY d0=x co-ord (0-319)
;      d1=y co-ord (0-199)
;      d2=sprite No (1-nn)
;      (screen) holds screen addr
;      (spr_buffer) clear or holds data
;      (sprite_tab..) holds table
;EXIT  Old sprite restored and 
;      new sprite displayed

m_sprite	movem.l	d0-d5/a0-a4,-(sp)
	lea	sprite_tab,a0	set table pointer
	and.l	#$ffff,d2
	sub	#1,d2
	lsl	#4,d2
	add.l	d2,a0

	move.l	screen,a4	a4=screen limit
	add	#32000,a4	

	move	(a0)+,d2	d2=width in bytes
	move	(a0)+,d5	d5=No of scanlines-1
	sub	(a0)+,d0	x hot spot ??
	sub	(a0)+,d1	y hot spot ??
	move.l	(a0)+,a1	a1=sprite data
	move.l	(a0)+,a3	a3=mask data
	
	lea	spr_buffer,a2
	tst.l	(a2)
	beq	m_sprite1	skip if no image stored
	
	move.l	(a2)+,a0	fetch scrn address
	move	(a2)+,d6	fetch width (bytes)
	move	(a2)+,d3	fetch height
		
m_sprite2	movem.l	d6/a0,-(sp)   copy buffer to scrn
m_sprite3	move	(a2)+,(a0)+
	dbra	d6,m_sprite3
	movem.l	(sp)+,d6/a0
	add.l	#160,a0
	cmp.l	a4,a0
	bgt	m_sprite13
	dbra	d3,m_sprite2
m_sprite13	lea	spr_buffer,a2
	clr.l	(a2)	erase buffer

m_sprite1	cmp	#319,d0	exit if invalid co-ords
	bhi	m_sprite10
	cmp	#199,d1
	bhi	m_sprite10
	
	move.l	screen,a0	calc sprite addr
	mulu	#160,d1
	add.l	d1,a0
	
	move	d0,d4
	lsr	#4,d0
	lsl	#3,d0
	add	d0,a0
	
	move	d2,d3
	lsr	#1,d3
	addq	#4,d3
	
	move.l	a0,(a2)+	copy addr to buffer
	move	d3,(a2)+	copy width to buffer
	move	d5,(a2)+	copy height to buff
	
	movem.l	d5/a0,-(sp)  copy screen data to buffer
m_sprite4	movem.l	d3/a0,-(sp)
m_sprite5	move	(a0)+,(a2)+
	dbra	d3,m_sprite5
	movem.l	(sp)+,d3/a0
	add.l	#160,a0
	cmp.l	a4,a0
	bgt	m_sprite12
	dbra	d5,m_sprite4
m_sprite12	movem.l	(sp)+,d5/a0
	
	lsr	#3,d2	
	subq	#2,d2
	and	#$0f,d4
m_sprite6	cmp.l	a4,a0	chk end of screen	
	bgt	m_sprite10
	cmp.l	screen,a0	chk start of screen
	blt	m_sprite10
	
	movem.l	d2/a0,-(sp)  display sprite
	moveq	#0,d3
	move	(a3),d3
	lsr.l	d4,d3
	not.l	d3
	move	#4-1,d1
m_sprite8	moveq	#0,d0
	move	(a1)+,d0
	lsr.l	d4,d0
	and	d3,(a0)
	or	d0,(a0)+
	dbra	d1,m_sprite8
	subq.l	#8,a1
	cmp	#-1,d2
	beq	m_sprite11
m_sprite7	move.l	(a3),d3
	lsr.l	d4,d3
	not.l	d3
	addq.l	#2,a3
	move	#4-1,d1
m_sprite9	move.l	(a1),d0
	move	8(a1),d0
	addq.l	#2,a1
	lsr.l	d4,d0
	and	d3,(a0)
	or	d0,(a0)+
	dbra	d1,m_sprite9
	dbra	d2,m_sprite7
m_sprite11	move.l	(a3),d3
	clr	d3
	addq.l	#2,a3
	lsr.l	d4,d3
	not.l	d3
	move	#4-1,d1
m_sprite0	move.l	(a1),d0
	clr	d0
	addq.l	#2,a1
	lsr.l	d4,d0
	and	d3,(a0)
	or	d0,(a0)+
	dbra	d1,m_sprite0	
	movem.l	(sp)+,d2/a0
	add.l	#160,a0
	dbra	d5,m_sprite6
m_sprite10	movem.l	(sp)+,d0-d5/a0-a4
	rts

sprite_file	dc.b	'FILENAME.OBJ',0	filepath/filename
		even
		
file_handle	ds.w	1	file handle
screen		ds.l	1	screen address
sprite_tab		ds.b	No of sprites*16	sprite table
sprite_data	ds.b	Size of .OBJ file	sprite data
sprite_mask	ds.b	sprite_data/4	mask data
spr_buffer		ds.b	(width in bytes+4)*(height)+8	temp buffer (largest sprite)
