*
*	Overlay error message output routine. 
*	This version is for text mode.  Use overrg.c
*	for the graph mode.  When _ov_err is invoked,
*	two parameters are pushed on stack, they are
*	address of error message and address of file name.
*
cconws	= 9	* console string write func code
pterm0 	= 0	* terminate the program func code
*
.globl	_ov_err
    	.text
_ov_err:
    	movea.l	(a7)+, a6	* save the return address.
*	print the error message.
    	move.l	#crlf,	-(a7)	* print cr & lf
    	move.w #cconws, -(a7)	* gemdos func to write string on console.
    	trap	#1		* make the call
    	addq.l	#6, a7		* pop the parameters.
    	move.w #cconws, -(a7)	* gemdos func to write string on console.
    	trap	#1		* make the call
    	addq.l	#6, a7		* pop the parameters.
* 	print the file name.
    	move.w 	#cconws, -(a7)	
    	trap 	#1
    	addq.l	#6, a7
    	move.l a6, -(a7)
    	rts
    	.data
    	.even
crlf:	.dc.b	13,10,0
   	.end
