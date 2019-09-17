*****************************************
* Routine name	: OBJC_STATUS		*
* Function	: To obtain the status	*
* of objects within the Resource Tree	*
* ------------------------------------- *
* Programmer	: Martyn Armitage	*
* Generates	:P.I.C.			*
* Written	: 01/12/1987		*
* Updated	: 12/06/1989		*
*****************************************

* get the status of an object
* pass the tree index in D0.w and the object index no in D1.w
*  - OR -
* pass D0.w = 0 and the tree address in A0
* returns with :
* the status of the object in D0.w
* flags in D1.w
* object list address in A0
* and  ted_info / string pointer in A1
* if an error occured then D0.w	= -1 ($ffff)

objc_status	movem.l	d2-d7/a2-a6,-(sp)	save reg's
		tst.w	d0			index passed ?
		beq.s	tree_addr_got		no, address is tho
find_address	clr.w	int_in(a6)		tree structure
		move.w	d0,int_in+2(a6)		index no of tree
		move.w	d1,-(sp)		save d1
		gem	RSRC_GADDR		go do it
		move.w	(sp)+,d1		get d1	back
		tst.w	d0			error ?
		beq.s	gaddr_error		yes
		move.l	addr_out(a6),a0		get tree address
tree_addr_got	and.l	#$ffff,d1		clear hi word
		beq.s	gaddr_error		no 0 index
		mulu	#24,d1			get offset of object
		add.l	d1,a0			address of object table
		move.w	8(a0),d1		get flags
		move.w	10(a0),d0		get status
		move.l	12(a0),a1		ted_info/string address
		bra.s	objc_stat_out		return
gaddr_error	move.w	#-1,d0			error
objc_stat_out	movem.l	(sp)+,d2-d7/a2-a6	get reg's back
		rts

update_index	rs.w	1	index of exit object
start_ob	rs.w	1	object to start drawing at
depth		rs.w	1	depth to draw
edit_text_index	rs.w	1	index of editable text
dial_coords	rs.w	4	coords of dialog box
d_temp_address	rs.l	1	temp storage for tree address

