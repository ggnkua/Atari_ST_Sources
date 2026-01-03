* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Spriteroutine fÅr die "True Color" (besser High Color) Modi des Falcon 030  *
* coded 93 by Photon of Lazer                                                 *
* member of THE INDEPENDENT                                                   *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;Wert der Hintergrundfarbe (Bits: RRRRR GGGGGX BBBBB):
back_color      EQU 0           ;Schwarz
spr_anz         EQU 11          ;Anzahl der Sprites
offset          EQU 4           ;Abstand zwischen den Sprites

;Werte fÅr die verschiedenen Auflîsungen:
x_max           EQU 319         ;VGA
y_max           EQU 239         ;VGA
;x_max           EQU 319         ;VGA (max. resolution)
;y_max           EQU 479         ;VGA (max. resolution)
;x_max           EQU 383         ;TV
;y_max           EQU 239         ;TV
;x_max           EQU 767         ;TV (max. resolution)
;y_max           EQU 479         ;TV (max. resolution)

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
;my_mode         EQU pal|vga|col40|bps16 ;VGA (max. resolution)
;my_mode         EQU overscan|pal|tv|col40|bps16 ;TV
;my_mode         EQU vertflag|overscan|pal|tv|col80|bps16 ;TV (max. resolution)

                TEXT
                clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP
                DC.W $A00A

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

                move.l  #(x_max+1)*(y_max+1)/2-1,D0
                movea.l scr_adr(PC),A0
fill_lp:        clr.l   (A0)+
                subq.l  #1,D0
                bpl.s   fill_lp

                move.l  $0118.w,old_mkb+2
                move.l  $70.w,old_vbl
                move.l  #vbl,$70.w


wait:
	move.w	#-1,vsync
.vsync	tst.w	vsync
	bne	.vsync

                move.l  old_adr_point0(PC),D0
                move.l  old_adr_point1(PC),old_adr_point0
                move.l  D0,old_adr_point1

	bsr	clear_all_sprites
	bsr	show_all_sprites

*	bsr	show_raster_time

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


set_scr_adr:    move.w  D1,-(SP)
                move.w  #3,-(SP)
                move.l  D0,-(SP)
                move.l  D0,-(SP)
                move.w  #5,-(SP)
                trap    #14

                move.w  #$25,-(SP)      ;VSYNC
                trap    #14
                lea     16(SP),SP
                rts

mkb:            move    #$2500,SR
old_mkb:        jmp     $0

vbl:            move.l  scr_adr(PC),log_scr_adr
scr_change:     tst.w	flip
		bne	.sub
		addi.l  #(x_max+1)*(y_max+1)*2,scr_adr
		bra	.ok
.sub
		subi.l  #(x_max+1)*(y_max+1)*2,scr_adr
.ok
                not    flip
                move.b  scr_adr+1(PC),$FFFF8201.w ;HIGH
                move.b  scr_adr+2(PC),$FFFF8203.w ;MID
                move.b  scr_adr+3(PC),$FFFF820d.w ;LOW
;                move.b  scr_adr+1(PC),$FFFF8205.w ;HIGH
;                move.b  scr_adr+2(PC),$FFFF8207.w ;MID
;                move.b  scr_adr+3(PC),$FFFF8209.w ;LOW
		clr.w	vsync
		rte

vsync		dc.w	0
flip		dc.w	0

;-------------------------------------------------
show_raster_time
	moveq	#0,d0
	move.b	$ffff8205.w,d0
	lsl.w	#8,d0
	move.b	$ffff8207.w,d0
	lsl.l	#8,d0
	move.b	$ffff8209.w,d0

	move.l	d0,a0
	moveq	#-1,d0
	REPT 20
	move.w	d0,(a0)+
	ENDR
	rts
;-------------------------------------------------
show_all_sprites
	lea	xy_pointer,a2
	move.l	old_adr_point0,a4

	move.w	#spr_anz-1,d3
.1
	move.l	log_scr_adr,a0
	lea	ball+4,a1

	move.l	(a2),a3
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	tst.w	(a3)
	bpl	.2
	lea	xy,a3
.2	move.l	a3,(a2)+

	muls.w	#640,d1
	add.l	d1,a0
	add.w	d0,d0
	add.w	d0,a0
	move.l	a0,(a4)+

	bsr	set_sprite
	dbf	d3,.1
	rts
;-------------------------------------------------
clear_all_sprites
	move.l	old_adr_point0,a2

	move.w	#spr_anz-1,d7
.1
	move.l	log_scr_adr,a0
	lea	ball+4,a1

	move.l	(a2)+,a0
	cmp.l	#-1,a0
	beq	.go_on
	bsr	clear_sprite_fast
.go_on
	dbf	d7,.1
	rts
;-------------------------------------------------
set_sprite
	move.w	-2(a1),d7
.y	
	move.l	a0,a6	***

.next
	move.w	(a1)+,d0
	beq	.end
	bmi.s	.set
	add.w	d0,a6
	bra.s	.next

.set
	neg.w	d0
	subq	#1,d0
.1	move.w	(a1)+,(a6)+
	dbf	d0,.1
	bra.s	.next
.end

	lea	320*2(a0),a0
	dbf	d7,.y
	rts
;-------------------------------------------------
clear_sprite
	move.w	-2(a1),d7
.y	
	move.l	a0,a6	***

.next
	move.w	(a1)+,d0
	beq	.end
	bmi.s	.set
	add.w	d0,a6
	bra.s	.next

.set
	neg.w	d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,a1

	moveq	#0,d1
	subq	#1,d0
.1	move.w	d1,(a6)+
	dbf	d0,.1
	bra.s	.next
.end

	lea	320*2(a0),a0
	dbf	d7,.y
	rts
;-------------------------------------------------
clear_sprite_fast
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	move.l	d0,a4
	move.l	d0,a5

	move.w	-2(a1),d6
.y	
	movem.l	d0-d5/a4-a5,(a0)
	movem.l	d0-d5/a4-a5,32(a0)
	lea	320*2(a0),a0
	dbf	d6,.y
	rts
;-------------------------------------------------


old_modecode:   DS.W 1
old_vbl:        DS.L 1
old_scr_adr:    DS.L 1
log_scr_adr:    DS.L 1
scr_adr:        DC.L scr_base
old_adr_point0: DC.L old_adr0
old_adr_point1: DC.L old_adr1
old_adr0:       Dcb.L spr_anz+1,-1
old_adr1:       Dcb.L spr_anz+1,-1
xy_pointer:
cn              SET 0
                REPT spr_anz
                DC.L xy+cn*4
cn              SET cn+offset
                ENDR
                DC.L -1
offset_tab:
count           SET 0
                REPT y_max
                DC.L count
count           SET count+(x_max+1)*2
                ENDR

xy:             incbin XY2.BIN
                DC.W -1

ball:           incbin KUGEL8.TCS

                BSS
scr_base:       DS.W (x_max+1)*(y_max+1)*2
                END
