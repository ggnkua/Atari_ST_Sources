;
; Bit plane clearer. Clears a selected number of screen bit planes.
;
;	~C:clr_planes(bit mask,L:screen)
;
; ------- Copyright Terry King Ninth Wave Software 1993-95 -------

	opt	o+		; optimise on, removes unwanted 0(A1)
clr_planes
	movem.l	d1-7/a0-6,-(a7)
	move	60(a7),d0
	add	d0,d0
	lea	lookup(pc),a2	; look up table of 16 routines
	move	(a2,d0.w),d0
	lea	c0(pc,d0),a2
	move	62(a7),d1
	subq	#1,d1
	move.l	64(a7),a1
.ylp	jsr	(a2)		; clear planes on one line
	dbf	d1,.ylp
	movem.l	(a7)+,d1-7/a0-6
	rts

lookup	dc.w	c0-c0,c1-c0,c2-c0,c3-c0
	dc.w	c4-c0,c5-c0,c6-c0,c7-c0
	dc.w	c8-c0,c9-c0,c10-c0,c11-c0
	dc.w	c12-c0,c13-c0,c14-c0,c15-c0
	
c0	rts

c1off set 0
c1	rept	20
	clr	c1off(a1)
c1off set c1off+8
	endr
	lea	160(a1),a1
	rts

c2off set 2
c2	rept	20
	clr	c2off(a1)
c2off set c2off+8
	endr
	lea	160(a1),a1
	rts

c3off set 0
c3	rept	20
	clr.l	c3off(a1)
c3off set c3off+8
	endr
	lea	160(a1),a1
	rts

c4off set 4	
c4	rept	20
	clr	c4off(a1)
c4off set c4off+8
	endr
	lea	160(a1),a1
	rts

c5off set 0
c5	rept	20
	clr	c5off(a1)
	clr	c5off+4(a1)
c5off set c5off+8
	endr
	lea	160(a1),a1
	rts

c6off set 2
c6	rept	20
	clr.l	c6off(a1)
c6off set c6off+8
	endr
	lea	160(a1),a1
	rts

c7	rept	20
	clr.l	(a1)+
	and.l	#$0000ffff,(a1)+
	endr
	rts

c8off set 6
c8	rept	20
	clr	c8off(a1)
c8off set c8off+8
	endr
	lea	160(a1),a1	
	rts
	
c9off set 0
c9	rept	20
	clr	c9off(a1)
	clr	c9off+6(a1)
c9off set c9off+8
	endr
	lea	160(a1),a1
	rts

c10off set 2
c10	rept	20
	clr	c10off(a1)
	clr	c10off+4(a1)
c10off set c10off+8
	endr
	lea	160(a1),a1
	rts
	
c11off set 0
c11	rept	20
	clr.l	c11off(a1)
	clr	c11off+6(a1)
c11off set c11off+8
	endr
	lea	160(a1),a1
	rts

c12off set 4
c12	rept	20
	clr.l	c12off(a1)
c12off set c12off+8
	endr
	lea	160(a1),a1
	rts

c13off set 0
c13	rept	20
	clr	c13off(a1)
	clr.l	c13off+4(a1)
c13off set c13off+8
	endr
	lea	160(a1),a1
	rts
	
c14off set 2
c14	rept	20
	clr	c14off(a1)
	clr	c14off+4(a1)
c14off set c14off+8
	endr
	lea	160(a1),a1
	rts
	
c15	rept	20
	clr.l	(a1)+
	clr.l	(a1)+
	endr
	rts