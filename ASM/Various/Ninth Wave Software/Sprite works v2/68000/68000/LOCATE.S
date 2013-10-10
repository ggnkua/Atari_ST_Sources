;
; Mapper commands to find flags and change map sprites
;
	bra	locate_flag	; locate flag address
	bra	change_map	; change map sprite
	bra	change_flag	; change flag status
	bra	get_map		; get map sprite
	bra	get_flag	; get flag status

;
; ~C:locate_flag%(x,y,l:map%,l:flags%)
;

locate_flag
	movem.l	d1-2/a0-1,-(a7)
	move	20(a7),d0		; x
	move	22(a7),d1		; y
	move.l	24(a7),a0		; map
	move.l	28(a7),a1		; flags
	lsr	#4,d0			; x/16
	lsr	#4,d1			; y/16
	mulu	(a0),d1			; width*y
	add.l	d1,a1
	add	#64,d0			; add header size
	add	d0,a1
	move.l	a1,d0			; return flag address
	movem.l	(a7)+,d1-2/a0-1
	rts
;
; stat&=C:get_flag%(x,y,l:map%,l:flags%)
;

get_flag
	movem.l	d1-2/a0-1,-(a7)
	move	20(a7),d0	
	move	22(a7),d1	
	move.l	24(a7),a0	
	move.l	28(a7),a1	
	lsr	#4,d0		
	lsr	#4,d1		
	mulu	(a0),d1		
	add.l	d1,a1
	add	#64,d0			; add header size
	add	d0,a1
	moveq	#0,d0
	move.b	(a1),d0			; return flag
	movem.l	(a7)+,d1-2/a0-1
	rts
;
; ~C:change_flag%(x,y,status,l:map%,l:flags%)
;

change_flag
	movem.l	d1-2/a0-1,-(a7)
	movem	20(a7),d0-2
	move.l	26(a7),a0	
	move.l	30(a7),a1	
	lsr	#4,d0		
	lsr	#4,d1		
	mulu	(a0),d1		
	add.l	d1,a1
	add	#64,d0			; add header size
	add	d0,a1
	move.b	d2,(a1)			; set flag status
	movem.l	(a7)+,d1-2/a0-1
	rts

;
; ~C:change_map%(x,y,sprite,l:map%)
;

change_map
	movem.l	d1-d3/a0,-(a7)
	move	20(a7),d0
	move	22(a7),d1
	clr.l	d3
	move	24(a7),d3
	move.l	26(a7),a0
	and	#$fff0,d0
	lsr	#2,d0			; MUL(X DIV 16,2)
	lsr	#4,d1
	mulu	(a0),d1
	lsl.l	#2,d1			; MUL(Y DIV 16,WIDTH*4)
	add	#10,d0			; add header size
	add	d0,a0
	add.l	d1,a0
	lsl.l	#7,d3			; sprite block * 128
	move.l	d3,(a0)			; change map location
	movem.l	(a7)+,d1-d3/a0
	rts
;
; s&=C:get_map%(x,y,l:map%)
;

get_map
	movem.l	d1-d3/a0,-(a7)
	move	20(a7),d0		; x
	move	22(a7),d1		; y
	move.l	24(a7),a0		; map
	and	#$fff0,d0
	lsr	#2,d0			; MUL(X DIV 16,2)
	lsr	#4,d1
	mulu	(a0),d1
	lsl.l	#2,d1			; MUL(Y DIV 16,WIDTH*4)
	add	#10,d0			; add header size
	add	d0,a0
	add.l	d1,a0
	move.l	(a0),d0			; get map sprite
	lsr.l	#7,d0			; divide by 128
	movem.l	(a7)+,d1-d3/a0
	rts
	