; Quick Time, AVI, FLI/FLC player
; Original version (graphics only): Dieter Fiebelkorn
; ASM translation + sound: Tello Guillaume

CDEB = 1

	if CDEB=0
VERSION = '2.83'
	else
VERSION = 'EBcd'
	endif

VER_STR macro
	dc.b "2.78"
	endm

	opt P=68000,w+

SUR_A = 0

REG = 1			; 1 for registred versions, 0 for shareware

	if REG=1
		if SUR_A=1
			output "A:\MP_STE.PRG"
		else		
			if CDEB=0
			OUTPUT "F:\ANIM\MP_STE\MP_STE.PRG"
			else
			OUTPUT "F:\ANIM\MP_STE\MPSTE_EB.PRG"
			endif
		endif
	else
		OUTPUT "F:\ANIM\MP_STE\MP_STESW.PRG"
	endif
	

; some useful Macros

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

; seeks into a file
 
SEEK MACRO	; size, mode (0=start, 1=current, 2=end)
	move #\2,-(sp)			; mode
	move mov_h,-(sp)		; handle
	move.l \1,-(sp)		; size (offset)
	move #66,-(sp)			; fseek
	trap #1
	lea 10(sp),sp
	ENDM

; converts an ugly Intel DWORD into a beautiful Motorola Long	
INTEL MACRO ; a data register (long)
	rol #8,\1
	swap \1
	rol #8,\1
	ENDM

; converts an ugly Falcon pixel into a beautiful NOVA one (without byte swap)
NOVA16 MACRO
	ror.l #5,\1
	lsr #1,\1
	rol.l #5,\1
	ENDM			
	
; converts a GGGBBBBB xRRRRRGG into a grey index (0 through 255)
TO_GREY MACRO
	ror #8,\1
	bclr #15,\1
	move.b 0(a1,\1.w),\1
	ENDM

; for unregistered mode only

RPZA	MACRO
	rept 2
	move.b (a2)+,d1
	ror #8,d1
	move.b (a2)+,d1
	bclr #15,d1
	move.b 0(a1,d1.w),(a3)+
	endr
	ENDM
	
GET_ILONG MACRO		; an, dn
	move.b 3(\1),\2
	ror #8,\2
	move.b 2(\1),\2
	swap \2
	move.b 1(\1),\2
	ror #8,\2
	move.b (\1),\2
	addq.l #4,\1
	ENDM
	
GET_LONG MACRO			; an, dn
	move.b (\1)+,\2
	ror #8,\2
	move.b (\1)+,\2
	swap \2
	move.b (\1)+,\2
	ror #8,\2
	move.b (\1)+,\2
	ENDM


splice MACRO
	move.\0 \2,d7
	lsr.\0 #\3,d7
	eor.\0 \1,d7
	and.\0 d0,d7
	eor.\0 d7,\1
	lsl.\0 #\3,d7
	eor.\0 d7,\2
	ENDM

get4on8 MACRO
	move (a1)+,\1
	move.b (a1)+,\1
	swap \1
	addq.l #1,a1
	move (a1)+,\1
	move.b (a1)+,\1
	addq.l #1,a1
	ENDM			
	text
	
	; **************** Several Initialisations **********************

	jmp skip_iv32

IV_SIZE equ 96000		; size when decrunch	
_iv32: 
	if CDEB=0
	INCBIN "IV32TAB.BIN"
	else
	dc.b 5
	endif
	even

skip_iv32:
	move.l a0,d0
	bne.s accessory	
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
   sf acc
   bra.s common
   
menu_reg: dc.l mr_cont,global,appl_id,menu_id,menu_nom,dum
mr_cont: dc.w 35,1,1,1,0
menu_nom: dc.l _menu_nom
menu_id: dc.w 0
_menu_nom: dc.b "  STE Player V"
				dc.l VERSION
				dc.b 0,0
	even
   
accessory:
	lea _pile,sp
	st acc
	
common:
   
	sf rsc
   
   GEM_AES appl_init
   move #2,mf_int
   
   cmp #$140,global				; AES version
   bpl.s .ok
   
   move.l #old_fs_cont,fileselect	; uses fsel_input on old machines
   
.ok:   
   GEM_AES graf_mouse			; the busy_bee
   GEM_AES graf_hand
   move intout,aes_handle
   move intout+8,boxh			; height of one char
   
   GEM_AES shel_find
	GEM_AES rsrc_load
	tst intout
	bne.s .lb1 
	pea no_rsc
	bsr alert
	tst.b acc
	beq end_end
.lb1:
   tst.b acc
   beq no_acc
   
   GEM_AES menu_reg				; the name of the accessory

acc_wait:
	tst.b repondre
	beq.s .lb1
	GEM_AES appl_write
	sf repondre
.lb1:
	GEM_AES evnt_mesag
	lea cvid_fix0,a0
	sf acc_command
	cmp #40,(a0)					; AC_OPEN?
	bne.s .lb0						; no, other message...
	move 8(a0),d0					; menu_id
	cmp menu_id,d0
	bne.s .lb1					; not my accessory
.go:
	move.l #intout,vq_extnd+12
	move #1,ve_int
	bra no_acc					; ok, open!
.lb0:
	cmp #'MP',(a0)
	bne.s .lb1
	tst 10(a0)						; 0: rien renvoyer a l'appelant
	beq.s .rien
	lea mp_buffer,a1
	move 10(a0),(a1)+				; le message voulu
	move 2(a0),mp_id				; l'ID de l'appelant
	move appl_id,(a1)+			; id m_player pour repondre
	clr (a1)+
	st repondre
.rien:
	move.l 6(a0),acc_cmd_adr	; command address?
	beq.s .go						; nothing, just open
	st acc_command					; one command line!
	bra.s .go

evnt_mesag: dc.l em_cont,global,dum,dum,em_add,dum
em_cont: dc.w 23,0,1,1,0
em_add: dc.l cvid_fix0			; the buffer

appl_write: dc.l aw_cont,global,mp_id,dum,aw_addr,dum
aw_cont: dc.w 12,2,1,1,0
mp_id: dc.w -1,16
aw_addr: dc.l mp_buffer

no_acc:
	XBIOS 4,2						; get rez
	addq #2,d0
	move d0,ow_int             ; getrez+2
	move aes_handle,i_handle			; gets the AES handle
	GEM_VDI open_work          ; opens my virtual workstation
	move ow_cont+12,i_handle	; and saves my handle
	
	move #3,wu_int
	GEM_AES wind_update
	
	GEM_VDI show_mouse
	GEM_VDI vsf_interior			; one color
	GEM_VDI vsf_color				; and this color is black
	
	pea cookie						; cookies+ kbshift address
	XBIOS 38,6						; supexec
	
	lea snd_value,a0
	btst #1,3(a0)
	sne (a0)							; $FF if DMA sound
	
	lea mch_value,a0
	cmp.l #$10010,(a0)
	seq (a0)							; $FF if Mega STE (with the cache!)
	
	XBIOS 3,2						; logbase
	move.l d0,physbase			; to act like a TT for FLM (example)
	add.l #32000,d0
	move.l d0,end_of_screen
	XBIOS 4,2						; get rez
	move d0,old_video
	move #-1,mov_h					; a negative handle if no file opened
	
	tst.b acc
	beq.s .lb3
	
	jsr save_menu					; saves the menu_bar if accessory
	
.lb3:	
	move.l #work_out,vq_extnd+12
	clr ve_int

	bra.s not_tc


appl_init: dc.l ai_cont,global,dum,appl_id,dum,dum
ai_cont: dc.w 10,0,1,0,0
appl_id: dc.w 0

   
form_dial: dc.l fd_cont,global,fd_int,dum,dum,dum
fd_cont: dc.w 51,9,0,1,0
fd_int: dc.w 0,0,0,0,0,0,0,640,480	


not_tc:
	tst.b nova
	beq.s .lb8
	dc.w $a000
	cmp #1,(a0)					; monochrome?
	bne.s .lb8					; no!
	cmp #640,-12(a0)			; width=640 (like ST High)
	bne.s .lb8
	sf nova						; else, acts like it is ST HIGH
.lb8:
	bsr save_16					; saves the desktop color registers	

	; ****************** loads the resource file ****************
	
	tst.b rsc
	bne .lb4
	

	moveq #2,d0
	move.l d0,rg_int
	GEM_AES rsrc_gaddr
	move.l tree,a0
	jsr add_version_number
	moveq #4,d0
	move.l d0,rg_int	; menu adr
	GEM_AES rsrc_gaddr
	move.l tree,menu_tree
	moveq #5,d0
	move.l d0,rg_int
	GEM_AES rsrc_gaddr
	move.l tree,a0		; sound selection
	add.w #131,a0		; dma button, ob state
	tst.b snd_value
	bne.s .lb0
	bset #3,(a0)		; else, disables DMA sound
	bclr #0,(a0)		; and clears selected
	beq.s .lb0			; wasn't selected!
	bset #0,24(a0)		; else, selects 'no sound'
.lb0:
	moveq #24,d1
	moveq #-1,d0		; dma
	btst #0,(a0)
	bne.s .lb7
	add d1,a0
	moveq #0,d0			; no sound
	move.l a0,a1
	btst #0,(a0)
	bne.s .lb7
	add d1,a0	
	moveq #1,d0			; mv16
	btst #0,(a0)
	bne.s .lb7
	add d1,a0
	moveq #2,d0			; ST replay 8
	btst #0,(a0)
	bne.s .lb7
	moveq #3,d0			; ST Replay 16
	add d1,a0
	btst #0,(a0)
	bne.s .lb7
	moveq #0,d0			; default, no sound
	bset #0,(a1)		; button selected
.lb7:
	move.b d0,_snd

	; ****************** looks for a command line upon entry ****

.lb3:	
	dc.w $A000
	cmp #1,(a0)
	seq is_mono							; monochrome display!!!
	cmp #4,(a0)
	bpl.s .lb4
	bsr adapt_rsc_colors				; no, change to B&W
.lb4:
	sf command							; the default is NO COMMAND LINE
	tst.b acc
	beq.s .lb5							; no acc, test command line
	tst.b acc_command
	beq normal							; accessory and no command line
	move.l acc_cmd_adr,a5
	bra.s .lb6
	
.lb5:
	move.l basepage,a5
	lea $80(a5),a5						; the command line
	moveq #0,d0
	move.b (a5)+,d0					; the lenght
	beq normal						; if 0, no command line
	clr.b 0(a5,d0.w)

.lb6:	
	lea cmd_dial,a0
	move.l #$ffffff00,(a0)+		; set the default four flags
	clr.w (a0)+						; and the fifth and sixth
	clr.b (a0)						; and 7th
	jsr parse_command_line
	
	lea cmd_coord,a0
	cmp.b #$FF,a0
	bne.s .clear_coord			; no coords (or just one)
	tst.b cmd_dial
	beq.s .keep_coord				; if no dialogs, coords allowed
.clear_coord:
	clr.b (a0)
.keep_coord:
	
	tst.b cmd_dial
	bne verify
	tst.b cmd_inter
	beq verify						; jumps if dial or if no hard interrupt
	jsr install_vectors
	
	bra verify


graf_hand: dc.l gh_cont,global,dum,intout,dum,dum
gh_cont: dc.w 77,0,5,0,0

adapt_rsc_colors:
	moveq #4,d0
	move.l d0,rg_int
	GEM_AES rsrc_gaddr
	move.l tree,d7			; end of objects
	clr.l rg_int
	GEM_AES rsrc_gaddr
	move.l tree,a0			; start of objects
.lb0:
	move 6(a0),d0			; ob type
	lea 14(a0),a1
	cmp #20,d0
	beq.s .box
	cmp #25,d0
	beq.s .box
	cmp #27,d0
	beq.s .box
	cmp #21,d0
	beq.s .ted
	cmp #22,d0
	beq.s .ted
	cmp #29,d0
	beq.s .ted
	cmp #30,d0
	bne.s .next
.ted:
	move.l 12(a0),a1	; tedinfo
	lea 18(a1),a1		; color word
.box:
	move.b #$11,(a1)+	; black for border and text
	and.b #$F0,(a1)	; white for fill
.next:
	lea 24(a0),a0
	cmp.l d7,a0
	bmi.s .lb0
	rts	
		
normal:
	; *********************** the names *************************
	tst.b rsc			; an accesory ran 2 times, no display
	bne.s again			; and no path change
	jsr displ_info
	
	; *********************** prepares the fileselector *********
	
	st rsc	
	GEMDOS 25,2				; dgetdrv
	add #'A',d0	   		; ascii drive (A=0, B=1 ...)
	lea path,a4
	move.b d0,(a4)+
	move.b #':',(a4)+		; paths stats with X:, X being the drive
	sub #'A'-1,d0			; drive number (A=1, B=2,...)
	move d0,-(sp)
	move.l a4,-(sp)
	GEMDOS 71,8				; degetpath, adds path in (A4)
	
lb0:
	tst.b (a4)+
	bne.s lb0				; looks for the 0 (end of the string)
	subq.l #1,a4			; back on the 0
	
	move.b #'\',(a4)+
	move.b #'*',(a4)+
	move.b #'.',(a4)+
	move.b #'*',(a4)+
	clr.b (a4)
	
	lea path,a4
	lea tga_path,a0
.aaa:
	move.b (a4)+,(a0)+
	bne.s .aaa				; copies the path into the tga path

	; ********************* the file selector *******************
	
again:
	clr mf_int
	GEM_AES graf_mouse				; the arrow
	GEM_VDI show_mouse	
	GEM_AES fileselect				; to select a MOV or quit (Abort button)
	move.l intout,-(sp)
	GEM_VDI hide_mouse
	move (sp)+,d0						; 0 if error
	move (sp)+,d1						; 0 if Abort, other if OK
	
	tst d0
	beq end_end							; if error, quits
	
	tst d1
	beq end_end							; if abort, quits
	
	; ******************* builds the full pathname of the movie *********

	move #2,mf_int
	GEM_AES graf_mouse
	bsr redraw
	
	lea path,a0
	lea full,a1							; full will contain path+file
	lea full2,a3
	move.l a1,a2						; will keep the last '\' position

lb1:
	move.b (a0)+,d0					; a byte from path...
	beq.s copy_name					; it's the end of the path
	move.b d0,(a1)+					; ...to full
	move.b d0,(a3)+					; and to full2
	cmp.b #'\',d0
	bne.s lb1
	move.l a1,a2						; if '\', updates A2
	bra.s lb1
	
copy_name:
	sub.l a2,a1
	sub.l a1,a3							; last '\' in full2
	move.l a3,fname_pos
	lea file,a0							; the file name (or the mask!)
lb2:
	move.b (a0)+,(a2)+				; copies after the last '\'
	bne.s lb2							; til the end of the string

	; ***************** verifies if this file exists and opens it **********
verify:	
	st rsc							; did it once (at least)
	pea dta
	GEMDOS 26,6						; fixes my own DTA
	move #1,-(sp)						; normal+read_only files	
	pea full
	GEMDOS 78,8							; search first
	lea exist_error,a0
	tst d0
	bmi ooops

next_file:
	move.l dta+26,total				; the file length
	lea dta+30,a0						; the file name
	move.l fname_pos,a1
.lb0:
	move.b (a0)+,(a1)+
	bne.s .lb0	
	
	clr -(sp)
	pea full2
	GEMDOS 61,8							; fopen with MOV file
	move d0,mov_h						; handle of the file is saved
	

	; ******************* sets some datas to 0 ******************************

	moveq #0,d0
	lea start_zero,a0					; datas that must be 0 at start
	lea end_zero,a1
lb3:
	move.l d0,(a0)+					; zero a long word
	cmp.l a1,a0							; have we finished?
	bmi.s lb3							; not yet
	
	; ******************* verifies the QT MOV format ************************
	
	bsr qt_parse_bin
	beq is_mov						; yes, it's a QT MOV file
	
	; ******************* supposes that it's an AVI file ********************

	bsr avi_parse_bin						; verifies header and gets blocs addresses
	beq is_avi
	
	; ******************* else, sopposes that it's a FLI ********************
	
	bsr fli_read_header
	beq is_fli
	
	; ******************* else, supposes that it's a Batch file *************
	
	jsr bat_read_header
	beq is_bat
	
	jsr mpg_read_header
	beq is_mpg

	if CDEB=0	
	jsr seq_read_header
	beq is_seq
	
	jsr kin_read_header
	beq is_kin
	
	jsr dlt_read_header
	beq is_dlt
	endif
	
	jsr flm_read_header
	beq is_flm
	bmi is_xflm					; -1 if extended flm (synchro or/and sound)
	
	jsr gif_read_header
	beq is_gif
	
	if CDEB=0
	jsr dl_read_header
	beq is_dl

	jsr vmas_read_header
	beq is_vmas
	
	jsr cd_read_header
	beq is_cd
	endif
	
		
	; ******************* else, it's an error *******************************
	
	lea format_error,a0
	bra ooops

is_vmas:
	move.l #vmas_title,a3
	moveq #1,d3
	move.b is_mono,bad_comp
	jsr fill_dialog
.lb1:
	moveq #0,d6			; first tree
	moveq #0,d7
	jsr manage_tree
	cmp #10,d6			; Cancel?
	seq stopped
	beq.s .lb2
	cmp #16,d6			; Infos?
	bne.s .lb2			; no, so it's the 'Go!' button
	jsr displ_info
	bra.s .lb1
.lb2:	
	tst.b stopped
	bne end_of_display	
	tst.b bad_comp
	bne end_of_display
	bsr init_rect
	move.l max_fsize,d1
	bsr malloc
	move.l d0,buffer	
	move.l tree_sav,a0
	btst #0,299(a0)
	bne.s .sync
	clr.l _delay
.sync:
	btst #0,275(a0)
	beq.s .no_sound
	jsr vmas_read_sound
.no_sound:
	jsr set_video
	jsr vmas_read_data
	bra end_of_display	
	
is_dl:
	move.l #dl_title,a3
	st can_count
	bra.s ks_com
	
is_flm:
	move.l #flm_title,a3
	bra.s ks_com

is_dlt:
	move.l #dlt_title,a3
	bra.s ks_com_2
	
is_kin:
	move.l #kin_title,a3
	bra.s ks_com_2
	
is_seq:
	move.l #seq_title,a3
	
ks_com_2:
	move.b is_mono,bad_comp
	
ks_com:
	moveq #0,d3
	jsr fill_dialog
.lb1:
	moveq #0,d6			; first tree
	moveq #0,d7
	jsr manage_tree
	cmp #10,d6			; Cancel?
	seq stopped
	beq.s .lb2
	cmp #16,d6			; Infos?
	bne.s .lb2			; no, so it's the 'Go!' button
	jsr displ_info
	bra.s .lb1
.lb2:
	jsr treat_shift
	move.l tree_sav,a0
	move.l play_sav,324(a0)
	move.l sync_sav,348(a0)
	bclr #4,273(a0)
	bclr #4,297(a0)		; clears the radio flags
	tst.b stopped
	bne end_of_display	; cancel button
	tst.b bad_comp
	bne end_of_display
	tst.b count
	bne.s .lb2a				; no delay with count
	btst #0,299(a0)
	bne.s .lb4
.lb2a:
	clr.l _delay			; no delay if max_speed set!
.lb4:
	bsr init_rect
	move.l comp_txt,d1
	cmp.l #'seq4',d1
	bne.s .other
	move.l max_fsize,d1
	bsr malloc
	move.l d0,buffer
	move.l #32000,d1
	bsr malloc
	move.l d0,s_buffer
	move.l #64000,d1
	bsr malloc
	move.l d0,s_buffer_2
	jsr set_video
	jsr seq_read_data	
.lb3:
	bra end_of_display
.other:
	cmp.l #'kin4',d1
	bne.s .other2
	move.l max_fsize,d1
	bsr malloc
	move.l d0,buffer
	jsr set_video
	jsr kin_read_data
	bra end_of_display
.other2:
	cmp.l #'dlt4',d1
	bne.s .other3
	move.l physbase,buffer
	jsr set_video	
	jsr dlt_read_data
	clr.l buffer			; it was not allocated (the real screen)
	bra end_of_display
.other3:
	move.b #'0',d1
	cmp.l #'flm0',d1
	bne.s .other4
	tst.b bad_comp
	bne end_of_display
	move.l physbase,s_buffer
	tst.b is_mono
	bne.s .tt_flm				; in mono, don't allocate another
	tst tt_res
	beq.s .tt_flm				; ST Low, don't allocate another screen
	move.l tt_screen_size,d1
	bsr malloc
	move.l d0,s_buffer
.tt_flm:
	move.l tt_flag_size,d1
	bsr malloc
	move.l d0,s_buffer_2		; flags for words that changed
	move.l max_fsize,d1
	bsr malloc
	move.l d0,buffer
	jsr set_video
	jsr flm_read_data
	bra end_of_display
.other4:
	cmp.l #'VMA0',d1
	bne.s .other5
	move.l max_fsize,d1
	bsr malloc
	move.l d0,buffer
	jsr set_video
	jsr vmas_read_data
	bra end_of_display
.other5:	
	move.l max_fsize,d1
	bsr malloc
	move.l d0,buffer			; all the screens!
	move.l sample_num,d1
	add.l d1,d1					; number of words
	bsr malloc
	move.l d0,s_buffer		; pointers to the images
	jsr load_dl_palette

	jsr load_dl_screens		; loads and converts 8bits to planes if TT
	tst.b count
	bne end_of_display
	jsr dl_frame_table
	tst.b reduce
	bne.s .no_grey
	bsr set_colors
.no_grey:
	jsr set_video
	jsr dl_read_data
	bra end_of_display	


hide_mouse: dc.l hm_cont,dum,dum,dum,dum

is_xflm:
	move.l #xflm_title,a3
	moveq #1,d3
	jsr fill_dialog
.lb1:
	moveq #0,d6			; first tree
	moveq #0,d7
	jsr manage_tree
	cmp #10,d6			; Cancel?
	seq stopped
	beq.s .lb2
	cmp #16,d6			; Infos?
	bne.s .lb2			; no, so it's the 'Go!' button
	bsr displ_info
	bra.s .lb1
.lb2:	
	tst.b stopped
	bne end_of_display	
	move.l tree_sav,a0
	btst #0,299(a0)
	sne sync
	bsr init_rect
	move.l physbase,s_buffer
	tst.b is_mono
	bne.s .tt_flm
	tst tt_res
	beq.s .tt_flm				; ST Low, don't allocate another screen
	move.l tt_screen_size,d1
	bsr malloc
	move.l d0,s_buffer
.tt_flm:
	move.l tt_flag_size,d1
	bsr malloc
	move.l d0,s_buffer_2		; flags for words that changed
	move.l max_fsize,d1
	bsr malloc
	move.l d0,buffer
	jsr flm_read_sound
	jsr set_video
	jsr flm_read_data
	bra end_of_display	
	
	
hm_cont: dc.w 123,0,0,0,0,0,0,0,0,0,0,0

is_cd:
	move.l #cd_title,a3
	moveq #1,d3
	jsr fill_dialog
.lb1:
	moveq #0,d6			; first tree
	moveq #0,d7
	jsr manage_tree
	cmp #10,d6			; Cancel?
	seq stopped
	beq.s .lb2
	cmp #16,d6			; Infos?
	bne.s .lb2			; no, so it's the 'Go!' button
	jsr displ_info
	bra.s .lb1
.lb2:	
	tst.b stopped
	bne end_of_display	
	move.l tree_sav,a0
	cmp.l #'CDA1',comp_txt
	beq.s .sound_file
	btst #0,299(a0)
	bne.s .sync
	clr.l _delay
.sync:
	jsr init_rect
	move.l max_fsize,d1
	bsr malloc
	move.l d0,buffer
	move.l tree_sav,a0
	btst #0,275(a0)
	beq.s .no_sound
	jsr cd_read_sound
.no_sound:
	jsr set_video
	lea .mono(pc),a0
	cmp.l #'CDH1',comp_txt
	beq.s .lb3
	lea grey16,a0
.lb3:
	pea (a0)
	jsr set_palette
	jsr cd_read_data
	bra end_of_display	
.sound_file:
	btst #0,275(a0)
	beq end_of_display
	move.l total,d0
	sub.l sound_seek,d0
	move.l d0,snd_size
	jsr cd_read_sound
	jsr cd_play_sound
	bra end_of_display
.mono: dc.w $FFF,0,$FFF,0,$FFF,0,$FFF,0,$FFF,0,$FFF,0,$FFF,0,$FFF,0

is_gif:
	move.l #gif_title,a3
	bra.s gm_comm

is_mpg:
	jsr mpg_parse_bin
	st bad_comp
	move.l #mpg_title,a3
gm_comm:
	moveq #1,d3
	jsr fill_dialog
.lb1:
	moveq #0,d6			; first tree
	moveq #0,d7
	jsr manage_tree
	cmp #10,d6			; Cancel?
	seq stopped
	beq.s .lb2
	cmp #16,d6			; Infos?
	bne.s .lb2			; no, so it's the 'Go!' button
	bsr displ_info
	bra.s .lb1
.lb2:	
	tst.b stopped
	bne end_of_display
	cmp.l #'mpeg',comp_txt
	bne.s .lb3
	bra end_of_display
.lb3:
	move.l tree_sav,a0
	moveq #0,d0			; no delay (default)
	btst #0,299(a0)
	beq.s .no_del
	moveq #-1,d0
.no_del:
	move.l d0,_delay	; -1 if delay accepted, 0 if no delay wanted...
	bsr init_rect
	move.l #4*4096,d1
	moveq #0,d0
	move max_imagex,d0
	add.l d0,d1
	bsr malloc
	move.l d0,hc_cvid	; bloc for the LZW codes, plus one line
	jsr set_video		; other mallocs possible
	move.l total,d1
	addq.l #2,d1		; 0 plus $3B
	move.l d1,-(sp)	; tries to load the whole GIF + one byte
	GEMDOS 72,6			; malloc
	tst.l d0
	beq.s .disk
	bmi.s .disk
	move.l d0,buffer
	bsr set_colors
	jsr gif_data_ram
	bra end_of_display
.disk:
	move.l #512,d1		; little buffer!
	bsr malloc
	move.l d0,buffer
	jsr gif_data_disk
	bra end_of_display
	
is_bat:
	lea add_digit-5,a0
	move.l #'0000',(a0)+
	move #'00',(a0)			; resets to 0 the text displayed
	move.l #bat_title,a3
	moveq #0,d3
	tst.b create_mov
	beq.s .lb0
	bmi.s .lb0a
	move.l #bat_title_gif,a3
	bra.s .lb0b
.lb0a:
	move.l #bat_title_avi,a3
	tst.b create_avi
	bne.s .lb0b
	move.l #bat_title_flm,a3
	tst.b slide_degas
	bne.s .lb0b
	move.l #bat_title_create,a3
.lb0b:
	bset #15,d3			; Alt Go allowed
.lb0:
	jsr fill_dialog
.lb1:
	moveq #0,d6			; first tree
	moveq #0,d7
	bsr manage_tree
	cmp #10,d6			; Cancel?
	seq stopped
	beq.s .lb2a
	cmp #16,d6			; Infos?
	bne.s .lb2			; no, so it's the 'Go!' button
	bsr displ_info
	bra.s .lb1
.lb2:
	move.l kbshift,a0
	btst #3,(a0)
	bne.s .lb2b
	sf create_mov		; create mode must be confirmed by 'Alt'
.lb2b:
	bsr clear_alt
	tst.b create_mov
	beq.s .lb2a
	tst.b bad_sound
	bne .lb3c
	jsr init_create
	clr.l _delay		; no synchro!
	bra.s .lb2c
.lb2a:
	tst.b slide_gif
	beq.s .lb2c
	move.l #4*4096,d1
	moveq #0,d0
	move max_imagex,d0
	add.l d0,d1
	bsr malloc
	move.l d0,hc_cvid	; bloc for the LZW codes, plus one line
.lb2c:
	move.l tree_sav,a0
	move.l play_sav,324(a0)
	move.l sync_sav,348(a0)
	bclr #4,273(a0)
	bclr #4,297(a0)		; clears the radio flags
	tst.b stopped
	bne end_of_display
	btst #0,275(a0)
	beq.s .lb4
	clr.l _delay			; no delay if max_speed set!
.lb4:
	bsr init_rect
	move.l max_fsize,d1
	bsr malloc
	move.l d0,buffer
	add.l neo_degas_offs,d0			; for degas,neo
	move.l d0,_flm_phys	; for degas,neo (if used)
	move.l #nothing,cf_display	; for degas,neo (if used)
	tst.b create_mov
	beq.s .lb4a
	tst.b slide_gif
	bne.s .lb3a				; no need to decompress for GIF!
	tst.b slide_degas
	bne.s .lb3a				; nor for degas
	move max_imagex,d0
	addq #3,d0
	and.b #$FC,d0
	move d0,screenw		; 4 pixels aligned
	move max_imagey,screenh
	clr offsx
	clr offsy
	move.l one_buffer,virtual
	move.l #_comp,compression
	bra.s .lb3a
.lb4a:
	jsr set_video			; clears screen and switch to TC
	bsr set_colors		; the 256 grey colors
.lb3a:
	jsr bat_read_data
	tst.b create_mov
	beq end_of_display
	jsr save_header
.lb3c:
	bra end_of_display					; the common end for QT and AVI and FLI
	
is_fli:
	move.l #fli_title,a3
	moveq #0,d3
	bset #15,d3			; Alt Go allowed
	bsr fill_dialog
.lb1:
	moveq #0,d6			; first tree
	moveq #0,d7
	bsr manage_tree
	cmp #10,d6			; Cancel?
	seq stopped
	beq.s .lb2
	cmp #16,d6			; Infos?
	bne.s .lb2			; no, so it's the 'Go!' button
	bsr displ_info
	bra.s .lb1
.lb2:
	jsr treat_shift
	tst.b count
	bne.s .lb2b
	move.l kbshift,a0
	btst #3,(a0)
	beq.s .lb2b
	move.l tree_sav,a0
	bclr #0,275(a0)
	jsr init_flm_create
.lb2b:
	bsr clear_alt	
	move.l tree_sav,a0
	move.l play_sav,324(a0)
	move.l sync_sav,348(a0)
	bclr #4,273(a0)
	bclr #4,297(a0)		; clears the radio flags
	tst.b stopped
	bne end_of_display	; cancel button
	lea _delay,a1
	tst.b count
	bne.s .lb2c				; no sync with count
	btst #0,299(a0)
	bne.s .lb4
.lb2c:
	clr.l (a1)			; no delay if max_speed set!
.lb4:
	tst.b create_flm
	beq.s .lb5
	bclr #0,299(a0)		; no more synchro
	lea flm_time,a0
	clr.l (a0)				; start with 0
	move.l (a1),flm_time_inc	; will add _delay each time
	clr.l (a1)				; no delay while saving
	move.l a0,flm_time_ptr		; memore position
	clr.l flm_ptr_inc		; same memory position
.lb5:
	bsr init_rect
	move.l max_fsize,d1
	bsr malloc
	move.l d0,buffer
	jsr set_video			; clears screen and switch to TC
	bsr set_colors			; flh is TC, so grey display in 256 colors
	tst.b create_flm
	beq.s .lb9
	move.l display_ste,cf_display
	move.l #compress_flm,display_ste
.lb9:
	bsr fli_read_data_256
	bra end_of_display	

is_avi:
	bsr avi_parse_chunks					; reads the header and 'idx1' bloc
	move.l #avi_title,a3
	moveq #1,d3
	bset #15,d3					; Alt Go allowed
	move.l #'rawa',s_signe	; AVI sounds are supposed to be unsigned
	bsr fill_dialog
.lb1:
	moveq #0,d6			; first tree
	moveq #0,d7
	bsr manage_tree
	cmp #10,d6			; Cancel?
	seq stopped
	beq end_of_display
	cmp #16,d6			; Infos?
	bne.s .lb2			; no, so it's the 'Go!' button
	bsr displ_info
	bra.s .lb1
.lb2:
	tst.b bad_comp
	bne.s .lb6			; no graphics
	jsr treat_shift
	tst.b count
	bne.s .lb2b
	move.l kbshift,a0
	btst #3,(a0)
	beq.s .lb2b
	move.l tree_sav,a0
	btst #0,275(a0)		; is there play sound?
	beq.s .lb2c
	bset #0,299(a0)		; yes, so there is a synchronisation
.lb2c:
	jsr init_flm_create
.lb2b:
	bsr clear_alt
	bsr init_rect
	move.l max_fsize,d1
	bsr malloc
	move.l d0,buffer	
.lb6:
	tst.b bad_sound	; bad sound, don't treat
	bne.s .lb4
	tst.l sound_num	; no sound anyway
	beq.s .lb4
	move.l snd_temp_size,d3
	move.l snd_size,d4
	bsr adapt_d4_size
	move.l tree_sav,a0
	btst #0,275(a0)
	beq.s .lb4
	bsr read_sound
.lb4:
	bsr avi_sync_tab
	tst.b create_flm
	beq.s .lb10
	jsr flm_avi_sync
	sf sync						; no synchro while saving
.lb10:
	tst.b count
	beq.s .lb11
	sf sync						; no sync when counting
.lb11:
	jsr set_video
	move.l mapused,d0
	lea cvid_fix1,a0
	tst.l d0
	beq.s .lb8
	bsr fli_color_256_256	; the palette
.lb8:
	tst.b reduce
	bne.s .lb12
	bsr set_colors
.lb12:
	tst.b create_flm
	beq.s .lb9
	move.l display_ste,cf_display
	move.l #compress_flm,display_ste
.lb9:
	bsr avi_read_data
	bra end_of_display					; the common end for QT and AVI
	
	
v_bar: dc.l vb_cont,dum,bar_pts,dum,dum

flm_avi_sync:
	tst.b sync
	beq dummy_flm_sync
	move.l chunkoffs,flm_time_ptr
	moveq #12,d0
	move.l d0,flm_ptr_inc
	clr.l flm_time_inc
	rts
	
vb_cont: dc.w 11,2,0,0,0,1,0,0,0,0,0,0

dummy_flm_sync:
	lea flm_time,a0
	clr.l (a0)
	move.l a0,flm_time_ptr
	clr.l flm_ptr_inc
	clr.l flm_time_inc		; 0=max speed
	rts

clear_alt:
	tst.b command
	beq.s .end
	tst.b cmd_alt
	beq.s .end
	move.l kbshift,a0
	bclr #3,(a0)	; we set this bit if command and cmd_alt
.end:
	rts


; here, treats the case of a QT MOV file

is_mov:
	
	; *************** read infos to prepare decrunch **********************	

	bsr qt_parse_chunks				; reads the frames info and fills some
											; arrays
	
	move.l #qt_title,a3	; the type of file
	tst.b vr_flag
	beq.s .lb0
	move.l #vr_title,a3
.lb0:
	moveq #1,d3
	bset #15,d3				; alt go allowed
	bsr fill_dialog	; the box with infos
.lb1:
	moveq #0,d6			; first tree
	moveq #0,d7
	bsr manage_tree
	cmp #10,d6			; Cancel?
	seq stopped
	beq end_of_display
	cmp #16,d6			; Infos?
	bne im_lb2			; no, so it's the 'Go!' button
	bsr displ_info
	bra.s .lb1
	

show_mouse: dc.l sm_cont,sm_int,dum,dum,dum

flm_read_sound:
	sf playing
	move.l tree_sav,a0
	btst #0,275(a0)		
	beq .end				; no Play sound wanted
	tst.b bad_sound
	bne .end				; bad sound any_way
	tst.l frequency
	beq .end				; no sound!
	move.l flm_snd_size,d7
	move.l d7,-(sp)
	GEMDOS $48,6			; malloc
	tst.l d0
	bmi.s .end				; alloc error
	beq.s .end
	move.l d0,snd_temp
	move.l d0,d6
	movem.l d6-d7,-(sp)
	moveq #1,d6
	moveq #1,d7
	bsr manage_tree
	movem.l (sp)+,d6-d7
	SEEK flm_snd_pos,0
	move.l d6,d0
	add.l d7,d0
	move.l d0,flm_snd_end
	move.l d6,-(sp)
	move.l d7,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; reads the whole sound into memory
	tst.b _snd
	bmi.s .dma
	bsr adapt_sound	
.dma:
	moveq #1,d6
	moveq #-11,d7
	bsr manage_tree
	st playing
.end:
	rts

; DMA sound to Yamaha emulation 9,6KHz or soudn card
; converts to 8 bits mono (even with stereo samples)

adapt_sound:
	move.l d6,a0			; start adress
	move.l d6,a1			; other start adress
	move.l frequency,d0
	cmp.w #12517,d0
	bne.s .other
	bra.s .l1
.loop:
	move.b (a0)+,(a1)+
	move.b (a0)+,(a1)+
	move.b (a0)+,(a1)+
	move.b (a0)+,(a1)+
	addq.l #1,a0
	move.b (a0)+,(a1)+
	move.b (a0)+,(a1)+
	move.b (a0)+,(a1)+
	addq.l #1,a0
.l1:
	subq.l #8,d7
	subq.l #1,d7
	bpl.s .loop
.no_zero:
	move.l d6,a0
	moveq #1,d0
.nz:
	tst.b (a0)+
	bne.s .nz2
	move.b d0,-1(a0)	; 0 replaced by 1
.nz2:
	cmp.l a1,a0
	bmi.s .nz
	clr.b (a0)			; end with a zero!!!
	rts
.other:
	cmp.w #25033,d0
	bne.s .last
	bra.s .l2
.loop2:
	move.l (a0)+,d0
	swap d0
	move.b d0,(a1)+
	swap d0
	move.b d0,(a1)+
	move.l (a0)+,d0
	swap d0
	move.b d0,(a1)+
	swap d0
	move.b d0,(a1)+
	move.l (a0)+,d0
	move.b d0,(a1)+
	move.l (a0)+,d0
	swap d0
	move.b d0,(a1)+
	swap d0
	move.b d0,(a1)+
	addq.l #2,a0
.l2:
	sub.l #18,d7
	bpl.s .loop2
	bra.s .no_zero
.last:
	bra.s .l3
.loop3:
	rept 4
	move.l (a0)+,d0
	move.b d0,(a1)+
	endr
	addq.l #4,a0
	rept 3
	move.l (a0)+,d0
	move.b d0,(a1)+
	endr
	addq.l #4,a0
.l3:
	sub.l #36,d7
	bpl.s .loop3
	bra .no_zero	
	
sm_cont: dc.w 122,0,0,1,0,0,0,0,0,0,0,0
sm_int: dc.w 0


im_lb2:
	tst.b bad_comp
	bne.s .no_step
	tst.b is_grey
	bne.s .no_reduce		; in grey...
	bsr treat_shift
.no_reduce:	
	tst.b count
	bne.s .no_step
	move.l kbshift,a0
	btst #3,(a0)		; alt key?
	beq.s .no_step
	move.l tree_sav,a0
	btst #0,275(a0)
	beq.s .lb0
	bset #0,299(a0)	; if Play sound -> synchro
.lb0:
	jsr init_flm_create
.no_step:
	bsr clear_alt
	jsr treat_vr_box
	cmp #12,d6
	beq end_of_display
	move.l samp_sizes,a0
	cmp.l #0,a0
	beq no_graph
	move.l sample_num,d1
	moveq #0,d0					; computes the max size of a sample
lb4:
	tst.l d1
	beq.s lb5
	subq.l #1,d1
	move.l (a0)+,d2			; a size
	cmp.l d2,d0					; size > max size?
	bpl.s lb4
	move.l d2,d0				; yes, so it's a new max size
	bra.s lb4
	
	
graf_mouse: dc.l mf_cont,global,mf_int,intout,mouse_def,dum
mf_cont: dc.w 78,1,1,1,0

flm_mov_sync:
	tst.b sync
	beq dummy_flm_sync
	move.l t2samps,flm_time_ptr
	moveq #4,d0
	move.l d0,flm_ptr_inc
	clr.l flm_time_inc
	rts

mf_int: dc.w 0
mouse_def: dc.l 0


lb5:
	move.l d0,max_fsize		; keeps the max size
	move.l d0,d1
	bsr malloc					; and allocates the buffer
	move.l d0,buffer			; the address
	

	bsr init_rect		; the movie rectangle, the screen adr, etc...
	bra.s kkk
	
	
appl_exit: dc.l ae_cont,global,dum,intout,dum,dum
ae_cont: dc.w 19,0,1,0,0


no_graph:
	GEM_VDI hide_mouse
kkk:
	bsr init_sound
	tst.b create_flm
	beq.s .lb5
	jsr flm_mov_sync
	sf sync
.lb5:
	tst.b count
	beq.s .lb6
	sf sync				; no synchro with count
.lb6:
	bsr set_video
	tst.b qt_palette
	beq.s .lb0
	tst.b is_grey
	beq.s .color
	bsr grey_mov		; returns EQ if set_colors needed, NE if not
	beq.s .lb0
	bra.s .lb3
.color:
	move.l pal_adr,a0
	bsr fli_color_256_256
	bne.s .lb3			; NE if set colors not needed (16 colors...)
.lb0:
	bsr set_colors		; the 16 grey colors
.lb3:
	tst.b create_flm
	beq.s .lb4
	move.l display_ste,cf_display
	move.l #compress_flm,display_ste
.lb4:
	bsr qt_read_data	; reads and displays the QT MOV file

end_of_display:
	tst.b create_flm
	beq.s .no_flm
	jsr complete_flm_file
	move.l flm_screen,a2
	bsr mfree
	move.l flm_frame,a2
	bsr mfree
.no_flm:
	move.l buffer,a2
	bsr mfree				; frees the buffer
	move.l s_buffer,a2
	bsr mfree				; desallocates the big buffers before using AES
	move.l s_buffer_2,a2
	bsr mfree
	move.l snd_temp,a2
	bsr mfree
	move.l bat_text,a2
	bsr mfree
	move.l virtual,a2
	bsr mfree
	
	jsr restore_video

	tst.b stopped
	bne.s .no_count
	tst.b count
	beq.s .no_count
	lea dta+30,a0
	lea count_file,a1
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0),(a1)		; 12 bytes for the file name
	pea count_end
	GEMDOS 9,6
	move #2,-(sp)
	BIOS 2,4
	st stopped	
.no_count:	

	move #3,fd_int
	GEM_AES form_dial		; screen updates
	sf display

	bsr redraw

	bsr restore_16		; back to the desktop colors

	jsr redraw_menu
	
	tst.b stopped
	bne.s .lb0				; stopped, no general stats displayed
	tst.l samp_sizes
	beq.s .lb0				; no graphics, so no stats about graphics...
	tst.b bad_comp			; graphics played?
	bne.s .lb0				; no, because of the bad_compresion
	tst.b step_mode		; step mode?
	bne.s .lb0				; yes, no time stats
	
	bsr fill_stat
	moveq #3,d6				; 3rd dialog
	moveq #0,d7
	bsr manage_tree
	st stopped				; if stat box, don't show alert 'Everything is Ok'
	
.lb0:
	GEM_VDI show_mouse	; the mouse is back
	
	tst.b command			; with a command line, no alert boxes
	bne.s end
	tst.b stopped			; if movie stopped (Control key), not that box
	bne.s end
	
	pea ok					; tells that everything is OK
	bsr alert

	
	; *************** closes the file and restarts ************************
	; *************** frees memory too ************************************
end:
	move.l hc_cvid,a2
	bsr mfree
	move.l codecs,a2
	bsr mfree
	move.l samp_sizes,a2
	bsr mfree
	move.l t2samps,a2
	bsr mfree
	move.l s2chunks,a2
	bsr mfree
	move.l chunkoffs,a2
	bsr mfree
	move.l sound_offs,a2
	bsr mfree
	move.l ss_tab,a2
	bsr mfree
	tst mov_h2
	beq.s .no_create
	move mov_h2,-(sp)
	GEMDOS 62,4							; closes created file
.no_create:
	tst mov_h
	bmi .nobox							; if <0, no file opened
	move mov_h,-(sp)					; else, a file is opened
	GEMDOS 62,4							; so, we need an fclose
.nobox:

	jsr exit_menu
	
	tst.b inter_flag
	bne.s end_end						; stopped by an interruption
	pea dta
	GEMDOS 26,6							; fixes my own DTA
	GEMDOS 79,2							; search next
	tst.l d0
	beq next_file
	
	tst.b command
	beq again							; if no command line, go to the fileselector
											; else, this is the end!	
	tst.b cmd_dial
	bne.s end_end
	tst.b cmd_inter
	bne verify											

end_end:
	tst.b cmd_dial
	bne.s .lb0
	tst.b cmd_inter
	beq.s .lb0
	jsr restore_vectors
	tst.b inter_flag
	beq.s .lb0
	move.l kbshift,a0
	bclr #2,(a0)				; we simulated Control, so clear it
.lb0:
	GEM_VDI show_mouse				; the mouse is back
	GEM_VDI close_work				; byebye VDI
	
	move #2,wu_int
	GEM_AES wind_update
	
	tst.b acc
	beq.s .lb1							; not an acc, exit!
	
	move.l menu_buffer,a2
	bsr mfree							; frees the buffer
	bra acc_wait						; if an accessory, back to the loop
	
.lb1:
	GEM_AES appl_exit					; a hand-shaking to AES
	GEMDOS 0,2							; a kiss for GEMDOS
	; here, nothing can occur...	
	
menu_bar: dc.l mb_cont,global,mb_int,dum,menu_tree,dum
mb_cont: dc.w 30,1,1,1,0
mb_int: dc.w 0

treat_shift:
	if REG=1
		tst.b is_mono
		bne.s .oops				; no color reduc with monochrome
		tst.b can_count
		bne.s .ok				
	.oops:
		rts						; can't count, no 256 colors mode
	.ok:
		sf count					; indexs used
		move.l kbshift,a0
		st reduce
		btst #0,(a0)
		bne.s .lb0
		btst #1,(a0)
		sne reduce
	.lb0:
		tst.b reduce
		bne.s .lb1
		rts						; no shift wanted
	.lb1:
		lea dta+30,a0			; file name
		lea count_file,a1		; the last file analised
		moveq #11,d0
	.lb2:
		move.b (a1)+,d1		; one char
		cmp.b (a0)+,d1
		bne.s .not_same
		tst.b d1
		dbeq d0,.lb2
		rts						; Ok, count=0, reduce=1
	.not_same:
		sf reduce
		st count					; Not equal, first we must count
		st bad_sound			; no sound when counting
		sf is_rep				; and no loop
		sf vr_flag				; and no VR
	endif
	rts					


fli_read_header:
	SEEK #0,0				; start of file
	pea intout				; as a temporary buffer
	move.l #128,-(sp)		; header len
	move mov_h,-(sp)
	GEMDOS 63,12			; fread
	tst.l d0
	bpl.s .lb0
.false:
	moveq #1,d0
	rts
.lb0:
	lea intout,a0
	move.l (a0)+,d0		; len of file
	INTEL d0					; they were drinking whiskey while building the 8088
	move.l d0,d1
	sub.l total,d1			; difference between two sizes
	bpl.s .plus
	neg.l d1
.plus:
	lsr.l #8,d0
	lsr.l #1,d0				; 1/1000 of the size
	cmp.l d0,d1
	bpl.s .false			; diff is too high
	moveq #1,d7				; default fli,flc (1byte/pix)
	move (a0)+,d0
	move 10(a0),d1			; time
	ror #8,d1
	cmp #$12af,d0
	bne.s .lb1
	move.l #'flc ',d0
	st can_count
.lb1a:
	ext.l d1					; milliseconds per frame
	divs #5,d1				; 1/200
	ext.l d1
	bne.s .lb2				; ok
	moveq #14,d1			; if 0, 14/200 gives 14 frames per second
	bra.s .lb2
.lb1:
	cmp #$44af,d0
	bne.s .lb1b
	move.l #'flh ',d0
	moveq #2,d7			; flh: 2bytes/pix
	bra.s .lb1a
.lb1b:
	cmp #$11af,d0		; magic
	bne.s .false
	move.l #'fli ',d0
	st can_count
	muls #731,d1
	lsr.l #8,d1				; number of 1/200
	bne.s .lb2				; ok
	moveq #14,d1			; if 0, default value
.lb2:
	move.l d1,_delay		; for one frame
	move.l d0,comp_txt
	moveq #0,d0
	move (a0)+,d0			; number of frames
	ror #8,d0
	move.l d0,sample_num
	move (a0)+,d0
	ror #8,d0
	move d0,max_imagex
	move (a0)+,d1
	ror #8,d1
	move d1,max_imagey
	muls d7,d1
	muls d0,d1				; number of pixels = max number of bytes per image
	add.l #1000,d1			; plus the palette (768) and others
	move.l d1,max_fsize  ; must be enough to store one frame at the time.
	moveq #0,d0
	st samp_sizes
	rts						; returns EQ

fli_read_data_256:
	tst.b bad_comp
	beq.s .good
	st stopped
	rts
.good:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
.disp_again:
	SEEK #128,0				; start of frames
	clr.l disp_frame
	move.l sample_num,d7	; number of frames
	lea colors256,a6
	cmp.l #'flh ',comp_txt
	bne.s .palette_mode
	move.l hc_cvid,a6		; with FLH, it's a 16 bits mode
.palette_mode:
	move.l virtual,a5
	move.l buffer,a4
	move max_imagex,d3
	move.l $4ba.w,start_time
	move.l $4ba.w,current_time
	bra .next
.loop: 
	addq.l #1,disp_frame
	lea intout,a3
	pea (a3)					; as a buffer
	move.l #16,-(sp)		; the frame header
	move mov_h,-(sp)
	GEMDOS 63,12			; fread
	move.l (a3)+,d0
	INTEL d0					; size of the frame
	subq.l #8,d0
	subq.l #8,d0			; 16 bytes yet read
	cmp #$faf1,(a3)+		; magic for a normal frame
	beq.s .normal
	SEEK d0,1				; else skips
	bra .next
.normal:
	move (a3),d6
	ror #8,d6				; number of chunks
	pea (a4)					; the buffer
	move.l d0,-(sp)		; the len to read
	move mov_h,-(sp)
	GEMDOS 63,12			; reads one frame
	move.l current_time,d0
.delay:
	cmp.l $4ba.w,d0
	bpl.s .delay
	add.l _delay,d0
	move.l d0,current_time
	move.l a4,a0			; start of the frame
	bra .ch_loop
.chunk:
	move.l (a0)+,d0
	INTEL d0					; chunk size
	lea -4(a0,d0.l),a1	; end of the chunk
	move (a0)+,d0
	ror #8,d0				; chunk ID
	cmp #12,d0				; fli_lc
	bne.s .lb0
	bsr fli_lc_256
	movem.l a1/a4-a6/d3/d6-d7,-(sp)
	move.l display_ste,a0
	jsr (a0)
	movem.l (sp)+,a1/a4-a6/d3/d6-d7
	bra .lb4
.lb0:
	cmp #7,d0				; flc_lc
	bne.s .lb00
	bsr flc_lc_256
	movem.l a1/a4-a6/d3/d6-d7,-(sp)
	move.l display_ste,a0
	jsr (a0)
	movem.l (sp)+,a1/a4-a6/d3/d6-d7
	bra .lb4
.lb00:
	cmp #15,d0				; fli_brun
	bne.s .lb1
	bsr fli_brun_256
	movem.l a1/a4-a6/d3/d6-d7,-(sp)
	move.l display_ste,a0
	jsr (a0)
	movem.l (sp)+,a1/a4-a6/d3/d6-d7
	bra .lb4
.lb1:
	cmp #11,d0				; fli_color (64)
	bne.s .lb2
	movem.l a1/a4-a6/d3/d6-d7,-(sp)
	move.l $4ba.w,-(sp)
	bsr fli_color_64_256
	move.l $4ba.w,d0
	sub.l (sp)+,d0
	add.l d0,current_time
	movem.l (sp)+,a1/a4-a6/d3/d6-d7
	bra .lb4
.lb2:
	cmp #4,d0				; flc_color (256)
	bne.s .lb20
	movem.l a1/a4-a6/d3/d6-d7,-(sp)
	move.l $4ba.w,-(sp)
	bsr fli_color_256_256
	move.l $4ba.w,d0
	sub.l (sp)+,d0
	add.l d0,current_time
	movem.l (sp)+,a1/a4-a6/d3/d6-d7
	bra.s .lb4
.lb20:
	cmp #13,d0				; fli_black
	bne.s .lb3
	bsr fli_black
	bra.s .lb4
.lb3:
	cmp #16,d0				; fli_copy
	bne.s .lb3a
	bsr fli_copy_256
	movem.l a1/a4-a6/d3/d6-d7,-(sp)
	move.l display_ste,a0
	jsr (a0)
	movem.l (sp)+,a1/a4-a6/d3/d6-d7
	bra.s .lb4
.lb3a:
	cmp #27,d0
	bne.s .lb3b
	bsr flh_delta_256
	movem.l a1/a4-a6/d3/d6-d7,-(sp)
	move.l display_ste,a0
	jsr (a0)
	movem.l (sp)+,a1/a4-a6/d3/d6-d7
	bra.s .lb4
.lb3b:
	cmp #25,d0
	bne.s .lb4
	bsr flh_brun_256
	movem.l a1/a4-a6/d3/d6-d7,-(sp)
	move.l display_ste,a0
	jsr (a0)
	movem.l (sp)+,a1/a4-a6/d3/d6-d7
.lb4:
	move.l a1,a0			; unknow ID, just skip!
.ch_loop:
	dbf d6,.chunk
.next:
	move.l kbshift,a0
	btst #2,(a0)
	bne.s .stop
	dbf d7,.loop
	tst.b is_rep
	bne .disp_again
	bra.s .exit
.stop:
	st stopped
.exit:
	move.l $4ba.w,end_time
	move.l stack_adr,-(sp)
	GEMDOS 32,6
	rts
	
fli_brun_256:
	move max_imagey,d5		; number of lines to modify
	move d5,flx_number
	clr flx_start
	move.l a5,a2				; screen pointer
	bra.s .l_loop
.line:
	lea 0(a2,d3.l),a3			; the next line in memory
	moveq #0,d4					; number of blocs
	move.b (a0)+,d4
	beq.s .apex					; si 0, c'est du Apex tout crach‚
	bra.s .b_loop
.blocs:
	moveq #0,d1
	moveq #0,d0
	move.b (a0)+,d0			; number of pixels
	cmp #$7f,d0
	bls.s .repeat
	sub #$100,d0
	neg d0
	bra.s .c_loop
.copy:
	move.b (a0)+,d1
	move.b 0(a6,d1.w),(a2)+	; into offset
.c_loop:
	dbf d0,.copy
	bra.s .b_loop
.repeat:
	move.b (a0)+,d1
	move.b 0(a6,d1.w),d1	; the color to be repeated
	bra.s .lb2
.lb1:
	move.b d1,(a2)+
.lb2:
	dbf d0,.lb1
.b_loop:
	dbf d4,.blocs
.next_line:
	move.l a3,a2				; the next line
.l_loop:
	dbf d5,.line
	rts	
.apex:
	move max_imagex,d4		; loop key is the width
	subq #1,d4
.ap_blocs:
	moveq #0,d1
	moveq #0,d0
	move.b (a0)+,d0			; number of pixels
	cmp #$7f,d0
	bls.s .ap_repeat
	sub #$100,d0
	neg d0
	sub d0,d4
	bra.s .ap_c_loop
.ap_copy:
	move.b (a0)+,d1
	move.b 0(a6,d1.w),(a2)+
.ap_c_loop:
	dbf d0,.ap_copy
	bra.s .ap_b_loop
.ap_repeat:
	sub d0,d4
	move.b (a0)+,d1
	move.b 0(a6,d1.w),d1	; the color to be repeated
	bra.s .ap_lb2
.ap_lb1:
	move.b d1,(a2)+
.ap_lb2:
	dbf d0,.ap_lb1
.ap_b_loop:
	tst d4
	bpl.s .ap_blocs
	bra.s .next_line


flc_lc_256:
	moveq #0,d1					; to convert bytes to words
	move (a0)+,d5				; number of lines
	ror #8,d5
	move #1,flx_number
	clr flx_start
	sf _disp
	move.l a5,a2				; screen pointer
	bra .l_loop
.line:
	lea 0(a2,d3.l),a3			; next line
.skip80:
	move (a0)+,d4
	cmp.b #$80,d4
	beq.s .skip80
	ror #8,d4					; number of blocs
	btst #14,d4
	beq.s .lb0
	eor #$ffff,d4
	tst.b _disp
	bne.s .yet
	add d4,flx_number
.yet:
	muls d3,d4
	add.l d4,a3
	addq #1,d5
	bra.s .next
.lb0:
	st _disp
	bra.s .b_loop
.blocs:
	moveq #0,d0
	move.b (a0)+,d0
	add d0,a2
	move.b (a0)+,d0
	cmp #$7f,d0
	bls.s .p2_loop
	sub #$100,d0
	neg d0
	move.b (a0)+,d1
	move.b 0(a6,d1.w),d2
	move.b (a0)+,d1
	move.b 0(a6,d1.w),d1
	bra.s .p_loop
.pixel:
	move.b d2,(a2)+
	move.b d1,(a2)+
.p_loop:
	dbf d0,.pixel
	bra.s .b_loop
.pixel2:
	move.b (a0)+,d1
	move.b 0(a6,d1.w),(a2)+
	move.b (a0)+,d1
	move.b 0(a6,d1.w),(a2)+
.p2_loop:
	dbf d0,.pixel2
.b_loop:
	dbf d4,.blocs
.next:
	tst.b _disp
	beq.s .yet2
	addq #1,flx_number
.yet2:
	move.l a3,a2
.l_loop:
	dbf d5,.line
	move max_imagey,d0
	cmp flx_number,d0
	bpl.s .exit
	subq #1,flx_number
.exit:
	rts

fli_lc_256:
	move (a0)+,d0
	ror #8,d0					; number of lines to skip
	move (a0)+,d5
	ror #8,d5					; number of lines to modify
	move d0,flx_start
	move d5,flx_number
	move.l a5,a2				; screen pointer
	muls d3,d0
	add.l d0,a2					; points to the correct line
	bra.s .l_loop
.line:
	lea 0(a2,d3.l),a3			; the next line in memory
	moveq #0,d4					; number of blocs
	move.b (a0)+,d4
	bra.s .b_loop
.blocs:
	moveq #0,d0
	move.b (a0)+,d0			; number of pixels to skip
	lea 0(a2,d0.w),a2
	moveq #0,d1
	moveq #0,d0
	move.b (a0)+,d0			; number of pixels
	cmp #$80,d0
	bpl.s .repeat
	bra.s .c_loop
.copy:
	move.b (a0)+,d1
	move.b 0(a6,d1.w),(a2)+	; the color from the palette into the screen memory
.c_loop:
	dbf d0,.copy
	bra.s .b_loop
.repeat:
	sub #$100,d0
	neg d0
	move.b (a0)+,d1
	move.b 0(a6,d1.w),d1	; the color to be repeated
	bra.s .lb2
.lb1:
	move.b d1,(a2)+
.lb2:
	dbf d0,.lb1
.b_loop:
	dbf d4,.blocs
	move.l a3,a2				; the next line
.l_loop:
	dbf d5,.line
	rts
	
fli_copy_256:
	move.l a5,a2				; the image
	move max_imagey,d5		; number of lines
	move d5,flx_number
	clr flx_start
	move max_imagex,d1
	moveq #0,d2
	bra.s .l_loop
.line:
	lea 0(a2,d3.l),a3			; the next line
	move d1,d4					; pixels per line
	bra.s .p_loop
.pixel:
	move.b (a0)+,d2
	move.b 0(a6,d2.w),(a2)+
.p_loop:
	dbf d4,.pixel
	move.l a3,a2				; next line
.l_loop:
	dbf d5,.line
	rts
	
fli_color_64_256:
	lea colors256,a6
	if REG=1
		tst.b count
		bne init_count_tab
		tst.b reduce				; $ff if reduce colors
		beq.s .normal
		moveq #2,d7					; 2 shifts (8 bits)
		jmp reduce_pal
	.normal:
	endif
	move (a0)+,d0				; number of blocs
	ror #8,d0
	moveq #63,d3				; limit mask
	bra.s .b_loop
.blocs:
	moveq #0,d1
	move.b (a0)+,d1			; number of colors to skip
	lea 0(a6,d1.w),a6			; jumps to the correct color
	move.b (a0)+,d1
	bne.s .col_loop
	move #255,d1				; if d1=0 it means 256 colors
.color:
	move.b (a0)+,d2
	and.w d3,d2
	move.b (a0)+,d4
	and.w d3,d4
	add d4,d4
	add d4,d2
	move d2,d4
	add d2,d2
	add d4,d2
	move.b (a0)+,d4
	and.w d3,d4
	add d4,d2					; brightness from 0 to 630
	ext.l d2
	divs #40,d2					; from 0 to 15
	lsl.b #3,d2					; as an offset
	move.b d2,(a6)+
.col_loop:
	dbf d1,.color
.b_loop:
	dbf d0,.blocs
	rts		
	
	if REG=1
	
init_count_tab:
	lea count_tab,a0
	moveq #0,d0
.lb0:
	move.b d0,(a6)+			; init color256 (0 to 255)
	clr.l (a0)+					; count to 0
	addq #1,d0
	cmp #256,d0
	bmi.s .lb0
	lea count_file,a0
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)					; clears the file name
									; it will be valid at the end of the anim
	lea count_stat+8,a0
	move.l #'0000',d0			; resets the counters
	move.l d0,(a0)+
	move d0,(a0)+
	clr.b d0
	move.l d0,16(a0)
	
	pea count_title
	GEMDOS 9,6
	rts
	
	endif

fli_color_256_256:
	lea colors256,a6			; here, keep this line (6 bytes) first!
									; see at gif palette
	if REG=1
		tst.b count
		bne.s init_count_tab
	endif
	cmp.l #$01000010,(a0)	; one block, 16 colors?
	beq.s .colors16
	if REG=1
		tst.b reduce				; $ff if reduce colors
		beq.s .normal
		moveq #0,d7					; no shift (8 bits)
		jmp reduce_pal
	.normal:
	endif
	move (a0)+,d0				; number of blocs
	ror #8,d0
	bra.s .b_loop
.blocs:
	moveq #0,d1
	move.b (a0)+,d1			; number of colors to skip
	add d1,a6
	move.b (a0)+,d1
	bne.s .col_loop
	move #255,d1				; if d1=0 it means 256 colors
.color:
	moveq #0,d2
	move.b (a0)+,d2
	moveq #0,d4
	move.b (a0)+,d4
	add d4,d4
	add d4,d2
	move d2,d4
	add d2,d2
	add d4,d2
	moveq #0,d4
	move.b (a0)+,d4
	add d4,d2					; brightness from 0 to 2550
	divs #160,d2					; from 0 to 15
	lsl.b #3,d2					; from 0 to 15 * 8 bytes per routine
	move.b d2,(a6)+
.col_loop:
	dbf d1,.color
.b_loop:
	dbf d0,.blocs
	moveq #0,d0					; returns EQ, set colors needed
	rts		
.colors16:
	addq.l #4,a0				; skips header
	move.l #$00081018,(a6)+
	move.l #$20283038,(a6)+
	move.l #$40485058,(a6)+
	move.l #$60687078,(a6)
	lea colors256,a6
bios_palette:					; a6 a ZONE, a0 the 16 RGB
	moveq #15,d1
	move.l a6,a1
._color:
	moveq #0,d2
	move.b (a0)+,d2
	lsl #3,d2
	btst #7,d2
	beq.s .c0
	bset #11,d2
.c0: 
	move.b (a0)+,d2
	lsr.b d2
	btst #3,d2
	beq.s .c1
	bset #7,d2
.c1:
	and.b #$F0,d2
	move.b (a0)+,d0
	rol.b #3,d0
	bclr #3,d0
	btst #7,d0
	beq.s .c2
	bset #3,d0
.c2:
	and.b #$f,d0
	or.b d0,d2
	move d2,(a1)+
	dbf d1,._color
	move.l a6,-(sp)
	jsr set_palette
	moveq #1,d0					; returns EQ, set colors not needed	
	rts
		
fli_black:
	move.l a1,-(sp)
	GEM_VDI v_bar			; VDI still works
	move.l (sp)+,a1
	rts

	; verifies AVI format and gets the addresses of the 3 main blocs
	; header + data + index	
	; returns EQ if ok and NE if error
	
avi_parse_bin:
	SEEK #0,0				; start of file
	move.l #$20202020,d6
	bsr read_3_long
	or.l d6,d0				; chunk name
	cmp.l #'riff',d0
	beq.s .lb0
.false:
	moveq #1,d0				; not an AVI file
	rts
.lb0:
	moveq #3,d7				; number of addresses to find
	moveq #4,d1
.lb1:
	tst d7
	beq .end
	subq.l #4,d1
	SEEK d1,1				; position into d0
	move.l d0,d5			; saves it
	bmi.s .false			; error!
	cmp.l total,d0
	beq.s .false			; end of file!
	addq.l #8,d5
	bsr read_3_long
	or.l d6,d0
	or.l d6,d2
	INTEL d1
	cmp.l #'idx1',d0
	bne.s .lb2
	subq #1,d7				; one bloc found
	move.l d5,idx_pos
	move.l d1,idx_len
	bra.s .lb1
.lb2:
	cmp.l #'list',d0
	bne.s .lb1
	cmp.l #'hdrl',d2
	bne.s .lb3
	subq #1,d7
	addq.l #4,d5
	move.l d5,head_pos
	subq.l #4,d1
	move.l d1,head_len
	addq.l #4,d1
	bra.s .lb1
.lb3:
	cmp.l #'movi',d2
	bne.s .lb1
	subq #1,d7
	move.l d5,movi_pos
	bra .lb1
.end:
	moveq #0,d0
	rts
		
	; reads the header (size of the image, number of frames, compression,
	; sound frequency, etc...)
	; then reads the 'idx1' section and prepares the tables to read each
	; frame


avi_parse_chunks:
	move.l #$20202020,d7
	lea cvid_fix0,a6			; the buffer to read the header
	move.l head_len,d6
	SEEK head_pos,0			; to the right position
	move.l a6,-(sp)
	move.l d6,-(sp)			; lenght of the AVI header bloc
	move mov_h,-(sp)
	GEMDOS 63,12
	lea 0(a6,d6.l),a5			; end address
	moveq #0,d4					; ffctype (vids or auds)
.lb0:
	cmp.l a5,a6
	bpl .end_header
	GET_LONG a6,d0				; chunk name
	or.l d7,d0					; to lower case
	GET_ILONG a6,d1			; size
	cmp.l #'avih',d0
	bne .lb1
	lea 16(a6),a3				; points to total frames
	GET_ILONG a3,d0
	move.l d0,sample_num	; number of frames
	lea 12(a3),a3
	GET_ILONG a3,d0
	move d0,max_imagex
	move d0,d2
	addq #3,d0
	and.b #$FC,d0
	move d0,xto4n
	add #15,d0
	and.b #$F0,d0
	sub xto4n,d0
	lsr #2,d0
	move d0,iv32_uv_inc
	lsr #2,d2
	addq #3,d2
	and.b #$fc,d2
	move d2,xqto4n
	GET_ILONG a3,d0
	move d0,max_imagey
	move d0,d2
	addq #3,d0
	and.b #$fc,d0
	move d0,yto4n
	lsr #2,d2
	addq #3,d2
	and.b #$fc,d2
	move d2,yqto4n
	st samp_sizes
	bra .next
.lb1:
	cmp.l #'list',d0
	bne.s .lb2
	move.l a6,a3
	GET_LONG a3,d0
	cmp.l #'strl',d0
	bne .next
	addq.l #4,a6
	bra .lb0
.lb2:
	cmp.l #'strh',d0
	bne.s .lb3
	move.l a6,a3
	GET_LONG a3,d4			; fcctype
	or.l d7,d4
	cmp.l #'vids',d4
	bne .next
	lea 20(a6),a3
	GET_ILONG a3,d0
	lea 24(a6),a3
	GET_ILONG a3,d2		; rate
	lea _op2,a3
	move.l d0,(a3)+		; op2
	move.l #200,(a3)		; op1
	jsr spmul
	move.l d2,-(a3)		; divis
	jsr spdiv
	move.l 4(a3),avi_rate
	bra .next	
.lb3:
	cmp.l #'strf',d0
	bne .next
	cmp.l #'vids',d4		; video info?
	bne .lb4					; no...
	lea 32(a6),a3
	GET_ILONG a3,d0		; number of colors into the palette
	move.l d0,mapused
	beq.s .c9
	bsr prepare_avi_pal
.c9:
	moveq #0,d4
	lea 16(a6),a3
	GET_LONG a3,d0			; compression
	or.l d7,d0				; to lower
	move.l d0,comp_txt
	if CDEB=0
	cmp.l #'cvid',d0
	bne.s .c1
	move.l #qt_decode_256,d0
	bra .next_comp
.c1:
	cmp.l #'msvc',d0
	beq.s .c1a
	cmp.l #'cram',d0
	bne .c2
.c1a:
	move.b 13(a6),d0
	ror #8,d0
	move.b 12(a6),d0		; Planes
	move.b 15(a6),d2
	ror #8,d2
	move.b 14(a6),d2		; bitcount
	muls d2,d0				; number of bits per pixel
	move d0,cram_bits
	cmp #16,d0
	bne.s .c5
	move.l #decode_cram16_grey,d0
	bra .next_comp
.c5:
	cmp #8,d0
	bne .unsup				; unsupported CRAM
	move.l #decode_cram8_256,d0
	st can_count
	bra .next_comp
.c2:
	endif
	cmp.l #'!   ',d0	; rle 8
	bne.s .c8
	move.l #'rle8',comp_txt
	move.l #decode_rle8_256,d0
	st can_count
   bra .next_comp
.c8:
	if CDEB=0
	cmp.l #'yuv9',d0
	beq.s .c12
	cmp.l #'yvu9',d0
	bne.s .c10
.c12:
	move.l #qt_yuv9_256,d0
	bra .next_comp
.c10:
	cmp.l #'    ',d0	; rgb
	bne.s .c13
	move.l #'rgb8',comp_txt
	move.l #decode_rgb_256,d0
	st can_count
	bra.s .next_comp
.c13:
	not.l d0
	cmp.l #$9689ccce,d0		; iv31
	beq.s .iv
	cmp.l #$9689cccd,d0		; iv32
	bne.s .unsup
.iv:
	move.l #intel_iv32_256,d0
	bra.s .next_comp	
	endif
.unsup:
	st bad_comp
	bra.s .next
.lb4:
	cmp.l #'auds',d4		; sound info?
	bne.s .next
	moveq #0,d4
	move.b 3(a6),d0
	ror #8,d0
	move.b 2(a6),d0
	lea 4(a6),a3
	move d0,channels
	GET_ILONG a3,d0
	move.l d0,frequency
	move.b 7(a3),d0
	ror #8,d0
	move.b 6(a3),d0
	move d0,sound_bits
.next:
	add.l d1,a6
	bra .lb0
.next_comp:
	move.l d0,compression
	bra.s .next
.end_header:
	move planes_sav,planes
	SEEK idx_pos,0			; to the index table
	move.l idx_len,d4
	move.l d4,d6
	asr.l #4,d6				; each entry is 16 bytes long
	move.l d6,d3			; for the loop
	move.l sample_num,d5
	tst.l frequency
	beq.s .no_sound
	sub.l d5,d6				; total frames - image frames >= sound frames
	move.l d6,d1
	beq.s .no_sound
	asl.l #3,d1				; 8 bytes for each sound (pos + len)
	bsr malloc
	move.l d0,sound_offs
	move.l d0,a4			; for the sound
.no_sound:
	move.l d5,d1
	add.l d5,d1
	add.l d5,d1				; * 3
	asl.l #2,d1				; *4 =12 bytes for each image (offset + size + time)
	addq.l #8,d1
	addq.l #8,d1			; for dummy values (start and end)
	bsr malloc
	move.l d0,chunkoffs
	move.l d0,a5			; for the graphics
	addq.l #4,a5			; skips over the dumy value
	move.l d4,d1
	bsr malloc				; for the whole idx1
	move.l d0,snd_temp	; saves it
	move.l d0,-(sp)
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	move.l #0,a3			; no offset
	move.l snd_temp,a0
	move.l a0,a2			; for mfree
	move.l d3,d6
	moveq #0,d4				; total sound size
	moveq #0,d5				; max_fsize
	moveq #0,d3				; max sound size
	move.l sample_num,a1	; to verify
	move.l 8(a0),d1		; first position
	INTEL d1
	cmp.l movi_pos,d1		; in the movie section?
	bpl.s .ok				; yes, positions are absolute
	move.l movi_pos,a3	; else, we must add a base address
.ok:
	move.l (a0)+,d0
	or.l d7,d0
	move.l d0,d1
	swap d1
	cmp #'00',d1			; 00dc or 00xx or else = a frame!
	bne.s .lb5
	cmp.l #0,a1				; end of expected frames?
	beq.s .unknown			; yes, skips!
	subq.l #1,a1			; one less frame
	move.l (a0)+,d2		; flags
	move.l (a0)+,d1		; offset
	INTEL d1
	add.l a3,d1
	addq.l #8,d1			; to skip the ID and the size
	move.l d1,(a5)+
	move.l (a0)+,d1		; size
	INTEL d1
	move.l d1,(a5)+
	cmp.l d1,d5
	bpl.s .lb6
	move.l d1,d5			; new max fsize
.lb6:
	clr.l (a5)+				; time
	btst #28,d2				; flag for 'key frame'
	beq.s .loop
	bset #7,-4(a5)			; bit 31 of time
	addq.l #1,ss_num			; number of key frames
	bra.s .loop
.lb5:
	cmp.l #'01wb',d0
	bne.s .unknown
	addq.l #1,sound_num
	addq.l #4,a0			; skip flags
	move.l (a0)+,d1		; offset
	INTEL d1
	add.l a3,d1
	addq.l #8,d1			; to skip the ID and the size
	move.l d1,(a4)+
	move.l (a0)+,d1		; size
	INTEL d1
	move.l d1,(a4)+
	add.l d1,d4				; updates the total size
	cmp.l d1,d3
	bpl.s .loop
	move.l d1,d3			; new max sound size
	bra.s .loop
.unknown:
	lea 12(a0),a0			; skips it
.loop:
	subq.l #1,d6
	bne .ok
	move.l a1,d6
	sub.l d6,sample_num	; if less than expected frames
	bsr mfree
	move.l sample_num,d2	; total frames
	move.l ss_num,d0		; key frames
	beq.s .no_key			; no key frames...
	divu d0,d2				; number of frames for 1 key frame
	swap d2
	clr d2
	swap d2
	cmp.l #4,d2				; more than 4?
	bmi.s .no_key
	st sync+1				; yes, so never skip a key frame!
.no_key:
	move.l d5,max_fsize
	move.l d4,snd_size
	move.l d3,snd_temp_size			
	rts	


prepare_avi_pal:
	movem.l a0-a1,-(sp)
	lea cvid_fix1,a0
	move #$0100,(a0)+		; one bloc
	clr.b (a0)+				; first color
	move.b d0,(a0)+		; number of colors
	lea 40(a6),a1			; start of palette
	bra.s ap_loop
	
	
open_work: dc.l ow_cont,ow_int,dum,work_out,ptsout
ow_cont: dc.w 100,0,0,11,0,0,0,0,0,0,0,0
ow_int: dc.w 2,1,1,1,1,1,1,0,1,0,2


ap_lb0:
	move.b 2(a1),(a0)+	; red
	move.b 1(a1),(a0)+	; green
	move.b (a1),(a0)+		; blue
	addq.l #4,a1
ap_loop:
	dbf d0,ap_lb0
	movem.l (sp)+,a0-a1
	rts

	
avi_read_data:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
.disp_again:
	moveq #0,d4
	moveq #0,d3				; sync flags
	tst.b playing
	beq.s .no_sound
	bsr start_sound
.no_sound:
	tst.b bad_comp
	bne .exit				; bad compression!
	move max_imagey,flx_number
	clr flx_start
	move.b sync,d3
	tst.b sync+1
	beq.s .ad
	bset #16,d3				; we can't skip a key frame 
.ad:
	move.l $4ba.w,start_time	; Timer C
	move.l sample_num,d7
	move.l chunkoffs,a6
	addq.l #4,a6
	bra .loop
.lb0:
	lea 8(a6),a0
	bclr #31,d3
	move.l (a0),d0
	bpl.s .no_key
	bset #31,d3
	bclr #31,d0
.no_key:
	move.l d0,a3
	tst.w d3
	beq.s .lb1
	bpl.s .pos
	tst.l d3
	bpl.s .skip
	btst #16,d3
	bne.s .lb1
	bra.s .pos1
.pos:
	tst.l d3
	bpl.s .pos1
	btst #16,d3
	bne.s .lb1
.pos1:
	move.l $4ba.w,d1
	sub.l start_time,d1
	cmp.l d1,a3
	bpl.s .lb1
	tst d3
	bmi.s .skip
.search:
	lea 12(a0),a0
	tst.b (a0)
	bpl.s .search
	move.l -12(a0),d0
	cmp.l d1,d0
	bpl.s .lb1
	bset #15,d3
.skip:
	lea 12(a6),a6
	bra .loop	
.lb1:
	bclr #15,d3
	move.l (a6)+,d0
	cmp.l d0,d4
	beq.s .no_seek
	SEEK d0,0			; good positon
	move.l d0,d4
.no_seek:
	move.l buffer,-(sp)
	move.l (a6)+,d0
	move.l d0,bufused
	addq.l #8,d0		; +00dc +len
	addq.l #1,d0
	bclr #0,d0			; even
	move.l d0,-(sp)
	add.l d0,d4			; new position
	move mov_h,-(sp)
	GEMDOS 63,12			; reads the frame
	move.l (a6)+,d0
	bclr #31,d0
	move.l d0,a3		; the time
	addq.l #1,disp_frame
	tst.b d3
	beq.s .disp
	move.l start_time,a0
	move.l -16(a6),d0
	bpl.s .ageu
	bclr #31,d0
.ageu:
	add.l d0,a0
.wait:
	cmp.l $4ba.w,a0
	bpl.s .wait
.disp:
	movem.l d3-d4/d7/a3/a6,-(sp)
	move.l compression,a0
	jsr (a0)
	move.l display_ste,a0
	jsr (a0)
	movem.l (sp)+,d3-d4/d7/a3/a6
.loop
	move.l kbshift,a0
	btst #2,(a0)
	bne.s .stop
	subq.l #1,d7
	bpl .lb0
	bra.s .exit
.stop:
	st stopped
.exit:
	tst.b stopped
	bne.s .quit
	move.l kbshift,a0
	btst #2,(a0)
	bne.s .stop
	tst.b _snd
	bmi.s .dma_quit
	tst.b yamaha_flag
	bne.s .exit
	bra.s .test_repeat
.dma_quit:
	btst #0,$ffff8901.w
	bne.s .exit
.test_repeat:
	tst.b is_rep
	bne .disp_again
.quit:
	tst.b playing
	beq.s .quit3
	tst.b _snd
	bpl.s .quit2
	clr.b $ffff8901.w
	bra.s .quit3
.quit2:
	move sr,d0
	move #$2700,sr
	move.l yamaha_ptr,a0
	clr.b (a0)+
	clr.b (a0)
	move d0,sr
.quit3:
	move.l $4ba.w,end_time
	move.l stack_adr,-(sp)
	GEMDOS 32,6
	rts


avi_sync_tab:
	move.l tree_sav,a0
	btst #0,299(a0)		; objetc 'synchronize'
	beq .end					; no sync
	move.l chunkoffs,a1
	cmp.l #0,a1
	beq .end
	move.l sample_num,d4
	btst #0,275(a0)		; play_sound?
	beq.s .lb4				; no, so use avi_rate!
	tst.b bad_sound	; bad sound, use avi_rate
	bne.s .lb4
	tst.l sound_num	; no sound anyway, avi_rate
	beq.s .lb4
	move.l frequency,-(sp)
	move.l snd_size,d1	; the size in bytes
	tst.b create_flm
	bne.s .dma
	tst.b _snd
	bmi.s .dma
	move.l #9600,frequency
	bra.s .lb5				; without DMA, stereo yet treated
.dma:	
	cmp #2,channels
	bne.s .lb5				; not a stereo, 1byte = 1sample
	asr.l #1,d1				; else 2bytes = 1 sample
.lb5:
	divu frequency+2,d1	; number of seconds for the whole sound
	move.l d1,d0
	muls #200,d0			; number of 1/200 (for entire seconds)
	swap d1
	muls #200,d1			; the remainder
	divu frequency+2,d1	
	swap d1
	clr d1
	swap d1
	add.l d0,d1				; d1=number of 200th of second for the whole sample
								; to use the Timer C of the system
	move.l (sp)+,frequency
	bra.s .lb3
.lb4:
	move.l d4,d1
;	divu avi_rate+2,d1	; number of seconds for the whole sound
;	move.l d1,d0
;	muls #200,d0			; number of 1/200 (for entire seconds)
;	swap d1
;	muls #200,d1			; the remainder
;	divu avi_rate+2,d1	
;	swap d1
;	clr d1
;	swap d1
;	add.l d0,d1				; d1=number of 200th of second for the whole sample
								; to use the Timer C of the system
	muls avi_rate+2,d1
.lb3:
	cmp.l #65536,d4
	bpl.s .reduce
	cmp.l #65536,d1
	bmi.s .go_on
.reduce:
	lsr.l d4
	lsr.l d1
	bra.s .lb3

.go_on:
	clr.l (a1)+				; the first entry contains 0 (start of the sound)
	moveq #1,d6
.lb1:
	addq.l #8,a1			; skips pos and size
	move.l d6,d3			; number of frames
	mulu d1,d3
	divu d4,d3				; d3 is the corresponding duration in 1/200 sec
	swap d3
	clr d3
	swap d3
	or.l d3,(a1)+			; to keep the 'key frame' flag
	addq.l #1,d6
	cmp.l d6,d4
	bpl.s .lb1
	st sync
	bset #7,8(a1)			; the last is always marked!
.end:
	rts
	
	
	; qt_parse_bin returns EQ if the QT MOV format is correct
	; or NE if there's an error. In this case, the AVI format will be
	; supposed.
	
qt_parse_bin:
	moveq #2,d5							; 2 ids to find
	moveq #-1,d6
	moveq #1,d0
.next:
	tst.l d0
	bmi.s .bug
	beq.s .bug
	tst d5
	beq.s .ok
	add.l d0,d6
	cmp.l total,d6
	bpl.s .bug
	SEEK d6,0	
	bsr read_len_id
	cmp.l #'skip',d1
	beq.s .skip0
	cmp.l #'mdat',d1
	bne.s .lb0
.skip0:
	move.l d6,d7
	add.l d0,d7							; end of mdat section
	move.l d7,mdat_end
	subq #1,d5
	bra.s .next
.lb0:
	cmp.l #'moov',d1
	bne.s .next
	subq #1,d5
	bra.s .next
.bug:
	moveq #1,d0
	rts
.ok:
	SEEK #0,0
	moveq #0,d0
	rts

qt_parse_chunks:
	moveq #1,d7				; the file_len
.lb0:
	tst.l d7
	bgt.s .lb1				; goes on if file_len >0
.end:
	rts   					; end if file_len<=0
.lb1:
	SEEK #0,1				; current position
	move.l total,d1
	sub.l d0,d1				; remaining bytes
	cmp.l #8,d1
	bmi.s .end				; not enough for len+id, end of file reached
	bsr read_len_id
	cmp.l #'skip',d1
	beq.s .skip1
	cmp.l #'mdat',d1
	bne.s .lb2
.skip1:
	tst.l d0
	bne.s .lb2
	lea mdat_error,a0		; if mdat and len=0, an error
	bra ooops
.lb2:
	cmp.l #8,d0
	bmi.s .end				; if len<8, we stop parsing
	cmp.l #1,d7
	bne.s .lb3
	cmp.l #'skip',d1
	beq.s .lb3
	cmp.l #'mdat',d1
	beq.s .lb3
	move.l d0,d7			; if file_len=1 and id <> 'mdat', file_len=len
	cmp.l #'moov',d1
	beq.s .lb3
	addq.l #1,d7			; and if id<>'moov', then file_len=len+1
.lb3:
	; *********************** atoms ***************
	cmp.l #'trak',d1
	bne.s .lb5
	clr.l v_flag
	clr.l s_flag
	move.l codec_num,codec_lastnum
	move.l chunkoff_num,chunkoff_lastnum
	move.l sample_num,sample_lastnum
	move.l s2chunk_num,s2chunk_lastnum
.lb4: subq.l #8,d7		; file_len = file_len - 8
	bra .lb0
.lb5:	cmp.l #'moov',d1
	beq.s .lb4
	cmp.l #'mdia',d1
	beq.s .lb4
	cmp.l #'minf',d1
	beq.s .lb4
	cmp.l #'stbl',d1
	beq.s .lb4
	cmp.l #'edts',d1
	beq.s .lb4
.lb6:
	; ********************** stuff *********************
	cmp.l #'mvhd',d1
	bne.s .lb7
	sub.l d0,d7
	SEEK #100,1			; just jump 100 bytes
	bra .lb0
.lb7:
	cmp.l #'tkhd',d1
	bne.s .lb8
	sub.l d0,d7
	SEEK #84,1			; just jump 84 bytes
	bra .lb0
.lb8:
	cmp.l #'elst',d1
	bne.s .lb9
	sub.l d0,d7
	bsr read_len_id
	muls #12,d1			; number of blocks of 12 bytes
	SEEK d1,1			; jumps
	bra .lb0
.lb9:
	cmp.l #'mdhd',d1
	bne.s .lb10
	sub.l d0,d7
	SEEK #12,1			; jumps 12 bytes
	bsr read_long
	lea qt_time,a0
	tst.l (a0)
	beq.s .lb9b
	clr.l (a0)+			; vmhd yet read = qt_time=0
.lb9b:
	move.l d0,(a0)		; in qt_time or qt_timescale
	SEEK #8,1			; jumps 8 more bytes
	bra .lb0
.lb10:
	cmp.l #'hdlr',d1
	bne.s .lb11
	sub.l d0,d7
	move.l d0,d6		; saves len
	SEEK #24,1			; jumps 24 bytes
	sub.l #32,d6		; is len>32
	bmi .lb0
	beq .lb0
	move.l d6,d0		; yes, d0 bytes to read
	bsr qt_read_name	; as a name
	bra .lb0
	; ********************* data chunks ***********************
.lb11:
	cmp.l #'skip',d1
	beq.s .skip2
	cmp.l #'mdat',d1
	bne.s .lb12
.skip2:
	subq.l #8,d0
	SEEK d0,1			; just jumps
	st data_flag		; and sets the data flag TRUE
	bra .lb0
.lb12:
	cmp.l #'stsd',d1
	bne.s .lb14
	clr.l video_flag
	move.l d0,-(sp)	; saves the len
	bsr qt_read_stsd
	move.l (sp)+,d0
	cmp.l #1,v_flag
	beq.s .lb13
	moveq #16,d0		; 16 for sound and text
.lb13:
	sub.l d0,d7			; sub 16 or normal len for video
	bra .lb0
.lb14:
	cmp.l #'stts',d1
	bne.s .lb15
	sub.l d0,d7
	bsr qt_read_stts
	bra .lb0
.lb15:
	cmp.l #'stss',d1
	bne.s .lb16
	sub.l d0,d7
	bsr qt_read_stss
	bra .lb0
.lb16:
	cmp.l #'stco',d1
	bne.s .lb17
	sub.l d0,d7
	bsr qt_read_stco
	bra .lb0
.lb17:
	cmp.l #'stsz',d1
	bne.s .lb18
	sub.l d0,d7
	bsr qt_read_stsz
	bra .lb0
.lb18:
	cmp.l #'stsc',d1
	bne.s .lb19
	sub.l d0,d7
	bsr qt_read_stsc
	bra .lb0
	; ************** sound codec header ******************
.lb19:	
	cmp.l #'pods',d1
	bne.s .lb20
	sub.l d0,d7
	subq.l #8,d0
	SEEK d0,1			; just jumps
	bra .lb0
.lb20:
	; ************** video/sound codec headers ***********
	cmp.l #'twos',d1	; signed sound
	beq.s .lb201
	cmp.l #'raw ',d1
	beq.s .lb201
	cmp.l #$0000,d1
	bne.s .lb202
	move.l #'raw ',d1
	bra.s .lb201
.lb202:
	cmp.l #'ima4',d1
	bne .lb22
.lb201:
	move.l d1,s_signe
	sub.l d0,d7
	subq.l #8,d0
	cmp.l #1,v_flag
	beq.s .lb21
	SEEK #16,1
	bsr read_long
	move d0,sound_bits
	swap d0
	move d0,channels
	SEEK #4,1
	bsr read_long
	clr d0
	swap d0
	move.l d0,frequency
	bra .lb0
.lb21:
	SEEK d0,1
	bra .lb0
	; ************** video codec headers *****************
.lb22:
	cmp.l #'smc ',d1
	bne.s .lb24
.lb23:
	sub.l d0,d7
	subq.l #8,d0
	bra.s .lb21
.lb24:
	cmp.l #'rpza',d1
	beq.s .lb23
	cmp.l #'rle ',d1
	beq.s .lb23
	cmp.l #'cvid',d1
	beq.s .lb23
	; ************** type of trak ************************
	cmp.l #'vmhd',d1
	bne.s .lb25
	move.l #1,v_flag
	lea qt_time,a0
	moveq #-1,d1
	tst.l (a0)
	beq.s .lb24b
	move.l (a0),d1		; timscale yet read
	clr.l (a0)+
.lb24b:
	move.l d1,(a0)		
	bra.s .lb23
.lb25:
	cmp.l #'smhd',d1
	bne.s .lb26
	move.l #1,s_flag
	bra.s .lb23
	; ************** ignored for now *********************
.lb26:
	cmp.l #'gmhd',d1
	beq.s .lb23
	cmp.l #'text',d1
	beq.s .lb23
	cmp.l #'skip',d1
	beq.s .lb23
	cmp.l #'stgs',d1
	beq.s .lb23
	cmp.l #'udta',d1
	beq.s .lb27
	cmp.l #'dinf',d1
	beq .lb23
	; ************* unknown ******************************
	bra .lb23
.lb27:
	sub.l d0,d7
	subq.l #8,d0
	cmp.l #12481,d0
	bpl .lb21		; too large, skip it!
	pea cvid_fix0
	move.l d0,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	tst.l d0
	bmi .lb0
	lea cvid_fix0,a0
.lb28:
	GET_LONG a0,d0
	tst.l d0
	beq .lb0			; nothing found...
	GET_LONG a0,d1
	subq.l #8,a0
	or.l #$20202020,d1
	cmp.l #'navg',d1
	beq.s .lb29
	add.l d0,a0
	bra.s .lb28
.lb29:
	move.l a0,d0
	bclr #0,d0
	move.l d0,a1
	moveq #55,d0
.lb32:
	move.b (a0)+,(a1)+
	dbf d0,.lb32
	lea -56(a1),a0	
	st vr_flag
	lea vr_info,a1
	move.l 16(a0),(a1)+	; img/cell and time
	move 12(a0),d0	; max_y
	ext.l d0
	moveq #0,d2		; default start_y
	move d0,(a1)+
	move.l 38(a0),d1	
	sub.l 34(a0),d1
	cmp.l #360,d1
	spl (a1)			; loop_y
	addq.l #2,a1
	tst.l d1
	beq.s .lb30		; no y movement
	move.l d0,d2
	muls 48(a0),d2
	lsl.l #2,d2
	sub.l d1,d2
	lsr.l #2,d2
	divs d1,d2
	sub d0,d2
	neg d2
	subq #1,d2
	cmp d0,d2
	bne.s .lb30
	subq #1,d2
.lb30:
	move d2,(a1)+
	move 10(a0),d0	; max_x
	moveq #0,d2		; default start_x
	move d0,(a1)+
	move.l 30(a0),d1	
	sub.l 26(a0),d1
	cmp.l #360,d1
	spl (a1)			; loop_x
	addq.l #2,a1
	tst.l d1
	beq.s .lb31		; no x movement
	move.l d0,d2
	muls 44(a0),d2
	divs d1,d2
	cmp d0,d2
	bne.s .lb31
	subq #1,d2
.lb31:
	move d2,(a1)+	
	bra .lb0

	; reads a name
	; D0=size expected
	; if d0=1 we take the size of the string (1 byte) and jump this size
	; if D0>1 we jump d0 bytes
	
qt_read_name:
	cmp.l #2,d0
	bpl.s .lb0				; 2 or more, normal read
	pea dum
	move.l #1,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	moveq #0,d0
	move.b dum,d0
.lb0:
	SEEK d0,1				; jumps
	rts
	
qt_read_stsd:
	bsr read_len_id		; version and num
	cmp.l #1,v_flag
	beq.s .lb0
	rts
.lb0:
	move.l d1,d4			; saves num
	tst.l codecs
	bne.s .lb1
	move.l d1,codec_num
	asl.l #4,d1				; each bloc->16bytes
	bsr malloc
	move.l d0,codecs
	moveq #0,d5				; cur
	bra.s .lb3
.lb1:
	move.l codec_num,d5	; cur and saves the old num
	add.l d5,d1
	move.l d1,codec_num	; updates the num
	asl.l #4,d1
	bsr malloc				; a new larger block
	move.l codecs,a0		; old block
	move.l d0,a1			; new block
	move.l a0,a2			; saves the old bloc (for mfree)
	move.l d0,codecs		; updates the adress
	move.l d5,d1			; old num
.lb2:
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+	; copies one codec
	subq.l #1,d1			; til the end of the old block
	bne.s .lb2
	bsr mfree				; a2 is the adress of the old one	
.lb3:
	asl.l #4,d5				; the offset for the first codec to read
	move.l codecs,a5
	add.l d5,a5				; adress of the first codec
	moveq #0,d5				; the flag for validity
.lb4:	
	bsr read_len_id
	move.l d0,d5			; len
	move.l d1,d6			; id
	SEEK #24,1
	bsr read_word
	move.l d0,(a5)			; width
	bsr read_word
	move.l d0,4(a5)		; height
	SEEK #14,1
	moveq #32,d0
	bsr qt_read_name
	bsr read_long
	move d0,d1				; flag for the palette
	clr d0
	swap d0					; qt_depth
	cmp #32,d0
	beq.s .common			; do not clear bit #5 if 32 planes
	bclr #5,d0				; flag for 'grey'
	beq.s .color
.grey:
	st is_grey
	move d0,grey_depth
	bra.s .common
.color:
	cmp #2,d0
	beq.s .grey				; grey when only 4 colors
.common:
	move.l d0,8(a5)		; into the codec
	sub.l #$56,d5			; updates the len
	move.l #default_pal_16,pal_adr
	cmp #4,d0
	beq.s .lb5
	move.l #default_palette,pal_adr
	cmp #8,d0				; qt_depth = 8?
	bne.s .lb5				; no color map
	btst #3,d1				; default palette?
	bne.s .lb5				; yes, nothing to do
	bsr load_palette
.lb5:
	or.l #$20202020,d6
	move.l d6,comp_txt
	if CDEB=0
	cmp.l #'cvid',d6
	beq .lb7				; ok
	cmp.l #'smc ',d6
	beq .lb11
	cmp.l #'raw ',d6
	beq .lb12
	endif
	cmp.l #'rle ',d6
	beq .lb13
	if CDEB=0
	cmp.l #'rpza',d6
	beq .lb15
	cmp.l #'yuv2',d6
	beq .lb17
	cmp.l #'yuv9',d6
	beq .lb18
	cmp.l #'yvu9',d6
	beq .lb18
	cmp.l #'8bps',d6
	beq .lb19
	cmp.l #'msvc',d6
	beq .lb20
	cmp.l #'wrle',d6
	beq .lb21
	not.l d6
	cmp.l #$9689cccd,d6		; iv32
	beq .lb22
	cmp.l #$9689ccce,d6
	beq .lb22
	endif
.lb6:	
	st bad_comp
	bra .lb8
.lb7:
	move.l #qt_decode_256,a0
	cmp #24,d0				; 24 planes?
	beq .lb8
	cmp #32,d0				; 32 planes?
	bne.s .lb6           ; if not, unsupported
	bra .lb8
.lb11:
	cmp #8,d0				; depth
	bne.s .lb6				; unsupported
	st qt_palette
	st can_count
	move.l #qt_smc_256,a0	; default, 256 colours
	bra .lb8
.lb12:
	cmp #1,d0
	bne.s .lb12f				; other depth
	move.b #'1',comp_txt+3	; raw1, monochrome
	move.l #qt_raw1_256,a0
	bra .lb8
.lb12f:
	cmp #2,d0
	bne.s .lb12g
	move.b #'2',comp_txt+3	; raw2, 4 colors
	st qt_palette
	move.l #qt_raw2_256,a0
	bra .lb8
.lb12g:
	cmp #4,d0
	bne.s .lb12a				; other depth
	move.b #'4',comp_txt+3	; 'raw4'
	st qt_palette
	move.l #qt_raw4_256,a0
	bra .lb8
.lb12a:
	cmp #16,d0
	bne.s .lb12b				; other depth
	move.l #'rw16',comp_txt
	move.l #qt_raw16_256,a0
	bra .lb8
.lb12b:
	cmp #24,d0
	bne.s .lb12c				; other depth
	move.l #'rw24',comp_txt
	clr off_24_32
.lb12e:
	move.l #qt_raw24_256,a0
	bra .lb8
.lb12c:
	cmp #32,d0
	bne.s .lb12d
	move #1,off_24_32
	move.l #'rw32',comp_txt
	bra.s .lb12e
.lb12d:	
	cmp #8,d0
	bne .lb6				; unsupported depth
	move.b #'8',comp_txt+3	; 'raw8'
	st qt_palette
	st can_count
	move.l #qt_raw_256,a0
	bra .lb8
.lb13:
	cmp #32,d0
	bne.s .lb13b
	move #1,off_24_32
	move #'32',comp_txt+2
	bra.s .lb13c
.lb13b:
	cmp #24,d0
	bne.s .lb13a
	move #'24',comp_txt+2		; 'rl24'
	clr off_24_32
.lb13c:
	move.l #qt_rle24_256,a0
	bra .lb8
.lb13a:
	cmp #16,d0
	bne.s .lb14
	move #'16',comp_txt+2		; 'rl16'
	move.l #qt_rle16_256,a0
	bra .lb8
.lb14:
	cmp #8,d0
	bne.s .lb14b			
	move.b #'8',comp_txt+3		; 'rle8'
	st qt_palette
	st can_count
	move.l #qt_rle8_256,a0
	bra .lb8
.lb14b:
	cmp #2,d0
	bne.s .lb14c
	move.b #'2',comp_txt+3
	st qt_palette
	move.l #qt_rle2_256,a0
	bra .lb8
.lb14c:
	cmp #4,d0
	bne.s .lb14d
	move.b #'4',comp_txt+3
	st qt_palette
	move.l #qt_rle4_256,a0
	bra .lb8
.lb14d:
	cmp #1,d0
	bne .lb6				; unsuported
	move.b #'1',comp_txt+3
	move.l #qt_rle1_256,a0
	bra .lb8
.lb15:
	cmp #16,d0
	bne .lb6				; always 16 bits
	move.l #qt_rpza_256,a0
	bra .lb8
.lb17:
	cmp #24,d0
	bmi .lb6				; millions colors needed
	move.l #qt_yuv2_256,a0
	bra .lb8
.lb18:
	cmp #24,d0
	bmi .lb6				; millions colors needed
	move.l #qt_yuv9_256,a0
	bra .lb8
.lb19:
	cmp #8,d0
	bne .lb6				; unsupported depth
	st qt_palette
	st can_count
	move.l #decode_rgb_256,a0
	bra .lb8
.lb20:
	move d0,cram_bits	; for init_rect
	cmp #16,d0
	bne.s .c5			; not cram 16
	move.l #decode_cram16_grey,a0
	bra.s .lb8
.c5:
	cmp #8,d0
	bne .lb6				; unsupported CRAM
	st qt_palette
	st can_count
	move.l #decode_cram8_256,a0
	bra.s .lb8
.lb21:
	cmp #8,d0
	bne .lb6				; unsupported depth
	st qt_palette
	st can_count
	move.l #decode_rle8_256,a0
	bra.s .lb8
.lb22:
	cmp #24,d0
	bne .lb6
	move.l #intel_iv32_256,a0
.lb8:
	move.l a0,12(a5)		; compression routine
	SEEK d5,1				; jumps the data
	move.l (a5),d0			; W
	move d0,d1
	addq #3,d0
	and.b #$FC,d0
	move d0,xto4n
	add #15,d0
	and.b #$F0,d0
	sub xto4n,d0
	lsr #2,d0
	move d0,iv32_uv_inc
	lsr #2,d1
	addq #3,d1
	and.b #$fc,d1
	move d1,xqto4n
	move xto4n,d0
	cmp max_imagex,d0
	bmi.s .lb9
	move d0,max_imagex
.lb9:
	move.l 4(a5),d0
	move d0,d1
	addq #3,d0
	and.b #$fc,d0
	move d0,yto4n
	lsr #2,d1
	addq #3,d1
	and.b #$fc,d1
	move d1,yqto4n
	move yto4n,d1
	cmp max_imagey,d1
	bmi.s .lb10
	move d1,max_imagey
.lb10:
	lea 16(a5),a5			; next codec
	subq.l #1,d4
	bne .lb4
	move.l #1,video_flag
	rts	

load_palette:
	movem.l d0-d2/a0-a2,-(sp)
	move.l d5,d0			; size to read
	cmp.l #2057,d5			; 2*.l + 256 * 8
	bmi.s .lb0
	move.l #2056,d0
.lb0:
	sub.l d0,d5				; updates the len
	pea cvid_fix1
	move.l d0,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; fread
	lea cvid_fix1,a0		; the palette read
	lea 2056(a0),a1		; the palette for fli_color_256_(256)
	move.l a1,pal_adr
	move.l #$01000000,(a1)+
	move.l (a0)+,d0		; start
	move.l (a0)+,d1		; end
.lb1:
	move (a0)+,d2			; index
	lea 0(a1,d2.w),a2
	add d2,d2
	add d2,a2
	move.b (a0),(a2)+
	move.b 2(a0),(a2)+
	move.b 4(a0),(a2)
	addq.l #6,a0			; next color
	addq #1,d0			; one more color
	cmp d0,d1			; the end?
	bpl.s .lb1			; no...
	movem.l (sp)+,d0-d2/a0-a2
	rts
	
qt_read_stts:
	bsr read_len_id		; version and num
	tst.l video_flag
	bne.s .lb0
	asl.l #3,d1				; each block is 8 bytes long
	SEEK d1,1				; jumps over
	rts
.lb0:
	move.l d1,d4			; saves num
	tst.l t2samps
	bne.s .lb1
	move.l d1,t2samp_num
	asl.l #3,d1				; each bloc->8 bytes
	bsr malloc
	move.l d0,t2samps
	moveq #0,d5				; cur
	bra.s .lb3
.lb1:
	move.l t2samp_num,d5	; cur and saves the old num
	add.l d5,d1
	move.l d1,t2samp_num	; updates the num
	asl.l #3,d1
	bsr malloc				; a new larger block
	move.l t2samps,a0		; old block
	move.l d0,a1			; new block
	move.l a0,a2			; saves the old bloc (for mfree)
	move.l d0,t2samps		; updates the adress
	move.l d5,d1			; old num
.lb2:
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+	; copies one t2samp
	subq.l #1,d1			; til the end of the old block
	bne.s .lb2
	bsr mfree				; a2 is the adress of the old one	
.lb3:
	asl.l #3,d5				; the offset for the first codec to read
	move.l t2samps,a5
	add.l d5,a5				; adress of the first t2samp
.lb4:
	bsr read_len_id		; count and duration
	move.l d0,(a5)+		; count
	move.l d1,(a5)+		; duration
.lb10:
	subq.l #1,d4			; another t2samp?
	bne .lb4					; yes, loop
	rts	

qt_read_stss:
	bsr read_len_id		; version and num
	move.l d1,ss_num
	asl.l #2,d1
	tst.l video_flag
	bne.s .lb0
	SEEK d1,1
	rts
.lb0:
	move.l d1,d4			; saves the len to read
	bsr malloc
	move.l d0,ss_tab
	move.l d0,-(sp)
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	rts
	
qt_read_stsc:
	subq.l #8,d0			; len-8
	move.l d0,d5			; saves
	SEEK #0,1				; current position into d0
	add.l d0,d5				; whatever happens, we must leave at current+len-16
	move.l d5,-(sp)		; saves
	bsr read_len_id		; version and num
	tst.l video_flag
	bne.s .lb0
.end:
	move.l (sp)+,d5
	SEEK d5,0				; jumps over what's not read
	rts
.lb0:
	move.l d1,d4			; saves num
	tst.l s2chunks
	bne.s .lb1
	move.l d1,s2chunk_num
	addq.l #1,d1			; starts at 0, one more block
	move.l d1,d0
	add.l d0,d0
	add.l d0,d1				; *3
	asl.l #2,d1				; *4 = *12
	bsr malloc
	move.l d0,s2chunks
	moveq #0,d5				; cur
	bra.s .lb3
.lb1:
	move.l s2chunk_num,d5	; cur and saves the old num
	add.l d5,d1
	move.l d1,s2chunk_num	; updates the num
	addq.l #1,d1			; begins at 0, so 1 block more
	move.l d1,d0
	add.l d0,d0
	add.l d0,d1				; *3
	asl.l #2,d1				; *4 = *12
	bsr malloc				; a new larger block
	move.l s2chunks,a0		; old block
	move.l d0,a1			; new block
	move.l a0,a2			; saves the old bloc (for mfree)
	move.l d0,s2chunks	; updates the adress
	move.l d5,d1			; old num
.lb2:
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+	; copies one s2chunk
	subq.l #1,d1			; til the end of the old block
	bne.s .lb2
	bsr mfree				; a2 is the adress of the old one	
.lb3:
	move.l d5,d0
	add.l d0,d0
	add.l d0,d5				; *3
	asl.l #2,d5				; *4 = *12
	move.l s2chunks,a5
	add.l d5,a5				; adress of the first s2chunk
	move.l codec_num,d5
	sub.l codec_lastnum,d5
.lb4:	
	bsr read_long			; first_chk
	add.l chunkoff_lastnum,d0
	subq.l #1,d0
	move.l d0,(a5)+		; first
	bsr read_len_id		; samp_per and chunk_tag
	cmp.l d1,d5
	bpl.s .lb5
	st stsc_invalid
	moveq #1,d0
	moveq #1,d1
.lb5:
	move.l d0,(a5)+		; samp_per into num
	add.l codec_lastnum,d1
	subq.l #1,d1
	move.l d1,(a5)+		; chunk_tag into tag
.lb10:
	subq.l #1,d4			; another t2samp?
	bne .lb4					; yes, loop
	bra .end	

qt_read_stsz:
	sub.l #20,d0			; len-20
	move.l d0,d5			; saves
	SEEK #4,1				; skips version
	bsr read_len_id		; samp_size and num
	tst.l video_flag
	bne.s .lb0
	SEEK d5,1				; jumps over what's not read
	rts
.lb0:
	move.l d0,d3			; for the last loop
	move.l d5,d6			; for the last loop too
	move.l d1,d4			; saves num
	tst.l samp_sizes
	bne.s .lb1
	move.l d1,sample_num
	asl.l #2,d1				; each bloc->4 bytes
	bsr malloc
	move.l d0,samp_sizes
	moveq #0,d5				; cur
	bra.s .lb3
.lb1:
	move.l sample_num,d5		; cur and saves the old num
	add.l d5,d1
	move.l d1,sample_num	; updates the num
	asl.l #2,d1					; each block is 4 bytes long
	bsr malloc					; a new larger block
	move.l samp_sizes,a0		; old block
	move.l d0,a1			; new block
	move.l a0,a2			; saves the old bloc (for mfree)
	move.l d0,samp_sizes	; updates the adress
	move.l d5,d1			; old num
.lb2:
	move.l (a0)+,(a1)+	; copies one samp_size
	subq.l #1,d1			; til the end of the old block
	bne.s .lb2
	bsr mfree				; a2 is the adress of the old one	
.lb3:
	asl.l #2,d5				; the offset for the first samp_size to fill
	move.l samp_sizes,a5
	add.l d5,a5				; adress of the first samp_size
	move.l a5,a4			; to know if we're on the first samp_size
.lb4:	
	tst.l d6					; another samp_size on disk?
	beq.s .lb5				; no, all has been readen
	bsr read_long			; else read 4 bytes...
	subq.l #4,d6			; ... and counts them!
	bra.s .lb7
.lb5:
	cmp.l a5,a4				; if all has been readen, is this the first?
	bne.s .lb6				; no
	move.l d3,d0         ; yes, use samp_size (see at the begining)
	bra.s .lb7
.lb6:
	move.l -4(a5),d0		; it's not the first, so use the previous value
.lb7:
	move.l d0,(a5)+	   ; fills the samp_size
	subq.l #1,d4			; another samp_size?
	bne .lb4					; yes, loop
	rts

qt_read_stco:
	bsr read_len_id		; version and num
	tst.l video_flag
	bne stco_video
	tst.l s_flag
	bne.s .stco_sound
	asl.l #2,d1				; nor video, neither sound, we skip it!
	SEEK d1,1
	rts	
.stco_sound:
	move.l d1,d4			; saves num
	tst.l sound_offs
	bne.s .lb1
	move.l d1,sound_num
	asl.l #3,d1				; each bloc->8 bytes
	bsr malloc
	move.l d0,sound_offs
	moveq #0,d5				; cur
	bra.s .lb3
.lb1:
	move.l sound_num,d5		; cur and saves the old num
	add.l d5,d1
	move.l d1,sound_num	; updates the num
	asl.l #3,d1					; each block is 8 bytes long
	bsr malloc					; a new larger block
	move.l sound_offs,a0		; old block
	move.l d0,a1			; new block
	move.l a0,a2			; saves the old bloc (for mfree)
	move.l d0,sound_offs	; updates the adress
	move.l d5,d1			; old num
.lb2:
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+	; copies one chunkoff
	subq.l #1,d1			; til the end of the old block
	bne.s .lb2
	bsr mfree				; a2 is the adress of the old one	
.lb3:
	asl.l #3,d5				; the offset for the first chunkoff to fill
	move.l sound_offs,a5
	add.l d5,a5				; adress of the first chunkoff
.lb4:	
	bsr read_long			; reads one chunkoff
	move.l d0,(a5)+	   ; and stores it
	addq.l #4,a5
	subq.l #1,d4			; another samp_size?
	bne .lb4					; yes, loop
	rts
stco_video:
	move.l d1,d4			; saves num
	tst.l chunkoffs
	bne.s .lb1
	move.l d1,chunkoff_num
	asl.l #2,d1				; each bloc->4 bytes
	bsr malloc
	move.l d0,chunkoffs
	moveq #0,d5				; cur
	bra.s .lb3
.lb1:
	move.l chunkoff_num,d5		; cur and saves the old num
	add.l d5,d1
	move.l d1,chunkoff_num	; updates the num
	asl.l #2,d1					; each block is 4 bytes long
	bsr malloc					; a new larger block
	move.l chunkoffs,a0		; old block
	move.l d0,a1			; new block
	move.l a0,a2			; saves the old bloc (for mfree)
	move.l d0,chunkoffs	; updates the adress
	move.l d5,d1			; old num
.lb2:
	move.l (a0)+,(a1)+	; copies one chunkoff
	subq.l #1,d1			; til the end of the old block
	bne.s .lb2
	bsr mfree				; a2 is the adress of the old one	
.lb3:
	asl.l #2,d5				; the offset for the first chunkoff to fill
	move.l chunkoffs,a5
	add.l d5,a5				; adress of the first chunkoff
.lb4:	
	bsr read_long			; reads one chunkoff
	move.l d0,(a5)+	   ; and stores it
	subq.l #1,d4			; another samp_size?
	bne .lb4					; yes, loop
	rts

; MOV files in VR format!!!!

vr_read_data:
	bsr find_offs_size_time
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr	; we're in supervisor mode!
	sf vr_clic
	clr.l vr_keys
	move vr_sx,d6
	ext.l d6
	move vr_sy,d7
	ext.l d7
	XBIOS 34,2
	move.l d0,a0			; kvdbase
	tst.b vr_clic+1
	bne vr_read_data_mouse
	lea 32(a0),a0
	move.l (a0),old_ikbd
	move.l #vr_ikbd,(a0)+
	move.l a0,ikbdstate
.loop:
	bsr first_of_cell
.go_on_cell:
	move.l $4ba.w,d3
	SEEK (a3)+,0				; offset
	move.l buffer,-(sp)
	move.l (a5)+,d0
	move.l d0,bufused
	move.l d0,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; fread!
	movem.l d3-d4/d6-d7/a3-a5,-(sp)	; saves registers
	move.l compression,a0
	jsr (a0)					; decodes and displays
	move.l display_ste,a0
	jsr (a0)	
	movem.l (sp)+,d3-d4/d6-d7/a3-a5
	move.l (a4)+,d0
	move.l kbshift,a1
	move.b (a1),d2
	and.b #3,d2
	beq.s .no_fast
	lsr.l #2,d0
.no_fast:
	add.l d0,d3
.delay:
	cmp.l $4ba.w,d3
	bpl.s .delay
	lea vr_keys(pc),a2
.wait:
	btst #2,(a1)	; Control key to stop
	bne .stop
	move.l (a2),d0
	bne.s .a_key
	tst.l d4
	bmi.s .wait		; one image per frame
	dbf d4,.go_on_cell
	bra .loop
.a_key:
	movem vr_y,d1-d2
	btst #23,d0
	beq.s .key1
	subq #1,d7		; down
	bpl .loop
	tst d2
	bne.s ._k0
	moveq #0,d7
	bra .wait
._k0:
	add d1,d7
	bra .loop
.key1:
	btst #31,d0
	beq.s .key2
	addq #1,d7		; up
	cmp d1,d7
	bmi .loop
	subq #1,d7
	tst d2
	beq .wait
	moveq #0,d7
	bra .loop
.key2:
	movem vr_x,d1-d2
	btst #15,d0
	beq.s .key3
	subq #1,d6		; $4D=RIGHT
	bpl .loop
	tst d2
	bne.s ._k2
	moveq #0,d6
	bra .wait
._k2:
	add d1,d6
	bra .loop
.key3:
	btst #7,d0
	beq .wait
	addq #1,d6		; $4B=LEFT
	cmp d1,d6
	bmi .loop
	subq #1,d6
	tst d2
	beq .wait
	moveq #0,d6
	bra .loop
.stop:
	st stopped
	XBIOS 34,2
	move.l d0,a0
	move.l old_ikbd,32(a0)
	move.l stack_adr,-(sp)
	GEMDOS 32,6					; returns to user mode
	rts

vr_clic: dc.b 0,0
vr_keys: dc.b 0,0,0,0

vr_ikbd:
	move.l ikbdstate,a0
	tst.b (a0)
	beq.s .testons
.adios:
	move.l old_ikbd,-(sp)
.rien:
	rts
.erreur:
	btst #5,d2
	beq.s .rien
	move.b 2(a1),d0
	move.l ikbdstate,a0
	move.l -32(a0),-(sp)
	rts
.testons:
	lea $FFFFFC00.w,a1
	move.b (a1),d2
	bpl.s .rien
	btst #0,d2
	beq.s .erreur
	move.b 2(a1),d0
	lea vr_keys(pc),a0
	cmp.b #$48,d0
	bne.s .lb0
.vrai:
	st (a0)
	rts
.lb0:
	cmp.b #$c8,d0
	bne.s .lb1
.faux:
	sf (a0)
	rts
.lb1:
	addq.l #1,a0
	cmp.b #$50,d0
	beq.s .vrai
	cmp.b #$D0,d0
	beq.s .faux
	addq.l #1,a0
	cmp.b #$4D,d0
	beq.s .vrai
	cmp.b #$CD,d0
	beq.s .faux
	addq.l #1,a0
	cmp.b #$4B,d0
	beq.s .vrai
	cmp.b #$CB,d0
	beq.s .faux
	move.l kbshift,a0
	moveq #2,d1
	cmp.b #$1D,d0
	bne.s .lb2
.vrai2:
	bset d1,(a0)
	rts
.lb2:
	cmp.b #$9D,d0
	bne.s .lb3
.faux2:
	bclr d1,(a0)
	rts
.lb3:
	moveq #0,d1
	cmp.b #$2a,d0
	beq.s .vrai2
	cmp.b #$aa,d0
	beq.s .faux2
	moveq #1,d1
	cmp.b #$36,d0
	beq.s .vrai2
	cmp.b #$b6,d0
	beq.s .faux2
	rts

first_of_cell:
	move vr_x,d3
	muls d7,d3
	add.l d6,d3				; index of the cell
	move vr_info,d4
	ext.l d4
	muls d4,d3			; index of the image
	lsl.l #2,d3
	move.l s_buffer,a3
	move.l t2samps,a4
	move.l samp_sizes,a5
	add.l d3,a3
	add.l d3,a4
	add.l d3,a5
	subq #1,d4
	bne.s .end
	bset #31,d4
.end:
	rts

find_offs_size_time:
	move.l sample_num,d1
	lsl.l #2,d1
	bsr malloc
	move.l d0,s_buffer
	move.l d0,a3
	moveq #0,d6				; current samp
	moveq #0,d5				; current s2chunk
	move.l s2chunks,a4
	move.l 12(a4),a5		; next s2chunk
	move.l 8(a4),d4		; tag
	move.l d4,d0
	asl.l #4,d0				; each codec 16 bytes
	move.l codecs,a2
	move.l (a2,d0.l),imagex
	move.l 4(a2,d0.l),imagey
	move.l 8(a2,d0.l),depth
	tst.b is_tt
	bne.s .tt
	move.l 12(a2,d0.l),compression
	bra.s .no_tt
.tt:
	move.l 12(a2,d0.l),tt_comp
.no_tt:
	moveq #-1,d7				; i for the loop
	bra .end_of_loop
.loop:
	move.l chunkoffs,a0
	move.l d7,d1
	lsl.l #2,d1
	move.l 0(a0,d1.l),d3
	move.l d5,d1
	add.l d1,d1
	add.l d5,d1
	lsl.l #2,d1
	cmp.l d7,a5				; jumps if i<>next_s2chunk
	bne.s .lb4
	move.l d5,d0
	addq.l #1,d0
	sub.l s2chunk_num,d0	; jumps if cur_s2chunk + 1 >= s2chunk_num
	bpl.s .lb4
	addq.l #1,d5			; cur_s2chunk++
	addq.l #8,d1
	addq.l #4,d1			; one bloc more
	move.l 12(a4,d1.l),a5
.lb4:
	move.l 4(a4,d1.l),d2	; num samps
	cmp.l 8(a4,d1.l),d4	; tags equals?
	beq .end_of_samps	; yes, that's ok
	move.l 8(a4,d1.l),d4	; new tag
	move.l d4,d0
	asl.l #4,d0				; each codec 16 bytes
	move.l 0(a2,d0.l),imagex
	move.l 4(a2,d0.l),imagey
	move.l 8(a2,d0.l),depth
	move.l 12(a2,d0.l),compression	
	bra .end_of_samps
.samp_loop:
	cmp.l sample_num,d6	; exit if cur_samp>=sample_num
	bpl .out
	move.l samp_sizes,a0
	move.l d6,d1
	lsl.l #2,d1
	move.l 0(a0,d1.l),d1
	addq.l #1,d6
	move.l d3,(a3)+		; new offset
	add.l d1,d3				; next one
	move.l t2samps,a0
	move.l d6,d1
	lsl.l #2,d1
	lea 0(a0,d1.l),a0
	move.l (a0),d1			; end time
	bclr #31,d1
	move.l -(a0),d0		; start time
	clr.l (a0)
	tst.b sync
	beq.s .end_of_samps
	bclr #31,d0
	sub.l d0,d1				; duration
	move.l d1,(a0)
.end_of_samps:
	subq.l #1,d2
	bpl .samp_loop	
.end_of_loop:
	addq.l #1,d7			; inc i
	cmp.l chunkoff_num,d7
	bmi .loop
.out:
	rts
	
vr_mouse:
	movem.l d0-d1/a1,-(sp)
	move.b (a0)+,d0
	and.b #3,d0					; buttons
	move.b d0,vr_clic
	lea vr_keys(pc),a1
	clr.l (a1)
	move.b (a0)+,d0
	ext.w d0						; X movement
	sgt 2(a1)
	smi 3(a1)
	bpl.s .test_y
	neg d0						; absoluteddx
.test_y:
	move.b (a0)+,d1
	ext.w d1
	sgt 1(a1)
	smi (a1)
	bpl.s .next
	neg d1						; absolute dy
.next:
	cmp d0,d1
	bpl.s .keep_y
	clr (a1)						; dx>dy, clear Y infos
	bra.s .fin
.keep_y:
	clr 2(a1)					; dy>dx, clear X infos
.fin:
	movem.l (sp)+,d0-d1/a1
	rts
		
vr_read_data_mouse:
	move.l 16(a0),old_ikbd
	move.l #vr_mouse,16(a0)
.loop:
	bsr first_of_cell
.go_on_cell:
	move.l $4ba.w,d3
	SEEK (a3)+,0				; offset
	move.l buffer,-(sp)
	move.l (a5)+,d0
	move.l d0,-(sp)
	move.l d0,bufused
	move mov_h,-(sp)
	GEMDOS 63,12			; fread!
	movem.l d3-d4/d6-d7/a3-a5,-(sp)	; saves registers
	move.l compression,a0
	jsr (a0)					; decodes and displays
	move.l display_ste,a0
	jsr (a0)	
	movem.l (sp)+,d3-d4/d6-d7/a3-a5
	move.l (a4)+,d0
	move.l kbshift,a1
	move.b vr_clic,d2
	beq.s .no_fast
	lsr.l #2,d0
.no_fast:
	add.l d0,d3
.delay:
	cmp.l $4ba.w,d3
	bpl.s .delay
	lea vr_keys(pc),a2
.wait:
	btst #2,(a1)	; Control key to stop
	bne .stop
	move.l (a2),d0
	bne.s .a_key
	tst.l d4
	bmi.s .wait		; one image per frame
	dbf d4,.go_on_cell
	bra .loop
.a_key:
	clr.l (a2)		; read once, then cleared
	movem vr_y,d1-d2
	btst #23,d0
	beq.s .key1
	subq #1,d7		; down
	bpl .loop
	tst d2
	bne.s ._k0
	moveq #0,d7
	bra .wait
._k0:
	add d1,d7
	bra .loop
.key1:
	btst #31,d0
	beq.s .key2
	addq #1,d7		; up
	cmp d1,d7
	bmi .loop
	subq #1,d7
	tst d2
	beq .wait
	moveq #0,d7
	bra .loop
.key2:
	movem vr_x,d1-d2
	btst #15,d0
	beq.s .key3
	subq #1,d6		; $4D=RIGHT
	bpl .loop
	tst d2
	bne.s ._k2
	moveq #0,d6
	bra .wait
._k2:
	add d1,d6
	bra .loop
.key3:
	btst #7,d0
	beq .wait
	addq #1,d6		; $4B=LEFT
	cmp d1,d6
	bmi .loop
	subq #1,d6
	tst d2
	beq .wait
	moveq #0,d6
	bra .loop
.stop:
	st stopped
	XBIOS 34,2
	move.l d0,a0
	move.l old_ikbd,16(a0)
	move.l stack_adr,-(sp)
	GEMDOS 32,6					; returns to user mode
	rts

	
; here d3 is used for synchro:
; d3.b:  $FF if synchro, $00 if no synchro
; bit #15: set if a frame has been skipped (display was late)
; bit #31: set if it's a particlar frame (whole screen built), cleared if
;			  the frame is a partial update of the screen.
; bit #16: if set, never skip a key frame
; bit #8	: set when the sound doesn't fit into ST Ram and that there's
;			  a remaining into TT Ram.

areu:
qt_read_data:
	tst.b vr_flag
	bne vr_read_data
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr	; we're in supervisor mode!
.disp_again:
	moveq #0,d3				; resets bits #31, #15, #8
	tst.b playing			; is there a sound?
	beq.s .no_sound
	bsr start_sound
.no_sound:	
	tst.l samp_sizes
	beq .out
	tst.b bad_comp			; compression supported?
	bne .out					; no, only sound!	
	move.b sync,d3
	beq.s .lb0				; no synchronisation
	move.l t2samps,a6		; the sync table
	addq.l #4,a6			; jumps over the dummy address
	tst.b sync+1			; can we skip a key frame?
	beq.s .lb0				; no!
	bset #16,d3	
.lb0:
	move.l $4BA.w,start_time	; Timer C counter (1/200)
	moveq #0,d6				; current samp
	moveq #0,d5				; current s2chunk
	move.l s2chunks,a4
	move.l 12(a4),a5		; next s2chunk
	move.l 8(a4),d4		; tag
	move.l d4,d0
	asl.l #4,d0				; each codec 16 bytes
	move.l codecs,a2
	move.l (a2,d0.l),imagex
	move.l 4(a2,d0.l),imagey
	move 6(a2,d0.l),flx_number
	move.l 8(a2,d0.l),depth
	clr flx_start
	tst.b is_tt
	bne.s .tt
	move.l 12(a2,d0.l),compression
	bra.s .no_tt
.tt:
	move.l 12(a2,d0.l),tt_comp
.no_tt:
	moveq #-1,d7				; i for the loop
	bra .end_of_loop
.loop:
	move.l d7,d0
	asl.l #2,d0
	move.l chunkoffs,a0
	move.l 0(a0,d0.l),d0
	SEEK d0,0	; start of chunk data
	move.l d5,d1
	move.l d1,d0
	add.l d0,d0
	add.l d0,d1				; *3
	asl.l #2,d1				; *4 = *12
	cmp.l d7,a5				; jumps if i<>next_s2chunk
	bne.s .lb4
	move.l d5,d0
	addq.l #1,d0
	sub.l s2chunk_num,d0	; jumps if cur_s2chunk + 1 >= s2chunk_num
	bpl.s .lb4
	addq.l #1,d5			; cur_s2chunk++
	addq.l #8,d1
	addq.l #4,d1			; one bloc more
	move.l 12(a4,d1.l),a5
.lb4:
	move.l 4(a4,d1.l),d2	; num samps
	cmp.l 8(a4,d1.l),d4	; tags equals?
	beq .end_of_samps	; yes, that's ok
	move.l 8(a4,d1.l),d4	; new tag
	move.l d4,d0
	asl.l #4,d0				; each codec 16 bytes
	move.l (a2,d0.l),imagex
	move.l 4(a2,d0.l),imagey
	move 6(a2,d0.l),flx_number
	move.l 8(a2,d0.l),depth
	move.l 12(a2,d0.l),compression	
	clr flx_start
	bra .end_of_samps
.samp_loop:
	move.l samp_sizes,a0
	move.l d6,d0
	asl.l #2,d0
	move.l 0(a0,d0.l),bufused	; size used for the current sample
	cmp.l sample_num,d6	; exit if cur_samp>=sample_num
	bpl .out
	addq.l #1,d6
	tst.w d3					; sync?
	beq.s .lb1				; no synchro
	bpl.s .pos
	tst.l d3					; bit 31 marked if particular
	bpl.s .skip				; can't come back with a non particular frame
	btst #16,d3				; key frame can be skipped?
	bne.s .lb1				; no, so display it!
	bra.s .pos1
.pos:
	tst.l d3
	bpl.s .pos1				; not a key frame
	btst #16,d3
	bne.s .lb1				; a key frame must be displayed
.pos1:	
	move.l $4ba.w,d1
	sub.l start_time,d1
	cmp.l d1,a3				; address passed?
	bpl.s .lb1				; not yet
	tst d3
	bmi.s .skip
	move.l a6,a0
.search:
	tst.b (a0)				; high byte marked?
	bmi.s .found
	addq.l #4,a0
	bra.s .search
.found:
	move.l -(a0),d0		; the last address for this group
	bclr #31,d0
	cmp.l d1,d0				; passed?
	bpl.s .lb1				; not yet, continue!
	bset #15,d3				; a frame has been skipped
.skip:
	movem.l d2/a2,-(sp)
	SEEK bufused,1			; yes, passed, skip this frame	
	movem.l (sp)+,d2/a2
	bra.s .end_of_samps
.lb1:
	bclr #15,d3
	movem.l d2-d7/a2-a6,-(sp)	; saves registers
	move.l buffer,-(sp)
	move.l bufused,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; fread!
	tst.b 7(sp)				; sync (d3 on the stack)
	beq.s .lb2
	move.l 40(sp),a0		; a6 on the stack
	move.l -8(a0),d0		; time for previous frame
;	bpl.s .ageu
	bclr #31,d0
;.ageu:
;	move.l start_time,a0
;	add.l d0,a0
	add.l start_time,d0
.lb3:
;	cmp.l $4ba.w,a0		; yes, is the previous frame ended?
	cmp.l $4ba.w,d0
	bpl.s .lb3				; not yet.
.lb2:
	addq.l #1,disp_frame	; counts the frames displayed
	move.l compression,a0
	jsr (a0)					; decodes into virtual
	move.l display_ste,a0
	jsr (a0)					; and displays
.next:
	movem.l (sp)+,d2-d7/a2-a6
	move.l kbshift,a0
	btst #2,(a0)	; Control key to stop
	bne.s .out3
.end_of_samps:
	tst.b d3
	beq.s .nosync
	bclr #31,d3
	move.l (a6)+,d0
	bpl.s .no_part
	bset #31,d3					; it's a particular frame (whole screen built)
	bclr #31,d0
.no_part:
	move.l d0,a3			; next step (for the synchro)
.nosync:
	subq.l #1,d2
	bpl .samp_loop	
	subq.l #4,a6		
.end_of_loop:
	addq.l #1,d7			; inc i
	cmp.l chunkoff_num,d7
	bmi .loop
.out:
	move.l kbshift,a0
	btst #2,(a0)			; control key to stop
	beq.s .out2
.out3:
	st stopped						; stopped, no stats displayed
	tst.b _snd
	bmi.s .dma_out2
	move sr,d0
	move #$2700,sr
	move.l yamaha_ptr,a0
	clr.b (a0)+
	clr.b (a0)
	move d0,sr
	bra.s .out
.dma_out2:	
	clr.b $ffff8901.w
.out2:
	tst.b _snd
	bpl.s .end_yam
	btst #0,$FFFF8901.w
	bne.s .out
	bra.s .test_repeat
.end_yam:
	tst.b yamaha_flag
	bne.s .out
.test_repeat:
	tst.b stopped
	bne.s .end
	tst.b is_rep
	bne .disp_again	
.end:
	move.l $4ba.w,end_time
	move.l stack_adr,-(sp)
	GEMDOS 32,6					; returns to user mode
	rts
	
start_sound:
	lea s_buffer,a0	
	tst.b _snd
	bpl yamaha_start_sound
	addq.l #1,a0
	move.b (a0)+,$ffff8903.w
	move.b (a0)+,$ffff8905.w
	move.b (a0),$ffff8907.w	; start address
	lea snd_end+1,a0
	move.b (a0)+,$ffff890f.w
	move.b (a0)+,$ffff8911.w
	move.b (a0),$ffff8913.w	; end address
	moveq #0,d0				; sound mode control
	cmp #2,channels
	beq.s .s1				; stereo, bit 7 is 0
	moveq #-128,d0			; else, bit 7 is 1
.s1:
	move.l frequency,d1
	addq #1,d0				; 1 for 12,5 kHz
	cmp.l #12517,d1
	beq.s .start
	addq #1,d0
	cmp.l #25033,d1		; 2 for 25 kHz
	beq.s .start
	addq #1,d0				; else 3 for 50 kHz
.start:
	move.b d0,$ffff8921.w		; sound mode control
	move.b #1,$ffff8901.w		; starts the sound!
	rts


vq_extnd: dc.l ve_cont,ve_int,dum,intout,ptsout

	
flm_start_sound:
	lea snd_temp,a0
	tst.b _snd
	bpl.s yamaha_start_sound	; no DMA!!!!
	clr.b $ffff8901.w
	addq.l #1,a0
	move.b (a0)+,$ffff8903.w
	move.b (a0)+,$ffff8905.w
	move.b (a0),$ffff8907.w	; start address
	lea flm_snd_end+1,a0
	move.b (a0)+,$ffff890f.w
	move.b (a0)+,$ffff8911.w
	move.b (a0),$ffff8913.w	; end address
	moveq #0,d0				; sound mode control
	cmp #2,channels
	beq.s .s1				; stereo, bit 7 is 0
	moveq #-128,d0			; else, bit 7 is 1
.s1:
	move.l frequency,d1
	addq #1,d0				; 1 for 12,5 kHz
	cmp.l #12517,d1
	beq.s .start
	addq #1,d0
	cmp.l #25033,d1		; 2 for 25 kHz
	beq.s .start
	addq #1,d0				; else 3 for 50 kHz
.start:
	move.b d0,$ffff8921.w		; sound mode control
	move.b #1,$ffff8901.w		; starts the sound!
	rts

yamaha_start_sound:
	move.l (a0),yamaha_ptr
	move sr,d0
	move.w	#$2700,sr
	move.l	#inull,$134.w
	lea $ffff8800.w,a0
	lea 2(a0),a1
	move.b	#0,(a0)
	move.b	#0,(a1)
	move.b	#1,(a0)
	move.b	#0,(a1)
	move.b	#2,(a0)
	move.b	#0,(a1)
	move.b	#3,(a0)
	move.b	#0,(a1)
	move.b	#4,(a0)
	move.b	#0,(a1)
	move.b	#5,(a0)
	move.b	#0,(a1)
	move.b	#7,(a0)
	move.b	#$FF,(a1)
	move.b	#8,(a0)
	move.b	#0,(a1)
	move.b	#9,(a0)
	move.b	#0,(a1)
	move.b	#10,(a0)
	move.b	#0,(a1)
	lea .replay_tab(pc),a1
	moveq #0,d1
	move.b _snd,d1
	add d1,d1
	add d1,d1
	move.l 0(a1,d1.w),a1		; adresse of the routine
	st yamaha_flag	
	lea $fffffa00.w,a0					; save MFP
	bclr #5,7(a0)
	bclr #5,$13(a0)
 	move.b	#64,$1F(a0)		; data
	move.b	#1,$19(a0)		; control
	move.l	a1,$134.w
	bclr.b	#3,$17(a0)
	bset #5,7(a0)
	bset #5,$13(a0)
	move.w	d0,sr
	rts
.replay_tab: dc.l yamaha_replay,mv_16,replay_8,replay_16

yamaha_ptr: dc.l 0

inull: rte

replay_16:	
	move.l a0,-(sp)
	move d0,-(sp)
	move.l yamaha_ptr(pc),a0
	move.b (a0)+,d0
	beq.s .end_replay
	move.l a0,yamaha_ptr
	lsl #8,d0
	move.l #$fffa8000,a0
	move.w 0(a0,d0.w),d0
.exit_int:
	move (sp)+,d0
	move.l (sp)+,a0
	rte
.end_replay:
	bsr stop_timer
	bra.s .exit_int

replay_8:	
	move.l a0,-(sp)
	move d0,-(sp)
	move.l yamaha_ptr(pc),a0
	clr d0
	move.b (a0)+,d0
	beq.s .end_replay
	move.l a0,yamaha_ptr
	add d0,d0
	move.l #$fa0100,a0
	move.b 0(a0,d0.w),d0
.exit_int:
	move (sp)+,d0
	move.l (sp)+,a0
	rte
.end_replay:
	bsr stop_timer
	bra.s .exit_int		
	
stop_timer:
	move sr,d0
	move #$2700,sr
	lea $fffffa00.w,a0
	bclr #5,7(a0)
	bclr #5,$b(a0)
	bclr #5,$f(a0)
	bclr #5,$13(a0)
	move.l #inull,$134.w
	sf yamaha_flag
	move d0,sr
	rts

mv_16:	
	move.l a0,-(sp)
	move d0,-(sp)
	move.l yamaha_ptr(pc),a0
	move.b (a0)+,d0
	beq.s .end_replay
	add.b #$80,d0
	and.b #$ff,d0
	move.l a0,yamaha_ptr
	add d0,d0
	move.l #$fa0100,a0
	move.b 0(a0,d0.w),d0
.exit_int:
	move (sp)+,d0
	move.l (sp)+,a0
	rte
.end_replay:
	bsr stop_timer
	bra.s .exit_int		
	
yamaha_replay:
	move.l a0,-(sp)
	move.l d0,-(sp)
	move d1,-(sp)
	move.l yamaha_ptr(pc),a0
	moveq #0,d0
	move.b (a0)+,d0
	beq.s .end_replay
	move.l a0,yamaha_ptr
	lsl.w #3,d0
	move.w yamaha_data+4(pc,d0.w),d1
	move.l yamaha_data(pc,d0.w),d0
	lea $ffff8800.w,a0
	movep.l d0,0(a0)
	movep.w d1,0(a0)	
.exit_int:
	move (sp)+,d1
	move.l (sp)+,d0
	move.l (sp)+,a0
	rte
.end_replay:
	bsr stop_timer
	bra.s .exit_int

yamaha_data:
	dc.w	$80C,$90B,$a09,0,$80C,$90B,$a09,0
	dc.w	$80D,$908,$a08,0,$80B,$90B,$a0B,0
	dc.w	$80D,$909,$a05,0,$80C,$90B,$a08,0
	dc.w	$80D,$909,$a02,0,$80D,$908,$a06,0
	dc.w	$80C,$90B,$a07,0,$80D,$907,$a07,0
	dc.w	$80C,$90B,$a06,0,$80C,$90A,$a09,0
	dc.w	$80B,$90B,$a0A,0,$80C,$90B,$a02,0
	dc.w	$80C,$90B,$a00,0,$80C,$90A,$a08,0

	dc.w	$80D,$906,$a04,0,$80D,$905,$a05,0
	dc.w	$80D,$905,$a04,0,$80C,$909,$a09,0
	dc.w	$80D,$904,$a03,0,$80B,$90B,$a09,0
	dc.w	$80C,$90A,$a05,0,$80B,$90A,$a0A,0
	dc.w	$80C,$909,$a08,0,$80B,$90B,$a08,0
	dc.w	$80C,$90A,$a00,0,$80C,$90A,$a00,0
	dc.w	$80C,$909,$a07,0,$80B,$90B,$a07,0
	dc.w	$80C,$909,$a06,0,$80B,$90B,$a06,0

	dc.w	$80B,$90A,$a09,0,$80B,$90B,$a05,0
	dc.w	$80A,$90A,$a0A,0,$80B,$90B,$a02,0
	dc.w	$80B,$90A,$a08,0,$80C,$907,$a07,0
	dc.w	$80C,$908,$a04,0,$80C,$907,$a06,0
	dc.w	$80B,$909,$a09,0,$80C,$906,$a06,0
	dc.w	$80A,$90A,$a09,0,$80C,$907,$a03,0
	dc.w	$80B,$90A,$a05,0,$80B,$909,$a08,0
	dc.w	$80B,$90A,$a03,0,$80A,$90A,$a08,0

	dc.w	$80B,$90A,$a00,0,$80B,$909,$a07,0
	dc.w	$80B,$908,$a08,0,$80A,$90A,$a07,0
	dc.w	$80A,$909,$a09,0,$80C,$901,$a01,0
	dc.w	$80A,$90A,$a06,0,$80B,$908,$a07,0
	dc.w	$80A,$90A,$a05,0,$80A,$909,$a08,0
	dc.w	$80A,$90A,$a02,0,$80A,$90A,$a01,0
	dc.w	$80A,$90A,$a00,0,$809,$909,$a09,0
	dc.w	$80A,$908,$a08,0,$80B,$908,$a01,0

	dc.w	$80A,$909,$a06,0,$80B,$907,$a04,0
	dc.w	$80A,$909,$a05,0,$809,$909,$a08,0
	dc.w	$80A,$909,$a03,0,$80A,$908,$a06,0
	dc.w	$80A,$909,$a00,0,$809,$909,$a07,0
	dc.w	$809,$908,$a08,0,$80A,$908,$a04,0
	dc.w	$809,$909,$a06,0,$80A,$908,$a01,0
	dc.w	$809,$909,$a05,0,$809,$908,$a07,0
	dc.w	$808,$908,$a08,0,$809,$909,$a02,0

	dc.w	$809,$908,$a06,0,$809,$909,$a00,0
	dc.w	$809,$907,$a07,0,$808,$908,$a07,0
	dc.w	$809,$907,$a06,0,$809,$908,$a02,0
	dc.w	$808,$908,$a06,0,$809,$906,$a06,0
	dc.w	$808,$907,$a07,0,$808,$908,$a04,0
	dc.w	$808,$907,$a06,0,$808,$908,$a02,0
	dc.w	$807,$907,$a07,0,$808,$906,$a06,0
	dc.w	$808,$907,$a04,0,$807,$907,$a06,0

	dc.w	$808,$906,$a05,0,$808,$906,$a04,0
	dc.w	$807,$906,$a06,0,$807,$907,$a04,0
	dc.w	$808,$905,$a04,0,$806,$906,$a06,0
	dc.w	$807,$906,$a04,0,$807,$905,$a05,0
	dc.w	$806,$906,$a05,0,$806,$906,$a04,0
	dc.w	$806,$905,$a05,0,$806,$906,$a02,0
	dc.w	$806,$905,$a04,0,$805,$905,$a05,0
	dc.w	$806,$905,$a02,0,$805,$905,$a04,0

	dc.w	$805,$904,$a04,0,$805,$905,$a02,0
	dc.w	$804,$904,$a04,0,$804,$904,$a03,0
	dc.w	$804,$904,$a02,0,$804,$903,$a03,0
	dc.w	$803,$903,$a03,0,$803,$903,$a02,0
	dc.w	$803,$902,$a02,0,$802,$902,$a02,0
	dc.w	$802,$902,$a01,0,$801,$901,$a01,0
	dc.w	$802,$901,$a00,0,$801,$901,$a00,0
	dc.w	$801,$900,$a00,0,$800,$900,$a00,0

	dc.w	$80E,$90D,$a0C,0,$80F,$903,$a00,0
	dc.w	$80F,$903,$a00,0,$80F,$903,$a00,0
	dc.w	$80F,$903,$a00,0,$80F,$903,$a00,0
	dc.w	$80F,$903,$a00,0,$80E,$90D,$a0B,0
	dc.w	$80E,$90D,$a0B,0,$80E,$90D,$a0B,0
	dc.w	$80E,$90D,$a0B,0,$80E,$90D,$a0B,0
	dc.w	$80E,$90D,$a0B,0,$80E,$90D,$a0B,0
	dc.w	$80E,$90D,$a0A,0,$80E,$90D,$a0A,0

	dc.w	$80E,$90D,$a0A,0,$80E,$90D,$a0A,0
	dc.w	$80E,$90C,$a0C,0,$80E,$90D,$a00,0
	dc.w	$80D,$90D,$a0D,0,$80D,$90D,$a0D,0
	dc.w	$80D,$90D,$a0D,0,$80D,$90D,$a0D,0
	dc.w	$80D,$90D,$a0D,0,$80D,$90D,$a0D,0
	dc.w	$80E,$90C,$a0B,0,$80E,$90C,$a0B,0
	dc.w	$80E,$90C,$a0B,0,$80E,$90C,$a0B,0
	dc.w	$80E,$90C,$a0B,0,$80E,$90C,$a0B,0

	dc.w	$80E,$90C,$a0B,0,$80E,$90C,$a0B,0
	dc.w	$80E,$90C,$a0A,0,$80E,$90C,$a0A,0
	dc.w	$80E,$90C,$a0A,0,$80E,$90C,$a0A,0
	dc.w	$80D,$90D,$a0C,0,$80D,$90D,$a0C,0
	dc.w	$80E,$90C,$a09,0,$80E,$90C,$a09,0
	dc.w	$80E,$90C,$a05,0,$80E,$90C,$a00,0
	dc.w	$80E,$90C,$a00,0,$80E,$90B,$a0B,0
	dc.w	$80E,$90B,$a0B,0,$80E,$90B,$a0B,0

	dc.w	$80E,$90B,$a0B,0,$80E,$90B,$a0A,0
	dc.w	$80E,$90B,$a0A,0,$80E,$90B,$a0A,0
	dc.w	$80D,$90D,$a0B,0,$80D,$90D,$a0B,0
	dc.w	$80D,$90D,$a0B,0,$80E,$90B,$a09,0
	dc.w	$80E,$90B,$a09,0,$80E,$90B,$a09,0
	dc.w	$80D,$90C,$a0C,0,$80D,$90D,$a0A,0
	dc.w	$80E,$90B,$a07,0,$80E,$90B,$a00,0
	dc.w	$80E,$90B,$a00,0,$80D,$90D,$a09,0

	dc.w	$80D,$90D,$a09,0,$80E,$90A,$a09,0
	dc.w	$80D,$90D,$a08,0,$80D,$90D,$a07,0
	dc.w	$80D,$90D,$a04,0,$80D,$90D,$a00,0
	dc.w	$80E,$90A,$a04,0,$80E,$909,$a09,0
	dc.w	$80E,$909,$a09,0,$80D,$90C,$a0B,0
	dc.w	$80E,$909,$a08,0,$80E,$909,$a08,0
	dc.w	$80E,$909,$a07,0,$80E,$908,$a08,0
	dc.w	$80E,$909,$a01,0,$80C,$90C,$a0C,0

	dc.w	$80D,$90C,$a0A,0,$80E,$908,$a06,0
	dc.w	$80E,$907,$a07,0,$80E,$908,$a00,0
	dc.w	$80E,$907,$a05,0,$80E,$906,$a06,0
	dc.w	$80D,$90C,$a09,0,$80E,$905,$a05,0
	dc.w	$80E,$904,$a04,0,$80D,$90C,$a08,0
	dc.w	$80D,$90B,$a0B,0,$80E,$900,$a00,0
	dc.w	$80D,$90C,$a06,0,$80D,$90C,$a05,0
	dc.w	$80D,$90C,$a02,0,$80C,$90C,$a0B,0

	dc.w	$80C,$90C,$a0B,0,$80D,$90B,$a0A,0
	dc.w	$80D,$90B,$a0A,0,$80D,$90B,$a0A,0
	dc.w	$80D,$90B,$a0A,0,$80C,$90C,$a0A,0
	dc.w	$80C,$90C,$a0A,0,$80C,$90C,$a0A,0
	dc.w	$80D,$90B,$a09,0,$80D,$90B,$a09,0
	dc.w	$80D,$90A,$a0A,0,$80D,$90A,$a0A,0
	dc.w	$80D,$90A,$a0A,0,$80C,$90C,$a09,0
	dc.w	$80C,$90C,$a09,0,$80C,$90C,$a09,0

	dc.w	$80D,$90B,$a06,0,$80C,$90B,$a0B,0
	dc.w	$80C,$90C,$a08,0,$80D,$90B,$a00,0
	dc.w	$80D,$90B,$a00,0,$80C,$90C,$a07,0
	dc.w	$80C,$90C,$a06,0,$80C,$90C,$a05,0
	dc.w	$80C,$90C,$a03,0,$80C,$90C,$a01,0
	dc.w	$80C,$90B,$a0A,0,$80D,$90A,$a05,0
	dc.w	$80D,$90A,$a04,0,$80D,$90A,$a02,0
	dc.w	$80D,$909,$a08,0,$80D,$909,$a08,0

ve_cont: dc.w 102,0,0,1,0,0,0,0,0,0,0,0
ve_int: dc.w 1	

qt_decode_256:
	move.l buffer,a2		; the datas
	clr x
	clr y
	clr y_top
	move max_imagex,d3
	addq #3,d3
	and.b #$FC,d3
	move d3,d4
	subq #4,d3
	asl #2,d4
	move max_imagex,d2
	addq #3,d2
	and.b #$fc,d2
	sub d2,d4	; y_inc
	move.l virtual,a3		; the screen
	
	move.l (a2)+,d2
	and.l #$FFFFFF,d2		; the len
	cmp.l bufused,d2		; compared to the expected len
	beq.s .lbgood
	addq.l #1,d2			; try to correct
	cmp.l bufused,d2		; correction failed?
	bne .out					; yes, we must get out!
.lbgood:
	addq.l #4,a2
	moveq #0,d2
	move (a2)+,d2			; strips
	move.l cvid_map_num,d1
	cmp.l d2,d1
	bpl .lb1
	; verify cvid max strips
	move.l d1,d5
	lsl.l #2,d5
	lea cvid_maps0,a4
	add.l d5,a4
	lsr.l #2,d5
	lea cvid_vmap0,a5
	add.l d5,a5
.lb0:	
	move.l #2080,d0
	muls d5,d0
	add.l #cvid_fix1,d0
	move.l d0,24(a4)
	sf 6(a5)
	move.l #2080,d0
	muls d5,d0
	add.l #cvid_fix0,d0
	move.l d0,(a4)+
	sf (a5)+
	addq.l #1,d5
	cmp.l d2,d5
	bmi.s .lb0
.lb1:
	move.l d2,cvid_map_num
	moveq #0,d5								; kk for a loop
.lb2:
	lsl.l #2,d5
	lea cvid_maps0,a4
	move.l 0(a4,d5.l),a4
	lea cvid_maps1,a5
	move.l 0(a5,d5.l),a5
	lsr.l #2,d5
	lea cvid_vmap0,a6
	add.l d5,a6
	tst.b (a6)								; vmap = false?
	bne.s .lb5								; non, skip
	move.l a4,a1							; dest
	move.l d5,d0							
	bne.s .lb3
	move.l d2,d0
.lb3:
	subq.l #1,d0							; kk-1 or if kk=0, strips-1
	lsl.l #2,d0
	lea cvid_maps0,a0		; source
	move.l 0(a0,d0.l),a0
	st.b (a6)								; vmap=true
	moveq #63,d0
.lb4:
   move.l (a0)+,(a1)+	
	move.l (a0)+,(a1)+	
	move.l (a0)+,(a1)+	
	move.l (a0)+,(a1)+	
	move.l (a0)+,(a1)+	
	move.l (a0)+,(a1)+	
	move.l (a0)+,(a1)+	
	move.l (a0)+,(a1)+	
	dbf d0,.lb4
.lb5:		
	tst.b 6(a6)								; vmap = false?
	bne.s .lb8								; non, skip
	move.l a5,a1							; dest
	move.l d5,d0							
	bne.s .lb6
	move.l d2,d0
.lb6:
	subq.l #1,d0							; kk-1 or if kk=0, strips-1
	lsl.l #2,d0
	lea cvid_maps1,a0		; source
	move.l 0(a0,d0.l),a0
	st.b 6(a6)								; vmap=true
	moveq #63,d0
.lb7:
	move.l (a0)+,(a1)+	
	move.l (a0)+,(a1)+	
	move.l (a0)+,(a1)+	
	move.l (a0)+,(a1)+	
	move.l (a0)+,(a1)+	
	move.l (a0)+,(a1)+	
	move.l (a0)+,(a1)+	
	move.l (a0)+,(a1)+	
	dbf d0,.lb7
.lb8:		
	addq.l #2,a2
	moveq #0,d6
	move.b (a2)+,d6			; topsize
	ror #8,d6
	move.b (a2)+,d6
	addq.l #4,a2
	move.b (a2)+,d0			; y1
	ror #8,d0
	move.b (a2)+,d0
	addq.l #2,a2	
	add d0,y_top			; works better???
	subq.l #8,d6
	subq.l #4,d6			; topsize-12
	sub x,a3				; image-x
	clr x
.lb9:
	tst.l d6
	bmi .end_while
	beq .end_while		; while topsize>0
	move.b (a2)+,d0			; cid
	ror #8,d0
	move.b (a2)+,d0
	moveq #0,d1
	move.b (a2)+,d1			; csize
	ror #8,d1
	move.b (a2)+,d1
	sub.l d1,d6				; topsize-csize
	subq.l #4,d1
	cmp #$2000,d0
	beq.s .case0
	cmp #$2200,d0
	bne.s .next1
	move.l a5,a0				; cvid_map
	move.l cvid_map_num,d0
	lea cvid_vmap1,a6
	add.l d0,a6
	bra.s .lb10
.case0:	
	move.l a4,a0				; cvid_map
	move.l cvid_map_num,d0
	lea cvid_vmap0,a6
	add.l d0,a6
.lb10:
	subq.l #1,d0
	bmi.s .comm0
	cmp.l d0,d5
	seq.b -(a6)					; set true only vmap(kk)
	bra.s .lb10
.comm0:
	cmp.l #6,d1
	bmi .endcase	
.lb11:
	rept 2
	move.b (a2),d0
	ror #8,d0
	move.b (a2)+,d0
	swap d0
	move.b (a2),d0
	ror #8,d0
	move.b (a2)+,d0
	and.l #$F0F0F0F0,d0
	lsr.l d0
	move.l d0,(a0)+
	endr
	addq.l #2,a2				; skips cr
	subq.l #6,d1				; csize-6
	bmi .endcase
	bne.s .lb11					; again...
	bra .endcase
.next1:
	cmp #$2100,d0
	beq.s .case1
	cmp #$2300,d0
	bne .next2
	move.l a5,a0
	bra.s .gloups
.case1:
   move.l a4,a0
.gloups:
	move.l d2,-(sp)			; saves d2
.comm1:
	tst.l d1
	bmi.s .lb16
	beq.s .lb16					; while csize>0
	move.b (a2)+,d7
	ror #8,d7
	move.b (a2)+,d7
	swap d7
	move.b (a2)+,d7
	ror #8,d7
	move.b (a2)+,d7			; flag
	subq.l #4,d1				; csize-4
	moveq #31,d2				; mask
.lb15:
	btst d2,d7					; mask and flag?	
	beq.s .lb13
.lb12:
	rept 2
		move.b (a2),d0
		ror #8,d0
		move.b (a2)+,d0
		swap d0
		move.b (a2),d0
		ror #8,d0
		move.b (a2)+,d0
		and.l #$F0F0F0F0,d0
		lsr.l d0
		move.l d0,(a0)+
	endr
	addq.l #2,a2				; skips cr
	subq.l #6,d1				; csize-6
	bra.s .lb14
.lb13:
	addq.l #8,a0
.lb14:
	dbf d2,.lb15				; mask-1
	bra .comm1					; while csize
.lb16:
	move.l (sp)+,d2			; restores d2
	; verify csize=0
	bra .endcase
.next2:
	cmp #$3000,d0
	bne .next3
	move.l d2,-(sp)			; saves strips
.lb17:
	tst.l d1
	beq .lb22					
	bmi .lb22					; while csize>0
	move y,d0
	cmp y_top,d0
	bpl.s .lb22					; and while y < ytop
	move.b (a2)+,d7
	ror #8,d7
	move.b (a2)+,d7
	swap d7
	move.b (a2)+,d7
	ror #8,d7
	move.b (a2)+,d7			; flag
	subq.l #4,d1				; csize-4
	moveq #31,d2				; mask
.lb20:
	move y,d0
	cmp y_top,d0
	bpl.s .lb21
	btst d2,d7					; mask and flag?
	beq.s .lb23
	bsr qt_256_c4
	subq.l #4,d1				; csize-4
	bra.s .lb18
.lb23:
	bsr qt_256_c1
	subq.l #1,d1
.lb18:
	addq #4,x
	addq.l #4,a3
	move x,d0
	cmp max_imagex,d0
	bmi.s .lb19
	clr x
	addq #4,y
	add d4,a3					; image + y_inc
.lb19:
	dbf d2,.lb20
.lb21:
	cmp.l #4,d1
	bpl.s .lb17
.lb22:
	add.l d1,a2					; dptr + csize
	move.l (sp)+,d2			; restores d2
	bra .endcase
.next3:
	cmp #$3200,d0
	bne .next4
.lb24:
	tst.l d1
	beq .lb25					
	bmi .lb25					; while csize>0
	move y,d0
	cmp y_top,d0
	bpl.s .lb25					; and while y < ytop
	bsr qt_256_c1
	subq.l #1,d1				; csize-1
	addq #4,x
	addq.l #4,a3
	move x,d0
	cmp max_imagex,d0
	bmi.s .lb24
	clr x
	addq #4,y
	add d4,a3					; image + y_inc
	bra.s .lb24
.lb25:
	add.l d1,a2					; dptr + csize
	bra .endcase
.next4:
	cmp #$3100,d0
	beq.s .case4
	cmp #$3300,d0
	bne .out
.case4:
	st flag0
	sf flag1
	sf flag2
	move.l d2,-(sp)			; saves strips
.lb26:
	tst.l d1
	beq .lb27					
	bmi .lb27					; while csize>0
	move y,d0
	cmp y_top,d0
	bpl .lb27					; and while y < ytop
	move.b (a2)+,d7
	ror #8,d7
	move.b (a2)+,d7
	swap d7
	move.b (a2)+,d7
	ror #8,d7
	move.b (a2)+,d7			; flag
	subq.l #4,d1				; csize-4
	moveq #31,d2				; mask
.lb28:
	move y,d0
	cmp y_top,d0
	bpl.s .lb26					; end d2 loop and go to while
	btst d2,d7					; mask and flag?
	bne.s .mcode23
	subq #1,d2
	btst d2,d7
	bne.s .mcode1
	st flag0						; here mcode = 00
	tst.b flag1
	beq.s .lb29
	bsr qt_256_c1
	subq.l #1,d1	
.lb29:
	sf flag1
.lb33:
	addq #4,x
	addq.l #4,a3
	move x,d0
	cmp max_imagex,d0
	bmi.s .end_mcode
	clr x
	addq #4,y
	add d4,a3					; image + y_inc
	bra.s .end_mcode
.mcode1:							; here mcode = 01
	st flag1
	tst.b flag2
	bne.s .lb30
	tst.b flag0
	beq.s .lb31
.lb30:
	sf flag0
	sf flag2
	bra.s .end_mcode
.lb31:
	bsr qt_256_c1
	subq.l #1,d1
	bra.s .end_mcode
.mcode23:
	subq #1,d2
	btst d2,d7
	bne.s .mcode3
	st flag2						; here mcode = 10 (2)
	tst.b flag1
	beq.s .lb31
	bsr qt_256_c4
	subq.l #4,d1
	bra.s .lb29
.mcode3:							; here mcode = 11 (3)
	bsr qt_256_c4
	subq.l #4,d1
.end_mcode:
	addq #4,x
	addq.l #4,a3
	move x,d0
	cmp max_imagex,d0
	bmi.s .lb32
	clr x
	addq #4,y
	add d4,a3					; image + y_inc
.lb32:
	dbf d2,.lb28				; end of d2 loop
	bra .lb26					; returns to while
.lb27:
	add.l d1,a2					; dptr + csize
	move.l (sp)+,d2			; restores d2
	bra .endcase	

.next5:
	nop
	
.endcase:
	bra .lb9
.end_while:
	addq.l #1,d5			; kk++
	cmp.l d2,d5
	bmi .lb2					; loops if kk<strips		
.out:
	rts

qt_256_c4:
	moveq #0,d0
	move.b (a2)+,d0		; d0
	lsl #3,d0
	lea 0(a4,d0.w),a0	; cv_map_d0
	moveq #0,d0
	move.b (a2)+,d0		; d1
	lsl #3,d0
	lea 0(a4,d0.w),a1	; cv_map_d1
	move.l a3,a6			; ip_ptr
	move.b (a0),(a6)+
	move.b 2(a0),(a6)+
	move.b (a1),(a6)+
	move.b 2(a1),(a6)+
	add d3,a6
	move.b 4(a0),(a6)+
	move.b 6(a0),(a6)+
	move.b 4(a1),(a6)+
	move.b 6(a1),(a6)+
	add d3,a6
	moveq #0,d0
	move.b (a2)+,d0		; d2
	lsl #3,d0
	lea 0(a4,d0.w),a0	; cv_map_d3
	moveq #0,d0
	move.b (a2)+,d0		; d4
	lsl #3,d0
	lea 0(a4,d0.w),a1	; cv_map_d4
	move.b (a0),(a6)+
	move.b 2(a0),(a6)+
	move.b (a1),(a6)+
	move.b 2(a1),(a6)+
	add d3,a6
	move.b 4(a0),(a6)+
	move.b 6(a0),(a6)+
	move.b 4(a1),(a6)+
	move.b 6(a1),(a6)
	rts
	
qt_256_c1:
	moveq #0,d0
	move.b (a2)+,d0		; d
	lsl #3,d0
	lea 0(a5,d0.w),a0		; cv_map_d
	move.l a3,a6			; the screen
	move.l (a0)+,d0		; d0 up and d1 down
	move.l d0,(a6)+
	add d3,a6				;+ row_inc
	move.l d0,(a6)+
	add d3,a6				;+ row_inc
	move.l (a0),d0			; d0 up and d1 down
	move.l d0,(a6)+
	add d3,a6				;+ row_inc
	move.l d0,(a6)
	rts

qt_smc_256:
	move #-1,first_time	; et first_time+1
	clr flx_start
	lea colors256,a6
	clr x
	clr y
	clr smc_8
	clr smc_a
	clr smc_c
	move max_imagex,d3
	subq #4,d3
	move.l buffer,a2
	move.l (a2)+,d0
	and.l #$ffffff,d0
	cmp.l bufused,d0
	bmi.s .ok_size
	move.l bufused,d0
.ok_size:
	subq.l #5,d0
.while:
	tst.b first_time+1
	beq.s .lb00
	sf first_time+1
	move y,flx_number
	tst x
	beq.s .lb00
	addq #4,flx_number
.lb00:
	tst.l d0
	bpl.s .lb0
	move flx_start,d0
	sub d0,flx_number
	rts
.lb0:
	moveq #0,d1
	move.b (a2)+,d1			; code
	subq.l #1,d0				; len--
	cmp #$20,d1
	bpl.s .case2
	cmp #$10,d1
	bmi.s .lb1
	move.b (a2)+,d1			; cnt if hicode=1
	subq.l #1,d0
	bra.s .lb2
.lb1:
	and #$f,d1					; cnt if hicode=0
.lb2:
	move max_imagex,d2
.lb3:
	addq #4,x
	cmp x,d2
	bgt.s .lb4
	clr x
	addq #4,y
	tst.b first_time
	beq.s .lb4
	addq #4,flx_start
.lb4:
	dbf d1,.lb3
	bra .while
.case2:
	move #$00ff,first_time
	cmp #$40,d1
	bpl.s .case4
	cmp #$30,d1
	bmi.s .lb5
	move.b (a2)+,d1
	subq.l #1,d0
	bra.s .lb6
.lb5:
	and #$f,d1
.lb6:
	move.l virtual,a3
	move y,d2
	muls max_imagex,d2
	add.l x-2,d2
	add.l d2,a3
	lea -4(a3),a4
	tst x
	bne.s .lb7
	move max_imagex,d2
	asl #2,d2
	sub d2,a4
	add d3,a4
	addq.l #4,a4
.lb7:
	bsr qt_smc_o2i_256
	dbf d1,.lb7
	bra .while	
.case4:
	cmp #$60,d1
	bpl .case6
	cmp #$50,d1
	bmi.s .lb8
	move.b (a2)+,d1
	subq.l #1,d0
	bra.s .lb9
.lb8:
	and #$f,d1
.lb9:	
	move.l virtual,a3
	move y,d2
	muls max_imagex,d2
	add.l x-2,d2
	add.l d2,a3
	lea -8(a3),a5
	move x,d4				; mtx
	move y,d5				; mty
	subq #8,d4
	bpl.s .lb10
	add max_imagex,d4
	subq #4,d5
	move max_imagex,d2
	asl #2,d2
	sub d2,a5
	add d3,a5
	addq.l #4,a5
.lb10:
	move.l a5,a4
	moveq #0,d6
	move d4,d6
	move d5,d7
	bsr qt_smc_o2i_256
	addq #4,d6
	addq.l #4,a4
	move max_imagex,d2
	cmp d6,d2
	bgt.s .lb11
	moveq #0,d6
	addq #4,d7
	move.l virtual,a3
	move d7,d2
	muls max_imagex,d2
	add.l d6,d2
	add.l d2,a4
.lb11:
	bsr qt_smc_o2i_256
	dbf d1,.lb10
	bra .while
.case6:
	cmp #$80,d1
	bpl.s .case8
	cmp #$70,d1
	bmi.s .lb12
	move.b (a2)+,d1
	subq.l #1,d0
	bra.s .lb13
.lb12:
	and #$f,d1
.lb13:
	moveq #0,d4
	move.b (a2)+,d4
	move.b 0(a6,d4.w),d4			; grey offset
	move.b d4,d2
	lsl #8,d4
	move.b d2,d4
	move d4,d2
	swap d4
	move d2,d4					; into high word
	subq.l #1,d0
	move.l virtual,a3
	move y,d2
	muls max_imagex,d2
	add.l x-2,d2
	add.l d2,a3
.lb14:
	bsr qt_smc_c1_256
	dbf d1,.lb14
	bra .while	
.case8:
	cmp #$a0,d1
	bpl .casea
	lea cvid_fix1,a0
	moveq #0,d2
	cmp #$90,d1
	bpl.s .lb15
	move.b smc_8+1,d2
	add d2,d2
	add d2,a0
	addq #1,smc_8
	moveq #0,d2
	move.b (a2)+,d2
	move.b 0(a6,d2.w),(a0)
	move.b (a2)+,d2
	move.b 0(a6,d2.w),1(a0)
	subq.l #2,d0
	bra.s .lb16
.lb15:
	move.b (a2)+,d2
	add d2,d2
	add d2,a0
	subq.l #1,d0
.lb16:
	move.l virtual,a3
	move y,d2
	muls max_imagex,d2
	add.l x-2,d2
	add.l d2,a3
	and #$f,d1
	move.b (a0)+,d4
	move.b (a0)+,d5
.lb17:
	move.l a3,a0
	move.b (a2)+,d6		; msk0
	bsr qt_smc_c2_256
	move.b (a2)+,d6		; msk1
	add d3,a0
	bsr qt_smc_c2_256
	subq.l #2,d0
	addq #4,x
	addq.l #4,a3
	move max_imagex,d2
	cmp x,d2
	bgt.s .lb18
	clr x
	addq #4,y
	move.l virtual,a3
	move y,d2
	muls max_imagex,d2
	add.l x-2,d2
	add.l d2,a3
.lb18:
	dbf d1,.lb17
	bra .while
.casea:
	cmp #$c0,d1
	bpl .casec
	lea cvid_fix1+1024,a0
	moveq #0,d2
	cmp #$b0,d1
	bpl.s .lb19
	move.b smc_a+1,d2
	asl #2,d2
	add d2,a0
	addq #1,smc_a
	moveq #0,d2
	move.b (a2)+,d2
	move.b 0(a6,d2.w),(a0)+
	move.b (a2)+,d2
	move.b 0(a6,d2.w),(a0)+
	move.b (a2)+,d2
	move.b 0(a6,d2.w),(a0)+
	move.b (a2)+,d2
	move.b 0(a6,d2.w),(a0)
	subq.l #3,a0
	subq.l #4,d0
	bra.s .lb20
.lb19:
	move.b (a2)+,d2
	asl #2,d2
	add d2,a0
	subq.l #1,d0
.lb20:
	move.l virtual,a3
	move y,d2
	muls max_imagex,d2
	add.l x-2,d2
	add.l d2,a3
	and #$f,d1				; cnt
.lb21:
	move.l a3,a1
	move.b (a2)+,d4
	ror #8,d4
	move.b (a2)+,d4
	swap d4
	move.b (a2)+,d4
	ror #8,d4
	move.b (a2)+,d4		; mask0-3
	subq.l #4,d0
	bsr qt_smc_c4_256
	addq #4,x
	addq.l #4,a3
	move max_imagex,d2
	cmp x,d2
	bgt.s .lb22
	clr x
	addq #4,y
	move.l virtual,a3
	move y,d2
	muls max_imagex,d2
	add.l x-2,d2
	add.l d2,a3
.lb22:
	dbf d1,.lb21
	bra .while	
.casec:
	cmp #$e0,d1
	bpl .casee
	lea cvid_fix1+3072,a0
	moveq #0,d2
	cmp #$d0,d1
	bpl.s .lb23
	move.b smc_c+1,d2
	asl #3,d2
	add d2,a0
	addq #1,smc_c
	moveq #0,d2
	rept 8
		move.b (a2)+,d2
		move.b 0(a6,d2.w),(a0)+
	endr
	subq.l #8,a0
	subq.l #8,d0
	bra.s .lb24
.lb23:
	move.b (a2)+,d2
	asl #3,d2
	add d2,a0
	subq.l #1,d0
.lb24:
	move.l virtual,a3
	move y,d2
	muls max_imagex,d2
	add.l x-2,d2
	add.l d2,a3
	and #$f,d1				; cnt
.lb25:
	move.l a3,a1
	subq.l #6,d0
	move.b (a2)+,d6
	ror #8,d6
	move.b (a2)+,d6
	bsr qt_smc_c8_256
	move d6,d7
	move.b (a2)+,d6
	ror #8,d6
	move.b (a2)+,d6
	bsr qt_smc_c8_256
	lsr #4,d6
	or d6,d7
	move.b (a2)+,d6
	ror #8,d6
	move.b (a2)+,d6
	bsr qt_smc_c8_256
	lsr #8,d6
	or d7,d6
	bsr qt_smc_c8_256
	addq #4,x
	addq.l #4,a3
	move max_imagex,d2
	cmp x,d2
	bgt.s .lb26
	clr x
	addq #4,y
	move.l virtual,a3
	move y,d2
	muls max_imagex,d2
	add.l x-2,d2
	add.l d2,a3
.lb26:
	dbf d1,.lb25
	bra .while
.casee:						; $ex	
	move.l virtual,a3
	move y,d2
	muls max_imagex,d2
	add.l x-2,d2
	add.l d2,a3
	and #$f,d1				; cnt
	moveq #0,d4
.lb27:
	move.l a3,a1
	moveq #0,d2
	rept 4
	rept 4
		move.b (a2)+,d2
		move.b 0(a6,d2.w),(a1)+
	endr
	add d3,a1
	endr
	subq.l #8,d0
	subq.l #8,d0
	addq #4,x
	addq.l #4,a3
	move max_imagex,d2
	cmp x,d2
	bgt.s .lb28
	clr x
	addq #4,y
	move.l virtual,a3
	move y,d2
	muls max_imagex,d2
	add.l x-2,d2
	add.l d2,a3
.lb28:
	dbf d1,.lb27
	bra .while	

qt_smc_c8_256:
	rept 4
		moveq #0,d2
		lsl #1,d6
		roxl #1,d2
		lsl #1,d6
		roxl #1,d2
		lsl #1,d6
		roxl #1,d2
		move.b (a0,d2.w),(a1)+
	endr
	add d3,a1
	rts
	
qt_smc_c4_256:
	moveq #3,d5
.lb0:
	rept 4
		moveq #0,d2
		lsl.l #1,d4
		roxl #1,d2
		lsl.l #1,d4
		roxl #1,d2
		move.b (a0,d2.w),(a1)+
	endr
	add d3,a1
	dbf d5,.lb0
	rts

qt_smc_c2_256:
	btst #7,d6
	beq.s .lb0
	move.b d5,(a0)+
	bra.s .lb1
.lb0:
	move.b d4,(a0)+
.lb1:	
	btst #6,d6
	beq.s .lb2
	move.b d5,(a0)+
	bra.s .lb3
.lb2:
	move.b d4,(a0)+
.lb3:
	btst #5,d6
	beq.s .lb4
	move.b d5,(a0)+
	bra.s .lb5
.lb4:
	move.b d4,(a0)+
.lb5:
	btst #4,d6
	beq.s .lb6
	move.b d5,(a0)+
	bra.s .lb7
.lb6:
	move.b d4,(a0)+
.lb7:
	add d3,a0
	btst #3,d6
	beq.s .lb8
	move.b d5,(a0)+
	bra.s .lb9
.lb8:
	move.b d4,(a0)+
.lb9:
	btst #2,d6
	beq.s .lb10
	move.b d5,(a0)+
	bra.s .lb11
.lb10:
	move.b d4,(a0)+
.lb11:
	btst #1,d6
	beq.s .lb12
	move.b d5,(a0)+
	bra.s .lb13
.lb12:
	move.b d4,(a0)+
.lb13:
	btst #0,d6
	beq.s .lb14
	move.b d5,(a0)+
	rts
.lb14:
	move.b d4,(a0)+
	rts

qt_smc_o2i_256:
	move.l a3,a0		; dest
	move.l a4,a1		; source
	rept 3
		move.l (a1)+,(a0)+
		add d3,a0
		add d3,a1
	endr
	move.l (a1),(a0)
	addq #4,x
	addq.l #4,a3
	move max_imagex,d2
	cmp x,d2
	bgt.s .end
	clr x
	addq #4,y
	move.l virtual,a3
	move y,d2
	muls max_imagex,d2
	add.l x-2,d2
	add.l d2,a3
.end:
	rts

	
qt_smc_c1_256:
	move.l a3,a0		; dest
	rept 3
		move.l d4,(a0)+
		add d3,a0
	endr
	move.l d4,(a0)
	addq #4,x
	addq.l #4,a3
	move max_imagex,d2
	cmp x,d2
	bgt.s .end
	clr x
	addq #4,y
	move.l virtual,a3
	move y,d2
	muls max_imagex,d2
	add.l x-2,d2
	add.l d2,a3
.end:
	rts

qt_raw_256:
	lea colors256,a1
	move.l buffer,a2
	move.l virtual,a3
	move.l imagey,d5
	move.l bufused,d4
	divs d5,d4						; max image x according to bufused
	subq #1,d4
	moveq #0,d1
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	move.b (a2)+,d1
	move.b 0(a1,d1.w),(a3)+
	dbf d0,.lb1
.y_loop:
	dbf d5,.lb0
	rts	


qt_raw4_256:
	move.l buffer,a2
	move.l virtual,a3
	move max_imagex,d3
	move.l imagex,d4
	addq #7,d4
	and.b #$F8,d4
	sub d4,d3
	moveq #0,d2
	moveq #0,d7
	move.l imagey,d5
	lsr #1,d4						; one byte=2 pixels
	subq #1,d4
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	moveq #0,d2
	move.b (a2)+,d2
	lsl #4,d2
	lsr.b #4,d2
	lsl #3,d2
	move d2,(a3)+
	dbf d0,.lb1
	add d3,a3
.y_loop:
	dbf d5,.lb0
	rts	


qt_raw1_256:
	move.l buffer,a2
	move.l virtual,a3
	move max_imagex,d3
	move.l imagey,d5
	move max_imagex,d4
	move d4,d0
	add #15,d4
	and.w #$fff0,d4				; word aligned
	cmp d0,d4
	beq.s .mul16
	and #$f,d0						; how many pixels more
	moveq #-1,d1					; full mask
	lsr d0,d1						; good mask
	move d4,d0
	asr #3,d0						; number of bytes
	lea -2(a2,d0.w),a0			; first word to change
	move d5,d2
	subq #1,d2
.mask:
	or d1,(a0)						; add black pixels when unused
	add d0,a0
	dbf d2,.mask
.mul16:
	sub d4,d3
	moveq #0,d2
	moveq #0,d7
	lsr #3,d4						; one byte=8 pixels
	subq #1,d4
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	move.b (a2)+,d2
	rept 7
		spl d1
		and.b #$78,d1
		move.b d1,(a3)+
		lsl.b #1,d2
	endr
	spl d1
	and.b #$78,d1
	move.b d1,(a3)+
	dbf d0,.lb1
	add d3,a3
.y_loop:
	dbf d5,.lb0
	rts	


qt_raw2_256:
	move.l buffer,a2
	move.l virtual,a3
	move max_imagex,d3
	move.l bufused,d4
	asl.l #2,d4
	move.l imagey,d5
	divs d5,d4
	sub d4,d3
	moveq #0,d2
	moveq #0,d7
	lsr #2,d4						; one byte=4 pixels
	subq #1,d4
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	move.b (a2)+,d2
	rept 4
		moveq #0,d6
		lsl.b d2
		roxl.b d6
		lsl.b d2
		roxl.b d6
		lsl.b #3,d6
		move.b d6,(a3)+
	endr
	dbf d0,.lb1
	add d3,a3
.y_loop:
	dbf d5,.lb0
	rts
	

qt_rle1_256:
	move.l virtual,a3
	move.l buffer,a2
	move max_imagex,d3
	addq.l #5,a2		; codec size + one byte
	btst #3,(a2)+		; flag and $8
	bne.s .lb0			; if 8, header present
	clr flx_number
	clr flx_start
.exit:
	rts					; else, nop frame
.lb0:
	move (a2)+,d0		; start line
	move d0,flx_start
	muls d3,d0			; offset
	add.l d0,a3			; start into screen
	addq.l #2,a2
	move (a2)+,d0		; number of lines	
	move d0,flx_number
	addq.l #2,a2
	move.l a3,a4		; saves start of line
.line:
	moveq #0,d1
	move.b (a2)+,d1		; code
	bclr #7,d1
	beq.s .lb1			; if >0, normal
	move.l a4,a3		; else, new line
	add d3,a4			; for the next time
.lb1:
	lsl #4,d1
	add d1,a3
	moveq #0,d1
	move.b (a2)+,d1
	beq.s .exit			; code=0 means end of frame
	bmi.s .repeat
	subq #1,d1
.copy:
	bsr .one_word		; from a2 into a3
	dbf d1,.copy
	bra.s .line
.repeat:
	not.b d1
	beq.s .line
	move.l a3,a0		; saves the current position
	bsr .one_word
	bra.s .lb2
.rep:
	rept 4
		move.l (a0)+,(a3)+
	endr
.lb2:
	dbf d1,.rep	
	bra.s .line
.one_word:
	moveq #1,d4
.again:
	move.b (a2)+,d2
	rept 7
		spl d0
		and.b #$78,d0
		move.b d0,(a3)+
		lsl.b #1,d2
	endr
	spl d0
	and.b #$78,d0
	move.b d0,(a3)+
	dbf d4,.again
	rts	


qt_rle2_256:
	move.l virtual,a3
	move.l buffer,a2
	move max_imagex,d3
	addq.l #5,a2		; codec size + one byte
	btst #3,(a2)+		; flag and $8
	bne.s .lb0			; if 8, header present
	clr flx_start
	clr flx_number
.exit:
	rts					; else, nop frame
.lb0:
	move (a2)+,d0		; start line
	move d0,flx_start
	muls d3,d0			; offset
	add.l d0,a3			; start into screen
	addq.l #2,a2
	move (a2)+,d0		; number of lines	
	move d0,flx_number
	addq.l #2,a2
	move.l a3,a4		; saves start of line
	bra.s .start
.line:
	moveq #0,d1
	move.b (a2)+,d1	; code
	bpl.s .lb1			; positive, copy
	cmp.b #$ff,d1
	bne.s .repeat		; other than -1, repeat
	add d3,a4			; next line
	move.l a4,a3		; new line
.start:
	tst.b (a2)+
	bne.s .line
	rts
.lb1:
	subq #1,d1
.copy:
	bsr .one_long		; from a2 into a3
	dbf d1,.copy
	bra.s .line
.repeat:
	not.b d1
	move.l a3,a0		; saves the current position
	bsr .one_long
	bra.s .lb2
.rep:
	rept 4
		move.l (a0)+,(a3)+
	endr
.lb2:
	dbf d1,.rep	
	bra.s .line
.one_long:
	moveq #1,d4
.again:
	move (a2)+,d2
	rept 8
		moveq #0,d0
		lsl d2
		roxl.b d0
		lsl d2
		roxl.b d0
		lsl.b #3,d0
		move.b d0,(a3)+
	endr
	dbf d4,.again
	rts	

qt_rle4_256:
	move.l virtual,a3
	move.l buffer,a2
	move max_imagex,d3
	addq.l #5,a2		; codec size + one byte
	btst #3,(a2)+		; flag and $8
	bne.s .lb0			; if 8, header present
	clr flx_number
	clr flx_start
	rts					; else, nop frame
.lb0:
	move (a2)+,d0		; start line
	move d0,flx_start
	muls d3,d0			; offset
	add.l d0,a3			; start into screen
	addq.l #2,a2
	move (a2)+,d0		; number of lines	
	move d0,flx_number
	addq.l #2,a2
	move.l a3,a4		; saves start of line
	bra.s .start
.line:
	moveq #0,d1
	move.b (a2)+,d1	; code
	bpl.s .lb1			; positive, copy
	cmp.b #$ff,d1
	bne.s .repeat		; other than -1, repeat
	add d3,a4			; next line
	move.l a4,a3		; new line
.start:
	tst.b (a2)+
	bne.s .line
	rts
.lb1:
	subq #1,d1
.copy:
	bsr .one_long		; from a2 into a3
	dbf d1,.copy
	bra.s .line
.repeat:
	not.b d1
	move.l a3,a0		; saves the current position
	bsr .one_long
	bra.s .lb2
.rep:
	move.l (a0)+,(a3)+
	move.l (a0)+,(a3)+
.lb2:
	dbf d1,.rep	
	bra.s .line
.one_long:
	rept 4
	moveq #0,d2
	move.b (a2)+,d2
	lsl #4,d2
	lsr.b #4,d2
	lsl #3,d2
	move d2,(a3)+
	endr
	rts

qt_rle8_256:
	lea colors256,a1
	move.l virtual,a3
	move.l buffer,a2
	move max_imagex,d3
	moveq #0,d4
	addq.l #5,a2		; codec size + one byte
	btst #3,(a2)+		; flag and $8
	bne.s .lb0			; if 8, header present
	clr flx_start
	clr flx_number
	rts					; else, nop frame
.lb0:
	move (a2)+,d0		; start line
	move d0,flx_start
	muls d3,d0			; offset
	add.l d0,a3			; start into screen
	addq.l #2,a2
	move (a2)+,d0		; number of lines
	move d0,flx_number
	addq.l #2,a2
	move.l a3,a4
.while:
	subq #1,d0
	bpl.s .lb1
	rts
.lb1:
	move.l a4,a3		; start of line
	add d3,a4			; for the next line
	moveq #0,d2
	move.b (a2)+,d2
	asl #2,d2
	lea -4(a3,d2.w),a3
.cnt:
	moveq #0,d2
	move.b (a2)+,d2	; code
	bne.s .case80
	move.b (a2)+,d2
	asl #2,d2
	lea -4(a3,d2.w),a3
	bra.s .cnt
.case80:
	bmi.s .repeat
	subq #1,d2
.run:
	rept 4
		move.b (a2)+,d4
		move.b 0(a1,d4.w),(a3)+
	endr
	dbf d2,.run
	bra.s .cnt
.repeat:
	sub #256,d2
	neg d2
	subq #1,d2
	beq.s .while	; it was $FF=end of line
	move.b (a2)+,d4
	move.b 0(a1,d4.w),d5
	lsl #8,d5
	move.b (a2)+,d4
	move.b 0(a1,d4.w),d5
	swap d5
	move.b (a2)+,d4
	move.b 0(a1,d4.w),d5
	lsl #8,d5
	move.b (a2)+,d4
	move.b 0(a1,d4.w),d5
.rep:
	move.l d5,(a3)+
	dbf d2,.rep
	bra.s .cnt


qt_yuv2_256:
	move.l virtual,a3
	move.l buffer,a2
	move.l imagey,d5
	move.l bufused,d4
	divs d5,d4				; number of columns according to buffer size
	lsr #1,d4				; one pixel = 2 bytes
	subq #1,d5
	move #$F8,d7
	move max_imagex,d3
	sub d4,d3
	subq #1,d4
	move #$F0F0,d2
	moveq #0,d0
	moveq #0,d1
.loop:
	move d4,d6
.line:
	move.b (a2),d0
	ror #8,d0
	move.b 2(a2),d0
	and d2,d0
	lsr d0
	move d0,(a3)+
	addq.l #4,a2
	subq #1,d6
	dbf d6,.line			; next 2 pixels
	add d3,a3
	dbf d5,.loop			; next line
	rts
	
	
qt_yuv9_256:
	move.l image,a3
	move.l buffer,a2	; Yptr
	move max_imagey,d5
	move max_imagex,d4
	subq #1,d5
	move screenw,d3
	sub d4,d3
	lsr #2,d4			; pixels come 4 at a time
	subq #1,d4
	moveq #0,d0
	moveq #0,d1			; y
.loop:
	move d4,d6
.line:
	move.l (a2)+,d0		; y0123
	not.l d0
	move.l d3,(a3)+
	subq #1,d6
	dbf d6,.line			; next 2 pixels
	add d3,a3
	dbf d5,.loop			; next line
	rts
	
	
close_work: dc.l cw_cont,dum,dum,dum,dum
cw_cont: dc.w 101,0,0,0,0,0,0,0,0,0,0,0


decode_cram16_grey:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
	move.l buffer,a2			; the datas
	move max_imagex,d3
	addq #4,d3
	clr x
	move max_imagey,y
	subq #1,y
.loop:
	tst y
	bmi .exit
	moveq #0,d6
	moveq #0,d7
	move.b (a2)+,d6				; code0 
	move.b (a2)+,d7				; code1
	cmp #$84,d7
	bmi.s .blocs
	cmp #$88,d7
	bpl.s .blocs
	sub #$84,d7						; skip
	lsl #8,d7
	add d6,d7
	bra.s .lb0
.skip:
	addq #4,x
	move x,d0
	cmp max_imagex,d0
	bmi.s .lb0
	clr x
	subq #4,y
.lb0:
	dbf d7,.skip
	bra.s .loop
.blocs:
	move.l virtual,a3
	move max_imagex,d0
	muls y,d0
	move x,d1
	ext.l d1
	add.l d1,d0
	add.l d0,a3			; image + y*screenw + x
	cmp #$80,d7
	bpl .lb2
	move (a2)+,d5		; cb0
	move (a2)+,d4		; ca0
	btst #7,d5
	beq.s .lb1
	move (a2)+,d2		; cb1
	move (a2)+,d1		; ca1
	bsr avi_cram16_c4_grey
	move d7,d6
	move (a2)+,d5
	move (a2)+,d4
	move (a2)+,d2
	move (a2)+,d1
	bsr avi_cram16_c4_grey
	bra.s .inc_bloc
.lb1:
	bsr avi_cram16_c2_grey
	move d7,d6
	bsr _avi_cram16_c2_grey
	bra.s .inc_bloc
.lb2:
	lsl #8,d6
	add d6,d7
	bsr avi_cram16_c1_grey
.inc_bloc:
	addq #4,x
	move x,d0
	cmp max_imagex,d0
	bmi .loop
	clr x
	subq #4,y
	bra .loop
.exit:
	rts
	
qt_raw16_256:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
	move.l buffer,a2
	move.l virtual,a3
	move max_imagex,d3
	move.l imagey,d5
	move.l bufused,d4
	divs d5,d4
	lsr #1,d4						; max image x according to bufused
	sub d4,d3
	subq #1,d4
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	move (a2)+,d2
	bclr #15,d2
	move.b 0(a1,d2.w),(a3)+
	dbf d0,.lb1
	add d3,a3
.y_loop:
	dbf d5,.lb0
	rts	

qt_raw24_256:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
	move off_24_32,d7			; 0 or 1 to skip one byte (R G B or 0 R G B)
	move.l buffer,a2
	move.l virtual,a3
	move max_imagex,d3
	move.l imagey,d5
	move.l bufused,d4
	moveq #3,d0
	add d7,d0
	muls d5,d0
	divs d0,d4					; max image_x according to bufused
	sub d4,d3
	subq #1,d4
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	add d7,a2
	moveq #0,d2
	move.b (a2)+,d2
	lsl #5,d2
	move.b (a2)+,d2
	lsl.l #5,d2
	move.b (a2)+,d2
	lsr.l #3,d2
	move.b 0(a1,d2.w),(a3)+
	dbf d0,.lb1
	add d3,a3
.y_loop:
	dbf d5,.lb0
	rts	

falc set 0

	rept 2

	if falc=0
bat_tga:
		if REG=0
			move.l hc_cvid,a1
		endif
	else
bat_tga_256:
	move.l hc_cvid,a1			
	endif
									; pointer for the color/grey conversion
									; word to byte with 256, word to word with
									; unregistered version and TC
	move.l buffer,a2
	move.l virtual,a3
	move max_imagex,d3
	move 14(a2),d5				; max_imagey
	ror #8,d5
	move 12(a2),d4				; max_imagex
	ror #8,d4
	btst #5,17(a2)
	bne.s .top
	move d5,d0
	subq #1,d0
	muls d3,d0
	add d4,d3
	neg d3
	bra.s .common
.top:
	sub d4,d3
	moveq #0,d0
.common:
	if falc<2
		add d3,d3					; row_inc
		add.l d0,d0
	endif
	add.l d0,a3
	subq #1,d4
	move.b 16(a2),d0
	cmp.b #24,d0					; 24 bits?
	bne .other_bits
	moveq #0,d0
	move.b (a2),d0
	lea 18(a2,d0.w),a2
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
		move.b (a2)+,d2
		lsl #8,d2
		swap d2
		move.b (a2)+,d2
		lsl #8,d2
		move.b (a2)+,d2
		lsr.b #3,d2
		rol #5,d2
		rol.l #5,d2
		if falc=2
			move.b 0(a1,d2.w),(a3)+
		else
			if REG=0
				ext.l d2
				add.l d2,d2
				move 0(a1,d2.l),(a3)+
			else
				move d2,(a3)+
			endif
		endif
	dbf d0,.lb1
	if falc=0
		move.l a3,a0
		move d4,d2
	.pad:
		addq #1,d2
		cmp max_imagex,d2
		beq.s .not_pad
		clr (a0)+
		bra.s .pad
	.not_pad:
	endif
	add d3,a3
.y_loop:
	dbf d5,.lb0
	if falc=2
		.aff:
		move.l display_ste,a0
		jmp (a0)
	else
		rts
	endif
.other_bits:			; assumes that it's a 16 bits TGA
	moveq #0,d0
	move.b (a2),d0
	lea 18(a2,d0.w),a2
	bra.s .oy_loop
.olb0:
	move d4,d0
.olb1:
		if falc=0
			move (a2)+,d2
			ror #8,d2
			move d2,(a3)+
		else
			move (a2)+,d2
			ror #8,d2
			bclr #15,d2
			move.b 0(a1,d2.w),(a3)+
		endif
	dbf d0,.olb1
	if falc=0
		move.l a3,a0
		move d4,d2
	.opad:
		addq #1,d2
		cmp max_imagex,d2
		beq.s .onot_pad
		clr (a0)+
		bra.s .opad
	.onot_pad:
	endif
	add d3,a3
.oy_loop:
	dbf d5,.olb0
	if falc=2
		bra.s .aff
	else
		rts
	endif
	
falc set 2
	endr

qt_rle16_256:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
	move.l virtual,a3
	move.l buffer,a2
	move max_imagex,d3
	addq.l #5,a2		; codec size + one byte
	btst #3,(a2)+		; flag and $8
	bne.s .lb0			; if 8, header present
	clr flx_number
	clr flx_start
	rts					; else, nop frame
.lb0:
	move (a2)+,d0		; start line
	move d0,flx_start
	muls d3,d0			; offset
	add.l d0,a3			; start into screen
	addq.l #2,a2
	move (a2)+,d0		; number of lines
	move d0,flx_number
	addq.l #2,a2
	move.l a3,a4
.while:
	subq #1,d0
	bpl.s .lb1
	rts
.lb1:
	move.l a4,a3		; start of line
	add d3,a4			; for the next line
	moveq #0,d2
	move.b (a2)+,d2
	lea -1(a3,d2.w),a3
.cnt:
	move.b (a2)+,d2	; code
	bne.s .case80
	move.b (a2)+,d2
	lea -1(a3,d2.w),a3
	bra.s .cnt
.case80:
	bmi.s .repeat
	subq #1,d2
.run:
	move.b (a2)+,d4
	ror #8,d4
	move.b (a2)+,d4
	bclr #15,d4
	move.b 0(a1,d4.w),(a3)+
	dbf d2,.run
	moveq #0,d2
	bra.s .cnt
.repeat:
	sub #256,d2
	neg d2
	subq #1,d2
	beq.s .while		; it was FF=end of line
	move.b (a2)+,d4
	ror #8,d4
	move.b (a2)+,d4
	bclr #15,d4
	move.b 0(a1,d4.w),d4
.rep:
	move.b d4,(a3)+
	dbf d2,.rep
	moveq #0,d2
	bra.s .cnt


qt_rle24_256:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
	move.l virtual,a3
	move.l buffer,a2
	move off_24_32,d7		; 1 or 0 to skip one byte before R G B
	move max_imagex,d3
	addq.l #5,a2		; codec size + one byte
	btst #3,(a2)+		; flag and $8
	bne.s .lb0			; if 8, header present
	clr flx_start
	clr flx_number
	rts					; else, nop frame
.lb0:
	move (a2)+,d0		; start line
	move d0,flx_start
	muls d3,d0			; offset
	add.l d0,a3			; start into screen
	addq.l #2,a2
	move (a2)+,d0		; number of lines
	move d0,flx_number
	addq.l #2,a2
	move.l a3,a4
.while:
	subq #1,d0
	bpl.s .lb1
	rts
.lb1:
	move.l a4,a3		; start of line
	add d3,a4			; for the next line
	moveq #0,d2
	move.b (a2)+,d2
	lea -1(a3,d2.w),a3
	move.b (a2)+,d2	; code
.cnt:
	cmp.b #$ff,d2
	beq.s .while		; end of line
	tst.b d2
	bne.s .case80
	move.b (a2)+,d2
	lea -1(a3,d2.w),a3
.next_cnt:
	move.b (a2)+,d2
	bra.s .cnt
.case80:
	cmp #$80,d2
	bpl.s .repeat
	subq #1,d2
.run:
	add d7,a2
	move.b (a2)+,d4
	lsl #5,d4
	move.b (a2)+,d4
	lsl.l #5,d4
	move.b (a2)+,d4
	lsr.l #3,d4
	bclr #15,d4
	move.b 0(a1,d4.w),(a3)+
	dbf d2,.run
	moveq #0,d2
	bra.s .next_cnt
.repeat:
	sub #256,d2
	neg d2
	subq #1,d2
	add d7,a2
	move.b (a2)+,d4
	lsl #5,d4
	move.b (a2)+,d4
	lsl.l #5,d4
	move.b (a2)+,d4
	lsr.l #3,d4
	bclr #15,d4
	move.b 0(a1,d4.w),d4
.rep:
	move.b d4,(a3)+
	dbf d2,.rep
	moveq #0,d2
	bra.s .next_cnt		


qt_rpza_256:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
	move.l buffer,a2
	move.l virtual,a3
	move max_imagex,d3
	moveq #0,d0
	move d3,d0	
	move d3,d5
	muls #3,d5
	subq #4,d3
	lsl #2,d0
	sub max_imagex,d0
	move.l d0,a4		; row inc
	moveq #0,d7				; x
	clr.b (a2)				; $e1
	move.l (a2)+,d0		; len
	cmp.l bufused,d0
	bne.s .out
	subq.l #5,d0			; ends at -1
.while:
	tst.l d0
	bpl.s .lb0
.out:
	rts
.lb0:
	moveq #0,d1
	move.b (a2)+,d1		; code
	subq.l #1,d0
	move d1,d2
	lsr #5,d2
	cmp.b #5,d2				; code $a0 to $bf
	bne.s .case8
	move.b (a2)+,d2			; color
	ror #8,d2
	move.b (a2)+,d2
	subq.l #2,d0
	bsr qt_rpza_c1_256
	bra.s .while
.case8:
	cmp.b #4,d2				; code $80 to $9f
	bne.s .casec
	sub #$80,d1				; loops
.lb1:
	bsr rpza_inc_256
	dbf d1,.lb1
	bra.s .while
.casec:
	cmp.b #6,d2
	bne.s .casex
	move d1,a0
	sub #$bf,a0
	subq.l #4,d0
	move.b (a2)+,d1			; one color
	ror #8,d1
	move.b (a2)+,d1
	move.b (a2)+,d2			; another
	ror #8,d2
	move.b (a2)+,d2
.col4_init:
	bclr #15,d1
	move.b 0(a1,d1.w),d1
	bclr #15,d2
	move.b 0(a1,d2.w),d2
.col4:
	move.b (a2)+,d4		; mask0 to 3
	ror #8,d4
	move.b (a2)+,d4
	swap d4
	move.b (a2)+,d4
	ror #8,d4
	move.b (a2)+,d4
	subq.l #4,d0
	bsr qt_rpza_c4_256
	subq #1,a0
	cmp #0,a0
	bne.s .col4
	bra.s .while
.casex:						; under $80
	lsl #8,d1
	move.b (a2)+,d1		; one color
	move.b (a2)+,d2			; a second color
	ror #8,d2
	move.b (a2)+,d2
	subq.l #3,d0
	move #1,a0
	bclr #15,d2
	bne.s .col4_init				; same as above
	bsr qt_rpza_c16_256
	bra .while
	
rpza_inc_256:
	addq.l #4,a3
	addq #4,d7
	cmp max_imagex,d7
	bmi.s .lb0
	moveq #0,d7
	add.l a4,a3
.lb0:
	rts	

qt_rpza_c1_256:
	bclr #15,d2
	move.b 0(a1,d2.w),d2
	sub #$a0,d1		; loops
	move d2,d4
	lsl #8,d2
	move.b d4,d2	; into high byte
	move d2,d4
	swap d2
	move d4,d2		; into high word
.lb0:
	rept 3
	move.l d2,(a3)+
	add d3,a3
	endr
	move.l d2,(a3)+
	sub d5,a3
	addq #4,d7
	cmp max_imagex,d7
	bmi.s .lb1
	moveq #0,d7
	add.l a4,a3
.lb1:
	dbf d1,.lb0
	rts

qt_rpza_c4_256:
	moveq #3,d6
.loop:
	btst #31,d4
	beq.s .lb0
	move.b d1,(a3)+
	bra.s .lb1
.lb0:
   move.b d2,(a3)+
.lb1:
	btst #29,d4
	beq.s .lb2
	move.b d1,(a3)+
	bra.s .lb3
.lb2:
   move.b d2,(a3)+
.lb3:
	btst #27,d4
	beq.s .lb4
	move.b d1,(a3)+
	bra.s .lb5
.lb4:
   move.b d2,(a3)+
.lb5:
	btst #25,d4
	beq.s .lb6
	move.b d1,(a3)+
	bra.s .lb7
.lb6:
   move.b d2,(a3)+
.lb7:
	add d3,a3
	lsl.l #8,d4
	dbf d6,.loop
	sub d3,a3
	sub d5,a3
	addq #4,d7
	cmp max_imagex,d7
	bmi.s .lb8
	moveq #0,d7
	add.l a4,a3
.lb8:
	rts


qt_rpza_c16_256:
	bclr #15,d1
	move.b 0(a1,d1.w),(a3)+
	bclr #15,d2
	move.b 0(a1,d2.w),(a3)+
	RPZA	; 2 pixels
	moveq #2,d2
.loop:
	add d3,a3
	rept 2
		RPZA	; 2 pixels
	endr
	dbf d2,.loop
	sub d5,a3
	addq #4,d7
	cmp max_imagex,d7
	bmi.s .lb8
	moveq #0,d7
	add.l a4,a3
.lb8:
	sub.l #28,d0
	rts

flh_brun_256:
	move max_imagey,d5		; number of lines to modify
	move d5,flx_number
	clr flx_start
	move.l a5,a2				; screen pointer
	bra.s .l_loop
.line:
	lea 0(a2,d3.l),a3			; the next line in memory
	moveq #0,d4					; number of blocs
	move.b (a0)+,d4
	beq.s .apex					; si 0, c'est du Apex tout crach‚
	bra.s .b_loop
.blocs:
	moveq #0,d1
	moveq #0,d0
	move.b (a0)+,d0			; number of pixels
	cmp #$7f,d0
	bls.s .repeat
	sub #$100,d0
	neg d0
	bra.s .c_loop
.copy:
	move.b (a0)+,d1
	ror #8,d1
	move.b (a0)+,d1
	NOVA16 d1
	bclr #15,d1
	move.b 0(a6,d1.w),(a2)+
.c_loop:
	dbf d0,.copy
	bra.s .b_loop
.repeat:
	move.b (a0)+,d1
	ror #8,d1
	move.b (a0)+,d1
	NOVA16 d1
	bclr #15,d1
	move.b 0(a6,d1.w),d1
	bra.s .lb2
.lb1:
	move.b d1,(a2)+
.lb2:
	dbf d0,.lb1
.b_loop:
	dbf d4,.blocs
.next_line:
	move.l a3,a2				; the next line
.l_loop:
	dbf d5,.line
	rts	
.apex:
	move max_imagex,d4		; loop key is the width
	subq #1,d4
.ap_blocs:
	moveq #0,d1
	moveq #0,d0
	move.b (a0)+,d0			; number of pixels
	cmp #$7f,d0
	bls.s .ap_repeat
	sub #$100,d0
	neg d0
	sub d0,d4
	bra.s .ap_c_loop
.ap_copy:
	move.b (a0)+,d1
	ror #8,d1
	move.b (a0)+,d1
	NOVA16 d1
	bclr #15,d1
	move.b 0(a6,d1.w),(a2)+
.ap_c_loop:
	dbf d0,.ap_copy
	bra.s .ap_b_loop
.ap_repeat:
	sub d0,d4
	move.b (a0)+,d1
	ror #8,d1
	move.b (a0)+,d1
	NOVA16 d1
	bclr #15,d1
	move.b 0(a6,d1.w),d1
	bra.s .ap_lb2
.ap_lb1:
	move.b d1,(a2)+
.ap_lb2:
	dbf d0,.ap_lb1
.ap_b_loop:
	tst d4
	bpl.s .ap_blocs
	bra.s .next_line
	
flh_delta_256:
	move (a0)+,d5
	ror #8,d5					; number of lines to modify
	move d5,flx_number
	moveq #0,d0
	move (a0),d4
	ror #8,d4
	bpl.s .zzz
	neg d4
	move d4,d0
.zzz:
	move d0,flx_start
	move.l a5,a2				; screen pointer
	bra.s .l_loop
.line:
	lea 0(a2,d3.l),a3			; the next line in memory
	move (a0)+,d4				; number of blocs
	ror #8,d4
	bpl.s .b_loop				; if >0, it's a normal line
	neg d4						; else, number of lines to skip!
	muls d3,d4					; number of bytes
	add.l d4,a2					; skips lines
	bra.s .line
.blocs:
	moveq #0,d0
	move.b (a0)+,d0			; number of pixels to skip
	add d0,a2
	moveq #0,d1
	moveq #0,d0
	move.b (a0)+,d0			; number of pixels
	cmp #$80,d0
	bpl.s .repeat
	bra.s .c_loop
.copy:
	move.b (a0)+,d1
	ror #8,d1
	move.b (a0)+,d1
	NOVA16 d1
	bclr #15,d1
	move.b 0(a6,d1.w),(a2)+
.c_loop:
	dbf d0,.copy
	bra.s .b_loop
.repeat:
	sub #$100,d0
	neg d0
	move.b (a0)+,d1
	ror #8,d1
	move.b (a0)+,d1
	NOVA16 d1
	bclr #15,d1
	move.b 0(a6,d1.w),d1
	bra.s .lb2
.lb1:
	move.b d1,(a2)+
.lb2:
	dbf d0,.lb1
.b_loop:
	dbf d4,.blocs
	move.l a3,a2				; the next line
.l_loop:
	dbf d5,.line
	rts

avi_cram16_c1_grey:
	TO_GREY d7
_avi_cram8_c1:
	and #$ff,d7
	move d7,d0
	lsl #8,d0
	or d0,d7		; repeats d7 into high byte
	move d7,d0
	swap d7
	move d0,d7	; and repeats into high word
	rept 4
	move.l d7,(a3)+
	sub d3,a3
	endr
	rts
	
avi_cram16_c2_grey:
	TO_GREY d4
	TO_GREY d5
_avi_cram16_c2_grey:
_avi_cram8_c2:
	btst #0,d6
	bne.s .lb0
	move.b d4,(a3)+
	bra.s .lb1
.lb0:
	move.b d5,(a3)+
.lb1:
	btst #1,d6
	bne.s .lb2
	move.b d4,(a3)+
	bra.s .lb3
.lb2:
	move.b d5,(a3)+
.lb3:
	btst #2,d6
	bne.s .lb4
	move.b d4,(a3)+
	bra.s .lb5
.lb4:
	move.b d5,(a3)+
.lb5:
	btst #3,d6
	bne.s .lb6
	move.b d4,(a3)+
	bra.s .lb7
.lb6:
	move.b d5,(a3)+
.lb7:
	sub d3,a3
	btst #4,d6
	bne.s .lb8
	move.b d4,(a3)+
	bra.s .lb9
.lb8:
	move.b d5,(a3)+
.lb9:
	btst #5,d6
	bne.s .lb10
	move.b d4,(a3)+
	bra.s .lb11
.lb10:
	move.b d5,(a3)+
.lb11:
	btst #6,d6
	bne.s .lb12
	move.b d4,(a3)+
	bra.s .lb13
.lb12:
	move.b d5,(a3)+
.lb13:
	btst #7,d6
	bne.s .lb14
	move.b d4,(a3)+
	bra.s .lb15
.lb14:
	move.b d5,(a3)+
.lb15:
	sub d3,a3
	rts

avi_cram16_c4_grey:
	TO_GREY d4
	TO_GREY d5
	TO_GREY d2
	TO_GREY d1
_avi_cram8_c4:
	btst #0,d6
	bne.s .lb0
	move.b d4,(a3)+
	bra.s .lb1
.lb0:
	move.b d5,(a3)+
.lb1:
	btst #1,d6
	bne.s .lb2
	move.b d4,(a3)+
	bra.s .lb3
.lb2:
	move.b d5,(a3)+
.lb3:
	btst #2,d6
	bne.s .lb4
	move.b d1,(a3)+
	bra.s .lb5
.lb4:
	move.b d2,(a3)+
.lb5:
	btst #3,d6
	bne.s .lb6
	move.b d1,(a3)+
	bra.s .lb7
.lb6:
	move.b d2,(a3)+
.lb7:
	sub d3,a3
	btst #4,d6
	bne.s .lb8
	move.b d4,(a3)+
	bra.s .lb9
.lb8:
	move.b d5,(a3)+
.lb9:
	btst #5,d6
	bne.s .lb10
	move.b d4,(a3)+
	bra.s .lb11
.lb10:
	move.b d5,(a3)+
.lb11:
	btst #6,d6
	bne.s .lb12
	move.b d1,(a3)+
	bra.s .lb13
.lb12:
	move.b d2,(a3)+
.lb13:
	btst #7,d6
	bne.s .lb14
	move.b d1,(a3)+
	bra.s .lb15
.lb14:
	move.b d2,(a3)+
.lb15:
	sub d3,a3
	rts

decode_cram8_256:
	lea colors256,a1
	move.l buffer,a2			; the datas
	move max_imagex,d3
	addq #4,d3
	clr x
	move max_imagey,y
	subq #1,y
.loop:
	tst y
	bmi .exit
	moveq #0,d6
	moveq #0,d7
	move.b (a2)+,d6				; code0 
	move.b (a2)+,d7				; code1
	cmp #$84,d7
	bmi.s .blocs
	cmp #$88,d7
	bpl.s .blocs
	sub #$84,d7						; skip
	lsl #8,d7
	add d6,d7
	bra.s .lb0
.skip:
	addq #4,x
	move x,d0
	cmp max_imagex,d0
	bmi.s .lb0
	clr x
	subq #4,y
.lb0:
	dbf d7,.skip
	bra.s .loop
.blocs:
	move.l virtual,a3
	move max_imagex,d0
	muls y,d0
	move x,d1
	ext.l d1
	add.l d1,d0
	add.l d0,a3			; image + y*screenw + x
	cmp #$90,d7
	bmi.s .lb1
	moveq #0,d1
	move.b (a2)+,d1
	move.b 0(a1,d1.w),d5		; cb0
	move.b (a2)+,d1
	move.b 0(a1,d1.w),d4		; ca0
	move.b (a2)+,d1
	move.b 0(a1,d1.w),d2		; cb1
	move.b (a2)+,d1
	move.b 0(a1,d1.w),d1		; ca1
	bsr _avi_cram8_c4
	move d7,d6
	moveq #0,d1
	move.b (a2)+,d1
	move.b 0(a1,d1.w),d5		; cb0
	move.b (a2)+,d1
	move.b 0(a1,d1.w),d4		; ca0
	move.b (a2)+,d1
	move.b 0(a1,d1.w),d2		; cb1
	move.b (a2)+,d1
	move.b 0(a1,d1.w),d1		; ca1
	bsr _avi_cram8_c4
	bra.s .inc_bloc
.lb1:
	cmp #$80,d7
	bpl.s .lb2
	moveq #0,d4
	move.b (a2)+,d4
	move.b 0(a1,d4.w),d5
	move.b (a2)+,d4
	move.b 0(a1,d4.w),d4
	bsr _avi_cram8_c2
	move d7,d6
	bsr _avi_cram8_c2
	bra.s .inc_bloc
.lb2:
	move.b 0(a1,d6.w),d7
	bsr _avi_cram8_c1
.inc_bloc:
	addq #4,x
	move x,d0
	cmp max_imagex,d0
	bmi .loop
	clr x
	subq #4,y
	bra .loop
.exit:
	rts
	
decode_rle8_256:
	lea colors256,a1
	move max_imagey,d1
	subq #1,d1						; y
	move max_imagex,d4
	move d4,d0
	muls d1,d0
	move.l virtual,a4				; screen memory
	add.l d0,a4						; last line
	move.l a4,a3
	move.l buffer,a2
.while:
	tst d1
	bpl.s .lb0
.end:
	rts
.lb0:
	moveq #0,d6
	move.b (a2)+,d6				; mod
	bne .lb8
	move.b (a2)+,d6				; opcode
	bne.s .lb3
	sub d4,a4						; mod=opcode=0, previous line
	move.l a4,a3					; new pos
	subq #1,d1
	bra.s .while
.lb3:
	cmp.b #1,d6						; if opcode=1
	bne.s .lb4
	moveq #-1,d1					; end of frame
	bra.s .while
.lb4:
	cmp.b #2,d6						; if opcode=2
	bne.s .lb5
	moveq #0,d0
	moveq #0,d5
	move.b (a2)+,d0
	move.b (a2)+,d5
	beq.s .lb4a
	sub d5,d1
	muls d4,d5						; number of lines
	sub.l d5,a4
	sub.l d5,a3
.lb4a:
	add d0,a3
	bra.s .while
.lb5:									; else (for opcode)
	move d6,d5						; cnt
	moveq #0,d0
	bra.s .loop
.lb6:
	move.b (a2)+,d0
	move.b 0(a1,d0.w),(a3)+
.loop:
	dbf d5,.lb6
	btst #0,d6
	beq .while
	addq.l #1,a2
	bra .while	
.lb8:
	move d6,d5		; cnt
	move.b (a2)+,d6
	move.b 0(a1,d6.w),d6
	bra.s .loop2
.lb9:
	move.b d6,(a3)+
.loop2:
	dbf d5,.lb9
	bra .while	

decode_rgb_256:
	lea colors256,a1
	move.l virtual,a3
	move.l buffer,a2
	move max_imagex,d3
	move d3,d7
	addq #1,d7
	bclr #0,d7				; for the next line into buffer
	move max_imagey,d1
	move screenh,d5
	move d1,d0				; y
	subq #1,d0
	muls d3,d0
	add.l d0,a3				; last line pointer
	moveq #0,d0
	bra.s .loop
.lb1:
	move.l a3,a5
	move.l a2,a4
	move d4,d6
	bra.s .line
.lb2:
	move.b (a4)+,d0
	move.b 0(a1,d0.w),(a5)+
.line:
	dbf d6,.lb2
	sub d3,a3
	add d7,a2
.loop:
	dbf d1,.lb1
	rts	

	
bat_ximg_256:
	move.l buffer,a2
	move.l 16(a2),d0
	or.l #$20202020,d0
	cmp.l #'ximg',d0
	beq.s .ok
.quit:
	rts				; not a ximg file!
.ok:
	cmp #8,4(a2)	; number of planes
	bne.s .quit		; only 256 colors accepted
	move 6(a2),d0	; pattern
	bne.s .lb1
	moveq #1,d0
.lb1:
	move d0,pattern
	lea colors256,a6	; palette pointer
	tst.b bat_getp	; read palette?
	beq .end_head
	lea 22(a2),a5
	tst.b create_mov
	bne.s .mov_make
	lea colors256,a4
	move #255,d7
.lb0:
	move (a5)+,d0		; red
	moveq #0,d1
	move (a5)+,d1		; green
	add d1,d1
	add d0,d1			; 2G+R
	move d1,d0
	add d1,d1
	add d0,d1			; 6G+3R
	add (a5)+,d1		; 6G + 3R + B (0 to 10000)
	divs #626,d1		; 0 to 15
	lsl #3,d1			; as an offset
	move.b d1,(a4)+
	dbf d7,.lb0
	bra .end_head
.mov_make:
	tst.b create_avi
	bne .avi_make
	moveq #0,d7
	move.l mov_pal,a0
	clr.l (a0)+
	clr (a0)+
	clr.b (a0)+
	st (a0)+
.mov_loop:
	move d7,(a0)+		; index
	if REG=1
		rept 3
			move (a5)+,d0
			muls #131,d0
			asr.l #1,d0
			move d0,(a0)+
		endr
	else
		move (a5)+,d0
		subq #1,d0
		bpl.s .mov_1
		moveq #0,d0
		.mov_1:
		move (a5)+,d1
		add d1,d1
		add d1,d0	; 2*R + G
		move d0,d1
		add d0,d0
		add d1,d0		; 6*R + 3*G
		add (a5)+,d0	; 6*R + 3*G + B, the brightness (0 to 9994)
		muls #59,d0
		divu #9,d0		; from 0 to 65516
		move d0,(a0)+
		move d0,(a0)+
		move d0,(a0)+
	endif
	addq #1,d7
	cmp #256,d7
	bne.s .mov_loop
	bra .end_head
.avi_make:
	move.l header_buffer,a0
	move #255,d7
.avi_loop:
	if REG=1
		addq.l #3,a0
		rept 3
			move (a5)+,d0
			lsr #2,d0
			move.b d0,-(a0)
		endr
		addq.l #3,a0
	else
		moveq #0,d0
		move (a5)+,d0
		move (a5)+,d1
		add d1,d1
		add d1,d0	; 2*G + R
		move d0,d1
		add d0,d0
		add d1,d0		; 6*R + 3*G
		add (a5)+,d0	; 6*R + 3*G + B, the brightness (0 to 10000)
		divs #39,d0		; 0 to 256.111
		cmp #256,d0
		bmi.s .avi1
		move #255,d0
	.avi1:
		move.b d0,(a0)+
		move.b d0,(a0)+
		move.b d0,(a0)+
	endif
	sf (a0)+			; 0
	dbf d7,.avi_loop
	
.end_head:
	move 12(a2),d0
	addq #7,d0
	and.b #$f8,d0
	move d0,a4		; image width	
	move 14(a2),y	; image height
	move 2(a2),d0	; header in words
	add d0,d0
	add d0,a2		; datas
	move.l virtual,a3
.next_line:
	lea cvid_fix0+512,a0	; one line decompressed
	lea 0(a0,a4.w),a5		; end of one ligne uncompressed
	move.b #1,dup_line
.uncomp:
	cmp.l a5,a0
	bpl.s .end_of_line
	moveq #0,d0
	move.b (a2)+,d0
	bne.s .other
	move.b (a2)+,d0	; second byte
	bne.s .pat_run
	cmp.b #$ff,(a2)+
	bne .quit			; error
	move.b (a2)+,dup_line
	bra.s .uncomp
.pat_run:
	move pattern,d1
	move d1,d2
	subq #1,d2
	bra.s .p1
.p0:
	move d2,d3
	move.l a2,a1
.p2:
	move.b (a1)+,(a0)+
	dbf d3,.p2	
.p1:
	dbf d0,.p0
	add d1,a2
	bra.s .uncomp	
.other:
	cmp.b #$80,d0
	bne.s .solid
	move.b (a2)+,d0	; how many
	bra.s .o1
.o0:
	move.b (a2)+,(a0)+
.o1:
	dbf d0,.o0
	bra.s .uncomp
.solid:
	bclr #7,d0
	bne.s .black
	bra.s .white
.w0:
	sf (a0)+
.white:
	dbf d0,.w0
	bra.s .uncomp
.b0:
	st (a0)+
.black:
	dbf d0,.b0
	bra.s .uncomp
.end_of_line:
	move a4,d0
	lsr #3,d0		; bytes for one plane
	lea cvid_fix0+512,a0
	lea 0(a0,d0.w),a5	; end of the 1st plane for the loop
	move.l a3,-(sp)	; if it's to be repeated!
.next_8_pixels:
	move.l a0,a1
	move.b (a1),d0
	ror.l #8,d0
	move a4,d0
	lsr #3,d0
	add d0,a1
	move.b (a1),d1
	add d0,a1
	move.b (a1),d2
	add d0,a1
	move.b (a1),d3
	add d0,a1
	move.b (a1),d4
	add d0,a1
	move.b (a1),d5
	add d0,a1
	move.b (a1),d6
	add d0,a1
	move.b (a1),d7
	move #8,a1		; a loop
.pixel:
	lsl.b #1,d7
	roxl #1,d0
	lsl.b #1,d6
	roxl #1,d0
	lsl.b #1,d5
	roxl #1,d0
	lsl.b #1,d4
	roxl #1,d0
	lsl.b #1,d3
	roxl #1,d0
	lsl.b #1,d2
	roxl #1,d0
	lsl.b #1,d1
	roxl #1,d0
	rol.l #1,d0
	tst.b create_mov
	bne.s .no_grey
	and #$FF,d0
	move.b 0(a6,d0.w),(a3)+
	bra.s .common
.no_grey:
	move.b d0,(a3)+
.common:
	subq #1,a1
	cmp #0,a1
	bne.s .pixel
	addq.l #1,a0
	cmp.l a5,a0
	bmi.s .next_8_pixels
.copy_line:
	move max_imagex,d3
	sub a4,d3
	add d3,a3
	move.l (sp)+,a5		; old a3
	subq.b #1,dup_line
	beq.s .other_line
	subq #1,y
	move.l a3,-(sp)
	move a4,d0
	bra.s .cp1
.cp0:
	move.b (a5)+,(a3)+
.cp1:
	dbf d0,.cp0
	bra.s .copy_line
.other_line:	
	subq #1,y
	bne .next_line
	tst.b create_mov
	beq.s .display
	rts	
.display:
	move.l display_ste,a0
	jmp (a0)

bat_degas:
	tst.b create_mov
	bne.s .create_flm
	tst.b bat_getp					; read palette?
	beq.s .no_palette
	move.l buffer,a0
	pea 2(a0)						; the palette
	jsr set_palette
.no_palette:
	move.l physbase,a3				; the screen
	move.l buffer,a0
	add.l neo_degas_offs,a0					; skips the palette
	move #1999,d0
.copy:
	move.l (a0)+,(a3)+
	move.l (a0)+,(a3)+
	move.l (a0)+,(a3)+
	move.l (a0)+,(a3)+
	dbf d0,.copy
	rts
.create_flm:
	bsr display_add_frame
	tst.b bat_getp
	beq.s .out
	move.l buffer,a0
	addq.l #2,a0		; to the palette
	lea flm_header+68(pc),a1
	if REG=1
		rept 8
		move.l (a0)+,(a1)+	; copies the palette
		endr
	else
		moveq #15,d0
		lea grey_palette,a2
		.loop:
			moveq #0,d2
			move (a0)+,d1		; st format
			move d1,d2
			and #$888,d2
			lsr #3,d2
			and #$777,d1
			add d1,d1
			add d2,d1			; tt format
			move d1,d2
			and #$f0,d2			; green
			lsr #3,d2			; 2*G
			move d1,d3
			lsr #8,d3			; red
			add d3,d2
			move d2,d3
			add d2,d2
			add d3,d2			; 6*G + 3*R
			and #$F,d1
			add d1,d2			; 6G+3R+B = brightness (0 to 150)
			addq #4,d2
			divs #5,d2
			bclr #0,d2			; (0 to 30)
			move 0(a2,d2.w),(a1)+
			dbf d0,.loop
	endif			
.out:
	jmp compress_flm
nothing: rts

	
ooops:								; when an error occurs
	move.l a0,-(sp)				; saves the alert string
	tst.b display					; form_dial called?
	beq.s .lb0						; no, jump!
	move #3,fd_int
	GEM_AES form_dial				; updates the screen
	sf display
.lb0:
	tst.b command
	beq.s .lb1
	tst.b cmd_erro
	bne.s .lb1
	addq.l #4,sp					; drops A0
	bra.s .lb2
.lb1:
	bsr alert						; alert box
.lb2:
	st stopped
	bra end_of_display			; and exits

alert:
	clr mf_int
	GEM_AES graf_mouse			; the busy bee
	GEM_VDI show_mouse			; the mouse is required for an alert box
	move.l (sp)+,a0				; the return adress(( with BSR)
	move.l (sp),ab_addrin		; the string adress (PEA befor BSR)
	move.l a0,(sp)					; the return adress on the stack
	GEM_AES alert_box				; form alert
	move intout,-(sp)				; the exit button is saved
	GEM_VDI hide_mouse			; hides the mouse
	move (sp)+,d0					; the exit button is returned into D0
	rts		

read_byte:
	pea dum
	move.l #1,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	moveq #0,d0
	move.b dum,d0
	rts
	
	; reads a word from MOV file and returns it into D0 (long extended)
read_word:
	pea dum
	move.l #2,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	move dum,d0
	ext.l d0
	rts
	; read a long word from MOV file and returns it into D0
read_long:
	pea dum
	move.l #4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	move.l dum,d0
	rts
	; reads two long words from MOV file and returns then into D0(first)/D1
read_id_len:
read_len_id:
	pea dum
	move.l #8,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	move.l dum,d0
	move.l dum+4,d1
	rts
	
read_3_long:
	pea dum
	move.l #12,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	lea dum,a0
	move.l (a0)+,d0
	move.l (a0)+,d1
	move.l (a0),d2
	rts

	; d1 is the size wanted
malloc:
	move.l d1,-(sp)
	GEMDOS 72,6
	tst.l d0
	bmi.s .lb0
	beq.s .lb0
	rts				; ok
.lb0:
	lea mem_error,a0
	bra ooops
	
	;a2 is the adress to free or 0 (it is checked inside)
mfree:
	cmp.l #0,a2
	beq.s .end
	move.l a2,-(sp)
	GEMDOS 73,6
.end:
	rts

cookie:
	clr.l mch_value
	clr.l snd_value
	move.l $4f2,a0
	move.l 36(a0),kbshift	; address of the special keys
	move.l $5A0,a0
	cmp.l #0,a0
	beq.s .end				; no cookie!
.lb0:
	tst.l (a0)
	beq.s .end
	cmp.l #'_MCH',(a0)
	bne.s .lb2
	move.l 4(a0),mch_value
	bra.s .lb4
.lb2:
	cmp.l #'_SND',(a0)
	bne.s .lb3
	move.l 4(a0),snd_value
.lb3:
	cmp.l #'NOVA',(a0)
	bne.s .lb4
	st nova					; a NOVA graphic card!!
.lb4:
	addq.l #8,a0			; next cookie
	bra.s .lb0
.end: rts

gen_16_to_greyoffset:
	move.l hc_cvid,a6
	moveq #0,d0				; brightness
	moveq #31,d1
.lb1:
	moveq #31,d2
.lb2:
	moveq #31,d3
.lb3:
	move.l d0,d4			; brightness from 0 to 310
	lsl.l #8,d4				;     "        "  0 to 79360
	divs #4961,d4			;     "        "  0 to 15
	lsl.b #3,d4
	move.b d4,(a6)+		; the color index for that rgb
	addq.l #1,d0			; blue counts for 1
	dbf d3,.lb3
	sub.l #26,d0			; -32 (to reset the blue) and +6 (for the green)
	dbf d2,.lb2
	sub.l #189,d0			; -192 (to reset the green) and +3 (for the red)
	dbf d1,.lb1
	rts

	if REG=0
		
gen_16_to_16grey:
	move.l hc_cvid,a6
	moveq #0,d0				; brightness
	moveq #31,d1
.lb1:
	moveq #31,d2
.lb2:
	moveq #31,d3
.lb3:
	move.l d0,d4			; brightness from 0 to 310
	divs #10,d4				; 0 to 31
	move d4,d5
	lsl #5,d5
	or d5,d4
	lsl #5,d5
	or d5,d4
	move d4,(a6)+			; 16 bits but with grey scale
	addq.l #1,d0			; blue counts for 1
	dbf d3,.lb3
	sub.l #26,d0			; -32 (to reset the blue) and +6 (for the green)
	dbf d2,.lb2
	sub.l #189,d0			; -192 (to reset the green) and +3 (for the red)
	dbf d1,.lb1
	rts
	
	endif
	
set_colors:
	tst.b count
	bne.s .end				; no grey when counting
	tst.b is_mono
	bne.s .end
	pea grey_palette
	jsr set_palette
.end:
	rts
grey_palette:
	dc.w $000,$888,$111,$999,$222,$aaa,$333,$bbb
	dc.w $444,$ccc,$555,$ddd,$666,$eee,$777,$fff
	
indexs: dc.w 0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,1
	
grey_mov:
	move grey_depth,d0
	cmp #8,d0
	bne.s .fli1
	lea colors256,a6
	move #255,d0
.lb0:
	move d0,d1
	and.b #$F0,d1
	lsr d1
	move.b d1,(a6)+
	dbf d0,.lb0	
	moveq #0,d0		; returns EQ, set_colors needed
	rts
.fli1:
	cmp #4,d0
	bne.s .fli2
	pea grey16
	bra.s .common	
.fli2:
	pea .grey4
.common:
	jsr set_palette
	moveq #1,d0		; returns NE, set colors not needed
	rts
.grey4: dc.w $fff,$555,$AAA,$000
	; ,0,0,0,0,0,0,0,0,0,0,0,0
grey16:
	dc.w $fff,$777,$eee,$666,$ddd,$555,$ccc,$444
	dc.w $bbb,$333,$aaa,$222,$999,$111,$888,$000

save_16:
	lea col_sav,a6
	moveq #15,d0
	tst.b nova
	beq.s .lb1
	move #255,d0
.lb1:
	move d0,vq_int
.lb0:
	GEM_VDI vq_color
	lea intout+2,a0
	move.l (a0)+,(a6)+	; red+green
	move.w (a0),(a6)+		; blue
	subq #1,vq_int
	bpl.s .lb0
	rts

restore_16:
	lea col_sav,a6
	moveq #15,d0
	tst.b nova
	beq.s .lb1
	move #255,d0
.lb1;
	move d0,vs_int
.lb0:
	lea vs_int+2,a0
	move.l (a6)+,(a0)+
	move (a6)+,(a0)
	GEM_VDI vs_color
	subq #1,vs_int
	bpl.s .lb0
	rts
	
redraw:
	move #2,wu_int
	GEM_AES wind_update
	GEM_AES evnt_timer
	move #3,wu_int
	GEM_AES wind_update
	rts
		
init_rect:
	bsr redraw
	clr.l fd_int+10
	move.l work_out,d0
	add.l #$10001,d0
	move.l d0,fd_int+14
	GEM_VDI hide_mouse
	clr fd_int
	GEM_AES form_dial    ; reserves screen	
	tst.b create_mov
	if REG=0
		beq.s .no_create
		move.l comp_txt,d1
		cmp.l #'tga2',d1	
		bne .here_if_create
		move.l #65536,d1
		bsr malloc
		move.l d0,hc_cvid
		bsr gen_16_to_16grey
		bra .here_if_create
	.no_create:
	else
		bne .here_if_create
	endif
	move.l comp_txt,d1
	cmp.l #'cvid',d1
	beq.s .round
	cmp.l #'MSVC',d1
	beq.s .round
	cmp.l #'cram',d1
	beq.s .round
	move.l #$9689cccd,d0
	not.l d0
	cmp.l d0,d1
	beq.s .iv
	subq #1,d0
	cmp.l d0,d1
	bne.s .not_round
.iv:
	bsr init_iv32_buf
.round:
	addq #3,max_imagex
	and.b #$FC,max_imagex+1
.not_round:
	cmp.l #'flh ',d1
	beq.s .lb1a
	cmp.l #'tga2',d1
	beq.s .lb1a
	cmp.l #'rw16',d1
	beq.s .lb1a
	cmp.l #'rw24',d1
	beq.s .lb1a
	cmp.l #'rw32',d1
	beq.s .lb1a
	cmp.l #'rl32',d1
	beq.s .lb1a
	cmp.l #'rl24',d1
	beq.s .lb1a
	cmp.l #'rpza',d1
	beq.s .lb1a
	cmp.l #'rl16',d1
	beq.s .lb1a
	cmp.l #'msvc',d1
	beq.s .lb1b
	cmp.l #'MSVC',d1
	beq.s .lb1b
	cmp.l #'cram',d1
	bne.s .lb2
.lb1b:
	cmp #16,cram_bits
	bne.s .lb2
.lb1a:
	move.l #32768,d1
	bsr malloc
	move.l d0,hc_cvid
	bsr gen_16_to_greyoffset		; only for 16bits images displayed in 256c
.lb2:
	move.l comp_txt,d1
	cmp.l #'kin4',d1
	beq.s .next
	cmp.l #'seq4',d1
	beq.s .next
	cmp.l #'dlt4',d1
	beq.s .next
	cmp.l #'VMAS',d1
	beq.s .next
	swap d1
	cmp #'CD',d1
	beq.s .next
	move max_imagex,d1
	muls max_imagey,d1				; number of bytes for a 256 colors display
	addq.l #8,d1
	addq.l #7,d1
	and.b #$F0,d1						; 16 bytes aligned
	move.l d1,d3
	bsr malloc
	move.l d0,virtual					; virtual screen!!!
	move.l d0,a0
	lsr.l #4,d3
	moveq #0,d0
.del_virtual:
	rept 4
		move.l d0,(a0)+
	endr
	subq.l #1,d3
	bne.s .del_virtual
.next:
	tst.b is_mono
	bne .mono_display
	move.l #display_ste_normal,display_ste
	tst.b cmd_coord
	bne.s .xy2
	move #320,d0
	sub max_imagex,d0
	bpl.s .ste320
	move.l #display_ste_half,display_ste
	add #320,d0
	asr #2,d0
	and.b #$f0,d0
	move d0,offsx
	moveq #0,d2
	move #400,d1
	sub max_imagey,d1
	asr #1,d1
	bmi.s .hidden
	bra.s .ste200	
.xy2:
	move cmd_x,d0
	move d0,offsx
	move cmd_y,d1
	add d1,d1
	moveq #0,d2
	bra.s .ste200
.ste320:
	asr #1,d0
	and.b #$F0,d0						; 16 bits aligned
	move d0,offsx
	moveq #0,d2							; no hidden lines
	move #200,d1
	sub max_imagey,d1
	bpl.s .ste200
.hidden:
	neg d1
	asr #1,d1
	move d1,d2
	moveq #0,d1	
.ste200:
	move d2,flx_hide					; number of hidden lines
	asr #1,d1
	move d1,offsy
	muls #160,d1						; offset into screen
	ext.l d0
	asr.l #1,d0							; one pixel = half byte
	add.l d0,d1
	move.l physbase,a0
	add.l d1,a0
	move.l a0,image
.here_if_create:
	if REG=1								; verifies the matching of the codes
		moveq #2,d0
		move.l d0,rg_int
		GEM_AES rsrc_gaddr
		moveq #14,d0
		bsr ted_adr		
		lea 14(a1),a1
		lea code,a0
		moveq #5,d0
		.verif:
			move.b (a0),d1
			cmp.b (a1),d1
			bne.s .verif
			addq.l #1,a0
			addq.l #1,a1
		dbf d0,.verif
	endif
	rts
.mono_display:
	lea display_mono(pc),a0
	move max_imagex,d3
	move max_imagey,d4
	move.l comp_txt,d1
	move.b #'0',d1
	cmp.l #'dl/0',d1
	beq.s .double
	tst.b create_flm
	beq.s .no_double
	cmp #321,d3
	bpl.s .no_double
	cmp #201,d4
	bpl.s .no_double
.double:
	add d3,d3
	add d4,d4
	lea display_mono_double(pc),a0
.no_double:
	move.l a0,display_ste
	tst.b cmd_coord
	bne.s .xy
	move #640,d0
	sub d3,d0
	asr #1,d0
	and.b #$F0,d0						; 16 bits aligned
	move d0,offsx
	moveq #0,d2							; no hidden lines
	move #400,d1
	sub d4,d1
	bpl.s .ste400
	neg d1
	asr #1,d1
	move d1,d2
	moveq #0,d1	
	bra.s .ste400
.xy:
	move cmd_x,d0
	move d0,offsx	
	move cmd_y,d1
	add d1,d1
	moveq #0,d2
.ste400:
	move d2,flx_hide					; number of hidden lines
	asr #1,d1
	move d1,offsy
	muls #80,d1						; offset into screen
	ext.l d0
	asr.l #3,d0							; one pixel = 1/8 byte
	add.l d0,d1
	move.l physbase,a0
	add.l d1,a0
	move.l a0,image
	bra .here_if_create
	
verify_dma:	; for FLM create (PI1, NEO) only
	sf bad_sound
	cmp #8,sound_bits
	bne.s .bad
	move.l frequency,d0
	moveq #0,d1
	move #12517,d1
	cmp #12266,d0
	bmi.s .bad
	cmp #12767,d0
	bmi.s .set_freq
	move #25033,d1
	cmp #24532,d0
	bmi.s .bad
	cmp #25533,d0
	bmi.s .set_freq
	cmp.l #49064,d0
	bmi.s .bad
	cmp.l #51067,d0
	bpl.s .bad		
.set_freq:
	move.l d1,frequency
	bra.s .good	
.bad:
	st bad_sound
.good:
	rts
		
	; verifies the frequency and the resolution and the channels

verify_sound:
	tst.b slide_degas
	bne.s verify_dma
	move.l comp_txt,d4
	cmp.l #'VMAS',d4
	beq .ok2
	move.b #'0',d4
	cmp.l #'flm0',d4
	beq .ok2
	swap d4
	cmp #'CD',d4
	beq .ok2
	move.l s_signe,d4
	cmp.l #'twos',d4
	beq.s .ok4
	cmp.l #'raw ',d4
	beq.s .ok4
	cmp.l #'rawa',d4
	bne .bye
.ok4:
	move.l #12517,d4
	move.l frequency,d1
	move.l d1,_freq_sav
	cmp.l #10900,d1
	bmi .bye
	cmp.l #11350,d1		; for 12,5kHz, 10,9 to 11,3 are accepted
	bmi.s .ok
	move.l #25033,d4
	cmp.l #21800,d1
	bmi.s .bye
	cmp.l #22700,d1		; for 25kHz, 21,8 to 22,7 are accepted
	bmi.s .ok	
	move.l #50066,d4
	cmp.l #43600,d1
	bmi.s .bye
	cmp.l #45400,d1
	bpl.s .bye
.ok:
	move.l d4,frequency	
	move sound_bits,d1
	cmp #8,d1
	beq.s .ok2
	cmp #16,d1
	bne.s .bye
.ok2:
	move channels,d1
	cmp #1,d1
	beq.s .ok3
	cmp #2,d1
	bne.s .bye
.ok3:
	sf bad_sound
	rts
.bye:
	st bad_sound
	rts

adapt_d4_size:
	tst.b create_flm
	beq.s .normal
	move.l d3,d4			; one sound at a time while saving
	bra.s .next
.normal:
   tst.b _snd
   bmi.s .next				; don't create, but DMA, so st‚r‚o accepted
   cmp #2,channels
   bne.s .next
   asr.l #1,d4				; with no DMA: no stereo, so half size
.next:
	cmp #8,sound_bits
	beq.s .lb9				; 8 bits, normal
	asr.l #1,d4				; else, 16 bits are converted into 8, half size
.lb9:
	addq.l #7,d4
	asr.l #3,d4				; rounded to the number of 8 bytes groups
	move.l d4,-(sp)
	asl.l #3,d4
	if REG=1
		tst.b create_flm	; if create, acts like DMA
		bne.s .dma
	endif
	tst.b _snd
	bmi.s .dma
	sub.l (sp)+,d4			; = 7/8 of d4 (8 bytes will take 7 with no DMA)
	move.l frequency,d0
	divs #12516,d0			; 1, 2 or 4
.other_size:
	lsr d0
	beq.s .common
	lsr.l d4
	bra.s .other_size
.dma:
	add.l (sp)+,d4			; = d4 * 9/8
.common:
	move.l d4,snd_size
	rts
		
init_sound:
	sf playing
	sf sync						; default is no synchronization, no sound
	tst.b bad_sound
	bne .bye
	move.l sound_offs,a6		; table with offset (present) and size (computed here)
	cmp.l #0,a6
	beq .bye
.lb0:
	move.l sound_num,d7
	move.l chunkoff_num,d6
	move.l chunkoffs,a5
	moveq #0,d4					; the total size of the sound (bytes)
	moveq #0,d3					; the max size (for one sample)
.lb1:
	move.l (a6)+,d0
.lb3:
	tst.l d6
	beq.s .lb5
	cmp.l (a5),d0
	bmi.s .lb2
	addq.l #4,a5
	subq.l #1,d6
	bra.s .lb3
.lb2:
	move.l (a5),d1
	cmp.l #1,d7
	beq.s .lb4
	cmp.l 4(a6),d1
	bmi.s .lb4
.lb6:
	move.l 4(a6),d1
.lb4:
	sub.l d0,d1
	move.l d1,(a6)+		; the size
	cmp.l d1,d3
	bpl.s .lb8				; below the max size
	move.l d1,d3			; else, it's a new size!
.lb8:
	add.l d1,d4
	bra.s  .lb7
.lb5:
	cmp.l #1,d7
	bne.s .lb6
	move.l mdat_end,d1
	bra.s .lb4
.lb7:
	subq.l #1,d7
	bne.s .lb1
	bsr adapt_d4_size
	move.l tree_sav,a0
	btst #0,275(a0)
	beq.s .bye
	bsr read_sound			; reads the whole sound into memory
.bye:
	bsr sync_tab
	rts
	
read_sound:
	move.l d3,-(a7)
	GEMDOS $48,6
	tst.l d0
	bmi .end				; not enough memory for the temporary buffer
	move.l d0,snd_temp
	beq .end
	move.l d0,a3
	move.l d4,stram_size	; default value if all fits in it
	move.l #-1,-(a7)		; asks for the memory available
	GEMDOS $48,6
	tst.l d0
	bmi .end					; an error
	beq .end
	cmp.l d4,d0				; compared to the memory wanted
	bmi .end				; not enough!
	move.l d4,-(sp)
	GEMDOS $48,6
	move.l d0,s_buffer
	beq .end
	move.l d0,a6
	move.l sound_offs,a5
	move.l sound_num,d7
	movem.l d2-d7/a2-a6,-(sp)
	moveq #1,d6
	moveq #1,d7
	bsr manage_tree
	if REG=1
		tst.b create_flm
		beq.s .no_head
		bsr flm_snd_ext
	.no_head:
	endif
	movem.l (sp)+,d2-d7/a2-a6
.lb0:
	SEEK (a5)+,0			; to the good position
	move.l (a5)+,d6
	move.l a3,-(sp)		; into the temporary buffer
	move.l d6,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	tst.l d0
	bmi .end					; an error
	bsr treat_sound		; copies temp into the real buffer, updates a6
	if REG=1
		tst.b create_flm
		beq.s .no_snd_sav
		bsr flm_snd_save
	.no_snd_sav:
	endif
	subq.l #1,d7
	bne.s .lb0
	move.l a6,d0
	bclr #0,d0
	move.l d0,a6			; turns A6 into an even address
	move.l a6,snd_end
	sub.l s_buffer,a6
	move.l a6,stram_size
	movem.l d2-d7/a2-a6,-(sp)
	moveq #1,d6
	moveq #-1,d7
	bsr manage_tree
	if REG=1
		tst.b create_flm
		beq.s .no_ext
		lea flm_header(pc),a0
		add.l flm_off(pc),a0
		move.l a0,a6
		add.l flm_hsize(pc),a0	; points to flm_sound
		move.l 10(a0),d7
		move.l d7,snd_size	; real size (for sync)
		addq.l #8,d7
		addq.l #6,d7			; plus the little header
		btst #0,d7
		beq.s .yet_even
		addq.l #1,d7			; to an even address
		pea (a6)
		moveq #1,d0
		move.l d0,-(sp)
		move mov_h2,-(sp)
		GEMDOS 64,12			; writes one byte more!
	.yet_even:
		move.l d7,4(a6)		; size of the current extension
	.no_ext:
	endif
	movem.l (sp)+,d2-d7/a2-a6
	if REG=1
		tst.b create_flm
		bne.s .end				; no playing while creating!
	endif
	st playing				; ok for playing the sound!
.end:
	rts	

; converting 8 bytes into 9 bytes is equal to converting
; 11025 Hz into 12403 Hz, 22050 Hz into 24806 Hz and 44100 Hz into 49612 Hz
; witch are very close to the DMA frequencies: 12517, 25033 and 50066,
; this is an very good approximation (error 1%).

; if no DMA, converts 8 bytes to 7 (11025 to 9647)
; or 16 bytes to 7 (22050 to 9647)
; or 32 bytes to 7 (44100 to 9647)
; for use with Timer A at 9600Hz

treat_sound:
	cmp.l #16,d6		; enough???
	bpl.s .ok
	rts
.ok:
	tst.b create_flm
	bne.s .dma				; if create, acts like DMA
	tst.b _snd
	bpl yamaha_treat_sound
.dma:
	move.l a3,a0			; temporary buffer
	cmp #8,sound_bits
	bne bits_16				; it's a 16 bits sample
	move.l d6,d0			; the size
	asr.l #3,d6				; blocs of 8 bytes
	and #7,d0				; remaining
	cmp.l #'twos',s_signe
	bne.s .sign
.lb2:
	rept 8
		move.b (a0)+,(a6)+
	endr
	move.b -1(a0),(a6)+	; repeats the last one
	subq.l #1,d6
	bne.s .lb2
	bra.s .lb3
.lb4:
	move.b (a0)+,(a6)+
.lb3:
	dbf d0,.lb4				; copies the remaining
	rts
.sign:
	moveq #-128,d1
.lb5:
	rept 8
		move.b (a0)+,d2
		add.b d1,d2
		move.b d2,(a6)+	; copies and signs 8 bytes
	endr
	move.b d2,(a6)+		; repeats the 8th byte
	subq.l #1,d6
	bne.s .lb5
	bra.s .lb6
.lb7:
	move.b (a0)+,d2
	add.b d1,d2
	move.b d2,(a6)+		; copies and signs the remaining
.lb6:
	dbf d0,.lb7
	rts	
bits_16:
	cmp.l #'rawa',s_signe	; avi sound?
	bne.s .lb0
	addq.l #1,a0			; the 8 high bits are in the lower byte (Intel)
.lb0:
	asr.l #1,d6
	move.l d6,d0				
	asr.l #3,d6				; blocs of 16 bytes (8 bytes in the destination)
	and #7,d0				; remaining
.lb2:
	rept 7
		move.b (a0),(a6)+		; 8 high bits
		addq.l #2,a0
	endr
	move.b (a0),d2				; the 8th byte
	move.b d2,(a6)+			; repeated
	move.b d2,(a6)+
	addq.l #2,a0
	subq.l #1,d6
	bne.s .lb2
	bra.s .lb3
.lb4:
	move.b (a0),(a6)+
	addq.l #2,a0
.lb3:
	dbf d0,.lb4				; copies the remaining
	rts

yamaha_treat_sound:
	move.l frequency,d0
	mulu sound_bits,d0
	lsr.l #2,d0
	divs #25033,d0			; step in d0.w
	move.l a3,a0			; temporary buffer
	lsr.l #3,d6				; blocs of 8
	move.l d0,d1
.other_size
	lsr d1
	beq.s .good_size
	lsr.l d6
	bra.s .other_size
.good_size:
	cmp #2,channels
	beq yamaha_treat_stereo
	cmp #8,sound_bits
	beq.s .lb20				; only 8 bits samples can be signed
	cmp.l #'rawa',s_signe	; for 16 bits samples...
	bne.s .lb2
	addq.l #1,a0				; ... some are in Intel format
	bra.s .lb2
.lb20:
	cmp.l #'twos',s_signe
	bne.s .sign
.lb2:
	rept 7
		move.b (a0),(a6)+
		bne.s *+8
		move.b #1,-1(a6)		
		add d0,a0
	endr
	add d0,a0	; skips the last one
	subq.l #1,d6
	bne.s .lb2
	clr.b (a6)		; it's maybe the last one!
	rts
.sign:
	moveq #-128,d1
.lb5:
	rept 7
		move.b (a0),d2
		add.b d1,d2
		bne.s *+4
		moveq #1,d2
		move.b d2,(a6)+	; copies and signs 8 bytes
		add d0,a0
	endr
	add d0,a0
	subq.l #1,d6
	bne.s .lb5
	clr.b (a6)				; maybe the last one!
	rts	
yamaha_treat_stereo:
	add d0,d0					; everything is doubled
	moveq #1,d3					; for 8 bits stereo signed
	cmp #8,sound_bits
	beq.s .lb20					; only 8 bits samples can be signed
	moveq #2,d3					; 16 bits stereo signed
	cmp.l #'rawa',s_signe	; for 16 bits samples...
	bne.s .lb2
	addq.l #1,a0				; ... some are in Intel format
	bra.s .lb2
.lb20:
	cmp.l #'twos',s_signe
	bne .sign
.lb2:
	rept 7
		move.b (a0),d1
		move.b 0(a0,d3.w),d2	; one or two bytes ahead
		ext.w d1
		ext.w d2
		add d1,d2
		asr d2
		move.b d2,(a6)+
		bne.s *+8
		move.b #1,-1(a6)		
		add d0,a0
	endr
	add d0,a0	; skips the last one
	subq.l #2,d6
	bgt .lb2
	clr.b (a6)		; it's maybe the last one!
	rts
.sign:
	moveq #-128,d3
.lb5:
	rept 7
		moveq #0,d1
		move.b (a0),d1
		moveq #0,d2
		move.b 1(a0),d2
		add d1,d2
		lsr d2
		add.b d3,d2
		bne.s *+4
		moveq #1,d2
		move.b d2,(a6)+	; copies and signs 8 bytes
		add d0,a0
	endr
	add d0,a0
	subq.l #2,d6
	bgt .lb5
	clr.b (a6)				; maybe the last one!
	rts	


sync_tab:
	move.l tree_sav,a0
	btst #0,299(a0)		; objetc 'synchronize'
	beq .end					; no sync
	move.l t2samps,a0
	cmp.l #0,a0	
	beq .end					; no time table for each frame
	move.l t2samp_num,d2
	moveq #0,d4				; total time
	moveq #0,d3				; total frames
.lb0:
	move.l (a0)+,d0		; number of frames
	add.l d0,d3				; updates the number of frames
	addq.l #2,a0
	mulu (a0)+,d0			; times their duration
	add.l d0,d4				; updates the total time
	subq.l #1,d2
	bne.s .lb0				; till the end of t2_samps
	move.l d3,d1
	asl.l #2,d1				; each entry is a long (4 bytes)
	addq.l #8,d1			; plus two dummy entries (the first and the last)
	bsr malloc
	move.l d0,a1

	move.l tree_sav,a0
	btst #0,275(a0)
	beq.s .scale
	tst.b bad_sound
	bne.s .scale
	tst.l sound_offs
	bne.s .sound

.scale:
	move.l #200,d1
	move.l qt_timescale,d4
	bne.s .go_on
	move.l #1000,d4
	bra.s .go_on

.sound:
	move.l frequency,-(sp)
	move.l snd_size,d1	; the size in bytes
	tst.b create_flm
	bne.s .dma
	tst.b _snd
	bmi.s .dma
	move.l #9600,frequency
	bra.s .lb5				; without DMA, stereo yet treated!
.dma:	
	cmp #2,channels
	bne.s .lb5				; not a stereo, 1byte = 1sample
	asr.l #1,d1				; else 2bytes = 1 sample
.lb5:
	divu frequency+2,d1	; number of seconds for the whole sound
	move.l d1,d0
	muls #200,d0			; number of 1/200 (for entire seconds)
	swap d1
	muls #200,d1			; the remainder
	divu frequency+2,d1	
	swap d1
	clr d1
	swap d1
	add.l d0,d1				; d1=number of 200th of second for the whole sample
								; to use the Timer C of the system
	move.l (sp)+,frequency							
.lb6:
	cmp.l #65536,d4
	bpl.s .reduce
	cmp.l #65536,d1
	bmi.s .go_on
.reduce:
	lsr.l d4
	lsr.l d1
	bra.s .lb6
	
.go_on:
	move.l t2samps,a0
	move.l a0,a2			; for mfree
	move.l a1,t2samps
	move.l t2samp_num,d2
	move.l d3,t2samp_num ; new number
	clr.l (a1)+				; the first entry contains 0 (start of the sound)
	moveq #0,d6
.lb1:
	move.l (a0)+,d0		; number of frames
	move.l (a0)+,d7		; duration of one frame
.lb2:
	add.l d7,d6				; from the start
	move.l d6,d3			; the duration (in time)
	mulu d1,d3
	divu d4,d3				; d3 is the corresponding duration in 1/200 sec
	swap d3
	clr d3
	swap d3
	move.l d3,(a1)+
	subq.l #1,d0
	bne.s .lb2
	subq.l #1,d2
	bne.s .lb1
	st sync
	bsr mfree
	move.l t2samps,a0		; points to the dummy, but the numbers start at 1
	move.l t2samp_num,d2
	lsl.l #2,d2
	bset #7,0(a0,d2.l)	; the last is always marked!
	lsr.l #2,d2
	sf sync+1				; we can skip a key frame (default)
	move.l ss_tab,a1
	cmp.l #0,a1
	beq.s .lb4				; no stss table! No particular frame, mark all
	move.l ss_num,d0		; else, number of particular frames
	divs d0,d2				; number of frames for one key frame
	cmp #8,d2				; more than 4?
	bmi.s .lb3
	st sync+1				; yes, we will never skip one key frame
.lb3:
	move.l (a1)+,d1
	lsl.l #2,d1
	bset #7,0(a0,d1.l)	; marks this address
	subq.l #1,d0
	bne.s .lb3
	bra.s .end
.lb4:
	addq.l #4,a0			; the next one (jumps over the dummy)
	bset #7,(a0)			; marks every frame
	subq.l #1,d2
	bne.s .lb4
.end:
	rts


displ_info:
	move.l kbshift,a0
	move.b (a0),d0
	and.b #$3,d0
	bne .sound_select	; skip info box if SHift
	clr mf_int
	GEM_AES graf_mouse
	GEM_VDI show_mouse
	moveq #1,d7
	moveq #2,d6
	bsr manage_tree
	move #$101,eb_int+4
	GEM_AES evnt_button
	move.l kbshift,a0
	move.b (a0),d0
	move d0,-(sp)			; keeps the shift state
	moveq #-1,d7
	moveq #2,d6
	bsr manage_tree
	clr eb_int+4
	GEM_AES evnt_button
	GEM_VDI hide_mouse
	move (sp)+,d0			; shift state
	and.b #$3,d0
	bne.s .sound_select
	rts
.sound_select:
	moveq #0,d7
	moveq #5,d6
	bsr manage_tree
	move.l tree,a0
	add.w #131,a0			; selected of first radio button
	moveq #-1,d7			; DMA
.find:
	btst #0,(a0)
	bne.s .found
	add.w #24,a0			; next object
	addq #1,d7
	cmp #4,d7
	bmi.s .find
	moveq #0,d7				; Yamaha if error...
.found:
	move.b d7,_snd
	cmp #10,d6				; save and exit???????
	beq.s .save
	rts
.error:
	rts
.save:
	move #2,-(sp)
	pea _name
	GEMDOS 61,8				; fopen
	move.l d0,d5
	bmi.s .error
	lea cvid_fix0,a5
	clr -(sp)
	move d5,-(sp)
	clr.l -(sp)
	GEMDOS 66,10
	pea (a5)
	move.l #20,-(sp)
	move d5,-(sp)
	GEMDOS 63,12
	clr -(sp)
	move d5,-(sp)
	moveq #0,d0
	move 18(a5),d0
	move.l d0,-(sp)
	GEMDOS 66,10
	pea (a5)
	move.l #24,-(sp)
	move d5,-(sp)
	GEMDOS 63,12
	clr -(sp)
	move d5,-(sp)
	move.l 20(a5),d0
	moveq #120,d4
	add.l d4,d0
	move.l d0,-(sp)
	GEMDOS 66,10
	pea (a5)
	move.l d4,-(sp)
	move d5,-(sp)
	GEMDOS 63,12
	moveq #-1,d0
	lea 11(a5),a0
.update_flags:
	bclr #0,(a0)
	cmp d0,d7
	bne.s .other_flag
	bset #0,(a0)
.other_flag:
	add.w #24,a0
	addq #1,d0
	cmp #4,d0
	bmi.s .update_flags
	move #1,-(sp)
	move d5,-(sp)
	neg.l d4
	move.l d4,-(sp)
	GEMDOS 66,10
	neg.l d4
	pea (a5)
	move.l d4,-(sp)
	move d5,-(sp)
	GEMDOS 64,12
	move d5,-(sp)
	GEMDOS 62,4
	rts
		
flm_snd_ext:
	lea flm_header(pc),a0
	add.l flm_off(pc),a0
	add.l flm_hsize(pc),a0
	move.b channels+1,9(a0)
	moveq #0,d0
	move.l frequency,d1
	addq #1,d0				; 1 for 12,5 kHz
	cmp.l #12517,d1
	beq.s .start
	addq #1,d0
	cmp.l #25033,d1		; 2 for 25 kHz
	beq.s .start
	addq #1,d0				; else 3 for 50 kHz
.start:
	move.b d0,8(a0)
	clr.l 10(a0)			; size reset for now
	pea (a0)
	moveq #14,d0
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12			; writes that little header
	rts
		
flm_snd_save:
	move.l a6,d0			; end of sound
	move.l s_buffer,a6
	sub.l a6,d0				; size of sound
	lea flm_header(pc),a0
	add.l flm_off(pc),a0
	add.l flm_hsize(pc),a0
	add.l d0,10(a0)		; size of sound updated
	pea (a6)
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12			; writes the sound
	rts


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
	tst.b command
	beq.s .normal
	cmp #1,d6
	beq.s .normal			; Loading sound...
	move.l #cmd_dial,a1
	tst.b (a1)+
	bne.s .normal			; dialogs allowed
	tst d6
	bne .out				; other than the first dialog
	move.l tree,a0
	bclr #0,275(a0)
	bclr #0,299(a0)		; the two buttons unset
	tst.b (a1)+				; cmd_play
	beq.s .k1
	bset #0,275(a0)
.k1:
	tst.b (a1)+				; cmd_sync
	beq.s .k2
	bset #0,299(a0)
.k2:
	move.l kbshift,a0
	bclr #3,(a0)
	tst.b (a1)				; cmd_alt
	beq.s .k3
	bset #3,(a0)			; alternate
.k3:
	moveq #9,d6				; GO button
	rts
.normal:
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
	move.l tree,a0
	tst d6
	bne.s .no_rep
	btst #0,467(a0)		; repeat or not?
	sne is_rep
.no_rep:
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
	bsr redraw
	cmp #18,d6				; close button???
	beq end_end				; quit the program
.out:
	rts

	; a3 contains the address of the string indicating the type of file
	; d3=1 for 'Play sound' and 'Synchronize'
	; d3=0 for 'Max speed ' and 'xxx.x f/s' (_delay contains duration per frame)
	; samp_sizes indicates if there are graphics
	;	- max_imagex and max_imagey gives the size
	;	- samp_num gives the number of frames
	;
	; frequency indicates if there is a sound
	; - sound_bits gives the resolution
	; - frequency gives the frequency
	; - channels gives mono or stereo
	
fill_dialog:
	clr.l rg_int		; first tree
	GEM_AES rsrc_gaddr
	move.l tree,a1
	move.l 228(a1),a1	; spec of button (Alt) Go!
	move.l #'   G',(a1)+
	move.l #'o!  ',(a1)+
	move.w #$2000,(a1)	; space and 0
	

	
	sf step_mode
	clr.l rg_int		; first tree
	GEM_AES rsrc_gaddr
	move.l tree,a1
	move.l a1,tree_sav
	move.l 228(a1),a1	; spec of button Go!
	lea .txt15(pc),a0
	tst.w d3				; bit #15 set if 'Alt go allowed'
	bpl.s .lb12
	lea .txt16(pc),a0
.lb12:
	if REG=1
		tst.b is_mono
		bne.s .no_shift
		tst.b can_count
		beq.s .no_shift
		add #20,a0			; txt15 to txt17 or txt16 to txt18
		.no_shift:
	endif
	bsr copy_string
	move.l tree,a1
	tst.b d3
	bne.s .lb9
	bset #4,273(a1)
	bset #4,297(a1)	; radio buttons
	bclr #0,275(a1)	; max speed unset
	lea 324(a1),a1		; string adr
	move.l (a1),play_sav
	move.l #max,(a1)
	lea 24(a1),a1
	move.l (a1),sync_sav
	move.l #delay,d0
	move.l d0,(a1)
	move.l d0,a1
	move.l #2000,d0
	divs _delay+2,d0	; frames/10 sec
	ext.l d0
	divs #10,d0
	move.l d0,d5
	ext.l d0
	bsr int_to_str				; the int part
	move.b #'.',(a1)+
	swap d5
	add.b #'0',d5
	move.b d5,(a1)+
	move.b #' ',(a1)+
	move.b #'f',(a1)+
	move.b #'/',(a1)+
	move.b #'s',(a1)+
	clr.b (a1)
.lb9:
	moveq #15,d0
	bsr ted_adr	
	moveq #25,d0
.lb10:
	move.b (a3)+,(a1)+	; the 24 caracters (maxi)
	dbf d0,.lb10
	moveq #17,d0
	bsr ted_adr
	lea dta+30,a0
	lea 11(a1),a1
	moveq #11,d0
.lb11:
	move.b (a0)+,(a1)+
	dbf d0,.lb11
	moveq #2,d0
	bsr ted_adr
	tst.l samp_sizes
	bne.s .graphics
	clr.b (a1)
	moveq #3,d0
	bsr ted_adr
	lea .txt1(pc),a0
	bsr copy_string
	moveq #4,d0
	bsr ted_adr
	clr.b (a1)
	bra .lb3
.graphics:
	lea .txt2(pc),a0
	bsr copy_string
	moveq #0,d0
	move max_imagex,d0
	bsr int_to_str
	move.b #' ',(a1)+
	move.b #'x',(a1)+
	move.b #' ',(a1)+
	move max_imagey,d0
	bsr int_to_str
	moveq #3,d0
	bsr ted_adr
	lea .txt3(pc),a0
	bsr copy_string
	move.l sample_num,d0
	bsr int_to_str
	lea .txt4(pc),a0
	bsr copy_string
	moveq #4,d0
	bsr ted_adr
	tst.b bad_comp
	beq.s .lb2
	lea .txt5(pc),a0
	bra.s .lb1
.lb2:
	lea .txt6(pc),a0
.lb1:
	bsr copy_string
	lea comp_txt,a0
	bsr copy_string
.lb3:
	moveq #6,d0
	bsr ted_adr
	move.l frequency,d3
	bne.s .sound
	clr.b (a1)
	moveq #7,d0
	bsr ted_adr
	lea .txt7(pc),a0
	bsr copy_string
	moveq #8,d0
	bsr ted_adr
	clr.b (a1)
	moveq #0,d2				; play sound unselected
	bra .lb4
.sound:
	lea .txt8(pc),a0
	bsr copy_string
	moveq #0,d0
	move sound_bits,d0
	bsr int_to_str
	cmp #2,channels
	beq.s .lb5
	lea .txt9(pc),a0
	bra.s .lb6
.lb5:
	lea .txt10(pc),a0
.lb6:
	bsr copy_string
	moveq #7,d0
	bsr ted_adr
	lea .txt11(pc),a0
	bsr copy_string
	move.l d3,d0
	bsr int_to_str
	lea .txt12(pc),a0
	bsr copy_string
	bsr verify_sound
	moveq #8,d0
	bsr ted_adr
	tst.b bad_sound
	beq.s .lb7
	lea .txt13(pc),a0
	moveq #0,d2				; don't play sound
	bra.s .lb8
.lb7:
	lea .txt14(pc),a0
	moveq #1,d2				; play sound
.lb8:
	bsr copy_string
.lb4:
	move.l tree,a0
	bset #0,299(a0)	; xx.x frames set or synchro
	btst #4,273(a0)		; radio buttons?
	bne.s .end				; yes, don't touch!
	bclr #0,275(a0)
	or.b d2,275(a0)		; state of play sound
.end:
	rts	
.txt1: dc.b " No graphics found",0
.txt2: dc.b "Display ",0
.txt3: dc.b "with ",0
.txt4: dc.b " frames.",0
.txt5: dc.b "Unsupported (",0
.txt6: dc.b " Supported (",0
.txt7: dc.b "No sound",0
.txt8: dc.b "Sound ",0
.txt9: dc.b " bits mono",0
.txt10: dc.b "bits stereo",0
.txt11: dc.b "at ",0
.txt12: dc.b " Hz.",0
.txt13: dc.b 'Unsupported',0
.txt14: dc.b 'Supported',0
.txt15: dc.b '   Go!   ',0
.txt16: dc.b '(Alt) Go!',0
	if REG=1
.txt17: dc.b '   Go!  ',0
.txt18: dc.b '(Alt)Go!',0
	endif

	even	

copy_string:
	move.b (a0)+,(a1)+
	bne.s copy_string
	subq.l #1,a1
	rts
	
	; upon entry: d0 is the index of the string
	; on exit: a1 is the address of the string
	
string_adr:
	move.l tree,a1
	muls #24,d0
	move.l 12(a1,d0.w),a1	; adr of the string
	rts
	
ted_adr:
	bsr.s string_adr
	move.l (a1),a1
	rts
	
	; upon entry, d0 is the integer
	;				  a1 is the address to put it	
	; upon exit, a1 is updated.
	
int_to_str:
	lea intout+100,a0			; as a buffer
	clr.b (a0)					; to end the string
.lb0:
	divu #10,d0
	swap d0
	add.b #'0',d0
	move.b d0,-(a0)			; one char
	clr d0
	swap d0
	tst.l d0
	bne.s .lb0					; not nul, continue!
.lb1:
	move.b (a0)+,(a1)+
	bne.s .lb1
	subq.l #1,a1
	rts

fill_stat:
	moveq #3,d0
	move.l d0,rg_int			; the 3rd dialog
	GEM_AES rsrc_gaddr
	moveq #11,d0
	bsr ted_adr
	lea dta+30,a0				; file name
	moveq #11,d0
.lb0:
	move.b (a0)+,(a1)+
	dbf d0,.lb0
	moveq #4,d0
	bsr string_adr
	move.l sample_num,d6
	move.l d6,d0
	bsr int_to_str
	moveq #5,d0
	bsr string_adr
	move.l disp_frame,d5
	move.l d5,d0
	bsr int_to_str
	move.b #' ',(a1)+
	move.b #'(',(a1)+
	move.l d5,d0
	mulu #100,d0
	divu d6,d0				; in %
	ext.l d0
	bsr int_to_str
	move.b #'%',(a1)+
	move.b #')',(a1)+
	clr.b (a1)
	moveq #6,d0
	bsr string_adr
	move.l d5,d0
	mulu #2000,d0
	move.l end_time,d6
	sub.l start_time,d6
	divu d6,d0				; number of frames in 10 seconds
	swap d0
	clr d0
	swap d0
	divs #10,d0
	move.l d0,d5
	ext.l d0
	bsr int_to_str				; the int part
	move.b #'.',(a1)+
	swap d5
	add.b #'0',d5
	move.b d5,(a1)+
	clr.b (a1)
	moveq #10,d0				; total time
	bsr string_adr
	divu #20,d6				; 1/200 into 1/10 of sec
	swap d6
	clr d6
	swap d6
	divs #10,d6
	move.l d6,d0
	ext.l d0
	bsr int_to_str				; the int part
	move.b #".",(a1)+
	swap d6
	add.b #'0',d6
	move.b d6,(a1)+
	lea .txt1(pc),a0
	bsr copy_string
	rts
.txt1: dc.b ' sec',0
	even

set_video:
	tst.b count
	beq.s .lb1
	rts						; if count, no res change
.lb1:
	tst old_video
	beq.s .lb0				; yet in 320x200x16
	tst.b is_mono
	bne.s .lb2				; mono display, no res_change!
	moveq #0,d1
	tst.b nova
	bne.s .lb3				; no res change on graphic card
	clr -(sp)
	moveq #-1,d0
	move.l d0,-(sp)
	move.l d0,-(sp)
	XBIOS 5,12
.lb0:
	tst.b cmd_coord
	bne.s .laisser2
	move #0,vi_int
	GEM_VDI vsf_color
	GEM_VDI v_bar			; else, just blacks the screen
.laisser2:
	rts
.lb2:
	tst.b cmd_coord
	bne.s .laisser
	moveq #-1,d1
.lb3:
	move.l physbase,a0
	move #1999,d0
.lb4:
	rept 4
		move.l d1,(a0)+
	endr
	dbf d0,.lb4
.laisser:
	rts
	
	
vsf_interior: dc.l vi_cont,vi_int,dum,dum,dum
vi_cont: dc.w 23,0,0,1,0,0,0,0,0,0,0,0
vi_int: dc.w 1


	
restore_video:
	tst.b count
	bne.s .end				; if count, no res change
	tst.b is_mono
	bne.s .end				; in mono, no res change	
	move old_video,d0
	beq.s .end				; we were yet in ST Low
	tst.b nova
	bne.s .end
	move d0,-(sp)			; else, comes back to the original resolution
	moveq #-1,d0
	move.l d0,-(sp)
	move.l d0,-(sp)
	XBIOS 5,12
.end:
	rts


;debug:
;	movem.l d0-d2/a0-a2,-(sp)
;	move.l #$20007,-(sp)
;	BIOS 3,6
;	move.l #$20002,-(sp)
;	trap #13
;	addq.l #4,sp
;	movem.l (sp)+,d0-d2/a0-a2
;	rts

bat_read_header:
	sf create_mov
	sf slide_gif
	sf create_avi
	sf qt_palette		; if 8 planes (RLE8 encoding)
	move #1,bat_gif_loop
	move #5,quality	; default!
	clr key_rate		; default no key frame
	move.l #$20202020,d7
	SEEK #0,0			; start of file
	bsr read_id_len
	or.l d7,d0
	cmp.l #'mpl',d0	; lower for 'M_PL'
	beq.s .half_ok
.error:
	moveq #-1,d0
	rts
.half_ok:
	or.l d7,d1
	cmp.l #'ayer',d1
	bne.s .error
	lea cvid_fix1,a5
	move.l a5,-(sp)
	move.l #12480,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	move.l d0,total
	bmi.s .error
	clr.b 0(a5,d0.l)		; end of file marked with a 0
	moveq #0,d6				; bit map of every option found
.parse_header:
	bsr bat_next_line
	or.b d7,d0			; to lower
	cmp.b #'=',1(a5)
	bne .end_head
	addq.l #2,a5			; skips X= (X beeing w,h,r,f,c,o)
	cmp.b #'w',d0
	bne.s .h0
	bsr get_number
	move d0,max_imagex
	bset #0,d6
	bra.s .parse_header
.h0:
	cmp.b #'h',d0
	bne.s .h1
	bsr get_number
	move d0,max_imagey
	bset #1,d6
	bra.s .parse_header
.h1:
	cmp.b #'f',d0
	bne.s .h2
	bsr get_number
	move.l d0,sample_num
	bset #16,d6
	bra.s .parse_header
.h2:
	cmp.b #'t',d0
	bne.s .h3
	bsr get_number
	move.l d0,_delay
	bset #17,d6
	bra.s .parse_header
.h3:
	cmp.b #'b',d0
	bne.s .h4
	bsr get_number
	move.l d0,max_fsize
	bset #2,d6
	bra.s .parse_header
.h4:
	cmp.b #'o',d0
	bne.s .h5
	st create_mov
	cmp.b #'#',(a5)		; avi file?
	bne.s .h4a
	addq.l #1,a5			; skips '#'
	st create_avi
.h4a:	
	lea out_file,a0
	bsr get_name
	bset #18,d6
	bra .parse_header
.h5:
	cmp.b #'s',d0
	bne.s .h6
	lea sound_file,a0
	bsr get_name
	bsr read_sound_header
	bset #17,d6
	bra .parse_header
.h6:
	cmp.b #'q',d0
	bne.s .h7
	bsr get_number
	move d0,quality
	bra .parse_header
.h7:
	cmp.b #'k',d0
	bne.s .h8
	bsr get_number
	move d0,key_rate
	bra .parse_header
.h8:
	cmp.b #'r',d0
	bne.s .h9
	bsr get_number
	move d0,bat_gif_loop
	bra .parse_header
.h9:
	cmp.b #'v',d0
	bne.s .h10
	bsr treat_vr_infos
	bra .parse_header	
.h10:
	cmp.b #'m',d0
	bne.s .h11
	bsr get_number
	move.l d0,vanel_adr
	st mountain
	bra .parse_header
.h11:
	cmp.b #'c',d0
	bne .error
	GET_LONG a5,d0		; compression (4 char)
	or.l d7,d0
	move.l d0,comp_txt
	cmp.l #'ximg',d0
	bne.s .c4
	move.l #bat_ximg_256,d0
	move.l d0,comp_create
	st qt_palette
	bra .c1
.c4:
	cmp.l #'tga2',d0
	bne.s .c5
	move.l #bat_tga,comp_create
	move.l #bat_tga_256,d0
	bra.s .c1
.c5:
	cmp.l #'dega',d0
	bne.s .c6
	moveq #34,d0
.c5b:
	move.l d0,neo_degas_offs
	move.l #bat_degas,d0
	move.l d0,comp_create
	st slide_degas
	or.b #$7,d6			; w, h, b
	move.l #33000,max_fsize
	move #320,max_imagex
	move #200,max_imagey
	bra.s .c1
.c6:
	cmp.l #'neoc',d0
	bne.s .c7
	move.l #128,d0
	bra.s .c5b
.c7:
	cmp.l #'gif8',d0
	bne.s .c0
	move.l #bat_gif,d0
	st slide_gif
.c1:
	move.l d0,compression
	bra.s .c2
.c0:
	st bad_comp
.c2:
	bset #3,d6
	bra .parse_header
.end_head:
	cmp.l #bat_tga,comp_create
	bne.s .lb0
	move max_imagex,d0
	addq #3,d0
	and.b #$FC,d0
	move d0,max_imagex	
.lb0:
	cmp.l #bat_ximg_256,comp_create
	bne.s .lb1
	move max_imagex,d0
	addq #7,d0
	and.b #$F8,d0
	move d0,max_imagex
.lb1:
	move quality,d0
	cmp #5,d0
	bmi.s .q_ok
	moveq #5,d0
.q_ok:
	cmp #1,d0
	bpl.s .q_ok2
	moveq #1,d0
.q_ok2:
	lea qual,a0
	add d0,d0
	move -2(a0,d0.w),quality	
	GET_LONG a5,d0
	or.l d7,d0
	cmp.l #'data',d0
	bne .error
	move.l a5,bat_ptr
	cmp #$f,d6
	beq.s .ok
	lea insuf_info,a0
	bra ooops
.ok:
	tst.b create_mov
	beq.s .ok2
	tst.b slide_gif
	beq.s .ok3
	bclr #7,create_mov		; positive for a GIF
.ok3:
	swap d6
	cmp #$7,d6
	beq.s .ok2
	lea insuf_info2,a0
	bra ooops
.ok2:
	bsr verify_vr_infos
	st samp_sizes
	moveq #0,d0
	rts
qual: dc.w $4210,$6318,$739c,$7bde,$7fff

treat_vr_infos:
	lea vr_y,a0
	bsr .number
	cmp.b #','-'0',d1
	bne.s .erreur
	move d0,6(a0)		; largeur X
	bsr.s .number
	cmp.b #','-'0',d1
	bne.s .erreur
	move d0,(a0)		; hauteur Y
	bsr.s .number	
	cmp.b #','-'0',d1
	bne.s .erreur
	move d0,10(a0)		; start X
	bsr.s .number
	cmp.b #','-'0',d1
	bne.s .erreur
	move d0,4(a0)		; start Y
	bsr.s .number
	cmp.b #','-'0',d1
	bne.s .erreur
	move d0,-4(a0)		; img/cell
	bsr.s .number
	move d0,8(a0)
	subq.l #1,a5		; back on CR/LF
	st create_vr
	rts
.erreur:
	lea .texte,a0
	bra ooops
.texte: dc.b "[1][ 6 values are needed | with 'v=' option! ][Ooops!]",0
	even
.number:
	moveq #0,d0
	moveq #0,d1
.lb0:
	move.b (a5)+,d1
	sub.b #'0',d1
	bmi.s .lb1
	muls #10,d0
	add.l d1,d0
	bra.s .lb0
.lb1:
	rts
	
verify_vr_infos:
	tst.b create_vr
	beq.s .fin			; Ok, no VR wanted
	lea .frame(pc),a0
	lea vr_y,a1
	move (a1),d0
	move 6(a1),d1
	move -4(a1),d2
	muls d1,d2
	muls d0,d2			; total of images
	cmp.l sample_num,d2
	bne ooops
	lea .coord(pc),a0
	subq #1,d0
	cmp 4(a1),d0
	bmi ooops
	subq #1,d1
	cmp 10(a1),d1
	bmi ooops
	moveq #0,d0
	move -4(a1),d0		; img_cell
	move key_rate,d1
	beq.s .warn
	divs d1,d0
	swap d0
	tst d0
	beq.s .fin			; no reminder, cool!
.warn:
	pea .key(pc)
	bsr alert
.fin:
	rts
.frame: dc.b "[1][ QuickTime VR infos | do not match the | total number of frames! ][Ooops!]",0
.coord: dc.b "[1][ QuickTime VR first cell | is out of range! ][Ooops!]",0
.key: dc.b "[1][ QuickTime VR key rate (k=xxxx) | doesn't match the number"
		dc.b " | of images per cell.| Hope you use '.keyf'... ][Thanks!]",0
		
		even

; uses a0,d0
; updates a5

get_name:
	moveq #0,d0
.copy:
	move.b (a5)+,d0
	cmp #$21,d0
	bmi.s .end
	move.b d0,(a0)+
	bra.s .copy
.end:
	clr.b (a0)
	subq.l #1,a5
	rts
	
; uses d0
; updates a5

bat_next_line:
	moveq #0,d0
.lb0:
	move.b (a5)+,d0		; looks for the end of a line
	cmp.b #13,d0
	beq.s .lb1
	cmp.b #10,d0
	bne.s .lb0
.lb1:
	move.b (a5)+,d0		; skips every CR,LF,space or tabulation
	cmp.b #33,d0
	bmi.s .lb1
	move.b -(a5),d0		; back to the first char
	cmp.b #';',d0			; a comment?
	beq.s .lb0				; yes! another line!
	rts

read_sound_header:
	clr -(sp)
	pea sound_file
	GEMDOS 61,8
	move.l d0,d3
	bmi .end
	move #2,-(sp)		; from the end
	move d3,-(sp)
	clr.l -(sp)
	GEMDOS $42,10
	move.l d0,snd_size	; total size of the file
	clr -(sp)			; from the start
	move d3,-(sp)
	clr.l -(sp)
	GEMDOS $42,10
	pea cvid_fix0
	move.l #36,-(sp)	; enough for WAV or AVR header
	move d3,-(sp)
	GEMDOS 63,12
	move d3,-(sp)
	move.l d0,d3
	GEMDOS 62,4
	tst.l d0
	bmi .end
	cmp.l #36,d3
	bne .end
	lea cvid_fix0,a0
	cmp.l #'2BIT',(a0)
	bne .not_avr
	sf little_indian				; not an Intel format
	move.l #128,sound_seek
	sf bad_sound
	move #1,channels
	tst 12(a0)
	beq.s .lb0
	move #2,channels
.lb0:
	move 14(a0),sound_bits
.lb1:
	move.l #'twos',s_signe
	tst 16(a0)
	bne.s .lb2
	move.l #'raw ',s_signe
.lb2:
	move.l 22(a0),frequency
	clr.b frequency
.treat_size:
	move.l snd_size,d0	; total size
	sub.l sound_seek,d0	; minus the header size
	move.l d0,snd_size
	move.l d0,d1
	lsr.l #7,d0
	lsr.l #8,d0		; number of blocs of 32768 bytes
	and.l #$7FFF,d1	; remaining
	cmp #2048,d1
	bpl.s .lb4
	add.l #32768,d1	; added to the last bloc
	bra.s .lb3
.lb4:
	addq.l #1,d0	; one more bloc (it's large enough to be alone)
.lb3:
	moveq #0,d2		; size added to the original header
	cmp.l #1,d0
	beq.s .lb6
	move.l d0,d2
	asl.l #2,d2
	addq.l #8,d2	; 4*n + 8 = number of bytes added
.lb6:
	move.l d0,bloc_num
	move.l d1,last_size
	move.l d2,size_added
.end:
	rts	
.not_avr:
	cmp.l #'RIFF',(a0)
	bne.s .end
	sf bad_sound
	move.l #44,sound_seek
	move 22(a0),d0
	ror #8,d0
	move d0,channels
	move.l 24(a0),d0
	INTEL d0
	move.l d0,frequency
	move 34(a0),d0
	ror #8,d0
	move d0,sound_bits
	cmp #16,d0
	seq little_indian			; true if Intel 16 bits
	beq.s .rawa_16
	move.l #'raw ',s_signe	; 8 bits are unsigned
	bra .treat_size
.rawa_16:
	move.l #'twos',s_signe	; 16 bits are signed...
	bra .treat_size
	
bat_read_data:
	tst.b bad_comp
	beq.s .ok
	rts
.ok:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
	clr flx_start
	move max_imagey,flx_number
	move.l bat_ptr,a5		; bat pointer
	lea cvid_fix1,a6		; stack pointer for loops
	clr.l disp_frame
	sf bat_getp
	move.l $4ba.w,start_time
	move.l $4ba.w,current_time
.loop:
	move.l kbshift,a0
	btst #2,(a0)
	bne .exit
	bsr bat_next_line
	cmp.b #'.',d0			; a command?
	beq.s .comm
	bsr bat_new_file	
	bra .display
.comm:
	addq.l #1,a5
	GET_LONG a5,d0
	or.l #$20202020,d0	; to lower
	cmp.l #'disp',d0
	beq .display
	cmp.l #'rept',d0
	bne.s .c0
	addq.l #1,a5
	bsr get_number
	move.l a5,-(a6)		; return address
	move.l d0,-(a6)		; how many loops
	bra.s .loop
.c0:
	cmp.l #'endr',d0
	bne.s .c2
	subq.l #1,(a6)
	beq.s .lb0				; end of loop
	move.l 4(a6),a5		; else goes back
	bra.s .loop
.lb0:
	addq.l #8,a6
	bra.s .loop
.c2:
	cmp.l #'incr',d0
	bne.s .c3
	move.l tga_digit,a0
.lb1:
	move.b (a0),d0
	addq.b #1,d0
	cmp.b #'9'+1,d0
	bmi.s .good
	move.b #'0',(a0)
	subq.l #1,a0
	bra.s .lb1
.good:
	move.b d0,(a0)
	bra .loop
.c3:
	cmp.l #'decr',d0
	bne.s .c4
	move.l tga_digit,a0
.lb2:
	move.b (a0),d0
	subq.b #1,d0
	cmp.b #'0',d0
	bpl.s .good
	move.b #'9',(a0)
	subq.l #1,a0
	bra.s .lb2
.c4:
	cmp.l #'getp',d0
	bne.s .c5
	st bat_getp		; next frame will change the palette
	bra .loop
.c5:
	cmp.l #'keyf',d0
	bne.s .c6
	st key_frame	; next frame is a key one!
	bra .loop
.c6:
	cmp.l #'stop',d0
	beq .exit
	bra .exit				; unknown command!
.display:
	tst.b mountain
	beq.s .normal
	bsr .mountain_image
	bra .common	
.normal:
	clr -(sp)
	pea tga_full
	GEMDOS 61,8				; fopen
	move.l d0,d6			; handle
	bmi .loop
	move.l buffer,-(sp)
	move.l max_fsize,-(sp)
	move d6,-(sp)
	GEMDOS 63,12			; fread
	move.l d0,d5
	move d6,-(sp)
	GEMDOS 62,4				; fclose
	tst.l d5
	bmi .loop
	beq .loop
.common:
	addq.l #1,disp_frame
	move.l current_time,d0
.delay:
	cmp.l $4ba.w,d0
	bpl.s .delay
	add.l _delay,d0
	move.l d0,current_time
	move.l compression,a0
	movem.l a5-a6,-(sp)
	jsr (a0)
	movem.l (sp)+,a5-a6
	sf bat_getp
	sf key_frame
	bra .loop
.exit:
	move.l $4ba.w,end_time
	move.l stack_adr,-(sp)
	GEMDOS 32,6
	rts
; vanel_adr: LONG sa routine
;				LONG le numero d'image que je demande
;				LONG l'adress ou il a ses pixels WORDS
;				WORD $FFFF si 16 bits Falcon, $0000 si 15 bits NOVA

.mountain_image:
	movem.l a5-a6,-(sp)
	move.l vanel_adr,a0
	move.l (a0)+,a5			; routine
	move.l disp_frame,(a0)	; image needed
	move.l stack_adr,-(sp)
	GEMDOS 32,6
	jsr (a5)
	movem.l (sp)+,a5-a6
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
	move.l vanel_adr,a0
	move.l buffer,a1			; mon buffer
	move.l #$00000200,(a1)+
	clr.l (a1)+
	clr.l (a1)+
	move max_imagex,d0
	ror #8,d0
	move d0,(a1)+
	move max_imagey,d1
	ror #8,d1
	move d1,(a1)+
	move #$1020,(a1)+
	ror #8,d0
	ror #8,d1
	muls d0,d1					; nombre de pixels
	move.l 8(a0),a2			; ses pixels
	move 12(a0),d0				; flag
	beq.s .copy_nova
	cmp #$FFFF,d0
	beq.s .copy_falc
	rts							; mauvais flag, on s'en fout
.copy_nova:
	move.w (a2)+,(a1)+
	subq.l #1,d1
	bne.s .copy_nova
	rts
.copy_falc:
	move (a2)+,d0
	NOVA16 d0
	swap d0
	move d0,(a1)+
	subq.l #1,d1
	bne.s .copy_falc
	rts


bat_new_file:
	lea tga_full,a0
	move.l a0,a1
.lb0:
	move.b (a5)+,d0
	move.b d0,(a0)+
	cmp.b #'\',d0
	bne.s .lb1
	move.l a0,a1
.lb1:
	cmp.b #33,d0
	bpl.s .lb0			; another!
	subq.l #1,a5
	clr.b -(a0)
.lb2:
	move.b (a1)+,d0
	beq.s .lb3			; the end!
	cmp.b #'.',d0
	bne.s .lb2
.lb3:
	subq.l #2,a1
	move.l a1,tga_digit
	rts
	
; uses d0,d1
; updates a5
get_number:
	moveq #0,d0				; the number
.lb0:
	moveq #0,d1
	move.b (a5)+,d1
	sub.b #'0',d1
	bmi.s .end
	cmp.b #'9'+1,d1
	bpl.s .end
	asl.l d0					; *2
	add.l d0,d1				; *2 + x
	asl.l #2,d0				; *8
	add.l d1,d0				; *10 + x
	bra.s .lb0
.end:
	subq.l #1,a5
	rts

init_create_avi:
	move.l _freq_sav,frequency
	seq bad_sound
	pea create_avi_text
	GEMDOS 9,6
	move max_imagex,d0
	addq #7,d0
	and.b #$F8,d0			; 8 aligned
	move d0,max_imagex
	move max_imagey,d1
	move d0,d3
	muls d1,d3				; size of one image
	lea avi_header,a0
	ror #8,d0
	move d0,176(a0)
	move d0,64(a0)
	ror #8,d0
	ror #8,d1
	move d1,180(a0)
	move d1,68(a0)
	ror #8,d1
	INTEL d3
	move.l d3,192(a0)
	INTEL d3
	move.l sample_num,d2
	INTEL d2
	move.l d2,140(a0)
	move.l d2,48(a0)
	move.l d3,d1
	bsr malloc
	move.l d0,one_buffer
	move.l d3,d1
	bsr malloc
	move.l d0,two_buffer
	move.l d3,d1
	asr.l d3
	add.l d3,d1				; 1.5 x size of screen with bad compression!
	move.l #32768+2048+8,d3
	cmp.l d3,d1		; enough for one sound?
	bpl.s .enough
	move.l d3,d1	; no, so new size
.enough:
	bsr malloc
	move.l d0,rle16_buffer
	move.l sample_num,d1
	tst.b bad_sound
	bne.s .nos1
	add.l bloc_num,d1		; plus the blocs for sound
.nos1:
	asl.l #4,d1				; 16 bytes for each
	add.l #1024+8,d1			;  plus the palette + idx1 + size
	bsr malloc
	move.l d0,header_buffer
	move.l d0,a0
	lea 1024(a0),a0
	move.l #'idx1',(a0)+
	clr.l (a0)+
	move.l a0,size_ptr
	clr -(sp)
	pea out_file
	GEMDOS 60,8
	tst.l d0
	bgt.s _end
	lea cant_create,a0
	bra ooops
	
rsrc_load: dc.l rl_cont,global,dum,intout,rsc_name,dum
rl_cont: dc.w 110,0,1,1,0
rsc_name: dc.l _name
	
_end:
	move d0,mov_h2
	lea avi_header,a0
	move.l _delay,d1
	muls #5000,d1		; number of microsecond per frame
	INTEL d1
	move.l d1,32(a0)
	move.l d1,128(a0)
	pea (a0)
	move.l #avi_end_header-avi_header,d1
	add.l #1024+12,d1		; plus the palette + LIST size 'movi'
	tst.b bad_sound
	bne.s .nos2
	add.l #100,d1			; plus the sound header
.nos2:
	move.l d1,-(sp)
	move d0,-(sp)
	GEMDOS 64,12	; write
	tst.b bad_sound
	beq.s .sound
	rts				; no sound, work is ended for init!
.sound:	
	pea sound_text
	GEMDOS 9,6
	move.l _freq_sav,frequency
	clr -(sp)
	pea sound_file
	GEMDOS 61,8
	move.l d0,d3
	clr -(sp)
	move d3,-(sp)
	move.l sound_seek,-(sp)
	GEMDOS 66,10		; skips header!
	move.l rle16_buffer,a3
	move.l bloc_num,d4	; number of blocs
	move.l size_ptr,a4	; idx1 section
.loop_sound:
	move.l #32768,d6		; one bloc
	move.l #'01wb',(a3)
	move.l (a3),(a4)+		; id
	clr.l (a4)+				; flags
	clr.l (a4)+				; offsets later
	subq.l #1,d4
	bne.s .not_last
	move.l last_size,d6
.not_last:
	INTEL d6
	move.l d6,(a4)+		; size
	move.l d6,4(a3)		; size
	INTEL d6
	pea 8(a3)
	move.l d6,-(sp)
	move d3,-(sp)
	GEMDOS 63,12		; fread
	bsr treat_avi_sound
	addq.l #8,d6		; +01wb + size
	move.l a3,-(sp)
	move.l d6,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12		; fwrite
	tst.l d4
	bne.s .loop_sound
	move d3,-(sp)
	GEMDOS 62,4
	move.l a4,size_ptr
.exit:
	lea avi_sound_header,a0
	moveq #1,d4
	move.l snd_size,d3
	move.b channels+1,d0
	cmp.b d4,d0
	beq.s .mono
	add d4,d4
	asr.l d3
.mono:
	move.b d0,86(a0)
	move.b sound_bits+1,d0
	cmp.b #8,d0
	beq.s .eight
	add d4,d4
	asr.l d3
.eight:
	move.b d0,98(a0)
	move.l #32768,d0
	cmp.l last_size,d0
	bpl.s .max_found
	move.l last_size,d0
.max_found:
	INTEL d0
	move.l d0,56(a0)
	move.b d4,40(a0)
	move.b d4,64(a0)
	move.b d4,96(a0)
	move.l frequency,d0
	INTEL d0
	move.l d0,88(a0)
	INTEL d0
	mulu d4,d0			; freq * scale
	INTEL d0
	move.l d0,44(a0)
	move.l d0,92(a0)
	INTEL d0
	lea _op2,a3
	move.l d0,(a3)+
	move.l sample_num,(a3)
	bsr spmul			; freq*scale*sample_num
	move.l snd_size,d1
	moveq #0,d2			; nbr of shifts
.more:
	addq #1,d2
	lsl.l d1
	btst #30,d1
	beq.s .more
	move.l (a3),d0
	move.l d1,(a3)			; divid
	move.l d0,-(a3)		; divis
	bsr spdiv
	move.l #15625,(a3)+
	bsr spmul
	move.l (a3),d1
	subq #6,d2
	beq.s .end2		
	bmi.s .plus
.minus:
	lsr.l d1
	subq #1,d2
	bne.s .minus
	bra.s .end2
.plus:
	lsl.l d1
	addq #1,d2
	bne.s .plus
.end2:	
	INTEL d3
	move.l d3,52(a0)
	lea avi_header,a0
	INTEL d1
	move.l d1,32(a0)
	move.l d1,128(a0)
	rts

vq_color: dc.l vq_cont,vq_int,dum,intout,dum
vq_cont: dc.w 26,0,0,2,0,0,0,0,0,0,0,0
vq_int: dc.w 0,1

treat_avi_sound:
	lea 8(a3),a0		; data pointer
	move.l d6,d0		; size in bytes
	cmp #8,sound_bits
	beq _eight
	asr.l d0
	subq.l #1,d0		; prepared for dbf
	move #$8000,d2		; to unsign raw 16 bits
	cmp.l #'twos',s_signe
	bne.s _raw_16
	tst.b little_indian	; here signed 16 bits
	bne.s .end				; Intel format, so Ok
.to_intel:
	move (a0),d1
	ror #8,d1
	move d1,(a0)+
	dbf d0,.to_intel
.end:
	rts	

wind_update: dc.l wu_cont,global,wu_int,dum,dum,dum
wu_cont: dc.w 107,1,1,0,0

_raw_16:
	move (a0),d1
	add d2,d1
	ror #8,d1
	move d1,(a0)+
	dbf d0,_raw_16
	rts

vsf_color: dc.l vc_cont,vi_int,dum,dum,dum
vc_cont: dc.w 25,0,0,1,0,0,0,0,0,0,0,0

_eight:
	subq.l #1,d0			; prepared for dbf
	cmp.l #'raw ',s_signe
	beq.s .end				; raw 8 bits, nothing to change
	moveq #-128,d2
.sign_8:
	add.b d2,(a0)+
	dbf d0,.sign_8
.end:
	rts

init_create_degas:
	pea degas_text
	GEMDOS 9,6
	lea flm_off(pc),a0
	clr.l (a0)
	move.l #flm_snd-flm_header,d0
	move.l d0,4(a0)
	tst.l frequency
	bne.s .next
	st bad_sound
.next:
	tst.b bad_sound
	bne _create_degas		; no sound alignment
	lea _op2(pc),a0
	move.l sample_num,(a0)+
	move.l frequency,(a0)
	bsr spmul
	move.l (a0),d1
	move.l d1,degas_div
	move.l snd_size,(a0)
	moveq #100,d0
	cmp #2,channels
	beq.s .ok
	add.l d0,d0
.ok:
	move.l d0,-(a0)
	bsr spmul
	move.l d1,(a0)
	bsr spdiv	
	lea degas_r(pc),a1
	move.l (a0)+,(a1)+
	move.l (a0),(a1)
	jmp _create_degas
	
init_create:
	tst.b slide_gif
	bne init_create_gif
	tst.b create_avi
	bne init_create_avi
	tst.b slide_degas
	bne init_create_degas
	pea create_text
	GEMDOS 9,6
	bsr mac_date			; fills the dates with the MAC format
	move max_imagex,d0
	addq #3,d0
	and.b #$Fc,d0			; 4 bits aligned
	move max_imagey,d1
	move d0,d3
	muls d1,d3
	move.l d3,d4
	add.l d4,d4				; size for one 'screen'
	asl.l #1,d3
	add.l d4,d3
	ext.l d1
	add.l d1,d3
	add.l d1,d3
	add.l #14,d3			; max size for a frame (coded with RLE16)
	tst.b qt_palette
	beq.s .true_col
	asr.l #1,d3
	asr.l #1,d4				; for 8 planes, half the size!
.true_col:
	move.l d3,d1
	move.l d3,snd_temp_size	; if sound is to be loaded...
	bsr malloc
	move.l d0,rle16_buffer
	move.l d4,d1
	bsr malloc
	move.l d0,one_buffer
	move.l d4,d1
	bsr malloc
	move.l d0,two_buffer
	move.l _freq_sav,frequency
	beq.s .no_sound
	move.l snd_size,d0
	bsr size_into_samples
	move.l d0,d4

	divu frequency+2,d4	; number of seconds for the whole sound
	move.l d4,d0
	muls #1000,d0			; number of 1/1000 (for entire seconds)
	swap d4
	muls #1000,d4			; the remainder
	divu frequency+2,d4	
	swap d4
	clr d4
	swap d4
	add.l d0,d4				; d1=number of 1000th of second for the whole sample
	divu sample_num+2,d4
	swap d4
	clr d4
	swap d4					; number of 1000th of second per frame
	sf bad_sound
	bra.s .next
.no_sound:
	st bad_sound
	move.l _delay,d4		; time for one sample
	move.l d4,d5
	lsl.l #2,d5
	add.l d5,d4				; in 1/1000
.next:
	move.l d4,d5
	move.l d4,_delay
	lea mov_header,a3
	move.l sample_num,d1
	mulu d1,d5				; total time
	asl.l #2,d1				; each size is 4 bytes long
	move.l d1,d6			; variable size
	add.l (a3),d1			; size of header
	tst.b bad_sound
	bne.s .lb2
	add.l sound_header,d1	; plus the sound header length
	add.l size_added,d1		; plus extra size (if >1 bloc of sound)
.lb2:
	tst.b qt_palette
	beq.s .no_pal
	add.l #2056,d1			; for the palette
	add.l #2056,d6
.no_pal:	
	move.l d1,header_size
	bsr malloc
	move.l d0,header_buffer
	move.l d0,a0			; fills the header!
	move.l header_size,(a0)+
	addq.l #4,a3			; 'moov' size
	moveq #6,d0
	bsr copy_longs
	move.l d5,(a0)+		; total time (mvhd)
	moveq #18,d0
	bsr copy_longs
	move.l (a3)+,d0		; next track is 2
	tst.b bad_sound
	bne.s .lb0
	addq.l #1,d0			; if sound, it is 3!
.lb0:
	move.l d0,(a0)+
	bsr make_size			; 'trak'
	moveq #7,d0
	bsr copy_longs
	move.l d5,(a0)+		; total time (tkhd)
	move (a3)+,(a0)+
	moveq #11,d0
	bsr copy_longs
	bsr copy_xy
	move (a3)+,(a0)+
	moveq #5,d0
	bsr copy_longs
	move.l d5,(a0)+		; total time (elst)
	moveq #1,d0
	bsr copy_longs
	bsr make_size			; 'mdia'
	moveq #6,d0
	bsr copy_longs
	move.l d5,(a0)+		; 'mdhd'
	moveq #14,d0
	bsr copy_longs
	bsr make_size			; 'minf'
	moveq #28,d0
	bsr copy_longs
	bsr make_size			; 'stbl'
	move.l (a3)+,(a0)+
	tst.b qt_palette
	beq.s .no_pal2
	move.l #2056,d0
	sub.l d0,d6
	move.l (a3)+,d1
	add.l d0,d1
	move.l d1,(a0)+		; new stsd size
	move.l (a3)+,(a0)+
	move.l (a3)+,(a0)+
	move.l (a3)+,(a0)+
	add.l (a3)+,d0
	move.l d0,(a0)+		; new video codec size
	bra.s .cont
.no_pal2:
	moveq #4,d0
	bsr copy_longs			; if no palette, just copies
.cont:	
	moveq #6,d0
	bsr copy_longs
	move max_imagex,(a0)+
	move max_imagey,(a0)+
	move (a3)+,(a0)+
	moveq #11,d0
	bsr copy_longs
	tst.b qt_palette
	beq.s .no_pal3
	moveq #8,d1
	swap d1					; 8 planes, flag=0000
	move.l d1,-4(a0)		; overwrites 16 planes and flag=FFFF
	move.l a0,mov_pal
	lea 2056(a0),a0		; jumps over the palette
.no_pal3:
	moveq #3,d0
	bsr copy_longs
	move.l sample_num,(a0)+
	move.l _delay,(a0)+
	moveq #4,d0
	bsr copy_longs
	move.l sample_num,(a0)+
	move.l (a3)+,(a0)+
	bsr make_size			; 'stsz'
	moveq #2,d0
	bsr copy_longs
	move.l sample_num,(a0)+
	move.l a0,size_ptr
	add.l d6,a0
	moveq #3,d0
	bsr copy_longs
	move.l (a3)+,d0
	add.l snd_size,d0
	move.l d0,(a0)+		; offset of images (8 + size of sound)
	tst.b bad_sound
	bne .lb1
	lea sound_header,a3
	move.l size_added,d6	; if >1 bloc of sound
	bsr make_size			; trak
	moveq #7,d0
	bsr copy_longs			; tkhd
	move.l d5,(a0)+
	moveq #20,d0
	bsr copy_longs
	move.l d5,(a0)+
	move.l (a3)+,(a0)+
	move.l (a3)+,(a0)+
	bsr make_size			; 'mdia'
	moveq #5,d0
	bsr copy_longs
	move.l frequency,(a0)+
	move.l snd_size,d0
	bsr size_into_samples
	move.l d0,(a0)+
	moveq #14,d0
	bsr copy_longs
	move (a3)+,(a0)+
	bsr make_size			; minf
	moveq #27,d0
	bsr copy_longs
	move (a3)+,(a0)+
	bsr make_size			; stbl
	moveq #5,d0
	bsr copy_longs
	move.l s_signe,(a0)+
	moveq #3,d0
	bsr copy_longs
	move channels,(a0)+
	move sound_bits,(a0)+
	move.l (a3)+,(a0)+
	move.w frequency+2,(a0)+
	clr (a0)+
	moveq #3,d0
	bsr copy_longs
	move.l snd_size,d0
	bsr size_into_samples
	move.l d0,(a0)+
	move.l (a3)+,(a0)+
	move.l bloc_num,d0
	cmp.l #1,d0
	bne.s .more
	moveq #4,d0
	bsr copy_longs		; stsc 1
	bra.s .common
.more:
	move.l #$28,(a0)+	; stsc 2
	addq.l #4,a3
	move.l (a3)+,(a0)+
	move.l (a3)+,(a0)+
	move.l #2,(a0)+
	move.l #1,(a0)+
	move.l #32768,d0
	bsr size_into_samples
	move.l d0,(a0)+
	move.l #1,(a0)+
	move.l d0,(a0)+
	addq.l #8,a3
.common:	
	move.l last_size,d0
	bsr size_into_samples
	move.l d0,(a0)+
	moveq #4,d0			; stsz
	bsr copy_longs
	move.l snd_size,d0
	bsr size_into_samples
	move.l d0,(a0)+
	cmp.l #1,bloc_num
	bne.s .more2
	moveq #4,d0
	bsr copy_longs
	bra.s .lb1	
.more2:
	sub.l #12,d6
	bsr make_size	
	moveq #1,d0
	bsr copy_longs
	move.l bloc_num,d0
	move.l d0,(a0)+
	addq.l #4,a3	
	move.l (a3)+,d1		; first offset
.loop_off:
	move.l d1,(a0)+
	add.l #32768,d1
	subq.l #1,d0
	bne.s .loop_off
.lb1:
	lea udta_header,a3
	bsr fill_navg_data
	moveq #19,d0
	bsr copy_longs
	clr -(sp)
	pea out_file
	GEMDOS 60,8
	tst.l d0
	bgt .end
	lea cant_create,a0
	bra ooops
.end:
	move d0,mov_h2
	pea dum
	move.l #8,-(sp)
	move d0,-(sp)
	GEMDOS 64,12	; writes 8 dummy bytes (size + mdat)
	tst.b bad_sound
	bne .exit
	pea sound_text
	GEMDOS 9,6
	clr -(sp)
	pea sound_file
	GEMDOS 61,8
	move.l d0,d3
	clr -(sp)
	move d3,-(sp)
	move.l sound_seek,-(sp)
	GEMDOS 66,10		; skips header!
	move.l snd_temp_size,d6
	and.b #$F0,d6		; rounded
	move.l rle16_buffer,a3
	move.l snd_size,d4
.loop_sound:
	cmp.l d6,d4
	bpl.s .lb3
	move.l d4,d6
.lb3:
	sub.l d6,d4
	move.l a3,-(sp)
	move.l d6,-(sp)
	move d3,-(sp)
	GEMDOS 63,12		; fread
	tst.b little_indian
	beq.s .lb4
	move.l a3,a0
	move.l d6,d1
	subq.l #1,d1
.lb5:
	move (a0),d0
	ror #8,d0
	move d0,(a0)+
	subq.l #2,d1
	bpl.s .lb5
.lb4:
	move.l a3,-(sp)
	move.l d6,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12		; fwrite
	tst.l d4
	bne.s .loop_sound
	move d3,-(sp)
	GEMDOS 62,4
.exit:	
	rts
init_create_gif:
	sf smc_a
	pea gif_text
	GEMDOS 9,6		; displays the title
	clr -(sp)
	pea out_file
	GEMDOS 60,8
	tst.l d0
	bgt .end
	lea cant_create,a0
	bra ooops
.end:	
	move d0,mov_h2		; keeps the handle!
	move.l _delay,d0
	addq.l #1,d0
	lsr.l #1,d0
	swap d0
	tst d0
	beq.s .ok_time
	moveq #0,d0
.ok_time:
	swap d0
	ror #8,d0
	move d0,delay_gif
	rts
	
fill_navg_data:
	tst.b create_vr
	bne.s .lb0
	move.l #'skip',12(a3)
	rts
.lb0:
	move.l #'NAVG',12(a3)
	lea vr_y,a1
	move -4(a1),24(a3)
	move.l _delay,d1
	move d1,26(a3)
	move 6(a1),d1
	move d1,18(a3)
	clr.l 38(a3)
	clr.l 42(a3)
	clr.l 50(a3)
	cmp #1,d1
	beq.s .lb2
	move #180,d0
	tst.w 8(a1)		; loop_x
	beq.s .lb1
	add d0,d0
.lb1:
	move d0,40(a3)
	muls 10(a1),d0
	add.l #67,d0
	divs d1,d0
	move.l d0,d1
	swap d1
	tst d1
	beq.s .no_reste
	addq #1,d0
.no_reste:	
	move d0,52(a3)
.lb2:
	move (a1),d1
	move d1,20(a3)
	clr.l 46(a3)
	clr.l 54(a3)
	clr.l 42(a3)
	cmp #1,d1
	beq.s .lb3
	moveq #90,d0
	move d0,48(a3)
	move d1,d2
	sub 4(a1),d2
	subq #1,d2
	muls d2,d0
	add.l #22,d0
	divs d1,d0
	move.l d0,d1
	swap d1
	tst d1
	beq.s .no_reste2
	addq #1,d0
.no_reste2:
	move d0,56(a3)
.lb3:
	rts

	
size_into_samples:
	move.l snd_size,d0
	cmp #16,sound_bits
	bne.s .lb0
	asr.l #1,d0
.lb0:
	cmp #2,channels
	bne.s .lb1
	asr.l #1,d0
.lb1:
	rts
	
	
copy_longs:
	move.l (a3)+,(a0)+
	dbf d0,copy_longs
	rts
make_size:
	move.l (a3)+,d0
	add.l d6,d0
	move.l d0,(a0)+
	rts
copy_xy:
	clr (a0)+
	move max_imagex,(a0)+
	clr (a0)+
	move max_imagey,(a0)+
	rts	

display_add_frame:
	move.l #add_digit,a0
.plus:
	move.b (a0),d0
	addq.b #1,d0
	cmp.b #'9'+1,d0
	bmi.s .good
	move.b #'0',(a0)
	subq.l #1,a0
	bra.s .plus
.good:
	move.b d0,(a0)
	pea add_file
	GEMDOS 9,6	
	rts
	
_comp:
	move.l comp_create,a0
	jsr (a0)
	bsr compress_rle
	rts	

compress_rle:
	addq #1,key_count
	bsr.s display_add_frame
	move.l one_buffer,a1		; new frame
	move.l two_buffer,a2		; old one
	move.l a1,a3				; flags
	move.l rle16_buffer,a0
	tst.b create_avi
	bne compress_wrle
	addq.l #4,a0
	move #$0008,(a0)+			; a header present
	clr.l (a0)+
	move max_imagey,(a0)+
	clr (a0)+
	tst.b qt_palette
	beq.s .rle16
	bsr compress_rle8
	bsr improve_rle8
	bra .end
.rle16:	
	move max_imagex,d5
	muls max_imagey,d5		; total size (in pixels)
	move quality,d4			; mask
	tst.b key_frame
	beq.s .z1					; no key forced
.gloube:
	clr key_count
	bra.s .new
.z1:	
	cmp.l #1,disp_frame		; first frame?
	beq.s .gloube				; yes, like a key frame
	move key_count,d0
	cmp key_rate,d0
	bne.s .other				; not a key frame	
.new:
	move (a1)+,(a2)+			; copies every pixel
	st (a3)+						; all are new!
	subq.l #1,d5
	bne.s .new
	bra.s .next
.other:
	move (a1)+,d0
	move d0,d1
	and d4,d1					; color with its quality reduced
	move (a2),d2
	and d4,d2					; its quality too
	cmp d1,d2
	beq.s .o1
	st (a3)+
	move d0,(a2)+
	bra.s .o2
.o1:
	sf (a3)+
	addq.l #2,a2
.o2:
	subq.l #1,d5
	bne.s .other
.next:
	move max_imagey,d7		; loop accross the lines!
	subq #1,d7
	move.l one_buffer,a1
	move.l two_buffer,a2
	move max_imagex,d4
.line:
	move.l a1,a3				; flags
	move.l a2,a4				; colors
	move.l a3,d3				; for size of run
	move d4,d2
	subq #1,d2					; loop through one line
.start:
	tst.b (a3)+					; pixels to skip at the beginning
	bne.s .lb0
	addq.l #2,a4
	dbf d2,.start
	move.b #$01,(a0)+			; all to skip, empty line!
	bra.s .end_of_line
.lb0:
	subq.l #1,a3
	move.l a3,d0
	sub.l d3,d0					; number of pixels to skip
.lb1:
	cmp #255,d0
	bmi.s .lb2
	st (a0)+
	sf (a0)+
	sub #254,d0
	bra.s .lb1
.lb2:
	addq #1,d0
	move.b d0,(a0)+
.lb4:
	move.l a3,d3				; new pos
	move.l a0,a5				; saves
	sf (a0)+						; the code byte
.run:
	tst.b (a3)+
	beq.s .lb5
	addq.b #1,(a5)				; the code byte
	bmi.s .lb3
	move.b (a4)+,(a0)+
	move.b (a4)+,(a0)+			; one pixel more
	dbf d2,.run
	bra.s .end_of_line
.lb3:
	subq.l #1,a3
	move.b #$7f,(a5)
	bra.s .lb4
.lb5:
	subq.l #1,a3
	move.l a3,d3
	sf (a0)+
	bra.s .start
.end_of_line:
	st (a0)+						; code $FF
	add d4,a1
	add d4,a2
	add d4,a2
	dbf d7,.line
	bsr improve_rle16
.end:
	move.l a0,d0
	move.l rle16_buffer,a0
	sub.l a0,d0	; codec size	
	move.l size_ptr,a1
	tst.b key_frame		; a key frame wanted?
	bne.s .key
	move key_count,d1		; else, auto key frame?
	cmp key_rate,d1
	bne.s .no_key			; no!
	clr key_count			; yes, reset counter
.key:
	bset #31,d0				; mark it as a key frame
	addq #1,key_frame_num
.no_key:
	move.l d0,(a1)+		; list of sizes
	move.l a1,size_ptr
	bclr #31,d0				; eventually set...
	move.l d0,(a0)
	bset #6,(a0)
	move.l a0,-(sp)
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12				; fwrite
	rts

compress_rle8:
	move max_imagex,d5
	muls max_imagey,d5		; total size (in pixels)
	tst.b key_frame
	beq.s .z1
.gloube:
	clr key_count
	bra.s .new
.z1
	cmp.l #1,disp_frame		; first frame?
	beq.s .gloube
	move key_count,d0
	cmp key_rate,d0
	bne.s .other
.new:
	move.l (a1)+,(a2)+		; 4 at a time
	st (a3)+						; all are new!
	subq.l #4,d5
	bne.s .new
	bra.s .next
.other:
	move.l (a1)+,d0
	cmp.l (a2),d0
	sne (a3)+					; FF if 4 different pixels
	move.l d0,(a2)+
	subq.l #4,d5
	bne.s .other
.next:
	move max_imagey,d7		; loop accross the lines!
	subq #1,d7
	move.l one_buffer,a1
	move.l two_buffer,a2
	move max_imagex,d4
	lsr #2,d4					; 4 pixels at a time
.line:
	move.l a1,a3				; flags
	move.l a2,a4				; colors
	move.l a3,d3				; for size of run
	move d4,d2
	subq #1,d2					; loop through one line
.start:
	tst.b (a3)+					; pixels to skip at the beginning
	bne.s .lb0
	addq.l #4,a4
	dbf d2,.start
	move.b #$01,(a0)+			; all to skip, empty line!
	bra.s .end_of_line
.lb0:
	subq.l #1,a3
	move.l a3,d0
	sub.l d3,d0					; number of 4-pixels to skip
.lb1:
	cmp #255,d0
	bmi.s .lb2
	st (a0)+
	sf (a0)+
	sub #254,d0
	bra.s .lb1
.lb2:
	addq #1,d0
	move.b d0,(a0)+
.lb4:
	move.l a3,d3				; new pos
	move.l a0,a5				; saves
	sf (a0)+						; the code byte
.run:
	tst.b (a3)+
	beq.s .lb5
	addq.b #1,(a5)				; the code byte
	bmi.s .lb3
	move.b (a4)+,(a0)+
	move.b (a4)+,(a0)+
	move.b (a4)+,(a0)+
	move.b (a4)+,(a0)+			; 4-pixels more
	dbf d2,.run
	bra.s .end_of_line
.lb3:
	subq.l #1,a3
	move.b #$7f,(a5)
	bra.s .lb4
.lb5:
	subq.l #1,a3
	move.l a3,d3
	sf (a0)+
	bra.s .start
.end_of_line:
	st (a0)+						; code $FF
	add d4,a1
	add d4,a2
	add d4,a2
	add d4,a2
	add d4,a2
	dbf d7,.line
.end:
	rts

objc_draw: dc.l od_cont,global,rect_draw,dum,tree,dum
od_cont: dc.w 42,6,1,1,0

compress_wrle:
	move.l #'00dc',(a0)+
	clr.l (a0)+					; future size
	move screenw,d5
	muls max_imagey,d5		; total size (in pixels)
	tst.b key_frame
	beq.s _z1
	clr key_count
	bra.s _new

evnt_timer: dc.l et_cont,global,et_int,dum,dum,dum
et_cont: dc.w 24,2,1,0,0
et_int: dc.w 250,0			; 1/4 sec

_z1:
	cmp.l #1,disp_frame		; first frame?
	bne.s .lb0
	clr key_count
	beq.s _new
.lb0:
	move key_count,d0
	cmp key_rate,d0
	bne.s _other
_new:
	move.l (a1)+,(a2)+		; 8 at a time
	move.l (a1)+,(a2)+
	st (a3)+						; all are new!
	subq.l #8,d5
	bne.s _new
	bra.s _next
	
rsrc_gaddr: dc.l rg_cont,global,rg_int,dum,dum,tree
rg_cont: dc.w 112,2,1,0,1

_other:
	move.l (a1)+,d0
	cmp.l (a2),d0
	sne d7					; FF if 4 different pixels
	ror #8,d7
	move.l d0,(a2)+
	move.l (a1)+,d0
	cmp.l (a2),d0
	sne d7
	move.l d0,(a2)+
	tst d7
	sne (a3)+					; FF if 8 different pixels
	subq.l #8,d5
	bne.s _other
_next:
	move max_imagey,d7		; loop accross the lines!
	subq #1,d7
	move.l one_buffer,a1
	move.l two_buffer,a2
	move screenw,d4
	move d4,d2
	muls d7,d2
	add.l d2,a2					; last line (datas)
	lsr.l #3,d2
	add.l d2,a1					; last line (flags)
.line:
	lsr #3,d4					; 8 pixels at a time
	move.l a1,a3				; flags
	move.l a2,a4				; colors
	move.l a3,d3				; for size of run
	move d4,d2
	subq #1,d2					; loop through one line
.start:
	tst.b (a3)+					; pixels to skip at the beginning
	bne.s .lb0
	addq.l #8,a4
	dbf d2,.start
	bra.s .end_of_line
.lb0:
	subq.l #1,a3
	move.l a3,d0
	sub.l d3,d0					; number of 8-pixels to skip
	beq.s .lb4					; nothing, no skip code
	lsl #3,d0					; number of pixels
.lb1:
	sf (a0)+
	move.b #$02,(a0)+
	cmp #255,d0
	bmi.s .lb2
	move.b #254,(a0)+
	sf (a0)+
	sub #254,d0
	bra.s .lb1
.lb2:
	move.b d0,(a0)+
	sf (a0)+
.lb4:
	sf (a0)+						; the code byte
	move.l a0,a5				; saves
	sf (a0)+						; count byte
.run:
	tst.b (a3)+
	beq.s .lb5
	addq.b #8,(a5)				; the code byte
	bcs.s .lb3
	move.l (a4)+,(a0)+			; 4-pixels more
	move.l (a4)+,(a0)+			; and more
	dbf d2,.run
	bra.s .end_of_line
.lb3:
	subq.l #1,a3
	move.b #$F8,(a5)
	bra.s .lb4
.lb5:
	subq.l #1,a3
	move.l a3,d3
	bra.s .start
.end_of_line:
	sf (a0)+
	sf (a0)+
	sub d4,a1				; back one line (flags)
	lsl #3,d4
	sub.w d4,a2				; back one line (datas)
	dbf d7,.line
.end:
	move.b #1,-1(a0)		; $00,$01 for end of frame
	bsr improve_wrle
	move.l a0,d0
	move.l rle16_buffer,a0
	sub.l a0,d0				; codec size	
	subq.l #8,d0			; codec offset
	INTEL d0
	move.l d0,4(a0)		; size into frame
	move.l size_ptr,a1
	move.l #'00dc',(a1)+
	move.l #$02000000,(a1)+		; default flags
	tst.b key_frame		; a key frame wanted?
	bne.s .key
	move key_count,d1		; else, auto key frame?
	cmp key_rate,d1
	bne.s .no_key			; no!
	clr key_count			; yes, reset counter
.key:
	bset #4,-4(a1)			; mark it as a key frame
	addq #1,key_frame_num
.no_key:
	clr.l (a1)+				; offsets will be computed at the end
	move.l d0,(a1)+		; size
	move.l a1,size_ptr
	move.l a0,-(sp)
	INTEL d0
	addq.l #8,d0
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12				; fwrite
	rts

shel_find: dc.l sf_cont,global,dum,dum,rsc_name,dum
sf_cont: dc.w 124,0,1,1,0

improve_rle16:
	move.l rle16_buffer,a4
	clr flx_start
	clr flx_end
	add.w #10,a4	
	move (a4)+,d2		; number of lines
	move d2,flx_number
	st flx_flag
	addq.l #2,a4
	move.l a4,a3
	move.l a3,flx_ptr
.while:
	subq #1,d2
	bmi .lb1
	move.b (a4)+,(a3)+	; first byte
	moveq #0,d0
.cnt:
	move.b (a4)+,d0	; code
	bne.s .case80
	move.b d0,(a3)+
	move.b (a4)+,(a3)+	; skip code
	bra.s .cnt
.case80:
	bmi.s .end_of_line
	sf flx_flag
	move d0,d7				; number of words
	move.l a4,a6			; uncompressed datas	
	move.l buffer,a1		; new compressed datas (if possible)
	move.l one_buffer,d6	; temporary
	bsr compress_run
	move.l a1,d0
	move.l buffer,a1
	sub.l a1,d0				; new size
	move d7,d1
	add d1,d1
	add d1,a4				; skips this bloc
	addq #1,d1				; old size
	cmp d1,d0
	bmi.s .better
	move.b d7,(a3)+		; no improvement
	subq #1,d7
.no_imp:
	move.b (a6)+,(a3)+
	move.b (a6)+,(a3)+
	dbf d7,.no_imp
	moveq #0,d0
	bra.s .cnt
.better:
	subq #1,d0
.copy_new:
	move.b (a1)+,(a3)+
	dbf d0,.copy_new	
	moveq #0,d0
	bra.s .cnt
.end_of_line:
	move.b d0,(a3)+		; end of line
	tst.b flx_flag
	bpl.s .non_empty
	addq #1,flx_start
	subq #1,flx_number
	move.l flx_ptr,a3		; back one line, it was empty!
	bra.s .while
.non_empty:
	bne .while	
	move.l a3,flx_ptr
	move d2,flx_end
	move.b #1,flx_flag
	bra .while
.lb1:
	move.l rle16_buffer,a0
	move flx_number,d2
	sub flx_end,d2
	bls.s .nop_frame
	move flx_start,6(a0)
	move d2,10(a0)
	bra.s .common
.nop_frame:
	clr 4(a0)
.common:
	move.l flx_ptr,a0		; new end of frame
	rts

; a0
; a1=buffer sortie
; a2=buffer temporaire
; a6=les donn‚es non compress‚es

; d0,d1,d3,d4,d5

compress_run:
	move.l d6,a2
	moveq #0,d1					; t=0
	moveq #0,d3					; bdex
.do_again:
	moveq #0,d0					; i=0
	lea 0(a6,d1.w),a0
	add d1,a0					; p+t
	move d7,d4
	subq #1,d4
	sub d1,d4					; bytes-1-t
	bra.s .valid
.while:
	lea 0(a0,d0.w),a5
	add d0,a5				; words
	move.b (a5)+,d5
	cmp.b 1(a5),d5
	beq.s .yeepee
	ror #8,d5
	move.b (a5)+,d5
	bra.s .end_of_while
.yeepee:
	ror #8,d5
	move.b (a5)+,d5
	cmp.b 1(a5),d5
	bne.s .end_of_while
	addq #1,d0
.valid:
	cmp d7,d0
	bpl.s .end_of_while
	cmp d4,d0
	bpl.s .end_of_while
	bra.s .while
.end_of_while:
	tst d0
	bne.s .good_if
	cmp d7,d3
	bmi.s .not_if
.good_if:
	tst d3
	beq.s .other_if
	move.b d3,(a1)+
	move.l d6,a2	; start of buffer
	bra.s .d
.copy_string:
	move.b (a2)+,(a1)+
	move.b (a2)+,(a1)+
.d:
	dbf d3,.copy_string
	moveq #0,d3
	move.l d6,a2
.other_if:
	tst d0
	beq.s .end_of_do
	addq #1,d0				; i=i+1
	add d0,d1				; t=t+(i+1)
	sub #256,d0
	neg d0	
	move.b d0,(a1)+
	ror #8,d5
	move.b d5,(a1)+
	ror #8,d5
	move.b d5,(a1)+
	bra.s .end_of_do
.not_if:
	move.b (a0),(a2)+
	move.b 1(a0),(a2)+
	addq #1,d3
	addq #1,d1
.end_of_do:
	cmp d7,d1
	bmi.s .do_again			
	tst d3
	beq.s .no_remain
	move.b d3,(a1)+
	move.l d6,a2
	bra.s .d2
.copy_last:
	move.b (a2)+,(a1)+
	move.b (a2)+,(a1)+
.d2:
	dbf d3,.copy_last
.no_remain:
	rts

improve_rle8:
	move.l rle16_buffer,a4
	clr flx_start
	clr flx_end
	add.w #10,a4	
	move (a4)+,d2		; number of lines
	move d2,flx_number
	st flx_flag			; lines are empty till here!
	addq.l #2,a4
	move.l a4,a3
	move.l a3,flx_ptr	; start here
.while:
	subq #1,d2
	bmi .lb1
	move.b (a4)+,(a3)+	; first byte
	moveq #0,d0
.cnt:
	move.b (a4)+,d0	; code
	bne.s .case80
	move.b d0,(a3)+
	move.b (a4)+,(a3)+	; skip code
	bra.s .cnt
.case80:
	bmi.s .end_of_line
	sf flx_flag				; we meet an non empty line!
	move d0,d7				; number of long words
	move.l a4,a6			; uncompressed datas	
	move.l buffer,a1		; new compressed datas (if possible)
	move.l one_buffer,d6	; temporary
	bsr compress_run8
	move.l a1,d0
	move.l buffer,a1
	sub.l a1,d0				; new size
	move d7,d1
	add d1,d1
	add d1,d1				; long words!
	add d1,a4				; skips this bloc
	addq #1,d1				; old size
	cmp d1,d0
	bmi.s .better
	move.b d7,(a3)+		; no improvement
	subq #1,d7
.no_imp:
	move.b (a6)+,(a3)+
	move.b (a6)+,(a3)+
	move.b (a6)+,(a3)+
	move.b (a6)+,(a3)+
	dbf d7,.no_imp
	moveq #0,d0
	bra.s .cnt
.better:
	subq #1,d0
.copy_new:
	move.b (a1)+,(a3)+
	dbf d0,.copy_new	
	moveq #0,d0
	bra.s .cnt
.end_of_line:
	move.b d0,(a3)+		; end of line
	tst.b flx_flag
	bpl.s .non_empty
	addq #1,flx_start
	subq #1,flx_number
	move.l flx_ptr,a3		; back one line, it was empty!
	bra .while
.non_empty:
	bne .while	
	move.l a3,flx_ptr
	move d2,flx_end
	move.b #1,flx_flag
	bra .while
.lb1:
	move.l rle16_buffer,a0
	move flx_number,d2
	sub flx_end,d2
	bls.s .nop_frame
	move flx_start,6(a0)
	move d2,10(a0)
	bra.s .common
.nop_frame:
	clr 4(a0)
.common:
	move.l flx_ptr,a0		; new end of frame
	rts


compress_run8:
	move.l d6,a2
	moveq #0,d1					; t=0
	moveq #0,d3					; bdex
.do_again:
	moveq #0,d0					; i=0
	lea 0(a6,d1.w),a0
	add d1,a0
	add d1,a0
	add d1,a0
	move d7,d4
	subq #1,d4
	sub d1,d4					; bytes-1-t
	bra.s .valid
.while:
	asl #2,d0
	lea 0(a0,d0.w),a5
	asr #2,d0
	move.b (a5)+,d5
	cmp.b 3(a5),d5
	bne.s .ne1
	ror #8,d5
	move.b (a5)+,d5
	cmp.b 3(a5),d5
	bne.s .ne2
	swap d5
	move.b (a5)+,d5
	cmp.b 3(a5),d5
	bne.s .ne3
	ror #8,d5
	move.b (a5)+,d5
	cmp.b 3(a5),d5
	bne.s .end_of_while
	addq #1,d0
	bra.s .valid
.ne1:
	ror #8,d5
	move.b (a5)+,d5
.ne2:
	swap d5
	move.b (a5)+,d5
.ne3:
	ror #8,d5
	move.b (a5)+,d5
	bra.s .end_of_while
.valid:
	cmp d7,d0
	bpl.s .end_of_while
	cmp d4,d0
	bpl.s .end_of_while
	bra.s .while
.end_of_while:
	tst d0
	bne.s .good_if
	cmp d7,d3
	bmi.s .not_if
.good_if:
	tst d3
	beq.s .other_if
	move.b d3,(a1)+
	move.l d6,a2	; start of buffer
	bra.s .d
.copy_string:
	move.b (a2)+,(a1)+
	move.b (a2)+,(a1)+
	move.b (a2)+,(a1)+
	move.b (a2)+,(a1)+
.d:
	dbf d3,.copy_string
	moveq #0,d3
	move.l d6,a2
.other_if:
	tst d0
	beq.s .end_of_do
	addq #1,d0				; i=i+1
	add d0,d1				; t=t+(i+1)
	sub #256,d0
	neg d0	
	move.b d0,(a1)+
	rept 4
		rol.l #8,d5
		move.b d5,(a1)+
	endr
	bra.s .end_of_do
.not_if:
	move.b (a0)+,(a2)+
	move.b (a0)+,(a2)+
	move.b (a0)+,(a2)+
	move.b (a0)+,(a2)+
	subq.l #4,a0
	addq #1,d3
	addq #1,d1
.end_of_do:
	cmp d7,d1
	bmi .do_again			
	tst d3
	beq.s .no_remain
	move.b d3,(a1)+
	move.l d6,a2
	bra.s .d2
.copy_last:
	move.b (a2)+,(a1)+
	move.b (a2)+,(a1)+
	move.b (a2)+,(a1)+
	move.b (a2)+,(a1)+
.d2:
	dbf d3,.copy_last
.no_remain:
	rts

improve_wrle:
	move max_imagey,d2
	subq #1,d2
	move.l rle16_buffer,a4
	addq.l #8,a4				; skips 00dc + size
	move.l a4,a3
	sf flx_flag
.while:
	tst d2
	bpl.s .lb0
.end:
	move.l a3,a0					; new end of frame
	rts
.lb0:
	moveq #0,d6
	move.b (a4)+,d6				; mod=0 always!
	move.b (a4)+,d6				; opcode
	bne.s .lb3
	tst.b flx_flag
	beq.s .first
	addq #1,flx_number
	bra.s .common
.first:
	move.l a3,flx_ptr
	move #1,flx_number
	st flx_flag
.common:
	clr.w (a3)+
	subq #1,d2
	bra.s .while
.lb3:
	cmp.b #1,d6						; if opcode=1
	bne.s .lb4
	tst.b flx_flag
	beq.s .no_empty
	move.l flx_ptr,a3
.no_empty:
	clr.b (a3)+
	move.b d6,(a3)+				; end of frame
	moveq #-1,d2
	bra.s .while
.lb4:
	tst.b flx_flag
	beq.s .no_empty2
	sf flx_flag
	move flx_number,d0
	cmp #3,d0
	bmi.s .no_empty2				; 1 or 2 lines, no need to improve
	move.l flx_ptr,a3
.opti_loop:
	move #2,(a3)+					; byte0 + byte2
	cmp #255,d0	
	bmi.s .end_loop
	move #254,(a3)+				; byte 0 + byte $FE
	sub #254,d0
	bra.s .opti_loop
.end_loop:
	move d0,(a3)+					; last value
.no_empty2:
	cmp.b #2,d6						; if opcode=2
	bne.s .lb5
	clr.b (a3)+
	move.b d6,(a3)+
	move.b (a4)+,(a3)+
	move.b (a4)+,d6
	sub d6,d2
	move.b d6,(a3)+
	bra .while
.lb5:									; else (for opcode)
	move d6,d7				; number of bytes
	move.l a4,a6			; uncompressed datas	
	move.l buffer,a1		; new compressed datas (if possible)
	move.l one_buffer,d6	; temporary
	bsr.s compress_wrun
	move.l a1,d0
	move.l buffer,a1
	sub.l a1,d0				; new size
	move d7,d1
	add d1,a4				; skips this bloc
	addq #2,d1				; old size
	cmp d1,d0
	bmi.s .better
	clr.b (a3)+
	move.b d7,(a3)+		; no improvement
	subq #1,d7
.no_imp:
	move.b (a6)+,(a3)+
	dbf d7,.no_imp
	bra .while
.better:
	subq #1,d0
.copy_new:
	move.b (a1)+,(a3)+
	dbf d0,.copy_new	
	bra .while	

compress_wrun:
	move.l d6,a2
	moveq #0,d1					; t=0
	moveq #0,d3					; bdex
.do_again:
	moveq #0,d0					; i=0
	lea 0(a6,d1.w),a0		; p+t
	move d7,d4
	subq #1,d4
	sub d1,d4					; bytes-1-t
	bra.s .valid
.while:
	move.b 0(a0,d0.w),d5
	cmp.b 1(a0,d0.w),d5
	bne.s .end_of_while
	addq #1,d0
.valid:
	cmp d7,d0
	bpl.s .end_of_while
	cmp d4,d0
	bpl.s .end_of_while
	bra.s .while
.end_of_while:
	tst d0
	bne.s .good_if
	cmp d7,d3
	bmi.s .not_if
.good_if:
	tst d3
	beq.s .other_if
	bsr.s .wcopy_string
	moveq #0,d3
	move.l d6,a2
.other_if:
	tst d0
	beq.s .end_of_do
	addq #1,d0				; i=i+1
	add d0,d1				; t=t+(i+1)
	move.b d0,(a1)+
	move.b d5,(a1)+
	bra.s .end_of_do
.not_if:
	move.b (a0),(a2)+
	addq #1,d3
	addq #1,d1
.end_of_do:
	cmp d7,d1
	bmi.s .do_again			
	tst d3
	beq.s .no_remain
	bsr.s .wcopy_string
.no_remain:
	rts
.wcopy_string:
	move.l d6,a2
	cmp.b #1,d3
	bne.s .not1
	move.b d3,(a1)+
	move.b (a2),(a1)+
	rts
.not1:
	cmp.b #2,d3
	bne.s .not2
	moveq #1,d3
	move.b d3,(a1)+
	move.b (a2)+,(a1)+
	move.b d3,(a1)+
	move.b (a2),(a1)+
	rts
.not2:
	clr.b (a1)+
	move.b d3,(a1)+
	bra.s .loop
.copy:
	move.b (a2)+,(a1)+
.loop:
	dbf d3,.copy
	move a1,d3
	btst #0,d3
	beq.s .pair
	clr.b (a1)+
.pair:
	rts

end_of_avi:
	move mov_h2,d5
	move.l header_buffer,a0
	lea 1024(a0),a0				; idx1 section
	move.l size_ptr,a1			; end of section
	move.l a1,d0
	sub.l a0,d0						; size of section
	subq.l #8,d0
	addq.l #4,a0
	INTEL d0
	move.l d0,(a0)+
	moveq #0,d0						; max frame size
	moveq #4,d1						; first offset
.offsets:
	cmp.l a1,a0
	bpl.s .save_idx1
	move.l (a0)+,d3				; 00dc or 01wb
	addq.l #4,a0					; skips flags
	INTEL d1
	move.l d1,(a0)+				; offset
	INTEL d1
	move.l (a0)+,d2				; size
	INTEL d2
	addq.l #8,d2
	cmp.l #'00dc',d3
	bne.s .no						; not an image, don't use with max size
	cmp.l d2,d0
	bpl.s .no
	move.l d2,d0					; new max_fsize
.no:
	add.l d2,d1						; new offset
	bra.s .offsets
.save_idx1:
	lea avi_header,a0
	INTEL D0
	move.l d0,144(a0)
	move.l d0,60(a0)				; max frame size
	move.l header_buffer,a0
	lea 1024(a0),a0
	move.l size_ptr,a1
	sub.l a0,a1
	move.l a0,-(sp)
	move.l a1,-(sp)
	move d5,-(sp)				; prepares write
	move #1,-(sp)
	move d5,-(sp)
	clr.l -(sp)
	GEMDOS 66,10					; current position = end of movi section
	move.l d0,d7
	GEMDOS 64,12					; writes the idx1 section
	move #1,-(sp)
	move d5,-(sp)
	clr.l -(sp)
	GEMDOS 66,10					; current position = len of file
	subq.l #8,d0
	INTEL d0
	lea avi_header,a3
	move.l d0,4(a3)				; RIFF len
	move.b #$1,56(a3)				; one stream (images)
	move.l #$4c0,d6				; header size
	tst.b bad_sound
	bne.s .nos1
	add.l #100,d6					; size of sound header
	addq.b #1,56(a3)				; two streams (images + sound)
.nos1:
	sub.l d6,d7
	sub.l #28,d7					; size of movi section
	INTEL d6
	move.l d6,16(a3)
	clr -(sp)
	move d5,-(sp)
	clr.l -(sp)
	GEMDOS 66,10					; start of file		
	pea (a3)
	move.l #212,-(sp)			; first part of header
	move d5,-(sp)
	GEMDOS 64,12					; writes it
	move.l header_buffer,-(sp)
	move.l #1024,-(sp)
	move d5,-(sp)
	GEMDOS 64,12					; writes the palette
	tst.b bad_sound
	bne.s _nos2
	move.l #avi_sound_header,-(sp)
	moveq #100,d0
	move.l d0,-(sp)
	move d5,-(sp)
	GEMDOS 64,12					; writes sound header
	bra.s _nos2

form_center: dc.l fc_cont,global,dum,rect,tree,dum
fc_cont: dc.w 54,0,5,1,0

_nos2:
	lea avi_end_header,a0
	INTEL d7
	move.l d7,4(a0)
	pea (a0)
	move.l #12,-(sp)
	move d5,-(sp)
	GEMDOS 64,12					; writes LIST size movi
	rts
	
end_of_gif:
	pea .code_end
	moveq #1,d0
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12
	rts
.code_end: dc.b $3B
	even

save_header:
	tst.b slide_gif
	bne end_of_gif
	pea add_header
	GEMDOS 9,6
	tst.b create_avi
	bne end_of_avi
	tst.b slide_degas
	beq.s .other
	rts				; flm files completed at end_of_display
.other:
	move #1,-(sp)
	move mov_h2,-(sp)
	clr.l -(sp)
	GEMDOS $42,10		; current file position
	move.l d0,dum		; for updating 'mdat' size
	tst key_frame_num
	beq.s .no_key
	bsr header_with_key	; upon return, header_size is updated
	move.l a5,-(sp)		; new start of bloc
	bra.s .truc
.no_key:
	move.l header_buffer,-(sp)
.truc:
	move.l header_size,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12		; writes the buffer!
.next:
	clr -(sp)
	move mov_h2,-(sp)
	clr.l -(sp)
	GEMDOS $42,10		; start of file
	move.l #'mdat',dum+4
	pea dum
	move.l #8,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12
	rts	
	
header_with_key:
	move.l header_buffer,a0
	moveq #0,d7
	move key_frame_num,d7
	addq #4,d7
	asl.l #2,d7				; 4*(num + 4) = size added with key section!
	move.l #'moov',d0
	bsr adjust_size
	move.l #'trak',d0
	bsr adjust_size
	move.l #'mdia',d0
	bsr adjust_size
	move.l #'minf',d0
	bsr adjust_size
	move.l #'stbl',d0
	bsr adjust_size
.search_stsc:
	cmp.l #'stsc',4(a0)
	beq.s .found
	add.l (a0),a0
	bra.s .search_stsc
.found:
	move.l a0,a5	; saves it
	move.l a0,d0
	sub.l header_buffer,d0	; size that can be saved now
	sub.l d0,header_size		; updates
	move.l header_buffer,-(sp)
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12				; saves the first part
	move.l d7,d6
	bsr save_long
	move.l #'stss',d6
	bsr save_long
	moveq #0,d6
	bsr save_long
	move key_frame_num,d6
	bsr save_long
	move.l a5,a0
.search_stsz:
	cmp.l #'stsz',4(a0)
	beq.s .found2
	add.l (a0),a0
	bra.s .search_stsz
.found2:
	lea 16(a0),a4
	move.l (a4)+,d5	; number of frames
	moveq #0,d6			; frame number (counter)	
	bra.s .num_loop
.loop:
	addq.l #1,d6
	bclr #7,(a4)
	beq.s .no			; there was no bit, so not a key frame
	bsr save_long
.no:
	addq.l #4,a4		; next size
.num_loop:
	subq.l #1,d5
	bpl.s .loop
	rts
	
adjust_size:
	cmp.l 4(a0),d0
	beq.s .found
	add.l (a0),a0
	bra.s adjust_size
.found:
	add.l d7,(a0)+			; adjusts the size
	addq.l #4,a0			; skips the ID
	rts
	
save_long:
	move.l d6,.temp
	pea .temp
	moveq #4,d0
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12
	rts
.temp: dc.l 0

parse_command_line:
	cmp.b #32,(a5)+
	beq.s parse_command_line
	move.b -(a5),d0
	bne.s .lbk
	rts
.lbk:
	moveq #-1,d1
	cmp.b #'+',d0
	beq.s .option
	moveq #0,d1
	cmp.b #'-',d0
	bne .file_name
.option:
	addq.l #1,a5
	move.b (a5)+,d0	; name of the option
	or.b #$20,d0		; to lower case
	cmp.b #'d',d0
	bne.s .o1
	move.b d1,cmd_dial
	bra.s parse_command_line
.o1:
	cmp.b #'p',d0
	bne.s .o2
	move.b d1,cmd_play
	bra.s parse_command_line
.o2:
	cmp.b #'s',d0
	bne.s .o3
	move.b d1,cmd_sync
	bra.s parse_command_line
.o3:
	cmp.b #'a',d0
	bne.s .o4
	move.b d1,cmd_alt
	bra.s parse_command_line
.o4:
	cmp.b #'e',d0
	bne.s .o5
	move.b d1,cmd_erro
	bra.s parse_command_line
.o5:
	cmp.b #'i',d0
	bne.s .o6
	move.b d1,cmd_inter
	bra.s parse_command_line
.o6:
	cmp.b #'x',d0
	bne.s .o7
	bsr cmd_get_int
;	tst.b is_tt
;	beq.s .o6a
	and.b #$F0,d0				; 16 aligned if a TT alone
.o6a:
	move d0,cmd_x
	or.b #$F0,cmd_coord
	bra parse_command_line
.o7:
	cmp.b #'y',d0
	bne.s .o8
	bsr cmd_get_int
	move d0,cmd_y
	or.b #$0F,cmd_coord
	bra parse_command_line
.o8:
	bra parse_command_line	; unknow option...
.file_name:
	lea full,a0							; the name of the file (or mask)
	lea full2,a1						
	move.l a1,a2						; the last '\'
	subq #1,d0
.lb0:
	move.b (a5)+,d1
	move.b d1,(a0)+
	move.b d1,(a1)+					; copies the name
	beq.s .lb2
	cmp.b #'\',d1
	bne.s .lb0
	move.l a1,a2
	bra.s .lb0
.lb2:
	move.l a2,fname_pos
	st command							; there's a COMMAND LINE
	rts
	
cmd_get_int:
	moveq #0,d0
	moveq #0,d1
.lb0:
	move.b (a5)+,d1		; one char
	sub.b #'0',d1			
	bmi.s .end				; not a digit
	cmp.b #10,d1
	bpl.s .end				; not a digit
	muls #10,d0
	add.w d1,d0				; adds this digit
	bra.s .lb0
.end:
	subq.l #1,a5			; back one char
	rts
	
install_vectors:
	XBIOS 34,2							; kbdvbase
	move.l d0,a0
	lea old_midi,a1
	move.l (a0),(a1)+
	move.l 12(a0),(a1)+
	move.l 20(a0),(a1)+
	move.l 32(a0),(a1)
	move.l #my_midi,(a0)
	move.l #my_stat,12(a0)
	move.l #my_cloc,20(a0)
	move.l #my_ikbd,32(a0)
	rts

restore_vectors:
	XBIOS 34,2							; kbdvbase
	move.l d0,a0
	lea old_midi,a1
	move.l (a1)+,(a0)
	move.l (a1)+,12(a0)
	move.l (a1)+,20(a0)
	move.l (a1)+,32(a0)
	rts

my_ikbd:
	st inter_flag
	move.l #return,-(sp)
	move.l old_ikbd,-(sp)
	rts
return:
	move sr,-(sp)
	tst.b inter_flag
	beq.s .lb0
	move.l a0,-(sp)
	move.l kbshift,a0
	bset #2,(a0)
	move.l (sp)+,a0
.lb0:
	move (sp)+,sr
	rts
	
my_midi:
	st inter_flag
	move.l a0,-(sp)
	move.l kbshift,a0
	bset #2,(a0)
	move.l (sp)+,a0
	move.l old_midi,-(sp)
	rts
	
my_stat:
	sf inter_flag
	move.l old_stat,-(sp)
	rts
	
my_cloc:
	sf inter_flag
	move.l old_cloc,-(sp)
	rts

mac_date:
	GEMDOS 42,2			; tgetdate
	move d0,d1
	and #$1F,d1			; day
	lsr #5,d0
	move d0,d2
	and #$F,d2			; month
	lsr #4,d0			; year since 1980
	add.w #1980,d0		; absolute year
	moveq #-1,d3
	add d0,d3			; year -1
	moveq #0,d4
	cmp #3,d2
	bmi.s .lb0
	move d0,d3			; year
	move d2,d4
	asl #2,d4			; m * 4
	add.w #23,d4		; m * 4 + 23
	ext.l d4
	divs #10,d4			; int(0,4 * m + 2,3)
	ext.l d4
.lb0:
	muls #365,d0
	subq #1,d2
	muls #31,d2
	add.l d2,d0
	ext.l d1
	add.l d1,d0
	sub.l d4,d0
	asr #2,d3			; int (y(-1) / 4)
	ext.l d3
	add.l d3,d0			; 365Y + 31(M-1) + D + INT(Z/4) - X
	sub.l #695436,d0	; days since 1/1/1904 (you Mac!)
	move.l d7,d0
	add.l d0,d0
	add.l d0,d7			; *3
	asl.l #3,d7			; *8 hours since 1/1/1904
	GEMDOS 44,2			; tgettime
	move d0,d1
	and #$1f,d1
	add d1,d1			; seconds
	lsr #5,d0
	move d0,d2
	and #$3f,d2			; minutes
	lsr #6,d0			; hours
	ext.l d0
	add.l d0,d7			; add the hours
	lsl.l #2,d7			; *4
	move.l d7,d0
	add.l d0,d0
	add.l d0,d7			; + *8
	add.l d0,d0
	add.l d0,d7			; + *16
	add.l d0,d0
	add.l d0,d7			; + * 32 = *60, into minutes
	ext.l d2
	add.l d2,d7			; add the minutes
	lsl.l #2,d7			; *4
	move.l d7,d0
	add.l d0,d0
	add.l d0,d7			; + *8
	add.l d0,d0
	add.l d0,d7			; + *16
	add.l d0,d0
	add.l d0,d7			; + * 32 = *60, into seconds
	ext.l d1
	add.l d1,d7			; add the seconds
	lea date_table,a0
.lb1:
	move.l (a0)+,d0
	beq.s .exit
	move.l d0,a1
	move.l d7,(a1)+
	move.l d7,(a1)
	bra.s .lb1
.exit
	rts
date_table:
	dc.l date1,date2,date3,date4,date5,0


start_routines:
	rts				; 0
	dc.w 0,1,2
	bset d4,d0		; 1
	rts
	dc.w 3,4
	bset d4,d1		; 2
	rts
	dc.w 5,6
	bset d4,d0		; 3
	bset d4,d1
	rts
	dc.w 7
	bset d4,d2		; 4
	rts
	dc.w 8,9
	bset d4,d0		; 5
	bset d4,d2
	rts
	dc.w 10
	bset d4,d1		; 6
	bset d4,d2
	rts
	dc.w 11
	bset d4,d0		; 7
	bset d4,d1
	bset d4,d2
	rts
	bset d4,d3
	rts				; 8
	dc.w 0,1
	bset d4,d3
	bset d4,d0		; 9
	rts
	dc.w 3
	bset d4,d3
	bset d4,d1		; 10
	rts
	dc.w 5
	bset d4,d3
	bset d4,d0		; 11
	bset d4,d1
	rts
	bset d4,d3
	bset d4,d2		; 12
	rts
	dc.w 8
	bset d4,d3
	bset d4,d0		; 13
	bset d4,d2
	rts
	bset d4,d3
	bset d4,d1		; 14
	bset d4,d2
	rts
	bset d4,d3
	bset d4,d0		; 15
	bset d4,d1
	bset d4,d2
	rts
	
	
mpg_read_header:
	SEEK #0,0		; start of file
	bsr read_long
	cmp.l #$000001b3,d0
	beq.s .ok
	cmp.l #$000001ba,d0
	beq.s .ok
	moveq #1,d0
.ok:
	rts
	
mpg_parse_bin:
	move.l #'mpeg',comp_txt
	st samp_sizes
	SEEK #0,0
	lea cvid_fix0,a3	; parse pointer
	move.l a3,a4		; end of bloc simulated
.next:
	bsr mpg_code	; end of file?
	bne.s .lb0
	rts
.lb0:
	cmp.b #$b3,d0
	bne.s .lb1
	bsr mpg_get_byte
	move d0,d4
	bsr mpg_get_byte
	lsl #8,d4
	move.b d0,d4
	move d4,d0
	lsr #4,d0
	move d0,max_imagex
	bsr mpg_get_byte
	lsl #8,d4
	move.b d0,d4
	and.w #$fff,d4
	move d4,max_imagey
	bra.s .next
.lb1:
	cmp.b #$00,d0
	bne.s .next
	bsr mpg_get_byte
	bsr mpg_get_byte
	and #$38,d0
	lsr #3,d0					; frame type (1, 2, 3) 
	addq.l #1,sample_num	
	bra.s .next

mpg_code:
	bsr mpg_get_byte
	bne.s .lb0
	rts				; if eq, then end of file
.lb0:
	tst.b d0
	bne.s mpg_code
	bsr mpg_get_byte
	bne.s .lb1
	rts
.lb1:
	tst.b d0
	bne.s mpg_code
.lb3:
	bsr mpg_get_byte
	bne.s .lb2
	rts
.lb2:
	tst.b d0
	beq.s .lb3
	cmp.b #1,d0
	bne.s mpg_code
	bsr mpg_get_byte
	bne.s .lb4
	rts
.lb4:
	moveq #1,d1
	rts
		
mpg_get_byte:
	cmp.l a3,a4
	beq.s .end_of_bloc
	move.b (a3)+,d0
	moveq #1,d1
	rts
.end_of_bloc:
	lea cvid_fix0,a3
	move.l a3,-(sp)
	move.l #16384,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	moveq #1,d1
	cmp.l d1,d0
	bmi.s .end_of_file
	lea (a3,d0.l),a4
	bra.s mpg_get_byte
.end_of_file:
	moveq #0,d1
	rts
	
seq_read_header:
	SEEK #0,0
	lea cvid_fix0,a3
	pea (a3)
	move.l #128,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	tst.l d0
	bmi .bug
	cmp #$FEDB,(a3)+
	bne .bug
	move #320,max_imagex
	move #200,max_imagey
	addq.l #2,a3
	move.l (a3)+,d1
	move.l d1,sample_num			; number of frames
	move.l d1,d4
	moveq #0,d0
	move (a3)+,d0					; number of VBLs (1/50)
	divs #30,d0					; nuber of 1/200 per frame
	ext.l d0
	move.l d0,_delay
	lsl.l #2,d1						; bytes to load the offset table
	move.l d1,d3					; saves it
	addq.l #4,d1					; plus a dummy value
	bsr malloc
	move.l d0,samp_sizes			; the bloc
	move.l d0,a3
	move.l d0,-(sp)
	move.l d3,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12					; read the table
	tst.l d0
	bmi.s .bug
	move.l total,0(a3,d3.l)		; the last value is the total length
	moveq #0,d0						; max fsize
	move.l (a3)+,d1				; first position
.lb0:
	move.l (a3)+,d2				; next position
	move.l d2,d3
	sub.l d1,d3						; current size
	cmp.l d3,d0
	bpl.s .lb1
	move.l d3,d0					; new max fsize
.lb1:
	move.l d2,d1					; new position
	subq.l #1,d4
	bne.s .lb0						; other size
	addq.l #1,d0
	bclr #0,d0						; word aligned
	move.l d0,max_fsize	
	move.l #'seq4',comp_txt
	moveq #0,d0
	rts	
.bug:
	moveq #1,d0
	rts

seq_read_data:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
.disp_again:
	clr.l disp_frame
	move.l s_buffer_2,a0
	move #3999,d0
.clear:
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	dbf d0,.clear
	st cvid_fix0			; new palette forced
	st cvid_fix0+32		; new palette forced
	move.l $4ba.w,start_time
	move.l $4ba.w,current_time
	move.l samp_sizes,a5		; sizes pointer
.again:	
	move.l (a5)+,d0
	cmp.l total,d0					; end of table?
	beq .exit
	move.l (a5),d4
	sub.l d0,d4
	SEEK d0,0						; good position
	move.l d4,bufused				; size to load
	move.l buffer,-(sp)
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	bsr seq_decomp_frame			; and updates the second buffer
	move SR,d1
	move.l current_time,d0
.delay:
	cmp.l $4ba.w,d0
	bpl.s .delay
	add.l _delay,d0
	move.l d0,current_time
	move d1,ccr
	bne.s .nop_frame
	bsr seq_read_palette
	bsr seq_disp_image
.nop_frame:
	addq.l #1,disp_frame
	move.l kbshift,a0
	btst #2,(a0)
	bne.s .stop
	bra .again
.exit:
	tst.b is_rep
	bne .disp_again
	bra.s .normal_out
.stop:
	st stopped
.normal_out:
	move.l $4ba.w,end_time
	move.l stack_adr,-(sp)
	GEMDOS 32,6
	rts	
	
seq_decomp_frame:
	cmp.l #129,bufused
	bmi .exit						; only a header!
	move.l buffer,a0				; the frame
	move.l 64(a0),d0				; size of the datas
	beq .exit						; no datas
	lea 128(a0),a1					; the datas
	tst.b 63(a0)
	beq .no_comp
	lea 0(a1,d0.l),a2				; end of datas
	move.l s_buffer,a3
.again:
	cmp.l a2,a1
	bpl.s .end_decomp
	move (a1)+,d0					; code
	bmi.s .run
	subq #1,d0						; for dbf
	move (a1)+,d1					; word to be repeated
.rep:
	move d1,(a3)+
	dbf d0,.rep
	bra.s .again
.exit:
	moveq #1,d0
	rts
.run:
	bclr #15,d0
	subq #1,d0
.run_2:
	move (a1)+,(a3)+				; copy
	dbf d0,.run_2
	bra.s .again
.end_decomp:
	move.l s_buffer,a1			; the datas
.no_comp:							; here a1 points to the uncompressed datas
	move 58(a0),d0			; W
	move d0,d1				; saves it
	add #15,d0
	lsr #4,d0				; number of columns of 16 pixels
	move d0,d3				; for TT 16 colors
	tst.b 63(a0)
	beq .really_no_comp
	move 60(a0),d2			; H
	muls d2,d0				; number of words in one plane
	add.l d0,d0				; number of bytes in one plane
	lea (a1,d0.l),a2
	lea (a2,d0.l),a3
	lea (a3,d0.l),a4		; the other planes
	move.l s_buffer_2,a6
	subq #1,d2				; for the loop
	move.l a1,d7
	lea mfdb_src,a1
	move.l a6,(a1)+
	move 58(a0),(a1)+
	move d3,d0
	lsl #4,d0
	move d0,(a1)+
	move d3,(a1)
	clr.l mfdb_dest	; screen
	subq #1,d3			; for the loop
	move d3,d0			; number of columns-1
	lsl #3,d0			; inc into buffer
	move.l d7,a1
.next:
	move.l a6,a0	
	move d2,d1
.one_column:
	move (a1)+,(a0)+
	move (a2)+,(a0)+
	move (a3)+,(a0)+
	move (a4)+,(a0)+
	add d0,a0
	dbf d1,.one_column
	addq.l #8,a6
	dbf d3,.next
	moveq #0,d0
	rts				
.really_no_comp:
	move.l a1,d7
	lea mfdb_src,a1
	move.l d7,(a1)+
	move 58(a0),(a1)+
	move d3,d0
	lsl #4,d0
	move d0,(a1)+
	move d3,(a1)
	clr.l mfdb_dest	; screen
	moveq #0,d0
	rts
	
vro_cpyfm: dc.l vcp_cont,vcp_int,vcp_ptsin,dum,dum
vcp_cont: dc.w 109,4,0,1,0,0,0
				dc.l mfdb_src,mfdb_dest
mfdb_src: dc.w 0,0,0,0,0,0,4,0,0,0
	
seq_read_palette:
	move.l buffer,a0
	addq.l #4,a0
	
kin_read_palette:
	lea cvid_fix0,a6
	move.l a6,a2
	moveq #15,d0
	moveq #0,d3			; no palette change (default)
	move #$FFF,d2
.not_tc:
	move (a0)+,d1		; one color
	cmp (a2),d1			; equals the old one?
	beq.s .eq_2			; yes
	move d1,(a2)		; else, updates
	addq #1,d3			; palette change!
.eq_2:
	addq.l #2,a2
	dbf d0,.not_tc
	tst.b d3
	beq.s .exit
	move.l a6,-(sp)
	jsr set_palette
.exit:
	rts		
	
seq_disp_image:
	move.l buffer,a0
	move.l 54(a0),d0
	move.l 58(a0),d1
	moveq #$3,d2
	lea vcp_int,a1
	tst.b 62(a0)
	beq.s .st_copy
	moveq #$6,d2
.st_copy:
	move d2,(a1)+
	clr.l (a1)+
	sub.l #$10001,d1
	move.l d1,(a1)+
	move.l d0,(a1)+
	add.l d0,d1
	move.l d1,(a1)
	GEM_VDI vro_cpyfm
	rts
	
kin_read_header:
	SEEK #0,0
	lea cvid_fix0+64,a3	; jumps over the other palettes
	pea (a3)
	moveq #64,d3
	move.l d3,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d0,d3
	beq.s .ok
.bug:
	moveq #1,d0
	rts
.ok:
	cmp.l #$27182818,48(a3)	; magic?
	bne.s .bug
	move (a3),d0
	ext.l d0
	move.l d0,sample_num		; number of frames
	move 40(a3),d0
	move d0,max_imagex
	move 42(a3),d1
	move d1,max_imagey
	add #15,d0
	and #$FFF0,d0				; word aligned
	muls d1,d0
	lsr.l #1,d0					; bytes for one frame
	move.l d0,max_fsize
	move.l #'kin4',comp_txt
	st samp_sizes
	moveq #100,d0
	sub 34(a3),d0				; number of 1/60 per frame
	muls #10,d0
	divs #3,d0				; number of 1/200 per frame
	ext.l d0
	move.l d0,_delay	
	cmp #2,38(a3)
	seq reverse_flag
	moveq #0,d0
	rts

kin_read_data:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
	sf reverse_flag+1
	lea vcp_int,a1
	move #3,(a1)+
	clr.l (a1)+
	move max_imagex,d0
	swap d0
	move max_imagey,d0
	sub.l #$10001,d0
	move.l d0,(a1)+
	move offsx,d1
	swap d1
	move offsy,d1
	move.l d1,(a1)+
	add.l d0,d1
	move.l d1,(a1)+
	lea mfdb_src,a1
	move.l buffer,(a1)+
	add.l #$10001,d0
	move.l d0,(a1)+
	swap d0
	add #15,d0
	lsr #4,d0
	move d0,(a1)+	
.other:
	SEEK #2,0
	lea cvid_fix0,a5
	pea 64(a5)
	move.l #32,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	lea 64(a5),a0	; palette loaded
	st (a5)			; new palette forced
	st 32(a5)		; new palette forced
	bsr kin_read_palette
.disp_again:
	move.l $4ba.w,start_time
	move.l $4ba.w,current_time
	clr.l disp_frame
	cmp #-1,reverse_flag
	bne.s .kaz
	move.l max_fsize,d0	; if reverse, goes back 2 frames
	add.l d0,d0
	sub.l d0,a5
	bra.s	.again
.kaz:
	move.l #64,a5			; current position
.again:	
	move.l a5,d5
	move.l max_fsize,d4
	cmp #-1,reverse_flag
	bne.s .forward
	cmp.l #64,a5
	bmi .exit	
	sub.l d4,d5
	bra.s .common
.forward:
	add.l d4,d5	
	cmp.l total,d5					; end of table?
	bgt .exit						; not more frames
.common:
	SEEK a5,0						; good position
	move.l d5,a5					; new position
	move.l d4,bufused				; size to load
	move.l buffer,-(sp)
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	move.l current_time,d0
.delay:
	cmp.l $4ba.w,d0
	bpl.s .delay
	add.l _delay,d0
	move.l d0,current_time
	bsr kin_disp_image
	addq.l #1,disp_frame
	move.l kbshift,a0
	btst #2,(a0)
	bne.s .stop
	bra .again
.exit:
	lea reverse_flag,a0
	tst.b (a0)+
	beq.s .zak
	tst.b (a0)
	beq.s .rev
	sf (a0)
	bra.s .zak
.rev:
	st (a0)
	bra .disp_again
.zak:
	tst.b is_rep
	bne .disp_again
	bra.s .normal_out
.stop:
	st stopped
.normal_out:
	move.l $4ba.w,end_time
	move.l stack_adr,-(sp)
	GEMDOS 32,6
	rts		

kin_disp_image:
	clr.l mfdb_dest
	GEM_VDI vro_cpyfm
	rts


dlt_read_header:
	cmp.l #32034,total		; pi1 file must be >= 32034 bytes
	bpl.s .ok
.bug:
	moveq #1,d0
	rts
.ok:
	SEEK #0,0
	move.l #cvid_fix0,a3
	move.l a3,-(sp)
	moveq #34,d4
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d4,d0
	bne.s .bug
	tst.w (a3)+
	bne.s .bug		; first word is 0 (ST Low)
	moveq #15,d0
.lb0:
	and.w #$F000,(a3)+	; the palette is 0xxx
	bne.s .bug
	dbf d0,.lb0				; after that, the first file is considered as a PI1 file
	move.l fname_pos,a0
.lb1:
	move.b (a0)+,d0		; one character of the name
	beq.s .lb2				; end reached, no extension
	cmp.b #'.',d0
	bne.s .lb1
.lb2:
	subq #1,a0
	move.b #'.',(a0)+
	move.b #'D',(a0)+
	move.b #'L',(a0)+
	move.b #'T',(a0)+	; new extension
	clr.b (a0)				; end of string
	clr -(sp)
	pea full2				; tries to open DLT file
	GEMDOS 61,8				; fopen 
	move d0,d7				; handle of the file is saved
	bmi .bug
	move.l #32034,d1
	bsr malloc
	move.l d0,s_buffer	; first image (PI1)
	move #2,-(sp)
	move d7,-(sp)
	clr.l -(sp)
	GEMDOS 66,10			; fseek to end
	move.l d0,d1			; total size
	addq.l #8,d1			; one dummy value
	move.l d0,d6
	bsr malloc
	move.l d0,s_buffer_2	; other frames (DLT)
	move.l d0,a3
	clr -(sp)
	move d7,-(sp)
	clr.l -(sp)
	GEMDOS 66,10			; fseek to the beginning
	move.l a3,-(sp)
	move.l d6,-(sp)
	move d7,-(sp)
	GEMDOS 63,12			; reads the whole DLT file
	clr.l (a3,d6.l)
	clr.l 4(a3,d6.l)		; the dummy value (0 for the end
	move d7,-(sp)
	GEMDOS 62,4				; closes the file
	moveq #1,d0				; number of frames (1 for the PI1 file)
.lb3:
	move (a3)+,d1
	beq.s .lb4
	addq.l #1,d0
	muls #6,d1
	add.l d1,a3
	bra.s .lb3
.lb4:
	move.l d0,sample_num
	move #320,max_imagex
	move #200,max_imagey
	move.l #'dlt4',comp_txt
	st samp_sizes
	moveq #13,d0
	move.l d0,_delay
	move.l #32000,max_fsize	; the screen buffer (if 256 or TC)
	moveq #0,d0
	rts
		
dlt_read_data:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
	SEEK #0,0
	move.l s_buffer,a3
	move.l a3,-(sp)
	move.l #32034,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; reads the whole pi1 file
	lea 2(a3),a0			; points to the palette
	st cvid_fix0			; new palette forced
	st cvid_fix0+32		; new palette forced
	bsr kin_read_palette
.disp_again:
	clr.l disp_frame
	move.l $4ba.w,start_time
	move.l $4ba.w,current_time
	move.l buffer,a0		; the screen
	move.l s_buffer,a1	; the pi1
	lea 34(a1),a1			; to the image
	move #999,d0
.clear:
	movem.l (a1)+,d1-d4
	movem.l d1-d4,(a0)
	lea 16(a0),a0
	movem.l (a1)+,d1-d4
	movem.l d1-d4,(a0)
	lea 16(a0),a0
	dbf d0,.clear
	lea cvid_fix0+1024,a4	; line flags
	moveq #49,d0
	moveq #-1,d1
.flags:
	move.l d1,(a4)+			; every line has changed!
	dbf d0,.flags
	move.l s_buffer_2,a5		; dlt pointer
	bra.s .first_time
.again:	
	bsr dlt_decomp_frame
	beq.s .exit					; EQ if last frame
	move.l current_time,d0
.delay:
	cmp.l $4ba.w,d0
	bpl.s .delay
	add.l _delay,d0
	move.l d0,current_time
.first_time:
	addq.l #1,disp_frame
	move.l kbshift,a0
	btst #2,(a0)
	bne.s .stop
	bra .again
.exit:
	tst.b is_rep
	bne .disp_again
	bra.s .normal_out
.stop:
	st stopped
.normal_out:
	move.l $4ba.w,end_time
	move.l stack_adr,-(sp)
	GEMDOS 32,6
	rts	
	
dlt_decomp_frame:
	move.w (a5)+,d0		; number of places to modify
	bne.s .lb0
	rts						; if 0, returns EQ
.lb0:
	subq #1,d0
	move.l buffer,a0
.lb1:
	move (a5)+,d1
	move.l (a5)+,d2
	eor.l d2,(a0,d1.w)
	dbf d0,.lb1
	moveq #1,d0				; returns NE
	rts

flm_read_header:
	SEEK #0,0
	lea cvid_fix0,a3
	pea (a3)
	moveq #68,d7
	move.l d7,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp d0,d7
	beq.s .lb0
.bug:
	moveq #1,d0
	rts
.lb0:
	move.l (a3),d0
	cmp.l total,d0				; total size correct?
	bne.s .bug
	cmp.l #$00010000,48(a3)	; magic
	bne.s .bug
	move.l 8(a3),max_fsize
	move.l 12(a3),sample_num
	move 52(a3),d0
	move d0,max_imagex
	swap d0
	move 54(a3),d0
	move d0,max_imagey
	moveq #0,d1
	move.l #16000,d2
	move.l #32000,d3
	cmp.l #$14000c8,d0		; st_low
	beq.s .found
	moveq #1,d1
	cmp.l #$28000c8,d0		; st med
	beq.s .found
	moveq #2,d1
	cmp.l #$2800190,d0		; st high
	beq.s .found
	moveq #4,d1
	move.l #76800,d2
	move.l #153600,d3
	cmp.l #$28001e0,d0		; tt med
	bne.s .zglity
	cmp.b #4,57(a3)
	beq.s .found
.zglity:
	moveq #7,d1
	st bad_comp					; unsupported!
	cmp.l #$14001e0,d0		; tt low
	beq.s .found
	moveq #-1,d1
.found:
	move d1,tt_res
	move.l d2,tt_flag_size
	move.l d3,tt_screen_size
	move.l #'flm0',d0
	add.b 57(a3),d0			; flm1, 2, 4, 8, 16...
	tst.b is_mono
	beq.s .no_limit
	cmp.l #'flm1',d0
	beq.s .no_limit
	st bad_comp					; in mono, only FLM1 allowed
.no_limit:
	move.l d0,comp_txt
	move 66(a3),d0
	move d0,mapused		; number of colors
	add d0,d0				; palette size
	add #68,d0				; plus header
	ext.l d0
	add.l 4(a3),d0			; plus extra infos
	move.l d0,snd_pos		; offset for the first frame
	addq.l #4,snd_pos		; next time we won't read the lenght
	SEEK d0,0				; go there
	pea snd_tt_end
	moveq #4,d7
	move.l d7,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; read size of first frame!
	cmp.l d0,d7
	bne .bug
	st samp_sizes
	SEEK #8,1
	pea dum
	move.l d7,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12		; reads 'time' id or else
	cmp.l d0,d7
	bne .bug
	move.l #13,_delay
	bsr flm_8_to_4_bits
	move.l dum,d0
	or.l #$20202020,d0
	cmp.l #'time',d0
	beq.s .extended
	moveq #0,d0
	rts	
.extended:
	tst.l 4(a3)	; no extra datas
	beq .exit
	move mapused,d0
	add d0,d0
	add #68,d0
	ext.l d0
	SEEK d0,0				; place for extra infos
.again:
	move.l d0,flm_snd_pos
	bsr read_len_id
	or.l #$20202020,d0	; the ID
	cmp.l #'dsnd',d0		; dma sound extension?
	bne.s .next_bloc
	bsr read_len_id
	move d0,d1
	swap d1
	move.l d1,flm_snd_size
	swap d0
	move.b d0,d1
	ext.w d1
	move d1,channels		; 1 or 2
	move #8,sound_bits
	lsr #8,d0				; frequency
	and.b #3,d0
	move.l #12517,d1
	subq #1,d0
	beq.s .found_f
	move.l #25033,d1
	subq #1,d0
	beq.s .found_f
	add.l d1,d1
	subq #1,d0
	beq.s .found_f
	clr.l d0
	st bad_sound
.found_f:
	move.l d1,frequency
	add.l #14,flm_snd_pos	; id+len+byte+byte+len
	bra.s .exit
.next_bloc:
	tst.l d1
	beq.s .exit				; no more blocs
	SEEK d1,1				; skips the bloc
	bra .again
.exit:
	moveq #-1,d0
	rts

flm_8_to_4_bits:
	cmp #4,tt_res
	beq.s .tt_med
	cmp #2,tt_res
	beq .st_high
	rts
.tt_med:
	lea colors256,a6
	moveq #0,d0
.loop:
	move d0,d1
	moveq #0,d2
	lsl.b d1
	roxl.b d2
	lsl.b #2,d1
	roxl.b d2
	lsl.b #2,d1
	roxl.b d2
	lsl.b #2,d1
	roxl.b d2
	move.b d2,(a6)+
	addq #1,d0
	cmp #256,d0
	bmi.s .loop
	rts
.st_high:
	lea cvid_fix0,a6
	lea cvid_fix1,a5
	moveq #0,d0
.loop2:
	move d0,d1
	moveq #0,d2
	moveq #0,d3
	rept 4
		lsl.b d1
		roxl.b d2
		lsl.b d1
		roxl.b d3
	endr
	move.b d2,(a6)+
	move.b d3,(a5)+
	addq #1,d0
	cmp #256,d0
	bmi.s .loop2
	rts
	
flm_read_data:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
	tst.b bad_comp
	bne .stop
	tst.b is_mono
	bne .again
	cmp.l #'flm1',comp_txt
	bne.s .colors
	clr $ffff8246.w			; 3 is black
	move #$444,$ffff8242.w	; 1 and 2 are grey
	move #$444,$ffff8244.w
	move #$FFF,$ffff8240.w	; 0 is white
	bra.s .again
.colors:
	SEEK #68,0
	lea cvid_fix0+64,a3
	move mapused,d0
	add d0,d0
	ext.l d0
	pea (a3)
	move.l d0,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp #17,mapused
	bmi.s .old
	bsr flm_pal_256
	bra.s .again
.old:
	move.l a3,a0
	st -32(a3)
	st -64(a3)
	bsr kin_read_palette
.again:
	move.l snd_pos,d0
	SEEK d0,0				; first frame
	move.l snd_tt_end,snd_size	; size of 1st frame
	move.l s_buffer,a0
	move.l s_buffer_2,a1
	moveq #-1,d1
	move.l tt_screen_size,d0
	asr.l #4,d0
	subq #1,d0
.clear:
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	move.l d1,(a1)+
	move.l d1,(a1)+
	dbf d0,.clear
	move.l sample_num,d7	; number of frames
	move.l $4ba.w,start_time
	move.l $4ba.w,current_time
	clr.l disp_frame
.lb0:
	move.l snd_size,d5
	move.l buffer,a3
	move.l a3,-(sp)
	move.l d5,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; read one frame
	move.l -4(a3,d5.l),snd_size	; size of the next frame
	bsr flm_decomp_frame
	move sr,d1
	tst.l disp_frame
	bne.s .not_first
	move.l $4ba.w,start_time
	move.l $4ba.w,current_time
	tst.b playing
	beq.s .not_first
	jsr flm_start_sound
.not_first:	
	addq.l #1,disp_frame
	move.l buffer,a3
	move.l 8(a3),d0
	or.l #$20202020,d0
	cmp.l #'time',d0
	bne.s .old_delay
	tst.b sync
	beq.s .common			; no synchro wanted
	move.l 12(a3),d0
	add.l start_time,d0
.new_delay:
	cmp.l $4ba.w,d0
	bpl.s .new_delay
	bra.s .common
.old_delay:
	move.l current_time,d0
.delay:
	cmp.l $4ba.w,d0
	bpl.s .delay
	add.l _delay,d0
	move.l d0,current_time
.common:
	move d1,ccr
	beq.s .nothing
	tst.b is_mono
	bne.s .nothing
	tst tt_res
	beq.s .nothing
	move.l d7,-(sp)
	bsr flm_disp_image
	move.l (sp)+,d7
.nothing:
	move.l kbshift,a0
	btst #2,(a0)
	bne.s .stop
	subq.l #1,d7			; one frame less
	bne .lb0				; not ended
	tst.b playing
	beq.s .no_sound
.wait_sound:
	tst.b _snd
	bmi.s .wait_dma
	tst.b yamaha_flag
	beq.s .no_sound
	bra.s .is_key
.wait_dma:
	btst #0,$ffff8901.w
	beq.s .no_sound
.is_key:
	btst #2,(a0)			; control?
	bne.s .stop
	bra.s .wait_sound
.no_sound:
	tst.b is_rep
	bne .again
	bra.s .normal_out
.stop:
	st stopped
	tst.b playing
	beq.s .normal_out
	tst.b _snd
	bmi.s .stop_dma
	move sr,d0
	move #$2700,sr
	move.l yamaha_ptr,a0
	clr.b (a0)+
	clr.b (a0)
	move d0,sr
	bra.s .normal_out
.stop_dma:
	clr.b $ffff8901.w 
.normal_out:	
	move.l $4ba.w,end_time
	move.l stack_adr,-(sp)
	GEMDOS 32,6
	rts

flm_pal_256:
	rts
	
;	lea cvid_fix1+8192,a4
;	move #$fff,d3
;	move #255,d4
;.not_tc:
;	lea cvid_fix0+64,a3
;	lea indexs,a5
;.lb1:
;	move (a3)+,d1
;	and d3,d1
;	if REG=0
;		move (a4,d1.w*2),d1
;	endif
;	tst.b is_tt
;	beq.s .not_tt
;	move d1,-(sp)
;	move #255,d1
;	sub d4,d1
;	move d1,-(sp)
;	XBIOS 83,6
;	dbf d4,.lb1
;	rts
;.not_tt:
;	lea vs_int,a0
;	move (a5)+,(a0)+
;	move d1,d0
;	lsr #8,d0
;	muls #66,d0
;	move d0,(a0)+
;	move d1,d0
;	lsr #4,d0
;	and #$f,d0
;	muls #66,d0
;	move d0,(a0)+
;	and #$f,d1
;	muls #66,d1
;	move d1,(a0)
;	GEM_VDI vs_color
;	dbf d4,.lb1
;	rts	
	
; returns EQ if nothing to do

flm_decomp_frame:
	moveq #20,d0	; minimal size
	add.l 4(a3),d0	; plus extra datas
	cmp.l d0,d5
	bgt.s .ok
.nothing:
	moveq #0,d0
	rts				; a nop frame???
.ok:
	lea 4(a3),a2
	add.l (a2)+,a2
	move.l (a2)+,d0		
	bmi.s .nothing
	exg.l a2,a3
	add.l (a3)+,a2	
	subq.l #4,a2
	move.l s_buffer,a0	; the screen (or buffer)
	move.l s_buffer_2,a1	; the flags for words that changed
	add.l d0,a0				; plus the offset
	lsr.l d0
	add.l d0,a1				; idem in the flags
.lb0:
	moveq #0,d0
	move.b (a3)+,d0		; one code
	bmi.s .lb1
	moveq #0,d1
	move.b (a3)+,d1		; second code
	move d1,d3
.loop:
	move (a2)+,d2
	eor d2,(a0)+
	st (a1)+
	dbf d1,.loop
	add d0,a0
	add d0,a0
	add d0,a1
	bra.s .lb0
.lb1:
	bclr #7,d0				; normal code
	cmp #$7d,d0
	bmi.s .lb2
	beq.s .end
	move.l (a2)+,d0
	add.l d0,a0
	lsr.l d0
	add.l d0,a1
	bra.s .lb0
.lb2:
	move d3,d1
	bra.s .loop
.end:
	moveq #1,d0
	rts

flm_disp_image:
	move.l s_buffer,a0		; the words
	move.l s_buffer_2,a1		; the flags
	move.l physbase,a3
	move tt_res,d0
	cmp #2,d0
	beq flm_st_high
	cmp #4,d0
	beq flm_tt_mid
	rts						; error...
flm_tt_mid:
	add #6400,a0				; 20 lines skipped
	add #3200,a1				; idem for flags
	move #199,d0				; number of lines
	moveq #0,d2
	lea colors256,a6			; conversion of 2 pixels for one
.lines:
	moveq #19,d1				; 20 times 16 pixels	= 320 pixels
.pixels:
	tst.l (a1)
	bne.s .changed
	tst.l 4(a1)
	bne.s .changed
	addq.l #8,a1
	add #16,a0
	bra .loop
.changed:
	clr.l (a1)+
	clr.l (a1)+
	move.b (a0)+,d2
	move.b 0(a6,d2.w),d4
	lsl #4,d4
	move.b (a0)+,d2
	or.b 0(a6,d2.w),d4
	lsl #4,d4
	move.b (a0)+,d2
	move.b 0(a6,d2.w),d5
	lsl #4,d5
	move.b (a0)+,d2
	or.b 0(a6,d2.w),d5
	lsl #4,d5
	move.b (a0)+,d2
	move.b 0(a6,d2.w),d6
	lsl #4,d6
	move.b (a0)+,d2
	or.b 0(a6,d2.w),d6
	lsl #4,d6
	move.b (a0)+,d2
	move.b 0(a6,d2.w),d7
	lsl #4,d7
	move.b (a0)+,d2
	or.b 0(a6,d2.w),d7
	lsl #4,d7
	move.b (a0)+,d2
	or.b 0(a6,d2.w),d4
	lsl #4,d4
	move.b (a0)+,d2
	or.b 0(a6,d2.w),d4
	move.b (a0)+,d2
	or.b 0(a6,d2.w),d5
	lsl #4,d5
	move.b (a0)+,d2
	or.b 0(a6,d2.w),d5
	move.b (a0)+,d2
	or.b 0(a6,d2.w),d6
	lsl #4,d6
	move.b (a0)+,d2
	or.b 0(a6,d2.w),d6
	move.b (a0)+,d2
	or.b 0(a6,d2.w),d7
	lsl #4,d7
	move.b (a0)+,d2
	or.b 0(a6,d2.w),d7
	movem.w d4-d7,(a3)
.loop:
	addq.l #8,a3
	dbf d1,.pixels
	add #320,a0			; skips one line
	add #160,a1			; idem for flags
	dbf d0,.lines
	rts	
flm_st_high:
	move #199,d0
	lea cvid_fix0,a6
	lea cvid_fix1,a5
	moveq #0,d2
.lines:
	moveq #19,d1
.pixels:
	tst.w (a1)
	bne.s .changed
	addq.l #2,a1
	addq.l #4,a0
	bra.s .loop
.changed:
	clr (a1)+
	move.b (a0)+,d2
	move.b 0(a6,d2.w),d4
	lsl #4,d4
	move.b 0(a5,d2.w),d5
	lsl #4,d5
	move.b (a0)+,d2
	or.b 0(a6,d2.w),d4
	lsl #4,d4
	or.b 0(a5,d2.w),d5
	lsl #4,d5
	move.b (a0)+,d2
	or.b 0(a6,d2.w),d4
	lsl #4,d4
	or.b 0(a5,d2.w),d5
	lsl #4,d5
	move.b (a0)+,d2
	or.b 0(a6,d2.w),d4
	or.b 0(a5,d2.w),d5
	movem.w d4-d5,(a3)
.loop:
	addq.l #8,a3
	dbf d1,.pixels
	add #80,a0			; skip one line
	add #40,a1
	dbf d0,.lines	
	rts
flm_tt_low:
	rts

dl_read_header:
	SEEK #0,0		; start of file
	lea cvid_fix0,a3
	moveq #64,d3
	pea (a3)
	move.l d3,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp d0,d3
	beq.s .ok
.bug:
	moveq #1,d0
	rts
.ok:
	move.b (a3)+,d3		; 1 or 2
	cmp.b #1,d3
	bne.s .lb0
	moveq #1,d4				; 160x100
	moveq #24,d0			; header size
	bra.s .lb1
.lb0:
	cmp.b #2,d3
	bne.s .bug
	move.b (a3)+,d4
	moveq #47,d0			; header size
	lea 20(a3),a3			; one zone
.lb1:
	lea 20(a3),a3			; second zone
	moveq #0,d5
	move.b (a3)+,d5		; screens
	mulu #64000,d5		; minimum size
	move.l d5,max_fsize	; to load the whole animation
	move.l d0,sound_seek
	add.l #768,d0			; plus the palette
	add.l d5,d0				; plus the screens
	cmp.l total,d5
	bpl.s .bug				; not enough bytes!
	cmp.b #1,d3
	bne.s .long_fr
	moveq #0,d0
	move.b (a3)+,d0
	ror #8,d0
	move.b (a3)+,d0
	ror #8,d0				; intel!
	bra.s .common
.long_fr:
	move.b (a3)+,d0
	ror #8,d0
	move.b (a3)+,d0
	swap d0
	move.b (a3)+,d0
	ror #8,d0
	move.b (a3)+,d0	
	INTEL d0
.common:
	move.l d0,sample_num
	move.l #'dl/0',d0
	add.b d3,d0
	move.l d0,comp_txt	; dl-1 or dl-2
	move #320,d0
	move #200,d1
	moveq #1,d2				; one image per screen
	subq #1,d4
	bmi.s .good_size
	lsr d0
	lsr d1
	moveq #4,d2				; 4 images per screen
	subq #1,d4
	bmi.s .good_size
	lsr d0
	lsr d1
	moveq #16,d2			; 16 images per screen
.good_size:
	move d0,max_imagex
	move d1,max_imagey
	move d2,dl_i_per_s	; images per screen
	st samp_sizes
	moveq #33,d0
	move.l d0,_delay		; 6fps
	moveq #0,d0
	rts	
	
load_dl_palette:
	move.l sound_seek,d0
	SEEK d0,0	; start of palette
	lea cvid_fix1,a3
	move.l #$01000000,(a3)+		; one bloc, 0 to 255
	pea (a3)
	move.l #768,d3
	move.l d3,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	lea -4(a3),a0				; the palette
	moveq #64,d0
	subq #1,d3
	moveq #0,d1
.look_for:
	move.b (a3)+,d1				; one color
	cmp d0,d1
	bpl.s .eight_bits
	dbf d3,.look_for
	jsr fli_color_64_256	
	rts
.eight_bits:
	jsr fli_color_256_256
	rts

count_dl_indexs:
	move.l #64000,d0
	sub.l d0,d5
	bmi.s .end
	lea count_tab,a2
.lb0:
	moveq #0,d1
	move.b (a3)+,d1
	add d1,d1
	add d1,d1
	addq.l #1,0(a2,d1.w)
	dbf d0,.lb0
	movem.l a3/d5,-(sp)
	bsr quit_count
	movem.l (sp)+,a3/d5
	bra.s count_dl_indexs	
.end:
	rts

load_dl_screens:
	lea colors256,a6				; color to grey conversion
	move.l buffer,a3
	move.l max_fsize,d5
	pea (a3)
	move.l d5,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12					; all screens loaded at once!
	tst.b count
	bne.s count_dl_indexs
	move.l a3,a0
	lsr.l #4,d5						; number of times we've got 16 pixels
	move.l d5,d0
	moveq #0,d6
.to_indexs:
	rept 16
	move.b (a3),d6
	move.b 0(a6,d6.w),(a3)+
	endr
	subq.l #1,d0
	bne.s .to_indexs
	move.l a0,a3
	tst.b is_mono
	bne .bayer_dith
.doug_16:
	movem.l (a3)+,d1-d4
	add.l d1,d1
	add.l d2,d2
	add.l d3,d3
	add.l d4,d4
	move.l #$00ff00ff,d0
	splice.l d1,d3,8
	splice.l d2,d4,8
	lsr.l #4,d2
	lsr.l #4,d4
	or.l d2,d1
	or.l d4,d3
	move d1,d2
	move d3,d4
	swap d1
	swap d3
	move #$3333,d0
	splice.w d1,d2,2
	splice.w d3,d4,2
	move #$5555,d0
	splice.w d1,d3,1
	splice.w d2,d4,1
	move d4,(a0)+
	move d2,(a0)+
	move d3,(a0)+
	move d1,(a0)+
	subq.l #1,d5
	bne .doug_16
	rts		
.bayer_dith:
	lea bayer2(pc),a4		; matrix
	moveq #0,d4					; start line
	moveq #0,d7					; 0 and max_x alternatively
	move.l a3,a1				; to adapt...
	move.l d5,d6				; idem
	divs #20,d6					; number of lines
	add d6,d6					; doubled
.other_line:
	sub.w d7,a1					; to repeat twice a line
	move.l a0,a3				; saves the current screen pointer
	move #320,d5
	move d5,d0
	sub d7,d0
	move d0,d7					; 0 or 320 alternatively
	and.w #$7F,d4
	lea 0(a4,d4.w),a2			; line into bayer
	add.w #16,d4					; next line
	bra.s .init
.other_16:	
	move.b (a1)+,d3
	cmp.b (a2)+,d3
	bls.s .black
	bclr d1,d0
.black:
	subq  #1,d1
	cmp.b (a2)+,d3
	bls.s .black2
	bclr d1,d0
.black2:
	dbf d1,.lb2
	move.l d0,(a0)+
	sub #32,a2
.init:
	moveq #-1,d0
	moveq #31,d1
	dbf d5,.other_16
	dbf d6,.other_line
	rts
.lb2:
	dbf d5,.other_16
	move.l d0,(a0)
.dec:
	dbf d6,.other_line
	rts			
	
	
dl_frame_table:
	move.l s_buffer,a3
	move.l sample_num,d3
	cmp.l #'dl/1',comp_txt
	beq.s .lb0
.lb1:
	bsr read_word
	ror #8,d0						; intel!!
	move d0,(a3)+
	subq.l #1,d3
	bne.s .lb1
	rts
.lb0:
	bsr read_byte
	moveq #0,d1
	move.b d0,d1
	divs #10,d1
	subq #1,d1
	move d1,d0						; nø of the screen
	swap d1
	subq #1,d1						; nø of image inside screen
	muls dl_i_per_s,d0
	add d1,d0						; global nø of image
	move d0,(a3)+
	subq.l #1,d3
	bne.s .lb0
	rts

dl_read_data:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
	move.l $4ba.w,current_time
.again:
	move.l #cvid_fix1+4000,s_buffer_2	; my stack for loops
	move.l s_buffer,a3	; table of frames
	move.l sample_num,d7	; number of frames
	move.l $4ba.w,start_time
	clr.l disp_frame
.lb0:
	moveq #0,d0
	move (a3)+,d0			; nø of the image
	bpl.s .normal
	cmp #$ffff,d0
	bne.s .cmd1
	move (a3)+,d0			; count
	move.l s_buffer_2,a0	; stack
	subq.l #1,d7
	move.l d7,-(a0)
	move.l a3,-(a0)
	move d0,-(a0)
	move.l a0,s_buffer_2
	bra .glop
.cmd1:
	cmp #$fffe,d0
	bne.s .cmd2
	move.l s_buffer_2,a0
	subq #1,(a0)+
	bne.s .not_end
	addq.l #8,a0
	move.l a0,s_buffer_2
	bra.s .glop
.not_end:
	move.l (a0)+,a3
	move.l (a0)+,d7	
	bra.s .glop
.cmd2:
	cmp #$fffd,d0
	bne.s .glop
	move.l #$20002,-(sp)
	trap #13
	addq.l #4,sp
	bra.s .glop
.normal:
	move dl_i_per_s,d2
	divs d2,d0	; screen and index
	moveq #0,d1
	move d0,d1
	muls #32000,d1		; offset for that screen
	swap d0
	lea .offsets(pc),a0
	tst.b is_mono
	beq.s .col
	lea .mono_off(pc),a0
.col:
	cmp #16,d2
	bne.s .lb1
	lea 16(a0),a0
.lb1:
	lsl #2,d0
	add.l 0(a0,d0.w),d1	; address in that screen
	add.l buffer,d1		; absolute address in that screen
	bsr dl_copy_image
	addq.l #1,disp_frame
	move.l current_time,d0
.delay:
	cmp.l $4ba.w,d0
	bpl.s .delay
	add.l _delay,d0
	move.l d0,current_time
	move.l kbshift,a0
	btst #2,(a0)
	bne.s .stop
.glop:
	subq.l #1,d7			; one frame less
	bne .lb0				; not ended
	tst.b is_rep
	bne .again
	bra.s .normal_out
.stop:
	st stopped
.normal_out:	
	move.l $4ba.w,end_time
	move.l stack_adr,-(sp)
	GEMDOS 32,6
	rts	
.offsets: dc.l 0,80,16000,16080
.offsets2: dc.l 0,40,80,120,8000,8040,8080,8120
			  dc.l 16000,16040,16080,16120,24000,24040,24080,24120	
.mono_off: dc.l 0,40,16000,16040
.mon_off2: dc.l 0,20,40,60,8000,8020,8040,8060
			dc.l 16000,16020,16040,16060,24000,24020,24040,24060


dl_copy_image:
	move.l d1,a1			; buffer
	move.l image,a0
	move #320,d3
	move max_imagex,d4
	sub d4,d3				; screen inc for one line
	lsr d3
	move #320,d5
	sub d4,d5				; buffer inc for one line
	lsr d5
	move max_imagey,d6
	lsr #4,d4
	tst.b is_mono
	beq.s .col
	lsr d3			; half the offsets
	lsr d5
	lsr d4
	add d6,d6		; double lines
.col:
	subq #1,d6				; for the loop
	subq #1,d4				; 16 pixels at a time
.line:
	move d4,d1
.pixels:
	movem.l (a1)+,d0/d2
	movem.l d0/d2,(a0)
	addq.l #8,a0
	dbf d1,.pixels
	add d3,a0
	add d5,a1
	dbf d6,.line
	rts

	if REG=0
	
gif_to_grey:
	ext.l d0
	divs #3,d0					; number of colors
	bra.s .loop
.next:
	moveq #0,d1
	moveq #0,d2
	move.b (a0)+,d1				; red
	move.b (a0)+,d2				; green
	add d2,d2
	add d1,d2
	move d2,d1
	add d2,d2
	add d1,d2
	moveq #0,d1
	move.b (a0),d1
	add d1,d2
	divs #10,d2
	move.b d2,(a0)
	move.b d2,-(a0)
	move.b d2,-(a0)
	addq.l #3,a0
.loop:
	dbf d0,.next
	move.l a0,a4
	rts
	
	endif

bat_create_gif:
	move.l buffer,a3
	move.l gif_pal_size,d0
	lea 13(a3,d0.l),a4		; start of datas
	tst.b smc_a
	bne.s .add_frame			; not the first one, don't use the colormap
	if REG=0
		move.l d0,-(sp)
		lea 13(a3),a0			; start of palette
		bsr gif_to_grey
		move.l (sp)+,d0
	endif
	move.b #'9',4(a3)			; turns all to GIF89a
	addq.l #8,d0
	addq.l #5,d0				; colormap + 13 = header!!!
	move.l a3,-(sp)
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12				; fwrite!!
	moveq #0,d1					; default is no netscape extension
	move bat_gif_loop,d0
	cmp #1,d0
	beq.s .no_loop
	ror #8,d0
	move d0,.net_loop
	moveq #19,d1				; 19 bytes more
.no_loop:
	move.l sample_num,d0
	INTEL d0
	move.l d0,.my_frm
	lea .my_ext(pc),a0
	sub d1,a0
	move.l a0,-(sp)
	moveq #20,d0
	add.l d1,d0
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12				; my extension (and maybe Netscape)
	st smc_a						; turns the flag (header read)
.add_frame:
	add.l bufused,a3			; end of file
	clr.b (a3)
	move.b #$3b,1(a3)		; end of file forced
.frames:
	move.b (a4)+,d0	; code
	cmp.b #$3B,d0
	beq .end
	cmp.b #$2c,d0
	bne .lb0
	bsr display_add_frame
	addq.l #1,disp_frame
	lea -1(a4),a0		; start of frame
	addq.l #8,a4		; four words
	move.b (a4)+,d0
	btst #7,d0
	beq.s .no_pal
	and #$7,d0
	addq #1,d0
	moveq #1,d1
	lsl d0,d1
	move d1,d0
	add d0,d1
	add d0,d1			; size of the palette
	if REG=0
		move d1,d0
		move.l a0,-(sp)
		move.l a4,a0
		bsr gif_to_grey	;and skip the palette
		move.l (sp)+,a0
	else		
		add d1,a4			; skips the palette
	endif
.no_pal:
	addq.l #1,a4		; LZW code
	moveq #0,d0
.lb2:
	cmp.l a3,a4
	bpl .end			; bad frame!
	move.b (a4)+,d0
	beq.s .save_frame	; 0, end of this part
	cmp.b #'0',d0		; for CALAMUS, them stupid!
	bne.s .lb3
	move.b (a4),d1
	cmp.b #$2c,d1
	beq.s .save_cal
	cmp.b #$3b,d1
	beq.s .save_cal
	cmp.b #$21,d1
	bne.s .lb3
	move.b 1(a4),d1
	cmp.b #$f9,d1
	beq.s .save_cal
	cmp.b #$fe,d1
	beq.s .save_cal
	cmp.b #$01,d1
	beq.s .save_cal
	cmp.b #$ff,d1
	beq.s .save_cal
.lb3:	
	add d0,a4			; else, an offset
	bra.s .lb2			; other bloc
.save_cal:
	clr.b -1(a4)
.save_frame:
	move.l a4,d0
	sub.l a0,d0			; size of the frame
	move.l a0,-(sp)
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12		; fwrite!
	tst.w delay_gif
	beq .frames		; delay is 0
	pea .delay_ext(pc)
	moveq #8,d0
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12		; fwrite (delay extension bloc)
	bra .frames
.lb0:
	cmp.b #$21,d0
	bne.s .end
	bsr trans_index
	addq.l #1,a4
.other:
	moveq #0,d0
.lb1:
	cmp.l a3,a4
	bpl.s .end
	move.b (a4)+,d0
	beq .frames			; 0, end of this part
	add d0,a4			; else, an offset
	bra.s .lb1			; other bloc
.end:	
	rts	
.net_ext: dc.b $21,$ff,$0b,'NETSCAPE','2.0',$03,$01
.net_loop: dc.b 0,0,0		; even address!
.my_ext: dc.b $21,$ff,$0b,'M_PLAYER','FRM',$04
.my_frm: dc.b 0,0,0,0,0		; even adress!
	dc.b 0						; to get delay_gif to an even address
.delay_ext: dc.b $21,$f9,$04,$00
delay_gif: dc.b 0,0,0,0
	even

trans_index:
	cmp.b #$f9,(a4)	; delay extension?
	beq.s .lb0
.exit:
	rts
.lb0:
	cmp.b #$4,1(a4)	; 4 bytes?
	bne.s .exit
	lea .trans(pc),a0	; out data
	move.b 2(a4),d0	; trans+restore byte
	move.b d0,3(a0)
	move.b 5(a4),6(a0) ; trans index (if used)
	btst #0,d0				; transparency index???
	bne.s .write
	and.b #$1c,d0		; action (0 to 7)
	cmp.b #$80,d0
	bmi.s .exit			; 0 or 1, no action!
.write:
	pea (a0)
	moveq #8,d0
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12		; fwrite!	
	rts
.trans: dc.b $21,$f9,$04,$01,$00,$00
.index: dc.b 0,0

	even
	
bat_gif:
	subq.l #1,disp_frame
	move.l d5,bufused			;size of the file
	move.l buffer,a3			; the file is here!
	bsr gif_read_header
	beq.s .ok
	rts
.ok:
	tst.b create_mov
	bgt bat_create_gif
.gif_loop:
	move.l buffer,a6
	move.l a6,a0
	add.l bufused,a0			; end_of_file
	clr.b (a0)
	move.b #$3B,1(a0)
	move.l a0,last_size
	moveq #0,d0
	move.b gif_flags,d0
	bset #15,d0
	lea 13(a6),a6		; start of global palette	
	bsr gif_palette
.frames:
	move.b (a6)+,d0	; code
	cmp.b #$3B,d0
	beq.s .end
	cmp.b #$2c,d0
	bne.s .lb0
	subq.l #1,sample_num
	bsr gif_decode_frame
	move.l a5,-(sp)		; the next length
	move.l display_ste,a0
	jsr (a0)
	move.l (sp)+,a6
	bra.s .other		; skips if something remains
.lb0:
	cmp.b #$21,d0
	bne.s .end
	addq.l #1,a6
.other:
	moveq #0,d0
.lb1:
	cmp.l last_size,a6
	bpl.s .end
	move.b (a6)+,d0
	beq.s .frames		; 0, end of this part
	add d0,a6			; else, an offset
	bra.s .lb1			; other bloc
.end:	
	st smc_a			; if next time, don't read palette
	rts
	
gif_read_header:
	tst.b slide_gif
	bne.s .ok
	SEEK #0,0
	lea cvid_fix0,a3
	move.l a3,-(sp)
	moveq #13,d3
	move.l d3,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d3,d0
	beq.s .ok
.bug:
	moveq #1,d0
	rts
.ok:
	cmp.l #'GIF8',(a3)+
	bne.s .bug
	move.l #'gif7',d0
	cmp #'7a',(a3)
	beq.s .found
	move.b #'9',d0
	cmp #'9a',(a3)
	bne.s .bug
.found:
	addq.l #2,a3
	move.l d0,comp_txt
	move (a3)+,d0
	ror #8,d0
	move d0,max_imagex
	move (a3)+,d0
	ror #8,d0
	move d0,max_imagey
	move (a3)+,d0
	move d0,gif_flags
	lsr #8,d0				; upper byte
	and #$7,d0
	addq #1,d0				; number of bits per color
	moveq #1,d1
	lsl d0,d1				; size of the palette
	move.l d1,d0
	add.l d1,d1
	add.l d0,d1				; 3 times the number of colors
	move.l d1,gif_pal_size
	moveq #39,d3			; 20 Mplayer + 19 Netscape
	tst.b slide_gif
	bne.s .special
	SEEK d1,1				; skips the palette
	lea cvid_fix0,a3
	move.l a3,-(sp)
	move.l d3,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d3,d0
	bne .end
	bra.s .common
.special:
	add.l d1,a3				; skips the palette
.common:
	add.l a3,d3				; end of the block read
	move.l #$20202020,d1
	move #1,gif_repeat
.other_bloc:
	cmp.b #$21,(a3)+
	bne .end
	cmp.b #$FF,(a3)+
	bne .end
	cmp.b #11,(a3)+		; application bloc?
	bne .end
	move.b (a3)+,d0
	ror #8,d0
	move.b (a3)+,d0
	swap d0
	move.b (a3)+,d0
	ror #8,d0
	move.b (a3)+,d0
	or.l d1,d0
	cmp.l #'mpl',d0		; ID of application
	bne.s .other_id
	move.b (a3)+,d0
	ror #8,d0
	move.b (a3)+,d0
	swap d0
	move.b (a3)+,d0
	ror #8,d0
	move.b (a3)+,d0
	or.l d1,d0
	cmp.l #'ayer',d0
	bne .end
	move.b (a3)+,d0
	ror #8,d0
	move.b (a3)+,d0
	swap d0
	move.b (a3)+,d0
	ror #8,d0
	move.b (a3)+,d0
	lsr.l #8,d0
	or.l d1,d0
	cmp.l #' frm',d0		; frame infos?
	bne.s .end
	move.b (a3)+,d0
	ror #8,d0
	move.b (a3)+,d0
	swap d0
	move.b (a3)+,d0
	ror #8,d0
	move.b (a3)+,d0
	INTEL d0
	move.l d0,sample_num
	bra.s .again
.other_id:
	cmp.l #'nets',d0
	bne.s .end
	move.b (a3)+,d0
	ror #8,d0
	move.b (a3)+,d0
	swap d0
	move.b (a3)+,d0
	ror #8,d0
	move.b (a3)+,d0
	or.l d1,d0
	cmp.l #'cape',d0
	bne.s .end
	move.b (a3)+,d0
	ror #8,d0
	move.b (a3)+,d0
	swap d0
	move.b (a3)+,d0
	ror #8,d0
	move.b (a3)+,d0
	lsr.l #8,d0
	or.l d1,d0
	cmp.l #' 2.0',d0
	bne.s .end
	addq.l #1,a3
	move.b (a3)+,d0
	ror #8,d0
	move.b (a3)+,d0
	ror #8,d0
	move d0,gif_repeat
.again:
	addq.l #1,a3			; skips the last '00'
	cmp.l d3,a3
	bmi .other_bloc
.end:
	st samp_sizes
	moveq #0,d0
	rts

gif_data_ram:
	SEEK #0,0
	move.l buffer,-(sp)
	move.l total,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; read the whole file
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
	sf smc_a				; first time, read palette
.again:
	move gif_repeat,_gif_rep
.gif_loop:
	clr.l disp_frame
	clr.l sample_num
	move.l $4ba.w,start_time
	move.l buffer,a6
	move.l a6,a0
	add.l total,a0			; end_of_file
	clr.b (a0)
	move.b #$3B,1(a0)
	move.l a0,last_size
	moveq #0,d0
	move.b gif_flags,d0
	bset #15,d0
	lea 13(a6),a6		; start of global palette	
	bsr gif_palette
.frames:
	move.l kbshift,a0
	btst #2,(a0)
	bne .stop
	move.b (a6)+,d0	; code
	cmp.b #$3B,d0
	beq.s .end
	cmp.b #$2c,d0
	bne.s .lb0
	bsr gif_decode_frame
	move.l a5,-(sp)		; the next length
	move.l display_ste,a0
	jsr (a0)	
	move.l (sp)+,a6		; the next length
	bra.s .other		; skips if something remains
.lb0:
	cmp.b #$21,d0
	bne.s .end
	cmp.b #$f9,(a6)+	; sub code
	bne.s .other
	bsr gif_delay		; then will skip the bloc like 'other'
.other:
	moveq #0,d0
.lb1:
	cmp.l last_size,a6
	bpl.s .end
	move.b (a6)+,d0
	beq.s .frames		; 0, end of this part
	add d0,a6			; else, an offset
	bra.s .lb1			; other bloc
.end:	
	st smc_a			; if next time, don't read palette
	subq #1,_gif_rep
	beq.s .another
	move.l kbshift,a0
	btst #0,(a0)	; shift with loop mode? to stop!
	bne.s .normal_out
	btst #1,(a0)
	bne.s .normal_out
	bra .gif_loop	
.another:
	tst.b is_rep
	bne .again
	bra.s .normal_out
.stop:
	st stopped
.normal_out:	
	move.l $4ba.w,end_time
	move.l stack_adr,-(sp)	
	GEMDOS 32,6
	rts

old_token: dc.w 0

gif_decode_frame:
	addq.l #1,disp_frame
	addq.l #1,sample_num
	bsr gif_prepare_rect
	moveq #0,d0
	move.b (a6)+,d0
	btst #6,d0
	sne gif_interlace
	bsr gif_palette
	moveq #0,d7
	move.b (a6)+,d7		; LZW size
	move d7,root_code
	moveq #1,d6
	lsl d7,d6				; bits2
	addq #1,d7				; code_size
	moveq #1,d0
	lsl d7,d0
	move d0,codesize2
	move d6,d5
	addq #2,d5				; next code
	moveq #-1,d2			; old code
	move d2,old_token
	moveq #0,d3
	move.l a6,a5			; end of bloc
	move.l hc_cvid,a4
	lea 16384(a4),a3		; line buffer!
.next_code:
	bsr gif_get_code
	addq #1,d6
	cmp d0,d6				; end of image?
	bne.s .no
.end:
	sf gif_trans			; only once
	rts
.no:
	subq #1,d6
	cmp d0,d5				; > next code?
	bmi.s .end
	move d0,d4				; current code
	cmp d0,d6
	bne.s .no_2
	move root_code,d7
	addq #1,d7				; codesize=bits+1
	moveq #1,d0
	lsl d7,d0
	move d0,codesize2
	move d6,d5
	addq #2,d5				; next code = bits2 + 2
	moveq #-1,d2			; old code	and old_token
	move d2,old_token
	bra.s .next_code
.no_2:
	move.l a4,a0			; first stack
	lea 4096(a0),a1		; last stack
	lea 4096(a1),a2		; code stack
	cmp d5,d0
	bne.s .no_3
	move.b old_token(pc),(a0)+
	move d2,d0
.no_3:
	cmp d6,d0
	bmi.s .end_of_while
	move.b 0(a1,d0.w),(a0)+
	add d0,d0
	move.w 0(a2,d0.w),d0
	bra.s .no_3
.end_of_while:
	move.b d0,old_token
	moveq #0,d1
	move gif_rows,d1
	add.l a4,d1
	add.l #16384,d1		; end of line
.do:
	move.b d0,(a3)+
	cmp a3,d1
	bne.s .no_4
	bsr gif_display_line
.no_4:
	cmp.l a0,a4				; stack empty?
	beq.s .end_of_do
	move.b -(a0),d0
	bra.s .do
.end_of_do:
	cmp #4096,d5
	bpl.s .end_of_for
	tst d2
	bmi.s .end_of_for
	add d5,d5
	move d2,0(a2,d5.w)
	lsr d5
	move.b old_token(pc),0(a1,d5.w)
	addq #1,d5
	cmp #12,d7
	bpl.s .end_of_for
	move codesize2,d0
	cmp d0,d5
	bmi.s .end_of_for
	addq #1,d7
	add d0,d0
	move d0,codesize2
.end_of_for:
	move d4,d2
	bra .next_code

gif_prepare_rect:
	moveq #0,d0
	move.b (a6)+,d0
	ror #8,d0
	move.b (a6)+,d0
	move.b (a6)+,d1
	ror #8,d1
	move.b (a6)+,d1
	ror #8,d1
	move d1,flx_start
	muls max_imagex,d1
	ror #8,d0
	add.l d0,d1			; offset from start of image in screen
	move.b (a6)+,d0
	ror #8,d0
	move.b (a6)+,d0
	ror #8,d0
	move d0,gif_rows
	neg d0
	move max_imagex,d2
	add d2,d0		; row inc
	add.l virtual,d1
	move.l d1,gif_image
	move.l d1,gif_image_sav	; when interlaced
	move d0,gif_inc
	move d2,gif_one_line
	move.b (a6)+,d0
	ror #8,d0
	move.b (a6)+,d0
	ror #8,d0
	move d0,flx_number
	muls d0,d2
	add.l d2,d1					; end of image
	move.l d1,gif_end_image
	clr gif_pass
	rts	

gif_display_line:
	movem.l d0-d2/a0-a1/a6,-(sp)
	move gif_rows,d0
	subq #1,d0
	lea 16384(a4),a3		; start of line
	move.l a3,a0
	move.l gif_image,a1
	move.l pal_adr,a6
	moveq #0,d1
.not_tc:
	tst.b gif_trans
	beq.s .nt0
	move.b gif_trans_index,d2
.nt1:
	move.b (a0)+,d1
	cmp.b d1,d2
	bne.s .nt2
	addq.l #1,a1
	dbf d0,.nt1
	bra.s .exit
.nt2:
	move.b 0(a6,d1.w),(a1)+
	dbf d0,.nt1
	bra.s .exit
.nt0:
	move.b (a0)+,d1
	move.b 0(a6,d1.w),(a1)+
	dbf d0,.nt0
.exit:	
	add gif_inc,a1
	tst.b gif_interlace
	beq.s .not_inter
	move gif_one_line,d0
	move gif_pass,d1
	and #$3,d1
	lsl #2,d1
	lea .gif_table,a0
	add d1,a0
	move d0,d1
	muls (a0)+,d0					; number of lines
	add.l d0,a1
	cmp.l gif_end_image,a1
	bmi.s .ok
	addq #1,gif_pass
	muls (a0),d1					; new start line
	add.l gif_image_sav,d1
	move.l d1,a1
	bra.s .ok
.not_inter:
	cmp.l gif_end_image,a1
	bmi.s .ok
	move.l gif_image_sav,a1		; end reached! start at bottom
.ok:
	move.l a1,gif_image
	movem.l (sp)+,d0-d2/a0-a1/a6
	rts
.gif_table: dc.w 7,4,7,2,3,1,1,0,0,0
	
gif_get_code:
	move.l a6,a0
	cmp.l a0,a5
	bne.s .lb0
	tst.b (a0)
	bne.s .normal
	move d6,d0
	addq #1,d0			; returns end_of_frame code
	rts
.normal:
	addq.l #1,a0
.lb0:
	move.b (a0)+,d0
	ror #8,d0
	cmp.l a0,a5
	bne.s .lb1
	addq.l #1,a0
.lb1:
	move.b (a0)+,d0
	ror #8,d0
	swap d0
	cmp.l a0,a5
	bne.s .lb2
	addq.l #1,a0
.lb2:
	move.b (a0),d0
	swap d0				; 3 bytes from input
	lsr.l d3,d0			; shifted!
	moveq #1,d1
	lsl d7,d1
	subq #1,d1			; mask
	and d1,d0			; correct code!
	add d7,d3			; bits read
.while:
	cmp #8,d3
	bmi.s .exit			; in the same byte, don't move
	subq #8,d3
	cmp.l a6,a5
	beq.s .lb3
	addq.l #1,a6
	cmp.l a6,a5
	bne.s .while
	moveq #0,d1
	move.b (a6)+,d1
	bne.s .not_end
.end:
	subq.l #1,a6
.not_end:
	lea 0(a6,d1.w),a5	; next bloc	
	cmp.l last_size,a5
	bmi.s .while
	move.l last_size,a5 ; end reached! limit!
	cmp.l a6,a5
	bpl.s .while			; good A6
	move.l a5,a6			; else limit!
	bra.s .while
.exit:
	rts
.lb3:
	moveq #0,d1
	move.b (a6)+,d1
	beq.s .end
	addq.l #1,a6
	subq #1,d1
	bra.s .not_end
	
	
gif_delay:
	tst.b _delay
	beq.s .end				; no delay wanted
	moveq #0,d0
	move.b 3(a6),d0
	ror #8,d0
	move.b 2(a6),d0
	add.l d0,d0
	add.l $4ba.w,d0		; end of time
.lb0:
	cmp.l $4ba.w,d0
	bpl.s .lb0				; not ended
.end:
	btst #0,1(a6)
	sne gif_trans
	move.b 4(a6),gif_trans_index
	rts

; d0 = flag bit #7 if there's a palette
; d0 and $7 +1 number of colors
; bit  #15 set if global palette
; bit  #31 set if load (else it is loaded ADR = a6, a6 updated!)

gif_palette:
	tst.b d0
	bmi.s .ok		; no palette!
	move.l #cvid_fix0,pal_adr	; no palette->global is back!
	rts
.ok:
	lea cvid_fix0,a4
	tst d0
	bmi.s .lb0
	lea cvid_fix0+2000,a4
.lb0:
	move.l a4,pal_adr
	lea 1000(a4),a4
	move.w #$0100,(a4)+
	clr.b (a4)+
	move.l d0,d7
	and #$7,d0
	addq #1,d0
	moveq #1,d1
	lsl d0,d1		; number of colors
	move.b d1,(a4)+
	tst.l d7
	bpl.s .loaded	; yet loaded!
	move d1,d0
	add d1,d1
	add d0,d1		; size of the palette
	ext.l d1
	pea (a4)
	move.l d1,-(sp)
	GEMDOS 63,12	; reads the palette
	bra.s .next
.loaded:
	move.b (a6)+,(a4)+
	move.b (a6)+,(a4)+
	move.b (a6)+,(a4)+
	subq #1,d1
	bne.s .loaded
.next:
	move.l a6,-(sp)
	tst.b smc_a
	bne.s .end
	move.l pal_adr,a6
	lea 1000(a6),a0
	jsr fli_color_256_256+6		; skips the a6 modify line
.end:
	move.l (sp)+,a6
	rts
	
gif_data_disk:
	rts

exit_menu:
	moveq #0,d0
	bra.s _menu
redraw_menu:
	moveq #1,d0
_menu:
	tst.b cmd_coord
	bne.s .lb1				; if coords, don't erase upper line
	tst.b acc
	bne.s .lb0				; no menu with an ACC
	move d0,mb_int
	GEM_AES menu_bar		; redraws the upper line
	bra.s .lb1
.lb0:
	move.l menu_buffer,a0
	move.l menu_len,d0
	move.l physbase,a1
	asr.l #2,d0
	subq.l #1,d0
.lb2:
	move.l (a0)+,(a1)+
	subq.l #1,d0
	bpl.s .lb2
.lb1:
	rts
	
save_menu:
	dc.w $a000
	moveq #1,d0
	add work_out,d0		; pixels per line
	muls (a0),d0			; bits per line
	asr.l #3,d0				; bytes per line
	moveq #2,d1
	add boxh,d1				; menu height
	muls d0,d1				; size of the menu
	move.l d1,menu_len
	bsr malloc
	move.l d0,menu_buffer
	move.l d0,a0
	move.l physbase,a1
	move.l menu_len,d0
	asr.l #2,d0
	subq.l #1,d0
.lb0:
	move.l (a1)+,(a0)+
	subq.l #1,d0
	bpl.s .lb0
	rts

count_normal_ste:
	lea count_tab,a2
	move d5,d6
	bmi.s quit_count					; positive number
	bra.s .dec
.other_line:
	cmp.l end_of_screen,a0
	bpl.s quit_count
	move.l a0,a3				; saves the current screen pointer
	move max_imagex,d5
.other_16:	
	moveq #15,d4
	sub #16,d5
	bpl.s .lb0
	add d5,d4
	moveq #0,d5
.lb0:
	moveq #0,d0
	move.b (a1)+,d0
	add d0,d0
	add d0,d0
	addq.l #1,0(a2,d0.w)
	dbf d4,.lb0
	addq.l #8,a0
	tst d5
	bne .other_16
	lea 160(a3),a0			; next line	
.dec:
	dbf d6,.other_line
quit_count:
	moveq #0,d6
	move #255,d0
.count:
	tst.l (a2)+
	beq.s .not_used
	addq #1,d6
.not_used:
	dbf d0,.count
	lea count_stat,a1
	lea 13(a1),a0
.plus:
	move.b (a0),d0
	addq.b #1,d0
	cmp.b #'9'+1,d0
	bmi.s .good
	move.b #'0',(a0)
	subq.l #1,a0
	bra.s .plus
.good:
	move.b d0,(a0)
	lea 33(a1),a0
	moveq #2,d1
.three_digits:
	divs #10,d6
	swap d6
	add.b #'0',d6
	move.b d6,-(a0)
	clr d6
	swap d6
	dbf d1,.three_digits
	pea (a1)
	GEMDOS 9,6	
	rts	
	
display_ste_normal:
	move flx_hide,d2		; number of hidden lines
	move flx_number,d5
	move.l image,a0
	move flx_start,d0
	move d0,d6
	sub d2,d0
	bpl.s .ok
	add d0,d5					; sub the extra lines
	moveq #0,d0					; no offset
	move d2,d6
.ok:
	muls #160,d0
	add.l d0,a0					; start into screen
	move.l virtual,a1
	move max_imagex,d0
	muls d0,d6
	add.l d6,a1					; start into buffer
	moveq #0,d6
	tst.b count
	bne count_normal_ste
	and #$f,d0	
	beq .douglas
	lea start_routines,a2
	move d5,d6
	bpl .dec						; positive number
.quit:
	rts							; else all are hidden!
.other_line:
	cmp.l end_of_screen,a0
	bpl.s .quit
	swap d6
	move.l a0,a3				; saves the current screen pointer
	move max_imagex,d5
.other_16:	
	moveq #0,d0
	moveq #0,d1
	moveq #0,d2
	moveq #0,d3
	moveq #16,d4
	sub d4,d5
	bpl.s .lb0
	neg d5
	asl #3,d5
	lea .lb0(pc,d5.w),a4	
	moveq #0,d5
	jmp (a4)
.lb0:
	rept 16
		subq #1,d4
		move.b (a1)+,d6
		jsr 0(a2,d6.w)
	endr
	movem.w d0-d3,(a0)
	addq.l #8,a0
	tst d5
	bne .other_16
	lea 160(a3),a0			; next line	
	swap d6
.dec:
	dbf d6,.other_line
	rts	
.douglas:
	subq #1,d5
	bmi .quit
.doug_line:
	cmp.l end_of_screen,a0
	bpl .quit
	move max_imagex,d6
	move.l a0,a3
	lsr #4,d6
	bra .doug_dec	
.doug_16:
	movem.l (a1)+,d1-d4
	add.l d1,d1
	add.l d2,d2
	add.l d3,d3
	add.l d4,d4
	move.l #$00ff00ff,d0
	splice.l d1,d3,8
	splice.l d2,d4,8
	lsr.l #4,d2
	lsr.l #4,d4
	or.l d2,d1
	or.l d4,d3
	move d1,d2
	move d3,d4
	swap d1
	swap d3
	move #$3333,d0
	splice.w d1,d2,2
	splice.w d3,d4,2
	move #$5555,d0
	splice.w d1,d3,1
	splice.w d2,d4,1
	move d4,(a0)+
	move d2,(a0)+
	move d3,(a0)+
	move d1,(a0)+
.doug_dec:
	dbf d6,.doug_16
	lea 160(a3),a0	
	dbf d5,.doug_line
	rts
	

count_ste_half:
	lea count_tab,a2
	move d5,d6
	bmi quit_count
	bra .dec						; positive number
.other_line:
	btst #0,d6
	bne.s .even_line
	add max_imagex,a1
	bra .dec
.even_line:
	cmp.l end_of_screen,a0
	bpl quit_count
	move.l a0,a3				; saves the current screen pointer
	move max_imagex,d5
.other_16:	
	moveq #15,d4
	sub #32,d5
	bpl.s .lb0
	asr #1,d5
	add d5,d4
	bpl.s .lb1
	moveq #0,d4
.lb1:
	moveq #0,d5
.lb0:
	moveq #0,d0
	move.b (a1),d0
	add d0,d0
	add d0,d0
	addq.l #1,0(a2,d0.w)
	addq.l #2,a1
	dbf d4,.lb0
	addq.l #8,a0
	tst d5
	bne .other_16
	lea 160(a3),a0			; next line	
	btst #0,max_imagex+1
	beq.s .dec
	subq.l #1,a1
.dec:
	dbf d6,.other_line
	bra quit_count
	
display_ste_half:
	move flx_hide,d2		; number of hidden lines
	add d2,d2
	move flx_number,d5
	move.l image,a0
	move flx_start,d0
	move d0,d6
	sub d2,d0
	bpl.s .ok
	add d0,d5					; sub the extra lines
	moveq #0,d0					; no offset
	move d2,d6
.ok:
	asr #1,d0
	muls #160,d0
	add.l d0,a0					; start into screen
	move.l virtual,a1
	move max_imagex,d0
	muls d0,d6
	add.l d6,a1					; start into buffer
	moveq #0,d6
	tst.b count
	bne count_ste_half
	and #$1f,d0
	beq .douglas
	lea start_routines,a2
	move d5,d6
	bpl .dec						; positive number
.quit:
	rts							; else all are hidden!
.other_line:
	btst #0,d6
	bne.s .even_line
	add max_imagex,a1
	bra .dec
.even_line:
	cmp.l end_of_screen,a0
	bpl.s .quit
	swap d6
	move.l a0,a3				; saves the current screen pointer
	move max_imagex,d5
.other_16:	
	moveq #0,d0
	moveq #0,d1
	moveq #0,d2
	moveq #0,d3
	moveq #16,d4
	sub d4,d5
	sub d4,d5			; 32 pixel at a time
	bpl.s .lb0
	neg d5
	bclr #0,d5
	move d5,d6
	asl #2,d6
	add d6,d5
	lea .lb0(pc,d5.w),a4	
	moveq #0,d5
	jmp (a4)
.lb0:
	rept 16
		subq #1,d4
		move.b (a1)+,d6
		jsr 0(a2,d6.w)
		addq.l #1,a1
	endr
	movem.w d0-d3,(a0)
	addq.l #8,a0
	tst d5
	bne .other_16
	lea 160(a3),a0			; next line	
	swap d6
	btst #0,max_imagex+1
	beq.s .dec
	subq.l #1,a1
.dec:
	dbf d6,.other_line
	rts		
.douglas:
	subq #1,d5
	bmi .quit
.doug_line:
	cmp.l end_of_screen,a0
	bpl .quit
	btst #0,d5
	beq.s .doug_ok
	add max_imagex,a1	
	dbf d5,.doug_line
	rts	
.doug_ok:
	move max_imagex,d6
	move.l a0,a3
	lsr #5,d6
	bra .doug_dec	
.doug_16:
	get4on8 d1
	get4on8 d2
	get4on8 d3
	get4on8 d4
	add.l d1,d1
	add.l d2,d2
	add.l d3,d3
	add.l d4,d4
	move.l #$00ff00ff,d0
	splice.l d1,d3,8
	splice.l d2,d4,8
	lsr.l #4,d2
	lsr.l #4,d4
	or.l d2,d1
	or.l d4,d3
	move d1,d2
	move d3,d4
	swap d1
	swap d3
	move #$3333,d0
	splice.w d1,d2,2
	splice.w d3,d4,2
	move #$5555,d0
	splice.w d1,d3,1
	splice.w d2,d4,1
	move d4,(a0)+
	move d2,(a0)+
	move d3,(a0)+
	move d1,(a0)+
.doug_dec:
	dbf d6,.doug_16
	lea 160(a3),a0	
	dbf d5,.doug_line
	rts
	
display_mono:
	lea bayer(pc),a4		; matrix
	move flx_hide,d2		; number of hidden lines
	move flx_number,d5
	move.l image,a0
	move flx_start,d0
	move d0,d6
	sub d2,d0
	bpl.s .ok
	add d0,d5					; sub the extra lines
	moveq #0,d0					; no offset
	move d2,d6
.ok:
	move d6,d4					; start line
	lsl #3,d4					; into matrix
	muls #80,d0
	add.l d0,a0					; start into screen
	move.l virtual,a1
	move max_imagex,d0
	muls d0,d6
	add.l d6,a1					; start into buffer
	moveq #0,d6
	move d5,d6
	bpl .dec						; positive number
.quit:
	rts							; else all are hidden!
.other_line:
	cmp.l end_of_screen,a0
	bpl.s .quit
	move.l a0,a3				; saves the current screen pointer
	move max_imagex,d5
	and.w #$3F,d4
	lea 0(a4,d4.w),a2			; line into bayer
	addq #8,d4					; next line
	bra.s .init
.other_16:	
	cmp.b (a2)+,(a1)+
	bls.s .black
	bclr d1,d0
.black:
	dbf d1,.lb2
	move d0,(a0)+
	sub #16,a2
.init:
	moveq #-1,d0
	moveq #15,d1
	dbf d5,.other_16
	lea 80(a3),a0
	dbf d6,.other_line
	rts
.lb2:
	dbf d5,.other_16
	move d0,(a0)
	lea 80(a3),a0			; next line	
.dec:
	dbf d6,.other_line
	rts	

bayer: dc.b 0,64,16,80,4,68,20,82
		dc.b 96,32,112,48,100,36,116,52
		dc.b 24,88,8,7,28,92,12,76
		dc.b 120,56,104,40,124,60,108,44
		dc.b 6,70,22,86,2,66,18,82
		dc.b 102,38,118,54,98,34,114,50
		dc.b 30,94,14,78,26,90,10,74
		dc.b 126,62,110,46,122,58,106,42
		dc.b 0,64,16,80,4,68,20,82

display_mono_double:
	lea bayer2(pc),a4		; matrix
	move flx_hide,d2		; number of hidden lines
	move flx_number,d5
	move.l image,a0
	move flx_start,d0
	move d0,d6
	sub d2,d0
	bpl.s .ok
	add d0,d5					; sub the extra lines
	moveq #0,d0					; no offset
	move d2,d6
.ok:
	move d6,d4					; start line
	lsl #5,d4					; into matrix
	muls #160,d0
	add.l d0,a0					; start into screen
	move.l virtual,a1
	move max_imagex,d0
	muls d0,d6
	add.l d6,a1					; start into buffer
	moveq #0,d7					; 0 and max_x alternatively
	moveq #0,d6
	move d5,d6
	add d6,d6
	bpl .dec						; positive number
.quit:
	rts							; else all are hidden!
.other_line:
	cmp.l end_of_screen,a0
	bpl.s .quit
	sub.w d7,a1					; to repeat twice a line
	move.l a0,a3				; saves the current screen pointer
	move max_imagex,d5
	move d5,d0
	sub d7,d0
	move d0,d7					; 0 or max_x alternatively
	and.w #$7F,d4
	lea 0(a4,d4.w),a2			; line into bayer
	add.w #16,d4					; next line
	bra.s .init
.other_16:	
	move.b (a1)+,d3
	cmp.b (a2)+,d3
	bls.s .black
	bclr d1,d0
.black:
	subq  #1,d1
	cmp.b (a2)+,d3
	bls.s .black2
	bclr d1,d0
.black2:
	dbf d1,.lb2
	move.l d0,(a0)+
	sub #32,a2
.init:
	moveq #-1,d0
	moveq #31,d1
	dbf d5,.other_16
	lea 80(a3),a0
	dbf d6,.other_line
	rts
.lb2:
	dbf d5,.other_16
	move.l d0,(a0)
	lea 80(a3),a0			; next line	
.dec:
	dbf d6,.other_line
	rts			

bayer2: dc.b 0,64,16,80,4,68,20,82,0,64,16,80,4,68,20,82
		dc.b 96,32,112,48,100,36,116,52,96,32,112,48,100,36,116,52
		dc.b 24,88,8,7,28,92,12,76,24,88,8,7,28,92,12,76
		dc.b 120,56,104,40,124,60,108,44,120,56,104,40,124,60,108,44
		dc.b 6,70,22,86,2,66,18,82,6,70,22,86,2,66,18,82
		dc.b 102,38,118,54,98,34,114,50,102,38,118,54,98,34,114,50
		dc.b 30,94,14,78,26,90,10,74,30,94,14,78,26,90,10,74
		dc.b 126,62,110,46,122,58,106,42,126,62,110,46,122,58,106,42
		dc.b 0,64,16,80,4,68,20,82,0,64,16,80,4,68,20,82

flm_header:
	dc.l 0		; file size
	dc.l 0		; extra datas
	dc.l 0		; max f size
	dc.l 0		; number of frames
	dc.b "MP_STE (AVI/MOV to FLM+sound)",0,0,0
	dc.l $00010000
	dc.w 320,200	; width and height
	dc.w 4		; planes
	dc.b 1,0,0,0,0,8,0,0	; unknown
	dc.w 16		; number of colors
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
flm_snd:
	dc.b 'dsnd'
	dc.l 0
	dc.b 0		; channels
	dc.b 0		; freq
	dc.l 0		; sound size

flm_header_mono:
	dc.l 0		; file size
	dc.l 0		; extra datas
	dc.l 0		; max f size
	dc.l 0		; number of frames
	dc.b "MP_STE (AVI/MOV to FLM+sound)",0,0,0
	dc.l $00010000
	dc.w 640,400	; width and height
	dc.w 1		; planes
	dc.b 1,2,0,2,0,0,0,0	; unknown
	dc.w 2		; number of colors
	dc.w $FFF,0
flm_snd_mono:
	dc.b 'dsnd'
	dc.l 0
	dc.b 0		; channels
	dc.b 0		; freq
	dc.l 0		; sound size	
	
flm_off: dc.l 0
flm_hsize: dc.l 0

init_flm_create:
	sf is_rep		; no loop with creation
	lea flm_off(pc),a0
	clr.l (a0)
	move.l #flm_snd-flm_header,d0
	move.l d0,4(a0)
	tst.b is_mono
	beq.s .zero			; no offset in color
	move.l #flm_header_mono-flm_header,(a0)+
	move.l #flm_snd_mono-flm_header_mono,(a0)
.zero:
	if REG=0
		move.l tree_sav,a0
		bclr #0,275(a0)
	endif
	clr mf_int
	GEM_AES graf_mouse				; the arrow
	GEM_VDI show_mouse	
	move.l #fs_addrin_tga,fileselect+16	; new addrin
	GEM_AES fileselect
	move.l #fs_addrin,fileselect+16		; restores it
	move.l intout,-(sp)
	GEM_VDI hide_mouse
	tst (sp)+						; 0 if error
	beq.s .quit
	tst (sp)+						; 0 if Abort, other if OK
   bne.s .ok
.quit:
	sf create_flm
	rts
.ok:
	lea tga_path,a0
	lea tga_full,a1
	move.l a1,a2		; last '\'
.lb0:
	move.b (a0)+,d0
	move.b d0,(a1)+
	beq.s .lb2
	cmp.b #'\',d0
	bne.s .lb0
	move.l a1,a2
	bra.s .lb0
.lb2:
	lea tga_file,a1
.lb1:
	move.b (a1)+,(a2)+
	bne.s .lb1
	move.l physbase,_flm_phys
_create_degas:
	move.l #32000,d1		; point d'entree
	bsr malloc
	move.l d0,flm_screen
	move.l d0,a0
	moveq #0,d0
	move #1999,d1
.clear:
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	dbf d1,.clear
	move.l #64000,d1
	bsr malloc
	move.l d0,flm_frame
	move.l d0,a0
	clr.l (a0)			; size of frame (if 0: first frame!)
	clr -(sp)
	pea out_file
	tst.b slide_degas
	bne.s .ok	
	move.l #tga_full,(sp)
.ok:
	GEMDOS 60,8
	tst.l d0
	bgt .end
	lea cant_create,a0
	bra ooops
.end:
	move d0,mov_h2
	lea flm_header(pc),a0
	add.l flm_off(pc),a0	; to the right header
	clr.l 4(a0)				; extra datas reset
	clr.l 8(a0)				; max_fsize reset
	clr.l 12(a0)			; number of frames reset
	pea (a0)
	move.l flm_hsize,-(sp)
	move d0,-(sp)
	GEMDOS 64,12	; writes the header (not filled)
	st create_flm
	tst.b slide_degas
	beq .out
	lea flm_time,a0
	move.l _delay,(a0)	; start time
	move.l (a0),flm_time_inc	; will add _delay each time
	move.l a0,flm_time_ptr		; memore position
	clr.l flm_ptr_inc		; same memory position
	tst.b bad_sound
	bne .out
	pea sound_text
	GEMDOS 9,6
	bsr flm_snd_ext
	clr -(sp)
	pea sound_file
	GEMDOS 61,8
	move.l d0,d3
	clr -(sp)
	move d3,-(sp)
	move.l sound_seek,-(sp)
	GEMDOS 66,10		; skips header!
	move.l snd_size,d6		; total size
	lea flm_snd,a3
	move.l flm_frame,a6
	add.w #256,a6				; don't overwrite frame header
.sound_loop:
	move.l #32768,d5
	cmp.l d5,d6
	bpl.s .ok_size
	move.l d6,d5
.ok_size:
	sub.l d5,d6
	pea (a6)
	move.l d5,-(sp)
	move d3,-(sp)
	GEMDOS 63,12				; reads 32K
	bsr sign_dma_sound
	add.l d5,10(a3)			; snd size
	addq.l #1,d5
	bclr #0,d5					; even
	pea (a6)
	move.l d5,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12				; writes the same
	tst.l d6
	bne.s .sound_loop
	moveq #14,d0
	add.l 10(a3),d0			; snd + extension
	addq.l #1,d0
	bclr #0,d0					; even
	move.l d0,flm_header+4	; size of extra infos	
	move d3,-(sp)
	GEMDOS 62,4					; fclose
.out:
	rts

sign_dma_sound:
	cmp.l #'twos',s_signe
	beq.s .end
	move.l a6,a0
	move.l d5,d0
	moveq #-128,d2
.loop:
	add.b d2,(a0)+
	subq.l #1,d0
	bne.s .loop
.end:
	rts
	

compress_flm:
	move.l cf_display,a0
	jsr (a0)			; displays the original frame
	move.l _flm_phys,a0
	move.l flm_screen,a1
	move #1999,d0
.new_words:
	rept 4
		move.l (a0)+,d1
		eor.l d1,(a1)+		; 0 if unchanged
	endr
	dbf d0,.new_words
	move.l a1,a3			; end of flm-screen
	move.l flm_frame,a0
	move.l (a0)+,d0			; size of previous frame
	move.l d0,(a0)+
	bne.s .lb2
	tst.b slide_degas
	bne.s .lb2					; colors treated with '.getp'
	tst.b is_mono
	bne.s .lb2					; no palette
	lea xbios_pal_sav,a2		; palette
	lea flm_header+68(pc),a1		; into header
	moveq #15,d0
.lb1:
	move.w (a2)+,(a1)+		; one color
	dbf d0,.lb1
.lb2:
	moveq #8,d0
	move.l d0,(a0)+			; extra datas
	move.l #'time',(a0)+		; ID for time
	move.l degas_div,a1		; if degas_div<>0: FLM synchro with sound
	cmp.l #0,a1
	beq.s .other
	move.l degas_q1,d0
	add.l degas_q,d0
	move.l degas_r1,d1
	add.l degas_r,d1
	cmp.l a1,d1
	bmi.s .glump
	sub.l a1,d1
	addq.l #1,d0
.glump:
	move.l d0,degas_q1
	move.l d1,degas_r1
	move.l d0,(a0)+
	bra.s .next
.other:
	move.l flm_time_ptr,a1	; where to find the time
	add.l flm_ptr_inc,a1		; 12 for AVI, 4 for MOV, 0 for FLI or FLM
	bclr #7,(a1)				; for some key frames...
	move.l (a1),(a0)+			; time in 1/200 of second
	move.l flm_time_inc,d0
	add.l d0,(a1)				; updates the time (usefull with FLI only)
	move.l a1,flm_time_ptr	; updates
.next:
	lea -32000(a3),a1			; flm_screen
.first_offset:
	cmp.l a3,a1
	bpl .nop_frame
	tst (a1)+
	beq.s .first_offset
	subq.l #2,a1
	move.l a1,d0
	move.l flm_screen,d1
	sub.l d1,d0					; first offset
	move.l d0,(a0)+
	addq.l #4,a0				; skips offset to second block				
	lea 20000(a0),a2			; second bloc
.no_nul:
	move.l a2,a4				; saves the current position
.loop:
	cmp.l a3,a1
	bpl.s .end_on_NE
	move (a1)+,(a2)+			; into the datas
	bne.s .loop					; not zero, go on!
	subq.l #2,a1
	subq.l #2,a2
.end_on_NE:
	move.l a2,d0
	sub.l a4,d0
	asr.l #1,d0					; number of words to change
.store_codes:
	cmp #257,d0
	bmi.s .stored
	sub #256,d0
	clr.b (a0)+					; no offset
	move.b #$ff,(a0)+			; 128 words to store
	bra.s .store_codes
.stored:
	tst d0
	beq.s .mul_256
	subq #1,d0
	clr.b (a0)+
	move.b d0,(a0)+
.mul_256:
	move.l a1,a4				; saves current position
.loop2:
	cmp.l a3,a1
	bpl.s .end_on_EQ
	tst (a1)+
	beq.s .loop2
	subq.l #2,a1
	move.l a1,d0
	sub.l a4,d0
	asr.l #1,d0					; number of words to skip
	cmp #128,d0
	bpl.s .long_zero
	move.b d0,-2(a0)
	bra.s .no_nul
.long_zero:
	move.b #$7f,-2(a0)
	sub.l #127,d0
	add.l d0,d0
	move.b #$FF,(a0)+
	move.l d0,(a2)+
	bra.s .no_nul
.end_on_EQ:
	move.b #$FD,(a0)+			; end of frame
	move.l flm_frame,a0
	add #28,a0					; start of the codes
	move.l a0,a1
	moveq #-1,d0				; current size
	moveq #0,d1					; for bytes being read
	moveq #0,d2
.reduce_codes:
	move.b (a1)+,d1
	cmp.b #$FD,d1
	beq.s .end_of_reduc
	cmp.b #$FF,d1
	beq.s .one_byte
	move.b (a1)+,d2
	cmp d2,d0
	beq.s .try_it
	move d2,d0					; new size
.no:
	move.b d1,(a0)+
	move.b d2,(a0)+
	bra.s .reduce_codes
.try_it:
	cmp #$7d,d1
	bpl.s .no					; reserved codes (7d, 7e, 7f)
	bset #7,d1
.one_byte:
	move.b d1,(a0)+
	bra.s .reduce_codes
.end_of_reduc:	
	move.b d1,(a0)+			; last code
	move.l a0,d0
	addq.l #1,d0
	bclr #0,d0					; word aligned
	move.l d0,a0
	move.l flm_frame,a1
	sub.l a1,d0					; offset for second bloc		
	move.l d0,24(a1)			; stored into header
	lea 20028(a1),a3			; start of data zone
.glue_frame:
	move.w (a3)+,(a0)+
	cmp.l a2,a3
	bmi.s .glue_frame
	sub.l a1,a0					; size of this frame
	move.l a0,d0
	bra.s .save_frame
.nop_frame:
	moveq #28,d0
.save_frame:
	lea flm_header+12(pc),a0
	add.l flm_off(pc),a0
	addq.l #1,(a0)	; number of frames strored
	move.l flm_frame,a0
	addq.l #1,d0
	bclr #0,d0
	move.l d0,(a0)
	cmp.l #28,d0
	bne.s .lb3
	move.l #-1,20(a0)
.lb3:
	lea flm_header+8(pc),a1
	add.l flm_off(pc),a1
	cmp.l (a1),d0				; compared to max_fsize
	bmi.s .lb0
	move.l d0,(a1)
.lb0:
	pea (a0)
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12				; writes that frame
	move.l _flm_phys,a0
	move.l flm_screen,a1
	move #1999,d0
.update:
	rept 4
		move.l (a0)+,(a1)+
	endr
	dbf d0,.update
	rts	
	
complete_flm_file:
	move #1,-(sp)
	move mov_h2,-(sp)
	clr.l -(sp)
	GEMDOS 66,10
	lea flm_header(pc),a3
	add.l flm_off(pc),a3
	move.l d0,(a3)			; size of the file
	clr -(sp)
	move mov_h2,-(sp)
	clr.l -(sp)
	GEMDOS 66,10			; start of file
	move.l flm_hsize(pc),d0
	tst.l 4(a3)				; no snd ext?
	beq.s .no_ext
	add.l #14,d0			; if extension, 14 bytes more
.no_ext:
	pea (a3)
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12			; write again the header (completed)
	move #2,-(sp)
	move mov_h2,-(sp)
	clr.l -(sp)
	GEMDOS 66,10			; back to the end of the file
	rts

	if REG=1

init_square_table:
	move.l a6,a0				; negative part
	lea 1022(a6),a1			; positive part
	move #65025,d0			; first square
	move #509,d1			; first offset
.lb0:
	move d0,-(a1)
	move d0,(a0)+
	sub d1,d0				; next square
	subq #2,d1				; next offset
	bpl.s .lb0
	rts
	
; d2 = color
; return: d0.w closest color, d1.l distance

; uses a0-a2, d0-d7

best_color:
	lea 1022(a6),a0		; rgb
	moveq #-1,d1
	lsr.l d1					; big distance
	move.l d1,a2
	lea 510(a6),a1			; square table (point a zero)
	move d2,d0
	add d0,d0
	add d2,d0
	add d0,a0				; our color
	moveq #0,d5
	moveq #0,d6
	moveq #0,d7
	move.b (a0)+,d5
	move.b (a0)+,d6
	move.b (a0)+,d7		; rgb
	moveq #0,d0				; closest
.lb0:
	addq #1,d2
	cmp max_color,d2		; usually 256
	bpl.s .end
	moveq #0,d1
	moveq #0,d3
	moveq #0,d4
	move.b (a0)+,d3
	sub d5,d3
	add d3,d3
	move 0(a1,d3.w),d1
	moveq #0,d3
	move.b (a0)+,d3
	sub d6,d3
	add d3,d3
	move 0(a1,d3.w),d4
	add.l d4,d1
	moveq #0,d3
	move.b (a0)+,d3
	sub d7,d3
	add d3,d3
	move 0(a1,d3.w),d4
	add.l d4,d1
	beq.s .lb0			; if 0, skip
	cmp.l a2,d1		
	bpl.s .lb0			; not closer
	move.l d1,a2
	move d2,d0
	bra.s .lb0
.end:
	move.l a2,d1
	rts

; a0 the fli/c palette
; d7 shift (0 for flc, 2 for fli)

init_palette:
	lea 1022(a6),a1
	move (a0)+,d0				; number of blocs
	ror #8,d0
	bra.s .b_loop
.blocs:
	moveq #0,d1
	move.b (a0)+,d1			; number of colors to skip
	bra.s .clear_skipped
.clear:
	clr.b (a1)+
	clr.b (a1)+
	clr.b (a1)+
.clear_skipped:
	dbf d1,.clear
	moveq #0,d1	
	move.b (a0)+,d1
	bne.s .col_loop
	move #255,d1				; if d1=0 it means 256 colors
.color:
	rept 3
	move.b (a0)+,d2
	lsl.b d7,d2
	move.b d2,(a1)+
	endr
.col_loop:
	dbf d1,.color
.b_loop:
	dbf d0,.blocs	
	lea count_tab,a2
	move.l a2,a0			; to find the first used color
	lea 1022(a6),a1		; to get this color
.find_first
	tst.l (a0)+
	bne.s .found
	addq.l #3,a1
	bra.s .find_first
.found:
	move.b (a1)+,d1		; a color that's used
	move.b (a1)+,d2
	move.b (a1)+,d3	
	lea 1022(a6),a1
	move #255,d0
.replace_unused:
	tst.l (a2)+
	bne.s .used
	move.b d1,(a1)+		; if unused, replaced with the used one
	move.b d2,(a1)+
	move.b d3,(a1)+
	dbf d0,.replace_unused
	rts
.used:
	addq.l #3,a1			; if used, keep it
	dbf d0,.replace_unused
	rts
		
reduce_pal:
	tst.b is_rep
	beq.s .no_pb
	bclr #0,is_rep
	bne.s .no_pb
	rts
.no_pb:
	move.l a0,a5				; saves the palette adr
	move.l #4350,d1
	bsr malloc
	move.l d0,a6				; base of the zone
	move.l a5,a0
	bsr init_palette
	bsr init_square_table
	lea 1790(a6),a0			; count
	lea 2814(a6),a1			; end of same
	move #255,d0
	moveq #1,d1
.init_count:
	move d1,(a0)+
	move d0,-(a1)
	dbf d0,.init_count
	move max_color,d0
	move d0,n_color
	subq #1,d0					; low index
	move d0,low_index
	move d0,high_index
	move d0,end_loop
	lea 1022(a6),a0			; palette
	move d0,d2
	add d2,d2
	add d0,d2
	lea 0(a0,d2),a1
	moveq #0,d2
	moveq #0,d3
	move.b (a1)+,d2
	move.b (a1)+,d3
	add d3,d2
	move.b (a1)+,d2
	add d3,d2					; low intensity
	move d2,d3					; high intensity
	lea 2302(a6),a2			; same
	moveq #-1,d0					; a
.loop1:
	addq #1,d0
	cmp end_loop,d0
	bpl.s .end_loop
	moveq #0,d5
	moveq #0,d6
	moveq #0,d7
	move.b (a0)+,d5
	move.b (a0)+,d6
	move.b (a0)+,d7			; rgb
	cmp (a2)+,d0				; same(a)=a?
	bne.s .loop1	
	move d5,d1
	add d6,d1
	add d7,d1					; current intensity
	cmp d2,d1
	bpl.s .not_low
	move d1,d2					; new low
	move d0,low_index
.not_low:
	cmp d1,d3
	bpl.s .not_high
	move d1,d3					; new high
	move d0,high_index
.not_high:
	move d0,d1					; b (a+1 to max col)
	move.l a0,a1				; palette
	move.l a2,a3				; same
.loop2:
	addq #1,d1
	cmp max_color,d1
	bpl.s .loop1
	cmp.b (a1),d5
	bne.s .not_same
	cmp.b 1(a1),d6
	bne.s .not_same
	cmp.b 2(a1),d7
	bne.s .not_same
	move d0,(a3)+
	subq #1,n_color
	addq.l #3,a1
	bra.s .loop2
.not_same:
	addq.l #2,a3
	addq.l #3,a1
	bra.s .loop2
.end_loop:
	move n_color,d0
	cmp n_wanted,d0		; usually 16
	bls .reduced
	lea 2814(a6),a3		; dist (LONGS)
	lea 3838(a6),a4		; best index
	moveq #-1,d2
.build_best:
	addq #1,d2
	cmp end_loop,d2
	bpl.s .while
	move d2,-(sp)
	bsr best_color
	move (sp)+,d2
	move d0,(a4)+
	move.l d1,(a3)+
	bra.s .build_best
.while:
	move n_color,d0
	cmp n_wanted,d0
	bls .reduced
	subq #1,n_color
	lea 2302(a6),a0		; same
	lea 2814(a6),a1		; dist
	moveq #-1,d0
	moveq #-1,d1
	lsr.l d1
.find_closest:
	addq #1,d0
	cmp end_loop,d0
	bpl.s .found
	move.l (a1)+,d2
	cmp (a0)+,d0
	bne.s .find_closest
	cmp.l d1,d2
	bpl.s .find_closest
	move.l d2,d1
	move d0,d3
	bra.s .find_closest
.found:
	move d3,d0
	add d0,d0
	add d3,d0
	lea 1022(a6),a3		; palette
	move.l a3,a2
	add d0,a3				; on the first color
	move d3,d0
	add d0,d0
	lea 3838(a6),a0
	move 0(a0,d0.w),d0	; best (color1)
	add d0,d0
	lea 2302(a6),a0
	move 0(a0,d0.w),d2	; color2
	move d2,d0
	add d0,d0
	add d2,d0
	add d0,a2				; on the second color
	lea 1790(a6),a0		; count
	cmp low_index,d3
	beq.s .first
	cmp high_index,d3
	bne.s .other
.first:
	move.b (a3)+,d5
	move.b (a3)+,d6
	move.b (a3)+,d7		; new rgb
	move d3,d0
.common:
	add d0,d0
	move 0(a0,d0.w),d0
	addq #1,d0				; new count
	bra.s .updates
.other:
	cmp low_index,d2
	beq.s .second
	cmp high_index,d2
	bne.s .average
.second:	move.b (a2)+,d5
	move.b (a2)+,d6
	move.b (a2)+,d7
	move d2,d0
	bra.s .common
.average:
	move d3,d0
	add d0,d0
	move 0(a0,d0.w),d1	; first coeff
	move d2,d0
	add d0,d0
	move 0(a0,d0.w),d4	; second coeff
	move d1,d0
	add d4,d0				; new count
	moveq #0,d5
	move.b (a3)+,d5
	muls d1,d5
	moveq #0,d6
	move.b (a2)+,d6
	muls d4,d6
	add.l d6,d5
	divs d0,d5				; new red
	moveq #0,d6
	move.b (a3)+,d6
	muls d1,d6
	moveq #0,d7
	move.b (a2)+,d7
	muls d4,d7
	add.l d7,d6
	divs d0,d6				; new green
	move d5,-(sp)
	moveq #0,d5
	move.b (a3)+,d5
	muls d1,d5
	moveq #0,d7
	move.b (a2)+,d7
	muls d4,d7
	add.l d5,d7
	divs d0,d7				; new blue
	move (sp)+,d5
.updates:
	lea 2302(a6),a0		; same
	lea 1022(a6),a1		; palette
	lea 1790(a6),a2		; count
	moveq #-1,d1
.update_sames:
	addq #1,d1
	cmp max_color,d1
	bpl.s .next
	move (a0),d4
	cmp d4,d3
	beq.s .change
	cmp d4,d2
	beq.s .change
	addq.l #2,a0
	addq.l #3,a1
	addq.l #2,a2
	bra.s .update_sames
.change:
	move d3,(a0)+
	move.b d5,(a1)+
	move.b d6,(a1)+
	move.b d7,(a1)+
	move d0,(a2)+
	bra.s .update_sames
.next:
	lea 3838(a6),a3	; best
	lea 2302(a6),a4	; same
	move.l a4,a5		; base of same to be kept
	lea 2814(a6),a2	; dists
	moveq #-1,d0
.update_dists:
	addq #1,d0
	cmp end_loop,d0
	bpl .while
	move (a3),d1		; best(a)
	cmp d3,d1
	beq.s .new_dist
	cmp (a4),d3
	beq.s .new_dist
	add d1,d1
	cmp 0(a5,d1),d3	; same(best(a))
	beq.s .new_dist
	addq.l #2,a3
	addq.l #2,a4
	addq.l #4,a2
	bra.s .update_dists
.new_dist:
	move d0,d2
	movem.l d0/d3/a2,-(sp)
	bsr best_color
	move d0,(a3)+		; new best
	addq.l #2,a4
	movem.l (sp)+,d0/d3/a2
	move.l d1,(a2)+	; new dist
	bra.s .update_dists
.reduced:
	lea 2302(a6),a0			; same
	lea 1022(a6),a2			; the palette
	lea cvid_fix1+12480,a3	; to store the RGB palette
	moveq #0,d0
	moveq #0,d2
.red_1:
	cmp (a0),d0					; new color?
	bne.s .red_2
	st (a0)+						; mark as new
	move.b d2,(a0)+			; the offset
	addq #8,d2					; other offset
	move.b (a2)+,(a3)+
	move.b (a2)+,(a3)+
	move.b (a2)+,(a3)+		; copies the color
	bra.s .red_3
.red_2:
	addq.l #3,a2				; skip color
	addq.l #2,a0				; skip index
.red_3:
	addq #1,d0
	cmp max_color,d0
	bmi.s .red_1
	lea 2302(a6),a0
	move.l a0,a2				; keeps the base
	lea colors256,a1
	moveq #0,d0
.red_4:
	move (a0)+,d1
	bmi.s .red_5				; a new color
	add d1,d1
	move 0(a2,d1.w),d1		; else, indirect
.red_5:
	move.b d1,(a1)+			; the offset
	addq #1,d0
	cmp max_color,d0
	bmi.s .red_4
	move.l a6,a2
	bsr mfree					; frees the zone
	lea cvid_fix1+12480,a0	; the RGB
	jmp bios_palette			; fixes the hardware palette	

max_color: dc.w 256
n_wanted: dc.w 16

	endif

vmas_read_header:
	SEEK #0,0
	lea cvid_fix0,a3
	pea (a3)
	moveq #10,d3
	move.l d3,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d0,d3
	beq.s .ok
.bug:
	moveq #1,d0
	rts
.ok:
	move.l #'VMAS',d0
	cmp.l (a3)+,d0
	bne.s .bug	
	cmp.w #'10',(a3)+
	bne.s .bug
	move.l d0,comp_txt
	move (a3)+,d0
	ext.l d0
	move.l d0,sample_num
	move #160,max_imagex
	move #100,max_imagey
	move.l #8032,max_fsize
	st samp_sizes
	moveq #0,d0
	move (a3)+,d0
	cmp #7,d0
	bpl.s .affine
	lea .tab(pc),a0
	move.b 0(a0,d0.w),d0
	bra.s .common
.affine:
	muls #150,d0
	sub.l #892,d0
.common:
	add.l d0,d0
	add.l d0,d0						; number of 1/200 to 1/800
	move.l d0,_delay
	move.l (a3)+,flm_snd_size		; size of sound into file
	beq.s .no_sound
	moveq #0,d0
	move (a3)+,d0					; frequency
	move.l d0,frequency
	move #8,sound_bits
	move #1,channels
	move.l sample_num,d0
	move.l max_fsize,d1
	muls d1,d0						; size of frames
	add.l #32,d0					; plus header
	move.l d0,flm_snd_pos		; position in file
.no_sound:
	moveq #0,d0
	rts
.tab: dc.b 14,20,26,36,44,56,80,0
	
vmas_read_data:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
.disp_again:
	clr.l disp_frame
	st cvid_fix0			; new palette forced
	st cvid_fix0+32		; new palette forced
	SEEK #32,0				; start of first frame (with palette)
	tst.b playing
	beq.s .nosound
	jsr flm_start_sound
.nosound:
	move.l $4ba.w,d0
	move.l d0,start_time
	add.l d0,d0
	add.l d0,d0
	move.l d0,current_time
.again:	
	move.l #8032,d4		; size to load
	move.l buffer,-(sp)
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d4,d0
	bne.s .exit
	move.l buffer,a0
	move.l a0,a1
	moveq #15,d0
.inver_pal:
	move (a1),d1
	move d1,d2
	lsr d1
	and #$777,d1
	lsl #3,d2
	and #$888,d2
	or d2,d1
	move d1,(a1)+
	dbf d0,.inver_pal
	bsr kin_read_palette
	bsr vmas_aff_image
	move.l current_time,d0
	add.l _delay,d0
	move.l d0,current_time
	lsr.l #2,d0
.delay:
	cmp.l $4ba.w,d0
	bpl.s .delay
	move.l sample_num,d0
	addq.l #1,disp_frame
	cmp.l disp_frame,d0
	beq.s .exit
	move.l kbshift,a0
	btst #2,(a0)
	bne.s .stop
	bra .again
.exit:
	tst.b playing
	beq.s .no_sound_end
	tst.b _snd
	bpl.s .yamaha
	btst #0,$ffff8901.w
	beq.s .no_sound_end
	bra.s .test_control
.yamaha:
	tst.b yamaha_flag
	beq.s .no_sound_end
.test_control:
	move.l kbshift,a0
	btst #2,(a0)
	beq.s .exit
.no_sound_end:
	tst.b is_rep
	bne .disp_again
	bra.s .normal_out
.stop:
	st stopped
.normal_out:
	tst.b playing
	beq.s .no_stop_sound
	tst.b _snd
	bmi.s .dma
	move sr,d0
	move #$2700,sr
	move.l yamaha_ptr,a0
	clr.b (a0)+
	clr.b (a0)
	move d0,sr
	bra.s .no_stop_sound
.dma:
	clr.b $ffff8901.w
.no_stop_sound:
	move.l $4ba.w,end_time
	move.l stack_adr,-(sp)
	GEMDOS 32,6
	rts		

vmas_aff_image:
	move.l buffer,a0
	add.w #32,a0
	move.l physbase,a3	; else, on a simple TT
	add.w #8040,a3
	moveq #99,d7			; 100 lines
.line:
	moveq #4,d6				; 5 times 32 points
.pixels:
	movem.l (a0)+,d0-d3
	movem.l d0-d3,(a3)
	add.w #16,a3
	dbf d6,.pixels
	add.w #80,a3
	dbf d7,.line
	rts

vmas_read_sound:
	move.l flm_snd_size,d0		; source size
	move.l d0,d5					; saves it
	move.l frequency,d7			; source frequency
	beq.s .end
	tst.b bad_sound
	bne.s .end
	divs d7,d0
	moveq #0,d1
	move d0,d1
	clr d0
	swap d0
	move.l #12517,d6		; with DMA
	tst.b _snd
	bmi.s .dma
	move.l #9600,d6		; other sound hardware
.dma:
	move.l d6,frequency
	muls d6,d1
	muls d6,d0
	divs d7,d0
	ext.l d0
	add.l d0,d1						; dest size of the sound
	move.l d1,snd_size
	addq.l #8,d1					; security
	move.l d1,-(sp)
	GEMDOS 72,6
	move.l d0,snd_temp
	bgt.s .ok
.end:
	rts								; no sound loaded...
.ok:
	move.l d0,a6					; sound ptr
	move.l #32768,-(sp)
	GEMDOS 72,6						; temporary buffer
	move.l d0,a5
	tst.l d0
	bmi.s .end
	beq.s .end
	movem.l d5-d7,-(sp)
	moveq #1,d6
	moveq #1,d7
	bsr manage_tree				; loading sound...
	movem.l (sp)+,d5-d7
	SEEK flm_snd_pos,0
.again:
	move.l #32768,d4
	cmp.l d4,d5
	bpl.s .enough
	move.l d5,d4
.enough:
	sub.l d4,d5
	move.l a5,a3
	move.l a3,-(sp)
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	bsr vmas_treat_sound
	tst.l d5
	bgt.s .again
	move.l a6,flm_snd_end
	move.l a5,a2
	bsr mfree
	tst.l _delay
	beq.s .no_sync
	move.l a6,d0
	sub.l snd_temp,d0			; sound size
	divs d6,d0
	move d0,d1					; q
	clr d0
	swap d0						; r
	muls #800,d1
	muls #800,d0
	divs d6,d0
	ext.l d0
	add.l d0,d1					; number of 1/200 for the whole anim
	move.l sample_num,d0
	divs d0,d1					; number of 1/200 for one image
	ext.l d1
	move.l d1,_delay
.no_sync:
	st playing
	moveq #1,d6
	moveq #-1,d7
	bsr manage_tree
	rts		

vmas_treat_sound:
	lea 0(a3,d4.l),a0	; end of source
	moveq #0,d2
	moveq #0,d3			; with DMA, 0=0
	tst.b _snd
	bmi.s .dma
	moveq #1,d3			; else, change 0 with 1
.dma:
	cmp.l d6,d7
	bmi.s .lb3			; greater dest
	bra.s .lb1
.lb0:
	addq.l #1,a3
	cmp.l a0,a3
	bpl.s .end
	add.l d6,d2
	cmp.l d7,d2
	bmi.s .lb0
.lb1:
	move.b (a3),(a6)+
	bne.s .ok1
	move.b d3,-1(a6)
.ok1:
	sub.l d7,d2
	bra.s .lb0
.end:
	rts
.lb2:
	move.b d0,(a6)+
	add.l d7,d2
	cmp.l d6,d2
	bmi.s .lb2
	sub.l d6,d2
.lb3:
	cmp.l a0,a3
	bpl.s .end
	move.b (a3)+,d0
	bne.s .lb2			; <>0
	move.b d3,d0		; else it must be changed to 1 without dma
	bra.s .lb2
	
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

spmul: 
	movem.l a6/d0-d3,-(sp)
	lea _op2(pc),a6
	clr d2
   tst.l (a6)+
   bge.s .lb1
   neg.l -4(a6)
   moveq #1,d2
.lb1: tst.l (a6)
   bge.s .lb2
   neg.l (a6)
   addq #1,d2
.lb2: move -2(a6),d0
   mulu 2(a6),d0
   move -4(a6),d1
   mulu 2(a6),d1
   move (a6),d3
   mulu -2(a6),d3
   add d3,d1
   move.l d0,(a6)
   add d1,(a6)
   btst #0,d2
   beq.s .lb3
   neg.l (a6)
.lb3: 
	movem.l (sp)+,a6/d0-d3
	rts

add_version_number:
	move.l 36(a0),a0
	move.l (a0),a0
.lb0:
	tst.b (a0)+
	bne.s .lb0
	subq.l #1,a0
	move.l #VERSION,d0
	move.b d0,-(a0)
	ror #8,d0
	move.b d0,-(a0)
	swap d0
	move.b d0,-(a0)
	ror #8,d0
	move.b d0,-(a0)
	rts

cd_read_header:
	SEEK #0,0
	moveq #40,d3
	lea cvid_fix0,a3
	pea (a3)
	move.l d3,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d0,d3
	beq.s .ok
.bug:
	moveq #1,d0
	rts
.ok:
	move.l (a3)+,d0
	move.l d0,comp_txt	; compression name
	cmp.l #'CDA1',d0
	beq .sound_file
	moveq #3,d4			; monochrome
	moveq #2,d5
	move.l #cdh1_aff,a0
	cmp.l #'CDH1',d0
	beq.s .found
	moveq #1,d4			; 16 greys
	moveq #0,d5
	move.l #cdl1_aff,a0
	cmp.l #'CDL1',d0
	beq.s .found
	moveq #0,d4			; 256 greys
	moveq #7,d5
	move.l #cdv1_aff,a0
	cmp.l #'CDV1',d0
	bne.s .bug
	st bad_comp			; unsupported!!
.found:
	move.l a0,compression
	move d4,cram_bits		; number of planes
	moveq #8,d0
	lsr d4,d0				; grey_depth
	move d0,grey_depth
	move d5,tt_res
	bsr .cd_read_num
	move.l d0,sample_num
	bsr .cd_read_num
	moveq #16,d6			; delay in 1/200
	moveq #0,d5				; no remain
	moveq #1,d2
	move.l d0,snd_size
	beq.s .no_sound
	lea _op2,a0
	move.l #50,(a0)+
	move.l d0,(a0)
	bsr spmul
	move.l (a0),d0
	move.l #12517,d2
	move.l d2,frequency
	lsr.l #2,d2
	move.l d2,-4(a0)
	move.l sample_num,(a0)
	bsr spmul
	move.l (a0),d2
	move.l d0,(a0)
	move.l d2,-(a0)
	bsr spdiv
	move.l (a0)+,d5
	move.l (a0),d6
	move #8,sound_bits
	move #1,channels
.no_sound:
	move.l d6,_delay
	move.l d5,cd_delay
	move.l d2,max_cd_delay
	bsr.s .cd_read_num
	move d0,max_imagex
	move d0,d3
	bsr.s .cd_read_num
	move d0,max_imagey
	move.l d0,imagey		; for qt_raw1 (CDH1)
	muls d0,d3				; d3=number of pixels
	lsr.l d4,d3				; d3=size of one frame
	move.l d3,max_fsize
	bsr.s .cd_read_num	; ??
	st samp_sizes
	move.l snd_size,d1
	beq.s .exit
	lea _op2,a0
	move.l sample_num,(a0)+
	move.l #6258,(a0)
	bsr spmul
	move.l d1,-(a0)
	bsr spdiv
	move.l (a0)+,d2
	move.l (a0),d0
	lea cd_acc+8,a0
	move d0,(a0)+			; integer
	move.l d2,(a0)+		; remainder
	move.l d1,(a0)			; remainder limit
.exit:	
	addq.l #2,a3			; skips 13,10
	sub.l #cvid_fix0,a3	; number of bytes for header
	move.l a3,sound_seek
	moveq #0,d0
	rts
.cd_read_num:
	cmp.b #32,(a3)+
	bmi.s .cd_read_num
	subq.l #1,a3
	moveq #0,d0
	moveq #1,d1
.digit:
	move.b (a3)+,d1
	sub #'0',d1
	bmi.s .end
	add.l d0,d0
	move.l d0,d2
	add.l d2,d2
	add.l d2,d2
	add.l d2,d0		; x 10
	add.l d1,d0		; + digit
	bra.s .digit
.end:
	subq.l #1,a3
	rts
.sound_file:
	bsr.s .cd_read_num	; number of 6258 bytes (maybe...)
	move.l #12517,frequency
	move #1,channels
	move #8,sound_bits	
	bra.s .exit

cd_calc_loops:
	lea cd_acc,a0
	move.l (a0)+,d0	; remainder
	move (a0)+,d1	; integer
	add.l 4(a0),d0
	add 2(a0),d1
	cmp.l 8(a0),d0
	bmi.s .end
	sub.l 8(a0),d0
	addq #1,d1
.end:
	move d1,d2		; how many
	tst d0
	beq.s .lb0
	addq #1,d2
.lb0:
	sub d2,d1		; 0 or -1
	subq #1,d2		; for the loop
	move d2,(a0)
	move d1,-(a0)
	move.l d0,-(a0)
	rts

cd_sound_size:
	move.l #6258,d0
	lea cd_sound_count,a0
	cmp.l (a0),d0
	bmi.s .enough
	move.l (a0),d0
	clr.l (a0)
	rts
.enough:
	sub.l d0,(a0)
	rts
			
cd_read_data:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
.disp_again:
	clr.l disp_frame
	move.l snd_size,cd_sound_count
	bsr.s cd_sound_size
	add.l #40,d0
	SEEK d0,0				; start of data
	lea cd_acc,a0
	clr.l (a0)+
	clr (a0)
	bsr cd_calc_loops
	tst.b playing
	beq.s .nosound
	jsr flm_start_sound
.nosound:
	move.l $4ba.w,d0
	move.l d0,start_time
	move.l d0,current_time
	clr.l cd_delay_acc
.again:	
	tst.l frequency
	beq.s .no_sound_skip
	cmp.l #1,disp_frame
	beq.s .skip
	subq.w #1,cd_acc+6
	bpl.s .no_sound_skip
	bsr cd_calc_loops		
.skip:
	bsr cd_sound_size
	SEEK d0,1			; relative skip
.no_sound_skip:	
	move.l max_fsize,d4		; size to load
	move.l buffer,-(sp)
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d4,d0
	bne.s .exit
	move.l compression,a0
	jsr (a0)
.timing:
	moveq #0,d1
	lea cd_delay_acc,a0
	move.l (a0)+,d0
	add.l (a0)+,d0
	cmp.l (a0),d0
	bmi.s .zzz
	sub.l (a0),d0
	moveq #1,d1
.zzz:
	move.l d0,-8(a0)
	addq.l #4,a0
	add.l (a0)+,d1
	add.l (a0),d1
	move.l d1,(a0)
.delay:
	cmp.l $4ba.w,d1
	bpl.s .delay
	move.l sample_num,d0
	addq.l #1,disp_frame
	cmp.l disp_frame,d0
	beq.s .exit
	move.l kbshift,a0
	btst #2,(a0)
	bne.s .stop
	bra .again
.exit:
	tst.b playing
	beq.s .no_sound_end
	tst.b _snd
	bpl.s .yamaha
	btst #0,$ffff8901.w
	beq.s .no_sound_end
	bra.s .test_control
.yamaha:
	tst.b yamaha_flag
	beq.s .no_sound_end
.test_control:
	move.l kbshift,a0
	btst #2,(a0)
	beq.s .exit
.no_sound_end:
	move.l kbshift,a0
	btst #0,(a0)
	bne .disp_again
	btst #1,(a0)
	bne .disp_again
	bra.s .normal_out
.stop:
	st stopped
.normal_out:
	tst.b playing
	beq.s .no_stop_sound
	tst.b _snd
	bmi.s .dma
	move sr,d0
	move #$2700,sr
	move.l yamaha_ptr,a0
	clr.b (a0)+
	clr.b (a0)
	move d0,sr
	bra.s .no_stop_sound
.dma:
	clr.b $ffff8901.w
.no_stop_sound:	
	move.l $4ba.w,end_time
	move.l stack_adr,-(sp)
	GEMDOS 32,6
	rts

cd_play_sound:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
	tst.b playing
	beq.s .exit
	jsr flm_start_sound
.exit:
	tst.b playing
	beq.s .normal_out
	tst.b _snd
	bpl.s .yamaha
	btst #0,$ffff8901.w
	beq.s .normal_out
	bra.s .test_control
.yamaha:
	tst.b yamaha_flag
	beq.s .normal_out
.test_control:
	move.l kbshift,a0
	btst #2,(a0)
	beq.s .exit
	st stopped
.normal_out:
	tst.b playing
	beq.s .no_stop_sound
	tst.b _snd
	bmi.s .dma
	move sr,d0
	move #$2700,sr
	move.l yamaha_ptr,a0
	clr.b (a0)+
	clr.b (a0)
	move d0,sr
	bra.s .no_stop_sound
.dma:
	clr.b $ffff8901.w
.no_stop_sound:	
	move.l $4ba.w,end_time
	move.l stack_adr,-(sp)
	GEMDOS 32,6
	rts

cdh1_aff:
	move.l buffer,a0
	move.l image,a3
	move #320,d3
	move max_imagex,d2
	add #15,d2
	and #$fff0,d2
	sub d2,d3
	lsr #1,d3
	lsr #4,d2
	subq #1,d2
	move max_imagey,d4
	subq #1,d4
.line:
	move d2,d1
.pixel:
	move (a0)+,(a3)
	addq.l #8,a3
	dbf d1,.pixel
	add d3,a3
	dbf d4,.line
	rts		
	
cdl1_aff:
	move.l buffer,a0
	move.l image,a3
	move #320,d3
	move max_imagex,d2
	add #15,d2
	and #$fff0,d2
	sub d2,d3
	lsr #1,d3
	lsr #4,d2
	subq #1,d2
	move max_imagey,d4
	subq #1,d4
.line:
	move d2,d1
.pixel:
	move.l (a0)+,(a3)+
	move.l (a0)+,(a3)+
	dbf d1,.pixel
	add d3,a3
	dbf d4,.line
	rts		
	
cdv1_aff:
	rts

cd_read_sound:
	sf playing
	tst.b bad_sound
	bne .end				; bad sound any_way
	tst.l frequency
	beq .end				; no sound!
	move.l snd_size,d7
	tst.b _snd
	bmi.s .dma1
	move.l d7,d0
	move.l d0,d1
	lsl.l #3,d1
	add.l d1,d0
	add.l d1,d1
	add.l d1,d0			; x 25
	lsr.l #5,d0			; /32 ~ x.78 (>9600/12516)
	add.l #2000,d0		; security (6258 > 4800)
	move.l d0,-(sp)
	bra.s .no_dma	
.dma1:
	move.l d7,-(sp)
.no_dma:
	GEMDOS $48,6			; mxalloc
	tst.l d0
	bmi .end				; alloc error
	beq .end
	move.l d0,snd_temp
	move.l d0,d6
	movem.l d6-d7,-(sp)
	moveq #1,d6
	moveq #1,d7
	jsr manage_tree
	movem.l (sp)+,d6-d7
	SEEK sound_seek,0
	move.l d6,d0
	add.l d7,d0
	move.l d0,flm_snd_end
	tst.l max_fsize
	beq .sound_file
	bsr .load_one
	SEEK max_fsize,1
	bsr .load_one
	lea cd_acc,a0
	clr.l (a0)+
	clr (a0)
	bsr cd_calc_loops
.loop:	
	move cd_acc+6,d0
	ext.l d0
	lea _op2,a0
	move.l d0,(a0)+
	move.l max_fsize,(a0)
	bsr spmul
	move.l (a0),d1
	SEEK d1,1
	bsr cd_calc_loops		
	addq #1,cd_acc+6
	bsr .load_one
	tst.l d7
	bne.s .loop
.exit:
	moveq #1,d6
	moveq #-1,d7
	jsr manage_tree
	st playing
.end:
	rts
.sound_file:
	bsr.s .load_one
	tst.l d7
	bne.s .sound_file
	bra.s .exit
.load_one:
	move.l #6258,d0
	cmp.l d0,d7
	bpl.s .load_enough
	move.l d7,d0
.load_enough:
	sub.l d0,d7
	move.l d6,-(sp)
	move.l d0,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	tst.b _snd
	bpl.s .adapt
	add.l d0,d6
	rts
.adapt:
	move.l d6,a0	; source
	move.l d6,a1	; dest
	lea 0(a0,d0.l),a2	; end
	moveq #0,d0
	moveq #1,d1
	bra.s .lb1
.lb0:
	addq.l #1,a0
	cmp.l a2,a0
	bpl.s .treated
	add.l #19200,d0
	cmp.l #25033,d0
	bmi.s .lb0
.lb1:
	move.b (a0),(a1)+
	bne.s .ok1
	move.b d1,-1(a1)
.ok1:
	sub.l #25033,d0
	bra.s .lb0
.treated:
	move.l a1,d6	; new end of sample
	rts

set_palette:
	move.l (sp)+,d0	; return adress
	move.l (sp)+,a0	; palette
	move.l d0,-(sp)	; return
	lea xbios_pal_sav,a1
	rept 8
		move.l (a0)+,(a1)+	; saves the palette
	endr
	tst.b nova
	bne.s .end
	pea -32(a0)
	XBIOS 6,6
	XBIOS 37,2
	XBIOS 37,2
.end:
	rts
	
xqto4n: dc.w 0
yqto4n: dc.w 0	
xto4n: dc.w 0
yto4n: dc.w 0
iv32_uv_inc: dc.w 0
iv32_entry: dc.l 0

intel_iv32_256:
 MOVE.L buffer,A2
 move.l 12(a2),d0
 INTEL d0
 cmp.l #50,d0
 bmi .fin
 LEA 16+2(A2),A2
 MOVE (A2)+,D0
 MOVE.L (A2)+,D5
 MOVEQ #0,D7
 MOVE.B (A2)+,D7
 ADDQ.l #3,A2
 MOVE (A2)+,D6
 ROR #8,D6
 CMP max_imagey,D6
 BNE .fin
 swap d6
 MOVE (A2)+,D6
 ROR #8,D6
 CMP max_imagex,D6
 BNE .fin
 MOVEM.L (A2)+,D2-D4
 INTEL d2
 INTEL d3
 INTEL d4
 ADDQ.l #4,A2
 MOVE.L A2,A5
 CMP.L #128,D5
 beq .fin
 LEA -32(A5,D2.L),A0
 MOVE.L (A0)+,D1
 INTEL d1
 lea iv32_ptrs,a3
 lea 12(a3),a2
 BTST #1,D0
 Bne.S .lb43
 exg.l a2,a3
.lb43:
 MOVE D6,D2
 CMP #160,D6
 BLS.S .lb45
 MOVE #160,D2
.lb45:  MOVE D2,-(SP)
 MOVE.L A0,-(SP)
 MOVE.L A5,-(SP)
 MOVE d7,-(SP)
 add.l d1,a0
 pEA 0(A0,D1.L)
 swap d6
 MOVE.l d6,-(SP)
 MOVE.L (A3),-(SP)
 MOVE.L (A2),-(SP)
 move.l iv32_entry(pc),a4
 jSR (a4)
 LEA 28(SP),SP
 bne .fin	; plan Y
	move.l (a2),a0		; Y plan
	move.l virtual,a3		; screen
	move max_imagex,d3
	move xto4n(pc),d7
	sub d7,d3				; screen inc
	move yto4n(pc),d6
	lsr #2,d7				; 4 par 4
	subq #1,d7
	bra.s .loop
.copy:
	move d7,d0
.pix4:
	move.l (a0)+,d1
	and.l #$78787878,d1
	move.l d1,(a3)+
	dbf d0,.pix4
	add d3,a3
.loop:
	dbf d6,.copy	
.fin:
	rts 

init_iv32_buf:
   LEA iv32_ptrs,A4
   LEA 12(a4),A5
	moveq #-16,d0
	moveq #15,d1
	move max_imagex,d2
	add d1,d2
	and.l d0,d2
	move max_imagey,d3
	add d1,d3
	and.l d0,d3
	muls d2,d3			; xy
	move.l d3,d1
	add.l d1,d1
	move.l d3,d0
	lsr.l #2,d0
	add.l d0,d1			; 2xy + xy/4
	move.l d2,d0
	lsl.l #2,d0
	add.l d0,d1			; 2xy +xy/4 +4x	: buffer total
	add.l #IV_SIZE,d1	; plus la routine + tableaux a decompresser
	bsr malloc
	move.l d0,a1		; adresse buffer
	move.l d0,bat_text	; as the iv_buffer
	lea _iv32,a0
	bsr ice_decrunch
	move.l a1,a0
	add.l #IV_SIZE,a0	; for YUV buffer
	lea 28(a1),a1
	move.l a1,iv32_entry	
	move.l #$40404040,d1	; valeur remplissage
	lsr #2,d2
	subq #1,d2			; boucle
	bsr.s .remplir
	move.l a0,(a4)+	; y1
	add.l d3,a0			; saute Y1
	bsr.s .remplir
	move.l a0,(a5)+	; y2
	add.l d3,a0			; saute y2
	bsr.s .remplir
	move.l a0,(a4)+	; U1
	lsr.l #4,d3			; xy/16
	addq #1,d2
	lsr #2,d2
	subq #1,d2			; x/16 longs
	add.l d3,a0			; saute u1
	bsr.s .remplir
	move.l a0,(a5)+	; u2
	add.l d3,a0			; saute u2
	bsr.s .remplir
	move.l a0,(a4)+	; v1
	add.l d3,a0			; saute v1
	bsr.s .remplir
	move.l a0,(a5)+	; v2
	add.l d3,a0
	bsr.s .remplir
	rts
.remplir:
	move d2,d0
.rr:
	move.l d1,(a0)+
	dbf d0,.rr
	rts

ice_decrunch:
	movem.l	d0-a6,-(sp)
	addq.l #4,a0				; skips 'ICE!'
	move.l (a0)+,d0
	lea.l	-8(a0,d0.l),a5
	move.l (a0)+,d0
	move.l	d0,(sp)
	move.l	a1,a4
	move.l	a1,a6
	adda.l	d0,a6
	move.l	a6,a3
	move.b	-(a5),d7
	bsr	.normal_bytes
	move.l	a3,a6
	bsr	.get_1_bit
	bcc.s	.not_packed
	move.w	#$0f9f,d7
	bsr	.get_1_bit
	bcc.s	.ice_00
	moveq	#15,d0	
	bsr	.get_d0_bits
	move.w	d1,d7
.ice_00:	moveq	#3,d6
.ice_01:	move.w	-(a3),d4
	moveq	#3,d5
.ice_02:	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,.ice_02
	dbra	d6,.ice_01
	movem.w	d0-d3,(a3)
	dbra	d7,.ice_00
.not_packed:
	movem.l	(sp)+,d0-a6
	rts
.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end
	moveq.l	#0,d1
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1
	dbne	d3,.nextgb
.no_more:	add.l	20(a1),d1
.copy_direkt:	
	move.b	-(a5),-(a6)
	dbf	d1,.copy_direkt
.test_if_end:	
	cmpa.l	a4,a6
	bgt.s	.strings
	rts	
.get_1_bit: 
	add.b	d7,d7
	bne.s	.bitfound
	move.b	-(a5),d7
	addx.b	d7,d7
.bitfound:	rts	
.get_d0_bits:	
	moveq.l	#0,d1
.hole_bit_loop:	
	add.b	d7,d7
	bne.s	.on_d0
	move.b	-(a5),d7
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1
	dbf	d0,.hole_bit_loop
	rts	
.strings:	lea.l	.length_tab(pc),a1
	moveq.l	#3,d2
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit:	
	moveq.l	#0,d4
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.no_uber
.get_uber: bsr.s	.get_d0_bits
.no_uber:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.get_offset_2
	lea.l	.more_offset(pc),a1
	moveq.l	#1,d2
.getoffs:	bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.get_d0_bits
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	.depack_bytes
	sub.w	d4,d1
	bra.s	.depack_bytes
.get_offset_2:	
	moveq.l	#0,d1
	moveq.l	#5,d0
	moveq.l	#-1,d2
	bsr.s	.get_1_bit
	bcc.s	.less_40
	moveq.l	#8,d0
	moveq.l	#$3f,d2
.less_40:	bsr.s	.get_d0_bits
	add.w	d2,d1
.depack_bytes:
	lea.l	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.dep_b:	move.b	-(a1),-(a6)
	dbf	d4,.dep_b
	bra	.normal_bytes
.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1
.length_tab:
	dc.b 9,1,0,-1,-1
	dc.b 8,4,2,1,0
.more_offset:
	dc.b	  11,   4,   7,  0
	dc.w	$11f,  -1, $1f

treat_vr_box:
	moveq #11,d6	; simulates 'OK'
	tst.b create_flm
	beq.s .lb0
	sf vr_flag		; no VR mode with FLM creation
	rts
.fin:
	move.l tree,a0
	btst #0,371(a0)
	sne vr_clic+1
	rts
.lb0:
	tst.b vr_flag
	beq.s .fin		; no VR anyway...
	moveq #6,d0
	move.l d0,rg_int
	GEM_AES rsrc_gaddr
	move.l tree,a0
	btst #0,227(a0)	; box 'do not display'
	bne.s .fin
	bclr #3,83(a0)
	bclr #3,131(a0)
	cmp #1,vr_x
	bne.s .lb1
	bset #3,83(a0)
	bset #3,131(a0)	; no x movement
.lb1:
	bclr #3,107(a0)
	bclr #3,155(a0)
	cmp #1,vr_y
	bne.s .lb2
	bset #3,107(a0)
	bset #3,155(a0)	; no y movement
.lb2:
	moveq #6,d6
	moveq #0,d7
	jsr manage_tree
	cmp #13,d6
	bne .fin
	sf vr_flag
	rts	
	

	data
		
	if REG=1
code: dc.b "7397E1"
	endif
	
exist_error: dc.b "[1][ | This file does not exist! ][ Ooops! ]",0		
data_error2: dc.b "[1][ | There's no Data2 in this file! ][ Ooops! ]",0
	if CDEB=0
format_error: dc.b "[1][ Format error, supported are: |"
				  dc.b     " QT-MOV, AVI, DL, BAT (MPlayer) |"
				  dc.b     " FLI & FLC & FLH (Autodesk) |"
				  dc.b     " FLM (Kin./Lexic./Vid.Master)|"
				  dc.b	  " SEQ/PI1+DLT (Cyber), GIF ]"
				  dc.b     "[ Ooops! ]",0
	else
format_error: dc.b "[1][ Version limit‚e CD EB Model: |"
			     dc.b     " MOV et AVI en Rle |"
			     dc.b     " FLI, FLM et GIF |"
			     dc.b     " et peut cr‚er des animations.]"
			     dc.b     "[ Ooops! ]",0
	endif
mem_error:   dc.b "[1][ | Not enough memory!... ][ Ooops! ]",0
bad_codecs:  dc.b "[1][ | QT Codecs not supported! ][ Ooops! ]",0
mdat_error:  dc.b "[1][ | QT mdat len is 0. ][ Quit ]",0
ok:          dc.b "[1][ | Everything is Ok! ][  Good!  ]",0
eof_error:   dc.b "[1][ | Unexpected End of File! | ][ Ooops! ]",0
bad_info:    dc.b "[1][ | Bad image informations! | ][ Ooops! ]",0
insuf_info:  dc.b "[1][ | The header hasn't every | information needed!"
				 dc.b " | (W=,H=,B=,C=) ][ Ooops! ]",0
insuf_info2: dc.b "[1][ | To create a Movie, you | must fill EVERY option!"
				 dc.b " | (O=,F=,T=) ][ Ooops! ]",0
cant_create: dc.b "[1][ | Can't create ouput | file! (MOV) ][ Ooops! ]",0
	if REG=1
no_rsc:		 dc.b "[1][ | Can't load ressource file! | (MP_STE.RSC) | ][ Ooops! ]",0
	else
no_rsc:		 dc.b "[1][ | Can't load ressource file! | (MP_STESW.RSC) | ][ Ooops! ]",0
	endif
	
	even

fileselect: dc.l fs_cont,global,dum,intout,fs_addrin,dum
fs_cont: dc.w 91,0,2,3,0
old_fs_cont: dc.w 90,0,2,2,0
fs_addrin: dc.l path,file,select
fs_addrin_tga: dc.l tga_path,tga_file,tga_text

alert_box: dc.l ab_cont,global,ab_int,intout,ab_addrin,dum
ab_cont: dc.w 52,1,1,1,0
ab_int: dc.w 1
ab_addrin: dc.l 0

vs_color: dc.l vs_cont,vs_int,dum,intout,dum
vs_cont: dc.w 14,0,0,4,0,0,0,0,0,0,0,0

form_dial2: dc.l fd_cont,global,rect_dial,dum,dum,dum

evnt_button: dc.l eb_cont,global,eb_int,intout,dum,dum
eb_cont: dc.w 21,3,5,0,0
eb_int: dc.w 1,1,0

form_do: dc.l do_cont,global,do_int,intout,tree,dum
do_cont: dc.w 50,1,1,1,0
do_int: dc.w 0			; no edit object

	if REG=1
_name: dc.b "MP_STE.RSC"
	else
_name: dc.b "MP_STESW.RSC"
	endif
			 dcb.b 200,0
select: dc.b " SELECT A MOVIE ",0,0
qt_title:  dc.b "  Apple QuickTime¿ (MOV)  ",0
vr_title:  dc.b "   QuickTime¿ VR (MOV)    ",0
avi_title: dc.b " Video for Windows¿ (AVI) ",0
fli_title: dc.b "Autodesk Animator¿ (FLI/C)",0
bat_title: dc.b "  Batch Slide Show (BAT)  ",0
bat_title_create:
			  dc.b "  Batch Create Mov (BAT)  ",0
bat_title_gif:
			  dc.b "  Batch Create Gif (BAT)  ",0
bat_title_avi:
			  dc.b "  Batch Create Avi (BAT)  ",0
bat_title_flm:
			  dc.b "  Batch Create Flm (BAT)  ",0
mpg_title: dc.b "   MPEG animation (MPG)   ",0 
seq_title: dc.b " Cyber Paint¿ anims (SEQ) ",0
kin_title: dc.b " Kinetic Microsyst¿ (FLM) ",0
dlt_title: dc.b " Cyber¿ anims (PI1 + DLT) ",0
flm_title: dc.b "   Lexicor¿ films (FLM)   ",0
xflm_title: dc.b "  Extended Lexicor¿ Film  ",0
gif_title: dc.b "Compuserve¿ graphics (GIF)",0
dl_title: dc.b  " Uncompressed DL1/2  (DL) ",0
vmas_title: dc.b " Video Master V1.0  (FLM) ",0 
cd_title:  dc.b "  Stratos Magazine (CDx)  ",0
	even
comp_txt: dc.b "xxxx)",0
max: dc.b "Max speed ",0
delay: dc.b "xxx.x f/s",0
tga_text: dc.b "Create FLM File",0,0
step_text:    dc.b " (Save/All/Quit/Run)",0
control_text: dc.b " (Control to stop!)",0
step_home: dc.b 27,"H",0
degas_text: dc.b 27,"ECreating extended FLM file...",13,10,10,0
create_text: dc.b 27,"ECreating Quick Time file...",13,10,10,0
gif_text		dc.b 27,"ECreating GIF file...",13,10,10,0
create_avi_text: dc.b 27,"ECreating Video for Windows file...",13,10,10,0
sound_text: dc.b "Adding sound...",13,10,10,0
	even		; to have add_digit - 5 on an even address
add_file: dc.b 13,"Adding frame 00000"
add_digit: dc.b "0...",0
add_header: dc.b 13,10,10,"Saving header...",0
count_title: dc.b 27,"EAnalysing color map...",13,10,10,0
count_end: dc.b 13,10,10,"End of analysis, press a key...",0
	even
count_stat: dc.b 13,"Frame 0000000    Colors used 000",0


   even	

	; to build each table, x goes from 4 to 124 and from -124 to -4 (step 8)
	; then we calculate int( x * A + 0.5 ), A depends on the table.
	
	; A=1.402
qt_vr_tab: dc.w 6,17,28,39,50,62,73,84,95,107
			  dc.w 118,129,140,151,163,174
			  dc.w -174,-163,-151,-140,-129
			  dc.w -118,-107,-95,-84,-73,-62,-50
			  dc.w -39,-28,-17,-6
	; A=-0.34414
qt_ug_tab: dc.w -1,-4,-7,-10,-12,-15,-18,-21
			  dc.w -23,-26,-29,-32,-34,-37,-40,-43
			  dc.w 43,40,37,34,32,29,26,23,21
			  dc.w 18,15,12,10,7,4,1
	; A=-0.71414
qt_vg_tab: dc.w -3,-9,-14,-20,-26,-31,-37,-43
		     dc.w -49,-54,-60,-66,-71,-77,-83,-89
		     dc.w 89,83,77,71,66,60,54,49,43,37
		     dc.w 31,26,20,14,9,3
	; A=1.772 
qt_ub_tab: dc.w 7,21,35,50,64,78,92,106,120,135,149,163,177,191,206,220
			  dc.w -220,-206,-191,-177,-163,-149,-135,-120,-106,-92,-78,-64
			  dc.w -50,-35,-21,-7

	; for QT modes (rle, smc, ...)
	
default_palette:
	dc.b 1,0		; one block
	dc.b 0,0		; 0=start, 0=256 colors
   dc.b $ff,$ff,$ff,$ff,$ff,$cc,$ff,$ff,$99,$ff,$ff,$66
   dc.b $ff,$ff,$33,$ff,$ff,$0,$ff,$cc,$ff,$ff,$cc,$cc
   dc.b $ff,$cc,$99,$ff,$cc,$66,$ff,$cc,$33,$ff,$cc,$0
   dc.b $ff,$99,$ff,$ff,$99,$cc,$ff,$99,$99,$ff,$99,$66
   dc.b $ff,$99,$33,$ff,$99,$0,$ff,$66,$ff,$ff,$66,$cc
   dc.b $ff,$66,$99,$ff,$66,$66,$ff,$66,$33,$ff,$66,$0
   dc.b $ff,$33,$ff,$ff,$33,$cc,$ff,$33,$99,$ff,$33,$66
   dc.b $ff,$33,$33,$ff,$33,$0,$ff,$0,$ff,$ff,$0,$cc
   dc.b $ff,$0,$99,$ff,$0,$66,$ff,$0,$33,$ff,$0,$0
   dc.b $cc,$ff,$ff,$cc,$ff,$cc,$cc,$ff,$99,$cc,$ff,$66
   dc.b $cc,$ff,$33,$cc,$ff,$0,$cc,$cc,$ff,$cc,$cc,$cc
   dc.b $cc,$cc,$99,$cc,$cc,$66,$cc,$cc,$33,$cc,$cc,$0
   dc.b $cc,$99,$ff,$cc,$99,$cc,$cc,$99,$99,$cc,$99,$66
   dc.b $cc,$99,$33,$cc,$99,$0,$cc,$66,$ff,$cc,$66,$cc
   dc.b $cc,$66,$99,$cc,$66,$66,$cc,$66,$33,$cc,$66,$0
   dc.b $cc,$33,$ff,$cc,$33,$cc,$cc,$33,$99,$cc,$33,$66
   dc.b $cc,$33,$33,$cc,$33,$0,$cc,$0,$ff,$cc,$0,$cc
   dc.b $cc,$0,$99,$cc,$0,$66,$cc,$0,$33,$cc,$0,$0
   dc.b $99,$ff,$ff,$99,$ff,$cc,$99,$ff,$99,$99,$ff,$66
   dc.b $99,$ff,$33,$99,$ff,$0,$99,$cc,$ff,$99,$cc,$cc
   dc.b $99,$cc,$99,$99,$cc,$66,$99,$cc,$33,$99,$cc,$0
   dc.b $99,$99,$ff,$99,$99,$cc,$99,$99,$99,$99,$99,$66
   dc.b $99,$99,$33,$99,$99,$0,$99,$66,$ff,$99,$66,$cc
   dc.b $99,$66,$99,$99,$66,$66,$99,$66,$33,$99,$66,$0
   dc.b $99,$33,$ff,$99,$33,$cc,$99,$33,$99,$99,$33,$66
   dc.b $99,$33,$33,$99,$33,$0,$99,$0,$ff,$99,$0,$cc
   dc.b $99,$0,$99,$99,$0,$66,$99,$0,$33,$99,$0,$0
   dc.b $66,$ff,$ff,$66,$ff,$cc,$66,$ff,$99,$66,$ff,$66
   dc.b $66,$ff,$33,$66,$ff,$0,$66,$cc,$ff,$66,$cc,$cc
   dc.b $66,$cc,$99,$66,$cc,$66,$66,$cc,$33,$66,$cc,$0
   dc.b $66,$99,$ff,$66,$99,$cc,$66,$99,$99,$66,$99,$66
   dc.b $66,$99,$33,$66,$99,$0,$66,$66,$ff,$66,$66,$cc
   dc.b $66,$66,$99,$66,$66,$66,$66,$66,$33,$66,$66,$0
   dc.b $66,$33,$ff,$66,$33,$cc,$66,$33,$99,$66,$33,$66
   dc.b $66,$33,$33,$66,$33,$0,$66,$0,$ff,$66,$0,$cc
   dc.b $66,$0,$99,$66,$0,$66,$66,$0,$33,$66,$0,$0
   dc.b $33,$ff,$ff,$33,$ff,$cc,$33,$ff,$99,$33,$ff,$66
   dc.b $33,$ff,$33,$33,$ff,$0,$33,$cc,$ff,$33,$cc,$cc
   dc.b $33,$cc,$99,$33,$cc,$66,$33,$cc,$33,$33,$cc,$0
   dc.b $33,$99,$ff,$33,$99,$cc,$33,$99,$99,$33,$99,$66
   dc.b $33,$99,$33,$33,$99,$0,$33,$66,$ff,$33,$66,$cc
   dc.b $33,$66,$99,$33,$66,$66,$33,$66,$33,$33,$66,$0
   dc.b $33,$33,$ff,$33,$33,$cc,$33,$33,$99,$33,$33,$66
   dc.b $33,$33,$33,$33,$33,$0,$33,$0,$ff,$33,$0,$cc
   dc.b $33,$0,$99,$33,$0,$66,$33,$0,$33,$33,$0,$0
   dc.b $0,$ff,$ff,$0,$ff,$cc,$0,$ff,$99,$0,$ff,$66
   dc.b $0,$ff,$33,$0,$ff,$0,$0,$cc,$ff,$0,$cc,$cc
   dc.b $0,$cc,$99,$0,$cc,$66,$0,$cc,$33,$0,$cc,$0
   dc.b $0,$99,$ff,$0,$99,$cc,$0,$99,$99,$0,$99,$66
   dc.b $0,$99,$33,$0,$99,$0,$0,$66,$ff,$0,$66,$cc
   dc.b $0,$66,$99,$0,$66,$66,$0,$66,$33,$0,$66,$0
   dc.b $0,$33,$ff,$0,$33,$cc,$0,$33,$99,$0,$33,$66
   dc.b $0,$33,$33,$0,$33,$0,$0,$0,$ff,$0,$0,$cc
   dc.b $0,$0,$99,$0,$0,$66,$0,$0,$33,$ee,$0,$0
   dc.b $dd,$0,$0,$bb,$0,$0,$aa,$0,$0,$88,$0,$0
   dc.b $77,$0,$0,$55,$0,$0,$44,$0,$0,$22,$0,$0
   dc.b $11,$0,$0,$0,$ee,$0,$0,$dd,$0,$0,$bb,$0
   dc.b $0,$aa,$0,$0,$88,$0,$0,$77,$0,$0,$55,$0
   dc.b $0,$44,$0,$0,$22,$0,$0,$11,$0,$0,$0,$ee
   dc.b $0,$0,$dd,$0,$0,$bb,$0,$0,$aa,$0,$0,$88
   dc.b $0,$0,$77,$0,$0,$55,$0,$0,$44,$0,$0,$22
   dc.b $0,$0,$11,$ee,$ee,$ee,$dd,$dd,$dd,$bb,$bb,$bb
   dc.b $aa,$aa,$aa,$88,$88,$88,$77,$77,$77,$55,$55,$55
   dc.b $44,$44,$44,$22,$22,$22,$11,$11,$11,$0,$0,$0
   
; for MOV rle4 or raw4...

default_pal_16:
	dc.b 1,0,0,16
	dc.b $ff,$ff,$ff,255,247,0,$ff,$63,0,$de,8,0
	dc.b $f7,8,$84,$42,0,$a5,0,0,$d6,0,$ad,$ef
	dc.b $18,$b5,$10,0,$63,$10,$52,$29,0,$94,$73,$39
	dc.b $c6,$c6,$c6,$84,$84,$84,$42,$42,$42,0,0,0


mov_header:
	dc.l	$2ee	; taille + 4 * number of frames
	dc.b 'moov'

	dc.l $6c
	dc.b 'mvhd'
	dc.l 0
date1:
	dc.l $ae33de13,$ae33de13
	dc.l 1000		; 1/1000 de sec!
;	dc.l 0		; dur‚e totale (1/1000 Šmes)
	dc.l $00010000
	dc.w $00ff
	dc.l 0,0,1,0,0,0,1,0,0,0,$4000
	dc.w 0
	dc.l 0,0,0,0,0,0,2

	dc.l $22a	; taille + 4 * number of frames
	dc.b 'trak'

	dc.l $5c
	dc.b 'tkhd'
	dc.l $f
date2:
	dc.l $AE33D60F,$AE33DE14,1
	dc.l 1000	; timescale
;	dc.l 0	; dur‚e totale
	dc.l 0,0
	dc.w 0,0,0
	dc.l 1,0,0,0,1,0,0,0,$4000
;	dc.l 0,0		; width et height
	dc.w 0

	dc.l $24
	dc.b 'edts'

	dc.l $1c
	dc.b 'elst'
	dc.l 0,1
;	dc.l 0	; dur‚e totale
	dc.l 0
	dc.w 1,0

	dc.l $1a2	; taille + 4 * number of frames
	dc.b 'mdia'

	dc.l $20
	dc.b 'mdhd'
	dc.l 0
date3:
	dc.l $ae33de13,$ae33de14,1000
;	dc.l 0	; dur‚e totale
	dc.w 0,0

	dc.l $38	; taille
	dc.b 'hdlr'
	dc.l 0
	dc.b 'mhlr','vide','gtel'
	dc.l $40000000,$0001002e
	dc.b $17,'MP_STE  on  Atari 68000'

	dc.l $142	; taille + 4 * number of frames
	dc.b 'minf'

	dc.l $14
	dc.b 'vmhd'
	dc.l 1
	dc.w $0040,$8000,$8000,$8000

	dc.l $38	; taille
	dc.b 'hdlr'
	dc.l 0
	dc.b 'dhlr','alis','gtel'
	dc.l $40000000,$00010037
	dc.b $17,'MP_STE  on  Atari 68000'

	dc.l $24
	dc.b 'dinf'

	dc.l $1c
	dc.b 'dref'
	dc.l 0,1,$c
	dc.b 'alis'
	dc.l 1

	dc.l $CA	; taille + 4 x number of frames
	dc.b 'stbl'

	dc.l $66
	dc.b 'stsd'
	dc.l 0,1
	dc.l $56
	dc.b 'rle '
	dc.l 0
	dc.w 0,1,1,1
	dc.b 'gtel'
	dc.l 0,$400
;	dc.w 0,0		; width et height
	dc.l $480000,$480000,0
	dc.w 1
	dc.b 15,"MP_STE  (V"
	VER_STR
	dc.b ")"
	dcb.b 16,0
	dc.w 16,$ffff	;plans et flag

	dc.l $18
	dc.b 'stts'
	dc.l 0,1
;	dc.l 0	; number of frames
;	dc.l 0	; duration of 1 frame

	dc.l $1c
	dc.b 'stsc'
	dc.l 0,1
	dc.l 1
;	dc.l 0	; number of frames
	dc.l 1

	dc.l $14	; ( + 4 x number of frames)
	dc.b 'stsz'
	dc.l 0,0
;	dc.l 0	; number of frames
;	dc.l x,x,x	; taille de chaque frame

	dc.l $14
	dc.b 'stco'
	dc.l 0,1,8	; first and only offset!

sound_header:
	dc.l $1f8
	dc.b 'trak'

	dc.l $5c
	dc.b 'tkhd'
	dc.l $f
date4:
	dc.l $ac78a740,$ad057173,2
	dc.l 0
;	dc.l	dur‚e totale	en 1/200 de seconde
	dc.l 0,0
	dc.w 0,0,$100
	dc.l 1,0,0,0,1,0,0,0,$4000,0,0
	dc.w 0

	dc.l $24
	dc.b 'edts'

	dc.l $1c
	dc.b 'elst'
	dc.l 0,1
;	dc.l dur‚e totale	en 1/1000
	dc.l 0
	dc.w 1,0

	dc.l $170
	dc.b 'mdia'

	dc.l $20
	dc.b 'mdhd'
	dc.l 0
date5:
	dc.l $ad057171,$ad057171
;	dc.l frequency,taille en octets
	dc.w 0,0

	dc.l $3a
	dc.b 'hdlr'
	dc.l 0
	dc.b 'mhlr','soun','gtel'
	dc.l $40000000,$00010024
	dc.b 25,'MP_STE  sound Atari 68000'

	dc.l $10e
	dc.b 'minf'

	dc.l $10
	dc.b 'smhd'
	dc.l 0,0

	dc.l $3A
	dc.b 'hdlr'
	dc.l 0
	dc.b 'dhlr','alis','gtel'
	dc.l $40000000,$0001002c
	dc.b 25,'MP_STE  sound Atari 68000'

	dc.l $24
	dc.b 'dinf'

	dc.l $1c
	dc.b 'dref'
	dc.l 0,1,$c
	dc.b 'alis'
	dc.l 1

	dc.l $98
	dc.b 'stbl'

	dc.l $34
	dc.b 'stsd'
	dc.l 0,1,$24
;	dc.b 'raw '	s_signe!
	dc.l 0
	dc.w 0,1,0,0
	dc.b 'gtel'
;	dc.w channels,res
	dc.w 0,0
;	dc.l frequency (LFIXED)

	dc.l $18
	dc.b 'stts'
	dc.l 0,1
;	dc.l taille en octets
	dc.l 1

	dc.l $1c
	dc.b 'stsc'
	dc.l 0,1
	dc.l 1
;	dc.l taille totale
	dc.l 1

	dc.l $14
	dc.b 'stsz'
	dc.l 0,1
;	dc.l taille totale

	dc.l $14
	dc.b 'stco'
	dc.l 0
	dc.l 1
	dc.l 8		; offset des sons

udta_header:
	dc.l $50
	dc.b 'udta'
	dc.l $38
	dc.b 'NAVG'
	dc.w 1	; version number?
	dc.w 0,0	; xmax, ymax
	dc.w 0,1	; ??, img/cell
	dc.w 1000,1	; time/img, cursor type
	dc.l 180	; view field
	dc.l 0,0	; start & end angle x
	dc.l 0,0	; start & end angle y
	dc.l 0,0	; first x and first y angle
	dc.w 0,0,0
	dc.l $c
	dc.b 'ctyp','stna'
	dc.l 0

avi_header:
	dc.b 'RIFF    AVI LIST    hdrlavih'
	dc.l $38000000
	dc.l $40420f00		; (32) microseconds per frame (5000 x _delay)
	dc.l 0				; (36) bytes per second
	dc.l 0,$10000000
	dc.l 0				; (48) number of frames
	dc.l 0
	dc.l $01000000		; (56) 1 images, 2 images + sound
	dc.l 0				; (60) max frame size + max sound size
	dc.l 0				; (64) W
	dc.l 0				; (68) H
	dc.l 0,0,0,0
	dc.b 'LIST'
	dc.l $74040000
	dc.b 'strlstrh'
	dc.l $38000000
	dc.b 'vidsRLE '
	dc.l 0,0,0
	dc.l $01000000		; (128) microseconds per frame
	dc.l $40420F00
	dc.l 0
	dc.l 0				; (140) number of frames
	dc.l 0				; (144) max frame size
	dc.l $34210000,0,0,0
	dc.b 'strf'
	dc.l $28040000,$28000000
	dc.l 0				; (176) W
	dc.l 0				; (180) H
	dc.l $01000800,$01000000
	dc.l 0				; (192) w*h
	dc.l 0,0,$00010000,0
							; here should come the palette 1024 bytes
							; b,v,r,0 * 256
avi_end_header:
	dc.b 'LIST    movi'
	
avi_sound_header:		; 100 bytes
	dc.b 'LIST'
	dc.l $5c000000
	dc.b 'strlstrh'
	dc.l $38000000
	dc.b 'auds'
	dc.l 0,0,0,0
	dc.l 0				; (40) scale = bytes per sample (1, 2 or 4)
	dc.l 0				; (44) freq*scale
	dc.l 0
	dc.l 0				; (52) total bytes / scale
	dc.l 0				; (56) max f size
	dc.l $34210000
	dc.l 0				; (64) scale again
	dc.l 0,0
	dc.b 'strf'
	dc.l $10000000
	dc.w $0100
	dc.w 0				; (86) channels
	dc.l 0				; (88) freq
	dc.l 0				; (92) freq x scale
	dc.w 0				; (96) scale again
	dc.w 0				; (98) bits per sample

	if REG=1
	even
code2: dc.l $8039cbf0,0
	endif

	bss

dta: ds.b 44
aes_handle: ds.w 1
i_handle: ds.w 1
mov_h: ds.w 1
total: ds.l 1
global: ds.l 100	
intout: ds.w 100

wu_int: ds.w 1

bar_pts: ds.w 2		; do not separate bar_pts and work_out
work_out: ds.w 100

ptsout: ds.w 100
dum: ds.l 3
fname_pos: ds.l 1
path: ds.b 400		; the path (for ex: F:\MOVIES\*.MOV )
file: ds.b 20		; the file (for ex: THING.MOV )
full: ds.b 420		; the full pathname (for ex: F:\MOVIES\THING.MOV )
full2: ds.b 420

tga_path: ds.b 400
tga_file: ds.b 20
tga_full: ds.b 420
tga_file_ptr: ds.l 1
tga_digit: ds.l 1
auto_save_tga: ds.b 1
auto_run_tga: ds.b 1
write_error: ds.w 1

virtual: ds.l 1

; *********** start of data that will be zeroed at launch ***********
start_zero:

inter_flag: ds.b 1

create_avi: ds.b 1
create_mov: ds.b 1
slide_gif: ds.b 1
slide_degas: ds.w 1

head_pos: ds.l 1
head_len: ds.l 1
idx_pos: ds.l 1
idx_len: ds.l 1
movi_pos: ds.l 1
avi_rate: ds.l 1

frequency: ds.l 1
channels: ds.w 1
sound_bits: ds.w 1
s_signe: ds.l 1
playing: ds.w 1
sync: ds.w 1
step_mode: ds.w 1

ss_num: ds.l 1
ss_tab: ds.l 1

sound_offs: ds.l 1
sound_num: ds.l 1

one_buffer:
top_lines_buff:
s_buffer: ds.l 1			; the ST ram buffer
top_lines_size:
stram_size: ds.l 1
two_buffer:
tga_buff:
s_buffer_2: ds.l 1		; the remaining into TT ram
tga_buff_size: ds.l 1
ttram_size: ds.l 1
snd_temp: ds.l 1
snd_temp_size: ds.l 1

snd_pos: ds.l 1
snd_end: ds.l 1
snd_tt_end: ds.l 1
snd_size: ds.l 1
timer_c: ds.l 1
end_time: ds.l 1
start_time: ds.l 1
stopped: ds.w 1
header_read: ds.w 1

qt_time: ds.l 1
qt_timescale: ds.l 1

chunkoffs: ds.l 1
chunkoff_num: ds.l 1
chunkoff_lastnum: ds.l 1
	; each entry is a long
samp_sizes: ds.l 1
sample_num: ds.l 1
sample_lastnum: ds.l 1
	; each entry is a long	
s2chunks: ds.l 1
s2chunk_num: ds.l 1
s2chunk_lastnum: ds.l 1
	; each bloc is 12 bytes long
	; 1 long : first
	; 1 long : num
	; 1 long : tag
rle16_buffer:
t2samps: ds.l 1
size_ptr:
t2samp_num: ds.l 1
	; each block is 8 bytes long:
	; 1 long : count
	; 1 long : time (or duration)
header_buffer:
codecs: ds.l 1			; adress of the malloc block
codec_num: ds.l 1	; number of codecs
codec_lastnum: ds.l 1
	; each block is 16 bytes long:
	; 1 long: width
	; 1 long: heigh
	; 1 long: depth
	; 1 long: compression
	
bad_comp: ds.w 1
bad_sound: ds.w 1

v_flag: ds.l 1
video_flag: ds.l 1
stsc_invalid: ds.l 1

qt_palette: ds.w 1

s_flag: ds.l 1
data_flag: ds.l 1

max_imagex: ds.w 1
max_imagey: ds.w 1
max_fsize: ds.l 1
buffer: ds.l 1
bufused: ds.l 1

alignwidth: ds.w 1
screenw: ds.w 1
screenh: ds.w 1
offsx: ds.l 1
offsy: ds.w 1

image: ds.l 1
imagex: ds.l 1
imagey: ds.l 1
depth: ds.l 1
compression: ds.l 1

disp_frame: ds.l 1
singlestep: ds.l 1
skipframes: ds.l 1

cvid_map_num: ds.l 1

hc_cvid: ds.l 1
mapused: ds.l 1

mov_h2: ds.w 1
key_frame_num: ds.w 1
key_count: ds.w 1
key_rate: ds.w 1
key_frame: ds.w 1

switched: ds.w 1
is_grey: ds.w 1
gif_trans: ds.b 1
gif_trans_index: ds.b 1
is_rep: ds.w 1		; byte

flm_screen: ds.l 1
flm_frame: ds.l 1
create_flm: ds.w 1
reduce: ds.b 1
count: ds.b 1
can_count: ds.b 1
yamaha_flag: ds.b 1
degas_div: ds.l 1
degas_q1: ds.l 1
degas_r1: ds.l 1

vr_flag: ds.b 1
create_vr: ds.b 1
vr_info:
	ds.l 1	; img/cell and time
vr_y: ds.w 1
vr_yloop: ds.w 1
vr_sy: ds.w 1
vr_x: ds.w 1
vr_xloop: ds.w 1
vr_sx: ds.w 1
vr_offset: ds.l 1


mountain: ds.w 1	; byte!
vanel_adr: ds.l 1


; *********** end of zeroed data **************************
end_zero:

degas_r: ds.l 1
degas_q: ds.l 1

mfp_sav: ds.b 8

count_tab: ds.l 256
count_file: ds.b 12

grey_depth: ds.w 1
cram_bits: ds.w 1
mch_value: ds.l 1
snd_value: ds.b 1	; 4 bytes for a long
_snd: ds.b 3
res_switch: ds.w 1
can_step: ds.w 1

pattern:
smc_8: ds.w 1
dup_line:
smc_a: ds.w 1
bat_getp:
smc_c: ds.w 1
pal_adr: ds.w 1

off_24_32: ds.w 1

cvid_maps0: ds.l 6
cvid_maps1: ds.l 6
cvid_fix0:  ds.b 6*2080
cvid_fix1:  ds.b 6*2080
				ds.b 3904	; for the FLM palettes
cvid_vmap0: ds.b 6
cvid_vmap1: ds.b 6
	ds.w 1					; when x needs to be long
x: ds.w 1
y: ds.w 1
y_top: ds.w 1
flag0: ds.w 1
flag1: ds.w 1
flag2: ds.w 1
nova: ds.w 1
command: ds.w 1
basepage: ds.l 1

col_sav: ds.w 256*3
vs_int: ds.w 4
planes: ds.w 1
display: ds.w 1		; 1 if form_dial(reserve) has been called
							; 0 after form_dial(free)
							
planes_sav: ds.w 1	; in case of a screen switch
old_video: ds.w 1		; mode code
old_screen: ds.l 1	; GEM physbase
old_size: ds.l 1		; GEM screen size
old_border: ds.l 1	; some video registers
physbase: ds.l 1		; my physbase (if needed)
physbase2: ds.l 1		; the unaligned address (for mfree)
end_of_screen: ds.l 1
video_reg: ds.b 36	; hardware video registers for Falcon

desiredtag: ds.l 1
fcctype: ds.l 1
mdat_end: ds.l 1

stack_adr: ds.l 1
kbshift: ds.l 1

rg_int: ds.w 2
tree: ds.l 1
tree_sav: ds.l 1
rect_dial: ds.w 3
rect_draw: ds.w 1
rect: ds.w 5
play_sav: ds.l 1
sync_sav: ds.l 1

cd_delay_acc: ds.l 1	; do not separate
cd_delay: ds.l 1
max_cd_delay: ds.l 1
_delay: ds.l 1
current_time: ds.l 1

boxh: ds.w 1

hc_rmap: ds.w 256
hc_gmap: ds.w 256
hc_bmap: ds.w 256

bat_ptr: ds.l 1
out_file: ds.b 400	; enough!
sound_file: ds.b 400
comp_create: ds.l 1
header_size: ds.l 1
_freq_sav: ds.l 1
quality: ds.w 1
size_added: ds.l 1
last_size: ds.l 1
bloc_num: ds.l 1
sound_seek: ds.l 1
mov_pal: ds.l 1
print_ptr: ds.l 1

low_index: ds.w 1
high_index: ds.w 1
n_color: ds.w 1
end_loop: ds.w 1

old_midi: ds.l 1
old_stat: ds.l 1
old_cloc: ds.l 1
old_ikbd: ds.l 1

tt_screen: ds.l 1
tt_comp: ds.l 1
is_tt: ds.w 1
flx_hide: ds.w 1
flx_number: ds.w 1
flx_start: ds.w 1
first_time: ds.w 1
_disp: ds.w 1
little_indian: ds.b 1
pal_change: ds.b 1
clip_adr: ds.l 1
mfdb_dest: ds.w 10

flx_ptr: ds.l 1
flx_flag: ds.w 1
flx_end: ds.w 1

vcp_int: ds.w 1		; do not separate vcp_*
vcp_ptsin: ds.w 8

reverse_flag: ds.w 1
gif_flags: ds.w 1
codesize2: ds.w 1
root_code: ds.w 1
gif_image: ds.l 1
gif_image_sav: ds.l 1
gif_rows: ds.w 1
gif_inc: ds.w 1
gif_one_line: ds.w 1
gif_pass: ds.w 1
gif_interlace: ds.w 1
gif_end_image: ds.l 1
gif_repeat: ds.w 1
_gif_rep: ds.w 1
gif_pal_size: ds.l 1
bat_gif_loop: ds.w 1

tt_res: ds.w 1
tt_flag_size: ds.l 1
tt_screen_size: ds.l 1
is_mono: ds.w 1

menu_tree: ds.l 1
menu_buffer: ds.l 1
menu_len: ds.l 1

dl_i_per_s: ds.w 1

display_ste: ds.l 1
colors256: ds.b 256

cmd_x: ds.w 1
cmd_y: ds.w 1

acc_cmd_adr: ds.l 1

xbios_pal_sav: ds.w 16

cf_display: ds.l 1
flm_time_ptr: ds.l 1
flm_ptr_inc: ds.l 1
flm_time: ds.l 1
flm_time_inc: ds.l 1
flm_snd_size: ds.l 1
flm_snd_pos: ds.l 1
flm_snd_end: ds.l 1
_flm_phys: ds.l 1
neo_degas_offs: ds.l 1

iv32_ptrs: ds.l 6
bat_text: ds.l 1

ikbdstate: ds.l 1

cd_acc: ds.w 9 ; LONG acc_remain, WORD acc_int, WORD loop
					; word +int, LONG+remain, LONG remain limit
cd_sound_count: ds.l 1

cmd_dial: ds.b 1	; do not separate those flags
cmd_play: ds.b 1
cmd_sync: ds.b 1
cmd_alt: ds.b 1
cmd_erro: ds.b 1
cmd_inter: ds.b 1
cmd_coord: ds.b 1

	even
	
mp_buffer: ds.w 8

acc: ds.b 1
rsc: ds.b 1
acc_command: ds.b 1
repondre: ds.b 1
	even
	ds.b $1000
_pile: ds.w 1		; room for the stack

	end
	
	
	
	