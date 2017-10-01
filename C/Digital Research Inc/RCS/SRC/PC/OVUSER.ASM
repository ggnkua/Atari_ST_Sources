	title	Runtime	Overlay	Loader User Module for Plink86
	subttl	Written	by Dave	Hirschman, Phoenix Software Associates,	Ltd.
	.sfcond
Cpm86	equ 0
;
; Copyright 1999 by Caldera Thin Clients, Inc.
; This software is licenced under the GNU Public License
; Please see LICENSE.TXT for further information.
;
; bfb,  7 may 85: check for vianet 3.0 emulation
; bfb,  6 may 85: $OVOM$ contains open mode bits, in case network running
;			   set $OVDOS2 at same time
;
		;******************************
		;* Overlay Loader User Module *
		;******************************
;    Users may modify this routine and link it into their programs to change the
;way the Plink86 overlay loader	operates.  All messages	generated at runtime,
;as well as any	communications carried out with	the operator, are handled here.
;This module also controls the process by which	the linkage editor searches for
;the overlays.	Modifications should be	made with care:	 Phoenix will probably
;be unsympathetic to those who make changes and	then expect us to help with the
;debugging.  However, virtually	any modifications needed to make your
;application run more smoothly may be accomplished by making minor changes to
;this code.  Also, see the "SAMPLE.ASM"	file for a much	simpler	version	of
;this module.

;    The "Cpm86" symbol	is used	as a conditional compilation flag that
;generates a Cpm86 version when	set to a non-zero value.  This version (and the
;overlay loader	itself)	will probably only work	with the Cpm86 version of the
;Lattice C compiler.  Many of the changes for Cpm86 involve changing
;segmentation, groups, and addressing:	Cpm86 supports only short addresses.
;
;    As	the program begins execution the $OVLYIU routine is called before
;the application code executes.	 Initialization	is performed here.  The	DS
;register is set to enable local data to be accessed, but the ES register
;points	to the MSDOS program segment prefix.  The standard user	module uses
;this to obtain	the address of the environment (specifically the PATH string).
;These strings are directory names used	by the system to find executable files,
;and they are used in the same way here	to find	overlay	files.
;
;    The overlay loader	calls symbol $OVLYxU each time it is about to open a
;new overlay file (keep	in mind	that a file can	contain	several	overlays), or
;whenever a fatal error	is encountered while reading an	overlay.  The name of
;the overlay file being	requested is provided in a string area labled by public
;symbol	$OVLYFN, and may be modified if	desired.  The file name	must be
;terminated by a NUL, and the string area must be at least 13 bytes
;long.	As initialized by the overlay loader, the file name consists of	a
;name and type only, of	maximum	length 8 and 3 chars respectively, separated
;by a period.
;
;    A result code is provided in the AL register describing what happened
;during	the previous attempt to	load an	current	overlay	from the current file:
;
;0 - The first attempt to load an overlay has not been made yet.
;1 - The overlay file was not found.
;2 - The overlay file couldn't be opened due to	a disk error.  These errors
;    are things	like no	disk in	drive, drive not ready,	or media errors	such
;    as	seek and CRC problems.
;3 - The overlay couldn't be read completely (premature	EOF).  The file
;    is	probably smashed.
;4 - The overlay couldn't be read because of a disk error (drive not ready,
;    media error, etc).
;5 - An	"invalid handle" error was returned when the file was accessed.
;    Possible the file was closed because another task was terminated (due
;    to	the strange way	MSDOS 2	tries to support multi-tasking).
;
;    After possibly making modifications to the	overlay	file name, the $OVLYxU
;routine must return, in the AL	register, a function code instructing the
;overlay loader	how to handle the next attempt to load the overlay:
;
;0 - Try to load the overlay from the file name	given in $OVLYFN.
;1 - Give up.  The program is normally terminated when this code is received.
;    However, if the user program called the overlay loader itself (at the
;    $LOAD$ routine, see Plink86 user manual), an error	code may be returned to
;    the user program at its option.
;
;    The standard routine shown	here uses the sequence number to try various
;strategies in order.  First, the unmodified file name is tried.  Next,	a
;default string	is appended to the front of the	given file name.  This string
;starts	out as "A:".  Beginning	with the third attempt file name prefixes are
;obtained from the MSDOS 2.0 PATH (if any).  After these have been exhausted
;subsequent attempts are handled the same as the second	attempt, after giving
;the operator an opportunity to	modify the default string.  The	operator may
;also terminate	the program at this point (code	1 is returned to the overlay
;loader).
;
	name	OVUSERM
;
	public	$OVLYMU	;entry point for MSDOS user routine
	public	$OVLYIU	;entry point to	initialize user	module
	public	$OVLYFN	;overlay file name string
;
;********
;* Data	*
;********
;
CR	equ	0DH
LF	equ	0AH
Sep	equ	'\'	;char to separate Msdos	2.0 directory names
;
OVdata	segment	word public 'OVERLAYLOADER'
	extrn  $OVOM$: byte		;open mode for overlay files - 
 						;	network may be running => shared files
	extrn  $OVDOS2: byte	;-1 => MSDOS >= 2.0 running

EnvPar	dw	0	;paragraph address of environment
EnvOff	dw	0	;offset	to PATH	string
TryEnv	dw	0	;current offset	to PATH	string
Path	db	"PATH"	;environment name for executable files path string
Psize =	4		;length	of Path
FNlen	equ 80
$OVLYFN	db FNlen dup (?) ;overlay file name work area
;
OVdata	ends
;
;********
;* Code	*
;********
;
CODE	segment	 public	'CODE'
	extrn  OvlErr: far
CODE	ends

OVcode	segment	 public	'OVERLAYLOADER'
	assume cs:OVcode, ds:OVdata, es:OVdata
;
;*******
;* Sys *
;*******
;This is a macro for doing operating system calls.
;
Sys	macro	Fun,Arg		;;macro	for invoking Operating system functions
	mov	AH,Fun
	int	21H
	endm
;
;***********
;* IsItSep *
;***********
;The zero flag is set iff the character	in AL is a valid path name separator
;or the	colon after a drive id.	 If not, AL is also changed to a backslash.
;
IsItSep	proc	near
	cmp	AL,':'		;a valid separator?
	jz	GotSep
	cmp	AL,'/'
	jz	GotSep
	cmp	AL,'\'
	jz	GotSep
	mov	AL,Sep		;No, use standard one.
GotSep:	ret
IsItSep	endp
;
;**********
;* Append *
;**********
;The file name prefix pointed to by BP:SI is appended to the front of the file
;name string.  Much of the code	here involves moving segment registers around,
;because the prefix may	exist in a different segment if	it is coming from the
;PATH in the environment area.	At the end of this routine SI points to
;the end of the	source prefix string.  If there	is no separator	at the end
;of the	prefix one is added (Sep).
;
Append	proc	near
	mov	DS,BP		;DS:SI points to prefix
	push	SI
	xor	DX,DX		;DX := length of file name prefix
Count:	lodsb
	inc	DX
	or	AL,AL
	jz	CntEnd
	cmp	AL,' '
	jz	CntEnd
	cmp	AL,';'
	jnz	Count
CntEnd:	dec	DX
	pop	SI
	;fall through

Appnd2:	mov	BX,ES		;save current DS and ES	in BX.
	mov	DS,BP		;DS:SI points to prefix
	push	SI
	add	SI,DX		;get to end of prefix, look at last char.
	dec	SI
	lodsb			;save it in AL.
	mov	DS,BX		;restore my DS.
	call	IsItSep		;see if	last char is separator,	save
	mov	AH,0		;separator in AL.
	jnz	Shift		;no, but now have it in	AL
	inc	AH		;AH is # of chars not used in prefix.
	dec	DX		;leave out separator, will put back later.
Shift:	mov	SI,offset $OVLYFN	;DS:SI -> end of file name
	push	SI		;ES:DI -> end of file name area
	add	SI,FNlen-1
	mov	DI,SI
	inc	DX
	sub	SI,DX
	mov	CX,FNlen	;shift file name up by length of prefix.
	sub	CX,DX		;plus separator byte.
	dec	DX
	std
	rep	movsb
	cld
	pop	DI		;move prefix to	file name area.
	pop	SI
	mov	DS,BP
	mov	CX,DX
	rep	movsb
	mov	DS,BX		;restore my DS
	mov	byte ptr [DI],AL ;add file name separator.
	mov	AL,AH		;get SI	to end of prefix
	mov	AH,0
	add	SI,AX
	ret
Append	endp
;
;**********
;* TryPth *
;**********
;If MSDOS 2.0 is running, the file name	prefix is set up as the	next directory
;name from the PATH string in the environment, if any.
;
TryPth:	
	mov	SI,TryEnv		;try next path
	or	SI,SI
	jz	NoPath
	push	DS			;DS:SI->next environment string
	mov	AX,EnvPar
	mov	DS,AX
;
TryP1:	lodsb				;get to	start of next directory	path
	cmp	AL,';'
	jz	TryP1
	cmp	AL,' '
	jz	TryP1
	dec	SI
;
	test	byte ptr [SI],-1	;anything here?
	mov	BP,DS			;(BP ->	prefix paragraph)
	pop	DS			;(restore DS)
	jz	NoPath
	call	Append			;append to file name.
	mov	TryEnv,SI		;save new ptr for next time.
	clc				;fn ready to use now.
	ret
;
NoPath:	stc
	ret
;
;***********
;* $OVLYxU *
;***********
;this routine calls an assembler procedure that sets up th
;segment registers and call a 'C' procedure to throw up an alert
;it also closes the file before an overlay is loaded
;
$OVLYMU	proc	near
	cld			;all increments	forward.
	or	AL,AL		;first attempt on this overlay file?
	jz	First
	cmp	AL,5		;If handle error, try starting over.
	jnz	Error
;
First:
	mov	bx,EnvOff
	mov	TryEnv,bx
	jmp	short Return	;try file name as is.
;
Error:	
Try2:	call	TryPth		;Try next MSDOS 2 PATH
	jnc	Return		;Any left?
	call	OvlErr
;
Return:	mov	AL,0		;Tell loader to	try current file name.
	ret
;
$OVLYMU	endp
;
;***********
;* $OVLYIU *
;***********
;This is the initialization routine for	the user module.  If we	are running
;under MSDOS 2 the environment is searched for the PATH	string.	 If MSDOS 3
;is running the	path name used to execute the program appears at the end of
;the environment and is	used instead of	the PATH.
;    The environment paragraph address is given	in the program prefix (pointed
;to by ES as the program begins	execution) at offset 2CH.  The environment
;consists of strings separated by nuls,	with an	extra nul at the end.  Each
;string	has a name at the front	and a value at the end,	separated by an	equal
;sign.	The string searched for	here has a name	of "PATH".  The	value portion
;of this string	is a list of directory names separated by semi-colons.	The
;command processor looks in these directories to find executable files,	so
;program overlays might	also be	found there.  If the "PATH" string is found,
;its address is	saved for later	use.
;    MSDOS 3 passes the name the program was executed under as a string
;following the end of the environment.  There's an extra word in front of it:
;I don't know what it is.  The MSDOS ref. says it's a "word count" but it
;always seems to be set to a one.  This routine ignores it.
;
Space	proc	near		;scan ES:DI until a non-blank is found.
	mov	AL," "
	repz	scasb
	dec	DI		;get ES:DI back to non-blank
	ret
Space	endp
;
$OVLYIU	proc	near
	mov	$OVDOS2, -1		;   -1 => use dos 2.0 file handles
	mov	AL, 0H			;   default to standard file open mode
NoPax:	mov	$OVOM$, AL		;   set my open mode
	mov	BX,ES:2CH		;Save environment paragraph address.
	mov	EnvPar,BX
	mov	ES,BX			;set ES to environment
	xor	DI,DI			;DI is offset into it.
	cld				;auto-increment	forward.
Srch:	test	byte ptr ES:[DI],-1	;end of	environment?
	jz	E1
	mov	SI,offset Path		;no, compare next string
	mov	CX,Psize
	repe cmpsb
	mov	CX,-1			;for REP instructions.
	jz	GotIt			;Is it a match?
;
Skip:	mov	AL,0			;No, get past string and
	repnz	scasb			;the nul terminating it.
	jmp	Srch
;
GotIt:	call	Space			;Got it:  skip blanks.
	cmp	byte ptr ES:[DI],'='	;at end	of "PATH"?
	jnz	Skip			;no, had match on prefix.
	inc	DI			;yes, get over =.
	call	Space			;and spaces.
	mov	EnvOff,DI		;save pointer to it.
E1:
IUend:
	ret
$OVLYIU	endp
;
OVcode	ends
	end
