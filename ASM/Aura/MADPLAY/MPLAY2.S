; Player for Syntheticsounds in MadMax Format.
; Runs on any monitor, any machine (STE/E/TT/F030), uses Timer-A for proper
; 50Hz VBL-emulation (even can handle some SID voice tunes (e.g.
; BigAlecs ones).
; Can handle informations from an SNDH Header (name of composer, number of
; tunes).
; On Falcon there is special mode: Autoswitch to 50Hz on VGA/RGB.
; In this mode, High-Colour volumeters... (little demospirit)

; Doesnt use anything like XBRA, so your memory keeps shrinking if you run
; several tunes resident (normal play: no probs!).

; Coded at one afternoon (the code looks like that!): 15.2.1992
; Updates:    End of 92.
; F030-patch: 3.3.97
; ICE-Depack: 1.5.97
; VBL-Mode  : 15.8.97 ('!Vxx' tag).
; Musicmon  : 19.10.98 (`MuMo` Tag).   ( Musicmon Digidrumtunes )
; Falcon50Hz: 24.10.98                 ( also many bugfixes )

; Version   : 1.00   (After 6 years and hundred of 0.3x, 0.4x versions...)

; To do     : Nur auf 68020 CPU gecheckt, nicht auf Falcon Videosystem.

; By the way: Done by BDCannibal (knaus@ruf.uni-freiburg.de)

speed           EQU 246         ; 245.76 (Timer-Wert fuer 50Hz IRQ)

MAX_HEADER      EQU 200         ; Bis Byte ~ wird SNDH gesucht.
SPACE_DEPACK    EQU 60000       ; Buffer fÅr ICE Depack (max. Size File)
OFFSET_MM       EQU 40000       ; Offset auf Musicmonbuffer.

FALCON          EQU 0           ; Falcon Videochange (50 Hz)
FALCON_COOL     EQU 0           ; Falcon immere auf 50Hz

                OPT D-,O+
                OUTPUT 'E:\MAD_PLAY.TTP','f:\tunes\lotus\twaves.snd'

; Commandozeile auslesen, restlichen Speicher freigeben und Tune laden.

                movea.l 4(SP),A0
                lea     $80(A0),A0      ; Commandline
                move.b  (A0)+,D7        ; leer ?
                beq     endend

                ext.w   D7              ; Anzahl Buchstaben
                subq.w  #1,D7
                lea     filename,A1
loop:           move.b  (A0)+,(A1)+
                dbra    D7,loop

                clr.b   (A1)            ; Schluûbyte

                movea.l 4(SP),A6        ; Erst nîtig, nachdem man Filegr. kennt

                pea     dta             ; DTA-Buffer einrichten
                move.w  #$1A,-(SP)      ; Datei einlesen
                trap    #1
                addq.w  #6,SP

                clr.w   -(SP)           ; Nur normale Dateien
                pea     filename
                move.w  #$4E,-(SP)
                trap    #1
                addq.w  #8,SP

                tst.w   D0
                beq.s   found

                pea     fault1(PC)
fault_out:      move.w  #9,-(SP)
                trap    #1
                addq.w  #6,SP
                bra     ende

found:          move.l  $0C(A6),D0
                add.l   $14(A6),D0
                add.l   $1C(A6),D0
                add.l   #$0400,D0
                lea     dta,A0
;                add.l   26(A0),D0       ; Grîûe des Files dazuaddieren
                move.l  D0,resident     ; wird gebraucht, wenn das Teil resident
;                                         gemacht werden soll !
                move.l  D0,-(SP)
                move.l  A6,-(SP)
                clr.w   -(SP)
                move.w  #$4A,-(SP)
                trap    #1
                lea     12(SP),SP

                tst.w   D0
                beq.s   no_mem_f

suck_it:        pea     fault5(PC)
                bra     fault_out

no_mem_f:       move.l  dta+26,D0       ; Speicher fÅr Sound allocieren.
                addi.l  #SPACE_DEPACK,D0
                move.l  D0,-(SP)
                move.w  #$48,-(SP)
                trap    #1
                addq.l  #4,SP

                tst.l   D0
                ble.s   suck_it

                move.l  D0,sound        ; Basisadresse

                clr.w   -(SP)           ; nur lesen
                pea     filename
                move.w  #$3D,-(SP)
                trap    #1
                addq.w  #6,SP

                tst.l   D0
                bpl.s   ok1

                pea     fault2(PC)
                bra.s   fault_out

ok1:            move.l  sound,-(SP)
                move.l  dta+26,-(SP)    ; Dateigrîûe
                move.w  D0,D7
                move.w  D7,-(SP)
                move.w  #$3F,-(SP)
                trap    #1
                lea     12(SP),SP

                tst.l   D0
                bpl.s   ok2

                pea     fault3(PC)
                bra     fault_out

ok2:            move.w  D7,-(SP)        ; fclose()
                move.w  #$3E,-(SP)
                trap    #1
                addq.w  #4,SP

                movea.l sound,A0        ; File ggf. entpacken.
                bsr     ice_depack2

                lea     txt1(PC),A0     ; Text modifizieren
                lea     dta+30,A1       ; Filenamen.
                moveq   #11,D0          ; max. 12 Buchstaben
loop2:          move.b  (A1)+,D1
                beq.s   clr_rest
                move.b  D1,(A0)+
                dbra    D0,loop2

clr_rest:       tst.w   D0
                bmi.s   noclrrest

clr_rest_lp:    move.b  #' ',(A0)+
                dbra    D0,clr_rest_lp

noclrrest:      lea     txt2(PC),A0
                move.l  dta+26,D0       ; DateilÑnge
                move.w  #10000,D2
                REPT 4
                divu    D2,D0
                add.b   #'0',D0
                move.b  D0,(A0)+
                clr.w   D0
                swap    D0
                divu    #10,D2
                ENDR
                add.b   #'0',D0
                move.b  D0,(A0)

                pea     starttxt(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.w  #6,SP

; ****************************************************************************

                bsr     test_sndh       ; Testen, ob SNDH Header vorhanden.

                IFNE FALCON_COOL ; Immer Falcon auf 50Hz Screen
                st      use_vbl         ; gehen ? (FÅr den Volumeter)
                ENDC

; ****************************************************************************

                clr.l   -(SP)           ; Scotty Superbeam...
                move.w  #$20,-(SP)
                trap    #1
                addq.w  #6,SP

                lea     saver,A0
                move.l  D0,(A0)+
                move.w  $FFFF8242.w,(A0)+
                move    SR,(A0)+
                move.w  $0484.w,(A0)+
                move.b  $FFFFFA19.w,(A0)+
                move.b  $FFFFFA17.w,(A0)+
                move.b  $FFFFFA13.w,(A0)+
                move.b  $FFFFFA07.w,(A0)+
                move.b  $FFFFFA1F.w,(A0)+
                move.b  $FFFFFA19.w,(A0)+
                move.l  $0110.w,(A0)+
                move.l  $0114.w,(A0)+
                move.l  $0134.w,(A0)+
                move.l  $08.w,(A0)+     ; Exceptions (fÅr Falcon!)
                move.l  $14.w,(A0)+     ; Zero Divide
                move.l  $20.w,(A0)+     ; Privilege Violation
                moveq   #8-1,D7
                lea     $60.w,A1        ; Spurious IRQ + Autovecs (Timer)...
sav_autovector: move.l  (A1)+,(A0)+
                dbra    D7,sav_autovector

                IFNE FALCON
                DC.L $4E7A0002  ; movec cacr,d0
                move.l  D0,(A0)+

                lea     save_vid,A0
                lea     $FFFF8200.w,A1  ; Videobase.
                move.w  $60(A1),(A0)+
                move.w  $66(A1),(A0)+
                move.l  $C0(A1),(A0)+

                move.w  $0A(A1),(A0)+
                move.w  $0E(A1),(A0)+
                move.w  $10(A1),(A0)+
                move.l  $82(A1),(A0)+
                move.l  $86(A1),(A0)+
                move.l  $8A(A1),(A0)+
                move.l  $A2(A1),(A0)+
                move.l  $A6(A1),(A0)+
                move.l  $AA(A1),(A0)+

                move.l  $FFFF9800.w,(A0)+
                move.l  $FFFF9804.w,(A0)+

                move.l  $FFFF8200.w,D0
                lsl.w   #8,D0
                move.b  $FFFF820D.w,D0
                move.l  D0,(A0)+
                ENDC

                bsr     tst_cpu         ; 68020 oder 68030 CPU ???
                beq.s   no_shadow

                move    #$2700,SR
                move.l  #bus_error,$08.w ; Shadowregister ansteuern.
                move.l  #rte,D0
                move.l  D0,$60.w        ; Bei FRAZER-Tunes nîtig.
                move.l  D0,$14.w
                move.l  D0,$20.w
                move    #$2300,SR
                bra.s   no_shadow

rte:            rte

no_shadow:      clr.b   backgrd

                bclr    #0,$0484.w      ; Tastaturklick aus (nur bei Backgrd.)
                move.w  #$00,$FFFF8242.w ; fÅr alle Farbmonis !
                clr.b   $FFFFFA19.w     ; Timer A stoppen

                tst.b   use_vbl         ; LÑuft Tune mit Timer-A ?
                beq     def_use_tima

                IFNE (FALCON-FALCON_COOL) ; Bei Falcon-normal noch auf Taste
                lea     enter_50hz(PC),A6 ; warten, bevor Screenmode
                bsr     print           ; umgeschalten wird (fÅr SNDH)
                move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP
                ENDC

                IFNE FALCON     ; Im Falconmodus Bildschirm auf 50Hz
                tst.b   falcon
                beq     no_f030

                moveq   #0,D0           ; Cache aus (nur im Fullscreenmodus)
                DC.L $4E7B0002

                stop    #$2300          ; VBL abwarten.

                move.l  #screen+256,D0  ; Videoadresse setzen.
                clr.b   D0
                bsr     set_vadr

                cmpi.b  #2,cookies+_MON ; RGB Monitor ???
                beq.s   set_rgb

* Monitor: VGA
* 320*240, True Color, 50.0 Hz, 31470 Hz
                move.l  #$C60091,$FFFF8282.w
                move.l  #$1002AB,$FFFF8286.w
                move.l  #$8C0096,$FFFF828A.w
                move.l  #$04EB04D1,$FFFF82A2.w
                move.l  #$3F00A9,$FFFF82A6.w
                move.l  #$046904E7,$FFFF82AA.w
                move.w  #$0200,$FFFF820A.w
                move.w  #$0186,$FFFF82C0.w
                clr.w   $FFFF8266.w
                move.w  #$0100,$FFFF8266.w
                move.w  #$05,$FFFF82C2.w
                move.w  #$0140,$FFFF8210.w
                move    #$2700,SR
                bra.s   vset

* Monitor: RGB/TV
* 320*240, True Color, 50.0 Hz, 15625 Hz
set_rgb:        move.l  #$C700A0,$FFFF8282.w
                move.l  #$1F02B8,$FFFF8286.w
                move.l  #$8700AA,$FFFF828A.w
                move.l  #$02710265,$FFFF82A2.w
                move.l  #$2F0047,$FFFF82A6.w
                move.l  #$0227026B,$FFFF82AA.w
                move.w  #$0200,$FFFF820A.w
                move.w  #$0186,$FFFF82C0.w
                clr.w   $FFFF8266.w
                move.w  #$0100,$FFFF8266.w
                move.w  #$00,$FFFF82C2.w
                move.w  #$0140,$FFFF8210.w

vset:           clr.l   $FFFF9800.w     ; FÅr Absturz (& Bugaboo)...
                move.l  #-1,$FFFF9804.w
                bsr     f030_prep_screen ; Screen fÅllen...
no_f030:
                ENDC

                tst.b   musicmon        ; Musicmon braucht keinen IRQ
                bne.s   start_it

                move.l  #vbl,$70.w      ; VBL installieren
                bra.s   start_it

def_use_tima:   tst.b   musicmon
                bne.s   start_it

                move    #$2700,SR       ; Interrupts sperren und Timer A init.
                move.l  #timer_a,$0134.w
                bclr    #3,$FFFFFA17.w
                bset    #5,$FFFFFA13.w
                bset    #5,$FFFFFA07.w
                move.b  #speed,$FFFFFA1F.w
                move.b  #7,$FFFFFA19.w  ; Timer mit Vorteiler 1:200 starten

start_it:       moveq   #1,D0
                movea.l sound,A0
                move.l  A0,D1           ; d1.l : Bufferadresse Musicmon
                add.l   #OFFSET_MM,D1
                jsr     (A0)            ; Soundinit

                stop    #$2300

                bsr     clr_keybuf


mainloop:       tst.b   musicmon        ; Kein IRQ, also nicht auf VSync warten
                bne.s   no_volum        ; Ebenfalls kein Volumeter.

                move.w  counter,D0      ; Nur alle 50 Hz.
wait_timer_a:   cmp.w   counter,D0
                beq.s   wait_timer_a

                bsr     volumeter       ; Aussteuerungsanzeige.

no_volum:       move.w  #$0B,-(SP)      ; Tasten ???
                trap    #1
                addq.l  #2,SP

                tst.w   D0
                beq.s   _mainloop

                move.w  #7,-(SP)
                trap    #1
                addq.w  #2,SP

                swap    D0              ; Scancode

                cmpi.b  #$39,D0         ; Ende ? (Space)
                beq     end
                cmpi.b  #$13,D0         ; Resident halrten ? (R)
                bne.s   no_resi
                bsr     resi
no_resi:        cmpi.b  #$01,D0         ; ESC zum Vorspulen.
                beq     vorspul
                cmpi.b  #$0B+10,D0      ; 1-0 ? (max. 20 Tasten)
                bgt.s   mainloop
                subq.b  #$02,D0
                bmi.s   mainloop

                ext.w   D0
                addq.w  #1,D0

                tst.w   anz_songs       ; Wenn kein SNDH Header vorh.: alles
                beq.s   all_keys        ; moeglich.

                cmp.w   anz_songs(PC),D0 ; Zu weit ?
                bgt.s   mainloop

all_keys:       movea.l sound,A0
                jsr     (A0)            ; neuer Sound installieren
                bra.s   mainloop

_mainloop:      cmpi.b  #$39,$FFFFFC02.w ; Assig am OS vorbei...
                beq     end
                bra.s   mainloop

volumeter:      >PART 'Volumeter'
                IFNE FALCON
                tst.b   use_vbl
                bne.s   f030_volum
                ENDC

                movem.l D0-A6,-(SP)

                lea     vol,A6

                moveq   #2,D7
out_loop:       moveq   #$0F,D0
                and.b   (A6)+,D0
                add.w   D0,D0
                add.w   D0,D0
                move.l  volm(PC,D0.w),D0
                move.l  D0,-(SP)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                dbra    D7,out_loop

                pea     curs_up(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP

                movem.l (SP)+,D0-A6
                rts

; Volumeterstrings (kein Stress bei Umwandlung...)
volm:           DC.L vol0,vol1,vol2,vol3
                DC.L vol4,vol5,vol6,vol7
                DC.L vol8,vol9,vola,volb
                DC.L volc,vold,vole,volf

                IFNE FALCON
fani:           DC.W 1434
f030_volum:     movem.l D0-A6,-(SP)

                move.l  #screen+256,D0
                clr.b   D0
                movea.l D0,A0

                adda.l  #640*150+64,A0
                lea     vol,A6
                lea     fvolgfx+4,A4

                move.w  fani,D0
                subq.w  #2,D0
                bpl.s   fokok
                move.w  #1434,D0
fokok:          move.w  D0,fani
                add.w   D0,D0
                adda.w  fani_off(PC,D0.w),A4

                moveq   #2,D7
fvol_lp:        moveq   #$0F,D0
                and.b   (A6)+,D0
                mulu    #8,D0
                addq.w  #2,D0           ; Offset und -1, kein 0
                move.w  #122,D1
                sub.w   D0,D1
                move.w  D0,D6
                move.w  D1,D4
                movea.l A4,A1
                movea.l A1,A3
                movea.l A0,A2
                moveq   #13,D5
fvol_lp2:       move.l  (A1)+,(A0)+
                dbra    D0,fvol_lp2
                moveq   #0,D2
                move.w  D1,D0
                subq.w  #1,D0
                ble.s   fno_clr
fclr_rest:      move.l  D2,(A0)+
                dbra    D0,fclr_rest
fno_clr:        lea     640(A2),A2
                lea     640(A3),A3
                movea.l A3,A1
                movea.l A2,A0
                move.w  D6,D0
                dbra    D5,fvol_lp2

                lea     640*4(A2),A2
                lea     640*13(A4),A4
                movea.l A2,A0
                dbra    D7,fvol_lp

                movem.l (SP)+,D0-A6
                rts

fani_off:       DC.W 12860,12860,12860,12860,12862,12862,12862
                DC.W 12862,12864,12864,12864,12864,12866,13506
                DC.W 13506,13506,13508,13508,13508,13508,13510
                DC.W 13510,13510,13510,13512,13512,13512,13512
                DC.W 13514,13514,13514,13514,13514,13516,13516
                DC.W 13516,13516,13518,13518,13518,13518,13518
                DC.W 13520,13520,13520,13520,13520,13520,13522
                DC.W 13522,13522,13522,12882,12882,12884,12884
                DC.W 12884,12884,12884,12884,12884,12246,12246
                DC.W 12246,12246,12246,12246,11606,11606,11608
                DC.W 11608,11608,11608,10968,10968,10968,10968
                DC.W 10968,10328,10328,10328,10328,10328,9688
                DC.W 9688,9688,9688,9688,9048,9048,9050
                DC.W 9048,9048,8408,8408,8408,8408,8408
                DC.W 8408,7768,7768,7768,7768,7768,7128
                DC.W 7128,7128,7128,7128,7128,7128,6488
                DC.W 6486,6486,6486,6486,6486,6486,6486
                DC.W 6486,6484,5844,5844,5844,5844,5844
                DC.W 5844,5842,5842,5842,5842,5842,5842
                DC.W 5840,5840,5840,5840,5840,5840,5838
                DC.W 6478,6478,6478,6478,6476,6476,6476
                DC.W 6476,7114,7114,7114,7114,7114,7112
                DC.W 7752,7752,7752,7750,8390,8390,8390
                DC.W 8388,9028,9028,9028,9026,9666,9666
                DC.W 9666,10304,10304,10304,10944,10942,10942
                DC.W 11582,11582,11580,12220,12220,12860,12858
                DC.W 12858,13498,13496,13496,14136,14136,14774
                DC.W 14774,14774,15414,15412,15412,16052,16052
                DC.W 16690,16690,16690,17330,17328,17968,17968
                DC.W 17968,18606,18606,18606,19246,19244,19244
                DC.W 19884,19884,19884,20522,20522,20522,21162
                DC.W 21160,21160,21160,21800,21800,21798,21798
                DC.W 22438,22438,22438,22438,22436,23076,23076
                DC.W 23076,23076,23076,23074,23074,23714,23714
                DC.W 23714,23714,23714,23712,23712,23712,23712
                DC.W 23712,23712,23712,23712,23710,23710,23710
                DC.W 23070,23070,23070,23070,23070,23070,23070
                DC.W 22430,22430,22430,22430,22430,21790,21790
                DC.W 21790,21150,21150,21150,21148,20510,20510
                DC.W 20510,19870,19870,19230,19230,19230,18590
                DC.W 18590,17950,17950,17950,17310,17310,16670
                DC.W 16670,16030,16030,15390,15390,14752,14752
                DC.W 14112,14112,14112,13472,13472,12832,12834
                DC.W 12194,11554,11554,10914,10914,10274,10276
                DC.W 9636,9636,8996,8996,8356,8358,7718
                DC.W 7718,7718,7078,7078,6440,6440,5800
                DC.W 5800,5160,5162,4522,4522,4522,3884
                DC.W 3884,3244,3244,3244,2606,2606,2606
                DC.W 1966,1968,1968,1968,1328,1330,1330
                DC.W 690,690,692,692,692,692,54
                DC.W 54,54,54,56,56,56,56
                DC.W 58,58,58,60,60,60,60
                DC.W 62,62,62,62,64,64,64
                DC.W 64,706,706,706,706,708,708
                DC.W 1348,1348,1350,1990,1990,1990,1992
                DC.W 2632,2632,2632,3274,3274,3274,3914
                DC.W 3914,4556,4556,4556,5196,5198,5838
                DC.W 5838,6478,6478,7120,7120,7760,7760
                DC.W 7760,8400,8402,9042,9042,9682,9682
                DC.W 10322,10324,10964,10964,11604,11604,12244
                DC.W 12884,12886,13526,13526,14166,14166,14166
                DC.W 14806,14806,15448,15448,16088,16088,16728
                DC.W 16728,17368,17368,18008,18008,18008,18648
                DC.W 18648,19288,19288,19288,19928,19928,20568
                DC.W 20568,20568,21210,21208,21208,21208,21848
                DC.W 21848,21848,22488,22488,22488,22488,22488
                DC.W 23128,23128,23128,23128,23128,23128,23128
                DC.W 23768,23768,23768,23766,23766,23766,23766
                DC.W 23766,23766,23766,23766,23764,23764,23764
                DC.W 23764,23764,23124,23124,23122,23122,23122
                DC.W 23122,23122,22482,22480,22480,22480,22480
                DC.W 21840,21840,21838,21838,21198,21198,21198
                DC.W 21196,20556,20556,20556,19914,19914,19914
                DC.W 19274,19274,19272,18632,18632,18632,17990
                DC.W 17990,17990,17350,17348,16708,16708,16708
                DC.W 16066,16066,15426,15426,15424,14784,14784
                DC.W 14784,14142,14142,13502,13502,13500,12860
                DC.W 12860,12860,12218,12218,11578,11576,11576
                DC.W 10936,10936,10934,10294,10294,10294,9652
                DC.W 9652,9652,9012,9010,9010,9010,8370
                DC.W 8368,8368,8368,7728,7726,7726,7726
                DC.W 7086,7084,7084,7084,7084,7084,6442
                DC.W 6442,6442,6442,6440,6440,6440,6440
                DC.W 5800,5798,5798,5798,5798,5798,5798
                DC.W 5796,5796,5796,5796,5796,5796,5794
                DC.W 5794,5794,5794,5794,5794,6434,6432
                DC.W 6432,6432,6432,6432,6432,6432,6432
                DC.W 6430,7070,7070,7070,7070,7070,7070
                DC.W 7070,7710,7710,7710,7710,7710,8350
                DC.W 8350,8350,8350,8350,8350,8990,8990
                DC.W 8988,8990,8990,9630,9630,9630,9630
                DC.W 9630,10270,10270,10270,10270,10270,10910
                DC.W 10910,10910,10910,10910,11550,11550,11550
                DC.W 11550,11552,11552,12192,12192,12192,12192
                DC.W 12192,12192,12834,12834,12834,12834,12834
                DC.W 12834,12834,12836,12836,13476,13476,13476
                DC.W 13476,13478,13478,13478,13478,13478,13478
                DC.W 13480,13480,13480,13480,13480,13482,13482
                DC.W 13482,13482,13484,13484,13484,13484,13484
                DC.W 13486,13486,13486,13486,13488,13488,13488
                DC.W 13488,13490,13490,13490,13490,13492,13492
                DC.W 13492,12852,12854,12854,12854,12854,12856
                DC.W 12856,12856,12856,12858,12858,12858,12860
                DC.W 12220,12220,12220,12222,12222,12222,12222
                DC.W 12224,12224,12224,12224,12226,11586,11586
                DC.W 11586,11588,11588,11588,11588,11590,11590
                DC.W 11590,11590,11592,11592,11592,11592,11594
                DC.W 11594,11594,11594,11594,11596,11596,11596
                DC.W 11596,11598,11598,11598,11598,11598,11600
                DC.W 11600,11600,11600,11600,11600,11602,11602
                DC.W 11602,11602,12242,12242,12244,12244,12244
                DC.W 12244,12244,12244,12884,12886,12886,12886
                DC.W 12886,12886,12886,13526,13526,13528,13528
                DC.W 13528,13528,14168,14168,14168,14168,14168
                DC.W 14808,14808,14808,14808,14808,15448,15448
                DC.W 15448,15448,15448,16088,16088,16090,16088
                DC.W 16088,16728,16728,16728,16728,16728,16728
                DC.W 17368,17368,17368,17368,17368,18008,18008
                DC.W 18008,18008,18008,18008,18008,18648,18646
                DC.W 18646,18646,18646,18646,18646,18646,18646
                DC.W 19284,19284,19284,19284,19284,19284,19284
                DC.W 19282,19282,19282,19282,19282,19282,19280
                DC.W 19280,19280,19280,19280,19280,19278,18638
                DC.W 18638,18638,18638,18636,18636,18636,18636
                DC.W 17994,17994,17994,17994,17994,17992,17352
                DC.W 17352,17352,17350,16710,16710,16710,16708
                DC.W 16068,16068,16068,16066,15426,15426,15426
                DC.W 14784,14784,14784,14144,14142,14142,13502
                DC.W 13502,13500,12860,12860,12860,12218,12218
                DC.W 11578,11576,11576,10936,10936,10294,10294
                DC.W 10294,9654,9652,9652,9012,9012,8370
                DC.W 8370,8370,7730,7728,7088,7088,7088
                DC.W 6446,6446,6446,5806,5804,5804,5164
                DC.W 5164,5164,4522,4522,4522,3882,3880
                DC.W 3880,3880,3240,3240,3238,3238,2598
                DC.W 2598,2598,2598,2596,1956,1956,1956
                DC.W 1956,1956,1954,1954,1314,1314,1314
                DC.W 1314,1314,1312,1312,1312,1312,1312
                DC.W 1312,1312,1312,1310,1310,1310,1950
                DC.W 1950,1950,1950,1950,1950,1950,2590
                DC.W 2590,2590,2590,2590,3230,3230,3230
                DC.W 3870,3870,3870,3868,4510,4510,4510
                DC.W 5150,5150,5790,5790,5790,6430,6430
                DC.W 7070,7070,7070,7710,7710,8350,8350
                DC.W 8990,8990,9630,9630,10272,10272,10912
                DC.W 10912,10912,11552,11552,12192,12834,12834
                DC.W 13474,13474,14114,14114,14754,14756,15396
                DC.W 15396,16036,16036,16676,16678,17318,17318
                DC.W 17318,17958,17958,18600,18600,19240,19240
                DC.W 19880,19882,20522,20522,20522,21164,21164
                DC.W 21804,21804,21804,22446,22446,22446,23086
                DC.W 23088,23088,23088,23728,23730,23730,24370
                DC.W 24370,24372,24372,24372,24372,25014,25014
                DC.W 25014,25014,25016,25016,25016,25016,25018
                DC.W 25018,25018,25660,25020,25020,25020,25022
                DC.W 25022,25022,25022,25024,25024,25024,25024
                DC.W 24386,24386,24386,24386,24388,24388,23748
                DC.W 23748,23750,23110,23110,23110,23112,22472
                DC.W 22472,22472,21834,21834,21834,21194,21194
                DC.W 20556,20556,20556,19916,19918,19278,19278
                DC.W 18638,18638,18000,18000,17360,17360,17360
                DC.W 16720,16722,16082,16082,15442,15442,14802
                DC.W 14804,14164,14164,13524,13524,12884,12884
                DC.W 12246,11606,11606,10966,10966,10966,10326
                DC.W 10326,9688,9688,9048,9048,8408,8408
                DC.W 7768,7768,7128,7128,7128,6488,6488
                DC.W 5848,5848,5848,5208,5208,4568,4568
                DC.W 4568,3930,3928,3928,3928,3288,3288
                DC.W 3288,2648,2648,2648,2648,2648,2008
                DC.W 2008,2008,2008,2008,2008,2008,1368
                DC.W 1368,1368,1366,1366,1366,1366,1366
                DC.W 1366,1366,1366,1364,1364,1364,1364
                DC.W 1364,2004,2004,2002,2002,2002,2002
                DC.W 2002,2642,2640,2640,2640,2640,3280
                DC.W 3280,3278,3278,3918,3918,3918,3916
                DC.W 4556,4556,4556,5194,5194,5194,5834
                DC.W 5834,5832,6472,6472,6472,7110,7110
                DC.W 7110,7750,7748,8388,8388,8388,9026
                DC.W 9026,9666,9666,9664,10304,10304,10304
                DC.W 10942,10942,11582,11582,11580,12220,12220
                DC.W 12860,12858,12858,13498,13496,13496,14136
                DC.W 14136,14134,14774,14774,14774,15412,15412
                DC.W 15412,16052,16050,16050,16050,16690,16688
                DC.W 16688,16688,17328,17326,17326,17326,17966
                DC.W 17964,17964,17964,17964,17964,18602,18602
                DC.W 18602,18602,18600,18600,18600,18600,19240
                DC.W 19238,19238,19238,19238,19238,19238,19236
                DC.W 19236,19236,19236,19236,19236,19234,19234
                DC.W 19234,19234,19234,19234,19234,18592,18592
                DC.W 18592,18592,18592,18592,18592,18592,18590
                DC.W 17950,17950,17950,17950,17950,17950,17950
                DC.W 17310,17310,17310,17310,17310,16670,16670
                DC.W 16670,16670,16670,16670,16030,16030,16028
                DC.W 16030,16030,15390,15390,15390,15390,15390
                DC.W 14750,14750,14750,14750,14750,14110,14110
                DC.W 14110,14110,14110,13470,13470,13470,13470
                DC.W 13472,13472,12832,12832,12832,12832,12832
                DC.W 12832,12834,12194,12194,12194,12194,12194
                DC.W 12194,12196,12196,11556,11556,11556,11556
                DC.W 11558,11558,11558,11558,11558,11558,11560
                DC.W 11560,11560,11560,11560,11562,11562,11562
                DC.W 11562,11564,11564,11564,11564,11564,11566
                DC.W 11566,11566,11566,11568,11568,11568,11568
                DC.W 11570,11570,11570,11570,11572,11572,11572
                DC.W 12212,12214,12214,12214,12214,12216,12216
                ENDC
                ENDPART
resi:           >PART 'Make resistend'
; Auf Falcon ist residente Musik nur erlaubt, wenn nicht im HC-Mode.
                IFEQ (FALCON-FALCON_COOL)
                rts
                ENDC

                IFEQ FALCON
                tst.b   use_vbl
                beq.s   resi_ok
                rts
                ENDC

resi_ok:        st      backgrd

                clr.w   -(SP)           ; Programm beenden und resident halten
                move.l  resident,-(SP)  ; Speicher nicht freigeben.
                move.w  #$31,-(SP)
                trap    #1

vorspul:        movem.l D0-A6,-(SP)     ; Vorspulen.
spieler:        movea.l sound,A0
                jsr     8(A0)           ; Sound playen

;                move.w  #50,D0
;lp1:            move.w  #5,D1
;lp2:            dbra    D1,lp2
;                dbra    D0,lp1

                move.w  #-1,-(SP)
                move.w  #11,-(SP)
                trap    #13
                addq.w  #4,SP

                btst    #0,D0
                bne.s   spieler

                movem.l (SP)+,D0-A6
                bra     mainloop
                ENDPART
end:            PART 'Ende'
                moveq   #0,D0           ; All SNDH Files should get
                movea.l sound,A0        ; that (at least a rts)
                jsr     4(A0)

                move    #$2700,SR
                lea     saver+8,A0
                move.w  (A0)+,$0484.w
                move.b  (A0)+,$FFFFFA19.w
                move.b  (A0)+,$FFFFFA17.w
                move.b  (A0)+,$FFFFFA13.w
                move.b  (A0)+,$FFFFFA07.w
                move.b  (A0)+,$FFFFFA1F.w
                move.b  (A0)+,$FFFFFA19.w
                move.l  (A0)+,$0110.w
                move.l  (A0)+,$0114.w
                move.l  (A0)+,$0134.w
                move.l  (A0)+,$08.w
                move.l  (A0)+,$14.w
                move.l  (A0)+,$20.w

                moveq   #8-1,D7
                lea     $60.w,A1
res_autovector: move.l  (A0)+,(A1)+
                dbra    D7,res_autovector

                IFNE FALCON
                tst.b   falcon
                beq.s   no_f030_2       ; Cache ggf. zurÅck.

                move.l  (A0)+,D0
                DC.L $4E7B0002
no_f030_2:
                ENDC

                move.l  #$080000,$FFFF8800.w ; Ton aus Geppard !
                move.l  #$090000,$FFFF8800.w
                move.l  #$0A0000,$FFFF8800.w

                IFEQ FALCON_COOL ; UnzulÑnglichkeiten von Turbo-Ass
                tst.b   use_vbl         ; im Berzug auf Pseudoopcodes
                beq.s   no_v_back
                ENDC

                IFNE FALCON
;                stop    #$2300
                lea     save_vid,A0

                lea     $FFFF8200.w,A1
                move.w  (A0)+,$60(A1)
                move.w  (A0)+,$66(A1)
                move.l  (A0)+,$C0(A1)

                move.w  (A0)+,$0A(A1)
                move.w  (A0)+,$0E(A1)
                move.w  (A0)+,$10(A1)
                move.l  (A0)+,$82(A1)
                move.l  (A0)+,$86(A1)
                move.l  (A0)+,$8A(A1)
                move.l  (A0)+,$A2(A1)
                move.l  (A0)+,$A6(A1)
                move.l  (A0)+,$AA(A1)

                move.l  (A0)+,$FFFF9800.w
                move.l  (A0)+,$FFFF9804.w

                move.l  (A0)+,D0        ; Alte Videoadresse zurÅck...
                bsr     set_vadr
                ELSE
                nop
                ENDC

no_v_back:      move.l  sound,-(SP)     ; Soundspeicher freigeben.
                move.w  #$49,-(SP)
;                trap    #1
                addq.l  #6,SP

                pea     ping(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP

                lea     saver+4,A0
                move.w  (A0),$FFFF8242.w
;                move    2(A0),SR
                move.l  -(A0),-(SP)
                move.w  #$20,-(SP)      ; zurÅck in den User-Mode
                trap    #1
                addq.l  #6,SP

endend:         clr.w   -(SP)           ; Don't ask...
                trap    #1
                addq.l  #2,SP

                clr.w   -(SP)
                trap    #1

ende:           move.w  #7,-(SP)        ; wird nach den Fehlermeldungen ange-
                trap    #1              ; sprungen
                addq.l  #2,SP
                clr.w   -(SP)
                trap    #1
                ENDPART
clr_keybuf:     PART 'Keybordbuffer leer'
                movem.l D0-A6,-(SP)
loopy:          move.w  #$0B,-(SP)      ; Tastaturbuffer leeren.
                trap    #1
                addq.l  #2,SP
                tst.w   D0
                beq.s   loopy_end
                move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP
                bra.s   loopy
loopy_end:      movem.l (SP)+,D0-A6
                rts
                ENDPART
vbl:            >PART 'VBL Mode'
                movem.l D0-A6,-(SP)
                bsr.s   get_vol
                movea.l sound,A0
                jsr     8(A0)
                movem.l (SP)+,D0-A6
                addq.w  #1,counter
                rte
                ENDPART
timer_a:        >PART 'Timer A'
                movem.l D0-A6,-(SP)
                bsr.s   get_vol

                movea.l sound,A0
                jsr     8(A0)           ; Sound spielen

end_tima:       movem.l (SP)+,D0-A6
                move.b  #%11011111,$FFFFFA0F.w ; da SEI
                move.b  #speed,$FFFFFA1F.w

                addq.w  #1,counter
                rte
                ENDPART
get_vol:        >PART 'Volumen auslesen'
                lea     $FFFF8800.w,A0
                lea     vol,A1
                move.b  #8,(A0)
                move.b  (A0),(A1)+
                move.b  #9,(A0)
                move.b  (A0),(A1)+
                move.b  #10,(A0)
                move.b  (A0),(A1)
                rts
                ENDPART
test_sndh:      PART 'SNDH test und Infos ausgeben'
                move.l  #'SNDH',D0      ; SNDH Header vorhanden ?
                bsr     search_sndh
                beq     no_sndh

                move.l  #'COMM',D0      ; Composer Tag "COMM"
                bsr     search_sndh
                beq.s   no_sndh_comm

                lea     composer(PC),A6
                bsr     print
                movea.l D0,A6
                bsr     print

no_sndh_comm:   move.l  #'COMP',D0      ; Composer Tag "COMP" (analog "COMM")
                bsr     search_sndh
                beq.s   no_sndh_comm2

                lea     composer(PC),A6
                bsr     print
                movea.l D0,A6
                bsr     print

no_sndh_comm2:  move.l  #'TITL',D0      ; Title
                bsr     search_sndh
                beq     no_sndh_titl

                lea     title(PC),A6
                bsr     print
                movea.l D0,A6
                bsr     print

no_sndh_titl:   move.l  #'RIPP',D0      ; Ripper
                bsr     search_sndh
                beq     no_sndh_ripp

                lea     ripp(PC),A6
                bsr     print
                movea.l D0,A6
                bsr     print

no_sndh_ripp:   move.l  #'CONV',D0      ; Konvertierung
                bsr     search_sndh
                beq     no_sndh_conv

                lea     conversion(PC),A6
                bsr     print
                movea.l D0,A6
                bsr     print

no_sndh_conv:   move.w  #'##',D0
                bsr     search_sndh_w
                beq     no_sndh

                move.w  D0,anz

                move.w  #$FF,D1
                and.w   D0,D1           ; 10^0
                lsr.w   #8,D0           ; 10^1

                subi.b  #'0',D0
                subi.b  #'0',D1
                mulu    #10,D0
                add.w   D1,D0
                move.w  D0,anz_songs

                lea     songs(PC),A6
                bsr     print

                move.w  #'!V',D0        ; VBL-Mode ???
                bsr     search_sndh_w
                beq.s   no_tim_sndh2

                lea     vbl_mode(PC),A6
                bsr     print

                st      use_vbl
;                movea.l D0,A6
;                bsr     print
no_tim_sndh2:   move.l  #'MuMo',D0
                bsr     search_sndh
                beq.s   no_tim_sndh3

                lea     mumo_text(PC),A6
                bsr     print

                st      musicmon
no_tim_sndh3:   bra     no_sndh

search_sndh:    movea.l sound,A5
                move.w  #MAX_HEADER-1,D7
                move.l  (A5)+,D1
_search_sndh:   cmp.l   D0,D1
                beq.s   wow2
                lsl.l   #8,D1
                move.b  (A5)+,D1
                dbra    D7,_search_sndh
                moveq   #0,D0
                rts
wow2:           move.l  A5,D0
                rts

search_sndh_w:  movea.l sound,A5
                move.w  #MAX_HEADER-1,D7
                move.w  (A5)+,D1
_search_sndh_w: cmp.w   D0,D1
                beq.s   wow_w
                lsl.w   #8,D1
                move.b  (A5)+,D1
                dbra    D7,_search_sndh_w
                moveq   #0,D0
                rts
wow_w:          move.b  (A5)+,D0
                lsl.w   #8,D0
                move.b  (A5)+,D0
                rts

composer:       DC.B 'Composer:   ',0
title:          DC.B 13,10,'Title:      ',0
ripp:           DC.B 13,10,'Ripped:     ',0
conversion:     DC.B 13,10,'Conversion: ',0
songs:          DC.B 13,10,'Songs:      '
anz:            DC.B 'xx',13,10,13,10,0
mumo_text:      DC.B 'MusicMon Mode: no volumeters.',13,10,0
vbl_mode:       DC.B 'VBL-Mode:   active (no Timer A, see manual)'
filler:         DC.B 13,10,13,10,0 ; } (ZWEI ZEILEN NICHT TRENNEN!!!).
                EVEN

print:          movem.l D0-D2/A0-A2,-(SP)
                pea     (A6)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                movem.l (SP)+,D0-D2/A0-A2
no_sndh:        rts
                ENDPART
ice_depack2:    >PART 'ICE Depacker'
;********************************************* Unpacking routine of PACK-ICE
; a0 = Adress of packed data
; "bsr" or "jsr" to ice_decrunch_2 with register a0 prepared.
                link    A3,#-120
                movem.l D0-A6,-(SP)
                lea     120(A0),A4
                movea.l A4,A6
                bsr     .getinfo
                cmpi.l  #'ICE!',D0
                bne     .not_packed
                bsr.s   .getinfo
                lea     -8(A0,D0.l),A5
                bsr.s   .getinfo
                move.l  D0,(SP)
                adda.l  D0,A6
                movea.l A6,A1

                moveq   #119,D0
.save:          move.b  -(A1),-(A3)
                dbra    D0,.save
                movea.l A6,A3
                move.b  -(A5),D7
                bsr.s   .normal_bytes
                movea.l A3,A5


                bsr     .get_1_bit
                bcc.s   .no_picture
                move.w  #$0F9F,D7
                bsr     .get_1_bit
                bcc.s   .ice_00
                moveq   #15,D0
                bsr     .get_d0_bits
                move.w  D1,D7
.ice_00:        moveq   #3,D6
.ice_01:        move.w  -(A3),D4
                moveq   #3,D5
.ice_02:        add.w   D4,D4
                addx.w  D0,D0
                add.w   D4,D4
                addx.w  D1,D1
                add.w   D4,D4
                addx.w  D2,D2
                add.w   D4,D4
                addx.w  D3,D3
                dbra    D5,.ice_02
                dbra    D6,.ice_01
                movem.w D0-D3,(A3)
                dbra    D7,.ice_00
.no_picture:
                movem.l (SP),D0-A3

.move:          move.b  (A4)+,(A0)+
                subq.l  #1,D0
                bne.s   .move
                moveq   #119,D0
.rest:          move.b  -(A3),-(A5)
                dbra    D0,.rest
.not_packed:
                movem.l (SP)+,D0-A6
                unlk    A3
                rts

.getinfo:       moveq   #3,D1
.getbytes:      lsl.l   #8,D0
                move.b  (A0)+,D0
                dbra    D1,.getbytes
                rts

.normal_bytes:
                bsr.s   .get_1_bit
                bcc.s   .test_if_end
                moveq   #0,D1
                bsr.s   .get_1_bit
                bcc.s   .copy_direkt
                lea     .direkt_tab+20(PC),A1
                moveq   #4,D3
.nextgb:        move.l  -(A1),D0
                bsr.s   .get_d0_bits
                swap    D0
                cmp.w   D0,D1
                dbne    D3,.nextgb
.no_more:       add.l   20(A1),D1
.copy_direkt:
                move.b  -(A5),-(A6)
                dbra    D1,.copy_direkt
.test_if_end:
                cmpa.l  A4,A6
                bgt.s   .strings
                rts

.get_1_bit:
                add.b   D7,D7
                bne.s   .bitfound
                move.b  -(A5),D7
                addx.b  D7,D7
.bitfound:
                rts

.get_d0_bits:
                moveq   #0,D1
.hole_bit_loop:
                add.b   D7,D7
                bne.s   .on_d0
                move.b  -(A5),D7
                addx.b  D7,D7
.on_d0:         addx.w  D1,D1
                dbra    D0,.hole_bit_loop
                rts


.strings:       lea     .length_tab(PC),A1
                moveq   #3,D2
.get_length_bit:
                bsr.s   .get_1_bit
                dbcc    D2,.get_length_bit
.no_length_bit:
                moveq   #0,D4
                moveq   #0,D1
                move.b  1(A1,D2.w),D0
                ext.w   D0
                bmi.s   .no_Åber
.get_Åber:
                bsr.s   .get_d0_bits
.no_Åber:       move.b  6(A1,D2.w),D4
                add.w   D1,D4
                beq.s   .get_offset_2


                lea     .more_offset(PC),A1
                moveq   #1,D2
.getoffs:       bsr.s   .get_1_bit
                dbcc    D2,.getoffs
                moveq   #0,D1
                move.b  1(A1,D2.w),D0
                ext.w   D0
                bsr.s   .get_d0_bits
                add.w   D2,D2
                add.w   6(A1,D2.w),D1
                bpl.s   .depack_bytes
                sub.w   D4,D1
                bra.s   .depack_bytes


.get_offset_2:
                moveq   #0,D1
                moveq   #5,D0
                moveq   #-1,D2
                bsr.s   .get_1_bit
                bcc.s   .less_40
                moveq   #8,D0
                moveq   #$3F,D2
.less_40:       bsr.s   .get_d0_bits
                add.w   D2,D1

.depack_bytes:
                lea     2(A6,D4.w),A1
                adda.w  D1,A1
                move.b  -(A1),-(A6)
.dep_b:         move.b  -(A1),-(A6)
                dbra    D4,.dep_b
                bra     .normal_bytes


.direkt_tab:
                DC.L $7FFF000E,$FF0007,$070002,$030001,$030001
                DC.L 270-1,15-1,8-1,5-1,2-1

.length_tab:
                DC.B 9,1,0,-1,-1
                DC.B 8,4,2,1,0

.more_offset:
                DC.B 11,4,7,0   ; Bits lesen
                DC.W $011F,-1,$1F ; Standard Offset

ende_ice_decrunch_2:
;************************************************** end of unpacking routine
                ENDPART
starttxt:       >PART 'Texte, Strings'
;DC.B 27,'f',27,'E'
                DC.B 13,10
                DC.B 'Soundchipplayer v. 1.00 by BDCannibal/AURA (24.10.97).'
                DC.B 13,10,13,10
txt:            DC.B 'Playing File:   '
txt1:           DC.B 'XXXXXXXX.XXX',13,10
                DC.B 'Length:         '
txt2:           DC.B 'XXXXX',' Bytes',13,10,13,10,27,'f',27,'b9',0
enter_50hz:     DC.B 13,10,13,10,'    '
                DC.B '<PRESS KEY TO SWITCH TO 50HZ SCREENMODE AND START TUNE>'
                DC.B 0
                EVEN

vol0:           DC.B '[               ]',13,10,0
vol1:           DC.B '[*              ]',13,10,0
vol2:           DC.B '[**             ]',13,10,0
vol3:           DC.B '[***            ]',13,10,0
vol4:           DC.B '[****           ]',13,10,0
vol5:           DC.B '[*****          ]',13,10,0
vol6:           DC.B '[******         ]',13,10,0
vol7:           DC.B '[*******        ]',13,10,0
vol8:           DC.B '[********       ]',13,10,0
vol9:           DC.B '[*********      ]',13,10,0
vola:           DC.B '[**********     ]',13,10,0
volb:           DC.B '[***********    ]',13,10,0
volc:           DC.B '[************   ]',13,10,0
vold:           DC.B '[************',27,'b1','*  ',27,'b9',']',13,10,0
vole:           DC.B '[************',27,'b1','** ',27,'b9',']',13,10,0
volf:           DC.B '[************',27,'b1','***',27,'b9',']',13,10,0
curs_up:        DC.B 27,'A',27,'A',27,'A',0

fault1:         DC.B 27,'E','Datei nicht gefunden...',0
fault2:         DC.B 27,'E','Datei konnte nicht geîffnet werden...',0
fault3:         DC.B 27,'E','Datei konnte nicht korrekt gelesen werden...',0
fault5:         DC.B 27,'E','Fehler bei der Speicherreservierung...',0
ping:           DC.B 7,0
                ENDPART

***** FALCON 030 ROUTINEN *****
f030_shadow:    >PART 'Buserror-Shadowregs'
; =====================================================
; Program called py the CPU in case of BUS ERROR
; it will try to correct it if it's due to an acces
; to shadowed YM register(s)
; =====================================================
bus_error:      move    #$2700,SR       ; IPL 7
                move.l  D0,.sav_d0
                move.l  A0,.sav_a0

                moveq   #0,D0
                move.w  $0A(SP),D0      ; SSW
                btst    #8,D0           ; data/retry
                beq     .reprise        ; retry
                btst    #6,D0           ; read/write
                beq.s   .ecriture       ; write

.lecture:       bclr    #8,D0           ; will do a retry
                move.w  D0,$0A(SP)      ; change stack frame
                cmpi.w  #$FF88,$11(SP)  ; bits 8-23 = psg?
                bne.s   .no_psg_r       ; no => bye bye
                move.b  $FFFF8800.w,D0  ; read psg
                move.b  D0,$2C(SP)
                move.b  D0,$2D(SP)
                move.b  D0,$2E(SP)
                move.b  D0,$2F(SP)
                bra     .exit
.no_psg_r:      clr.l   $2C(SP)
                bra     .exit

.ecriture:      bclr    #8,D0
                move.w  D0,$0A(SP)
                cmpi.w  #$FF88,$11(SP)
                bne.s   .no_psg_w
                andi.b  #$02,$13(SP)
                bne.s   .ff8802
.ff8800:        andi.w  #$30,D0         ; oper size
                lsr.w   #4,D0
                beq.s   .size_13
                cmpi.w  #2,D0
                beq.s   .size_12
.size_11:       move.b  $1B(SP),$FFFF8800.w
                bra     .exit
.size_12:       move.b  $1A(SP),$FFFF8800.w
                bra     .exit
.size_13:                               ;move.l #$FC000000,$FFFF9800.w
                move.b  $18(SP),$FFFF8800.w
                move.b  $1A(SP),$FFFF8802.w
                bra     .exit

.ff8802:        andi.w  #$30,D0
                lsr.w   #4,D0
                beq.s   .size_23
                cmpi.w  #2,D0
                beq.s   .size_22
.size_21:       move.b  $1B(SP),$FFFF8802.w
                bra.s   .exit
.size_22:       move.b  $1A(SP),$FFFF8802.w
                bra.s   .exit
.size_23:       move.b  $18(SP),$FFFF8802.w
                move.b  $1A(SP),$FFFF8800.w
                bra.s   .exit

.no_psg_w:                              ;move.l #$FC000000,$FFFF9800.w
                bra.s   .exit

.reprise:       btst    #14,D0
                beq.s   .etageB
                btst    #15,D0
                beq.s   .etageC
                bra.s   .exit

.etageB:        bclr    #12,D0
                move.w  D0,$0A(SP)
                cmpi.w  #$0A,6(SP)      ; frame type A?
                bne.s   .frameBB
.frameBA:       movea.l 2(SP),A0
                move.l  A0,$0E(SP)
                bra.s   .exit
.frameBB:       movea.l $24(SP),A0
                move.w  -2(A0),$0E(SP)
                bra.s   .exit

.etageC:        bclr    #13,D0
                move.w  D0,$0A(SP)
                cmpi.w  #$0A,6(SP)
                bne.s   .frameCB
.frameCA:       movea.l 2(SP),A0
                move.w  2(A0),$0C(SP)
                bra.s   .exit
.frameCB:       movea.l $24(SP),A0
                move.w  -2(A0),$0C(SP)

.exit:          movea.l .sav_a0,A0
                move.l  .sav_d0,D0
                rte

.sav_d0:        DC.L 0
.sav_a0:        DC.L 0
                ENDPART
tst_cpu:        >PART 'Cookies lesen'
                movem.l D0-A6,-(SP)
                lea     cookies,A0
                bsr     get_system
                bpl.s   f030_tst
                moveq   #0,D0
                movem.l (SP)+,D0-A6
                rts
f030_tst:       cmpi.b  #20,_CPU+cookies ; Mindestens 030 (oder 020
                bge.s   _rts
                moveq   #0,D0
                movem.l (SP)+,D0-A6
                rts
_rts:           st      falcon
                moveq   #1,D0
                movem.l (SP)+,D0-A6
                rts
cookies:        DS.B 16
BUF_SIZE        EQU 16
_CPU            EQU 0           ; Prozessor
_VDO            EQU 1           ; Videosystem
_FDC            EQU 2           ; Floppycontroler
_SND            EQU 3           ; Soundsystem
_MCH            EQU 4           ; Machine
_FPU            EQU 5           ; Floating Point Unit
MINT            EQU 6           ; Mint
_COD            EQU 7           ; Codec
_DSP            EQU 8           ; DSP
_16D            EQU 9           ; 16-Bit Samplesound
_YAM            EQU 10          ; Yamaha
_MON            EQU 11          ; Monitortyp

; a0.l - Pointer auf Struktur.
get_system:     movem.l D0-A6,-(SP)

                move.l  $05A0.w,D0      ; Cookiebase
                bne.s   tos_1_6         ; das waren noch Tage...

                moveq   #-1,D0          ; Z-Bit lîschen
                movem.l (SP)+,D0-A6
                rts

tos_1_6:        movea.l D0,A1

                movea.l A0,A2
                moveq   #BUF_SIZE-1,D7
clr_buf:        clr.b   (A2)+
                dbra    D7,clr_buf

search_cook:    movem.l (A1)+,D0/D6
                tst.l   D0
                beq     ende_liste

                lea     ref_liste(PC),A5
                move.w  (A5)+,D7        ; Anzahl Referenzcookies.
chk_entry:      move.l  (A5)+,D1        ; Name
                move.w  (A5)+,D2        ; relativer Sprungoffset
                cmp.l   D1,D0
                dbeq    D7,chk_entry

                tst.w   D7              ; Referenz gefunden ?
                bmi.s   search_cook
; Data in d6.l
                lea     base(PC),A6
                jsr     0(A6,D2.w)
                bra.s   search_cook     ; NÑchsten Keks

ende_liste:                             ; Monitor egal
                moveq   #0,D0           ; Z-Bit setzen
                movem.l (SP)+,D0-A6
                rts

ref_liste:      DC.W 7-1        ; 7 untersuchte EintrÑge.

                DC.L '_CPU'     ; Prozessor
                DC.W __cpu-base
                DC.L '_VDO'     ; Videosystem
                DC.W __vdo-base
                DC.L '_FDC'     ; Floppy
                DC.W __fdc-base
                DC.L '_SND'     ; Sound
                DC.W __snd-base
                DC.L '_MCH'     ; Kiste
                DC.W __mch-base
                DC.L '_FPU'     ; Coproz
                DC.W __fpu-base
                DC.L 'MiNT'     ; MiNT
                DC.W __mint-base

base:
__cpu:          move.b  D6,_CPU(A0)     ; CPU-Typ Åbernehmen.
                rts
__vdo:          swap    D6              ; Bit 16/17 nach unten.
                move.b  D6,_VDO(A0)
                rts
__fdc:          move.l  D0,-(SP)
                move.l  D6,D0
                andi.l  #$FFFFFF,D0
                swap    D6
                lsr.b   #4,D6           ; Diskettenformat
                cmpi.l  #'ATC',D0       ; Kompatibler Controller ?
                bne.s   no_com_fdc
                bset    #7,D6           ; Bit 7 setzen.
no_com_fdc:     move.b  D6,_FDC(A0)
                move.l  (SP)+,D0
                rts
__snd:          btst    #4,D6
                sne     _COD(A0)        ; Codec ?
                btst    #3,D6
                sne     _DSP(A0)        ; DSP ?
                btst    #2,D6
                sne     _16D(A0)        ; 16 Bit DMA ?
                btst    #0,D6
                sne     _YAM(A0)        ; Yamaha ?
                rts
__mch:          swap    D6              ; Maschine: STE kompat. werden ignor.
                move.b  D6,_MCH(A0)
                rts
__fpu:          swap    D6
                move.b  D6,_FPU(A0)
                rts
__mint:         st      MINT(A0)
                rts
                ENDPART
set_vadr:       >PART 'Screenadresse setzen (in d0.l)'
                move.l  D1,-(SP)
                move.b  D0,D1
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                move.b  D1,$FFFF820D.w
                move.l  (SP)+,D1
                rts
                ENDPART
f030_prep_screen:
                >PART 'Screenprepare F030'
                IFNE FALCON
                move.l  #screen+256,D0
                clr.b   D0
                movea.l D0,A0
                movea.l A0,A6

                move.w  #112*640/4-1,D0
                moveq   #0,D1
fclr_lp:        move.l  D1,(A0)+
                dbra    D0,fclr_lp

                moveq   #32-1,D7
                moveq   #0,D0
loopf1:         move.w  #320/2*4-1,D6
loopf2:         move.l  D0,(A0)+
                dbra    D6,loopf2
                addi.l  #%10000000000000001,D0
                dbra    D7,loopf1

                lea     _font(PC),A0
                lea     font,A1
                bsr     conv_fnt_4t

                lea     640*20(A6),A6
                movea.l A6,A0

                lea     10*640+168(A0),A0
                lea     ftxt(PC),A1
                lea     font,A2
                bsr     write_t_str

                lea     25*640+168(A6),A0
                lea     ftxt2(PC),A1
                lea     font,A2
                bsr     write_t_str

                moveq   #FALCON_COOL,D0
                tst.w   D0
                bne.s   no_3

                lea     40*640+168(A6),A0
                lea     ftxt3(PC),A1
                lea     font,A2
                bra     write_t_str

no_3:           lea     44*640(A6),A0   ; Dateinamen gespielte Datei ausgeben.

                lea     filename,A1     ; LÑnge des Dateinamens.
                movea.l A1,A6
                moveq   #0,D0
length:         addq.w  #1,D0
                move.b  (A1)+,D1
                beq.s   got_length

                cmp.b   #'a',D1         ; Klein- in Groûbuchstaben wandeln.
                blt.s   no_small
                cmp.b   #'z',D1
                bgt.s   no_small
                addi.b  #'A'-'a',D1
no_small:       move.b  D1,-1(A1)

                cmp.b   #'\',D1         ; Pfad? Nur Filenamen gewollt.
                bne.s   length

                movea.l A1,A6
                clr.w   D0
                bra.s   length

got_length:     subq.w  #1,D0
                moveq   #40,D1          ; Dateistring zentrieren.
                sub.w   D0,D1
                ble     _rts

                moveq   #0,D2           ; Offset falls ungerade Anzahl...
                bclr    #0,D1
                beq.s   ok
                moveq   #8,D2

ok:             lsl.w   #3,D1
                ext.l   D1
                add.l   D2,D1
                adda.l  D1,A0

                movea.l A6,A1
                lea     font,A2
                bra     write_t_str

ftxt:           DC.B "MAD PLAYER  V. 1.00",0
ftxt2:          DC.B "  BY JOCHEN KNAUS",0
ftxt3:          DC.B "    (50HZ MODE)",0
                EVEN

;   /// Font Konvertierung    ///
;  /// a0.l - Adresse Urfont ///
; /// a1.l - Zielbuffer     ///
f_high          EQU 8
f_col           EQU $FFFF       ; Farbe, die der Font dann haben soll.
conv_fnt_4t:    movem.l D0-A6,-(SP)     ; 4 Planes -> High-Colour
                lea     fcolours,A3
                moveq   #0,D3

                moveq   #1,D4           ; 2 Buchstabenreihen
con_reihe:      moveq   #19,D7          ; 40 Zeichen / Zeile
con_char:       moveq   #f_high-1,D6
                movea.l A0,A2
con_zeile:      move.b  (A2)+,D0
                move.b  (A2)+,D1

                move.w  #0,D2           ; Hintergrundfarbe

                moveq   #7,D5           ; alle 8 Bits durchkauen
kauen:          move.w  D2,f_high*8*2(A1)
                btst    D5,D1           ; Buchstaben 2
                beq.s   no_set2

                add.w   D3,D3
                move.w  0(A3,D3.w),f_high*8*2(A1)
                lsr.w   #1,D3           ; --> ST again

                addq.w  #1,D3
                andi.w  #31,D3
no_set2:        move.w  D2,(A1)+
                btst    D5,D0
                beq.s   no_set1

                add.w   D3,D3
                move.w  0(A3,D3.w),-2(A1)
                lsr.w   #1,D3

                addq.w  #1,D3
                andi.w  #31,D3
no_set1:        dbra    D5,kauen

                lea     160-8+6(A2),A2
                dbra    D6,con_zeile

                addq.l  #8,A0
                lea     f_high*8*2(A1),A1
                dbra    D7,con_char

                lea     160*8(A0),A0    ; nÑchste Fontreihe
                dbra    D4,con_reihe

                movem.l (SP)+,D0-A6
                rts


; //////////////////////        *** Stringausgabe ***
; a0 - Bildschirmadresse (Basis 640 Bytes/Scan)
; a1 - Stringadresse
; a2 - Fontadresse
; //////////////////////
sonder:         DC.W 11-1       ; Sonderzeichenadressen im Font
                DC.W '0',35
                DC.W '.',36
                DC.W '!',37
                DC.W '?',38
                DC.W ',',39
                DC.W '(',40
                DC.W ')',41
                DC.W '|',42
                DC.W ' ',43
                DC.W '#',44
                DC.W '_',36

write_t_str:    movem.l D0-A6,-(SP)

                lea     sonder,A6       ; Sonderzeichen ?
do_char:        moveq   #0,D0
                move.b  (A1)+,D0
                beq     end_str

                movea.l A6,A5
                move.w  (A5)+,D7        ; Anzahl Sonderzeichen (-1)
chk_sonder:     cmp.w   (A5)+,D0
                bne.s   chk_next

                move.w  (A5)+,D0
                bra.s   get_adr

chk_next:       addq.l  #2,A5
                dbra    D7,chk_sonder

                cmp.b   #'A',D0         ; Normales Textzeichen
                bge.s   chk_char

                sub.b   #'1',D0
                bmi     end_str         ; Error
                cmp.b   #'9',D0
                bgt     end_str         ; Error

                add.w   #26,D0          ; Numeric-Base
                bra.s   get_adr

chk_char:       sub.b   #'A',D0
                cmp.b   #'Z',D0
                bgt     end_str         ; Error

get_adr:        mulu    #f_high*8*2,D0
                lea     0(A2,D0.l),A3   ; Buchstabengfx
                movea.l A0,A4

                movem.l (A3)+,D0-D7     ; 2 Zeilen Buchstaben holen
                movem.l D0-D3,(A4)      ; Zeile 1
                movem.l D4-D7,640(A4)   ; Zeile 2
                lea     1280(A4),A4
                movem.l (A3)+,D0-D7     ; 2 Zeilen Buchstaben holen
                movem.l D0-D3,(A4)      ; Zeile 1
                movem.l D4-D7,640(A4)   ; Zeile 2
                lea     1280(A4),A4
                movem.l (A3)+,D0-D7     ; 2 Zeilen Buchstaben holen
                movem.l D0-D3,(A4)      ; Zeile 1
                movem.l D4-D7,640(A4)   ; Zeile 2
                lea     1280(A4),A4
                movem.l (A3)+,D0-D7     ; 2 Zeilen Buchstaben holen
                movem.l D0-D3,(A4)      ; Zeile 1
                movem.l D4-D7,640(A4)   ; Zeile 2
                lea     1280(A4),A4

                lea     8*2(A0),A0
                bra     do_char

end_str:        movem.l (SP)+,D0-A6
                rts

; Die Fontadressen der Hex-Zahlen (fÅr Infoausgabe)
hex:            DC.W 35
                DC.W 26,27,28,29,30,31,32,33,34
                DC.W 0,1,2,3,4,5,6

fcolours:       DS.W 32,$FFFF   ; Fontfarben (rotieren)
                DC.W $E230,$4E2F,$123D,$6545,$1257,$4512,$1214,$9431
                DC.W $0A24,$40F7,$45D0,$7809,$4504,$1247,$65F1,$4512
                DC.W $89A2,$299C,$4D15,$1F87,$1542,$6599,$A831,$9D40
                DC.W $1A22,$2C55,$D2C8,$A1B1,$BE0C,$5C21,$1B16,$52C2

                PATH 'F:\SOURCES.030\MADPLAY\'
_font:          IBYTES 'FONT88.IMG'
                ENDC
                ENDPART

falcon:         DC.B 0
use_vbl:        DC.B 0          ; VBL benutzen ?
musicmon:       DC.B 0          ; Musicmon Mode (Timer & Extraspeicher...)
                EVEN
anz_songs:      DC.W 0

                IFNE FALCON     ; Falcon Volumeter
fvolgfx:        IBYTES 'F:\PLASMA.16B'
                ENDC

                BSS
                EVEN
vol:            DS.W 2
counter:        DS.W 1
resident:       DS.L 1
backgrd:        DS.B 2
saver:          DS.L 200
filename:       DS.B 258
save_vid:       DS.B 100
dta:            DS.B 44
graf:           DS.L 1
sound:          DS.L 1
                IFNE FALCON
font:           DS.B 640*32
screen:         DS.B 320*2*240+256
                ENDC
                END
