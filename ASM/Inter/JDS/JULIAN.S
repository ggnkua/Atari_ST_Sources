; Julian Dentro-System
                OPT X+

                >PART 'EQU Main'
jds             EQU 0           ; 0 = Routine mit JDS
;                               1 = Unterroutine vom JDS; wird nachgeladen und
;                                   soll die JDS-Routinen Åber deren Offset
;                                   anspringen...
system_mask     EQU %1000
;                           :||||
;                           :|||+--- ST
;                           :||+---- STE
;                           :|+----- Mega STE
;                           :+------ Falcon 030
;                           +- - - - TT
info_key_ok     EQU 0           ; 0 = Aus
kill_bugaboo    EQU 0           ; 0 = Aus (Buggaboo-Killer fÅr Falcon...) Noch nicht fertig!
space           EQU 57          ; " "-Taste
info_key        EQU 41          ; "#"-Taste
module_on       EQU 0           ; 0 = Aus
*module_timer    EQU 0           ; 0 = Timer A    1 = Timer B
hdplay_used     EQU 0           ; 0 = Nein
hdplay_bufsize  EQU 50000       ; In 10000er-Schritten!
hdplay_mode     EQU %10000010
;                            ||    ||
;                            ||    00 --- nute condition
;                            ||    01 --- 12517 Hz
;                            ||    10 --- 25033 Hz
;                            ||    11 --- 50066 Hz
;                            |+---------- 0:  8 Bit
;                            |            1: 16 Bit
;                            +----------- 0: Stereo
;                                         1: Mono
show_time       EQU 0           ; 0 = Aus
                ENDPART
                >PART 'equ'
; 26/08/93 bITmASTER

iera            EQU $FFFFFA07   ;Interrupt-Enable-Register A
ierb            EQU $FFFFFA09   ;                                                               B
imra            EQU $FFFFFA13
isra            EQU $FFFFFA0F
isrb            EQU $FFFFFA11
tacr            EQU $FFFFFA19
tbcr            EQU $FFFFFA1B
tadr            EQU $FFFFFA1F
tbdr            EQU $FFFFFA21
tccr            EQU $FFFFFA1D
tcdr            EQU $FFFFFA23
aer             EQU $FFFFFA03
stcolor         EQU $FFFF8240
fcolor          EQU $FFFF9800
vbl             EQU $70
timer_a_int     EQU $0134
timer_b_int     EQU $0120
timer_c_int     EQU $0114

ym_select       EQU $FFFF8800
ym_write        EQU $FFFF8802
ym_read         EQU $FFFF8800

vbaselow        EQU $FFFF820D
vbasemid        EQU $FFFF8203
vbasehigh       EQU $FFFF8201
vcountlow       EQU $FFFF8209
vcountmid       EQU $FFFF8207
vcounthigh      EQU $FFFF8205
linewid         EQU $FFFF820F
hscroll         EQU $FFFF8265

keyctl          EQU $FFFFFC00
keybd           EQU $FFFFFC02

dsphost         EQU $FFFFA200
hostintvec      EQU $03FC

pcookies        EQU $05A0

hop             EQU $FFFF8A3A
op              EQU $FFFF8A3B
line_nr         EQU $FFFF8A3C
mode            EQU $FFFF8A3C
skew            EQU $FFFF8A3D
endmask1        EQU $FFFF8A28
endmask2        EQU $FFFF8A2A
endmask3        EQU $FFFF8A2C
x_count         EQU $FFFF8A36
y_count         EQU $FFFF8A38
dest_x_inc      EQU $FFFF8A2E
dest_y_inc      EQU $FFFF8A30
dest_adr        EQU $FFFF8A32
src_x_inc       EQU $FFFF8A20
src_y_inc       EQU $FFFF8A22
src_adr         EQU $FFFF8A24

mpx_src         EQU $FFFF8930
mpx_dst         EQU $FFFF8932
                ENDPART

                >PART 'TEXT Dentro-System'
; In Supervisor-Modus...
                pea     ds_w2(PC)
                move.w  #38,-(SP)
                trap    #14
                addq.l  #6,SP
ds_w1:          clr.w   -(SP)
                trap    #1
; GerÑtetest
; ==========
; Kontrollwert in system_mask: Bit 0  ST
;                                  1  STE
;                                  2  Mega STE
;                                  3  Falcon 030
;                                  4  TT
; GerÑte-Maske steht auch in system_flag.w
ds_w2:          movea.l SP,A5
                movea.l $08.w,A6
                moveq   #1,D0           ; ST
                move.l  #ds_w7,$08.w
                tst.b   $FFFF8922.w
                moveq   #2,D0           ; STE
ds_w7:          move.l  #ds_w8,$08.w
                move.b  $FFFF8E21.w,D1
                moveq   #4,D0           ; Mega STE
ds_w8:          move.l  #ds_w9,$08.w
                tst.b   $FFFF8C01.w
                moveq   #16,D0          ; TT
ds_w9:          move.l  #ds_w10,$08.w
                tst.b   $FFFF8280.w
                moveq   #8,D0           ; Falcon 030
ds_w10:         move.l  A6,$08.w
                movea.l A5,SP

                move.w  D0,system_flag
                and.w   #system_mask,D0
                bne.s   ds_w0

                pea     ds_error0(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP
                bra.s   ds_w1
; Falcon-Monitor-Test
; falcon_monitor.b   0  Monochrome
;                    1  RGB
;                    2  VGA
;                    3  TV
ds_w0:          move.w  system_flag(PC),D0
                and.w   #%1000,D0
                beq.s   ds_w3
; Bugaboo-Killer?
                IF kill_bugaboo<>0
                andi    #$7FFF,SR
                lea     new_vbr(PC),A0
                DC.L $4E7B8801
                move    SR,D0
                andi    #$7FFF,SR
                btst    #15,D0
                beq.s   w0
; Trace-Versuch...
                suba.l  A0,A0
                DC.L $4E7B8801
                bra.s   ds_w3
w0:             suba.l  A0,A0
                DC.L $4E7B8801
                ENDC

                move.w  #89,-(SP)
                trap    #14
                addq.l  #2,SP
                move.b  D0,falcon_monitor
; Monochrome? ==> Raus!
ds_w3:          move.w  system_flag(PC),D0
                and.w   #%1000,D0
                beq.s   ds_w4
                tst.b   falcon_monitor
                beq.s   ds_w5
                bra.s   ds_w6
ds_w4:          move.b  $FFFF8260.w,D0
                and.b   #%11,D0
                cmp.b   #%10,D0
                bne.s   ds_w6
ds_w5:          pea     monochrome_error(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP
                rts
; Alles retten...
ds_w6:          move    SR,-(SP)        ; Statusregister retten

                ori     #$0700,SR       ; Interrupts aus

                move.w  system_flag(PC),D0 ; Alte Auflîsung retten
                cmp.w   #%1000,D0
                beq.s   ds_w13
                move.w  #4,-(SP)
                trap    #14
                addq.l  #2,SP
                move.w  D0,-(SP)
                move.w  #12,D7
ds_w13:         move.w  #-1,-(SP)
                move.w  #88,-(SP)
                trap    #14
                addq.l  #4,SP
                move.w  D0,-(SP)
                move.w  #3,-(SP)
                move.w  #14,D7
ds_w12:         move.w  #2,-(SP)        ; Bildschirmadresse retten
                trap    #14
                addq.l  #2,SP
                move.l  D0,-(SP)
                move.l  D0,-(SP)
                move.w  #5,-(SP)
                move.w  D7,-(SP)

                lea     2048,A0
                move.w  #509,D0
ds_l0:          move.l  -(A0),-(SP)
                dbra    D0,ds_l0

                move.b  $FFFF8260.w,-(SP) ; Shifter - Register retten
                move.l  $FFFF8200.w,-(SP)
                movem.l $FFFF8240.w,D0-D7 ; 16-Farb-Register retten
                movem.l D0-D7,-(SP)

                move.l  $08.w,-(SP)
                move.l  $0C.w,-(SP)
                move.l  $68.w,-(SP)     ; Exceptionsvektoren retten
                move.l  $70.w,-(SP)
                move.l  $0118.w,-(SP)
                move.l  $0120.w,-(SP)
                move.l  $0134.w,-(SP)

                move.b  $FFFFFA07.w,-(SP) ; MFP - Register retten
                move.b  $FFFFFA09.w,-(SP)
                move.b  $FFFFFA13.w,-(SP)
                move.b  $FFFFFA15.w,-(SP)
                move.b  $FFFFFA17.w,-(SP)
                move.b  $FFFFFA19.w,-(SP)
                move.b  $FFFFFA1B.w,-(SP)
                move.b  $FFFFFA1D.w,-(SP)

                move.l  SP,original_sp
; Alles abschalten...
                lea     $FFFFFA07.w,A1  ; MFP - Interrupts stoppen
                moveq   #0,D1
                moveq   #7,D0
ds_l2:          move.b  D1,(A1)
                addq.l  #2,A1
                dbra    D0,ds_l2

                lea     dummy_rte(PC),A0
                move.l  A0,$08.w
                move.l  A0,$0C.w
                lea     dummy_rte(PC),A0 ; Exceptionsvektoren auf RTE setzen
                move.l  A0,$68.w
                move.l  A0,$70.w
                move.l  A0,$0118.w
                move.l  A0,$0120.w
                move.l  A0,$0134.w

                bsr     init_soundchip
                IF hdplay_used<>0
                sf      hdplay_on
                ENDC
; Eigene Handler installieren...
                IF kill_bugaboo<>0
                move.l  #vbl_handler,$70+vbr
                move.l  #acia_handler,$0118+vbr
                ELSE
                move.l  #vbl_handler,$70.w
                move.l  #acia_handler,$0118.w
                ENDC
                move.b  #%1000000,$FFFFFA09.w
                move.b  #%1000000,$FFFFFA15.w
; Falcon in Hîchstgeschwindigkeit (...VorlÑufig ins Dentro_Init verschoben)
; Variablen einstellen
                move.l  #subskript_stack+4*16,subskript_stackpos
                clr.b   subskript_tiefe
; Dentro-Initialisierung als Sub-Routine
                bsr     dentro_init
                andi    #$F8FF,SR       ; Interrupts an
; Hauptroutine
; ============
; Ablauf-Skript: .l  Adresse des nÑchsten Skript-Befehls
;                .l  Adresse der Routine
;                ... Datenpaket.
; Bei Routinenaufruf steht in A0 die Adresse des Datenpaketes.
; Routinenende: RTS
                move.l  #ablauf_skript,main_skriptpos
                clr.w   main_skriptnr
                clr.w   -(SP)
                movea.l SP,A0
                bsr     wvbl
                addq.l  #2,SP
main_l0:        movea.l main_skriptpos(PC),A0
                move.l  (A0)+,main_skriptpos
                movea.l (A0)+,A1
                jsr     (A1)
                addq.w  #1,main_skriptnr
                bra.s   main_l0
dummy_rte:      rte
*****************************************************************************
; Dentro-Ende (Letzer Skript-Befehl bzw. Escape-Taste)
dentro_exit:    move.l  #dentro_end,dentro_exit_c0
dentro_exit2:   ori     #$0700,SR
                IF hdplay_used<>0
                bsr     hdplay_stop
                ENDC
                bsr     stop_module
                bsr     dentro_deinit
                movea.l original_sp(PC),SP
; Originalwerte zurÅckschreiben
                move.b  (SP)+,$FFFFFA1D.w ; MFP - Register zurÅckschreiben
                move.b  (SP)+,$FFFFFA1B.w
                move.b  (SP)+,$FFFFFA19.w
                move.b  (SP)+,$FFFFFA17.w
                move.b  (SP)+,$FFFFFA15.w
                move.b  (SP)+,$FFFFFA13.w
                move.b  (SP)+,$FFFFFA09.w
                move.b  (SP)+,$FFFFFA07.w

                move.l  (SP)+,$0134.w   ; Exceptionsvektoren zurÅckschreiben
                move.l  (SP)+,$0120.w
                move.l  (SP)+,$0118.w
                move.l  (SP)+,$70.w
                move.l  (SP)+,$68.w
                move.l  (SP)+,$0C
                move.l  (SP)+,$08

                movem.l (SP)+,D0-D7     ; Shifter - Register zurÅckschreiben
                movem.l D0-D7,$FFFF8240.w
                move.l  (SP)+,$FFFF8200.w
                move.b  (SP)+,$FFFF8260.w

                lea     $08,A0
                move.w  #509,D0
ds_l1:          move.l  (SP)+,(A0)+
                dbra    D0,ds_l1

                move.w  (SP)+,D7
                trap    #14
                adda.w  D7,SP

                move    (SP)+,SR        ; Statusregister zurÅckladen
; Buggaboo-Killer & Falcon?
                move.w  system_mask(PC),D0
                and.w   #%1000,D0
                beq.s   ds_w11
                suba.l  A0,A0
                DC.L $4E7B8801
; Dentro verlassen
ds_w11:         jmp     0
dentro_exit_c0  EQU *-4
dentro_end:     rts
error_exit:     move.l  A0,error_adr
                move.l  #error_exit_w0,dentro_exit_c0
                bra     dentro_exit2
error_exit_w0:  pea     error_txt(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  error_adr(PC),-(SP)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP
                rts
dentro_info_exit:move.l #dentro_info_exit_w0,dentro_exit_c0
                bra     dentro_exit2
dentro_info_exit_w0:pea dentro_info(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  $0462.w,D0
                add.l   #10*50,D0
dentro_info_exit_l0:cmp.l $0462.w,D0
                bne.s   dentro_info_exit_l0
                rts
*****************************************************************************
; Keyboard-, Maus- und Joysticktreiber
acia_handler:   andi.b  #%10111111,$FFFFFA11
                movem.l D0-D1,-(SP)
                move.b  $FFFFFC02.w,D0
                tst.w   acia_joy_flag
                bne     acia_joy
                cmpi.w  #2,acia_mouse_flag
                beq.s   acia_mouse2
                tst.w   acia_mouse_flag
                bne.s   acia_mouse1
                move.b  D0,D1
                and.b   #$FC,D1
                cmp.b   #$F8,D1
                bne.s   acia_no_mouse
                and.b   #$03,D0
                move.b  D0,mousek
                move.w  #2,acia_mouse_flag
                movem.l (SP)+,D0-D1
                rte
acia_no_mouse:  move.b  D0,D1
                and.b   #$FE,D1
                cmp.b   #$FE,D1
                bne.s   acia_no_joy
                not.b   D0
                move.b  D0,acia_joy_select
                not.w   acia_joy_flag
                movem.l (SP)+,D0-D1
                rte
acia_no_joy:    move.b  D0,key
                cmp.b   #1,D0           ; Escape...
                beq.s   dentro_exit_s0
                IF info_key_ok<>0
                cmp.b   #info_key,D0
                beq     dentro_info_exit
                ENDC
                movem.l (SP)+,D0-D1
                rte
dentro_exit_s0: bra     dentro_exit
acia_mouse2:    ext.w   D0
                add.w   D0,mousex
                subq.w  #1,acia_mouse_flag
                movem.l (SP)+,D0-D1
                rte
acia_mouse1:    ext.w   D0
                add.w   D0,mousey
                subq.w  #1,acia_mouse_flag
                movem.l (SP)+,D0-D1
                rte
acia_joy:       clr.w   acia_joy_flag
                tst.b   acia_joy_select
                bne.s   acia_joy2
                move.b  D0,joystick1
                movem.l (SP)+,D0-D1
                rte
acia_joy2:      move.b  D0,joystick0
                movem.l (SP)+,D0-D1
                rte
*****************************************************************************
; Soundchipinitialisierung (Lautsprecher beim Falcon wird ausgeschaltet!)
init_soundchip: moveq   #10,D0
                lea     $FFFF8800.w,A0
                lea     $FFFF8802.w,A1
init_soundchip_l0:move.b D0,(A0)
                clr.b   (A1)
                dbra    D0,init_soundchip_l0
                move.b  #7,(A0)
                move.b  #127,(A1)
                move.b  #14,(A0)
                move.b  #38+64,(A1)
                rts
*****************************************************************************
; VBL-Handler
vbl_handler:    ori     #$0700,SR
                movem.l D0-A6,-(SP)
                addq.l  #1,$0466.w
                move.w  system_flag(PC),D0
                and.w   #%1000,D0
                beq.s   vbl_handler_w2
                tst.b   falcon_monitor
                bne.s   vbl_handler_w2
                eori.b  #-1,falcon_monitor_extravbl
                beq.s   vbl_handler_w1
vbl_handler_w2: st      vsync_flag
                moveq   #15,D0
                lea     vbl_slots(PC),A0
                IF show_time<>0
                move.l  #160,$FFFF9800.w
                ENDC
vbl_handler_l0: movea.l (A0)+,A1
                cmpa.l  #0,A1
                beq.s   vbl_handler_w0
                movem.l D0/A0,-(SP)
                jsr     (A1)
                movem.l (SP)+,D0/A0
vbl_handler_w0: dbra    D0,vbl_handler_l0
vbl_handler_w1: IF show_time<>0
                clr.l   $FFFF9800.w
                ENDC
                movem.l (SP)+,D0-A6
                rte
; Add VBL-Rout
; .w   PrioritÑt (0=hoch..3=niedrig)
; .l   Adr. Routine
add_vblrout:    move.w  (A0)+,D0
                lsl.w   #4,D0
                lea     vbl_slots(PC),A1
                adda.w  D0,A1
                moveq   #3,D1
add_vblrout_l0: tst.l   (A1)+
                beq.s   add_vblrout_w0
                dbra    D1,add_vblrout_l0
                lea     add_vblrout_error0(PC),A0
                bra     error_exit
add_vblrout_w0: move.l  (A0)+,-(A1)
                rts
; Sub VBL-Rout
; .l   Adr. Routine
sub_vblrout:    move.l  (A0),D0
                lea     vbl_slots(PC),A0
                moveq   #15,D1
sub_vblrout_l0: cmp.l   (A0)+,D0
                beq.s   sub_vblrout_w0
                dbra    D1,sub_vblrout_l0
                lea     sub_vblrout_error0(PC),A0
                bra     error_exit
sub_vblrout_w0: clr.l   -(A0)
                rts
*****************************************************************************
; SUBSKRIPT & RETURN
; Aufruf von "Unterskripts", vergleichbar mit Unterprogrammen, und RÅckkehr
; zum letzten "Oberskript". Es sind 16 Verschachtelungen erlaubt.
; .l  Adr. des Subskripts
subskript:      cmpi.b  #15,subskript_tiefe
                blt.s   subskript_w0
                BREAKPT '; SUBSKIPT-Verschachtelung Åberschritten!'
subskript_w0:   addq.b  #1,subskript_tiefe
                movea.l subskript_stackpos(PC),A1
                move.l  main_skriptpos(PC),-(A1)
                move.l  A1,subskript_stackpos
                move.l  (A0),main_skriptpos
                rts
return:         tst.b   subskript_tiefe
                bne.s   return_w0
                BREAKPT '; RETURN auûerhalb eines Subskripts!'
return_w0:      subq.b  #1,subskript_tiefe
                movea.l subskript_stackpos(PC),A1
                move.l  (A1)+,main_skriptpos
                move.l  A1,subskript_stackpos
                rts
*****************************************************************************
; Warteroutinen
; Anz. VBLs warten
; .w  Anz. der VBLs
wvbl_anz:       move.w  (A0)+,D0
wvbl_anz_l1:    sf      vsync_flag
wvbl_anz_l0:    tst.b   vsync_flag
                beq.s   wvbl_anz_l0
                dbra    D0,wvbl_anz_l1
                rts
; NÑchsten VBL abwarten
wvbl:           IF show_time
                move.l  #160,$FFFF9800.w
                ENDC
                sf      vsync_flag
wvbl_l0:        tst.b   vsync_flag
                beq.s   wvbl_l0
                IF show_time
                clr.l   $FFFF9800.w
                ENDC
                rts
; Auf Ende der öberblendung warten
wait_swap_colors:tst.b  swap_colors_ready
                beq.s   wait_swap_colors
                rts
; Auf Space warten
wait_for_space: cmpi.b  #57,key
                bne.s   wait_for_space
wait_for_space_l0:cmpi.b #57,key
                beq.s   wait_for_space_l0
                rts
; Auf eine mindestzahl von vergangenen VBLs warten
wait_timer:     move.l  D0,-(SP)
                move.l  (A0)+,D0
wait_time_l0:   cmp.l   $0466.w,D0
                bgt.s   wait_time_l0
                move.l  (SP)+,D0
                rts
clear_timer:    clr.l   $0466.w
                rts
*****************************************************************************
; SetRes-Routinen (FÅr Falcon...)
; .l  Zeiger auf eine mit GetVideo erzeugte VDO-Sequenz.
set_falconres:  bsr.s   wvbl
                movea.l (A0)+,A0
                move.w  (A0)+,$FFFF8260.w
                move.w  (A0)+,$FFFF8266.w ;Falcon Shift Mode
                move.l  (A0)+,$FFFF8282.w ;Horiz. Hold Timer + H. Border Begin
                move.l  (A0)+,$FFFF8286.w ;H. Border End + H. Display Begin
                move.l  (A0)+,$FFFF828A.w ;H. Display End + H. Sync Start
                move.l  (A0)+,$FFFF82A2.w ;Vert. Freq. Timer + V. Border Begin
                move.l  (A0)+,$FFFF82A6.w ;V. Border End + V. Display Begin
                move.l  (A0)+,$FFFF82AA.w ;V. Display End + V. Sync Start
                move.l  (A0)+,$FFFF82C0.w ;Video Control + Video Mode
                move.w  (A0)+,$FFFF8210.w ;line wide
                rts
*****************************************************************************
; öberblend-Routinen (Kein TrueColor!)
; .l  Adr. Zielpalette
; .w  Anz. der Schritte (gesamt)
swap_16_colors: sf      swap_colors_ready
                lea     $FFFF8240.w,A1
                movea.l (A0)+,A2
                move.w  (A0),D6
                move.w  D6,swap_colors_count
                lea     swap_colors_tab(PC),A3
                lea     swap_colors_aktcols(PC),A4
                lea     swap_16_colors_convtab(PC),A5
                moveq   #15,D0
swap_16_colors_l0:move.w (A1)+,D1
                move.w  (A2)+,D2
                move.w  D1,D3           ; Blue
                and.l   #$0F,D3
                move.b  0(A5,D3.w),D3
                move.w  D3,(A4)+
                clr.w   (A4)+
                move.w  D2,D4
                and.l   #$0F,D4
                move.b  0(A5,D4.w),D4
                sub.w   D3,D4
                spl     D7
                bpl.s   swap_16_colors_w0
                neg.w   D4
swap_16_colors_w0:divu  D6,D4
                move.w  D4,(A3)+
                divu    D6,D4
                move.w  D4,(A3)+
                tst.b   D7
                bne.s   swap_16_colors_w1
                neg.l   -4(A3)
swap_16_colors_w1:move.w D1,D3          ; Green
                lsr.w   #4,D3
                and.l   #$0F,D3
                move.b  0(A5,D3.w),D3
                move.w  D3,(A4)+
                clr.w   (A4)+
                move.w  D2,D4
                lsr.w   #4,D4
                and.l   #$0F,D4
                move.b  0(A5,D4.w),D4
                sub.w   D3,D4
                spl     D7
                bpl.s   swap_16_colors_w2
                neg.w   D4
swap_16_colors_w2:divu  D6,D4
                move.w  D4,(A3)+
                divu    D6,D4
                move.w  D4,(A3)+
                tst.b   D7
                bne.s   swap_16_colors_w3
                neg.l   -4(A3)
swap_16_colors_w3:lsr.w #8,D1           ; Red
                and.l   #$0F,D1
                move.b  0(A5,D1.w),D1
                move.w  D1,(A4)+
                clr.w   (A4)+
                lsr.w   #8,D2
                and.l   #$0F,D2
                move.b  0(A5,D2.w),D2
                sub.w   D1,D2
                spl     D7
                bpl.s   swap_16_colors_w4
                neg.w   D2
swap_16_colors_w4:divu  D6,D2
                move.w  D2,(A3)+
                divu    D6,D2
                move.w  D2,(A3)+
                tst.b   D7
                bne.s   swap_16_colors_w5
                neg.l   -4(A3)
swap_16_colors_w5:dbra  D0,swap_16_colors_l0
                pea     swap_16_colors_vblrout(PC)
                clr.w   -(SP)
                movea.l SP,A0
                bsr     add_vblrout
                addq.l  #6,SP
                rts
swap_16_colors_vblrout:lea $FFFF8240.w,A0
                lea     swap_colors_tab(PC),A1
                lea     swap_colors_aktcols(PC),A2
                lea     swap_16_colors_convtab2(PC),A3
                moveq   #15,D0
swap_16_c_vblrout_l0:move.l (A2),D1
                add.l   (A1)+,D1
                move.l  D1,(A2)+
                swap    D1
                moveq   #0,D2
                move.b  0(A3,D1.w),D2
                move.l  (A2),D1
                add.l   (A1)+,D1
                move.l  D1,(A2)+
                swap    D1
                move.b  0(A3,D1.w),D1
                lsl.w   #4,D1
                or.w    D1,D2
                move.l  (A2),D1
                add.l   (A1)+,D1
                move.l  D1,(A2)+
                swap    D1
                move.b  0(A3,D1.w),D1
                lsl.w   #8,D1
                or.w    D1,D2
                move.w  D2,(A0)+
                dbra    D0,swap_16_c_vblrout_l0
                subq.w  #1,swap_colors_count
                bne.s   swap_16_c_vblrout_w0
                pea     swap_16_colors_vblrout(PC)
                movea.l SP,A0
                bsr     sub_vblrout
                addq.l  #4,SP
                st      swap_colors_ready
swap_16_c_vblrout_w0:rts

swap_256_colors:sf      swap_colors_ready
                lea     $FFFF9800.w,A1
                movea.l (A0)+,A2
                move.w  (A0),D6
                move.w  D6,swap_colors_count
                lea     swap_colors_tab(PC),A3
                lea     swap_colors_aktcols(PC),A4
                moveq   #0,D2
                move.w  #255,D0
swap_256_colors_l0:moveq #0,D1
                move.l  (A1)+,D3
                move.b  (A2)+,D1
                move.l  D3,D2
                swap    D2
                lsr.w   #8,D2
                and.l   #$FF,D2
                move.w  D2,(A4)+
                clr.w   (A4)+
                sub.w   D2,D1
                spl     D7
                bpl.s   swap_256_colors_w0
                neg.w   D1
swap_256_colors_w0:divu D6,D1
                move.w  D1,(A3)+
                divu    D6,D1
                move.w  D1,(A3)+
                tst.b   D7
                bne.s   swap_256_colors_w1
                neg.l   -4(A3)
swap_256_colors_w1:moveq #0,D1
                move.b  (A2)+,D1
                move.l  D3,D2
                swap    D2
                and.l   #$FF,D2
                move.w  D2,(A4)+
                clr.w   (A4)+
                sub.w   D2,D1
                spl     D7
                bpl.s   swap_256_colors_w2
                neg.w   D1
swap_256_colors_w2:divu D6,D1
                move.w  D1,(A3)+
                divu    D6,D1
                move.w  D1,(A3)+
                tst.b   D7
                bne.s   swap_256_colors_w3
                neg.l   -4(A3)
swap_256_colors_w3:moveq #0,D1
                addq.l  #1,A2
                move.b  (A2)+,D1
                move.l  D3,D2
                and.l   #$FF,D2
                move.w  D2,(A4)+
                clr.w   (A4)+
                sub.w   D2,D1
                spl     D7
                bpl.s   swap_256_colors_w4
                neg.w   D1
swap_256_colors_w4:divu D6,D1
                move.w  D1,(A3)+
                divu    D6,D1
                move.w  D1,(A3)+
                tst.b   D7
                bne.s   swap_256_colors_w5
                neg.l   -4(A3)
swap_256_colors_w5:dbra D0,swap_256_colors_l0
                pea     swap_256_colors_vblrout(PC)
                clr.w   -(SP)
                movea.l SP,A0
                bsr     add_vblrout
                addq.l  #6,SP
                rts
swap_256_colors_vblrout:lea $FFFF9800.w,A0
                move.l  #$8F00008F,(A0)
                lea     swap_colors_tab(PC),A1
                lea     swap_colors_aktcols(PC),A2
                move.w  #255,D0
swap_256_c_vblrout_l0:move.l (A2),D1
                add.l   (A1)+,D1
                move.l  D1,(A2)+
                swap    D1
                moveq   #0,D2
                move.b  D1,D2
                move.l  (A2),D1
                add.l   (A1)+,D1
                move.l  D1,(A2)+
                swap    D1
                lsl.w   #8,D2
                move.b  D1,D2
                move.l  (A2),D1
                add.l   (A1)+,D1
                move.l  D1,(A2)+
                swap    D1
                swap    D2
                move.b  D1,D2
                move.l  D2,(A0)+
                dbra    D0,swap_256_c_vblrout_l0
                subq.w  #1,swap_colors_count
                bne.s   swap_256_c_vblrout_w0
                pea     swap_256_colors_vblrout(PC)
                movea.l SP,A0
                bsr     sub_vblrout
                addq.l  #4,SP
                st      swap_colors_ready
swap_256_c_vblrout_w0:rts
*****************************************************************************
; Entpackroutinen fÅr 1 Plane in 8-Plane-Pic; Cacheoptimierte Falcon-Version
; .l  Bildadresse
; .w  Plane-Offset (Plane-Nr. * 2)
                CNOP 4,16
depack_pic:     movea.l (A0)+,A2
                movea.l log_scr_adr(PC),A1
                movea.l (A1),A1
                adda.w  (A0),A1
                lea     $FFFF8A28.w,A0
                move.l  #-1,(A0)+
                move.w  #-1,(A0)+
                move.w  #16,2(A0)
                move.w  #1,10(A0)
                lea     13(A0),A0
                lea     -9(A0),A3
                lea     6(A3),A4
                move.w  #1,$FFFF8A36
                lea     1(A0),A5
                move.b  #%11000000,D3
                lea     depack_pic_c0(PC),A6
                move.w  #4000,D1
depack_pic_l0:  move.w  (A2)+,D0
                bmi.s   depack_pic_w0
                move.l  A1,(A3)
                bclr    #0,D0
                seq     (A0)
                adda.w  D0,A1
                lsr.w   #4,D0
                move.w  D0,(A4)
                move.b  D3,(A5)
                sub.w   D0,D1
                bgt.s   depack_pic_l0
                rts
depack_pic_w0:  add.w   D0,D1
                add.w   D0,D0
                add.w   D0,D0
                move.w  D0,D2
                add.w   D2,D2
                add.w   D2,D2
                suba.w  D2,A1
                jmp     0(A6,D0.w)
c               SET 50*16
                REPT 50
                move.w  (A2)+,-c(A1)
c               SET c-16
                ENDR
depack_pic_c0:  tst.w   D1
                bgt     depack_pic_l0
                rts
*****************************************************************************
; Module-Player (Falcon)
; Init und Deinit automatisch. Aufruf mit play_module
; .l  Adr. Module
init_modplayer: IF module_on<>0
*                        pea falconmodplayer(pc)
*                       movea.l sp,a0
*                      bsr reloziere
*                     addq.l #4,sp
                ENDC
                rts

play_module:    IF module_on=0
                rts
                ELSE
                moveq   #1,D0
                movea.l (A0),A0
                bsr.s   falconmodplayer ;ein
                rts

*                lea     savearea(PC),A0
*                ENDC
*                IF module_timer=0
*                move.l  timer_a_int.w,(A0)+
*                move.b  tacr.w,(A0)+
*                move.b  tadr.w,(A0)+
*                move.b  #246,tadr.w
*                move.b  #7,tacr.w
*                move.l  #module_timer_rout,timer_a_int.w
*                bset    #5,imra.w
*                bset    #5,iera.w
*                ELSE
*                move.l  timer_b_int.w,(A0)+
*                move.b  tbcr.w,(A0)+
*                move.b  tbdr.w,(A0)+
*                move.b  #246,tbdr.w
*                move.b  #7,tbcr.w
*                move.l  #module_timer_rout,timer_b_int.w
*                bset    #0,imra.w
*                bset    #0,iera.w
                ENDC
*                st      module_playflag
*                rts

stop_module:    IF module_on=0
                rts
                ENDC
*                IF (module_timer=0)&(module_on<>0)
*                bclr    #5,iera.w
*                bclr    #5,imra.w
*                lea     savearea(PC),A0
*                move.l  (A0)+,timer_a_int.w
*                move.b  (A0)+,tacr.w
*                move.b  (A0)+,tadr.w
*                ENDC
*                IF (module_timer<>0)&(module_on<>0)
*                bclr    #0,iera.w
*                bclr    #0,imra.w
*                lea     savearea(PC),A0
*                move.l  (A0)+,timer_b_int.w
*                move.b  (A0)+,tbcr.w
*                move.b  (A0)+,tbdr.w
*                ENDC
                IF module_on<>0
                bsr.s   falconmodplayer+2 ;aus
                sf      module_playflag
                ENDC
                rts

*module_timer_rout:IF module_on=0
*                rte
*                ELSE
*                movem.l D0-A6,-(SP)
*                bsr.s   falconmodplayer+36
*                movem.l (SP)+,D0-A6
*                ENDC
*                IF module_timer=0
*                bclr    #5,$FFFFFA0F.w
*                ELSE
*                bclr    #0,$FFFFFA0F.w
*                ENDC
*                rte

                IF module_on<>0
*savearea:       DS.B 6
                PATH 'E:\BITMSTR\'
falconmodplayer:IBYTES 'PLAY_DSP.INL'
                ENDC
*****************************************************************************
; 3D-Routinen
*****************************************************************************
; Colorcycling (Kein TrueColor!)
*****************************************************************************
; Zoomer&Rotator (Falcon, TrueColor)
*****************************************************************************
; Sternenfeld
*****************************************************************************
; Textkonverter
; .l  Text-Adresse (Textende=0.b)
; .l  Adr. Umwandlungstabelle
textkonverter:  movea.l (A0)+,A1
                movea.l (A0),A0
                moveq   #0,D0
textkonverter_l0:move.b (A1),D0
                beq.s   textkonverter_e
                move.b  0(A0,D0.w),(A1)+
                bra.s   textkonverter_l0
textkonverter_e:rts
*****************************************************************************
; Plane-Lîschroutine
; .w  Start-Offset (=2*plane_nr+planes_anz*40*startzeile)
; .w  Zeilenanzahl-1
clear_4_planes: movea.l log_scr_adr(PC),A1
                movea.l (A1),A1
                adda.w  (A0)+,A1
                move.w  (A0)+,D0
clear_4_planes_l0:
c               SET 0
                REPT 20
                clr.w   c(A1)
c               SET c+8
                ENDR
                adda.w  #160,A1
                dbra    D0,clear_4_planes_l0
                rts
clear_8_planes: movea.l log_scr_adr(PC),A1
                movea.l (A1),A1
                adda.w  (A0)+,A1
                move.w  (A0)+,D0
clear_8_planes_l0:
c               SET 0
                REPT 20
                clr.w   c(A1)
c               SET c+16
                ENDR
                adda.w  #320,A1
                dbra    D0,clear_8_planes_l0
                rts
*****************************************************************************
; SwapScreen etc.
swap_screens:   movea.l log_scr_adr(PC),A0
                movea.l phys_scr_adr(PC),A1
                move.l  (A0),D0
                move.l  (A1),(A0)
                move.l  D0,(A1)
                move.b  D0,D1
                lsr.l   #8,D0
                suba.l  A0,A0
                movep.w D0,$8201(A0)
                move.b  D1,$FFFF820D.w
                rts
*****************************************************************************
; Sprite-Routinen (16x16 Pixel)
*****************************************************************************
; DMA-Loader
*****************************************************************************
; Relozierroutine
; .l  Zeiger auf Routine
reloziere:      movea.l (A0),A0
                move.l  2(A0),D0
                add.l   6(A0),D0
                add.l   14(A0),D0
                adda.l  #$1C,A0
                move.l  A0,D1
                movea.l A0,A1
                movea.l A1,A2
                adda.l  D0,A1
                move.l  (A1)+,D0
                adda.l  D0,A2
                add.l   D1,(A2)
                clr.l   D0
reloziere_l0:   move.b  (A1)+,D0
                beq.s   reloziere_w0
                cmp.b   #1,D0
                beq.s   reloziere_l1
                adda.l  D0,A2
                add.l   D1,(A2)
                bra.s   reloziere_l0
reloziere_l1:   adda.l  #$FE,A2
                bra.s   reloziere_l0
reloziere_w0:   rts
*****************************************************************************
; Linienroutinen
*****************************************************************************
; PolyflÑchen-Zeichenroutinen (Eine Plane...)
*****************************************************************************
; Hardisk-Playroutine (HD-Recording...)
; hdplay_init (Initialisieren von der Playroutine)
; .l  Zeiger auf HD-Skript: .l  0 = Ende
;                               >0: LÑnge der Daten
;                                   .l Startposition im aktuellen File
;                               <0: -LÑnge der Daten
;                                   .l Pointer auf Dateinamen
;                                   .l Startposition im File
; Es wird MFP-Interrupt 7 benîtigt!
; hdplay (Mîglichst oft aufrufen; NICHT IM VBL!!!)
; hdplay_stop (Abbrechen...)
hdplay_init:    IF hdplay_used<>0
                sf      hdplay_fopen
                clr.b   $FFFF8901.w
                move.b  #2,$FFFF8937.w
                clr.w   $FFFF893A.w
                move.b  #hdplay_mode,$FFFF8921.w
                clr.b   $FFFF8920.w
                move.b  #1,$FFFF8900.w
                move.l  $013C.w,hdplay_oldmfp7
                move.l  #hdplay_intr,$013C.w
                bset    #7,$FFFFFA07.w
                bset    #7,$FFFFFA13.w
                bclr    #7,$FFFFFA0F.w
                move.l  #$090000,$FFFF8930.w
                clr.w   $FFFF8934.w
                move.l  (A0),hdplay_pl_ptr
                clr.l   hdplay_p_restln
                move.l  #hdplay_buf1,hdplay_bufptr1
                move.l  #hdplay_buf2,hdplay_bufptr2
                bsr     hdplay_load
                move.l  #hdplay_start,hdplay_next
                sf      hdplay_loadnext
                ENDC
                rts

hdplay:         IF hdplay_used<>0
                jmp     0
hdplay_next     EQU *-4
hdplay_start:   st      hdplay_on
                move.l  hdplay_bufptr1,D0
                move.l  D0,D1
                add.l   hdplay_buflen,D1
                subq.l  #1,D1
                suba.l  A0,A0
                bclr    #7,$FFFF8901.w
                move.b  D0,$FFFF8907.w
                lsr.l   #8,D0
                movep.w D0,$8903(A0)
                move.b  D1,$FFFF8913.w
                lsr.l   #8,D1
                movep.w D1,$890F(A0)
                move.b  #3,$FFFF8901.w
hdplay_start_l0:move.l  #hdplay_start_l2,hdplay_next
hdplay_start_l2:tst.b   hdplay_loadnext
                beq     hdplay_e
                sf      hdplay_loadnext
                move.l  hdplay_bufptr1,D0
                move.l  hdplay_bufptr2,hdplay_bufptr1
                move.l  D0,hdplay_bufptr2
                bsr     hdplay_load
                tst.l   hdplay_buflen
                beq.s   hdplay_start_w0
                move.l  hdplay_bufptr1,D0
                move.l  D0,D1
                add.l   hdplay_buflen,D1
                subq.l  #1,D1
                suba.l  A0,A0
                bclr    #7,$FFFF8901.w
                move.b  D0,$FFFF8907.w
                lsr.l   #8,D0
                movep.w D0,$8903(A0)
                move.b  D1,$FFFF8913.w
                lsr.l   #8,D1
                movep.w D1,$890F(A0)
                bra.s   hdplay_start_l0
hdplay_start_w0:move.b  #1,$FFFF8901.w
                move.l  #hdplay_start_l1,hdplay_next
hdplay_start_l1:tst.b   $FFFF8901.w
                bne.s   hdplay_e
                ENDC
hdplay_stop:    IF hdplay_used<>0
                clr.b   $FFFF8901.w
                tst.b   hdplay_fopen
                beq.s   hdplay_e
                bclr    #5,$FFFFFA07.w
                move.l  hdplay_oldmfp7,$013C.w
                move.w  hdplay_filehandle,-(SP)
                move.w  #$3E,-(SP)
                trap    #1
                addq.l  #4,SP
                sf      hdplay_fopen
                sf      hdplay_on
hdplay_e:       ENDC
                rts

                IF hdplay_used<>0
hdplay_intr:    st      hdplay_loadnext
                bclr    #7,$FFFFFA0F.w
                rte
                ENDC

hdplay_load:    IF hdplay_used<>0
                movea.l hdplay_pl_ptr,A6
                move.l  #hdplay_bufsize,D7
                move.l  hdplay_bufptr1,D5
                tst.l   hdplay_p_restln
                bgt.s   hdplay_load_w0
hdplay_load_l0: tst.l   (A6)
                beq     hdplay_load_w1
                move.l  (A6)+,hdplay_p_restln
                tst.l   hdplay_p_restln
                bgt.s   hdplay_load_w2
                neg.l   hdplay_p_restln
                tst.b   hdplay_fopen
                beq.s   hdplay_load_w3
                move.w  hdplay_filehandle,-(SP)
                move.w  #$3E,-(SP)
                trap    #1
                addq.l  #4,SP
                sf      hdplay_fopen
hdplay_load_w3: clr.w   -(SP)
                move.l  (A6)+,-(SP)
                move.w  #$3D,-(SP)
                trap    #1
                addq.l  #8,SP
                move.w  D0,hdplay_filehandle
                st      hdplay_fopen
hdplay_load_w2: clr.w   -(SP)
                move.w  hdplay_filehandle,-(SP)
                move.l  (A6)+,-(SP)
                move.w  #$42,-(SP)
                trap    #1
                lea     10(SP),SP
hdplay_load_w0: move.l  D7,D0
                cmp.l   hdplay_p_restln,D0
                blt.s   hdplay_load_w4
                move.l  hdplay_p_restln,D0
hdplay_load_w4: sub.l   D0,hdplay_p_restln
                move.l  D5,-(SP)
                move.l  D0,-(SP)
                move.w  hdplay_filehandle,-(SP)
                move.w  #$3F,-(SP)
                trap    #1
                lea     12(SP),SP
                add.l   D0,D5
                sub.l   D0,D7
                bgt     hdplay_load_l0
hdplay_load_w1: move.l  A6,hdplay_pl_ptr
                move.l  #hdplay_bufsize,hdplay_buflen
                sub.l   D7,hdplay_buflen
                ENDC
                rts
*****************************************************************************
; load
; .l  Zeiger fname, mit 0-Byte abgeschlossen
; .l  Zieladresse
; LÑdt eine Datei an die Zieladresse
load:           movea.l A0,A6
                clr.w   -(SP)
                move.l  (A6)+,-(SP)
                move.w  #$3D,-(SP)
                trap    #1
                addq.l  #8,SP
                move.w  D0,handle
                move.l  (A6),-(SP)
                move.l  #$7FFFFFFF,-(SP)
                move.w  handle(PC),-(SP)
                move.w  #$3F,-(SP)
                trap    #1
                lea     $0C(SP),SP
                move.w  handle(PC),-(SP)
                move.w  #$3E,-(SP)
                trap    #1
                addq.l  #4,SP
                rts
*****************************************************************************
; save
; .l  Zeiger fname, mit 0-Byte abgeschlossen
; .l  Startadresse
; .l  Anzahl Bytes
; Speichert den angegebenen Speicherbereich in eine Datei
save:           movea.l A0,A6
                clr.w   -(SP)
                move.l  (A6)+,-(SP)
                move.w  #$3C,-(SP)
                trap    #1
                addq.l  #8,SP
                move.w  D0,handle
                move.l  (A6)+,-(SP)
                move.l  (A6),-(SP)
                move.w  handle(PC),-(SP)
                move.w  #$40,-(SP)
                trap    #1
                lea     $0C(SP),SP
                move.w  handle(PC),-(SP)
                move.w  #62,-(SP)
                trap    #1
                addq.l  #4,SP
                rts
*****************************************************************************
; run_file
; .l  Zeiger auf fname, mit 0-Byte abgeschlossen
; .l  Zieladresse des Files
; LÑdt eine Programmdatei nach, reloziert diese und startet sie.
; Bei 4(sp) wird der Datei ein Zeiger auf den JDS-Block Åbergeben. RÅcksprung mit
; rts.
run_file:       move.l  A0,-(SP)
                bsr.s   load
                movea.l (SP)+,A0
                tst.l   D0
                bpl.s   run_file_w0
                lea     run_file_error0(PC),A0
                bra     error_exit
run_file_w0:    move.l  4(A0),-(SP)
                movea.l SP,A0
                bsr     reloziere
                movea.l (SP)+,A0
                pea     jds_block(PC)
                jsr     (A0)
                addq.l  #4,SP
                rts
*****************************************************************************
; set_scradr
; .l  Adresse von log_scr-Variable
; .l  Adresse von phys_scr-Variable
; Teilt den JDS-Funktionen die Adresse der beiden Variablen mit. So ist es
; mîglich, daû jedes Programm seine eigene Variablen hierfÅr hat und trotzdem
; die JDS-Funktionen benutzen kann.
set_scradr:     move.l  (A0)+,log_scr_adr
                move.l  (A0),phys_scr_adr
                rts
*****************************************************************************
; load_prog
; .l  Zeiger auf fname, mit 0-Byte abgeschlossen
; .l  Zieladresse des Files
; LÑdt eine Programmdatei nach, reloziert diese aber startet sie nicht.
load_prog:      move.l  A0,-(SP)
                bsr     load
                movea.l (SP)+,A0
                tst.l   D0
                bpl.s   load_prog_w0
                lea     run_file_error0(PC),A0
                bra     error_exit
load_prog_w0:   move.l  4(A0),-(SP)
                movea.l SP,A0
                bsr     reloziere
                addq.l  #4,SP
                rts
*****************************************************************************
; run_prog
; .l  Adresse des mit load_prog geladenen Programmes
; Startet eine mit load_prog geladene Programmdatei
; Bei 4(sp) wird der Datei ein Zeiger auf den JDS-Block Åbergeben. RÅcksprung mit
; rts.
run_prog:       movea.l (A0),A0
                pea     jds_block(PC)
                jsr     (A0)
                addq.l  #4,SP
                rts
*****************************************************************************
; depack_ice
; .l  Zeiger auf die zu entpackenden Daten
; Entpackt die Daten in ihrem Bereich. Es wird Ice 2.4 verwendet.
depack_ice:     movem.l D0-A6,-(SP)
                movea.l (A0),A0
                bsr.s   depack_ice_s0
                movem.l (SP)+,D0-A6
                rts
                PATH 'D:\TURBOASS\JDS\'
depack_ice_s0:  IBYTES 'ICE_2_4.INL'
*****************************************************************************
; run_packed_file
; .l  Zeiger auf fname, mit 0-Byte abgeschlossen
; .l  Zieladresse des Files
; LÑdt eine Programmdatei nach, entpackt, reloziert und startet diese.
; Bei 4(sp) wird der Datei ein Zeiger auf den JDS-Block Åbergeben. RÅcksprung mit
; rts.
run_packed_file:move.l  A0,-(SP)
                bsr     load
                movea.l (SP)+,A0
                tst.l   D0
                bpl.s   run_packed_file_w0
                lea     run_file_error0(PC),A0
                bra     error_exit
run_packed_file_w0:
                move.l  4(A0),-(SP)
                movea.l SP,A0
                bsr     depack_ice
                movea.l SP,A0
                bsr     reloziere
                movea.l (SP)+,A0
                pea     jds_block(PC)
                jsr     (A0)
                addq.l  #4,SP
                rts
*****************************************************************************
; load_packed_prog
; .l  Zeiger auf fname, mit 0-Byte abgeschlossen
; .l  Zieladresse des Files
; LÑdt eine Programmdatei nach, entpackt und reloziert diese, aber startet sie
; nicht.
load_packed_prog:
                move.l  A0,-(SP)
                bsr     load
                movea.l (SP)+,A0
                tst.l   D0
                bpl.s   load_packed_prog_w0
                lea     run_file_error0(PC),A0
                bra     error_exit
load_packed_prog_w0:
                move.l  4(A0),-(SP)
                movea.l SP,A0
                bsr     depack_ice
                movea.l SP,A0
                bsr     reloziere
                addq.l  #4,SP
                rts

                ENDPART
                >PART 'TEXT Dentro-Init'
; Intialisierung von Bildschirmen und Daten
dentro_init:    move.l  #screen0,phys_scr
                move.l  #screen1,log_scr
                pea     phys_scr(PC)
                pea     log_scr(PC)
                movea.l SP,A0
                bsr     set_scradr
                addq.l  #8,SP
                bsr     swap_screens
                bsr     init_modplayer
                move.b  #%11010111,$FFFF8007.w
                clr.l   $FFFF9800.w
                rts
dentro_deinit:  bsr     stop_module
                rts
                ENDPART
                >PART 'TEXT Programm'
rout:
                rts
                ENDPART

*******************************************************************************
                DATA
                >PART 'DATA Dentro-System'
                IF kill_bugaboo<>0
new_vbr:        REPT 256
                DC.L dummy_rte
                ENDR
                ENDC
                IF kill_bugaboo<>0
vbr             SET new_vbr
                ELSE
vbr             SET 0
                ENDC
dentro_info:    DC.B 27,"EHere it is: The Dentro-Info!",13,10,10
                DC.B "Fried Bits '94 - Party-Dentro for Falcon 030.",13,10,10
                DC.B "Based on Julian Dentro-System Version 940310",13,10
                DC.B "JDS is a TFC-product by Lucky of ST",13,10,10
                DC.B "Code......: Lucky of ST (TFC)",13,10
                DC.B "            Nightmare (TFC)",13,10
                DC.B "            Pater Michael (Inter)",13,10
                DC.B "Gfx.......: Samurai (Inter)",13,10
                DC.B "            CD-ROM",13,10
                DC.B "            GFA-Basic",13,10
                DC.B "Music.....: Stax (Lazer)",13,10
                DC.B "DSP-Player: bITmASTER (BSW)",13,10,10
                DC.B "(c) 1994 TFC ~ Member of Crystal Corps",13,10,10,10
                DC.B 'To contact us write to: "Nightmare"',13,10
                DC.B "                        Andreas Niemann",13,10
                DC.B "                        Hindenburgstr. 5",13,10
                DC.B "                        23684 Pînitz",13,10
                DC.B "                        Germany",0
ds_error0:      DC.B 27,'EWrong system! I run on',13,10
                IF system_mask&%1
                DC.B 'ST',13,10
                ENDC
                IF system_mask&%10
                DC.B 'STE',13,10
                ENDC
                IF system_mask&%100
                DC.B 'Mega STE',13,10
                ENDC
                IF system_mask&%1000
                DC.B 'Falcon 030',13,10
                ENDC
                IF system_mask&%10000
                DC.B 'TT',13,10
                ENDC
                DC.B 13,'Sorry...',0
monochrome_error:DC.B 'Sorry! I do not run on monochrome!',0
error_txt:      DC.B 'FEHLER! Die Nummer der Skriptposition steht in main_skriptpos. Beschreibung:',13,10,0
add_vblrout_error0:DC.B 'Kein VBL-Slot in der genannten PrioritÑt frei.',0
sub_vblrout_error0:DC.B 'Genannte VBL-Routine ist nicht installiert.',0
run_file_error0:DC.B 'Programmdatei nicht gefunden.',0
                EVEN
swap_16_colors_convtab:DC.B 0,2,4,6,8,10,12,14,1,3,5,7,9,11,13,15
swap_16_colors_convtab2:DC.B 0,8,1,9,2,10,3,11,4,12,5,13,6,14,7,15

mousex_adr:     DC.L mousex
mousey_adr:     DC.L mousey
mousek_adr:     DC.L mousek
joystick0_adr:  DC.L joystick0
joystick1_adr:  DC.L joystick1
key_adr:        DC.L key

* öbergabeblock fÅr Nachlade-Routinen *
mousex:         DS.W 1
mousey:         DS.W 1
mousek:         DS.B 1
joystick0:      DS.B 1
joystick1:      DS.B 1
key:            DS.B 1
jds_block:
log_scr_adr:    DC.L log_scr
phys_scr_adr:   DC.L phys_scr
                DC.L dentro_exit,init_soundchip,add_vblrout,sub_vblrout
                DC.L subskript,return,wvbl_anz,wvbl,wait_swap_colors
                DC.L wait_for_space,set_falconres,swap_16_colors,swap_256_colors
                DC.L depack_pic,play_module,textkonverter,clear_4_planes
                DC.L clear_8_planes,swap_screens,reloziere,hdplay_init,hdplay,hdplay_stop
                DC.L load,save,run_file,set_scradr,load_prog,run_prog
                DC.L wait_timer,clear_timer,depack_ice,run_packed_file
                DC.L load_packed_prog
***************************************

                EVEN
                ENDPART
                >PART 'DATA Ablauf-Skript'
ablauf_skript:  DC.L b0,wvbl
b0:                                     *    dc.l b1,rout
*                DC.L b0x,run_file,fire,load_with_screen
b0x:                                    *           dc.l b1,run_file,gang,load_with_screen
b1:                                     *          dc.l b2,run_file,ball,load_with_screen
b2:                                     *         dc.l b3,run_file,triball,load_with_screen
b3:                                     *        dc.l b4,run_file,pudding,load_with_screen
b4:             DC.L e,run_file,blender,load_with_screen
*            dc.l e,wait_for_space
e:              DC.L 0,dentro_exit
gang:           DC.B "e:\f_bits.94\w_stein\w_stein.exe",0
fire:           DC.B "e:\f_bits.94\fire\fire.exe",0
comanche:       DC.B "e:\f_bits.94\executes.rgb\comanche.exe",0
ball:           DC.B "e:\f_bits.94\f_kugeln\trueball.prg",0
triball:        DC.B "e:\f_bits.94\triball\triball.prg",0
pudding:        DC.B "e:\f_bits.94\glas_kuh\pudding.exe",0
blender:        DC.B "d:\turboass\michael\delusion\sa_blend.prg",0
                EVEN

                ENDPART
                >PART 'DATA Programm'
                ENDPART

*******************************************************************************
                BSS
                >PART 'BSS Dentro-System'
log_scr:        DS.L 1
phys_scr:       DS.L 1
module_playflag:DS.B 1
subskript_tiefe:DS.B 1
subskript_stackpos:DS.L 1
subskript_stack:DS.L 16
system_flag:    DS.W 1
main_skriptpos: DS.L 1
main_skriptnr:  DS.W 1
vbl_slots:      DS.L 16
original_sp:    DS.L 1
error_adr:      DS.L 1
vsync_flag:     DS.B 1
falcon_monitor: DS.B 1
falcon_monitor_extravbl:DS.B 1
swap_colors_ready:DS.B 1
swap_colors_tab:DS.L 768
swap_colors_aktcols:DS.L 768
swap_colors_count:DS.W 1
acia_joy_flag:  DS.W 1
acia_mouse_flag:DS.W 1
acia_joy_select:DS.B 1
                EVEN
handle:         DS.W 1
                IF hdplay_used<>0
hdplay_loadnext:DS.B 1
hdplay_fopen:   DS.B 1
hdplay_pl_ptr:  DS.L 1
hdplay_p_restln:DS.L 1
hdplay_bufptr1: DS.L 1
hdplay_bufptr2: DS.L 1
hdplay_buflen:  DS.L 1
hdplay_filehandle:DS.W 1
hdplay_oldmfp7: DS.L 1
hdplay_on:      DS.B 1
                DS.L 1
hdplay_buf1:    REPT hdplay_bufsize/10000
                DS.L 2500
                ENDR
hdplay_buf2:    REPT hdplay_bufsize/10000
                DS.L 2500
                ENDR
                ENDC
                ENDPART
                >PART 'BSS Programm'
                ENDPART
                DS.W 384*10
                >PART 'BSS Allgemeine Daten'
load_without_screen:
                CNOP 0,4
screen0:        DS.L 46080
                DS.W 384*10
screen1:        DS.L 46080
                ENDPART
                DS.W 384*10
load_with_screen:
prg_ende:       END

                >PART 'JDS-Dokumentation'
; Julian Dentro System - Kurzdokumentation der Befehle
;
;
; dentro_exit
; Dentro Abbrechen und verlassen.
;
; init_soundchip
; Soundchipinitialisierung (Lautsprecher beim Falcon wird ausgeschaltet!)
;
; add_vblrout
; .w   PrioritÑt (0=hoch..3=niedrig)
; .l   Adr. Routine
; Neue VBL-Routine installieren
;
; sub_vblrout
; .l   Adr. Routine
; VBL-Routine aus seinem Slot entfernen
;
; subskript
; .l  Adr. des Subskripts
; Aufruf von "Unterskripts", vergleichbar mit Unterprogrammen, und RÅckkehr
;
; return
; Zum letzten "Oberskript" zurÅckkehren. Es sind 16 Verschachtelungen erlaubt.
;
; wvbl_anz
; .w  Anz. der VBLs
; Wartet eine bestimmte Anzahl von VBLs.
;
; wvbl
; Wartet auf den nÑchsten VBL.
;
; wait_swap_colors
; Auf Ende der öberblendung warten
;
; wait_for_space
; Auf Space warten
;
; set_falconres
; .l  Zeiger auf eine mit GetVideo erzeugte VDO-Sequenz.
; Auflîsung beim Falcon setzen
;
; swap_16_colors
; swap_256_colors
; .l  Adr. Zielpalette
; .w  Anz. der Schritte (gesamt)
; öberblend-Routinen fÅr 16 und 256 Farben
;
; depack_pic
; .l  Bildadresse
; .w  Plane-Offset (Plane-Nr. * 2)
; Entpackroutinen fÅr 1 Plane in 8-Plane-Pic; Cacheoptimierte Falcon-Version
;
; play_module
; .l  Adr. Module
; Module-Player (Falcon)
; Init und Deinit automatisch. Vorzeitig mit stop_module stoppen.
;
; textkonverter
; .l  Text-Adresse (Textende=0.b)
; .l  Adr. Umwandlungstabelle
; Wandelt ASCII-Text in beliebiges andere Format um.
;
; clear_4_planes
; clear_8_planes
; .w  Start-Offset (=2*plane_nr+planes_anz*40*startzeile)
; .w  Zeilenanzahl-1
; Plane-Lîschroutinen. Lîscht jeweils nur eine Plane...
;
; swap_screens
; Wechselt zwischen Logischen und Physikalischen Bildschirm.
;
; reloziere
; .l  Zeiger auf Routine
; Relozierroutine (fÅr nachgeladene Programme etc.)
;
; Hardisk-Playroutine (HD-Recording...)
; hdplay_init (Initialisieren von der Playroutine)
; .l  Zeiger auf HD-Skript: .l  0 = Ende
;                               >0: LÑnge der Daten
;                                   .l Startposition im aktuellen File
;                               <0: -LÑnge der Daten
;                                   .l Pointer auf Dateinamen
;                                   .l Startposition im File
; Es wird MFP-Interrupt 7 benîtigt!
; hdplay (Mîglichst oft aufrufen; NICHT IM VBL!!!)
; hdplay_stop (Abbrechen...)
;
; load
; .l  Zeiger fname, mit 0-Byte abgeschlossen
; .l  Zieladresse
; LÑdt eine Datei an die Zieladresse
;
; save
; .l  Zeiger fname, mit 0-Byte abgeschlossen
; .l  Startadresse
; .l  Anzahl Bytes
; Speichert den angegebenen Speicherbereich in eine Datei
;
; run_file
; .l  Zeiger auf fname, mit 0-Byte abgeschlossen
; .l  Zieladresse des Files
; LÑdt eine Programmdatei nach, reloziert diese und startet sie.
; Bei 4(sp) wird der Datei ein Zeiger auf den JDS-Block Åbergeben. RÅcksprung mit
; rts.
;
; set_scradr
; .l  Adresse von log_scr-Variable
; .l  Adresse von phys_scr-Variable
; Teilt den JDS-Funktionen die Adresse der beiden Variablen mit. So ist es
; mîglich, daû jedes Programm seine eigene Variablen hierfÅr hat und trotzdem
; die JDS-Funktionen benutzen kann.
;
; load_prog
; .l  Zeiger auf fname, mit 0-Byte abgeschlossen
; .l  Zieladresse des Files
; LÑdt eine Programmdatei nach, reloziert diese aber startet sie nicht.
; Bei 4(sp) wird der Datei ein Zeiger auf den JDS-Block Åbergeben. RÅcksprung mit
; rts.
;
; run_prog
; .l  Adresse des mit load_prog geladenen Programmes
; Startet eine mit load_prog geladene Programmdatei
; Bei 4(sp) wird der Datei ein Zeiger auf den JDS-Block Åbergeben. RÅcksprung mit
; rts.
;
; wait_timer
; .l  Mindestzahl der VBLs
; Wartet, bis der VBL-ZÑhler in $466.w (long) einen bestimmten Wert mindestens
; erreicht hat.
;
; clear_timer
; Lîscht den VBL-ZÑhler in $466.w (long).
;
; depack_ice
; .l  Zeiger auf die zu entpackenden Daten
; Entpackt die Daten in ihrem Bereich. Es wird Ice 2.4 verwendet.
;
; run_packed_file
; .l  Zeiger auf fname, mit 0-Byte abgeschlossen
; .l  Zieladresse des Files
; LÑdt eine Programmdatei nach, entpackt, reloziert und startet diese.
; Bei 4(sp) wird der Datei ein Zeiger auf den JDS-Block Åbergeben. RÅcksprung mit
; rts.
;
; load_packed_prog
; .l  Zeiger auf fname, mit 0-Byte abgeschlossen
; .l  Zieladresse des Files
; LÑdt eine Programmdatei nach, entpackt und reloziert diese, aber startet sie
; nicht.
                ENDPART
                END
