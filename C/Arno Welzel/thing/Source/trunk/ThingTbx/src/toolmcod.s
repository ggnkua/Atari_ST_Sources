;==========================================================================
;TOOLMCOD.S
;
;Assemblerroutinen der Toolbox
;==========================================================================

	globl	get_oshdr
	globl	get_twin
	globl long_2_int

	text
	
;--------------------------------------------------------------------------
;Zeiger auf den OS-Header holen
;
;Deklaration: SYSHDR *get_oshdr(void)
;--------------------------------------------------------------------------

module get_oshdr
	pea			get_oshdr1(pc)
	move.w	#38,-(sp)		; Supexec()
	trap		#14
	addq.l	#6,sp
	move.l	d0,a0
	rts

get_oshdr1:
	move.l	$4f2,d0
	rts
endmod

;--------------------------------------------------------------------------
;Ermitteln des aktiven Fensters - liefert auch unter MagiC das richtige
;Handle! Patch fÅr wind_get(0,WF_TOP,...) Pure C 1.1 :(
;
;Deklaration: void get_twin(int *handle)
;--------------------------------------------------------------------------

get_twin:
	movem.l	a0-a6/d0-d7,-(sp)	;Register retten
	
	move.w	#104,contrl		;AES-Parameterblock vorbereiten
	move.w	#2,contrl+2
	move.w	#5,contrl+4
	move.w	#0,contrl+6
	move.w	#0,contrl+8
	move.w	#0,intin
	move.w	#10,intin+2
	
	move.l	#aespb,d1		;AES-Trap
	move.w	#200,d0
	trap	#2
	
	move.w	intout+2,d0		;Korrektur fÅr MagiC
	cmp.w	#-2,d0
	bne	topok
	move.w	intout+8,intout+2
topok:
	movem.l	(sp)+,a0-a6/d0-d7	;Ergebnis holen
	move.w	intout+2,(a0)
	rts

/*
 * long_2_int
 *
 * Wandelt in Langwort in zwei Wîrter.
 *
 * Pure-C-équivalent:
 * void long_2_int(long lw, int *hi, int *lo)
 *
 * Eingabe:
 * lw (d0): Zu wandelndes Langwort
 * hi (a0): Zeiger auf Wort fÅr den High-Anteil
 * lo (a1): Zeiger auf Wort fÅr den Low-Anteil
 */
module long_2_int
	move.w	d0,(a1)
	swap	d0
	move.w	d0,(a0)
	rts
endmod

;--------------------------------------------------------------------------
;Daten
;--------------------------------------------------------------------------

	data
	
contrl:
	dc.w	0,0,0,0,0
globl:
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
intin:
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
intout:
	dc.w	0,0,0,0,0,0,0
adrin:
	dc.l	0,0
adrout:
	dc.l	0,0
aespb:
	dc.l	contrl
	dc.l	globl
	dc.l	intin
	dc.l	intout
	dc.l	adrin
	dc.l	adrout

	end
