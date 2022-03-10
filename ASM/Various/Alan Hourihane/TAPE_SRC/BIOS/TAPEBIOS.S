*************************************************************************
*									*
*  This is a GENERIC tape driver, for most SCSI compliant Tape Drives.	*
*  Written by Alan Hourihane, current version 1.5 (13/3/91)		*
*									*
*************************************************************************

VERSION 		equ $00010005		* Version 1.5
rvalid			equ $426		* Resvalid
rvector 		equ $42a		* Reset Vector
RMAGIC			equ $31415926		* Reset magic value
PCOOKIE 		equ $5a0		* Cookie Pointer
NOCOOK			equ 20			* Twenty New Cookies.
wdc			equ $ffff8604		* WD Controller
port			equ $fffffa01		* DMA port (FDC/HDC bit 5)
dma			equ $ffff8609		* DMA control register
flock			equ $43e		* Resource Lock flag location
INQUIRE			equ 12			* Inquire function

*************************************************************************
* Start of code. But jump straight away to installation phase.		*
*************************************************************************

start:		bra.w	install 	* Jump to Initialization point.

*************************************************************************
* This section contains the details for the XBRA id installation	*
*************************************************************************

		dc.b	"XBRATAPE"	* The XBRA id 'TAPE'.
oldtrap10:	dc.l	0		* The old TRAP #10 vector is
					* placed here after installation.

*************************************************************************
*  New TRAP #10 Handler, then jump to old TRAP #10 if call not for us.	*
*************************************************************************

newtrap10:	move.w	(sp),d0 	* New TRAP #10 entry point.
		btst	#13,d0		* Test for supervisor mode.
		bne.b	nousp		* 
		move	usp,a0		* Get User Stack Pointer.
		bra.b	dousp		*
nousp:		movea.l sp,a0		* Point to incomming arguments
		addq.l	#6,a0		*
dousp:		cmpi.w	#$ACE,(a0)	* Is this function call for us ?
		beq.b	tape_io 	* Yes go to it.
do_10:		movea.l oldtrap10,a0	* Get old TRAP #10 entry address
systrap10:	jmp	(a0)		* Go to old vector handler
	
*************************************************************************
* If we got here, then we need to perform some sort of TAPE I/O.	*
*************************************************************************

tape_io:				* We're ready for TAPE I/O.

timeout:	move.w	#0,d0		* Timeout for next TAPE call.
					* Changed when install complete.
					* 0 to 65535 maximum.
	
subtime:	tst.w	d0		* Has timeout value been reached.
		beq	continue	* Execute streamer command, if zero.
		sub.w	#1,d0		* Decrease timeout value.
		bra	subtime 	* Subtract again.
		
continue:	move.l	$8(a0),nblock	* Get and save number of blocks.
		move.l	$4(a0),bufadr	* Get and save buffer address.
		move.w	$2(a0),d0	* Get and save read/write flag.
		tst.w	d0		* < 0 (i.e. is it a valid function) 
		bmi.s	error		* Not valid, return error.
		cmp.w	#12,d0		* > 12 (i.e. is it a valid function)
		bgt.s	error		* Not valid, return error.
		lsl.w	#2,d0		* Convert to long table offsets.
		lea	jmptbl,a0	* Get jump table base.
		move.l	0(a0,d0.w),a0	* Get function address from table.
		jmp	(a0)		* Perform function as requested.

error:		rte			* Return with error function.

jmptbl: 	dc.l	t_ready 	* Test Unit Ready.
		dc.l	t_read		* Read tape.
		dc.l	t_write 	* Write tape.
		dc.l	t_rewind	* Rewind tape.
		dc.l	t_load		* Load tape.
		dc.l	t_unload	* Unload tape.
		dc.l	t_filmk 	* Write File marks.
		dc.l	t_rsense	* Request Sense.
		dc.l	t_mselect	* Mode Select.
		dc.l	t_msense	* Mode Sense.
		dc.l	t_space 	* Space command.
		dc.l	t_erase 	* Erase tape.
		dc.l	t_inquire	* Inquiry.

*************************************************************************
*									*
* The following functions are the jump table commands to perform the	*
* specific functions required on the tape drive. The code sets up the	*
* necessary data packets that need to be sent across the DMA bus.	*
*									*
*************************************************************************

*************************************************************************      
* Perform a TEST UNIT READY command.					*
*************************************************************************

t_ready:	movem.l a1/d1,-(sp)	* Save A1 and D1 registers.
		lea	cdb,a0		* Pop command block into A0.
		move.b	#0,(a0)+	* 'SCSI command for READY' 
		clr.b	(a0)+		* Command block, must be zero.
		clr.b	(a0)+		* ....
		clr.b	(a0)+		* ...
		clr.b	(a0)+		* ..
		clr.b	(a0)		* Flag = 0, Link = 0.
		move.w	#1,dmacnt	* DMA count.
		move.l	#lbuf,bufadr	* Get local scratch buffer address.
		bsr	dout		* Branch to DATA OUT phase code.
		movem.l (sp)+,a1/d1	* Restore A1 and D1 registers.
		rte			* Return from TRAP #10.
		
*************************************************************************
* Perform a READ command.						*
*************************************************************************

t_read: 	movem.l a1/d1,-(sp)	* Save A1 and D1 registers.
		lea	cdb,a0		* Pop command block into A0.
		move.b	#8,(a0)+	* 'SCSI command for READ'
		move.b	#1,(a0)+	* Fixed = 1.
		move.b	nblock+1,(a0)+	* Transfer Length (MSB)
		move.b	nblock+2,(a0)+	* Transfer Length
		move.b	nblock+3,(a0)+	* Transfer Length (LSB)
		clr.b	(a0)		* Flag = 0, Link = 0.
		move.w	nblock+2,d0	* Get 16 bit block read count.
		move.w	d0,dmacnt	* Value for dma block transfer.
		bsr	din		* Branch to DATA IN phase code.
		movem.l (sp)+,a1/d1	* Restore A1 and D1 registers.
		rte			* Return from TRAP #10.
		
*************************************************************************
* Perform a WRITE command.						*
*************************************************************************
       
t_write:	movem.l a1/d1,-(sp)	* Save A1 and D1 registers.
		lea	cdb,a0		* Pop command block into A0.
		move.b	#$A,(a0)+	* 'SCSI command for WRITE'
		move.b	#1,(a0)+	* Fixed = 1.
		move.b	nblock+1,(a0)+	* Transfer Length (MSB)
		move.b	nblock+2,(a0)+	* Transfer Length
		move.b	nblock+3,(a0)+	* Transfer Length (LSB)
		clr.b	(a0)		* Flag = 0, Link = 0.
		move.w	nblock+2,d0	* Get 16 bit block write count.
		move.w	d0,dmacnt	* Value for dma block transfer.
		bsr	dout		* Branch to DATA OUT phase code.
		movem.l (sp)+,a1/d1	* Restore A1 and D1 registers.
		rte			* Return from TRAP #10.
	
*************************************************************************
* Perform a REWIND command.						*
*************************************************************************

t_rewind:	movem.l a1/d1,-(sp)	* Save A1 and D1 registers.
		lea	cdb,a0		* Pop command block into A0.
		move.b	#1,(a0)+	* 'SCSI command for REWIND'
		clr.b	(a0)+		* Immed = 0.
		clr.b	(a0)+		* Command block, must be zero.
		clr.b	(a0)+		* ...
		clr.b	(a0)+		* ..
		clr.b	(a0)		* Flag = 0, Link = 0.
		move.w	#1,dmacnt	* DMA count.
		move.l	#lbuf,bufadr	* Get local scratch buffer address.
		bsr	dout		* Branch to DATA OUT phase code.
		movem.l (sp)+,a1/d1	* Restore A1 and D1 registers.
		rte			* Return from TRAP #10.
	
*************************************************************************
* Perform an LOAD command.						*
*************************************************************************
       
t_load: 	movem.l a1/d1,-(sp)	* Save A1 and D1 registers.
		lea	cdb,a0		* Pop command block into A0.
		move.b	#$1b,(a0)+	* 'SCSI command for LOAD'
		clr.b	(a0)+		* Immed = 0.
		clr.b	(a0)+		* Command block, must be zero.
		clr.b	(a0)+		* ..
		move.b	nblock+3,d0	* Re-Ten, 0 or 2 for retension.
		lsl.b	#1,d0		* ...
		and.b	#2,d0		* ..
		or.b	#1,d0		* Load = 1.
		move.b	d0,(a0)+	* ..
		clr.b	(a0)		* Flag = 0, Link = 0.
		move.w	#1,dmacnt	* DMA count.
		move.l	#lbuf,bufadr	* Get local scratch buffer address.
		bsr	dout		* Branch to DATA OUT phase code.
		movem.l (sp)+,a1/d1	* Restore A1 and D1 registers.
		rte			* Return from TRAP #10.

*************************************************************************
* Perform a MODE SELECT command.					*
*************************************************************************

t_mselect:	movem.l a1/d1,-(sp)	* Save A1 and D1 registers.
		lea	cdb,a0		* Pop command block into A0.
		move.b	#$15,(a0)+	* 'SCSI command for MODE SELECT'
		clr.b	(a0)+		* Command block, must be zero.
		clr.b	(a0)+		* ...
		clr.b	(a0)+		* ..
		move.b	nblock+3,(a0)+	* Parameter List Length.
		clr.b	(a0)		* Flag = 0, Link = 0.
		move.w	#1,dmacnt	* DMA count.
		bsr	dout		* Branch to DATA OUT phase code.
		movem.l (sp)+,a1/d1	* Restore A1 and D1 registers.
		rte			* Return from TRAP #10.
		
*************************************************************************
* Perform a MODE SENSE command. 					*
*************************************************************************

t_msense:	movem.l a1/d1,-(sp)	* Save A1 and D1 registers.
		lea	cdb,a0		* Pop command block into A0.
		move.b	#$1A,(a0)+	* 'SCSI command for MODE SENSE'
		clr.b	(a0)+		* Command block, must be zero.
		clr.b	(a0)+		* ...
		clr.b	(a0)+		* ..
		move.b	nblock+3,(a0)+	* Parameter List Length.
		clr.b	(a0)		* Flag = 0, Link = 0.
		move.w	#1,dmacnt	* DMA count.
		bsr	din		* Branch to DATA IN phase code.
		movem.l (sp)+,a1/d1	* Restore A1 and D1 registers.
		rte			* Return from TRAP #10.

*************************************************************************
* Perform an UNLOAD command.						*
*************************************************************************
       
t_unload:	movem.l a1/d1,-(sp)	* Save A1 and D1 registers.
		lea	cdb,a0		* Pop command block into A0.
		move.b	#$1b,(a0)+	* 'SCSI command for UNLOAD'
		clr.b	(a0)+		* Immed = 0.
		clr.b	(a0)+		* Command block, must be zero.
		clr.b	(a0)+		* ..
		move.b	nblock+3,d0	* Re-Ten, 0 or 2 for retension.
		lsl.b	#1,d0		* ...
		and.b	#2,d0		* Load = 0.
		move.b	d0,(a0)+	* ..
		clr.b	(a0)		* Flag = 0, Link = 0.
		move.w	#1,dmacnt	* DMA count.
		move.l	#lbuf,bufadr	* Get local scratch buffer address.
		bsr	dout		* Branch to DATA OUT phase code.
		movem.l (sp)+,a1/d1	* Restore A1 and D1 registers.
		rte			* Return from TRAP #10.
		
*************************************************************************
* Perform a WRITE FILEMARKS command.					*
*************************************************************************

t_filmk:	movem.l a1/d1,-(sp)	* Save A1 and D1 registers.
		lea	cdb,a0		* Pop command block into A0.
		move.b	#$10,(a0)+	* 'SCSI command for WRITE FILEMARK'
		clr.b	(a0)+		* Command block, must be zero.
		move.b	nblock+1,(a0)+	* Number of Filemarks (MSB)
		move.b	nblock+2,(a0)+	* Number of Filemarks
		move.b	nblock+3,(a0)+	* Number of Filemarks (LSB)
		clr.b	(a0)		* Str = 0, Flag = 0, Link = 0.
		move.w	#1,dmacnt	* DMA count.
		move.l	#lbuf,bufadr	* Get local scratch buffer address.
		bsr	dout		* Branch to DATA OUT phase code.
		movem.l (sp)+,a1/d1	* Restore A1 and D1 registers.
		rte			* Return from TRAP #10.
		
*************************************************************************
* Perform a REQUEST SENSE command.					*
*************************************************************************

t_rsense:	movem.l a1/d1,-(sp)	* Save A1 and D1 registers.
		lea	cdb,a0		* Pop command block into A0.
		move.b	#3,(a0)+	* 'SCSI command for REQUEST SENSE'
		clr.b	(a0)+		* Command block, must be zero.
		clr.b	(a0)+		* ...
		clr.b	(a0)+		* ..
		move.b	nblock+3,(a0)+	* Allocation Length.
		clr.b	(a0)		* Flag = 0, Link = 0.
		move.w	#1,dmacnt	* DMA count.
		bsr	din		* Branch to DATA IN phase code.
		movem.l (sp)+,a1/d1	* Restore A1 and D1 registers.
		rte			* Return from TRAP #10.

*************************************************************************
* Perform a SPACE command.						*
*************************************************************************
       
t_space:	movem.l a1/d1,-(sp)	* Save A1 and D1 registers.
		lea	cdb,a0		* Pop command block into A0.
		move.b	#$11,(a0)+	* 'SCSI command for SPACE'
		move.b	nblock,(a0)+	* Code bits (bits 0 and 1).
		move.b	nblock+1,(a0)+	* Count (MSB).
		move.b	nblock+2,(a0)+	* Count.
		move.b	nblock+3,(a0)+	* Count (LSB).
		clr.b	(a0)		* Flag = 0, Link = 0.
		move.w	#1,dmacnt	* DMA count.
		move.l	#lbuf,bufadr	* Get local scratch buffer address.
		bsr	dout		* Branch to DATA OUT phase code.
		movem.l (sp)+,a1/d1	* Restore A1 and D1 registers.
		rte			* Return from TRAP #10.

*************************************************************************
* Perform an ERASE command.						*
*************************************************************************
       
t_erase:	movem.l a1/d1,-(sp)	* Save A1 and D1 registers.
		lea	cdb,a0		* Pop command block into A0.
		move.b	#$19,(a0)+	* 'SCSI command for ERASE'
		move.b	#1,(a0)+	* Long = 1.
		clr.b	(a0)+		* Command block, must be zero.
		clr.b	(a0)+		* ...
		clr.b	(a0)+		* ..
		clr.b	(a0)		* Flag = 0, Link = 0.
		move.w	#1,dmacnt	* DMA count.
		move.l	#lbuf,bufadr	* Get local scratch buffer address.
		bsr	dout		* Branch to DATA OUT phase code.
		movem.l (sp)+,a1/d1	* Restore A1 and D1 registers.
		rte			* Return from TRAP #10.

*************************************************************************
* Perform an INQUIRY command.						*
*************************************************************************

t_inquire:	movem.l a1/d1,-(sp)	* Save A1 and D1 registers.
		lea	cdb,a0		* Pop command block into A0.
		move.b	#$12,(a0)+	* 'SCSI command for INQUIRY'
		clr.b	(a0)+		* Command block, must be zero.
		clr.b	(a0)+		* ...
		clr.b	(a0)+		* ..
		move.b	nblock+3,(a0)+	* Allocation Length.
		clr.b	(a0)		* Flag = 0, Link = 0.
		move.w	#1,dmacnt	* DMA count.
		bsr	din		* Branch to DATA IN phase code.
		movem.l (sp)+,a1/d1	* Restore A1 and D1 registers.
		rte			* Return from TRAP #10.

*************************************************************************
* End of the jump table offset code.					*
* Next, follows the code to send the data to and from the tape device.	*
*************************************************************************

*************************************************************************
* Issue command and RECEIVE data from SCSI device			*
*************************************************************************

din:		move.l	#wdc,a0 	* Load WD Controller address to A0.
		bsr.w	sendcdb 	* Setup DMA and send DCB to controller.
		bmi.w	tout		* controller/DMA time-out
		move.w	#$190,2(a0)	*
		nop			*
		nop			*
		move.w	#$90,2(a0)	*
		nop			*
		nop			*
		move.w	dmacnt,(a0)	*
		clr.l	d1		*
		move.w	#$8A,2(a0)	*
		move.b	(a1),d1 	* Get last byte of CDB
		swap	d1		*
		move.l	d1,(a0) 	* last byte of CDB (initiate)
		move.w	#$8A,d1 	*
		bra.b	exec		*
		
*************************************************************************
* Issue command and SEND data to SCSI device.				*
*************************************************************************

dout:		move.l	#wdc,a0 	*
		bsr.w	sendcdb 	* setup DMA and send DCB to controller
		move.w	#$90,2(a0)	*
		nop			*
		nop			*
		move.w	#$190,2(a0)	*
		nop			*
		nop			*
		move.w	dmacnt,(a0)	* DMA block count setup
		clr.l	d1		*
		move.w	#$18A,2(a0)	*
		move.b	(a1),d1 	* Get last byte of CDB
		swap	d1		*
		move.w	#$100,d1	*
		move.l	d1,(a0) 	* last byte of CDB (initiate)
		move.w	#$18A,d1	*

exec:		bsr.w	wait		* go wait for complete intr.
		bmi.b	tout		* loop timed out --->
		move.w	d1,2(a0)	*
		nop			*
		move.w	(a0),d0 	* get HDC/DMA status in d0
		and.w	#$FF,d0 	* Strip all but HDC bits
		bra.s	ndto		*

tout:		move.w	#-2,d0		* Device time-out

ndto:		move.w	#$80,2(a0)	*
		nop			*
		tst.w	(a0)		*
		clr.w	flock		* clear Floppy VBI
		rts			*

*************************************************************************
* Set parameters (Set DMA, and send first 5 bytes of DCB).		*
*************************************************************************

sendcdb:	st	flock		* Set flock
		move.b	bufadr+3,dma+4	* Set DMA buffer address LOW
		move.b	bufadr+2,dma+2	* Set DMA buffer address MED
		move.b	bufadr+1,dma	* Set DMA buffer address HIGH
		move.w	#$88,2(a0)	* Set HDC access, (Device Select ?)

		lea	cdb,a1		* Get Base address of CDB
		clr.l	d0		*
		move.b	acsi,d0 	* Place DEVICE ID in upper 3 bits of cmd
		and.b	#$e0,d0 	* make sure only top 3 bits
		or.b	(a1)+,d0	* and put 1st byte of CDB in also
		swap	d0		*
		move.w	#$8A,d0 	* put in ST's needed direction and addr
		move.l	d0,(a0) 	* DCB byte #0 (Command + Device Number)

		move.w	#3,d1		* all but last byte but last byte of CDB
		move.w	#$8A,2(a0)	* Issue first byte (not included in CDBSIZ)
		bsr	swait		*
		bmi	parmo		*

scdbl:		clr.l	d0		* Now send all but last byte ....
		move.b	(a1)+,d0	* Get Next Byte
		swap	d0		*
		move.w	#$8A,d0 	*
		move.l	d0,(a0) 	* Send Next DCB byte
		bsr.w	swait		* wait for intr
		bmi.b	parmo		* Timeout exit
		dbf	d1,scdbl	* 
parmo:		rts			* Return to caller.

*************************************************************************
* Wait for Command Complete						*
*************************************************************************

wait:		move.l	#$4000000,d0	* Init long wait (approx 2 mins)
		bra.b	waitl		* Goto wait loop
swait:		move.l	#$100000,d0	* Init short wait (approx 20 secs)
waitl:		subq.l	#1,d0		* Wait loop - decrement time-out counter
		bmi.b	waito		* Rollover means time-out!
		btst	#$5,port	* Interrupt yet, HDC/FDC (bit 5).
		bne.b	waitl		* Not yet , keep waiting till intr or time-out
		clr.l	d0		* Clear CPU's N flag = interrupt received.
waito:		rts			* Return to caller.

*************************************************************************
* UNJAR code, for those versions of TOS that don't clear COOKIE JAR's	*
*************************************************************************

		dc.b	"XBRAUJAR"	* XBRA id for UJAR - Unjar Code.
vecsave:	ds.l	1		* Space for vector save.
rhand:		clr.l	PCOOKIE 	* Clear pointer to cookie jar.
		move.l	vecsave,rvector * Move vecsave to Reset vector.
		move.l	valsave,rvalid	* Move valsave to Reset value.
		jmp	(a6)		* Jump to reset routine.
valsave:	ds.l	1		* Space for value save.
		
*************************************************************************
* Space for necessary DATA, during TRAP #10 call.			*
*************************************************************************

nblock: dc.l	0			* 
bufadr: dc.l	0			* Buffer Address.
dmacnt: dc.w	0			* DMA count.
acsi:	dc.w	0			* ACSI address of Tape Streamer.
cdb:	ds.b	6			* 
lbuf:	ds.b	512			* Local 512 byte DMA buffer.

*************************************************************************
* End of Resident trap code. After install, approximately 2KB.		*
*************************************************************************

*************************************************************************
* Installation Code.							*
*************************************************************************

install:	move.l	a7,a5		* Store stack to determine basepage.
		move.l	4(a5),a5	* BasePage is now in A5.
		move.l	12(a5),d0	* Text segment length stands in A0.
		add.l	20(a5),d0	* Add to that the length of the data,
		add.l	28(a5),d0	* And the BSS segments,
		add.l	#$500,d0	* And the amount needed for stack.
		move.l	d0,d1		*
		add.l	a5,d1		* Length + address of basepage.
		and.l	#-2,d1		* Be sure stack starts on even address.
		move.l	d1,a7		* Now put stack where we want it.
		move.l	d0,-(sp)	* Size of reserved area.
		move.l	a5,-(sp)	* Start of reserved area.
		clr.w	-(sp)		* Dummy.
		move.w	#$4A,-(sp)	* Setblock function call.
		trap	#1		* Call TRAP #1, to activate.
		add.l	#12,-(sp)	* Tidy stack.
		clr.l	-(sp)		* User stack becomes supervisor stack.
		move.w	#$20,-(sp)	* Supervisor mode.
		trap	#$1		* Call TRAP #1, to activate.
		addq.l	#6,sp		* Tidy stack.
		move.l	d0,stkp 	* Save old stack pointer to stkp.
		move.l	(PCOOKIE),a6	* Find COOKIE JAR pointer.
		move.l	a6,d0		* Move pointer to data register.
		tst.l	d0		* Test, Is there a cookie jar ?
		beq	createjar	* No, so create one, then continue.
doinst: 	clr.l	d6		* Clear cookie counter.
isit:		move.l	(a6)+,d7	* Get a cookie name.
		add.l	#4,a6		* Skip value, Go to next cookie.
		add.l	#1,d6		* Add one to cookie counter.
		cmp.l	#'TAPE',d7	* Test, Is TapeBIOS already installed.
		beq	already 	* Yes, Tell user and abort.
		tst.l	d7		* Test, Have we hit the zero cookie.
		bne isit		* No, Go again.
		sub.l	#4,a6		* Go back to name pointer.
		move.l	(a6),d7 	* Get number of cookies in jar.
		cmp.l	d7,d6		* Test, Is cookie jar full.
		beq copyjar		* Yes, Install new jar.
		
jardone:	move.w	#0,-(sp)	* Open TAPEBIOS.INF for read
		pea	tapeinf 	* Push name onto stack.
		move.w	#$3d,-(sp)	* Function call for open.
		trap	#1		* Call TRAP #1, to open.
		addq.l	#8,sp		* Tidy stack.
		tst.l	d0		* Test, Any problems opening file.
		bmi	tinfopen	* Yes, tell user and abort.
		move	d0,fhandle	* Save file handle.
		pea	tapebuf 	* Push buffer address onto stack.
		move.l	#7,-(sp)	* Get 7 bytes from TAPEBIOS.INF
		move.w	fhandle,-(sp)	* Push file handle onto stack.
		move.w	#$3f,-(sp)	* Function call for read.
		trap	#1		* Call TRAP #1, to read.
		add.l	#12,-(sp)	* Tidy stack.
		cmp.l	#7,d0		* Did we get the 7 bytes.
		bne	tapeinferr	* No, so tell user and abort.
		move.w	fhandle,-(sp)	* Push file handle onto stack.
		move.w	#$3e,-(sp)	* Function call for close.
		trap	#1		* Call TRAP #1, to close.
		addq.l	#4,sp		* Tidy stack.
		tst.l	d0		* Did we close TAPEBIOS.INF OK.
		bmi	tinfclose	* No, tell user and abort.
	
		move.b	tapebuf,d0	* Get the SCSI ID number of device.
		sub.b	#'0',d0 	* Change from ASCII to binary value.
		bmi	ivdid		* < 0 (i.e. invalid ID)
		cmp.b	#7,d0		* Compare with ID with 7.
		bhi	ivdid		* > 7 (i.e. invalid ID)
		lsl.b	#5,d0		* Move bits to proper location.
		move.b	d0,acsi 	* And save for driver calls later.
		clr.l	d1		* Clear D1 register.
		clr.l	d0		* Clear D0 register.
		move.b	tapebuf+2,d0	* Get first digit.
		sub.b	#'0',d0 	* Change from ASCII to binary value.
		mulu	#10000,d0	* Multiply by 10000.
		move.b	tapebuf+3,d1	* Get second digit.
		sub.b	#'0',d1 	* Change from ASCII to binary value.
		mulu	#1000,d1	* Multiply by 1000.
		add.l	d1,d0		* Add d1 to d0.
		clr.l	d1		* Clear D1 register.
		move.b	tapebuf+4,d1	* Get third digit.
		sub.b	#'0',d1 	* Change from ASCII to binary value.
		mulu	#100,d1 	* Multiply by 100.
		add.l	d1,d0		* Add d1 to d0.
		clr.l	d1		* Clear D1 register.
		move.b	tapebuf+5,d1	* Get fourth digit.
		sub.b	#'0',d1 	* Change from ASCII to binary value.
		mulu	#10,d1		* Multiply by 10.
		add.l	d1,d0		* Add d1 to d0.
		clr.l	d1		* Clear D1 register.
		move.b	tapebuf+6,d1	* Get fifth digit.
		sub.b	#'0',d1 	* Change from ASCII to binary value.
		add.l	d1,d0		* Add d1 to d0.
		move.w	d0,timeout+2	* Pop new timeout value into loop.
		move.l	$a8,oldtrap10	* Save old TRAP #10 vector.
		move.l	#newtrap10,$a8	* Install our new TapeBIOS vector.
	
		move.l	#64,-(sp)	* Get 64 bytes of Inquiry Data.
		move.l	#ibuffer,-(sp)	* Pop data buffer onto stack.
		move.w	#INQUIRE,-(sp)	* Choose INQUIRE command.
		move.w	#$ACE,-(sp)	* TapeBIOS function call.
		trap	#10		* Call TRAP #10, to activate.
		add.l	#12,sp		* Tidy stack.
		tst.w	d0		* Did inquire fail.
		bne	failinq 	* Yes, tell user and abort.
	
		cmp.b	#1,(ibuffer)	* Is the SCSI ID chosen a sequential device.
		bne	notsequent	* Apparently Not, Abort install.
		
		move.l	(PCOOKIE),a6	* Get COOKIE JAR pointer.
anothcook:	move.l	(a6)+,d7	* Get cookie name.
		move.l	(a6)+,d6	* Get cookie value.
		tst.l	d7		* Have we hit the zero cookie.
		bne	anothcook	* No, so get another cookie.
		sub.l	#8,a6		* Go back to current cookie.
		move.l	#'TAPE',(a6)+	* Install TAPE cookie.
		move.l	#VERSION,(a6)+	* Install version number.
		move.l	#0,(a6)+	* Put zero cookie back.
		move.l	d6,(a6) 	* Put number of cookies back.
		move.b tapebuf,greet+41 * Pop SCSI ID into greeting message.
		move.l	#greet,-(sp)	* Pop Greeting message onto stack.
		move.w	#9,-(sp)	* Use print line function.
		trap	#1		* Call TRAP #1, to print it.
		addq.l	#6,sp		* Tidy stack.
		move.w	#23,d6		* 24 bytes of device name.
		move.l	#ibuffer,a5	* Move inquiry buffer to A5.
		add.l	#8,a5		* Jump to device name.
devicename:	clr.w	d7		* Clear D7 register.
		move.b	(a5)+,d7	* Move character to D7.
		move.w	d7,-(sp)	* Pop D7 into stack.
		move.w	#2,-(sp)	* Use Conout function.
		trap	#1		* Call TRAP #1, to print character.
		addq.l	#4,sp		* Tidy stack.
		dbra d6,devicename	* Print out Full Device Name.
		move.l	#greet2,-(sp)	* Print a CR,LF.
		move.w	#9,-(sp)	* Use print line function.
		trap	#1		* Call TRAP #1, to print it.
		addq.l	#6,sp		* Tidy stack.
	
		move.l	stkp,-(sp)	* Move User stack pointer to stack.
		move.w	#$20,-(sp)	* User Mode.
		trap	#1		* Call TRAP #1, to activate.
		addq.l	#6,sp		* Tidy stack.
		clr.w	-(sp)		* Terminate with zero status
		move.l	#install,d0	* Calculate driver code size.
		sub.l	#start,d0	* ..
		move.l	d0,-(sp)	* Keep TapeBIOS memory resident.
		move.w	#$31,-(sp)	* Ptermres call
		trap	#1		* Call TRAP #1, to terminate.
		
*************************************************************************
* End of main installation code.					*
* Next, are some routines called by the installation procedure. 	*							*
*************************************************************************

malloc: 	move.l	(mem),d4	* No of Cookies.
		mulu	#8,d4		* Multiply by 8.
		move.l	d4,-(sp)	* No of bytes to reserve.
		move.w	#$48,-(sp)	* Malloc function call.
		trap	#1		* Call TRAP #1, to activate.
		addq.l	#6,sp		* Tidy stack.
		tst.l	d0		* Error or address of memory ?
		bmi	mallerr 	* Malloc Error, abort install.
		rts			* Return to caller.	   

createjar:	move.l	rvalid,valsave	* Save reset value.
		move.l	rvector,vecsave * Save reset vector.
		move.l	#rhand,rvector	* Install new Reset Vector.
		move.l	#RMAGIC,rvalid	* Pop new ResetMAGIC value in.
		move.l	#NOCOOK,mem	* Space to reserve for New jar.
		bsr	malloc		* Malloc that memory.
		move.l	d0,PCOOKIE	* Install New Cookie Jar.
		move.l	d0,a5		* Move data reg to address reg.
		move.l	#0,(a5)+	* Install zero cookie.
		move.l	#NOCOOK,(a5)	* Install Number of New cookies.
		bra	doinst		* Ok, continue install.
	
copyjar:	move.l	rvalid,valsave	* Save reset value
		move.l	rvector,vecsave * Save reset vector value
		move.l	#rhand,rvector	* Install new resvector
		move.l	#RMAGIC,rvalid	* Pop new resmagic value in.
		add.l	#NOCOOK,d7	* Increase jar.
		move.l	d7,mem		* Space to reserve for New jar.
		bsr	malloc		* Malloc that memory.
		move.l	(PCOOKIE),a6	* Get Cookie Jar pointer.
		move.l	d0,a5		* Move data reg to address reg.
		
copymore:	tst.l	(a6)		* Is this the zero cookie.
		beq	endcopy 	* Yes, so end copy.
		move.l	(a6)+,(a5)+	* Copy cookie name.
		move.l	(a6)+,(a5)+	* Copy cookie value.
		bra	copymore	* Copy again ?
		
endcopy:	move.l	#0,(a5)+	* Install the zero cookie.
		move.l	(mem),(a5)	* Install Number of New cookies.
		move.l	d0,PCOOKIE	* Install new pointer to jar.
		bra	jardone 	* Continue Install Procedure.

failinq:	move.l	#finq,-(sp)	* Fail inquiry message.
		move.l	(oldtrap10),$a8 * Put old TRAP #10 vector back.
		bra.s	pae		* Go and print message.
	
notsequent:	move.l	#nseq,-(sp)	* Not sequential device message.
		move.l	(oldtrap10),$a8 * Put old TRAP #10 vector back.
		bra.s	pae		* Go and print message.

tinfopen:	move.w	fhandle,-(sp)	* Push file handle onto stack.
		move.w	#$3e,-(sp)	* Close file.
		trap	#1		* Call TRAP #1, to activate.
		addq.l	#4,sp		* Tidy stack.
		move.l	#eof,-(sp)	* Error opening file message.
		bra.s	pae		* Go and print message.
		
tapeinferr:	move.w	fhandle,-(sp)	* Push file handle onto stack.
		move.w	#$3e,-(sp)	* Close file.
		trap	#1		* Call TRAP #1, to activate.
		addq.l	#4,sp		* Tidy stack.
		move.l	#erf,-(sp)	* Error reading file message.
		bra.s	pae		* Go and print message.
		 
tinfclose:	move.l	#ecf,-(sp)	* Error closing file message.
		bra.s	pae		* Go and print message.
		
ivdid:		move.l	#ividm,-(sp)	* Invalid device ID message.
		bra.s	pae		* Go and print message.
		
mallerr:	move.l	#merr,-(sp)	* Malloc Memory error message.
		bra.s	pae		* Go and print message.
		
already:	move.l	#ari,-(sp)	* Already installed message.

pae:		move.w	#9,-(sp)	* Print line function call.
		trap	#1		* Call TRAP #1, to activate.
		addq.l	#6,sp		* Tidy stack.
		move.l	stkp,-(sp)	* Pop User stack pointer onto stack.
		move.w	#$20,-(sp)	* Call User mode.
		trap	#$1		* Call TRAP #1, to activate.
		addq.l	#6,sp		* Tidy stack.
		clr.w	-(sp)		* Use terminate function call.
		trap	#1		* Call TRAP #1, to quit.

*************************************************************************
* DATA segment. 							*
*************************************************************************

greet:		dc.b	'TapeBIOS Driver Ver 1.5 Installed for ID#X, Copyright 1991,1992 A. Hourihane.',13,10,'Tape Device Online is the ',0
greet2: 	dc.b	13,10,0
merr:		dc.b	'*** Memory allocation failure, Installation ABORTED ***',13,10,0 
nseq:		dc.b	'*** SCSI ID specified is not a tape drive, Installation ABORTED ***',13,10,0
ari:		dc.b	'*** Tape Driver is already resident, Installation ABORTED ***',13,10,0
ecf:		dc.b	'*** Error closing TAPEBIOS.INF, Installation ABORTED ***',13,10,0
erf:		dc.b	'*** Error reading TAPEBIOS.INF, Installation ABORTED ***',13,10,0	
ividm:		dc.b	'*** Invalid Device ID, Installation ABORTED ***',13,10,0
eof:		dc.b	'*** Error opening TAPEBIOS.INF, Installation ABORTED ***',13,10,0
finq:		dc.b	'*** Failed Inquiry on SCSI ID specified, Installation ABORTED ***',13,10,0

ibuffer:	ds.l	64		* Inquiry Buffer.
stkp:		ds.l	1		* Store for old stack pointer.
tapebuf:	ds.w	5		* Store for TAPEBIOS.INF file data.
fhandle:	ds.w	1		* Store for file handle.	
mem:		ds.l	1		* Store for malloc reserve.

tapeinf:	dc.b	'TAPEBIOS.INF', 0

		end
