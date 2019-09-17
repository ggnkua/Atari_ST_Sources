*****************
* MACRO LIBRARY *
*  by S.H.Rigby *
*  Version 1.02 *
*    26/06/93   *
*****************
	INCLUDE	equates.i
	INCLUDE	errors.i
	INCLUDE	bios.i
	INCLUDE	xbios.i
	INCLUDE	gemdos.i
	INCLUDE	traps.i
	INCLUDE intmath.i
	INCLUDE line_a.i
	
* CHARACTER DEVICE I/O ROUTINES
*******************************
* PRT,AUX,CON,MIDI,KBD,RAW are valid devices 0-5
* Valid operations:
* Operation	PRT AUX CON MIDI KBD RAW
* --------------------------------------
* Bconstat	no  yes yes yes  no  no
* Bconin	yes yes yes yes  no  no
* Bconout	yes yes yes yes  yes yes
* Bcostat	yes yes yes yes  yes no
* Midi has I/O buffer of $80 (128) bytes only!
* Keyboard I/O buffer is $80 (128) bytes
* RS-232 I/O buffer is 256 bytes
* KBD is output only for configuring keyboard
* RAW outputs all characters to screen with no interpretation
*
* Note: PARALLEL interrupt available at $100 - see traps.i
*       RS232 Carrier Detect, Clear to Send, TX Error, RX Error, Ring,
*             TX Next char and RX Next char Interrupts are available
*       KBD/MIDI combined interrupt available     
* see traps.i for more info
* see conterm for keyboard functions in equates.i
* see xconstat, xconin, xcostat, xconout vectors in OS variables in equates.i

* Read character from device
*	see equates.i for devices
*	waits for input
*	only devices 1-3 valid
*	CON returns IBM compatible scancode in low byte of high word
*	if bit 3 of Conterm is set, returns shift status in high byte
*	of high word. default state is off.
*	All other devices only return the character value
Bconin	MACRO	device
	TEXT
	move.w	\1,-(sp)
	move.w	#bconin,-(sp)
	trap	#BIOS
	addq.w	#4,sp
	ENDM	d0.l=[$00/Shift_code][Scan_code][$00][Char]

* Write character to device
*	see equates.i for devices
*	Devices 0-4 to send to
*	waits for completion of output before return
*	PRT returns 0 for fail and !0 for success
*	letter is low byte of word
Bconout	MACRO	device.w,letter.b
	TEXT
	clr.w	-(sp)
	move.b	\2,1(sp)
	move.w	\1,-(sp)
	move.w	#bconout,-(sp)
	trap	#BIOS
	addq.w	#6,sp
	ENDM

* Device ready to read	(true/false)
*	use CON,AUX or MIDI (1,2 or 3)
*	see equates.i for devices
*	MIDI has interrupt driven input buffer of 80 chars
Bconstat	MACRO	device
		TEXT
		move.w	\1,-(sp)
		move.w	#bconstat,-(sp)
		trap	#BIOS
		addq.w	#4,sp
		ENDM	d0.l=0 or -1 (no char ready/char ready)

* Device ready to write	(true/false)
*	BUG: 3 is KBD, 4 is MIDI - compensated for in code
Bcostat	MACRO	device
	TEXT
	cmp.w	#3,\1
	bne	.a\@
	addq.w	#1,\1	;MIDI has to be 4
	bra	.b\@
.a\@	cmp.w	#4,\1
	bne	.b\@
	subq.w	#1,\1	;KBD has to be 3
.b\@	move.w	\1,-(sp)
	move.w	#bcostat,-(sp)
	trap	#BIOS
	addq.w	#4,sp
	ENDM	d0.l=0 or -1 (not ready/ready to rcve char)

* Reset Keyboard Translation Tables to Power up defaults
*		see Keytbl for setting tables
Bioskeys	MACRO
		TEXT
		move.w	#bioskeys,-(sp)
		trap	#XBIOS
		addq.w	#2,sp
		ENDM	

* Read character from serial port (handle 1) - wait if not ready
*	NO FLOW CONTROL ON THIS - USE BCONIN WITH BCONSTAT!
*	else maybe lose received characters
Cauxin	MACRO	
	TEXT
	move.w	#c_auxin,-(sp)
	trap	#GEMDOS
	addq.w	#2,sp
	ENDM	d0.b=ASCII

* Serial Port ready to read (true/false) (handle 1)
Cauxis	MACRO	
	TEXT
	move.w	#c_auxis,-(sp)
	trap	#GEMDOS
	addq.w	#2,sp
	ENDM	d0.l=-1 if key ready, else 0

* Serial Port ready to write (true/false) (handle 1)
Cauxos	MACRO	
	TEXT
	move.w	#c_auxos,-(sp)
	trap	#GEMDOS
	addq.w	#2,sp
	ENDM	d0.l=-1 if ready for key, else 0

* Write character to serial port
*	waits for key to be sent
*	tabs are not expanded
*	NO FLOW CONTROL ON THIS - USE BCONOUT WITH BCOSTAT!
*	else maybe lose transmitted characters
*	Top Byte of char on stack must be zero - so load byte!
Cauxout	MACRO	character
	TEXT
	clr.w	-(sp)
	move.b	\1,1(sp)
	move.w	#c_auxout,-(sp)
	trap	#GEMDOS
	addq.w	#4,sp
	ENDM	

* Read Console, echo & return value (handle 0)
*	waits for Keypress
* 	scancode only available if handle 0 is still console!
*	bits 24-31	shift status (if conterm bit 3 set) or 0
*	bits 16-23	scancode
*	bits 0-7	ascii
*	Does not return indication of EOF & can't tell if file or device
*	^C does NOT terminate
*	New TOS can now use ALT+NUMPAD to key ascii code 000-255
Cconin	MACRO	
	TEXT
	move.w	#c_conin,-(sp)
	trap	#GEMDOS
	addq.w	#2,sp
	ENDM	d0.b=ASCII (swap d0.b)=scancode

* Write to Console (handle 0)
*	Tabs are not expanded
*	VT-52 command codes are interpreted as such and hence not printed
*	Top Byte of char word on stack must be zero so stack Byte
Cconout	MACRO	character
	TEXT
	clr.w	-(sp)
	move.b	\1,1(sp)
	move.w	#c_conout,-(sp)
	trap	#GEMDOS
	addq.w	#4,sp
	ENDM	

* Console ready to read (true/false)
*	Since consoles & files are always ready - check not needed!
*	Unless re-routed!
Cconis	MACRO	
	TEXT
	move.w	#c_conis,-(sp)
	trap	#GEMDOS
	addq.w	#2,sp
	ENDM	d0.l=-1 if key ready, else 0

* Console ready to send (true/false)
Cconos	MACRO	
	TEXT
	move.w	#c_conos,-(sp)
	trap	#GEMDOS
	addq.w	#2,sp
	ENDM	d0.l=-1 if key ready, else 0


* Read string from console (handle 0)
*	echoes chars to screen
*	buffer[0]=length of buffer (entered by YOU),
*	buffer[1]=string length (entered by it)
*	string non-terminated
*	HANGS ON EOF if file
*	^M or [RETURN] ends the line (with CR)
*	^J ends the line (with LF)
*	^H or [BS] kills last character
*	^U kills line (skip to next line)
*	^X kills line (erase to start of line)
*	^R (skip to next line) retypes line
*	^C terminates program
*	^I is a Tab
Cconrs	MACRO	input_buffer
	TEXT
	move.l	\1,-(sp)
	move.w	#c_conrs,-(sp)
	trap	#GEMDOS
	addq.w	#6,sp
	ENDM

* Write string to Console
*	string is null terminated
*	VT-52 commands are interpreted
Cconws	MACRO	string_address
	TEXT
	move.l	\1,-(sp)
	move.w	#c_conws,-(sp)
	trap	#GEMDOS
	addq.w	#6,sp
	ENDM	d0=number of chars printed

* Read string from Console, no echo
*	wait for keypress
*	^s pause output
*	^q resume output
*	^c terminate program
*	these control codes may not work on very early TOS's
*	they would then be passed back to program instead
Cnecin	MACRO	
	TEXT
	move.w	#c_necin,-(sp)
	trap	#GEMDOS
	addq.w	#2,sp
	ENDM	d0.l=keyvalue (^s,^q,^c active)

* Parallel port ready to write (true/false)
Cprnos	MACRO	
	TEXT
	move.w	#c_prnos,-(sp)
	trap	#GEMDOS
	addq.w	#2,sp
	ENDM	d0.l=-1 if ready, else 0

* Write character to Parallel Port
*	if cannot send, fails after time-out period
*	waits for char to be sent
*	tabs are not expanded
*	Top Byte of char on stack must be zero, so stack byte only
Cprnout	MACRO	character
	TEXT
	clr.w	-(sp)
	move.b	\1,1(sp)
	move.w	#c_prnout,-(sp)
	trap	#GEMDOS
	addq.w	#4,sp
	tst.w	d0
	bne	.\@
	Error	Printer_err_msg
.\@	
	ENDM	d0.w=>0=fail,-1=o.k.

* Read character from keyboard, no echo (handle 0)
*	wait for keypress
*	passes all control codes to program
*	no EOF indication
Crawcin	MACRO
	TEXT
	move.w	#c_rawcin,-(sp)
	trap	#GEMDOS
	addq.w	#2,sp
	ENDM	d0.l=keyvalue (d0.b=char and swap d0.b=scancode)

* Raw I/O to/from keyboard/screen (no wait)
*	VT-52 codes are interpreted
*	tabs are not expanded
*	cannot write 255 to screen
*	d0.w=$00 is EOF or NO CHAR ready on input
Crawio	MACRO	character or $00ff to read
	TEXT
	clr.w	-(sp)
	move.b	\1,1(sp)
	move.w	#c_rawio,-(sp)
	trap	#GEMDOS
	addq.w	#4,sp
	ENDM	d0.w=keyscan_code/ASCII or 0 for no key - if reading

* Set Cursor Blink Mode & Rate
*		See equates.i for Blink Modes
*		Don't need rate for modes 0-3
*		Rate is (Blinks-per-sec * frame-freq)/2
*		Rate set is cursor on time
*		Rate of zero is 256 - Range 0-255
*		Default rate is 30
*		GET_BLINK_RATE puts Current Rate in low byte of d0
Cursconf	MACRO	mode,rate
		TEXT
		IFEQ	NARG-2
		move.w	\2,-(sp)
		ENDC
		move.w	\1,-(sp)
		move.w	#cursconf,-(sp)
		trap	#XBIOS
		IFEQ	NARG-2
		addq.w	#6,sp
		ELSE
		addq.w	#4,sp
		ENDC
		ENDM	d0.b = old_rate if mode is GET_BLINK_RATE (5)
			;otherwise d0.b is junk

* Write string to Intelligent Keyboard Controller
*	count is string length-1
Ikbdws	MACRO	count,string_ptr
	TEXT
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#ikbdws,-(sp)
	trap	#XBIOS
	addq.w	#8,sp
	ENDM

* Input (& output) Buffer tables
*	device 0 = RS232
*	device 1 = Console
*	device 2 = MIDI
*	ADDED 1 TO DEVICE TO ALLOW COMPATIBILITY WITH OTHER DEVICE CALLS
*	see equates.i for structure of I/O record
*	rs232 output buffer follows on from input buffer
*	flow control says stop at high water & start at low water
Iorec	MACRO	device
	TEXT
	move.w	\1,-(sp)
	addq.w	#1,(sp)	;maintain normal device numbers
	move.w	#iorec,-(sp)
	trap	#XBIOS
	addq.w	#4,sp
	ENDM	d0.l=input buffer record address

* Get/set Keyboard Repeat rate
*	-1 will LEAVE value unchanged
*	times are in system ticks (50Hz)
Kbrate	MACRO	delay_rate, repeat_rate
	TEXT
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#kbrate,-(sp)
	trap	#XBIOS
	addq.w	#6,sp
	ENDM	d0.w=delay/repeat <high/low byte>

* Set/Get keyboard state of shift-keys
*	mode is state to set to or -1 to read
*	see equates.i for bit values
*	shift code result is IBM compatible
Kbshift	MACRO	mode(+ve/-ve)
	TEXT
	move.w	\1,-(sp)
	move.w	#kbshift,-(sp)
	trap	#BIOS
	addq.w	#4,sp
	ENDM	d0.l=Shift_code before any changes here

* Set Keyboard Translation Tables
*	Each pointer points to 128 byte table 
*	containing ascii number at scancode position
*	see equates.i for table structure returned (list of pointers)
*	restore to default settings with Bioskeys() 
*	Pass -1 to leave a key table as it is
Keytbl	MACRO	key_tbl,shift_key_tbl,caps_key_tbl
	TEXT
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#keytbl,-(sp)
	trap	#XBIOS
	lea	14(sp),sp
	ENDM	d0.l=pointer to table of three pointers

* Write string to MIDI Port
*	count is length of string minus one
Midiws	MACRO	count,string_ptr
	TEXT
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#midiws,-(sp)
	trap	#XBIOS
	addq.w	#8,sp
	ENDM	

* Configure RS232 port
*	-1 means don't set parameter
*	see equates.i for speed table from 19200 to 50 baud
*	see equates.i for flow control table (either XON/XOFF or RTS/CTS)
*	ucr,rsr,tsr,scr set the 68901 registers named
*	ucr=parity, stop bits and data bits
*	see equates.i for values
Rsconf	MACRO	speed,flow_control,ucr,rsr,tsr,scr
	TEXT
	move.w	\6,-(sp)
	move.w	\5,-(sp)
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#rsconf,-(sp)
	trap	#XBIOS
	addq.w	#4,sp
	ENDM	d0.l=old ucr/rsr/tsr/scr 

* DISK DEVICE I/O ROUTINES (also see FILE ROUTINES)
**************************
* Disk Date & Time formats are same as GEMDOS/XBIOS date & time
* Floppy/Hard disk interrupt available - see traps.i
* critical error vector available for file prompts - see equates.i
* memory variables - see flock, seekrate, fverify, bootdev in equates.i
* hard disk - see hdv_init, hdv_bpb, hdv_rw, hdv_boot, hdv_mediach,
* _nflops, _drvbits, _dskbufp, pun_ptr and _cmdload in equates.i
* variable _bufl points to fat and data buffers

* Create a Directory
*	Can specify full path but path to new directory must exist
*	Fails if no room in root dir or directory exists or
*		path to directory doesn't exist
Dcreate	MACRO	pathname_addr
	TEXT
	move.l	\1,-(sp)
	move.w	#d_create,-(sp)
	trap	#GEMDOS
	addq.w	#6,sp
	Gemdos_error	
	ENDM	d0.w=0 or error

* Delete a Directory
*	Directory must be empty
Ddelete	MACRO	pathname_addr
	TEXT
	move.l	\1,-(sp)
	move.w	#d_delete,-(sp)
	trap	#GEMDOS
	addq.w	#6,sp
	Gemdos_error	
	ENDM

* Free space on drive
*	see equates.i for table contents
*	(table) is Number of Free Clusters
*	(table+4) is Total Number of Clusters on Drive
*	(table+8) is Sector Size in Bytes
*	(table+12) is Cluster Size in Sectors
*	Very slow on hard disks
*	NOT SURE IF 0=A OR 0=DEFAULT DRIVE!
Dfree	MACRO	table.l,drive_num
	TEXT
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#d_free,-(sp)
	trap	#GEMDOS
	addq.w	#8,sp
	ENDM

* Get default drive (0=A)
*	supports drives 0-15 (A:-P:)
Dgetdrv	MACRO	
	TEXT
	move.w	#d_getdrv,-(sp)
	trap	#GEMDOS
	addq.w	#2,sp
	ENDM	d0.l=Logical Drives (bit set per drive)

* Get Path on any drive
*	current drive=0,a=1,etc.
*	path string length has no limit - use 128 bytes or more
Dgetpath	MACRO	path_buffer,drive
		TEXT
		move.w	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#d_getpath,-(sp)
		trap	#GEMDOS
		addq.w	#8,sp
		Gemdos_error	
		ENDM

* Bitmap of Logical drives
*	result taken from _drvbits ($4c4) - see equates.i
*	GemDos uses A-P, other add-ons use the full A-Z, Mint uses U
Drvmap	MACRO
	TEXT
	move.w	#drvmap,-(sp)
	trap	#BIOS
	addq.w	#2,sp
	ENDM	do.l=Logical Drives (bit set per drive)

* Set default drive (0=A)
*	drives 0-15 valid (A:-P:)
*	only returns drives whose directories have been looked at
Dsetdrv	MACRO	drive_number
	TEXT
	move.w	\1,-(sp)
	move.w	#d_setdrv,-(sp)
	trap	#GEMDOS
	addq.w	#4,sp
	ENDM	d0.l=Logical Drives (bit set per drive)

* Set Path on current drive
*	do not use a drive letter in pathname
*	If drive & colon are in pathname, Default path for that drive is set
*		but default drive is not changed.
Dsetpath	MACRO	pathname_addr
		TEXT
		move.l	\1,-(sp)
		move.w	#d_setpath,-(sp)
		trap	#GEMDOS
		addq.w	#6,sp
		Gemdos_error	
		ENDM

* Format Track on floppy disk
*	buffer is word aligned and long enough to hold at least one tracks 
*	worth of sectors
*	skewtable is not used on TOS that cannot skew disks (pre-blitter)
*	it is only used if interleave is -1
*	it is a pointer to a table of sector numbers (word length) in the order
*	they are to be put on disk (sectors_per_track*tracks of them)
*	dev_num is 0 or 1 for floppy A or B
*	interleave is (number of sectors between sector numbers)-1
*	usually set to 1 for sector order 1,2,3,etc
*	magic must be $87654321
*	virgin is the value on blank sectors normally $e5e5
*	high nibble of virgin cannot be $f
*	bad sectors are returned in the buffer, sector numbers in words
*	list is null terminated
*	first word in buffer is zero if no bad sectors
*	bad sectors may not be in numerical order
*	media-definately-changed is recorded
*	Bad sectors should be marked in the FATs
*	Bad sectors in the first two tracks mean disk is unuseable
Flopfmt	MACRO	buffer,skewtable,dev_num,sect_per_track,track_num,side_num,interleave,magic,virgin
	TEXT
	move.w	\9,-(sp)
	move.l	\8,-(sp)
	move.w	\7,-(sp)
	move.w	\6,-(sp)	
	move.w	\5,-(sp)
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.l	\2,-(sp)	;unused on pre-blitter TOS
	move.l	\1,-(sp)
	move.w	#flopfmt,-(sp)
	trap	#XBIOS
	lea	26(sp),sp
	Gemdos_error
	ENDM	d0.w=0 or bios error

* Read Sectors from floppy disk
*	dummy is not used
*	buffer is word aligned and long enough to hold all sectors read
*	dev_num is 0 or 1 for floppy A or B
*	count must be less than or equal to sectors-per-track
Floprd	MACRO	buffer,dummy,dev_num,sect_num,track_num,side_num,count
	TEXT
	move.w	\7,-(sp)
	move.w	\6,-(sp)	
	move.w	\5,-(sp)
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.l	\2,-(sp)	;unused
	move.l	\1,-(sp)
	move.w	#floprd,-(sp)
	trap	#XBIOS
	lea	20(sp),sp
	Gemdos_error
	ENDM	d0.w=0 or bios error

* Read & Verify Sectors from floppy disk
*	dummy is not used
*	buffer is word aligned and long enough to hold a cluster (1024 normally)
*	dev_num is 0 or 1 for floppy A or B
*	count must be less than or equal to sectors-per-track
*	bad sectors are returned in the buffer, null terminated
*	first word in buffer is zero if no bad sectors
*	bad sectors may not be in numerical order
Flopver	MACRO	buffer,dummy,dev_num,sect_num,track_num,side_num,count
	TEXT
	move.w	\7,-(sp)
	move.w	\6,-(sp)	
	move.w	\5,-(sp)
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.l	\2,-(sp)	;unused
	move.l	\1,-(sp)
	move.w	#flopver,-(sp)
	trap	#XBIOS
	lea	20(sp),sp
	Gemdos_error
	ENDM	d0.w=0 or bios error

* Write Sectors to floppy disk
*	dummy is not used
*	buffer is word aligned, holding all sectors to write
*	dev_num is 0 or 1 for floppy A or B
*	count must be less than or equal to sectors-per-track
*	writing to sector 1, track 0, side 0 causes media-maybe-changed status
Flopwr	MACRO	buffer,dummy,dev_num,sect_num,track_num,side_num,count
	TEXT
	move.w	\7,-(sp)
	move.w	\6,-(sp)	
	move.w	\5,-(sp)
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.l	\2,-(sp)	;unused
	move.l	\1,-(sp)
	move.w	#flopwr,-(sp)
	trap	#XBIOS
	lea	20(sp),sp
	Gemdos_error
	ENDM	d0.w=0 or bios error

* Get bios parameter block for drive (0=A)
*	see equates.i for BPB table format
*	see disk_str.txt for details on usage
*	Returns 0.L if no BPB found!
Getbpb	MACRO	Drivenum
	TEXT
	move.w	\1
	move.w	#getbpb,-(sp)
	trap	#BIOS
	addq.w	#4,sp
	ENDM	do.l=bpb_ptr (see equates.i)

* Has Disk changed? (0=no/1=maybe/2=yes)
Mediach	MACRO	drivenum (0=A, 1=B, etc)
	TEXT
	move.w	\1,-(sp)
	move.w	#mediach,-(sp)
	trap	#BIOS
	addq.w	#2,sp
	ENDM	d0=0-no change/1-might have changed/2-changed
	
* Make a Boot Sector in RAM
*	stored on side 0, track 0 , sector 1
*	buffer may contain a boot sector already and is sector sized!
*	e.g. for making executable boot sectors
*	if serial_num=-1, buffer's serial number is not changed
*	if serial_num>=$01000000 Random number is used
*	otherwise number given is used
*	see equates.i for disk types
*	pass -1 for disk type to leave as is in buffer
*	Exec=1 for executable boot sector
*	exec=0 for non-exec, -1 to leave buffer alone
*	write to disk boot sector when finished
Protobt	MACRO	buffer,Serial_num,Disktype,Execflag
	TEXT
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#protobt,-(sp)
	trap	#XBIOS
	lea	14(sp),sp
	ENDM

* Read/Write Absolute Sectors
*	see equates.i for modes
*	Drive 0=A, 1=B, etc.
*	used by GEMDOS on first access or media change
*	odd buffer address allowed but slow!
*	mode bit 0 - write when set, else read
*	mode bit 1 - do not check or change media changed status if set
*	mode bit 2 - disable retry if set - AHDI >=V3
*	mode bit 3 - physical sector if set, else logical - AHDI >=V3
*	to use sector>32767, start=-1, long start used for sector - AHDI >=V3
*	buffer length needs to be bytes-per-sector (512 normally) * number of sectors
Rwabs	MACRO	mode,buffer,sectors,start,drivenum,(long start)
	TEXT
	IFEQ	6-NARG
	move.l	\6,-(sp)
	ENDC
	move.w	\5,-(sp)
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#rwabs,-(sp)
	trap	#BIOS
	IFEQ	6-NARG
	lea	18(sp),sp
	ELSE
	lea	14(sp),sp
	ENDC
	Gemdos_error
	ENDM	

* ERROR ROUTINES
****************
* critical error vector available - see equates.i

* Reports any valid Gemdos or Bios error
*	should be long negative but some functions return word negative
*	so test is done for word negative instead
Gemdos_error	MACRO	error_num in d0
		TEXT
		tst.w	d0	;-ve=gemdos error
		bpl.s	.\@
		move.w	d0,-(sp)
		neg.w	d0
		lsl.w	#2,d0
		move.l	#BIOS_ERRORS,a0
		move.l	(a0,d0.w),a0
		Error	a0
		move.w	(sp)+,d0
.\@
		ENDM

* Reports any short message as an error message
Error	MACRO	err_msge_addr
	TEXT
	IFD	Gem_flag
	Form_alert	0,\1
	ELSE
	Tos_alert	\1
	ENDC
	ENDM

* Report error and wait for keypress
Tos_alert	MACRO	err_msge_addr
		TEXT
		Cconws	\1
		Crawcin
		ENDM

* FILE MANAGEMENT MACROS
************************
* Legal Drives: A-P or CON: AUX: PRN: for read/write/open/create/close.
* CON: AUX: PRN: have handles -1,-2,-3 (word length)
* Standard handles are 0-5, 6 and above are file handles
* Media change closes all open handles on that disk
* Legal Pathnames: {A:}{\}{path\}<file>{.}{ext},0
* Path may use '.' & ".." for current and parent
* start with slash to start at root of drive
* no drive to use current drive - no \path to use current directory
* Legal Letters in Filenames: A-Z a-z 0-9 _ ! @ # $ % ^ & ( ) + - = ~ ` ; 
*                              ' " , < > | [ ] { }
* Text files end lines with CR-LF and end files with ^Z
* Disk Date & Time formats are same as GEMDOS/XBIOS date & time

* Get/Set File Attributes
*	see equates.i for file attributes
*	archive bit does not work on all GEMDOS
Fattrib	MACRO	filename_addr,get(0)/set(1),attributes
	TEXT
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#f_attrib,-(sp)
	trap	#GEMDOS
	lea	#10(sp),sp
	Gemdos_error	
	ENDM	do.w=current attributes if get used else not defined

* Close a File
*	Note: PRN,CON & AUX should not be closed
Fclose	MACRO	file_handle
	TEXT
	move.w	\1,-(sp)
	move.w	#f_close,-(sp)
	trap	#GEMDOS
	addq.w	#4,sp
	Gemdos_error	
	ENDM	d0.w=0 or error code

* Create/Wipe a File and open it for Writing
*	Pathname should be Null terminated
*	see equates.i for attributes
*	returns handle as word or error code
*	Error codes may be -34 (Path not found), -35 (No handles Available)
*		or -36 (Access Denied - read only maybe)
*	Files that already existed are set to zero length
*	File Created/Wiped is opened for write only
*	do not set read_only on creation as file is only opened for writing!
*	only have one volume label per disk - GEMDOS will allow many!
*	Note: CON, AUX & PRN are already open as file handles (-1,-2,-3)
*	but they return -ve handles (words) if opened or created.
*	Handles 0-5 are reserved (for STDIN, STDOUT, STDERR, STDAUX & STDLIST?)
*	First handle assigned to files is 6
*	negative longs indicate true errors
*	Child processes inherit parent's handles
*	Handles are closed when media changes or program terminates
*	Position pointer set to start of file
Fcreate	MACRO	path&name_addr,attributes
	TEXT
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#f_create,-(sp)
	trap	#GEMDOS
	addq.w	#8,sp
	Gemdos_error	
	ENDM	d0.w=file handle or error

* Get/Set File Date & Time stamp
*	buffer=time.w,date.w (or other way round?)
*	Date=YYYYYYYMMMMDDDDD - add 1980 to year
*	Time=HHHHHMMMMMMSSSSS - multiply seconds by 2
Fdatime	MACRO	date&time_ptr,handle,get(0)/set(1)
	TEXT
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#f_datime,-(sp)
	trap	#GEMDOS
	lea	10(sp),sp
	ENDM	

* Delete a File
Fdelete	MACRO	filename_addr
	TEXT
	move.l	\1,-(sp)
	move.w	#f_delete,-(sp)
	trap	#GEMDOS
	addq.w	#6,sp
	Gemdos_error	
	ENDM	

* Duplicate a File Handle
*	returns an alternative handle for a standard device
*	see Fforce
Fdup	MACRO	std_handle (0-5)
	TEXT
	move.w	\1,-(sp)
	move.w	#f_dup,-(sp)
	trap	#GEMDOS
	addq.w	#4,sp
	Gemdos_error	
	ENDM	d0.w=new_handle

* Force a Standard File Handle to alternative handle
*	Used for printing to Disk,etc
*	Duplicate Std Handle first so it can be Fforced back to normal after
*	by forcing it to the duplicates handle (then close duplicate handle)
*	see Fdup
*	used to redirect standard output
Fforce	MACRO	std_handle,alt_handle
	TEXT
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#f_force,-(sp)
	trap	#GEMDOS
	addq.w	#6,sp
	Gemdos_error	
	ENDM

* Get disk transfer address (WORD ALIGNED)
*	see equates.i for 44 byte buffer
Fgetdta	MACRO
	TEXT
	move.w	#f_getdta,-(sp)
	trap	#GEMDOS
	addq.w	#2,sp
	ENDM	d0.l=DTA_Address

* Get File Length
Flength	MACRO	file_handle
	TEXT
	Fseek	#1,\1,EOF
	ENDM	d0.l=file length

* Open a File
*	see equates.i for mode
*	0 = Read Only
*	2 = Write Only
*	3 = Read or Write
*	Note: PRN,CON & AUX are already open as file handles
*	but they return -ve words if opened or created.
*	negative longs indicate true errors
*	Position pointer set to start of File
Fopen	MACRO	path&name_addr,open_mode
	TEXT
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#f_open,-(sp)
	trap	#GEMDOS
	addq.w	#8,sp
	Gemdos_error	
	ENDM	d0.w=file handle or error

* Read a File
*	Note: PRN,CON & AUX are already open as file handles
*	if you read past end of file, no error,
*		but length read(d0) <> length requested
*	returns 0 on EOF
Fread	MACRO	file_handle,length,buffer_addr
	TEXT
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#f_read,-(sp)
	trap	#GEMDOS
	lea	12(sp),sp
	Gemdos_error	
	ENDM	d0.w=number of bytes read

* Rename a File
*	Wildcards may NOT be used
*	new name must not exist
*	new name may be in another directory!
Frename	MACRO	old_name_ptr,new_name_ptr
	TEXT
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	clr.w	-(sp)
	move.w	#f_rename,-(sp)
	trap	#GEMDOS
	lea	12(sp),sp
	Gemdos_error
	ENDM	

* Seek a Position within a File
*	see equates.i for start_point
*	0 = Beginning Of File
*	1 = Current Position
*	2 = End Of File
*	Note: 	seek before BOF returns 0
*		seek after EOF returns length of file
*	-ve position will give -ve offset from start_point
Fseek	MACRO	position,file_handle,start_point
	TEXT
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#f_seek,-(sp)
	trap	#GEMDOS
	lea	10(sp),sp
	ENDM	d0.w=position from BOF

* Set disk transfer address (WORD ALIGNED)
*	see equates.i for 44 byte buffer
Fsetdta	MACRO	new_dta_addr
	TEXT
	move.l	\1,-(sp)
	move.w	#f_setdta,-(sp)
	trap	#GEMDOS
	addq.w	#6,sp
	ENDM

* Search a File specification (for the first time)
*	Use Fsnext for repeat searches
*	wildcards are allowed in the filename but not the path
*	hidden & system files are included if specified
*	volumes & subdirectories are searched exclusive of other attributes
*	see equates.i for attributes
*	see equates.i for DTA buffer table
Fsfirst	MACRO	filespec_addr,attributes
	TEXT
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#f_sfirst,-(sp)
	trap	#GEMDOS
	addq.w	#8,sp
	Gemdos_error
	ENDM	d0.w=0 or -33 (file not found)

* Repeat Search for a File specification
*	Used after Fsfirst succeeds to get next match
*	see equates.i for attributes
*	see equates.i for DTA buffer table
*	DTA contents must remain unaltered between calls
Fsnext	MACRO	
	TEXT
	move.w	#f_snext,-(sp)
	trap	#GEMDOS
	addq.w	#2,sp
	Gemdos_error
	ENDM	d0.w=0 or -33 (file not found)

* write to a File
*	Note: PRN,CON & AUX are already open as file handles
*	if disk full, length returned (d0) <> length requested to write
*	otherwise d0=length or a gemdos error code
*	Note: This limits file size to 31 bit lengths!
Fwrite	MACRO	file_handle,length,buffer_addr
	TEXT
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#f_write,-(sp)
	trap	#GEMDOS
	lea	12(sp),sp
	Gemdos_error	
	ENDM	d0.l=number of bytes written

* MEMORY MANAGEMENT MACROS
**************************
* see memvalid, memcntlr, themd, phystop, _membot, _memtop, 
* memval2, memval3 in equates.i

* Get System Memory Parameter Block
*	see equates.i for structures
*	used by Gemdos - no other use seen
Getmpb	MACRO	mpb_ptr	;3 longs as pointers to Memory Descriptors
	TEXT
	move.l	\1,-(sp)
	clr.w	-(sp)
	trap	#BIOS
	addq.w	#6,sp
	ENDM

* Add Alternative Memory to System (Gemdos>=0.25)
Maddalt	MACRO	address,size
	TEXT
	cmp.w	#25,Gemdos_ver
	bge	.\@
	Error	#Gd_ver_err_msg
.\@	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#m_addalt,-(sp)
	trap	#GEMDOS
	lea	10(sp),sp
	ENDM

* Allocate memory (from alternate memory if bit 2 set in program header)
* 	pass -1 to return memory available
*	DO NOT EXCEED 20 OPEN MEMORY BLOCKS AT ANY GIVEN TIME!
Malloc	MACRO	memory_required
	TEXT
	move.l	\1,-(sp)
	move.w	#m_alloc,-(sp)
	trap	#GEMDOS
	addq.w	#6,sp
	tst.l	d0
	bne.s	.\@
	Error	#Malloc_err_msg
.\@
	ENDM

* Move block of memory in bytes,words or longs
* 		Uses d0/a0-a1
Mem_move	MACRO	from,to,count
		TEXT
	move.w	\3,d0
		move.l	\1,a0
		move.l	\2,a1
.\@		move.\0	(a0)+,(a1)+
		dbra	d0,.\@
		ENDM

* Free allocated memory (normal or alternate)
*	Any memory not returned is freed when program terminates
Mfree	MACRO	memory_to_free
	TEXT
	move.l	\1,-(sp)
	move.w	#m_free,-(sp)
	trap	#GEMDOS
	addq.w	#6,sp
	Gemdos_error
	ENDM

* Free tail end of memory block back to Gemdos
*	Normal Errors are:
*		-40 Invalid Memory Block Address
*		-67 Memory Block Growth Failure
Mshrink	MACRO	address,new_size
	TEXT
	IFNE	2-NARG
	FAIL	Invalid Number of Parameters!
	ENDC
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	clr.w	-(sp)
	move.w	#m_shrink,-(sp)
	trap	#GEMDOS
	lea	12(sp),sp
	Gemdos_error
	ENDM
	
* Allocate memory with preference
*	see equates.i for memory types
*	new for GEMDOS v0.25
*	pass length of -1 for max available of type
*	Do not use alternate memory for screen
Mxalloc	MACRO	length_required,type
	TEXT
	cmp.w	#25,Gemdos_ver
	bge.s	mxa_good.\@		;no function
	cmp.w	#1,\2			;no alt memory
	beq.s	mxa_zero\@
	Malloc	\1
	bra.s	mxa_end\@
mxa_good.\@	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#m_xalloc,-(sp)
	trap	#GEMDOS
	addq.w	#8,sp
	bra.s	mxa_end\@
mxa_zero\@	clr.l	d0
mxa_end\@
	bne.s	.\@
	Error	#Malloc_err_msg
.\@
	ENDM	d0.l=address or 0 to fail or size of largest block

* Reserve size bytes from top of memory
*	only works before GEMDOS is initialised!
Ssbrk	MACRO	size
	TEXT
	move.l	\1,-(sp)
	move.w	#ssbrk,-(sp)
	trap	#XBIOS
	addq.w	#6,sp
	ENDM	d0.l=start of reserved memory

* MOUSE MACROS
**************

* Initialise mouse packet handler
*	see equates.i for mouse modes and parameter structure
*	see XBIOS 34 Kbdvbase for info on KBD subsystem handlers
Initmouse	MACRO	mode,parameter_ptr,mouse_interrupt_handler_addr
	TEXT
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#initmouse,-(sp)
	trap	#XBIOS
	lea	12(sp),sp
	ENDM

* NUMERIC ROUTINES
******************

* Get Random Number
*	seed=(seed * 3141592621) + 1
*	random=seed >> 8
*	Initial value of seed taken from _frclock (frame counter)
*	bits 24-31 are zero
*	bit 0 has exact 50% distribution
Random	MACRO
	TEXT
	move.w	#random,-(sp)
	trap	#XBIOS
	addq.w	#2,sp
	ENDM	d0.l=24 bit Pseudo Random Number

* PRINTER MACROS
****************

* Get/Set Printer Configuration
*	Get config if config_word=-1
*	Usually used by Install Printer Desk Accessory
*	Values used by Screen Dump & Desktop File Printing
*	Screen print doesn't support Epson Colour Printers
*	or Colour Daisywheels
*	new_code is 16 bit flag - see equates.i
Setprt	MACRO	new_code
	TEXT
	move.w	\1,-(sp)
	move.w	#setprt,-(sp)
	trap	#XBIOS
	addq.w	#4,sp
	ENDM	d0.w = old_code
	
* PROGRAM STARTUP & SHUTDOWN MACROS
***********************************
* Program owns files it opens and memory it allocates Exclusively
* Owned files and memory is cleared when it terminates
* Vector $102 is called just before program terminates
* - see etv_term/ETV_TERM in equates.i
* system reset bailout vector available - see resvalid, resvector in equates.i
* memory variables - see phystop, membot, memtop and mval2 in equates.i
* also see _cmdload for auto shell loading

* Load and/or Execute a Program
*	DO NOT USE IF YOU ARE AN ACCESSORY!
*	All parents std_handles are passed as they are to child
*	i.e. redirection is passed down the chain
*	Must terminate child process to return system resources to parent
*	see equates.i for load modes
*	see pexec.txt for further details
*	LOAD_GO,file_name,cmd_lin,env_lin
*	LOAD,file_name,cmd_lin,env_lin
*	GO,0.l,basepage,0.l
*	MAKE_BASEPAGE,0.l,cmd_lin,env_lin
*	cmd_line=length_byte+string,0
*	env_line=0 for previous env
*	env_line=array of null terminated strings + 0 at end
*	e.g.	"PATH=C:\",0,"LIB=C:\LIB",0,0
Pexec	MACRO	mode,filename_ptr,cmd_line_ptr,env_ptr
	TEXT
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#p_exec,-(sp)
	trap	#GEMDOS
	lea	16(sp),sp
	Gemdos_error
	ENDM	d0.l=various - see above

* standard exit from program
Prog_exit	MACRO	<return code>
	TEXT
	cmp.l	#"BSTK",Stack_end
	beq.s	.B\@
	Error	#Stklo_err_msg
.B\@	
	cmp.l	#"TSTK",Stack_start
	beq.s	.T\@
	Error	#Stkhi_err_msg
.T\@	
	IFEQ	NARG
	Pterm0
	ELSE
	Pterm	\1
	ENDC
	ENDM	

* standard startup into program
*	shrink program to required length
*	Basepage variable is pointer to program basepage
*	Stack points to top of stack
*	Stackend points to bottom of stack
*	checks against overflow put at top & bottom of stack
*	Gets GEMDOS Version
*	Gets Pointer to A_Table
Prog_shrink	MACRO	<stacksize>
	TEXT
	IFGT	NARG-1
	FAIL	Too Many Parameters in Prog_shrink!
	ENDC
	move.l	4(sp),a0	;pointer to Basepage
	move.l	a0,Basepage
	move.l	$c(a0),d0	;length of TEXT Section
	add.l	$14(a0),d0	;length of DATA Section
	add.l	$1c(a0),d0	;length of BSS Section
	add.l	#$100,d0	;length of Basepage
	move.l	a0,d1
	add.l	d0,d1	;new hitpa=start of basepage + size
	move.l	d1,P_hitpa(a0)	;added for Pexec mode 4 compatability
	move.l	#Stack,sp	;in BSS Section
	move.l	#"BSTK",Stack_end	;test value
	move.l	#"TSTK",Stack_start	;test value
	Mshrink	a0,d0	;address,size
	Sversion		;store version of Gemdos
	move.b	d0,Gemdos_ver
	lsr.w	#8,d0	;in hi-low format!
	move.b	d0,Gemdos_ver+1
	A_Init
	move.l	a0,A_Table
	BSS
	IFEQ	NARG
Stack_end	ds.l	1024/4	;default stack of 1K
	ELSE
Stack_end	ds.l	\1/4	;default stack of 1K
	ENDC
Stack	ds.l	1
Stack_start	ds.l	1

Basepage	ds.l	1
A_Table		ds.l	1	;Pointer to A_line Table
Gemdos_ver	ds.w	1	;Gemdos version number (High/Low)
	TEXT
	ENDM

* Exit and return error_code
* 	closes all files and releases all allocated memory
*	return code is -ve for error, +ve for message
*	Actual Code received is Long -ve for Program Load Error
*		Word -ve for program indicating error
Pterm	MACRO	return_code(+ve)
	TEXT
	move.w	\1,-(sp)
	move.w	#p_term,-(sp)
	trap	#GEMDOS
	ENDM

* Exit and return 0
* 	closes all files and releases all allocated memory
Pterm0	MACRO
	TEXT
	clr.w	-(sp)
	trap	#GEMDOS
	ENDM
	
* Terminate & Stay Resident
*	allocated ram is kept
*	open files are closed
*	size=basepage($100)+prog[+data][+stack]
*	exit_code should be +ve (or -ve for error code)
*	Resident_size includes 256 bytes of Basepage
Ptermres	MACRO	Resident_size,exit_code
		TEXT
		move.w	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#p_termres,-(sp)
		trap	#GEMDOS
*		addq.w	#8,sp	;never returns!
		ENDM

* SCREEN ROUTINES
*****************
* Monitor Type interrupt available - see traps.i
* HSYNC interrupt available - see traps.i
* also see HSYNC.txt to make use of it!
* OS variables - see palmode, defshiftmd, sshiftmd, v_bas_ad, colorptr,
* swc_vec and screenpt in equates.i
* also see _prt_cnt, scr_dump, prv_lsto, prv_lst, prv_auxo, prv_aux
* for screen dumps

* Get/Set Blitter Config
*	Use mode of -1 to leave Blitter in Current State
*	mode=0 to use Software Blit
*	mode=1 to use Hardware Blit
*	returns Bit 0 Set = Hardware Blit
*	returns Bit 1 Set = Blitter Hardware Present
Blitmode	MACRO	mode
		TEXT
		move.w	\1,-(sp)
		move.w	#blitmode,-(sp)
		trap	#XBIOS
		addq.w	#4,sp
		ENDM	do.w = old_mode

* Get screen resolution 
*	0,1 or 2 for ST Low/Med/High
*	7,4 or 6 for TT Low/Med/High
*	use for open virtual workstation only
Getrez	MACRO
	TEXT
	move.w	#getrez,-(sp)
	trap	#XBIOS
	addq.w	#2,sp
	ENDM	d0.w=screen mode currently in use

* Get Logical Screen Address
*	This is where TOS writes to when told to draw on the screen
*	Normally the same address as the Physical screen address
*	To make Screen updates look fast: 
*		reserve memory the size of the screen
*		point logbase to reserved memory (see Setscreen)
*		copy physical screen to logical screen
*		do all drawing
*		copy logical screen to physical screen
*		OR swap screen addresses (log <-> phys)
*	Physical and Logical Address MUST be Aligned
*		ST's to 256 byte boundary (last byte of address is 0)
*		STE's to Word boundary (last bit of address is 0)
Logbase	MACRO
	TEXT
	move.w	#logbase,-(sp)
	trap	#XBIOS
	addq.w	#2,sp
	ENDM	d0.l=Address of Logical Screen

* Get Monitor Type
*	FALCON ONLY
*	0 - ST Mono Monitor
*	1 - ST Colour Monitor
*	2 - VGA Monitor
*	3 - TV
*	value returned is from monitor socket pins
Montype	MACRO
	TEXT
	move.w	#montype,-(sp)
	trap	#XBIOS
	addq.w	#2,sp
	ENDM	d0.w=Monitor Type

* Get Physical Screen Address
*	32K long on normal ST's & STE's
*	Physical and Logical Address MUST be Aligned
*		ST's to 256 byte boundary (last byte of address is 0)
*		STE's to Word boundary (last bit of address is 0)
Physbase	MACRO
	TEXT
	move.w	#physbase,-(sp)
	trap	#XBIOS
	addq.w	#2,sp
	ENDM	d0.l=Address of Physical Screen

* Print all or part of the screen
*	prtable is a 30 byte parameter table
*	see equates.i for structure
*	Uses Vectors $506,$50a,$50e & $512
*	printer status/printer_output/RS-232 status/RS-232 output
Prtblk	MACRO	prtable
	TEXT
	move.l	\1,-(sp)
	move.w	#prtblk,-(sp)
	trap	#XBIOS
	addq.w	#6,sp
	ENDM

* Screen Dump
*	Atari or Epson Compatible only
*	see Setprt for printer settings used by this routine
*	Vectored through 1282 ($502) to allow installation of other
*	screen dump code as TSR's
*	Standard routine calls Prtblk(prtable)
Scrdmp	MACRO
	TEXT
	move.w	#scrdmp,-(sp)
	trap	#XBIOS
	addq.w	#2,sp
	ENDM

* Set the Actual Colour of a Pen
*	pass negative colour for no change
*	colour word is xxxx R0321 G0321 B0321 in bits
*	least significant bit (0) only used on STE and above
*	pens 0-15 valid in ST/STE Low Res
Setcolour	MACRO	pen,colour
		TEXT
		Setcolor	\1,\2
		ENDM
Setcolor	MACRO	pen,colour
		TEXT
		move.w	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#setcolour,-(sp)
		trap	#XBIOS
		addq.w	#6,sp
		ENDM	d0.w=Old colour

* Set 16 Colours
*	pallete_ptr is word aligned
*	points to table of 16 colour words for the 16 pens
*	becomes active at next vblank
*	colour word is xxxx R0321 G0321 B0321
*	least significant bit only used on STE
Setpallete	MACRO	pallete_ptr
	TEXT
	move.l	\1,-(sp)
	move.w	#setpallete,-(sp)
	trap	#XBIOS
	addq.w	#6,sp
	ENDM	

* Set Screen logical and physical address and screen mode
*	phys becomes active at next vblank (maybe not on pre-blitter TOS)
*	To avoid screen glitch on pre-blitter TOS's, 
*		put new and old phys screens in same 64K block
*		OR call Vsync before Setscreen
*	Physical and Logical Address MUST be Aligned
*		ST's to 256 byte boundary (last byte of address is 0)
*		STE's to Word boundary (last bit of address is 0)
*	use -1 for any parameter that should not change
*	change of rez causes clear screen, home cursor & reset VT52
*	if log or phys = -1 then they are not changed
*	If log and phys = 0 then screens are automatically 
*					set to correct size - FALCON ONLY
*	VDI is reinitialised to new rez, AES is not!
*	if rez=0 then ST Low
*	if rez=1 then ST Med
*	if rez=2 then ST High
*	if rez=3 then mode is modecode for Screen
*	rez=3 only valid for FALCON
*	See ModeCode Values in Equates.i
*	Bits 0-2 = Bits per pixel
*	Bit    3 = 80 Column if set
*	Bit    4 = VGA if set
*	Bit    5 = PAL if set
*	Bit    6 = Overscan if set (Not VGA)
*		multiplies X & Y by 1.2
*	Bit    7 = ST Compatible Mode if Set
*	Bit    8 = Interlace on if set (double Y pixels)
Setscreen	MACRO	log,phys,rez (,mode)
	TEXT
	IFEQ	NARG-4
	move.w	\4,-(sp)
	ENDC
	move.w	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#setscreen,-(sp)
	trap	#XBIOS
	IFEQ	NARG-4
	lea	14(sp),sp
	ELSE
	lea	12(sp),sp
	ENDC
	ENDM	d0.l=Address of Physical Screen

* Get List of Palette Colours starting at pen INDEX for COUNT pens into ARRAY of Longs
*	FALCON ONLY
*	ARRAY is filled with Longs of the form xRGB
VgetRGB	MACRO INDEX,COUNT,ARRAY
	TEXT
	move.l	\3,-(sp)
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#vgetrgb,-(sp)
	trap	#XBIOS
	lea	10(sp),sp
	ENDM	

* Get Memory Size needed by a given type of Screen
*	FALCON ONLY
*	See ModeCode Values in Equates.i
*	Bits 0-2 = Bits per pixel
*	Bit    3 = 80 Column if set
*	Bit    4 = VGA if set
*	Bit    5 = PAL if set
*	Bit    6 = Overscan if set (Not VGA)
*		multiplies X & Y by 1.2
*	Bit    7 = ST Compatible Mode if Set
*	Bit    8 = Interlace on if set (double Y pixels)
*	Returns Screen Size in Bytes in d0.l
VgetSize	MACRO	modecode
	TEXT
	move.w	\1,-(sp)
	move.w	#vgetsize,-(sp)
	trap	#XBIOS
	addq.w	#4,sp
	ENDM	d0.l=Screen Size (bytes)

* Set VDI Mask and Overlay Mode
*	FALCON ONLY
*	TRUE COLOUR USE ONLY
* gets/sets the AND/OR masks used by VDI in calculation of vs_colour
* used to enable/disable the overlay bit in true colour mode
*	AND = $FFFF	OR = $0000	NO EFFECT
*	AND = $FFFF	OR = $0020	SET OVERLAY BIT
*	AND = $FFDF	OR = $0000	CLEAR OVERLAY BIT
*	OVERLAY = 0 to take system out of Overlay Mode
*	OVERLAY = Non-Zero to put system into Overlay Mode
* Possible uses in VDI colour changes by masking and redrawing same colour?
VsetMask	MACRO	OR_Mask,AND_Mask,Overlay
	TEXT
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#vsetmask,-(sp)
	trap	#XBIOS
	addq.w	#8,sp
	ENDM
	
* Get/Set Video Mode
*	FALCON ONLY
*	Setscreen is preferred
*	DOES NOT CHANGE SCREEN ADDRESS OR ALLOCATE MEMORY OR TELL VDI
*	IF SCREENSIZE NOW BIGGER, IT WILL CORRUPT UNLESS MOVED FIRST!
*	If Modecode is -1, returns current state without altering anything
*	see equates.i for Modecodes
*	Bits 0-2 = Bits per pixel
*	Bit    3 = 80 Column if set
*	Bit    4 = VGA if set
*	Bit    5 = PAL if set
*	Bit    6 = Overscan if set (Not VGA)
*		multiplies X & Y by 1.2
*	Bit    7 = ST Compatible Mode if Set
*	Bit    8 = Interlace on if set (double Y pixels)
* 	40 Column 2 Colour Mode not allowed
* 	80 Column True Colour Mode not allowed on VGA
* 	VALIDITY OF CODE NOT CHECKED 
* Returns Previous value of Screen Mode
Vsetmode	MACRO	modecode
	TEXT
	move.w	#\1,-(sp)
	move.w	#vsetmode,-(sp)
	trap	#XBIOS
	addq.w	#4,sp
	ENDM	d0.w = old Modecode
	
* Set List of Palette Colours starting at pen INDEX for COUNT pens from ARRAY of Longs
*	FALCON ONLY
*	ARRAY should be filled with Longs of the form xRGB
*	Used by VDI in vs_colour
VsetRGB	MACRO INDEX,COUNT,ARRAY
	TEXT
	move.l	\3,-(sp)
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#vsetrgb,-(sp)
	trap	#XBIOS
	lea	10(sp),sp
	ENDM	

* Use Setscreen - see associated Info in Setscreen
*	FALCON ONLY FOR MODE (RES>2)
Vsetscreen	MACRO	log,phys,res,mode
		TEXT
		Setscreen \1,\2,\3,\4
		ENDM

* Set Video Sync Clocks
*	FALCON ONLY
*	see equates.i
*	Bit 0 - Set for External Clock
*	Bit 1 - Set for External Vsync
*	Bit 2 - Set for External Hsync
Vsetsync	MACRO	Sync_code
	TEXT
	move.w	\1,-(sp)
	move.w	#vsetsync,-(sp)
	trap	#XBIOS
	addq.w	#4,sp
	ENDM

* Wait for VBLANK Sync
Vsync	MACRO
	TEXT
	move.w	#vsync,-(sp)
	trap	#XBIOS
	addq.w	#2,sp
	ENDM

* SOUND ROUTINES
****************
* All ST's (and up) have Yamaha YM-2149 or General Instruments AY-3-8190
* Programmable Sound Generator.
* ST's @ $ffff8800 for register to read/write, $ffff8802 for value of register
* Should use Giaccess for read/writes

* Get/Set Play & Record Enable/Disable
*		FALCON ONLY
*		see equates.i for Modes
*		Mode = -1 means get current Mode
*		Bit 0 - Set for Play Enable
*		Bit 1 - Set for Play Repeat
*		Bit 2 - Set for Record Enable
*		Bit 3 - Set for Record Repeat
*	Sound system has 32 byte FIFO Buffer
*	If Software recording and Record Enable Bit not Cleared,
*	then Clear Bit to Flush Buffer.
Buffoper	MACRO	mode
		TEXT
		move.w	\1,-(sp)
		move.w	#buffoper,-(sp)
		trap	#XBIOS
		addq.w	#4,sp
		ENDM	d0.l=0 or Current Mode Settings

* Get Sound Buffer Pointers
*		FALCON ONLY
*		see equates.i
*		Buffer_Table must have room for 4 longs
*		These are filled by the call
*		+$00 Current Play Position
*		+$04 Current Record Position
*		+$08 Reserved
*		+$0C Reserved
Buffptr		MACRO	Buffer_Table
		TEXT
		move.l	\1,-(sp)
		move.w	#buffptr,-(sp)
		trap	#XBIOS
		addq.w	#6,sp
		ENDM

* Configure Sound Switch Matrix
*		FALCON ONLY
*		Source=	0 - DMA Playback
*			1 - DSP Transmit
*			2 - External Input (DSP Port)
*			3 - ADC (Microphone Input and/or PSG chip)
*		Note: Standard ST Sound (PSG) goes through ADC
*		Dest	Bit 0 - DMA Record
*			Bit 1 - DSP Receive
*			Bit 2 - External Output	(DSP Port)
*			Bit 3 - DAC (Headphones and/or Speaker)
*		Clock =	0 - Internal 25.175MHz
*			1 - External Clock (through DSP Port)
*			2 - Internal 32MHz
*		Prescale - Table given is for 25.175MHz Clock
*			32MHz Clock not allowed for CODEC / DMA
*			Clock is /256 then /(Prescale+1)
*			* means not allowed for CODEC / DMA and will Mute Codec
*			 0	uses /1280*, /640, /320 or /160 set in Soundcmd()
*			 1	/512	49.170KHz
*			 2	/768	32.780KHz
*			 3	/1024	24.585KHz
*			 4	/1280	19.668KHz
*			 5	/1536	16.390KHz
*			 6	/1792	14.049KHz *
*			 7	/2048	12.292KHz
*			 8	/2304	10.927KHz *
*			 9	/2560	 9.834KHz
*			10	/2816	 8.940KHz *
*			11	/3072	 8.195KHz
*			12	/3328	 7.565KHz *
*			>12 will Mute the CODEC until Reset with Sndstatus()
*			13		 7.14 KHz *
*			14		 6.66 KHz *
*			15		 6.25 KHz *
*		Protocol = 0	Enable Handshaking
*		           1	Disable Handshaking
Devconnect	MACRO	source,dest,clock,prescale,protocol
		TEXT
		move.w	\5,-(sp)
		move.w	\4,-(sp)
		move.w	\3,-(sp)
		move.w	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#devconnect,-(sp)
		trap	#XBIOS
		lea	12(sp),sp
		ENDM	d0.l = ?

* Set Yamaha Sound Chip to Play command stream
*	Commands $00-$0f,x	Put next byte in sound register 0-15
*	Command  $80,x		Put next byte in temporary register
*	Command  $81,x,y,z	Put temp reg into reg x
*				add signed value of y to temp reg
*				until temp=z
*	Commands $82-$ff,x	stop if x=0
*				else wait for x timer ticks (always 50Hz)
Dosound	MACRO	command_ptr
	TEXT
	move.l	\1,-(sp)
	move.w	#dosound,-(sp)
	trap	#XBIOS
	addq.w	#6,sp
	ENDM

* Isolate DSP Tx/Rx ports from Sound Switch Matrix
*		1 - Connect Port
*		0 - Disconnect Port
Dsptristate	MACRO	Tx_on,Rx_on
		TEXT
		move.w	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#dsptristate,-(sp)
		trap	#XBIOS
		addq.w	#6,sp
		ENDM	d0.l=?
		
* Read/Write to Yamaha Sound Chip Register
*	register number is $0-$F to read, add $80 to register_num to write
*	Note: data is byte sized
*	Don't use for Register 14, use On/Offgibit
*	Register 15 is Parallel Port data (I/O)
Giaccess	MACRO	data, register
		TEXT
		move.w	\2,-(sp)
		clr.w	-(sp)
		move.b	\1,1(sp)
		move.w	#giaccess,-(sp)
		trap	#XBIOS
		addq.w	#6,sp		;and this?
		ENDM	d0.b=register value

* SYSTEM ROUTINES
*****************
* 200Hz System clock interrupt available - see traps.i
* timer handoff vector available - see equates.i
* OS variables - see timer_ms, vblsem, nvbls, vblqueue, vbclock & frclock
* in equates.i
* also see savptr, sav_context, _hz_200, the_env, _sysbase, _shell_p
* end_os and exec_os
* see Post mortem dump area for system crash info - in equates.i

* Disable MFP 68901 Interrupt Vector
*	- for normally disabled, + for normally enabled
*	Int 0-	Port Bit 0	Parallel Port Busy
*	Int 1+	Port Bit 1	RS-232 Data Carrier Detect
*	Int 2+	Port Bit 2	RS-232 Clear To Send
*	Int 3-	Port Bit 3	Blitter Chip - Operation Finished
*	Int 4-	Timer D		RS-232 Baud Rate Generator
*	Int 5+	Timer C		System Clock (200Hz)
*	Int 6+	Port Bit 4	KBD and MIDI ACIA data request
*	Int 7-	Port Bit 5	Floppy/DMA port data request
*	Int 8-	Timer B		HBlank Counter
*	Int 9+	USART		RS-232 Tx Error
*	Int 10+	USART		RS-232 Tx Buffer Empty
*	Int 11+	USART		RS-232 Rx Error
*	Int 12+	USART		RS-232 Rx Buffer Full
*	Int 13-	Timer A		Spare (for User Apps)/STE uses this
*	Int 14-	Port Bit 6	RS-232 Ring Indicator
*	Int 15-	Port Bit 7	Monochrome Monitor Detect
Jdisint	MACRO	interrupt_num
	TEXT
	move.w	\1,-(sp)
	move.w	#jdisint,-(sp)
	trap	#XBIOS
	addq.w	#4,sp
	ENDM	

* Enable MFP 68901 Interrupt Vector
*	See Jdisint for info
Jenabint	MACRO	interrupt_num
	TEXT
	move.w	\1,-(sp)
	move.w	#jenabint,-(sp)
	trap	#XBIOS
	addq.w	#4,sp
	ENDM	

* Get Device Vector Table
*	The addresses of IKBD & MIDI interrupt handlers
*	see equates.i for structure and purpose
*	used for any interrupt driven signal - joystick, mouse, midi, etc
Kbdvbase	MACRO
	TEXT
	move.w	#kbdvbase,-(sp)
	trap	#XBIOS
	addq.w	#2,sp
	ENDM	d0.l=pointer to vector structure

* Set MFP Interrupt Vector
*	Interrupt numbers = 0-15
*	Old Vector address is lost
Mfpint	MACRO	interrupt_num,Vector_addr
	TEXT
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#mfpint,-(sp)
	trap	#XBIOS
	addq.w	#8,sp
	ENDM	

* Clear bit on Yamaha Sound Chip Port A
*	Bit 0 - Floppy Disk Side 1 Select
*	Bit 1 - Floppy Disk Drive A Select
*	Bit 2 - Floppy Disk Drive B Select
*	Bit 3 - RS-232 RTS
*	Bit 4 - RS-232 DTR
*	Bit 5 - Centronics Strobe Line
*	Bit 6 - General Purpose Output/Used on STE
*	Bit 7 - Reserved
Offgibit	MACRO	bit_number
	TEXT
	move.w	\1,-(sp)
	move.w	#offgibit,-(sp)
	trap	#XBIOS
	addq.w	#4,sp	
	ENDM	

* Set bit on Yamaha Sound Chip Port A
*	See Offgibit details
Ongibit	MACRO	bit_number
	TEXT
	move.w	\1,-(sp)
	move.w	#ongibit,-(sp)
	trap	#XBIOS
	addq.w	#4,sp	
	ENDM	

* Throw away AES and free any AES memory
*	if aes present, throw away & Reboot
*	else return!
Puntaes	MACRO
	TEXT
	move.w	#puntaes,-(sp)
	trap	#XBIOS
	addq.w	#2,sp
	ENDM

* Get/Set exception vector
*	Vector Address = -1 for get vector address
*	remember to restore old vector when finished
*	0-$ff	standard 680x0 exception vectors
*	$100	System timer vector
*	$101	Critical Error Handler
*	$102	Process Termination Handler
*	$103-107	Reserved
*	$200-$ffff	reserved for OEM use - not available in BIOS
Setexec	MACRO	Vector_num,new_addr
	TEXT
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#setexec,-(sp)
	trap	#BIOS
	addq.w	#8,sp
	ENDM	D0.L=Old Vector Address

* Run subroutine in SUPER mode
*	Need to be in Super to Look at Adresses<$800 or >$FF80000
*	Creates Bus Error otherwise (2 Bombs)
*	end code with rts
*	NO BIOS OR GEMDOS CALLS
Supexec	MACRO	subroutine_address
	TEXT
	move.l	\1,-(sp)
	move.w	#supexec,-(sp)
	trap	#XBIOS
	addq.w	#6,sp
	ENDM

* Set User/Supervisor mode
*	Need to be in Super to Look at Adresses<$800 or >$FF80000
*	Creates Bus Error otherwise (2 Bombs)
*	mode=(-)1	returns 0 if in user mode & (-)1 if in super mode
*	mode=0		switch modes using current stack 
*			and return old stack of new mode
*	mode=new_stack  switches modes with new_stack used as super stack
*			and returns old stack of new mode
*	when going to super mode, get old super stack
*	when going to user mode, set mode to old super stack
*	RESTORE SUPER STACK BEFORE PROCESS TERMINATES
Super	MACRO	stack or 0 or 1
	TEXT
	move.l	\1,-(sp)
	move.w	#super,-(sp)
	trap	#GEMDOS
	addq.w	#6,sp
	ENDM	

* Get GEMDOS version number
*	$0d00	v 0.13 - disk based
*	$1300	v 0.19 - ROM & Mega TOS
*	$1500	v 0.21 - Rainbow & STE TOS
*	$1700	v 0.23 - STE TOS v1.62
*	$1900	v 0.25 - MegaSTE & TT TOS
Sversion	MACRO
	TEXT
	move.w	#s_version,-(sp)
	trap	#GEMDOS
	addq.w	#2,sp
	ENDM	d0.w=version number (low/high)

* Get system timer tick interval (in milliseconds)
*	normally 20
*	compare with system timer actual value passed for
*	measure of system overload
Tickcal	MACRO
	TEXT
	move.w	#tickcal,-(sp)
	trap	#BIOS
	addq.w	#2,sp
	ENDM	D0.L=milliseconds/timer tick (20)

* Set timer registers
*	Timer A is for user use
*	Master clock is 2,457,600Hz
*	timer 0-3 = MFP 68901 timer A-D
*	control is timer control register setting - see equates.i
*	data put in timer's data register
*	vector points to interrupt handler
*	TIMER A - Used only for applications
*	TIMER B - Graphics - Hblank, Sync, etc
*	TIMER C - 200Hz System Timer
*	TIMER D - RS232 Baud Rate - but interrupt free for use
Xbtimer	MACRO	timer,control,data,vector
	TEXT
	move.l	\4,-(sp)
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#xbtimer,-(sp)
	trap	#XBIOS
	lea	12(sp),sp
	ENDM	

* TIME AND DATE ROUTINES
************************
*	Time and Date formats are same as on Disks
*	GEMDOS Clock Runs under Interrupt
*	XBIOS Clock is Hardware
*	GEMDOS Clock may Lose Time
*	GEMDOS Clock updated from XBIOS Clock at end of each program
*		ONLY IN BLITTER TOS AND LATER

Day	MACRO	date
	and.w	#31,\1
	ENDM

Hours	MACRO	time
	lsr.w	#11,\1
	and.w	#31,\1
	ENDM

Minutes	MACRO	time
	lsr.w	#5,\1
	and.w	#63,\1
	ENDM

Month	MACRO	date
	lsr.w	#5,\1
	and.w	#15,\1
	ENDM

Seconds	MACRO	time
	and.w	#31,\1
	lsl.w	#1,\1
	ENDM

Year	MACRO	date
	lsr.w	#8,\1
	lsr.w	#1,\1
	and.w	#$ff,\1
	add.w	#1980,\1
	ENDM	

Set_date	MACRO	DAY.w,MONTH.w,YEAR.w
	* GEMDOS CLOCK ONLY
	IFC	'd0','\1'
	FAIL	SET DATE USES D0
	ENDC
	IFC	'd0','\2'
	FAIL	SET DATE USES D0
	ENDC
	IFC	'd0','\3'
	FAIL	SET DATE USES D0
	ENDC
	move.w	\3,d0
	sub.w	#1980,d0
	lsl.w	#4,d0
	and.w	#15,\2
	or.w	\2,d0
	lsl.w	#5,d0
	and.w	#31,\1
	or.w	\1,d0
	Tsetdate	d0

Set_time	MACRO	HOURS.w,MINUTES.w,SECONDS.w
	* GEMDOS CLOCK ONLY
	IFC	'd0','\2'
	FAIL	SET TIME USES D0
	ENDC
	IFC	'd0','\3'
	FAIL	SET TIME USES D0
	ENDC
	move.w	\3,d0
	lsl.w	#6,d0
	and.w	#63,\2
	or.w	\2,d0
	lsl.w	#5,d0
	lsr.w	#1,\1
	and.w	#31,\1	;bi-seconds
	or.w	\1,d0
	lsl.w	#1,\1
	Tsettime	d0
	ENDM

* Get KBD time & date (or RTC in Mega's) - Hardware Clock
*	date in high word
*	time in low word - DOS Format
*	bits are yyyyyyymmmmddddd hhhhhmmmmmmsssss
*	s=seconds/2 (0-29)
Gettime	MACRO
	move.w	#gettime,-(sp)
	trap	#XBIOS
	addq.w	#2
	ENDM	d0.l=date.w/time.w in DOS format

* Set KBD time & date (or RTC in mega's) - Hardware Clock
*	date in high word
*	time in low word - DOS Format
*	bits are yyyyyyymmmmddddd hhhhhmmmmmmsssss
*	s=seconds/2 (0-29)
Settime	MACRO	date&time
	move.w	#settime,-(sp)
	trap	#XBIOS
	addq.w	#2
	ENDM	

* Get date - Software Clock
*	bits 0-4	Day	(1-31)
*	bits 5-8	Month	(1-12)
*	bits 9-15	Year-1980 (0-119)
Tgetdate	MACRO
	move.w	#t_getdate,-(sp)
	trap	#GEMDOS
	addq.w	#2,sp
	ENDM	d0.w=date

* Get time - Software Clock
*	bits 0-4	Seconds/2	(0-29)
*	bits 5-10	Minutes		(0-59)
*	bits 11-15	Hours		(0-23)
Tgettime	MACRO
	move.w	#t_gettime,-(sp)
	trap	#GEMDOS
	addq.w	#2,sp
	ENDM	d0.w=time

* Set date - Software Clock
*	bits 0-4	Day
*	bits 5-8	Month
*	bits 9-15	Year-1980
*	GEMDOS DOES NOT TELL BIOS THAT DATE HAS CHANGED!
*	validity of date not checked!
Tsetdate	MACRO	date
	move.w	\1,-(sp)
	move.w	#t_setdate,-(sp)
	trap	#GEMDOS
	addq.w	#4,sp
	Gemdos_error
	ENDM	d0.l=0 or error code

* Set time - Software Clock
*	bits 0-4	Seconds/2
*	bits 5-10	Minutes
*	bits 11-15	Hours
*	GEMDOS DOES NOT TELL BIOS THAT TIME HAS CHANGED!
Tsettime	MACRO	time
	move.w	\1,-(sp)
	move.w	#t_settime,-(sp)
	trap	#GEMDOS
	addq.w	#4,sp
	Gemdos_error
	ENDM

Weekday	MACRO	date
	move.w	\1,d0
	move.w	d0,d1
	move.w	d1,d2
	Day	d0
	Month	d1
	Year	d2
	cmp.w	#3,d1	;if month<3 then month=month+12;year=year-1
	bge.s	.\@
	add.w	#12,d1
	subq.w	#1,d2
.\@	move.w	d1,d3
	add.w	d1,d3
	add.w	d1,d3	;weekday=3*month
	addq.w	#3,d3	;+3
	ext.l	d3
	divu	#5,d3	;(3*month+3)/5
	add.w	d2,d3	;+year
	lsr.w	#2,d2	
	add.w	d2,d3	;+year/4
	ext.l	d2
	divu	#25,d2
	sub.w	d2,d3	;-year/100
	lsr.w	#2,d2
	add.w	d2,d3	;+year/400
	add.w	d0,d3	;+day
	lsl.w	#1,d1	
	add.w	d1,d3	;+month*2
	addq.w	#1,d3	;+2
	ext.l	d3
	divu	#7,d3
	swap	d3
	addq.w	#1,d3	;answer=1-7 1=Sunday
	move.w	d3,d0	;weekday=weekday%7
	ENDM	Day of Week (1-7) 1=Sunday


