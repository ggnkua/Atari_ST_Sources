*
* Dallas 1216 RTC TOS synchronisation
* TOS Y2K fix good until 2030 
*
* Thanks to Bill Penner (RTC) and Ingo Linkweiler (Y2K)
* for inspiration, tools and code
*
* /Troed of SYNC 2014-03-02
*
* v1.00
*
*
* Usage: Compile into program suitable for desktop/AUTO usage
*        or uncomment __BOOTSECTOR and compile to file meant for
*        bootsector deployment.

*__BOOTSECTOR

_prg_base
	ifnd __BOOTSECTOR
	move.l 4(sp),a0		* base page
	move.l #$100,d0		* length of basepage
	add.l $c(a0),d0		* length of TEXT
	add.l $14(a0),d0	* length of DATA
	add.l $1c(a0),d0	* length of BSS

	move.l d0,_res+2	* size of mem to reserve on exit

	pea 0
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,_ssp+2
	endc

	lea _save_sr(pc),a0
	move.w sr,(a0)
	move.w #$2700,sr

	lea _rtcprobe(pc),a0
	move.b $5,(a0)		* $e0 if TOS >=1.4, $fc if <

	moveq #5,d5		* _rtcprobe offset

* _rtcprobe address byte trickery saves lots of bytes
* (compared to listing all eight probe addresses as longwords)

.l4	lea _rtcprobe(pc),a0
	move.l d5,d6
	roxr.b #1,d6		* make every second probe address +1
	lea (a0,d6.w),a0

	moveq #0,d0
	move.b (a0),d0

	swap d0
	roxl.b #1,d0		* $fc0000 -> $fc0001
	exg d0,a0

	move.b 8(a0),d0
	move.b 8(a0),d0

	* compare d4 (time, includes milliseconds)
	bsr.s _readrtc
	move.l d4,a1
	move.l #50000,d3	* wait
.l6	dbf d3,.l6
	bsr.s _readrtc
	cmp.l d4,a1
	bne.s _rtc

	* no RTC found at this address, probe next
	dbf d5,.l4
	
	* no RTC found at all, skip to Y2K fix
	bra.s _nortc

* destroys d0-d7 (except d5)
* return values in d3,d4

_readrtc
	* write: fe0000 or fe0002
	* read: fe0008 - read bit in bit 0

	* Send magic value twice - remember, all communication is LSB
	moveq #1,d6
	* Magic value to init clock chip communication
	move.l #$5ca33ac5,d0	* from minix code and data sheet
	rol.l #2,d0	
.l2	moveq #31,d7
.l1
	ror.l #1,d0
	move.w d0,d1
	and.w #2,d1
	* read fe0000 to write 0, fe0002 to write 1
	move.b (a0,d1),d2		
	dbf d7,.l1
	dbf d6,.l2

	* read out RTC data
	moveq #0,d3	* date
	moveq #0,d4	* time
	moveq #63,d7
.l3
	move.b 8(a0),d0
	roxr.b #1,d0
	roxr.l #1,d3
	roxr.l #1,d4
	dbf d7,.l3
	rts

_rtc
	move.w _save_sr(pc),sr
	* write to the keyboard ACIA directly - it's BCD

	andi #%01111,CCR	* clear X (otherwise adds to ABCD below)
	lea _ikbd(pc),a0
	ror.l #8,d3
	swap d3
	move.l #$70,d0		* (2000-1980) + (80-30)
	abcd d0,d3
	swap d3
	and.l #$00ffffff,d3
	or.l d3,(a0)+
	and.l #$ffffff00,d4
	or.l d4,(a0)
	
	pea _ikbd(pc)
	move.w #_ikbdend-_ikbd-1,-(sp)
	move.w #25,-(sp)	* ikbdws - send string to ikbd
	trap #14
	addq.l #8,sp

_nortc
	move.w _save_sr(pc),sr

	move.l $b8,a0
	cmp.w #$c10c,-2(a0)
	beq.s _resident		* We're already resident

	ifd __BOOTSECTOR
	move.l #_end-_ourxbios,-(sp)	* length
	move.w #$48,-(sp)		* malloc
	trap #1
	addq.l #6,sp
	
	cmp.l #0,d0			* alloc failed
	beq.s _exit
	endc

	lea _origxbios(pc),a0
	move.l $b8,(a0)

	ifd __BOOTSECTOR		* move code into alloced buffer
	move.l d0,a0
	move.l #_end-_magic,d1
	lea (a0,d1),a0
	asr.l #2,d1
	lea _end(pc),a1
.l1	move.l -(a1),-(a0)
	dbf d1,.l1

* install our own Xbios intercept
	addq.w #2,d0			* skip magic
	move.l d0,$b8			* our alloced mem
	else
* install our own Xbios intercept
	move.l #_ourxbios,$b8		* TSRd
	endc

	pea _info(pc)
	move.w #$9,-(sp)	* print line
	trap #1
	addq.l #6,sp

_settime
* retrieve our patched value through xbios
	move.w #23,-(sp)	* gettime
	trap #14
	addq.l #2,sp
	move.l d0,d7

*	move.l d0,-(sp)
*	move.w #22,-(sp)	* settime
*	trap #14
*	addq.l #6,sp

* fix gemdos
	move.w d7,-(sp)
	move.w #$2d,-(sp)	* tsettime
	trap #1
	addq.l #4,sp

	swap d7

	move.w d7,-(sp)
	move.w #$2b,-(sp)	* tsetdate
	trap #1
	addq.l #4,sp

_exit

	ifnd __BOOTSECTOR
_ssp	move.l #0,-(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp

	clr.w -(sp)
_res	move.l #0,-(sp)		* set at start
	move.w #49,-(sp)	* ptermres
	trap #1
	else
	rts
	endc

_resident
	ifnd __BOOTSECTOR
	move.l #0,_res+2	* Make sure we don't leak mem
	endc
	bra.s _settime

* These addresses (and +1 for odd byte) are probed to see if there's
* a Dallas 1216 RTC active (two consecutive reads to see if milliseconds
* change) - if so, its current time is written to the IKBD
		
_rtcprobe
	dc.b $e0		* Set to E0 or FC depending on TOS
	dc.b $fa		* cartridge bank 0
	dc.b $fb		* cartridge bank 1
	
	even

* code below put in alloced memory and TSRed

_magic	dc.w $c10c		* "clock" - magic to know if we're loaded	
_ourxbios
	lea _active(pc),a0
	tst.b (a0)
	beq.s .orig

	move.l sp,a1
	lea _ssr(pc),a0
	move.w (a1)+,(a0)
	addq.l #4,a1

* On non-68000 CPU we need to compensate for long stackframe
	tst.w $59e
	beq.s .n68000
	addq.w #2,a1
.n68000

	btst #$d,(a0)
	bne.s .user
	move.l usp,a1
.user
	cmp.w #23,(a1)
	beq.s _ourget
	cmp.w #22,(a1)
	beq.s _ourset

.orig	move.l _origxbios(pc),a1
	jmp (a1)

_origxbios	dc.l 0
_ssr	dc.w 0
_save_sr	dc.w 0

_ourget
	lea _active(pc),a0
	sf (a0)

	move.w #23,-(sp)
	trap #14		* gettime
	addq.l #2,sp

	* year in bit 25-31, add d30
*	rol.l #7,d0
*	add #30,d0
*	ror.l #7,d0

*	add.l #%11110000000000000000000000000,d0

	add.l #$3c000000,d0

	bra.s _ourend
*	lea _active(pc),a0	
*	st (a0)
*	rte

_ourset
	lea _active(pc),a0
	sf (a0)

	move.l 2(a1),d0

	* year in bit 25-31, sub d30
*	sub.l #%11110000000000000000000000000,d0

*	rol.l #7,d0
*	sub.l #30,d0
*	ror.l #7,d0

	sub.l #$3c000000,d0

	move.l d0,-(sp)
	move.w #22,-(sp)
	trap #14	* settime
	addq.l #6,sp

_ourend	lea _active(pc),a0
	st (a0)
	rte

_active	dc.w -1

*_ikbd	dc.b $1b,$14,$02,$16,$23,$40,$00,0
_ikbd	dc.b $1b,$00,$00,$00,$00,$00,$00,0
_ikbdend
_end

_info	dc.b 27,'p',' RTC+Y2K SYNCed ',27,'q',$d,$a,0
	even

_prg_end

