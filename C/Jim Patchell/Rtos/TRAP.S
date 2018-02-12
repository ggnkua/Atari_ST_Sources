
	XDEF Trap1
	.FREF _cio,4

#define	ADD_HANDLER	1	/*	add handler to device table	*/
#define	OPEN		3	/*	open a device		*/
#define READ		5	/*	read a buffer		*/
#define	GETC		7	/*	get a character		*/
#define WRITE		9	/*	write a buffer		*/
#define	PUTC		11	/*	put a character		*/
#define	CLOSE		12	/*	close a device		*/
#define	STATUS		13	/*	get device status	*/

	SECTION	code


;**************************************************************************
;
; Trap1
;
; Trap entry point.  Entry through the use of trap #1 function
;
; gets the status register off of the stack
; determines if system is in supervisor or user mode
; locates a posible parameter area
; pushes the pointer to the parameter area onto the stack
; Call the routine that is going to handle this trap
;
; copyright (c) 1998,2000 Jim Patchell
;
;**************************************************************************

Trap1
	move.w		(a7),d0					;get status register from stack
	btst.l		#13,d0					;test suppervisor bit
	beq.s		UserMode				;if not supevisor, user mode
	lea			6(a7),a0				;load a0 with address of parameters
	bra.s		Trap0_1
UserMode
	move.l		usp,a0					;load user stack pointer to a0
Trap0_1
	move.l		(a0),-(a7)				;push parameter pointer onto stack
	jsr			_cio					;call cio processing routine
	rte

	;*************************************************************
	; long AddHandler(char *dev_name,H_JVEC *jump_table);
	;
	; This function is passed 8 bytes, and the compiler treats it
	; like 8 bytes, but we clean up 10 bytes from stack
	;*************************************************************

	.FDEF _AddHandler,8

_AddHandler
	move.l	(a7)+,d0					;remove return address
	move.w	#ADD_HANDLER,-(a7)			;push command on stack add handler
	move.l	a7,a0						;pointer to top of params
	move.l	d0,-(a7)					;push return address back on stack
	move.l	a0,-(a7)					;push param pointer onto stack
	trap	#1							;call CIO
	addq.l	#4,a7						;clean up stack
	move.l	(a7)+,a0					;pop return address
	lea		10(a7),a7					;clean up stack
										;8 bytes were passed
										;we added another 2 bytes hear
	jmp		(a0)						;return from subroutine

	;**************************************************************
	; int Open(char *dev_name,int mode);
	;
	; This function get gets 6 bytes and the compiler treats it like
	; 6 bytes, but we clean up 8 from stack because we add 2
	;**************************************************************

	.FDEF	_Open,6

_Open
	move.l	(a7)+,d0				;remove return address
	move.w	#OPEN,-(a7)				;push OPEN command on stack
	move.l	a7,a0					;pointer to top of params on stack
	move.l	d0,-(a7)				;push return address back on stack
	move.l	a0,-(a7)				;push param pointer onto stack
	trap	#1						;call CIO
	addq.l	#4,a7					;clean up stack
	move.l	(a7)+,a0				;pop return address
	lea		8(a7),a7				;clean up stack
	jmp		(a0)					;return from subroutine

	;****************************************************************
	;int Close(int handle);
	;
	; This function get 2 bytes and the compiler treats it like 2
	; bytes, but we clean up 4 bytes from stack becasue we add 2
	;****************************************************************

	.FDEF _Close,2

_Close
	move.l	(a7)+,d0				;remove return address
	move.w	#CLOSE,-(a7)			;push CLOSE command on stack
	move.l	a7,a0					;pointer to top of params on stack
	move.l	d0,-(a7)				;push return address back on stack
	move.l	a0,-(a7)				;push param pointer onto stack
	trap	#1						;call CIO
	addq.l	#4,a7					;clean up stack
	move.l	(a7)+,a0				;pop return address
	addq.l	#4,a7					;clean up stack
	jmp		(a0)					;return from subroutine

	;*******************************************************************
	;int GetC(int handle);
	;
	;This function gets 2 bytes and the compiler treats it like 2 bytes
	;but we clean up 4 bytes from the stack because we add 2
	;
	;*******************************************************************

	.FDEF	_Getc,2

_Getc
	move.l	(a7)+,d0				;remove return address
	move.w	#GETC,-(a7)				;push GETC command on stack
	move.l	a7,a0					;pointer to top of params on stack
	move.l	d0,-(a7)				;push return address back on stack
	move.l	a0,-(a7)				;push param pointer onto stack
	trap	#1						;call CIO
	addq.l	#4,a7					;clean up stack
	move.l	(a7)+,a0				;pop return address
	addq.l	#4,a7					;clean up stack
	jmp		(a0)					;return from subroutine

	;*******************************************************************
	;int PutC(int handle,int c);
	;
	; This function get 4 bytes and the compiler treats it like 4 bytes
	; but we clean up 6 bytes from the stack because we add 2
	;*******************************************************************

	.FDEF	_Putc,4

_Putc
	move.l	(a7)+,d0				;remove return address
	move.w	#PUTC,-(a7)				;push PUTC command on stack
	move.l	a7,a0					;pointer to top of params on stack
	move.l	d0,-(a7)				;push return address back on stack
	move.l	a0,-(a7)				;push param pointer onto stack
	trap	#1						;call CIO
	addq.l	#4,a7					;clean up stack
	move.l	(a7)+,a0				;pop return address
	addq.l	#6,a7					;clean up stack
	jmp		(a0)					;return from subroutine

	;********************************************************************
	;int Status(int handle,char *buff,long count,int aux);
	;
	; This function gets 12 bytes and the compiler treats it like 12 bytes
	; but we clean up 14 bytes from the stack because we add 2
	;********************************************************************

	.FDEF	_Status,12

_Status
	move.l	(a7)+,d0				;remove return address
	move.w	#STATUS,-(a7)			;push STATUS command on stack
	move.l	a7,a0					;pointer to top of params on stack
	move.l	d0,-(a7)				;push return address back on stack
	move.l	a0,-(a7)				;push param pointer onto stack
	trap	#1						;call CIO
	addq.l	#4,a7					;clean up stack
	move.l	(a7)+,a0				;pop return address
	lea.l	14(a7),a7				;clean up stack
	jmp		(a0)					;return from subroutine

	;********************************************************************
	;int StatusO(char *buff,long count,int aux,char *name);
	;
	; This function gets 14 bytes and the compiler treats it like 14 bytes
	; but we clean up 18 bytes from the stack because we add 4
	;********************************************************************

_StatusO
	move.l	(a7)+,d0				;remove return address
	move.w	#-1,-(a7)				;push negative handle on stack
	move.w	#STATUS,-(a7)			;push STATUS command on stack
	move.l	a7,a0					;pointer to top of params on stack
	move.l	d0,-(a7)				;push return address back on stack
	move.l	a0,-(a7)				;push param pointer onto stack
	trap	#1						;call CIO
	addq.l	#4,a7					;clean up stack
	move.l	(a7)+,a0				;pop return address
	lea.l	18(a7),a7				;clean up stack
	jmp		(a0)					;return from subroutine

	;********************************************************************
	;long Xio(int cmd,int handle,char *name,char *buff,long count,int aux,...);
	;
	; We dont have to push anything extra onto the stack for this function
	;
	; Xio requires that a variable number of parameters can be passed
	; so the calling function will clean up this stack mess
	;********************************************************************

	XDEF	_Xio

_Xio
	pea		4(a7)					;push start of param area onto stack
	trap	#1						;call CIO
	addq.l	#4,a7					;clean up stack
	rts

	;********************************************************************
	;long Read(int handle,char *buff,long count);
	;
	; This function gets 10 bytes and the compiler treats it like 10 bytes
	; but we clean up 12 bytes from the stack because we add 2
	;********************************************************************


	.FDEF	_Read,10

_Read
	move.l	(a7)+,d0				;remove return address
	move.w	#READ,-(a7)				;push READ command on stack
	move.l	a7,a0					;pointer to top of params on stack
	move.l	d0,-(a7)				;push return address back on stack
	move.l	a0,-(a7)				;push param pointer onto stack
	trap	#1						;call CIO
	addq.l	#4,a7					;clean up stack
	move.l	(a7)+,a0				;pop return address
	lea.l	12(a7),a7				;clean up stack
	jmp		(a0)					;return from subroutine

	;********************************************************************
	;long Write(int handle,char *buff,long count);
	;
	; This function gets 10 bytes and the compiler treats it like 10 bytes
	; but we clean up 12 bytes from the stack because we add 2
	;********************************************************************


	.FDEF	_Write,10
_Write
	move.l	(a7)+,d0				;remove return address
	move.w	#WRITE,-(a7)			;push WRITE command on stack
	move.l	a7,a0					;pointer to top of params on stack
	move.l	d0,-(a7)				;push return address back on stack
	move.l	a0,-(a7)				;push param pointer onto stack
	trap	#1						;call CIO
	addq.l	#4,a7					;clean up stack
	move.l	(a7)+,a0				;pop return address
	lea.l	12(a7),a7				;clean up stack
	jmp		(a0)					;return from subroutine

