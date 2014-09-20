
;Utility functions
;NOTE - we cannot disable Timer C on TOS 2.06 (or later) as it will cause
;problems with disc access and cause endless loops

ENABLEVAPCHECK = 1							;Set to 1 to enable VAP check (Hatari does not emulate on Falcon)

MACHINE_ST = 0								;Machine types
MACHINE_STE = 1
MACHINE_TT = 2
MACHINE_FALCON = 3

	SECTION	TEXT

;----------------------------------
;Initialise utility routines
utilinit
	move.w	#MACHINE_ST,machine
	bsr		utilrandseed					;Create random seeds
	move.b	rndseed8,rndnum8
	move.w	rndseed16,rndnum16
	moveq.l	#0,d0
	move.l	d0,vblcount
	move.l	d0,blankingcount
	move.l	d0,nextscreen
	move.l	d0,nextpalette
	move.w	d0,nextrasterset
	move.w	d0,rasterset
	move.l	d0,phybse
	move.l	d0,logbse
	move.l	d0,displaybse
	move.l	d0,offscreenbse

	lea		screenlines,a0
	moveq.w	#0,d0							;Offset
	move.w	#160,d1							;Byte offset to next line (ie 320 pixels)
	move.w	#200-1,d2
.loop
	move.w	d0,(a0)+						;Store offset for each screen line
	add.w	d1,d0
	dbra.w	d2,.loop

	bra		utilsfindmachinetype			;Find machine we're running on (does RTS)

;----------------------------------
;Enter supervisor mode, pass a0.l as old super vector
utilsupermode
	move.l	a0,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

;----------------------------------
;Set new VBL interrupt vector, pass a0.l as new interrupt routine
utilsetvblvector
	move.w	#$2700,sr						;Disable interrupts
	move.l	a0,$70.w						;Set new VBL vector
	move.w	#$2300,sr						;Enable interrupts
	rts

;----------------------------------
;Store hardware state
utilstorestate
	move.w	#$2700,sr						;Disable interrupts
	move.l	$8.w,oldbuserror				;Store vectors
	move.l	$c.w,oldaddresserror
	move.l	$10.w,oldillegalins
	move.l	$14.w,olddivzero
	move.l	$70.w,oldvbl
	move.l	$110.w,oldtimerd
	move.l	$114.w,oldtimerc
	move.l	$118.w,oldikbd
	move.l	$120.w,oldtimerb
	move.l	$134.w,oldtimera
	move.l	$404.w,oldgemdoserror
	move.b	$fffffa07.w,oldintenablea		;Store MFP registers
	move.b	$fffffa09.w,oldintenableb
	move.b	$fffffa13.w,oldintmaska
	move.b	$fffffa15.w,oldintmaskb
	move.b	$fffffa19.w,oldtimeracontrol
	move.b	$fffffa1b.w,oldtimerbcontrol
	move.b	$fffffa1d.w,oldtimercdcontrol
	move.b	$ffff8201.w,oldvideohighbyte
	move.b	$ffff8203.w,oldvideomidbyte
	move.b	$ffff820a.w,oldvideosync
	movem.l	$ffff8240.w,d0-d7				;Store 16 colour palette
	movem.l	d0-d7,oldpalette
	move.w	#$2300,sr						;Enable interrupts

	bra		utilstopmfp						;Disable all MFP timers (does RTS)

;----------------------------------
;Restore hardware state
utilrestorestate
	bsr		utilstopmfp						;Disable all MFP timers
	
	move.w	#$2700,sr						;Disable interrupts
	move.l	oldbuserror,$8.w				;Restore vectors
	move.l	oldaddresserror,$c.w
	move.l	oldillegalins,$10.w
	move.l	olddivzero,$14.w
	move.l	oldvbl,$70.w
	move.l	oldtimerd,$110.w
	move.l	oldtimerc,$114.w
	move.l	oldikbd,$118.w
	move.l	oldtimerb,$120.w
	move.l	oldtimera,$134.w	
	move.l	oldgemdoserror,$404.w
	move.b	oldvideohighbyte,$ffff8201.w
	move.b	oldvideomidbyte,$ffff8203.w
	move.b	oldvideosync,$ffff820a.w
	move.b	oldtimeracontrol,$fffffa19.w
	move.b	oldtimerbcontrol,$fffffa1b.w
	move.b	oldtimercdcontrol,$fffffa1d.w
	move.b	oldintmaska,$fffffa13.w
	move.b	oldintmaskb,$fffffa15.w
	move.b	oldintenablea,$fffffa07.w		;Restore MFP registers
	move.b	oldintenableb,$fffffa09.w
	movem.l	oldpalette,d0-d7				;Restore palette
	movem.l	d0-d7,$ffff8240.w
	move.w	#$2300,sr						;Enable interrupts
	rts

;----------------------------------
;Stop MFP timers
utilstopmfp
	move.w	#$2700,sr						;Disable interrupts
	move.b	#0,$fffffa19.w					;Stop Timer A in Timer A Control
	move.b	#0,$fffffa1b.w					;Stop Timer B in Timer B Control
	and.b	#$f8,$fffffa1d.w				;Stop Timer D in Timer C+D Control (leave Timer C alone)
	bclr.b	#5,$fffffa07.w					;Disable Timer A in Interrupt Enable A
	bclr.b	#0,$fffffa07.w					;Disable Timer B in Interrupt Enable A
	bclr.b	#4,$fffffa09.w					;Disable Timer D in Interrupt Enable B	
	bclr.b	#5,$fffffa13.w					;Mask Timer A in Interrupt Mask A
	bclr.b	#0,$fffffa13.w					;Mask Timer B in Interrupt Mask A
	bclr.b	#4,$fffffa15.w					;Mask Timer D in Interrupt Mask B
	bclr.b	#5,$fffffa0b.w					;Clear Timer A in Interrupt Pending A
	bclr.b	#0,$fffffa0b.w					;Clear Timer B in Interrupt Pending A
	bclr.b	#4,$fffffa0d.w					;Clear Timer D in Interrupt Pending B
	move.w	#$2300,sr						;Enable interrupts
	rts

;----------------------------------
;Check cookie jar to find machine we're running on
utilsfindmachinetype
	move.w	#MACHINE_ST,machine				;Default to ST
	move.l	$5a0.w,d0						;Read cookie jar pointer
	beq.s	.done							;If no cookie jar we're a basic ST

	move.l	d0,a0
.loop
	move.l	(a0)+,d0						;Read cookie identifier
	beq.s	.done							;Check for end of cookie jar
	move.l	(a0)+,d1						;Read cookie value
	cmp.l	#'_MCH',d0						;Check for '_MCH'
	beq.s	.foundmachine					;Store machine type
	bra.s	.loop

.foundmachine
	swap	d1								;Get _MCH value 0=ST, 1=STe, 2=TT, 3=Falcon
	move.w	d1,machine						;And store as MACHINE_xx
.done
	rts

;----------------------------------
;Set Atari ST low resolution
utilsetlowres
	move.w	#0,-(sp)						;Low resolution
	move.l	#-1,-(sp)						;Retain physical screen base
	move.l	#-1,-(sp)						;Retain logical screen base
	move.w	#5,-(sp)						;Setscreen
	trap	#14
	adda.w	#12,sp
	rts

;----------------------------------
;Find physical screen address
utilfindscreen
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,phybse						;Store as physical screen
	move.l	d0,displaybse
	move.l	d0,offscreenbse
	move.l	#logscreen+255,d0
	move.b	#0,d0
	move.l	d0,logbse						;Get address of logical screen aligned to 256 bytes
	move.l	d0,offscreenbse					;Set off-screen for screen swap
	rts

;----------------------------------
;Set entire palette to black
utilblackpalette
	lea		$ffff8240.w,a0
	moveq.l	#0,d0
	move.l	d0,(a0)+						;Clear 16 colours
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)
	rts
	
;----------------------------------
;Wait for next VBL
utilwaitvbl
	move.l	vblcount,d0
.loop
	cmp.l	vblcount,d0						;Wait for VBL counter to change
	beq.s	.loop
	rts

;----------------------------------
;Wait for next Display Blanking (ie last line of display)
utilwaitdisplayblank
	move.l	blankingcount,d0
.loop
	cmp.l	blankingcount,d0				;Wait for Display Blanking counter to change
	beq.s	.loop
	rts

;----------------------------------
;Wait for first display line to begin (call after VBL)
;NOTE - Hatari does not emulate this when running as a Falcon
utilwaitdisplay
	IFGT ENABLEVAPCHECK
	lea		$ffff8209.w,a0					;Video Address Counter Low byte
	move.b	(a0),d0
.loop
	cmp.b	(a0),d0							;Wait for it to change
	beq.s	.loop
	ENDC
	rts

;----------------------------------
;Example code to check/wait for the Video Address Counter to reach a set offset
;NOTE - Hatari does not emulate this when running as a Falcon
utilwaitvideoaddress
	IFGT ENABLEVAPCHECK
	lea		$ffff8201.w,a0					;Video Base Address
	movep.w	(a0),d0							;Read High+Mid value
	add.w	#$7d-1,d0						;Mid byte offset for 32000-256, ie near end of visible display	
	lea		$ffff8205.w,a0					;Video Address Counter
.loop
	movep.w	(a0),d1							;Read High+Mid value
	cmp.w	d0,d1
	bls.s	.loop							;Loop until counter is higher, ie d1<=d0 (unsigned)
	ENDC
	rts

;----------------------------------
;Swap off-screen and display screens
;NOTE - on the ST/STe $ff8201 is loaded BEFORE the VBL interrupt so we can set it at anytime
;On the Falcon it is read AFTER the VBL interrupt (as it can be modified for each line)
utilswapscreen
	move.l	offscreenbse,d0
utilswapscreend0
	cmp.w	#MACHINE_FALCON,machine			;If running on a Falcon screen address is set on next VBL
	beq.s	.setscreenfalcon				;Otherwise set VAP now as ST/STe loads on next retrace
	lea		$ffff8201.w,a0					;Video Base Address
	lsr.l	#8,d0							;Get off-screen address High+Mid
	movep.w	d0,(a0)							;Write High+Mid value to be used on next retrace
	bra.s	.setscreen
.setscreenfalcon
	move.l	d0,nextscreen					;Set off-screen address to write during next VBL
.setscreen

	move.l	offscreenbse,d0					;Swap off-screen and display screen addresses
	move.l	displaybse,offscreenbse
	move.l	d0,displaybse
	rts

;----------------------------------
;Wait for keypress using GEMDOS (does not print to output)
utilwaitkey
	move.w	#8,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

;----------------------------------
;Check for keypress using GEMDOS, return d0.w as key (0 if no key is pressed)
utilcheckkey
	move.w	#$b,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

;----------------------------------
;Fast clear screen, pass a0.l as screen address
utilclearscreen
	lea		32000(a0),a0					;Start at end of screen
	moveq.l	#0,d1							;Clear d1-d7/a1-a6
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,d7
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
	move.l	d1,a5
	move.l	d1,a6
	move.w	#68-1,d0						;Loop for 31824 bytes
.loop
	movem.l d1-d7/a1-a6,-(a0)				;Clear 468 bytes
	movem.l d1-d7/a1-a6,-(a0)
	movem.l d1-d7/a1-a6,-(a0)
	movem.l d1-d7/a1-a6,-(a0)
	movem.l d1-d7/a1-a6,-(a0)
	movem.l d1-d7/a1-a6,-(a0)
	movem.l d1-d7/a1-a6,-(a0)
	movem.l d1-d7/a1-a6,-(a0)
	movem.l d1-d7/a1-a6,-(a0)
	dbra.w	d0,.loop
	movem.l d1-d7/a1-a6,-(a0)				;Clear remaining 176 bytes
	movem.l d1-d7/a1-a6,-(a0)
	movem.l d1-d7/a1-a6,-(a0)
	movem.l d1-d5,-(a0)
	rts

;----------------------------------
;Fast copy screen, pass a0.l as source and a1.l as destination screen address
utilcopyscreen
	move.w	#333-1,d0						;333*96 = 31968 bytes
.loop
	movem.l	(a0)+,d1-d7/a2-a6				;Copy 96 bytes
	movem.l	d1-d7/a2-a6,(a1)
	movem.l	(a0)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,48(a1)
	lea		96(a1),a1
	dbra.w	d0,.loop
	movem.l	(a0),d1-d7/a2					;Copy remaining 32 bytes
	movem.l	d1-d7/a2,(a1)
	rts

;----------------------------------
;Function to force 60Hz
utilset60hz
	bclr.b	#1,$ffff820a.w					;Bit 1 is 0 for 60Hz or 1 for 50Hz
	rts

;----------------------------------
;Function to force 50Hz
utilset50hz
	bset.b	#1,$ffff820a.w					;Set 50Hz
	rts

;----------------------------------
;Generate random seeds on boot (use XBIOS for compatibility)
utilrandseed
	move.w	#17,-(sp)						;Random
	trap	#14
	addq.w	#2,sp
	cmp.b	#0,d0							;Check if seed is invalid (ie 0)
	bne.s	.setseed8
	move.b	#$23,d0							;Force valid default seed
.setseed8
	move.b	d0,rndseed8

	move.w	#17,-(sp)
	trap	#14
	addq.w	#2,sp
	cmp.w	#0,d0
	bne.s	.setseed16
	move.w	#$a67e,d0
.setseed16
	move.w	d0,rndseed16
	rts
		
;----------------------------------
;Randomise Xorshift (as Xorshift is a repeating sequence)
utilrandomise
	move.b	$ffff8209.w,d0					;Read video address pointer
	add.b	d0,rndnum8						;Add to random numbers
	add.b	d0,rndnum16
	rts

;----------------------------------
;Xorshift random number, return value in d0.b (range 0...255-1)
utilrandbyte
	move.w	d1,-(sp)
	move.b	rndnum8,d0
	move.b	d0,d1
	lsl.b	#7,d1
	eor.b	d1,d0							;y ^= (y<<7)
	move.b	d0,d1
	lsr.b	#5,d1
	eor.b	d1,d0							;y ^= (y>>5)
	move.b	d0,d1
	lsl.b	#3,d1
	eor.b	d1,d0							;y ^= (y<<3)
	beq.s	.zero
.reseed
	move.b	d0,rndnum8
	subq.b	#1,d0
	move.w	(sp)+,d1
	rts
.zero
	move.b	rndseed8,d0						;Reset seed
	bra.s	.reseed

;----------------------------------
;Xorshift random number, return value in d0.w (range 0...65535-1)
utilrandword
	move.w	d1,-(sp)
	move.w	rndnum16,d0
	move.w	d0,d1
	lsl.w	#8,d1
	lsl.w	#5,d1
	eor.w	d1,d0							;y ^= (y<<13)
	move.w	d0,d1
	lsr.w	#8,d1
	lsr.w	#1,d1
	eor.w	d1,d0							;y ^= (y>>9)
	move.w	d0,d1
	lsl.w	#7,d1
	eor.w	d1,d0							;y ^= (y<<7)
	beq.s	.zero
.reseed
	move.w	d0,rndnum16
	subq.w	#1,d0
	move.w	(sp)+,d1
	rts
.zero
	move.w	rndseed16,d0					;Reset seed
	bra.s	.reseed

;----------------------------------
;Print word to screen as HEX, pass value in d0.w
utilprintword
	movem.l	d0-d7/a0-a6,-(sp)
	lea		textword,a0						;Buffer to write digits
	bsr		utilword2text					;Convert d0.w to text string
	move.l	#textword,-(sp)
	move	#$9,-(sp)						;Conws
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;----------------------------------
;Print long word to screen as HEX, pass value in d0.l
utilprintlong
	movem.l	d0-d7/a0-a6,-(sp)
	lea		textlong,a0						;Buffer to write digits
	bsr		utillong2text					;Convert d0.l to text string
	move.l	#textlong,-(sp)
	move	#$9,-(sp)						;Conws
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;----------------------------------
;Convert word to HEX string, pass value in d0.w and string buffer in a0.l
utilword2text
	movem.l	d0-d2/a0,-(sp)
	moveq.w	#4-1,d2							;Write 4 digits
.loop
	rol.w	#4,d0							;Put upper nibble in lowest bits
	move.w	d0,d1							;Copy value
	and.w	#$f,d1							;Mask nibble
	add.w	#'0',d1							;'0...9'
	cmp.w	#'9',d1
	ble.s	.ok
	add.w	#'A'-'9'-1,d1					;'A...F'
.ok
	move.b	d1,(a0)+						;Write digit
	dbra.w	d2,.loop
	movem.l	(sp)+,d0-d2/a0
	rts

;----------------------------------
;Convert long word to HEX string, pass value in d0.l and string buffer in a0.l
utillong2text
	movem.l	d0-d2/a0,-(sp)
	moveq.w	#8-1,d2							;Write 8 digits
.loop
	rol.l	#4,d0							;Put upper nibble in lowest bits
	move.l	d0,d1							;Copy value
	and.l	#$f,d1							;Mask nibble
	add.w	#'0',d1							;'0...9'
	cmp.w	#'9',d1
	ble.s	.ok
	add.w	#'A'-'9'-1,d1					;'A...F'
.ok
	move.b	d1,(a0)+						;Write digit
	dbra.w	d2,.loop
	movem.l	(sp)+,d0-d2/a0
	rts

;----------------------------------
;Find available free memory from GEMDOS, returns size in d0.l
utilavailablemem
	move.l	#-1,-(sp)						;Pass -1 to find free memory
	move.w	#$48,-(sp)						;Malloc
	trap	#1
	addq.w	#6,sp	
	rts

;----------------------------------

	SECTION	DATA

textword			dc.b	"XXXX",0		;Buffers for output when convert value to HEX strings, including trailing '\0'
textlong			dc.b	"XXXXXXXX",0
	EVEN

;----------------------------------

	SECTION	BSS

machine				ds.w	1				;Machine type, ie MACHINE_xx
rndseed8			ds.b	1				;Random numbers
rndnum8				ds.b	1
rndseed16			ds.w	1
rndnum16			ds.w	1
vblcount			ds.l	1				;VBL counter
blankingcount		ds.l	1				;VBL IN counter
nextscreen			ds.l	1				;Next screen address, set on VBL
nextpalette			ds.l	1				;Next palette address, set on VBL
nextrasterset		ds.w	1				;Next raster set, set on VBL
rasterset			ds.w	1				;Raster set
phybse				ds.l	1				;Physical and logical screen addresses
logbse				ds.l	1
displaybse			ds.l	1				;Current displayed screen address
offscreenbse		ds.l	1				;Off-screen address
screenlines			ds.w	200				;Offsets to each line in screen (ie y*160)
logscreen			ds.b	32256			;320*200 32Kbyte logical screen, with 256 bytes for alignment
oldsuper			ds.l	1				;Old supermode vector
oldbuserror			ds.l	1				;$8 Bus Error vector
oldaddresserror		ds.l	1				;$c Address Error vector
oldillegalins		ds.l	1				;$10 Illegal Instruction
olddivzero			ds.l	1				;$14 Divide By Zero
oldvbl				ds.l	1				;$70 VBL vector
oldtimerd			ds.l	1				;$110 MFP Timer D vector (low priority)
oldtimerc			ds.l	1				;$114 MFP Timer C vector
oldikbd				ds.l	1				;$114 MFP IKBD vector
oldtimerb			ds.l	1				;$120 MDP Timer B vector
oldtimera			ds.l	1				;$134 MFP Timer A vector (high priority)
oldgemdoserror		ds.l	1				;$404 GEMDOS critical error handler
oldintenablea		ds.b	1				;$fffa07 Interrupt Enable A
oldintenableb		ds.b	1				;$fffa09 Interrupt Enable B
oldintmaska			ds.b	1				;$fffa13 Interrupt Mask A
oldintmaskb			ds.b	1				;$fffa15 Interrupt Mask B
oldtimeracontrol	ds.b	1				;$fffa19 Timer A Control
oldtimerbcontrol	ds.b	1				;$fffa1b Timer B Control
oldtimercdcontrol	ds.b	1				;$fffa1d Timer C+D Control
oldvideohighbyte	ds.b	1				;$ff8201 Video Base Address High
oldvideomidbyte		ds.b	1				;$ff8203 Video Base Address Mid
oldvideosync		ds.b	1				;$ff820a Video Shifter Sync Mode
	EVEN
oldpalette			ds.w	16				;$ff8240 16-colour palette
