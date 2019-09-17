*  OFFSETS and EQUATES  *
*    by S.H.Rigby       *
*      Version 1.01     *
*************************

* GENERAL NAMES
***************
LEAVE	EQU	-1

* SYNC CODES
************
EXT_CLOCK	EQU	1
EXT_VSYNC	EQU	2
EXT_HSYNC	EQU	4

* SCREEN MODECODES
******************
* to be AND'ed with value
NUMCOLS		EQU	7	;gives bps value
* to be OR'ed together
VERTFLAG	EQU	256	;INTERLACE ON
STMODES		EQU	128
OVERSCAN	EQU	64
PAL		EQU	32
NTSC		EQU	0
VGA		EQU	16
TV		EQU	0
COL80		EQU	8
COL40		EQU	0
BPS1		EQU	0	;2   COLOURS
BPS2		EQU	1	;4   COLOURS
BPS4		EQU	2	;16  COLOURS
BPS8		EQU	3	;256 COLOURS
BPS16		EQU	4	;TRUE COLOUR

* VT52 ESCAPE CODES
*******************
VT_UP	EQU	'A'	;if on top line, no action
VT_DOWN	EQU	'B'	;if on bottom line, no action
VT_RIGHT	EQU	'C'	;if far right, no action
VT_LEFT	EQU	'D'	;if far left, no action - non-destructive
VT_CLS	EQU	'E'	;clear screen and home cursor
VT_HOME	EQU	'H'	;cursor to top left only
VT_SCROLL_UP	EQU	'I'	;scroll down if at top of screen
VT_CLR_EOS	EQU	'J'	;erase all from cursor (incl) to end of screen
VT_CLR_EOL	EQU	'K'	;erase all from cursor to end of line
VT_INSERT	EQU	'L'	;insert blank line at cursor, all below move down
VT_DELETE	EQU	'M'	;delete current line, move all below up one, blank at bottom
VT_GOTO	EQU	'Y'	ROW+32,COL+32 (rows and cols start at 1)
VT_TEXT_COL	EQU	'b'	REGISTER (0-15)
VT_BACK_COL	EQU	'c'	REGISTER (0-15)
VT_CLR_BOS	EQU	'd'	;erase all from top of screen to cursor (incl)
VT_CURS_ON	EQU	'e'	;hide cursor
VT_CURS_OFF	EQU	'f'	;show cusor
VT_GET_CURS	EQU	'j'	;save current cursor position
VT_SET_CURS	EQU	'k'	;restore cursor to saved position
VT_CLR_LINE	EQU	'l'	;erase current line and move cursor to start of line
VT_CLR_BOL	EQU	'o'	;erase from start of curent line to cursor (incl)
VT_INVERT_ON	EQU	'p'	;reverse video on
VT_INVERT_OFF	EQU	'q'	;reverse video off
VT_WRAP_ON	EQU	'v'	;if at end of line, start new line - scrolls up if at last line
VT_WRAP_OFF	EQU	'w'	;if at end of line, overwrite char
BELL	EQU	07
BACKSPACE	EQU	08
TAB	EQU	09
LF	EQU	10
HT	EQU	11
CLS	EQU	12
CR	EQU	13
ESC	EQU	27

* TEXT CURSOR MODES
*******************
CURS_HIDE	EQU	0
CURS_SHOW	EQU	1
CURS_BLINK	EQU	2
CURS_STEADY	EQU	3
CURS_SET_RATE	EQU	4
CURS_GET_RATE	EQU	5

* DEVICES
*********
PRN	EQU	0
LST	EQU	0
AUX	EQU	1
CON	EQU	2
MIDI	EQU	3
KBD	EQU	4
RAW	EQU	5
MODEM_1	EQU	6	;TT/MEGA_STE/FALCON
MODEM_2	EQU	7	;TT/MEGA_STE (SCC CHANNEL B)
SERIAL_1	EQU	8	;TT (3-WIRE MFP)/MEGA_STE (SCC CHANNEL A)
SERIAL_2	EQU	9	;TT (SCC CHANNEL A)

* PRINTER CONFIGURATION BITS
****************************
P_DOT	EQU	0
P_MONO	EQU	0		;Some show colour as 0
P_ATARI	EQU	0
P_DRAFT	EQU	0
P_PARALLEL	EQU	0
P_FORM	EQU	0
P_DAISY	EQU	1
P_COLOUR	EQU	2	;Some show mono as 2
P_EPSON	EQU	4
P_LQ	EQU	8
P_RS232	EQU	16
P_SHEET	EQU	32

* SHIFTCODE VALUES
******************
R_SHIFT	EQU	1	;BIT 0
L_SHIFT	EQU	2
CTRL	EQU	4
ALT	EQU	8
CAPS_LOCK	EQU	16
ALT_HOME	EQU	32
ALT_INSERT	EQU	64	;BIT 6

* KEY TABLE STRUCTURE
*********************
	RSRESET
Unshift	rs.l	1	;pointers to scancode-to-ascii table
Shift	rs.l	1	;128 bytes in length
Capslock	rs.l	1

* INPUT/OUTPUT RECORD STRUCTURE
*******************************
	RSRESET
Ibuf	rs.l	1	;pointer to buffer
Ibufsiz	rs.w	1	;buffer size
Ibufhd	rs.w	1	;Index to head
Ibuftl	rs.w	1	;Index to tail
Ibuflow	rs.w	1	;Low water mark
Ibufhi	rs.w	1	;High water mark
Obuf	rs.l	1	;pointer to buffer
Obufsiz	rs.w	1	;buffer size
Obufhd	rs.w	1	;Index to head
Obuftl	rs.w	1	;Index to tail
Obuflow	rs.w	1	;Low water mark
Obufhi	rs.w	1	;High water mark

* BAUD RATES
************
BAUD19200	EQU	0
BAUD9600	EQU	1
BAUD4800	EQU	2
BAUD3600	EQU	3
BAUD2400	EQU	4
BAUD2000	EQU	5
BAUD1800	EQU	6
BAUD1200	EQU	7
BAUD600		EQU	8
BAUD300		EQU	9
BAUD200		EQU	10
BAUD150		EQU	11
BAUD134		EQU	12
BAUD110		EQU	13
BAUD75		EQU	14
BAUD50		EQU	15

* FLOW CONTROL
**************
FLOW_OFF	EQU	0
FLOW_SOFT	EQU	1
FLOW_HARD	EQU	2	;rts/cts non functional in pre-blitter roms
FLOW_BOTH	EQU	3

* UCR - RS232 CONTROL
*********************
PARITY_ODD	EQU	0	;BIT 1
PARITY_EVEN1	EQU	2
PARITY_OFF	EQU	0	;BIT 2
PARITY_ON	EQU	4
STOP_BIT_0	EQU	0	;BITS 3 & 4
STOP_BIT_1	EQU	8
STOP_BIT_15	EQU	16
STOP_BIT_2	EQU	24
DATA_BIT_8	EQU	0	;BITS 5 & 6
DATA_BIT_7	EQU	32
DATA_BIT_6	EQU	64
DATA_BIT_5	EQU	96
UCR_CLK_16	EQU	128	;BIT 7 - DIVIDE CLOCK BY 16
UCR_CLK_SYNC	EQU	0

* BIOS PARAMETER BLOCK
**********************
	RSRESET
Recsiz	rs.w	1	;bytes/sector (512)
Clsiz	rs.w	1	;sectors/cluster (2)
Clsizb	rs.w	1	;bytes/cluster (1024)
Rdlen	rs.w	1	;Number of Root Dir Sectors
Fsiz	rs.w	1	;Fat size in sectors/FAT
Fatrec	rs.w	1	;Start sector of 2nd FAT
Datrec	rs.w	1	;Start sector of 1st Data Cluster
Numcl	rs.w	1	;Number of Data Clusters on Disk
Bflags	rs.w	1	;0=12bit FAT
			;1=16bit FAT
* DISK TYPES
************
SSSD	EQU	0	;40 TRACK - SINGLE SIDED SINGLE DENSITY 
DSSD	EQU	1	;40 TRACK - DOUBLE SIDED SINGLE DENSITY
SSDD	EQU	2	;80 TRACK - SINGLE SIDED DOUBLE DENSITY
DSDD	EQU	3	;80 TRACK - DOUBLE SIDED DOUBLE DENSITY

RANDOM_BT	EQU	$01000000	;RANDOM DISK SERIAL NUMBER

* FREE SPACE TABLE
******************
	RSRESET
Free_space	rs.l	1	;free drive space in bytes
Free_cl	rs.l	1	;available clusters
Sector_size	rs.l	1	;sector size in bytes
Cl_size	rs.l	1	;Cluster size in sectors

* MEMORY TYPES (FOR M_XALLOC)
**************
SYS_RAM	EQU	0	;system ram only
ALT_RAM	EQU	1	;alternate ram only
SYS_OR_ALT	EQU	2	;system ram preferred
ALT_OR_SYS	EQU	3	;alternate ram preferred

* MEMORY PARAMETER BLOCK
************************
	RSRESET
Mpb_mfl	rs.l	1	;Memory Free List Pointer
Mpb_mal	rs.l	1	;Memory Allocated List Pointer
Mpb_rover	rs.l	1	;Roving Pointer

* MEMORY DESCRIPTOR - pointed to by Mp_mfl,Mp_mal,Mp_rover
*******************
	RSRESET
Md_link	rs.l	1	;Pointer to next Memory Descriptor (or NULL)
Md_start	rs.l	1	;Start Address of Memory Block
Md_length	rs.l	1	;Length of Memory Block in bytes
Md_own	rs.l	1	;Pointer to Owner's Process Descriptor

* MOUSE MODES
*************
M_DISABLE	EQU	0	;disable mouse
M_RELATIVE	EQU	1	;enable mouse in relative mode
M_ABSOLUTE	EQU	2	;enable mouse in absolute mode
M_KEYCODE	EQU	4	;enable mouse in keycode mode

* MOUSE PARAMETER BLOCK
***********************
	RSRESET
M_topmode	rs.b	1	;0 if Y=0 at bottom
			;1 if Y=0 at top
M_buttons	rs.b	1	;see set mouse buttons keyboard command
M_xparam	rs.b	1	;threshold,scale or delta factors, depending on mode
M_yparam	rs.b	1
M_xmax		rs.w	1	;abs mode only - max x & y positions
M_ymax		rs.w	1
M_xinitial	rs.w	1	;abs mode only - Initial x & y positions
M_yinitial	rs.w	1	

* RWABS MODES
*************
READ	EQU	0	;BIT 0
WRITE	EQU	1
NO_MEDIACH	EQU	2	;BIT 1
NO_RETRY	EQU	4	;BIT 2 (AHDI 3.00)
PHYSICAL	EQU	8	;BIT 3 (AHDI 3.00)

* MEDIACH STATUS
****************
NO_CHANGE	EQU	0
MAYBE_CHANGED	EQU	1
CHANGED	EQU	2

* FILE DTA TABLE
****************
	RSRESET
DTA_RESERVED	RS.B	21	;Reserved for internal use
DTA_ATTRIB	RS.B	1	;file attributes
DTA_TIME	RS.W	1	;file modified time
DTA_DATE	RS.W	1	;file modified date
DTA_SIZE	RS.L	1	;File size
DTA_NAME	RS.L	14	;Filename

* FILE ATTRIBUTES
*****************
READ_ONLY	EQU	01
HIDDEN	EQU	02
SYSTEM	EQU	04
VOLUME	EQU	08
DIRECTORY	EQU	16
ARCHIVE	EQU	32	;WRITTEN & CLOSED

* FILE OPEN MODES
*****************
OPEN_READ	EQU	0
OPEN_WRITE	EQU	1
OPEN_RW	EQU	2

* FILE SEEK FROM
****************
BOF	EQU	0	;BEGINNING OF FILE
CURRENT	EQU	1	;CURRENT POSITION
EOF	EQU	2	;END OF FILE

* BUFFER CONTROL BLOCK
**********************
	RSRESET
B_link	rs.l	1	;pointer to next BCB
B_bufdrv	rs.w	1	;drive number or -1
B_buftype	rs.w	1	;buffer type
B_bufrec	rs.w	1	;record number cached in this block
B_dirty	rs.w	1	;dirty flag
B_dm	rs.l	1	;pointer to drive media descriptor table
B_bufr	rs.l	1	;pointer to buffer itself

* P_EXEC LOAD MODES
*******************
LOAD_GO	EQU	0	;Load & Execute - return exit code
LOAD	EQU	3	;Load only - return basepage address of prg
GO	EQU	4	;Execute basepage
MAKE_BASEPAGE	EQU	5	;create basepage
GO_FREE	EQU	6	;Execute then free (Gemdos >v0.21)
MAKE_PAGE2	EQU	7	;Create basepage (Gemdos >v0.25)

* EXECUTABLE FILE HEADER STRUCTURE
**********************************
* see exec_str.txt for more details
	RSRESET
PRG_magic	rs.w	1	;magic number - $601a
PRG_tsize	rs.l	1	;size of text segment
PRG_dsize	rs.l	1	;size of data segment
PRG_bsize	rs.l	1	;size of bss segment
PRG_ssize	rs.l	1	;symbol segment size
PRG_res1	rs.l	1	;reserved
PRGFLAGS	rs.l	1	;
ABSFLAG	rs.w	1	;

* BASEPAGE LAYOUT
*****************
* pointed to by 4(sp) when program starts
	RSRESET
P_lowtpa	rs.l	1	;Base Address of TPA
P_hitpa	rs.l	1	;End of TPA (+1) - unusable above here
P_tbase	rs.l	1	;Start of TEXT Section
P_tlen	rs.l	1	;Length of TEXT Section
P_dbase	rs.l	1	;Start of DATA Section
P_dlen	rs.l	1	;Length of DATA Section
P_bbase	rs.l	1	;Start of BSS Section
P_blen	rs.l	1	;Length of BSS Section
P_dta	rs.l	1	;Pointer to DTA
P_parent	rs.l	1	;Pointer to Parent Basepage
			;0 if Desk Accessory
P_reserved	rs.l	1
P_env	rs.l	1	;Pointer to Environment String
	RSSET	$80
P_cmdlin	rs.l	1	;Pointer to Command Line
			;Length byte, String, {0.b - maybe!}

* CRITICAL ERROR NUMBERS
************************
Abort	equ	-$1	;or any negative number
Retry	equ	$10000
Ignore	equ	$0

* PRINT SCREEN BLOCK TABLE - PRTABLE
************************************
		RSRESET
Pr_blkprt	rs.l	1	;Pointer to Screen Address
Pr_offset	rs.w	1	;Offset from Start Address (in bits,0-7)
Pr_width	rs.w	1	;Screen Width (in bytes)
Pr_height	rs.w	1	;Screen Height
Pr_left		rs.w	1	;Screen Dump Left Margin
Pr_right	rs.w	1	;Screen Dump Right Margin
Pr_scrres	rs.w	1	;Screen Resolution (0,1,2)
Pr_dstres	rs.w	1	;Printer res (0=960,1=1280)
Pr_colpal	rs.w	1	;Pointer to Colour Palette
Pr_type		rs.w	1	;Printer Type	0=Atari Mono Dot
				;		1=Atari Mono Daisy
				;		2=Atari Colour Dot
				;		4=Epson Mono Dot
Pr_port		rs.w	1	;Printer Port (0=parallel,1=RS-232)
Pr_masks	rs.l	1	;Pointer to half-tone mask table
				;Use 0 for ROM table

* SOUND MATRIX VALUES
*********************
DMA_Play	equ	0	;actual number
DSP_Tx		equ	1
EXT_In		equ	2
ADC		equ	3
DMA_Rec		equ	1	;numbers to OR together
DSP_Rx		equ	2
EXT_Out		equ	4
DAC		equ	8

* SOUND CLOCKS
**************
CLK25M	EQU	0
CLKEXT	EQU	1
CLK32M	EQU	2

* PRESCALE CLOCKS
*****************
CLK50K	EQU	1
CLK33K	EQU	2
CLK25K	EQU	3
CLK20K	EQU	4
CLK16K	EQU	5
CLK14K	EQU	6	*=NOT ALLOWED WITH CODEC
CLK12K	EQU	7
CLK11K	EQU	8	*
CLK10K	EQU	9
CLK9K	EQU	10	*
CLK8K	EQU	11

* SOUND BUFFER MODES
********************
Play_Enable	equ	0	;bit numbers
Play_Repeat	equ	1
Record_Enable	equ	2
Record_Repeat	equ	3

* SOUND BUFFER TABLE
********************
	RSRESET
Play_Ptr	rs.l	1	;current play position
Record_Ptr	rs.l	1	;current record position
Snd_Reserved	rs.l	2	;not used

* MFP 68901 TIMER MODES
***********************
*	Clock is 245700Hz
TIMER_OFF	EQU	0
DELAY_4		EQU	1	;Clock divided by _x generates Int
DELAY_10	EQU	2
DELAY_16	EQU	3
DELAY_50	EQU	4
DELAY_64	EQU	5
DELAY_100	EQU	6
DELAY_200	EQU	7
EVENT_COUNT	EQU	8	;Counts down 1 for each input pulse
PULSE_4		EQU	9	;Clock divided by _x will time pulse width
PULSE_10	EQU	10	;i.e. input turns clock on/off
PULSE_16	EQU	11
PULSE_50	EQU	12
PULSE_64	EQU	13
PULSE_100	EQU	14
PULSE_200	EQU	15

* DEVICE VECTOR TABLE
*********************
* Used by Kbdvbase()
	RSRESET
Midivec		rs.l	1	;midi input - normally points to buffer in bios
			;d0.b will contain char from midi port
Vkbderr		rs.l	1	;keyboard error - overrun
Vmiderr		rs.l	1	;midi error - overrun
				;
Statvec		rs.l	1	;ikbd status packet
Mousevec	rs.l	1	;mouse packet - used by gem
				;rts after use - <1ms in routine
Clockvec	rs.l	1	;clock packet - used by system
Joyvec		rs.l	1	;joystick packet
*<all packets>			;POINTER TO PACKET IN A0 AND ON STACK
				;rts after use - <1ms in routine
				;save registers used

Midisys		rs.l	1	;system midi vector from ACIA
Ikbdsys		rs.l	1	;system ikbd vector from ACIA - used by system
*<master vectors>		;6850 char ready causes ints for kbd & midi
				;this normally calls system vectors above
				;which call packet vectors above
				;do not use 6850 char ready - use other vectors above

* VECTOR NUMBERS FOR GEMDOS SETEXEC
***********************************
* $00-$FF are for 68000 Vectors

* $100-$1ff are for Gemdos use
etv_timer	equ	$100	;System Timer
* for date/time and housekeeping - +4(sp) is number of milliseconds since last call
* branch to old vector after use - d0-d7/a0-a6 are saved before call and restored after
etv_critic	equ	$101	;Critical Error Handler
* 4(sp) contains error number - return d0 as result code
* $000100 is retry, $0 is ignore, -$XX is error code - default is -1
* Preserve d3-d7/a3-a6 in your routine
etv_term	equ	$102	;Process terminate handler (& ^C)
* normally an rts - jump to somewhere if want to recover or restart

* $200-$2ff are for AES use and cannot be changed by Setexec

* POST MORTEM DUMP AREA
***********************
* processor state saved here after crash
* NOT WRITTEN OVER ON SYSTEM RESET!
proc_lives	equ	$380	;$12345678 if valid data
proc_dregs	equ	$384	;d0-d7
proc_aregs	equ	$3a4	;a0-a6, SSP (super stack pointer)
proc_enum	equ	$3c4	;1st byte is exception number
proc_usp	equ	$3c8	;user stack pointer
proc_stk	equ	$3cc	;16 words of super stack

* TOS TABLE
***********
etv_timer	equ	$400 l	;see above
etv_critic	equ	$404 l	;see above
etv_term	equ	$408 l	;see above
etv_103		equ	$40c l	;reserved
etv_104		equ	$410 l	;reserved
etv_105		equ	$414 l	;reserved
etv_106		equ	$418 l	;reserved
etv_107		equ	$41c l	;reserved
memvalid	equ	$420 l	;$752019f3 for good coldstart and valid memory config
memcntlr	equ	$424 b	;memory controller config nibble
resvalid	equ	$426 l	;$31415926 to jump through resvector on RESET
resvector	equ	$42a l	;if resvalid, called after reset but before any hardware
				;setup. return address in a6. Both stacks are invalid! 
phystop		equ	$42e l	;1st address above RAM = size of RAM
_membot		equ	$432 l	;bottom of AVAILABLE memory - used by Gemdos Getmpb
				;as start of Gemdos TPA
_memtop		equ	$436 l	;top of AVAILABLE memory - used by Gemdos Getmpb as
				;end of Gemdos TPA
memval2		equ	$43a l	;$237698AA for good coldstart and valid memory config
flock		equ	$43e w	;zero locks DMA access - non-zero means can use DMA
seekrate	equ	$440 w	;0=6ms/1=12ms/2=2ms/3=3ms - only used at boot time
_timr_ms	equ	$442 w	;system timer calibration - should be 20(ms)
				;since timer handoff vector called at 50Hz
				;this value returned by tickcal and passed on stack
				;to timer handoff vector
_fverify	equ	$444 w	;if zero, don't verify floppy writes, default DO verify
				;used by BIOS Rwabs call
_bootdev	equ	$446 w	;device number system booted from
			;used by AES for default env.path
palmode		equ	$448 w	;zero=NTSC 60Hz, none zero default=PAL 50Hz
defshiftmd	equ	$44a b	;default video resolution (on startup)
sshiftmd	equ	$44c b	;current video resolution
_v_bas_ad	equ	$44e l	;Logical Screen address - see Logbase()
vblsem		equ	$452 w	;1 enables vblank processes - 0 if already in vblank routine
nvbls		equ	$454 w	;number of vertical blank vector slots (normally 8)
_vblqueue	equ	$456 l	;address of vblank vector list
colorptr	equ	$45a l	;ptr to 16 words of colour info to load next vblank or zero
				;zeroed after use by vblank
screenptr	equ	$45e l	;ptr to new physical screen to change to on next vblank
				;does not zero after use - ZERO IF NO CHANGE
_vbclock	equ	$462 l	;vblank interrupt counter
_frclock	equ	$466 l	;vblank processed counter
hdv_init	equ	$46a l	;hard disk init vector
swv_vec		equ	$46e l	;vector for change on mono monitor detect i/p
hdv_bpb		equ	$472 l	;Get Bios Parameter Block vector for Hard Disk
				;same parameters on stack as in BIOS call
hdv_rw		equ	$476 l	;hard disk read/write vector
				;same parameters on stack as in Rwabs
hdv_boot	equ	$47a l	;hard disk boot vector
hdv_mediach	equ	$47e l	;hard disk media change vector
				;same parameters on stack as in BIOS floppy call
_cmdload	equ	$482 w	;attempt to load COMMAND.PRG if non-zero after loading boot sector
conterm		equ	$484 w	;set bit 0 for key click
				;set bit 1 for key repeat
				;set bit 2 for bell on ^G from console
				;set bit 3 for shift status reporting in Bconin & Cconin
				;in bits 24-31 of d0.l
themd		equ	$48e l	;Gemdos startup TPA size
savptr		equ	$4a2 l	;pointer to BIOS register save area
_nflops		equ	$4a6 w	;number of floppies physically attached
sav_context	equ	$4ae l	;pointer to saved processor context
_bufl		equ	$4b2 l	;pointer to data and FAT/dir Buffer Control Blocks
				;see BCB structure
_hz_200		equ	$4ba l	;vector for 200Hz system timer tick, 
				;normally divides by four for 50Hz system timer
the_env		equ	$4be 4b	;the default environment string (e.g. "A:\",0)
_drvbits	equ	$4c4 w	;drivemap of logical drives (as in Drvmap)
_dskbufp	equ	$4c6 l	;pointer to 1K buffer used for disk & GSX graphics
				;do not use in interrupt routines
;??? gap ???	
_prt_cnt	equ	$4ee w	;-1 normally, 0 for screen dump, >0 to abort
_sysbase	equ	$4f2 l	;Pointer to OS header block
_shell_p	equ	$4f6 l	;Points to shell specific context?
end_os		equ	$4fa l	;Points to last byte of low ram used by OS
				;copied into _membot at start up
exec_os		equ	$4fe l	;Start of AES or any code to start after system init
* 		>= TOS V1.2
scr_dump	equ	$502 l	;pointer to screen dump code
prv_lsto	equ	$506 l	;pointer to output device status for screen dump to PRN
				;-1 for printer ready, 0 for busy
prv_lst		equ	$50a l	;pointer to char output for screen dump to PRN
				;character to be printed is on stack
prv_auxo	equ	$50e l	;pointer to output device status for screen dump to AUX
				;-1 for printer ready, 0 for busy
prv_aux		equ	$512 l	;pointer to char output for screen dump to AUX
				;character to be printed is on stack
pun_ptr		equ	$516 l	;pointer to hard disk driver data structure
memval3		equ	$51a l	;memory validation value to check for cold boots
xconstat	equ	$51e 8l	;console input status vectors for standard devices 0-5 (7?)
				;note: 3 is KBD not MIDI, and vice versa
xconin		equ	$53e 8l	;console input vectors for standard devices 0-5 (7?)
xcostat		equ	$55e 8l	;console output status vectors for standard devices 0-5 (7?)
xconout		equ	$57e 8l	;console output vectors for standard devices 0-5 (7?)
*		> TOS V1.2
_longframe	equ	$59e w	;zero if 68000 exception stack frames, 
				;non-zero for long exception stack frames
_p_cookies	equ	$5a0 l	;pointer to cookie jar or zero for none

* SYSBASE TABLE - OS HEADER BLOCK
*********************************
* If _sysbase address > phystop then TOS is ROM based
	RSRESET
OS_branch	rs.w	1	;branch to RESET handler
OS_version	rs.b	2	;version & release number of TOS
			;blitter support starts at $0102
OS_reset	rs.l	1	;pointer to RESET handler
OS_base	rs.l	1	;pointer to base of OS
OS_ramtop	rs.l	1	;pointer to top of OS Ram
OS_reserved	rs.l	1	;not used
OS_magic	rs.l	1	;pointer to GEM memory usage parameter block
OS_date	rs.l	1	;build date as YYYYMMDD
OS_config	rs.w	1	;configuration bits
			;bit 0 is 1 for PAL, 0 for NTSC
			;TV scan rate setup accordingly
			;bits 1 & 2 are for the country
			;0=USA,1=Germany,2=France,3=UK
			;4=Spain,5=?,6=Sweden
			;7 & 8=Switzerland (French & German)
			;9=Turkey
OS_dos_date	rs.l	1	;build date in Disk format (GEMDOS)
OS_mem_ptr	rs.l	1	;internal memory pointer to OS_POOL
			;used by FOLDERXXX.PRG
			;TOS v1.02 or greater
OS_shift_state	rs.l	1	;ptr to KBD shift state bits
			;updated at interrupt level
			;TOS v1.02 or greater
OS_process_addr	rs.l	1	;pointer to app being executed
			;TOS v1.02 or greater

* THE MAGIC - GEM MEMORY USAGE PARAMETER BLOCK
**********************************************
* GEM only starts up if the Magic_magic is $87654321
* If the magic is not valid, the RAM normally used by GEM is freed
* Puntaes() returns if the magic is not valid or is in ROM,
* otherwise it zeroes the Magic_magic and jumps to the RESET handler.

	RSRESET
Magic_magic	rs.l	1	;$87654321
Magic_os_end	rs.l	1	;end of OS+GEM BSS
Magic_gemstart	rs.l	1	;GEM execution start address
