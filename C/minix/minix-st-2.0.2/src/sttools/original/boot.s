#include "type.s"

! offsets in this boot block:
sizes	= 480
magic	= 502
nsect	= 504
fsckd	= 506
zero	= 508
fsckt	= 510

BIOS	= 13
RWABS	= 4
GETBPB	= 7

_bootdev	= 0x0446
ldaddr		= 0x010000

boot:
	move.w	_bootdev,-(sp)
	move.w	#GETBPB,-(sp)
	trap	#BIOS
	add.w	#4,sp
	tst.l	d0
	beq	fail
	clr.w	d6		! start with block 0
	lea	start+sizes(pc),a4 ! address of sector table
	add.w	#1,(a4)		! count boot block
	move.l	#ldaddr,a3	! load address in memory
read:
	clr.l	d4		! load sectors from disc
	move.w	(a4)+,d4
	beq	4f		! count of 0 means loading finished
	bsr	rwabs
	bne	fail
	add.w	d4,d6
	asl.l	#8,d4
	asl.l	#1,d4
	add.l	d4,a3

	clr.l	d0		! create bss area of part
	move.w	(a4)+,d0
	asl.l	#8,d0
	beq	read
3:
	clr.w	(a3)+
	sub.l	#1,d0
	bne	3b
	bra	read
4:
	! calculate end of loaded image
	! keep this value in d2 for future reference
	clr.l	d2
	move.w	start+nsect(pc),d2
	asl.l	#8,d2		! multiply
	asl.l	#1,d2		! with 512
	add.l	#ldaddr,d2
	move.l	d2,a0	
	lea	copy(pc),a1	! copy copy routine to the end of the image
	move.l	#128,d0		! to avoid that it overwrites itself
5:	move.l	(a1)+,(a0)+	! 512 bytes is definitely enough.
	dbf	d0,5b
	! if there is no mmu the .data4 will cause a trap. Catch it
	! and jump to the copy routine in that case
	move.l	d2,a1	
	move.l	a1,0x2c
	! disable the mmu. This is needed because on the TT tos has
	! initialised the mmu when we get here.
	clr.l	(a0)
	.data4	0xf0104000	! move (a0),tc
	jmp	(a1)		! jump to new copy routine

copy:
	lea	copy(pc),a0
	move.w	#0x2700,sr
	move.l	#8,a0
	! save the minix boot address. It will be overwritten during the copy
	move.l	ldaddr+0x204,a3	
	move.l	#ldaddr+0x208,a1! start address of minix
3:	move.l	(a1)+,(a0)+
	cmp.l	a1,d2		! d2 contains the end of the loaded image
	bne	3b
	jmp	(a3)		! minix boot address

fail:
	clr.l	d0		! cannot load MINIX; try next device
	rts

rwabs:
	move.w	_bootdev,-(sp)
	move.w	d6,-(sp)
	move.w	d4,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#RWABS,-(sp)
	trap	#BIOS
	add.w	#14,a7
	tst.w	d0
	rts
