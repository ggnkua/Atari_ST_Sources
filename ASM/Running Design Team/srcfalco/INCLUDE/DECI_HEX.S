;**************************************

; a0: pointer auf ASCII-dezimalzahl, ende mit $00
; a2: screenadresse 1
; a3: screenadresse 2
; d1: farbe

paint_deci:
		clr.w	pdeci_flag
paint_deci_loop:
		moveq	#0,d0
                move.b  (A0)+,D0
                beq.s   paint_deci_out

                subi.b  #"0",D0
                bpl.s   pd_its_a_zahl

		tst.w	pdeci_flag
		beq.s	pd_no_number	
                moveq   #0,D0
		bra.s	pd_go_on
pd_its_a_zahl:
		move.w	#1,pdeci_flag
pd_go_on:
                move.l  A0,-(SP)

		cmpi.w	#640,true_offi+2
		bne	pdgo_no640
		lea	pdeci_routs,a0
		bra.s	pdgo_go_on
pdgo_no640	cmpi.w	#512,true_offi+2
		bne	pdgo_no512
		lea	pdeci512_routs,a0
		bra.s	pdgo_go_on
pdgo_no512	lea	pdeci_routs,a0
          
pdgo_go_on
                movea.l 0(A0,D0.w*4),A0
                bsr.s   pdeci_clear
                jsr     (A0)
                exg     A2,A3
                bsr.s   pdeci_clear
                jsr     (A0)
                exg     A2,A3
pdgo_no_pnt
                movea.l (SP)+,A0
pd_no_number
                adda.w  #8,A2
                adda.w  #8,A3

                bra.s   paint_deci_loop

paint_deci_out:
                rts

;---

pdeci_flag:	dc.w	0

;---

pdeci_clear:
		cmpi.w	#640,true_offi+2
		beq.s	pdc_640
		cmpi.w	#512,true_offi+2
		beq.s	pdc_512
	
		rts

pdc_640
                clr.l   (A2)
                clr.w   4(A2)
                clr.w   640(A2)
                clr.w   644(A2)
                clr.l   1280(A2)
                clr.w   1284(A2)
                clr.w   1920(A2)
                clr.w   1924(A2)
                clr.l   2560(A2)
                clr.w   2564(A2)

                rts

pdc_512
                clr.l   (A2)
                clr.w   4(A2)
                clr.w   512(A2)
                clr.w   516(A2)
                clr.l   1024(A2)
                clr.w   1028(A2)
                clr.w   1536(A2)
                clr.w   1540(A2)
                clr.l   2048(A2)
                clr.w   2052(A2)

                rts

;---

pdeci_0:
                move.w  D1,(A2)
                move.w  D1,2(A2)
                move.w  D1,4(A2)
                move.w  D1,640(A2)
                move.w  D1,644(A2)
                move.w  D1,1280(A2)
                move.w  D1,1284(A2)
                move.w  D1,1920(A2)
                move.w  D1,1924(A2)
                move.w  D1,2560(A2)
                move.w  D1,2562(A2)
                move.w  D1,2564(A2)

                rts

;---

pdeci_1:
                move.w  D1,4(A2)
                move.w  D1,644(A2)
                move.w  D1,1284(A2)
                move.w  D1,1924(A2)
                move.w  D1,2564(A2)

                rts

;---

pdeci_2:
                move.w  D1,(A2)
                move.w  D1,2(A2)
                move.w  D1,4(A2)
                move.w  D1,644(A2)
                move.w  D1,1280(A2)
                move.w  D1,1282(A2)
                move.w  D1,1284(A2)
                move.w  D1,1920(A2)
                move.w  D1,2560(A2)
                move.w  D1,2562(A2)
                move.w  D1,2564(A2)

                rts

;---

pdeci_3:
                move.w  D1,(A2)
                move.w  D1,2(A2)
                move.w  D1,4(A2)
                move.w  D1,644(A2)
                move.w  D1,1280(A2)
                move.w  D1,1282(A2)
                move.w  D1,1284(A2)
                move.w  D1,1924(A2)
                move.w  D1,2560(A2)
                move.w  D1,2562(A2)
                move.w  D1,2564(A2)

                rts

;---

pdeci_4:
                move.w  D1,(A2)
                move.w  D1,4(A2)
                move.w  D1,640(A2)
                move.w  D1,644(A2)
                move.w  D1,1280(A2)
                move.w  D1,1282(A2)
                move.w  D1,1284(A2)
                move.w  D1,1924(A2)
                move.w  D1,2564(A2)

                rts

;---

pdeci_5:
                move.w  D1,(A2)
                move.w  D1,2(A2)
                move.w  D1,4(A2)
                move.w  D1,640(A2)
                move.w  D1,1280(A2)
                move.w  D1,1282(A2)
                move.w  D1,1284(A2)
                move.w  D1,1924(A2)
                move.w  D1,2560(A2)
                move.w  D1,2562(A2)
                move.w  D1,2564(A2)

                rts

;---

pdeci_6:
                move.w  D1,(A2)
                move.w  D1,2(A2)
                move.w  D1,4(A2)
                move.w  D1,640(A2)
                move.w  D1,1280(A2)
                move.w  D1,1282(A2)
                move.w  D1,1284(A2)
                move.w  D1,1920(A2)
                move.w  D1,1924(A2)
                move.w  D1,2560(A2)
                move.w  D1,2562(A2)
                move.w  D1,2564(A2)

                rts

;---

pdeci_7:
                move.w  D1,(A2)
                move.w  D1,2(A2)
                move.w  D1,4(A2)
                move.w  D1,644(A2)
                move.w  D1,1284(A2)
                move.w  D1,1924(A2)
                move.w  D1,2564(A2)

                rts

;---

pdeci_8:
                move.w  D1,(A2)
                move.w  D1,2(A2)
                move.w  D1,4(A2)
                move.w  D1,640(A2)
                move.w  D1,644(A2)
                move.w  D1,1280(A2)
                move.w  D1,1282(A2)
                move.w  D1,1284(A2)
                move.w  D1,1920(A2)
                move.w  D1,1924(A2)
                move.w  D1,2560(A2)
                move.w  D1,2562(A2)
                move.w  D1,2564(A2)

                rts

;---

pdeci_9:
                move.w  D1,(A2)
                move.w  D1,2(A2)
                move.w  D1,4(A2)
                move.w  D1,640(A2)
                move.w  D1,644(A2)
                move.w  D1,1280(A2)
                move.w  D1,1282(A2)
                move.w  D1,1284(A2)
                move.w  D1,1924(A2)
                move.w  D1,2560(A2)
                move.w  D1,2562(A2)
                move.w  D1,2564(A2)

                rts

;---------------

pdeci512_0:
                move.w	d1,(A2)
		move.w	d1,2(a2)
		move.w	d1,4(a2)
		move.w	d1,512(a2)
		move.w	d1,516(a2)
		move.w	d1,1024(a2)
		move.w	d1,1028(a2)
		move.w	d1,1536(a2)
		move.w	d1,1540(a2)
		move.w	d1,2048(a2)
		move.w	d1,2050(a2)
		move.w	d1,2052(a2)

		rts

;---

pdeci512_1:
		move.w	d1,4(a2)
		move.w	d1,516(a2)
		move.w	d1,1028(a2)
		move.w	d1,1540(a2)
		move.w	d1,2052(a2)

		rts

;---

pdeci512_2:
                move.w	d1,(A2)
		move.w	d1,2(a2)
		move.w	d1,4(a2)
		move.w	d1,516(a2)
		move.w	d1,1024(a2)
		move.w	d1,1026(a2)
		move.w	d1,1028(a2)
		move.w	d1,1536(a2)
		move.w	d1,2048(a2)
		move.w	d1,2050(a2)
		move.w	d1,2052(a2)

		rts

;---

pdeci512_3:
                move.w	d1,(A2)
		move.w	d1,2(a2)
		move.w	d1,4(a2)
		move.w	d1,516(a2)
		move.w	d1,1024(a2)
		move.w	d1,1026(a2)
		move.w	d1,1028(a2)
		move.w	d1,1540(a2)
		move.w	d1,2048(a2)
		move.w	d1,2050(a2)
		move.w	d1,2052(a2)

		rts

;---

pdeci512_4
                move.w	d1,(A2)
		move.w	d1,4(a2)
		move.w	d1,512(a2)
		move.w	d1,516(a2)
		move.w	d1,1024(a2)
		move.w	d1,1026(a2)
		move.w	d1,1028(a2)
		move.w	d1,1540(a2)
		move.w	d1,2052(a2)

		rts

;---

pdeci512_5
                move.w	d1,(A2)
		move.w	d1,2(a2)
		move.w	d1,4(a2)
		move.w	d1,512(a2)
		move.w	d1,1024(a2)
		move.w	d1,1026(a2)
		move.w	d1,1028(a2)
		move.w	d1,1540(a2)
		move.w	d1,2048(a2)
		move.w	d1,2050(a2)
		move.w	d1,2052(a2)

		rts

;---

pdeci512_6
                move.w	d1,(A2)
		move.w	d1,2(a2)
		move.w	d1,4(a2)
		move.w	d1,512(a2)
		move.w	d1,1024(a2)
		move.w	d1,1026(a2)
		move.w	d1,1028(a2)
		move.w	d1,1536(a2)
		move.w	d1,1540(a2)
		move.w	d1,2048(a2)
		move.w	d1,2050(a2)
		move.w	d1,2052(a2)

		rts

;---

pdeci512_7
                move.w	d1,(A2)
		move.w	d1,2(a2)
		move.w	d1,4(a2)
		move.w	d1,516(a2)
		move.w	d1,1028(a2)
		move.w	d1,1540(a2)
		move.w	d1,2052(a2)

		rts

;---

pdeci512_8
                move.w	d1,(A2)
		move.w	d1,2(a2)
		move.w	d1,4(a2)
		move.w	d1,512(a2)
		move.w	d1,516(a2)
		move.w	d1,1024(a2)
		move.w	d1,1026(a2)
		move.w	d1,1028(a2)
		move.w	d1,1536(a2)
		move.w	d1,1540(a2)
		move.w	d1,2048(a2)
		move.w	d1,2050(a2)
		move.w	d1,2052(a2)

		rts

;---

pdeci512_9
                move.w	d1,(A2)
		move.w	d1,2(a2)
		move.w	d1,4(a2)
		move.w	d1,512(a2)
		move.w	d1,516(a2)
		move.w	d1,1024(a2)
		move.w	d1,1026(a2)
		move.w	d1,1028(a2)
		move.w	d1,1540(a2)
		move.w	d1,2048(a2)
		move.w	d1,2050(a2)
		move.w	d1,2052(a2)

		rts

;**************************************

paint_hex:      
                movea.l A2,A0
                lea     80(A2),A0

                move.w  #$FFFF,D1

                lea     phex_routs,A4

paint_hex_loop: move.w  D0,D2
                andi.w  #$000F,D2
                add.w   D2,D2
                add.w   D2,D2
                movea.l 0(A4,D2.w),A5
                movea.l A0,A1
                jsr     (A5)
                lsr.l   #4,D0
                lea     -10(A0),A0

                dbra    D7,paint_hex_loop

                rts

;---------------

clear_number:
                clr.w   2(A1)
                clr.w   4(A1)
                clr.w   640(A1)
                clr.w   646(A1)
                clr.w   1280(A1)
                clr.w   1286(A1)
                clr.w   1922(A1)
                clr.w   1924(A1)
                clr.w   2560(A1)
                clr.w   2566(A1)
                clr.w   3200(A1)
                clr.w   3206(A1)
                clr.w   3842(A1)
                clr.w   3844(A1)
                rts

paint_0:
                move.w  D1,2(A1)
                move.w  D1,4(A1)
                move.w  D1,640(A1)
                move.w  D1,646(A1)
                move.w  D1,1280(A1)
                move.w  D1,1286(A1)
                clr.w   1922(A1)
                clr.w   1924(A1)
                move.w  D1,2560(A1)
                move.w  D1,2566(A1)
                move.w  D1,3200(A1)
                move.w  D1,3206(A1)
                move.w  D1,3842(A1)
                move.w  D1,3844(A1)
                rts

paint_1:
                clr.w   2(A1)
                clr.w   4(A1)
                clr.w   640(A1)
                clr.w   1280(A1)
                clr.w   1922(A1)
                clr.w   1924(A1)
                clr.w   2560(A1)
                clr.w   3200(A1)
                clr.w   3842(A1)
                clr.w   3844(A1)
                move.w  D1,646(A1)
                move.w  D1,1286(A1)
                move.w  D1,2566(A1)
                move.w  D1,3206(A1)
                rts

paint_2:
                clr.w   640(A1)
                clr.w   1280(A1)
                clr.w   2566(A1)
                clr.w   3206(A1)
                move.w  D1,2(A1)
                move.w  D1,4(A1)
                move.w  D1,646(A1)
                move.w  D1,1286(A1)
                move.w  D1,1922(A1)
                move.w  D1,1924(A1)
                move.w  D1,2560(A1)
                move.w  D1,3200(A1)
                move.w  D1,3842(A1)
                move.w  D1,3844(A1)
                rts

paint_3:
                clr.w   640(A1)
                clr.w   1280(A1)
                clr.w   2560(A1)
                clr.w   3200(A1)
                clr.w   3842(A1)
                clr.w   3844(A1)
                move.w  D1,2(A1)
                move.w  D1,4(A1)
                move.w  D1,646(A1)
                move.w  D1,1286(A1)
                move.w  D1,1922(A1)
                move.w  D1,1924(A1)
                move.w  D1,2566(A1)
                move.w  D1,3206(A1)
                move.w  D1,3842(A1)
                move.w  D1,3844(A1)
                rts

paint_4:
                clr.w   2(A1)
                clr.w   4(A1)
                clr.w   2560(A1)
                clr.w   3200(A1)
                clr.w   3842(A1)
                clr.w   3844(A1)
                move.w  D1,640(A1)
                move.w  D1,646(A1)
                move.w  D1,1280(A1)
                move.w  D1,1286(A1)
                move.w  D1,1922(A1)
                move.w  D1,1924(A1)
                move.w  D1,2566(A1)
                move.w  D1,3206(A1)
                rts

paint_5:
                clr.w   646(A1)
                clr.w   1286(A1)
                clr.w   2560(A1)
                clr.w   3200(A1)
                move.w  D1,2(A1)
                move.w  D1,4(A1)
                move.w  D1,640(A1)
                move.w  D1,1280(A1)
                move.w  D1,1922(A1)
                move.w  D1,1924(A1)
                move.w  D1,2566(A1)
                move.w  D1,3206(A1)
                move.w  D1,3842(A1)
                move.w  D1,3844(A1)
                rts

paint_6:
                clr.w   646(A1)
                clr.w   1286(A1)
                move.w  D1,2(A1)
                move.w  D1,4(A1)
                move.w  D1,640(A1)
                move.w  D1,1280(A1)
                move.w  D1,1922(A1)
                move.w  D1,1924(A1)
                move.w  D1,2560(A1)
                move.w  D1,2566(A1)
                move.w  D1,3200(A1)
                move.w  D1,3206(A1)
                move.w  D1,3842(A1)
                move.w  D1,3844(A1)
                rts

paint_7:
                clr.w   2(A1)
                clr.w   4(A1)
                clr.w   640(A1)
                clr.w   1280(A1)
                clr.w   1922(A1)
                clr.w   1924(A1)
                clr.w   2560(A1)
                clr.w   3200(A1)
                clr.w   3842(A1)
                clr.w   3844(A1)
                move.w  D1,2(A1)
                move.w  D1,4(A1)
                move.w  D1,646(A1)
                move.w  D1,1286(A1)
                move.w  D1,2566(A1)
                move.w  D1,3206(A1)
                rts

paint_8:
                move.w  D1,2(A1)
                move.w  D1,4(A1)
                move.w  D1,640(A1)
                move.w  D1,646(A1)
                move.w  D1,1280(A1)
                move.w  D1,1286(A1)
                move.w  D1,1922(A1)
                move.w  D1,1924(A1)
                move.w  D1,2560(A1)
                move.w  D1,2566(A1)
                move.w  D1,3200(A1)
                move.w  D1,3206(A1)
                move.w  D1,3842(A1)
                move.w  D1,3844(A1)
                rts

paint_9:
                clr.w   2560(A1)
                clr.w   3200(A1)
                move.w  D1,2(A1)
                move.w  D1,4(A1)
                move.w  D1,640(A1)
                move.w  D1,646(A1)
                move.w  D1,1280(A1)
                move.w  D1,1286(A1)
                move.w  D1,1922(A1)
                move.w  D1,1924(A1)
                move.w  D1,2566(A1)
                move.w  D1,3206(A1)
                move.w  D1,3842(A1)
                move.w  D1,3844(A1)
                rts

paint_a:
                clr.w   3842(A1)
                clr.w   3844(A1)
                move.w  D1,2(A1)
                move.w  D1,4(A1)
                move.w  D1,640(A1)
                move.w  D1,646(A1)
                move.w  D1,1280(A1)
                move.w  D1,1286(A1)
                move.w  D1,1922(A1)
                move.w  D1,1924(A1)
                move.w  D1,2560(A1)
                move.w  D1,2566(A1)
                move.w  D1,3200(A1)
                move.w  D1,3206(A1)
                rts

paint_b:
                clr.w   2(A1)
                clr.w   4(A1)
                clr.w   646(A1)
                clr.w   1286(A1)
                move.w  D1,640(A1)
                move.w  D1,1280(A1)
                move.w  D1,1922(A1)
                move.w  D1,1924(A1)
                move.w  D1,2560(A1)
                move.w  D1,2566(A1)
                move.w  D1,3200(A1)
                move.w  D1,3206(A1)
                move.w  D1,3842(A1)
                move.w  D1,3844(A1)
                rts

paint_c:
                clr.w   646(A1)
                clr.w   1286(A1)
                clr.w   1922(A1)
                clr.w   1924(A1)
                clr.w   2566(A1)
                clr.w   3206(A1)
                move.w  D1,2(A1)
                move.w  D1,4(A1)
                move.w  D1,640(A1)
                move.w  D1,1280(A1)
                move.w  D1,2560(A1)
                move.w  D1,3200(A1)
                move.w  D1,3842(A1)
                move.w  D1,3844(A1)
                rts

paint_d:
                clr.w   2(A1)
                clr.w   4(A1)
                clr.w   640(A1)
                clr.w   1280(A1)
                move.w  D1,646(A1)
                move.w  D1,1286(A1)
                move.w  D1,1922(A1)
                move.w  D1,1924(A1)
                move.w  D1,2560(A1)
                move.w  D1,2566(A1)
                move.w  D1,3200(A1)
                move.w  D1,3206(A1)
                move.w  D1,3842(A1)
                move.w  D1,3844(A1)
                rts

paint_e:
                clr.w   646(A1)
                clr.w   1286(A1)
                clr.w   2566(A1)
                clr.w   3206(A1)
                move.w  D1,2(A1)
                move.w  D1,4(A1)
                move.w  D1,640(A1)
                move.w  D1,1280(A1)
                move.w  D1,1922(A1)
                move.w  D1,1924(A1)
                move.w  D1,2560(A1)
                move.w  D1,3200(A1)
                move.w  D1,3842(A1)
                move.w  D1,3844(A1)
                rts

paint_f:
                clr.w   646(A1)
                clr.w   1286(A1)
                clr.w   2566(A1)
                clr.w   3206(A1)
                clr.w   3842(A1)
                clr.w   3844(A1)
                move.w  D1,2(A1)
                move.w  D1,4(A1)
                move.w  D1,640(A1)
                move.w  D1,1280(A1)
                move.w  D1,1922(A1)
                move.w  D1,1924(A1)
                move.w  D1,2560(A1)
                move.w  D1,3200(A1)
                rts
