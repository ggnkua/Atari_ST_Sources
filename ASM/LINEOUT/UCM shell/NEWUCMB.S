******** CONSTANTS ********

* executable type
forcestmode:	=	0			* 1=force a TT/Falc to behave like an ST.
testmode:	=	0			* 1=leave out nasty interrupt stuff for easy debug.
usedatalink:	=	1			* Use convential filesys (=0) or datalinkage (=1).
channels8:	=	0			* 1=Use new modplayer for 8 channels.
fastscroll:	=	1			* Use fastscroll
* Screen dimensions
scrxbytes:	=	160
scrlines:	=	200
scrbufsize:	=	scrxbytes*scrlines
txtbgnline:	=	28
* Muzak types
xlr8type:	=	0
trimodtype:	=	1
scavytype:	=	2
taotype:	=	3
megatizertype:	=	4
* Text embedded crap types
specialtype:	=	255
linktype:	=	10
bigtexttype:	=	1
bigtexttype2:	=	2
pictype:	=	30
endpictype:	=	40
* Picture handling stuffs
picnmbr:	=	3		* Maximum number of PI1's in the text
picmaxsize:	=	32066		* Size of degas elite PI1
* font dimensions
charwidth:	=	4
charheight:	=	8

******** ASM OPTIONS AND OUTPUT ********

		IFEQ	testmode
		OPT	D-,P=68000
		ENDC
		IFEQ	usedatalink
		OUTPUT	D:\CODING\UCMSHELL\SHELL.PRG
		ELSE
		OUTPUT	D:\CODING\UCMSHELL\DSHELL.PRG
		ENDC

******** LIBRARY INCLUDES ********

	bra	START

archivemode:	=	usedatalink
		INCLUDE	INCLOAD.I
		TEXT

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

	IFEQ	1	;IFEQ	usedatalink	* Well.. if moondog doesn't want it..
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
	bsr	SAVE_FV
	move.w	$ffff8006.w,d0
	lsr.w	#8,d0
	lsr.w	#6,d0
	beq	.fastout			* Go out if it is mono-monitor
	subq.w	#2,d0
	bne.s	.dorgbcrap
	lea	stlowvga_vid,a0
	bsr	CHANGE_FVFAST
	bra.s	.setfalcres
.dorgbcrap:
	lea	stlowrgb_vid,a0
	bsr	CHANGE_FVFAST
.setfalcres:
.initstw1:
* Save old ST-res.
	move.w	#4,-(sp)
	trap	#14
	addq	#2,sp
	move.w	d0,oldstres
* Set ST-low
	clr.b	$ffff8260.w
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
* Set the new screen.
	move.l	scr,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
* Save loads of interrupt crap.
	bsr	SAVE_SYSTEMVARS
* Set some interrupt crap.
	move	#$2700,sr
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
.musicstopped:
* Restore loads of interrupt crap.
	bsr	RESTORE_SYSTEMVARS
* Restore screen + res.
.rest_resscr:
	cmpi.w	#3,computer
	bne.s	.oldstres
.fscr	move.l	oldscr,d0
	move.b	d0,d1
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w
	bsr	RESTORE_FV
	bra.s	.res_fertig
.oldstres:
	move.b	oldstres+1,$ffff8260.w
	move.l	oldscr,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
.res_fertig:
* Restore old ST-pallette.
	movem.l	oldst_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
* Return to usermode and exit.
.fastout:
	clr.w	-(sp)
	trap	#1

******** SUBROUTINES ********

SAVE_FV:
	lea	fvbuf,a0
	move.l	$ffff8282.w,(a0)+		* h-regs
	move.l	$ffff8286.w,(a0)+		* 
	move.l	$ffff828a.w,(a0)+		* 
	move.l	$ffff82a2.w,(a0)+		* v-regs
	move.l	$ffff82a6.w,(a0)+		* 
	move.l	$ffff82aa.w,(a0)+		* 
	move.w	$ffff82c0.w,(a0)+		* vco
	move.w	$ffff82c2.w,(a0)+		* c_s
	move.l	$ffff820e.w,(a0)+		* offset
	move.w	$ffff820a.w,(a0)+		* sync
	move.b  $ffff8256.w,(a0)+		* p_o
	clr.b   (a0)				* test of st(e) or falcon mode
	cmp.w   #$b0,$ffff8282.w		* hht kleiner $b0?
	sle     (a0)+				* flag setzen
	move.w	$ffff8266.w,(a0)+		* f_s
	move.w	$ffff8260.w,(a0)+		* st_s
	rts

RESTORE_FV:
	lea	fvbuf,a0

* Changes screenresolution the fast way.. Do this synced to the VBL for
* the smooth res-change.
* INPUT: a0: address of falcvideo-buffer
CHANGE_FVFAST:
	clr.w   $ffff8266.w			* falcon-shift clear
	move.l	(a0)+,$ffff8282.w	0	* h-regs
	move.l	(a0)+,$ffff8286.w	4	*
	move.l	(a0)+,$ffff828a.w 	8	*
	move.l	(a0)+,$ffff82a2.w	12	* v-regs
	move.l	(a0)+,$ffff82a6.w 	16	*
	move.l	(a0)+,$ffff82aa.w 	20	*
	move.w	(a0)+,$ffff82c0.w	24	* vco
	move.w	(a0)+,$ffff82c2.w	26	* c_s
	move.l	(a0)+,$ffff820e.w	28	* offset
	move.w	(a0)+,$ffff820a.w	32	* sync
        move.b  (a0)+,$ffff8256.w	34	* p_o
        tst.b   (a0)+   		35	* st(e) compatible mode?
       	bne.s   .ok			36
	move.w	$468.w,d0			* / wait for vbl
.wait468:					* | to avoid
	cmp.w	$468.w,d0			* | falcon monomode
	beq.s	.wait468			* \ syncerrors.
       	move.w  (a0),$ffff8266.w	38	* falcon-shift
	bra.s	.video_restored
.ok:	move.w  2(a0),$ffff8260.w	40	* st-shift
	move.w	-10(a0),$ffff82c2.w		* c_s
	move.l	-8(a0),$ffff820e.w		* offset		
.video_restored:
	rts

SAVE_SYSTEMVARS:
* Save loads of interrupt crap.
	move    #$2700,SR
	lea     sys_var,a0
	move.l  $0070.w,(a0)+
	move.l  $0068.w,(a0)+
	move.l  $0110.w,(a0)+
	move.l	$0114.w,(a0)+
	move.l	$0118.w,(a0)+
	move.l  $0120.w,(a0)+
	move.l	$0134.w,(a0)+
	lea     $fffffa00.w,a1
	move.b	$01(a1),(a0)+
	move.b	$03(a1),(a0)+
	move.b	$05(a1),(a0)+
	move.b  $07(a1),(A0)+
	move.b  $09(a1),(A0)+
	move.b	$0b(a1),(a0)+
	move.b	$0d(a1),(a0)+
	move.b	$0f(a1),(a0)+
	move.b  $11(a1),(A0)+
	move.b  $13(a1),(A0)+
	move.b  $15(a1),(A0)+
	move.b  $17(a1),(A0)+
	move.b	$19(a1),(a0)+
	move.b  $1B(a1),(A0)+
	move.b	$1d(a1),(a0)+
	move.b	$1f(a1),(a0)+
	move.b  $21(a1),(A0)+
	move.b  $23(a1),(A0)+
	move.b  $25(a1),(A0)+
	move.b  $0484.w,(A0)+
	move	#$2300,sr
	rts

RESTORE_SYSTEMVARS:
	move    #$2700,sr
	clr.b   $fffffa1b.w     ;Timer B stoppen
        lea     sys_var,a0
	move.l  (a0)+,$0070.w
	move.l  (a0)+,$0068.w
	move.l  (a0)+,$0110.w
	move.l	(a0)+,$0114.w
	move.l	(a0)+,$0118.w
	move.l  (a0)+,$0120.w
	move.l	(a0)+,$0134.w
	lea     $fffffa00.w,A1
	move.b	(a0)+,$01(a1)
	move.b	(a0)+,$03(a1)
	move.b	(a0)+,$05(a1)
	move.b  (A0)+,$07(A1)
	move.b  (A0)+,$09(A1)
	move.b	(a0)+,$0b(a1)
	move.b	(a0)+,$0d(a1)
	move.b	(a0)+,$0f(a1)
	move.b  (a0)+,$11(A1)
	move.b  (a0)+,$13(A1)
	move.b  (a0)+,$15(A1)
	move.b  (a0)+,$17(A1)
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
	move.b  (a0)+,$0484.w
	move    #$2300,SR
	rts

INIT_IKBD:
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

.init:	DC.W	0

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

dspmod_bin:
	IFNE	channels8
	INCBIN	DSPMOD.TCE
	ELSE
	INCBIN	DSP.BSW
	ENDC

	EVEN

	TEXT

PLAY_STMUS:
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
	bra	.noplay
.play	addq	#4,sp
	move.l	-4(a1),a1
	jsr	(a1)
	rts
.noplay	move.w	#-1,sngtype
	addq	#4,sp
	rts

PLAY_TAOSONG:
	moveq	#1,d0
	jsr	sound_buf
	move.l	#sound_buf+4,MUSIC_IRQ
	move.w	#taotype,sngtype		* type=tao sid
	clr.w	music
	rts

PLAY_XLR8SONG:
	move.w	#xlr8type,sngtype		* type=xlr8
	moveq	#1,d0
	jsr	sound_buf
	move.l	#sound_buf+2,MUSIC_IRQ
	clr.w	music
	rts

PLAY_TRIMODSONG:
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

PLAY_SCAVENGERSONG:
	move.w	#scavytype,sngtype		* type=scavenger SID
	jsr     sound_buf
	move.l  #sound_buf+6,MUSIC_IRQ
	clr.w	music
	rts

PLAY_MEGATIZERSONG:
	move.w	#megatizertype,sngtype		* type=megatizer
	jsr	sound_buf
	move.l	#sound_buf+8,MUSIC_IRQ
	clr.w	music
	rts

stmustype_tbl:
	DC.W	5-1
	DC.B	"TAO",0
	DC.L	PLAY_TAOSONG
	DC.B	"XLR",0
	DC.L	PLAY_XLR8SONG
	DC.B	"TRI",0
	DC.L	PLAY_TRIMODSONG
	DC.B	"SCV",0
	DC.L	PLAY_SCAVENGERSONG
	DC.B	"MGT",0
	DC.L	PLAY_MEGATIZERSONG

STOP_STMUS:
	tst.w   music
	bne.s   .stop
	move.w	sngtype,d0
	cmpi.w	#xlr8type,d0
	bne.s	.next
	lea	sound_buf,a0
	moveq	#0,d0
	jsr	(a0)
	bra.s	.stop
.next:	cmpi.w	#trimodtype,d0
	bne.s	.next2
* A0 = address of sound_buf
	move.l	#rts,MUSIC_IRQ
	jsr	amplay_bin+8				* Deinstall player.
	;jsr	amplay_bin+12				* Stop & restore vectors.
	bra.s	.stop
.next2:	cmpi.w	#scavytype,d0
	bne.s	.next3
	jsr     sound_buf+2
	bra.s	.stop
.next3:	cmpi.w	#taotype,d0
	bne.s	.next4
	moveq	#0,d0
	jsr	sound_buf
	bra.s	.stop
.next4:	cmpi.w	#megatizertype,d0
	bne.s	.next5
	jsr	sound_buf+4
	bra.s	.stop
.next5:	nop
.stop:	move.l	#rts,MUSIC_IRQ
	move.w  #1,music
	rts

* Routine that returns computertype in registers.
* OUTPUT: d0.w: 0=ST
*               1=STe
*               2=TT030
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
* OUTPUT: d0.l: pos=number of bytes read or 
*               neg=error, not found/done
LOAD_SHELLINCLUDE:
	exg	a0,a1
	bra	LOAD_INCFILETOBUF

INIT_MENUFONT:
	lea	font_dat,a1
	lea	menufont_tbl,a0
	lea	2*8*256(a0),a2
	lea	2*8*256(a2),a3
	lea	2*8*256(a3),a4
	move.w	#256*8-1,d7

.loop:	moveq	#0,d0
	move.b	(a1)+,d0
	move.w	d0,d1
	lsl.w	#4,d1
	move.w	d1,d2
	lsl.w	#4,d2
	move.w	d2,d3
	lsl.w	#4,d3
	move.w	d3,(a0)+
	move.w	d2,(a2)+
	move.w	d1,(a3)+
	move.w	d0,(a4)+
	dbra	d7,.loop
	rts

INIT_BIGMENUFONT:
	lea	bigmenufont_tbl,a0
	lea	bigcharloc_tbl,a2
	lea	npropfntedge_tbl,a3
	move.l	a1,a6
	move.w	#256-1,d7
.chlop:	movem.w	(a2)+,d0-d2
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
.crlop:	move.w	(a1)+,d0
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

INIT_MOUSEPOINTER:
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

COPY_STSCREEN:
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
CLEAR_BUFFER:
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
.bigloop:
	REPT	4
	movem.l	d1-d7/a1-a6,-(a0)
	ENDR
	dbra	d0,.bigloop
.small	swap	d0
	move.w	d0,d1
	lsr.w	#4,d0
	beq.s	.mini
	subq.w	#1,d0
.smallloop:
	movem.l	d2-d5,-(a0)
	dbra	d0,.smallloop
.mini	andi.w	#$000f,d1
	beq.s	.rts
	subq.w	#1,d1
.minilp	move.b	d2,-(a0)
	dbra	d1,.minilp
.rts	rts

* INPUT: a0: startaddress of 160 bytes to clear.
CLEAR_160BYTES:
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
CLEAR_320BYTES:
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

INIT_MOUSEBACK:
	lea	mseback_buf,a0
	move.l	scr+4,a1
	moveq	#10-1,d7
.lp:	REPT	4
	move.l	(a1)+,(a0)+
	ENDR
	lea	scrxbytes-16(a1),a1
	dbra	d7,.lp
	rts

INIT_TEXT:
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
.form_loop:
	move.b  (A0)+,D0
	cmp.b   #'{',D0
	beq.s   .special
	cmp.b   #13,D0
	bne.s   .flw1
	addq.l  #1,A0
	tst.w   D2
	beq.s   .small_text
.big_text:
	move.w  #bigtexttype,(A1)+
	move.l	a0,(a1)+
	move.w	#bigtexttype2,(a1)+
	move.l	a0,(a1)+
	addq.w  #2,D1
	bra.s   .flw1
.small_text:
	move.w  #0,(A1)+
	move.l  A0,(A1)+
	addq.w  #1,D1
.flw1:	cmpa.l  A0,A2
	bge.s   .form_loop
.returns:
	cmp.w   #21,D1
	bge.s   .flw2
	move.w  #0,(A1)+
	move.l  A0,(A1)+
	addq.w  #1,D1
	bra.s   .returns
.flw2:	move.w  D1,textlines
	move.b  #$0D,(A0)+
	move.b  #$0A,(A0)+
	rts
.special:
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
.link:	move.w	#linktype,-6(a1)
	bra	.clear_klammer
.new_font:
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
.color:	moveq	#0,d0
	move.l	a0,a6
.asclp:	move.b	(a6)+,d3
	sub.b	#'0',d3
	blt.s	.shitcolor
	cmpi.b	#9,d3
	bgt.s	.shitcolor
	mulu.w	#10,d0
	add.b	d3,d0
	bra.s	.asclp
.shitcolor:
	cmpi.b	#16,d0
	blt.s	.okcoln
	andi.b	#$0f,d0
.okcoln	move.b	d0,(a0)+
	bra	.clear_klammer
.image:	movem.l	d1-a6,-(sp)
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
.loppo:	move.w	fxtype(pc),(a1)+
	move.l	adr,(a1)+
	addq.l	#8,adr
	dbra	d0,.loppo
	bra.s	.clear_klammer
* Other special thingies in here...
	nop
.clear_klammer
.ckl:	cmpi.b  #'}',(A0)+
	bne.s   .ckl
	move.b  #specialtype,-1(A0)
	bra	.flw1

fxtype:	DC.W	0
adr:	DC.L	0

EXTRACT_NAMEFROMTEXT:
.prelp	cmpi.b	#' ',(a0)
	bne.s	.loop
	addq	#1,a0
	bra.s	.prelp
.loop:	move.b	(a0)+,d0
	cmpi.b	#'a',d0
	blt.s	.on
	cmpi.b	#'z',d0
	bhi.s	.on
	subi.w	#32,d0
.on:	move.b	d0,(a1)+
	cmpi.b	#'}',d0
	beq.s	.out
	cmpi.b	#' ',d0
	bne.s	.loop
.out:	clr.b	-1(a1)
	rts

CONV_TEXT2NUM:
	moveq	#0,d0
.loop:	moveq	#0,d1
	move.b	(a1)+,d1
	beq.s	.end
	subi.b	#'0',d1
	cmpi.b	#10,d1
	bhs.s	.error
	mulu.w	#10,d0
	add.b	d1,d0
	bra.s	.loop
.end:	rts
.error:	moveq	#0,d0
	rts

* INPUT: d0.b: character
* OUTPUT: d0.b: 0=left alignment
*               1=mid alignment
*               2=right alignment
GET_PICALIGNMENT:
	cmpi.b	#'a',d0
	blt.s	.lower
	subi.b	#32,d0
.lower:	cmpi.b	#'L',d0
	bne.s	.m
	move.b	#0,d0
	rts
.m:	cmpi.b	#'M',d0
	bne.s	.r
	move.b	#1,d0
	rts
.r:	cmpi.b	#'R',d0
	bne.s	.mid
	move.b	#2,d0
	rts
.mid:	move.b	#1,d0
	rts

EXTRACT_NAMEFROMETEXT:
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
CLEAR_PICTUREBUF:
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
ADD_PICBLK:
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
.new:	move.l	a1,a0
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
.skip:	move.w	d2,(a1)+
	swap	d7
	move.w	d7,(a1)+
	move.l	a0,(a1)+
	addq.w	#1,d6
	add.w	d6,piclin_tbl
	move.w	d6,d0
	move.l	a6,a0
	rts
.old:
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
PUT_PICNAMEINTABLE:
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

PLOT_BIGTEXTLINE:
	movem.l	d1-a6,-(sp)
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
.loop:	moveq	#0,d0
	move.b	(a2)+,d0
	cmpi.b	#specialtype,d0
	beq.s	.out
	cmpi.b	#$d,d0
	beq.s	.out
	move.l	d0,d1
	mulu.w	#6,d1
	move.l	d2,d3
	add.w	4(a3,d1.l),d2
	lsl.l	#7,d0			;mulu.w	#16*8,d0
	adda.l	d0,a1
	cmpi.w	#16,d3
	blo.s	.skip
	addq	#8,a5
	subi.w	#16,d2
	subi.w	#16,d3
.skip:	movea.l	a5,a0
	moveq	#charheight-1,d6
.linlop	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	move.l	d0,d1
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	move.w	d0,d1
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	move.l	d0,d4
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	move.w	d0,d4
	or.l	d1,(a0)+
	or.l	d4,(a0)+
	lea	160-16(a0),a0		;lea	scrxbytes-8(a0),a0
	dbra	d6,.linlop
	lea	-(scrxbytes*charheight)+8(a0),a0
	movea.l	a6,a1
	bra.s	.loop
.out:	movem.l	(sp)+,d1-a6
	rts

PLOT_BIGTEXTSCANLINE:
	lsl.w	#3,d1
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
.loop:	moveq	#0,d0
	move.b	(a2)+,d0
	cmpi.b	#specialtype,d0
	beq.s	.out
	cmpi.b	#$d,d0
	beq.s	.out
	move.l	d0,d1
	add.l	d1,d1			;
	move.l	d1,d3			;
	add.l	d1,d1			;
	add.l	d3,d1			;mulu.w	#6,d1
	move.l	d2,d3
	add.w	4(a3,d1.l),d2
	lsl.l	#7,d0			;mulu.w	#16*8,d0
	adda.l	d0,a1
	cmpi.w	#16,d3
	blo.s	.skip
	addq	#8,a5
	subi.w	#16,d2
	subi.w	#16,d3
.skip:	movea.l	a5,a0
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	move.l	d0,d1
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	move.w	d0,d1
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	move.l	d0,d4
	moveq	#0,d0
	move.w	(a1)+,d0
	ror.l	d3,d0
	or.w	d0,(a0)+
	swap	d0
	move.w	d0,d4
	or.l	d1,(a0)+
	or.l	d4,(a0)+
	movea.l	a6,a1
	bra.s	.loop
.out	rts

PLOT_TEXTLINE:
	move.l	textlen,d1
	lea	(a2,d1.l),a5
	lea	txt_tbl,a4
	move.w	d0,d1
	mulu.w	#6,d0
	adda.l	d0,a4
	movea.l	a0,a6
	moveq	#0,d5

.plotit:
	move.w	(a4)+,d0
	cmpi.w	#pictype,d0
	blt.s	.fnt
	cmpi.w	#endpictype,d0
	bhs.s	.fnt
	movea.l	(a4),a1			Get address of piclin table entry
	move.w	(a1),d1			Get y-offset
	move.w	2(a1),d7		Get number of scanlines
	movea.l	4(a1),a1		Get address of picpck table entry
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
.right:	adda.w	#scrxbytes,a0
	sub.w	d3,a0
.alok:	move.l	4(a1),a1
	mulu.w	#scrxbytes,d1
	addi.l	#34,d1			skip degas header
	adda.l	d1,a1
	adda.w	d2,a1
	moveq	#0,d0
	move.w	d3,d0
	subq.w	#1,d7
	bpl.s	.cplp
	rts
.cplp:	movem.l	d0/d7/a0/a1,-(sp)
	bsr	COPY_BUFFER
	movem.l	(sp)+,d0/d7/a0/a1
	lea	scrxbytes(a0),a0
	lea	scrxbytes(a1),a1
	dbra	d7,.cplp
	rts
.fnt:	cmpi.w	#bigtexttype,d0
	bne.s	.lfont
	movea.l	(a4),a2
	lea	bigmenufont_tbl,a1
	bsr	PLOT_BIGTEXTLINE
	rts
.lfont:	cmpi.w	#bigtexttype2,d0
	bne.s	.nfont
	movea.l	(a4),a2
	lea	bigmenufont_tbl+charheight*8,a1
	bsr	PLOT_BIGTEXTLINE
	rts
.nfont:	movea.l	(a4),a2
	lea	menufont_tbl,a1
	movea.l	a1,a6
	moveq	#0,d1
	moveq	#80-1,d4

.loop:	moveq	#0,d0
	move.b	(a2)+,d0
	cmpi.b	#$d,d0
	beq.s	.out
	cmpi.b	#240,d0
	blo.s	.no_specialchar
	subi.b	#240,d0
	suba.l	d5,a0
	move.b	d0,d5
	add.l	d5,d5
	adda.l	d5,a0
	bra.s	.loop
.no_specialchar:
	lsl.l	#4,d0
	adda.l	d0,a1
.plot_char:
	move.w	(a1)+,d0
	or.w	d0,(a0)
	move.w	(a1)+,d0
	or.w	d0,160(a0)
	move.w	(a1)+,d0
	or.w	d0,320(a0)
	move.w	(a1)+,d0
	or.w	d0,480(a0)
	move.w	(a1)+,d0
	or.w	d0,640(a0)
	move.w	(a1)+,d0
	or.w	d0,800(a0)
	move.w	(a1)+,d0
	or.w	d0,960(a0)
	move.w	(a1)+,d0
	or.w	d0,1120(a0)
	addq.w	#1,d1
	lea	2*256*8(a6),a6
.test_nextchunk:
	cmpi.w	#4,d1
	blt.s	.not_nextchunk
	subq.w	#4,d1
	addq	#8,a0
	lea	-2*256*8*4(a6),a6
.not_nextchunk:
	movea.l	a6,a1
	dbra	d4,.loop
.out:	rts

PLOT_FULLTEXT:
	clr.w	chrlin
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	REPT	18
	move.l	4(sp),d0
	cmp.w	textlines,d0
	bhi	.out
	move.l	(sp),a0
	bsr	PLOT_TEXTLINE
	addi.l	#scrxbytes*charheight,(sp)
	addq.l	#1,4(sp)
	ENDR
.out:	addq	#8,sp
	rts

PLOT_TEXTSCANLINE:
	move.l	textlen,d2
	lea	(a2,d2.l),a5
	lea	txt_tbl,a4
	mulu.w	#6,d0
	adda.l	d0,a4

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
.linok:	move.l	4(a1),a1		Get address of picpck table entry
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
.right:	adda.w	#scrxbytes,a0
	sub.w	d3,a0
.alok:	move.l	4(a1),a1
	mulu.w	#scrxbytes,d1
	addi.l	#34,d1			skip degas header
	adda.l	d1,a1
	add.w	d2,a1
	moveq	#0,d0
	move.w	d3,d0
	bsr	COPY_BUFFER
	rts
.fnt:	cmpi.w	#bigtexttype,d0
	bne.s	.lfont
	move.l	(a4),a2
	lea	bigmenufont_tbl,a1
	bsr	PLOT_BIGTEXTSCANLINE
	rts
.lfont:	cmpi.w	#bigtexttype2,d0
	bne.s	.nfont
	move.l	(a4),a2
	lea	bigmenufont_tbl+charheight*8,a1
	bsr	PLOT_BIGTEXTSCANLINE
	rts
.nfont:	move.l	(a4),a2
	lea	menufont_tbl,a1
	add.w	d1,d1
	adda.w	d1,a1
	movea.l	a1,a6
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d5
	moveq	#80-1,d4

.loop:	moveq	#0,d0
	move.b	(a2)+,d0
	cmpi.b	#$d,d0
	beq.s	.out
	cmpi.b	#240,d0
	blo.s	.no_specialchar
	subi.b	#240,d0
	or.w	d2,(a0)
	moveq	#0,d2
	suba.l	d5,a0
	move.b	d0,d5
	add.l	d5,d5
	adda.l	d5,a0
	bra.s	.loop
.no_specialchar:
	lsl.l	#4,d0
	or.w	(a1,d0.l),d2
	addq.w	#1,d1
	lea	2*256*8(a6),a6
.test_nextchunk:
	cmpi.w	#4,d1
	blt.s	.not_nextchunk
	subq.w	#4,d1
	lea	-2*256*8*4(a6),a6
	move.w	d2,(a0)
	moveq	#0,d2
	addq	#8,a0
.not_nextchunk:
	movea.l	a6,a1
	dbra	d4,.loop
.out:	or.w	d2,(a0)
	rts

PLOT_MOUSE:
	moveq	#0,d0
	move.w	mse_tbl+2,d0
	cmpi.w	#txtbgnline,d0
	bge.s	.ypos
	moveq	#txtbgnline,d0
	bra.s	.movey
.ypos:	cmpi.w	#scrlines-10,d0
	blt.s	.movey
	move.w	#scrlines-10,d0
.movey:	move.w	d0,mse_tbl+2
	subi.w	#txtbgnline,d0
	add.w	chrlin,d0
	lsr.w	#3,d0		;divu.w	#charheight,d0
	cmpi.w	#18,d0
	bhs.s	.norm
	add.w	actline,d0
	mulu.w	#6,d0
	lea	txt_tbl,a0
	cmpi.w	#linktype,0(a0,d0.l)
	bne.s	.norm
	lea	mse2_pic,a1
	moveq	#-4,d2
	bra.s	.mask
.norm:	lea	mse_pic,a1
	moveq	#0,d2
.mask:	lea	10*2(a1),a2
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
	add.l	d2,d1
	tst.l	d0
	bpl.s	.xpos
	moveq	#0,d0
	bra.s	.ty
.xpos:	cmpi.w	#(scrxbytes*2)-10,d0
	blt.s	.ty
	move.w	#(scrxbytes*2)-10,d0
.ty:	move.w	d0,mse_tbl
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
.ylp:	moveq	#-1,d0
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

PLOT_MOUSEBACK:
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

SAVE_ARTICLE:
	bsr     STOP_MUSIC
.ende2:	bsr	RESTORE_SYSTEMVARS
	cmpi.w  #3,computer
	bne.s   .oldstres
.fscr:	bsr	RESTORE_FV
	move.l	oldscr,d0
	move.b	d0,d1
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w
	bra.s	.res_fertig
.oldstres:
	move.b	oldstres+1,$ffff8260.w
	move.l	oldscr,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
.res_fertig:
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

.skipsave:
	cmpi.w  #3,computer
	bne.s   .initstw1
	move.w	$ffff8006.w,d0
	lsr.w	#8,d0
	lsr.w	#6,d0
	subq.w	#2,d0
	bne.s	.dorgbcrap
	lea	stlowvga_vid,a0
	bsr	CHANGE_FVFAST
	bra.s	.skipstshit
.dorgbcrap:
	lea	stlowrgb_vid,a0
	bsr	CHANGE_FVFAST
	bra.s	.skipstshit
.initstw1:
	clr.b	$ffff8260.w
.skipstshit:

	move	#$2700,sr
	lea     $FFFFFA00.w,A1
	clr.b   $1B(A1)         ;Timer B stoppen, wenn lÑuft
	bclr    #3,$17(A1)
	bclr	#4,$15(a1)
	bclr	#3,$fffffa17.w
	ori.b	#%00100001,$fffffa07.w
	ori.b	#%00100001,$fffffa13.w
	ori.b	#%01101000,$fffffa09.w
	move.l  #NEWVBL,$70.w
	move	#$2300,sr
	bsr	INIT_IKBD
	bsr	PLAY_MUSIC
	rts

FADE_IN:
	lea	pic_buf+4+2,a1
	lea	backup_pal+32,a0
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

.16lop:	move.w	$468.w,d0
.466lp:	cmp.w	$468.w,d0
	beq.s	.466lp

	lea	backup_pal,a2
	lea	menu_pal,a1
	move.w	d7,-(sp)
	bsr.s	FADE_1UP
	move.w	(sp)+,d7

	lea	pic_buf+4+2,a1		Kick in startaddress of first pallette
	lea	backup_pal+32,a2
	moveq	#picnmbr-1,d6

.pallp:	move.l	a1,-(sp)
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
FADE_1UP:
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
.skipb:	move.w	d0,d1
	move.w	d2,d3
	andi.w	#$00f0,d1
	andi.w	#$00f0,d3
	cmp.w	d1,d3
	beq.s	.skipg
	bchg	#7,d0
	beq.s	.skipg
	add.w	#16,d0
.skipg:	move.w	d0,d1
	move.w	d2,d3
	andi.w	#$0f00,d1
	andi.w	#$0f00,d3
	cmp.w	d1,d3
	beq.s	.skipr
	bchg	#11,d0
	beq.s	.skipr
	add.w	#256,d0
.skipr:	move.w	d0,(a1)+
	dbra	d6,.collop
	rts

* Routine that fades out the menu pallette and all picture-pallettes.
* >WARNING< The picture pallettes in pic_buf are affected!
FADE_OUT:
	lea	backup_pal,a0
	movem.l	menu_pal,d0-d6/a2
	movem.l	d0-d6/a2,(a0)
	moveq	#16-1,d7

.16lop:	move.w	$468.w,d0
.p466lp	cmp.w	$468.w,d0
	beq.s	.p466lp
	lea	menu_pal,a1
	move.w	d7,-(sp)
	bsr.s	FADE_1DOWN
	move.w	(sp)+,d7

	lea	pic_buf+4+2,a1		Kick in startaddress of first pallette
	moveq	#picnmbr-1,d6

.pallp:	move.l	a1,-(sp)
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
FADE_1DOWN:
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
.skipb:	move.w	d0,d1
	move.w	d2,d3
	andi.w	#$00f0,d1
	andi.w	#$00f0,d3
	cmp.w	d1,d3
	beq.s	.skipg
	bchg	#7,d0
	bne.s	.skipg
	subi.w	#16,d0
.skipg:	move.w	d0,d1
	move.w	d2,d3
	andi.w	#$0f00,d1
	andi.w	#$0f00,d3
	cmp.w	d1,d3
	beq.s	.skipr
	bchg	#11,d0
	bne.s	.skipr
	subi.w	#256,d0
.skipr:	move.w	d0,(a1)+
	dbra	d6,.collop
	rts

	BSS

backup_pal:
	DS.W	16*(picnmbr+1)

	TEXT

* Routine that displays the intro picture (with fading and stuff).
SHOW_INTROPIC:
* Load the intro picture + pallette into buffer.
	lea	intropicname_txt,a0
	lea	file_buf,a1
	bsr	LOAD_SHELLINCLUDE
* Wait for a VBL to occur and then clear the actual pallette
	move.w	$468.w,d0
.tstvbl	cmp.w	$468.w,d0
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
.fadeinloop:
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
.skipb:	move.w	d0,d1
	move.w	d2,d3
	andi.w	#$00f0,d1
	andi.w	#$00f0,d3
	cmp.w	d1,d3
	beq.s	.skipg
	bchg	#7,d0
	beq.s	.skipg
	add.w	#16,d0
.skipg:	move.w	d0,d1
	move.w	d2,d3
	andi.w	#$0f00,d1
	andi.w	#$0f00,d3
	cmp.w	d1,d3
	beq.s	.skipr
	bchg	#11,d0
	beq.s	.skipr
	add.w	#256,d0
.skipr:	move.w	d0,(a1)+
	dbra	d6,.collop
* Wait 2 VBLs.
	move.w	$468.w,d0
.tst466	cmp.w	$468.w,d0
	beq.s	.tst466
	move.w	$468.w,d0
.ts466:	cmp.w	$468.w,d0
	beq.s	.ts466
* Kick in new pallette
	movem.l	-32(a1),d0-d5/a3-a4
	movem.l	d0-d5/a3-a4,(a0)
	dbra	d7,.fadeinloop
	rts

INIT_SHELL:
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
	lea	file_buf+34+(scrxbytes*43),a1
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
.wipeloop:
	move.w	$468.w,d0
.wtvbl:	cmp.w	$468.w,d0
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

GET_CONTROLS:
	movem.w	mse_tbl,d0-d2
	tst.w	d2
	beq.s	.rts
	btst	#9,d2
	bne.s	.left
	moveq	#10,d0
	rts
.left:	cmpi.w	#200-24,d1
	bhs.s	.bar
	move.w	actline,d0
	subi.w	#txtbgnline,d1
	add.w	chrlin,d1	
	lsr.w	#3,d1		;divu.w	#charheight,d1
	add.w	d1,d0
	lea	txt_tbl,a0
	mulu.w	#6,d0
	move.l	2(a0,d0.l),a0
.tstlp:	move.b	(a0)+,d0
	cmpi.b	#specialtype,d0
	beq.s	.ok
	cmpi.b	#$d,d0
	bne.s	.tstlp
	bra.s	.rts
.ok:	addq	#1,a0
	cmpi.b	#'\',(a0)+
	bne.s	.rts
	bsr	EXTRACT_NAMEFROMETEXT
	moveq	#20,d0
	rts
.rts:	moveq	#0,d0
	rts
.bar:	cmpi.w	#45,d0
	bhs.s	.help
	moveq	#1,d0
	rts
.help:	cmpi.w	#96,d0
	bhs.s	.save
	moveq	#2,d0
	rts
.save:	cmpi.w	#146,d0
	bhs.s	.tmus
	moveq	#3,d0
	rts
.tmus:	cmpi.w	#200,d0
	bhs.s	.mus1
	moveq	#11,d0
	rts
.mus1:	cmpi.w	#216,d0
	bhs.s	.mus2
	moveq	#4,d0
	rts
.mus2:	cmpi.w	#232,d0
	bhs.s	.mus3
	moveq	#5,d0
	rts
.mus3:	cmpi.w	#256,d0
	bhs.s	.off
	moveq	#6,d0
	rts
.off:	cmpi.w	#289,d0
	bhs.s	.down
	moveq	#9,d0
	rts
.down:	cmpi.w	#303,d0
	bhs.s	.up
	moveq	#7,d0
	rts
.up:	moveq	#8,d0
	rts

DO_SHELLMAINLOOP:
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

.loop:	move.w	actline,actlin2
	lea	scr,a0
	move.l	(a0),d0
	move.l	4(a0),(a0)+
	move.l	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
.noswap:

	move.w	$468.w,d0
.tstvbl:
	cmp.w	$468.w,d0
	beq.s	.tstvbl

	move.b	keycode,d0
	cmpi.b	#$48,d0
	beq	.up
	cmpi.b	#$50,d0
	beq	.down
	cmpi.b	#$1f,d0
	beq	.save
	cmpi.b	#$62,d0
	beq	.help
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
.else:	cmpi.b	#10,d0
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
	cmpi.b	#$1,keycode			* Escape key..
	bne	.noswap
	move.l	#rts,HBL_IRQ
	move.w	#$2700,sr
	clr.b	$fffffa1b.w
	bclr	#0,$fffffa07.w
	bclr	#0,$fffffa13.w
	move.w	#$2300,sr
	rts

.up:	tst.w	actline
	bgt.s	.hushb
	tst.w	chrlin
	beq	.noswap
	IFNE	fastscroll
	cmpi.w	#50,scrollcount
	blt.s	.hushb
	cmpi.w	#1,chrlin
	bls	.noswap
	ENDC
.hushb:	tst.w	scrollcount
	bne.s	.skiprd
	bsr	PLOT_MOUSEBACK
.skiprd	addq.w	#1,scrollcount
	cmpi.w	#50,scrollcount
	IFNE	fastscroll
	blt	.onescan_u
	ELSE
	bra	.onescan_u
	ENDC
	lea	scr,a2
	movea.l	(a2)+,a0
	movea.l	(a2)+,a1
	lea	scrxbytes*(txtbgnline+2)(a0),a0
	lea	scrxbytes*txtbgnline(a1),a1
	move.l	#((18*charheight)-2)*scrxbytes,d0
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
	moveq	#charheight-1,d1
.skipc1a:
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
.skipc1b:
	move.w	d0,actline
	move.w	d1,chrlin
	bsr	PLOT_TEXTSCANLINE
	bra	.loop
.onescan_u:
	movea.l	scr,a0
	movea.l	scr+4,a1
	lea	scrxbytes*(txtbgnline+1)(a0),a0
	lea	scrxbytes*txtbgnline(a1),a1
	move.l	#((18*charheight)-1)*scrxbytes,d0
	bsr	COPY_BUFFER
	move.l	scr,a0
	lea	scrxbytes*txtbgnline(a0),a0
	bsr	CLEAR_160BYTES
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

.down:	move.w	actline,d1
	move.w	chrlin,d0
	addq.w	#1,d0
	cmpi.w	#charheight,d0
	blt.s	.skip_downline
	addq.w	#1,d1
.skip_downline:
	addi.w	#18,d1
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
	move.l	#(18*charheight-2)*scrxbytes,d0
	bsr	COPY_BUFFER
	move.l	scr,a0
	lea	scrxbytes*(txtbgnline+(18*charheight-2))(a0),a0
	bsr	CLEAR_320BYTES
	move.w	actline,d2
	move.w	chrlin,d3
	move.w	d2,d0
	addi.w	#18,d0
	move.w	d3,d1
	addq.w	#1,d3
	cmpi.w	#charheight,d3
	blt.s	.skip_1st_d
	moveq	#0,d3
	addq.w	#1,d2
.skip_1st_d:
	move.w	d2,actline
	move.w	d3,chrlin
	bsr	PLOT_TEXTSCANLINE
	move.l	scr,a0
	lea	scrxbytes*(txtbgnline+(18*charheight-1))(a0),a0
	move.w	actline,d2
	move.w	chrlin,d3
	move.w	d2,d0
	addi.w	#18,d0
	move.w	d3,d1
	addq.w	#1,d3
	cmpi.w	#charheight,d3
	blt.s	.skip_2nd_d
	moveq	#0,d3
	addq.w	#1,d2
.skip_2nd_d:
	move.w	d2,actline
	move.w	d3,chrlin
	bsr	PLOT_TEXTSCANLINE
	bra	.loop
.onescan_d:
	movea.l	scr,a0
	movea.l	scr+4,a1
	lea	scrxbytes*txtbgnline(a0),a0
	lea	scrxbytes*(txtbgnline+1)(a1),a1
	move.l	#(18*charheight-1)*scrxbytes,d0
	bsr	COPY_BUFFER
	movea.l	scr,a0
	lea	scrxbytes*(txtbgnline+(18*charheight-1))(a0),a0
	bsr	CLEAR_160BYTES
	move.w	actline,d2
	move.w	chrlin,d3
	move.w	d2,d0
	addi.w	#18,d0
	move.w	d3,d1
	addq.w	#1,d3
	cmpi.w	#charheight,d3
	blt.s	.skip_1_d
	moveq	#0,d3
	addq.w	#1,d2
.skip_1_d:
	move.w	d2,actline
	move.w	d3,chrlin
	bsr	PLOT_TEXTSCANLINE
	bra	.loop

.left:	move.w	actline,d1
	beq	.noswap
	tst.w	scrollcount
	bne	.noswap
	move.w	d1,-(sp)
	bsr	PLOT_MOUSEBACK
	move.w	(sp)+,d1
	addq.w	#1,scrollcount
	subi.w	#18,d1
	bpl.s	.d1ok
	moveq	#0,d1
.d1ok	move.w	d1,d0
	move.w	d0,actline
	movea.l	scr,a0
	lea	txtbgnline*scrxbytes(a0),a0
	movem.l	d0/a0,-(sp)
	move.l	#scrxbytes*144,d0
	bsr	CLEAR_BUFFER
	movem.l	(sp)+,d0/a0
	bsr	PLOT_FULLTEXT
	bra	.loop

.right:	move.w	actline,d2
	addi.w	#18,d2
	cmp.w	textlines,d2
	beq	.noswap
	tst.w	scrollcount
	bne	.noswap
	move.w	d2,-(sp)
	bsr	PLOT_MOUSEBACK
	move.w	(sp)+,d2
	addq.w	#1,scrollcount
	move.w	textlines,d1
	subi.w	#18-1,d1
	cmp.w	d1,d2
	bmi.s	.ready
	move.w	textlines,d2
	subi.w	#18-1,d2
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

.newart:
	move.w	actline,oldline
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

.qsub:	tst.w	subart
	beq	.noswap
	bsr	PLOT_MOUSEBACK
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

.help:	move.w	#1,hlpmode
	lea	helptextname_txt,a1
	lea	filename_txt,a0
.hcplp	move.b	(a1)+,(a0)+
	bne.s	.hcplp
	bra	.newart

.off:	tst.w	music
	beq.s	.stopm
	bsr	PLAY_MUSIC
	bra.s	.doloop
.stopm	bsr	STOP_MUSIC
	move	#$2700,sr
	bclr	#4,$fffffa15.w
	ori.b	#%01101000,$fffffa09.w
	move	#$2300,sr
.doloop	clr.b	mse_tbl+4
	move.w	$468.w,d0
.timlop	move.w	$468.w,d1
	sub.w	d0,d1
	cmpi.w	#25,d1
	bne.s	.timlop
	bra	.noswap

.sng1:	cmpi.w	#1,sngnum
	beq	.noswap
	bsr	STOP_MUSIC
	move.w	#1,sngnum
	bsr	PLAY_MUSIC
	bra	.noswap

.sng2:	cmpi.w	#2,sngnum
	beq	.noswap
	bsr	STOP_MUSIC
	move.w	#2,sngnum
	bsr	PLAY_MUSIC
	bra	.noswap

.sng3:	cmpi.w	#3,sngnum
	beq	.noswap
	bsr	STOP_MUSIC
	move.w	#3,sngnum
	bsr	PLAY_MUSIC
	bra	.noswap

.save:	bsr	PLOT_MOUSEBACK
	bsr	SAVE_ARTICLE
	clr.b	mse_tbl+4
	move.w	$468.w,d0
.timlp2	move.w	$468.w,d1
	sub.w	d0,d1
	cmpi.w	#25,d1
	bne.s	.timlp2
	movea.l	scr,a0
	lea	scrxbytes*txtbgnline(a0),a0
	move.l	a0,-(sp)
	move.l	#scrxbytes*144,d0
	bsr	CLEAR_BUFFER
	move.l	(sp)+,a0
	move.w	actline,d0
	bsr	PLOT_FULLTEXT
	movea.l	scr+4,a0
	lea	scrxbytes*txtbgnline(a0),a0
	move.l	a0,-(sp)
	move.l	#scrxbytes*144,d0
	bsr	CLEAR_BUFFER
	move.l	(sp)+,a0
	move.w	actline,d0
	bsr	PLOT_FULLTEXT
	bra	.loop

.music:	cmpi.w	#3,computer
	bne.s	.f242
	bsr	STOP_MUSIC
	not.w	falcmus
	move.w	#1,sngnum
	bsr	PLAY_MUSIC
.f242	move.w	$468.w,d0
.timlp3	move.w	$468.w,d1
	sub.w	d0,d1
	cmpi.w	#25,d1
	bne.s	.timlp3
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

MUSIC_IRQ:
	DC.L	rts
HBL_IRQ:
	DC.L	rts

rts:	rts

INSTALL_MAINHBL:
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
.nopc:	move.l	#menu_pal,(a1)+
.doloop	addq.w	#1,d7
	subq	#2,a2
	move.w	d1,d2
	addi.w	#charheight+4,d1	* 4 scanlines between upper bar and 2nd textline
	sub.w	chrlin,d1
.loop:	move.w	d1,d3
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
.nopic:	move.l	#menu_pal,(a1)+
.lpend:	addq	#4,a2
	move.w	d1,d2
	addq.w	#1,d7
	addi.w	#charheight,d1
	cmpi.w	#txtbgnline+(18*charheight),d2
	blt.s	.loop
	subi.w	#txtbgnline+(18*charheight),d2
	beq.s	.skip
	sub.w	d2,-6(a1)
.skip	move.l	#menu_pal,2(a1)
	move.w	d7,(a0)+
	rts

WIPEHBL:
	move	#$2700,sr
	movem.l	a0-a1,-(sp)
	lea	end_pal,a1
	lea	$ffff8240.w,a0
	REPT	8
	move.l	(a1)+,(a0)+
	ENDR
	movem.l	(sp)+,a0-a1
	clr.b	$ffffffa1b.w
	rte

MAINHBL:
	move	#$2700,sr
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

.msepck	DC.W	0

******** DATA + INCLUDES ********

	DATA

* FV2 video binaries
stlowrgb_vid:
	INCBIN	STLOWRGB.VID
stlowvga_vid:
	INCBIN	STLOWVGA.VID

amplay_bin:
	INCBIN	AMSID3D3.BIN
	EVEN

font_dat:
	INCBIN	FONT48.DAT

bigcharloc_tbl:
	REPT	32
	DC.W	0,190,3
	ENDR
	DC.W	304,113,10		' ' 32
	DC.W	217,17,5		'!' 33
	DC.W	222,17,8		'"' 34
	DC.W	98,27,6			'#' 35
	DC.W	260,0,4			'$' 36
	DC.W	264,0,4			'%' 37
	DC.W	268,0,4			'&' 38
	DC.W	275,16,5		''' 39
	DC.W	251,16,8		'(' 40
	DC.W	259,16,6		')' 41
	DC.W	284,0,4			'*' 42
	DC.W	308,16,8		'+' 43
	DC.W	297,16,4		',' 44
	DC.W	300,16,8		'-' 45
	DC.W	292,16,4		'.' 46
	DC.W	243,16,8		'/' 47
	DC.W	206,17,10		'0' 48
	DC.W	111,17,8		'1' 49
	DC.W	119,17,11		'2' 50
	DC.W	130,17,10		'3' 51
	DC.W	140,17,10		'4' 52
	DC.W	150,17,11		'5' 53
	DC.W	161,17,12		'6' 54
	DC.W	174,17,10		'7' 55
	DC.W	184,17,10		'8' 56
	DC.W	194,17,12		'9' 57
	DC.W	12,36,4			':' 58
	DC.W	16,36,4			';' 59
	DC.W	280,16,6		'<' 60
	DC.W	284,0,4			'=' 61
	DC.W	286,16,6		'>' 62
	DC.W	288,0,4			'?' 63
	DC.W	92,27,5			'@' 64
	DC.W	0,0,14			'A' 65
	DC.W	14,0,14			'B' 66
	DC.W	28,0,15			'C' 67
	DC.W	43,0,15			'D' 68
	DC.W	58,0,15			'E' 69
	DC.W	73,0,13			'F' 70
	DC.W	86,0,16			'G' 71
	DC.W	102,0,16		'H' 72
	DC.W	118,0,6			'I' 73
	DC.W	124,0,12		'J' 74
	DC.W	136,0,15		'K' 75
	DC.W	152,0,13		'L' 76
	DC.W	165,0,16		'M' 77
	DC.W	185,0,14		'N' 78
	DC.W	199,0,16		'O' 79
	DC.W	216,0,14		'P' 80
	DC.W	230,0,16		'Q' 81
	DC.W	247,0,16		'R' 82
	DC.W	262,0,12		'S' 83
	DC.W	274,0,14		'T' 84
	DC.W	288,0,15		'U' 85
	DC.W	303,0,16		'V' 86
	DC.W	0,16,16			'W' 87
	DC.W	22,16,15		'X' 88
	DC.W	37,16,14		'Y' 89
	DC.W	52,16,13		'Z' 90
	DC.W	0,0,4			'[' 91
	DC.W	36,36,4			'\' 92
	DC.W	0,0,4			']' 93
	DC.W	300,0,4			'^' 94
	DC.W	32,36,4			'_' 95
	DC.W	275,16,5		'`' 96
	DC.W	104,0,4			'a' 97
	DC.W	108,0,4			'b' 98
	DC.W	112,0,4			'c' 99
	DC.W	116,0,4			'd' 100
	DC.W	120,0,4			'e' 101
	DC.W	124,0,4			'f' 102
	DC.W	128,0,4			'g' 103
	DC.W	132,0,4			'h' 104
	DC.W	136,0,4			'i' 105
	DC.W	140,0,4			'j' 106
	DC.W	144,0,4			'k' 107
	DC.W	148,0,4			'l' 108
	DC.W	152,0,4			'm' 109
	DC.W	156,0,4			'n' 110
	DC.W	160,0,4			'o' 111
	DC.W	164,0,4			'p' 112
	DC.W	168,0,4			'q' 113
	DC.W	172,0,4			'r' 114
	DC.W	176,0,4			's' 115
	DC.W	180,0,4			't' 116
	DC.W	184,0,4			'u' 117
	DC.W	188,0,4			'v' 118
	DC.W	192,0,4			'w' 119
	DC.W	196,0,4			'x' 120
	DC.W	200,0,4			'y' 121
	DC.W	204,0,4			'z' 122
	DC.W	0,0,4			'{' 123
	DC.W	308,0,4			'|' 124
	DC.W	0,0,4			'}' 125
	DC.W	88,27,5			'~' 126
	DC.W	0,0,4			'' 127
	DC.W	0,0,4			'Ä' 128
	DC.W	84,27,4			'Å' 129
	DC.W	0,0,4			'Ç' 130
	DC.W	0,0,4			'É' 131
	DC.W	68,27,4			'Ñ' 132
	REPT	9	
	DC.W	0,0,4
	ENDR
	DC.W	65,16,14		'é' 142
	REPT	5
	DC.W	0,0,4
	ENDR
	DC.W	76,27,4			'î' 148
	DC.W	0,0,4			'ï' 149
	DC.W	0,0,4			'ñ' 150
	DC.W	0,0,4			'ó' 151
	DC.W	0,0,4			'ò' 152
	DC.W	79,16,13		'ô' 153
	DC.W	96,16,15		'ö' 154
	REPT	70
	DC.W	0,0,4
	ENDR
	DC.W	292,0,4			'·' 225
	REPT	30
	DC.W	0,0,4
	ENDR

npropfntedge_tbl
	DC.W	%0000000000000000
	DC.W	%1000000000000000
	DC.W	%1100000000000000
	DC.W	%1110000000000000
	DC.W	%1111000000000000
	DC.W	%1111100000000000
	DC.W	%1111110000000000
	DC.W	%1111111000000000
	DC.W	%1111111100000000
	DC.W	%1111111110000000
	DC.W	%1111111111000000
	DC.W	%1111111111100000
	DC.W	%1111111111110000
	DC.W	%1111111111111000
	DC.W	%1111111111111100
	DC.W	%1111111111111110
	DC.W	%1111111111111111

* gem-fileselector-data
aespb	DC.L	contrl,global,intin,intout,addrin,addrout
fsel_input
	DC.W	90,0,2,2,0
appl_init
	DC.W	10,0,1,0,0
appl_exit
	DC.W	19,0,1,0,0

* Required filenames in data
menugfxname_txt
	DC.B	"MENU_GFX.PI1",0
menutextname_txt
	DC.B	"MENUTEXT.TXT",0
helptextname_txt
	DC.B	"HELPTEXT.TXT",0
intropicname_txt
	DC.B	"STARTPIC.PI1",0
modname_txt
	DC.B	"AUTOPLAY.MOD",0
	EVEN

******** RESERVES ********

	BSS

	EVEN

* New stack area.
	DS.L	256
ustk:	DS.L	1
* GEM shit!
* gem-fileselector-reserves
contrl:	DS.W	128
intin:	DS.W	128
intout:	DS.W	128
global:	DS.W	16
addrin:	DS.W	128
addrout	DS.W	128
fsel_file:
	DS.W	8
ddir:	DS.B	128
* Save stuffs.
oldscr:	DS.L	1
oldvbl:	DS.L	1
oldfres	DS.W	1
oldstres:
	DS.W	1
oldst_pal:
	DS.W	16
fvbuf:	DS.B	40
sys_var	DS.L	19
oldmse_adr:
	DS.L	1
mserout_adr:
	DS.L	1
* Timer shit
linenumber:
	DS.W	1
old466:	DS.L	1
hbl_tbl	DS.W	2
	DS.W	22*3
* Control buffers
mse_tbl	DS.W	5
keycode	DS.W	1
	EVEN
* Disk handles/buffers
filhndl	DS.W	1
filedata_buf
	DS.B	44
file_buf
	DS.L	65536/4
* Data about current status of computer/shell
computer
	DS.W	1			/ Keep
monitor	DS.W	1			| these
blitter	DS.W	1			\ toghether
music	DS.W	1
sngnum	DS.W	1
falcmus	DS.W	1
sngtype	DS.W	1
* Text-stuffs
subart	DS.W	1
hlpmode	DS.W	1
actline	DS.W	1
actlin2	DS.W	1
oldline	DS.W	1
chrlin:	DS.W	1
filename_txt:
	DS.B	128
oldartname_txt:
	DS.B	128
gentext_txt:
	DS.B	16
textlines:
	DS.W	1
txt_tbl	DS.W	3*5000
textlen	DS.L	1
text_buf:
	DS.L	40000
scrollcount:
	DS.W	1
* Screenbuffers + pallettes + musicbufs
menu_pal:
	DS.W	16
fade_pal:
	DS.W	16
end_pal	DS.W	16
scr:	DS.L	1
	DS.L	1
scrbuf:	DS.B	256
	DS.L	scrbufsize/4
	DS.L	scrbufsize/4
	DS.W	4
piclin_tbl:
	DS.W	1			number of entries in picture table
	DS.W	3*80			80 entries max!
pic_buf	DS.L	1			endaddress of last picture
	DS.B	picmaxsize*picnmbr
picpck_tbl:
	DS.W	1			number of entries in packet table
	DS.W	4*30			30 entries max!
picname_tbl:
	DS.W	1
	DS.B	32*picnmbr
mse_pic	DS.W	10
	DS.L	2*10
mse2_pic:
	DS.W	10
	DS.L	2*10
mseback_buf:
	DS.L	4*10
menufont_tbl:
	DS.W	8*256*4			* 4 shifted versions of 256 chars 8 lines high
bigmenufont_tbl:
	DS.W	4*16*256
sound_buf:
	DS.W	50000
sound2_buf:
	DS.W	50000