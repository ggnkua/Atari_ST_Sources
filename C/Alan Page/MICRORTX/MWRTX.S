/////////////////////////////////////////////////////////////////////////
/									/
/	RTXBIND.S							/
/									/
/	(C) Copyright 1986, Beckemeyer Development Tools		/
/	All Rights Reserved						/
/									/
/	RTX interface to Mark Williams C.  These are re-entrant.	/
/									/
/////////////////////////////////////////////////////////////////////////

.shri
	.globl rtx_install_
rtx_install_:
	move.l 4(sp),-(sp)		/ root basepage address
	move.w $0x00,-(sp)		/ rtx_install
	trap $5				/ enter RTX
	addq.l $6,sp
	rts

	.globl p_create_
p_create_:
	link a6,$0
	move.l 26(a6),-(sp)		/ stack size
	move.l 22(a6),-(sp)		/ stack args
	move.w 20(a6),-(sp)		/ arg word count
	move.l 16(a6),-(sp)		/ load address
	move.w 14(a6),-(sp)		/ slice
	move.w 12(a6),-(sp)		/ priority
	move.l  8(a6),-(sp)		/ name	
	move.w $0x01,-(sp)		/ p_create
	trap $5				/ enter RTX
	unlk a6				/ restore stack 
	rts

	.globl p_delete_
p_delete_:
	move.l 4(sp),-(sp)		/ PID
	move.w $0x02,-(sp)		/ p_delete
	trap $5				/ enter RTX
	addq.l $6,sp			/ restore stack
	rts


	.globl p_priority_
p_priority_:
	link a6,$0
	move.w 12(a6),-(sp)		/ delta
	move.l  8(a6),-(sp)		/ PID
	move.w $0x03,-(sp)		/ p_priority
	trap $5				/ enter RTX
	unlk a6
	rts

	.globl p_slice_
p_slice_:
	link a6,$0
	move.w 12(a6),-(sp)		/ delta
	move.l  8(a6),-(sp)		/ PID
	move.w $0x04,-(sp)		/ p_slice
	trap $5				/ enter RTX
	unlk a6
	rts

	.globl q_create_
q_create_:
	link a6,$0
	move.w 12(a6),-(sp)		/ Q type
	move.l  8(a6),-(sp)		/ Q name
	move.w $0x05,-(sp)		/ q_create
	trap $5				/ enter RTX
	unlk a6
	rts

	.globl q_delete_
q_delete_:
	move.l 4(sp),-(sp)		/ QID
	move.w $0x06,-(sp)		/ q_delete
	trap $5				/ enter RTX
	addq.l $6,sp
	rts

	.globl q_send_
q_send_:
	link a6,$0
	move.l 12(a6),-(sp)		/ messsage buffer
	move.l  8(a6),-(sp)		/ QID
	move.w $0x07,-(sp)		/ q_send	
	trap $5				/ enter RTX
	unlk a6
	rts

	.globl q_req_
q_req_:
	link a6,$0
	move.l 18(a6),-(sp)		/ timeout
	move.w 16(a6),-(sp)		/ nowait option
	move.l 12(a6),-(sp)		/ message buffer
	move.l 8(a6),-(sp)		/ QID
	move.w $0x08,-(sp)		/ q_req
	trap $5				/ enter RTX
	unlk a6
	rts

	.globl q_jam_
q_jam_:
	link a6,$0
	move.l 12(a6),-(sp)		/ messsage buffer
	move.l  8(a6),-(sp)		/ QID
	move.w $0x09,-(sp)		/ q_jam
	trap $5				/ enter RTX
	unlk a6
	rts

	.globl e_signal_
e_signal_:
	link a6,$0
	move.w 12(a6),-(sp)		/ event
	move.l  8(a6),-(sp)		/ PID
	move.w $0x0a,-(sp)		/ e_signal
	trap $5				/ enter RTX
	unlk a6
	rts

	.globl e_wait_
e_wait_:
	link a6,$0
	move.l 14(a6),-(sp)		/ timeout
	move.w 12(a6),-(sp)		/ condition
	move.l  8(a6),-(sp)		/ event buffer
	move.w $0x0b,-(sp)		/ e_wait
	trap $5				/ enter RTX
	unlk a6
	rts

	.globl p_pause_
p_pause_:
	move.l 4(sp),-(sp)		/ timeout
	move.w $0x0c,-(sp)		/ p_pause
	trap $5				/ enter RTX
	addq.l $6,sp
	rts

	.globl m_alloc_
m_alloc_:
	move.l 4(sp),-(sp)		/ size
	move.w $0x0d,-(sp)		/ m_alloc
	trap $5				/ enter RTX
	addq.l $6,sp
	rts

	.globl m_free_
m_free_:
	move.l 4(sp),-(sp)		/ segment
	move.w $0x0e,-(sp)		/ m_free
	trap $5				/ enter RTX
	addq.l $6,sp
	rts

	.globl m_assign_
m_assign_:
	link a6,$0
	move.l 12(a6),-(sp)		/ PID
	move.l  8(a6),-(sp)		/ segment
	move.w $0x0f,-(sp)		/ m_assign
	trap $5				/ enter RTX
	unlk a6
	rts

	.globl p_lookup_
p_lookup_:
	move.l 4(sp),-(sp)		/ name
	move.w $0x10,-(sp)		/ p_lookup
	trap $5				/ enter RTX
	addq.l $6,sp
	rts

	.globl q_lookup_
q_lookup_:
	move.l 4(sp),-(sp)		/ Q name
	move.w $0x11,-(sp)		/ q_lookup
	trap $5				/ enter RTX
	addq.l $6,sp
	rts

	.globl p_vector_
p_vector_:
	link a6,$0
	move.l 12(a6),-(sp)		/ vector
	move.l 8(a6),-(sp)		/ PID
	move.w $0x13,-(sp)		/ p_vector
	trap $5				/ enter RTX
	unlk a6
	rts

	.globl p_suspend_
p_suspend_:
	link a6,$0
	move.l 8(a6),-(sp)		/ PID
	move.w $0x14,-(sp)		/ p_suspend
	trap $5				/ enter RTX
	unlk a6
	rts


	.globl p_resume_
p_resume_:
	link a6,$0
	move.l 8(a6),-(sp)		/ PID
	move.w $0x15,-(sp)		/ p_resume
	trap $5				/ enter RTX
	unlk a6
	rts

	.globl d_install_
d_install_:
	link a6,$0
	move.l 30(a6),-(sp)		/ cntrl
	move.l 26(a6),-(sp)		/ costat
	move.l 22(a6),-(sp)		/ conout
	move.l 18(a6),-(sp)		/ conin
	move.l 14(a6),-(sp)		/ constat
	move.l 10(a6),-(sp)		/ name
	move 8(a6),-(sp)		/ unit
	move $0x16,-(sp)			/ d_install
	trap $5				/ enter RTX
	unlk a6
	rts

	.globl d_cntrl_
d_cntrl_:
	link a6,$0
	move.l 10(a6),-(sp)		/ long word parameter
	move.w 8(a6),-(sp)		/ unit number
	move.w $0x17,-(sp)		/ d_cntrl
	trap $5				/ enter RTX
	unlk a6
	rts


	.globl q_info_
q_info_:
	link a6,$0
	move.l 16(a6),-(sp)		/ num proc
	move.l 12(a6),-(sp)		/ num msg
	move.l 8(a6),-(sp)		/ qid
	move.w $0x18,-(sp)		/ q_info
	trap $5				/ enter RTX
	unlk a6
	rts


	.globl rtx_remove_
rtx_remove_:
	move.w $0xff,-(sp)		/ rtx_remove
	trap $5				/ enter RTX
	addq.l $2,sp
	rts

/////////////////////////////////////////////////////////////////////////
/									/
/	BIOS, XBIOS, and GEMDOS re-entrant interface for RTX		/
/									/
/////////////////////////////////////////////////////////////////////////
	.shri
	.globl bios_
bios_:
	move $201,-(sp)
	trap $5			/ save real return address
	addq.l $6,sp		/ pop return off stack
	trap $13
	move.l d0,-(sp)		/ save return value
	move $203,-(sp)
	trap $5			/ save real return address
	addq.l $2,sp
	movea.l d0,a0
	move.l (sp)+,d0		/ set up return value
	jmp (a0)


	.globl xbios_
xbios_:
	move $201,-(sp)
	trap $5			/ save real return address
	addq.l $6,sp		/ pop return off stack
	trap $14
	move.l d0,-(sp)		/ save return value
	move $203,-(sp)
	trap $5			/ save real return address
	addq.l $2,sp
	movea.l d0,a0
	move.l (sp)+,d0		/ set up return value
	jmp (a0)


	.globl gemdos_
gemdos_:
	move $201,-(sp)
	trap $5			/ save real return address
	addq.l $6,sp		/ pop return off stack
	trap $1	
	move.l d0,-(sp)		/ save return value
	move $203,-(sp)
	trap $5			/ save real return address
	addq.l $2,sp
	movea.l d0,a0
	move.l (sp)+,d0		/ set up return value
	jmp (a0)
