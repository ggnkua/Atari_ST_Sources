
; Screen written by Matt of STAXø, Ω 1992/93
; program by Matt, graphics by Sodan/Matt, sound by Sally
;               VBL 1  reserviert: D0,A0,A1,A2,A6
;               "   "   verfÅgbar: D1-D7,A2-A5,A7
; DON'T DARE ABOUT THIS WITHOUT TELLING ME !!!   FUCK YOU ASSHOLE!!!
* Hi Questor, auf keinen Fall auf ANPASSEN klicken, okey !? (Sonst gibt's
* probleme mit sync etc.), tschÅû,
*                                  matt.

                path 'E:'
speed           equ 2           ; Geschwindigkeit der Scroller
anz_zeilen      equ 20          ; wieviel Scrolltext...
height          equ 11          ; Hîhe der Sprites
lines           equ 31          ; Hîhe des STAX Logos
weight          equ 152         ; Breite des STAX Logos in (!) Bytes
logo_pos        equ 160*70-48   ; Startline von STAX Logo
sek_change      equ 5           ; Anz. 50/s pro neuer Farbpalette


                text

                bsr     set_video
                bsr     set_irqs
                jsr     init_logo
                bsr     which_st_type
                st      change_flag

second_part:    move.l  #vbl,$70.w
                bsr     vsync
                movem.l palette,d0-d7
                movem.l d0-d7,$ffff8240.w

paddy_on:       cmpi.b  #$39,$fffffc02.w
                bne.s   paddy_on

                move.l  #sound_only,$70.w
                bsr     clear_ram
                bsr     vsync2

spacetest:      cmpi.b  #$39,$fffffc02.w
                beq.s   spacetest

                move.l  #plasmavbl,$70.w
                bsr.s   loop1
                bsr     vsync2

                bsr     restore_irqs
                bsr     restore_video

                jmp     $0400.w         ; in Loader springen


;-----------------------------------------------------------------------------

loop1:          bsr     vsync2
                addq.w  #1,plasma_offset
                cmpi.w  #194,plasma_offset
                bne.s   loop1

z:              cmpi.b  #2,$fffffc02.w
                beq     change_flags
                cmpi.b  #3,$fffffc02.w
                beq     change_flags2
                cmpi.b  #80,$fffffc02.w
                beq.s   count_up
                cmpi.b  #72,$fffffc02.w
                beq.s   count_down
                cmpi.b  #$39,$fffffc02.w
                bne.s   z

loop2:          bsr     vsync2
                subq.w  #1,plasma_offset
                bne.s   loop2
                rts

;----------------------------------------------------------------------------

count_up:       tst.b   change_flag
                beq.s   z
                cmpi.w  #4,pal_count
                bhi.s   z
                addq.w  #1,pal_count
                lea     pal_tab,a0
                move.w  pal_count,d0
                add.w   d0,d0
                add.w   d0,d0
                movea.l 0(a0,d0.w),a0
                move.l  a0,pal_pntr
wait1:          cmpi.b  #80,$fffffc02.w
                beq.s   wait1
                bra.s   z

count_down:     tst.b   change_flag
                beq.s   z
                cmpi.w  #1,pal_count
                blt     z
                subq.w  #1,pal_count
                lea     pal_tab,a0
                move.w  pal_count,d0
                add.w   d0,d0
                add.w   d0,d0
                movea.l 0(a0,d0.w),a0
                move.l  a0,pal_pntr
wait2:          cmpi.b  #72,$fffffc02.w
                beq.s   wait2
                bra     z

get_colors:     addq.w  #1,pal_count
                cmpi.w  #8,pal_count
                bne.s   okey_dokey
                clr.w   pal_count
okey_dokey:
                lea     pal_tab,a0
                move.w  pal_count,d0
                add.w   d0,d0
                add.w   d0,d0
                movea.l 0(a0,d0.w),a0
                move.l  a0,pal_pntr
                rts

change_flags:   clr.w   pal_count
                st      change_flag
                bra     z
change_flags2:  clr.w   pal_count
                sf      change_flag
                bra     z

;-----------------------------------------------------------------------------

sound_only:     st      vbl_flag
                movem.l d0-a6,-(sp)
                jsr     sound+8
                movem.l (sp)+,d0-a6
                rte

clear_bss:      lea     start_bss,a0
                lea     end_bss,a1
                moveq   #0,d0
clear:          move.l  d0,(a0)+
                cmpa.l  (a0),a1
                bne.s   clear
                rts

;-----------------------------------------------------------------------------

set_video:      move.b  $ffff820a.w,old_sync
                move.b  $ffff8260.w,old_res
                movem.l $ffff8240.w,d0-d7
                movem.l d0-d7,old_pal
                lea     $ffff8201.w,a0
                movep.w 0(a0),d0
                move.w  d0,old_scr

                move.l  $70.w,old70

                moveq   #$12,d0
                bsr     ikbd

                move.l  #init_vbl,$70.w

                moveq   #0,d0
                moveq   #7,d1
                lea     $ffff8240.w,a0
cls_pal:        move.l  d0,(a0)+
                dbra    d1,cls_pal

                jsr     clear_ram(pc)

                move.l  #screen_ram,d0
                clr.b   d0
                move.l  d0,screen
                lsr.l   #8,d0
                lea     $ffff8201.w,a0
                movep.w d0,0(a0)

                moveq   #0,d0
                jsr     sound

                movea.l screen,a0
                lea     160(a0),a0
                move.l  a0,real_screen
                movea.l a0,a1
                lea     230*2(a0),a0    ; dieser ist fÅr die Scroller
                move.l  a0,scroll_screen
                lea     10(a1),a1
                move.l  a1,real_screen  ; hier kommen die Sprites drauf

                jsr     init_sprites(pc)

                jsr     print_scroller(pc)
                jsr     get_scroller(pc)

                jsr     clear_ram(pc)

                bsr     vsync
                move.b  #2,$ffff820a.w
                bsr     vsync
                clr.b   $ffff8260.w
                bsr     vsync
                rts


restore_video:  move.l  #init_vbl,$70.w
                bsr     vsync
                bsr     vsync

                move.b  #8,$ffff8800.w
                clr.b   $ffff8802.w
                move.b  #9,$ffff8800.w
                clr.b   $ffff8802.w
                move.b  #$0a,$ffff8800.w
                clr.b   $ffff8802.w

                movem.l old_pal,d0-d7
                movem.l d0-d7,$ffff8240.w

                bsr.s   vsync
                move.b  #2,$ffff820a.w
                bsr.s   vsync
                move.b  #0,$ffff820a.w
                bsr.s   vsync

                bsr.s   vsync
                move.b  old_sync,$ffff820a.w
                bsr.s   vsync
                move.b  old_res,$ffff8260.w
                bsr.s   vsync
                move.w  old_scr,d0
                lea     $ffff8201.w,a0
                movep.w d0,0(a0)

                moveq   #8,d0
                bsr     ikbd

                move.l  #_rte,$70.w
                rts

;-----------------------------------------------------------------------------

ikbd:           lea     $fffffc00.w,a0
kaeptain_iglo:  btst    #1,(a0)         ; bereit ?
                beq.s   kaeptain_iglo
                move.b  d0,2(a0)
                rts

vsync:          sf      vblflag
john_wayne:     tst.b   vblflag
                beq.s   john_wayne
                rts

vsync2:         sf      vbl_flag
vsync2_:        tst.b   vbl_flag
                beq.s   vsync2_
                rts

;-----------------------------------------------------------------------------

clear_ram:      lea     screen_ram,a0
                move.l  #230*278/4+160/4-1,d0
cls_ram:        clr.l   (a0)+
                dbra    d0,cls_ram
                rts

;-----------------------------------------------------------------------------

set_irqs:       move    sr,d7
                move    #$2700,sr
                lea     $fffffa00.w,a0
                move.b  $07(a0),oldmfp07
                move.b  $09(a0),oldmfp09
                move.b  $11(a0),oldmfp11
                move.b  $13(a0),oldmfp13
                move.b  $15(a0),oldmfp15
                move.b  $17(a0),oldmfp17
                move.b  $19(a0),oldmfp19
                move.b  $1b(a0),oldmfp1b
                move.b  $21(a0),oldmfp21
                clr.b   $07(a0)
                clr.b   $09(a0)
                clr.b   $13(a0)
                clr.b   $15(a0)
                move.l  $0134.w,old134
                move.l  $0120.w,old120
                move.l  $0118.w,old118
                move.l  $0114.w,old114
                move.l  $0110.w,old110
                move.l  $68.w,old68

                bset    #0,$07(a0)
                bset    #0,$13(a0)
                bclr    #3,$17(a0)

                move.l  #init_vbl,$70.w
                move.l  #timer_b,$0120.w
                move    d7,sr
                rts

restore_irqs:   move    sr,d7
                move    #$2700,sr
                move.l  old134,$0134.w
                move.l  old120,$0120.w
                move.l  old118,$0118.w
                move.l  old114,$0114.w
                move.l  old110,$0110.w
                move.l  old68,$68.w

                lea     $fffffa00.w,a0
                move.b  oldmfp07,$07(a0)
                move.b  oldmfp09,$09(a0)
                move.b  oldmfp11,$11(a0)
                move.b  oldmfp13,$13(a0)
                move.b  oldmfp15,$15(a0)
                move.b  oldmfp17,$17(a0)
                move.b  oldmfp19,$19(a0)
                move.b  oldmfp1b,$1b(a0)
                move.b  oldmfp21,$21(a0)

                move    d7,sr
                rts

;------------------------------------------------------------------------------

print_scroller: movea.l txt_pntr,a0
                lea     screen_ram,a1
                move.w  #anz_zeilen-1,d0
nÑchste_zeile:  moveq   #0,d3
                move.w  #52-1,d1        ; 52 Buchstaben pro Zeile
nÑchster_char:  move.b  (a0)+,d2        ; Buchstaben holen
                sub.b   #$20,d2         ; runterzÑhlen
                ext.w   d2              ; erweitern und
                add.w   d2,d2           ; an Tabelle anpassen
                add.w   d2,d2
                lea     char_tab,a2
                movea.l 0(a2,d2.w),a2   ; Zeiger auf Buchstaben
                movea.l a1,a3
                adda.l  d3,a3
                rept 7
                move.b  (a2),(a3)
                lea     160(a2),a2
                lea     52*anz_zeilen(a3),a3
                endr
                addq.l  #1,d3
                dbra    d1,nÑchster_char
                lea     52(a1),a1
                dbra    d0,nÑchste_zeile
                rts


get_scroller:   lea     screen_ram,a0
                lea     scroll_puf,a1
                move.w  #anz_zeilen*7*52-1,d0
uwe_wegmann:    move.b  (a0)+,(a1)+
                dbra    d0,uwe_wegmann

                move.w  #14*4,d0        ; Zeiger auf Pufferliste
                moveq   #14,d1          ; 15 weitere Puffer vorbereiten
shift_next:     lea     screen_ram,a0
                moveq   #7-1,d3
shift_text:     move    #0,ccr
val             set 0
                rept 26*anz_zeilen
                roxr.w  val(a0)
val             set val+2
                endr
                lea     52*anz_zeilen(a0),a0
                dbra    d3,shift_text

                lea     screen_ram,a0
                lea     scroll_puf_tab,a1
                movea.l 0(a1,d0.w),a1
                subq.l  #4,d0
                move.w  #anz_zeilen*7*52-1,d2
uwe_rîssler:    move.b  (a0)+,(a1)+
                dbra    d2,uwe_rîssler
                dbra    d1,shift_next
                rts

;------------------------------------------------------------------------------

init_vbl:       st      vblflag
_rte:           rte

timer_b:        rte


which_st_type:  bsr.s   get_lines
                move.w  scanlines,d0
                cmpi.w  #226,d0         ; ist es mein STE ???
                bne.s   not_my_ste
                clr.w   st_type
                rts
not_my_ste:     move.w  #1,st_type
                rts

;RÅckgabe in 'st_type'.w :   0 = ST mit 29 Zeilen oberer Rand
;                            1 = ST mit 13 Zeilen oberer Rand

get_lines:
;ermittlet wieviel lines auf jeweiliger ST Version im Overscan Modus
;dargestellt werden kînnen.

                move.l  $70.w,-(sp)
                move.l  #testvbl1,$70.w
                bsr     vsync
                bsr     vsync
                subq.w  #3,scanlines

                cmpi.w  #216,scanlines
                blt.s   al_bundy
                move.w  #226,scanlines
al_bundy:       move.l  (sp)+,$70.w
                rts

testvbl1:       clr.b   $fffffa1b.w     ; Timer B holen
                move.b  #1,$fffffa21.w
                move.l  #testb1,$0120.w
                move.b  #8,$fffffa1b.w

                move.l  #testvbl2,$70.w
                clr.b   $ffff820a.w     ; 60 Hz
                st      vblflag
                rte

testvbl2:       clr.b   $fffffa1b.w     ; Timer B aus
                st      vblflag
                rte

testb1:         addq.w  #1,scanlines    ; wieder Zeile mehr
                move.b  #2,$ffff820a.w  ; 50 Hz (Border zu)
                move.l  #testb2,$0120.w ; next
                rte

testb2:         addq.w  #1,scanlines    ; jetzt immer einen dazuzÑhlen bis
                rte                     ; Screen zuende ist !!!

;------------------------------------------------------------------------------

plasmavbl:      st      vbl_flag
                move    #$2700,sr
                movem.l d0-a6,-(sp)

                movem.l palettestax,d0-d7
                movem.l d0-d7,$ffff8240.w

                tst.b   change_flag
                bne.s   nix_news
                addq.w  #1,change_pal
                cmpi.w  #sek_change,change_pal
                bne.s   nix_news
                bsr     get_colors
                clr.w   change_pal
nix_news:

                addi.w  #2,ras_pntr
                cmpi.w  #300,ras_pntr
                bne.s   do_it
                clr.w   ras_pntr

do_it:          clr.b   $fffffa1b.w
                move.b  #199,$fffffa21.w
                move.b  #8,$fffffa1b.w
                move.l  #hbl0,$0120.w

                jsr     copy_distorter

;---------------------------------------------------
;---- Alles fÅr den Plasma-Synchron-code vorbereiten
;---------------------------------------------------
                moveq   #0,d0
                moveq   #0,d1
                move.w  #18,d2
                move.w  plasma_offset,d7

                movea.l pal_pntr,a0
                movea.l a0,a2
                lea     $ffff8240.w,a1
                addq.w  #2,nop_count
                cmpi.w  #96,nop_count
                bne.s   nix1
                clr.w   nop_count
nix1:           lea     nop_data,a3
                move.w  nop_count,d1
                lea     nop_ende(pc),a4
                lea     plasma_dist,a5

wait_beam0:     move.b  $ffff8209.w,d0
                beq.s   wait_beam0
                not.b   d0
                lsl.b   d0,d0

                ds.w 70,$4e71
                move.w  (a0),(a1)

;------------------------------------------------------------------------;
;---- hier beginnt der Synchronteil (pro Zeile 512 Cycles)            ---;
;------------------------------------------------------------------------;
;--- a0 Zeiger auf Farben, a1 Farbregister, d7 Plasmalines DBF-ZÑhler ---;
;--- d1 Offset auf Offset-Tabelle, a3 Offset-Tabelle                  ---;
;--- a5 Plasma Distpositions Table, a4 Nop-Tabelle Ende (Sprung)      ---;
;--- used: 476 Cycles complex code + max. 72 cycles special Nop's     ---;
;------------------------------------------------------------------------;
plasma_lines:   move.w  (a5)+,d0        ;  [8]
                add.w   d0,d1           ;  [4]
                move.l  0(a3,d1.w),d0   ; [20]
                move.w  d0,d3           ;  [4]
                movea.l a4,a6           ;  [4]
                suba.w  d0,a6           ;  [8]
                jsr     (a6)            ; [16]

                movea.l a0,a2           ;  [4]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                move.w  (a2)+,(a1)      ; [12]
                nop                     ;  [4]
                dbra    d7,plasma_lines ; [12]

                move    #$2300,sr

;-------------------------------------------------------------------;
;---- ab hier wieder normaler Code (noch etwa 20000 Cycles frei) ---;
;-------------------------------------------------------------------;
;------------------------------------------------------;
;---- neuen Buchstaben holen und in Puffer kopieren ---;
;------------------------------------------------------;
                subq.w  #1,scroll_count
                bne.s   keep_char
                move.w  #4,scroll_count
                moveq   #0,d0
                movea.l text_pntr,a0
                move.b  (a0)+,d0
                cmpi.b  #-1,(a0)
                bne.s   txt_okey
                lea     txt,a0
txt_okey:       move.l  a0,text_pntr
                sub.b   #32,d0
                ext.w   d0
                add.w   d0,d0
                add.w   d0,d0
                lea     font_tab,a0
                lea     char_puf,a1
                movea.l 0(a0,d0.w),a0
                moveq   #7,d0
copy_puf:       move.b  (a0),(a1)+
                lea     160(a0),a0
                dbra    d0,copy_puf
keep_char:      movem.l (sp)+,d0-a6
                rte


;-----------------------------------------------;
;---- hier die Nop Table, insgesamt 72 Cycles --;
;-----------------------------------------------;
nop_table:      nop                     ; 1
                nop                     ; 2
                nop                     ; 3
                nop                     ; 4
                nop                     ; 5
                nop                     ; 6
                nop                     ; 7
                nop                     ; 8
                nop                     ; 9
                nop                     ; 10
                nop                     ; 11
                nop                     ; 12
                nop                     ; 13
                nop                     ; 14
                nop                     ; 15
                nop                     ; 16
                nop                     ; 17
nop_ende:       nop                     ; 18
                rts


;--------------------------------------------;
;---- hier sind die rasterlines interrupts --;
;--------------------------------------------;
hbl0:           clr.b   $fffffa1b.w
                movem.l d0-a6,-(sp)
                movea.w #$fa21,a0
                move.b  #200,(a0)
                move.b  #8,-6(a0)
                move.b  (a0),d0
wait_da_border: cmp.b   (a0),d0
                beq.s   wait_da_border
                clr.b   $ffff820a.w
                nop
                moveq   #1,d0
open:           nop
                dbra    d0,open
                nop
                move.w  #0,$ffff8240.w
                move.b  #2,$ffff820a.w
                clr.b   -6(a0)
                move    #$2700,sr
                lea     $ffff820a.w,a0
                lea     $ffff8260.w,a1
                lea     scroll_pal,a2
                lea     $ffff8242.w,a3
                lea     $ffff8240.w,a5
                lea     ras_pal,a4
                adda.w  ras_pntr,a4

                moveq   #0,d0
open_left_right:move.b  $ffff8209.w,d0
                beq.s   open_left_right
                not.b   d0
                lsl.b   d0,d0

                ds.w 73,$4e71

;-------------------------------------------------------------------------;
;---- ein paar Zeilen îffnen fÅr Scroller (Chars sind 7 Pixel hoch!!!) ---;
;-------------------------------------------------------------------------;
open_lines:     rept 7
                nop
                move.w  a1,(a1)
                nop
                move.b  d0,(a1)
                move.w  (a4)+,(a5)
                move.w  (a2)+,(a3)
                ds.w 83,$4e71
                move.b  d0,(a0)
                move.w  a0,(a0)
                ds.w 13,$4e71
                move.w  a1,(a1)
                nop
                move.b  d0,(a1)
                ds.w 7,$4e71
                clr.w   $ffff8240.w
                endr

;--------------------
;---- Screen rotieren
;--------------------
                bsr.s   scroller
                bsr.s   scroller

                jsr     sound+8
                move    #$2300,sr
                movem.l (sp)+,d0-a6
                bclr    #0,$fffffa0f.w
                rte

;---------------------------------------------------------------------------;
;---- Routine rotiert Screen um 1 Pixel nach links (erstes Bitplane nur) ---;
;---------------------------------------------------------------------------;
scroller:       lea     char_puf,a0
                movea.l screen,a1
                lea     32000(a1),a1
                lea     160(a1),a1
                moveq   #6,d0
one_plane:      move    #0,ccr
                moveq   #0,d1
                move.b  (a0),d1
                asl.b   #1,d1
                move.b  d1,(a0)+
                roxl.w  25*8(a1)
                roxl.w  24*8(a1)
                roxl.w  23*8(a1)
                roxl.w  22*8(a1)
                roxl.w  21*8(a1)
                roxl.w  20*8(a1)
                roxl.w  19*8(a1)
                roxl.w  18*8(a1)
                roxl.w  17*8(a1)
                roxl.w  16*8(a1)
                roxl.w  15*8(a1)
                roxl.w  14*8(a1)
                roxl.w  13*8(a1)
                roxl.w  12*8(a1)
                roxl.w  11*8(a1)
                roxl.w  10*8(a1)
                roxl.w  9*8(a1)
                roxl.w  8*8(a1)
                roxl.w  7*8(a1)
                roxl.w  6*8(a1)
                roxl.w  5*8(a1)
                roxl.w  4*8(a1)
                roxl.w  3*8(a1)
                roxl.w  2*8(a1)
                roxl.w  1*8(a1)
                roxl.w  (a1)
                lea     230(a1),a1
                dbra    d0,one_plane
                rts



;------------------------------------------------------------------------------

sprite_routine2:
;---- alten Hintegrund in umgekehrter Reihenfolge zurÅcksetzen
                movea.l old_back_s,a0   ; [20]
                bsr     restore_sprite  ; [12]

                movea.l old_back_t,a0   ; [20]
                bsr     restore_sprite  ; [12]

                movea.l old_back_a,a0   ; [20]
                bsr     restore_sprite  ; [12]

                movea.l old_back_x,a0   ; [20]
                bsr     restore_sprite  ; [12]

                movea.l old_back_m,a0   ; [20]
                bsr     restore_sprite  ; [12]

                movea.l old_back_a2,a0  ; [20]
                bsr     restore_sprite  ; [12]

                movea.l old_back_t2,a0  ; [20]
                bsr     restore_sprite  ; [12]

                movea.l old_back_t3,a0  ; [20]
                bsr     restore_sprite  ; [12]

; bis hier 2032 Taktzyklen
                rts

sprite_routine1:
;---- Parameter holen und Sprite setzen
                movea.l x_pointer_x,a0  ; [20]
                move.w  (a0)+,d5        ; [8]
                cmpi.w  #-1,(a0)        ; [12]
                bne.s   x1_okey         ; [12]
                lea     x_tab,a0        ; [12]
x1_okey:        move.l  a0,x_pointer_x  ; [12]
                movea.l y_pointer_x,a0  ; [20]
                move.l  (a0)+,d6        ; [8]
                cmpi.l  #-1,(a0)        ; [12]
                bne.s   y1_okey         ; [12]
                lea     y_tab,a0        ; [12]
y1_okey:        move.l  a0,y_pointer_x  ; [20]
                lea     mask_puffer_x,a2 ;    [12]
                lea     sprite_puffer_x,a3 ;  [12]
                movea.l real_screen,a6  ; Screenadresse   [20]

                bsr     set_sprite      ;     [12]
                move.l  save_pos,old_back_x ; [20]
; 228 Taktzyklen

                movea.l x_pointer_a,a0
                move.w  (a0)+,d5
                cmpi.w  #-1,(a0)
                bne.s   x2_okey
                lea     x_tab,a0
x2_okey:        move.l  a0,x_pointer_a
                movea.l y_pointer_a,a0
                move.l  (a0)+,d6
                cmpi.l  #-1,(a0)
                bne.s   y2_okey
                lea     y_tab,a0
y2_okey:        move.l  a0,y_pointer_a
                lea     mask_puffer_a,a2
                lea     sprite_puffer_a,a3
                movea.l real_screen,a6  ; Screenadresse   [20]

                bsr     set_sprite
                move.l  save_pos,old_back_a
; 228 Taktzyklen

                movea.l x_pointer_t,a0
                move.w  (a0)+,d5
                cmpi.w  #-1,(a0)
                bne.s   x3_okey
                lea     x_tab,a0
x3_okey:        move.l  a0,x_pointer_t
                movea.l y_pointer_t,a0
                move.l  (a0)+,d6
                cmpi.l  #-1,(a0)
                bne.s   y3_okey
                lea     y_tab,a0
y3_okey:        move.l  a0,y_pointer_t
                lea     mask_puffer_t,a2
                lea     sprite_puffer_t,a3
                movea.l real_screen,a6  ; Screenadresse   [20]

                bsr     set_sprite
                move.l  save_pos,old_back_t
; 228 Taktzyklen

                movea.l x_pointer_s,a0
                move.w  (a0)+,d5
                cmpi.w  #-1,(a0)
                bne.s   x4_okey
                lea     x_tab,a0
x4_okey:        move.l  a0,x_pointer_s
                movea.l y_pointer_s,a0
                move.l  (a0)+,d6
                cmpi.l  #-1,(a0)
                bne.s   y4_okey
                lea     y_tab,a0
y4_okey:        move.l  a0,y_pointer_s
                lea     mask_puffer_s,a2
                lea     sprite_puffer_s,a3
                movea.l real_screen,a6  ; Screenadresse   [20]

                bsr     set_sprite
                move.l  save_pos,old_back_s
; 228 Taktzyklen

                movea.l x_pointer_m,a0
                move.w  (a0)+,d5
                cmpi.w  #-1,(a0)
                bne.s   x5_okey
                lea     x_tab,a0
x5_okey:        move.l  a0,x_pointer_m
                movea.l y_pointer_m,a0
                move.l  (a0)+,d6
                cmpi.l  #-1,(a0)
                bne.s   y5_okey
                lea     y_tab,a0
y5_okey:        move.l  a0,y_pointer_m
                lea     mask_puffer_m,a2
                lea     sprite_puffer_m,a3
                movea.l real_screen,a6  ; Screenadresse   [20]
                addq.l  #2,a6

                bsr     set_sprite
                move.l  save_pos,old_back_m
; 228 Taktzyklen

                movea.l x_pointer_a2,a0
                move.w  (a0)+,d5
                cmpi.w  #-1,(a0)
                bne.s   x6_okey
                lea     x_tab,a0
x6_okey:        move.l  a0,x_pointer_a2
                movea.l y_pointer_a2,a0
                move.l  (a0)+,d6
                cmpi.l  #-1,(a0)
                bne.s   y6_okey
                lea     y_tab,a0
y6_okey:        move.l  a0,y_pointer_a2
                lea     mask_puffer_a,a2
                lea     sprite_puffer_a,a3
                movea.l real_screen,a6  ; Screenadresse   [20]
                addq.l  #2,a6

                bsr     set_sprite
                move.l  save_pos,old_back_a2
; 228 Taktzyklen

                movea.l x_pointer_t2,a0
                move.w  (a0)+,d5
                cmpi.w  #-1,(a0)
                bne.s   x7_okey
                lea     x_tab,a0
x7_okey:        move.l  a0,x_pointer_t2
                movea.l y_pointer_t2,a0
                move.l  (a0)+,d6
                cmpi.l  #-1,(a0)
                bne.s   y7_okey
                lea     y_tab,a0
y7_okey:        move.l  a0,y_pointer_t2
                lea     mask_puffer_t,a2
                lea     sprite_puffer_t,a3
                movea.l real_screen,a6  ; Screenadresse   [20]
                addq.l  #2,a6

                bsr     set_sprite
                move.l  save_pos,old_back_t2
; 228 Taktzyklen

                movea.l x_pointer_t3,a0
                move.w  (a0)+,d5
                cmpi.w  #-1,(a0)
                bne.s   x8_okey
                lea     x_tab,a0
x8_okey:        move.l  a0,x_pointer_t3
                movea.l y_pointer_t3,a0
                move.l  (a0)+,d6
                cmpi.l  #-1,(a0)
                bne.s   y8_okey
                lea     y_tab,a0
y8_okey:        move.l  a0,y_pointer_t3
                lea     mask_puffer_t,a2
                lea     sprite_puffer_t,a3
                movea.l real_screen,a6  ; Screenadresse   [20]
                addq.l  #2,a6

                bsr     set_sprite
                move.l  save_pos,old_back_t3
                rts

restore_sprite:
;---- A0 Position
                moveq   #0,d0           ; [4]
                rept height
                move.w  d0,(a0)         ; [8]
                move.w  d0,8(a0)        ; [12]
                lea     230(a0),a0      ; [8]
                endr
                rts


;---- A2 Maske, A3 Sprite data, A6 Screen
;---- D5 X-Pos, D6 Y-Pos
; braucht etwa 2224 Taktzyklen pro Durchlauf
set_sprite:
                move.w  d5,d7           ; Wert retten     [4]

                and.w   #$fff0,d5       ; runden           [8]
                lsr.w   #1,d5           ; benutzbar machen [8]

                and.w   #$0f,d7         ; modula 16                  [8]
                mulu    #height*16,d7   ; Offset fÅr Puffer machen   [?]

                mulu    #230,d6         ; Y-Pos berechnen            [?]

                add.w   d5,d6           ; X-Pos + Y-Pos              [8]
                adda.l  d6,a6           ;  = Screenadresse           [8]

                move.l  a6,save_pos     ; wird nochmal gebraucht !!! [20]

                movea.l a6,a5           ; Screenadresse merken       [4]

                adda.l  d7,a2           ; richtige Maske             [8]
                adda.l  d7,a3           ; richtes Sprite             [8]

und:            rept height
                move.w  (a2),d5         ; Maske laden                [8]
                move.w  8(a2),d4        ; "                          [12]
                lea     16(a2),a2       ; neue Zeile                 [8]

                not.w   d5              ; invertieren                [4]
                not.w   d4              ; "                          [4]

                and.w   d5,(a6)         ; auf Screen setzen          [8]
                and.w   d4,8(a6)        ; "                          [12]
                lea     230(a6),a6      ; neue Bildschirmzeile       [8]
                endr

oder:           rept height
                move.w  (a3),d2         ; Sprite laden               [8]
                or.w    d2,(a5)         ; und in Screen verknÅpfen   [8]

                move.w  8(a3),d2        ; "                          [12]
                or.w    d2,8(a5)        ; "                          [12]

                lea     16(a3),a3       ; nÑchste Spritezeile        [8]
                lea     230(a5),a5      ; nÑchste Bildschirmzeile    [8]
                endr
                rts


;---- A0 Mask, A3 Mask Puffer
;---- A4 Sprite, A5 Sprite Puffer
shift_sprite:   moveq   #0,d7
;---- erst Masken vorbereiten
                lea     save_maske,a1   ; neue Maske erstellen
                movea.l a3,a2
                move.w  #height-1,d0
new_mask:       move.w  (a0),(a1)+      ; einmal nicht verschieben
                move.w  (a0),(a2)+
                move.w  (a0),(a1)+
                move.w  (a0)+,(a2)+
                move.l  d7,(a1)+
                move.l  d7,(a1)+
                move.l  d7,(a1)+
                move.l  d7,(a2)+
                move.l  d7,(a2)+
                move.l  d7,(a2)+
                dbra    d0,new_mask

                move.w  #1,d6
                move.w  #14,d4
next_mask:      lea     save_maske,a0
                move.w  #height-1,d0
banana:         move    #0,ccr
                roxr.w  (a0)
                roxr.w  8(a0)
                lea     16(a0),a0
                dbra    d0,banana

                lea     save_maske,a0
                movea.l a3,a1
                move.w  d6,d5
                addq.w  #1,d6
                mulu    #height*16,d5
                adda.l  d5,a1
                move.w  #height-1,d0
copy_mask:      move.w  (a0)+,(a1)+
                move.w  (a0)+,(a1)+
                move.l  (a0)+,(a1)+
                move.l  (a0)+,(a1)+
                move.l  (a0)+,(a1)+
                dbra    d0,copy_mask
                dbra    d4,next_mask

;---- Sprite umwandeln und vorshiften
                movea.l a4,a0           ; neues Sprite erstellen
                lea     save_sprite,a2
                movea.l a5,a1
                move.w  #height-1,d0
copy_1st_spr:   move.l  (a0),(a2)+
                move.l  (a0)+,(a1)+
                move.l  (a0),(a2)+
                move.l  (a0)+,(a1)+
                move.l  d7,(a2)+
                move.l  d7,(a2)+
                move.l  d7,(a1)+
                move.l  d7,(a1)+
                dbra    d0,copy_1st_spr

                move.w  #1,d6
                move.w  #14,d4
next_sprite:    moveq   #0,d2
another_plane:  lea     save_sprite,a0
                lea     0(a0,d2.w),a0
                move.w  #height-1,d0
lucky:          move    #0,ccr
                roxr.w  (a0)
                roxr.w  8(a0)
                lea     16(a0),a0
                dbra    d0,lucky
                addq.w  #2,d2
                cmpi.w  #8,d2
                bne.s   another_plane

                lea     save_sprite,a0
                movea.l a5,a1
                move.w  d6,d5
                addq.w  #1,d6
                mulu    #height*16,d5
                adda.l  d5,a1
                move.w  #height-1,d0
copy_sprite:    move.w  (a0)+,(a1)+
                move.w  (a0)+,(a1)+
                move.l  (a0)+,(a1)+
                move.l  (a0)+,(a1)+
                move.l  (a0)+,(a1)+
                dbra    d0,copy_sprite
                dbra    d4,next_sprite
                rts

;---- A0= Y_Pointer, A1 X_Pointer
;---- back: A3 = Backgroundposition
prepare_sprite_puffers:
                movea.l real_screen,a3
                move.w  (a0),d0
                move.w  (a1),d1
                and.w   #$fff0,d1
                lsr.w   #1,d1
                mulu    #230,d0
                add.w   d1,d0
                adda.l  d0,a3
                rts


init_sprites:   lea     mask_s,a0
                lea     mask_puffer_s,a3
                lea     sprite_s,a4
                lea     sprite_puffer_s,a5
                bsr     shift_sprite

                lea     mask_t,a0
                lea     mask_puffer_t,a3
                lea     sprite_t,a4
                lea     sprite_puffer_t,a5
                bsr     shift_sprite

                lea     mask_a,a0
                lea     mask_puffer_a,a3
                lea     sprite_a,a4
                lea     sprite_puffer_a,a5
                bsr     shift_sprite

                lea     mask_x,a0
                lea     mask_puffer_x,a3
                lea     sprite_x,a4
                lea     sprite_puffer_x,a5
                bsr     shift_sprite

                lea     mask_m,a0
                lea     mask_puffer_m,a3
                lea     sprite_m,a4
                lea     sprite_puffer_m,a5
                bsr     shift_sprite
                rts

;--------------------------------------------------------------------------

vbl:            clr.w   $ffff8240.w     ; schwarz
                jsr     sprite_routine1(pc)

                ds.w 40,$4e71

                move.l  #open_top,$68.w ; HBL schicken
                move.w  #2,hbl_count    ; Anzahl Zeilen warten (nicht mehr
                move    #$2100,sr       ; viel... wegen den Sprites !!!)
                st      vblflag         ; VBL ist das
                move.w  #$2100,(sp)
                rte

open_top:       subq.w  #1,hbl_count    ; abwÑrts zÑhlen bis 0
                beq.s   openit          ; und dann den oberen Rand îffnen
                rte

openit:         move.l  #open_top2,$68.w
                stop    #$2100          ; bis zum nÑchsten HBL ist Funkstille

open_top2:      move    #$2700,sr       ; [16] keine Unterbrechung mehr
                addq.l  #6,sp           ; [8]  Stack sollte korrigiert werden...

                ds.w 86,$4e71   ; [344] warten...

                move.b  #0,$ffff820a.w  ; [16]  60 Hz

                ds.w 17,$4e71   ; [68]

                move.b  #2,$ffff820a.w  ; [16]  50 Hz

                subq.w  #2,ras_count
                bne.s   okey_ras
                move.w  #694,ras_count
okey_ras:       lea     $ffff8242.w,a6  ; Farbregister
                lea     raster_pal,a2   ; Farben
                adda.w  ras_count,a2
                lea     $ffff820a.w,a0  ; Sync-Register
                lea     $ffff8260.w,a1  ; Auflîsungsregister

                moveq   #0,d0
gerd_mueller:   move.b  $ffff8209.w,d0  ; screen low byte
                beq.s   gerd_mueller
                not.w   d0
                lsr.w   d0,d0           ; jetzt wird synchronisiert

                ds.w 73,$4e71   ; Anfang der 2. Zeile abwarten

fullscreen_code:
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                movea.l x_dist_pntr,a3  ; [20]
                move.w  (a3)+,d2        ; [8]
                bne     nicht_null1     ; [12]
                lea     x_dist,a3       ; [12]
                bra     nicht_null2     ; [12]
nicht_null1:    ds.w 6,$4e71    ; [24]
nicht_null2:    move.l  a3,x_dist_pntr  ; [20] Zeiger auf X-Tab konstant lassen

                move.w  x_pos,d1        ; [16]
                addq.w  #speed,d1       ; [4]
                cmpi.w  #(anz_zeilen+3)*52*7,d1 ; [8]
                bne     mehr_text1      ; [12]
                moveq   #0,d1           ; [4]
                bra     mehr_text2      ; [12]
mehr_text1:     ds.w 4,$4e71    ; [16]
mehr_text2:     move.w  d1,x_pos        ; [16]
                move.w  d1,d3           ; [4] merken
                movea.l scroll_screen,a4 ; [20] Screenadresse konstant halten

;--- hier beginnt eine Scroller-Schleife

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]

                move.w  (a2)+,(a6)      ; [12]


; newline's
                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]
                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]

                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]


                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]

                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                move.w  (a5)+,(a4)      ; [12]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]

                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]

                move.w  (a2)+,(a6)      ; [12]

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]

                ds.w 1,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a2)+,(a6)      ; [12]


; newline
                rept 5
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]

                ds.w 1,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]

                ds.w 1,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                ds.w 1,$4e71

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]

                move.w  (a2)+,(a6)      ; [12]

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]

                ds.w 3,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 5
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline


                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 5
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 5
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]

                ds.w 2,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]


                adda.w  d1,a5           ; [8]
                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline
                rept 6
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]

                ds.w 1,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                lea     230(a4),a4      ; [8]
                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]

                ds.w 1,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                ds.w 2,$4e71

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]

                move.w  (a2)+,(a6)      ; [12]

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]

                ds.w 3,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]

                and.w   #$fff0,d1       ; [8]

                ds.w 1,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                movea.l 0(a5,d4.w),a5   ; [20]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]

                ds.w 1,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,25*8(a4)  ; [16]
                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]
                move.w  (a5)+,(a4)      ; [12]

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]

                ds.w 1,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]

                and.w   #$fff0,d1       ; [8]

                ds.w 1,$4e71

                move.w  (a2)+,(a6)      ; [12]

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                movea.l 0(a5,d4.w),a5   ; [20]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,25*8(a4)  ; [16]

                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [20]
                move.w  (a5)+,2*8(a4)   ; [20]
                move.w  (a5)+,3*8(a4)   ; [20]
                move.w  (a5)+,4*8(a4)   ; [20]
                move.w  (a5)+,5*8(a4)   ; [20]
                move.w  (a5)+,6*8(a4)   ; [20]
                move.w  (a5)+,7*8(a4)   ; [20]
                move.w  (a5)+,8*8(a4)   ; [20]
                move.w  (a5)+,9*8(a4)   ; [20]
                move.w  (a5)+,10*8(a4)  ; [20]
                move.w  (a5)+,11*8(a4)  ; [20]
                move.w  (a5)+,12*8(a4)  ; [20]
                move.w  (a5)+,13*8(a4)  ; [20]
                move.w  (a5)+,14*8(a4)  ; [20]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,15*8(a4)  ; [20]
                move.w  (a5)+,16*8(a4)  ; [20]
                move.w  (a5)+,17*8(a4)  ; [20]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,18*8(a4)  ; [20]
                move.w  (a5)+,19*8(a4)  ; [20]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,20*8(a4)  ; [20] NICHT 20, SONDERN 16 Zykles
                move.w  (a5)+,21*8(a4)  ; [20] Die 20'er Klammern stimmen nicht
                move.w  (a5)+,22*8(a4)  ; [20]
                move.w  (a5)+,23*8(a4)  ; [20]
                move.w  (a5)+,24*8(a4)  ; [20]
                move.w  (a5)+,25*8(a4)  ; [20]

                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [20]
                move.w  (a5)+,2*8(a4)   ; [20]
                move.w  (a5)+,3*8(a4)   ; [20]
                move.w  (a5)+,4*8(a4)   ; [20]
                move.w  (a5)+,5*8(a4)   ; [20]
                move.w  (a5)+,6*8(a4)   ; [20]
                move.w  (a5)+,7*8(a4)   ; [20]
                move.w  (a5)+,8*8(a4)   ; [20]
                move.w  (a5)+,9*8(a4)   ; [20]
                move.w  (a5)+,10*8(a4)  ; [20]
                move.w  (a5)+,11*8(a4)  ; [20]
                move.w  (a5)+,12*8(a4)  ; [20]
                move.w  (a5)+,13*8(a4)  ; [20]
                move.w  (a5)+,14*8(a4)  ; [20]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,15*8(a4)  ; [20]
                move.w  (a5)+,16*8(a4)  ; [20]
                move.w  (a5)+,17*8(a4)  ; [20]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,18*8(a4)  ; [20]
                move.w  (a5)+,19*8(a4)  ; [20]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,20*8(a4)  ; [20]
                move.w  (a5)+,21*8(a4)  ; [20]
                move.w  (a5)+,22*8(a4)  ; [20]
                move.w  (a5)+,23*8(a4)  ; [20]
                move.w  (a5)+,24*8(a4)  ; [20]
                move.w  (a5)+,25*8(a4)  ; [20]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [20]
                move.w  (a5)+,2*8(a4)   ; [20]
                move.w  (a5)+,3*8(a4)   ; [20]
                move.w  (a5)+,4*8(a4)   ; [20]
                move.w  (a5)+,5*8(a4)   ; [20]
                move.w  (a5)+,6*8(a4)   ; [20]
                move.w  (a5)+,7*8(a4)   ; [20]
                move.w  (a5)+,8*8(a4)   ; [20]
                move.w  (a5)+,9*8(a4)   ; [20]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,10*8(a4)  ; [20]
                move.w  (a5)+,11*8(a4)  ; [20]
                move.w  (a5)+,12*8(a4)  ; [20]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,13*8(a4)  ; [20]
                move.w  (a5)+,14*8(a4)  ; [20]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,15*8(a4)  ; [20]
                move.w  (a5)+,16*8(a4)  ; [20]
                move.w  (a5)+,17*8(a4)  ; [20]
                move.w  (a5)+,18*8(a4)  ; [20]
                move.w  (a5)+,19*8(a4)  ; [20]
                move.w  (a5)+,20*8(a4)  ; [20]
                move.w  (a5)+,21*8(a4)  ; [20]
                move.w  (a5)+,22*8(a4)  ; [20]
                move.w  (a5)+,23*8(a4)  ; [20]
                move.w  (a5)+,24*8(a4)  ; [20]
                move.w  (a5)+,25*8(a4)  ; [20]

                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [20]
                move.w  (a5)+,2*8(a4)   ; [20]
                move.w  (a5)+,3*8(a4)   ; [20]
                move.w  (a5)+,4*8(a4)   ; [20]
                move.w  (a5)+,5*8(a4)   ; [20]
                move.w  (a5)+,6*8(a4)   ; [20]
                move.w  (a5)+,7*8(a4)   ; [20]
                move.w  (a5)+,8*8(a4)   ; [20]
                move.w  (a5)+,9*8(a4)   ; [20]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,10*8(a4)  ; [20]
                move.w  (a5)+,11*8(a4)  ; [20]
                move.w  (a5)+,12*8(a4)  ; [20]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,13*8(a4)  ; [20]
                move.w  (a5)+,14*8(a4)  ; [20]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,15*8(a4)  ; [20]
                move.w  (a5)+,16*8(a4)  ; [20]
                move.w  (a5)+,17*8(a4)  ; [20]
                move.w  (a5)+,18*8(a4)  ; [20]
                move.w  (a5)+,19*8(a4)  ; [20]
                move.w  (a5)+,20*8(a4)  ; [20]
                move.w  (a5)+,21*8(a4)  ; [20]
                move.w  (a5)+,22*8(a4)  ; [20]
                move.w  (a5)+,23*8(a4)  ; [20]
                move.w  (a5)+,24*8(a4)  ; [20]
                move.w  (a5)+,25*8(a4)  ; [20]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [20]
                move.w  (a5)+,2*8(a4)   ; [20]
                move.w  (a5)+,3*8(a4)   ; [20]
                move.w  (a5)+,4*8(a4)   ; [20]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,5*8(a4)   ; [20]
                move.w  (a5)+,6*8(a4)   ; [20]
                move.w  (a5)+,7*8(a4)   ; [20]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,8*8(a4)   ; [20]
                move.w  (a5)+,9*8(a4)   ; [20]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,10*8(a4)  ; [20]
                move.w  (a5)+,11*8(a4)  ; [20]
                move.w  (a5)+,12*8(a4)  ; [20]
                move.w  (a5)+,13*8(a4)  ; [20]
                move.w  (a5)+,14*8(a4)  ; [20]
                move.w  (a5)+,15*8(a4)  ; [20]
                move.w  (a5)+,16*8(a4)  ; [20]
                move.w  (a5)+,17*8(a4)  ; [20]
                move.w  (a5)+,18*8(a4)  ; [20]
                move.w  (a5)+,19*8(a4)  ; [20]
                move.w  (a5)+,20*8(a4)  ; [20]
                move.w  (a5)+,21*8(a4)  ; [20]
                move.w  (a5)+,22*8(a4)  ; [20]
                move.w  (a5)+,23*8(a4)  ; [20]
                move.w  (a5)+,24*8(a4)  ; [20]
                move.w  (a5)+,25*8(a4)  ; [20]

                lea     230(a4),a4      ; [8]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [20]
                move.w  (a5)+,2*8(a4)   ; [20]
                move.w  (a5)+,3*8(a4)   ; [20]
                move.w  (a5)+,4*8(a4)   ; [20]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,5*8(a4)   ; [20]
                move.w  (a5)+,6*8(a4)   ; [20]
                move.w  (a5)+,7*8(a4)   ; [20]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,8*8(a4)   ; [20]
                move.w  (a5)+,9*8(a4)   ; [20]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,10*8(a4)  ; [20]
                move.w  (a5)+,11*8(a4)  ; [20]
                move.w  (a5)+,12*8(a4)  ; [20]
                move.w  (a5)+,13*8(a4)  ; [20]
                move.w  (a5)+,14*8(a4)  ; [20]
                move.w  (a5)+,15*8(a4)  ; [20]
                move.w  (a5)+,16*8(a4)  ; [20]
                move.w  (a5)+,17*8(a4)  ; [20]
                move.w  (a5)+,18*8(a4)  ; [20]
                move.w  (a5)+,19*8(a4)  ; [20]
                move.w  (a5)+,20*8(a4)  ; [20]
                move.w  (a5)+,21*8(a4)  ; [20]
                move.w  (a5)+,22*8(a4)  ; [20]
                move.w  (a5)+,23*8(a4)  ; [20]
                move.w  (a5)+,24*8(a4)  ; [20]
                move.w  (a5)+,25*8(a4)  ; [20]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]

                ds.w 1,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                ds.w 1,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                lea     230(a4),a4      ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]

                and.w   #$fff0,d1       ; [8]

                ds.w 2,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]


                movea.l 0(a5,d4.w),a5   ; [20]
                lsr.w   #3,d1           ; [12]
                move.w  (a2)+,(a6)      ; [12]

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [20]
                move.w  (a5)+,2*8(a4)   ; [20]
                move.w  (a5)+,3*8(a4)   ; [20]
                move.w  (a5)+,4*8(a4)   ; [20]
                move.w  (a5)+,5*8(a4)   ; [20]
                move.w  (a5)+,6*8(a4)   ; [20]
                move.w  (a5)+,7*8(a4)   ; [20]
                move.w  (a5)+,8*8(a4)   ; [20]
                move.w  (a5)+,9*8(a4)   ; [20]
                move.w  (a5)+,10*8(a4)  ; [20]
                move.w  (a5)+,11*8(a4)  ; [20]
                move.w  (a5)+,12*8(a4)  ; [20]
                move.w  (a5)+,13*8(a4)  ; [20]
                move.w  (a5)+,14*8(a4)  ; [20]
                move.w  (a5)+,15*8(a4)  ; [20]
                move.w  (a5)+,16*8(a4)  ; [20]
                move.w  (a5)+,17*8(a4)  ; [20]
                move.w  (a5)+,18*8(a4)  ; [20]
                move.w  (a5)+,19*8(a4)  ; [20]
                move.w  (a5)+,20*8(a4)  ; [20]
                move.w  (a5)+,21*8(a4)  ; [20]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,25*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

; newline

                rept 5
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                lea     230(a4),a4      ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [20]
                move.w  (a5)+,2*8(a4)   ; [20]
                move.w  (a5)+,3*8(a4)   ; [20]
                move.w  (a5)+,4*8(a4)   ; [20]
                move.w  (a5)+,5*8(a4)   ; [20]
                move.w  (a5)+,6*8(a4)   ; [20]
                move.w  (a5)+,7*8(a4)   ; [20]
                move.w  (a5)+,8*8(a4)   ; [20]
                move.w  (a5)+,9*8(a4)   ; [20]
                move.w  (a5)+,10*8(a4)  ; [20]
                move.w  (a5)+,11*8(a4)  ; [20]
                move.w  (a5)+,12*8(a4)  ; [20]
                move.w  (a5)+,13*8(a4)  ; [20]
                move.w  (a5)+,14*8(a4)  ; [20]
                move.w  (a5)+,15*8(a4)  ; [20]
                move.w  (a5)+,16*8(a4)  ; [20]
                move.w  (a5)+,17*8(a4)  ; [20]
                move.w  (a5)+,18*8(a4)  ; [20]
                move.w  (a5)+,19*8(a4)  ; [20]
                move.w  (a5)+,20*8(a4)  ; [20]
                move.w  (a5)+,21*8(a4)  ; [20]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,25*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                lea     230(a4),a4      ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [20]
                move.w  (a5)+,2*8(a4)   ; [20]
                move.w  (a5)+,3*8(a4)   ; [20]
                move.w  (a5)+,4*8(a4)   ; [20]
                move.w  (a5)+,5*8(a4)   ; [20]
                move.w  (a5)+,6*8(a4)   ; [20]
                move.w  (a5)+,7*8(a4)   ; [20]
                move.w  (a5)+,8*8(a4)   ; [20]
                move.w  (a5)+,9*8(a4)   ; [20]
                move.w  (a5)+,10*8(a4)  ; [20]
                move.w  (a5)+,11*8(a4)  ; [20]
                move.w  (a5)+,12*8(a4)  ; [20]
                move.w  (a5)+,13*8(a4)  ; [20]
                move.w  (a5)+,14*8(a4)  ; [20]
                move.w  (a5)+,15*8(a4)  ; [20]
                move.w  (a5)+,16*8(a4)  ; [20]
                move.w  (a5)+,17*8(a4)  ; [20]
                move.w  (a5)+,18*8(a4)  ; [20]
                move.w  (a5)+,19*8(a4)  ; [20]
                move.w  (a5)+,20*8(a4)  ; [20]
                move.w  (a5)+,21*8(a4)  ; [20]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,25*8(a4)  ; [16]
                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                ds.w 1,$4e71
                move.w  (a2)+,(a6)      ; [12]

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]

                ds.w 3,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                adda.l  #52*(anz_zeilen-1),a5 ; [16]
                lea     230(a4),a4      ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                adda.l  #52*(anz_zeilen-1),a5 ; [16]
                lea     230(a4),a4      ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                adda.l  #52*(anz_zeilen-1),a5 ; [16]
                lea     230(a4),a4      ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                adda.l  #52*(anz_zeilen-1),a5 ; [16]
                lea     230(a4),a4      ; [8]

                move.w  (a5)+,(a4)      ; [12]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a2)+,(a6)      ; [12]

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]

                ds.w 1,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                adda.l  #52*(anz_zeilen-1),a5 ; [16]
                lea     230(a4),a4      ; [8]
                move.w  (a2)+,(a6)      ; [12]
                move.w  (a5)+,(a4)      ; [12]

; newline

                rept 5
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]

                ds.w 1,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                adda.l  #52*(anz_zeilen-1),a5 ; [16]
                lea     230(a4),a4      ; [8]
                move.w  (a2)+,(a6)      ; [12]
                move.w  (a5)+,(a4)      ; [12]
                endr

; newline

                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]

                ds.w 1,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]

                ds.w 1,$4e71
                move.w  (a2)+,(a6)      ; [12]

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]

                ds.w 3,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                adda.l  #52*(anz_zeilen-1),a5 ; [16]
                lea     230(a4),a4      ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                adda.l  #52*(anz_zeilen-1),a5 ; [16]
                lea     230(a4),a4      ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]

                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                adda.l  #52*(anz_zeilen-1),a5 ; [16]
                lea     230(a4),a4      ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]

                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]
                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]
                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline

                rept 6
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                adda.l  #52*(anz_zeilen-1),a5 ; [16]
                lea     230(a4),a4      ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]
                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                move.w  d3,d1           ; [4]
                move.w  (a3)+,d2        ; [8]
                lea     690(a4),a4      ; [8]

                add.w   d2,d1           ; [4]
                move.w  d1,d4           ; [4]
                and.w   #$0f,d4         ; [8]
                add.w   d4,d4           ; [4]
                add.w   d4,d4           ; [4]

                ds.w 2,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                lea     scroll_puf_tab,a5 ; [12]
                movea.l 0(a5,d4.w),a5   ; [20]

                and.w   #$fff0,d1       ; [8]
                lsr.w   #3,d1           ; [12]

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                adda.w  d1,a5           ; [8]

                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]
                move.w  (a2)+,(a6)      ; [12]

; newline
                rept 6
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]

                ds.w 1,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]
                adda.l  #52*(anz_zeilen-1),a5 ; [16]

                ds.w 1,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                lea     230(a4),a4      ; [8]
                move.w  (a5)+,(a4)      ; [12]
                move.w  (a5)+,1*8(a4)   ; [16]

                move.w  (a2)+,(a6)      ; [12]
                endr

; newline

                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                move.w  (a5)+,2*8(a4)   ; [16]
                move.w  (a5)+,3*8(a4)   ; [16]
                move.w  (a5)+,4*8(a4)   ; [16]
                move.w  (a5)+,5*8(a4)   ; [16]
                move.w  (a5)+,6*8(a4)   ; [16]
                move.w  (a5)+,7*8(a4)   ; [16]
                move.w  (a5)+,8*8(a4)   ; [16]
                move.w  (a5)+,9*8(a4)   ; [16]
                move.w  (a5)+,10*8(a4)  ; [16]
                move.w  (a5)+,11*8(a4)  ; [16]
                move.w  (a5)+,12*8(a4)  ; [16]
                move.w  (a5)+,13*8(a4)  ; [16]
                move.w  (a5)+,14*8(a4)  ; [16]
                move.w  (a5)+,15*8(a4)  ; [16]
                move.w  (a5)+,16*8(a4)  ; [16]
                move.w  (a5)+,17*8(a4)  ; [16]
                move.w  (a5)+,18*8(a4)  ; [16]
                move.w  (a5)+,19*8(a4)  ; [16]
                move.w  (a5)+,20*8(a4)  ; [16]
                move.w  (a5)+,21*8(a4)  ; [16]
                move.w  (a5)+,22*8(a4)  ; [16]
                move.w  (a5)+,23*8(a4)  ; [16]

                ds.w 1,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                move.w  (a5)+,24*8(a4)  ; [16]
                move.w  (a5)+,25*8(a4)  ; [16]

                ds.w 5,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                ds.w 8,$4e71
                move.w  (a2)+,(a6)      ; [12]

; newline

                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                ds.w 89,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                ds.w 13,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                ds.w 8,$4e71
                move.w  (a2)+,(a6)      ; [12]



****************************************************************************
;--- nÑchste 'Ein-zeile-Sync-Rout' wird gebraucht, um richtig 'Lower-Border'
;--- Routine aufzurufen !!!
****************************************************************************
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                ds.w 89,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                ds.w 9,$4e71    ; 9 wenn st_type, 10 wenn st_type(pc)

                move.w  st_type,d1      ; [12] schonmal D1 mit Bitnummer laden

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

; hier wÑren bis noch 12*4 = 48 Zyklen frei, also diese gleich NICHT
; ignorieren !!!

                cmpi.w  #1,d1           ; [8] wenn 0 dann 229'Zeilen Rout holen
                beq     st_213          ; [12] immer!!! (0=229 Zeilen geîffnet)

******************************************************************************
**************     229'ER ST VERSION BORDER ROUTINE         ******************
******************************************************************************

st_229:         ds.w 7-3,$4e71  ; noch ein kleiner Rest von oben !!!
                move.w  (a2)+,(a6)      ; [12]

                rept 16         ; bei 229'er ST's 16 Zeilen mehr oberer Rand
                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                ds.w 89,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                ds.w 13,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                ds.w 12-3,$4e71
                move.w  (a2)+,(a6)      ; [12]
                endr


;---- unteren Rand nun mit îffnen !!! (braucht 2 Synclines !!!)

                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                ds.w 89,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                ds.w 10,$4e71

                move.w  d0,(a0)         ; [8]  Unterer Rand I
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                ds.w 11-3,$4e71
                move.w  (a2)+,(a6)      ; [12]

;---- nÑchste 'mit-lower-border' Zeile '29

                move.w  a1,(a1)         ; [8]  Linker Rand I
                move.w  a0,(a0)         ; [8]  Unterer Rand II
                move.b  d0,(a1)         ; [8]

                ds.w 89,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                ds.w 13,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                ds.w 11-3,$4e71
                move.w  (a2)+,(a6)      ; [12]


; unterer Rand nun auch weg, es geht normal (?) weiter !!!!

                rept 34-1-1
                nop

                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                ds.w 89,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                ds.w 13,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                ds.w 11-3,$4e71
                move.w  (a2)+,(a6)      ; [12]
                endr
                jmp     leave_fullscreen(pc)




******************************************************************************
**************     213'ER ST VERSION BORDER ROUTINE         ******************
******************************************************************************

st_213:         ds.w 7-3,$4e71
                move.w  (a2)+,(a6)      ; [12]

;--- nun unteren Rand auf 213'er îffnen (wieder 2 Synclines gebraucht !!!)

                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                ds.w 89,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                ds.w 10,$4e71

                move.w  d0,(a0)         ; [8]  Unterer Rand I
                nop
                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                ds.w 11-3,$4e71
                move.w  (a2)+,(a6)      ; [12]


; nÑchste Zeile '13

                move.w  a1,(a1)         ; [8]  Linker Rand I
                move.w  a0,(a0)         ; [8]  Unterer Rand II
                move.b  d0,(a1)         ; [8]

                ds.w 89,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                ds.w 13,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                ds.w 11-3,$4e71
                move.w  (a2)+,(a6)      ; [12]


; unterer Rand auch hier nun weg, es geht normal weiter...

                rept 34+16-1-1
                nop

                move.w  a1,(a1)         ; [8]  Linker Rand I
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                ds.w 89,$4e71

                move.b  d0,(a0)         ; [8]  Rechter Rand
                move.w  a0,(a0)         ; [8]

                ds.w 13,$4e71

                move.w  a1,(a1)         ; [8]  Linker Rand II
                nop                     ; [4]
                move.b  d0,(a1)         ; [8]

                ds.w 11-3,$4e71
                move.w  (a2)+,(a6)      ; [12]
                endr

leave_fullscreen:
                jsr     sprite_routine2
                jsr     sound+8(pc)

                move.w  #$2300,(sp)     ; SR setzen
                rte

;------------------------------------------------------------------------------

init_logo:      move.w  #lines*weight/4-1,d0 ;erster Block muû nicht rotiert werden
                lea     logo_puffer,a1
                lea     logo(pc),a0
copy_1st_logo:  move.l  (a0)+,(a1)+
                dbra    d0,copy_1st_logo

                move.w  #14,d0
                moveq   #0,d3
shift_next_logo:moveq   #0,d1
next_plane:     lea     logo(pc),a0
                lea     0(a0,d1.w),a0
                move.w  #lines-1,d2
shift_logo:     move    #0,ccr

                roxr.w  0*8(a0)         ; this one isn't universell but
                roxr.w  1*8(a0)         ; better
                roxr.w  2*8(a0)         ; "
                roxr.w  3*8(a0)         ; "
                roxr.w  4*8(a0)         ; "
                roxr.w  5*8(a0)         ; "
                roxr.w  6*8(a0)         ; "
                roxr.w  7*8(a0)         ; "
                roxr.w  8*8(a0)         ; "
                roxr.w  9*8(a0)         ; "
                roxr.w  10*8(a0)        ; "
                roxr.w  11*8(a0)        ; "
                roxr.w  12*8(a0)        ; "
                roxr.w  13*8(a0)        ; "
                roxr.w  14*8(a0)        ; "
                roxr.w  15*8(a0)        ; "
                roxr.w  16*8(a0)        ; "
                roxr.w  17*8(a0)        ; "
                roxr.w  18*8(a0)        ; "
                lea     weight(a0),a0   ; "

                dbra    d2,shift_logo
                addq.w  #2,d1
                cmpi.w  #8,d1           ; 4 Bitplanes schon erreicht ???
                bne.s   next_plane

                lea     logo_puffer,a1
                addq.w  #1,d3           ; OffsetzÑhler fÅr Logopuffer
                move.w  d3,d4
                mulu    #weight*lines,d4
                adda.l  d4,a1           ; hier nÑchstes Logo hinkopieren

                lea     logo(pc),a0
                move.w  #lines*weight/4-1,d1
copy_logo:      move.l  (a0)+,(a1)+
                dbra    d1,copy_logo
                dbra    d0,shift_next_logo
                rts

*********************

copy_distorter: clr.w   line_counter
                suba.l  a5,a5
                movea.l dist_pointer,a0
                move.w  (a0)+,d0
                cmpi.w  #-1,(a0)
                bne.s   alles_klar
                lea     dist_tab,a0
alles_klar:     move.l  a0,dist_pointer
                movea.l a0,a6           ; A6 bleibt Zeiger auf X Positionen
                cmpi.w  #0,(a6)
                move.w  d0,d1
                and.w   #$f0,d0
                lsr.w   #1,d0           ; screenadresse
                movea.l screen,a1
                adda.l  #logo_pos,a1

                move.l  a1,save_dist_pos
                adda.w  d0,a1           ; neue Position

                and.w   #$0f,d1
                ext.l   d1
                add.l   d1,d1
                add.l   d1,d1
                lea     logo_puffer_offsets,a0
                movea.l 0(a0,d1.l),a0

                movem.l (a0),d1-d6/a2-a3
                movem.l d1-d6/a2-a3,(a1)
                movem.l 32(a0),d1-d6/a2-a3
                movem.l d1-d6/a2-a3,32(a1)
                movem.l 64(a0),d1-d6/a2-a3
                movem.l d1-d6/a2-a3,64(a1)
                movem.l 96(a0),d1-d6/a2-a3
                movem.l d1-d6/a2-a3,96(a1)
                movem.l 128(a0),d1-d6
                movem.l d1-d6,128(a1)

*                move.l  #0,weight(a1)
*                move.l  #0,weight+4(a1)

                move.w  #lines-2,d7
next_line:      addi.w  #160,line_counter
get_x:          move.w  (a6)+,d0        ; neue Position
                cmpi.w  #-1,d0
                beq.s   get_x
                move.w  d0,d1
                and.w   #$f0,d0
                lsr.w   #1,d0
                movea.l save_dist_pos,a1
                adda.w  line_counter,a1
                adda.w  d0,a1
                and.w   #$0f,d1
                ext.l   d1
                add.l   d1,d1
                add.l   d1,d1
                lea     logo_puffer_offsets,a0
                movea.l 0(a0,d1.l),a0
                adda.l  a5,a0           ; A0 neue data position

                movem.l (a0),d1-d6/a2-a3
                movem.l d1-d6/a2-a3,(a1)
                movem.l 32(a0),d1-d6/a2-a3
                movem.l d1-d6/a2-a3,32(a1)
                movem.l 64(a0),d1-d6/a2-a3
                movem.l d1-d6/a2-a3,64(a1)
                movem.l 96(a0),d1-d6/a2-a3
                movem.l d1-d6/a2-a3,96(a1)
                movem.l 128(a0),d1-d6
                movem.l d1-d6,128(a1)

*                move.l  #0,weight(a1)
*                move.l  #0,weight+4(a1)

                lea     weight(a5),a5
                dbra    d7,next_line

                movea.l save_dist_pos,a1
                adda.w  line_counter,a1
                lea     160(a1),a1

                rts
;--------------------------------------------------------------------------


                path 'E:ANAL_EXS.SRC\'
chars:          ibytes 'CHARSET.DAT'
                even
sound:          ibytes 'SALLY.MUS'
                even
logo:           ibytes 'LOGO.DAT'
                even



scroll_screen:  dc.l 0
real_screen:    dc.l 0
txt_pntr:       dc.l scroll_text
x_dist_pntr:    dc.l x_dist

scroll_puf_tab: dc.l scroll_puf+anz_zeilen*52*7*15
                dc.l scroll_puf+anz_zeilen*52*7*14
                dc.l scroll_puf+anz_zeilen*52*7*13
                dc.l scroll_puf+anz_zeilen*52*7*12
                dc.l scroll_puf+anz_zeilen*52*7*11
                dc.l scroll_puf+anz_zeilen*52*7*10
                dc.l scroll_puf+anz_zeilen*52*7*9
                dc.l scroll_puf+anz_zeilen*52*7*8
                dc.l scroll_puf+anz_zeilen*52*7*7
                dc.l scroll_puf+anz_zeilen*52*7*6
                dc.l scroll_puf+anz_zeilen*52*7*5
                dc.l scroll_puf+anz_zeilen*52*7*4
                dc.l scroll_puf+anz_zeilen*52*7*3
                dc.l scroll_puf+anz_zeilen*52*7*2
                dc.l scroll_puf+anz_zeilen*52*7*1
                dc.l scroll_puf+anz_zeilen*52*7*0

font_tab:
char_tab:       dc.l chars+160*14+8*10
                dc.l chars+160*7+8*17
                dc.l chars+160*14+8*4
                dc.l chars+160*14+8*10
                dc.l chars+160*14+8*10
                dc.l chars+160*14+8*10
                dc.l chars+160*14+8*10
                dc.l chars+160*14+8*10
                dc.l chars+160*14+8*0
                dc.l chars+160*14+8*1
                dc.l chars+160*7+8*18
                dc.l chars+160*14+8*6
                dc.l chars+160*7+8*19
                dc.l chars+160*14+8*3
                dc.l chars+160*7+8*16
                dc.l chars+160*14+8*5
                dc.l chars+160*7+8*15
                dc.l chars+160*7+8*6
                dc.l chars+160*7+8*7
                dc.l chars+160*7+8*8
                dc.l chars+160*7+8*9
                dc.l chars+160*7+8*10
                dc.l chars+160*7+8*11
                dc.l chars+160*7+8*12
                dc.l chars+160*7+8*13
                dc.l chars+160*7+8*14
                dc.l chars+160*14+8*10
                dc.l chars+160*14+8*10
                dc.l chars+160*14+8*8
                dc.l chars+160*14+8*10
                dc.l chars+160*14+8*7
                dc.l chars+160*14+8*2
                dc.l chars+160*14+8*10
                dc.l chars+8*0
                dc.l chars+8*1
                dc.l chars+8*2
                dc.l chars+8*3
                dc.l chars+8*4
                dc.l chars+8*5
                dc.l chars+8*6
                dc.l chars+8*7
                dc.l chars+8*8
                dc.l chars+8*9
                dc.l chars+8*10
                dc.l chars+8*11
                dc.l chars+8*12
                dc.l chars+8*13
                dc.l chars+8*14
                dc.l chars+8*15
                dc.l chars+8*16
                dc.l chars+8*17
                dc.l chars+8*18
                dc.l chars+8*19
                dc.l chars+160*7+8*0
                dc.l chars+160*7+8*1
                dc.l chars+160*7+8*2
                dc.l chars+160*7+8*3
                dc.l chars+160*7+8*4
                dc.l chars+160*7+8*5


palette:        dc.w $00,$00,$0444,$0444,$0777,$0777
                ds.w 10,$0444

ras_count:      dc.w 1000
st_type:        dc.w 0
hbl_count:      dc.w -1
x_pos:          dc.w 0

x_dist:         dc.w 1,1,1,1,1,2,2,2,2,3,3,3,4,4,5
                dc.w 6,7,8,9,10
                dc.w 12,14,16,18,20
                dc.w 23,26,29,32
                dc.w 36,40
                dc.w 42,44,46,48,50
                dc.w 51,52,53,54,55
                dc.w 56,56,57,57,57,58,58,58,58,59,59,59,59,59,60,60,60,60,60,60
                dc.w 59,59,59,59,59,58,58,58,58,57,57,57,56,56
                dc.w 55,54,53,52,51,50
                dc.w 48,46,44,42,40,36
                dc.w 32,29,26,23
                dc.w 20,18,16,14,12
                dc.w 10,9,8,7,6,5
                dc.w 4,4,3,3,3,2,2,2,2,1,1,1,1,1,0
                dc.w 1,1,1,1,1,2,2,2,2,3,3,3,4,4,5
                dc.w 6,7,8,9,10
                dc.w 12,14,16,18,20
                dc.w 23,26,29,32
                dc.w 36,40
                dc.w 42,44,46,48,50
                dc.w 51,52,53,54,55
                dc.w 56,56,57,57,57,58,58,58,58,59,59,59,59,59,60,60,60,60,60,60
                dc.w 59,59,59,59,59,58,58,58,58,57,57,57,56,56
                dc.w 55,54,53,52,51,50
                dc.w 48,46,44,42,40,36
                dc.w 32,29,26,23
                dc.w 20,18,16,14,12
                dc.w 10,9,8,7,6,5
                dc.w 4,4,3,3,3,2,2,2,2,1,1,1,1,1


y_tab:          dc.l 0,0,0,0,1,1,1,2,2,3,4,5,6,7,8,9,10
                dc.l 12,14,16,18,20,22,24,26,28,30
                dc.l 33,36,39,42,45,48,51,54,57,60
                dc.l 64,68,72,76,80,84,88,92,96,100
                dc.l 105,110,115,120
                dc.l 125,130,135,140
                dc.l 144,148,152,156,160,164,168,172,176,180
                dc.l 183,186,189,192,195,198,201,204,207,210
                dc.l 212,214,216,218,220,222,224,226,228,230
                dc.l 231,232,233,234,235,236,237,238,238,239,239,239
                dc.l 240,240,240,240
y_tab2:         dc.l 239,239,239,238,238,237,236,235,234,233,232,231,230
                dc.l 228,226,224,222,220,218,216,214,212,210
                dc.l 207,204,201,198,195,192,189,186,183,180
                dc.l 176,172,168,164,160,156,152,148,144,140
                dc.l 135,130,125,120,115,110,105,100
                dc.l 96,92,88,84,80,76,72,68,64,60
                dc.l 57,54,51,48,45,42,39,36,33,30
                dc.l 28,26,24,22,20,18,16,14,12,10
                dc.l 9,8,7,6,5,4,3,2,2,1,1,1,-1


x_tab:          dc.w 5,5,5,5,5,6,6,6,6,7,7,7,8,8
                dc.w 9,10,11,12,13,14,15,16,17,18,19,20
                dc.w 22,24,26,28,30,32,34,36,38,40,42,44,46,48,50
                dc.w 53,56,59,62,65,68,71,74,77,80
                dc.w 83,86,89,92,95,98,101,104,107
                dc.w 111,116,120,124,128,132,136,140,144,148,152
                dc.w 156,160
                dc.w 165,170,175,180,185,190,195,200,205,210,215
                dc.w 220,225,230,235,240,245,250,255,260,265,270
                dc.w 274,278,282,286,290,294,298,302,306,310,314,318
                dc.w 321,324,327,330,333,336,339,342,345,348,351,354
                dc.w 357,360,363,367,370,373,376,379
x_tab2:         dc.w 383,381,379,376,373,370,367,363,360,357,354,351,348,345
                dc.w 342,339,336,333,330,327,324,321,318,314,310,306,302,298
                dc.w 294,290,286,282,278,274,270,265,260,255,250,245,240,235
                dc.w 230,225,220,215,210,205,200,195,190,185,180,175,170,165
                dc.w 160,156,152,148,144,140,136,132,128,124,120,116,111
                dc.w 107,104,101,98,95,92,89,86,83,80,77,74,71,68,65,62,59,56,53
                dc.w 50,48,46,44,42,40,38,36,34,32,30,28,26,24,22,20
                dc.w 19,18,17,16,15,14,13,12,11,10,9,8,8,7,7,7,6,6,6,6
                dc.w 5,5,5,5,5,-1

x_pointer_x:    dc.l x_tab
y_pointer_x:    dc.l y_tab
x_pointer_a:    dc.l x_tab+2*4
y_pointer_a:    dc.l y_tab+4
x_pointer_t:    dc.l x_tab+4*4
y_pointer_t:    dc.l y_tab+8
x_pointer_s:    dc.l x_tab+6*4
y_pointer_s:    dc.l y_tab+12

x_pointer_t3:   dc.l x_tab2
y_pointer_t3:   dc.l y_tab2
x_pointer_t2:   dc.l x_tab2+2*4
y_pointer_t2:   dc.l y_tab2+4
x_pointer_a2:   dc.l x_tab2+4*4
y_pointer_a2:   dc.l y_tab2+8
x_pointer_m:    dc.l x_tab2+6*4
y_pointer_m:    dc.l y_tab2+12

nop_count:      dc.w 0
nop_data:       rept 100
                dc.w 0,0,0,2,2,2,2,4,4,4,6,6,8,10
                dc.w 10,12,12,12,14,14,14,14,16,16,16,16,16
                dc.w 14,14,14,14,12,12,12,10,10,8,6,6,4,4,4,2,2,2,2,0,0
                endr

plasma_dist:    rept 20
                dc.w 0,0,0,0,2,2,2,4,4,6,8,8,10,10,10,12,12,12,12
                dc.w 10,10,10,8,8,6,4,4,2,2,2
                endr

scroll_pal:     dc.w $17,$26,$35,$44,$54,$63,$72
                ds.w 30

ras_pal:        ds.w 10
                dc.w $0100,$0100,$0200,$0200,$0300,$0300,$0400,$0400,$0500,$0500,$0600,$0600,$0700,$0700
                dc.w $0600,$0600,$0500,$0500,$0400,$0400,$0300,$0300,$0200,$0200,$0100,$0100
                ds.w 10
                dc.w $10,$10,$20,$20,$30,$30,$40,$40,$50,$50,$60,$60,$70,$70
                dc.w $60,$60,$50,$50,$40,$40,$30,$30,$20,$20,$10,$10
                ds.w 10
                dc.w $0110,$0110,$0220,$0220,$0330,$0330,$0440,$0440,$0550,$0550,$0660,$0660,$0770,$0770
                dc.w $0660,$0660,$0550,$0550,$0440,$0440,$0330,$0330,$0220,$0220,$0110,$0110
                ds.w 100


palette2:       dc.w $0100,$0101,$0201,$0202,$0302,$0303,$0403,$0404,$0504,$0505,$0605
                dc.w $0606,$0706,$0707,$0607,$0507,$0407,$0307,$0207,$0107,$07
                dc.w 6,5,4,3,2,1
                ds.w 10
palette1:       dc.w $10,$11,$0210,$22,$32,$33,$43,$44,$54,$55
                dc.w $65,$66,$76,$77,$67,$66,$56,$55,$45,$44,$34,$33,$23,$22
                dc.w $11,$01
                ds.w 20
palette3:       dc.w $0100,$0110,$0210,$0220,$0320,$0330,$0430,$0440,$0540,$0550,$0650,$0660
                dc.w $0760,$0770,$0670,$0660,$0560,$0550,$0450,$0440,$0340,$0330,$0230,$0220,$0120,$0110,$10
                ds.w 20
palette4:       dc.w $10,$20,$30,$40,$50,$60,$70
                dc.w $0160,$0250,$0340,$0430,$0520,$0610,$0700
                dc.w $0601,$0502,$0403,$0304,$0205,$0106,$07
                dc.w 6,5,4,3,2,1
                ds.w 20
palette5:       dc.w $0100,$0200,$0300,$0400,$0500,$0600,$0700
                dc.w $0710,$0720,$0730,$0740,$0750,$0760,$0770
                dc.w $0670,$0570,$0470,$0370,$0270,$0170,$70
                dc.w $06,$05,$04,$03,$02,$01
                ds.w 20
palette0:       dc.w 1,2,3,4,5,6,7
                dc.w $17,$27,$37,$47,$57,$67,$77
                dc.w $0177,$0277,$0377,$0477,$0577,$0677,$0777
                dc.w $0666,$0555,$0444,$0333,$0222,$0111
                ds.w 20

raster_pal:     ds.w 3          ; weil Scroller beginnt erst ab der 4 Zeile
                rept 10
                dc.w $0101,$00,$0101,$0101,$0202,$0101,$0202,$0202,$0303,$0202,$0303,$0303,$0404
                dc.w $0303,$0404,$0404,$0404,$0505,$0404,$0505,$0505,$0606,$0505,$0606,$0606,$0707
                dc.w $0606,$0707,$0707,$0716,$0707,$0716,$0716,$0725,$0716,$0725,$0725,$0734,$0725
                dc.w $0734,$0734,$0743,$0734,$0743,$0743,$0752,$0743,$0752,$0752,$0761,$0752,$0761
                dc.w $0761,$0770,$0761,$0770,$0770,$0760,$0770,$0760,$0760,$0750,$0760,$0750,$0750
                dc.w $0740,$0750,$0740,$0740,$0730,$0740,$0730,$0730,$0720,$0730,$0720,$0720,$0710
                dc.w $0720,$0710,$0710,$0700,$0710,$0700,$0700,$0701,$0700,$0701,$0701,$0702,$0701
                dc.w $0702,$0702,$0703,$0702,$0703,$0703,$0704,$0703,$0704,$0704,$0705,$0704,$0705
                dc.w $0705,$0706,$0706,$0707,$0706,$0707,$0707,$0607,$0707,$0607,$0607,$0507,$0607
                dc.w $0507,$0507,$0407,$0507,$0407,$0407,$0307,$0407,$0307,$0307,$0207,$0307,$0207
                dc.w $0207,$0107,$0207,$0107,$0107,$07,$0107,$07,$07,$06,$07,$06,$06
                dc.w $05,$06,$05,$05,$04,$05,$04,$04,$03,$04,$03,$03,$02
                dc.w $03,$02,$02,$01,$02,$01,$01,$00,$01
                dc.w $00,$01,$00,$01,$01,$01,$01,$01,$02,$01,$02
                dc.w $02,$02,$02,$02,$03,$02,$03,$03,$03,$03,$03,$04
                dc.w $03,$04,$04,$04,$04,$04,$05,$04,$05,$05,$05
                dc.w $05,$05,$06,$05,$06,$06,$06,$06,$06,$0116,$06
                dc.w $0116,$0116,$0116,$0116,$0116,$0226,$0116,$0226,$0226,$0226,$0226,$0226
                dc.w $0336,$0226,$0336,$0336,$0336,$0336,$0336,$0446,$0336,$0446,$0446
                dc.w $0446,$0446,$0446,$0556,$0446,$0556,$0556,$0556,$0556,$0556,$0666
                dc.w $0556,$0666,$0666,$0666,$0666,$0666,$0776,$0666,$0776,$0776,$0776,$0776
                dc.w $0776,$0775,$0776,$0775,$0775,$0775,$0775,$0775,$0774,$0775,$0774
                dc.w $0774,$0774,$0774,$0774,$0773,$0774,$0773,$0773,$0773,$0773,$0773,$0772
                dc.w $0773,$0772,$0772,$0772,$0772,$0772,$0771,$0772,$0771,$0771,$0771
                dc.w $0771,$0771,$0770,$0771,$0770,$0770,$0770,$0770,$0770,$0750,$0770
                dc.w $0750,$0750,$0750,$0750,$0750,$0740,$0750,$0740,$0740,$0740,$0740,$0740
                dc.w $0630,$0740,$0630,$0630,$0630,$0630,$0630,$0520,$0630,$0520,$0520
                dc.w $0520,$0520,$0520,$0410,$0520,$0410,$0410,$0410,$0410,$0410,$0300
                dc.w $0410,$0300,$0300,$0300,$0300,$0300,$0200,$0300,$0200,$0100
                endr

mask_s:         dc.w $0fff,$1ffe,$3ffc,$7e00,$ffff,$7fff,$3fff,$07
                dc.w $3fff,$7ffe,$fffc

mask_t:         dc.w $3ffc,$7ffe,$ffff,$ffff,$e3c7,$c3c3,$83c1,$03c0
                dc.w $03c0,$03c0,$03c0

mask_a:         dc.w $07e0,$0ff0,$1ff8,$3ffc,$781e,$f81f,$ffff,$ffff
                dc.w $ffff,$e007,$e007

mask_x:         dc.w $f83f,$fc7e,$7efc,$3ff8,$1ff0,$0ff0,$1ff8,$3e7c
                dc.w $7c3e,$f81f,$f00f

mask_m:         dc.w $e007,$f00f,$f81f,$fc3f,$fe7f,$ffff,$f7ef,$f3cf
                dc.w $f18f,$f00f,$f00f

sprite_s:       dc.w $0fff,$00,$00,$00,$1ffe,$00,$00,$00
                dc.w $3ffc,$00,$00,$00,$7e00,$00,$00,$00
                dc.w $ffff,$00,$00,$00,$7fff,$00,$00,$00
                dc.w $3fff,$00,$00,$00,$07,$00,$00,$00
                dc.w $3fff,$00,$00,$00,$7ffe,$00,$00,$00
                dc.w $fffc,$00,$00,$00

sprite_t:       dc.w $3ffc,$00,$00,$00,$7ffe,$00,$00,$00
                dc.w $ffff,$00,$00,$00,$ffff,$00,$00,$00
                dc.w $e3c7,$00,$00,$00,$c3c3,$00,$00,$00
                dc.w $83c1,$00,$00,$00,$03c0,$00,$00,$00
                dc.w $03c0,$00,$00,$00,$03c0,$00,$00,$00
                dc.w $03c0,$00,$00,$00

sprite_a:       dc.w $07e0,$00,$00,$00,$0ff0,$00,$00,$00
                dc.w $1ff8,$00,$00,$00,$3ffc,$00,$00,$00
                dc.w $781e,$00,$00,$00,$f81f,$00,$00,$00
                dc.w $ffff,$00,$00,$00,$ffff,$00,$00,$00
                dc.w $ffff,$00,$00,$00,$e007,$00,$00,$00
                dc.w $e007,$00,$00,$00

sprite_x:       dc.w $f83f,$00,$00,$00,$fc7e,$00,$00,$00
                dc.w $7efc,$00,$00,$00,$3ff8,$00,$00,$00
                dc.w $1ff0,$00,$00,$00,$0ff0,$00,$00,$00
                dc.w $1ff8,$00,$00,$00,$3e7c,$00,$00,$00
                dc.w $7c3e,$00,$00,$00,$f81f,$00,$00,$00
                dc.w $f00f,$00,$00,$00

sprite_m:       dc.w $e007,$00,$00,$00,$f00f,$00,$00,$00
                dc.w $f81f,$00,$00,$00,$fc3f,$00,$00,$00
                dc.w $fe7f,$00,$00,$00,$ffff,$00,$00,$00
                dc.w $f7ef,$00,$00,$00,$f3cf,$00,$00,$00
                dc.w $f18f,$00,$00,$00,$f00f,$00,$00,$00
                dc.w $f00f,$00,$00,$00

palettestax:    dc.w $00,$0210,$0321,$0432,$0442,$0552,$0663,$0773
                dc.w $0775,$0776,$0777,$70,$70,$70,$70,$0777


dist_pointer:   dc.l dist_tab
dist_tab:
                rept 300
                dc.w 96
                endr
                dc.w 94,92,90,88,86,84,82,80
                rept 1
                dc.w 80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110
                dc.w 112,110,108,106,104,102,100,98,96,94,92,90,88,86,84,82,80
                endr
                rept 2
                dc.w 80,80,80,81,81,82,83,84,85,87,89,91,94,97,100
                dc.w 102,104,106,107,108,109,110,111,111,112,112,112
                dc.w 111,111,110,109,108,107,106,104,102,100,97,94,91,89,87,85,84,83,82
                dc.w 81,81
                endr
                rept 3
                dc.w 80,80,81,82,84,86,89,93,98,102,105,108,110,112,114,115,116
                dc.w 117,117,116,115,114,112,110,108,105,102,98,93,89,86,84,82,81
                endr
                rept 1
                dc.w 80,80,80,80,81,81,82,82,84,84,86,86,88,88,90,90,92,92
                dc.w 94,94,96,96,98,98,100,100,102,102,104,104,106,106,108,108
                dc.w 110,110,112,112,114,114,116,116,118,118,118,118,116,116
                dc.w 114,114,112,112,110,110,108,108,106,106,104,104,102,102
                dc.w 100,100,98,98,96,96,94,94,92,92,90,90,88,88,86,86,84,84,82,82
                endr
                rept 1
                dc.w 80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110
                dc.w 112,110,108,106,104,102,100,98,96,94,92,90,88,86,84,82,80
                endr
                rept 5
                dc.w 80,80,81,82,84,87,91,96,101,105,108,111,113,115,116,117,118,118
                dc.w 117,116,115,113,111,108,105,101,96,91,87,84,82,81
                endr
                rept 2
                dc.w 80,80,81,82,84,86,89,93,98,102,105,108,110,112,114,115,116
                dc.w 117,117,116,115,114,112,110,108,105,102,98,93,89,86,84,82,81
                endr
                rept 2
                dc.w 80,80,81,82,84,87,91,96,101,105,108,111,113,115,116,117,118,118
                dc.w 117,116,115,113,111,108,105,101,96,91,87,84,82,81
                endr
                rept 3
                dc.w 80,80,80,81,81,82,83,84,85,87,89,91,94,97,100
                dc.w 102,104,106,107,108,109,110,111,111,112,112,112
                dc.w 111,111,110,109,108,107,106,104,102,100,97,94,91,89,87,85,84,83,82
                dc.w 81,81
                endr
                rept 4
                dc.w 80,80,81,82,84,86,89,93,98,102,105,108,110,112,114,115,116
                dc.w 117,117,116,115,114,112,110,108,105,102,98,93,89,86,84,82,81
                endr
                rept 10
                dc.w 80,80,81,82,84,87,91,96,101,105,108,111,113,115,116,117,118,118
                dc.w 117,116,115,113,111,108,105,101,96,91,87,84,82,81
                endr
                rept 150
                dc.w 96
                endr
                dc.w 94,91,89,87,85,84,83,82
                dc.w 81,81
                rept 2
                dc.w 80,80,80,81,81,82,83,84,85,87,89,91,94,97,100
                dc.w 102,104,106,107,108,109,110,111,111,112,112,112
                dc.w 111,111,110,109,108,107,106,104,102,100,97,94,91,89,87,85,84,83,82
                dc.w 81,81
                endr
                rept 2
                dc.w 80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110
                dc.w 112,110,108,106,104,102,100,98,96,94,92,90,88,86,84,82,80
                endr
                rept 2
                dc.w 80,80,80,80,81,81,82,82,84,84,86,86,88,88,90,90,92,92
                dc.w 94,94,96,96,98,98,100,100,102,102,104,104,106,106,108,108
                dc.w 110,110,112,112,114,114,116,116,118,118,118,118,116,116
                dc.w 114,114,112,112,110,110,108,108,106,106,104,104,102,102
                dc.w 100,100,98,98,96,96,94,94,92,92,90,90,88,88,86,86,84,84,82,82
                endr
                rept 7
                dc.w 80,80,81,82,84,87,91,96,101,105,108,111,113,115,116,117,118,118
                dc.w 117,116,115,113,111,108,105,101,96,91,87,84,82,81
                endr
                dc.w 80,80,80,81,81,82,83,84,85,87,89,91,94
                dc.w -1
                rept 100
                dc.w 96
                endr

pal_pntr:       dc.l palette0
pal_tab:        rept 2
                dc.l palette0,palette1,palette2,palette3,palette4,palette5
                endr

logo_puffer_offsets:
                dc.l logo_puffer+lines*weight*0
                dc.l logo_puffer+lines*weight*1
                dc.l logo_puffer+lines*weight*2
                dc.l logo_puffer+lines*weight*3
                dc.l logo_puffer+lines*weight*4
                dc.l logo_puffer+lines*weight*5
                dc.l logo_puffer+lines*weight*6
                dc.l logo_puffer+lines*weight*7
                dc.l logo_puffer+lines*weight*8
                dc.l logo_puffer+lines*weight*9
                dc.l logo_puffer+lines*weight*10
                dc.l logo_puffer+lines*weight*11
                dc.l logo_puffer+lines*weight*12
                dc.l logo_puffer+lines*weight*13
                dc.l logo_puffer+lines*weight*14
                dc.l logo_puffer+lines*weight*15

save_dist_pos:  dc.l 0
line_counter:   dc.w 0
plasma_offset:  dc.w 0
pal_count:      dc.w 2
scroll_count:   dc.w 8
ras_pntr:       dc.w 0
change_pal:     dc.w 0

text_pntr:      dc.l txt
txt:            dc.b "                                                                                        "
                dc.b "      ....... THIS ARE ANAL EXZESSE BROUGHT TO YOU BY MATT OF STAX......."
                dc.b "WELL, I MEAN THIS ARE SOME UGLY COLORS IN"
                dc.b " SOME VERY UGLY WAVES BUT PLEASE NOTE ITS MY FIRST TRY DOING THOSE COLORS SO ITS NOT TOO BAD, ISNT IT ???   "
                dc.b " ANYWAY YOU CAN STILL PRESS THE CURSOR KEYS UP AND DOWN TO GET SOME OTHER COLORS OR YOU CAN ALSO PRESS"
                dc.b " KEY 2 TO START A CHAOS SWITCH OF THE COLORS....  WITH KEY 1 YOU CAN RETURN INTO THIS MODE BY THE WAY !!!     "
                dc.b " ICH MUSS NOCH ERWAEHNEN, DASS ICH DEN NAMEN 'ANALE EXZESSE' FUER DIESEN"
                dc.b " SCREEN GEWAEHLT HABE, DA ER GENAUSO SINNLOS (WEIL TECHNISCH TOTAL UEBERHOLT) IST WIE DER"
                dc.b " GLEICHNAMIGE FILM !!!    BEVOR ES ABER RICHTIG WEITERGEHT MOECHTE ICH NOCH DIE CREDITS VERTEILEN ...   "
                dc.b " ALSO... KOT UND IDE........  ACH SCHEISSE, ICH VERGASS DIE ENGLAENDER...   WELL"
                dc.b " ENGLISH MEN, HERE ARE THE CREDITS...       CODE AND DESIGN BY MATT OF STAX, "
                dc.b " BLOODY EXCELLENT MUSIC BY SALLY OF STAX, GRAFICKEN BY SODAN OF STAX, ONE PLANE GRAFIX AND TEXTS BY MATT OF STAX."
                dc.b "      DOCH WARUM HABE ICH GERADE SODANS ANTEIL MIT 'GRAFICKEN' BEZEICHNET ???  "
                dc.b " HA, KNIFFELIG, WAS ???  NA, DAS KOMMT DAHER, DASS ICH MITE DEM TOTAL UN-COOLEM UND LANGWEILIGEM ALS AUCH KINDISCHEM"
                dc.b " AUSDRUCK 'GRAFICKEN' MEINEN PERSOENLICHEM PROTEST DARUEBER AUSDRUECKEN MOECHTE, DASS UNSER"
                dc.b " SODAN JETZT BEIM BUND IST !!!   FOR ENGLISH MEN: SODAN OF STAX IS IN THE ARMY NOW ... AND I THINK THIS IS"
                dc.b " ABSOLUTELY SHIT BECAUSE ALL THE ARMIES OF THE WORLD ARE JUST BRINGING SHIT TO US !!!   "
                dc.b " NA JA, WENN SODAN WIRKLICH EIN RICHTIGER STAXXER IST DANN WIRD ER SICH FRUEHER ODER SPAETER"
                dc.b " EIN GEWEHR NEHMEN (MIT ETWA 60000000 SCHUSS) UND ALL DIE BEKIFFTEN OFFIZIERE UND GENERAELE IN"
                dc.b " SEINER BESCHISSENEN KASERNE ABKNALLEN .......         HMM...  SODAN ... THINK ABOUT THIS !!!                   "
                dc.b " OKEY , NOW ITS THE 11.08.1993 AND I (MATT) AM SITTING IN A BIG HOUSE IN A SMALL GERMAN VILLAGE"
                dc.b " CALLED  WIRSBERG  !!!    THE REASON FOR MY APPEARANCE AT THIS PLACE IS THE STAX SUMMER CONVENTION 1993"
                dc.b " WHICH TAKES PLACE RIGHT HERE AND RIGHT IN THESE DAYS !!!    "
                dc.b " HMMM... I WILL GIVE YOU A LIST OF THE PEOPLE WHO ARE ACTUALLY"
                dc.b " SITTING AROUND ME...   QUESTOR OF INTER (A NICE GUEST AT THE PARTY)   DUX OF STAX (ACTUALLY PLAYING SUPER SPRINT WITH"
                dc.b " QUESTOR OF INTER)     MATT OF STAX (ACTUALLY WRITING THIS BULL)     TYAN OF STAX (ACTUALLY PLAYING FORGOTTEN WORLDS)"
                dc.b "    MIKE OF STAX (ACTUALLY CODING SOMETHING FOR THIS DEMO...)    APOLLO OF NPG (ACTUALLY CODING ON A FALCON)"
                dc.b "    CARNERA OF NPG (ACTUALLY SITTING NEXT TO APOLLO)    JARON OF NPG (ACTUALLY CODING ON FALCON, TOO !!!)"
                dc.b " ............................. WELL, WHAT TO WRITE ABOUT THIS PARTY...  "
                dc.b " YESTERDAY IT ALL BEGAN AND WE DIRECTLY HAD A LOT OF FUN ESPECIALLY WHEN WE CHECKED OUT SOME"
                dc.b " FUNNY SELF MADE SAMPLE VOICES ON TYANS FALCON !!!   YOU CAN HEAR SOME OF THEM IN THIS DEMO BY THE WAY... MAYBE YOU CAN IMAGINE"
                dc.b " HOW FUNNY IT IS TO CRY INTO A MICRO WHEN YOU ALREADY KNOW THAT YOUR SAMPLE WILL NEVER BE USED BECAUSE"
                dc.b " ITS JUST SENSELESS.......BUT ANYWAY VERY EXCITING !!!                                  "
                dc.b " WELL... NOW ITS SATURDAY THE 14TH OF AUGUST AND TOMORROW IT ALL WILL END... YESTERDAY"
                dc.b " WE (MIKE..DUX..QUESTOR AND ME) WERE SWIMMING AND I CAN TELL YOU THAT THESE BIG"
                dc.b " W A S S E R R U T S C H E  WHICH WE FOUNT THERE IS ONE OF THE BEST THINGS IN WIRSBERG !!!   "
                dc.b " IN THE NIGHT THEN WE (ONLY A FEW OF US) WENT TO A BIG GLAMOUR DISCO... YOU KNOW SOMETHING"
                dc.b " WERE THEY ONLY PLAY TECHNO..HIP HOP AND THE CHART BREAKERS !!! "
                dc.b " BUT IT WAS ANYWAY VERY VERY WONDERFUL BECAUSE MIKE AND ME GAVE US THE KELLE AND THEREFORE WE"
                dc.b " THEN HAD A LOT OF FUN LOOKING AT LOADSA PEOPLE ....  MOREOVER I HAD A VERY NICE TALK WITH TARZAN BOY IN THAT"
                dc.b " DISCO AND IN THE END I COULD PERSUADE HIM TO JOIN US !!!   YO, GREAT EH !! "
                dc.b " BUT NOW I SAY GOOD BYE ENGLISH AND LETS TALK SERIOUS... I MEAN LETS TALK GERMAN ...  ABER"
                dc.b " HOCHDEUTSCH UND NICHT BAYRISCH WIE... ICH BIN JETZT BELEIDIGT WEIL QUESTOR MIR MEIN"
                dc.b " BUCH NICHT GEBEN WOLLTE !!!      COOOOOOOOL!!!!   HE...     HEHEHEHHWHAHEHHE ALLES GELOGEN...  "
                dc.b "   DAS KANN JA MAL PASSIEREN !!!     .............  MACHT JA NICHTS. QUESTOR !!!!    "
                dc.b " QUESTOR LACHT !!! HAOAOOAHOHAOHOAHOHO........      TYAN SCHMUNZELT...HDHZZEZZH!!!!      "
                dc.b " MATT IS MATT AND MAD IS MATT AUCH !!!   APOLLO SPIELT EIN SPIEL !!!   HMMM....  WIE MAG ES WOHL HEISSEN !!!  "
                dc.b " VIELLEICHT...   O I D S  !!....     JAAAAAAAA!!!!!            ICH WEISS JETZT SICHER DIE VERGANGENHEIT VON..  TO FIND !! "
                dc.b " ES IST...   FOUND !!!  WOW !!!      "
                dc.b " SO GENUG JETZT...  KEINE LUST MEHR AUF MEHR TEXT....      SEE YA ... LATER !!!                    "
                dc.b "                                                     "
                dc.b -1
                even

scroll_text:    dc.b "                                                    "
                dc.b "                                                    "
                dc.b "HI THERE!!! THIS IS MATT PRESENTING YOU SOME DRUNKEN"
                dc.b " RASTERS WHICH YOU ARE GOING TO SEE AS SOON AS YOU W"
                dc.b "ILL SMASH SPACE... FOR SOME PARTY SCROLLTEXT AND THE"
                dc.b " CREDITS AND MAYBE SOME MORE CRAP READ THE NEXT COMI"
                dc.b "NG SCROLLER... THIS ONE IS JUST THE PRESENTATION AND"
                dc.b " IS FILLED WITH MOSTLY REGARDS AND KISSES...        "
                dc.b "MEGA GREETINGS TO SOME LOCAL  GUYS...  HI ALE,KLEVER"
                dc.b ",SASCHA,GUIDO AND THE REST OF THE MALLORCA-TEAM,INGO"
                dc.b ",STAPPE,RANDOLPH,POLLO,BOLLA-RECH AND OF COURSE HELL"
                dc.b "O TO MARINA WHO MADE MY MALLORCA HOLIDAYS SO WONDERF"
                dc.b "UL...       MEGA PLATINUM GREETS TO MY FAVE BANDS,WH"
                dc.b "O ARE...    FAITH NO MORE,RAGE AGAINST THE MACHINE,C"
                dc.b "LAWFINGER,PEARL JAM,NIRVANA,RED HOT CHILI PEPPERS,PR"
                dc.b "O PAIN,RUMBLE MILITIA,MEGADETH,SOD,DREAM THEATER AND"
                dc.b ",OF COURSE, THE ORGANISATION (DEATH ANGEL).....     "
                dc.b "FUCK YOU POSERS GUNS N ROSES AND BON JOVI !!! PRESS "
                dc.b "SPACE NOW.....                                      "
                dc.b "                                                    "
                dc.b "                                                    "
                dc.b "                                                    "
                dc.b "                                                    "
                dc.b "                                                    "
                dc.b "                                                    "
                dc.b "                                                    "
                dc.b "                                                    "
                dc.b "                                                    "
                dc.b "                                                    "
                dc.b "                                                    "
                dc.b "                                                    "
                dc.b "                                                    "

                even

;------------------------------------------------------------------------------


                bss
start_bss:
screen:         ds.l 1
old68:          ds.l 1
old70:          ds.l 1
old110:         ds.l 1
old114:         ds.l 1
old118:         ds.l 1
old120:         ds.l 1
old134:         ds.l 1
old_pal:        ds.w 16
old_scr:        ds.w 1
scanlines:      ds.w 1
oldmfp07:       ds.b 1
oldmfp09:       ds.b 1
oldmfp11:       ds.b 1
oldmfp13:       ds.b 1
oldmfp15:       ds.b 1
oldmfp17:       ds.b 1
oldmfp19:       ds.b 1
oldmfp1b:       ds.b 1
oldmfp21:       ds.b 1
old_res:        ds.b 1
old_sync:       ds.b 1
vblflag:        ds.b 1
old484:         ds.b 1
vbl_flag:       ds.b 1
change_flag:    ds.b 1
                even

save_pos:       ds.l 1

old_back_s:     ds.l 1
old_back_t:     ds.l 1
old_back_a:     ds.l 1
old_back_x:     ds.l 1
old_back_m:     ds.l 1
old_back_a2:    ds.l 1
old_back_t2:    ds.l 1
old_back_t3:    ds.l 1

char_puf:       ds.b 10

save_maske:     ds.b height*16
save_sprite:    ds.b height*16

mask_puffer_s:  ds.b height*16*16
sprite_puffer_s:ds.b height*16*16
mask_puffer_t:  ds.b height*16*16
sprite_puffer_t:ds.b height*16*16
mask_puffer_a:  ds.b height*16*16
sprite_puffer_a:ds.b height*16*16
mask_puffer_x:  ds.b height*16*16
sprite_puffer_x:ds.b height*16*16
mask_puffer_m:  ds.b height*16*16
sprite_puffer_m:ds.b height*16*16
                even

scroll_puf:     ds.l anz_zeilen*52*7*16/4
                ds.w 8000

logo_puffer:    ds.l (lines*weight*16)/4+164

                ds.l 64
screen_ram:     ds.l 230*278/4+160/4
end_bss:        end
