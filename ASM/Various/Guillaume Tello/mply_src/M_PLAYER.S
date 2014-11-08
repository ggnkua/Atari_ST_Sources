; Quick Time, AVI, FLI/FLC player
; Original version (graphics only): Dieter Fiebelkorn
; ASM translation + DMA sound + NOVA graphics: Guillaume Tello


	opt P=68030,P=68882,w+

CDEB = 0			; 1 pour CD EB Model (limite!!!)

	if CDEB=0	
VERSION = '2.9B'
	else
VERSION = 'EBcd'
	endif
	
VER_STR macro
	dc.b "2.78"
	endm

REG = 1			; 1 for registred versions, 0 for shareware
MARTIN = 1		; 1 pour MPEG martin, 0 pour DECODEUR.PRG

	if REG=1
		if CDEB=0
		OUTPUT "F:\ANIM\M_PLAYER\M_PLAYER.PRG"
		else
		OUTPUT "F:\ANIM\M_PLAYER\MPLYR_EB.PRG"
		endif
	else
		OUTPUT "F:\ANIM\M_PLAYER\MPLYR_SW.PRG"
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

; converts a beautiful 16bit NOVA pixel into an ugly Falcon one (for cram)
FALC16 MACRO
	ror #5,\1
	lsr.b #1,\1
	roxr #2,\1
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
	move.b (a1,\1.w),\1
	ENDM

; for unregistered mode only

TO_GREY_16 MACRO
	ror #8,\1
	bclr #15,\1
	move (a1,\1.w*2),\1
	ENDM
	
RPZA	MACRO
	move.l (a2)+,d1
	if falc=2
		swap d1
		bclr #15,d1
		move.b (a1,d1.w),(a3)+
		swap d1
		bclr #15,d1
		move.b (a1,d1.w),(a3)+
	else	
	if REG=1
		ror #8,d1
		if (falc=1)|(falc=3)
			FALC16 d1
			if falc=3
				ror #8,d1
			endif
		endif
		swap d1
		ror #8,d1
		if (falc=1)|(falc=3)
			FALC16 d1
			if falc=3
				ror #8,d1
			endif
		endif
		swap d1
	else
		bclr #15,d1
		move (a1,d1.w*2),d1
		swap d1
		bclr #15,d1
		move (a1,d1.w*2),d1
		swap d1
	endif
	move.l d1,(a3)+
	endif
	ENDM

splice	MACRO  ; data1,data2,mask,temp,imm
	move.l \2,\4
	lsr.l #\5,\4
	eor.l \1,\4
	and.l \3,\4
	eor.l \4,\1
	lsl.l #\5,\4
	eor.l \4,\2
	ENDM
	
sp_16 MACRO
	move.\0 \2,d7
	lsr.\0 #\3,d7
	eor.\0 \1,d7
	and.\0 d0,d7
	eor.\0 d7,\1
	lsl.\0 #\3,d7
	eor.\0 d7,\2
	ENDM

AUD_CALC_DVI MACRO
   ADD \2,\2
   AND #$1F,\2			;delta (magnitude)
   MOVE \3,D0
   ASL #5,D0
   OR \2,D0				;B4:signe B3:pas B2:1/2 pas B1:1/4 pas  +1/8 pas
   ADD (a1,D0),\1		;+ pas
   BVC.S *+14
   BPL.S *+8
   MOVE #32767,\1
   BRA.S *+6
	MOVE #-32768,\1	;‚crˆtage
	ADD (a0,\2),\3	;nouvelle valeur d'index
   BPL.S *+6
   CLR \3
	BRA.S *+12
	CMP #88,\3
   BLS.S *+6
   MOVE #88,\3
	ENDM
		
	text
	
	; **************** Several Initialisations **********************

	bra.l skip_iv32
	
real_freq_tab:
	dc.l 12585,25169,50337
	dc.l 12929,24585,49170
	
IV_SIZE equ 94208		; size when decrunch	
_iv32: 
	if CDEB=0
	INCBIN "IV32TAB.BIN"
	else
	dc.b 5
	endif
	even
	
_mpeg:
	if MARTIN=1
		INCBIN "MPEG.PRG"
	else
		INCBIN "DECODEUR.PRG"
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
_menu_nom: dc.b "  M_Player V"
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
   GEM_AES graf_mouse			; the busy_bee
   GEM_AES graf_hand
   move intout,aes_handle
   move intout+8,boxh			; height of one char

	GEM_AES shel_find
	GEM_AES rsrc_load
	tst intout
	bne.s .lb1 
	pea no_rsc
	bsr.l alert
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
	
	sf nova							; default is not NOVA
	sf is_tt							; and no basic tt
	clr.l ed_adr					; no VDI extension
	pea cookie						; cookies+ kbshift address
	XBIOS 38,6						; supexec
	
	move.l ed_adr,d0
	beq.s .no_Xvdi
	move.l d0,a0
	moveq #0,d0						; function 0
	jsr (a0)							; EdDI
	cmp #$101,d0
	spl ed_adr						; if +, Real X present
	bmi.s .no_Xvdi					; else skip
	GEM_VDI vq_extnd2
	move cvid_fix0+10,ed_adr+2	; real X (in bytes)
.no_Xvdi:	
	move.b ([kbshift]),d0
	and.b #3,d0						; one of the shift keys?
	beq.s .no_shift
	and.b #1,d0						; le droit?
	sne psnd_flag					; alors forcer la carte parallele!!!
	move.b #1,snd_value+3		; simulates only Yamaha
.no_shift:
	lea snd_value,a0
	btst #2,3(a0)
	beq.s .no_falc_snd
	
	lea real_freq_tab,a0
	move.l 12(a0),(a0)+
	move.l 12(a0),(a0)+
	move.l 12(a0),(a0)
	
	move.w	#$1,-(sp)			; FPATCH2
	clr.l	-(sp)		
	move.w	#$8,-(sp)		
	clr.w	-(sp)		
	move.w	#139,-(sp)		
	trap	#$E
	lea	$C(sp),sp		

	clr.w	-(sp)	
	move.w	#132,-(sp)	
	trap	#$E		
	addq.l	#4,sp	

	move.w	#$40,-(sp)		
	move.w	#$2,-(sp)	
	move.w	#130,-(sp)		
	trap	#$E
			
	move.w	#$3,$2(sp)		
	trap	#$E		
	addq.l	#6,sp	

	move.w	#$3,-(sp)		
	move.w	#$6,-(sp)
	move.w	#$130,-(sp)		
	trap	#$E
	
	move.w	#$4,$2(sp)		
	trap	#$E	
	
	move.w	#$5,$2(sp)	
	trap	#$E		
	addq.l	#6,sp
	lea snd_value,a0
	
.no_falc_snd:	
	btst #1,3(a0)					; dma sound?
	sne (a0)							; snd_value=FF for DMA, 0 for no DMA
	bne.s .found_sound
	btst #0,3(a0)					; else, Yamaha?
	beq.s .found_sound
	move.b #1,(a0)					; 1=Yamaha
	
.found_sound:
	XBIOS 3,2						; logbase
	move.l d0,old_screen
	move.l d0,physbase			; to act like a TT for FLM (example)
	swap d0
	and #$FF00,d0					; the upper byte only
	cmp #$FE00,d0					; into the VME addressable area?
	bne.s .lb0
	st nova							; yes, consider it as a graphic card!
.lb0:
	
	sf res_switch					; default is no resolution switch allowed
	tst.b nova						; a graphic card?
	bne.s .lb1						; yes, no switch
	cmp.l #$30000,vdo_value
	bmi.s .lb2						; at least a falcon video unit?
	st res_switch					; everything is ok, switch allowed
	move #-1,-(sp)
	XBIOS 88,4
	move d0,old_video
	move d0,-(sp)
	XBIOS 91,4
	move.l d0,old_size
	bra.s .lb1

.lb2:
	cmp.l #$20000,vdo_value		; a TT video unit???
	bne.s .lb1						; no!
	XBIOS 4,2						; get rez
	move d0,old_video
	move.b #$7f,res_switch		; true but positive
	st is_tt

.lb1:
	move #-1,mov_h					; a negative handle if no file opened
	
	GEM_VDI vq_extnd
	move.w intout+8,d0			; number of planes
	move d0,planes
	moveq #0,d1
	move ed_adr+2,d1				; width in bytes or dum
	beq.s .nook
	bmi.s .nook
	lsl.l #3,d1						; number of bits
	divs d0,d1						; number of pixels
	move d1,ed_adr+2
	moveq #1,d2
	add work_out,d2				; vdi X
	cmp d2,d1
	bpl.s .ook
.nook:
	sf ed_adr	
.ook:
	bsr.l window_use
	move planes,d0
	cmp #16,d0						; High color?
	bne.s .lb11
	cmp #3,is_65k
	sne is_65k						; $FF if high color and not mode=3
.lb11:
	
	GEM_VDI hide_mouse
	
	tst.b acc
	beq.s .lb3
	
	bsr.l save_menu					; saves the menu_bar if accessory
	
.lb3:	
	move.l #work_out,vq_extnd+12
	clr ve_int

	move planes,d0
	cmp #15,d0						; 32768 colors
	beq.s good2
	cmp #16,d0						; 65536 colors
	bne.s not_tc
	
good2:
	sf res_switch					; if in TC, don't change!
	tst.b nova
	bne.s _nova
	if REG=1
		bsr.l falcon_adapt					; hc maps for the Falcon
	else
		bsr.l adapt_256
	endif
	bra next


appl_init: dc.l ai_cont,global,dum,appl_id,dum,dum
ai_cont: dc.w 10,0,1,0,0
appl_id: dc.w 0

   
_nova:
	if REG=1
		bsr.l nova_adapt						; hc maps for the NOVA card
	else
		bsr.l adapt_256
	endif	
	bra next


form_dial: dc.l fd_cont,global,fd_int,dum,dum,dum
fd_cont: dc.w 51,9,0,1,0
fd_int: dc.w 0,0,0,0,0,0,0,640,480	


not_tc:
	bsr.l save_256					; saves the desktop color registers	

	cmp #8,planes
	bne.s other

	tst.b nova						; 256 colors only with a NOVA card
	bne.s good
other:
	tst.b res_switch
	bne.s good3						; or if we can switch to TC, that's ok
	pea bad_card
	bsr.l alert
	bra end_end
good3:
	bpl.s good4						; if >0 TT video
	move planes,planes_sav		; if a Falcon (we can switch to TC
	move #16,planes				; prepares 16 bits
	if REG=1
		bsr.l falcon_adapt
	else
		bsr.l adapt_256
	endif
	move planes_sav,planes		; comes back
	bra.s next
good4:
	move planes,planes_sav		; for a TT, always 256 colors
	move #8,planes
	bsr.l adapt_256
	move planes_sav,planes
	bra.s next
good:
	bsr.l adapt_256
	
next:
	; ****************** loads the resource file ****************
	
	tst.b rsc
	bne .lb4
	
	moveq #2,d0
	move.l d0,rg_int
	GEM_AES rsrc_gaddr	; info box
	move.l tree,a0
	bsr.l add_version_number
	moveq #4,d0
	move.l d0,rg_int	; menu adr
	GEM_AES rsrc_gaddr
	move.l tree,menu_tree
	clr.l rg_int		; first tree
	GEM_AES rsrc_gaddr
	move.l tree,a1
	bsr.l treat_w_button
	st can_step
	cmp #16,planes		; TC, ok for step mode
	beq.s .lb3
	tst.b res_switch	; or we can go into TC mode? Ok
	bmi.s .lb3
	sf can_step			; else, no step mode (256 colors on NOVA or TT)

	; ****************** looks for a command line upon entry ****

.lb3:	
	cmp #4,planes						; monochrome or 4 colors?
	bpl.s .lb4
	bsr adapt_rsc_colors				; yes, change to B&W
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
	clr.b 0(a5,d0.w)				; ends the command line
	
.lb6:	
	lea cmd_dial,a0
	move.l #$ffffff00,(a0)+		; set the default four flags
	clr.w (a0)+						; and the fifth and sixth
	clr.w (a0)						; and 7th + 8th
	bsr.l parse_command_line
	
	lea cmd_coord,a0
	cmp.b #$FF,(a0)
	bne.s .clear_coord			; no coords (or just one)
	tst.b cmd_dial
	beq.s .keep_coord				; if no dialogs, coords allowed
.clear_coord:
	clr.b (a0)
.keep_coord:
	tst.b (a0)
	beq.s .no_change_win
	sf can_win						; if coords, don't add a window!!
	move.l DVI_DELTA,a0
	or.b #$08,(a0)					; disabled
	and.b #$0F,(a0)				; not selected	
.no_change_win:
	tst.b cmd_dial
	bne verify
	tst.b cmd_inter
	beq verify						; jumps if dial or if no hard interrupt
	bsr.l install_vectors
	
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
	bsr.l displ_info
	
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
	
	move.l #'\*.*',(a4)+
	clr.b (a4)
	
	lea path,a4
	lea tga_path,a0
	lea avr_path,a1
.aaa:
	move.b (a4),(a0)+
	move.b (a4)+,(a1)+
	bne.s .aaa				; copies the path into the tga path and avr path

	; ********************* the file selector *******************
	
again:
;	move.l #-1,-(sp)
;	GEMDOS $48,6
;	move.l #29646,a0
;.truv:
;	movem.l (a0)+,d0-d3
;	cmp.l #$2000,d0
;	bmi.s .suite
;	move.l d0,a0
;	bra.s .truv
;.suite:

	clr mf_int
	GEM_AES graf_mouse				; the arrow
	GEM_VDI show_mouse	
	GEM_AES fileselect				; to select a MOV or quit (Abort button)
	move.b ([kbshift]),etat_sav
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
	bsr.l redraw
	
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
	btst #3,etat_sav					; si CONTROL, c'est un "parse disk"
	bne.s .glue
	pea dta
	GEMDOS 26,6						; fixes my own DTA
	move #1,-(sp)						; normal+read_only files	
	pea full
	GEMDOS 78,8							; search first
	lea exist_error,a0
	tst d0
	bpl.s next_file
	bra.l ooops							; non, erreur
.glue:
	moveq #0,d0
	lea start_zero,a0					; datas that must be 0 at start
	lea end_zero,a1
.lb3:
	move.l d0,(a0)+					; zero a long word
	cmp.l a1,a0							; have we finished?
	bmi.s .lb3							; not yet
	st is_parse
	bsr.l parse_disk						; oui! lancer recherche.
	bra.l end_of_display

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

	sf is_win
	moveq #0,d0
	lea start_zero,a0					; datas that must be 0 at start
	lea end_zero,a1
lb3:
	move.l d0,(a0)+					; zero a long word
	cmp.l a1,a0							; have we finished?
	bmi.s lb3							; not yet
	
	move.l #yamaha_dum,yamaha_ptr
	
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
	
	bsr.l bat_read_header
	beq is_bat
	
	bsr.l mpg_read_header
	beq is_mpg

	if CDEB=0	
	bsr.l seq_read_header
	beq is_seq
	
	bsr.l kin_read_header
	beq is_kin
	
	bsr.l dlt_read_header
	beq is_dlt
	endif
	
	bsr.l flm_read_header
	beq is_flm
	bmi is_xflm
	
	bsr.l gif_read_header
	beq is_gif
	
	if CDEB=0
	bsr.l mvi_read_header
	beq is_mvi
	
	bsr.l dl_read_header
	beq is_dl
	
	bsr.l vmas_read_header
	beq is_vmas
	
	bsr.l cd_read_header
	beq is_cd
	endif
	
	; ******************* else, it's an error *******************************

	tst.b cmd_return
	beq.s .lb0
	move.l cmd_return_adr,a0
	move #-1,(a0)+		; unknown
	lea dta+30,a1
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1),(a0)+
	clr (a0)
.lb0:		
	lea format_error,a0
	bra.l ooops

is_mvi:
	move.l #mvi_title,a3	
	bra.s mas_mvi	

is_vmas:
	move.l #vmas_title,a3
mas_mvi:
	moveq #1+4,d3		; se fier a can step
	bsr.l principal
	tst.b stopped
	bne end_of_display	
	cmp.l #'mvi ',comp_txt
	beq .mvi
	tst.b can_step
	beq.s .no_step
	btst #3,([kbshift])
	sne step_mode
	beq.s .no_step
	move.l _delay,d0
	lsr.l #2,d0
	move.l d0,_delay
	moveq #3,d7
	bsr.l init_step_mode
	beq end_of_display
.no_step:
	bsr.l init_rect
	move.l max_fsize,d1
	bsr.l malloc
	move.l d0,buffer	
	move.l tree_sav,a0
	btst #0,299(a0)
	bne.s .sync
	clr.l _delay
.sync:
	btst #0,275(a0)
	beq.s .no_sound
	bsr.l vmas_read_sound
.no_sound:
	bsr.l set_video
	bsr.l _run_m_player
	bsr.l vmas_read_data
	bra end_of_display	
.mvi:
	move.l tree_sav,a0
	btst #0,275(a0)
	beq end_of_display
	move.l snd_size,d4
	bsr.l adapt_d4_size
	move.l _freq_sav,d3
	add.l d3,d3
	add.l d3,d3
	divs.l #5,d3			; 80% of one second
	addq.l #5,d3			; plus the offset
	st mvi_flag
	bsr.l read_sound
	bsr.l mvi_read_data
	bra end_of_display

is_dl:
	move.l #dl_title,a3
	moveq #-4,d3
	bra.s _ks_com
	
is_flm:
	move.l #flm_title,a3
	bra.s ks_com

is_dlt:
	move.l #dlt_title,a3
	bra.s ks_com
	
is_kin:
	move.l #kin_title,a3
	bra.s ks_com
	
is_seq:
	move.l #seq_title,a3
	
ks_com:
	moveq #0,d3
_ks_com:
	bpl.s .posit
	st group_step
	neg.l d3
.posit:
	bsr.l principal
	bsr remet_play_sound
	bne end_of_display	; cancel button
	btst #0,299(a0)
	bne.s .lb4
	clr.l _delay			; no delay if max_speed set!
.lb4:
	tst.b group_step
	beq.s .no_step2
	tst.b can_step
	beq.s .no_step
	btst #3,([kbshift])
	sne step_mode
.no_step:
	bsr clear_alt
	tst.b step_mode
	beq.s .no_step2
	moveq #-1,d7
	bsr.l init_step_mode
	beq end_of_display
.no_step2:
	bsr.l init_rect
	move.l comp_txt,d1
	cmp.l #'seq4',d1
	bne.s .other
	move.l max_fsize,d1
	bsr.l malloc
	move.l d0,buffer
	move.l #32000,d1
	bsr.l malloc
	move.l d0,s_buffer
	move.l #64000,d1
	bsr.l malloc
	move.l d0,s_buffer_2
	bsr.l set_video
	bsr.l seq_read_data	
.lb3:
	bra end_of_display
.other:
	cmp.l #'kin4',d1
	bne.s .other2
	move.l max_fsize,d1
	bsr.l malloc
	move.l d0,buffer
	bsr.l set_video
	bsr.l kin_read_data
	bra end_of_display
.other2:
	cmp.l #'dlt4',d1
	bne.s .other3
	move.l physbase,buffer
	tst.b is_tt
	bne.s .tt_dlt
	move.l max_fsize,d1
	bsr.l malloc
	move.l d0,buffer
.tt_dlt:
	bsr.l set_video	
	bsr.l dlt_read_data
	tst.b is_tt
	beq end_of_display
	clr.l buffer			; it was not allocated (the real screen)
	bra end_of_display
.other3:
	move.b #'0',d1
	cmp.l #'flm0',d1
	bne.s .other4
	tst.b bad_comp
	bne end_of_display		; unsupported resolution
	move.l physbase,s_buffer
	tst.b is_tt
	bne.s .tt_flm				; TT without NOVA
	move.l tt_screen_size,d1
	bsr.l malloc
	move.l d0,s_buffer
.tt_flm:
	move.l tt_flag_size,d1
	bsr.l malloc
	move.l d0,s_buffer_2		; flags for words that changed
	move.l max_fsize,d1
	bsr.l malloc
	move.l d0,buffer
	bsr.l set_video
	bsr.l flm_read_data
	bra end_of_display
.other4:
	move.l max_fsize,d1
	bsr.l malloc
	move.l d0,buffer			; all the screens!
	move.l sample_num,d1
	add.l d1,d1					; number of words
	bsr.l malloc
	move.l d0,s_buffer		; pointers to the images
	bsr.l load_dl_palette
	bsr.l load_dl_screens		; loads and converts 8bits to planes if TT
	bsr.l dl_frame_table
	bsr.l set_video
	lea cvid_fix1,a0			; the palette
	cmp #16,planes
	bne.s .not_tc
	lea cvid_fix0,a6
	bsr fli_color_64
	bra.s .dl_common
.not_tc:
	bsr fli_color_64_256
.dl_common:
	bsr.l _run_m_player
	bsr.l dl_read_data
	bra end_of_display	


hide_mouse: dc.l hm_cont,dum,dum,dum,dum

remet_play_sound:
	move.l tree_sav,a0
	move.l play_sav,324(a0)
	move.l sync_sav,348(a0)
	bclr #4,273(a0)
	bclr #4,297(a0)		; clears the radio flags
	tst.b stopped
	rts
	
is_xflm:
	move.l #xflm_title,a3
	moveq #1,d3
	bsr.l principal
	tst.b stopped
	bne end_of_display	
	move.l tree_sav,a0
	btst #0,299(a0)
	sne sync
	bsr.l init_rect
	move.l physbase,s_buffer
	tst is_tt
	bne.s .tt_flm				
	move.l tt_screen_size,d1
	bsr.l malloc
	move.l d0,s_buffer
.tt_flm:
	move.l tt_flag_size,d1
	bsr.l malloc
	move.l d0,s_buffer_2		; flags for words that changed
	move.l max_fsize,d1
	bsr.l malloc
	move.l d0,buffer
	bsr.l flm_read_sound
	bsr.l set_video
	bsr.l flm_read_data
	bra end_of_display	
	
	
hm_cont: dc.w 123,0,0,0,0,0,0,0,0,0,0,0

cd_nul: rts

is_cd:
	move.l #cd_title,a3
	moveq #1,d3
	bsr.l principal
	tst.b stopped
	bne end_of_display	
	move.l tree_sav,a0
	cmp.l #'CDA1',comp_txt
	beq .sound_file
	tst.b bad_comp
	bne.s .no_graph
	btst #0,299(a0)
	sne sync	
	bsr.l init_rect
	move.l max_fsize,d1
	addq.l #8,d1
	addq.l #8,d1
	bsr.l malloc
	move.l d0,buffer
	addq.l #8,d0
	addq.l #7,d0
	and.w #$FFF0,d0
	move.l d0,buffer_16
.no_graph:
	move.l tree_sav,a0
	btst #0,275(a0)
	beq.s .no_sound
	bsr.l cd_read_sound
.no_sound:
	tst.b bad_comp
	bne.s .lb4
	bsr.l set_video
	cmp.l #'CDL1',comp_txt
	bne.s .lb3
	bsr.l grey_mov
.lb3:
	cmp.l #'CDV1',comp_txt
	bne.s .lb4
	move.l #cvid_fix1,a0
	cmp #16,planes
	bne.s .lb5
	move.l #cvid_fix0,a6
	bsr.l fli_color_256
	bra.s .lb4
.lb5:
	bsr.l fli_color_256_256
.lb4:
	bsr.l cd_read_data
	bra end_of_display	
.sound_file:
	btst #0,275(a0)
	beq end_of_display
	move.l total,d0
	sub.l sound_seek,d0
	move.l d0,snd_size
	bsr.l cd_read_sound
	bsr.l cd_play_sound
	bra end_of_display

is_gif:
	move.l #gif_title,a3
	moveq #1+4,d3
	bra.s gm_comm

is_mpg:
	bsr.l mpg_parse_bin
	sf bad_comp
	move.l #mpg_title,a3
	moveq #0+4,d3
gm_comm:
	bsr.l principal
	cmp.l #'mpeg',comp_txt
	bne .lb3
	bsr remet_play_sound
	bne end_of_display
	tst.b can_step
	beq.s .no_step1
	btst #3,([kbshift])	; alt?
	sne step_mode
.no_step1:
	bsr clear_alt
	tst.b step_mode
	beq.s .lb4a
	moveq #-3,d7
	bsr.l init_step_mode
	beq end_of_display
.lb4a:
	tst.b is_tt
	bne.s .pas_buf
	move max_imagex,d1
	muls max_imagey,d1
	bsr.l malloc
	move.l d0,buffer	; pour le plan Y
.pas_buf:
	bsr.l init_rect
	bsr.l set_video
	if REG=1
		cmp #16,planes
		bne.s .fast
		tst.b fast_mode
		beq.s .col
	.fast:
	endif
	move #8,grey_depth
	move.l #'INVE',d0
	bsr.l grey_mov	
.col:
	bsr.l mpg_read_data
	bra end_of_display
.lb3:
	tst.b stopped
	bne end_of_display
	move.l tree_sav,a0
	moveq #0,d0			; no delay (default)
	btst #0,299(a0)
	beq.s .no_del
	moveq #-1,d0
.no_del:
	move.l d0,_delay	; -1 if delay accepted, 0 if no delay wanted...
	beq.s .no_step2
	tst.b can_step
	beq.s .no_step
	btst #3,([kbshift])
	sne step_mode
.no_step:
	bsr clear_alt
	move.l total,d1
	addq.l #2,d1		; 0 plus $3B
	bsr.l malloc
	move.l d0,buffer
	tst.b step_mode
	beq.s .no_step2
	moveq #-2,d7
	bsr.l init_step_mode
	beq end_of_display
.no_step2:	
	bsr.l init_rect
	move.l #4*4096,d1
	moveq #0,d0
	move max_imagex,d0
	add.l d0,d1
	bsr.l malloc
	move.l d0,hc_cvid	; bloc for the LZW codes, plus one line
	bsr.l set_video		; other mallocs possible
	bsr.l _run_m_player
	bsr.l gif_read_data
	bra end_of_display
	
is_bat:
	lea add_digit-5,a0
	move.l #'0000',(a0)+
	move #'00',(a0)			; resets to 0 the text displayed
	moveq #0,d3
	move.l #bat_title,a3
	tst.b create_mov
	beq.s .lb0
	bmi.s .lb0a
	move.l #bat_title_gif,a3
	moveq #2,d3					; toujours Alt Go
	bra.s .lb0
.lb0a:
	moveq #2,d3
	move.l #bat_title_avi,a3
	tst.b create_avi
	bne.s .lb0
	move.l #bat_title_flm,a3
	tst.b slide_degas
	bne.s .lb0
	move.l #bat_title_create,a3
.lb0:
	bsr.l principal
	beq.s .lb2a
	btst #3,([kbshift])
	bne.s .lb2b
	sf create_mov		; create mode must be confirmed by 'Alt'
.lb2b:
	bsr clear_alt
	tst.b create_mov
	beq.s .lb2a
	move planes,planes_sav
	move #16,planes
	tst.b bad_sound
	bne .lb3c
	bsr.l init_create
	clr.l _delay		; no synchro!
	bra.s .lb2c
.lb2a:
	tst.b slide_gif
	beq.s .lb2c
	move.l #4*4096,d1
	moveq #0,d0
	move max_imagex,d0
	add.l d0,d1
	bsr.l malloc
	move.l d0,hc_cvid	; bloc for the LZW codes, plus one line
.lb2c:
	bsr remet_play_sound
	bne end_of_display
	btst #0,275(a0)
	beq.s .lb4
	clr.l _delay			; no delay if max_speed set!
.lb4:
	bsr.l init_rect
	move.l max_fsize,d1
	add.l tgac_offset,d1	; en cas de compression
	bsr.l malloc
	move.l d0,buffer
	add.l neo_degas_offs,d0			; for degas,neo
	move.l d0,_flm_phys	; for degas,neo (if used)
	tst.b create_mov
	beq.s .lb4a
	tst.b slide_gif
	bne.s .lb3d				; no need to decompress for GIF!
	tst.b slide_degas
	bne.s .lb3d
	move max_imagex,d0
	addq #3,d0
	and.b #$FC,d0
	move d0,screenw		; 4 pixels aligned
	move max_imagey,screenh
	clr offsx
	clr offsy
	move.l one_buffer,image
	move.l #_comp,compression
.lb3d:
	tst.b _conv_video
	beq.s .lb3a
	st switched
	bsr.l sv_falcon		; au cas ou M_PLAYER fils doit changer RES
	bra.s .lb3a
.lb4a:
	bsr.l set_video			; clears screen and switch to TC
	cmp #8,planes
	bne.s .lb3a
	bsr.l set_colors		; the 256 grey colors
.lb3a:
	bsr.l bat_read_data
	tst.b create_mov
	beq end_of_display
	bsr.l save_header
.lb3c:
	move planes_sav,planes
	bra end_of_display					; the common end for QT and AVI and FLI
	
is_fli:
	move.l #fli_title,a3
	moveq #0+4,d3
	bsr.l principal
	beq.s .no_step
	tst.b can_step
	beq.s .no_step
	btst #3,([kbshift])
	sne step_mode
.no_step:
	bsr clear_alt
	bsr remet_play_sound
	bne end_of_display	; cancel button
	btst #0,299(a0)
	bne.s .lb4
	clr.l _delay			; no delay if max_speed set!
.lb4:
	tst.b step_mode
	beq.s .aaa
	moveq #0,d7
	bsr.l init_step_mode
	beq end_of_display
.aaa:	
	bsr.l init_rect
	move.l max_fsize,d1
	bsr.l malloc
	move.l d0,buffer
	bsr.l set_video			; clears screen and switch to TC
	cmp #8,planes
	bne.s .lb3
	cmp.l #'flh ',comp_txt
	bne.s .lb3a
	bsr.l set_colors			; flh is TC, so grey display in 256 colors
.lb3a:
	bsr fli_read_data_256
	bra end_of_display	
.lb3:
	bsr.l _run_m_player
	bsr fli_read_data
	bra end_of_display					; the common end for QT and AVI and FLI

treat_control:
	btst #2,([kbshift])
	beq.s .fin
	move #7,-(sp)
	move #2,-(sp)
	BIOS 3,6				; cloche!
	move.l #$00020002,-(sp)
	trap #13
	addq.l #4,sp		; lit un caractere
	sub.b #'0',d0
	bls.s .fin			; 0 ou moins refus‚
	cmp.b #10,d0
	bpl.s .fin			; 10 ou plus refus‚
	move.b d0,iv32_freq
.fin:
	rts
	

is_avi:
	bsr avi_parse_chunks					; reads the header and 'idx1' bloc
	move.l #avi_title,a3
	moveq #1+4,d3
	move.l #'rawa',s_signe	; AVI sounds are supposed to be unsigned
	bsr.l principal
	beq end_of_display
	tst.b bad_comp
	bne.s .lb6			; no graphics
	bsr treat_control
	tst.b can_step
	beq.s .no_step
	btst #3,([kbshift])	; alt?
	sne step_mode
.no_step:
	bsr clear_alt
	tst.b no_idx1
	beq.s .suite
	bsr avi_build_table	; pas de table, il faut la construire!!	
.suite:
	tst.b step_mode
	beq.s .lb4a
	moveq #1,d7
	bsr.l init_step_mode
	beq end_of_display
.lb4a:
	bsr.l init_rect
	move.l max_fsize,d1
	bsr.l malloc
	move.l d0,buffer	
.lb6:
	tst.b step_mode
	bne.s .lb4b			; no sound needed
	tst.b bad_sound	; bad sound, don't treat
	bne.s .lb4
	tst.l sound_num	; no sound anyway
	beq.s .lb4
	move.l snd_temp_size,d3
	move.l snd_size,d4
	bsr.l adapt_d4_size	; and eventually D3 if ima4!!!
	move.l tree_sav,a0
	btst #0,275(a0)
	beq.s .lb4
	bsr.l read_sound
.lb4:
	bsr avi_sync_tab
.lb4b:
	bsr.l set_video
	move.l mapused,d0
	lea cvid_fix1,a0
	cmp #8,planes
	bne.s .lb9
	tst.l d0
	beq.s .lb8
	bsr fli_color_256_256	; the palette into VDI registers
	bra.s .lb3
.lb8:
	bsr.l set_colors
	bra.s .lb3
.lb9:
	tst.l d0
	beq.s .lb3
	lea cvid_fix0,a6
	bsr fli_color_256			; the palette into a table
.lb3:
	bsr.l _run_m_player
	bsr avi_read_data

	bra end_of_display					; the common end for QT and AVI
	
	
v_bar: dc.l vb_cont,dum,bar_pts,dum,dum
vb_cont: dc.w 11,2,0,0,0,1,0,0,0,0,0,0

clear_alt:
	tst.b command
	beq.s .end
	tst.b cmd_alt
	beq.s .end
	bclr #3,([kbshift])	; we set this bit if command and cmd_alt
.end:
	rts


; here, treats the case of a QT MOV file

is_mov:
	
	; *************** read infos to prepare decrunch **********************	
	move.l #id_table,id_ptr			; list of IDs (CVID, etc...)
	bsr qt_parse_chunks				; reads the frames info and fills some
											; arrays
	lea id_table,a0
	move.l (a0)+,comp_txt		; back to the first ID
	move.b (a0),qt_palette
	
	move.l #qt_title,a3	; the type of file
	tst.b vr_flag
	beq.s .lb0
	move.l #vr_title,a3
.lb0:
	moveq #1+4,d3
	bsr.l principal
	beq end_of_display
	bra im_lb2			; no, so it's the 'Go!' button
	

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
	clr -(sp)				; ST ram only
	move.l d7,-(sp)
	GEMDOS $44,8			; mxalloc
	tst.l d0
	bmi.s .end				; alloc error
	beq.s .end
	move.l d0,snd_temp
	move.l d0,d6
	movem.l d6-d7,-(sp)
	moveq #1,d6
	moveq #1,d7
	bsr.l manage_tree
	movem.l (sp)+,d6-d7
	SEEK flm_snd_pos,0
	move.l d6,d0
	add.l d7,d0
	move.l d0,flm_snd_end
	move.l d6,-(sp)
	move.l d7,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; reads the whole sound into memory
	tst.b snd_value
	bmi.s .dma
	bsr.s adapt_sound
.dma:
	moveq #1,d6
	moveq #-1,d7
	bsr.l manage_tree
	st playing
.end:
	rts

sm_cont: dc.w 122,0,0,1,0,0,0,0,0,0,0,0
sm_int: dc.w 0

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
	
	
im_lb2:
	bsr treat_control
	tst.b can_step
	beq.s .no_step
	btst #3,([kbshift])		; alt key?
	sne step_mode
.no_step:
	bsr clear_alt
	bsr.l treat_vr_box
	cmp #12,d6
	beq end_of_display
	tst.b step_mode
	beq.s .kk2
	moveq #2,d7
	bsr.l init_step_mode
	beq end_of_display
.kk2:
	move.l samp_sizes,a0
	cmp.l #0,a0
	beq.s no_graph
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
mf_int: dc.w 0
mouse_def: dc.l 0


lb5:
	move.l d0,max_fsize		; keeps the max size
	move.l d0,d1
	bsr.l malloc					; and allocates the buffer
	move.l d0,buffer			; the address
	

	bsr.l init_rect		; the movie rectangle, the screen adr, etc...
	bra.s kkk
	
	
appl_exit: dc.l ae_cont,global,dum,intout,dum,dum
ae_cont: dc.w 19,0,1,0,0


no_graph:
	GEM_VDI hide_mouse
kkk:
	tst.b step_mode
	bne.s .kk3
	bsr.l init_sound
.kk3:
	tst.b vr2_flag
	beq.s .no_more_buffers
	bsr alloc_vr2_buf
.no_more_buffers:
	bsr.l set_video
	tst.b qt_palette
	beq.s .lb0
	tst.b is_grey
	beq.s .color
	bsr.l grey_mov
	bra.s .lb3
.color:
	move.l pal_adr,a0
	cmp #8,planes
	bne.s .zzz
	bsr fli_color_256_256
	bra.s .lb3
.zzz:
	lea cvid_fix0,a6
	bsr fli_color_256
	bra.s .lb3
.lb0:
	cmp #8,planes
	bne.s .lb3
	bsr.l set_colors		; the 256 grey colors
.lb3:
	bsr.l _run_m_player
	bsr qt_read_data	; reads and displays the QT MOV file

end_of_display:
	move.l tga10_buff,a2
	bsr.l mfree
	move.l tga_buff,a2
	bsr.l mfree
	move.l top_lines_buff,a2
	bsr.l mfree				; lignes d'ecran a sauvegarder.
	move.l bat_text,a2	; ou iv32 buffer
	bsr.l mfree
	move.l buffer,a2
	bsr.l mfree				; frees the buffer
	move.l s_buffer,a2
	bsr.l mfree				; desallocates the big buffers before using AES
	move.l s_buffer_2,a2
	bsr.l mfree
	move.l snd_temp,a2
	bsr.l mfree

	tst.b is_tt
	beq.s .lb3
	move.l image,a2		; on a TT, a virtual buffer as video ram
	bsr.l mfree
.lb3:
	tst.b is_win
	beq.s .lb20
	GEM_AES wind_close
	GEM_AES wind_delete
	bra.s .lb5
	
.lb20:
	tst.b switched
	beq.s .lb2
	
	bsr.l restore_video
	GEM_VDI vq_extnd		; fills again work_out
	move planes_sav,planes

.lb2:
	tst.b slide_flag
	bne.s .lb5
	move #3,fd_int
	GEM_AES form_dial		; screen updates
.lb5:
	sf display

	bsr.l redraw

	cmp #16,planes
	beq.s .lb4
	bsr.l restore_256		; back to the desktop colors

.lb4:

	bsr.l redraw_menu
	
	tst.b stopped
	bne.s .lb0				; stopped, no general stats displayed
	tst.l samp_sizes
	beq.s .lb0				; no graphics, so no stats about graphics...
	tst.b bad_comp			; graphics played?
	bne.s .lb0				; no, because of the bad_compresion
	tst.b step_mode		; step mode?
	bne.s .lb0				; yes, no time stats
	
	bsr.l fill_stat		; renvoit dans D6 le bon arbre (3 ou 9)
	moveq #0,d7
	bsr.l manage_tree
	st stopped				; if stat box, don't show alert 'Everything is Ok'
	
.lb0:
	tst.b slide_flag
	bne.s end
	GEM_VDI show_mouse	; the mouse is back
	
	tst.b command			; with a command line, no alert boxes
	bne.s end
	tst.b stopped			; if movie stopped (Control key), not that box
	bne.s end
	
	pea ok					; tells that everything is OK
	bsr.l alert

	
	; *************** closes the file and restarts ************************
	; *************** frees memory too ************************************
end:
	move.l vr2_temp,a2
	bsr.l mfree
	move.l hc_cvid,a2
	bsr.l mfree
	move.l codecs,a2
	bsr.l mfree
	move.l samp_sizes,a2
	bsr.l mfree
	move.l t2samps,a2
	bsr.l mfree
	move.l s2chunks,a2
	bsr.l mfree
	move.l chunkoffs,a2
	bsr.l mfree
	move.l sound_offs,a2
	bsr.l mfree
	move.l ss_tab,a2
	bsr.l mfree
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

	bsr.l exit_menu
	
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
	tst.b slide_flag
	beq.s .lb0
	bra.l slide_next_file										
.lb0:
	
	tst.b cmd_dial
	bne.s end_end
	tst.b cmd_inter
	bne verify											

end_end:
	tst.b cmd_dial
	bne.s .lb0
	tst.b cmd_inter
	beq.s .lb0
	bsr.l restore_vectors
	tst.b inter_flag
	beq.s .lb0
	bclr #2,([kbshift])				; we simulated Control, so clear it
.lb0:
	GEM_VDI show_mouse				; the mouse is back
	GEM_VDI close_work				; byebye VDI
	
	move #2,wu_int
	GEM_AES wind_update
	
	tst.b acc
	beq.s .lb1							; not an acc, exit!
	
	move.l menu_buffer,a2
	bsr.l mfree							; frees the buffer
	bra acc_wait						; if an accessory, back to the loop
	
.lb1:
	GEM_AES rsrc_free
	GEM_AES appl_exit					; a hand-shaking to AES
	GEMDOS 0,2							; a kiss for GEMDOS
	
menu_bar: dc.l mb_cont,global,mb_int,dum,menu_tree,dum
mb_cont: dc.w 30,1,1,1,0
mb_int: dc.w 0

	; here, nothing can occur...	

alloc_vr2_buf:
	move max_imagex,d0
	muls max_imagey,d0
	cmp #16,planes
	bne.s .lb0
	add.l d0,d0			; 2bytes/pixel
.lb0:
	move.l vr2_data+14,d1	; img/panneau
	move.l vr2_num,d2
	muls d1,d2					; total images
	move.l d2,sample_num
	muls.l d0,d1				; gros buffer circulaire
	move.l d0,d4				; saved
	add.l d0,d1					; ajoute!!!
	bsr.l malloc	
	move.l d0,vr2_temp		; une image
	add.l d4,d0
	move.l d0,vr2_panneau 	; le 360ø
	tst.b is_tt
	beq.s .pas_tt
	move.l image,vr2_image
	clr offsy
	clr offsx
	move alignwidth,screenw
	move vr2_y+2,screenh
	bra.s .common
.pas_tt:
	move.l physbase,a0
	move screenh,d0
	sub vr2_y+2,d0
	lsr #1,d0
	move d0,offsy
	move screenw,d1
	muls d1,d0
	sub vr2_x+2,d1
	lsr #1,d1
	ext.l d1
	move.l d1,offsx
	add.l d1,d0
	add.l d0,a0
	cmp #8,planes
	beq.s .ok
	add.l d0,a0
.ok:
	move.l a0,vr2_image
.common:
	movem.l vr2_data+6,d0/d1
	movem.l vr2_x,d2/d3
	exg.l d0,d1
	cmp #360,vr2_data	; angle horizontal
	seq vr_xloop
	sf vr_yloop
	tst.b vr_xloop		; pour l'instant
	bne.s .ok2
	sub.l d2,d0
.ok2:
	sub.l d3,d1
	movem.l d0/d1,vr2_maxx
	lsr.l #1,d1
	lsr.l #1,d0
	movem.l d0/d1,vr2_sx
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
	lsr.l #1,d0				; 1/512 of the size
	cmp.l d0,d1
	bpl.s .false			; difference is too high
	moveq #1,d7				; one pixel=one byte (fli,flc)
	move (a0)+,d0
	move 10(a0),d1			; time
	ror #8,d1
	cmp #$12af,d0
	bne.s .lb1
	move.l #'flc ',d0
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
	moveq #2,d7				; one pixel=2bytes
	bra.s .lb1a
.lb1b:
	cmp #$11af,d0		; magic
	bne.s .false
	move.l #'fli ',d0
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
	muls d7,d1				; x1 (fli,flc) or x2 (flh)
	muls d0,d1				; number of pixels = max number of bytes per image
	add.l #1000,d1			; plus the palette (768) and others
	move.l d1,d0
	lsr.l #4,d0				; 1/16
	add.l d0,d1				; size + 6.25% (in case of bad compressor)
	move.l d1,max_fsize  ; must be enough to store one frame at the time.
	moveq #0,d0
	st samp_sizes
	rts						; returns EQ

c256 set 0

	rept 2
	
	if c256=1
fli_read_data_256:
	addq.l #8,compression	; skips the start of routine
	addq.l #8,compression
	else
fli_read_data:
	tst.b step_mode
	bne.l fli_step_mode
	endif
	tst.b bad_comp
	beq.s .good
	st stopped
	rts
.good:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
.disp_again:
	SEEK #128,0
	clr.l disp_frame
	move.l sample_num,d7	; number of frames
	if c256=0
		lea cvid_fix0,a6		; as a buffer for the palette
	endif
	cmp.l #'flh ',comp_txt
	bne.s .palette_mode
	move.l hc_cvid,a6		; with FLH, it's a 16 bits mode
.palette_mode:
	move.l image,a5
	move.l buffer,a4
	move screenw,d3
	if c256=0
		add d3,d3				; to skip one line
	endif
	move.l $4ba.w,start_time
	move.l $4ba.w,current_time
	bra.s .little_header
.loop: 
	addq.l #1,disp_frame
	move.l intout,a3		; 16 bytes
	move.l (a3)+,d0
	INTEL d0					; size of the frame
	cmp #$faf1,(a3)+		; magic for a normal frame
	beq.s .normal
	subq.l #8,d0
	subq.l #8,d0
	SEEK d0,1				; else skips
.little_header:
	lea intout+4,a3
	move.l a3,-4(a3)
	pea (a3)					; as a buffer
	move.l #16,-(sp)		; the frame header
	move mov_h,-(sp)
	GEMDOS 63,12			; fread
	bra .next
.normal:
	move (a3),d6
	ror #8,d6				; number of chunks
	pea (a4)					; the buffer
	move.l d0,-(sp)		; the len to read + 16 bytes=next header
	lea -16(a4,d0.l),a0
	move.l a0,intout		; new little header
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
	if c256=1
		bsr fli_lc_256
		tst.b is_tt
		beq .lb4
		bsr to_planes
	else
		bsr fli_lc
	endif
	bra .lb4
.lb0:
	cmp #7,d0				; flc_lc
	bne.s .lb00
	if c256=1
		bsr flc_lc_256
		tst.b is_tt
		beq .lb4
		bsr to_planes
	else
		bsr flc_lc
	endif
	bra .lb4
.lb00:
	cmp #15,d0				; fli_brun
	bne.s .lb1
	if c256=1
		bsr fli_brun_256
		tst.b is_tt
		beq.s .lb4
		bsr to_planes
	else
		bsr fli_brun
	endif
	bra.s .lb4
.lb1:
	cmp #11,d0				; fli_color (64)
	bne.s .lb2
	if c256=1
		bsr fli_color_64_256
	else
		bsr fli_color_64
	endif
	bra.s .lb4
.lb2:
	cmp #4,d0				; flc_color (256)
	bne.s .lb20
	if c256=1
		bsr fli_color_256_256
	else
		bsr fli_color_256
	endif
	bra.s .lb4
.lb20:
	cmp #13,d0				; fli_black
	bne.s .lb3
	bsr fli_black
	bra.s .lb4
.lb3:
	cmp #16,d0				; fli_copy
	bne.s .lb3a
	if c256=1
		bsr fli_copy_256
		tst.b is_tt
		beq.s .lb4
		bsr to_planes
	else
		bsr fli_copy
	endif
	bra.s .lb4
.lb3a:
	cmp #27,d0
	bne.s .lb3b
	if c256=1
		bsr flh_delta_256
		tst.b is_tt
		beq.s .lb4
		bsr to_planes
	else
		if REG=0
			bsr flh_delta
		else
			tst.b nova
			beq.s .lb3c
			bsr flh_delta
			bra.s .lb4
		.lb3c:
			bsr flh_delta_falc
		endif
	endif
	bra.s .lb4
.lb3b:
	cmp #25,d0
	bne.s .lb4
	if c256=1
		bsr flh_brun_256
		tst.b is_tt
		beq.s .lb4
		bsr to_planes
	else
		if REG=0
			bsr flh_brun
		else
			tst.b nova
			beq.s .lb3d
			bsr flh_brun
			bra.s .lb4
		.lb3d:
			bsr flh_brun_falc
		endif
	endif
.lb4:
	move.l a1,a0			; unknow ID, just skip!
.ch_loop:
	dbf d6,.chunk
.next:
	btst #2,([kbshift])
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
	
	if c256=1
	
to_planes:
	movem.l a0-a4/d0-d7,-(sp)
	move flx_number,a3
	move flx_start,d0
	move.l compression,a0
	jsr (a0)
	movem.l (sp)+,a0-a4/d0-d7
	rts
		
	endif
	
	if c256=1
fli_brun_256:
	else
fli_brun:
	endif
	move max_imagey,d5		; number of lines to modify
	if c256=1
		move d5,flx_number
		clr flx_start
	endif
	move.l a5,a2				; screen pointer
	bra.s .l_loop
.line:
	lea (a2,d3.l),a3			; the next line in memory
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
	if c256=1
		move.b (a0)+,(a2)+
	else
		move.b (a0)+,d1
		move.w (a6,d1*2),(a2)+	; the color from the palette into the screen memory
	endif
.c_loop:
	dbf d0,.copy
	bra.s .b_loop
.repeat:
	move.b (a0)+,d1
	if c256=0
		move.w (a6,d1.w*2),d1	; the color to be repeated
	endif
	bra.s .lb2
.lb1:
	if c256=1
		move.b d1,(a2)+
	else
		move d1,(a2)+
	endif
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
	if c256=1
		move.b (a0)+,(a2)+
	else
		move.b (a0)+,d1
		move.w (a6,d1*2),(a2)+	; the color from the palette into the screen memory
	endif
.ap_c_loop:
	dbf d0,.ap_copy
	bra.s .ap_b_loop
.ap_repeat:
	sub d0,d4
	move.b (a0)+,d1
	if c256=0
		move.w (a6,d1.w*2),d1	; the color to be repeated
	endif
	bra.s .ap_lb2
.ap_lb1:
	if c256=1
		move.b d1,(a2)+
	else
		move d1,(a2)+
	endif
.ap_lb2:
	dbf d0,.ap_lb1
.ap_b_loop:
	tst d4
	bpl.s .ap_blocs
	bra.s .next_line


	if c256=1
flc_lc_256:
	else
flc_lc:
	endif
	moveq #0,d1					; to convert bytes to words
	move (a0)+,d5				; number of lines
	ror #8,d5
	if c256=1
		move #1,flx_number
		clr flx_start
		sf _disp
	endif
	move.l a5,a2				; screen pointer
	bra.s .l_loop
.line:
	lea (a2,d3.l),a3			; next line
.skip80:
	move (a0)+,d4
	cmp.b #$80,d4
	beq.s .skip80
	ror #8,d4					; number of blocs
	btst #14,d4
	beq.s .lb0
	eor #$ffff,d4
	if c256=1
		tst.b _disp
		bne.s .yet
		add d4,flx_number
	.yet:
	endif
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
	if c256=1
		lea (a2,d0.w),a2
	else
		lea (a2,d0.w*2),a2		; skips some pixels
	endif
	move.b (a0)+,d0
	cmp #$7f,d0
	bls.s .p2_loop
	sub #$100,d0
	neg d0
	if c256=1
		move.b (a0)+,d2
		lsl #8,d2
		move.b (a0)+,d2
	else
		move.b (a0)+,d1			; one color
		move (a6,d1.w*2),d2
		swap d2
		move.b (a0)+,d1			; second color
		move (a6,d1.w*2),d2		; two colors into d2.l
	endif
	bra.s .p_loop
.pixel:
	if c256=1
		move d2,(a2)+
	else
		move.l d2,(a2)+			; 2 colors
	endif
.p_loop:
	dbf d0,.pixel
	bra.s .b_loop
.pixel2:
	if c256=1
		move (a0)+,(a2)+	; 2 colors
	else
		move.b (a0)+,d1
		move (a6,d1.w*2),d2
		swap d2
		move.b (a0)+,d1
		move (a6,d1.w*2),d2
		move.l d2,(a2)+
	endif
.p2_loop:
	dbf d0,.pixel2
.b_loop:
	dbf d4,.blocs
.next:
	if c256=1
		tst.b _disp
		beq.s .yet2
		addq #1,flx_number
		.yet2:
	endif
	move.l a3,a2
.l_loop:
	dbf d5,.line
	move max_imagey,d0
	cmp flx_number,d0
	bpl.s .exit
	subq #1,flx_number
.exit:
	rts

	if c256=1
fli_lc_256:
	else
fli_lc:
	endif
	move (a0)+,d0
	ror #8,d0					; number of lines to skip
	move (a0)+,d5
	ror #8,d5					; number of lines to modify
	if c256=1
		move d0,flx_start
		move d5,flx_number
	endif
	move.l a5,a2				; screen pointer
	muls d3,d0
	add.l d0,a2					; points to the correct line
	bra.s .l_loop
.line:
	lea (a2,d3.l),a3			; the next line in memory
	moveq #0,d4					; number of blocs
	move.b (a0)+,d4
	bra.s .b_loop
.blocs:
	moveq #0,d0
	move.b (a0)+,d0			; number of pixels to skip
	if c256=1
		lea (a2,d0.w),a2
	else
		lea (a2,d0.w*2),a2		; skips the pixels
	endif
	moveq #0,d1
	moveq #0,d0
	move.b (a0)+,d0			; number of pixels
	cmp #$80,d0
	bpl.s .repeat
	bra.s .c_loop
.copy:
	if c256=1
		move.b (a0)+,(a2)+
	else
		move.b (a0)+,d1
		move.w (a6,d1.w*2),(a2)+	; the color from the palette into the screen memory
	endif
.c_loop:
	dbf d0,.copy
	bra.s .b_loop
.repeat:
	sub #$100,d0
	neg d0
	move.b (a0)+,d1
	if c256=0
		move.w (a6,d1.w*2),d1	; the color to be repeated
	endif
	bra.s .lb2
.lb1:
	if c256=1
		move.b d1,(a2)+
	else
		move d1,(a2)+
	endif
.lb2:
	dbf d0,.lb1
.b_loop:
	dbf d4,.blocs
	move.l a3,a2				; the next line
.l_loop:
	dbf d5,.line
	rts
	
	if c256=1
fli_copy_256:
	else
fli_copy:
	endif
	move.l a5,a2				; the image
	move max_imagey,d5		; number of lines
	if c256=1
		move d5,flx_number
		clr flx_start
	endif
	move max_imagex,d1
	moveq #0,d2
	bra.s .l_loop
.line:
	lea (a2,d3.l),a3			; the next line
	move d1,d4					; pixels per line
	bra.s .p_loop
.pixel:
	if c256=1
		move.b (a0)+,(a2)+
	else
		move.b (a0)+,d2
		move (a6,d2.w*2),(a2)+	; one pixel
	endif
.p_loop:
	dbf d4,.pixel
	move.l a3,a2				; next line
.l_loop:
	dbf d5,.line
	rts
	
c256 set 1+c256

	endr							; two types of fli routines (32k or 256c)


fli_color_64:
	move (a0)+,d0				; number of blocs
	ror #8,d0
	move.l a6,a2				; palette pointer
	move is_65k,d5
	move.b nova,d5				; NOVA or Falcon 16 bits
	bra.s .b_loop
.blocs:
	moveq #0,d1
	move.b (a0)+,d1			; number of colors to skip
	lea (a2,d1*2),a2			; jumps to the correct color
	move.b (a0)+,d1
	bne.s .col_loop
	move #255,d1				; if d1= it means 256 colors
.color:
	if REG=1
		move.b (a0)+,d2
		ror #7,d2
		and #$7c00,d2				; red
		move.b (a0)+,d4
		lsl #4,d4
		and #$3e0,d4			
		or d4,d2						; + green
		moveq #0,d4
		move.b (a0)+,d4
		lsr #1,d4
		or d4,d2						; + blue
	else
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
		add d4,d2					; brightness from 0 to 630
		divs #20,d2					; from 0 to 31
		move d2,d4
		lsl #5,d4
		or d4,d2
		lsl #5,d4
		or d4,d2
	endif		
	ror #8,d2					; to NOVA  format
	tst d5						; is_65k in upper byte
	bmi.s .lb00
	tst.b d5
	bne.s .lb0
.lb00:
	FALC16 d2
	tst d5
	bpl.s .lb0
	ror #8,d2
.lb0:
	move d2,(a2)+				; and into the palette
.col_loop:
	dbf d1,.color
.b_loop:
	dbf d0,.blocs
	rts		

fli_color_64_256:
	move (a0)+,d0				; number of blocs
	ror #8,d0
	tst.b is_tt					; because of NVDI
	bne .tt_pal
	lea indexs,a2
	bra.s .b_loop
.blocs:
	moveq #0,d1
	move.b (a0)+,d1			; number of colors to skip
	lea (a2,d1*2),a2			; jumps to the correct color
	move.b (a0)+,d1
	bne.s .col_loop
	move #255,d1				; if d1=0 it means 256 colors
.color:
	lea vs_int,a6
	move (a2)+,(a6)+			; color index
	if REG=1
		rept 3
			moveq #0,d2
			move.b (a0)+,d2
			lsl #4,d2					; 0-63 to 0-1008
			move d2,(a6)+
		endr
	else
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
		add d4,d2					; brightness from 0 to 630
		muls #100,d2
		divs #63,d2					; from 0 to 1000
		move d2,(a6)+
		move d2,(a6)+
		move d2,(a6)+
	endif
	movem.l d0-d1/a0-a2,-(sp)
	GEM_VDI vs_color
	movem.l (sp)+,d0-d1/a0-a2
.col_loop:
	dbf d1,.color
.b_loop:
	dbf d0,.blocs
	rts		
.tt_pal:
	move.l #0,a2
	bra.s .tt_b_loop
.tt_blocs:
	moveq #0,d1
	move.b (a0)+,d1			; number of colors to skip
	add d1,a2
	move.b (a0)+,d1
	bne.s .tt_col_loop
	move #255,d1				; if d1=0 it means 256 colors
.tt_color:
	if REG=1
		move.b (a0)+,d2
		lsl #6,d2
		move.b (a0)+,d2
		lsl.b #2,d2
		lsl #4,d2
		move.b (a0)+,d2
		lsl.b #2,d2
		lsr #4,d2
	else
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
		add d4,d2					; brightness from 0 to 630
		divs #40,d2					; from 0 to 15
		move d2,d4
		lsl #4,d4
		or d4,d2
		lsl #4,d4
		or d4,d2
	endif
	movem.l d0-d1/a0-a2,-(sp)
	move d2,-(sp)
	move a2,-(sp)
	XBIOS 83,6						; esetcolor
	movem.l (sp)+,d0-d1/a0-a2
	addq #1,a2
.tt_col_loop:
	dbf d1,.tt_color
.tt_b_loop:
	dbf d0,.tt_blocs
	rts		

	
fli_color_256:
	move (a0)+,d0				; number of blocs
	ror #8,d0
	move.l a6,a2				; palette pointer
	move is_65k,d5
	move.b nova,d5				; NOVA or Falcon 16 bits
	bra.s .b_loop
.blocs:
	moveq #0,d1
	move.b (a0)+,d1			; number of colors to skip
	lea (a2,d1*2),a2			; jumps to the correct color
	move.b (a0)+,d1
	bne.s .col_loop
	move #255,d1				; if d1=0 it means 256 colors
.color:
	if REG=1
		move.b (a0)+,d2
		lsl #7,d2
		and #$7c00,d2				; red
		move.b (a0)+,d4
		lsl #2,d4
		and #$3e0,d4			
		or d4,d2						; + green
		move.b (a0)+,d4
		lsr.b #3,d4
		or.b d4,d2					; + blue
	else
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
		divs #80,d2					; from 0 to 31
		move d2,d4
		lsl #5,d4
		or d4,d2
		lsl #5,d4
		or d4,d2
	endif
	ror #8,d2					; to NOVA  format
	tst d5
	bmi.s .lb00
	tst.b d5
	bne.s .lb0
.lb00:
	FALC16 d2
	tst d5
	bpl.s .lb0
	ror #8,d2
.lb0:
	move d2,(a2)+				; and into the palette
.col_loop:
	dbf d1,.color
.b_loop:
	dbf d0,.blocs
	rts	

fli_color_256_256:
	move (a0)+,d0				; number of blocs
	ror #8,d0
	tst.b is_tt					; because of NVDI...
	bne .tt_pal
	lea indexs,a2
	bra.s .b_loop
.blocs:
	moveq #0,d1
	move.b (a0)+,d1			; number of colors to skip
	lea (a2,d1*2),a2			; jumps to the correct color
	move.b (a0)+,d1
	bne.s .col_loop
	move #255,d1				; if d1=0 it means 256 colors
.color:
	lea vs_int,a6
	move (a2)+,(a6)+			; color index
	if REG=1
		rept 3
			moveq #0,d2
			move.b (a0)+,d2
			lsl #2,d2					; 0-255 to 0-1020
			move d2,(a6)+
		endr
	else
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
		muls #20,d2
		divs #51,d2					; from 0 to 1000
		move d2,(a6)+
		move d2,(a6)+
		move d2,(a6)+
	endif
	movem.l d0-d1/a0-a2,-(sp)
	GEM_VDI vs_color
	movem.l (sp)+,d0-d1/a0-a2
.col_loop:
	dbf d1,.color
.b_loop:
	dbf d0,.blocs
	rts		
.tt_pal:	
	move.l #0,a2
	bra.s .tt_b_loop
.tt_blocs:
	moveq #0,d1
	move.b (a0)+,d1			; number of colors to skip
	add d1,a2
	move.b (a0)+,d1
	bne.s .tt_col_loop
	move #255,d1				; if d1=0 it means 256 colors
.tt_color:
	if REG=1
		move.b (a0)+,d2
		lsl #4,d2
		move.b (a0)+,d2
		lsl #4,d2
		move.b (a0)+,d2
		lsr #4,d2
	else
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
		divs #160,d2				; from 0 to 15
		move d2,d4
		lsl #4,d4
		or d4,d2
		lsl #4,d4
		or d4,d2
	endif
	movem.l d0-d1/a0-a2,-(sp)
	move d2,-(sp)
	move a2,-(sp)
	XBIOS 83,6						; esetcolor
	movem.l (sp)+,d0-d1/a0-a2
	addq #1,a2
.tt_col_loop:
	dbf d1,.tt_color
.tt_b_loop:
	dbf d0,.tt_blocs
	rts		
	
fli_black:
	move.l a1,-(sp)
	tst.b is_tt
	bne.s .lb2
	tst.b switched
	bne.s .lb0
.lb2:
	GEM_VDI v_bar			; VDI still works
	bra.s .end
.lb0:							; else, we handle it
	move.l physbase,a1
	move #9599,d5
.lb1:
	clr.l (a1)+
	clr.l (a1)+
	clr.l (a1)+
	clr.l (a1)+
	dbf d5,.lb1
.end:
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
	moveq #7,d7				; mask of bits to find
	cmp.l #'riff',d0
	beq.s .lb0
.false:
	cmp #1,d7				; reste la zone idx1??	
	beq .no_id
	moveq #1,d0				; not an AVI file
	rts
.lb0:
	moveq #4,d1
.lb1:
	tst d7
	beq .end					; all found
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
	subq #1,d7				; one bloc found (bit 0)
	move.l d5,idx_pos
	move.l d1,idx_len
	bra.s .lb1
.lb2:
	cmp.l #'list',d0
	bne.s .lb1
	cmp.l #'hdrl',d2
	bne.s .lb3
	subq #2,d7				; one bloc (bit 1)
	addq.l #4,d5
	move.l d5,head_pos
	subq.l #4,d1
	move.l d1,head_len
	addq.l #4,d1
	bra.s .lb1
.lb3:
	cmp.l #'movi',d2
	bne.s .lb1
	subq #4,d7				; one bloc (bit 2)
	move.l d5,movi_pos
	bra .lb1
.no_id:
	st no_idx1
.end:
	moveq #0,d0
	rts
		
	; reads the header (size of the image, number of frames, compression,
	; sound frequency, etc...)
	; then reads the 'idx1' section and prepares the tables to read each
	; frame


avi_parse_chunks:
	move planes,planes_sav
	tst.b res_switch
	beq.s .no_sw
	bmi.s .aab
	move #8,planes				; always 256 colors for a TT
	bra.s .no_sw
.aab:
	move #16,planes			; act like TC if we're going to switch
.no_sw:
	move.l #$20202020,d7
	lea cvid_fix0,a6			; the buffer to read the header
	move.l head_len,d6
	SEEK head_pos,0			; to the right position
	move.l a6,-(sp)
	move.l d6,-(sp)	; lenght of the AVI header bloc
	move mov_h,-(sp)
	GEMDOS 63,12
	lea (a6,d6.l),a5			; end address
	moveq #0,d4					; ffctype (vids or auds)
.lb0:
	cmp.l a5,a6
	bpl .end_header
	move.l (a6)+,d0			; chunk name
	or.l d7,d0					; to lower case
	move.l (a6)+,d1
	INTEL d1						; size
	cmp.l #'avih',d0
	bne .lb1
	lea 16(a6),a3		; points to total frames
	move.l (a3)+,d0
	INTEL d0
	move.l d0,sample_num	; number of frames
	lea 12(a3),a3
	move.l (a3)+,d0		; width
	INTEL d0
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
	move.l (a3),d0			; height
	INTEL d0
	move d0,max_imagey
	move d0,d2
	addq #3,d0
	and.b #$fc,d0
	move d0,yto4n
	lsr #2,d2
	addq #3,d2
	and.b #$fc,d2
	move d2,yqto4n
	move #$0101,iv32_freq
	st samp_sizes
	bra .next
.lb1:
	cmp.l #'list',d0
	bne.s .lb2
	cmp.l #'strl',(a6)
	bne .next
	addq.l #4,a6
	bra .lb0
.lb2:
	cmp.l #'strh',d0
	bne.s .lb3
	move.l (a6),d4			; fcctype
	or.l d7,d4
	cmp.l #'vids',d4
	bne .next
	move.l 20(a6),d0
	INTEL d0					; time for one frame
	move.l 24(a6),d2		; rate
	INTEL d2
	muls.l #200,d0
	divs.l d2,d0		
	move.l d0,avi_rate	; number of 1/200 for one frame
	bra .next	
.lb3:
	cmp.l #'strf',d0
	bne .next
	cmp.l #'vids',d4		; video info?
	bne .lb4				; no...
	move.l 32(a6),d0
	INTEL d0					; number of colors into the palette
	move.l d0,mapused
	beq.s .c9
	bsr prepare_avi_pal
.c9:
	moveq #0,d4
	move.l 16(a6),d0		; compression
	or.l d7,d0				; to lower
	move.l d0,comp_txt
	if CDEB=0
	cmp.l #'cvid',d0
	bne.s .c1
	cmp #8,planes
	beq.s .c0
	move.l #qt_decode_cvid,d0
	bra .next_comp
.c0:
	move.l #qt_decode_256,d0
	bra .next_comp
.c1:
	cmp.l #'msvc',d0
	beq.s .c1a
	cmp.l #'cram',d0
	bne .c2
.c1a:
	move 12(a6),d0			; Planes
	ror #8,d0
	move 14(a6),d2			; bitcount
	ror #8,d2
	muls d2,d0				; number of bits per pixel
	move d0,cram_bits
	cmp #16,d0
	bne.s .c5
	tst.b is_tt
	bne.s .c4
	tst.b nova
	beq.s .c3
	cmp #8,planes
	beq.s .c4
	move.l #decode_cram16,d0
	bra .next_comp
.c4:
	move.l #decode_cram16_grey,d0
	bra .next_comp
.c3:
	move.l #decode_cram16_falc,d0
	bra .next_comp
.c5:
	cmp #8,d0
	bne .unsup				; unsupported CRAM
	cmp #8,planes
	beq.s .c6
	move.l #decode_cram8,d0
	bra .next_comp
.c6:
	move.l #decode_cram8_256,d0
	bra .next_comp
.c2:
	endif
	cmp.l #'!   ',d0	; rle 8
	bne.s .c8
	move.l #'rle8',comp_txt
	cmp #8,planes
	beq.s .c7
	move.l #decode_rle8,d0
	bra .next_comp
.c7:
	move.l #decode_rle8_256,d0
   bra .next_comp
.c8:
	if CDEB=0
	cmp.l #'yuv9',d0
	beq.s .c12
	cmp.l #'yvu9',d0
	bne.s .c10
.c12:
	move.l #qt_yuv9,d0
	cmp #8,planes
	bne .next_comp
	move.l #qt_yuv9_256,d0
	bra .next_comp
.c10:
	cmp.l #'    ',d0	; rgb
	bne.s .c13
	move.l #'rgb8',comp_txt
	cmp #8,planes
	beq.s .c11
	move.l #decode_rgb,d0
	bra.s .next_comp
.c11:
	move.l #decode_rgb_256,d0
	bra.s .next_comp
.c13:
	not.l d0
	cmp.l #$9689ccce,d0		; iv31
	beq.s .iv
	cmp.l #$9689cccd,d0		; iv32
	bne.s .unsup
.iv:
	move.l #intel_iv32_256,d0
	cmp #16,planes
	bne.s .next_comp
	if REG=1
		st can_fast
	endif
	move.l #intel_iv32,d0
	bra.s .next_comp
	endif
.unsup:
	st bad_comp
	bra.s .next
.lb4:
	cmp.l #'auds',d4		; sound info?
	bne.s .next
	moveq #0,d4
	move.l a6,a3
	move (a3)+,avi_comp_flag
	move (a3)+,d0
	ror #8,d0
	move d0,channels
	move.l (a3)+,d0
	INTEL d0
	move.l d0,frequency
	move 6(a3),d0
	ror #8,d0
	move d0,sound_bits
.next:
	add.l d1,a6
	bra .lb0
.next_comp:
	move.l d0,compression
	bra.s .next
.end_header:
	move planes_sav,planes
	tst.b no_idx1
	bne .fin	
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
	muls.l #12,d1			; 12 bytes for each image (offset + size + time)
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
	sf dc_flag
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
	beq .unknown			; yes, skips!
	subq.l #1,a1			; one less frame
	move.l (a0)+,d2		; flags
	move.l (a0)+,d1		; offset
	INTEL d1
	add.l a3,d1
	addq.l #8,d1			; to skip the ID and the size
	move.l d1,(a5)+
	;***
	tst.b dc_flag
	beq.s .first
	sub.l -16(a5),d1		; diff of sizes
	bmi.s .first
	move.l -12(a5),d0		; old size
	beq.s .first			; nul frame, don't touch!
	sub.l d0,d1				; what will be added
	bmi.s .first
	cmp.l #2049,d1
	bpl.s .first			; too much
	add.l d1,d0				; back to diff of sizes
	cmp.l d0,d5
	bpl.s .lbtruc
	move.l d0,d5
.lbtruc:
	move.l d0,-12(a5)		; as the new size for the previous frame	
.first:
	;***
	move.l (a0)+,d1		; size
	INTEL d1
	move.l d1,(a5)+
	st dc_flag
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
	divs.l d0,d2			; number of frames for 1 key frame
	cmp.l #4,d2				; more than 4?
	bmi.s .no_key
	st sync+1				; yes, so never skip a key frame!
.no_key:
	move.l d5,max_fsize
	move.l d4,snd_size
	move.l d3,snd_temp_size			
.fin:
	rts	

avi_build_table:
	moveq #10,d6
	moveq #1,d7
	bsr.l manage_tree
	move.l #$20202020,d7
	move.l movi_pos,a3
	addq.l #4,a3		; saute 'movi'
	SEEK a3,0			; to the index table
	move.l sample_num,d5
	tst.l frequency
	beq.s .no_sound
	move.l d5,d6			; 1 image = 1 sound (???)
	move.l d6,d1
	beq.s .no_sound
	asl.l #3,d1				; 8 bytes for each sound (pos + len)
	bsr malloc
	move.l d0,sound_offs
	move.l d0,a4			; for the sound
.no_sound:
	move.l d5,d1
	muls.l #12,d1			; 12 bytes for each image (offset + size + time)
	addq.l #8,d1
	addq.l #8,d1			; for dummy values (start and end)
	bsr malloc
	move.l d0,chunkoffs
	move.l d0,a5			; for the graphics
	addq.l #4,a5			; skips over the dumy value
	move.l d3,d6
	moveq #0,d4				; total sound size
	moveq #0,d5				; max_fsize
	moveq #0,d3				; max sound size
	move.l sample_num,a1	; to verify
	sf dc_flag
.ok:
	move.l a1,-(sp)
	bsr read_id_len
	INTEL d1
	addq.l #1,d1
	bclr #0,d1
	move.l d1,a0			; sauve la taille
	move.l (sp)+,a1
	addq.l #8,a3
	or.l d7,d0
	swap d0
	cmp #'00',d0			; 00dc or 00xx or else = a frame!
	bne.s .lb5
	cmp.l #0,a1				; end of expected frames?
	beq .unknown			; yes, skips!
	subq.l #1,a1			; one less frame
	moveq #0,d2				; flags
	move.l a3,d1			; offset
	move.l a3,(a5)+
	;***
	tst.b dc_flag
	beq.s .first
	sub.l -16(a5),d1		; diff of sizes
	bmi.s .first
	move.l -12(a5),d0		; old size
	beq.s .first			; nul frame, don't touch!
	sub.l d0,d1				; what will be added
	bmi.s .first
	cmp.l #2049,d1
	bpl.s .first			; too much
	add.l d1,d0				; back to diff of sizes
	cmp.l d0,d5
	bpl.s .lbtruc
	move.l d0,d5
.lbtruc:
	move.l d0,-12(a5)		; as the new size for the previous frame	
.first:
	;***
	move.l a0,d1		; size
	move.l d1,(a5)+
	st dc_flag
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
	swap d0
	cmp.l #'01wb',d0
	bne.s .unknown
	addq.l #1,sound_num
	move.l a3,(a4)+		; offset
	move.l a0,d1		; size
	move.l d1,(a4)+
	add.l d1,d4				; updates the total size
	cmp.l d1,d3
	bpl.s .loop
	move.l d1,d3			; new max sound size
	bra.s .loop
.unknown:
	cmp.l #"rec ",d0
	bne.s .loop				; non, sauter section
	sub.l a0,a0				; sinon, vider A0 car len id est suffisant
.loop:
	add.l a0,a3				; updates offset
	move.l a1,-(sp)
	SEEK a0,1
	move.l (sp)+,a1
	cmp.l d0,a3				; offset correct?
	bne.s .fin_fich
	subq.l #1,d6
	bne .ok
.fin_fich:
	move.l a1,d6
	sub.l d6,sample_num	; if less than expected frames
	move.l sample_num,d2	; total frames
	move.l ss_num,d0		; key frames
	beq.s .no_key			; no key frames...
	divs.l d0,d2			; number of frames for 1 key frame
	cmp.l #4,d2				; more than 4?
	bmi.s .no_key
	st sync+1				; yes, so never skip a key frame!
.no_key:
	move.l d5,max_fsize
	move.l d4,snd_size
	move.l d3,snd_temp_size			
.fin:
	moveq #10,d6
	moveq #-1,d7
	bsr.l manage_tree
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
	moveq #-1,d0
	move.l d0,bufused		; for CVID
	tst.b step_mode
	beq.s .pas_mode
	bra.l avi_step_mode
.pas_mode:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
.disp_again:
	moveq #0,d4				; file position!!!
	moveq #0,d3				; sync flags
	tst.b playing
	beq.s .no_sound
	tst.l s_buffer_2
	beq.s .s2
	bset #8,d3
.s2:
	bsr start_sound
.no_sound:
	tst.b bad_comp
	bne .exit				; bad compression!
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
	btst #8,d3
	beq.s .no_remain
	tst.b snd_value
	bmi.s .dma_remain
	tst.b yamaha_flag
	bne.s .no_remain
	bsr yamaha_next_sound
	bra.s .no_remain	
.dma_remain:
	btst #0,$ffff8901.w
	bne.s .no_remain
	bsr next_sound
.no_remain:
	lea 8(a6),a0
	bclr #31,d3
	move.l (a0),d0	; time
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
	bclr #31,d0			; en cas de key frames partout!
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
	move.l d0,d4		; new position
.no_seek:
	move.l (a6)+,d0
	beq.s .nul_frm
	move.l buffer,-(sp)
	move.l d0,-(sp)
	add.l d0,d4			; new position
	move mov_h,-(sp)
	GEMDOS 63,12			; reads the frame
.nul_frm:
	move.l (a6)+,d0
	bclr #31,d0
	move.l d0,a3			; the time
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
	tst.l -8(a6)		; frame size
	beq.s .loop			; nul frame
	movem.l d3-d4/d7/a3/a6,-(sp)
	move.l compression,a0
	jsr (a0)
	movem.l (sp)+,d3-d4/d7/a3/a6
.loop
	btst #2,([kbshift])
	bne.s .stop
	subq.l #1,d7
	bpl .lb0
	bra.s .exit
.stop:
	st stopped
.exit:
	tst.b stopped
	bne.s .quit
	btst #2,([kbshift])
	bne.s .stop
	tst.b snd_value
	bmi.s .dma_quit
	tst.b yamaha_flag
	bne.s .exit
	bra.s .test_repeat
.dma_quit:
	btst #0,$ffff8901.w
	bne.s .exit
	btst #8,d3
	beq.s .test_repeat
	bsr next_sound
	bra.s .exit
.test_repeat:
	tst.b is_rep
	beq.s .quit
	tst.b snd_value
	bpl .disp_again		; no DMA so no TT/ST ram problem
	tst.l s_buffer_2		; a TT Ram sound with DMA?
	beq .disp_again		; no, all in ST RAM
	sf playing				; else, no sound with repetition
	bra .disp_again	
.quit:
	tst.b snd_value
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
	tst.b bad_sound	; bad sound, use avi_rate
	bne.s .lb4
	tst.l sound_num	; no sound anyway, avi_rate
	beq.s .lb4
	tst.b playing
	beq.s .lb4			; no sound loaded, use AVI rate
	move.l snd_size,d1	; the size in bytes
	tst.b snd_value
	bmi.s .dma
	move.l #9600,d5
	bra.s .lb5
.dma:
	move.l real_freq,d5
	cmp #2,channels
	bne.s .lb5				; not a stereo, 1byte = 1sample
	asr.l #1,d1				; else 2bytes = 1 sample
.lb5:
	moveq #0,d6
	muls.l #200,d6:d1
	divs.l d5,d6:d1	; d1=number of 200th of second for the whole sample
								; to use the Timer C of the system
	bra.s .lb3
.lb4:
	move.l d4,d1
	muls.l avi_rate,d1	; number of 200th of sec for the whole sample
.lb3:
	clr.l (a1)+				; the first entry contains 0 (start of the sound)
	moveq #1,d6
.lb1:
	addq.l #8,a1			; skips pos and size
	move.l d6,d3			; number of frames
	muls.l d1,d5:d3
	divs.l d4,d5:d3		; d3 is the corresponding duration in 1/200 sec
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
	cmp.l #'mdat',d1
	beq.s .lb3
	cmp.l #'skip',d1
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
	SEEK #74,1			; just jump 74
	bsr read_len_id	; + 8
	move.l d0,_vr2_x
	move.l d1,_vr2_y	; temporaires (au cas ou GMHD=pano)
	SEEK #2,1			; +2 = 84....
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
	tst.b vr2_flag
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
	SEEK #12,1
	bsr read_long
	cmp.l #'gtel',d0
	seq gtel_sound
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
	bne.s .lb26a
	st _vr2_flag		; peut etre un vr2... (pas sur!)
	bra.s .lb23
.lb26a:
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
	; ************* in udta look for NAVG section ********
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
	move.l (a0),d0
	beq .lb0			; nothing found...
	move.l 4(a0),d1
	or.l #$20202020,d1
	cmp.l #'navg',d1
	beq.s .lb29
	add.l d0,a0
	bra.s .lb28
.lb29:
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
	muls.l 46(a0),d2
	lsl.l #2,d2
	sub.l d1,d2
	lsr.l #2,d2
	divs.l d1,d2
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
	muls.l 42(a0),d2
	divs.l d1,d2
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
	tst.b _vr2_flag
	bne qt_read_pano
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
	or.l #$20202020,d6	; to lower case
	move.l d6,comp_txt
	move planes,planes_sav
	tst.b res_switch
	beq.s .aaa
	bmi.s .aab
	move #8,planes			; act like in 256 colors with a TT
	bra.s .aaa
.aab:
	move #16,planes		; act like in TC if we're going to switch
.aaa:
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
	cmp #8,planes
	beq.s .lb71
	move.l #qt_decode_cvid,a0
.lb71:
	cmp #24,d0				; 24 planes?
	beq .lb8
	cmp #32,d0				; 32 planes?
	bne.s .lb6           ; if not, unsupported
	bra .lb8
.lb11:
	cmp #8,d0				; depth
	bne.s .lb6				; unsupported
	st qt_palette
	move.l #qt_smc_256,a0	; default, 256 colours
	cmp #8,planes
	beq .lb8
	move.l #qt_smc,a0		; or else, it's true color
	bra .lb8
.lb12:
	cmp #1,d0
	bne.s .lb12f				; other depth
	move.b #'1',comp_txt+3	; raw1, monochrome
	move.l #qt_raw1_256,a0
	cmp #8,planes
	beq .lb8
	move.l #qt_raw1,a0
	bra .lb8
.lb12f:
	cmp #2,d0
	bne.s .lb12g
	move.b #'2',comp_txt+3	; raw2, 4 colors
	st qt_palette
	move.l #qt_raw2_256,a0
	cmp #8,planes
	beq .lb8
	move.l #qt_raw2,a0
	bra .lb8
.lb12g:
	cmp #4,d0
	bne.s .lb12a				; other depth
	move.b #'4',comp_txt+3	; 'raw4'
	st qt_palette
	move.l #qt_raw4_256,a0
	cmp #8,planes
	beq .lb8
	move.l #qt_raw4,a0
	bra .lb8
.lb12a:
	cmp #16,d0
	bne.s .lb12b				; other depth
	move.l #'rw16',comp_txt
	move.l #qt_raw16_256,a0
	cmp #8,planes
	beq .lb8
	move.l #qt_raw16,a0
	tst.b nova
	bne .lb8
	move.l #qt_raw16_falc,a0
	bra .lb8
.lb12b:
	cmp #24,d0
	bne.s .lb12c				; other depth
	move.l #'rw24',comp_txt
	clr off_24_32
.lb12e:
	move.l #qt_raw24_256,a0
	cmp #8,planes
	beq .lb8
	move.l #qt_raw24,a0
	tst.b nova
	bne .lb8
	move.l #qt_raw24_falc,a0
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
	move.l #qt_raw_256,a0
	cmp #8,planes
	beq .lb8
	move.l #qt_raw,a0
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
	cmp #8,planes
	beq .lb8
	move.l #qt_rle24,a0
	tst.b nova
	bne .lb8
	move.l #qt_rle24_falc,a0
	bra .lb8
.lb13a:
	cmp #16,d0
	bne.s .lb14
	move #'16',comp_txt+2		; 'rl16'
	move.l #qt_rle16_256,a0
	cmp #8,planes
	beq .lb8
	move.l #qt_rle16,a0
	tst.b nova
	bne .lb8
	move.l #qt_rle16_falc,a0
	bra .lb8
.lb14:
	cmp #8,d0
	bne.s .lb14b			
	move.b #'8',comp_txt+3		; 'rle8'
	st qt_palette
	move.l #qt_rle8_256,a0
	cmp #8,planes
	beq .lb8
	move.l #qt_rle8,a0
	bra .lb8
.lb14b:
	cmp #2,d0
	bne.s .lb14c
	move.b #'2',comp_txt+3
	st qt_palette
	move.l #qt_rle2_256,a0
	cmp #8,planes
	beq .lb8
	move.l #qt_rle2,a0
	bra .lb8
.lb14c:
	cmp #4,d0
	bne.s .lb14d
	move.b #'4',comp_txt+3
	st qt_palette
	move.l #qt_rle4_256,a0
	cmp #8,planes
	beq .lb8
	move.l #qt_rle4,a0
	bra .lb8
.lb14d:
	cmp #1,d0
	bne .lb6				; unsuported
	move.b #'1',comp_txt+3
	move.l #qt_rle1_256,a0
	cmp #8,planes
	beq .lb8
	move.l #qt_rle1,a0
	bra .lb8
.lb15:
	cmp #16,d0
	bne .lb6				; always 16 bits
	cmp #8,planes
	beq.s .lb16
	move.l #qt_rpza,a0
	tst.b nova
	bne .lb8
	move.l #qt_rpza_falc,a0
	bra .lb8
.lb16:
	move.l #qt_rpza_256,a0
	bra .lb8
.lb17:
	cmp #24,d0
	bmi .lb6				; millions colors needed
	move.l #qt_yuv2,a0
	cmp #8,planes
	bne .lb8
	move.l #qt_yuv2_256,a0
	bra .lb8
.lb18:
	cmp #24,d0
	bmi .lb6				; millions colors needed
	move.l #qt_yuv9,a0
	cmp #8,planes
	bne .lb8
	move.l #qt_yuv9_256,a0
	bra .lb8
.lb19:
	cmp #8,d0
	bne .lb6				; unsupported depth
	st qt_palette
	move.l #decode_rgb_256,a0
	cmp #8,planes
	beq .lb8
	move.l #decode_rgb,a0
	bra .lb8
.lb20:
	move d0,cram_bits	; for init_rect
	cmp #16,d0
	bne.s .c5			; not cram 16
	tst.b is_tt
	bne.s .c4
	tst.b nova
	beq.s .c3
	cmp #8,planes
	beq.s .c4
	move.l #decode_cram16,a0
	bra .lb8
.c4:
	move.l #decode_cram16_grey,a0
	bra.s .lb8
.c3:
	move.l #decode_cram16_falc,a0
	bra.s .lb8
.c5:
	cmp #8,d0
	bne .lb6				; unsupported CRAM
	st qt_palette
	cmp #8,planes
	beq.s .c6
	move.l #decode_cram8,a0
	bra.s .lb8
.c6:
	move.l #decode_cram8_256,a0
	bra.s .lb8
.lb21:
	cmp #8,d0
	bne .lb6				; unsupported depth
	st qt_palette
	move.l #decode_rle8_256,a0
	cmp #8,planes
	beq.s .lb8
	move.l #decode_rle8,a0
	bra.s .lb8
.lb22:
	cmp #24,d0
	bne .lb6
	move.l #intel_iv32_256,a0
	cmp #16,planes
	bne.s .lb8
	if REG=1
		st can_fast
	endif
	move.l #intel_iv32,a0
.lb8:
	move.l a0,12(a5)		; compression routine
	move planes_sav,planes
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
	move #$0101,iv32_freq
	move yto4n,d0
	cmp max_imagey,d0
	bmi.s .lb10
	move d0,max_imagey
.lb10:
	lea 16(a5),a5			; next codec
	move.l id_ptr,a0
	move.l comp_txt,(a0)+
	move.w qt_palette,(a0)+
	move.l a0,id_ptr		; keeps every ID (if several are there!)
	subq.l #1,d4
	bne .lb4
	move.l #1,video_flag
	rts	

qt_read_pano:
	bsr read_len_id
	or.l #$20202020,d1
	cmp.l #'pano',d1
	bne.s .autre
	move.b #$7F,vr_flag	; true but >0
	pea cvid_fix0
	subq.l #8,d0			; - len, id
	move.l d0,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	tst.l d0
	bmi .gloups
	lea cvid_fix0,a0
	lea vr2_data,a1
	move 88(a0),(a1)+		; angle Horizontal
	move 92(a0),(a1)+		; angle haut
	move 96(a0),(a1)+		; angle bas
	move.l 108(a0),d0
	move.l d0,(a1)+	; hauteur panneau
	move.l 112(a0),(a1)+	; largeur panneau
	move.l 116(a0),(a1)+	; images par panneau
	move.l 120(a0),(a1)+	; images par colonne
.commun:
	st vr2_flag				; OUI!!! un VR2...
	lea _vr2_x,a0
	move.l (a0),8(a0)		; copie _vr2_x dans vr2_x et id pour y
	move.l 4(a0),d1		; limite vr2_y a la hauteur du panneau-1
	cmp.l d0,d1
	bmi.s .ok
	move.l d0,d1
	subq.l #1,d1
.ok:
	move.l d1,12(a0)
	rts
.autre:
	cmp.l #'qtvr',d1
	bne.s .gloups
	move.b #$7F,vr_flag	; true but >0
	pea cvid_fix0
	subq.l #8,d0			; - len, id
	move.l d0,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	tst.l d0
	bmi .gloups
	;	lea cvid_fix0,a0
	move.l codecs,a0
	lea vr2_data,a1
	move #360,(a1)+	
	move #45,(a1)+
	move #-45,(a1)+
	move.l (a0)+,d2
	move.l d2,(a1)+	; largeur image=hauteur panneau
	moveq #24,d1
	move.l (a0)+,d0	; hauteur image
	muls d1,d0		; *24=largeur panneau
	move.l d0,(a1)+
	move.l qtvr_num,d0
	move.l d0,(a1)+
	divs d1,d0
	ext.l d0
	move.l d0,(a1)+
	move.l d2,d0
	bra .commun	
.gloups:
	sf _vr2_flag
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
	tst.l d1
	bpl.s .toto
	move d0,d2
.toto:
	lea (a1,d2.w*2),a2
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
	move.l d0,d4			; sauve position
	add.l d0,d5				; whatever happens, we must leave at current+len-16
	move.l d5,-(sp)		; saves
	bsr read_len_id		; version and num
	tst.l video_flag
	bne.s .lb0
	tst.l s_flag
	beq.s .end
	addq.l #4,d4
	addq.l #8,d4
	movem.l d1/d4,snd_size_offs
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
	muls.l #12,d1			; each bloc->12 bytes
	bsr malloc
	move.l d0,s2chunks
	moveq #0,d5				; cur
	bra.s .lb3
.lb1:
	move.l s2chunk_num,d5	; cur and saves the old num
	add.l d5,d1
	move.l d1,s2chunk_num	; updates the num
	addq.l #1,d1			; begins at 0, so 1 block more
	muls.l #12,d1			; each block is 12 bytes long
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
	muls.l #12,d5			; the offset for the first s2chunk to fill
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
	tst.b vr2_flag
	beq.s .coucou
	move.l d1,vr2_num		; nombre de lieux
.coucou:
	SEEK d5,1				; jumps over what's not read
	rts
.lb0:
	move.l d0,d3			; for the last loop
	move.l d5,d6			; for the last loop too
	move.l d1,d4			; saves num
	tst.l samp_sizes
	bne.s .lb1
	move.l d1,sample_num
	move.l d1,qtvr_num	; en cas de qtvr...
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
	beq.s .lb5				; no, all has been read
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
	pea (a5)
	lsl.l #2,d4
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
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
	tst.b step_mode
	bne.l qt_step_mode
	tst.b vr_flag
	bmi vr_read_data
	bgt vr2_read_data		; ouh la!
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr	; we're in supervisor mode!
.disp_again:
	moveq #0,d3				; resets bits #31, #15, #8
	tst.b playing			; is there a sound?
	beq.s .no_sound
	tst.l s_buffer_2		; a TT Ram remaining?
	beq.s .s2				; no!
	bset #8,d3				; else, sets the bit
.s2:
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
	move.l ([chunkoffs],d7.l*4),d0
	SEEK d0,0	; start of chunk data
	move.l d5,d1
	muls.l #12,d1
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
	move.l 8(a2,d0.l),depth
	move.l 12(a2,d0.l),compression	
	bra .end_of_samps
.samp_loop:
	btst #8,d3				; set if there's a sound with remaining into TT ram
	beq.s .no_remain
	tst.b snd_value
	bmi.s .dma_remain
	tst.b yamaha_flag
	bne.s .no_remain
	bsr yamaha_next_sound
	bra.s .no_remain	
.dma_remain:
	btst #0,$ffff8901.w
	bne.s .no_remain		; sound not stopped yet
	bsr next_sound
.no_remain:
	move.l samp_sizes,a0
	move.l (a0,d6.l*4),bufused	; size used for the current sample
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
	bpl.s .ageu
	bclr #31,d0
.ageu:
	move.l start_time,a0
	add.l d0,a0
.lb3:
	cmp.l $4ba.w,a0		; yes, is the previous frame ended?
	bpl.s .lb3				; not yet.
.lb2:
	addq.l #1,disp_frame	; counts the frames displayed
	move.l compression,a0
	jsr (a0)					; decodes and displays
.next:
	movem.l (sp)+,d2-d7/a2-a6
	btst #2,([kbshift])	; Control key to stop
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
	btst #2,([kbshift])			; control key to stop
	beq.s .out2
.out3:
	st stopped						; stopped, no stats displayed
	tst.b snd_value
	bpl.s .out2_yamaha
	clr.b $ffff8901.w
	bclr #8,d3
	bra.s .out2
.out2_yamaha:
	bclr #8,d3
	move sr,d0
	move #$2700,sr
	move.l yamaha_ptr,a0
	clr.b (a0)+
	clr.b (a0)
	move d0,sr
.out2:
	tst.b snd_value
	beq.s .end
	bmi.s .dma_test
	tst.b yamaha_flag
	bne.s .out
	btst #8,d3
	beq.s .test_repeat
	bsr yamaha_next_sound
	bra.s .out
.dma_test:
	btst #0,$FFFF8901.w
	bne.s .out
	btst #8,d3
	beq.s .test_repeat
	bsr next_sound
	bra.s .out
.test_repeat:
	tst.b stopped
	bne.s .end
	tst.b is_rep
	beq.s .end
	tst.b snd_value
	bpl .disp_again		; no DMA so no TT/ST ram problem
	tst.l s_buffer_2		; a TT Ram sound with DMA?
	beq .disp_again		; no, all in ST RAM
	sf playing				; else, no sound with repetition
	bra .disp_again
.end:
	move.l $4ba.w,end_time
	move.l stack_adr,-(sp)
	GEMDOS 32,6					; returns to user mode
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
	move.l -(a0),old_ikbd
	move.l #vr_ikbd,(a0)
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
	move.l old_ikbd,-(a0)
	move.l stack_adr,-(sp)
	GEMDOS 32,6					; returns to user mode
	rts

vr_xymouse: dc.w 0,0
vr_clic: dc.b 0,0
vr_keys: dc.b 0,0,0,0
vr2_esc: dc.b 0,0				; ESC revient, TAB avance

vr_ikbd:
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
	addq.l #1,a0
	cmp.b #$01,d0	; esc
	beq.s .vrai
	cmp.b #$81,d0
	beq.s .faux
	addq.l #1,a0
	cmp.b #$0F,d0	; tab
	beq.s .vrai
	cmp.b #$8F,d0
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
	muls.l d4,d3			; index of the image
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
	move.l ([chunkoffs],d7.l*4),d3	; offset
	move.l d5,d1
	muls.l #12,d1
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
;	move.l (a2,d0.l),imagex		; pour l'instant!
;	move.l 4(a2,d0.l),imagey
;	move.l 8(a2,d0.l),depth
;	move.l 12(a2,d0.l),compression	
	bra .end_of_samps
.samp_loop:
	cmp.l sample_num,d6	; exit if cur_samp>=sample_num
	bpl .out
	move.l samp_sizes,a0
	move.l (a0,d6.l*4),d1
	addq.l #1,d6
	move.l d3,(a3)+		; new offset
	add.l d1,d3				; next one
	move.l t2samps,a0
	lea (a0,d6.l*4),a0
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
	lea vr_keys(pc),a1
	move.b d0,-2(a1)
	clr.l (a1)
	move.b (a0)+,d0
	ext.w d0						; X movement
	add d0,-6(a1)
	sgt 2(a1)
	smi 3(a1)
	bpl.s .test_y
	neg d0						; absoluteddx
.test_y:
	move.b (a0)+,d1
	ext.w d1
	add d1,-4(a1)
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

vr2_read_data:
	bsr find_offs_size_time
	tst.b is_tt
	beq.s .pas_tt
	move.l compression,a0
	move.l tt_comp,compression
	lea 22(a0),a0
	move.l a0,tt_comp
.pas_tt:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr	; we're in supervisor mode!
	sf vr_clic
	clr.l vr_keys
	clr vr2_esc
	moveq #-1,d0
	move.l d0,vr2_index
	move.l vr2_temp,image	; image into TEMP
	XBIOS 34,2
	move.l d0,a0			; kvdbase
	tst.b vr_clic+1
	bne.s .mouse1
	move.l -(a0),old_ikbd
	move.l #vr_ikbd,(a0)
	bra.s .loop
.mouse1:
	move.l 16(a0),old_ikbd
	move.l #vr_mouse,16(a0)
.loop:
	bsr first_of_pano
	move.l screenw,vr2_save_screen
	move.l max_imagex,screenw	; temp a la meme taille que l'image
.go_on_pano:
	SEEK (a3)+,0				; offset
	move.l buffer,-(sp)
	move.l (a5)+,d0
	move.l d0,-(sp)
	move.l d0,bufused
	move mov_h,-(sp)
	GEMDOS 63,12			; fread!
	movem.l d5/a3/a5,-(sp)	; saves registers
	move.l compression,a0
	jsr (a0)					; decode dans TEMP
	movem.l (sp)+,d5/a3/a5
	bsr vr2_save_image
	dbf d5,.go_on_pano
	move.l vr2_save_screen,screenw	
	move.l vr2_sx,d6
	move.l vr2_sy,d7		; positions de depart
.voir:
	move.l $4ba.w,a4
	bsr vr2_display
	tst.b is_tt
	beq.s .no_tt
	movem.l a4/d6-d7,-(sp)
	move.l vr2_y,a3
	move.l tt_comp,a1
	move.l vr2_image,a0
	moveq #0,d0
	jsr (a1)
	movem.l (sp)+,a4/d6-d7
.no_tt:
	move.l a4,d3
	move.l _delay,d0
	lsr.l #2,d0
	move.l kbshift,a1
	tst.b vr_clic+1
	bne.s .mouse2
	move.b (a1),d2
	and.b #3,d2
	beq.s .no_fast
	bra.s .fast
.mouse2:
	move.b vr_clic(pc),d2
	btst #1,d2
	beq.s .no_fast
.fast:
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
	tst.b vr_clic+1
	bne.s .mouse3
	move 4(a2),d0
	bne .loop
	bra.s .wait
.mouse3:
	btst #0,vr_clic
	bne .loop		; if escape, other panel
	bra.s .wait
.a_key:
	tst.b vr_clic+1
	beq.s .no_mouse1
	clr.l (a2)		; with mouse: read once
	move.l vr2_maxy,d1
	move.l -6(a2),d0
	clr.l -6(a2)
	asl #4,d0
	add d0,d7
	bpl.s .m0
	moveq #1,d7
	bra.s .xmov
.m0:
	cmp d1,d7
	bmi.s .xmov
	move d1,d7
	subq #1,d7
.xmov:
	move.l vr2_maxx,d1
	swap d0
	asl #4,d0
	add d0,d6
	bpl.s .m1
	tst.b vr_xloop
	bne.s .m2
	moveq #0,d6
	bra .voir
.m2:
	add d1,d6
	bmi.s .m2
	bra .voir
.m1:
	tst.b vr_xloop
	bne.s .m3
	cmp d1,d6
	bmi .voir
	move d1,d6
	bra .voir		
.m3:
	cmp d1,d6
	bmi .voir
	sub d1,d6
	bra.s .m3
.no_mouse1:
	move.l vr2_maxy,d1
	btst #31,d0
	beq.s .key1
	sub #16,d7		; down
	bgt .voir
	tst.b vr_yloop
	bne.s ._k0
	moveq #1,d7
	bra .voir
._k0:
	add d1,d7
	bra .loop
.key1:
	btst #23,d0
	beq.s .key2
	add #16,d7		; up
	cmp d1,d7
	bmi .voir
	move d1,d7
	tst.b vr_yloop
	beq .voir
	moveq #1,d7
	bra .voir
.key2:
	move.l vr2_maxx,d1
	btst #7,d0
	beq.s .key3
	sub #16,d6		; $4D=RIGHT
	bpl .voir
	tst.b vr_xloop
	bne.s ._k2
	moveq #0,d6
	bra .voir
._k2:
	move.l d1,d6
	bra .voir
.key3:
	btst #15,d0
	beq .wait
	add #16,d6		; $4B=LEFT
	cmp d1,d6
	bmi .voir
	move.l d1,d6
	tst.b vr_xloop
	beq .voir
	moveq #0,d6
	bra .voir
.stop:
	st stopped
	XBIOS 34,2
	move.l d0,a0
	moveq #16,d0
	tst.b vr_clic+1
	bne.s .mouse4
	moveq #-4,d0
.mouse4:
	move.l old_ikbd,0(a0,d0)
	move.l stack_adr,-(sp)
	GEMDOS 32,6					; returns to user mode
	rts
	
first_of_pano:
	move.l vr2_index,d3
	addq.l #1,d3
	cmp.l vr2_num,d3
	bmi.s .ok
	moveq #0,d3
.ok:
	move.l d3,vr2_index
	move.l vr2_data+14,d5	; nombre d'images par panneau
	muls.l d5,d3	; index de la premiere image du panneau
	lsl.l #2,d3
	move.l s_buffer,a3
	move.l t2samps,a4
	move.l samp_sizes,a5
	add.l d3,a3
	add.l d3,a4
	move.l (a4),_delay
	add.l d3,a5
	subq #1,d5				; pour la boucle
	clr.l vr2_col_offy
	move.l vr2_data+10,d0
	sub max_imagey,d0
	move.l d0,vr2_col_offx
	rts
	
vr2_save_image:
	move max_imagey,d7
	ext.l d7
	move.l vr2_panneau,a1
	move.l a1,a2
	move max_imagex,d6
	move.l vr2_data+10,d3	; largeur
	move.l vr2_col_offy,d1
	muls d3,d1
	sub.l d7,d3					; increment horizontal
	add.l vr2_col_offx,d1	
	add.l d1,a1
	move d6,d2
	subq #1,d2
	subq #1,d7
	cmp #8,planes
	beq.s .c256
	add.l d1,a1
	add.l	d3,d3
	add.l d6,d6	
.lb1:
	move d7,d0
	move.l a2,a0				; saves
.lb0
	sub d6,a0
	move (a0),(a1)+
	dbf d0,.lb0
	add.l d3,a1
	addq.l #2,a2
	dbf d2,.lb1
	bra.s .new_offset
.c256:
	move d7,d0
	move.l a2,a0				; saves
.clb0
	sub d6,a0
	move.b (a0),(a1)+
	dbf d0,.clb0
	add.l d3,a1
	addq.l #1,a2
	dbf d2,.c256
.new_offset:
	move.l vr2_col_offy,d0
	add max_imagex,d0			; new offset
	cmp.l vr2_data+6,d0		; =hauteur pano?
	bmi.s .good					; oui, retour a zero.
	moveq #0,d0
	move max_imagey,d0
	sub.l d0,vr2_col_offx
	moveq #0,d0
.good:
	move.l d0,vr2_col_offy
	rts	
	
vr2_display:
	move.l vr2_image,a3		; ecran	
	move.l vr2_data+10,d0
	move.l d0,d3				; largeur
	muls d7,d0
	add.l d6,d0					; offset dans tableau
	move.l vr2_panneau,a0
	move.l vr2_x,d4
	move.l vr2_y,d5
	tst.b vr2_def
	bne.s vr2_disp_def
	sub.l d4,d3					; inc pour tableau
	move screenw,d1
	sub d4,d1					; inc pour ecran
	ext.l d1
	subq #1,d4
	subq #1,d5
	add.l d0,a0
	cmp #8,planes
	beq.s .c256
	add.l d0,a0
	add.l d1,d1
	add.l d3,d3
.lb1:
	move d4,d2
.lb0:
	move (a0)+,(a3)+
	dbf d2,.lb0
	add.l d3,a0
	add.l d1,a3
	dbf d5,.lb1
	rts	
.c256:
	move d4,d2
.clb0:
	move.b (a0)+,(a3)+
	dbf d2,.clb0
	add.l d3,a0
	add.l d1,a3
	dbf d5,.c256
	rts		
vr2_disp_def:
	movem.l d6-d7,-(sp)
	moveq #0,d6
	move.l d7,d1
	add.l d7,d1
	move.l d5,d2
	add.l d5,d2
	add.l d5,d2		; global effect with 3*window height
	sub.l d2,d1
	muls.l d4,d1
	bpl.s .areu1
	moveq #-1,d6
.areu1:
	swap d1
	move d1,d6
	clr d1
	lsl.l #3,d2
	dc.w $4c42,$1c06		; divsl.l d2,d6:d1
	move.l d1,a2			; x de depart en WORD,WORD
	lsr.l #3,d2
	add.l d7,d7
	moveq #0,d6
	sub.l d5,d7
	muls.l d4,d7
	neg.l d7
	bpl.s .areu2
	moveq #-1,d6
.areu2:	
	move.l d5,d1
	muls.l d2,d1
	add.l d1,d1
	swap d7
	move d7,d6
	clr d7
	dc.w $4c41,$7c06		;	divsl.l d1,d6:d7		; dx en WORD,WORD
	exg.l a2,d7
	move screenw,d1
	sub d4,d1
	ext.l d1						; increment pour ecran
	subq #1,d5
	add.l d0,a0
	cmp #8,planes
	beq.s .clb1
	add.l d0,a0
	add.l d1,d1
	add.l d3,d3
.lb1:
	move.l d4,d2				; longueur normale
	swap d2
	sub.l d7,d2
	sub.l d7,d2
	swap d2						; nouvelle longueur
	swap d7
	move.l a0,a1				; save pos
	add d7,a0
	add d7,a0
	move.l a0,d6
	bclr #0,d6
	move.l d6,a0
	moveq #0,d6
	cmp d4,d2
	beq.s .copie
	lea 0(a3,d4.l*2),a5			; end of line (for A3)
	bpl.s .reduire
.agrandir:		
	move (a0)+,d0
.ag0:
	move d0,(a3)+
	cmp.l a5,a3
	beq.s .fin_ligne
	add d2,d6
	cmp d4,d6
	bmi.s .ag0
	sub d4,d6
	bra.s .agrandir
.r0:
	addq.l #2,a0
	add d4,d6
	cmp d2,d6
	bmi.s .r0
.reduire:
	sub d2,d6
	move (a0),(a3)+
	cmp.l a3,a5
	bne.s .r0
	bra.s .fin_ligne
.c0:
	move (a0)+,(a3)+
.copie:
	dbf d2,.c0
.fin_ligne:
	lea 0(a1,d3.l),a0			; nouvelle ligne
	swap d7
	add.l a2,d7
	add.l d1,a3
	dbf d5,.lb1
	movem.l (sp)+,d6-d7
	rts	
.clb1:
	move.l d4,d2				; longueur normale
	swap d2
	sub.l d7,d2
	sub.l d7,d2
	swap d2						; nouvelle longueur
	swap d7
	move.l a0,a1				; save pos
	add d7,a0
	moveq #0,d6
	cmp d4,d2
	beq.s .ccopie
	lea 0(a3,d4.l),a5			; end of line (for A3)
	bpl.s .creduire
.cagrandir:		
	move.b (a0)+,d0
.cag0:
	move.b d0,(a3)+
	cmp.l a5,a3
	beq.s .cfin_ligne
	add d2,d6
	cmp d4,d6
	bmi.s .cag0
	sub d4,d6
	bra.s .cagrandir
.cr0:
	addq.l #1,a0
	add d4,d6
	cmp d2,d6
	bmi.s .cr0
.creduire:
	sub d2,d6
	move.b (a0),(a3)+
	cmp.l a3,a5
	bne.s .cr0
	bra.s .cfin_ligne
.cc0:
	move.b (a0)+,(a3)+
.ccopie:
	dbf d2,.cc0
.cfin_ligne:
	lea 0(a1,d3.l),a0			; nouvelle ligne
	swap d7
	add.l a2,d7
	add.l d1,a3
	dbf d5,.clb1
	movem.l (sp)+,d6-d7
	rts		
	
yamaha_next_sound:
	lea s_buffer_2,a0		; TT ram buffer (one time)
	bclr #8,d3				; no more remaining
	bra yamaha_start_sound	; play it!
	
next_sound:
	move.l snd_pos,a0
	move.l ttram_size,d0
	beq .end
	move.l stram_size,d1
	move.l d1,a1				; saves it
	cmp #2,channels
	bne.s .lb5
	asr.l #1,d1					; if stereo, 2 bytes for one sample
.lb5:
	muls.l #200,d1
	divs.l real_freq,d1		; number of 1/200 that have been played
	add.l d1,timer_c
	move.l a1,d1				; the stram size again
	cmp.l d0,d1
	bpl.s .lb0
	sub.l d1,ttram_size		; the remaining shrinks
	add.l d1,snd_pos			; updates the position
	bra.s .copy
.lb0:
	move.l d0,d1				; the size to copy
	bclr #8,d3					; there's no more remaining
.copy:
	move.l s_buffer,a1		; the ST Ram buffer
	move.l d1,d0
	lsr.l #4,d1					; blocs of 16 bytes
	and #$F,d0					; the remaining bytes
	bra.s .lb2
.lb1:
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
.lb2:
	subq.l #1,d1
	bpl.s .lb1
	bra.s .lb4
.lb3:
	move.b (a0)+,(a1)+
.lb4:
	dbf d0,.lb3
	move.l a1,snd_end
	bsr start_sound
	move.l $4ba.w,d0
	sub.l timer_c,d0
	bpl.s .lb6
	moveq #0,d0
.lb6:
	move.l d0,start_time
	bra.s .out
.end:
	bclr #8,d3
.out:
	rts
	
start_sound:
	lea s_buffer,a0
	tst.b snd_value
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
	tst.b snd_value
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
	st yamaha_flag	
	lea $fffffa00.w,a0					; save MFP
	bclr #5,7(a0)
	bclr #5,$13(a0)
	move.b	#1,$19(a0)		; control
	tst.b psnd_flag			; parallel sound card
	bne.s .coucou
 	move.b	#64,$1F(a0)		; data
	move.l	#yamaha_replay,$134.w
	bra.s .common
.coucou:
	move.b #32,$1f(a0)
	move.l #psnd_replay,$134.w
.common:
	bclr.b	#3,$17(a0)
	bset #5,7(a0)
	bset #5,$13(a0)
	move.w	d0,sr
	rts

yamaha_ptr: dc.l yamaha_dum
yamaha_dum: dc.w 0

inull: rte

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

psnd_replay:
	move.l a0,-(sp)
	move.l d0,-(sp)
	move.l yamaha_ptr(pc),a0
	move.l #$07ff0f00,d0
	move.b (a0)+,d0
	beq.s .end_replay
	eor.b #$80,d0
	move.l a0,yamaha_ptr
	move.l d0,.save_previous
	lea $FFFF8800.w,a0
	movep.l d0,0(a0)
	move.l #.psnd2,$134.w
.exit_int:
	move.l (sp)+,d0
	move.l (sp)+,a0
	rte
.end_replay:
	bsr stop_timer
	bra.s .exit_int
.save_previous: dc.l 0
.psnd2:
	move.l a0,-(sp)
	move.l d0,-(sp)
	move d1,-(sp)
	move.l yamaha_ptr(pc),a0
	move.l .save_previous(pc),d0
	move.b (a0),d1
	lea $FFFF8800.w,a0
	eor.b #$80,d1
	move.l #psnd_replay,$134.w
	add.b d1,d0
	roxr.b d0
	move (sp)+,d1
	movep.l d0,0(a0)
	move.l (sp)+,d0				
	move.l (sp)+,a0
	rte

yamaha_replay:
	movem.l d0/a0-a1,-(sp)
	move.l yamaha_ptr(pc),a0
	moveq #0,d0
	move.b (a0)+,d0
	beq.s .end_replay
	move.l d0,a1
	move.l a0,yamaha_ptr
	add.l a1,d0
	lea $ffff8800.w,a0
	add.l a1,d0
	lea yamaha_data(pc,d0.w),a1
	move.b #8,(a0)
	move.b (a1)+,2(a0)
	move.b #9,(a0)
	move.b (a1)+,2(a0)
	move.b #10,(a0)
	move.b (a1),2(a0)
.exit_int:
	movem.l (sp)+,d0/a0-a1
	rte
.end_replay:
	bsr stop_timer
	bra.s .exit_int

yamaha_data:
	dc.b	$C,$B,$9,$C,$B,$9
	dc.b	$D,$8,$8,$B,$B,$B
	dc.b	$D,$9,$5,$C,$B,$8
	dc.b	$D,$9,$2,$D,$8,$6
	dc.b	$C,$B,$7,$D,$7,$7
	dc.b	$C,$B,$6,$C,$A,$9
	dc.b	$B,$B,$A,$C,$B,$2
	dc.b	$C,$B,$0,$C,$A,$8
	dc.b	$D,$6,$4,$D,$5,$5
	dc.b	$D,$5,$4,$C,$9,$9
	dc.b	$D,$4,$3,$B,$B,$9
	dc.b	$C,$A,$5,$B,$A,$A
	dc.b	$C,$9,$8,$B,$B,$8
	dc.b	$C,$A,$0,$C,$A,$0
	dc.b	$C,$9,$7,$B,$B,$7
	dc.b	$C,$9,$6,$B,$B,$6
	dc.b	$B,$A,$9,$B,$B,$5
	dc.b	$A,$A,$A,$B,$B,$2
	dc.b	$B,$A,$8,$C,$7,$7
	dc.b	$C,$8,$4,$C,$7,$6
	dc.b	$B,$9,$9,$C,$6,$6
	dc.b	$A,$A,$9,$C,$7,$3
	dc.b	$B,$A,$5,$B,$9,$8
	dc.b	$B,$A,$3,$A,$A,$8
	dc.b	$B,$A,$0,$B,$9,$7
	dc.b	$B,$8,$8,$A,$A,$7
	dc.b	$A,$9,$9,$C,$1,$1
	dc.b	$A,$A,$6,$B,$8,$7
	dc.b	$A,$A,$5,$A,$9,$8
	dc.b	$A,$A,$2,$A,$A,$1
	dc.b	$A,$A,$0,$9,$9,$9
	dc.b	$A,$8,$8,$B,$8,$1
	dc.b	$A,$9,$6,$B,$7,$4
	dc.b	$A,$9,$5,$9,$9,$8
	dc.b	$A,$9,$3,$A,$8,$6
	dc.b	$A,$9,$0,$9,$9,$7
	dc.b	$9,$8,$8,$A,$8,$4
	dc.b	$9,$9,$6,$A,$8,$1
	dc.b	$9,$9,$5,$9,$8,$7
	dc.b	$8,$8,$8,$9,$9,$2
	dc.b	$9,$8,$6,$9,$9,$0
	dc.b	$9,$7,$7,$8,$8,$7
	dc.b	$9,$7,$6,$9,$8,$2
	dc.b	$8,$8,$6,$9,$6,$6
	dc.b	$8,$7,$7,$8,$8,$4
	dc.b	$8,$7,$6,$8,$8,$2
	dc.b	$7,$7,$7,$8,$6,$6
	dc.b	$8,$7,$4,$7,$7,$6
	dc.b	$8,$6,$5,$8,$6,$4
	dc.b	$7,$6,$6,$7,$7,$4
	dc.b	$8,$5,$4,$6,$6,$6
	dc.b	$7,$6,$4,$7,$5,$5
	dc.b	$6,$6,$5,$6,$6,$4
	dc.b	$6,$5,$5,$6,$6,$2
	dc.b	$6,$5,$4,$5,$5,$5
	dc.b	$6,$5,$2,$5,$5,$4
	dc.b	$5,$4,$4,$5,$5,$2
	dc.b	$4,$4,$4,$4,$4,$3
	dc.b	$4,$4,$2,$4,$3,$3
	dc.b	$3,$3,$3,$3,$3,$2
	dc.b	$3,$2,$2,$2,$2,$2
	dc.b	$2,$2,$1,$1,$1,$1
	dc.b	$2,$1,$0,$1,$1,$0
	dc.b	$1,$0,$0,$0,$0,$0
	dc.b	$E,$D,$C,$F,$3,$0
	dc.b	$F,$3,$0,$F,$3,$0
	dc.b	$F,$3,$0,$F,$3,$0
	dc.b	$F,$3,$0,$E,$D,$B
	dc.b	$E,$D,$B,$E,$D,$B
	dc.b	$E,$D,$B,$E,$D,$B
	dc.b	$E,$D,$B,$E,$D,$B
	dc.b	$E,$D,$A,$E,$D,$A
	dc.b	$E,$D,$A,$E,$D,$A
	dc.b	$E,$C,$C,$E,$D,$0
	dc.b	$D,$D,$D,$D,$D,$D
	dc.b	$D,$D,$D,$D,$D,$D
	dc.b	$D,$D,$D,$D,$D,$D
	dc.b	$E,$C,$B,$E,$C,$B
	dc.b	$E,$C,$B,$E,$C,$B
	dc.b	$E,$C,$B,$E,$C,$B
	dc.b	$E,$C,$B,$E,$C,$B
	dc.b	$E,$C,$A,$E,$C,$A
	dc.b	$E,$C,$A,$E,$C,$A
	dc.b	$D,$D,$C,$D,$D,$C
	dc.b	$E,$C,$9,$E,$C,$9
	dc.b	$E,$C,$5,$E,$C,$0
	dc.b	$E,$C,$0,$E,$B,$B
	dc.b	$E,$B,$B,$E,$B,$B
	dc.b	$E,$B,$B,$E,$B,$A
	dc.b	$E,$B,$A,$E,$B,$A
	dc.b	$D,$D,$B,$D,$D,$B
	dc.b	$D,$D,$B,$E,$B,$9
	dc.b	$E,$B,$9,$E,$B,$9
	dc.b	$D,$C,$C,$D,$D,$A
	dc.b	$E,$B,$7,$E,$B,$0
	dc.b	$E,$B,$0,$D,$D,$9
	dc.b	$D,$D,$9,$E,$A,$9
	dc.b	$D,$D,$8,$D,$D,$7
	dc.b	$D,$D,$4,$D,$D,$0
	dc.b	$E,$A,$4,$E,$9,$9
	dc.b	$E,$9,$9,$D,$C,$B
	dc.b	$E,$9,$8,$E,$9,$8
	dc.b	$E,$9,$7,$E,$8,$8
	dc.b	$E,$9,$1,$C,$C,$C
	dc.b	$D,$C,$A,$E,$8,$6
	dc.b	$E,$7,$7,$E,$8,$0
	dc.b	$E,$7,$5,$E,$6,$6
	dc.b	$D,$C,$9,$E,$5,$5
	dc.b	$E,$4,$4,$D,$C,$8
	dc.b	$D,$B,$B,$E,$0,$0
	dc.b	$D,$C,$6,$D,$C,$5
	dc.b	$D,$C,$2,$C,$C,$B
	dc.b	$C,$C,$B,$D,$B,$A
	dc.b	$D,$B,$A,$D,$B,$A
	dc.b	$D,$B,$A,$C,$C,$A
	dc.b	$C,$C,$A,$C,$C,$A
	dc.b	$D,$B,$9,$D,$B,$9
	dc.b	$D,$A,$A,$D,$A,$A
	dc.b	$D,$A,$A,$C,$C,$9
	dc.b	$C,$C,$9,$C,$C,$9
	dc.b	$D,$B,$6,$C,$B,$B
	dc.b	$C,$C,$8,$D,$B,$0
	dc.b	$D,$B,$0,$C,$C,$7
	dc.b	$C,$C,$6,$C,$C,$5
	dc.b	$C,$C,$3,$C,$C,$1
	dc.b	$C,$B,$A,$D,$A,$5
	dc.b	$D,$A,$4,$D,$A,$2
	dc.b	$D,$9,$8,$D,$9,$8
	
ve_cont: dc.w 102,0,0,1,0,0,0,0,0,0,0,0
ve_int: dc.w 1
vq_extnd2: dc.l ve_cont,ve_int2,dum,cvid_fix0,cvid_fix1
ve_int2: dc.w 2

	; ************* creates two routines very similar *****************
	; the first with c256=0  --> high color display
	; the second withcc256=1---> 256 grey
	; only a few lines change (if c256=..., comditional assembly)
	
c256 set 0			; first loop, c256=0

	rept 2			; two times
	
	if c256=0		; the name of the routine changes
qt_decode_cvid:
	else
qt_decode_256:
	endif
	
	move.l buffer,a2		; the datas
	clr x
	clr y
	clr y_top
	move screenw,d3
	move d3,d4
	if c256=0
		subq #3,d3			; row_inc
		add d3,d3				; one pixel=2bytes in true color mode
	else
		subq #4,d3
	endif
	asl #2,d4
	move max_imagex,d2
	addq #3,d2
	and.b #$fc,d2
	sub d2,d4	; y_inc
	if c256=0
		add d4,d4				; one pixel=2bytes in true color mode
	endif
	move.l image,a3		; the screen
	
	move.l (a2)+,d2
	and.l #$FFFFFF,d2		; the len
	move.l bufused,d1
	bmi.s .lbgood			; avi file!!!
	cmp.l d1,d2				; compared to the expected len
	beq.s .lbgood
	addq.l #1,d2			; try to correct
	cmp.l d1,d2				; correction failed?
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
	lea (cvid_maps0,d5.l*4),a4
	lea (cvid_vmap0,d5.l),a5
.lb0:	
	move.l #2080,d0
	muls.l d5,d0
	add.l #cvid_fix1,d0
	move.l d0,24(a4)
	sf 6(a5)
	move.l #2080,d0
	muls.l d5,d0
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
	move.l (cvid_maps0,d5.l*4),a4
	move.l (cvid_maps1,d5.l*4),a5
	lea (cvid_vmap0,d5.l),a6
	tst.b (a6)								; vmap = false?
	bne.s .lb5								; non, skip
	move.l a4,a1							; dest
	move.l d5,d0							
	bne.s .lb3
	move.l d2,d0
.lb3:
	subq.l #1,d0							; kk-1 or if kk=0, strips-1
	move.l (cvid_maps0,d0.l*4),a0		; source
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
	move.l (cvid_maps1,d0.l*4),a0		; source
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
	move (a2)+,d6			; topsize
	addq.l #4,a2
	move (a2)+,d0			; y1
	addq.l #2,a2	
	add d0,y_top			; works better???
	move screenh,d0
	cmp y_top,d0			; under the screen?
	bpl.s .good_height	; no, ok
	move d0,y_top			; else, this is the limit
.good_height:
	subq.l #8,d6
	subq.l #4,d6			; topsize-12
	sub x,a3				; image-x
	if c256=0
		sub x,a3			; one pixel=2bytes
	endif
	clr x
.lb9:
	tst.l d6
	bls .end_while       ; while topsize>0
	move (a2)+,d0			; cid
	moveq #0,d1
	move (a2)+,d1			; csize
	sub.l d1,d6				; topsize-csize
	subq.l #4,d1
	cmp #$2000,d0
	beq.s .case0
	cmp #$2200,d0
	bne.s .next1
	move.l a5,a0				; cvid_map
	move.l cvid_map_num,d0
	lea (cvid_vmap1,d0.l),a6
	bra.s .lb10
.case0:	
	move.l a4,a0				; cvid_map
	move.l cvid_map_num,d0
	lea (cvid_vmap0,d0.l),a6
.lb10:
	subq.l #1,d0
	bmi.s .comm0
	cmp.l d0,d5
	seq.b -(a6)					; set true only vmap(kk)
	bra.s .lb10
.comm0:
	if c256=0
		move.l hc_cvid,a1
	endif
	cmp.l #6,d1
	bmi.s .lb9
.lb11:
	if c256=0
		moveq #0,d0
		move.b 4(a2),d0
		lsl #5,d0
		move.b 5(a2),d0
		and.w #$1FF8,d0
		lsl.l #6,d0					; cr
		lea (a1,d0.l),a6			; hc_cvid[cr]
		moveq #0,d0
		move.b (a2)+,d0			; y1
		move.w (a6,d0.w*2),(a0)+	; fills	cvid_map
		move.b (a2)+,d0			; y2
		move.w (a6,d0.w*2),(a0)+
		move.b (a2)+,d0			; y3
		move.w (a6,d0.w*2),(a0)+
		move.b (a2)+,d0			; y4
		move.w (a6,d0.w*2),(a0)+
	else
		rept 2
		move.b (a2),d0
		ror #8,d0
		move.b (a2)+,d0
		swap d0
		move.b (a2),d0
		ror #8,d0
		move.b (a2)+,d0
		not.l d0
		move.l d0,(a0)+
		endr
	endif
	addq.l #2,a2				; skips cr
	subq.l #6,d1				; csize-6
	bgt.s .lb11
	bra .lb9
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
	move.l (a2)+,d7			; flag
	subq.l #4,d1				; csize-4
	if c256=0
		move.l hc_cvid,a1
	endif
	moveq #31,d2				; mask
.lb15:
	btst d2,d7					; mask and flag?	
	beq.s .lb13
.lb12:
	if c256=0
		moveq #0,d0
		move.b 4(a2),d0
		lsl #5,d0
		move.b 5(a2),d0
		and.w #$1FF8,d0
		lsl.l #6,d0					; cr
		lea (a1,d0.l),a6			; hc_cvid[cr]
		moveq #0,d0
		move.b (a2)+,d0			; y1
		move.w (a6,d0.w*2),(a0)+	; fills	cvid_map
		move.b (a2)+,d0			; y2
		move.w (a6,d0.w*2),(a0)+
		move.b (a2)+,d0			; y3
		move.w (a6,d0.w*2),(a0)+
		move.b (a2)+,d0			; y4
		move.w (a6,d0.w*2),(a0)+
	else
		rept 2
		move.b (a2),d0
		ror #8,d0
		move.b (a2)+,d0
		swap d0
		move.b (a2),d0
		ror #8,d0
		move.b (a2)+,d0
		not.l d0
		move.l d0,(a0)+
		endr
	endif
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
	bra .lb9
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
	bpl .lb22					; and while y < ytop
	move.l (a2)+,d7			; flag
	subq.l #4,d1				; csize-4
	moveq #31,d2				; mask
.lb20:
	move y,d0
	cmp y_top,d0
	bpl .lb21
	btst d2,d7					; mask and flag?
	beq.s .lb23
	moveq #0,d0
	move.b (a2)+,d0		; d0
	lea (a4,d0.w*8),a0	; cv_map_d0
	move.b (a2)+,d0		; d1
	lea (a4,d0.w*8),a1	; cv_map_d1
	move.l a3,a6			; ip_ptr
	if c256=0
		move (a0)+,(a6)+
		move (a0)+,(a6)+
		move (a1)+,(a6)+
		move (a1)+,(a6)
		add d3,a6				; +row_inc
		move (a0)+,(a6)+
		move (a0),(a6)+
		move (a1)+,(a6)+
		move (a1),(a6)
	else
		move.b (a0),(a6)+
		move.b 2(a0),(a6)+
		move.b (a1),(a6)+
		move.b 2(a1),(a6)+
		add d3,a6
		move.b 4(a0),(a6)+
		move.b 6(a0),(a6)+
		move.b 4(a1),(a6)+
		move.b 6(a1),(a6)+
	endif
	add d3,a6
	move.b (a2)+,d0		; d2
	lea (a4,d0.w*8),a0	; cv_map_d3
	move.b (a2)+,d0		; d4
	lea (a4,d0.w*8),a1	; cv_map_d4
	if c256=0
		move (a0)+,(a6)+
		move (a0)+,(a6)+
		move (a1)+,(a6)+
		move (a1)+,(a6)
		add d3,a6				; +row_inc
		move (a0)+,(a6)+
		move (a0),(a6)+
		move (a1)+,(a6)+
		move (a1),(a6)
	else
		move.b (a0),(a6)+
		move.b 2(a0),(a6)+
		move.b (a1),(a6)+
		move.b 2(a1),(a6)+
		add d3,a6
		move.b 4(a0),(a6)+
		move.b 6(a0),(a6)+
		move.b 4(a1),(a6)+
		move.b 6(a1),(a6)
	endif
	subq.l #4,d1				; csize-4
	bra.s .lb18
.lb23:
	moveq #0,d0
	move.b (a2)+,d0		; d
	lea (a5,d0.w*8),a0	; cv_map_d
	move.l a3,a6			; the screen
	move.l (a0)+,d0		; d0 up and d1 down
	if c256=0
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		move.l (a0),d0			; d0 up and d1 down
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
	else
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l (a0),d0			; d0 up and d1 down
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l d0,(a6)
	endif
	subq.l #1,d1
.lb18:
	addq #4,x
	if c256=0
		addq.l #8,a3				; each pixel is 2 bytes
	else
		addq.l #4,a3
	endif
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
	bpl .lb17
.lb22:
	add.l d1,a2					; dptr + csize
	move.l (sp)+,d2			; restores d2
	bra .lb9
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
	moveq #0,d0
	move.b (a2)+,d0		; d
	lea (a5,d0.w*8),a0	; cv_map_d
	move.l a3,a6			; the screen
	move.l (a0)+,d0		; d0 up and d1 down
	if c256=0
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		move.l (a0),d0			; d0 up and d1 down
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
	else
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l (a0),d0			; d0 up and d1 down
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l d0,(a6)
	endif
	subq.l #1,d1				; csize-1
	addq #4,x
	if c256=0
		addq.l #8,a3				; each pixel is 2 bytes
	else
		addq.l #4,a3
	endif
	move x,d0
	cmp max_imagex,d0
	bmi.s .lb24
	clr x
	addq #4,y
	add d4,a3					; image + y_inc
	bra .lb24
.lb25:
	add.l d1,a2					; dptr + csize
	bra .lb9
.next4:
	cmp #$3100,d0
	beq.s .case4
	cmp #$3300,d0
;	bne .lb9
	bne .out
	;****
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
	move.l (a2)+,d7			; flag
	subq.l #4,d1				; csize-4
	moveq #31,d2				; mask
.lb28:
	move y,d0
	cmp y_top,d0
	bpl.s .lb26					; end d2 loop and go to while
	btst d2,d7					; mask and flag?
	bne .mcode23
	subq #1,d2
	btst d2,d7
	bne .mcode1
	st flag0						; here mcode = 00
	tst.b flag1
	beq.s .lb29
	moveq #0,d0
	move.b (a2)+,d0		; d
	lea (a5,d0.w*8),a0	; cv_map_d
	move.l a3,a6			; the screen
	move.l (a0)+,d0		; d0 up and d1 down
	if c256=0
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		move.l (a0),d0			; d0 up and d1 down
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
	else
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l (a0),d0			; d0 up and d1 down
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l d0,(a6)
	endif
	subq.l #1,d1	
.lb29:
	sf flag1
.lb33:
	addq #4,x
	if c256=0
		addq.l #8,a3				; each pixel is 2 bytes
	else
		addq.l #4,a3
	endif
	move x,d0
	cmp max_imagex,d0
	bmi .end_mcode
	clr x
	addq #4,y
	add d4,a3					; image + y_inc
	bra .end_mcode
.mcode1:							; here mcode = 01
	st flag1
	tst.b flag2
	bne.s .lb30
	tst.b flag0
	beq.s .lb31
.lb30:
	sf flag0
	sf flag2
	bra .end_mcode
.lb31:
	moveq #0,d0
	move.b (a2)+,d0		; d
	lea (a5,d0.w*8),a0	; cv_map_d
	move.l a3,a6			; the screen
	move.l (a0)+,d0		; d0 up and d1 down
	if c256=0
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		move.l (a0),d0			; d0 up and d1 down
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
	else
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l (a0),d0			; d0 up and d1 down
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l d0,(a6)
	endif
	subq.l #1,d1
	bra .end_mcode
.mcode23:
	subq #1,d2
	btst d2,d7
	bne.s .mcode3
	st flag2						; here mcode = 10 (2)
	tst.b flag1
	beq.s .lb31
	moveq #0,d0
	move.b (a2)+,d0		; d0
	lea (a4,d0.w*8),a0	; cv_map_d0
	move.b (a2)+,d0		; d1
	lea (a4,d0.w*8),a1	; cv_map_d1
	move.l a3,a6			; ip_ptr
	if c256=0
		move (a0)+,(a6)+
		move (a0)+,(a6)+
		move (a1)+,(a6)+
		move (a1)+,(a6)
		add d3,a6				; +row_inc
		move (a0)+,(a6)+
		move (a0),(a6)+
		move (a1)+,(a6)+
		move (a1),(a6)
	else
		move.b (a0),(a6)+
		move.b 2(a0),(a6)+
		move.b (a1),(a6)+
		move.b 2(a1),(a6)+
		add d3,a6
		move.b 4(a0),(a6)+
		move.b 6(a0),(a6)+
		move.b 4(a1),(a6)+
		move.b 6(a1),(a6)+
	endif
	add d3,a6
	move.b (a2)+,d0		; d2
	lea (a4,d0.w*8),a0	; cv_map_d3
	move.b (a2)+,d0		; d4
	lea (a4,d0.w*8),a1	; cv_map_d4
	if c256=0
		move (a0)+,(a6)+
		move (a0)+,(a6)+
		move (a1)+,(a6)+
		move (a1)+,(a6)
		add d3,a6				; +row_inc
		move (a0)+,(a6)+
		move (a0),(a6)+
		move (a1)+,(a6)+
		move (a1),(a6)
	else
		move.b (a0),(a6)+
		move.b 2(a0),(a6)+
		move.b (a1),(a6)+
		move.b 2(a1),(a6)+
		add d3,a6
		move.b 4(a0),(a6)+
		move.b 6(a0),(a6)+
		move.b 4(a1),(a6)+
		move.b 6(a1),(a6)
	endif
	subq.l #4,d1
	bra .lb29
.mcode3:							; here mcode = 11 (3)
	moveq #0,d0
	move.b (a2)+,d0		; d0
	lea (a4,d0.w*8),a0	; cv_map_d0
	move.b (a2)+,d0		; d1
	lea (a4,d0.w*8),a1	; cv_map_d1
	move.l a3,a6			; ip_ptr
	if c256=0
		move (a0)+,(a6)+
		move (a0)+,(a6)+
		move (a1)+,(a6)+
		move (a1)+,(a6)
		add d3,a6				; +row_inc
		move (a0)+,(a6)+
		move (a0),(a6)+
		move (a1)+,(a6)+
		move (a1),(a6)
	else
		move.b (a0),(a6)+
		move.b 2(a0),(a6)+
		move.b (a1),(a6)+
		move.b 2(a1),(a6)+
		add d3,a6
		move.b 4(a0),(a6)+
		move.b 6(a0),(a6)+
		move.b 4(a1),(a6)+
		move.b 6(a1),(a6)+
	endif
	add d3,a6
	move.b (a2)+,d0		; d2
	lea (a4,d0.w*8),a0	; cv_map_d3
	move.b (a2)+,d0		; d4
	lea (a4,d0.w*8),a1	; cv_map_d4
	if c256=0
		move (a0)+,(a6)+
		move (a0)+,(a6)+
		move (a1)+,(a6)+
		move (a1)+,(a6)
		add d3,a6				; +row_inc
		move (a0)+,(a6)+
		move (a0),(a6)+
		move (a1)+,(a6)+
		move (a1),(a6)
	else
		move.b (a0),(a6)+
		move.b 2(a0),(a6)+
		move.b (a1),(a6)+
		move.b 2(a1),(a6)+
		add d3,a6
		move.b 4(a0),(a6)+
		move.b 6(a0),(a6)+
		move.b 4(a1),(a6)+
		move.b 6(a1),(a6)
	endif
	subq.l #4,d1
.end_mcode:
	addq #4,x
	if c256=0
		addq.l #8,a3				; each pixel is 2 bytes
	else
		addq.l #4,a3
	endif
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
	bra .lb9
.end_while:
	addq.l #1,d5			; kk++
	cmp.l d2,d5
	bmi .lb2					; loops if kk<strips		
.out:
	rts

	if c256=0
qt_smc:
	lea cvid_fix0,a6
	else
qt_smc_256:
	endif
	clr x
	clr y
	clr smc_8
	clr smc_a
	clr smc_c
	move screenw,d3
	subq #4,d3
	if c256=0
		add d3,d3					; row_inc
	endif
	move.l buffer,a2
	move.l (a2)+,d0
	and.l #$ffffff,d0
	cmp.l bufused,d0
	bmi.s .ok_size
	move.l bufused,d0
.ok_size:
	subq.l #4,d0
	add.l a2,d0			; end adress
	bra.s .while
.exit: 
	rts
.while:
	cmp.l d0,a2
	bpl.s .exit
.lb0:
	moveq #0,d1
	move.b (a2)+,d1			; code
	cmp #$20,d1
	bpl.s .case2
	cmp #$10,d1
	bmi.s .lb1
	move.b (a2)+,d1			; cnt if hicode=1
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
.lb4:
	dbf d1,.lb3
	bra.s .while
.case2:
	cmp #$40,d1
	bpl.s .case4
	cmp #$30,d1
	bmi.s .lb5
	move.b (a2)+,d1
	bra.s .lb6
.lb5:
	and #$f,d1
.lb6:
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
		lea -8(a3),a4			; last bloc, o_tmp
	else
		add.l d2,a3
		lea -4(a3),a4
	endif
	tst x
	bne.s .lb7
	move screenw,d2
	neg d2
	if c256=0
		lea (a4,d2.w*8),a4	; one line up
		add d3,a4
		addq.l #8,a4			; end of line
	else
		lea (a4,d2.w*4),a4
		add d3,a4
		addq.l #4,a4
	endif
.lb7:
	if c256=0
		bsr qt_smc_o2i
	else
		bsr qt_smc_o2i_256
	endif
	dbf d1,.lb7
	bra .while	
.case4:
	cmp #$60,d1
	bpl .case6
	cmp #$50,d1
	bmi.s .lb8
	move.b (a2)+,d1
	bra.s .lb9
.lb8:
	and #$f,d1
.lb9:	
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
		lea -16(a3),a5			; o2tmp (2 blocs)
	else
		add.l d2,a3
		lea -8(a3),a5
	endif
	move x,d4				; mtx
	move y,d5				; mty
	subq #8,d4
	bpl.s .lb10
	add max_imagex,d4
	subq #4,d5
	move screenw,d2
	neg d2
	if c256=0
		lea (a5,d2.w*8),a5	; one line up
		add d3,a5
		addq.l #8,a5			; end of line
	else
		lea (a5,d2.w*4),a5
		add d3,a5
		addq.l #4,a5
	endif
.lb10:
	move.l a5,a4
	moveq #0,d6
	move d4,d6
	move d5,d7
	if c256=0
		bsr qt_smc_o2i
		addq #4,d6				; tx
		addq.l #8,a4
	else
		bsr qt_smc_o2i_256
		addq #4,d6
		addq.l #4,a4
	endif
	move max_imagex,d2
	cmp d6,d2
	bgt.s .lb11
	moveq #0,d6
	addq #4,d7
	move.l image,a3
	move d7,d2
	muls screenw,d2
	add.l d6,d2
	if c256=0
		lea (a4,d2.l*2),a4	; o_tmp
	.lb11:
		bsr qt_smc_o2i
	else
		add.l d2,a4
	.lb11:
		bsr qt_smc_o2i_256
	endif
	dbf d1,.lb10
	bra .while
.case6:
	cmp #$80,d1
	bpl.s .case8
	cmp #$70,d1
	bmi.s .lb12
	move.b (a2)+,d1
	bra.s .lb13
.lb12:
	and #$f,d1
.lb13:
	if c256=0
		moveq #0,d4
		move.b (a2)+,d4	; ct
		move.w (a6,d4.w*2),d4	; true color
	else
		move.b (a2)+,d4
		move.b d4,d2
		lsl #8,d4
		move.b d2,d4
	endif
	move d4,d2
	swap d4
	move d2,d4					; into high word
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
	.lb14:
		bsr qt_smc_c1
	else
		add.l d2,a3
	.lb14:
		bsr qt_smc_c1_256
	endif
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
	if c256=0
		lea (a0,d2.w*4),a0
		addq #1,smc_8
		move.b (a2)+,d2
		move (a6,d2.w*2),(a0)
		move.b (a2)+,d2
		move (a6,d2.w*2),2(a0)
	else
		lea (a0,d2.w*2),a0
		addq #1,smc_8
		move.b (a2)+,(a0)
		move.b (a2)+,1(a0)
	endif
	bra.s .lb16
.lb15:
	move.b (a2)+,d2
	if c256=0
		lea (a0,d2.w*4),a0
	else
		lea (a0,d2.w*2),a0
	endif
.lb16:
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp	
		and #$f,d1				; cnt
		move (a0)+,d4
		move (a0)+,d5			; c0, c1
	else
		add.l d2,a3
		and #$f,d1
		move.b (a0)+,d4
		move.b (a0)+,d5
	endif
.lb17:
	move.l a3,a0
	move.b (a2)+,d6		; msk0
	if c256=0
		bsr qt_smc_c2
	else
		bsr qt_smc_c2_256
	endif
	move.b (a2)+,d6		; msk1
	add d3,a0
	if c256=0
		bsr qt_smc_c2
	else
		bsr qt_smc_c2_256
	endif
	addq #4,x
	if c256=0
		addq.l #8,a3
	else
		addq.l #4,a3
	endif
	move max_imagex,d2
	cmp x,d2
	bgt.s .lb18
	clr x
	addq #4,y
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
	else
		add.l d2,a3
	endif
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
	if c256=0
		lea (a0,d2.w*8),a0
		addq #1,smc_a
		move.b (a2)+,d2
		move (a6,d2.w*2),(a0)
		move.b (a2)+,d2
		move (a6,d2.w*2),2(a0)
		move.b (a2)+,d2
		move (a6,d2.w*2),4(a0)
		move.b (a2)+,d2
		move (a6,d2.w*2),6(a0)
	else
		lea (a0,d2.w*4),a0
		addq #1,smc_a
		move.b (a2)+,(a0)+
		move.b (a2)+,(a0)+
		move.b (a2)+,(a0)+
		move.b (a2)+,(a0)
		subq.l #3,a0
	endif
	bra.s .lb20
.lb19:
	move.b (a2)+,d2
	if c256=0
		lea (a0,d2.w*8),a0
	else
		lea (a0,d2.w*4),a0
	endif
.lb20:
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp	
	else
		add.l d2,a3
	endif
	and #$f,d1				; cnt
.lb21:
	move.l a3,a1
	move.l (a2)+,d4		; mask0-3
	if c256=0
		bsr qt_smc_c4
		addq #4,x
		addq.l #8,a3
	else
		bsr qt_smc_c4_256
		addq #4,x
		addq.l #4,a3
	endif
	move max_imagex,d2
	cmp x,d2
	bgt.s .lb22
	clr x
	addq #4,y
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
	else
		add.l d2,a3
	endif
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
	lea (a0,d2.w*8),a0
	if c256=0
		lea (a0,d2.w*8),a0
		addq #1,smc_c
		rept 8
		move.b (a2)+,d2
		move (a6,d2.w*2),(a0)+
		endr
		sub #16,a0
	else
		addq #1,smc_c
		rept 8
		move.b (a2)+,(a0)+
		endr
		subq.l #8,a0
	endif
	bra.s .lb24
.lb23:
	move.b (a2)+,d2
	lea (a0,d2.w*8),a0
	if c256=0
		lea (a0,d2.w*8),a0
	endif
.lb24:
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp	
	else
		add.l d2,a3
	endif
	and #$f,d1				; cnt
.lb25:
	move.l a3,a1
	move (a2)+,d6
	if c256=0
		bsr qt_smc_c8
	else
		bsr qt_smc_c8_256
	endif
	move d6,d7
	move (a2)+,d6
	if c256=0
		bsr qt_smc_c8
	else
		bsr qt_smc_c8_256
	endif
	lsr #4,d6
	or d6,d7
	move (a2)+,d6
	if c256=0
		bsr qt_smc_c8
	else
		bsr qt_smc_c8_256
	endif
	lsr #8,d6
	or d7,d6
	if c256=0
		bsr qt_smc_c8
		addq #4,x
		addq.l #8,a3
	else
		bsr qt_smc_c8_256
		addq #4,x
		addq.l #4,a3
	endif
	move max_imagex,d2
	cmp x,d2
	bgt.s .lb26
	clr x
	addq #4,y
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
	else
		add.l d2,a3
	endif
.lb26:
	dbf d1,.lb25
	bra .while
.casee:						; $ex	
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp	
	else
		add.l d2,a3
	endif
	and #$f,d1				; cnt
	moveq #0,d4
.lb27:
	move.l a3,a1
	rept 4
	rept 4
	if c256=0
		move.b (a2)+,d4
		move (a6,d4.w*2),(a1)+
	else
		move.b (a2)+,(a1)+
	endif
	endr
	add d3,a1
	endr
	addq #4,x
	if c256=0
		addq.l #8,a3
	else
		addq.l #4,a3
	endif
	move max_imagex,d2
	cmp x,d2
	bgt.s .lb28
	clr x
	addq #4,y
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
	else
		add.l d2,a3
	endif
.lb28:
	dbf d1,.lb27
	bra .while	

	if c256=0	
qt_smc_c8:
	else
qt_smc_c8_256
	endif
	rept 4
	moveq #0,d2
	lsl #1,d6
	roxl #1,d2
	lsl #1,d6
	roxl #1,d2
	lsl #1,d6
	roxl #1,d2
	if c256=0
		move (a0,d2.w*2),(a1)+
	else
		move.b (a0,d2.w),(a1)+
	endif
	endr
	add d3,a1
	rts
	
	if c256=0
qt_smc_c4:
	else
qt_smc_c4_256:
	endif
	moveq #3,d5
.lb0:
	rept 4
	moveq #0,d2
	lsl.l #1,d4
	roxl #1,d2
	lsl.l #1,d4
	roxl #1,d2
	if c256=0
		move.w (a0,d2.w*2),(a1)+
	else
		move.b (a0,d2.w),(a1)+
	endif
	endr
	add d3,a1
	dbf d5,.lb0
	rts
	
	if c256=0
qt_smc_c2:
	btst #7,d6
	beq.s .lb0
	move d5,(a0)+
	bra.s .lb1
.lb0:
	move d4,(a0)+
.lb1:	
	btst #6,d6
	beq.s .lb2
	move d5,(a0)+
	bra.s .lb3
.lb2:
	move d4,(a0)+
.lb3:
	btst #5,d6
	beq.s .lb4
	move d5,(a0)+
	bra.s .lb5
.lb4:
	move d4,(a0)+
.lb5:
	btst #4,d6
	beq.s .lb6
	move d5,(a0)+
	bra.s .lb7
.lb6:
	move d4,(a0)+
.lb7:
	add d3,a0
	btst #3,d6
	beq.s .lb8
	move d5,(a0)+
	bra.s .lb9
.lb8:
	move d4,(a0)+
.lb9:
	btst #2,d6
	beq.s .lb10
	move d5,(a0)+
	bra.s .lb11
.lb10:
	move d4,(a0)+
.lb11:
	btst #1,d6
	beq.s .lb12
	move d5,(a0)+
	bra.s .lb13
.lb12:
	move d4,(a0)+
.lb13:
	btst #0,d6
	beq.s .lb14
	move d5,(a0)+
	rts
.lb14:
	move d4,(a0)+
	rts
	
	else
	
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

	endif

	if c256=0
qt_smc_o2i:
	else
qt_smc_o2i_256:
	endif
	move.l a3,a0		; dest
	move.l a4,a1		; source
	rept 3
		move.l (a1)+,(a0)+
		if c256=0
			move.l (a1)+,(a0)+
		endif
		add d3,a0
		add d3,a1
	endr
	if c256=0
		move.l (a1)+,(a0)+
	endif
	move.l (a1),(a0)
	addq #4,x
	if c256=0
		addq.l #8,a3
	else
		addq.l #4,a3
	endif
	move max_imagex,d2
	cmp x,d2
	bgt.s .end
	clr x
	addq #4,y
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
	else
		add.l d2,a3
	endif
.end:
	rts

	if c256=0
qt_smc_c1:
	else
qt_smc_c1_256
	endif
	move.l a3,a0		; dest
	rept 3
		if c256=0
			move.l d4,(a0)+
		endif
		move.l d4,(a0)+
		add d3,a0
	endr
	if c256=0
		move.l d4,(a0)+
	endif
	move.l d4,(a0)
	addq #4,x
	if c256=0
		addq.l #8,a3
	else
		addq.l #4,a3
	endif
	move max_imagex,d2
	cmp x,d2
	bgt.s .end
	clr x
	addq #4,y
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
	else
		add.l d2,a3
	endif
.end:
	rts

	if c256=0
intel_iv32:
	else
	
xqto4n: dc.w 0
yqto4n: dc.w 0	
xto4n: dc.w 0
yto4n: dc.w 0
iv32_uv_inc: dc.w 0
iv32_entry: dc.l 0
iv32_freq: dc.w $0101

intel_iv32_256:
	endif
 MOVE.L buffer,A2
 move.l 12(a2),d0
 INTEL d0			; size of frame
 cmp.l #50,d0
 bmi .gloups2
 lea 16(a2,d0.l),a1	; end of frame 
 LEA 16+2(A2),A2	;+2 => version
 MOVE (A2)+,D0	;flags
 MOVE.L (A2)+,D5	;lecture d'un .Li ->D5 =8*taille donn‚es utiles
 MOVEQ #0,D7
 MOVE.B (A2)+,D7 ; cboffset
 ADDQ.l #3,A2	;saute cbset
 MOVE (A2)+,D6	;hauteur
 ROR #8,D6	;format intel => motorola
 CMP max_imagey,D6
 BNE .fin
 swap d6
 MOVE (A2)+,D6	;largeur
 ROR #8,D6	;format intel -> motorola
 CMP max_imagex,D6
 BNE .fin ; bad dimensions
 MOVEM.L (A2)+,D2-D4	;lit les 3 offsets
 INTEL d2
 INTEL d3
 INTEL d4
 ADDQ.l #4,A2
 MOVE.L A2,A5		; a5=buffer+48
 CMP.L #128,D5
 beq .fin ; bad dimensions
 LEA -32(A5,D2.L),A0	;offset donn‚es Y
 MOVE.L (A0)+,D1	;1.Li
 INTEL d1
 lea iv32_ptrs,a3
 lea 12(a3),a2
 BTST #1,D0	;buffer swapping
 Bne.S .lb43
 exg.l a2,a3
.lb43:
 MOVE D6,D2	;largeur anim
 CMP #160,D6
 BLS.S .lb45
 MOVE #160,D2
.lb45:  MOVE D2,-(SP)	;largeur bloc
 MOVE.L A0,-(SP)	;donn‚es Y
 MOVE.L A5,-(SP)	;donn‚es entˆte
 MOVE d7,-(SP)	;cboffset
 pEA (A0,D1.L*2)	;donn‚es compress‚s
 swap d6
 MOVE.l d6,-(SP)	; x and y at the same time
 MOVE.L (A3),-(SP)	;ybuf
 MOVE.L (A2),-(SP)
 move.l iv32_entry(pc),a0
 jsr (a0)
 LEA 28(SP),SP
 bne .fin	; plan Y
 
 if c256=0
	if REG=1
		tst.b fast_mode
		bne .fast_display
	endif

 LEA -32(A5,D3.L),A0	;offset donn‚es U
 MOVE.L (A0)+,D1
 INTEL d1
 MOVEQ #0,D6
 move xqto4n(pc),d2
 CMP #40,D2
 BLS.S .lb47
 MOVEQ #40,D2
.lb47:  MOVE D2,-(SP)	;largeur bloc
 MOVE.L A0,-(SP)	;donn‚es U
;
 MOVE.L A5,-(SP)	;donn‚es entˆte
 MOVE d7,-(SP)	;cboffset
; subq.l #6,sp
 pea (a0,d1.l*2)	;donn‚es compress‚s
 MOVE.l xqto4n(pc),-(SP)	;hauteur/4 + largeur
 MOVE.L 8(A3),-(SP)
 MOVE.L 8(A2),-(SP)
 move.l iv32_entry(pc),a0
 jsr (a0)
 LEA 28(SP),SP
 Bne .fin	; plan U
 LEA -32(A5,D4.L),A0	;offset donn‚es V
 MOVE.L (A0)+,D1
 INTEL d1
;
 MOVE D2,-(SP)	;largeur bloc
; subq.l #2,sp
 MOVE.L A0,-(SP)	;donn‚es V
;
 MOVE.L A5,-(SP)	;donn‚es entˆte
 MOVE d7,-(SP)	;cboffset
; subq.l #6,sp
 pea (a0,d1.l*2)	;donn‚es compress‚s
;
 move.l xqto4n(pc),-(sp)
; subq.l #4,sp
 MOVE.L 4(A3),-(SP)
 MOVE.L 4(A2),-(SP)
 move.l iv32_entry(pc),a0
 jsr (a0)
 LEA 28(SP),SP
 Bne .fin	; plan V
 move iv32_freq(pc),d0
 subq.b #1,d0
 beq.s .on_affiche
 move d0,iv32_freq
 rts							; n'affiche pas 
.on_affiche:
 lsr #8,d0
 move.b d0,iv32_freq+1	; reset counter
 MOVE.L (A2)+,A0	;source tableau y
 MOVE.L (A2)+,A6	;source tableau u
 MOVE.L (A2),A5	;source tableau v
 move.l hc_cvid,a1	; conversion
 move.l image,a3
	move xto4n(pc),d0
	move yto4n(pc),d7
	subq #4,d0
	lsr #2,d7
	move screenw,d3
	subq #4,d3
	move iv32_uv_inc(pc),d5
	add d3,d3			; screen inc
	move #$1FF8,d4
	moveq #0,d1
 bra .line_loop
.line:
	move d0,d5
	lsr #2,d5
	bra.s .skip_init
.one_bloc:
	move.l a2,a3
	move.l d2,a0
.skip_init:
 moveq #0,d6
 move.b (a6)+,d6
 lsl #6,d6
 move.b (a5)+,d6
 add.b d6,d6
 and.w #$1FF8,d6	; and.w d4,d6
 lsl.l #6,d6
 lea (a1,d6.l),a4	; conversion
 rept 4
	 move.b (a0)+,d1
	 move (a4,d1*2),(a3)+
 endr
 move.l a3,a2		; saves for next bloc
 move.l a0,d2		; same
 rept 3
 	add d3,a3
	 add d0,a0
	 rept 4
 		move.b (a0)+,d1
	 	move (a4,d1*2),(a3)+
	 endr
 endr
	dbf d5,.one_bloc 
.common:
	swap d5
	add d3,a3
	add d5,a5
	sub d0,a3
	add d5,a6
	sub d0,a3
.line_loop:
	swap d5
	dbf d7,.line
.fin:
; 	bra.s .gloups2
.gloups2:
	rts

	if REG=1
.fast_display:
 move iv32_freq(pc),d0
 subq.b #1,d0
 beq.s .on_affiche_fast
 move d0,iv32_freq
 rts							; n'affiche pas 
.on_affiche_fast:
 lsr #8,d0
 move.b d0,iv32_freq+1	; reset counter
	move.l (a2),a0		; Y plan
	move.l image,a3		; screen
	move screenw,d3
	move xto4n(pc),d7
	move.l hc_cvid,a4
	sub d7,d3				; screen inc
	add d3,d3
	move yto4n(pc),d6
	lsr #2,d7				; 4 par 4
	subq #1,d7
	moveq #0,d1
	bra.s .loop
.copy:
	move d7,d0
.pix4:
	rept 4
		move.b (a0)+,d1
		move 0(a4,d1.w*2),(a3)+
	endr
	dbf d0,.pix4
	add d3,a3
.loop:
	dbf d6,.copy	
	rts 
	endif

 else		; if c256=1, only Y and direct copy!!!
 
 move iv32_freq(pc),d0
 subq.b #1,d0
 beq.s .on_affiche_256
 move d0,iv32_freq
 rts							; n'affiche pas 
.on_affiche_256:
 lsr #8,d0
 move.b d0,iv32_freq+1	; reset counter
	move.l (a2),a0		; Y plan
	move.l image,a3		; screen
	move screenw,d3
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
	not.l d1
	add.l d1,d1
	move.l d1,(a3)+
	dbf d0,.pix4
	add d3,a3
.loop:
	dbf d6,.copy	
.fin:
;	bra.s .gloups2 
.gloups2:
	rts 
	
	endif


	if c256=0
qt_raw:
	lea cvid_fix0,a6			; the palette
	else
qt_raw_256:
	endif
	move.l buffer,a2
	move.l image,a3
	move screenw,d3
	move.l imagey,d5
	move.l bufused,d4
	divs d5,d4						; max image x according to bufused
	sub d4,d3
	if c256=0
		add d3,d3					; row_inc
		moveq #0,d2
	endif
	subq #1,d4
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	if c256=0
		move.b (a2)+,d2
		move (a6,d2.w*2),(a3)+
	else
		move.b (a2)+,(a3)+
	endif
	dbf d0,.lb1
	add d3,a3
.y_loop:
	dbf d5,.lb0
	rts	

	if c256=0
qt_raw4:
	lea cvid_fix0,a6			; the palette
	else
qt_raw4_256:
	endif
	move.l buffer,a2
	move.l image,a3
	move screenw,d3
	move.l imagex,d4
	addq #7,d4
	and.b #$F8,d4
	sub d4,d3
	if c256=0
		add d3,d3					; row_inc
	endif
	moveq #0,d2
	moveq #0,d7
	move.l imagey,d5
	lsr #1,d4						; one byte=2 pixels
	subq #1,d4
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	if c256=0
		moveq #0,d2
		move.b (a2)+,d2
		ror.l #4,d2
		move (a6,d2.w*2),(a3)+
		swap d2
		rol #5,d2
		move (a6,d2.w),(a3)+
	else
		moveq #0,d2
		move.b (a2)+,d2
		lsl #4,d2
		lsr.b #4,d2
		move d2,(a3)+
	endif
	dbf d0,.lb1
	add d3,a3
.y_loop:
	dbf d5,.lb0
	rts	

	if c256=0
qt_raw1:
	else
qt_raw1_256:
	endif
	move.l buffer,a2			; keep those 6 bytes first (CDV)
	move.l image,a3
	move screenw,d3
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
	if c256=0
		add d3,d3					; row_inc
	endif
	moveq #0,d2
	moveq #0,d7
	lsr #3,d4						; one byte=8 pixels
	subq #1,d4
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	if c256=0
		move.b (a2)+,d2
		rept 7
			spl (a3)+
			spl (a3)+
			lsl.b #1,d2
		endr
		spl (a3)+
		spl (a3)+
	else
		move.b (a2)+,d2
		rept 7
			smi (a3)+
			lsl.b #1,d2
		endr
		smi (a3)+
	endif
	dbf d0,.lb1
	add d3,a3
.y_loop:
	dbf d5,.lb0
	rts	

	if c256=0
qt_raw2:
	lea cvid_fix0,a6
	else
qt_raw2_256:
	endif
	move.l buffer,a2
	move.l image,a3
	move screenw,d3
	move.l bufused,d4
	asl.l #2,d4
	move.l imagey,d5
	divs d5,d4
	sub d4,d3
	if c256=0
		add d3,d3					; row_inc
	endif
	moveq #0,d2
	moveq #0,d7
	lsr #2,d4						; one byte=4 pixels
	subq #1,d4
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	if c256=0
		move.b (a2)+,d2
		rept 4
			moveq #0,d6
			lsl.b d2
			roxl.b d6			
			lsl.b d2
			roxl.b d6
			move (a6,d6.w*2),(a3)+
		endr
	else
		move.b (a2)+,d2
		rept 4
			moveq #0,d6
			lsl.b d2
			roxl.b d6
			lsl.b d2
			roxl.b d6
			move.b d6,(a3)+
		endr
	endif
	dbf d0,.lb1
	add d3,a3
.y_loop:
	dbf d5,.lb0
	rts
	
	if c256=0
qt_rle1:
	else
qt_rle1_256:
	endif
	move.l image,a3
	move.l buffer,a2
	move screenw,d3
	if c256=0
		add d3,d3		; inc for one line
	endif
	addq.l #5,a2		; codec size + one byte
	btst #3,(a2)+		; flag and $8
	bne.s .lb0			; if 8, header present
.exit:
	rts					; else, nop frame
.lb0:
	move (a2)+,d0		; start line
	muls d3,d0			; offset
	add.l d0,a3			; start into screen
	addq.l #2,a2
	move (a2)+,d0		; number of lines	
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
	if c256=0
		lsl #5,d1
	else
		lsl #4,d1
	endif
	add d1,a3		; skips pixels
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
	if c256=0
		rept 8
		move.l (a0)+,(a3)+
		endr
	else
		rept 4
		move.l (a0)+,(a3)+
		endr
	endif
.lb2:
	dbf d1,.rep	
	bra.s .line
.one_word:
	moveq #1,d4
.again:
	if c256=0
		move.b (a2)+,d2
		rept 7
			spl (a3)+
			spl (a3)+
			lsl.b #1,d2
		endr
		spl (a3)+
		spl (a3)+
	else
		move.b (a2)+,d2
		rept 7
			smi (a3)+
			lsl.b #1,d2
		endr
		smi (a3)+
	endif		
	dbf d4,.again
	rts	

	if c256=0
qt_rle2:
	lea cvid_fix0,a6	; the palette
	else
qt_rle2_256:
	endif
	move.l image,a3
	move.l buffer,a2
	move screenw,d3
	if c256=0
		add d3,d3		; inc for one line
	endif
	addq.l #5,a2		; codec size + one byte
	btst #3,(a2)+		; flag and $8
	bne.s .lb0			; if 8, header present
.exit:
	rts					; else, nop frame
.lb0:
	move (a2)+,d0		; start line
	muls d3,d0			; offset
	add.l d0,a3			; start into screen
	addq.l #2,a2
	move (a2)+,d0		; number of lines	
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
	if c256=0
		rept 8
		move.l (a0)+,(a3)+
		endr
	else
		rept 4
		move.l (a0)+,(a3)+
		endr
	endif
.lb2:
	dbf d1,.rep	
	bra.s .line
.one_long:
	moveq #1,d4
.again:
	if c256=0
		move (a2)+,d2
		rept 8
			moveq #0,d0
			lsl d2
			roxl d0
			lsl d2
			roxl d0
			move (a6,d0.w*2),(a3)+
		endr
	else
		move (a2)+,d2
		rept 8
			moveq #0,d0
			lsl d2
			roxl.b d0
			lsl d2
			roxl.b d0
			move.b d0,(a3)+
		endr
	endif		
	dbf d4,.again
	rts	

	if c256=0
qt_rle4:
	lea cvid_fix0,a6	; the palette
	else
qt_rle4_256:
	endif
	move.l image,a3
	move.l buffer,a2
	move screenw,d3
	if c256=0
		add d3,d3		; inc for one line
	endif
	addq.l #5,a2		; codec size + one byte
	btst #3,(a2)+		; flag and $8
	bne.s .lb0			; if 8, header present
.exit:
	rts					; else, nop frame
.lb0:
	move (a2)+,d0		; start line
	muls d3,d0			; offset
	add.l d0,a3			; start into screen
	addq.l #2,a2
	move (a2)+,d0		; number of lines	
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
	if c256=0
		rept 4
		move.l (a0)+,(a3)+
		endr
	else
		move.l (a0)+,(a3)+
		move.l (a0)+,(a3)+
	endif
.lb2:
	dbf d1,.rep	
	bra.s .line
.one_long:
	moveq #1,d4
.again:
	if c256=0
		rept 2
		moveq #0,d2
		move.b (a2)+,d2
		moveq #15,d0
		and d2,d0
		lsr #4,d2
		move (a6,d2.w*2),(a3)+
		move (a6,d0.w*2),(a3)+
		endr
	else
		rept 2
		move.b (a2)+,d2
		unpk d2,d0,#0
		move d0,(a3)+
		endr
	endif
	dbf d4,.again
	rts

	if c256=0	
qt_rle8:
	lea cvid_fix0,a6
	moveq #0,d4
	else
qt_rle8_256:
	endif
	move.l image,a3
	move.l buffer,a2
	move screenw,d3
	if c256=0
		add d3,d3
	endif
	addq.l #5,a2		; codec size + one byte
	btst #3,(a2)+		; flag and $8
	bne.s .lb0			; if 8, header present
	rts					; else, nop frame
.lb0:
	move (a2)+,d0		; start line
	muls d3,d0			; offset
	add.l d0,a3			; start into screen
	addq.l #2,a2
	move (a2)+,d0		; number of lines
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
	if c256=0
		lea -8(a3,d2.w*8),a3	; skips blocs
	else
		lea -4(a3,d2.w*4),a3
	endif
.cnt:
	move.b (a2)+,d2	; code
	bne.s .case80
	move.b (a2)+,d2
	if c256=0
		lea -8(a3,d2.w*8),a3 ; skips
	else
		lea -4(a3,d2.w*4),a3
	endif
	bra.s .cnt
.case80:
	bmi.s .repeat
	subq #1,d2
.run:
	if c256=0
	rept 4
		move.b (a2)+,d4
		move (a6,d4.w*2),(a3)+
	endr
	else
		move.l (a2)+,(a3)+
	endif		
	dbf d2,.run
	moveq #0,d2
	bra.s .cnt
.repeat:
	sub #256,d2
	neg d2
	subq #1,d2
	beq.s .while		; it was $FF=end of line
	if c256=0
		move.b (a2)+,d4
		move (a6,d4.w*2),d5
		swap d5
		move.b (a2)+,d4
		move (a6,d4.w*2),d5
		move.b (a2)+,d4
		move (a6,d4.w*2),d6
		swap d6
		move.b (a2)+,d4
		move (a6,d4.w*2),d6
	else
		move.b (a2)+,d5
		lsl #8,d5
		move.b (a2)+,d5
		swap d5
		move.b (a2)+,d5
		lsl #8,d5
		move.b (a2)+,d5
	endif
.rep:
	move.l d5,(a3)+
	if c256=0
		move.l d6,(a3)+
	endif
	dbf d2,.rep
	moveq #0,d2
	bra.s .cnt


	if c256=0
qt_yuv2:
	move.l hc_cvid,a1
	else
qt_yuv2_256:
	endif
	move.l image,a3
	move.l buffer,a2
	move.l imagey,d5
	move.l bufused,d4
	divs d5,d4				; number of columns according to buffer size
	lsr #1,d4				; one pixel = 2 bytes
	subq #1,d5
	move #$F8,d7
	move screenw,d3
	sub d4,d3
	subq #1,d4
	if c256=0
		add d3,d3
	endif
	moveq #0,d0
	moveq #0,d1
.loop:
	move d4,d6
.line:
	if c256=0
		move.b (a2)+,d0		; y0
		moveq #0,d2
		move.b (a2)+,d2		; u
		lsl #5,d2
		move.b (a2)+,d1		; y1
		move.b (a2)+,d2		; v
		and.b d7,d2
		lsl.l #6,d2				; uuuuuvvvvv0 00000000
		lea (a1,d2.l),a4
		move (a4,d0.w*2),(a3)+
		move (a4,d1.w*2),(a3)+
	else
		move.b (a2)+,d0
		not.b d0
		move.b d0,(a3)+	; y0
		move.w (a2)+,d0	; u and y1
		not.b d0
		move.b d0,(a3)+	; y1
		addq.l #1,a2
	endif
	subq #1,d6
	dbf d6,.line			; next 2 pixels
	add d3,a3
	dbf d5,.loop			; next line
	rts
	
	if c256=0
qt_yuv9:
	move.l hc_cvid,a1
	else
qt_yuv9_256:
	endif
	move.l image,a3
	move.l buffer,a2	; Yptr
	
	move max_imagey,d5
	move max_imagex,d4
	if c256=0
		move d4,d7
		muls d5,d7
		lea (a2,d7.l),a0	; Vptr
		lsl.l #4,d7			; Vptr = yptr /16 (size)
		add.l a0,d7			; Uptr
	endif
	subq #1,d5
	move screenw,d3
	sub d4,d3
	lsr #2,d4			; pixels come 4 at a time
	subq #1,d4
	if c256=0
		add d3,d3
	endif
	moveq #0,d0
	moveq #0,d1			; y
.loop:
	move d4,d6
	if c256=0
		move.l d7,a5			; Up
		move.l a0,a6			; Vp
	endif
.line:
	if c256=0
		move.b (a5)+,d2		; u
		lsl #5,d2
		move.b (a6)+,d2		; v
		and.b #$f8,d2
		lsl.l #6,d2				; uuuuuvvvvv0 00000000
		lea (a1,d2.l),a4
		rept 4
			move.b (a2)+,d0	; Y0,1,2,3
			move (a4,d0.w*2),(a3)+	; corresponding RGB
		endr
	else
		move.l (a2)+,d0		; y0123
		not.l d0
		move.l d3,(a3)+
	endif
	subq #1,d6
	dbf d6,.line			; next 2 pixels
	add d3,a3
	if c256=0
		moveq #3,d0
		and d0,d1				; y mod 4
		cmp d0,d1
		bne.s .no
		move.l a5,d7			; every 4 lines, new UV
		move.l a6,a0
		.no:		
	endif
	dbf d5,.loop			; next line
	rts
	
	
c256 set 1+c256				; now c256=1, second loop
	endr							; makes the second routine


close_work: dc.l cw_cont,dum,dum,dum,dum
cw_cont: dc.w 101,0,0,0,0,0,0,0,0,0,0,0


falc set 0						; 0 = NOVA 32k, 1 = Falc 32k, 2 = NOVA 256c,3=65k

	rept 4						; 2 routines for NOVA (faster), and 1 for falcon

	if falc=2
c256 set 1
	else
c256 set 0
	endif

	if falc=0
decode_cram16:
		if REG=0
			move.l hc_cvid,a1	; to turn colors into grey!
		endif
		
	else
		if falc=1
decode_cram16_falc:
			if REG=0
				move.l hc_cvid,a1
			endif
		else
			if falc=3
decode_cram16_65k:
			else
decode_cram16_grey:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
			endif
		endif
	endif
	if falc<3
		move.l buffer,a2			; the datas
		move screenw,d3
		addq #4,d3
		if falc<2
			add d3,d3					; row dec, 1pixel is 2 bytes
		endif
		clr x
		move max_imagey,y
		subq #1,y
	endif
	if falc=0
		tst.b is_65k
		bne decode_cram16_65k
	endif
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
	move.l image,a3
	move screenw,d0
	muls y,d0
	move x,d1
	ext.l d1
	add.l d1,d0
	if c256=0
		add.l d0,d0
	endif
	add.l d0,a3			; image + y*screenw + x
	cmp #$80,d7
	bpl .lb2
	move (a2)+,d5		; cb0
	move (a2)+,d4		; ca0
	btst #7,d5
	beq.s .lb1
	move (a2)+,d2		; cb1
	move (a2)+,d1		; ca1
	if falc=2
		bsr avi_cram16_c4_grey
	else
		if REG=1		
			if (falc=1)|(falc=3)
				FALC16 d5
				FALC16 d4
				FALC16 d2
				FALC16 d1
				if falc=3
					ror #8,d5
					ror #8,d4
					ror #8,d2
					ror #8,d1
				endif
			endif
		else
			TO_GREY_16 d5
			TO_GREY_16 d4
			TO_GREY_16 d2
			TO_GREY_16 d1
		endif
		bsr avi_cram16_c4
	endif
	move d7,d6
	move (a2)+,d5
	move (a2)+,d4
	move (a2)+,d2
	move (a2)+,d1
	if falc=2
		bsr avi_cram16_c4_grey
	else
		if REG=1		
			if (falc=1)|(falc=3)
				FALC16 d5
				FALC16 d4
				FALC16 d2
				FALC16 d1
				if falc=3
					ror #8,d5
					ror #8,d4
					ror #8,d2
					ror #8,d1
				endif
			endif
		else
			TO_GREY_16 d5
			TO_GREY_16 d4
			TO_GREY_16 d2
			TO_GREY_16 d1
		endif
		bsr avi_cram16_c4
	endif
	bra.s .inc_bloc
.lb1:
	if falc=2
		bsr avi_cram16_c2_grey
		move d7,d6
		bsr _avi_cram16_c2_grey
	else
		if REG=1
			if (falc=1)|(falc=3)
				FALC16 d5
				FALC16 d4
				if falc=3
					ror #8,d5
					ror #8,d4
				endif
			endif
		else
			TO_GREY_16 d5
			TO_GREY_16 d4
		endif
		bsr avi_cram16_c2
		move d7,d6
		bsr avi_cram16_c2		
	endif
	bra.s .inc_bloc
.lb2:
	lsl #8,d6
	add d6,d7
	if falc=2
		bsr avi_cram16_c1_grey
	else
		if REG=1
			if (falc=1)|(falc=3)
				FALC16 d7
				if falc=3
					ror #8,d7
				endif
			endif
		else
			TO_GREY_16 d7
		endif
		bsr avi_cram16_c1
	endif
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
	
		if falc=0
qt_raw16:
		if REG=0
			move.l hc_cvid,a1	; to turn colors into grey!
		endif
	else
		if falc=1
qt_raw16_falc:
			if REG=0
				move.l hc_cvid,a1
			endif
		else
			if falc=3
qt_raw16_65k:
			else
qt_raw16_256:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
			endif
		endif
	endif
	if falc<3
		move.l buffer,a2
		move.l image,a3
		move screenw,d3
		move.l imagey,d5
		move.l bufused,d4
		divs d5,d4
		lsr #1,d4						; max image x according to bufused
		sub d4,d3
		if falc<2
			add d3,d3					; row_inc
		endif
		subq #1,d4
	endif
	if falc=0
		tst.b is_65k
		bne qt_raw16_65k
	endif
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	move (a2)+,d2
	bclr #15,d2
	if falc=2
		move.b (a1,d2.w),(a3)+
	else
		if REG=0
			move (a1,d2.w*2),(a3)+
		else
			ror #8,d2
			if (falc=1)|(falc=3)
				FALC16 d2
				if falc=3
					ror #8,d2
				endif
			endif
			move d2,(a3)+
		endif
	endif
	dbf d0,.lb1
	add d3,a3
.y_loop:
	dbf d5,.lb0
	rts	

	if falc=0
qt_raw24:
		if REG=0
			move.l hc_cvid,a1	; to turn colors into grey!
		endif
	else
		if falc=1
qt_raw24_falc:
			if REG=0
				move.l hc_cvid,a1
			endif
		else
			if falc=3
qt_raw24_65k:
			else
qt_raw24_256:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
			endif
		endif
	endif
	if falc<3
		move off_24_32,d7			; 0 or 1 to skip one byte (R G B or 0 R G B)
		move.l buffer,a2
		move.l image,a3
		move screenw,d3
		move.l imagey,d5
		move.l bufused,d4
		moveq #3,d0
		add d7,d0
		muls d5,d0
		divs d0,d4					; max image_x according to bufused
		sub d4,d3
		if falc<2
			add d3,d3					; row_inc
		endif
		subq #1,d4
	endif
	if falc=0
		tst.b is_65k
		bne qt_raw24_65k
	endif
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	add d7,a2
	if (REG=1)&((falc=1)|(falc=3))
		move.b (a2)+,d2
		lsl #5,d2
		move.b (a2)+,d2
		lsl.l #6,d2
		move.b (a2)+,d2
		lsr.l #3,d2
		if falc=3
			ror #8,d2
		endif
		move d2,(a3)+
	else
		move.b (a2)+,d2
		lsl #5,d2
		move.b (a2)+,d2
		lsl.l #5,d2
		move.b (a2)+,d2
		lsr.l #3,d2
		if falc=2
			bclr #15,d2
			move.b (a1,d2.w),(a3)+
		else
			if REG=1
				ror #8,d2
				move d2,(a3)+
			else
				bclr #15,d2
				move (a1,d2.w*2),(a3)+
			endif
		endif
	endif
	dbf d0,.lb1
	add d3,a3
.y_loop:
	dbf d5,.lb0
	rts	

	if falc=0
bat_tga:
		if REG=0
			move.l hc_cvid,a1	; to turn colors into grey!
		endif
	else
		if falc=1
bat_tga_falc:
			if REG=0
				move.l hc_cvid,a1
			endif
		else
			if falc=3
bat_tga_65k:
			else
bat_tga_256:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
			endif
		endif
	endif
	if falc<3
		move.l buffer,a2
		move.l image,a3
		move screenw,d3
		move 14(a2),d5				; max_imagey
		ror #8,d5
		move 12(a2),d4				; max_imagex
		ror #8,d4
		btst #5,17(a2)				; origin top or bottom
		bne.s .top
		move d5,d0
		subq #1,d0
		muls d3,d0					; to go to the bottom
		add d4,d3
		neg d3						; back one line
		bra.s .common	
	.top:
		moveq #0,d0					; yet at top
		sub d4,d3
	.common:
		if falc<2
			add.l d0,d0
			add d3,d3					; row_inc
		endif
		add.l d0,a3					; to the correct line
		subq #1,d4
		move.b 16(a2),d0
	endif
	if falc=0
		tst.b create_mov
		bne.s .areu					; if CREATE, NOVA 15 bits encoding
		tst.b is_65k				; else, 16 bits allowed
		bne bat_tga_65k
	.areu:
	endif
	cmp.b #24,d0					; 24 bits?
	bne .other_bits
	moveq #0,d0
	move.b (a2),d0					; offset
	lea 18(a2,d0.w),a2
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	if (REG=1)&((falc=1)|(falc=3))
		move.b (a2)+,d2
		lsl #8,d2
		swap d2
		move.b (a2)+,d2
		lsl #8,d2
		move.b (a2)+,d2
		lsr.b #3,d2
		rol #6,d2
		rol.l #5,d2
		if falc=3
			ror #8,d2
		endif
		move d2,(a3)+
	else
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
			move.b (a1,d2.w),(a3)+
		else
			if REG=1
				ror #8,d2
				move d2,(a3)+
			else
				move (a1,d2.w*2),(a3)+
			endif
		endif
	endif
	dbf d0,.lb1
	if c256=0
		tst.b create_mov
		beq.s .not_pad
		move.l a3,a0
		move d4,d2
	.pad:
		addq #1,d2
		cmp screenw,d2
		beq.s .not_pad
		clr (a0)+
		bra.s .pad
	.not_pad:
	endif
	add d3,a3
.y_loop:
	dbf d5,.lb0
	rts
.other_bits:			; assumes that it's a 16 bits TGA
	moveq #0,d0
	move.b (a2),d0
	lea 18(a2,d0.w),a2
	bra.s .oy_loop
.olb0:
	move d4,d0
.olb1:
	if (REG=1)&((falc=1)|(falc=3))
		move (a2)+,d2
		;	ror #8,d2
		FALC16 d2
		if falc=3
			ror #8,d2
		endif
		move d2,(a3)+
	else
		if (REG=1)&(falc=0)
			move (a2)+,(a3)+
		else
			move (a2)+,d2
			ror #8,d2
			bclr #15,d2
			if falc=2
				move.b (a1,d2.w),(a3)+
			else
				move (a1,d2.w*2),(a3)+
			endif
		endif
	endif
	dbf d0,.olb1
	if c256=0
		tst.b create_mov
		beq.s .onot_pad
		move.l a3,a0
		move d4,d2
	.opad:
		addq #1,d2
		cmp screenw,d2
		beq.s .onot_pad
		clr (a0)+
		bra.s .opad
	.onot_pad:
	endif
	add d3,a3
.oy_loop:
	dbf d5,.olb0
	rts

		if falc=0
qt_rle16:
		if REG=0
			move.l hc_cvid,a1	; to turn colors into grey!
		endif
	else
		if falc=1
qt_rle16_falc:
			if REG=0
				move.l hc_cvid,a1
			endif
		else
			if falc=3
qt_rle16_65k:
			else
qt_rle16_256:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
			endif
		endif
	endif
	if falc<3
		move.l image,a3
		move.l buffer,a2
		move screenw,d3
		if falc<2
			add d3,d3
		endif
		addq.l #5,a2		; codec size + one byte
		btst #3,(a2)+		; flag and $8
		bne.s .lb0			; if 8, header present
		rts					; else, nop frame
	.lb0:
		move (a2)+,d0		; start line
		muls d3,d0			; offset
		add.l d0,a3			; start into screen
		addq.l #2,a2
		move (a2)+,d0		; number of lines
		addq.l #2,a2
		move.l a3,a4
	endif
	if falc=0
		tst.b is_65k
		bne qt_rle16_65k
	endif
.while:
	dbf d0,.lb1
;	subq #1,d0
;	bpl.s .lb1
	rts
.lb1:
	move.l a4,a3		; start of line
	moveq #0,d2
	add d3,a4			; for the next line
	move.b (a2)+,d2
	if falc=2
		lea -1(a3,d2.w),a3
	else
;		subq.l #2,a3
;		add d2,a3
;		add d2,a3
		lea -2(a3,d2.w*2),a3	; skips blocs
	endif
.cnt:
	move.b (a2)+,d2	; code
	bne.s .case80
	move.b (a2)+,d2
	if falc=2
		lea -1(a3,d2.w),a3
	else
;		subq.l #2,a3
;		add d2,a3
;		add d2,a3
		lea -2(a3,d2.w*2),a3 ; skips
	endif
	bra.s .cnt
.case80:
	bmi.s .repeat
	subq #1,d2
.run:
	move (a2)+,d4
	if falc=2
		bclr #15,d4
		move.b (a1,d4.w),(a3)+
	else
		if REG=0
			bclr #15,d4
			move (a1,d4.w*2),(a3)+
		else
			ror #8,d4
			if (falc=1)|(falc=3)
				FALC16 d4
				if falc=3
					ror #8,d4
				endif
			endif
			move d4,(a3)+
		endif
	endif
	dbf d2,.run
	moveq #0,d2
	bra.s .cnt
.repeat:
	sub #256,d2
	neg d2
	subq #1,d2
	beq.s .while		; it was $FF=end of line
	move (a2)+,d4
	if falc=2
		bclr #15,d4
		move.b (a1,d4.w),d4
	else
		if REG=0
			bclr #15,d4
			move (a1,d4.w*2),d4
		else
			ror #8,d4
			if (falc=1)|(falc=3)
				FALC16 d4
				if falc=3
					ror #8,d4
				endif
			endif
		endif
	endif
.rep:
	if falc=2
		move.b d4,(a3)+
	else
		move d4,(a3)+
	endif
	dbf d2,.rep
	moveq #0,d2
	bra.s .cnt


	if falc=0
qt_rle24:
		if REG=0
			move.l hc_cvid,a1	; to turn colors into grey!
		endif
	else
		if falc=1
qt_rle24_falc:
			if REG=0
				move.l hc_cvid,a1
			endif
		else
			if falc=3
qt_rle24_65k:
			else
qt_rle24_256:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
			endif
		endif
	endif
	if falc<3
		move.l image,a3
		move.l buffer,a2
		move off_24_32,d7		; 1 or 0 to skip one byte before R G B
		move screenw,d3
		if falc<2
			add d3,d3
		endif
		addq.l #5,a2		; codec size + one byte
		btst #3,(a2)+		; flag and $8
		bne.s .lb0			; if 8, header present
		rts					; else, nop frame
	.lb0:
		move (a2)+,d0		; start line
		muls d3,d0			; offset
		add.l d0,a3			; start into screen
		addq.l #2,a2
		move (a2)+,d0		; number of lines
		addq.l #2,a2
		move.l a3,a4
	endif
	if falc=0
		tst.b is_65k
		bne qt_rle24_65k
	endif
.while:
	subq #1,d0
	bpl.s .lb1
	rts
.lb1:
	move.l a4,a3		; start of line
	add d3,a4			; for the next line
	moveq #0,d2
	move.b (a2)+,d2
	if falc=2
		lea -1(a3,d2.w),a3
	else
		lea -2(a3,d2.w*2),a3	; skips blocs
	endif
	move.b (a2)+,d2	; code
.cnt:
	cmp.b #$ff,d2
	beq.s .while		; end of line
	tst.b d2
	bne.s .case80
	move.b (a2)+,d2
	if falc=2
		lea -1(a3,d2.w),a3
	else
		lea -2(a3,d2.w*2),a3 ; skips
	endif
.next_cnt:
	move.b (a2)+,d2
	bra.s .cnt
.case80:
	cmp #$80,d2
	bpl.s .repeat
	subq #1,d2
.run:
	add d7,a2
	if (REG=1)&((falc=1)|(falc=3))
		move.b (a2)+,d4
		lsl #5,d4
		move.b (a2)+,d4
		lsl.l #6,d4
		move.b (a2)+,d4
		lsr.l #3,d4
		if falc=3
			ror #8,d4
		endif
		move d4,(a3)+
	else
		move.b (a2)+,d4
		lsl #5,d4
		move.b (a2)+,d4
		lsl.l #5,d4
		move.b (a2)+,d4
		lsr.l #3,d4
		if falc=2
			bclr #15,d4
			move.b (a1,d4.w),(a3)+
		else
			if REG=1
				ror #8,d4
				move d4,(a3)+
			else
				bclr #15,d4
				move (a1,d4.w*2),(a3)+
			endif
		endif
	endif
	dbf d2,.run
	moveq #0,d2
	bra.s .next_cnt
.repeat:
	sub #256,d2
	neg d2
	subq #1,d2
	add d7,a2
	if (REG=1)&((falc=1)|(falc=3))
		move.b (a2)+,d4
		lsl #5,d4
		move.b (a2)+,d4
		lsl.l #6,d4
		move.b (a2)+,d4
		lsr.l #3,d4
		if falc=3
			ror #8,d4
		endif
	else
		move.b (a2)+,d4
		lsl #5,d4
		move.b (a2)+,d4
		lsl.l #5,d4
		move.b (a2)+,d4
		lsr.l #3,d4
		if falc=2
			bclr #15,d4
			move.b (a1,d4.w),d4
		else
			if REG=1
				ror #8,d4
			else
				bclr #15,d4
				move (a1,d4.w*2),d4
			endif
		endif
	endif
.rep:
	if falc=2
		move.b d4,(a3)+
	else
		move d4,(a3)+
	endif
	dbf d2,.rep
	moveq #0,d2
	bra.s .next_cnt		


	if falc=0
qt_rpza:
		if REG=0
			move.l hc_cvid,a1	; to turn colors into grey!
		endif
	else
		if falc=1
qt_rpza_falc:
			if REG=0
				move.l hc_cvid,a1
			endif
		else
			if falc=3
qt_rpza_65k:
			else
qt_rpza_256:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
			endif
		endif
	endif
	if falc<3
		move.l buffer,a2
		move.l image,a3
		move screenw,d3
		moveq #0,d0
		move d3,d0	
		move d3,d5
		muls #3,d5
		subq #4,d3
		lsl #2,d0
		sub max_imagex,d0
		if falc<2
			add d3,d3
			add d0,d0
			add d5,d5			
		endif
		move.l d0,a4		; row inc
		moveq #0,d7				; x
		clr.b (a2)				; $e1
		move.l (a2)+,d0		; len
		cmp.l bufused,d0
		beq.s .good_size
	.out:
		rts
	.good_size:
		lea -4(a2,d0.l),a0	; end of frame
	endif
	if falc=0
		tst.b is_65k
		bne qt_rpza_65k
	endif
.while:
	cmp.l a0,a2
	bpl.s .out
.lb0:
	moveq #0,d1
	move.b (a2)+,d1		; code
	move d1,d2
	lsr #5,d2
	cmp.b #5,d2				; code $a0 to $bf
	bne.s .case8
	move (a2)+,d2			; color
	if falc=2
		bsr qt_rpza_c1_256
	else
		if REG=0
			bsr qt_rpza_c1_grey
		else
			if falc=1
				bsr qt_rpza_c1_falc
			else
				if falc=3
					bsr qt_rpza_c1_65k
				else
					bsr qt_rpza_c1
				endif
			endif
		endif
	endif
	bra.s .while
	if falc=3
.out:
	rts
	endif
.case8:
	cmp.b #4,d2				; code $80 to $9f
	bne.s .casec
	sub #$80,d1				; loops
.lb1:
	if falc=2
		addq.l #4,a3
	else		
		addq.l #8,a3
	endif
	addq #4,d7
	cmp max_imagex,d7
	bmi.s ._lb0
	moveq #0,d7
	add.l a4,a3
._lb0:
	dbf d1,.lb1
	bra.s .while
.casec:
	cmp.b #6,d2
	bne.s .casex
	move d1,d0
	sub #$C0,d0				; loops (-1 for dbf)
	move (a2)+,d1			; one color
	move (a2)+,d2			; another
.col4_init:
		if falc=2
	bclr #15,d1
	bclr #15,d2
	move.b (a1,d1.w),d1
	move.b (a1,d2.w),d2
		else
			if REG=0
	bclr #15,d1
	bclr #15,d2
	move (a1,d1.w*2),d1
	move (a1,d2.w*2),d2
			else
			if (falc=1)|(falc=3)
	ror #8,d1
	ror #8,d2
	FALC16 d1
	FALC16 d2
			if falc=3
				ror #8,d1
				ror #8,d2
			endif
			else
	ror #8,d1
	ror #8,d2
			endif
		endif
	endif	
.col4:
	if falc=2
		bsr qt_rpza_c4_256
	else
		bsr qt_rpza_c4
	endif
	bra.s .while
.casex:						; under $80
	lsl #8,d1
	move.b (a2)+,d1		; one color
	move (a2)+,d2			; a second color
	moveq #0,d0				; one loop (if bit 15)
	bclr #15,d2
	bne.s .col4_init			; same as above
	if falc=2
		bsr qt_rpza_c16_256
	else
		if REG=0
			bsr qt_rpza_c16_grey
		else
			if falc=1
				bsr qt_rpza_c16_falc
			else
				if falc=3
					bsr qt_rpza_c16_65k
				else
					bsr qt_rpza_c16
				endif
			endif
		endif
	endif
	bra.s .while
	
	if falc=2
qt_rpza_c1_256:
	bclr #15,d2
	move.b (a1,d2.w),d2
	else
		if REG=0
qt_rpza_c1_grey:
	bclr #15,d2
	move (a1,d2.w*2),d2
		else
			if falc=0
qt_rpza_c1:
	ror #8,d2
			else
				if falc=3
qt_rpza_c1_65k:
	ror #8,d2
	FALC16 d2
	ror #8,d2
				else
qt_rpza_c1_falc:
	ror #8,d2
	FALC16 d2
				endif
			endif
		endif
	endif			
	sub #$a0,d1		; loops
	if falc=2
		move d2,d4
		lsl #8,d2
		move.b d4,d2	; into high byte
	endif
	move d2,d4
	swap d2
	move d4,d2		; into high word
.lb0:
	rept 3
	move.l d2,(a3)+
	if c256=0
		move.l d2,(a3)+
	endif
	add d3,a3
	endr
	move.l d2,(a3)+
	if c256=0
		move.l d2,(a3)+
	endif
	sub d5,a3
	addq #4,d7
	cmp max_imagex,d7
	bmi.s .lb1
	moveq #0,d7
	add.l a4,a3
.lb1:
	dbf d1,.lb0
	rts

	if (falc=0)|(falc=2)	; falc=0 pour 1 et 3 aussi
	
	if falc=2
qt_rpza_c4_256:
	else
qt_rpza_c4:
	endif
.debut:
	move.l (a2)+,d4
	moveq #3,d6
.loop:
	btst #31,d4
	beq.s .lb0
	
	if falc=2
	
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
   
   else
   
   move d1,(a3)+
	bra.s .lb1
.lb0:
   move d2,(a3)+
.lb1:
	btst #29,d4
	beq.s .lb2
	move d1,(a3)+
	bra.s .lb3
.lb2:
   move d2,(a3)+
.lb3:
	btst #27,d4
	beq.s .lb4
	move d1,(a3)+
	bra.s .lb5
.lb4:
   move d2,(a3)+
.lb5:
	btst #25,d4
	beq.s .lb6
	move d1,(a3)+
	bra.s .lb7
.lb6:
   move d2,(a3)+
   
   endif
   
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
	dbf d0,.debut
	rts

	endif ; (for FALC<>1)

	if falc=2
qt_rpza_c16_256:
	bclr #15,d1
	move.b (a1,d1.w),(a3)+
	bclr #15,d2
	move.b (a1,d2.w),(a3)+
	else
		if REG=0
qt_rpza_c16_grey:
	bclr #15,d1
	move (a1,d1.w*2),(a3)+
	bclr #15,d2
	move (a1,d2.w*2),(a3)+
		else
			if falc=1
qt_rpza_c16_falc:
	ror #8,d1
	FALC16 d1
	ror #8,d2
	FALC16 d2
	move d1,(a3)+
	move d2,(a3)+
			else
			if falc=3
qt_rpza_c16_65k:
	ror #8,d1
	FALC16 d1
	ror #8,d2
	ror #8,d1
	FALC16 d2
	move d1,(a3)+
	ror #8,d2
	move d2,(a3)+
			else
qt_rpza_c16:
	ror #8,d1
	ror #8,d2
	move d1,(a3)+
	move d2,(a3)+
			endif
			endif
		endif
	endif
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

	if falc=2
flh_brun_256:
	else
		if (REG=1)&(falc=1)
flh_brun_falc:
		else
			if (REG=1)&(falc=3)
flh_brun_65k:
			else
flh_brun:
			endif
		endif
	endif
		move max_imagey,d5		; number of lines to modify
	if falc<3
;		move max_imagey,d5		; number of lines to modify
		if falc=2
			move d5,flx_number
			clr flx_start
		endif
	endif
		move.l a5,a2				; screen pointer
	if (REG=1)&(falc=0)
		tst.b is_65k
		bne flh_brun_65k
	endif
	bra.s .l_loop
.line:
	lea (a2,d3.l),a3			; the next line in memory
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
	if falc=2
		move (a0)+,d1
		NOVA16 d1
		bclr #15,d1
		move.b (a6,d1.w),(a2)+
	else
		if (REG=1)&(falc=1)
			move (a0)+,(a2)+
		else
			if (REG=1)&(falc=3)
				move (a0)+,d1
				ror #8,d1
				move d1,(a2)+
			else
				move (a0)+,d1
				NOVA16 d1
				if REG=0
					bclr #15,d1
					move (a6,d1.w*2),(a2)+
				else
					ror #8,d1
					move d1,(a2)+
				endif
			endif
		endif
	endif
.c_loop:
	dbf d0,.copy
	bra.s .b_loop
.repeat:
	if falc=2
		move (a0)+,d1
		NOVA16 d1
		bclr #15,d1
		move.b (a6,d1.w),d1
	else
		if (REG=1)&(falc=1)
			move (a0)+,d1
		else
			if (REG=1)&(falc=3)
				move (a0)+,d1
				ror #8,d1
			else
				move (a0)+,d1
				NOVA16 d1
				if REG=0
					bclr #15,d1
					move (a6,d1.w*2),d1
				else
					ror #8,d1
				endif
			endif
		endif
	endif	
	bra.s .lb2
.lb1:
	if falc=2
		move.b d1,(a2)+
	else
		move d1,(a2)+
	endif
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
	if falc=2
		move (a0)+,d1
		NOVA16 d1
		bclr #15,d1
		move.b (a6,d1.w),(a2)+
	else
		if (REG=1)&(falc=1)
			move (a0)+,(a2)+
		else
			if (REG=1)&(falc=3)
				move (a0)+,d1
				ror #8,d1
				move d1,(a2)+
			else
				move (a0)+,d1
				NOVA16 d1
				if REG=0
					bclr #15,d1
					move (a6,d1.w*2),(a2)+
				else
					ror #8,d1
					move d1,(a2)+
				endif
			endif
		endif
	endif
.ap_c_loop:
	dbf d0,.ap_copy
	bra.s .ap_b_loop
.ap_repeat:
	sub d0,d4
	if falc=2
		move (a0)+,d1
		NOVA16 d1
		bclr #15,d1
		move.b (a6,d1.w),d1
	else
		if (REG=1)&(falc=1)
			move (a0)+,d1
		else
			if (REG=1)&(falc=3)
				move (a0)+,d1
				ror #8,d1
			else
				move (a0)+,d1
				NOVA16 d1
				if REG=0
					bclr #15,d1
					move (a6,d1.w*2),d1
				else
					ror #8,d1
				endif
			endif
		endif
	endif	
	bra.s .ap_lb2
.ap_lb1:
	if falc=2
		move.b d1,(a2)+
	else
		move d1,(a2)+
	endif
.ap_lb2:
	dbf d0,.ap_lb1
.ap_b_loop:
	tst d4
	bpl.s .ap_blocs
	bra.s .next_line
	
	if falc=2
flh_delta_256:
	else
		if (REG=1)&(falc=1)
flh_delta_falc:
		else
			if (REG=1)&(falc=3)
flh_delta_65k:
			else
			if falc=0
flh_delta:
			else
flh_non_delta:
			endif
			endif
		endif
	endif	
	if falc<3
		move (a0)+,d5
		ror #8,d5					; number of lines to modify
		if falc=2
			move d5,flx_number
			moveq #0,d0
			move (a0),d4
			ror #8,d4
			bpl.s .zzz
			neg d4
			move d4,d0
			.zzz:
			move d0,flx_start
		endif
		move.l a5,a2				; screen pointer
	endif
	if (REG=1)&(falc=0)
		tst.b is_65k
		bne flh_delta_65k
	endif
	bra.s .l_loop
.line:
	lea (a2,d3.l),a3			; the next line in memory
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
	if falc=2
		lea (a2,d0.w),a2
	else
		lea (a2,d0.w*2),a2		; skips the pixels
	endif
	moveq #0,d1
	moveq #0,d0
	move.b (a0)+,d0			; number of pixels
	cmp #$80,d0
	bpl.s .repeat
	bra.s .c_loop
.copy:
	if falc=2
		move (a0)+,d1
		NOVA16 d1
		bclr #15,d1
		move.b (a6,d1.w),(a2)+
	else
		if (REG=1)&(falc=1)
			move (a0)+,(a2)+
		else
			if (REG=1)&(falc=3)
				move (a0)+,d1
				ror #8,d1
				move d1,(a2)+
			else
				move (a0)+,d1
				NOVA16 d1
				if REG=0
					bclr #15,d1
					move (a6,d1.w*2),(a2)+
				else
					ror #8,d1
					move d1,(a2)+
				endif
			endif
		endif
	endif
.c_loop:
	dbf d0,.copy
	bra.s .b_loop
.repeat:
	sub #$100,d0
	neg d0
	if falc=2
		move (a0)+,d1
		NOVA16 d1
		bclr #15,d1
		move.b (a6,d1.w),d1
	else
		if (REG=1)&(falc=1)
			move (a0)+,d1
		else
			if (REG=1)&(falc=3)
				move (a0)+,d1
				ror #8,d1
			else
				move (a0)+,d1
				NOVA16 d1
				if REG=0
					bclr #15,d1
					move (a6,d1.w*2),d1
				else
					ror #8,d1
				endif
			endif
		endif
	endif	
	bra.s .lb2
.lb1:
	if falc=2
		move.b d1,(a2)+
	else
		move d1,(a2)+
	endif
.lb2:
	dbf d0,.lb1
.b_loop:
	dbf d4,.blocs
	move.l a3,a2				; the next line
.l_loop:
	dbf d5,.line
	rts

	
falc set 1+falc
	endr
	

avi_cram16_c1:
	move d7,d0
	swap d7
	move d0,d7		; repeats d7 into high word
	rept 4
	move.l d7,(a3)+
	move.l d7,(a3)+
	sub d3,a3
	endr
	rts
	
avi_cram16_c2:
	btst #0,d6
	bne.s .lb0
	move d4,(a3)+
	bra.s .lb1
.lb0:
	move d5,(a3)+
.lb1:
	btst #1,d6
	bne.s .lb2
	move d4,(a3)+
	bra.s .lb3
.lb2:
	move d5,(a3)+
.lb3:
	btst #2,d6
	bne.s .lb4
	move d4,(a3)+
	bra.s .lb5
.lb4:
	move d5,(a3)+
.lb5:
	btst #3,d6
	bne.s .lb6
	move d4,(a3)+
	bra.s .lb7
.lb6:
	move d5,(a3)+
.lb7:
	sub d3,a3
	btst #4,d6
	bne.s .lb8
	move d4,(a3)+
	bra.s .lb9
.lb8:
	move d5,(a3)+
.lb9:
	btst #5,d6
	bne.s .lb10
	move d4,(a3)+
	bra.s .lb11
.lb10:
	move d5,(a3)+
.lb11:
	btst #6,d6
	bne.s .lb12
	move d4,(a3)+
	bra.s .lb13
.lb12:
	move d5,(a3)+
.lb13:
	btst #7,d6
	bne.s .lb14
	move d4,(a3)+
	bra.s .lb15
.lb14:
	move d5,(a3)+
.lb15:
	sub d3,a3
	rts

avi_cram16_c4:
	btst #0,d6
	bne.s .lb0
	move d4,(a3)+
	bra.s .lb1
.lb0:
	move d5,(a3)+
.lb1:
	btst #1,d6
	bne.s .lb2
	move d4,(a3)+
	bra.s .lb3
.lb2:
	move d5,(a3)+
.lb3:
	btst #2,d6
	bne.s .lb4
	move d1,(a3)+
	bra.s .lb5
.lb4:
	move d2,(a3)+
.lb5:
	btst #3,d6
	bne.s .lb6
	move d1,(a3)+
	bra.s .lb7
.lb6:
	move d2,(a3)+
.lb7:
	sub d3,a3
	btst #4,d6
	bne.s .lb8
	move d4,(a3)+
	bra.s .lb9
.lb8:
	move d5,(a3)+
.lb9:
	btst #5,d6
	bne.s .lb10
	move d4,(a3)+
	bra.s .lb11
.lb10:
	move d5,(a3)+
.lb11:
	btst #6,d6
	bne.s .lb12
	move d1,(a3)+
	bra.s .lb13
.lb12:
	move d2,(a3)+
.lb13:
	btst #7,d6
	bne.s .lb14
	move d1,(a3)+
	bra.s .lb15
.lb14:
	move d2,(a3)+
.lb15:
	sub d3,a3
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

c256 set 0						; 0 = NOVA 32k or Falc 32k, 1 = NOVA 256c

	rept 2

	if c256=0
decode_cram8:
	lea cvid_fix0,a1		; pointer for the palette to 16bits conversion
	else
decode_cram8_256:
	endif
	move.l buffer,a2			; the datas
	move screenw,d3
	addq #4,d3
	if c256=0
		add d3,d3					; row dec, 1pixel is 2 bytes
	endif
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
	move.l image,a3
	move screenw,d0
	muls y,d0
	move x,d1
	ext.l d1
	add.l d1,d0
	if c256=0
		add.l d0,d0
	endif
	add.l d0,a3			; image + y*screenw + x
	cmp #$90,d7
	bmi.s .lb1
	if c256=0
		moveq #0,d5
		moveq #0,d4
		moveq #0,d2
		moveq #0,d1
	endif
	move.b (a2)+,d5		; cb0
	move.b (a2)+,d4		; ca0
	move.b (a2)+,d2		; cb1
	move.b (a2)+,d1		; ca1
	if c256=0
		move (a1,d5.w*2),d5
		move (a1,d4.w*2),d4
		move (a1,d2.w*2),d2
		move (a1,d1.w*2),d1
		bsr avi_cram16_c4
	else
		bsr _avi_cram8_c4
	endif
	move d7,d6
	if c256=0
		moveq #0,d5
		moveq #0,d4
		moveq #0,d2
		moveq #0,d1
	endif
	move.b (a2)+,d5
	move.b (a2)+,d4
	move.b (a2)+,d2
	move.b (a2)+,d1
	if c256=0
		move (a1,d5.w*2),d5
		move (a1,d4.w*2),d4
		move (a1,d2.w*2),d2
		move (a1,d1.w*2),d1
		bsr avi_cram16_c4
	else
		bsr _avi_cram8_c4
	endif
	bra.s .inc_bloc
.lb1:
	cmp #$80,d7
	bpl.s .lb2
	if c256=0
		moveq #0,d5
		moveq #0,d4
	endif
	move.b (a2)+,d5
	move.b (a2)+,d4
	if c256=0
		move (a1,d5.w*2),d5
		move (a1,d4.w*2),d4
		bsr avi_cram16_c2
		move d7,d6
		bsr avi_cram16_c2
	else
		bsr _avi_cram8_c2
		move d7,d6
		bsr _avi_cram8_c2
	endif
	bra.s .inc_bloc
.lb2:
	if c256=0
		move (a1,d6.w*2),d7
		bsr avi_cram16_c1
	else	
		move.b d6,d7
		bsr _avi_cram8_c1
	endif
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
	
c256 set 1+c256
	endr
	
	
c256 set 0							; 0=32k, 1=256colors, for rle8 and rgb

	rept 2
	
	if 1=0
	
	if c256=0
decode_rle8:
	lea cvid_fix0,a1				; the palette pointer
	else
decode_rle8_256:
	endif
	moveq #0,d0						; x
	move max_imagey,d1
	subq #1,d1						; y
	move max_imagex,d4			; imagex
	move.l image,a4				; screen memory
	move.l buffer,a2
;	move.l bufused,d2
;	subq.l #1,d2
.while:
	tst d1
	bpl.s .lb0
.end:
	rts
.lb0:
;	tst.l d2
;	bmi.s .end
	moveq #0,d6
	move.b (a2)+,d6				; mod
	moveq #0,d7
	move.b (a2)+,d7				; opcode
;	subq.l #2,d2
	tst.b d6							; jumps if mod<>0
	bne .lb8
	tst.b d7							; if opcode=0
	bne.s .lb3
.lb2:
	cmp d0,d4						; while x> imagex
	bpl.s .lb1
	sub d4,d0
	subq #1,d1
	bra.s .lb2
.lb1:
	moveq #0,d0
	subq #1,d1
	bra.s .while
.lb3:
	cmp.b #1,d7						; if opcode=1
	bne.s .lb4
	moveq #-1,d1
	bra.s .while
.lb4:
	cmp.b #2,d7						; if opcode=2
	bne.s .lb5
	moveq #0,d5
	move.b (a2)+,d5
	add d5,d0						; x=x+*dptr++
	move.b (a2)+,d5
	sub d5,d1						; y=y-*dptr++
;	subq.l #2,d2
	bra.s .while
.lb5:									; else (for opcode)
;	sub.l d7,d2
	move.l a4,a3
	move d1,d3
	muls screenw,d3
	add.l d0,d3
	if c256=0
		add.l d3,d3
	endif
	add.l d3,a3						; image + y*imagex + x
	move d7,d5						; cnt
	bra.s .loop
.lb6:
	cmp d4,d0
	bmi.s .lb7
	sub d4,d0
	subq #1,d1
	move.l a4,a3
	move d1,d3
	muls screenw,d3
	add.l d0,d3
	if c256=0
		add.l d3,d3
	endif
	add.l d3,a3						; image + y*imagex + x	
	bra.s .lb6
.lb7:
	if c256=1
		move.b (a2)+,(a3)+
	else
		move.b (a2)+,d6
		move (a1,d6.w*2),(a3)+
	endif
	addq #1,d0
.loop:
	dbf d5,.lb6
	btst #0,d7
	beq .while
	addq.l #1,a2
;	subq.l #1,d2
	bra .while	
.lb8:
	move.l a4,a3
	move d1,d3
	muls screenw,d3
	add.l d0,d3
	if c256=0
		add.l d3,d3
	endif
	add.l d3,a3						; image + y*imagex + x
	move d6,d5						; cnt
	if c256=0
		move (a1,d7.w*2),d7	
	endif
	bra.s .loop2
.lb9:
	cmp d4,d0
	bmi.s .lb10
	sub d4,d0
	subq #1,d1
	move.l a4,a3
	move d1,d3
	muls screenw,d3
	add.l d0,d3
	if c256=0
		add.l d3,d3
	endif
	add.l d3,a3						; image + y*imagex + x	
	bra.s .lb9
.lb10:
	if c256=1
		move.b d7,(a3)+
	else
		move d7,(a3)+
	endif
	addq #1,d0
.loop2:
	dbf d5,.lb9
	bra .while	

	else
	
	if c256=0
decode_rle8:
	lea cvid_fix0,a1				; the palette pointer
	else
decode_rle8_256:
	endif
	move max_imagey,d1
	subq #1,d1						; y
	move screenw,d4
	if c256=0
		add d4,d4
	endif
	move d4,d0
	muls d1,d0
	move.l image,a4				; screen memory
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
	bne.s .lb8
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
	if c256=0
		add d0,d0
	endif
	add d0,a3
	move.b (a2)+,d5
	beq.s .lb0
	sub d5,d1
	muls d4,d5						; number of lines
	sub.l d5,a4
	sub.l d5,a3
	bra.s .while
.lb5:									; else (for opcode)
	move d6,d5						; cnt
	moveq #0,d0
	bra.s .loop
.lb6:
	if c256=1
		move.b (a2)+,(a3)+
	else
		move.b (a2)+,d0
		move (a1,d0.w*2),(a3)+
	endif
.loop:
	dbf d5,.lb6
	btst #0,d6
	beq.s .lb0
	addq.l #1,a2
	bra.s .lb0
.lb8:
	move d6,d5		; cnt
	move.b (a2)+,d6
	if c256=0
		move (a1,d6.w*2),d6
	endif
	bra.s .loop2
.lb9:
	if c256=1
		move.b d6,(a3)+
	else
		move d6,(a3)+
	endif
.loop2:
	dbf d5,.lb9
	bra.s .lb0
	
	endif
	
	if c256=0
decode_rgb:
	lea cvid_fix0,a1
	else
decode_rgb_256:
	endif
	move.l image,a3
	move.l buffer,a2
	move max_imagex,d0
	move d0,d7
	addq #1,d7
	bclr #0,d7				; for the next line into buffer
	move max_imagey,d1
	move screenw,d4
	move d4,d3
	if c256=0
		add d3,d3			; for the next line into video ram
	endif
	cmp d4,d0
	bpl.s .lb0
	move d0,d4				; if image to large
.lb0:
	move screenh,d5
	move d1,d0				; y
	subq #1,d0
	muls d3,d0
	add.l d0,a3				; last line pointer
.lb4:
	cmp d1,d5				; under the screen?
	bpl.s .lb5				; no, ok
	subq #1,d1				; else one line skipped
	sub d3,a3				; one upinto screen
	add d7,a2				; one down into buffer
	bra.s .lb4
.lb5:
	moveq #0,d0
	bra.s .loop
.lb1:
	move.l a3,a5
	move.l a2,a4
	move d4,d6
	bra.s .line
.lb2:
	if c256=0
		move.b (a4)+,d0
		move (a1,d0.w*2),(a5)+
	else
		move.b (a4)+,(a5)+
	endif
.line:
	dbf d6,.lb2
	sub d3,a3
	add d7,a2
.loop:
	dbf d1,.lb1
	rts	

	if c256=0	
bat_ximg:
	else
bat_ximg_256:
	tst.b mountain
	bne _convert256
	endif
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
	if c256=0
		lea cvid_fix0,a6	; palette pointer
	endif
	tst.b bat_getp	; read palette?
	beq .end_head
	
	if c256=0
	
	lea 22(a2),a0	; palette VDI
	lea indexs,a1
	move #255,d7	; 256 colors
	tst.b nova
	beq.s .falcon
.lb0:
	if REG=1
		move (a0)+,d0	; red
		lsr #5,d0
		lsl.b #2,d0
		move (a0)+,d1	; green
		lsr #5,d1
		ror #3,d1
		or d1,d0
		move (a0)+,d1	; blue
		lsr #5,d1
		lsl #8,d1
		or d1,d0
	else
		move (a0)+,d1
		move (a0)+,d0	; 2*R + G
		add d0,d0
		add d1,d0
		move d0,d1
		add d0,d0
		add d1,d0		; 6*R + 3*G
		add (a0)+,d0	; 6*R + 3*G + B, the brightness (0 to 10000)
		ext.l d0
		divs #320,d0	; 0 to 31
		move d0,d1
		lsl #5,d1
		or d1,d0
		lsl #5,d1
		or d1,d0
		ror #8,d0
	endif
	move d0,(a6)+
	dbf d7,.lb0
	lea cvid_fix0,a6
	bra.s .end_head
.falcon:
	if REG=1
		move (a0)+,d0	; red
		lsr #5,d0
		ror #5,d0
		move (a0)+,d1	; green
		lsr #4,d1
		lsl #5,d1
		or d1,d0
		move (a0)+,d1	; blue
		lsr #5,d1
		or d1,d0
	else
		move (a0)+,d1
		move (a0)+,d0
		add d0,d0
		add d1,d0	; 2*R + G
		move d0,d1
		add d0,d0
		add d1,d0		; 6*R + 3*G
		add (a0)+,d0	; 6*R + 3*G + B, the brightness (0 to 10000)
		ext.l d0
		divs #320,d0	; 0 to 31
		move d0,d1
		lsl #6,d1
		or d1,d0
		lsl #5,d1
		or d1,d0
	endif
	move d0,(a6)+
	dbf d7,.falcon
	lea cvid_fix0,a6
	
	else
	
	lea 22(a2),a5
	tst.b create_mov
	bne.s .mov_make
	move.l a2,-(sp)
	lea indexs,a4
	move #255,d7
.lb0:
	lea vs_int,a0
	move (a4)+,(a0)+
	if REG=1
		move.l (a5)+,(a0)+
		move (a5)+,(a0)
	else
		move (a5)+,d1
		move (a5)+,d0
		add d0,d0
		add d1,d0	; 2*R + G
		move d0,d1
		add d0,d0
		add d1,d0		; 6*R + 3*G
		add (a5)+,d0	; 6*R + 3*G + B, the brightness (0 to 10000)
		ext.l d0
		divs #10,d0	; 0 to 1000
		move d0,(a0)+
		move d0,(a0)+
		move d0,(a0)
	endif
	GEM_VDI vs_color
	dbf d7,.lb0
	move.l (sp)+,a2
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
		move (a5)+,d1
		subq #1,d1
		bpl.s .mov_1
		moveq #0,d1
		.mov_1:
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
	
		
	endif
	
.end_head:
	move 12(a2),d0
	addq #7,d0
	and.b #$F8,d0
	move d0,a4	; image width	
	move 14(a2),y	; image height
	move 2(a2),d0	; header in words
	lea (a2,d0.w*2),a2	; datas
	move.l image,a3
.next_line:
	lea cvid_fix0+512,a0	; one line decompressed
	lea (a0,a4.w),a5	; end of one ligne uncompressed
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
	lea (a0,d0.w),a5	; end of the 1st plane for the loop
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
	if c256=0
		and #$FF,d0
		move (a6,d0.w*2),(a3)+
	else
		move.b d0,(a3)+
	endif
	subq #1,a1
	cmp #0,a1
	bne.s .pixel
	addq.l #1,a0
	cmp.l a5,a0
	bmi.s .next_8_pixels
.copy_line:
	move screenw,d3
	sub a4,d3
	if c256=0
		add d3,d3
	endif
	add d3,a3
	move.l (sp)+,a5		; old a3
	subq.b #1,dup_line
	beq.s .other_line
	subq #1,y
	move.l a3,-(sp)
	move a4,d0
	bra.s .cp1
.cp0:
	if c256=0
		move (a5)+,(a3)+
	else
		move.b (a5)+,(a3)+
	endif
.cp1:
	dbf d0,.cp0
	bra.s .copy_line
.other_line:	
	subq #1,y
	bne .next_line
	rts	
	
c256 set 1+c256
	
	endr

_convert256:
	move.l vanel_adr,a0
	if REG=1
		cmp #$7fff,quality			; q=5?
		beq _dither216
	endif
	move.l 4(a0),d0				; numero d'image
	bne.s .pas_premier			
	move.l #32768,d1
	bsr malloc
	move.l d0,hc_cvid
	bsr gen_16_to_grey
	moveq #-1,d0
	move #255,d1
	tst.b create_avi
	beq.s .pas_avi
	move.l header_buffer,a0
	sf d0
.avi_pal:
	move.l d0,(a0)+
	sub.l #$01010100,d0
	dbf d1,.avi_pal
	bra.s .pas_premier
.pas_avi:
	move.l mov_pal,a0
	clr.l (a0)+
	clr.w (a0)+
	move d1,(a0)+
	lea 2048(a0),a0
	moveq #0,d0
.move_pal:
	move d0,-(a0)
	move d0,-(a0)
	move d0,-(a0)
	move d1,-(a0)
	add #257,d0
	dbf d1,.move_pal
.pas_premier:
	move.l vanel_adr,a0
	move.l 8(a0),a1				; ses pixels
	move.l one_buffer,a2			; destination
	move max_imagey,d0
	subq #1,d0						; boucle
	move _vanel_line,d4
	move _vanel_plus,d5
	subq #1,d4						; for the loop
	move d4,d2
	move 12(a0),d1					; flag
	move.l hc_cvid,a0
	tst d1
	bne.s .falcon
.nova:
	move (a1)+,d1
	ror #8,d1
	bclr #15,d1
	move.b 0(a0,d1.w),(a2)+
	dbf d2,.nova
	move d5,d2
	bra.s .nov1
.efface:
	st (a2)+
.nov1:
	dbf d2,.efface
	move d4,d2
	dbf d0,.nova
	rts
.falcon:
	move (a1)+,d1
	NOVA16 d1
	move.b 0(a0,d1.w),(a2)+
	dbf d2,.falcon
	move d5,d2
	bra.s .fal1
.delete:
	st (a2)+
.fal1:
	dbf d2,.delete
	move d4,d2
	dbf d0,.falcon
	rts

	if REG=1

magic:
   dc.b 34,5,21,44,32,3,20,42,33,4,21,43,35,6,22,44
   dc.b 15,50,28,12,13,48,26,10,14,49,27,11,15,51,28,12
   dc.b 31,8,18,47,29,7,16,45,30,8,17,46,32,9,19,48
   dc.b 25,41,37,2,23,39,36,0,24,40,37,1,25,41,38,3
   dc.b 33,4,20,43,35,6,22,45,34,5,21,43,33,4,20,42
   dc.b 14,49,27,10,16,51,29,13,14,50,27,11,13,49,26,10
   dc.b 30,7,17,46,32,9,19,48,31,8,18,47,30,7,17,46
   dc.b 23,39,36,1,26,42,38,3,24,40,37,2,23,39,36,1
   dc.b 34,5,21,44,33,4,20,42,33,4,20,43,35,6,22,45
   dc.b 15,50,28,11,13,49,26,10,14,49,27,11,16,51,29,12
   dc.b 31,8,18,47,29,7,16,45,30,7,17,46,32,9,19,48
   dc.b 24,40,37,2,23,39,36,0,24,40,36,1,25,41,38,3
   dc.b 34,5,21,43,35,6,22,44,34,5,22,44,32,3,19,42
   dc.b 14,50,27,11,15,51,28,12,15,50,28,12,13,48,26,10
   dc.b 30,8,18,46,31,9,19,47,31,9,18,47,29,6,16,45
   dc.b 24,40,37,1,25,41,38,2,25,41,38,2,23,39,35,0
col_mod:
	dc.b 0,8,16,24,32,40,48,5,13,21,29,37,45,2,10,18,26,34,42,40,7,15,23,31,39,47,4,12,20,28,36,0
bleu_div:
	dc.b 0,0,0,0,0,0,0,36,36,36,36,36,36,72,72,72,72,72,72,72,108,108,108,108,108,108,144,144,144,144,144,180
	dc.b 0,0,0,0,0,0,0,6,6,6,6,6,6,12,12,12,12,12,12,12,18,18,18,18,18,18,24,24,24,24,24,30
	dc.b 0,0,0,0,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,2,3,3,3,3,3,3,4,4,4,4,4,5

_dither216:
	move.l 4(a0),d0
	bne.s .pas_premier
	moveq #0,d1
	moveq #0,d2
	moveq #0,d3
	tst.b create_avi
	beq.s .pas_avi
	move.l header_buffer,a0
	moveq #51,d0
.avi_1:
	move.b d3,(a0)+
	move.b d2,(a0)+
	move.b d1,(a0)+
	sf (a0)+
	add.b d0,d1
	bcc.s .avi_1
	moveq #0,d1
	add.b d0,d2
	bcc.s .avi_1
	moveq #0,d2
	add.b d0,d3
	bcc.s .avi_1
	moveq #39,d0
.avi_2:
	clr.l (a0)+
	dbf d0,.avi_2
	bra.s .pas_premier
.pas_avi:
	move.l mov_pal,a0
	clr.l (a0)+
	clr (a0)+
	clr.b (a0)+
	st (a0)+
	move #13107,d0
	moveq #0,d4
.mov_1:
	move d4,(a0)+
	move d1,(a0)+
	move d2,(a0)+
	move d3,(a0)+
	addq #1,d4
	add d0,d1
	bcc.s .mov_1
	moveq #0,d1
	add d0,d2
	bcc.s .mov_1
	moveq #0,d2
	add d0,d3
	bcc.s .mov_1
	moveq #39,d0
.mov_2:
	move d4,(a0)+
	clr.l (a0)+
	clr (a0)+
	dbf d0,.mov_2
.pas_premier:	
	move.l vanel_adr,a0
	move.l 8(a0),a1				; ses pixels
	move 12(a0),d1					; le flag	
	lea col_mod(pc),a0			; modulos et quotients
	move.l one_buffer,a3			; destination
	move max_imagey,d6
	subq #1,d6						; boucle
	move _vanel_line,d4
	move _vanel_plus,d5
	subq #1,d4						; for the loop	
	lea magic(pc),a2
	cmp #$FFFF,d1
	beq .fligne						; pixels Falcon
.ligne:
	move d4,d7
	lea 16(a2),a4					; fin ligne magic
.pixel:
	move (a1)+,d0					; un pixel NOVA
	move.b (a2)+,d2				; magic (x,y)
	ror #8,d0
	move d0,d1
	and #$1F,d0						; bleu
	move.b 32(a0,d0.w),d3		; le pixel 216
	cmp.b 0(a0,d0.w),d2
	bcc.s .pas_bleu
	add.b #36,d3
.pas_bleu:
	lsr #5,d1
	move d1,d0
	and #$1F,d1						; vert
	add.b 64(a0,d1.w),d3
	cmp.b 0(a0,d1.w),d2
	bcc.s .pas_vert
	addq.b #6,d3
.pas_vert:
	lsr #5,d0						; rouge
	and #$1F,d0
	add.b 96(a0,d0.w),d3
	cmp.b 0(a0,d0.w),d2
	bcc.s .pas_rouge
	addq.b #1,d3
.pas_rouge:
	move.b d3,(a3)+
	cmp.l a2,a4						; fin ligne (magic)?
	bne.s .pas_fin
	lea -16(a4),a2					; recule de 16 positions
.pas_fin:
	dbf d7,.pixel
	move d5,d7
	bra.s .nov1
.efface:
	sf (a3)+
.nov1:
	dbf d7,.efface
	cmp.l #magic+256,a4
	bne.s .pas_fin_magic
	lea -256(a4),a4
.pas_fin_magic:
	move.l a4,a2
	dbf d6,.ligne
	rts				
.fligne:
	move d4,d7
	lea 16(a2),a4					; fin ligne magic
.fpixel:
	move (a1)+,d0					; un pixel Falcon
	move.b (a2)+,d2				; magic (x,y)
	move d0,d1
	and #$1F,d0						; bleu
	move.b 32(a0,d0.w),d3		; le pixel 216
	cmp.b 0(a0,d0.w),d2
	bcc.s .fpas_bleu
	add.b #36,d3
.fpas_bleu:
	lsr #6,d1
	move d1,d0
	and #$1F,d1						; vert
	add.b 64(a0,d1.w),d3
	cmp.b 0(a0,d1.w),d2
	bcc.s .fpas_vert
	addq.b #6,d3
.fpas_vert:
	lsr #5,d0						; rouge
	add.b 96(a0,d0.w),d3
	cmp.b 0(a0,d0.w),d2
	bcc.s .fpas_rouge
	addq.b #1,d3
.fpas_rouge:
	move.b d3,(a3)+
	cmp.l a2,a4						; fin ligne (magic)?
	bne.s .fpas_fin
	lea -16(a4),a2					; recule de 16 positions
.fpas_fin:
	dbf d7,.fpixel
	move d5,d7
	bra.s .fnov1
.fefface:
	sf (a3)+
.fnov1:
	dbf d7,.fefface
	cmp.l #magic+256,a4
	bne.s .fpas_fin_magic
	lea -256(a4),a4
.fpas_fin_magic:
	move.l a4,a2
	dbf d6,.fligne
	rts				

	endif								; fin de dithering 216
	
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
	tst.b cmd_return
	bne.l end_end
	tst.b cmd_erro
	bne.s .lb1
	addq.l #4,sp					; drops A0
	bra.s .lb2
.lb1:
	bsr alert						; alert box
.lb2:
	st stopped
	bra.l end_of_display			; and exits

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
	bmi.s .end
	move.l a2,-(sp)
	GEMDOS 73,6
	tst d0
	beq.s .end
	nop
.end:
	rts

cookie:
	clr.l cpu_value
	clr.l vdo_value
	clr.l snd_value
	sf psnd_flag			; no parallel card
	move.l $4f2,a0
	move.l 36(a0),kbshift	; address of the special keys
	move.l $5A0,a0
	cmp.l #0,a0
	beq .end				; no cookie!
.lb0:
	tst.l (a0)
	beq .end
	cmp.l #'NOVA',(a0)	; a NOVA graphic card?
	bne.s .lb1
	st nova					; yes! nova = FF
	move.l 4(a0),a1
	move 12(a1),is_65k	; mode (3=32768)
	bra .lb4
.lb1:
	cmp.l #'_VDO',(a0)
	bne.s .lb2
	move.l 4(a0),vdo_value
	bra .lb4
.lb2:
	cmp.l #'MgMc',(a0)
	bne.s .lb3
	st nova					; assumes that Mac video = NOVA Video
	bra.s .lb4
.lb3:
	cmp.l #'_SND',(a0)
	bne.s .lb31
	move.l 4(a0),snd_value
	bra.s .lb4
.lb31:
	cmp.l #'PSND',(a0)
	bne.s .lb32
	st psnd_flag
	bra.s .lb4
.lb32:
	cmp.l #'EdDI',(a0)
	bne.s .lb33
	move.l 4(a0),ed_adr
	bra.s .lb4
.lb33:
	cmp.l #'_MIL',(a0)	; MILAN = NOVA.
	bne.s .lb35
	st nova
	move #4,is_65k			; pas de 32768 support‚
	bra.s .lb4
.lb35:
	cmp.l #'_CPU',(a0)
	bne.s .lb4
	move.l 4(a0),cpu_value
.lb4:
	addq.l #8,a0			; next cookie
	bra .lb0
.end: rts

	if REG=1
		
nova_adapt:
	tst.b is_65k
	bne.s falcon_adapt
	lea hc_rmap,a0
	lea hc_gmap,a1
	lea hc_bmap,a2
	moveq #0,d3
.loop:
	move d3,d0
	lsl #2,d0		; red
	move d3,d1
	ror #3,d1		; green
	move d3,d2
	rol #8,d2		; blue
	moveq #7,d4
.lb0:
	move d0,(a0)+
	move d1,(a1)+
	move d2,(a2)+
	dbf d4,.lb0
	addq #1,d3
	cmp #32,d3
	bmi.s .loop
	rts

falcon_adapt:
	lea hc_rmap,a0
	lea hc_gmap,a1
	lea hc_bmap,a2
	moveq #0,d3		; blue
.loop:
	move d3,d0
	ror #5,d0		; red
	move d3,d1
	rol #6,d1		; green
	moveq #7,d4
.lb0:
	move d0,(a0)+
	move d1,(a1)+
	move d3,(a2)+
	dbf d4,.lb0
	addq #1,d3
	cmp #32,d3
	bmi.s .loop
	tst.b is_65k
	bne.s .inverse
	rts
.inverse:
	move #255,d4
.lb1:
	move -(a0),d0
	move -(a1),d1
	move -(a2),d2
	ror #8,d0
	move d0,(a0)
	ror #8,d1
	move d1,(a1)
	ror #8,d2
	move d2,(a2)
	dbf d4,.lb1
	rts
	
	else
	
gen_tc_to_grey:
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
	tst.b is_65k
	bne.s .lb4
	tst.b nova
	beq.s .lb4
	lsl #5,d5
	or d5,d4
	lsl #5,d5
	or d5,d4
	ror #8,d4
	bra.s .lb5
.lb4:
	lsl #6,d5
	or d5,d4
	lsl #5,d5
	or d5,d4
	tst.b is_65k
	beq.s .lb5
	ror #8,d4
.lb5:
	move d4,(a6)+			; the grey for that rgb
	addq.l #1,d0			; blue counts for 1
	dbf d3,.lb3
	sub.l #26,d0			; -32 (to reset the blue) and +6 (for the green)
	dbf d2,.lb2
	sub.l #189,d0			; -192 (to reset the green) and +3 (for the red)
	dbf d1,.lb1
	rts	
	
	endif


	; the xbios palette (4096) into 16 bits (grey or color)
	
xbiospal_16:
	lea cvid_fix1,a0
	lea 8192(a0),a1
	moveq #0,d0
.lb0:
	bfextu d0{20:4},d1	; red
	bfextu d0{24:4},d2	; green
	bfextu d0{28:4},d3	; blue
	add d1,d1
	bclr #4,d1
	beq.s .lb1
	addq #1,d1
.lb1:
	move d1,d4
	add d2,d2
	bclr #4,d2
	beq.s .lb2
	addq #1,d2
.lb2:
	lsl #4,d4
	or d2,d4
	add d3,d3
	bclr #4,d3
	beq.s .lb3
	addq #1,d3
.lb3:
	lsl #4,d4
	or d3,d4
	if REG=1
		lsl #8,d1
		add d3,d3
		tst.b is_65k
		bne.s .falc
		tst.b nova
		beq.s .falc
		lsl #3,d1
		lsl #6,d2
		or d1,d2
		or d3,d2
		ror #8,d2
		bra.s .ok
		.falc:
		lsl #4,d1
		lsl #7,d2
		or d1,d2
		or d3,d2
		tst.b is_65k
		beq.s .ok
		ror #8,d2
	else
		add d2,d2
		add d1,d2
		move d2,d1
		add d2,d2
		add d1,d2
		add d3,d2		; brighness from 0 to 150 maxi (more often 140)
		add d2,d2		; 0 to 280 (or 300)
		divs #9,d2 					
		cmp #32,d2
		bmi.s .zzz
		moveq #31,d2
		.zzz:
		move d2,d1
		lsl #8,d1
		move d2,d3
		tst.b is_65k
		bne.s .falc
		tst.b nova
		beq.s .falc
		lsl #2,d1
		lsl #5,d3
		or d3,d2
		or d1,d2
		ror #8,d2
		bra.s .ok
		.falc:
		lsl #3,d1
		lsl #6,d3
		or d3,d2
		or d1,d2
		tst.b is_65k
		beq.s .ok
		ror #8,d2		
	endif
.ok:
	move d2,(a0)+			; first table (st format)
	move d2,(a1,d4.w*2)	; second table (tt format)
	addq #1,d0
	cmp #4096,d0
	bmi .lb0
	rts
	
		
; for seq4 if not registered only

	if REG=0
	
xbiospal_grey:
	lea cvid_fix1,a0
	lea 8192(a0),a1
	moveq #0,d0
.lb0:
	bfextu d0{20:4},d1	; red
	bfextu d0{24:4},d2	; green
	bfextu d0{28:4},d3	; blue
	add d1,d1
	bclr #4,d1
	beq.s .lb1
	addq #1,d1
.lb1:
	move d1,d4
	add d2,d2
	bclr #4,d2
	beq.s .lb2
	addq #1,d2
.lb2:
	lsl #4,d4
	or d2,d4
	add d3,d3
	bclr #4,d3
	beq.s .lb3
	addq #1,d3
.lb3:
	lsl #4,d4
	or d3,d4
	add d2,d2
	add d1,d2
	move d2,d1
	add d2,d2
	add d1,d2
	add d3,d2		; brighness from 0 to 150 maxi (more often 140)
	divs #9,d2 					
	cmp #16,d2
	bmi.s .zzz
	moveq #15,d2
.zzz:
	move d2,d3
	lsl #4,d3
	or d2,d3
	lsl #4,d3
	or d2,d3
	move d3,(a1,d4.w*2)
	bclr #0,d2
	beq.s .ok
	bset #4,d2
.ok:
	lsr #1,d2
	move d2,d3
	lsl #4,d3
	or d3,d2
	lsl #4,d3
	or d3,d2
	move d2,(a0)+
	addq #1,d0
	cmp #4096,d0
	bmi.s .lb0
	rts
	
	endif
		
gen_16_to_grey:
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
	divs #310,d4			;     "        "  0 to 255
	sub #255,d4
	bmi.s .lb4
	moveq #0,d4
.lb4:
	neg.b d4
	move.b d4,(a6)+		; the color index for that rgb
	addq.l #1,d0			; blue counts for 1
	dbf d3,.lb3
	sub.l #26,d0			; -32 (to reset the blue) and +6 (for the green)
	dbf d2,.lb2
	sub.l #189,d0			; -192 (to reset the green) and +3 (for the red)
	dbf d1,.lb1
	rts

	if REG=1
fast_y_to_grey:
	lea hc_rmap,a2
	lea hc_gmap,a3
	lea hc_bmap,a4
	move.l hc_cvid,a6	
	moveq #127,d0
.lb0:
	move.l (a2)+,d1
	or.l (a3)+,d1
	or.l (a4)+,d1
	move d1,(a6)+
	dbf d0,.lb0
	rts
	endif
	
gen_yuv_tab:
	move #$100,d2			; y inc=1, one loop to 256
	move.l comp_txt,d1
	not.l d1
	cmp.l #$9689ccce,d1
	beq.s .iv
	cmp.l #$9689cccd,d1
	bne.s .not_invers
.iv:
	if REG=1
		tst.b fast_mode
		bne fast_y_to_grey
	endif
	move #$201,d2			; y inc=2, 2 loops to 256
	lea qt_vr_tab,a0
	lea 32(a0),a1
	moveq #15,d0
.invers:
	add #44,64(a0)
	sub #44,64(a1)
	add #92,128(a0)
	sub #92,128(a1)
	sub #227,192(a0)
	add #227,192(a1)
	sub #180,(a0)+
	add #180,(a1)+
	dbf d0,.invers
.not_invers:
	move d2,-(sp)
	lea hc_rmap,a2
	lea hc_gmap,a3
	lea hc_bmap,a4
	move.l hc_cvid,a6
	lea qt_ug_tab,a0
	moveq #31,d0			; u
.loop_u:
	move 128(a0),d7		; ub_tab(u)
	move (a0)+,a5			; ug_tab(u)
	lea qt_vr_tab,a1
	moveq #31,d1			; v
.loop_v:
	move (sp),-(sp)
	move 128(a1),d5		; vg_tab(v)
	add a5,d5				; ug_tab(u) + vg_tab(v)
	move (a1)+,d4			; vr_tab(v)
	moveq #0,d2				; y
.loop_y:
	move d2,d3
	add d4,d3				; r
	bpl.s .lb0
	moveq #0,d3
.lb0:
	cmp #256,d3
	bmi.s .lb1
	move #255,d3
.lb1:
	moveq #0,d6
	move (a2,d3.w*2),d6	; rmap
	move d2,d3
	add d5,d3				; g
	bpl.s .lb2
	moveq #0,d3
.lb2:
	cmp #256,d3
	bmi.s .lb3
	move #255,d3
.lb3:
	add (a3,d3.w*2),d6	; rmap | gmap
	move d2,d3
	add d7,d3				; b
	bpl.s .lb4
	moveq #0,d3
.lb4:
	cmp #256,d3
	bmi.s .lb5
	move #255,d3
.lb5:
	add (a4,d3.w*2),d6	; rmap | gmap | bmap
	if REG=0
		divs #10,d6					; from 0 to 31
		move d6,d3
		lsl #5,d3
		or d3,d6
		lsl #5,d3
		or d3,d6
		ror #8,d6
		tst.b is_65k
		bne.s .lb9
		tst.b nova
		bne.s .lb8
	.lb9:
		FALC16 d6
		tst.b is_65k
		beq.s .lb8
		ror #8,d6
	.lb8:
	endif
	move d6,(a6)+			; into hc_cvid
	add.b (sp),d2
	bne .loop_y
	subq.b #1,1(sp)
	beq .loop_y
	addq.l #2,sp
	dbf d1,.loop_v
	dbf d0,.loop_u
	cmp.w #$201,(sp)+
	bne.s .not_revers
	lea qt_vr_tab,a0
	lea 32(a0),a1
	moveq #15,d0
.revers:
	sub #44,64(a0)
	add #44,64(a1)
	sub #92,128(a0)
	add #92,128(a1)
	add #227,192(a0)
	sub #227,192(a1)
	add #180,(a0)+
	sub #180,(a1)+
	dbf d0,.revers
.not_revers:
	rts
	
	
adapt_256:
	lea hc_rmap,a0
	lea hc_gmap,a1
	lea hc_bmap,a2
	moveq #0,d3		; blue
.loop:
	move d3,d0		; green
	add d0,d0
	move d0,d2
	add d0,d0
	add d2,d0		; green*6 for brightness
	move d3,d1
	add d1,d1
	add d3,d1		; red*3
	moveq #7,d4
.lb0:
	move d1,(a0)+
	move d0,(a1)+
	move d3,(a2)+
	dbf d4,.lb0
	addq #1,d3
	cmp #32,d3
	bmi.s .loop
	rts

set_colors:
	tst.b is_tt
	bne .tt_pal				; because of NVDI...
	lea indexs+512,a6		; starts with the black
	lea .offsets,a5
	moveq #0,d6					; the grey level (0 -> 1000)
.lb0:
	move.w (a5)+,d7
.lb1:
	lea vs_int,a0
	move -(a6),(a0)+
	bmi.s .end
	move d6,(a0)+
	move d6,(a0)+
	move d6,(a0)
	GEM_VDI vs_color
	subq #1,d7
	bmi.s .lb2
	addq #4,d6					; another grey level
	bra.s .lb1
.lb2:
	addq #3,d6
	lea vs_int,a0
	move -(a6),(a0)+
	bmi.s .end
	move d6,(a0)+
	move d6,(a0)+
	move d6,(a0)
	GEM_VDI vs_color
	bra.s .lb0
.end:
	rts
.tt_pal:
	move.w #$FFF,d7
	moveq #0,d6			; counter (0-255)
.next:
	moveq #15,d5		; counter (0-15)
.tt_loop:
	move d7,-(sp)
	move d6,-(sp)
	XBIOS 83,6			; esetcolor
	addq #1,d6
	dbf d5,.tt_loop
	sub #$111,d7
	bpl.s .next
	rts
	
; first grey scale is 0, each entry indicates the number of times to add 4
; then we must add once 3.
.offsets: dc.w 6,12,11,12,12,12,11,12,12,12,11,12,12,12,11,12,12,12,11,12,6
			dc.w -1		; to end the index table
indexs: dc.w 0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,255
a	set 16
	rept 239
	dc.w a
a  set a+1
	endr
	dc.w 1
	
grey_mov:
	move grey_depth,d0
	move planes,d1
	lea cvid_fix0,a6
	cmp #16,d1
	beq.s .tc
	move.l a6,a0			; for FLI color 256
	move #$0100,(a6)+		; one bloc
	clr.b (a6)+				; color start
	cmp #8,d0
	bne.s .fli1
	clr.b (a6)+				; 256 greys
	move #255,d0
	swap d0
	cmp #'IN',d0
	bne.s .normal
	add #768,a6
	swap d0
.lb44:
	move.b d0,-(a6)
	move.b d0,-(a6)
	move.b d0,-(a6)
	dbf d0,.lb44
	bra.s .go
.normal:
	swap d0
.lb4:
	move.b d0,(a6)+
	move.b d0,(a6)+
	move.b d0,(a6)+		; rvb
	dbf d0,.lb4
.go:
	bra.l fli_color_256_256
.fli1:
	cmp #4,d0
	bne.s .fli2
	move.b #16,(a6)+
	moveq #14,d0
	move #255,d1
.lb5:
	move.b d1,(a6)+
	move.b d1,(a6)+
	move.b d1,(a6)+
	sub #16,d1
	dbf d0,.lb5
	clr.l (a6)
	bra.s .go
.fli2:
	move.b #4,(a6)+
	move.l #$FFFFFFAA,(a6)+
	move.l #$AAAA5555,(a6)+
	move.l #$55000000,(a6)+
	bra.s .go		
.tc:
	cmp #8,d0
	bne.s .tc1
	moveq #31,d0		; here, 256 grey
	cmp.l #'CDV1',comp_txt
	beq .tc_cd_stratos
	cmp.l #'mpeg',comp_txt
	beq .tc_cd_stratos
	move #$7FFF,d1
.lb0:
	move d1,d3
	ror #8,d3
	tst.b is_65k
	bne.s .lb00
	tst.b nova
	bne.s .lb1
.lb00:
	FALC16 d3
	tst.b is_65k
	beq.s .lb1
	ror #8,d3
.lb1:		
	rept 8
	move d3,(a6)+
	endr
	sub #$421,d1
	dbf d0,.lb0
	rts
.tc1:
	cmp #4,d0
	bne.s .tc2
	moveq #16,d0		; here 16 grey
	move #$7FFF,d1
	bra.s .lb6
.lb2:
	move d3,(a6)+
	sub #$842,d1
.lb6:
	move d1,d3
	ror #8,d3
	tst.b is_65k
	bne.s .lb66
	tst.b nova
	bne.s .lb3
.lb66:
	FALC16 d3
	tst.b is_65k
	beq.s .lb3
	ror #8,d3
.lb3:
	dbf d0,.lb2
	rts
.tc2:
	tst.b is_65k
	bne.s .tc4
	tst.b nova
	bne.s .tc3
	move.l #$FFFF528A,(a6)+		; here 4 grey (Falcon)
	move.l #$29450000,(a6)+
	rts
.tc4:
	move.l #$FFFF8A52,(a6)+
	move.l #$45290000,(a6)+
	rts
.tc3:
	move.l #$FF7F4A29,(a6)+		; here 4 grey (NOVA)
	move.l #$a5140000,(a6)+
	rts
.tc_cd_stratos:
	moveq #0,d1
.cd_lb0:
	move d1,d3
	ror #8,d3
	tst.b is_65k
	bne.s .cd_lb00
	tst.b nova
	bne.s .cd_lb1
.cd_lb00:
	FALC16 d3
	tst.b is_65k
	beq.s .cd_lb1
	ror #8,d3
.cd_lb1:		
	rept 8
	move d3,(a6)+
	endr
	add #$421,d1
	dbf d0,.cd_lb0
	rept 8
	clr -(a6)			; 255 = black
	endr
	rts

save_256:
	lea col_sav,a6
	move #255,vq_int
.lb0:
	GEM_VDI vq_color
	lea intout+2,a0
	move.l (a0)+,(a6)+	; red+green
	move.w (a0),(a6)+		; blue
	subq #1,vq_int
	bpl.s .lb0
	rts

restore_256:
	tst.b slide_flag
	bne.s .out
	lea col_sav,a6
	move #255,vs_int
.lb0:
	lea vs_int+2,a0
	move.l (a6)+,(a0)+
	move (a6)+,(a0)
	GEM_VDI vs_color
	subq #1,vs_int
	bpl.s .lb0
.out:
	rts
	
redraw:
	tst.b slide_flag
	bne.s .out
	move #2,wu_int
	GEM_AES wind_update
	GEM_AES evnt_timer
	move #3,wu_int
	GEM_AES wind_update
.out:
	rts
		
init_rect:
	move.l kbshift,a0
	move.b (a0),d0
	and.b #$3,d0			; shift???
	sne fast_mode			; to accelerate IV32 or MPEG
	bsr redraw
	clr.l fd_int+10
	move.l work_out,d0
	add.l #$10001,d0
	move.l d0,fd_int+14
	move d0,d3				; screenw
	swap d0
	move d0,d4				; screenh
	tst.b slide_flag
	bpl.s .no_trap			; 0 or $7f
	GEM_VDI hide_mouse
	clr fd_int
	GEM_AES form_dial    ; reserves screen	
.no_trap:
	sf switched				; default is no resolution switch
	tst.b create_mov
	bne .no_switch			; no display for creation
	tst.b nova
	bne .no_switch			; on a NOVA, never switch!
	tst.b res_switch		; can we switch?
	beq .no_switch			; no!
	bpl.s .tt_sw
	move.l old_screen,physbase	; supposes it's enough
	move.l old_size,d0	; current size of screen
	cmp.l #153600,d0
	bpl .enough
	clr -(sp)				; only st ram
	move.l #153856,-(sp)
	GEMDOS 68,8
	move.l d0,physbase2
	and.l #$ffffff00,d0
	bmi.s .glups
	bne .ok
.glups:
	lea mem_error,a0
	bra ooops
.tt_sw:
	move planes,planes_sav
	move.l comp_txt,d1
	cmp.l #'CDH1',d1
	beq.s .st_high
	cmp.l #'dlt4',d1
	beq.s .tt_sw_16
	cmp.l #'seq4',d1
	beq.s .tt_sw_16
	cmp.l #'kin4',d1
	beq.s .tt_sw_16
	cmp.l #'VMAS',d1
	beq.s .tt_sw_16
	cmp.l #'CDL1',d1
	beq.s .tt_sw_16
	cmp.l #'dega',d1
	beq.s .tt_sw_16
	cmp.l #'neoc',d1
	beq.s .tt_sw_16
	move.b #'0',d1
	cmp.l #'flm0',d1
	bne.s .tt_sw_256
	move tt_res,d1
	beq.s .tt_sw_16	; 0: st low
	cmp #7,d1
	beq.s .tt_sw_256	; 7: TT low
	cmp #1,d1
	beq.s .st_high
	cmp #2,d1
	beq.s .st_med
.tt_med:
	moveq #4,d0
	move.l #$27f01df,d1
	bra.s .tt_com
.st_high:
	moveq #1,d0
	move.l #$27f018f,d1
	bra.s .tt_com
.st_med:
	moveq #2,d0
	move.l #$27f00c7,d1
	bra.s .tt_com
.tt_sw_16:
	moveq #4,d0
	move.l #$13f00c7,d1
	bra.s .tt_com
.tt_sw_256:	
	moveq #8,d0
	move.l #$13f01df,d1
.tt_com:
	cmp planes,d0
	bne.s .change_res
	cmp.l work_out,d1
	beq.s .no_switch
.change_res:	
	st switched
	move d0,planes
	move.l d1,work_out
	bra.s .no_switch
.ok:
	move.l d0,physbase
.enough:
	move planes,planes_sav
	move #16,planes
	st switched
	move.l #$13f00ef,work_out	; 319 x 239
.no_switch:
	move.l comp_txt,d1
	cmp.l #'flm8',d1
	beq.s .cec
	cmp.l #'flm4',d1
	beq.s .cec
	cmp.l #'dlt4',d1
	beq.s .cec
	cmp.l #'kin4',d1
	beq.s .cec
	cmp.l #'seq4',d1
	beq.s .cec
	cmp.l #'VMAS',d1
	beq.s .cec
	cmp.l #'CDL1',d1
	beq.s .cec
	cmp.l #'dega',d1
	beq.s .cec
	cmp.l #'neoc',d1
	bne.s .zez
.cec:
	cmp #16,planes
	bne.s .ses
	bsr xbiospal_16
	bra .lb2
.ses:
	if REG=0
		bsr xbiospal_grey
	endif
	bra .lb2
.zez:
	cmp.l #'yuv2',d1
	beq.s .lb1x
	cmp.l #'yuv9',d1
	beq.s .lb1x
	cmp.l #'yvu9',d1
	beq.s .lb1x
	cmp.l #'YVU9',d1
	beq.s .lb1x
	cmp.l #'cvid',d1
	beq.s .lb1x
	tst.b fast_mode
	bne.s .coucou
	cmp.l #'mpeg',d1
	beq.s .lb1x
.coucou:
	move.l #$9689cccd,d0
	not.l d0
	cmp.l d0,d1
	beq.s .iv
	subq #1,d0
	cmp.l d0,d1
	bne.s .lb1
.iv:
	bsr init_iv32_buf
.lb1x:
	cmp #8,planes
	beq .lb2								; no table if in grey!
	move.l #$80000,d1					; if cvid (or other yuv) allocate table
	bsr malloc
	move.l d0,hc_cvid
	bsr gen_yuv_tab					; and caculates it
	bra .lb2
.lb1:
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
	cmp #8,planes
	if REG=1
		bne.s .lb2
	else
		beq.s .lb3
		move.l #65536,d1
		bsr malloc
		move.l d0,hc_cvid
		bsr gen_tc_to_grey
		bra.s .lb2	
	.lb3:
	endif
	move.l #32768,d1
	bsr malloc
	move.l d0,hc_cvid
	bsr gen_16_to_grey				; only for 16bits images displayed in 256c
.lb2:
	tst.b vr2_flag
	beq.s .vv0
	move.l vr2_x,d0
	bra.s .vv1
.vv0:
	move max_imagex,d0
.vv1:
	addq #7,d0
	addq #8,d0
	and.b #$f0,d0
	move d0,alignwidth

	moveq #1,d0
	add.w work_out,d0					; screen width
	move d0,screenw
	tst.b switched
	bne.s .areu							; we switch, don't use cmd_coord
	tst.b cmd_coord
	beq.s .areu							; no coords specified...
	move cmd_x,d0						; else, use it!
	bra.s lb6
.areu:	
	sub alignwidth,d0
	asr #1,d0							; offsx
	bpl.s lb6
	moveq #0,d0
lb6:
	move.l d0,offsx
		
	moveq #1,d1
	add.w work_out+2,d1				; screen height
	move d1,screenh
	tst.b switched
	bne.s .areu							; we switch, don't use cmd_coord
	tst.b cmd_coord
	beq.s .areu							; no coords specified...
	move cmd_y,d1						; else, use it!
	bra.s lb7
.areu:
	tst.b vr2_flag
	beq.s .vv2
	sub vr2_y+2,d1
	bra.s .vv3
.vv2:
	sub max_imagey,d1
.vv3:
	asr #1,d1							; offsy
	bpl.s lb7
	moveq #0,d1
lb7:
	move d1,offsy

	tst.b switched
	bne.s .no_align			; if switch, no real X length
	tst.b ed_adr				; if no Extended VDI, no real X
	beq.s .no_align
	
	move ed_adr+2,screenw	; else, real X!!
.no_align:	
	muls screenw,d1
	ext.l d0
	add.l d0,d1
	move.l d1,d5
	cmp #8,planes
	beq.s .lb0
	add.l d1,d5							; a pixel is 2 bytes with 16 planes
.lb0:
	move.l old_screen,d0				; GEM physbase
	tst.b switched
	beq.s .aaa
	move.l physbase,d0				; my physbase
.aaa:
	add.l d0,d5							; physbase+offsets
	move.l d5,image					; start of image into video memory
	
	st display
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
	
	tst.b is_tt
	beq .exit
	move.l comp_txt,d1
	cmp.l #'VMAS',d1
	beq .exit
	cmp.l #'CDL1',d1
	beq .exit
	cmp.l #'VFAL',d1
	beq .exit
	cmp.l #'CDV1',d1
	beq .exit
	cmp.l #'CDH1',d1
	beq .exit
	cmp.l #'seq4',d1
	beq .exit
	cmp.l #'kin4',d1
	beq .exit
	cmp.l #'dlt4',d1
	beq .exit	
	cmp.l #'dega',d1
	beq.s .exit
	cmp.l #'neoc',d1
	beq.s .exit
	move.b #'0',d1
	cmp.l #'dl/0',d1
	beq.s .exit
	cmp.l #'flm0',d1
	beq.s .exit
	move alignwidth,d1
	move d1,screenw
	tst.b vr2_flag
	beq.s .vv4
	move.l vr2_y,d0
	bra.s .vv5
.vv4:
	move max_imagey,d0
.vv5:
	move d0,screenh
	bsr adapt_ratio
	muls d0,d1					; number of bytes to allocate	
	move.l d1,d3
	bsr malloc
	move.l image,d1
	and.b #$f0,d1				; 16 aligned	
	move.l d1,tt_screen		; not directly into video RAM
	move.l d0,image			; but into my buffer
	bsr clear_buffer
	move.l compression,tt_comp
	move.l d7,compression
.exit:
	rts
	
adapt_ratio:
	cmp #321,d1
	bmi.s .lb0
	add #31,d1
	and.b #$e0,d1
	move d1,alignwidth	; 32 bytes aligned
	move d1,screenw
	move.l #planes_disp_half,d7
	tst.b switched
	bne.s .lb4		; we switch, no cmd coords
	tst.b cmd_coord
	beq.s .lb4		; no coords anyway
	rts				; else keep position
.lb4:
	move d1,d5
	asr #2,d5
	move offsy,d6
.end:
	muls #320,d6
	add.l #160,d6
	ext.l d5
	sub.l d5,d6
	add.l physbase,d6
	move.l d6,image
	rts
.lb0:
	cmp #241,d0
	bmi.s .lb1
	move.l #planes_display,d7
	rts
.lb1:
	move.l #planes_disp_double,d7
	tst.b switched
	bne.s .lb2		; we switch, no cmd coords
	tst.b cmd_coord
	beq.s .lb2		; no coords anyway
	rts				; else keep position
.lb2:
	move #240,d6
	sub d0,d6		; new offsy
	move d1,d5
	asr d5
	bra.s .end	
	
clear_buffer:
	move.l d0,a0
	lsr.l #4,d3		; d3 is 16 aligned
.lb0:
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	subq.l #1,d3
	bne.s .lb0
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
	move #3,-(sp)
	move.l d1,-(sp)
	GEMDOS 68,8			; alloc preffering TT ram
	move.l d0,a0		; adresse buffer
	move.l d0,bat_text	; as the iv_buffer
	bmi.s .lb0
	beq.s .lb0
	move.l a0,a1
	lea _iv32,a0
	bsr.l cache_off
	bsr ice_decrunch
	bsr.l cache_on
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
.lb0:
	lea mem_error,a0
	bra ooops

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
	move avi_comp_flag,d4
	beq.s .ok7				; unknown = OK
	cmp #$0100,d4			; PCM
	bne .bye
.ok7:
	lea real_freq_tab,a2
	move.l (a2),d4
	move.l d4,real_freq	; for VMAS
	cmp.l 12(a2),d4
	sne real_freq			; $FF if TT, $00 if Falcon (for FLM)
	move.l comp_txt,d4
	cmp.l #'VMAS',d4
	beq .ok2
	cmp.l #'VFAL',d4
	beq .ok2
	swap d4
	cmp #'CD',d4
	beq .ok2
	swap d4
	move.b #'0',d4
	cmp.l #'flm0',d4
	beq .ok2
	move.l s_signe,d4
	cmp.l #'twos',d4
	beq.s .ok4
	cmp.l #'raw ',d4
	beq.s .ok4
	cmp.l #'ima4',d4
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
	add.l #4,a2
	move.l #25033,d4
	cmp.l #21800,d1
	bmi.s .bye
	cmp.l #22700,d1		; for 25kHz, 21,8 to 22,7 are accepted
	bmi.s .ok	
	add.l #4,a2
	move.l #50066,d4
	cmp.l #43600,d1
	bmi.s .bye
	cmp.l #45400,d1
	bpl.s .bye
.ok:
	move.l (a2),real_freq
	move.l d4,frequency	
	move sound_bits,d1
	cmp #4,d1
	beq.s .ok2
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
	tst.b snd_value
	beq.s .bye				; if $00, no DMA sound!!!!
	sf bad_sound
	rts
.bye:
	st bad_sound
	rts
	
adapt_d4_size:
   tst.b snd_value
   bmi.s .next				; don't create, but DMA, so st‚r‚o accepted
   cmp #2,channels
   bne.s .next
   asr.l #1,d4				; with no DMA: no stereo, so half size
.next:
	moveq #0,d0				; no ima4... default
	move.l d0,ima4_offs	; no offset
	cmp.l #'ima4',s_signe
	bne.s .no_comp
	bsr.l INIT_TAB_IMA4
	move.l #'twos',s_signe
	moveq #7,d0				; ima4 + 16bits + stereo
	lsl.l #6,d4				; *64
	divs.l #17,d4			; /17
	move.l d3,d1
	lsl.l #6,d3
	cmp #2,channels
	beq.s .comp_ste
	moveq #6,d0				; ima4 + 16bits + mono
.comp_ste:
	divs.l #17,d3			; 1 + 64/17 of the buffer =comp + uncomp
	move.l d3,ima4_offs
	add.l d1,d3
	move #16,sound_bits
	bra.s .lb9
.no_comp:
	cmp #8,sound_bits
	beq.s .lb9				; 8 bits, normal
	asr.l #1,d4				; else, 16 bits are converted into 8, half size
.lb9:
	move.b d0,ima4_flag
	addq.l #7,d4
	asr.l #3,d4				; rounded to the number of 8 bytes groups
	move.l d4,-(sp)
	asl.l #3,d4
	tst.b snd_value
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
	addq.l #2,d4			; Magic hangs if all used!!!
	move.l d4,snd_size
	rts	

old_init_sound:
	move.l sound_num,d7
	move.l chunkoff_num,d6
	move.l chunkoffs,a5
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
	moveq #0,d4					; the total size of the sound (bytes)
	moveq #0,d3					; the max size (for one sample)
	tst.b gtel_sound
	beq.s .titi
	bsr old_init_sound
	bra .common
.titi:
	move.l sound_num,a4
	addq.l #1,a4
	moveq #1,d7
	moveq #0,d6					; pas de d‚calage
	cmp.l #'ima4',s_signe
	bne.s .pas_comp
	cmp #1,channels
	bne.s .8bits
	moveq #-1,d6
	bra.s .8bits
.pas_comp:
	cmp #1,channels
	beq.s .mono
	addq #1,d6
.mono:
	cmp #8,sound_bits
	beq.s .8bits
	addq #1,d6					; nombre de d‚calages
.8bits:
	lea snd_size_offs,a0
	move.l (a0)+,d5			; num
	SEEK (a0),0					; bonne position
.coucou:
	subq #1,d5
	bsr read_3_long			; taille,tag,jusqu'ou
	tst d6
	bpl.s .normal
	lsr.l #1,d0
	bra.s .tutu
.normal:
	lsl.l d6,d0					; decale selon 8/16 bits et mono/stereo
.tutu:
	tst d5
	bne.s .toto1
	move.l a4,d2				; total + 1 (aller jusqu'a la fin)
.toto1:
	addq.l #4,a6
	move.l d0,(a6)+
	add.l d0,d4					; taille totale
	cmp.l d0,d3
	bpl.s .lb7
	move.l d0,d3
.lb7:
	addq.l #1,d7
	cmp.l d7,d2
	bne.s .toto1
	tst d5
	bne.s .coucou
.common:
	bsr adapt_d4_size		; and eventually D3 if ima4
	move.l tree_sav,a0
	btst #0,275(a0)
	beq.s .bye
	bsr read_sound			; reads the whole sound into memory
.bye:
	bsr sync_tab
	rts

read_sound:
	sf ttram_sound		; 00 on copie en ST Ram, FF on copie en tt Ram
	move.l d3,-(a7)
	GEMDOS $48,6
	tst.l d0
	bmi .end				; not enough memory for the temporary buffer
	move.l d0,snd_temp
	beq .end
	move.l d0,a3
	tst.b step_mode		; if step mode, only copies!!!
	bne.s .just_save
	add.l sound_num,d4	; plus 1 octet d'ecart par bloc
	moveq #64,d0
	add.l d0,d4				; plus une securite...
	move.l d4,stram_size	; default value if all fits in it
	clr -(sp)				; ST Ram only	
	move.l #-1,-(a7)		; asks for the memory available
	GEMDOS $44,8
	tst.l d0
	bmi .end				; an error
	beq .end
	cmp.l d4,d0				; compared to the memory wanted
	bpl.s .enough			; whow! it's enough!
	move.l d4,d6
	sub.l d0,d6				; memory left (to be allocated in TT ram)
	move #1,-(sp)
	move.l d6,-(sp)
	GEMDOS $44,8			; tries to allocate the remaining into TT ram
	tst.l d0
	bmi .end				; no, impossible!
	move.l d0,snd_pos
	move.l d0,s_buffer_2
	beq .end				; not enough
	move.l d6,ttram_size
	sub.l d6,d4				; re-calculates the amount available into ST Ram
	move.l d4,stram_size
.enough:
	clr -(sp)
	move.l d4,-(sp)
	GEMDOS $44,8
	move.l d0,s_buffer
	beq .end
	move.l d0,a6
.just_save:
	move.l sound_offs,a5
	move.l sound_num,d7
	movem.l d2-d7/a2-a6,-(sp)
	moveq #1,d6
	moveq #1,d7
	bsr manage_tree
	movem.l (sp)+,d2-d7/a2-a6
	tst.b mvi_flag
	beq .lb0				; avi or mov
	moveq #29,d0
	move.l d0,a5			; first position
	move.l mvi_save_size,d7	; old snd_size
	addq.l #5,d7
	move.l a3,a4
.lb_0:
	SEEK a5,0
	move.l d3,d6			; size
	move.l a4,-(sp)
	move.l d6,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	tst.l d0
	bmi .end
	lea 3(a4),a3
	tst.b (a3)+
	beq.s .lb_3
	tst.b mvi_rem
	beq.s .lb_3
	bpl.s .lb_2
	subq.l #1,d6
	subq.l #1,a5
	clr.b -(a6)
	subq.l #1,a3
	bra.s .lb_3
.lb_2:
	addq.l #1,d6
	addq.l #1,a5
	addq.l #1,a3
	move.b -1(a6),(a6)+
	clr.b (a6)
.lb_3:
	subq.l #5,d6
	sub.l d6,d7	
	bsr treat_sound
	subq.l #3,a3
	move.l (a3),d0
	clr.b d0
	INTEL d0
	add.l d3,a5
	add.l d0,a5				; next position
	subq.l #2,a5
	tst.b mvi_flag
	beq.s .lb_1
	sf mvi_flag
	move.l mvi_next_size,d3
.lb_1:
	cmp.l d3,d7
	bpl .lb_0
	bra.s .common
.lb0:
	SEEK (a5)+,0			; to the good position
	move.l (a5)+,d6
	move.l a3,d0
	add.l ima4_offs,d0	; 0 if uncompressed
	move.l d0,-(sp)		; into the temporary buffer
	move.l d6,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	tst.l d0
	bmi.s .end				; an error
	bsr treat_sound		; copies temp into the real buffer, updates a6
								; or (step mode) saves it into file!
	subq.l #1,d7
	bne.s .lb0
.common:
	tst.b step_mode
	bne.s .just_save2
	move.l a6,d0
	bclr #0,d0
	move.l d0,a6			; turns A6 into an even address
	moveq #0,d0
	tst.b ttram_sound
	beq.s .lb1
	move.l a6,snd_tt_end
	sub.l s_buffer_2,a6
	move.l a6,ttram_size
	move.l a6,d0
	move.l snd_end,a6	; * 
	bra.s .lb2
.lb1:
	move.l a6,snd_end
.lb2:						; *
	sub.l s_buffer,a6
	move.l a6,stram_size
	add.l a6,d0
; .lb2:					; *
	move.l d0,snd_size
.just_save2:
	movem.l d2-d7/a2-a6,-(sp)
	moveq #1,d6
	moveq #-1,d7
	bsr manage_tree
	movem.l (sp)+,d2-d7/a2-a6
	st playing				; ok for playing the sound!
.end:
	rts	

; converting 8 bytes into 9 bytes is equal to converting
; 11025 Hz into 12403 Hz, 22050 Hz into 24806 Hz and 44100 Hz into 49612 Hz
; witch are very close to the DMA frequencies: 12517, 25033 and 50066,
; this is an very good approximation (error 1%).

treat_sound:
	move.b ima4_flag,d1
	beq.s .no_comp
	move.l ima4_offs,a2
	add.l a3,a2		; compressed datas
	move.l a3,a4	; uncompressed
	bsr.l DECOMPRESS_IMA4
	move.l d0,d6	; uncompressed size
.no_comp:
	tst.b step_mode
	bne _save_avr_block
	tst.b ttram_sound
	bne.s .lb8					; yes
	move.l s_buffer,a1		; else, calculates the top address of the ST ram
	add.l stram_size,a1
	bra.s .lb9
.lb8:
	move.l s_buffer_2,a1	; en TT Ram
	add.l ttram_size,a1
.lb9:
	moveq #32,d0			; securite
	sub.l d0,a1				; the top minus 32 bytes
	tst.b snd_value
	bpl yamaha_treat_sound
	move.l a3,a0			; temporary buffer
	cmp #8,sound_bits
	bne bits_16			; it's a 16 bits sample
	move.l d6,d0			; the size
	asr.l #3,d6				; blocs of 8 bytes
	and #7,d0				; remaining
	cmp.l #'twos',s_signe
	bne.s .sign
.lb2:
	cmp.l a1,a6				; at the top?
	bmi.s .z1
	bsr into_tt
.z1:
	move.l (a0)+,(a6)+
	move.l (a0)+,(a6)+	; 8 bytes
	move.b -1(a0),(a6)+	; repeats the last one
	subq.l #1,d6
	bne.s .lb2
	cmp.l a1,a6
	bmi.s .lb3
	bsr into_tt
	bra.s .lb3
.lb4:
	move.b (a0)+,(a6)+
.lb3:
	dbf d0,.lb4				; copies the remaining
	rts
.sign:
	moveq #-128,d1
.lb5:
	cmp.l a1,a6
	bmi.s .z2
	bsr into_tt
.z2:
	rept 8
		move.b (a0)+,d2
		add.b d1,d2
		move.b d2,(a6)+	; copies and signs 8 bytes
	endr
	move.b d2,(a6)+		; repeats the 8th byte
	subq.l #1,d6
	bne.s .lb5
	cmp.l a1,a6
	bmi.s .lb6
	bsr into_tt
	bra.s .lb6
.lb7:
	move.b (a0)+,d2
	add.b d1,d2
	move.b d2,(a6)+		; copies and signstthe remaining
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
	cmp #2,channels
	bne.s .lb5
.lb2:
	cmp.l a1,a6
	bmi.s .z1
	bsr into_tt
.z1:
	movep.l 0(a0),d2
	addq.l #8,a0
	move.l d2,(a6)+
	movep.l 0(a0),d2
	addq.l #8,a0
	move.l d2,(a6)+
	move d2,(a6)+
	subq.l #1,d6
	beq.s .zed
	cmp.l a1,a6
	bmi.s .zz1
	bsr into_tt
.zz1:
	movep.l 0(a0),d2
	addq.l #8,a0
	move.l d2,(a6)+
	movep.l 0(a0),d2
	addq.l #8,a0
	move.l d2,(a6)+
	subq.l #1,d6	
	bne.s .lb2	
.zed:	
	cmp.l a1,a6
	bmi.s .lb3
	bsr into_tt
	bra.s .lb3
.lb4:
	move.b (a0),(a6)+
	addq.l #2,a0
.lb3:
	dbf d0,.lb4				; copies the remaining
	rts
.lb5:
	cmp.l a1,a6
	bmi.s .zzz1
	bsr into_tt
.zzz1:
	movep.l 0(a0),d2
	addq.l #8,a0
	move.l d2,(a6)+
	movep.l 0(a0),d2
	addq.l #8,a0
	move.l d2,(a6)+
	move.b d2,(a6)+
	subq.l #1,d6
	bne.s .lb5
	bra.s .zed
	
into_tt:
	tst.b ttram_sound
	bne.s .end
	move.l a6,snd_end			; the end of the ST Ram buffer
	clr.b (a6)					; if yamaha...
	bclr #0,snd_end+3			; word aligned
	tst.l s_buffer_2			; is there a TT ram buffer?
	beq.s .end					; no...
	move.l s_buffer_2,a6		; yes, go on copying!
	st ttram_sound
	lea  -32(a6),a1
	add.l ttram_size,a1
	rts
.end:
	addq.l #4,sp				; a first RTS
	rts							; and a second one

_save_avr_block:
	cmp #16,sound_bits
	bne.s .lb0
	cmp.l #'rawa',s_signe
	bne.s .lb0
	move.l a3,a0
	move.l d6,d0
.motorola:
	move (a0),d1				; seul cas ou on inverse: AVI en 16 bits
	ror #8,d1
	move d1,(a0)+
	subq.l #2,d0
	bgt.s .motorola
.lb0:
	move.l a3,-(sp)
	move.l d6,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12
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
	cmp.l a1,a6
	bmi.s .z1
	bsr into_tt
.z1:
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
	cmp.l a1,a6
	bmi.s .z2
	bsr into_tt
.z2:
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
	cmp.l a1,a6
	bmi.s .z1
	bsr into_tt
.z1:
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
	cmp.l a1,a6
	bmi.s .z2
	bsr into_tt
.z2:
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
	tst.b vr_flag
	bne.s .yes
	move.l tree_sav,a0
	btst #0,299(a0)		; objetc 'synchronize'
	beq .end					; no sync
.yes:
	move.l t2samps,a0
	cmp.l #0,a0	
	beq .end					; no time table for each frame
	move.l t2samp_num,d2
	moveq #0,d4				; total time
	moveq #0,d3				; total frames
.lb0:
	move.l (a0)+,d0		; number of frames
	add.l d0,d3				; updates the number of frames
	muls.l (a0)+,d0		; times their duration
	add.l d0,d4				; updates the total time
	subq.l #1,d2
	bne.s .lb0				; till the end of t2_samps
	move.l d3,d1
	asl.l #2,d1				; each entry is a long (4 bytes)
	addq.l #8,d1			; plus two dummy entries (the first and the last)
	bsr malloc
	move.l d0,a1

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
	move.l snd_size,d1	; the size in bytes
	tst.b snd_value
	bmi.s .dma
	move.l #9600,d5
	bra.s .lb5
.dma:
	move.l real_freq,d5
	cmp #2,channels
	bne.s .lb5				; not a stereo, 1byte = 1sample
	asr.l #1,d1				; else 2bytes = 1 sample
.lb5:
	moveq #0,d6
	muls.l #200,d6:d1
	divs.l d5,d6:d1	; d1=number of 200th of second for the whole sample
								; to use the Timer C of the system
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
	muls.l d1,d5:d3
	divs.l d4,d5:d3		; d3 is the corresponding duration in 1/200 sec
	move.l d3,(a1)+
	subq.l #1,d0
	bne.s .lb2
	subq.l #1,d2
	bne.s .lb1
	move.l tree_sav,a0
	btst #0,299(a0)		; objetc 'synchronize'
	beq.s .glub					; no sync
	st sync
.glub:
	bsr mfree
	move.l t2samps,a0		; points to the dummy, but the numbers start at 1
	move.l t2samp_num,d2
	bset #7,(a0,d2.l*4)	; the last is always marked!
	sf sync+1				; we can skip a key frame (default)
	move.l ss_tab,a1
	cmp.l #0,a1
	beq.s .lb4				; no stss table! No particular frame, mark all
	move.l ss_num,d0		; else, number of particular frames
	divs.l d0,d2			; number of frames for one key frame
	cmp.l #4,d2				; more than 4?
	bmi.s .lb3
	st sync+1				; yes, we will never skip one key frame
.lb3:
	move.l (a1)+,d1
	bset #7,(a0,d1.l*4)	; marks this address
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
	clr mf_int
	GEM_AES graf_mouse
	GEM_VDI show_mouse
	moveq #1,d7
	moveq #2,d6
	bsr manage_tree
	move #$101,eb_int+4
	GEM_AES evnt_button
	moveq #-1,d7
	moveq #2,d6
	bsr manage_tree
	clr eb_int+4
	GEM_AES evnt_button
	GEM_VDI hide_mouse
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
	tst.b slide_flag
	bne.s .slide
	tst.b command
	beq.s .normal
	cmp #1,d6
	beq.s .normal			; Loading sound...
	cmp #8,d6
	beq.s .normal
.slide:
	move.l #cmd_dial,a1
	tst.b (a1)+
	bne.s .normal			; dialogs allowed
	tst d6
	bne .out				; other than the first dialog
	move.l tree,a0
	btst #0,467(a0)		; window??
	sne can_win
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
	bne.s .no_win
	btst #0,467(a0)			; Window or not?
	sne can_win
	btst #0,491(a0)		; repeat or not?
	sne is_rep
.no_win:
	move intout,d6
	and #$7fff,d6			; the exit object
	move d6,d0
	muls #24,d0
	bclr #0,11(a0,d0.w)	; resets the 'selected' bit of the exit button
	GEM_VDI hide_mouse
.clear:
	tst.b slide_flag
	bne.s .out
	move #3,rect_dial
	GEM_AES form_dial2
	bsr redraw
	cmp #18,d6				; close button???
	bne.s .out
   bra.l end_end				; quit the program
.out:
	rts

principal:
	bsr.s fill_dialog
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
.lb2:						; EQ=stopped, NE=GO
	rts

	; a3 contains the address of the string indicating the type of file
	; d3: bit0=1 playsound/=0max speed
	;		bit1=1 Alt go sans condition/=0voir condition
	;		bit2=1 Alt go si can step/=0 Go tout seul
	; samp_sizes indicates if there are graphics
	;	- max_imagex and max_imagey gives the size
	;	- samp_num gives the number of frames
	;
	; frequency indicates if there is a sound
	; - sound_bits gives the resolution
	; - frequency gives the frequency
	; - channels gives mono or stereo
	
fill_dialog:
	tst.b cmd_return
	bne fill_return_and_exit
	sf step_mode
	clr.l rg_int		; first tree
	GEM_AES rsrc_gaddr
	move.l tree,a1
	move.l a1,tree_sav
	move.l 228(a1),a0	; spec of button (Alt) Go!
	btst #1,d3
	bne.s .alt_go
	btst #2,d3
	beq.s .go_seul
	tst.b can_step
	beq.s .go_seul
.alt_go:
	move.l #'(Alt',(a0)+
	if REG=1
		tst.b can_fast
		beq.s .ntm0
		move.l #')Go',(a0)+
		bra.s .ntm1
	.ntm0:
	endif
	move.l #') Go',(a0)+
.ntm1:
	move #$2100,(a0)		; ! et 0
	bra.s .commun	
.go_seul:
	if REG=1
		tst.b can_fast
		beq.s .ntm2
		move.l #'   ',(a0)+
		move.l #'Go! ',(a0)+
		bra.s .ntm3
	.ntm2:
	endif
	move.l #'   G',(a0)+
	move.l #'o!  ',(a0)+
.ntm3:
	move.w #$2000,(a0)	; space and 0
.commun:
	btst #0,d3
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
	cmp.l #'mpeg',comp_txt
	bne.s .normal
	move.l avi_rate,d0
	bsr int_to_str
	bra.s .common
.normal:
	move.l #2000,d0
	divs.l _delay,d0	; frames/10 sec
	divs #10,d0
	move.l d0,d5
	ext.l d0
	bsr int_to_str				; the int part
	move.b #'.',(a1)+
	swap d5
	add.b #'0',d5
	move.b d5,(a1)+
.common:
	move.l #' f/s',(a1)+
	clr.b (a1)
.lb9:
	moveq #15,d0
	bsr ted_adr	
	rept 6
		move.l (a3)+,(a1)+	; the 24 caracters (maxi)
	endr
	move (a3),(a1)				; and 2 more!
	moveq #17,d0
	bsr ted_adr
	lea dta+30,a0
	lea 11(a1),a1
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+		; 12 char maxi
	moveq #2,d0
	bsr ted_adr
	tst.l samp_sizes
	bne.s .graphics
	clr.b (a1)
	moveq #3,d0
	bsr ted_adr
	move.l #' No ',(a1)+
	move.l #'grap',(a1)+
	move.l #'hics',(a1)+
	move.l #' fou',(a1)+
	move.w #'nd',(a1)+
	clr.b (a1)
	moveq #4,d0
	bsr ted_adr
	clr.b (a1)
	bra .lb3
.graphics:
	move.l #'Disp',(a1)+
	move.l #'lay ',(a1)+
	moveq #0,d0
	move max_imagex,d0
	bsr int_to_str
	move.l #' x  ',(a1)
	addq.l #3,a1
	move max_imagey,d0
	bsr int_to_str
	moveq #3,d0
	bsr ted_adr
	move.l #'with',(a1)+
	move.b #32,(a1)+
	move.l sample_num,d0
	bne.s .connu
	tst.b unknown
	beq.s .connu		; mais nul...
	move.b #'-',(a1)+
	move #'?-',(a1)+
	bra.s .inconnu
.connu:
	bsr int_to_str
.inconnu:
	move.l #' fra',(a1)+
	move.l #'mes.',(a1)+
	clr.b (a1)
	moveq #4,d0
	bsr ted_adr
	tst.b bad_comp
	beq.s .lb2
	move.l #'Unsu',(a1)+
	move.w #'pp',(a1)+
	bra.s .lb1
.lb2:
	move.l #'Supp',(a1)+
.lb1:
	move.l #'orte',(a1)+
	move.l #'d ( ',(a1)
	addq.l #3,a1
	move.l comp_txt,(a1)+
	move.w #$2900,(a1)		; ')' and 0
.lb3:
	moveq #6,d0
	bsr ted_adr
	move.l frequency,d3
	bne.s .sound
	clr.b (a1)
	moveq #7,d0
	bsr ted_adr
	move.l #'No s',(a1)+
	move.l #'ound',(a1)+
	clr.b (a1)
	moveq #8,d0
	bsr ted_adr
	clr.b (a1)
	moveq #0,d2				; play sound unselected
	bra .lb4
.sound:
	move.l #'Soun',(a1)+
	move.w #'d ',(a1)+
	moveq #0,d0
	move sound_bits,d0
	bsr int_to_str
	move.l #' bit',(a1)+
	cmp #2,channels
	beq.s .lb5
	move.l #'s mo',(a1)+
	move.w #'no',(a1)+
	bra.s .lb6
.lb5:
	move.l #'s st',(a1)+
	move.l #'ereo',(a1)+
.lb6:
	clr.b (a1)
	moveq #7,d0
	bsr ted_adr
	move.l #'at  ',(a1)
	addq.l #3,a1
	move.l d3,d0
	bsr int_to_str
	move.l #' Hz.',(a1)+
	clr.b (a1)
	bsr verify_sound
	moveq #8,d0
	bsr ted_adr
	tst.b bad_sound
	beq.s .lb7
	move.l #'Unsu',(a1)+
	move #'pp',(a1)+
	moveq #0,d2				; don't play sound
	bra.s .lb8
.lb7:
	move.l #'Supp',(a1)+
	moveq #1,d2				; play sound
.lb8:
	move.l #'orte',(a1)+
	move #$6400,(a1)+		; d and 0
.lb4:
	move.l tree,a0
	bset #0,299(a0)	; xx.x frames set or synchro
	btst #4,273(a0)		; radio buttons?
	bne.s .end				; yes, don't touch!
	bclr #0,275(a0)
	or.b d2,275(a0)		; state of play sound
.end:
	tst.b vr2_flag
	beq.s .end_end
	bclr #0,299(a0)
.end_end:
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
	divsl.l #10,d1:d0
	add.b #'0',d1
	move.b d1,-(a0)			; one char
	tst.l d0
	bne.s .lb0					; not nul, continue!
.lb1:
	move.b (a0)+,(a1)+
	bne.s .lb1
	subq.l #1,a1
	rts

fill_stat:
	tst.b is_parse
	bne .parse_stat
	moveq #3,d0
	move.l d0,rg_int			; the 3rd dialog
	GEM_AES rsrc_gaddr
	moveq #11,d0
	bsr ted_adr
	lea dta+30,a0				; file name
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+		; 12 char maxi
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
	move.w #' (',(a1)+
	move.l d5,d0
	muls.l #100,d0
	divs.l d6,d0				; in %
	bsr int_to_str
	move.w #'%)',(a1)+
	clr.b (a1)
	moveq #6,d0
	bsr string_adr
	move.l d5,d0
	muls.l #2000,d0
	move.l end_time,d6
	sub.l start_time,d6
	divs.l d6,d0				; number of frames in 10 seconds
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
	divs.l #20,d6				; 1/200 into 1/10 of sec
	divs #10,d6
	move.l d6,d0
	ext.l d0
	bsr int_to_str				; the int part
	move.b #".",(a1)+
	swap d6
	add.b #'0',d6
	move.b d6,(a1)+
	move.l #' sec',(a1)+
	clr.b (a1)
	moveq #3,d6
	rts
.parse_stat:
	moveq #9,d0
	move.l d0,rg_int			; the 3rd dialog
	GEM_AES rsrc_gaddr
	moveq #8,d0
	bsr ted_adr
	lea file,a0				; file name
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+		; 12 char maxi
	moveq #3,d0
	bsr string_adr
	move.l sample_num,d0
	bsr int_to_str
	moveq #4,d0
	bsr string_adr
	move.l disp_frame,d0
	bsr int_to_str
	move.l end_time,d6
	sub.l start_time,d6
	moveq #7,d0				; total time
	bsr string_adr
	divs.l #20,d6				; 1/200 into 1/10 of sec
	divs #10,d6
	move.l d6,d0
	ext.l d0
	bsr int_to_str				; the int part
	move.b #".",(a1)+
	swap d6
	add.b #'0',d6
	move.b d6,(a1)+
	move.l #' sec',(a1)+
	clr.b (a1)
	moveq #9,d6
	rts	


fill_return_and_exit:
	move.l cmd_return_adr,a0
	move #1,(a0)+		; OK
	lea dta+30,a1
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	clr (a0)+		; file name
.copy_type:
	move.b (a3)+,(a0)+
	bne.s .copy_type
	clr.b (a0)+		; type string
	moveq #0,d0		; default: no graphics
	tst.l samp_sizes
	beq.s .lb0
	moveq #1,d0		; or supported graphics
	tst.b bad_comp
	beq.s .lb0
	moveq #-1,d0	; or unsupported
.lb0:
	move d0,(a0)+
	move max_imagex,(a0)+
	move max_imagey,(a0)+
	move.l sample_num,(a0)+
	move.l comp_txt,(a0)+
	moveq #0,d0		; default: no sound
	move.l frequency,d7
	beq.s .lb1
	bsr verify_sound
	moveq #1,d0
	tst.b bad_sound
	beq.s .lb1
	moveq #-1,d0
.lb1:
	move d0,(a0)+
	move sound_bits,(a0)+
	move channels,(a0)+
	move.l d7,(a0)+
	move mov_h,-(sp)
	GEMDOS 62,4
	bra.l end_end

set_video:
	tst.b slide_flag
	beq.s .no_slide		; no slide of anim
	bclr #7,slide_flag
	bne.s .no_slide		; slide, but switch if the first file!
.end:
	rts
.no_slide:
	bsr.l try_window
	tst.b is_win
	bne.s .end				; a window is opened!!!
	tst.b switched
	bne sv_falcon
	tst.b cmd_coord		; here no switch
	beq.s .black			; no coords so black the screen
	rts						; else, nothing to do!
.black:
	cmp #16,planes
	beq.s .one
	clr vi_int				; background is 0
	move.l comp_txt,d0
	swap d0
	cmp #'CD',d0			; CDH1, CHL1, CDV1
	beq.s .ok
	swap d0
	cmp.l #'fli ',d0
	beq.s .ok
	cmp.l #'flc ',d0
	beq.s .ok
	cmp.l #'seq4',d0
	beq.s .ok
	cmp.l #'kin4',d0
	beq.s .ok
	cmp.l #'dlt4',d0
	beq.s .ok
	cmp.l #'VMAS',d0
	beq.s .ok
	cmp.l #'VFAL',d0
	beq.s .ok
	move.b #'0',d0
	cmp.l #'dl/0',d0
	beq.s .ok
	cmp.l #'flm0',d0
	beq.s .ok
.one:
	move #1,vi_int
.ok:
	GEM_VDI vsf_color
	GEM_VDI v_bar			; else, just blacks the screen
	rts
	
	
vsf_interior: dc.l vi_cont,vi_int,dum,dum,dum
vi_cont: dc.w 23,0,0,1,0,0,0,0,0,0,0,0
vi_int: dc.w 1


sv_falcon:
	tst.b _conv_video
	bne .suite
	tst.b res_switch
	bmi.s .is_falc
	beq.s .is_falc			; if 0, a Falcon in TC and an FLM anim!
	move.l comp_txt,d0
	lsr.l #8,d0
	cmp.l #'flm',d0
	beq.s .use_tt_res
	lsr.l #8,d0
	cmp #'CD',d0
	bne.s .other
.use_tt_res:
	move tt_res,-(sp)
	bra.s .tt_comm
.other:
	cmp #4,planes
	beq.s .st_low
	move #7,-(sp)			; else it's a TT, to 320x480x256
	bra.s .tt_comm
.st_low:
	clr -(sp)				; to 320x200x16 (with SEQ for example)
.tt_comm:
	moveq #-1,d0
	move.l d0,-(sp)
	move.l d0,-(sp)
	XBIOS 5,12				; setscreen
	rts
.is_falc:
	move.b conv_flag,conv_video
	beq.s .suite
	rts						; pas de changement de video si M_PLAYER pere
								; faire changement dans M_PLAYER fils
.suite:
	move.l physbase,a0
	move #9599,d1
.clear:
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	dbf d1,.clear
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
	
	lea video_reg,a0
	MOVE.L   $FFFF8282.W,(a0)+
   MOVE.L   $FFFF8286.W,(a0)+
   MOVE.L   $FFFF828A.W,(a0)+
   MOVE.L   $FFFF82A2.W,(a0)+
   MOVE.L   $FFFF82A6.W,(a0)+
   MOVE.L   $FFFF82AA.W,(a0)+
   MOVE.W   $FFFF820A.W,(a0)+
   MOVE.W   $FFFF82C0.W,(a0)+
   move.w   $FFFF8266.W,(a0)+
   MOVE.W   $FFFF8266.W,(a0)+
   MOVE.W   $FFFF82C2.W,(a0)+
   MOVE.W   $FFFF8210.W,(a0)+
	
	move old_video,d0
	and.w	#$10,d0		; vga?
	beq.s	.rgb
.vga:
	move.w #$114,d1	; true color, interlace, vga
	bra.s	.set
.rgb:
	move.w old_video,d1
	and.w	#$20,d1		; keep pal/ntsc flag
	or.w #4,d1			; true color
.set:	
	move.w d1,-(sp)
	move.w #-1,-(sp)
	move.l physbase,-(sp)
	move.l physbase,-(sp)
	XBIOS 5,12
	XBIOS 88,4
	move.l		$ffff9800.w,old_border
	clr.l		$ffff9800.w
; Monitor: VGA
; 320*240, True Colour, 60.0 Hz, 31470 Hz
	move old_video,d1
	btst #4,d1					; vga?
	beq.s .lb0
   MOVE.L   #$C6008B,$FFFF8282.W
   MOVE.L   #$1302AA,$FFFF8286.W
   MOVE.L   #$8B0097,$FFFF828A.W
   MOVE.L   #$41903FF,$FFFF82A2.W
   MOVE.L   #$3F003D,$FFFF82A6.W
   MOVE.L   #$3FD0415,$FFFF82AA.W
   MOVE.W   #$200,$FFFF820A.W
   MOVE.W   #$186,$FFFF82C0.W
   CLR.W    $FFFF8266.W
   MOVE.W   #$100,$FFFF8266.W
   MOVE.W   #$5,$FFFF82C2.W
   MOVE.W   #$140,$FFFF8210.W
   bra .end
.lb0:
	btst #5,d1				; pal?
	beq.s .lb1				; no
; Monitor: RGB/TV (PAL)
; 320*240, True Colour, 50.0 Hz, 15625 Hz
   MOVE.L   #$FE009A,$FFFF8282.W
   MOVE.L   #$5A0039,$FFFF8286.W
   MOVE.L   #$9A00D9,$FFFF828A.W
   MOVE.L   #$2710239,$FFFF82A2.W
   MOVE.L   #$590059,$FFFF82A6.W
   MOVE.L   #$239026B,$FFFF82AA.W
   MOVE.W   #$200,$FFFF820A.W
   MOVE.W   #$181,$FFFF82C0.W
   CLR.W    $FFFF8266.W
   MOVE.W   #$100,$FFFF8266.W
   MOVE.W   #$0,$FFFF82C2.W
   MOVE.W   #$140,$FFFF8210.W
	bra.s .end
.lb1:
; Monitor: RGB/TV (NTSC)
; 320*240, True Colour, 59.5 Hz, 15594 Hz
   MOVE.L   #$FE0099,$FFFF8282.W
   MOVE.L   #$590038,$FFFF8286.W
   MOVE.L   #$9900DA,$FFFF828A.W
   MOVE.L   #$20D01FB,$FFFF82A2.W
   MOVE.L   #$1B001B,$FFFF82A6.W
   MOVE.L   #$1FB0207,$FFFF82AA.W
   MOVE.W   #$200,$FFFF820A.W
   MOVE.W   #$181,$FFFF82C0.W
   CLR.W    $FFFF8266.W
   MOVE.W   #$100,$FFFF8266.W
   MOVE.W   #$0,$FFFF82C2.W
   MOVE.W   #$140,$FFFF8210.W
.end:
	btst #2,([kbshift])
	bne.s .end
	move.l stack_adr,-(sp)
	GEMDOS 32,6
	rts
	
restore_video:
	tst.b _conv_video
	bne.s .suite
	tst.b slide_flag
	bne .out
	tst.b res_switch
	bmi.s .is_falc
	beq.s .is_falc				; Falcon TC with an FLM anim
	move old_video,-(sp)		; else it's a TT
	moveq #-1,d0
	move.l d0,-(sp)
	move.l d0,-(sp)
	XBIOS 5,12
	rts
	
.is_falc:
	tst.b conv_video
	beq.s .suite
	rts						; deja fait dans M_PLAYER FILS
.suite:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
	move old_video,-(sp)
   XBIOS 88,4
	
	lea video_reg,a0
	MOVE.L   (a0)+,$FFFF8282.W
   MOVE.L   (a0)+,$FFFF8286.W
   MOVE.L   (a0)+,$FFFF828A.W
   MOVE.L   (a0)+,$FFFF82A2.W
   MOVE.L   (a0)+,$FFFF82A6.W
   MOVE.L   (a0)+,$FFFF82AA.W
   MOVE.W   (a0)+,$FFFF820A.W
   MOVE.W   (a0)+,$FFFF82C0.W
   move.w   (a0)+,$FFFF8266.W
   MOVE.W   (a0)+,$FFFF8266.W
   MOVE.W   (a0)+,$FFFF82C2.W
   MOVE.W   (a0)+,$FFFF8210.W

	move.l old_border,$ffff9800.w
   move #-1,-(sp)
	move.l old_screen,-(sp)
	move.l old_screen,-(sp)
	XBIOS 5,12
   
	move.l stack_adr,-(sp)
	GEMDOS 32,6
	move.l physbase,a2
	cmp.l old_screen,a2
	beq.s .out
	move.l physbase2,a2	; the real address (unaligned)
	bsr mfree
.out:
	rts

qt_step_mode:
	tst.l samp_sizes
	beq .out
	tst.b bad_comp			; compression supported?
	bne .out					; no, only sound!	
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
	move.l 12(a2,d0.l),compression
	moveq #-1,d7				; i for the loop
	bra .end_of_loop
.loop:
	move.l ([chunkoffs],d7.l*4),d0
	SEEK d0,0	; start of chunk data
	move.l d5,d1
	muls.l #12,d1
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
	move.l 8(a2,d0.l),depth
	move.l 12(a2,d0.l),compression	
	bra .end_of_samps
.samp_loop:
	move.l samp_sizes,a0
	move.l (a0,d6.l*4),bufused	; size used for the current sample
	cmp.l sample_num,d6	; exit if cur_samp>=sample_num
	bpl .out
	addq.l #1,d6
	movem.l d2-d7/a2-a6,-(sp)	; saves registers
	move.l buffer,-(sp)
	move.l bufused,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; fread!
	move.l compression,a0
	jsr (a0)					; decodes and displays
	movem.l (sp)+,d2-d7/a2-a6
.bug:
	bsr inc_frame
	beq.s .out				; =0 quit
	bpl.s .end_of_samps	; >0 next
	bsr save_frame			; <0 save
	bmi.s .bug
.end_of_samps:
	subq.l #1,d2
	bpl .samp_loop	
.end_of_loop:
	addq.l #1,d7			; inc i
	cmp.l chunkoff_num,d7
	bmi .loop
.out:
	rts

avi_step_mode:
	move.l sample_num,d7
	move.l chunkoffs,a6
	addq.l #4,a6
	bra .loop
.lb0:
	SEEK (a6)+,0			; good positon
	move.l buffer,-(sp)
	move.l (a6)+,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; reads the frame
	move.l (a6)+,a3		; the time
	movem.l d3/d7/a3/a6,-(sp)
	move.l compression,a0
	jsr (a0)
	movem.l (sp)+,d3/d7/a3/a6
.bug:
	bsr inc_frame
	beq.s .quit
	bpl.s .loop
	bsr save_frame
	bmi.s .bug
.loop:
	subq.l #1,d7
	bpl .lb0
.quit:
	rts
	
fli_step_mode:
	tst.b bad_comp
	beq.s .good
	st stopped
	rts
.good:
	SEEK #128,0				; start of frames
	clr.l disp_frame
	move.l sample_num,d7	; number of frames
	lea cvid_fix0,a6		; as a buffer for the palette
	cmp.l #'flh ',comp_txt
	bne.s .palette_mode
	move.l hc_cvid,a6		; with FLH, it's a 16 bits mode
.palette_mode:	
	move.l image,a5
	move.l buffer,a4
	move screenw,d3
	add d3,d3				; to skip one line
	ext.l d3
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
	bsr.l fli_lc
	bra .lb4
.lb0:
	cmp #7,d0				; flc_lc
	bne.s .lb00
	bsr.l flc_lc
	bra.s .lb4
.lb00:
	cmp #15,d0				; fli_brun
	bne.s .lb1
	bsr.l fli_brun
	bra.s .lb4
.lb1:
	cmp #11,d0				; fli_color (64)
	bne.s .lb2
	bsr.l fli_color_64
	bra.s .lb4
.lb2:
	cmp #4,d0				; flc_color (256)
	bne.s .lb20
	bsr.l fli_color_256
	bra.s .lb4
.lb20:
	cmp #13,d0				; fli_black
	bne.s .lb3
	bsr.l fli_black
	bra.s .lb4
.lb3:
	cmp #16,d0				; fli_copy
	bne.s .lb3a
	bsr.l fli_copy
	bra.s .lb4
.lb3a:
	cmp #27,d0
	bne.s .lb3b
	if REG=0
		bsr flh_delta
	else
		tst.b nova
		beq.s .lb3c
		bsr flh_delta
		bra.s .lb4
	.lb3c:
		bsr flh_delta_falc
	endif
	bra.s .lb4
.lb3b:
	cmp #25,d0
	bne.s .lb4
	if REG=0
		bsr flh_brun
	else
		tst.b nova
		beq.s .lb3d
		bsr flh_brun
		bra.s .lb4
	.lb3d:
		bsr flh_brun_falc
	endif
.lb4:
	move.l a1,a0			; unknow ID, just skip!
.ch_loop:
	dbf d6,.chunk
.bug:
	bsr inc_frame
	beq.s .exit
	bpl.s .next
	bsr save_frame
	bmi.s .bug
.next:
	dbf d7,.loop
.stop:
	st stopped
.exit:
	rts
	
ritme: dc.l 1

_prepare_chaines:
	moveq #6,d0
	move.l d0,rg_int
	GEM_AES rsrc_gaddr
	move.l tree,a2
	move.l ritme(pc),d0
	move.l 684(a2),a3
	move.l (a3),a3			; tedinfo du ritme!
	bsr .add_int
	move.l #200,d6
	move anim_type,d7
	bne.s .pas_fli
.avec_delai:
	move.l _delay,d3	; 1/200 par image
.zorglub:
	move.l d6,d4
	divs d3,d4			; key frame (1 par seconde)
	ext.l d4
	bra.s .commun	
.pas_fli:
	cmp #3,d7			; FLM VMAS
	beq.s .avec_delai
	cmp #-3,d7
	beq.s .mpeg
	cmp #1,d7
	bne.s .pas_avi
.mpeg:
	move.l avi_rate,d4
	move.l d6,d3
	divs d4,d3
	ext.l d3
	exg.l d3,d4
	bra.s .commun
.pas_avi:
	cmp #2,d7
	bne.s .pas_mov
	move.l t2samps,a0
	cmp.l #0,a0	
	beq.s .autre
	move.l t2samp_num,d2
	moveq #0,d3				; total time
	moveq #0,d4				; total frames
.lb0:
	move.l (a0)+,d0		; number of frames
	add.l d0,d4				; updates the number of frames
	muls.l (a0)+,d0		; times their duration
	add.l d0,d3				; updates the total time
	subq.l #1,d2
	bne.s .lb0				; till the end of t2_samps
	move.l qt_timescale,d1
	bne.s .go_on
	move.l #1000,d1
.go_on:
	muls.l d6,d0:d3
	divs.l d1,d0:d3		; total de 1/200 pour l'anim
	divs.l d4,d3			; 1/200 par image
	bra.s .zorglub
.pas_mov:
	cmp #-1,d7
	bne.s .pas_dl
	bra.s .avec_delai
.pas_dl:
.autre:
	moveq #25,d3
	moveq #8,d4
.commun:
	move.l tree,a2
	move.l 276(a2),a1	; tedinfo
	lea _temps(pc),a3
	move.l a3,(a1)
	move.l d3,d0
	bsr .add_int
	move.l 252(a2),a1
	lea _key(pc),a3
	move.l d4,d0
	move.l a3,(a1)
	bsr .add_int
	bclr #0,515(a2)	; ADD a sound cleared
	bset #3,539(a2)	; no save sound
	tst.b bad_sound
	bne.s .end
	tst.l sound_num
	beq.s .end
	bclr #3,539(a2)
.end:
	rts
.add_int:
	lea -1(a7),a0	
	clr.b (a0)
	moveq #10,d2
.lbx:
	divsl.l d2,d1:d0
	add.b #'0',d1
	move.b d1,-(a0)
	tst.l d0
	bne.s .lbx
	move.l (a0),(a3)
	rts	
_temps: dc.l 0
_key: dc.l 0
	even	
	
	
init_step_mode:
	move d7,anim_type		; -3=mpeg, -2=GIF, -1=DL, 0=FL?, 1=AVI, 2=MOV, 3=VMAS/VFAL
	bsr _prepare_chaines
.again:
	moveq #0,d7
	moveq #6,d6
	bsr manage_tree
	cmp #9,d6							; cancel
	bne.s .not_cancel
.cancel:
	moveq #0,d0							; EQ si cancel
	sf switched
	rts
.not_cancel:
	cmp #21,d6							; ADD a sound?
	bne.s .other
	bsr select_avr_file
	bra.s .again
.other:
	cmp #22,d6
	bne.s .other2
	bsr select_avr_file
	move.l tree,a0
	btst #0,515(a0)
	beq.s .again						; cancelled
	bsr save_avr_file
	bra.s .again
.other2:
	move.l tree,a0
	move.l 684(a0),a0
	move.l (a0),a0		; chaine ritme
	moveq #0,d0
	moveq #0,d1
.chiffre:
	move.b (a0)+,d0
	beq.s .termine
	muls #10,d1
	sub.b #'0',d0
	add d0,d1
	bra.s .chiffre
.termine:
	tst.l d1
	bne.s .ok1
	moveq #1,d1		; au moins 1, faut pas deconner!
.ok1:
	move.l d1,ritme
	clr _ritme	
	move.l sample_num,d0
	add.l d1,d0
	subq.l #1,d0
	divs.l d1,d0
	move.l d0,sample_num2
	move d6,d7
	move work_out,d1					; screenw
	addq #1,d1
	muls boxh,d1
	asl.l #2,d1							; size of one text line in pixels
	move.l d1,top_lines_size
	bsr malloc
	move.l d0,top_lines_buff
	move.l work_out,d6
	add.l #$10001,d6
	move max_imagey,d1
	cmp d6,d1
	bmi.s .w_ok
	move d6,d1
.w_ok:
	move d1,d6
	swap d6
	move max_imagex,d1
	cmp d6,d1
	bmi.s .h_ok
	move d6,d1
.h_ok:
	move d1,d6
	swap d6
	muls d6,d1
	move.l d1,d0
	add.l d1,d1
	cmp #3,d7							; TGA 24 bits?
	bne.s .16bits
	add.l d0,d1							; x 3, R G B
.16bits:
	add.l #18,d1						; TGA header
	move.l d1,tga_buff_size
	bsr malloc
	move.l d0,a0
	move.l d0,tga_buff
	move.l #$00000200,(a0)+
	clr.l (a0)+
	clr.l (a0)+
	swap d6
	ror #8,d6
	move d6,(a0)+		; W
	swap d6
	ror #8,d6
	move d6,(a0)+		; H
	cmp #3,d7			; TGA 24 bits?
	beq.s .lb3
	move #$1020,(a0)	; 16 bits
	bra.s .lb4
.lb3:
	move #$1820,(a0)	; 24 bits
.lb4:
	sf auto_save_tga
	sf auto_run_tga
	sf write_error
	clr mf_int
	GEM_AES graf_mouse				; the arrow
	GEM_VDI show_mouse
	lea fs_addrin_tga,a0
	move.l #tga_text,8(a0)
	cmp #5,d7
	bmi.s .tga_save
	st conv_flag						; avec une conversion...
	st auto_save_tga					; ...sauvegarde automatique!!!
	st auto_run_tga					; ...sans intervention humaine!
	move.l #convert_txt,8(a0)
	bra.s .pas_comp
.tga_save:
	move.l tree,a1
	btst #0,659(a1)					; bouton RLE
	sne tgac								; flag a FF si compression demandee
.pas_comp:
	move.l a0,fileselect+16	; new addrin
	GEM_AES fileselect
	move.l #fs_addrin,fileselect+16		; restores it
	move.l intout,-(sp)
	GEM_VDI hide_mouse
	move (sp)+,d0						; 0 if error
	move (sp)+,d1						; 0 if Abort, other if OK
	beq .cancel
	tst d0
	beq .cancel
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
	move.l a2,tga_file_ptr	; the name of the file
	tst.b conv_flag
	bne _prepare_bat
	move.l #'0000',(a2)+		; default name
	move.l #'0000',(a2)+
	lea -1(a2),a1				; pointer to last digit
	move.l a1,tga_digit
	move.l #'.TGA',(a2)+
	clr.b (a2)
	sub #12,a2
	lea tga_file,a1
	moveq #6,d0
.lb1:
	move.b (a1)+,d1
	beq.s .arg
	cmp.b #'*',d1
	beq.s .arg
	cmp.b #'?',d1
	beq.s .arg
	cmp.b #'.',d1
	beq.s .arg
	move.b d1,(a2)+
	dbf d0,.lb1
.arg:
	cmp.l tga_file_ptr,a2
	bne.s .ok					; at least one good byte!
.default:
	move.w #'FR',(a2)+
	move.b #'M',(a2)+
.ok:
	tst.b tgac
	beq.s .pas_comp2
	move.l tga_buff_size,d1
	bsr malloc
	move.l d0,tga10_buff
.pas_comp2:
	moveq #-1,d0
	rts

select_avr_file:
	clr mf_int
	GEM_AES graf_mouse				; the arrow
	GEM_VDI show_mouse
	move.l #fs_addrin_avr,fileselect+16	; new addrin
	GEM_AES fileselect
	move.l #fs_addrin,fileselect+16		; restores it
	move.l intout,-(sp)
	GEM_VDI hide_mouse
	move (sp)+,d0						; 0 if error
	move (sp)+,d1						; 0 if Abort, other if OK
	beq .cancel
	tst d0
	beq .cancel
	lea avr_path,a0
	lea avr_full,a1
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
	lea avr_file,a0
.lb3:
	move.b (a0)+,(a2)+	; plus le nom
	bne.s .lb3
	move.l tree,a0
	bset #0,515(a0)
	rts
.cancel:
	move.l tree,a0
	bclr #0,515(a0)
	rts

save_avr_file:
	clr -(sp)
	pea avr_full
	GEMDOS 60,8				; fcreate
	move d0,mov_h2
	bpl.s .ok
.gloub:
	rts
.ok:
	move.l #128,d4
	move.l snd_temp_size,d3
	cmp.l d4,d3
	bpl.s .enough
	move.l d4,d3
.enough:
	pea avr_full
	move.l d4,-(sp)		; 128 dummy for header
	move mov_h2,-(sp)
	GEMDOS 64,12
	cmp.l d4,d0
	bne.s .gloub
	move.l tree,-(sp)
	cmp #1,anim_type
	beq.s .avi_sound
	bsr init_sound			; sinon MOV
	bra.s .loaded
.avi_sound:
	bsr adapt_d4_size		; only for D3!!!
	bsr read_sound
.loaded:
	move.l (sp)+,tree
	move mov_h2,d7
	move #2,-(sp)
	move d7,-(sp)
	clr.l -(sp)
	GEMDOS 66,10
	move.l d0,d6			; taille du fichier
	move.l #128,d5
	sub.l d5,d6				; taille son
	move.l snd_temp,a3	; buffer
	clr -(sp)
	move d7,-(sp)
	clr.l -(sp)
	GEMDOS 66,10			; debut du fichier
	move.l a3,a0
	move.l #'2BIT',(a0)+
	move.l #'M_PL',(a0)+
	move.l #'AYER',(a0)+
	move channels,d2
	cmp #2,d2
	seq d0
	ext.w d0
	move d0,(a0)+
	move sound_bits,d3
	move d3,(a0)+
	move #$FFFF,d0				; signed
	cmp #16,d3
	beq.s .signe
	cmp.l #'twos',s_signe
	beq.s .signe
	moveq #0,d0					; cas 8 bits AVI ou raw MOV	
.signe:	
	move d0,(a0)+				; signed ou non
	lsl d2,d3				; 16 (m8), 32 (m16, s8) 64 (s16)
	lsr #5,d3
	lsr.l d3,d6				; nombre de samples
	clr (a0)+
	st (a0)+
	st (a0)+
	move.l _freq_sav,d0
	move.l d0,(a0)
	st (a0)
	addq.l #4,a0
	move.l d6,(a0)+
	clr.l (a0)+
	move.l d6,(a0)+
	moveq #44,d0
.del_header:
	clr (a0)+
	dbf d0,.del_header
	move.l a3,-(sp)	
	move.l d5,-(sp)
	move d7,-(sp)
	GEMDOS 64,12
	move d7,-(sp)
	GEMDOS 62,4
	clr mov_h2
	move.l snd_temp,a2
	bsr mfree
	move.l tree,a0
	bset #3,539(a0)	; disable seconde sauvegarde
	rts
	
	
_prepare_bat:
	cmp #-2,anim_type		; un GIF?
	bne.s .pas_gif
	tst.l sample_num		; le nombre d'images est connu?
	bne.s .pas_gif			; oui, pas de traitement … part
	bsr _count_gif_frames
	move.l ritme(pc),d1
	move.l sample_num,d0
	add.l d1,d0
	subq.l #1,d0
	divs.l d1,d0
	move.l d0,sample_num2
.pas_gif:
	move d7,d6
	subq #7,d6				; -1=mov 16, 0=mov 8, 1=avi 8
	move.l tga_buff,a3
	add #18,a3
	move.l #'m_pl',(a3)+
	move.l #'ayer',(a3)+
	move #$0d0a,d7
	move d7,(a3)+
	move #'o=',(a3)+
	cmp #1,d6
	bne.s .pas_avi
	move.b #'#',(a3)+
.pas_avi:
	clr.b (a2)
	lea tga_full,a1
.lb0:
	move.b (a1)+,(a3)+
	bne.s .lb0
	subq.l #1,a3
	lea tga_file,a0
.lb1:
	move.b (a0)+,(a3)+
	bne.s .lb1
	subq.l #1,a3
	move d7,(a3)+
	move.l #'_TEM',(a2)+
	move.l #'P.BA',(a2)+
	move.w #$5400,(a2)
	tst d6
	bmi.s .tga
	move.l #'c=xi',(a3)+
	move #'mg',(a3)+
	bra.s .toto
.tga:
	move.l #'c=tg',(a3)+
	move #'a2',(a3)+
.toto:
	move d7,(a3)+
	move #'w=',(a3)+
	moveq #0,d0
	move max_imagex,d0
	move d0,d4
	bsr .add_int
	move d7,(a3)+
	move #'h=',(a3)+
	moveq #0,d0
	move max_imagey,d0
	muls d0,d4
	bsr .add_int
	move d7,(a3)+
	add.l d4,d4
	moveq #18,d0
	add.l d4,d0
	move #'b=',(a3)+
	bsr .add_int
	move d7,(a3)+
	move.l sample_num2,d4
	move #'f=',(a3)+
	move.l d4,d0
	bsr .add_int
	move d7,(a3)+
	move.l tree,a0
	btst #0,515(a0)
	beq.s .pas_avr
	move #'s=',(a3)+
	lea avr_full,a0
	bsr .add_str
	move d7,(a3)+
	bra.s .pas_t	
.pas_avr:
	lea _temps(pc),a0
	tst.b (a0)
	beq.s .pas_t
	move #'t=',(a3)+
	bsr .add_str
	move d7,(a3)+
.pas_t:
	lea _key(pc),a0
	tst.b (a0)
	beq.s .pas_k
	move #'k=',(a3)+
	bsr .add_str
	move d7,(a3)+
.pas_k:
	move.l tree,a0
	move.b #'1',d0
	lea 371(a0),a0		; selected da qualite
.again:
	btst #0,(a0)
	bne.s .qual
	add.w #24,a0
	addq.b #1,d0
	bra.s .again
.qual:
	if REG=0
		tst d1
		bpl.s .titi
	endif
	move #'q=',(a3)+
	move.b d0,(a3)+
	move d7,(a3)+
	if REG=0
.titi:
	endif
	move #'m=',(a3)+
	lea _dialogue,a0
	move.l a0,d0
	move.l #ma_routine,(a0)+
	addq.l #8,a0
	clr (a0)			; flag=0 (pas d'extension)
	move.l tree,a1
	btst #0,611(a1)
	bne.s .pas_zoom
	move #'EX',(a0)+	; flag=EX, extension pr‚sente
	btst #0,587(a1)
	bne.s .zoom2
	move #$0102,(a0)+
	bra.s .pas_zoom
.zoom2:
	move #$0201,(a0)+
.pas_zoom:
	bsr .add_int
	move d7,(a3)+
	lea .dat(pc),a0
	bsr .add_str
	subq.l #1,d4
	beq.s .terminus
	lea .aumoins2(pc),a0
	bsr .add_str
	move.l d4,d0
	bsr .add_int
	lea .fin(pc),a0
	bsr .add_str
.terminus:
	lea .stop(pc),a0
	bsr .add_str
	clr -(sp)
	pea tga_full
	GEMDOS 60,8
	move d0,d7
	bmi .gloub
	move.l tga_buff,a0
	add #18,a0
	move.l a0,-(sp)
	sub.l a0,a3
	move.l a3,-(sp)
	move d7,-(sp)
	GEMDOS 64,12
	tst.l d0
	bmi.s .gloub
	move d7,-(sp)
	GEMDOS 62,4
.ok:
	moveq #-1,d0
	rts
.gloub:
	moveq #0,d0
	rts	
.add_int:
	lea 16(a3),a0
	clr.b (a0)
	moveq #10,d2
.lbx:
	divsl.l d2,d1:d0
	add.b #'0',d1
	move.b d1,-(a0)
	tst.l d0
	bne.s .lbx
.add_str:
	move.b (a0)+,(a3)+
	bne.s .add_str
	subq.l #1,a3
	rts	

.dat: dc.b "data",13,10,"F0000000.TGA",13,10,0
.aumoins2: dc.b ".rept ",0
.fin: dc.b 13,10,".incr",13,10,".disp",13,10,".endr",13,10,0
.stop: dc.b ".stop",13,10,0
	even	

_run_m_player:
	tst.b conv_flag
	bne.s .ok
	rts
.ok:
	lea _name,a0
	if REG=1
		move.l #'M_PL',(a0)+
		move.l #'AYER',(a0)+
	else
		move.l #'MPLY',(a0)+
		move.l #'R_SW',(a0)+
	endif
	move.l #'.PRG',(a0)+
	clr.b (a0)
	GEM_AES shel_find
	lea tga_full,a0
	move.l tga_buff,a1
	add #18,a1 		; command line
	lea 1(a1),a2
	move.b #"-",(a2)+
	move.l #'d+a+',(a2)+
	move #'e ',(a2)+
	tst.b conv_video
	beq.s .copy_cmd
	move.b #'+',-1(a2)
	move #'v ',(a2)+	; changer de RES Falcon dans M_Player fils
.copy_cmd:
	move.b (a0)+,(a2)+
	bne.s .copy_cmd
	lea -1(a2),a0		; final 0
	subq.l #2,a2
	sub.l a1,a2
	move a2,d0
	move.b d0,(a1)		; size of command line
	move.l a7,conv1_stack
	move.l a0,-(sp)	; envir
	move.l a1,-(sp)	; cmd
	pea _name
	clr -(sp)			; load and go
	GEMDOS 75,16
	move.l conv1_stack,a7
	tst.l d0
	bpl.s .suite
	subq.l #8,a7
	move.l #_defaut_name,-(sp)
	clr -(sp)
	GEMDOS 75,16
	move.l conv1_stack,a7
	tst.l d0
	bpl.s .suite
	neg.l d0
	sub #31,d0			; TOS code
	move d0,fe_int
	GEM_AES form_error
;	lea .zut(pc),a0
;	bra ooops
.suite:
	addq.l #4,sp
	st stopped
	bra.l end_of_display
.zut: dc.b "[1][Can't find | "
	if REG=1
		dc.b "M_PLAYER"
	else
		dc.b "MPLYR_SW"
	endif
	dc.b ".PRG !!][Ooops!]",0
_defaut_name: dc.b "F:\ANIM\M_PLAYER\M_PLAYER.PRG",0
	even

ma_routine:
	move.l a7,hote_stack
	move.l conv1_stack,a7
	move.l (a7),d0
	lea -512(a7),a7		; ben oui! pour pr‚server la pile d'appel de PEXEC
	move.l d0,-(a7)
	rts

form_error: dc.l fe_cont,global,fe_int,dum,dum,dum
fe_cont: dc.w 53,1,1,0,0
fe_int: dc.w 0

_ritme: dc.w 0

inc_frame:
	subq #1,_ritme
	bmi.s .la_bonne	
	moveq #1,d0
	rts						; renvoit ni EQ ni <0, sauter image
.la_bonne:
	move.l ritme,d0
	subq #1,d0
	move d0,_ritme
	tst.b conv_flag		; a conversion????
	beq.s .eq
	moveq #-1,d0
	rts
.eq:
	movem.l d0-d2/a0-a2,-(sp)
	tst.b write_error
	bne.s save_error
	move.l top_lines_buff,a0
;	move.l $44e.w,a1
	move.l physbase,a1
;
	move.l top_lines_size,d0
.cpy_lines:
	move.l (a1)+,(a0)+
	subq.l #4,d0
	bne.s .cpy_lines
	move.l tga_digit,a0
.lb0:
	move.b (a0),d0
	addq.b #1,d0
	cmp.b #'9'+1,d0
	bmi.s .good
	move.b #'0',(a0)
	subq.l #1,a0
	bra.s .lb0
.good:
	move.b d0,(a0)
save_error:					; comes back here when error (no inc frame)
	sf write_error
	lea step_home,a0
	bsr print
	move.l tga_file_ptr,a0
	bsr print
	btst #2,([kbshift])
	beq.s .no_stop
	sf auto_save_tga
	sf auto_run_tga
.no_stop:
	tst.w auto_save_tga		; and auto_run_tga! (.b + .b)
	bne.s .contrl_txt
	lea step_text,a0
	bra.s .lb1
.contrl_txt:
	lea control_text,a0
.lb1:
	bsr print
	XBIOS 37,2
	XBIOS 37,2				; 2 vsync to read the line!
	tst.w auto_save_tga	; and auto_run_tga
	bne.s .no_key
	move.l #$20002,-(sp)
	trap #13
	addq.l #4,sp
.no_key:
	move.l top_lines_buff,a0
;	move.l $44e.w,a1
	move.l physbase,a1
;
	move.l top_lines_size,d1
.rst_lines:
	move.l (a0)+,(a1)+
	subq.l #4,d1
	bne.s .rst_lines
	tst.b auto_save_tga
	bne.s .mi
	tst.b auto_run_tga
	bne.s .pl
	cmp.b #27,d0
	beq.s .eq
	or.b #$20,d0
	cmp.b #'q',d0
	beq.s .eq
	cmp.b #'s',d0
	beq.s .mi
	cmp.b #'a',d0
	beq.s .auto
	cmp.b #'r',d0
	beq.s .run
.pl:
	moveq #1,d0			; 'next' returns>0
.quit:
	movem.l (sp)+,d0-d2/a0-a2
	rts
.auto:
	st auto_save_tga
.mi:
	moveq #-1,d0		; 'save' returns <0
	bra.s .quit
.eq:
	moveq #0,d0			; 'quit' returns =0
	bra.s .quit
.run:
	st auto_run_tga
	bra.s .pl
	
save_frame:
	movem.l d0-d5/a0-a2,-(sp)
	move.l tga_buff,a0
	move 12(a0),d0
	ror #8,d0			; W
	move 14(a0),d1
	ror #8,d1			; H
	lea 16(a0),a0		; bits per pixel
	move.l image,a1	; same but in memory
	move screenw,d3
	sub d0,d3
	add d3,d3			; row_inc
	subq #1,d1			; for the loop
	subq #1,d0
	cmp #$1820,(a0)+
	beq.s .24bits
	bsr _save_tga16
	bra .next	
.24bits:
	tst.b is_65k
	bne.s .falcon
	tst.b nova
	beq.s .falcon
.line:
	move d0,d2			; W
.pixel:
	move.w (a1)+,d4	; one pixel
	ror #5,d4
	move.b d4,d5
	and.b #$f8,d5
	move.b d5,(a0)+	; blue
	ror #5,d4
	move.b d4,d5
	and.b #$f8,d5
	move.b d5,(a0)+	; green
	ror #5,d4
	and.b #$f8,d4
	move.b d4,(a0)+	; red
	dbf d2,.pixel
	add d3,a1
	dbf d1,.line
	bra.s .next
.falcon:
.line2:
	move d0,d2			; W
.pixel2:
	move.w (a1)+,d4	; one pixel
	tst.b is_65k
	beq.s .noswp
	swap d4
.noswp:
	rol #3,d4
	move.b d4,d5
	and.b #$f8,d5
	move.b d5,(a0)+	; blue
	ror #6,d4
	move.b d4,d5
	and.b #$f8,d5
	move.b d5,(a0)+	; green
	ror #5,d4
	and.b #$f8,d4
	move.b d4,(a0)+	; red
	dbf d2,.pixel2
	add d3,a1
	dbf d1,.line2
.next:
	tst.b conv_flag
	bne .m_player	
	clr -(sp)
	pea tga_full
	GEMDOS 60,8			; fcreate
	move.l d0,d3
	bmi.s .bug
	tst.b tgac
	beq.s .normal
	bsr _sauve_tga10
	beq.s .normal		; compression n'a pas marche!
	move.l tga10_buff,-(sp)
	bra.s .common
.normal:
	move.l tga_buff,-(sp)
	move.l tga_buff_size,d4
.common:
	move.l d4,-(sp)
	move d3,-(sp)
	GEMDOS 64,12
	move.l d0,d5		; size written
	bmi.s .bug
	move d3,-(sp)
	GEMDOS 62,4
	tst.l d0
	bmi.s .bug
	cmp.l d4,d5
	bne.s .bug
	moveq #0,d0			; 0 = Ok
	bra.s .quit
.bug:
	move #7,-(sp)		; bell
	move #2,-(sp)		; console
	BIOS 3,6				; rings a bell
	sf auto_save_tga	; if it was set!
	st write_error
	moveq #-1,d0	
.quit:
	movem.l (sp)+,d0-d5/a0-a2
	rts
.m_player:
	lea _dialogue,a0
	lea .retour(pc),a1
	move.l a1,(a0)+
	addq.l #4,a0
	move.l tga_buff,a1
	add #18,a1
	move.l a1,(a0)+
	clr (a0)+			; toujours en 15 bits NOVA
	movem.l d6-d7/a3-a6,-(sp)
;	move.l stack_adr,-(sp)
;	GEMDOS 32,6			; retour en utilisateur
	move.l a7,conv_stack
	move.l hote_stack,a7
	rts
.retour:
	move.l a7,hote_stack	
	move.l conv_stack,a7
;	clr.l -(sp)
;	GEMDOS 32,6
;	move.l d0,stack_adr
	movem.l (sp)+,d6-d7/a3-a6
	bra .quit

_save_tga16:
	tst.b is_65k
	bne.s .nova65
	tst.b nova
	beq.s .falcon
.line:
	move d0,d2			; W
.pixel:
	move.w (a1)+,(a0)+
	dbf d2,.pixel
	add d3,a1
	dbf d1,.line
	rts
.falcon:
.line2:
	move d0,d2			; W
.pixel2:
	move.w (a1)+,d4	; one pixel
	NOVA16 d4
	ror #8,d4
	move d4,(a0)+	; red
	dbf d2,.pixel2
	add d3,a1
	dbf d1,.line2
	rts
.nova65:
.line3:
	move d0,d2			; W
.pixel3:
	move.w (a1)+,d4	; one pixel
	ror #8,d4
	NOVA16 d4
	ror #8,d4
	move d4,(a0)+	; red
	dbf d2,.pixel3
	add d3,a1
	dbf d1,.line3
	rts

_sauve_tga10:
	move.l tga_buff,a0
	move.l tga10_buff,a1
	move (a0)+,(a1)+
	move (a0)+,d0
	move.b #10,(a1)+
	move.b d0,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move (a0)+,d0
	move d0,(a1)+			; X
	ror #8,d0
	move (a0)+,d4
	move d4,(a1)+
	ror #8,d4				; Y
	muls d0,d4				; nombre de pixels
	move (a0)+,d0
	move d0,(a1)+
	cmp #$1820,d0
	beq _tga10_24			; 24 bits!
	move.l d4,d5			; compte les pixels lus dans buff
	add.l d4,d4				; compte les octets utilisables dans buff2	
	subq.l #1,d4
	move (a0)+,d0			; valeur courante
	subq.l #1,d5
.fin_egal:
	move.l a1,a2
	sf (a1)+					; nouveau code = 0
	subq.l #1,d4
	bmi.s .comp_inefficace
.autre:
	move d0,(a1)+			; qu'on range
	subq.l #2,d4
	bmi.s .comp_inefficace
	subq.l #1,d5
	bmi.s .fin	
	move (a0)+,d1			; pixel suppl‚mentaire
	cmp d1,d0
	beq.s .egal
	move d1,d0
	addq.b #1,(a2)
	bpl.s .autre			; si >0, moins de 128
	subq.b #1,(a2)			; retour a $00 + 127
	bra.s .fin_egal
.egal:
	tst.b (a2)
	beq.s .good
	subq.l #2,a1
	subq.b #1,(a2)
	move.l a1,a2
	sf (a1)+
	move d1,(a1)+
	subq.l #1,d4			; #1 car A1-2 puis +1 +2
	bmi.s .comp_inefficace	
.good:
	move.b #$81,(a2)
.encore:
	subq.l #1,d5
	bmi.s .fin
	move (a0)+,d0
	cmp d1,d0
	bne.s .fin_egal
	addq.b #1,(a2)
	bmi.s .encore			; si toujours<0, moins de 128
	st (a2)					; retour a $80 + 127
	bra.s .fin_egal		; le 129eme ne commence pas forcement un bloc repeat
.comp_inefficace:
	moveq #0,d4
	rts
.fin:
	move.l a1,d4
	sub.l tga10_buff,d4	; taille a sauver
	rts
_tga10_24:
	move.l d4,d5			; compte les pixels lus dans buff
	add.l d4,d4
	add.l d5,d4				; compte les octets utilisables dans buff2	
	subq.l #1,d4
	move.l #$FFFFFF00,d2
	move.l (a0),d0			; valeur courante
	and.l d2,d0
	addq.l #3,a0
	subq.l #1,d5
.fin_egal:
	move.l a1,a2
	sf (a1)+					; nouveau code = 0
	subq.l #1,d4
	bmi.s .comp_inefficace
.autre:
	move.l d0,(a1)			; qu'on range
	addq.l #3,a1
	subq.l #3,d4
	bmi.s .comp_inefficace
	subq.l #1,d5
	bmi.s .fin	
	move.l (a0),d1			; pixel suppl‚mentaire
	addq.l #3,a0
	and.l d2,d1
	cmp.l d1,d0
	beq.s .egal
	move.l d1,d0
	addq.b #1,(a2)
	bpl.s .autre			; si >0, moins de 128
	subq.b #1,(a2)			; retour a $00 + 127
	bra.s .fin_egal
.egal:
	tst.b (a2)
	beq.s .good
	subq.l #3,a1
	subq.b #1,(a2)
	move.l a1,a2
	sf (a1)+
	move.l d1,(a1)
	addq.l #3,a1
	subq.l #1,d4			; #1 car A1-3 puis +1 +3
	bmi.s .comp_inefficace	
.good:
	move.b #$81,(a2)
.encore:
	subq.l #1,d5
	bmi.s .fin
	move.l (a0),d0
	addq.l #3,a0
	and.l d2,d0
	cmp.l d1,d0
	bne.s .fin_egal
	addq.b #1,(a2)
	bmi.s .encore			; si toujours<0, moins de 128
	st (a2)					; retour a $80 + 127
	bra.s .fin_egal		; le 129eme ne commence pas forcement un bloc repeat
.comp_inefficace:
	moveq #0,d4
	rts
.fin:
	move.l a1,d4
	sub.l tga10_buff,d4	; taille a sauver
	rts
	
; print_ptr is the relative screen pointer)
; a0 contains the string to display (nul terminated)

print:
	tst.b switched				; res change on a Falcon?
	bne.s .my_print			; yes, don't use system routines
	move.l a0,-(sp)			; else, normal print
	GEMDOS 9,6
	rts
.my_print:
	cmp.l #step_home,a0		; is it just 'Home'
	bne.s .lb0
	clr.l print_ptr			; yes, so clear our pointer
	rts
.lb0:
	move.l print_ptr,a1		; else, write into video Ram
	add.l $44e.w,a1
	move screenw,d2
	subq #8,d2
	add d2,d2
.loop:
	move.b (a0)+,d0
	beq.s .end
	ext.w d0
	bmi.s .loop				; more than 127, not supported char
	sub.w #32,d0
	bmi.s .loop				; under 32, not supported
	lea (fonte,pc,d0.w*8),a2	; the datas for this char
	moveq #7,d0
	move.l a1,-(sp)
.line:
	swap d0
	move #7,d0
	move.b (a2)+,d1
.pix:
	spl (a1)+
	spl (a1)+
	subq #1,d0
	bmi.s .lb1
	lsl.b #1,d1
	bra.s .pix
.lb1:
	add d2,a1
	swap d0
	dbf d0,.line
	move.l (sp)+,a1
	lea 16(a1),a1
	bra.s .loop
.end:
	sub.l $44e.w,a1
	move.l a1,print_ptr
	rts
	
fonte: INCBIN "FONTE.BIN"

debug:
	movem.l d0-d2/a0-a2,-(sp)
	move.l #$20007,-(sp)
	BIOS 3,6
	move.l #$20002,-(sp)
	trap #13
	addq.l #4,sp
	movem.l (sp)+,d0-d2/a0-a2
	rts

slide_read_header:
	or.l d7,d1
	cmp.l #'eani',d1
	beq.s .ok
.error:
	moveq #1,d0
	rts
.ok:
	move.l total,d1
	add.l #1024,d1		; 256 loops!!!
	bsr malloc
	move.l d0,a5
	move.l d0,slide_zone
	lea 1024(a5),a5	; start of file and end of stack
	move.l a5,slide_ptr
	move.l a5,slide_stack
	move.l a5,-(sp)
	move.l total,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12		; read the whole bat
	move mov_h,-(sp)
	GEMDOS 62,4			; close
	st slide_flag		; a slide of anim
	lea slide_save_flags,a1
	move command,(a1)+
	st command
	lea cmd_dial,a0
	move.l (a0),(a1)+
	move.l #$00FFFF00,(a0)+
	move.l (a0),(a1)+
	clr.l (a0)+
	move #1,wu_int
	GEM_AES wind_update
	
slide_next_file:
	move.l slide_ptr,a5
	move.l slide_stack,a6
.loop:
	bsr bat_next_line
	cmp.b #'.',d0			; a command?
	beq.s .comm
	bsr slide_new_file	
	bra .display
.comm:
	addq.l #1,a5
	move.l (a5)+,d0
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
	move.l slide_digit,a0
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
	move.l slide_digit,a0
.lb2:
	move.b (a0),d0
	subq.b #1,d0
	cmp.b #'0',d0
	bpl.s .good
	move.b #'9',(a0)
	subq.l #1,a0
	bra.s .lb2
.c4:
	cmp.l #'stop',d0
	beq .exit
	bra .exit				; unknown command!
.display:
	move.l a6,slide_stack
	move.l a5,slide_ptr
	bra.l verify
.exit:
	sf slide_flag
	lea slide_save_flags,a1
	move (a1)+,command
	lea cmd_dial,a0
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l slide_zone,a2
	bsr mfree
	move #0,wu_int
	GEM_AES wind_update
	bra.l end_of_display	
	
bat_read_header:
	sf create_mov
	sf create_avi
	sf slide_gif
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
	cmp.l #'slid',d0
	beq slide_read_header
.error:
	moveq #-1,d0
	rts
.half_ok:
	or.l d7,d1
	cmp.l #'ayer',d1
	bne.s .error
	move.l #12480,d1
	bsr malloc
	move.l d0,a5
	move.l d0,bat_text
	move.l a5,-(sp)
	move.l total,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12		; read the whole bat
	move.l d0,total
	bmi.s .error
	clr.b (a5,d0.l)		; end of file marked with a 0
	move mov_h,-(sp)
	GEMDOS 62,4			; close
	moveq #0,d6				; bit map of every option found
.parse_header:
	bsr bat_next_line
	or.b d7,d0			; to lower
	cmp.b #'=',1(a5)
	bne .end_head
	addq.l #2,a5			; skips X= (X beeing w,h,r,f,c,o,v)
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
	move.l d0,a0
	add.w #12,a0
	cmp #"EX",(a0)+
	bne.s .pas_zoom
	moveq #0,d0
	cmp #$0101,(a0)
	beq.s .trouve
	moveq #1,d0
	cmp #$0201,(a0)
	beq.s .trouve
	moveq #-1,d0
	cmp #$0102,(a0)
	beq.s .trouve
	bra.s .pas_zoom	
.trouve:
	move.b d0,conv_zoom
.pas_zoom:
	st mountain
	bra .parse_header
.h11:
	cmp.b #'c',d0
	bne .error
	move planes,planes_sav
	tst.b res_switch
	beq.s .c3
	move #16,planes
.c3:
	move.l (a5)+,d0		; compression (4 char)
	or.l d7,d0
	move.l d0,comp_txt
	cmp.l #'ximg',d0
	bne.s .c4
	move.l #bat_ximg_256,d0
	move.l d0,comp_create
	st qt_palette
	tst.b is_tt
	bne .c1
	cmp #8,planes
	beq .c1
	move.l #bat_ximg,d0
	bra .c1
.c4:
	cmp.l #'tga2',d0
	bne.s .c5
	move.l #bat_tga,comp_create
	move.l #bat_tga_256,d0
	tst.b is_tt
	bne .c1
	cmp #8,planes
	beq .c1
	move.l #bat_tga,d0
	tst.b nova
	bne .c1
	move.l #bat_tga_falc,d0
	bra .c1
.c5:
	cmp.l #'tgac',d0
	bne.s .c5c
	st tgac
	move.b #'2',d0
	move.l d0,comp_txt
	bra.s .c4
.c5c:
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
	move planes_sav,planes
	bra .parse_header
.end_head:
	move max_imagex,d0
	move max_imagey,d1
	move d0,conv_x
	move d1,conv_y
	moveq #-18,d2
	add.l max_fsize,d2
	tst.b conv_zoom
	beq.s .no_zoom
	bmi.s .reduc
	add d0,d0
	add d1,d1
	add.l d2,d2	
	add.l d2,d2		; 4 fois plus de points
	bra.s .commun
.reduc:
	lsr #1,d0
	lsr #1,d1
	lsr.l #2,d2		; 4 fois moins de points
.commun:
	move d0,max_imagex
	move d1,max_imagey
	moveq #18,d1
	add.l d2,d1
	move.l d1,max_fsize
.no_zoom:
	cmp.l #bat_tga,comp_create
	bne.s .lb0
	move max_imagex,d0
	addq #3,d0
	and.b #$FC,d0
	move d0,max_imagex	
.lb0:
	cmp.l #bat_ximg_256,comp_create
	bne.s .lb1
	tst.b mountain
	beq.s .lb00				; BAT normal, garder buffer
	tst.b conv_zoom
	bne.s .lb00				; avec ZOOM garder buffer TGA
	move.l #256,max_fsize	; sinon, buffer DUMMY
.lb00:
	move max_imagex,d0
	move d0,_vanel_line
	move d0,d1
	addq #7,d1
	and.b #$F8,d1
	move d1,max_imagex
	sub d0,d1
	move d1,_vanel_plus
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
	move -2(a0,d0.w*2),quality	
	move.l (a5)+,d0
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
	tst tgac						; compression?
	beq.s .no_comp
	move max_imagex,d0
	muls max_imagey,d0
	move.l d0,d1
	add.l d0,d1
	add.l d0,d1					; *3
	moveq #18,d0
	add.l d0,d1					; + header
	move.l d1,tgac_offset
.no_comp:	
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


decomp_tga10:
	movem.l d0-d5/a0-a2,-(sp)
	move.l buffer,a2
	move.l a2,a0
	add.l tgac_offset,a2
	cmp.b #10,2(a2)			; c'est du 10?
	bne .pas_comp
	move.b #2,2(a2)			; tga 10 en tga 2
	move.l a2,a1
	move 14(a2),d5				; max_imagey
	ror #8,d5
	move 12(a2),d4				; max_imagex
	ror #8,d4
	muls d5,d4
	move.b 16(a2),d1
	moveq #0,d0
	move.b (a2),d0
	lea 18(a2,d0.w),a2
.copy_head:
	move.b (a1)+,(a0)+
	cmp.l a2,a1
	bmi.s .copy_head
	cmp.b #24,d1
	bne .other_bits
.boukl:
	moveq #0,d0
	move.b (a2)+,d0
	bmi.s .pak
	sub.l d0,d4
.norm:
	move.b (a2)+,(a0)+
	move.b (a2)+,(a0)+
	move.b (a2)+,(a0)+
	dbf d0,.norm
.test:
	subq.l #1,d4
	bgt.s .boukl
	movem.l (sp)+,d0-d5/a0-a2
	rts
.pak:
	move.l (a2),d1
	addq.l #3,a2
	bclr #7,d0
	sub.l d0,d4
.pak2:
	move.l d1,(a0)
	addq.l #3,a0
	dbf d0,.pak2
	bra.s .test
.other_bits:
	moveq #0,d0
	move.b (a2)+,d0
	bmi.s .pak16
	sub.l d0,d4
.norm16:
	move (a2)+,(a0)+
	dbf d0,.norm16
.test16:
	subq.l #1,d4
	bgt.s .other_bits
	movem.l (sp)+,d0-d5/a0-a2
	rts
.pak16:
	move (a2)+,d1
	bclr #7,d0
	sub.l d0,d4
.pak216:
	move d1,(a0)+
	dbf d0,.pak216
	bra.s .test16
.pas_comp:
	move.l max_fsize,d0
.cpypk:
	move.l (a2)+,(a0)+
	subq.l #4,d0
	bpl.s .cpypk
	movem.l (sp)+,d0-d5/a0-a2
	rts	
	
bat_read_data:
	tst.b bad_comp
	beq.s .ok
	rts
.ok:
	tst.b mountain
	bne.s .no_time
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
	move.l $4ba.w,start_time
	move.l $4ba.w,current_time
	bra.s .no_mountain
.no_time:
	GEM_VDI hide_mouse
.no_mountain:
	move.l bat_ptr,a5		; bat pointer
	lea cvid_fix1,a6		; stack pointer for loops
	clr.l disp_frame
	sf bat_getp
.loop:
	btst #2,([kbshift])
	bne .exit
	bsr bat_next_line
	cmp.b #'.',d0			; a command?
	beq.s .comm
	bsr bat_new_file	
	bra .display
.comm:
	addq.l #1,a5
	move.l (a5)+,d0
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
	move.l buffer,d0
	add.l tgac_offset,d0
	move.l d0,-(sp)
	move.l max_fsize,-(sp)
	move d6,-(sp)
	GEMDOS 63,12			; fread
	move.l d0,d5
	move d6,-(sp)
	GEMDOS 62,4				; fclose
	tst.l d5
	bmi .loop
	beq .loop
	tst.b tgac
	beq.s .common
	bsr decomp_tga10
.common:
	addq.l #1,disp_frame
	tst.b mountain
	bne.s .no_time2
	move.l current_time,d0
.delay:
	cmp.l $4ba.w,d0
	bpl.s .delay
	add.l _delay,d0
	move.l d0,current_time
.no_time2:
	move.l compression,a0
	movem.l a5-a6,-(sp)
	jsr (a0)
	movem.l (sp)+,a5-a6
	sf bat_getp
	sf key_frame
	bra .loop
.exit:
	tst.b mountain
	bne.s .no_time3
	move.l $4ba.w,end_time
	move.l stack_adr,-(sp)
	GEMDOS 32,6
	rts
.no_time3:
	st stopped
	rts

; vanel_adr: LONG sa routine
;				LONG le numero d'image que je demande
;				LONG l'adress ou il a ses pixels WORDS
;				WORD $FFFF si 16 bits Falcon, $0000 si 15 bits NOVA

.mountain_image:
	move.l a7,conv_stack
	move.l vanel_adr,a0
	move.l (a0)+,a3			; routine
	move.l disp_frame,(a0)	; image needed
;	move.l stack_adr,-(sp)
;	GEMDOS 32,6
	movem.l a5-a6,-(sp)
	jsr (a3)
	movem.l (sp)+,a5-a6
;	clr.l -(sp)
;	GEMDOS 32,6
;	move.l d0,stack_adr
	move.l conv_stack,a7
	cmp.l #'tga2',comp_txt
	beq.s .true_color
	tst.b conv_zoom			; y a t-il du zoom?
	bne.s .true_color			; ben oui!!!
	rts							; sinon, rien! (dithering after!!!)
.true_color:
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
	move.l 8(a0),a2			; ses pixels
	tst.b conv_zoom
	bne.s _zoom_2
	muls d0,d1					; nombre de pixels
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
	ror #8,d0
	move d0,(a1)+
	subq.l #1,d1
	bne.s .copy_falc
	rts
	
_zoom_2:
	cmp.l #'tga2',comp_txt
	beq.s .true_color	
	sub.w #18,a1				; pas de header pour du 256 couleurs
	move.l a1,8(a0)			; ses pixels deviennent les miens!
.true_color:
	tst.b conv_zoom
	bmi _zoom_reduc
	move d0,d2
	add d2,d2
	move d1,d3
	lsr d3						; 2 lignes trait‚es a la fois
	move 12(a0),d0				; flag
	beq.s .copy_nova
	cmp #$FFFF,d0
	beq.s .copy_falc
	rts							; mauvais flag, on s'en fout
.copy_nova:
	bra.s .boucle
.ligne:
	move.w (a2)+,d0
	move d0,0(a1,d2)
	move d0,(a1)+
	move d0,0(a1,d2)
	move d0,(a1)+
	dbf d1,.ligne
	add d2,a1
.boucle:
	move d2,d1
	lsr #2,d1
	subq #1,d1
	dbf d3,.ligne
	rts
.copy_falc:
	bra.s .fboucle
.fligne:
	move.w (a2)+,d0
	NOVA16 d0
	ror #8,d0
	move d0,0(a1,d2)
	move d0,(a1)+
	move d0,0(a1,d2)
	move d0,(a1)+
	dbf d1,.fligne
	add d2,a1
.fboucle:
	move d2,d1
	lsr #2,d1
	subq #1,d1
	dbf d3,.fligne
	rts
	
_zoom_reduc:
	move conv_x,d2
	addq #1,d2
	bclr #0,d2
	add d2,d2
	move d1,d3
	move 12(a0),d0				; flag
	beq.s .copy_nova
	cmp #$FFFF,d0
	beq.s .copy_falc
	rts							; mauvais flag, on s'en fout
.copy_nova:
	bra.s .boucle
.ligne:
	move.w (a2)+,(a1)+
	addq.l #2,a2
	dbf d1,.ligne
	add d2,a2
.boucle:
	move max_imagex,d1
	subq #1,d1
	dbf d3,.ligne
	rts
.copy_falc:
	bra.s .fboucle
.fligne:
	move.w (a2)+,d0
	NOVA16 d0
	ror #8,d0
	move d0,(a1)+
	addq.l #2,a2
	dbf d1,.fligne
	add d2,a2
.fboucle:
	move max_imagex,d1
	subq #1,d1
	dbf d3,.fligne
	rts

slide_new_file:
	lea full,a0
	lea full2,a2
	move.l a2,a3
	move.l a0,a1
.lb0:
	move.b (a5)+,d0
	move.b d0,(a0)+
	move.b d0,(a2)+
	cmp.b #'\',d0
	bne.s .lb1
	move.l a0,a1
	move.l a2,a3
.lb1:
	cmp.b #33,d0
	bpl.s .lb0			; another!
	move.l a3,fname_pos	; in case of mask
	subq.l #1,a5
	clr.b -(a0)
.lb2:
	move.b (a1)+,d0
	beq.s .lb3			; the end!
	cmp.b #'.',d0
	bne.s .lb2
.lb3:
	subq.l #2,a1
	move.l a1,slide_digit
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
	moveq #0,d1
.lb0:
	move.b (a5)+,d1
	sub.b #'0',d1
	bmi.s .end
	cmp.b #'9'+1,d1
	bpl.s .end
	muls.l #10,d0
	add.l d1,d0
	bra.s .lb0
.end:
	subq.l #1,a5
	rts

init_create_avi:
	move.l _freq_sav,frequency
	seq bad_sound			; if 0, no sound
	tst.b mountain
	bne.s .pas_aff
	pea create_avi_text
	GEMDOS 9,6
.pas_aff:
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

wind_update: dc.l wu_cont,global,wu_int,dum,dum,dum
wu_cont: dc.w 107,1,1,0,0

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
	tst.b mountain
	bne.s .pas_aff	
	pea sound_text
	GEMDOS 9,6
.pas_aff:
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
	muls.l sample_num,d0
	move.l snd_size,d1
	muls.l #1000000,d2:d1
	divs.l d0,d2:d1	; d1= micro seconds per frame	
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
	
alert_box: dc.l ab_cont,global,ab_int,intout,ab_addrin,dum
ab_cont: dc.w 52,1,1,1,0
ab_int: dc.w 1
ab_addrin: dc.l 0

_raw_16:
	move (a0),d1
	add d2,d1
	ror #8,d1
	move d1,(a0)+
	dbf d0,_raw_16
	rts
	
evnt_timer: dc.l et_cont,global,et_int,dum,dum,dum
et_cont: dc.w 24,2,1,0,0
et_int: dc.w 250,0			; 1/4 sec

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
		
init_create:
	tst.b slide_gif
	bne init_create_gif
	tst.b create_avi
	bne init_create_avi
	tst.b slide_degas
	bne init_create_degas
	tst.b mountain
	bne.s .pas_aff
	pea create_text
	GEMDOS 9,6
.pas_aff:
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
	muls.l #1000,d0:d4
	divs.l frequency,d0:d4
	divs.l sample_num,d4	; number of millisec per frame
	sf bad_sound
	bra.s .next
.no_sound:
	st bad_sound
	move.l _delay,d4		; time for one sample
	muls.l #5,d4			; in 1/1000
.next:
	move.l d4,d5
	move.l d4,_delay
	lea mov_header,a3
	move.l sample_num,d1
	muls.l d1,d5			; total time
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
	tst.b mountain
	bne.s .pas_aff1
	pea sound_text
	GEMDOS 9,6
.pas_aff1:
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
	move -4(a1),24(a3)	; img/cell
	move.l _delay,d1
	move d1,26(a3)			; time
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
	tst.b mountain
	bne.s .pas_aff2
	pea add_file
	GEMDOS 9,6	
.pas_aff2:
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
.glup:
	clr key_count
	bra.s .new
.z1:	
	cmp.l #1,disp_frame		; first frame?
	beq.s .glup					; yes, like a key frame
	move key_count,d0
	cmp key_rate,d0
	bne.s .other				; not a key frame	
.new:
	move (a1)+,d0
	ror #8,d0
	move d0,(a2)+				; copies every pixel
	st (a3)+						; all are new!
	subq.l #1,d5
	bne.s .new
	bra.s .next
.other:
	move (a1)+,d0
	ror #8,d0
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
	move (a4)+,(a0)+			; one pixel more
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
	move screenw,d5
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
	move screenw,d4
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
	move.l (a4)+,(a0)+			; 4-pixels more
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
	lea (a2,d4.w*4),a2
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
	
rsrc_gaddr: dc.l rg_cont,global,rg_int,dum,dum,tree
rg_cont: dc.w 112,2,1,0,1

_z1:
	cmp.l #1,disp_frame		; first frame?
	bne.s .lb0
	clr key_count
	bra.s _new
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
_other:
	move.l (a1)+,d0
	cmp.l (a2),d0
	sne (a3)+					; FF if 4 different pixels
	move.l d0,(a2)+
	move.l (a1)+,d0
	cmp.l (a2),d0
	sne (a3)+
	move.l d0,(a2)+
	move -(a3),d0
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
	clr (a3)+
	subq #1,d0						; ***
.opti_loop:
	move #2,(a3)+					; byte0 + byte2
	cmp #255,d0	
	bmi.s .end_loop
	move #254,(a3)+				; byte 0 + byte $FE
	sub #254,d0
	bra.s .opti_loop
.end_loop:
	move d0,(a3)+					; last value
	cmp.b #2,d6						; essaye de fusionner les deux 0,2,x,y
	bne.s .lb5
	move.b 1(a4),d6				; nombre de lignes a sauter
	add d0,d6
	cmp #255,d6
	bmi.s .merge
	moveq #2,d6
	bra.s .no_empty2				; pas de fusion possible
.merge:
	move.b (a4)+,-2(a3)			; new dx
	move.b (a4)+,d6
	sub d6,d2
	add.b d6,-1(a3)
	bra .while	
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
	
form_center: dc.l fc_cont,global,dum,rect,tree,dum
fc_cont: dc.w 54,0,5,1,0	

improve_rle16:
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
	move (a6)+,(a3)+
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
	bne.s .while	
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
	lea 0(a6,d1.w*2),a0		; p+t
	move d7,d4
	subq #1,d4
	sub d1,d4					; bytes-1-t
	bra.s .valid
.while:
	move 0(a0,d0.w*2),d5
	cmp 2(a0,d0.w*2),d5
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
	move (a2)+,(a1)+
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
	move d5,(a1)+
	bra.s .end_of_do
.not_if:
	move (a0),(a2)+
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
	move (a2)+,(a1)+
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
	move.l (a6)+,(a3)+
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


compress_run8:
	move.l d6,a2
	moveq #0,d1					; t=0
	moveq #0,d3					; bdex
.do_again:
	moveq #0,d0					; i=0
	lea 0(a6,d1.w*4),a0		; p+t
	move d7,d4
	subq #1,d4
	sub d1,d4					; bytes-1-t
	bra.s .valid
.while:
	move.l 0(a0,d0.w*4),d5
	cmp.l 4(a0,d0.w*4),d5
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
	move.l (a2)+,(a1)+
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
	move.l d5,(a1)+
	bra.s .end_of_do
.not_if:
	move.l (a0),(a2)+
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
	move.l (a2)+,(a1)+
.d2:
	dbf d3,.copy_last
.no_remain:
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

evnt_button: dc.l eb_cont,global,eb_int,intout,dum,dum
eb_cont: dc.w 21,3,5,0,0
eb_int: dc.w 1,1,0

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

end_of_flm:
	bsr.l complete_flm_file
	move.l flm_screen,a2
	bsr mfree
	move.l flm_frame,a2
	bsr mfree
	rts
	
save_header:
	tst.b slide_gif
	bne end_of_gif
	tst.b mountain
	bne.s .pas_aff3
	pea add_header
	GEMDOS 9,6
.pas_aff3:
	tst.b create_avi
	bne end_of_avi
	tst.b slide_degas
	bne end_of_flm
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
	bne.s .lbk			; stange end...
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
	tst.b is_tt
	beq.s .o6a
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
	cmp.b #'r',d0
	bne.s .o9
	bsr cmd_get_int
	st cmd_return
	move.l d0,cmd_return_adr
	move.l d0,a0
	clr (a0)		; default is 'not found'!!!
	move.l #VERSION,68(a0)	; fills the version number
	bra parse_command_line
.o9:	
	cmp.b #'v',d0
	bne.s .o10
	move.b d1,_conv_video
	bra parse_command_line
.o10:
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
	move.b (a5)+,d1
	cmp.b #'w',d1
	beq.s .word
	cmp.b #'W',d1
	beq.s .word
	cmp.b #'L',d1
	beq.s .long
	cmp.b #'l',d1
	beq.s .long
	cmp.b #'$',d1
	beq.s .hexa
	bra.s .skip
.lb0:
	move.b (a5)+,d1		; one char
.skip:
	sub.b #'0',d1			
	bmi.s .end				; not a digit
	cmp.b #10,d1
	bpl.s .end				; not a digit
	add.l d0,d0
	move.l d0,d2
	add.l d2,d2
	add.l d2,d2
	add.l d2,d0				; d0*10
	add.l d1,d0				; adds this digit
	bra.s .lb0
.end:
	subq.l #1,a5			; back one char
	rts
.word:
	move.b (a5)+,d0
	ror #8,d0
	move.b (a5)+,d0
	rts
.long:
	bsr.s .word
	swap d0
	bra.s .word
.hexa:
	move.b (a5)+,d1		; one char
	or.b #$20,d1			; to lower case
	sub.b #'0',d1			
	bmi.s .end				; not a digit
	cmp.b #10,d1
	bmi.s .ok
	sub.b #39,d1
	cmp.b #16,d1
	bpl.s .end
	cmp.b #10,d1
	bmi.s .end
.ok:
	lsl.l #4,d0				; d0*16
	add.l d1,d0				; adds this digit
	bra.s .hexa
	
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
	bset #2,([kbshift])
.lb0:
	move (sp)+,sr
	rts
	
my_midi:
	st inter_flag
	bset #2,([kbshift])
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

planes_display:
	move.l tt_comp,a0
	jsr (a0)
	move max_imagey,a3	; 8 bytes from the upper label
	moveq #0,d0
	move.l image,a0		; 16 bytes from the upper label
	move d0,d1				; 22 bytes from the upper label
	muls alignwidth,d1
	add.l d1,a0
	muls #320,d0
	move.l tt_screen,a1
	add.l d0,a1
	move #320,a4
	sub alignwidth,a4		; row inc
	move a3,d5
	bra .first
.line_loop:
	move alignwidth,d6
	lsr #4,d6
	subq #1,d6
.line:
	movem.l (a0)+,d1-d4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	splice d2,d4,d0,d7,8
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	swap d2
	swap d4
	eor d1,d2
	eor d3,d4
	eor d2,d1
	eor d4,d3
	eor d1,d2
	eor d3,d4
	swap d2
	swap d4
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move d4,(a1)+
	swap d4
	move d2,(a1)+
	swap d2
	move d3,(a1)+
	swap d3
	move d1,(a1)+
	swap d1
	move d4,(a1)+
	move d2,(a1)+
	move d3,(a1)+
	move d1,(a1)+
	dbf d6,.line
	add a4,a1
.first:
	dbf d5,.line_loop
	rts		
	
	
planes_disp_double:
	move.l tt_comp,a0
	jsr (a0)
	move max_imagey,a3	; 8 bytes from the upper label
	moveq #0,d0
	move.l image,a0		; 16 bytes from the upper label
	move d0,d1				; 22 bytes from the upper label
	muls alignwidth,d1
	add.l d1,a0
	muls #640,d0
	move.l tt_screen,a1
	add.l d0,a1
	move #640,a4
	sub alignwidth,a4		; row inc
	move a3,d5
	lea 320(a1),a3
	bra .first
.line_loop:
	move alignwidth,d6
	lsr #4,d6
	subq #1,d6
.line:
	movem.l (a0)+,d1-d4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	splice d2,d4,d0,d7,8
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	swap d2
	swap d4
	eor d1,d2
	eor d3,d4
	eor d2,d1
	eor d4,d3
	eor d1,d2
	eor d3,d4
	swap d2
	swap d4
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move d4,(a1)+
	move d4,(a3)+
	swap d4
	move d2,(a1)+
	move d2,(a3)+
	swap d2
	move d3,(a1)+
	move d3,(a3)+
	swap d3
	move d1,(a1)+
	move d1,(a3)+
	swap d1
	move d4,(a1)+
	move d2,(a1)+
	move d3,(a1)+
	move d1,(a1)+
	move d4,(a3)+
	move d2,(a3)+
	move d3,(a3)+
	move d1,(a3)+
	dbf d6,.line
	add a4,a1
	add a4,a3
.first:
	dbf d5,.line_loop
	rts		

get4on8 MACRO
	move.w (a0)+,\1
	move.b (a0),\1
	swap \1
	addq.l #2,a0
	move.w (a0)+,\1
	move.b (a0),\1
	addq.l #2,a0
	ENDM

planes_disp_half:
	move.l tt_comp,a0
	jsr (a0)
	move max_imagey,a3		; 8 bytes from the upper label
	moveq #0,d0
	move.l image,a0		; 16 bytes from the upper label
	move d0,d1				; 22 bytes from the upper label
	muls alignwidth,d1
	add.l d1,a0
	muls #320,d0
	move.l tt_screen,a1
	add.l d0,a1
	move #640,d0
	sub alignwidth,d0
	asr d0
	move d0,a4
	move a3,d5
	bra .first
.line_loop:
	move alignwidth,d6
	lsr #5,d6
	subq #1,d6
.line:
	get4on8 d1
	get4on8 d2
	get4on8 d3
	get4on8 d4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	splice d2,d4,d0,d7,8
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	swap d2
	swap d4
	eor d1,d2
	eor d3,d4
	eor d2,d1
	eor d4,d3
	eor d1,d2
	eor d3,d4
	swap d2
	swap d4
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move d4,(a1)+
	swap d4
	move d2,(a1)+
	swap d2
	move d3,(a1)+
	swap d3
	move d1,(a1)+
	swap d1
	move d4,(a1)+
	move d2,(a1)+
	move d3,(a1)+
	move d1,(a1)+
	dbf d6,.line
	add a4,a1
.first:
	dbf d5,.line_loop
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
	moveq #24,d7
	muls.l d0,d7		; hours since 1/1/1904
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
	mulu.l #60,d7		; into minutes
	ext.l d2
	add.l d2,d7			; add the minutes
	mulu.l #60,d7		; into seconds
	ext.l d1
	add.l d1,d7			; add the minutes
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


mpg_read_header:
	SEEK #0,0		; start of file
	bsr read_long
	cmp.l #$000001b3,d0
	beq.s .ok
	cmp.l #$000001ba,d0
	beq.s .ok1
	moveq #1,d0
.ok:
	rts
.ok1:
	moveq #99,d0
	move d0,sound_bits
	move.l d0,frequency
	st bad_sound
	moveq #0,d0
	rts
	
mpg_parse_bin:
	move.l #'mpeg',comp_txt
	tst.l frequency
	sne d5
	ext d5		; WORD negatif si il y a du son
	move.b ([kbshift]),d5
	and.b #3,d5			; BYTE non nul si SHIFT
	if REG=1
		move planes,d0
		tst.b res_switch
		beq.s .no_sw
		bmi.s .aab
		moveq #8,d0
		bra.s .no_sw
	.aab:
		moveq #16,d0
	.no_sw:
		cmp #16,d0
		seq can_fast
	endif
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
	bsr mpg_get_byte
	and #$F,d0
	move.b .temps(pc,d0.w),d0
	ext.l d0
	move.l d0,avi_rate		; images par seconde
	cmp.l #$800000,total		; grosse anim???
	bpl .gros
	bra.s .next
.temps: dc.b 30,24,24,25,30,30,50,60,60,15,30,30,30,30,30,30
.lb1:
	tst d5
	bpl .lb2			; ne plus lire si deja lu!
	cmp.b #$C0,d0
	bne .lb2
	bsr mpg_get_byte
	bsr mpg_get_byte
	bsr mpg_get_byte
	and #$ff,d0
	ror #6,d0
	cmp.b #2,d0
	bne.s .kautre
	bsr mpg_get_byte
	bsr mpg_get_byte
	and #$ff,d0
	subq #1,d0
	move d0,d6
	bra.s .ksauter
.kautre:
	rol #6,d0			; recupere
	cmp.b #$ff,d0
	bne.s .kautre2
.kouf:
	bsr mpg_get_byte
	cmp.b #$ff,d0
	beq.s .kouf
.kautre2:
	cmp #$40,d0
	bmi.s .kautre3
	bsr mpg_get_byte
	bsr mpg_get_byte
.kautre3:
 	cmp #$30,d0
 	bmi.s .kautre4
 	moveq #8,d6		; sauter 9
 	bra.s .ksauter
.freq: dc.w 22050,24000,16000,0,44100,48000,32000,0
.kautre4:
	cmp #$20,d0
	bmi.s .kautre5
	moveq #3,d6		; sauter 4
.ksauter:
	bsr mpg_get_byte
	dbf d6,.ksauter
.kautre5:
	bsr mpg_get_byte	; inutile
	bsr mpg_get_byte
	and #$8,d0
	lea .freq(pc,d0.w),a5
	bsr mpg_get_byte
	and #$c,d0
	lsr #1,d0
	move 0(a5,d0.w),frequency+2
	bsr mpg_get_byte
	ror #6,d0
	and #$C003,d0
	moveq #2,d1
	cmp.b #3,d0
	bne.s .ster
	moveq #1,d1
.ster:
	move d1,channels
	rol #2,d0
	and #3,d0
	addq #1,d0
	lsl #2,d0
	move d0,sound_bits
	and #$FF,d5			
	bra .next
.lb2:
	cmp.b #$00,d0
	bne .next
	bsr mpg_get_byte
	bsr mpg_get_byte
	and #$38,d0
	lsr #3,d0					; frame type (1, 2, 3) 
	addq.l #1,sample_num	
	bra .next
.gros:
	tst d5
	bne .next					; chercher encore le 1C0 pour le son
	tst.b d5
	bne .next					; si SHIFT, lecture des images
	st unknown					; nombre inconnu
	clr.l sample_num
	rts


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


mpg_read_data:
	tst.b is_tt
	beq.s .lb0
	move.l image,buffer
.lb0:
	move mov_h,-(sp)
	GEMDOS 62,4				; referme le MPG!!!
	move #-1,mov_h			; plus a fermer maintenant.
.again:
	clr.l disp_frame
	moveq #-1,d7
	move.l d7,a5
	clr -(sp)
	move.l d7,-(sp)
	GEMDOS 68,8				; total ST RAM
	move.l d0,d6
	lea full2,a0
	lea avr_path,a1
	lea 1(a1),a2
	move.l #'-q  ',(a2)+
.copy_cmd:
	move.b (a0)+,(a2)+
	bne.s .copy_cmd
	subq.l #1,a2
	move.l #' f%d',(a2)+
	move.w #'%c',(a2)+
	clr.b (a2)+
	lea -1(a2),a0		; final 0
	subq.l #2,a2
	sub.l a1,a2
	move a2,d0
	move.b d0,(a1)		; size of command line
	move.l a7,conv1_stack
	move.l a0,-(sp)	; envir
	move.l a1,-(sp)	; cmd
	clr.l -(sp)			; no name!
	move #5,-(sp)		; basepage
	GEMDOS 75,16
	tst.l d0
	bmi .erreur
	move.l d0,a3
	move #1,-(sp)
	move.l d7,-(sp)
	GEMDOS 68,8			; total TT Ram
	cmp.l d0,d6
	bpl.s .en_st
	move.l d0,d6		; nouvelle taille
	move #1,-(sp)
	move.l d6,-(sp)
	GEMDOS 68,8			; alloue toute la TT RAM
	move.l d0,a0		; nouvelle base_page
	move.l a3,a1		; ancienne
	move.l d0,a3		; conserve
	move.l a3,(a0)+	; base TPA
	lea 0(a3,d6.l),a2
	move.l a2,(a0)+	; haut TPA
	rept 6
	clr.l (a0)+
	endr					; ptrs vers DATA TEXT etc...
	lea 128(a3),a2
	move.l a2,(a0)+	; DTA
	move.l basepage,(a0)+
	move.l #7,(a0)+	; flags
	lea 44(a1),a2		; reste de la vieille basepage
	moveq #52,d0
.copy_base:
	move.l (a2)+,(a0)+
	dbf d0,.copy_base
	move.l a1,-(sp)
	GEMDOS 73,6			; libŠre l'ancienne zone
.en_st:
	lea _mpeg,a0		; le prog en ICE
	lea 256(a3),a1		; start of TEXT
	move.l a1,8(a3)	; start TEXT
	move.l 2(a0),d0
	move.l d0,12(a3)	; taille TEXT
	add.l d0,a1
	move.l a1,16(a3)	; start DATA
	move.l 6(a0),d0
	move.l d0,20(a3)	; taille DATA
	add.l d0,a1
	move.l a1,24(a3)	; start BSS
	move.l 10(a0),28(a3)	; taille BSS
	add #28,a0			; TEXT source
	lea 256(a3),a1		; TEXT dest
	lea skip_iv32,a2	; fin source
.copy_prog:
	rept 4
	move.l (a0)+,(a1)+
	endr
	cmp.l a2,a0
	bmi.s .copy_prog
	clr.l -(sp)
	move.l a3,-(sp)	; cmd
	clr.l -(sp)			; no name!
	move #4,-(sp)		; GO!
	pea inst_mpg_trap(pc)
	XBIOS 38,6	
	XBIOS 37,2
	XBIOS 37,2
	GEMDOS 75,16
	tst.l d0
	bmi.s .erreur
	pea uninst_mpg_trap(pc)
	XBIOS 38,6
	XBIOS 37,2
	XBIOS 37,2
	move.l a3,-(sp)	; libere le programme
	GEMDOS 73,6
	btst #2,([kbshift])
	sne stopped
	bne.s .no_rep
	tst.b is_rep
	bne .again
.no_rep:
	bclr #2,([kbshift])
	sf stopped
	move.l disp_frame,d0
	cmp.l sample_num,d0
	bmi.s .ok
	move.l d0,sample_num	
.ok:
	tst.b is_tt
	beq.s .lb1
	clr.l buffer
.lb1:
	rts
	
.erreur:
	neg.l d0
	sub #31,d0			; TOS code
	move d0,fe_int
	GEM_AES form_error
	rts
	
inst_mpg_trap:
	bsr invalid_cache
	lea $a0.w,a0
	lea _mpg_trap,a1
	move.l (a0),(a1)+
	move.l #mpg_trap,(a0)
	move.l -(a0),(a1)+
	if MARTIN=1
		move.l #mpg_time,(a0)
		clr _mpg_time
	else
		move.l #read_indirect,(a0)
		moveq #-1,d0
		move.l d0,read_ptr
	endif
	move.l $4ba.w,start_time
	rts
	
uninst_mpg_trap:
	lea $a0.w,a0
	lea _mpg_trap,a1
	move.l (a1)+,(a0)
	move.l (a1),-(a0)
	if MARTIN=1
		cmp #2,_mpg_time
		beq.s .fin
		move.l $4ba.w,end_time
	.fin:		
	else
		move.l $4ba.w,end_time
	endif
	rts

mpg_time:
	tst _mpg_time
	beq.s .first
	move.l $4ba.w,end_time
.lb0:
	addq #1,_mpg_time
	rte
.first:
	bsr restore_cache
	move.l $4ba.w,start_time
	if REG=1
		move.b fast_mode,d0
		ext.w d0
	else
		moveq #-1,d0
	endif
	if MARTIN=1
		move.l kbshift,d3
	endif
	bra.s .lb0
	
;mpg_fin:
;	st stopped
;	clr -(sp)
;	trap #1
		
mpg_trap:
	movem.l d0-d3/a1-a3,-(sp)
	addq.l #1,disp_frame
	if REG=1
		cmp #16,planes
		bne.s .fast_disp
		tst.b fast_mode
		beq mpg_color
.fast_disp:
	endif
	if MARTIN=1
		move.l 20(a6),a0			; Y
	else
		move.l 12(a6),a0
		move.l (a0),a0				; buffer Y
	endif
	tst.b is_tt
	beq.s .carte
	move.l a0,image
	movem.l d4-d7/a4,-(sp)
	move.l compression,a0
	jsr 8(a0)
	movem.l (sp)+,d4-d7/a4
	bra.s mpg_commun
.carte:
	move.l image,a1
	move max_imagey,d1
	move screenw,d3
	cmp #8,planes
	beq .cloopy
	add d3,d3
	lea cvid_fix0,a3
	moveq #0,d0
	bra.s .loopy
.ligne:
	move max_imagex,d2
	bra.s .loopx
.point:
	move.b (a0)+,d0
	move 0(a3,d0*2),(a1)+
.loopx:
	dbf d2,.point	
	lea 0(a2,d3.w),a1	
.loopy:
	move.l a1,a2
	dbf d1,.ligne
	bra.s mpg_commun
.cligne:
	move max_imagex,d2
	bra.s .cloopx
.cpoint:
	move.b (a0)+,(a1)+
.cloopx:
	dbf d2,.cpoint	
	lea 0(a2,d3.w),a1	
.cloopy:
	move.l a1,a2
	dbf d1,.cligne
mpg_commun:
	movem.l (sp)+,d0-d3/a1-a3
	tst.b step_mode
	beq.s .suite
	bsr inc_frame
	beq.s .quit
	bpl.s .suite
	bsr save_frame
	bmi.s .quit
	bra.s .suite
;.control:
;	btst #2,([kbshift])
;	beq.s .suite
.quit:
	bset #2,([kbshift])
;	move.l #mpg_fin,2(sp)
.suite:
	rte


	if REG=1
mpg_color:
	movem.l d4/d6/a4-a6,-(sp)
	if MARTIN=1
		lea 12(a6),a0
		move.l (a0)+,a6
		move.l (a0)+,a5
		move.l (a0),a0
	else
		move.l 12(a6),a5
		MOVE.L (A5)+,A0	;source tableau y
		MOVE.L (A5)+,A6	;source tableau u
		MOVE.L (A5),A5		;source tableau v
	endif
	move.l hc_cvid,a3	; conversion
	move.l image,a1
	move screenw,d3
	move max_imagey,d1
	add d3,d3
	lsr d1				; half size
	move max_imagex,d4
	moveq #0,d0
	bra.s .loopy
.ligne:
	move d4,d2
	lsr d2				; half size
	bra.s .loopx
.point4:
	moveq #0,d6
	move.b (a6)+,d6
	add.b #$80,d6
	lsl #5,d6
	move.b (a5)+,d6
	add.b #$80,d6
	and.w #$1FF8,d6
	lsl.l #6,d6
	lea (a3,d6.l),a4	; conversion
	move.b (a0)+,d0
	move (a4,d0*2),(a1)+
	move.b (a0),d0
	move (a4,d0*2),(a1)
	lea -1(a0,d4.w),a0
	lea -2(a1,d3.w),a1
	move.b (a0)+,d0
	move (a4,d0*2),(a1)+
	move.b (a0)+,d0
	move (a4,d0*2),(a1)+
	sub d4,a0
	sub d3,a1
.loopx:
	dbf d2,.point4
	lea 0(a2,d3.w*2),a1
	add d4,a0
.loopy:
	move.l a1,a2
	dbf d1,.ligne
	movem.l (sp)+,d4/d6/a4-a6
	bra mpg_commun
	
	endif

	if MARTIN=0

read_ptr: dc.l 0
read_end: dc.l 0

read_indirect:
	cmp #99,frequency+2
	beq.s .avec_son
	move.l d5,-(sp)		; lecture normale!!!
	move.l d6,-(sp)
	move d4,-(sp)
	GEMDOS 63,12
	rte
.avec_son:
	movem.l d6/a2-a4,-(sp)
	move.l d5,a0		; le buffer
	move.l d6,d1		; la taille
	move.l read_ptr(pc),a3
	cmp.l #-1,a3		; mis a -1 pour la premiere fois
	bne.s .vas_y
	bsr.s .read			; premiŠre fois, lire!
	move #49,d0			; 50 longs = 200 octets
	sub #200,d1
.copy_header:
	move.l (a3)+,(a0)+
	dbf d0,.copy_header
	lea reserve_num(pc),a1
	clr (a1)
	bra .loop
.ca_roule:
	lea 0(a3,d0.l),a4			; fin de buffer
	sub.l #8192,d0
	beq.s .tout
	move.l #$000001B7,(a4)+	; fin forcee
	move.l a4,a2
.truc:
	move.l #-1,(a2)+			; bourre la fin de -1
	subq.l #4,d0
	bpl.s .truc
.tout:
	move.l a4,read_end
	rts
.read:
	movem.l d1/a0-a1,-(sp)
	lea cvid_fix1,a3
	move.l a3,read_ptr
	move.l a3,-(sp)
	move.l #8192,-(sp)
	move.w d4,-(sp)
	GEMDOS 63,12
	movem.l (sp)+,d1/a0-a1
	tst.l       D0
	bpl.s .ca_roule
	movem.l (sp)+,d1/a2-a4
	rte							; retourne le code d'erreur
.vas_y:
	move.l read_end(pc),a4
.debut:
	lea reserve_num(pc),a1
	move (a1),d0
	beq .loop
	sub d0,d1
	addq.l #2,a1
	bra.s .toutou
.reste:
	move.b (a1)+,(a0)+
.toutou:
	dbf d0,.reste
	lea reserve_num(pc),a1
	clr (a1)
	bra .loop
.charger0:
	bsr.s .read
	bra.s .retour0
.charger1:
	bsr.s .read
	bra.s .retour1
.charger2:
	bsr.s .read
	bra.s .retour2
.charger3:
	bsr.s .read
	bra.s .retour3
.again:
	cmp.l a4,a3
	bpl.s .charger0
.retour0:
	move.b (a3)+,d0
	bne .pas_nul		; facheux!
	cmp.l a4,a3
	bpl.s .charger1
.retour1:
	move.b (a3)+,d0
	bne.s .zut
	cmp.l a4,a3
	bpl.s .charger2
.retour2:
	move.b (a3)+,d0
	cmp.b #$1,d0
	bne.s .zut2
	cmp.l a4,a3
	bpl.s .charger3
.retour3:
	move.b (a3)+,d0
	cmp.b #$ba,d0
	beq .cut_ba		; retour a again
	cmp.b #$e0,d0
	beq .cut_e0		; idem
	cmp.b #$c0,d0
	beq .cut_c0		; idem
	cmp.b #$be,d0
	beq .cut_c0		; kif kif
	cmp.b #$bb,d0
	beq .cut_c0
	clr.b (a0)+
	subq #1,d1
	bpl.s .zut3
	move #3,(a1)+
	move #1,(a1)+
	move.b d0,(a1)
	bra.s .fin
.zut3:
	clr.b (a0)+
	subq #1,d1
	bpl.s .zut4
	move #2,(a1)+
	move.b #1,(a1)+
	move.b d0,(a1)
	bra.s .fin
.zut4:
	move.b #1,(a0)+
	bra.s .zut5
.zut:
	clr.b (a0)+
.zut5:
	subq #1,d1
	bpl.s .pas_nul
	move #1,(a1)+
	move.b d0,(a1)
	bra.s .fin
.zut2:
	clr.b (a0)+
	subq #1,d1
	bpl.s .zut
	move #2,(a1)+
	clr.b (a1)+
	move.b d0,(a1)
	bra.s .fin
.pas_nul:
	move.b d0,(a0)+	; un de plus!
.loop:
	dbf d1,.again
.fin:
	move.l a3,read_ptr
	movem.l (sp)+,d0/a2-a4	; d0 recupere la valeur de D6 (taille)
	rte
.cut_ba:
	addq.l #8,a3		; $1ba, sauter 8 octets
.sauter:
	cmp.l a3,a4
	bpl .again
	sub.l a4,a3			; nombre d'octets restants
	move.l a3,a2
	bsr .read			; avancer
	add.l a2,a3
	bra .again
.cut_e0:
	bsr.s .getbyte
	bsr.s .getbyte
	bsr.s .getbyte
	and #$ff,d0
	ror #6,d0
	cmp.b #2,d0
	bne.s .autre
	bsr.s .getbyte
	bsr.s .getbyte
	and #$ff,d0
	add.w d0,a3
	bra.s .sauter
.autre:
	rol #6,d0			; recupere
	cmp.b #$ff,d0
	bne.s .autre2
.ouf:
	bsr.s .getbyte
	cmp.b #$ff,d0
	beq.s .ouf
.autre2:
	; cmp #$80,d0
	; bpl erreur!!
	cmp #$40,d0
	bmi.s .autre3
	bsr.s .getbyte
	bsr.s .getbyte
.autre3:
 	; cmp	#$40,d0
 	; bpl erreur!!
 	cmp #$30,d0
 	bmi.s .autre4
 	add #9,a3
 	bra.s .sauter
.autre4:
	cmp #$20,d0
	bmi.s .autre5
	addq.l #4,a3
	bra.s .sauter
.autre5:
	; cmp #$f,d0
	; bne erreur!
	bra .again		; rien a sauter avec $0F
.getbyte:
	cmp.l a4,a3
	bmi.s .ok1
	bsr .read
.ok1:
	moveq #0,d0
	move.b (a3)+,d0
	rts
.cut_c0:
	bsr.s .getbyte
	lsl #8,d0
	move.l d0,a2
	bsr.s .getbyte
	add.l a2,d0		; reconstruit le mot
	add.l d0,a3		; saute le bloc son!!!
	bra .sauter

reserve_num: dc.w 0
reserve: dc.l 0

	endif
	
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
	divs.l #30,d0					; nuber of 1/200 per frame
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
	move.l total,(a3,d3.l)		; the last value is the total length
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
	bsr v_new_palette
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
	move ccr,d1
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
	btst #2,([kbshift])
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
	lea (a1,d0.l),a2				; end of datas
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
	move 60(a0),d2			; H
	muls d2,d0				; number of words in one plane
	add.l d0,d0				; number of bytes in one plane
	lea (a1,d0.l),a2
	lea (a2,d0.l),a3
	lea (a3,d0.l),a4		; the other planes
	move.l s_buffer_2,a6
	subq #1,d2				; for the loop
	tst.b 63(a0)
	beq .really_no_comp
	cmp #4,planes			; 320x200x16???
	beq .planes_mode
	add.w 54(a0),a6		; + offs_x
	move 56(a0),d0			; offs_y
	muls #320,d0
	add.l d0,a6				; start into buffer 2
	move.l a6,clip_adr
	move.l a6,-(sp)
.other_column:	
	moveq #16,d0
	cmp #16,d1
	bpl.s .ok_all
	move d1,d0
.ok_all:
	sub d0,d1				; those are treated now
	subq #1,d0				; for the loop
	swap d2
	move d0,d2
	swap d2
	swap d0
	move.l a6,-(sp)
	move d2,d0
	tst.b 62(a0)			; copy or XOR?
	bne.s .x_little_line
.little_line:
	swap d0
	move (a1)+,d3
	move (a2)+,d4
	move (a3)+,d5
	move (a4)+,d6
.pixels:
	moveq #0,d7
	lsl d6
	roxl.b d7
	lsl d5
	roxl.b d7
	lsl d4
	roxl.b d7
	lsl d3
	roxl.b d7
	move.b d7,(a6)+
	dbf d0,.pixels
	add.l #320,(sp)
	move.l (sp),a6
	swap d2
	move d2,d0
	swap d2
	swap d0
	dbf d0,.little_line
.common:
	addq.l #4,sp
	addq.l #8,(sp)
	addq.l #8,(sp)
	move.l (sp),a6
	tst d1
	bne.s .other_column
	addq.l #4,sp
	moveq #0,d0
	rts
.exit:
	moveq #1,d0				; a nop frame
	rts	
.x_little_line:
	swap d0
	move (a1)+,d3
	move (a2)+,d4
	move (a3)+,d5
	move (a4)+,d6
.x_pixels:
	moveq #0,d7
	lsl d6
	roxl.b d7
	lsl d5
	roxl.b d7
	lsl d4
	roxl.b d7
	lsl d3
	roxl.b d7
	eor.b d7,(a6)+
	dbf d0,.x_pixels
	add.l #320,(sp)
	move.l (sp),a6
	swap d2
	move d2,d0
	swap d2
	swap d0
	dbf d0,.x_little_line	
	bra.s .common
.planes_mode:
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
	cmp #4,planes
	bne.s .no_planes
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
.no_planes:
	move.l s_buffer_2,a6
	add.w 54(a0),a6		; + offs_x
	move 56(a0),d0			; offs_y
	muls #320,d0
	add.l d0,a6				; start into buffer 2
	move.l a6,clip_adr
	move.l d1,a3			; W
.nc_other_line:	
	move.l a6,a4
	moveq #0,d1				; no pixels yet
.nc_16_pix:
	moveq #16,d0
	add d0,d1
	cmp d1,a3
	bpl.s .nc_ok_all
	sub a3,d1
	sub d1,d0
	move d3,d1
.nc_ok_all:
	movem (a1)+,d3-d6
	subq #1,d0
.nc_pixels:
	moveq #0,d7
	lsl d6
	roxl.b d7
	lsl d5
	roxl.b d7
	lsl d4
	roxl.b d7
	lsl d3
	roxl.b d7
	move.b d7,(a6)+
	dbf d0,.nc_pixels
	cmp d1,a3
	bne.s .nc_16_pix
	lea 320(a4),a6
	dbf d2,.nc_other_line
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
	if REG=0
		lea cvid_fix1,a3
	endif
	move #$FFF,d2
	cmp #9,planes
	bmi.s .not_tc
	lea 32(a2),a3
	lea cvid_fix1,a1
.lb0:
	move (a0)+,d1
	and d2,d1
	cmp (a3),d1
	beq.s .equal
	move d1,(a3)
	addq #1,d3			; palette has changed
.equal:
	addq.l #2,a3
	move (a1,d1.w*2),(a2)+
	dbf d0,.lb0
	move.b d3,pal_change
	rts
.not_tc:
	tst.b is_tt
	beq.s .vdi_call
.tt_xbios:
	move (a0)+,d1		; one color
	if REG=0
		and d2,d1
		move (a3,d1.w*2),d1	; to grey!
	endif
	cmp (a2),d1			; equals the old one?
	beq.s .eq_2			; yes
	move d1,(a2)		; else, updates
	addq #1,d3			; palette change!
.eq_2:
	addq.l #2,a2
	dbf d0,.tt_xbios
	tst.b d3
	beq.s .exit
	move.l a6,-(sp)
	XBIOS 6,6			; set palette
.exit:
	rts		
.vdi_call:
	move (a0)+,d1		; one color
	if REG=0
		and d2,d1
		move (a3,d1.w*2),d1	; to grey!
	endif
	cmp (a2),d1			; equals the old one?
	beq.s .eq_3			; yes
	move d1,(a2)		; else, updates
	movem.l d0/d2/a0/a2,-(sp)
	lea vs_int,a0
	moveq #15,d2
	sub d0,d2
	move (indexs,d2.w*2),(a0)+	; index
	move d1,d0
	and #$888,d0
	lsr #3,d0
	and #$777,d1
	add d1,d1
	add d0,d1
	bfextu d1{20:4},d0
	muls #66,d0
	move d0,(a0)+
	bfextu d1{24:4},d0
	muls #66,d0
	move d0,(a0)+
	and #$f,d1
	muls #66,d1
	move d1,(a0)
	GEM_VDI vs_color
	movem.l (sp)+,d0/d2/a0/a2
.eq_3:
	addq.l #2,a2
	dbf d0,.vdi_call
	rts
	
seq_disp_image:
	cmp #4,planes
	beq .st_low
	move.l image,a3
	move screenw,d3
	cmp #9,planes
	bmi .not_tc
	tst.b pal_change
	beq.s	.clip
	sub #320,d3
	add d3,d3
	move.l s_buffer_2,a0
	moveq #0,d0
	move #199,d1
.line:
	moveq #79,d2
.pixels:
	rept 4
	move.b (a0)+,d0
	move (a6,d0.w*2),(a3)+
	endr
	dbf d2,.pixels
	add d3,a3
	dbf d1,.line
	rts
.clip:
	move.l clip_adr,a0
	move.l buffer,a1
	move 56(a1),d0
	muls d3,d0
	move 54(a1),d1
	ext.l d1
	add.l d1,d0
	add.l d0,d0
	add.l d0,a3		; new address into video RAM
	move 58(a1),d0	; L
	sub d0,d3
	add d3,d3		; inc for video RAM
	move #320,d1
	sub d0,d1		; inc for buffer
	move 60(a1),d7	; H
	subq #1,d7		; for the loop
	subq #1,d0		; for the loop
	moveq #0,d6
.loop:
	move d0,d2
.c_line:
	move.b (a0)+,d6
	move (a6,d6.w*2),(a3)+
	dbf d2,.c_line
	add d1,a0
	add d3,a3
	dbf d7,.loop
	rts
.not_tc:
	move.l clip_adr,a0
	move.l buffer,a1
	move 56(a1),d0
	muls d3,d0
	move 54(a1),d1
	ext.l d1
	add.l d1,d0
	add.l d0,a3		; new address into video RAM
	move 58(a1),d0	; L
	sub d0,d3		; inc for video RAM
	move #320,d1
	sub d0,d1		; inc for buffer
	move 60(a1),d7	; H
	subq #1,d7		; for the loop
	subq #1,d0		; for the loop
.ntc_loop:
	move d0,d2
.ntc_line:
	move.b (a0)+,(a3)+
	dbf d2,.ntc_line
	add d1,a0
	add d3,a3
	dbf d7,.ntc_loop
	rts
.st_low:
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
	divs.l #3,d0				; number of 1/200 per frame
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
	tst.b is_tt
	beq.s .other
	lea vcp_int,a1
	move #3,(a1)+
	clr.l (a1)+
	move max_imagex,d0
	swap d0
	move max_imagey,d0
	sub.l #$10001,d0
	move.l d0,(a1)+
	move.l offsx,d1
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
	bsr v_new_palette
	lea 64(a5),a0	; palette loaded
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
	btst #2,([kbshift])
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
	cmp #4,planes
	bne.s buffer_to_tc_256
	clr.l mfdb_dest
	GEM_VDI vro_cpyfm
	rts

buffer_to_tc_256:
	move.l buffer,a0		; keep those 6 bytes first (VMAS)
_buf_to_tc_256:
	move.l a5,-(sp)
	move.l image,a3
	move screenw,d3
;	move max_imagex,d0
	move alignwidth,d0
	sub d0,d3
	move d3,a5
	move max_imagey,d6
	subq #1,d6
	cmp #16,planes
	bne .last
	lea cvid_fix0,a6		; the palette
	add a5,a5				; inc for Video ram
	lea .little_buf+16(pc),a2
.next:
	move max_imagex,d5
.line:	
	moveq #16,d1
	cmp d1,d5
	bpl.s .enough
	move d5,d1
.enough:
	sub d1,d5
	move (a0)+,d4
	move (a0)+,d2
	move (a0)+,d3
	move (a0)+,d1
	move #$5555,d0
	sp_16.w d1,d3,1
	sp_16.w d2,d4,1
	move #$3333,d0
	sp_16.w d1,d2,2
	sp_16.w d3,d4,2
	swap d3
	swap d1
	move d4,d3
	move d2,d1
	move.l #$1E1E1E1E,d0
	move.l d1,d2
	move.l d3,d4
	add.l d1,d2
	add.l d3,d4		; double for A6 index
	and.l d0,d2
	and.l d0,d4
	lsr.l #3,d1
	lsr.l #3,d3
	and.l d0,d1
	and.l d0,d3
	move.l #$00ff00ff,d0
	sp_16.l d1,d3,8
	sp_16.l d2,d4,8
	moveq #0,d7
	movem.l d1-d4,-(a2)
	moveq #0,d0
	move.b (a2)+,d7
	rept 7
		move.b (a2)+,d0
		move 0(a6,d7.w),(a3)+
		move.b (a2)+,d7
		move 0(a6,d0.w),(a3)+
	endr
	move.b (a2)+,d0
	move 0(a6,d7.w),(a3)+
	move 0(a6,d0.w),(a3)+
	tst d5
	bne .line
	add a5,a3
	dbf d6,.next
	move.l (sp)+,a5
	rts
.last:
	move max_imagex,d5
.l_line:	
	moveq #16,d1
	cmp d1,d5
	bpl.s .l_enough
	move d5,d1
.l_enough:
	sub d1,d5
	move (a0)+,d4
	move (a0)+,d2
	move (a0)+,d3
	move (a0)+,d1
	move #$5555,d0
	sp_16.w d1,d3,1
	sp_16.w d2,d4,1
	move #$3333,d0
	sp_16.w d1,d2,2
	sp_16.w d3,d4,2
	swap d3
	swap d1
	move d4,d3
	move d2,d1
	move.l #$0F0F0F0F,d0
	move.l d1,d2
	move.l d3,d4
	and.l d0,d2
	and.l d0,d4
	lsr.l #4,d1
	lsr.l #4,d3
	and.l d0,d1
	and.l d0,d3
	move.l #$00ff00ff,d0
	sp_16.l d1,d3,8
	sp_16.l d2,d4,8
	movem.l d1-d4,(a3)
	add.w #16,a3	
	tst d5
	bne .l_line
	add a5,a3
	dbf d6,.last
	move.l (sp)+,a5
	rts
.little_buf: dc.l 0,0,0,0

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
	move.l #'.DLT',(a0)+	; new extension
	clr.b (a0)				; end of string
	clr -(sp)
	pea full2				; tries to open DLT file
	GEMDOS 61,8				; fopen 
	move d0,d7				; handle of the file is saved
	bmi.s .bug
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
	bsr v_new_palette
	lea 2(a3),a0			; points to the palette
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
	tst.b is_tt
	bne.s .no_disp
	bsr dlt_disp_image
.no_disp:
	addq.l #1,disp_frame
	btst #2,([kbshift])
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
	lea cvid_fix0+1023,a4	; flags for each line
	moveq #0,d3					; first offset
.lb1:
	move (a5)+,d1
	cmp d3,d1
	bmi.s .same_line
.next:
	add #160,d3					; next offset
	addq.l #1,a4
	cmp d3,d1
	bpl.s .next
	st (a4)	
.same_line:
	move.l (a5)+,d2
	eor.l d2,(a0,d1.w)
	dbf d0,.lb1
	moveq #1,d0				; returns NE
	rts

dlt_disp_image:
	move.l image,a3
	move screenw,d3
	move #320,d0
	sub d0,d3
	move #200,a2
	move.l buffer,a0
	lea cvid_fix0+1024,a4	; the flags for each line
	cmp #16,planes
	bne.s .last
	lea cvid_fix0,a6		; the palette
	add d3,d3				; inc for Video ram
.next:
	tst.b (a4)				; this line has changed?
	bne.s .yes
	lea 160(a0),a0
	lea 640(a3),a3
	bra.s .skip_line
.yes:
	move #320,d0
.line:	
	moveq #16,d1
	sub d1,d0
	subq #1,d1
	movem.w (a0)+,d4-d7	; the four planes
	swap d0
.pixels:
	clr d0
	lsl d7
	roxl.b d0
	lsl d6
	roxl.b d0
	lsl d5
	roxl.b d0
	lsl d4
	roxl.b d0
	move (a6,d0.w*2),(a3)+
	dbf d1,.pixels
	swap d0
	tst d0
	bne.s .line
.skip_line:
	sf (a4)+		; resets for the future
	add d3,a3
	subq #1,a2
	cmp #0,a2
	bne.s .next	
	rts	
.last:
	tst.b (a4)				; this line has changed?
	bne.s .l_yes
	lea 160(a0),a0
	lea 320(a3),a3
	bra.s .l_skip_line
.l_yes:
	move #320,d0
.l_line:	
	moveq #16,d1
	sub d1,d0
	subq #1,d1
	movem.w (a0)+,d4-d7	; the four planes
	swap d0
.l_pixels:
	clr d0
	lsl d7
	roxl.b d0
	lsl d6
	roxl.b d0
	lsl d5
	roxl.b d0
	lsl d4
	roxl.b d0
	move.b d0,(a3)+
	dbf d1,.l_pixels
	swap d0
	tst d0
	bne.s .l_line
.l_skip_line:
	sf (a4)+
	add d3,a3
	subq #1,a2
	cmp #0,a2
	bne.s .last
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
	cmp.b #4,57(a3)			; 4 plans?
	beq.s .found
	add.l d2,d2
	add.l d3,d3
	cmp.b #8,57(a3)			; VGA 256c
	beq.s .found
.zglity:	
	moveq #7,d1
	cmp.l #$14001e0,d0		; tt low
	beq.s .found
.no_more:
	moveq #-1,d1
	st bad_comp					; unsupported!
.found:
	move d1,tt_res
	move.l d2,tt_flag_size
	move.l d3,tt_screen_size
	move.l #'flm0',d0
	add.b 57(a3),d0			; flm1, 2, 4, 8, 16...
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
	bsr.l read_len_id
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
	
flm_read_data:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
	cmp.l #'flm1',comp_txt
	bne.s .colors
	tst.b is_tt
	beq.s .other
	clr $ffff8240.w
	move #$FFF,$ffff8242.w
	bra .again
.other:
	cmp #8,planes
	bne .again
	lea vs_int,a3
	clr.l (a3)+
	clr.l (a3)+
	GEM_VDI vs_color
	move #1000,d0
	move d0,-(a3)
	move d0,-(a3)
	move d0,-(a3)
	moveq #1,d0
	move d0,-(a3)
	GEM_VDI vs_color
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
	bsr v_new_palette
	move.l a3,a0
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
	move ccr,d2
	tst.l disp_frame
	bne.s .not_first
	move.l $4ba.w,start_time
	move.l $4ba.w,current_time
	tst.b playing
	beq.s .not_first
	bsr.l flm_start_sound
.not_first:	
	move d2,ccr
	beq.s .nothing
	tst.b is_tt
	bne.s .nothing
	move.l d7,-(sp)
	bsr flm_disp_image
	move.l (sp)+,d7
.nothing:
	addq.l #1,disp_frame
	move.l buffer,a3
	move.l 8(a3),d0
	or.l #$20202020,d0
	cmp.l #'time',d0
	bne.s .old_delay
	tst.b sync
	beq.s .common			; no synchro wanted
	move.l 12(a3),d0
	move.l d0,d1			; STE time
	tst.b real_freq
	beq.s .falc_adjust
	lsr.l #8,d1
	sub.l d1,d0
	lsr.l #2,d1
	sub.l d1,d0
	lsr.l d1
	sub.l d1,d0				; TT time (1-1/256-1/1024-1/2048)
	bra.s .adjusted
.falc_adjust:
	lsr.l #6,d1
	add.l d1,d0
	lsr.l #3,d1
	add.l d1,d0
	lsr.l #2,d1
	add.l d1,d0				; Falcon time (1+1/64+1/512+1/2048)		
.adjusted:		
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
	move.l kbshift,a0
	btst #2,(a0)
	bne.s .stop
	subq.l #1,d7			; one frame less
	bne .lb0				; not ended
	tst.b playing
	beq.s .no_sound
.wait_sound:
	tst.b snd_value
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
	tst.b snd_value
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
	lea cvid_fix1+8192,a4
	move #$fff,d3
	move #255,d4
	cmp #16,planes
	bne.s .not_tc
	lea cvid_fix0,a6
	lea 64(a6),a3
.lb0:
	move (a3)+,d1
	and d3,d1
	move (a4,d1.w*2),(a6)+
	dbf d4,.lb0
	rts
.not_tc:
	lea cvid_fix0+64,a3
	lea indexs,a5
.lb1:
	move (a3)+,d1
	and d3,d1
	if REG=0
		move (a4,d1.w*2),d1
	endif
	tst.b is_tt
	beq.s .not_tt
	move d1,-(sp)
	move #255,d1
	sub d4,d1
	move d1,-(sp)
	XBIOS 83,6
	dbf d4,.lb1
	rts
.not_tt:
	lea vs_int,a0
	move (a5)+,(a0)+
	move d1,d0
	lsr #8,d0
	muls #66,d0
	move d0,(a0)+
	move d1,d0
	lsr #4,d0
	and #$f,d0
	muls #66,d0
	move d0,(a0)+
	and #$f,d1
	muls #66,d1
	move d1,(a0)
	GEM_VDI vs_color
	dbf d4,.lb1
	rts	
	
; returns EQ if nothing to do

flm_decomp_frame:
	cmp.l #20,d5
	bpl.s .ok
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
	lea (a0,d0.w*2),a0
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
	move.l image,a3
	move screenw,d3
	move max_imagex,d0
	sub d0,d3
	move max_imagey,a2
	cmp #16,planes
	bne.s .not_tc
	lea cvid_fix0,a6		; the palette
	add d3,d3				; inc for Video ram
.not_tc:
	move tt_res,d0
	cmp #2,d0
	beq flm_st_high
	cmp #7,d0
	beq flm_tt_low
	cmp #16,planes			; here ST low or TT med (16 colors)
	bne .last_0
	cmp #4,d0
	bne.s .next
	cmp.l #'flm8',comp_txt
	beq flm_vga_256
	cmp #640,screenw
	bmi flm_tt_mid_half
.next:
	move max_imagex,d0
.line:	
	moveq #16,d1
	cmp d1,d0
	bpl.s .enough
	move d0,d1
.enough:
	sub d1,d0
	tst.l (a1)
	bne.s .changed
	addq.l #8,a0			; skips 4 planes
	add d1,d1
	add d1,a3				; and 16 (or else) pixels
	bra.s .skip
.changed:
	clr.l (a1)
	subq #1,d1
	swap d0
	movem.w (a0)+,d4-d7	; the four planes
.pixels:
	clr d0
	lsl d7
	roxl.b d0
	lsl d6
	roxl.b d0
	lsl d5
	roxl.b d0
	lsl d4
	roxl.b d0
	move (a6,d0.w*2),(a3)+
	dbf d1,.pixels
	swap d0
.skip:
	addq.l #4,a1
	tst d0
	bne.s .line
	add d3,a3
	subq #1,a2
	cmp #0,a2
	bne.s .next	
	rts	
.last_0:
	cmp #4,d0
	bne.s .last
	cmp.l #'flm8',comp_txt
	beq flm_vga_256
.last:
	move d3,a5
	move a2,d6
	subq #1,d6
.last_2:
	move max_imagex,d5
.l_line:	
	moveq #16,d1
	cmp d1,d5
	bpl.s .l_enough
	move d5,d1
.l_enough:
	sub d1,d5
	tst.l (a1)
	bne.s .l_changed
	addq.l #8,a0
	add d1,a3
	bra .l_skip
.l_changed:
	clr.l (a1)
	move (a0)+,d4
	move (a0)+,d2
	move (a0)+,d3
	move (a0)+,d1
	move #$5555,d0
	sp_16.w d1,d3,1
	sp_16.w d2,d4,1
	move #$3333,d0
	sp_16.w d1,d2,2
	sp_16.w d3,d4,2
	swap d3
	swap d1
	move d4,d3
	move d2,d1
	move.l #$0F0F0F0F,d0
	move.l d1,d2
	move.l d3,d4
	and.l d0,d2
	and.l d0,d4
	lsr.l #4,d1
	lsr.l #4,d3
	and.l d0,d1
	and.l d0,d3
	move.l #$00ff00ff,d0
	sp_16.l d1,d3,8
	sp_16.l d2,d4,8
	movem.l d1-d4,(a3)
	add.w #16,a3		
.l_skip:
	addq.l #4,a1
	tst d5
	bne .l_line
	add a5,a3
	dbf d6,.last_2
	rts
flm_tt_mid_half:
	move.l physbase,a3
	move screenh,d1
	sub #240,d1
	bpl.s .lb0
	moveq #0,d1
.lb0:
	asr d1
	move screenw,d0
	muls d0,d1
	sub #320,d0
	move d0,d3
	add d3,d3
	asr d0
	ext.l d0
	add.l d0,d1
	add.l d1,d1
	add.l d1,a3		; start in screen	
.next:
	move #640,d0
.line:	
	moveq #16,d1
	cmp d1,d0
	bpl.s .enough
	move d0,d1
.enough:
	sub d1,d0
	tst.l (a1)
	bne.s .changed
	addq.l #8,a0			; skips 4 planes
	add d1,a3				; and 8 (or else) pixels
	bra.s .skip
.changed:
	clr.l (a1)
	subq #1,d1
	swap d0
	movem.w (a0)+,d4-d7	; the four planes
.pixels:
	clr d0
	lsl d7
	roxl.b d0
	lsl d6
	roxl.b d0
	lsl d5
	roxl.b d0
	lsl d4
	roxl.b d0
	move (a6,d0.w*2),(a3)+
	subq #1,d1				; skips one pixel
	lsl d7
	lsl d6
	lsl d5
	lsl d4
	dbf d1,.pixels
	swap d0
.skip:
	addq.l #4,a1
	tst d0
	bne.s .line
	add d3,a3
	lea 320(a0),a0			; 640 pixels skipped (one line)
	lea 160(a1),a1			; 40 long flags skipped (one line)
	subq #1,a2
	cmp #0,a2
	bne.s .next	
	rts	
flm_st_high:
	cmp #16,planes
	bne.s .not_tc
	cmp #640,screenw
	bmi.s flm_st_high_half
.again:
	moveq #39,d2	; 40 words for each line
.line:
	tst.b (a1)
	beq.s .skip
	move (a0)+,d0
	moveq #15,d1
.lb0:
	btst d1,d0
	seq (a3)+
	seq (a3)+
	dbf d1,.lb0
	sf (a1)
	bra.s .next
.skip:
	lea 32(a3),a3	; 16 pixels
	addq.l #2,a0	; one word
.next:
	addq.l #1,a1	; flags
	dbf d2,.line
	add d3,a3
	subq #1,a2
	cmp #0,a2
	bne.s .again
	rts
.not_tc:
	moveq #39,d2	; 40 words for each line
.nt_line:
	tst.b (a1)
	beq.s .nt_skip
	move (a0)+,d0
	moveq #15,d1
.nt_lb0:
	btst d1,d0
	sne (a3)+
	dbf d1,.nt_lb0
	sf (a1)
	bra.s .nt_next
.nt_skip:
	lea 16(a3),a3	; 16 pixels
	addq.l #2,a0	; one word
.nt_next:
	addq.l #1,a1	; flags
	dbf d2,.nt_line
	add d3,a3
	subq #1,a2
	cmp #0,a2
	bne.s .not_tc
	rts	
flm_st_high_half:
	move.l physbase,a3
	move screenh,d1
	sub #200,d1
	asr d1
	move screenw,d0
	muls d0,d1
	sub #320,d0
	move d0,d3
	add d3,d3
	asr d0
	ext.l d0
	add.l d0,d1
	add.l d1,d1
	add.l d1,a3		; start in screen
	move #$1042,d4		; half grey for nova
	tst.b nova
	bne.s .again
	move #$8410,d4		; half grey for Falcon
.again:
	moveq #39,d2	; 40 words for each line
.line:
	tst.b (a1)
	beq.s .skip
	move (a0)+,d0
	moveq #15,d1
.lb0:
	btst d1,d0
	beq.s .lb1
	subq #1,d1
	btst d1,d0
	beq.s .lb2
	sf (a3)+
	sf (a3)+			; $11 = black
	bra.s .lb3
.lb1:
	subq #1,d1
	btst d1,d0
	bne.s .lb2		
	st (a3)+			; $00 = white
	st (a3)+
	bra.s .lb3
.lb2:
	move d4,(a3)+	; one grey =$10 or $01
.lb3:
	dbf d1,.lb0
	sf (a1)
	bra.s .next
.skip:
	lea 16(a3),a3	; 8 pixels
	addq.l #2,a0	; one word
.next:
	addq.l #1,a1	; flags
	dbf d2,.line
	add d3,a3
	lea 80(a0),a0	; skips one line into buffer
	lea 40(a1),a1	; one flag byte line skipped
	subq #2,a2		; two lines at a time
	cmp #0,a2
	bne.s .again
	rts
	
falc set 0
	
	rept 2
	
	if falc=0
flm_tt_low:
	else
flm_vga_256:
	endif
	move a2,d6
	subq #1,d6
	move d3,a5
	move screenw,d3
	move screenh,d2
	if falc=0
		sub #240,d2
	else
		sub #480,d2
	endif
	asr d2
	bpl.s .off_ok
	moveq #0,d2
.off_ok:
	muls d2,d3
	add.l d3,a3
	cmp #16,planes
	bne .not_tc
	add.l d3,a3
	lea cvid_fix1,a2	; for 16 bytes buffer
.again:
	if falc=0
		moveq #19,d5
	else
		moveq #39,d5
	endif
.line:
	tst.l (a1)
	bne.s .do_it
	tst.l 4(a1)
	beq .skip
.do_it:
	rept 2
		move (a0)+,d4
		swap d4
		move (a0)+,d2
		swap d2
		move (a0)+,d3
		swap d3
		move (a0)+,d1
		swap d1
	endr
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	swap d4
	swap d2
	eor d3,d4
	eor d1,d2
	eor d4,d3
	eor d2,d1
	eor d3,d4
	eor d1,d2
	swap d4
	swap d2
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	splice d2,d4,d0,d7,8
	move.l d4,-(a2)
	move.l d3,-(a2)
	moveq #0,d0
	move.l d2,-(a2)
	moveq #0,d7
	move.l d1,-(a2)
	move.b (a2)+,d7
	rept 7
		move.b (a2)+,d0
		move (a6,d7.w*2),(a3)+
		move.b (a2)+,d7
		move (a6,d0.w*2),(a3)+
	endr
	move.b (a2)+,d0
	move (a6,d7.w*2),(a3)+
	move (a6,d0.w*2),(a3)+
	clr.l (a1)+
	clr.l (a1)+
	bra.s .next
.skip:
	lea 32(a3),a3
	lea 16(a0),a0
	addq.l #8,a1
.next:
	dbf d5,.line
	add a5,a3
	if falc=0
		lea 320(a0),a0
		lea 160(a1),a1
		subq #2,d6
	else
		subq #1,d6
	endif
	bpl .again
	rts
.not_tc:
	if falc=0
		moveq #19,d5
	else
		moveq #39,d5
	endif
.nt_line:
	tst.l (a1)
	bne.s .nt_do_it
	tst.l 4(a1)
	beq .nt_skip
.nt_do_it:
	rept 2
		move (a0)+,d4
		swap d4
		move (a0)+,d2
		swap d2
		move (a0)+,d3
		swap d3
		move (a0)+,d1
		swap d1
	endr
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	swap d4
	swap d2
	eor d3,d4
	eor d1,d2
	eor d4,d3
	eor d2,d1
	eor d3,d4
	eor d1,d2
	swap d4
	swap d2
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	move.l d1,(a3)+
	splice d2,d4,d0,d7,8
	move.l d2,(a3)+
	move.l d3,(a3)+
	move.l d4,(a3)+
	clr.l (a1)+
	clr.l (a1)+
	bra.s .nt_next
.nt_skip:
	lea 16(a3),a3
	lea 16(a0),a0
	addq.l #8,a1
.nt_next:
	dbf d5,.nt_line
	add a5,a3
	if falc=0
		lea 320(a0),a0
		lea 160(a1),a1
		subq #2,d6
	else
		subq #1,d6
	endif
	bpl .not_tc
	rts
	
falc set falc+1

	endr

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
	muls.l #64000,d5		; minimum size
	move.l d5,max_fsize	; to load the whole animation
	move.l d0,sound_seek
	add.l #768,d0			; plus the palette
	add.l d5,d0				; plus the screens
	cmp.l total,d5
	bpl.s .bug				; not enough bytes!
	cmp.b #1,d3
	bne.s .long_fr
	moveq #0,d0
	move (a3)+,d0
	ror #8,d0
	bra.s .common
.long_fr:
	move.l (a3)+,d0
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
	move.l #768,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	rts
	
load_dl_screens:
	move.l buffer,a3
	move.l max_fsize,d5
	pea (a3)
	move.l d5,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12					; all screens loaded at once!
	tst.b is_tt
	bne.s .tt_planes
	rts
.tt_planes:
	lsr.l #4,d5						; number of times we've got 16 pixels
.pixels_16:
	movem.l (a3),d1-d4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	splice d2,d4,d0,d7,8
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	swap d2
	swap d4
	eor d1,d2
	eor d3,d4
	eor d2,d1
	eor d4,d3
	eor d1,d2
	eor d3,d4
	swap d2
	swap d4
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move d4,(a3)+
	swap d4
	move d2,(a3)+
	swap d2
	move d3,(a3)+
	swap d3
	move d1,(a3)+
	swap d1
	move d4,(a3)+
	move d2,(a3)+
	move d3,(a3)+
	move d1,(a3)+
	subq.l #1,d5
	bne .pixels_16
	rts
	
dl_frame_table:
	move.l s_buffer,a3
	move.l sample_num,d3
	cmp.l #'dl/1',comp_txt
	beq.s .lb0
.lb1:
	bsr.l read_word
	ror #8,d0						; intel!!
	move d0,(a3)+
	subq.l #1,d3
	bne.s .lb1
	rts
.lb0:
	bsr.l read_byte
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
	tst.b step_mode
	bne.s .step1
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
	move.l $4ba.w,current_time
.step1:
	tst.b is_tt
	beq.s .again
	tst.b switched
	bne.s .adapt		; if switched, center of the screen
	tst.b cmd_coord
	bne.s .again		; else, if coords, don't care about centering
.adapt:
	move max_imagey,d0
	lsr d0
	muls #320,d0
	sub.l d0,image					; as we double the height.
.again:
	move.l #cvid_fix1+4000,s_buffer_2	; my stack for loops
	move.l s_buffer,a3	; table of frames
	move.l sample_num,d7	; number of frames
	tst.b step_mode
	bne.s .step2
	move.l $4ba.w,start_time
.step2:
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
	bra .glop
.not_end:
	move.l (a0)+,a3
	move.l (a0)+,d7	
	bra .glop
.cmd2:
	cmp #$fffd,d0
	bne .glop
	move.l #$20002,-(sp)
	trap #13
	addq.l #4,sp
	bra .glop
.normal:
	move dl_i_per_s,d2
	divs d2,d0	; screen and index
	moveq #0,d1
	move d0,d1
	muls.l #64000,d1		; offset for that screen
	swap d0
	lea .offsets,a0
	cmp #16,d2
	bne.s .lb1
	lea 16(a0),a0
.lb1:
	add.l (a0,d0.w*4),d1	; address in that screen
	add.l buffer,d1		; absolute address in that screen
	bsr dl_copy_image
	addq.l #1,disp_frame
	tst.b step_mode
	beq.s .step3
.bug:
	bsr inc_frame
	beq.s .step_stop
	bpl.s .loop
	bsr save_frame
	bmi.s .bug
.loop:
	subq.l #1,d7
	bne .lb0
.step_stop:
	st stopped
	rts
.step3:
	move.l current_time,d0
.delay:
	cmp.l $4ba.w,d0
	bpl.s .delay
	add.l _delay,d0
	move.l d0,current_time
	btst #2,([kbshift])
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
.offsets: dc.l 0,160,32000,32160
.offsets2: dc.l 0,80,160,240,16000,16080,16160,16240
			  dc.l 32000,32080,32160,32240,48000,48080,48160,48240	


dl_copy_image:
	move.l d1,a1			; buffer
	move.l image,a0
	move screenw,d3
	move max_imagex,d4
	sub d4,d3				; screen inc for one line
	move #320,d5
	sub d4,d5				; buffer inc for one line
	move max_imagey,d6
	subq #1,d6				; for the loop
	tst.b is_tt
	bne.s dl_tt_double
	cmp #16,planes
	beq.s dl_tc
	lsr #2,d4				; 4 bytes at a time
	subq #1,d4				; for dbf
.line:
	move d4,d1
.pixels:
	move.l (a1)+,(a0)+
	dbf d1,.pixels
	add d3,a0
	add d5,a1
	dbf d6,.line
	rts
dl_tc:
	lea cvid_fix0,a6		; the palette
	add d3,d3				; one pixel = 2 bytes
	lsr #2,d4
	subq #1,d4				; 4 pixels at a time
	moveq #0,d0
.line:
	move d4,d1
.pixels:
	rept 4
		move.b (a1)+,d0
		move (a6,d0.w*2),(a0)+
	endr
	dbf d1,.pixels
	add d3,a0
	add d5,a1
	dbf d6,.line
	rts
dl_tt_double:
	lsr #4,d4
	subq #1,d4				; 16 pixels at a time
	lea 320(a0),a5			; next line
	add #320,d3
.line:
	move d4,d1
.pixels:
	movem.l (a1)+,d0/d2/a2/a4	; 16 bytes
	movem.l d0/d2/a2/a4,(a0)
	movem.l d0/d2/a2/a4,(a5)
	lea 16(a5),a5
	lea 16(a0),a0
	dbf d1,.pixels
	add d3,a0
	add d3,a5
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
	move.w #$003b,(a3)		; end of file forced
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
	bsr trans_index	; adds the transparency/restore extension if present
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
.net_loop: dc.b 0,0,0
.my_ext: dc.b $21,$ff,$0b,'M_PLAYER','FRM',$04
.my_frm: dc.b 0,0,0,0,0
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
	move.w #$003B,(a0)
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
	move.l a5,a6		; the next length
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
	st unknown				; a priori, pas de nombre d'images
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
	cmp.w #$21FF,(a3)+
	bne.s .end
	cmp.b #11,(a3)+		; application bloc?
	bne.s .end
	move.l (a3)+,d0
	or.l d1,d0
	cmp.l #'mpl',d0		; ID of application
	bne.s .other_id
	move.l (a3)+,d0
	or.l d1,d0
	cmp.l #'ayer',d0
	bne.s .end
	move.l (a3)+,d0
	lsr.l #8,d0
	or.l d1,d0
	cmp.l #' frm',d0		; frame infos?
	bne.s .end
	move.l (a3)+,d0			; everything OK, number of frames
	INTEL d0
	move.l d0,sample_num
	sf unknown				; nombre connu!
	bra.s .again
.other_id:
	cmp.l #'nets',d0
	bne.s .end
	move.l (a3)+,d0
	or.l d1,d0
	cmp.l #'cape',d0
	bne.s .end
	move.l (a3)+,d0
	lsr.l #8,d0
	or.l d1,d0
	cmp.l #' 2.0',d0
	bne.s .end
	addq.l #1,a3
	move (a3)+,d0
	ror #8,d0
	move d0,gif_repeat
.again:
	addq.l #1,a3			; skips the last '00'
	cmp.l d3,a3
	bmi.s .other_bloc
.end:
	st samp_sizes
	moveq #0,d0
	rts

_count_gif_frames:
	movem.l d0-d2/a0-a2,-(sp)
	bsr load_gif
	add #13,a2			; saute le header
	add.l gif_pal_size,a2	; et la palette
	moveq #0,d2			; nombre d'images
.loop:
	moveq #0,d0
	move.b (a2)+,d0
	cmp.b #$3b,d0
	beq.s .fin
	cmp.b #$21,d0
	beq.s .extens
	cmp.b #$2c,d0
	bne.s .autre
	addq.l #1,d2
	addq.l #8,a2	; saute x,y,w,h
	move.b (a2)+,d0	; masque de bits
	bpl.s .extens	; saute aussi le premier code LZW
	and.w #$07,d0
	moveq #2,d1
	lsl d0,d1
	muls #3,d1		; taille palette
	add.l d1,a2		; saute
.extens:
	addq.l #1,a2	; $21 + autre octet
.autre:
	cmp.l last_size,a2
	bpl.s .fin
	move.b (a2)+,d0
	beq.s .loop
	add d0,a2
	bra.s .autre
.fin:
	move.l d2,sample_num
	movem.l (sp)+,d0-d2/a0-a2
	rts
	
load_gif:
	tst.b gif_loaded
	bne.s .end
	st gif_loaded
	SEEK #0,0
	move.l buffer,-(sp)
	move.l total,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; read the whole file
	move.l buffer,a2
	move.l a2,a0
	add.l total,a0			; end_of_file
	move.w #$003B,(a0)
	move.l a0,last_size
.end:
	rts
	
gif_read_data:
	bsr.s load_gif
	tst.b step_mode
	bne.s .no_step1
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
.no_step1:
	sf smc_a				; first time, read palette
.again:
	move gif_repeat,_gif_rep
.gif_loop:
	clr.l disp_frame
	clr.l sample_num
	tst.b step_mode
	bne.s .no_step2
	move.l $4ba.w,start_time
.no_step2:
	move.l buffer,a6
;	move.l a6,a0
;	add.l total,a0			; end_of_file
;	move.w #$003B,(a0)
;	move.l a0,last_size
	moveq #0,d0
	move.b gif_flags,d0
	bset #15,d0
	lea 13(a6),a6		; start of global palette	
	bsr gif_palette
.frames:
	btst #2,([kbshift])
	bne .stop
	move.b (a6)+,d0	; code
	cmp.b #$3B,d0
	beq .end
	cmp.b #$2c,d0
	bne.s .lb0
	bsr gif_decode_frame
	move.l a5,a6		; the next length
	tst.b is_tt
	beq.s .coucou
	move gif_lines,a3		; number of lines
	move gif_start_line,d0	; start line
	move.l compression,a0
	jsr 16(a0)	
.coucou:
	tst.b step_mode
	beq.s .step3
.bug:
	bsr inc_frame
	beq.s .step_stop
	bpl.s .loop
	bsr save_frame
	bmi.s .bug
.loop:
	moveq #0,d0
.lb11:
	cmp.l last_size,a6
	bpl.s .step_stop
	move.b (a6)+,d0
	beq.s .frames		; 0, end of this part
	add d0,a6			; else, an offset
	bra.s .lb11			; other bloc
.step_stop:
	st stopped
	rts
.step3:	
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
	beq .frames		; 0, end of this part
	add d0,a6			; else, an offset
	bra.s .lb1			; other bloc
.end:	
	st smc_a			; if next time, don't read palette
	tst.b step_mode
	bne.s .step_stop
	subq #1,_gif_rep
	beq.s .another
	btst #0,([kbshift])	; shift with loop mode? to stop!
	bne.s .normal_out
	btst #1,([kbshift])
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
	sf gif_trans			; only for one image
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
	move.b (a1,d0.w),(a0)+
	move.w (a2,d0.w*2),d0
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
	move d2,(a2,d5.w*2)
	move.b old_token(pc),(a1,d5.w)
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
	move (a6)+,d0
	move (a6)+,d1
	ror #8,d1
	move d1,gif_start_line
	muls screenw,d1
	ror #8,d0
	add.l d0,d1			; offset from start of image in screen
	move (a6)+,d0
	ror #8,d0
	move d0,gif_rows
	neg d0
	move screenw,d2
	add d2,d0		; row inc
	cmp #16,planes
	bmi.s .lb0
	add.l d1,d1
	add d0,d0
	add d2,d2	
.lb0:
	add.l image,d1
	move.l d1,gif_image
	move.l d1,gif_image_sav	; when interlaced
	move d0,gif_inc
	move d2,gif_one_line
	move (a6)+,d0
	ror #8,d0
	move d0,gif_lines
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
	cmp #16,planes
	bne .not_tc
	move.l pal_adr,a6		; palette
	moveq #0,d1
	tst.b gif_trans
	beq.s .lb0
	move.b gif_trans_index,d2
.lb0t:
	move.b (a0)+,d1
	cmp.b d2,d1
	bne.s .lb1t
	addq.l #2,a1		; skips	
	dbf d0,.lb0t
	bra.s .exit
.lb1t:
	move (a6,d1.w*2),(a1)+
	dbf d0,.lb0t
	bra.s .exit
.lb0:
	move.b (a0)+,d1
	move (a6,d1.w*2),(a1)+
	dbf d0,.lb0
.exit:
	add gif_inc,a1
	tst.b gif_interlace
	beq.s .not_inter
	move gif_one_line,d0
	move gif_pass,d1
	and #$3,d1
	lea (.gif_table,d1.w*4),a0
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
	move.b d1,(a1)+
	dbf d0,.nt1
	bra .exit
.nt0:
	move.b (a0)+,(a1)+
	dbf d0,.nt0
	bra .exit
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
	lea (a6,d1.w),a5	; next bloc	
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
	tst.b step_mode
	bne.s .end				; ni avec la conversion
	moveq #0,d0
	move 2(a6),d0
	ror #8,d0
	add.l d0,d0
	add.l $4ba.w,d0		; end of time
.lb0:
	cmp.l $4ba.w,d0
	bpl.s .lb0				; not ended
.end:
	btst #0,1(a6)			; transparency?
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
	cmp #8,planes
	beq.s .not_tc
	bsr.l fli_color_256
	bra.s .end
.not_tc:
	bsr.l fli_color_256_256
.end:
	move.l (sp)+,a6
	rts
	
exit_menu:
	moveq #0,d0
	bra.s _menu
redraw_menu:
	moveq #1,d0
_menu:
	tst.b mountain
	bne.s .lb1
	tst.b cmd_coord
	bne.s .lb1				; if coords, don't erase upper line
	tst.b slide_flag
	bne.s .lb1
	tst.b acc
	bne.s .lb0				; no menu with an ACC
	move d0,mb_int
	GEM_AES menu_bar		; redraws the upper line
	bra.s .lb1
.lb0:
	move.l menu_buffer,a0
	move.l menu_len,d0
	move.l old_screen,a1
	asr.l #2,d0
	subq.l #1,d0
.lb2:
	move.l (a0)+,(a1)+
	subq.l #1,d0
	bpl.s .lb2
.lb1:
	rts
	
save_menu:
	moveq #1,d0
	add work_out,d0		; pixels per line
	muls planes,d0			; bits per line
	asr.l #3,d0				; bytes per line
	moveq #2,d1
	add boxh,d1				; menu height
	muls.l d0,d1			; size of the menu
	move.l d1,menu_len
	bsr.l malloc
	move.l d0,menu_buffer
	move.l d0,a0
	move.l old_screen,a1
	move.l menu_len,d0
	asr.l #2,d0
	subq.l #1,d0
.lb0:
	move.l (a1)+,(a0)+
	subq.l #1,d0
	bpl.s .lb0
	rts

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
	sf cram_bits			; 0 if ST Low
	cmp.l (a3)+,d0
	beq.s .ok_st_low
	move.l #'VFAL',d0
	st cram_bits
	cmp.l -4(a3),d0
	bne.s .bug	
.ok_st_low
	cmp.w #'10',(a3)+
	bne.s .bug
	move.l d0,comp_txt
	move (a3)+,d0
	ext.l d0
	move.l d0,sample_num
	move #160,max_imagex
	move #100,max_imagey
	move.l #8032,d0
	tst.b cram_bits
	beq.s .st_low
	move.l #17024,d0
.st_low:
	move.l d0,max_fsize
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
	tst.b step_mode
	bne.s .disp_again
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
.disp_again:
	clr.l disp_frame
	bsr v_new_palette
	SEEK #32,0				; start of first frame (with palette)
	tst.b step_mode
	bne.s .again
	tst.b playing
	beq.s .nosound
	bsr.l flm_start_sound
.nosound:
	move.l $4ba.w,d0
	move.l d0,start_time
	add.l d0,d0
	add.l d0,d0
	move.l d0,current_time
.again:	
	move.l max_fsize,d4		; size to load
	move.l buffer,-(sp)
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d4,d0
	bne .exit
	move.l buffer,a0
	tst.b cram_bits
	bne.s .fal
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
	bra.s .timing
.fal:
	bsr vfal_get_palette
	bsr vfal_aff_image
.timing:
	tst.b step_mode
	beq.s .no_step
.bug:
	bsr inc_frame
	beq.s .step_stop
	bpl.s .loop
	bsr save_frame
	bmi.s .bug
.loop:
	move.l sample_num,d0
	addq.l #1,disp_frame
	cmp.l disp_frame,d0
	bne .again
.step_stop:
	st stopped
	rts
.no_step:
	move.l current_time,d0	; in 1/800
	add.l _delay,d0
	move.l d0,current_time
	lsr.l #2,d0					; back to 1/200
.delay:
	cmp.l $4ba.w,d0
	bpl.s .delay
	move.l sample_num,d0
	addq.l #1,disp_frame
	cmp.l disp_frame,d0
	beq.s .exit
	btst #2,([kbshift])
	bne.s .stop
	bra .again
.exit:
	tst.b playing
	beq.s .no_sound_end
	tst.b snd_value
	bpl.s .yamaha
	btst #0,$ffff8901.w
	beq.s .no_sound_end
	bra.s .test_control
.yamaha:
	tst.b yamaha_flag
	beq.s .no_sound_end
.test_control:
	btst #2,([kbshift])
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
	tst.b snd_value
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

v_new_palette:
	lea cvid_fix0,a0
	tst.b cram_bits
	bne.s .fal
	moveq #63,d0
.new:
	st (a0)+
	dbf d0,.new		; new palette forced
	rts
.fal:
	move #255,d0
.new_pal:
	st (a0)			; the normal palette has always 0 here
	addq.l #4,a0	; and so $FF is different!
	dbf d0,.new_pal
	rts
	

vmas_aff_image:
	move.l buffer,a0
	add.w #32,a0
	cmp #8,planes
	bpl _buf_to_tc_256	; on a graphic card or Falcon TC
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

vfal_get_palette:
	lea cvid_fix0,a6
	move #255,d0			; loop
	cmp #16,planes
	bne .not_tc
	tst.b nova
	bne.s .nova
.couleur:
	move.w (a0)+,d1
	lsl #5,d1
	move.b (a0)+,d1
	lsl.l #6,d1
	move.b (a0)+,d1
	lsr.l #3,d1
	move d1,(a6)+
	dbf d0,.couleur
	rts
.nova:
	move.w (a0)+,d1
	lsl #5,d1
	move.b (a0)+,d1
	lsl.l #5,d1
	move.b (a0)+,d1
	lsr.l #3,d1
	ror #8,d1
	move d1,(a6)+
	dbf d0,.nova
	rts
.not_tc:
	tst.b is_tt
	bne.s .tt_pal
	move.l a0,a3
	lea indexs,a4
	move d0,d7
.vdi_pal:
	move.l (a3)+,d0		; one color
	cmp.l (a6)+,d0
	beq.s .skip_vdi
	move.l d0,-4(a6)		; new color
	lea vs_int,a0
	move (a4),(a0)+		; index
	swap d0
	lsl #2,d0
	move d0,(a0)+
	swap d0	
	move d0,d1
	lsr #6,d1
	move d1,(a0)+
	ror #8,d0
	lsr #6,d0
	move d0,(a0)
	GEM_VDI vs_color
.skip_vdi:
	addq.l #2,a4
	dbf d7,.vdi_pal
	rts
.tt_pal:
	move (a0)+,d1
	lsl #4,d1
	move.b (a0)+,d1
	lsl #4,d1
	move.b (a0)+,d1
	lsr #4,d1
	move d1,(a6)+
	dbf d0,.tt_pal
	pea -512(a6)
	move #256,-(sp)
	clr -(sp)
	XBIOS 84,10
	rts
	
vfal_aff_image:
	move.l buffer,a1
	add #1024,a1
	moveq #99,d5	; H
	move screenw,a5
	sub #160,a5		; inc
	tst.b is_tt
	bne .tt_256
	move.l image,a0
	cmp #16,planes
	bne .not_tc
	lea cvid_fix0,a6
	add a5,a5
.again:
	moveq #9,d6		; 10 times 16 pixels
.line:
	rept 2
		move (a1)+,d4
		swap d4
		move (a1)+,d2
		swap d2
		move (a1)+,d3
		swap d3
		move (a1)+,d1
		swap d1
	endr
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	swap d4
	swap d2
	eor d3,d4
	eor d1,d2
	eor d4,d3
	eor d2,d1
	eor d3,d4
	eor d1,d2
	swap d4
	swap d2
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	splice d2,d4,d0,d7,8
	move.l d4,-(a1)
	move.l d3,-(a1)
	moveq #0,d0
	move.l d2,-(a1)
	moveq #0,d7
	move.l d1,-(a1)
	move.b (a1)+,d7
	rept 7
		move.b (a1)+,d0
		move (a6,d7.w*2),(a0)+
		move.b (a1)+,d7
		move (a6,d0.w*2),(a0)+
	endr
	move.b (a1)+,d0
	move (a6,d7.w*2),(a0)+
	move (a6,d0.w*2),(a0)+
	dbf d6,.line			
	add a5,a0
	dbf d5,.again
	rts
.not_tc:
	moveq #9,d6
.nt_line:
	rept 2
		move (a1)+,d4
		swap d4
		move (a1)+,d2
		swap d2
		move (a1)+,d3
		swap d3
		move (a1)+,d1
		swap d1
	endr	
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	swap d4
	swap d2
	eor d3,d4
	eor d1,d2
	eor d4,d3
	eor d2,d1
	eor d3,d4
	eor d1,d2
	swap d4
	swap d2
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	move.l d1,(a0)+
	splice d2,d4,d0,d7,8	
	move.l d2,(a0)+
	move.l d3,(a0)+
	move.l d4,(a0)+
	dbf d6,.nt_line			
	add a5,a0
	dbf d5,.not_tc
	rts
.tt_256:
	move.l a1,a0
	move d5,a2
	move.l physbase,a3
	add.l #44880,a3		; start in screen memory
	lea 320(a3),a5			; double the lines
	move #32,a4
	move #512,a1
.other_line:
	rept 4
	movem.l (a0)+,d0-d7
	movem.l d0-d7,(a3)
	movem.l d0-d7,(a5)
	add a4,a3
	add a4,a5
	endr
	movem.l (a0)+,d0-d7
	movem.l d0-d7,(a3)
	movem.l d0-d7,(a5)
	add a1,a3
	add a1,a5
	subq #1,a2
	cmp #0,a2
	bne .other_line
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
	lea real_freq,a0
	sf (a0)
	move.l (a0),d6
	tst.b snd_value
	bmi.s .dma
	move.l #9600,d6		; other sound hardware
.dma:
	move.l #12517,frequency
	muls d6,d1
	muls d6,d0
	divs d7,d0
	ext.l d0
	add.l d0,d1						; dest size of the sound
	move.l d1,snd_size
	addq.l #8,d1					; security
	clr -(sp)
	move.l d1,-(sp)
	GEMDOS 68,8
	move.l d0,snd_temp
	bgt.s .ok
.end:
	rts								; no sound loaded...
.ok:
	move.l d0,a6					; sound ptr
	move #3,-(sp)
	move.l #32768,-(sp)
	GEMDOS 68,8						; temporary buffer
	move.l d0,a5
	tst.l d0
	bmi.s .end
	beq.s .end
	movem.l d5-d7,-(sp)
	moveq #1,d6
	moveq #1,d7
	bsr.l manage_tree				; loading sound...
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
	tst.b snd_value
	bmi.s .no_stop_byte
	clr.b -1(a6)		; end of sound
.no_stop_byte:
	move.l a6,flm_snd_end
	move.l a5,a2
	bsr.l mfree
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
	bsr.l manage_tree
	rts		

vmas_treat_sound:
	lea 0(a3,d4.l),a0	; end of source
	moveq #0,d2
	moveq #0,d3			; with DMA, 0=0
	tst.b snd_value
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
	bne.s .lb2
	move.b d3,d0
	bra.s .lb2
	
add_version_number:
	move.l 36(a0),a0		; ob spec of object 1= tedinfo
	move.l (a0),a0			; string address
.lb0:
	tst.b (a0)+
	bne.s .lb0				; look for end of string (V*.** + '0')
	move.l #VERSION,-5(a0)	; replace *.** with current version number
	rts

bat_degas:
	tst.b create_mov
	bne.s .create_flm
	tst.b bat_getp
	beq.s .no_pal
	bsr v_new_palette
	move.l buffer,a0
	addq.l #2,a0
	bsr kin_read_palette
.no_pal:
	move.l buffer,a0
	add.l neo_degas_offs,a0					; skips the palette
	tst.b is_tt
	bne.s .tt_direct
	bsr _buf_to_tc_256
	rts	
.tt_direct:
	move.l physbase,a3				; the screen
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
		lea .grey_palette(pc),a2
		.loop_col:
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
			dbf d0,.loop_col
	endif			
.out:
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
	lea $ffff8240.w,a2		; palette
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
	addq.l #1,flm_header+12	; number of frames strored
	move.l flm_frame,a0
	addq.l #1,d0
	bclr #0,d0
	move.l d0,(a0)
	cmp.l #28,d0
	bne.s .lb3
	move.l #-1,20(a0)
.lb3:
	lea flm_header+8(pc),a1
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
.grey_palette:
	dc.w $000,$888,$111,$999,$222,$aaa,$333,$bbb
	dc.w $444,$ccc,$555,$ddd,$666,$eee,$777,$fff
	
complete_flm_file:
	move #1,-(sp)
	move mov_h2,-(sp)
	clr.l -(sp)
	GEMDOS 66,10
	lea flm_header,a3
	move.l d0,(a3)			; size of the file
	clr -(sp)
	move mov_h2,-(sp)
	clr.l -(sp)
	GEMDOS 66,10			; start of file
	moveq #100,d0
	tst.l 4(a3)				; no snd ext?
	beq.s .no_ext
	moveq #114,d0			; if extension, 14 bytes more
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

init_create_degas:
	pea degas_text
	GEMDOS 9,6
	tst.l frequency
	bne.s .next
	st bad_sound
.next:
	tst.b bad_sound
	bne .create_degas		; no sound alignment
	move.l sample_num,d1
	muls.l frequency,d1
	move.l d1,degas_div
	move.l snd_size,d2
	moveq #100,d0
	cmp #2,channels
	beq.s .ok1
	add.l d0,d0
.ok1:
	muls.l d0,d2
	divsl.l d1,d0:d2
	lea degas_r(pc),a1
	move.l d0,(a1)+
	move.l d2,(a1)
.create_degas:
	move.l #32000,d1		; point d'entree
	bsr.l malloc
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
	bsr.l malloc
	move.l d0,flm_frame
	move.l d0,a0
	clr.l (a0)			; size of frame (if 0: first frame!)
	clr -(sp)
	pea out_file
	GEMDOS 60,8
	tst.l d0
	bgt .end
	lea cant_create,a0
	bra.l ooops
.end:
	move d0,mov_h2
	lea flm_header(pc),a0
	clr.l 4(a0)				; extra datas reset
	clr.l 8(a0)				; max_fsize reset
	clr.l 12(a0)			; number of frames reset
	lea .degas(pc),a1
	cmp.l #"dega",comp_txt
	beq.s .ok_info
	addq.l #5,a1
.ok_info:
	move.l (a1)+,25(a0)	; writes Degas or *.NEO
	move.b (a1),29(a0)
	pea (a0)
	moveq #100,d3
	move.l d3,-(sp)
	move d0,-(sp)
	GEMDOS 64,12	; writes the header (not filled)
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
.degas: dc.b "Degas"
	dc.b "*.NEO"

	even

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

flm_snd_ext:
	lea flm_snd,a0
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
		
flm_header:
	dc.l 0		; file size
	dc.l 0		; extra datas
	dc.l 0		; max f size
	dc.l 0		; number of frames
	dc.b "M_Player Degas-->Extended FLM",0,0,0
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


mvi_read_header:
	SEEK #0,0
	moveq #32,d3
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
	move.l (a3),d0
	lsr.l #8,d0
	cmp.l #$00070402,d0
	bne.s .bug
	addq.l #3,a3
	move.l (a3)+,d0
	INTEL d0
	move.l d0,sample_num
	move.l (a3)+,d0
	INTEL d0
	divs.l #5000,d0			; number of 1/200
	move.l d0,_delay
	move (a3)+,d0
	ror #8,d0
	move d0,max_imagex
	move (a3)+,d0
	ror #8,d0
	move d0,max_imagey
	st bad_comp
	st samp_sizes
	move.l #"mvi ",comp_txt
	move #8,sound_bits
	move #1,channels
	moveq #0,d0
	addq.l #1,a3
	move (a3)+,d0
	ror #8,d0
	move.l d0,frequency
	move.l (a3),d0
	INTEL d0
	move.l d0,snd_size
	move.l d0,mvi_save_size
	move.l d0,d3
	move.l sample_num,d1
	move.l d1,d2
	lsr.l #1,d2		; half
	add.l d2,d0
	divs.l d1,d0	; rounded: number of bytes for one frame
	muls.l d0,d1	
	sub.l d1,d3		; the remainder
	move.b d3,mvi_rem
	addq.l #5,d0	; plus offset
	move.l d0,mvi_next_size
	move.l #'rawa',s_signe
	moveq #0,d0
	rts
		
mvi_read_data:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
	moveq #0,d3				; sync flags
	tst.l s_buffer_2
	beq.s .s2
	bset #8,d3
.s2:
	bsr.l start_sound
.no_sound:
	move.l $4ba.w,start_time	; Timer C
.lb0:
	btst #2,([kbshift])
	bne.s .stop						; control? so quit!
	btst #8,d3
	beq.s .no_remain
	tst.b snd_value
	bmi.s .dma_remain
	tst.b yamaha_flag
	bne.s .lb0
	bsr.l yamaha_next_sound
	bra.s .lb0
.dma_remain:
	btst #0,$ffff8901.w
	bne.s .lb0
	bsr.l next_sound
	bra.s .lb0
.no_remain:
	tst.b snd_value
	bmi.s .dma_quit
	tst.b yamaha_flag
	bne.s .lb0
	bra.s .quit
.dma_quit:
	btst #0,$ffff8901.w
	bne.s .lb0
	bra.s .quit
.stop:
	st stopped
.quit:
	tst.b snd_value
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
	muls.l #50,d5:d0
	move.l #12517,d2
	move.l d2,frequency
	lsr.l #2,d2
	muls.l sample_num,d2
	divs.l d2,d5:d0
	move.l d0,d6
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
	move.l sample_num,d0
	muls #6258,d0
	divs.l d1,d2:d0
	lea cd_acc+8,a0
	move d0,(a0)+			; integer
	move.l d2,(a0)+		; remainder
	move.l d1,(a0)			; remainder limit
.exit:	
	addq.l #2,a3			; skips 13,10
	sub.l #cvid_fix0,a3	; number of bytes for header
	move.l a3,sound_seek
	cmp.l #'CDV1',comp_txt
	bne.s .no_iff
	bsr cd_read_iff_pal	
.no_iff:
	tst.b bad_comp
	beq.s .exit_exit
	move.l #cd_nul,compression
.exit_exit:
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

cd_read_iff_pal:
	move.l fname_pos,a0
.lb1:
	move.b (a0)+,d0		; one character of the name
	beq.s .lb2				; end reached, no extension
	cmp.b #'.',d0
	bne.s .lb1
.lb2:
	subq.l #2,a0
	move.b #'1',(a0)+		; xxxx1.IFF
	move.l #'.IFF',(a0)+	; new extension
	clr.b (a0)				; end of string
	clr -(sp)
	pea full2				; tries to open IFF file
	GEMDOS 61,8				; fopen 
	move d0,d7				; handle of the file is saved
	bmi.s .bug
	lea cvid_fix1,a3
.loop:
	move.l a3,-(sp)
	moveq #8,d0
	move.l d0,-(sp)
	move d7,-(sp)
	GEMDOS 63,12
	move.l (a3),d0			; id
	move.l 4(a3),d1		; size
	cmp.l #'FORM',d0
	bne.s .id2
	moveq #4,d1				; skip
	bra.s .skip
.id2:
	cmp.l #'BODY',d0
	beq.s .close_bug		; if BODY, then CMAP not found!!!
	cmp.l #'CMAP',d0
	beq.s .found_pal
.skip:
	move #1,-(sp)
	move d7,-(sp)
	move.l d1,-(sp)
	GEMDOS 66,10			; fseek D1 bytes
	tst.l d0
	bmi.s .close_bug
	bra.s .loop
.found_pal:
	move.l #$01000000,(a3)+	; one bloc, 256 colors
	move.l a3,-(sp)
	move.l d1,-(sp)		; size of CMAP
	move d7,-(sp)
	GEMDOS 63,12
	move d7,-(sp)
	GEMDOS 62,4
	rts
.close_bug:
	move d7,-(sp)
	GEMDOS 62,4
.bug:
	st bad_comp
	rts

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
	bsr tt_calc_image
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
	cmp.l #'CDH1',comp_txt
	bne.s .disp_again
	tst.b is_tt
	beq.s .other
	clr $ffff8240.w
	move #$FFF,$ffff8242.w
	bra.s .disp_again
.other:
	lea vs_int,a3
	clr.l (a3)+
	clr.l (a3)+
	GEM_VDI vs_color
	move #1000,d0
	move d0,-(a3)
	move d0,-(a3)
	move d0,-(a3)
	moveq #1,d0
	move d0,-(a3)
	GEM_VDI vs_color
.disp_again:
	clr.l disp_frame
	clr.l gif_image
	move.l snd_size,cd_sound_count
	bsr cd_sound_size
	add.l #40,d0
	SEEK d0,0				; start of data
	lea cd_acc,a0
	clr.l (a0)+
	clr (a0)
	bsr cd_calc_loops
	tst.b playing
	beq.s .nosound
	bsr.l flm_start_sound
.nosound:
	move.l $4ba.w,d0
	move.l d0,start_time
	move.l d0,current_time
	clr.l cd_delay_acc
.again:	
	tst.l frequency
	beq.s .no_sound_skip
	cmp.l #1,gif_image
	beq.s .skip
	subq.w #1,cd_acc+6
	bpl.s .no_sound_skip
	bsr cd_calc_loops		
.skip:
	bsr cd_sound_size
	SEEK d0,1			; relative skip
.no_sound_skip:	
	move.l max_fsize,d4		; size to load
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
	tst.b sync
	bne.s .ok
	move.l $4ba.w,d1	; false_time
	addq.l #2,d1		; + 1/100
.ok:
	move.l d1,(a0)
	addq.l #1,gif_image
	cmp.l $4ba.w,d1
	bpl.s .aff
	SEEK d4,1
	bra.s .no_timing
.aff:
	move.l buffer_16,-(sp)
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d4,d0
	bne.s .exit
	move.l compression,a0
	jsr (a0)
	addq.l #1,disp_frame
	move.l current_time,d1	
.delay:
	cmp.l $4ba.w,d1
	bpl.s .delay
.no_timing:
	move.l sample_num,d0
	cmp.l gif_image,d0
	beq.s .exit
	btst #2,([kbshift])
	bne.s .stop
	bra .again
.exit:
	tst.b playing
	beq.s .no_sound_end
	tst.b snd_value
	bpl.s .yamaha
	btst #0,$ffff8901.w
	beq.s .no_sound_end
	bra.s .test_control
.yamaha:
	tst.b yamaha_flag
	beq.s .no_sound_end
.test_control:
	btst #2,([kbshift])
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
	tst.b snd_value
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
	bsr.l flm_start_sound
.exit:
	tst.b playing
	beq.s .normal_out
	tst.b snd_value
	bpl.s .yamaha
	btst #0,$ffff8901.w
	beq.s .normal_out
	bra.s .test_control
.yamaha:
	tst.b yamaha_flag
	beq.s .normal_out
.test_control:
	btst #2,([kbshift])
	beq.s .exit
	st stopped
.normal_out:
	tst.b playing
	beq.s .no_stop_sound
	tst.b snd_value
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



tt_calc_image:
	tst.b is_tt
	bne.s .ok
	rts
.ok:
	move max_imagex,d0
	move max_imagey,d1
	lea .data(pc),a0
	move.l comp_txt,d2
	cmp.l #'CDH1',d2
	beq.s .found
	addq.l #8,a0
	cmp.l #'CDL1',d2
	beq.s .found
	addq.l #8,a0
.found:
	move (a0)+,d3		; height
	muls (a0)+,d1		; double?
	sub d1,d3
	lsr #1,d3
	move (a0)+,d1		; width
	muls d1,d3			; complete lines
	sub d0,d1
	lsr #1,d1
	add #15,d1
	and #$fff0,d1
	ext.l d1
	add.l d1,d3			; upper left in pixels
	move (a0)+,d0		; shifts
	lsr.l d0,d3
	add.l physbase,d3
	move.l d3,image
	rts
.data: dc.w 400,1,640,3,200,1,320,1,480,2,320,0
	
cdh1_aff:
	move.l buffer_16,a0
	tst.b is_tt
	beq.s .lb2
	move.l image,a3
	move #640,d3
	move max_imagex,d2
	add #15,d2
	and #$fff0,d2
	sub d2,d3
	lsr #3,d3
	lsr #4,d2
	subq #1,d2
	move max_imagey,d4
	subq #1,d4
.line:
	move d2,d1
.pixel:
	move (a0)+,(a3)+
	dbf d1,.pixel
	add d3,a3
	dbf d4,.line
	rts	
.lb2:
	move.l a0,a2
	cmp #16,planes
	bne.s .lb0
	bra.l qt_raw1+6
.lb0:
	cmp #8,planes
	bne.s .lb1
	bra.l qt_raw1_256+6
.lb1:	
	rts
	
cdl1_aff:
	move.l buffer_16,a0
	tst.b is_tt
	beq _buf_to_tc_256
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
	move.l buffer_16,a0
	move.l image,a3
	move screenw,d3
	tst.b is_tt
	bne cdv1_tt
	sub max_imagex,d3
	move max_imagey,d6
	subq #1,d6
	cmp #16,planes
	bne .not_tc
	lea cvid_fix0,a6
	add d3,d3
	move d3,a5
.again:
	move max_imagex,d5
	add #15,d5
	lsr #4,d5
	subq #1,d5
.line:
	rept 2
		move (a0)+,d4
		swap d4
		move (a0)+,d2
		swap d2
		move (a0)+,d3
		swap d3
		move (a0)+,d1
		swap d1
	endr
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	swap d4
	swap d2
	eor d3,d4
	eor d1,d2
	eor d4,d3
	eor d2,d1
	eor d3,d4
	eor d1,d2
	swap d4
	swap d2
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	splice d2,d4,d0,d7,8
	move.l d4,-(a0)
	move.l d3,-(a0)
	moveq #0,d0
	move.l d2,-(a0)
	moveq #0,d7
	move.l d1,-(a0)
	move.b (a0)+,d7
	rept 7
		move.b (a0)+,d0
		move (a6,d7.w*2),(a3)+
		move.b (a0)+,d7
		move (a6,d0.w*2),(a3)+
	endr
	move.b (a0)+,d0
	move (a6,d7.w*2),(a3)+
	move (a6,d0.w*2),(a3)+
	dbf d5,.line
	add a5,a3
	dbf d6,.again
	rts
.not_tc:
	move d3,a5
.tc_again:
	move max_imagex,d5
	add #15,d5
	lsr #4,d5
	subq #1,d5
.tc_line:
	rept 2
		move (a0)+,d4
		swap d4
		move (a0)+,d2
		swap d2
		move (a0)+,d3
		swap d3
		move (a0)+,d1
		swap d1
	endr
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	swap d4
	swap d2
	eor d3,d4
	eor d1,d2
	eor d4,d3
	eor d2,d1
	eor d3,d4
	eor d1,d2
	swap d4
	swap d2
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	move.l d1,(a3)+
	splice d2,d4,d0,d7,8
	move.l d2,(a3)+
	move.l d3,(a3)+
	move.l d4,(a3)+
	dbf d5,.tc_line
	add a5,a3
	dbf d6,.tc_again
	rts
cdv1_tt:
	move max_imagex,d2
	add #15,d2
	and #$fff0,d2
	add d3,d3
	sub d2,d3
	lsr #4,d2
	subq #1,d2
	move max_imagey,d4
	subq #1,d4
.line:
	move d2,d1
	lea 320(a3),a1		; second line
.pixel:
	movem.l (a0)+,d5-d7/a2
	movem.l d5-d7/a2,(a3)
	lea 16(a3),a3
	movem.l d5-d7/a2,(a1)
	lea 16(a1),a1
	dbf d1,.pixel
	add d3,a3
	dbf d4,.line
	rts		

cd_read_sound:
	sf playing
	tst.b bad_sound
	bne .end				; bad sound any_way
	tst.l frequency
	beq .end				; no sound!
	move.l snd_size,d7
	tst.b snd_value
	bmi.s .dma1
	move.l d7,d0
	move.l d0,d1
	lsl.l #3,d1
	add.l d1,d0
	add.l d1,d1
	add.l d1,d0			; x 25
	lsr.l #5,d0			; /32 ~ x.78 (>9600/12516)
	add.l #2000,d0		; security (6258 > 4800)
	move #3,-(sp)		; TT Ram is better (cause faster!)
	move.l d0,-(sp)
	bra.s .no_dma	
.dma1:
	clr -(sp)				; ST ram only
	move.l d7,-(sp)
.no_dma:
	GEMDOS $44,8			; mxalloc
	tst.l d0
	bmi .end				; alloc error
	beq .end
	move.l d0,snd_temp
	move.l d0,d6
	movem.l d6-d7,-(sp)
	moveq #1,d6
	moveq #1,d7
	bsr.l manage_tree
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
	move.l max_fsize,d1
	muls.l d0,d1
	SEEK d1,1
	bsr cd_calc_loops		
	addq #1,cd_acc+6
	bsr .load_one
	tst.l d7
	bne.s .loop
.exit:
	moveq #1,d6
	moveq #-1,d7
	bsr.l manage_tree
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
	tst.b snd_value
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

TAB_AUDIO_DVI_PAS:
 DC.W     7,    8,    9,   10,   11,   12,   13,   14,   16,   17
 DC.W    19,   21,   23,   25,   28,   31,   34,   37,   41,   45
 DC.W    50,   55,   60,   66,   73,   80,   88,   97,  107,  118
 DC.W   130,  143,  157,  173,  190,  209,  230,  253,  279,  307
 DC.W   337,  371,  408,  449,  494,  544,  598,  658,  724,  796
 DC.W   876,  963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066
 DC.W  2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358
 DC.W  5894, 6484, 7132, 7845, 8630, 9493,10442,11487,12635,13899
 DC.W 15289,16818,18500,20350,22385,24623,27086,29794,32767

cache_sav: dc.l 0

cache_off:
	movem.l d0-d2/a0-a2,-(sp)
	pea invalid_cache(pc)
	XBIOS 38,6
	movem.l (sp)+,d0-d2/a0-a2
	rts
invalid_cache:
	movec CACR,d0
	move.l d0,cache_sav
	cmp #40,cpu_value+2
	bpl.s .hades
	ori #$0808,d0
	movec d0,CACR
	rts
.hades:
	movec CACR,d0
	and.l #$6FFF7FFF,d0
	movec d0,CACR	
	rts

cache_on:
	movem.l d0-d2/a0-a2,-(sp)
	pea restore_cache(pc)
	XBIOS 38,6
	movem.l (sp)+,d0-d2/a0-a2
	rts	
restore_cache:
	move.l cache_sav(pc),d0
	movec d0,CACR
	rts
	
INIT_TAB_IMA4:
	MOVEM.L D0-D4/A0-A1,-(SP)
   LEA TAB_AUDIO_DVI_PAS(pc),A0
   LEA DVI_DELTA,A1
   MOVE #88,D2
.lb1:
	MOVEQ #0,D4;delta
   MOVEQ #15,D3
.lb2:
   MOVE (A0),D1
   MOVEQ #0,D0
   BTST #2,D4
   BEQ.S .lb3
   ADD D1,D0;+ pas
.lb3:
   LSR #1,D1
   BTST #1,D4
   BEQ.S .lb4
   ADD D1,D0;+ 1/2 pas
.lb4:
   LSR #1,D1
   BTST #0,D4
   BEQ.S .lb5
   ADD D1,D0;+ 1/4 pas
.lb5:
   LSR #1,D1
   ADD D1,D0;+ 1/8 pas
   BTST #3,D4;signe
   BEQ.S .lb6;positif
   NEG D0
.lb6:
   MOVE D0,(A1)+
   addq #1,D4
   DBRA D3,.lb2
   ADDQ #2,A0
   DBRA D2,.lb1
   MOVEM.L (SP)+,D0-D4/A0-A1
   RTS

TAB_AUDIO_DVI_INDEX:
 DC.W -1,-1,-1,-1,2,4,6,8
 DC.W -1,-1,-1,-1,2,4,6,8

DECOMPRESS_IMA4:
	; A4 cible 16 bits
	; A2 compresse
	; d6 taille compressee
	;D1.W:mode avec B0: mono(0)/st‚r‚o(1)
	;  B1: 8 bits (0)/16 bits(1)
	;  B2: deltapack_ima4
	;au retour dans D0.L: longueur

   BTST #2,D1;mode: B0: mono(0)/st‚r‚o(1), B1: 8 bits(0)/16 bits(1)
			;  B2: deltapack ima4/dvi, B3:deltapack adpcm, B4:ulaw
   BEQ .lb1
   BTST #1,D1		;8 bits (0)/16 bits(1)
   BEQ .lb1
   MOVEM.L D1-A5,-(SP)
   MOVE.L A4,-(SP)
   MOVE D1,-(SP)							;mode
   LEA TAB_AUDIO_DVI_INDEX(pc),A0
   LEA DVI_DELTA,A1
   MOVE.L A2,A3							;buffer voie gauche
   LEA 0,A5									;compteur bloc
   MOVE.L d6,D7
   BLE .lb8
   ADD #$22,A3								;buffer voie droite ‚ventuelle
.lb6:
	MOVE (A2)+,D0
   SUBQ.L #2,D7
   MOVE D0,D4
   AND #$7F,D4								;index voie gauche
   CMP #88,D4
   BLS.S .lb3
   MOVE #88,D4
.lb3:
   AND #$FF80,D0
   MOVE D0,D2								;‚chantillon voie gauche
   BTST #0,1(SP)							;mono(0)/st‚r‚o(1)
   BEQ.S .lb9								;mono
   MOVE (A3)+,D0
   SUBQ.L #2,D7
   MOVE D0,D5
   AND #$7F,D5								;index voie droite
   CMP #88,D5
   BLS.S .lb2
   MOVE #88,D5
.lb2:
   AND #$FF80,D0
   MOVE D0,D3								;‚chantillon voie droite
.lb9:
   MOVE #$22-2,A5							;taille bloc -> compteur bloc
.lb4:
   subq #1,A5									;compteur bloc
   MOVE.B (A2)+,D1
   MOVE.B D1,D6							;! quartet poids forts et poids faible invers‚s dans un ancien format
   AUD_CALC_DVI D2,D1,D4,A0,A1
   MOVE D2,(A4)+							;‚chantillon voie gauche ou mono
   LSR.B #4,D6
   AUD_CALC_DVI D2,D6,D4,A0,A1
   BTST #0,1(SP)							;mono(0)/st‚r‚o(1)
   BEQ .lb7									;mono
   MOVE.B (A3)+,D1
   MOVE.B D1,D6
   AUD_CALC_DVI D3,D1,D5,A0,A1
   MOVE D3,(A4)+							;‚chantillon voie droite
   LSR.B #4,D6
   AUD_CALC_DVI D3,D6,D5,A0,A1
   MOVE D2,(A4)+							;‚chantillon voie gauche
   MOVE D3,(A4)+							;‚chantillon voie droite
   SUBQ.L #2,D7							;compteur octets
   BLE.S .lb8
   MOVE A5,D0								;compteur bloc
   BGT .lb4
   ADD #$22,A2								;saute la 2Šme voie
   ADD #$22,A3
   BRA .lb6
.lb7:
   MOVE D2,(A4)+							;‚chantillon mono
   SUBQ.L #1,D7							;compteur octets
   BLE.S .lb8
   MOVE A5,D0								;compteur bloc
   BGT .lb4
   BRA .lb6
.lb8:
	ADDQ #2,SP
   MOVE.L A4,D0
   SUB.L (SP)+,D0							;longueur en octets
   MOVEM.L (SP)+,D1-A5
.lb1:
	RTS

wind_get: dc.l wg_cont,global,wg_int,window0,dum,dum
wg_cont: dc.w 104,2,5,0,0
wg_int: dc.w 0,4

window_use:
	cmp #16,d0			; number of planes on desktop
	seq can_win			; $FF if window allowed
	beq.s .lb0
	rts
.lb0:
	GEM_AES wind_get	; work size of window 0
	tst window0
	bne.s .ok
	sf can_win			; no window allowed cause error!
.ok:
	rts

wind_calc: dc.l wc_cont,global,wc_int,wc_int+2,dum,dum
wc_cont: dc.w 108,6,5,0,0

try_window:
	tst.b slide_flag
	bne.s .end			; no window with slideshow of anims
	tst.b can_win
	beq.s .end
	sf is_win
	lea wc_int,a0
	clr (a0)+			; calc from work to full
	move #1,(a0)+		; kind of window (only title)
	move offsx+2,(a0)+
	move offsy,(a0)+
	tst.b vr2_flag
	beq.s .no_vr2
	move vr2_x+2,(a0)+
	move vr2_y+2,(a0)+
	bra.s .common
.no_vr2:
	move max_imagex,(a0)+
	move max_imagey,(a0)
.common:
	GEM_AES wind_calc
	lea wc_int+2,a0
	tst (a0)
	bne.s .ok
.end:
	rts
.ok:
	move #1,(a0)+		; for eventually wind_create
	lea window0+2,a1
	move (a1)+,d1
	move (a0)+,d0
	cmp d1,d0
	bmi.s .end			; bad x
	move (a1)+,d3
	move (a0)+,d2
	cmp d3,d2
	bmi.s .end			; bad y
	add (a1)+,d1
	add (a0)+,d0
	cmp d0,d1
	bmi.s .end			; bad x'
	add (a1),d3
	add (a0),d2
	cmp d2,d3
	bmi.s .end			; bad y'
	GEM_AES wind_create
	move wc_int+2,d7
	beq.s .end
	st is_win
	lea ws_int,a0
	move d7,(a0)+	; handle
	move #2,(a0)+	; TITLE
	move.l fname_pos,(a0)	; string address
	GEM_AES wind_set
	GEM_AES wind_open
	rts
	
wind_create: dc.l wcr_cont,global,wc_int+2,wc_int+2,dum,dum
wcr_cont: dc.w 100,5,1,0,0

wind_open: dc.l wo_cont,global,wc_int+2,dum,dum,dum
wo_cont: dc.w 101,5,1,0,0

treat_w_button:
	lea 467(a1),a0
	move.b (a0),d0
	move.l a0,DVI_DELTA	; if coords...
	tst.b can_win
	beq.s .disable
	btst #3,d0		; disabled?
	beq.s .enabled
	sf can_win		; if disabled, no WINDOW at all
	bra.s .disable
.enabled:
	btst #0,d0		; selected?
	sne can_win
	rts
.disable:
	and.b #$FE,d0	; not selected
	or.b #$08,d0		; and disabled
	move.b d0,(a0)
	rts

wind_set: dc.l ws_cont,global,ws_int,dum,dum,dum
ws_cont: dc.w 105,6,1,0,0

wind_close: dc.l wcl_cont,global,ws_int,dum,dum,dum
wcl_cont: dc.w 102,1,1,0,0

treat_vr_box:
	moveq #11,d6	; simulates 'OK'
	tst.b step_mode
	beq.s .lb0
	sf vr_flag		; no VR mode with step mode
	rts
.fin:
	move.l tree,a0
	btst #0,371(a0)
	sne vr_clic+1
	btst #0,443(a0)
	sne vr2_def
	rts
.lb0:
	tst.b vr_flag
	beq.s .fin		; no VR anyway...
	moveq #5,d0
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
	bclr #3,443(a0)
	bclr #3,467(a0)	; def allowed
	tst.b vr2_flag
	bne.s .no_def
	bset #3,443(a0)
	bset #3,467(a0)
.no_def:
	moveq #5,d6
	moveq #0,d7
	bsr.l manage_tree
	cmp #13,d6
	bne .fin
	sf vr_flag
	sf vr2_flag
	rts	

		
wind_delete: dc.l wd_cont,global,ws_int,dum,dum,dum
wd_cont: dc.w 103,1,1,0,0

parse_disk:
	moveq #7,d6
	moveq #0,d7
	bsr.l manage_tree
	cmp #18,d6
	beq .fin
	move.l tree,a0
	add.w #24*3+11,a0		; slect du 3eme element
	moveq #14,d0			; 15 boutons a tester
	cmp #20,d6
	bne.s .lb0
.all:
	bset #0,(a0)
	add #24,a0
	dbf d0,.all
	bra.s parse_disk
.lb0:
	cmp #21,d6
	bne.s .lb1
.none:
	bclr #0,(a0)
	add #24,a0
	dbf d0,.none
	bra.s parse_disk
.lb1:						; par defaut bouton 19=START
	lea cvid_fix1(pc),a1
	moveq #0,d7			; nombre d'extensions choisies
.sel:
	btst #0,(a0)
	beq.s .lb2
	move.l 1(a0),a2	; texte du bouton *.xxx
	move.l 1(a2),(a1)+	; partie .xxx copiee
	addq #1,d7		
.lb2:
	add #24,a0
	dbf d0,.sel
	tst d7
	beq.s .fin			; rien de choisi!!!
	bsr _open_parse_bat
	beq.s .fin			; annulation ou erreur
	bsr _parse
	pea batch3(pc)
	moveq #7,d4
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 64,12
	st samp_sizes
	rts
.fin:
	st stopped
	rts
	
vsf_color: dc.l vc_cont,vi_int,dum,dum,dum
vc_cont: dc.w 25,0,0,1,0,0,0,0,0,0,0,0

_open_parse_bat:
	clr mf_int
	GEM_AES graf_mouse				; the arrow
	GEM_VDI show_mouse
	lea fs_addrin+8(pc),a3
	move.l (a3),-(sp)
	move.l #batch,(a3)
	GEM_AES fileselect				; to select a MOV or quit (Abort button)
	move.l (sp)+,(a3)
	move.l intout,-(sp)
	GEM_VDI hide_mouse
	move (sp)+,d0						; 0 if error
	move (sp)+,d1						; 0 if Abort, other if OK
	tst d0
	beq .gloups							; if error, quits
	tst d1
	beq .gloups							; if abort, quits
	lea path(pc),a0
	lea full(pc),a1
	move.l a1,a2
.lb1:
	move.b (a0)+,d0					; a byte from path...
	beq.s .copy_name					; it's the end of the path
	move.b d0,(a1)+					; ...to full
	cmp.b #'\',d0
	bne.s .lb1
	move.l a1,a2						; if '\', updates A2
	bra.s .lb1
.copy_name:
	lea file(pc),a0							; the file name (or the mask!)
.lb2:
	move.b (a0)+,(a2)+				; copies after the last '\'
	bne.s .lb2							; til the end of the string
	clr -(sp)
	pea full(pc)
	GEMDOS 60,8
	tst.l d0
	bmi.s .gloups
	move d0,mov_h
	pea batch2(pc)
	moveq #10,d4
	move.l d4,-(sp)
	move d0,-(sp)
	GEMDOS 64,12
	cmp.l d4,d0
	bne.s .gloups
	moveq #1,d0
	rts
.gloups:
	moveq #0,d0
	rts
batch: dc.b "Where to save the BAT file?",0,0	
batch2: dc.b "SLIDEANI",13,10	; 10 car
batch3: dc.b ".stop",13,10		; 7 car
batch4: dc.b "*.*",0				; masque de recherche
batch5: dc.b "..",0				; pour remonter

	even
	
_parse:
	move.l d7,-(sp)
	moveq #8,d6
	moveq #1,d7
	bsr.l manage_tree				; searching files
	move.l (sp)+,d7
	pea .debut(pc)
	XBIOS 38,6
	moveq #0,d6						; niveau de base
	move.l fname_pos,a5			; pointeur dans le nom
	clr.b (a5)						; termine
	lea full2(pc),a3
	move (a3),d0
	cmp.b #":",d0					; un nom de lecteur?
	bne.s .setpath
	lsr #8,d0						; le nom
	move.l #$FFDFDFDF,d3			; masque pour les extensions en majuscules
	sub #"A",d0
	move d0,-(sp)
	GEMDOS 14,4
	addq.l #2,a3
.setpath:
	move.l a3,-(sp)
	GEMDOS 59,6
	tst.l d0
	bmi .fin							; path not found
	lea cvid_fix1(pc),a3			; pointe sur les extensions
	subq #1,d7						; pour les boucles
	lea 100(a3),a4					; premiŠre DTA
.dossier:
	addq.l #1,sample_num
	move.l a4,-(sp)
	GEMDOS 26,6						; fixe ma DTA
	move #-1,-(sp)
	pea batch4(pc)
	GEMDOS 78,8						; fsfirst
	bra.s .autre
.next:
	GEMDOS 79,2
.autre:
	tst.l d0
	bmi .fin_dossier
	move.b 21(a4),d0				; attrib
	btst #4,d0						; dossier?
	bne.s .zyva
	move.l a5,a1
	lea 30(a4),a0
	moveq #0,d1
.cpy_name:
	move.b (a0)+,d0
	beq.s .lb1
	cmp.b #".",d0
	bne.s .lb0
	move.l -1(a0),d1				; extension
.lb0:
	move.b d0,(a1)+
	bra.s .cpy_name
.lb1:
	and.l d3,d1						; en majuscules pour la comparaison
	move d7,d0						; compteur
	move.l a3,a0					; les extensions
.lb2:
	cmp.l (a0)+,d1
	beq.s .lb3
	dbf d0,.lb2
	bra.s .next
.lb3:
	move.w #$0d0a,(a1)+
	lea full2(pc),a0
	sub.l a0,a1						; taille
	move.l a0,-(sp)
	move.l a1,-(sp)
	move mov_h,-(sp)
	GEMDOS 64,12					; fwrite
	addq.l #1,disp_frame
	bra.s .next	
.zyva:
	move 30(a4),d0					; deux lettres
	cmp #"..",d0
	beq.s .next
	cmp #$2e00,d0
	beq.s .next
	and #$FF00,d0
	beq.s .next						; si il est nul, ignorer
	pea 30(a4)
	GEMDOS 59,6						; nouveau dossier
	tst.l d0
	bmi .next						; path not found, autre dossier
	lea 30(a4),a0					; nom
	add #44,a4						; saute la DTA
	move.l a5,(a4)+
.lb4:
	move.b (a0)+,(a5)+			; ajoute dossier
	bne.s .lb4
	move.b #"\",-1(a5)			; et modifie fname pos
	addq #1,d6
	bra .dossier	
.fin_dossier:
	subq #1,d6
	bmi.s .fin	
	move.l -(a4),a5				; vieux fname pos
	sub #44,a4
	pea batch5(pc)	
	GEMDOS 59,6
	tst.l d0
	bmi.s .fin						; refuse de remonter, sortir!
	move.l a4,-(sp)
	GEMDOS 26,6						; fixe ma DTA
	bra .next		
.fin:
	pea .term(pc)
	XBIOS 38,6
	move.l d7,-(sp)
	moveq #8,d6
	moveq #-1,d7
	bsr.l manage_tree				; searching files
	move.l (sp)+,d7
	rts
.debut:
	move.l $4ba.w,start_time
	rts
.term:
	move.l $4ba.w,end_time
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
				  dc.b     " FLI/C/H, CDH/L/V (CD Stratos) |"
				  dc.b     " FLM (Kin./Lexic./Vid.Master)|"
				  dc.b	  " SEQ/PI1+DLT (Cyber), GIF ]"
				  dc.b     "[ Ooops! ]",0
	else
format_error: dc.b "[1][ Version CD EB model: |"
				  dc.b     " MOV et AVI en Rle |"
				  dc.b     " FLI, MPEG, FLM & GIF |"
				  dc.b     " et peut cr‚er des animations ]"
				  dc.b	  "[Oooops! ]",0
	endif
mem_error:   dc.b "[1][ | Not enough memory!... ][ Ooops! ]",0
bad_codecs:  dc.b "[1][ | QT Codecs not supported! ][ Ooops! ]",0
mdat_error:  dc.b "[1][ | QT mdat len is 0. ][ Quit ]",0
ok:          dc.b "[1][ | Everything is Ok! ][  Good!  ]",0
bad_card:    dc.b "[1][ Supported displays are: | - TT video "
				 dc.b "| - Nova/C.Dots 1&2 (256 or 32K) "
				 dc.b "| - Falcon video ][ Quit! ]",0
eof_error:   dc.b "[1][ | Unexpected End of File! | ][ Ooops! ]",0
bad_info:    dc.b "[1][ | Bad image informations! | ][ Ooops! ]",0
insuf_info:  dc.b "[1][ | The header hasn't every | information needed!"
				 dc.b " | (W=,H=,B=,C=) ][ Ooops! ]",0
insuf_info2: dc.b "[1][ | To create a Movie, you | must fill EVERY option!"
				 dc.b " | (O=,F=,T=) ][ Ooops! ]",0
cant_create: dc.b "[1][ | Can't create ouput | file! (MOV) ][ Ooops! ]",0
	if REG=1
no_rsc:		 dc.b "[1][ | Can't load ressource file! | (M_PLAYER.RSC) | ][ Ooops! ]",0
	else
no_rsc:		 dc.b "[1][ | Can't load ressource file! | (MPLYR_SW.RSC) | ][ Ooops! ]",0
	endif
avr_text: dc.b "Select a SOUND FILE",0,0
	
	even

fileselect: dc.l fs_cont,global,dum,intout,fs_addrin,dum
fs_cont: dc.w 91,0,2,3,0
fs_addrin: dc.l path,file,select
fs_addrin_tga: dc.l tga_path,tga_file,tga_text
fs_addrin_avr: dc.l avr_path,avr_file,avr_text

vs_color: dc.l vs_cont,vs_int,dum,intout,dum
vs_cont: dc.w 14,0,0,4,0,0,0,0,0,0,0,0

shel_find: dc.l sf_cont,global,dum,dum,rsc_name,dum
sf_cont: dc.w 124,0,1,1,0

rsrc_load: dc.l rl_cont,global,dum,intout,rsc_name,dum
rl_cont: dc.w 110,0,1,1,0
rsc_name: dc.l _name

rsrc_free: dc.l rf_cont,global,dum,dum,dum,dum
rf_cont: dc.w 111,0,1,0,0

form_dial2: dc.l fd_cont,global,rect_dial,dum,dum,dum

form_do: dc.l do_cont,global,do_int,intout,tree,dum
do_cont: dc.w 50,1,1,1,0
do_int: dc.w 0			; no edit object

	if REG=1
_name: dc.b "M_PLAYER.RSC"
	else
_name: dc.b "MPLYR_SW.RSC"
	endif
			 dcb.b 200,0
select: dc.b " SELECT A MOVIE ",0,0
qt_title:  dc.b "  Apple QuickTime¿ (MOV)  ",0
vr_title:  dc.b "   QuickTime¿ V_R (MOV)   ",0
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
xflm_title: 
			  dc.b "  Extended Lexicor¿ Film  ",0
gif_title: dc.b "Compuserve¿ graphics (GIF)",0
dl_title:  dc.b " Uncompressed DL1/2  (DL) ",0
vmas_title: 
			  dc.b " Video Master¿ V1.0 (FLM) ",0 
mvi_title: dc.b "   Motion Pixels¿ (MVI)   ",0
cd_title:  dc.b "  Stratos Magazine (CDx)  ",0
comp_txt: dc.b "xxxx"
max: dc.b "Max speed ",0
delay: dc.b "xxx.x f/s",0
tga_text: dc.b "Select TGA SAVE PATH",0,0
step_text:    dc.b " (Save/All/Quit/Run)",0
control_text: dc.b " (Control to stop!)",0
step_home: dc.b 27,"H",0
degas_text: dc.b 27,"ECreating extended FLM file...",13,10,10,0
create_text: dc.b 27,"ECreating Quick Time file...",13,10,10,0
gif_text		dc.b 27,"ECreating GIF file...",13,10,10,0
create_avi_text: dc.b 27,"ECreating Video for Windows file...",13,10,10,0
sound_text: dc.b "Adding sound...",13,10,10,0
add_file: dc.b 13,"Adding frame 00000"
add_digit: dc.b "0...",0
add_header: dc.b 13,10,10,"Saving header...",0
convert_txt: dc.b "Select output FILENAME",0,0
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
	dc.b $17,'M_Player on Atari 68030'

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
	dc.b $17,'M_Player on Atari 68030'

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
	dc.b 15,"M_PLAYER(V"
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
	dc.b 25,'M_PLAYER sound Atari68030'

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
	dc.b 25,'M_PLAYER sound Atari68030'

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
	
is_65k: dc.w $0003 ; mode for 32768 colors on NOVA

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

avr_path: ds.b 400
avr_file: ds.b 20
avr_full: ds.b 420
tga_path: ds.b 400
tga_file: ds.b 20
tga_full: ds.b 420
tga_file_ptr: ds.l 1
tga_digit: ds.l 1
auto_save_tga: ds.b 1
auto_run_tga: ds.b 1
write_error: ds.w 1

; *********** start of data that will be zeroed at launch ***********
start_zero:

inter_flag: ds.b 1

create_avi: ds.b 1
create_mov: ds.b 1
slide_gif: ds.b 1
slide_degas: ds.b 1
mvi_flag: ds.b 1

head_pos: ds.l 1
head_len: ds.l 1
idx_pos: ds.l 1
idx_len: ds.l 1
movi_pos: ds.l 1
avi_rate: ds.l 1

real_freq: ds.l 1
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

top_lines_buff: ds.l 1
one_buffer:
s_buffer: ds.l 1			; the ST ram buffer
top_lines_size:
stram_size: ds.l 1
tga_buff:	ds.l 1
two_buffer:
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

max_imagex: ds.w 1	; DO NOT
max_imagey: ds.w 1	; SEPARATE

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

flm_screen: ds.l 1
flm_frame: ds.l 1

bat_text: ds.l 1

yamaha_flag: ds.w 1
degas_div: ds.l 1
degas_q1: ds.l 1
degas_r1: ds.l 1

grey_depth: ds.w 1
cram_bits: ds.w 1

ima4_offs: ds.l 1
ima4_flag: ds.w 1
avi_comp_flag: ds.w 1
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

vr2_flag: ds.b 1	; byte!		NE PAS SEPARER
vr2_def:	ds.b 1
vr2_data: ds.w 3	; angle large, haut, bas
			 ds.l 4	; hauteur, largeur, images/panneau, images/colonne
vr2_col_offx: ds.l 1
vr2_col_offy: ds.l 1
			 
_vr2_x: ds.l 1		; ne pas separer les 4
_vr2_y: ds.l 1
vr2_x: ds.l 1
vr2_y: ds.l 1		; fenetre dans le panneau

vr2_num: ds.l 1	; nombre de lieux
vr2_temp: ds.l 1
vr2_panneau: ds.l 1
vr2_image: ds.l 1
vr2_index: ds.l 1
vr2_sx: ds.l 1
vr2_sy: ds.l 1
vr2_save_screen: ds.w 2
vr2_maxx: ds.l 1
vr2_maxy: ds.l 1

mountain: ds.b 1	; byte!
conv_flag: ds.b 1
vanel_adr: ds.l 1
_vanel_plus: ds.w 1	; en plus sur une ligne
_vanel_line: ds.w 1
conv_zoom: ds.b 1		; byte! (0=pas de zoom, 1=x2, -1=:2)
group_step: ds.b 1
gif_loaded: ds.b 1	; byte!
gtel_sound: ds.b 1
_vr2_flag: ds.b 1		; byte
can_fast: ds.b 1		; byte!
unknown: ds.b 1		; byte
tgac: ds.b 1			; FF si TGA compress‚ (entree ou sortie!)
tgac_offset: ds.l 1
tga10_buff: ds.l 1	; second buffer pour compression
conv_video: ds.b 1	; byte FF si M_PLAYER fils doit changer de RES Falcon
_conv_video: ds.b 1	; byte FF dans fils si M_PLAYER doit changer RES Falcon
etat_sav: ds.b 1		; etat des touches apres FILESLECTOR (pour parse_disk).
is_parse: ds.b 1		; FF si mode parse (pour les dialogues a modifier)
no_idx1: ds.b 1		; FF si AVI sans idx1
ttram_sound: ds.b 1	; FF si on charge en TT ram

; *********** end of zeroed data **************************
end_zero:
	even

degas_r: ds.l 1
degas_q: ds.l 1

ed_adr: ds.l 1

vdo_value: ds.l 1
snd_value: ds.l 1
cpu_value: ds.l 1
res_switch: ds.w 1
can_step: ds.w 1
psnd_flag: ds.w 1		; for VIRUS sound card

pattern:
smc_8: ds.w 1
dup_line:
dc_flag:
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

old_midi: ds.l 1
old_stat: ds.l 1
old_cloc: ds.l 1
old_ikbd: ds.l 1

tt_screen: ds.l 1
tt_comp: ds.l 1
is_tt: ds.w 1
flx_number: ds.w 1
flx_start: ds.w 1
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
gif_lines: ds.w 1
gif_inc: ds.w 1
gif_start_line: ds.w 1
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

menu_tree: ds.l 1
menu_buffer: ds.l 1
menu_len: ds.l 1

dl_i_per_s: ds.w 1

cmd_x: ds.w 1
cmd_y: ds.w 1
cmd_return_adr: ds.l 1

acc_cmd_adr: ds.l 1

flm_snd_size: ds.l 1
flm_snd_pos: ds.l 1
flm_snd_end: ds.l 1

flm_time_ptr: ds.l 1
flm_ptr_inc: ds.l 1
flm_time: ds.l 1
flm_time_inc: ds.l 1
_flm_phys: ds.l 1
neo_degas_offs: ds.l 1

id_ptr: ds.l 1				; initialis‚ a id_table!
id_table: ds.l 6			; au cas ou! VR2 n'en compte que 2
								; LONG ID et qt_palette
mvi_save_size: ds.l 1
mvi_next_size: ds.l 1
mvi_rem: ds.w 1	; byte

slide_zone: ds.l 1
slide_ptr: ds.l 1
slide_stack: ds.l 1
slide_flag: ds.w 1
slide_digit: ds.l 1
slide_save_flags: ds.b 10

iv32_ptrs: ds.l 6	; y1,u1,v1,y2,u2,v2

cd_acc: ds.w 9 ; LONG acc_remain, WORD acc_int, WORD loop
					; word +int, LONG+remain, LONG remain limit
cd_sound_count: ds.l 1

buffer_16: ds.l 1	; 16 bytes aligned buffer

cmd_dial: ds.b 1	; do not separate those flags
cmd_play: ds.b 1
cmd_sync: ds.b 1
cmd_alt: ds.b 1
cmd_erro: ds.b 1
cmd_inter: ds.b 1
cmd_coord: ds.b 1
cmd_return: ds.b 1

DVI_DELTA: ds.w 1424	; compressed sound

can_win: ds.b 1		; 16 bits (NOVA or Falcon) on desktop -> window allowed
is_win: ds.b 1			; can_win=true and enough place for a window
fast_mode: ds.b 1		; byte
is_rep: ds.b 1			; if REPEAT button is ON

sample_num2: ds.l 1	; les effectivements sauv‚es (voire ritme!)

window0: ds.w 5		; return + x + y + l + h of window 0
ws_int: ds.w 6
wc_int: ds.w 6

_dialogue: ds.l 3		; ma routine, frame number, adresse pixels
	ds.w 1				; flag, si flag='EX', il y a une extension
	ds.w 1				; extension: $0101=taille normale
							;				 $0201=zoom fois deux
							;				 $0102=zoom divis‚ par deux
	
conv_stack: ds.l 1
hote_stack: ds.l 1
conv1_stack: ds.l 1
anim_type: ds.w 1
conv_x: ds.w 1			; en cas de zoom, garde les tailles d'origine
conv_y: ds.w 1

snd_size_offs: ds.l 2	; pour MOV

qtvr_num: ds.l 1		; nombre d'images du premier codec.
_mpg_trap: ds.l 2		; trap 8 (dessin) trap 7 (timer)
_mpg_time: ds.w 1

mp_buffer: ds.w 8

acc: ds.b 1
rsc: ds.b 1
acc_command: ds.b 1
repondre: ds.b 1
	even
	ds.b $1000
_pile: ds.w 1		; room for the stack

	end


	