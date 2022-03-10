			EXPORT	decrunch
			
			IMPORT	vm_address

;************************************************************
;* Entpacken einer IMG-Datei:                               *
;*                                                          *
;* A0: Zeiger auf die Quelldaten im physikalischen Speicher *
;* A1: Startadresse im virtuellen Speicher                  *
;************************************************************

decrunch:
			movem.l d3-d7/a2-a6,-(sp)	; Register retten
			move.l	a0,a3				; Quelldaten (phys. Speicher)
			move.l	d0,a4				; Puffer (virt. Speicher);

			movea.l a3,a5
			move.w	2(a3),d0			; Headergrîûe in WORD
			add.w	d0,d0
			lea 	0(a3,d0.w),a3		; Zeiger auf gepackte Daten

			move.w	6(a5),d5			; LÑnge eines Musters in Bytes
			subq.w	#1,d5				; - 1 wegen DBRA

			moveq	#0,d6
			move.w	12(a5),d6			; Bildbreite in Punkten
			addq.w	#7,d6				; auf Bytes aufrunden
			lsr.w	#3,d6				; Zeilenbreite in Bytes
			move.w	d6,a6
			btst	#0,d6				; Breite auf WORD aufrunden
			beq.b	no_corr1
			addq.w	#1,d6
no_corr1:
			move.w	14(a5),d7			; Anzahl der Zeilen
			subq.w	#1,d7				; - 1 wegen DBRA

main3:		
			move.l	a4,d0				; V_ADR
			lea		window_size,a0		; Zeiger auf Fenstergrîûe
			moveq	#4,d1				; Zugriff im WRITE-Modus
			jsr		vm_address			; virt. Speicher adressieren

			lea 	0(a0,a6.w),a1		; Zeiger auf nÑchste Zeile
			lea		0(a4,d6.w),a4		; V_ADR += Zeilenbreite

			moveq	#0,d2

			tst.b	(a3)				; 1. Byte = 0 ?
			bne.b	main1				; nein
			tst.b	1(a3)				; 2. Byte = 0 ?
			bne.b	main1				; nein
			cmpi.b	#$FF,2(a3)			; 3. Byte = $FF ?
			bne.b	main1				; nein
			addq.l	#3,a3				; sonst Zeilenwiederholung
			move.b	(a3)+,d2			; Anzahl Wiederholungen
			subq.w	#1,d2				; - 1 wegen DBRA

main1:		bsr.b	subrout 			; Daten entpacken
			cmpa.l	a1,a0				; Zeilenende erreicht ?
			blt.b	main1				; nein => weitermachen
			subq.w	#1,d7				; alle Zeilen entpackt ?
			bmi.b	ende				; ja => Ende

			tst.w	d2					; nur eine Zeile ??
			beq.b	main3				; dann neue Zeile beginnen

			move.w	d2,d3				; ansonsten die vorherige Zeile
			subq.w	#1,d3				; kopieren

main2:		move.l	a4,d0				; V_ADR
			sub.l	d6,d0				; minus Zeilenbreite
			lea		window_size,a0		; Zeiger auf Fenstergrîûe
			moveq	#4,d1				; Zugriff im WRITE-Modus
			jsr		vm_address			; virt. Speicher adressieren

			lea 	0(a0,d6.w),a1		; Zeiger auf nÑchste Zeile
			lea		0(a4,d6.w),a4		; V_ADR += Zeilenbreite

			move.w 	d6,d0
			subq.w	#1,d0
main4:		move.b	(a0)+,(a1)+			; Zeile kopieren
			dbra	d0,main4

			subq.w	#1,d7				; alle Zeilen entpackt ?
			bmi.b	ende				; ja => Ende
			dbra	d3,main2			; noch eine Zeile kopieren ?
			bra.b	main3				; sonst neue Zeile beginnen

ende:		movem.l (sp)+,d3-d7/a2-a6	; Register restaurieren
			rts


;**************************************
;* Entpackroutinen fÅr eine Bildzeile *
;**************************************

subrout:	moveq	#0,d0
			move.b	(a3)+,d0			; Byte holen
			beq.b	special				; = 0, dann Musterwiederholung
			smi 	d1					; D1 = $FF, falls Bit 7 gesetzt
			tst.b	d0					; D0 > 0 ??
			bpl.b	fill				; dann FÅllroutine aufrufen
			and.b	#$7F,d0				; Bit 6 - Bit 0 = 0 ??
			beq.b	normal				; dann Bytes kopieren

fill:		subq.w	#1,d0				; Anzahl - 1 wegen DBRA
fillloop:	move.b	d1,(a0)+			; FÅllwert (0 oder $FF) schreiben
			dbra	d0,fillloop
			rts

normal: 	move.b	(a3)+,d0			; Anzahl holen
			subq.w	#1,d0				; - 1 wegen DBRA
normalloop: move.b	(a3)+,(a0)+ 		; Bytes kopieren
			dbra	d0,normalloop
			rts

special:	move.b	(a3)+,d0			; Anzahl der Wiederholungen
			subq.w	#1,d0				; - 1 wegen DBRA

			cmp.b	#1,d5				; Muster 2 Bytes breit ?
			beq.b	special2			; dann Spezialbehandlung

			movea.l a3,a2
speciall2:	movea.l a2,a3
			move.w	d5,d1
speciall1:	move.b	(a3)+,(a0)+ 		; Muster kopieren
			dbra	d1,speciall1
			dbra	d0,speciall2		; Muster wiederholen
			rts

special2:	move.b	(a3)+,d3			; Muster (2 Bytes) holen
			move.b	(a3)+,d4
special2l:	move.b	d3,(a0)+			; 1. Byte schreiben
			move.b	d4,(a0)+			; 2. Byte schreiben
			dbra	d0,special2l		; Muster wiederholen
			rts

window_size:	dc.l	2000			; Grîûe des Windows
