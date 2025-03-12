;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;here I come;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
********
*
*   etrnl3/4.s - a version of resizable reset-proff ram-drive
*                modified to work also on Mega4
*
*   An original of code eternal by John Franco.
*   This code modifies and fixes some bugs of eternal2.
*
*   A 'fractional' name of this program - eternal 3 for Mega 4 -
*   follows a fine tradition originated by one operating system.
*
*   Changes to work on Mega4 - by Michal Jaegermann, 23 May 1988
*   	this code also somehow modified in other places
*
*   Assemble this source with as68.
*
*   An unmodified source will produce a ram-drive which will be
*   installed as a drive m: with size of 300k, unless you have
*   Mega 4, in which case a default size will be 1M.
*
*   This program, when executed first time, will set a number of pointers
*   and it will reset your computer.  Execute the second time in order
*   to install ram-drive.  To automate that process, put, as the
*   FIRST program in AUTO folder.  If, on a reset,  an old ram-drive is found,
*   and no keys will intervene, then its contents will be, hopefully,
*   restored.
*
*   If some other program plays the same games with phystop pointer
*   as this program, then etrnl3/4 will be not installed, unless you
*   will force it by pressing an 'Alternate' key.  In that case, too bad
*   for the other program.
*
*   If a 'Control' key is held down, then ram-drive will be not installed.
*   If a ram drive was installed - it will be unmounted and a computer will
*   reset.  A message wil appear and it will stay until you hit a
*   'Return' key. If this program is in AUTO folder, hit 'Control' once
*   again, in order to prevent an installation of default ram-drive
*   during boot-up sequence.
*
*   'Alternate' key will let you specify drive letter and size of a ram
*   drive to install.  Already installed ram-drive will be replaced
*   with a new one.  During this process an old contents of the ram-drive
*   is wiped out.  Even if a drive letter and size remain unchanged!
*   An example of a ram drive specification - 'p200'.  Your input
*   is not checked, so be careful. Do not use drive letters already taken,
*   unless resizing ram-drive previously mounted by etrnl3/4.prg
*
*   NOTE:  For ram-drives installed with sizes around 2 MBytes and over
*   some version of TOS will come out with a wrong size information when
*   inquired from Desktop.  'df' function in gulaam fares much better.
*   If somebody has an explanation for this behaviour I am all ears.
*   It is really not very well tested when amounts of memory allocated
*   to ram-drive are in eccess of 3 MBytes.
*
*******

*  Section for an assembler to produce some constants
*  No code generated

	.offset 0

offrecsiz:	ds.w	1
offcls:		ds.w	1
offclsb:	ds.w	1
offrdlen:	ds.w	1
offfsiz:	ds.w	1
offfatrec:	ds.w	1
offdatrec:	ds.w	1
offnumcl:	ds.w	1
offbflg:	ds.w	1

offident:	ds.b	4
offdrvno:	ds.w	1

magic		.equ	'rdrv'
reset_v		.equ	4
phystop		.equ	$42e
membot		.equ	$432
memtop		.equ	$436
hdv_bpb		.equ	$472
hdv_rw		.equ	$476
hdv_mediach	.equ	$47e
drivebits	.equ	$4c4
conterm		.equ	$484

gemdos		.equ	$01
mshrink		.equ	$4a
super		.equ	$20
necin		.equ	$07
printline	.equ	$09
readline	.equ	$0a
bios		.equ	$0d
kbshift		.equ	$0b

ram_drive	.equ	12	; drive m: as68 does not constants like 'm'-'a'
st_size		.equ	300	; default ramdisk size in K's
mega_size	.equ	1024	; default ramdisk size for Mega 4

	.text

	movea.l	a7,a5			; standard preamble
	movea.l	#stack,a7
	movea.l	$4(a5),a5
	move.l	$C(a5),d0
	add.l	$14(a5),d0
	add.l	$1C(a5),d0
	add.l	#$100,d0
	move.l	d0,-(a7)
	move.l	a5,-(a7)
	move.w	#0,-(a7)
	move.w	#mshrink,-(a7)
	trap	#gemdos
	adda.l	#$C,a7

	clr.l	-(a7)
	move.w	#super,-(a7)
	trap	#gemdos
	addq.l	#6,a7
	move.l	d0,sv_sup		; save old supervisor pointer
	bclr	#$0,conterm
	move.l	memtop,a4
	move.l	#phystop,a5
        moveq   #0,d3
	cmpi.l  #$400000,(a5)
        beq     mega4
	movea.l	(a5),a5
	lea	offident(a5),a1
	move.l	(a1),d3		;I if drive installed - magic in d3
	bra	keychk
mega4:
	movea.l	(a5),a5			; a 5now contains a value of phystop
	move.w	#mega_size,(default+4)	; modify default size for mega4
keychk:
	move.w	#$FFFF,-(a7)
	move.w	#kbshift,-(a7)
	trap	#bios
	addq.l	#4,a7
	tst	d0
	beq	nokey

	tst	d3		; no ram-drive if 0
        beq	chkalt

*	you are here if something above (false) phystop and some key pushed


	cmpi.l	#magic,d3	; is this ram drive
	bne.b	chkalt		; if no - then check which key it was

*	de-install if not 'Alternate'

	lea	offdrvno(a5),a3
	move.w	(a3)+,d4
	move.w	drivebits,d5
	bclr	d4,d5
	move.w	d5,drivebits
	add.b	d4,rmlet	; set up drive letter in a message
	move.l	(a3)+,phystop
	move.l	(a3)+,memtop
	addq.l  #2,a3
	move.l	(a3)+,hdv_bpb
	addq.l  #2,a3
	move.l  (a3)+,hdv_rw
	addq.l  #2,a3
	move.l  (a3),hdv_mediach

chkalt:
	lsr.l	#4,d0
	bcs	getspec		; if Alt was pressed - ask specs
	cmpi.l	#magic,d3	; do we have an old ram drive?
	bne	exit		; no? - get out and do nothing

	move.l	#rmmess,-(a7)
	move.w	#printline,-(a7)
	trap	#gemdos
	addq.l	#6,a7
waitcr:	move.w  #necin,-(a7)
	trap	#gemdos
	addq.l	#2,a7
	cmpi.b	#$0d,d0		; cr?
	bne.b	waitcr		; try again if not
	bra	reset

getspec:
	move.l	#askspec,-(a7)
J#Imove.w	#printline,-(a7)
	trap	#gemdos
	addq.l	#6,a7
	move.l	#inpbuf,-(a7)	; read answer here
	move.w	#$A,-(a7)
	trap	#$1
J#Iaddq.l	#6,a7
	moveq	#0,d1
	move.b  entered,d1
	tst.b	d1
	beq	getspec

	moveq	#0,d0
	move.b	drvlet,d0
	subq.l	#1,d0
	andi.l	#$1F,d0
	move.w	d0,device_no
	move.b	d0,rd_bpb+3
	move.b	d0,rd_rw+3
	move.b	d0,rd_mediach+3

	cmpi.b	#$1,d1
	ble.b	default
	cmpi.b	#$6,d1
	ble.b	convert
	move.b	#$5,d1
convert:
	move	d1,d6
	subq.l	#2,d6
	moveq	#0,d0
	movea.l	#capacity,a0
collect:
	mulu	#$A,d0
	move.b	(a0)+,d1
	andi.l	#$F,d1
	add.l	d1,d0
	dbf	d6,collect
	addq.l	#2,d0
	bra.b	newsize

nokey:
	cmpi.l	#magic,d3
	beq.w	restart

default:
	move.l	#st_size,d0	; this instruction modified if mega4 detected
newsize:
	move.w	d0,numcl
	moveq	#$A,d2
	lsl.l	d2,d0		; compute size in bytes
	add.l	#$2600,d0	; + drive overhead
	move.l	d0,d1
	add.l	membot,d1	; + system
	add.l	#$20000,d1	; minimum for user
	cmp.l	a4,d1		; exit if not enough memory
	bge	exit

	move.l  #sv_phystop,a3  ; we may need old data in case of removal
	move.l	a5,(a3)+	; save old phystop
	move.l	a4,(a3)+	; save old memtop
	sub.l	d0,a5		; decrease by a requested size
	sub.l	d0,a4
	move.l  a5,phystop	; and tell computer that this is it
	move.l  a4,memtop
	addq.l  #2,a3		
	move.l  hdv_bpb,(a3)+	; fill jump table
	addq.l  #2,a3		; skip jump instruction in the table
	move.l  hdv_rw,(a3)+
	addq.l  #2,a3
	move.l	hdv_mediach,(a3)
	movea.l	#driver,a0
	moveq	#$7F,d7
movehi:	
	move.l	(a0)+,(a5)+	; move disk-driver into its place
	dbf	d7,movehi
	move.l	#$1100,d7
	moveq	#$0,d0
erase:
	move.l	d0,(a5)+	; wipe-out FATs
	dbf	d7,erase
reset:
	movea.l	reset_v,a0
	jmp	(a0)		; and force warm boot

restart:
	move.l	a5,d1			; pointer to phystop
	add.l	#(rd_mediach-driver),d1 ; install new values in vectors
	move.l	d1,hdv_mediach
	add.l	#(rd_bpb-rd_mediach),d1
	move.l	d1,hdv_bpb
	add.l	#(rd_rw-rd_bpb),d1
	move.l	d1,hdv_rw

	move.w	offdrvno(a5),d1		; put device on map
	move.w	drivebits,d0
	bset	d1,d0
	move.w	d0,drivebits
	clr.w   offbflg(a5)
exit:
	move.l	sv_sup,-(a7)
	move.w	#super,-(a7)
	trap	#gemdos
	addq.l	#6,a7
	clr.w	-(a7)			; by for now
	trap	#gemdos
	illegal				; don't tread on me

* ----------------------------------------------------------------
* this data moved into high memory
*
driver:
recsiz:	dc.w	512M
clsiz:	dc.w	2
clsizb: dc.w	1024
rdlen:	dc.w	7		; root dir len in sectors
fsiz:	dc.w	5		; FAT size in sectors
fatrec: dc.w	6		; here starts 2nd FAT
datrec: dc.w	18		; here data start
numcl:  dc.w	$01EC		; number of clusters
bflags: dc.w	0

ident:
	dc.b	'rdrv'
device_no:
	dc.w	ram_drive
sv_phystop:
	dc.l	0
sv_memtop:
	dc.l	0
jbpb:				; jump table to be filled
	dc.w	$4ef9
vbpb:
	dc.l	0		; space for vector to old bpb handler
jrw:
	dc.w	$4ef9
vrw:
	dc.l	0		; space for vector to old bpb handler
jmediach:
	dc.w	$4ef9
vmediach:
	dc.l	0		; space for vector to old bpb handler

rd_mediach:
	cmpi.w	#ram_drive,$4(a7)
	bne	jmediach
	moveq	#$0,d0
	rts

rd_bpb:
	cmpi.wI#ram_drive,$4(a7)
	bne	jbpb
	move.l	phystop,d0
	rts
rd_rw:
	cmpi.w	#ram_drive,$E(a7)
	bne	jrw
	movea.l	phystop,a0
	adda.l	#$200,a0
	movea.l	$6(a7),a1
	moveq	#$0,d1
	move.w	$C(a7),d1
	moveq	#$9,d0
	asl.l	d0,d1
	adda.l	d1,a0
	move.w	$A(a7),d0
	move.l	a1,d2
	btst	#$0,d2
	bne.b	rw_l3
	btst	#$0,$5(a7)
	bne.b	rw_l1
	exg	a0,a1
rw_l1:
	move.w	#$F,d1
rw_l2:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbf	d1,rw_l2
	subq.l	#1,d0
	bne.b	rw_l1
	rts

rw_l3:
	btst	#$0,$5(a7)
	bne.b	rw_l4
	exg	a0,a1
rw_l4:
	move.w	#$3F,d1
rw_l5:
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	dbf	d1,rw_l5
	subq.l	#1,d0
	bne.b	rw_l4
	rts

	.data
askspec:
	dc.b	'Enter ramdisk spec: ',0
inpbuf:
	dc.b	6
entered:
	dc.b	5
drvlet:
	dc.b	0
capacity:
	dc.b	0,0,0,0,0,0,0,0

rmmess:	dc.b	'Ram drive '
rmlet:	dc.b	'a'
rmcont: dc.b	' unmounted. Reset...',0

	.even
	.bss
	ds.b	$200
stack:  ds.l    1
sv_sup:
	ds.l	1
savstack:
	ds.l	1
	end

