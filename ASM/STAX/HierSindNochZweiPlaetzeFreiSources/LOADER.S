; Hi Guys, hier ist nun mein kleiner Loader. Man bergibt dem Programm
; die Screen-Nummer in D0 (wie immer...).  Die Adresse, an die das Prg
; geladen wird, kann man mit dem equ bestimmen... Ihr mžt nun noch
; den Entpacker an die markierte Stelle einbauen...
; Wenn die Var. debugger auf 1 steht, wird der Teil direkt hinter das
; Programm geladen und die Systemvariablen werden nicht gel”scht (halt zum
; debuggen...) Der Loader sollte eigentlich funktionieren, ich konnt es
; aber leider nicht gescheit austesten.... Die Programme mssen direkt
; an einem Track beginnen (Startsektor = IMMER 1 !!!!)

; Meine Farb-Einblendrout hat noch einen Fehler, aber ich bin gerade so am
; Ende, so daž ihr den rausmachen mžt (Sorry, sollte aber einfach sein...)

;         ICH HASSE PROGRAMMIEREN !!!!!!!!!! FUCK ZEUG !!!!!!!!!!!!
;                   FUCK COMPUTER !!!!!!!!!!!!!   FUCK TERMINE !!!!!!!!!!
;                         FUCK THE WOLRD !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


; P.S.: Ins Programm mžt ihr auch noch springen, aber ich weis nich,
; wieviel ihr schon init. habt.       FUCK LOADER !!!!!!!!!!!!!!!!!!!!!

prg_adr         EQU $0C0000
anz_sekt        EQU 10          ; Anzahl der Sektoren auf der Disk

debugger        EQU 1
                IF debugger=1
                trap    #3              ; zum Debuggen
                moveq   #0,D0           ; Screen 0 laden
                OPT D+
                ELSE
                OPT D-
                lea     $08.w,A0
                lea     _rte,A2
                lea     $0380.w,A1      ; Alles Rausschmeissen
clear_vekt:     move.l  A2,(A0)+
                cmpa.l  A0,A1
                bne.s   clear_vekt
                ENDC

                move.w  D0,screen_number
                move.l  #sync_vbl,$70.w
                move.l  #screen_base,D0
                clr.b   D0
                move.l  D0,screen
                lsr.l   #8,D0
                lea     $FFFF8201.w,A0
                move.w  vblz,D1
wait1:          cmp.w   vblz,D1
                beq.s   wait1
                movep.w D0,0(A0)
                clr.b   $FFFF8260.w
                move.b  #2,$FFFF820A.w

                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4
                moveq   #0,D5
                moveq   #0,D6
                moveq   #0,D7
                movem.l D0-D7,$FFFF8240.w ; Farben L™SCHEN (Hehehe)
                movem.l D0-D7,vbl_pal

                lea     pic,A0
                movea.l screen,A1
                move.w  #180-1,D1
copy_pic:       moveq   #9-1,D0
copy2:          move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                dbra    D0,copy2
                lea     11*8(A1),A1
                dbra    D1,copy_pic

                move.w  screen_number,D0
                add.w   D0,D0
                add.w   D0,D0
                lea     text_adrs,A0
                movea.l 0(A0,D0.w),A0
                bsr     print_text      ; Text auf den Screen

                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4
                moveq   #0,D5
                moveq   #0,D6
                moveq   #0,D7
                movem.l D0-D7,$FFFF8240.w

                moveq   #7-1,D7
einblend:       moveq   #3-1,D6         ; 3 VBL's warten
ein2:           move.w  vblz,D0
wait_einbl:     cmp.w   vblz,D0
                beq.s   wait_einbl
                dbra    D6,ein2

                lea     pic_pal,A0
                lea     vbl_pal,A1
                moveq   #16-1,D6
col_loop:       moveq   #0,D0
                moveq   #0,D1
                move.w  (A0)+,D0
                move.w  (A1),D1
                move.w  D1,D5
                move.w  D0,D2
                move.w  D1,D3
                and.w   #$0F00,D2
                and.w   #$0F00,D3
                cmp.w   D2,D3
                beq.s   no_ein1
                addi.w  #$0100,D5       ; Rot-Anteil erh”hen
no_ein1:        move.w  D0,D2
                move.w  D1,D3
                and.w   #$F0,D2
                and.w   #$F0,D3
                cmp.w   D2,D3
                beq.s   no_ein2
                addi.w  #$10,D5
no_ein2:        and.w   #$0F,D0
                and.w   #$0F,D1
                cmp.w   D0,D1
                beq.s   no_ein3
                addq.w  #1,D5
no_ein3:        move.w  D5,(A1)
                addq.l  #2,A1           ; n„chste Farbe
                dbra    D6,col_loop
                dbra    D7,einblend

                move.w  screen_number,D0
                bsr     load            ; Glle-Loader starten

; Hier den Depack-Algorythmus (f„ngt an an der Adresse 'prg_adr' )

wait:           cmpi.b  #$39,$FFFFFC02.w ; Das hier noch ausbauen...
                bne.s   wait            ; ist nur zum testen

                moveq   #7-1,D7
ausblend_loop:  moveq   #3-1,D6
wait_aus2:      move.w  vblz,D0
wait_ausbl:     cmp.w   vblz,D0
                beq.s   wait_ausbl
                dbra    D6,wait_aus2

                lea     vbl_pal,A0
                moveq   #16-1,D6
col_ausloop:    moveq   #0,D0
                move.w  (A0),D0
                move.w  D0,D1
                and.w   #$0F00,D1
                beq.s   nix_1
                subi.w  #$0100,(A0)
nix_1:          move.w  D0,D1
                and.w   #$F0,D1
                beq.s   nix_2
                subi.w  #$10,(A0)
nix_2:          and.w   #$0F,D0
                beq.s   nix_3
                subq.w  #1,(A0)
nix_3:          addq.w  #2,A0
                dbra    D6,col_ausloop
                dbra    D7,ausblend_loop

                trap    #3
                illegal

sync_vbl:       addq.w  #1,vblz
                movem.l D0-D7,-(SP)
                movem.l vbl_pal,D0-D7
                movem.l D0-D7,$FFFF8240.w
                movem.l (SP)+,D0-D7
_rte:           rte
vblz:           DS.W 1

                >PART 'Print-Rout'
chartab:        DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                DC.B 27,28,29,30,31,32,33,34,35,36 ; Zahlen
                DC.B 0,0,0,0,0,0,0
                DC.B 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19 ; Buch-
                DC.B 20,21,22,23,24,25,26 ;                            staben

print_text:     moveq   #0,D1           ; X=0
                moveq   #0,D2           ; Y=0
                movea.l screen,A1
                lea     9*8(A1),A1
                lea     charset,A2
printloop:      movea.l A2,A3
                moveq   #0,D0
                move.b  (A0)+,D0        ; Zeichen => D0
                bmi     ende_print_text
                sub.w   #32,D0
                move.b  chartab(PC,D0.w),D0
                cmp.w   #20,D0
                blt.s   no_2_line_in_chars
                lea     160*11(A3),A3
no_2_line_in_chars:
                lsl.w   #3,D0           ; *8
                adda.w  D0,A3           ; Zeichenadresse ausrechnen
                move.l  (A3),(A1)
                move.l  4(A3),4(A1)
.offset         SET 160
                REPT 10
                move.l  .offset(A3),.offset(A1)
                move.l  .offset+4(A3),.offset+4(A1)
.offset         SET .offset+160
                ENDR
                addq.w  #8,A1

                addq.w  #1,D1           ; X=X+1
                cmp.w   #11,D1
                bne     printloop
                moveq   #0,D1
                addq.w  #1,D2           ; Y=Y+1
                cmp.w   #15,D2
                beq.s   ende_print_text
                lea     9*8+160*12(A1),A1
                bra     printloop
ende_print_text:rts
                ENDPART
load:           >PART 'Loader'
                lsl.w   #3,D0
                lea     sector_tab,A0
                adda.w  D0,A0
                move.w  (A0)+,D0        ; Seite
                move.w  (A0)+,D5        ; Tracknummer
                moveq   #1,D6           ; Startsektor auf 1
                move.w  (A0)+,D7        ; Anzahl der Sektoren
                IF debugger=1
                move.l  #dummy_memory,dma_adresse
                ELSE
                move.l  #prg_adr,dma_adresse
                ENDC
                tst.w   D0              ; Seite 0?
                bne.s   side2
                move.l  #$0E0E0505,$FFFF8800.w ; Select Floppy A Side 0
                bra.s   side_ok
side2:          move.l  #$0E0E0404,$FFFF8800.w ; Select Floppy A Side 1
side_ok:        bsr     restore         ; erstmal Track 0 anfahren...
                subq.w  #1,D7           ; Anzahl korrigieren
read_loop:      bsr     seek            ; Track anfahren
                bsr     read_sector     ; und Sektoren lesen
                addq.w  #1,D5           ; Track = Track + 1
                addi.l  #anz_sekt*512,dma_adresse
                sub.w   #anz_sekt,D7
                bpl.s   read_loop

wait_motor:     move.w  $FFFF8604.w,D0
                btst    #7,D0
                bne.s   wait_motor
                move.l  #$0E0E0707,$FFFF8800.w
                rts

read_sector:    bsr     set_dma
                bsr     dma_toggle
                move.w  #14,$FFFF8604.w ; maximal 14 Sektoren
                bsr     wait_fdc
                move.w  #$84,$FFFF8606.w
                bsr     wait_fdc
                move.w  D6,$FFFF8604.w
                bsr     wait_fdc
                move.w  #$80,$FFFF8606.w
                bsr     wait_fdc
                move.w  #$90,$FFFF8604.w
                bra     wait_befehl

restore:        move.w  #$80,$FFFF8606.w ; Kommandobyte anw„hlen
                bsr     wait_fdc
                move.w  #$03,$FFFF8604.w ; Kommando setzen
                bra     wait_befehl

seek:           move.w  #$86,$FFFF8606.w ; Datenregister anw„hlen
                bsr     wait_fdc
                move.w  D5,$FFFF8604.w  ; Tracknummer schreiben
                bsr     wait_fdc
                move.w  #$80,$FFFF8606.w
                bsr     wait_fdc
                move.w  #$13,$FFFF8604.w
                bra     wait_befehl

dma_toggle:     move.w  #$90,$FFFF8606.w
                move.w  #$0190,$FFFF8606.w
                move.w  #$90,$FFFF8606.w
                rts

set_dma:        lea     dma_adresse,A0
                move.b  3(A0),$FFFF860D.w ; Low
                move.b  2(A0),$FFFF860B.w ; Mid
                move.b  1(A0),$FFFF8609.w ; High
                rts
wait_befehl:    bsr     wait_fdc
wait_befehl2:   btst    #5,$FFFFFA01.w
                bne.s   wait_befehl2
                rts
wait_fdc:       move.w  D0,-(SP)
                moveq   #20,D0          ; sollte eigentlich lang genug sein...
wait_fdc2:      nop
                dbra    D0,wait_fdc2
                move.w  (SP)+,D0
                rts
; Aufbau:       dc.w Seite, Starttrack, Sektoranzahl, 0 ( Dummy )
sector_tab:     DC.W 0,1,20,0
                DC.W 0,1,20,0
                DC.W 0,1,20,0
dma_adresse:    DC.L prg_adr    ; Wohin laden ?

                ENDPART
text_adrs:      DC.L text1,text1,text1,text1,text1
; Hier die Adressen von den Textseiten eingeben (wird je nach Screennummer
; angew„hlt...)

; Bei den Texten gehen nur die Buchstaben und die Zahlen von 0 - 9 !
; FUCK ZEICHENSATZ !!!!!!!!!!!!
text1:          DC.B "HI GUYS,   "
                DC.B " THIS  IS  "
                DC.B "THE LOADER."
                DC.B "           "
                DC.B "I HOPE YA  "
                DC.B " LIKE IT   "
                DC.B "           "
                DC.B "TODAY IT IS"
                DC.B "   THE     "
                DC.B " 23 09 1993"
                DC.B "   AND MY  "
                DC.B " SCREEN IS "
                DC.B "NOT READY  "
                DC.B "           "
                DC.B " QUESTOR   "

                EVEN
pic:            IBYTES 'GASTON.IMG'
charset:        IBYTES 'LOADFONT.IMG'
pic_pal:        DC.W $0777,$00,$0765,$40,$0432,$0740,$0257,$36
                DC.W $04,$0700,$0666,$0555,$0444,$0333,$0222,$00
vbl_pal:        DS.W 16
screen_number:  DS.W 1
                BSS
screen:         DS.L 1
                DS.B 256
screen_base:    DS.B 32256
                IF debugger=1
dummy_memory:   DS.W 50000
                ENDC
                END
; FUCK ASSEMBLER, DER LOADER IST JETZT AUCH SCHON ZUM ZWEITEN MAL
; GECODED, WEIL MAL WIEDER MEINE FESTPLATTE ABGESCHMIERT IST !!!!!
; TEILWEISE HAT DER ASSEMBLER BEIM SPEICHERN AUCH NOCH PROBLEME  :-<<<<<<<<
                END
