;Werte zur Programmierung der Videohardwareregister:
vertflag        EQU $0100
stmodes         EQU $800
overscan        EQU $40
pal             EQU $20
ntsc            EQU $00
vga             EQU $10
tv              EQU $00
col80           EQU $08
col40           EQU $00
bps16           EQU 4
bps8            EQU 3
bps4            EQU 2
bps2            EQU 1
bps1            EQU 0
getmode         EQU -1

;verschiedene "Modecodes":
my_mode          EQU vertflag|pal|vga|col40|bps16 ;VGA-Monitor

                clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP
                DC.W $A00A

		clr.w  $ffff8240.w
		clr.l  $ffff9800.w
kw		cmp.b  #$1,$fffffc02.w
		bne.s kw

                move.w  #3,-(SP)
                trap    #14
                addq.l  #2,SP
                move.l  D0,old_scr_adr

                move.w  #getmode,-(SP)
                move.w  #88,-(SP)
                trap    #14
                addq.l  #4,SP
                move.w  D0,old_modecode

                move.l  scr_adr(PC),D0
                move.w  #my_mode,D1     ;"True Color"
                bsr   set_scr_adr

		clr.l $ffff9800.w	

                move.l  #320*240/2-1,D0
                movea.l scr_adr(PC),A0
fill_lp         clr.l   (A0)+
                subq.l  #1,D0
                bpl.s   fill_lp

                move.l  $0118.w,old_mkb+2
                move.l  $70.w,old_vbl
                move.l  #vbl,$70.w



wait 
	move.w	#-1,vsync
.vsync	tst.w	vsync
	bne	.vsync

	bsr	show_raster
	bsr	show_raster_time

        cmpi.b  #$39,$FFFFFC02.w ;Auf Space warten
        bne.s   wait

        move    SR,-(SP)
        move    #$2700,SR
        move.l  old_vbl(PC),$70
        move.l  old_mkb+2(PC),$0118.w
        move    (SP)+,SR

        move.l  old_scr_adr(PC),D0
        move.w  old_modecode(PC),D1
        bsr.s   set_scr_adr

        DC.W $A009
        clr.w   -(SP)
        trap    #1


set_scr_adr
	move.w  D1,-(SP)
	move.w  #3,-(SP)
	move.l  D0,-(SP)
	move.l  D0,-(SP)
	move.w  #5,-(SP)
	trap    #14

        move.w  #$25,-(SP)      ;VSYNC
        trap    #14
        lea     16(SP),SP
        rts

mkb    
	move    #$2500,SR
old_mkb
        jmp     $0

vbl    
*	add.w	#1,screen_flip
	and.w	#3,screen_flip
	bne	.0

	clr.l   $ffff9800.w

	sub.w	#3*2,waveptr1
	tst.w	waveptr1
	bpl	.w1
	add.w	#3600*2,waveptr1
.w1
	sub.w	#3*2,waveptr2
	tst.w	waveptr2
	bpl	.w2
	add.w	#3600*2,waveptr2
.w2
	sub.w	#3*2,waveptr3
	tst.w	waveptr3
	bpl	.w3
	add.w	#3600*2,waveptr3
.w3
*	add.l	#2*640,y_pos
	cmp.l	#640*240,y_pos
	blt	.0
	sub.l	#640*240,y_pos
.0

	add.l	#8*640,y_pos
	cmp.l	#640*240,y_pos
	blt	.00
	sub.l	#640*240,y_pos
.00

	move.l	#scr_base,a0
	move.w	screen_flip,d0
	subq	#1,d0
	bmi	.2
.1	add.l	#640*240,a0
	dbf	d0,.1
.2
	move.l	a0,screen_base

	move.l	scr_adr,log_scr_adr
        move.l  screen_base,scr_adr
	move.l	y_pos,d0
	add.l	d0,scr_adr


        tst.w	flip
	bne	.sub
*	addi.l  #320*240*2,scr_adr
	bra	.ok
.sub
*	subi.l  #320*240*2,scr_adr
.ok
        not    flip
        move.b  scr_adr+1(PC),$FFFF8201.w ;HIGH
        move.b  scr_adr+2(PC),$FFFF8203.w ;MID
        move.b  scr_adr+3(PC),$FFFF820d.w ;LOW
	clr.w	vsync
	rte

vsync		dc.w	0
flip		dc.w	0

;-------------------------------------------------
show_raster
	add.w	#8*2*2,waveptr1
	cmp.w	#3600*2,waveptr1
	blt	.w1
	sub.w	#3600*2,waveptr1
.w1
	add.w	#8*2*2,waveptr2
	cmp.w	#3600*2,waveptr2
	blt	.w2
	sub.w	#3600*2,waveptr2
.w2
	add.w	#8*2*2,waveptr3
	cmp.w	#3600*2,waveptr3
	blt	.w3
	sub.w	#3600*2,waveptr3
.w3

	lea	wave1,a2
	add.w	waveptr1,a2
	lea	wave2,a3
	add.w	waveptr2,a3
	lea	wave3,a4
	add.w	waveptr3,a4

y_cnt = 8

	move.l	scr_adr,d0
	move.l	d0,d1
	add.l	#640*240,d1

; Zeile l”schen
	move.l  d0,$FFFF8A32.w 		; Destination
	move.b  #$00,$FFFF8A3B.w	; Operation-Register
	clr.b   $FFFF8A3D.w		; skew
	move.l  #-1,$FFFF8A28.w		; Endmask
	move.w  #-1,$FFFF8A2C.w		; endmask
	move.w  #2,$FFFF8A2E.w  	; D-Xinc
	move.w  #0,$FFFF8A30.w  	; D-Yinc
	move.w  #y_cnt*320,$FFFF8A36.w ; Xcnt
	move.w  #1,$FFFF8A38.w ; Ycnt
	move.b  #%11000000,$FFFF8A3C.w

	move.l  d1,$FFFF8A32.w 		; Destination
	move.b  #$00,$FFFF8A3B.w	; Operation-Register
	clr.b   $FFFF8A3D.w		; skew
	move.l  #-1,$FFFF8A28.w		; Endmask
	move.w  #-1,$FFFF8A2C.w		; endmask
	move.w  #2,$FFFF8A2E.w  	; D-Xinc
	move.w  #0,$FFFF8A30.w  	; D-Yinc
	move.w  #y_cnt*320,$FFFF8A36.w ; Xcnt
	move.w  #1,$FFFF8A38.w ; Ycnt
	move.b  #%11000000,$FFFF8A3C.w



	move.l	d0,d2
	move.l	d1,d3
; rot kopieren
	move.b  #$02,$FFFF8A3A.w 	; nur Null Bytes
	move.b  #$03,$FFFF8A3B.w	; Operation-Register
	clr.b   $FFFF8A3D.w		; skew
	move.l  #-1,$FFFF8A28.w		; Endmask
	move.w  #-1,$FFFF8A2C.w		; endmask
	move.w  #2,$FFFF8A2E.w  	; D-Xinc
	move.w  #0,$FFFF8A30.w  	; D-Yinc
	move.w  #2,$FFFF8A20.w 		; S-Xinc
	move.w  #0,$FFFF8A22.w 		; S-Yinc

	move.w	#7,d7
.lr
	move.l	#raster_red,d4

	move.l	d2,a0
	add.w	(a2),a0
	move.l  d4,$FFFF8A24.w  	; Source Start
	move.l  a0,$FFFF8A32.w 		; Destination
	move.w  #124,$FFFF8A36.w 	; Xcnt
	move.w  #1,$FFFF8A38.w 		; Ycnt
	move.b  #%11000000,$FFFF8A3C.w

	move.l	d3,a0
	add.w	(a2),a0
	move.l  d4,$FFFF8A24.w  	; Source Start
	move.l  a0,$FFFF8A32.w 		; Destination
	move.w  #124,$FFFF8A36.w 	; Xcnt
	move.w  #1,$FFFF8A38.w 		; Ycnt
	move.b  #%11000000,$FFFF8A3C.w
	lea	4(a2),a2

	add.l	#640,d2
	add.l	#640,d3
	dbf	d7,.lr


	move.l	d0,d2
	move.l	d1,d3
	move.b  #$07,$FFFF8A3B.w	; Operation-Register

	move.w	#7,d7
.lg
	move.l	#raster_red,d4

	move.l	d2,a0
	add.w	(a3),a0
	move.l  d4,$FFFF8A24.w  	; Source Start
	move.l  a0,$FFFF8A32.w 		; Destination
	move.w  #124,$FFFF8A36.w 	; Xcnt
	move.w  #1,$FFFF8A38.w 		; Ycnt
	move.b  #%11000000,$FFFF8A3C.w

	move.l	d3,a0
	add.w	(a3),a0
	move.l  d4,$FFFF8A24.w  	; Source Start
	move.l  a0,$FFFF8A32.w 		; Destination
	move.w  #124,$FFFF8A36.w 	; Xcnt
	move.w  #1,$FFFF8A38.w 		; Ycnt
	move.b  #%11000000,$FFFF8A3C.w
	lea	4(a3),a3

	add.l	#640,d2
	add.l	#640,d3
	dbf	d7,.lg


	move.l	d0,d2
	move.l	d1,d3
	move.b  #$07,$FFFF8A3B.w	; Operation-Register

	move.w	#7,d7
.lb
	move.l	#raster_green,d4

	move.l	d2,a0
	add.w	(a4),a0
	move.l  d4,$FFFF8A24.w  	; Source Start
	move.l  a0,$FFFF8A32.w 		; Destination
	move.w  #124,$FFFF8A36.w 	; Xcnt
	move.w  #1,$FFFF8A38.w 		; Ycnt
	move.b  #%11000000,$FFFF8A3C.w

	move.l	d3,a0
	add.w	(a4),a0
	move.l  d4,$FFFF8A24.w  	; Source Start
	move.l  a0,$FFFF8A32.w 		; Destination
	move.w  #124,$FFFF8A36.w 	; Xcnt
	move.w  #1,$FFFF8A38.w 		; Ycnt
	move.b  #%11000000,$FFFF8A3C.w
	lea	4(a4),a4

	add.l	#640,d2
	add.l	#640,d3
	dbf	d7,.lb
	rts
;-------------------------------------------------
show_raster_time
	move.l #-1,$ffff9800.w	
	moveq	#0,d0
	move.b	$ffff8205.w,d0
	lsl.w	#8,d0
	move.b	$ffff8207.w,d0
	lsl.l	#8,d0
	move.b	$ffff8209.w,d0

	move.l	d0,a0
	moveq	#-1,d1
	REPT 20
	move.w	d1,(a0)+
	ENDR
	move.w	#30,d1
.1	dbf	d1,.1
	move.l	d0,a0
	moveq	#0,d1
	REPT 20
	move.w	d1,(a0)+
	ENDR
	rts
;-------------------------------------------------
old_modecode    ds.w	1
old_vbl         ds.l	1
old_scr_adr     dc.l	scr_base
log_scr_adr     dc.l	scr_base
scr_adr         dc.l	scr_base

y_pos		dc.l	0
hy_pos		dc.l	0

raster_red
i set 0
	rept 31
	dc.w	i*64*32
	dc.w	i*64*32
i set i+1
	endr
	rept 31
	dc.w	i*64*32
	dc.w	i*64*32
i set i-1
	endr

raster_green
i set 0
	rept 31
	dc.w	i*64
	dc.w	i*64
i set i+1
	endr
	rept 31
	dc.w	i*64
	dc.w	i*64
i set i-1
	endr

raster_blue
i set 0
	rept 31
	dc.w	i
	dc.w	i
i set i+1
	endr
	rept 31
	dc.w	i
	dc.w	i
i set i-1
	endr

screen_flip	dc.w	0
screen_base	dc.l	scr_base

waveptr1	dc.w	0
waveptr2	dc.w	0
waveptr3	dc.w	0

wave1		incbin	wave1.dat
wave2		incbin	wave2.dat
wave3		incbin	wave3.dat

        section bss
dummy		ds.l	200000

scr_base	ds.w	320*240*8




	IFNE 0
*	move.l  D0,$FFFF8A24.w  	; Source Start
	move.l  d0,$FFFF8A32.w 		; Destination
*	move.l  #screen,$FFFF8A32.w 	; Destination
*	move.b  #$00,$FFFF8A3A.w 	; nur Null Bytes
	move.b  #$00,$FFFF8A3B.w	; Operation-Register
	clr.b   $FFFF8A3D.w		; skew
	move.l  #-1,$FFFF8A28.w		; Endmask
	move.w  #-1,$FFFF8A2C.w		; endmask
	move.w  #2,$FFFF8A2E.w  	; D-Xinc
	move.w  #0,$FFFF8A30.w  	; D-Yinc
*	move.w  #lines*2,$FFFF8A20.w 	; S-Xinc
*	move.w  #-lines*2*63-2,$FFFF8A22.w ; S-Yinc
	move.w  #y_cnt*320,$FFFF8A36.w ; Xcnt
	move.w  #1,$FFFF8A38.w ; Ycnt
	move.b  #%11000000,$FFFF8A3C.w
	ENDC