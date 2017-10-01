*
*	This routine prints the overlay error message.
*	There are two parameters pushed on the stack before calling
*	this routine: _ov_err(err_msg, filename)
*	char *err_msg;		pointer to the error message string
*	char *filename;		pointer to the file name that cause trouble
*
cconws	= 9			* console string write func code for GEMDOS
pterm0	= 0			* terminate the program func code for GEMDOS
*
.globl	_ov_err
    	.text 
_ov_err:
	move.w	#cconws, -(a7)	*get GEMDOS function number
	trap	#1              *print the message
    	addq.l  #6, a7		*pop parameters

	move.w	#cconws,-(a7)	*set up for BDOS call
	trap	#1		*print the filename
    	addq.l	#6, a7		*pop parameters

cmdrtn: move.w	#pterm0,-(a7)	*get GEMDOS function number
	trap	#1              *terminate the program
    	
    	.end
