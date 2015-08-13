;==================================
;
; CREATE BUFFER
;
; INPUTS
; D0 = len bytes
;
; RETURNS:
; D0 = (success) pointer
;    = (failure) null
;
;
;==================================	

make_buff:
		movem.l	d1-d7/a0-a6,-(a7)
	  	move.l	d0,-(a7)
		move.w	#72,-(a7)
		trap	#1
		addq.w	#6,a7
		movem.l	(a7)+,d1-d7/a0-a6
		rts
END_make_buff:



;==================================
;
; FREE BUFFER
;
; INPUTS
; A0 = buffer
;
; RETURNS:
; D0 = (success) E_OK 0 
;      (fail) negative err   
;
;==================================	


free_buff:
	movem.l	d1-d7/a0-a6,-(a7)
	move.l	(a0),-(sp)
	move.w	#$49,-(sp)
	trap 	#1
	addq.   #6,sp
	movem.l	(a7)+,d1-d7/a0-a6
	rts
END_free_buff:


;;;;; sector padding
; boot sector capacity gets exceeded, from here on it's stored
; in another sector
;

;==================================
;
; SHRINK ALLOCATED MEMORY (mshrink)
;
; INPUTS
; A0 = &(end of new stack)
; A1 = &(where to return)
;
; RETURNS:
; D0 = (success) E_OK 0
;      (fail) negative err
; A5 = &old stack
; SP = &end of new stack
;
;==================================

mshrink:
		move.l sp,a5
	        move.l a0,sp			
		movem.l	d1-d7/a0-a4/a6,-(a7)

				   ; calculate program and data size for TOS - to free unused space
		movea.l 4(a5),a5   ; a5 points 100bytes below program start
		move.l $c(a5),d0
		add.l $14(a5),d0
		add.l $1c(a5),d0
		add.l #$100,d0
		move.l d0,-(sp)
		move.l a5,-(sp)
		move.w #0,-(sp)
		move.w #$4a,-(sp)
		trap #1	          	; SETBLOCK Gemdos
		add.l #12,sp      	; correct stack
		movem.l	(a7)+,d1-d7/a0-a4/a6
		jmp	(a1)
END_mshrink: