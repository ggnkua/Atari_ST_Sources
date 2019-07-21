;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION TEXT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

SPEED = 1				; 1= x2 speed / 2= x4 speed

UNREGISTER_SYNC_INIT_31 = 1

sync_init_31: MACRO
	fill_nop_9			; [31]
	movem.l	pal_bg(pc),d2-d5	;     [12] 16+8n
	move.l	logo_adr(pc),a3	;     [4]
	move.l	sync_logical(pc),a4	;     [4]
	lea	230*4+6(a4),a4	;     [2]
	ENDM

	INCLUDE	COREOVER.S

;#===============#
;# Runs the demo #
;#===============#

run_demo:

	; Clear palette
	bsr	clr_palette

	; Define new screen
	SET_PHYSBASE_OVERSCAN screen_buf,screen_adr

	; Initialise sinus tables (for background)
	lea	sinus_x(pc),a0
	move.w	#160,d0
	move.w	d0,d1
	bsr	generate_sinus
	lea	sinus_y(pc),a0
	moveq	#100,d0
	move.w	d0,d1
	bsr	generate_sinus

	; Initialise sinus tables (for bouncing logo)
	lea	sinus_logo(pc),a0
	moveq	#40,d0
	moveq	#0,d1
	bsr	generate_sinus

	lea	sinus_logo(pc),a0
	move.w	#1024-1,d0
.sin:	move.w	(a0),d1
	bpl.s	.ok
	neg.w	d1		; absolute value
.ok:	add.w	#12,d1		; +12px for margin
	move.w	d1,(a0)+
	dbra	d0,.sin

	; Initialise lut
	bsr	init_lut
	
	; Initialise scroller
	bsr	init_scroller

	; Initialise logo
	bsr	init_logo

	; Initialise background
	bsr	init_background

	; Initialize music
	moveq	#1,d0
	bsr	player

	; Set screen adress
	move.l	screen_adr,sync_logical
	bsr	sync_scroll

	; Install Fullscreen VBL routine
	lea	full_map(pc),a0
 	bsr	full_setup_realtime
	move.l	#full_vbl,VBL.w

loop:	; Display moving background
	bsr 	move_background

	; Display scroller
	bsr	move_scroller

	; Clear unused parts of the screen
	bsr	clear_screen

	; Logo start address
	lea	logo_buf,a3
	lea	sinus_logo(pc),a0
	move.w	plogo,d0
	move.w	(a0,d0.w),d1	; d1 = sinus(plogo)
	mulu	#52,d1		; d1 = sinus(plogo) * line width
	lea	(a3,d1.l),a3
	move.l	a3,logo_adr

	; Next iteration
	addq.w	#1,iteration
	addq.w	#8,px
	and.w	#$7FF,px
	add.w	#12,py
	and.w	#$7FF,py
	add.w	#20,plogo
	and.w	#$7FF,plogo

	; Set palette
	bsr.s	set_palette

	; Play music
	bsr	player+4

	; Wait for VSYNC
	bsr	vsync

	; Check keyboard 
	cmpi.b	#$39,KEYBOARD_DATA.w
	bne.s	loop

	; Sound off
	bsr	sound_off

	rts

;#-------------#
;# Clr Palette #
;#-------------#

clr_palette:
	lea	PALETTE.w,a0
	moveq	#8-1,d0
.clrpal:	clr.l	(a0)+
	dbra	d0,.clrpal
	rts

;#-------------#
;# Set Palette #
;#-------------#

set_palette:

	move.w	iteration,d0
	cmpi.w	#56,d0
	bge.s	.fade1

	and.w	#%11111000,d0
	lsl.w	#1,d0
	lea	fade_bg,a0
	lea	(a0,d0.w),a0
	movem.l	(a0),d0-d3
	movem.l	d0-d3,pal_bg
	movem.l	d0-d3,pal_logo
.fade1:
	move.w	iteration,d0
	cmpi.w	#200,d0
	blt.s	.fade2
	cmpi.w	#231,d0
	bgt.s	.fade2

	sub.w	#200,d0
	and.w	#%11111000,d0
	lsl.w	#1,d0
	lea	fade_logo,a0
	lea	(a0,d0.w),a0
	movem.l	(a0),d0-d3
	movem.l	d0-d3,pal_logo
.fade2:
	rts

;#----------------------#
;# Initialize LUT table #
;#----------------------#

init_lut:
	lea	lut(pc),a0
	moveq	#0,d1
	moveq	#0,d2
	move.w	#512-1,d6
.lut:
	move.l	d1,d7
	mulu	#230*48,d7		; (x % 16) * stripe height
	add.l	d2,d7		; + offset 0/8/16

	addq.l	#1,d1
	cmpi.w	#16,d1
	bne.s	.notmod
	clr.l	d1
	addq.l	#8,d2
	cmpi.w	#24,d2
	bne.s	.notmod
	clr.l	d2
.notmod:
	move.l	d7,(a0)+		; Save offset into LUT
	dbra	d6,.lut

	rts

;#---------------------#
;# Initialize the logo #
;#---------------------#

init_logo:
	lea	logo,a0
	lea	logo_buf+61*52,a1	; skip 61 lines (x52b)
	move.w	#181*52/4-1,d0
.copy:	move.l	(a0)+,(a1)+
	dbra	d0,.copy
	rts

;#--------------------------#
;# Initialize the 16 shifts #
;#--------------------------#
; 16 stripes + 9 copied stripes at the end

init_background:
	move.l	screen_adr,a1
	moveq	#16+9-1,d7
.init:	lea	bubbles,a0
	bsr	copy_bubble
	bsr	shift_bubble
	dbra	d7,.init
	rts

;#-------------------------#
;# Initialize the scroller #
;#-------------------------#

init_scroller:

	; Shift the font => font_wide
	lea	font(pc),a0
	lea	font_wide,a1
	move.w	#60*16-1,d7
.shift:	clr.l	d0
	move.w	(a0)+,d0
	move.l	d0,(a1)
MULT	SET 1
	REPT	8/SPEED-1
	lsl.l	#2*SPEED,d0
	move.l	d0,60*16*4*MULT(a1)
MULT	SET MULT+1
	ENDR
	addq.l	#4,a1
	dbra	d7,.shift

	rts

;#----------------------#
;# Display the scroller #
;#----------------------#

move_scroller:

	add.l	#60*64,pos_font

	add.w	#1792,posy_scroller
	cmpi.w	#1792*8/SPEED,posy_scroller
	bne.s	.noloop

	clr.w	posy_scroller

	move.l	#$FFFF0000,and_value

	move.l	pos_text,a0
	clr.w	d0
	move.b	(a0)+,d0
	sub.w	#32,d0
	lsl.w	#6,d0		; x64
	lea	font_wide,a1
	lea	(a1,d0.l),a1
	move.l	a1,pos_font
	
	cmp.l	#end_text,a0
	bne.s	.notendtxt
	move.l	#text,a0
.notendtxt:	move.l	a0,pos_text

	addq.w	#2,posx_scroller
	cmpi.w	#60,posx_scroller
	bne.s	.noloop
	move.w	#4,posx_scroller
.noloop:
	lea	font_buf,a2
	add.w	posy_scroller,a2
	add.w	posx_scroller,a2

	move.l	and_value,d5
	
	move.l	pos_font,a1
	moveq	#16-1,d0
.line:	move.l	(a1)+,d1
	and.l	d5,26*2(a2)
	or.l	d1,26*2(a2)
	move.l	26*2(a2),-4(a2)
	lea	56*2(a2),a2
	dbra	d0,.line

	rol.l	#2,d5
	move.l	d5,and_value

	rts

and_value:		dc.w	-1,0
posy_scroller:	dc.w	0
posx_scroller:	dc.w	4
pos_text:		dc.l	text
pos_font:		dc.l	font_wide

;#--------------------------#
;# Display background image #
;#--------------------------#

move_background:

	lea	sinus_x(pc),a0
	move.w	px,d0
	move.w	(a0,d0.w),d1	; x = sinus(px)
	
	lea	lut(pc),a1
	add.w	d1,d1		; x2
	add.w	d1,d1		; x4
	move.l	(a1,d1.w),d4

	lea	sinus_y(pc),a2
	move.w	py,d2
	move.w	(a2,d2.w),d5	; y = sinus(py)
	mulu	#230,d5		; y * 230
	
	move.l	screen_adr,d7
	add.l	d4,d7
	add.l	d5,d7
	move.l	d7,sync_logical
	bsr	sync_scroll

	rts

;#-------------------------#
;# Raw copy of the picture #
;#-------------------------#

copy_bubble:
	moveq	#48-1,d0
.copy:	movem.w	(a0)+,d1-d6/a3-a5
	; 16 left pixels
	movem.w	d1-d3,(a1)
	movem.w	d1-d3,24*1+8*0(a1)
	movem.w	d1-d3,24*2+8*0(a1)
	movem.w	d1-d3,24*3+8*0(a1)
	movem.w	d1-d3,24*4+8*0(a1)
	movem.w	d1-d3,24*5+8*0(a1)
	movem.w	d1-d3,24*6+8*0(a1)
	movem.w	d1-d3,24*7+8*0(a1)
	movem.w	d1-d3,24*8+8*0(a1)
	movem.w	d1-d3,24*9+8*0(a1)
	; 16 center pixels
	movem.w	d4-d6,24*0+8*1(a1)
	movem.w	d4-d6,24*1+8*1(a1)
	movem.w	d4-d6,24*2+8*1(a1)
	movem.w	d4-d6,24*3+8*1(a1)
	movem.w	d4-d6,24*4+8*1(a1)
	movem.w	d4-d6,24*5+8*1(a1)
	movem.w	d4-d6,24*6+8*1(a1)
	movem.w	d4-d6,24*7+8*1(a1)
	movem.w	d4-d6,24*8+8*1(a1)
	; 16 right pixels
	movem.w	a3-a5,24*0+8*2(a1)
	movem.w	a3-a5,24*1+8*2(a1)
	movem.w	a3-a5,24*2+8*2(a1)
	movem.w	a3-a5,24*3+8*2(a1)
	movem.w	a3-a5,24*4+8*2(a1)
	movem.w	a3-a5,24*5+8*2(a1)
	movem.w	a3-a5,24*6+8*2(a1)
	movem.w	a3-a5,24*7+8*2(a1)
	movem.w	a3-a5,24*8+8*2(a1)
	; Next line
	lea	230(a1),a1
	dbra	d0,.copy
	rts

;#-------------------#
;# Shift the picture #
;#-------------------#

shift_bubble:
	lea	bubbles,a0
	moveq	#48-1,d0
.shift:	; Plane 0
	move.w	(a0),d1
	roxl.w	d1
	roxl.w	12(a0)
	roxl.w	6(a0)
	roxl.w	(a0)
	; Plane 1
	move.w	2(a0),d1
	roxl.w	d1
	roxl.w	14(a0)
	roxl.w	8(a0)
	roxl.w	2(a0)
	; Plane 2
	move.w	4(a0),d1
	roxl.w	d1
	roxl.w	16(a0)
	roxl.w	10(a0)
	roxl.w	4(a0)
	; Next line
	lea	18(a0),a0
	dbra	d0,.shift
	rts

;#------------------------#
;# Partially clear screen #
;#------------------------#

clear_screen:

	moveq	#0,d0

	move.l	sync_logical,a0
	addq.l	#230*0+6,a0
	moveq	#4-1,d1
.top:	move.w	d0,(a0)
OFFSET	SET 8
	REPT	25
	move.w	d0,OFFSET(a0)
OFFSET	SET OFFSET+8
	ENDR
	lea	230(a0),a0
	dbra	d1,.top

	move.l	sync_logical,a0
	add.l	#230*244+6,a0
	moveq	#2-1,d1
.mid:	move.w	d0,(a0)
OFFSET	SET 8
	REPT	25
	move.w	d0,OFFSET(a0)
OFFSET	SET OFFSET+8
	ENDR
	lea	230(a0),a0
	dbra	d1,.mid

	move.l	sync_logical,a0
	add.l	#230*262+6,a0
	moveq	#6-1,d1
.bot:	move.w	d0,(a0)
OFFSET	SET 8
	REPT	25
	move.w	d0,OFFSET(a0)
OFFSET	SET OFFSET+8
	ENDR
	lea	230(a0),a0
	dbra	d1,.bot

	rts

;#---------------------#
;# Fullscreen routines #
;#---------------------#

full_line:
	switch_res_hi_low		; [ 5] Left border
	fill_nop_89			; [89]
	switch_freq_60_50		; [ 4] Right border
	fill_nop_13			; [13]
	stabilisator		; [ 5] Stabilisator
	fill_nop_7			; [12]
	move.l	(a6)+,a5		;     [3] Next line
	jmp	(a5)		;     [2]

full_set_pal:
	switch_res_hi_low		; [ 5] Left border
	movem.l	d2-d5,PALETTE.w	; [11] 12+8n
	movem.l	pal_logo(pc),d2-d5	; [12] 16+8n
	movem.l	d2-d5,PALETTE+16.w	; [11] 12+8n
	fill_nop_55			;     => [89]
	switch_freq_60_50		; [ 4] Right border
	fill_nop_13			; [13]
	stabilisator		; [ 5] Stabilisator
	fill_nop_7			; [12]
	move.l	(a6)+,a5		;     [3] Next line
	jmp	(a5)		;     [2]

full_copy:
OFFSET	set 8
	switch_res_hi_low		; [ 5] Left border
	fill_nop_2			; [89]
	move.w	(a3)+,(a4)		;     [3]
	REPT 21			;     [84] = 21*4
	move.w	(a3)+,OFFSET(a4)
OFFSET	SET OFFSET+8
	ENDR
	switch_freq_60_50		; [ 4] Right border
	fill_nop_1			; [13]
	REPT 3			;     [12] = 3*4
	move.w	(a3)+,OFFSET(a4)
OFFSET 	SET OFFSET+8
	ENDR
	stabilisator		; [ 5] Stabilisator
	fill_nop_1			; [12]
	move.w	(a3)+,OFFSET(a4)	;     [4]
	lea	230(a4),a4		;     [2]
	move.l	(a6)+,a5		;     [3] Next line
	jmp	(a5)		;     [2]

full_scroller_init:
	switch_res_hi_low		; [ 5] Left border
	fill_nop_48			; [89]

	lea	font_buf-30*2,a3	;     [3]
	add.w	posy_scroller,a3	;     [5]
	add.w	posx_scroller,a3	;     [5]

	move.l	sync_logical,a4	;     [5]
	add.l	#230*246+6,a4	;     [4]
	
	move.l	#$06660666,d4	;     [3]
	move.l	d4,PALETTE+16.w	;     [4]
	move.l	d4,PALETTE+20.w	;     [4]
	move.l	d4,PALETTE+24.w	;     [4]
	move.l	d4,PALETTE+28.w	;     [4]

	switch_freq_60_50		; [ 4] Right border
	fill_nop_13			; [13]
	stabilisator		; [ 5] Stabilisator
	fill_nop_7			; [12]
	move.l	(a6)+,a5		;     [ 3] Next line
	jmp	(a5)		;     [ 2]

full_scroller:
OFFSET	set 8
	switch_res_hi_low		; [ 5] Left border
	fill_nop_0			; [89]
	lea	30*2(a3),a3		;     [2]
	move.w	(a3)+,(a4)		;     [3]
	REPT 21			;     [84] = 21*4
	move.w	(a3)+,OFFSET(a4)
OFFSET	SET OFFSET+8
	ENDR
	switch_freq_60_50		; [ 4] Right border
	fill_nop_1			; [13]
	REPT 3			;     [12] = 3*4
	move.w	(a3)+,OFFSET(a4)
OFFSET 	SET OFFSET+8
	ENDR
	stabilisator		; [ 5] Stabilisator
	fill_nop_1			; [12]
	move.w	(a3)+,OFFSET(a4)	;     [4]
	lea	230(a4),a4		;     [2]
	move.l	(a6)+,a5		;     [3] Next line
	jmp	(a5)		;     [2]

full_end_vbl:
	bsr	clr_palette
	SET_SP_2300			; SR set
	rte

;#------------------------------------#
;# Music by Epic/The Misfits Software #
;#------------------------------------#

	INCLUDE	ZIK.S

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION DATA
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

full_map:	dcb.l 6,0
	dc.l full_set_pal
	REPT 221
	dc.l full_copy
	ENDR
	dc.l rout_bottom_1
	dc.l rout_bottom_2
	REPT 19
	dc.l full_copy
	ENDR
	dc.l full_line
	dc.l full_scroller_init
	REPT 16
	dc.l full_scroller
	ENDR
	REPT 7
	dc.l full_line
	ENDR
	dc.l full_end_vbl

bubbles:	incbin BUBBLES.RAW
	
logo:	incbin LOGO.RAW

font:	incbin FONT.RAW

text:	REPT SPEED
	dc.b '                        '
	dc.b '                        '
	ENDR
	dc.b 'HELLO ALL     '
	dc.b 'IN FEBRUARY 2019 ATARI LEGEND BRINGS YOU A VERY RARE GAME BY LANKHOR          '
	dc.b 'ESPRITS MATHEMATIQUES CE1-CE2 - VOLUME 1          '
	dc.b 'GAME SUPPLIED AND CRACKED BY BRUME OF ATARI LEGEND     '
	dc.b 'WONDERFUL INTRO CODED BY DYNO OF EFFECT     '
	dc.b 'BRILLIANT LOGO BY PANDAFOX OF EFFECT     '
	dc.b 'VERY COOL MUSIC BY EPIC OF THE MISFITS SOFTWARE     '
	dc.b 'AND GAME TESTED BY LULU               '
	dc.b 'BRUME ON THE KEYBOARD     '
	dc.b 'I CRACKED THIS STUFF IN 2004 BUT IT STAYED ON MY HARD DRIVE AND I ENDED UP FORGETTING IT          '
	dc.b 'THIS IS ONE THE EIGHT VOLUMES OF THE ESPRITS SERIE          '
	dc.b 'HAVE MANY REQUESTS OVER THE LAST YEARS TIME HAS COME TO RELEASE WITH A PROPER INTRO     '
	dc.b 'THANKS AGAIN DYNO AND PANDAFOX FOR YOUR PRECIOUS HELP               '
	dc.b 'BEST GREETINGS ARE SENT TO THE FOLLOWING CREWS          '
	dc.b 'ADRENALIN UK     CEREBRAL VORTEX     CREAM     DHS     EFFECT     ELITE     EQUINOX     '
	dc.b 'EUROSWAP     EVIL FORCE     FANATICS     HEMOROIDS     MJJ PROD     NOEXTRA     '
	dc.b 'OXYGENE     PARADIZE     POV     PULSION     REPLICANTS     RESERVOIR GODS     '
	dc.b 'RIPPED OFF     SPECIAL FX     ST KNIGHTS     SUPREMACY     THE CAREBEARS     '
	dc.b 'THE EXCEPTIONS     THE LEMMINGS     TOOL8     ZUUL               '
	dc.b 'AND OF COURSE EVERYONE IN THE ATARI LEGEND TEAM               '
	dc.b 'ENJOY AND BE SURE TO GRAB ALL OTHER VOLUMES OF THE SERIE ON THE SITE WWW.ATARILEGEND.COM     '
	dc.b 'SEE YOU SOON               '

end_text:

fade_bg:	dc.w $000,$000,$000,$000,$000,$000,$000,$000
	dc.w $000,$000,$000,$000,$000,$001,$000,$000
	dc.w $000,$000,$000,$000,$000,$112,$000,$000
	dc.w $000,$100,$000,$000,$010,$223,$000,$001
	dc.w $000,$210,$100,$010,$120,$334,$001,$012
	dc.w $000,$321,$210,$120,$231,$445,$012,$123
	dc.w $000,$432,$321,$231,$342,$556,$123,$234

fade_logo:	dc.w $111,$432,$321,$231,$342,$556,$123,$234
	dc.w $222,$543,$432,$342,$453,$666,$234,$345
	dc.w $333,$654,$543,$453,$564,$666,$345,$456
	dc.w $444,$765,$654,$564,$675,$777,$456,$567

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@¶@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

pal_bg:	ds.w 8
pal_logo:	ds.w 8

iteration:	ds.w 1
px:	ds.w 1
py:	ds.w 1
plogo:	ds.w 1

logo_adr:	ds.l 1
screen_adr:	ds.l 1

sinus_x:	ds.w 1024
sinus_y:	ds.w 1024
sinus_logo:	ds.w 1024

lut:	ds.l 512

font_wide:	ds.b 30720/SPEED			; 60 chars * 16 lines * 4 bytes * x shifts

font_buf:	ds.w (((416+16+16)*2)/16)*16*8/SPEED	; 56.w * 16 lines * x shifts

logo_buf:	ds.b 292*52

screen_buf:	ds.b 160+256+(230*48*16)+(230*48*9)

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 END
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
