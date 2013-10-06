; easy_bat: (c) 1997 Tello Guillaume
; fabrication de fichiers BAT

LANG  = 0

	if LANG=0
		output "easy_bat.prg"
	endif
	
	if LANG=1
		output "ebat_eng.prg"
	endif
	
	

; les macros

XBIOS MACRO   ; fn,stack
   move #\1,-(sp)
   trap #14
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

BIOS MACRO    ; fn,stack
   move #\1,-(sp)
   trap #13
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

GEMDOS MACRO    ; fn,stack
   move #\1,-(sp)
   trap #1
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM
   
GEM_AES MACRO
   move.l #\1,d1
   move.l #$c8,d0
   trap #2
   ENDM

GEM_VDI MACRO
   move.l #\1,a0
   move.l a0,d1
   move.l (a0),a0
   move i_handle,12(a0)
   moveq #$73,d0
   trap #2
   ENDM
   
   
   
   text
   
   move.l  4(a7),a5
	move.l a5,basepage
   move.l $18(a5),d0
   add.l $1c(a5),d0
   add.l #$100,d0
   lea _pile,sp
   sub.l a5,d0
   move.l  d0,-(sp)
   move.l  a5,-(sp)
   clr -(sp)
   GEMDOS $4a,12              ; MSHRINK reduces space
   
   GEM_AES appl_init
   move #2,mf_int
   
   cmp #$140,global				; AES version
   bpl.s .ok
   
   move.l #old_fs_cont,fileselect	; uses fsel_input on old machines
   
.ok:   
   GEM_AES graf_mouse			; the busy_bee
   GEM_AES graf_hand
   move intout,aes_handle
   
   XBIOS 4,2						; get rez
	addq #2,d0
	move d0,ow_int             ; getrez+2
	move aes_handle,i_handle			; gets the AES handle
	GEM_VDI open_work          ; opens my virtual workstation
	move ow_cont+12,i_handle	; and saves my handle
	
	move #3,wu_int
	GEM_AES wind_update
	
	GEM_VDI show_mouse
	
	GEM_AES shel_find
	GEM_AES rsrc_load
	tst intout
	beq end_end
	
	lea select_image(pc),a3
	moveq #8,d6
	move.l d6,rg_int
	GEM_AES rsrc_gaddr
	move.l tree(pc),a0
	moveq #4,d6		; to loop
get_free_strings:
	add.w #24,a0	; next string
	move.l 12(a0),(a3)+
	dbf d6,get_free_strings
	
	move work_out+26(pc),d0		; predifined colors
	cmp #16,d0
	bpl.s colors
	move.l tree(pc),a3			; last tree
	clr.l rg_int
	GEM_AES rsrc_gaddr
	move.l tree(pc),a0			; first tree
to_mono:
	move 6(a0),d0					; ob_type
	cmp #21,d0
	bne.s .lb0
	move.l 12(a0),a1				; TEXT tedinfo
	bset #0,18(a1)					; TEXT color = 1
	bra.s .loop
.lb0:
	cmp #20,d0
	bne.s .loop
	move 14(a0),d0				; COLOR word for BOX
	and.w #$FF8F,d0			; pattern index to 0
	btst #0,d0					; 9?
	bne.s .lb1					; yes, keep 0
	bset #4,d0					; else, pattern 1
.lb1:
	move d0,14(a0)
.loop:
	add.w #24,a0
	cmp.l a3,a0
	bmi.s to_mono

colors:
; ***************************** arbre INFO

	jsr display_info
	
; initialisations
debut:
	lea bat_header(PC),a5	; header pointer
	
	lea signature(pc),a0
	bsr add_string_h

; ***************************** arbre type d'image

	moveq #0,d7
	moveq #0,d6
	bsr manage_tree
	moveq #0,d0
	cmp #17,d6
	bne.s .lb0
	move.b #'#',d0
	moveq #7,d6					; same as IMG
.lb0:
	move.b d0,avi_string
	subq #6,d6					; 0 to 4
	move d6,comp
	muls #9,d6
	move.l a5,si_tgac			; pour passer eventuellement tga2 en tgac
	lea comp_data(pc),a0
	add.l d6,a0
	bsr add_string_h
	bsr create_path

; ***************************** arbre dimensions

	bsr reset_size
.lb1:
	moveq #0,d7
	moveq #1,d6
	bsr manage_tree
	cmp #10,d6
	beq.s .lb2
	bsr read_into_image
	bra.s .lb1
.lb2:
	bsr get_sizes	

; ***************************** arbre qualit‚ + fichier sortie

	bsr other_paths	
	bsr set_quality
	clr.b image_name
	moveq #0,d7
	moveq #2,d6
	bsr manage_tree
	cmp #7,d6
	beq .lb3						; not output file, so no quality needed
	lea output_path(pc),a0
	lea image_name(pc),a1
	move.l select_output(pc),a2
	lea full(pc),a3
	bsr selector
	beq .lb3						; cancel or error
	lea out_data(pc),a0
	bsr add_string_h
	move.l a3,a0
	bsr add_string_h
	move.b #13,(a5)+
	move.b #10,(a5)+
	tst comp
	bne .lb3						; no TGA, so no quality
	bsr get_quality
	
.lb3:
; ***************************	arbre temps et sons

	bsr reset_time
.lb4:
	moveq #3,d6
	moveq #0,d7
	bsr manage_tree
	cmp #11,d6					; ok
	beq.s .lb5
	bsr get_sound_file
	bra.s .lb4
.lb5:
	lea key(pc),a1
	tst.b (a1)
	beq.s .lb6					; no key frames
	lea key_data(pc),a0
	bsr add_string_h
	move.l a1,a0
	bsr add_string_h
	move.b #13,(a5)+
	move.b #10,(a5)+
.lb6:
	lea time(pc),a1
	tst.b (a1)
	beq.s .lb7					; no time
	lea time_data(pc),a0	
	bsr add_string_h
	move.l a1,a0
	bsr add_string_h
	move.b #13,(a5)+
	move.b #10,(a5)+
.lb7:
	lea full(pc),a1
	tst.b (a1)
	beq.s .lb8					; no sound file
	lea sound_data(pc),a0	
	bsr add_string_h
	move.l a1,a0
	bsr add_string_h
	move.b #13,(a5)+
	move.b #10,(a5)+	
.lb8:		

; ***************************** arbre data

	lea bat_data(pc),a6		; data pointer
	clr.l sample_num			; number of frames
	bsr reset_data
.lb9:
	clr.b image_name
	clr.b nombre
.lb91:
	moveq #0,d7
	moveq #4,d6
	bsr manage_tree
	cmp #17,d6
	beq.s .lb10					; Fin
	cmp #16,d6
	beq.s .lb11					; valider
	bsr select_start_image
	bra.s .lb91
.lb11:
	bsr treat_group			; updates sample_num
	bra.s .lb9	
.lb10:			

; ***************************** arbre repete

	bsr reset_repeat
	moveq #0,d7
	moveq #7,d6
	bsr manage_tree
	bsr treat_repeat
	
; ***************************** la question du VR

	cmp #2,comp
	bpl.s .lb12		; pas un MOV!!!
	bsr reset_vr
	moveq #0,d7
	moveq #9,d6
	bsr manage_tree
	bsr treat_vr

; ***************************** ajoute ligne 'data' en fin de header

.lb12:
	lea data_data(pc),a0
	bsr add_string_h

; ***************************** fin finale

	lea stop_data(pc),a0
	bsr add_string_d
	moveq #5,d6
	moveq #0,d7
	bsr manage_tree
	cmp #10,d6
	beq end_end				; quit
	cmp #9,d6
	beq debut				; cancel + redo
	
	bsr save_bat
	
; ***************************** FIN

	bra end_end

	; upon entry:
	; d7=0 -> draw + form_do + clear
	; d7=1 -> draw
	; d7=-1 -> clear
	; d6= long word containing the index of the tree (0,1,2,3)
	
manage_tree:
	tst d7
	bmi .clear				; if <0, just frees the screen
	move.l d6,rg_int		; the index of the tree
	GEM_AES rsrc_gaddr	; the address of the tree into 'tree'
	GEM_AES form_center	; the coordinates
	clr rect_dial			; reserves screen
	GEM_AES form_dial2
	move.l #7,rect_draw	; 0.w and 7.w
	GEM_AES objc_draw
	tst d7
	bne .out					; if non zero, just draw
	clr mf_int
	GEM_AES graf_mouse
	GEM_VDI show_mouse
	GEM_AES form_do		; else, dialog
	move intout,d6
	and #$7fff,d6			; the exit object
	move.l tree,a0
	move d6,d0
	muls #24,d0
	bclr #0,11(a0,d0.w)	; resets the 'selected' bit of the exit button
	GEM_VDI hide_mouse
.clear:
	move #3,rect_dial
	GEM_AES form_dial2
.out:
	rts
	
display_info:
	clr mf_int
	GEM_AES graf_mouse
	GEM_VDI show_mouse
	moveq #1,d7
	moveq #6,d6
	bsr manage_tree
	move #$101,eb_int+4
	GEM_AES evnt_button
	moveq #-1,d7
	moveq #6,d6
	bsr manage_tree
	clr eb_int+4
	GEM_AES evnt_button
	GEM_VDI hide_mouse
	rts

save_bat:
	lea bat_ext(pc),a0
	lea image_path(pc),a2
	lea sound_path(pc),a3
	move.l a3,a4		; last '\'
.copy_path:
	move.b (a2)+,d0
	beq.s .copy_name
	cmp.b #'\',d0
	bne.s .no_slash
	lea 1(a3),a4
.no_slash:
	move.b d0,(a3)+
	bra.s .copy_path
.copy_name:
	move.b (a0)+,(a4)+
	bne.s .copy_name
	lea sound_path(pc),a0
	lea image_name(pc),a1
	clr.b (a1)
	move.l select_bat(pc),a2
	lea full(pc),a3
	bsr selector
	beq end_end
	clr -(sp)
	pea (a3)
	GEMDOS 60,8			; fcreate
	move d0,d7
	bmi end_end
	lea bat_header(pc),a0
	pea (a0)
	sub.l a0,a5
	move.l a5,-(sp)
	move d7,-(sp)		
	GEMDOS 64,12		; fwrite
	cmp.l a5,d0
	bne.s .close
	lea bat_data(pc),a0
	pea (a0)
	sub.l a0,a6
	move.l a6,-(sp)
	move d7,-(sp)
	GEMDOS 64,12
.close:
	move d7,-(sp)
	GEMDOS 62,4
	rts

reset_vr:
	moveq #9,d6
	move.l d6,rg_int
	GEM_AES rsrc_gaddr
	move.l tree(pc),a0
	moveq #5,d0
.lb0:
	move d0,d1
	muls #24,d1
	move.l 12(a0,d1.l),a2
	move.l (a2),a2
	clr.b (a2)
	addq #1,d0
	cmp #9,d0
	bne.s .lb0
	moveq #14,d0
	muls #24,d0
	move.l 12(a0,d0.l),a2
	move.l (a2),a2
	move.b #'1',(a2)+
	clr.b (a2)
	moveq #11,d0
	muls #24,d0
	bclr #0,11(a0,d0.l)
	rts
	
treat_vr:
	cmp #12,d6
	beq.s .ok
	rts				; no VR wanted
.ok:
	lea vr_data(pc),a0
	bsr add_string_h
	moveq #9,d6
	move.l d6,rg_int
	GEM_AES rsrc_gaddr
	move.l tree(pc),a2
	moveq #5,d0
.lb0:
	move d0,d1
	muls #24,d1
	move.l 12(a2,d1.l),a0
	move.l (a0),a0
	bsr add_string_h
	move.b #',',(a5)+
	addq #1,d0
	cmp #9,d0
	bne.s .lb0
	moveq #14,d1
	muls #24,d1
	move.l 12(a2,d1.l),a0
	move.l (a0),a0
	bsr add_string_h
	move.b #',',(a5)+
	moveq #11,d0
	muls #24,d0
	moveq #'0',d1
	btst #0,11(a2,d0.l)	
	beq.s .lb1
	moveq #'1',d1
.lb1:
	move.b d1,(a5)+
	rts

reset_repeat:
	moveq #7,d6
	move.l d6,rg_int
	GEM_AES rsrc_gaddr
	move.l tree(pc),a0
	moveq #8,d0
	muls #24,d0
	add.l d0,a0
	move.l 12(a0),a2
	lea nombre(pc),a1
	move.l a1,(a2)
	clr.b (a1)
	rts
	
treat_repeat:
	lea nombre(pc),a0
	move comp,d6
	cmp #2,d6
	beq.s .gif
	bsr str_to_int
	cmp #2,d0
	bmi.s .frames
	move.l sample_num,d1
	muls d0,d1				; global repeat
	move.l d1,sample_num
	bsr add_frames_data
	lea rep_data(pc),a0
	bsr add_string_h
	lea nombre(PC),a0
	bsr add_string_h
	move.b #13,(a5)+
	move.b #10,(a5)+	
	lea end_data(pc),a0
	bsr add_string_d
	rts
.gif:
	tst.b (a0)
	beq.s .frames
	move.l a0,a1
	lea rgif_data(pc),a0
	bsr add_string_h
	move.l a1,a0
	bsr add_string_h
	move.b #13,(a5)+
	move.b #10,(a5)+
.frames:
	bsr add_frames_data
	rts

add_frames_data:
	lea frame_data(pc),a0
	bsr add_string_h
	move.l sample_num,d0
	move.l a5,a0
	bsr int_to_str
	lea -1(a0),a5
	rts
	
select_start_image:
	lea image_path(pc),a0
	lea image_name(pc),a1
	move.l select_one(pc),a2
	lea full(pc),a3
	bsr selector
	rts	

treat_group:
	moveq #4,d6
	move.l d6,rg_int
	GEM_AES rsrc_gaddr
	move.l tree(pc),a1
	moveq #10,d0
	muls #24,d0
	add.l d0,a1			; object get palette
	btst #0,11(a1)		; selected?
	beq.s .no_pal
	lea getp_data(pc),a0
	bsr add_string_d
.no_pal:
	add.w #24,a1		; keyf
	btst #0,11(a1)
	beq.s .no_key
	lea keyf_data(pc),a0
	bsr add_string_d
.no_key:
	lea image_name(pc),a0
	tst.b (a0)
	beq.s .no_file
	addq.l #1,sample_num
	lea image_path(pc),a2
	lea full(pc),a3
	move.l a3,a4		; last '\'
.copy_path:
	move.b (a2)+,d0
	beq.s .copy_name
	cmp.b #'\',d0
	bne.s .no_slash
	lea 1(a3),a4
.no_slash:
	move.b d0,(a3)+
	bra.s .copy_path
.copy_name:
	move.b (a0)+,(a4)+
	bne.s .copy_name
	move.b #13,-1(a4)
	move.b #10,(a4)+
	clr.b (a4)
	lea full(pc),a0
	bsr add_string_d
.no_file:
	add.w #48,a1		; incr
	lea nombre(pc),a0
	bsr str_to_int	
	add.l d0,sample_num
	tst d0
	beq.s .no_command
	cmp #1,d0
	beq.s .no_rep
	lea rep_data(pc),a0
	bsr add_string_d
	lea nombre(pc),a0
	bsr add_string_d
	move.b #13,(a6)+
	move.b #10,(a6)+
.no_rep:
	bchg #0,11(a1)
	beq.s .no_incr
	lea incr_data(pc),a0
.no_incr:
	add.w #24,a1
	bchg #0,11(a1)
	beq.s .no_decr
	lea decr_data(pc),a0
.no_decr:
	bsr add_string_d
	cmp #1,d0
	beq.s .no_command
	lea end_data(pc),a0
	bsr add_string_d
.no_command:
	rts

str_to_int:
	moveq #0,d0
	moveq #0,d1
.lb0:
	move.b (a0)+,d1	; one more digit
	beq.s .end
	sub.b #'0',d1
	muls #10,d0
	add.l d1,d0
	bra.s .lb0
.end:
	rts

get_sound_file:
	lea sound_path(pc),a0
.lb0:
	tst.b (a0)+
	bne.s .lb0
	subq.l #1,a0
	lea sound_ext(pc),a1
	cmp #9,d6
	beq.s .lb1
	addq.l #6,a1
.lb1:
	move.b (a1)+,(a0)+
	bne.s .lb1
	lea sound_path(pc),a0
	lea image_name(pc),a1
	clr.b (a1)
	move.l select_sound(pc),a2
	lea full(pc),a3
	bsr selector
	beq.s .lb2			; cancel/error
   rts
.lb2:
	clr.b (a3)		
	rts
	
reset_data:
	moveq #4,d6
	move.l d6,rg_int
	GEM_AES rsrc_gaddr
	move.l tree(pc),a0
	moveq #7,d0
	muls #24,d0
	add.l d0,a0			; object 7
	lea image_name(pc),a1
	move.l 12(a0),a2
	move.l a1,(a2)		; text
	add.w #72,a0		; get palette
	move comp,d0
	beq.s .no_pal
	cmp #2,d0
	beq.s .no_pal
	bclr #3,11(a0)		; enabled
	bset #0,11(a0)		; selected for IMG, PI1, NEO
	bra.s .lb0
.no_pal:
	bset #3,11(a0)		; disabled
	bclr #0,11(a0)		; not selected for TGA and GIF
.lb0:
	add.w #24,a0		; KEYF
	cmp #2,d0
	bpl.s .no_key
	bclr #3,11(a0)		; enabled for TGA, IMG
	bra.s .lb1
.no_key:	
	bset #3,11(a0)		; disabled for GIF, PI1, NEO
.lb1:
	bclr #0,11(a0)		; not selected
	add.w #48,a0		; incr
	bset #0,11(a0)		; selected
	add.w #24,a0		; decr
	bclr #0,11(a0)		; not selected
	add.w #24,a0		; number of loops
	move.l 12(a0),a2
	lea nombre(pc),a1
	move.l a1,(a2)
	clr.b (a1)
	rts
	
reset_time:
	lea full(pc),a0
	clr.b (a0)
	moveq #3,d6
	move.l d6,rg_int
	GEM_AES rsrc_gaddr
	move.l tree(pc),a0
	moveq #8,d0
	muls #24,d0
	add.l d0,a0		; object 8
	move.l 12(a0),a1
	lea time(pc),a2
	clr.b (a2)
	move.l a2,(a1)		; text
	add.w #24,a0	; AVR
	move comp,d0
	cmp #2,d0		; gif?
	beq.s .lb0
	bclr #3,11(a0)
	add.w #24,a0
	bclr #3,11(a0)	; buttons enabled
	bra.s .lb1
.lb0:
	bset #3,11(a0)
	add.w #24,a0
	bset #3,11(a0)	; buttons disabled for GIF
.lb1:
	add.w #48,a0	; key frames
	lea key(pc),a2
	move.l 12(a0),a1
	move.l a2,(a1)	; the text
	clr.b (a2)
	bset #3,11(a0)	; for GIF/PI1/NEO, no key frames
	bclr #3,9(a0)	; no editable
	cmp #2,d0
	bpl.s .lb2
	bclr #3,11(a0)	; else, enabled for AVI/MOV
	bset #3,9(a0)
.lb2:
	rts
	
reset_size:
	moveq #1,d6
	move.l d6,rg_int
	GEM_AES rsrc_gaddr
	move.l tree,a0
	moveq #6,d0
	muls #24,d0
	add.l d0,a0			; adress of first object
	lea width(pc),a2
	cmp #3,comp
	bpl.s .lb1
	clr.l (a2)+
	clr.l (a2)+
	clr.l (a2)+
	bra.s .lb2
.lb1:
	move.l #$33323000,(a2)+
	move.l #$32303000,(a2)+
	move.l #$33333030,(a2)+
	move.w #$3000,(a2)
.lb2:
	sub.w #12,a2
	rept 3
	move.l 12(a0),a1
	move.l a2,(a1)
	addq.l #4,a2
	add.w #24,a0
	endr
	lea 11(a0),a0
	cmp #3,comp
	bpl.s .lb3
	bclr #3,(a0)
	rts
.lb3:
	bset #3,(a0)
	rts
	
get_sizes:
	lea size_data(pc),a0
	bsr add_string_h
	move.l a0,a1
	lea width(pc),a0
	bsr add_string_h
	move.l a1,a0
	bsr add_string_h
	move.l a0,a1
	lea height(pc),a0
	bsr add_string_h
	move.l a1,a0
	bsr add_string_h
	move.l a0,a1
	lea buffer(pc),a0
	bsr add_string_h
	move.l a1,a0
	bsr add_string_h
	rts

create_path:
	GEMDOS 25,2				; dgetdrv
	add #'A',d0	   		; ascii drive (A=0, B=1 ...)
	lea image_path(pc),a4
	move.b d0,(a4)+
	move.b #':',(a4)+		; paths stats with X:, X being the drive
	sub #'A'-1,d0			; drive number (A=1, B=2,...)
	move d0,-(sp)
	move.l a4,-(sp)
	GEMDOS 71,8				; degetpath, adds path in (A4)
.lb0:
	tst.b (a4)+
	bne.s .lb0				; looks for the 0 (end of the string)
	subq.l #1,a4			; back on the 0
	move.b #'\',(a4)+
	move.b #'*',(a4)+
	move.b #'.',(a4)+
	move comp,d0
	add d0,d0
	add d0,d0
	lea ext_data(pc),a0
	add.w d0,a0
	rept 4
	move.b (a0)+,(a4)+
	endr
	rts

other_paths:
	lea image_path(pc),a0
	lea sound_path(pc),a1
	lea output_path(pc),a2
	move.l a0,a3				; the last "\"
.lb0:
	move.b (a0)+,d0
	beq.s .lb2
	cmp.b #'\',d0
	bne.s .lb1
	move.l a0,a3
.lb1:
	move.b d0,(a1)+
	move.b d0,(a2)+
	bra.s .lb0
.lb2:
	subq.l #1,a0
	sub.l a3,a0
	sub.l a0,a1
	sub.l a0,a2
	clr.b (a1)				; end of sound path (extension later)
	move.b #'*',(a2)+
	move.b #'.',(a2)+
	lea ext2_data(pc),a0
	move comp,d0
	cmp #1,d0
	bne.s .lb3				; not IMG, skip
	tst.b avi_string
	bne.s .lb3				; IMG and AVI, good
	moveq #0,d0				; else act like MOV
.lb3
	add d0,d0
	add d0,d0
	add.w d0,a0
	rept 4
	move.b (a0)+,(a2)+
	endr
	rts

get_quality:
	moveq #2,d6
	move.l d6,rg_int
	GEM_AES rsrc_gaddr
	move.l tree(pc),a0
	add.w #264,a0			; object 11
	moveq #'1',d0
.lb0:
	btst #0,11(a0)
	bne.s .lb1
	add.w #24,a0
	addq #1,d0
	cmp.b #'5',d0
	bne.s .lb0
.lb1:
	lea qual_data,a0
	move.b d0,2(a0)
	bsr add_string_h
	rts		
	
set_quality:
	moveq #2,d6
	move.l d6,rg_int
	GEM_AES rsrc_gaddr
	move.l tree(pc),a0
	add.w #240,a0			; object 10
	moveq #5,d0
	tst comp
	beq.s .tga
.lb0:
	bset #3,11(a0)			; options unselected, disabled
	bclr #0,11(a0)
	add.w #24,a0
	dbf d0,.lb0
	rts
.tga:
	bclr #3,11(a0)
	bclr #0,11(a0)			; options available, not selected
	add.w #24,a0
	dbf d0,.tga
	bset #0,-13(a0)		; '5' selected
	rts
		
read_into_image:
	lea image_path(pc),a0
	lea image_name(pc),a1
	move.l select_image(pc),a2
	lea full(pc),a3
	bsr selector	
	beq .end
	pea dta(pc)
	GEMDOS 26,6						; fixes my own DTA
	move #1,-(sp)						; normal+read_only files	
	pea (a3)
	GEMDOS 78,8							; search first
	tst d0
	bmi .end
	lea dta(pc),a4
	move.l 26(a4),d6					; the file length
	clr -(sp)
	pea (a3)
	GEMDOS 61,8							; fopen this file
	move d0,d7
	lea sound_path(pc),a4
	pea (a4)
	moveq #16,d0
	move.l d0,-(sp)
	move d7,-(sp)
	GEMDOS 63,12						; reads 16 bytes
	move d7,-(sp)
	GEMDOS 62,4							; fclose
	move comp,d1
	bne.s .pas_tga
	cmp.b #10,2(a4)					; tga10 ou tga2?
	bne.s .pas_tga	
	move.l si_tgac,a0
	move.b #'c',5(a0)					; remplace tga2 en tgac	
.pas_tga:	
	addq.l #6,a4
	cmp #2,d1							; GIF?
	beq.s .lb0
	addq.l #6,a4
.lb0:
	moveq #0,d0
	move (a4)+,d0
	moveq #0,d2
	move (a4),d2
	cmp #1,d1
	beq.s .lb1
	ror #8,d0
	ror #8,d2
.lb1:
	lea width(pc),a0
	bsr int_to_str
	move.l d2,d0
	lea height(pc),a0
	bsr int_to_str
.next_file:
	GEMDOS 79,2							; search next
	tst.l d0
	bmi .no_more
	move.l dta+26(pc),d0
	cmp.l d0,d6
	bpl.s .next_file
	move.l d0,d6
	bra.s .next_file
.no_more:
	move.l d6,d0
	lea buffer(pc),a0
	bsr int_to_str
.end:
	rts		

int_to_str:
	lea intout+100,a1			; as a buffer
	clr.b (a1)					; to end the string
	cmp.l #65536,d0
	bpl.s .lb2
.lb0:
	divu #10,d0
	swap d0
	add.b #'0',d0
	move.b d0,-(a1)			; one char
	clr d0
	swap d0
	tst.l d0
	bne.s .lb0					; not nul, continue!
.lb1:
	move.b (a1)+,(a0)+
	bne.s .lb1
	rts
.lb2:
	move.l #10,_op2
	move.l d0,_op1
	bsr spdiv
	move.l _op2(pc),d0
	add.b #'0',d0
	move.b d0,-(a1)
	move.l _op1(pc),d0
	bne.s .lb2
	bra.s .lb1

_op2: dc.l 0		; divis, returns remainder
_op1: dc.l 0		; divid, returns quotient or mul

spdiv: 
	movem.l d0-d7,-(sp)
	moveq.l #1,d7
   move.l d7,d6
   move.l _op2(pc),d4
   bpl.s .lb1
   neg.l d4
   neg.l d7
.lb1: move.l _op1(pc),d3
   bpl.s .lb2
   neg.l d3
   neg.l d7
   neg.l d6
.lb2: move.l #$80000000,d0
   moveq #0,d1
   moveq #0,d2
.lb3: lsl.l #1,d1
   move.l d0,d5
   and.l d3,d5
   beq.s .lb4
   addq.l #1,d1
.lb4: lsl.l #1,d2
   cmp.l d4,d1
   bmi.s .lb5
   sub.l d4,d1
   addq.l #1,d2
.lb5: lsr.l #1,d0
   bne.s .lb3
   tst.l d7
   bpl.s .lb6
   neg.l d2
.lb6: tst.l d6
   bpl.s .lb7
   neg.l d1
.lb7: 
	move.l d1,_op2
	move.l d2,_op1
	movem.l (sp)+,d0-d7
	rts


; a0: path
; a1: file
; a2: title
; a3: full
; ouput: NE+full (a3 unchanged)
; or EQ.
	
selector:
	movem.l a0-a2,fs_addrin
	GEM_VDI show_mouse
	GEM_AES fileselect
	move.l intout,-(sp)
	GEM_VDI hide_mouse
	move.l (sp)+,d0
	tst.w d0
	beq.s .end
	swap d0
	tst.w d0
	beq.s .end
	move.l fs_addrin(pc),a0
	move.l a3,a1
	move.l a1,a2						; will keep the last '\' position
.lb1:
	move.b (a0)+,d0					; a byte from path...
	beq.s .copy_name					; it's the end of the path
	move.b d0,(a1)+					; ...to full
	cmp.b #'\',d0
	bne.s .lb1
	move.l a1,a2						; if '\', updates A2
	bra.s .lb1
.copy_name:
	move.l fs_addrin+4(pc),a0		; the file name (or the mask!)
.lb2:
	move.b (a0)+,(a2)+				; copies after the last '\'
	bne.s .lb2							; til the end of the string
	moveq #1,d0							; returns NE
.end:
	rts									; or EQ if error
	
end_end:
	GEM_VDI show_mouse				; the mouse is back
	GEM_VDI close_work				; byebye VDI
	
	move #2,wu_int
	GEM_AES wind_update
	
	GEM_AES appl_exit					; a hand-shaking to AES
	GEMDOS 0,2							; a kiss for GEMDOS	

; add a0 string into header, updates A5

add_string_h:
	move.b (a0)+,(a5)+
	bne.s add_string_h
	subq.l #1,a5
	rts
	
add_string_d:
	move.b (a0)+,(a6)+
	bne.s add_string_d
	subq.l #1,a6
	rts
	
	
	data
	
appl_init: dc.l ai_cont,global,dum,appl_id,dum,dum
ai_cont: dc.w 10,0,1,0,0
appl_id: dc.w 0

form_dial: dc.l fd_cont,global,fd_int,dum,dum,dum
fd_cont: dc.w 51,9,0,1,0
fd_int: dc.w 0,0,0,0,0,0,0,640,480	

graf_mouse: dc.l mf_cont,global,mf_int,intout,mouse_def,dum
mf_cont: dc.w 78,1,1,1,0
mf_int: dc.w 0
mouse_def: dc.l 0

graf_hand: dc.l gh_cont,global,dum,intout,dum,dum
gh_cont: dc.w 77,0,5,0,0

wind_update: dc.l wu_cont,global,wu_int,dum,dum,dum
wu_cont: dc.w 107,1,1,0,0

shel_find: dc.l sf_cont,global,dum,dum,rsc_name,dum
sf_cont: dc.w 124,0,1,1,0

show_mouse: dc.l sm_cont,sm_int,dum,dum,dum
sm_cont: dc.w 122,0,0,1,0,0,0,0,0,0,0,0
sm_int: dc.w 0

rsrc_load: dc.l rl_cont,global,dum,intout,rsc_name,dum
rl_cont: dc.w 110,0,1,1,0
rsc_name: dc.l _name

rsrc_gaddr: dc.l rg_cont,global,rg_int,dum,dum,tree
rg_cont: dc.w 112,2,1,0,1

form_center: dc.l fc_cont,global,dum,rect,tree,dum
fc_cont: dc.w 54,0,5,1,0

form_dial2: dc.l fd_cont,global,rect_dial,dum,dum,dum

evnt_button: dc.l eb_cont,global,eb_int,intout,dum,dum
eb_cont: dc.w 21,3,5,0,0
eb_int: dc.w 1,1,0

form_do: dc.l do_cont,global,do_int,intout,tree,dum
do_cont: dc.w 50,1,1,1,0
do_int: dc.w 0			; no edit object

objc_draw: dc.l od_cont,global,rect_draw,dum,tree,dum
od_cont: dc.w 42,6,1,1,0

open_work: dc.l ow_cont,ow_int,dum,work_out,ptsout
ow_cont: dc.w 100,0,0,11,0,0,0,0,0,0,0,0
ow_int: dc.w 2,1,1,1,1,1,1,0,1,0,2

appl_exit: dc.l ae_cont,global,dum,intout,dum,dum
ae_cont: dc.w 19,0,1,0,0

close_work: dc.l cw_cont,dum,dum,dum,dum
cw_cont: dc.w 101,0,0,0,0,0,0,0,0,0,0,0

hide_mouse: dc.l hm_cont,dum,dum,dum,dum
hm_cont: dc.w 123,0,0,0,0,0,0,0,0,0,0,0


fileselect: dc.l fs_cont,global,dum,intout,fs_addrin,dum
fs_cont: dc.w 91,0,2,3,0
old_fs_cont: dc.w 90,0,2,2,0

	if LANG=0
_name: dc.b "EASY_BAT.RSC",0
	endif
	
	if LANG=1
_name: dc.b "EBAT_ENG.RSC",0
	endif
	
	dcb.b 200,0
	
signature: dc.b "M_PLAYER",13,10,0
comp_data: dc.b "c=tga2",13,10,0,"c=ximg",13,10,0,"c=gif8",13,10,0
				dc.b "c=dega",13,10,0,"c=neoc",13,10,0
size_data: dc.b "w=",0,13,10,"h=",0,13,10,"b=",0,13,10,0
ext_data: dc.b "TGA",0,"IMG",0,"GIF",0,"PI1",0,"NEO",0
ext2_data: dc.b "MOV",0,"AVI",0,"GIF",0,"FLM",0,"FLM",0
bat_ext: dc.b "*.BAT",0
out_data: dc.b "o="
avi_string: dc.b 0,0 	; and maybe '#',0
qual_data: dc.b "q=0",13,10,0
key_data: dc.b "k=",0
time_data: dc.b "t=",0
sound_data: dc.b "s=",0
sound_ext: dc.b "*.AVR",0,"*.WAV",0
getp_data: dc.b ".getp",13,10,0
keyf_data: dc.b ".keyf",13,10,0
rep_data: dc.b ".rept ",0
end_data: dc.b ".endr",13,10,0
incr_data: dc.b ".incr",13,10,".disp",13,10,0
decr_data: dc.b ".decr",13,10,".disp",13,10,0
stop_data: dc.b ".stop",0
rgif_data: dc.b "r=",0
frame_data: dc.b "f=",0
data_data: dc.b 13,10,"data",13,10,0
vr_data: dc.b 13,10,"v=",0

	even
		
	bss
i_handle: ds.w 1
aes_handle: ds.w 1
dum: ds.w 10
global: ds.l 100	
intout: ds.w 100
wu_int: ds.w 1

bar_pts: ds.w 2		; do not separate bar_pts and work_out
work_out: ds.w 100

ptsout: ds.w 100
basepage: ds.l 1
tree: ds.l 1
rect_dial: ds.w 3
rect_draw: ds.w 1
rect: ds.w 5
rg_int: ds.w 2
comp: ds.w 1
fs_addrin: ds.l 3


bat_header: ds.b 700	; enough...
bat_data: ds.b 12000 ; enough too...

dta: ds.b 44
output_path: ds.b 200
sound_path: ds.b 200
image_path: ds.b 200
image_name: ds.b 20
full: ds.b 200

nombre: ds.b 4
sample_num: ds.l 1

select_image: ds.l 1	; keep this order
select_output: ds.l 1
select_sound: ds.l 1
select_one: ds.l 1
select_bat: ds.l 1 

width: ds.b 4		; keep this order!!
height: ds.b 4
buffer: ds.b 10
time: ds.b 8
key: ds.b 4

si_tgac: ds.l 1

	ds.l 500
_pile: ds.w 1
	end