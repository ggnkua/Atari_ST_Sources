	move.l a0,ptr_pathname

	move #MX_PREFTTRAM,d0
	bsr GWVA_FILE_LOAD_IN_MEM
	tst.l d0
	ble erreur_load

	move.l a0,gif_loaded_address
	move.l d0,gif_loaded_length

	MXALLOC #MX_PREFTTRAM,#256*4
	tst.l d0
	ble err_malloc
	move.l d0,gif_palette

	MXALLOC #MX_PREFTTRAM,#200000	; 640*480+4096
	tst.l d0
	ble err_malloc
	move.l d0,strings

	move.l gif_loaded_length,d0
*	bclr #0,d0			; pourquoi je faisais ‡a ???
	MXALLOC #MX_PREFTTRAM,d0	; au header + palette prŠs
	tst.l d0
	ble err_malloc
	move.l d0,gif_buff
	add.l gif_loaded_length,d0
	move.l d0,fin_gif_buff

	graf_mouse #BUSY_BEE
	; d‚but du d‚codage

	move.l gif_loaded_address,a0

	clr.l d0
	bsr get_left
	bsr get_left
	bsr get_left
	cmp.l #'GIF',d0
	bne err_not_gif
	addq #3,a0

	bsr get_word
	move d0,gif_loaded_width
	bsr get_word
	move d0,gif_loaded_height

	move.b (a0)+,d0
	move.b d0,d1
	and.w #%111,d1
	add #1,d1
	move d1,gif_loaded_nb_planes
	moveq #1,d2
	lsl.w d1,d2
	move d2,gif_loaded_nb_colors
*	cmp.b #%111,d1		; no use of CR
*	bne err_not_256_coul
	btst #7,d0
	beq.s .not_global_coul
	bsr get_left		; backgroud coul
	bsr get_left		; 0.b
	bsr create_pal
	bra.s .continue
.not_global_coul:
	bsr get_left		; backgroud coul
	bsr get_left		; 0.b
.continue:

find_separator:
	cmp.b #',',(a0)+
	bne.s find_separator

	bsr get_word		; d‚calage du bord gauche
	bsr get_word		; d‚calage / haut

	bsr get_word
*	cmp.w #640,d0
*	bgt pas_640
*	move d0,gif_loaded_width
	bsr get_word
*	cmp.w #480,d0
*	bgt pas_480
*	move d0,gif_loaded_height

	move.b (a0)+,d0
	btst #7,d0
	beq.s .not_local		; ignore pixel
*	move.b d0,d1
*	and.b #%111,d1
*	cmp.b #%111,d1
*	bne err_not_256_coul
	btst #6,d0
	bne err_interlaced
	bsr create_pal
.not_local:
	move.b (a0)+,d0
	cmp.b #8,d0
	bne err_not_8_bits

	bsr prepare_lzh_buff		; default strings 0 to 255

	bsr make_gif_buff		; d0.l longeur buff

	MFREE gif_loaded_address	; plus besoin
	clr.l gif_loaded_address

	move gif_loaded_width,d0
	add #15,d0
	divu #16,d0
	mulu #16,d0			; multiple de 16
	mulu gif_loaded_nb_planes,d0
	divu #8,d0			; donc divisible par 8
	mulu gif_loaded_height,d0
	add.l #639+1+1024,d0
	MXALLOC #MX_PREFTTRAM,d0
	tst.l d0
	ble err_malloc
	move.l d0,gif_img

	bsr decompact_buff

	save.l a1

	MFREE strings
	clr.l strings
	move.l #1,d0
*	bsr GWVA_APP_OBJ_PRG_WAIT_EVENTS

	MFREE gif_buff
	clr.l gif_buff
	load.l a1

	move.l gif_img,a0
	move.w gif_loaded_width,d0
	mulu gif_loaded_height,d0
	add.l d0,a0
	cmp.l a0,a1
	beq.s .no_error

	move #ALERT_UNPACK_ERR,d0
	move #1,d1
	bsr GWVA_RSC_ALERT_BOX

.no_error
	move gif_loaded_width,d0
	add #15,d0
	divu #16,d0
	mulu #16,d0			; multiple de 16
	mulu gif_loaded_nb_planes,d0
	divu #8,d0			; donc divisible par 8
	move d0,gif_loaded_width_rounded_16
	mulu gif_loaded_height,d0
	MXALLOC #MX_PREFTTRAM,d0
	tst.l d0
	ble err_malloc
	move.l d0,gif_for_screen
