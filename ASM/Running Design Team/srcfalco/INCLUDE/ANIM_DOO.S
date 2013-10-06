;**************************************
;* animate_doors
;**************************************

animate_doors
		move.w	an_doors_flag,d2
		beq.s	ad_no_doors

		lea	an_doors_ptr,a0
		moveq	#anim_doors_max-1,d3
		moveq	#0,d4

ad_loop
		btst	d4,d2
		beq.s	ad_skip_door

		movea.l	(a0,d4.w*4),a1
		bsr	anim_one_door

ad_skip_door
		addq.w	#1,d4
		dbra	d3,ad_loop

		move.w	d2,an_doors_flag

ad_no_doors
		rts

;---------------

anim_one_door

;    a1: zeiger auf eine tuer, bleibt unveraendert
;    d4: nummer der tuer im an_doors_flag
;    d2: an_doors_flag
; d0/d1: benutzt

		move.w	door_status(a1),d0
		btst	#1,d0
		bne.s	anim_open_door
		btst	#2,d0
		bne.s	anim_close_door
		btst	#3,d0
		bne	anim_wait_door

		rts

;---

anim_open_door
		bset	#0,d0
		moveq	#0,d1
		move.b	door_line+11(a1),d1	; h1
		add.w	vbl_time,d1
		cmp.w	door_h2(a1),d1		; ende erreicht ?
		blt.s	anim_open_close_no

	; tuer ist jetzt ganz geoeffnet worden ...
	; zugehoeriges sample abspielen ...

		movem.l	d0-a6,-(sp)
                movem.l door_pts(A1),D0-D1
                moveq   #snd_door_rastet,D2
                bsr     init_sam_dist
		movem.l	(sp)+,d0-a6


		move.w	door_h2(a1),d1
		bclr	#1,d0			; statusbit "oeffnen" loeschen
		tst.w	door_auto_clo(a1)
		bne.s	anim_set_otime_door

		bclr	d4,d2
		bra.s	anim_open_close_no

anim_set_otime_door

		bset	#3,d0
		move.w	door_otime(a1),door_count(a1)
		bra.s	anim_open_close_no

;---

anim_close_door
		tst.w	door_under(a1)
		beq.s	anim_can_close

		moveq	#0,d1
		move.b	door_line+11(a1),d1
		subi.w	#player_pix_hgt/2,d1
		cmp.w	door_h1(a1),d1
		blt.s	anim_can_close

		move.w	#%10,door_status(a1)
		rts

anim_can_close
		bclr	#0,d0
		moveq	#0,d1
		move.b	door_line+11(a1),d1
		sub.w	vbl_time,d1
		cmp.w	door_h1(a1),d1
		bgt.s	anim_open_close_no

		move.w	door_h1(a1),d1
		bclr	#2,d0
		bclr	d4,d2

anim_open_close_no

                move.b  D1,door_line+11(A1)
                move.b  D1,door_line+11+20(A1)
                move.b  D1,door_line+11+40(A1)
                move.b  D1,door_line+11+60(A1)
                move.w  D0,door_status(A1)

                rts

;----

anim_wait_door:
                move.w  door_count(A1),D1
                sub.w   vbl_time,D1
                bmi.s   anim_wait_end

                move.w  D1,door_count(A1)
                rts

anim_wait_end:
                move.w  #%0000000000000101,door_status(A1)

		tst.w	door_under(a1)
		beq.s	awe_can_close

		; tuer soll geschlossen werden, spieler
		; ist aber darunter. also richtiges sample abspielen ...

                move.w  D2,-(SP)
                movem.l door_pts(A1),D0-D1
                moveq   #snd_door_rastet,D2
                bsr     init_sam_dist
                move.w  (SP)+,D2

		rts

awe_can_close
                move.w  D2,-(SP)
                movem.l door_pts(A1),D0-D1
                moveq   #snd_door_close,D2
                bsr     init_sam_dist
                move.w  (SP)+,D2

                rts


;**************************************
;* animate_lifts
;**************************************

; rewritten 29/03/97, 8:30

animate_lifts
		move.w	an_lifts_flag,d2
		beq.s	al_out

		lea	an_lifts_ptr,a0
		moveq	#anim_lifts_max-1,d3
		moveq	#0,d4

anim_lifts_loop
		btst	d4,d2
		beq.s	anim_no_lift

		movea.l	(a0,d4.w*4),a1
		bsr.s	anim_one_lift

anim_no_lift
		addq.w	#1,d4
		dbra	d3,anim_lifts_loop

		move.w	d2,an_lifts_flag

al_out
		rts

;---------------

anim_one_lift

;*** animiert einen einzelnen lift

;*  a1: zeiger auf einen lift, bleibt unveraendert
;*  d4: nummer der tuer im an_lifts_flag
;*  d2: an_lifts_flag
;*  d0-d1/d5-d6: benutzt

		move.w	lift_status(a1),d0
		btst	#1,d0
		bne.s	anim_open_lift
		btst	#2,d0
		bne.s	anim_close_lift
		btst	#3,d0
		bne	anim_wait_lift

		rts

;----

anim_open_lift

		bset	#0,d0			; flag fuer bewegung setzen ...

		moveq	#0,d1
		move.b	lift_line+15(a1),d1	; aktuelle h2
		move.b	lift_line+19(a1),d5	; aktuelles yoffi

		move.w	vbl_time,d6
		add.w	d6,d1			; h2 angleichen (h2 ist modulo 2 !!!)
		sub.b	d6,d5
		sub.b	d6,d5			; yoffi angleichen (yoffi ist modulo 1 !!!)

		cmp.w	lift_h2(a1),d1		; ende erreicht ???
		blt.s	anim_l_open_close_no

	; der lift hat seine obere position erreicht ...

		move.w	lift_t1(a1),d5		; original yoffi holen

		move.w	lift_h2(a1),d1
		bclr	#1,d0			; statusbit "oeffnen" loeschen
		tst.w	lift_otime(a1)
		bne.s	anim_l_set_otime_door
		bclr	d4,d2
		bra.s	anim_l_open_close_no
anim_l_set_otime_door
		bset	#3,d0
		move.w	lift_otime(a1),lift_count(a1)
		bra.s	anim_l_open_close_no

;---

anim_close_lift

		bclr	#0,d0
		moveq	#0,d1
		move.b	lift_line+15(a1),d1
		move.b	lift_line+19(a1),d5

		move.w	vbl_time,d6
		sub.w	d6,d1
		add.b	d6,d5
		add.b	d6,d5

		cmp.w	lift_h1(a1),d1
		bgt.s	anim_l_open_close_no

	; der lift hat wieder seine untere position erreicht ...

		move.w	lift_h2(a1),d5
		sub.w	lift_h1(a1),d5
		add.w	d5,d5
		add.w	lift_t1(a1),d5

		move.w	lift_h1(a1),d1
		bclr	#2,d0
		bclr	d4,d2			; flag loeschen ...


anim_l_open_close_no

	; d0 = lift_status
	; d1 = h2
	; d5 = yoffi

		move.w	d0,lift_status(a1)
		move.b	d1,lift_line+15(a1)
		move.b	d1,lift_line+15+20(a1)
		move.b	d1,lift_line+15+40(a1)
		move.b	d1,lift_line+15+60(a1)
		move.b	d5,lift_line+19(a1)
		move.b	d5,lift_line+19+20(a1)
		move.b	d5,lift_line+19+40(a1)
		move.b	d5,lift_line+19+60(a1)

	; jetzt die hoehe des zugehoerigen sector_fields anpassen ...

		lsl.w	#2,d1
		addi.w	#player_pix_hgt*2,d1
		movea.l	lift_sec_ptr(a1),a1
;		neg.l	d1
		move.w	d1,sf_sh(a1)

		rts

;---

anim_wait_lift
		move.w	lift_count(a1),d1
		sub.w	vbl_time,d1
		bmi.s	anim_l_wait_end

		move.w	d1,lift_count(a1)

		rts

anim_l_wait_end

	; lift soll wieder heruntergefahren werden ...

		move.w	#%101,lift_status(a1)

		move.w	d2,-(sp)
		movem.l	lift_pts(a1),d0-d1
		moveq	#snd_lift_close,d2
		bsr	init_sam_dist
		move.w	(sp)+,d2

		rts

