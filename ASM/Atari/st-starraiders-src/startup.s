*
*	STARTUP.S   Startup File for StarRaiders/Menu
*
	.text
*
*	PUBLIC SYMBOLS
*
	.globl	_ctrl_cnts
	.globl	_crystal
	.globl	_highscores
	.globl	_memerror
	.globl	savessp
	.globl	screen0
	.globl	screen1
	.globl	_titlescreen
	.globl	x160tbl
	.globl	_xbios

*
*	HARDWARE CONSTANTS
*
palette	.equ	$ff8240		* color0 - palette base address

*
*	SYSTEM CONSTANTS
*
conterm	.equ	$484		* Console Keyboard Control

*
*	GAME CONSTANTS
*
scorlen	.equ	(12*42)+30	* Length of Hi-Score Buffer

*
*	System Initialization
*
start:
	move.l	a7,a5
	move.l	#mystack,a7	* Get Our Own Local Stack
	move.l	4(a5),a5	* a5 = basepage address
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0	* RAM req'd = text+bss+data+BasePageLength
	move.l	d0,d4		* d4 = RAM req'd
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move	d0,-(sp)	* junk word
	move	#$4a,-(sp)
	trap	#1		* Return Excess Storage
	add.l	#12,sp

	move	#2,-(sp)
	trap	#14
	add.l	#2,sp
	move.l	d0,screen0	* Share System Physical Screen
	cmp.l	4(a5),d0
	bne	getmem		* IF (We Have High Memory) THEN
	clr	_memerror
	sub.l	#$8000,d0	* CHEAT!! Use RAM Just Below the Screen
	add.l	a5,d4		* d4 = highest used address
	cmp.l	d0,d4
	ble	cheat0
	move	#1,_memerror	* IF (Prog-Top Within Screen RAM) THEN ERROR
cheat0:	move.l	d0,screen1
	bra	memfail

getmem:	move.l	#$7e00,-(sp)	* ELSE We Must MALLOC Our Screen
	move	#$48,-(sp)
	trap	#1
	addq.l	#6,sp		* MALLOC A 32,000-Byte Buffer
	move	#1,_memerror
	tst.l	d0
	beq	memfail		* IF (Sufficient Memory) THEN
	clr	_memerror
	move.l	d0,memalloc	* Save ptr to Return Later
	add.l	#$100,d0
	and.l	#$ffffff00,d0
	move.l	d0,screen1	* Buffers for Double-Buffering
memfail:

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1		* enter supervisor mode
	addq.l	#6,sp
	move.l	d0,savessp	* save old ssp

	jsr	readscore	* Read the High Score File

	move.b	conterm,saveterm
	move.b	#2,conterm	* Turn-Off Bell and Click, Allow Repeat

	movea.l	#palette,a0
	movea.l	#oldpal,a1
	movea.l	#mypal,a2
	move	#15,d0
paloop:
	move.w	(a0),(a1)+	* save old color palette
	move.w	(a2)+,(a0)+	* create new color palette
	dbra	d0,paloop

	jsr	linanit		* get pointer to the 8x8 font

	move.l	savessp,-(sp)
	move.w	#$20,-(sp)
	trap	#1		*return to user mode
	addq.l	#6,sp

	clr	d0
	movea.l	#x160tbl,a0
	move	#199,d1
xm160lp:			* build multiply-by-160 lookup table
	move	d0,(a0)+
	add	#160,d0
	dbra	d1,xm160lp

	jsr	rplmasker	* Build Masks for REPLACE stamps

*
*	Window Menu Manager
*
	jsr	_main		* Run the MENU Manager

*
*	System Tear-Down
*
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1		* enter supervisor mode
	addq.l	#6,sp
	move.l	d0,savessp	* save old ssp

	jsr	writescore	* Write the High Score File

	movea.l	#oldpal,a0
	movea.l	#palette,a1
	move	#15,d0
unpaloop:
	move.w	(a0)+,(a1)+
	dbra	d0,unpaloop	* restore old color palette

	move.b	saveterm,conterm	* Restore Keyboard State

	move.l	savessp,-(sp)
	move.w	#$20,-(sp)
	trap	#1		*return to user mode
	addq.l	#6,sp

	move	#23,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,savessp	* Get IKBD Date/Time
	move	d0,-(sp)
	move	#$2d,-(sp)
	trap	#1
	addq.l	#4,sp		* Set GEMDOS Time
	move	savessp,-(sp)
	move	#$2b,-(sp)
	trap	#1
	addq.l	#4,sp		* Set GEMDOS Date

	tst	_memerror
	bne	memfaild	* IF (Memory Was Allocated) THEN
	move.l	memalloc,-(sp)
	move	#$49,-(sp)
	trap	#1
	addq.l	#6,sp		* MFREE Buffer Storage
memfaild:
	clr.w	-(sp)
	trap	#1		* return to GEMDOS

*
*	SUBROUTINES
*

*
*	READSCORE   Reads High Score Table from Disk.
*
*	Given:
*		nothing
*
*	Returns:
*		High Score Buffer updated
*
*	Register Usage:
*		destroys a0-a3 and d0-d3
*
*	Externals:
*		code
*
readscore:
	move.w	#0,-(sp)
	move.l	#scorfnam,-(sp)	
	move.w	#$3d,-(sp)
	trap	#1		
	addq.l	#8,sp			* open Score file for read only
	move.w	d0,filehndl
	bmi	rdfail			* IF (Error) Skip This
	move.l	#decode,-(sp)		* use Hi-Score Buffer
	move.l	#scorlen+2,-(sp)	* Hi-Score file length
	move.w	filehndl,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	adda.w	#12,sp			* read entire file
	tst.l	d0
	bmi	rdoops			* IF (error) THEN No File
	jsr	code			* ELSE Decode the Data
	move.w	filehndl,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp			* close file
	rts
rdoops:					* Read Error
	move.w	filehndl,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp			* close file & FALL THRU
rdfail:
	movea.l	#hsdefault,a0
	movea.l	#_highscor,a1
	move	#267,d0
	jsr	wordcopy		* Create Default High-Score Table
	rts


*
*	WRITESCORE   Writes High Score Table to Disk.
*
*	Given:
*		nothing
*
*	Returns:
*		High Score File updated
*
*	Register Usage:
*		destroys a0-a3 and d0-d3
*
*	Externals:
*		code,randu
*
writescore:
	jsr	randu
	and	#-2,d0
	move	d0,decode		* Generate Word-Aligned Decode
	jsr	code			* Encode the High Scores

	move.w	#1,-(sp)
	move.l	#scorfnam,-(sp)	
	move.w	#$3d,-(sp)
	trap	#1		
	addq.l	#8,sp			* open Score file for WRITE only
	move.w	d0,filehndl
	bpl	dowrite			* IF (Error) THEN

	cmp	#-33,d0
	beq	nofile	
	rts				* IF (Fatal Error) ABORT
nofile:	move.w	#02,-(sp)
	move.l	#scorfnam,-(sp)	
	move.w	#$3c,-(sp)
	trap	#1		
	addq.l	#8,sp			* CREATE Score file
	move.w	d0,filehndl
	bpl	dowrite
	rts				* IF (Unable to Create) ABORT

dowrite:				* ELSE (Write new file)
	move.l	#decode,-(sp)		* use Hi-Score Buffer
	move.l	#scorlen+2,-(sp)	* Hi-Score file length
	move.w	filehndl,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	adda.w	#12,sp			* write file

	move.w	filehndl,-(sp)		* Close REGARDLESS of Error Status
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	rts


*
*	CODE	Encode/Decode High-Score Table
*
*	Given:
*		DECODE = low-word "tape" address
*
*	Returns:
*		High Score Table Coded
*
*	Register Usage:
*		destroys a0-a1 and d0-d1
*
*	Externals:
*		none
*
code:
	move.l	#$0fc0000,d0
	move	decode,d0
	move.l	d0,a0			* a0 = ptr to "one-time-tape"
	movea.l	#_highscor,a1		* a1 = ptr to High Scores
	move	#(scorlen/2)-1,d1
codelp:					* FOR (all words of data) DO
	move	(a0)+,d0
	eor	d0,(a1)+		* Exclusive OR
	dbra	d1,codelp
	rts

*
*	C-Callable SUBROUTINES
*

*
*	For GEMAES calls from AESBIND.ARC or cryslib.o
*
_crystal:
	move.l	4(a7),d1
	move.w	#200,d0
	trap	#2
	rts


*
*	trap14	Taken straight from the hitchhikers guide
*
_xbios:
	move.l	(sp)+,saveret	*pop return address
	trap	#14
	move.l	saveret,-(sp)	*restore return address
	rts


*
*	Build Title Screen
*
_titlescreen:
	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	movea.l	d0,a2		* a2 = Physical Screen ptr

	movea.l	#topcock,a0
	movea.l	a2,a1
	adda.l	#(11*160),a1	* offset for menu-bar
	move	#(14*80),d0
	jsr	wordcopy	* copy top of panel to screen
	move.l	#titlepic,a0
	movea.l	a2,a1
	adda.l	#(25*160),a1	* offset to title-picture
	move	#(109*80),d0
	jsr	wordcopy	* copy title to screen
	move.l	#botcock,a0
	movea.l	a2,a1
	adda.l	#(134*160),a1	* offset into screen
	move	#(66*80),d0
	jsr	wordcopy	* copy bottom of panel to screen

	move.l	a2,screen
	move	#96,d0
	move	#134,d1
	movea.l	#titlewal,a0
	jsr	wall_blt	* Special .. Add Active Viewer

	rts

*
*	DATA STORAGE
*
	.data

hsdefault:			* Default High-Score Table
	.dc.b	" Dr. Z.      C STAR COMMANDER, CLASS 1",0,0,0,0
	.dc.b	" J. Domurat  P COMMANDER, CLASS 1     ",0,0,0,0
	.dc.b	" Mary K.     W CENTURION, CLASS 1     ",0,0,0,0
	.dc.b	" Bradley Jon C WARRIOR, CLASS 1       ",0,0,0,0
	.dc.b	" D. Staugas  P ACE, CLASS 1           ",0,0,0,0
	.dc.b	" Leonard T.  P PILOT, CLASS 1         ",0,0,0,0
	.dc.b	" M. Schmal   P LIEUTENANT, CLASS 1    ",0,0,0,0
	.dc.b	" L. Dyer     P NOVICE, CLASS 1        ",0,0,0,0
	.dc.b	" C. Suko     P ROOKIE, CLASS 1        ",0,0,0,0
	.dc.b	" Jim E.      N ROOKIE, CLASS 2        ",0,0,0,0
	.dc.b	" D. Mui      N ROOKIE, CLASS 3        ",0,0,0,0
	.dc.b	" K.U.J.      N ROOKIE, CLASS 4        ",0,0,0,0
	.dc.b	"GARBAGE SCOW CAPTAIN, CLASS 4",0

scorfnam:			* High-Score Table File Name
	.dc.b	"hiscores.rjz",0

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

*
*	RANDOM STORAGE
*

	.bss

saveterm:
	.ds.b	1		* Old Console Status

	.even

	.ds.l	256		* (stack body)
mystack:
	.ds.l	1		* Local Stack Storage
oldpal:
	.ds.l	16		* old color palette
savessp:
	.ds.l	1		* passed ssp
saveret:
	.ds.l	1		* storage for C-return address

filehndl:			* Open File Handle
	.ds.w	1
decode:				* Secret Decoder Ring
	.ds.w	1
_highscores:			* High Score Table
	.ds.w	267		* 12-Scores * 42-Bytes
*				  30 Bytes Last Score

_memerror:
	.ds.w	1		* Memory Allocation Error Flag
memalloc:
	.ds.l	1		* Allocated Memory ptr
screen0:
	.ds.l	1		* screen buffer0 address
screen1:
	.ds.l	1		* screen buffer1 address

x160tbl:
	.ds.w	200		* multiply-by-160 lookup table

	.end
