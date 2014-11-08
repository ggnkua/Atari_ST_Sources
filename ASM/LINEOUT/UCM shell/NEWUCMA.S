******** CONSTANTS ********

* executable type
forcestmode	equ	0			* 1=force a TT/Falc to behave like an ST.
testmode	equ	0			* 1=leave out nasty interrupt stuff for easy debug.
usedatalink	equ	1			* Use convential filesys (=0) or datalinkage (=1).
channels8	equ	0			* 1=Use new modplayer for 8 channels.
fastscroll	equ	1			* Use fastscroll
* Screen dimensions
scrxbytes	equ	160
scrlines	equ	200
scrbufsize	equ	scrxbytes*scrlines
txtbgnline	equ	28
* Muzak types
xlr8type	equ	0
trimodtype	equ	1
scavytype	equ	2
taotype		equ	3
megatizertype	equ	4
* Text embedded crap types
specialtype	equ	255
linktype	equ	10
bigtexttype	equ	1
bigtexttype2	equ	2
pictype		equ	30
endpictype	equ	40
* Picture handling stuffs
picnmbr		equ	3		* Maximum number of PI1's in the text
picmaxsize	equ	32066		* Size of degas elite PI1
* font dimensions
charwidth	equ	4
charheight	equ	9

******** ASM OPTIONS AND OUTPUT ********

	IFEQ	testmode
	OPT	D-
	ENDC
	IFEQ	usedatalink
	OUTPUT	D:\CODING\UCMSHELL\SHELL.PRG
	ELSE
	OUTPUT	D:\CODING\UCMSHELL\DSHELL.PRG
	ENDC

******** CODE ********

START:	move.l	4(sp),a5			* mshrink
	move.l	$0c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	addi.l	#$1000,d0
	addi.l	#$100,d0
	move.l	a5,d1
	add.l	d0,d1
	andi.b	#%11111110,d1			* even address
	move.l	d1,sp
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

	IFEQ	usedatalink
* Test for presence of necessary files..
	pea	menugfxname_txt			* Push textaddress.
	move.l	(sp),a0
	pea	menutextname_txt		* Push textaddress.
	move.l	(sp),a0
	move.w	#0,-(sp)			* Fopen
	move.l	a0,-(sp)
	move.w	#61,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi.s	.error
	addq	#4,sp
	pea	menutextname_txt		* Push textaddress.
	move.l	(sp),a0
	move.w	#0,-(sp)			* Fopen
	move.l	a0,-(sp)
	move.w	#61,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi.s	.error
	addq	#4,sp
	pea	helptextname_txt		* Push textaddress.
	move.l	(sp),a0
	move.w	#0,-(sp)			* Fopen
	move.l	a0,-(sp)
	move.w	#61,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi.s	.error
	addq	#4,sp
	pea	intropicname_txt		* Push textaddress.
	move.l	(sp),a0
	move.w	#0,-(sp)			* Fopen
	move.l	a0,-(sp)
	move.w	#61,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi.s	.error
	addq	#4,sp
	pea	modname_txt			* Push textaddress.
	move.l	(sp),a0
	move.w	#0,-(sp)			* Fopen
	move.l	a0,-(sp)
	move.w	#61,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi.s	.error
	addq	#4,sp
	bra.s	.supvis

.error	pea	.fileerror_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	pea	.return_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move	#2,-(sp)
	move	#2,-(sp)
	trap	#13
	addq.l	#4,sp
	bra	.fastout

.fileerror_txt
	DC.B	"The following file is missing: ",0
.return_txt
	DC.B	$d,$a,0
	EVEN

	ENDC

.supvis:
* Set supervisormode and save old stackpointer..
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,oldsp
	move.l	#ustk,sp			* Install own stack..
* Save the old screenaddress.
	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldscr
* Install a file-information buffer.
	pea	filedata_buf			Fsetdata
	move.w	#26,-(sp)
	trap	#1
	addq	#6,sp
* Get the computertype.
	bsr	GET_MACHINEID
	movem.w	d0-d2,computer
	IFNE	forcestmode
	move.w	#1,computer			* Transform any machine into a STe!
	ENDC
	cmpi.w	#3,computer
	bne.s	.initstw1
* If the machine is a Falcon do specific resolution-stuff.
;	bsr	INIT_FALCPATCH
	move.w	$ffff8006.w,d0
	lsr.w	#8,d0
	lsr.w	#6,d0
	beq	.fastout			* Go out if it is mono-monitor
	subq.w	#2,d0
	bne.s	.dorgbcrap
	move.w	#%0000000010010010,d0
	bra.s	.setfalcres
.dorgbcrap
	move.w	#%0000000010100010,d0
.setfalcres
	move.w	d0,-(sp)
	bsr	SAVE_FV
	move.w	(sp)+,d0
	move.w	d0,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq	#4,sp
	move.w	d0,oldfres
	bra.s	.skipstshit
.initstw1
	move.w	#4,-(sp)
	trap	#14
	addq	#2,sp
	move.w	d0,oldstres
.skipstshit
* Save old ST-pallette.
	lea	$ffff8240.w,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,oldst_pal
	moveq	#8-1,d7
.clrlop	clr.l	(a0)+
	dbra	d7,.clrlop
* Setup screenaddresses.
	move.l	#scrbuf+256,d0
	sub.b	d0,d0
	lea	scr,a0
	move.l	d0,(a0)+
	add.l	#scrbufsize,d0
	move.l	d0,(a0)+
* Set ST-low and set the new screen.
	clr.b	$ffff8260.w
	move.l	scr,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
* Save loads of interrupt crap.
	move    #$2700,SR
	lea     sys_var,A0
	move.l  $70.w,(A0)+
	move.l  $68.w,(A0)+
	move.l  $0110.w,(A0)+
	move.l	$118.w,(a0)+
	move.l  $0120.w,(A0)+
	lea     $FFFFFA00.w,A1
	move.b	$01(a1),(a0)+
	move.b	$03(a1),(a0)+
	move.b	$05(a1),(a0)+
	move.b  $07(A1),(A0)+
	move.b  $09(A1),(A0)+
	move.b	$0b(a1),(a0)+
	move.b	$0d(a1),(a0)+
	move.b	$0f(a1),(a0)+
	move.b  $11(A1),(A0)+
	move.b  $13(A1),(A0)+
	move.b  $15(A1),(A0)+
	move.b  $17(A1),(A0)+
	move.b	$19(a1),(a0)+
	move.b  $1B(A1),(A0)+
	move.b	$1d(a1),(a0)+
	move.b	$1f(a1),(a0)+
	move.b  $21(A1),(A0)+
	move.b  $23(A1),(A0)+
	move.b  $25(A1),(A0)+
	move.b  $0484.w,(A0)+
* Set some interrupt crap.
	clr.b	$fffffa1b.w
	bclr	#3,$fffffa17.w			* hardware end-of-interrupt
	ori.b	#%00100001,$fffffa07.w
	ori.b	#%00100001,$fffffa13.w
	ori.b	#%01101000,$fffffa09.w		* Was #%01101000 !!
* Kick in new VBL routine.
	move.l	#NEWVBL,$70.w
	move	#$2300,sr
* Initialize mouse + kill keysound
	bsr	INIT_IKBD
* Fade + show intro picture.
	move.l	$466.w,old466
	bsr	SHOW_INTROPIC
	move.w	#1,music			* Music off
	move.w	#1,sngnum			* Songnumber 1
	bsr	PLAY_MUSIC
	bsr	INIT_SHELL
	move.l	old466,d0
.tst4ba	cmpi.b	#$39,keycode
	beq.s	.wipe
	move.l	$466.w,d1
	sub.l	d0,d1
	cmpi.w	#250,d1
	blt.s	.tst4ba
.wipe	bsr	WIPE_PIC2SHELL
	bsr	DO_SHELLMAINLOOP

	bsr	STOP_MUSIC
.musicstopped
* Restore loads of interrupt crap.
	move    #$2700,sr
	clr.b   $fffffa1b.w     ;Timer B stoppen
        lea     sys_var,A0
	move.l  (A0)+,$70.w
	move.l  (A0)+,$68.w
	move.l  (A0)+,$0110.w
	move.l	(a0)+,$118.w
	move.l  (A0)+,$0120.w
	lea     $FFFFFA00.w,A1
	move.b	(a0)+,$01(a1)
	move.b	(a0)+,$03(a1)
	move.b	(a0)+,$05(a1)
	move.b  (A0)+,$07(A1)
	move.b  (A0)+,$09(A1)
	move.b	(a0)+,$0b(a1)
	move.b	(a0)+,$0d(a1)
	move.b	(a0)+,$0f(a1)
	move.b  (A0)+,$11(A1)
	move.b  (A0)+,$13(A1)
	move.b  (A0)+,$15(A1)
	move.b  (A0)+,$17(A1)
	move.l	a0,a2
	clr.b	$19(a1)
	clr.b	$1b(a1)
	clr.b	$1d(a1)
	addq	#3,a0
	move.b	(a0)+,d0 $1f(a1)
	move.b  (A0)+,d0 $21(A1)
	move.b  (A0)+,d0 $23(A1)
	move.b  (A0)+,d0 $25(A1)
	move.b	(a2)+,$19(a1)
	move.b	(a2)+,$1B(A1)
	move.b	(a2)+,$1d(a1)
	move.b  (A0)+,$0484.w
	move    #$2300,SR
* Restore screen + res.
.rest_resscr
	cmpi.w	#3,computer
	bne.s	.oldstres
.fscr	move.l	oldscr,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.w	oldfres,d0
	btst	#7,d0
	bne.s	.stfres
	move.w	d0,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq	#4,sp
	bsr	RESTORE_FV
	bra.s   .res_fertig
.stfres	move.w	d0,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq	#4,sp
	bra.s	.res_fertig
.oldstres
	move.b	oldstres+1,$ffff8260.w
	move.l	oldscr,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
.res_fertig
* Restore old ST-pallette.
	movem.l	oldst_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
* Return to usermode and exit.
.fastout
	move.l	oldsp,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.w	-(sp)
	trap	#1

******** SUBROUTINES ********

;INIT_FALCPATCH
;	bsr.s	fpatch_bin
;	rts
;
;EXIT_FALPATCH
;	bsr.s	fpatch_bin+4
;	rts
;
;fpatch_bin
;	incbin	F_PATCH.INL

SAVE_FV	lea	fvbuf,a1
	move.l	#'FVD2',(a1)+	4 bytes header
	move.b	$ffff8006.w,(a1)+	monitor type
	move.b	$ffff820a.w,(a1)+	sync
	move.l	$ffff820e.w,(a1)+	offset & vwrap
	move.w	$ffff8266.w,(a1)+	spshift
	move.l	#$ff8282,a0	horizontal control registers
.loop1	move	(a0)+,(a1)+
	cmp.l	#$ff8292,a0
	bne	.loop1
	move.l	#$ff82a2,a0	vertical control registers
.loop2	move	(a0)+,(a1)+
	cmp.l	#$ff82ae,a0
	bne	.loop2
	move	$ffff82c2.w,(a1)+	video control
	move	$ffff82c0.w,(a1)+	video clock
	move.b	$ffff8260.w,(a1)+	shifter resolution
	move.b	$ffff820a.w,(a1)+	video sync mode
	rts

RESTORE_FV
	lea	fvbuf,a0
	bsr	SET_FV
	rts

* Changes screenresolution the fast way.. Do this synced to the VBL for
* the smooth res-change.
* INPUT: a0: address of fv2-buffer
SET_FV	addq	#6,a0				* Skip header + monitortype
	move.l	a0,a6
	move	sr,-(sp)
	move	#$2300,sr

	move.l	(a0)+,$ffff820e.w		* offset & vwrap
	move.w	(a0)+,$ffff8266.w		* spshift
	lea	$ffff8282.w,a1			* horizontal control registers
.loop1	move.w	(a0)+,(a1)+
	cmpa.w	#$8292,a1
	bne.s	.loop1
	lea	$ffff82a2.w,a1			* vertical control registers
.loop2	move.w	(a0)+,(a1)+
	cmpa.w	#$82ae,a1
	bne.s	.loop2
	move.w	(a0)+,$ffff82c2.w		* video control
	move.w	(a0)+,$ffff82c0.w		* video clock
	cmpi.w	#$50,6(a6)			* ST resolution?
	blt.s	.stres
	addq	#1,a0				* st res
	bra.s	.fres
.stres	move.b	(a0)+,$ffff8260.w		* st res
.fres	move.b	(a0)+,$ffff820a.w		* video sync mode
	move	(sp)+,sr
	rts

INIT_IKBD
	move	#$2700,sr
	bclr	#0,$484.w			Keyclick off
	move.l	#NEW118,$118.w
	move	#$2300,sr
	rts

PLAY_MUSIC:
	cmpi.w #3,computer
	beq.s	.falc
.st	bsr	PLAY_STMUS
	rts
.falc	tst.w	falcmus
	bne.s	.st
	bsr	DSP_PLAY
	rts

STOP_MUSIC:
	cmpi.w #3,computer
	beq.s	.falc
.st	bsr	STOP_STMUS
	rts
.falc	tst.w	falcmus
	bne.s	.st
	bsr	DSP_STOP
	rts

	IFNE	channels8
DSP_PLAY:
	bsr	dspmod_bin+28
	lea     modname_txt,A0
	lea     sound_buf,A1
	bsr     LOAD_SHELLINCLUDE
	lea	sound_buf,a0
	bsr	dspmod_bin+52
	tst.b	d0
	bne.s	.on
	move.w	#1,music
	rts
.on	lea	sound_buf,A0
	lea	.modvol_tbl(PC),A1
	bsr	dspmod_bin+36
	move.w	dspmod_bin+60(PC),D0
	bset	#1,D0
	move.w	D0,dspmod_bin+60
	move.l	#dspmod_bin+44,MUSIC_IRQ
	clr.w	music
	rts

	DATA

.modvol_tbl
	DC.W	$7FFF,$7FFF,$7FFF,$7FFF
	DC.W	$7fff,$7fff,$ffff,$ffff		0,0,0,0

	TEXT

DSP_STOP:
	tst.w	music
	bne.s	.nostop
	bsr	dspmod_bin+40
	move.l	#rts,MUSIC_IRQ
	bsr	dspmod_bin+32
.nostop	move.w	#1,music
	rts

	ELSE

DSP_PLAY:
	move.w	.init(pc),d0
	tst.w	d0
	bne.s	.done
	lea	dspmod_bin(pc),a0
	bsr	.reloziere079
	move.w	#1,.init
.done	lea     modname_txt,a0
	lea     sound_buf,a1
	bsr     LOAD_SHELLINCLUDE
	moveq	#1,d0
	lea	sound_buf,a0
	bsr	dspmod_bin+28+0			* On
	move.l	#dspmod_bin+28+8,MUSIC_IRQ
	clr.w	music
	rts

.init:	dc.w	0

.reloziere079:
	move.l	2(a0),d0
	add.l	6(a0),d0
	add.l	14(a0),d0
	adda.l	#$1c,a0
	move.l	a0,d1
	movea.l	a0,a1
	movea.l	a1,a2
	adda.l	d0,a1
	move.l	(a1)+,d0
	adda.l	d0,a2
	add.l	d1,(a2)
	clr.l	d0
.L000A:	move.b	(a1)+,d0
	beq.s	.L000C
	cmp.b	#1,d0
	beq.s	.L000B
	adda.l	d0,a2
	add.l	d1,(a2)
	bra.s	.L000A
.L000B:	adda.l	#$fe,a2
	bra.s	.L000A
.L000C:	rts

DSP_STOP:
	tst.w	music
	bne.s	.nostop
	bsr	dspmod_bin+28+4     		* Off
.nostop	move.w	#1,music
	move.l	#rts,MUSIC_IRQ
	rts

	ENDC

	DATA

dspmod_bin
	IFNE	channels8
	INCBIN	DSPMOD.TCE
	ELSE
	INCBIN	DSP.BSW
	ENDC

	EVEN

	TEXT

PLAY_STMUS
	tst.w	music
	bne.s	.playit
	bsr	STOP_STMUS
.playit	move.w	sngnum,d0
	lea	filename_txt,a0
	lea	stmustype_tbl(pc),a1
	move.w	(a1)+,d7
	move.l	a0,-(sp)
	addi.b	#'0',d0
	move.b	d0,(a0)+
	move.b	#'.',(a0)+

.next	move.l	(sp),a0
	move.l	(a1)+,2(a0)
	move.l	a1,-(sp)
	lea	sound_buf,a1
	bsr	LOAD_SHELLINCLUDE
	move.l	(sp)+,a1
	addq	#4,a1
	tst.l	d0
	bpl.s	.play
	dbra	d7,.next
	bra.s	.noplay
.play	addq	#4,sp
	move.l	-4(a1),a1
	jmp	(a1)
.noplay	move.w	#-1,sngtype
	addq	#4,sp
	rts

PLAY_TAOSONG
	moveq	#1,d0
	jsr	sound_buf
	move.l	#sound_buf+4,MUSIC_IRQ
	move.w	#taotype,sngtype	type=tao sid
	clr.w	music
	rts

PLAY_XLR8SONG
	move.w	#xlr8type,sngtype	type=xlr8
	moveq	#1,d0
	jsr	sound_buf
	move.l	#sound_buf+2,MUSIC_IRQ
	clr.w	music
	rts

PLAY_TRIMODSONG
	move.w	#trimodtype,sngtype		* Type=Animal Mine Trimod
	lea	filename_txt,a6
	lea	2(a6),a0
	move.w	#"TV",(a0)+
	move.b	#"S",(a0)+
	clr.b	(a0)
	move.l	a6,a0
	lea	sound2_buf,a1
	bsr	LOAD_SHELLINCLUDE
	tst.l	d0
	bmi.s	.kut
	lea	sound2_buf,a0
	lea	sound_buf,a1
	jsr	amplay_bin			* Relocate and play
.skip2	move.l	#amplay_bin+4,MUSIC_IRQ
	clr.w	music
.kut	rts

PLAY_SCAVENGERSONG
	move.w	#scavytype,sngtype	type=scavenger SID
	jsr     sound_buf
	move.l  #sound_buf+6,MUSIC_IRQ
	clr.w	music
	rts

PLAY_MEGATIZERSONG
	move.w	#megatizertype,sngtype	type=megatizer
	jsr	sound_buf
	move.l	#sound_buf+8,MUSIC_IRQ
	clr.w	music
	rts

	data

stmustype_tbl
	dc.w	5-1
	dc.b	"TAO",0
	dc.l	PLAY_TAOSONG
	dc.b	"XLR",0
	dc.l	PLAY_XLR8SONG
	dc.b	"TRI",0
	dc.l	PLAY_TRIMODSONG
	dc.b	"SCV",0
	dc.l	PLAY_SCAVENGERSONG
	dc.b	"MGT",0
	dc.l	PLAY_MEGATIZERSONG

	text

STOP_STMUS
	tst.w   music
	bne.s   .stop
	move.w	sngtype,d0
	cmpi.w	#xlr8type,d0
	bne.s	.next
	lea	sound_buf,a0
	moveq	#0,d0
	jsr	(a0)
	bra.s	.stop
.next	cmpi.w	#trimodtype,d0
	bne.s	.next2
* A0 = address of sound_buf
	jsr	amplay_bin+12				* Stop & restore vectors.
;	jsr	amplay_bin+8				* Deinstall player.
	bra.s	.stop
.next2	cmpi.w	#scavytype,d0
	bne.s	.next3
	jsr     sound_buf+2
	bra.s	.stop
.next3	cmpi.w	#taotype,d0
	bne.s	.next4
	moveq	#0,d0
	jsr	sound_buf
	bra.s	.stop
.next4	cmpi.w	#megatizertype,d0
	bne.s	.next5
	jsr	sound_buf+4
	bra.s	.stop
.next5	nop
.stop	move.l	#rts,MUSIC_IRQ
	move.w  #1,music
	rts

* Routine that returns computertype in registers.
* OUTPUT: d0.w: 0=ST
*               1=STe
*               2=TT
*               3=Falcon030
*         d1.w: 0=monochrome monitor
*               1=RGB monitor
*               2=VGA monitor
*               3=TV
*         d2.w: 0=no blitter
*               1=blitter active
GET_MACHINEID:
	INCBIN	ID_COMP.BIN
	EVEN

* Routine that loads a shell file by using a given name.
* INPUT: a0: startaddress of nullterminated name
*        a1: startaddress of buffer to load to
* OUPTUT: d0.l: pos=number of bytes read or 
*               neg=error, not found/done
LOAD_SHELLINCLUDE:
	IFNE	usedatalink
	lea	libmem_buf,a2
	bsr.s	.inc
	tst.l	d0 
	bne.s	.out
	moveq	#-1,d0
.out:	rts
.inc:
;	INCBIN	LNKLIB.BIN
;	EVEN
	ELSE
	exg	a0,a1
	bra.s	LOAD_FILE
	nop	
	ENDC

* Routine that loads a given file from disk to a buffer.
* INPUT: a0: startaddress of buffer to load to
*        a1: startaddress of nullterminated name
* OUTPUT: d0.l: pos=length of file read
*               neg=error, not done
LOAD_FILE:
	movem.l	a0-a1,-(sp)
	move.w	#0,-(sp)			Fopen
	move.l	a1,-(sp)
	move.w	#61,-(sp)
	trap	#1
	addq.l	#8,sp
	movem.l	(sp)+,a0-a1
	move.w	d0,filhndl
	bpl.s	.read
	ext.l	d0
	rts
.read	move.l	a0,-(sp)
	move.w	#0,-(sp)			Fsfirst
	move.l	a1,-(sp)
	move.w	#78,-(sp)
	trap	#1
	addq.l	#8,sp
	move.l	filedata_buf+26,d0
	move.l	(sp)+,a0
	move.l	a0,-(sp)			Fread
	move.l	d0,-(sp)
	move.w	filhndl,-(sp)
	move.w	#63,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bpl.s	.close
	move.w	filhndl,-(sp)			Fclose
	move.w	#62,-(sp)
	trap	#1
	addq.l	#4,sp
	rts
.close	move.w	filhndl,-(sp)			Fclose
	move.w	#62,-(sp)
	trap	#1
	addq.l	#4,sp
	move.l	filedata_buf+26,d0
	rts

INIT_MENUFONT
	lea	font_dat,a1
	lea	menufont_tbl,a0
	moveq	#0,d0
	moveq	#8+4,d1
	move.w	#256-1,d7

.loop	REPT	8
	move.b	(a1)+,d0
	lsl.w	d1,d0
	move.w	d0,(a0)+
	ENDR
	dbra	d7,.loop
	rts

INIT_BIGMENUFONT
	lea	bigmenufont_tbl,a0
	lea	bigcharloc_tbl,a2
	lea	npropfntedge_tbl,a3
	move.l	a1,a6
	move.w	#256-1,d7
.chlop	movem.w	(a2)+,d0-d2
	mulu.w	#scrxbytes,d1
	move.w	d0,d3
	lsr.w	#4,d0
	move.w	d3,d4
	andi.w	#$000f,d3
	lsl.w	#3,d0
	add.l	d0,d1
	add.l	d1,a1

	add.w	d2,d2
	move.w	(a3,d2.w),d1
	lsr.w	#1,d2
	moveq	#16-1,d6
.crlop	move.w	(a1)+,d0
	lsl.w	d3,d0
	and.w	d1,d0
	move.w	d0,(a0)+
	move.w	(a1)+,d0
	lsl.w	d3,d0
	and.w	d1,d0
	or.w	d0,(a0)+
	move.w	(a1)+,d0
	lsl.w	d3,d0
	and.w	d1,d0
	or.w	d0,(a0)+
	move.w	(a1)+,d0
	lsl.w	d3,d0
	and.w	d1,d0
	or.w	d0,(a0)+
	lea	152(a1),a1
	dbra	d6,.crlop

	add.w	d2,d3
	sub.w	#16,d3
	bmi.s	.eol
	add.w	d3,d3
	move.w	(a3,d3.w),d1
	lsr.w	#1,d3
	sub.w	d2,d3
	neg.w	d3
	lea	-8*16(a0),a0
	lea	8-(scrxbytes*16)(a1),a1
	moveq	#16-1,d6
.crlop2	move.w	(a1)+,d0
	and.w	d1,d0
	lsr.w	d3,d0
	or.w	d0,(a0)+
	move.w	(a1)+,d0
	and.w	d1,d0
	lsr.w	d3,d0
	or.w	d0,(a0)+
	move.w	(a1)+,d0
	and.w	d1,d0
	lsr.w	d3,d0
	or.w	d0,(a0)+
	move.w	(a1)+,d0
	and.w	d1,d0
	lsr.w	d3,d0
	or.w	d0,(a0)+
	lea	152(a1),a1
	dbra	d6,.crlop2
.eol	move.l	a6,a1
	dbra	d7,.chlop
	rts

INIT_MOUSEPOINTER
	move.l	a1,a6
	lea	mse_pic,a0
	lea	2*10(a0),a2
	moveq	#10-1,d7
.lp	move.w	(a1)+,d0
	move.w	d0,(a2)+
	move.w	d0,d1
	move.w	(a1)+,d0
	move.w	d0,(a2)+
	or.w	d0,d1
	move.w	(a1)+,d0
	move.w	d0,(a2)+
	or.w	d0,d1
	move.w	(a1)+,d0
	move.w	d0,(a2)+
	or.w	d0,d1
	not.w	d1
	move.w	d1,(a0)+
	lea	scrxbytes-8(a1),a1
	dbra	d7,.lp
	lea	mse2_pic,a0
	lea	8(a6),a1
	lea	2*10(a0),a2
	moveq	#10-1,d7
.lp2	move.w	(a1)+,d0
	move.w	d0,(a2)+
	move.w	d0,d1
	move.w	(a1)+,d0
	move.w	d0,(a2)+
	or.w	d0,d1
	move.w	(a1)+,d0
	move.w	d0,(a2)+
	or.w	d0,d1
	move.w	(a1)+,d0
	move.w	d0,(a2)+
	or.w	d0,d1
	not.w	d1
	move.w	d1,(a0)+
	lea	scrxbytes-8(a1),a1
	dbra	d7,.lp2
	rts

COPY_STSCREEN
	move.w	#200-1,d7
.loop	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,96(a0)
	movem.l	(a1)+,d0-d3
	movem.l	d0-d3,144(a0)
	lea	160(a0),a0
	dbra	d7,.loop
	rts

* Routine that clears a given amount of bytes
* INPUT: a0: startaddress of buffer
*        d0.l: number of bytes to clear
CLEAR_BUFFER
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	add.l	d0,a0
	divu.w	#208,d0
	beq.s	.small
	moveq	#0,d6
	moveq	#0,d7
	move.l	d1,a1
	move.l	d2,a2
	move.l	d3,a3
	move.l	d4,a4
	move.l	d5,a5
	move.l	d6,a6
	subq.w	#1,d0
.bigloop
	REPT	4
	movem.l	d1-d7/a1-a6,-(a0)
	ENDR
	dbra	d0,.bigloop
.small	swap	d0
	move.w	d0,d1
	lsr.w	#4,d0
	beq.s	.mini
	subq.w	#1,d0
.smallloop
	movem.l	d2-d5,-(a0)
	dbra	d0,.smallloop
.mini	andi.w	#$000f,d1
	beq.s	.rts
	subq.w	#1,d1
.minilp	move.b	d2,-(a0)
	dbra	d1,.minilp
.rts	rts

* INPUT: a0: startaddress of 160 bytes to clear.
CLEAR_160BYTES
	lea	160(a0),a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	movea.l	d0,a1
	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	rts

* INPUT: a0: startadress of 320 bytes to clear.
CLEAR_320BYTES
	lea	320(a0),a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	movea.l	d0,a1
	movea.l	d1,a2
	movea.l	d1,a3
	movea.l	d1,a4
	movea.l	d1,a5
	movea.l	d1,a6
	movem.l	d0-d7/a1-a6,-(a0)
	movem.l	d0-d7/a1-a6,-(a0)
	movem.l	d0-d7/a1-a6,-(a0)
	movem.l	d0-d7/a1-a6,-(a0)
	movem.l	d0-d7/a1-a6,-(a0)
	movem.l	d0-d7/a1-a2,-(a0)
	rts

* Routine that copies a given amount of data from one address to the other.
* INPUT: a0: startaddress of destination buffer
*        a1: startaddress if source buffer
*        d0.l: number of bytes to copy
COPY_BUFFER
	tst.w	blitter
	bra.s	.noblit			;beq.s	.noblit			
	lea	$FFFF8A00.w,A2		* Blitter-Base
	moveq	#-1,D1
	move.l	D1,$28(A2)
	move.w	D1,$2C(A2)		* Endmask
	moveq	#2,D1
	move.w	D1,$20(A2)		* Source-x-inc
	move.w	D1,$22(A2)		* Source-y-inc
	move.l	A1,$24(A2)		* Source-Add.
	move.w	D1,$2E(A2)		* Dest.-x-inc
	move.w	D1,$30(A2)		* Dest.-y-inc
	move.l	A0,$32(A2)		* Dest.-Add.
	lsr.l	#1,d0
	move.w	d0,$36(A2)		* x-count
	move.w	#1,$38(A2)		* y-count
	andi.b	#%11111010,$3a(a2)	* no halftone shit
	ori.b	#%00000010,$3a(a2)	* no halftone shit
	move.b	#3,$3B(A2)		* OP = Dest=SOurce
	move.b	#0,$3D(A2)		* skew = 0
	lea	$3C(A2),A2
	andi.b	#%10010000,(a2)		* no halftone shit
	ori.b	#%00000000,(a2)		* no halftone shit
	bset	#7,(A2)         	* Busy = 1
.restart_blit
	bset	#7,(A2)
	nop
	bne.s	.restart_blit
	rts
.noblit	divu.w	#192,d0
	subq.w	#1,d0
	bmi.s	.small
.biglp	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,48(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,96(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,144(a0)
	lea	192(a0),a0
	dbra	d0,.biglp
.small	swap	d0
	move.w	d0,d1
	andi.w	#$fff8,d0
	sub.w	d0,d1
	lsr.w	#3,d0
	subq.w	#1,d0
	bmi.s	.mini
.smallp	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d0,.smallp
.mini	subq.w	#1,d1
	bmi.s	.rts
.minilp	move.b	(a1)+,(a0)+
	dbra	d1,.minilp
.rts	rts

INIT_MOUSEBACK
	lea	mseback_buf,a0
	move.l	scr+4,a1
	moveq	#10-1,d7
.lp	REPT	4
	move.l	(a1)+,(a0)+
	ENDR
	lea	scrxbytes-16(a1),a1
	dbra	d7,.lp
	rts

INIT_TEXT
	movem.l	d0-a6,-(sp)
	bsr	CLEAR_PICTUREBUF
	movem.l	(sp)+,d0-a6
* Do the text itself..
	subq.l	#2,d7
	move.l	d7,textlen
	lea     text_buf,A0
* a0.l - Zeiger auf Text
* d7.l - LÑnge des Textes-1 (in bytes)
* d1.w - Zeilencounter
* d2.w - Font-style
* a1.l - Zeiger auf text-table
	lea     0(A0,D7.l),A2
	moveq	#0,d1
	lea     txt_tbl,A1
	moveq	#0,d1
	moveq	#0,d2
	move.w	#0,(a1)+
	move.l	a0,(a1)+
.form_loop
	move.b  (A0)+,D0
	cmp.b   #'{',D0
	beq.s   .special
	cmp.b   #13,D0
	bne.s   .flw1
	addq.l  #1,A0
	tst.w   D2
	beq.s   .small_text
.big_text
	move.w  #bigtexttype,(A1)+
	move.l	a0,(a1)+
	move.w	#bigtexttype2,(a1)+
	move.l	a0,(a1)+
	addq.w  #2,D1
	bra.s   .flw1
.small_text
	move.w  #0,(A1)+
	move.l  A0,(A1)+
	addq.w  #1,D1
.flw1	cmpa.l  A0,A2
	bge.s   .form_loop
.returns
	cmp.w   #21,D1
	bge.s   .flw2
	move.w  #0,(A1)+
	move.l  A0,(A1)+
	addq.w  #1,D1
	bra.s   .returns
.flw2	move.w  D1,textlines
	move.b  #$0D,(A0)+
	move.b  #$0A,(A0)+
	rts
.special
	cmpi.b  #'*',(A0)
	bne.s   .flw1
	move.b  #specialtype,-1(A0)
	move.b	#specialtype,(a0)+
	move.b  (A0)+,D0
	cmpi.b	#'\',d0
	beq.s	.link
	cmpi.b	#'f',D0
	beq.s   .new_font
	cmpi.b	#'c',d0
	beq.s	.color
	cmpi.b	#'i',d0
	beq.s	.image
	bra	.clear_klammer
.link	move.w	#linktype,-6(a1)
	bra	.clear_klammer
.new_font
	move.b  (A0)+,D2
	sub.w   #48,D2
	beq	.form_loop
	subq	#6,a1
	move.w  #bigtexttype,(A1)+
	move.l	a0,(a1)+
	move.w	#bigtexttype2,(a1)+
	move.l	a0,(a1)+
	addq.w  #2-1,D1
	bra	.flw1
.color	moveq	#0,d0
	move.l	a0,a6
.asclp	move.b	(a6)+,d3
	sub.b	#'0',d3
	blt.s	.shitcolor
	cmpi.b	#9,d3
	bgt.s	.shitcolor
	mulu.w	#10,d0
	add.b	d3,d0
	bra.s	.asclp
.shitcolor
	cmpi.b	#16,d0
	blt.s	.okcoln
	andi.b	#$0f,d0
.okcoln	move.b	d0,(a0)+
	bra	.clear_klammer
.image	movem.l	d1-a6,-(sp)
	lea	filename_txt,a1
	bsr	EXTRACT_NAMEFROMTEXT		Get filename
	lea	gentext_txt,a1
	bsr	EXTRACT_NAMEFROMTEXT		Get alignment
	move.b	gentext_txt,d0
	bsr	GET_PICALIGNMENT
	move.w	#pictype,d1
	add.b	d0,d1
	move.w	d1,fxtype
	REPT	4
	lea	gentext_txt,a1
	bsr	EXTRACT_NAMEFROMTEXT
	lea	gentext_txt,a1
	bsr	CONV_TEXT2NUM
	move.w	d0,-(sp)
	ENDR
	move.w	(sp)+,d3
	move.w	(sp)+,d2
	move.w	(sp)+,d1
	move.w	(sp)+,d0
	lea	filename_txt,a1
	bsr	ADD_PICBLK
	move.l	a0,adr
	movem.l	(sp)+,d1-a6
	tst.w	d0
	bmi.s	.clear_klammer		heavy shit
	subq	#6,a1
	subq.w	#1,d0
	add.w	d0,d1
.loppo	move.w	fxtype(pc),(a1)+
	move.l	adr,(a1)+
	addq.l	#8,adr
	dbra	d0,.loppo
	bra.s	.clear_klammer
* Other special thingies in here...
	nop
.clear_klammer
.ckl	cmpi.b  #'}',(A0)+
	bne.s   .ckl
	move.b  #specialtype,-1(A0)
	bra	.flw1

fxtype	dc.w	0
adr	dc.l	0

EXTRACT_NAMEFROMTEXT
.prelp	cmpi.b	#' ',(a0)
	bne.s	.loop
	addq	#1,a0
	bra.s	.prelp
.loop	move.b	(a0)+,d0
	cmpi.b	#'a',d0
	blt.s	.on
	cmpi.b	#'z',d0
	bhi.s	.on
	subi.w	#32,d0
.on	move.b	d0,(a1)+
	cmpi.b	#'}',d0
	beq.s	.out
	cmpi.b	#' ',d0
	bne.s	.loop
.out	clr.b	-1(a1)
	rts

CONV_TEXT2NUM
	moveq	#0,d0
.loop	moveq	#0,d1
	move.b	(a1)+,d1
	beq.s	.end
	subi.b	#'0',d1
	cmpi.b	#10,d1
	bhs.s	.error
	mulu.w	#10,d0
	add.b	d1,d0
	bra.s	.loop
.end	rts
.error	moveq	#0,d0
	rts

* INPUT: d0.b: character
* OUTPUT: d0.b: 0=left alignment
*               1=mid alignment
*               2=right alignment
GET_PICALIGNMENT
	cmpi.b	#'a',d0
	blt.s	.lower
	subi.b	#32,d0
.lower	cmpi.b	#'L',d0
	bne.s	.m
	move.b	#0,d0
	rts
.m	cmpi.b	#'M',d0
	bne.s	.r
	move.b	#1,d0
	rts
.r	cmpi.b	#'R',d0
	bne.s	.mid
	move.b	#2,d0
	rts
.mid	move.b	#1,d0
	rts

EXTRACT_NAMEFROMETEXT
	lea	filename_txt,a1
.loop	move.b	(a0)+,d0
	cmpi.b	#'a',d0
	blt.s	.on
	cmpi.b	#'z',d0
	bhi.s	.on
	subi.w	#32,d0
.on	move.b	d0,(a1)+
	cmpi.b	#specialtype,d0
	bne.s	.loop
	clr.b	-1(a1)
	rts

* Clears all entries from the picture handling related buffers.
CLEAR_PICTUREBUF
	moveq	#0,d0
	move.w	d0,piclin_tbl
	move.w	d0,picpck_tbl
	move.w	d0,picname_tbl
	lea	pic_buf+4,a0
	move.l	a0,-(a0)
	rts

* INPUT: d0.w: x-start/16
*        d1.w: x-end/16
*        d2.w: y-start
*        d3.w: y-end
*        a1: address of name of picture
* OUTPUT: d0.b: 0=ok
*               -1=error, not done
*         a0: address of entry
ADD_PICBLK
	movem.w	d0-d3,-(sp)
	move.l	a1,-(sp)
	bsr	PUT_PICNAMEINTABLE
	move.l	(sp)+,a1
	tst.b	d0
	beq.s	.new
	bpl	.old
	movem.w	(sp)+,d0-d3
	moveq	#-1,d0
	rts
.new	move.l	a1,a0
	move.l	pic_buf,a1
	bsr	LOAD_SHELLINCLUDE
* Test hier diskIO success!!
	
* Make the new picture packet table entry..
	lea	picpck_tbl,a0
	move.w	(a0),d0
	move.w	d0,d1
	addq.w	#1,d1
	move.w	d1,(a0)+
	lsl.w	#3,d0
	adda.w	d0,a0
	movem.w	(sp)+,d0-d3
	sub.w	d0,d1
	lsl.w	#3,d0
	move.w	d0,(a0)+			* Put x-offset (bytes) in entry
	move.w	d1,(a0)+			* Put number of chunks in entry
	move.l	pic_buf,(a0)+			* Put address of PI1 in entry
	addi.l	#picmaxsize,pic_buf
	subq	#8,a0
* Make new picline table entries..
	lea	piclin_tbl,a1
	move.w	(a1)+,d0
	lsl.w	#3,d0
	adda.w	d0,a1
	move.l	a1,a6
	move.w	d3,d7
	sub.w	d2,d7				* y-end - y-begin
	divu.w	#charheight,d7			* get number of textlines and remaining number of scanlines
	move.w	d7,d6
	subq.w	#1,d7
	bmi.s	.skip
.linlop	move.w	d2,(a1)+
	move.w	#charheight,(a1)+
	move.l	a0,(a1)+
	addi.w	#charheight,d2
	dbra	d7,.linlop
.skip	move.w	d2,(a1)+
	swap	d7
	move.w	d7,(a1)+
	move.l	a0,(a1)+
	addq.w	#1,d6
	add.w	d6,piclin_tbl
	move.w	d6,d0
	move.l	a6,a0
	rts
.old
* Make new picture packet..
	subq.w	#1,d0
	mulu.w	#picmaxsize,d0
	move.l	d0,d6
	addi.l	#pic_buf+4,d6			* d6=address of PI1 in memory
	lea	picpck_tbl,a0
	move.w	(a0),d0
	move.w	d0,d1
	addq.w	#1,d1
	move.w	d1,(a0)+
	lsl.w	#3,d0
	adda.w	d0,a0
	movem.w	(sp)+,d0-d3
	sub.w	d0,d1
	lsl.w	#3,d0
	move.w	d0,(a0)+			* Put x-offset (bytes) in entry
	move.w	d1,(a0)+			* Put number of chunks in entry
	move.l	d6,(a0)+			* Put address of PI1 in entry
	subq	#8,a0
* Make new picturelines..
	lea	piclin_tbl,a1
	move.w	(a1)+,d0
	lsl.w	#3,d0
	adda.w	d0,a1
	move.l	a1,a6
	move.w	d3,d7
	sub.w	d2,d7
	divu.w	#charheight,d7
	move.w	d7,d6
	subq.w	#1,d7
	bmi.s	.skp
.linlp	move.w	d2,(a1)+
	move.w	#charheight,(a1)+
	move.l	a0,(a1)+
	addi.w	#charheight,d2
	dbra	d7,.linlp
.skp	move.w	d2,(a1)+
	swap	d7
	move.w	d7,(a1)+
	move.l	a0,(a1)+
	addq.w	#1,d6
	add.w	d6,piclin_tbl
	move.w	d6,d0
	move.l	a6,a0
	rts

* INPUT: a1: address of picturename
* OUTPUT: d0.b: >0=name already in table, number of entry returned
*               0=new name added to table
*               -1=too many pictures, not done!
PUT_PICNAMEINTABLE
	move.l	a1,a5
	lea	picname_tbl,a0
	move.w	(a0)+,d7
	cmpi.w	#picnmbr,d7
	beq.s	.error
	move.l	a0,a6
	subq.w	#1,d7
	bmi.s	.add
	moveq	#1,d6			; moveq #1,d6
.strlop	moveq	#0,d2
.chrlop	move.b	(a0)+,d0
	beq.s	.chrend
	move.b	(a1)+,d1
	beq.s	.chrend
	cmp.b	d0,d1
	beq.s	.yes
	moveq	#1,d2
.yes	beq.s	.chrlop
.chrend	tst.b	d2
	bne.s	.next
	move.w	d6,d0
	rts
.next	move.l	a5,a1
	lea	32(a6),a6
	move.l	a6,a0
	addq.w	#1,d6
	dbra	d7,.strlop
.add
.movlop	move.b	(a1)+,(a0)+
	bne.s	.movlop
	addq.w	#1,picname_tbl
	moveq	#0,d0
	rts
.error	moveq	#-1,d0
	rts

PLOT_BIGTEXTLINEU
	movem.l	d1-a6,-(sp)
	lea	bigmenufont_tbl,a1
	lea	bigcharloc_tbl,a3
	move.l	a1,a6
	move.l	a0,a5
	move.l	a2,a4
	moveq	#0,d1
.prelp	moveq	#0,d0
	move.b	(a4)+,d0
	cmpi.b	#specialtype,d0
	beq.s	.preout
	cmpi.b	#$d,d0
	beq.s	.preout
	mulu.w	#6,d0
	add.w	4(a3,d0.l),d1
	bra.s	.prelp
.preout	subi.w	#scrxbytes*2,d1
	neg.w	d1
	lsr.w	#1,d1
	move.w	d1,d0
	lsr.w	#4,d1
	lsl.w	#3,d1
	add.w	d1,a5
	andi.w	#$000f,d0
	move.w	d0,d2
.loop	moveq	#0,d0
	move.b	(a2)+,d0
	cmpi.b	#specialtype,d0
	beq.s	.out
	cmpi.b	#$d,d0
	beq.s	.out
	move.l	d0,d1
	mulu.w	#6,d1
	move.l	d2,d3
	add.w	4(a3,d1.l),d2
	mulu.w	#16*8,d0
	add.l	d0,a1
	cmpi.w	#16,d3
	blo.s	.skip
	addq	#8,a5
	subi.w	#16,d2
	subi.w	#16,d3
.skip	move.l	a5,a0
	moveq	#charheight-1,d6
.linlop	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	or.w	d0,6(a0)
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	or.w	d0,6(a0)
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	or.w	d0,6(a0)
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	or.w	d0,6(a0)
	lea	scrxbytes-8(a0),a0
	dbra	d6,.linlop
	lea	-(scrxbytes*charheight)+8(a0),a0
	move.l	a6,a1
	bra.s	.loop
.out	movem.l	(sp)+,d1-a6
	rts

PLOT_BIGTEXTLINEL
	movem.l	d1-a6,-(sp)
	lea	bigmenufont_tbl,a1
	lea	bigcharloc_tbl,a3
	lea	charheight*8(a1),a1
	move.l	a0,a5
	move.l	a1,a6
	move.l	a2,a4
	moveq	#0,d1
.prelp	moveq	#0,d0
	move.b	(a4)+,d0
	cmpi.b	#specialtype,d0
	beq.s	.preout
	cmpi.b	#$d,d0
	beq.s	.preout
	mulu.w	#6,d0
	add.w	4(a3,d0.l),d1
	bra.s	.prelp
.preout	subi.w	#scrxbytes*2,d1
	neg.w	d1
	lsr.w	#1,d1
	move.w	d1,d0
	lsr.w	#4,d1
	lsl.w	#3,d1
	add.w	d1,a5
	andi.w	#$000f,d0
	move.w	d0,d2
.loop	moveq	#0,d0
	move.b	(a2)+,d0
	cmpi.b	#specialtype,d0
	beq.s	.out
	cmpi.b	#$d,d0
	beq.s	.out
	move.l	d0,d1
	mulu.w	#6,d1
	move.l	d2,d3
	add.w	4(a3,d1.l),d2
	mulu.w	#16*8,d0
	add.l	d0,a1
	cmpi.w	#16,d3
	blo.s	.skip
	addq	#8,a5
	subi.w	#16,d2
	subi.w	#16,d3
.skip	move.l	a5,a0
	moveq	#7-1,d6
.linlop	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	or.w	d0,6(a0)
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	or.w	d0,6(a0)
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	or.w	d0,6(a0)
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	or.w	d0,6(a0)
	lea	scrxbytes-8(a0),a0
	dbra	d6,.linlop
	lea	-(scrxbytes*7)+8(a0),a0
	move.l	a6,a1
	bra.s	.loop
.out	movem.l	(sp)+,d1-a6
	rts

PLOT_BIGTEXTSCANLINEU
	lsl.w	#3,d1
	lea	bigmenufont_tbl,a1
	adda.w	d1,a1
	lea	bigcharloc_tbl,a3
	move.l	a1,a6
	move.l	a0,a5
	move.l	a2,a4
	moveq	#0,d1
.prelp	moveq	#0,d0
	move.b	(a4)+,d0
	cmpi.b	#specialtype,d0
	beq.s	.preout
	cmpi.b	#$d,d0
	beq.s	.preout
	mulu.w	#6,d0
	add.w	4(a3,d0.l),d1
	bra.s	.prelp
.preout	subi.w	#scrxbytes*2,d1
	neg.w	d1
	lsr.w	#1,d1
	move.w	d1,d0
	lsr.w	#4,d1
	lsl.w	#3,d1
	add.w	d1,a5
	andi.w	#$000f,d0
	move.w	d0,d2
.loop	moveq	#0,d0
	move.b	(a2)+,d0
	cmpi.b	#specialtype,d0
	beq.s	.out
	cmpi.b	#$d,d0
	beq.s	.out
	move.l	d0,d1
	mulu.w	#6,d1
	move.l	d2,d3
	add.w	4(a3,d1.l),d2
	lsl.l	#7,d0			mulu.w	#16*8,d0
	add.l	d0,a1
	cmpi.w	#16,d3
	blo.s	.skip
	addq	#8,a5
	subi.w	#16,d2
	subi.w	#16,d3
.skip	move.l	a5,a0
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	or.w	d0,6(a0)
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	or.w	d0,6(a0)
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	or.w	d0,6(a0)
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	or.w	d0,6(a0)
	move.l	a6,a1
	bra.s	.loop
.out	rts

PLOT_BIGTEXTSCANLINEL
	cmpi.w	#7,d1
	blt.s	.low
	rts
.low	lsl.w	#3,d1
	lea	bigmenufont_tbl,a1
	adda.w	d1,a1
	lea	bigcharloc_tbl,a3
	lea	charheight*8(a1),a1
	move.l	a0,a5
	move.l	a1,a6
	move.l	a2,a4
	moveq	#0,d1
.prelp	moveq	#0,d0
	move.b	(a4)+,d0
	cmpi.b	#specialtype,d0
	beq.s	.preout
	cmpi.b	#$d,d0
	beq.s	.preout
	mulu.w	#6,d0
	add.w	4(a3,d0.l),d1
	bra.s	.prelp
.preout	subi.w	#scrxbytes*2,d1
	neg.w	d1
	lsr.w	#1,d1
	move.w	d1,d0
	lsr.w	#4,d1
	lsl.w	#3,d1
	add.w	d1,a5
	andi.w	#$000f,d0
	move.w	d0,d2
.loop	moveq	#0,d0
	move.b	(a2)+,d0
	cmpi.b	#specialtype,d0
	beq.s	.out
	cmpi.b	#$d,d0
	beq.s	.out
	move.l	d0,d1
	mulu.w	#6,d1
	move.l	d2,d3
	add.w	4(a3,d1.l),d2
	lsl.l	#7,d0			mulu.w	#16*8,d0
	add.l	d0,a1
	cmpi.w	#16,d3
	blo.s	.skip
	addq	#8,a5
	subi.w	#16,d2
	subi.w	#16,d3
.skip	move.l	a5,a0
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	or.w	d0,6(a0)
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	or.w	d0,6(a0)
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	or.w	d0,6(a0)
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	or.w	d0,6(a0)
	move.l	a6,a1
	bra.s	.loop
.out	rts

PLOT_TEXTLINE
	move.l	textlen,d1
	lea	(a2,d1.l),a5
	lea	txt_tbl,a4
	move.w	d0,d1
	mulu.w	#6,d0
	add.l	d0,a4
	move.l	a0,a6
	moveq	#0,d5

.plotit	move.w	(a4)+,d0
	cmpi.w	#pictype,d0
	blt.s	.fnt
	cmpi.w	#endpictype,d0
	bhs.s	.fnt
	move.l	(a4),a1			Get address of piclin table entry
	move.w	(a1),d1			Get y-offset
	move.w	2(a1),d7		Get number of scanlines
	move.l	4(a1),a1		Get address of picpck table entry
	move.w	(a1),d2
	move.w	2(a1),d3
	lsl.w	#3,d3
	subi.w	#pictype,d0
	beq.s	.alok
	cmpi.b	#2,d0
	beq.s	.right
	adda.w	#scrxbytes/2,a0
	move.w	d3,d0
	lsr.w	#1,d0
	andi.w	#$fff8,d0
	sub.w	d0,a0
	bra.s	.alok
.right	adda.w	#scrxbytes,a0
	sub.w	d3,a0
.alok	move.l	4(a1),a1
	mulu.w	#scrxbytes,d1
	addi.l	#34,d1			skip degas header
	adda.l	d1,a1
	adda.w	d2,a1
	moveq	#0,d0
	move.w	d3,d0
	subq.w	#1,d7
	bpl.s	.cplp
	rts
.cplp	movem.l	d0/d7/a0/a1,-(sp)
	bsr	COPY_BUFFER
	movem.l	(sp)+,d0/d7/a0/a1
	lea	scrxbytes(a0),a0
	lea	scrxbytes(a1),a1
	dbra	d7,.cplp
	rts
.fnt	cmpi.w	#bigtexttype,d0
	bne.s	.lfont
	move.l	(a4),a2
	bsr	PLOT_BIGTEXTLINEU
	rts
.lfont	cmpi.w	#bigtexttype2,d0
	bne.s	.nfont
	move.l	(a4),a2
	bsr	PLOT_BIGTEXTLINEL
	rts
.nfont	move.l	(a4),a2
	lea	menufont_tbl,a1
	move.l	a1,a6
	lea	scrxbytes(a0),a0
	movea.w	#scrxbytes,a4
	moveq	#0,d1
	moveq	#80-1,d4

.loop	moveq	#0,d0
	move.b	(a2)+,d0
	cmpi.b	#$d,d0
	beq	.out
	cmpi.b	#' ',d0
	bne.s	.nospac
	move.l	d1,d3
	addq.w	#charwidth,d1			* Add width of character.
	cmpi.w	#16,d3
	blo.s	.hehe
	addq	#8,a0
	subi.w	#16,d3
	subi.w	#16,d1
.hehe	cmpa.l	a5,a2
	beq	.out
	dbra	d4,.loop
	rts
.nospac	cmpi.b	#240,d0
	blo.s	.noshit
	sub.b	#240,d0
	sub.l	d5,a0
	move.b	d0,d5
	add.l	d5,d5
	add.l	d5,a0
	bra.s	.loop
.noshit	move.l	d1,d3
	addq.w	#charwidth,d1			* Add width of character.
	lsl.w	#4,d0
	add.l	d0,a1
	cmpi.w	#16,d3
	blo.s	.chlp
	addq	#8,a0
	subi.w	#16,d3
	subi.w	#16,d1
.chlp	moveq	#0,d0
	move.w	(a1)+,d0
	beq.s	.1
	ror.l	d3,d0
	or.w	d0,(a0)
	swap	d0
	or.w	d0,8(a0)
.1	adda.l	a4,a0
	moveq	#0,d0
	move.w	(a1)+,d0
	beq.s	.2
	ror.l	d3,d0
	or.w	d0,(a0)
	swap	d0
	or.w	d0,8(a0)
.2	adda.l	a4,a0
	moveq	#0,d0
	move.w	(a1)+,d0
	beq.s	.3
	ror.l	d3,d0
	or.w	d0,(a0)
	swap	d0
	or.w	d0,8(a0)
.3	adda.l	a4,a0
	moveq	#0,d0
	move.w	(a1)+,d0
	beq.s	.4
	ror.l	d3,d0
	or.w	d0,(a0)
	swap	d0
	or.w	d0,8(a0)
.4	adda.l	a4,a0
	moveq	#0,d0
	move.w	(a1)+,d0
	beq.s	.5
	ror.l	d3,d0
	or.w	d0,(a0)
	swap	d0
	or.w	d0,8(a0)
.5	adda.l	a4,a0
	moveq	#0,d0
	move.w	(a1)+,d0
	beq.s	.6
	ror.l	d3,d0
	or.w	d0,(a0)
	swap	d0
	or.w	d0,8(a0)
.6	adda.l	a4,a0
	moveq	#0,d0
	move.w	(a1)+,d0
	beq.s	.7
	ror.l	d3,d0
	or.w	d0,(a0)
	swap	d0
	or.w	d0,8(a0)
.7	adda.l	a4,a0
	moveq	#0,d0
	move.w	(a1)+,d0
	beq.s	.8
	ror.l	d3,d0
	or.w	d0,(a0)
	swap	d0
	or.w	d0,8(a0)
.8	lea	-7*scrxbytes(a0),a0
	move.l	a6,a1
	cmpa.l	a2,a5
	beq.s	.out
	dbra	d4,.loop
.out	rts

PLOT_FULLTEXT
	clr.w	chrlin
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	REPT	16
	move.l	4(sp),d0
	cmp.w	textlines,d0
	bhi	.out
	move.l	(sp),a0
	bsr	PLOT_TEXTLINE
	add.l	#scrxbytes*charheight,(sp)
	addq.l	#1,4(sp)
	ENDR
.out	addq	#8,sp
	rts

PLOT_TEXTSCANLINE
	move.l	textlen,d2
	lea	(a2,d2.l),a5
	lea	txt_tbl,a4
	mulu.w	#6,d0
	add.l	d0,a4

.plotit	move.w	(a4)+,d0
	cmpi.w	#pictype,d0
	blt.s	.fnt
	cmpi.w	#endpictype,d0
	bhs.s	.fnt
	move.l	(a4),a1			Get address of piclin table entry
	move.w	(a1),d2			Get y-offset
	cmp.w	2(a1),d1
	blt.s	.linok
	rts				Go out if the linenumber exceeds piclenght
.linok	move.l	4(a1),a1		Get address of picpck table entry
	add.w	d2,d1			Add y-offset to line-number
	move.w	(a1),d2
	move.w	2(a1),d3
	lsl.w	#3,d3
	subi.w	#pictype,d0
	beq.s	.alok
	cmpi.b	#2,d0
	beq.s	.right
	adda.w	#scrxbytes/2,a0
	move.w	d3,d0
	lsr.w	#1,d0
	andi.w	#$fff8,d0
	sub.w	d0,a0
	bra.s	.alok
.right	adda.w	#scrxbytes,a0
	sub.w	d3,a0
.alok	move.l	4(a1),a1
	mulu.w	#scrxbytes,d1
	addi.l	#34,d1			skip degas header
	adda.l	d1,a1
	add.w	d2,a1
	moveq	#0,d0
	move.w	d3,d0
	bsr	COPY_BUFFER
	rts
.fnt	cmpi.w	#bigtexttype,d0
	bne.s	.lfont
	move.l	(a4),a2
	bsr	PLOT_BIGTEXTSCANLINEU
	rts
.lfont	cmpi.w	#bigtexttype2,d0
	bne.s	.nfont
	move.l	(a4),a2
	bsr	PLOT_BIGTEXTSCANLINEL
	rts
.nfont	move.l	(a4),a2
	lea	menufont_tbl,a1
	cmpi.w	#8,d1
	bne.s	.add
	rts
.add	add.w	d1,d1
	adda.w	d1,a1
	move.l	a1,a6
	lea	scrxbytes(a0),a0
	moveq	#0,d1
	moveq	#0,d5
	moveq	#80-1,d4

.loop	moveq	#0,d0
	move.b	(a2)+,d0
	cmpi.b	#$d,d0
	beq	.out
	cmpi.b	#' ',d0
	bne.s	.nospac
	move.l	d1,d3
	addq.w	#4,d1
	cmpi.w	#16,d3
	blo.s	.hehe
	addq	#8,a0
	subi.w	#16,d3
	subi.w	#16,d1
.hehe	cmpa.l	a5,a2
	beq	.out
	dbra	d4,.loop
	rts
.nospac	cmpi.b	#240,d0
	blo.s	.noshit
	subi.b	#240,d0
	sub.l	d5,a0
	move.b	d0,d5
	add.l	d5,d5
	add.l	d5,a0
	bra.s	.loop
.noshit	move.w	d1,d3
	addq.w	#4,d1			* Add width of character (=4).
	lsl.w	#4,d0
	add.l	d0,a1
	cmpi.w	#16,d3
	blo.s	.chlp
	addq	#8,a0
	subi.w	#16,d3
	subi.w	#16,d1
.chlp	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)
	swap	d0
	or.w	d0,8(a0)
	move.l	a6,a1
	cmpa.l	a2,a5
	beq.s	.out
	dbra	d4,.loop
.out	rts

PLOT_MOUSE
	moveq	#0,d0
	move.w	mse_tbl+2,d0
	cmpi.w	#txtbgnline,d0
	bge.s	.ypos
	moveq	#txtbgnline,d0
	bra.s	.movey
.ypos	cmpi.w	#scrlines-10,d0
	blt.s	.movey
	move.w	#scrlines-10,d0
.movey	move.w	d0,mse_tbl+2
	subi.w	#txtbgnline,d0
	add.w	chrlin,d0
	divu.w	#charheight,d0
	cmpi.w	#16,d0
	bhs.s	.norm
	add.w	actline,d0
	mulu.w	#6,d0
	lea	txt_tbl,a0
	cmpi.w	#linktype,0(a0,d0.l)
	bne.s	.norm
	lea	mse2_pic,a1
	bra.s	.mask
.norm	lea	mse_pic,a1
.mask	lea	10*2(a1),a2
	move.l	scr+4,a0
	tst.w	scrollcount
	bne.s	.skiprd
	move.l	a0,a6
	movem.w	mse_tbl+6,d0-d1
	andi.b	#$f0,d0
	lsr.w	#1,d0
	add.l	d0,a0
	mulu.w	#scrxbytes,d1
	add.l	d1,a0
	lea	mseback_buf,a3
	moveq	#10-1,d7
.restlp	REPT	4
	move.l	(a3)+,(a0)+
	ENDR
	lea	scrxbytes-16(a0),a0
	dbra	d7,.restlp
	move.l	a6,a0
.skiprd	movem.w	mse_tbl,d0-d1
	tst.l	d0
	bpl.s	.xpos
	moveq	#0,d0
	bra.s	.ty
.xpos	cmpi.w	#(scrxbytes*2)-10,d0
	blt.s	.ty
	move.w	#(scrxbytes*2)-10,d0
.ty	move.w	d0,mse_tbl
	movem.w	d0-d1,mse_tbl+6
	move.w	d0,d2
	lsr.w	#4,d0
	lsl.w	#3,d0
	add.l	d0,a0
	add.l	d0,d0
	sub.l	d0,d2
	mulu.w	#scrxbytes,d1
	add.l	d1,a0
	move.l	a0,a6
	lea	mseback_buf,a3
	moveq	#10-1,d7
.savelp	REPT	4
	move.l	(a0)+,(a3)+
	ENDR
	lea	scrxbytes-16(a0),a0
	dbra	d7,.savelp
	move.l	a6,a0
	moveq	#10-1,d7
.ylp	moveq	#-1,d0
	move.w	(a1)+,d0
	ror.l	d2,d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	swap	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	lea	-16(a0),a0
	REPT	4
	moveq	#0,d0
	move.w	(a2)+,d0
	ror.l	d2,d0
	or.w	d0,(a0)+
	swap	d0
	or.w	d0,6(a0)
	ENDR
	lea	scrxbytes-8(a0),a0
	dbra	d7,.ylp
	rts

PLOT_MOUSEBACK
	move.l	scr+4,a0
	movem.w	mse_tbl+6,d0-d1
	andi.b	#$f0,d0
	lsr.w	#1,d0
	add.l	d0,a0
	mulu.w	#scrxbytes,d1
	add.l	d1,a0
	lea	mseback_buf,a3
	moveq	#10-1,d7
.restlp	REPT	4
	move.l	(a3)+,(a0)+
	ENDR	
	lea	scrxbytes-16(a0),a0
	dbra	d7,.restlp
	rts

SAVE_ARTICLE
	bsr     STOP_MUSIC
.ende2	move    #$2700,SR
	clr.b   $FFFFFA1B.w     ;Timer B stoppen
	lea     sys_var,A0
	move.l  (A0)+,$70.w
	move.l  (A0)+,$68.w
	move.l  (A0)+,$0110.w
	move.l	(a0)+,$118.w
	move.l  (A0)+,$0120.w
	lea     $FFFFFA00.w,A1
	move.b	(a0)+,$01(a1)
	move.b	(a0)+,$03(a1)
	move.b	(a0)+,$05(a1)
	move.b  (A0)+,$07(A1)
	move.b  (A0)+,$09(A1)
	move.b	(a0)+,$0b(a1)
	move.b	(a0)+,$0d(a1)
	move.b	(a0)+,$0f(a1)
	move.b  (A0)+,$11(A1)
	move.b  (A0)+,$13(A1)
	move.b  (A0)+,$15(A1)
	move.b  (A0)+,$17(A1)
	move.l	a0,a2
	clr.b	$19(a1)
	clr.b	$1b(a1)
	clr.b	$1d(a1)
	addq	#3,a0
	move.b	(a0)+,d0 $1f(a1)
	move.b  (A0)+,d0 $21(A1)
	move.b  (A0)+,d0 $23(A1)
	move.b  (A0)+,d0 $25(A1)
	move.b	(a2)+,$19(a1)
	move.b	(a2)+,$1B(A1)
	move.b	(a2)+,$1d(a1)
	move.b  (A0)+,$0484.w
	move    #$2300,SR
	cmpi.w  #3,computer
	bne.s   .oldstres
.fscr	move.l	oldscr,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.w	oldfres,d0
	btst	#7,d0
	bne.s	.stfres
	move.w	d0,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq	#4,sp
	bsr	RESTORE_FV
	bra.s   .res_fertig
.stfres	move.w	d0,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq	#4,sp
	bra.s	.res_fertig
.oldstres
	move.b	oldstres+1,$ffff8260.w
	move.l	oldscr,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
.res_fertig
	movem.l oldst_pal,D0-D7
	movem.l D0-D7,$ffff8240.w

	move.l	#appl_init,aespb
	move.l	#aespb,d1
	move.l	#$c8,d0
	trap	#2
	move.w	#$19,-(sp)
	trap	#1
	addq	#2,sp
	addi.b	#'A',d0
	lea	ddir,a0
	move.b	d0,(a0)+
	move.b	#":",(a0)+
	move.b	#"\",(a0)+
	move.b	#"*",(a0)+
	move.b	#".",(a0)+
	move.b	#"*",(a0)+
	clr.b	(a0)
	move.l	#fsel_input,aespb
	lea	addrin,a0
	move.l	#ddir,(a0)+
	clr.b	fsel_file
	move.l	#fsel_file,(a0)+
	move.l	#aespb,d1
	move.l	#$c8,d0
	trap	#2
	move.l	#appl_exit,aespb
	move.l	#aespb,d1
	move.l	#$c8,d0
	trap	#2

	tst.w	intout+2
	beq.s	.skipsave

	lea	filename_txt,a0
	lea	fsel_file,a1
	lea	ddir,a2
.coplp1	move.b	(a2)+,(a0)+
	bne.s	.coplp1
.backlp	cmpi.b	#"\",-(a0)
	bne.s	.backlp
	addq	#1,a0
.coplp2	move.b	(a1)+,(a0)+
	bne.s	.coplp2

	move.w	#0,-(sp)			Fcreate
	move.l	#filename_txt,-(sp)
	move.w	#60,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,filhndl
;	bmi.s	.skipsave
	move.l	#text_buf,-(sp)			Fwrite
	move.l	textlen,-(sp)
	move.w	filhndl,-(sp)
	move.w	#64,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
;	bmi.s	.skipsave
	move.w	filhndl,-(sp)			Fclose
	move.w	#62,-(sp)
	trap	#1
	addq.l	#4,sp

.skipsave
	cmpi.w  #3,computer
	bne.s   .initstw1
	move.w	$ffff8006.w,d0
	lsr.w	#8,d0
	lsr.w	#6,d0
	subq.w	#2,d0
	bne.s	.dorgbcrap
	move.w	#%0000000010010010,d0
	bra.s	.setfalcres
.dorgbcrap
	move.w	#%0000000010100010,d0
.setfalcres
	move.w	d0,-(SP)       ; set new and get old F030 reso
	move.w	#88,-(SP)
	trap	#14
	addq	#4,SP
.initstw1
	move.b	#0,$ffff8260.w
	move	#$2700,sr
	lea     $FFFFFA00.w,A1
	clr.b   $1B(A1)         ;Timer B stoppen, wenn lÑuft
	bclr    #3,$17(A1)
	bclr	#4,$15(a1)
	bclr	#3,$fffffa17.w
	ori.b	#%00100001,$fffffa07.w
	ori.b	#%00100001,$fffffa13.w
	ori.b	#%01101000,$fffffa09.w
	move	#$2300,sr
	move.l  #NEWVBL,$70.w
	bsr	INIT_IKBD
	bsr	PLAY_MUSIC
	rts

FADE_IN	lea	pic_buf+4+2,a1
	lea	backup_pal+32(pc),a0
	moveq	#picnmbr-1,d7
.initlp	movem.l	(a1),d0-d6/a2
	movem.l	d0-d6/a2,(a0)
	lea	16*2(a0),a0
	moveq	#0,d0
	REPT	8
	move.l	d0,(a1)+
	ENDR
	adda.l	#picmaxsize-32,a1
	dbra	d7,.initlp

	move.l	#INSTALL_MAINHBL,HBL_IRQ
	moveq	#16-1,d7

.16lop	move.l	$466.w,d0
.466lp	cmp.l	$466.w,d0
	beq.s	.466lp

	lea	backup_pal(pc),a2
	lea	menu_pal,a1
	move.w	d7,-(sp)
	bsr.s	FADE_1UP
	move.w	(sp)+,d7

	lea	pic_buf+4+2,a1		Kick in startaddress of first pallette
	lea	backup_pal+32(pc),a2
	moveq	#picnmbr-1,d6

.pallp	move.l	a1,-(sp)
	move.l	a2,-(sp)
	move.w	d6,-(sp)
	move.w	d7,-(sp)
	bsr.s	FADE_1UP
	move.w	(sp)+,d7
	move.w	(sp)+,d6
	move.l	(sp)+,a2
	move.l	(sp)+,a1
	lea	16*2(a2),a2
	adda.l	#picmaxsize,a1
	dbra	d6,.pallp
	dbra	d7,.16lop
	rts

* INPUT: a1: startaddress of pallette to fade from.
*        a2: startaddress of pallette to fade to.
FADE_1UP
	moveq	#16-1,d6
.collop	move.w	(a1),d0
	move.w	(a2)+,d2
	move.w	d0,d1
	move.w	d2,d3
	andi.w	#$000f,d1
	andi.w	#$000f,d3
	cmp.w	d1,d3
	beq.s	.skipb
	bchg	#3,d0
	beq.s	.skipb
	addq	#1,d0
.skipb	move.w	d0,d1
	move.w	d2,d3
	andi.w	#$00f0,d1
	andi.w	#$00f0,d3
	cmp.w	d1,d3
	beq.s	.skipg
	bchg	#7,d0
	beq.s	.skipg
	add.w	#16,d0
.skipg	move.w	d0,d1
	move.w	d2,d3
	andi.w	#$0f00,d1
	andi.w	#$0f00,d3
	cmp.w	d1,d3
	beq.s	.skipr
	bchg	#11,d0
	beq.s	.skipr
	add.w	#256,d0
.skipr	move.w	d0,(a1)+
	dbra	d6,.collop
	rts

* Routine that fades out the menu pallette and all picture-pallettes.
* >Warning< The picture pallettes in pic_buf are affected!
FADE_OUT
	lea	backup_pal(pc),a0
	movem.l	menu_pal,d0-d6/a2
	movem.l	d0-d6/a2,(a0)
	moveq	#16-1,d7

.16lop	move.l	$466.w,d0
.p466lp	cmp.l	$466.w,d0
	beq.s	.p466lp
	lea	menu_pal,a1
	move.w	d7,-(sp)
	bsr.s	FADE_1DOWN
	move.w	(sp)+,d7

	lea	pic_buf+4+2,a1		Kick in startaddress of first pallette
	moveq	#picnmbr-1,d6

.pallp	move.l	a1,-(sp)
	move.w	d6,-(sp)
	move.w	d7,-(sp)
	bsr.s	FADE_1DOWN
	move.w	(sp)+,d7
	move.w	(sp)+,d6
	move.l	(sp)+,a1
	adda.l	#picmaxsize,a1
	dbra	d6,.pallp
	dbra	d7,.16lop

	move.l	#rts,HBL_IRQ
	rts

* INPUT: a1: startaddress of pallette to fade down
FADE_1DOWN
	moveq	#0,d0
	lea	end_pal,a0
	moveq	#8-1,d7
.clrlop	move.l	d0,(a0)+
	dbra	d7,.clrlop
* Fade down one step.
	lea	end_pal,a2
	moveq	#16-1,d6
.collop	move.w	(a1),d0
	move.w	(a2)+,d2
	move.w	d0,d1
	move.w	d2,d3
	andi.w	#$000f,d1
	andi.w	#$000f,d3
	cmp.w	d1,d3
	beq.s	.skipb
	bchg	#3,d0
	bne.s	.skipb
	subq.w	#1,d0
.skipb	move.w	d0,d1
	move.w	d2,d3
	andi.w	#$00f0,d1
	andi.w	#$00f0,d3
	cmp.w	d1,d3
	beq.s	.skipg
	bchg	#7,d0
	bne.s	.skipg
	subi.w	#16,d0
.skipg	move.w	d0,d1
	move.w	d2,d3
	andi.w	#$0f00,d1
	andi.w	#$0f00,d3
	cmp.w	d1,d3
	beq.s	.skipr
	bchg	#11,d0
	bne.s	.skipr
	subi.w	#256,d0
.skipr	move.w	d0,(a1)+
	dbra	d6,.collop
	rts

	bss

backup_pal
	ds.w	16*(picnmbr+1)

	text

* Routine that displays the intro picture (with fading and stuff).
SHOW_INTROPIC
* Load the intro picture + pallette into buffer.
	lea	intropicname_txt,a0
	lea	file_buf,a1
	bsr	LOAD_SHELLINCLUDE
* Wait for a VBL to occur and then clear the actual pallette
	move.l	$466.w,d0
.tstvbl	cmp.l	$466.w,d0
	beq.s	.tstvbl
	moveq	#0,d0
	lea	$ffff8240.w,a0
	lea	fade_pal,a1
	moveq	#8-1,d7
.clrlop	move.l	d0,(a0)+
	move.l	d0,(a1)+
	dbra	d7,.clrlop
* Set destination pallette and copy the picture to the screen
	lea	file_buf+2,a1
	movem.l	(a1)+,d0-d7
	movem.l	d0-d7,end_pal
	move.l	scr,a0
	bsr	COPY_STSCREEN
* Fade in one step.
	moveq	#16-1,d7
.fadeinloop
	lea	$ffff8240.w,a0
	lea	fade_pal,a1
	lea	end_pal,a2
	moveq	#16-1,d6
.collop	move.w	(a1),d0
	move.w	(a2)+,d2
	move.w	d0,d1
	move.w	d2,d3
	andi.w	#$000f,d1
	andi.w	#$000f,d3
	cmp.w	d1,d3
	beq.s	.skipb
	bchg	#3,d0
	beq.s	.skipb
	addq	#1,d0
.skipb	move.w	d0,d1
	move.w	d2,d3
	andi.w	#$00f0,d1
	andi.w	#$00f0,d3
	cmp.w	d1,d3
	beq.s	.skipg
	bchg	#7,d0
	beq.s	.skipg
	add.w	#16,d0
.skipg	move.w	d0,d1
	move.w	d2,d3
	andi.w	#$0f00,d1
	andi.w	#$0f00,d3
	cmp.w	d1,d3
	beq.s	.skipr
	bchg	#11,d0
	beq.s	.skipr
	add.w	#256,d0
.skipr	move.w	d0,(a1)+
	dbra	d6,.collop
* Wait 2 VBLs.
	move.l	$466.w,d0
.tst466	cmp.l	$466.w,d0
	beq.s	.tst466
	move.l	$466.w,d0
.ts466	cmp.l	$466.w,d0
	beq.s	.ts466
* Kick in new pallette
	movem.l	-32(a1),d0-d5/a3-a4
	movem.l	d0-d5/a3-a4,(a0)
	dbra	d7,.fadeinloop
	rts

INIT_SHELL
* Load in the shell graphics (menu + menu pallette).
	lea	menugfxname_txt,a0
	lea	file_buf,a1
	bsr	LOAD_SHELLINCLUDE
* Kick the pallette in the menu_pal buffer 
* and kick the graphics on screen 2.
	lea	file_buf+2,a1
	movem.l	(a1)+,d0-d7
	movem.l	d0-d7,menu_pal
	move.l	scr+4,a0
	move.l	#scrxbytes*24,d0
	lea	file_buf+34,a1
	bsr	COPY_BUFFER
	lea	file_buf+34+(scrxbytes*176),a1
	move.l	scr+4,a0
	lea	176*scrxbytes(a0),a0
	move.l	#scrxbytes*24,d0
	bsr	COPY_BUFFER
	lea	file_buf+34+(scrxbytes*24),a1
	bsr	INIT_MENUFONT
	lea	file_buf+34+(scrxbytes*42),a1
	bsr	INIT_BIGMENUFONT
	lea	file_buf+34+(scrxbytes*76),a1
	bsr	INIT_MOUSEPOINTER
	bsr	INIT_MOUSEBACK
* Load the menutext.
	lea	menutextname_txt,a0
	lea	text_buf,a1
	bsr	LOAD_SHELLINCLUDE
	move.l	d0,d7
	addq.l	#1,d7
	bsr	INIT_TEXT
	move.l	scr+4,a0
	lea	scrxbytes*txtbgnline(a0),a0
	moveq	#0,d0
	bsr	PLOT_FULLTEXT
	rts

WIPE_PIC2SHELL
	move.l	#WIPEHBL,$120.w
	bset	#0,$fffffa07.w
	bset	#0,$fffffa13.w

	move.w	#1,linenumber
	move.w	#200-1,d7
.wipeloop
	move.l	$466.w,d0
.wtvbl	cmp.l	$466.w,d0
	beq.s	.wtvbl

	move	#$2700,sr
	clr.b	$ffffffa1b.w
	move.b	linenumber+1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move	#$2300,sr

	movem.l	menu_pal,d0-d6/a0
	movem.l	d0-d6/a0,$ffff8240.w
	move.l	scr,a0
	move.l	scr+4,a1
	move.w	linenumber,d0
	subq.w	#1,d0
	mulu.w	#scrxbytes,d0
	add.l	d0,a0
	add.l	d0,a1
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,96(a0)
	movem.l	(a1)+,d0-d3
	movem.l	d0-d3,144(a0)
	
	addq.w	#1,linenumber
	dbra	d7,.wipeloop

	move.w	#$2700,sr
	clr.b	$fffffa1b.w
	bclr	#0,$fffffa07.w
	bclr	#0,$fffffa13.w
	move.w	#$2300,sr

	movem.l	menu_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

GET_CONTROLS
	movem.w	mse_tbl,d0-d2
	tst.w	d2
	beq.s	.rts
	btst	#9,d2
	bne.s	.left
	moveq	#10,d0
	rts
.left	cmpi.w	#200-24,d1
	bhs.s	.bar
	move.w	actline,d0
	subi.w	#txtbgnline,d1
	add.w	chrlin,d1	
	divu.w	#charheight,d1
	add.w	d1,d0
	lea	txt_tbl,a0
	mulu.w	#6,d0
	move.l	2(a0,d0.l),a0
.tstlp	move.b	(a0)+,d0
	cmpi.b	#specialtype,d0
	beq.s	.ok
	cmpi.b	#$d,d0
	bne.s	.tstlp
	bra.s	.rts
.ok	addq	#1,a0
	cmpi.b	#'\',(a0)+
	bne.s	.rts
	bsr	EXTRACT_NAMEFROMETEXT
	moveq	#20,d0
	rts
.rts	moveq	#0,d0
	rts
.bar	cmpi.w	#45,d0
	bhs.s	.help
	moveq	#1,d0
	rts
.help	cmpi.w	#96,d0
	bhs.s	.save
	moveq	#2,d0
	rts
.save	cmpi.w	#146,d0
	bhs.s	.tmus
	moveq	#3,d0
	rts
.tmus	cmpi.w	#200,d0
	bhs.s	.mus1
	moveq	#11,d0
	rts
.mus1	cmpi.w	#216,d0
	bhs.s	.mus2
	moveq	#4,d0
	rts
.mus2	cmpi.w	#232,d0
	bhs.s	.mus3
	moveq	#5,d0
	rts
.mus3	cmpi.w	#256,d0
	bhs.s	.off
	moveq	#6,d0
	rts
.off	cmpi.w	#289,d0
	bhs.s	.down
	moveq	#9,d0
	rts
.down	cmpi.w	#303,d0
	bhs.s	.up
	moveq	#7,d0
	rts
.up	moveq	#8,d0
	rts

DO_SHELLMAINLOOP
	lea	mse_tbl,a0
	move.w	#scrxbytes*2/2,(a0)+
	move.w	#scrlines/2,(a0)+

	bset	#0,$fffffa07.w
	bset	#0,$fffffa13.w
	move.l	#INSTALL_MAINHBL,HBL_IRQ

	lea	scr,a0
	move.l	(a0),d0
	move.l	4(a0),(a0)+
	move.l	d0,(a0)

.loop	move.w	actline,actlin2
	lea	scr,a0
	move.l	(a0),d0
	move.l	4(a0),(a0)+
	move.l	d0,(a0)
.noswap	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

	move.l	$466.w,d0
.tstvbl	cmp.l	$466.w,d0
	beq.s	.tstvbl

	move.b	keycode,d0
	cmpi.b	#$1f,d0
	beq	.save
	cmpi.b	#$62,d0
	beq	.help
	cmpi.b	#$48,d0
	beq	.up
	cmpi.b	#$50,d0
	beq	.down
	cmpi.b	#$4b,d0
	beq	.left
	cmpi.b	#$4d,d0
	beq	.right
	cmpi.b	#$39,d0
	beq	.qsub
	cmpi.b	#$32,d0
	beq	.off
.getctr	bsr	GET_CONTROLS
	cmpi.b	#1,d0
	bne.s	.else
	rts
.else	cmpi.b	#10,d0
	beq	.qsub
	cmpi.b	#2,d0
	beq	.help
	cmpi.b	#4,d0
	beq	.sng1
	cmpi.b	#5,d0
	beq	.sng2
	cmpi.b	#6,d0
	beq	.sng3
	cmpi.b	#7,d0
	beq	.down
	cmpi.b	#9,d0
	beq	.off
	cmpi.b	#11,d0
	beq	.music
	cmpi.b	#8,d0
	beq.s	.up
	cmpi.b	#20,d0
	beq	.newart
	cmpi.b	#3,d0
	beq	.save
	bsr	PLOT_MOUSE
	clr.w	scrollcount
	move.l	scr+4,d0
	cmpi.b	#$1,keycode			* Escape key..
	bne	.noswap
	move.l	#rts,HBL_IRQ
	move.w	#$2700,sr
	clr.b	$fffffa1b.w
	bclr	#0,$fffffa07.w
	bclr	#0,$fffffa13.w
	move.w	#$2300,sr
	rts

.up	move.l	scr+4,d0
	tst.w	actline
	bgt.s	.hushb
	tst.w	chrlin
	beq	.noswap
	IFNE	fastscroll
	cmpi.w	#50,scrollcount
	blt.s	.hushb
	cmpi.w	#1,chrlin
	bls	.noswap
	ENDC
.hushb	tst.w	scrollcount
	bne.s	.skiprd
	move.l	d0,-(sp)
	bsr	PLOT_MOUSEBACK
	move.l	(sp)+,d0
.skiprd	addq.w	#1,scrollcount
	cmpi.w	#50,scrollcount
	IFNE	fastscroll
	blt	.onescan_u
	ELSE
	bra	.onescan_u
	ENDC
	lea	scr,a2
	move.l	(a2)+,a0
	move.l	(a2)+,a1
	lea	scrxbytes*(txtbgnline+2)(a0),a0
	lea	scrxbytes*txtbgnline(a1),a1
	move.l	#((16*charheight)-2)*scrxbytes,d0
	bsr	COPY_BUFFER
	move.l	scr,a0
	lea	scrxbytes*txtbgnline(a0),a0
	bsr	CLEAR_320BYTES
	move.l	scr,a0
	lea	scrxbytes*(txtbgnline+1)(a0),a0
	move.w	actline,d0
	move.w	chrlin,d1
	subq.w	#1,d1
	bpl.s	.skipc1a
	subq.w	#1,d0
	moveq	#8,d1
.skipc1a
	move.w	d0,actline
	move.w	d1,chrlin
	bsr	PLOT_TEXTSCANLINE
	move.l	scr,a0
	lea	scrxbytes*txtbgnline(a0),a0
	move.w	actline,d0
	move.w	chrlin,d1
	subq.w	#1,d1
	bpl.s	.skipc1b
	subq.w	#1,d0
	moveq	#charheight-1,d1
.skipc1b
	move.w	d0,actline
	move.w	d1,chrlin
	bsr	PLOT_TEXTSCANLINE
	bra	.loop
.onescan_u
	move.l	scr,a0
	move.l	scr+4,a1
	lea	scrxbytes*(txtbgnline+1)(a0),a0
	lea	scrxbytes*txtbgnline(a1),a1
	move.l	#((16*charheight)-1)*scrxbytes,d0
	bsr	COPY_BUFFER
	move.l	scr,a0
	lea	scrxbytes*txtbgnline(a0),a0
	bsr	CLEAR_160BYTES
	move.l	scr,a0
	lea	scrxbytes*txtbgnline(a0),a0
	move.w	actline,d0
	move.w	chrlin,d1
	subq.w	#1,d1
	bpl.s	.skipc1
	subq.w	#1,d0
	moveq	#charheight-1,d1
.skipc1	move.w	d0,actline
	move.w	d1,chrlin
	bsr	PLOT_TEXTSCANLINE
	bra	.loop
.down	move.l	scr+4,d0
	move.w	actline,d1
	addi.w	#15+1,d1
	cmp.w	textlines,d1
	bgt	.noswap
	tst.w	scrollcount
	bne.s	.skipr2
	bsr	PLOT_MOUSEBACK
.skipr2	addq.w	#1,scrollcount
	cmpi.w	#50,scrollcount
	IFNE	fastscroll
	blt	.onescan_d
	ELSE
	bra	.onescan_d
	ENDC
	lea	scr,a2
	move.l	(a2)+,a0
	move.l	(a2)+,a1
	lea	scrxbytes*txtbgnline(a0),a0
	lea	scrxbytes*(txtbgnline+2)(a1),a1
	move.l	#((16*charheight)-2)*scrxbytes,d0
	bsr	COPY_BUFFER
	move.l	scr,a0
	lea	scrxbytes*(txtbgnline+((16*charheight)-2))(a0),a0
	bsr	CLEAR_320BYTES
	move.l	scr,a0
	lea	scrxbytes*(txtbgnline+((16*charheight)-3))(a0),a0
	move.w	actline,d0
	move.w	chrlin,d2
	addq.w	#1,d2
	move.w	d2,d1
	cmpi.b	#charheight,d2
	bne.s	.skipc3
	moveq	#0,d2
	addq.w	#1,d0
.skipc3	move.w	d2,chrlin
	move.w	d0,actline
	move.w	d2,d1
	subq.w	#2,d1
	bpl.s	.skipd
	addi.w	#charheight,d1
	subq.w	#1,d0
.skipd	addi.w	#15+1,d0
	bsr	PLOT_TEXTSCANLINE
	move.l	scr,a0
	lea	scrxbytes*(txtbgnline+((16*charheight)-2))(a0),a0
	move.w	actline,d0
	move.w	chrlin,d2
	addq.w	#1,d2
	move.w	d2,d1
	cmpi.b	#charheight,d2
	bne.s	.skipc3a
	moveq	#0,d2
	addq.w	#1,d0
.skipc3a
	move.w	d2,chrlin
	move.w	d0,actline
	move.w	d2,d1
	subq.w	#2,d1
	bpl.s	.skipda
	addi.w	#charheight,d1
	subq.w	#1,d0
.skipda	addi.w	#15+1,d0
	bsr	PLOT_TEXTSCANLINE
	bra	.loop
.onescan_d
	move.l	scr,a0
	move.l	scr+4,a1
	lea	scrxbytes*txtbgnline(a0),a0
	lea	scrxbytes*(txtbgnline+1)(a1),a1
	move.l	#((16*charheight)-1)*scrxbytes,d0
	bsr	COPY_BUFFER
	move.l	scr,a0
	lea	scrxbytes*(txtbgnline+((16*charheight)-1))(a0),a0
	bsr	CLEAR_160BYTES
	move.l	scr,a0
	lea	scrxbytes*(txtbgnline+((16*charheight)-2))(a0),a0
	move.w	actline,d0
	move.w	chrlin,d2
	addq.w	#1,d2
	move.w	d2,d1
	cmpi.b	#charheight,d2
	bne.s	.skipc3_2
	moveq	#0,d2
	addq.w	#1,d0
.skipc3_2
	move.w	d2,chrlin
	move.w	d0,actline
	move.w	d2,d1
	subq.w	#2,d1
	bpl.s	.skipd_2
	addi.w	#charheight,d1
	subq.w	#1,d0
.skipd_2
	addi.w	#15+1,d0
	bsr	PLOT_TEXTSCANLINE
	bra	.loop
.left	move.l	scr+4,d0
	move.w	actline,d1
	beq	.noswap
	tst.w	scrollcount
	bne	.noswap
	movem.l	d0-d1,-(sp)
	bsr	PLOT_MOUSEBACK
	movem.l	(sp)+,d0-d1
	addq.w	#1,scrollcount
	sub.w	#16,d1
	bpl.s	.d1ok
	moveq	#0,d1
.d1ok	move.w	d1,d0
	move.w	d0,actline
	move.l	scr,a0
	lea	txtbgnline*scrxbytes(a0),a0
	movem.l	d0/a0,-(sp)
	move.l	#scrxbytes*144,d0
	bsr	CLEAR_BUFFER
	movem.l	(sp)+,d0/a0
	bsr	PLOT_FULLTEXT
	bra	.loop
.right	move.l	scr+4,d0
	move.w	actline,d2
	addi.w	#16,d2
	cmp.w	textlines,d2
	beq	.noswap
	tst.w	scrollcount
	bne	.noswap
	movem.l	d0/d2,-(sp)
	bsr	PLOT_MOUSEBACK
	movem.l	(sp)+,d0/d2
	addq.w	#1,scrollcount
	move.w	textlines,d1
	subi.w	#15,d1
	cmp.w	d1,d2
	bmi.s	.ready
	move.w	textlines,d2
	subi.w	#15,d2
.ready	move.w	d2,d0
	move.w	d0,actline
	move.l	scr,a0
	lea	txtbgnline*scrxbytes(a0),a0
	movem.l	d0/a0,-(sp)
	move.l	#scrxbytes*144,d0
	bsr	CLEAR_BUFFER
	movem.l	(sp)+,d0/a0
	bsr	PLOT_FULLTEXT
	bra	.loop
.newart	move.w	actline,oldline
	bsr	PLOT_MOUSEBACK
	bsr	FADE_OUT
	lea	filename_txt,a0
	lea	text_buf,a1
	bsr	LOAD_SHELLINCLUDE
	move.l	d0,d7
	addq.l	#1,d7
	bsr	INIT_TEXT
	move.l	scr,a0
	lea	scrxbytes*txtbgnline(a0),a0
	move.l	a0,-(sp)
	move.l	#scrxbytes*144,d0
	bsr	CLEAR_BUFFER
	move.l	(sp)+,a0
	moveq	#0,d0
	bsr	PLOT_FULLTEXT
	move.l	scr+4,a0
	lea	scrxbytes*txtbgnline(a0),a0
	move.l	a0,-(sp)
	move.l	#scrxbytes*144,d0
	bsr	CLEAR_BUFFER
	move.l	(sp)+,a0
	moveq	#0,d0
	bsr	PLOT_FULLTEXT
	moveq	#0,d0
	move.w	d0,actline
	move.w	d0,actlin2
	moveq	#1,d0
	move.w	d0,scrollcount
	move.w	d0,subart
	bsr	FADE_IN
	bra	.loop
.qsub	tst.w	subart
	bne.s	.dombo
	move.l	scr+4,d0
	bra	.noswap
.dombo	bsr	PLOT_MOUSEBACK
	bsr	FADE_OUT
	lea	menutextname_txt,a0
	lea	text_buf,a1
	bsr	LOAD_SHELLINCLUDE
	move.l	d0,d7
	addq.l	#1,d7
	bsr	INIT_TEXT
	move.w	oldline,d0
	tst.w	hlpmode
	beq.s	.nohelp
	moveq	#0,d0
.nohelp	move.w	d0,actline
	move.w	d0,actlin2
	move.l	scr,a0
	lea	scrxbytes*txtbgnline(a0),a0
	move.l	a0,-(sp)
	move.l	#scrxbytes*144,d0
	bsr	CLEAR_BUFFER
	move.l	(sp)+,a0
	move.w	actline,d0
	bsr	PLOT_FULLTEXT
	move.l	scr+4,a0
	lea	scrxbytes*txtbgnline(a0),a0
	move.l	a0,-(sp)
	move.l	#scrxbytes*144,d0
	bsr	CLEAR_BUFFER
	move.l	(sp)+,a0
	move.w	actline,d0
	bsr	PLOT_FULLTEXT
	move.w	#1,scrollcount
	moveq	#0,d0
	move.w	d0,subart
	move.w	d0,hlpmode
	bsr	FADE_IN
	bra	.loop
.help	move.w	#1,hlpmode
	lea	helptextname_txt,a1
	lea	filename_txt,a0
.hcplp	move.b	(a1)+,(a0)+
	bne.s	.hcplp
	bra	.newart
.off	tst.w	music
	beq.s	.stopm
	bsr	PLAY_MUSIC
	bra.s	.doloop
.stopm	bsr	STOP_MUSIC
	move	#$2700,sr
	bclr	#4,$fffffa15.w
	ori.b	#%01101000,$fffffa09.w
	move	#$2300,sr
.doloop	clr.b	mse_tbl+4
	move.l	$466.w,d0
.timlop	move.l	$466.w,d1
	sub.l	d0,d1
	cmpi.w	#25,d1
	bne.s	.timlop
	move.l	scr+4,d0
	bra	.noswap
.sng1	bsr	STOP_MUSIC
	move.w	#1,sngnum
	bsr	PLAY_MUSIC
	move.l	scr+4,d0
	bra	.noswap
.sng2	bsr	STOP_MUSIC
	move.w	#2,sngnum
	bsr	PLAY_MUSIC
	move.l	scr+4,d0
	bra	.noswap
.sng3	bsr	STOP_MUSIC
	move.w	#3,sngnum
	bsr	PLAY_MUSIC
	move.l	scr+4,d0
	bra	.noswap
.save	bsr	SAVE_ARTICLE
	clr.b	mse_tbl+4
	move.l	$466.w,d0
.timlp2	move.l	$466.w,d1
	sub.l	d0,d1
	cmpi.w	#25,d1
	bne.s	.timlp2
	move.l	scr+4,d0
	bra	.noswap
.music	cmpi.w	#3,computer
	bne.s	.f242
	bsr	STOP_MUSIC
	not.w	falcmus
	move.w	#1,sngnum
	bsr	PLAY_MUSIC
.f242	move.l	$466.w,d0
.timlp3	move.l	$466.w,d1
	sub.l	d0,d1
	cmpi.w	#25,d1
	bne.s	.timlp3
	move.l	scr+4,d0
	bra	.noswap

******** INTERRUPTS ********

NEWVBL	movem.l	d0-a6,-(sp)
	move.l	HBL_IRQ(pc),a0
	jsr	(a0)
	move.l	MUSIC_IRQ(pc),a0
	jsr	(a0)
	movem.l	(sp)+,d0-a6
	addq.l	#1,$466.w
	rte

MUSIC_IRQ
	dc.l	rts
HBL_IRQ	dc.l	rts

rts	rts

INSTALL_MAINHBL
	lea	hbl_tbl,a0
	move.w	#1,(a0)+
	lea	2(a0),a1
	lea	txt_tbl,a2
	move.w	actlin2,d0
	mulu.w	#6,d0
	adda.l	d0,a2
	moveq	#0,d7
	moveq	#txtbgnline-4,d1	*
	move.w	d1,(a1)+
	move	#$2700,sr
	clr.b	$fffffa1b.w
	move.b	d1,$fffffa21.w
	move.l	#MAINHBL,$120.w
	move.b	#8,$fffffa1b.w
	move	#$2300,sr
	move.w	(a2)+,d0
	cmpi.w	#pictype,d0
	blt.s	.nopc
	cmpi.w	#endpictype,d0
	bhi.s	.nopc
	move.l	(a2),a3			* Get address of piclin table entry
	move.l	4(a3),a3		* Get address of picpck table entry
	move.l	4(a3),a3		* Get address of picture
	addq	#2,a3
	move.l	a3,(a1)+		* Pallette address
	bra.s	.doloop
.nopc	move.l	#menu_pal,(a1)+
.doloop	addq.w	#1,d7
	subq	#2,a2
	move.w	d1,d2
	addi.w	#charheight+4,d1	* 4 scanlines between upper bar and 2nd textline
	sub.w	chrlin,d1
.loop	move.w	d1,d3
	sub.w	d2,d3
	move.w	d3,(a1)+
	move.w	(a2)+,d0
	cmpi.w	#pictype,d0
	blt.s	.nopic
	cmpi.w	#endpictype,d0
	bhi.s	.nopic
	move.l	(a2),a3			* Get address of piclin table entry
	move.l	4(a3),a3		* Get address of picpck table entry
	move.l	4(a3),a3		* Get address of picture
	addq	#2,a3
	move.l	a3,(a1)+		* Pallette address
	bra.s	.lpend
.nopic	move.l	#menu_pal,(a1)+
.lpend	addq	#4,a2
	move.w	d1,d2
	addq.w	#1,d7
	addi.w	#charheight,d1
	cmpi.w	#txtbgnline+(16*charheight),d2
	blt.s	.loop
	subi.w	#txtbgnline+(16*charheight),d2
	beq.s	.skip
	sub.w	d2,-6(a1)
.skip	move.l	#menu_pal,2(a1)
	move.w	d7,(a0)+
	rts

WIPEHBL	move	#$2700,sr
	movem.l	a0-a1,-(sp)
	lea	end_pal,a1
	lea	$ffff8240.w,a0
	REPT	8
	move.l	(a1)+,(a0)+
	ENDR
	movem.l	(sp)+,a0-a1
	clr.b	$ffffffa1b.w
	move	#$2300,sr
	rte

MAINHBL	move	#$2700,sr
	movem.l	d0-d1/a0-a1,-(sp)
	lea	hbl_tbl,a0
	movem.w	(a0),d0-d1
	cmp.w	d0,d1
	bne.s	.on
	add.w	d0,d0			/
	move.w	d0,d1			| mulu.w #6,d0
	add.w	d0,d0			|
	add.w	d1,d0			\
	move.l	4+2(a0,d0.l),a1
	lea	$ffff8240.w,a0
	REPT	8
	move.l	(a1)+,(a0)+
	ENDR
	clr.b	$fffffa1b.w
	bra.s	.end
.on	addq.w	#1,(a0)
	add.w	d0,d0			/
	move.w	d0,d1			| mulu.w #6,d0
	add.w	d0,d0			|
	add.w	d1,d0			\
	lea	4(a0,d0.l),a0
	clr.b	$fffffa1b.w
	move.w	(a0)+,d0
	move.b	d0,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	(a0)+,a1
	lea	$ffff8240.w,a0
	REPT	8
	move.l	(a1)+,(a0)+
	ENDR
.end	movem.l	(sp)+,d0-d1/a0-a1
	move	#$2300,sr
	rte

NEW118	move.w	d0,-(sp)
;	move.l	a0,-(sp)
.over_again
	move.b	$fffffc02.w,d0
	tst.w	.msepck
	bne.s	.get_mouse
	cmpi.b	#$f8,d0
	blt.s	.no_mouse
	cmpi.b	#$fb,d0
	ble	.mouse_comming		;	ble.s	.mouse_comming
.no_mouse
;	lea	spckey_tbl,a0
;	cmpi.b	#$1d,d0
;	beq.s	.control_press
;	cmpi.b	#$36,d0
;	beq.s	.shift_press
;	cmpi.b	#$2a,d0
;	beq.s	.shift_press
;	cmpi.b	#$38,d0
;	beq.s	.alt_press
;	cmpi.b	#$3a,d0
;	beq.s	.caps_press
;	cmpi.b	#$9d,d0
;	beq.s	.control_press
;	cmpi.b	#$b6,d0
;	beq.s	.shift_release
;	cmpi.b	#$aa,d0
;	beq.s	.shift_release
;	cmpi.b	#$b8,d0
;	beq.s	.alt_press
	move.b	d0,keycode
	bra.s	.exit
;.shift_press
;	addq.w	#1,shiftkey		;(a0)
;	bra.s	.exit
;.shift_release
;	subq.w	#1,shiftkey		;(a0)
;	bra.s	.exit
;.control_press
;	tst.b	d0
;	sgt	controlkey		;2(a0)
;	bra.s	.exit
;.alt_press
;	tst.b	d0
;	sgt	altkey			;4(a0)
;	bra.s	.exit
;.caps_press
;	tst.w	capskey
;	seq	capskey			;6(a0)
;	bra.s	.exit
.get_mouse
	ext.w	d0
	cmpi.w	#1,.msepck
	beq.s	.gtmse1
	tst.b	mse_tbl+4
	bne.s	.spck1
	add.w	d0,mse_tbl
.spck1	subq.w	#1,.msepck
	bra.s	.exit
.gtmse1	tst.b	mse_tbl+4
	bne.s	.spck2
	add.w	d0,mse_tbl+2
.spck2	clr.w	.msepck
	bra.s	.exit
.mouse_comming
	move.w	#2,.msepck
	andi.b	#%00000011,d0
	move.b	d0,mse_tbl+4
.exit	btst.b	#4,$fffffa01.w
	beq	.over_again		;	beq.s	.over_again
;	move.l	(sp)+,a0
	move.w	(sp)+,d0
	rte

.msepck	dc.w	0

******** DATA + INCLUDES ********

	data

amplay_bin
	INCBIN	AMSID3D2.BIN
	even

font_dat
	INCBIN	FONT48.DAT

bigcharloc_tbl
	REPT	32
	dc.w	0,190,3
	ENDR
	dc.w	304,113,10		' ' 32
	dc.w	217,17,5		'!' 33
	dc.w	222,17,8		'"' 34
	dc.w	98,27,6			'#' 35
	dc.w	260,0,4			'$' 36
	dc.w	264,0,4			'%' 37
	dc.w	268,0,4			'&' 38
	dc.w	275,16,5		''' 39
	dc.w	251,16,8		'(' 40
	dc.w	259,16,6		')' 41
	dc.w	284,0,4			'*' 42
	dc.w	308,16,8		'+' 43
	dc.w	297,16,4		',' 44
	dc.w	300,16,8		'-' 45
	dc.w	292,16,4		'.' 46
	dc.w	243,16,8		'/' 47
	dc.w	206,17,10		'0' 48
	dc.w	111,17,8		'1' 49
	dc.w	119,17,11		'2' 50
	dc.w	130,17,10		'3' 51
	dc.w	140,17,10		'4' 52
	dc.w	150,17,11		'5' 53
	dc.w	161,17,12		'6' 54
	dc.w	174,17,10		'7' 55
	dc.w	184,17,10		'8' 56
	dc.w	194,17,12		'9' 57
	dc.w	12,36,4			':' 58
	dc.w	16,36,4			';' 59
	dc.w	280,16,6		'<' 60
	dc.w	284,0,4			'=' 61
	dc.w	286,16,6		'>' 62
	dc.w	288,0,4			'?' 63
	dc.w	92,27,5			'@' 64
	dc.w	0,0,14			'A' 65
	dc.w	14,0,14			'B' 66
	dc.w	28,0,15			'C' 67
	dc.w	43,0,15			'D' 68
	dc.w	58,0,15			'E' 69
	dc.w	73,0,13			'F' 70
	dc.w	86,0,16			'G' 71
	dc.w	102,0,16		'H' 72
	dc.w	118,0,6			'I' 73
	dc.w	124,0,12		'J' 74
	dc.w	136,0,15		'K' 75
	dc.w	152,0,13		'L' 76
	dc.w	165,0,16		'M' 77
	dc.w	185,0,14		'N' 78
	dc.w	199,0,16		'O' 79
	dc.w	216,0,14		'P' 80
	dc.w	230,0,16		'Q' 81
	dc.w	247,0,16		'R' 82
	dc.w	262,0,12		'S' 83
	dc.w	274,0,14		'T' 84
	dc.w	288,0,15		'U' 85
	dc.w	303,0,16		'V' 86
	dc.w	0,16,16			'W' 87
	dc.w	22,16,15		'X' 88
	dc.w	37,16,14		'Y' 89
	dc.w	52,16,13		'Z' 90
	dc.w	0,0,4			'[' 91
	dc.w	36,36,4			'\' 92
	dc.w	0,0,4			']' 93
	dc.w	300,0,4			'^' 94
	dc.w	32,36,4			'_' 95
	dc.w	275,16,5		'`' 96
	dc.w	104,0,4			'a' 97
	dc.w	108,0,4			'b' 98
	dc.w	112,0,4			'c' 99
	dc.w	116,0,4			'd' 100
	dc.w	120,0,4			'e' 101
	dc.w	124,0,4			'f' 102
	dc.w	128,0,4			'g' 103
	dc.w	132,0,4			'h' 104
	dc.w	136,0,4			'i' 105
	dc.w	140,0,4			'j' 106
	dc.w	144,0,4			'k' 107
	dc.w	148,0,4			'l' 108
	dc.w	152,0,4			'm' 109
	dc.w	156,0,4			'n' 110
	dc.w	160,0,4			'o' 111
	dc.w	164,0,4			'p' 112
	dc.w	168,0,4			'q' 113
	dc.w	172,0,4			'r' 114
	dc.w	176,0,4			's' 115
	dc.w	180,0,4			't' 116
	dc.w	184,0,4			'u' 117
	dc.w	188,0,4			'v' 118
	dc.w	192,0,4			'w' 119
	dc.w	196,0,4			'x' 120
	dc.w	200,0,4			'y' 121
	dc.w	204,0,4			'z' 122
	dc.w	0,0,4			'{' 123
	dc.w	308,0,4			'|' 124
	dc.w	0,0,4			'}' 125
	dc.w	88,27,5			'~' 126
	dc.w	0,0,4			'' 127
	dc.w	0,0,4			'Ä' 128
	dc.w	84,27,4			'Å' 129
	dc.w	0,0,4			'Ç' 130
	dc.w	0,0,4			'É' 131
	dc.w	68,27,4			'Ñ' 132
	REPT	9	
	dc.w	0,0,4
	ENDR
	dc.w	65,16,14		'é' 142
	REPT	5
	dc.w	0,0,4
	ENDR
	dc.w	76,27,4			'î' 148
	dc.w	0,0,4			'ï' 149
	dc.w	0,0,4			'ñ' 150
	dc.w	0,0,4			'ó' 151
	dc.w	0,0,4			'ò' 152
	dc.w	79,16,13		'ô' 153
	dc.w	96,16,15		'ö' 154
	REPT	70
	dc.w	0,0,4
	ENDR
	dc.w	292,0,4			'·' 225
	REPT	30
	dc.w	0,0,4
	ENDR

npropfntedge_tbl
	dc.w	%0000000000000000
	dc.w	%1000000000000000
	dc.w	%1100000000000000
	dc.w	%1110000000000000
	dc.w	%1111000000000000
	dc.w	%1111100000000000
	dc.w	%1111110000000000
	dc.w	%1111111000000000
	dc.w	%1111111100000000
	dc.w	%1111111110000000
	dc.w	%1111111111000000
	dc.w	%1111111111100000
	dc.w	%1111111111110000
	dc.w	%1111111111111000
	dc.w	%1111111111111100
	dc.w	%1111111111111110
	dc.w	%1111111111111111

* gem-fileselector-data
aespb	dc.l	contrl,global,intin,intout,addrin,addrout
fsel_input
	dc.w	90,0,2,2,0
appl_init
	dc.w	10,0,1,0,0
appl_exit
	dc.w	19,0,1,0,0

* Required filenames in data
menugfxname_txt
	dc.b	"MENU_GFX.PI1",0
menutextname_txt
	dc.b	"MENUTEXT.TXT",0
helptextname_txt
	dc.b	"HELPTEXT.TXT",0
intropicname_txt
	dc.b	"STARTPIC.PI1",0
modname_txt
	dc.b	"AUTOPLAY.MOD",0

******** RESERVES ********

	bss

	even

* New stack area.
	ds.l	256
ustk	ds.l	1
* GEM shit!
* gem-fileselector-reserves
contrl	ds.w	128
intin	ds.w	128
intout	ds.w	128
global	ds.w	16
addrin	ds.w	128
addrout	ds.w	128
fsel_file
	ds.w	8
ddir	ds.b	64
* Save stuffs.
oldsp	ds.l	1
oldscr	ds.l	1
oldvbl	ds.l	1
oldfres	ds.w	1
oldstres
	ds.w	1
oldst_pal
	ds.w	16
fvbuf	ds.w	24
sys_var	ds.l	17
oldmse_adr
	ds.l	1
mserout_adr
	ds.l	1
* Timer shit
linenumber
	ds.w	1
old466	ds.l	1
hbl_tbl	ds.w	2
	ds.w	20*3
* Control buffers
mse_tbl	ds.w	5
keycode	ds.w	1
	EVEN
* Disk handles/buffers
filhndl	ds.w	1
filedata_buf
	ds.b	44
file_buf
	ds.l	65536/4
libmem_buf
	ds.b	512*24+2
* Data about current status of computer/shell
computer
	ds.w	1			/ Keep
monitor	ds.w	1			| these
blitter	ds.w	1			\ toghether
music	ds.w	1
sngnum	ds.w	1
falcmus	ds.w	1
sngtype	ds.w	1
* Text-stuffs
subart	ds.w	1
hlpmode	ds.w	1
actline	ds.w	1
actlin2	ds.w	1
oldline	ds.w	1
chrlin	ds.w	1
filename_txt
	ds.b	64
oldartname_txt
	ds.b	64
gentext_txt
	ds.b	16
textlines
	ds.w	1
txt_tbl	ds.w	3*5000
textlen	ds.l	1
text_buf
	ds.l	40000
scrollcount
	ds.w	1
* Screenbuffers + pallettes + musicbufs
menu_pal
	ds.w	16
fade_pal
	ds.w	16
end_pal	ds.w	16
scr	ds.l	1
	ds.l	1
scrbuf	ds.b	256
	ds.l	scrbufsize/4
	ds.l	scrbufsize/4
	ds.w	4
piclin_tbl
	ds.w	1			number of entries in picture table
	ds.w	3*80			80 entries max!
pic_buf	ds.l	1			endaddress of last picture
	ds.b	picmaxsize*picnmbr
picpck_tbl
	ds.w	1			number of entries in packet table
	ds.w	4*30			30 entries max!
picname_tbl
	ds.w	1
	ds.b	32*picnmbr
mse_pic	ds.w	10
	ds.l	2*10
mse2_pic
	ds.w	10
	ds.l	2*10
mseback_buf
	ds.l	4*10
menufont_tbl
	ds.w	8*1*256
bigmenufont_tbl
	ds.w	4*16*256
sound_buf
	ds.w	50000
sound2_buf
	ds.w	50000
end_of_bss