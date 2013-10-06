
; liest die episoden- und levelinformationen
; (anzahl, filename) aus der datei "data\episode.dat"
; und speichert die zugehoerigen informationen ab

; die datei episode.dat hat folgendes format: ASCII, nur eine zeile
; EL<file1>X<file2>X...XL<file1>X<file2>X...
; E anzahl episoden (0-9)
; L anzahl level (0-9)
; <file1> dateinamen
; X trennzeichen fuer filenamen

episode_read

	; lade die datei "data\episode.dat" in
	; den speicherbereich der farbtabelle

		move.l	#er_file,file_name_ptr
		move.l	#5000,file_size
		move.l	#truecolor_tab,file_buf_ptr
		jsr	load_file

	; jetzt dieses file parsen ...

		lea	level_files,a5
		lea	truecolor_tab,a6
		move.b	(a6)+,d0
		subi.b	#$31,d0
		ext.w	d0
		move.w	d0,lf_nb_episode(a5)		; anzahl episoden eintragen
		lea	lf_episode_ptr(a5),a5

	; das startmenu korrigieren ...

		; pointer fuer mns_back korrigieren ...

		lea	mns_new_routs,a4
		move.l	#mns_back,4(a4,d0.w*4)

		; anzahl eintraege korrigieren ...

		move.w	d0,d1
		addq.w	#2,d1
		move.w	d1,er_modify_1
		move.w	d1,er_modify_2

		; menueposition (bildschirm) in y korrigieren ...

		moveq	#7,d1
		sub.w	d0,d1
		mulu	#640*8,d1
		move.l	d1,er_modify_1-4
		move.l	d1,er_modify_2-4

	; ... startmenu korrigiert

		lea	mns_new_txt,a0

er_episode_loop

	; jetzt die bezeichnung der episode ins startmenu uebernehmen

erlb_loop	move.b	(a6)+,d2
		cmpi.b	#"%",d2
		beq.s	erlb_found
		move.b	d2,(a0)+
		bra.s	erlb_loop
erlb_found	move.b	#13,(a0)+

	; anzahl level dieser episode herausfinden ...

		movea.l	(a5)+,a4
		move.b	(a6)+,d1
		subi.b	#$31,d1
		ext.w	d1
		move.w	d1,lf_nb_level(a4)
		lea	lf_level_ptr(a4),a4


er_level_loop
		movea.l	(a4)+,a3

erll_loop	move.b	(a6)+,d2
		cmpi.b	#"%",d2
		beq.s	er_fe_found
		move.b	d2,(a3)+
		clr.b	(a3)
		bra.s	erll_loop
er_fe_found		
		dbra	d1,er_level_loop

		dbra	d0,er_episode_loop

	; und schliesslich noch das startmenue beenden ...

		lea	er_startmenu(pc),a1
erms_loop	move.b	(a1)+,d0
		move.b	d0,(a0)+
		bne.s	erms_loop

	; evtl. noch eine kleinigkeit zum debuggen, aber
	; ansonsten raus ...

		ifeq	final
		move.l	#level_files,file_buf_ptr
		move.l	#10000,file_size
		move.l	#er_debug_file,file_name_ptr
		jsr	save_file
		endc
		
		rts

;---------------

er_file		dc.b	"data\episode.dat",0
er_startmenu	dc.b	"BACK TO MAIN",0
		even

		ifeq 	final
er_debug_file	dc.b	"epidebug.hex",0
		even
		endc




