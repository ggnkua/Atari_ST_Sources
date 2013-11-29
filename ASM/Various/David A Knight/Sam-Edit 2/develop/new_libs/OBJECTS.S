	SECTION	data

; Object structure
	rsreset
objectNext	rs.w	1
objectHead	rs.w	1
objectTail	rs.w	1
objectType	rs.w	1
objectFlags	rs.w	1
objectStatus	rs.w	1
objectSpec	rs.w	2
objectX	rs.w	1
objectY	rs.w	1
objectW	rs.w	1
objectH	rs.w	1
objectSize	rs.w	0

; Tedinfo structure
	rsreset
te_ptext	rs.l	1
te_ptmplt	rs.l	1
te_pvalid	rs.l	1
te_font	rs.w	1
te_resvd1	rs.w	1
te_just	rs.w	1
te_colour	rs.w	1
te_resvd2	rs.w	1
te_thickness	rs.w	1
te_txtlen	rs.w	1
te_tmplen	rs.w	1

	SECTION	bss
objectTextCursor	ds.w	1

	SECTION	text
;----------------------------------------------------------
positionObject	; x,y, = d1,d2
		; object id=d0
	movem.l	d0-d7/a0-a6,-(sp)

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	mulu	#24,d0
	ext.l	d0
	add.l	d0,a0

	move.w	d1,objectX(a0)
	move.w	d2,objectY(a0)

	movem.l	(sp)+,d0-d7/a0-a6
	rts
;----------------------------------------------------------
typeObjectCheck	; object index in d0
		; flag to check in d2
		; returns result in d1
	movem.l	d0/d2-d7/a0-a6,-(sp)

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	mulu	#24,d0
	ext.l	d0
	add.l	d0,a0

	move.w	objectFlags(a0),d1
	and.w	d2,d1

	movem.l	(sp)+,d0/d2-d7/a0-a6
	rts
;----------------------------------------------------------
specialTypeObjectCheck	; object index in d0
		; type to check in d2
		; returns result in d1
	movem.l	d0/d2-d7/a0-a6,-(sp)

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	mulu	#24,d0
	ext.l	d0
	add.l	d0,a0

	move.w	objectType(a0),d1
	cmp.w	d2,d1
	beq	.done

	moveq.w	#0,d1
.done
	movem.l	(sp)+,d0/d2-d7/a0-a6
	rts
;----------------------------------------------------------
selectObject		; object index in d0
		; returns state in d1
	movem.l	d0/d2-d7/a0-a6,-(sp)

	move.w	d0,d2
	beq	.done

	move.l	dialogTableAddress,a0
	move.l	a0,a1
	move.l	dialogResource(a0),a0
	mulu	#24,d0
	ext.l	d0
	add.l	d0,a0

	move.w	objectStatus(a0),d1
	eor.w	#1,d1
	move.w	d1,objectStatus(a0)
	move.w	d1,-(sp)

	objc_offset	d2,dialogResource(a1)

	move.w	intout+2,d1
	move.w	intout+4,d2
	move.w	objectW(a0),d3
	move.w	objectH(a0),d4
	move.w	dialogHandle(a1),d0
	subq.w	#4,d1
	subq.w	#4,d2
	addq.w	#8,d3
	addq.w	#8,d4
	bsr	generalRedrawHandler

	move.w	(sp)+,d1
.done
	movem.l	(sp)+,d0/d2-d7/a0-a6
	rts
;----------------------------------------------------------
findNextEditable
;                      d0 = current editable object
;                      d1 = object to start check at
;                      d2 = objects flags
;
; returns object (or -1) in d0

	movem.l	d1-d7/a0-a6,-(sp)

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a1

	tst.w	d2
	beq	.noCurrent
	tst.w	d0
	bmi	.noCurrent

	objc_edit	d0,#0,objectTextCursor,#3,a1
	moveq.w	#-1,d0
.noCurrent
	move.w	d1,d2
	mulu	#24,d2
	ext.l	d2
	add.l	d2,a1
	move.w	objectFlags(a1),d2
	andi.w	#32,d2
	bne	.notFound
.loop
	addq.w	#1,d1
	add.l	#24,a1
	move.w	objectFlags(a1),d2
	move.w	d2,d3
	andi.w	#8,d2
	bne	.found
	andi.w	#32,d3
	bne	.notFound
	bra	.loop

.found
	move.w	d1,d0
.notFound
	tst.w	d0
	bpl	.set

	move.w	dialogEdit(a0),d1
	ble	.done
	objc_edit	d1,#0,#0,#1,dialogResource(a0)
	move.w	intout+2,objectTextCursor
.set
	move.w	d0,dialogEdit(a0)
	objc_edit	d0,#0,#0,#1,dialogResource(a0)

	move.w	intout+2,objectTextCursor
.done
	movem.l	(sp)+,d1-d7/a0-a6
	rts
;----------------------------------------------------------
findPreviousEditable
;                      d0 = current editable object
;                      d1 = object to start check at
;                      d2 = objects flags
;
; returns object (or -1) in d0

	movem.l	d1-d7/a0-a6,-(sp)

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a1

	tst.w	d0
	bmi	.done

	objc_edit	d0,#0,objectTextCursor,#3,a1

	move.w	d1,d2
	mulu	#24,d2
	ext.l	d2
	add.l	d2,a1

	tst.w	d1
	beq	.done
.loop
	subq.w	#1,d1
	sub.l	#24,a1
	move.w	objectFlags(a1),d2
	andi.w	#8,d2
	bne	.found
	tst.w	d1
	beq	.notFound
	bra	.loop

.found
	move.w	d1,d0
.notFound
	tst.w	d0
	bpl	.set

	move.w	dialogEdit(a0),d0
.set

	move.w	d0,dialogEdit(a0)
	objc_edit	d0,#0,#0,#1,dialogResource(a0)

	move.w	intout+2,objectTextCursor
.done
	movem.l	(sp)+,d1-d7/a0-a6
	rts
;----------------------------------------------------------