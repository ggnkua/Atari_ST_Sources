	opt o+
*******************************************************************
***		   The Funky Screen Flipper			***
***								***
***			  Written by				***
***								***
***	    The Hitchhiker, The Tempest and Itself..!		***
***								***
***	      Self writing version - 9th March 1991		***
***								***
***								***
*******************************************************************

	COMMENT HEAD=1		* Set fastload bit for TOS 1.4+

	section text

	move.l	#message,-(sp)		* Print welcome message
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#7,-(sp)		* Wait keypress
	trap	#1
	addq.l	#2,sp


	lea 	newscre,a0		* new screen store
	move.l	a0,d0
	move.l	#%11111111111111111111111000000000,d1
	and.l	d0,d1		* force 512 byte border
	add.l	#512,d1		* new logbase is in d1
	
	move.l	d1,logbase
	
	move.w 	#-1,-(sp)	* now call setscreen
	move.l 	#-1,-(sp)	* to set logbase to
	move.l	d1,-(sp)	* point to our screen
	move.w	#5,-(sp)	* buffer.
	trap	#14
	add.l	#12,sp

	lea 	count,a0
	move.b	#0,(a0)

	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp		* get physbase
	
	move.l	d0,a0
	move.l	a0,phybas	*store physbase


	move.w	#4,-(sp)	* Getrez
	trap	#14
	addq.l	#2,sp
	
	lea	scrmov,a4	* set addr of routine
	
	lea	phybas,a5
	move.l	(a5),d7
	
	cmpi.w	#2,d0		* mono ?
	bne.s	setcol		* no - colour setuo
	
	move.w	#399,d2			* number of lines
	move.w	#1,d4			* (movems/line)-1
	move.w	#160,d5			* bytes per line
	add.l	#31920,d7		* start of end line
	bra.s 	skip
 
setcol
	move.w	#199,d2			* number of lines
	move.w	#3,d4			* (movems/line)-1
	move.w	#320,d5			* bytes per line
	add.l	#31840,d7		* start of end line
skip

	move.l	d7,phybas
	
	lea	selfwrt,a0		*a0 points to start of move 	
bigloop
	move	d4,d0			* number of moves less one	
loopwrt
	move.l	#$4cdd03ff,(a0)+	* this is movem.l (a5)+,d0-a1
	move.l	#$48d603ff,(a0)+	* this is movem.l d0-a1,(a6)
	move.l	#$ddfc0000,(a0)+	* this writes some of ....
	move.w	#$0028,(a0)+		* add.l	#40,a6

	dbra	d0,loopwrt		* do again

	move.l	#$9dfc0000,(a0)+	* write sub.l #bytes/line,a0
	move	d5,(a0)+ 		* ditto
	dbra	d2,bigloop		* do it again 
	move	#$4e75,(a0)+		* write rts 

	clr.l	-(sp)			* now lets jump into
	move.w	#$20,-(sp)		* supervisor mode
	trap	#1
	addq.l	#6,sp
	move.l	d0,supsta
	
	move.l	($456).w,a0		* address of VBI queue
	
	move.w	#7,d0			* scan for empty VBI slot
loop	move.l	(a0)+,d1
	beq.s	found
	dbra	d0,loop

	move.l	supsta,-(sp)		* back to user mode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	move.l	#0,-(sp)		* PTERM - just in case...!
	trap #1
	
found	subq.l	#4,a0			* Correct address
	move.l	a4,(a0)			* Insert new VBL routine
	
	move.l	supsta,-(sp)		* back to user mode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	move.w	#0,-(sp)		* terminate and stay resident
	move.l	#50000,-(sp)		* keeping 50K
	move.w	#$31,-(sp)
	trap #1

scrmov					* move routines
	lea	count,a0
	move.b (a0),d0
	cmpi.b	#3,d0			* shall I update ?
	beq.s cont			* yes - branch
	addq.b	#1,d0			* no - increment counter
	move.b d0,(a0)			* store counter
	rts				* bye bye

cont 	
	move.b	#0,(a0)			* reset counter
	lea	logbase(pc),a2
	move.l	(a2),a5		* get logbase
	lea	phybas(pc),a2
	move.l	(a2),a6		* get physbase

	jsr	selfwrt
	rts


message	dc.b	27,"E",27,"f"
	dc.b	"/==========================================\",13,10
	dc.b	"|",27,"p     Mega Funky Screen Flipper! v2.0      ",27,"q|",13,10
	dc.b	"\==========================================/",13,10
	dc.b	13,10
	dc.b	"               Written by",13,10
	dc.b	"     The Tempest and The Hitchhiker",13,10
	dc.b	"             Of The Revenge",13,10
	dc.b	13,10
	dc.b	"    Warning: This program can",13,10
	dc.b	"    seriously damage your sanity.",13,10
	dc.b	13,10
	dc.b	"    Version 2.0 is a lot faster and",13,10
	dc.b	"    was much stranger to program.  Try",13,10
	dc.b	"    looking at it using MonST...!",13,10
	dc.b	13,10
	dc.b	"    This program was written whilst",10,13
	dc.b	"    under the influence of Steve Vai's",10,13
	dc.b	"    Flexable - Highly recommended.",10,13
	dc.b	13,10
	dc.b	"    P.S. Do not try to read the",13,10
	dc.b	"    the text while standing on your",13,10
	dc.b	"    head unless you have a mirror",13,10
	dc.b	"    as well...!",13,10
	dc.b	13,10
	dc.b	"    ",27,"p Hit any key to phreak out...! ",27,"q",0

	even


	section bss

phybas  ds.l 1 			* store for physbase
supsta	ds.l 1			* store for super stack pntr
logbase	ds.l 1			* store for logbase
newscre	ds.l 8130		* new screen
count	ds.b 1			* frame coutner
	even
	ds.w 10
selfwrt	ds.b 13000		*space for code to be written
