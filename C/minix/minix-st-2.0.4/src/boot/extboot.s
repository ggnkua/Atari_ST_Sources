!	extboot 1.1 - Extended partition boot code	Author: Kees J. Bot
!								13 May 1995
!
! This code may be placed into any free boot sector, like the first sector
! of an extended partition, a file system partition other than the root,
! or even the master bootstrap.  It will boot the logical partition whose
! device and subpartition number are patched into the start of the code.
!
.sect .text; .sect .rom; .sect .data; .sect .bss

	LOADOFF	   =	0x7C00	! 0x0000:LOADOFF is where this code is loaded
	BUFFER	   =	0x0600	! First free memory
	PART_TABLE =	   446	! Location of partition table within this code
	PENTRYSIZE =	    16	! Size of one partition table entry
	MAGIC	   =	   510	! Location of the AA55 magic number

	! <ibm/partition.h>:
	EXT_PART   =	     5
	bootind	   =	     0
	sysind	   =	     4
	lowsec	   =	     8


.define begtext, begdata, begbss, endtext, enddata, endbss, _main
.sect .data
begdata:
.sect .bss
begbss:
.sect .text
begtext:
_main:

! Load the sector from a given logical device and jump to it.

extended:
	jmp	over
device:	.data1	0			! /dev/hd<drive><logical>
logical:.data1	0
over:
	xor	ax, ax
	mov	ds, ax
	mov	es, ax
	cli
	mov	ss, ax			! ds = es = ss = Vector segment
	mov	sp, #LOADOFF
	sti
	mov	bp, #BUFFER+PART_TABLE	! Often used address

! Copy this code to safety, then jump to it.
	mov	si, sp			! si = start of this code
	push	si			! Also its return address
	mov	di, #BUFFER		! Buffer area
	mov	cx, #512/2		! One sector
	cld
    rep	movs
	jmpf	BUFFER+migrate, 0	! To safety
migrate:

	movb	al, BUFFER+device	! ax = device
	movb	dl, #5
	divb	dl			! al = disk, ah = partition within disk
	movb	dl, #0x80
	addb	dl, al			! dl = disk
	movb	al, ah			! al = partition within disk
	push	ax			! Save partition choice
	call	load			! Get sector 0
	jb	error0			! Unable to read it
	pop	ax			! Restore partition choice
	subb	al, #1			! Don't like 0 mod 5
	jl	fail
	call	gettable		! Copy and sort the partition table
	movb	ah, #PENTRYSIZE
	mulb	ah			! ax = al * PENTRYSIZE
	add	si, ax			! si = address of partition entry
	cmpb	sysind(si), #EXT_PART	! Must be an extended partition
	jne	fail
	mov	ax, lowsec+0(si)
	mov	BUFFER+extbase+0, ax
	mov	ax, lowsec+2(si)
	mov	BUFFER+extbase+2, ax	! Save offset of enclosing ext part

! Search for the n-th logical partition.
search:
	mov	ax, lowsec+0(si)
	mov	BUFFER+offset+0, ax
	mov	ax, lowsec+2(si)
	mov	BUFFER+offset+2, ax	! Set offset of current partition
	call	load			! Load the partition bootstrap
error0:	jb	error
	cmpb	BUFFER+logical, #0
	je	bootstrap		! Run it?
	call	gettable		! Copy and sort extended part table
	xor	di, di
search1:cmpb	sysind(si), #EXT_PART
	jne	notext
	mov	di, si			! Remember chained ext partition
	jmp	next
notext:	cmpb	sysind(si), #0
	je	last
	decb	BUFFER+logical
	jz	search			! The right logical?
next:	add	si, #PENTRYSIZE
	cmp	si, #BUFFER+PART_TABLE+4*PENTRYSIZE
	jb	search1			! Try next entry
last:	mov	si, di
	test	si, si
	jnz	search			! Try the next extended partition
fail:	call	print
	.data2	BUFFER+notfound
	jmp	hang

! A read error occurred, complain and hang
error:
	call	print
	.data2	BUFFER+readerr
	jmp	hang

! Copy a partition table into BUFFER+PART_TABLE, adjust and sort it.
gettable:
	mov	si, #LOADOFF+PART_TABLE	! si = new partition table
	mov	di, bp			! To buffer area
	mov	cx, #4*PENTRYSIZE/2
    rep	movs
	mov	si, bp			! First table entry
	addb	cl, #4			! Four entries
adjust:	mov	di, #BUFFER+extbase	! Adjust ext part by extended base
	cmpb	sysind(si), #EXT_PART
	je	adjx
	mov	di, #BUFFER+offset	! Adjust other parts by sector offset
adjx:	mov	bx, (di)
	add	lowsec+0(si), bx
	mov	bx, 2(di)
	adc	lowsec+2(si), bx
	add	si, #PENTRYSIZE		! Next to adjust
	loop	adjust
	addb	cl, #4			! Four times is enough to sort
sort:	mov	si, bp			! First table entry
bubble:	lea	di, PENTRYSIZE(si)	! Next entry
	cmpb	sysind(si), ch		! Partition type, nonzero when in use
	jz	exchg			! Unused entries sort to the end
inuse:	mov	bx, lowsec+0(di)
	sub	bx, lowsec+0(si)	! Compute di->lowsec - si->lowsec
	mov	bx, lowsec+2(di)
	sbb	bx, lowsec+2(si)
	jnb	order			! In order if si->lowsec <= di->lowsec
exchg:	movb	ah, (si)
	xchgb	ah, PENTRYSIZE(si)	! Exchange entries byte by byte
	movb	(si), ah
	inc	si
	cmp	si, di
	jb	exchg
order:	mov	si, di
	cmp	si, #BUFFER+PART_TABLE+3*PENTRYSIZE
	jb	bubble
	loop	sort
    	mov	si, bp			! si = sorted table
bootstrap:
	ret				! Return / Jump to the master bootstrap

! Load sector 'offset' from the current device.  The obvious head, sector,
! and cylinder numbers are ignored in favour of the more trustworthy absolute
! start of partition.
load:
	mov	di, #1		! One retry should unwedge a hard disk
retry:	push	dx		! Save drive code
	push	es
	push	di		! Next call destroys es and di
	movb	ah, #0x08	! Code for drive parameters
	int	0x13
	pop	di
	pop	es
	andb	cl, #0x3F	! cl = max sector number (1-origin)
	incb	dh		! dh = 1 + max head number (0-origin)
	movb	al, cl		! al = cl = sectors per track
	mulb	dh		! dh = heads, ax = heads * sectors
	mov	bx, ax		! bx = sectors per cylinder = heads * sectors
	mov	ax, BUFFER+offset+0
	mov	dx, BUFFER+offset+2 ! dx:ax = sector within drive
	div	bx		! ax = cylinder, dx = sector within cylinder
	xchg	ax, dx		! ax = sector within cylinder, dx = cylinder
	movb	ch, dl		! ch = low 8 bits of cylinder
	divb	cl		! al = head, ah = sector (0-origin)
	xorb	dl, dl		! About to shift bits 8-9 of cylinder into dl
	shr	dx, #1
	shr	dx, #1		! dl[6..7] = high cylinder
	orb	dl, ah		! dl[0..5] = sector (0-origin)
	movb	cl, dl		! cl[0..5] = sector, cl[6..7] = high cyl
	incb	cl		! cl[0..5] = sector (1-origin)
	pop	dx		! Restore drive code in dl
	movb	dh, al		! dh = al = head
	mov	bx, #LOADOFF	! es:bx = where sector is loaded
	mov	ax, #0x0201	! Code for read, just one sector
	int	0x13		! Call the BIOS for a read
	jnb	ok		! Read succeeded
	dec	di
	jl	bad		! Retry count expired
	xorb	ah, ah
	int	0x13		! Reset
	jnb	retry		! Try again
bad:	stc			! Set carry flag
	ret
ok:	cmp	LOADOFF+MAGIC, #0xAA55
	jne	nosig		! Error if signature wrong
	ret			! Return with carry still clear
nosig:	call	print
	.data2	BUFFER+noboot
	!jmp	hang

! Hang forever waiting for CTRL-ALT-DEL
hang:	jmp	hang

print:	pop	si			! return address
	lods				! ax = *si++ = word after 'call print'
	push	si			! new return address
	mov	si, ax
prnext:	lodsb				! al = *si++ is char to be printed
	testb	al, al
	jz	prdone			! Null marks end
	movb	ah, #14			! 14 = print char
	mov	bx, #0x0001		! Page 0, foreground color
	int	0x10			! Call BIOS VIDEO_IO
	jmp	prnext
prdone:	ret


.sect .data
offset:		.data4	0
extbase:	.data4	0
readerr:	.ascii	"Read error \0"
noboot:		.ascii	"Not bootable \0"
notfound:	.ascii	"Logical not found \0"
.sect .text
endtext:
.sect .data
enddata:
.sect .bss
endbss:
