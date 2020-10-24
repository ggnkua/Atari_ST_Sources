;rockyone			pour MI-3  MI-9			18/06/2017
;							        26.03.218
;a0 source
;a1 destination  32066 bytes
;
; file%  $1 pour fichiers menu Mi-9, sinon toujour $0
;
;
;			Call ATM(L source, L destination, W file%)
;			------------------------------------------
;
;
;Return in low d0 :   	 0  not error
;			-2 bad file
;.........................................................................
; source
;+ 0 	'ATM5'
;+ 4	taille image d‚compress‚
;+ 8	taille image compress‚ - 12
;+12	data image

; PIC_ALGO = 0 decrunch fichier non encod‚ avec algorythm d'image sp‚ciale.
; PIC_ALGO = 1 decrunch tous les fichiers avec ou sans image algorythm.

PIC_ALGO            EQU 1

Offset_tab          equ 0   ; 7 d‚calages plus 1 d‚calage sp‚cial
Short_char_tab      equ 8   ; 16 caractŠres courts
Pic_count           equ 24  ; 1 octet avec le nombre d'image compress‚es

        movem.l	d1-d7/a0-a6,-(SP)
	movem.l	60(sp),a0-a1

	moveq.l	#-2,d0			:R. bad file
	addq.l	#4,a0			;Compence le test suivant d‚ja

*					;effectu‚ dans MI3 & MI9
*	cmpi.l	#"ATM5",(a0)+
*       bne	end_prg

;.........................................................................
        move.l	(a0)+,d1		; taille image d‚compress‚
	tst.w	68(sp)			; File menu Mi-9 ?
	bne.s	ok_file			; yes
	cmpi.l	#32034,d1
	beq.s	ok_file
	cmpi.l	#32066,d1
	bne	end_prg			; image trop grande
ok_file:
;.........................................................................

        adda.l	d1,a1			; fin image d‚compress‚
	moveq.l	#0,d1
        move.l	(a0)+,d0		; taille fichier compress‚-12
        lea.l	0(a0,d0.l),a6		; fin image compress‚
	move.b  -(a6),pic_count(sp)	; nombre d'image compress‚	
     	move.l  a1,a2

     	move.b  -(a6),d7	; $0
     	moveq   #7,d4
     	bra     get_block_data
; d0
; d1
; d2
; d3 = length bits
; d4 = 7
; d5
; d6
; d7
; a0 = src start
; a1 = dst
; a2 = src end
; a3 = einde block ptr
; a4 = copy pointer
; a5 = table status, .h offsets, .w short chars
; a6 = src

get_bit_empty2: move.b	-(a6),d7
            	addx.b	d7,d7
            	bra.s	get_bit_cont2

delta_char: 	move.b	(a1),d0
            	cmp.b	d4,d5
            	ble.s	not_neg
            	add.b	#$F0,d5
not_neg:    	sub.b	d5,d0
            	move.b	d0,-(a1)
            	bra	tst_end

get_bit_empty0:	move.b  -(a6),d7
            	addx.b  d7,d7
            	bra.s   get_bit_cont0

length_3bits:	moveq   #3,d6
            	bsr.s   getd6_bits
            	tst.w   d5
            	bne.s   length_done
length_7bits:	moveq   #7,d6
            	bsr.s   getd6_bits
            	tst.w   d5
            	beq.s   length_13bits
            	add.w   #15,d5
            	bra.s   length_done
length_13bits:	moveq   #13,d6
            	bsr.s   getd6_bits
            	add.w   #255+15,d5
            	bra.s   length_done
length_2:   	add.b   d7,d7
            	beq.s   get_bit_empty2
get_bit_cont2:	bcs.s   short_char
            	moveq   #1,d6
            	bra.s   length_2_end

empty:      	move.b  -(a6),d7
            	addx.b  d7,d7
            	addx.w  d5,d5
            	dbra    d6,get_bits_loop
            	rts

offset:     	DC.W    0,32,96,352,864,1888,3936,8032
bits:       	DC.B    0,1,3,4,5,6,7,8

short_char: 	moveq   #3,d6
            	bsr.s   getd6_bits
            	move.w	a5,d6				; test a5.w
            	bne.s   delta_char
            	move.b  short_char_tab(sp,d5.w),-(a1)
            	bra.s   tst_end

getd6_bits: 	moveq   #0,d5
get_bits_loop:	add.b   d7,d7
            	beq.s   empty
            	addx.w  d5,d5
            	dbra    d6,get_bits_loop
            	rts

sld_start:  	move.w  d3,d5
take_lenght:	add.b   d7,d7
            	beq.s   get_bit_empty0
get_bit_cont0:	dbcs    d5,take_lenght
            	bcc.s   length_3bits
            	neg.w   d5
length_done:	add.w   d3,d5
            	beq.s   length_2
            	moveq   #2,d6
length_2_end:	move.w  d5,d2
            	bsr.s   getd6_bits
            	move.w  d5,d0
            	move.b  bits(PC,d0.w),d6
            	ext.w   d6
            	move.l  a5,d5                     ; test a5.h
            	bpl.s   spec_offset
            	addq.w  #4,d6
            	bsr.s   getd6_bits
special_offset_einde:
            	add.w   d0,d0
            	add.w   offset(PC,d0.w),d5
            	lea     1(a1,d5.w),a4
            	move.b  -(a4),-(a1)
copy_loop:  	move.b  -(a4),-(a1)
            	dbra	d2,copy_loop

tst_end:    	cmpa.l  a1,a3                     ; block done?
            	beq.s   block_end
depack_loop:    add.b   d7,d7
            	beq.s   get_bit_empty3
get_bit_cont3:	bcs.s   sld_start
            	move.b  -(a6),-(a1)               ; literal
            	cmpa.l  a1,a3                     ; fin du block ?
            	bne.s   depack_loop               ; nope, next
block_end:  	cmpa.l  a6,a0                     ; depack done ?
            	beq.s   work_done                 ; oui
            	bra.s   get_block_data

;............... use special offset table
spec_offset:	bsr.s   getd6_bits
            	move.w  d5,d1
            	lsl.w   #4,d1
            	moveq   #2,d6
            	bsr.s   getd6_bits
            	cmp.b   d4,d5
            	blt.s   table_offset
            	add.b   d7,d7
            	beq.s   get_bit_empty4
get_bit_cont4:	bcc.s   table_offset           	; Special offset is table 
;						; offset #8
             	moveq   #2,d6
            	bsr.s   getd6_bits
            	add.w   d5,d5
            	or.w    d1,d5
            	bra.s   special_offset_einde

get_bit_empty3:	move.b  -(a6),d7
            	addx.b  d7,d7
            	bra.s   get_bit_cont3

table_offset:	or.b    offset_tab(sp,d5.w),d1
            	move.w  d1,d5
            	bra.s   special_offset_einde

get_bit_empty4:	move.b  -(a6),d7
            	addx.b  d7,d7
            	bra.s   get_bit_cont4

; pic_algo
work_done:	moveq   #0,d7
            	move.b  pic_count(sp),d7	; no of pictures to decode
            	bsr.s	decod_picture
*      		lea     26(sp),sp		;???

;...............................................
 		moveq.l	#0,d0			;R. not error
end_prg:	movem.l (SP)+,d1-d7/a0-a6
            	rts
;...............................................

get_block_data:	moveq   #-1,d3
            	bsr.s   get_bit
            	bcc.s   no_special_offsets
            	move.b  -(a6),d0                ; special offset
            	lea     (sp),a4                 ; special offset table
            	moveq   #1,d1
            	moveq   #6,d2
next_offset:	cmp.b   d0,d1                   ; special offset?
            	bne.s   offset_not_special      ; nope
            	addq.w  #2,d1                   ; skip
offset_not_special:
            	move.b  d1,(a4)+                ; store offset
            	addq.w  #2,d1                   ; calc next offset
            	dbra	d2,next_offset        	; next
            	move.b  d0,(a4)+                ; store special offset
            	clr.w   d3                      ; offset table is filled
no_special_offsets:
            	swap    d3
            	bsr.s   get_bit                 ; short chars?
            	bcc.s   relatif                	; nope
            	lea     short_char_tab(sp),a4	; short char table pointer
            	moveq   #15,d0                  ; 16 short chars

next_char:  	move.b  -(a6),(a4)+             ; fill table
            	dbra	d0,next_char          ; next
            	clr.w   d3		; short char table is filled
relatif:   	move.l  d3,a5                   ; store logic
            	moveq   #0,d3
            	move.b  -(a6),d3                ; length bits
            	move.b  -(a6),d0                ; block length
            	lsl.w   #8,d0                   ;
            	move.b  -(a6),d0                ; 16 bits
            	movea.l a1,a3                   ; calc end of block
            	suba.w  d0,a3
            	bra	depack_loop             ; depack

get_bit:    	add.b   d7,d7
            	beq.s   get_bit_empty
            	rts

decod_picture:	dbra	d7,decod_algo
            	rts

decod_algo: 	subq.l	#4,30(SP)                 ; correct origsize
            	move.l	-(a2),d0
            	lea.l	0(a1,d0.l),a5
no_odd:     	lea.l	32000(a5),a0
next_plane: 	moveq   #3,d6
next_word:  	move.w  (a5)+,d0
            	moveq	#3,d5
next_bits:  	add.w	d0,d0
            	addx.w	d1,d1
            	add.w	d0,d0
            	addx.w	d2,d2
            	add.w	d0,d0
            	addx.w	d3,d3
            	add.w	d0,d0
            	addx.w	d4,d4
            	dbra	d5,next_bits
            	dbra	d6,next_word
            	movem.w	d1-d4,-8(a5)
            	cmpa.l	a5,a0
            	bne.s	next_plane
            	bra.s	decod_picture

get_bit_empty:	move.b  -(a6),d7
            	addx.b  d7,d7
            	rts

     		END
