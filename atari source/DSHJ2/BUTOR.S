
		.globl	_BUT_OR,_BADDR,_BSTATE,_BREAL
                .globl  _clrmem
		.globl  _gdostst
		.globl  _OVMOUSE,_NVMOUSE,_KICKAES
		.globl  _gcurx,_gcury


*	The right and left buttons are ORed together as the Left button
*	flag and passed to the AES mouse button interrupt routine. 
*
*  in:
*	_BUT_ADDR contains the address of the AES interrupt routine
*	that deals with mouse buttons.
*
* out:
*	_BUT_STATE contains the actual mouse button state prior to ORing



_BUT_OR:	and.w	#$FFFF,d0
		tst     d0
		move.w  d0,_BREAL
		beq	place
  		move.w	d0,_BSTATE
		move.w	#1,d0
place:		move.l	_BADDR,-(sp)
		rts				; jmp to AES subroutine



*************************************************************************
*									*
*	CLRMEM								*
*									*
*	This routine clears an arbitrary block of memory.		*
*	The block length must be an even integer less then 16 Megabytes.*
*	The block must start on a word boundary				*
*									*
*	Inputs:	d0.L = Number of bytes to Clear				*
*		a0   = Ptr to Memory to Clear				*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	d0-d2, a0-a2				*
*									*
*************************************************************************
_clrmem:
        move.l  4(sp),a0
	move.l  8(sp),d0

	movem.l	d3-d7,-(sp)
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	moveq.l	#0,d7
	move.l	d1,a2		* 32 bytes of Zero
	move.l	d0,temp2	* save total size in bytes (assumed to be even)
	move.l	a0,a1
	adda.l	d0,a1		* a1 = EOMemory Block
	and.l	#$ffffff00,d0

	beq	clearlast	* WHILE (Pages Remain) DO
	asr.l	#8,d0
	subq.w	#1,d0		* NOTE: 16-Megabyte Maximum
clear1:
	movem.l	d1-d7/a2,-(a1)
	movem.l	d1-d7/a2,-(a1)
	movem.l	d1-d7/a2,-(a1)
	movem.l	d1-d7/a2,-(a1)
	movem.l	d1-d7/a2,-(a1)
	movem.l	d1-d7/a2,-(a1)
	movem.l	d1-d7/a2,-(a1)
	movem.l	d1-d7/a2,-(a1)	* Clear a Page (256 bytes)
	dbra	d0,clear1
clearlast:
	move.l	temp2,d0	* d0 = total size in bytes (assumed to be even)
	and.w	#$0ff,d0
	asr.w	#1,d0
	beq	cleardone	* IF (Last Page Remains) THEN
	subq.w	#1,d0		* FOR (All Words Remaining) DO
clear2:	move.w	d1,-(a1)	* Clear Word
	dbra	d0,clear2
cleardone:
	movem.l	(sp)+,d3-d7
	rts



_gdostst: move.w #-2,d0
	  trap   #2
	  rts


_NVMOUSE: rts

_KICKAES: move.w  SR,-(sp)
	  ori.w   #$0700,SR
          movea.l _gcurx,a0
	  move.w  (a0),d0
          movea.l _gcury,a0
          move.w  (a0),d1
 	  move.l  _OVMOUSE,a0
	  jsr (a0)
          move.w  (sp)+,SR
	  rts

                .bss

		.even
temp2:          .ds.l   1
_BADDR:		.ds.l	1
_BSTATE:	.ds.w	1
_BREAL:		.ds.w	1
_OVMOUSE:	.ds.l   1
_temp3:		.ds.l	1

		.end
