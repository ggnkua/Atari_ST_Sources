;
; TOS macros library: GEMDOS, BIOS, XBIOS and LINE A.
; Author : P-Jean Goulier.
;
; For each macro : 1 - A little explain.
;		   2 - Syntax.
;		   3 - Return.

;
; GEMDOS.
;


pterm0	MACRO			; To end a program.
				; pterm0
	clr	-(sp)
	trap	#1
	ENDM

cconin	MACRO			; To wait for a key with echo.
				; cconin
				; D0 = char.
				
	move	#1,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

cconout MACRO			; To display a character.
				; cconout char
	move	\1,-(sp)
	move	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM

cauxin	MACRO			; To get a character on RS232.
				; cauxin
				; D0 = char.
	move	#3,-(sp)	
	trap	#1
	addq.l	#2,sp
	ENDM
	
cauxout MACRO			; To send a character on RS232.
				; cauxout char
	move	\1,-(sp)
	move	#4,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM
	
cprnout MACRO			; To print a character on Centronics
				; cprnout char
				; D0 = -1 if char printed.
				; D0 = 0  if problem (30s).

	move	\1,-(sp)
	move	#5,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM
	
crawio	MACRO			; Print / Inkey.
				; crawio #$FF => Inkey
				; crawio  'X' => Print
	move	\1,-(sp)
	move	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM
	
crawcin MACRO			; To wait for a character without echo.
				; crawcin
	move	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

cconws	MACRO			; To display a string (end=0).
				; cconws string
	move.l	\1,-(sp)
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM
	
cconrs	MACRO			; To input a line.
				; cconrs buffer
				; Before input : 1st byte Buffer = Nb char. maxi.
				; After input  : 2nd byte Buffer = Nb char. send.
				; String from 3rd byte.
	move.l	\1,-(sp)
	move	#$A,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM
	
cconis	MACRO			; To test the Keyboard buffer.
				; cconis
				; D0 = -1 => character available.
				; D0 = 0  => no character.

	move	#$B,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM
	
dsetdrv MACRO			; To set the current drive.
				; dsetdrv dev
				; A = 0, B = 1, etc.

	move	\1,-(sp)
	move	#$E,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM
	
cprnos	MACRO			; To test the Centronics port.
				; cprnos
				; D0 = -1 if available.

	move	#$11,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM
	
cauxis	MACRO			; To test the RS232 availability (reception).
				; cauxis
				; D0 = 0 if available.
	move	#$12,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM
	
cauxos	MACRO			; To test the RS232 availability (emission).
				; cauxos
				; D0 = 0 if available.
	move	#$13,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

dgetdrv MACRO			; To get the current drive.
				; dgetdrv
				; => D0 : drive code (0=A, B=1, etc).
	move	#$19,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM
	
fsetdta MACRO			; To set the DTA buffer.
				; fsetdta dta
				; DTA buffer must be done like :
				; dta:	 ds.b	21	(R‚served)
				; attr:  ds.b	1
				;	 even
				; hour: ds.w	1
				; date:  ds.w	1
				; size:  ds.l	1
				; name:	 ds.b	14	
	move.l	\1,-(sp)
	move	#$1a,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM
	
super_mode	MACRO		; Supervisor mode.
				; super_mode
				; D0 = usp
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM
	
user_mode	MACRO		; User mode.
				; user_mode usp
	move.l	\1,-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM
	
tgetdate	MACRO		; To get the system date.
				; tgetdate
				; D0 = date format :
				;      bits 0 - 4  => day.
				;      bits 5 - 8  => month.
				;      bits 9 - 15 => year (0=1980).

	move	#$2A,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM
	
tsetdate	MACRO		; To set the system date.
				; tsetdate date
				; D0 = -1 if error.
				; See tgetdate about format.

	move	\1,-(sp)
	move	#$2B
	trap	#1
	addq.l	#4,sp
	ENDM
	
tgettime	MACRO		; To get the system hour.
				; tgettime
				; D0 = hour format :
				;      bits 0 - 4   => seconds.
				;      bits 5 - 10  => minutes.
				;      bits 11 - 15 => hours.

	move	#$2C,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM
	
tsettime	MACRO		; To set sytem hour.
				; tsettime date
				; D0 = -1 if error.
				; See tgettime about format.

	move	#$2D,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

fgetdta MACRO			; To get the DTA pointer.
				; fgetdta
				; D0 = ptr

	move	#$2F,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM
	
sversion	MACRO		; To get the GEMDOS version.
				; sversion
				; D0 = version

	move	#$30,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM
	
ptermres MACRO			; To end a resident program.
				; ptermres size
	clr	-(sp)
	move.l	\1,-(sp)
	move	#$31,-(sp)
	trap	#1
	ENDM
	
dfree	MACRO			; To get the disk free space.
				; dfree buffer,dev
				; 0 = current drive, 1 = A, 2 = B, etc.
				; Result in buffer 4 LW :
				;	0 => nb free clusters.
				;	1 => nb total clusters.
				;	2 => Cluster size.
				;	3 => nb sect/cluster.

	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#$36,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

dcreate MACRO			; To create a folder.
				; dcreate pathname.
				; D0 = -1 => Error.

	move.l	\1,-(sp)
	move	#$39,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM
	
ddelete MACRO			; To delete a folder.
				; ddelete pathname
				; D0 = -1 => Error.
				; D0 = $FFFFFFCA => The folder contains
				;		    still files

	move.l	\1,-(sp)
	move	#$3A,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM
	
dsetpath	MACRO		; To set a path.
				; dsetpath path
				; D0 = -1 => Error.

	move.l	\1,-(sp)
	move	#$3B,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM
	
fcreate MACRO			; To create a file
				; fcreate name,type
				; Type : Bit 0 => free(0)/prot(1)
				;	     1 => hiden.
				;	     2 => system.
				;	     3 => disk name.
				;	     4 => folder.
				;	     5 => archive.
				; => D0 : error if < 0 or handle.
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#$3C,-(sp)
	trap	#1
	lea	8(sp),sp
	ENDM
			
fopen	MACRO			; To open a file.
				; fopen name,type
				; Type : 0 => Read.
				;	 1 => Write.
				;	 2 => Both.
				; => D0 : error if < 0 or Handle.
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#$3D,-(sp)
	trap	#1
	lea	8(sp),sp
	ENDM
	
fclose	MACRO			; To close a file.
				; fclose hdle
				; => D0 : error if < 0.
	move	\1,-(sp)
	move	#$3E,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM
	
fread	MACRO			; To read a file.
				; fread hdle,count,buffer
				; => D0 : error if < 0.
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#$3F,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM
	
fwrite	MACRO			; To write in a file.
				; fwrite hdle,count,buffer
				; => D0 : error if < 0.
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM
	
fdelete MACRO			; To delete a file.
				; fdelete name
				; => D0 : error if < 0.
	move.l	\1,-(sp)
	move	#$41,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM
	
fseek	MACRO			; To skip byte in a file.
				; fseek offset,hdle,mode
				; Mode : 0 = Start
				;	 1 = actual place.
				;	 2 = End.
				; => D0 : error if < 0.
				;	  Pointer if > 0.
	move	\3,-(sp)
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#$42,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM
	
fattrib MACRO			; To set attributes files.
				; fattrib name,flag,attrib
				; flag : 0 = Read.
				;	 1 = Write.
				; attrib : See fcreate.
				; D0 : error if < 0.
	move	\3,-(sp)
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#$43,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM
	
dgetpath	MACRO		; To get current path.
				; dgetpath device,path
				; => D0 : error if < 0.
	move	\1,-(sp)
	move.l	\2,-(sp)
	move	#$47,-(sp)
	trap	#1
	lea	8(sp),sp
	ENDM
	
malloc	MACRO			; To reserve GEMDOS memory
				; or to ask free space (-1).
				; malloc size
				; => D0 : free space (-1).
				;	  Buffer address.
				;	  Error if < 0.
	move.l	\1,-(sp)
	move	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM
	
mfree	MACRO			; To free a memory block.
				; mfree adr
				; => D0 : error if < 0.
	move.l	\1,-(sp)
	move	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM
	
mshrink MACRO			; To free memory (To shrink for a program).
				; mshrink addr,size
				; => D0 : Error if <> 0.
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	clr	-(sp)
	move	#$4A,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM
	
pexec	MACRO			; To load and/or run a program.
				; Mode 0 : Load & Go => pexec mode,nom,cmd,env
				; Mode 3 : Load => pexec mode,nom,cmd,env
				;	   D0 = Prg addr in RAM.
				; Mode 4 : Go => pexec mode,cmd,adr,env
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#$4B,-(sp)
	trap	#1
	lea	16(sp),sp
	ENDM
	
pterm	MACRO			; To end a program.
				; pterm code.
	move	\1,-(sp)
	move	#$4C,-(sp)
	trap	#1
	ENDM
	
fsfirst MACRO			; To search for a file (1st).
				; fsfirst filename,attrib
				; => D0 = 0 if file not found.
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#$4E,-(sp)
	trap	#1
	lea	8(sp),sp
	ENDM
	
fsnext	MACRO			; To search next files corresponding
				; to the Fsfirst mask.
				; => D0 : <> 0 if file not found.
	move	#$4F,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM
	
frename MACRO			; To rename a file.
				; frename old,new
				; D0 => error if < 0.
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	clr	-(sp)
	move	#$56,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM
	
fdatime MACRO			; To read / write date and hour for a file.
				; fdatime buffer,hdle,flag
				; The file must be open.
				; flag : 0 = read.
				;	 1 = write.
				; buffer : 1 LW contains 1W = hour.
				;			 1W = date.
				; See tgetdate and tgettime about format.
	move	\3,-(sp)
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#$57,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM
	
	
;
; BIOS.
;

getmpb	MACRO			; To get the Memory Parameter Block.
				; getmpb ptr
				; ptr : buffer where 3 LW aim to a memory structure.
	move.l	\1,-(sp)
	clr	-(sp)
	trap	#13
	addq.l	#6,sp
	ENDM
	
bconstat	MACRO		; To test an input device.
				; bconstat dev
				; D0 = 0 if char available.
				; dev : 0 = Centronics (PRT).
				;	1 = RS232 (AUX).
				;	2 = Keybd & screen (CON).
				;	3 = MIDI (MID).
				;	4 = Keybd (IKBD).
				;	5 = Screen.
	move	\1,-(sp)
	move	#1,-(sp)
	trap	#13
	addq.l	#4,sp
	ENDM
	
bconin	MACRO			; To wait for a character from an input device.
				; bconin dev
				; => D0
	move	\1,-(sp)
	move	#2,-(sp)
	trap	#13
	addq.l	#4,sp
	ENDM
	
bconout MACRO			; To send a character to an output device.
				; bconout dev,char
	move	\2,-(sp)
	move	\1,-(sp)
	move	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	ENDM
	
rwabs	MACRO			; To read / write sectors on disk.
				; rwabs flag,buffer,count,sect,dev
				; D0 => error if < 0.
				; flag : 0 = read.
				;	 1 = write.
				; buffer : datas buffer.
				; count : nb sectors.
				; sect : no 1st logic sector.
				; dev : drive.
	move	\5,-(sp)
	move	\4,-(sp)
	move	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#4,-(sp)
	trap	#13
	lea	14(sp),sp
	ENDM
	
setexec MACRO			; Diversion of an exception vector.
				; setexec num,vec
				; D0 => old addr.
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#5,-(sp)
	trap	#13
	lea	8(sp),sp
	ENDM
	
tickcal MACRO			; To get time (ms) between two system clock calls.
				; tickcal
				; D0 = time (ms) (50 Hz = 20 ms).
	move	#6,-(sp)
	trap	#13
	addq.l	#2,sp
	ENDM

getbpb	MACRO			; To get the Bios Parameter Block.
				; getbpb dev
				; D0 = ptr BPB.
				; BPB :
				;	1W : nb byte/sect.
				;	1W : nb sect/clust.
				;	1W : nb byte/clust.
				;	1W : nb sect/dir.
				;	1W : nb sect/FAT.
				;	1W : no sect 2nd FAT.
				;	1W : no sect 1st data clust.
				;	1W : nb data clust/disk.
				;	1W : 0
	move	\1,-(sp)
	move	#7,-(sp)
	trap	#13
	addq.l	#4,sp
	ENDM
	
bcostat MACRO			; To test an output device.
				; bcostat dev
				; See bconstat.
	move	\1,-(sp)
	move	#8,-(sp)
	trap	#13
	addq.l	#4,sp
	ENDM
	
mediach MACRO			; To test if a floppy disk has been changed.
				; mediach dev
				; D0 = 0 => disk hold.
				;      1 => maybe changed.
				;      2 => changed.
	move	\1,-(sp)
	move	#9,-(sp)
	trap	#13
	addq.l	#4,sp
	ENDM
	
drvmap	MACRO			; To test available disks.
				; drvmap
				; D0 = bit vector to describe available unities.
	move	#$A,-(sp)
	trap	#13
	addq.l	#2,sp
	ENDM
	
getshift	MACRO		; To test / modify shift keys.
				; getshift mode
				; Mode = -1 => read.
				;	  0 => Modification.
				; D0 = vecteur de bits.
				;	bit 0 : Shift right.
				;	bit 1 : Shift left.
				;	bit 2 : CTRL.
				;	bit 3 : ALT.
				;	bit 4 : CAPS LOCK.
				;	bit 5 : CLR/HOME.
				;	bit 6 : INSERT.
				;	bit 7 : Not used.
	move	\1,-(sp)
	move	#$B,-(sp)
	trap	#13
	addq.l	#4,sp
	ENDM
				
	

;
; XBIOS.
;

initmous	MACRO		; To modify mouse vector.
				; initmous type,par,vec
				; typ = 0 : Swith off mouse.
				;	1 : Switch on mouse (relative).
				;	2 : Switch on mouse (absolute).
				;	3 : No used.
				;	4 : Switch on mouse (keybd).
				; par = Parameter block.
				;	1B : topmode => 0 : Y=0 bottom.
				;			1 : Y=0 top.
				;	1B : buttons => "set mouse buttons" IKBD.
				;	1B : xparam  => Scale factors for mouse moves.
				;	1B : yparam
				;
				;	If typ = 2,
				;	1W : xmax    => Max coord.
				;	1W : ymax
				;	1W : wstart  => Mouse origin.
				;	1W : ystart
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	clr	-(sp)
	trap	#14
	lea	12(sp),sp
	ENDM
	
physbase MACRO			; To get screen physic address.
				; => D0.
	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	ENDM
	
logbase MACRO			; To get screen logic address.
				; => D0.
	move	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	ENDM
	
getrez	MACRO			; To get resolution.
				; => D0.
	move	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	ENDM
	
setscreen MACRO 		; To set screen addresses.
				; setscreen log,phys,resol.
	move	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	ENDM
	
setpalette MACRO		; To set palette.
				; setpalette palette.
	move.l	\1,-(sp)
	move	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	ENDM
	
setcolor MACRO			; To set a colour.
				; setcolor coul,RVB.
	move	\2,-(sp)
	move	\1,-(sp)
	move	#7,-(sp)
	trap	#14
	addq.l	#6,sp
	ENDM

floprd	MACRO			; To read sectors.
				; Floprd buffer,dev,sect,trk,face,count
	move	\6,-(sp)
	move	\5,-(sp)
	move	\4,-(sp)
	move	\3,-(sp)
	move	\2,-(sp)
	clr.l	-(sp)
	move.l	\1,-(sp)
	move	#8,-(sp)
	trap	#14
	lea	20(sp),sp
	ENDM
	
flopwr	MACRO			; To write sectors.
				; Flopwr buffer,dev,sect,trk,face,count
	move	\6,-(sp)
	move	\5,-(sp)
	move	\4,-(sp)
	move	\3,-(sp)
	move	\2,-(sp)
	clr.l	-(sp)
	move.l	\1,-(sp)
	move	#9,-(sp)
	trap	#14
	lea	20(sp),sp
	ENDM
	
flopfmt MACRO			; To format a disk track.
				; flopfmt buffer,dev,spt,track,face,inter,virgin
				; D0 : error if < 0.
				; Buffer => 8 Ko for 9 sect/trk.
				; Si D0 = -16 => Bad sector.
				;		 Buffer contains a bad sectors list.
	move	\7,-(sp)
	move.l	#$87654321,-(sp)
	move	\6,-(sp)
	move	\5,-(sp)
	move	\4,-(sp)
	move	\3,-(sp)
	move	\2,-(sp)
	clr.l	-(sp)
	move.l	\1,-(sp)
	move	#$A,-(sp)
	trap	#14
	lea	26(sp),sp
	ENDM
	
iorec	MACRO			; To get a pointer about a circular buffer.
				; iorec dev
				; => D0 = ptr.
	move	\1,-(sp)
	move	#14,-(sp)
	trap	#14
	addq.l	#2,sp
	ENDM
	
rsconf	MACRO			; RS232 Configuration.
				; rsconf baud,ctrl,ucr,rsr,tsr,scr
	move	\6,-(sp)
	move	\5,-(sp)
	move	\4,-(sp)
	move	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#$F,-(sp)
	trap	#14
	lea	14(sp),sp
	ENDM
	
keytbl	MACRO			; New keyboard configuration.
				; keytbl unshift,shift,caps
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move	#$10,-(sp)
	trap	#14
	lea	14(sp),sp
	ENDM
	
random	MACRO			; To get a randomize number.
				; D0 = nb (24 bits.)
	move	#$17,-(sp)
	trap	#14
	addq.l	#2,sp
	ENDM
	
protobt MACRO			; To create a boot sector.
				; protobt buffer,serial,type,flag
	move	\4,-(sp)
	move	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#18,-(sp)
	trap	#14
	lea	14(sp),sp
	ENDM
	
flopver MACRO			; To verify a sector.
				; flopver buffer,dev,sect,track,face,count
				; Buffer must to be aligned on a 1024 multiple.
				; D0 : error if < 0.
	move	\6,-(sp)
	move	\5,-(sp)
	move	\4,-(sp)
	move	\3,-(sp)
	move	\2,-(sp)
	clr.l	-(sp)
	move.l	\1,-(sp)
	move	#$13,-(sp)
	trap	#14
	lea	20(sp),sp
	ENDM
	
scrdmp	MACRO			; Hardcopy.
				; scrdmp
	move	#$14,-(sp)
	trap	#14
	addq.l	#2,sp
	ENDM
	
cursconf	MACRO		; Cursor configuration.
				; cursconf fct,taux
	move	\2,-(sp)
	move	\1,-(sp)
	move	#$15,-(sp)
	trap	#14
	addq.l	#6,sp
	ENDM
	
bioskeys	MACRO		; To reset the keybord.
				; bioskeys
	move	#$18,-(sp)
	trap	#14
	addq.l	#2,sp
	ENDM
	
ikbdws	MACRO			; To send commands to the keyboard processor.
				; ikbdws nb,ptr
	move.l	\1,-(sp)
	move	\2,-(sp)
	move	#$16,-(sp)
	trap	#14
	lea	8(sp),sp
	ENDM
	
dosound MACRO			; To generate sounds under interruption.
				; dosound ptr
	move.l	\1,-(sp)
	move	#$20,-(sp)
	trap	#14
	addq.l	#6,sp
	ENDM
	
kbrate	MACRO			; To set repeat keys.
				; kbrate delay,repeat
	move	\2,-(sp)
	move	\1,-(sp)
	move	#$23,-(sp)
	trap	#14
	addq.l	#6,sp
	ENDM
	
vsync	MACRO			; To wait for a VBL.
				; vsync
	move	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	ENDM
	
supexec MACRO			; To execute a routine in supervisor.
				; supexec adr
	move.l	\1,-(sp)
	move	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	ENDM

	
;
; LINE A.
;

init_linea	MACRO		; Initialisation.
				; => D0 : Parameters address.
	dc.w	$a000
	ENDM
	
mouseoff	MACRO		; Mouse off.
	dc.w	$a00a
	ENDM
	
mouseon MACRO			; Mouse on.
	dc.w	$a009
	ENDM
	
