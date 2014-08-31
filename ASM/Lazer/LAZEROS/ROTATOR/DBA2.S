                        >PART 'EQU JDS'
jds                     EQU 2 ; 0 = Routine mit JDS (NUR MIT JDS-SOURCEN!!!)
;                               1 = Unterroutine vom JDS; wird nachgeladen und
;                                   soll die JDS-Routinen Åber deren Offset
;                                   anspringen... (SA-Version)
;                               2 = DV-Version; JDS wird als File mit einge-
;                                   bunden. Zur Programmentwicklung von Modulen
;                                   ohne die ganzen JDS-Sourcen
jds_version             EQU 12
;
yes                     EQU -1
no                      EQU 0
nil                     EQU 0
;
module_on               EQU no
                        ENDPART
; WICHTIG: Beim Verlassen des Stand-Alone-Moduls wird ein Bereich von
;          184320 Bytes (384x240xTC) in den Bildspeicher vom JDS Åbertragen und
;          umgeschaltet. Sollte der benîtigte Bildspeicher grîûer sein, so
;          sollte COPY_PHYS_SCREEN auf 0 gesetzt werden.
; Wenn no_own_screens=yes, dann benutzt das Nachlademodul ausschlieûlich den
; öbergabe-Bildschirm des JDS! (Nur fÅr öberblend-Effekte interessant...)
; copy_phys_screen und no_own_screens haben nur eine Wirkung wenn SA-Version!
copy_phys_screen        EQU yes
no_own_screens          EQU no

                        OPT X+
                        OUTPUT 'S_ALONE.PRG'
                        >PART 'EQU Lucky'
scankey_esc             EQU 1
scankey_1               EQU 2
scankey_2               EQU 3
scankey_3               EQU 4
scankey_4               EQU 5
scankey_5               EQU 6
scankey_6               EQU 7
scankey_7               EQU 8
scankey_8               EQU 9
scankey_9               EQU 10
scankey_0               EQU 11
scankey_û               EQU 12
scankey_apostroph       EQU 13
scankey_backspace       EQU 14
scankey_tab             EQU 15
scankey_q               EQU 16
scankey_w               EQU 17
scankey_e               EQU 18
scankey_r               EQU 19
scankey_t               EQU 20
scankey_z               EQU 21
scankey_u               EQU 22
scankey_i               EQU 23
scankey_o               EQU 24
scankey_p               EQU 25
scankey_Å               EQU 26
scankey_plus            EQU 27
scankey_return          EQU 28
scankey_control         EQU 29
scankey_a               EQU 30
scankey_s               EQU 31
scankey_d               EQU 32
scankey_f               EQU 33
scankey_g               EQU 34
scankey_h               EQU 35
scankey_j               EQU 36
scankey_k               EQU 37
scankey_l               EQU 38
scankey_î               EQU 39
scankey_Ñ               EQU 40
scankey_#               EQU 41
scankey_milbe           EQU 43
scankey_y               EQU 44
scankey_x               EQU 45
scankey_c               EQU 46
scankey_v               EQU 47
scankey_b               EQU 48
scankey_n               EQU 49
scankey_m               EQU 50
scankey_komma           EQU 51
scankey_punkt           EQU 52
scankey_minus           EQU 53
scankey_space           EQU 57
scankey_f1              EQU 59
scankey_f2              EQU 60
scankey_f3              EQU 61
scankey_f4              EQU 62
scankey_f5              EQU 63
scankey_f6              EQU 64
scankey_f7              EQU 65
scankey_f8              EQU 66
scankey_f9              EQU 67
scankey_f10             EQU 68
scankey_clrhome         EQU 71
scankey_cursor_up       EQU 72
scankey_minus_ziffblk   EQU 74
scankey_cursor_left     EQU 75
scankey_cursor_right    EQU 77
scankey_plus_ziffblk    EQU 78
scankey_cursor_down     EQU 80
scankey_insert          EQU 82
scankey_delete          EQU 83
scankey_shift_f1        EQU 84
scankey_shift_f2        EQU 85
scankey_shift_f3        EQU 86
scankey_shift_f4        EQU 87
scankey_shift_f5        EQU 88
scankey_shift_f6        EQU 89
scankey_shift_f7        EQU 90
scankey_shfit_f8        EQU 91
scankey_shift_f9        EQU 92
scankey_shift_f10       EQU 93
scankey_kleiner         EQU 96
scankey_undo            EQU 97
scankey_help            EQU 98
scankey_klammer_auf     EQU 99
scankey_klammer_zu      EQU 100
scankey_durch           EQU 101
scankey_mal             EQU 102
scankey_7_ziffblk       EQU 103
scankey_8_ziffblk       EQU 104
scankey_9_ziffblk       EQU 105
scankey_4_ziffblk       EQU 106
scankey_5_ziffblk       EQU 107
scankey_6_ziffblk       EQU 108
scankey_1_ziffblk       EQU 109
scankey_2_ziffblk       EQU 110
scankey_3_ziffblk       EQU 111
scankey_0_ziffblk       EQU 112
scankey_punkt_ziffblk   EQU 113
scankey_enter           EQU 114
scankey_alt_1           EQU 120
scankey_alt_2           EQU 121
scankey_alt_3           EQU 122
scankey_alt_4           EQU 123
scankey_alt_5           EQU 124
scankey_alt_6           EQU 125
scankey_alt_7           EQU 126
scankey_alt_8           EQU 127
scankey_alt_9           EQU 128
scankey_alt_0           EQU 129
scankey_alt_û           EQU 130
scankey_alt_apostroph   EQU 131
                        ENDPART

                        >PART 'Init JDS-Modul'
                        lea     _bssstart,A0
                        move.l  #(_bssende-_bssstart+3)/4-1,D1
_jdsloop1:              clr.l   (A0)+
                        subq.l  #1,D1
                        bpl.s   _jdsloop1

                        IF jds=2
                        tst.l   D0
                        bne     start_from_jds
                        lea     jds_include(PC),A0
                        move.l  2(A0),D0
                        add.l   6(A0),D0
                        add.l   14(A0),D0
                        adda.l  #$0000001C,A0
                        move.l  A0,D1
                        movea.l A0,A1
                        movea.l A1,A2
                        adda.l  D0,A1
                        move.l  (A1)+,D0
                        adda.l  D0,A2
                        add.l   D1,(A2)
                        clr.l   D0
initbin_reloziere_l0:   move.b  (A1)+,D0
                        beq.s   initbin_reloziere_w0
                        cmp.b   #1,D0
                        beq.s   initbin_reloziere_l1
                        adda.l  D0,A2
                        add.l   D1,(A2)
                        bra.s   initbin_reloziere_l0
initbin_reloziere_l1:   adda.l  #$000000FE,A2
                        bra.s   initbin_reloziere_l0
initbin_reloziere_w0:   lea     own_stack,A0
                        lea     start_from_jds(PC),A1
                        bra.s   jds_include
                        CNOP 0,16
                        PATH 'D:\JDS\'
jds_include:            IBYTES 'JDS.BIN'
                        EVEN
                        ENDC
; Initialisierung eines Nachlademoduls fÅr das JDS.
; Nicht als Subroutine aufrufen! Diese Sequenz muû als Programmstart stehen!
start_from_jds:         movea.l 4(SP),A0
                        move.l  A0,jds_block_adr
                        move.l  -26(A0),params_adr
                        move.l  -22(A0),background_color_oadr
                        move.l  #background_color_4,-22(A0)
                        move.l  -18(A0),background_color_4
                        move.l  -14(A0),background_color_8
                        move.l  -10(A0),background_color_tc
                        move.w  -2(A0),system_flag
                        move.l  (A0),log_orig_scr_adr
                        movea.l (A0),A1
                        move.l  (A1),log_scr
                        addq.l  #4,A0
                        move.l  (A0),phys_orig_scr_adr
                        movea.l (A0),A1
                        move.l  (A1),phys_scr
                        addq.l  #4,A0
                        move.l  (A0)+,dentro_exit+2
                        move.l  (A0)+,init_soundchip+2
                        move.l  (A0)+,add_vblrout+2
                        move.l  (A0)+,sub_vblrout+2
                        move.l  (A0)+,subskript+2
                        move.l  (A0)+,return+2
                        move.l  (A0)+,wvbl_anz+2
                        move.l  (A0)+,wvbl+2
                        move.l  (A0)+,wait_swap_colors+2
                        move.l  (A0)+,wait_for_space+2
                        move.l  (A0)+,set_falconres+2
                        move.l  (A0)+,swap_16_colors+2
                        move.l  (A0)+,swap_256_colors+2
                        move.l  (A0)+,depack_pic+2
                        move.l  (A0)+,play_module+2
                        move.l  (A0)+,textkonverter+2
                        move.l  (A0)+,clear_4_planes+2
                        move.l  (A0)+,clear_8_planes+2
                        move.l  (A0)+,swap_screens+2
                        move.l  (A0)+,reloziere+2
                        move.l  (A0)+,hdplay_init+2
                        move.l  (A0)+,hdplay+2
                        move.l  (A0)+,hdplay_stop+2
                        move.l  (A0)+,load+2
                        move.l  (A0)+,save+2
                        move.l  (A0)+,run_file+2
                        move.l  (A0)+,set_scradr+2
                        move.l  (A0)+,load_prog+2
                        move.l  (A0)+,run_prog+2
                        move.l  (A0)+,wait_timer+2
                        move.l  (A0)+,clear_timer+2
                        move.l  (A0)+,depack_ice+2
                        move.l  (A0)+,run_packed_file+2
                        move.l  (A0)+,load_packed_prog+2
                        move.l  (A0)+,copy_block+2
                        move.l  (A0)+,clear_block+2
                        move.l  (A0)+,mouse_on+2
                        move.l  (A0)+,mouse_off+2
                        move.l  (A0)+,inst_cache_on+2
                        move.l  (A0)+,inst_cache_off+2
                        move.l  (A0)+,data_cache_on+2
                        move.l  (A0)+,data_cache_off+2
                        move.l  (A0)+,cpu_16mhz+2
                        move.l  (A0)+,cpu_8mhz+2
                        move.l  (A0)+,blitter_16mhz+2
                        move.l  (A0)+,blitter_8mhz+2
                        move.l  (A0)+,shadowregs_on+2
                        move.l  (A0)+,shadowregs_off+2
                        move.l  (A0)+,clear_key_vectors+2
                        move.l  (A0)+,set_key_vector+2
                        move.l  (A0)+,clear_key_vector+2
                        move.l  (A0)+,calc_tc_ausblender+2
                        move.l  (A0)+,autoscroller_tc_init+2
                        move.l  (A0)+,autoscroller_tc+2
                        move.l  (A0)+,calc_sintab+2
                        move.l  (A0)+,wvbl_swap_screens+2
                        move.l  (A0)+,install_acia_block+2
                        move.l  (A0)+,destall_acia_block+2
                        move.l  (A0)+,wait_to_modpos+2
                        move.l  (A0)+,error_exit+2
                        move.l  (A0)+,depack_ifp+2
                        move.l  (A0)+,calc_zoomtab+2
                        move.l  (A0)+,zoom_dotfield+2
                        move.l  (A0)+,rotate_dotfield+2
                        move.l  (A0)+,calc_morphfield+2
                        move.l  (A0)+,calc_morphstep+2
                        move.l  (A0)+,set_background_color+2
                        move.l  (A0)+,blitter_on+2
                        move.l  (A0)+,blitter_off+2
                        move.l  (A0)+,fade_module+2
                        move.l  (A0)+,install_midi_handler+2
                        move.l  (A0)+,destall_midi_handler+2
                        move.l  (A0)+,swap_acia_vbl_routs+2
                        move.l  (A0)+,set_max_sample_anz+2
                        move.l  (A0)+,init_swap_256_colors+2
                        move.l  (A0)+,do_swap_256_colors+2

                        cmpi.l  #jds_version,8(SP)
                        blt     jds_version_error

                        pea     phys_scr
                        pea     log_scr
                        movea.l SP,A0
                        bsr     set_scradr
                        addq.l  #8,SP

                        pea     acia_block
                        movea.l SP,A0
                        bsr     install_acia_block
                        addq.l  #4,SP

                        move.l  SP,orig_sp
                        IF jds<>2
                        lea     own_stack,SP
                        ENDC
                        IF module_on<>0&jds=2
                        move.w  #100,-(SP)
                        move.w  #$7FFF,-(SP)
                        pea     module(PC)
                        movea.l SP,A0
                        bsr     play_module
                        addq.l  #8,SP
                        ENDC
                        movea.l params_adr(PC),A0
                        bsr     jdsrout_start
                        movea.l orig_sp,SP

                        pea     acia_block
                        movea.l SP,A0
                        bsr     destall_acia_block
                        addq.l  #4,SP

                        IF jds=2
                        bra.s   _jdsw1
                        ENDC
                        IF no_own_screens=yes
                        bra.s   _jdsw0
                        ENDC
                        IF copy_phys_screen=yes
                        movea.l phys_scr,A0
                        movea.l log_orig_scr_adr(PC),A1
                        movea.l (A1),A1
                        move.w  #46079,D0
_jdsloop0:              move.l  (A0)+,(A1)+
                        dbra    D0,_jdsloop0
                        ENDC
_jdsw0:                 move.l  phys_orig_scr_adr(PC),-(SP)
                        move.l  log_orig_scr_adr(PC),-(SP)
                        movea.l SP,A0
                        bsr     set_scradr
                        addq.l  #8,SP
                        IF no_own_screens=no
                        bsr     swap_screens
                        ENDC
_jdsw1:                 movea.l jds_block_adr,A0
                        move.l  background_color_oadr,-22(A0)
                        move.l  background_color_4,-18(A0)
                        move.l  background_color_8,-14(A0)
                        move.l  background_color_tc,-10(A0)
                        rts

jds_version_error:      lea     jds_version_error$(PC),A0
error_exit:             jmp     0
jds_version_error$:     DC.B "Modul setzt auf eine veraltete JDS-Version auf!",0
                        EVEN

dentro_exit:            jmp     0
init_soundchip:         jmp     0
add_vblrout:            jmp     0
sub_vblrout:            jmp     0
subskript:              jmp     0
return:                 jmp     0
wvbl_anz:               jmp     0
wvbl:                   jmp     0
wait_swap_colors:       jmp     0
wait_for_space:         jmp     0
set_falconres:          jmp     0
swap_16_colors:         jmp     0
swap_256_colors:        jmp     0
depack_pic:             jmp     0
play_module:            jmp     0
textkonverter:          jmp     0
clear_4_planes:         jmp     0
clear_8_planes:         jmp     0
swap_screens:           jmp     0
reloziere:              jmp     0
hdplay_init:            jmp     0
hdplay:                 jmp     0
hdplay_stop:            jmp     0
load:                   jmp     0
save:                   jmp     0
run_file:               jmp     0
set_scradr:             jmp     0
load_prog:              jmp     0
run_prog:               jmp     0
wait_timer:             jmp     0
clear_timer:            jmp     0
depack_ice:             jmp     0
run_packed_file:        jmp     0
load_packed_prog:       jmp     0
copy_block:             jmp     0
clear_block:            jmp     0
mouse_on:               jmp     0
mouse_off:              jmp     0
inst_cache_on:          jmp     0
inst_cache_off:         jmp     0
data_cache_on:          jmp     0
data_cache_off:         jmp     0
cpu_16mhz:              jmp     0
cpu_8mhz:               jmp     0
blitter_16mhz:          jmp     0
blitter_8mhz:           jmp     0
shadowregs_on:          jmp     0
shadowregs_off:         jmp     0
clear_key_vectors:      jmp     0
set_key_vector:         jmp     0
clear_key_vector:       jmp     0
calc_tc_ausblender:     jmp     0
autoscroller_tc_init:   jmp     0
autoscroller_tc:        jmp     0
calc_sintab:            jmp     0
wvbl_swap_screens:      jmp     0
install_acia_block:     jmp     0
destall_acia_block:     jmp     0
wait_to_modpos:         jmp     0
depack_ifp:             jmp     0
calc_zoomtab:           jmp     0
zoom_dotfield:          jmp     0
rotate_dotfield:        jmp     0
calc_morphfield:        jmp     0
calc_morphstep:         jmp     0
set_background_color:   jmp     0
blitter_on:             jmp     0
blitter_off:            jmp     0
fade_module:            jmp     0
install_midi_handler:   jmp     0
destall_midi_handler:   jmp     0
swap_acia_vbl_routs:    jmp     0
set_max_sample_anz:     jmp     0
init_swap_256_colors:   jmp     0
do_swap_256_colors:     jmp     0

log_orig_scr_adr:       DS.L 1
phys_orig_scr_adr:      DS.L 1
system_flag:            DS.W 1
params_adr:             DS.L 1

jdsrout_start:
                        ENDPART
                        >PART 'TEXT Programm'
x_size                  EQU 320
y_size                  EQU 256

; Geschwindigkeiten einstellen
rout:                   move.l  A0,-(SP)
                        bsr     shadowregs_on ; FALCON auf Full-Power
                        bsr     cpu_16mhz
                        bsr     blitter_16mhz
                        bsr     inst_cache_on
                        bsr     data_cache_on
; Bildschirme einrichten
                        lea     screen0,A0
                        lea     screen1,A1
                        move.l  A0,log_scr
                        move.l  A1,phys_scr
                        move.l  background_color_8,D1
                        moveq   #0,D1
                        move.w  #x_size*y_size/4-1,D0 ; * Diese Zeilen lîschen,
rout_l0:                move.l  D1,(A0)+ ;              * wenn der Bildschirm
                        move.l  D1,(A1)+ ;              * nicht gelîscht werden
                        dbra    D0,rout_l0 ;            * soll...
                        bsr     wvbl_swap_screens ;     *
                        pea     vmode(PC)
                        movea.l SP,A0
                        bsr     set_falconres
                        addq.l  #4,SP
                        movea.l (SP)+,A0
* Hier kommt die eigene Routine:
                        bsr.s   xxx

* Hier ist das Ende der Routine:
                        movea.l log_scr,A0 ;       * Diese Zeilen lîschen,
                        move.w  #x_size*y_size/2-1,D0 ;* wenn der Bildschirm
rout_l1:                clr.l   (A0)+   ;              * am Routinenende nicht
                        dbra    D0,rout_l1 ;           * gelîscht werden soll!
                        bsr     wvbl_swap_screens ;
                        rts
                        ENDPART
                        >PART 'XXX'
xxx:
                        addi.w  #20,$FFFF8284.w

                        bset    #0,$FFFF82C3.w

                        lea     maglogo+0*640*50+0*60(PC),A0
                        lea     orig_gfx,A1
                        move.w  #128-1,D0
mag_l0:                 move.w  #128-1,D1
mag_l1:
                        move.w  (A0),512(A1)
                        move.w  (A0),256(A1)
                        move.w  (A0),512+256(A1)
                        move.w  (A0)+,(A1)+
                        dbra    D1,mag_l1
;>                        lea     (320-128)*2(A0),A0
;>                        lea     512(A1),A1
                        lea     256+512(A1),A1
                        dbra    D0,mag_l0


                        bsr     mouse_on
                        bsr.s   singen
                        bsr.s   rotator

                        rts
                        ENDPART
                        >PART 'Taylor sinus generator'
;512 Werte im Padded-24-Format (fÅr den DSP geeignet !)
;d.h. 0 ... $007fffff ... 0 ... $00800001 ...
singen:
size                    EQU 512 ;nicht Ñndern !

sin_gen:                lea     sin,A0
                        moveq   #0,D6
                        lea     size*2+4(A0),A1
                        movea.l A0,A2
                        moveq   #size/4-1,D7
sin_gen1:               lea     sin_fakdiv+16,A3
                        move.l  D6,D5
                        moveq   #7,D2
sin_gen2:               move.w  D2,D1
                        move.l  D6,D3
sin_gen3:               mulu.l  D6,D4:D3
                        rol.l   #8,D3
                        rol.l   #8,D4
                        move.b  D3,D4
                        move.l  D4,D3
                        dbra    D1,sin_gen3
                        divs.l  -(A3),D3
                        add.l   D3,D5
                        subq.w  #2,D2
                        bcc.s   sin_gen2
sin_gen4:               asr.l   #1,D5
                        move.l  D5,(A0)+
                        move.l  D5,-(A1)
                        add.l   #$06487ED5/size,D6 ;2*pi*(2^24)
                        dbra    D7,sin_gen1
                        move.l  #$007FFFFF,-(A1)
                        lea     size(A1),A1
                        move.w  #size/2+size/4-1,D1
sin_gen6:               move.l  (A2)+,(A1)
                        neg.l   (A1)+
                        dbra    D1,sin_gen6
                        rts
                        ENDPART
                        >PART 'TEXT rotator'
rotator:
; Tabelle zum Abdunkeln berechnen
                        move.w  #2,-(SP)
                        pea     helltab
                        movea.l SP,A0
                        bsr     calc_tc_ausblender
                        addq.w  #6,SP
; Grafik doppeln
                        lea     orig_gfx+2*65536,A0
                        lea     gfx+4*65536,A1
                        lea     helltab,A2
                        moveq   #0,D1
                        move.w  #$00010000>>1-1,D0
rotator_gengfx_l0:      move.w  -(A0),D1
                        move.w  D1,-(A1)
                        move.w  0(A2,D1.l*2),-(A1)
                        move.w  -(A0),D1
                        move.w  0(A2,D1.l*2),-(A1)
                        move.w  D1,-(A1)
                        dbra    D0,rotator_gengfx_l0
; Inverse Grafik generieren
                        lea     gfx,A0
                        lea     inverse_gfx,A1
                        moveq   #-1,D0
rotator_genigfx_l0:     REPT 2
                        move.w  (A0)+,D1
;>                    eori.l  #-1,D1
                        move.w  D1,D2
                        move.w  D2,D3
                        and.w   #%0000000000011111,D1
                        and.w   #%0000011111100000,D2
                        and.w   #%1111100000000000,D3
                        ror.w   #5,D1
                        rol.w   #5,D3
                        or.w    D2,D1
                        or.w    D3,D1
                        move.w  D1,(A1)+
                        ENDR
                        dbra    D0,rotator_genigfx_l0
; Doubletab generieren...
abdunkelwert            EQU 4
                        lea     doubletab,A0
                        move.l  #$0000FFFF,D0
rota_gendouble_l0:      move.w  D0,D1
                        and.w   #%0000000000011111,D1
                        subq.w  #abdunkelwert,D1
                        bpl.s   rota_gendouble_w0
                        moveq   #0,D1
rota_gendouble_w0:      move.w  D0,D2
                        and.w   #%0000011111100000,D2
                        sub.w   #abdunkelwert<<6,D2
                        bmi.s   rota_gendouble_w2
                        or.w    D2,D1
rota_gendouble_w2:      move.w  D0,D2
                        and.w   #%1111100000000000,D2
                        sub.w   #abdunkelwert<<11,D2
                        bcs.s   rota_gendouble_w3
                        or.w    D2,D1
rota_gendouble_w3:      move.w  D1,0(A0,D0.l*4)
                        move.w  D1,2(A0,D0.l*4)
                        dbra    D0,rota_gendouble_l0

;Øw%=30
                        move.w  #0,w
;Øsi%=SINQ(w%)*65536

rotator_l0:
                        bsr     gen_rotdist

                        lea     sin,A0
                        move.w  w,D0
                        move.l  0(A0,D0.w*4),si


                        moveq   #8,D3
                        move.l  si,D6
                        asr.l   D3,D6
                        move.l  D6,si
;Øco%=COSQ(w%)*65536
                        lea     cos,A0
                        move.l  0(A0,D0.w*4),co

                        move.l  co,D6
                        asr.l   D3,D6
                        move.l  D6,co

                        lea     gfx+128*1024,A0
                        tst.b   inverse
                        beq.s   rotator_w2
                        adda.l  #256*256*4,A0
                        subq.b  #1,inverse
rotator_w2:             movea.l log_scr,A1
                        adda.l  #640*200/2,A1
                        lea     magnetic,A2

                        lea     rotdist+100*4,A4
;ØFOR y%=-50 TO 49
                        move.l  #-50,y
rotator_next_y:         move.l  -(A4),D6
                        cmp.l   #$00000A00,D6
                        ble.s   dorot
;>                        lea     -640(A1),A1
                        move.w  #640/4-1,D7
norot_l0:
                        move.l  -(A2),-(A1)
;>                        clr.l   -(A1)
                        dbra    D7,norot_l0
                        bra     norot
dorot:
;Øxstart%=(-50*faktor%) DIV 256
                        move.l  #-80,D3
                        muls    D6,D3
                        asr.l   #8,D3
;Øystart%=(y%*faktor%) DIV 256
                        move.l  y,D4
                        add.l   #70-20,D4
                        muls    D6,D4
                        asr.l   #8,D4
;Øxpos%=xstart%*si%+ystart%*co%
;Øypos%=ystart%*si%-xstart%*co%
                        move.l  D3,D0
                        move.l  D4,D1
                        muls.l  si,D0
                        muls.l  co,D4
                        add.l   D4,D0
                        muls.l  si,D1
                        muls.l  co,D3
                        sub.l   D3,D1
;Øxofs%=(si%*faktor%) DIV 256
                        move.l  si,D2
                        muls.l  D6,D2
                        clr.w   D2
                        swap    D2
;Øyofs%=-(co%*faktor%) DIV 256
                        move.l  co,D3
                        muls.l  D6,D3
                        asr.l   #8,D3
;ØFOR x%=0 TO 99
                        neg.l   D3
                        lsr.l   #8,D0
                        swap    D1
                        swap    D3
                        move.l  D1,D7
                        clr.w   D7
                        add.l   D7,D0
                        move.l  D3,D7
                        clr.w   D7
                        add.l   D7,D2
                        move.w  #160/10-1,D7
rotator_next_x:
;ØWORD{scrcntr%+(ypos% DIV 65536)*640+(xpos% DIV 65536)*2}=-1
; d0 xpos  yn|00|xv|xn
; d1 ypos  00|00|00|yv
; d2 xofs  yn|00|xv|xn
; d3 yofs  00|00|00|yv
                        REPT 10
                        move.w  D0,D4
                        move.b  D1,D4
                        move.l  0(A0,D4.w*4),-(A1)
                        add.l   D2,D0
                        addx.b  D3,D1
                        ENDR

;>                        add.l   #$70000050,D2
;>                        moveq   #0,D4
;>                        addx.b  D4,D3

;ØNEXT x%
                        dbra    D7,rotator_next_x
;ØADD faktor%,3

;ØNEXT y%
norot:
;>                        lea     -640(A1),A1
                        addq.l  #1,y
                        cmpi.l  #50,y
                        bne     rotator_next_y

                        addi.w  #3+2,w
                        cmpi.w  #512,w
                        blt.s   rotator_winkel_w0
                        subi.w  #512,w
rotator_winkel_w0:

                        tst.b   schrift_on
                        beq.s   rotator_w1
                        movea.l log_scr,A1
                        adda.l  schrift_pos,A1
                        movea.l schrift_block,A0
                        bsr     schrift
rotator_w1:

                        cmpi.b  #scankey_return,key
                        bne.s   rotator_w0
                        bsr     do_command
rotator_w0:

                        clr.l   $FFFF9800.w
                        bsr     wvbl_swap_screens
;>                        bsr     swap_screens
                        move.l  #160,$FFFF9800.w

                        bra     rotator_l0
                        rts
                        ENDPART
splinewerte:            DS.W 10
splines:                DC.W $A000,$A000,$A000,$0000
                        DC.W $0000,$0000,$0000,$0D00
                        DC.W $0000,$3000,-$1000,$3000+$2000
splinecnt:              DC.W 0

                        >PART 'TEXT Rotdist'
;> a = 60                      d0   <<20
;> b = 20
;> aofs = b/100                d1   <<20
;> h = 50                      d2   <<20
;Ø FOR c=0 TO 99               d3
;Ø   d=h/(TAN(RAD(a))/16)      d4
;Ø   PRINT #1,MKL$(d);
;Ø   ADD a,aofs
;Ø NEXT c

gen_rotdist:
                        lea     splinewerte,A0
                        lea     splines,A1
                        move.w  splinecnt,D0
                        moveq   #3-1,D6
                        bsr     spline

                        addi.w  #$0150,splinecnt
                        tst.w   splinecnt
                        bpl.s   gen_w0
                        bsr     wait_for_space
gen_w0:
                        andi.w  #$7FFF,splinecnt

                        lea     splinewerte,A0
                        moveq   #0,D0
;>                        BREAKPT ' '
                        move.w  (A0)+,D0
                        lsl.l   #8,D0
;>                        move.l  #10<<16<<4,D0

                        moveq   #0,D1
                        move.w  (A0)+,D1
                        lsl.l   #8,D1
;>                        swap    D1
;>                        lsr.l   #1,D1
;>                        move.l  #$000D0000,D1

                        moveq   #0,D2
                        move.w  (A0)+,D2
                        lsl.l   #8,D2
;>                        swap    D2
;>                        move.l  #$00300000,D2

                        IFNE 0
                        move.l  #10<<16<<4,D0
                        moveq   #0,D0

                        move.w  mousey,D2
                        cmp.w   #14,D2
                        bge.s   w4
                        moveq   #14,D2
w4:                     move.w  D2,mousey
                        swap    D2
                        clr.w   D2
                        move.l  #$00300000,D2

                        moveq   #0,D1
                        move.w  mousex,D1
                        ext.l   D1
                        bmi.s   gen_rotdist_m
;>                        neg.l   D1

                        lsl.l   #8,D1
                        lsl.l   #3,D1
;>                        cmp.l   #-$080000,D1
;>                        bge.s   w1
;>                        move.l  #-$080000,D1
;>                        BREAKPT ' '
;>
;>w1:

                        cmp.l   #$00080000,D1
                        ble.s   w0
                        move.l  #$00080000,D1
w0:
                        move.l  #$000D0000,D1
                        ENDC

                        lea     rotdist,A0
                        lea     tan,A1
                        moveq   #128-1,D3
gen_rotdist_l0:         move.l  D2,D4
                        move.l  D0,D5
                        swap    D5
                        ext.l   D5
                        divs.l  0(A1,D5.w*4),D4
                        move.l  D4,(A0)+
                        add.l   D1,D0
                        dbra    D3,gen_rotdist_l0
                        rts

gen_rotdist_m:
                        neg.l   D1

                        lsl.l   #8,D1
                        lsl.l   #3,D1

                        cmp.l   #$00080000,D1
                        ble.s   w1
                        move.l  #$00080000,D1
w1:
                        lea     rotdist+400,A0
                        lea     tan,A1
                        moveq   #100-1,D3
gen_rotdist_l1:         move.l  D2,D4
                        move.l  D0,D5
                        swap    D5
                        ext.l   D5
                        divs.l  0(A1,D5.w*4),D4
                        move.l  D4,-(A0)
                        add.l   D1,D0
                        dbra    D3,gen_rotdist_l1
                        rts
                        ENDPART
                        >PART 'Schrift'
; a0 BLOCK
; a1 screenpos
schrift:

                        move.l  schrift_sub,D6
                        sub.l   D6,brightness
                        bcc.s   schrift_w1
                        clr.w   brightness
schrift_w1:
                        move.w  brightness,D6
                        move.w  D6,D4
                        lsl.w   #5,D4
                        or.w    D6,D4
                        lsl.w   #6,D4
                        or.w    D6,D4
                        subq.w  #8,D6
                        bcc.s   schrift_w3
                        moveq   #0,D6
schrift_w3:             move.w  D6,D5
                        lsl.w   #5,D5
                        or.w    D6,D5
                        lsl.w   #6,D5
                        or.w    D6,D5

                        move.w  #31,D6
                        sub.w   brightness,D6
                        move.w  D6,D3
                        lsl.w   #5,D3
                        or.w    D6,D3
                        lsl.w   #6,D3
                        or.w    D6,D3
                        or.w    #%0000000000100000,D3
                        move.w  D3,D6
                        swap    D3
                        move.w  D6,D3

                        move.w  (A0)+,D7
                        move.w  (A0)+,D0

                        move.w  D0,D1
                        addq.w  #1,D1
                        movea.l A1,A6
schrift_l3:             movea.l A6,A5
                        move.w  D7,D6
schrift_l4:             REPT 4
                        clr.l   (A5)+
                        ENDR
                        dbra    D6,schrift_l4
                        lea     640*2(A6),A6
                        dbra    D1,schrift_l3

                        move.l  schrift_scroll,D6
                        add.l   D6,schrift_pos
                        adda.l  D6,A1
                        adda.l  D6,A1

schrift_l0:             move.w  D7,D6
                        movea.l A1,A3
schrift_l2:             move.b  (A0)+,D2
                        moveq   #8-1,D1
schrift_l1:             add.b   D2,D2
                        bcc.s   schrift_w0
                        move.w  D4,(A3)
                        or.w    D5,640(A3)
                        and.l   D3,642(A3)
                        and.l   D3,640*3+2(A3)

schrift_w0:             addq.w  #2,A3
                        dbra    D1,schrift_l1
                        dbra    D6,schrift_l2
                        lea     640*2(A1),A1
                        dbra    D0,schrift_l0
                        rts
                        ENDPART
                        >PART 'Do Command'
do_command:             movea.l cmd_pos,A0
                        move.w  (A0)+,D0
                        cmp.w   #cmd_schrift_on,D0
                        bne.s   do_cmd_w0
                        move.l  (A0)+,schrift_pos
                        move.l  (A0)+,schrift_block
                        clr.l   schrift_sub
                        move.l  #31<<16,brightness
                        clr.l   schrift_scroll
                        st      schrift_on
                        bra.s   do_cmd_e
do_cmd_w0:              cmp.w   #cmd_schrift_weg,D0
                        bne.s   do_cmd_w1
                        move.l  #$00010000,schrift_sub
                        move.l  #-640*2,schrift_scroll
                        bra.s   do_cmd_e
do_cmd_w1:              cmp.w   #cmd_schrift_off,D0
                        bne.s   do_cmd_w2
                        sf      schrift_on
                        bra.s   do_cmd_e
do_cmd_w2:
                        cmp.w   #cmd_inverse,D0
                        bne.s   do_cmd_w3
                        move.b  #3,inverse
                        bra.s   do_cmd_w3
do_cmd_w3:
                        lea     cmd_list,A0

do_cmd_e:               move.l  A0,cmd_pos
                        clr.b   key
                        rts
                        ENDPART
                        >PART 'Spline-Rout'
; a0 Zielspiecher fÅr die Spline-Werte
; a1 Spline-StÅtzpunkte
; d0 Counter (0-$7fff)
; d6 dimension der Spline-1 (normal 2-1)
                        IFNE 1
spline:
                        moveq   #15,D7
*       move.l  #$7FFF,D0 ; t%    d0
.l0:                    lea     tbuff,A2
                        move.l  D0,D1
                        eori.w  #$7FFF,D0 ; t2%   d1
                        move.w  D0,D2
                        move.w  D1,D3
                        mulu    D0,D2
                        lsr.l   D7,D2   ; t_2
                        move.w  D2,D4
                        mulu    D0,D4
                        lsr.l   D7,D4   ; t_3  >>1
                        move.w  D4,(A2)+
                        move.w  D1,D4
                        mulu    D2,D4
                        lsr.l   D7,D4   ; 3*t_2_m_t2 >>2
                        move.w  D4,(A2)+
                        mulu    D1,D3
                        lsr.l   D7,D3
                        move.w  D3,D4
                        mulu    D0,D4
                        lsr.l   D7,D4   ; 3*t_m_t2_2 >>3
                        move.w  D4,(A2)+
                        mulu    D1,D3
                        lsr.l   D7,D3   ; t2_3 >>4
                        move.w  D3,(A2)+
*       lea     spline_point,A0
*       moveq   #2-1,D6
*       lea     pts(PC),A1
.l1:                    lea     tbuff,A2
                        move.w  (A2)+,D1
                        muls    (A1)+,D1
                        REPT 2
                        move.w  (A2)+,D2
                        muls    (A1)+,D2
                        muls.l  #3,D2
                        add.l   D2,D1
                        ENDR
                        move.w  (A2)+,D2
                        muls    (A1)+,D2
                        add.l   D2,D1
                        add.l   D1,D1
                        swap    D1
                        move.w  D1,(A0)+
                        dbra    D6,.l1

*       sub.w   #200,D0 ; ZÑhler...
*       bpl     .l0
                        rts
                        ENDC
                        ENDPART

                        DATA
                        >PART 'DATA Programm'
                        PATH 'D:\JDS\SCP'
vmode:                  IBYTES 'R_TC__PF.SCP'
;>                        IBYTES 'DBA.SCP'

                        IF module_on<>0
module:                 PATH 'C:\'
                        IBYTES 'FOLLOW.MOD'
                        ENDC

                        ENDPART
                        >PART 'DATA Rotator'
                        PATH 'D:\4K'
maglogo:                IBYTES 'YY.TRU',,8
magnetic:

cmd_pos:                DC.L cmd_list

cmd_schrift_on          EQU 0
cmd_schrift_weg         EQU 1
cmd_last_cmd            EQU 2
cmd_schrift_off         EQU 3
cmd_inverse             EQU 4

cmd_list:
                        DC.W cmd_schrift_on
                        DC.L 640*88+320-10*8,block0
                        DC.W cmd_schrift_weg
                        DC.W cmd_schrift_on
                        DC.L 640*88+320-6*8,block1
                        DC.W cmd_schrift_weg
                        DC.W cmd_schrift_on
                        DC.L 640*88+320-9*8,block2
                        DC.W cmd_schrift_weg
                        DC.W cmd_schrift_off
                        DC.W cmd_inverse
                        DC.W cmd_last_cmd

                        PATH 'D:\4K\'
tan:                    IBYTES 'TAN.BIN'

sin_fakdiv:             DC.L -6,120,-5040,362880 ;-3!, 5!, -7!, 9!

block2:                 DC.W 9-1,7-1
                        DC.B %11100111,%00011100,%11111111,%11100111,%11111001,%11111110,%00000000,%00000000,%00000000
                        DC.B %11100111,%10011100,%00001110,%00000111,%00000001,%11000111,%00000000,%11000000,%00000000
                        DC.B %11100111,%11011100,%00001110,%00000111,%00000001,%11000111,%00000000,%00000000,%00000000
                        DC.B %11100111,%11111100,%00001110,%00000111,%11100001,%11001110,%11000110,%11001110,%01100011
                        DC.B %11100111,%01111100,%00001110,%00000111,%00000001,%11111100,%11000110,%11011011,%01101011
                        DC.B %11100111,%00111100,%00001110,%00000111,%00000001,%11001110,%01101100,%11011000,%01101011
                        DC.B %11100111,%00011100,%00001110,%00000111,%11111001,%11000111,%00111000,%11001111,%00110110

block0:                 DC.W 10-1,7-1
                        DC.W %1110000001110000,%1110011111100111,%0011101110111000,%0111110001111000
                        DC.W %0011111001111111
                        DC.W %1110000001110000,%1110111001110111,%0011101110111000,%1110111011101100
                        DC.W %0111011101111111
                        DC.W %1110000001110000,%1110111000000111,%0111001110111000,%1110111011100000
                        DC.W %0111000000011100
                        DC.W %1110000001110000,%1110111000000111,%1110000111110000,%1110111011111000
                        DC.W %0011111000011100
                        DC.W %1110000001110000,%1110111000000111,%0111000011100000,%1110111011100000
                        DC.W %0000011100011100
                        DC.W %1111111101110000,%1110111001110111,%0011100011100000,%1110111011100000
                        DC.W %0111011100011100
                        DC.W %1111111100111111,%1100011111100111,%0011100011100000,%0111110011100000
                        DC.W %0011111000011100

block1:                 DC.W 6-1,9-1
                        DC.W %0000000000000000,%0000000000000000,%0000110000000000
                        DC.W %0000000000000000,%0000000000000000,%0000111110000000
                        DC.W %1111000111001110,%0011100111001101,%1100111000011100
                        DC.W %1101101100011011,%0110001101101111,%0110110000110000
                        DC.W %1101101100011110,%0011001111001110,%0110110000011000
                        DC.W %1101101100011000,%0001101100001100,%0110110110001100
                        DC.W %1111001100001110,%0111000111001100,%0110011100111000
                        DC.W %1100000000000000,%0000000000000000,%0000000000000000
                        DC.W %1100000000000000,%0000000000000000,%0000000000000000

schrift_on:             DC.B 0
inverse:                DC.B 0
                        EVEN

                        PATH 'C:\'
orig_gfx:               IBYTES 'ORIG.TPI',,128
                        ENDPART

_bssstart:              BSS

                        >PART 'BSS Allgemein'
orig_sp:                DS.L 1
                        DS.B 8192
own_stack               EQU *

jds_block_adr:          DS.L 1
background_color_oadr:  DS.L 1
background_color_4:     DS.L 1
background_color_8:     DS.L 1
background_color_tc:    DS.L 1
phys_scr:               DS.L 1
log_scr:                DS.L 1
acia_block              EQU *
key:                    DS.B 1
joystick0:              DS.B 1
joystick1:              DS.B 1
mousek:                 DS.B 1
mousex:                 DS.W 1
mousey:                 DS.W 1
last_acia_block:        DS.L 1

                        ENDPART
                        >PART 'BSS Programm'

                        CNOP 0,4
screen0:                DS.L x_size*y_size/2
screen1:                DS.L x_size*y_size/2

                        ENDPART
                        >PART 'BSS Rotator'
rotdist:                DS.L 128
schrift_scroll:         DS.L 1
schrift_sub:            DS.L 1
schrift_pos:            DS.L 1
schrift_block:          DS.L 1
sin:                    DS.L 512/4
cos:                    DS.L 512
w:                      DS.W 1
si:                     DS.L 1
co:                     DS.L 1
y:                      DS.L 1
doubletab:              REPT 4
                        DS.L 65536/2
                        ENDR
brightness:             DS.L 1
helltab:                DS.L 65536/2
gfx:                    DS.L 256*256
inverse_gfx:            DS.L 256*256
                        ENDPART
tbuff:                  DS.L 6

_bssende:
prg_ende:               END

                        >PART 'JDS-Dokumentation'
; Julian Dentro System - Kurzdokumentation der Befehle
; Alle Routinen mit der Milbe (~) vor der Programmierer-Kennung sind mit
; Vorsicht zu geniesen. Sie wurden zwar implementiert aber noch nie verwendet
; bzw. getestet!
;
;
; dentro_exit                           Lucky
; Dentro Abbrechen und verlassen.
;
; init_soundchip                        Lucky
; Soundchipinitialisierung (Lautsprecher beim Falcon wird ausgeschaltet!)
;
; add_vblrout                           Lucky
; .w   PrioritÑt (0=hoch..3=niedrig)
; .l   Adr. Routine
; Neue VBL-Routine installieren
;
; sub_vblrout                           Lucky
; .l   Adr. Routine
; VBL-Routine aus seinem Slot entfernen
;
; subskript                             Lucky
; .l  Adr. des Subskripts
; Aufruf von "Unterskripts", vergleichbar mit Unterprogrammen in GFA
;
; return                                Lucky
; Zum letzten "Oberskript" zurÅckkehren. Es sind 16 Verschachtelungen erlaubt.
;
; wvbl_anz                              Lucky
; .w  Anz. der VBLs
; Wartet eine bestimmte Anzahl von VBLs.
;
; wvbl                                  Lucky
; Wartet auf den nÑchsten VBL.
;
; wvbl_swap_screens                     Lucky
; Wartet auf den nÑchsten VBL und vertauscht die Bildschirme.
;
; wait_swap_colors                      Lucky
; Auf Ende der öberblendung warten
;
; wait_for_space                        Lucky
; Auf Space warten
;
; wait_until_faded                      Lucky
; Warten, bis Modul auf Ziel gefaded
;
; set_falconres                         Lucky
; .l  Zeiger auf eine mit Screens Pain (Mugwumps/Aura) erzeugte SCP-Datei
; Auflîsung beim Falcon setzen
;
; swap_16_colors                        Lucky
; swap_256_colors                     ~ Lucky
; .l  Adr. Zielpalette
; .w  Anz. der Schritte (gesamt)
; öberblend-Routinen fÅr 16 und 256 Farben.
;
; depack_pic                            Lucky
; .l  Bildadresse
; .w  Plane-Offset (Plane-Nr. * 2)
; Entpackroutinen fÅr 1 Plane in 8-Plane-Pic; Cacheoptimierte Falcon-Version
; Eigenes Format, siehe "PACK.GFA"...
;
; play_module                           Lucky
; .l  Adr. Module
; .w  (Anfangs-)LautstÑrke (0=Laut; $40=Leise)
; .w  Surround-Delay (0..$800); 0 = Aus
; Module-Player (Falcon) [Routine von bITmASTER]
; Init und Deinit automatisch. Vorzeitig mit stop_module stoppen.
;
; stop_module                           Lucky
; Stopt das aktuelle Module.
;
; fade_module                           Lucky
; .w  ZiellautstÑrke
; .w  Speed (Anzahl VBLs)
; Fadet das aktuelle Modul ein/aus. FUNKTIONIERT MOMENTAN NICHT!
;
; wait_to_modpos                        Lucky
; Wartet auf ein 8-Kommando im Modul
;
; textkonverter                       ~ Lucky
; .l  Text-Adresse (Textende=0.b)
; .l  Adr. Umwandlungstabelle
; Wandelt ASCII-Text in beliebiges andere Format um.
;
; clear_4_planes                      ~ Lucky
; clear_8_planes                        Lucky
; .w  Start-Offset (=2*plane_nr+planes_anz*40*startzeile)
; .w  Zeilenanzahl-1
; Plane-Lîschroutinen. Lîscht jeweils nur eine Plane...
;
; swap_screens                          Lucky
; Wechselt zwischen Logischen und Physikalischen Bildschirm.
;
; reloziere                             Lucky
; .l  Zeiger auf Routine
; Relozierroutine (fÅr nachgeladene Programme etc.)
;
; Hardisk-Playroutine (HD-Recording...) Lucky
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
; load                                  Lucky
; .l  Zeiger fname, mit 0-Byte abgeschlossen
; .l  Zieladresse
; LÑdt eine Datei an die Zieladresse
;
; save                                  Lucky
; .l  Zeiger fname, mit 0-Byte abgeschlossen
; .l  Startadresse
; .l  Anzahl Bytes
; Speichert den angegebenen Speicherbereich in eine Datei
;
; run_file                              Lucky
; .l  Zeiger auf fname, mit 0-Byte abgeschlossen
; .l  Zieladresse des Files
; LÑdt eine Programmdatei nach, reloziert diese und startet sie.
; Bei 4(sp) wird der Datei ein Zeiger auf den JDS-Block Åbergeben. RÅcksprung mit
; rts.
;
; set_scradr                            Lucky
; .l  Adresse von log_scr-Variable
; .l  Adresse von phys_scr-Variable
; Teilt den JDS-Funktionen die Adresse der beiden Variablen mit. So ist es
; mîglich, daû jedes Programm seine eigene Variablen hierfÅr hat und trotzdem
; die JDS-Funktionen benutzen kann.
;
; load_prog                             Lucky
; .l  Zeiger auf fname, mit 0-Byte abgeschlossen
; .l  Zieladresse des Files
; LÑdt eine Programmdatei nach, reloziert diese aber startet sie nicht.
; Bei 4(sp) wird der Datei ein Zeiger auf den JDS-Block Åbergeben. RÅcksprung mit
; rts.
;
; run_prog                              Lucky
; .l  Adresse des mit load_prog geladenen Programmes
; Startet eine mit load_prog geladene Programmdatei
; Bei 4(sp) wird der Datei ein Zeiger auf den JDS-Block Åbergeben. RÅcksprung mit
; rts.
;
; wait_timer                            Lucky
; .l  Mindestzahl der VBLs
; Wartet, bis der VBL-ZÑhler in $466.w (long) einen bestimmten Wert mindestens
; erreicht hat.
;
; clear_timer                           Lucky
; Lîscht den VBL-ZÑhler in $466.w (long).
;
; depack_ice                            Lucky
; .l  Zeiger auf die zu entpackenden Daten
; Entpackt die Daten in ihrem Bereich. Es wird Ice 2.4 verwendet.
; ACHTUNG: Die Daten verlÑngern sich dabei natÅrlich!!!!
;
; run_packed_file                       Lucky
; .l  Zeiger auf fname, mit 0-Byte abgeschlossen
; .l  Zieladresse des Files
; LÑdt eine Programmdatei nach, entpackt, reloziert und startet diese.
; Bei 4(sp) wird der Datei ein Zeiger auf den JDS-Block Åbergeben. RÅcksprung mit
; rts.
;
; load_packed_prog                      Lucky
; .l  Zeiger auf fname, mit 0-Byte abgeschlossen
; .l  Zieladresse des Files
; LÑdt eine Programmdatei nach, entpackt und reloziert diese, aber startet sie
; nicht.
;
; copy_block                          ~ Nightmare
; .l  Adr. Quelle
; .l  Adr. Ziel
; .l  Anzahl Bytes
; Kopiert einen Speicherbereich. öberlappungen werden hierbei berÅcksichtigt.
;
; clear_block                         ~ Nightmare
; .l  Adr.
; .l  Anzahl Bytes
; Lîscht den angegebenen Speicherbereich
;
; mouse_on                              Nightmare
; mouse_off                             Nightmare
; Schaltet die Maus ein/aus
;
; inst_cache_on                         Nightmare
; inst_cache_off                        Nightmare
; Schalten den Befehls-Cache vom 68030er ein/aus.
;
; data_cache_on                         Nightmare
; data_cache_off                        Nightmare
; Schalten den Daten-Cache vom 68030er ein/aus.
;
; cpu_16mhz                             Nightmare
; cpu_8mhz                              Nightmare
; Stellen die CPU-Geschwindigkeit ein.
;
; blitter_16mhz                         Nightmare
; blitter_8mhz                          Nightmare
; Stellen die Blitter-Geschwindigkeit ein.
;
; shadowregs_on                         Nightmare
; shadowregs_off                        Nightmare
; Bestimmen, ob die ST-Shadowregister angeschaltet sind oder nicht.
;
; blitter_on                            Nightmare
; blitter_off                           Nightmare
; Schalten den Blitter ein bzw. aus
;
; clear_key_vectors                     Lucky
; Lîscht die Key-Vektoren vom Tastaturhandler.
;
; set_key_vector                        Lucky
; .w  Tasten-Scancode
; .l  Adr. Routine
; Setzt einen Keyvector auf die entsprechende Routine. Der Acia-Handler ruft
; diese automatisch auf, wenn die entsprechende Taste gedrÅckt wird.
; WICHTIG: Die Routine muû mit RTS enden und darf nur die Register D0-D1/A0
;          verÑndern! Alle anderen Register mÅssen von der Routine gerettet
;          werden. Die Routine sollte auch sehr kurz sein, da sie zur Laufzeit
;          des ACIA-Interrupts ausgefÅhrt wird!
;
; clear_key_vector                      Lucky
; .w  Tasten-Scancode
; Lîscht den Keyvector der angegebenen Taste
;
; calc_tc_ausblender                    Lucky
; .l  Zieladresse (Platz fÅr 32768 Longs!)
; .w  Abdunklungsgeschwindigkeit
; Berechnet eine Ausblend-Tabelle fÅr den TrueColor-Modus.
;
; autoscroller_tc_init                  Lucky
; autoscroller_tc                       Lucky
; .l  Adr. Scroll-Tabelle
; .w  X-Size in Pixeln
; Wartet auf den nÑchsten VBL, schaltet die Bildschirme um und zeigt den
; den neuen Bildschirm an der gewÅnschten Scrollposition an.
; An autoscroll_ready kann man sehen, ob das Scrollskript abgearbeitet ist (-1.b)
; autoscroll_tc_init muû vorher einmal aufgerufen werden.
; (TrueColor!) ==> Es kann nur auf gerade X-Offsets gescrollt werden!
;                  Hierbei wird automatisch gerundent...
;
; calc_sintab                           Lucky
; .l  Adr. der Zieltabelle (40960 Words):
;              Je Gradschritte 256 Bytes
;               255 = Drehung um 360 Grad
;              ==> Cosinus = Sinus + 256*64
; Berechnet eine Sinus/Cosinus-Tabelle in einem speziellen Format. Beispiel:
; Rotation um die X-Achse, wenn A0=Sinus xw, A1=Cosinus xw, d0=x, d1=y, d2=z
; Oberes Bytes von d0,d1,d2 jeweils=0 (!)
;                       move.w  d1,d4
;                       move.b  (a1,d1.w),d1
;                       add.b   (a0,d2.w),d1
;                       move.b  (a1,d2.w),d2
;                       sub.b   (a0,d4.w),d2
; Rotation um die Y-Achse, A2=Sinus yw, A3=Cosinus yw
;                       move.b  d0,d4
;                       move.b  (a3,d0.w),d0
;                       add.b   (a2,d2.w),d0
;                       move.b  (a3,d2.w),d2
;                       sub.b   (a2,d4.w),d2
; Rotation um die Z-Achse, A4=Sinus zw, A5=Cosinus zw
;                       move.b  d0,d4
;                       move.b  (a5,d0.w),d0
;                       add.b   (a4,d1.w),d0
;                       move.b  (a5,d1.w),d1
;                       sub.b   (a4,d4.w),d1
;
; rotate_dotfield                       Lucky
; A0.l  Adr. Quellpunktefeld (Je Punkt -128..127)
; A1.l  Adr. Zielpunktefeld
; A2.l  Adr. Sinus/Cosinus-Tabelle
; D0.l  xw (0..255)
; D1.l  yw (0..255)
; D2.w  Basistiefe
; D3.w  Anzahl Punkte-1
; Rotiert das Punktefeld um die X- und Y-Achse und legt die errechneten Daten
; in das Zielpunktefeld ab. Die Sinus/Cosinus-Tabelle muû zuvor mit
; calc_sintab erzeugt worden sein. Punkte sind jeweils Bytes
;
; calc_zoomtab                          Lucky
; .l  Adr. Zoomtab (Max. Anzahl Punkte*2 Words)
; Berechnet die fÅr den 3D-Zoomer benîtigte Zoomtabelle
;
; zoom_dotfield                         Lucky
; A0.l  Punktefeld (von rotate_dotfield)
; A1.l  Zielfeld (Anzahl Punkte*2 Words)
; A2.l  Adr. Zoomtab
; D0.w  Anzahl Punkte-1
; Rechnet ein mit rotate_dotfield gedrehtes 3D-Punktesystem auf gezoomte
; Koordinaten um. Ergebnis im X.w, Y.w - Format
;
; calc_morphfield                       Lucky
; A0.l  Adr Dotfield Original
; A1.l  Adr Dotfield Ziel
; A2.l  Adr Morphing-Schrittfeld (Anz. Punkte * 3 Words)
; A3.l  Adr Morphing-Dotfield (Anz. Punkte * 3 Words)
; D0.w  Anzahl Punkte-1
; D1.w  Anzahl Schritte
; D2.b  0 = Einmal; -1 = Unendlich
; Berechnet ein fÅr ein Dotfield-Morphing benîtigtes Feld...
;
; calc_morphstep                        Lucky
; A0.l  Adr Morphing-Dotfield
; A1.l  Adr Morphing-Schrittfeld
; A2.l  Adr Dotfield fÅr rotate_dotfield
; D0.w  Anzahl Punkte-1
; Einfach vor jedem Abarbeiten von rotate_dotfield aufrufen...
; (Berechnet den nÑchsten Schritt zum neuen Objekt)
;
; install_acia_block                    Lucky
; .l  Adresse des Acia-Blocks des Moduls
; Installiert die Variablen fÅr den Acia-Handler im JDS
;
; destall_acia_block                    Lucky
; .l  Adresse des aktuellen Blocks
; Destalliert den Acia-Handler wieder. Nicht vergessen!!!
;
; error_exit                            Lucky
; A0.l  Adr. Fehlertext
; Bricht die ProgrammausfÅhrung ab und gibt den Fehlertext aus.
;
; depack_ipf                            Lucky
; .l  Adr. IFP-Film
; Spielt eine Filmsequenz im IFP-Format (Inter Film - Packed) ab. Diese Routine
; lîscht nicht den Startbildschirm und setzt nicht die Auflîsung. Sie muû in
; einem 320x100 - Videomodus gestartet werden. (TrueColor) Es eignet sich z.B.
; 'R_TC_DPF.SCP'. Der Bildschirm wird auch beim Verlassen nicht gelîscht.
;
; set_background_color
; .b  Leer
; .b  Rot  0..255
; .b  Blau 0..255
; .b  GrÅn 0..255
; Berechnet die Hintergrundfarbe fÅr alle Folgeeffekte
;
; install_midi_handler
; .l  Adr. Midi-Handler (endet auf rts; darf d0-d1/a0 verÑndern)
; Installiert eine Empfangsroutine fÅr den Midi-Port
;
; destall_midi_handler
; Entfernt einen installierten Midi-Handler
;
; swap_acia_vbr_routs
; Vertauscht die aktuelle Acia & VBR-Routine gegen die Original-Routinen.
                        ENDPART
                        >PART 'Vordefinierte Rout.sammlungen'
; PAL_GEN                               Lucky
; Hier sind einige Routinen um Farbpaletten im 256-Farben-Modus zu bearbeiten.
; Insbesonders um Farbadditionen und Farbgebung einzelner Planes usw. zu
; berechnen. Die meisten Routinen sind nicht optimiert.
                        ENDPART
                        >PART 'Vordefinierte Effekte'
; TC_ROUTIN.SRC                         Nightmare (JDS-modulized by Lucky)
; Diese Routine blendet ein TC-Bild, daû innerhalb der Routine definiert ist,
; durch drehen kleiner Bereiche ein. Es wird der aktuelle Videomodus genommen,
; jedoch muû die Bildschirmgrîûe Åber die Size-EQUs in der Routine eingestellt
; werden.
                        ENDPART
                        >PART 'Kleine Standard-Routinen'
; AUSBLEND.S                            Lucky
; Blendet den aktuellen TC-Bildschirm aus. Konzept von Nightmare.
;
; DIVIDE.S                              Lucky
; Versuch einer schnellen Divisions-Routine...
                        ENDPART
                        END
                        >PART 'TEXT Rotdist'
;>;> a = 60                      d0   <<20
;>;> b = 20
;>;> aofs = b/100                d1   <<20
;>;> h = 50                      d2   <<20
;>;Ø FOR c=0 TO 99               d3
;>;Ø   d=h/(TAN(RAD(a))/16)      d4
;>;Ø   PRINT #1,MKL$(d);0
;>;Ø   ADD a,aofs
;>;Ø NEXT c
;>
;>gen_rotdist:            move.l  #10<<16<<4,D0
;>
;>                        move.w  mousey,D2
;>                        cmp.w   #14,D2
;>                        bge.s   w4
;>                        moveq   #14,D2
;>w4:                     move.w  D2,mousey
;>                        swap    D2
;>                        clr.w   D2
;>;>                        move.l  #$00300000,D2
;>
;>                        moveq   #0,D1
;>                        move.w  mousex,D1
;>                        ext.l   D1
;>                        bmi.s   gen_rotdist_m
;>                        neg.l   D1
;>
;>                        lsl.l   #8,D1
;>                        lsl.l   #3,D1
;>;>                        cmp.l   #-$00080000,D1
;>;>                        bge.s   w1
;>;>                        move.l  #-$00080000,D1
;>;>                        BREAKPT ' '
;>;>
;>;>w1:
;>
;>                        cmp.l   #$00080000,D1
;>                        ble.s   w0
;>;>                        move.l  #$000D0000,D1
;>
;>w0:
;>
;>                        lea     rotdist+100,A0
;>                        lea     tan,A1
;>                        moveq   #100-1,D3
;>gen_rotdist_l0:         move.l  D2,D4
;>                        move.l  D0,D5
;>                        swap    D5
;>                        ext.l   D5
;>                        divs.l  0(A1,D5.w*4),D4
;>;>                        asr.l   #1,D4  ; Vergrîûern...
;>                        move.l  D4,(A0)+
;>                        add.l   D1,D0
;>                        dbra    D3,gen_rotdist_l0
;>                        rts
;>
;>gen_rotdist_m:
;>                        IFNE 0
;>                        neg.l   D1
;>
;>                        lsl.l   #8,D1
;>                        lsl.l   #3,D1
;>
;>                        cmp.l   #$00080000,D1
;>                        ble.s   w1
;>                        move.l  #$00080000,D1
;>w1:
;>                        lea     rotdist+400,A0
;>                        lea     tan,A1
;>                        moveq   #100-1,D3
;>gen_rotdist_l1:         move.l  D2,D4
;>                        move.l  D0,D5
;>                        swap    D5
;>                        ext.l   D5
;>                        divs.l  0(A1,D5.w*4),D4
;>                        move.l  D4,-(A0)
;>                        add.l   D1,D0
;>                        dbra    D3,gen_rotdist_l1
;>                        ENDC
;>                        rts
                        ENDPART
                        END
