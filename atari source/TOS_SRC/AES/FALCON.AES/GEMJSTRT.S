*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gemjstrt.s,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:24:52 $	$Locker: kbad $
* =======================================================================
*  $Log:	gemjstrt.s,v $
* Revision 2.2  89/04/26  18:24:52  mui
* TT
* 
* Revision 2.1  89/02/22  05:28:00  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.7  88/10/10  18:36:19  kbad
* left out .globl declaration for gemstart label.  Urk.
* 
* Revision 1.6  88/09/20  12:39:21  kbad
* Added gemstart: label for start of AES (for new partial-link build)
* 
* Revision 1.5  88/09/09  17:09:01  kbad
* Added environment setting compatibility mode
* 
* Revision 1.3  88/07/29  16:14:37  kbad
* Added conditional assembly for `dowarn'
* 
* Revision 1.2  88/07/15  16:08:13  mui
* initialize dowarn flag
* 
* Revision 1.1  88/06/02  12:34:22  lozben
* Initial revision
* 
*************************************************************************
*	GEMSTART.S	9/29/84 - 05/07/85	Lowell Webster
*	Ram based system	04/30/85	Derek Mui
*	Added one more variable diskin  08/28/85	Derek Mui
*	Clear sh_rom to read cart once only	7/1/86	Derek Mui
*	Take out sh_rom				7/2/86	Derek Mui
*	Init the g_wsend 			3/11/87	Derek Mui
*	Added autoexec				12/23/87 D.Mui
*	Clean up				1/14/88	 D.Mui
*	Take out s_menu		1/28/88			D.Mui
*	Crunch			2/3/88		D.Mui
*	Take out sh_up		2/11/88		D.Mui
*	Take out gl_respref	2/25/88		D.Mui
*	Take out system_acc	3/15/88		D.Mui
*	initalize sh variables	04/29/88	D.Mui
*       Start up aes/desktop as process
*	fix Super calls at startup		900702 kbad
*	Add GEMDOS version check for Pexec 7	900719 kbad
* 	assemble with MAS 900801 kbad
*	Change the uda_size	7/16/92		D.Mui
*	Added default res for sparrow 7/21/92	D.Mui

	.text

uda_size	equ	2074		* 74 + STACK_SIZE of 500 x 4
init_size	equ	uda_size - 2	* 0 relative
gloamnt		equ	2355		* sizeof(THEGLO) / 4
fsize		equ	100		* size of linef handler in bytes+ a little fat
*
fline		equ	0		* 1-line "F" included
*					* 0-line "F" not included
dodowarn	equ	0		* 1=>do the warning
*					* 0=>no warning

	.globl	_d_rezword
	.globl	_main
	.globl	_D		* static data, gl_uda 1st
	.globl	_trap
	.globl	_DOS_ERR
	.globl	_DOS_AX
	.globl	_justretf
	.globl	_drwaddr
	.globl	_tikcod
	.globl	_tikaddr
	.globl	_gl_restype
	.globl	_gl_rschange
	.globl	_size_theglo
	.globl	_ad_envrn
	.globl	_diskin		* added 08/2/8/85
*	.globl	_g_wsend
	.globl	_autoexec	
	.globl	_sh_doexec	* added 4/29/88
	.globl	_sh_iscart
	.globl	_sh_isgem
	.globl	_sh_gem
	.globl	gemstart
*
ifne	dodowarn
	.globl	_dowarn	
endc
*
ifne	fline
	.globl	_linef
endc
*
*
*  Must be first object file in link statement
*
*	Do setblock call to free up memory
*
gemstart:
	move.l	a7,a5		* save stack
	move.l	#ustak, a7	* switch stacks, dos needs a user stack 
	move.l	4(a5),a5	* basepage address
*	or.l	#7,$28(a5)	* prgflags in basepage
	move.l	$c(a5),d0	* textlen
	add.l	$14(a5),d0	* datalen
	add.l	$1c(a5),d0	* bsslen
	add.l	#$100,d0	* skip los pageos baseos
	move.l	d0,-(a7)	* size
	move.l	a5,-(a7)	* basepage
	move	d0,-(a7)	* junk word
	move	#$4a,-(a7)	* Mshrink
	trap	#1
	add.l	#12,a7

*	move.l	a7,-(a7)	* use same stacks for now
	clr.l	-(a7)		* Super(0L)
	move.w	#32,-(a7)	* drdos get sup mode
	trap	#1
	addq	#6,a7
*
*
* Here we munge the environment so the hard disk gets searched, if present,
* by shel_path.  This is for compatibility with the old shel_path, which
* didn't really use the path, but looked on C:\ anyways.
* You're welcome, Allan.
* (880825 kbad)
*
*
	movea.l	$2c(a5),a0		* save the environment pointer
	move.l	a0,_ad_envrn
	move.l	$4c2,d0			* get drvbits
	and.l	#$4,d0			* drive C there?
	beq.b	not_ours		* nope, leave the env alone
	cmp.l	#'PATH',(a0)+		* check 1st longword
	bne.b	not_ours
	cmp.l	#$3d00413a,(a0)+	* "=0A:"
	bne.b	not_ours

* section changed 8/9/90 AKP
	move.l	(a0),d0			* get last long to d0
	clr.b	d0			* clear last byte so it's "don't care"
	cmp.l	#$5c000000,d0		* check for "\00"
	bne.b	not_ours
	move.b	#'C',-2(a0)		* make it PATH=0C:\00

* end section changed

not_ours:
	clr.w	_gl_rschange		* Clear out resolution globals

	move.w	#1,d0
	move.w	d0,_gl_restype

sh_start:
	move.w	d0,_autoexec		* turn on auto exec
	move.w	d0,_sh_isgem		* desktop is the next to run 
	move.w	d0,_sh_gem			
	clr.w	_sh_doexec
	clr.w	_sh_iscart
	move.w	#$82,_d_rezword		* default resolution for sparrow

ifne	dodowarn
	clr.w	_dowarn			* This variable may or may not exist
endc
*
*		 LINE "F"
*
ifne	fline
	move.b	$2c,d0
	beq	nolinef		* linef vector already installed
	move.l	#fsize,-(a7)
	move.w	#$48,-(a7)
	trap	#1		* dos_allocate
	addq.l	#6,a7
	movea.l	d0,a0
	move.w	#((fsize/2)-1),d1
	movea.l	#_linef,a1
lop:
	move.w	(a1)+,(a0)+	* move linef code to ram
	dbf	d1,lop
	move.l	d0,$2c		* install ram linef vector
nolinef:
	nop
endc

	move.w  #1,_diskin	* added 08/28/85
*	clr.w	_g_wsend

*	bra begin

	move.w	#$30,-(sp)	* Sversion
	trap	#1
	addq	#2,sp
	move.b	d0,d1		* major version byte
	lsr	#8,d0
	lsl	#8,d1
	move.b	d0,d1		* minor version byte
	cmp	#$0018,d1	* GEMDOS version that supports Pexec 7
	blt	do5
	moveq	#7,d0
	move	d0,execmode
	move.l	d0,execflags
	bra	dobegin
do5:	move	#5,execmode
	clr.l	execflags
*
* Create a process for "begin", give it 128 bytes of stack, and just go
* new stuff as of 900702
*
dobegin:
* Pexec 7 is exactly like Pexec 5 except it specifies prgflags for basepage
* as next argument after Pexec code, instead of using 0 there
	clr.l	-(sp)		* env
	move.l	#dummycmd,-(sp)	* cmdline
	move.l	execflags,-(sp)	* flags
	move.w	execmode,-(sp)	* mode
	move.w	#$4b,-(sp)	* Pexec
	trap	#1
	lea	16(sp),sp

	move.l	d0,a5		* basepage
	move.l	#beg,8(a5)	* text base
	move.l	#$180,d0
	move.l	(a5),a0
	add.l	d0,a0		* basepage + 128 byte stack
	move.l	a0,4(a5)	* becomes hi TPA
	move.l	d0,-(sp)	* new size
	move.l	a5,-(sp)	* block start
	clr	-(sp)		* junk word
	move	#$4a,-(sp)	* Mshrink
	trap	#1
	lea	12(sp),sp

	clr.l	-(sp)		* Pexec(6,...)
	move.l	a5,-(sp)
	clr.l	-(sp)
	move.w	#6,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
	bra	dobegin

beg:
	clr.l	-(a7)		* use same stacks for now
	move.w	#32,-(a7)	* drdos get sup mode
	trap	#1		* Super(0L)
	addq	#6,a7

begin:

	jsr	_size_theglo	* returns sizeof(THEGLO) in words
	move.l	#_D,a0		* zero out static unitialized data
	clr.l	d1

beg1:
	move.w	d1,(a0)+
	dbmi.w	d0,beg1		* THIS MUST BE CHANGED TO DBRA!!!

	move.l	#_justretf,_drwaddr	* initialize some bss pointers
	move.l	#_tikcod,_tikaddr

* initialize first stack pointer in first uda

	move.l	#_D,a6		* base of uda
	move.l	a6,a5
	add.l	#init_size,a6	* add sizeof uda
	move.l	a6,62(a5)	* initialize stack pointer in uda
	move.l	a6,a7

	jsr	_main

	clr	(sp)
	trap	#1

* never get here

	bra	begin		* forever

*
*
_trap:	
	move.l	(sp)+,retsav
	clr.w	_DOS_ERR
	clr.w	_DOS_AX
	trap	#1
	move.w  d0,_DOS_AX	* set return code ( error proc only )
	tst.l	d0		* be careful !
	bge 	oktrap
	move.w	#1,_DOS_ERR

oktrap:
	move.l	retsav,-(sp)
	rts
*
*
	.bss

retsav:		.ds.l	1

* screen resolution 1=default, 2=320x200, 3=640x200, 4=640x400

_gl_restype:	.ds.w	1
_gl_rschange:	.ds.w	1
		.ds.l	32
ustak:		.ds.l	1
_diskin:	.ds.w	1	* added
dummycmd:	.ds.w	1
execmode:	.ds.w	1
execflags:	.ds.l	1
	.end
