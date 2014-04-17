 .if !(^^defined DEFS_I)
DEFS_I = 1
;  .if !(^^defined HOST)
;HOST    EQU     0       ;default for running from target system
;  .endif                ;  (for SCSI only)

prod    equ     0       ;not production test
PREPROD = 1		; less help if = 1

*       Video palette colors
red     equ     $500    ;dark background in monochrome
green   equ     $051    ;light background in monochrome
blue    equ     $005
yellow  equ     $551
menucol equ     $003    ;dark blue
bgrnd   equ     $003
white   equ     $666
black   equ     0

*       ASCII characters
esc     equ     $1b
eof     equ     $1a
cr      equ     $0d     
lf      equ     $0a     
bs      equ     8
eot     equ     0
tab     equ     9
tm      equ     6
space   equ     " "
uparrow equ     1
dwnarrow equ    2
rarrow  equ     3
larrow  equ     4
iv      equ     5       ;print next char. inverse video
invtog	equ	16	; : RWS 16JAN92 : inverse on/off toggle

CR = cr
LF = lf
EOT = eot
 
uparky  equ     $48     ;up arrow scancode
dnarky  equ     $50     ;down arrow scancode
rtarky  equ     $4d     ;right arrow
lfarky  equ     $4b     ;left arrow
ret     equ     cr


* ADDED 24JAN92 : RWS
mfpta     equ  $134      ; timer A int. vector
mfprtc    equ  $178      ; new rtc vector

*       Initial stack (until we test the upper memory area)
initstack       equ     $200    ;stack is from $1ff down to ? 
*                               ;exception vectors are at $13f
*                               ;$200-140=c0=192 bytes=48 cells
bigstack        equ     $20000  ;this stack is used after init. except 
*                               ;during the ram test

trapv0  equ     $80     ;trap 0 vector

*       Locations $200-400 should be preserved once system is initialized

bltbit  equ     0
bltflg  equ     1       
_bltflg equ     $fe
rtcbit  equ     1
rtcflg  equ     2
_rtcflg equ     $fd
expbit  equ     2
expflg  equ     $4
_expflg equ     $fb

kfail   equ     0       ;bit 0 set=keyboard failed
rsinp   equ     1       ;bit 1 set=RS232 loopback connector installed
qztest  equ     3       ;bit 3 set=Q or Z test (don't wait for conin)
mlttst  equ     4       ;bit 4 set=multiple tests selected
mltpas  equ     5       ;bit 5 set=multiple passes
savscr  equ     6       ;bit 6 set=save screen
autoky  equ     7       ;bit 7 set=don't wait for key before clearing screen

M_CFLASH        equ     $0001           ; cursor flash          0:disabled
F_CFLASH        equ         0           ;*                      1:enabled

M_CSTATE        equ     $0002           ;* cursor flash state   0:off
F_CSTATE        equ         1           ;*                      1:on

M_CVIS          equ     $0004           ;* cursor visibility    0:invisible
F_CVIS          equ         2           ;*                      1:visible

*         The visibility flag is also used as a semaphore to prevent

*       the interrupt-driven cursor blink logic from colliding with
*       escape sequence cursor-drawing activity.

M_CEOL          equ     $0008   ; cursor end of line handling   0:overwrite
F_CEOL          equ         3   ;                               1:wrap

M_REVID         equ     $0010   ; reverse video                 0:on
F_REVID         equ         4   ;                               1:off

F_SVPOS         equ     5       ; position saved flag. (0=false, 1=true)

F_NEWVID	equ	1	; CHANGE COLOR ON MAKE/BREAK KEY FOR VISUAL CHECK : 07APR92 : RWS
FAKECOLOR	equ	2	; using a VGA monitor to run diagnostic : 08APR92
*
*****************************************************************
*-------midi/keyboard offset equates for their i/o buffer records
*

ibufptr         equ     0       ;input buffer location pointer
ibufsiz         equ     4       ;maximum size of this buffer
ibufhead        equ     6       ;relative pointer to next byte to be taken 
*                               ;from this buffer
ibuftail        equ     8       ;relative pointer to next location available
*                               ;to insert a new byte
ibuflow         equ     10      ;amount of space in buffer before an "xon" 
*                            ;may be sent to restore normal use of buffer.
ibufhigh        equ     12   ;amount of space used in buffer that trigger's
*                               ;the sending of a "xoff" signal to the host
obufptr         equ     14      ;buffer location pointer
obufsiz         equ     18      ;maximum size of this buffer
obufhead        equ     20      ;relative pointer to next byte to be taken
*                               ;from this buffer
obuftail        equ     22      ;relative pointer to next location available 
*                               ;to insert a new byte
obuflow         equ     24      ;amount of space in buffer before an "xon" 
*                            ;may be sent to restore normal use of buffer.
obufhigh        equ     26   ;amount of space used in buffer that trigger's
*                               ;the sending of a "xoff" signal to the host
status          equ     28      ;copy of midi acia status
rsrbyte         equ     28      ;copy of rs-232 receiver status byte
tsrbyte         equ     29      ;copy of rs-232 transmitter status byte

ctrls           equ     $13     ;control s
ctrlq           equ     $11     ;control q
xoff            equ     $13     ;
xon             equ     $11     ;
xonoff          equ     1

kinsize         equ     $40
koutsize        equ     $40

minsize         equ     $80
moutsize        equ     $80

;mbufrec         equ     mibufptr

*       Write, Read buffers
wbuf            equ     $2000   ;need $1200 bytes for 9 sectors
rbuf            equ     $4000

flopbase        equ     $1000   ;base address for floppy variables

*------ Floppy state variables in DSB:
recal           equ     $ff00           ; recalibrate flag (in dcurtrack)
dcurtrack       equ     0               ; current track#
dseekrt         equ     2	;dcurtrack+2     ; floppy's seek-rate
dsbsiz          equ     4 	;dseekrt+2       ; (size of a DSB)

*********************************************
*------ Display memory is (usually) at $10000
scrmem          equ     $10000
scrmemh         equ     1       ;high byte
scrmemm         equ     0       ;mid byte       
scrmeml		equ	0	;lo byte = 


spscrmem	equ	$050000	; sp Display Memory - NOTE: 1MB OR GREATER RAM SIZE ONLY!
spscrh		equ	$05
spscrm		equ	$00
spscrl		equ	$00

*--- GI ("psg") sound chip:
giporta         equ     $e              ; GI register# for I/O port A

.endif
