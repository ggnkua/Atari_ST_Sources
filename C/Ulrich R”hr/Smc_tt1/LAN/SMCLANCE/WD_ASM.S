	.super

; Vektor Interrupt von LAN Karte
;-------------------------------------------------------
      import    wd_interrupt
vekt_new:	    
				move.l		sp,stack_merk     ; sp sichern
                lea.l		new_stack,sp      ; auf freien speicher
				movem.l		d0-d7/a0-a6,-(sp) ; retten auf neuen Stack
				jsr			wd_interrupt      ; routine aktivieren
				movem.l		(sp)+,d0-d7/a0-a6 ; Register rein
                move.l		stack_merk,sp     ; alten sp restaurieren
vekt_exit:		rte


; installieren in Vektor Slot
;----------------------------------------------------------
     export     install_vekt
install_vekt:   move.l  vekt_address,a0 ; Adresse des Ints
				move.l  (a0),vekt_merk
				move.l	#vekt_new,(a0)
                move.l  vekt_level,d0
                tst.l	d0              ; nur wenn Level angegeben
                beq.s   install_end
                bset.b  d0,$FF8E0D      ; Bit Nr = level- 0 ist unbelegt
install_end:	rts

; deinstallieren in Vektor Slot
;----------------------------------------------------------
     export     deinstall_vekt
deinstall_vekt: move.l  vekt_address,a0 ; Adresse des Ints
				move.l  vekt_merk,(a0)
				rts

;------------------------------------------------------
; Kopieren mit movep Befehlen
;-------------------------------------------------------
; a0.l = Zieladresse (Peripherie)
; a1.l = quelladdresse
; d0.w = ZÑhler

export pwrite
pwrite:	movem.l	d0/d1/a0/a1,-(sp)
		lsr.w	#2,d0     ; d0/4
        addq.w  #1,d0     ; ein wenig mehr
pwrite_l:move.l  (a1)+,d1
        movep.l d1,(a0) ; auf Peripherie moven
        addq.l	#8,a0
 	    dbra    d0,pwrite_l   ; Loop
        movem.l	(sp)+,d0/d1/a0/a1
        rts

;------------------------------------------------------
; ZurÅckkopieren mit movep Befehlen
;-------------------------------------------------------
; a0.l = Zieladresse
; a1.l = quelladdresse (Peripherie)
; d0.w = ZÑhler

export pread
pread:	movem.l	d0/d1/a0/a1,-(sp)
		lsr.w	#2,d0     ; d0/4
        addq.w  #1,d0     ; ein wenig mehr
pread_l:movep.l (a1),d1   ; von Peripherie holen
        move.l d1,(a0)+   ; auf Ziel moven
        addq.l	#8,a1
 	    dbra    d0,pread_l   ; Loop
        movem.l	(sp)+,d0/d1/a0/a1
        rts

;------------------------------------------------------
; ZurÅckkopieren mit movep Befehlen
;-------------------------------------------------------
; a0.l = Zieladresse
; a1.l = quelladdresse (Peripherie)
; d0.w = ZÑhler

export pfcopy
pfcopy:	movem.l	a0/a1/d0-d4,-(sp)
		lsr.w	#4,d0     ; d0/4
        addq.w  #1,d0     ; ein wenig mehr
pfcopy_l:move.l  (a1)+,(a0)+
		move.l  (a1)+,(a0)+
		move.l  (a1)+,(a0)+
        move.l  (a1)+,(a0)+
 	    dbra    d0,pfcopy_l   ; Loop

        movem.l (sp)+,a0/a1/d0-d4
        rts

;------------------------------------------------------
; ZurÅckkopieren mit movep Befehlen
;-------------------------------------------------------
; a0.l = Zieladresse
; a1.l = quelladdresse (Peripherie)
; d0.w = ZÑhler

export pfwrite
pfwrite:lsr.w	#2,d0     ; d0/4
        addq.w  #1,d0     ; ein wenig mehr
fwrite_l:move.l  (a1)+,(a0)+ ; von Peripherie holen
 	    dbra    d0,fwrite_l   ; Loop
        rts

	.bss
vekt_merk:		ds.l	1
stack_merk:     ds.l    1
   export vekt_address
vekt_address:   ds.l    1
   export vekt_level
vekt_level:     ds.l    1

				ds.l	4096
new_stack:      ds.l    1
