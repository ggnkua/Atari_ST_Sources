; Atari ST/e synclock demosystem
; September 3, 2011
;
; sys/falcon.s
;
; Falcon specific video save/set/restore

		section	text

falcon_save_video:

	ifne	show_infos				;
		move.l	#text_falcon_mode,d0		;
		jsr	print				;
	endc						;

		lea	save_falcon_video,a0		;
		move.l	$ffff8200.w,(a0)+		;Vidhm
		move.w	$ffff820c.w,(a0)+		;Vidl
		move.l	$ffff8282.w,(a0)+		;H-regs
		move.l	$ffff8286.w,(a0)+		;
		move.l	$ffff828a.w,(a0)+		;
		move.l	$ffff82a2.w,(a0)+		;V-regs
		move.l	$ffff82a6.w,(a0)+		;
		move.l	$ffff82aa.w,(a0)+		;
		move.w	$ffff82c0.w,(a0)+		;VCO
		move.w	$ffff82c2.w,(a0)+		;C_S
		move.l	$ffff820e.w,(a0)+		;Offset
		move.w	$ffff820a.w,(a0)+		;Sync
		move.b  $ffff8265.w,(a0)+		;P_O
		clr.b   (a0)				;Test of ST(e) or falcon mode
		cmp.w   #$b0,$ffff8282.w		;HHT kleiner $b0?
		sle     (a0)+				;Flag setzen
		move.w	$ffff8266.w,(a0)+		;F_S
		move.w	$ffff8260.w,(a0)+		;ST_s
		rts

falcon_set_video:
		move.w	#$59,-(sp)			;Check RGB/TV/VGA
		trap	#14				;
		addq.l	#2,sp				;

		cmp.w	#1,d0				;1 = RGB
		beq.s	.rgb				;
		cmp.w	#3,d0				;3 = TV
		beq.s	.rgb				;
		bra.s	.vga50				;Otherwise assume VGA

.rgb:		move.l	#$300027,$ffff8282.w		;Falcon 50Hz RGB
		move.l	#$70229,$ffff8286.w		;
		move.l	#$1e002a,$ffff828a.w		;
		move.l	#$2710265,$ffff82a2.w		;
		move.l	#$2f0081,$ffff82a6.w		;
		move.l	#$211026b,$ffff82aa.w		;
		move.w	#$200,$ffff820a.w		;
		move.w	#$185,$ffff82c0.w		;
		clr.w	$ffff8266.w			;
		clr.b	$ffff8260.w			;
		clr.w	$ffff82c2.w			;
		move.w	#$50,$ffff8210.w		;
		rts

.vga50:		move.l	#$170011,$ffff8282.w		;Falcon 50Hz VGA
		move.l	#$2020e,$ffff8286.w		;
		move.l	#$d0012,$ffff828a.w		;
		move.l	#$4eb04d1,$ffff82a2.w		;
		move.l	#$3f00f5,$ffff82a6.w		;
		move.l	#$41504e7,$ffff82aa.w		;
		move.w	#$200,$ffff820a.w		;
		move.w	#$186,$ffff82c0.w		;
		clr.w	$ffff8266.w			;
		clr.b	$ffff8260.w			;
		move.w	#$5,$ffff82c2.w			;
		move.w	#$50,$ffff8210.w		;
		rts

falcon_restore_video:
		clr.w   $ffff8266.w     	        ;Falcon-shift clear
		lea	save_falcon_video,a0		;
		move.l	(a0)+,$ffff8200.w		;Videobase_address:h&m
		move.w	(a0)+,$ffff820c.w		;L
		move.l	(a0)+,$ffff8282.w		;H-Regs
		move.l	(a0)+,$ffff8286.w		;
		move.l	(a0)+,$ffff828a.w		;
		move.l	(a0)+,$ffff82a2.w		;V-Regs
		move.l	(a0)+,$ffff82a6.w		;
		move.l	(a0)+,$ffff82aa.w		;
		move.w	(a0)+,$ffff82c0.w		;VCO
		move.w	(a0)+,$ffff82c2.w		;C_S
		move.l	(a0)+,$ffff820e.w		;Offset
		move.w	(a0)+,$ffff820a.w		;Sync
		move.b  (a0)+,$ffff8265.w		;P_O
		tst.b   (a0)+   			;ST(e) comptaible mode?
	        bne.s   .ok				;
		move.w  (a0),$ffff8266.w		;Falcon-shift
		rts
.ok:		move.w  2(a0),$ffff8260.w		;ST-shift
		lea	save_falcon_video,a0		;
		move.w	32(a0),$ffff82c2.w		;C_S
		move.l	34(a0),$ffff820e.w		;Offset
		rts


		section	bss

save_falcon_video:
		ds.b	46
		section	text


