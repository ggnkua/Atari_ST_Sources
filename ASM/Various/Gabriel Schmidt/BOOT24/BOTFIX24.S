* FIX24.PRG fr Bootsektor *
*                          *
* Bootsektor-Version von   *
* Gabriel Schmidt          *

; Kommentare betreffen nur Žnderungen gegenber FIX24 aus [1].
; Das Prinzip des Programms und das Listing sind dort erkl„rt.

GEMDOS   = 1
CNECIN   = 8
CCONWS   = 9
MXALLOC  = 68

BIOS    = 13
RWABS   = 4

_p_cookies = $5a0

magic    = $1357bd13

	text

	MC68030
	MC68851
	SUPER

	moveq #-1,d6
	lea sterr(pc),a6
	move.l _p_cookies,d0
	beq quit
	move.l d0,a0
cloop:
	movem.l (a0)+,d0-d1
	tst.l d0
	beq quit
	cmp.l #"_MCH",d0
	bne cloop
	swap d1
	subq.l #2,d1
	bne quit
	cmp.l #magic,$5a8
	bne.b noram
	move.l $5a4,d0
	cmp.l #$1000000,d0
	ble.b noram
	lea ramerr(pc),a6
	sub.l #$1000000,d0
	move #1,-(sp)
	move.l d0,-(sp)
	move #MXALLOC,-(sp)
	trap #GEMDOS
	addq.l #8,sp
	tst.l d0
	beq quit
noram:
	movec.l cacr,d0
	or #$0808,d0
	and #$fefe,d0
	movec.l d0,cacr
	lea dummy(pc),a0
	pmove (a0),tc             ; dc.l $f0104000   Alternativ-Codes
	pmove (a0),tt0            ; dc.l $f0100800   fr MAS-68K
	pmove (a0),tt1            ; dc.l $f0100c00   (siehe Text)
	lea $0700,a0
	moveq #15,d0
fill1:
	move.l #$00000742,(a0)+
	dbra d0,fill1
	moveq #15,d0
fill2:
	move.l #$000007c2,(a0)+
	dbra d0,fill2
	moveq #1,d1
	moveq #14,d0
fill3:
	move.l d1,(a0)+
	add.l #$0010000,d1
	dbra d0,fill3
	move.l #$00f00041,(a0)
	pmove trans,tc
	lea message(pc),a6
	clr d6
quit:
	move.w d6,-(sp)
	pea (a6)
	move #CCONWS,-(sp)        ; Meldung ausgeben
	trap #GEMDOS
	addq.l #6,sp
	move.w (sp)+,d6
	beq go                    ; Installation erfolgreich?
	rts                       ; nein, Booten fortsetzen
go:                         ; ja
	move.w #CNECIN,-(sp)      ; Tastendruck abwarten
	trap #GEMDOS
	addq.l #2,sp
	move.w #0,-(sp)
	move.w #0,-(sp)
	move.w #1,-(sp)
	pea bootsec(pc)
	move.w #2,-(sp)
	move.w #RWABS,-(sp)       ; Bootsektor lesen
	trap #BIOS
	lea $e(sp),sp
	lea bootsec(pc),a0        ; Bootsektor ausfhrbar?
	clr d0
	move.w #255,d1
bloop:
	add.w (a0)+,d0
	dbra d1,bloop
	cmp #$1234,d0
	beq bootsec               ; ja, Bootsektor ausfhren
	rts                       ; nein, Booten fortsetzten

trans:    dc.l $80f04445
dummy:    dc.l 0
sterr:    dc.b $0d,$0a,"FIX24 l„uft nur auf dem TT!",$0d,$0a,$00
message:  dc.b $0d,$0a,"BootFIX24 V1.0 installiert,",$0d,$0a
          dc.b "Cache aus...   [TASTE] -> Reboot",$0d,$0a,$00
ramerr:   dc.b $0d,$0a,"Das TT-RAM ist nicht leer!",$0d,$0a,$00

	even
bootsec:  ds.w 1
