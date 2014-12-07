get_jds_screens EQU 1           ; 0 = Nein
; ^ Beim Start dieser Routine werden die aktuellen Bildschirmadressen vom
;   JDS geholt
set_jds_screens EQU 1           ; 0 = Nein
; ^ Beim Verlassen dieser Routine werden die Originaladressen der JDS-Bild-
;   schirme zurÅckgeschrieben. Ansonsten hat das JDS anschlieûend die Screens
;   dieser Routine!

                >PART 'Init JDS-Modul'
; Initialisierung eines Nachlademoduls fÅr das JDS.
; Nicht als Subroutine aufrufen! Diese Sequenz muû als Programmstart stehen!
                movea.l 4(SP),A0
                move.l  A0,D0
                sub.l   #8,D0
                move.l  D0,mousex_adr
                addq.l  #2,D0
                move.l  D0,mousey_adr
                addq.l  #2,D0
                move.l  D0,mousek_adr
                addq.l  #1,D0
                move.l  D0,joystick0_adr
                addq.l  #1,D0
                move.l  D0,joystick1_adr
                addq.l  #1,D0
                move.l  D0,key_adr
                move.w  -2(A0),system_mask
                move.l  (A0),log_orig_scr_adr
                IF get_jds_screens<>0
                movea.l (A0),A1
                move.l  (A1),log_scr
                ENDC
                addq.l  #4,A0
                move.l  (A0),phys_orig_scr_adr
                IF get_jds_screens<>0
                movea.l (A0),A1
                move.l  (A1),phys_scr
                ENDC
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
                pea     phys_scr(PC)
                pea     log_scr(PC)
                movea.l SP,A0
                bsr     set_scradr
                addq.l  #8,SP

                bsr     jdsrout_start

                IF set_jds_screens<>0
                move.l  phys_orig_scr_adr(PC),-(SP)
                move.l  log_orig_scr_adr(PC),-(SP)
                movea.l SP,A0
                bsr     set_scradr
                addq.l  #8,SP
                ELSE
                movea.l phys_orig_scr_adr(PC),A0
                move.l  phys_scr(PC),(A0)
                movea.l log_orig_scr_adr(PC),A0
                move.l  log_scr(PC),(A0)
                ENDC
                rts

dentro_exit:    jmp     0
init_soundchip: jmp     0
add_vblrout:    jmp     0
sub_vblrout:    jmp     0
subskript:      jmp     0
return:         jmp     0
wvbl_anz:       jmp     0
wvbl:           jmp     0
wait_swap_colors:jmp    0
wait_for_space: jmp     0
set_falconres:  jmp     0
swap_16_colors: jmp     0
swap_256_colors:jmp     0
depack_pic:     jmp     0
play_module:    jmp     0
textkonverter:  jmp     0
clear_4_planes: jmp     0
clear_8_planes: jmp     0
swap_screens:   jmp     0
reloziere:      jmp     0
hdplay_init:    jmp     0
hdplay:         jmp     0
hdplay_stop:    jmp     0
load:           jmp     0
save:           jmp     0
run_file:       jmp     0
set_scradr:     jmp     0
load_prog:      jmp     0
run_prog:       jmp     0
wait_timer:     jmp     0
clear_timer:    jmp     0
depack_ice:     jmp     0
run_packed_file:jmp     0
load_packed_prog:jmp    0

log_scr:        DS.L 1
phys_scr:       DS.L 1
log_orig_scr_adr:DS.L 1
phys_orig_scr_adr:DS.L 1
mousex_adr:     DS.L 1
mousey_adr:     DS.L 1
mousek_adr:     DS.L 1
joystick0_adr:  DS.L 1
joystick1_adr:  DS.L 1
key_adr:        DS.L 1
system_mask:    DS.W 1

space           EQU 57
module_on       EQU 0

jdsrout_start:
                ENDPART

