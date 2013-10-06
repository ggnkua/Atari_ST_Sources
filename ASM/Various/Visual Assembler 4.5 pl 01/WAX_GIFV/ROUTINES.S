*--------------------------------------------------------------------------*

get_left:	lsl.l #8,d0
	move.b (a0)+,d0
	rts

get_word:	move.b (a0)+,d1		; lsb (format PC de merde)
	move.b (a0)+,d0		; msb
	lsl.w #8,d0
	move.b d1,d0
	rts

*--------------------------------------------------------------------------*

create_pal:	move gif_loaded_nb_colors,d1
	subq #1,d1
	move.l gif_palette,a1
.make_rvb:	bsr.s get_left
	bsr.s get_left
*	lsl.l #8,d0
	bsr.s get_left
	move.l d0,(a1)+
	dbf d1,.make_rvb
	rts

*--------------------------------------------------------------------------*

prepare_lzh_buff:		; pr‚pare la table de pointeurs
	lea string_table,a2
	move.l strings,a3
	clr d0
	moveq #1,d1
.create:	move.l a3,(a2)+
	move.l d1,(a2)+
	move.b d0,(a3)+
	addq #1,d0
	cmp #256,d0
	bne.s .create
	move.l #string_table+(256+2)*8,ptr_table
	move.l strings,a2
	add.w #256,a2
	move.l a2,ptr_strings
	move.w #256+2,current_max_code
	rts

*--------------------------------------------------------------------------*
make_gif_buff:
	clr.l d0			; compte longeur totale
	move.l fin_gif_buff,a1

.recomm:	moveq #0,d1
	move.b (a0)+,d1
	beq.s .finished
	subq #1,d1
	add.l d1,d0
.copy_cutted:move.b (a0)+,-(a1)		; recopie … l'envers
	dbf d1,.copy_cutted		; pour r‚cup‚rer les
	bra.s .recomm		; bits dans le bon sens
.finished:	rts

*--------------------------------------------------------------------------*
decompact_buff:
	move.l fin_gif_buff,a0
	move.l gif_img,a1
	lea string_table,a6
	clr.l d1
	clr.l d2

	move.l #0,d7		; offset in bits field
raz_code_send:
	move.l #9,d6		; code start size

find_1st:	sub.l d6,d7
	bfextu (a0){d7:d6},d1		; offset:length

	cmp.w #%100000000,d1
	beq.s find_1st		; on a d‚ja	fait un raz

	move.b ([a6,d1*8]),(a1)+	; 1er a une longeur de 1

all_bytes:	sub.l d6,d7
	bfextu (a0){d7:d6},d2		; offset:length

	cmp.w #%100000000,d2
	bne.s pas_raz
	bsr prepare_lzh_buff
	bra.s raz_code_send
pas_raz:
	cmp.w #%100000001,d2		; c'est un code compress‚
	beq finishes

	cmp current_max_code,d2
	blt.s cod_exists
	bgt errare_humanum

	; le code n'existe pas dans la table : on prend le vieux

	move.l (a6,d1*8),a2		; ad. chaine
	move.l 4(a6,d1*8),d3		; nb.

	move.l ptr_strings,a3		; <=> allocation dynamique
	move.l ptr_table,a4
	move.l a3,(a4)+
	addq.l #1,d3
	move.l d3,(a4)+
	move.l a4,ptr_table		; ad. dans table des strings

	subq #1+1,d3
copy_new2:	move.b (a2)+,(a3)+
	dbf d3,copy_new2		; copy old

	move.b ([a6,d1*8]),(a3)+	; copy 1st of old

	move.l a3,ptr_strings

	move current_max_code,d2	; ne sert plus
	move.w d2,d1		; old=new
	move d2,d0
	addq #1,d0
	move d0,current_max_code
	and d2,d0
	bne.s not_depass2
	addq.l #1,d6		; ruse des dieux pour trouver

	cmp.w #13,d6		; pas sur 13 bits SVP
	blt.s pas_coolax
	move.w #12,d6
pas_coolax:

not_depass2:			; le d‚passemnent du code bital

	move.l (a6,d2*8),a2		; ad. chaine
	move.l 4(a6,d2*8),d3		; nb.
	subq #1,d3
copy_string2:
	move.b (a2)+,(a1)+		; d‚pack
	dbf d3,copy_string2

	bra all_bytes

cod_exists:	; in the table

	move.l (a6,d2*8),a2		; ad. chaine
	move.l 4(a6,d2*8),d3		; nb.
	subq #1,d3
copy_string:
	move.b (a2)+,(a1)+		; d‚pack
	dbf d3,copy_string

	move.l (a6,d1*8),a2		; ad. chaine
	move.l 4(a6,d1*8),d3		; nb.

	move.l ptr_strings,a3		; <=> allocation dynamique
	move.l ptr_table,a4
	move.l a3,(a4)+
	addq #1,d3
	move.l d3,(a4)+
	move.l a4,ptr_table		; ad. dans table des strings

	subq #1+1,d3
copy_new:	move.b (a2)+,(a3)+
	dbf d3,copy_new		; copy old

	move.b ([a6,d2*8]),(a3)+	; copy 1st of new

	move.l a3,ptr_strings

	move.w d2,d1		; old=new
	move current_max_code,d2	; ne sert plus
	move d2,d0
	addq #1,d2
	and d2,d0
	bne.s not_depass
	addq.l #1,d6		; ruse des dieux pour trouver

	cmp.w #13,d6		; pas sur 13 bits SVP
	blt.s pas_coolax2
	move.w #12,d6
pas_coolax2:

not_depass:	move d2,current_max_code	; le d‚passemnent du code bital
	bra all_bytes

finishes:	rts

errare_humanum:
	rts

*--------------------------------------------------------------------------*
put_in_screen_format:
	move gif_loaded_nb_planes,d0
	cmp.w GWVA_ROOT_VDI_WORKSTATION_EXTD+4*2,d0
	bne.s cannot_do

	move.l gif_for_screen,a0
	move.w gif_loaded_width_rounded_16,d0
	mulu gif_loaded_height,d0

.clrs:
	rept 4
	clr.l (a0)+
	endr
	sub.l #16,d0
	bne.s .clrs

	move.l gif_img,a0
	move.l gif_for_screen,a1
	move gif_loaded_height,d7
	subq #1,d7
ver:	move gif_loaded_width,d6

hor:	moveq #16-1,d5

	sub #16,d6
	bge.s .sup_16
	add d6,d5			; ruse !
.sup_16:
	move.w #%1000000000000000,d1		; motif
par_16:
	move.b (a0)+,d0
	move gif_loaded_nb_planes,d4
	subq #1,d4
planes:	lsl.b #1,d0				; lsl.b
	bcc.s clear
	or.w d1,(a1,d4*2)
clear:	dbf d4,planes

	lsr.w #1,d1
	dbf d5,par_16

	add.l #2*8,a1
	tst d6
	bgt hor

	dbf d7,ver
	clr d7
	rts

cannot_do:	moveq #-1,d7
	rts
*--------------------------------------------------------------------------*
