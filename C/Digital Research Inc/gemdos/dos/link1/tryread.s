.globl _readg

fread	= 63		* 3f, f_read gemdos func code
fseek	= 66		* 0x42, f_seek gemdos func code
bufsize = 128		* buffer size
hdsize	= 28		* file header size
pterm0	   =	0			* terminate the program func code
cconws     =	9			* console string write func code
fopen	   =   15			* file open func code
	.text
*
*
*	OPEN OVERLAY FILE
*
_readg:
    	move	sr, savecc
    	movem.l d1-d7/a0-a6,saver
	move.w	#0,  -(a7)		* read access mode
    	pea.l   fname			* filename address
    	move.w  #fopen,-(a7)		* GEMDOS function number
	trap	#1			*try to open the file to be loaded
    	addq.l  #8,  a7			* pop parameters
	cmpi.l	#-33,d0			*test d0 for GEMDOS error return code
	beq	openerr			*if d0 = -33L then goto openerr
    	cmpi.l	#-35, d0		*if d0 = -35l then goto nohdle
    	beq	nohdle
    	cmpi.l	#-36, d0		*if d0 = -36L then goto noaccs
    	beq	noaccs
     	move.w	d0, flhd		* store file handle, otherwise
*
*	FILL THE LPB
*
    	lea	flhd, a0		* a0 contains address of fild handle
	lea	ovbspg,a3		* get address of input buffer 
	move.l	a3,baspag		* put it in LPB


readseq:
* GEMDOS f_read  function
	move.l	a3, -(sp)	* buffer address
    	move.l	#bufsize, -(sp) * buffer size
    	move.w	(a0),	-(sp)	* file handle
	move.w	#fread, -(sp)	* read function
	trap	#1		* call gemdos
     	add.l	#12, sp		* pop parameters
	rts



*
*	PRINT ERROR MESSAGE
*
openerr:
	move.l	#openmsg,-(a7)	*get address of error message 
	bra	print		*to be printed
nohdle:
    	move.l	#hdlemsg, -(a7)	*get addr of error message
    	bra	print
noaccs:
    	move.l	#accmsg, -(a7)	*get addr of error message
    	bra	print
lderr:	move.l  #loaderr,-(a7)	*get address of error message to 
*				*be printed
print:	move.w	#cconws, -(a7)	*get GEMDOS function number
	trap	#1              *print the message
    	addq.l  #6, a7		*pop parameters

	move.b	#0, ex		*mark end of filename
	move.l	#fname,-(a7)	*get address of filename
	move.w	#cconws,-(a7)	*set up for BDOS call
	trap	#1		*print the filename
    	addq.l	#6, a7		*pop parameters

cmdrtn: move.w	#pterm0,-(a7)	*get GEMDOS function number
	trap	#1              *terminate the program

*
*	DATA
*
	.data
*
*	ERROR MESSAGE STRINGS
*
	.even
loaderr:	.dc.b  13,10,"Error Loading Overlay File "
openmsg:	.dc.b  13,10,"Unable to Open Overlay File "
hdlemsg:	.dc.b  13,10,"No file handle left for file "
accmsg:		.dc.b  13,10,"Access denied for file "
fname:		.dc.b	"s.dat"
ex:		.ds.b	0
*
*	BSS
*
	.bss
	.even
oldadd: .ds.l	1		* table for last loaded overlay
savecc:	.ds.w	1
saver:	.ds.l	14
ovbspg:	.ds.w	64		* input buffer (like basepage) for loadr
*
*	LOAD PARAMETER BLOCK
*	If the following label and storage size are changed, the offsets
*	defined in loadr needs to changed too.
	.even
flhd:	   .ds.w	1      *file handle of program file
baspag:	   .ds.l	1      *Base page address of loaded program
	.end
