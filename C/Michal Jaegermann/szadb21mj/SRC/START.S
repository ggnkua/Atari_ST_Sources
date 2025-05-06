*************************************************************************
*									*
*	DSTART.S	Startup module for C programs using dLibs	*
*			modified for szadb 				*
*************************************************************************

*
*  Use this module when compiling adb without on-online help
*  Sozobon preprocessor unfortunately does not take .s files
*

*
*  More modifications to make it TT compatible
*  this module now computes screen parameters and reserves screen
*  buffers in an area between program text and __break.
*

*
* entry points
*
.globl	_ossp
.globl	__base			* basepage pointer
.globl	__start			* startup entry point
.globl	_etext			* end of text segment
.globl	_edata			* end of data segment
.globl	_end			* end of BSS segment (end of program)
.globl	__break			* location of stack/heap break
.globl	__exit			* terminate immediately with exit code
.globl	__argc			* number of arguments
.globl	__argv			* argument list pointer
.globl	__envp			* environment string pointer
.globl	_errno			* system error number
.globl	_gemdos			* trap #1 (gemdos) hook
.globl	_bios			* trap #13 (bios) hook
.globl	_xbios			* trap #14 (xbios) hook
.globl	_bdos			* trap #2 (bdos) hook

*
* external references
*
.globl	__STKSIZ		* Stack size value from C (unsigned long)
.globl	__main			* Initial entry point for C program
.globl	_main			* C program main() function
.globl  _w			* structure describing screen parameters
.globl	_screen			* work screen buffer
.globl	_linbuf			* current line image for transcript writing
.globl	_svline			* saved line to protect from help()
.globl  _linsize		* so many long words + 6 bytes in _linbuf

*
* useful constants
*
MINSTK		equ	1024	* Minimum 1K stack size
MARGIN		equ	512	* Minimum memory to return to OS

*
* GEMDOS functions
*
Cconws		equ	$09	* Console write string
Pterm		equ	$4C	* Process terminate (with exit code)
Mshrink		equ	$4A	* Shrink program space
Getrez		equ	$04	* Find current resolution

*
* basepage offsets
*
p_hitpa		equ	$04	* top of TPA
p_tbase		equ	$08	* base of text
p_tlen		equ	$0C	* length of text
p_dbase		equ	$10	* base of data
p_dlen		equ	$14	* length of data
p_bbase		equ	$18	* base of BSS
p_blen		equ	$1C	* length of BSS
p_env		equ	$2C	* environment string
p_cmdlin	equ	$80	* command line image

*
* STARTUP ROUTINE (must be first object in link)
*
.text
__start:
*
* save initial stack and basepage pointers
*
	move.l	sp,a5			* a5 = initial stack pointer
	move.l	4(sp),a4		* a4 = basepage address
	move.l	a4,__base
	move.l	p_tbase(a4),d3
	add.l	p_tlen(a4),d3
	move.l	d3,_etext		* end of text segment
	move.l	p_dbase(a4),d3
	add.l	p_dlen(a4),d3
	move.l	d3,_edata		* end of data segment
	move.l	p_bbase(a4),d3
	add.l	p_blen(a4),d3
	move.l	p_env(a4),__envp	* save environment pointer
	move.l  a4,_end			* save basepage address for a moment
*
* compute work screen location, its parameters and reserve memory for it
*
	move.l  #255,d0
	add.l	d0,d3			* here a space for our work screen
	not.l	d0
	and.l	d0,d3			* align it on 0x100 boundary
	move.l	d3,_screen		* set work screen start

*
* This code fills fields in _w structure from a file window.c
* and finds how much memory has to be reserved
* All changes in window structure have to be reflected here!
*

	move.w  #Getrez,-(sp) 
	jsr	_xbios
	move.w	d0,_w+6			* and store it in w.res
*
* get all other info from line-A stuff
*
	.dc.w	$0a000
	lea	_w,a2
	move.l  a1,20(a2)		* a pointer to pointers to fonts
	moveq   #0,d0
	move.w	d0,(a2)+		* clear curc
	move.l	d0,(a2)+		* clear curl
	move.w  -44(a0),d0		* number of columns = V_CEL_MX
	addq	#1,d0
	move.w	(a2)+,d3		* grab resolution
	cmp.w   #2,d3			* is this still ST resolution?
	bgt	sfind			* jump if no
	moveq	#80,d1
	cmp.w   d1,d0			* no more than 80 columns?
	ble	sfind			* jump in this case
*
*	it looks like that we are running on Moniterm
*	szadb will work only with a standard monitor hooked on a side
*	so stick canned values into _w structure;
*
	subq	#1,d3			* test resolution
	bge	cols
	lsr.w	#1,d1			* only 40 columns for low
cols:
	move.w	d1,(a2)+		
	move.w  #25,(a2)+		* always 25 rows
	moveq	#16,d1
	moveq	#80,d2	
	subq	#1,d3			* medium or low res?
	beq	fsize			* jump if not
	lsr.w	#1,d1			* fontsz only 8
	lsl.w	#1,d2			* but fsz 160
fsize:
	move.w	d1,(a2)+		* store fontsz
	addq	#2,a2			* skip csz
	move.w	#1280,(a2)+		* lsz is fixed here
	move.w	d2,(a2)			* fill fsz
	move.l  #7999,d0		* this+1 = screen size in long words
	bra	blanksc
*
* no monitor trickery here - try to find out real values for screen
* parameters
*
sfind:
	move.w	d0,(a2)+		* d0 -> cols
	move.w  -42(a0),d0		* number of rows = V_CEL_MY
	addq	#1,d0
	move.w	d0,(a2)+
	move.w  -46(a0),d1
	move.w  d1,(a2)+		* fontsz
	addq    #2,a2			* skip csz
	move.w  -40(a0),d0		* width of line in bytes
	move.w  d0,(a2)+		* lsz - upper half of d0 already clear
	divu	d1,d0
	move.w	d0,(a2)			* fsz
	move.w  (a0),d0			* number of planes
	mulu    -4(a0),d0		* and multiply by max_y
	mulu    -12(a0),d0		* and by max_x - total size in pixels
	lsr.l   #5,d0			* total size of screen in long words
*
* blank out screen area
*
blanksc:
	move.l	_screen,a0
	move.l	d0,d1
	swap	d1
	moveq	#0,d3
clean:					* overshot by 1 in a case
					* of screen size not divisible by 32
	move.l	d3,(a0)+
	dbra	d0,clean
	dbra	d1,clean
	move.l	a0,_linbuf		* buffer for a current line characters
	move.w	-10(a2),d0		* screen width
	subq	#1,d0
	lsr.w	#2,d0			* decremented count in long words
	move.w	d0,_linsize		* for use by dbra in _cleanlb
	lsl.w	#2,d0			* this number is even
	addq.w	#6,d0			* number of columns + '\r\n'
	add.w	d0,a0			* _linbuf ends here
	move.l	a0,_svline		* this buffer used only when help
					* is active
	add.w	d0,a0			* same size as for linbuf
*
* reserve space for a work screen between end of the program
* and a space for stack - calculate initial __break value
newbrk:
	move.l	a0,__break
	move.l  _end,a4			* restore pointer to basepage
	move.l	a0,_end			* our end of program (with screen)

*
* call C function to get command line arguments
* this has to be done after screen setup, since _initargs moves __break
*
	lea.l	p_cmdlin(a4),a0		* get pointer to command line image
	move.b	(a0)+,d0
	ext.w	d0			* extract length
	move.w	d0,-(sp)		* cmdlen
	move.l	a0,-(sp)		* cmdline
	jsr	__initar		* call _initargs(cmdline, cmdlen)
	addq.l	#6,sp
*
* calculate free space available to program
*
	move.l	__break,a3		* a3 = base of free space
	move.l	a3,d3
	neg.l	d3
	add.l	p_hitpa(a4),d3
	sub.l	#MARGIN,d3		* d3 = free space
*
* calculate new stack size (store in d2)
*
	move.l	#__STKSIZ,a2		* a2 = &_STKSIZ
	move.l	a2,d2			* if __STKSIZ is undefined
	beq	minimum			*   use MINSTK
	move.l	(a2),d2			* if __STKSIZ is positive
	bpl	setstk			*   use __STKSIZ
	add.l	d3,d2			* if __STKSIZ is negative
	cmp.l	#MINSTK,d2		*   try (free space + __STKSIZ)
	bge	setstk			* if < MINSTK
minimum:
	move.l	#MINSTK,d2		*   use MINSTK
*
* check to see if there is enough room for requested stack
*
setstk:
	cmp.l	d3,d2
	blt	shrink			* if (available < requested)
	move.l	#stkerr,-(sp)
	move.w	#Cconws,-(sp)
	trap	#1			*   report a stack error
	addq.l	#6,sp
	move.w	#-39,-(sp)
	move.w	#Pterm,-(sp)
	trap	#1			*   and return error -39 (ENSMEM)
*
* set up new stack pointer and Mshrink
*
shrink:
	add.l	a3,d2			* new stack = free base + stack size
	move.l	d2,sp
	sub.l	a4,d2			* keep space = new stack - __base
	move.l	d2,-(sp)
	move.l	a4,-(sp)
	clr.w	-(sp)
	move.w	#Mshrink,-(sp)
	trap	#1			* Mshrink(0, _base, keep);
	add.l	#12,sp
*
* Look at kernel sp
*
	move.l	#0,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.w	#6,sp
	move.l	d0,_ossp
*
* call C entry point function _main()
*
	jsr	__main			* if _main returns
	move.w	d0,4(sp)		*   insert return value and fall thru

*
* void _exit(code)
*   int code;
*
* Terminate process with a return value of <code>
*
__exit:
	tst.l	(sp)+			* pop return PC off the stack
	move.w	(sp)+,d7		* exit code

	move.l	_ossp,d0		* old system stack pointer
	move.l	d0,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.w	#6,sp

	move.w	d7,-(sp)
	move.w	#Pterm,-(sp)
	trap	#1			*   and terminate.

*
* operating system trap hooks for C
*

*
* long gemdos(function, [parameter, ...])
*   int function;
*
_gemdos:
	move.l	(sp)+,traprtn		* save return address
	trap	#1			* do gemdos trap
	bra	chkstk

*
* long bios(function, [parameter, ...])
*   int function;
*
_bios:
	move.l	(sp)+,traprtn		* save return address
	trap	#13			* do bios trap
	bra	chkstk

*
* long xbios(function, [parameter, ...])
*   int function;
*
_xbios:
	move.l	(sp)+,traprtn		* save return address
	trap	#14			* do xbios trap
	bra	chkstk

*
* int bdos(function, parameter)
*   int function;
*   long parameter;
*
_bdos:
	move.l	(sp),traprtn		* save return address
	move.l	a6,(sp)			* save old frame pointer
	move.l	sp,a6			* set up frame pointer
	tst.l	-(a6)			*   (fake "link a6,#0")
	move.w	8(a6),d0		* function code in D0.W
	move.l	10(a6),d1		* parameter value in D1.L
	trap	#2			* do bdos trap
	move.l	(sp)+,a6		* restore old frame pointer

*
* check for stack overflow (done after all OS traps)
*
chkstk:
*	cmp.l	__break,sp
*	bgt	nosweat			* if (_break > sp)
*	move.l	#stkovf,-(sp)
*	move.w	#Cconws,-(sp)
*	trap	#1			*   report a stack overflow
*	addq.l	#6,sp
*	move.w	#-1,-(sp)
*	move.w	#Pterm,-(sp)
*	trap	#1			*   and return error -1 (ERROR)
nosweat:
	move.l	traprtn,-(sp)		* else, restore return address
	rts				* and do a normal return.

*
* this call to _main ensures that it the user's main() function will be
* linked, even if it is in a library.
*
	jsr	_main			* NO PATH TO THIS STATEMENT

* THE FOLLOWING IS SELF MODIFYING CODE, DO NOT DISTURB
	move.l	#$644c6962,$7320(sp)
	moveq.l	#$31,d3
	move.l	$0(a2,d0),d7

*
* initialized data space
*
.data
.even
stkerr:					* not enough memory for stack
	.dc.b	'Not enough memory',$d,$a,0
stkovf:					* impending stack overflow
	.dc.b	'Stack overflow',$d,$a,0
_errno:					* system error number
	.dc.w	0
__argc:					* number of command line args
	.dc.w	0
__argv:					* pointer to command line arg list
	.dc.l	0
*
* uninitialized data space
*
.bss
.even
__base:					* pointer to basepage
	.ds.l	1
_etext:					* pointer to end of text segment
	.ds.l	1
_edata:					* pointer to end of data segment
	.ds.l	1
_end:					* pointer to end of BSS (end of program)
	.ds.l	1
__break:				* pointer to stack/heap break
	.ds.l	1
__envp:					* pointer to environment string
	.ds.l	1
traprtn:				* storage for return PC in trap hooks
	.ds.l	1
_ossp:
	.ds.l	1
.end
