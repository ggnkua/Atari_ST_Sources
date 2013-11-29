rpmode	equ	0		; Replay mode offset
rptype	equ	1		; Replay sample type
rpname	equ	2		; Replay name offset
maxlen	equ	70000		; Default sample buffer size
xbraid	equ	"GBel"		; XBRA identification.

start	bra	reside

;	dc.l	"XBRA",xbraid
;oldtrap1 dc.l	0
;trap1	tst.l	gbell_active
;	bne.s	trap1r2		; Skip test if locked (save some CPU)
;	btst	#0,$ff8901
;	bne.s	trap1r2		; Skip if soundchip busy
;	pea	(a0)
;	move.l	usp,a0
;	btst	#5,4(sp)
;	beq.s	trap1t
;	lea	4(sp),a0
;	add.l	staksiz,a0
;
;trap1t	tst.l	bellsample		; Is there a bell sample?
;	beq.s	trap1nb			; If not, skip bell tests
;	cmp.w	#9,(a0)
;	beq.s	cconws
;	cmp.l	#$00020007,(a0)
;	beq.s	cbell
;	cmp.l	#$00060007,(a0)
;	beq.s	cbell
;trap1nb
;	; TRAP 1 TESTS IN HERE
;
;trap1r	move.l	(sp)+,a0
;trap1r2	move.l	oldtrap1,-(sp)
;	rts
;
;cbell	move.l	a6,-(sp)
;	move.l	bellsample(pc),a6
;	bsr	loadspl
;	move.l	(sp)+,a6
;	move.l	(sp)+,a0		; Don't continue in ROM
;	rte
;
;cconws	move.l	2(a0),a0		; Get string to test
;	move.l	d0,-(sp)
;	moveq	#0,d0			; Flag
;cconwsl	cmp.b	#7,(a0)			; Is there a bell?
;	bne.s	nobell
;	moveq	#1,d0			; If so, set flag
;	move.b	d0,(a0)			; And set bell to "no operation"
;nobell	tst.b	(a0)+			; Was this end of string?
;	bne.s	cconwsl			; If not, then loop
;
;	tst.w	d0			; Did we find any bell?
;	bne.s	cconwsb
;
;	move.l	a6,-(sp)
;	move.l	bellsample(pc),a6
;	bsr	loadspl			; Load sample.
;	move.l	(sp)+,a6
;
;cconwsb	move.l	(sp)+,d0		; Restore d0.
;	bra.s	trap1r			; And exit through ROM
;
	dc.l	"XBRA",xbraid
oldtrap13 dc.l	0
trap13	pea	(a0)			; Store a0
	move.l	usp,a0			; Grasp stack
	btst	#5,4(sp)		; supervisor/user?
	beq	trap13t
	lea	4(sp),a0
	add.l	staksiz,a0

	cmp.l	#$50101,(a0)		; Test if GEM is being installed.
	bne	noaltvec
	move.l	a0,-(sp)
	move.l	$88.w,a0
findtrap
	cmp.l	#"XBRA",-12(a0)		; Is there an XBRA?
	bne.s	instal2			; If not, then we reached ROM. Install ourselves
	cmp.l	#xbraid,-8(a0)		; Is it us?
	beq.s	noins2			; If so, we are already installed

	cmp.l	#"LTMF",-8(a0)		; Is it let'em fly?
	bne.s	noltmf
	tst.w	ltmftest
	beq.s	noltmf
	tst.l	swooshsample
	beq.s	noltmf
	move.l	a0,-(sp)
	lea	$52d4(a0),a0
	cmp.l	#$2f0a2f08,(a0)+
	bne.s	noknltmf
	cmp.l	#$3f3c0020,(a0)
	bne.s	noknltmf
	subq	#4,a0
	move.l	newltmf,(a0)+		; Insert jump
	move.w	newltmf+4,(a0)
	clr.w	ltmftest
	bra.s	noltmfa
noknltmf
	clr.l	swooshsample
noltmfa	move.l	(sp)+,a0

noltmf	move.l	-4(a0),a0		; otherwise, check next link
	bra.s	findtrap
instal2	lea	$88.w,a0		; It's trap #2 that is the problem
	move.l	(a0),oldvec		; Remember old vector
	move.l	#gbel,(a0)		; Install new one
noins2					; And return
	move.l	(sp)+,a0
noaltvec
trap13t

trap13nb
	; TRAP 13 tests in here...

trap13r	move.l	(sp)+,a0
	move.l	oldtrap13,-(sp)
	rts
;olda0	dc.l	0

ltmftest dc.w	-1
newltmf	jmp	doswoosh
doswoosh
	tst.l	lock
	bne.s	noswoosh

	movem.l	d0-a6,-(sp)
	move.l	swshst,a1
	move.l	swshen,a2
	moveq	#0,d0
	move.b	swshmod,d0
	trap	#6
	movem.l	(sp)+,d0-a6

noswoosh rts

playspltrap
	btst	#0,$ffff8901
	bne.s	noplaytrap
	bsr	playspl
noplaytrap
	rte

; BELL replacement... ;-)
	dc.l	"XBRA",xbraid
oldbell	dc.l	0
bellvec	tst.l	lock
	bne.s	nodobell
	btst	#0,$ff8901
	bne	nodobell
	movem.l	d0-a6,-(sp)
	move.l	bellst,a1
	move.l	bellen,a2
	moveq	#0,d0
	move.b	bellmod,d0
	bsr	playspl
	movem.l	(sp)+,d0-a6
nodobell
	rts

	dc.l	"XBRA",xbraid
oldvec	dc.l	0

gbel	btst	#0,$ff8901		; Is there a sound on right now?
	bne	gbel_end		; If so, ABORT ABORT ABORT

	tst.l	gbel_active		; Is gbel already active?
	bne	gbel_end		; recurtion lock

	cmp.w	#200,d0			; We're waiting for AES call
	bne	gbel_end

	movem.l	d0-d2/a0/a5-a6,-(sp)

	move.l	d1,a5
	move.l	(a5),a0			; a5=GEM parameter table
	move.l	evttab(pc),a6
	move.w	(a0),d0			; d0=AES function
finntab	move.w	(a6)+,d1
	beq	testaes			; Table func 0: AES execution
	cmp.w	#1,d1			; Table func 1: Alert + text test
	beq	testalert
	cmp.w	#2,d1			; Table func 2: Alert + test all
	beq	testalrta
	cmp.w	#3,d1			; Table func 3: Set window name
	beq.s	testwiname
	cmp.w	#4,d1
	beq.s	testobject
	cmp.w	#24892,d1		; >=24892: Void function.
	bge.s	testvoid
	bra	gbel_e2			; Otherwise, unknown format - kill process
testvoid
	addq	#4,a6
	bra.s	finntab

testobject
	move.w	(a6)+,d1		; Object number to test
	cmp.w	#42,d0			; Check that it _is_ objc_draw
	bne	noalert
	move.l	(a6)+,a0
	move.l	a5,-(sp)

	move.l	16(a5),a5		; Get object_tree address
	move.l	(a5),a5
	mulu	#24,d1			; Get offset for our object
	lea	(a5,d1.l),a5		; Move to offset
	move.w	6(a5),d0
	cmp.w	#20,d0
	blt.s	noobject
	beq.s	obj_string
	cmp.w	#22,d0
	ble.s	obj_ted
	cmp.w	#26,d0
	blt.s	noobject
	beq.s	obj_string
	cmp.w	#28,d0
	blt.s	noobject
	beq.s	obj_string
	cmp.w	#30,d0
	ble.s	obj_ted
	cmp.w	#32,d0
	beq.s	obj_string
noobject
	move.l	(sp)+,a5
	bra.s	nosmpl
obj_ted
	move.l	12(a5),a5	; Get TED_INFO
	move.l	(a5),a5		; Get string
	bra.s	testtext
obj_string
	move.l	12(a5),a5
obj_compare
	bra.s	testtext

testwiname
	cmp.w	#105,d0			; Check that it _is_ wind_set
	bne.s	noalert
	move.l	(a6)+,a0		; Get string
	move.l	a5,-(sp)
	move.l	8(a5),a5
	cmp.w	#2,2(a5)		; Is it wf_name?
	beq.s	dowiname
	move.l	(sp)+,a5		; If not, panic!!!
	bra.s	nosmpl
dowiname
	move.l	4(a5),a5		; Get window name data
	bra.s	testtext

testalrta
	cmp.w	#52,d0
	bne.s	noalert
	move.l	(a6)+,a0
	move.l	a5,-(sp)
	move.l	16(a5),a5
	move.l	(a5),a5
	bra.s	testtext

testalert
	cmp.w	#52,d0			; Is it really an alert?
	bne.s	noalert			; Nope, it is not an alert
	move.l	(a6)+,a0		; Position to read text data
	move.l	a5,-(sp)		; Store parameter for later
	move.l	16(a5),a5		; Get adrin
	move.l	(a5),a5			; Get adrin[0]

findtext cmp.b	#"]",(a5)+		; Skip first parameter
	bne.s	findtext
testtext move.b	(a0)+,d1		; Did we make it though to NULL?
	beq.s	doalert			; If so, then celebrate!
	move.b	(a5)+,d2
	cmp.b	d1,d2			; Otherwise, compare
	beq.s	testtext
	move.l	(sp)+,a5
	bra.s	nosmpl			; Or forget it if not equal/skip spl

doalert	move.l	(sp)+,a5
	bra.s	dosound

noalert	addq	#4,a6			; Skip text test
nosmpl	addq	#4,a6			; Skip sample
	bra.s	finnnxt

testaes	cmp.w	(a6)+,d0
	bne.s	notaes

dosound	move.l	(a6),a6			; Read sample
	bsr	loadspl			; and play it
	bra.s	gbel_e2

notaes	addq	#4,a6			; Skip sample

finnnxt	tst.w	(a6)			; Last entry is negative
	bge	finntab

gbel_e2	movem.l	(sp)+,d0-d2/a0/a5-a6
gbel_end move.l	oldvec,-(sp)
	rts

playspl	tst.w	falcon
	beq.s	notfalcon

	clr.w	$ff8934
;	movem.l	d0/a1-a2,-(sp)

;            pea       132*$00010000
;            trap      #14               ; 8 bit stereo
;            addq.w    #4,sp

;            pea       1
;            move.w    #135,-(sp)
;            trap      #14               ; Timer A, play interrupt
;            addq.w    #6,sp

;            pea       $00030001
;            pea       $00080000
;            pea       139*$00010000
;            trap      #14               ; Devconnect
;            lea       12(sp),sp

;            clr.l     -(sp)
;            move.w    #133,-(sp)
;            trap      #14               ; 1 stereo channel out, 0 in
;            addq.w    #6,sp

;	movem.l	(sp)+,d0/a1-a2

notfalcon
	move.b	#%00,$ff8901		; Stop DMA sound
	bset	#7,d0
	bclr	#6,d0
	move.b	d0,$ff8921		; Sound mode: x kHz 8-bit mono
	move.l	a2,d0
	lea	$ff890f,a0		; End address
	bsr	write24			; movep 24 bits
	move.l	a1,d0
	lea	$ff8903,a0		; Start address
	bsr	write24			; movep 24 bits
	move.b	#%01,$ff8901		; Start sample
	rts

write24	movep.w	d0,2(a0)
	swap	d0
	move.b	d0,(a0)
	rts


; Load sample at (a6) in table
loadspl	tst.l	gbel_active		; Is gbel already active loading?
	bne	nospl			; recurtion lock
	st	gbel_active

	movem.l	d0-a6,-(sp)

	cmp.l	lastld,a6
	bne.s	loadspb

	move.l	lastld+4,a1
	move.l	lastld+8,a2
	bra.s	noinv

loadspb	lea	fullpath(pc),a1
	lea	lpath(pc),a0
copypath move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne.s	copypath
addslash move.b	#"\",(a1)+
	lea rpname(a6),a0
copyname move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne.s	copyname
	clr.b	(a1)+

	clr.w	-(sp)
	pea	fullpath(pc)
	move.w	#61,-(sp)
	trap	#1			; Fopen
	addq	#8,sp
	move.l	d0,d6
	tst.w	d0
	bmi.s	nospl

	clr.l	-(sp)			; zero **********************************
	

	move.l	tespl(pc),-(sp)
	move.l	buffsiz,-(sp)
	move.w	d6,-(sp)
	move.w	#63,-(sp)
	trap	#1			; Fread
	move.l	d0,d5
	lea	12(sp),sp

	move.w	d6,-(sp)
	move.w	#62,-(sp)
	trap	#1			; Fclose
	addq	#4,sp

	move.l	tespl(pc),a1
	lea	(a1,d5.l),a2
	move.l	a6,lastld
	move.l	a1,lastld+4
	move.l	a2,lastld+8
	tst.b	rptype(a6)
	beq.s	noinv

	move.l	a1,a0
invert	add.b	#128,(a0)+
	cmp.l	a2,a0
	blt.s	invert

noinv	move.b	rpmode(a6),d0
	bsr	playspl

	clr.w	gbel_active

nospl	movem.l	(sp)+,d0-a6
	rts

lastld	dc.l	0,0,0

; Lookup table
cook	dc.l	"GBel"
table	dc.l	"MAGI",24892
	dc.l	"_VER","1.0c"		; Version number
	dc.l	"BUFF"			; Sample buffer
bufferbeg
tespl	dc.l	0
	dc.l	"SIZE"			; Sample size
bufferlen
buffsiz	dc.l	maxlen
	dc.l	"TABL"			; Action table begin
evttab	dc.l	0
	dc.l	"TSIZ"			; Size of table data (allocated)
evtsize	dc.l	0
	dc.l	"PATH",lpath		; Load path
	dc.l	"LOCK"			; Active lock
gbel_active
gbell_active
lock
	dc.l	0
	dc.l	"FALC"			; Falcon sound init?
falcon	dc.l	0
	dc.l	"STAK"			; Amount of data pushed at trap
staksiz	dc.l	6
	dc.l	"LAST",fullpath		; Full path of last loaded sample.
	dc.l	"PROG",start-$100	; Program data begin... ;-)
	dc.l	"PSIZ",eoprogr-start+$100+1024 ; Size of resident program
	dc.l	"BELL"			; Address of bellsamplename
bellsample
	dc.l	0
	dc.l	"BELS"			; Address of bellsamplestart
bellst	dc.l	0
	dc.l	"BELE"			; Address of bellsampleend
bellen	dc.l	0
	dc.l	"BELM"			; Bell replay mode
bellmod	dc.l	0
	dc.l	"T#02",gbel		; My trap 2 bender
	dc.l	"T#13",trap13		; My trap 13 bender
	dc.l	"BHOK",bellvec		; Bell_hook routine
	dc.l	"LOAD",loadspl		; Loadspl routine
	dc.l	"PLAY",playspl		; Playspl routine
	dc.l	"SWSH"			; Sample for LTMF swoosh sound
swooshsample dc.l 0
	dc.l	"SWSS"			; Swoosh sounds begin
swshst	dc.l	0
	dc.l	"SWSE"			; Swoosh sounds end
swshen	dc.l	0
	dc.l	"SWSM"			; Swoosh sound mode
swshmod	dc.l	0

	dc.l	0,0			; end of lookup table

fullpath ds.b	160			; Just in case...
lpath	ds.b	160		; Just in case

;********************************************************************
; Malloc in: d0=size needed
;            d1=block ID
;       out: a0=address of bytes allocated
;      note: This alloc routine presumes that if not enough memory
;            can be allocated, it is ok to deallocate any already
;            allocated memory.
domalloc
	movem.l	d1-d7/a1-a6,-(sp)

malloc	move.l	bufferbeg,a0		; Read beginning of actual buffer
	move.l	a0,a1
	add.l	bufferlen,a1		; Find end of buffer...
	move.l	#0,a2			; Address of best match so far

_malloc	tst.l	4(a0)			; Is this part of the buffer allocated?
	beq.s	_mallot			; If not, then test if it can be used...
_mallon	move.l	(a0),a0			; Or if it is, then skip to next allocation
	cmp.l	a1,a0			; Come to the end of the buffer?
	blt.s	_malloc			; If not, then loop...

_mallox	cmp.l	#0,a2			; Has a fitting allocation unit been found?
	beq.s	_mallof			; Otherwise, we will have to force some...

	move.l	d1,4(a2)		; Set owner ID
	lea	10(a2,d0.l),a3		; Get address of next free block
	move.l	(a2),d2			; Calculate size of next block...
	sub.l	a3,d2
	cmp.l	#10,d2			; Is it <= than header?
	ble.s	_mallos			; If so, then just drop it. (No use or impossible)

	move.l	(a2),(a3)		; Copy link...
	clr.l	4(a3)			; ID free on other block...
	move.l	a3,(a2)			; Create new link

_mallos	lea	10(a2),a0		; Return beginning of block in a0
	movem.l	(sp)+,d1-d7/a1-a6
	rts				; ...and size in d0

_mallot	move.l	(a0),d2			; Get address of next link
	sub.l	a0,d2			; Get size of block+header
	sub.l	#10,d2			; Subtract header
	cmp.l	d0,d2			; Big enough?
	blt.s	_mallon			; If not, then check next block

	cmp.l	d7,d2			; Does it 'fit' better?
	bgt.s	_mallon			; If not, then skip to next...

	move.l	d2,d7			; Save fitness
	move.l	a0,a2			; Save block header address
	bra.s	_mallon			; And continue check...

_mallof	move.l	bufferlen,d2		; Get actual buffer length
	sub.l	#10,d2			; subtract header...
	cmp.l	d2,d0			; Do we have enough buffer at all?
	blt	_mallct			; If not, then cut sample buffer...

	move.l	bufferbeg,a0		; Begin at beginning of buffer
	move.l	a0,a2
mallof_	tst.l	4(a0)			; Find first non-free block
	bne.s	_mallff
	move.l	a0,a2
	move.l	(a0),a0
	cmp.l	a1,a0
	blt.s	mallof_
	bra.s	_mallct

_mallff	clr.l	4(a0)			; Free block...
	cmp.l	a0,a2			; Was it the first?
	beq	malloc			; If so, go retry malloc... ;-)

	move.l	(a2),(a0)		; Otherwise, make previous link skip this one
	bra	malloc			; Then retry... ;-)

_mallct	move.l	bufferbeg,a0		; Or give the cut version instead...
	move.l	a1,(a0)+
	move.l	d1,(a0)+
	clr.w	(a0)+
	move.l	a1,d0
	sub.l	a0,d0
	movem.l	(sp)+,d1-d7/a1-a6
	rts


eoprogr
*************************************** Non-resident data ***************
reside	pea	eoprog-start+$100+1024
	move.l	#start-$100,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1			shrink memory
	lea	12(sp),sp

	lea	gbellintro(pc),a0
	bsr	prints

	clr.w	-(sp)
	pea	infname(pc)
	move.w	#$3d,-(sp)
	trap	#1
	addq	#8,sp
	move.w	d0,d7
	bmi	noinfofile

	move.w	#2,-(sp)	; To end	
	move.w	d7,-(sp)
	clr.l	-(sp)
	move.w	#$42,-(sp)
	trap	#1		; Move!
	lea	10(sp),sp
	move.l	d0,d6		; d6=size of file
	clr.w	-(sp)		; To start
	move.w	d7,-(sp)
	clr.l	-(sp)
	move.w	#$42,-(sp)
	trap	#1		; Move!
	lea	10(sp),sp

	move.l	d6,-(sp)	; Allocate memory for file
	add.l	d6,(sp)		; Double it for extra space (strings)
	move.w	#72,-(sp)
	trap	#1
	addq	#6,sp
	tst.l	d0
	beq	nomemory

	move.l	d0,a6		; Store file load area
	lea	(a6,d6.l),a5	; Calculate string write area

	pea	(a6)		; Load area
	move.l	d6,-(sp)	; Load length
	move.w	d7,-(sp)	; Load handle
	move.w	#$3f,-(sp)	; Load action
	trap	#1		; Load trap
	lea	12(sp),sp	; Load stack

	cmp.l	d6,d0		; Check if load length is correct
	bne	loaderror

	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1		; Close file
	addq	#4,sp

	move.l	a6,a0		; a0=read string
	move.l	a6,a1		; a1=write action
	move.l	a5,a2		; a2=write string here first
parse	lea	commandbuff,a3
parse_l	cmp.l	a5,a0		; Have we come to end yet?
	bge	endparse
	move.b	(a0)+,d0
	cmp.b	#" ",d0
	beq.s	parse_com
	move.b	d0,(a3)+
	cmp.l	#commandbuff+19,a3
	blt.s	parse_l
	bra	syntaxerror

parse_com
	clr.b	(a3)+
	lea	commands,a4
parse_tcom
	tst.b	(a4)		; Did we reach end of table?
	beq	syntaxerror	; If so, syntax error
	lea	commandbuff,a3
parse_test
	move.b	(a4)+,d0
	beq.s	parse_tcom	; Over the edge...
	move.b	(a3)+,d1
	beq.s	parse_eow	; End of our word? If so, the other should be, too.
	cmp.b	d0,d1
	beq.s	parse_test
parse_next
	tst.b	(a4)+
	bne.s	parse_next
	bra.s	parse_tcom
parse_eow
	cmp.b	#" ",d0
	bne.s	parse_next
parse_stuff
	move.b	(a4)+,d0	; End of string?
	beq.s	parse		; Then continue with next thing to parse

	move.l	a4,-(sp)

	cmp.b	#"0",d0
	blt.s	notnum
	cmp.b	#"9",d0
	ble.s	do_num
notnum
	cmp.b	#"#",d0
	beq.s	do_immediate
	cmp.b	#"i",d0
	beq.s	do_integer
	cmp.b	#"$",d0
	beq.s	do_string
	cmp.b	#"s",d0
	beq.s	do_sample
	cmp.b	#"b",d0
	beq.s	do_bell
	cmp.b	#"B",d0
	beq.s	do_swoosh

parse_stuffl
	move.l	(sp)+,a4
	bra.s	parse_stuff

do_immediate
	move.l	(sp)+,a4
	move.b	(a4)+,d0
	cmp.b	#"p",d0
	beq.s	make_path
	cmp.b	#"b",d0
	beq.s	make_buffer
	bra	parse

do_num
	and.w	#$ff,d0
	sub.w	#"0",d0
	move.w	d0,(a1)+
	bra.s	parse_stuffl

do_integer
	bsr	make_int
	bra.s	parse_stuffl

do_string
	bsr	make_string
	bra.s	parse_stuffl

do_sample
	move.l	(sp)+,a4
	bra	make_sample

do_bell
	move.l	(sp)+,a4
	move.w	#24892,(a1)+		; Void
	bra	make_sample

do_swoosh
	move.l	(sp)+,a4
	move.w	#24893,(a1)+		; Void
	bra.s	make_sample

make_buffer
	addq	#4,sp
	bsr	get_int
	move.l	d0,buffsiz
	bra	m_newline

make_path
	lea	lpath(pc),a4
m_pathl	move.b	(a0)+,d0
	cmp.b	#" ",d0
	beq	patherror
	cmp.b	#10,d0
	beq.s	m_pathe
	cmp.b	#13,d0
	beq.s	m_pathe
	move.b	d0,(a4)+
	bra.s	m_pathl
m_pathe	clr.b	(a4)+
	bra	m_newline

make_int
	bsr	get_int
	move.w	d0,(a1)+
	rts

make_string
	move.l	#"STRI",(a1)+
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#'"',d0
	bne	stringerr
m_stril	move.b	(a0)+,d0
	cmp.b	#'"',d0
	beq.s	m_strie
	cmp.w	#" ",d0
	blt	stringerr
	cmp.l	a5,a0
	bge	stringerr
m_striq	move.b	d0,(a2)+
	bra.s	m_stril
m_strie	move.b	(a0)+,d0
	cmp.b	#'"',d0
	beq.s	m_striq
	cmp.b	#" ",d0
	bne	stringerr
	clr.b	(a2)+
	rts

make_sample
	move.l	#"SMPL",(a1)+
	bsr	get_int
	cmp.w	#255,d0
	bgt	toobig
	move.b	d0,(a2)+
	bsr	get_int
	cmp.w	#255,d0
	bgt	toobig
	move.b	d0,(a2)+
m_sampl	cmp.l	a5,a0
	bge	namerror
	move.b	(a0)+,d0
	cmp.b	#" ",d0
	beq	namerror
	cmp.b	#10,d0
	beq.s	m_sampe
	cmp.b	#13,d0
	beq.s	m_sampe
	move.b	d0,(a2)+
	bra.s	m_sampl
m_sampe	clr.b	(a2)+
	bra.s	m_newline

get_int
	moveq	#0,d0
	moveq	#0,d1
get_intl
	move.b	(a0)+,d1
	cmp.b	#" ",d1
	beq.s	get_inte
	cmp.b	#13,d1
	beq.s	get_inte
	cmp.b	#10,d1
	beq.s	get_inte
	cmp.w	#"0",d1
	blt	interror
	cmp.w	#"9",d1
	bgt	interror
	sub.w	#"0",d1
	add.l	d0,d0
	move.l	d0,d2
	add.l	d2,d0
	add.l	d2,d0
	add.l	d2,d0
	add.l	d2,d0		; muls.l  ;-)
	add.l	d1,d0
	bra.s	get_intl
get_inte rts

m_newline
	move.b	(a0),d0
	cmp.b	#10,d0
	beq.s	m_linext
	cmp.b	#13,d0
	bne	parse
m_linext
	addq	#1,a0
	bra.s	m_newline

endparse
	move.w	#-1,(a1)+	; Write "End of table"
	move.l	a5,a0		; a0=   read strings we created
	move.l	a1,a5		; a1=a5=where strings should begin
				; a2=   where strings end - now
copystring
	cmp.l	a2,a0
	bgt.s	copystringe
	move.b	(a0)+,(a1)+
	bra.s	copystring

copystringe
	move.l	a1,a2		; Strings: a5-a2
	move.l	a6,a0

pointerl			; Install pointers to strings
	cmp.w	#-1,(a0)
	beq.s	pointere
	cmp.w	#24892,(a0)
	bne.s	pointerb
	move.l	a5,bellsample
pointerb cmp.w	#24893,(a0)
	bne.s	pointerc
	move.l	a5,swooshsample
pointerc move.l	(a0),d0
	cmp.l	#"SMPL",d0
	beq.s	pointspl
	cmp.l	#"STRI",d0
	beq.s	pointstr
	addq	#2,a0
	bra.s	pointerl
pointspl
	move.l	a5,(a0)+
	addq	#2,a5
	bra.s	nextstri
pointstr
	move.l	a5,(a0)+
nextstri
	tst.b	(a5)+
	bne.s	nextstri
	bra.s	pointerl

pointere
	move.l	a5,d0
	sub.l	a6,d0

	move.l	a6,evttab	; Store variables
	move.l	d0,evtsize

	move.l	d0,-(sp)
	pea	(a6)
	pea	$4a0000		; Shrink memory block
	trap	#1
	lea	12(sp),sp

	pea	maxlen
	move.w	#72,-(sp)
	trap	#1
	addq	#6,sp
	tst.l	d0
	beq	nonmem2
	move.l	d0,tespl

************************************
	tst.l	bellsample
	beq.s	nobellsample
	move.l	bellsample,a6
	bsr.s	dogetsample
	move.l	a1,bellst
	move.l	a2,bellen
	move.b	(a6),bellmod
nobellsample
	tst.l	swooshsample
	beq.s	noswooshsample
	move.l	swooshsample,a6
	bsr.s	dogetsample
	move.l	a1,swshst
	move.l	a2,swshen
	move.b	(a6),swshmod
noswooshsample
****************************************************


do_install
	pea	install(pc)
	move.w	#$26,-(sp)
	trap	#14		; S_exec   (read old vector)
	addq	#6,sp

	lea	installtext(pc),a0
	bsr	prints

	clr.w	-(sp)
	pea	eoprogr-start+$100+1024
	move.w	#49,-(sp)
	trap	#1		; Exit / stay resident

dogetsample
	move.l	a6,-(sp)
	lea	fullpath(pc),a1
	lea	lpath(pc),a0
copyp1	move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne.s	copyp1
	move.b	#"\",(a1)+
	lea	rpname(a6),a0
copyn2	move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne.s	copyn2
	clr.b	(a1)+

	clr.w	-(sp)
	pea	fullpath(pc)
	move.w	#61,-(sp)
	trap	#1			; Fopen
	addq	#8,sp
	move.l	d0,d6
	tst.w	d0
	bmi	nospl

	move.w	#2,-(sp)	; To end	
	move.w	d7,-(sp)
	clr.l	-(sp)
	move.w	#$42,-(sp)
	trap	#1		; Move!
	lea	10(sp),sp
	move.l	d0,d6		; d6=size of file
	clr.w	-(sp)		; To start
	move.w	d7,-(sp)
	clr.l	-(sp)
	move.w	#$42,-(sp)
	trap	#1		; Move!
	lea	10(sp),sp

	move.l	d6,-(sp)	; Allocate memory for file
	move.w	#72,-(sp)
	trap	#1
	addq	#6,sp
	tst.l	d0
	beq	nomemoryb

	move.l	d0,a6		; Store file load area
	lea	(a6,d6.l),a5	; Calculate string write area

	pea	(a6)		; Load area
	move.l	d6,-(sp)	; Load length
	move.w	d7,-(sp)	; Load handle
	move.w	#$3f,-(sp)	; Load action
	trap	#1		; Load trap
	lea	12(sp),sp	; Load stack

	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1		; Close file
	addq	#4,sp

	move.l	a6,a1
	lea	(a6,d6.l),a2
	move.l	(sp)+,a6
	tst.b	rptype(a6)
	beq.s	nobellinvert

	move.l	a1,a0
invert2	add.b	#128,(a0)+
	cmp.l	a2,a0
	blt.s	invert2

nobellinvert
	rts


install
************************** Cookie handling ******************
cookie	equ	$5a0

	move.l	cookie.w,a0
	lea	cook(pc),a1
	move.l	(a1)+,d1
	moveq	#4,d2
	moveq	#1,d3
fcooki	move.l	(a0)+,d0
	beq.s	addcooki
	cmp.l	#"_MCH",d0
	bne.s	notmachine
	cmp.l	#$00030000,(a0)
	blt.s	notmachine
	move.l	#"TRUE",falcon
notmachine
	cmp.l	d1,d0
	beq.s	nocooki
	add.l	d2,a0
	addq	#1,d3
	bra.s	fcooki
nocooki	lea	already(pc),a0
	bra	puterminate		; Abort installation

addcooki
	move.l	(a0),d4
	cmp.l	d4,d3
	blt.s	addcookok
	rol.l	#4,d4		; Twice as many cookies * 8 bytes each

	move.l	d4,-(sp)	; Malloc
	move.w	#72,-(sp)
	trap	#1
	addq	#6,sp
	tst.l	d0
	bne.s	cookicopy

	lea	nocookimem(pc),a0
	bra	puterminate

cookicopy
	move.l	d0,a1
	move.l	a1,a2
	move.l	cookie.w,a0
cookicopy2
	move.l	(a0)+,d0
	tst.l	d0
	beq.s	cookilast
	move.l	d0,(a1)+
	move.l	(a0)+,(a1)+
	bra.s	cookicopy2
cookilast
	move.l	#"GBel",(a1)+
	move.l	#table,(a1)+
	clr.l	(a1)+
	move.l	(a0)+,d0
	add.l	d0,d0		; Fix for 2*cookies
	move.l	d0,(a1)+
	move.l	a2,cookie.w	; New cookie table location... ;-)
	bra.s	vectorinst

addcookok
	move.l	(a0),8(a0)
	move.l	d1,-4(a0)
	move.l	a1,(a0)+
	clr.l	(a0)+

*************************************************************
vectorinst
;	lea	$84.w,a0	; -> $84 = trap 1
;	move.l	(a0),oldtrap1
;	move.l	#trap1,(a0)

	tst.l	bellsample
	beq.s	nobellvec
	lea	$5ac.w,a0	; ->$5ac = Bell routine
	move.l	(a0),oldbell
	move.l	#bellvec,(a0)
nobellvec

	move.l	#playspltrap,$98.w ; $98=trap #6 - use this one if need supervisormode

	lea	$b4.w,a0	; -> $b4 = trap 13
	move.l	(a0),oldtrap13
	move.l	#trap13,(a0)
	lea	$80.w,a0
	move.l	(a0),a1
	move.l	#stacalc,(a0)
	move.l	sp,d0
	trap	#0
stacalc	move.l	sp,d1
	move.l	d0,sp
	move.l	a1,(a0)
	sub.l	d1,d0
	move.l	d0,staksiz
	rts

prints	pea	(a0)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	rts

freea6	pea	(a6)
	move.w	#73,-(sp)
	trap	#1
	addq	#6,sp
	rts

stringerr
	lea	strierror(pc),a0
	bra.s	freeterm

patherror
	lea	patherr(pc),a0
	bra.s	freeterm

loaderror
	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq	#4,sp
	lea	loaderrtext(pc),a0
freeterm
	bsr	prints
	bsr	freea6
	bra.s	terminate

noinfofile
	lea	noinfotext(pc),a0
	bra.s	puterminate

syntaxerror
	lea	serror(pc),a0
	bra.s	puterminate

namerror
	lea	namerr(pc),a0
	bra.s	freeterm

nonmem2
	lea	nonmem2t(pc),a0
	bra.s	freeterm

toobig
	lea	toobigtext(pc),a0
	bra.s	freeterm

interror
	lea	interr(pc),a0
	bra.s	freeterm

nomemoryb
	lea	nomembtext(pc),a0
	bsr	prints
	clr.l	bellsample
	bra	nobellsample

nomemory
	lea	nomemtext(pc),a0
puterminate
	bsr	prints

terminate
	lea	abortext(pc),a0
	bsr	prints
	pea	$4c0000
	trap	#1

infname	dc.b	"\GBELL.INF",0

commandbuff
	ds.b	20			; Max size of command

commands
	dc.b	"PATH #p",0		; # = immediate execution
	dc.b	"SAMPLEPATH #p",0
	dc.b	"BUFFER #b",0
	dc.b	"SAMPLEBUFFER #b",0
	dc.b	"AES 0is",0		; i=integer, s=sample
	dc.b	"GEMAES 0is",0
	dc.b	"ALERTEXT 1$s",0
	dc.b	"ALERT 2$s",0		; $=string
	dc.b	"WINAME 3$s",0
	dc.b	"WINDOWNAME 3$s",0
	dc.b	"OBJTEXT 4i$s",0	; Object text
	dc.b	"OBJECTEXT 4i$s",0
	dc.b	"BELL b",0		; action b=bell sample
	dc.b	"SWOOSH B",0		; action B=swoosh sample

	dc.b	0			; End of command table

gbellintro
	dc.b	13,"GBell v1.0c  (C) 1994 Gard Eggesb³ Abrahamsen",13,10
	dc.b	   "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=",13,10,0
noinfotext
	dc.b	   "Couldn't locate GBELL.INF",13,10,0
nomemtext
	dc.b	   "Couldn't allocate memory to load GBELL.INF",13,10,0
loaderrtext
	dc.b	   "Error loading GBELL.INF",13,10,0
serror
	dc.b	   "Syntax error, command not recognized",13,10,0
patherr
	dc.b	   "Invalid path syntax in line PATH",13,10,0
strierror
	dc.b	   "Invalid string syntax",13,10,0
namerr
	dc.b	   "Invalid file name",13,10,0
toobigtext
	dc.b	   "Integer out of range",13,10,0
interr
	dc.b	   "THAT'S NOT AN INTEGER!!!",13,10,0
nonmem2t
	dc.b	   "Can't allocate memory for sample buffer...",13,10,0
already
	dc.b	   "GBell already installed!",13,10,0
nocookimem
	dc.b	   "No room for cookie.",13,10,0
abortext
	dc.b	   "GBell installation aborted.",13,10,10,0
installtext
	dc.b	   "Installed vectors and staying resident",13,10,0
nomembtext
	dc.b	   "Couldn't allocate memory to resident bell sample",13,10,0

eoprog
