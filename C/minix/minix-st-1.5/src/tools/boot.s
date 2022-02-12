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
ldaddr		= 0x040000

boot:
	move.w	_bootdev.l,-(sp)
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
	lea	copy(pc),a0
	lea	start(pc),a1
	sub.l	a1,a0
	add.l	#ldaddr,a0
	jmp	(a0)		! jump to copy routine at ldaddr

copy:
	move.w	#0x2700,sr
	move.l	#8,a0
	move.l	#ldaddr+0x208,a1! start address of minix
	move.l	#0x400,d0
2:	move.l	(a1)+,(a0)+
	cmp.l	a0,d0
	bne	2b
	add.l	#0x200,a0	! skip tos variables
	add.l	#0x200,a1
	clr.l	d0
	move.w	start+nsect(pc),d0
	asl.l	#8,d0		! multiply
	asl.l	#1,d0		! with 512
3:	move.l	(a1)+,(a0)+
	cmp.l	a0,d0
	bne	3b
	move.l	ldaddr+0x204,a0
	jmp	(a0)		! minix boot address

fail:
	clr.l	d0		! cannot load MINIX; try next device
	rts

rwabs:
	move.w	_bootdev.l,-(sp)
	move.w	d6,-(sp)
	move.w	d4,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#RWABS,-(sp)
	trap	#BIOS
	add.w	#14,a7
	tst.w	d0
	rts
