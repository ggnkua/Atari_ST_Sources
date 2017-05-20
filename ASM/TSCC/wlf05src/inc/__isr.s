;----------------------------------------------------------
; collection of used interrupt service routines and some
; misc. and handy irq-stuff
;----------------------------------------------------------

; general...

		section	text			
idle_frcount	subq.l #1,$466.w ; dec framecounter
		rte

idle		rte

;----------------------------------------------------------
; this chunk sends a command (d0) to the IKBD
;
;----------------------------------------------------------


send_ikbd       lea.l	$fffffc00.w,a0
wait_ikbd      	btst.b  #1,(a0)		; IKBD ready ?
                beq.s   wait_ikbd
                move.b  d0,2(a0)
                rts

*********************************
*
*  void interrupt TicCounter()
*
* Increment my keyframing variables
*
*********************************

		rsreset
TicCount.TURNSPEED	rs.w	1
TicCount.WALKSPEED	rs.w	1
TicCount.FASTTURN	rs.w	1
TicCount.RUNSPEED	rs.w	1


_Tics		dcb.w	4,0

ticcounter	dc.w	0

TicCountISR	move.l	a0,-(sp)

		lea.l	_Tics(pc),a0
		addi.l	#TURNSPEED<<16|WALKSPEED,(a0)+
		addi.l	#FASTTURN<<16|RUNSPEED,(a0)+

		addq.w	#1,(a0)	; ticcounter
	
		move.l	(sp)+,a0
		rte