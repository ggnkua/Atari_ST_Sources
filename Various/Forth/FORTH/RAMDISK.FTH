( RamDisk.fth
  June 28, 1986
  Based on a PD program by Jens-Uwe Mager.
  Just adjust the value of 'kBytes' and load this file into Mach2.
  The resulting application can be put into your 'AUTO' folder.
  References are to Abacus' GEM INTERNALS book.)

( ATARI QUIRK! If you copy files into the disk's icon instead of window,
  the window isn't updated, that is, the new file won't appear. Things
  work properly if you copy files into the window. Hitting the ESC will
  tell the ST to update the front window. Wierd.)

( You'll install a new disk each time you run RAMDISK.PRG. New disks
  don't show on the desktop, though, until you install a disk icon. To
  do this, select a disk icon, pull-down the OPTIONS menu and
  INSTALL NEW DRIVE. If you always you the same number of disks, just
  SAVE DESKTOP after this so you never have to worry about that icon.)

variable progStart	( will hold addr of begin of .PRG section)
variable progEnd	( will hold addr of end)

only forth
also GEM also assembler
decimal

			( ****** RAM disk size ******)
100	constant kBytes	( <===** ADJUST THIS ********)
			( ***************************)
kBytes 1024 *
	constant ramDiskSize

60 user fileID
hex

( base page offsets)
C	constant prglen		( never any data segment)
18	constant bssbase	( begin of bss, i.e., addr of ramdisk)
1C	constant bsslen		( size of bss, i.e., of ramdisk)

( ATARI global variables. See pg. 251 INTERNALS)
472	constant hdv_bpb
476	constant hdv_rw
47E	constant hdv_media
4C2	constant drvbits

( trap stuff)
E	constant xbios
1	constant tos
31	constant termres	( terminate and stay resident)
26	constant supexec	( for exec'ing install code in super mode)

: dummy ;
decimal

here progStart !

( what follows will be written out as an application w/o any Forth)

( ********************************************************* )
( **************** RAMDISK.PRG **************************** )
( ********************************************************* )

		( this is a .PRG file header. See pg.597 GEM INTRO/GEMDOS)
DC.W	$601A	( code meaning contiguous program segments)
DC.L	0	( will get patched with length of code)
DC.L	0	( length of data seg is 0 in this program)
ramDiskSize ,	( bss segment is where the ram disk is)
DC.L	0	( no symbol table)
DC.L	0	( resvd, always 0)
DC.L	0	( resvd, always 0)
DC.W	0	( resvd, always 0)

( .text)
( now starts the code. Execution will start here at launch)

CODE JMPToMain	( will get patched forward to Main)
	JMP	dummy	( junk to force a PC-relative opcode)
END-CODE

header drive	( 'Install' searches for 1st avail drive and puts # here)
	DC.W	0

header rambase	( will hold begin addr of ram disk area)
	DC.L	0

header mybpb	( see p. 149 INTERNALS)
	DC.W	512	( bytes/sector)
	DC.W	2	( sectors/cluster)
	DC.W	1024	( bytes/cluster)
	DC.W	7	( sectors in directory)
	DC.W	5	( sectors in a FAT)
	DC.W	6	( sector # of 2nd FAT)
	DC.W	18	( sector # of 1st avail data cluster)
	kBytes 9 - w,	( number of clusters available)
	DC.W	0	( ? 'misc flags')

CODE oldMediaCh	( 'Install' patches this to jmp to other mediaCh routine)
	JMP	80000	( to force an ABS.L)
END-CODE

CODE mediaCh	( will become the system mediaCh routine)
	MOVE.W	drive,D0
	CMP.W	4(A7),D0	( talking to us?)
	BNE.S	oldMediaCh	( no)
	MOVEQ.L	#0,D0		( means 'media definitely unchanged')
	RTS
END-CODE

CODE oldgetBPB	( 'Install' will patch this to jump to other getBPB routine)
	JMP	80000
END-CODE

CODE getBPB	( will become the system getBPB routine)
	MOVE.W	drive,D0
	CMP.W	4(A7),D0	( would you like my bpb?)
	BNE.S	oldgetBPB	( alas, no)
	LEA	mybpb,A0
	MOVE.L	A0,D0		( return ramdisk's bpb)
	RTS
END-CODE

CODE oldrw	( 'Install' will patch this to jump to original rw routine)
	JMP	80000	( 80000 forces a JMP ABS.L)
END-CODE

CODE rw		( will become system's rw routine)
	MOVE.W	drive,D0
	CMP.W	14(A7),D0	( rw to ramdisk?)
	BNE.S	oldrw		( no)
	MOVE.L	rambase,A0	( addr of begin of ram disk)
	MOVE.L	6(A7),A1	( addr of the r/w buffer)
	MOVE.W	12(A7),D1	( starting sector number)
	MOVEQ.L	#9,D0		( * 512)
	ASL.L	D0,D1
	ADDA.L	D1,A0
	MOVE.W	10(A7),D0	( number of sectors to r/w)
	MOVE.L	A1,D2
	BTST	#0,5(A7)	( test the r/w flag. odd is write)
	BNE.S	@Cont
	EXG	A0,A1
@Cont	BTST	#0,D2		( see if the dummy has buffer on odd addr)
	BNE.S	@Bytes

	ASL.L	#7,D0		( blocks -> longs)
@Longs	MOVE.L	(A1)+,(A0)+	( move long words into place)
	SUBQ.L	#1,D0
	BNE.S	@Longs
	RTS			( always returns result code of 0 in D0)

@Bytes	MOVEQ.L	#9,D1
	ASL.L	D1,D0		( blocks -> bytes)
@Bytes1	MOVE.B	(A1)+,(A0)+	( mvoe bytes into place)
	SUBQ.L	#1,D0
	BNE.S	@Bytes1
	RTS			( always return a result code of 0 in D0)

END-CODE

CODE Install		( this installs the ramdisk at launch time)
	LEA	oldrw,A0	( first save old routines)
	MOVE.L	hdv_rw,2(A0)
	LEA	oldgetbpb,A0
	MOVE.L	hdv_bpb,2(A0)
	LEA	oldmediach,A0
	MOVE.L	hdv_media,2(A0)

	LEA	rw,A0
	MOVE.L	A0,hdv_rw	( now install new routines)
	LEA	getbpb,A0
	MOVE.L	A0,hdv_bpb
	LEA	mediach,A0
	MOVE.L	A0,hdv_media

	LEA	rambase,A0	( install address of begin of disk)
	MOVE.L	bssbase(A6),(A0)

	MOVE.L	drvbits,D0	( now find an available drive no.)
	MOVE.L	D0,D2
	BSET	#2,D0		( avoid slot C for some reason)
	MOVEQ.L	#0,D1
@drvlp	LSR.L	#1,D0
	BCC.S	@drvfnd
	ADDQ.W	#1,D1
	BRA.S	@drvlp
@drvfnd	BSET	D1,D2		( set appropriate bit in drvmap)
	LEA	drive,A0
	MOVE.W	D1,(A0)	( and save drive number so ram disk knows)
	MOVE.L	D2,drvbits
	RTS
END-CODE

CODE Main			( this is the main launch itme routine)
	MOVE.L	4(A7),A6	( get the base page address)

	PEA	Install		( execute the install routine in super)
	MOVE.W	#supexec,-(A7)	( so it can access low memory)
	TRAP	#xbios
	ADDQ.L	#6,A7

	MOVE.L	prglen(A6),D0	( now figure how much to leave resident)
	ADD.L	bsslen(A6),D0	( this is the size of the ramdisk)
	CLR.W	-(A7)		( exit code)
	MOVE.L	D0,-(A7)	( how much to leave resident)
	MOVE.W	#termres,-(A7)
	TRAP	#tos		( that's all. Ramdisk installed.)
END-CODE

header	TextEnd			( for patching purposes)
( now I continue with more of the structure of a .PRG file)

( .data)	( don't use a data segment)
( .symbol)	( don't use any symbols)

DC.L	0,0,0	( and I don't use any relocation)

( .end)

( *******************************************************)
( ************** END OF RAMDISK.PRG *********************)
( *******************************************************)

here progEnd !

( PATCH TIME!)
( patch the initial PC-rel jump to jump down to main at launch time)

' Main ' JMPToMain 2+ -
' JMPToMain 2+ w!

( patch the length of the text segment
  of this program into the .PRG header)

' TextEnd ' JMPToMain - 
progStart @ 2+ !


( now save out the image)
: SAVE.IMAGE		( since this file could be loaded from disk,
			CREATE" would close this file, ending the
			load. So define this word  and then run it
			when this file needn't be open anymore.)
	fileid w@		( save this file's id if loading from disk)
	0 fileid w!		( system thinks no file is open)
	CREATE" RAM_100.PRG"	( change name to reflect size)
	progStart @		( buffer address)
	progEnd @ progStart @ -	( count)
	fWrite	drop		( write it out)
	close-file		( save it)
	fileID w!		( put fileid back to continue loading)
				( smile)
	empty			( dump all this code)
	;

SAVE.IMAGE
