****
*
*	alloca()	-- allocate memory from the stack (NOT the heap)
*

*
* entry points
*
.globl	_alloca

*
* external references
*
.globl	__break

.text
*
* char *alloca(size)
*   int size;
*
* Allocate <size> bytes from the stack.  This space is automatically
* free'd when the calling function exits.  DO NOT use other memory
* management function, like free() and realloc(), with this block.
*
_alloca:
	clr.l	d0			* set initial return value
	move.l	(sp),a1			* save return address
	clr.l	d1			* get requested block size
	move.w	4(sp),d1
	move.l	sp,a0			* calculate new sp
	sub.l	d1,a0
	cmp.l	__break,a0		* if (new sp < __break)
	blt	ealloca			*   error, potential stack overflow
	move.l	a0,sp			* set new sp
	move.w	d1,(a0)+		* store dummy word
	move.l	a1,(a0)+		* store dummy long
	move.l	a0,d0			* return pointer to memory block
ealloca:
	jmp	(a1)			* "return" to caller
