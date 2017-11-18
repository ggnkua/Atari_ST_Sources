******************************************************************************
*
* gemstart.s -startup code for the C runtime library, aesbind, vdibind
*	
*	IMPORTANT: SEE THE DESCRIPTION OF THE "STACK" VARIABLE, BELOW.
*
*	This is the startup code for any application running on the Atari ST.
*	This includes gemlib, vdi, and the aes bindings.
*
*	Look carefully at the comments below; they will determine the nature
*	of this startup code (stack size, AES & VDI usage, etc.).
*
*	This must be the first object file in a LINK command. When the
*	operating system gives it control, our process has ALL of memory
*	allocated to it, and our stack pointer is at the top.
*	This code (conditionally) gives some of that memory back
*	to the operating system, places its stack pointer at the top
*	of the memory it still owns, sets up some global variables,
*	and calls __main, the run-time library startup routine (which
*	parses the command line into argc/argv, opens stdin and stdout,
*	etc., before calling the programmer's _main).
*
*	This object file also includes __exit, which is the procedure the
*	runtime library calls to exit back to the operating system.
*	As a new feature with this release, the argument passed to __exit
*	is NOT ignored; it is passed to the operating system using the Pterm
*	function call, which returns it as the value of the Pexec() call
*	which invoked this process.
*
******************************************************************************
*
*	CONFIGUING THIS STARTUP FILE
*
*	There are several memory models which this startup file will
*	assemble for, selected by the assembly variable STACK.
*
*	When your process gets control, it owns its basepage, its text
*	(program) segment, its data segment, its bss segment (uninitialized
*	data), and all the "free memory" from there to the top of the TPA.
*	A process can choose to keep all that free memory for its stack
*	(used by function calls and local variables) and heap (used by
*	malloc()), or it can return some or all of that space to the
*	operating system.
*
*	The memory between the top of your bss segment and your stack pointer
*	is used both for a heap and for the stack.  The line between heap
*	and stack is called the "break".  When malloc() uses up all the
*	memory below the break, it calls _brk() (in this file) to move the 
*	break up.  If the break gets too close to the stack, _brk() returns 
*	an error code, and malloc() will return NULL because it couldn't
*	satisfy the request.  If the stack actually overflows the break,
*	_brk() prints an error message and exits, returning 1 to its parent.
*
*	If you are using the AES or VDI, you must return at least a little of
*	the free memory to the operating system, because they need it.
*	About 8K should be enough. The AES uses this memory for blt buffers,
*	and the VDI uses it for virtual workstation data.
*	Also, if your program uses the Pexec() call, you will need to return
*	some space to make room for the child process.
*
*	It is usually a good idea to keep only as much memory as you will
*	use, because some programs depend on processes returning some 
*	memory to the operating system.
*
*************************************************************************
*
*	Here are the memory models you can set up with the STACK variable:
*
*	STACK
*	value	Meaning
*	------	---------------------------------------------------------
*	-1	Keep all the memory for this process. Return NONE of it
*		to the operating system.  This model gives you the most
*		memory.
*
*		WARNING: IF YOU REQUEST ALL OF MEMORY (with STACK = -1),
*		YOU MUST NOT USE THE AES, THE VDI, OR THE BIOS PEXEC() 
*		FUNCTION. PEXEC WILL RETURN A CORRECT ERROR CODE (-39, 
*		ENSMEM), BUT IT WILL ALSO BREAK THE MEMORY MANAGEMENT SYSTEM.
*
*	 0	Return all but a minimal amount (MINSTACK) of the free
*		space to the operating system.  This is a good idea if
*		you know you won't be using malloc() much, or if you
*		will be using Pexec() and your program doesn't need much
*		stack space.  Remember, though, that some library functions,
*		especially fopen(), use malloc() and will use your heap
*		space.
*
*	 1	Keep 1/4 of the free space.  This is a good model if
*		you will be using malloc() a lot, but also want to use 
*		Pexec() to spawn subprocesses.
*
*	 2	Keep 2/4 (1/2) of the free space.  This is good if you
*		use malloc() a lot, but don't want to be too much of a 
*		memory hog.
*
*	 3	Keep 3/4 of the free space.  This is a good choice for
*		programs which use the AES or VDI, because it gives you plenty
*		of room for using malloc(), but leaves enough for the
*		AES and VDI to allocate their buffers, too.
*
*	 4	This is a special value which means "Keep the number of
*		bytes in the LONG global variable __STKSIZ."  You must declare
*		a variable in your program called "_STKSIZ" and initialize
*		it to the number of bytes you want for your stack and heap.
*		If __STKSIZ is negative, it means "Keep all BUT the number
*		of bytes in __STKSIZ."  As a safeguard, if __STKSIZ is
*		undefined, you will get MINSTACK bytes of stack/heap.
*
*		An example using __STKSIZ this in C is:
*
*			/* outside all function blocks */
*			unsigned long _STKSIZ = 32767;	/* 32K stack+heap */
*		or
*			unsigned long _STKSIZ = -8192;	/* keep all but 8K */
*
*		Note that in C, all variables get an underscore stuck on
*		the front, so you just use one underscore in your program.
*		Note also that it has to be all upper-case.
*
*	Any other POSITIVE value of STACK will be taken as the number of
*	bytes you want to KEEP for your stack and heap.
*
*	Any other NEGATIVE value of STACK will be taken as the number of
*	bytes you want to give back to the operating system.
*
*	Note that if you give back less than 512 bytes, you still shouldn't
*	use Pexec(), and if you give back less than (about) 4K, you shouldn't
*	use the AES or VDI.
*
*	In all cases, a minimum stack size is enforced.  This minimum is
*	set by the variable MINSTACK in this assembly file.  This value
*	should be at least 256 bytes, but should be more like 4K. If
*	the stack size from the STACK model you choose or the _STKSIZ
*	variable in your program is less than MINSTACK, you'll get
*	MINSTACK bytes.  If there aren't MINSTACK bytes free past the end
*	of your BSS, the program will abort with an error message.
*
*************************************************************************
*
* STACK variable summary:
*	-1=keep all
*	 0=keep MINSTACK bytes
*	 1=keep 1/4 of free memory
*	 2=keep 2/4
*	 3=keep 3/4
*	 4=use _STKSIZ: keep (if >0) or give up (if <0) _STKSIZ bytes.
*    other=keep that many bytes (positive) or give back that many (negative)

STACK=-8192		* CHANGE THIS VARIABLE TO CHOOSE A MEMORY MODEL
MINSTACK=4096		* minimum stack+heap size.
FUDGE=512		* minimum space to leave ABOVE our stack

* BASEPAGE ADDRESSES:
p_lowtpa=$0		* Low TPA address (basepage address)
p_hitpa=$4		* High TPA address (and initial stack pointer)
p_tbase=$8		* ptr to Code segment start
p_tlen=$c		* Code segment length
p_dbase=$10		* ptr to Data segment start
p_dlen=$14		* Data segment length
p_bbase=$18		* ptr to Bss  segment start
p_blen=$1c		* Bss  segment length
p_dta=$20		* ptr to process's initial DTA
p_parent=$24		* ptr to process's parent's basepage
p_reserved=$28		* reserved pointer
p_env=$2c		* ptr to environment string for process
p_cmdlin=$80		* Command line image

*
* CONTROL VARIABLES (used in stack computations)
*
* GOTSTACK: a boolean which is set TRUE if STACK in [-1..4], meaning "don't
*	    assemble the code keeping or returning STACK bytes."
*
* DOSHRINK: a boolean which is set FALSE if STACK is -1, meaning "don't
*	    shrink any memory back to the operating system."
*
gotstack	.equ	0	* set to 1 if STACK in [-1..4]
doshrink	.equ	1	* default is 1; set to 0 if STACK = -1

* GEMDOS functions:
cconws=$09		* Cconws(string): write to console
mshrink=$4a		* Mshrink(newsize): shrink a block to a new size
pterm=$4c		* Pterm(code): exit, return code to parent

.globl	__start
.globl	__main
.globl	__exit
.globl	_brk
.globl	__break
.globl	___cpmrv
.globl	__base
.globl	__sovf
.globl	_crystal
.globl	_ctrl_cnts


	.text
*
*  Must be first object file in link statement
*

__start:
	move.l	sp,a1		* save our initial sp (used by ABORT)
	move.l	4(sp),a0	* a0 = basepage address
	move.l	a0,__base	* base = a0
	move.l	p_bbase(a0),d0	* d0 = bss seg start
	add.l	p_blen(a0),d0	* d0 += bss length  (d0 now = start of heap)
	move.l	d0,__break	* __break = first byte of heap

*************************************************************************
*									*
*	Compute stack size based on MINSTACK, p_hitpa(a0), STACK,	*
*	and __STKSIZ, as appropriate.  Place the SP where you want	*
*	your stack to be. Note that a0 == __base, d0 == __break		*
*									*
*	At most one of the STACK code fragments will be assembled.	*
*	If none of them are, then `gotstack' will still be 0, and	*
*	the final block, saving STACK bytes, is used. Finally, if	*
*	STACK wasn't -1 (meaning don't shrink at all), DOSHRINK		*
*	gets control.  See doshrink for more.				*
*									*
*************************************************************************

*************************************************************************
*		STACK = -1: keep all of memory				*
*************************************************************************

	.ifeq	STACK+1		* if (STACK == -1)
gotstack	.equ	1
doshrink	.equ	0	* this PREVENTS doshrink from assembling.
	move.l	p_hitpa(a0),sp	* place stack at top of tpa.
	move.l	d0,d1		* check against MINSTACK
	add.l	#MINSTACK,d1	* d1 = __break + MINSTACK;
	cmp.l	sp,d1		* if (sp < __break + MINSTACK)
	bhi	abort		*	goto abort;
	.endc			* (this falls through to the __main call)

*************************************************************************
*		STACK = 0: keep only MINSTACK bytes			*
*************************************************************************

	.ifeq	STACK
gotstack	.equ	1
	move.l	#MINSTACK,sp	*	sp = __break+MINSTACK;
	add.l	d0,sp
	.endc			* (this falls through to doshrink)

*************************************************************************
*		STACK = 1: keep 1/4 of available memory			*
*************************************************************************

	.ifeq	STACK-1
gotstack	.equ	1	*	/* keep 1/4 of available RAM */
	move.l	p_hitpa(a0),d1	*	d1 = p_hitpa;
	sub.l	d0,d1		*	d1 -= __break; /* d1 = free ram size */
	lsr.l	#2,d1		*	d1 /= 4;
	add.l	d0,d1		*	d1 += __break;     /* d1 = new sp */
	move.l	d1,sp		* 	sp = d1;
	.endc			* } (this falls through to doshrink)

*************************************************************************
*		STACK = 2: keep 2/4 of available memory			*
*************************************************************************

	.ifeq	STACK-2		* if (STACK == 2) {	/* keep 1/2 */
gotstack	.equ	1
	move.l	p_hitpa(a0),d1	*	d1 = p_hitpa;
	sub.l	d0,d1		*	d1 -= __break; /* d1 = free ram size */
	lsr.l	#1,d1		*	d1 /= 2;
	add.l	d0,d1		*	d1 += __break; /* d1 = new sp */
	move.l	d1,sp		* 	sp = d1;
	.endc			* this falls through to doshrink

*************************************************************************
*		STACK = 3: keep 3/4 of available memory			*
*************************************************************************

	.ifeq	STACK-3		* if (STACK == 3) {	/* keep 3/4 */
gotstack	.equ	1
	move.l	p_hitpa(a0),d1	*	d1 = p_hitpa;
	sub.l	d0,d1		*	d1 -= __break; /* d1 = free ram size */
	lsr.l	#2,d1		*	d1 /= 4;
	move.l	d1,d2		*	d2 = d1
	add.l	d2,d1		*	d1 += d2;
	add.l	d2,d1		*	d1 += d2; /* now d1 = 3*(d1/4) */
	add.l	d0,d1		*	d1 += __break;     /* d1 = new sp */
	move.l	d1,sp		* 	sp = d1;
	.endc			* this falls through to doshrink

*************************************************************************
*		STACK = 4: keep or give up __STKSIZ bytes of memory.	*
*************************************************************************

	.ifeq	STACK-4		* if (STACK == 4) {	/* keep __STKSIZ */
	.globl __STKSIZ		* global variable holding stack size
gotstack	.equ	1
	move.l	#__STKSIZ,a1	* Check to see if __STKSIZ was undefined.
	beq	keepmin		* if it's zero, keep the minimum stack.
	move.l	(a1),d1
	bmi	giveback	*	if (__STKSIZ < 0) goto giveback;
	add.l	d0,d1		*	d1 = __base+__STKSIZ; /* new sp */
	bra	gotd1

keepmin:			* __STKSIZ was undefined; keep minimum.
	move.l	#MINSTACK,d1
	add.l	d0,d1		*	d1 = __base + MINSTACK;
	bra	gotd1		*	goto gotd1;

giveback:
	add.l	p_hitpa(a0),d1	*	d1 += hitpa;

gotd1:	move.l	d1,sp		* gotd1: sp = d1;
	.endc

*************************************************************************
*		STACK is something else: keep (if STACK>0) or give	*
*			back (if STACK<0) STACK bytes			*
*************************************************************************

	.ifeq	gotstack	* it's a constant stack value (+ or -)

	move.l	#STACK,d1	*	/* if neg, give back STACK bytes */
	bmi	giveback	*	if (STACK < 0) goto giveback;
	add.l	d0,d1		*	d1 = __STKSIZ + __base; /* new sp */
	bra	gotd1		*	goto gotd1;

giveback:			* giveback:
	add.l	p_hitpa(a0),d1	*	d1 += hitpa;	/* d1 = new sp */
gotd1:				* gotd1:
	move.l	d1,sp		*	sp = d1;
	.endc

*************************************************************************
*									*
* DOSHRINK: take SP as a requested stack pointer. Place it		*
* between (__break+MINSTACK) and (p_hitpa(a0)-FUDGE).  If we can't,	*
* abort. Otherwise, we return the remaining memory back to the o.s.	*
* The reason we always shrink by at least FUDGE bytes is to work around	*
* a bug in the XBIOS Malloc() routine: when there are fewer than 512	*
* bytes in the largest free block, attempting a Pexec() breaks the	*
* memory management system.  Since all models except -1 permit Pexec()	*
* calls, we have to make sure they don't break, even if the Pexec()	*
* fails.  Thus, FUDGE must be at least 512.				*
*									*
*************************************************************************
*
* PSEUDOCODE:
* doshrink(sp)
* {
*	/* if too low, bump it up */
*	if (sp < (__break + MINSTACK))
*		sp = (__break + MINSTACK);
*
*	/* if too high, bump it down */
*	if (sp > (hitpa - FUDGE)) {
*		sp = (hitpa - FUDGE);
*
*		/* if now too low, there's not enough memory */
*		if (sp < (__break + MINSTACK))
*			goto abort;
*	}
*	Mshrink(0,__base,(sp - __base));
* }
*
*************************************************************************

	.ifne	doshrink	* assemble this only if STACK != -1
	move.l	d0,d1		*     d1 = __break;
	add.l	#MINSTACK,d1	*     d1 += MINSTACK;
	cmp.l	d1,sp		*     if ((__break+MINSTACK) < sp)
	bhi	minok		* 	goto minok;
	move.l	d1,sp		*     else sp = (__break+MINSTACK)
minok:				* minok:
	move.l	p_hitpa(a0),d2	*     d2 = hitpa;
	sub.l	#FUDGE,d2	*     d2 -= FUDGE;
	cmp.l	d2,sp		*     if ((hitpa - FUDGE) > sp)
	bcs	maxok		*	goto maxok;
*				*     else {
	move.l	d2,sp		*	sp = (hitpa - FUDGE);
	cmp.l	d1,d2		* 	if ((__break+MINSTACK) > (hitpa-FUDGE))
	bcs	abort		*	    goto abort;	/* BAD NEWS */
*				*     }
maxok:

*************************************************************************
* STACK LOCATION HAS BEEN DETERMINED. Return unused memory to the o.s.	*
*************************************************************************

	move.l	sp,d1		*     d1 = sp;
	and.l	#-2,d1		*     /* ensure d1 is even */
	move.l	d1,sp		*     sp = d1;
	sub.l	a0,d1		*     d1 -= __base; /* d1 == size to keep */

	move.l	d1,-(sp)	* push the size to keep
	move.l	a0,-(sp)	* and start of this block (our basepage)
	clr.w	-(sp)		* and a junk word
	move	#mshrink,-(sp)	* and the function code
	trap	#1		* Mshrink(0,__base,(sp-base))
	add.l	#12,sp		* clean the stack after ourselves
	.endc

*************************************************************************
*									*
* Finally, the stack is set up. Now call _main(cmdline, length).	*
*									*
*************************************************************************

	move.l	__base,a0	* set up _main(cmdline,length)
	lea.l	p_cmdlin(a0),a2	* a2 now points to command line
	move.b	(a2)+,d0	* d0 = length; a2++;
	ext.w	d0		* extend byte count into d0.w
	move.w	d0,-(a7)	* push length
	move.l	a2,-(a7)	* Push commnd
	clr.l	a6		* Clear frame pointer
	jsr	__main		* call main routine	NEVER RETURNS

***********************************************************************
*
* _exit(code)	Terminate process, return code to the parent.
*
***********************************************************************

__exit:
	tst.l	(a7)+		* drop return PC off the stack, leaving code
	move.w	#pterm,-(a7)	* push function number
	trap	#1		* and trap.

*
* abort: used if the stack setup above fails. Restores the initial sp,
* prints a message, and quits with the error ENSMEM.
*
abort:				* print an abortive message and quit
	move.l	a1,sp		* restore initial sp
	pea.l	abortmsg	* push string address
	move.w	#cconws,-(a7)	* and function code
	trap	#1		* and trap to print message
	addq.l	#6,a7		* clean off stack
	move.w	#-39,-(a7)	* push error number -39: ENSMEM
	jsr	__exit		* and exit with it.
*
*
_brk:		
	cmp.l	__break,sp	* compare current break with current stack
	bcs	__sovf		* actual stack overflow!
	movea.l	4(sp),a0	* get new break
	move.l	a0,d0		* compare with stack, including 256-byte
	adda.l	#$100,a0	* chicken factor
	cmpa.l	a0,sp		* if (sp < a0+256)
	bcs	badbrk		* 	bad break;
	move.l	d0,__break	* OK break: save the break
	clr.l	d0		* Set OK return
	rts			* return

badbrk:
	move.l	#-1,d0		* Load return reg
	rts			* Return
*
*
.globl	___BDOS
___BDOS:
	link	a6,#0		* link
	move.w	8(sp),d0	* Load func code
	move.l	10(sp),d1	* Load Paramter
	trap	#2		* Enter BDOS
	cmpa.l	__break,sp	* Check for stack ovf
	bcs	__sovf		* overflow! print msg and abort
	unlk	a6		* no error; return
	rts			* Back to caller

*
* stack overflow! This external is called by salloc in gemlib as well as above
*
__sovf:
	move.l	#ovf,-(sp)	* push message address
	move.w	#cconws,-(sp)	* push fn code
	trap	#1		* Issue message

	move.w	#1,-(a7)	* push return code (1)
	move.w	#pterm,d0	* push function code (Pterm)
	trap	#1		* call Pterm(1) (never returns)

*
*	Block Fill function:
*
*	blkfill(dest,char,cnt);
*
*	BYTE	*dest;		* -> area to be filled
*	BYTE	char;		* =  char to fill
*	WORD	cnt;		* =  # bytes to fill
*
	.globl	_blkfill
_blkfill:
	move.l	4(a7),a0	* -> Output area
	move.w	8(a7),d1	* =  output char
	move.w	10(a7),d0	* =  output count
	ext.l	d0		* make it long
	subq.l	#1,d0		* decrement
	ble	filldone	* Done if le
fillit:	move.b	d1,(a0)+	* move a byte
	dbra	d0,fillit	* Continue
filldone: clr.l	d0		* always return 0
	rts			*

*
*	Index function to find out if a particular character is in a string.
*
	.globl	_index
	.globl	_strchr
_index:
_strchr:
	move.l	4(a7),a0	* a0 -> String
	move.w	8(a7),d0	* D0 = desired character
xindex:	tst.b	(a0)		* EOS?
	bne	notend		* No, continue to look
	clr.l	d0		* Not found
	rts			* Quit
notend:	cmp.b	(a0)+,d0	* check for character
	bne	xindex		*	
	move.l	a0,d0		* Found it
	subq.l	#1,d0		* set return pointer
	rts

*
*	For GEMAES calls from AESBIND.ARC or cryslib.o
*
_crystal:
	move.l	4(a7),d1
	move.w	#200,d0
	trap	#2
	rts

*
*	Data area
*
	.data
	.globl	___pname	* Program Name
	.globl	___tname	* Terminal Name
	.globl	___lname	* List device name
	.globl	___xeof		* ^Z byte
ovf:		.dc.b	'Stack Overflow',13,10,0	* Overflow message
___pname:	.dc.b	'runtime',0	* Program name
___tname:	.dc.b	'CON:',0	* Console name
___lname:	.dc.b	'LST:',0	* List device name
___xeof:	.dc.b	$1a		* Control-Z
abortmsg:	.dc.b	'Cannot initialize stack',13,10,0	* abort message

**********************************************************************
*
* BSS AREA
**********************************************************************
	.bss
	.even
__base:		.ds.l	1	* -> Base Page
__break:	.ds.l	1	* Break location
___cpmrv:	.ds.w	1	* Last CP/M return val

*
*	control array for vdibind
*
	.data
    	.even
_ctrl_cnts:			 	*	Application Manager
	.dc.b	0, 1, 0			* func 010		
    	.dc.b	2, 1, 1			* func 011		
    	.dc.b	2, 1, 1 		* func 012		
	.dc.b	0, 1, 1			* func 013		
	.dc.b	2, 1, 1			* func 014		
	.dc.b	1, 1, 1			* func 015		
	.dc.b	0, 0, 0			* func 016		
	.dc.b	0, 0, 0			* func 017		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 1, 0			* func 019		
*							 Event Manager
	.dc.b	0, 1, 0			* func 020		
	.dc.b	3, 5, 0			* func 021		
	.dc.b	5, 5, 0			* func 022		
	.dc.b	0, 1, 1			* func 023		
	.dc.b	2, 1, 0			* func 024		
	.dc.b	16, 7, 1 		* func 025		
	.dc.b	2, 1, 0			* func 026		
	.dc.b	0, 0, 0			* func 027		
	.dc.b	0, 0, 0			* func 028		
	.dc.b	0, 0, 0			* func 009		
*							 Menu Manager
	.dc.b	1, 1, 1			* func 030		
	.dc.b	2, 1, 1			* func 031		
	.dc.b	2, 1, 1			* func 032		
	.dc.b	2, 1, 1			* func 033		
	.dc.b	1, 1, 2			* func 034		
	.dc.b	1, 1, 1			* func 005		
	.dc.b	0, 0, 0			* func 006		
	.dc.b	0, 0, 0			* func 007		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 0, 0			* func 009		
*							 Object Manager
	.dc.b	2, 1, 1			* func 040		
	.dc.b	1, 1, 1			* func 041		
  	.dc.b	6, 1, 1			* func 042		
	.dc.b	4, 1, 1			* func 043		
	.dc.b	1, 3, 1			* func 044		
	.dc.b	2, 1, 1			* func 045		
	.dc.b	4, 2, 1			* func 046		
	.dc.b	8, 1, 1			* func 047		
	.dc.b	0, 0, 0			* func 048		
	.dc.b	0, 0, 0			* func 049		
*							 Form Manager
	.dc.b	1, 1, 1			* func 050		
	.dc.b	9, 1, 1			* func 051		
	.dc.b	1, 1, 1			* func 002		
	.dc.b	1, 1, 0			* func 003		
	.dc.b	0, 5, 1			* func 004		
	.dc.b	0, 0, 0			* func 005		
	.dc.b	0, 0, 0			* func 006		
	.dc.b	0, 0, 0			* func 007		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 0, 0			* func 009		
*							 Dialog Manager
	.dc.b	0, 0, 0			* func 060		
	.dc.b	0, 0, 0			* func 061		
	.dc.b	0, 0, 0			* func 062		
	.dc.b	0, 0, 0			* func 003		
	.dc.b	0, 0, 0			* func 004		
	.dc.b	0, 0, 0			* func 005		
	.dc.b	0, 0, 0			* func 006		
	.dc.b	0, 0, 0			* func 007		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 0, 0			* func 009		
*							Graphics Manager
	.dc.b	4, 3, 0			* func 070		
	.dc.b	8, 3, 0			* func 071		
	.dc.b	6, 1, 0			* func 072		
	.dc.b	8, 1, 0			* func 073		
	.dc.b	8, 1, 0			* func 074		
	.dc.b	4, 1, 1			* func 075		
	.dc.b	3, 1, 1			* func 076		
	.dc.b	0, 5, 0			* func 077		
	.dc.b	1, 1, 1			* func 078		
	.dc.b	0, 5, 0			* func 009		
*							Scrap Manager
	.dc.b	0, 1, 1			* func 080		
	.dc.b	0, 1, 1			* func 081		
	.dc.b	0, 0, 0			* func 082		
	.dc.b	0, 0, 0			* func 083		
	.dc.b	0, 0, 0			* func 084		
	.dc.b	0, 0, 0			* func 005		
	.dc.b	0, 0, 0			* func 006		
	.dc.b	0, 0, 0			* func 007		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 0, 0			* func 009		
*							fseler Manager
	.dc.b	0, 2, 2			* func 090		
	.dc.b	0, 0, 0			* func 091		
	.dc.b	0, 0, 0			* func 092		
	.dc.b	0, 0, 0			* func 003		
	.dc.b	0, 0, 0			* func 004		
	.dc.b	0, 0, 0			* func 005		
	.dc.b	0, 0, 0			* func 006		
	.dc.b	0, 0, 0			* func 007		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 0, 0 		* func 009		
*							Window Manager
	.dc.b	5, 1, 0			* func 100		
	.dc.b	5, 1, 0			* func 101		
	.dc.b	1, 1, 0			* func 102		
	.dc.b	1, 1, 0			* func 103		
	.dc.b	2, 5, 0			* func 104		
	.dc.b	6, 1, 0			* func 105		
	.dc.b	2, 1, 0			* func 106		
	.dc.b	1, 1, 0			* func 107		
	.dc.b	6, 5, 0			* func 108		
	.dc.b	0, 0, 0 		* func 009		
*							Resource Manger
	.dc.b	0, 1, 1			* func 110		
	.dc.b	0, 1, 0			* func 111		
	.dc.b	2, 1, 0			* func 112		
	.dc.b	2, 1, 1			* func 113		
	.dc.b	1, 1, 1			* func 114		
	.dc.b	0, 0, 0			* func 115		
	.dc.b	0, 0, 0			* func 006
	.dc.b	0, 0, 0			* func 007
	.dc.b	0, 0, 0			* func 008
	.dc.b	0, 0, 0			* func 009
*							Shell Manager
	.dc.b	0, 1, 2			* func 120
	.dc.b	3, 1, 2			* func 121
	.dc.b	1, 1, 1			* func 122
	.dc.b	1, 1, 1			* func 123
	.dc.b	0, 1, 1			* func 124
	.dc.b	0, 1, 2			* func 125

	.end
