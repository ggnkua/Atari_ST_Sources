*  sony.s - sony mini flop driver					*



***************************************************************************
**  NOTES:
**
**  mods:
**  #	  who date	change
**  ----- --- ---------	------
**  M0001 ktb 13 Aug 85	Changed label _bconout to _cputc, which is what is
**			now in the console drivers.
**
**  M0002 ktb 15 Aug 85	Changed the way the tick interrupt handles # ticks
**			per msec and calls the log tik intr handler
**
**  M0003 ktb 15 Aug 85	Added SCCs ffmt routine
**
***************************************************************************

*
*  local constants
*

IF_RPKT		equ	1	* receive packet flag for log intr routines


*
*  global definitions
*
	.xref	_fdisk
	.xref	_fdint
	.xref	_nsect
	.xref	_fdinit
	.xref	_popit
	.xref	_ffmt		* M0003

*
*  externals
*

	.xdef	_clkvec
	.xdef	_cputc		* M0001 ktb
	.xdef	_slot3i
	.xdef	_tmertck	* for autorepeat keys; see conio.c
	.xdef	_criter
	.xdef	_blink
	.xdef	_newdsk
**
**  _fdinit -
**
_fdinit:
	clr	proflg
	clr	fstat
	move.b	#0,fdflg	* assume no diskop in progress
	move.l	#$fcc000,a0
	move.b	#$ff,3(a0)
	move.b	#$85,1(a0)
wt1:	tst.b	1(a0)
	bne	wt1
	move.b	#$88,3(a0)
	move.b	#$86,1(a0)
wt2:	tst.b	1(a0)
	bne	wt2
	rts
*
* fdisk - floppy disk (twiggy) handler
* stack structure (after link)  a5    -> callers frame pointer (olda5)
*				      +4 callers retadd
*			caller parms  +8 drv,cyl,head,buf,op (r/w=0/1)
*				     +20 sector #
*
_fdisk:	link	a5,#0
	movem.l	d1-d2/a0-a4,-(sp)
retwig:	clr	fstat
	move.l	#fdparms,a0		* base of fd parm area
	move	8(a5),4(a0)		* drive
	move	10(a5),d0		* cyl
	move	d0,$a(a0)		* set track
	move	12(a5),6(a0)		* head (side)
	move	18(a5),2(a0)		* op
	clr	$c(a0)
	move	12(a5),d1
	or	d0,d1			* track and head = 0, write aaaa in fileid
	bne	nofid
	move	#11,d2			* fill 12 bytes of header with aaaa`s
	move.l	#$fcc3e9,a1
fidlp:	move.b	#$aa,(a1)		* fileid for booting
	addq.l	#2,a1
	dbf	d2,fidlp
nofid:	move.l	14(a5),a3		* buffer address in a3
* keep the but/dips away
	clr	fdflg			* it should have been clear, but...
	bsr	nocmd			* wait until no cmd pending (disable ints)
	move.b	#$fe,fdflg		* lock out others
	move	d2,sr			* re-enable ints
	move	20(a5),d1	* sector #
rwnxt:	lea	fdparms+2,a0
	move.l	#$fcc002,a2
	move	#5,d2			* 6 parms to move
mvprml:	move	(a0)+,(a2)+
	dbf	d2,mvprml
	move.l	#$fcc000,a0
	move.b	d1,9(a0)		* set phys sector
*
* drop through, just do 1 sector
*
rwlp:	tst	18(a5)			* write ?
	beq	gogo			* no, go
	move	#511,d2
	lea	$401(a0),a2		* start of buffer	
wmov:	move.b	(a3)+,(a2)
	addq.l	#2,a2
	dbf	d2,wmov
gogo:	tst	bdcmd			* is button/dip command pending ?
	bne	gogo			* wait right here
	move.b	#$ff,fdflg
	move.b	#$81,1(a0)		* set the gobyte and go
wtflg:	btst.b	#0,fdflg
	bne	wtflg			* fdir interrupt routine will set this
	tst	18(a5)			* if this was a read, copy out the data
	bne	rwlp2			* no, skip this
	move	#511,d2
	lea	$401(a0),a2
rmov:	move.b	(a2),(a3)+
	addq.l	#2,a2
	dbf	d2,rmov
rwlp2:
*
* drop through to end logic
*
* done with command, let others go
	clr.b	fdflg
	bsr	dopend
	move	#1,d0			* return no error
	tst	fstat
	beq	fddone			* there was none
*
* critical error occurred
*
	move	fstat,d0
	move	d0,d1
	lsr	#4,d0			* display hi nyb
	and	#$f,d0
	or	#$40,d0
	move	d0,-(sp)

	bsr	_cputc			* M0001 ktb

	and	#$f,d1
	or	#$40,d1
	move	d1,(sp)

	bsr	_cputc			* M0001 ktb

	addq.l	#2,sp	
*
	move	fstat,-(sp)
	jsr	_criter		* if this returns, then retry
	jmp	retwig
	clr	d0
fddone:	clr	fstat
	movem.l	(sp)+,d1-d2/a0-a4
	unlk	a5
	rts
*
nocmd:	move	sr,d2
	move	#$2700,sr
	tst	fdflg			* rwts pending ?
	bne	wtagin
	tst	bdcmd			* but/dip (clamp/unclamp) pending ?
	bne	wtagin
	rts				* got sync
wtagin:	move	d2,sr
	bra	nocmd
*
*
*
clrvrt:	move.l	d0,$fce018	* long to re-enable
wtclr:	btst.b	#2,$fcf801
	beq	wtclr
	movem.l	d0-d7/a0-a6, -(sp)	* RJG 4/15/85 as per bios spec

	jsr	_blink
	jsr	_tmertck		* for autorepeat keys; see conio.c
*
* its clear, do hw stuff
*	call timer vector with the number of msecs since last tick
*	M0002
*
	bsr	tiktim		*  d0 <- nbr msecs since last tick
*  				*  (*_tkintr)( IF_RPKT , tcktim() ) ;
	move.l	d0,-(sp)	*    nbr msecs onto stack
	move.l	#IF_RPKT,-(sp)	*    flags onto stack
	move.l	_clkvec,a0	*    addr of intr routine 
	jsr	(a0)		*    make call

	addq.l	#8,sp		*  clear stack

*
*  return from excp
*

	movem.l	(sp)+, d0-d7/a0-a6	
	rte
*
*
* check and clear the profile
prochk:	movem.l	d0/a0,-(sp)
	move.l	#$fcd900,a0
proch1:	btst.b	#1,$69(a0)		* profile BSY int ?
	beq	whoops			* nope, I`m confused 
	movem.l	(sp)+,d0/a0
	jmp	_slot3i
*
_fdint:
	btst.b	#2,$fcf801		* check status reg (vertical retrace)
	beq	clrvrt
ipatch1: btst.b	#7,$fcd969		* something in via ifr ?
	bne	prochk
	tst.b	fdflg			* fd command pending ?
	bne	fdyes			* yes, do it !
* must be button or diskinplace int with no commands pending
	move.l	d2,-(sp)
	bsr	butdip
	bsr	nocmd
	bsr	dopend
	move	d2,sr
	move.l	(sp)+,d2
	rte

fdyes:	movem.l	d0-d1/a0,-(sp)
	move.l	#$fcc000,a0
	move.b	$5f(a0),d0
	tst.b	d0
	beq	whoops
	move	d0,d1
	andi.b	#$44,d1			* is this a rwts complete ?
	bne	clrwts
	bsr	butd2			* oh shit, I`m in the wrong place
	bra	fdout
clrwts:	move.b	d1,3(a0)
	move	fstat,d0		* or latest status into status byte
	or.b	$11(a0),d0
	move	d0,fstat
	move.b	#$85,1(a0)
clwtlp:	tst.b	1(a0)
	bne	clwtlp
	bclr.b	#0,fdflg
fdout:	movem.l	(sp)+,d0-d1/a0
	rte
*
butdip:	movem.l	d0-d1/a0,-(sp)
	move.l	#$fcc000,a0
	move.b	$5f(a0),d0		* button, diskinplace handler
	bsr	butd2
	movem.l	(sp)+,d0-d1/a0
	rts
	
butd2:	move.b	d0,3(a0)		* clamp/unclamp completion is RWTS-bit 2,6
	move.b	#$85,1(a0)		* clear them now
butwt:	tst.b	1(a0)
	bne	butwt
	and	#$33,d0
	or.b	bdpend,d0
	move.b	d0,bdpend
	clr	bdcmd			* its soup
	rts

_popit:	or	#$2000,bdpend
dopend:	movem.l	d1/a0,-(sp)
	move.l	#$fcc000,a0
	btst.b	#5,bdpend		* button on drv 1
	bne	but1
	btst.b	#4,bdpend
	bne	dip1
	btst.b	#1,bdpend
	bne	but2
	btst.b	#0,bdpend
	bne	dip2
	clr.b	bdpend			* no pending stuff left
	clr	bdcmd
	bra	nobdc
bdend:	move	#$ff,bdcmd		* button/dip command has been sent
nobdc:	movem.l	(sp)+,d1/a0
	rts

but1:	bclr	#5,bdpend
	move	#$80,d1
	move	#1,_newdsk
	bra	clbut
but2:	bclr	#1,bdpend
	clr	d1
clbut:	move.b	d1,5(a0)
	move.b	#2,3(a0)
	move.b	#$81,1(a0)
	bra	bdend
dip1:	bclr	#4,bdpend
	move	#$80,d1
	move	#1,_newdsk
	bra	cldip
dip2:	bclr	#0,bdpend
	clr	d1
cldip:	move.b	d1,5(a0)
	move.b	#9,3(a0)
	move.b	#$81,1(a0)
	bra	bdend
*
* spurious interrupt
whoops: move.l	#imess,d1
	move.w	#9,d0
	trap	#2
	movem.l	(sp)+,d0/a0
	rte


******************************************************************************
**
** _ffmt - floppy format
**	M0003
**

_ffmt:
	move.l	#$FCC000,a0	* a0 -> FD I/O block
	tst	4(sp)		* check for A: or B:
	bne	is_b

	move.b	#$80,$5(a0)	* drive <- a:
	bra	f_cmd

is_b:
	move.b	#$00,$5(a0)	* drive <- b:
f_cmd:
	move.b	#$03,$3(a0)	* command <- format
	move.b	#$00,$B(a0)	* track <- 0
	move.b	#$00,$D(a0)	* speed <- normal
	move.b	#$FF,$F(a0)	* format confirm <- $FF
	move.b	#$FF,fdflg	* (set flag that _fdint will clear)
	clr	fstat		* (clear error status)
	move.b	#$81,$1(a0)	* command trigger <- go

* wait for command termination

f_wait:
	btst.b	#0,fdflg	* _fdint will clear this
	bne	f_wait		* loop into command done

* check for error

	move	fstat,d0	* pick up status
	rts			* and return to caller


***************************************************************************
**  tiktim -
**	return the number of milliseconds since the last tick.
**	nothing fancy here, we just assume that the only one calling us
**	is the tick interrupt, so the time between calls is constant.
**
**	there are currently about 15.2 msecs per tick.  So every fifth
**	call we return 16 to make up for it.
**

tiktim:
	moveq	#15,d0		* assume 15 until test
	addq	#1,tikcnt
	cmp	#4,tikcnt
	bls	tikxit

	moveq	#16,d0
	clr	tikcnt

tikxit: rts


***************************************************************************
*				data area


	.even
imess:	.dc.b	"Unexpected interrupt.",13,10,"$"
	.even
proflg:	.dc.w	0
fdflg:	.dc.w	0
fstat:	.dc.w	0
bdpend:	.dc.w	0
bdcmd:	.dc.w	0
fdparms: .ds.b	16
_nsect:	
* sony table
	.dc.b	12,12,12,12,12,12,12,12
	.dc.b	12,12,12,12,12,12,12,12
	.dc.b	11,11,11,11,11,11,11,11
	.dc.b	11,11,11,11,11,11,11,11
	.dc.b	10,10,10,10,10,10,10,10
	.dc.b	10,10,10,10,10,10,10,10
	.dc.b	9,9,9,9,9,9,9,9
	.dc.b	9,9,9,9,9,9,9,9
	.dc.b	8,8,8,8,8,8,8,8
	.dc.b	8,8,8,8,8,8,8,8
* twiggy table
	.dc.b	22,22,22,22
	.dc.b	21,21,21,21,21,21,21
	.dc.b	19,19,19,19,19,19
	.dc.b	18,18,18,18,18,18
	.dc.b	17,17,17,17,17,17
	.dc.b	16,16,16,16,16,16,16
	.dc.b	15,15,15,15


***************************************************************************
*			bss

	.bss
tikcnt:	.ds.w	1
	.end
