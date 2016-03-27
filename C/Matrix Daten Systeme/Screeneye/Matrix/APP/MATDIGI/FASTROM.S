.include "MDADR.H"


;------------------------------------------------ grab_rom -----
; void grab_rom ( int vfactor ) ;
;					d0

					.export	grab_rom

grab_rom:			bsr		set_rom_vfact		; reissue vfactor
					tst.b	RGRABevenwrite		; issue grab command
					tst.b	RGRABoddwrite		; issue grab command
					rts

;------------------------------------------------ set_rom_vfact ---------
; void set_rom_vfact ( int vfactor ) ;
;	 				   		d0
VF8			.equ	$00
VF4F		.equ	$0E
VF4			.equ	$08

					.export	set_rom_vfact
			
set_rom_vfact:		move.l	a0,-(sp)			; save a0
					andi	#7,d0				; for safety
					cmpi	#3,d0				; factor == 4 ?
					beq		rvf4				; yes
				
					move	#VF8,d0				; mux for vfactor == 8
					bra		sv8
				
rvf4:				move	#VF4F,d0			; mux for vfactor 4
												; ... & fast grey
sv8:				lea		RPICformat,a0
					move.b	0(a0,d0.w),d0		; select picture format
					move.l	(sp)+,a0			; retrieve a0
					rts


used_regs			.reg	d3-d7/a2-a3

;------------------------------------------------ wait_even ----------
wait_even:			btst.b	#0,RGRABevenread	; wait until a 1/2 frame...
					bne 	wait_even	 		; ... has been captured

					rts

;------------------------------------------------ wait_odd -----------
wait_odd:			btst.b	#0,RGRABoddread		; wait until a 1/2 frame...
					bne 	wait_odd	 		; ... has been captured

					rts

;------------------------------------------------ wait_grab -----------
					.export	wait_grab
					
wait_grab:			bsr		wait_even			; wait for even 1/2 frame
					bsr		wait_odd			; wait for odd 1/2 frame
					rts
										
;------------------------------------------------ kill_half_header -----
					.import	head_y				; lines in header
kill_half_header:
.if KILLheader
					lea		REVENpicData,a1		; point to even data
					move	head_y,d5			; lines in header
					
khh_rem_line:		move	#HALFPIXWIDTH-1,d6	; width of header in words
				
khh_rem_pixel:		tst.w	(a1)				; read & discard Y+Y
					dbra	d6,khh_rem_pixel
					
					dbra	d5,khh_rem_line
.endif
					rts


;------------------------------------------------ kill_full_header -----
kill_full_header:
					lea		REVENpicData,a1		; point to even data
					lea		RODDpicData,a3		; point to odd data
					move	#HALFLINE-19,d5		; fiddle factor + 1/2 line
					
kfh_fiddle:			tst.w	(a3)				; read & discard
					dbra	d5,kfh_fiddle

.if KILLheader
					move	head_y,d6			; lines in header
					asr		#1,d6				; use half
															
kfh_rem_line:		move	#MAXdx-1,d5			; width of header in words
					
kfh_rem_pixel:		tst.w	(a1)				; read & discard Y+C
					tst.w	(a3)				; read & discard Y+C
					dbra	d5,kfh_rem_pixel
					
					dbra	d6,kfh_rem_line
.endif
					rts

ODDfetch			.equ	$21
EVENfetch			.equ	$20
;------------------------------------------------ frpr_getline -----
; void frpr_getline ( void *rgb, int source ) ;
;							a0	      d0
					.export	frpr_getline
					.import	yc_to_rgb
					
frpr_getline:		movem.l	#used_regs,-(sp)
					cmp		#ODDfetch,d0
					beq		frpr_odd
					
frpr_even:			lea		REVENpicData,a1
					bra		frpr_get

frpr_odd:			lea		RODDpicData,a1

frpr_get:			move	#HALFLINE-1,d3		; width of line / 2		

frpr_bloop:			move	(a1),d0				; y0cb
					move	(a1),d1				; y1cr
					movem.l	a1/d3,-(sp)			; save registers
					jsr		yc_to_rgb			; y0cr,y1cb ==> rgb0, rgb1
					
					movem.l	(sp)+,a1/d3			; retrieve registers
					dbra	d3,frpr_bloop
					
					movem.l	(sp)+,#used_regs
					rts


;------------------------------------------------ frp_getline -----
; void  frp_getline ( void *yc, void *source, int dx ) ;
;							a0	      a1		  d0
					.export	frp_getline

frp_getline:		move	d0,d3				; width of line 	

frp_bloop:			move	(a1),(a0)+			; y0cb/r
					dbra	d3,frp_bloop

					rts


;------------------------------------------------ fetch_rom_init -----
; void  fetch_rom_init ( void  ) ;

					.export	fetch_rom_init

fetch_rom_init:		movem.l	#used_regs,-(sp)
					tst.w	RSTARTdigitiser 	; reset fifo pointer
					bsr		kill_full_header					
					bsr		wait_even
					bsr		wait_odd

fri_return:			movem.l	(sp)+,#used_regs	; retrieve saved registers
					rts


;------------------------------------------------ fetch_rom_pic -----
; void  fetch_rom_pic ( void *buffer, int width, int lines ) ;
;							a0		      d0			d1

					.export	fetch_rom_pic

fetch_rom_pic:		movem.l	#used_regs,-(sp)
					subq	#1,d1				; line counter
					bmi		frp_return			; whoops! bad vert. res.

					subq	#1,d0				; width counter
					tst.w	RSTARTdigitiser 	; reset fifo pointer
					bsr		kill_full_header					
					bsr		wait_even
					bsr		wait_odd

frp_yloop:			lea		REVENpicData,a1
					bsr		frp_getline
					
					lea		RODDpicData,a1
					subq	#1,d1				; count the line
					bsr		frp_getline
					
					dbra	d1,frp_yloop		; next line

frp_return:			movem.l	(sp)+,#used_regs	; retrieve saved registers
					rts

;------------------------------------------------ fetch_2rom_pic -----
; void  fetch_2rom_pic ( void *buffer, int width, int lines ) ;
;							a0		      d0			d1

					.export	fetch_2rom_pic

fetch_2rom_pic:		movem.l	#used_regs,-(sp)
					subq	#1,d1				; line counter
					bmi		frp2_return			; whoops! bad vert. res.

					asr		#1,d0				; frp_getline reads 2 pixels
					subq	#1,d0				; width counter
					tst.w	RSTARTdigitiser 	; reset fifo pointer
					bsr		kill_half_header					
					bsr		wait_even

frp2_yloop:			bsr		frp_getline
					dbra	d1,frp2_yloop		; next line

frp2_return:		movem.l	(sp)+,#used_regs	; retrieve saved registers
					rts

			
;------------------------------------------------ ygrey_getline -----
ygrey_getline:		move	#SIXTEENTHLINE-1,d3	; width of line / 16		

ygrey_16loop:		move	#15,d2				; bit counter

ygrey_bloop:		move	(a1)+,d6			; get source word (Y+C)
					roxl	d7,d6				; X <-- Y??
					roxl	d5					; Bit0 <-- X (=Y??)
					dbra	d2,ygrey_bloop		; next data

					not		d5					; invert data for std. palette
					move	d5,(a0)+			; save & inc.
					dbra	d3,ygrey_16loop		; next word
					
					rts


;------------------------------------------------ Y_to_grey -----
; void  Y_to_grey ( void *buffer, void *buffer, int lines, int planes ) ;
;						a0		      a1			d0		  d1

					.export	Y_to_grey

Y_to_grey:			movem.l	#used_regs,-(sp)
					subq	#1,d0				; line counter
					bmi		ygrey_return		; whoops! bad vert. res.

					subq	#1,d1				; plane counter
					move	d0,d4				; save line counter
					movea.l	a1,a3				; save yc pointer
					
ygrey_ploop:		move	d4,d0				; get line counter
					move	d1,d7				; plane number
					addq	#1,d7				; scale 1 .. planes
					movea.l	a3,a1				; retrieve yc pointer
					
ygrey_yloop:		bsr		ygrey_getline
					dbra	d0,ygrey_yloop		; next line

					dbra	d1,ygrey_ploop		; next plane

ygrey_return:		movem.l	(sp)+,#used_regs	; retrieve saved registers
					rts




;------------------------------------------------ ayg_getline -----
ayg_getline:		move	#SIXTEENTHLINE-1,d3	; width of line / 16		

ayg_16loop:			move	#15,d2				; bit counter

ayg_bloop:			move	(a1),d6				; get source word (Y+C)
					roxl	d7,d6				; X <-- Y??
					roxl	d5					; Bit0 <-- X (=Y??)
					dbra	d2,ayg_bloop		; next data

					not		d5					; invert data for std. palette
					move	d5,(a0)+			; save & inc.
					dbra	d3,ayg_16loop		; next word
					
					rts



;------------------------------------------------ Alt_Y_to_grey -----
; void  Alt_Y_to_grey ( void *buffer, void *dummy, int lines, int planes ) ;
;						  a0		      a1		   d0		  d1

					.export	Alt_Y_to_grey

Alt_Y_to_grey:		movem.l	#used_regs,-(sp)
					subq	#1,d0				; line counter
					bmi		ayg_return			; whoops! bad vert. res.

					subq	#1,d1				; plane counter
					move	d0,d4				; save line counter

					bsr		wait_even
					bsr		wait_odd

ayg_ploop:			tst.w	RSTARTdigitiser 	; reset fifo pointer
					bsr		kill_full_header					

					move	d4,d0				; get line counter
					move	d1,d7				; plane number
					addq	#1,d7				; scale 1 .. planes

ayg_yloop:			lea		REVENpicData,a1
					bsr		ayg_getline
					
					lea		RODDpicData,a1
					subq	#1,d0				; count the line
					bsr		ayg_getline
					dbra	d0,ayg_yloop		; next line

					dbra	d1,ayg_ploop		; next plane

ayg_return:			movem.l	(sp)+,#used_regs	; retrieve saved registers
					rts



;------------------------------------------------ Y_to_mono -----
; void  Y_to_mono ( void *buffer, int lines ) ;
;						a0		      d0	

					.export	Y_to_mono

Y_to_mono:			movem.l	#used_regs,-(sp)
					subq	#1,d0				; line counter
					bmi		ymono_return		; whoops! bad vert. res.

					tst.w	RSTARTdigitiser 	; reset fifo pointer
					bsr		kill_full_header					
					bsr		wait_even
					bsr		wait_odd
					
					moveq	#1,d7				; plane number

ymono_yloop:		lea		REVENpicData,a1
					bsr		ayg_getline
					
					lea		RODDpicData,a1
					subq	#1,d0				; count the line
					bsr		ayg_getline
					
					dbra	d0,ymono_yloop		; next line

ymono_return:		movem.l	(sp)+,#used_regs	; retrieve saved registers
					rts




; *****************************************************************
; entry : 	result in d4.w
;			source in d6.b
;			table reference in d1.w
; uses :	d5

g_to_dith:			lsl		#1,d4				; LSBi <-- 0
					move.b	dither_tab(pc,d1),d5; get dither value
					cmp.b	d6,d5				; compare Y with dither value
					bhi		digd_clear			; don't set bit
			
					ori		#1,d4				; set LSbi

digd_clear:			rts							; return dith1,dith2

;dither table
;index				  0    1    2    3    4    5    6    7	y-
;x-coordinate	   15,7 14,6 13,5 12,4 11,3 10,2  9,1  8,0	coordinate
;---------------------------------------------------------------
dither_tab:
			.dc.b	168,  40, 136,   8, 160,  32, 128,   0	;0
			.dc.b	168,  40, 136,   8, 160,  32, 128,   0	;0

			.dc.b	104, 232,  72, 200,  96, 224,  64, 192	;1
			.dc.b	104, 232,  72, 200,  96, 224,  64, 192	;1

			.dc.b	152,  24, 184,  56, 144,  16, 176,  48	;2
			.dc.b	152,  24, 184,  56, 144,  16, 176,  48	;2

			.dc.b	 88, 216, 120, 248,  80, 208, 112, 240	;3
			.dc.b	 88, 216, 120, 248,  80, 208, 112, 240	;3

			.dc.b	164,  36, 132,   4, 172,  44, 140,  12	;4
			.dc.b	164,  36, 132,   4, 172,  44, 140,  12	;4

			.dc.b	100, 228,  68, 196, 108, 236,  76, 204	;5
			.dc.b	100, 228,  68, 196, 108, 236,  76, 204	;5

			.dc.b	148,  20, 180,  52, 156,  28, 188,  60 	;6
			.dc.b	148,  20, 180,  52, 156,  28, 188,  60 	;6

			.dc.b	 84, 212, 116, 244,  92, 220, 124, 252	;7
			.dc.b	 84, 212, 116, 244,  92, 220, 124, 252	;7


;------------------------------------------------ ydith_getline -----
ydith_getline:		move	#SIXTEENTHLINE-1,d7	; width of line / 16		

ydith_16loop:		move	#15,d2				; bit counter (2 bits/loop )
					clr		d4					; dith1,dith2 = 0,0
					
ydith_bloop:		move	d2,d1				; x MOD 16
					add		d3,d1				; (y MOD 8 ) * 16 + (x MOD 8)
					move	(a1),d6				; get 1st. source word (Y+C)
					lsr		#8,d6				; d6.b = Y
					bsr		g_to_dith
					
					move	(a1),d6				; get 2nd. source word (Y+C)
					lsr		#8,d6				; Y -> d6.b
					subq	#1,d2				; count 2nd. pixel
					subq	#1,d1				; table reference
					bsr		g_to_dith
					
					dbra	d2,ydith_bloop		; next data

					not		d4					; invert data for std. palette
					move	d4,(a0)+			; save & inc.
					dbra	d7,ydith_16loop		; next word
					
					rts

;------------------------------------------------ Y_to_dith -----
; void  Y_to_dith ( void *buffer, int lines ) ;
;						a0		      d0	

					.export	Y_to_dith

Y_to_dith:			movem.l	#used_regs,-(sp)
					subq	#1,d0				; line counter
					bmi		ydith_return		; whoops! bad vert. res.

					tst.w	RSTARTdigitiser 	; reset fifo pointer
					bsr		kill_full_header					
					
					bsr		wait_even
					bsr		wait_odd

ydith_yloop:		move	d0,d3				; get line counter (=y)
					andi	#7,d3				; y MOD 8
					asl		#4,d3				; (y MOD 8) * 16 [word]

					lea		REVENpicData,a1
					bsr		ydith_getline
					
					lea		RODDpicData,a1
					subq	#1,d0				; count the line
					move	d0,d3				; get line counter (=y)
					andi	#7,d3				; y MOD 8
					asl		#4,d3				; (y MOD 8) * 16 [word]
					bsr		ydith_getline
					
					dbra	d0,ydith_yloop		; next line

ydith_return:		movem.l	(sp)+,#used_regs	; retrieve saved registers
					rts



;------------------------------------------------ Y_to_2dith -----
; void  Y_to_2dith ( void *yy, int dy ) ;
;						a0		  d0	
					.export	Y_to_2dith

Y_to_2dith:			movem.l	#used_regs,-(sp)	
					subq	#1,d0				; line counter
					bmi		digd_return			; whoops! bad vert. res.

					tst.w	RSTARTdigitiser 	; reset fifo pointer
					bsr		kill_half_header
					bsr		wait_even
					
digd_yloop:			move	#WORDWIDTH-1,d7		; width of line in words		

					move	d0,d3				; get line counter (=y)
					andi	#7,d3				; y MOD 8
					asl		#4,d3				; (y MOD 8) * 16 [word]

digd_oloop:			move	#15,d2				; 16 pixels / loop 
					clr		d4					; dith1,dith2 = 0,0
			
digd_iloop:			move	(a1),d6				; get YY ( 2 * 8 bits )
					ror		#8,d6				; swap Y1 & Y2 bytes
					move	d2,d1				; x MOD 16
					add		d3,d1				; (y MOD 8 ) * 16 + (x MOD 16)
					bsr		g_to_dith			; process Y1 (in LSBy)
					
					lsr		#8,d6				; get Y1 into LSBy
					subq	#1,d2				; count 2nd. pixel
					subq	#1,d1				; table reference
					bsr		g_to_dith			; process Y2 (in LSBy)
					
					dbra	d2,digd_iloop		; next pixel pair

					not		d4					; invert data for std. palette
					move	d4,(a0)+			; dith1,dith2 --> destination++
					dbra	d7,digd_oloop		; next word

					dbra	d0,digd_yloop		; next line

digd_return:		movem.l	(sp)+,#used_regs	; retrieve saved registers
					rts



;------------------------------------------------ Y_to_2grey -----
; void  Y_to_2grey ( void *yy, void *yc, int dy, int planes ) ;
;						a0		  a1		d0		d1	

					.export	Y_to_2grey

Y_to_2grey:			movem.l	#used_regs,-(sp)	
					subq	#1,d0				; line counter
					bmi		digg_return			; whoops! bad vert. res.

					move	d0,d3				; save line counter
					subq	#1,d1				; plane counter
					move	d1,d2				; save plane counter
					movea.l	a1,a3				; save yc pointer
					
digg_ploop:			move	d3,d1				; get line counter
					move	d2,d7				; plane number
					addq	#1,d7				; scale 1 .. planes
					movea.l	a3,a1				; retrieve YC pointer
					
digg_yloop:			move	#WORDWIDTH-1,d0		; width of line / 16		

digg_16loop:		move	#7,d4				; bit counter (2 bits/loop )

digg_bloop:			move	(a1)+,d6			; get source word
					roxl	d7,d6				; X <-- Y?? (appr. bit for plane)
					roxl	d5					; Bit0 <-- X (=Y??)
					lsr		#8,d6				; d6.b = .......Y7
					roxr	d6					; Y7 --> X
					roxl	d5					; Bit0 <-- X (=Y7)	
												; d5 = ........ ......Y15,Y7
					dbra	d4,digg_bloop		; next data

					not		d5					; invert data for std. palette
					move	d5,(a0)+			; save & inc.
					dbra	d0,digg_16loop		; next word

					dbra	d1,digg_yloop		; next line

					dbra	d2,digg_ploop		; next plane

digg_return:		movem.l	(sp)+,#used_regs	; retrieve saved registers
					rts


;------------------------------------------------ Alt_Y_to_2grey -----
; void  Alt_Y_to_2grey ( void *yy, int dy, int planes ) ;
;							a0		  d0		d1	

					.export	Alt_Y_to_2grey

Alt_Y_to_2grey:		movem.l	#used_regs,-(sp)	
					subq	#1,d0				; line counter
					bmi		ay2g_return			; whoops! bad vert. res.

					move	d0,d3				; save line counter
					subq	#1,d1				; plane counter
					move	d1,d2				; save plane counter

					bsr		wait_even

ay2g_ploop:			tst.w	RSTARTdigitiser 	; reset fifo pointer
					bsr		kill_half_header

					move	d3,d1				; get line counter
					move	d2,d7				; plane number
					addq	#1,d7				; scale 1 .. planes

ay2g_yloop:			move	#WORDWIDTH-1,d0		; width of line / 16		

ay2g_16loop:		move	#7,d4				; bit counter (2 bits/loop )

ay2g_bloop:			move	(a1),d6				; get source word
												; d6 = Y15....... Y7.......
					roxl	d7,d6				; X <-- Y?? (appr. bit for plane)
					roxl	d5					; Bit0 <-- X (=Y??)
					lsr		#8,d6				; d6.b = .......Y7
					roxr	d6					; Y7 --> X
					roxl	d5					; Bit0 <-- X (=Y7)	
												; d5 = ........ ......Y15,Y7
					dbra	d4,ay2g_bloop		; next data

					not		d5					; invert data for std. palette
					move	d5,(a0)+			; save & inc.
					dbra	d0,ay2g_16loop		; next word

					dbra	d1,ay2g_yloop		; next line

					dbra	d2,ay2g_ploop		; next plane

ay2g_return:		movem.l	(sp)+,#used_regs	; retrieve saved registers
					rts

.MC68020
;------------------------------------------------ Y_to_2grey_ntc -----
; void  Y_to_2grey_ntc ( void *yy, int dy ) ;
;							a0		  d0

					.export	Y_to_2grey_ntc
					.import	grey_table

Y_to_2grey_ntc:		movem.l	#used_regs,-(sp)	
					subq	#1,d0				; line counter
					bmi		diggn_return		; whoops! bad vert. res.

					tst.w	RSTARTdigitiser		; reset fifo pointer
					bsr		kill_half_header
					
					lea		grey_table,a2		; YC --> RGB grey conversion
					bsr		wait_even

diggn_yloop:		move	#HALFPIXWIDTH-1,d3	; width of line in pixels

diggn_bloop:		move	(a1),d1				; y0y1
					move	d1,d2
					lsr		#8,d1				; 00y0
					move	(a2,d1.w*2),(a0)+
					and		#$00FF,d2			; 00y1
					move	(a2,d2.w*2),(a0)+
					dbra	d3,diggn_bloop

					dbra	d0,diggn_yloop		; next line

diggn_return:		movem.l	(sp)+,#used_regs	; retrieve saved registers
					rts
.MC68000



;------------------------------------------------ Y_to_2mono -----
; void  Y_to_2mono ( void *yy, int dy ) ;
;						a0		  d0	

					.export	Y_to_2mono

Y_to_2mono:			movem.l	#used_regs,-(sp)	
					subq	#1,d0				; line counter
					bmi		digm_return			; whoops! bad vert. res.

					tst.w	RSTARTdigitiser 	; reset fifo pointer
					bsr		kill_half_header
					
					move	#1,d7				; always 1 plane
					bsr		wait_even

digm_yloop:			move	#WORDWIDTH-1,d1		; width of line / 16		

digm_16loop:		move	#7,d4				; bit counter (2 bits/loop )

digm_bloop:			move	(a1),d6				; get source word
												; d6 = Y15....... Y7.......
					roxl	d7,d6				; X <-- Y15
					roxl	d5					; Bit0 <-- X (=Y15)
					lsr		#8,d6				; d6.b = .......Y7
					roxr	d6					; Y7 --> X
					roxl	d5					; Bit0 <-- X (=Y7)	
												; d5 = ........ ......Y15,Y7
					dbra	d4,digm_bloop		; next data

					not		d5					; invert data for std. palette
					move	d5,(a0)+			; save & inc.
					dbra	d1,digm_16loop		; next word

					dbra	d0,digm_yloop		; next line

digm_return:		movem.l	(sp)+,#used_regs	; retrieve saved registers
					rts

.MC68020
;------------------------------------------------ ygntc_getline -----
					.import	grey_table

ygntc_getline:		lea		grey_table,a2		; YC --> RGB grey conversion
					move	#MAXdx-1,d3			; width of line	

ygntc_bloop:		move	(a1),d1				; y0cb
					lsr		#8,d1				; 00y0
					move	(a2,d1.w*2),(a0)+
					dbra	d3,ygntc_bloop

					rts
.MC68000

;------------------------------------------------ Y_to_grey_ntc -----
; void  Y_to_grey_ntc ( void *buffer, int lines ) ;
;					 	        a0		   d0

					.export	Y_to_grey_ntc

Y_to_grey_ntc:		movem.l	#used_regs,-(sp)
					subq	#1,d0				; line counter
					bmi		ygntc_return		; whoops! bad vert. res.

					tst.w	RSTARTdigitiser 	; reset fifo pointer
					bsr		kill_full_header
					bsr		wait_even
					bsr		wait_odd

ygntc_yloop:		lea		REVENpicData,a1
					bsr		ygntc_getline
					
					lea		RODDpicData,a1
					subq	#1,d0				; count the line
					bsr		ygntc_getline
					
					dbra	d0,ygntc_yloop		; next line

ygntc_return:		movem.l	(sp)+,#used_regs	; retrieve saved registers
					rts

.MC68020
;------------------------------------------------ yntc_getline -----
					.import	rgb_table

yntc_getline:		lea		rgb_table,a2		; YC --> RGB conversion
					clr.l	d1					; unsigned ext for (A2,di.l*2)
					clr.l	d2
				
					move	#$FC00,d5			; y  - mask ( 6 bit )
					move	#$00F8,d6			; cr - mask ( 5 bit )

					move	#HALFLINE-1,d3		; width of line / 2		

yntc_bloop:			move	(a1),d1				; y0cb
					move	(a1),d2				; y1cr

					move	d2,d7				; get cr			d7 = y1Cr
					and		d6,d7				;					     00Cr
					lsl		#2,d7				;	 -> [9..5]			 0cr0
					move.b	d1,d4				; get cb			d4 = xxCb
					lsr.b	#3,d4				;	 -> [4..0]			 xxcb
					or.b	d4,d7				; -> cr/cb in d3	d7 = 0crb

					and		d5,d1				; get y0			d1 = y000
					or		d7,d1				;						 ycrb
					move	(a2,d1.l*2),(a0)+	; write 565 pixel

					and		d5,d2				; get y1			d2 = y100
					or		d7,d2				;						 ycrb
					move	(a2,d2.l*2),(a0)+	; write 565 pixel
					dbra	d3,yntc_bloop

					rts
.MC68000

;------------------------------------------------ Y_to_ntc -----
; void  Y_to_ntc ( void *buffer, int lines ) ;
;						a0		      d0

					.export	Y_to_ntc

Y_to_ntc:			movem.l	#used_regs,-(sp)
					subq	#1,d0				; line counter
					bmi		yntc_return			; whoops! bad vert. res.

					tst.w	RSTARTdigitiser 	; reset fifo pointer
					bsr		kill_full_header
					bsr		wait_even
					bsr		wait_odd

yntc_yloop:			lea		REVENpicData,a1
					bsr		yntc_getline
					
					lea		RODDpicData,a1
					subq	#1,d0				; count the line
					bsr		yntc_getline
					
					dbra	d0,yntc_yloop		; next line

yntc_return:		movem.l	(sp)+,#used_regs	; retrieve saved registers
					rts

used_regs332		.reg	d0/d1/d4

;------------------------------------------------ y332_getline -----
					.import	rgb_table

y332_getline:		movem	#used_regs332,-(sp)									
					lea		rgb_table,a2		; YC --> RGB conversion
					clr.l	d1					; unsigned ext for (A2,di.l*2)
					clr.l	d2
					move	#SIXTEENTHLINE-1,d3	; width of line / 16		

y332_16loop:		move	#7,d0				; bit counter

y332_bloop:			move	(a1)+,d1			; get source word (y0cb)
					move	(a1)+,d2			; get source word (y1cr)

					move	d2,d6				; get cr			d7 = y1cr
					and		#$00F8,d6			;					     00cr
					lsl		#2,d6				;	 -> [9..5]			 0cr0
					move.b	d1,d4				; get cb			d4 = xxCb
					lsr.b	#3,d4				;	 -> [4..0]			 xxcb
					or.b	d4,d6				; -> cr/cb in d3	d6 = 0crb

					and		#$FC00,d1			; get y0			d1 = y000
					or		d6,d1				;						 ycrb
					move.b	(a2,d1.l),d4
					roxl.b	d7,d4				; X <-- Y??
					roxl	d5					; Bit0 <-- X (=Y??)
					
					and		#$FC00,d2			; get y1			d2 = y100
					or		d6,d2				;						 ycrb
					move.b	(a2,d2.l),d4
					roxl.b	d7,d4				; X <-- Y??
					roxl	d5					; Bit0 <-- X (=Y??)

					dbra	d0,y332_bloop		; next data

					not		d5					; invert for std. pal.
					move	d5,(a0)+			; save & inc.
					dbra	d3,y332_16loop		; next word

					movem	(sp)+,#used_regs332								
					rts

;------------------------------------------------ Y_to_332 -----
; void  Y_to_332 ( void *buffer, void, *ycbuf, int lines ) ;
;						a0		      	  a1		d0

					.export	Y_to_332

Y_to_332:			movem.l	#used_regs,-(sp)
					subq	#1,d0				; line counter
					bmi		y332_return			; whoops! bad vert. res.

					move	d0,d4				; save line counter
					moveq	#7,d1				; planes - 1
					movea.l	a1,a3				; save yc pointer
					
y332_ploop:			move	d4,d0				; get line counter
					move	d1,d7				; plane number
					addq	#1,d7				; scale 1 .. planes
					movea.l	a3,a1				; retrieve yc pointer
					
y332_yloop:			bsr		y332_getline
					dbra	d0,y332_yloop		; next line

					dbra	d1,y332_ploop		; next plane

y332_return:		movem.l	(sp)+,#used_regs	; retrieve saved registers
					rts


;------------------------------------------ add32clip8 --------------
;	int add32clip8 ( int a8, long b32 )
;	d0					d0			d1
			.export	add32clip8
								; result ( max. bits )
add32clip8:		asr.l	#8,d1	;	20->12
				add		d1,d0	;	8+12
				bpl		a16c8_posi

				move	#0,d0	; underflow
				bra		a16c8_ok

a16c8_posi:		cmp		#255,d0
				ble		a16c8_ok
				
				move	#255,d0	; overflow
				
	a16c8_ok:	rts


;------------------------------------------ writeadd32_clip8 --------------
;	byte *writeadd32_clip8 ( byte *p, int a8, long b32 )
;	a0						a0		d0			d1
			.export	writeadd32_clip8
									; result ( max. bits )
writeadd32_clip8:
				asr.l	#8,d1		;	20->12
				add		d1,d0		;	8+12
				bpl		wa32c8_posi

				move	#0,d0		; underflow
				bra		wa32c8_ok

wa32c8_posi:	cmp		#255,d0
				ble		wa32c8_ok
				
				move	#255,d0		; overflow
				
wa32c8_ok:		move.b	d0,(a0)+
				rts





; ********************************* old routines ****************

.if 0

used_regs332		.reg	d0/d1/d4

;------------------------------------------------ y332_getline -----
					.import	rgb_table

y332_getline:		movem	#used_regs332,-(sp)									
					lea		rgb_table,a2		; YC --> RGB conversion
					clr.l	d1					; unsigned ext for (A2,di.l*2)
					clr.l	d2
					move	#SIXTEENTHLINE-1,d3	; width of line / 16		

y332_16loop:		move	#7,d0				; bit counter

y332_bloop:			move	(a1),d1				; get source word (y0cb)
					move	(a1),d2				; get source word (y1cr)

					move	d2,d6				; get cr			d7 = y1cr
					and		#$00F8,d6			;					     00cr
					lsl		#2,d6				;	 -> [9..5]			 0cr0
					move.b	d1,d4				; get cb			d4 = xxCb
					lsr.b	#3,d4				;	 -> [4..0]			 xxcb
					or.b	d4,d6				; -> cr/cb in d3	d6 = 0crb

					and		#$FC00,d1			; get y0			d1 = y000
					or		d6,d1				;						 ycrb
					move.b	(a2,d1.l),d4
					roxl	d7,d4				; X <-- Y??
					roxl	d5					; Bit0 <-- X (=Y??)
					
					and		#$FC00,d2			; get y1			d2 = y100
					or		d6,d2				;						 ycrb
					move.b	(a2,d2.l),d4
					roxl	d7,d4				; X <-- Y??
					roxl	d5					; Bit0 <-- X (=Y??)

					dbra	d0,y332_bloop		; next data

					move	d5,(a0)+			; save & inc.
					dbra	d3,y332_16loop		; next word

					movem	(sp)+,#used_regs332								
					rts

;------------------------------------------------ Y_to_332 -----
; void  Y_to_332 ( uword *buffer, int lines ) ;
;						a0		      d0

					.export	Y_to_332

Y_to_332:			movem.l	#used_regs,-(sp)
					subq	#1,d0				; line counter
					bmi		y332_return			; whoops! bad vert. res.

					move	d0,d4				; save line counter
					bsr		wait_even
					bsr		wait_odd

					moveq	#8,d1				; planes
					
y332_ploop:			tst.w	RSTARTdigitiser 	; reset fifo pointer
					bsr		kill_full_header					

					move	d4,d0				; get line counter
					move	d1,d7				; plane number
					addq	#1,d7				; scale 1 .. planes

y332_yloop:			lea		REVENpicData,a1
					bsr		y332_getline
					
					lea		RODDpicData,a1
					subq	#1,d0				; count the line
					bsr		y332_getline
					
					dbra	d0,y332_yloop		; next line

					dbra	d1,y332_ploop		; next plane

y332_return:		movem.l	(sp)+,#used_regs	; retrieve saved registers
					rts


used_reg2			.reg	d3-d7/a3

;------------------------------------------------ yy_to_ras -----
; void  yy_to_ras ( uword *yy, uword *ras, int dx, int dy, int planes ) ;
;						a0		  a1		  d0	d1			d2
; N.B. dx in words!
					.export	yy_to_ras

yy_to_ras:			movem.l	#used_reg2,-(sp)
					subq	#1,d2				; plane counter
					subq	#1,d1				; line counter
					move	d1,d7				; save line counter
					subq	#1,d0				; word counter
					move	d0,d3				; save word counter
					movea.l	a0,a3				; save line start
					
yyr_ploop:			move	d7,d1				; retrieve line counter
					movea.l	a3,a0				; retrieve line source start

yyr_yloop:			move	d3,d0				; retrieve word counter		

yyr_16loop:			move	#15,d4				; bit counter
					
yyr_bloop:			move.b	(a0),d6				; get source byte
					roxl.b	d6					; X <-- MSB....
					move.b	d6,(a0)+			; resave it & inc.
					roxl	d5					; ....LSB <-- X
					dbra	d4,yyr_bloop		; next bit

					move	d5,(a1)+			; save & inc.
					dbra	d0,yyr_16loop		; next word

					dbra	d1,yyr_yloop		; next line

					dbra	d2,yyr_ploop		; next plane
						
yyr_return:			movem.l	(sp)+,#used_reg2
					rts


;------------------------------------------------ oldg_rom_pic -----
; void  oldg_rom_pic ( void *yy, int dx, int dy ) ;
;							a0		  d0		d1

;................................................ fetch_gline ........
fetch_gline:		move	d3,d0			; for x = xlongs1 .. 0
										
flg_data_loop:		move	(a1),(a0)+		; copy 16 bits
					dbra	d0,flg_data_loop; repeat for complete line

					move	d4,d0			; for x = rest_longs-1 .. 0
					beq		flg_return		; digit.line = buf.line (finished)
					bpl		flg_skip_data	; digit.line > buf.line (read & discard)
					
					neg		d0				; -ve --> +ve
					lsl.l	#1,d0			; adjust destination pointer
					adda	d0,a0			; ... without filling
					bra		flg_return		; finished

					; skip digitizer data

flg_skip_data:
					subq	#1,d0			; use rest as counter
				
flg_skip_loop:		tst		(a1)			; read & discard 
					dbra	d0,flg_skip_loop; repeat till end of line
					
flg_return:			rts						; finished

;................................................ fetchg_rom_pic ....

					.export	oldg_rom_pic

oldg_rom_pic:		movem.l	#used_regs,-(sp)	
					move	d0,d3				; buff.line
					asr		d3					; 1 word = 2 pixels (YY)
					tst.w	RSTARTdigitiser 	; Set ODD & EVEN Pointer to zero

					lea		REVENpicData,a1		; point to data
.if KILLheader
					move	#15,d0				; remove header

oldg_rem_line:		move	#QUARTERLINE-1,d4	; digit.line
					
oldg_rem_pixel:		tst.w	(a1)				; read & discard Y+Y
					dbra	d4,oldg_rem_pixel

					dbra	d0,oldg_rem_line
.endif
					; calc loop limits
					
					move	#HALFLINE,d4		; digit.line
					sub		d3,d4				; (digit.line - buff.line)
					bpl		oldg_skip			; >= ==> skip some data

					; buffer line > digitiser line
					move	#HALFLINE,d3		; max digitizer data

oldg_skip:			subq	#1,d3				; use as counter in fetch_line
					bmi		oldg_return			; whoops! bad buff.line
					
					; fetch loops

					subq	#1,d1				; for y = dy/2-1 .. 0
					bmi		oldg_return			; whoops! bad vert. res.

					; wait for grab to finish
					
oldg_rom1:			btst.b	#0,RGRABevenread	; wait until a 1/2 frame...
					bne 	oldg_rom1 			; ... has been captured

oldg_yloop:			bsr		fetch_gline			; fetch complete line
					dbra	d1,oldg_yloop		; repeat for whole screen
	
oldg_return:		movem.l	(sp)+,#used_regs
					rts



;------------------------------------------------ testg_rom_pic -----
; void  testg_rom_pic ( uword *yy, void *src, int dy, int planes ) ;
;							a0			a1		d0			d1	

					.export	testg_rom_pic

testg_rom_pic:		movem.l	#used_regs,-(sp)	
					subq	#1,d0				; line counter
					bmi		testg_return		; whoops! bad vert. res.

					move	d0,-(sp)			; save line counter
					move	d1,d3				; planes
					subq	#1,d1				; plane counter
					move	d1,d2				; save plane counter
					movea.l	a1,a3				; save source pointer

testg_ploop:		movea.l	a3,a1				; retrieve source pointer
					move	(sp)+,d1			; get line counter
					move	d1,-(sp)			; resave line counter
					move	d2,d7				; plane number
					addq	#1,d7				; scale 1 .. planes

testg_yloop:		move	#WORDWIDTH-1,d0		; width of line / 16		

testg_16loop:		move	#7,d4				; bit counter (2 bits/loop )

testg_bloop:		move	(a1),d6				; get source word
												; d6 = Y15....... Y7.......
					roxl	d7,d6				; X <-- Y?? (appr. bit for plane)
					roxl	d5					; Bit0 <-- X (=Y15)
					lsr		#8,d6				; d6.b = .......Y7
					roxr	d6					; Y7 --> X
					roxl	d5					; Bit0 <-- X (=Y7)	
												; d5 = ........ ......Y15,Y7
					dbra	d4,testg_bloop		; next data

					move	d5,(a0)+			; save & inc.
					dbra	d0,testg_16loop		; next word

					dbra	d1,testg_yloop		; next line

					dbra	d2,testg_ploop		; next plane

testg_return:		move	(sp)+,d1			; remove line counter
					movem.l	(sp)+,#used_regs	; retrieve saved registers
					rts

.endif

