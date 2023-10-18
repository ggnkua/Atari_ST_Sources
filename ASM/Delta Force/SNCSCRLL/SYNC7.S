; Syncscrolling in 7 Scanlines
; written by New Mode
; for TOS-Magazine
; (Version fÅr Devpac Assembler)


                OPT X+          ; Erweiterte Symboltable anschalten

                SECTION TEXT

                pea     start(PC)
                move.w  #38,-(A7)            ; Supexec
                trap    #14
                addq.l  #6,A7

                clr.w   -(A7)
                trap    #1

start:
                lea     bss_start,A0
                lea     bss_ende,A1
                moveq   #0,D0
clear_bss:      move.l  D0,(A0)+
                cmpa.l  A0,A1
                bge.s   clear_bss

                move.l  A7,oldstack
                move    SR,old_sr
                ori     #$0700,SR            ; alle IRQ's sperren

                lea     stack,A7             ; eigenen Stack setzen

                bsr     install_all          ; alles initialisieren

                bsr     init_sync_scrolling

                lea     picture,A0
                movea.l screen_1(PC),A1
                move.w  #(32000/4-1),D0
copy_pic:       move.l  (A0)+,(A1)+
                dbra    D0,copy_pic


                move.l  #vbl,$70.w

                clr.b   key

wait:

                cmpi.b  #$4d,key             ; Cursor rechts?
                bne.s   not_right
                addq.l  #8,screen_1
                bra.s   ready
not_right:
                cmpi.b  #$4b,key             ; Cursor links?
                bne.s   not_left
                subq.l  #8,screen_1
                bra.s   ready
not_left:
                cmpi.b  #$48,key             ; Cursor hoch?
                bne.s   not_up
                subi.l  #160,screen_1
                bra.s   ready
not_up:
                cmpi.b  #$50,key             ; Cursor runter?
                bne.s   not_down
                addi.l  #160,screen_1
                bra.s   ready

not_down:       cmpi.b  #$4e,key             ; + auf Num. Keypad?
                bne.s   not_up2
                addq.l  #2,screen_1
                bra.s   ready
not_up2:
                cmpi.b  #$4a,key             ; - auf Zahlenblock?
                bne.s   not_down2
                subq.l  #2,screen_1

ready:
                bsr     vsync
                tst.w   key_repeat
                bne.s   not_down2
                clr.b   key


not_down2:
                cmpi.b  #$1c,key             ; Return
                bne.s   not_return
                eori.w  #-1,key_repeat
                clr.b   key
not_return:
                cmpi.b  #$62,key             ; Help?
                bne.s   not_help

                clr.b   key
                bsr     show_help


not_help:       cmpi.b  #$39,key             ; Space gedrÅckt?
                bne     wait

ende:

                bsr     restore_all          ; alles zurÅcksetzen

                movea.l oldstack,A7          ; alten Stack setzen
                move    old_sr,SR
                rts

;-----------------------------------------------------------------------------

install_all:
; Initialisiert alle Hardware-Register

                move.b  $ffff820a.w,oldsync
                move.b  $ffff8260.w,oldres

                movem.l $ffff8240.w,D0-D7
                movem.l D0-D7,oldpalette

                lea     $ffff8240.w,A0
                moveq   #7,D0
clrpal:         clr.l   (A0)+
                dbra    D0,clrpal

                lea     $ffff8201.w,A0       ; Screenadresse holen
                movep.w 0(A0),D0
                move.w  D0,oldscreen

                move.l  #screen_base,D0
                and.l   #-256,D0             ; untere 8 Bits weg
                move.l  D0,screen_1
                movea.l D0,A0
                add.l   #200*160,D0
                move.l  D0,screen_2
                movea.l D0,A1

                move.w  #(200*40)-1,D0       ; beide Screens lîschen
clr_screens:    clr.l   (A0)+
                clr.l   (A1)+
                dbra    D0,clr_screens

                move.l  screen_1(PC),D0
                bsr     set_screen

                bsr     init_mfp

                move    #$2300,SR            ; IRQ's an

                moveq   #$12,D0              ; Maus aus
                bsr.s   send_ikbd

                bsr     vsync
                move.b  #2,$ffff820a.w       ; 50 Hz

                bsr     vsync
                clr.b   $ffff8260.w          ; Lowres

                movem.l palette(PC),D0-D7
                movem.l D0-D7,$ffff8240.w

                rts


restore_all:
; alle Hardware-Register werden wieder so gesetzt wie am Anfang

                move.l  #start_vbl,$70.w
                bsr.s   vsync

                movem.l oldpalette,D0-D7
                movem.l D0-D7,$ffff8240.w

                bsr.s   vsync
                move.b  #2,$ffff820a.w       ; 50Hz

                bsr.s   vsync
                move.b  #0,$ffff820a.w       ; 60Hz (damit Syncerrors beheben)

                bsr.s   vsync
                move.b  oldsync,$ffff820a.w  ; alte Sync. und Res. zurÅck
                move.b  oldres,$ffff8260.w

                bsr     restore_mfp

                moveq   #$08,D0              ; Maus wieder ein
                bsr.s   send_ikbd

                move.w  oldscreen,D0
                lea     $ffff8201.w,A0
                movep.w D0,0(A0)             ; alte Screenadresse setzen

                rts

send_ikbd:
; sendet Byte aus d0 an IKBD
                lea     $fffffc00.w,A0
waitkeyready:   btst    #1,(A0)
                beq.s   waitkeyready
                move.b  D0,2(A0)
                rts

vsync:          lea     vsync_count,A0
                move.l  (A0),D0
wait_strahl:    cmp.l   (A0),D0
                beq.s   wait_strahl
                rts

init_mfp:
; rettet und setzt alle IRQ's

                move    SR,-(A7)
                ori     #$0700,SR
                move.l  $0118.w,oldkey
                move.l  $0120.w,oldtimerb
                move.l  $70.w,oldvbl
                move.l  $68.w,oldhbl
                lea     $fffffa00.w,A0       ; MFP
                move.b  $07(A0),oldmfp07
                move.b  $09(A0),oldmfp09
                move.b  $11(A0),oldmfp11
                move.b  $13(A0),oldmfp13
                move.b  $15(A0),oldmfp15
                move.b  $17(A0),oldmfp17
                move.b  $1b(A0),oldmfp1b
                move.b  $21(A0),oldmfp21
                clr.b   $07(A0)              ; alle IRQ's aus
                clr.b   $09(A0)
                clr.b   $13(A0)
                clr.b   $15(A0)
                bset    #0,$07(A0)           ; Timer B erlauben
                bset    #0,$13(A0)
                bset    #6,$09(A0)           ; Tastatur IRQ erlauben
                bset    #6,$15(A0)
                bclr    #3,$17(A0)           ; Automatic EOI

                move.l  #newkey,$0118.w
                move.l  #start_vbl,$70.w     ; am Anfang (zum Initialisieren)
                move.l  #timer_b,$0120.w

                move.b  #$03,$fffffc00.w     ; ACIA-Init
                move.b  #$96,$fffffc00.w

                move    (A7)+,SR

                rts

restore_mfp:
; setzt alle MFP-Register wieder zurÅck

                move    SR,-(A7)
                ori     #$0700,SR
                move.l  oldkey,$0118.w
                move.l  oldtimerb,$0120.w
                move.l  oldvbl,$70.w
                move.l  oldhbl,$68.w
                lea     $fffffa00.w,A0       ; MFP
                move.b  oldmfp07,$07(A0)
                move.b  oldmfp09,$09(A0)
                move.b  oldmfp11,$11(A0)
                move.b  oldmfp13,$13(A0)
                move.b  oldmfp15,$15(A0)
                move.b  oldmfp17,$17(A0)
                move.b  oldmfp1b,$1b(A0)
                move.b  oldmfp21,$21(A0)

                move.b  #$03,$fffffc00.w     ; ACIA-Init
                move.b  #$96,$fffffc00.w

                move    (A7)+,SR
                rts

start_vbl:      clr.b   $fffffa1b.w          ; Timer B aus
                addq.l  #1,vsync_count
                rte

;------------------------------------------------------------------------------

show_help:
; gibt Lowbyte und aktuelle Syncroutinen auf Screen aus.

                move.l  screen_1(PC),D0
                move.l  screen_2(PC),screen_1
                move.l  D0,screen_2


                lea     zahlen_grafik(PC),A0
                movea.l screen_1(PC),A1
                lea     50*160+6(A1),A1

                and.l   #255,D0              ; Lowbyte holen

                move.l  D0,D1
                divu    #100,D1
                add.w   D1,D1
                lea     0(A0,D1.w),A2
                bsr     copy_char
                lea     8(A1),A1

                clr.w   D1
                swap    D1
                divu    #10,D1
                add.w   D1,D1
                lea     0(A0,D1.w),A2
                bsr     copy_char
                lea     8(A1),A1

                swap    D1
                add.w   D1,D1
                lea     0(A0,D1.w),A2
                bsr     copy_char

                lsr.w   #1,D0                ; Lowbyte
                lsl.w   #5,D0                ; *8*4
                lea     sync_pointer_tab(PC),A0
                adda.w  D0,A0
                movea.l screen_1(PC),A1
                lea     70*160+4(A1),A1
                moveq   #6,D0                ; 7 Zeilen hinkopieren

copy_routs:     move.l  (A0)+,D1             ; Routine
                cmp.l   #sync_routine0,D1
                bne.s   not_sync_r0
                moveq   #0,D2
not_sync_r0:
                cmp.l   #sync_routine1,D1
                bne.s   not_sync_r1
                moveq   #2,D2
not_sync_r1:
                cmp.l   #sync_routine2,D1
                bne.s   not_sync_r2
                moveq   #4,D2
not_sync_r2:
                cmp.l   #sync_routine3,D1
                bne.s   not_sync_r3
                moveq   #6,D2
not_sync_r3:
                cmp.l   #sync_routine4,D1
                bne.s   not_sync_r4
                moveq   #8,D2
not_sync_r4:
                cmp.l   #sync_routine5,D1
                bne.s   not_sync_r5
                moveq   #10,D2
not_sync_r5:
                lea     zahlen_grafik(PC),A2
                adda.w  D2,A2
                bsr     copy_char

                lea     8*160(A1),A1
                dbra    D0,copy_routs



                clr.b   key
wait_space:     tst.b   key
                beq.s   wait_space
                clr.b   key

                movea.l screen_1(PC),A0
                move.w  #7999,D0
cls:            clr.l   (A0)+
                dbra    D0,cls

                move.l  screen_1(PC),D0
                move.l  screen_2(PC),screen_1
                move.l  D0,screen_2

                rts



copy_char:
off             SET 0
off2            SET 0
                REPT 7
                move.w  off2(A2),off(A1)
off2            SET off2+20
off             SET off+160
                ENDR
                rts


vbl:
                move.l  #open_top,$68.w
                move.w  #32,hbl_count

                addq.l  #1,vsync_count

                andi.w  #$f9ff,(A7)          ; HBL zulassen
                rte

; --------- **** 7UP-SYNC SCROLLING **** -----------------------------------
;
;       BY NEW MODE OF DELTA FORCE/THE UNION
;


hbl_count:      DC.W 32

open_top:       subq.w  #1,hbl_count         ; solange, bis Zeile erreicht
                bmi.s   hbl_is_da
                rte


hbl_is_da:      move.l  #open_top_2,$68.w
waithere:       stop    #$2100
                bra.s   waithere

open_top_2:
; klappt den oberen Rand auf

                move    #$2700,SR

                addq.l  #6,A7                ; Stack korrigieren

                movem.l D0-A6,-(A7)          ; alle Register retten

                DCB.W 56,$4e71

                move.b  #0,$ffff820a.w       ; 60 Hz

                DCB.W 17,$4e71

                move.b  #2,$ffff820a.w       ; 50 Hz

                movea.l sync_pointer1(PC),A0
                lea     $ffff8209.w,A2
                lea     $ffff820a.w,A3
                lea     $ffff8260.w,A4
                moveq   #0,D0
                moveq   #2,D1
                moveq   #0,D3
wait_sync2:     move.b  (A2),D3
                cmp.w   #64,D3
                blt.s   wait_sync2
                sub.w   #64,D3
                not.w   D3
                lsr.w   D3,D3

                DCB.W 38-5,$4e71

                movea.l (A0)+,A1             ; Routine aus Tabelle holen
                jmp     (A1)                 ; und diese anspringen


end_sync:
                move.l  screen_1(PC),D0
                bsr     set_screen


                movem.l (A7)+,D0-A6
                ori.w   #$0300,(A7)          ; SR auf $2300 setzen
                rte

set_screen:
; in d0 = Screenadresse
; stellt Lowbyte durch Syncscrolling dar
                move.l  sync_pointer1(PC),D1 ; Pointer tauschen
                move.l  sync_pointer2(PC),sync_pointer1
                move.l  D1,sync_pointer2

                move.l  D0,D1
                and.w   #255,D1              ; nur untere 8 Bits
                lea     sync_pointer_tab(PC),A0 ; dort sind Routinen
                lsr.w   #1,D1                ; durch 2 -> 0-127
                move.w  D1,D2
                lsl.w   #5,D1                ; *32 (8 Longs)
                adda.w  D1,A0
                move.l  A0,sync_pointer1
                lea     sync_offset_tab(PC),A0
                lsl.w   #2,D2                ; *4 (wegen Longs)
                add.l   0(A0,D2.w),D0        ; Offset auf Screen addieren
                lsr.l   #8,D0
                lea     $ffff8201.w,A0       ; Screen setzen (Mid- und Highbyte)
                movep.w D0,0(A0)
                rts


; Hier sind die Routinen, die die RÑnder aufmachen

sync_routine1:
; klappt beide RÑnder auf.
; braucht 70 Bytes
                move.b  D1,(A4)              ; Highres
                nop
                move.b  D0,(A4)              ; Lowres (Links auf)

                DCB.W 89,$4e71

                move.b  D0,(A3)              ; 60Hz
                move.b  D1,(A3)              ; 50Hz (Rechts auf)

                DCB.W 13,$4e71

                move.b  D1,(A4)              ; Highres
                nop
                move.b  D0,(A4)              ; Lowres (Rechts zu)

                DCB.W 12-5,$4e71
                movea.l (A0)+,A1             ; nÑchste Routine holen (12)
                jmp     (A1)                 ; und die anspringen    (8)


sync_routine2:
; klappt nur linken Rand auf
; braucht 26 Bytes


                move.b  D1,(A4)              ; Highres
                nop
                move.b  D0,(A4)              ; Lowres (Links auf)

                DCB.W 89,$4e71

                move.b  D1,(A3)              ; 50Hz
                move.b  D1,(A3)              ; 50Hz (nur Dummy)

                DCB.W 13,$4e71

                move.b  D1,(A4)              ; Highres
                nop
                move.b  D0,(A4)              ; Lowres (Rechts "zu")

                DCB.W 12-5,$4e71
                movea.l (A0)+,A1             ; nÑchste Routine holen (12)
                jmp     (A1)                 ; und die anspringen    (8)


sync_routine3:
; klappt linken Rand auf und schneidet 2 Bytes ab.
; braucht 24 Bytes

                move.b  D1,(A4)              ; Highres
                nop
                move.b  D0,(A4)              ; Lowres (Links auf)

                DCB.W 88,$4e71   ; ein NOP zu frÅh!

                move.b  D0,(A3)              ; 60Hz
                move.b  D1,(A3)              ; 50Hz (Rechts auf)

                DCB.W 14,$4e71

                move.b  D1,(A4)              ; Highres
                nop
                move.b  D0,(A4)              ; Lowres (Rechts zu)
                DCB.W 12-5,$4e71
                movea.l (A0)+,A1             ; nÑchste Routine holen (12)
                jmp     (A1)                 ; und die anspringen    (8)



sync_routine4:
; klappt rechten Rand auf und schneidet 2 Bytes ab.
; braucht -2 Bytes

                move.b  D0,(A4)              ; Lowres (Dummy)
                nop
                move.b  D0,(A4)              ; Lowres ("Links auf")

                DCB.W 88,$4e71   ; ein NOP zu frÅh!

                move.b  D0,(A3)              ; 60Hz
                move.b  D1,(A3)              ; 50Hz (Rechts auf)

                DCB.W 14,$4e71

                move.b  D1,(A4)              ; Highres
                nop
                move.b  D0,(A4)              ; Lowres (Rechts zu)

                DCB.W 12-5,$4e71
                movea.l (A0)+,A1             ; nÑchste Routine holen (12)
                jmp     (A1)                 ; und die anspringen    (8)



sync_routine5:
; Nur rechten Rand aufmachen
; stellt 44 Bytes dar

                move.b  D0,(A4)              ; Lowres (Dummy)
                nop
                move.b  D0,(A4)              ; Lowres ("Links auf")

                DCB.W 89,$4e71

                move.b  D0,(A3)              ; 60Hz
                move.b  D1,(A3)              ; 50Hz (Rechts auf)

                DCB.W 13,$4e71

                move.b  D1,(A4)              ; Highres
                nop
                move.b  D0,(A4)              ; Lowres (Rechts zu)

                DCB.W 12-5,$4e71

                movea.l (A0)+,A1             ; nÑchste Routine holen (12)
                jmp     (A1)                 ; und die anspringen    (8)

sync_routine0:
; macht 512 TZ lang nichts

                DCB.W 116,$4e71

                DCB.W 12-5,$4e71
                movea.l (A0)+,A1             ; nÑchste Routine holen (12)
                jmp     (A1)                 ; und die anspringen    (8)

init_sync_scrolling:
; generelle Initialisierungsroutine

                bsr.s   get_anzahl_zeilen    ; ermitteln, wieviel Scanlines dargestellt werden
                bsr     create_tabellen      ; Tabellen aufbauen
                rts

create_tabellen:
; erstellt Pointertabellen fÅr Syncscrolling (im BSS)
                lea     sync_tabelle(PC),A0
                lea     sync_pointer_tab(PC),A1
                lea     sync_offset_tab(PC),A2
                lea     sync_routine_tab(PC),A3
                move.w  #(256/2)-1,D0        ; 128 Werte (2er Syncscrolling)
createtabloop0: moveq   #6,D1                ; 7 Routinen
createtabloop1: moveq   #0,D2
                move.b  (A0)+,D2             ; Wert von 0-5 holen
                lsl.w   #2,D2                ; *4 wegen Longs
                move.l  0(A3,D2.w),(A1)+     ; Routine in Pointertab ablegen
                dbra    D1,createtabloop1
                move.l  #end_sync,(A1)+      ; Letzte Routine immer dazu
                move.b  (A0)+,D2             ; Offsetwert holen
                beq.s   is_off0
                bpl.s   is_off1
                move.l  #-256,(A2)+          ; jeweiligen Offset setzen
                bra.s   off_ok
is_off0:        clr.l   (A2)+
                bra.s   off_ok
is_off1:        move.l  #256,(A2)+
off_ok:         dbra    D0,createtabloop0
                rts




sync_routine_tab:
; Hier stehen die mîglichen Routinen drin.
; Wird zum Berechnen benîtigt

                DC.L sync_routine0
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine3
                DC.L sync_routine4
                DC.L sync_routine5



get_anzahl_zeilen:
; Routine ermittelt die MMU des ST's, d.h. wieviele Zeilen dargestellt werden
; (wenn oberer Rand auf ist)

                move    #$2700,SR
                move.l  $70.w,-(A7)          ; VBL und HBL retten
                move.l  $68.w,-(A7)

                move.l  #test_vbl,$70.w
                move.l  #test_hbl1,$68.w
                move.w  #340,hbl_count       ; Wert sehr hoch setzen

                move    #$2300,SR
                bsr     vsync

                clr.b   $fffffa1b.w
                move.b  #255,$fffffa21.w
                move.b  #8,$fffffa1b.w       ; Timer B start

                move.b  $ffff8209.w,D0
wait_lowbyte:   cmp.b   $ffff8209.w,D0
                beq.s   wait_lowbyte

                moveq   #0,D1
wait_loop:      addq.w  #1,D1
                cmp.w   #5,D1
                bgt.s   wait_ready
                move.b  $ffff8209.w,D0
                cmp.b   $ffff8209.w,D0
                beq.s   wait_loop
                moveq   #0,D1
                bra.s   wait_loop
wait_ready:     move.w  #255,D0
                sub.b   $fffffa21.w,D0       ; aktuelle ZÑhler abziehen
                move.w  D0,anzahl_zeilen
                bsr     vsync

                move    #$2700,SR

                move.l  (A7)+,$68.w
                move.l  (A7)+,$70.w
                move    #$2300,SR
                rts

test_vbl:       move.w  #32,hbl_count        ; dort oberen Rand aufmachen
                move.l  #test_hbl1,$68.w     ; HBL Routine
                addq.l  #1,vsync_count
                andi.w  #$f1ff,(A7)          ; HBL erlauben (SR auf $2100)
                rte

test_hbl1:      subq.w  #1,hbl_count
                bmi.s   test_hbl2
                rte
test_hbl2:      move.l  #test_hbl3,$68.w     ; neuen HBL setzen
wait_for_hbl:   stop    #$2100               ; warten bis HBL da!
                bra.s   wait_for_hbl

test_hbl3:      move    #$2700,SR            ; alle IRQ's aus
                addq.l  #6,A7                ; Stack korrigieren
                DCB.W 89,$4e71
                move.b  #0,$ffff820a.w       ; 60 Hz
                DCB.W 17,$4e71
                move.b  #2,$ffff820a.w       ; 50 Hz
                ori.w   #$0300,(A7)          ; SR auf $2300
                rte

anzahl_zeilen:  DC.W 0



sync_pointer1:  DC.L sync_pointer_tab ; auf Routine "0" zeigen
sync_pointer2:  DC.L sync_pointer_tab

sync_offset_tab:
; Hier kommen die jeweiligen Offsets fÅr die Syncoffsets rein
; (256, -256 oder 0)
; kann ins BSS kommen
; Hier fÅr 2er Lowbytes

                DS.L 256/2

sync_pointer_tab:
                DS.L 256/2*8
; kann ins BSS kommen. Hier sind jeweils 8 Pointer auf die Routinen pro
; Offset (hier 2er Lowbytes mîglich)



sync_tabelle:
; eigentliche Tabelle mit jeweils 8 Bytes.
; davon 7 Bytes Randwerte (welche Routine 0-5).
; Achtes Byte: 0=Screenoffset 0, 1=Screenoffset 256, -1=Screenoffset -256
; Lowbyte mîglich in zwei Byte Schritten

                DC.B 0,0,0,0,0,0,0,0 ; 0
                DC.B 1,1,1,3,3,0,0,-1 ; 2
                DC.B 1,1,3,3,3,3,3,-1 ; 4
                DC.B 4,5,5,5,5,5,5,-1 ; 6
                DC.B 5,5,5,5,5,5,0,-1 ; 8
                DC.B 2,2,2,1,1,3,3,-1 ; 10
                DC.B 3,3,5,5,5,5,5,-1 ; 12
                DC.B 1,3,5,5,5,5,0,-1 ; 14
                DC.B 1,1,5,5,5,0,0,-1 ; 16
                DC.B 1,3,3,3,5,5,5,-1 ; 18
                DC.B 1,1,3,3,5,5,0,-1 ; 20
                DC.B 1,1,1,3,5,0,0,-1 ; 22
                DC.B 1,1,1,1,0,0,0,-1 ; 24
                DC.B 1,1,1,3,3,3,0,-1 ; 26
                DC.B 2,1,1,1,3,3,0,-1 ; 28
                DC.B 2,2,1,1,1,3,0,-1 ; 30
                DC.B 3,5,5,5,5,5,5,-1 ; 32
                DC.B 1,5,5,5,5,5,0,-1 ; 34
                DC.B 4,4,4,4,5,0,0,0 ; 36
                DC.B 1,3,3,5,5,5,5,-1 ; 38
                DC.B 1,1,3,5,5,5,0,-1 ; 40
                DC.B 1,1,1,5,5,0,0,-1 ; 42
                DC.B 1,1,3,3,3,5,5,-1 ; 44
                DC.B 1,1,1,3,3,5,0,-1 ; 46
                DC.B 3,3,0,0,0,0,0,0 ; 48
                DC.B 1,1,1,3,3,3,3,-1 ; 50
                DC.B 5,5,5,5,5,5,5,-1 ; 52
                DC.B 2,2,1,1,1,3,3,-1 ; 54
                DC.B 2,2,2,1,1,1,3,-1 ; 56
                DC.B 1,3,5,5,5,5,5,-1 ; 58
                DC.B 1,1,5,5,5,5,0,-1 ; 60
                DC.B 3,4,4,4,5,0,0,0 ; 62
                DC.B 1,1,3,3,5,5,5,-1 ; 64
                DC.B 1,1,1,3,5,5,0,-1 ; 66
                DC.B 1,1,1,1,5,0,0,-1 ; 68
                DC.B 1,0,0,0,0,0,0,0 ; 70
                DC.B 1,1,1,1,3,3,0,-1 ; 72
                DC.B 2,2,4,1,1,1,1,-1 ; 74
                DC.B 2,2,1,1,1,1,0,-1 ; 76
                DC.B 1,5,5,5,5,5,5,-1 ; 78
                DC.B 4,4,4,4,5,5,0,0 ; 80
                DC.B 4,4,4,5,5,0,0,0 ; 82
                DC.B 1,1,3,5,5,5,5,-1 ; 84
                DC.B 1,1,1,5,5,5,0,-1 ; 86
                DC.B 5,5,0,0,0,0,0,0 ; 88
                DC.B 1,1,1,3,3,5,5,-1 ; 90
                DC.B 3,3,5,0,0,0,0,0 ; 92
                DC.B 1,1,1,1,1,0,0,-1 ; 94
                DC.B 1,1,1,1,3,3,3,-1 ; 96
                DC.B 2,3,3,3,0,0,0,0 ; 98
                DC.B 2,2,1,1,1,1,3,-1 ; 100
                DC.B 2,2,2,1,1,1,1,-1 ; 102
                DC.B 1,1,5,5,5,5,5,-1 ; 104
                DC.B 3,4,4,4,5,5,0,0 ; 106
                DC.B 1,4,4,4,5,0,0,0 ; 108
                DC.B 1,1,1,3,5,5,5,-1 ; 110
                DC.B 1,1,1,1,5,5,0,-1 ; 112
                DC.B 1,5,0,0,0,0,0,0 ; 114
                DC.B 3,3,3,5,0,0,0,0 ; 116
                DC.B 1,3,3,0,0,0,0,0 ; 118
                DC.B 3,3,3,3,3,0,0,0 ; 120
                DC.B 2,2,2,5,0,0,0,0 ; 122
                DC.B 4,4,4,4,5,5,5,0 ; 124
                DC.B 4,4,4,5,5,5,0,0 ; 126
                DC.B 4,4,5,5,5,0,0,0 ; 128
                DC.B 1,1,1,5,5,5,5,-1 ; 130
                DC.B 5,5,5,0,0,0,0,0 ; 132
                DC.B 4,3,3,5,5,0,0,0 ; 134
                DC.B 3,3,5,5,0,0,0,0 ; 136
                DC.B 1,3,5,0,0,0,0,0 ; 138
                DC.B 1,1,0,0,0,0,0,0 ; 140
                DC.B 1,3,3,3,0,0,0,0 ; 142
                DC.B 3,3,3,3,3,3,0,0 ; 144
                DC.B 1,1,1,1,1,2,2,-1 ; 146
                DC.B 5,2,2,2,2,0,0,0 ; 148
                DC.B 1,4,4,4,4,5,5,0 ; 150
                DC.B 3,4,4,5,5,5,0,0 ; 152
                DC.B 1,4,4,5,5,0,0,0 ; 154
                DC.B 3,5,5,5,0,0,0,0 ; 156
                DC.B 1,5,5,0,0,0,0,0 ; 158
                DC.B 3,3,3,5,5,0,0,0 ; 160
                DC.B 1,3,3,5,0,0,0,0 ; 162
                DC.B 1,1,3,0,0,0,0,0 ; 164
                DC.B 1,3,3,3,3,0,0,0 ; 166
                DC.B 3,3,3,3,3,3,3,0 ; 168
                DC.B 2,3,3,3,3,3,3,0 ; 170
                DC.B 5,5,5,5,4,4,0,0 ; 172
                DC.B 4,5,5,5,5,0,0,0 ; 174
                DC.B 5,5,5,5,0,0,0,0 ; 176
                DC.B 3,3,4,5,5,5,0,0 ; 178
                DC.B 3,3,5,5,5,0,0,0 ; 180
                DC.B 1,3,5,5,0,0,0,0 ; 182
                DC.B 1,1,5,0,0,0,0,0 ; 184
                DC.B 1,3,3,3,5,0,0,0 ; 186
                DC.B 1,1,3,3,0,0,0,0 ; 188
                DC.B 1,3,3,3,3,3,0,0 ; 190
                DC.B 2,2,3,3,3,3,5,0 ; 192
                DC.B 2,2,2,3,3,3,5,0 ; 194
                DC.B 1,4,4,4,5,5,5,0 ; 196
                DC.B 3,4,5,5,5,5,0,0 ; 198
                DC.B 3,5,5,5,5,0,0,0 ; 200
                DC.B 1,5,5,5,0,0,0,0 ; 202
                DC.B 3,3,3,5,5,5,0,0 ; 204
                DC.B 1,3,3,5,5,0,0,0 ; 206
                DC.B 1,1,3,5,0,0,0,0 ; 208
                DC.B 1,1,1,0,0,0,0,0 ; 210
                DC.B 1,1,3,3,3,0,0,0 ; 212
                DC.B 1,3,3,3,3,3,3,0 ; 214
                DC.B 4,4,5,5,5,5,5,0 ; 216
                DC.B 4,5,5,5,5,5,0,0 ; 218
                DC.B 5,5,5,5,5,0,0,0 ; 220
                DC.B 3,3,4,5,5,5,5,0 ; 222
                DC.B 3,3,5,5,5,5,0,0 ; 224
                DC.B 1,3,5,5,5,0,0,0 ; 226
                DC.B 1,1,5,5,0,0,0,0 ; 228
                DC.B 1,3,3,3,5,5,0,0 ; 230
                DC.B 1,1,3,3,5,0,0,0 ; 232
                DC.B 1,1,1,3,0,0,0,0 ; 234
                DC.B 1,1,3,3,3,3,0,0 ; 236
                DC.B 1,2,2,3,3,3,5,0 ; 238
                DC.B 2,2,1,1,3,3,0,0 ; 240
                DC.B 1,4,4,5,5,5,5,0 ; 242
                DC.B 0,4,4,4,4,4,4,1 ; 244
                DC.B 1,5,5,5,5,0,0,0 ; 246
                DC.B 3,3,3,5,5,5,5,0 ; 248
                DC.B 1,1,3,4,5,5,0,0 ; 250
                DC.B 1,1,3,5,5,0,0,0 ; 252
                DC.B 1,1,1,5,0,0,0,0 ; 254




; ---------- **** SYNCSCROLLING ENDE **** ------------------------------------


newkey:         move.w  D0,-(A7)             ; TastaturIRQ
                move.b  $fffffc00.w,D0
                btst    #7,D0
                beq.s   endkey
                move.b  $fffffc02.w,key
endkey:         move.w  (A7)+,D0
                rte

timer_b:        rte


;------------------------------------------------------------------------------
                SECTION DATA

screen_1:       DC.L 0          ; so weit oben damit PC-Relativer Zugriff
screen_2:       DC.L 0
key:            DC.W 0
key_repeat:     DC.W -1


zahlen_grafik:
; 0-9 16 breit, 7 hoch, nebeneinander

                DC.W $7ff8,$07c0,$7ff8,$7ff8,$f03c,$fffc,$7ff8,$fffc
                DC.W $7ff8,$7ff8,$f03c,$3fc0,$f03c,$f03c,$f03c,$f000
                DC.W $f03c,$3c,$f03c,$f03c,$f0fc,$03c0,$7c,$3c
                DC.W $f03c,$f000,$f000,$f0,$f03c,$f03c,$f33c,$03c0
                DC.W $07f8,$0ff8,$7ffc,$fff8,$fff8,$3ff8,$7ff8,$7ffc
                DC.W $fc3c,$03c0,$7f80,$3c,$3c,$3c,$f03c,$03c0
                DC.W $f03c,$3c,$f03c,$03c0,$f000,$f03c,$3c,$f03c
                DC.W $f03c,$0f00,$f03c,$f03c,$7ff8,$fffc,$fffc,$7ff8
                DC.W $3c,$7ff8,$7ff8,$0f00,$7ff8,$7ff8

back_pic:	INCBIN 'SYNC7.NEO'
palette:	EQU	back_pic+4
picture:	EQU	back_pic+128

;------------------------------------------------------------------------------
		SECTION BSS
bss_start:      

oldmfp07:       DS.B 1
oldmfp09:       DS.B 1
oldmfp11:       DS.B 1
oldmfp13:       DS.B 1
oldmfp15:       DS.B 1
oldmfp17:       DS.B 1
oldmfp1b:       DS.B 1
oldmfp21:       DS.B 1
oldres:         DS.B 1
oldsync:        DS.B 1
oldvbl:         DS.L 1
oldhbl:         DS.L 1
oldkey:         DS.L 1
oldtimerb:      DS.L 1
oldstack:       DS.L 1
oldpalette:     DS.L 8
oldscreen:      DS.W 1
vsync_count:    DS.L 1
old_sr:         DS.W 1

stack_block:    DS.B 512        ; 512 Bytes Stack
stack:

                DS.L 256        ; wegen unteren 8 Bits des Screens

screen_base:    DS.B 32000*2    ; Platz fÅr 2 Screens

bss_ende:       END
