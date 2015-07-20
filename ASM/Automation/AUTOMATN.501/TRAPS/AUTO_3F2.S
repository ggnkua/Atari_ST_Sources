;
; New Trap #1 Loader for Automation v5.01 packer by IWWWTTI - 6/1/1992
; --------------------------------------------------------------------
;
; For internal use by Source members ONLY (for now !!)
; (Hopefully this will work unlike the 'Revision 3' sources !!)
;
; WILL ONLY WORK ON FILES WHICH ARE COMPLETELY READ BY ONE CALL TO
; FREAD (TRAP #1 #$3F).
;
; Based on the JAM Packer v4.0 Trap #1 Loader, with some extra bells
; and whistles added !!

savebuf	= $200
yes	equ	1
no	equ	0
LSEEKROUTINE	EQU 	yes	;WHEN PROG USES LSEEK TO DETERMINE FILE LENGTH
SFIRSTROUTINE	EQU	no	;WHEN PROG USES SFIRST TO DETERMINE FILE LENGTH

text_on	equ	yes
waitkey	equ	yes
quit_gem	equ	no
lowres	equ	no
flash	equ	yes
meg_only	equ	yes
bell_off	equ	yes	; switch bell off & back on after quitting

begin	bra	start

	dc.b	"MUG U.Kø Packed Program - Piss Off Ripper !!"
	even

fname	dc.b	'spaceace.exe',$00
	even

cls	dc.b	27,"E",0
	even

text	dc.b	27,"E"
	dc.b	27,"p","MUG U.Kø (of The Source)",27,"q",13,10
	dc.b	"------------------------",13,10,10
	dc.b	"Presents: Space Ace Demo",13,10,10
	dc.b	"by: Glasgow Computer Centre",13,10,10
	dc.b	"Packed by: MUG U.Kø",13,10,10
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
	move.l	A5,-(a7)
	clr.w	-(a7)		; was move.w #$0,-(a7)
	move.w	#$4A,-(a7)
	trap	#1
	ADDA.L	#12,A7
	
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,d7

	ifne	bell_off		; for programs that need the
	bclr	#0,$484.w		; bell turning off
	endc

	ifne	meg_only
	move.l	$42e,d0
	cmp.l	#$00080000,d0	; if top of user ram = $80000
	beq.s	half_meg		; then get an upgrade !!
	endc	
	
	move.l	$84.W,oldtrap1vector
	move.l	#trapit,$84.W

	move.l	d7,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	ifne	lowres
	clr.w 	-(sp)
	pea	-1
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	lea	$c(a7),a7
	endc

	ifne	text_on
	pea	text(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	endc

	ifne	waitkey	
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	endc

	pea	cls(pc)
	move.w	#9,-(sp)
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

	ifne	bell_off		; turn on the bell again after
	bset	#0,$484.w		; you quit the program !!
	endc

	move.w	#$4c,-(sp)
	trap	#1

	elseif

quit	move.w	$4.w,a0
	jmp	(a0)

	endc

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
magic	dc.b 'AU5!'

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
	BSR DEPACK
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
;-----------------------------------------------------------------
; A0 -> A1 depacker

DEPACK	movem.l	d0-a6,-(sp)
	bsr.s	getinfo		
	cmpi.l	#'AU5!',d0	
	bne	not_packed	
	bsr.s	getinfo		
	lea.l	-8(a0,d0.l),a5	
	bsr.s	getinfo		
	move.l	d0,(sp)		
	move.l	a1,a4		
	move.l	a1,a6
	adda.l	d0,a6		
	move.l	a6,a3		
	move.b	-(a5),d7	
	bsr	normal_bytes

	bsr	get_1_bit 	
	bcc.s	not_packed	
	move.w	#$0f9f,d7 	
AU5_00:	moveq	#3,d6		
AU5_01:	move.w	-(a3),d4	
	moveq	#3,d5		
AU5_02:	add.w	d4,d4		
	addx.w	d0,d0		
	add.w	d4,d4		
	addx.w	d1,d1		
	add.w	d4,d4		
	addx.w	d2,d2		
	add.w	d4,d4		
	addx.w	d3,d3		
	dbra	d5,AU5_02 	
	dbra	d6,AU5_01 	
	movem.w	d0-d3,(a3)	
	dbra	d7,AU5_00 	

not_packed:
	movem.l	(sp)+,d0-a6
	rts

getinfo:
	moveq	#3,d1	
getbytes:
	 lsl.l	#8,d0		
	move.b	(a0)+,d0
	dbf	d1,getbytes
	rts

normal_bytes:	
	bsr.s	get_1_bit
	bcc.s	test_if_end	
	moveq.l	#0,d1		
	bsr.s	get_1_bit
	bcc.s	copy_direkt	
	lea.l	direkt_tab+20(pc),a1
	moveq.l	#4,d3
nextgb:	move.l	-(a1),d0	
	bsr.s	get_d0_bits
	swap.w	d0
	cmp.w	d0,d1		
	dbne	d3,nextgb 	
no_more:
	add.l	20(a1),d1
copy_direkt:	
	move.b	-(a5),-(a6)	

	ifne	flash		; flash colours if required !!
;	move.w	d0,$ffff8240.w	; Standard Auto v5.01 flash
	move.w	d7,$ffff8240.w	; Greenies (not the nasal variety !!)
;	not.w	$ffff8240.w	; Black & White Minstrels !!
;	move.b	(a6),$ffff8240.w	; Medway Boys F/X
;	eori.w	#$201,$ffff8240.w	; Dream Warriors F/X
	endc

	dbf	d1,copy_direkt	
test_if_end:	
	cmpa.l	a4,a6		
	bgt.s	strings		
	rts	

get_1_bit:
	add.b	d7,d7		
	bne.s	bitfound	
	move.b	-(a5),d7	
	addx.b	d7,d7
bitfound:
	rts	

get_d0_bits:	
	moveq.l	#0,d1		
hole_bit_loop:	
	add.b	d7,d7		
	bne.s	on_d0		
	move.b	-(a5),d7	
	addx.b	d7,d7
on_d0:	addx.w	d1,d1		
	dbf	d0,hole_bit_loop
	rts	

strings:
	lea.l	length_tab(pc),a1
	moveq.l	#3,d2		
get_length_bit:	
	bsr.s	get_1_bit
	dbcc	d2,get_length_bit
no_length_bit:	
	moveq.l	#0,d4		
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0	
	ext.w	d0		
	bmi.s	no_Åber		
get_Åber:
	bsr.s	get_d0_bits
no_Åber:
	move.b	6(a1,d2.w),d4	
	add.w	d1,d4	
	beq.s	get_offset_2	


	lea.l	more_offset(pc),a1	
	moveq.l	#1,d2
getoffs:
	bsr.s	get_1_bit
	dbcc	d2,getoffs
	moveq.l	#0,d1		
	move.b	1(a1,d2.w),d0	
	ext.w	d0		
	bsr.s	get_d0_bits
	add.w	d2,d2		
	add.w	6(a1,d2.w),d1	
	bpl.s	depack_bytes	
	sub.w	d4,d1		
	bra.s	depack_bytes

get_offset_2:	
	moveq.l	#0,d1		
	moveq.l	#5,d0		
	moveq.l	#-1,d2		
	bsr.s	get_1_bit
	bcc.s	less_40		
	moveq.l	#8,d0		
	moveq.l	#$3f,d2		
less_40:
	bsr.s	get_d0_bits
	add.w	d2,d1		

depack_bytes:			
	lea.l	2(a6,d4.w),a1	
	adda.w	d1,a1		
	move.b	-(a1),-(a6)	
dep_b:	move.b	-(a1),-(a6)	
	dbf	d4,dep_b	
	bra	normal_bytes	


direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.l 270-1,15-1,8-1,5-1,2-1

length_tab:
	dc.b 9,1,0,-1,-1	
	dc.b 8,4,2,1,0		

more_offset:
	dc.b	  11,4,7,0
	dc.w	$11f,-1,$1f	

;*************************************************** Ende der Unpackroutine

;-----------------------------------------------------------------

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
null:		DC.L $00