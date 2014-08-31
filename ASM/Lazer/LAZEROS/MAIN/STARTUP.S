COLOR0	set $ffff9800


;-----------------------------------------------------------
phoenix_init
	move.w	#$2700,sr
	move.l	$70.w,ph_old_vbl+2
	move.l	#ph_vbl,$70.w
	move.w	#$2300,sr
	rts
;-----------------------------------------------------------
phoenix_exit
	move.w	#$2700,sr
	move.l	ph_old_vbl+2,$70.w
	move.w	#$2300,sr
	rts
;-----------------------------------------------------------
ph_vbl
	IFD FASTEXIT
	cmp.b	#1,key
	bne	.no_kill
	and.w	#$2300,sr
	jmp	main_exit
.no_kill
	ENDC

	cmp.b	#20,old_key
	bne.s	.no_timer
	cmp.b	#20+128,key
	bne.s	.no_timer
	not.w	timer_flag
	clr.b	old_key
.no_timer

	add.w	#1,vsync_count

ph_old_vbl
	jmp	$12345678
;-----------------------------------------------------------

;-----------------------------------------------------------
; -> A0: Pointer to string
;    A1: Pointer to screen
;    D0,D1: X,Y Position
; Der String muž mit $0 terminiert sein!

show_string
	rts
;-----------------------------------------------------------


;-----------------------------------------------------------
pusha MACRO
	movem.l	d0-a6,-(sp)
	ENDM
;-----------------------------------------------------------
popa MACRO
	movem.l	(sp)+,d0-a6
	ENDM
;-----------------------------------------------------------
save_stack MACRO
	move.l	sp,save_sp
	ENDM
;-----------------------------------------------------------
restore_stack MACRO
	move.l	save_sp,sp
	ENDM
;-----------------------------------------------------------
timer MACRO
	tst.w	timer_flag
	beq.s	.no\@
	move.l	#\1,COLOR0
.no\@
	ENDM
;-----------------------------------------------------------
vsync MACRO
	move.l	d0,-(sp)
	move.w	vsync_count,d0
.wait\@
	cmp.w	vsync_count,d0
	beq	.wait\@
	move.l	(sp)+,d0
	ENDM
;-----------------------------------------------------------
wait 	MACRO
	move.w	#\1,d0
.1\@	vsync
	dbf	d0,.1\@
	ENDM
;-----------------------------------------------------------
cache_on MACRO
	movec	CACR,d0
	or.l	#1+256,d0
	movec	d0,CACR
	ENDM
;-----------------------------------------------------------
terminate MACRO
	clr.w	-(sp)
	trap	#1
	ENDM
;-----------------------------------------------------------
; ->screen in d0
setscreen MACRO
	move.w	d0,d1
	lsr.w	#8,d1
	move.l	d0,d2
	swap	d2
	move.b	d2,$ffff8201.w
	move.b	d1,$ffff8203.w
	move.b	d0,$ffff820d.w
	ENDM
;-----------------------------------------------------------
swapscreens MACRO
	move.l	d0,-(sp)
	move.l	scr1,d0
	move.l	scr2,scr1
	move.l	d0,scr2
	move.l	(sp)+,d0
	ENDM
;-----------------------------------------------------------
save_resolution MACRO
	move.w	#-1,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq	#4,sp
	move.w	d0,old_resolution
	ENDM
;-----------------------------------------------------------
restore_resolution MACRO
	move.w	old_resolution,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq	#4,sp
	ENDM
;-----------------------------------------------------------
; gibt den vom Programm nicht ben”tigten Speicher wieder zurck
shrink_memory	MACRO
	move.l	a7,a5
	move.l	#mystack,a7
	move.l	4(a5),a5

	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	#0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
***	bne	.error
	ENDM
;-----------------------------------------------------------
save_interrupts MACRO
        move.b  $fffffa07.w,old7
        move.b  $fffffa09.w,old9
        move.b  $fffffa11.w,old11
        move.b  $fffffa13.w,old13
        move.b  $fffffa15.w,old15
        move.b  $fffffa19.w,old19
        move.b  $fffffa1b.w,old1b
        move.b  $fffffa1d.w,old1d
        move.b  $fffffa1f.w,old1f
        move.b  $fffffa23.w,old23

	move.l	$68.w,old68
        move.l  $110.w,old110
        move.l  $118.w,old118
        move.l  $120.w,old120
	move.l	$134.w,old134
        move.l  $70.w,old70
        move.l  $70.w,old_vbl+2
        ENDM
;-----------------------------------------------------------
set_interrupts MACRO
	move.w	#$2700,sr
	move.b	#1,$fffffa07.w
	clr.b	$fffffa09.w
	move.b	#1,$fffffa13.w
	clr.b	$fffffa15.w
	clr.b	$fffffa19.w
	move.w	#$2300,sr
	
	bset	#6,$fffffa09.w
	bset	#6,$fffffa15.w
        move.l  #vbl,$70.w
	ENDM
;-----------------------------------------------------------
restore_interrupts MACRO
	move.w	#$2700,sr
        move.l  old134,$134.w
        move.l  old120,$120.w
        move.l  old118,$118.w
        move.l  old110,$110.w
        move.l  old68,$68.w

        move.b  old7,$fffa07
        move.b  old9,$fffa09
        move.b  old11,$fffa11
        move.b  old13,$fffa13
        move.b  old15,$fffa15
        move.b  old19,$fffa19
        move.b  old1b,$fffa1b
*	clr.b	$fffffa1d.w
*	move.b  old1d,$fffa1d
        move.b  old1f,$fffa1f
*	move.b  old23,$fffa23
	move.w	#$2300,sr
        move.l  old70,$70.w
	ENDM
;-----------------------------------------------------------
super_on MACRO
        move.l  #0,-(sp)
        move.w  #32,-(sp)
        trap    #1
        addq.l  #6,sp
        move.l  d0,user_sp
	ENDM
;-----------------------------------------------------------
super_off MACRO
        move.l  user_sp,-(sp)
        move.w  #32,-(sp)
        trap    #1
        addq.l  #6,sp
	ENDM
;-----------------------------------------------------------
mouse_off MACRO
        dc.w    $a00a

        pea     moff
        move.w  #0,-(sp)
        move.w  #25,-(sp)
        trap    #14
        addq.l  #8,sp
	ENDM
;-----------------------------------------------------------
mouse_on MACRO
        pea     mon
        move.w  #0,-(sp)
        move.w  #25,-(sp)
        trap    #14
        addq.l  #8,sp
        
        dc.w    $a009
	ENDM
;-----------------------------------------------------------
clr_bss MACRO
	moveq	#0,d0
	lea	start_bss,a0
	lea	end_bss,a1
.loop\@
	move.l	d0,(a0)+
	cmp.l	a1,a0
	blt	.loop\@
	ENDM
;-----------------------------------------------------------
; -> Checkt monitor: monitor_flag..1 ->VGA
;		     monitor_flag..0 ->RGB
check_vga
	clr.w	monitor_flag
	move.w	#89,-(sp)
	trap	#14
	addq	#2,sp
	cmp.w	#2,d0
	beq	is_vga
	rts
is_vga	move.w	#1,monitor_flag
	rts
;-----------------------------------------------------------
; -> A0: Pointer auf die Hardware-Daten
set_resolution MACRO
        move.l	(a0)+,$ffff8282.w
        move.l	(a0)+,$ffff8286.w
        move.l	(a0)+,$ffff828A.w
        move.l	(a0)+,$ffff82A2.w
        move.l	(a0)+,$ffff82A6.w
        move.l	(a0)+,$ffff82AA.w
        move.w	(a0)+,$ffff820A.w
        move.w	(a0)+,$ffff82C0.w
        clr.w	$ffff8266.w
        move.w	(a0)+,$ffff8266.w
        move.w	(a0)+,$ffff82C2.w
        move.w	(a0)+,$ffff8210.w
	ENDM
;-----------------------------------------------------------
; RGB 384*240, True Color, 50.0 Hz, 15625 Hz
rgb_384x240xtrue
	dc.l	$FE00CC,$280019,$BA00D9,$2710265,$2F0059,$239026B
        dc.w	$200,$181,$100,$0,$180

; RGB 320*200, 16 Farben, 50.0 Hz, 15625 Hz
rgb_320x200x16
	dc.l	$FE00CC,$280017,$7800D9,$2710265,$2F0081,$211026B
	dc.w	$200,$181,$0,$0,$50

; RGB 640*200, 16 Farben, 50.0 Hz, 15625 Hz
rgb_640x200x16
	dc.l	$1FE0199,$500061,$11201B3,$2710265,$2F0081,$211026B
	dc.w	$200,$181,$0,$4,$A0

; RGB 640*200, 4 Farben, 50.0 Hz, 15625 Hz
rgb_640x200x4
        dc.l    $3E0033,$3E0033,$A0005,$1E0036,$2710265,$2F0081,$211026B
	dc.w	$200,$181,$1,$4,$50

; RGB 320*100, 256 Farben, 50.0 Hz, 15625 Hz
rgb_320x100x256
	dc.l	$FE00CC,$28001E,$7F00D9,$2710265,$2F007D,$20D026B
	dc.w	$200,$181,$10,$1,$A0

; RGB 320*200, 256 Farben, 50.0 Hz, 15625 Hz
rgb_320x200x256
	dc.l	$FE00CC,$28001E,$7F00D9,$2710265,$2F007F,$20F026B
	dc.w	$200,$181,$10,$0,$A0

; RGB 384*120, 256 Farben, 50.0 Hz, 15625 Hz
rgb_384x120x256
	dc.l	$FE00CC,$280007,$A800D9,$2710265,$2F0059,$239026B
	dc.w	$200,$181,$10,$1,$C0

; RGB 384*240, 256 Farben, 50.0 Hz, 15625 Hz
rgb_384x240x256
	dc.l	$FE00CC,$280007,$A800D9,$2710265,$2F0059,$239026B
	dc.w	$200,$181,$10,$0,$C0



; VGA 384*240, 256 Farben, 60.0 Hz, 31470 Hz
vga_384x240x256_60
        dc.l    $FC00B4,$1A02E0,$9500C0,$41903AF,$8F003D,$3FD0415
        dc.w    $200,$182,$10,$5,$C0

; VGA 384*240, 256 Farben, 50.0 Hz, 31470 Hz
vga_384x240x256
        dc.l    $FC00B4,$1A02E0,$9500C0,$4EB0481,$8F00A5,$46504E7
        dc.w    $200,$182,$10,$5,$C0

; VGA 384*240, True Color, 60.0 Hz, 31470 Hz
vga_384x240xtrue_60
        dc.l    $FC00B4,$1A02F2,$A700C0,$41903AF,$8F003D,$3FD0415
        dc.w    $200,$182,$100,$5,$180

; VGA 384*240, True Color, 50.0 Hz, 31470 Hz
vga_384x240xtrue
        dc.l    $FC00B4,$1A02F2,$A700C0,$4EB0481,$8F00A5,$46504E7
        dc.w    $200,$182,$100,$5,$180

; VGA 640*200, 16 Farben, 50.0 Hz, 31470 Hz
vga_640x200x16
	dc.l	$C6008D,$1502A3,$7C0097,$4EB0481,$8F010D,$42D04E7
	dc.w	$200,$186,$0,$9,$A0

; VGA 640*200, 4 Farben, 50.0 Hz, 31470 Hz
vga_640x200x4
        dc.l    $170011,$2020E,$D0012,$4EB0481,$8F00ED,$40D04E7
	dc.w	$200,$186,$1,$9,$50

rgb_320x200xtrue
	dc.l	$FE00C3,$200030,$9100D7,$2710265,$2F0081,$211026B
	dc.w	$200,$181,$100,$0,$140


; RGB 320*240, True Color, 50.0 Hz, 15625 Hz
rgb_320x240xtrue_cin
	dc.l	$C70099,$1902C5,$9400A9,$2710265,$2F0059,$239026B
	dc.w	$200,$185,$100,$0,$140

rgb_320x120xtrue_cin
	dc.l	$C70099,$1902C5,$9400A9,$2710265,$2F0059,$239026B
	dc.w	$200,$187,$100,$1,$140

rgb_640x400xtrue
	dc.l	$1FE0187,$400072,$12301AF,$2700265,$2F0080,$210026B
	dc.w	$200,$181,$100,$6,$280

; RGB 320*240, 16 Farben, 50.0 Hz, 15625 Hz
rgb_320x240x16_cin
	dc.l	$C70099,$1902A3,$7200A6,$2710265,$2F0059,$239026B
	dc.w	$200,$186,$0,$0,$50

; RGB 320*240, 256 Farben, 50.0 Hz, 15625 Hz
rgb_320x240x256_cin
	dc.l	$C70099,$1902B3,$8200A6,$2710265,$2F0059,$239026B
	dc.w	$200,$186,$10,$0,$A0

;RGB 384*240, True Color, 60.0 Hz, 15625 Hz
rgb_384x240xtrue_60
	dc.l	$FE00C3,$200010,$B100D3,$20901FD,$2F0027,$2070203
	dc.w	$200,$182,$100,$0,$180


;-----------------------------------------------------------

moff		dc.b    $12
mon		dc.b    $8

user_sp		dc.l    0

old7		dc.b    0
old9		dc.b    0
old11		dc.b    0
old13		dc.b    0
old15		dc.b    0
old19		dc.b    0
old1b		dc.b    0
old1d		dc.b    0
old1f		dc.b    0
old23		dc.b    0
        even
old68		dc.l    0
old70		dc.l    0
old120		dc.l    0
old110		dc.l    0
old118		dc.l    0
old134		dc.l    0

old_screen	dc.l    0
old_resolution	dc.w	0
old_vid_buffer:	ds.w 23+16+32		*video + ST-Farben + Falcon-Farben
	ds.l	400
save_sp		dc.l	0

vsync_count	dc.w	0

	IFD TIMER
timer_flag	dc.w	TIMER
	ELSE
timer_flag	dc.w	0
	ENDC

old_key		dc.b	0
key		dc.b	0
monitor_flag	dc.w	0	;0=RGB , 1=VGA

**font_sys_8x8	incbin	f:\lanix\sys_8x8.fnt

	even