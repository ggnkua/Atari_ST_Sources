*  biosa.s - main bios routines						*

*  biosa.s - bios interface module					*

***************************************************************************
*
*  NOTES:
*	08/11/85 ktb	changing the way bios: handles calles to char
*			devices by calling bios.c, who vectors the call
*			based on the handle number
*
*	08 aug 85 ktb	changed tpa to start at 10000 for 70000
*
*	14 Aug 85 ktb	M0001.  handling of mouse and clock setvec changes
*
*	14 Aug 85 ktb	Ripped out all of the old console handling stuff.
*
***************************************************************************

*
*  conditional compile switches
*

automem equ 0		* =0 if hardcoded to 1Mbyte--will permit sid & cpm68k
*			  =1 if automem sizing done--no sid & cpm68k
*				WHENEVER automem IS REDEFINED (ie assigned 
*				anew to be either 0 or 1) be sure to ALSO 
*				REDEFINE it in MAIN.C

panic	equ	0	* 0 if no cmpanic routine available
*			* 1 if it is
*

*
*  global entry points
*
	.text

	.xdef	_cmain
	.xref	_bcli
	.xref	_bsti
	.xref	_criter
	.xref	_keyint
	.xref	_slot3i
	.xref	v100		* timer tick vector
	.xref	_env

	.xdef	_dskinit
	.xdef	_coninit
	.xdef	_proint
	.xdef	_fdint
	.xdef	_fdinit
	.xdef	_timetck

ifne	automem			* include iff automemory sizing is not hardcoded
	.globl	_autom		* automemory C procedure in main.c
	.xdef	_qt		* boolean for automemory sizing
	.globl	_lastref	* last valid @ in automemory sizing
endc

	.globl	_lentpa		* size of final tpa of users prog; see main.c
	.globl	_lowtpa		* address where user's tpa begins; see main.c

*	.globl	_bconin		* procedure in conio.c
*	.globl	_bconstat	* procedure in conio.c
*	.globl	_bconout	* procedure in conio.c
*	.globl	_charout	* defined in conio.c

	.globl	_ratint		* defined in conio.c as a pointer to a function
	.globl	_newdsk

*
*  globals
*

	.xref	_cmret

*
*  external definitions
*

*				* debug routines
ifne	panic
	.xdef	_cmpanic	*  panic routine
endc

*
*	.xdef	_kdump
*	.xdef	_kputs
*

*				* procedures in biosc.c
	.xdef	_bchistat	*  character input status
	.xdef	_bchostat	*  character output status
	.xdef	_bchgetc	*  character input
	.xdef	_bchputc	*  character output
	.xdef	_bchictl	*  char input  ctrl
	.xdef	_bchoctl	*  char output ctrl
	.xdef	_bblictl	*  blk  input  ctrl
	.xdef	_bbloctl	*  blk  output ctrl
	.xdef	_bchsvec	*  char set vector

	.xdef	_bgetbpb	* procedure in main.c
	.xdef	_bgetmpb	* procedure in main.c
	.xdef	_rwabs		* procedure in rdabs.c
	.xdef	_cntrlst	* procedure in conio.c

*				* init routines
*	.xdef	_hello		*  startup message and wait for key input
	.xdef	_sinit		*  serial init
	.xdef	_pinit		*  printer init

*				* console i/o primitives
	.xdef	_cputc		*  output a char
	.xdef	_cgetc		*  input  a char
	.xdef	_cinstat	*  input  status
	.xdef	_coutstat	*  output status


*
* Firstly, we must get into supervisor mode.  To do this we must know whether
* we are currently running under cp/m (not in sup mode) or else we are booting
* under gemdos (is already in sup mode).
*
_main:
	move	sr,d0
	btst	#13,d0			* 2000 ?
	bne	skpcpm			* branch iff are under gemdos
*
*	cpm assisted boot
*
	movem.l	d0-d7/a0-a7,regsav	* here iff are under cp/m
	move	#$3e,d0
	trap	#2			* trap call gets us into supervisor mode
	move	#$2700,sr
	movem.l	regsav,d0-d7/a0-a7
*
*	Now determine where the user's TPA begins
*
	move.l	#$20000, _lowtpa	* 2 resident O/Ss + sid under TPA
ifeq	automem				* hardcode if no automem comps done
	move.l	#$60000, _lentpa	* length of the user's TPA
endc
	bra	clrbss			* skip over gemdos-booted-specific code

*
*	gemdos original
*

skpcpm:	move.l	#$10000, _lowtpa	* @ at which user's TPA begins
ifeq	automem			* hardcode if no automem computations done
	move.l	#$70000, _lentpa	* length of user's TPA
endc

*
*  clear my bss
*

clrbss:	move.l	#bssstrt,a0	* get beginning @ of our bss
clrmor:	clr.w	(a0)+		* zero out our bss to initialize it
	cmp.l	#$10000,a0
	bne	clrmor	
*
* revector interrupts to us
*
	move.l	#_nmibrk,$7c	* set nmi to do an illegal instruction
	move.l	#keyint,$68	* revector the keyboard interrupt to keyint
	move.l	#_slot3i,$74	* level 5 autovector is slot 3
*	move.l	#_slot3i,$70	* level 6 autovector is slot 2
	move.l	#_fdint,$64
	move.l	#bios,$b4	* bios entry is trap #13

	move.l	#defcrit,v101	* default crit error
	move.l	#deftime,v100	* default timer tick code
	move.l	#defterm,v102	* default terminate handler
	move.l	#defrat,_ratint * ratint is a pointer to a function (in conio.c)

*
*  call bios init entry points
*

	jsr	_fdinit
	jsr	_dskinit
	jsr	_coninit

	move.l	#$b9000,a6
	move.l	a6,a7
	move	d0,$fce01a	* turn on vertical retracer (use fce01a)
	move	#$2000,sr

* (new - ktb 08/09/85)
*	jsr	_hello

	jsr	_sinit
	jsr	_pinit

*
* Do automemory sizing if the proper switch is thrown for computation.
* To do this we must revector an interrupt to ourselves.
*

ifne	automem			* will do automemory sizing
	move.l $8, busvect	* preserve pres bus interrupt vector contents
	move.l	#hndl, $8	* revector
	jsr	_autom		* increment the count of amt of M until bus err
	move.l	busvect, $8	* return to original values
	move.l	_lastref, d0	* last valid reference
	sub.l   _lowtpa, d0	* subtract the base of TPA to get TPA size
	move.l	d0, _lentpa	* This is the size of the TPA in this system
endc

*
* Invoke the command interpreter
*	we should not return from the ci, so if we do, do something intelligent
*		(like panic)
*

	jsr	_cmain

ifne	panic
	move.l	d0,_cmret	* store for peeking in cmpanic
	jsr	_cmpanic	* panic
endc

*
*  brkpt: go to rom
*

_brkpt:	illegal
	rts
*
*  nmi vector
*

_nmibrk: move	#$2000,sr
	jmp	_brkpt

*
*  default rat (mouse) interrupt
*  default term
*  default timer interrupt
*  default critical error handler
*

defrat:
	rts

defterm: 
deftime:
defcrit: 
	rts


*
*  hndl -
*	handle buss error for auto mem sizing
*	(I don't think this works yet - ktb)
*

ifne   automem			* T iff automemory is not hardcoded
hndl:				* interrupt handling routine for automem sizing
	addq	#8, a7		* pop 4 words off of the stack
	move	#1, _qt		* tell C routine to stop:  make boolean true
	move.l	a7, a1		* PC not moved enough fwd w interrupt occurs
	addq	#4, a1		*	so make ret PC val to be 2 larger 
	add	#2, (a1)	*
	rte
endc

*
*  criter -
*	critical error hanlder
*

_criter: move	4(sp),d0	* error code
	move	savesr,-(sp)
	move.l	saveret,-(sp)
	move.l	savesp,-(sp)
	move	d0,-(sp)
	move.l	v101,a0
	move.l	#-1,d0		* abort(-1) is default
	jsr	(a0)
	addq.l	#2,sp
	move.l	d0,d1
	swap	d1
	cmp	#1,d1
	bne	okgo		* retry ?
	move.l	(sp)+,savesp	* yes, restore stuff
	move.l	(sp)+,saveret
	move	(sp)+,savesr
	rts
okgo:	move.l	(sp)+,a0
	move.l	(sp)+,-(a0)	* retadd
	move	(sp)+,-(a0)	* sr
	move.l	a0,sp
	rte			* zap (back to bdos)


****************************************************************************
*	This is the entry point in the bios for all trap 13 calls.
****************************************************************************

bios:	move.w	(sp)+,savesr	* save the status register
	move.l	(sp)+,saveret	* save the return address
	move.l	sp,savesp

	clr.l	a0
	move.w	(sp)+,a0	* get the request function number

*				* >>>>> MAX FUNC VALUE HERE <<<<<
	cmp	#$10,a0		* verify that it is a valid function number
	bgt	nobios		* branch iff invalid number

	add.l	a0,a0		* we will now look up this number in a table
	add.l	a0,a0		* 	multiply the number by four (= an @)
	add.l	#btbl,a0	*	add that number to the base of the table
	move.l	(a0),a0		* 	get the address of procedure from table
	jsr	(a0)		* call the requested function

nobios:	move.l  savesp,sp	* restore entry stack pointer
	move.l	saveret,-(sp)	* restore the return address to the stack
	move.w	savesr,-(sp)	* restore the original status register value
	rte			* note if error nothing is returned
*
*	This is the table of routines accessed for all trap 13 function exec.
*	(all routines prefixed with _bch or _bbl are in biosc.c - ktb Aug 14)
*
btbl:	.dc.l	_bgetmpb	* trap 13, function # 0, found in main.c
	.dc.l	_bchistat	* trap 13, function # 1, char input  status
	.dc.l	_bchgetc	* trap 13, function # 2, char input
	.dc.l	_bchputc	* trap 13, function # 3, char output
	.dc.l	_rwabs		* trap 13, function # 4, found in rdabs.c
	.dc.l	_bsetvec	* trap 13, function # 5, found in biosa.s
	.dc.l	_timetck	* trap 13, function # 6, found in main.c
	.dc.l	_bgetbpb	* trap 13, function # 7, found in main.c
	.dc.l	_bchostat	* trap 13, function # 8, char output status
	.dc.l	medchk		* trap 13, function # 9, found in biosa.s
	.dc.l	_getdrvm	* trap 13, function # A, found in biosa.s
	.dc.l	_cntrlst	* trap 13, function # B, found in conio.c
	.dc.l	_bchictl	* trap 13, function # C, char input  ctrl
	.dc.l	_bchoctl	* trap 13, function # D, char output ctrl
	.dc.l	_bblictl	* trap 13, function # E, blk  input  ctrl
	.dc.l	_bbloctl	* trap 13, function # F, blk  output ctrl
	.dc.l	_bchsvec	* trap 13, function #10, char set vector

*
*  nop -
*
_nop:	rts			* empty function, is called in the table above


*
* medchk -
*	

medchk:	clr.l	d0		* trap 13, function 9
	move	4(sp),d1	* drive
	cmp	#2,d1		* drive c and d are fixed
	bge	safe
	move	_newdsk,d0	* may be unsafe
safe:	rts

*
*  getdrvm -
*

_getdrvm:			* trap 13, function A
	moveq	#5, d0		* both A: and C: but never B: drives occur
	move.l	$74,d1		* now will see if D: drive is here or not
	cmp.l	$70,d1		* have D: iff $74 == $70 else no have
	bne	gdrv1		* branch iff no drive D:
	ori.l	#8, d0		* show by bit-map that have drive d:
gdrv1:	rts


*
*	The following function is trap 13, function # 5 which sets the 
*	exception vector.
*
_bsetvec: move	4(sp),a0	* discover the exception vector # to set
	adda.l	a0,a0		* multiply that number by 4 
	adda.l	a0,a0		*  

	cmpa.l	#$400,a0	* >= 400 if user/Gemdos defined extnd excptn vec
	beq	vsplt		* disallow vector 100 (old timer vector)
	blt	norml		* branch iff vector defined by 68000 hardware
*
*	in extended range.  Limit that to critical error and terminate.
*	if not in that range, ignore the call, otherwise, set a0 to point
*	to the address with the current vector.
*
	cmpa.l  #$408,a0	* is vecnum between 100 and 102 (ie gemdos vec)?
	bgt	vsplt		* if not then invalid vector number so exit(EWF)

	adda.l	#v100-$400,a0	* put in a0 the address of the specified vector
*
*	here we have a legal vector request, and a0 points to the current
*	vector.  Get it.  If the new address is -1, then do NOT replace the
*	current vector.  Otherwise, overlay it with what the caller passed.
*
norml:	move.l	(a0),d0		* move vector value into d0 register
	cmp.l	#-1,6(sp)	* is a specific exception vector table specified
	beq	vsplt		* branch iff NO specific exceptn vector tbl spec
	move.l	6(sp),(a0)	* move into ratint t exceptn vectr @ spec by usr
*
*  exit bsetvec
*
vsplt:	rts
	
*
*  disable, enable interrupts
*

_bcli:	move	#$2700,sr
	rts

_bsti:	move	#$2000,sr
	rts

****************************************************************************
*  keyint -
*	This next procedure is called whenever a keyboard activity occurs.
*	The keyboard interrupt is vectored here.
*
keyint:	movem.l	d0-d2/a0-a2,-(sp)	* save these registers on the sys stack
	jsr	_keyint			* procedure found in conio.c
	bra	retint

*
*  slot3i -
*
_slot3i: movem.l d0-d2/a0-a2,-(sp)	* save these registers on the sys stack
	jsr	_proint

*
*  return from interrupt
*

retint:	movem.l	(sp)+,d0-d2/a0-a2	* restore these regstrs from t sys stack
	rte

	.data
	.even

* ------------------- keyboard mapping tables --------------------------------
	.globl	_unshift	* regular key values (not shifted,ctrl,etc)
	.globl  _unshft1

_unshift:		* for scan codes greater than 40h
	.dc.b	$2d,$3d,$5c,$00,$70,$08,$0d,$00
	.dc.b	$0d,$00,$00,$00,$2f,$00,$7f,$00
	.dc.b	$39,$30,$75,$69,$6a,$6b,$5b,$5d
	.dc.b	$6d,$6c,$3b,$27,$20,$2c,$2e,$6f
	.dc.b	$65,$36,$37,$38,$35,$72,$74,$79
	.dc.b	$60,$66,$67,$68,$76,$63,$62,$6e
	.dc.b	$61,$32,$33,$34,$31,$71,$73,$77
	.dc.b	$09,$7a,$78,$64,  0,  0,  0,  0

_unshft1:		* for scan keys between 0x20 and 0x2f
	.dc.b	$1b,$00,$00,$00,$00,$00,$00,$00
	.dc.b	$00,$00,$00,$00,$00,$00,$00,$0d
	
	.globl	_shiftbl	* shifted keys
	.globl	_shift1

_shiftbl:		* for scan codes greater than 40h
	.dc.b	$5f,$2b,$7c,$00,$50,$08,$0d,$00
	.dc.b	$0d,$30,$00,$00,$3f,$00,$7f,$00
	.dc.b	$28,$29,$55,$49,$4a,$4b,$7b,$7d
	.dc.b	$4d,$4c,$3a,$22,$20,$3c,$3e,$4f
	.dc.b	$45,$5e,$26,$2a,$25,$52,$54,$59
	.dc.b	$7e,$46,$47,$48,$56,$43,$42,$4e
	.dc.b	$41,$40,$23,$24,$21,$51,$53,$57
	.dc.b	$09,$5a,$58,$44,  0,  0,  0,  0

_shift1:		* for scan keys between 0x20 and 0x2f
	.dc.b	$1b,$00,$34,$36,$00,$00,$00,$38
	.dc.b	$00,$00,$00,$32,$2e,$00,$00,$0a

	.globl	_capstbl	* caps lock 
_capstbl:
	.dc.b	$2d,$3d,$5c,$00,$50,$08,$0d,$00
	.dc.b	$0d,$30,$00,$00,$2f,$31,$7f,$00
	.dc.b	$39,$30,$55,$49,$4a,$4b,$5b,$5d
	.dc.b	$4d,$4c,$3b,$27,$20,$2c,$2e,$4f
	.dc.b	$45,$36,$37,$38,$35,$52,$54,$59
	.dc.b	$00,$46,$47,$48,$56,$43,$42,$4e
	.dc.b	$41,$32,$33,$34,$31,$51,$53,$57
	.dc.b	$09,$5a,$58,$44,  0,  0,  0,  0

	.globl	_ctltbl		* control keys
_ctltbl:
	.dc.b	$1f,$3d,$1c,$00,$10,$08,$0d,$00
	.dc.b	$0d,$30,$00,$00,$2f,$31,$7f,$00
	.dc.b	$39,$30,$15,$09,$0a,$0b,$1b,$1d
	.dc.b	$0d,$0c,$3b,$27,$20,$2c,$2e,$0f
	.dc.b	$05,$1e,$37,$38,$35,$12,$14,$19
	.dc.b	$7e,$06,$07,$08,$16,$03,$02,$0e
	.dc.b	$01,$00,$33,$34,$31,$11,$13,$17
	.dc.b	$09,$1a,$18,$04,  0,  0,  0,  0

	.globl	_scancd		* ibm scan keys
	.globl  _scancd1
_scancd:		* IBM scan codes equiv to our scan codes 
	.dc.b	$0c,$0d,$2b,$00,$19,$0e,$47,$00
	.dc.b	$1c,$52,$00,$00,$35,$3b,$0e,$00
	.dc.b	$0a,$0b,$16,$17,$24,$25,$1a,$1b
	.dc.b	$32,$26,$27,$28,$39,$33,$34,$18
	.dc.b	$12,$07,$08,$09,$06,$13,$14,$15
	.dc.b	$29,$21,$22,$23,$2f,$2e,$30,$31
	.dc.b	$1e,$03,$04,$05,$02,$10,$1f,$11
	.dc.b	$0f,$2c,$2d,$20,  0,  0,  0,  0

_scancd1:		* same as above except our scan codes {20h .. 2fh}
	.dc.b	$01,$37,$4b,$4d,$41,$42,$43,$48
	.dc.b	$3e,$3f,$40,$50,$53,$3c,$3d,$1c

	.globl _alt
_alt:			* alt keys for scan codes >= 40h 
	.dc.b	$00,$00,$00,$00,$19,$00,$00,$00
	.dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	.dc.b	$80,$81,$16,$17,$24,$25,$00,$00
	.dc.b	$32,$26,$00,$00,$00,$00,$00,$18
	.dc.b	$12,$7d,$7e,$7f,$7c,$13,$14,$15
	.dc.b	$00,$21,$22,$23,$2f,$2e,$30,$31
	.dc.b	$1e,$79,$7a,$7b,$78,$10,$1f,$11
	.dc.b	$00,$2c,$2d,$20,$00,$00,$00,$00
* ----------------------------------------------------------------------------

	.even
_env:	.dc.b	"COMSPEC=C:\COMMAND.PRG",0,0
	.even
fsstak:	.dc.l	fstrt

crlf:
	.dc.b	13,10,0

	.bss
	.even
_lowtpa: .ds.l  1
_lentpa: .ds.l	1		* for automemory sizing of primary memory
ifne	automem			* T iff not hardcoded but must be figured out
_qt:	.ds.w	1		* boolean f automem sizing
_lastref: .ds.l	1		* last valid @ in automem sizing
busvect: .ds.l	1		* store the address of orig bus error vector
endc
bssstrt: .ds.w	1
biosav:	.ds.l	1
savesp: .ds.l	1
saveret: .ds.l	1
savesr:	.ds.w	1
retshell: .ds.l	1
regsav:	.ds.l	16
	.ds.l	1000
fstrt:	.ds.l	1
obdos:	.ds.l	1
v100:	.ds.l	1		* Gemdos defined extended vector for timer tick
v101:	.ds.l	1		* Gemdos def ext vect f Critical error handling
v102:	.ds.l	1		* Gemdos def extended vector f terminate handler
*


	.even
_cmret:	.ds.l	1		* store return code from cmain here
	.end

