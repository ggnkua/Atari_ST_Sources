******************************************************************************
*
*	C runtime startup for CP/M-68k.
*
*	Adapted for make (no AES control array, 12k stack)
*
******************************************************************************
*
ltpa=0			* Low TPA address
htpa=4			* High TPA address
lcode=8			* Code segment start
codelen=12		* Code segment length
ldata=16		* Data segment start
datalen=20		* Data segment length
lbss=24			* Bss  segment start
bsslen=28		* Bss  segment length
freelen=32		* free segment length
resvd=36		* Reserved
fcb2=56			* 2nd parsed fcb
fcb1=92			* 1st parsed fcb
command=128		* Command tail
prtstr=9		* Print string BDOS Call
exit=0			* BDOS exit call
.globl	__main
.globl	__exit
.globl	__break
.globl	___cpmrv
.globl	__base
.globl  _sw_
.globl	__sovf


		.text


*
*  Must be first object file in link statement
*
	move.l	a7,a5		* save a7 so we can get the base page address
	move.l	4(a5),a5	* a5=basepage address
	move.l	a5,__base	* save for C startup
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$3100,d0	* d0=basepage+textlen+datalen+bsslen
*				  (plus 12K of user stack)
	move.l	d0,d1
	add.l	a5,d1		* compute stack top
	and.l	#-2,d1		* ensure even byte boundary
	move.l	d1,a7		* setup user stack, 1K above end of BSS

	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp)		* junk word
	move	#$4a,-(sp)	* return excess storage
	trap	#1
	add.l	#12,sp


		move.l	__base,a0		*	Load C external
		move.l	lbss(a0),a1		*	a1 -> bss region
		adda.l	bsslen(a0),a1		*	a1 -> 1st heap loc

		move.l	a1,__break		*	Put in "break" loc
		lea.l	command(a0),a2		*	a2 -> command line
		move.b	(a2)+,d0		*	d0 = byte count
		andi.l	#$ff,d0			*	clear junk
		move.w	d0,-(a7)		*	push length
		move.l	a2,-(a7)		*	Push commnd
		clr.l	a6			*	Clear frame pointer
		jsr	__main			*	call main routine
		jmp	__exit			*	call "exit"


	.bss
	.even
__base:		.ds.l	1			*	-> Base Page
__break:	.ds.l	1			*	Break function
___cpmrv:	.ds.w	1			*	Last CP/M return val



*
*
.globl	_brk
		.text
_brk:		
		movea.l	4(sp),a0		*	New break?
		move.l 	a0,d0
		lea	$100(a0),a0		*	Chicken factor
		cmpa.l	a0,sp			*	Compare
		bhis	brkok			*	OK, continue
		move.l	#-1,d0			*	Load return reg
		rts				*	Return
brkok:
		move.l	d0,__break		*	Save the break
		clr.l	d0			*	Set OK return
		rts				*	return
		
.globl	___BDOS
___BDOS:	link	a6,#0			*	link
		move.w	8(sp),d0		*	Load func code
		move.l	10(sp),d1		*	Load Paramter
		trap	#2			*	Enter BDOS
		cmpa.l	__break,sp		*	Check for stack ovf
		bhis	noovf			*	NO overflow, continue
__sovf:		move.w	#prtstr,d0		*	String print
		lea	ovf,a0			*	a0-> message
		move.l	a0,d1			*	load proper reg
		trap	#2			*	Issue message
__exit:		move.w	#exit,d0		*	Exit
		trap	#2			*		now
noovf:						*	Here if all OK
		unlk	a6			*
		rts				*	Back to caller
*
*	Block Fill function:
*
*	blkfill(dest,char,cnt);
*
*	BYTE	*dest;		/* -> area to be filled	*/
*	BYTE	char;		/* =  char to fill	*/
*	WORD	cnt;		/* =  # bytes to fill   */
*
	.globl	_blkfill
_blkfill:
	move.l	4(a7),a0			*	-> Output area
	move.w	8(a7),d1			*	=  output char
	move.w	10(a7),d0			*	=  output count
	ext.l	d0				*	make it long
	subq.l	#1,d0				*	decrement
	ble	filldone			*	Done if le
fillit:	move.b	d1,(a0)+			*	move a byte
	dbra	d0,fillit			*	Continue
filldone: clr.l	d0				*	always return 0
	rts					*

*
*	Index function to find out if a particular character is in a string.
*
	.globl	_index
	.globl	_strchr
_index:
_strchr:
	move.l	4(a7),a0			*	a0 -> String
	move.w	8(a7),d0			*	D0 = desired character
xindex:	tst.b	(a0)				*	EOS?
	bne	notend				*	No, continue to look
	clr.l	d0				*	Not found
	rts					*	Quit
notend:	cmp.b	(a0)+,d0			*	check for character
	bne	xindex				*	
	move.l	a0,d0				*	Found it
	subq.l	#1,d0				*	set return pointer
	rts					*
*
*	Data area
*
		.data
		.globl	___pname		*	Program Name
		.globl	___tname		*	Terminal Name
		.globl	___lname		*	List device name
		.globl	___xeof			*	^Z byte
ovf:		.dc.b	'Stack Overflow$'	*	Error message
___pname:	.dc.b	'C runtime',0		*	Program name
___tname:	.dc.b	'CON:',0		*	Console name
___lname:	.dc.b	'LST:',0		*	List device name
___xeof:	.dc.b	$1a			*	Control-Z
		.end
