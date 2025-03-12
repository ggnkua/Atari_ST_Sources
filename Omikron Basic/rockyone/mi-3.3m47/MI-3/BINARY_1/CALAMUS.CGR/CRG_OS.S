;rockyone			pour MI-3 MI-9			  10/02/2017
;
;modifier le 17/02/2017
;add tests file size						16.09.2019
;
;				open|save  CGR of Calamus
;				open 	   CRG of Ec_Paint
;op% 0 open
;    1 save
;
;	open		call crg_os( L source, L but, W op%,w size)
;	save		call crg_os( L but, L source, W op%,w 0)
;
;
; + 0 'CALAMUSCRG'
; +10 $03E8			; version
; +12 $0002			; resolution ?
; +14 file size -24
; +18 $0080			; 128 ?
; +20 largeur image
; +24 hauteur image
; +28 $00000050 		; 80 nombre d'octet par ligne ? <> ec_paint
; +32 $0100                     ; 256?				<> ec_paint
; +34 $ffffffff			; ?				<> ec_paint
; +38 longeur du segment des data compress‚ +2 ou 4 for file Ecpaint
; +42 data compress‚ de limage
;--------------------------------------------------------------------------
		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1

		lea.l	header(pc),a5

		tst.w	68(sp)		; save or open ?
		beq.s	open_cgr

;...............................................SAVE CRG..........

;a0       but
;a1 a2    source
;a3	  end_line    source
;a4	  end_source
;a5	  header
;a6	  end_but
;d2 	  byte		
;.....................
		movea.l	a0,a6			; for calulate file size
		adda.l	#42,a0

		lea.l	34(a1),a1		
		lea.l	80(a1),a3		; end of a line source
		lea.l	32000(a1),a4		; eof file source

loop_save:	cmp.l	a1,a4			; eof soure ?
		bls	end_save		; yes

		move.b	(a1)+,d2		; read byte source

same_byte:	cmp.b	(a1),d2
		bne.s	not_equal

		cmp.l	a1,a3			; end of a line ?
		beq.s	end_equal 

     	        addq.b	#1,(a0)			; cpt repeat even byte 
		addq.l	#1,a1
		bra.s	same_byte

end_equal:	movea.l	a3,a1
		lea.l	80(a3),a3

save_equal:	addi.b	#128,(a0)+
		move.b	d2,(a0)+		; byte to repeat
		bra.s	loop_save

not_equal:	tst.b	(a0)
		beq.s	save_literally
		cmp.l	a1,a3
		beq.s	end_equal
		bra.s	save_equal
	

save_literally:	lea.l	1(a0),a2	

loop_literal:	move.b	d2,(a2)+		; copy  byte literraly

		cmp.l	a3,a1			; end of a line ?
		beq.s	end_literal	

		move.b	(a1),d2
		cmp.b	1(a1),d2
		beq.s	save_literal

		addq.l	#1,a1
		addq.b	#1,(a0)			; number of byte literally
		bra.s	loop_literal

end_literal:	movea.l	a3,a1
		lea.l	80(a3),a3

save_literal:	movea.l	a2,a0
		bra.s	loop_save	


;...............................................OPEN CRG..........

open_cgr:	move.w	70(sp),d1		; Size eof the loaded file
		ext.l	d1
		sub.l	#24,d1			; - header size
		move.l	d1,14(a5)

;...................................TEST HEADER.....................
		moveq.l	#-2,d0			;R. error header
		moveq.l	#28/4-1,d1		; test 28 bytes
test_header:	cmpm.l	(a5)+,(a0)+	
		bne.s	end_prg
		dbra.w	d1,test_header

		moveq.l	#0,d0			;R. not error

		lea.l	14(a0),a0		; Skip codes that vary,
;						; and size data compressed
;...................................................................

		move.w	#2,(a1)+		; write resolution
		move.l	#$fff0000,(a1)+		; write colors palette
		lea.l	28(a1),a1
		lea.l	32000(a1),a3

loop_open:	cmp.l	a1,a3			; eof source ?
		blt.s	end_prg		

		moveq.l	#0,d1

		move.b	(a0)+,d1
		cmpi.b	#128,d1
		bmi.s	literally

		subi.b	#128,d1
depack:		move.b	(a0),(a1)+		
		dbra.w	d1,depack

		addq.l	#1,a0
		bra.s	loop_open

literally:	move.b	(a0)+,(a1)+
		dbra.w	d1,literally
		bra.s	loop_open

;..............................................................	

end_save:	move.b	#$ff,(a0)+		; write the end of the 
		move.b	#$ff,(a0)+		; compressed data

		suba.l	a6,a0			; file size	

		lea.l	-24(a0),a1		; size file-24
		move.l	a1,14(a5)		
		lea.l	-44(a0),a1		; size of compressed data+2
		move.l	a1,38(a5)		

		moveq.l	#42/2-1,d1 	        ; Write the 42 bytes of the
write_header:	move.w	(a5)+,(a6)+
		dbra.w	d1,write_header

		move.l	a0,d0			;Return  file size 

;..............................................................					

end_prg:	movem.l (sp)+,d1-d7/a0-a6
		rts

;..............................................................
	
		even
header:		dc.b	'CALAMUSCRG'
		dc.w 	$03e8,$2
		dc.l	$0		; file size
		dc.w	$80
		dc.l	$280,$190,$50
		dc.w	$100
		dc.l	$ffffffff,$0
		even
	
;--------------------------------------------------------------------------
