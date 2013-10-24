;
; New Trap #1 Loader for Atomic v3.5 packer by MAC SYS DATA - 12/7/92
; ----------------------------------------------------------------
;
; WILL ONLY WORK ON FILES WHICH ARE COMPLETELY READ BY ONE CALL TO
; FREAD (TRAP #1 #$3F).
;

savebuf	= $200
yes	equ	1
no	equ	0

LSEEKROUTINE	EQU 	yes	;WHEN PROG USES LSEEK TO DETERMINE FILE LENGTH
SFIRSTROUTINE	EQU	no	;WHEN PROG USES SFIRST TO DETERMINE FILE LENGTH

text_on		equ	yes
waitkey		equ	yes
quit_gem	equ	yes
lowres		equ	yes
flash		equ	yes
meg_only	equ	no	; If yes then program needs 1 MEGABYTE
bell_off	equ	no
fade		equ	yes

begin	bra	start

fname	dc.b	'copier.pov',$00
	even

text	dc.b	27,"E"
	dc.b	27,"p","MAC SYS DATA PRESENTS",27,"q",13,10
	dc.b	"------------------------",13,10,10
	dc.b	"Press any key to load !!",13,10,10
	dc.b	0
	

start	movea.l	a7,a5 
	lea	begin(pc),a7
	move.l	4(a5),a5
	move.l	$C(a5),d0
	add.l	$14(a5),d0
	add.l	$1C(a5),d0
	add.l	#$100,d0

	move.l	d0,-(a7)
	move.l	a5,-(a7)
	clr.w	-(a7)		; was move.w #$0,-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	adda.l	#12,a7
	
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,-(sp)

	ifne	bell_off		; for programs that need the
	bclr	#0,$484.w		; bell turning off
	endc
;
; Has user only got 512K ????
;
	ifne	meg_only
	move.l	$42e,d0		; Top of user RAM
	cmp.l	#$00080000,d0	; if it equals $80000
	beq.s	half_meg		; then get an upgrade !!
	endc	

	move.l	$84.W,oldtrap1vector
	move.l	#trapit,$84.W

	ifne	fade		;fade down
	lea	$ffff8240.w,a5
	MOVEQ	#7,D1
	MOVE.W	#$777,D2	;colour white
L0007	MOVEQ	#3,D7		;delay for fade in/out
.loop	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	dbf	d7,.loop
	MOVE.W	D2,(A5)
	SUBI.W	#$111,D2
	DBF	D1,L0007

	moveq	#0,d0
	lea	$ffff8240.w,a0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+	;all black

	endc

	ifne	lowres		;if low rez is set put into low
	clr.w 	-(sp)
	pea	-1
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	lea	$c(a7),a7

	else

	move.w	#1,-(sp)	;else go med rez
	pea	-1
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	endc

	ifne	text_on
	pea	text(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	endc

	ifne	fade		;fade up text only
	lea	$ffff8246.w,a5
	lea	$ffff825e.w,a6
	MOVEQ	#7,D1
	MOVE.W	#$000,D2	;colour white
.loop2	MOVEQ	#3,D7		;delay for fade in/out
.dff	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	dbf	d7,.dff
	MOVE.W	D2,(A5)		;low rez colours
	MOVE.W	D2,(A6)		;med rez cols
	add.w	#$111,d2
	DBF	D1,.loop2
	endc

	ifne	waitkey	
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	endc

	ifne	fade		;fade down
	lea	$ffff8246.w,a5
	lea	$ffff825e.w,a6
	MOVEQ	#7,D1
	MOVE.W	#$777,D2	;colour white
myfade	MOVEQ	#3,D7		;delay for fade in/out
.def	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	dbf	d7,.def
	MOVE.W	D2,(A5)
	MOVE.W	D2,(A6)
	SUBI.W	#$111,D2
	DBF	D1,myfade
	endc

;ALWAYS MAKE IT GO LOW REZ BEFORE LOAD.... (MARK SEZ)
	clr.w 	-(sp)
	pea	-1
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	lea	$c(a7),a7

	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	#null,-(sp)
	move.l	#null,-(sp)
	pea	fname(pc)
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#14,sp
	tst.l	d0

;ENSURE THAT YOU CAN QUIT OUT OF PROGRAMS WITHOUT A CRASH

	ifne	quit_gem
quit	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	oldtrap1vector(pc),$84.w
	
	move.l	d0,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	ifne	bell_off
	bset	#0,$484.w
	endc

	move.w	#$4c,-(sp)
	trap	#1

	elseif

quit	move.w	$4.w,a0
	jmp	(a0)

	endc
;
; Trap 512K owners when program requires 1 Meg+ to run !!
;
	ifne	meg_only
half_meg	pea	more_mem(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	move.w	#$4c,-(sp)
	trap	#1

more_mem	dc.b	27,"E"
	dc.b	"NOT ENOUGH MEMORY !!",13,10
	dc.b	"--------------------",13,10,10
	dc.b	"You require 1 megabyte or",13,10
	dc.b	"more to run this program !",13,10,10
	dc.b	"Press any key !!",13,10
	dc.b	0
	even
	endc

trapit:
	btst #$05,(a7)
	bne.s super
	move.l usp,a0
	bra.s after
super:
	move.l a7,a0
	addq.l #6,a0
after:
	cmp.w #$3d,(a0)
	beq doopen
	cmp.w #$3f,(a0)
	beq.s load

	IFNE LSEEKROUTINE
	cmp.w #$42,(a0)
	beq.s down
	ENDC

	IFNE SFIRSTROUTINE
	cmp.w #$4e,(a0)
	beq.s dosfirst
	cmp.w #$2f,(a0)
	beq.s dogetdta
	cmp.w #$1a,(a0)
	ENDC

	bne dotrap1

	IFNE SFIRSTROUTINE
	lea retsetdta(pc),a0
	move.l 2(a7),(a0)
	lea setdta(pc),a0
	move.l a0,2(a7)
	bra dotrap1

dogetdta:
	lea retgetdta(pc),a0
	move.l 2(a7),(a0)
	lea getdta(pc),a0
	move.l a0,2(a7)
	bra dotrap1
	ENDC

doopen:
	lea retopen(pc),a0
	move.l 2(a7),(a0)
	lea open(pc),a0
	move.l a0,2(a7)
	bra dotrap1

;here starts the stuff for SFIRST

	IFNE SFIRSTROUTINE
dosfirst:
	lea retsfirst(pc),a0
	move.l 2(a7),(a0)
	lea sfirst(pc),a0
	move.l a0,2(a7)
	bra.s dotrap1
	ENDC

;here start the stuff for LSEEK
	IFNE LSEEKROUTINE
down:
	lea retlseek(pc),a0
	move.l 2(a7),(a0)
	lea lseek(pc),a0
	move.l a0,2(a7)
	bra.s dotrap1
	ENDC

load:
	move.w inopen(pc),d0
	cmp.w #1,d0
	beq.s dotrap1			;if checking depack marker, do real trap1!
	move.w seekflag(pc),d0
	cmp.w #1,d0
	beq.s dotrap1			;if called from seek handler, exit!
	move.w mustdpak(pc),d0
	cmp.w #1,d0
	bne.s dotrap1			;if marker not present, don't decrunch!

	move.l a7,d0
	movem.l a1-a3,-(sp) 
 
	sub.l #$20,8(a0)
	lea buffer(pc),a1
	move.l 8(a0),(a1)

	move.l d0,a2
	lea return(pc),a1
	move.l 2(a2),(a1)
	lea unpack(pc),a1
	move.l a1,2(a2)

	move.l buffer(pc),a1
	lea savebuf,a2
	move.l #$20,a3
loadloop:
	move.b (a1)+,(a2)+
	subq.l #1,a3
	cmp.l #0,a3
	bne.s loadloop
	movem.l (sp)+,a1-a3
 
dotrap1:
	dc.w $4ef9
oldtrap1vector:
	dc.l $00


;**************************
open:
	tst.l d0
	bmi exitopen2

	movem.l a1-a3,-(sp)
	move.l d0,a3
	lea inopen(pc),a1
	move.w #1,(a1)

	pea test(pc)
	move.l #8,-(sp)
	move.w a3,-(sp)
	move.w #$3f,-(sp)
	trap #1
	add.l #12,sp
	tst.l d0			;ADDED TO FIX ZERO LENGTH FILE
	beq.s notcrun			;DITTO
 
	move.l magic(pc),d0
	cmp.l test(pc),d0
	bne.s notcrun
	lea mustdpak(pc),a1
	move.w #1,(a1)
	bra.s skipit
notcrun:
	lea mustdpak(pc),a1
	move.w #0,(a1)
skipit:

	move.w #1,-(sp)
	move.w a3,-(sp)
	move.l #-8,-(sp)
	move.w #$42,-(sp)
	trap #1
	add.l #10,sp

	move.l a3,d0
exitopen:
	lea inopen(pc),a1
	move.w #0,(a1)
	movem.l (sp)+,a1-a3

exitopen2	dc.w $4ef9
retopen	dc.l $00

inopen	dc.w 0
test	dc.l 0
unpaklen	dc.l 0
mustdpak	dc.w 0
magic	dc.b 'ATM5'

 IFNE SFIRSTROUTINE
;***************************
getdta:
	lea dta(pc),a0
	move.l d0,(a0)
	dc.w $4ef9
retgetdta	dc.l $00

;****************************
setdta:
	lea dta(pc),a0
	move.l 2(a7),(a0)
	dc.w $4ef9
retsetdta	dc.l $00

;***********************************     FOR $4E (SFIRST)
sfirst:
	tst.l d0
	bne pissoff

	move.l 2(a7),a0

	movem.l a1-a3,-(sp)

	move.w #$2,-(sp)
	move.l a0,-(sp)
	move.w #$3d,-(sp)
	trap #1
	addq.l #8,sp
	lea sfirsthandle(pc),a1
	move.w d0,(a1)

	move.w mustdpak(pc),d0
	cmp.w #1,d0
	beq.s change
	bra.s afterchange

change:
	move.l dta(pc),a0
	add.l #26,a0
	move.l unpaklen(pc),d0
	move.l d0,(a0)

afterchange:
	move.w sfirsthandle(pc),-(sp)
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp

	movem.l (sp)+,a1-a3

pissoff:
	dc.w $4ef9
retsfirst:                               ;exit
	dc.l $00
 ENDC

;***********************************     FOR $42 (LSEEK) IN TRAP1
 IFNE LSEEKROUTINE
lseek:
	cmp.w #2,8(a7)
	bne vamos3
	cmp.l #0,2(a7)
	bne vamos3
	lea seekhandle(pc),a0
	move.w 6(a7),(a0)
	lea sd0save(pc),a0
	move.l d0,(a0)

	move.w mustdpak(pc),d0
	cmp.w #1,d0
	bne.s vamos 
	move.l unpaklen(pc),d0
	bra.s vamos3

vamos:
	move.l sd0save(pc),d0
vamos3:
	dc.w $4ef9
retlseek:                            ;exit
	dc.l $00
 ENDC

;************************************    FOR $3F (READ) IN TRAP1
unpack:
         ;a0 - start of crunched data
         ;a1 - beginning of uncrunching area

	movem.l d0-d7/a0-a6,-(sp)
	move.l buffer(pc),a0
	lea origlen(pc),a1
	move.l 4(a0),(a1)

	move sr,d1
	btst #13,d1
	bne nochange

	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	lea jek(pc),a6
	move.l d0,(a6)

	lea mode(pc),a1
	move.w #1,(a1)      ;1 denotes must return to user mode

nochange:
	lea colstore(pc),a1
	move.w $fff8240,(a1)
	move.l buffer(pc),a0
	move.l a0,a1
	add.l #$20,a1
	bsr de_atom35
	move.w colstore(pc),$fff8240

				;restore memory saved in buffer
	move.l buffer(pc),a1
	lea savebuf,a2
	move.l #$20,a3
loadloop2:
	move.b (a2)+,(a1)+
	subq.l #1,a3
	cmp.l #0,a3
	bne.s loadloop2

	move.w mode(pc),d0
	cmp.w #1,d0
	bne nochange2

	move.l jek(pc),-(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp

nochange2:
	lea mode(pc),a1
	move.w #$00,(a1)
	movem.l (sp)+,d0-d7/a0-a6
	move.l origlen(pc),d0
	dc.w $4ef9
return:                            ;exit decrunch module
	 dc.l $00
;------------------------------------------------
;ATOMIK DECRUNCH SOURCE CODE v3.5 (non optimise, pas le temps. sorry...)

;ce depacker est indissociable du programme ATOMIK V3.5 tous les mecs
;qui garderons se source dans l'espoir de prendre de l'importance
;en se disant moi je l'ai et pas l'autre sont des lamers.

;MODE=1 depack data from a0 to a0 
;MODE=0 depack data from a0 to a1 (RESTORE SPACE a 1 inutile! si MODE=0)

;PIC_ALGO = 0 decrunch file not encoded with special picture algorythm.
;PIC_ALGO = 1 decrunch all files with or without picture algorythm.

;DEC_SPACE = (lesser decrunch space is gived after packing by atomik v3.5)
             
;RESTORE_SPACE = 1 the allocated decrunch space will be restored .
;RESTORE_SPACE = 0 the allocated decrunch space will not be restored.

;call it by BSR DEPACK or JSR DEPACK but call it!

MODE:	EQU	0
PIC_ALGO:	EQU	1
DEC_SPACE:	EQU	$80	 ;MAX IS $7FFE (no odd value!)
RESTORE_SPACE:	EQU	1

de_atom35	movem.l	d0-a6,-(a7)
	cmp.l	#"ATM5",(a0)+
	bne	not_packed
	link	a2,#-28
	move.l	(a0)+,d0
	ifne	MODE
	lea	4(a0,d0.l),a5
	move.l	d0,-(a7)
	elseif
	move.l	a1,a5
	add.l	d0,a5
	endc
	move.l	a5,a4
	ifne	MODE
	ifne	DEC_SPACE
	lea	DEC_SPACE(a4),a5
	endc
	endc
	lea	-$c(a4),a4
	move.l	(a0)+,d0
	move.l	a0,a6
	add.l	d0,a6
	ifne	PIC_ALGO
	moveq	#0,d0
	move.b	-(a6),d0
	move	d0,-2(a2)
	ifne	RESTORE_SPACE
	lsl	#2,d0
	sub	d0,a4
	endc
	elseif
	ifne	RESTORE_SPACE
	clr	-2(a2)
	endc
	subq	#1,a6
	endc
	ifne	RESTORE_SPACE
	lea	buff_marg(pc),a3
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.save
.save_m:	move.b	(a4)+,(a3)+
	subq	#1,d0
.save:	bne.s	.save_m
	movem.l	a3-a4,-(a7)
	endc
	ifne	PIC_ALGO
	pea	(a5)
	endc
	move.b	-(a6),d7
	bra	take_type
decrunch:	move	d3,d5
take_lenght:	add.b	d7,d7
.cont_take:	dbcs	d5,take_lenght
	beq.s	.empty1
	bcc.s	.next_cod
	sub	d3,d5
	neg	d5
	bra.s	.do_copy1
.next_cod:	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	bra.s	.do_copy
.next_cod1:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15,d5
	bra.s	.do_copy
.empty1:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_take
.next_cod2:	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15,d5
.do_copy:	add	d3,d5
.do_copy1:	lea	decrun_table(pc),a4
	move	d5,d2
	bne.s	bigger
	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	.ho_kesako
	moveq	#1,d6
	bra.s	word
.ho_kesako:	moveq	#3,d6
	bsr.s	get_bit2
	tst.b	-28(a2)
	beq.s	.ho_kesako1
	move.b	10-28(a2,d5.w),-(a5)
	bra	tst_end
.ho_kesako1:	move.b	(a5),d0
	btst	#3,d5
	bne.s	.ho_kesako2
	bra.s	.ho_kesako3
.ho_kesako2:	add.b	#$f0,d5
.ho_kesako3:	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	tst_end
get_bit2:	clr	d5
.get_bits:	add.b	d7,d7
	beq.s	.empty
.cont:	addx	d5,d5
	dbf	d6,.get_bits
	tst	d5
	rts
.empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont
bigger:	moveq	#2,d6
word:	bsr.s	get_bit2
contus:	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	tst.b	1-28(a2)
	bne.s	.spe_ofcod1
	addq	#4,d6
	bra.s	.nospe_ofcod1
.spe_ofcod1:	bsr.s	get_bit2
	move	d5,d1
	lsl	#4,d1
	moveq	#2,d6
	bsr.s	get_bit2
	cmp.b	#7,d5
	blt.s	.take_orof
	moveq	#0,d6
	bsr.s	get_bit2
	beq.s	.its_little
	moveq	#2,d6
	bsr.s	get_bit2
	add	d5,d5
	or	d1,d5
	bra.s	.spe_ofcod2
.its_little:	or.b	2-28(a2),d1
	bra.s	.spe_ofcod3
.take_orof:	or.b	3-28(a2,d5.w),d1
.spe_ofcod3:	move	d1,d5
	bra.s	.spe_ofcod2
.nospe_ofcod1:	bsr.s	get_bit2
.spe_ofcod2:	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
.copy_same:	move.b	-(a4),-(a5)
	ifne	flash
	move.w	d7,$ffff8240.w		; try d0, d4,d5 & d7
	endc
	dbf	d2,.copy_same
	bra.s	tst_end
make_jnk:	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	string
	move.b	-(a6),-(a5)
tst_end:	cmp.l	a5,a3
	bne.s	make_jnk
	cmp.l	a6,a0
	beq.s	work_done
take_type:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.nospe_ofcod
	move.b	-(a6),d0
	lea	2-28(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
.next:	cmp.b	d0,d1
	bne.s	.no_off_4b
	addq	#2,d1
.no_off_4b:	move.b	d1,(a1)+
	addq	#2,d1
	dbf	d2,.next
	st	1-28(a2)
	bra.s	.spe_ofcod
.nospe_ofcod:	sf	1-28(a2)
.spe_ofcod:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.relatif
	lea	10-28(a2),a1
	moveq	#15,d0
.next_f:	move.b	-(a6),(a1)+
	dbf	d0,.next_f
	st	-28(a2)
	bra.s	.freq
.relatif:	sf	-28(a2)
.freq:	clr	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl	#8,d0
	move.b	-(a6),d0
	move.l	a5,a3
	sub	d0,a3
	bra.s	make_jnk
string:	bra	decrunch
work_done:
	ifne	PIC_ALGO
	move.l	(a7)+,a0
	pea	(a2)
	bsr.s	decod_picture
	move.l	(a7)+,a2
	endc
	ifne	RESTORE_SPACE
	movem.l	(a7)+,a3-a4
	endc
	ifne	MODE
	move.l	(a7)+,d0
	bsr	copy_decrun
	endc
	ifne	RESTORE_SPACE
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.restore
.restore_m:	move.b	-(a3),-(a4)
	subq	#1,d0
.restore:	bne.s	.restore_m
	endc
	unlk	a2
not_packed:	movem.l	(a7)+,d0-a6
 	rts
decrun_table:	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	0,1,3,4,5,6,7,8
	ifne	PIC_ALGO
decod_picture:	move	-2(a2),d7
.next_picture:	dbf	d7,.decod_algo
	rts
.decod_algo:	move.l	-(a0),d0
	lea	0(a5,d0.l),a1
.no_odd:	lea	$7d00(a1),a2
.next_planes:	moveq	#3,d6
.next_word:	move	(a1)+,d0
	moveq	#3,d5
.next_bits:	add	d0,d0
	addx	d1,d1
	add	d0,d0
	addx	d2,d2
	add	d0,d0
	addx	d3,d3
	add	d0,d0
	addx	d4,d4
	dbf	d5,.next_bits
	dbf	d6,.next_word
	movem	d1-d4,-8(a1)
	cmp.l	a1,a2
	bne.s	.next_planes
	bra.s	.next_picture
	endc
	ifne	MODE
copy_decrun:	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun:	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun
	rts
	endc
	ifne	RESTORE_SPACE
buff_marg:	dcb.b	$90+DEC_SPACE+$C
	endc
;------------------------------------------------

	dc.b	"!K.U GUM"

	SECTION DATA
origlen:		dc.l $00
oldssp:		dc.l $00
buffer:		dc.l $00
mode:		dc.l $00
jek:		dc.l $00
length:		dc.l $00
colstore:		dc.l $00
seekflag:		dc.w $00
seekhandle:	dc.w $00
sd0save:		dc.l $00
rtlseeksav:	dc.l $00
sfirsthandle:	dc.l $00
dta:		dc.l $00
oldsize:		dc.l $00
null:		dc.l $00