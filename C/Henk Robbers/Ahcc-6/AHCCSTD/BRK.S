****
*
*	Heap management functions
*

*
* entry points
*
.globl	_brk
.globl	_sbrk

*
* external references
*
.globl	ebss
.globl	_break

.text
*
* int brk(void *addr)
*
* Set _break (the point where heap and stack meet) to <addr>.
* Return 0 for success, -1 for failure.
*
brk:
*							  new break is in a0
	move.l	a0,d0
	cmp.l	ebss,d0			; if (new break < end of BSS)
	blt 	brkerr			;   error
	add.l	#$100,d0
	cmp.l	d0,sp			; if ((new break + 256) > sp)
	bgt 	l0
brkerr:						;   error, bad break location
	moveq	#-1,d0
	rts						; return error -1
l0:
	move.l	a0,_break		; set new break
	clr 	d0
	rts 					; return status ok

*
* char *sbrk(size_t amount)
*
* Move _break by <amount> bytes.
* Return a pointer to the old _break for success, NULL for failure.
*
sbrk:
*							   amount is in d0
	move.l	_break,a1		; save old _break
	move.l	a1,a0			; calculate new break
	adda.l	d0,a0
	jsr 	brk				; call brk() to set new break
	tst.w	d0				; if brk() returned an error
	beq 	l1
	clr.l	a1				;   set old _break to NULL
l1:
	move.l	a1,a0
	rts 					; return old _break

.end
