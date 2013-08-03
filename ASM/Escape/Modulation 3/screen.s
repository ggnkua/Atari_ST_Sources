export save_old_res
export set_all_vid
export set_scr_adr
export set_scp_res


;KOPIERT VIDEOREGISTERINHALTE IN EINEN ANGEGEBENEN SPEICHERBEREICH
save_old_res:
	movem.l	d0/a0-a2,-(sp)
	;a0:	Zielbuffer
	lea     regtabl2,A2
	moveq   #(regtabl2_e-regtabl2)/2-1,D0
save_all5a:     
	movea.w (A2)+,A1        ;sonstige Register zurÅck
	move.w  (A1),(A0)+
	dbf    D0,save_all5a
	movem.l	(sp)+,d0/a0-a2
rts



;SETZT VIDEOREGISTER AUF ORGINALWERTE (->SAVE_OLD_RES)
set_all_vid:
	movem.l	d0/a0-a2,-(sp)
	lea     regtabl2,A2
	moveq   #(regtabl2_e-regtabl2)/2-1-4,D0
reset_all5a:    
	movea.w (A2)+,A1        ;sonstige Register zurÅck
	move.w  (A0)+,(A1)
	dbra    D0,reset_all5a

	cmpi.w  #$50,$FFFF8282.w ;STE-Komp. Modus?
	blt.s   ste_comp_mod1a
	addq.w  #2,A0           ;$8260 Åberspringen
	move.w  (A0)+,$FFFF8266.w
	bra.s   no_video_ret1a
ste_comp_mod1a:
	move.w  2(A0),$FFFF8266.w
	move.w  (A0)+,$FFFF8260.w ;STE-Komp. Modus einstellen
	addq.w  #2,A0
no_video_ret1a:
	move.w  (A0)+,$FFFF8210.w
	move.w  (A0)+,$FFFF82C2.w
set_allvid_end:
	movem.l	(sp)+,d0/a0-a2
rts


;SETZT HARDWAREMéSSIG NEUE VIDEOADRESSE
set_scr_adr:
	move.l	d0,-(sp)
	;a0:	neue Screenadresse
	clr.l	d0

	;Hi-Byte
	move.l	a0, d0
	and.l	#%00000000111111110000000000000000, d0
	lsr.l	#8, d0
	lsr.l	#8, d0
	move.b	d0, $FFFF8201			;Videohardwareregister
	
	;Mid-Byte
	move.l	a0, d0
	and.l	#%00000000000000001111111100000000, d0
	lsr.l	#8, d0
	move.b	d0, $FFFF8203			;Videohardwareregister
	
	;Low-Byte
	move.l	a0, d0
	and.l	#%00000000000000000000000011111111, d0
	move.b	d0, $FFFF820D			;Videohardwareregister
	move.l	(sp)+,d0
rts


;SETZT VIDEOREGISTER AUF DIE WERTE EINER SCP-SEQUENZ
set_scp_res:
	move.l	a0,-(sp)
	;a0.l:	Zeiger auf eine mit Screens Pain erzeugte SCP-Sequenz.
	lea     122(A0),A0
	move.l  (A0)+,$FFFF8282.w
	move.l  (A0)+,$FFFF8286.w
	move.l  (A0)+,$FFFF828A.w
	move.l  (A0)+,$FFFF82A2.w
	move.l  (A0)+,$FFFF82A6.w
	move.l  (A0)+,$FFFF82AA.w
	move.w  (A0)+,$FFFF820A.w
	move.w  (A0)+,$FFFF82C0.w
	move.w  (A0)+,$FFFF8266.w
	move.w  (A0)+,$FFFF8266.w
	move.w  (A0)+,$FFFF82C2.w
	move.w  (A0)+,$FFFF8210.w
	movea.l	(sp)+,a0
rts


regtabl2:
                DC.W $820A,$8282,$8284,$8286,$8288,$828A
                DC.W $828C,$828E,$8290,$82A2,$82A4,$82A6,$82A8,$82AA
                DC.W $82AC,$82C0,$8260,$8266,$8210,$82C2
;letzte 4 Registerwerte in der Reihenfolge NICHT Ñndern!
regtabl2_e:

