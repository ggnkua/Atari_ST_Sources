.sect .text; .sect .data; .sect .bss
.sect .bss
.comm _gtobuf, 12
.sect .text
!
! Warning:  this code depends on the C language declaration of
! jmp_buf in <setjmp.h>, and on the definitions of the flags
! SC_ONSTACK, SC_SIGCONTEXT, and SC_NOREGLOCALS in <sys/sigcontext.h>.
SC_SIGCONTEXT=2
SC_NOREGLOCALS=4
!
! ___setjmp is called with two arguments.  The third argument is pushed
! by compiler generated code transparently to the caller.
!
! ___setjmp(jmp_buf, savemask, retaddr)
!
.extern ___setjmp
___setjmp:
	push	bp
	mov	bp,sp

	push	0(bp)		! frame pointer
	lea	ax, 4(bp)
	push	ax		! stack pointer
	push	8(bp)		! program counter
	
	xor	ax, ax
	push	ax		! signal mask high
	push	ax		! signal mask low
	mov	ax,#SC_NOREGLOCALS	! flags (4 is SC_NOREGLOCALS)
	push	ax

	mov	ax, 6(bp)	! get the savemask arg
	cmp	ax, #0
	je	nosigstate	! don't save signal state

	or	-12(bp), #SC_SIGCONTEXT		! flags |= SC_SIGCONTEXT

	lea	ax, -10(bp)
	push	ax
	push	#0
	push	#0
	call	_sigprocmask	! fill in signal mask
	add	sp, #6

nosigstate:
	mov	bx, 4(bp)	! jmp_buf
	mov	cx, #12		! sizeof(jmp_buf)
	call	.sti		! sp = src addr, bx = dest addr, cx = count
	xor	ax, ax
	jmp	.cret

.extern __longjmp
__longjmp:
	push	bp
	mov	bp, sp

! Copy the jmp_buf to the gtobuf.
	push	4(bp)			! src address
	mov	ax, #_gtobuf
	push	ax			! dst address
	mov	cx, #6			! word count
	call	.blm			! block move			

! Check that this jmp_buf has no saved registers.
	mov 	ax, _gtobuf		! get flags
	test 	ax, #4
	je	__longjerr

! Set up the value to return in ax.
	mov	ax, 6(bp)		! value to return
	or	ax, ax
	jne	nonzero
	mov	ax, #1
nonzero:
	mov	bx, #_gtobuf
	mov	bp, 10(bx)
	mov	sp, 8(bx)
	jmp	@6(bx)

.extern _longjmp
_longjmp:
	push	bp
	mov	bp, sp

! Check that this is a jmp_buf with no saved regs and with signal context info.
	mov	bx, 4(bp)		! pointer to jmp_buf
	mov	ax, 0(bx)		! get the flags
	test 	ax, #4			! check for no saved registers
	je	__longjerr
	test	ax, #2			! check for signal context
	je	__longjerr
	
! Compute the value to return
	mov	ax, 6(bp)		! proposed value to return
	or	ax, ax
	jne	nonzero1
	mov	ax, #1
nonzero1:

! Call _sigjmp to restore the old signal context.
	push	ax
	push	4(bp)
	call	__sigjmp
	add	sp, #4
