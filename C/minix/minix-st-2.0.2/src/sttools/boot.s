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
#ifdef DETERMINE_MEM
#ifdef USE_PHYSTOP
! to avoid buserrors (for emulators) use _phystop to determine RAM size
_phystop	= 0x42e	! pointer to first byte above ST RAM
#endif /* USE_PHYSTOP */
ld_1MB	= 0x100000	! 1MB
ld_512k	= 0x80000	! 512kB
ld_256k	= 0x40000	! 256kB
#else
#ifdef LOAD1MB
ldaddr		= 0x0100000	! 1MB
#else
ldaddr		= 0x040000
#endif /* LOAD1MB */
#endif /* DETERMINE_MEM */

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
#ifdef DETERMINE_MEM
#ifdef USE_PHYSTOP
	move.l	#ld_1MB,a3
	cmp.l	_phystop,a3
	bgt	memdone		! more than 1MB RAM
	beq	mem1MB		! one MB RAM
	move.l	#ld_256k,a3	! 512k (or less, will fail) RAM
	bra	memdone
mem1MB:
	move.l	#ld_512k,a3
memdone:
#else
	move.l	#ld_256k,a3	! preset 256kB load address
	move.l	sp,a1		! save sp
	move.l	8,a2		! save old buserr vector
	move.l	#buserr1,8
	move.b	ld_1MB,d0	! RAM at 1MB?
	move.l	#ld_1MB,a3	! yes, use it for loading Minix
	bra	buserr2
buserr1:
	move.l	#buserr2,8
	move.b	ld_512k,d0	! RAM at 512k?
	move.l	#ld_512k,a3	! yes, use it for loading Minix
buserr2:
	move.l	a1,sp		! restore stack
	move.l	a2,8		! restore buserr vector
#endif /* USE_PHYSTOP */
	move.l	a3,d3		! save for later
#else
	move.l	#ldaddr,a3	! load address in memory
#endif /* DETERMINE_MEM */
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
#ifdef DETERMINE_MEM
	add.l	d3,d2
#else
	add.l	#ldaddr,d2
#endif /* DETERMINE_MEM */
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
#ifdef DETERMINE_MEM
	move.l	d3,a3
	move.l	0x204(a3),a3
	move.l	d3,a1
	add	#0x208,a1
#else
	move.l	ldaddr+0x204,a3	
	move.l	#ldaddr+0x208,a1! start address of minix
#endif /* DETERMINE_MEM */
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
