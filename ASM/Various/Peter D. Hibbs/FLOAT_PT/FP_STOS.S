;Initialise floating point binary file
;ENTRY File FLOAT.BIN loaded into RAM at label fp_data
;EXIT  All 32 bit addresses re-located in fp_data block

init_float	movem.l	d0-d1/a0-a1,-(sp)
	lea	fp_data,a0	locate fp data
	move.l	2(a0),a1	fetch offset to relocation
	add	#28,a0	locate base addr
	move.l	a0,d1	d1=offset value
	add.l	a0,a1	a1=relocation table
	add.l	(a1)+,a0	a0=1st address
	add.l	d1,(a0)
init_float1	tst.b	(a1)	end of table ?
	beq	init_float3
	cmp.b	#1,(a1)	large gap ?
	beq	init_float2
	move.b	(a1)+,d0
	and	#$ff,d0
	add	d0,a0	set next addr
	add.l	d1,(a0)	change addr
	bra	init_float1
	
init_float2	add	#254,a0	add 254 to pointer
	add	#1,a1	next byte
	bra	init_float1
	
init_float3	movem.l	(sp)+,d0-d1/a0-a1
	rts

;Floating point entry routine
;ENTRY d0.l and d1.l hold fp number
;      d2.l and d3.l hold fp number (if reqd)
;      d4 holds function number (0-28)
;      a0 holds buffer address (if reqd)
;EXIT  d0.l and d1.l hold result (or d0 holds No of chrs in string)

float_point	movem.l	d2-d7/a0-a6,-(sp)
	move.l	d4,d7	swap registers
	move.l	d3,d4	around to make
	move.l	d2,d3	it easier to
	move.l	d1,d2	use the routines
	move.l	d0,d1
	move.l	d7,d0
	lsl	#2,d0	d0x4
	lea	fp_data+$398c,a6 locate look-up table
	move.l	0(a6,d0),a6	locate function start
	jsr	(a6)	execute function
	movem.l	(sp)+,d2-d7/a0-a6
	rts
	
fp_data	incbin	'F:\DEVPAC\ROUTINES\FLOAT.BIN',0
