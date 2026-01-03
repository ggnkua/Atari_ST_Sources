
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Spriteroutine fÅr die "True Color" (besser High Color) Modi des Falcon 030  *
* coded 1992/93 by Scandion of THE MUGWUMPS                                   *
* member of THE INDEPENDENT                                                   *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;Wert der Hintergrundfarbe (Bits: RRRRR GGGGGX BBBBB):
back_color      EQU 0           ;Schwarz
spr_anz         EQU 11	        ;Anzahl der Sprites
offset	        EQU 5           ;Abstand zwischen den Sprites

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
stmodes         EQU $80
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
my_mode         EQU vertflag|pal|vga|col40|bps16 ;VGA-Monitor
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
                bsr.s   set_scr_adr

                move.l  #(x_max+1)*(y_max+1)/2-1,D0
                movea.l scr_adr(PC),A0
fill_lp:        clr.l   (A0)+
                subq.l  #1,D0
                bpl.s   fill_lp

                bsr     generate_code
                move.l  $0118.w,old_mkb+2
                move.l  $70.w,old_vbl
                move.l  #vbl,$70.w

wait:           cmpi.b  #$39,$FFFFFC02.w ;Auf Space warten
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
scr_change:     addi.l  #(x_max+1)*(y_max+1)*2,scr_adr
                bchg    #1,scr_change
                move.b  scr_adr+1(PC),$FFFF8201.w ;HIGH
                move.b  scr_adr+2(PC),$FFFF8203.w ;MID
                move.b  scr_adr+3(PC),$FFFF820D.w ;LOW
                move.l  old_adr_point0(PC),D0
                move.l  old_adr_point1(PC),old_adr_point0
                move.l  D0,old_adr_point1

                movea.l old_adr_point0(PC),A2
                lea     (A2),A2
black_lp:       tst.l   (A2)
                bmi.s   go_on1
                lea     black(PC),A0
                movea.l (A2)+,A1        ;old_scr_adr
                bsr     set_sprite
                bra.s   black_lp


go_on1:         move.l	xy_pointer0(PC),a2
		move.l	xy_pointer1(pc),a3
                movea.l old_adr_point0(PC),A6
                lea     (A6),A6
                lea     offset_tab(PC),A5

                tst.w   1008(A2)            ;Ende der XY-Tabelle?
                bpl.s   go_on0
                move.l  #xy0,xy_pointer0
		lea 	xy0,a2
go_on0:         addq.l  #4,xy_pointer0

   		tst.w   1008(A3)          ;Ende der XY-Tabelle?
                bpl.s   go_on2
                move.l  #xy1,xy_pointer1
		lea 	xy1,a3
go_on2:         addq.l  #4,xy_pointer1


		move.w #spr_anz-1,d7
spr_lp:
                move.w  (A2),D0
                move.w  2(A2),D1
		add.w 	(a3),d0                
		add.w	2(a3),d1
		lea	offset*4(a2),a2
		addq.l 	#4,a3
		
		lea     gen_gfx(PC),A0  ;Grafik
                movea.l log_scr_adr(PC),A1
		
		add.w   D0,D0           ;*2
                lea     0(A1,D0.w),A1
                asl.w   #2,D1           ;*4
                move.l  0(A5,D1.w),D1   ;Offset berechnen
                lea     0(A1,D1.l),A1
                move.l  A1,(A6)+        ;old_scr_adr
                bsr     set_sprite
                dbra 	d7,spr_lp
	        rte


generate_code:  lea     ball(PC),A0     ;normale Grafik
                lea     gen_gfx(PC),A1  ;geÑnderte Grafik
                lea     set_sprite(PC),A2 ;generierter Code

                move.w  (A0),D0         ;Breite
                ext.l   D0
                move.l  #(x_max+1)*2,D7
                add.l   D0,D0           ;*2
                sub.l   D0,D7           ;### d7 = Adressoffset ###

                move.w  (A0)+,D2        ;### d0/d2 = Breite ###
                move.w  (A0)+,D1        ;### d1 = Hîhe ###

                move.l  D7,D6           ;### d6 = Zieloffset ###
                neg.l   D6              ;fÅr's erste mal negativ

;Code-Generierung:

y_loop:         move.w  D2,D0           ;X-ZÑhler erneut setzen
                add.l   D7,D6           ;Zeilenoffset addieren
                subq.w  #1,D1           ;letzte Zeile
                bmi     end_loop        ;dann TschÅû

x_loop:         subq.w  #1,D0           ;Letzter Pixel der Zeile?
                bmi.s   y_loop          ;dann Y-Schleife loopen

                cmpi.w  #back_color,(A0)+ ;Pixel vergleichen
                beq.s   its_back        ;Hintergrund gefunden

;Grafik gefunden

                tst.l   D6              ;Zieloffset noch eintragen?
                beq.s   set_pixel       ;Nein...

                cmp.l   #2,D6
                bne.s   no2
                move.w  addquick2(PC),(A2)+ ;2 Bytes Offset
                bra.s   set_pixel
no2:            cmp.l   #4,D6
                bne.s   no4
                move.w  addquick4(PC),(A2)+ ;4 Bytes Offset
                bra.s   set_pixel
no4:            cmp.l   #6,D6
                bne.s   no6
                move.w  addquick6(PC),(A2)+ ;6 Bytes Offset
                bra.s   set_pixel
no6:            cmp.l   #8,D6
                bne.s   no8
                move.w  addquick8(PC),(A2)+ ;8 Bytes Offset
                bra.s   set_pixel
no8:            move.l  D6,D5
                and.l   #$FFFF0000,D5   ;WORD ausmaskieren
                tst.w   D5              ;LONG?
                bne.s   its_long
                move.w  lea_adr(PC),(A2)+ ;lea...
                move.w  D6,(A2)+        ;n Bytes Zieloffset eintragen
                bra.s   set_pixel
its_long:       move.w  add_adr(PC),(A2)+ ;add...
                move.l  D6,(A2)+        ;n Bytes Zieloffset eintragen

;Pixel setzen

set_pixel:      moveq   #0,D6           ;Zieloffset lîschen
                move.w  word_move(PC),(A2)+ ;ein Pixel setzen
                move.w  -2(A0),(A1)+    ;Pixel Åbernehmen
                tst.w   D0
                beq.s   x_loop          ;Ende der Zeile erreicht?

not_line_end:   cmpi.w  #back_color,(A0) ;nÑchsten Pixel vergleichen
                beq.s   x_loop          ;es war nur ein Pixel

                move.w  long_move(PC),-2(A2) ;zwei Pixel setzen
                move.w  (A0),(A1)+      ;Pixel ebenfalls Åbernehmen
                subq.w  #1,D0           ;X-ZÑhler verringern
                addq.l  #2,A0           ;nÑchster Pixel
                bra     x_loop

;Hintergrund gefunden

its_back:       addq.l  #2,D6           ;Zieloffset um 2 erhîhen
                bra     x_loop

end_loop:       move.w  return(PC),(A2)+ ;Ende der Generierung
                rts

;Codeteile fÅr 'set_spr':

word_move:      move.w  (A0)+,(A1)+
long_move:      move.l  (A0)+,(A1)+
lea_adr:        lea     $1234(A1),A1
add_adr:        adda.l  #$1234,A1
addquick2:      addq.l  #2,A1
addquick4:      addq.l  #4,A1
addquick6:      addq.l  #6,A1
addquick8:      addq.l  #8,A1
return:         rts


old_modecode:   DS.W 1
old_vbl:        DS.L 1
old_scr_adr:    DS.L 1
log_scr_adr:    DS.L 1
scr_adr:        DC.L scr_base
old_adr_point0: DC.L old_adr0
old_adr_point1: DC.L old_adr1
old_adr0:       Dcb.L spr_anz+1,-1
old_adr1:       Dcb.L spr_anz+1,-1
xy_pointer0:	dc.l xy0
xy_pointer1:	dc.l xy1


offset_tab:
count           SET 0
                REPT y_max
                DC.L count
count           SET count+(x_max+1)*2
                ENDR

xy0:            incbin XY3.BIN
		incbin xy3.bin     
           	DC.W -1
xy1:		incbin xy4.bin
		incbin xy4.bin
		dc.w -1

ball:           incbin d:\KUGEL8.GFX


                BSS
set_sprite:     DS.W 8000
gen_gfx:        DS.W 4000
black:          DS.W 4000
scr_base:       DS.W (x_max+1)*(y_max+1)*2
                END
