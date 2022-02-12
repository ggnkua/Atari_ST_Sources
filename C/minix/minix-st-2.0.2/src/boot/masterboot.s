!	masterboot 1.9 - Master boot block code		Author: Kees J. Bot
!
! This code may be placed in the first sector (the boot sector) of a floppy,
! hard disk or hard disk primary partition.  There it will perform the
! following actions at boot time:
!
! - If the ALT key is held down, then '/dev/hd?' is typed and you are
!   expected to type a number key (0 - 9) to select the device to boot.
!
! - If locked into booting a certain partition, then do so.
!
! - If the booted device is a hard disk and one of the partitions is active
!   then the active partition is booted.
!
! - Otherwise the next floppy or hard disk device is booted, trying them one
!   by one.
!
! To make things a little clearer, the boot path might be:
!	/dev/fd0	- Floppy disk containing data, tries fd1 then hd0
!	[/dev/fd1]	- Drive empty
!	/dev/hd0	- Master boot block, selects active partition 3
!	/dev/hd3	- Submaster, selects active subpartition 1
!	/dev/hd3a	- Minix bootblock, reads secondary boot code /boot
!	Minix		- Started by secondary boot from /minix

	LOADOFF	   =	0x7C00	! 0x0000:LOADOFF is where this code is loaded
	BUFFER	   =	0x0600	! First free memory
	PART_TABLE =	   446	! Location of partition table within this code
	PENTRYSIZE =	    16	! Size of one partition table entry
	MAGIC	   =	   510	! Location of the AA55 magic number

	! <ibm/partition.h>:
	bootind	   =	     0
	sysind	   =	     4
	lowsec	   =	     8


.define begtext, begdata, begbss, endtext, enddata, endbss, _main
.data
begdata:
.bss
begbss:
.text
begtext:
_main:

! Find active (sub)partition, load its first sector, run it.

master:
	jmp	over
fix:	.data1	0			! If 1-9 then always boot that device
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
	rep
    	movs
	jmpf	BUFFER+migrate, 0	! To safety
migrate:

! ALT key pressed to override active device boot?
key:
	movb	ah, #0x02		! Keyboard shift status
	int	0x16
	testb	al, #0x08		! Bit 3 = ALT key
	jz	noalt			! No ALT key pressed
	call	print
	.data2	BUFFER+devhd
getkey:	xorb	ah, ah			! Wait for keypress
	int	0x16
	movb	BUFFER+choice, al
	subb	al, #0x30		! al -= '0'
	cmpb	al, #10
	jae	getkey			! Key not in 0 - 9 range
	push	ax
	call	print			! Show the key typed
	.data2	BUFFER+choice
	pop	ax
	jmp	override
noalt:
	movb	al, BUFFER+fix		! Always boot a certain partition?
	testb	al, al
	jz	findactive		! No, boot the active partition
override:
	cbw				! ax = partition choice
	movb	dl, #5
	divb	dl			! al = disk, ah = partition within disk
	movb	dl, #0x80
	addb	dl, al			! dl = disk
	movb	al, ah			! al = partition within disk
	push	ax			! Save partition choice
	call	load0			! Get sector 0
	jb	error0			! Unable to read it
	pop	ax			! Restore partition choice
	subb	al, #1			! Was it 0 mod 5?
	jl	bootstrap		! Jump to the master bootstrap
	mov	si, #LOADOFF+PART_TABLE	! si = new partition table
	mov	di, bp			! To buffer area
	mov	cx, #4*PENTRYSIZE/2
	rep
	movs
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
	movb	ah, #PENTRYSIZE
	mulb	ah			! ax = al * PENTRYSIZE
	add	si, ax			! si = address of partition entry
	cmpb	sysind(si), #1		! Should be in use
	jb	error0
	jmp	loadpart		! Get the partition bootstrap

! Find the active partition
findactive:
	testb	dl, dl
	jge	nextdisk		! No partitions on floppies
	mov	si, bp
find:	cmpb	sysind(si), #0		! Partition type, nonzero when in use
	jz	nextpart
	testb	bootind(si), #0x80	! Active partition flag in bit 7
	jz	nextpart		! It's not active
loadpart:
	call	load			! Load partition bootstrap
error0:	jb	error1			! Not supposed to fail
bootstrap:
	ret				! Jump to the master bootstrap
nextpart:
	add	si, #PENTRYSIZE
	cmp	si, #BUFFER+PART_TABLE+4*PENTRYSIZE
	jb	find
! No active partition, tell 'em
	call	print
	.data2	BUFFER+noactive

! There are no active partitions on this drive, try the next drive.
nextdisk:
	incb	dl			! Increment dl for the next drive
	testb	dl, dl
	jl	nexthd			! Hard disk if negative
	int	0x11			! Get equipment configuration
	shl	ax, #1			! Highest floppy drive # in bits 6-7
	shl	ax, #1			! Now in bits 0-1 of ah
	andb	ah, #0x03		! Extract bits
	cmpb	dl, ah			! Must be dl <= ah for drive to exist
	ja	nextdisk		! Otherwise try hd0 eventually
	call	load0			! Read the next floppy bootstrap
	jb	nextdisk		! It failed, next disk please
	ret				! Jump to the next master bootstrap
nexthd:	call	load0			! Read the hard disk bootstrap
error1:	jb	error			! No disk?
	ret


! Load sector 0 from the current device.  It's either a floppy bootstrap or
! a hard disk master bootstrap.
load0:
	mov	si, bp
	mov	lowsec+0(si), ds	! Create an entry with a zero lowsec
	mov	lowsec+2(si), ds
	!jmp	load

! Load sector lowsec(si) from the current device.  The obvious head, sector,
! and cylinder numbers are ignored in favour of the more trustworthy absolute
! start of partition.
load:
	mov	di, #3		! Three retries for floppy spinup
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
	mov	ax, lowsec+0(si)
	mov	dx, lowsec+2(si)! dx:ax = sector within drive
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
	cmpb	ah, #0x80	! Disk timed out?  (Floppy drive empty)
	je	bad
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
	jmp	hang

! A read error occurred, complain and hang
error:
	call	print
	.data2	BUFFER+readerr

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


.data
devhd:		.ascii	"/dev/hd?\b"
choice:		.ascii	"\0\r\n\0"
noactive:	.ascii	"None active\r\n\0"
readerr:	.ascii	"Read error \0"
noboot:		.ascii	"Not bootable \0"
.text
endtext:
.data
enddata:
.bss
endbss:
