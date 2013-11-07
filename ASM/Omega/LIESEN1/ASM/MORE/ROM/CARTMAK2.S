
	; KONVERT
	;- - - - - 
	
	; Program f”r att l„gga in valfria program p† STC1 cartridge.
	; Disassemblerad och „ndrad 91-11-01 men funkar ej...
	
	; Omskriven 91-11-08. v0.14b funkar nu att l„gga in program med.
	; Genom att toggla bit 0 p† fb0001 med DIP-switchen kan cartridget
	; antingen auto-boota eller inte.

	; v0.14c: G†r att st„nga av AUTO-booten fr†n cart genom att h†lla
	; ned v„nster shift.
	
	opt	P=68000
	opt	o+,w-
	opt	d-

COPYDRIVE	equ	7		; Ska ej „ndras eftersom ROMCOPY anv„nder den...
COPYMASK	equ	1<<COPYDRIVE

DriveNo		equ	15
DriveMask	equ	1<<DriveNo

basestore	equ	$fc		; Var basadressen lagras (spurious interrupt...)

ownid		equ	"RRKO"

key		equ	$1d

	output	.PRG

START
	move.l $4(a7),a0
	move.l #$100,d6
	add.l $C(a0),d6
	add.l $14(a0),d6
	add.l $1C(a0),d6
	move #$80,d7		;128
	lsl.l #8,d7		;* 256
	lsl.l #2,d7		;* 1024
	add.l d7,d6

	pea L70060		; Supexec
	move #$26,-(a7)
	trap #$E
	addq.l #6,a7
	tst.b	nores
	bne.s	avsluta
	move #$2C,-(a7)	; TGettime
	trap #$1
	addq.l #2,a7
	move d0,time1
	move d0,time2
	move #$2A,-(a7)	; TGetdate
	trap #$1
	addq.l #2,a7
	move d0,date1
	move d0,date2
	clr -(a7)		; Ptermres
	move.l d6,-(a7)
	move #$31,-(a7)
	trap #$1
avsluta
	clr	-(sp)
	trap	#1

	;Installera vektorer...
L70060	lea	$472.w,a0
	lea	L700BE(pc),a1
	jsr	instvek(pc)

	lea	$476.w,a0
	lea	L700D0(pc),a1
	jsr	instvek(pc)
	
	lea	$47e.w,a0
	lea	L700E2(pc),a1
	jsr	instvek(pc)

	tst.b	nores
	bne.s	noclear
	lea RAMSTART+$400,a0
	bsr.s L700A2
	or.l #COPYMASK,$4C2.w
noclear
	rts

instvek
	move.l	(a0),a2
	move.l	-12(a2),d0
	cmp.l	#"XBRA",d0
	bne.s	.notinst
	move.l	-8(a2),d0
	cmp.l	#ownid,d0
	bne.s	.notinst
	move.l	-4(a2),(a0)	; l„gg tillbaks gamla vektorn
	st	nores
	rts
.notinst
	move.l	a2,-4(a1)	; lagra gammal vektor
	move.l	a1,(a0)		; l„gg dit ny vektor
	clr.b	nores
	rts

L700A2	bsr.s L700AC
	bsr.s L700AC
	move #$FF,d0
	bra.s L700B0
L700AC	move #$5F,d0
L700B0	clr.l (a0)+
	dbf d0,L700B0
	add.l #$80,a0
	rts

	dc.l	"XBRA"
	dc.l	ownid
L70130	dc.l	0
	; hdv_bpb
L700BE	move $4(a7),d0
	move.l L70130,a0
	lea L700FC,a1
	bra.s L700F2

	dc.l	"XBRA"
	dc.l	ownid
L70134	dc.l	0
	; hdv_rw
L700D0	move $E(a7),d0
	move.l L70134,a0
	lea L70104,a1
	bra.s L700F2


	dc.l	"XBRA"
	dc.l	ownid
L70138	dc.l	0

L700E2	move $4(a7),d0
	move.l L70138,a0
	lea L7012C,a1
L700F2	cmp #COPYDRIVE,d0
	beq.s L700FA
	move.l a0,a1
L700FA	jmp (a1)

	; hdw_mediach
L700FC	move.l #RAMBPB,d0
	rts

	; hdv rw
L70104	move $A(a7),d1		; antal sektorer som ska flyttas
	mulu #$20,d1		; * 32 (16 bytes flyttas per dbf)
	move.l $6(a7),a0	; destadress
	lea RAMSTART,a1
	move $C(a7),d0		; startsektor
	mulu #$200,d0		; * 512
	add.l d0,a1
	tst $4(a7)		; read/write?
	beq.s L70128
	exg a0,a1
L70128	bra FLYTTA
L7012C	clr.l d0
	rts
FLYTTA	subq.l #1,d1
LFA014A	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	dbf d1,LFA014A
	; egen hdv_mediach
	clr.l d0
	rts
nores	dc.b	0
	even






RAMSTART
	org	$fa0000
ROMSTART
	dc.l	$ABCDEF42
	dc.l	NEXTPROGRAM		; Pekare till n„sta program
	dc.l	$8000000+CARTINIT	; Intierings sekvens f”re Disk-Boot
	dc.l	ROMONSTART		; Start p† programmet ROMON.PRG
time1	equ	RAMSTART+*-ROMSTART
	dc	$7885
date1	equ	RAMSTART+*-ROMSTART
	dc	$1762
	dc.l	ROMONSLUT-ROMONSTART
	dc.b	"ROMP.PRG",$0
	even

	; Structur f”r romdisken

RAMBPB	equ	RAMSTART+*-ROMSTART
BPB	dc	$200		; Bytes / sector
	dc	$1		; Sectors / Cluster
	dc	$200		; Bytes / cluster
	dc	$1		; Antal sectors / directory
	dc	$1		; Antal sectors / FAT
	dc	$3		; Startsektor f”r FAT 2 (2)
	dc	$5		; Sectornr f”r f”rsta fria sektor (4)
	dc	$007f		; Totalt antal clusters f”r mediet (fe)
	dc	$0

	even

	; Start f”r ROMON.PRG
ROMONSTART
	pea	S_ROMON(PC)
	bra.s	SHORTCUT

	; Start f”r ROMOFF.PRG
	;---------------------

ROMOFFSTART
	pea	S_ROMOFF(PC)
SHORTCUT
	move	#$26,-(a7)		; SUPER EXEC
	trap	#$E
	addq.l	#6,a7
	clr	-(a7)
	trap	#$1

	; Start f”r ROMON.PRG
	;---------------------
	
S_ROMON	or.l	#DriveMask,$4C2.w		; Drivebits
	move.l	basestore.w,a1
	move	#$ABCD,(cmpadr-base)(a1)	; reagera p† cartridget igen...
	move.l	$472.w,d0
	rts

	; Program f”r ROMOFF.PRG
S_ROMOFF	
	and.l	#($ffffffff^DriveMask),$4C2.w	; Ta bort romdriven
	move.l	basestore.w,a1
	move	#$BCD,(cmpadr-base)(a1)			; Žndra cmp s† att cartridge ej finns...
	rts

ROMONSLUT
ROMOFFSLUT
	; Initieringssekvens som k”rs f”re diskbooten
CARTINIT	

;		HERE GOES INIT AND WAIT!

	
	pea	mallocend-movestart		; allokera systemminne
	move	#$48,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	d0,a0
	move.l	a0,a2
	move	#(moveend-movestart)/2-1,d0
	lea	movestart(pc),a1		; Flytta h„rifr†n
TILLRAM	move	(a1)+,(a0)+
	dbf	d0,TILLRAM
	move.l	$472.w,(a0)+			; lagra hdv_bpb
	move.l	$476.w,(a0)+			; lagra hdv_rw
	move.l	$47E.w,(a0)+			; lagra hdv_mediach
	move.l	a2,$472.w			; egen hdv_bpb
	move.l	a2,basestore.w			; Lagra basadress p† 000000FC (hoppas det g†r...)
	add.l	#(ownhdvrw-ownhdvbpb),a2
	move.l	a2,$476.w			; egen hdv_rw
	add.l	#(ownhdvmediach-ownhdvrw),a2
	move.l	a2,$47E.w			; egen hdv_mediach
	or.l	#DriveMask,$4C2.w		; s„tt vald drive aktiv via _drvbits
	move	#DriveNo,-(a7)			; S„tt default drive till romdisken s† att
	move	#$E,-(a7)			; autoboot sker fr†n denna
	trap	#$1
	addq.l	#4,a7
.noboot
;	pea	null(pc)
;	pea	null(pc)
;	pea	autofile(pc)
;	pea	$004b0000
;	trap	#1
;	lea	$10(a7),a7
	rts

autofile
	dc.b	"P:\OMEGA.PRG"
null	dc.b	0
	even

do_hdv_bpb	
	move.l	#BPB,d0	; hdv_bpb
	rts

	; Egen hdv_rw
do_hdv_rw
	move	$A(a7),d1
	mulu	#$20,d1
	move.l	$6(a7),a0
	lea	ROMSTART,a1
	move	$C(a7),d0
	mulu	#$200,d0
	add.l	d0,a1
	tst	$4(a7)
	beq.s	FLYTTAIGEN
	moveq	#-$1,d0
	rts
FLYTTAIGEN	
	subq.l	#1,d1
LOOPIGEN
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbf	d1,LOOPIGEN

	; egen hdv_mediach
do_hdv_mediach
	clr.l	d0
	rts


	; N„sta program
NEXTPROGRAM
LFA015A	dc.l	$0				; Inga flera program
	dc.l	$0				; Ingen initiering
	dc.l	ROMOFFSTART			; Start f”r ROMOFF.PRG
time2	equ	RAMSTART+*-ROMSTART
	dc	$7885
date2	equ	RAMSTART+*-ROMSTART
	dc	$1762
	dc.l	ROMOFFSLUT-ROMOFFSTART		; L„ngd
	dc.b	"ROMAV.PRG",$0
	even





	; Program som l„ggs upp p† membot
base

movestart
ownhdvbpb
	move	$4(a7),d0			; hdv_bpb: driveno till d0
	move.l	hdv_bpbstore(pc),a0
	lea	do_hdv_bpb,a1
	bra.s	mainromdisk

ownhdvrw
	move	$E(a7),d0			; hdv_rw: driveno till d0
	move.l	hdv_rwstore(pc),a0
	lea	do_hdv_rw,a1
	bra.s	mainromdisk

ownhdvmediach
	move	$4(a7),d0			; hdv_mediach
	move.l	hdv_mediachstore(pc),a0
	lea	do_hdv_mediach,a1
mainromdisk	
	bsr.s	chk_cart			; Kolla om cartridget „r i
	beq.s	LFA01C0				; Hoppa till egen rutin
	move.l	a0,a1				; annars hoppa till orginalrutin
LFA01C0	jmp	(a1)

cmpadr	equ	*+2
chk_cart
	cmp	#$ABCD,ROMSTART			; Finns cartridge
	beq.s	cartexist			; ja!
	and.l	#($ffffffff^DriveMask),$4C2.w	; Ta bort driven
	not	d0				; Invertera driven f”r att sabba comparen
	bra.s	comparen
cartexist	
	or.l	#DriveMask,$4C2.w		; Fixa s† att romdisken finns
comparen
	cmp	#DriveNo,d0			; Access f”r romdisken?
	rts
moveend
hdv_bpbstore	
	dc.l	$0				; H„r lagras gamla adresser
hdv_rwstore		
	dc.l	$0
hdv_mediachstore	
	dc.l	$0
mallocend