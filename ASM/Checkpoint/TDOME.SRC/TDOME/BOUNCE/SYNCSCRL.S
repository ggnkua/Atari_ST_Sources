
vbl_syncscroll: >PART

                move    #$2700,SR

                move.l  #hbl_top,$00000068.w
                move.w  #HBL_TOP_LINES-1,top_line_counter.w

; setup timer b
                move.l  #spc_timer_b,$00000120.w
                move.b  #0,$FFFFFA1B.w
                move.b  #27+1+2,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w

;-------------------------------------------------------
                movem.l sample_buffPtr(PC),A4/A6
                exg     A4,A6
                movem.l A4/A6,sample_buffPtr

                move.l  A4,spl_play_ptr
                move.l  A6,spl_work_ptr
                lea     $FFFF8800.w,A6
;-------------------------------------------------------

                move    #$2100,SR       ; hbl on

                clr.b   top_hbl_flag

                movem.l D0-D6/A0-A3,-(SP)

                move.l  vbl_slot_first.w,D0
                beq.s   *+4
                movea.l D0,A0
                jsr     (A0)

                bsr     decode_VQ_frame

                movem.l (SP)+,D0-D6/A0-A3

                addq.l  #1,$00000466.w
                move.b  #$21,(SP)       ; HBL zulassen
                rte
                ENDPART

                >PART ' sync scroller '

hbl_top:
                move.l  (A4)+,D7        ; 3
                movep.l D7,0(A6)        ; 7
                move.l  (A4)+,(A6)      ; 6
                subq.w  #1,top_line_counter.w
                bmi.s   hbl_line_da
                rte
hbl_line_da:
                move    #$2700,SR
                move.b  #0,$FFFFFA19.w  ; ta ctrl

;  move.l  $FFFFFA12.w,old_imask+2
;  move.l  #0,$FFFFFA12.w  ; lock imask

                move.l  SP,ot2_sp+2
                move.l  #open_top_2,$00000068.w
                move    #$2100,SR
waithbl:
                stop    #$2100
                bra.s   waithbl

open_top_2:
; klappt den oberen Rand auf
                move    #$2700,SR
ot2_sp:         lea     0,SP            ; Stack korrigieren

                move.l  #rte,$00000068.w ; 6

;; movem.l D0-A5,-(SP)     ; 32   alle Register retten

                movem.l D0-D6/A0-A3,-(SP) ; 24
                DS.W 6,$00004E71

                move.l  SP,reload_stack+2 ; 5

colors_hbl_adr: movem.l zero,D0-D6/A0   ;   21
                movem.l D0-D6/A0,$FFFF8240.w ; 19

                DS.W 13-6-1,$00004E71

                lea     (A4),A2         ; 1   samplePtr

                move.b  #0,$FFFF820A.w  ; 60 Hz
                DS.W 11,$00004E71
                move.b  #2,$FFFF820A.w  ; 50 Hz

                clr.w   sync_offset     ; Z„hler fr syncscroll offets

                movea.l sync_pointer1,A0
;-- lea     $FFFF8209.w,A2
                lea     $FFFF820A.w,A3
                lea     $FFFF8260.w,A4
                move.w  #$0100,D0       ; moveq   #0,D0
                moveq   #2,D1
                moveq   #0,D3

                st      top_hbl_flag
wait_sync2:                             ;-- move.b  (A2),D3
                move.b  $FFFF8209.w,D3
                cmp.w   #64,D3
                blt.s   wait_sync2
                sub.w   #64,D3
                not.w   D3
                lsr.w   D3,D3


;; move.w  #$0070,$FFFF8240.w


                DS.W 33,$00004E71

; used: a0,a1,a3,a4
; free: a2,a5,a6

; start syncscroller
                movea.l (A0)+,A1        ; 3 Routine aus Tabelle holen
                jmp     (A1)            ; 2 und diese anspringen
end_sync:
                ENDPART
                >PART ' bordercode '
syncscroll_end:

reload_stack:   lea     0,SP

                lea     (A2),A4         ; 1   samplePtr

;; old_imask:      move.l  #0,$FFFFFA12.w

                move.l  #hbl_end,$00000068.w
                move    #$2100,SR

                move.l  screen_sync(PC),D0
                bsr.s   set_screen

                movem.l (SP)+,D0-D6/A0-A3

                move.b  #$21,(SP)       ; enable hbl
                rte
                ENDPART

hbl_end:
                move    #$2700,SR
                move.l  (A4)+,D7        ; 3
                movep.l D7,0(A6)        ; 7
                move.l  (A4)+,(A6)      ; 6
                rte

set_screen:     >PART
; in d0 = Screenadresse
; stellt Lowbyte durch Syncscrolling dar

                move.l  sync_pointer1(PC),D1 ; Pointer tauschen
                move.l  sync_pointer2(PC),sync_pointer1
                move.l  D1,sync_pointer2

                move.l  D0,D1
                and.w   #255,D1         ; nur untere 8 Bits
                lea     sync_pointer_tab(PC),A0 ; dort sind Routinen
                lsr.w   #1,D1           ; durch 2 -> 0-127
                move.w  D1,D2
                lsl.w   #5,D1           ; *32 (8 Longs)
                adda.w  D1,A0
                move.l  A0,sync_pointer1
                lea     sync_offset_tab(PC),A0
                lsl.w   #2,D2           ; *4 (wegen Longs)
                add.l   0(A0,D2.w),D0   ; Offset auf Screen addieren
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                rts

; Hier sind die Routinen, die die R„nder aufmachen

sync_routine1:
; klappt beide R„nder auf.
; braucht 70 Bytes
                move.b  D1,(A4)         ; Highres
                nop
                move.b  D0,(A4)         ; Lowres (Links auf)

                move.l  (A2)+,D7        ; 3
                movep.l D7,0(A6)        ; 7
                move.l  (A2)+,(A6)      ; 6  ...16

                addi.w  #160+70,sync_offset ; 6
                DS.W 89-6-16,$00004E71

                move.b  D0,(A3)         ; 60Hz
                move.b  D1,(A3)         ; 50Hz (Rechts auf)

                DS.W 13,$00004E71

                move.b  D1,(A4)         ; Highres
                nop
                move.b  D0,(A4)         ; Lowres (Rechts zu)

                DS.W 7,$00004E71

                movea.l (A0)+,A1        ; n„chste Routine holen (12)
                jmp     (A1)            ; und die anspringen    (8)

sync_routine2:
; klappt nur linken Rand auf
; braucht 26 Bytes
                move.b  D1,(A4)         ; Highres
                nop
                move.b  D0,(A4)         ; Lowres (Links auf)

                move.l  (A2)+,D7        ; 3
                movep.l D7,0(A6)        ; 7
                move.l  (A2)+,(A6)      ; 6  ...16

                addi.w  #160+26,sync_offset ; 6
                DS.W 89-6-16,$00004E71

                move.b  D1,(A3)         ; 50Hz
                move.b  D1,(A3)         ; 50Hz (nur Dummy)

                DS.W 13,$00004E71

                move.b  D1,(A4)         ; Highres
                nop
                move.b  D0,(A4)         ; Lowres (Rechts "zu")

                DS.W 7,$00004E71

                movea.l (A0)+,A1        ; n„chste Routine holen (12)
                jmp     (A1)            ; und die anspringen    (8)


sync_routine3:
; klappt linken Rand auf und schneidet 2 Bytes ab.
; braucht 24 Bytes
                move.b  D1,(A4)         ; Highres
                nop
                move.b  D0,(A4)         ; Lowres (Links auf)

                move.l  (A2)+,D7        ; 3
                movep.l D7,0(A6)        ; 7
                move.l  (A2)+,(A6)      ; 6  ...16

                addi.w  #160+24,sync_offset ; 6
                DS.W 88-6-16,$00004E71

                move.b  D0,(A3)         ; 60Hz
                move.b  D1,(A3)         ; 50Hz (Rechts auf)

                DS.W 14,$00004E71

                move.b  D1,(A4)         ; Highres
                nop
                move.b  D0,(A4)         ; Lowres (Rechts zu)

                DS.W 7,$00004E71

                movea.l (A0)+,A1        ; n„chste Routine holen (12)
                jmp     (A1)            ; und die anspringen    (8)

sync_routine4:
; klappt rechten Rand auf und schneidet 2 Bytes ab.
; braucht -2 Bytes
                move.b  D0,(A4)         ; Lowres (Dummy)
                nop
                move.b  D0,(A4)         ; Lowres ("Links auf")

                move.l  (A2)+,D7        ; 3
                movep.l D7,0(A6)        ; 7
                move.l  (A2)+,(A6)      ; 6  ...16

                addi.w  #160-2,sync_offset ; 6
                DS.W 88-6-16,$00004E71

                move.b  D0,(A3)         ; 60Hz
                move.b  D1,(A3)         ; 50Hz (Rechts auf)

                DS.W 14,$00004E71

                move.b  D1,(A4)         ; Highres
                nop
                move.b  D0,(A4)         ; Lowres (Rechts zu)

                DS.W 7,$00004E71

                movea.l (A0)+,A1        ; n„chste Routine holen (12)
                jmp     (A1)            ; und die anspringen    (8)

sync_routine5:
; Nur rechten Rand aufmachen
; stellt 44 Bytes dar

                move.b  D0,(A4)         ; Lowres (Dummy)
                nop
                move.b  D0,(A4)         ; Lowres ("Links auf")

                move.l  (A2)+,D7        ; 3
                movep.l D7,0(A6)        ; 7
                move.l  (A2)+,(A6)      ; 6  ...16

                addi.w  #160+44,sync_offset ; 6
                DS.W 89-6-16,$00004E71

                move.b  D0,(A3)         ; 60Hz
                move.b  D1,(A3)         ; 50Hz (Rechts auf)

                DS.W 13,$00004E71

                move.b  D1,(A4)         ; Highres
                nop
                move.b  D0,(A4)         ; Lowres (Rechts zu)

                DS.W 7,$00004E71

                movea.l (A0)+,A1        ; n„chste Routine holen (12)
                jmp     (A1)            ; und die anspringen    (8)

sync_routine0:
; macht 512 TZ lang nichts
                addi.w  #160,sync_offset ; 6

                move.l  (A2)+,D7        ; 3
                movep.l D7,0(A6)        ; 7
                move.l  (A2)+,(A6)      ; 6  ...16

                DS.W 117-16,$00004E71

                movea.l (A0)+,A1        ; n„chste Routine holen (12)
                jmp     (A1)            ; und die anspringen    (8)

                ENDPART
top_hbl_flag:   DC.B 0,0
sync_offset:    DC.W 0
screen_sync:    DC.L 0
;-------------------------------------------------------------------------------
init_sync_scrolling:>PART

;-     bsr.s   get_anzahl_zeilen ; ermitteln, wieviel Scanlines dargestellt werden

                bsr     install_all

                bsr.s   create_tabellen ; Tabellen aufbauen

                move    #$2700,SR

                lea     rte(PC),A0
                move.l  A0,$00000060.w
*  move.l  A0,$00000068.w
                move.l  A0,$00000120.w
*  move.l  A0,$00000134.w

                clr.b   $FFFFFA1B.w     ; tb ctrl
                bset    #5,$FFFFFA07.w  ;Timer B
                bset    #5,$FFFFFA13.w  ;Timer B

                move    #$2300,SR

                rts





                lea     rte(PC),A0
                move.l  A0,$00000060.w
                move.l  A0,$00000068.w
                move.l  A0,$00000120.w
                move.l  A0,$00000134.w

                clr.b   $FFFFFA1B.w     ; tb ctrl
                bset    #0,$FFFFFA07.w  ;Timer B
                bset    #0,$FFFFFA13.w  ;Timer B

                clr.b   $FFFFFA19.w     ; ta ctrl
                bset    #5,$FFFFFA07.w  ;Timer B
                bset    #5,$FFFFFA13.w  ;Timer B

                move    #$2300,SR

                rts

create_tabellen:
; erstellt Pointertabellen fr Syncscrolling (im BSS)
                lea     sync_tabelle(PC),A0
                lea     sync_pointer_tab(PC),A1
                lea     sync_offset_tab(PC),A2
                lea     sync_routine_tab(PC),A3
                move.w  #(256/2)-1,D0   ; 128 Werte (2er Syncscrolling)
createtabloop0: moveq   #6,D1           ; 7 Routinen
createtabloop1: moveq   #0,D2
                move.b  (A0)+,D2        ; Wert von 0-5 holen
                lsl.w   #2,D2           ; *4 wegen Longs
                move.l  0(A3,D2.w),(A1)+ ; Routine in Pointertab ablegen
                dbra    D1,createtabloop1
                move.l  #end_sync,(A1)+ ; Letzte Routine immer dazu
                move.b  (A0)+,D2        ; Offsetwert holen
                beq.s   is_off0
                bpl.s   is_off1
                move.l  #-256,(A2)+     ; jeweiligen Offset setzen
                bra.s   off_ok
is_off0:        clr.l   (A2)+
                bra.s   off_ok
is_off1:        move.l  #256,(A2)+
off_ok:         dbra    D0,createtabloop0
                rts

sync_routine_tab:
; Hier stehen die m”glichen Routinen drin.
; Wird zum Berechnen ben”tigt

                DC.L sync_routine0
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine3
                DC.L sync_routine4
                DC.L sync_routine5

                ENDPART
install_all:    >PART

;  movem.l palette,D0-D7
;  movem.l D0-D7,$FFFF8240.w
                move.l  screen_sync,D0
                jsr     set_screen
                rts
                ENDPART
start_vbl:      >PART
                addq.l  #1,$00000466.w
                rte
                ENDPART
;-------------------------------------------------------------------------------
                >PART ' sync data '
hbl_count:      DC.W 32
anzahl_zeilen:  DC.W 0
sync_pointer1:  DC.L sync_pointer_tab
sync_pointer2:  DC.L sync_pointer_tab
sync_offset_tab:DS.L 256/2
sync_pointer_tab:DS.L 256/2*8

sync_tabelle:   DC.B 0,0,0,0,0,0,0,0+0
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
                DC.B 1,3,3,3,5,0,0,0 ; !86
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
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


