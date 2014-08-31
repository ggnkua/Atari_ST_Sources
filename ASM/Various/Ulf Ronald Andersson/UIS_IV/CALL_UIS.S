;----------------------------------------------------------------------------
;File name:	CALL_UIS.S			Revision date:	1997.01.09
;----------------------------------------------------------------------------
; QED-ASMPAR 4 0006  $DSDR:Z:111,M:4
;Desert	Drain V1.52   680x0er Disassembler  05.00.1994 22:40:14
;DATEI:	CALL_UIS.ACC   423 Bytes
;TEXT:	  344	$00158
;DATA:	   46	$0002E
;BSS:	 1418  $00058A
;----------------------------------------------------------------------------
	OUTPUT	.ACC
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
;
start:
	lea	contrl(PC),SP
;
	pea	ptsout(PC)	;(B_5FA) = ptsout
	pea	intout(PC)	;(B_5F6) = intout
	pea	ptsin(PC)	;(B_5F2) = ptsin
	pea	intin(PC)	;(B_5EE) = intin
	pea	contrl(PC)	;(B_5EA) = contrl
	pea	addrout(PC)	;(B_5E6) = addrout
	pea	addrin(PC)	;(B_5E2) = addrin
	pea	intout(PC)	;(B_5DE) = intout
	pea	intin(PC)	;(B_5DA) = intin
	pea	global(PC)	;(B_5D6) = global
	pea	contrl(PC)	;(B_5D2) = contrl
	pea	vdipb(PC)	;(vdipb_p) = vdipb
	pea	aespb(PC)	;(aespb_p) = aespb
;
	lea	loc_stktop(PC),SP
	lea	contrl(PC),A0
	move.l	#$A0000,(A0)+	;appl_init
	move.l	#$10000,(A0)+
	move.w	#0,(A0)
	move.l	aespb_p(PC),D1
	move.w	#$C8,D0
	trap	#2		;aes
	lea	ap_id(PC),A0
	move.w	intout(PC),(A0)
;
	lea	contrl(PC),A0
	move.l	#$230001,(A0)+	;menu_register
	move.l	#$10001,(A0)+
	move.w	#0,(A0)
	lea	intin(PC),A0
	move.w	ap_id(PC),(A0)
	lea	addrin(PC),A0
	lea	acc_name(PC),A1
	move.l	A1,(A0)
	move.l	aespb_p(PC),D1
	move.w	#$C8,D0
	trap	#2		;aes
	lea	acc_id(PC),A0
	move.w	intout(PC),(A0)
;
	lea	contrl(PC),A0
	move.l	#$4D0000,(A0)+	;graf_handle
	move.l	#$50000,(A0)+
	move.w	#0,(A0)
	move.l	aespb_p(PC),D1
	move.w	#$C8,D0
	trap	#2		;aes
	movea.l	#vref,A6
	clr.w	done_init_f-vref(A6)
;
acc_loop:
	lea	contrl(PC),A0
	move.l	#$170000,(A0)+		;evnt_mesag
	move.l	#$10001,(A0)+
	move.w	#0,(A0)
	lea	addrin(PC),A0
	lea	mesag_buf-vref(A6),A1
	move.l	A1,(A0)
	move.l	aespb_p(PC),D1
	move.w	#$C8,D0
	trap	#2			;aes
	move.w	intout(PC),D0
	cmpi.w	#40,mesag_buf-vref(A6)	;AC_OPEN ?
	bne.s	acc_loop
	move.w	acc_id(PC),D0
	cmp.w	8+mesag_buf-vref(A6),D0	;correct acc id ?
	bne.s	acc_loop
	tas.b	done_init_f-vref(A6)
	bmi.s	T_126
;
	move.w	#$19,-(SP)
	trap	#1		;gemdos Dgetdrv
	addq.l	#2,SP
	move.l	#'A:\*',file_path_s-vref(A6)
	move.l	#'.*'<<16,4+file_path_s-vref(A6)
	add.b	D0,file_path_s-vref(A6)
	clr.b	file_name_s-vref(A6)
;
T_126:
	lea	contrl(PC),A0
	move.l	#$5A0000,(A0)+	;fsel_input
	move.l	#$20002,(A0)+
	move.w	#0,(A0)
	lea	addrin(PC),A0
	lea	file_path_s-vref(A6),A1
	move.l	A1,(A0)+
	lea	file_name_s-vref(A6),A1
	move.l	A1,(A0)
	move.l	aespb_p(PC),D1
	move.w	#$C8,D0
	trap	#2		;aes
	bra	acc_loop
;
	SECTION	DATA
;
acc_name:
	dc.b	'  Universal IV',$0
	even
global:	dc.b	$0,$0,$0,$0
ap_id:	dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
;
	SECTION	BSS
;
	ds.l	200			 ;=800
loc_stktop:
	ds.w	1			 ;=2
vref:
mesag_buf:	;vref+$00
	ds.w	8
;;;		;vref+$10
	ds.b	4
done_init_f:	;vref+$14
	ds.w	1
file_name_s:	;vref+$16
	ds.b	$1A
file_path_s:	;vref+$30
	ds.b	240
acc_id:	ds.w	1			 ;=2
aespb_p:	ds.l	1
vdipb_p:	ds.l	1	;unused
aespb:	ds.l	6			 ;=24
vdipb:	ds.l	5			 ;=20
contrl:	ds.w	17			 ;=34
intin:	ds.l	10			 ;=40
ptsin:	ds.l	10			 ;=40
intout:	ds.l	10			 ;=40
ptsout:	ds.l	10			 ;=40
addrin:	ds.l	10			 ;=40
addrout:
	ds.l	10			 ;=40
;
	END
;----------------------------------------------------------------------------
;End of file:	CALL_UIS.S
;----------------------------------------------------------------------------
