* Metamorph by Mark Kimball
* (C) Copyright 1990 by Antic Publishing, Inc.
*
*	machine-code stuff to help exit from any
*	level of meta, for fatal error handling

* this file also contains some routines to take care of the
* odd .3D2 file format which ensures that integer data will
* fall across word boundarys if using raw .3D2 data (!)


	.globl _f_init,_fatal
	.globl _wfetch,_wput

* routine to initialize the fatal-error handler.
* Normal usage in a C program might go something like this:

* if(f_init() == TRUE)
*  goto fail;
*  rest of startup code

* fail:
*  cleanup code to release memory, reset flags, etc
*
*  A call which will cause execution of the code starting at 'fail':
*  fatal();
*  (this call can be used at any subroutine level, although NOT from inside
*  an interrupt-handler), without causing stack overflow problems.

_f_init:

	move.l (sp),a0		reentry address
	move.l a0,vector		save it
	move.l a6,vector+4	save frame-pointer
	clr.l d0		return FALSE
	rts

_fatal:
	move.l vector,a0	address to execute
	move.l vector+4,a6	restore frame-pointer
	move.l #1,d0		return TRUE
	jmp (a0)


* wfetch(ptr) returns an int.  It probably will start at an odd address
_wfetch:

	move.l 4(sp),a0
	move.b (a0)+,d0
	asl.w #8,d0
	move.b (a0),d0
	rts

* wput(source,dest) sets (dest) equal to source value.  will work with
*                   odd addresses

_wput:
	move.w 4(sp),d0
	move.l 6(sp),a0

	move.b d0,(a0)+
	lsr.w #8,d0
	move.b d0,(a0)
	rts


vector:
	ds.l 2

