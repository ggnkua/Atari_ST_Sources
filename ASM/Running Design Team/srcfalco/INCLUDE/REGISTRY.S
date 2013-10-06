
; sicherheitskonzept:
; an der datei sampack1.dat sind in den letzten 20 bytes
; der registrierte name kodiert. die datei wird waehrend
; des hauptmenues eingeladen und dekodiert - und der
; name angezeigt. die anzeigeroutine setzt ein flag,
; das sie durchlaufen wurde.
; im code der engine wird nun auf mehrere arten geprueft,
; ob diese anzeigeroutine ueberhaupt durchlaufen wurde:
; - durchlauf-flag ueberpruefen
; - opcode "jsr registry_get_name" abfragen
; - checksumme der routine "registry_get_name" ueberpruefen
; - ueberpruefen, ob in der routine "registry_get_name" der
;   opcode fuer "rts" nicht schon vorher kommt


;**************************************
;* registry_control_rts
;**************************************

registry_control_rts

		ifne menueflag

		lea	registry_get_name(pc),a0
		move.w	#(registry_get_name_end-registry_get_name)/2-1-1,d0
		moveq	#0,d1
rcr_loop	move.w	(a0)+,d2
		cmpi.w	#$4e75,d2
		beq.s	rcr_error
		dbra	d0,rcr_loop
		bra.s	rcr_ok

rcr_error
		lea	registry_file,a0
		moveq	#8,d0
		jsr	stop_system

rcr_ok
		endc

		rts

;**************************************
;* registry_control_checksum
;**************************************

registry_control_checksum

		ifne menueflag

	;--------------------
	; checksumme berechnen

		lea	registry_get_name(pc),a0
		move.w	#(registry_get_name_end-registry_get_name)/2-1,d0
		moveq	#0,d1
rcc_loop	moveq	#0,d2
		move.w	(a0)+,d2
		add.l	d2,d1
		dbra	d0,rcc_loop

		move.w	registry_checksum,d0
		cmp.w	d0,d1
		beq.s	rcc_ok

		lea	registry_file,a0
		moveq	#8,d0
		jsr	stop_system
rcc_ok
		endc

		rts

;**************************************
;* registry_control_flag
;**************************************

; kontrolliert, ob das flag registry_was_done
; gesetzt wurde

registry_control_flag

		ifne menueflag

		tst.w	registry_was_done
		bne.s	rcf_ok

		lea	registry_file,a0
		moveq	#8,d0
		jsr	stop_system
rcf_ok
		endc

		rts


;**************************************
;* registry_control_main_opcode
;**************************************

; kontrolliert, ob der opcode fuer
; jsr registry_get_name vorhanden ist

registry_control_main_opcode

		ifne menueflag

		lea	rc_pos01-$1234,a5
		adda.l	#$1234,a5
		cmpi.w	#$4eb9,(a5)
		beq.s	rcmo_ok

		lea	registry_file,a0
		moveq	#8,d0
		jsr	stop_system
rcmo_ok
		endc

		rts

;**************************************
;* registry_get_name
;**************************************

registry_get_name

		ifeq	registry_flag
		bra.s	rgn_out
		endc

		movea.l	samples,a0
		adda.l	#mx_intsam_len-20,a0

		lea	sm_registry,a1
		move.w	#1,registry_was_done

		move.b	#$81,d7
		move.b	(a0),d0
		sub.b	d7,d0
		
		addq.l	#4,a0
		move.b	(a0)+,d1
		sub.b	d7,d1
		move.b	d1,(a1)
		lea	3(a1),a1

		subq.b	#1,d0
		bmi.s	rgn_unknown
		cmpi.b	#14,d0
		bgt.s	rgn_unknown
rgn_loop	move.b	(a0)+,d1
		sub.b	d7,d1
		move.b	d1,(a1)+
		dbra	d0,rgn_loop
		clr.b	(a1)
		bra.s	rgn_out

rgn_unknown
		lea	sm_registry,a1
		move.l	#"UNKN",(a1)
		move.l	#"OWN ",4(a1)
		clr.b	7(a1)

rgn_out
		rts

registry_get_name_end

;--------------------------------------

registry_show_hex

		movea.l	screen_2,a0
		jsr	clear_black_240

		movea.l	samples,a0
		adda.l	#mx_intsam_len-20,a0

		moveq	#3,d2
		moveq	#0,d1
rsh_loop2
		jsr	rsh_paint4
		addq.l	#4,a0
		addi.w	#10,d1
		dbra	d2,rsh_loop2

rsh_wait	tst.b	keytable+$39
		beq.s	rsh_wait

		rts

;---------------		

rsh_paint4
		movem.l	d0-a6,-(sp)
		move.l	(a0),d0
		moveq	#7,d7
		movea.l	screen_2,a2
		mulu	#640,d1
		adda.l	d1,a2
		jsr	paint_hex
		movem.l	(sp)+,d0-a6

		rts







