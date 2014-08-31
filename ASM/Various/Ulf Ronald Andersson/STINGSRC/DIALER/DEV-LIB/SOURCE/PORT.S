*
* assembler routines for using the ports
* author     : Jan Kriesten
* last change: 17.03.1994
*
* tabsize    : 4
*

	.INCLUDE "port.sh"

*** Hardware-Adressen:
mfp1		EQU		$00fffa01
mfp2		EQU		$00fffa81
sccctl_a	EQU		$ffff8c81
sccdat_a	EQU		$ffff8c83
sccctl_b	EQU		$ffff8c85
sccdat_b	EQU		$ffff8c87

*** Bco* - Routinen:
bcon_m1		EQU		$0522.w
bcon_midi	EQU		$052A.w


		.TEXT
		
;-------
; DTR-OFF-Routinen:

low_dtr:
		xdef		low_dtr
		
		add.w		d0, d0
		add.w		d0, d0
		
		movea.l		.jmp(pc, d0.w), a1
		jmp			(a1)

.jmp:
		dc.l		.dtr_off1, .dtr_off2, .dtr_off3, .dtr_off4
		
.dtr_off1:
;		move.w		#$10, -(sp)			; DTR-Bit oderieren
;		move.w		#$1e, -(sp)			; Opcode fr Ongibit (XBIOS 30)
		move.l		#$001e0010, -(sp)	;
		trap		#14					; XBIOS-Trap
		addq.l		#4, sp				; Stack restaurieren
		rts
		
.dtr_off2:
		move.l		20(a0), dev			; Adresse der Iorec-Struktur nach
										; dev
		pea			.low_it2(pc)		; Im Supervisormodus ausfhren
		move.w		#$26, -(sp)			; Opcode fr Supexec (XBIOS 38)
		trap		#14					; XBIOS-Trap
		addq.l		#6, sp				; Stack restaurieren
		rts

.low_it2:
		move.w		sr, d1				; Status-Register in d1 retten
		ori.w		#$700, sr			; Interrupts sperren
		
		movea.l		dev(pc), a0			; Iorec Struktur holen
		move.b		$1d(a0), d0			; WR5 Schatten nach d0
		andi.b		#$7f, d0			; DTR aus
		move.b		d0, $1d(a0)			; WR5 Schatten zurckschreiben
		
		lea			sccctl_b, a0		; Adresse des SCC-Control-Registers
		move.b		#$05, (a0)			; Write-Register 5 ausw„hlen
		move.b		d0, (a0)			; und DTR-Bit l”schen (==> DTR low)
		
		move.w		d1, sr				; Interrupts wieder freigeben

.dtr_off3:
		rts
		
.dtr_off4:
		move.l		20(a0), dev			; Adresse der Iorec-Struktur nach
										; dev
		pea			.low_it4(pc)		; Im Supervisormodus ausfhren
		move.w		#$26, -(sp)			; Opcode fr Supexec (XBIOS 38)
		trap		#14					; XBIOS-Trap
		addq.l		#6, sp				; Stack restaurieren
		rts

.low_it4:
		move.w		sr, d1				; Status-Register in d1 retten
		ori.w		#$700, sr			; Interrupts sperren
		
		movea.l		dev(pc), a0			; Iorec Struktur holen
		move.b		$1d(a0), d0			; WR5 Schatten nach d0
		andi.b		#$7f, d0			; DTR aus
		move.b		d0, $1d(a0)			; WR5 Schatten zurckschreiben
		
		lea			sccctl_a, a0		; Adresse des SCC-Control-Registers
		move.b		#$05, (a0)			; Write-Register 5 ausw„hlen
		move.b		d0, (a0)			; und DTR-Bit l”schenn (==> DTR low)
		
		move.w		d1, sr				; Interrupts wieder freigeben
		rts

;-------
; DTR-ON-Routinen:

high_dtr:
		xdef		high_dtr
		
		add.w		d0, d0
		add.w		d0, d0
		
		movea.l		.jmp(pc, d0.w), a1
		jmp			(a1)

.jmp:
		dc.l		.dtr_on1, .dtr_on2, .dtr_on3, .dtr_on4

.dtr_on1:
;		move.w		#$ffe7, -(sp)		; DTR- und RTS-Bit undieren
;		move.w		#$1d, -(sp)			; Opcode fr Offgibit (XBIOS 29)
		move.l		#$001dffe7, -(sp)	;
		trap		#14					; XBIOS-Trap
		addq.l		#4, sp				; Stack restaurieren
		rts
		
.dtr_on2:
		move.l		20(a0), dev			; Adresse der Iorec-Struktur nach
										; dev
		pea			.high_it2(pc)		; Im Supervisormodus ausfhren
		move.w		#$26, -(sp)			; Opcode fr Supexec (XBIOS 38)
		trap		#14					; XBIOS-Trap
		addq.l		#6, sp				; Stack restaurieren
		rts

.high_it2:
		move.w		sr, d1				; Status-Register in d1 retten
		ori.w		#$700, sr			; Interrupts sperren
		
		movea.l		dev(pc), a0			; Iorec Struktur holen
		move.b		$1d(a0), d0			; WR5 Schatten nach d0
		ori.b		#$82, d0			; DTR und RTS an
		move.b		d0, $1d(a0)			; WR5 Schatten zurckschreiben
		
		lea			sccctl_b, a0		; Adresse des SCC-Control-Registers
		move.b		#$05, (a0)			; Write-Register 5 ausw„hlen
		move.b		d0, (a0)			; und schreiben
		
		move.w		d1, sr				; Interrupts wieder freigeben
		
.dtr_on3:
		rts
		
.dtr_on4:
		move.l		20(a0), dev			; Adresse der Iorec-Struktur nach
										; dev
		pea			.high_it4(pc)		; Im Supervisormodus ausfhren
		move.w		#$26, -(sp)			; Opcode fr Supexec (XBIOS 38)
		trap		#14					; XBIOS-Trap
		addq.l		#6, sp				; Stack restaurieren
		rts

.high_it4:
		move.w		sr, d1				; Status-Register in d1 retten
		ori.w		#$700, sr			; Interrupts sperren
		
		movea.l		dev(pc), a0			; Iorec Struktur holen
		move.b		$1d(a0), d0			; WR5 Schatten nach d0
		ori.b		#$82, d0			; DTR und RTS an
		move.b		d0, $1d(a0)			; WR5 Schatten zurckschreiben
		
		lea			sccctl_a, a0		; Adresse des SCC-Control-Registers
		move.b		#$05, (a0)			; Write-Register 5 ausw„hlen
		move.b		d0, (a0)			; und schreiben
		
		move.w		d1, sr				; Interrupts wieder freigeben
		rts

;-------
; DCD-Routinen:
is_dcd:
		xdef		is_dcd
		
		add.w		d0, d0
		add.w		d0, d0
		move.l		dcd_funcs(pc, d0.w), -(sp)
		
		move.w		#$26, -(sp)			; Opcode fr Supexec (XBIOS 38)
		trap		#14					; XBIOS-Trap
		addq.l		#6, sp				; Stack restaurieren

		rts

dcd_funcs:
		dc.l		.dcd1, .dcd2, .dcd3, .dcd4

.dcd1:
		move.b		mfp1, d0			; dcd holen: ~dcd & 2
		not.b		d0
		andi.w		#2, d0
		rts

.dcd2:
		move.b		sccctl_b, d0		; dcd holen: dcd & 8
		andi.w		#8,d0
		rts

.dcd3:
		moveq		#1, d0				; immer Carrier annehmen!
		rts
		
.dcd4:
		move.b		sccctl_a, d0		; dcd holen: dcd & 8
		andi.w		#8,d0
		rts

;-------
; SetMapM1
; ->	a0: Adresse fr Zeiger auf MAPTAB-Struktur
; <-	nichts
;
; Die Funktion setzt die Adressen der I/O-Betriebssystemroutinen
; fr Modem 1 in die lokale Tabelle.
;
; Achtung: Nur aufrufen, wenn es _kein_ Bconmap() gibt!!!
;
SetMapM1:
		xdef		SetMapM1			; Funktion exportieren
		
		move.l		#.map_m1, (a0)		; Zeiger einsetzen
		
		pea			.set_m1(pc)			; Adresse der Funktion auf den Stack
		move.w		#$26, -(sp)			; Opcode fr Supexec (XBIOS 38)
		trap		#14					; XBIOS-Trap
		addq.l		#6, sp				; Stack restaurieren
		
		clr.w		-(sp)				; dev: RS232
		move.w		#$E, -(sp)			; Opcode fr Iorec (XBIOS 14)
		trap		#14					; XBIOS-Trap
		addq.l		#4, sp				;
		
		lea			.map_m1(pc), a1		;
		move.l		d0, iorec(a1)		;
		
		rts

.set_m1:
		lea			.map_m1(pc), a0		;
		lea			bcon_m1, a1			;
		move.l		(a1), (a0)+			;
		move.l		$20(a1), (a0)+		;
		move.l		$40(a1), (a0)+		;
		move.l		$60(a1), (a0)		;
		rts

.map_m1:	dcb.b	MAPTAB, 0

;-------
; SetMapMidi
; ->	a0: Adresse fr Zeiger auf MAPTAB-Struktur
; <-	nichts
;
; Die Funktion setzt die Adressen der I/O-Betriebssystemroutinen
; fr die Midi-Schnittstelle in die lokale Tabelle.
;
SetMapMidi:
		xdef		SetMapMidi			; Funktion exportieren
		
		move.l		#.map_midi, (a0)	; Zeiger einsetzen
		
		pea			.set_midi(pc)		; Adresse der Funktion auf den Stack
		move.w		#$26, -(sp)			; Opcode fr Supexec (XBIOS 38)
		trap		#14					; XBIOS-Trap
		addq.l		#6, sp				; Stack restaurieren
		
		move.w		#2, -(sp)			; dev: MIDI
		move.w		#$E, -(sp)			; Opcode fr Iorec (XBIOS 14)
		trap		#14					; XBIOS-Trap
		addq.l		#4, sp				;
		
		lea			.map_midi(pc), a1	;
		move.l		d0, iorec(a1)		;
		
		rts

.set_midi:
		lea			.map_midi(pc), a0	;
		lea			bcon_midi, a1		;
		move.l		(a1), (a0)+			;
		move.l		$20(a1), (a0)+		;
		move.l		$44(a1), (a0)+		;
		move.l		$60(a1), (a0)		;
		rts

.map_midi:	dcb.b	MAPTAB, 0

;-------
; SetIorec
; ->	a0: Zeiger auf IOREC-Struktur
;		a1: Zeiger auf Speicherbereich
;		d0: L„nge des Speicherblocks
; <-	nichts
;
; Die Funktion setzt die Adresse des Speicherbereichs in die
; IOREC-Struktur.
;
SetIorec:
		xdef		SetIorec			; Funktion exportieren
		
		move.l		a0, dev				; Adresse der Iorec-Struktur nach dev
		move.l		a1, blk				; Adresse des Speicherbereichs nach blk
		move.w		d0, len				; L„nge des Speickerblocks
		
		pea			.sets(pc)			; Im Supervisormodus ausfhren
		move.w		#$26, -(sp)			; Opcode fr Supexec (XBIOS 38)
		trap		#14					; XBIOS-Trap
		addq.l		#6, sp				; Stack restaurieren
		rts

.sets:
		move.w		sr, d2				; Status-Register in d1 retten
		ori.w		#$700, sr			; Interrupts sperren
		
		move.w		len(pc), d0			; L„nge holen
		
		movea.l		dev(pc), a0			; Iorec Struktur holen
		move.l		blk(pc), (a0)		; neuen Block einsetzen
		move.w		d0, 4(a0)			; L„nge einsetzen
		clr.l		6(a0)				; Schreib-/Leseposition 0 setzen
		
		lsr.w		#2, d0				; untere Wassermarke
		move.w		d0, 10(a0)			; einsetzen
		
		move.w		d0, d1				; obere Wassermarke
		add.w		d1, d0				;
		add.w		d1, d0				;
		move.w		d0, 12(a0)			; einsetzen
		
		move.w		d2, sr				; Interrupts wieder freigeben
		rts


;-------
; Funktionsname:	SendBlock
; ->	a0:	Pointer auf DEVICES-Struktur
;		a1:	Adresse des zu sendenden Blocks
;		d0:	Gr”e des Blocks
;		d1:	TRUE, wenn Carrier geprft werden soll, sonst FALSE
; <-	TRUE wenn alles ok, sonst FALSE;
;
; Die Funktion sendet den Block ber die serielle Schnittstelle.
;
SendBlock:
		xdef		SendBlock			; Funktion exportieren
		xdef		pause_2				; 
		
		movem.l		a2-a6/d3-d7, -(sp)	; Register retten
		
		move.l		a0, dev				; Devices-Struktur,
		move.l		a1, blk				; Adresse des Blocks,
		move.l		d0, len				; zu sendende L„nge und 
		move.w		d1, tst				; Carrier-Check retten
		pea			.do_sendblock(pc)	; Senderoutine auf den Stack
		move.w		#$26, -(sp)			; Opcode fr Supexec (XBIOS 38 )
		trap		#14					; XBIOS-Trap
		addq.l		#6, sp				; Stack restaurieren
		
		movem.l		(sp)+, a2-a6/d3-d7	; Register restaurieren
		
		rts

.do_sendblock:
		movea.l		blk(pc), a3			; Adresse des Blocks nach a3
		move.l		len(pc), d4			; zu sendende L„nge nach d4
		move.w		tst(pc), d3			; Carrier-Check Ja/Nein?
		move.l		pause_2(pc), d5		;
		
		; Routinen holen:
		movea.l		dev(pc), a0			; Zeiger auf die DEVICES-Struktur
		
		move.w		func_num(a0), d0	;
		subq.w		#1, d0				;
		add.w		d0, d0				;
		add.w		d0, d0				;
		
		lea			dcd_funcs(pc), a4	;
		move.l		(a4, d0.w), a4		; DCD Funktionen
		
		movea.l		maptab(a0), a0		; MAPTAB-Adresse
		movea.l		bcostat(a0), a5		; Adresse von Bcostat
		movea.l		bconout(a0), a6		; Adresse von Bconout
		
.b1:
		tst.w		d3					; Carrier prfen?
		beq.b		.b2					; wenn nicht, dann weiter bei .b2
		
		jsr			(a4)				; DCD testen
		
		tst.w		d0					; Carrier OK?
		beq.b		.send_nok_ex		; wenn kein Carrier, dann nix senden!
		
.b2:
		subq.l		#1, d4				; Counter erniedrigen
		bmi.b		.send_ok_ex			; wenn < 0, dann fertig!
		
		moveq		#0, d0				; d0 l”schen
		move.b		(a3)+, d0			; zu sendendes Byte nach d0
		move.l		d0, -(sp)			; zu sendendes Byte auf den Stack
										; + dummy fr's Device, damit der
										; Offset stimmt.
.wait:
		jsr			(a5)				; Einsprung in Bcostat
		
		tst.w		d0					; Kann Zeichen gesendet werden?
		bne.b		.send_it			; wenn ja, dann senden
		
		tst.l		d5					; Warteroutine gesetzt?
		beq.b		.wait
		
		movea.l		d5, a0				; Adresse holen und
		jsr			(a0)				; springen ...
		bra.b		.wait
		
.send_it:		
		;*** Senden:
		jsr			(a6)				; Einsprung in Bconout
		addq.l		#4, sp				; Stack restaurieren
		
		bra.b		.b1					; weiter bei .b1 bis ende!
		
.send_ok_ex:
		moveq		#1, d0
		rts
		
.send_nok_ex:
		clr.w		d0
		rts

;-------
; Funktionsname:	GetBlock
; ->	a0:	Pointer auf DEVICES-Struktur
;		a1:	Adresse Buffers
;		d0:	Gr”e des Buffers in Bytes
; <-	Anzahl der gelesenen Bytes;
;
; Die Funktion holt die an der serielle Schnittstelle vorhandenen
; Bytes in einen Buffer.
;
GetBlock:
		xdef		GetBlock			; Funktion exportieren
		
		movem.l		a2-a6/d3-d7, -(sp)	; Register retten
		
		move.l		a0, dev				; Devices-Struktur,
		move.l		a1, blk				; Adresse des Blocks,
		move.l		d0, len				; zu sendende L„nge und 
		pea			.do_getblock(pc)	; Leseroutine auf den Stack
		move.w		#$26, -(sp)			; Opcode fr Supexec (XBIOS 38 )
		trap		#14					; XBIOS-Trap
		addq.l		#6, sp				; Stack restaurieren
		
		movem.l		(sp)+, a2-a6/d3-d7	; Register restaurieren
		
		rts

.do_getblock:
		movea.l		blk(pc), a3			; Adresse des Buffers nach a3
		move.l		len(pc), d4			; Bufferl„nge nach d4
		moveq		#0, d3				; gelesene Zeichen auf 0 setzen
		
		; Routinen holen:
		movea.l		dev(pc), a0			; Zeiger auf die DEVICES-Struktur
		
		movea.l		maptab(a0), a0		; MAPTAB-Adresse
		movea.l		bconstat(a0), a5	; Adresse von Bcostat
		movea.l		bconin(a0), a6		; Adresse von Bconout
		
.b1:
		jsr			(a5)				; Einsprung in Bconstat
		tst.w		d0					; Zeichen vorhanden?
		beq.b		.get_block_ex		; wenn nein, dann zurck
		
		;*** Zeichen holen:
		jsr			(a6)				; Einsprung in Bconin
		move.b		d0, (a3)+			; Zeichen sichern
		addq.l		#1, d3				; Counter hochz„hlen
		
		cmp.l		d3, d4				; Counter testen
		bne.b		.b1					; Buffer voll?
		
.get_block_ex:
		move.l		d3, d0
		rts

*****************************************************************************

dev:		dc.l	0
blk:		dc.l	0
len:		dc.l	0
tst:		dc.w	0

pause_2:	dc.l	0

		.END
