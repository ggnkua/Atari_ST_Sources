**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
**  Direct Disk Access File Loader By Nova.
**  Set tabs to 10
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
Restore	equ	0
Seek	equ	1
Step	equ	2
Stepin	equ	3
Stepout	equ	4
Readsect	equ	5
Writesect	equ	6
Readtrk	equ	7
Writetrk	equ	8

DriveA	equ	0
DriveB	equ	1
Side0	equ	0
Side1	equ	1

pstart	move.l	sp,oldusp

	pea	stack
	move	#$20,-(sp)
	trap	#1
	move.l	d0,oldssp

	move	#1,$43e.w

	moveq	#0,d0
	bsr	restore

	bsr	initdisc		get disc format info

	lea	file,a0		get file size/1st cluster
	bsr	getfinfo
	tst.l	d0
	bmi.s	.notfound

	move.l	#1024,d2
	bsr	seek

	lea	filespace,a0	where to load
	bsr	loadfile
.notfound

	moveq	#1,d0
	bsr	restore
	move	#0,$43e.w
	move.l	oldssp,-(sp)
	move	#$20,-(sp)
	trap	#1
	move.l	oldusp,sp
	clr	-(sp)
	trap	#1

**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
**	Subroutines
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
restore
	move.l	d0,-(sp)
	move	#Restore,command
	moveq	#DriveA,d1
	moveq	#Side0,d2
	bsr	startcom
	move	#0,track
	bsr	waitend
	move.l	(sp)+,d0

	tst.l	d0
	beq	.nwo

	bsr	motoroff

.nwo	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
**  d0=file lenght		,truncated to lenght left
**  d1=start cluster	,set to first cluster to read
**  d2=bytes to seek by	,set to offset for load file routine

seek	lea	LogFat,a0
	sub.l	d2,d0
	bmi.s	.error

.seek	cmp.l	#1024,d2
	blt	.ok

	sub.l	#1024,d2		decrement seek value
	lsl	#1,d1		goto next cluster
	move	(a0,d1),d1
	bra.s	.seek

.ok	rts

.error	moveq	#-1,d0
	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
**  d0=bytes to load
**  d1=starting cluster
**  d2=offset from start of cluster to load from ( must be even )
**  a0=where to load

loadfile

	move.l	d0,size
	move	d1,cluster
	and.l	#$03FE,d2
	move	d2,offset
	move.l	a0,loadadd

	bsr	conclust

	tst	offset
	beq	.loadclusters

	move	sct,d0
	move	trk,d1
	move	side_,d2

	move	#DriveA,d3
	moveq	#2,d7
	lea	Cluster,a0
	bsr	readsectors
	bsr	copypart
	bsr	nxtcluster
.loadclusters
	cmp.l	#1024,size
	blt	.lastbit
	bsr	conclust

.clu_loop
	move	sct,sector	get info on sector to read
	move	trk,d1
	move	side_,d2
	moveq	#DriveA,d3

	bsr	loadncon
	cmp.l	#1024,size
	bge	.clu_loop

.lastbit	tst.l	size
	beq	.finload
	bmi	.finload

	move	sct,d0		get info on sector to read
	move	trk,d1
	move	side_,d2
	move	#DriveA,d3
	moveq	#2,d7
	lea	Cluster,a0
	bsr	readsectors

	move	#0,offset
	bsr	copyend

.finload	rts

***---***
copyend	lea	Cluster,a0
	move.l	loadadd,a1
	move.l	size,d0
	move.b	d0,d1
	and	#1,d1
	lsr	#1,d0
	subq	#1,d0
	bmi.s	.isodd

.cend	move	(a0)+,(a1)+
	dbf	d0,.cend

.isodd	tst	d1
	beq	.done

	move.b	(a0)+,(a1)+

.done	rts

***---***

loadncon	movem.l	d0-3,-(sp)

	cmp	track,d1		check if track moved
	beq	.read

	bsr	.movetrack

.read	move	#Readsect,command	start read op
	move.l	loadadd,transadd

	movem	d1-2,-(sp)
	move	d3,d1
	bsr	startcom
	movem	(sp)+,d1-2

	movem.l	(sp)+,d0-3

	bsr	nxtcluster	find next cluster
	bsr	conclust		convert cluster to phy sector
	add.l	#512,loadadd	move load address
	sub.l	#1024,size	decrease size left

	bsr	waitend

	move	sector,d0
	addq	#1,d0
	cmp	Sectors_Track,d0
	ble	.notover
	move	#1,d0

	addq	#1,d2
	cmp	Number_Sides,d2
	ble	.notover
	move	#0,d2

	addq	#1,d1
.notover	move	d0,sector

	cmp	track,d1		check if track moved
	beq	.read2

	bsr	.movetrack

.read2	move	#Readsect,command	start read op
	move.l	loadadd,transadd

	movem	d1-2,-(sp)
	move	d3,d1
	bsr	startcom
	movem	(sp)+,d1-2

	add.l	#512,loadadd
	bsr	waitend

	rts
***---***
.movetrack
	movem	d1-2,-(sp)

	move	d1,track
	move	#Seek,command
	move	d3,d1
	bsr	startcom
	bsr	waitend

	movem	(sp)+,d1-2

	rts
***---***
conclust	movem.l	d0-3,-(sp)
	move	cluster,d0
	bsr	cluster2log
	bsr	log2phy
	move	d0,sct
	move	d1,trk
	move	d2,side_
	movem.l	(sp)+,d0-3
	rts

***---***
nxtcluster
	movem.l	d0/a0,-(sp)
	move	cluster,d0
	lea	LogFat,a0
	lsl	#1,d0
	move	(a0,d0),d0
	move	d0,cluster
	movem.l	(sp)+,d0/a0
	rts

***---***
copypart
	lea	Cluster,a0
	add	offset,a0
	move.l	loadadd,a1

	move.l	#1024,d0
	sub	offset,d0
	bmi.s	.copysmall
	sub.l	d0,size
	lsr	#1,d0
	subq	#1,d0
.copy2	move	(a0)+,(a1)+
	dbf	d0,.copy2
	move.l	a1,loadadd
	rts

.copysmall
	move.l	size,d0
.copy	subq	#2,d0
	bmi.s	.fin1
	move	(a0)+,(a1)+
	bra.s	.copy
.fin1	move.l	a1,loadadd
	move.l	#0,size
	rts

***---***
sct	dc.w	0
trk	dc.w	0
side_	dc.w	0

cluster	dc.w	0
size	dc.l	0
offset	dc.w	0
loadadd	dc.l	0

**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
**  this routine gets the lenght and attribute of the file in a0
**  and the starting cluster in d2

**  a0=file name
**  d0=file lenght
**  d1=first cluster
**  d2=file attribute

getfinfo
	bsr	logname2phyname	convert file name to disc format
	bsr	findindir		find name in the directory
	tst.l	d0
	bmi.s	.nfound

	moveq	#0,d0		get file size
	move.b	31(a0),d0
	rol.l	#8,d0
	move.b	30(a0),d0
	rol.l	#8,d0
	move.b	29(a0),d0
	rol.l	#8,d0
	move.b	28(a0),d0

	moveq	#0,d2		get file attribute
	move.b	11(a0),d2

	moveq	#0,d1		get first cluster
	move.b	27(a0),d1
	rol.l	#8,d1
	move.b	26(a0),d1

.nfound	rts
**--**--**--**--**--**
**  finds file in phyname in the directory
**  a0=pointer to filename in directory
**  d0=0 if file found -1 if not found

findindir
	movem.l	d1-3/a1-3,-(sp)

	moveq	#-1,d0
	lea	RootDirectory,a0
	lea	phyname,a1

.entry	move.l	a0,a2
	move.l	a1,a3
	moveq	#10,d3

.check	move.b	(a2)+,d1
	move.b	(a3)+,d2
	cmp.b	d1,d2
	bne.s	.nxt
	dbf	d3,.check

	moveq	#0,d0
	movem.l	(sp)+,d1-3/a1-3
	rts

.nxt	lea	32(a0),a0
	tst.l	(a0)		if entry is 0 then no more entrys
	beq	.end
	bra	.entry

.end	movem.l	(sp)+,d1-3/a1-3
	rts

**--**--**--**--**--**
**  a0=name to convert to disc format name

logname2phyname

	movem.l	d0/a0-1,-(sp)

	lea	phyname,a1
	move.l	#'    ',(a1)	clear the name
	move.l	#'    ',4(a1)
	move.l	#'    ',8(a1)

.convert	move.b	(a0)+,d0		get byte
	tst.b	d0		if zero we've done
	beq	.done
	cmp.b	#'.',d0		test for '.'
	beq.s	.pad		if so pad it out

	move.b	d0,(a1)+
	bra.s	.convert

.pad	lea	phyname+8,a1

.doext	move.b	(a0)+,d0
	tst.b	d0
	beq.s	.done
	move.b	d0,(a1)+
	bra.s	.doext

.done	movem.l	(sp)+,d0/a0-1
	rts

**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
**  this subroutine get the format info of drive A and gets the fat and
**  directory.

initdisc
	bsr	restore
	bsr	getBOOT
	bsr	getformatinfo
	bsr	getFAT
	bsr	decodefat
	bsr	getDIR
	moveq	#0,d0
	rts

badformatt
	moveq	#-1,d0
	rts

getBOOT	moveq	#1,d0
	moveq	#0,d1
	moveq	#Side0,d2
	moveq	#DriveA,d3
	moveq	#1,d4
	lea	Sector,a0
	bsr	readsector
	rts
getFAT
	moveq	#2,d0			read all Fat table
	moveq	#0,d1			at track zero
	moveq	#0,d2			side zero
	moveq	#3,d7
	lea	RootDirectory,a0		load fat into directory
	bsr	readsectors		space
	rts

getDIR	move	#1,d0			calculate log sect of dir
	move	Sectors_Fat,d1
	move	Number_Fats,d2
	mulu	d2,d1
	add	d1,d0
	bsr	log2phy

	moveq	#0,d3			drive a
	moveq	#1,d4			leave drive on
	lea	RootDirectory,a0
	move	Sectors_Root,d7
	cmp	#7,d7
	bgt	badformatt
	bsr	readsectors		read all root directory
	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
decodefat
	lea	RootDirectory,a0
	lea	LogFat,a1

	move	#900-1,d7		max fat entrys

.decode	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.b	(a0)+,d1		get 8 highest bits of lo entry 
	move.b	(a0)+,d2		store byte to be split
	move.b	(a0)+,d0		get 8 highest bits of hi entry
	lsl	#4,d0		move bits
	move.b	d2,d3		make copy
	lsr	#4,d2		get lo 4 bits of hi entry
	or	d2,d0		put lo bits in hi entry
	and	#15,d3		get high bits of lo entry
	rol	#8,d1		shift lo bits
	move.b	d3,d1		set high bits
	rol	#8,d1		correct entry

	move	d1,(a1)+		store decoded entrys
	move	d0,(a1)+
	dbf	d7,.decode

	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
getformatinfo
	lea	Sector,a0

	moveq	#0,d0
	move.b	16(a0),d0
	move	d0,Number_Fats

	move.b	17(a0),Max_Dir_Entrys+1     Words are stored backwards
	move.b	18(a0),Max_Dir_Entrys

	move.b	19(a0),Total_Sectors+1
	move.b	20(a0),Total_Sectors

	move.b	22(a0),Sectors_Fat+1
	move.b	23(a0),Sectors_Fat

	move.b	24(a0),Sectors_Track+1
	move.b	25(a0),Sectors_Track

	move.b	26(a0),Number_Sides+1
	move.b	27(a0),Number_Sides

	move	Max_Dir_Entrys,d0
	lsr	#4,d0
	move	d0,Sectors_Root

	moveq	#0,d0
	move	Total_Sectors,d0
	moveq	#0,d1
	move	Sectors_Track,d1
	divu	d1,d0
	move	Number_Sides,d1
	divu	d1,d0
	move	d0,Number_Tracks

	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
**  d0 = cluster number
**  d0 = logical sector that cluster starts at, on return

cluster2log

	movem.l	d1-2,-(sp)

	subq	#2,d0		-2 'cause clusters 1+2 don't exist
	lsl	#1,d0		*2 for 2 sectors per cluster
	addq	#1,d0		add 1 sector for boot sector

	move	Sectors_Fat,d1
	move	Number_Fats,d2
	mulu	d2,d1		number of sectors for fats
	add	d1,d0
	add	Sectors_Root,d0	add root directory on

	movem.l	(sp)+,d1-2
	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
**  d0 = logical sector
**  d0 = physical sector
**  d1 = physical track
**  d2 = side

log2phy

	moveq	#0,d2
	moveq	#0,d3
	move	Sectors_Track,d2	work out sectors per track
	move	Number_Sides,d3	with two sides
	mulu	d3,d2

	move	d0,d3		divide log sector by sct/trk
	and.l	#$FFF,d3
	divu	d2,d3
	move	d3,d1		got physical track
	swap	d3		remainder = sector of phy trk

	cmp	Sectors_Track,d3
	bge.s	.side2
	clr	d2
	move	d3,d0
	addq	#1,d0	not counting from zero for phy sector
	rts

.side2	move	#1,d2
	sub	Sectors_Track,d3
	move	d3,d0
	addq	#1,d0
	rts

**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
**  d0=sector number
**  d1=track
**  d2=side
**  d3=drive
**  d7=number of sectors to read
**  a0=where to read/write

readsectors
	subq	#1,d7
	bmi.s	.lasttrack

.readem	movem.l	d0-3/a0,-(sp)
	bsr	readsector
	movem.l	(sp)+,d0-3/a0
	lea	$200(a0),a0

	addq	#1,d0
	cmp	Sectors_Track,d0
	ble	.notover
	moveq	#1,d0

	addq	#1,d2
	cmp	Number_Sides,d2
	ble	.notover
	move	#0,d2

	addq	#1,d1
	cmp	Number_Tracks,d1
	beq	.lasttrack

.notover	dbf	d7,.readem
	moveq	#0,d0
	rts

.lasttrack
	moveq	#-1,d0
	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
**  d0=sector number
**  d1=track
**  d2=side
**  d3=drive
**  a0=where to read/write

readsector
	move.l	a0,transadd
	move	d0,sector

	cmp	track,d1
	beq	.read

	move	d1,track
	move	#Seek,command
	movem.l	d0-3,-(sp)
	move	d3,d1
	bsr	startcom
	bsr	waitend
	movem.l	(sp)+,d0-3

.read	move	#Readsect,command
	move	d3,d1
	bsr	startcom
	bsr	waitend
	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
**  d0=command to do
**  d1=drive
**  d2=side

startcom
	bsr	Select_Drive
	bsr	FDCaccess
	rts

waitend	move.l	#2000000,d6	gives approx. 4 secounds

.wfeoc	subq.l	#1,d6
	beq	.timedout
	nop
	nop
	btst	#5,$FFFFFA01.w
	bne.s	.wfeoc
	clr.l	d6
	rts
.timedout	moveq	#-1,d6
	rts

motoroff	move	#$180,$FFFF8606.w	select status reg
.motson	move	$FFFF8604.w,d0
	tst.b	d0
	bmi.s	.motson
	move	d0,stat
	moveq	#-1,d1
	moveq	#0,d2
	bsr	Select_Drive
	rts

Select_Drive
	eor	#1,d2		flip side
	tst	d1
	bmi	.nodrive
	beq	.driveA
	move	#%0010,d1
	bra	.setd
.driveA	move	#%0100,d1
	bra	.setd
.nodrive	move	#%0110,d1
.setd	or	d2,d1
	move.b	#14,$FFFF8800.w
	move.b	d1,$FFFF8802.w
	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
FDCaccess
	move.l	d0,-(sp)

	move	command,d0
	cmp	#8,d0
	bgt	.notvalid

	lsl	#2,d0
	jsr	jtab(pc,d0.w)

.notvalid	move.l	(sp)+,d0
	rts

jtab	bra	_restore		0
	bra	_seek		1
	bra	_step		2
	bra	_stepin		3
	bra	_stepout		4
	bra	_readsect		5
	bra	_writesect	6
	bra	_readtrk		7
	bra	_writetrk		8

_restore	move	#$80,$FFFF8606.w
	move	#$01,$FFFF8604.w
	rts

_seek	move	#$86,$FFFF8606.w
	move	track,$FFFF8604.w
	move	$FFFF8606.w,stat
	move	#$80,$FFFF8606.w
	move	#$11,$FFFF8604.w
	rts

_step	move	#$80,$FFFF8606.w
	move	#$31,$FFFF8604.w

_stepin	move	#$80,$FFFF8606.w
	move	#$51,$FFFF8604.w
	rts

_stepout	move	#$80,$FFFF8606.w
	move	#$71,$FFFF8604.w
	rts

_readsect	move	#$84,$FFFF8606.w
	move	sector,$FFFF8604.w

	bsr	_writeaddress

	move	#$90,$FFFF8606.w
	move	#$190,$FFFF8606.w
	move	#$90,$FFFF8606.w
	move	#1,$FFFF8604.w

	move	#$80,$FFFF8606
	move	#$80,$FFFF8604
	rts

_writesect
	move	#$84,$FFFF8606.w		set as read sector as it
	move	sector,$FFFF8604.w		doesn't work

	bsr	_writeaddress

	move	#$90,$FFFF8606.w
	move	#$190,$FFFF8606.w
	move	#$90,$FFFF8606.w
	move	#1,$FFFF8604.w

	move	#$80,$FFFF8606.w
	move	#$80,$FFFF8604.w
	rts

_readtrk	bsr	_writeaddress
	move	#$90,$FFFF8606.w
	move	#$190,$FFFF8606.w
	move	#$90,$FFFF8606.w
	move	#13,$FFFF8604.w
	move	#$80,$FFFF8606.w
	move	#$E0,$FFFF8604.w
	rts

_writetrk	bsr	_writeaddress
	move	#$190,$FFFF8606.w
	move	#$90,$FFFF8606.w
	move	#$190,$FFFF8606.w
	move	#13,$FFFF8604.w
	move	#$180,$FFFF8606.w
	move	#$F0,$FFFF8604.w
	rts
_writeaddress
	move.b	transadd+3,$FFFF860d.w
	move.b	transadd+2,$FFFF860b.w
	move.b	transadd+1,$FFFF8609.w
	rts

command	dc.w	0		command to do

sector	dc.w	0		start sector
track	dc.w	0
side	dc.w	0
drive	dc.w	0
transadd	dc.l	0		where to read/write data from

stat	dc.w	0		status of FDC

**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
installFDCrout
	move.l	$11C.w,oldFDC		save old vector
	move.l	#FDCaccess,$11C.w		set mine

	or.b	#$80,$FFFFFA09.w		enable FDC on MFP
	or.b	#$80,$FFFFFA15.w
	and.b	#$7F,$FFFFFA11.w		ensure ISR bit is clear
	move	#1,$43E.w
	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
removeFDCrout
	or.b	#$80,$FFFFFA11.w		ensure ISR bit is set
	and.b	#$7F,$FFFFFA09.w		disable FDC on MFP
	and.b	#$7F,$FFFFFA15.w
	move.l	oldFDC,$11C.w
	move	#0,$43E.w
	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
	Section Data
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
file	dc.b	'FLOAD.S',0
	even
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
	Section Bss
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
oldusp	ds.l	1
oldssp	ds.l	1
oldFDC	ds.l	1

	ds.l	128
stack	ds.l	2


phyname	ds.b	12		store name in disc format

Sectors_Track	ds.w	1	sectors per track
Number_Tracks	ds.w	1	number of tracks
Total_Sectors	ds.w	1	total sectors on disc
Number_Sides	ds.w	1	single or double sided

Number_Fats	ds.w	1	How many fats there are
Sectors_Fat	ds.w	1	sectors per fat
Sectors_Root	ds.w	1	calculated from Max_Dir_Entrys
Max_Dir_Entrys	ds.w	1	number of root directory entrys

LogFat		ds.w	900	Decoded Fat ( 16 bits/entry )
Cluster		ds.b	512
Sector		ds.b	512
RootDirectory	ds.b	512*7	space for root directory

filespace		ds.b	20000

