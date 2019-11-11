Example file by Michael Wensley

LIBRARY "gemaes","cdlib"
DEFINT a-z
DIM code$(0)
dim meta&(3)

' uses "inline?" machine code? (Growl,Snarl: Why no inline traps?)

' E.g Machine code: all codes here are 2 bytes long?
' ** is code?
' /< - push the next long onto the stack?
' ?< - push the next word onto the stack?
' N@ - trap #0?
' NA - trap #1?
' NB - trap #2?
' NC - trap #3 ... (goes through the alphabet to? NO - that is trap #15?)
' Nu - return to HBASIC program (rts)?
' #À - copy contents of d0 to the address given by the next long?
'  < - copy next long to d0?
' "< - copy next long to d1?
' ßü - add  the next long to the stack pointer?

' CD-ROM access code.

' start of init code.

cdinit varptr(meta&(0))
IF meta&(1)=0 THEN PRINT "No CD rom?" : END
PRINT "CD-ROM drives installed:",BIN$(meta&(0))
PRINT "Available CD-ROM devices are:";
FOR i=0 TO 25
IF (meta&(0) AND (2^i)) THEN PRINT "Drive "+CHR$(65+i)
NEXT i
d&=meta&(1)
n$=""
DO
	ch=PEEKB(d&)
	IF ch=0 THEN EXIT LOOP
	n$=n$+CHR$(ch)
	INCR d&
LOOP
PRINT "The CD-ROM driver is called?:"+n$

addr$="####"

IF meta&(3)=0 THEN
	PRINT "Extended information unsupported"
ELSE
	PRINT "CD-ROM driver version number:",PEEKW(meta&(3))
	POKEL VARPTR(addr$),PEEKL(meta&(3)+2)
	PRINT "CD-ROM driver identifier:"+addr$
	l2p&=PEEKL(meta&(3)+6)
	PRINT "Logical (drive letter) to physical SCSI/ASCI device id remap table",l2p&
	' end of init code.

	' this following program -> how to get a physical device id given a?
	' drive letter using the remap table provided by the init code?
	drive$="Z"  'change if not installed for drive Z?
	d&=PEEKL(meta&(3)+6)
	id=0
	DO
	IF PEEKB(d&)=ASC(drive$) THEN EXIT LOOP
	INCR id
	INCR d&
	LOOP
	guessid=id-1
	IF guessid<8 THEN
	PRINT "Is this CD-ROM an ACSI device:",guessid
	ELSE
	PRINT "Is this CD-ROM an SCSI device:",guessid-8
	END IF
	' end of table search routine.
END IF


' that follows, fun things to do with CDS???
' using drive Z
drive$="Z"

' firstly, open up a CD - Drive for a session with it.
meta&(0)=0
bioserror cdopen&(ASC(drive$),VARPTR(meta&(0)))

d&=meta&(0)
IF d&<>0 THEN
	' meta&(1),meta&(2),meta&(3) reserved?
	n$=""
	DO
		ch=PEEKB(d&)
		IF ch=0 THEN EXIT LOOP
		n$=n$+CHR$(ch)
		INCR d&
	LOOP
	PRINT "The CD-ROM driver for CD-DRIVE "+drive$+" is called?:"+n$
ELSE
	PRINT "No CD-ROM driver installed for this drive?"
END IF

'perform an (extended) command, in this one.

PRINT "CD-ROM command controller....  meow."
PRINT "Would you like?:"
DO
PRINT "0= get long offset"
PRINT "1= Pause audio cd"
PRINT "2= unpause audio cd"
PRINT "3= play cd using msf"
PRINT "4= play cd using ti"
PRINT "5= read cd table of contents."
PRINT "6= read an entry in the table of contents."
PRINT "7= power off CDdrive motor"
PRINT "8= power on CDdrive motor"
PRINT "9= eject cd."
PRINT "10= set CD volume"
PRINT "11= read channel information"
PRINT "12= read mode 2 sectors"
PRINT "13= read mode 1 sectors"
PRINT "14= lock eject button"
PRINT "15= unlock eject button"
PRINT "16= control the audio settings"
PRINT "17= read the 'Digital Audio' 'red book' sectors"
PRINT "19= read the media catalog number"
PRINT "20= read the track recording code"
PRINT "777= stop audio play back"

DO
INPUT command
IF command=777 THEN bioserror cdstopaudio&(ASC(drive$))
LOOP UNTIL command<777

IF command=0 THEN meta&(0)=0
IF command=3 THEN
	INPUT "Start minute",sm
	INPUT "Start second",ss
	INPUT "Start frame ",sf
	INPUT "End   minute",em
	INPUT "End   second",es
	INPUT "End   frame ",ef
	meta&(0)=0
	meta&(1)=0
	POKEB VARPTR(meta&(0))+0,sm
	POKEB VARPTR(meta&(0))+1,ss
	POKEB VARPTR(meta&(0))+2,sf
	POKEB VARPTR(meta&(0))+3,em
	POKEB VARPTR(meta&(1))+0,es
	POKEB VARPTR(meta&(1))+1,ef
END IF
IF command=4 THEN
	meta&(0)=0
	INPUT "Start track",st
	INPUT "Start index",si
	INPUT "End.. track",et
	INPUT "End.. index",ei
	POKEB VARPTR(meta&(0))+0,st
	POKEB VARPTR(meta&(0))+1,si
	POKEB VARPTR(meta&(0))+2,et
	POKEB VARPTR(meta&(0))+3,ei
END IF
IF command=5 THEN
	'uses one word.
	meta&(0)=0
END IF
IF command=6 THEN
	meta&(0)=0
	meta&(1)=0
	meta&(2)=0
	meta&(3)=0
	INPUT "Entry for track: or &HAA",tr
	PRINT tr
	INPUT "1=LBA 2=MSF",fm
	POKEB VARPTR(meta&(0))+0,tr
	POKEB VARPTR(meta&(0))+1,fm
END IF

IF command=10 THEN
	' uses one long
	PRINT "Set volume level &HFFFFFFFF"
	PRINT "                   ||||||-- channel 3"
	PRINT "                   ||||---- channel 2"
	PRINT "                   ||------ channel 1"
	PRINT "                   -------- channel 0"
	INPUT "Set volume:",meta&(0)
END IF
IF command=11 THEN
	meta&(0)=0
	meta&(1)=0
	meta&(2)=0
	meta&(3)=0
	INPUT "1=LBA 2=MSF",tr
	POKEB VARPTR(meta&(0)),tr
END IF

IF (command=12) OR (command=13) OR (command=17) THEN
	SELECT CASE command
	CASE 12
	s$=STRING$(2336,0)
	CASE 13
	s$=STRING$(2048,0)
	CASE 17
	s$=STRING$(2352,0)
	END SELECT
	PRINT "Sector length",LEN(s$)
	INPUT "Choose a logical block address",meta&(0)
	meta&(1)=SADD(s$)
	meta&(2)=LEN(s$)

	'meta&(0)= 'logical block address (on the cd)
	'meta&(1)= 'buffer pointer (in the computer's memory)
	'meta&(2)= 'number of bytes to read (either 2336 or 2048)
	' command=12 mode 2 sectors are 2336 bytes long?
	' command=13 mode 1 sectors are 2048 bytes long?
	' command=17 red book digital audio sectors are 2352 bytes long?
END IF
IF command=16 THEN
	PRINT "Control audio settings:"
	meta&(0)=0
	meta&(1)=0
	meta&(2)=0
	meta&(3)=0
	INPUT "0= enquire otherwise set",m
	POKEW VARPTR(meta&(0)),m
	FOR c=0 TO 3
		PRINT "Channel "+STR$(c)+" selection"; : INPUT s
		PRINT "Channel "+STR$(c)+" volume"; : INPUT v
		POKEB VARPTR(meta&(0))+2+2*c,s
		POKEB VARPTR(meta&(0))+3+2*c,v
	NEXT c
END IF
IF command=19 THEN
	s$=STRING$(24,0)
END IF
IF command=20 THEN
	INPUT "Recording code for which track?",t
	s$=CHR$(t)+STRING$(25,0)
END IF
IF command>20 THEN EXIT LOOP

magic$="FCTL" 'fcntl?
magic&=PEEKL(VARPTR(magic$))

dat&=0
SELECT CASE command
CASE 19
	recode&=cdioctl&(ASC(drive$),magic&,command,VARPTR(s$))
CASE 20
	recode&=cdioctl&(ASC(drive$),magic&,command,VARPTR(s$))
CASE ELSE
	recode&=cdioctl&(ASC(drive$),magic&,command,VARPTR(meta&(0)))
END SELECT

IF recode&=0 THEN
	PRINT "Done."
	SELECT CASE command
	CASE 0 : PRINT "The block number is:",meta&(0)
	CASE 4 : PRINT "Play",HEX$(meta&(0))
	CASE 5 : PRINT "First track on cd:",PEEKB(VARPTR(meta&(0))+0)
					 PRINT "Last  track on cd:",PEEKB(VARPTR(meta&(0))+1)
	CASE 6 : cd=PEEKW(VARPTR(meta&(0))+2)
		PRINT "The SUBQ channel encodes ";
		c=cd AND &HF000
		SELECT CASE c
		CASE &H0000 : PRINT "nothing?"
		CASE &H1000 : PRINT "position?"
		CASE &H2000 : PRINT "MCN?"
		CASE &H3000 : PRINT "ISRC?"
		CASE ELSE : PRINT "unknown/reserved?",HEX$(cd)
		END SELECT
		IF cd AND &B100000000 THEN PRINT "Audio with pre-emphasis?"
		IF cd AND &B1000000000 THEN PRINT "Digital copy permitted?"
		IF cd AND &B10000000000 THEN PRINT "This is a (filesystem) Data track?" ELSE PRINT "This may be an audio (music) track?"
		IF cd AND &B100000000000 THEN PRINT "Four channels?"
		PRINT "Data storage mode:",cd AND &HFF
		PRINT "Track start?:",meta&(1)
		PRINT "Someting else?:",meta&(2)
		PRINT "Length of this track: Units valid in MSF mode?"
		PRINT "Hours?",PEEKB(VARPTR(meta&(2))+0)
		PRINT "Minutes?",PEEKB(VARPTR(meta&(2))+1)
		PRINT "Seconds",PEEKB(VARPTR(meta&(2))+2)
		PRINT "Partseconds?",PEEKB(VARPTR(meta&(2))+3)
		INPUT "Press return to continue",r$
	CASE 10
		PRINT "Volume level set &H"+HEX$(meta&(0))
		PRINT "                   ||||||-- channel 3"
		PRINT "                   ||||---- channel 2"
		PRINT "                   ||------ channel 1"
		PRINT "                   -------- channel 0"
	CASE 11
		PRINT "Format 1=LBA 2=MSF",PEEKB(VARPTR(meta&(0)))
		PRINT "Audio status ";
		au=PEEKB(VARPTR(meta&(0))+1)
		SELECT CASE au
		CASE 0000 : PRINT "unsupported?"
		CASE &H11 : PRINT "Playing audio"
		CASE &H12 : PRINT "Paused audio"
		CASE &H13 : PRINT "Successfully finished audio play"
		CASE &H14 : PRINT "Error stopped audio play"
		CASE &H15 : PRINT "No current audio status to give"
		CASE ELSE : PRINT "Unknown / Future expansion code"
		END SELECT
		cd=PEEKW(VARPTR(meta&(0))+2)
		c=cd AND &HF0
		PRINT "Reserved",(cd AND &HFF00)/&H100
		PRINT "The SUBQ channel encodes ";
		SELECT CASE c
		CASE &H00 : PRINT "nothing?"
		CASE &H10 : PRINT "position?"
		CASE &H20 : PRINT "MCN?"
		CASE &H30 : PRINT "ISRC?"
		CASE ELSE : PRINT "unknown/reserved?",HEX$(cd)
		END SELECT
		IF cd AND &B1 THEN PRINT "Audio with pre-emphasis?"
		IF cd AND &B10 THEN PRINT "Digital copy permitted?"
		IF cd AND &B100 THEN PRINT "This is a (filesystem) Data track?" ELSE PRINT "This may be an audio (music) track?"
		IF cd AND &B1000 THEN PRINT "Four channels?"
		PRINT "Current track:",PEEKB(VARPTR(meta&(1))+0)
		PRINT "Current index:",PEEKB(VARPTR(meta&(1))+1)
		PRINT "Absolute (to cd start   ) play address",PEEKL(VARPTR(meta&(1))+2)
		PRINT "From CD start: Units valid in MSF mode?"
		PRINT "Hours?  ",PEEKB(VARPTR(meta&(1))+2)
		PRINT "Minutes?",PEEKB(VARPTR(meta&(1))+3)
		PRINT "Seconds?",PEEKB(VARPTR(meta&(1))+4)
		PRINT "PartSeconds?",PEEKB(VARPTR(meta&(1))+5)
		PRINT "Relative (to track start) play address",PEEKL(VARPTR(meta&(1))+6)
		PRINT "From track start: Units valid in MSF mode?"
		PRINT "Hours?",PEEKB(VARPTR(meta&(1))+6)
		PRINT "Minutes?",PEEKB(VARPTR(meta&(1))+7)
		PRINT "Seconds?",PEEKB(VARPTR(meta&(1))+8)
		PRINT "PartSeconds?",PEEKB(VARPTR(meta&(1))+9)

		INPUT "Press return to continue",r$
	CASE 16
		PRINT "Found:"
		FOR c=0 TO 3
		s=PEEKB(VARPTR(meta&(0))+2+2*c)
		v=PEEKB(VARPTR(meta&(0))+3+2*c)
		PRINT "Channel "+STR$(c)+" selection",s
		PRINT "Channel "+STR$(c)+" volume",v
		NEXT c
	CASE 19
		au=ASC(MID$(s$,1,1))
		PRINT "Audio status ";
		SELECT CASE au
		CASE 0000 : PRINT "unsupported?"
		CASE &H11 : PRINT "Playing audio"
		CASE &H12 : PRINT "Paused audio"
		CASE &H13 : PRINT "Successfully finished audio play"
		CASE &H14 : PRINT "Error stopped audio play"
		CASE &H15 : PRINT "No current audio status to give"
		CASE ELSE : PRINT "Unknown / Future expansion code"
		END SELECT
		PRINT "Media catalog number?:"+MID$(s$,2,23)
	CASE 20
		PRINT "Track number",ASC(MID$(s$,1,1))
		au=ASC(MID$(s$,2,1))
		PRINT "Audio status ";
		SELECT CASE au
		CASE 0000 : PRINT "unsupported?"
		CASE &H11 : PRINT "Playing audio"
		CASE &H12 : PRINT "Paused audio"
		CASE &H13 : PRINT "Successfully finished audio play"
		CASE &H14 : PRINT "Error stopped audio play"
		CASE &H15 : PRINT "No current audio status to give"
		CASE ELSE : PRINT "Unknown / Future expansion code"
		END SELECT

		PRINT "Track record code?:"+MID$(s$,3,23)
	END SELECT
ELSE
	bioserror recode&
END IF


LOOP



' lastly, close the CD - Drive to end the session with it.
bioserror cdclose&(ASC(drive$))

END

SUB bioserror(BYVAL recode&)
LOCAL j
IF recode&>0 THEN PRINT "Returned:",recode& : EXIT SUB
SELECT CASE recode&
	CASE 0 : PRINT "OK?"
	CASE -1 : PRINT "generic error"
	CASE -2 : PRINT "drive not ready"
	CASE -3 : PRINT "unknown command"
	CASE -4 : PRINT "Cyclic Redundancy Check error?"
	CASE -5 : PRINT "bad request"
	CASE -6 : PRINT "seek error - (dirty CD?)"
	CASE -7 : PRINT "unknown media"
	CASE -8 : PRINT "sector not found - (very dirty CD?"
	CASE -9	: PRINT "out of paper (out of media?)"
	CASE -10 : PRINT "write fault (CD can't be written to?)"
	CASE -11 : PRINT "read fault (check connections, clean cd?)"
	CASE -13 : PRINT "write protected"
	CASE -14 : PRINT "media change (CD has been changed, drive busy reconfiguring to new CD?)"
	CASE -15 : PRINT "unknown device"
	CASE -16 : PRINT "bad sectors on format (dirty CD?)"
	CASE -17 : PRINT "insert other disc request"
	CASE -32 : PRINT "invalid function"
CASE ELSE
	j=form_error((0-recode&)-31)
END SELECT
END SUB
