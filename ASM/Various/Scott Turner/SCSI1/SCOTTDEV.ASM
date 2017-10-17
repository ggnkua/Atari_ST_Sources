* scottdisk.asm Copyright 1987 by Scott Turner ALL RIGHTS RESERVED
*
* This is a MOUNTable device driver for the MicroForge SCSI buss interface.
* It may not chase yer mouse pointer around the screen, but I think someone
* will find it useful :-). The strict license below is not because I'm an
* asshole, but because there ARE assholes out there in the world. I've put
* alot of effort into the driver and it is my sincere wish that it be made
* available to ANYONE who wants it so long as the person or entity providing
* it to them doesn't make a profit off it. BE WARNED, THIS IS NOT A 'PLAY'
* LICENSE, I MEAN IT. (grrrr)
*
* This device driver supports 1 (ONE) SCSI buss device. This device can have
* 2 (TWO) hard disk units attached to it. This driver is currently tuned for
* use with an OMTI 5100 SCSI buss device.
*
* Please note that the OMTI needs a little breathing space after completion
* of one command before beginning another. This driver is tuned to work on a
* MC68000 or MC68010 running at the factory clock rate. If you jack the clock
* rate or use an MC68020 you may need to re-tune this driver.
*
* Please note that this device driver uses the power LED as a disk activity
* indicator.
*
* Formatting the hard disk seems to be a touchy area for most disk drivers
* I've seen or heard about. This driver uses the SCSI command #4 to format
* the drive if it is issued a format command for IO_OFFSET 0. I tried using
* the OMTI format track command but it didn't really seem to format the
* track because when I hit the un-formatted part of my test hard disk it
* didn't format it. (Reads would return error $94) So I fell back to my
* less than ideal solution of issuing the format command at offset 0. This
* allows you to format the hard disk with the CLI FORMAT command, but none
* of the other 'nifty' uses of a track by track formatter are available.
* This may seem like a total bummer but then again more than a few controllers
* can't format a single track. :) PLEASE NOTE: Unlike the MessyDOS FORMAT
* command, there IS NO CHANCE of recovering data from the drive! So let's be
* careful out there. ;)
*
* The MOUNT command can be used to partition the two hard disk drives into
* smaller pieces. (See hints below)
*
* Here is a sample mountlist entry for a Seagate ST-4051:
*	DH0:       Device = scottdisk.device
*	           Unit   = 0
*	           Flags  = 1
*	           Surfaces  = 5
*	           BlocksPerTrack = 17
*	           Reserved = 2
*	           Interleave = 0
*	           LowCyl = 0  ;  HighCyl = 976
*	           Buffers = 30
*	           BufMemType = 0
*	#
* Don't forget that the numbers used in the mountlist and used at the end of
* this driver DO NOT HAVE TO MATCH. HOWEVER, the total SIZE given in the
* mountlist MUST NOT exceed the size encoded at the end of this driver.
*
* To setup a system for operation:
*	1. Configure the driver for your hard disk drive(s).
*	2. Construct this driver and place the result in df0:devs/scottdisk.device
*	3. Insert entry(s) into df0:devs/mountlist
*	4. For each drive:
*		A. mount <entryname>
*		B. format drive <entryname> name <somename>
*		C. Insert 'mount <entryname>' into your df0:s/startup-sequence
*	5. Enjoy! :-)
*
* Hints:
* If like me you hate using a slow 2nd floppy drive to copy disks, then setup
* a partition on your hard disk using mountlist. Make it the same as an
* amiga floppy: 11 sectors per track, 2 sides, 80 tracks. Then mount it and
* you can diskcopy to/from a floppy to/from it! You can even call it DF1! :)
* Rather than use the CLI AddBuffers command just tweak the 'Buffers =' line in
* the mountlist entry.
*
* Please note that this driver could have tons of things done to it to improve
* performance. And I am currently continuing work to make all sorts of changes
* to this driver to improve performance. This version is being released at this
* time so that others can get some use from it while I labor on.
*
* If you have questions/comments/requests concerning this source code, please
* direct them in WRITING (no I don't mean via phone!) to:
*
* Scott Turner
* L5 Computing
* 12311 Maplewood Avenue
* Edmonds, WA. 98020-1115 USA
*
* I may also be reached via:
*
* JST on GEnie
* scotty@l5comp.UUCP or stride!l5comp!scotty
*
* I am NOT releasing this source code into the public domain. However, I here
* by grant a license for distribution via AmigaDOS format 3.5" diskette or via
* an online telecommunications medium provided that the party charges less than
* the following to do so:
*
* USA $10 for a copy on an AmigaDOS 3.5" disk.
* USA $10 an hour for 1200 baud connection at 18:00 PST from Seattle, WA USA.
*
* You may not use this source code to make object code if you intend to charge
* anything above the above limits for the object code alone. ie you may not
* sell the object code for more than the above stated limits for the source.
*
* I also hereby grant a license for converting this source code for the
* following purposes:
*	1. To change the hard disk drive parameters.
*	2. To work with other SCSI buss interface cards.
*	3. To work with other SCSI buss devices.
*	4. Re-tune time delays.
*
* HOWEVER, under this license you may NOT:
*	1. Remove my copyright.
*	2. Modify or make additions to this license.
*	3. Change the name of the device from 'scottdisk.device'.
*	4. Change the limitation on charges for object code.
*
* (If you wonder if I'm egotistical, please note that 'scott' is the same
* length as 'track'. This is handy for patching disk editors to use this device
* driver rather than trackdisk.device.)
*
* I reserve all other rights. This source code is made available "AS IS" and I
* make no warranties for it's fitness for any purpose.
*
*------------------------------------------------------------------------------
*
* I hate assembling 3,000 lines of include files. How about you?
*
* Definition of our base variables
* This first part is cast in concrete
LibNegSize	EQU	16
LibPosSize	EQU	18
OpenCount	EQU	32
*
* End of pre-defined lib-base structure, we can now do as we damn well please.
CurUnit		EQU	34
CurIOReq	EQU	36
CurBlock	EQU	40
CurBuffer	EQU	44
NotifyIRQ	EQU	48
NeedNotify	EQU	52
DosBase		EQU	56
BaseVarSize	EQU	60
*
* External references to EXEC
_MakeLibrary	EQU	-6*14
_Forbid		EQU	-6*22
_Permit		EQU	-6*23
_Cause		EQU	-6*30
_AddPort	EQU	-6*59
_PutMsg		EQU	-6*61
_GetMsg		EQU	-6*62
_ReplyMsg	EQU	-6*63
_WaitPort	EQU	-6*64
_OpenLibrary	EQU	-6*68
_CloseLibrary	EQU	-6*69
_AddDevice	EQU	-6*72
*
* External AmigaDOG reference
_CreateProc	EQU	-6*23
*
* Address of SCSI port
CtrlAddr	EQU	$EF7000
*
* Device version
MajorVersion	EQU	33
MinorVersion	EQU	1
*
* Number of blocks per track for BOTH DRIVES!!!
BlocksPerTrack	EQU	17
*
* Driver header
DriverIDString	DC.B	'ScottDisk 33.1 (23 May 1987)',13,10,0
MatchTag	DC.W	$4AFC		; RT_MATCHWORD
		DC.L	MatchTag	; RT_MATCHTAG
		DC.L	EndOfDriver	; RT_ENDSKIP
		DC.B	1		; RT_FLAGS
		DC.B	MajorVersion	; RT_VERSION
		DC.B	3		; RT_TYPE
		DC.B	30		; RT_PRI
		DC.L	DeviceName	; RT_NAME
		DC.L	DriverIDString	; RT_IDSTRING
		DC.L	DriverInit	; RT_INIT
*
* NOTE: This table is up here so the entries are positive in value. I don't
* know if this is important or not.
VectorTable	DC.W	-1	; Entries are relative to VectorTable
		DC.W	DeviceOpen-VectorTable		; Open
		DC.W	DeviceClose-VectorTable		; Close
		DC.W	DeviceNull-VectorTable		; Expunge
		DC.W	DeviceNull-VectorTable		; NULL
		DC.W	DeviceBeginIO-VectorTable	; BeginIO
		DC.W	DeviceNull-VectorTable		; AbortIO
		DC.W	-1	; End of the table

DeviceOpen	CMPI.L	#1,D0		; Unit number = 0 or 1?
		BHI.S	0$
		MOVE.L	D0,24(A1)	; Then AOK
		CLR.B	31(A1)		; IO_ERR := 0
		ADDQ.W	#1,32(A6)	; Bump open count
		RTS       
*
* Illegal unit # requested
0$		MOVE.B	#32,31(A1)	; Return bad unit number error
		RTS

DeviceClose	MOVEQ	#-1,D0
		MOVE.L	D0,24(A1)	; Kill unit #
		MOVE.L	D0,20(A1)	; Kill device pointer
*
* Dec open counter, but don't let it go negative
		MOVE.W	OpenCount(A6),D0
		BEQ.S	0$
		SUBQ.W	#1,D0
		MOVE.W	D0,OpenCount(A6)
0$		MOVEQ	#0,D0
		RTS       

DeviceBeginIO	MOVEM.L	D1/A0-A1,-(A7)
		CMPI.L	#1,24(A1)	; Legal unit #?
		BHI.S	3$
		CLR.B	31(A1)		; IO_ERR := 0
		MOVE.B	29(A1),D0	; Get command
		SUBI.B	#12,D0		; Standard command?
		BLT.S	2$
		CMPI.B	#4,D0		; Special command?
		BGE.S	2$
		TST.B	D0
		BNE.S	0$
*
* Record notify info
		MOVE.L	40(A1),NotifyIRQ(A6)
		SNE	NeedNotify(A6)
		BRA.S	1$
*
* Return command packet now
3$		MOVE.B	#32,31(A1)	; IO_ERR := bad unit you nerd!
0$		CLR.L	32(A1)
1$		BSET	#7,30(A1)
		MOVE.B	#5,8(A1)
		MOVEM.L	(A7)+,D1/A0-A1
		MOVEQ	#0,D0
		RTS       

*
* Post command to the handler
2$		ANDI.B	#$7E,30(A1)	; Clear status flags
		LEA	OurPort,A0
		MOVE.L	A6,-(A7)
		MOVEA.L	4,A6
		JSR	_PutMsg(A6)
		MOVEA.L	(A7)+,A6
		MOVEM.L	(A7)+,D1/A0-A1
		MOVEQ	#0,D0
DeviceNull	RTS       

DriverInitStructure
		DC.B	%11100000
		DC.B	0
		DC.W	$8	; LN_TYPE
		DC.B	3	; Device
		DC.B	0	; Pad
		DC.B	%11000000
		DC.B	0
		DC.W	$A	; LN_NAME
		DC.L	DeviceName
		DC.B	%11100000
		DC.B	0
		DC.W	$E	; LIB_FLAGS
		DC.B	6	; Value for LIB_FLAGS, JustChanged, and please sum
		DC.B	0	; Padding
		DC.B	%11000000
		DC.B	0
		DC.W	20	; LIB_VERSION
		DC.W	MajorVersion
		DC.W	MinorVersion
		DC.L	0

DogName		DC.B	'dos.library',0
NewProcRecord	DC.L	DeviceName
		DC.L	5
		DC.L	SegList
		DC.L	256

DriverInit	MOVEM.L	A2/A6,-(SP)
		MOVEA.L	4,A6
*
* Build library structure
		LEA	VectorTable,A0	; Vectors
		LEA	DriverInitStructure,A1	; InitStructure
		SUBA.L	A2,A2		; InitRoutine, NULL we're already running!
		MOVEQ	#BaseVarSize,D0	; Our data seg size
		JSR	_MakeLibrary(A6)
		TST.L	D0
		BEQ.S	TwilightZone	; Go there if we didn't get created
*
* We were created
* Save library base for the new process
		MOVE.L	D0,LibraryBase
		MOVEA.L	D0,A2
*
* Create a process for our handler
		LEA	DogName(PC),A1
		MOVEQ	#0,D0
		JSR	_OpenLibrary(A6)
		MOVE.L	D0,DosBase(A2)
		MOVEA.L	D0,A2
*
* Create the handler process
		MOVEM.L	NewProcRecord(PC),D1-D4
		LSR.L	#2,D3		; Linker won't do this :)
		JSR	_CreateProc(A2)
		SUBI.L	#$5C,D0		; Convert DOS process to Exec process
		MOVE.L	D0,PortTask	; Patch message port
*
* Add our communications port to the system list
		LEA	OurPort,A1
		JSR	_AddPort(A6)
*
* Add us to the system device list
		MOVEA.L	LibraryBase,A1	; Position parameter for call
		JSR	_AddDevice(A6)
		MOVEQ	#1,D0		; Indicate that we opened
		MOVEM.L	(SP)+,A2/A6
		RTS

TwilightZone	MOVEQ	#0,D0		; Indicate that we didn't open
		MOVEM.L	(SP)+,A2/A6
		RTS
*
* Here begins the code for the handler process
		CNOP	0,4	; MUST be on longword boundary
		DC.L	16	; Segment length, value doesn't matter
SegList		DC.L	0	; Pointer to next segment (ie none)
*
* Initialize some registers with some handy values
		MOVEA.L	4,A6
		MOVEA.L	LibraryBase,A5
		MOVEA.L	#CtrlAddr,A4
		LEA	42(A4),A2	; Status port-READ ONLY
		LEA	44(A4),A3	; Status port-WRITE ONLY
		LEA	40(A4),A4	; Data port-WRITE ONLY
*
* Offset 38 is the Data port-READ ONLY, but I ran out of regs...
*
* MicroForge SCSI status port bits
*	Read  0 Reads as ONE		Write  0 ACK*
*	      1 MSG*			       1 ???
*	      2 CD*			       2 SEL*
*	      3 IO*			       3 ???
*	      4 REQ*			       4 ???
*	      5 Reads as ONE		       5 ???
*	      6 Reads as ONE		       6 ???
*	      7 Reads as ONE		       7 ???
		MOVEQ	#1,D3		; Used for ACKing
		MOVEQ	#4,D4		; Used checking REQ
		MOVEQ	#0,D5		; Used for ACKing
*
* Configure the SCSI hard disk controller
		JSR	_Forbid(A6)
		BSR	InitController
		JSR	_Permit(A6)
*
* Start waiting for commands on our port
		CLR.W	NeedNotify(A5)
LoopTop		TST.W	NeedNotify(A5)
		BEQ.S	0$
		MOVEA.L	NotifyIRQ(A5),A1
		JSR	_Cause(A6)
		CLR.W	NeedNotify(A5)
0$		LEA	OurPort,A0
		JSR	_WaitPort(A6)
		MOVE.L	D0,CurIOReq(A5)
		LEA	OurPort,A0		; Delink the message
		JSR	_GetMsg(A6)
		TST.L	CurIOReq(A5)
		BEQ	LoopTop
*
* We have a packet, process it
		BCHG	#1,$BFE001		; Dim the LED
		MOVEA.L	CurIOReq(A5),A0
		MOVE.W	24+2(A0),D1		; Get unit #
		LSL.W	#5,D1			; Convert to LUN
		MOVE.B	D1,CurUnit(A5)		; Store for use later
		MOVE.L	44(A0),D0		; Get IO_OFFSET
		MOVEQ	#9,D1
		LSR.L	D1,D0
		MOVE.L	D0,CurBlock(A5)
		MOVE.L	36(A0),D7		; Get IO_LENGTH
		LSR.L	D1,D7
		MOVE.L	40(A0),CurBuffer(A5)	; Move IO_BUFFER
		MOVEQ	#0,D1			; Get IO_COMMAND
		MOVE.B	29(A0),D1
		CMPI.W	#12,D1			; In range?
		BCC.S	CmdDone
		ADD.W	D1,D1
		JMP	DispatchTable(PC,D1.W)

MotorCmd	MOVE.L	D3,32(A0)	;Return motor as ON
		BRA.S	CmdDone

ReturnAOK	MOVE.L	D5,32(A0)
CmdDone		BCHG	#1,$BFE001	; Bring LED back up
		MOVEA.L	CurIOReq(A5),A1	; Send request back
		JSR	_ReplyMsg(A6)
		BRA	LoopTop		; Back to loop top

DispatchTable	BRA	ReturnAOK	;Invalid
		BRA	ReturnAOK	;Reset
		BRA.S	ReadCmd		;Read
		BRA.S	WriteCmd	;Write
		BRA	ReturnAOK	;Update buffers
		BRA	ReturnAOK	;Clear buffers
		BRA	ReturnAOK	;Stop
		BRA	ReturnAOK	;Start
		BRA	ReturnAOK	;Abort
		BRA	MotorCmd	;Motor
		BRA	ReturnAOK	;Seek
*
* Save one BRA by placing this here (Can I shave code or what? :)
FormatCmd	TST.L	CurBlock(A5)
		BNE.S	WriteCmd
		SUBQ.W	#1,D7
		BLT.S	1$
0$		MOVE.B	#4,CurrentCmd	; Format track command
		MOVE.B	#1,CurrentCmd+4
		BSR	SendCmd
		BSR	FinishUp
		BPL.S	WriteCmd
1$		MOVEA.L	CurIOReq(A5),A0
		MOVE.L	36(A0),32(A0)
		BRA	CmdDone

ReadCmd		MOVE.B	#8,CurrentCmd
		MOVE.B	D7,CurrentCmd+4
		BEQ.S	1$
		SUBQ.W	#1,D7
		BSR.S	SendCmd
0$		BSR	ReadData
		DBPL	D7,0$
		BSR	FinishUp
1$		MOVEA.L	CurIOReq(A5),A0
		MOVE.L	36(A0),32(A0)
		BRA	CmdDone

WriteCmd	MOVE.B	#$A,CurrentCmd
		MOVE.B	D7,CurrentCmd+4
		BEQ.S	1$
		SUBQ.W	#1,D7
		BSR.S	SendCmd
0$		BSR.S	WriteData
		DBPL	D7,0$
		BSR	FinishUp
1$		MOVEA.L	CurIOReq(A5),A0
		MOVE.L	36(A0),32(A0)
		BRA	CmdDone

SendCmd		MOVE.L	CurBlock(A5),D0
		MOVE.W	D0,CurrentCmd+2
		SWAP.W	D0
		OR.B	CurUnit(A5),D0
		MOVE.B	D0,CurrentCmd+1
*
* Select SCSI device
		MOVE.B	D3,(A4)
		MOVE.B	D4,(A3)
*
* Wait for BSY
0$		MOVEQ	#%11111,D0
		AND.B	(A2),D0
		BEQ	0$
*
* Clear our out going bits (get off buss)
		MOVE.B	D5,(A4)
		MOVE.B	D5,(A3)
*
* Wait for SEL
1$		BTST	#2,(A2)
		BEQ	1$
		MOVEQ	#6-1,D0
		LEA	CurrentCmd,A0
*
* Wait for REQ
2$		BTST	D4,(A2)
		BEQ	2$
*
* Send command bytes
3$		MOVE.B	(A0)+,(A4)
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		DBF	D0,3$
		MOVE.B	D5,(A4)
		RTS

WriteData	MOVEA.L	CurBuffer(A5),A0
		MOVEQ	#64-1,D0
*
* Wait for REQ
0$		BTST	D4,(A2)
		BEQ	0$
*
* Check C/D if it's clear then AOK, else ERROR.
		BTST	#2,(A2)
		BNE.S	2$
*
* Write data to SCSI buss
* NOTE: Un-winding past 8 doesn't return alot for the extra size.
1$		MOVE.B	(A0)+,(A4)	;1
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		MOVE.B	(A0)+,(A4)	;2
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		MOVE.B	(A0)+,(A4)	;3
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		MOVE.B	(A0)+,(A4)	;4
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		MOVE.B	(A0)+,(A4)	;5
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		MOVE.B	(A0)+,(A4)	;6
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		MOVE.B	(A0)+,(A4)	;7
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		MOVE.B	(A0)+,(A4)	;8
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		DBF	D0,1$
		MOVE.B	D5,(A4)
2$		MOVE.L	A0,CurBuffer(A5)
		TST.W	D0
		RTS

ReadData	MOVEA.L	CurBuffer(A5),A0
		MOVEQ	#64-1,D0
		MOVEA.L	#CtrlAddr+38,A1
*
* Wait for REQ
0$		BTST	D4,(A2)
		BEQ	0$
*
* Check C/D if it's clear then AOK, else ERROR.
		BTST	#2,(A2)
		BNE.S	2$
*
* Read data from SCSI buss
* NOTE: Un-winding past 8 doesn't return alot for the extra size.
1$		MOVE.B	(A1),(A0)+	;1
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		MOVE.B	(A1),(A0)+	;2
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		MOVE.B	(A1),(A0)+	;3
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		MOVE.B	(A1),(A0)+	;4
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		MOVE.B	(A1),(A0)+	;5
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		MOVE.B	(A1),(A0)+	;6
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		MOVE.B	(A1),(A0)+	;7
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		MOVE.B	(A1),(A0)+	;8
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		DBF	D0,1$
2$		MOVE.L	A0,CurBuffer(A5)
		TST.W	D0
		RTS

FinishUp
*
* Wait for C/D
0$		BTST	#3,(A2)
		BEQ	0$

*
* Wait for REQ
1$		BTST	D4,(A2)
		BEQ	1$

*
* Read completion status byte
		MOVE.B	CtrlAddr+38,D0
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
*
* Wait for MSG
2$		BTST.B	D3,(A2)
		BEQ	2$

*
* Wait for REQ
3$		BTST	D4,(A2)
		BEQ	3$

*
* ACK the completion message byte
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)

*
* Did an error occur?
		BTST	D3,D0
		BNE.S	Error
*
* A little delay for when we're good...
		MOVEQ	#$10,D0
9$		DBF	D0,9$
*
* Return normal completion
		MOVEQ	#0,D0
		RTS       
*
* Error occured in command
* Send command #3 to get reason for error
Error		MOVE.B	#3,CurrentCmd
		CLR.B	CurrentCmd+4
		CLR.L	CurBlock(A5)
*
* OMTI needs time to think before we ask for error sense data.
		MOVEQ	#$7F,D0
9$		DBF	D0,9$

		BSR	SendCmd
		MOVEQ	#4-1,D0
		LEA	ErrBuffer,A0
		MOVEA.L	#CtrlAddr+38,A1
*
* Wait for REQ
0$		BTST	D4,(A2)
		BEQ	0$
*
* Check C/D if it's clear then AOK, else ERROR
		BTST	#2,(A2)
		BNE.S	2$
*
* Read data from SCSI buss
1$		MOVE.B	(A1),(A0)+
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		DBF	D0,1$
		MOVE.B	D5,(A4)
		BSR.S	TossStatus
*
* Take the data returned and feed it to the user
		MOVEA.L	CurIOReq(A5),A0
		MOVE.B	ErrBuffer,D0
		MOVE.B	D0,$CF		; "back door" to get I/O result
		MOVE.B	D0,31(A0)	; Return SCSI error code
		MOVEQ	#-1,D0
		RTS
*
* Ooops, we had an error getting the error info.
* BTW, this is most likely because the delay above needs tweaking.
2$		BSR.S	TossStatus
		MOVE.B	#20,31(A0)	; Return some kind of error :)
		MOVEQ	#-1,D0
		RTS

TossStatus
*
* Wait for C/D
0$		BTST	#3,(A2)
		BEQ	0$

*
* Wait for REQ
1$		BTST	D4,(A2)
		BEQ	1$

*
* Read completion status byte
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
*
* Wait for MSG
2$		BTST.B	D3,(A2)
		BEQ	2$

*
* Wait for REQ
3$		BTST	D4,(A2)
		BEQ	3$

*
* ACK the completion message byte
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		RTS

InitController	LEA	InitCmd,A0
		BSR.S	SendICmd
		LEA	InitData,A0
		BSR.S	SendInitData

*
* Wait for OMTI to get with it
		MOVEQ	#$10,D0
0$		DBF	D0,0$

		LEA	InitCmd1,A0
		BSR.S	SendICmd
		LEA	InitData1,A0
		BRA.S	SendInitData

SendICmd	MOVE.B	D3,(A4)
		MOVE.B	D4,(A3)
0$		MOVEQ	#%11111,D0
		AND.B	(A2),D0
		BEQ	0$
		MOVE.B	D5,(A4)
		MOVE.B	D5,(A3)
1$		BTST	#2,(A2)
		BEQ	1$
		MOVEQ	#6-1,D0
2$		BTST	D4,(A2)
		BEQ	2$
3$		MOVE.B	(A0)+,(A4)
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		DBF	D0,3$
		MOVE.B	D5,(A4)
		RTS

SendInitData	MOVEQ	#10-1,D0
0$		BTST	D4,(A2)
		BEQ	0$
1$		MOVE.B	(A0)+,(A4)
		MOVE.B	D3,(A3)
		MOVE.B	D5,(A3)
		DBF	D0,1$
		MOVE.B	D5,(A4)
		BRA	TossStatus

		DATA
*
* NOTE: I use a DATA section so that I can reach some of these variables via
* absolute addressing. I COULD hang them off (A5) but it was just simpler to
* hack them in down here as I needed them...
DeviceName	DC.B	'scottdisk.device',0
		CNOP	0,4
LibraryBase	DC.L	0
OurPort		DC.L	0
		DC.L	0
		DC.B	4
		DC.B	0
		DC.L	DeviceName
		DC.B	0
		DC.B	24
PortTask	DC.L	0	;TaskHandle
LH1		DC.L	LH2
LH2		DC.L	0
		DC.L	LH1
		DC.B	5
		DC.B	0

CurrentCmd	DC.B	0,0,0,0,1,0

ErrBuffer	DC.L	0

InitCmd		DC.B	$C2,0,0,0,0,0
InitCmd1	DC.B	$C2,$20,0,0,0,0
*
* The tables below are sent to the controller to configure it for the drive
* attached to it. Do not change the sector size from 512 bytes!!!!
*
* Some global data about these values for the OMTI 5100 controller:
* Step pulse width:
* 00 thru 05	5us
* 06 thru 08	7.8us
* 09 thru 0B	10.6us
* 0C thru 0E	13.4us
* etc....
*
* Step period:
* Value * 50us with value 0 yielding 9us rather than 0us :).
*
* Number of heads:
* This value must be one less than the number of heads. If the drive has 5
* heads then enter 4.
*
* Number of cylinders:
* This value must be one less than the number of cylinders. If the drive has
* 977 cylinders then enter 976.
*
* Bytes 7 and 8:
* Are used to set the precomp and reduced write current starting points.
* Reduced write is based on the 8 bits in byte 7. If byte 7 equals 0 or 1 then
* reduced write current is disabled. Otherwise it starts at the cylinder
* indicated by the value of byte 7.
* Write precompensation is based on a 10 bit value made up from the 8 bits in
* byte 7 and the lower 2 bits in byte 8. The two bits from byte 8 are tacked
* onto the left of the bits from byte 7 to make the 10 bit value. If this 10
* bit value is 0 then precomp is disabled. If this 10 bit value is 1 then
* precomp is applied to ALL cylinders. Any other value indicates the cylinder
* to start precomp on.
*
* Init data for drive 0
InitData	DC.B	0	; Step pulse width
		DC.B	0	; Step period
		DC.B	0	; Step mode
		DC.B	5	; Number of heads
		DC.W	627	; Number of cylinders
		DC.W	0	; Bytes 7 and 8 (see above)
		DC.B	BlocksPerTrack
		DC.B	0	; Reserved
*
* Init data for drive 1
InitData1	DC.B	0	; Step pulse width
		DC.B	0	; Step period
		DC.B	0	; Step mode
		DC.B	3	; Number of heads
		DC.W	611	; Number of cylinders
		DC.W	0	; Bytes 7 and 8 (see above)
		DC.B	BlocksPerTrack
		DC.B	0	; Reserved
*
* End driver on a long word boundary
		CNOP	0,4
EndOfDriver

		END
