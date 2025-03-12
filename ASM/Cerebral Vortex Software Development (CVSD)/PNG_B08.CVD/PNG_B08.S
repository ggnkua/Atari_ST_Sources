*************************************************
*                                               *
* << Png routine : >>                           *
* -------------------                           *
*                                               *
* << Code : GT Turbo >>                         *
* << Add. Code, Help and debugging : Azrael     *
* << and Zerosquare >>                          *
*                                               *
* Devpac, tab : 16                              *
*                                               *
* This routine can read the 3 kinds of PNG pic  *
* - unpacked picture                            *
* - packed with fixed huffman code              *
* - packed with variable huffman code           *
*                                               *
* interlaced, 1,2,4,8,16,32 bits by pixel,      *
* with alpha or not, etc...                     *
*                                               *
*                                               *
* After unpacking you've got a buffer with a    *
* screen size*3 bytes, (1 byte by component).   *
* In this version i've added a bytefiller for   *
* Radeon card (CTPCI), if you only need RVB     *
* just kill it, it's written in the convert     *
* raw routine.. make a search on bytefiller     *
* and delete the line.....                      *
*                                               *
* This routine must be spread, you can          *
* distribute, cook it ( O_o), reverse it,       *
* put it in your garden, forget it O_o,         *
* but just told that the original routine was   *
* coded by the C.V.S.D. Team...                 *
*                                               *
*                                               *
*                             < C.V.S.D. 2012 > *
*                                               *
* Beta V: 0.8                                   *
*                                               *
* The only bug left is with 1,2,4 bits by pixel *
* interlaced picture, a litte bug give 'sinus   *
* shifted' picture. I will kill it when i have  *
* some free time....                            *
*                                               *
*                                               *
*    Azrael, GT Turbo, Zerosquare from :        *
*                                               *
* Cerebral Vortex Software Developement         *
*                                               *
* All questions can be send at :                *
*                                               *
*       png68000@jagware.org                    *
*                                               *
*                                               *
* P.S. : Atari is always the coolest 'world'    *
*        me....                                 *
*                                               *
*************************************************

; %XYZ Z= Fast load, Y=TT-Ram Prg, X=TT-Ram mem

	COMMENT	HEAD=%111

	opt	p=68000

; Structure for unpacking tree

	rsreset

Feuille_gauche:	rs.w	1
Feuille_droite:	rs.w	1
Fcar:	rs.w	1	

; ********************************************************************
; ********************************************************************

	move.l	a7,a6	* Save Stack
	move.l	4(a6),a6	* Base Page
	move.l	$c(a6),d0	* Section Text Length
	add.l	$14(a6),d0	* Section Data Length
	add.l	$1c(a6),d0	* Section Bss Length
	move.l	d0,d6
	add.l	#$400,d0	*  Bytes : stack size
	move.l	d0,d1	* !!!!
	add.l	a6,d1	* Start Adr
	and.l	#-2,d1	* Even Adr
	move.l	d1,a7	* Stack
	
	move.l	d0,-(a7)	* Length
	move.l	a6,-(a7)	* Start Adr
	clr.w	-(a7)	* Null
	move.w	#$4a,-(a7)	* Msrink
	trap	#1	* 
	lea	12(a7),a7

	jsr	Appl_init	; Need it for 'proper display'
	jsr	Init_vdi

; ********************************************************************
; ********************************************************************
; Display intro text 


	lea	Home_txt,a0	; Home text
	jsr	Print_text

; ********************************************************************
; ********************************************************************

another_pic:

	sf	String_selection
	sf	File_name_string

	move.l	#String_selection,d0
	move.l	#File_name_string,d1

	jsr	Fsel_input

	tst.w	Int_out+2
	beq	Quit

	lea	String_selection,a0
	jsr	Find_a_file_name
	add.w	d0,a0
	lea	File_name_string,a1
	exg	a0,a1
	jsr	Copy_string
	
	lea	String_selection,a0
	jsr	Read_file
	bmi	Quit		; Error ? if yes quit

; ********************************************************************
; ********************************************************************

	move.l	File_adr,a0		; File adr :)
	lea	Palette,a1		; Palette buffer (Max 256 colors *3 bytes (RVB)
				; If needed of course
	jsr	Control_png_file(pc)	; Good png File ? Control
	bpl.s	Hopla		

	lea	File_error,a0		; Error in it :)
	jsr	Print_text
	bra	Quit

Hopla:

; We need buffer

	move.l	#33000*6,d0
	jsr	Malloc
	beq	Quit
	move.l	d0,GT_Tree_adr
	move.l	d0,a0

	move.l	#33000*6,d0
	jsr	Malloc
	beq	Quit
	move.l	d0,LGT_Tree_adr

	move.l	d0,a0
	jsr	Clean_this_fuckin_tree

	move.l	#(800*600)*6,d0
	jsr	Malloc
	beq	Quit
	move.l	d0,Screen_buffer_adr

; ******************************************************************

	move.l	#(800*600)*6,d0
	jsr	Malloc
	beq	Quit
	move.l	d0,Output_stream_adr

	move.l	#(800*600)*6,d0
	jsr	Malloc
	beq	Quit
	move.l	d0,Output_buffer_adr
	
; ********************************************************************
; ********************************************************************
; In : a0.l : file adr
;      a1.l : Memory for a first tree (2^16)*6 bytes

	move.l	File_adr,a0
	move.l	GT_Tree_adr,a1

	jsr	Process_png_file(pc)

; ********************************************************************
; ********************************************************************

	jsr	Gen_grey_palette	; If grey palette is need
	
	jsr	Convert_raw_to_argb(pc)	; Convert raw png format
				; to ARGB (Radeon format)

	jsr	Aff_picture(pc)		; Display picture

; Mfree all buffer

	move.l	GT_Tree_adr,d0
	jsr	Mfree

	move.l	LGT_Tree_adr,d0
	jsr	Mfree

	move.l	Screen_buffer_adr,d0
	jsr	Mfree

	move.l	Output_stream_adr,d0
	jsr	Mfree

	move.l	Output_buffer_adr,d0
	jsr	Mfree

	jsr	Wait_key(pc)

	bra	Another_pic

; *********************************************************
; *********************************************************

Quit:
	jsr	V_clswk	* Close Vdi workstation


	jsr	Appl_exit	; Close AES

	move.l	File_adr(pc),d0
	jsr	Mfree(pc)


; Bye bye
	clr.w	-(a7)
	trap	#1


; ********************************************************************
; ********************************************************************
; ********************************************************************

; Hi this is the first routine called :
; Control_png_file : it control and init some differents things like
; Size of the picture, numbers of colors, all obligatory chunks are
; present


; In :
; ----
; a0.l : File adr
; a1.l : Palette buffer Adr if needed
; d0.l : Negative if error, else d0.l =0

; d0.l : -1 bad signature
; d0.l : -2 bad crc (If crc control enable) (Avaible in option xD)
; no it in this version, if you want a version with just contact me
; d0.l : -3 no IDAT or IDHR chunk
; d0.l : -4 chunk parameter error

; Out :
; -----
; d0.l : =0 if everything is good, negative else
; d1.l : X size
; d2.l : Y size
; d3.l : Numbers of colors (If it is a paletted picture)
; d4.l : bits by pixel
; d5.l : Alpha flag
; d6.l : Give Memory needed for picture buffer (Uncompressed picture in TC 24 bits)

Signature:	dc.b	$89,$50,$4e,$47,$d,$a,$1a,$a	

Control_png_file:
	movem.l	d7/a0-a6,-(a7)

	clr.w	Nb_colors	; No palette by default
	move.l	a0,Pointer	; Datafile pointer
	move.l	a1,Palette_pnt	; Palette pointer max 256*3 bytes

	jsr	Init_tabs	; Init some tabs

; ****************************************************************

	move.l	Pointer(pc),a0

	lea	Signature(pc),a1
	moveq	#8-1,d1
Test_the_whole_signature:
	move.b	(a1)+,d0
	cmp.b	(a0)+,d0
	bne.s	Erreur_de_signature
	dbra	d1,Test_the_whole_signature
	move.l	a0,Pointer
	moveq	#0,d0
	bra.s	Quit_test_signature
Erreur_de_signature:
	bra.s	Quit_control_png_file		; Bad signature No !! O_o
Quit_test_signature:

; ****************************************************************

	jsr	Control_chunk(pc)		; 
	bmi.s	Quit_control_png_file		; Error !! O_o

	moveq	#0,d0		; Good Png file
	move.l	X_size(pc),d1		; X size
	move.l	Y_size(pc),d2		; Y Size
	move.w	Nb_colors(pc),d3	; Nb of colors in palette if no -1

	moveq	#0,d4
	move.b	Bitdepth,d4
	mulu	Nb_channel,d4		; Bit by pixel

	moveq	#0,d5
	move.w	Alpha_flag,d5		; Alpha flag

	move.w	Y_size+2,d7
	addq.w	#1,d7		; add 1 byte for filter

	move.w	Bytpp,d6		; Memory needed for the picture
	mulu	X_size+2,d6
	mulu	d7,d6

Quit_control_png_file:
	tst.l	d0
	movem.l	(a7)+,d7/a0-a6
	rts

; *********************************************

Control_chunk:	movem.l	d1-d7/a0-a6,-(a7)

	lea	Chunk_name(pc),a1
	moveq	#3,d1
Png_ctrl_chunk:
 	jsr	Read_chunk(pc)	
	bmi	Chunk_error		
	
	cmp.l	#"IHDR",(a1)		; First chunk ?
	bne.s	Pas_chunk_idhr_0
	jsr	Read_grafics_description(pc)
	bclr	#0,d1
Pas_chunk_idhr_0:

	cmp.l	#"IDAT",(a1)
	bne.s	Pas_chunk_idat_0
	bclr	#1,d1
Pas_chunk_idat_0:

	cmp.l	#"PLTE",(a1)
	bne.s	Pas_chunk_plte_0
	jsr	Read_plte(pc)
Pas_chunk_plte_0:

	move.l	Pointer(pc),a0
	add.l	Chunk_length(pc),a0
	addq.w	#4,a0
	move.l	a0,Pointer

	cmp.l	#"IEND",(a1)
	bne.s	Png_ctrl_chunk

	moveq	#-3,d0		 il manque soit l'idat soit IDHR

	tst.w	d1
	bne.s	Chunk_error

; Controle de la valeur de differents type graphiques

	moveq	#-4,d0

	tst.b	Filter
	bne.s	Chunk_error		

	cmp.b	#1,Interlace
	bgt.s	Chunk_error

	cmp.b	#6,Colortype
	bgt.s	Chunk_error

	moveq	#0,d1
	move.b	Colortype(pc),d1
	move.b	Color_type_table(pc,d1.w),d2
	bmi.s	Chunk_error

	move.b	Bitdepth(pc),d1
	cmp.b	#1,d1
	blt.s	Chunk_error
	cmp.b	#16,d1
	bgt.s	Chunk_error
	move.w	d1,d2
	subq.w	#1,d2
	and.w	d1,d2
	bne.s	Chunk_error

	moveq	#0,d0		; No error

Chunk_error:
	tst.l	d0
	movem.l	(a7)+,d1-d7/a0-a6
	rts

Color_type_table:
	dc.b	0,-1,0,0,0,-1,0
	EVEN	

Control_png_file_end:


; *************************************************************************************************
; *************************************************************************************************
; *************************************************************************************************
;                              Here come the real routine


; a0.l : Picture adr 

Process_png_file:
	movem.l	d0-d7/a0-a6,-(a7)

	addq.w	#8,a0	; Jump signature
	move.l	a0,Pointer
	
	move.l	a1,GT_Tree_adr

	lea	Chunk_name(pc),a1

	sf	First_idat_flag

Png_main_bcl:
	jsr	Read_chunk(pc)

	cmp.l	#"IDAT",(a1)
	bne.s	Pas_chunk_idat

; ************************************************************

	tst.b	First_idat_flag
	bne.s	Pas_first_idat_donc_pac_recopie

	move.l	Pointer(pc),a2		; Data size
	move.l	a2,Gluing_adr
	add.l	Chunk_length(pc),a2	; Chunk size, because we don't recopy first one

	st	First_idat_flag

	bra.s	Exit_read_idat
Pas_first_idat_donc_pac_recopie:

	move.l	Pointer(pc),a0
	move.l	Glue_pnt(pc),a2

	move.l	Chunk_length(pc),d7

	subq.l	#1,d7
	
Copy_idat_data_to_p_datastream:	
	move.b	(a0)+,(a2)+

	subq.l	#1,d7
	bpl.s	Copy_idat_data_to_p_datastream

Exit_read_idat:
	move.l	a2,Glue_pnt

; ************************************************************

Pas_chunk_idat:

	move.l	Pointer(pc),a0
	add.l	Chunk_length(pc),a0
	addq.w	#4,a0
	move.l	a0,Pointer

	cmp.l	#"IEND",(a1)
	bne.s	Png_main_bcl

; Reste plus qu'a traiter le datastream

	move.l	Gluing_adr(pc),a6

	addq.w	#2,a6	; Jump Fcheck, dico et amstramgram

; *******************************************************

	move.l	a6,Big_pnt
	clr.w	A6_bit_cnt


	jsr	Init_all_for_fixed_code(pc)

; ************************************************************************
; ************************************************************************
;  JUMP JUMP !!

	move.l	Output_stream_adr,a5


; **********************************************************************
; ************************   Main boucle *******************************
; **********************************************************************

Traite_le_zblib_datastream:
	jsr	Readbitfromstream(pc)	; Next bit
	move.b	d7,d0
	move.b	d7,Fbit		; Final bit

	moveq	#0,d0
	jsr	Readbitfromstream(pc)
	move.b	d7,d0

	jsr	Readbitfromstream(pc)
	add.w	d7,d7
	or.w	d7,d0
	move.b	d0,Btype		; Btype

; **************************************************************

	tst.b	Btype
	bne.s	Pas_unpacked_data
	jsr	Unpacked_data(pc)	; Bloc pas compact‚
Pas_unpacked_data:

	cmp.b	#1,Btype
	bne.s	Pas_fixed_code
	jsr	Fixed_code(pc)		; Bloc fixed code
Pas_fixed_code:

	cmp.b	#2,Btype
	bne.s	Pas_code	
	jsr	Var_code(pc)		; Bloc fixed code
	jsr	Fixed_code(pc)
Pas_code:

	tst.b	Fbit
	beq.s	Traite_le_zblib_datastream

Jump_it:

; **********************************************************************
; ******************* End of Main boucle *******************************
; **********************************************************************

	move.l	a5,d0
	sub.l	Output_stream_adr,d0
	
	move.l	Output_stream_adr,Buffer_pnt

	tst.b	Interlace
	beq.s	Pas_de_desentrelacement_a_faire

	jsr	Disentrelacing_rout(pc)

	move.l	Output_buffer_adr,Buffer_pnt	

	bra.s	Interlace_end

Pas_de_desentrelacement_a_faire:

; **************************************************************************

	move.w	X_size+2(pc),d7
	move.w	Y_size+2(pc),d6
	jsr	Filtering(pc)

Interlace_end:

	movem.l	(a7)+,d0-d7/a0-a6
	rts

; *********************************************************************
; *********************************************************************

Disentrelacing_rout:
	movem.l	d0-d7/a0-a6,-(a7)

	move.l	Output_stream_adr,a6
	move.l	Output_buffer_adr,a5

	lea	Tab_pass(pc),a1
	lea	Off_x_pass(pc),a0

	moveq	#7-1,d5
Make_all_pass:
	move.l	a6,Buffer_pnt

	move.l	(a1)+,(a0)
	move.l	(a1)+,4(a0)

	move.l	X_size(pc),d7
	sub.w	Off_x_pass,d7
	divu	(a1)+,d7

	tst.w	d7
	beq	Jump_this_pass

	move.l	d7,d4
	swap	d4
	tst.w	d4
	beq.s	Pas_de_padding_byte_en_x	;
	addq.w	#1,d7
Pas_de_padding_byte_en_x:

	move.l	Y_size(pc),d6
	divu	(a1)+,d6
	tst.w	d6
	beq	Jump_this_pass

	jsr	Filtering(pc)

	jsr	One_pass(pc)

Jump_this_pass:
	dbra	d5,Make_all_pass

	movem.l	(a7)+,d0-d7/a0-a6
	rts

Tab_pass:
	dc.w	0,0,8,8,8,8
	dc.w	4,0,8,8,8,8
	dc.w	0,4,4,8,4,8
	dc.w	2,0,4,4,4,4
	dc.w	0,2,2,4,2,4
	dc.w	1,0,2,2,2,2
	dc.w	0,1,1,2,1,2

; *****************************************************************************

One_pass:	movem.l	d0-d7/a0-a5,-(a7)

	subq.w	#1,d6
	subq.w	#1,d7 
	move.w	d7,d5

	cmp.b	#8,Bitdepth
	blt	One_pass_bit

	move.w	X_size+2(pc),d0
	mulu	Bytpp,d0
	addq.w	#1,d0			; Pour le byte filter
	move.w	d0,Line_offset

	move.w	Add_x_pass(pc),d0
	mulu	Bytpp,d0
	move.w	d0,Add_ch_pass

	move.w	Add_y_pass(pc),d0
	mulu	Line_offset(pc),d0
	move.w	d0,Precalc_y_add

; ***********************************************

	move.w	Off_x_pass(pc),d0
	mulu	Bytpp(pc),d0
	move.w	d0,Precalc_x_offset

	move.w	Off_y_pass(pc),d0
	mulu	Line_offset(pc),d0
	add.l	d0,a5

	move.w	Add_ch_pass(pc),d0
	move.w	Precalc_y_add(pc),d1
	move.w	Bytpp(pc),d2
	subq.w	#1,d2
	move.w	Precalc_x_offset,d3

Fill_lines_1:
	move.b	(a6)+,(a5)			; Recup le filter byte

	lea	1(a5,d3.w),a4		; O-o

	move.w	d5,d7
Fill_une_ligne_1:
	move.l	a4,a3

	move.w	d2,d4
Disentrelace_all_channels:
	move.b	(a6)+,(a3)+
	dbra	d4,Disentrelace_all_channels
	add.w	d0,a4
	dbra	d7,Fill_une_ligne_1

	add.w	d1,a5
	dbra	d6,Fill_lines_1

	movem.l	(a7)+,d0-d7/a0-a5
	rts

; ********************************************************
; ********************************************************

One_pass_bit:
	moveq	#0,d0
	move.b	Bitdepth,d0
	mulu	X_size+2,d0
	addq.w	#7,d0
	lsr.w	#3,d0
	addq.w	#1,d0
	move.w	d0,Line_offset

	cmp.b	#1,Bitdepth
	beq	Desen_1_bit

	cmp.b	#2,Bitdepth
	beq	Desen_2_bit

	move.w	d7,d1
	addq.w	#1,d1

	moveq	#0,d0
	move.b	Bitdepth,d0
	mulu	d1,d0		; Calcul du nb bit dans la src
	addq.w	#7,d0
	lsr.w	#3,d0	
	addq.w	#1,d0
	move.w	d0,Techno

	lea	Tab_4_bits_desen,a0

	moveq	#0,d2
	move.l	a6,a3

	move.w	Off_y_pass,d3
Fill_all_lines_4_bits:
	move.b	(a6)+,d0		; Filter byte

	move.w	d5,d7
	move.w	Off_x_pass,d4
Fill_one_line_4_bits:
	lea	1(a5),a4

	move.b	(a6),d1
	tst.w	d2
	beq.s	Swap_for_4bit_lower

	not.w	d2
	and.b	#$f,d1
	addq.w	#1,a6
	bra.s	bit4_lower
Swap_for_4bit_lower:
	lsr.b	#4,d1
	not.w	d2
bit4_lower:

	move.w	d3,d0
	mulu	Line_offset,d0
	add.w	d0,a4

	move.w	d4,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	0(a0,d0.w),a4

	tst.w	2(a0,d0.w)
	beq.s	Pas_decal_4_bits
	lsl.b	#4,d1
Pas_decal_4_bits:
	or.b	d1,(a4)

	add.w	Add_x_pass,d4
	dbra	d7,Fill_one_line_4_bits

	add.w	Techno,a3
	move.l	a3,a6

	add.w	Add_y_pass,d3
	dbra	d6,Fill_all_lines_4_bits

	bra	Disen_bit_end

; *****************************************************
; Padding bits ? Fuck YOU !!! Fucking picture format !!

Desen_2_bit:	lea	Tab_2_bits_desen,a0

	move.w	d7,d0		; Calcul du nb bit dans la src
	add.w	d0,d0
	addq.w	#7,d0
	lsr.w	#3,d0	
	addq.w	#1,d0
	move.w	d0,Techno

	move.l	a6,a3

	move.w	Off_y_pass,d3
Fill_all_lines_2_bits:
	move.b	(a6)+,(a5)		; Filter byte

	moveq	#6,d1
	move.w	d5,d7
	move.w	Off_x_pass,d4
Fill_one_line_2_bits:
	move.l	a5,a4
	addq.w	#1,a4

	move.b	(a6),d2
	lsr.b	d1,d2
	and.b	#%11,d2

	move.w	d3,d0
	mulu	Line_offset,d0
	add.l	d0,a4

	move.w	d4,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	0(a0,d0.w),a4
	move.w	2(a0,d0.w),d0

	lsl.b	d0,d2

	or.b	d2,(a4)

	subq.w	#2,d1
	bpl.s	Pas_youp
	moveq	#6,d1
	addq.w	#1,a6
Pas_youp:

	add.w	Add_x_pass,d4
	dbra	d7,Fill_one_line_2_bits

	add.w	Techno,a3
	move.l	a3,a6

	add.w	Add_y_pass,d3
	dbra	d6,Fill_all_lines_2_bits

	bra	Disen_bit_end

; *****************************************************

Desen_1_bit:
	lea	Tab_1_bits_desen,a0

	move.w	d7,d0		; Calcul du nb bit dans la src
	addq.w	#7,d0
	lsr.w	#3,d0	
	addq.w	#1,d0
	move.w	d0,Techno


	move.l	a6,a3

	move.w	Off_y_pass,d3
Fill_all_lines_1_bits:
	move.b	(a6)+,(a5)		; Filter byte

	moveq	#7,d1
	move.w	d5,d7
	move.w	Off_x_pass,d4
Fill_one_line_1_bits:
	lea	1(a5),a4

	move.w	d3,d0
	mulu	Line_offset,d0
	add.l	d0,a4

	move.w	d4,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	0(a0,d0.w),a4
	move.w	2(a0,d0.w),d2

	btst	d1,(a6)
	beq.s	Pas_one_pixel
	bset	d2,(a4)
Pas_one_pixel:

	subq.w	#1,d1
	bpl.s	Pas_youp_1
	moveq	#7,d1
	addq.w	#1,a6
Pas_youp_1:

	add.w	Add_x_pass,d4
	dbra	d7,Fill_one_line_1_bits

	add.w	Techno,a3
	move.l	a3,a6

	add.w	Add_y_pass,d3
	dbra	d6,Fill_all_lines_1_bits


; *****************************************************

Disen_bit_end:
	movem.l	(a7)+,d0-d7/a0-a5
	rts


; ********************************************************************
; ********************************************************************
; d7.w : X size
; d6.w : Y size

Filtering:	movem.l	d0-d7/a0-a6,-(a7)

	move.w	d7,X_filter
	move.w	d6,Y_filter

; *****************************************************************************
; Bon on va calculer le nb de boucles a executer pour faire toute la ligne
; en tenant compte de l'alpha qui fait de toute fa‡on partie des channels
; mais surtout a un bitdepth de 16 !!

	clr.w	Line_cnt

; Calcul du nombre d'octets par ligne ((X_size*bitdepth)/8))

	moveq	#0,d0
	move.b	Bitdepth,d0
	mulu	Nb_channel,d0
	mulu	d7,d0
	addq.w	#7,d0
	lsr.l	#3,d0
	move.w	d0,Line_offset_raw

	subq.w	#1,d0			; -1 coz dbra
	move.w	d0,Line_size
	addq.w	#2,d0
	move.w	d0,Line_offset

; *****************************************************************************

	move.l	Buffer_pnt,a1

	subq.w	#1,d6
Make_all_lines:
	moveq	#0,d0
	move.b	(a1)+,d0

	cmp.b	#1,d0
	beq.s	Filtre_1

	cmp.b	#2,d0
	beq.s	Filtre_2

	cmp.b	#3,d0
	beq.s	Filtre_3

	cmp.b	#4,d0
	beq	Filtre_4

; **************************************************************************
; Par defaut le Zero !! Comme cela si il y a une merde :)
Filtre_0:

	add.w	Line_offset_raw(pc),a1
	bra	Filtre_fini

; **************************************************************************
Filtre_1:

	move.l	a1,a2	
	move.l	a1,a3
	add.w	Bytpp,a3

	move.w	Line_size,d7
	sub.w	Bytpp,d7

	moveq	#0,d0
Application_du_filtre_1:
	move.b	(a2)+,d0
	add.b	d0,(a3)+			; 12+4
	dbra	d7,Application_du_filtre_1

	move.w	Line_size,d7
	sub.w	Bytpp,d7

	add.w	Line_offset_raw,a1
	bra	Filtre_fini

; **************************************************************************
Filtre_2:
	move.l	a1,a2	
	move.l	a1,a3
	sub.w	Line_offset,a2

	tst.w	Line_cnt
	beq.s	Filtre_0

	move.w	Line_size,d7
Application_du_filtre_2:
	move.b	(a2)+,d0
	add.b	d0,(a3)+			; 12+4
	dbra	d7,Application_du_filtre_2

	add.w	Line_offset_raw,a1
	bra	Filtre_fini

; **************************************************************************
Filtre_3:
	move.l	a1,a2	
	move.l	a1,a3
	move.l	a1,a4

	sub.w	Line_offset,a2	; Pointe sur Y-1
				; Le premier pixel on le fait a la main
	move.w	Bytpp,d7		; Ca evite le test et on gagne meme quelques cycles
	subq.w	#1,d7

	tst.w	Line_cnt
	beq.s	Line_0_filtre_3

	moveq	#0,d0
Pre_application_du_filtre_3:
	move.b	(a2)+,d0
	lsr.b	d0
	add.b	d0,(a3)+			; 12+4
	dbra	d7,Pre_application_du_filtre_3

; donc a4 a maintenant un pixel de retard !!! Ce qu'il nous fallait	

	move.w	Line_size,d7
	sub.w	Bytpp,d7
	moveq	#0,d0
	moveq	#0,d1
Application_du_filtre_3:
	move.b	(a2)+,d0		; B
	move.b	(a4)+,d1		; A
	add.w	d1,d0		; Add sur 9 bits
	lsr.w	d0		; ramene sur 8
	add.b	d0,(a3)+		; et FINIT !!!
	dbra	d7,Application_du_filtre_3

	add.w	Line_offset_raw,a1
	bra	Filtre_fini

; *****************************************

Line_0_filtre_3:

	add.w	d7,a3
	addq.w	#1,a3

; donc a4 a maintenant un pixel de retard !!! Ce qu'il nous fallait	

	move.w	Line_size,d7
	sub.w	Bytpp,d7
	moveq	#0,d0
	moveq	#0,d1
Application_du_filtre_3_0:
	move.b	(a2)+,d0		; B
	moveq	#0,d0
	move.b	(a4)+,d1		; A
	add.w	d1,d0		; Add sur 9 bits
	lsr.w	d0		; ramene sur 8
	add.b	d0,(a3)+		; et FINIT !!!
	dbra	d7,Application_du_filtre_3_0

	add.w	Line_offset_raw,a1
	bra	Filtre_fini

; **************************************************************************

Filtre_4:
	move.l	a1,a2		; a2=a
	move.l	a1,a3		; a3=b
	move.l	a1,a4		; a4=c
	move.l	a1,a5		; resultat

	sub.w	Line_offset(pc),a3	; Pointeur pour B
	sub.w	Line_offset(pc),a4	; Pointeur pour C

	move.w	Bytpp,d7
	subq.w	#1,d7
Pre_application_du_filtre_4:
	move.b	(a3)+,d0
	add.b	d0,(a5)+		; Et l'additionne a notre octet courant
	dbra	d7,Pre_application_du_filtre_4

	move.w	Line_size,d7
	sub.w	Bytpp,d7

	move.l	d6,-(a7)

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2

Application_du_filtre_4:
	move.b	(a2)+,d0			; A_pr
	move.b	(a3)+,d1			; B_pr
	move.b	(a4)+,d2			; C_pr

	move.w	d1,d3		; B
	sub.w	d2,d3		; -C=Pa
	move.w	d3,d5
	bpl.s	Pas_neg_pa
	neg.w	d3		; Pa
Pas_neg_pa:

	move.w	d0,d4		; A
	sub.w	d2,d4		; -C 
	move.w	d4,d6
	bpl.s	Pas_neg_pb
	neg.w	d4		; Pb
Pas_neg_pb:

	add.w	d6,d5		; 
	bpl.s	Pas_neg_pc
	neg.w	d5		; Pc
Pas_neg_pc:

; *********************************************

	cmp.w	d4,d3		; Pa<=Pb ?
	bgt.s	Predic_label_0	; Yes

	cmp.w	d5,d3		; Pa<=Pc ?
	bgt.s	Predic_label_0	; Yes

	add.b	d0,(a5)+		; Pr=A si Pa<=Pb and Pa<=Pc
	bra.s	Predic_end

Predic_label_0:
	cmp.w	d5,d4		; Pc>Pb
	bgt.s	Predic_label_2	; Yes

	add.b	d1,(a5)+		; Sinon Pr=B
	bra.s	Predic_end

Predic_label_2:
	add.b	d2,(a5)+		; Pr=C
Predic_end:	
	dbra	d7,Application_du_filtre_4

	add.w	Line_offset_raw,a1

	move.l	(a7)+,d6

; **************************************************************************
; **************************************************************************

Filtre_fini:
	addq.w	#1,Line_cnt
	dbra	d6,Make_all_lines


	movem.l	(a7)+,d0-d7/a0-a6
	rts

; **************************************************************************
; **************************************************************************
; **************************************************************************

; ********************************************************************
; Renvoie dans d7.w le prochain bit

Readbitfromstream:
	move.l	d0,-(a7)
	move.l	a0,-(a7)

	move.l	Big_pnt(pc),a0

	move.w	A6_bit_cnt(pc),d0

	moveq	#0,d7
	btst	d0,(a0)
	beq.s	Bit_egal_a_zero
	moveq	#1,d7
Bit_egal_a_zero:

	addq.w	#1,d0
	and.w	#%111,d0
	bne.s	Pas_next_octet
	addq.l	#1,Big_pnt
Pas_next_octet:
	move.w	d0,A6_bit_cnt

	move.l	(a7)+,a0
	move.l	(a7)+,d0
	tst.w	d7
	rts

; ********************************************************************
; Renvoie dans d1.w le prochain bit

Readbitfromoutputstream:
	move.l	d0,-(a7)
	move.l	a0,-(a7)

	move.l	Big_pnt(pc),a0

	move.w	A6_bit_cnt(pc),d0

	moveq	#0,d1
	btst	d0,(a0)
	beq.s	Bit_egal_a_zero_0
	moveq	#1,d1
Bit_egal_a_zero_0:

	subq.w	#1,d0
	bpl.s	Pas_next_octet_0
	addq.l	#1,Big_pnt
	moveq	#7,d0
Pas_next_octet_0:
	move.w	d0,A6_bit_cnt

	move.l	(a7)+,a0
	move.l	(a7)+,d0
	rts

; ********************************************************************
; ********************************************************************
; out : d0.l : error if neg, else =0

Read_chunk:	movem.l	d1-d7/a0-a6,-(a7)

	move.l	Pointer(pc),a0
	move.l	(a0)+,Chunk_length
	move.l	a0,Copie_adr_chunk

	lea	Chunk_name(pc),a1

	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+

	move.l	a0,Pointer

	add.l	Chunk_length(pc),a0
	move.l	a0,Chunk_end_adr	; Fin du chunk

	moveq	#0,d0
	tst.l	d0
	movem.l	(a7)+,d1-d7/a0-a6
	rts

Extra_bit_dist:
	dc.w	0-1,0-1,0-1,0-1,1-1,1-1,2-1,2-1,3-1,3-1,4-1,4-1,5-1,5-1,6-1,6-1,7-1,7-1,8-1,8-1
	dc.w	9-1,9-1,10-1,10-1,11-1,11-1,12-1,12-1,13-1,13-1

Extra_bit_dist_base:
	dc.w	1,2,3,4,5,7,9,13,17,25,33,49,65,97,129
	dc.w	193,257,385,513,769,1025
	dc.w	1537,2049,3073,4097,6145,8193,12289
	dc.w	16385,24577

; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; Warning !!! One table is indexed on the other, so don't move them separatly

Extra_bit_length_base:
	dc.w	3,4,5,6,7,8,9,10,11,13,15,17
	dc.w	19,23,27,31,35,43,51,59,67
	dc.w	83,99,115,131,163,195,227,258

; Each value has been added by -1 (For dbra ;) )

Extra_bit_length:
	dc.w	0-1,0-1,0-1,0-1,0-1,0-1,0-1,0-1,1-1,1-1
	dc.w	1-1,1-1,2-1,2-1,2-1,2-1,3-1,3-1,3-1,3-1
	dc.w	4-1,4-1,4-1,4-1,5-1,5-1,5-1,5-1,0-1

; Each value has been mul by 2 for learning an add :)

Clcl_order:	dc.w	16*2,17*2,18*2,0,8*2,7*2,9*2,6*2,10*2,5*2,11*2,4*2,12*2,3*2,13*2,2*2,14*2,1*2,15*2

; ********************************************************************
; ********************************************************************
; ********************************************************************

Var_code:	movem.l	d0-d7/a0-a6,-(a7)

	move.l	GT_Tree_adr,a0
	move.l	LGT_Tree_adr,a1

	move.w	#33000-1,d7
	moveq	#0,d0
Clear_les_arbres_1:
	move.l	d0,(a0)+	
	move.w	d0,(a0)+	

	move.l	d0,(a1)+	
	move.w	d0,(a1)+	
	dbra	d7,Clear_les_arbres_1

; *****************************************************

	lea	DGT_Tree,a2

	moveq	#64-1,d7
	moveq	#0,d0
Clear_le_petit_arbre:
	move.w	d0,(a2)+	
	move.l	d0,(a2)+	
	dbra	d7,Clear_le_petit_arbre

; ********************************************************************************
; ********************************************************************************
; ********************************************************************************

	lea	DTree_len,a0
	lea	DTree_code,a1
	moveq	#31-1,d7		; 0 a 31 30 et 31 pas used
DInit_first_fixed_code_0:
	move.w	d0,(a0)+		; Fixed dist
	move.l	d0,(a1)+		; Fixed dist
	dbra	d7,DInit_first_fixed_code_0

; ********************************************************************************
; ********************************************************************************
; ********************************************************************************

	moveq	#5,d0
	jsr	Readxbits(pc)
	add.w	#257,d6
	move.w	d6,Hlit

	moveq	#5,d0
	jsr	Readxbits(pc)
	addq.w	#1,d6
	move.w	d6,Hdist

	moveq	#4,d0
	jsr	Readxbits(pc)
	addq.w	#4,d6
	move.w	d6,Hclen

; **********************************************************************************************
; **********************************************************************************************
; Lecture de codes

	lea	Bitlen_data,a0
	lea	Clcl_order(pc),a1

	move.l	Big_pnt(pc),a6
	move.w	A6_bit_cnt(pc),d3

	moveq	#19-1,d5
	moveq	#0,d4
Read_clcl_code:
	moveq	#0,d6

	cmp.w	Hclen(pc),d4
	bge.s	Plus_lire_des_bits

	moveq	#3-1,d0		; 3 Bits
	moveq	#0,d1
Read_3_bits:	
	btst	d3,(a6)
	beq.s	Bit_egal_a_zero_100
	bset	d1,d6
Bit_egal_a_zero_100:
	addq.w	#1,d3
	and.w	#%111,d3
	bne.s	Pas_next_octet_100
	addq.w	#1,a6
Pas_next_octet_100:
	addq.w	#1,d1
	dbra	d0,Read_3_bits
Plus_lire_des_bits:
	move.w	(a1)+,d1		* Table precalc*2
	move.w	d6,0(a0,d1.w)

	addq.w	#1,d4
	dbra	d5,Read_clcl_code

    	move.l	a6,Big_pnt
	move.w	d3,A6_bit_cnt

; **********************************************************************************************
; **********************************************************************************************

	moveq	#19,d0		; Nb d'entrees
	lea	Bitlen_data,a6	; Longueur code
	lea	LTree_code(pc),a5
	jsr	HuffmanTree_lengths(pc)		; On genere les codes

	move.l	LGT_Tree_adr,a4
	lea	LTree_code(pc),a6	; Arbre genere pour les LL code
	lea	Bitlen_data,a5	; Longueur des code
	moveq	#19,d7		; 19 code
	jsr	Generate_a_Tree(pc)

; *****************************************************************
; Lire les codes, on a Hlit litteral / Length et Hdist code for distance
; donc on boucle sur Hlit+Hdist

	sf	Flag

	clr.w	Tree_pnt

	lea	Tree_len(pc),a4

	moveq	#0,d5

; d4.w : Hlit+Hdist

	move.w	Hlit(pc),d4
	add.w	Hdist(pc),d4

	move.l	LGT_Tree_adr,a0
	move.w	A6_bit_cnt(pc),d3
Read_bitstream_clcl:
	move.l	Big_pnt(pc),a6
	move.w	Feuille_gauche(a0),Tree_pnt
	btst	d3,(a6)
	beq.s	Bit_egal_a_zero_400
	move.w	Feuille_droite(a0),Tree_pnt
Bit_egal_a_zero_400:

	addq.w	#1,d3
	and.w	#%111,d3
	bne.s	Pas_next_octet_400
	addq.l	#1,Big_pnt
Pas_next_octet_400:
	move.w	d3,A6_bit_cnt

	move.l	LGT_Tree_adr,a0
	add.w	Tree_pnt(pc),a0

	move.w	Fcar(a0),d0			; On boucle
	bmi.s	Read_bitstream_clcl

	tst.b	Flag
	bne.s	Pas_attack_dist

	cmp.w	Hlit(pc),d5			; On attaque les dist ?
	blt.s	Pas_attack_dist
	lea	Dtree_len,a4
	st	Flag
Pas_attack_dist:

	cmp.w	#15,d0
	bgt.s	Code_sup_15
	addq.w	#1,d5
	move.w	d0,(a4)+		; On range le code
	bra.s	Next_clcl_code
Code_sup_15:

	cmp.w	#16,d0
	bne.s	Code_pas_16
	moveq	#2,d0	; 2 Bits
	jsr	Readxbits(pc)
	addq.w	#3,d6
	move.w	-2(a4),d0		; Previous code
	bra.s	Copy_d6_fois_d0
Code_pas_16:

	cmp.w	#17,d0
	bne.s	Code_pas_17
	moveq	#3,d0
	jsr	Readxbits(pc)
	addq.w	#3,d6
	moveq	#0,d0
	bra.s	Copy_d6_fois_d0
Code_pas_17:

	cmp.w	#18,d0
	bne.s	Code_pas_18
	moveq	#7,d0
	jsr	Readxbits(pc)
	add.w	#11,d6
	moveq	#0,d0

Copy_d6_fois_d0:
	add.w	d6,d5
	subq.w	#1,d6
Recopy_code_0_18:	
	move.w	d0,(a4)+
	dbra	d6,Recopy_code_0_18
Code_pas_18:

Next_clcl_code:
	clr.w	Tree_pnt

	move.l	LGT_Tree_adr,a0
	move.w	A6_bit_cnt(pc),d3

	cmp.w	d4,d5
	blt	Read_bitstream_clcl

; **************************************************************************************
; **************************************************************************************
; **************************************************************************************
; **************************************************************************************
; donc on a les deux frequences des codes, on genere les codes puis les arbres

; *****************************************************************
; On gen l'arbre pour les dist

	move.w	Hlit(pc),d0
	lea	Tree_len(pc),a6
	lea	Tree_code(pc),a5
	jsr	HuffmanTree_lengths(pc)		; On genere les codes

	move.l	GT_Tree_adr,a4
	lea	Tree_code(pc),a6	; Arbre genere pour les LL code
	lea	Tree_len(pc),a5
	move.w	Hlit(pc),d7
	jsr	Generate_a_Tree(pc)

	move.w	Hdist(pc),d0		; Nb d'entrees
	lea	DTree_len(pc),a6
	lea	DTree_code(pc),a5
	jsr	HuffmanTree_lengths(pc)		; On genere les codes

	lea	DGT_Tree,a4
	lea	DTree_code(pc),a6	; Arbre genere pour les LL code
	lea	DTree_len(pc),a5
	move.w	Hdist(pc),d7
	jsr	Generate_a_Tree(pc)
	

; ************************************************************************************************

	movem.l	(a7)+,d0-d7/a0-a6
	rts

; Read X bits inv
; d0.w : bit number

Readxbits:
	subq.w	#1,d0
	moveq	#0,d6
	moveq	#0,d1
Read_x_bits:
	jsr	Readbitfromstream(pc)
	beq.s	Pas_de_bit_a_placer_ici_99
	bset	d1,d6
Pas_de_bit_a_placer_ici_99:
	addq.w	#1,d1
	dbra	d0,Read_x_bits

	rts

; ********************************************************************
; ********************************************************************
; ********************************************************************

Fixed_code:	movem.l	d0-d7/a0-a4,-(a7)

; **************************************************************************************
; **************************************************************************************
; d5.w Tree Pnt
; d4.w Dtree pnt

; a5=outputstream

	lea	Extra_bit_dist(pc),a1
	lea	Extra_bit_dist_base(pc),a4
	lea	Extra_bit_length_base(pc),a2	; Donc move it !!!

	move.w	A6_bit_cnt(pc),d3
	move.l	Big_pnt(pc),a6

	move.l	GT_Tree_adr,a0
Read_bitstream:
	move.w	Feuille_gauche(a0),d5
	btst	d3,(a6)
	beq.s	Bit_egal_a_zero_1
	move.w	Feuille_droite(a0),d5
Bit_egal_a_zero_1:
	addq.w	#1,d3
	and.w	#%111,d3
	bne.s	Pas_next_octet_1
	addq.w	#1,a6
Pas_next_octet_1:
	move.l	GT_Tree_adr,a0
	add.w	d5,a0
	move.w	Fcar(a0),d0
	bmi.s	Read_bitstream		; Si neg noeud

	cmp.w	#256,d0
	beq	Fin_de_bloc_fixed_code
	bgt.s	Decode_distance

	move.b	d0,(a5)+		; On sort direct l'octet !!
	move.l	GT_Tree_adr,a0

	bra.s	Read_bitstream

; ******************************************************************
; ******************************************************************
; Decodage de la distance

Decode_distance:
	sub.w	#257,d0
	add.w	d0,d0
	move.w	0(a2,d0.w),Nb_repeat
	move.w	29*2(a2,d0.w),d2
	bmi.s	Pas_dextra_bit_length	; non

	moveq	#0,d1
	moveq	#0,d6
Read_extra_bit_length:	
	btst	d3,(a6)
	beq.s	Bit_egal_a_zero_44
	bset	d1,d6
Bit_egal_a_zero_44:
	addq.w	#1,d3
	and.w	#%111,d3
	bne.s	Pas_next_octet_44
	addq.w	#1,a6
Pas_next_octet_44:
	addq.w	#1,d1
	dbra	d2,Read_extra_bit_length

	add.w	d6,Nb_repeat	; Repeat total donc ok !

Pas_dextra_bit_length:

;*************************************************************************

	lea	DGT_Tree,a0
Dist_decoding:
	move.w	Feuille_gauche(a0),d4
	btst	d3,(a6)
	beq.s	Bit_egal_a_zero_2
	move.w	Feuille_droite(a0),d4
Bit_egal_a_zero_2:
	addq.w	#1,d3
	and.w	#%111,d3
	bne.s	Pas_next_octet_2
	addq.w	#1,a6
Pas_next_octet_2:
	lea	DGT_Tree,a0
	add.w	d4,a0
	move.w	Fcar(a0),d0
	bmi.s	Dist_decoding

; *************************************************************************

	moveq	#0,d6
	add.w	d0,d0			; Extra bit
	move.w	0(a1,d0.w),d2		; cod‚ sur un mot
	bmi.s	Pas_dextra_bit		; Dbra

	moveq	#0,d1
Read_extra_bit:
	btst	d3,(a6)
	beq.s	Bit_egal_a_zero_99
 	bset	d1,d6
Bit_egal_a_zero_99:
	addq.w	#1,d3
	and.w	#%111,d3
	bne.s	Pas_next_octet_99
	addq.w	#1,a6
Pas_next_octet_99:
	addq.w	#1,d1
	dbra	d2,Read_extra_bit
Pas_dextra_bit:

; *****************************************************************************

	add.w	0(a4,d0.w),d6	; d0.w*2 a ‚t‚ calcul‚ avant

; donc ici on va reculer de Dist_total dans le flux de sortie (a1)
; et donc recopie de Nb_repeat 

	move.l	a5,a3
	sub.w	d6,a3

 	move.w	Nb_repeat(pc),d0
	subq.w	#1,d0
P_vas_y_recopie:
	move.b	(a3)+,(a5)+
	dbra	d0,P_vas_y_recopie

; ******************************************************************
; ******************************************************************

	move.l	GT_Tree_adr,a0
	bra	Read_bitstream

Fin_de_bloc_fixed_code:
	move.l	a6,Big_pnt
	move.w	d3,A6_bit_cnt

	movem.l	(a7)+,d0-d7/a0-a4
	rts

; ********************************************************************
; ********************************************************************
; ********************************************************************

Init_all_for_fixed_code:
	movem.l	d0-d7/a0-a6,-(a7)

	lea	Tree_len(pc),a0

	move.w	#144-1,d7
Init_first_fixed_code:
	move.w	#8,(a0)+
	dbra	d7,Init_first_fixed_code

	move.w	#112-1,d7
Init_second_fixed_code:
	move.w	#9,(a0)+
	dbra	d7,Init_second_fixed_code

	move.w	#24-1,d7
Init_third_fixed_code:
	move.w	#7,(a0)+
	dbra	d7,Init_third_fixed_code

	move.w	#8-1,d7
Init_fourth_fixed_code:
	move.w	#8,(a0)+
	dbra	d7,Init_fourth_fixed_code

	lea	DTree_len(pc),a0
	moveq	#32-1,d7		; 0 a 31 30 et 31 pas used
	moveq	#5,d0
DInit_first_fixed_code:
	move.w	d0,(a0)+		; Fixed dist
	dbra	d7,DInit_first_fixed_code

	move.l	GT_Tree_adr,a0
	move.w	#30000-1,d7
	moveq	#0,d0
Clear_cette_p1_de_zone:
	move.l	d0,(a0)+
	move.w	d0,(a0)+
	dbra	d7,Clear_cette_p1_de_zone

	move.w	#288,d0		; Nb d'entrees
	lea	Tree_len(pc),a6
	lea	Tree_code(pc),a5
	jsr	HuffmanTree_lengths(pc)		; On genere les codes

	move.l	GT_Tree_adr,a4
	lea	Tree_code(pc),a6	; Arbre genere pour les LL code
	lea	Tree_len(pc),a5
	move.w	#288,d7
	jsr	Generate_a_Tree(pc)

; ************************************************************************************************
; ************************************************************************************************
; ************************************************************************************************
; On gen l'arbre pour les dist

	moveq	#32,d0		; Nb d'entrees
	lea	DTree_len(pc),a6
	lea	DTree_code(pc),a5
	jsr	HuffmanTree_lengths(pc)		; On genere les codes

	lea	DGT_Tree,a4
	lea	DTree_code(pc),a6	; Arbre genere pour les LL code
	lea	DTree_len(pc),a5
	moveq	#32,d7
	jsr	Generate_a_Tree(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

; *********************************************************************************************************
; *********************************************************************************************************
; *********************************************************************************************************
; *********************************************************************************************************
; GT Gardener O_o

; d1.w : Free_noeud
; d2.w : Tree Pnt
; d3.w : -1
; In : a4.l Tree adr
;      a6.l Tree code
;      a5.l Tree len
;      d7.w Nb elements

Generate_a_Tree:
	movem.l	d0-d7/a0-a6,-(a7)

	move.l	a4,a0
	
	clr.l	(a0)+	; Clear two first pointers
	move.w	#-1,(a0)	; No car

	moveq	#6,d1	; Prochain noeud libre vu que le 0 c'est la racine

	subq.w	#1,d7

	moveq	#0,d4		; Car
Gen_GT_Tree:
	moveq	#0,d2		; Depart racine

	move.l	(a6)+,d6		; Le code
	move.w	(a5)+,d5		; Sa longueur
	beq.s	Gen_GT_Tree_next

	subq.w	#1,d5		; Dbra inside
	beq.s	Pose_la_feuille		; Warning !!! Pour les codes a 1 Bit !!

Scan_the_whole_code:
	move.l	a4,a0
	add.w	d2,a0

	btst	d5,d6		; 0 ou 1
	beq.s	Go_gauche		; 0 donc a gauche

; ***********************************************************************

	move.w	Feuille_droite(a0),d0	; Recup la feuille gauche
	beq.s	Create_un_noeud_a_droite

	move.w	d0,d2		; Sinon on se pose sur le noeud		
	bra.s	Whole_code

Create_un_noeud_a_droite:
	move.w	#-1,Fcar(a0)
	move.w	d1,Feuille_droite(a0)
	move.w	d1,d2

	addq.w	#6,d1	

	bra.s	Whole_code

; ***********************************************************************
Go_gauche:
	move.w	Feuille_gauche(a0),d0	; Recup la feuille gauche
	beq.s	Create_un_noeud_a_gauche

	move.w	d0,d2		; Sinon on se pose sur le noeud		
	bra.s	Whole_code

Create_un_noeud_a_gauche:

	move.w	#-1,Fcar(a0)
	move.w	d1,Feuille_gauche(a0)
	move.w	d1,d2

	addq.w	#6,d1	
		
Whole_code:

; ***********************************************************************
; ***********************************************************************

	cmp.w	#1,d5
	beq.s	Pose_la_feuille

	dbra	d5,Scan_the_whole_code

Pose_la_feuille:

	move.l	a4,a0		; On se repositionne
	add.w	d2,a0	; pour poser la feuille

	move.w	d1,d2
	move.w	#-1,Fcar(a0)

	btst	#0,d6		; 0 ou 1
	beq.s	Feuille_a_gauche		; 0 donc a gauche

; ***********************************************************************
	move.w	d1,Feuille_droite(a0)

	bra.s	Attend_les_fruits

; ***********************************************************************
Feuille_a_gauche:
	move.w	d1,Feuille_gauche(a0)

; Reste plus qu'a poser la feuille !!

Attend_les_fruits:
	move.l	a4,a0		; On se repositionne
	add.w	d2,a0	; pour poser la feuille

	addq.w	#6,d1	

	move.l	#-1,(a0)+	
	move.w	d4,(a0)

	move.w	d1,d2

Gen_GT_Tree_next:
 	addq.w	#1,d4		; Le suivant

	dbra	d7,Gen_GT_Tree

	movem.l	(a7)+,d0-d7/a0-a6
	rts
Generate_a_tree_end:

; *********************************************************************************************************
; *********************************************************************************************************
; *********************************************************************************************************
; *********************************************************************************************************
; huffman fixed length
; Routine qui genere les codes d'huffman
;
; a6.l : Tree len (Longueur des codes).w
; a5.l : Tree_code
; d0.w : Nombre de codes

HuffmanTree_lengths:
	movem.l	d0-d7/a0-a6,-(a7)

	lea	Bl_count(pc),a0
	lea	Next_code(pc),a1
	move.w	#289-1,d7
	moveq	#0,d1
Clear_bl_count:
	move.w	d1,(a0)+
	move.l	d1,(a1)+
	dbra	d7,Clear_bl_count

	subq.w	#1,d0		; A cause des dbra
	move.w	d0,d7	
	move.w	d0,d6

	move.l	a6,a0

	lea	Bl_count(pc),a1
Count_occurence:
	move.w	(a0)+,d0	; Tree len(i&)
	add.w	d0,d0		; pour pointer tab
	addq.w	#1,0(a1,d0.w)	; Bl_count=+1
	dbra	d7,Count_occurence

; **************************************************

	moveq	#0,d5

	move.w	d6,d7

	lea	Bl_count(pc),a4		; Occurences sur un mot

	lea	Next_code+4(pc),a3	; Code sur un long
Count_truc:	
	moveq	#0,d0
	move.w	(a4)+,d0
	add.l	d0,d5

	move.l	d5,d0
	add.l	d0,d0
	move.l	d0,d5

	move.l	d5,(a3)+
	dbra	d7,Count_truc

; **************************************************

	lea	Next_code(pc),a2
Last_bcl_code:
	move.w	(a6)+,d0
	beq.s	Len_egal_zero

	add.w	d0,d0
	add.w	d0,d0

	move.l	0(a2,d0.w),(a5)
	addq.l	#1,0(a2,d0.w)

Len_egal_zero:
	addq.w	#4,a5
	dbra	d6,Last_bcl_code

	movem.l	(a7)+,d0-d7/a0-a6
	rts

; *********************************************************************************************************
; *********************************************************************************************************
; *********************************************************************************************************
; *********************************************************************************************************

Unpacked_data:
	movem.l	d0-d7/a0-a4,-(a7)

	addq.w	#1,a6	; Saute Final bit and Btype

	lea	Word(pc),a0
	move.b	(a6)+,1(a0)
	move.b	(a6)+,0(a0)
	move.w	Word(pc),d7

; *************************************************
; On degage Nlen

	move.b	(a6)+,d0
	move.b	(a6)+,d0

	subq.w	#1,d7
Copy_to_idat_buffer
	move.b	(a6)+,(a5)+
	dbra	d7,Copy_to_idat_buffer
	
	move.l	a6,Big_pnt	; On repointe le stream
	clr.w	A6_bit_cnt	; sur le premier bit
	
	movem.l	(a7)+,d0-d7/a0-a4
	rts

; ********************************************************************
; ********************************************************************


; ********************************************************************
; ********************************************************************

Read_grafics_description:
	movem.l	d0-d7/a0-a6,-(a7)

	move.l	Pointer(pc),a0
	lea	X_size(pc),a1

	moveq	#4+4+5-1,d7
Copy_infos_idhr:
	move.b	(a0)+,(a1)+
	dbra	d7,Copy_infos_idhr

; ******************************************************

	moveq	#0,d0
	move.b	Colortype(pc),d0
	lsl.w	#2,d0

	lea	Color_type_channel(pc),a0
	add.w	d0,a0
	move.w	(a0)+,Nb_channel
	move.w	(a0),Alpha_flag

	moveq	#0,d0
	move.b	Bitdepth(pc),d0
	mulu	Nb_channel(pc),d0
	addq.w	#7,d0
	lsr.w	#3,d0
	move.w	d0,Bytpp

	movem.l	(a7)+,d0-d7/a0-a6
	rts

Color_type_channel:			; 6
	dc.w	1,0		; Greyscale, 1 Channel, No alpha
	dc.w	0,0		; Error
	dc.w	3,0		; True Color,3 Channel, No alpha
	dc.w	1,0		; Indexed,1 Channel, no alpha
	dc.w	2,1		; Greyscale,1 Channel,1 Alpha
	dc.w	0,0		; Error
	dc.w	4,1		; T.C., 4 Channel,1 Alpha

Read_plte:	movem.l	d0-d7/a0-a6,-(a7)
	
	move.l	Pointer(pc),a6
	move.l	Palette_pnt(pc),a0

	move.l	Chunk_length(pc),d7
	divu	#3,d7
	move.w	d7,Nb_colors

	subq.w	#1,d7
Recopy_la_pal:
	move.b	(a6)+,(a0)+
	move.b	(a6)+,(a0)+
	move.b	(a6)+,(a0)+
	dbra	d7,Recopy_la_pal

	movem.l	(a7)+,d0-d7/a0-a6
	rts

; ************************************************************************
; ************************************************************************

Convert_raw_to_argb:
	movem.l	d0-d7/a0-a6,-(a7)

	moveq	#0,d0
	move.b	Bitdepth,d0
	mulu	Nb_channel,d0
	mulu	X_size+2,d0
	addq.w	#7,d0
	lsr.w	#3,d0
	addq.w	#1,d0
	move.w	d0,Line_offset_raw

	move.l	Buffer_pnt,a4	; Buffer avec notre raw
	move.l	Screen_buffer_adr,a5

	move.w	Y_size+2,d5
	subq.w	#1,d5

	moveq	#0,d0
	move.b	Bitdepth,d0
	lsr.w	#3,d0
	move.w	d0,Alpha_add

	move.l	a4,Big_pnt
	move.l	a4,a2

Convert_all_lines:
	move.b	(a4)+,Filter_type	; Degage le filtre !!
	addq.l	#1,Big_pnt

	move.w	#7,A6_bit_cnt	

	move.w	X_size+2,d7
	subq.w	#1,d7
	moveq	#0,d4
Convert_one_line:

;******************** Palette indexed 1,2,4,8 bit of bitdepth **************************

	cmp.b	#0,Colortype	; Donc si grey palette indexed
	beq.s	Paletted_mode	; la valeur renvoy‚ est la couleur du point

	cmp.b	#4,Colortype	; Donc si grey palette indexed plus alpha
	beq.s	Paletted_mode	; la valeur renvoy‚ est la couleur du point

	cmp.b	#3,Colortype	; Donc si palette indexed
	bne	Pas_color_index	; la valeur renvoy‚ est la couleur du point

Paletted_mode:	
	moveq	#0,d0

	cmp.b	#8,Bitdepth
	beq.s	Palette_indexed_8_bit

	cmp.b	#1,Bitdepth
	beq.s	Palette_indexed_1_bit

	cmp.b	#2,Bitdepth
	beq.s	Palette_indexed_2_bit

	cmp.b	#4,Bitdepth
	beq.s	Palette_indexed_4_bit

	cmp.b	#16,Bitdepth
	beq.s	Palette_indexed_16_bit		; Gros debile !!

Palette_indexed_8_bit:
	move.b	(a4)+,d0		; Color on 8 bit index
	bra.s	Palette_indexed_commun_part

Palette_indexed_1_bit:
	jsr	Readbitfromoutputstream
	move.b	d1,d0	
	bra.s	Palette_indexed_commun_part

Palette_indexed_2_bit:
	jsr	Readbitfromoutputstream
	move.b	d1,d0	
	add.b	d0,d0
	jsr	Readbitfromoutputstream
	or.b	d1,d0	
	bra.s	Palette_indexed_commun_part

Palette_indexed_4_bit:
	tst.w	d4
	beq.s	High_quartet
	not.w	d4
	move.b	(a4)+,d0
	and.b	#$f,d0
	bra.s	Palette_indexed_commun_part

High_quartet:
	not.w	d4
	move.b	(a4),d0
	lsr.b	#4,d0
	bra.s	Palette_indexed_commun_part

Palette_indexed_16_bit:
	move.w	(a4)+,d0		; On convertit en 8 bit !!	
	lsr.w	#8,d0
	and.w	#$ff,d0

Palette_indexed_commun_part:
	move.l	Palette_pnt,a3

	mulu	#3,d0
	add.w	d0,a3

	move.b	#0,(a5)+	; Bytefiller, kill it if you only want RVB !!	
	move.b	(a3)+,(a5)+	; R
	move.b	(a3)+,(a5)+	; V
	move.b	(a3)+,(a5)+	; B

Pas_color_index:
;******************** Palette indexed 1,2,4,8 bit of bitdepth **************************

; *************** T.C. Part **************************************

	cmp.b	#2,Colortype	; Donc si palette indexed
	beq.s	Color_tc_y

	cmp.b	#6,Colortype	; Donc si palette indexed
	beq.s	Color_tc_y

	bra.s	Pas_color_TC_y	; la valeur renvoy‚ est la couleur du point

Color_tc_y:
	cmp.b	#8,Bitdepth
	beq.s	Its_8_bit_TC

; 16 Bits T.C. O_o	Converting it to 8 bits !!

	move.b	#0,(a5)+	; Bytefiller, Kill it if you only want RVB

	move.w	(a4)+,d0
	lsr.w	#8,d0
	move.b	d0,(a5)+

	move.w	(a4)+,d0
	lsr.w	#8,d0
	move.b	d0,(a5)+

	move.w	(a4)+,d0
	lsr.w	#8,d0
	move.b	d0,(a5)+

	bra.s	Pas_color_tc_y

Its_8_bit_TC:
	move.b	#0,(a5)+	; Bytefiller, ..... :)
	move.b	(a4)+,(a5)+
	move.b	(a4)+,(a5)+
	move.b	(a4)+,(a5)+

Pas_color_tc_y:

; *************** T.C. Part end **************************************

; *************** Jump alpha channel *********************************

	tst.w	Alpha_flag
	beq.s	Pas_dalpha
	add.w	Alpha_add,a4
Pas_dalpha:

; *************** Jump alpha channel *********************************

	dbra	d7,Convert_one_line

	moveq	#0,d0
	move.w	Line_offset_raw,d0
	add.w	d0,a2
	move.l	a2,a4
	move.l	a4,Big_pnt

	dbra	d5,Convert_all_lines
	
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

Init_tabs:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Tab_4_bits_desen,a0
	moveq	#0,d0		; Offset
	moveq	#0,d1		; Decal
	move.w	#(1000/2)-1,d7		; Par coup de 2 pixels
Init_tab_4_bits:
	move.w	d0,(a0)+		; Range l'offset
	move.w	#1,(a0)+		; Range le deca

	move.w	d0,(a0)+		; Range l'offset
	move.w	#0,(a0)+		; Range le deca
	addq.w	#1,d0
	dbra	d7,Init_tab_4_bits

; ********************************************

	lea	Tab_2_bits_desen,a0
	moveq	#0,d0		; Offset
	move.w	#(1000/4)-1,d7		; 
Init_tab_2_bits:

	moveq	#6,d1		; Decal
	moveq	#4-1,d6	
Init_tab_2_one_octet:
	move.w	d0,(a0)+		; Range l'offset
	move.w	d1,(a0)+		; Range le deca
	subq.w	#2,d1
	dbra	d6,Init_tab_2_one_octet

	addq.w	#1,d0
	dbra	d7,Init_tab_2_bits

; ********************************************

	lea	Tab_1_bits_desen,a0
	moveq	#0,d0		; Offset
	move.w	#(1000/8)-1,d7
Init_tab_1_bits:

	moveq	#7,d1		; Decal
	moveq	#8-1,d6	
Init_tab_1_one_octet:
	move.w	d0,(a0)+		; Range l'offset
	move.w	d1,(a0)+		; Range le deca
	subq.w	#1,d1
	dbra	d6,Init_tab_1_one_octet

	addq.w	#1,d0
	dbra	d7,Init_tab_1_bits

	movem.l	(a7)+,d0-d7/a0-a6
	rts

; ************************************************************
; Generate 'grey palette' if necessary

Gen_grey_palette:
	movem.l	d0-d7/a0-a6,-(a7)

	tst.b	Colortype
	beq.s	Go_gen_grey_palette

	cmp.b	#4,Colortype
	beq.s	Go_gen_grey_palette

	bra.s	Pas_gen_grey_palette

Go_gen_grey_palette:

	lea	Palette,a0

	moveq	#0,d0
	move.b	Bitdepth,d0

	cmp.b	#1,d0
	bne.s	Pas_1_de_prof		
	move.b	#255,d3
	moveq	#2-1,d0
Pas_1_de_prof		

	cmp.b	#2,d0
	bne.s	Pas_2_de_prof		
	move.b	#85,d3
	moveq	#4-1,d0
Pas_2_de_prof:

	cmp.b	#4,d0
	bne.s	Pas_4_de_prof		
	move.b	#17,d3
	moveq	#16-1,d0
Pas_4_de_prof:

; If bitdepth =8 or 16, same parameters, because 16 bpp pixels
; are internally converted into 8 bpp

	cmp.b	#8,d0
	beq.s	Same_val_for_grey_scale
	cmp.b	#16,d0
	beq.s	Same_val_for_grey_scale
	bra.s	Pas_16_de_prof
Same_val_for_grey_scale:
	move.b	#1,d3
	move.w	#256-1,d0
Pas_16_de_prof:


	moveq	#0,d2
Gen_a_grey_palette:	
	move.b	d2,(a0)+
	move.b	d2,(a0)+
	move.b	d2,(a0)+

	add.b	d3,d2
	dbra	d0,Gen_a_grey_palette	
	
Pas_gen_grey_palette:
	movem.l	(a7)+,d0-d7/a0-a6
	rts

Process_png_file_end:

; *******************************************************************************************************************
; *******************************************************************************************************************
;                              Png rout end............
; *******************************************************************************************************************
; *******************************************************************************************************************

Aff_picture:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Mfbd_src,a0	
	move.l	Screen_buffer_adr,(a0)+

	move.w	X_size+2,(a0)+		; Picture size in pixels
	move.w	Y_size+2,(a0)+

	moveq	#0,d0
	move.w	X_size+2,d0		;
	lsl.w	#2,d0
	lsr.w	#1,d0
	
	move.w	d0,(a0)+		; Line size in word

	move.w	#1,(a0)+		; Format
	move.w	#1,(a0)+		; Nb of planes

	clr.w	(a0)+	
	clr.w	(a0)+	
	clr.w	(a0)

; ***********************

	lea	Mfbd_src,a0
	lea	Mfbd_screen,a1
	moveq	#3,d0

	moveq	#0,d1	* X
	moveq	#0,d2	* Y

	move.w	#0,d3	* X1
	move.w	#100,d4	* Y1

	move.w	X_size+2,d5	* X dest
	subq.w	#1,d5
	move.w	Y_size+2,d6	* Y dest
	subq.w	#1,d6
	
	jsr	Vro_cpyfm(pc)


	movem.l	(a7)+,d0-d7/a0-a6
	rts

; *********************************************************************
; *********************************************************************

Print_text:	movem.l	d0-d7/a0-a6,-(a7)

	move.l	a0,-(a7)
	move.w	#9,-(a7)
	trap	#1
	addq.w	#6,a7

	movem.l	(a7)+,d0-d7/a0-a6
	rts

; ********************************************************************
; ********************************************************************
; enter : file name

Read_file:	movem.l	d0-d7/a0-a6,-(a7)

	move.l	a0,File_name
	jsr	Print_text(pc)

	lea	Cr_lf_txt,a0
	jsr	Print_text	

	move.l	File_name,a0
	jsr	Exist1

	move.l	File_length,d0
	beq	Read_file_error

	movem.l	d0-d7/a0-a6,-(a7)

	lea	File_length_txt+14,a0
	moveq	#8,d1
	jsr	Convert_to_dec

	movem.l	(a7)+,d0-d7/a0-a6

	lea	File_length_txt,a0
	jsr	Print_text

	move.l	File_length(pc),d0
	jsr	Malloc
	bmi.s	Read_file_error
	move.l	d0,File_adr

	moveq	#0,d0
	move.l	File_name(pc),d1
	jsr	Fopen(pc)
	bmi.s	Read_file_error
	move.w	d0,d7			; Handle

	move.l	File_adr,d0
	move.l	File_length(pc),d1
	move.w	d7,d2
	jsr	Fread(pc)
	bmi.s	Read_file_error

	move.w	d7,d0
	jsr	Fclose(pc)
	bmi.s	Read_file_error

	movem.l	(a7)+,d0-d7/a0-a6
	rts

Read_file_error:
	lea	Read_file_error_txt,a0
	jsr	Print_text
	
	jsr	Wait_key

	moveq	#-1,d0
	movem.l	(a7)+,d0-d7/a0-a6
	rts

File_name:	dc.l	0
File_length:
	dc.l	0
File_adr:	dc.l	0

Read_file_error_txt:
	dc.b	"Loading error....",13,10,0
	EVEN

************************************************
*                                              *
* Fclose :                                     *
* --------                                     *
*                                              *
* d0.w : Handle                                *
*                                              *
************************************************

Fclose:	movem.l	d1-d7/a0-a6,-(a7)

	move.w	d0,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.w	#4,a7

	movem.l	(a7)+,d1-d7/a0-a6
	rts

************************************************
*                                              *
* Fread :                                      *
* -------                                      *
*                                              *
* d0.l : Buffer                                *
* d1.l : Bytes Number                          *
* d2.w : Handle                                *
*                                              *
************************************************

Fread:	movem.l	d1-d7/a0-a6,-(a7)

	move.l	d0,-(a7)
	move.l	d1,-(a7)
	move.w	d2,-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7

	movem.l	(a7)+,d1-d7/a0-a6
	rts

************************************************
*                                              *
* Fopen :                                      *
* -------                                      *
*                                              *
* d0.w : Mode                                  *
* d1.l : Name Adr                              *
*                                              *
************************************************

Fopen:	movem.l	d1-d7/a0-a6,-(a7)

	move.w	d0,-(a7)
	move.l	d1,-(a7)
	move.w	#$3d,-(a7)
	trap	#1
	addq.w	#8,a7

	movem.l	(a7)+,d1-d7/a0-a6
	rts


;***********************************************
; pour v‚rifier l'existence d'un fichier sans
; g‚n‚r‚ d'erreur

Exist1:	movem.l	d0-d7/a0-a6,-(a7)

	move.l	a0,File_name

	lea	My_dta,a0
	jsr	Fsetdta(pc)

	clr.l	My_dta+26

	moveq	#0,d0
	move.l	File_name(pc),a0
	jsr	Fsfirst(pc)

	lea	My_dta+26,a0
	move.l	(a0),d0
	move.l	d0,File_length

	movem.l	(a7)+,d0-d7/a0-a6
	rts	

************************************************
*                                              *
* Fsetdta :                                    *
* ---------                                    *
*                                              *
* a0.l : New Dta Adr                           *
*                                              *
************************************************

Fsetdta:	movem.l	d1-d7/a0-a6,-(a7)

	move.l	a0,-(a7)
	move.w	#$1a,-(a7)
	trap	#1
	addq.w	#6,a7

	movem.l	(a7)+,d1-d7/a0-a6
	rts

****************************************************************
*                                                              *
* Fsfirst :                                                    *
* ---------                                                    *
*                                                              *
* In : d0.w : File Attributes                                  *
* ---- a0.l : Name Adr                                         *
*                                                              *
****************************************************************

Fsfirst:	movem.l	d1-d7/a0-a6,-(a7)

	move.w	d0,-(a7)
	move.l	a0,-(a7)	
	move.w	#$4e,-(a7)
	trap	#1
	addq.w	#8,a7

	movem.l	(a7)+,d1-d7/a0-a6
	rts

****************************************************************
*                                                              *
* Malloc :                                                     *
* --------                                                     *
*                                                              *
* d0.l : Memory Bloc Length                                    *
*                                                              *
****************************************************************

Malloc:	movem.l	d1-d7/a0-a6,-(a7)

	move.l	d0,-(a7)	
	move.w	#$48,-(a7)
	trap	#1
	addq.w	#6,a7
	tst.l	d0
	movem.l	(a7)+,d1-d7/a0-a6
	rts

****************************************************************
*                                                              *
* Mfree :                                                      *
* -------                                                      *
*                                                              *
* d0.l : Memory Bloc Adr                                       *
*                                                              *
****************************************************************

Mfree:	movem.l	d1-d7/a0-a6,-(a7)

	move.l	d0,-(a7)	
	move.w	#$49,-(a7)
	trap	#1
	addq.w	#6,a7

	movem.l	(a7)+,d1-d7/a0-a6
	rts

; ********************************************************************
; ********************************************************************
; ********************************************************************

Wait_key:	movem.l	d0-d7/a0-a6,-(a7)

	move.w	#7,-(a7)
	trap	#1
	addq.w	#2,a7

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Convert_to_dec :                             *
* ----------------                             *
*                                              *
* a0.l : Ascii buffer Adr                      *
* d0.w : Number to convert                     *
* d1.w : Number of char                        *
*                                              *
************************************************

Convert_to_dec:	movem.l	d0-d7/a0-a6,-(a7)

	moveq	#0,d4

	move.w	d1,d6
	subq.w	#1,d6

	neg.w	d1
	add.w	#$a,d1
	lsl.w	#2,d1

	lea	Number_tab(pc),a1
	add.w	d1,a1

CEn_entier:
	move.l	(a1)+,d7
	move.w	#$d0,d5
CSous_tract:
	sub.l	d7,d0
	dbmi	d5,CSous_tract
	add.l	d7,d0
	neg.b	d5

;	tst.b	d4
;	bne.s	Range_le_chiffre	
;	
;	cmp.b	#"0",d5
;	beq.s	Cest_un_premier_zero
;	moveq	#1,d4
;Range_le_chiffre:

	move.b	d5,(a0)+
Cest_un_premier_zero:
	dbra	d6,CEn_entier
;	sf	(a0)

	movem.l	(a7)+,d0-d7/a0-a6
	rts
	

Convert_to_dec_format:
	movem.l	d0-d7/a0-a6,-(a7)

	moveq	#0,d4

	move.w	d1,d6
	subq.w	#1,d6

	neg.w	d1
	add.w	#$a,d1
	lsl.w	#2,d1

	lea	Number_tab(pc),a1
	add.w	d1,a1

CEn_entier0:
	move.l	(a1)+,d7
	move.w	#$d0,d5
CSous_tract0:
	sub.l	d7,d0
	dbmi	d5,CSous_tract0
	add.l	d7,d0
	neg.b	d5

	move.b	d5,(a0)+
	dbra	d6,CEn_entier0

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Display_dec :                                *
* -------------                                *
*                                              *
* d0.l : Number to display                     *
* d1.b : X Display                             *
* d2.b : Y Display                             *
************************************************

Display_dec:	movem.l	d0-d7/a0-a6,-(a7)

	add.b	#$20,d1
	move.b	d1,X_locate

	add.b	#$20,d2
	move.b	d2,Y_locate

	lea	Number(pc),a0
	lea	Number_tab(pc),a1
	moveq	#9,d6
En_entier:
	move.l	(a1)+,d7
	moveq	#9,d5
	moveq	#-1,d4
Sous_tract:
	addq.b	#1,d4
	sub.l	d7,d0
	dbmi	d5,Sous_tract
	add.l	d7,d0

	add.b	#"0",d4
	move.b	d4,(a0)+
	dbra	d6,En_entier

	pea	Locate_txt(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.w	#6,a7

	movem.l	(a7)+,d0-d7/a0-a6
	rts

Locate_txt:
	dc.b	27,"Y"
Y_locate:
	dc.b	0
X_locate:
	dc.b	0		
Number:
	ds.b	10
	dc.b	0
	dc.b	0
Number_tab
	dc.l	1000000000
	dc.l	100000000
	dc.l	10000000
	dc.l	1000000
	dc.l	100000
	dc.l	10000
	dc.l	1000
	dc.l	100
	dc.l	10
	dc.l	1

************************************************
*                                              *
* Display_hex :                                *
* -------------                                *
*                                              *
* d0.l : Number to display                     *
* d1.b : X Display                             *
* d2.b : Y Display                             *
************************************************


Display_hex:	movem.l	d0-d7/a0-a6,-(a7)

	add.b	#$20,d1
	move.b	d1,X_locate

	add.b	#$20,d2
	move.b	d2,Y_locate

	lea	Number(pc),a0
	moveq	#7,d6
H_en_entier:
	move.l	d0,d1
	and.b	#$f,d1
	cmp.b	#10,d1
	blt.s	Inf_a_9
	sub.b	#10,d1
	add.b	#"A",d1
	bra.s	Range_it
Inf_a_9:
	add.b	#"0",d1		

Range_it:
	move.b	d1,0(a0,d6.w)
	lsr.l	#4,d0
	dbra	d6,H_en_entier

	pea	Locate_txt(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.w	#6,a7

	movem.l	(a7)+,d0-d7/a0-a6
	rts

; ****************************************************

Clean_this_fuckin_tree:
	movem.l	d0-d7/a0-a6,-(a7)

	move.w	#33000-1,d7
	moveq	#0,d0
Clean_the_tree:
	move.l	d0,(a0)+
	move.w	d0,(a0)+
	dbra	d7,Clean_the_tree
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

; ***************************************************************************

Init_vdi:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Contrl,a0
	move.w	#100,(a0)
	clr.w	2(a0)
	move.w	#11,6(a0)
	move.w	#1,12(a0)
	lea	Intin,a0
	moveq	#9,d0
	moveq	#1,d1
Fill_intin:
	move.w	d1,(a0)+
	dbra	d0,Fill_intin
	move.w	#2,(a0)		

	jsr	Call_vdi

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Vro_cpyfm :                                  *
* -----------                                  *
*                                              *
* a0.l : Mfbd src                              *
* a1.l : Mfbd dest                             *
* d0.w : Logic operation                       *
* d1.w : X src                                 *
* d2.w : Y src                                 *
* d3.w : X dest                                *
* d4.w : Y dest                                *
* d5.w : Taille X                              *
* d6.w : Taille Y                              *
*                                              *
************************************************

Vro_cpyfm:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Contrl,a2
	move.w	#109,(a2)		* Vro
	move.w	#4,2(a2)		* Ptsin nb
	move.w	#1,6(a2)		* Intin
	move.l	a0,14(a2)		* Mfbd src
	move.l	a1,18(a2)		* mfbd Dest

	move.w	d0,Intin

	lea	Ptsin,a2
	move.w	d1,0(a2)
	move.w	d2,2(a2)

	add.w	d5,d1
	add.w	d6,d2

	move.w	d1,4(a2)
	move.w	d2,6(a2)

********************************************************

	move.w	d3,8(a2)
	move.w	d4,10(a2)

	add.w	d5,d3
	add.w	d6,d4

	move.w	d3,12(a2)	* Meme taille x
	move.w	d4,14(a2)	* Meme taille y

	jsr	Call_vdi(pc)
		
	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Vq_extnd :                                   *
* ----------                                   *
*                                              *
* d0.w : Flag                                  *
*                                              *
************************************************

Vq_extnd:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Contrl,a0
	move.w	#102,(a0)
	clr.w	2(a0)
	move.w	#1,6(a0)

	move.w	d0,Intin

	jsr	Call_vdi(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

***************************************************************
*                                                             *
*                           Vdi                               *
*                         --------                            *
*                                                             *
***************************************************************

Call_vdi:	movem.l	d0-d7/a0-a6,-(a7)

	move.l	#Vdi_table,d1
	moveq	#$73,d0
	trap	#2
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

***************************************************************
*                                                             *
*                           Aes                               *
*                         --------                            *
*                                                             *
***************************************************************

Call_aes:	movem.l	d0-d1,-(a7)

	move.l	#Aes_table,d1
	move.w	#$c8,d0
	trap	#2
	
	movem.l	(a7)+,d0-d1
	rts

************************************************
*                                              *
* Appl_init :                                  *
* -----------                                  *
*                                              *
* Exit : Ap_id in Int_out                      *
*                                              *
************************************************

Appl_init:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.l	#$000a0002,(a0)+	* Appl_init
	move.l	#$00010000,(a0)+
	clr.w	8(a0)
	jsr	Call_aes(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* V_clswk :                                    *
* ---------                                    *
*                                              *
************************************************

V_clswk:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Contrl,a0
	move.w	#101,(a0)
	clr.w	2(a0)
	clr.w	6(a0)
	jsr	Call_vdi(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Appl_exit :                                  *
* -----------                                  *
*                                              *
************************************************


Appl_exit:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#19,(a0)	* Appl_exit
	clr.w	2(a0)
	move.w	#1,4(a0)
	clr.w	6(a0)
	jsr	Call_aes(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Fsel_input :                                 *
* ------------                                 *
*                                              *
* < Automatic STE Detection > if C.V. Cookies  *
* reading rout is installed.....               *
*                                              *
* d0.l :  String selection                     *
* d1.l :  File name string                     *
* d2.l :  Selector title (Only >=STE)          *
*                                              *
************************************************

Fsel_input:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#90,(a0)
	clr.w	2(a0)
	move.w	#2,4(a0)
	move.w	#2,6(a0)
	clr.w	8(a0)

	lea	Addr_in(pc),a0
	move.l	d0,(a0)+
	move.l	d1,(a0)+

	jsr	Call_aes(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

String_selection:	dc.b	"*.PNG",0
	ds.b	128
	EVEN

************************************************
*                                              *
* Form_alert :                                 *
* ------------                                 *
*                                              *
* d0.l : Tree adr                              *
* d1.w : Defaut Button                         *
*                                              *
************************************************

Form_alert:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#52,(a0)
	move.w	#1,2(a0)
	move.w	#1,4(a0)
	move.w	#1,6(a0)
	move.w	d1,Int_in
	move.l	d0,Addr_in
	
	jsr	Call_aes(pc)
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Find_a_file_name :                           *
* ------------------                           *
*                                              *
* a0.l : String Adr                            *
*                                              *
* Out :                                        *
* -----                                        *
*                                              *
* d0.w : Number of chars before the file name  *
*                                              *
************************************************

Find_a_file_name:
	movem.l	d1-d7/a0-a6,-(a7)

	move.b	#"\",d0
	jsr	Find_a_char(pc)
	bmi.s	Pas_darboressence_dans_le_nom_de_fichier

	jsr	Find_a_zero(pc)
	move.w	d0,d1
	add.w	d0,a0
	move.b	#"\",d0
	jsr	Find_a_char_inv(pc)
	sub.w	d0,d1
	addq.w	#1,d1
	move.w	d1,d0
	bra.s	Fichier_trouve
Pas_darboressence_dans_le_nom_de_fichier:
	moveq	#0,d0
Fichier_trouve:
	movem.l	(a7)+,d1-d7/a0-a6
	rts

************************************************
*                                              *
* Find_a_char :                                *
* -------------                                *
*                                              *
* a0.l : String adr (In)                       *
* d0.b : Char to find (In)                     *
*                                              *
* d0.w : Char counter                          *
*                                              *
************************************************

Find_a_char:	move.l	d1,-(a7)
	move.l	a0,-(a7)

	moveq	#-1,d1
Find_a_char_label:
	addq.w	#1,d1
	cmp.b	(a0)+,d0
	beq.s	Char_found
	tst.b	(a0)
	bne.s	Find_a_char_label
	moveq	#-1,d1
Char_found:
	move.w	d1,d0
	move.l	(a7)+,a0
	move.l	(a7)+,d1
	tst.w	d0
	rts

************************************************
*                                              *
* Find_a_zero :                                *
* -------------                                *
*                                              *
* a0.l : String Adr                            *
*                                              *
* Out :                                        *
* -----                                        *
*                                              *
* d0.w : Number of chars before the null byte. *
*                                              *
************************************************

Find_a_zero:	move.l	a0,-(a7)

	moveq	#0,d0
	move.w	#-1,d0
Find_a_zero_label:
	addq.w	#1,d0
	tst.b	(a0)+
	bne.s	Find_a_zero_label	

	move.l	(a7)+,a0
	tst.w	d0
	rts

************************************************
*                                              *
* Find_a_char_inv :                            *
* -----------------                            *
*                                              *
* a0.l : String adr (In)                       *
* d0.b : Char to find (In)                     *
*                                              *
* d0.w : Char counter                          *
*                                              *
************************************************

Find_a_char_inv:
	move.l	d1,-(a7)
	move.l	a0,-(a7)

	moveq	#0,d1

	cmp.b	(a0),d0
	beq.s	Char_found_inv

Find_a_char_label_inv:
	addq.w	#1,d1
	cmp.b	-(a0),d0
	beq.s	Char_found_inv
	tst.b	(a0)
	bne.s	Find_a_char_label_inv

Char_found_inv:
	move.w	d1,d0
	move.l	(a7)+,a0
	move.l	(a7)+,d1
	rts

************************************************
*                                              *
* Copy_string :                                *
* -------------                                *
*                                              *
* a0.l : String Adr                            *
* a1.l : String Destination Adr                *
*                                              *
* Out :                                        *
* -----                                        *
*                                              *
* d0.w : Number of chars copied.               *
*                                              *
************************************************

Copy_string:	move.l	a0,-(a7)
	move.l	a1,-(a7)

	move.w	#-1,d0
Copy_label:
	addq.w	#1,d0
	move.b	(a0)+,(a1)+
	bne.s	Copy_label	

	move.l	(a7)+,a1
	move.l	(a7)+,a0
	rts

; ********************************************************************
; ********************************************************************
	
	SECTION	DATA

Home_txt:	dc.b	27,"H","<< 5 Kbytes ",27,"b2","C.V.S.D. ",27,"bF","Png Decoder >>",13,10
	dc.b	"<< Main code : ",27,"b4","GT Turbo",27,"bF","          >>",13,10
	dc.b	"<< Add. Code and help :          >>",13,10
	dc.b	"<<",27,"b4"," Azrael",27,"bF",",",27,"b4","Zerosquare",27,"bF","             >>",13,10
	dc.b	"<<------------------------------->>",13,10,0

	EVEN
	
;Png_file_name:	dc.b	"D:\PICTURE.PNG\POULPI.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\BABBLE.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\ORIANNE.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\EXAMPLE.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\ESSAIS.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\JASMIN.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\KAK2.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\KAK1.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\666.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\NUR.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\TITLE.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\PLOGO.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\TH_BAR.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\TH_GOL.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\BOAT1.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\PNGGRA.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\BABOON.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\F04N2C08.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\BASN2C16.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\BASN6A16.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\BASN3P04.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\ELA_256.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\BASN6a16.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\BASN0g08.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\S09N3P02.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\F99N0G04.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\S09N3P02.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\BASI0g01.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\BASI0g04.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\TEST17.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\RGBE.PNG",0
;Png_file_name:	dc.b	"D:\PICTURE.PNG\S17I3p04.PNG",0

;Png_file_name:	dc.b	"D:\PICTURE.PNG\ERRORS\XDTN0G01.PNG",0
	EVEN

File_error:	dc.b	"File format error......",13,10,0
	EVEN

File_length_txt:
	dc.b	"File length : 00000000 bytes",13,10,0
	EVEN

Cr_lf_txt:	dc.b	13,10,0
	EVEN

Malloc_error:	dc.b	"Malloc error.....",13,10,0
	EVEN

Aes_table:	dc.l	Control,Global
	dc.l	Int_in,Int_out
	dc.l	Addr_in,Addr_out

Vdi_table:	dc.l	Contrl
	dc.l	Intin,Ptsin
	dc.l	Intout,Ptsout

; ********************************************************************
; ********************************************************************


	SECTION	BSS

************************************************
*                    VDI var                   *
************************************************

Chunk_length:	ds.l	1	
Pointer:	ds.l	1

Chunk_name:	ds.l	1
	ds.l	1

Big_pnt:	ds.l	1
A6_bit_cnt:	ds.w	1

Palette_pnt:	ds.l	1

Nb_channel:	ds.w	1
Alpha_flag:	ds.w	1
Crc_flag:	ds.b	1
First_idat_flag:
	ds.b	1
Fbit:	ds.b	1
Btype:	ds.b	1
Word:	ds.l	1
Len:	ds.w	1
Cnt:	ds.w	1
Bytpp:	ds.w	1

Techno:	ds.w	1

; *****************************************
; Don't modif the struct order

X_size:	ds.l	1
Y_size:	ds.l	1

Bitdepth	ds.b	1
Colortype	ds.b	1
Compression:	ds.b	1
Filter	ds.b	1
Interlace	ds.b	1

; *****************************************

Flag	ds.b	1

Nb_colors:	ds.w	1

X_filter:	ds.w	1
Y_filter:	ds.w	1

; *****************************************
; Don't modif the struct order

Off_x_pass:	ds.w	1
Off_y_pass:	ds.w	1
Add_x_pass:	ds.w	1
Add_y_pass:	ds.w	1

; *****************************************

Hlit:	ds.w	1
HDist:	ds.w	1
HClen:	ds.w	1

Tree_pnt:	ds.w	1
DTree_pnt:	ds.w	1

Dist_var:	ds.w	1
Nb_repeat:	ds.w	1
Dist_total:	ds.w	1
Total_repeat:	ds.w	1

Precalc_x_offset:
	ds.l	1
Precalc_y_add:	ds.l	1

Line_size:	ds.w	1
Line_cnt:	ds.w	1

Line_offset:	ds.l	1
Line_offset_raw:ds.l	1

Add_ch_pass:	ds.l	1
Copie_adr_chunk:ds.l	1
Chunk_end_adr:	ds.l	1
Filter_type:
	ds.b	1
	ds.b	1	

Tree_len:	ds.l	289
Tree_code:	ds.l	289

Bl_count:	ds.w	289
Next_code:	ds.l	289

Buffer_pnt:	ds.l	1


LTree_code:	ds.l	19	; normalement 19
Bitlen_data:ds.w	19	; Seulement 19

DTree_len:	ds.w	33
DTree_code:	ds.l	33

Gluing_adr:	ds.l	1
Glue_pnt:	ds.l	1

Alpha_add:	ds.w	1

DGT_Tree:	ds.b	64*6		; Nd gauche, Nd droit

GT_tree_adr:	ds.l	1
LGT_tree_adr:	ds.l	1

X_screen_size:	ds.w	1
Y_screen_size:	ds.w	1

; *************************************************************************
; *************************************************************************
	EVEN
My_dta:	ds.b	44

Palette:	ds.l	256
Off_aff:	ds.l	1

; *****************************************

Global:	ds.w	3
	ds.l	6
Control:	ds.w	5

Int_in:	ds.w	32
Int_out:	ds.w	8
Addr_in:	ds.l	3
Addr_out:	ds.l	1

File_name_string:
	ds.b	128

; *****************************************

Screen_buffer_adr:
	ds.l	1
Output_stream_adr:
	ds.l	1
Output_buffer_adr:
	ds.l	1


Tab_4_bits_desen:
	ds.w	(2+2)*1000
Tab_2_bits_desen:
	ds.w	(2+2)*1000
Tab_1_bits_desen:
	ds.w	(2+2)*1000

************************************************
*                    VDI var                   *
************************************************

Contrl:	ds.w	14
Intin:	ds.w	128
Intout:	ds.w	128
Ptsin:	ds.w	128
Ptsout:	ds.w	128

Mfbd_src:
	ds.l	1	* Screen adr !!!
	ds.w	1	* 
	ds.w	1	* 
	ds.w	1	* 
	ds.w	1	* 
	ds.w	1	* 
	ds.w	1	* 
	ds.w	1	* 
	ds.w	1	* 

Mfbd_screen:
	ds.l	1	* Screen adr !!!
	ds.w	1	* 
	ds.w	1	* 
	ds.w	1	* 
	ds.w	1	* 
	ds.w	1	* 
	ds.w	1	* 
	ds.w	1	* 
	ds.w	1	* 

	END
	
************************************************
*                                              *
************************************************


