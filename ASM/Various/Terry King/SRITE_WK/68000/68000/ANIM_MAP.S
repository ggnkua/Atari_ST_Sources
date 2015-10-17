;
; Map animator for use with the ste/mapper and v_mapper commands.
;
; Changes sprite numbers in map blocks so when the map is reprinted
; the graphics will change.
;
;
; ~C:animate_block(number,x,y,start,end,current,speed,loop,L:map)
; ~C:animate_clear(number)
; ~C:animate_map()
;
; ------- Copyright Terry King Ninth Wave Software 1993-95 -------

	bra	animate_block
	bra	animate_map
	bra	animate_clear

ADDRESS=0
START=4
END=6
CURRENT=8
COUNT=10
SPEED=11
LOOP=12
SIZE=14

	opt	o+			
animate_map
	movem.l	d1-4/a0-1,-(a7)
	lea	table(pc),a0		; table of 100 entries
	moveq	#99,d0
anim_lp	move.l	ADDRESS(a0),d4
	beq.s	next			; next if address is 0
	move.b	COUNT(a0),d1
	addq.b	#1,d1			; increase counter
	cmp.b	SPEED(a0),d1
	ble.s	ni			; not up to correct count
	clr.b	d1			; reset counter
	moveq	#0,d2
	move	CURRENT(a0),d2		; current frame
	move	d2,d3
	lsl.l	#7,d2			; multiply by 128
	move.l	d4,a1			; destination address into a1
	move.l	d2,(a1)			; store sprite on map
	addq	#1,d3			; increase current frame
	cmp	END(a0),d3		; reached the last frame ?
	ble.s	nt		
	tst.b	LOOP(a0)
	bne.s	loop
	clr.l	ADDRESS(a0)
	bra.s	next
loop	move	START(a0),d3		; yes, reset first frame	
nt	move	d3,CURRENT(a0)
ni	move.b	d1,COUNT(a0)		; store count
next	lea	SIZE(a0),a0
	dbf	d0,anim_lp
	movem.l	(a7)+,d1-4/a0-1
	rts
	
animate_block
	movem.l	d1-d7/a0-a6,-(a7)
	movem	60(a7),d0-6
	tst	d0
	bmi.s	get_free
	cmp	#100,d0
	bge.s	no_room			; all entries used
found	move	d0,d7
	move.l	76(a7),a0
	and	#$fff0,d1
	lsr	#2,d1			; MUL(X DIV 16,2)
	lsr	#4,d2
	mulu	(a0),d2
	lsl.l	#2,d2			; MUL(Y DIV 16,WIDTH*4)
	add	#10,d1			; add header size
	add	d1,a0
	add.l	d2,a0
	lea	table(pc),a2
	mulu	#SIZE,d0
	add	d0,a2
	move.l	a0,(a2)+		; store address
	move	d3,(a2)+		; start
	move	d4,(a2)+		; end
	move	d5,(a2)+		; current
	clr.b	(a2)+			; count
	move.b	d6,(a2)+		; speed
	move.b	75(a7),(a2)		; loop
no_room	move	d7,d0
	ext.l	d0
	movem.l	(a7)+,d1-d7/a0-a6
	rts
get_free
	lea	table(pc),a2		; find a free entry
	moveq	#0,d0		
	moveq	#99,d7
.gf_lp	tst.l	ADDRESS(a2)
	beq.s	found			; which has a zero address
	addq	#1,d0
	lea	SIZE(a2),a2		; try next entry
	dbf	d7,.gf_lp
	moveq	#-1,d7
	bra.s	no_room

animate_clear
	move.l	a0,-(a7)
	lea	table(pc),a0
	move	8(a7),d0
	bmi.s	.clrall
	cmp	#99,d0
	bgt.s	.error
	mulu	#SIZE,d0
	add	d0,a0
	clr.l	ADDRESS(a0)		; clear individual entry
.error	move.l	(a7)+,a0
	rts
.clrall	moveq	#99,d0			; clear 100 entries
.clrlp	clr.l	ADDRESS(a0)
	lea	SIZE(a0),a0
	dbf	d0,.clrlp
	move.l	(a7)+,a0
	rts
	
table	ds.b	SIZE*100
