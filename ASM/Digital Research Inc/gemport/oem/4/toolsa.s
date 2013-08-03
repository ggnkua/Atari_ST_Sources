*  toolsa.s - assembly language tools routines				*


*
*  globals
*
	.xref	_inp
	.xref	_outp

***************************************************************************
*  inp -
*	input a byte from the specified port.
*  synopsis:
*	BYTE	inp() ;
*	BYTE	*port ;		/*  port address			*/
*	BYTE	ch ;
*	ch = inp( port ) ;
*

_inp:	movea.l	4(sp),a0	*  get port address
	clr.l	d0		*  clear return reg
	move.b	(a0),d0		*  input from port
	rts
	
***************************************************************************
*  outp -
*	output a byte to the specified port
*  synopsis:
*	VOID	outp() ;
*	BYTE	data ;
*	BYTE	*port ;		/*  port address			*/
*	outp( data , port ) ;
*

_outp:	movea.l	6(sp),a0	*  get port address
	move.b	5(sp),(a0)	*  output data to port
	rts


