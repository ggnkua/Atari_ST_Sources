/******************************************************************************
	Module ALOCK :		alock, protect2
	A-Lock copy protection

	---> WARNING:  DO NOT RUN THIS MODULE THROUGH THE CODE IMPROVER !

******************************************************************************/

overlay "alock"

/* include header files .....................................................*/

#include <asm.h>				  /* needed for in-line assembly language */
#include "defines.h"         /* program-specific */
#include <gemdefs.h>         /* AES                  */
#include <obdefs.h>          /* more AES  */

/* global variables .........................................................*/

#include "externs.h"

#define maxtry 10
#define badflag 1
extern int alock(),protect2();

asm {
alock:
	movem.l	D1-D7/A0-A6,-(A7)		; save everyone (but D0)
	lea		_notes(A4),A6			; buffer

alockstart:								; start of completely unlocated code
											; (can be crc'd)

	lea		Serial,A5				; --> serial number
	moveq		#2,D6						; D6 - current try (2 or 1)
	moveq		#maxtry,D5				; D5 - read count
	move.w 	#25,-(A7)				; get current drive into d7
	bra		trap1
trap1ret:
	addq.w	#2,A7						; restore the stack
	cmpi.w	#2,D7						; device not a floppy?
	blt		l0
	clr.w		D7							; floppies only (for right now anyways)

/* read signature sector: track 0, side 0, sector 0 */
l0:
	move.w	#1,-(A7)					; read one sector
	clr.w		-(A7)						; side 0
	clr.w		-(A7)						; track 0
	clr.w		-(A7)						; sector 0
	move.w	D7,-(A7)					; device (0-A:,1-B:)
	clr.l		-(A7)						; not used
	move.l	A6,-(A7)					; pointer to buffer
	move.w	#8,-(A7)					; read sector
	bra		trap14
trap14ret:
	adda.w	#20,A7					; restore the stack

/* check results */
	tst.w		D0
	beq		l3					; no error
	bmi		l9					; sync box ok
l1:
	subq.w	#1,D6				; next device
	beq		l2					; no more? then quit
	moveq		#maxtry,D5		; set read count
	addq.w	#1,D7				; next device
	cmpi.w	#2,D7				; go too far?
	bne		l0					; no? then try that device
	clr.w		D7					; yes? set device to 0
	bra		l0					; and retry

l2:
   moveq		#badflag,D0		; send bad verify flag
	bra		l8					; and exit

/* verify signature */
l3:
	movea.l	A6,A0				; --> buffer
	movea.l	A5,A1				; --> serial number
	cmpm.l	(A0)+,(A1)+		; compare first 4 bytes of serial no.
	bne		l1					; don't match? bad disk
	cmpm.w	(A0)+,(A1)+		; compare last 2 bytes of serial no.
	bne		l1					; don't compare? bad disk

	cmpi.w	#maxtry,D5		; first time read?
	bne		l7
	movea.l	A6,A3				; a3--> first time results
	adda.l	#64,A6			; read past the first time results
	subq.w	#1,D5
	bra		l0					; read again
l7:
   subq.w	#1,D5				; run out of tries?
	bmi		l1

	move.l	16(A3),D0
	cmp.l		16(A6),D0
	bne		l4
	move.l	20(A3),D0
	cmp.l		20(A6),D0
	bne		l4
	move.l	24(A3),D0
	cmp.l		24(A6),D0
	bne		l4
	move.l	28(A3),D0
	cmp.l		28(A6),D0
	bne		l4
	move.l	32(A3),D0
	cmp.l		32(A6),D0
	bne		l4
	move.l	36(A3),D0
	cmp.l		36(A6),D0
	bne		l4
	move.l	40(A3),D0
	cmp.l		40(A6),D0
	bne		l4
	move.l	44(A3),D0
	cmp.l		44(A6),D0
	beq		l0					; 32 bytes all the same
l4:
	clr.w		D0					; 32 bytes not all the same:  set good flag

l8:								; do a CRC of this whole routine
	lea		alockstart,A0	; --> start of area to be crc'd
	move.b	D0,(A0)			; seeded with D0
	clr.w		D0
	lea		alockend,A1		; --> end of area to be crc'd
addcrc:
	cmpa.l	A0,A1				; done crc'ing?
	beq		l9
	move.b	(A0)+,D7			; byte to be computed into CRC
	moveq		#7,D1
crcloop:
	lsl.b		#1,D7
	roxl.w	#1,D0
	bcc		skipit
	eori.w	#0x8005,D0
skipit:
	dbf		D1,crcloop
	bra		addcrc

Serial:
	dc.w		0x3130, 0x3030, 0x3136

l9:
	movem.l	(A7)+,D1-D7/A0-A6
	rts

trap1:
	tst.l		d0					; d0.l= 0L if sync box
	beq		trap1ret
	move.l	d0,d7
	trap		#1
	exg.l		d0,d7
	bra		trap1ret

trap14:
	tst.l		d0					; d0.l= 0L if sync box
	bne		trap14x
	move.w	#0x9efc,d0		; return d0.w <0 sync box ok
	bra		trap14ret
trap14x:
	trap		#14
	andi.w	#3,d0		; return d0.w = 0 ok, >0 error
	bra		trap14ret

alockend:						; end of range that can be crc'd

}	/* end alock() */

/* second phase of copy protection ..........................................*/
/* entry condition: d0= 9efc sync box ok, 108b alock ok */

asm {
protect2:
/* note: this code is needed to determine correct maincrc and mainchksum !!!...
	illegal
	move.w	maincrc(a4),d1
	move.w	mainchksum(a4),d1
... !!! */
	tst.w		d0
	bmi		sync_ok
	addi.w	#0x8e71,d0
sync_ok:						; d0.w= 9efc, high word of suba.w #X,a7 instruction
	rts
}	/* end protect2() */

/* EOF alock.c */ 
