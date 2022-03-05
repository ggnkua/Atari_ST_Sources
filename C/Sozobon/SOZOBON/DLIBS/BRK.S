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
.globl	_end
.globl	__break

.text
*
* int brk(addr)
*   char *addr;
*
* Set _break (the point where heap and stack meet) to <addr>.
* Return 0 for success, -1 for failure.
*
_brk:
	move.l	4(sp),a0		* get new break
	move.l	a0,d0
	cmp.l	_end,d0			* if (new break < end of BSS)
	blt	brkerr			*   error
	add.l	#$100,d0
	cmp.l	d0,sp			* if ((new break + 256) > sp)
	bgt	setbrk
brkerr:					*   error, bad break location
	move.l	#-1,d0
	rts				* return error -1
setbrk:
	move.l	a0,__break		* set new break
	clr.l	d0
	rts				* return status ok

*
* char *sbrk(amount)
*   int amount;
*
* Move _break by <amount> bytes.
* Return a pointer to the old _break for success, NULL for failure.
*
_sbrk:
	move.w	4(sp),d0		* get amount
	ext.l	d0
	move.l	__break,a1		* save old _break
	add.l	a1,d0			* calculate new break
	move.l	d0,-(sp)
	jsr	_brk			* call brk() to set new break
	addq.l	#4,sp
	tst.w	d0			* if brk() returned an error
	beq	sbrk
	clr.l	a1			*   set old _break to NULL
sbrk:
	move.l	a1,d0
	rts				* return old _break

.end
