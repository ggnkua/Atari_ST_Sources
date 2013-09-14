;+
; CHNLTST.C - test Sparrow SDMA and BLiTTER by accessing them simultaneously.
;
; Apr-09-92 ml.	    Started this.
;		    (Sound stuff adapted from LT's looptst.c)
;-
.include    "defs.h"
.include    "sound.h"
.include    "sysvar.h"
.include    "spscsi.h"
.include    "blitter.h"

.extern	_hread, _hwrite, _readcap
.extern _cachexst
.extern	_active, _awto, _sbwto

STACKSIZE   equ	    $2000
HEAPSIZE    equ	    $8000
NSECTS	    equ	    MAXACSECTS

IDLETM	    equ	    12		; spin IDE down every 60 seconds
NTICKS	    equ	    12400	; spin IDE up every 62 seconds


	bra	sttst

	    .globl  _spscsixst
_spscsixst: dc.b    1		; 1: Sparrow SCSI exists
	    .globl  blit
blit:	    dc.b    1		; 1: do BLiT test
badblit:    dc.b    0		; 1: error in BLiT test
manual:	    dc.b    0		; 1: we turned BLiT test off
rw:	    dc.b    1		; 1: do read/write test
	    .globl  _useblit
_useblit:   dc.b    0		; 0: no IDE BliT involved
	    .globl  idespin
idespin:    dc.b    1		; 1: do IDE spin-up spin-down
.even
bsbuf:	    dcb.l   128,0	; BLiT source buffer
bdbuf:	    dcb.l   128,0	; BLiT destination buffer
.even
savssp:	    dc.l    0		; system stack pointer
timestamp:  dc.l    0		; time recorder
ssect:	    dc.l    0		; starting sector number
bigrbuf:    dc.l    0		; address of read buffer
bigwbuf:    dc.l    0		; address of write buffer
basepage:   dc.l    0		; basepage address

cmd:	    dc.b    13,10
	    dc.b    'ESC - quit      h - help',13,10
	    dc.b    10
	    dc.b    'Sound controls:',13,10
	    dc.b    '  r - sound from RASCAL (2 tracks)',13,10
;	    dc.b    '  o - sound from connector (10 tracks)',13,10
	    dc.b    '  d - disable sound test',13,10
	    dc.b    '  e - enable sound test',13,10
	    dc.b    10
	    dc.b    'BLiTTER controls:',13,10
	    dc.b    '  n - disable BLiTTER test',13,10
	    dc.b    '  b - enable BLiTTER test',13,10
	    dc.b    10
	    dc.b    'SCSI Read-Write controls:',13,10
	    dc.b    '  q - disable SCSI Read-Write test',13,10
	    dc.b    '  w - enable SCSI Read-Write test',13,10
	    dc.b    10
	    dc.b    'IDE spin-down spin-up controls:',13,10
	    dc.b    '  s - disable the drive from spinning up',13,10
	    dc.b    '  u - enable the drive to spin up',13,10
	    dc.b    0

help:	    dc.b    'Type \'h\' for help',13,10,0

;+
; Error messages
;-
e_nomem:    dc.b    'Not enough memory',13,10,0
e_cap:	    dc.b    'Cannot get SCSI unit 0 disk capacity',13,10,0
e_rwcmp:    dc.b    'Read-Write comparison error',13,10,0
e_read:	    dc.b    'Read from SCSI hard disk failed',13,10,0
e_write:    dc.b    'Write to SCSI hard disk failed',13,10,0
e_blit:	    dc.b    'BLiT comparison error',13,10,0

.even
sttst:	move.l	4(sp),a0	; get the basepage address
	move.l	a0,basepage	; save it
	move.l	$18(a0),a1	; bss base address from basepage
	adda.l	$1c(a0),a1	; + bss size
	adda.l	#STACKSIZE,a1	; + stack
	adda.l	#HEAPSIZE,a1	; + heap; a1 -> new top
	move.l	a1,sp		; move stack to top of new TPA
	suba.l	basepage,a1	; new TPA size
	move.l	a1,-(sp)	; new size after Mshrink()
	move.l	basepage,-(sp)	; starting from basepage
	clr.w	-(sp)
	move.w	#$4a,-(sp)	; Mshrink(0, basepage, TPAsize)
	trap	#1
	adda.w	#12,sp		; clean up stack

	clr.l	-(sp)		; go into Super mode
	move.w	#$20,-(sp)	; Super(0L)
	trap	#1
	addq.w	#6,sp		; clean up stack
	move.l	d0,savssp	; save system stack pointer

	st	_cachexst	; assume cache exists

	move.l	#cmd,-(sp)	; print commands usage
	bsr	prnstr
	addq.w	#4,sp		; clean up stack

	move.w	#IDLETM,-(sp)	; set IDE 0 to Active mode with timeout
	move.w	#$10,-(sp)
	bsr	_sbwto
	addq.w	#4,sp		; clean up stack
	move.l	_hz_200,timestamp   ; record the time

	bsr	sndsetup	; set up sound registers and start sound loop

				; fill buffer for BLiT test
	movea.l	#bsbuf,a0	; a0 -> BLiT test source buffer
	moveq	#0,d0
	move.w	#511,d2		; a total of 512 bytes
fbsbuf:
	move.b	d0,(a0)+
	addq.b	#1,d0
	dbra	d2,fbsbuf

				; set up hard disk transfers
	move.l	#(2*NSECTS*512),-(sp)
	move.w	#$48,-(sp)	; Malloc(NSECTS*2 sectors)
	trap	#1
	addq.w	#6,sp		; clean up stack
	move.l	d0,bigrbuf	; bigrbuf -> read buffer
	bne.s	fillbuf
	move.l	#e_nomem,-(sp)	; print error message
	bsr	prnstr
	addq.w	#4,sp		; clean up stack
w2quit:	move.w	#2,-(sp)	; console
	move.w	#1,-(sp)	; Bconstat(CON)
	trap	#13
	addq.w	#4,sp		; clean up stack
	tst.w	d0		; any character available?
	beq	w2quit		; if not, wait some more
	bra	endtst		; else, quit

fillbuf:
	add.l	#(NSECTS*512),d0
	move.l	d0,bigwbuf	; bigwbuf -> write buffer
				; fill write buffer with test pattern
	movea.l	d0,a0		; a0 -> write buffer
	moveq	#0,d0		; pattern starts with zero
	move.w	#NSECTS-1,d1	; altogether NSECTS sectors
fnxts:	move.w	#511,d2		; 512 bytes per sector
fnxtb:	move.b	d0,(a0)+
	addq.b	#1,d0
	dbra	d2,fnxtb	; fill next byte
	dbra	d1,fnxts	; fill next sector

				; find capacity of hard disk

;	move.w	#8,-(sp)	; SCSI unit 0
;	move.l	#bdbuf,-(sp)	; buffer
;	move.w	#1,-(sp)	; 1 sector
;	clr.l	-(sp)		; sector 0
;	bsr	_hread		; read root sector of SCSI unit 0
;	adda.w	#12,sp		; clean up stack

; Start test

w4char:	move.w	#2,-(sp)	; console
	move.w	#1,-(sp)	; Bconstat(CON)
	trap	#13
	addq.w	#4,sp		; clean up stack
	tst.w	d0		; any character available?
	bne	getchar		; if so, go get it
				; else
	tst.b	rw		; do read write test?
	bne.s	wtst		; if so, go do it
	tst.b	idespin		; do IDE spin-up?
	beq.s	chkblit		; if not, test blit?
	bsr	idespnup	; else spin IDE up
chkblit:
	tst.b	blit		; do blit test?
	beq.s	w4char		; if not, fine
	bsr	blittst		; else, do it
	tst.b	badblit		; blit test successful?
	beq.s	w4char		; if so, then continue
	move.l	#e_blit,-(sp)	; print error message
	bsr	prnstr
	addq.w	#4,sp		; clean up stack
	sf	blit		; disable BLiT test
	bra	w4char

wtst:	tst.b	blit		; BLiT test on?
	beq.s	stcap		; if not, good, just go on
	st	manual		; if so, remember it
	sf	blit		; and turn it off while getting capacity
stcap:	move.l	#bdbuf,-(sp)	; buffer
	clr.l	-(sp)		; sectnum
	clr.w	-(sp)		; pmi = 0
	move.w	#8,-(sp)	; SCSI 0
	bsr	_readcap
	add.l	#12,sp		; clean up stack
	tst.b	manual		; did we turned BLiT test off?
	beq.s	tstcap		; if not, just go on
	st	blit		; else, put it back on
	sf	manual
tstcap:	tst.w	d0		; successful?
	beq.s	getcap		; if so, get capacity of drive
	move.l	#e_cap,-(sp)	; else print error message
	bsr	prnstr
	addq.w	#4,sp		; clean up stack
	sf	rw		; disable read write test
	bra	w4char		; if not, quit

getcap:	move.l	bdbuf,d0	; d0 = hard disk size
	addq.l	#1,d0		;    = logical address of last block + 1
	sub.l	#NSECTS,d0	; d0 = starting sector for r/w test
	move.l	d0,ssect	; save starting sector for r/w test

	move.w	#8,-(sp)	; SCSI unit 0
	move.l	bigwbuf,-(sp)	; buffer
	move.w	#NSECTS,-(sp)	; NSECTS sectors
	move.l	ssect,-(sp)	; sector #
	bsr	_hwrite		; write test pattern onto disk
	adda.w	#12,sp		; clean up stack
	tst.w	d0		; successful?
	beq.s	rtst		; if so, go on
	move.l	#e_write,-(sp)	; print error message
	bsr	prnstr
	addq.w	#4,sp		; clean up stack
	sf	rw		; disable read-write test
	bra	w4char

rtst:	tst.b	blit		; blit test done?
	beq.s	rtst1		; if not, no need to check
	tst.b	badblit		; blit test successful?
	beq.s	rtst1		; if so, then continue
	move.l	#e_blit,-(sp)	; else print error message
	bsr	prnstr
	addq.w	#4,sp		; clean up stack
	sf	blit		; disable BLiT test
	bra	w4char

rtst1:	move.w	#8,-(sp)	; SCSI unit 0
	move.l	bigrbuf,-(sp)	; buffer
	move.w	#NSECTS,-(sp)	; NSECTS sectors
	move.l	ssect,-(sp)	; sector 0
	bsr	_hread		; read test pattern back from disk
	adda.w	#12,sp		; clean up stack
	tst.w	d0		; successful?
	beq.s	cmptst		; if so, go on
	move.l	#e_read,-(sp)	; print error message
	bsr	prnstr
	addq.w	#4,sp		; clean up stack
	sf	rw		; disable read-write test
	bra	w4char

cmptst:	tst.b	blit		; blit test done?
	beq.s	cmptst1		; if not, no need to check
	tst.b	badblit		; blit test successful?
	beq.s	cmptst1		; if so, then continue
	move.l	#e_blit,-(sp)	; else print error message
	bsr	prnstr
	addq.w	#4,sp		; clean up stack
	sf	blit		; disable blit test
	bra	w4char

cmptst1:
	movea.l	bigwbuf,a0	; a0 -> write buffer
	movea.l	bigrbuf,a1	; a1 -> write buffer
	move.w	#NSECTS-1,d1	; altogether NSECTS sectors
cnxts:	move.w	#127,d2		; 128 longs per sector
cnxtb:	cmpm.l	(a0)+,(a1)+
	dbne	d2,cnxtb	; compare next byte
	dbne	d1,cnxts	; compare next sector
	beq	w4char		; if data match, continue
	move.l	#e_rwcmp,-(sp)	; else print error message
	bsr	prnstr
	addq.w	#4,sp		; clean up stack
	sf	rw		; disable read-write test
	bra	w4char		; and continue

getchar:
	move.w	#2,-(sp)	; console
	move.w	#2,-(sp)	; Bconin(CON)
	trap	#13
	addq.w	#4,sp		; clean up stack

;+
; Keyboard input related to quitting and help
;-
	cmp.w	#$1b,d0		; char ESC?
	beq	endtst		; if so, quit test

chk_h:	cmp.w	#'h',d0		; char h?
	bne.s	chk_r		; if not, check for char r
	move.l	#cmd,-(sp)	; else print commands usage
	bsr	prnstr
	addq.w	#4,sp		; clean up stack
	bra	w4char

;+
; Keyboard input related to sound
;-
chk_r:	cmp.w	#'r',d0		; char r? 
	bne.s	chk_d		; if not, check for char d
	bsr	insnd		; else program sound source from internal
	bra	w4char

;chk_o:	cmp.w	#'o',d0		; char o? 
;	bne.s	chk_d		; if not, check for char d
;	bsr	outsnd		; else program sound source from internal
;	bra	w4char

chk_d:	cmp.w	#'d',d0		; char d?
	bne.s	chk_e		; if not, check for char e
	bsr	dsrcply		; else disable record-play loop
	bra	w4char

chk_e:	cmp.w	#'e',d0		; char e?
	bne.s	chk_b		; if not, check for char b
	bsr	enrcply		; else enable record-play loop
	bra	w4char

;+
; Keyboard input related to BLiTTER
;-
chk_b:	cmp.w	#'b',d0		; char b?
	bne.s	chk_n		; if not, check for char n
	st	blit		; else enable BLiTs test
	bra	w4char

chk_n:	cmp.w	#'n',d0		; char n?
	bne.s	chk_w		; if not, check for char w
	sf	blit		; else disable BLiT test
	bra	w4char

;+
; Keyboard input related to read-write
;-
chk_w:	cmp.w	#'w',d0		; char w?
	bne.s	chk_q		; if not, check for char q
	st	rw		; else enable read write test
	bra	w4char

chk_q:	cmp.w	#'q',d0		; char q?
	bne	chk_u		; if not, check for char u
	sf	rw		; else disable read write test
	bra	w4char

;+
; Keyboard input related to IDE
;-
chk_u:	cmp.w	#'u',d0		; char u?
	bne.s	chk_s		; if not, check for char s
	st	idespin		; else enable IDE spin-down spin-up
	bra	w4char

chk_s:	cmp.w	#'s',d0		; char s?
	bne.s	nomatch		; if not, there's no match
	sf	idespin		; else disable IDE spin-down spin-up
	bra	w4char

nomatch:			; key input doesn't match
	move.l	#help,-(sp)	; tell user to get help
	bsr	prnstr
	addq.w	#4,sp		; clean up stack
	bra	w4char

endtst:	bsr	dsrcply		; disable record-play
	tst.l	bigrbuf		; any buffer allocated?
	beq.s	allout
	move.l	bigrbuf,-(sp)
	move.w	#$49,-(sp)	; Mfree(bigrbuf)
	trap	#1
	adda.w	#6,sp		; clean up stack
allout:	move.l	savssp,-(sp)	; go back to user mode
	move.w	#$20,-(sp)	; Super(savssp)
	trap	#1
	addq.w	#6,sp

	clr.w	-(sp)
	trap	#1		; Pterm0()


;+
; Set up sound control and mode registers
;-
sndsetup:
	moveq	#0,d0		    ; clear d0
	move.b	VID_BH,d0	    ; d0 = screen base address
	swap	d0
	move.b	VID_BM,d0
	lsl.w	#8,d0
	move.b	VID_BL,d0
	move.l	d0,d1		    ; d1 = screen base address

; Set up Sound Control Register
				    
	move.b	#REC_SET,SNDCTRL    ; set up RECORD registers
	move.b	d0,SFBLOW	    ; set sound frame base address
	lsr.l	#8,d0
	move.b	d0,SFBMID
	lsr.l	#8,d0
	move.b	d0,SFBHI

	move.l	d1,d0
	add.l	#$2000,d0	    ; frame is $2000 bytes big
	move.l	d0,d1
	move.b	d0,SFTLOW	    ; set sound frame top addr
	lsr.l	#8,d0
	move.b	d0,SFTMID
	lsr.l	#8,d0
	move.b	d0,SFTHI

				    ; Play back buf follows Record buf
	move.b	#PLAY_SET,SNDCTRL   ; set up PLAY BACK registers
	move.l	d1,d0
	move.b	d0,SFBLOW	    ; set sound frame base address
	lsr.l	#8,d0
	move.b	d0,SFBMID
	lsr.l	#8,d0
	move.b	d0,SFBHI

	move.l	d1,d0
	add.l	#$2000,d0	    ; frame is $2000 bytes big
	move.b	d0,SFTLOW	    ; set sound frame top addr
	lsr.l	#8,d0
	move.b	d0,SFTMID
	lsr.l	#8,d0
	move.b	d0,SFTHI

	bsr	insnd		    ; program sound source
	rts


;+
; Disable record-play loop  (= LT's disable_loop)
;-
dsrcply:
	clr.b	SNDCTRL
	rts


;+
; Enable record-play loop   (= LT's enable_loop)
;-
enrcply:
	move.b	#(REC_REP|REC_ENABLE),SNDCTRL
	move.b	#(REC_REP|REC_ENABLE|PLAY_REP|PLAY_ENABLE),SNDCTRL
	rts


;+
; Program sound record data to come from connector (= LT's outer_loop)
;-
outsnd:	bsr	dsrcply		    ; disable rec-play loop
	move.w	#(M_CHAN_OFF|A_CHAN_5|WORD_MODE|S_RT_160),SNDMODE
	move.w	#$ffe0,UWMASK	    ; set up uwire mask
	move.w	#$b960,UWDATA	    ; set up uwire data
	bsr	enrcply		    ; enable rec-play loop
	rts


;+
; Program sound record data to come from RASCAL (= LT's inner_loop)
;-
insnd:	bsr	dsrcply		    ; disable rec-play loop
	move.w	#(WORD_MODE|S_RT_160),SNDMODE
	move.w	#5,CLKSRC	    ; clock source, turn off handshake
	move.w	#1,DATAMTRX	    ; rec-play loopback - no handshake

; July 2 92 - There is no more RASCAL!!!!!  :)
;	move.w	#$ffe0,UWMASK	    ; set up uwire mask
;	move.w	#$b920,UWDATA	    ; set up uwire data
	bsr	enrcply		    ; enable rec-play loop
	rts


;+
; Move data through BLiTTER and check if data is good
; var badblit = 1 if there is error in data
; var badblit = 0 if there is no error in data
;-
	.globl	blittst
blittst:
	movem.l	d0/a0-a1,-(sp)		; save registers
	lea	bBLiTTER,a1		; a1 -> BLiTTER register map
	move.l	#bsbuf,SRCADDR(a1)	; set source addr
	move.l	#bdbuf,DESTADDR(a1)	; set destination addr
	move.w	#2,DESTXINC(a1)		; words read
	move.w	#2,SRCXINC(a1)		; words write
	moveq	#0,d0
	move.w	d0,SRCYINC(a1)		; never increment source Y
	move.w	d0,DESTYINC(a1)		; never increment destination Y
	move.b	d0,SKEW(a1)		; no skew
	moveq	#$ff,d0
	move.l	d0,ENDMASK1(a1)		; change all bits at destination
	move.w	d0,ENDMASK3(a1)		; change all bits at destination
	move.w	#$203,HOP(a1)		; set HOP and OP to source
	move.w	#256,XCNT(a1)		; num of words to transfer
	move.w	#1,YCNT(a1)		; one destination line
	move.b	#$80,BUSY(a1)		; start the BLiTTER
restart:
	nop
	tas	BUSY(a1)		; restart BLiTTER and test if busy
	bmi.s	restart			; done if not busy

	lea	bsbuf,a0		; a0 -> source buffer
	lea	bdbuf,a1		; a1 -> destination buffer
	move.l	#127,d0			; 128 bytes to check
bcmp:	cmpm.l	(a0)+,(a1)+
	dbne	d0,bcmp
	sne	badblit			; set result
	movem.l	(sp)+,d0/a0-a1		; restore registers
	rts


;+
; Idespdn() - spin down IDE drive every 6 secs
;
;-
	.globl	idespnup
idespnup:
	move.l	d0,-(sp)		; save d0
	move.l	_hz_200,d0		; d0 = current time
	sub.l	timestamp,d0		; d0 = time interval between now
					;      and last time it was spun up
	cmp.w	#NTICKS,d0		; is it time to spin up again?
	bcs	nospnup			; if not, return
	move.w	#$10,-(sp)		; spin up
	bsr	_active			; set drive to Active mode
	addq.w	#2,sp			; clean up stack
	move.l	_hz_200,timestamp	; record new time
nospnup:
	move.l	(sp)+,d0		; restore d0
	rts


	
;+
; Prnstr() - print the null-terminated string at the given address
;	     to the console
;
; Passed:
;	4(sp).l -> string to be printed
;-
prnstr:	move.l	4(sp),-(sp)	    ; string to be printed
	move.w	#9,-(sp)	    ; Cconws()
	trap	#1
	addq.l	#6,sp		    ; clean up stack
	rts



