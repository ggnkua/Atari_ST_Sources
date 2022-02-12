	.sect .text
	.define ___sigreturn
	.extern __sigreturn

!
! When sending a signal the kernel puts a sigcontext and a sigframe
! on the stack, the sigreturn() call to the kernel will remove it.
! The layout of the stack, when the users signal handler is called:
!
!    Program Stack		!
! sigcontext scp		!	regs, saved by system.c/do_sendsig()
! struct sigcontext *sf_scpcopy !	pointer to scp (second copy)
! void (*sf_retadr2)(void)	!	program counter, when signal arrived
! int sf_fp;			!
! struct sigcontext *sf_scp	!	pointer to scp
! int sf_code			!
! int sf_signo			!	signal number
! void (*sf_retadr)(void)	!	pointer to users sigreturn function
				!	provided by sigaction().
				! This is ___sigreturn!

! The function __sigreturn (lib/posix/_sigreturn.c) expects one
! Argument, a Pointer to a sigcontext. So we have to do exactly nothing
! here but to call __sigreturn() directly. The two ints "sf_code" and
! "sf_signo" interprets __sigreturn() as return PC and does not touch them.
! __sigreturn() does not return, instead, the program gets continued
! at the point where the signal occured.

! In Minix 1.6.25 the sigframe structure didn't have the "sf_fp" and
! "sf_retadr2" fields. Removing "sf_code" and "sf_signo" didn't do any
! harm because there is a copy of the pointer to sigcontext...

___sigreturn: 
!	add.l	#4,sp	! remove intno and code
	jmp __sigreturn

