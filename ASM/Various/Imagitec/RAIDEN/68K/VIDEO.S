; Note that the horizontal timing numbers are for NTSC

;vclk		equ	400	; this for 25 MHz
;vclk		equ	399	; this for 25.05 MHz
vclk		equ	376	; this for 26.6 MHz

; The following are time in units of 100 ps

horiz_per	equ	317778 	; 63.5555us/2 Horizontal period
sync_per	equ	46050	; 4.605us synch width
eq_per		equ	23500	; 2.35us equalization
front_porch	equ	17450	; 1.745us 
line_blank	equ	109500	; 10.95us Total blanking

; The is the display width in video clocks

disp_width	equ	Screen_Width*4 	; Screen_Width*3				(320-32)*3	960	;this is in pixels/divider
;disp_height	equ	Screen_Height	;this is in lines

; Horizontal computations

n_hp		equ	horiz_per/vclk
n_hbb		equ	((horiz_per-sync_per-front_porch)/vclk)|$400
n_hbe		equ	(line_blank-sync_per-front_porch)/vclk
n_hs		equ	((horiz_per-sync_per)/vclk)|$400
n_hvs		equ	(horiz_per-(2*sync_per))/vclk
n_heq		equ	(horiz_per-eq_per)/vclk
n_hde		equ	((disp_width/2)-1)|$400
n_hdb1		equ	((n_hp)-(disp_width/2))
n_hdb2		equ	n_hdb1

; Vertical

n_vp		equ	523
n_vee		equ	6
n_vbe		equ	40
n_vdb		equ	n_vbe+26-12-6
;n_vde		equ	n_vdb+(disp_height*2)
;n_vbb		equ	n_vde+40
n_vs		equ	n_vp-10
n_veb		equ	n_vs-n_vee

VideoInit
	Bsr	Screen_Black
	Lea	Hardware,a5
	move.l	#$00070007,G_END(a5)
	move.w	#n_hde,HDE(a5)
	move.w	#n_hdb1,HDB1(a5)
	move.w	#n_hdb2,HDB2(a5)
	move.w	#n_vdb,VDB(a5)
	move.w	#$ffff,VDE(a5)
	Move.l	#$00070007,D_END+Hardware
	Ifnd	Booter
	St	Video_Flag
	Endc
	move.w	#$6C1,VMODE(a5)
	rts

Screen_Black
	move.l	#$0,BG+Hardware
	move.l	#$0,BORD1+Hardware
	Rts
