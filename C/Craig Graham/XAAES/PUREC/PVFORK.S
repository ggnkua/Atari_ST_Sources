; pvfork.s dated 02/22/96
;
; Author:
; Thomas Binder
; (binder@rbg.informatik.th-darmstadt.de)
;
; Purpose:
; Frontend for the MiNT-call Pvfork, which can't be called with a
; simple subroutine. Just put it _in front_ of mintlib.lib in your
; project files.
;
; History:
; 02/21-
; 02/22/96: Creation

	export	Pvfork

module Pvfork
; First, save register a2
	pea		(a2)
	move.w	#$113,-(sp)		; Pvfork
	trap	#1
	addq.l	#2,sp
	tst.w	d0
	beq.s	child
; In the parent, we just restore a2 and return
	move.l	(sp)+,a2
	rts
child:
; In the child, we have a problem: Since Pvfork is called as a
; subroutine, a2 and the return address have to popped from the stack
; to return to the calling routine. This routine now calls at least
; Pterm or Pexec, which pushes new values on the stack, thus
; destroying the value of a2 and the return address of the parent's
; Pvfork-call. So, we must set up a temporary stack to avoid this.
; Of course, we also have to copy some bytes of the original stack,
; because Pure C keeps many local variables there (other compilers
; sure do the same...)

; 256 bytes of temporary stack should be enough in most cases; but if
; the calling function has many local arrays, it might as well be too
; little...
	equ		tmp_stksiz,$100

	move.l	sp,a0
	lea		-tmp_stksiz(a0),sp	; Bug: No stack checking here
	moveq	#4,d1
	moveq	#0,d2
loop:
	move.l	(a0,d1.w),(sp,d2.w)
	addq.w	#4,d1
	addq.w	#4,d2
	cmpi.w	#tmp_stksiz,d2
	bne.s	loop
	move.l	(a0),a2
	rts
