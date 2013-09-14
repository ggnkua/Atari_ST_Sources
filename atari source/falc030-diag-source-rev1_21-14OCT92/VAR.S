	.include "var.gbl"
	.globl EndVar,brkbuft,kbctrl,kbufrec,tries,NoOps,is_rtc


*************************************************
*                                               *
*       SYSTEM SOFTWARE EQUATES AND STORAGE     *
*                                               *
*************************************************

*** NOTE: ALL LABELS TO BE UNIQUE IN 8 CHARACTERS!	

	.abs    $200
;	.abs	$400	; RWS : WHY?!?!? RAM TEST NOW KILLS THE ENTIRE RAM BLOCK!

;*       Video palette colors
;red     equ     $500    ;dark background in monochrome
;green   equ     $051    ;light background in monochrome
;blue    equ     $005
;yellow  equ     $551
;menucol equ     $003    ;dark blue
;bgrnd   equ     menucol
;white   equ     $666
;black   equ     0

*       ASCII characters
;esc     equ     $1b
;eof     equ     $1a
;cr      equ     $0d     
;lf      equ     $0a     
;bs      equ     8
;eot     equ     0
;tab     equ     9
;tm      equ     6
;space   equ     " "
;uparrow equ     1
;dwnarrow equ    2
;rarrow  equ     3
;larrow  equ     4
;iv      equ     5       ;print next char. inverse video
;invtog	equ	16	; : RWS 16JAN92 : inverse on/off toggle
; 
;uparky  equ     $48     ;up arrow scancode
;dnarky  equ     $50     ;down arrow scancode
;rtarky  equ     $4d     ;right arrow
;lfarky  equ     $4b     ;left arrow
;ret     equ     cr

* ADDED 24JAN92 : RWS
;mfpta     equ  $134      ; timer A int. vector
;mfprtc    equ  $178      ; new rtc vector

*       Initial stack (until we test the upper memory area)
;initstack       equ     $200    ;stack is from $1ff down to ? 
*                               ;exception vectors are at $13f
*                               ;$200-140=c0=192 bytes=48 cells
;bigstack        equ     $20000  ;this stack is used after init. except 
*                               ;during the ram test

;trapv0  equ     $80     ;trap 0 vector

*       Locations $200-400 should be preserved once system is initialized

********************
*-------miscellaneous
MIDIREC:        ds.l    1	;for HOST MIDI test
TOSreturn:	ds.l	1	;TOS return address from cart boot.
ProdTestStat:	ds.b	2	; Production test flags. Minus in first byte = not production tests.. don't set RTC
				; otherwise contents is bit# of test suite running
				; second byte = $ff if a test in suite failed.
NoOps:	ds.b	1		; used by automenus
FPUStat:	ds.b	1	;status of FPU check $01= FPU, $00 = no FPU
errorpc: ds.l   1       ;save address of last bus/address error
topram: ds.l    1       ;top of ram
intflg: ds.w    1       ;flag for interrupts
timout: ds.w    1       ;counter to time-out events
line0x: ds.w    1       ;save x coordinate of line 0
savx:   ds.w    1       ;while displaying on line 0, save coordinates
savy:   ds.w    1       ;...for other messages
togo:   ds.l    1       ;cycles to go
cycle:  ds.l    1       ;cycles performed
templ:  ds.l    1       ;temp register (long)
tstbufl: ds.l   1       ;pointer to bottom entry in tstbuf
tstptr: ds.l    1       ;pointer to current entry in tstbuf
tst_tbl: ds.l   1       ;point to table of tests
tst_msg: ds.l   1       ;test completion message
rsrate: ds.w    1       ;rs232 rate (timer d data)
sav_x:  ds.w    1       ;save cursor x (keybd)
sav_y:  ds.w    1       ;save cursor y
	.even
jstat1: ds.b    1       ;joy 1 status must precede joy0 and be on word boundary
jstat0: ds.b    1       
initflg: ds.b   1       ;init complete flag
keybuf: ds.b    32      ;32 char.=input keystrokes for tests and cycles
tstbuf: ds.b    16      ;16 char.=tests to run
numbuf: ds.b    16      ;16 char.=cycles to run
tst_len: ds.b   1       ;length of test table
driva:  ds.b    1       ;floppy disk A status
drivb:  ds.b    1       ;floppy disk B status
cur_drv: ds.b   1       ;drive tested in floppy exerciser
kbrev:  ds.b    1       ;after keyreset test,=revision # or neg #
timestat: ds.b  6       ;keyboard timer status (reverse order: ss,mm,hh...)
wrflg:  ds.b    1       ;flags current alter/examine memory
alltst: ds.b    1
timflg: ds.b    1       ;flag to show timer interrupt
index1: ds.b    1       ;general purpose
rcvbyt: ds.b    1       ;rs232 receive byte
xmtbyt: ds.b    1       ;rs232 transmit byte
rsistat: ds.b   1       ;receiver status
rsostat: ds.b   1       ;transmitter status
brkcod: ds.b    1       ;last key break code
autotst: ds.b   1       ;non-zero => more than one test

mega:   ds.b    1       ;bit 0 set => blt, bit 1 set => rtc, bit 2 set =>exp
;bltbit  equ     0
;bltflg  equ     1       
;_bltflg equ     $fe
;rtcbit  equ     1
;rtcflg  equ     2
;_rtcflg equ     $fd
;expbit  equ     2
;expflg  equ     $4
;_expflg equ     $fb

consol: ds.b    1       ;consol I/O and test flags as follows:
;kfail   equ     0       ;bit 0 set=keyboard failed
;rsinp   equ     1       ;bit 1 set=RS232 loopback connector installed
;qztest  equ     3       ;bit 3 set=Q or Z test (don't wait for conin)
;mlttst  equ     4       ;bit 4 set=multiple tests selected
;mltpas  equ     5       ;bit 5 set=multiple passes
;savscr  equ     6       ;bit 6 set=save screen
;autoky  equ     7       ;bit 7 set=don't wait for key before clearing screen

usrom:  ds.b    1       ;non-zero = US TOS

ProdBkgnd:	ds.w	1	; production test background color in multi tests

*       Display blanking routines variables
	.even
hcount: ds.w    1       ;horizontal line counter
lcount: ds.b    1       ;vblank indicator
lumlin: ds.b    1
collin: ds.b    1
desel:  ds.b    1       ;floppy vert. blank var
tempb:  ds.b    1       ;temp var
rndbyt: ds.b    1       ;random number

*********************************
*------ Display Routines' Storage
*
scrtop:         ds.w    1               ; line number to start scroll
v_bas_ad:       ds.l    1               ; video base address.
v_planes:       ds.w    1               ; number of video planes.
v_vt_rez:       ds.w    1               ; vertical resolution.
v_hz_rez:       ds.w    1               ; horizontal resolution.
v_lin_wr:       ds.w    1               ; number of bytes per video line.
*
v_cel_ht:       ds.w    1               ; height of font.
v_cel_wr:       ds.w    1               ; number of bytes per character line.
v_cel_mx:       ds.w    1               ; maximum cell x coord.
v_cel_my:       ds.w    1               ; maximum cell y coord.
*
v_fnt_ad:       ds.l    1               ; address of font data.
v_fnt_wr:       ds.w    1               ; width (in bytes) of font form.
v_fnt_dc:       ds.w    1               ; number of bytes between same line
*                                       ;   in adjacent characters in form.
v_fnt_st:       ds.w    1               ; first ascii value in font.
v_fnt_nd:       ds.w    1               ; last ascii value in font.
*
v_col_fg:       ds.w    1               ; foreground color number.
v_col_bg:       ds.w    1               ; background color number.
v_cur_cx:       ds.w    1               ; current cursor x coord.
v_cur_cy:       ds.w    1               ; current cursor y coord.
v_cur_ad:       ds.l    1               ; current cursor screen address.
v_stat_0:       ds.b    1               ; cursor status.
v_cur_tim:      ds.b    1               ; cursor blink timer.
disab_cnt:      ds.w    1               ; cursor hide depth count.
sav_cxy:        ds.w    2               ; save area for cursor cell coords.

v_stat_R:	ds.w	1		; flag for changing make/break key color
*
*       The next 4 variables are used as an array by the line drawing
*         routines.  They must be contiguous!!!!!
*       FG_BP_1 is the lowest-order color index bit.
*
_FG_BP_1:       .ds.w   1               ; foreground bitplane 1 value.
_FG_BP_2:       .ds.w   1               ; foreground bitplane 2 value.
_FG_BP_3:       .ds.w   1               ; foreground bitplane 3 value.
_FG_BP_4:       .ds.w   1               ; foreground bitplane 4 value.
_X1:            .ds.w   1               ; x coordinate.
_X2:            .ds.w   1               ; x coordinate.
_Y1:            .ds.w   1               ; y coordinate.
_Y2:            .ds.w   1               ; y coordinate.
_LN_MASK:       .ds.w   1               ; line style. ($FFFF => solid)
_WRT_MODE:      .ds.w   1               ; writing mode.
_patmsk:        .ds.w   1               ; pattern index.
_patptr:        .ds.l   1               ; pointer to base of pattern data.
*
*   these spaces are for Blitter test routine. 
	        .ds.l   $10             ;
lineavar:       .ds.w   $45             ;line A variables
coor_tbl:       .ds.l     1             ;array of points to be plotted
_v_bas_ad:      .ds.l     1             ;screen display during ext. test
verts:          .ds.w     8             ;array of initial vertices
vertsl:         .ds.w     8             ;array of next group of vertices
*
;M_CFLASH        equ     $0001           ; cursor flash          0:disabled
;F_CFLASH        equ         0           ;*                      1:enabled

;M_CSTATE        equ     $0002           ;* cursor flash state   0:off
;F_CSTATE        equ         1           ;*                      1:on

;M_CVIS          equ     $0004           ;* cursor visibility    0:invisible
;F_CVIS          equ         2           ;*                      1:visible

*         The visibility flag is also used as a semaphore to prevent

*       the interrupt-driven cursor blink logic from colliding with
*       escape sequence cursor-drawing activity.

;M_CEOL          equ     $0008   ; cursor end of line handling   0:overwrite
;F_CEOL          equ         3   ;                               1:wrap

;M_REVID         equ     $0010   ; reverse video                 0:on
;F_REVID         equ         4   ;                               1:off

;F_SVPOS         equ     5       ; position saved flag. (0=false, 1=true)

;F_NEWVID	equ	1	; CHANGE COLOR ON MAKE/BREAK KEY FOR VISUAL CHECK : 07APR92 : RWS
;FAKECOLOR	equ	2	; using a VGA monitor to run diagnostic : 08APR92
*
*****************************************************************
*-------midi/keyboard offset equates for their i/o buffer records
*

;ibufptr         equ     0       ;input buffer location pointer
;ibufsiz         equ     4       ;maximum size of this buffer
;ibufhead        equ     6       ;relative pointer to next byte to be taken 
*                               ;from this buffer
;ibuftail        equ     8       ;relative pointer to next location available
*                               ;to insert a new byte
;ibuflow         equ     10      ;amount of space in buffer before an "xon" 
*                            ;may be sent to restore normal use of buffer.
;ibufhigh        equ     12   ;amount of space used in buffer that trigger's
*                               ;the sending of a "xoff" signal to the host
;obufptr         equ     14      ;buffer location pointer
;obufsiz         equ     18      ;maximum size of this buffer
;obufhead        equ     20      ;relative pointer to next byte to be taken
*                               ;from this buffer
;obuftail        equ     22      ;relative pointer to next location available 
*                               ;to insert a new byte
;obuflow         equ     24      ;amount of space in buffer before an "xon" 
*                            ;may be sent to restore normal use of buffer.
;obufhigh        equ     26   ;amount of space used in buffer that trigger's
*                               ;the sending of a "xoff" signal to the host
;status          equ     28      ;copy of midi acia status
;rsrbyte         equ     28      ;copy of rs-232 receiver status byte
;tsrbyte         equ     29      ;copy of rs-232 transmitter status byte

;ctrls           equ     $13     ;control s
;ctrlq           equ     $11     ;control q
;xoff            equ     $13     ;
;xon             equ     $11     ;
;xonoff          equ     1

;kinsize         equ     $40
;koutsize        equ     $40

kibuffer:       ds.b    kinsize         ;keyboard input buffer
kobuffer:       ds.b    koutsize        ;keyboard output buffer

*********************************************
*-------keyboard port routines variable space
*

kibufptr:       ds.l    1
kibufsiz:       ds.w    1
kibufhead:      ds.w    1
kibuftail:      ds.w    1
kibuflow:       ds.w    1
kibufhigh:      ds.w    1
kobufptr:       ds.l    1
kobufsiz:       ds.w    1
kobufhead:      ds.w    1
kobuftail:      ds.w    1
kobuflow:       ds.w    1
kobufhigh:      ds.w    1
kstatus:        ds.b    2
kbufrec         equ     kibufptr
brkptrh:        ds.l    1       ;break code buffer ptr head
brkptrt:        ds.l    1       ;break code buffer ptr tail
brkbufh:        ds.b    8       ;break code buffer
brkbuft         equ     *

*       Acia error handler vectors -- init'ed to point to 'rte' unless
*       changed subsequent to boot-up

vkbderr:        ds.l    1       ;keyboard error handler address
vmiderr:        ds.l    1       ;midi error handler address


*       Keyboard state variables

kstate:         ds.b    1       ;present state of ikbd reception routine
kindex:         ds.b    1       ;index used to count down bytes left to
*                               ;receive for current state's record
kbshift:        ds.b    1       ;bit 7 set=shift 
kbctrl:		ds.w	1	;bit 8 set=control key down : ADDED 29JAN92 : RWS
rmb:            ds.b    1       ;mouse relative movement header
rmx:            ds.b    1       ;  "      "     x
rmy:            ds.b    1       ;  "      "     y

*       keyboard repeat variables

keyrep:         ds.b    1
kdelay1:        ds.b    1
kdelay2:        ds.b    1

**************************************
*-------------------------------------
*       Local variables, not preserved during RAM test
	.even

erflg0: ds.b    1
erflg1: ds.b    1
erflg2: ds.b    1
erflg3: ds.b    1
erflg4: ds.b    1
erflg5: ds.b    1
erflg6: ds.b    1
erflg7: ds.b    1
erflg8: ds.b    1
erflg9:	ds.b	1
erflg10: ds.b   1
erflg11: ds.b   1
rxstat: ds.b    1
exiflg: ds.b    1
special: ds.b   1
txiflg: ds.b    1
rxiflg: ds.b    1


currow: ds.b    1       ;cursor position, keyboard test display
curcol: ds.b    1

	.even
colsav: ds.w    1       ;save color during palette and hires tests
resmod: ds.b    1       ;save video resolution
	ds.b    1       ;no use, just keep on even boundary

	.even
*       Write/read memory
addr1:  ds.l    1
addr2:  ds.l    1
blkcnt: ds.w    1       ;blinking cursor counter
blkstat: ds.b   1       ;blink state
wdata:  ds.b    1

	.even
*       ROM test
csh2:   ds.w    1
csh1:   ds.w    1
csh0:   ds.w    1
csl2:   ds.w    1
csl1:   ds.w    1
csl0:   ds.w    1
crch2:  ds.w    1
crch1:  ds.w    1
crch0:  ds.w    1
crcl2:  ds.w    1
crcl1:  ds.w    1
crcl0:  ds.w    1
roffset: ds.w   1
dsprom: ds.w    1        ;****~ 5/1/90 tf

keylog: ds.w    1       ;keyboard test log of keys detected

*       color test
v_bas_c: ds.l   1
colors: ds.b    1
	.even
*       Video counter test
scrsta: ds.l    1       ;start of current screen line
scrend: ds.l    1       ;end of screen memory

*       video scrolling test
vsflg:  ds.w    1
vscount: ds.w   1
v_bas_sv: ds.l  1
counter: ds.w   1
count:  ds.w    1
volume: ds.w    1

*       game controller test
vcount: ds.w    1

*       dma sound
cursnd: ds.w    1

*       DMA command block
dsect:  ds.w    1
ddbuf:  ds.l    1
dcmd:   ds.b    1
dmamem: ds.b    1

	.even
*       BltBlk
*  The following variables (4 words) have to be in order for blit test to work
spatt:  ds.w    1       ;source pattern
dpatt:  ds.w    1       ;destination pattern
n_lines: ds.w   1       ;# of lines in a screen
dspan:  ds.w    1       ;span of a line (words)

*       Expansion
vecsav: ds.l    7       ;save interrupt vectors

******************************************
*-------Midi port routines variable space
*
;minsize         equ     $80
;moutsize        equ     $80

mibuffer:       ds.b    minsize         ;midi input buffer
mobuffer:       ds.b    moutsize        ;midi output buffer

mibufptr:       ds.l    1
mibufsiz:       ds.w    1
mibufhead:      ds.w    1
mibuftail:      ds.w    1
mibuflow:       ds.w    1
mibufhigh:      ds.w    1
mobufptr:       ds.l    1
mobufsiz:       ds.w    1
mobufhead:      ds.w    1
mobuftail:      ds.w    1
mobuflow:       ds.w    1
mobufhigh:      ds.w    1
mstatus:        ds.b    2
mbufrec         equ     mibufptr

*       Real-time clock test

	.even
time:   ds.w    13      ;read/write to/from hardware
oldtime: ds.w   6       ;save time upon test entry
oldday: ds.w    1       ; "   day   "    "    "
olddate: ds.w   6       ; "   date  "    "    "
tempbuf: ds.w   6       ; a temporary buffer to use while entries are disorderd

*new rtc variables * ADDED 24JAN92 : RWS
filchr:   ds.b 1
target:   ds.b 1
temp:     ds.b 6
bckgnd:   ds.b 1
tim_al:   ds.b 1
tim_ah:   ds.b 1

is_rtc:	ds.b	1
rtcbuf:  ds.b   72

*********************************
*-------------- Floppy RAM usage:

fdat:   ds.w    1       
fint:   ds.w    1
fsid:   ds.w    1
ftrk:   ds.w    1
fsct:   ds.w    1
fcnt:   ds.w    1
fdev:   ds.w    1
fbuf:   ds.l    1
hrderr: ds.w    1
a_timer: ds.w   1       ;timer for speed
sample: ds.w    10      ;record period (speed test)
spmax:  ds.w    1       ;max speed
spmin:  ds.w    1       ;min speed
badtrack: ds.b  160     ;record faulty tracks
rd_err: ds.w    1       ;hard read errors
wrt_err: ds.w   1       ;hard write errors
fmt_err: ds.w   1       ;format errors
sidtst: ds.b    1       ;ne if checking how many sides (don't print error)
fmtflg: ds.b    1       ;ne if format succeeded
no_msg: ds.b    1       ;suppress error message (=sidtst)

*       Write, Read buffers
;wbuf            equ     $2000   ;need $1200 bytes for 9 sectors
;rbuf            equ     $4000

;flopbase        equ     $1000   ;base address for floppy variables

retrycnt:       ds.w    1               ; retry counter         (used)

cdev:           ds.w    1               ; device #              parm
ctrack:         ds.w    1               ; track number          parm
csect:          ds.w    1               ; sector number         parm
cside:          ds.w    1               ; side number           parm
ccount:         ds.w    1               ; sector count          parm
cdma:           ds.l    1               ; DMA address           parm
edma:           ds.l    1               ; ending DMA address    computed

spt:            ds.w    1               ; #sectors_per_track    flopfmt parm
interlv:        ds.w    1               ; interleave factor     flopfmt parm
virgin:         ds.w    1               ; fill data for sectors flopfmt parm

tmpdma:         ds.l    1               ; temp for hardware DMA image
def_error:      ds.w    1               ; default error number
curr_err:       ds.w    1               ; current error number

regsave:        ds.l    9               ; save area for C registers

*       DSB--dcurtrack, dseekrate
dsb0:           ds.b    4               ; floppy 0's DSB
dsb1:           ds.b    4               ; floppy 1's DSB
*------ Floppy state variables in DSB:
;recal           equ     $ff00           ; recalibrate flag (in dcurtrack)
;dcurtrack       equ     0               ; current track#
;dseekrt         equ     dcurtrack+2     ; floppy's seek-rate
;dsbsiz          equ     dseekrt+2       ; (size of a DSB)

*********************************************
*       hard disk DMA test 
****~ 7/10/90 tf r/w "J" test
tocount: ds.l   1
errsid0: ds.w   1
errsid1: ds.w   1
errsid2: ds.w   1
errsid3: ds.w   1
block:   ds.w   1
cylndr: ds.w    1
sector: ds.l    1
s_sct:  ds.l    1
hsct:   ds.l    1
hcnt:   ds.w    1
hdev:   ds.w    1
hbuf:   ds.l    1
hdata:  ds.w    1
blst_sct: ds.l  1
bad_lst:  ds.l  32
bad_lste:  ds.l 1

* NEW VIDEO STORAGE : 24MAR92 : RWS
;	         
;rbcolor:	ds.l	1
;rbdir:		ds.l	1
;
;vbhstore:	ds.w	1
;vbmstore:	ds.w	1
;vblstore:	ds.w	1


;maxx:	ds.w	1
;maxy:	ds.w	1
;wrdmde:	ds.w	1
;bytperline:	ds.w	1
;logplanes:	ds.w	1

escflag:	ds.b	1	;for console.s : 09APR92 : RWS
Y1store:	ds.b	1

	.include	e_data ; moved out...;RWS.TPEX

	.even

SPRegSpace:	ds.l	30

*-------------------------------------------
* Extra Inverse Flag : 16JAN92 : RWS
invflag:	ds.b	1
	.even
;TP1count:	ds.w	1
;     .even
     .abs $40000		;why this, here?? AUDIO TEST USES $40000+
spray_beg:  ds.l   2
hrdbuf:  ds.b    512*68          
spray_mid:  ds.l   2
hwrbuf:  ds.b    512*68
spray_end:  ds.l   2
pad:     ds.l   2
savbuf: ds.b    512*68
sensbuf: ds.b   16

*********************************************
*------ Display memory is (usually) at $10000
;scrmem          equ     $10000
;scrmemh         equ     1       ;high byte
;scrmemm         equ     0       ;mid byte       
;scrmeml		equ	0	;lo byte = 


;spscrmem	equ	$050000	; sp Display Memory - NOTE: 1MB OR GREATER RAM SIZE ONLY!
;spscrh		equ	$05
;spscrm		equ	$00
;spscrl		equ	$00

	.even
scsibuf: ds.l   1        ;pointers to scsi buffers
scsibuf1: ds.l  1

*vme space variables
oldvecs: ds.l   8
oldpsw: ds.w    1
oldVIM: ds.b    1               ; old SCU VME Interrupt Mask
	.even
nPassNo: ds.l   1
icnt0:  ds.l    1
icnt1:  ds.l    1
icnt2:  ds.l    1
icnt3:  ds.l    1
icnt4:  ds.l    1
icnt5:  ds.l    1
icnt6:  ds.l    1
icnt7:  ds.l    1


txbuf:  ds.b    $200
txbufe  equ     $
buflen  equ     txbufe-txbuf
blank:  ds.b    16              ;in case of buffer overrun
rxbuf:  ds.b    $200
rxbufe  equ     $
txptr:  ds.l    1
rxptr:  ds.l    1

; Bltmsg: ds.l 1			;4/17/92 Tomle
; Blt:    ds.l 1			;4/17/92 Tomle

* New Keyboard KeyStruck Table...

KeyStruck:	ds.b	$72	; one per scan code + a few for mouse.
KSMouRB:	ds.b	1	; bit 1 = make, bit 2 = break after make. all entries		
KSMouLB:	ds.b	1	; should be $3 before exiting test. 
KSMouU:		ds.b	1
KSMouD:		ds.b	1	; all 0,0 entries in Keypos[x] set KeyStruck[x] to $3. 
KSMouL:		ds.b	1
KSMouR:		ds.b	1	; NOTE: EuroKeys
EndKeyStruck:	ds.b	1
KeyStruckEnd:
* SDMA error flag.

SDMAerrflg:	ds.b	1

* Guards checking registers

guardlo:	ds.w	1
guardhi:	ds.w	1
tries:		ds.w	1	; can be used by tests as a counter
EndVar:         ds.w	1
