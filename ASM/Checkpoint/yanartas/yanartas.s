; Todo:
; settings for demo
z_on            equ 0
;;;;;; GENERAL ;;;;;;
playmusic       equ 1
rasters         equ 0
framecount      equ 0
debug           equ 0
hidemodmate     equ 0
loadmusic       equ 0

max_nr_of_vertices  equ 190
; scene selection:
;   - boing                 7s
;   - warning               10s             --> 17
;   - doKolorz              20s             --> 37
;   - titlescreen           8s              --> 45
;   - polygon           1   26s             --> 71
;   - polygon           2   25s             --> 96                   51 total
;   - twister               30s             --> 126
;   - moire                 7s              --> 133
;   - dragon picture        6s              --> 139
;   - sinedots              31s             --> 160
;   - worship               8s              --> 168
;   - endpart               
startscreen             equ boing

boing_nextscene         equ cpt
cpt_nextscene           equ warning
warning_nextscene       equ doKolorz
dokolorz_nextscene      equ titlescreen
titlescreen_nextscene   equ polygon
polygon_nextscene       equ twister
twister_nextscene       equ moire
moire_nextscene         equ dragon
dragon_nextscene        equ sinedots
sinedots_nextscene      equ worship
worship_nextscene       equ endpart

;;;;;;;;;;;;;;;;;;;;;

;;;;; SPECIFIC ;;;;;;
; twister part
vertical_offset_between_lines   equ 15*160
number_of_2characters           equ 10      (times 2)
text_character_offset           equ 72
number_of_lines                 equ 16
characters_per_line             equ 20
text_line_offset                equ 2*characters_per_line

;;;;;; moire ;;;;;
moireblocks         equ 20  ; should me MOD 2
moireoffset         equ 40+(20-moireblocks)*2
morenegativeoffset  equ -80-moireblocks*2
moirecolorinterval  equ 6 ;6
pathoffset          equ 8
pathlength          equ pathoffset*400      ;8x for offset


;;;;; sinedots ;;;;;;;
number_of_pixels                equ 750

;;;;; polyrout ;;;;;;
clearfilloffset                 equ 80
number_of_edges                 equ 36-1
size                            equ 44
mods                            equ 0   ; was 29
divsize                         equ size
possize                         equ (size)*2
negsize                         equ (256-size)*2
possize2                        equ (size+mods)*2
negsize2                        equ (256-(size+mods))*2

;;;;;; endpart ;;;;;;;
endpage                         equ 6


break   macro
    move.b  #0,$ffffc123
    endm

wait_for_vbl macro
    move.l  #0,$466.w       ;16
.loop\@
    tst.l   $466.w          ;12
    beq     .loop\@
    endm

save_old_values macro
    move.w  #$2700,sr                                       ;Stop all interrupts (using $ means hexidecimal)
    move.l  $70.w,save_vbl                          ;Save old VBL
    move.l  $68.w,save_hbl                          ;Save old HBL
    move.l  $134.w,save_ta                          ;Save old Timer A
    move.l  $120.w,save_tb                          ;Save old Timer B
    move.l  $114.w,save_tc                          ;Save old Timer C
    move.l  $110.w,save_td                          ;Save old Timer D
    move.l  $118.w,save_acia                        ;Save old ACIA
    move.b  $fffffa03.w,save_active_edge
    move.b  $fffffa07.w,save_inta
    move.b  $fffffa09.w,save_intb           ;Save MFP state for interrupt enable B
    move.b  $fffffa13.w,save_inta_mask
    move.b  $fffffa15.w,save_intb_mask      ;Save MFP state for interrupt mask B
    move.b  $fffffa1f,save_ta_delay
;    move.b  $ffff8e21,mste_status
    move.w  #$2300,sr                                       ;Interrupts back on
    move.b  #$12,$fffffc02.w                        ;Kill mouse
    move.b  $484.w,save_keymode               ; save keyclick
    endm    



check_for_spacebar_to_exit macro
    cmp.b   #$39,$fffffc02.w
    bne     .end\@
    jmp     exit_demo
.end\@
    endm

check_for_spacebar_to_end macro
    cmp.b   #$39,$fffffc02.w
    bne     .end\@
    jmp     resetrout
.end\@
    endm



swapscreens macro
    move.l  screenpointer,d0
    move.l  screenpointer2,screenpointer
    move.l  d0,screenpointer2
                
    move.l  screenpointershifter,d0
    move.l  screenpointer2shifter,screenpointershifter
    move.l  d0,screenpointer2shifter
    endm

swappixelpointers   macro
    move.l  pixelpointer,d0
    move.l  pixelpointer2,pixelpointer
    move.l  d0,pixelpointer2
    endm

swapclearpointers   macro
    move.l  clearpointer,d0
    move.l  clearpointer2,clearpointer
    move.l  d0,clearpointer2
    endm

rasterq macro
    IFNE debug
        cmp.b   #$10,$fffffc02.w
        bne     .q\@
            move.w  \1,$ffff8240
.q\@
    ENDC
    endm

donops macro
    REPT \1
        IFNE playmusic
        ELSE
        nop
        ENDC
    ENDR        
        endm  

framecount_start macro
    IFNE framecount
        move.w  #0,framecounter
    ENDC
    endm

framecount_stop macro
    IFNE framecount
        move.l  #0,d0
        move.w  framecounter,d0
        move.b  #0,$ffffc123
    ENDC
    endm

;;;;;; general includes, utilities etc ;;;;;;;
    include asm/raster.s
    include asm/pushpop.s
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    section     text
;;;;;;;;;;;;; start code ;;;;;;;;
; allocates stack, etc
; saves old addresses
; inits double buffered screen
; inits screenpointshifter
    include         asm/start.s 
                    save_old_values   
;;;;; END SETUP ;;;;;;;;;;;;;;;;;;
    move.l  $0426.w,reset_number_saved
    move.l  $042a.w,reset_vector_saved
    ;;;;; cookiejar!

        move.l  $5a0.w,d0
        beq.s   .st             ;Null pointer = ST
        move.l  d0,a0

        move.l  #128-1,d7
.search_mch:    
        tst.l   (a0)
        beq.s   .st             ;Null termination of cookiejar, no _MCH found = ST
        cmp.l   #"_MCH",(a0)
        beq.s   .mch_found
        addq.l  #8,a0
        dbra    d7,.search_mch
        bra.s   .st             ;Default to ST

.mch_found: 
        move.l  4(a0),d0
        cmp.l   #$00010000,d0
        beq.s   .ste
        cmp.l   #$00010010,d0
        beq.s   .megaste
        cmp.l   #$00020000,d0
        beq.s   .tt

.st:        
        move.l  #"ST  ",computer_type
        bra.s   .cookie_done

.ste:       
        move.l  #"STe ",computer_type
        move.w  #1,is_ste
        bra.s   .cookie_done

.megaste:   
        move.l  #"MSTe",computer_type
        bra.s   .cookie_done

.tt:        
        move.l  #"TT  ",computer_type
        bra.s   .cookie_done

.cookie_done

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   now jump to the first scene
    jmp     startscreen                    

computer_type
    dc.l    0
    dc.b    13,10,0,0
is_ste
    dc.w    0

;;;;;;;;;; BOING SCREEN MAIN LOOP ;;;;;;;;;;
; boing screen
; bouncing cursor
; 1 screen, no double buffer
boing

.init
    ; make sure front color is black
    move.w  #0,$ffff8242
    ; init the music, and flag the music on
    jsr     boingmusic+0
    st      music_on_flag
    ; fix vbl and hbl
    jsr     install_boing_vbl_hbl

prepare_screen: 
    move.l  screenpointer,A1
    move.l  a1,a6
    lea     cursor_data,A0
    lea     y_data,A2
    moveq   #0,d7

.show_cursor:
    movea.l A1,A3                   ; A3 = backup - position fr das l”schen des cursors

o   SET 0
    REPT 8
        move.w  (A0),o(A1)          ; zeichnet cursor (8x8 pixel)
        move.w  2(A0),o+8(A1)       ; zwei worte wg. shifting
o       SET     o+160
    ENDR

    moveq  #0,d0
    wait_for_vbl

o   SET 0
    REPT 8
        move.w  d0,o(A3)        ; cursor l”schen
        move.w  d0,o+8(A3)
o       SET     o+160
    ENDR

    move.l  a6,a1       ; hole bildschirmadresse
    move.w  (a2)+,d0
    add.l   d0,a1
    addq.w   #4,d7           ; cursor_offset

    lea     cursor_data,a0 ; zeiger auf cursordaten
    add.l   d7,a0           ; +cursor_offset

    cmpi.w  #16*4,d7        ; schon am ende der cursordaten-tabelle
    bne.s   .no_restart

    add.l   #8,a6       ; dann auf n„chstes wort schalten
    moveq   #0,d7           ; cursor_offset l”schen

.no_restart:     
    check_for_spacebar_to_exit


    cmpi.w  #$FFFF,(a2)     ; ende der y-daten-tabelle?
    bne     .show_cursor



    movea.l a6,a2       ; zeiger auf bildschirmposition
    move.w  -2(a2),d0
    add.l   d0,a1


o   SET 0
    REPT 8
        move.w  (a0),o(a1)       ; cursor zeichnen
        move.w  2(a0),o+8(a1)
o       SET     o+160
    ENDR


    moveq   #20,D0
    jsr     sub_wvbld0
    moveq   #3,d0
    jsr     sub_wvbld0
    move.w  #$111,$ffff8242
    moveq   #3,d0
    jsr     sub_wvbld0
    move.w  #$222,$ffff8242
    moveq   #3,d0
    jsr     sub_wvbld0
    move.w  #$333,$ffff8242
    moveq   #3,d0
    jsr     sub_wvbld0
    move.w  #$444,$ffff8242
    moveq   #3,d0
    jsr     sub_wvbld0
    move.w  #$555,$ffff8242
    moveq   #3,d0
    jsr     sub_wvbld0
    move.w  #$666,$ffff8242
    moveq   #3,d0
    jsr     sub_wvbld0
    move.w  #$777,$ffff8242

    ;;;;;;;;;;;; BOING DONE ;;;;;;;;;;

    move    #$2700,SR       ; keinen ir zulassen
    clr.b   $FFFFFA07.w     ; timer b abschalten
    clr.b   $FFFFFA09.w
    clr.b   $FFFFFA13.w
    clr.b   $FFFFFA15.w
    move.l  #new_vbl_trans,$70.w ; neue vbl-routine
    move    #$2300,SR       ; alle ir zulassen

    lea     transoffsets,A5
transition:     
    move.w  #0,D0           ; schlz„: 50hz = 1 sek warten
    jsr     sub_wvbld0

    move.w  (A5),transoffsetblack
    move.w  (A5)+,D0
    add.w   D0,D0           ; 2*schwarz (links+rechts)=rest fr weiž

    moveq   #50,D1
    sub.w   D0,D1           ; 50 - 2*schwarz = rest fr weiž
    move.w  D1,transoffsetwhite

    bsr     sub_codegen

    move.w  #1,codegen_on   ; set flag: raster wieder zeigen
    tst.w   (A5)
    bmi     trans_end
    bra.s   transition

trans_end:
.deinit
    jsr     boingmusic+4
    clr.b   music_on_flag   ; musik aus
    jmp     boing_nextscene
;;;;;;;;;;; END BOING SCREEN MAINLOOP ;;;;;;


;;;;;;;;;; BOING SCREEN CODE ;;;;;;;;;;;;;;;
sub_codegen:    
    lea     mod_code(PC),A0

    moveq   #0,D0
    moveq   #0,D1
    moveq   #0,D2
    moveq   #0,D3

    move.w  #1-1,D0         ; eine zeile generieren

start_codegen:  
    move.w  transoffsetblack,D1 ; black+white zusammen 50
    subq.w  #1,D1           ; wg dbra
gen_black:      
    move.w  move_0(PC),D3   ; 14; 25 ; 37 und  36; 25; 13
    move.w  D3,(A0)+

    dbra    D1,gen_black

    move.w  transoffsetwhite,D1
    tst.w   D1              ; ist weiž=0
    beq.s   jump_over_white ; dann nichts generieren

    subq.w  #1,D1           ; wg dbra
gen_white:      
    move.w  move_777(PC),D3 ;
    move.w  D3,(A0)+

    dbra    D1,gen_white

jump_over_white:move.w  transoffsetblack,D1 ;
                subq.w  #1,D1           ; wg dbra
gen_black2:     move.w  move_0,D3
                move.w  D3,(A0)+

                dbra    D1,gen_black2

                moveq   #24-1,D1        ; 28*4 = 112 TZ
gen_hbl:        move.w  #$4E71,(A0)+    ; hier nur 24 wg. dbra
                dbra    D1,gen_hbl

                dbra    D0,start_codegen

                st      flag_1stgen
                rts

move_0:         move.w  D1,(A1)         ; schwarz
move_777:       move.w  D2,(A1)         ; weiž


new_vbl_trans:  move.w  #$0599,D5       ; kurz warten
vbl_loop1:      dbra    D5,vbl_loop1

                move.b  #0,$FFFF820A.w  ; 60 hz
                REPT 10
                    nop
                ENDR

                move.b  #2,$FFFF820A.w  ; 50 hz

                movem.l D0-D3/A0-A1,-(SP)

                movea.l #$FFFF8240,A1
                move.w  #$0100,D1
                move.w  #$0777,D2
                move.w  #$0700,D3

                addq.l  #1,$0466.w

                lea     $FFFF8209.w,A0  ; zeiger auf videoadressz„hler-lowbyte
sync:           move.b  (A0),D0         ; videoadressz„hler-lowbyte auslesen
                beq.s   sync            ; ungleich 0? dann...

                not.b   D0              ; oder: sub.b d0,d1 ; synchronisation!
                lsl.w   D0,D0           ; oder: lsl.w d1,d0 (dann aber 102 nops)

cont_tb:     
                REPT 82
                    nop
                ENDR   
;                               ; um zentrierung des rasters zu erreichen

                move.w  #268-1,D0
mod_code:       
                REPT 75
                    nop
                ENDR
                dbra    D0,mod_code

                tst.b   flag_1stgen
                beq.s   no_blackborder
                move.w  D1,(A1)         ; unterer/oberer rand schwarz

no_blackborder: 
                movem.l (SP)+,D0-D3/A0-A1
                rte


install_boing_vbl_hbl
    move.l  #boingvbl,$70.w      ; vbl-vektor verbiegen
    move    #$2700,SR       ; stoppe interrupts: setzt die drei IR-
    move.l  #boing_timer_b,$0120.w ; timer b-vektor verbiegen
    clr.b   $FFFFFA09.w     ; IERB - alle IRs aus (timer c, timer d)
    ori.b   #%1,$FFFFFA07.w ; IERA - timer b zulassen
    ori.b   #%1,$FFFFFA13.w ; IMRA - alle IRs maskieren aužer t-b
    clr.b   $FFFFFA1B.w     ; timer b-control-register reinigen
    move    #$2300,SR       ; alle interrupts erlauben
    rts

boingvbl:
    addq.l  #1,$466.w
    clr.b   $FFFFFA1B.w     ; tb-control-register: %0 = timer stop
    move.b  #199,$FFFFFA21.w ; nach 199 zeilen auslsen
    move.b  #8,$FFFFFA1B.w  ; ereignisz„hler-modus
    pushall
    move.b  music_on_flag,d0
    beq.s   .no_music
    jsr     boingmusic+8
.no_music
    popall
    rte

boing_timer_b:        
    move    #$2700,SR       ; timer aus
    pushd0
    move.b  $FFFFFA21.w,d0  ; zeilennummer 199laden
.tb_sync:        
    cmp.b   $FFFFFA21.w,d0  ; auf zeile 200 warten
    beq.s   .tb_sync
    clr.b   $FFFF820A.w     ; -> 60 hz
    move.w  #2,d0           ; schleifenz„hler (3x)
.timer_b_loop:  
    nop                     ; kurz warten
    dbra    d0,.timer_b_loop
    move.b  #2,$FFFF820A.w  ; -> 50 hz
    move    #$2300,SR
    popd0
    bclr    #0,$FFFFFA0F.w
    rte
;;;;;;;;;;; CPT CODE ;;;;;;;;;;;;
cpt
                move.l  #50-1,d7
.wait
                wait_for_vbl
                dbra    d7,.wait
                pushall
                jsr     cptmusic+0         ; musik init
                popall

                move.w  #$0100,D1
                movea.l #$FFFF8240,A0
                moveq   #16-1,D0
clr_palette:    move.w  D1,(A0)+
                dbra    D0,clr_palette


                move.l  #cpt_vbl,a0
                move.l  #dummy,a1
                jsr     install_vbl_hbl 


                lea     lucaslogo+34,A0
                move.l  screenpointer,a1
                move.l  screenpointer2,a2
                lea     85*160(A1),A1
                lea     85*160(a2),a2
                move.w  #20*59,D0
get_pic:        move.l  (A0),(A1)+
                move.l  (a0)+,(a2)+
                move.l  (A0),(A1)+
                move.l  (a0)+,(a2)+
                dbra    D0,get_pic

                lea     lucaspal,A0

get_pal:        movem.l (A0)+,D0-D7
                movem.l D0-D7,$FFFF8240.w

                move.w  #2,D0
                jsr     sub_wvbld0

                tst.w   (A0)
                bne.s   get_pal

                move.w  #80-1,D0
                jsr     sub_wvbld0

                lea     lucaslogo+34,A0
                lea     60*160(A0),A0

                movea.l screenpointer,A1
                move.l  screenpointer2,a2
                lea     133*160(A1),A1
                lea     133*160(A2),A2

                move.w  #12*20,D0
get_demos:      move.w  (A0)+,D1
                or.w    D1,(A1)+
                or.w    D1,(A2)+
                move.w  (A0)+,D1
                or.w    D1,(A1)+
                or.w    D1,(A2)+
                move.w  (A0)+,D1
                or.w    D1,(A1)+
                or.w    D1,(A2)+
                move.w  (A0)+,D1
                or.w    D1,(A1)+
                or.w    D1,(A2)+
                dbra    D0,get_demos

    jsr     initMultable                        ;42
    st      multable_calced_flag

    jsr     initDivTable                        ;22
    st      divtable_calced_flag

    jsr     generateClearAndFillCode            ;11
    st      clearrout_calced_flag

    jsr     SegmentedLineSetup                  ;15
    st      linerout_calced_flag

                move.w  #30-1,D0
                jsr     sub_wvbld0

                lea     lucaslogo+34,A0
                lea     73*160(A0),A0

                moveq   #6,D1
twinkle_outloop:move.l screenpointer,A1
                lea     80*160+152(A1),A1
                moveq   #11,D0
twinkle_inloop: move.w  (A0)+,(A1)+
                move.w  (A0)+,(A1)+
                move.w  (A0)+,(A1)+
                move.w  (A0)+,(A1)+
                lea     152(A0),A0
                lea     152(A1),A1
                dbra    D0,twinkle_inloop

                move.w  #3,D0
                jsr     sub_wvbld0

                dbra    D1,twinkle_outloop

                jsr     cptmusic+4         ; musik aus

                move.w  #50,D0
                jsr     sub_wvbld0

;;;;;;;;;;; now we start fadeout
show_bars_1:    lea      bar_buffer_end(PC),A0 ; point to bar data
                move.l   screenpointer,A1       ; get scr_adr
                movea.l A1,A2           ; save scr_adr

                moveq   #36,D5          ; einmal durch kompletten buffer
loop_bars1:     moveq   #20-1,D6        ; einmal komplett auf bildschirm
                moveq   #0,D7
all_bars1:      move.l  -(A0),D0
single_bar1:

o               SET 0
                REPT 200
                or.w    D0,o(A1)            ; 4 * 200 * 20 * 16 =
                or.w    D0,o+2(A1)
                or.w    D0,o+4(A1)
                or.w    D0,o+6(A1)
o               SET o+160
                ENDR

                lea     8(A1),A1

                dbra    D6,all_bars1
                wait_for_vbl
                swapscreens
            
                move.l  screenpointer,a1
                adda.l  #19*4,A0        ; zurck auf anfang+1

                dbra    D5,loop_bars1

                move.w  #5-1,d0
                jsr     sub_wvbld0


show_bars_2:    move.w  #0,$FFFF8240.w

                lea     bar_buffer2(PC),A0 ; point to bar data
                move.l   screenpointer2,A1      ; get scr_adr
                movea.l A1,A2           ; save scr_adr
                lea     fade_colors222(PC),A3

                moveq   #36,D5          ; einmal durch kompletten buffer
loop_bars2:     moveq   #20-1,D6        ; einmal komplett auf bildschirm
                moveq   #0,D7
all_bars2:      move.w  #200-1,D7       ; 200 zeilen
                move.l  -(A0),D0
single_bar2:    move.w  D0,(A1)
                move.w  D0,2(A1)
                move.w  D0,4(A1)
                move.w  D0,6(A1)

                lea     160(A1),A1

                dbra    D7,single_bar2

                lea     -200*160(A1),A1
                lea     8(A1),A1

                dbra    D6,all_bars2

                move.l  screenpointer2,a1
                wait_for_vbl
                swapscreens
                adda.l  #21*4,A0        ; zurck auf anfang+1

                move.w  (A3)+,$FFFF825E.w

                dbra    D5,loop_bars2

                move.w  #50-1,d0
                jsr     sub_wvbld0


                jmp     cpt_nextscene


cpt_vbl:
                move.l screenpointershifter,$ff8200
                addq.l  #1,$0466.w
                pushall
                jsr     cptmusic+8         ; musik aufrufen
                popall

                rte

sub_wvbld0:       
        clr.l   $0466.w
.wvbl           
        tst.l   $0466.w
        beq.s   .wvbl

        dbra    D0,sub_wvbld0

        rts



fade_colors222:    DC.W $0777,$0777
                DC.W $0777,$0777,$0777,$0777,$0777,$0777,$0777
                DC.W $0777,$0777,$0777,$0777,$0777,$0777,$0777
                DC.W $0776,$0775,$0774,$0773,$0772,$0771,$0770
                DC.W $0760,$0750,$0740,$0730,$0720,$0710,$0700
                DC.W $0600,$0500,$0400,$0300,$0200,$0100,$00

                REPT 25
                DC.L 0
                ENDR
                DC.L %110000000
                DC.L %110000000
                DC.L %1111000000
                DC.L %1111000000
                DC.L %11111100000
                DC.L %11111100000
                DC.L %111111110000
                DC.L %111111110000
                DC.L %1111111111000
                DC.L %1111111111000
                DC.L %11111111111100
                DC.L %11111111111100
                DC.L %111111111111110
                DC.L %111111111111110
bar_buffer:     REPT 21
                DC.L %1111111111111111
                ENDR
bar_buffer2:    DC.L %1111111111111111
                DC.L %111111111111110
                DC.L %111111111111110
                DC.L %11111111111100
                DC.L %11111111111100
                DC.L %1111111111000
                DC.L %1111111111000
                DC.L %111111110000
                DC.L %111111110000
                DC.L %11111100000
                DC.L %11111100000
                DC.L %1111000000
                DC.L %1111000000
                DC.L %110000000
                DC.L %110000000
                DC.L %0
                DC.L %0
                REPT 19
                DC.L 0
                ENDR
bar_buffer_end: DC.L 0

;;;;;;;;;;; WARNING CODE ;;;;;;;;
warning
                bsr.s   init_system
                bsr.s   prepare_pic
                bsr     part_showblocks
                bsr     delete_warning
                bsr     white_curtain

                move.l  #48,d7
.waitframe
                wait_for_vbl
                dbra    d7,.waitframe

                jmp     warning_nextscene


init_system:    move.b  #0,$FFFF8260.w
                move.w  #0,$FFFF8240.w

                move.l  screenpointer,a0
                jsr     clearScreen4bpl
                move.l  screenpointer2,a0
                jsr     clearScreen4bpl

                jsr     warningmusic+0
                st      music_on_flag

                move    #$2700,SR
                move.l  #new_vblxx,$70.w
                move    #$2300,SR

                rts

new_vblxx:        addq.l  #1,$0466.w
                pushall
                    jsr       warningmusic+8
                popall
                rte


prepare_pic:    lea     warningpic+34,A0
                lea     buffer_table(PC),A2

                moveq   #8-1,D6
blocks:         movea.l (A2)+,A1        ; point to next block address
                bsr.s   sub_getblock
                dbra    D6,blocks

                lea     turtle_buf,A1
                move.w  #41-1,D7        ; height of the turtle
                bsr.s   getblock_inloop

                rts

sub_getblock:

getblock_outloop:
        moveq  #15-1,D7        ; counter: number of lines
getblock_inloop:
                REPT 6
                        move.l  (A0)+,(A1)+
                        move.l  (A0)+,(A1)+
                ENDR
                lea     160-48(A0),A0

        dbra    D7,getblock_inloop
        rts


part_showblocks:
                lea     warningpic+2,A0
                movem.l (A0),D0-D7
                movem.l D0-D7,$FFFF8240.w

                lea     buffer_table(PC),A1
                lea     x_pos(PC),A2
                lea     y_pos(PC),A3

                lea     wvbl_table(PC),A5

                moveq   #8-1,D7         ; counter: 8 blocks to show
show_blocks:    move.l  screenpointer,A0
                adda.w  (A2)+,A0        ; get xpos
                adda.w  (A3)+,A0        ; get ypos

                movea.l (A1)+,A4        ; A4 contains pointer to bufferdata

                bsr     sub_wvblxx

                bsr.s   sub_putblocks

                dbra    D7,show_blocks

                bsr     sub_wvblxx

                movea.l screenpointer,A0
                adda.w  (A2)+,A0
                adda.w  (A3)+,A0
                move.w  #41-1,D6        ; height of the turtle

                bsr.s   putblock_loop

                bsr     sub_wvblxx

                rts

buffer_table:   DC.L warning_buf,this_buf,demo_buf,contains_buf,no_buf
                DC.L cute_buf,animals_buf,dot_buf,turtle_buf
x_pos:          DC.W 80,40,56,80,56,64,80,112,120
y_pos:          DC.W 94*160,114*160,114*160,115*160,136*160,136*160,135*160
                DC.W 136*160,100*160

wvbl_table:     DC.W 0,30,13,20,30,30,10,12,15,28

sub_putblocks:  moveq   #15-1,D6        ; 15 buffer lines

putblock_loop:  REPT 6
                move.l  (A4)+,D5        ; bufferdata to screen
                or.l    D5,(A0)+
                move.l  (A4)+,D5
                or.l    D5,(A0)+
                ENDR

                lea     160-48(A0),A0   ; point to next line on screen

                dbra    D6,putblock_loop

                rts

sub_wvblxx:
                move.w  (A5)+,D5
.wvbl:           clr.l   $0466.w
.wvbl_loop:      tst.l   $0466.w
                beq.s   .wvbl_loop
                dbra    D5,.wvbl

                rts

delete_warning: 
                lea     fadepalette,A0 ; point to colors
                 moveq   #0,D7
            
                bsr.s   raster_fading
                bsr     wait_a_bit
                bsr     clearscreen

                rts

raster_fading:  move    #$2700,SR

                bclr    #5,$FFFFFA15.w  ; tc off



                move.l  #raster_vbl,$70.w

                move    #$2300,SR

                moveq   #0,D7
fadelooper:     bsr     sub_wait
                bsr     sub_wait

                add.l   #15*2,D7        ; index fr farbtabelle auf anfang n„chste tabelle
                cmp.w   #85*16,D7       ; schon 70 durchl„ufe (bild eingef„rbt)?
                ble.s   fadelooper      ; wenn nicht dann wieder von vorn

                rts

raster_vbl:     move.b  #0,$FFFFFA1B.w

                addi.l  #1,$0466.w
                lea     fadepalette(PC),A0 ; point to colors
                adda.l  D7,A0           ; sub index for 1st palette
                pushall
                    jsr     warningmusic+8
                popall
                move    #$2700,sr
                move.b  #1,$FFFFFA07.w  ; tb
                move.b  #1,$FFFFFA13.w  ; tb
                 move.l  #raster_tb,$0120.w
                move    #$2300,sr
                move.b  #90,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w

                rte

raster_tb:      move    #$2700,SR
                move.b  #0,$FFFFFA1B.w

                move.l  D6,-(SP)
                movem.l (A0)+,D0-D6     ; farben holen
                movem.l D0-D6,$FFFF8242.w ; und in register schaufeln
                move.l  (SP)+,D6

                move.w  (A0)+,$FFFF825E.w

                move.b  #2,$FFFFFA21.w  ; farbwechsel alle drei zeilen
                move.b  #8,$FFFFFA1B.w  ; ereignisz„hlermodus

                bclr    #0,$FFFFFA0F.w

                rte

fadepalette:    REPT 30
                DC.W $0EEE,$0DDD,$0FFF,$03D3,$01C1,$31,$21,$10,$0EC3,$0D32,$0C30,$0C22,$0322,$0211,$0101
                ENDR

                DC.W $0EEE,$0DDD,$0FFF,$03D3,$01C1,$31,$21,$10,$0EC3,$0D32,$0C30,$0C22,$0322,$0211,$0101
                DC.W $0666,$0555,$0777,$0A5A,$0848,$A8,$98,$80,$064A,$05A9,$04A0,$0499,$0A99,$0988,$0808
                DC.W $0DDD,$0CCC,$0EEE,$02C2,$B0,$20,$10,$00,$0DB2,$0C21,$0B20,$0B11,$0211,$0100,$00
                DC.W $0555,$0444,$0666,$0949,$30,$90,$80,$00,$0539,$0498,$0390,$0388,$0988,$0800,$00
                DC.W $0CCC,$0BBB,$0DDD,$01B1,$A0,$10,$00,$00,$0CA1,$0B10,$0A10,$0A00,$0100,$00,$00
                DC.W $0444,$0333,$0555,$0838,$20,$80,$00,$00,$0428,$0380,$0280,$0200,$0800,$00,$00
                DC.W $0BBB,$0AAA,$0CCC,$A0,$90,$00,$00,$00,$0B90,$0A00,$0900,$0900,$00,$00,$00
                DC.W $0333,$0222,$0444,$20,$10,$00,$00,$00,$0310,$0200,$0100,$0100,$00,$00,$00
                DC.W $0AAA,$0999,$0BBB,$90,$80,$00,$00,$00,$0A80,$0900,$0800,$0800,$00,$00,$00
                DC.W $0222,$0111,$0333,$10,$00,$00,$00,$00,$0200,$0100,$00,$00,$00,$00,$00
                DC.W $0999,$0888,$0AAA,$80,$00,$00,$00,$00,$0900,$0800,$00,$00,$00,$00,$00
                DC.W $0111,$00,$0222,$00,$00,$00,$00,$00,$0100,$00,$00,$00,$00,$00,$00
                DC.W $0888,$00,$0999,$00,$00,$00,$00,$00,$0800,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$0111,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$0888,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

                REPT 40
                DC.W $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                ENDR

wait_a_bit:     move.w  #25,D6
.wvbl_:          clr.l   $0466.w
.wvbl_looper:    tst.l   $0466.w
                beq.s   .wvbl_looper
                dbra    D6,.wvbl_

                rts

clearscreen:    moveq   #0,D0
                movea.l #$FFFF8240,A0
                moveq   #15,D1
pal_black:      move.w  D0,(A0)+
                dbra    D1,pal_black

                move.l screenpointer,A0
                jsr     clearScreen4bpl
                move.l  screenpointer2,a0
                jsr     clearScreen4bpl  

                move.l  #dummy_vbl,$70.w
                move.l  #dummy_tb,$0120.w
                rts

dummy_vbl:      addq.l  #1,$0466.w
                pushall
                jsr     warningmusic+8
                popall
                rte

dummy_tb:       rte


white_curtain:  
        bsr.s   init_raster


init_raster:    move    #$2700,SR

                bclr    #5,$FFFFFA15.w

                move.b  #1,$FFFFFA07.w
                move.b  #1,$FFFFFA13.w
                bclr    #3,$FFFFFA07.w

                lea     fadecolorsxx(PC),A1

                move.b  #100,startline2
                move.b  #1,endline2

                move.l  #curtain_tb,$0120.w
                move.l  #curtain_vbl,$70.w
                move    #$2300,SR

                rts

curtain_vbl:    move.b  #0,$FFFFFA1B.w  ; tb aus
                addq    #1,$466
                pushall
                    jsr     warningmusic+8
                popall
                move.b  startline2(PC),D0

                cmpi.w  #-1,(A1)        ; already black?
                beq.s   end_vbl_nowxx

                move.b  D0,$FFFFFA21.w  ; startzeile tb neu initialisieren
                move.b  #8,$FFFFFA1B.w  ; ereignisz„hlermodus
                move.l  #curtain_tb,$0120.w

                cmp.b   #80,D0
                ble.s   new_vbl_fadexx

                rte

end_vbl_nowxx:    move.l  #new_vbl2xx,$70.w
                rte

new_vbl2xx:       move.w  #$0777,$FFFF8240.w
                rte

new_vbl_fadexx:   move.w  (A1)+,$FFFF8240.w
            rte

curtain_tb:     move    #$2700,SR       ; keine irs zulassen
                move.b  #0,$FFFFFA1B.w  ; tb aus

                move.w  #$0777,$FFFF8240.w

                subi.b  #2,startline2

                move.b  endline2(PC),D0
                move.b  D0,$FFFFFA21.w  ; startzeile tb neu initialisieren
                move.b  #8,$FFFFFA1B.w  ; ereignisz„hlermodus
                move.l  #new_tb2xx,$0120.w

                bclr    #0,$FFFFFA0F.w  ; tb beendet

                rte

new_tb2xx:        move    #$2700,SR       ; keine irs zulassen
                move.b  #0,$FFFFFA1B.w  ; tb aus

                addi.b  #4,endline2

                move.w  -2(A1),$FFFF8240.w

                bclr    #0,$FFFFFA0F.w  ; tb beendet

                rte

                DC.W $00        ; don't delete (move.w -2(a1),$8240.w!)
fadecolorsxx:     DC.W $00,0,0,0,0,0,0,0,0,0,0,0,0
                DC.W $00,0,0,0,0,0,0,0,0,0,0,0,0
                DC.W $01
                DC.W $0111
                DC.W $0112
                DC.W $0222
                DC.W $0223
                DC.W $0333
                DC.W $0334
                DC.W $0444
                DC.W $0445
                DC.W $0555
                DC.W $0556
                DC.W $0666
                DC.W $0667
                DC.W $0777

                DC.W -1

startline2:      DS.W 1
endline2:        DS.W 1


sub_wait:       clr.l   $0466.w
wvblwaitloop:   tst.l   $0466.w
                beq.s   wvblwaitloop

                rts
;;;;; EXIT CODE
exit_demo
    include         asm/stop.s

default_vbl_kolorz:    
    move.l  screenpointershifter,$ff8200
    addq.w  #1,$466
    IFNE    playmusic                               
            pushall
            jsr warningmusic+8
            popall
    ENDC
        IFNE    framecount
            addq.w  #1,framecounter
        ENDC
    ;Start up Timer B each VBL
    move.w  #$2700,sr                       ;Stop all interrupts
    clr.b   $fffffa1b.w                     ;Timer B control (stop)
    bset    #0,$fffffa07.w                  ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w                  ;Interrupt mask A (Timer B)
    move.b  #0,$fffffa21.w                  ;Timer B data (number of scanlines to next interrupt)
    bclr    #3,$fffffa17.w                  ;Automatic end of interrupt
    move.b  #8,$fffffa1b.w                  ;Timer B control (event mode (HBL))
    rte     


default_vbl:    
    move.l  screenpointershifter,$ff8200
        tst.w   is_ste
    beq     .no_ste
        move.b  #0,$FF820D
        move.b  #0,$FF820F
        move.b  #0,$FF8265
.no_ste
    addq.w  #1,$466
    IFNE    playmusic                               
            pushall
            jsr music+8
            popall
    ENDC
        IFNE    framecount
            addq.w  #1,framecounter
        ENDC
    ;Start up Timer B each VBL
    move.w  #$2700,sr                       ;Stop all interrupts
    clr.b   $fffffa1b.w                     ;Timer B control (stop)
    bset    #0,$fffffa07.w                  ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w                  ;Interrupt mask A (Timer B)
    move.b  #0,$fffffa21.w                  ;Timer B data (number of scanlines to next interrupt)
    bclr    #3,$fffffa17.w                  ;Automatic end of interrupt
    move.b  #8,$fffffa1b.w                  ;Timer B control (event mode (HBL))
    rte     

; a0 vbl
; a1 hbl                
install_vbl_hbl:
    pusha0
    pusha1     
    move.w  #$2700,sr                                       ;Stop all interrupts (using $ means hexidecimal)
    move.l  a0,$70.w                                        ;Install our own VBL
    move.l  a1,$120.w                                       ;Install our own Timer B
    clr.b   $fffffa07.w                                     ;Interrupt enable A (Timer-A & B)
    clr.b   $fffffa13.w                                     ;Interrupt mask A (Timer-A & B)
    clr.b   $fffffa09.w                                     ;Interrupt enable B (Timer-C & D)
    clr.b   $fffffa15.w                                     ;Interrupt mask B (Timer-C & D)
    move.w  #$2300,sr                                       ;Interrupts back on
    popa1
    popa0
    rts

dummy:          
    rte             
;;;;;;;;;;;;;;;;;;;;;; END WARNING CODE ;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;; doKolorz MAIN ;;;;;;;;;;;;;;;;;;;
doKolorz
.init
    move.l  #default_vbl_kolorz,a0
    move.l  #dummy,a1
    jsr     install_vbl_hbl 
    jsr     kolorz_doInitialSource
    jsr     kolorz_generateClearScreenCode
    jsr     kolorz_preCalcSin
    jsr     kolorz_generateHBLCode

    lea     kolorz_palette,a0
    movem.l (a0),d0-d7
    move.w  d0,$ffff8242
    movem.l d1-d7,$ffff8244

    add.w   #32,kolorz_palette_counter
    move.w  #$777,$ffff8240
    move.w  #500,waitcounter    
.mainloop
        wait_for_vbl
        swapscreens
    move.w  logoDone,d0
    beq     doKolorz2

    jsr     doLogo
            check_for_spacebar_to_exit

    jmp     .mainloop

    
waitcounter             dc.l    36+30*32                ;2003 - 19 ==> 124 lines to be at hbl = 1       /979 - 19 = 980 ==> 61 lines

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; doKolorz CODE ;;;;;;;;;;;;;;;;;

; assumes:
; source pic in a0
; dest location in a1
; x block in d0
; y count in d1
doVClipping macro
    move.l  d1,d5
    blt     .\@topclip
    cmp.w   #199,d5
    bgt     .nodraw
    add.l   d7,d5
    sub.l   #199,d5
    bgt     .\@botclip  
    jmp     .\@novclip
.\@topclip
    ; check if we need to draw at all
    move.l  d1,d4
    add.w   d7,d4
    blt     .nodraw
    ; when we have topclipping, we need to add to the source offset so we dont draw the top lines
    neg.l   d5      ; this is what we have to skip; number of x-lines
    move.w  d6,d1
    addq    #1,d1
    mulu    d1,d5
    add.w   d5,d5
    add.w   d5,a0
    ; when clipping top, we always draw frop top
    moveq   #0,d1   ; so reset the y-value
    ; when we have topclipping, we need to adjust the number of lines drawn
    move.w  d4,d7

    jmp     .\@novclip
.\@botclip
    ; not implemented
.\@novclip
    endm


; a0 source data
; d0 is x value
; d1 is y value
drawSprite
    ; cheats!
    ext.l   d0
    move.w  #1,kolorz_animationmoved
    lea     x_block_and_offset,a2
    lea     y_block,a3

    movem.w (a0)+,d6-d7/a6          ; get the width and height of the picture

    moveq   #0,d2
.checkleftclip
    move.w  d0,d5                   ;x start to local var
    bge     .noleftclip             ;if x start > 0, no clipping on the right
.checkifendclipped
    move.w  d6,d4                   ;we have left clipping, get width of sprite in local var
    addq    #1,d4   ;+1             ;add one to size of sprite
    asl     #4,d4   ; *16           ;do *16, since we're counting pixels
    add.w   d5,d4                   ;add the -x to the size of the sprite
    ble     .nodraw                 ;if result is <= 0 then nodraw
.leftclipping
    ; when we get here we know that we need to clip at least 1 block
    ; and we know that we need to draw at least one block
    ; we need to figure out how many we need to draw

    ; d4 is the amount of pixels left to draw
    ; this/16 rounded up is the number of blocks left to draw

    ; -x = x
    neg.l   d5                      ;d5 is now the number of pixels on the left hand side
    move.w  d5,d4                   ;save to local car
    add.w   d5,d5                   
    add.w   d5,d5
    add.w   d5,a2
    move.w  (a2)+,d2            ; x_offset *8   ; this is what we want to use to determine the left offset
    ; d2 is the offset normally used for the screen, which is *8
    ; 8 is offset per block for screen
    ; 2 is offset per block for source
    asr     #3,d2               ; so we divide by 8
    ; here we lose precision, only if the value of d2%8=0 can we safely add
    ; if its not exactly d2%16 != 0, then we need to add something
    add.w   d2,d2
    and.w   #%1111,d4
    tst.w   d4
    beq     .noadd
    move.w  d6,d4
    add.w   d4,d4
    cmp.w   d4,d2
    beq     .nodraw
    add.w   #2,d2
.noadd
    add.w   d2,a0               ; add the offset to a0
    moveq   #0,d5               ; for sourcepic selection we need inverted offset
    sub.w   (a2),d5             ;
    bge     .noadd2
    add.w   #16,d5
.noadd2
    ; since we clip left, we have no x-offset to add, we need to add y-offset however:
    add.w   d1,d1
    add.w   (a3,d1.w),a1

    ; destination offsets have been sorted; we need to determine the sprite source to chose from
    move.w  a6,d1
    mulu    d5,d1   ; we have inverted offset used
    add.w   d1,a0

    ; finally, since we clipped, we have the source offset that we need to take into account each x-line in d2
    ; but we need to adjust the number of times that we copy a block!
    move.w  d2,d3
    asr     #1,d3
    sub.w   d3,d6

    subq    #1,d7                           ; number of times for 

    ; load the jumptable
    lea     .jmptable,a3
    addq    #1,d6
    add.w   d6,d6           ; *2
    move.w  d6,d5
    add.w   d6,d6           ; *4
    add.w   d5,d6
    sub.w   #2,d6
    add.w   d6,a3       ; advance to where the dbra has to be

    lea     savedCrap,a6
    move.l  a3,(a6)+
    move.l  (a3),(a6)+
    move.l  4(a3),(a6)+
    move.l  8(a3),(a6)+

    move.l  #$43E900A0,(a3)+            ;   lea 160(a1),a1
    move.w  #$D0C2,(a3)+                ;   adda.w  d0,a0
    move.w  #$51CF,(a3)+                ;   dbra d7,
    add.w   #8,d6                       ;   above instructions is 8 (4+2+2)
    neg.w   d6
    move.w  d6,(a3)+                    ;   pointer address to dbra to
    move.w  #$4E75,(a3)                 ;   rts

    jmp     .jmptable(PC)

.noleftclip 
    ; if we have no left clip, we may have right clip
.checkrightclip
    ; check if xstart is out of bounds
    cmp.w   #319,d0                     ; d0 is x-coord for drawing
    bgt     .nodraw                     ; if outside visible screen, dont draw
.checkifrightendclip
    move.w  d6,d4                       ; d6 is width of picture, in 16 pixel blocks, save to local var
;    addq    #1,d4   ;+1
    asl     #4,d4                       ; d4 = blocks*16 = xvalue
    add.w   d0,d4;                      ; add the width to starting position, to see if we need to clip
    sub.w   #319,d4 ; subtract 319      ; subtract 319, if its < 0; then no clip
    blt     .noclip ; 
.rightclip
    move.w  d4,d5                       ; number of pixels out of screen to local d5
    asr     #4,d4                       ; d4 holds the number of pixels out of the screen
    and.w   #%1111,d5                   ; do we have any remainder pixels?
    cmp.w   #0,d5
    beq     .noadd5                     ; if we do, we need to add 1 tot he `to be clipped' blocks
    addq    #1,d4
.noadd5

    sub     d4,d6                       ; d6 is number of block to be drawn
    add.w   d4,d4
    move.w  d4,d2
    subq    #1,d0

    add.w   d0,d0
    add.w   d0,d0
    add.w   d0,a2
    move.w  (a2)+,d0            ; x_offset
    add.w   d1,d1
    add.w   (a3,d1.w),d0        ; y_offset
    add.w   d0,a1               ; offsets added to screenaddress

    ; determine the offsets into the source
    move.w  d6,d0
    move.w  a6,d1
    mulu    (a2),d1             ; to determine which block we use
    add.w   d1,a0               ; add offset tos source

    subq.w  #1,d7                           ; number of times for 

    lea     .jmptable,a3
    addq.w  #1,d6
    add.w   d6,d6           ; *2
    move.w  d6,d5
    add.w   d6,d6           ; *4
    add.w   d5,d6
    sub.w   #2,d6
    add.w   d6,a3       ; advance to where the dbra has to be

    lea     savedCrap,a6
    move.l  a3,(a6)+
    move.l  (a3),(a6)+
    move.l  4(a3),(a6)+
    move.l  8(a3),(a6)+

    move.l  #$43E900A0,(a3)+            ;   lea 160(a1),a1
    move.w  #$D0C2,(a3)+                ;   adda.w  d0,a0
    move.w  #$51CF,(a3)+                ;   dbra d7,
    add.w   #8,d6                       ;   above instructions is 8 (4+2+2)
    neg.w   d6
    move.w  d6,(a3)+                    ;   pointer address to dbra to
    move.w  #$4E75,(a3)                 ;   rts

    jmp     .jmptable(PC)


.noclip
    doVClipping
    ; determine offset into the screen
    add.w   d0,d0
    add.w   d0,d0
    add.w   d0,a2
    move.w  (a2)+,d0            ; x_offset
    add.w   d1,d1
    add.w   (a3,d1.w),d0        ; y_offset
    add.w   d0,a1               ; offsets added to screenaddress

    ; this in an altered state can be used to generate code
    ; for each different `sprite' individually
    ; determine the offsets into the source
    move.l  a6,d1
    mulu    (a2),d1             ; to determine which block we use
    add.w   d1,a0

.dodraw
    subq    #1,d7                           ; number of times for 
    ; load the jumptable
    lea     .jmptable,a3
    addq    #1,d6
    add.w   d6,d6           ; *2
    move.w  d6,d5
    add.w   d6,d6           ; *4
    add.w   d5,d6
    sub.w   #2,d6
    add.w   d6,a3       ; advance to where the dbra has to be

    lea     savedCrap,a6
    move.l  a3,(a6)+
    move.l  (a3),(a6)+
    move.l  4(a3),(a6)+
    move.l  8(a3),(a6)+

    move.l  #$43E900A0,(a3)+            ;   lea 160(a1),a1
    move.w  #$51CF,(a3)+                ;   dbra d7,
    add.w   #6,d6                       
    neg.w   d6
    move.w  d6,(a3)+                    ;   pointer address to dbra to
    move.w  #$4E75,(a3)                 ;   rts

.jmptable
o   SET 0
    REPT 10
            move.w  (a0)+,d0                ;   2 bytes
            or.w    d0,o(a1)                ;   4 bytes
o   SET o+8
    ENDR

.nodraw
        move.l  (a7)+,a6
        add.w   #12,a6
        jmp     (a6)

savedCrap
    dc.l    savedCrap+4,0,0,0
    dc.l    0,0

savedD7
    dc.l    0

checkAndDoSpkr
    move.w  kolorz_animationdone,d0
    beq     .doanimation
    jmp     nextpart

.doanimation
    raster  #$000
    
    jsr     clearScreenCode

    raster  #$007

    lea     spriteslist,a4
    lea     kolorz_sprites_coordslist,a5
    move.l  screenpointer2,a1
    move.l  a1,usp
    move.w  #0,kolorz_animationmoved
    move.l  #17-1,d7
n   equ 6
.doSprite
        move.l  d7,savedD7
        move.l  usp,a1
        move.l  (a4)+,a0
        movem.w (a5)+,d0-d5         ;d0,d1 x,y current position; d2,d3 x,y target position, d4 speed, d5 indication we're done
        tst.w   d5
        beq     .spritedone
        cmp.w   d2,d0               ; have we reached our x-position yet?               ;2
        blt     .xless              ; we are left from target
        bgt     .xmore              ; we are right from target
;.xnomovement
        cmp.w   d3,d1               ; have we reached our y-position yet?
        blt     .yless              ; we are above target
        bgt     .ymore              ; we are under target

        add.w   #1,d5               ; add 1 to finished marker      ;2
        jmp     .draw
.xless
        add.w   d4,d0               ; increase x with speed             ;2
        add.w   #2,a1
        jmp     .draw
.xmore
        sub.w   d4,d0               ; decrease x with speed                     ;2
        add.w   #2,a1
        jmp     .draw
.yless
        add.w   d4,d1               ; increase y with speed                     ;2
        add.w   #2,a1
        jmp     .draw
.ymore
        sub.w   d4,d1               ; decrease y with speed
        add.w   #2,a1
.draw   
        movem.w d0-d5,-12(a5)       ; store all values
        jsr     drawSprite          ; draw sprite
        lea     savedCrap,a6
        move.l  (a6)+,a3
        move.l  (a6)+,(a3)+
        move.l  (a6)+,(a3)+
        move.l  (a6)+,(a3)+
        move.l  savedD7,d7
.spritedone
    dbra    d7,.doSprite
    jmp spkrrts

vbl_logo_dyn:   
    move.l screenpointershifter,$ff8200
        tst.w   is_ste
    beq     .no_ste
        move.b  #0,$FF820D
        move.b  #0,$FF820F
        move.b  #0,$FF8265
.no_ste
    addq    #1,$466.w
    ;Start up Timer B each VBL
    move.w  #$2700,sr           ;Stop all interrupts
    clr.b   $fffffa1b.w         ;Timer B control (stop)
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
    move.l  #hbl_logodyn,$120.w     ;Install our own Timer B
    move.b  #199,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)
    bclr    #3,$fffffa17.w          ;Automatic end of interrupt
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
    move.w  #$2300,sr           ;Interrupts back on
    rte

hbl_logodyn:
    move.l  kolorz_waitcounter2,d7
.waitbot
        move.l  d7,d7
    dbra    d7,.waitbot
    move.w  #$000,$ffff8240
    rte

doLogo
    jmp     checkAndDoSpkr
spkrrts
    raster  #$700
    move.w  kolorz_animationmoved,d0
    bne     .notdone
    move.w  #1,kolorz_animationdone
.notdone
    jmp     derp

nextpart
    move.w  #0,logoDone
derp
    rts

clearScreen4bpl:     
    add.l   #44160,a0
    move.l  #849-1,d0

    move.l  #0,d1   
    move.l  d1,d2
    move.l  d1,d3
    move.l  d1,d4
    move.l  d1,d5
    move.l  d1,d6
    move.l  d1,d7
    move.l  d1,a1
    move.l  d1,a2
    move.l  d1,a3
    move.l  d1,a4
    move.l  d1,a5
    move.l  d1,a6   ;13*4 = 52      
.del
    movem.l d1-d7/a1-a6,-(a0)
    dbra    d0,.del
    move.l  d1,-(a0)
    move.l  d1,-(a0)
    move.l  d1,-(a0)
    rts                

kolorz_doInitialSource
    lea     kolorz_s0,a0
    lea     s0data,a1
    move.l  (a0)+,d0
    move.l  (a0)+,d1
    jsr     prepareInitialSources
    lea     s0data,a1
    jsr     preshiftSingleThing


    lea     kolorz_s1,a0
    lea     s1data,a1
    move.l  (a0)+,d0
    move.l  (a0)+,d1
    jsr     prepareInitialSources
    lea     s1data,a1
    jsr     preshiftSingleThing


    lea     kolorz_s2,a0
    lea     s2data,a1
    move.l  (a0)+,d0
    move.l  (a0)+,d1
    jsr     prepareInitialSources
    lea     s2data,a1
    jsr     preshiftSingleThing

    lea     kolorz_s3,a0
    lea     s3data,a1
    move.l  (a0)+,d0
    move.l  (a0)+,d1
    jsr     prepareInitialSources
    lea     s3data,a1
    jsr     preshiftSingleThing

    lea     kolorz_p0,a0
    lea     p0data,a1
    move.l  (a0)+,d0
    move.l  (a0)+,d1
    jsr     prepareInitialSources
    lea     p0data,a1
    jsr     preshiftSingleThing

    lea     kolorz_p1,a0
    lea     p1data,a1
    move.l  (a0)+,d0
    move.l  (a0)+,d1
    jsr     prepareInitialSources
    lea     p1data,a1
    jsr     preshiftSingleThing

    lea     kolorz_p2,a0
    lea     p2data,a1
    move.l  (a0)+,d0
    move.l  (a0)+,d1
    jsr     prepareInitialSources
    lea     p2data,a1
    jsr     preshiftSingleThing

    lea     kolorz_p3,a0
    lea     p3data,a1
    move.l  (a0)+,d0
    move.l  (a0)+,d1
    jsr     prepareInitialSources
    lea     p3data,a1
    jsr     preshiftSingleThing

    lea     kolorz_k0,a0
    lea     k0data,a1
    move.l  (a0)+,d0
    move.l  (a0)+,d1
    jsr     prepareInitialSources
    lea     k0data,a1
    jsr     preshiftSingleThing

    lea     kolorz_k1,a0
    lea     k1data,a1
    move.l  (a0)+,d0
    move.l  (a0)+,d1
    jsr     prepareInitialSources
    lea     k1data,a1
    jsr     preshiftSingleThing

    lea     kolorz_k2,a0
    lea     k2data,a1
    move.l  (a0)+,d0
    move.l  (a0)+,d1
    jsr     prepareInitialSources
    lea     k2data,a1
    jsr     preshiftSingleThing

    lea     kolorz_k3,a0
    lea     k3data,a1
    move.l  (a0)+,d0
    move.l  (a0)+,d1
    jsr     prepareInitialSources
    lea     k3data,a1
    jsr     preshiftSingleThing


    lea     kolorz_r0,a0
    lea     r0data,a1
    move.l  (a0)+,d0
    move.l  (a0)+,d1
    jsr     prepareInitialSources
    lea     r0data,a1
    jsr     preshiftSingleThing

    lea     kolorz_r1,a0   
    lea     r1data,a1
    move.l  (a0)+,d0
    move.l  (a0)+,d1
    jsr     prepareInitialSources
    lea     r1data,a1
    jsr     preshiftSingleThing

    lea     kolorz_r2,a0
    lea     r2data,a1
    move.l  (a0)+,d0
    move.l  (a0)+,d1
    jsr     prepareInitialSources
    lea     r2data,a1
    jsr     preshiftSingleThing

    lea     kolorz_r3,a0
    lea     r3data,a1
    move.l  (a0)+,d0
    move.l  (a0)+,d1
    jsr     prepareInitialSources
    lea     r3data,a1
    jsr     preshiftSingleThing

    lea     kolorz_r4,a0
    lea     r4data,a1
    move.l  (a0)+,d0
    move.l  (a0)+,d1
    jsr     prepareInitialSources
    lea     r4data,a1
    jsr     preshiftSingleThing


    rts

prepareInitialSources
    move.w  d0,(a1)+
    move.w  d1,(a1)+
    moveq   #0,d5
    moveq   #0,d6

    move.w  d0,d5
    addq.w  #1,d5
    move.w  d1,d6
    mulu    d5,d6
    add.w   d6,d6
    move.w  d6,(a1)+

    subq    #1,d0
    subq    #1,d1

    ; start
    move.l  d1,d7
.outerloop
    ; move to next y-line
    move.l  d0,d6
.innerloop
    ; do hline
            move.w (a0),(a1)+
            add.w   #8,a0
        dbra    d6,.innerloop
        move.w  #0,(a1)+            ; one additional word for shfting
    dbra    d7,.outerloop   
    rts

; before getting called sor tthe shit
preshiftSingleThing
    movem.w (a1)+,d0-d2
    ; set up counters
    move.l  #15-1,d7    ;   we want 15 copies

.docopy
        move.l  a1,a0   ;   careful! source = dest
        add.l   d2,a1   ;   and add the offset
        move.l  a1,a2   ;   save the destination
        ; now we can start shifting and copying
        move.l  d1,d5       ; yloop
        subq    #1,d5
.outerloop
        moveq   #0,d3       ; clear d2
        move.l  d0,d4
.innerloop  
                move.w  (a0)+,d3
                roxr.w  #1,d3
                move.w  d3,(a1)+
            dbra    d4,.innerloop
        dbra    d5,.outerloop
        move.l  a2,a1           ; restore stuff for next iteration

    dbra    d7,.docopy

    rts

initTimerFraction
    move.l  #32,d0
    move.l  #50,d1
    asl.l   #8,d0
    divu    d1,d0
    move.w  d0,d2
    clr.w   d0
    swap    d0
    asl.l   #8,d0
    divu    d1,d0
    swap    d2
    asr.l   #8,d2
    or.w    d0,d2       

    move.w  d2,kolorz_timerfraction
    rts

kolorz_generateClearScreenCode
    lea     clearScreenCode,a0
    move.l  a0,a6
    move.w  #$2079,(a0)+                ;   move.l  x,a0
    move.l  #screenpointer2,(a0)+
    move.w  #$5448,(a0)+
    move.w  #$7000,(a0)+                ;   moveq   #0,d0

    move.w  #0,d5               ; offset
    move.w  #20-1,d6
    move.w  #200-1,d7

    move.w  #$3140,d0
    move.w  #8,d1

.outerloop
    move.w  #20-1,d6
.innerloop
        move.w  d0,(a0)+            ; 12*188 longword + 5 word => 
        move.w  d5,(a0)+
        addq    #8,d5
    dbra    d6,.innerloop
    dbra    d7,.outerloop

    move.w  #$4E75,(a0)+
    rts

kolorz_preCalcSin
.coltab_precalc: 
    lea     kolorz_col_tab,A0  ; zeiger auf farbtabelle (32 farben)
     lea     kolorz_precalc_coltab,A1 ; zeiger auf farbfeld (268*32)
     lea     kolorz_sintab,A2

     moveq  #0,d3
     move.w #268-1,d0
.coltab_outloop3:
    moveq   #16+6-1,d1
.coltab_inloop3:
        move.l  d3,(a1)+
        dbra    d1,.coltab_inloop3
        dbra    d0,.coltab_outloop3


     move.l  a0,a3
     move.w  #268+67-1,D0       ; 268 y-zeilen generieren
.coltab_outloop: 
    moveq   #16+6-1,D1      ; a 32 farben (16 .l = 32 .w)
;                                       ; + 12 farben wg. sinus (hbl einf„rben!)
.coltab_inloop:  
    move.l  (A0)+,(A1)+     ; 2 farbregister -> farbfeld
    dbra    D1,.coltab_inloop
    move.l  a3,A0  ; nach 32 farben zum anfang farbtabelle
    adda.w  (A2)+,A0
    dbra    D0,.coltab_outloop


    move.l  #$07770777,d3
    move.w  #268-1,D0       ; 268 y-zeilen generieren
.coltab_outloop2: 
    moveq   #16+6-1,D1      ; a 32 farben (16 .l = 32 .w)
;                                       ; + 12 farben wg. sinus (hbl einf„rben!)
.coltab_inloop2:  
    move.l  d3,(A1)+     ; 2 farbregister -> farbfeld
    dbra    D1,.coltab_inloop2
    dbra    D0,.coltab_outloop2
    rts

;;;; dokolorz part 2 ;;;;
; curtain
;;;;;;;;;;
doKolorz2
.init
    move.l  #vbl_logo_dyn,a0
    move.l  #hbl_logodyn,a1
    jsr     install_vbl_hbl 
    jsr     initTimerFraction
.mainloop
        wait_for_vbl
        swapscreens             ; dont use jmp when it returns with rts, use branch then
    move.w  #$000,$ffff8240                 ; 16
    move.l  waitcounter(PC),d7              ; 16
    ; 236 done
    ; last dbra takes 4 more, so effectively 272 cycles left
    ; 272 left,  so initial value is 17
    ; each next line is 512/16 = 32
    nop
    nop
.waitraster
    move.l  d7,d7                           ;   4
    dbra    d7,.waitraster                  ; taken 12, not taken; 16;
                                            ; so each dbra is 4 nops
    move.w  #$777,$ffff8240
    jsr     rollCurtain

        IFNE    playmusic               
            pushall
            jsr warningmusic+8
            popall
        ENDC
            check_for_spacebar_to_exit
    jmp     .mainloop
;;;;;;;;;;; end dokolorz part 2 ;;;;;;;;;;;;
;;;;;;;;;;;;;;; DOKOLORZ PART 2 CODE ;;;;;;;;;;;;;;;;
rollCurtain
    move.l  #0,d2
    move.l  kolorz_timerfractioncounter,d1
    add.w   kolorz_timerfraction,d1
    bcc     .skiptop
    addq    #1,d2
    move.l  waitcounter,d0
    cmp.w   #2035,d0
    bge     .noaddtop
    add.l   #35,d0
.noaddtop
    move.l  d0,waitcounter
.skiptop
    move.l  d1,kolorz_timerfractioncounter

    move.l  kolorz_waitcounter2,d0
    cmp.w   #32,d0
    blt     .nosubbot
    sub.l   #32,d0
    addq    #1,d2
.nosubbot
    move.l  d0,kolorz_waitcounter2

    tst.w   d2
    bne     .w
    ; ELSE WE ARE DONE
    move.l  (sp)+,d7    ; pop stack pointer
    jmp     doKolorz3
.w
    rts
;;;;;;;;;;;;;;;;;; END DOKOLORZ PART 2 CODE ;;;;;;;;;;;;;;;
;;;;;;; DOKOLORZ PART 3 CODE ;;;;;;
doKolorz3
.init
    move.w  #$777,$ffff8240
    move.w  #6267,d7
.waitloop
        move.l  d7,d7
        dbra    d7,.waitloop
    move.w  #$000,$ffff8240
    move.l  #kolorz_vbl_logo_static,a0
    move.l  #kolorz_hbl_static1,a1
    jsr     install_vbl_hbl
    IFNE    playmusic
        jsr     music+8
    ENDC


.mainloop
            wait_for_vbl
    move.w  #$000,$ffff8240
    jsr     doRasterMove


waitloop
    move.l  #230,d7
.waitloop
            wait_for_vbl
    jsr     doRasterMove
            check_for_spacebar_to_exit
    dbra    d7,.waitloop

.dokolorz
    wait_for_vbl

    move.w  kolorzCounter,d0
    cmp.w   #18*4,d0
    beq     .cont
    lea     kolorzList,a0
    add.w   d0,a0
    add.w   #4,kolorzCounter
    move.l  (a0),a0

    move.w  (a0)+,d0
    move.w  (a0)+,d6

    jsr     doBubble
    jsr     doRasterMove
            check_for_spacebar_to_exit
            wait_for_vbl

    jsr     doRasterMove
            check_for_spacebar_to_exit
    jmp     .dokolorz

.cont
    lea     checkpoint,a0
    jsr     copyBubbleText
    move.l  #110,d7
.waitloop2
        REPT 3
            wait_for_vbl
    jsr     doRasterMove
            check_for_spacebar_to_exit
        ENDR

    move.w  kolorz_palette_counter,d0
    cmp.w   #7*32,d0
    beq     .nopalette

            check_for_spacebar_to_exit

    lea     kolorz_palette,a0
    add.w   d0,a0
    movem.l (a0)+,d0-d6/a1
    movem.l d0-d6/a1,$ffff8240
    add.w   #32,kolorz_palette_counter
    dbra    d7,.waitloop2

.nopalette
    lea     dothekolorz,a0
    jsr     copyBubbleText
            check_for_spacebar_to_exit
    dbra    d7,.waitloop2

    moveq   #7-1,d7
.fadeout
        REPT 2
            wait_for_vbl
            check_for_spacebar_to_exit
            nop
        ENDR
    lea     blackPalette,a0
    lea     $ffff8240,a1
    jsr     doFade
    dbra    d7,.fadeout




.deinit
    move.l  screenpointer,a0
    jsr     clearScreen4bpl
    move.l  screenpointer2,a0
    jsr     clearScreen4bpl
    jmp     dokolorz_nextscene

;;;;;;;;; DOKOLORZ PART 3 CODE ;;;;;
doRasterMove
    move.w  #$000,$ffff8240
    move.l  kolorz_sincounter,d0
    cmp.l   #2*99*280,d0
    bge     .addless
    add.l   #86,d0
    jmp     .go
.addless
.go
    move.l  d0,kolorz_sincounter
    rts

doBubble
    move.l  screenpointer,a1
    move.l  screenpointer2,a2

    add.w   d0,a1
    add.w   d0,a2

    add.w   #160*137,a1
    add.w   #160*137,a2

    move.w  d6,d4
    addq.w  #1,d4
    add.w   d4,d4
    add.w   d4,d4
    add.w   d4,d4
    neg.w   d4
    add.w   #160,d4

    move.l  #62-1,d7
.loop
    move.w  d6,d5
.innerloop
        move.w  (a0)+,d0
        or.w    d0,(a1)
        or.w    d0,(a2)
        add.w   #8,a1
        add.w   #8,a2
        dbra    d5,.innerloop
    add.w   d4,a1
    add.w   d4,a2
    dbra    d7,.loop
    rts



kolorz_vbl_logo_static:    
    move.l screenpointershifter,$ff8200
    addq    #1,$466.w
    move.w  #$000,$ffff8240
    ;Start up Timer B each VBL
    move.w  #$2700,sr           ;Stop all interrupts
    clr.b   $fffffa1b.w         ;Timer B control (stop)
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
    move.l  #kolorz_hbl_static1,$120.w     ;Install our own Timer B
    move.b  #1,$fffffa21.w          ;Timer B data (number of scanlines to next interrupt)
    bclr    #3,$fffffa17.w          ;Automatic end of interrupt
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
    move.w  #$2300,sr           ;Interrupts back on
    IFNE    playmusic
        pushall
        jsr warningmusic+8
        popall
    ENDC
    rte

kolorz_generateHBLCode
    lea     kolorzhblcode,a0

    move.l  #$41F88240,(a0)+                    ;   lea $ffff8240.w,a0
    move.l  #$4E714E71,d0  ;2x nop, need 55   
    moveq   #27,d7
.do2nops
        move.l  d0,(a0)+                        ;   nop x2
    dbra    d7,.do2nops
    move.w  #$4E71,(a0)+    ;55!                ;   nop

    move.w  #$3091,(a0)+                        ;   move.w  (a1),(a0)

    move.l  #200*42/2-1,d7
    move.l  #$30993099,d0
.domove
        move.l  d0,(a0)+                        ;   move.w  (a1)+,(a0) x2
    dbra    d7,.domove

    move.w  #$4250,(a0)+                        ;   clr.w   (a0)
    move.w  #$4E75,(a0)+                        ;   rts       ----> total = 4+55*2+2+2*42*200+2+2 = 4 + 110 + 2 + 16800 + 2 + 2 = 120 + 16800 = 16920
    rts

kolorz_hbl_static1:
    movem.l d0-a6,-(sp)
    clr.b   $fffffa1b.w         ;Timer B control (stop)
    lea     kolorz_precalc_coltab+268*105*2,a1
    move.l  kolorz_sincounter,d0
    sub.l   d0,a1

    lea     $ffff8209.w,a0          ;hardsync
    moveq   #127,d1
.sync:      
    tst.b   (a0)
    beq.s   .sync
    move.b  (a0),d2
    sub.b   d2,d1
    lsr.l   d1,d1

    jsr     kolorzhblcode

    movem.l (sp)+,d0-a6
    rte



copyBubbleText
    move.l  screenpointer,a1
    move.l  screenpointer2,a2

    add.w   (a0),a1
    add.w   (a0)+,a2

    move.w  (a0)+,d5    ; blocks of 16 pixels + 1
    move.w  (a0)+,d3    ; number of lines

    move.w  (a0)+,d4    ; added offset

.outerloop
        move.l  d5,d6
.innerloop
            move.l  (a0),(a1)+
            move.l  (a0)+,(a2)+
            move.l  (a0),(a1)+
            move.l  (a0)+,(a2)+

        dbra    d6,.innerloop
        add.w   d4,a1
        add.w   d4,a2
    dbra    d3,.outerloop
    rts

;;;;;;;;;;;;; END DOKOLORZ PART 3 CODE ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; TITLEPIC MAIN CODE ;;;;;;;;;;;;;;;;;;;;;
titlescreen
.init
    move.l  #default_vbl_kolorz,$70

    lea     yanartaspic+34,a0
    move.l  screenpointer,a1
    move.l  screenpointer2,a2
    move.w  #200*20-1,d7
.copyblock
        move.l  (a0),(a1)+
        move.l  (a0)+,(a2)+
        move.l  (a0),(a1)+
        move.l  (a0)+,(a2)+
    dbra    d7,.copyblock
    move.w  #280,waitcounter
    move.w  #8,fadecounter


.mainloop

    subq.w  #1,waitcounter
    beq     .deinit

.dofade
            wait_for_vbl
    subq.w  #1,fadecounter
    bne     .nofade
    move.w  #8,fadecounter
    lea     yanartaspic+2,a0
    lea     $ffff8240,a1
    jsr     doFade
            check_for_spacebar_to_exit

.nofade
    jmp     .mainloop

.deinit
    move.l  #bounce_vbl,a0
    move.l  #black_hbl,a1
    jsr     install_vbl_hbl

.timerbloop
.loop
    ; here we do rasterbar
            wait_for_vbl
    cmp.w   #85,timer_b_line
    bge     .clearscreen
    add.w   #1,timer_b_line
            check_for_spacebar_to_exit
    jmp     .loop

.clearscreen   
    move.l  screenpointer,a0
    jsr     clearScreen4bpl
    move.l  screenpointer2,a0
    jsr     clearScreen4bpl
    jmp     titlescreen_nextscene
;;;;;;;;;;;;; END TITLEPIC MAIN CODE ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; TITLEPIC CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;


timer_b_line
    dc.w    0

timerbwob
    include res/titlewob.s

    even

bounce_vbl:   
    move.l screenpointershifter,$ff8200
    pushall
    jsr     warningmusic+8

    lea     timerbwob,a0
    add.w   timer_b_line,a0
    move.b  (a0),d0
    beq     .skip
    lea     $ffff8240,a0
    lea     yanartaspic+2,a1
    REPT 8
        move.l  (a1)+,(a0)+
    ENDR
.skip


    addq    #1,$466.w
    ;Start up Timer B each VBL
    move.w  #$2700,sr           ;Stop all interrupts
    clr.b   $fffffa1b.w         ;Timer B control (stop)
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
    move.l  #black_hbl,$120.w     ;Install our own Timer B
    move.b  d0,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)
    bclr    #3,$fffffa17.w          ;Automatic end of interrupt
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
    move.w  #$2300,sr           ;Interrupts back on
    popall
    rte



black_hbl    
    move.l  d0,-(sp)
    move.l  a0,-(sp)
    lea     $ffff8240,a0
    moveq   #0,d0

    REPT 8
        move.l  d0,(a0)+
    ENDR

    move.l  (sp)+,a0
    move.l  (sp)+,d0
    rte

;;;;;;;;;;;;; END TITLEPIC CODE ;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; START POLYGON ROUT ;;;;;;;;;;;;;;;
polyintro
    include res/polyintro.s
 
poly_x             dc.w     0
step               dc.w     0


polygon
    ; generate code takes 4 frames
    jsr     SegmentedLineSetup


    ; initialize the current object
    jsr     initPolyObject

    ; check if the multable is precalced
    tst.w   multable_calced_flag
    bne     .skipMultable
    jsr     initMultable
    st      multable_calced_flag
.skipMultable

    jsr     warningmusic+4
    jsr     music+0
    st      music_on_flag

    
    ;;; first install the timer a
    move.b  #1,rasterpos
    move.l  #poly_openborder_top_bot_vbl,a0
    move.l  #raster_timer_a,a1
    move.l  #raster_timer_b,a2
    jsr     install_vbl_ta_tb
    ;;; then lower the curtain to the proper level
.doTheCurtain

    wait_for_vbl
    move.w  #$0466,$ffff8240
    lea     polyintro,a0
    add.w   step,a0
    move.b  (a0),rasterpos

    add.w   #1,step
    cmp.w   #82,step
    beq     .init

            check_for_spacebar_to_exit   
    jmp     .doTheCurtain



.init


    ; check if the divtable is precalced
    tst.w   divtable_calced_flag
    bne     .skipDivTable
    jsr     initDivTable
    st      divtable_calced_flag
.skipDivTable




    ; object starts completely yellow
    move.w  #$0411,$ffff8242
    move.w  #$0411,$ffff8244
    move.w  #$0411,$ffff8246
    move.l  #polygon_bottom_vbl,a0
    move.l  #polygon_bottom_hbl,a1
    jsr     install_vbl_hbl 
    move.w  #$466,$ffff8240
    move.l  #6184,d7
    move.w  #2*2,stepSpeedX
.wait
    nop
    nop
    dbra    d7,.wait
    move.w  #$000,$ffff8240

.objectrollin  
            wait_for_vbl
            swapscreens
            swapclearpointers
;    move.w  #$777,$ffff8240
    move.w  #$0466,$ffff8240


    jsr     modify_y_offset
    jsr     clearArea2

    jsr     doRotationPoly
    jsr     fixProjectedPolySource
    jsr     regelEdges                  ; bright red
    jsr     drawLines
    jsr     eorFill2

    ; middle of the screen, place dot
;    move.l  screenpointer2,a0
;    move.w  #(1<<15),d0
;    move.w  #%1000000000000000,80+160*180+6(a0)

    ; here we rollt he polygon to the right
    move.w  poly_x,d0
    add.w   #8192*3,d0
    bcc     .noadd
    add.w   #1,vertices_xoff
.noadd
    move.w  d0,poly_x
    add.w   #1,vertices_xoff
    cmp.w   #400,vertices_xoff
    ble     .cont3
    move.w  #-80,vertices_xoff
    move.w  #0,poly_x
.cont3

    cmp.w   #898,currentStepX
    beq     polygonstartsrotating
            check_for_spacebar_to_exit
    jmp     .objectrollin


;;;;;;;;; square in middel ;;;;;;
fillOrLines
    dc.w    0
flashcounter
    dc.w    3
bounceCounter
    dc.w    0
polyBounceTable
    include res/polybounce.s

polygonstartsrotating
.startpoly2
.init
    move.w  #13,waitcounter
    move.w  #0,stepSpeedX
    move.b  #185,rasterpos

.objectrotates  
            wait_for_vbl
            swapscreens
            swapclearpointers
    move.w  #$0466,$ffff8240

    jsr     clearArea2
    jsr     doRotationPoly
    jsr     fixProjectedPolySource
    jsr     regelEdges                  ; bright red

    move.w  fillOrLines,d0
    bne     .doLines
    jsr     drawLines
    jsr     eorFill2
    jmp     .linesDone
.doLines
    jsr     drawLinesKalms
.linesDone
    
    tst     addorsub
    bne     .noadd
    add.w   #2,addcounter
    cmp.w   #96,addcounter
    bne     .noadd
        addq.w  #2,stepSpeedY
        move.w  #0,addcounter
        cmp.w   #24,stepSpeedY
        blt     .noadd
        st      addorsub
.noadd
        lea     polyBounceTable,a0
        add.w   bounceCounter,a0
        move.w  (a0),vertices_yoff
        tst     tbinstalled
        add.w   #2,bounceCounter
        cmp.w   #128,bounceCounter
        bne     .noBounceReset
            move.w  #0,bounceCounter
            tst.w   flashcounter
            beq     .noBounceReset
            sub.w   #1,flashcounter
            move.w  fillOrLines,d0
            beq     .set
            move.w  #0,fillOrLines
            move.w  #0,glenz
            jmp     .noBounceReset
.set  
            move.w  #1,glenz
            st      fillOrLines
.noBounceReset
    tst.w   flashcounter
    bne     .nosub
    sub.w   #1,waitcounter
    beq     polybounceleftright
    ; here we also need the new timer b stuff, so we can drop the border
    tst.w   tbinstalled
    bne     .rasterposadd
        st      tbinstalled
        move.l  #poly_openborder_vbl,a0
        move.l  #raster_timer_b,a1
        jsr     install_vbl_hbl


        jmp     .nosub
.rasterposadd
        move.b  rasterpos,d0
        cmp.b   #245,d0
        bge     .nosub
        move.b  rasterposadd,d0
        add.b   d0,rasterpos
        add.b   #1,d0
        move.b  d0,rasterposadd

.nosub
            check_for_spacebar_to_exit
    jmp     .objectrotates
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

rasterposadd
    dc.b    1
rasterpos
    dc.b    185
    even
poly_openborder_vbl:       
        move.l screenpointershifter,$ff8200
        addq    #1,$466.w
        pushall
        move.w  #$2700,sr           ;Stop all interrupts

        IFNE    framecount
            addq.w  #1,framecounter
        ENDC

        ;Start up Timer B each VBL
        clr.b   $fffffa1b.w         ;Timer B control (stop)
        bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
        bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
        move.b  rasterpos,d0
        cmp.w   #200,d0
        bge     .doOpenLowerBorderTimer
            move.l  #raster_timer_b,$120.w
            move.b  rasterpos,$fffffa21.w     ;Timer B data (number of scanlines to next interrupt)
            jmp     .cont
.doOpenLowerBorderTimer
        move.b  #200,$fffffa21.w
        cmp.w   #200,d0
        bne     .doOther
            move.l  #open_lower_border_timer_b_black,$120.w
            jmp     .cont
.doOther
            move.l  #open_lower_border_timer_b,$120.w
.cont
        move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
        bclr    #3,$fffffa17.w          ;Automatic end of interrupt

        jsr     music+8
        popall
        rte


poly_openborder_top_bot_vbl:       
        move.l screenpointershifter,$ff8200
        addq    #1,$466.w
        pushall
        move.w  #$2700,sr           ;Stop all interrupts

        IFNE    framecount
            addq.w  #1,framecounter
        ENDC

        ;Start up Timer A each VBL
        clr.b   $fffffa19.w         ;Timer-A control (stop)
        bset    #5,$fffffa07.w          ;Interrupt enable A (Timer A)
        bset    #5,$fffffa13.w          ;Interrupt mask A (Timer A)
        move.b  #98,$fffffa1f.w         ;Timer A Delay (data)
        move.b  #4,$fffffa19.w          ;Timer A Predivider (start Timer A)

        ;Start up Timer B each VBL
        clr.b   $fffffa1b.w         ;Timer B control (stop)
        bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
        bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
        move.b  rasterpos,d0
        cmp.w   #200,d0
        bge     .doOpenLowerBorderTimer
            move.l  #raster_timer_b,$120.w
            move.b  rasterpos,$fffffa21.w     ;Timer B data (number of scanlines to next interrupt)
            jmp     .cont
.doOpenLowerBorderTimer
        move.b  #200,$fffffa21.w
        cmp.w   #200,d0
        bne     .doOther
            move.l  #open_lower_border_timer_b_black,$120.w
            jmp     .cont
.doOther
            move.l  #open_lower_border_timer_b,$120.w
.cont
        move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
        bclr    #3,$fffffa17.w          ;Automatic end of interrupt


        jsr     music+8
        popall
        rte

raster_timer_a:
        move.w  #$2100,sr           ;Enable HBL
        stop    #$2100              ;Wait for HBL
        move.w  #$2700,sr           ;Stop all interrupts
        clr.b   $fffffa19.w         ;Stop Timer A

        REPT 84
            nop
        ENDR

        clr.b   $ffff820a.w         ;60 Hz
        REPT 9
            nop
        ENDR
        move.b  #2,$ffff820a.w          ;50 Hz
        rte


raster_timer_b:
        ;set black background
        move.w  #0,$ffff8240
        move.w  #$2700,sr
    clr.b   $fffffa1b.w         ;Timer B control (stop)
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
    bclr    #3,$fffffa17.w          ;Automatic end of interrupt
        rte

open_lower_border_timer_b_black:                
        REPT 3
            nop
        ENDR
        clr.b   $ffff820a.w         ;60 Hz
        move.b  #2,$ffff820a.w          ;50 Hz
        move.w  #$000,$ffff8240
    rte



open_lower_border_timer_b:                
        REPT 3
            nop
        ENDR
        clr.b   $ffff820a.w         ;60 Hz
        move.b  #2,$ffff820a.w          ;50 Hz
        pushd0
        moveq   #0,d0
        move.b  rasterpos,d0
        sub.w   #200,d0
        move.w  #$2700,sr
    clr.b   $fffffa1b.w         ;Timer B control (stop)
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
        move.l  #tb_black,$120.w
        move.b  d0,$fffffa21.w 

    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
    bclr    #3,$fffffa17.w          ;Automatic end of interrupt
        popd0
    rte

tb_black
    move.w  #$000,$ffff8240
    clr.b   $fffffa1b.w         ;Timer B control (stop)

    rte

tbinstalled
    dc.w    0
dotransform
    dc.w    0
transforminit
    dc.w    0
transformcounter
    dc.w    0
addcounter
    dc.w    0
addorsub
    dc.w    0
copyCounter
    dc.w    200
screenTargetOffset
    dc.w    0
screenSourceAddress
    dc.l    0

;;;;;;;;;;;;;;;; START POLYGON 3 ;;;;;;;;;;;;;;;;;;;;;
; here the object stars movign left and right, and we drop the floor
currentHorPath
    dc.l    0
currentVerPath
    dc.l    0
horpath:
    include res/horpoly.s
horpath2:
    include res/horpoly2.s
horpath3:
    include res/horpoly3.s
vertpath:
    include res/vertpoly.s
vertpath2
    include res/verttemp.s
currentStep2
    dc.w    0
flashwait
    dc.w    0

polybounceleftright
.init
    move.w  #2,stepSpeedX
    move.w  #800,waitcounter
    move.w  #0,currentStep

    move.w  #0,flashcounter
    move.w  #3,addcounter

    move.l  #horpath,currentHorPath
    move.w  #3,flashwait

.mainloop
    wait_for_vbl
    swapscreens
    swapclearpointers
    tst.w   flashcounter
    beq     .gogogo

    lea     $ffff8240,a0
    lea     flashPalette,a1
    add.w   flashcounter,a1
    move.l  (a1)+,(a0)+
    move.l  (a1)+,(a0)+
    REPT    12
        move.w  #$0466,(a0)+
    ENDR

.gogogo


    jsr     clearArea2

    jsr     doRotationPoly
    jsr     fixProjectedPolySource
    jsr     regelEdges                  ; bright red
    tst.w   noKalms
    bne     .noKalms
    jsr     drawLinesKalms
    jmp     .contxtt
.noKalms
    jsr     drawLines
    jsr     eorFill2
.contxtt

    cmp.w   #700,waitcounter
    bne     .dontbegin
        st  dotransform
.dontbegin


    tst.w   dotransform
    beq     .contx
        sub.w   #1,addcounter
        bne     .contx
        move.w  #3,addcounter
        cmp.w   #29,transformcounter
        beq     .setSpeed
        tst.w   transforminit
        bne     .initdone

;24, 54, 60, 66, 72, 78
;-3, +3, -1, +1, -2, +2

        move.l  currentVertices,a0
        move.w  #512-88,28(a0)
        move.w  #512-88,60(a0)
        move.w  #512-88,74(a0)
        st      transforminit
.initdone
        move.l  currentVertices,a0
        sub.w   #2,28(a0)
        add.w   #2,58(a0)
        sub.w   #2,60(a0)
        add.w   #2,66(a0)
        sub.w   #2,74(a0)
        add.w   #2,80(a0)
        addq.w  #1,transformcounter
        jmp     .contx
.setSpeed
    move.w  #4,stepSpeedX
.contx

    lea     horpath,a0
    add.w   currentStep,a0
    move.w  (a0),vertices_xoff
    add.w   #2,currentStep
    cmp.w   #400,currentStep
    bne     .good
    move.w  #0,currentStep
.good       


    lea     vertpath,a0
    add.w   currentStep2,a0
    move.w  (a0),vertices_yoff
    add.w   #4,currentStep2
    cmp.w   #400,currentStep2
    bne     .contxx
    move.w  #0,currentStep2

.contxx

    tst     flashcounter
    bne     .checkflash
    move.w  currentStep,d0
    cmp.w   #200,d0
    beq     .setFlashCounter
    cmp.w   #0,d0
    beq     .setFlashCounter
    jmp     .noFlash

.setFlashCounter
    subq.w  #1,flashwait
    beq     polyDragonRight
    move.w  #8,flashcounter
    jmp     .noFlash
.checkflash
    add.w   #8,flashcounter
    cmp.w   #56,flashcounter
    bne     .conttt
        tst.w   noKalms
        beq     .set1
.set0   
        move.w  #0,noKalms
        add.w   #8,stepSpeedX
        jmp     .conttt
.set1
        move.w  #1,noKalms
.conttt
    cmp.w   #120,flashcounter
    bne     .noFlash
    move.w  #0,flashcounter

.noFlash

    subq.w  #1,waitcounter
    beq     polyDragonRight
            check_for_spacebar_to_exit
    jmp     .mainloop
;;;;;;;;;;;
polyInPosition
    dc.w    0
noKalms
    dc.w    0
backGroundColor
    dc.w    0
xhordone
    dc.w    0
drawLatch
    dc.w    0
fadewait
    dc.w    0
;;;;;;;;;;;;;;;;;;;;;
polyDragonRight
.now1
.init

    ; initialize/clear needed counters
    ; - screen address
    lea     polygon_rightpic+34,a0
    move.l  a0,screenSourceAddress
    ; - copy counter
    move.w  #408,copyCounter
    ; - offset counter
    move.w  #0,screenTargetOffset
    move.w  #0,drawLatch

    sub.w   #2,stepSpeedX

    move.w  #8,flashcounter
    move.w  #600,waitcounter
    move.w  #10,fadecounter
    move.w  #1,flashwait
    move.w  #30,fadewait
    move.w  #$0466,backGroundColor

.mainloop
    wait_for_vbl
    swapscreens
    swapclearpointers

    move.w  backGroundColor,$ffff8240

    tst.w   polyInPosition
    beq     .notDone
    sub.w   #8,copyCounter
    ble     .doFade
    move.l  screenSourceAddress,a0
    move.l  screenpointer2,a2
    add.w   screenTargetOffset,a2
    move.w  #160-1,d7
.copyblock
        move.l  (a0)+,(a2)+
        move.l  (a0)+,(a2)+
    dbra    d7,.copyblock
    tst.w   drawLatch
    beq     .swapLatch
    move.l      a0,screenSourceAddress
    add.w       #1280,screenTargetOffset
    move.w      #0,drawLatch
    jmp         .notDone
.swapLatch
    move.w       #1,drawLatch
    jmp         .notDone

.doFade
    subq.w  #1,fadewait
    bge     .skip
    subq.w  #1,fadecounter
    bne     .skip
    lea     polygon_rightpic+2,a0
    lea     $ffff8240,a1
    jsr     doFade
    move.w  #5,fadecounter
    move.w  #-8,copyCounter
.skip

.notDone

    ; first we enter this, we still need to flash
    
    tst.w   flashcounter
    beq     .gogogo
    cmp.w   #56,flashcounter
    bne     .cont
        move.w  #1,glenz
        move.w  #1,noKalms
.cont
    lea     $ffff8240,a0
    lea     flashPalette,a1
    add.w   flashcounter,a1
    move.w  (a1),backGroundColor
    move.l  (a1)+,(a0)+
    move.l  (a1)+,(a0)+
    add.w   #8,flashcounter
    cmp.w   #128,flashcounter
    bne     .gogogo
    move.w  #0,flashcounter         ; disable flashes
.gogogo




    jsr     clearArea2
    jsr     doRotationPoly
    jsr     fixProjectedPolySource
    jsr     regelEdges                  ; bright red
    tst.w   noKalms
    bne     .noKalms
    jsr     drawLinesKalms
    jmp     .contx
.noKalms
    jsr     drawLines
    jsr     eorFill2
.contx

    tst.w   flashwait
    beq     .x2
    lea     horpath3,a0
    add.w   currentStep,a0
    move.w  (a0),vertices_xoff
    add.w   #2,currentStep
    cmp.w   #400,currentStep
    bne     .good
    sub.w   #1,flashwait
    move.w  #0,currentStep
.x2       

    tst.w   xhordone
    bne     .good
    lea     horpath2,a0
    add.w   currentStep,a0
    move.w  (a0),vertices_xoff
    cmp.w   #40,vertices_xoff
    bne     .xnotinposition
        move.w  #1,polyInPosition
.xnotinposition
    add.w   #2,currentStep
    cmp.w   #400,currentStep
    bne     .good
    move.w  #0,currentStep
    move.w  #1,xhordone
.good    


    lea     vertpath,a0
    add.w   currentStep2,a0
    move.w  (a0),vertices_yoff
    tst.w   polyInPosition
    beq     .noadd2
    cmp.w   #94,vertices_yoff
    beq     .contxx
    add.w   #4,currentStep2
.noadd2
    add.w   #4,currentStep2
    cmp.w   #400,currentStep2
    bne     .contxx
    move.w  #0,currentStep2
.contxx



    sub.w   #1,waitcounter
    beq     .deinit

            check_for_spacebar_to_exit
    jmp     .mainloop


.deinit
     move.w  #800,waitcounter
     move.w #234,currentStep
   move.w  #6,fadecounter
   move.w   #7,flashwait
   move.w   #0,polyInPosition
    move.w  #27,copyCounter
    ; - offset counter
    move.w  #0,screenTargetOffset
    move.w  #0,drawLatch
    move.l  #0,currentVerPath    
.fadeOut
    wait_for_vbl
    swapscreens
    swapclearpointers

    tst.w   polyInPosition
    beq     .noclear
        sub.w   #1,copyCounter
        beq     .done
        move.l  screenpointer2,a0
        add.w   screenTargetOffset,a0
        move.w  #8*2-1,d7
        moveq   #0,d0
.clearline
        REPT 20
            move.l  d0,(a0)+
            move.l  d0,(a0)+        ; 20*8*8 = 10*160 = 1280
        ENDR
        dbra    d7,.clearline
    tst.w   drawLatch
    beq     .swapLatch1
    add.w       #1280*2,screenTargetOffset
    move.w      #0,drawLatch
    jmp         .noclear
.swapLatch1
    move.w       #1,drawLatch
    jmp         .noclear
.done
    move.w  #0,polyInPosition
    move.w  #0,currentStep2
    move.l  #1,currentVerPath
.noclear


    tst.w   flashwait
    beq     .dontfade22
    subq.w  #1,fadecounter
    bne     .dontfade22
    lea     dragonrightpalette,a0
    lea     $ffff8240,a1
    jsr     doFade
    move.w  #6,fadecounter
    sub.w   #1,flashwait
    bne     .dontfade22
    st      polyInPosition
.dontfade22

    jsr     clearArea2
    jsr     doRotationPoly
    jsr     fixProjectedPolySource
    jsr     regelEdges                  ; bright red
    tst.w   noKalms
    bne     .noKalms3
    jsr     drawLinesKalms
    jmp     .contx3
.noKalms3
    jsr     drawLines
    jsr     eorFill2
.contx3

    tst.l   currentVerPath
    beq     .noY
    lea     vertpath2,a0
    add.w   currentStep2,a0
    move.w  (a0),vertices_yoff
    add.w   #2,currentStep2
    cmp.w   #30,currentStep2
    beq     polyZoom
.noY

    lea     horpath3,a0
    add.w   currentStep,a0
    move.w  (a0),vertices_xoff
    add.w   #2,currentStep
    cmp.w   #400,currentStep
    bne     .xhorgood
    move.w  #0,currentStep
.xhorgood    
            check_for_spacebar_to_exit
    jmp     .fadeOut

;;;;;
flashPalette
    dc.w    $0466,$0532,$0411,$0211 ;0
    dc.w    $0466,$0532,$0422,$0222 ;4
    dc.w    $0466,$0533,$0433,$0333 ;8
    dc.w    $0466,$0544,$0444,$0444 ;12
    dc.w    $0566,$0555,$0555,$0555 ;16
    dc.w    $0666,$0666,$0666,$0666 ;20
    dc.w    $0777,$0777,$0777,$0777 ;24
    dc.w    $0777,$0777,$0777,$0777 ;28
    dc.w    $0777,$0777,$0777,$0777 ;32
    dc.w    $0666,$0666,$0666,$0666 ;36
    dc.w    $0566,$0555,$0555,$0555 ;40
    dc.w    $0566,$0555,$0555,$0555 ;44
    dc.w    $0466,$0544,$0444,$0444 ;48
    dc.w    $0466,$0533,$0433,$0333 ;52
    dc.w    $0466,$0532,$0422,$0222 ;56
    dc.w    $0466,$0532,$0411,$0211 ;60

flashPalette2
    dc.w    $0466,$0532,$0411,$0466 ;0
    dc.w    $0466,$0532,$0422,$0466 ;4
    dc.w    $0466,$0533,$0433,$0466 ;8
    dc.w    $0466,$0544,$0444,$0466 ;12
    dc.w    $0566,$0555,$0555,$0566 ;16
    dc.w    $0666,$0666,$0666,$0666 ;20
    dc.w    $0777,$0777,$0777,$0777 ;24
    dc.w    $0777,$0777,$0777,$0777 ;28
    dc.w    $0777,$0777,$0777,$0777 ;32
    dc.w    $0666,$0666,$0666,$0666 ;36
    dc.w    $0566,$0555,$0555,$0566 ;40
    dc.w    $0566,$0555,$0555,$0566 ;44
    dc.w    $0466,$0544,$0444,$0466 ;48
    dc.w    $0466,$0533,$0433,$0466 ;52
    dc.w    $0466,$0532,$0422,$0466 ;56
    dc.w    $0466,$0532,$0411,$0466 ;60


;;;;;
dragonrightpalette
    dc.w    $0466,$0532
    dc.w    $0411,$0211
    REPT    12
        dc.w    $0466
    ENDR

resizeTable
    incbin  res/resizetable.bin
resizePath
    include res/resizepath.s
currentStep3   
    dc.w    0
counterrr
    dc.w    0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
polyZoom   
.init
    move.w  #0,currentStep
    move.w  #0,currentStep2
    move.w  #600,currentStep3
    move.w  #2,stepSpeedY
    move.w  #6,stepSpeedX
    move.w  #4,stepSpeedZ
    move.w  #3,flashwait
    move.w  #1,counterrr ; we want to loop 1 time
.mainloop
    wait_for_vbl
    swapscreens
    swapclearpointers

    tst.w   flashcounter
    beq     .gogogo
    cmp.w   #56,flashcounter
    bne     .cont
        tst.w   noKalms
        beq     .set1
.set0   
        move.w  #0,noKalms
        move.w  #0,glenz
        jmp     .cont
.set1
        sub.w   #1,counterrr
        move.w  #1,noKalms
        move.w  #0,glenz
.cont
    lea     $ffff8240,a0
    lea     flashPalette2,a1
    add.w   flashcounter,a1
    move.w  (a1),backGroundColor
    move.l  (a1)+,(a0)+
    move.l  (a1)+,(a0)+
    add.w   #8,flashcounter
    cmp.w   #128,flashcounter
    bne     .gogogo
    move.w  #0,flashcounter         ; disable flashes
.gogogo

    jsr     clearArea2
    jsr     doRotationPoly
    jsr     fixProjectedPolySource
    jsr     regelEdges
    tst.w   noKalms
    bne     .noKalms
    jsr     drawLinesKalms
    jmp     .cont2
.noKalms
    jsr     drawLines
    jsr     eorFill2
.cont2

    tst     counterrr
    beq     .noFlash
    move.w  currentStep,d0
    cmp.w   #200,d0
    beq     .setFlashCounter
    jmp     .noFlash
.setFlashCounter
        add.w   #8,flashcounter
.noFlash

    lea     horpath,a0
    add.w   currentStep,a0
    move.w  (a0),vertices_xoff
    add.w   #2,currentStep
    cmp.w   #400,currentStep
    bne     .xok
    move.w  #0,currentStep
    tst.w   counterrr
    bne     .xok
        jmp polyEnd
.xok  

    lea     vertpath,a0
    add.w   currentStep2,a0
    move.w  (a0),vertices_yoff
    add.w   #4,currentStep2
    cmp.w   #400,currentStep2
    bne     .yok
    move.w  #0,currentStep2
.yok


    lea     resizePath,a0
    add.w   currentStep3,a0
    move.w  (a0),d0
    lea     resizeTable,a0
    movem.w (a0,d0.w),a1-a4
    jsr     setSizeVertices
    add.w   #2,currentStep3
    cmp.w   #800,currentStep3
    bne     .pok
    move.w  #0,currentStep3
.pok
            check_for_spacebar_to_exit
    jmp    .mainloop


polyEnd
    lea     resizeTable,a0
    movem.w (a0),a1-a4
    jsr     setSizeVertices
    move.w  #0,flashcounter
    move.w  #4,stepSpeedY
    move.w  #4,stepSpeedZ
    move.w  #0,counterrr

    lea     polygon_endpic+34,a0
    move.l  a0,screenSourceAddress
    ; - copy counter
    move.w  #408,copyCounter
    ; - offset counter
    move.w  #0,screenTargetOffset
    move.w  #0,drawLatch
    move.w  #2,fadecounter
    move.w  #400,waitcounter
.mainloop2
    wait_for_vbl
    swapscreens
    swapclearpointers

    sub.w   #8,copyCounter
    ble     .doFade
    move.l  screenSourceAddress,a0
    move.l  screenpointer2,a2
    add.w   screenTargetOffset,a2
    move.w  #160-1,d7
.copyblock
        move.l  (a0)+,(a2)+
        move.l  (a0)+,(a2)+
    dbra    d7,.copyblock
    tst.w   drawLatch
    beq     .swapLatch
    move.l      a0,screenSourceAddress
    add.w       #1280,screenTargetOffset
    move.w      #0,drawLatch
    jmp         .notDone
.swapLatch
    move.w       #1,drawLatch
    jmp         .notDone

.doFade
    subq.w  #1,fadecounter
    bne     .skip
    lea     polygon_endpic+2,a0
    lea     $ffff8240,a1
    jsr     doFade
    move.w  #7,fadecounter
    move.w  #-8,copyCounter
.skip
.notDone

    jsr     clearArea2
    jsr     doRotationPoly
    jsr     fixProjectedPolySource
    jsr     regelEdges
    jsr     drawLines
    jsr     eorFill2

    tst.w   flashcounter
    bne     .xok2
    lea     horpath3,a0
    add.w   currentStep,a0
    move.w  (a0),vertices_xoff
    add.w   #2,currentStep
    cmp.w   #450,currentStep
    bne     .xok2
    move.w  #0,currentStep   
.xok2

    cmp.w   #241,vertices_xoff
    bne     .cont
        cmp.w   #100,currentStep
        blt     .cont
    move.w  #240,vertices_xoff
    move.w  #1,flashcounter
.cont

    tst.w   counterrr
    bne     .yok
    lea     vertpath,a0
    add.w   currentStep2,a0
    move.w  (a0),vertices_yoff
    add.w   #4,currentStep2
    cmp.w   #400,currentStep2
    bne     .yok
    move.w  #0,currentStep2
.yok

    move.w  stepSpeedX,d0
    move.w  stepSpeedY,d1
    move.w  stepSpeedZ,d2
    move.w  currentStepX,d3
    move.w  currentStepY,d4
    move.w  currentStepZ,d5

    tst.w   flashcounter
    bne     .noway
        cmp.w   #114,vertices_yoff
        bne     .noway
        move.w  #1,counterrr
.noway 
    cmp.w   #256,currentStepZ
    bne     .noZ
    move.w  #0,stepSpeedZ
.noZ
    cmp.w   #384,currentStepX
    bne     .noX
    move.w  #0,stepSpeedX
.noX
    cmp.w   #128,currentStepY
    bne     .noY
    move.w  #0,stepSpeedY
.noY

            check_for_spacebar_to_exit
    sub.w   #1,waitcounter
    bne     .mainloop2

.fadeouttheshitfornextscene

    lea     mask_buffer,a0
    moveq   #40-1,d7
.start_showmask: 
    movea.l screenpointer,a1

    moveq   #7-1,d3
.mask_outerloop: 
    moveq   #10-1,d0
.mask_loop:

o   SET 0

    REPT 32
        move.w  (a0)+,d1
        move.w  (a0)+,d2
    
        and.w   d1,o(a1)
        and.w   d1,o+2(a1)
        and.w   d1,o+4(a1)
        and.w   d1,o+6(a1)
    
        and.w   d2,o+8(a1)
        and.w   d2,o+10(a1)
        and.w   d2,o+12(a1)
        and.w   d2,o+14(a1)
o       SET o+160

    ENDR

    lea     -64*2(a0),a0
    lea     16(a1),a1

    dbra    d0,.mask_loop

    lea     -160(a1),a1
    lea     32*160(a1),a1

    dbra    d3,.mask_outerloop

    addi.w  #64,mask_offset
    addi.w  #64,mask_offset

    lea     mask_buffer,a0
    adda.w  mask_offset,a0

    dbra    d7,.start_showmask

sub_wait_a_bit: clr.l   $0466.w
                moveq   #25,D7          ; wait 2 seconds
wvbl_wait:      tst.l   $0466.w
                beq.s   wvbl_wait
                clr.l   $0466.w
                dbra    D7,wvbl_wait

    jsr     sub_rasterinit

                move.w  #120,D6         ; wait until colors are gone
wait_rasters:   jsr   sub_wvbl
                dbra    D6,wait_rasters

                lea     $FFFF8240,A0
                moveq   #16-1,D0
.blackpal_loop:  move.w  #0,(A0)+
                dbra    D0,.blackpal_loop

    move.l  #default_vbl,a0
    move.l  #dummy,a1
    jsr     install_vbl_hbl 
    wait_for_vbl
.nextscene
    jmp     polygon_nextscene


mask_offset:    DS.W 1
tb_flag:        DS.W 1  


sub_rasterinit: moveq   #0,D0           ; d0 = linecounter (where tb is triggered)
                lea     rastercolors,A0

                move    #$2700,SR

                clr.b   $FFFFFA07.w
                clr.b   $FFFFFA09.w

                move.l  #rte_tb,$0120.w

                clr.b   $FFFFFA1B.w
                move.b  #255,$FFFFFA21.w
                bset    #0,$FFFFFA07.w
                bset    #0,$FFFFFA13.w
                bclr    #3,$FFFFFA17.w  ; auto eoi

                move    #$2300,SR

                jsr     sub_wvbl

                move.l  #new_vbl_z,$70.w

                rts


new_vbl_z:        
                move    #$2700,SR
                move.w  2(A0),$FFFF8240.w ; get color from rasterpalette
                addq.w  #8,d0

                move.w  #32,$0140.w     ; counter for upper border opener
                move.l  #new_hbl_z,$68.w

                move.b  #$21,(SP)       ; hbl on
end_vbl_z:        addq.l  #1,$0466.w

                rte


vbl_dummy:      addq.l  #1,$0466.w
                move.w  #0,$FFFF8240.w
                clr.b   $FFFFFA1B.w
                rte

        ;        ENDPART
        ;        >PART 'NEW HBL'

new_hbl_z:        subq.w  #1,$0140.w      ; decrease from 32 to -1
                bmi.s   hbl_appeared

                rte

hbl_appeared:   move    #$2700,SR
                move.l  #hbl_sync_z,$68.w
                move.b  $FFFFFA13.w,reset_1+3 ; save mfp
                move.b  $FFFFFA15.w,reset_2+3
                clr.b   $FFFFFA13.w     ; lock mfp
                clr.b   $FFFFFA15.w

hbl_wait_z:       stop    #$2100          ; wait until next hbl
                bra.s   hbl_wait_z

hbl_sync_z:       move    #$2700,SR
                addq.l  #6,SP

                move.l  D0,-(SP)
                moveq   #24,D0
borderwait:     dbra    D0,borderwait

                move.l  (SP)+,D0

                move.b  #0,$FFFF820A.w  ; 60 Hz
                rept 24
                    nop
                endr
                move.b  #2,$FFFF820A.w  ;50 Hz

                cmpi.w  #228,D0         ; line for opening the lower border?
                bge.s   init_borderopen ; if not, then set tb for colorchange

init_colorchange:
                move.l  #tb_color,$0120.w ; colorchange <y228
                clr.b   $FFFFFA1B.w
                move.b  D0,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                bra.s   reset_1

init_borderopen:
                st      tb_flag
                move.l  #tb_bottom,$0120.w ; colorchange >y228?
                clr.b   $FFFFFA1B.w     ; then open border first
                move.b  #228,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w

reset_1:        move.b  #$12,$FFFFFA13.w ; restore mfp
reset_2:        move.b  #$34,$FFFFFA15.w ;

                jsr     music+8
                move.b  #$23,(SP)       ; interrupts on (except hbl)

                rte

*** timer b routine for lines <y228 (changig color) ****************************

tb_color:       move    #$2700,SR

                move.w  (A0),$FFFF8240.w ; push bottom color in

                move.l  #tb_bottom,$0120.w ; set timer for border opener
                clr.b   $FFFFFA1B.w

                move.w  #228,D1         ; calculate the line
                sub.w   D0,D1           ; for opening lower border

                move.b  D1,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w

                rte

*** timer b routine for line y228 (opening the lower border) *******************

tb_bottom:      move    #$2700,SR

                clr.b   $FFFFFA1B.w
                move.b  #2,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w

                move.w  D0,-(SP)

                move.b  $FFFFFA21.w,D0
tb_sync:        cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
                beq.s   tb_sync

                move.w  (SP)+,D0

                move.b  #0,$FFFF820A.w  ; 60 hz
                REPT 18
                    nop
                ENDR
                move.b  #2,$FFFF820A.w  ; 50 hz

                tst.w   tb_flag         ; >y228 (lower border?)
                beq.s   rte_tb

                move.w  D0,D1           ; calculate lines till next tb
                sub.w   #228,D1

                move.l  #tb_bottom_change,$0120.w ; colorchange >y228
                clr.b   $FFFFFA1B.w
                move.b  D1,$FFFFFA21.w  ; set next timer b
                move.b  #8,$FFFFFA1B.w

                tst.w   D1              ; exactly y228?
                bne.s   not_228

                move.w  (A0),$FFFF8240.w ; then colorchange

not_228:        rte

rte_tb:         clr.b   $FFFFFA1B.w

                rte

*** timer b routine for lines >y228 *******************************************

tb_bottom_change:
                move    #$2700,SR

                move.w  (A0),$FFFF8240.w ; push bottom color in

                cmp.w   #270,D0         ; end of the visible screen?
                ble.s   tb_bottom_end

                moveq   #0,D0           ; re-init linecounter
                addq.w  #2,A0           ; point to next color

tb_bottom_end:  clr.b   $FFFFFA1B.w
                rte

;;;;;;;;;;;;;;;;;;;; END POLYGON ROUT ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;; START POLYGON CODE ;;;;;;;;;;;;;;

savedXstep
    dc.w    0
savedYstep
    dc.w    0
savedZstep
    dc.w    0

polygon_bottom_vbl:    
    move.l screenpointershifter,$ff8200
    addq.w  #1,$466
    IFNE    playmusic                               
            pushall
            jsr music+8
            popall
    ENDC
        IFNE    framecount
            addq.w  #1,framecounter
        ENDC
    ;Start up Timer B each VBL
    move.w  #$2700,sr                       ;Stop all interrupts
    clr.b   $fffffa1b.w                     ;Timer B control (stop)
    bset    #0,$fffffa07.w                  ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w                  ;Interrupt mask A (Timer B)
    move.b  #185,$fffffa21.w                  ;Timer B data (number of scanlines to next interrupt)
    bclr    #3,$fffffa17.w                  ;Automatic end of interrupt
    move.b  #8,$fffffa1b.w                  ;Timer B control (event mode (HBL))
    rte     

polygon_bottom_hbl
        move.w  #0,$ffff8240
    rte

setSizeVertices
    ; a1 is nn      -->> addq.w #2          add.w   a1,
    ; a2 is np      -->> subq.w #2          move.w  a2
    ; a3 is sn      -->> add.w  d6          move.w  a3
    ; a4 is sp      -->> sub.w  d6          move.w  a4


    lea     coordsource,a0
    movem.w (a0)+,d0-d5
    move.w  a1,d0           ;p0     dc.w    negsize,negsize,negsize ; (-1,-1,-1)    left,   top,    back    ;0      0       0*s
    move.w  a1,d1
    move.w  a1,d2
    move.w  a2,d3           ;p1     dc.w    possize,negsize,negsize ; ( 1,-1,-1)    right,  top,    back    ;6      4       1*s
    move.w  a1,d4
    move.w  a1,d5
    movem.w d0-d5,-12(a0)
    movem.w (a0)+,d0-d5
    move.w  a1,d0           ;p2     dc.w    negsize,possize,negsize ; (-1, 1,-1)    left,   bottom, back    ;12     8       2*s
    move.w  a2,d1
    move.w  a1,d2
    move.w  a2,d3           ;p3     dc.w    possize,possize,negsize ; ( 1, 1,-1)    right,  bottom, back    ;18     12      3*s
    move.w  a2,d4
    move.w  a1,d5
    movem.w d0-d5,-12(a0)
    movem.w (a0)+,d0-d5
    ;addq.w #4,d0           ;p4     dc.w    0,0,negsize2            ; ( 0, 0,-1)    middle, middle, back    ;24     16      4*s
    ;subq.w #4,d1
    move.w  a3,d2
    move.w  a1,d3           ;p5     dc.w    negsize,negsize,possize ; (-1,-1, 1)    left,   top,    front   ;30     20      5*s
    move.w  a1,d4
    move.w  a2,d5
    movem.w d2-d5,-8(a0)
    movem.w (a0)+,d0-d5
    move.w  a2,d0           ;p6     dc.w    possize,negsize,possize ; ( 1,-1, 1)    right,  top,    front   ;36     24      6*s
    move.w  a1,d1
    move.w  a2,d2
    move.w  a1,d3           ;p7     dc.w    negsize,possize,possize ; (-1, 1, 1)    left,   bottom, front   ;42     28      7*s
    move.w  a2,d4
    move.w  a2,d5
    movem.w d0-d5,-12(a0)   
    movem.w (a0)+,d0-d5
    move.w  a2,d0           ;p8     dc.w    possi   ze,possize,possize ; ( 1, 1, 1)    right,  bototm, front   ;48     32      8*s
    move.w  a2,d1
    move.w  a2,d2
;   addq.w  #4,d3           ;p9     dc.w    0,0,possize2            ; ( 0, 0, 1)    middle, middle, front   ;54     36      9*s
;   subq.w  #4,d4
    move.w  a4,d5
    movem.w d0-d5,-12(a0)   
    movem.w (a0)+,d0-d5
    move.w  a3,d0           ;p10    dc.w    negsize2,0,0            ; (-1, 0, 0)    left,   middle, middle  ;60     40      10*s
;   addq.w  #4,d1
;   subq.w  #4,d2
    move.w  a4,d3           ;p11    dc.w    possize2,0,0        ;m          48              right           ;66     44      11*s
;   subq.w  #4,d4
;   subq.w  #4,d5
    movem.w d0-d5,-12(a0)   
    movem.w (a0)+,d0-d5
;   subq.w  #4,d0           ;p12    dc.w    0,negsize2,0        ;l          44              down            ;72     48      12*s
    move.w  a3,d1
;   subq.w  #4,d2
;   addq.w  #4,d3           ;p13    dc.w    0,possize2,0        ;k          40              up              ;78     52      13*s
    move.w  a4,d4
;   subq.w  #4,d5
    movem.w d0-d5,-12(a0)
    rts


modify_y_offset
    lea     path,a1
    move.w  currentStepX,d1
    add.w   d1,d1
    add.w   d1,d1
    add.w   d1,a1                              ;16
    move.w  (a1),d0
    lsr.w   #1,d0

    lea     sintable,a0
    move.w  (a0,d0.w),d0

    move.w  d0,d1
    add.w   d0,d0
    add.w   d0,d0
    add.w   d0,d0
    add.w   d1,d0   ;x9
    bge     .cont
    neg.w   d0
.cont       
    asr.w   #8,d0
    add.w   d0,d0
    move.w  d0,vertices_yoff_mod
    rts

vertices_yoff_mod
    dc.w    0

fixProjectedPolySource
    move.l  screenpointer2,a0
    IFNE    rasters
        move.w  #$040,$ffff8240
    ENDC


    move.l  clearpointer,a0
    move.l  screenpointer2,(a0)+
    move.w  vertices_yoff,d1
    sub.w   vertices_yoff_mod,d1
    move.w  d1,(a0)+
    swap    d1
    move.w  vertices_xoff,d1
    move.w  d1,(a0)+
    swap    d1

    lea     vertexprojection,a0                 ;12
    lea     projectedPolySource,a1              ;8

    ; 14*12 = 168
    ; 71*16 = 1136
    ; 1*12 = 12
    ; +28

    ; we have 14 things
    ; d0-d7 = 8
    ; a0-a7 = 8


    ; ~72*4 cycles can be won by reordering this data to
        move.l  a7,savedA7 
        move.l  d0,(a1)+
        
        movem.l (a0)+,a1-a7     ; first 7

        add.l   d1,a1
        add.l   d1,a2
        add.l   d1,a3
        add.l   d1,a4
        add.l   d1,a5
        add.l   d1,a6
        add.l   d1,a7

        add.l   a1,a1
        add.l   a1,a1
        add.l   a2,a2
        add.l   a2,a2
        add.l   a3,a3
        add.l   a3,a3
        add.l   a4,a4
        add.l   a4,a4
        add.l   a5,a5
        add.l   a5,a5
        add.l   a6,a6
        add.l   a6,a6
        add.l   a7,a7
        add.l   a7,a7

;       move.l  d0,a1       ;52,68,148,164,244,260
;       move.l  d2,a2       ;8,40,152,184,256,272
;       move.l  d3,a3       ;64,80,112,128,248,280
;       move.l  d4,a4       ;28,44,124,140,268,284
;       move.l  d5,a5       ;240,252,264,276
;       move.l  d6,a6       ;56,88,160,176,200,208
;       move.l  d7,a7       ;4,20,172,188,212,220

        movem.l (a0)+,d0/d2-d7      ; second
        add.l   d1,d0
        add.l   d1,d2
        add.l   d1,d3
        add.l   d1,d4
        add.l   d1,d5
        add.l   d1,d6
        add.l   d1,d7
    
        lsl.l   #2,d0       ;76,92,100,116,196,236
        lsl.l   #2,d2       ;16,32,104,136,224,232
        lsl.l   #2,d3       ;192,204,216,228
        lsl.l   #2,d4       ;48,60,72,84------
        lsl.l   #2,d5       ;0,12,24,36---------
        lsl.l   #2,d6       ;144,156,168,180
        lsl.l   #2,d7       ;96,108,120,132-----


        lea projectedPolySource,a0
        ;0
        move.l  d5,(a0)+        ;0
        move.l  a7,(a0)+        ;4
        move.l  a2,(a0)+        ;8
        move.l  d5,(a0)+        ;12
        move.l  d2,(a0)+        ;16
        move.l  a7,(a0)+        ;20
        ;24
        move.l  d5,(a0)+        ;24
        move.l  a4,(a0)+        ;28
        move.l  d2,(a0)+        ;32
        move.l  d5,(a0)+        ;36
        move.l  a2,(a0)+        ;40
        move.l  a4,(a0)+        ;44
        ;48
        move.l  d4,(a0)+        ;48
        move.l  a1,(a0)+        ;52
        move.l  a6,(a0)+        ;56
        move.l  d4,(a0)+        ;60
        move.l  a3,(a0)+        ;64
        move.l  a1,(a0)+        ;68
        ;72
        move.l  d4,(a0)+        ;72
        move.l  d0,(a0)+        ;76
        move.l  a3,(a0)+        ;80
        move.l  d4,(a0)+        ;84
        move.l  a6,(a0)+        ;88
        move.l  d0,(a0)+        ;92
        ;96
        move.l  d7,(a0)+        ;96
        move.l  d0,(a0)+        ;100
        move.l  d2,(a0)+        ;104
        move.l  d7,(a0)+        ;108
        move.l  a3,(a0)+        ;112
        move.l  d0,(a0)+        ;116
        ;120
        move.l  d7,(a0)+        ;120
        move.l  a4,(a0)+        ;124
        move.l  a3,(a0)+        ;128
        move.l  d7,(a0)+        ;132
        move.l  d2,(a0)+        ;136
        move.l  a4,(a0)+        ;140
        ;144
        move.l  d6,(a0)+        ;144
        move.l  a1,(a0)+        ;148
        move.l  a2,(a0)+        ;152
        move.l  d6,(a0)+        ;156
        move.l  a6,(a0)+        ;160
        move.l  a1,(a0)+        ;164
        ;168
        move.l  d6,(a0)+        ;168
        move.l  a7,(a0)+        ;172
        move.l  a6,(a0)+        ;176
        move.l  d6,(a0)+        ;180
        move.l  a2,(a0)+        ;184
        move.l  a7,(a0)+        ;188
        ;192
        move.l  d3,(a0)+        ;192
        move.l  d0,(a0)+        ;196
        move.l  a6,(a0)+        ;200
        move.l  d3,(a0)+        ;204
        move.l  a6,(a0)+        ;208
        move.l  a7,(a0)+        ;212
        move.l  d3,(a0)+        ;216
        move.l  a7,(a0)+        ;220
        move.l  d2,(a0)+        ;224
        move.l  d3,(a0)+        ;228
        move.l  d2,(a0)+        ;232
        move.l  d0,(a0)+        ;236
        move.l  a5,(a0)+        ;240
        move.l  a1,(a0)+        ;244
        move.l  a3,(a0)+        ;248
        move.l  a5,(a0)+        ;252
        move.l  a2,(a0)+        ;256
        move.l  a1,(a0)+        ;260
        move.l  a5,(a0)+        ;264
        move.l  a4,(a0)+        ;268
        move.l  a2,(a0)+        ;272
        move.l  a5,(a0)+        ;276
        move.l  a3,(a0)+        ;280
        move.l  a4,(a0)+        ;284
        move.l  savedA7,a7

    rts

    ds.l    3
projectionSaved
    ds.w    6
savedA7
    ds.l    1
number_of_polygons      
    ds.w    1



regelEdges:
    IFNE rasters
        move.w  #$700,$ffff8240
    ENDC
    lea     projectedPolySource,a0                  ;12
    lea     polyEdgesList,a4                        ;12
    moveq   #0,d0                                   ;4
    moveq   #%10,d1                                 ;4

;    jmp     doGlenz
    move.w  glenz,d2                            ;12
    bne     doGlenz

    move.w  number_of_polygons(PC),d7               ;12
.checkAndSetPolyGon
    move.w  (a0)+,a5                                                            ;8                      
    move.w  (a0)+,a6                                                            ;8
    movem.w (a0)+,d2-d5                                                         ;24         ; point data
    movem.l (a4)+,a1-a3                                                         ;36         ; lines data
    ; z = (d1.x * d2.y) - (d1.y * d2.x) 
    move.w  d4,d6                                                               ;4
    sub.w   d2,d4   ; d2.x      ;d2.x = v3.x - v2.x                             ;4
    sub.w   a5,d6   ; d1.x      ;d1.x = v3.x - v1.x                             ;4
    move.w  d5,d2               ; save d5                                       ;4
    sub.w   d3,d5   ; d2.y      ;d2.y = v3.y - v2.y                             ;4
    muls    d5,d6               ;d1.x * d2.y                                    ;52     
    move.w  d2,d5                                                               ;4
    sub.w   a6,d5   ; d1.y      ;d1.y = v3.y - v1.y                             ;4
    muls    d4,d5               ;d1.yllll * d2.x                                ;48

    sub.l   d5,d6       ; d7 = z            ;6                                  ;4
    bgt     .visible                                                            ;12
;;;;;;;;;; notvisible
    subq.w  #2,d0                                                                   ;4      
    beq     .istwoNotvisible                                                    ;8      --> 204
.iszeroNotvisible       
    ; now set that bitplane 1 for these lines are not known
    and.w   d1,(a1)                                                         ;16
    and.w   d1,(a2)                                                         ;16
    and.w   d1,(a3)                                                         ;16
    ; the next polygon is in bitplane 2
    moveq   #2,d0   
    dbra.w  d7,.checkAndSetPolyGon                                                  ;12
    rts
.istwoNotvisible
    ; now set that bitplane 2 for these lines are not known
    and.w   #%01,(a1)
    and.w   #%01,(a2)
    and.w   #%01,(a3)
    ; the next polygon is in bitplane 1
    dbra.w  d7,.checkAndSetPolyGon
    rts
;;;;;;;;;;; visible code
.visible
    subq.w  #2,d0
    beq     .istwoVisible   
.iszeroVisible
    or.w    #%1,(a1)
    or.w    #%1,(a2)
    or.w    #%1,(a3)
    moveq   #2,d0
    dbra.w  d7,.checkAndSetPolyGon
    rts
.istwoVisible
    or.w    d1,(a1)
    or.w    d1,(a2)
    or.w    d1,(a3)
    dbra.w  d7,.checkAndSetPolyGon
    rts




doGlenz
        ; this clears the linelist, so that they can be done afresh
        lea     linesList,a5
o       SET 0
        moveq   #0,d0
        REPT number_of_edges+1
            move.w  d0,o(a5)
o       SET o+10
        ENDR
        moveq   #1,d0


.checkAndSetPolyGon0
    REPT 12
    move.w  (a0)+,a5                                                            ;8                      
    move.w  (a0)+,a6                                                            ;8
    movem.w (a0)+,d2-d5                                                         ;24         ; point data
    movem.l (a4)+,a1-a3                                                         ;36         ; lines data
    ; z = (d1.x * d2.y) - (d1.y * d2.x) 
    move.w  d4,d6                                                               ;4
    sub.w   d2,d4   ; d2.x      ;d2.x = v3.x - v2.x                             ;4
    sub.w   a5,d6   ; d1.x      ;d1.x = v3.x - v1.x                             ;4
    move.w  d5,d2               ; save d5                                       ;4
    sub.w   d3,d5   ; d2.y      ;d2.y = v3.y - v2.y                             ;4
    muls    d5,d6               ;d1.x * d2.y                                    ;52     
    move.w  d2,d5                                                               ;4
    sub.w   a6,d5   ; d1.y      ;d1.y = v3.y - v1.y                             ;4
    muls    d4,d5               ;d1.yllll * d2.x                                ;48

    sub.l   d5,d6       ; d7 = z            ;6                                  ;4
    bgt     *+18    ;.visible0                                                          ;12
;;;;;;;;;; notvisible
    move.w  d1,(a1)                                                         ;16
    move.w  d1,(a2)                                                         ;16
    move.w  d1,(a3)                                                         ;16
    add.w   #12,a0
    add.w   #12,a4
    bra     *+16    ;nextiter
;   dbra.w  d7,.checkAndSetPolyGon0                                             ;12
;   rts
;;;;;;;;;;; visible code
;.visible0
    move.w  d0,(a1)
    move.w  d0,(a2)
    move.w  d0,(a3)
    add.w   #12,a0
    add.w   #12,a4
;   dbra.w  d7,.checkAndSetPolyGon0
;   rts
    ENDR
nextiter
    rts


;; calling: doClipping x,y
; where 
;   x = do we have stepping to take into account    1 = stepping
;   y = do we have positive or negative offset      1 = positive
;   a1 = whole stepping (if needed)
;   a2 = is fraction
;;;; TODO: offset for fraction
doLeftRightClipping macro
.left
    ; clipping,check if x < 0
    tst.w   d0
    bge     .right
    ; if x < 0; then x = 0, but we also need to adjust the y drawing
    ; there are 2 ways, the stepping, and the fraction (precision)

    neg     d0      ; now d0 is positive
    sub.w   d0,d2
    blt     .nodraw

    ; if we have NORMAL stepping to do, we need to take this into account as well
    lsr.w   #2,d0

    IFNE \1
        move.w  a1,d3       ; move stepping to d3
        mulu    d0,d3       ; number of steps clipped
        add.w   d3,a0       ; add offset to a0
    ENDC

    move.w  a2,d3           ; move the fraction to d3
    mulu    d0,d3           ; number of steps clipped
    swap    d3              ; swap to the whole part
    add.w   d3,d3
    add.w   d3,d3

    IFNE \2
        add.w   (a3,d3.w),a0        ; if positive, add to a0
    ELSE
        sub.w   (a3,d3.w),a0        ; if negative, subtract from a0
    ENDC
    moveq   #0,d0           ; clip d0 to 0
.leftdone
    jmp     .draw
.right
    move.w  d2,d3
    add.w   d0,d3
    cmp.w   #319*4,d3
    ble.w   .draw
    ; here we know that the right point is out of bound, we also have to check for the left point
    cmp.w   #319*4,d0
    bge     .nodraw

    move.w  #319*4,d2
    sub.w   d0,d2
    jmp     .draw

.nodraw
    lea space2longword,a4
    rts
.draw
    endm    


drawLinesKalms:
    IFNE    rasters
        move.w  #$707,$ffff8240
    ENDC
    lea     linesList,a5                            ;12
    move.l  screenpointer2,a4
    move.l  a4,usp                  ;

    move.w  #number_of_edges,a4                 ;
    add.w   #1,a4 

.doLine
    sub.w   #1,a4
    ; first word is used to determine if we need to draw
    move.w  (a5)+,d0        ;2
    ble     .noDraw         ;2                      ;+44
    ; when we get here, its either 1,2,3
.justDraw
    move.l  (a5)+,a6        ;2      ; next longword is first vertex pointer         ;12             12
    move.w  (a6)+,d0        ;2      ; get x                                         ;8              movem.w (a6,d0.w),d0-d1 28
    move.w  (a6),d1         ;2      ; get y                                         ;8              swap    4
    move.l  (a5)+,a6        ;2      ; get 2nd vertex pointer                        ;12             movem.w (a6,)
    movem.w (a6)+,d2-d3     ;4                                              ;20

    move.l  usp,a0
    lsr     #2,d0
    lsr     #2,d1
    lsr     #2,d2
    lsr     #2,d3
    jsr     SegmentedLine

    move.w  a4,d0
    bne     .doLine
    rts

.noDraw
    add.w   #8,a5
    move.w  a4,d0
    bne     .doLine
    rts 

space2longword
    ds.l    2


drawLines:
    IFNE    rasters
        move.w  #$707,$ffff8240
    ENDC

    move.l  a7,savedA7
    ; used for drawline
    lea     y_block2,a3                              ;12 
    lea     divtable,a5                             ;12
    move.l  a5,usp                                  ;4
    lea     linesList,a5                            ;12
    move.l  screenpointer2,a7                   ;


    moveq   #%1000,d5               ; 4 eor = 1000  8 bchg 
    moveq   #%100000,d4
    move.w  #%10000000,d6               ; eor = 100000              ; 111111
    moveq   #%1000000,d7
    swap    d7
    move.w  #number_of_edges,d7                 ; 
.doLine
    ; first word is used to determine if we need to draw
    move.w  (a5)+,d0        ;2
    ble     .noDraw         ;2                      ;+44
    ; when we get here, its either 1,2,3
    ; so we need to draw anyhow, so load the screen pointer
    move.l  a7,a0           ;2
    subq.w  #2,d0           ;2
    blt     .justDraw
    bgt     .drawTwo        ;2          ;+50 ; if result > 0 then its 3, draw two pixels
;   bne     .justDraw       ;2          ;+4 ; if result is not > 0, and not 0, its -1, and we need to just draw without altering the screen pointer
.drawOtherBitPlane  
    add.w   #2,a0           ;2
.justDraw
    move.l  (a5)+,a6        ;2      ; next longword is first vertex pointer         ;12             12
    move.w  (a6)+,d0        ;2      ; get x                                         ;8              movem.w (a6,d0.w),d0-d1 28
    move.w  (a6),d1         ;2      ; get y                                         ;8              swap    4
    move.l  (a5)+,a6        ;2      ; get 2nd vertex pointer                        ;12             movem.w (a6,)
    movem.w (a6)+,d2-d3     ;4                                              ;20
    swap    d7              ;2
    jsr     drawLine        ;4
    move.l  a6,(a4)         ;2          ;12

    swap    d7              ;2
    dbra    d7,.doLine      ;4
    move.l  savedA7(PC),a7  ;4
    rts                     ;2

.noDraw
    add.w   #8,a5           ;2  ; skip the line offset
    dbra    d7,.doLine      ;4  ;-48
    move.l  savedA7(PC),a7  ;4
    rts                     ;2

.drawTwo
    move.l  (a5)+,a6        ;2
    move.w  (a6)+,d0        ;2
    move.w  (a6),d1         ;2
    move.l  (a5)+,a6        ;2
    movem.w (a6)+,d2-d3     ;4
    swap    d7              ;2
    jsr     drawLine2       ;4
    move.l  a6,(a4)+        ;2              ;12
    move.l  -4(a3),(a4)

    swap    d7              ;2
    dbra    d7,.doLine      ;4
    move.l  savedA7(PC),a7  ;4
    rts 


eor_mask_and_offset_12_12
val     set 0
val2    set 0
    REPT 20
        REPT 8
            dc.w    val,val2
val         set val+firsthalf
        ENDR
val2        set val2+1
        REPT 7
            dc.w    val,val2
val         set val+secondhalf
        ENDR
        dc.w    val,val2
val         set 0
val2        set val2+7
    ENDR


firsthalf   equ 12
secondhalf  equ 12
last        equ 14
y_positive_target_abs
val     set lines_with_add
    REPT 20
        REPT 8
            dc.l    val
val         set val+firsthalf
        ENDR
        REPT 7
            dc.l    val
val         set val+secondhalf
        ENDR
        dc.l    val
val         set val+last
    ENDR

y_negative_target_abs
val     set lines_with_add_neg
    REPT 20
        REPT 8
            dc.l    val
val         set val+firsthalf
        ENDR
        REPT 7
            dc.l    val
val         set val+secondhalf
        ENDR
        dc.l    val
val         set val+last
    ENDR


;   a0 is screenptr
;   a1 is divtable
;   a2 is fraction
;   a3 is y-offset
;   a4 is projectionptr
;   a5 is smc address
;   a6 is smc opcode
dummyaddr
    ds.l    1

savedA6
    ds.l    1

drawLine
    cmp.w   d0,d2               ; is d2 > d0 ?      ;4
    bge     .noswap                                 ;12
    exg     d0,d2                                   ;8
    exg     d1,d3                                   ;8
.noswap
    sub.w   d0,d2               ; d2 is count (dx)  ;4
;   IFNE    hline_and_vline
;       beq     .vline
;   ENDC
    sub.w   d1,d3               ; d3 is dy          ;4
;   IFNE    hline_and_vline
;       beq     .hline
;   ENDC
    bge     y_positive                                  ;8

;;;;;; y negative
y_negative
    neg     d3                                      ;4  
    asl.l   #7,d3                                   ;22
    or.w    d2,d3                                   ;8

    move.l  usp,a6                                  ;4
    add.l   d3,a6                                   ;8
    move.w  (a6)+,d3                                ;8
    beq     no_add_y_negative

.add_y_negative
    neg     d3                                      ;4

    move.w  (a6),a2                                 ;8
    move.w  d3,a1                                   ;8

    doLeftRightClipping 1,0     ; no add, negative y

    lea     eor_mask_and_offset_12_12(PC),a4                ;8      
    move.l  (a4,d0.w),d3        ; eor/offset 16.16  ;20     
    add.w   (a3,d1.w),d3                            ;16     
    add.w   d3,a0               ; screen+off        ;8      
    swap    d3              ; swap to mask          ;4          -->48

    and.w   #$3c,d0         ; 8
    add.w   d0,d2           ; 4

    lea     y_negative_target_abs(PC),a6            ;8   moveq #x,d0 ; swap d0 add.w d2,d0 move.l d0,a6 move.l (a6),a4
    move.l  (a6,d2.w),a4                            ;20
    move.l  (a4),a6
    move.w  #$4E75,(a4) 

    moveq   #0,d1                                   ;4      
    moveq   #%1,d0                              ;4      ; 1 eor = 01, 2 bchg = 10
    moveq   #%100,d2                            ;4      ; 3 eor = 100, 5 bcgh = 10000

    jmp     lines_with_add_neg(PC,d3.w)             ;16

lines_with_add_neg  
;1
    REPT 7
        eor.b       d6,(a0)  
        add.w       a1,a0    
        add.w       a2,d1    
        bcc.s       *+6      
        add.w       #-160,a0 
;2
        eor.b       d7,(a0)  
        add.w       a1,a0    
        add.w       a2,d1    
        bcc.s       *+6      
        add.w       #-160,a0 
;3
        eor.b       d4,(a0)  
        add.w       a1,a0    
        add.w       a2,d1    
        bcc.s       *+6      
        add.w       #-160,a0 
;4
        bchg.b      d2,(a0)  
        add.w       a1,a0    
        add.w       a2,d1    
        bcc.s       *+6      
        add.w       #-160,a0 
;5
        eor.b       d5,(a0)  
        add.w       a1,a0    
        add.w       a2,d1    
        bcc.s       *+6      
        add.w       #-160,a0 
;6
        eor.b       d2,(a0)  
        add.w       a1,a0    
        add.w       a2,d1    
        bcc.s       *+6      
        add.w       #-160,a0 
;7
        bchg.b      d0,(a0)  
        add.w       a1,a0    
        add.w       a2,d1    
        bcc.s       *+6      
        add.w       #-160,a0 
;8
        eor.b       d0,(a0)+ 
        add.w       a1,a0    
        add.w       a2,d1    
        bcc         *+6      
        add.w       #-160,a0 
;9
        eor.b       d6,(a0)  
        add.w       a1,a0    
        add.w       a2,d1    
        bcc         *+6      
        add.w       #-160,a0 
;10
        eor.b       d7,(a0)  
        add.w       a1,a0    
        add.w       a2,d1    
        bcc         *+6      
        add.w       #-160,a0 
;11
        eor.b       d4,(a0)  
        add.w       a1,a0    
        add.w       a2,d1    
        bcc         *+6      
        add.w       #-160,a0 
;12
        bchg.b      d2,(a0)  
        add.w       a1,a0    
        add.w       a2,d1    
        bcc         *+6      
        add.w       #-160,a0 
;13
        eor.b       d5,(a0)  
        add.w       a1,a0    
        add.w       a2,d1    
        bcc         *+6      
        add.w       #-160,a0 
;14
        eor.b       d2,(a0)  
        add.w       a1,a0    
        add.w       a2,d1    
        bcc         *+6      
        add.w       #-160,a0 
;15
        bchg.b      d0,(a0)  
        add.w       a1,a0    
        add.w       a2,d1    
        bcc         *+6      
        add.w       #-160,a0 
;16
        eor.b       d0,(a0)  
        add.w       #7,a0    
        add.w       a1,a0    
        add.w       a2,d1    
        bcc         *+6      
        add.w       #-160,a0 
    ENDR


y_positive
    asl.l   #7,d3                                   
    or.w    d2,d3

    move.l  usp,a6

    add.l   d3,a6       ;8
    move.w  (a6)+,d3    ;8

    beq     no_add_y_pos

    move.w  (a6),a2     ;8
    move.w  d3,a1                               ;8

    doLeftRightClipping 1,1     ; add, positive

    lea     eor_mask_and_offset_12_12(PC),a4                ;8      
    move.l  (a4,d0.w),d3        ; eor/offset 16.16  ;20     
    add.w   (a3,d1.w),d3                            ;16     
    add.w   d3,a0               ; screen+off        ;8      
    swap    d3              ; swap to mask          ;4          -->48

    and.w   #$3c,d0
    add.w   d0,d2

    lea     y_positive_target_abs(PC),a6                    ;8
    move.l  (a6,d2.w),a4
    move.l  (a4),a6         ; a6 is opcode      ;12
    move.w  #$4E75,(a4) 

    moveq   #0,d1                                   ;4      
    moveq   #%1,d0                              ;4      ; 1 eor = 01, 2 bchg = 10
    moveq   #%100,d2                            ;4      ; 3 eor = 100, 5 bcgh = 10000

    jmp     lines_with_add(PC,d3.w)             ;16

lines_with_add  
;1
    REPT 7
        eor.b       d6,(a0)      
        add.w       a1,a0        
        add.w       a2,d1        
        bcc.s       *+6          
        add.w       #160,a0      
;2
        eor.b       d7,(a0)      
        add.w       a1,a0        
        add.w       a2,d1        
        bcc.s       *+6          
        add.w       #160,a0      
;3
        eor.b       d4,(a0)      
        add.w       a1,a0        
        add.w       a2,d1        
        bcc.s       *+6          
        add.w       #160,a0      
;4
        bchg.b      d2,(a0)      
        add.w       a1,a0        
        add.w       a2,d1        
        bcc.s       *+6          
        add.w       #160,a0      
;5
        eor.b       d5,(a0)      
        add.w       a1,a0        
        add.w       a2,d1        
        bcc.s       *+6          
        add.w       #160,a0      
;6
        eor.b       d2,(a0)      
        add.w       a1,a0        
        add.w       a2,d1        
        bcc.s       *+6          
        add.w       #160,a0      
;7
        bchg.b      d0,(a0)      
        add.w       a1,a0        
        add.w       a2,d1        
        bcc.s       *+6          
        add.w       #160,a0      
;8
        eor.b       d0,(a0)+     
        add.w       a1,a0        
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;9
        eor.b       d6,(a0)      
        add.w       a1,a0        
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;10
        eor.b       d7,(a0)      
        add.w       a1,a0        
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;11
        eor.b       d4,(a0)      
        add.w       a1,a0        
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;12
        bchg.b      d2,(a0)      
        add.w       a1,a0        
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;13
        eor.b       d5,(a0)      
        add.w       a1,a0        
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;14
        eor.b       d2,(a0)      
        add.w       a1,a0        
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;15
        bchg.b      d0,(a0)      
        add.w       a1,a0        
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;16
        eor.b       d0,(a0)      
        add.w       #7,a0        
        add.w       a1,a0        
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
    ENDR



no_add_y_pos
    move.w  (a6),a2     ;8
    ; dx > dy

    doLeftRightClipping 0,1

    cmp.w   #$6000,a2
    bls     no_add_y_opt_pos

    lea     eor_mask_and_offset_no_add(PC),a6       ;8
    move.l  (a6,d0.w),d3        ; eor/offset 16.16  ;20 

    add.w   (a3,d1.w),d3                            ;16
    add.w   d3,a0               ; screen+off        ;8
    
    swap    d3              ; swap to mask          ;4

    and.w   #$3c,d0
    add.w   d0,d2
    lea     targettable_noadd_pos(PC),a6        ;8
    move.l  (a6,d2.w),a4                        ;20
    move.l  (a4),a6
    move.w  #$4E75,(a4) 

    moveq   #0,d1                                   ;4
    moveq   #%1,d0                  ; 1 eor = 01, 2 bchg    = 10
    moveq   #%100,d2                ; 3 eor = 100, 5 bcgh = 100000

    jmp     lines_no_add_pos(pc,d3.w)           ;16

lines_no_add_pos
;1
    REPT 7
        eor.b       d6,(a0)      
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;2
        eor.b       d7,(a0)      
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;3
        eor.b       d4,(a0)      
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;4
        bchg        d2,(a0)      
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;5
        eor.b       d5,(a0)      
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;6
        eor.b       d2,(a0)      
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;7      
        bchg        d0,(a0)      
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;8
        eor.b       d0,(a0)+     
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;9
        eor.b       d6,(a0)      
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;10
        eor.b       d7,(a0)      
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;11
        eor.b       d4,(a0)      
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;12
        bchg        d2,(a0)      
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;13
        eor.b       d5,(a0)      
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;14
        eor.b       d2,(a0)      
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;15
        bchg        d0,(a0)      
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
;16
        eor.b       d0,(a0)      
        add.w       #7,a0        
        add.w       a2,d1        
        bcc         *+6          
        add.w       #160,a0      
    ENDR

eor_mask_and_offset_no_add
val     set 0
val2    set 0
    REPT 20
        REPT 8
            dc.w    val,val2
val         set val+firsthalf2
        ENDR
val2        set val2+1
        REPT 7
            dc.w    val,val2
val         set val+secondhalf2
        ENDR
        dc.w    val,val2
val         set 0
val2        set val2+7
    ENDR


firsthalf2  equ 10
secondhalf2 equ 10
last2       equ 12
targettable_noadd_neg
val     set lines_no_add_neg
    REPT 20
        REPT 8
            dc.l    val
val         set val+firsthalf2
        ENDR
        REPT 7
            dc.l    val
val         set val+secondhalf2
        ENDR
        dc.l    val
val         set val+last2
    ENDR

targettable_noadd_pos
val     set lines_no_add_pos
    REPT 20
        REPT 8
            dc.l    val
val         set val+firsthalf2
        ENDR
        REPT 7
            dc.l    val
val         set val+secondhalf2
        ENDR
        dc.l    val
val         set val+last2
    ENDR


no_add_y_negative

    move.w  (a6),a2     ;8

    doLeftRightClipping 0,0

    cmp.w   #$6000,a2       ; dx > dy
    bls     no_add_y_opt_neg

    lea     eor_mask_and_offset_no_add(PC),a4       ;8
    move.l  (a4,d0.w),d3        ; eor/offset 16.16  ;20 
    add.w   (a3,d1.w),d3                            ;16
    add.w   d3,a0               ; screen+off        ;8
    
    swap    d3              ; swap to mask          ;4

    and.w   #$3c,d0
    add.w   d0,d2

    lea     targettable_noadd_neg(PC),a6        ;8
    move.l  (a6,d2.w),a4                    ;16
    move.l  (a4),a6
    move.w  #$4E75,(a4) 

    moveq   #0,d1                                   ;4
    moveq   #%1,d0                  ; 1 eor = 01, 2 bchg    = 10
    moveq   #%100,d2                ; 3 eor = 100, 5 bcgh = 100000

    jmp     lines_no_add_neg(PC,d3.w)

lines_no_add_neg    
;1
    REPT 7
        eor.b       d6,(a0) 
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;2
        eor.b       d7,(a0) 
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;3
        eor.b       d4,(a0) 
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;4
        bchg        d2,(a0) 
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;5
        eor.b       d5,(a0) 
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;6
        eor.b       d2,(a0) 
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;7      
        bchg        d0,(a0) 
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;8
        eor.b       d0,(a0)+
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;9
        eor.b       d6,(a0) 
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;10
        eor.b       d7,(a0) 
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;11
        eor.b       d4,(a0) 
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;12
        bchg        d2,(a0) 
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;13
        eor.b       d5,(a0) 
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;14
        eor.b       d2,(a0) 
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;15
        bchg        d0,(a0) 
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;16
        eor.b       d0,(a0) 
        add.w       #7,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
    ENDR


eor_mask_and_offset_no_add_opt
val     set 0
val2    set 0
    REPT 20
        REPT 8
            dc.w    val,val2
val         set val+firsthalf3
        ENDR
val2        set val2+1
        REPT 7
            dc.w    val,val2
val         set val+secondhalf3
        ENDR
        dc.w    val,val2
val         set 0
val2        set val2+7
    ENDR


firsthalf3  equ 14
secondhalf3 equ 14
last3       equ 16
targettable_noadd_opt_pos
val     set lines_no_add_opt_pos
    REPT 20
        REPT 7
            dc.l    val                         ;7
val         set val+firsthalf3
        ENDR
            dc.l    val                         ;8
val         set val+firsthalf3
        REPT 7
            dc.l    val                         ;15
val         set val+secondhalf3
        ENDR
        dc.l    val                             ;16
val         set val+last3
    ENDR

targettable_noadd_opt_neg
val     set lines_no_add_opt_neg
    REPT 20
        REPT 7
            dc.l    val                         ;7
val         set val+firsthalf3
        ENDR
            dc.l    val                         ;8
val         set val+firsthalf3
        REPT 7
            dc.l    val                         ;15
val         set val+secondhalf3
        ENDR
        dc.l    val                             ;16
val         set val+last3
    ENDR

no_add_y_opt_pos
    lea     eor_mask_and_offset_no_add_opt(PC),a6       ;8

    move.l  (a6,d0.w),d3        ; eor/offset 16.16  ;20 
    add.w   (a3,d1.w),d3                            ;16
    add.w   d3,a0               ; screen+off        ;8  
    swap    d3              ; swap to mask          ;4

    and.w   #$3c,d0
    add.w   d0,d2

    lea     targettable_noadd_opt_pos(PC),a6            ;8
    move.l  (a6,d2.w),a4                    ;16
    move.l  (a4),a6
    move.l  #$B1184E75,(a4)

    lea     lines_no_add_opt_pos(PC,d3.w),a1

    moveq   #0,d1                                   ;4
    moveq   #%1,d3                  ; 1 eor = 01, 2 bchg    = 10
    moveq   #%100,d2                ; 3 eor = 100, 5 bcgh = 100000
    moveq   #0,d0

    jmp     (a1)

lines_no_add_opt_pos    
;1
    REPT 7
        eor.b       d6,d0
        add.w       a2,d1
        bcc         *+10
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #160,a0
;2
        eor.b       d7,d0
        add.w       a2,d1
        bcc         *+10
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #160,a0
;3
        eor.b       d4,d0
        add.w       a2,d1
        bcc         *+10
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #160,a0
;4
        bchg        d2,d0
        add.w       a2,d1
        bcc         *+10
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #160,a0
;5
        eor.b       d5,d0
        add.w       a2,d1
        bcc         *+10
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #160,a0
;6
        eor.b       d2,d0
        add.w       a2,d1
        bcc         *+10
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #160,a0
;7      
        bchg        d3,d0
        add.w       a2,d1
        bcc         *+10
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #160,a0
;8
        eor.b       d3,d0
        eor.b       d0,(a0)+
        moveq       #0,d0
        add.w       a2,d1
        bcc         *+6 
        add.w       #160,a0
;9
        eor.b       d6,d0
        add.w       a2,d1
        bcc         *+10
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #160,a0
;10
        eor.b       d7,d0
        add.w       a2,d1
        bcc         *+10
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #160,a0
;11
        eor.b       d4,d0
        add.w       a2,d1
        bcc         *+10
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #160,a0
;12
        bchg        d2,d0
        add.w       a2,d1
        bcc         *+10
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #160,a0
;13
        eor.b       d5,d0
        add.w       a2,d1
        bcc         *+10
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #160,a0
;14
        eor.b       d2,d0
        add.w       a2,d1
        bcc         *+10
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #160,a0
;15
        bchg        d3,d0
        add.w       a2,d1
        bcc         *+10
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #160,a0
;16
        eor.b       d3,d0
        eor.b       d0,(a0)
        add.w       #7,a0
        moveq       #0,d0
        add.w       a2,d1
        bcc         *+6 
        add.w       #160,a0
    ENDR


no_add_y_opt_neg
    lea     eor_mask_and_offset_no_add_opt(PC),a6       ;8

    move.l  (a6,d0.w),d3        ; eor/offset 16.16  ;20 
    add.w   (a3,d1.w),d3                            ;16
    add.w   d3,a0               ; screen+off        ;8
    
    swap    d3              ; swap to mask          ;4

    and.w   #$3c,d0
    add.w   d0,d2

    lea     targettable_noadd_opt_neg(PC),a6            ;8
    move.l  (a6,d2.w),a4                    ;16
    move.l  (a4),a6
    move.l  #$B1184E75,(a4)

    lea     lines_no_add_opt_neg(PC,d3.w),a1

    moveq   #0,d1                                   ;4
    moveq   #%1,d3                  ; 1 eor = 01, 2 bchg    = 10
    moveq   #%100,d2                ; 3 eor = 100, 5 bcgh = 100000
    moveq   #0,d0

    jmp     (a1)

lines_no_add_opt_neg    
;1
    REPT 7
        eor.b       d6,d0       
        add.w       a2,d1       
        bcc         *+10        
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #-160,a0    
;2
        eor.b       d7,d0       
        add.w       a2,d1       
        bcc         *+10        
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #-160,a0    
;3
        eor.b       d4,d0       
        add.w       a2,d1       
        bcc         *+10        
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #-160,a0    
;4
        bchg        d2,d0       
        add.w       a2,d1       
        bcc         *+10        
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #-160,a0    
;5
        eor.b       d5,d0       
        add.w       a2,d1       
        bcc         *+10        
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #-160,a0    
;6
        eor.b       d2,d0       
        add.w       a2,d1       
        bcc         *+10        
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #-160,a0    
;7      
        bchg        d3,d0       
        add.w       a2,d1       
        bcc         *+10        
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #-160,a0    
;8
        eor.b       d3,d0       
        eor.b       d0,(a0)+
        moveq       #0,d0
        add.w       a2,d1       
        bcc         *+6         
        add.w       #-160,a0    
;9
        eor.b       d6,d0       
        add.w       a2,d1       
        bcc         *+10        
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #-160,a0    
;10
        eor.b       d7,d0       
        add.w       a2,d1       
        bcc         *+10        
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #-160,a0    
;11
        eor.b       d4,d0       
        add.w       a2,d1       
        bcc         *+10        
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #-160,a0    
;12
        bchg        d2,d0       
        add.w       a2,d1       
        bcc         *+10        
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #-160,a0    
;13
        eor.b       d5,d0       
        add.w       a2,d1       
        bcc         *+10        
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #-160,a0    
;14
        eor.b       d2,d0       
        add.w       a2,d1       
        bcc         *+10        
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #-160,a0    
;15
        bchg        d3,d0       
        add.w       a2,d1       
        bcc         *+10        
        eor.b       d0,(a0)
        moveq       #0,d0
        add.w       #-160,a0    
;16
        eor.b       d3,d0       
        eor.b       d0,(a0)
        add.w       #7,a0
        moveq       #0,d0
        add.w       a2,d1       
        bcc         *+6         
        add.w       #-160,a0    
    ENDR
;;;;;;;;;;;;; end normal lines

;;;;;;;;;;;;; start two lines



eor_mask_and_offset_2lines
val     set 0
val2    set 0
    REPT 20
        REPT 8
            dc.w    val,val2
val         set val+firsthalf_2lines
        ENDR
val2        set val2+1
        REPT 7
            dc.w    val,val2
val         set val+secondhalf_2lines
        ENDR
        dc.w    val,val2
val         set 0
val2        set val2+7
    ENDR


firsthalf_2lines    equ 16
secondhalf_2lines   equ 16
last_2lines         equ 18
y_positive_target_abs_2lines
val     set lines_with_add_2lines
    REPT 20
        REPT 8
            dc.l    val
val         set val+firsthalf_2lines
        ENDR
        REPT 7
            dc.l    val
val         set val+secondhalf_2lines
        ENDR
        dc.l    val
val         set val+last_2lines
    ENDR

y_negative_target_abs_2lines
val     set lines_with_add_neg_2lines
    REPT 20
        REPT 8
            dc.l    val
val         set val+firsthalf_2lines
        ENDR
        REPT 7
            dc.l    val
val         set val+secondhalf_2lines
        ENDR
        dc.l    val
val         set val+last_2lines
    ENDR



; uses d0,d1,d2,d3,d4,
drawLine2
    cmp.w   d0,d2               ; is d2 > d0 ?      ;4
    bge     .noswap                                 ;12
    exg     d0,d2                                   ;8
    exg     d1,d3                                   ;8
.noswap
    sub.w   d0,d2               ; d2 is count (dx)  ;4
;   IFNE    hline_and_vline
;       beq     .vline
;   ENDC
    sub.w   d1,d3               ; d3 is dy          ;4
;   IFNE    hline_and_vline
;       beq     .hline
;   ENDC
    bge     y_positive_2lines                           ;8

y_negative_2lines
    neg     d3                                      ;4  
    asl.l   #7,d3                                   ;22
    or.w    d2,d3                                   ;8

    move.l  usp,a6                                  ;4
    add.l   d3,a6                                   ;8
    move.w  (a6)+,d3                                ;8
    beq     no_add_y_negative_2lines

    neg     d3                                      ;4

    move.w  (a6),a2                                 ;8
    move.w  d3,a1                                   ;8

    doLeftRightClipping 1,0 ; add,negative

    lea     eor_mask_and_offset_2lines(PC),a4       ;8      
    move.l  (a4,d0.w),d3        ; eor/offset 16.16  ;20     
    add.w   (a3,d1.w),d3                            ;16     
    add.w   d3,a0               ; screen+off        ;8      
    swap    d3              ; swap to mask          ;4          -->48

    and.w   #$3c,d0
    add.w   d0,d2

    lea     y_negative_target_abs_2lines(PC),a6         
    move.l  (a6,d2.w),a4
    move.l  (a4),a6
    move.l  4(a4),-4(a3)
;   move.l  4(a4),savedSecond
    move.w  #$4E75,(a4) 

    moveq   #0,d1                                   ;4      
    moveq   #%1,d0                              ;4      ; 1 eor = 01, 2 bchg = 10
    moveq   #%100,d2                            ;4      ; 3 eor = 100, 5 bcgh = 10000

    jmp     lines_with_add_neg_2lines(PC,d3.w)              ;16

    ; store: 
    ;   - address to jump to ds.l                       ;12         --> removed: 20+24
    ;   - fraction                                      ;8
    ;   - address to write rts to,  dus move.l ()       ;12 --> 32*3 = 96

lines_with_add_neg_2lines   
;1
    REPT 7
        eor.b       d6,(a0) 
        eor.b       d6,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc.s       *+6     
        add.w       #-160,a0
;2
        eor.b       d7,(a0) 
        eor.b       d7,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc.s       *+6     
        add.w       #-160,a0
;3
        eor.b       d4,(a0) 
        eor.b       d4,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc.s       *+6     
        add.w       #-160,a0
;4
        bchg.b      d2,(a0) 
        bchg.b      d2,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc.s       *+6     
        add.w       #-160,a0
;5
        eor.b       d5,(a0) 
        eor.b       d5,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc.s       *+6     
        add.w       #-160,a0
;6
        eor.b       d2,(a0) 
        eor.b       d2,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc.s       *+6     
        add.w       #-160,a0
;7
        bchg.b      d0,(a0) 
        bchg.b      d0,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc.s       *+6     
        add.w       #-160,a0
;8
        eor.b       d0,(a0)+
        eor.b       d0,1(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;9
        eor.b       d6,(a0) 
        eor.b       d6,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;10
        eor.b       d7,(a0) 
        eor.b       d7,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;11
        eor.b       d4,(a0) 
        eor.b       d4,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;12
        bchg.b      d2,(a0) 
        bchg.b      d2,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;13
        eor.b       d5,(a0) 
        eor.b       d5,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;14
        eor.b       d2,(a0) 
        eor.b       d2,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;15
        bchg.b      d0,(a0) 
        bchg.b      d0,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;16
        eor.b       d0,(a0) 
        eor.b       d0,2(a0)
        add.w       #7,a0   
        add.w       a1,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
    ENDR

y_positive_2lines
    asl.l   #7,d3                                   
    or.w    d2,d3

    move.l  usp,a6

    add.l   d3,a6       ;8
    move.w  (a6)+,d3    ;8

    beq     no_add_y_pos_2lines

    move.w  (a6),a2     ;8
    move.w  d3,a1                               ;8

    doLeftRightClipping 1,1 ;add, positive

    lea     eor_mask_and_offset_2lines(PC),a4               ;8      
    move.l  (a4,d0.w),d3        ; eor/offset 16.16  ;20     
    add.w   (a3,d1.w),d3                            ;16     
    add.w   d3,a0               ; screen+off        ;8      
    swap    d3              ; swap to mask          ;4          -->48

    and.w   #$3c,d0
    add.w   d0,d2

    lea     y_positive_target_abs_2lines(PC),a6                 ;8
    move.l  (a6,d2.w),a4
    move.l  (a4),a6         ; a6 is opcode          ;12
;   move.l  4(a4),savedSecond                       ;32
    move.l  4(a4),-4(a3)                            ;28
    move.w  #$4E75,(a4) 


    moveq   #0,d1                                   ;4      
    moveq   #%1,d0                                  ;4      ; 1 eor = 01, 2 bchg = 10
    moveq   #%100,d2                                ;4      ; 3 eor = 100, 5 bcgh = 10000

    jmp     lines_with_add_2lines(PC,d3.w)              ;16

lines_with_add_2lines   
;1
    REPT 7
        eor.b       d6,(a0) 
        eor.b       d6,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc.s       *+6     
        add.w       #160,a0 
;2
        eor.b       d7,(a0) 
        eor.b       d7,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc.s       *+6     
        add.w       #160,a0 
;3
        eor.b       d4,(a0) 
        eor.b       d4,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc.s       *+6     
        add.w       #160,a0 
;4
        bchg.b      d2,(a0) 
        bchg.b      d2,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc.s       *+6     
        add.w       #160,a0 
;5
        eor.b       d5,(a0) 
        eor.b       d5,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc.s       *+6     
        add.w       #160,a0 
;6
        eor.b       d2,(a0) 
        eor.b       d2,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc.s       *+6     
        add.w       #160,a0 
;7
        bchg.b      d0,(a0) 
        bchg.b      d0,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc.s       *+6     
        add.w       #160,a0 
;8
        eor.b       d0,(a0)+
        eor.b       d0,1(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;9
        eor.b       d6,(a0) 
        eor.b       d6,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;10
        eor.b       d7,(a0) 
        eor.b       d7,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;11
        eor.b       d4,(a0) 
        eor.b       d4,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;12
        bchg.b      d2,(a0) 
        bchg.b      d2,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;13
        eor.b       d5,(a0) 
        eor.b       d5,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;14
        eor.b       d2,(a0) 
        eor.b       d2,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;15
        bchg.b      d0,(a0) 
        bchg.b      d0,2(a0)
        add.w       a1,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;16
        eor.b       d0,(a0) 
        eor.b       d0,2(a0)
        add.w       #7,a0   
        add.w       a1,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
    ENDR



no_add_y_pos_2lines
    move.w  (a6),a2     ;8

    doLeftRightClipping 0,1 ;no add, positive
    ; dx > dy
    cmp.w   #$6000,a2
    bls     no_add_y_opt_pos_2lines

    lea     eor_mask_and_offset_no_add_2lines(PC),a6        ;8
    move.l  (a6,d0.w),d3        ; eor/offset 16.16  ;20 
    add.w   (a3,d1.w),d3                            ;16
    add.w   d3,a0               ; screen+off        ;8
    
    swap    d3              ; swap to mask          ;4

    and.w   #$3c,d0
    add.w   d0,d2
    lea     targettable_noadd_pos_2lines(PC),a6     ;8
    move.l  (a6,d2.w),a4                        ;20
    move.l  (a4),a6
    move.l  4(a4),-4(a3)
    move.w  #$4E75,(a4) 

    moveq   #0,d1                                   ;4
    moveq   #%1,d0                  ; 1 eor = 01, 2 bchg    = 10
    moveq   #%100,d2                ; 3 eor = 100, 5 bcgh = 100000

    jmp     lines_no_add_pos_2lines(pc,d3.w)            ;16

lines_no_add_pos_2lines
;1
    REPT 7
        eor.b       d6,(a0) 
        eor.b       d6,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;2
        eor.b       d7,(a0) 
        eor.b       d7,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;3
        eor.b       d4,(a0) 
        eor.b       d4,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;4
        bchg        d2,(a0) 
        bchg        d2,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;5
        eor.b       d5,(a0) 
        eor.b       d5,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;6
        eor.b       d2,(a0) 
        eor.b       d2,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;7      
        bchg        d0,(a0) 
        bchg        d0,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;8
        eor.b       d0,(a0)+
        eor.b       d0,1(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;9
        eor.b       d6,(a0) 
        eor.b       d6,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;10
        eor.b       d7,(a0) 
        eor.b       d7,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;11
        eor.b       d4,(a0) 
        eor.b       d4,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;12
        bchg        d2,(a0) 
        bchg        d2,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;13
        eor.b       d5,(a0) 
        eor.b       d5,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;14
        eor.b       d2,(a0) 
        eor.b       d2,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;15
        bchg        d0,(a0) 
        bchg        d0,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;16
        eor.b       d0,(a0) 
        eor.b       d0,2(a0)
        add.w       #7,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
    ENDR

eor_mask_and_offset_no_add_2lines
val     set 0
val2    set 0
    REPT 20
        REPT 8
            dc.w    val,val2
val         set val+firsthalf2_2lines
        ENDR
val2        set val2+1
        REPT 7
            dc.w    val,val2
val         set val+secondhalf2_2lines
        ENDR
        dc.w    val,val2
val         set 0
val2        set val2+7
    ENDR


firsthalf2_2lines   equ 14
secondhalf2_2lines  equ 14
last2_2lines        equ 16
targettable_noadd_neg_2lines
val     set lines_no_add_neg_2lines
    REPT 20
        REPT 8
            dc.l    val
val         set val+firsthalf2_2lines
        ENDR
        REPT 7
            dc.l    val
val         set val+secondhalf2_2lines
        ENDR
        dc.l    val
val         set val+last2_2lines
    ENDR

targettable_noadd_pos_2lines
val     set lines_no_add_pos_2lines
    REPT 20
        REPT 8
            dc.l    val
val         set val+firsthalf2_2lines
        ENDR
        REPT 7
            dc.l    val
val         set val+secondhalf2_2lines
        ENDR
        dc.l    val
val         set val+last2_2lines
    ENDR


no_add_y_negative_2lines
    move.w  (a6),a2     ;8

    doLeftRightClipping 0,0 ;no add, negative

    cmp.w   #$6000,a2       ; dx > dy
    bls     no_add_y_opt_neg_2lines

    lea     eor_mask_and_offset_no_add_2lines(PC),a4        ;8
    move.l  (a4,d0.w),d3        ; eor/offset 16.16  ;20 

    add.w   (a3,d1.w),d3                            ;16
    add.w   d3,a0               ; screen+off        ;8
    
    swap    d3              ; swap to mask          ;4

    and.w   #$3c,d0
    add.w   d0,d2

    lea     targettable_noadd_neg_2lines(PC),a6     ;8
    move.l  (a6,d2.w),a4                    ;16
    move.l  (a4),a6
    move.l  4(a4),-4(a3)
    move.w  #$4E75,(a4) 

    moveq   #0,d1                                   ;4
    moveq   #%1,d0                  ; 1 eor = 01, 2 bchg    = 10
    moveq   #%100,d2                ; 3 eor = 100, 5 bcgh = 100000

    jmp     lines_no_add_neg_2lines(PC,d3.w)

lines_no_add_neg_2lines 
;1
    REPT 7
        eor.b       d6,(a0) 
        eor.b       d6,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;2
        eor.b       d7,(a0) 
        eor.b       d7,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;3
        eor.b       d4,(a0) 
        eor.b       d4,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;4
        bchg        d2,(a0) 
        bchg        d2,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;5
        eor.b       d5,(a0) 
        eor.b       d5,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;6
        eor.b       d2,(a0) 
        eor.b       d2,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;7      
        bchg        d0,(a0) 
        bchg        d0,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;8
        eor.b       d0,(a0)+
        eor.b       d0,1(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;9
        eor.b       d6,(a0) 
        eor.b       d6,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;10
        eor.b       d7,(a0) 
        eor.b       d7,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;11
        eor.b       d4,(a0) 
        eor.b       d4,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;12
        bchg        d2,(a0) 
        bchg        d2,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;13
        eor.b       d5,(a0) 
        eor.b       d5,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;14
        eor.b       d2,(a0) 
        eor.b       d2,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;15
        bchg        d0,(a0) 
        bchg        d0,2(a0)
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;16
        eor.b       d0,(a0) 
        eor.b       d0,2(a0)
        add.w       #7,a0   
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
    ENDR

eor_mask_and_offset_no_add_opt_2lines
val     set 0
val2    set 0
    REPT 20
        REPT 8
            dc.w    val,val2
val         set val+firsthalf3_2lines
        ENDR
val2        set val2+1
        REPT 7
            dc.w    val,val2
val         set val+secondhalf3_2lines
        ENDR
        dc.w    val,val2
val         set 0
val2        set val2+7
    ENDR

firsthalf3_2lines   equ 18
secondhalf3_2lines  equ 18
last3_2lines        equ 20
targettable_noadd_opt_pos_2lines
val     set lines_no_add_opt_pos_2lines
    REPT 20
        REPT 7
            dc.l    val                         ;7
val         set val+firsthalf3_2lines
        ENDR
            dc.l    val                         ;8
val         set val+firsthalf3_2lines
        REPT 7
            dc.l    val                         ;15
val         set val+secondhalf3_2lines
        ENDR
        dc.l    val                             ;16
val         set val+last3_2lines
    ENDR

targettable_noadd_opt_neg_2lines
val     set lines_no_add_opt_neg_2lines
    REPT 20
        REPT 7
            dc.l    val                         ;7
val         set val+firsthalf3_2lines
        ENDR
            dc.l    val                         ;8
val         set val+firsthalf3_2lines
        REPT 7
            dc.l    val                         ;15
val         set val+secondhalf3_2lines
        ENDR
        dc.l    val                             ;16
val         set val+last3_2lines
    ENDR


no_add_y_opt_pos_2lines

    lea     eor_mask_and_offset_no_add_opt_2lines(PC),a6        ;8
    move.l  (a6,d0.w),d3        ; eor/offset 16.16  ;20 

    add.w   (a3,d1.w),d3                            ;16
    add.w   d3,a0               ; screen+off        ;8  
    swap    d3              ; swap to mask          ;4

    and.w   #$3c,d0
    add.w   d0,d2

    lea     targettable_noadd_opt_pos_2lines(PC),a6         ;8
    move.l  (a6,d2.w),a4                    ;16
    move.l  (a4)+,a6
    move.l  (a4),-4(a3)
    move.l  #$B1184E75,(a4)
    move.l  #$B1280002,-(a4)

    lea     lines_no_add_opt_pos_2lines(PC,d3.w),a1

    moveq   #0,d1                                   ;4
    moveq   #%1,d3                  ; 1 eor = 01, 2 bchg    = 10
    moveq   #%100,d2                ; 3 eor = 100, 5 bcgh = 100000
    moveq   #0,d0

    jmp     (a1)


lines_no_add_opt_pos_2lines 
;1
    REPT 7
        eor.b       d6,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0) 
        eor.b       d0,2(a0)
        moveq       #0,d0   
        add.w       #160,a0 
;2
        eor.b       d7,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0) 
        eor.b       d0,2(a0)
        moveq       #0,d0   
        add.w       #160,a0 
;3
        eor.b       d4,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0) 
        eor.b       d0,2(a0)
        moveq       #0,d0   
        add.w       #160,a0 
;4
        bchg        d2,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #160,a0 
;5
        eor.b       d5,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #160,a0 
;6
        eor.b       d2,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #160,a0 
;7      
        bchg        d3,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #160,a0 
;8
        eor.b       d3,d0   
        eor.b       d0,(a0)+
        eor.b       d0,1(a0)
        moveq       #0,d0
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
;9
        eor.b       d6,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #160,a0 
;10
        eor.b       d7,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #160,a0 
;11
        eor.b       d4,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #160,a0 
;12
        bchg        d2,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #160,a0 
;13
        eor.b       d5,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #160,a0 
;14
        eor.b       d2,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #160,a0 
;15
        bchg        d3,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #160,a0 
;16
        eor.b       d3,d0   
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        add.w       #7,a0
        moveq       #0,d0
        add.w       a2,d1   
        bcc         *+6     
        add.w       #160,a0 
    ENDR


no_add_y_opt_neg_2lines
    lea     eor_mask_and_offset_no_add_opt_2lines(PC),a6        ;8

    move.l  (a6,d0.w),d3        ; eor/offset 16.16  ;20 
    add.w   (a3,d1.w),d3                            ;16
    add.w   d3,a0               ; screen+off        ;8
    
    swap    d3              ; swap to mask          ;4

    and.w   #$3c,d0
    add.w   d0,d2
    lea     targettable_noadd_opt_neg_2lines(PC),a6         ;8
    move.l  (a6,d2.w),a4                    ;16
    move.l  (a4)+,a6
    move.l  (a4),-4(a3)
    move.l  #$B1184E75,(a4)
    move.l  #$B1280002,-(a4)

    lea     lines_no_add_opt_neg_2lines(PC,d3.w),a1

    moveq   #0,d1                                   ;4
    moveq   #%1,d3                  ; 1 eor = 01, 2 bchg    = 10
    moveq   #%100,d2                ; 3 eor = 100, 5 bcgh = 100000
    moveq   #0,d0

    jmp     (a1)

lines_no_add_opt_neg_2lines 
;1
    REPT 7
        eor.b       d6,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #-160,a0
;2
        eor.b       d7,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #-160,a0
;3
        eor.b       d4,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #-160,a0
;4
        bchg        d2,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #-160,a0
;5
        eor.b       d5,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #-160,a0
;6
        eor.b       d2,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #-160,a0
;7      
        bchg        d3,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #-160,a0
;8
        eor.b       d3,d0   
        eor.b       d0,(a0)+
        eor.b       d0,1(a0)
        moveq       #0,d0
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
;9
        eor.b       d6,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #-160,a0
;10
        eor.b       d7,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #-160,a0
;11
        eor.b       d4,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #-160,a0
;12
        bchg        d2,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #-160,a0
;13
        eor.b       d5,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #-160,a0
;14
        eor.b       d2,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #-160,a0
;15
        bchg        d3,d0   
        add.w       a2,d1   
        bcc         *+14    
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        moveq       #0,d0
        add.w       #-160,a0
;16
        eor.b       d3,d0   
        eor.b       d0,(a0)
        eor.b       d0,2(a0)
        add.w       #7,a0
        moveq       #0,d0
        add.w       a2,d1   
        bcc         *+6     
        add.w       #-160,a0
    ENDR

emptyaddr
    ds.l    1

x               equ 8
y               equ 160

;~1350, clear and eor
; eor = 36
; clear = 12    --> 1350 * 48   64800




xx00_0  equ 0
xy00_0  equ 0

xx00_1  equ 1*x+36*y
xy00_1  equ 86
xx00_2  equ 2*x+18*y
xy00_2  equ 118
xx00_3  equ 3*x+8*y
xy00_3  equ 146
xx00_4  equ 4*x+0*y
xy00_4  equ 156
xx00_5  equ 5*x+0*y
xy00_5  equ 156
xx00_6  equ 6*x+0*y
xy00_6  equ 156
xx00_7  equ 7*x+0*y
xy00_7  equ 156
xx00_8  equ 8*x+5*y
xy00_8  equ 148
xx00_9  equ 9*x+18*y
xy00_9  equ 119
xx00_10 equ 10*x+34*y
xy00_10 equ 88
; size: 1156 + 154
xx00_11 equ 0
xy00_11 equ 0


xx01_0 equ 0
xy01_0 equ 0
xx01_1 equ 1*x+37*y
xy01_1 equ 80
xx01_2 equ 2*x+18*y
xy01_2 equ 118
xx01_3 equ 3*x+7*y
xy01_3 equ 140
xx01_4 equ 4*x+2*y
xy01_4 equ 150
xx01_5 equ 5*x+0*y
xy01_5 equ 155
xx01_6 equ 6*x+0*y
xy01_6 equ 155
xx01_7 equ 7*x+1*y
xy01_7 equ 152
xx01_8 equ 8*x+6*y
xy01_8 equ 142
xx01_9 equ 9*x+15*y
xy01_9 equ 124
xx01_10 equ 10*x+31*y
xy01_10 equ 92
; size: 1152 + 154
xx01_11 equ 0
xy01_11 equ 0

xx02_0 equ 0
xy02_0 equ 0
xx02_1 equ 1*x+39*y
xy02_1 equ 76
xx02_2 equ 2*x+19*y
xy02_2 equ 116
xx02_3 equ 3*x+8*y
xy02_3 equ 138
xx02_4 equ 4*x+2*y
xy02_4 equ 150
xx02_5 equ 5*x+0*y
xy02_5 equ 155
xx02_6 equ 6*x+0*y
xy02_6 equ 155
xx02_7 equ 7*x+1*y
xy02_7 equ 152
xx02_8 equ 8*x+5*y
xy02_8 equ 144
xx02_9 equ 9*x+14*y
xy02_9 equ 126
xx02_10 equ 10*x+30*y
xy02_10 equ 94
xx02_11 equ 11*x+76*y
xy02_11 equ 2
; size: 1152 + 154

xx03_0 equ 0
xy03_0 equ 0

xx03_1 equ 1*x+40*y
xy03_1 equ 74
xx03_2 equ 2*x+20*y
xy03_2 equ 114
xx03_3 equ 3*x+8*y
xy03_3 equ 138
xx03_4 equ 4*x+2*y
xy03_4 equ 150
xx03_5 equ 5*x+0*y
xy03_5 equ 155
xx03_6 equ 6*x+0*y
xy03_6 equ 155
xx03_7 equ 7*x+0*y
xy03_7 equ 155
xx03_8 equ 8*x+5*y
xy03_8 equ 144
xx03_9 equ 9*x+13*y
xy03_9 equ 128
xx03_10 equ 10*x+28*y
xy03_10 equ 98
xx03_11 equ 11*x+64*y
xy03_11 equ 26
; size: 1180 + 154

xx04_0 equ 0
xy04_0 equ 0
xx04_1 equ 1*x+42*y
xy04_1 equ 70
xx04_2 equ 2*x+21*y
xy04_2 equ 112
xx04_3 equ 3*x+9*y
xy04_3 equ 136
xx04_4 equ 4*x+2*y
xy04_4 equ 150
xx04_5 equ 5*x+0*y
xy04_5 equ 155
xx04_6 equ 6*x+0*y
xy04_6 equ 155
xx04_7 equ 7*x+0*y
xy04_7 equ 155
xx04_8 equ 8*x+4*y
xy04_8 equ 146
xx04_9 equ 9*x+13*y
xy04_9 equ 128
xx04_10 equ 10*x+27*y
xy04_10 equ 100
xx04_11 equ 11*x+59*y
xy04_11 equ 36
; size: 1186 + 154

xx05_1 equ 1*x+44*y
xy05_1 equ 66
xx05_2 equ 2*x+22*y
xy05_2 equ 110
xx05_3 equ 3*x+10*y
xy05_3 equ 134
xx05_4 equ 4*x+3*y
xy05_4 equ 148
xx05_5 equ 5*x+0*y
xy05_5 equ 155
xx05_6 equ 6*x+0*y
xy05_6 equ 155
xx05_7 equ 7*x+0*y
xy05_7 equ 155
xx05_8 equ 8*x+4*y
xy05_8 equ 146
xx05_9 equ 9*x+12*y
xy05_9 equ 130
xx05_10 equ 10*x+26*y
xy05_10 equ 102
xx05_11 equ 11*x+55*y
xy05_11 equ 44
; size: 1188 + 154

xx06_1 equ 1*x+47*y
xy06_1 equ 60
xx06_2 equ 2*x+23*y
xy06_2 equ 108
xx06_3 equ 3*x+10*y
xy06_3 equ 134
xx06_4 equ 4*x+3*y
xy06_4 equ 148
xx06_5 equ 5*x+0*y
xy06_5 equ 155
xx06_6 equ 6*x+0*y
xy06_6 equ 155
xx06_7 equ 7*x+0*y
xy06_7 equ 155
xx06_8 equ 8*x+4*y
xy06_8 equ 146
xx06_9 equ 9*x+11*y
xy06_9 equ 132
xx06_10 equ 10*x+25*y
xy06_10 equ 104
xx06_11 equ 11*x+52*y
xy06_11 equ 50
; size: 1190 + 154



xx07_1 equ 1*x+49*y
xy07_1 equ 56
xx07_2 equ 2*x+24*y
xy07_2 equ 106
xx07_3 equ 3*x+11*y
xy07_3 equ 132
xx07_4 equ 4*x+3*y
xy07_4 equ 148
xx07_5 equ 5*x+0*y
xy07_5 equ 155
xx07_6 equ 6*x+0*y
xy07_6 equ 155
xx07_7 equ 7*x+0*y
xy07_7 equ 155
xx07_8 equ 8*x+3*y
xy07_8 equ 148
xx07_9 equ 9*x+11*y
xy07_9 equ 132
xx07_10 equ 10*x+24*y
xy07_10 equ 106
xx07_11 equ 11*x+49*y
xy07_11 equ 56
; size: 1192 + 154

; 1341
xx08_1 equ 1*x+52*y
xy08_1 equ 50
xx08_2 equ 2*x+25*y
xy08_2 equ 104
xx08_3 equ 3*x+11*y
xy08_3 equ 132
xx08_4 equ 4*x+4*y
xy08_4 equ 146
xx08_5 equ 5*x+0*y
xy08_5 equ 155
xx08_6 equ 6*x+0*y
xy08_6 equ 155
xx08_7 equ 7*x+0*y
xy08_7 equ 155
xx08_8 equ 8*x+3*y
xy08_8 equ 148
xx08_9 equ 9*x+10*y
xy08_9 equ 134
xx08_10 equ 10*x+23*y
xy08_10 equ 108
xx08_11 equ 11*x+47*y
xy08_11 equ 60
; size: 1190 + 154


xx09_1 equ 1*x+55*y
xy09_1 equ 44
xx09_2 equ 2*x+26*y
xy09_2 equ 102
xx09_3 equ 3*x+12*y
xy09_3 equ 130
xx09_4 equ 4*x+4*y
xy09_4 equ 146
xx09_5 equ 5*x+0*y
xy09_5 equ 155
xx09_6 equ 6*x+0*y
xy09_6 equ 155
xx09_7 equ 7*x+0*y
xy09_7 equ 155
xx09_8 equ 8*x+3*y
xy09_8 equ 148
xx09_9 equ 9*x+10*y
xy09_9 equ 134
xx09_10 equ 10*x+22*y
xy09_10 equ 110
xx09_11 equ 11*x+44*y
xy09_11 equ 66
; size: 1188 + 154

xx10_1 equ 1*x+59*y
xy10_1 equ 36
xx10_2 equ 2*x+27*y
xy10_2 equ 100
xx10_3 equ 3*x+13*y
xy10_3 equ 128
xx10_4 equ 4*x+4*y
xy10_4 equ 146
xx10_5 equ 5*x+0*y
xy10_5 equ 155
xx10_6 equ 6*x+0*y
xy10_6 equ 155
xx10_7 equ 7*x+0*y
xy10_7 equ 155
xx10_8 equ 8*x+2*y
xy10_8 equ 150
xx10_9 equ 9*x+9*y
xy10_9 equ 136
xx10_10 equ 10*x+21*y
xy10_10 equ 112
xx10_11 equ 11*x+42*y
xy10_11 equ 70
; size: 1186 + 154

xx11_1 equ 1*x+64*y
xy11_1 equ 26
xx11_2 equ 2*x+28*y
xy11_2 equ 98
xx11_3 equ 3*x+13*y
xy11_3 equ 128
xx11_4 equ 4*x+5*y
xy11_4 equ 144
xx11_5 equ 5*x+0*y
xy11_5 equ 155
xx11_6 equ 6*x+0*y
xy11_6 equ 155
xx11_7 equ 7*x+0*y
xy11_7 equ 155
xx11_8 equ 8*x+2*y
xy11_8 equ 150
xx11_9 equ 9*x+8*y
xy11_9 equ 138
xx11_10 equ 10*x+20*y
xy11_10 equ 114
xx11_11 equ 11*x+40*y
xy11_11 equ 74
; size: 1180 + 154



xx12_1 equ 1*x+77*y
xy12_1 equ 0
xx12_2 equ 2*x+30*y
xy12_2 equ 94
xx12_3 equ 3*x+14*y
xy12_3 equ 126
xx12_4 equ 4*x+5*y
xy12_4 equ 144
xx12_5 equ 5*x+1*y
xy12_5 equ 152
xx12_6 equ 6*x+0*y
xy12_6 equ 155
xx12_7 equ 7*x+0*y
xy12_7 equ 155
xx12_8 equ 8*x+2*y
xy12_8 equ 150
xx12_9 equ 9*x+8*y
xy12_9 equ 138
xx12_10 equ 10*x+19*y
xy12_10 equ 116
xx12_11 equ 11*x+39*y
xy12_11 equ 76
; size: 1150 + 154

xx13_1 equ 1*x+0*y
xy13_1 equ 0
xx13_2 equ 2*x+31*y
xy13_2 equ 92
xx13_3 equ 3*x+15*y
xy13_3 equ 124
xx13_4 equ 4*x+6*y
xy13_4 equ 142
xx13_5 equ 5*x+1*y
xy13_5 equ 152
xx13_6 equ 6*x+0*y
xy13_6 equ 155
xx13_7 equ 7*x+0*y
xy13_7 equ 155
xx13_8 equ 8*x+2*y
xy13_8 equ 150
xx13_9 equ 9*x+7*y
xy13_9 equ 140
xx13_10 equ 10*x+18*y
xy13_10 equ 118
xx13_11 equ 11*x+37*y
xy13_11 equ 80
; size: 1327

xx14_1 equ 1*x+0*y
xy14_1 equ 0
xx14_2 equ 2*x+32*y
xy14_2 equ 90
xx14_3 equ 3*x+16*y
xy14_3 equ 122
xx14_4 equ 4*x+6*y
xy14_4 equ 142
xx14_5 equ 5*x+1*y
xy14_5 equ 152
xx14_6 equ 6*x+0*y
xy14_6 equ 155
xx14_7 equ 7*x+0*y
xy14_7 equ 155
xx14_8 equ 8*x+1*y
xy14_8 equ 152
xx14_9 equ 9*x+7*y
xy14_9 equ 140
xx14_10 equ 10*x+17*y
xy14_10 equ 120
xx14_11 equ 11*x+35*y
xy14_11 equ 84
; size: NAN

xx15_1 equ 1*x+0*y
xy15_1 equ 0
xx15_2 equ 2*x+34*y
xy15_2 equ 86
xx15_3 equ 3*x+16*y
xy15_3 equ 122
xx15_4 equ 4*x+6*y
xy15_4 equ 142
xx15_5 equ 5*x+1*y
xy15_5 equ 152
xx15_6 equ 6*x+0*y
xy15_6 equ 155
xx15_7 equ 7*x+0*y
xy15_7 equ 155
xx15_8 equ 8*x+1*y
xy15_8 equ 152
xx15_9 equ 9*x+6*y
xy15_9 equ 142
xx15_10 equ 10*x+16*y
xy15_10 equ 122
xx15_11 equ 11*x+34*y
xy15_11 equ 86
; size: NAN

clearBlock  MACRO\1
    addq.w  #1,d2                   ; .w 5242                       ;2
    bne     .\@cont                 ; .w 6602 (+2)                  ;2
    rts                             ; .w 4E75                       ;2
.\@cont
d   SET     \2-8
    REPT    \3
        move.l  d0,d(a0)            ; .l 2140 0B48                  ; y * 4
d       SET     d+160
    ENDR
    ENDM                            ; .w 4E75                       ;2------> y*4 + 8

makeClearBlock macro
    lea     \1,a0       ; load destination memory
    move.l  #\2,d0  ; initial starting offset
    subq.w  #8,d0
    move.l  #\3-1,d7    ; loop counter

    move.w  #$5242,(a0)+    ;   addq.w #1,d2
    move.w  #$6602,(a0)+    ;   bne *+2
    move.w  #$4E75,(a0)+    ;   rts


    subq    #1,d7
    blt     .end\@

    move.l  #160,d6     ; offset
    ; actual generation of code

    ;setup the inner loop vars, for speed
    move.w  #$2140,d1       ; move.l d0,x(a0)
.doiteration\@
        move.w  d1,(a0)+    ; move.l d0,x(a0)
        move.w  d0,(a0)+    ; x
        add.w   d6,d0       ; x set x+160
    dbra    d7,.doiteration\@
    IFNE    \4
    move.w  #$4E75,(a0)+
    ENDC
    jmp .realend\@
.end\@
    IFNE    \4
        move.w  #$4E75,(a0)+
    ELSE
        move.w  #$4E71,(a0)+
    ENDC
.realend\@
    endm

fillBlock macro
\1
    addq.w  #1,d2                   ; .w 5242
    bne     .\@cont                 ; .w 6602 
    rts                             ; .w 4E75
.\@cont
d   SET     \2-8
    REPT    \3
        move.l  d(a0),d0            ; .l 2028 0B48 (2028 xxxx)
d       SET     d+160   
        eor.l   d0,d(a0)            ; .l B1A8 0BE8 (B1A8 xxxx+160)
    ENDR
    ENDM                            ; .w 4E75                       ; y * 8 + 8

makeFillBlock macro
    lea     \1,a0       ; load destination memory
    move.l  #\2,d0  ; initial starting offset
    subq.w  #8,d0
    move.l  #\3-1,d7    ; loop counter

    move.w  #$5242,(a0)+    ;   addq.w #1,d2                    ;2
    move.w  #$6602,(a0)+    ;   bne *+2                         ;2
    move.w  #$4E75,(a0)+    ;   rts                             ;2

    subq    #2,d7
    blt     .end\@
    move.l  #160,d6     ; offset
    ; actual generation of code


    ;setup the inner loop vars, for speed
    move.w  #$2028,d1       ; move.l d(a0),d0
    move.w  #$B1A8,d2       ; eor.l d0,d(a0)
.doiteration\@
        move.w  d1,(a0)+    ; move.l x(a0),d0                   ;2
        move.w  d0,(a0)+    ; x                                 ;2
        add.w   d6,d0       ; x set x+160
        move.w  d2,(a0)+    ; eor.l d0,x(a0)                    ;2
        move.w  d0,(a0)+    ; x                                 ;2
    dbra    d7,.doiteration\@
    IFNE    \4
    move.w  #$4E75,(a0)+    ;rts                                ;2
    ENDC
    jmp .realend\@
.end\@
    IFNE    \4
        move.w  #$4E75,(a0)+
    ELSE
        move.w  #$4E71,(a0)+
    ENDC
.realend\@
    endm


generateClearAndFillCode
    makeClearBlock block1_0,xx00_1,xy00_1,0
    makeClearBlock block2_0,xx00_2,xy00_2,0
    makeClearBlock block3_0,xx00_3,xy00_3,0
    makeClearBlock block4_0,xx00_4,xy00_4,0
    makeClearBlock block5_0,xx00_5,xy00_5,0
    makeClearBlock block6_0,xx00_6,xy00_6,0
    makeClearBlock block7_0,xx00_7,xy00_7,0
    makeClearBlock block8_0,xx00_8,xy00_8,0
    makeClearBlock block9_0,xx00_9,xy00_9,0
    makeClearBlock block10_0,xx00_10,xy00_10,0
    makeClearBlock block11_0,xx00_11,xy00_11,1

    makeClearBlock block1_1,xx01_1,xy01_1,0
    makeClearBlock block2_1,xx01_2,xy01_2,0
    makeClearBlock block3_1,xx01_3,xy01_3,0
    makeClearBlock block4_1,xx01_4,xy01_4,0
    makeClearBlock block5_1,xx01_5,xy01_5,0
    makeClearBlock block6_1,xx01_6,xy01_6,0
    makeClearBlock block7_1,xx01_7,xy01_7,0
    makeClearBlock block8_1,xx01_8,xy01_8,0
    makeClearBlock block9_1,xx01_9,xy01_9,0
    makeClearBlock block10_1,xx01_10,xy01_10,0
    makeClearBlock block11_1,xx01_11,xy01_11,1

    makeClearBlock block1_2,xx02_1,xy02_1,0
    makeClearBlock block2_2,xx02_2,xy02_2,0
    makeClearBlock block3_2,xx02_3,xy02_3,0
    makeClearBlock block4_2,xx02_4,xy02_4,0
    makeClearBlock block5_2,xx02_5,xy02_5,0
    makeClearBlock block6_2,xx02_6,xy02_6,0
    makeClearBlock block7_2,xx02_7,xy02_7,0
    makeClearBlock block8_2,xx02_8,xy02_8,0
    makeClearBlock block9_2,xx02_9,xy02_9,0
    makeClearBlock block10_2,xx02_10,xy02_10,0
    makeClearBlock block11_2,xx02_11,xy02_11,1

    makeClearBlock block1_3,xx03_1,xy03_1,0
    makeClearBlock block2_3,xx03_2,xy03_2,0
    makeClearBlock block3_3,xx03_3,xy03_3,0
    makeClearBlock block4_3,xx03_4,xy03_4,0
    makeClearBlock block5_3,xx03_5,xy03_5,0
    makeClearBlock block6_3,xx03_6,xy03_6,0
    makeClearBlock block7_3,xx03_7,xy03_7,0
    makeClearBlock block8_3,xx03_8,xy03_8,0
    makeClearBlock block9_3,xx03_9,xy03_9,0
    makeClearBlock block10_3,xx03_10,xy03_10,0
    makeClearBlock block11_3,xx03_11,xy03_11,1

    makeClearBlock block1_4,xx04_1,xy04_1,0
    makeClearBlock block2_4,xx04_2,xy04_2,0
    makeClearBlock block3_4,xx04_3,xy04_3,0
    makeClearBlock block4_4,xx04_4,xy04_4,0
    makeClearBlock block5_4,xx04_5,xy04_5,0
    makeClearBlock block6_4,xx04_6,xy04_6,0
    makeClearBlock block7_4,xx04_7,xy04_7,0
    makeClearBlock block8_4,xx04_8,xy04_8,0
    makeClearBlock block9_4,xx04_9,xy04_9,0
    makeClearBlock block10_4,xx04_10,xy04_10,0
    makeClearBlock block11_4,xx04_11,xy04_11,1

    makeClearBlock block1_5,xx05_1,xy05_1,0
    makeClearBlock block2_5,xx05_2,xy05_2,0
    makeClearBlock block3_5,xx05_3,xy05_3,0
    makeClearBlock block4_5,xx05_4,xy05_4,0
    makeClearBlock block5_5,xx05_5,xy05_5,0
    makeClearBlock block6_5,xx05_6,xy05_6,0
    makeClearBlock block7_5,xx05_7,xy05_7,0
    makeClearBlock block8_5,xx05_8,xy05_8,0
    makeClearBlock block9_5,xx05_9,xy05_9,0
    makeClearBlock block10_5,xx05_10,xy05_10,0
    makeClearBlock block11_5,xx05_11,xy05_11,1

    makeClearBlock block1_6,xx06_1,xy06_1,0
    makeClearBlock block2_6,xx06_2,xy06_2,0
    makeClearBlock block3_6,xx06_3,xy06_3,0
    makeClearBlock block4_6,xx06_4,xy06_4,0
    makeClearBlock block5_6,xx06_5,xy06_5,0
    makeClearBlock block6_6,xx06_6,xy06_6,0
    makeClearBlock block7_6,xx06_7,xy06_7,0
    makeClearBlock block8_6,xx06_8,xy06_8,0
    makeClearBlock block9_6,xx06_9,xy06_9,0
    makeClearBlock block10_6,xx06_10,xy06_10,0
    makeClearBlock block11_6,xx06_11,xy06_11,1

    makeClearBlock block1_7,xx07_1,xy07_1,0
    makeClearBlock block2_7,xx07_2,xy07_2,0
    makeClearBlock block3_7,xx07_3,xy07_3,0
    makeClearBlock block4_7,xx07_4,xy07_4,0
    makeClearBlock block5_7,xx07_5,xy07_5,0
    makeClearBlock block6_7,xx07_6,xy07_6,0
    makeClearBlock block7_7,xx07_7,xy07_7,0
    makeClearBlock block8_7,xx07_8,xy07_8,0
    makeClearBlock block9_7,xx07_9,xy07_9,0
    makeClearBlock block10_7,xx07_10,xy07_10,0
    makeClearBlock block11_7,xx07_11,xy07_11,1

    makeClearBlock block1_8,xx08_1,xy08_1,0
    makeClearBlock block2_8,xx08_2,xy08_2,0
    makeClearBlock block3_8,xx08_3,xy08_3,0
    makeClearBlock block4_8,xx08_4,xy08_4,0
    makeClearBlock block5_8,xx08_5,xy08_5,0
    makeClearBlock block6_8,xx08_6,xy08_6,0
    makeClearBlock block7_8,xx08_7,xy08_7,0
    makeClearBlock block8_8,xx08_8,xy08_8,0
    makeClearBlock block9_8,xx08_9,xy08_9,0
    makeClearBlock block10_8,xx08_10,xy08_10,0
    makeClearBlock block11_8,xx08_11,xy08_11,1

    makeClearBlock block1_9,xx09_1,xy09_1,0
    makeClearBlock block2_9,xx09_2,xy09_2,0
    makeClearBlock block3_9,xx09_3,xy09_3,0
    makeClearBlock block4_9,xx09_4,xy09_4,0
    makeClearBlock block5_9,xx09_5,xy09_5,0
    makeClearBlock block6_9,xx09_6,xy09_6,0
    makeClearBlock block7_9,xx09_7,xy09_7,0
    makeClearBlock block8_9,xx09_8,xy09_8,0
    makeClearBlock block9_9,xx09_9,xy09_9,0
    makeClearBlock block10_9,xx09_10,xy09_10,0
    makeClearBlock block11_9,xx09_11,xy09_11,1

    makeClearBlock block1_10,xx10_1,xy10_1,0
    makeClearBlock block2_10,xx10_2,xy10_2,0
    makeClearBlock block3_10,xx10_3,xy10_3,0
    makeClearBlock block4_10,xx10_4,xy10_4,0
    makeClearBlock block5_10,xx10_5,xy10_5,0
    makeClearBlock block6_10,xx10_6,xy10_6,0
    makeClearBlock block7_10,xx10_7,xy10_7,0
    makeClearBlock block8_10,xx10_8,xy10_8,0
    makeClearBlock block9_10,xx10_9,xy10_9,0
    makeClearBlock block10_10,xx10_10,xy10_10,0
    makeClearBlock block11_10,xx10_11,xy10_11,1

    makeClearBlock block1_11,xx11_1,xy11_1,0
    makeClearBlock block2_11,xx11_2,xy11_2,0
    makeClearBlock block3_11,xx11_3,xy11_3,0
    makeClearBlock block4_11,xx11_4,xy11_4,0
    makeClearBlock block5_11,xx11_5,xy11_5,0
    makeClearBlock block6_11,xx11_6,xy11_6,0
    makeClearBlock block7_11,xx11_7,xy11_7,0
    makeClearBlock block8_11,xx11_8,xy11_8,0
    makeClearBlock block9_11,xx11_9,xy11_9,0
    makeClearBlock block10_11,xx11_10,xy11_10,0
    makeClearBlock block11_11,xx11_11,xy11_11,1

    makeClearBlock block1_12,xx12_1,xy12_1,0
    makeClearBlock block2_12,xx12_2,xy12_2,0
    makeClearBlock block3_12,xx12_3,xy12_3,0
    makeClearBlock block4_12,xx12_4,xy12_4,0
    makeClearBlock block5_12,xx12_5,xy12_5,0
    makeClearBlock block6_12,xx12_6,xy12_6,0
    makeClearBlock block7_12,xx12_7,xy12_7,0
    makeClearBlock block8_12,xx12_8,xy12_8,0
    makeClearBlock block9_12,xx12_9,xy12_9,0
    makeClearBlock block10_12,xx12_10,xy12_10,0
    makeClearBlock block11_12,xx12_11,xy12_11,1 ;-->    1356

    makeClearBlock block1_13,xx13_1,xy13_1,0
    makeClearBlock block2_13,xx13_2,xy13_2,0
    makeClearBlock block3_13,xx13_3,xy13_3,0
    makeClearBlock block4_13,xx13_4,xy13_4,0
    makeClearBlock block5_13,xx13_5,xy13_5,0
    makeClearBlock block6_13,xx13_6,xy13_6,0
    makeClearBlock block7_13,xx13_7,xy13_7,0
    makeClearBlock block8_13,xx13_8,xy13_8,0
    makeClearBlock block9_13,xx13_9,xy13_9,0
    makeClearBlock block10_13,xx13_10,xy13_10,0
    makeClearBlock block11_13,xx13_11,xy13_11,1 ;-->    1356

    makeClearBlock block1_14,xx14_1,xy14_1,0
    makeClearBlock block2_14,xx14_2,xy14_2,0
    makeClearBlock block3_14,xx14_3,xy14_3,0
    makeClearBlock block4_14,xx14_4,xy14_4,0
    makeClearBlock block5_14,xx14_5,xy14_5,0
    makeClearBlock block6_14,xx14_6,xy14_6,0
    makeClearBlock block7_14,xx14_7,xy14_7,0
    makeClearBlock block8_14,xx14_8,xy14_8,0
    makeClearBlock block9_14,xx14_9,xy14_9,0
    makeClearBlock block10_14,xx14_10,xy14_10,0
    makeClearBlock block11_14,xx14_11,xy14_11,1 ;-->    1356

    makeClearBlock block1_15,xx15_1,xy15_1,0
    makeClearBlock block2_15,xx15_2,xy15_2,0
    makeClearBlock block3_15,xx15_3,xy15_3,0
    makeClearBlock block4_15,xx15_4,xy15_4,0
    makeClearBlock block5_15,xx15_5,xy15_5,0
    makeClearBlock block6_15,xx15_6,xy15_6,0
    makeClearBlock block7_15,xx15_7,xy15_7,0
    makeClearBlock block8_15,xx15_8,xy15_8,0
    makeClearBlock block9_15,xx15_9,xy15_9,0
    makeClearBlock block10_15,xx15_10,xy15_10,0
    makeClearBlock block11_15,xx15_11,xy15_11,1 ;-->    1356

    makeFillBlock   fillblock1_0,xx00_1,xy00_1,0
    makeFillBlock   fillblock2_0,xx00_2,xy00_2,0
    makeFillBlock   fillblock3_0,xx00_3,xy00_3,0
    makeFillBlock   fillblock4_0,xx00_4,xy00_4,0
    makeFillBlock   fillblock5_0,xx00_5,xy00_5,0
    makeFillBlock   fillblock6_0,xx00_6,xy00_6,0
    makeFillBlock   fillblock7_0,xx00_7,xy00_7,0
    makeFillBlock   fillblock8_0,xx00_8,xy00_8,0
    makeFillBlock   fillblock9_0,xx00_9,xy00_9,0
    makeFillBlock   fillblock10_0,xx00_10,xy00_10,0
    makeFillBlock   fillblock11_0,xx00_11,xy00_11,1

    makeFillBlock   fillblock1_1,xx01_1,xy01_1,0
    makeFillBlock   fillblock2_1,xx01_2,xy01_2,0
    makeFillBlock   fillblock3_1,xx01_3,xy01_3,0
    makeFillBlock   fillblock4_1,xx01_4,xy01_4,0
    makeFillBlock   fillblock5_1,xx01_5,xy01_5,0
    makeFillBlock   fillblock6_1,xx01_6,xy01_6,0
    makeFillBlock   fillblock7_1,xx01_7,xy01_7,0
    makeFillBlock   fillblock8_1,xx01_8,xy01_8,0
    makeFillBlock   fillblock9_1,xx01_9,xy01_9,0
    makeFillBlock   fillblock10_1,xx01_10,xy01_10,0
    makeFillBlock   fillblock11_1,xx01_11,xy01_11,1

    makeFillBlock   fillblock1_2,xx02_1,xy02_1,0
    makeFillBlock   fillblock2_2,xx02_2,xy02_2,0
    makeFillBlock   fillblock3_2,xx02_3,xy02_3,0
    makeFillBlock   fillblock4_2,xx02_4,xy02_4,0
    makeFillBlock   fillblock5_2,xx02_5,xy02_5,0
    makeFillBlock   fillblock6_2,xx02_6,xy02_6,0
    makeFillBlock   fillblock7_2,xx02_7,xy02_7,0
    makeFillBlock   fillblock8_2,xx02_8,xy02_8,0
    makeFillBlock   fillblock9_2,xx02_9,xy02_9,0
    makeFillBlock   fillblock10_2,xx02_10,xy02_10,0
    makeFillBlock   fillblock11_2,xx02_11,xy02_11,1

    makeFillBlock   fillblock1_3,xx03_1,xy03_1,0
    makeFillBlock   fillblock2_3,xx03_2,xy03_2,0
    makeFillBlock   fillblock3_3,xx03_3,xy03_3,0
    makeFillBlock   fillblock4_3,xx03_4,xy03_4,0
    makeFillBlock   fillblock5_3,xx03_5,xy03_5,0
    makeFillBlock   fillblock6_3,xx03_6,xy03_6,0
    makeFillBlock   fillblock7_3,xx03_7,xy03_7,0
    makeFillBlock   fillblock8_3,xx03_8,xy03_8,0
    makeFillBlock   fillblock9_3,xx03_9,xy03_9,0
    makeFillBlock   fillblock10_3,xx03_10,xy03_10,0
    makeFillBlock   fillblock11_3,xx03_11,xy03_11,1

    makeFillBlock   fillblock1_4,xx04_1,xy04_1,0
    makeFillBlock   fillblock2_4,xx04_2,xy04_2,0
    makeFillBlock   fillblock3_4,xx04_3,xy04_3,0
    makeFillBlock   fillblock4_4,xx04_4,xy04_4,0
    makeFillBlock   fillblock5_4,xx04_5,xy04_5,0
    makeFillBlock   fillblock6_4,xx04_6,xy04_6,0
    makeFillBlock   fillblock7_4,xx04_7,xy04_7,0
    makeFillBlock   fillblock8_4,xx04_8,xy04_8,0
    makeFillBlock   fillblock9_4,xx04_9,xy04_9,0
    makeFillBlock   fillblock10_4,xx04_10,xy04_10,0
    makeFillBlock   fillblock11_4,xx04_11,xy04_11,1


    makeFillBlock   fillblock1_5,xx05_1,xy05_1,0
    makeFillBlock   fillblock2_5,xx05_2,xy05_2,0
    makeFillBlock   fillblock3_5,xx05_3,xy05_3,0
    makeFillBlock   fillblock4_5,xx05_4,xy05_4,0
    makeFillBlock   fillblock5_5,xx05_5,xy05_5,0
    makeFillBlock   fillblock6_5,xx05_6,xy05_6,0
    makeFillBlock   fillblock7_5,xx05_7,xy05_7,0
    makeFillBlock   fillblock8_5,xx05_8,xy05_8,0
    makeFillBlock   fillblock9_5,xx05_9,xy05_9,0
    makeFillBlock   fillblock10_5,xx05_10,xy05_10,0
    makeFillBlock   fillblock11_5,xx05_11,xy05_11,1

    makeFillBlock   fillblock1_6,xx06_1,xy06_1,0
    makeFillBlock   fillblock2_6,xx06_2,xy06_2,0
    makeFillBlock   fillblock3_6,xx06_3,xy06_3,0
    makeFillBlock   fillblock4_6,xx06_4,xy06_4,0
    makeFillBlock   fillblock5_6,xx06_5,xy06_5,0
    makeFillBlock   fillblock6_6,xx06_6,xy06_6,0
    makeFillBlock   fillblock7_6,xx06_7,xy06_7,0
    makeFillBlock   fillblock8_6,xx06_8,xy06_8,0
    makeFillBlock   fillblock9_6,xx06_9,xy06_9,0
    makeFillBlock   fillblock10_6,xx06_10,xy06_10,0
    makeFillBlock   fillblock11_6,xx06_11,xy06_11,1

    makeFillBlock   fillblock1_7,xx07_1,xy07_1,0
    makeFillBlock   fillblock2_7,xx07_2,xy07_2,0
    makeFillBlock   fillblock3_7,xx07_3,xy07_3,0
    makeFillBlock   fillblock4_7,xx07_4,xy07_4,0
    makeFillBlock   fillblock5_7,xx07_5,xy07_5,0
    makeFillBlock   fillblock6_7,xx07_6,xy07_6,0
    makeFillBlock   fillblock7_7,xx07_7,xy07_7,0
    makeFillBlock   fillblock8_7,xx07_8,xy07_8,0
    makeFillBlock   fillblock9_7,xx07_9,xy07_9,0
    makeFillBlock   fillblock10_7,xx07_10,xy07_10,0
    makeFillBlock   fillblock11_7,xx07_11,xy07_11,1

    makeFillBlock   fillblock1_8,xx08_1,xy08_1,0
    makeFillBlock   fillblock2_8,xx08_2,xy08_2,0
    makeFillBlock   fillblock3_8,xx08_3,xy08_3,0
    makeFillBlock   fillblock4_8,xx08_4,xy08_4,0
    makeFillBlock   fillblock5_8,xx08_5,xy08_5,0
    makeFillBlock   fillblock6_8,xx08_6,xy08_6,0
    makeFillBlock   fillblock7_8,xx08_7,xy08_7,0
    makeFillBlock   fillblock8_8,xx08_8,xy08_8,0
    makeFillBlock   fillblock9_8,xx08_9,xy08_9,0
    makeFillBlock   fillblock10_8,xx08_10,xy08_10,0
    makeFillBlock   fillblock11_8,xx08_11,xy08_11,1

    makeFillBlock   fillblock1_9,xx09_1,xy09_1,0
    makeFillBlock   fillblock2_9,xx09_2,xy09_2,0
    makeFillBlock   fillblock3_9,xx09_3,xy09_3,0
    makeFillBlock   fillblock4_9,xx09_4,xy09_4,0
    makeFillBlock   fillblock5_9,xx09_5,xy09_5,0
    makeFillBlock   fillblock6_9,xx09_6,xy09_6,0
    makeFillBlock   fillblock7_9,xx09_7,xy09_7,0
    makeFillBlock   fillblock8_9,xx09_8,xy09_8,0
    makeFillBlock   fillblock9_9,xx09_9,xy09_9,0
    makeFillBlock   fillblock10_9,xx09_10,xy09_10,0
    makeFillBlock   fillblock11_9,xx09_11,xy09_11,1

    makeFillBlock   fillblock1_10,xx10_1,xy10_1,0
    makeFillBlock   fillblock2_10,xx10_2,xy10_2,0
    makeFillBlock   fillblock3_10,xx10_3,xy10_3,0
    makeFillBlock   fillblock4_10,xx10_4,xy10_4,0
    makeFillBlock   fillblock5_10,xx10_5,xy10_5,0
    makeFillBlock   fillblock6_10,xx10_6,xy10_6,0
    makeFillBlock   fillblock7_10,xx10_7,xy10_7,0
    makeFillBlock   fillblock8_10,xx10_8,xy10_8,0
    makeFillBlock   fillblock9_10,xx10_9,xy10_9,0
    makeFillBlock   fillblock10_10,xx10_10,xy10_10,0
    makeFillBlock   fillblock11_10,xx10_11,xy10_11,1

    makeFillBlock   fillblock1_11,xx11_1,xy11_1,0
    makeFillBlock   fillblock2_11,xx11_2,xy11_2,0
    makeFillBlock   fillblock3_11,xx11_3,xy11_3,0
    makeFillBlock   fillblock4_11,xx11_4,xy11_4,0
    makeFillBlock   fillblock5_11,xx11_5,xy11_5,0
    makeFillBlock   fillblock6_11,xx11_6,xy11_6,0
    makeFillBlock   fillblock7_11,xx11_7,xy11_7,0
    makeFillBlock   fillblock8_11,xx11_8,xy11_8,0
    makeFillBlock   fillblock9_11,xx11_9,xy11_9,0
    makeFillBlock   fillblock10_11,xx11_10,xy11_10,0
    makeFillBlock   fillblock11_11,xx11_11,xy11_11,1

    makeFillBlock   fillblock1_12,xx12_1,xy12_1,0
    makeFillBlock   fillblock2_12,xx12_2,xy12_2,0
    makeFillBlock   fillblock3_12,xx12_3,xy12_3,0
    makeFillBlock   fillblock4_12,xx12_4,xy12_4,0
    makeFillBlock   fillblock5_12,xx12_5,xy12_5,0
    makeFillBlock   fillblock6_12,xx12_6,xy12_6,0
    makeFillBlock   fillblock7_12,xx12_7,xy12_7,0
    makeFillBlock   fillblock8_12,xx12_8,xy12_8,0
    makeFillBlock   fillblock9_12,xx12_9,xy12_9,0
    makeFillBlock   fillblock10_12,xx12_10,xy12_10,0
    makeFillBlock   fillblock11_12,xx12_11,xy12_11,1

    makeFillBlock   fillblock1_13,xx13_1,xy13_1,0
    makeFillBlock   fillblock2_13,xx13_2,xy13_2,0
    makeFillBlock   fillblock3_13,xx13_3,xy13_3,0
    makeFillBlock   fillblock4_13,xx13_4,xy13_4,0
    makeFillBlock   fillblock5_13,xx13_5,xy13_5,0
    makeFillBlock   fillblock6_13,xx13_6,xy13_6,0
    makeFillBlock   fillblock7_13,xx13_7,xy13_7,0
    makeFillBlock   fillblock8_13,xx13_8,xy13_8,0
    makeFillBlock   fillblock9_13,xx13_9,xy13_9,0
    makeFillBlock   fillblock10_13,xx13_10,xy13_10,0
    makeFillBlock   fillblock11_13,xx13_11,xy13_11,1

    makeFillBlock   fillblock1_14,xx14_1,xy14_1,0
    makeFillBlock   fillblock2_14,xx14_2,xy14_2,0
    makeFillBlock   fillblock3_14,xx14_3,xy14_3,0
    makeFillBlock   fillblock4_14,xx14_4,xy14_4,0
    makeFillBlock   fillblock5_14,xx14_5,xy14_5,0
    makeFillBlock   fillblock6_14,xx14_6,xy14_6,0
    makeFillBlock   fillblock7_14,xx14_7,xy14_7,0
    makeFillBlock   fillblock8_14,xx14_8,xy14_8,0
    makeFillBlock   fillblock9_14,xx14_9,xy14_9,0
    makeFillBlock   fillblock10_14,xx14_10,xy14_10,0
    makeFillBlock   fillblock11_14,xx14_11,xy14_11,1

    makeFillBlock   fillblock1_15,xx15_1,xy15_1,0
    makeFillBlock   fillblock2_15,xx15_2,xy15_2,0
    makeFillBlock   fillblock3_15,xx15_3,xy15_3,0
    makeFillBlock   fillblock4_15,xx15_4,xy15_4,0
    makeFillBlock   fillblock5_15,xx15_5,xy15_5,0
    makeFillBlock   fillblock6_15,xx15_6,xy15_6,0
    makeFillBlock   fillblock7_15,xx15_7,xy15_7,0
    makeFillBlock   fillblock8_15,xx15_8,xy15_8,0
    makeFillBlock   fillblock9_15,xx15_9,xy15_9,0
    makeFillBlock   fillblock10_15,xx15_10,xy15_10,0
    makeFillBlock   fillblock11_15,xx15_11,xy15_11,1
    rts 


clearArea2
    ; depending on the vertices_xoffset, do the clearing
    ; the vertices_xoffset determines WHICH x-coords to draw

    IFNE    rasters
        move.w  #$143,$ffff8240
    ENDC
    move.l  clearpointer,a6
    move.l  (a6)+,a0
    moveq   #0,d0

    move.w  (a6)+,d1
    sub.w   #78,d1
    asl.w   #5,d1           ;16
    move.w  d1,d3
    add.w   d1,d1
    add.w   d1,d1
    add.w   d3,d1           ;---> 32                                        ; 177 vbl

    add.w   d1,a0


    moveq   #-12,d2
    move.w  (a6)+,d1
    move.w  d1,d6

    sub.w   #clearfilloffset,d1
    blt     less

    cmp.w   #320-96-96,d1
    ble     doclear

more
    move.w  d1,d3
    asr.w   #4,d3
    subq.w  #7,d3
    add.w   d3,d2
    subq    #2,d2
    jmp     doclear
    
less
    neg     d1
    move.w  d1,d2
    add.w   d2,d2           ;*2
    add.w   d2,d2           ;*4
    lea     negcleardata,a1
    add.w   d2,a1
    asr.w   #4,d1           ; divide by 16
    addq.w  #1,d1
    add.w   d1,d1
    add.w   d1,d1
    add.w   d1,d1           ;*8
    sub.w   d1,a0
    move.l  (a1),a1
    jmp     (a1)

doclear
    asr.w   #1,d1
    and.w   #%1111111111111000,d1

    add.w   d1,a0

    lea     x_block,a6
    moveq   #0,d7
    move.w  d6,d7
    add.w   d7,d7
    add.w   d7,d7
    move.l  (a6,d7.w),a6
    jmp     (a6)
xis00   equ block1_0
xis01   equ block1_1
xis02   equ block1_2
xis03   equ block1_3
xis04   equ block1_4
xis05   equ block1_5
xis06   equ block1_6
xis07   equ block1_7
xis08   equ block1_8
xis09   equ block1_9
xis10   equ block1_10
xis11   equ block1_11
xis12   equ block1_12
xis13   equ block1_13
xis14   equ block1_14
xis15   equ block1_15

stopclear
    rts 


eorFill2
    IFNE    rasters
    move.w  #$007,$ffff8240
    ENDC

    move.l  screenpointer2,a0

    move.w  vertices_yoff,d1
    sub.w   vertices_yoff_mod,d1
    sub.w   #78,d1

    asl.w   #5,d1           ;16
    move.w  d1,d3           ;4
    add.w   d1,d1           ;4
    add.w   d1,d1           ;4
    add.w   d3,d1           ;4      ;---> 32                                        ; 177 vbl

    add.w   d1,a0

    move.l  #0,d1
    moveq   #-12,d2

    move.w  vertices_xoff,d1
    move.w  d1,d7
    sub.w   #clearfilloffset,d1
    blt     less2
more2
    cmp.w   #320-96-96,d1
    ble     dofill
    move.w  d1,d3
    asr.w   #4,d3
    subq.w  #7,d3
    add.w   d3,d2
    sub.w   #2,d2
    jmp     dofill

less2
    neg     d1
    move.w  d1,d2
    move.w  d1,d3
    asr.w   #4,d1           ; divide by 16
    addq    #1,d1
    add.w   d1,d1
    add.w   d1,d1
    lea     negfilldata,a1
    add.w   d2,d2
    add.w   d2,d2
    add.w   d2,a1
    add.w   d1,d1
    sub.w   d1,a0
    move.l  (a1),a1
    jmp     (a1)

dofill
    asr.w   #1,d1                               ;8
    and.w   #%1111111111111000,d1               ;8
    add.w   d1,a0

    lea     fx_block,a6
    add.w   d7,d7
    add.w   d7,d7
    move.l  (a6,d7.w),a6
    jmp     (a6)

fxis00  equ fillblock1_0
fxis01  equ fillblock1_1
fxis02  equ fillblock1_2
fxis03  equ fillblock1_3
fxis04  equ fillblock1_4
fxis05  equ fillblock1_5
fxis06  equ fillblock1_6
fxis07  equ fillblock1_7
fxis08  equ fillblock1_8
fxis09  equ fillblock1_9
fxis10  equ fillblock1_10
fxis11  equ fillblock1_11
fxis12  equ fillblock1_12
fxis13  equ fillblock1_13
fxis14  equ fillblock1_14
fxis15  equ fillblock1_15

stopfill
    rts 

xx:     dc.l    0
xy:     dc.l    0
xz:     dc.l    0
yx:     dc.l    0
yy:     dc.l    0
yz:     dc.l    0
zx:     dc.l    0
zy:     dc.l    0
zz:     dc.l    0


; cost: 1582 + 208 * nr_vertex
; I have 14 vertices --> 1630 + 14 * 208 = 4542
; 1135 nop
doRotationPoly
    lea     path,a0
    move.w  #1024,d7
    move.w  currentStepX,d0
    add.w   stepSpeedX,d0
    cmp.w   d7,d0
    blt     .goodX
        sub.w   d7,d0
.goodX
    move.w  (a0,d0.w),d2
    move.w  d0,currentStepX

    move.w  currentStepY,d0
    add.w   stepSpeedY,d0
    cmp.w   d7,d0
    blt     .goodY
        sub.w   d7,d0
.goodY
    move.w  (a0,d0.w),d4
    move.w  d0,currentStepY

    move.w  currentStepZ,d0
    add.w   stepSpeedZ,d0
    cmp.w   d7,d0
    blt     .goodZ
        sub.w   d7,d0
.goodZ
    move.w  (a0,d0.w),d6
    move.w  d0,currentStepZ
doRotation:
.get_rotation_values_x_y_z                              ; http://mikro.naprvyraz.sk/docs/Coding/1/3D-ROTAT.TXT
    lea     sintable,a0                             ;12
    lea     sintable+256,a1
    move.w  (a0,d2.w),d1                    ; sin(A)    ;around z axis      16
    move.w  (a1,d2.w),d2                    ; cos(A)                        16
;    move.w  (a0),d1
;    move.w  (a1),d2
    move.w  (a0,d4.w),d3                    ; sin(B)    ;around y axis      16
    move.w  (a1,d4.w),d4                    ; cos(B)                        16
 ;   move.w  (a0),d3
 ;   move.w  (a1),d4
    move.w  (a0,d6.w),d5                    ; sin(C)    ;around x axis      16
    move.w  (a1,d6.w),d6                    ; cos(C)                        16
 ;   move.w  (a0),d5
 ;   move.w  (a1),d6
.xx
    move.w  d2,d7                       ;                       4
    muls    d4,d7                       ;                       42
    asr.l   #8,d7                       ;xx,zz                  24  
    move.w  d7,xx                       ;                       18      cos(A)*cos(B)
.xy
    move.w  d4,d7                       ;                       4
    muls    d1,d7                       ;                       42      cos(B)*sin(A)           
    asr.l   #8,d7                       ;                       24
    move.w  d7,a1                       ;                       4
.xz
    move.w  d3,a0                       ;                       4       sin(B)
.yx
    move.w  d6,d0                                           ;   4
    muls    d1,d0   ; d0 = sin(A) * cos(C)                      44      
    move.w  d2,d7                                           ;   4
    muls    d3,d7   ; d7 = cos(A) * sin(B)                  ;   44
    asr.l   #8,d7                                           ;   24
    muls    d5,d7   ; d7 = cos(A) * sin(B) * sin(C)         ;   44
    add.l   d7,d0                                           ;   10      
    asr.l   #8,d0                                           ;   22
    move.w  d0,a3                                           ;   4       cos(A) * sin(B) * sin(C) + sin(A) * cos(C)
.yy
    move.w  d2,d7   ; d7 = cos(A)                           ;   4
    neg     d7      ; d7 = -cos(A)                          ;   4
    muls    d6,d7   ; d7 = -cos(A) * cos(C)                 ;   44
    move.w  d1,d0       ; sin(A)                                4
    muls    d3,d0       ; sin(A) * sin(B)                       44
    asr.l   #8,d0       ;                                       24
    muls    d5,d0       ; sin(A) * sin(B) * sin(C)              44
    add.l   d0,d7       ;                                       8
    asr.l   #8,d7       ;                                       24
    move.w  d7,a4       ;                                       4
.yz
    move.w  d4,d7                                           ;   4
    neg     d7                                              ;   4
    muls    d5,d7                                           ;   44
    asr.l   #8,d7                                           ;   24
    move.w  d7,d6                                           ;   4
.setupComplete                      ; setup takes 906 cycles    

    moveq   #0,d7               ;4
    lea multable,a2             ;12

    move.w  a0,d0   ;xz         ;4
    move.w  a1,d1   ;xy         ;4
    move.w  a3,d2   ;yx         ;4
    move.w  a4,d5   ;yy         ;4

    move.w  #%111111110,d7
    and.w   d7,d0
    and.w   d7,d1
    and.w   d7,d2
    and.w   d7,d5
    and.w   d7,d6

    lsl.l   #8,d0               ;26
    lsl.l   #8,d1               ;24
    lsl.l   #8,d2               ;24
    lsl.l   #8,d5               ;24
    lsl.l   #8,d6               ;24

    move.l  d0,a0               ;4
    move.l  d1,a1               ;4
    move.l  d2,a3               ;4
    move.l  d5,a4               ;4
    move.w  xx(PC),d7           ;12
    and.w   #%111111110,d7
    lsl.l   #8,d7               ;24
    lea     vertexprojection,a6
    move.l  currentVertices,a5                  ;                   20                  
    move.w  number_of_vertices,d5               ; 20
.doVertex
        movem.w (a5)+,d0-d2                     ;8

        move.l  d7,d3   ;xx                     ;4      00000000 00000000 00000000 11111110     ;254
        or.w    d0,d3                           ;4
        move.w  (a2,d3.l),d4 ; x * xx           ;16     
        move.l  a1,d3   ;xy                     ;4
        or.w    d1,d3                           ;4
        add.w   (a2,d3.l),d4                    ;16
        move.l  a0,d3   ;xz                     ;4
        or.w    d2,d3                           ;4
        add.w   (a2,d3.l),d4                    ;16
        move.w  d4,(a6)+    ;store x''          ;8      ;

        move.l  a3,d3   ;yx                     ;4
        or.w    d0,d3                           ;4
        move.w  (a2,d3.l),d4 ; x * xx           ;16
        move.l  a4,d3   ;yy                     ;4
        or.w    d1,d3                           ;4
        add.w   (a2,d3.l),d4                    ;16 
        move.l  d6,d3   ;yz                     ;4
        or.w    d2,d3                           ;4
        add.w   (a2,d3.l),d4                    ;16
        move.w  d4,(a6)+    ;store y''          ;8

    dbra    d5,.doVertex                            ; 208/312 innerloop

    rts

initMultable:
    lea multable,a0
    moveq   #0,d7
    moveq   #0,d6
    moveq   #0,d5
    moveq   #0,d4

    move.w  #256,d0
    move.w  #256,d1

outerloop:
    moveq   #0,d6
innerloop:
    REPT 8
        move.b  d7,d5
        ext.w   d5
        move.b  d6,d4
        ext.w   d4

        muls    d4,d5
        asr.l   #7,d5
        move.w  d5,(a0)+

        addq    #1,d6
    ENDR
        cmp     d0,d6
        blt     innerloop
    addq    #1,d7
    cmp     d1,d7
    blt     outerloop

    rts


initDivTable
    lea divtable,a0
    lea y_block,a1
    moveq   #0,d7
    moveq   #0,d6
    moveq   #0,d5
    moveq   #0,d4
    move.l  #128,d0
    move.w  #divsize*2,d2

; encoding: upper 8 bits is x
;           lower 8 bits is y
; offset is longword per item
.outerloop:
    moveq   #0,d6       ; y
.innerloop:
    REPT 8
        move.l  d7,d5   ; x                                                                         ;   4
            cmp.w   d2,d6
            bgt.w   *+34
            asl.l   #8,d5
            divu    d6,d5
            move.w  d5,d1
            clr.w   d5
            swap    d5
            asl.l   #8,d5
            divu    d6,d5
            swap    d1
            asr.l   #8,d1
            or.w    d5,d1
            swap    d1

            asl.w   #5,d1           ;16         2^5 = 32
            move.w  d1,d3                   ; save 32
            add.w   d1,d1                   ; 64
            add.w   d1,d1                   ; 128
            add.w   d3,d1           ;---> 32     d1 = *160                                   ; 177 vbl

            swap    d1
            move.l  d1,(a0)+

            ;end actual calc
            addq    #1,d6   
    ENDR
                                                                                    ;   4
        cmp     d0,d6                                                                               ;   8
        blt     .innerloop                                                                          ; ----> +12 ==> 426
    addq    #1,d7                                                                                   ;   4
    cmp     d2,d7                                                                                   ;   8
    blt     .outerloop                                                                              ; ---> 256*256*426 + 256*16 = 3.5sec precalc

    rts


initPolyObject
        move.w  #14-1,number_of_vertices
        move.w  #24-1,number_of_polygons
        move.l  #coordsource,currentVertices
        move.w  #0,currentStep
        move.w  #99*2,currentStepX
        move.w  #0,currentStepY
        move.w  #0,currentStepZ
        move.w  #-79,vertices_xoff
        move.w  #140,vertices_yoff


        lea     cleardata,a0
        move.l  screenpointer2,(a0)+
        move.w  vertices_yoff,(a0)+
        move.w  vertices_xoff,(a0)+
        lea     cleardata,a0
        move.l  a0,clearpointer

        lea     cleardata2,a0
        move.l  screenpointer2,(a0)+
        move.w  vertices_yoff,(a0)+
        move.w  vertices_xoff,(a0)+
        lea     cleardata2,a0
        move.l  a0,clearpointer2
    rts
 
;;;;;;;;;;;;;;;;;;;; END POLYGON CODE ;;;;;;;;;;;;;;;;

poly_curt_vbl:    
        move.l screenpointershifter,$ff8200
        addq    #1,$466.w
        clr.b   $fffffa1b.w         ;Timer B control (stop)

    move.w  #0,$ffff8240        ;    black!

        ;Start up Timer A each VBL
        clr.b   $fffffa19.w         ;Timer-A control (stop)
        bset    #5,$fffffa07.w          ;Interrupt enable A (Timer A)
        bset    #5,$fffffa13.w          ;Interrupt mask A (Timer A)
        move.b  #98,$fffffa1f.w         ;Timer A Delay (data)
        move.b  #4,$fffffa19.w          ;Timer A Predivider (start Timer A)
;        move.l  #twister_timer_b,$120.w                   ;Install our own Timer B

        rte  


polycurt_timer_a:
        move.w  #$2100,sr           ;Enable HBL
        stop    #$2100              ;Wait for HBL
        move.w  #$2700,sr           ;Stop all interrupts
        clr.b   $fffffa19.w         ;Stop Timer A
        REPT 84
            nop
        ENDR

        clr.b   $ffff820a.w         ;60 Hz
        REPT 9
            nop
        ENDR
        move.b  #2,$ffff820a.w          ;50 Hz


        clr.b   $fffffa1b.w         ;Timer B control (stop)
        bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
        bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)

        pushd0
        moveq   #0,d0
        move.w  #130,d0
        sub.w   timer_b_offset,d0
        bne.s   nz    ;;
        moveq   #1,d0 ;;
nz:
        move.b  d0,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)  
        move.l  #timer_b_poly,$120.w        ;Install our own Timer B
        bclr    #3,$fffffa17.w          ;Automatic end of interrupt
        move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))

        popd0
        rte

twistpalettepointer
    dc.l    0


timer_b_poly

    movem.l d0-d7/a0,-(sp)
    move.l  twistpalettepointer,a0
    movem.l (a0),d0-d7
    movem.l d0-d7,$ffff8240
    move.w  #$2700,sr
    clr.b   $fffffa1b.w         ;Timer B control (stop)
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)

        moveq   #0,d0
        move.w  timer_b_offset,d0
nz2:            
        cmp.w   #100-1,d0
        bge.s   .bla

        add.w   d0,d0
        move.b  d0,$fffffa21.w
        jmp     .cont
.bla
        move.b  #199-2,$fffffa21.w
.cont
        move.l  #timer_b2,$120.w
    bclr    #3,$fffffa17.w          ;Automatic end of interrupt
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
    movem.l (sp)+,d0-d7/a0

    rte


timer_b2
    
    pushd0
    pusha0
    move.l  #0,d0
    lea     $ffff8240,a0
    rept 8
        move.l  d0,(a0)+
    endr
    popa0
    popd0
    clr.b   $fffffa1b.w         ;Timer B control (stop)
        jsr     music+8

    rte


timer_b_offset
    dc.w    1
swap_vbl
    dc.w    0

;;;;;;;;;;;;;;;;;;;; TWISTER + WOBBLE TEXT LOOP ;;;;;;;;;;;;;;;
twister
    move.l  screenpointer,a0
    jsr     clearScreen4bpl
    move.l  screenpointer2,a0
    jsr     clearScreen4bpl    

    lea     twistpallette+32*5,a0
    move.l  a0,twistpalettepointer

    jsr     initText
    jsr     prepareText
    jsr     generateClearScreenCode
    jsr     generateTwisterCode
    move.w  #vertical_offset_between_lines,twister_scrollvert

    tst.w   is_ste
    beq     .no_ste
        move.b  #0,$FF820D
        move.b  #0,$FF820F
        move.b  #0,$FF8265
.no_ste

    move.w  #$777,endPartBackgroundColor
    move.l  #poly_curt_vbl,a0
    move.l  #polycurt_timer_a,a1
    move.l  #dummy,a2
    jsr     install_vbl_ta_tb
    move.w  #3,twister_addition

.fadein
    wait_for_vbl
    swapscreens
    add.b   #8,twister_iteration
    move.w  twister_addition,d5         ; this is now 3
    add.w   d5,twistdataoffset
    jsr     doTwisterCode

    cmp.w   #97,timer_b_offset
    beq     .init
    add.w   #1,timer_b_offset
    jmp .fadein

.init  
    move.w  #$2700,sr
    move.l  #twister_tatb_vbl,$70.w                    ;Install our own VBL
    move.w  #$2300,sr
    move.w  #3,twister_addition
    move.w  #250,waitcounter

.mainloop
    wait_for_vbl
    swapscreens
    jsr twisterClearScreenCode
    jsr doTwisterCode
    jsr twisterText

    ;;;;;;;;;; BEGIN WOBBLE STUFF ;;;;;;;;;;
    ; change horz offset
    move.w  twister_horoffset,d0
    add.w   #1,d0
    cmp.w   #100,d0
    ble     .hh
    move.w  #0,d0
.hh
    move.w  d0,twister_horoffset

    ; change vert offset
    move.w  vertoffsettableoffset,d0
    add.w   #4,d0
    cmp.w   #16,d0
    bne     .nn

    move.w  #0,d0
    move.w  twister_vertoffset,d1
    add.w   #2,d1
    move.w  d1,twister_vertoffset
    cmp.w   #40,d1
    bne     .nn
    move.w  #0,d1
    move.w  d1,twister_vertoffset
.nn
    move.w  d0,vertoffsettableoffset
    ;;;;;;;;; END WOBBLE STUFF ;;;;;

    ;;; TWISTER ITER ;;;
    add.b   #8,twister_iteration
    move.w  twister_addition,d5         ; this is now 3
    add.w   d5,twistdataoffset
    ;;; END ITER ;;;;

    ;;;; TEXT SCROLLING ;;;;;
    move.w  textoffset,d0
    cmp.w   #87*40,d0
    beq     .textdone
    ; scrolling of text
    moveq   #0,d0
    move.w  twister_scrollvert,d0
    move.w  twister_horoffset,d1
    sub.w   #160,d0
    bgt     .no_scroll_vert_reset
    move.w  #vertical_offset_between_lines,d0
    add.w   #text_line_offset,textoffset
    add.w   #10,d1
    cmp.w   #100,d1
    blt     .no_scroll_vert_reset
    sub.w   #100,d1
.no_scroll_vert_reset
    move.w  d0,twister_scrollvert
    move.w  d1,twister_horoffset
    ;;;;; END TEXT SCROLLING ;;;;;

            check_for_spacebar_to_exit
    bne     .mainloop

.textdone
    move.w  waitcounter,d0
    beq     .deinit
    subq.w  #1,waitcounter
    jmp     .mainloop


.deinit
    move.w  #40,waitcounter
    move.w  #4,fadecounter
    lea     twistpallette+32*5,a0
    move.l  #currentPalette,twistpalettepointer
.fadeoutloop
            wait_for_vbl
            swapscreens

    sub.w   #1,fadecounter
    bne     .skip222
    lea     blackPalette,a0
    lea     currentPalette,a1
    jsr     doFade


    move.w  #4,fadecounter
.skip222    


    jsr twisterClearScreenCode
    jsr doTwisterCode
    jsr twisterText

    ;;;;;;;;;; BEGIN WOBBLE STUFF ;;;;;;;;;;
    ; change horz offset
    move.w  twister_horoffset,d0
    add.w   #1,d0
    cmp.w   #100,d0
    ble     .hhrr
    move.w  #0,d0
.hhrr
    move.w  d0,twister_horoffset

    ; change vert offset
    move.w  vertoffsettableoffset,d0
    add.w   #4,d0
    cmp.w   #16,d0
    bne     .nnrr

    move.w  #0,d0
    move.w  twister_vertoffset,d1
    add.w   #2,d1
    move.w  d1,twister_vertoffset
    cmp.w   #40,d1
    bne     .nnrr
    move.w  #0,d1
    move.w  d1,twister_vertoffset
.nnrr
    move.w  d0,vertoffsettableoffset
    ;;;;;;;;; END WOBBLE STUFF ;;;;;

    ;;; TWISTER ITER ;;;
    add.b   #8,twister_iteration
    move.w  twister_addition,d5         ; this is now 3
    add.w   d5,twistdataoffset
    ;;; END ITER ;;;;

            check_for_spacebar_to_exit
    sub.w   #1,waitcounter
    beq     twister_nextscene

    jmp     .fadeoutloop

currentPalette  equ twistpallette+32*5


; VVV
;;;;;;;;;;;;;;;; TWISTER + WOBBLE MAIN CODE ;;;;;;;;;;;;;;;;
twister_tatb_vbl:       
        move.l screenpointershifter,$ff8200
            tst.w   is_ste
    beq     .no_ste
        move.b  #0,$FF820D
        move.b  #0,$FF820F
        move.b  #0,$FF8265
.no_ste
        addq    #1,$466.w
        move.w  #$2700,sr           ;Stop all interrupts

        IFNE    framecount
            addq.w  #1,framecounter
        ENDC

        ;Start up Timer A each VBL
        clr.b   $fffffa19.w         ;Timer-A control (stop)
        bset    #5,$fffffa07.w          ;Interrupt enable A (Timer A)
        bset    #5,$fffffa13.w          ;Interrupt mask A (Timer A)
        move.b  #98,$fffffa1f.w         ;Timer A Delay (data)
        move.b  #4,$fffffa19.w          ;Timer A Predivider (start Timer A)

        move.l #twister_timer_a,$134.w    
        
        ;Start up Timer B each VBL
        clr.b   $fffffa1b.w         ;Timer B control (stop)
        bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
        bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
;        move.b  #30,$fffffa21.w     ;Timer B data (number of scanlines to next interrupt)
;        move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
        bclr    #3,$fffffa17.w          ;Automatic end of interrupt

        move #$2400,SR

        pushall
        lea $ffff8240.w,a0
        moveq #0,d0
        rept 8
        move.l d0,(a0)+
        endr

        popall


        jsr     music+8
        rte

twister_timer_a:
        move.w  #$2100,sr           ;Enable HBL
        stop    #$2100              ;Wait for HBL
        move.w  #$2700,sr           ;Stop all interrupts
        clr.b   $fffffa19.w         ;Stop Timer A

        move #$000,$ffff8240.w    

        dcb.w   84-4,$4e71            ;Zzzz

        clr.b   $ffff820a.w         ;60 Hz
        REPT 9     ;
            nop
        ENDR
        move.b  #2,$ffff820a.w          ;50 Hz

        move.b #0,$fffffa1b.w    
        move.l  #twister_tb_1,$120.w        ;Install our own Timer B
        move.b  #32-3,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
        move.b #8,$fffffa1b.w

        rte

;TTT

; tb_1 is 30 lines of black, which covers last line
twister_tb_1: 

    movem.l d0-d7/a0,-(sp)    
    move.l  twistpalettepointer,a0
    move.w  (a0),d7
    addq.l  #2,a0

    move.w  (a0)+,$ffff8242.w
    movem.l (a0),d0-d6
    movem.l d0-d6,$ffff8244.w

    dcb.w   60,$4e71            ;52 nops
    move    d7,$ffff8240.w
    movem.l (sp)+,d0-d7/a0

    move.b  #0,$fffffa1b.w    
    move.l  #twister_tb_1B,$120.w        ;Install our own Timer B
    move.b  #199-1,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b  #8,$fffffa1b.w
    rte

twister_tb_1B:

        dcb.w   128+10,$4e71
        move.w  #$000,$ffff8240.w
        pushd0
        pusha0
        lea     $ffff8240.w,a0
        moveq   #0,d0
        rept 8
        move.l d0,(a0)+
        endr
        popa0
        popd0
tb_rte:
        move.b #0,$fffffa1b.w
        move.l #tb_rte,$120.w     
        rte

        move.w  endPartBackgroundColor,$ffff8240.w
        move.l  #twister_timer_b,$120.w             ;Install our own Timer B    
        rte


twister_timer_b:    
        clr.b   $ffff820a.w         ;60 Hz
        not.w   $ffff8240
        move.w  #$000,$ffff8240
        dcb.w   1,$4e71             ;       5 nops
        move.b  #2,$ffff820a.w          ;50 Hz

        rte

install_vbl_ta_tb:
        move.l  a0,-(sp)                        ;Save A0
        move.l  a1,-(sp)                        ;Save A0    
        move.l  a2,-(sp)
        move.w  #$2700,sr                   ;Stop all interrupts (using $ means hexidecimal)
        move.l  a0,$70.w                    ;Install our own VBL
        move.l  a1,$134.w                   ;Install our own Timer B
        move.l  a2,$120.w                   ;Install our own Timer B
        move.l  #dummy,$68.w            ;Install our own HBL (dummy)

        clr.b   $fffffa07.w                 ;Interrupt enable A (Timer-A & B)
        clr.b   $fffffa13.w                 ;Interrupt mask A (Timer-A & B)
        clr.b   $fffffa09.w                 ;Interrupt enable B (Timer-C & D)
        clr.b   $fffffa15.w                 ;Interrupt mask B (Timer-C & D)
        move.w  #$2300,sr                   ;Interrupts back on
        move.l  (sp)+,a2
        move.l  (sp)+,a1
        move.l  (sp)+,a0
        rts     


generateTwisterCode
    lea     doTwisterCode,a0
    ; init stuff
    move.w  #$41F9,(a0)+        ; lea absolute address into a0      ;1
    move.l  #twistbin,(a0)+     ; absolute address                  ;2
    move.w  #$2279,(a0)+        ; movea.l absolute ddress to a1     ;1
    move.l  #screenpointer2,(a0)+   ; absolute address              ;2
    move.l  #$43E91220,(a0)+    ; add offset to a1
    move.w  #$45F9,(a0)+        ; lea absolute address into a2      ;1
    move.l  #twistdata,(a0)+    ; absolute address                  ;2
    move.w  #$D4F9,(a0)+        ; adda.w absolute address           ;1

    move.l  #twistdataoffset,(a0)+  ; absolute address              ;2
    move.w  #$7E00,(a0)+        ; moveq #0,d7                       ;1
    move.w  #$1E39,(a0)+        ; move.b absolute into d7           ;1
    move.l  #twister_iteration,(a0)+; absolute address                  ;2
    move.w  #$43E9,(a0)+        ; lea a1,a1                         ;1
    move.w  #$00A0,(a0)+        ; offset 160                        ;1  --> 18
    ; variables for loop
    moveq   #0,d0               ; offset register                   
    move.l  #198-1,d7           ; d7 counter register

    move.l  #$DE1A2C07,d1
    move.l  #$ED4E4CF0,d2
    move.l  #$780F6000,d3
    move.l  #$48E9780F,d4
    move.l  #$4CF0780F,d5
    move.w  #$6020,d6


    ; first iteration is special, no offset at first write
;   move.w  #$DE1A,(a0)+        ;   addb (a2)+,d7                   ;1
;   move.w  #$2C07,(a0)+        ;   move.l  d7,d6                   ;1
    move.l  d1,(a0)+
;   move.w  #$ED4E,(a0)+        ;   lsl #6,d6                       ;1

;   move.w  #$4CF0,(a0)+        ;                                   ;1
    move.l  d2,(a0)+
;   move.w  #$780F,(a0)+        ;   movem.l (a0,d6.w),d0-d3/a3-a6   ;1
;   move.w  #$6000,(a0)+                ;                           ;1
    move.l  d3,(a0)+

    move.w  #$48D1,(a0)+        ;   movem.l d0-d3/a3-a6,o(a1)   with o = 0  ;1
    move.w  #$780F,(a0)+        ;                                           ;1
    add.w   #32,d0

;   move.w  #$4CF0,(a0)+        ;                                   ;1
;   move.w  #$780F,(a0)+        ; movem.l   o(a0,d6.w),d0-d3/a3-a6  ;1
    move.l  d5,(a0)+
    move.w  d6,(a0)+                                            ;1

;   move.w  #$48E9,(a0)+                                            ;1
;   move.w  #$780F,(a0)+                                            ;1 --> 31
    move.l  d4,(a0)+
    move.w  d0,(a0)+    
    add.w   #128,d0


.doiteration
;       move.w  #$DE1A,(a0)+        ;   addb (a2)+,d7                   ;1
;       move.w  #$2C07,(a0)+        ;   move.l  d7,d6                   ;1
        move.l  d1,(a0)+                                                ;2

;       move.w  #$ED4E,(a0)+        ;   lsl #6,d6                       ;1

;       move.w  #$4CF0,(a0)+        ;
        move.l  d2,(a0)+

;       move.w  #$780F,(a0)+        ;   movem.l (a0,d6.w),d0-d3/a3-a6
;       move.w  #$6000,(a0)+                ;
        move.l  d3,(a0)+

;       move.w  #$48E9,(a0)+        ;   movem.l d0-d3/a3-a6,o(a1)   with o = 0
;       move.w  #$780F,(a0)+        ;
        move.l  d4,(a0)+
        move.w  d0,(a0)+
        add.w   #32,d0

;       move.w  #$4CF0,(a0)+        ;
;       move.w  #$780F,(a0)+        ; movem.l   o(a0,d6.w),d0-d3/a3-a6
        move.l  d5,(a0)+
        move.w  d6,(a0)+

;       move.w  #$48E9,(a0)+
;       move.w  #$780F,(a0)+                                            ; 17 * 198
        move.l  d4,(a0)+
        move.w  d0,(a0)+
        add.w   #128,d0

    dbra    d7,.doiteration

    move.w  #$0C79,(a0)+                                                
    move.w  #totallength2,(a0)+ 
    move.l  #twistdataoffset,(a0)+
    move.w  #$6C02,(a0)+
    move.w  #$6008,(a0)+

    move.w  #$0479,(a0)+ 
    move.w  #totallength2,(a0)+
    move.l  #twistdataoffset,(a0)+                              ;10 + 31 + 13*198

    move.w  #$4E75,(a0)+    
    rts

generateClearScreenCode
    lea     twisterClearScreenCode,a0
    move.w  #$2079,(a0)+
    move.l  #screenpointer2,(a0)+
    move.l  #$41E81220,(a0)+
    move.w  #$7000,(a0)+                ;   moveq   #0,d0

    move.w  #64,d5              ; offset
    move.w  #12-1,d6
    move.w  #200-1,d7

    move.w  #$3140,d0
    move.w  #64,d1

.outerloop
    move.w  #12-1,d6
.innerloop
        move.w  d0,(a0)+            ; 12*188 longword + 5 word => 
        move.w  d5,(a0)+
        addq    #8,d5
    dbra    d6,.innerloop
    add.w   d1,d5
    dbra    d7,.outerloop

    move.w  #$4E75,(a0)+
    rts



prepareText
    lea     twister_text,a0
    lea     twister_text_codes,a1

    move.w  #totalnumber_of_text_lines*characters_per_line-1,d7
.doletter
    moveq   #0,d0
    move.b  (a0)+,d0
    sub.w   #32,d0
    lsl.w   #4,d0
    move.w  d0,(a1)+
    dbra    d7,.doletter
    rts


;savedA7
;    ds.l    1

twisterText
    move.l  a7,savedA7
    move.w  twister_horoffset,d7        ;12
    add.w   d7,d7   ;2          ;4
    add.w   d7,d7   ;4          ;4
    add.w   d7,d7   ;8          ;4      ; if we keep d7 safe, then this is not needed
    lea     twister_text_codes,a2             ;8      ; if we are smart then we only have to do a2 once
    add.w   textoffset,a2       ;16     ; if we save textoffset to d6, and keep this local
    lea     twister_verttable,a4        ;8
    move.w  #number_of_lines-1,d6           ;8
    move.w  vertoffsettableoffset,d0    ;12
    move.l  (a4,d0.w),a4        ;20
    add.w   twister_vertoffset,a4       ;16
    move.l  a4,usp              ;4
    move.l  screenpointer2,a1   ;20
    add.w   #72+1760,a1
    add.w   twister_scrollvert,a1
    lea     twister_sinetexthor,a0
    move.l  a0,a7

doTextLine
    move.l  a7,a0
    add.w   d7,a0               ;8      ; determine h offset, d7 cant be modified
    swap    d7                  ;4
    move.w  #number_of_2characters-1,d7         ;8
    move.l  (a0)+,a6            ;12
    move.l  (a0),a0             ;12
    move.l  a1,a3               ;4
    move.l  usp,a4              ;4

    jmp     (a6)                ;8      --> was 204, now: 88

; in use:
;   a0
;   a1
;   a2
;   a3
;   a4
;   a5
;   a6
;   d0,d1,d2,d3,d4,d5,d7

minus8tominus15
.doletters
    move.l  a3,a5
    add.w   (a4)+,a5

    move.w  (a2)+,d0
    beq.s   .letter2

    move.l  a0,a6
    add.w   d0,a6
o   SET     0
    REPT 6
        move.b  (a6)+,d0
        or.b    d0,o-7(a5)
        move.b  (a6)+,d0
        move.b  d0,o(a5)
o       SET     o+160
    ENDR

.letter2
    move.w  (a2)+,d0
    beq.s   .addtoa4next

    move.l  a3,a5
    add.w   (a4)+,a5
        movem.w (a0,d0.w),d0-d5 ;
        or.w    d0,(a5)
        or.w    d1,160(a5)
        or.w    d2,320(a5)
        or.w    d3,480(a5)
        or.w    d4,640(a5)
        or.w    d5,800(a5)
.next
    add.w   #8,a3
    dbra    d7,.doletters
.end
    add.w   #vertical_offset_between_lines,a1
    swap    d7
    add.w   #text_character_offset,d7
    dbra    d6,doTextLine
    move.l  savedA7,a7
    rts
.addtoa4next
    add.w   #2,a4
    add.w   #8,a3
    dbra    d7,.doletters   
    add.w   #vertical_offset_between_lines,a1
    swap    d7
    add.w   #text_character_offset,d7
    dbra    d6,doTextLine
    move.l  savedA7,a7
    rts

zerotominus7
.doletters
    move.l  a3,a5                   ;4
    add.w   (a4)+,a5                    ;14         ; 64

    move.w  (a2)+,d0
    beq.s   .letter2

        movem.w (a0,d0.w),d0-d5     ;44
        or.w    d0,(a5)             ;12         ; 7*16 + 12 + 44 = 112 + 56 = 168
        or.w    d1,160(a5)          ;16
        or.w    d2,320(a5)          ;16
        or.w    d3,480(a5)          ;16
        or.w    d4,640(a5)          ;16
        or.w    d5,800(a5)          ;16

.letter2
    add.w   #8,a3                   ;8          ; this can be removed when using rept        17*8*8*1= 1088
    move.w  (a2)+,d0                ;8
    beq.s   .addtoa4next

    move.l  a3,a5                   ;4
    add.w   (a4)+,a5                ;12
    move.l  a0,a6                   ;4
    add.w   d0,a6                   ;8
o   SET     0
    REPT 6
        ; 12 * 8 = 96 => 88
        move.b  (a6)+,d0            ;8      ; 44 * 6 = 284
        or.b    d0,o-7(a5)          ;16
        move.b  (a6)+,d0            ;8
        move.b  d0,o(a5)            ;12
o       SET     o+160
    ENDR
.next
    dbra    d7,.doletters
.end
    add.w   #vertical_offset_between_lines,a1
    swap    d7                      ;4
    add.w   #text_character_offset,d7                   ;8
    dbra    d6,doTextLine           ;12
    move.l  savedA7,a7
    rts
.addtoa4next
    add.w   #2,a4
    dbra    d7,.doletters
    add.w   #vertical_offset_between_lines,a1
    swap    d7                      ;4
    add.w   #text_character_offset,d7                   ;8
    dbra    d6,doTextLine           ;12
    move.l  savedA7,a7
    rts

initText
    lea twister_text_shift0,a0
    lea twister_text_shift1,a1
    jsr shiftOneLeft
    lea twister_text_shift1,a0
    lea twister_text_shift2,a1
    jsr shiftOneLeft
    lea twister_text_shift2,a0
    lea twister_text_shift3,a1
    jsr shiftOneLeft
    lea twister_text_shift3,a0
    lea twister_text_shift4,a1
    jsr shiftOneLeft
    lea twister_text_shift4,a0
    lea twister_text_shift5,a1
    jsr shiftOneLeft
    lea twister_text_shift5,a0
    lea twister_text_shift6,a1
    jsr shiftOneLeft
    lea twister_text_shift6,a0
    lea twister_text_shift7,a1
    jsr shiftOneLeft
    rts

shiftOneLeft
    move.l  #93*8-1,d7
    moveq   #0,d0
    roxl.l  #1,d0
.shiftword
    move.w  (a0)+,d0
    roxl.w  #1,d0
    move.w  d0,(a1)+
    dbra    d7,.shiftword
    rts
;;;;;;;;;;;;;;;;;;; END TWISTER AND WOBBLE CODE ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; START MOIRE ;;;;;;;;;;;;
bg   equ bg_1
bg_1 equ $0012
c1_1 equ $0435
c2_1 equ $0325




moirepalette
    dc.w    bg_1,c1_1,c2_1,bg_1,bg_1,bg_1,bg_1,bg_1
    dc.w    c1_1,bg_1,bg_1,bg_1,bg_1,bg_1,bg_1,bg_1

bg_2 equ $0012
c1_2 equ $0133
c2_2 equ $0334

moirepalette2
    dc.w    bg_2,c1_2,c2_2,bg_2,bg_2,bg_2,bg_2,bg_2
    dc.w    c1_2,bg_2,bg_2,bg_2,bg_2,bg_2,bg_2,bg_2

bg_3 equ $0012
c1_3 equ $0422
c2_3 equ $0232

moirepalette3
    dc.w    bg_3,c1_3,c2_3,bg_3,bg_3,bg_3,bg_3,bg_3
    dc.w    c1_3,bg_3,bg_3,bg_3,bg_3,bg_3,bg_3,bg_3

bg_4 equ $0012
c1_4 equ $0323
c2_4 equ $0326

moirepalette4
    dc.w    bg_4,c1_4,c2_4,bg_4,bg_4,bg_4,bg_4,bg_4
    dc.w    c1_4,bg_4,bg_4,bg_4,bg_4,bg_4,bg_4,bg_4

moire_duration equ 280


moire
.init


    move.l  screenpointer,a0
    jsr     clearScreen4bpl
    move.l  screenpointer2,a0
    jsr     clearScreen4bpl

    move.l  #default_vbl,a0
    move.l  #dummy,a1
    jsr     install_vbl_hbl 

    moveq   #0,d0
    lea     $ffff8240,a0
    REPT 8  
        move.l  d0,(a0)+
    ENDR


    lea     moiresun,a0
    jsr     initBitplanesNew

    move.l  #pathnew1,pathpointer1
    move.l  #pathnew2,pathpointer2

    move.w  #0,currentStep
    move.w  #moire_duration,waitcounter
    move.w  #8,fadecounter


.mainloop 
        wait_for_vbl
        swapscreens


    sub.w   #1,fadecounter
    bne     .skip
    lea     moirepalette,a0
    lea     $ffff8240,a1
    jsr     doFade
    move.w  #8,fadecounter
.skip

    jsr     doMoire

    subq.w  #1,waitcounter
    beq     fadeOut1

        check_for_spacebar_to_exit
    jmp .mainloop 


fadeOut1
    move.w  #4,fadecounter
    move.w  #17,waitcounter
.mainloop 
            wait_for_vbl
            swapscreens
    sub.w   #1,fadecounter
    bne     .skip
    lea     greenPalette,a0
    lea     $ffff8240,a1
    jsr     doFade
    move.w  #4,fadecounter
.skip
    jsr     doMoire
    sub.w  #1,waitcounter
    beq     part2
            check_for_spacebar_to_exit
    jmp     .mainloop 


part2
    lea     moirecircle,a0
    jsr     initBitplanesNew
    move.l  #path1,pathpointer1
    move.l  #path2,pathpointer2

    move.w  #4,fadecounter
    move.w  #moire_duration,waitcounter
    move.w  #0,currentStep

.mainloop
    wait_for_vbl
    swapscreens
    sub.w   #1,fadecounter
    bne     .skip
    lea     moirepalette2,a0
    lea     $ffff8240,a1
    jsr     doFade
    move.w  #8,fadecounter
.skip
    jsr     doMoire
    subq.w  #1,waitcounter
    beq     part2FadeOut
            check_for_spacebar_to_exit
    jmp     .mainloop




part2FadeOut
    move.w  #4,fadecounter
    move.w  #17,waitcounter
fadeOut2
        wait_for_vbl
        swapscreens

    sub.w   #1,fadecounter
    bne     .skip
    lea     greenPalette,a0
    lea     $ffff8240,a1
    jsr     doFade
    move.w  #4,fadecounter
.skip

    jsr     doMoire

    sub.w  #1,waitcounter
    beq     part3

            check_for_spacebar_to_exit
    jmp     fadeOut2




part3a
.init
    lea     wobblesun,a0
    jsr     initBitplanesNew
    move.l  #pathnew1,pathpointer1
    move.l  #pathnew2,pathpointer2
    move.w  #8,fadecounter
    move.w  #moire_duration,waitcounter
    move.w  #0,currentStep
.mainloop
    wait_for_vbl
    swapscreens
    sub.w   #1,fadecounter
    bne     .skip

    lea     moirepalette3,a0
    lea     $ffff8240,a1
    jsr     doFade
    move.w  #8,fadecounter
.skip

    jsr     doMoireDist

    subq.w  #1,waitcounter
    beq     part3FadeOuta

         check_for_spacebar_to_exit
    jmp .mainloop
       



part3FadeOuta
    move.w  #4,fadecounter
    move.w  #17,waitcounter
fadeOut3a
        wait_for_vbl
        swapscreens

    sub.w   #1,fadecounter
    bne     .skip
    lea     greenPalette,a0
    lea     $ffff8240,a1
    jsr     doFade
    move.w  #4,fadecounter
.skip

    jsr     doMoire

    sub.w  #1,waitcounter
    beq     part4

            check_for_spacebar_to_exit
    jmp     fadeOut3a










part3
.init
    lea     wobblesun,a0
    jsr     initBitplanesNew
    move.l  #pathnew1,pathpointer1
    move.l  #pathnew2,pathpointer2
    move.w  #8,fadecounter
    move.w  #moire_duration,waitcounter
    move.w  #0,currentStep
.mainloop
    wait_for_vbl
    swapscreens
    sub.w   #1,fadecounter
    bne     .skip

    lea     moirepalette4,a0
    lea     $ffff8240,a1
    jsr     doFade
    move.w  #8,fadecounter
.skip

    jsr     doMoireDist

    subq.w  #1,waitcounter
    beq     part3FadeOut

         check_for_spacebar_to_exit
    jmp .mainloop
       



part3FadeOut
    move.w  #4,fadecounter
    move.w  #17,waitcounter
fadeOut3
        wait_for_vbl
        swapscreens

    sub.w   #1,fadecounter
    bne     .skip
    lea     greenPalette,a0
    lea     $ffff8240,a1
    jsr     doFade
    move.w  #4,fadecounter
.skip

    jsr     doMoire

    sub.w  #1,waitcounter
    beq     part4

            check_for_spacebar_to_exit
    jmp     fadeOut3



part4
.init
    lea     moiresun,a0
    jsr     initBitplanesNew
    move.l  #path1,pathpointer1
    move.l  #path2,pathpointer2
    move.w  #8,fadecounter
    move.w  #moire_duration,waitcounter
    move.w  #0,currentStep
.mainloop
    wait_for_vbl
    swapscreens
    sub.w   #1,fadecounter
    bne     .skip

    lea     moirepalette,a0
    lea     $ffff8240,a1
    jsr     doFade
    move.w  #8,fadecounter
.skip

    jsr     doMoireDist

    subq.w  #1,waitcounter
    beq     part4FadeOut

         check_for_spacebar_to_exit
    jmp .mainloop



part4FadeOut
.deinit3
    move.w  #1,fadecounter
    move.w  #50,waitcounter
.fadeOut2
        wait_for_vbl
        swapscreens

    sub.w   #1,fadecounter
    bne     .skip5
    lea     greenPalette,a0
    lea     $ffff8240,a1
    jsr     doFade
    move.w  #7,fadecounter
.skip5

    jsr     doMoireDist

    sub.w  #1,waitcounter
    beq     moire_nextscene

        check_for_spacebar_to_exit
    jmp .fadeOut2

;;;;;;;;;;;;; END MOIRE ;;;;;;;;;;;;;
;;;;;;;;;;;;; START MOIRE SUPPORT ;;;;;;;;;;;;

; d0 x_offset to source font
; d1 y_offset to source font
moveBitplaneFastDistortPlain:
    move.l  #moireoffset,d5 ; this is the `rest' of the offeset, since a0 is incremented after moving
    move.l  screenpointer2,a1
    lea     moire_y,a5
    add.w   d1,d1
    move.w  (a5,d1.w),d4

    lea     disttable,a5    

    move.w  moiredistortoffset,d1       ;16
    cmp.w   #800,d1                     ;8
    blt     .noreset                    ;12
    moveq.l #0,d1
.noreset
    addq.w  #4,d1                       ;4
    add.w   d1,a5                       ;8
    move.w  d1,moiredistortoffset       ;16


; d0 : x-offset
; d1,d2 taken,          
    move.l #80,a4
    lea     moire_x,a2  
    lea     moirejmpsource,a6       ;4

    move.w  #199,d1             ; for comparison to see if we passed the last line

.doline
    move.w  (a5)+,d3                ; x-distortion offset, absolute
    add.w   d0,d3                   ; original x-offset added to distortion
    add.w   d3,d3   
    move.w  d4,d7
    add.w   (a2,d3.w),d7                ; determine the block offset 
    add.w   d3,d3                   ;4
    move.l  (a6,d3.w),a0                    ;12 address of the moiresource is now in a0
    add.w   d7,a0               ; 8 cycle
offset set 6
        REPT 10             ; line has 20 blocks
            move.l  (a0)+,offset(a1)                    ;a0 has done +, so thats +18*2 = +36        
offset set offset+16
        ENDR
        add.w   #160,a1
    add.w   a4,d4
    dbra    d1,.doline
    rts

; ********** copy bitplane code **********
; a0 is target data register
; d0 is bitplanedata
initBitplanesNew
        lea     moiresource0,a1
        jsr     prepareMoireSource

        jmp     initBitplanesNewCont
initBitplanes:
initBitplanesNewCont
        lea     moiresource0,a0
        lea     moiresource1,a1
        jsr     prepareMoireSource

        lea     moiresource1,a0
        lea     moiresource2,a1
        jsr     prepareMoireSource

        lea     moiresource2,a0
        lea     moiresource3,a1
        jsr     prepareMoireSource

        lea     moiresource3,a0
        lea     moiresource4,a1
        jsr     prepareMoireSource

        lea     moiresource4,a0
        lea     moiresource5,a1
        jsr     prepareMoireSource

        lea     moiresource5,a0
        lea     moiresource6,a1
        jsr     prepareMoireSource

        lea     moiresource6,a0
        lea     moiresource7,a1
        jsr     prepareMoireSource

        lea     moiresource7,a0
        lea     moiresource8,a1
        jsr     prepareMoireSource

        lea     moiresource8,a0
        lea     moiresource9,a1
        jsr     prepareMoireSource

        lea     moiresource9,a0
        lea     moiresource10,a1
        jsr     prepareMoireSource

        lea     moiresource10,a0
        lea     moiresource11,a1
        jsr     prepareMoireSource

        lea     moiresource11,a0
        lea     moiresource12,a1
        jsr     prepareMoireSource

        lea     moiresource12,a0
        lea     moiresource13,a1
        jsr     prepareMoireSource

        lea     moiresource13,a0
        lea     moiresource14,a1
        jsr     prepareMoireSource

        lea     moiresource14,a0
        lea     moiresource15,a1
        jsr     prepareMoireSource

        move.l  #0,moirepathcounter

    rts

; a0 sprite source
; a1 sprite target  
prepareMoireSource:
    moveq.l #0,d5
    roxl.l  #1,d5


    add.w   #32000,a0
    add.w   #32000,a1
    move.w  #400-1,d7       ; y-loop        200*20 = 4000 (*4 bytes)
.loopy
        REPT 20
        move.l  -(a0),d0
        roxl.l  #1,d0       ; shift bit out
        move.l  d0,-(a1)
        ENDR
    dbra    d7,.loopy
    rts


pathpointer1
    dc.l    0

pathpointer2
    dc.l    0

doMoire:

    raster  #$700
    move.l  pathpointer1,a6
;    lea     path1,a6
    add.w   moirepathcounter,a6
    move.l  (a6)+,d0
    move.l  (a6),d1
    moveq.l #0,d2
    move.w  currentStep,d3
    jsr     moveBitplaneFast2

    raster  #$007
    move.l  pathpointer2,a6
;    lea     path2,a6
    add.w   moirepathcounter,a6
    move.l  (a6)+,d0
    move.l  (a6),d1         
    moveq.l #2,d2
    jsr     moveBitplaneNormal

    move.w  moirepathcounter,d0      
    addq.w  #8,d0
    cmp.w   #pathlength,d0
    blt     .cont1
    move.w  #0,d0
.cont1
    move.w  d0,moirepathcounter
    rts


doMoireDist:
    move.l  pathpointer1,a6
    add.w   moirepathcounter,a6
    move.l  (a6)+,d0
    move.l  (a6),d1
    moveq.l #0,d2
    move.w  currentStep,d3
    jsr     moveBitplaneFastDistortPlain

    move.l  pathpointer2,a6
    add.w   moirepathcounter,a6
    move.l  (a6)+,d0
    move.l  (a6),d1         
    moveq.l #2,d2
    jsr     moveBitplaneNormal

    move.w  moirepathcounter,d0      
    addq.w  #8,d0
    cmp.w   #pathlength,d0
    blt     .cont1
    move.w  #0,d0
.cont1
    move.w  d0,moirepathcounter
    rts


; a0 address of moire source
; a1 address of the target screen address
; d0 x_offset to source font
; d1 y_offset to source font
moveBitplaneFast2:
;   pushall 

    move.l  #moireoffset,d5 ; this is the `rest' of the offeset, since a0 is incremented after moving
    move.l  screenpointer2,a1

    lea     moirejmpsource,a6
    add.w   d0,d0
    move.w  d0,d3
    add.w   d0,d0
    add.w   d0,a6
    move.l  (a6),a0

    lea     moire_x,a4
    add.w   (a4,d3.w),a0
        
    lea     moire_y,a5
        
    add.w   d1,d1
    move.w  (a5,d1.w),d4
    add.w   d4,a0           ; add y-offset
    
    ; use: d1,d2,a0,a1,d5
    ; thus: a2,a3,a4,a5,a6
    ;       d0,d3,d4,d6,d7
    add.w   #6,a1
    move.w  #200/4-1,d7

.doline
    REPT 4
offset set 0
        REPT 20/2               ; line has 20 blocks
        move.l  (a0)+,offset(a1)                    ;a0 has done +, so thats +18*2 = +36        
offset set offset+16
        ENDR
    add.w   #160,a1
    add.w   #40,a0
    ENDR
    dbra    d7,.doline
    rts

; a0 address of moire source
; a1 address of the target screen address
; d0 x_offset to source font
; d1 y_offset to source font
moveBitplaneNormal:
    move.l  screenpointer2,a1

    add.l   d2,a1   ; take the offset into account
    move.w  #40,d5

    lea     moirejmpsource,a6
    add.w   d0,d0
    move.w  d0,d3
    add.w   d0,d0
    add.w   d0,a6
    move.l  (a6),a0

    lea     moire_x,a4
    add.w   (a4,d3.w),a0
    lea     moire_y,a5
    add.w   d1,d1
    add.w   (a5,d1.w),a0                

    move.l  #200/2-1,d7 
.doline
    REPT 2
offset set 0
        REPT 20             ; line has 20 blocks
        move.w  (a0)+,offset(a1)        ;   16*20 = 320
offset set offset+8
        ENDR
        add.w   #40,a0
        add.w   #160,a1
    ENDR
    dbra    d7,.doline

    rts

;;;;;;;;;;;;; END MOIRE SUPPORT ;;;;;;;;;;;;;;
;;;;;;;;;;;;; START DRAGONPIC ;;;;;;;;;;;;;;;;
dragon
.init
    lea     $ffff8240,a0
    rept 8
        move.l  #0,(a0)+
    ENDR

    lea     dragonpic+34,a0
    move.l  screenpointer,a1
    move.l  screenpointer2,a2
    move.w  #200*20-1,d7
.copyblock
        move.l  (a0),(a1)+
        move.l  (a0)+,(a2)+
        move.l  (a0),(a1)+
        move.l  (a0)+,(a2)+
    dbra    d7,.copyblock


    move.w  #250,waitcounter
    move.w  #5,fadecounter
.mainloop
    wait_for_vbl

    subq.w  #1,fadecounter
    bne     .cont
    lea     dragonpic+2,a0
    lea     $ffff8240,a1
    jsr     doFade
    move.w  #5,fadecounter
.cont
            check_for_spacebar_to_exit
    sub.w   #1,waitcounter
    bne     .mainloop


    jsr initClearPixels
    jsr preCalcSineX
    jsr preCalcSineY
    st  sineDotsInit




                movea.l screenpointer,A0      ; for the bars coming from right
                movea.l A0,A1
                lea     50*160(A1),A1   ; for the bars coming from left
                lea     153(A1),A1

                move.w  #$FF,D1         ; fill pattern for deleting the pic
                move.b  #13,fadeflag     ; load fadecounter (wait at first run)

                lea     fadecolors2,A2   ; point to fading tab


                move.w  #20-1,D0
delete_loop:    bsr     sub_wvbl
                bsr     sub_wvbl
                bsr     load_palette

                bsr     kill_squares
                addq.l  #1,A0           ; upper delete: point to next byte
                subq.l  #1,A1           ; lower delete: point to next byte

                bsr     sub_wvbl
                bsr     sub_wvbl

                bsr     kill_squares
                addq.l  #7,A0           ; upper delete; point to next word
                subq.l  #7,A1           ; lower delete: point to next word

                dbra    D0,delete_loop



    move.l  screenpointer,a0
    jsr     clearScreen4bpl
    move.l  screenpointer2,a0
    jsr     clearScreen4bpl

    jmp     dragon_nextscene


;;;;;;;;;
fadeflag:       DS.W 1

fadecolors2:    
                DC.W $0466,$0532,$0411,$0122,$0232,$0342,$0452,$0663,$0200,$0300,$0411,$0532,$0356,$0742,$0345,$0111
                DC.W $0BDD,$0CA9,$0B88,$0899,$09A9,$0AB9,$0BC9,$0DDA,$0900,$0A00,$0B88,$0CA9,$0ACD,$0EB9,$0ABC,$0888
                DC.W $0355,$0421,$0300,$11,$0121,$0231,$0341,$0552,$0100,$0200,$0300,$0421,$0245,$0631,$0234,$00
                DC.W $0ACC,$0B98,$0A00,$88,$0898,$09A8,$0AB8,$0CC9,$0800,$0900,$0A00,$0B98,$09BC,$0DA8,$09AB,$00
                DC.W $0244,$0310,$0200,$00,$10,$0120,$0230,$0441,$00,$0100,$0200,$0310,$0134,$0520,$0123,$00
                DC.W $09BB,$0A80,$0900,$00,$80,$0890,$09A0,$0BB8,$00,$0800,$0900,$0A80,$08AB,$0C90,$089A,$00
                DC.W $0133,$0200,$0100,$00,$00,$10,$0120,$0330,$00,$00,$0100,$0200,$23,$0410,$12,$00
                DC.W $08AA,$0900,$0800,$00,$00,$80,$0890,$0AA0,$00,$00,$0800,$0900,$9A,$0B80,$89,$00
                DC.W $22,$0100,$00,$00,$00,$00,$10,$0220,$00,$00,$00,$0100,$12,$0300,$01,$00
                DC.W $99,$0800,$00,$00,$00,$00,$80,$0990,$00,$00,$00,$0800,$89,$0A00,$08,$00
                DC.W $11,$00,$00,$00,$00,$00,$00,$0110,$00,$00,$00,$00,$01,$0200,$00,$00
                DC.W $88,$00,$00,$00,$00,$00,$00,$0880,$00,$00,$00,$00,$08,$0900,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0100,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0800,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                DC.W -1

load_palette:   tst.b   fadeflag
                bne.s   no_fade

                pushall
                
                lea     brownPalette,a0
                lea     $ffff8240,a1
                jsr     doFade
                move.b  #1,fadeflag

                popall

no_fade:        subq.b  #1,fadeflag

                rts

brownPalette
    rept 16
        dc.w    $210
    endr


kill_squares:
o               SET 0

                REPT 50
                or.b    D1,o+0(A0)
                or.b    D1,o+0(A1)
                or.b    D1,o+2(A0)
                or.b    D1,o+2(A1)
                or.b    D1,o+4(A0)
                or.b    D1,o+4(A1)
                or.b    D1,o+6(A0)
                or.b    D1,o+6(A1)
o               SET o+160

                ENDR

                lea     160*100(A0),A0
                lea     160*100(A1),A1

o               SET 0

                REPT 50

                or.b    D1,o+0(A0)
                or.b    D1,o+0(A1)
                or.b    D1,o+2(A0)
                or.b    D1,o+2(A1)
                or.b    D1,o+4(A0)
                or.b    D1,o+4(A1)
                or.b    D1,o+6(A0)
                or.b    D1,o+6(A1)
o               SET o+160

                ENDR

                lea     -160*100(A0),A0
                lea     -160*100(A1),A1

                rts










    move.w  #80,waitcounter
    move.w  #40,fadecounter
.deinit
            wait_for_vbl
            nop
            nop

    subq.w  #1,fadecounter
    bne     .nofade
        lea     blackPalette,a0
        lea     $ffff8240,a1
        jsr     doFade
        move.w  #6,fadecounter
.nofade
            check_for_spacebar_to_exit
    subq.w  #1,waitcounter
    bne .deinit


    move.l  screenpointer,a0
    jsr     clearScreen4bpl
    move.l  screenpointer2,a0
    jsr     clearScreen4bpl

    jmp     dragon_nextscene



;;;;;;;;;;;;; END DRAGONPIC ;;;;;;;;;;;;;;;;;;
;;;;;;;;;; START SINEDOTS ;;;;;;;;;;
sineDotsInit
    dc.w    0

sinedots
.init
    move.w   #$210,d0
    lea     $ffff8240,a0
    move.w  #16-1,d7

.clearcolour
        move.w  d0,(a0)+
    dbra    d7,.clearcolour

    move.l  screenpointer,a0
    jsr     clearScreen4bpl
    move.l  screenpointer2,a0
    jsr     clearScreen4bpl

    move.l  #default_vbl,a0
    move.l  #rte_timerb,a1
    jsr     install_vbl_hbl


    move.l  #1*256,sineDotsaddX1
    move.w  #3,sineDotsaddX2
    move.w  #3,sineDotsaddY1
    move.w  #1,sineDotsaddY2
    move.w  #2,sineDotsaddY3

    move.w  #1220,waitcounter

    ;135 frames
;        framecount_start
    tst sineDotsInit
    bne .initDone
    jsr initClearPixels
    jsr preCalcSineX
    jsr preCalcSineY
.initDone
;        framecount_stop

    move.w  #$210,$ffff8240
    move.w  #$742,$ffff8242
    move.w  #$210,$ffff8244
    move.w  #$742,$ffff8246
    move.w  #$210,$ffff8248
    move.w  #$742,$ffff824A

.mainloop
            wait_for_vbl
            swapscreens
            swappixelpointers


            rasterq #$000
    jsr     sineDots2

    jsr     clearPixels
            rasterq #$070
    jsr     doCredits
            rasterq #$700

    move.w  creditsPartDone,d0
    bne     .waitorgo

.waitorgo
            check_for_spacebar_to_exit
    subq.w  #1,waitcounter
    bne     .mainloop


.deinit
    move.w  #80,waitcounter
    move.w  #8,fadecounter
.fadeout

        wait_for_vbl
        swapscreens
        swappixelpointers

    sub.w   #1,fadecounter
    bne     .skip2
    lea     blackPalette,a0
    lea     $ffff8240,a1
    jsr     doFade
    move.w  #8,fadecounter
.skip2

    jsr     sineDots2
    jsr     clearPixels

            check_for_spacebar_to_exit
    sub.w   #1,waitcounter
    bne     .fadeout

    move.l  screenpointer,a0
    jsr     clearScreen4bpl
    move.l  screenpointer2,a0
    jsr     clearScreen4bpl

    jmp     sinedots_nextscene

;;;;;;;;;;;;;;;;;;;;; SINEDOTS MAINCODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rte_timerb
    rte

initClearPixels
    move.l  screenpointer2,d0
    lea     pixels,a1
    lea     pixels2,a2
    move.l  a1,pixelpointer
    move.l  a2,pixelpointer2
    move.l  #number_of_pixels-1,d7
.initPixel
    move.l  d0,(a1)+
    move.l  d0,(a2)+
    dbra    d7,.initPixel
    rts

clearPixels 
    move.w  #number_of_pixels/50-1,d7                                                           ;4
    move.l  pixelpointer2,a0                                                                        ;6
    moveq   #0,d0                                                                               ;2
    move.l  a7,savedA7                                                                          ;6
.clearWord
    REPT 7
        movem.l (a0)+,a1-a7         ;68         ;52                                             ;4
        move.w  d0,(a1)             ;42         ;40     --> 94*10 = 940 18.8                    ;2   =====> (7*8 + 7* 68)* 7 + 8 + 12 = 552
        move.w  d0,(a2)                                                                         ;2   alt => 3* 14 + 8
        move.w  d0,(a3)                                                                         ;2  14:  68 + 14*16 = 876
        move.w  d0,(a4)                                                                         ;2
        move.w  d0,(a5)                                                                         ;2
        move.w  d0,(a6)                                                                         ;2
        move.w  d0,(a7)                                                                         ;2 --> 18 * 7 = 70+56 = 126 , and with .w vals ?
    ENDR
        move.l  (a0)+,a1            ;12                                                         ;2
        move.w  d0,(a1)             ;8      -> per 50: 7*110+20 = 790 = 15,8 cycle per dot      ;2 --> 130

    dbra    d7,.clearWord
    move.l  savedA7,a7
    rts

preCalcSineX
    lea     preSineX,a0
    lea     mulperiod256,a1 ;   this is lower
    move.l  a1,a4
    lea     x_offset_430,a2     ;   this is upper
    lea     x_mask_offset,a3

    move.l  #256*2,d5
    move.l  #430*2,d4
    move.w  #160,d2
.outerloop
    move.l  d5,d6
    move.l  a4,a1
.innerloop
.calciter
        move.w  (a1)+,d3
        muls    (a2),d3
        swap    d3
        add.w   d2,d3           ; add 160
        add.w   d3,d3           ; do *4 for offset
        add.w   d3,d3           ; ^^
        move.l  (a3,d3.w),(a0)+ ; move the longword from the x_mask (word)+ offset (word)
        subq    #2,d6
        bne     .innerloop

    add.w   #2,a2
    subq.w  #2,d4
    bne     .outerloop
    rts

preCalcSineY
    lea     preSineY,a0
    lea     y1_off60,a3     ;   this is lower
    lea     mulperiod256,a2 ;   this is upper

    lea     y_block,a6

    move.l  #256*2,d5
    move.l  #256*2,d4
    moveq   #0,d3
    move.w  #99,d2
.outerloop
    move.l  d5,d6
    move.l  a3,a1
.innerloop
        move.w  (a1)+,d3        ; load off60 (val1) value in d3
        muls    (a2),d3     ; multiply the mulperiod190 (val2) with val1
        swap    d3                  ; get the integer part
        add.w   d2,d3               ; add 99 (middle-y)

            add.w   d3,d3               ; 4
            move.w  (a6,d3.w),d3        ; 16
        move.w  d3,(a0)+
        subq.w  #2,d6
        bne     .innerloop

    add.w   #2,a2
    subq.w  #2,d4
    bne     .outerloop
    rts

sineDots2
;   move.l  a7,savedA7

    ; save screen pointer to usp, 4 cycles innerloop
    move.l  screenpointer2,a0
    move.l  a0,usp
    ; constant 256 for addition
    move.l  #256,a2
    ; save address for pixels
    move.l  pixelpointer,a3
    ; premulted sine values for x: sine1 * sine2
    lea     preSineX,a4
    ; constatnt for comparisson
    move.l  #430*256,a5
    ; ofset values for sine1 * sine2 + offset
    lea     y2_off39,a6         ;   8       ; this needs *160
    ; premulted sine values for y: sine1 * sine2
    lea     preSineY,a1

    move.l  sineDotsCounterX,d7     ; upper val x
    moveq   #0,d2
    move.w  sineDotsCounterX2,d2    ; lower val x
    move.w  sineDotsCounterY,d6
    move.w  sineDotsCounterY2,d1
    add.w   d1,d1
    move.w  sineDotsCounterY3,d4
    lsl     #8,d4
    
    move.l  #number_of_pixels/50-1,d5




.loop   
    ;   d0.l; totaloffset + pixelmask       a0; screenpointer
    ;   d1.w; offset for y-39 add           a1; y_offset multable
    ;   d2.w; x-off lower off               a2; #256 for upper-value addition
    ;   d3;     local var for multable      a3; clearpixel list
    ;   d4; y-off upper off                 a4; x_offset + mask table
    ;   d5; loop register                   a5; #256*430 for comparison
    ;   d6; y-off lower off                 a6; y_off39 table
    ;   d7; x-off upper off                 a7; 
    REPT 50
;;;;;;; determine x,y values 
;;;;;;;;;; get x
    move.l  d7,d3                   ;   4               ; put upper value
    or.b    d2,d3                   ;   4               ; lower value
;    add.l   d3,d3                   ;   8               ; offset *4
;    add.l   d3,d3                   ;   8
    lsl.l     #2,d3   
    move.l  (a4,d3.l),d0            ;   20  --> 44      ; move.l mask + offset to d0    from multable

;;;;;;;;;; get y
    move.l  d4,d3                   ;   4               ; put upper value
    or.b    d6,d3                   ;   4               ; lower value
    add.l   d3,d3                   ;   8               ; offset *2
    add.w   (a1,d3.l),d0            ;   16              ; add to offset  from multable
    add.w   (a6,d1.w),d0            ;   16  --> 48      ; and the actual 39 offset as well

;;;;;;; putpixel
    move.l  usp,a0                  ;   4               ; grab screenpointer
    add.w   d0,a0                   ;   8               ; add total offset to screenpointer
    move.l  a0,(a3)+                ;   12              ; save known address for clearing
    swap    d0                      ;   4               ; swap to mask
    or.w    d0,(a0)                 ;   12  --> 36   (92+36=128)    ; or mask into screen
;;;;;;; end putpixel

    ;;;; Y OFFSETS
    addq.b  #3,d6                   ;   4   lower x value   ; add 3 to offset, since its byte, it autowraps
    add.w   a2,d4                   ;   4   upper x value   ; add #256 to offset, since its word it autowraps
    addq.w  #6,d1                   ;   4   y-39 offset     ; add 6 to offset, it doesnt autowrap, so we have a multiple rept on the include of the data

    ;;;; X OFFSET
    add.l   a2,d7                   ;   8                   ; add 256 to offset, but no autowrap, the period is not 256 but 430-something
    cmp.l   a5,d7                   ;   6                   ; check if we need to wrap
    blt     *+4                     ;   12                  ; if we need to wrap, gogo
    sub.l   a5,d7                                           ; correct for wrap

    addq.b  #2,d2                   ;   4   --> 128 + 42 = 160  ; add 2 to offset, byte offset, so we autowrap

    ENDR
    dbra    d5,.loop


;;;;;;; end stuff; increase counters for movement
    move.l  sineDotsCounterX,d0     ;12
    add.l   sineDotsaddX1,d0            ;   add.l   #1*256,d0                   ;4
    bge     .cont1
    add.l   a5,d0
.cont1
    cmp.l   a5,d0                           ;   cmp.l   #430*256,d0                 ;8
    blt     .endX                   ;12
    sub.l   a5,d0                           ;   sub.l   #430*256,d0                 ;4
.endX
    move.l  d0,sineDotsCounterX     ;16


    move.w  sineDotsCounterX2,d0    ;12
    add.w   sineDotsaddX2,d0            ;4
    cmp.w   a2,d0                   ;8      ;   cmp.w   #256,d0                 ;8
    blt     .endX2                  ;12
    sub.w   a2,d0                   ;4      ;   sub.w   #256,d0                 ;4
.endX2
    move.w  d0,sineDotsCounterX2    ;16


    move.w  sineDotsCounterY,d0     ;12
    add.w   sineDotsaddY1,d0                    ;4
    cmp.w   a2,d0                   ;8      ;   cmp.w   #256,d0                 ;8
    blt     .endY                   ;12
    sub.w   a2,d0                   ;4      ;   sub.w   #256,d0                 ;4
.endY
    move.w  d0,sineDotsCounterY     ;16


    move.w  sineDotsCounterY2,d0    ;12
    add.w   sineDotsaddY2,d0                    ;4
    cmp.w   #460,d0                 ;8      ;   cmp.w   #256,d0                 ;8
    blt     .endY2                  ;12
    sub.w   #460,d0                 ;4      ;   sub.w   #256,d0                 ;4
.endY2
    move.w  d0,sineDotsCounterY2    ;16


    move.w  sineDotsCounterY3,d0    ;12
    add.w   sineDotsaddY3,d0                    ;4
    cmp.w   a2,d0                   ;8      ;   cmp.w   #256,d0                 ;8
    blt     .endY3                  ;12
    sub.w   a2,d0                   ;4      ;   sub.w   #256,d0                 ;4
.endY3
    move.w  d0,sineDotsCounterY3    ;16

    rts

doCredits
    move.w  creditsState,d0
    blt     .copyPart
    beq     .fadeIn
    ; here we are waiting
    move.w  credsWaiting,d0
    bne     .fadeout
    ; if we are here, we are waiting
    move.w  credWaitCounter,d0
    subq.w  #1,d0
    beq     .donewaiting
    move.w  d0,credWaitCounter
    rts

.donewaiting
    move.w  #1,credsWaiting
    rts

.fadeout
    tst.w   taskFade
    bne     .taskFadeOut
    lea     credFade,a0
    move.w  credFadeCounter,d0
    move.w  (a0,d0.w),$ffff8244

    cmp.w   #66,d0
    bge     .donefadeout
    addq.w  #2,d0
    move.w  d0,credFadeCounter
    rts
.donefadeout
    st      taskFade
.taskFadeOut
    lea     credFade,a0
    move.w  taskFadeCounter,d0
    move.w  (a0,d0.w),$ffff8248
    cmp.w   #66,d0
    bge     .doneFadeOutTask
        addq.w  #2,d0
        move.w  d0,taskFadeCounter
        rts
.doneFadeOutTask
    move.w  creditspointer,d0
    cmp.w   #16,d0
    beq     .creditspartdone
    addq.w  #4,creditspointer

    move.w  #0,taskFade
    move.w  #0,taskFadeCounter
    move.w  #-1,creditsState
    move.w  #150,credWaitCounter
    move.w  #0,credFadeCounter
    move.w  #0,credsWaiting
    asr     #1,d0
    lea     jmpchange,a0
    jmp     (a0,d0.w)   

    rts

.creditspartdone
    move.w  #1,creditsPartDone

    rts
.end
    rts

.fadeIn
    tst     taskFade
    bne     .taskFade
    lea     credFade,a0
    move.w  credFadeCounter,d0
    move.w  (a0,d0.w),$ffff8244

            ; use this time to also move in the credits

            move.w  creditsCopyPartCounter,d2   ; its x10
            cmp.w   #40,d2
            beq     .skipload

            move.w  creditspointer,d1
            lea     creditstypelist,a0
            move.l  (a0,d1.w),a0

            move.l  screenpointer,a1
            move.l  screenpointer2,a2

            add.w   #0+159*160,a1
            add.w   #0+159*160,a2

            move.w  d2,d1
            move.w  d2,d3

            muls    #160,d1

            add.w   d1,a1
            add.w   d1,a2

            muls    #24,d3
            add.w   d3,a0

o           SET 4
            REPT 10
            REPT 12
                move.w  (a0),o(a1)
                move.w  (a0)+,o(a2)
o               SET     o+8
            ENDR
o               SET     o+64
            ENDR

            add.w   #10,creditsCopyPartCounter

.skipload
    cmp.w   #36,d0
    bge     .donefadein
    ; add to acounter
    addq.w  #2,d0
    move.w  d0,credFadeCounter
    rts
.donefadein
    st      taskFade
    ; now we fade in credits
.taskFade
    lea     credFade,a0
    move.w  taskFadeCounter,d0
    move.w  (a0,d0.w),$ffff8248
    cmp.w   #36,d0
    bge     .doneFadeInTask
        addq.w  #2,d0
        move.w  d0,taskFadeCounter
        rts
.doneFadeInTask
    move.w  #0,creditsCopyPartCounter
    addq.w  #1,creditsState
    move.w  #0,taskFade
    rts


.copyPart
    move.w  creditspointer,d0
    lea     creditssourcelist,a0
    move.l  (a0,d0.w),a0
    move.l  screenpointer,a1
    move.l  screenpointer2,a2

    move.w  creditsCopyPartCounter,d0
    move.w  d0,d3
    muls    #40,d0      ; offset from source
    move.w  d0,d1       ; 
    add.w   d1,d1       ; *2
    add.w   d1,d1       ; *2 = 160, offset from target

    add.w   d0,a0
    add.w   d1,a1
    add.w   d1,a2

o   SET 2
    REPT 5*20
        move.w  (a0),o(a1)
        move.w  (a0)+,o(a2)
o       SET     o+8
    ENDR

    addq.w  #5,d3
    cmp.w   #65,d3
    blt     .notdone
        addq.w  #1,creditsState
        move.w  #0,creditsCopyPartCounter
        move.w  #0,taskFade
    rts
.notdone
    move.w  d3,creditsCopyPartCounter
    rts

taskFadeCounter
    dc.w    0
taskFade
    dc.w    0

jmpchange
    jmp spkr_change
    jmp mod_change
    jmp jok_change
    jmp actodi_change

spkr_change
    move.l  #768,sineDotsaddX1
    move.w  #10,sineDotsaddX2
    move.w  #12,sineDotsaddY1
    move.w  #7,sineDotsaddY2
    move.w  #4,sineDotsaddY3
    rts
mod_change
    move.l  #2*256,sineDotsaddX1
    move.w  #4,sineDotsaddX2
    move.w  #2,sineDotsaddY1
    move.w  #1,sineDotsaddY2
    move.w  #2,sineDotsaddY3

    rts
jok_change
    move.l   #-1*256,sineDotsaddX1
    sub.w   #3,sineDotsaddX2
    add.w   #4,sineDotsaddY1
    add.w   #9,sineDotsaddY2
    add.w   #4,sineDotsaddY3
    rts
actodi_change
    move.l  #3*256,sineDotsaddX1
    move.w  #2,sineDotsaddX2        
    move.w  #4,sineDotsaddY1        
    move.w  #4,sineDotsaddY2        
    move.w  #2,sineDotsaddY3        
    rts
;;;;;;;;;;;;;;;; END SINEDOTS DATA ;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; START WORSHIP CODE ;;;;;;;;;;;;;;;;;;;;;
worship
.deinit
    jsr music+4
    jsr worshipsound+0
    jsr worshipsound+8
.init
                move.l  #worship_vbl,a0
                move.l  #dummy,a1
                jsr     install_vbl_hbl 

                move.l  screenpointer,scr_adr1
                move.l  screenpointer2,scr_adr2

                move.l  #screen3,D0     ; worship
                clr.b   D0
                move.l  D0,scr_adr3

                move.l  #screen4,D0     ; the
                clr.b   D0
                move.l  D0,scr_adr4

                move.l  #screen5,D0     ; ashes
                clr.b   D0
                move.l  D0,scr_adr5

                lea     $FFFF8240,A0
                moveq   #16-1,D0
.blackpal_loop:  
                move.w  #0,(A0)+
                dbra    D0,.blackpal_loop

                ;; dont
                movea.l scr_adr2,A0
                lea     dont_pic,A1
                bsr     copy_data
                movea.l scr_adr2,a0
                lea     hejdub,a1
o               SET 2+176*160
                REPT 23
                    REPT 4
                        move.w  (a1)+,o(a0)
o                       SET     o+8
                    ENDR
o                   SET o+160-4*8
                ENDR
                ;; worship
                movea.l scr_adr3,A0
                lea     worsh_pic,A1
                bsr     copy_data
                movea.l scr_adr3,a0
                lea     hejdub,a1
o               SET 2+176*160
                REPT 23
                    REPT 4
                        move.w  (a1)+,o(a0)
o                       SET     o+8
                    ENDR
o                   SET o+160-4*8
                ENDR
                ;; the 
                movea.l scr_adr4,A0
                lea     the_pic,A1
                bsr     copy_data
                movea.l scr_adr4,a0
                lea     hejdub,a1
o               SET 2+176*160
                REPT 23
                    REPT 4
                        move.w  (a1)+,o(a0)
o                       SET     o+8
                    ENDR
o                   SET o+160-4*8
                ENDR
                ;; ashes
                movea.l scr_adr5,A0
                lea     ashes_pic,A1
                bsr     copy_data
                movea.l scr_adr5,a0
                lea     hejdub,a1
o               SET 2+176*160
                REPT 23
                    REPT 4
                        move.w  (a1)+,o(a0)
o                       SET     o+8
                    ENDR
o                   SET o+160-4*8
                ENDR
                move.l  scr_adr1,D0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w

                bsr     sub_wvbl


.mainloop

                lea     first_fade,A0
                move.l  A0,firstfade_pos ; save infader palette position

part_left2mid:  lea     worship_pic+34,A0
                movea.l scr_adr1,A1

                moveq   #0,D0           ; schlz„: anzahl diagonaler k„stchen
                moveq   #20-1,D1        ; schlz„: h”chstens 20 hor.k„st.(320/16)

                move.l  A0,pic_start    ; zeiger auf grafikdaten sichern
                addi.l  #8,pic_start    ; auf n„chstes wort rechts ausrichten

                move.l  A1,square_start ; zeiger auf bildschirm sichern
                addi.l  #8,square_start ; auf n„chstes wort rechts ausrichten

squdraw_outloop:

squdraw_loop:

o               SET 0

                REPT 10
                move.w  o*160+0(A0),o*160+0(A1) ; jeweils vier planes
                move.w  o*160+2(A0),o*160+2(A1)
                move.w  o*160+4(A0),o*160+4(A1)
                move.w  o*160+6(A0),o*160+6(A1)
o               SET o+1         ;               ; von insgesamt 1o zeilen
                ENDR

                lea     10*160(A0),A0   ; grafikdaten-zeiger 1o zeilen nach unten
                lea     -8(A0),A0       ; und links

                lea     10*160(A1),A1   ; bildschirm-zeiger 1o zeilen nach unten
                lea     -8(A1),A1       ; und links

                dbra    D0,squdraw_loop

                bsr     sub_wvbl
                bsr     sub_wvbl
                bsr     sub_wvbl

                addi.w  #1,blockanzahl  ; schlz„ fr n„chsten durchgang erweitern
                move.w  blockanzahl,D0  ; schlz„ setzen

                movea.l pic_start,A0    ; zeiger auf grafikdaten holen
                addi.l  #8,pic_start    ; auf n„chstes wort rechts ausrichten

                movea.l square_start,A1 ; zeiger auf bildschirm holen
                addi.l  #8,square_start ; auf n„chstes wort rechts ausrichten

                bsr     sub_infade

                dbra    D1,squdraw_outloop


part_mid2right: moveq   #20-1,D0        ; schlz„: diagonale k„stchen
                moveq   #19-1,D1        ; schlz„: vertikale k„stchen
                move.w  #20,blockanzahl ; z„hler neu initialisieren

squdraw_outloop2:

squdraw_loop2:

o               SET 0

                REPT 10
                move.w  o*160+0(A0),o*160+0(A1) ; jeweils vier planes
                move.w  o*160+2(A0),o*160+2(A1)
                move.w  o*160+4(A0),o*160+4(A1)
                move.w  o*160+6(A0),o*160+6(A1)
o               SET     o+1         ;               ; von insgesamt 1o zeilen
                ENDR

                lea     10*160(A0),A0   ; grafikdaten-zeiger 1o zeilen nach unten
                lea     -8(A0),A0       ; und links

                lea     10*160(A1),A1   ; bildschirm-zeiger 1o zeilen nach unten
                lea     -8(A1),A1       ; und links

                dbra    D0,squdraw_loop2

                bsr     sub_wvbl
                bsr     sub_wvbl
                bsr     sub_wvbl

                subi.w  #1,blockanzahl  ; schlz„ fr n„chsten durchgang verringern
                move.w  blockanzahl,D0  ; schlz„ setzen

                movea.l pic_start,A0    ; zeiger auf grafikdaten holen
                addi.l  #10*160,pic_start ; 1o zeilen runten setzen

                movea.l square_start,A1 ; zeiger auf bildschirm holen
                addi.l  #10*160,square_start ; 1o zeilen runter setzen

                dbra    D1,squdraw_outloop2

                bra.s   part_flashfade

; ****************************************

sub_infade:     movem.l D0-A0,-(SP)

                move.l  firstfade_pos,A0 ; get pointer to infader palette
                tst.w   (A0)            ; end of the table?
                bmi.s   stop_fadein

getnewpal1:     movem.l (A0)+,D0-D7     ; get colors
                movem.l D0-D7,$FFFF8240.w

                bsr     sub_wvbl
                bsr     sub_wvbl

                move.l  A0,firstfade_pos ; save pointer

stop_fadein:    movem.l (SP)+,D0-A0
                rts

firstfade_pos:  DC.L 1

; *********************************************

part_flashfade:
                REPT 25
                bsr     sub_wvbl        ; **** !
                ENDR

restart_fade:   lea     worship_colors,A0
                move.w  #14,color_flag

                movem.l (A0)+,D0-D7
                movem.l D0-D7,$FFFF8240.w ; hole weiže palette

                movea.l scradr_table,A1

                move.w  scradr_counter,D0

                move.l  0(A1,D0.w),D0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w

                addi.w  #4,scradr_counter

                bsr     sub_wvbl

                move.w  #0,$FFFF8242.w  ;1
                move.w  #$776,$ffff8244

                bsr     sub_wvbl
                bsr     sub_wvbl

                move.l  scr_adr1,D0     ; zeige worship
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                bsr     sub_wvbl


color_loop:     movem.l (A0)+,D0-D7
                movem.l D0-D7,$FFFF8240.w

                REPT 2
                bsr     sub_wvbl
                ENDR

                subi.w  #1,color_flag
                tst.b   color_flag
                bmi.s   .cont

                bra.s   color_loop

.cont:        

                REPT 20
                bsr     sub_wvbl
                ENDR

                subi.w  #1,flash_counter
                tst.w   flash_counter
                bmi.s   stop_flash

                bra     restart_fade

stop_flash:     lea     last_fade,A0

getnewpal:      movem.l (A0)+,D0-D7
                movem.l D0-D7,$FFFF8240.w
                bsr.s   sub_wvbl
                bsr.s   sub_wvbl

                tst.w   (A0)
                beq.s   stop_all

                bra.s   getnewpal


stop_all:       
                movea.l scr_adr1,A0
                bsr.s   sub_clrscr

                move.w  #25,waitcounter

.wait
                wait_for_vbl
                subq.w  #1,waitcounter
                bne     .wait


part_endraster: move    #$2700,SR       ; keinen ir zulassen

                bclr    #5,$FFFFFA15.w  ; tc aus

                move.b  #1,$FFFFFA07.w  ; tb
                move.b  #1,$FFFFFA13.w  ; tb

                lea     fadecolors,A1

                move.b  #100,startline
                move.b  #1,endline

                move.l  #new_tb,$0120.w
                move.l  #new_vbl,$70.w
                move    #$2300,SR

               move.w  #150,waitcounter
.wait
                wait_for_vbl
                subq.w  #1,waitcounter
                bne     .wait

                jmp     worship_nextscene




new_vbl:        move.b  #0,$FFFFFA1B.w  ; tb aus
                addq.w  #1,$466
                move.b  startline,D0

                cmpi.w  #-1,(A1)        ; already black?
                beq.s   end_vbl_now

                jsr     worshipsound+8

                move.b  D0,$FFFFFA21.w  ; startzeile tb neu initialisieren
                move.b  #8,$FFFFFA1B.w  ; ereignisz„hlermodus
                move.l  #new_tb,$0120.w

                move.w  (A1)+,$FFFF8240.w

                rte

end_vbl_now:    
                jsr     worshipsound+4
                move.l  #new_vbl2,$70.w
                rte

new_vbl2:       move.w  #0,$FFFF8240.w
                addq.w  #1,$466
                rte

new_vbl_fade:   move.w  (A1)+,$FFFF8240.w

end_vbl:        rte

new_tb:         move    #$2700,SR       ; keine irs zulassen
                move.b  #0,$FFFFFA1B.w  ; tb aus

                move.w  #$00,$FFFF8240.w

                subi.b  #2,startline

                move.b  endline,D0
                move.b  D0,$FFFFFA21.w  ; startzeile tb neu initialisieren
                move.b  #8,$FFFFFA1B.w  ; ereignisz„hlermodus
                move.l  #new_tb2,$0120.w

                bclr    #0,$FFFFFA0F.w  ; tb beendet

                rte

new_tb2:        move    #$2700,SR       ; keine irs zulassen
                move.b  #0,$FFFFFA1B.w  ; tb aus

                addi.b  #4,endline

                move.w  -2(A1),$FFFF8240.w

                bclr    #0,$FFFFFA0F.w  ; tb beendet

                rte



copy_data       
                move.w  #200*20-1,d7
                moveq   #0,d0
.loop
                move.w  (a1)+,(a0)+
                move.w  d0,(a0)+
                move.l  d0,(a0)+
                dbra    d7,.loop
                rts

sub_showtext:   move.w  #8000/2-1,D0
showtext_loop:  move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                dbra    D0,showtext_loop

                rts

sub_clrscr:     
                move.w  #4000-1,D0
                moveq   #0,d1
clrscr_loop:    REPT 4
                move.l  d1,(A0)+
                ENDR
                dbra    D0,clrscr_loop

                rts

sub_wvbl:       clr.l   $0466.w
                nop
.wvbl_loop:     tst.l   $0466.w
                beq.s   .wvbl_loop

                rts

worship_vbl:    
    addq.w  #1,$466
    IFNE    playmusic                               
            pushall
            jsr worshipsound+8
            popall
    ENDC
        IFNE    framecount
            addq.w  #1,framecounter
        ENDC
    ;Start up Timer B each VBL
    move.w  #$2700,sr                       ;Stop all interrupts
    clr.b   $fffffa1b.w                     ;Timer B control (stop)
    bset    #0,$fffffa07.w                  ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w                  ;Interrupt mask A (Timer B)
    move.b  #0,$fffffa21.w                  ;Timer B data (number of scanlines to next interrupt)
    bclr    #3,$fffffa17.w                  ;Automatic end of interrupt
    move.b  #8,$fffffa1b.w                  ;Timer B control (event mode (HBL))
    rte   
;;;;;;;;;;;;;;;; END WORSHIP CODE ;;;;;;;;;;;;;;;;;;;;;
savedTB
    dc.l    0
evl equ 0

;;;;;;;;;;;;; START ENDPART CODE ;;;;;;;;;;;;
endpart
    move.w  #0,endPartBackgroundColor
    move.l  #endpart_vbl_tb,a0
    move.l  #rte_timerb,a1
    jsr     install_vbl_hbl 
    pushall
    jsr     endmusic+0 
    popall

.deinit
    moveq   #0,d0
    lea     $ffff8240,a0
    move.w  #16-1,d7
.clearcolour
        move.w  d0,(a0)+
    dbra    d7,.clearcolour

    move.l  screenpointer,a0
    jsr     clearScreen4bpl
    move.l  screenpointer2,a0
    jsr     clearScreen4bpl

    lea     endpartyanart,a0
    move.l  screenpointer,a1
    move.l  screenpointer2,a2
    move.l  #200*20-1,d7
.copy
        move.w  (a0),6(a1)
        move.w  (a0)+,6(a2)
        add.w   #8,a1
        add.w   #8,a2
    dbra    d7,.copy

    jsr music+4

.init
    
    jsr     prepareEndText
    jsr     prepareEndFont
    jsr     initMultable
    st      multable_calced_flag
.skipInitMultable
    jsr     init3dObject

    lea     endpal5,a0
    move.w  (a0),endPartBackgroundColor
    move.l  a0,targetPaletteAddress
    move.w  #0,fadecounter
 
.mainloop
    wait_for_vbl
    swapscreens
        move.l  clearlocpointer,d0
        move.l  clearlocpointer2,clearlocpointer
        move.l  d0,clearlocpointer2

        cmp.w   #4,fadecounter
        bne     .nofade

        move.l  targetPaletteAddress,a0
        lea     $ffff8240,a1
        jsr     doEndPartFade
        move.w  #0,fadecounter
.nofade
        add.w   #1,fadecounter


        rasterq #$700
        lea     path,a0
        add.w   currentStep,a0
        move.w  #0,d2
        move.w  (a0),d4
        move.w  #0,d6

        jsr     doRotation
        jsr     clearDots
        jsr     doSineEffectMiddle
        jsr     endPartText
        jsr     endPartProgress
        jsr     putPixels
        jsr     fujiBounce

        check_for_spacebar_to_end
    jmp .mainloop
;;;;;;;;;;;;;;;;;;;;; ENDPART CODE ;;;;;;;;;;;;
;;;;;;;;;;;; START ENDPART MAIN CODE ;;;;;;;;;;;;
endPartBackgroundColor
    dc.w    0
fadecounter
    dc.w    0

;a0 destination palette
;a1 current palette
doFade
    move.w  #16-1,d5                        ;8
    move.w  #%011100000000,d2   ; red       ;8
    move.w  #%000001110000,d3   ; green     ;8
    move.w  #%000000000111,d4   ; blue      ;8 ---> 72 setup
.doOneColor
        move.w  (a0),a2                     ;8
        move.w  (a1),a3                     ;8
    
    ;do red, d0 is target, d1 is current
        move.w  a2,d0                       ;4  
        move.w  a3,d1                       ;4
    
        and.w   d2,d0                       ;4
        and.w   d2,d1                       ;4
    
        cmp.w   d1,d0                       ;4
        beq     .redDone
        blt     .subRed
.addRed
        add.w   #%000100000000,(a1)         ;16
        jmp     .redDone
.subRed
        sub.w   #%000100000000,(a1)         ;16
.redDone

    ;do green
        move.w  a2,d0                       ;4
        move.w  a3,d1                       ;4
    
        and.w   d3,d0                       ;4
        and.w   d3,d1                       ;4
    
        cmp.w   d1,d0                       ;4
        beq     .greenDone
        blt     .subGreen
.addGreen
        add.w   #%000000010000,(a1)         ;16
        jmp     .greenDone
.subGreen
        sub.w   #%000000010000,(a1)         ;16
.greenDone

    ;do blue
        move.w  a2,d0                       ;4
        move.w  a3,d1                       ;4
    
        and.w   d4,d0                       ;4
        and.w   d4,d1                       ;4
    
        cmp.w   d1,d0                       ;4
        beq     .blueDone
        blt     .subBlue
.addBlue
        add.w   #%000000000001,(a1)         ;16
        jmp     .blueDone
.subBlue
        sub.w   #%000000000001,(a1)
.blueDone
        add.l   #2,a0                       ;8
        add.l   #2,a1                       ;8
    dbra    d5,.doOneColor
    rts 



;a0 destination palette
;a1 current palette
doEndPartFade
    move.w  #15-1,d5                        ;8
    move.w  #%011100000000,d2   ; red       ;8
    move.w  #%000001110000,d3   ; green     ;8
    move.w  #%000000000111,d4   ; blue      ;8 ---> 72 setup
;;;; first do the background color
.doOneColorBackground
        move.w  (a0),a2                     ;8
        move.w  endPartBackgroundColor,a3                     ;8
    
    ;do red, d0 is target, d1 is current
        move.w  a2,d0                       ;4  
        move.w  a3,d1                       ;4
    
        and.w   d2,d0                       ;4
        and.w   d2,d1                       ;4
    
        cmp.w   d1,d0                       ;4
        beq     .redDoneBackground
        blt     .subRedBackground
.addRedBackground
        add.w   #%000100000000,endPartBackgroundColor         ;16
        jmp     .redDoneBackground
.subRedBackground
        sub.w   #%000100000000,endPartBackgroundColor         ;16
.redDoneBackground

    ;do green
        move.w  a2,d0                       ;4
        move.w  a3,d1                       ;4
    
        and.w   d3,d0                       ;4
        and.w   d3,d1                       ;4
    
        cmp.w   d1,d0                       ;4
        beq     .greenDoneBackground
        blt     .subGreenBackground
.addGreenBackground
        add.w   #%000000010000,endPartBackgroundColor         ;16
        jmp     .greenDoneBackground
.subGreenBackground
        sub.w   #%000000010000,endPartBackgroundColor         ;16
.greenDoneBackground

    ;do blue
        move.w  a2,d0                       ;4
        move.w  a3,d1                       ;4
    
        and.w   d4,d0                       ;4
        and.w   d4,d1                       ;4
    
        cmp.w   d1,d0                       ;4
        beq     .blueDoneBackground
        blt     .subBlueBackground
.addBlueBackground
        add.w   #%000000000001,endPartBackgroundColor         ;16
        jmp     .blueDoneBackground
.subBlueBackground
        sub.w   #%000000000001,endPartBackgroundColor
.blueDoneBackground
        add.l   #2,a0                       ;8
        add.l   #2,a1                       ;8




;; now do the other 15 colors



.doOneColor
        move.w  (a0),a2                     ;8
        move.w  (a1),a3                     ;8
    
    ;do red, d0 is target, d1 is current
        move.w  a2,d0                       ;4  
        move.w  a3,d1                       ;4
    
        and.w   d2,d0                       ;4
        and.w   d2,d1                       ;4
    
        cmp.w   d1,d0                       ;4
        beq     .redDone
        blt     .subRed
.addRed
        add.w   #%000100000000,(a1)         ;16
        jmp     .redDone
.subRed
        sub.w   #%000100000000,(a1)         ;16
.redDone

    ;do green
        move.w  a2,d0                       ;4
        move.w  a3,d1                       ;4
    
        and.w   d3,d0                       ;4
        and.w   d3,d1                       ;4
    
        cmp.w   d1,d0                       ;4
        beq     .greenDone
        blt     .subGreen
.addGreen
        add.w   #%000000010000,(a1)         ;16
        jmp     .greenDone
.subGreen
        sub.w   #%000000010000,(a1)         ;16
.greenDone

    ;do blue
        move.w  a2,d0                       ;4
        move.w  a3,d1                       ;4
    
        and.w   d4,d0                       ;4
        and.w   d4,d1                       ;4
    
        cmp.w   d1,d0                       ;4
        beq     .blueDone
        blt     .subBlue
.addBlue
        add.w   #%000000000001,(a1)         ;16
        jmp     .blueDone
.subBlue
        sub.w   #%000000000001,(a1)
.blueDone
        add.l   #2,a0                       ;8
        add.l   #2,a1                       ;8
    dbra    d5,.doOneColor
    rts 



endpart_vbl_tb:    
        move.l screenpointershifter,$ff8200
        addq    #1,$466.w
        move.w  #$2700,sr           ;Stop all interrupts
        clr.b   $fffffa1b.w         ;Timer B control (stop)

    move.w  #0,$ffff8240
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
    move.l  #endpart_tb1,$120.w     ;Install our own Timer B
    move.b  #1,$fffffa21.w          ;Timer B data (number of scanlines to next interrupt)
        bclr    #3,$fffffa17.w          ;Automatic end of interrupt
        move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
        move.w  #$2300,sr           ;Interrupts back on

        rte        

endpart_tb1:
                movem.l d1-d2/a0,-(sp)
                clr.b   $fffffa1b.w                     ;Timer B control (stop)
 
                move.w  #$2700,sr

        lea $ffff8209.w,a0          ;Hardsync
        moveq   #127,d1
.sync:      tst.b   (a0)
        beq.s   .sync
        move.b  (a0),d2
        sub.b   d2,d1
        lsr.l   d1,d1
    dcb.w   80,$4e71
    move.w  endPartBackgroundColor,$ffff8240
    movem.l (sp)+,d1-d2/a0
    move.l  #endpart_tb2,$120.w
    move.b #0,$fffffa1b.w
    move.b #196,$fffffa21.w
    move.b #8,$fffffa1b.w

    rte


endpart_tb2
                movem.l d1-d2/a0,-(sp)
                clr.b   $fffffa1b.w                     ;Timer B control (stop)
 
                move.w  #$2700,sr

        lea $ffff8209.w,a0          ;Hardsync
        moveq   #127,d1
.sync:      tst.b   (a0)
        beq.s   .sync
        move.b  (a0),d2
        sub.b   d2,d1
        lsr.l   d1,d1
    dcb.w   59,$4e71
    movem.l (sp)+,d1-d2/a0

    move.w  #$000,$ffff8240
    move    #$2400,sr    

        IFNE    playmusic               
            jsr endmusic+8
        ENDC
    move.b  #0,$fffffa1b.w
    rte


doSineEffectMiddle
    ;   load the screenpointer
    move.l  screenpointer2,a0
    add.w   #80+320,a0
    lea     x_mask_offset_left_right,a2
    move.l  a2,a6
    move.w  #197-1,d6
    moveq   #-1,d5
    moveq   #0,d4

    lea     sinvaluesmiddle,a1
    add.w   sineoffset,a1

    lea     sinvaluesmiddle3,a3
    add.w   sineoffset2,a3

    lea     sinevaluesmiddleC,a4
    add.w   sineoffset3,a4
.doLine
        move.l  a0,a5               ;4
        move.w  (a1)+,d0            ;8
        add.w   (a3)+,d0            ;8
        add.w   (a4)+,d0
        move.l  a6,a2               ;4
        add.w   d0,a2               ;8
        move.w  (a2)+,d0            ;8  ;maskleft
        move.w  (a2)+,d1            ;8  ;maskright
        move.w  (a2)+,d2            ;8  ;offset
        jmp     .blocktable(pc,d2.w)
.blocktable
    REPT 20
        move.w  d5,(a5)         ;2
        add.w   #8,a5           ;2
    ENDR
        move.w  d1,(a5)
        add.w   #8,a5
        move.w  d4,(a5)

.gogo
;;;;;; left side
        move.l  a0,a5
        sub.w   #8,a5
        jmp     .blocktable2(pc,d2.w)
.blocktable2
    REPT 20
        move.w  d5,(a5)         ;2
        sub.w   #8,a5           ;2              ;---> here a tradeoff can be made by different jumps and do direct offset
    ENDR
        move.w  d0,(a5)
        sub.w   #8,a5
        move.w  d4,(a5)
        add.w   #160,a0
    dbra.w  d6,.doLine

        move.w  sineoffset,d0
        subq.w  #1*2,d0
        bge     .cont
        move.w  #300*2,d0
.cont
        move.w  d0,sineoffset


        move.w  sineoffset2,d0
        add.w   #2*2,d0
        cmp.w   #130*2*2,d0
        blt     .cont2
        moveq   #0,d0
.cont2
        move.w  d0,sineoffset2

        move.w  sineoffset3,d0
        add.w   #2*2,d0
        cmp.w   #220*2*2,d0
        blt     .cont3
        moveq   #0,d0
.cont3
        move.w  d0,sineoffset3
    rts


    dc.b    0
    even
endtextlines    equ 153
endtext ;    1234567890123456789012345678901234567890|234567890123456789012345678901234567890|2345  -> 85



    ; page 0
    dc.b    "                                        "  ;1
    dc.b    "                                        "
    dc.b    "                                        "
    dc.b    "                                        "
    dc.b    "                                        "  ;5
    dc.b    "        you have been watching:         "
    dc.b    "                                        "  
    dc.b    "                yanartas                "
    dc.b    "                                        "
    dc.b    "                                        "  ;10
    dc.b    "    first presented at sillyventure     "  
    dc.b    "   gdansk poland, december 5th, 2014    "
    dc.b    "                                        "
    dc.b    "                                        "  
    dc.b    "           tradition is not...          "  ;15
    dc.b    "                                        "          
    dc.b    "         to worship the ashes           "
    dc.b    "                                        "
    dc.b    "                  but...                "
    dc.b    "                                        "
    dc.b    "       to keep the fire burning         "
    dc.b    "                                        "  ;20
    dc.b    "                                        "
    dc.b    "                                        "
    dc.b    "                                        "  ;25

    ;   page 1
    dc.b    "                                        "
    dc.b    "full credits are as follows:            "
    dc.b    "                                        "  
    dc.b    "- tos boing -                           "  
    dc.b    " code + design by modmate               "  ;5
    dc.b    " sound ripped by modmate (from flood)   "
    dc.b    "                                        "
    dc.b    "- lucaspoint -                          "
    dc.b    " code + design + gfx by modmate         "
    dc.b    " sound by 505                           "
    dc.b    "                                        " 
    dc.b    "- warning -                             "  
    dc.b    " gfx + idea by modmate                  "  ;10 
    dc.b    " msx by actodi                          "
    dc.b    "                                        "
    dc.b    " did you notice - we also did not have  "
    dc.b    " vectorballs, or textured objects?      "
    dc.b    "                                        "
    dc.b    "- do the kolorz -                       "  ;15
    dc.b    " code + design by spkr                  "
    dc.b    " additional code by modmate             "
    dc.b    " gfx by modmate                         "
    dc.b    " msx by actodi                          "  ;20
    dc.b    "                                        "
    dc.b    "                                        "
 

    ;   page 2
    dc.b    "                                        "
    dc.b    "- yanartas : the burning rock -         "
    dc.b    " gfx by jok                             "
    dc.b    " msx by actodi                          "
    dc.b    "                                        "  ;25
    dc.b    "- rotating rock -                       "
    dc.b    " code + design by spkr                  "
    dc.b    " wireframe linerout by kalms            "
    dc.b    " gfx by jok                             "
    dc.b    " msx by actodi                          "  ;5
    dc.b    "                                        "                                                       .
    dc.b    " thanks genesis project for inspiration " 
    dc.b    " to write a realtime polygon filler     "
    dc.b    "                                        "
    dc.b    "- twister + greetings -                 "
    dc.b    " code + design by spkr                  "
    dc.b    " gfx by xia                             "  ;15
    dc.b    " font by modmate                        "
    dc.b    " msx by actodi                          "
    dc.b    "                                        "
    dc.b    "- xor pattern -                         "
    dc.b    " code by spkr                           "
    dc.b    " patterns by jok                        "
    dc.b    " msx by actodi                          "  ;5
    dc.b    "                                        "  ;25

    ;   page 3
    dc.b    "                                        "
    dc.b    "                                        "
    dc.b    "- the dragon's nest                     "
    dc.b    " gfx by jok                             "
    dc.b    "                                        "
    dc.b    "- 750 sinedots -                        "
    dc.b    " code by spkr                           "  ;20
    dc.b    " design by modmate                      "
    dc.b    " msx by actodi                          "
    dc.b    "                                        "  
    dc.b    "- dont worship the ashes -              "  
    dc.b    " code + design + gfx by modmate         "
    dc.b    " sound effect + sync by actodi          "
    dc.b    "                                        "  
    dc.b    "- end credits -                         "
    dc.b    " code + design by spkr                  "  ;10
    dc.b    " font by modmate                        "
    dc.b    " 3d object by xia                       "
    dc.b    " msx by xia, Prof. E. Gadd's Lab from   "  ;10
    dc.b    "  Luigi's Mansion, composed by Shinobu  "
    dc.b    "  Tanaka + Kazumi Totaka                "
    dc.b    " stable borders by evl                  "
    dc.b    " logo by jok                            "
    dc.b    "                                        "
    dc.b    "                                        "
    dc.b    "                                        "
 
    ; page 4
    dc.b    "graditute goes out to:                  "
    dc.b    "                                        "
    dc.b    "the homefront - floor + pien, you guys  "
    dc.b    " are the best, thanks for the love and  "
    dc.b    " all the support                        "
    dc.b    "                                        "  ;5
    dc.b    "xia - the relentless support for the    "
    dc.b    " past 1.5 year have been awesome.       "
    dc.b    " without you, there would have been no  "
    dc.b    " spkr demos nor endless atari           "
    dc.b    " programming enjoyment - let love rule! "  ;10
    dc.b    "                                        "
    dc.b    "modmate - your motivating talks and     "
    dc.b    " fresh ideas got me into working more   "
    dc.b    " on presentation, i am looking forward  "
    dc.b    " to our future endeavours!              "  ;15
    dc.b    "                                        "
    dc.b    "shadow - for taking the time to mail    "
    dc.b    " back and forth over the polyrout, hope "
    dc.b    " to see more work of you on the st!     "
    dc.b    "                                        "  ;20
    dc.b    "defjam - for the technical in-depth     "
    dc.b    " views into the next-level programming  "
    dc.b    " techniques                             "
    dc.b    "                                        "  ;25

    ;   page 5
    dc.b    "                                        "
    dc.b    "evl - your last minute help and fixes   "
    dc.b    " this close to the deadline. i will     "
    dc.b    " make an effort in the near future      "
    dc.b    " to publish your useful tidbits and     "  ;5
    dc.b    " examples                               " 
    dc.b    "                                        "
    dc.b    "sillyventure - for the opportunity to   "
    dc.b    " celebrate 1 year of asm coding, one    "
    dc.b    " year ago you guys watched my first asm "  ;10
    dc.b    " demo here                              "  
    dc.b    "                                        "
    dc.b    "you - for watching this demo and        "
    dc.b    " reading the complete text of the       "
    dc.b    " endpart                                "  ;15
    dc.b    "                                        " 
    dc.b    "                                        "
    dc.b    "                                        "
    dc.b    "     now go do something useful;        "
    dc.b    "    go make a demo or something!        "  ;20
    dc.b    "                                        "
    dc.b    "               - wrap -                 "
    dc.b    "                                        "
    dc.b    "                                        "
    dc.b    "                                        "  ;25

    even



numbers
    dc.w    2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2 ;40
    dc.w    6,10,14,18,22,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26
    dc.w    26,26,26,26,26

;offset  
;    dc.w 2


endPartText
    move.l  screenpointer2,a0
    add.w   screenOffset,a0
    lea     twister_text_shift0_swap,a4
    lea     endtext_prepared,a2
    add.w   textOffset,a2
    lea     numbers,a6
    add.w   numbersOffset,a6

    REPT 20
;.doletterleft
    ; left character setup
    move.l  a4,a5
    add.w   (a2)+,a5            ; check if space, then skip
    ; move in left char
    move.w  (a6)+,d6
    jmp     (pc,d6.w)
o   SET 2
    REPT    6
        move.b  (a5)+,o(a0)             ; this could be direct with proper data layout  ;8          ; all 4
o       SET     o+160
    ENDR

    ; right character setup
    move.l  a4,a5
    add.w   (a2)+,a5            ; check if space, then skip
    ; move in right char
    move.w  (a6)+,d6
    jmp     (pc,d6.w)
o   SET 2
    REPT    6
        move.b  (a5)+,o+1(a0)   
o       SET     o+160
    ENDR

    addq    #4,d6
    cmp.w   #22,d6
    bne     *+4
    rts

    add.w   #8,a0
    ENDR


    rts

endpartWaitFrames   equ 100

endpartWaitCounter
    dc.w    endpartWaitFrames

pageCounter
    dc.w    1
numbersOffset           
    dc.w    80
targetPaletteAddress
    dc.l    0

endPartProgress
    ; check if we are in the clearRoute
    move.w  clearRoute,d7
    bne     .doClearRoute
    ; move the text of the line
    move.w  numbersOffset,d0
    beq     .nosub
    sub.w   #2,d0
    move.w  d0,numbersOffset
    jmp     .movinglineexit
.nosub
    ; when we are here, the line of text is at the end, and we do a next line
        move.w  textOffset,d0
        move.w  #80*25,d1
        muls    pageCounter,d1
        cmp.w   d1,d0
        beq     .pagedone
        move.w  #80,numbersOffset
        add.w   #8*160,screenOffset
        add.w   #80,textOffset
        jmp     .changedlineexit
.pagedone
    ; when we are here, we are done with the page, so we need to wait a bit before we clear
        move.w  endpartWaitCounter,d0
        bne     .waitEndpart
    ; when we are here, the waiting is done
        move.w  #1,clearRoute
        move.w  #0,clearRouteLineCounter
.doClearRoute
        move.w  clearRouteLineCounter,d6
        move.l  screenpointer2,a0
        move.l  screenpointer,a1

        add.w   d6,a0
        add.w   d6,a1

        move.w  #0,d1
o       SET 2
        REPT    80
            move.w  d1,o(a0)
            move.w  d1,o(a1)
o           SET     o+8
        ENDR


        add.w   #320,d6
        move.w  d6,clearRouteLineCounter
        cmp.w   #320*100,d6
        ble     .endclearroute
    ; when we are here, the clearroute is done
;       move.w  #0,numbersOffset
        move.w  #0,screenOffset
        move.w  #0,clearRoute
.pickColor
            move.w  #17,-(SP)       ; random
    trap    #14
    addq.l  #2,SP

    and.l   #%111,D0        ; only 0-7

    lsl.w   #2,D0

    lea     endpart_paltable,a0
    add.w   d0,a0
    move.l  (a0),a0
    cmp.l   targetPaletteAddress,a0
    beq     .pickColor
    move.l  a0,targetPaletteAddress
    movem.l (a0),d0-d7

        cmp.w   #endpage,pageCounter
        bne     .addtoPage
        ; restore all the shit to starting values
        move.w  #endpartWaitFrames,endpartWaitCounter
        move.w  #0,textOffset
        move.w  #0,clearRoute
        move.w  #0,clearRouteLineCounter
        move.w  #1,pageCounter
        move.w  #80,numbersOffset
        move.w  #0,screenOffset
    rts
.addtoPage
    addq.w  #1,pageCounter
.endclearroute
    rts
.changedlineexit
    rts
.movinglineexit
    rts
.waitEndpart
    subq.w  #1,endpartWaitCounter
    rts

prepareEndFont
    lea     endpart_text_shift0,a0
    lea     twister_text_shift0,a1  ;2944
    move.l  #184,d7
.copystuff
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
    dbra    d7,.copystuff


    lea     twister_text_shift0,a0
    lea     twister_text_shift0_swap,a1
    move.l  #93*8-1,d7
    moveq   #0,d0
    roxl.l  #1,d0
.shiftword
    move.w  (a0)+,d0
    move.b  d0,(a1)+
    dbra    d7,.shiftword
    rts

prepareEndText
    lea     endtext_prepared,a1
    lea     endtext,a0

    move.l  #endtextlines*40-1,d7
.doletter
    moveq   #0,d0
    move.b  (a0)+,d0
    sub.w   #32,d0
    lsl.w   #3,d0
    move.w  d0,(a1)+
    dbra    d7,.doletter
    rts

init3dObject
        move.w  #190-1,number_of_vertices
        move.l  #coordsource2,currentVertices
        move.w  #0,currentStep
        move.w  #160,vertices_xoff
        move.w  #100,vertices_yoff

        lea     clearlocs,a0
        lea     clearlocs2,a1
        move.l  a0,clearlocpointer
        move.l  a1,clearlocpointer2
        move.l  screenpointer2,d0
        move.l  #190-1,d7
.doit
            move.l  d0,(a0)+
            move.l  d0,(a1)+
            dbra    d7,.doit
    rts

putPixels
    move.l  screenpointer2,a0
    add.w   #4,a0
    lea     vertexprojection,a1
    lea     x_block_add,a2
    lea     y_block,a3

    move.l  clearlocpointer2,a4
    move.w  vertices_xoff,d0
    move.w  vertices_yoff,d1
    move.w  number_of_vertices,d7

.doPixel
        move.l  a0,a5

        move.w  (a1)+,d2
        add.w   d0,d2
        add.w   d2,d2
        add.w   d2,d2
        move.w  (a1)+,d3
        add.w   d1,d3
        add.w   d3,d3

        move.l  (a2,d2.w),d4
        add.w   (a3,d3.w),d4
        add.w   d4,a5
        move.l  a5,(a4)+
        swap    d4
        or.w    d4,(a5)
    dbra    d7,.doPixel
    rts

clearDots
    move.l  clearlocpointer2,a0
    move.w  #19-1,d7

    move.w  #0,d0
    REPT 31
        movem.l  (a0)+,a1-a6
        move.w  d0,(a1)
        move.w  d0,(a2)
        move.w  d0,(a3)
        move.w  d0,(a4)
        move.w  d0,(a5)
        move.w  d0,(a6)
    ENDR
    movem.l  (a0)+,a1-a4
    move.w  d0,(a1)
    move.w  d0,(a2)
    move.w  d0,(a3)
    move.w  d0,(a4)

    rts 


fujiBounce
        move.w  vertices_yoff,d0
        cmp.w   #62,d0
        ble     .switchy
        cmp.w   #159,d0
        bge     .switchy
        jmp     .cont2
.switchy
        neg.w   direction_y
.cont2
        lea     vertexprojection,a0
        move.w  30*4(a0),d0         ; one extreme
        add.w   vertices_xoff,d0
        cmp.w   #3,d0
        ble     .switch
        cmp.w   #318,d0
        bge     .switch

        move.w  120*4(a0),d0
        add.w   vertices_xoff,d0
        cmp.w   #3,d0
        ble     .switch
        cmp.w   #318,d0
        bge     .switch


        jmp     .cont
.switch
        move.w  forward,d0
        bne     .set0
.set1
        move.w  #1,forward
        neg.w   direction_x
        jmp     .cont
.set0
        move.w  #0,forward
        neg.w   direction_x
        jmp     .cont
.cont

        move.w  direction_x,d0
        add.w   d0,vertices_xoff
        move.w  direction_y,d0
        add.w   d0,vertices_yoff

        move.w  forward,d0
        bne     .backward

; forward
        add.w   #2*4,currentStep
        move.w  currentStep,d0
        cmp.w   #512*2,d0
        blt     .noresetStepCounter
        move.w  #0,currentStep
.noresetStepCounter
    rts

;backward
.backward
        sub.w   #2*4,currentStep
        move.w  currentStep,d0
        bge     .noresetStepCounter2
        move.w  #511*2,currentStep
.noresetStepCounter2
    rts    

direction_y
    dc.w    1
direction_x
    dc.w    1
forward
    dc.w    0
;;;;;;;;;;;;;;;;;;;;;;;; END ENDPART CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; START RESETROUT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

rvbl:            ;>PART
                addq.l  #1,$00000466.w
                rte

resetrout:       
        move.w  #$2700,sr                   ;Stop all interrupts
        lea     stack,sp

                lea     reset_black_pal(PC),A0 ; black palette
                lea     $FFFF8240,A1
                movem.l (A0),D0-D7
                movem.l D0-D7,(A1)

        lea     save_screenadr,a0           ;Restore old screen address
        move.b  (a0)+,$ffff8201.w           ;
        move.b  (a0)+,$ffff8203.w           ;
        move.b  (a0)+,$ffff820d.w           ;

                bclr    #3,$FFFFFA17.w  ; auto eoi

                move.l  #rvbl,$00000070.w
                move    #$2300,SR
                move.w  #1,D7
                bsr     sync_wvbl
                jsr     music+0

starttt
                jsr     init_music
                jsr     init_reset_screen
                jsr     show_background
                jsr     show_dunedude
                jsr     fade_dunedude
                jsr     move_dunedude
                jsr     show_bubble
                jsr     fade_out
                jsr     end_reset_screen

                rts

init_reset_screen:


                clr.b   $0484.w         ; click off
                DC.W    $A00A      ; hide mouse

                bsr     end_sub_clrscr

                lea     $FFFF8242.w,A0
                move.w  #$0223,D1
                moveq   #15-1,D0        ; set all colors to bar color $223
bgcol_loop:     move.w  D1,(A0)+
                dbra    D0,bgcol_loop


                move.w  #200,D7
                bsr     sync_wvbl

                rts



old_tc:         DS.L 1
                even
new_tc:            
                sub.w   #57,tccount
                bgt     nocall
                add.w   #200,tccount
                move    SR,-(SP)
                move    #$2500,SR
                jsr     reset_music+8
                move    (SP)+,SR

nocall:         rte

tccount:        DS.W 200

show_background:lea     show_bg_synctab,A5

                lea     background_pic+34,A0
                movem.l $044E.w,A1

                lea     25*160(A1),A1

                lea     background_pic+34,A2
                lea     128(A2),A2

                movem.l $044E.w,A3
                lea     25*160(A3),A3
                lea     128(A3),A3

                move.w  #3-1,D6
outloop_bars:
                move.w  #147-1,D7
draw_bar:       REPT 4
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+

                move.l  (A2)+,(A3)+
                move.l  (A2)+,(A3)+

                ENDR

                lea     160-(4*8)(A0),A0
                lea     160-(4*8)(A1),A1

                lea     160-(4*8)(A2),A2
                lea     160-(4*8)(A3),A3

                dbra    D7,draw_bar

                addi.w  #32,bar_offset
                moveq   #0,D7
                move.w  bar_offset,D7

                lea     background_pic+34,A0
                lea     64(A0),A0
                movea.l A0,A2

                movem.l $044E.w,A1
                lea     25*160(A1),A1
                adda.l  D7,A1

                movem.l $044E.w,a3
                lea     25*160+128(A3),A3
                suba.l  D7,A3

                move.w  (A5)+,D7
                bsr     sync_wvbl

                dbra    D6,outloop_bars

                move.w  #40,D7
                bsr     sync_wvbl

                rts

bar_offset:     DC.L 0
show_bg_synctab:DC.W 40,10,10

background_fade:DC.W $00,$01,$02,$03
                DC.W $13,$23
                DC.W $0123,$0223
                DC.W -1



show_dunedude:  lea     dunedude_pic+34,A0 ; source: upper line
                lea     61*160(A0),A0

                lea     dunedude_pic+34,A1 ; source: lower line
                lea     62*160(A1),A1

                movem.l $044E.w,A2
                lea     101*160(A2),A2
                lea     16(A2),A2

                movem.l $044E.w,A3
                lea     102*160(A3),A3
                lea     16(A3),A3

                moveq   #123/2,D7       ; counter: no of lines
push_dunedude:  REPT 5
                move.w  (A0),(A2)       ; upper line
                move.w  2(A0),2(A2)
                move.w  4(A0),4(A2)
                move.w  6(A0),6(A2)

                move.w  (A1),(A3)       ; lower line
                move.w  2(A1),2(A3)
                move.w  4(A1),4(A3)
                move.w  6(A1),6(A3)

                lea     8(A0),A0        ; point to next word
                lea     8(A1),A1
                lea     8(A2),A2
                lea     8(A3),A3

                ENDR

                lea     -160(A0),A0     ; source up
                lea     -5*8(A0),A0

                lea     160-(5*8)(A1),A1 ; source down

                lea     -160(A2),A2     ; dest up
                lea     -5*8(A2),A2

                lea     160-(5*8)(A3),A3 ; dest down

                jsr     sub_wvbl

                dbra    D7,push_dunedude

                move.w  #40,D7
                bsr     sync_wvbl

                rts



fade_dunedude:  lea     dunedude_fadepal(PC),A0
dunedude_loop:  movem.l (A0),D0-D6
                movem.l D0-D6,$FFFF8242.w

                REPT 3
                jsr     sub_wvbl
                ENDR

                lea     14*2(A0),A0
                tst.w   (A0)
                bge.s   dunedude_loop

                move.w  #120,D7
                bsr     sync_wvbl

                rts



move_dunedude:  lea     dunedude_moves(PC),A4 ; points to movetable

                move.w  (A4)+,D0        ; get next startline

                move.l  #$FFFFFFFF,D6   ; prepare register for deletebox

init_move_dude: lea     dunedude_pic+34,A0
                movea.l $044E.w,A1
                lea     40*160(A1),A1   ; point to upper left of dunedude
                lea     0(A1,D0.w),A1   ; add/sub new startline from movetable

                lea     -7*160(A1),A2   ; scr_adr delete box above dunedude

                lea     131*160(A2),A3  ; scr_adr delete box below dunedude

                REPT 3
                jsr     sub_wvbl
                ENDR

                move.w  #123,D7         ; counter: 122 lines
move_around:    REPT 5
                move.l  (A0),(A1)
                move.l  4(A0),4(A1)     ; draw one line of dunedude
                addq.l  #8,A0
                addq.l  #8,A1
                ENDR

                lea     160-(5*8)(A0),A0 ; point to next line
                lea     160-(5*8)(A1),A1

                dbra    D7,move_around

                REPT 7
                move.l  D6,(A2)         ; draw delete box above dunedude
                move.l  D6,4(A2)
                addq.l  #8,A2

                move.l  D6,(A2)
                move.l  D6,4(A2)
                addq.l  #8,A2

                move.l  D6,(A2)
                move.l  D6,4(A2)
                addq.l  #8,A2

                move.l  D6,(A2)
                move.l  D6,4(A2)
                addq.l  #8,A2

                move.l  D6,(A2)
                move.l  D6,4(A2)
                addq.l  #8,A2

                lea     160-(5*8)(A2),A2

                ENDR

                REPT 7
                move.l  D6,(A3)         ; draw deletebox below dunedude
                move.l  D6,4(A3)
                addq.l  #8,A3

                move.l  D6,(A3)
                move.l  D6,4(A3)
                addq.l  #8,A3

                move.l  D6,(A3)
                move.l  D6,4(A3)
                addq.l  #8,A3

                move.l  D6,(A3)
                move.l  D6,4(A3)
                addq.l  #8,A3

                move.l  D6,(A3)
                move.l  D6,4(A3)
                addq.l  #8,A3

                lea     160-(5*8)(A3),A3

                ENDR

                move.w  (A4)+,D0        ; get new startline from dunedude_moves
                cmp.w   #$FF,D0         ; end of the startline table?
                bne     init_move_dude

                move.w  #40,D7
                bsr     sync_wvbl

                rts

dunedude_moves: REPT 4
                DC.W -5*160+16  ; decrease 5 lines
                DC.W -7*160+16  ; ...
                DC.W -8*160+16
                DC.W -7*160+16
                DC.W -5*160+16
                DC.W 0+16       ; back to earth
                ENDR
                DC.W $FF        ; end of table


show_bubble:    lea     text_bubble+34,A0
                movea.l $044E.w,A1
                lea     40*160+48(A1),A1

                moveq   #78-1,D7
push_bubble:    REPT 13
                move.l  (A0),D0
                and.l   D0,(A1)
                move.l  4(A0),D0
                and.l   D0,4(A1)
                addq.l  #8,A0
                addq.l  #8,A1
                ENDR

                lea     160-(8*13)(A0),A0
                lea     160-(8*13)(A1),A1

                dbra    D7,push_bubble

                move.w  #300,D7
                bsr     sync_wvbl

                rts



fade_out:

waiter          EQU 100

; *****************************************************************************
; ausfader
;
; D1 - warte-schleifenz„hler                         h”chstens 7 fadingschritte
; D2 - innerer schleifenz„hler fr 16 farben    D4 - testbit
;
; A0 - zeiger auf farbtabelle
;

fadestart:      bsr.s   init_col        ; zeiger auf anfang der farbtabelle

                move.l  #6,D3           ; „ussere schleife:h”chstens 7XX/X7X/XX7

fade_loop:      move.b  bit(PC),D4      ; erstes zu testendes bit (2-6-10)
                btst    D4,D0           ; jeweils 3. bit der farbe testen
                bne.s   fade_sub        ; wenn "%1" faden, ansonsten...
                subq.b  #1,D4           ; auf n„chstes bit ausrichten
                btst    D4,D0           ; jeweils 2. bit der farbe testen
                bne.s   fade_sub        ; wenn "%1" faden, ansonsten...
                subq.b  #1,D4           ; auf n„chstes bit ausrichten
                btst    D4,D0           ; jeweils 1. bit der farbe testen
                beq.s   nextcol         ; wenn "%0" -> n„chste farbe

fade_sub:       jsr     sub_wvbl        ; kurz warten
                sub.w   sub(PC),D0      ; r-g-b abdunkeln
                move.w  D0,(A0)         ; neue farbe in farbregister schreiben

nextcol:        addq.w  #2,A0           ; zeiger auf n„chste farbnummer
                move.w  (A0),D0         ; wert der neuen farbe einladen

                dbra    D2,fade_loop    ; innere schleife

                bsr.s   init_col        ; vor n„chstem fadingschritt z„hler neu laden
                dbra    D3,fade_loop    ; „užere schleife

                jsr     sub_wvbl

optimize:       move.w  sub(PC),D0      ; alten sub-wert holen
                lsl.w   #4,D0           ; $1->$10->$100 (anstatt mulu $10,d0)
                move.w  D0,sub          ; neuen subwert zurckschreiben

                cmp.w   #$0100,D0       ; wenn nach lsl gr”sser als $100($1000)
                bgt.s   fini_fade       ; dann raus aus der faderoutine

                move.b  bit(PC),D4      ; altes anfangsbit laden
                addq.b  #4,D4           ; bits "6"-5-4 bzw. "10"-9-8
                move.b  D4,bit          ; neues anfangsbit speichern

                bra.s   fadestart

init_col:       move.w  $FFFF8240,D0    ; auf anfang der farbtabelle
                lea     $FFFF8240,A0
                move.l  #15,D2          ; 16 durchl„ufe/16 farben=innere schleife
                rts

sub:            DC.W $01        ; fadingschritt
bit:            DC.B $02        ; anfangsbit
                EVEN

fini_fade:      move.w  #150,D7
                bsr     sync_wvbl

                rts


end_reset_screen:
                bsr.s  end_sub_clrscr
                        move.l  #8*256,d0       
        move.l  #$ffff8800,a1
        move.l  #3-1,d1
.loop:
        movep.w d0,(0,a1)
        add.w   #256,d0
        dbra    d1,.loop

                lea     $FFFF8240.w,A0
                lea     fadewhite_pal,A1
                move.w  #fadewhite_end/2-1,D7
fade_white:     move.w  (A1)+,(A0)
                jsr     sub_wvbl
                jsr     sub_wvbl
                dbra    D7,fade_white

                moveq   #50,D7
                bsr     sync_wvbl
                move.l   $04,A0
                jmp     (A0)

                rts

fadewhite_pal:  DC.W $00,$0100,$0200,$0300,$0400,$0500,$0600,$0700
                DC.W $0701,$0702,$0703,$0704,$0705,$0706,$0707
                DC.W $0717,$0727,$0737,$0747,$0757,$0767,$0777
fadewhite_end   EQU *-fadewhite_pal



end_sub_clrscr:     movea.l $044E.w,A0
                moveq   #0,D0
                move.w  #4000/2-1,D7
clr_scr_loop:   move.l  D0,(A0)+
                move.l  D0,(A0)+
                move.l  D0,(A0)+
                move.l  D0,(A0)+
                dbra    D7,clr_scr_loop

                rts

sync_wvbl:      clr.l   $0466.w
sync_wvbl_loop: tst.l   $0466.w
                beq.s   sync_wvbl_loop

                dbra    D7,sync_wvbl

                rts


;;;;;;;;;;;;;;; FROM HERE ON ITS CRAP
stackframe_size:
                DC.W 0

rte1
    rte

init_music:     
                ;>PART

                move.l  #trap_0,$00000080.w
                lea     (SP),A6
                move.l  #"CPT!",-(SP)
                trap    #0
                illegal
trap_0:
get_id:
                addq.w  #2,stackframe_size
                addq.l  #2,SP
                cmpi.l  #"CPT!",(SP)
                bne.s   get_id
                lea     (A6),SP

                move.l  #trap1,$00000084.w

                lea     rte1,A0
                move.l  A0,$00000060.w  ; NMI

                bclr    #3,$FFFFFA17.w  ; auto eoi

                moveq   #1,D0
                jsr     reset_music

                clr.b   $FFFFFA1D.w     ; cd ctrl
                move.l  #music_replay_timer,$00000114.w

                move.l  music_hz(PC),D0
                bsr     set_music_speed_hz

                rts

trap1:
                lea     (SP),A0
                adda.w  stackframe_size(PC),A0
                move.l  #music_bss,D0
                rte


music_replay_timer:
                move    #$2400,SR
                movem.l D0-A6,-(SP)
                jsr     reset_music+8
                movem.l (SP)+,D0-A6
                rte

music_hz:       DC.L 57

set_music_speed_hz:
                ;>PART

                move    #$2700,SR
; Timer C
*    clr.b   $FFFFFA1D.w     ; cd ctrl
*    move.b  D7,$FFFFFA23.w  ; c data
                bset    #5,$FFFFFA09.w
                bset    #5,$FFFFFA15.w

                pea     (A0)
                lea     mfp_prediv_table(PC),A0
                lea     -12+4(A0),A0
mfp_get_min:
                lea     12(A0),A0
                cmp.l   (A0),D0
                blt.s   mfp_get_min
                move.l  -(A0),D1        ; MFP_freq * prediv
                divu    D0,D1           ; timer data
                move.l  8(A0),D0        ; timer prediv set
                movea.l (SP)+,A0

                lea     $FFFFFA1D.w,A0
                andi.b  #$F0,(A0)

                lsl.b   #4,D0

                move.b  D1,$FFFFFA23.w  ; c data
                or.b    D0,$FFFFFA1D.w  ; cd ctrl

                move    #$2300,SR
                rts

mfp_prediv_table:
; .l  MFP_freq * prediv       ( = max freq.)
; .l  MIN freq
; .l  MFP bits
                DC.L 614400,2409+1,%0000000000000001 ; 1:4
                DC.L 245760,963+1,%0000000000000010 ; 1:10
                DC.L 153600,602+1,%0000000000000011 ; 1:16
                DC.L 49152,192+1,%0000000000000100 ;  1:50
                DC.L 38400,150+1,%0000000000000101 ;  1:64
                DC.L 24576,96+1,%0000000000000110 ;  1:100
                DC.L 12288,48+1,%0000000000000111 ;  1:200





;;;;;;;;; DATA
                DATA


reset_black_pal:      
                REPT 16
                DC.W 0
                ENDR

dunedude_fadepal:
                DC.W $0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223
                DC.W $0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223
                DC.W $0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223
                DC.W $0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223
                DC.W $0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223
                DC.W $0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223
                DC.W $0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0AA3
                DC.W $0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0333
                DC.W $0A23,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0A23,$0223,$022B,$0223,$0223,$0BBB
                DC.W $0323,$0223,$0223,$0223,$0223,$0223,$0223,$0223,$0323,$0223,$0224,$0223,$0223,$0444
                DC.W $0B23,$0A23,$0223,$0223,$0223,$02A3,$0223,$022A,$0B23,$0A23,$02AC,$0223,$0223,$0CCC
                DC.W $0423,$0323,$0223,$0223,$0223,$0233,$0223,$0222,$0423,$0323,$0235,$0223,$0223,$0555
                DC.W $0CA3,$0B2A,$0A2A,$022A,$029A,$09B3,$09AA,$0929,$0C23,$0B93,$02BD,$022B,$0223,$0DDD
                DC.W $0533,$0422,$0322,$0222,$0212,$0143,$0132,$0121,$0523,$0413,$0246,$0224,$0223,$0666
                DC.W $0DBA,$0CA9,$0B29,$0A99,$0289,$08CA,$08B9,$08A8,$0D93,$0C8A,$0ACE,$02AC,$0AA3,$0EEE
                DC.W $0642,$0531,$0421,$0311,$0201,$52,$41,$30,$0613,$0502,$0357,$0235,$0333,$0777
                DC.W -1

reset_music:          
    incbin 'reset/MUSIC/RESET.SND'
    even
music_bss:
        ds.l    800

background_pic: incbin 'reset/BACKGR.PI1'
bg_pic_end:     DC.L 0
dunedude_pic:   incbin 'reset/DUNEDUDE.PI1',19840
text_bubble:    incbin 'reset/THANKYOU.PI1'

    even

;;;;;;;;;;;;;;;;;;;;;;;; END RESETROUT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;; RESTORE ALL REGISTERS CODE ;;;;;;;;;;;;;;;;;;;;;   

    include res/kalms/clipline.s
    include res/kalms/lineroute.s

section data


SegmentedLine_MulTable
CNTR    SET     0
        REPT    200
        dc.l    CNTR
CNTR    SET     CNTR+SegmentedLine_Pitch
        ENDR



;;;;;;;;; GENERAL STUFF ;;;;;;;;;
    IFNE loadmusic
    ELSE

warningmusic:
    incbin  msx/CUTEANI1.SND

music
    incbin  msx/3DRAGON9.SND
    ENDC

;;;;;;;;;; BOING SCREEN ;;;;;;;;;;
    even
cursor_data:    
    DC.W %1111111100000000
    DC.W %0
    DC.W %111111110000000
    DC.W %0
    DC.W %11111111000000
    DC.W %0
    DC.W %1111111100000
    DC.W %0
    DC.W %111111110000
    DC.W %0
    DC.W %11111111000
    DC.W %0
    DC.W %1111111100
    DC.W %0
    DC.W %111111110
    DC.W %0
    DC.W %11111111
    DC.W %0
    DC.W %1111111
    DC.W %1000000000000000
    DC.W %111111
    DC.W %1100000000000000
    DC.W %11111
    DC.W %1110000000000000
    DC.W %1111
    DC.W %1111000000000000
    DC.W %111
    DC.W %1111100000000000
    DC.W %11
    DC.W %1111110000000000
    DC.W %1
    DC.W %1111111000000000
    DC.W %0
    DC.W %1111111100000000
    even

transoffsets:   DC.W 1,1,2,2,3,3,4,4,5,6,7,8,10,12,14,17,20,24
                DC.W 25
                DC.W 24,20,17,15,13,12,11,11,10,10,9,9,9
                DC.W 9
                DC.W 9,9,10,10,11,11,12,13,15,17,20,24
                DC.W 25
                DC.W 24,21,19,18,16,15,15,14,14,14
                DC.W 14
                DC.W 14,14,15,15,16,18,19,21,24
                DC.W 25
                DC.W 24,22,20,20,19,19,19
                DC.W 19
                DC.W 19,20,20,20,22,24
                DC.W 25
                DC.W 24,23,22,23,24
                DC.W 25
                DC.W -1

transoffsetwhite:
                DC.W 50

boingmusic:
    incbin 'msx/BOING.SND' 
    even
        
y_data:
raw_y_data:     dc.w 1*160,2*160,3*160,4*160,5*160,6*160,7*160,8*160,9*160,10*160,12*160,14*160,16*160,18*160,20*160,22*160,24*160
                dc.w 28*160,32*160,36*160,40*160,45*160,50*160,55*160,60*160,65*160,72*160,77*160,84*160,91*160,100*160
                dc.w 110*160,120*160,130*160,145*160,160*160,175*160,195*160,215*160,230*160
                dc.w 230*160,215*160,195*160,175*160
                dc.w 160*160,145*160,130*160,120*160,110*160,100*160,95*160,90*160,87*160
                dc.w 84*160,82*160,80*160,78*160,76*160,74*160,73*160,72*160,71*160,71*160,70*160,70*160
                dc.w 70*160,71*160,71*160,72*160,73*160,75*160,76*160,78*160,80*160,82*160,84*160,87*160,90*160,95*160,100*160,110*160,120*160
                dc.w 130*160,145*160,160*160,175*160,195*160,215*160,230*160
                dc.w 230*160,215*160,195*160,180*160,165*160,150*160,135*160,130*160,125*160,122*160,119*160,118*160,117*160
                dc.w 117*160,117*160,117*160
                dc.w 117*160,118*160,119*160,122*160,125*160,130*160,135*160,150*160,165*160,180*160,195*160,215*160,230*160
                dc.w 215*160,195*160,180*160,175*160,170*160,167*160,164*160,161*160,159*160,158*160,157*160,157*160
                dc.w 157*160,158*160,159*160,161*160,164*160,167*160,170*160,175*160,180*160,195*160,215*160,230*160
                dc.w 215*160,200*160,195*160,191*160,190*160,189*160,189*160,190*160,191*160,195*160,200*160,215*160,230*160
                dc.w 215*160,210*160,205*160,204*160,203*160,202*160,202*160,203*160,204*160,205*160,210*160,215*160,230*160
                dc.w 220*160,215*160,214*160,213*160,213*160,213*160,214*160,215*160,220*160,230*160
                dc.w 225*160,220*160,220*160,220*160,225*160,230*160
                DC.W $FFFF
;;;;;;;;;; END BOING SCREEN DATA ;;;;;;;;;;;;;;;
;;;;;;;;;; START CPT DATA ;;;;;;;;;;;;;
lucaspal:       DC.W $0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100
                DC.W $0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100
                DC.W $0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0110,$0110,$0111
                DC.W $0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0200,$0210,$0220,$0220,$0222
                DC.W $0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0200,$0200,$0310,$0320,$0330,$0331,$0333
                DC.W $0100,$0100,$0100,$0100,$0100,$0100,$0100,$0200,$0200,$0300,$0310,$0420,$0430,$0440,$0442,$0444
                DC.W $0100,$0100,$0100,$0100,$0100,$0200,$0200,$0300,$0310,$0410,$0420,$0530,$0540,$0550,$0553,$0555
                DC.W $0100,$0100,$0100,$0200,$0200,$0300,$0310,$0410,$0420,$0520,$0530,$0640,$0650,$0661,$0664,$0666
                DC.W $0100,$0333,$0200,$0300,$0310,$0410,$0420,$0520,$0530,$0630,$0640,$0750,$0760,$0772,$0775,$0777
                DC.W 0,0,0,0

lucaslogo:         incbin 'cpt/CPTLUCAS.PI1'
cptmusic:          incbin 'cpt/LUCASEFX.SND'
;;;;;;;;;; END CPT DATA ;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; WARNING SCREEN DATA ;;;;;;;;;;;;
warningpic:        incbin 'gfx/warnew.pi1'
;;;;;;;;;;; END WARNING DATA ;;;;;;;;;;;;;;
;;;;;;;;;;; BEGIN KOLORZ DATA ;;;;;;;;;;;;;
kolorz_col_tab:
                REPT 2
                DC.W $0100
                DC.W $0200
                DC.W $0300
                DC.W $0400
                DC.W $0500
                DC.W $0600
                DC.W $0700
                DC.W $0710
                DC.W $0720
                DC.W $0730
                DC.W $0740
                DC.W $0750
                DC.W $0760
                DC.W $0770
                DC.W $0771
                DC.W $0772
                DC.W $0773
                DC.W $0774
                DC.W $0775
                DC.W $0776
                DC.W $0777
                DC.W $0777

                DC.W $0776
                DC.W $0775
                DC.W $0774
                DC.W $0773
                DC.W $0772
                DC.W $0771
                DC.W $0770
                DC.W $0760
                DC.W $0750
                DC.W $0740
                DC.W $0730
                DC.W $0720
                DC.W $0710
                DC.W $0700
                DC.W $0600
                DC.W $0500
                DC.W $0400
                DC.W $0300
                DC.W $0200
                DC.W $0100

                ENDR
kolorz_sintab:        

                REPT 10
                DC.W 0,0,0,2,2,2,4,4,4,6,6,8,8,10,10,12,12,12,14,14,14,16,16,16,16
                DC.W 14,14,14,14,12,12,12,10,10,8,8,6,6,4,4,4,2,2,2,0,0
                ENDR

kolorz_waitcounter2            dc.l    32*51


x_block_and_offset
val set 0
    REPT 20
ofs set 0
        REPT 16
            dc.w    val
            dc.w    ofs
ofs set ofs+1
        ENDR
val set val+8
    ENDR

y_block2:
val set 0
    REPT 200
        dc.w    val
        dc.w    val
val set val+160     
    ENDR

y_block
val set 0
    REPT 200
        dc.w    val
val set val+160
    ENDR

kolorz_palette_counter
    dc.w    0

kolorz_palette
            ;0      ;1     ;2   ;3  ;4      ;5  ;6      ;7  ;8      ;9   ;10    ;11   ;12   ;13   ;14   ;15
    dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
    dc.w    $0000,$0000,$0000,$0000,$0011,$0010,$0110,$0000,$0100,$0100,$0100,$0100,$0100,$0100,$0110,$0111
    dc.w    $0000,$0000,$0010,$0010,$0122,$0111,$0221,$0001,$0210,$0100,$0200,$0200,$0210,$0210,$0221,$0222
    dc.w    $0000,$0000,$0121,$0121,$0133,$0121,$0232,$0001,$0311,$0200,$0200,$0300,$0320,$0320,$0331,$0333
    dc.w    $0000,$0000,$0121,$0131,$0233,$0232,$0343,$0011,$0321,$0200,$0300,$0400,$0420,$0430,$0442,$0444
    dc.w    $0000,$0000,$0222,$0232,$0244,$0343,$0454,$0111,$0422,$0300,$0400,$0500,$0531,$0540,$0552,$0555
    dc.w    $0000,$0000,$0232,$0242,$0344,$0454,$0565,$0112,$0432,$0300,$0400,$0600,$0641,$0650,$0663,$0666
    dc.w    $0000,$0000,$0232,$0343,$0455,$0565,$0675,$0112,$0532,$0400,$0500,$0700,$0741,$0760,$0773,$0777
;kolorz_palette_end
;    dc.w    $0000,$0000,$0000,$0112,$0222,$0223,$0333,$0000,$0334,$0444,$0000,$0555,$0556,$0666,$0667,$0777
;    dc.w    $0777,$0667,$0666,$0556,$0555,$0445,$0444,$0344,$0334,$0333,$0223,$0222,$0113,$0111,$0001,$0000


kolorz_sprites_coordslist      
    ;s0
    dc.w    42,1
    dc.w    42,89
    dc.w    2,-2                
    ;s1
    dc.w    65,-113
    dc.w    25,93
    dc.w    2,-2
    ;s2
    dc.w    680,0
    dc.w    56,120
    dc.w    3,-2
    ;s3
    dc.w    -220,50
    dc.w    41,150
    dc.w    1,-2
    ;p0             
    dc.w    1141,99
    dc.w    82,63
    dc.w    3,-2
    ;p1
    dc.w    322,0
    dc.w    66,68
    dc.w    4,-2
    ;p2
    dc.w    1500,140
    dc.w    100,80
    dc.w    5,-2                ;p2
    ;p3
    dc.w    0,0
    dc.w    91,118
    dc.w    1,-2
    ;k0
    dc.w    -216,28
    dc.w    144,28
    dc.w    1,-2
    ;k1
    dc.w    -44,160
    dc.w    112,44
    dc.w    1,-2
    ;k2
    dc.w    147,-40
    dc.w    147,70
    dc.w    1,-2                
    ;k3
    dc.w    124,-98
    dc.w    124,66
    dc.w    4,-2                
    ;r0
    dc.w    0,3
    dc.w    179,13
    dc.w    1,-2
    ;r1
    dc.w    0,0
    dc.w    163,18
    dc.w    1,-2
    ;r2
    dc.w    299,57
    dc.w    206,57
    dc.w    3,-2
    ;r3
    dc.w    -3,29
    dc.w    197,29
;   dc.w    217,75
    dc.w    2,-2
    ;r4
    dc.w    -2,18
    dc.w    188,68
;   dc.w    217,75
    dc.w    2,-2



spriteslist ;17
    dc.l    s0data  ;   0
    dc.l    s1data  ;   1
    dc.l    s2data  ;   2
    dc.l    s3data  ;   3
    dc.l    p0data  ;   4
    dc.l    p1data  ;   5
    dc.l    p2data  ;   6
    dc.l    p3data  ;
    dc.l    k0data  ;
    dc.l    k1data  ;
    dc.l    k2data  ;
    dc.l    k3data  ;
    dc.l    r0data  ;
    dc.l    r1data  ;
    dc.l    r2data  ;
    dc.l    r3data  ;
    dc.l    r4data  ;
    even

kolorz_s0  
    dc.l    2,19
    include gfx/spkr/s1.S         ; 5 x 118   
kolorz_s1  
    dc.l    3,46
    include gfx/spkr/s2.S         ; 1 x 52
kolorz_s2  
    dc.l    3,46
    include gfx/spkr/s3.S         ; 1 x 57
kolorz_s3  
    dc.l    2,19
    include gfx/spkr/s4.S         ; 1 x 95
kolorz_p0  
    dc.l    3,20
    include gfx/spkr/p1.S         ; 4 x 40    
kolorz_p1 
    dc.l    3,56
    include gfx/spkr/p2.S         ; 5 x 48
kolorz_p2
    dc.l    2,35
    include gfx/spkr/p3.S         ; 5 x 48
kolorz_p3 
    dc.l    2,33
    include gfx/spkr/p4.S         ; 5 x 48
kolorz_k0 
    dc.l    1,47
    include gfx/spkr/k1.S         ; 5 x 48
kolorz_k1
    dc.l    2,28
    include gfx/spkr/k2.S         ; 5 x 48
kolorz_k2
    dc.l    3,43
    include gfx/spkr/k3.S         ; 5 x 48
kolorz_k3 
    dc.l    3,61
    include gfx/spkr/k4.S         ; 5 x 48
kolorz_r0
    dc.l    3,20
    include gfx/spkr/r1.S         ; 5 x 48
kolorz_r1
    dc.l    3,56
    include gfx/spkr/rend.S         ; 5 x 48
kolorz_r2
    dc.l    3,33
    include gfx/spkr/r3.S         ; 5 x 48
kolorz_r3
    dc.l    2,36
    include gfx/spkr/r3b.S         ; 5 x 48
kolorz_r4
    dc.l    2,34
    include gfx/spkr/r4.S         ; 5 x 48





cptDone
    dc.w    -2
logoDone
    dc.w    -1

    ; offset, number of blocks, number of lines, offset to next
    ; offset is 80 bytes => 160 pixels
    ; 7+1*16 = 8*16 => 128 pixels
    ; 
    ; 
checkpoint
    dc.w    146*160+80,8,37-1,88
    include gfx/cptk.s

dothekolorz
    dc.w   177*160+80,8,14-1,88
    include gfx/thekolorz.s

kolorzCounter
    dc.w    0

kolorzList
    dc.l    k1
    dc.l    k2
    dc.l    k3
    dc.l    k4
    dc.l    k5
    dc.l    k6
    dc.l    k7
    dc.l    k8
    dc.l    k9
    dc.l    k10
    dc.l    k11
    dc.l    k12
    dc.l    k13
    dc.l    k14
    dc.l    k15
    dc.l    k16
    dc.l    k17
    dc.l    k18
    dc.l    k19

k1  ;7,1
    dc.w    7*8,1-1
    incbin  gfx/kolorz/k1.bin
k2  ;7,2
    dc.w    7*8,2-1
    incbin  gfx/kolorz/k2.bin
k3  ;8,2
    dc.w    8*8,2-1
    incbin  gfx/kolorz/k3.bin
k4  ;9,2
    dc.w    9*8,2-1
    incbin  gfx/kolorz/k4.bin
k5  ;9,3
    dc.w    9*8,3-1
    incbin  gfx/kolorz/k5.bin
k6  ;9,4
    dc.w    9*8,4-1
    incbin  gfx/kolorz/k6.bin
k7  ;11,2
    dc.w    11*8,2-1
    incbin  gfx/kolorz/k7.bin
k8  ;11,3
    dc.w    11*8,3-1
    incbin  gfx/kolorz/k8.bin
k9  ;11,4
    dc.w    11*8,4-1
    incbin  gfx/kolorz/k9.bin
k10 ;12,3
    dc.w    12*8,3-1
    incbin  gfx/kolorz/k10.bin
k11 ;13,4
    dc.w    13*8,4-1
    incbin  gfx/kolorz/k11.bin
k12 ;14,3
    dc.w    14*8,3-1
    incbin  gfx/kolorz/k12.bin
k13 ;15,2
    dc.w    15*8,2-1
    incbin  gfx/kolorz/k13.bin
k14 ;15,3
    dc.w    15*8,3-1
    incbin  gfx/kolorz/k14.bin
k15 ;16,3
    dc.w    16*8,3-1
    incbin  gfx/kolorz/k15.bin
k16 ;16,3
    dc.w    16*8,3-1
    incbin  gfx/kolorz/k16.bin
k17 ;17,3
    dc.w    17*8,3-1
    incbin  gfx/kolorz/k17.bin
k18 ;18,2
    dc.w    18*8,2-1
    incbin  gfx/kolorz/k18.bin
k19 ;19,1
    dc.w    19*1,1-1
    incbin  gfx/kolorz/k19.bin




;;;;;;;;;;;;; END DOKOLORZ DATA ;;;;;;;;;;;;;;;;;
yanartaspic
    incbin  gfx/yanartas5.pi1
;;;;;;;;;;;;; START POLYGON DATA ;;;;;;;;;;;;;;;;
rastercolors:   DC.W $0466,$0345,$0123,0,0
                DC.W -1

mask_buffer     incbin 'cpt/mask.bin'

polygon_endpic
    incbin  gfx/polygonpic.pi1

polygon_rightpic
    incbin  gfx/dragonright.pi1

negcleardata
    dc.l    -1                      ;0
    dc.l    block2_14               ;-1 
    dc.l    block2_13               ;-2
    dc.l    block2_12               ;-3 
    dc.l    block2_11               ;-4 
    dc.l    block2_10               ;-5 
    dc.l    block2_9               ;-6 
    dc.l    block2_8               ;-7 
    dc.l    block2_7                ;-8 
    dc.l    block2_6                ;-9 
    dc.l    block2_5                ;-10
    dc.l    block2_4                ;-11
    dc.l    block2_3                ;-12
    dc.l    block2_2                ;-13
    dc.l    block2_1                ;-14
    dc.l    block2_0                ;-15

    dc.l    block3_15               ;-16
    dc.l    block3_14               ;-17
    dc.l    block3_13               ;-18
    dc.l    block3_12               ;-19
    dc.l    block3_11               ;-20
    dc.l    block3_10               ;-21
    dc.l    block3_9               ;-22
    dc.l    block3_8                ;-23
    dc.l    block3_7                ;-24
    dc.l    block3_6                ;-25
    dc.l    block3_5                ;-26
    dc.l    block3_4                ;-27
    dc.l    block3_3                ;-28
    dc.l    block3_2                ;-29
    dc.l    block3_1                ;-30
    dc.l    block3_0                ;-31


    dc.l    block4_15               ;-32
    dc.l    block4_14               ;-33
    dc.l    block4_13               ;-34
    dc.l    block4_12               ;-35
    dc.l    block4_11               ;-36
    dc.l    block4_10               ;-37
    dc.l    block4_9               ;-38
    dc.l    block4_8                ;-39
    dc.l    block4_7                ;-40
    dc.l    block4_6                ;-41
    dc.l    block4_5                ;-42
    dc.l    block4_4                ;-43
    dc.l    block4_3                ;-44
    dc.l    block4_2                ;-45
    dc.l    block4_1                ;-46
    dc.l    block4_0                ;-47


    dc.l    block5_15               ;-48
    dc.l    block5_14               ;-49
    dc.l    block5_13               ;-50
    dc.l    block5_12               ;-51
    dc.l    block5_11               ;-52
    dc.l    block5_10               ;-53
    dc.l    block5_9               ;-54
    dc.l    block5_8                ;-55
    dc.l    block5_7                ;-56
    dc.l    block5_6                ;-57
    dc.l    block5_5                ;-58
    dc.l    block5_4                ;-59
    dc.l    block5_3                ;-60
    dc.l    block5_2                ;-61
    dc.l    block5_1                ;-62
    dc.l    block5_0                ;-63

    dc.l    block6_15               ;-64
    dc.l    block6_14               ;-65
    dc.l    block6_13              ;-66
    dc.l    block6_12               ;-67
    dc.l    block6_11               ;-68
    dc.l    block6_10               ;-69
    dc.l    block6_9               ;-70
    dc.l    block6_8                ;-71
    dc.l    block6_7                ;-72
    dc.l    block6_6                ;-73
    dc.l    block6_5                ;-74
    dc.l    block6_4                ;-75
    dc.l    block6_3                ;-76
    dc.l    block6_2                ;-77
    dc.l    block6_1                ;-78
    dc.l    block6_0                ;-79

    dc.l    block7_15               ;-80    5x12, 2x10, 2x8, 1x7, 2x5, 4x0
    dc.l    block7_14               ;-81
    dc.l    block7_13               ;-82
    dc.l    block7_12               ;-83
    dc.l    block7_11               ;-84
    dc.l    block7_10               ;-85
    dc.l    block7_9               ;-86
    dc.l    block7_8                ;-87
    dc.l    block7_7                ;-88
    dc.l    block7_6                ;-89
    dc.l    block7_5                ;-90
    dc.l    block7_4                ;-91
    dc.l    block7_3                ;-92
    dc.l    block7_2                ;-93
    dc.l    block7_1                ;-94
    dc.l    block7_0                ;-95

    dc.l    block8_15               ;-16-> 0, but next block
    dc.l    block8_14               ;-1 -> 15
    dc.l    block8_13               ;-2 -> 14
    dc.l    block8_12               ;-3 -> 13
    dc.l    block8_11               ;-4 -> 12
    dc.l    block8_10               ;-5 -> 11
    dc.l    block8_9               ;-6 -> 10
    dc.l    block8_8                ;-7 -> 9
    dc.l    block8_7                ;-8 -> 8
    dc.l    block8_6                ;-9 -> 7
    dc.l    block8_5                ;-10-> 6
    dc.l    block8_4                ;-11-> 5
    dc.l    block8_3                ;-12-> 4
    dc.l    block8_2                ;-13-> 3
    dc.l    block8_1                ;-14-> 2
    dc.l    block8_0                ;-15-> 1

    dc.l    block9_15               ;-16-> 0, but next block
    dc.l    block9_14               ;-1 -> 15
    dc.l    block9_13               ;-2 -> 14
    dc.l    block9_12               ;-3 -> 13
    dc.l    block9_11               ;-4 -> 12
    dc.l    block9_10               ;-5 -> 11
    dc.l    block9_9               ;-6 -> 10
    dc.l    block9_8                ;-7 -> 9
    dc.l    block9_7                ;-8 -> 8
    dc.l    block9_6                ;-9 -> 7
    dc.l    block9_5                ;-10-> 6
    dc.l    block9_4                ;-11-> 5
    dc.l    block9_3                ;-12-> 4
    dc.l    block9_2                ;-13-> 3
    dc.l    block9_1                ;-14-> 2
    dc.l    block9_0                ;-15-> 1

    dc.l    block10_15              ;-16-> 0, but next block
    dc.l    block10_14              ;-1 -> 15
    dc.l    block10_13              ;-2 -> 14
    dc.l    block10_12              ;-3 -> 13
    dc.l    block10_11              ;-4 -> 12
    dc.l    block10_10              ;-5 -> 11
    dc.l    block10_9              ;-6 -> 10
    dc.l    block10_8               ;-7 -> 9
    dc.l    block10_7               ;-8 -> 8
    dc.l    block10_6               ;-9 -> 7
    dc.l    block10_5               ;-10-> 6
    dc.l    block10_4               ;-11-> 5
    dc.l    block10_3               ;-12-> 4
    dc.l    block10_2               ;-13-> 3
    dc.l    block10_1               ;-14-> 2
    dc.l    block10_0               ;-15-> 1

    dc.l    block11_15              ;-16-> 0, but next block
    dc.l    block11_14              ;-1 -> 15
    dc.l    block11_13              ;-2 -> 14
    dc.l    block11_12              ;-3 -> 13
    dc.l    block11_11              ;-4 -> 12
    dc.l    block11_10              ;-5 -> 11
    dc.l    block11_9              ;-6 -> 10
    dc.l    block11_8               ;-7 -> 9
    dc.l    block11_7               ;-8 -> 8
    dc.l    block11_6               ;-9 -> 7
    dc.l    block11_5               ;-10-> 6
    dc.l    block11_4               ;-11-> 5
    dc.l    block11_3               ;-12-> 4
    dc.l    block11_2               ;-13-> 3
    dc.l    block11_1               ;-14-> 2
    dc.l    block11_0               ;-15-> 1

    dc.l    block11_0
    REPT 31
    dc.l    stopclear
    ENDR

negfilldata
    dc.l    -1  ; this is crap          ;0 unused
    dc.l    fillblock2_14               ;-1
    dc.l    fillblock2_13               ;-2
    dc.l    fillblock2_12               ;-3
    dc.l    fillblock2_11               ;-4
    dc.l    fillblock2_10               ;-5
    dc.l    fillblock2_9               ;-6
    dc.l    fillblock2_8               ;-7
    dc.l    fillblock2_7                ;-8
    dc.l    fillblock2_6                ;-9
    dc.l    fillblock2_5                ;-10
    dc.l    fillblock2_4                ;-11
    dc.l    fillblock2_3                ;-12
    dc.l    fillblock2_2                ;-13
    dc.l    fillblock2_1                ;-14
    dc.l    fillblock2_0                ;-15

    dc.l    fillblock3_15               ;-16
    dc.l    fillblock3_14               ;-17
    dc.l    fillblock3_13               ;-18
    dc.l    fillblock3_12               ;-19
    dc.l    fillblock3_11               ;-20
    dc.l    fillblock3_10               ;-21
    dc.l    fillblock3_9               ;-22
    dc.l    fillblock3_8                ;-22
    dc.l    fillblock3_7                ;-24
    dc.l    fillblock3_6                ;-25
    dc.l    fillblock3_5                ;-26
    dc.l    fillblock3_4                ;-27
    dc.l    fillblock3_3                ;-28
    dc.l    fillblock3_2                ;-29
    dc.l    fillblock3_1                ;-30
    dc.l    fillblock3_0                ;-31

    dc.l    fillblock4_15               ;-32
    dc.l    fillblock4_14               ;-33
    dc.l    fillblock4_13               ;-34
    dc.l    fillblock4_12               ;-35
    dc.l    fillblock4_11               ;-36
    dc.l    fillblock4_10               ;-37
    dc.l    fillblock4_9               ;-38
    dc.l    fillblock4_8                ;-39
    dc.l    fillblock4_7                ;-40
    dc.l    fillblock4_6                ;-41
    dc.l    fillblock4_5                ;-42
    dc.l    fillblock4_4                ;-43
    dc.l    fillblock4_3                ;-44
    dc.l    fillblock4_2                ;-45
    dc.l    fillblock4_1                ;-46
    dc.l    fillblock4_0                ;-47

    dc.l    fillblock5_15               ;-48
    dc.l    fillblock5_14               ;-49
    dc.l    fillblock5_13               ;-50
    dc.l    fillblock5_12               ;-51
    dc.l    fillblock5_11               ;-52
    dc.l    fillblock5_10               ;-53
    dc.l    fillblock5_9               ;-54
    dc.l    fillblock5_8                ;-55
    dc.l    fillblock5_7                ;-56
    dc.l    fillblock5_6                ;-57
    dc.l    fillblock5_5                ;-58
    dc.l    fillblock5_4                ;-59
    dc.l    fillblock5_3                ;-60
    dc.l    fillblock5_2                ;-61
    dc.l    fillblock5_1                ;-62
    dc.l    fillblock5_0                ;-63

    dc.l    fillblock6_15               ;-64
    dc.l    fillblock6_14               ;-65
    dc.l    fillblock6_13               ;-66
    dc.l    fillblock6_12               ;-67
    dc.l    fillblock6_11               ;-68
    dc.l    fillblock6_10               ;-69
    dc.l    fillblock6_9               ;-70
    dc.l    fillblock6_8                ;-71
    dc.l    fillblock6_7                ;-72
    dc.l    fillblock6_6                ;-73
    dc.l    fillblock6_5                ;-74
    dc.l    fillblock6_4                ;-75
    dc.l    fillblock6_3                ;-76
    dc.l    fillblock6_2                ;-77
    dc.l    fillblock6_1                ;-78
    dc.l    fillblock6_0                ;-79

    dc.l    fillblock7_15               ;-80
    dc.l    fillblock7_14               ;-81
    dc.l    fillblock7_13               ;-82
    dc.l    fillblock7_12               ;-83
    dc.l    fillblock7_11               ;-84
    dc.l    fillblock7_10               ;-85
    dc.l    fillblock7_9               ;-86
    dc.l    fillblock7_8                ;-87
    dc.l    fillblock7_7                ;-88
    dc.l    fillblock7_6                ;-89
    dc.l    fillblock7_5                ;-90
    dc.l    fillblock7_4                ;-91
    dc.l    fillblock7_3                ;-92
    dc.l    fillblock7_2                ;-93
    dc.l    fillblock7_1                ;-94
    dc.l    fillblock7_0                ;-95

    dc.l    fillblock8_15               ;-96
    dc.l    fillblock8_14               ;-97
    dc.l    fillblock8_13               ;-98
    dc.l    fillblock8_12               ;-99
    dc.l    fillblock8_11               ;-100
    dc.l    fillblock8_10               ;-101
    dc.l    fillblock8_9               ;-102
    dc.l    fillblock8_8                ;-103
    dc.l    fillblock8_7                ;-104
    dc.l    fillblock8_6                ;-105
    dc.l    fillblock8_5                ;-106
    dc.l    fillblock8_4                ;-107
    dc.l    fillblock8_3                ;-108
    dc.l    fillblock8_2                ;-109
    dc.l    fillblock8_1                ;-110
    dc.l    fillblock8_0                ;-111

    dc.l    fillblock9_15               ;-112
    dc.l    fillblock9_14               ;-113
    dc.l    fillblock9_13               ;-114
    dc.l    fillblock9_12               ;-115
    dc.l    fillblock9_11               ;-116
    dc.l    fillblock9_10               ;-117
    dc.l    fillblock9_9               ;-118
    dc.l    fillblock9_8                ;-119
    dc.l    fillblock9_7                ;-120
    dc.l    fillblock9_6                ;-121
    dc.l    fillblock9_5                ;-122
    dc.l    fillblock9_4                ;-123
    dc.l    fillblock9_3                ;-124
    dc.l    fillblock9_2                ;-125
    dc.l    fillblock9_1                ;-126
    dc.l    fillblock9_0                ;-127

    dc.l    fillblock10_15              ;-128
    dc.l    fillblock10_14              ;-129
    dc.l    fillblock10_13              ;-130
    dc.l    fillblock10_12              ;-131
    dc.l    fillblock10_11              ;-132
    dc.l    fillblock10_10              ;-133
    dc.l    fillblock10_9              ;-134
    dc.l    fillblock10_8               ;-135
    dc.l    fillblock10_7               ;-136
    dc.l    fillblock10_6               ;-137
    dc.l    fillblock10_5               ;-138
    dc.l    fillblock10_4               ;-139
    dc.l    fillblock10_3               ;-140
    dc.l    fillblock10_2               ;-141
    dc.l    fillblock10_1               ;-142
    dc.l    fillblock10_0               ;-143

    dc.l    fillblock11_15              ;-144
    dc.l    fillblock11_14              ;-145
    dc.l    fillblock11_13              ;-146
    dc.l    fillblock11_12              ;-147
    dc.l    fillblock11_11              ;-148
    dc.l    fillblock11_10              ;-149
    dc.l    fillblock11_9              ;-150
    dc.l    fillblock11_8               ;-151
    dc.l    fillblock11_7               ;-152
    dc.l    fillblock11_6               ;-153
    dc.l    fillblock11_5               ;-154
    dc.l    fillblock11_4               ;-155
    dc.l    fillblock11_3               ;-156
    dc.l    fillblock11_2               ;-157
    dc.l    fillblock11_1               ;-158
    dc.l    fillblock11_0               ;-159

    dc.l    fillblock11_0               ;-160

    REPT 31
    dc.l    stopclear
    ENDR
x_block
    REPT 30
    dc.l    xis00   ;0
    dc.l    xis01   ;1
    dc.l    xis02   ;2
    dc.l    xis03   ;3
    dc.l    xis04   ;4
    dc.l    xis05   ;5
    dc.l    xis06   ;6
    dc.l    xis07   ;7
    dc.l    xis08   ;8
    dc.l    xis09   ;9
    dc.l    xis10   ;10
    dc.l    xis11   ;11
    dc.l    xis12   ;12
    dc.l    xis13   ;13
    dc.l    xis14   ;14
    dc.l    xis15   ;15
    ENDR

fx_block
    REPT 30
    dc.l    fxis00  ;0
    dc.l    fxis01  ;1
    dc.l    fxis02  ;2
    dc.l    fxis03  ;3
    dc.l    fxis04  ;4
    dc.l    fxis05  ;5
    dc.l    fxis06  ;6
    dc.l    fxis07  ;7
    dc.l    fxis08  ;8
    dc.l    fxis09  ;9
    dc.l    fxis10  ;10
    dc.l    fxis11  ;11
    dc.l    fxis12  ;12
    dc.l    fxis13  ;13
    dc.l    fxis14  ;14
    dc.l    fxis15  ;15
    ENDR


linesList
;11*s,6*s,1*s
l01 dc.w        0
    dc.l    projectedPolySource+4       ;6
    dc.l    projectedPolySource+12      ;11
l02 dc.w        0
    dc.l    projectedPolySource+8       ;1
    dc.l    projectedPolySource+4       ;6
l03 dc.w        0
    dc.l    projectedPolySource+8       ;1
    dc.l    projectedPolySource+12      ;11

;11*s,8*s,6*s
l04 dc.w        0
    dc.l    projectedPolySource+16      ;8
    dc.l    projectedPolySource+12      ;11
l05 dc.w        0
    dc.l    projectedPolySource+4       ;6
    dc.l    projectedPolySource+16      ;8
;l01

;11*s,3*s,8*s
l06 dc.w        0
    dc.l    projectedPolySource+28      ;3
    dc.l    projectedPolySource+12      ;11
l07 dc.w        0
    dc.l    projectedPolySource+28      ;3
    dc.l    projectedPolySource+16      ;8
;l04

;11*s,1*s,3*s
;l03
l08 dc.w        0
    dc.l    projectedPolySource+8       ;1
    dc.l    projectedPolySource+28      ;3
;l06

;10*s,0*s,5*s
l09 dc.w        0
    dc.l    projectedPolySource+52      ;0
    dc.l    projectedPolySource+48      ;10
l10 dc.w        0
    dc.l    projectedPolySource+52      ;0
    dc.l    projectedPolySource+56      ;5
l11 dc.w        0
    dc.l    projectedPolySource+56      ;5
    dc.l    projectedPolySource+48      ;10

;10*s,2*s,0*s
l12 dc.w        0
    dc.l    projectedPolySource+64      ;2
    dc.l    projectedPolySource+48      ;10
l13 dc.w        0
    dc.l    projectedPolySource+52      ;0
    dc.l    projectedPolySource+64      ;2
;l09

;10*s,7*s,2*s
l14 dc.w        0
    dc.l    projectedPolySource+76      ;7
    dc.l    projectedPolySource+48      ;10
l15 dc.w        0
    dc.l    projectedPolySource+64      ;2
    dc.l    projectedPolySource+76      ;7
;l12

;10*s,5*s,7*s
;l11
l16 dc.w        0
    dc.l    projectedPolySource+56      ;5
    dc.l    projectedPolySource+76      ;7
;l14

;13*s,7*s,8*s
l17 dc.w        0
    dc.l    projectedPolySource+76      ;7
    dc.l    projectedPolySource+96      ;13
l18 dc.w        0
    dc.l    projectedPolySource+76      ;7
    dc.l    projectedPolySource+16      ;8
l19 dc.w        0
    dc.l    projectedPolySource+16      ;8
    dc.l    projectedPolySource+96      ;13

;13*s,2*s,7*s
l20 dc.w        0
    dc.l    projectedPolySource+64      ;2
    dc.l    projectedPolySource+96      ;13
;l15
;l17

;13*s,3*s,2*s
l21 dc.w        0
    dc.l    projectedPolySource+28      ;3
    dc.l    projectedPolySource+96      ;13

l22 dc.w        0
    dc.l    projectedPolySource+64      ;2
    dc.l    projectedPolySource+28      ;3
;l20

;13*s,8*s,3*s
;l19
;l07
;l22

;12*s,0*s,1*s
l23 dc.w        0
    dc.l    projectedPolySource+52      ;0
    dc.l    projectedPolySource+144     ;12
l24 dc.w        0
    dc.l    projectedPolySource+52      ;0
    dc.l    projectedPolySource+8       ;1
l25 dc.w        0
    dc.l    projectedPolySource+8       ;1
    dc.l    projectedPolySource+144     ;12

;12*s,5*s,0*s
l26 dc.w        0
    dc.l    projectedPolySource+56      ;5
    dc.l    projectedPolySource+144     ;12
;l10
;l23

;12*s,6*s,5*s
l27 dc.w        0
    dc.l    projectedPolySource+4       ;6
    dc.l    projectedPolySource+144     ;12
l28 dc.w        0
    dc.l    projectedPolySource+56      ;5
    dc.l    projectedPolySource+4       ;6
;l26

;12*s,1*s,6*s
;l25
;l02
;l27

;9*s,7*s,5*s
l29 dc.w        0
    dc.l    projectedPolySource+76      ;7
    dc.l    projectedPolySource+192     ;9
;l16
l30 dc.w        0
    dc.l    projectedPolySource+56      ;5
    dc.l    projectedPolySource+192     ;9

;9*s,5*s,6*s
;l30
;l28
l31 dc.w        0
    dc.l    projectedPolySource+4       ;6
    dc.l    projectedPolySource+192     ;9

;9*s,6*s,8*s
;l31
;l05
l32 dc.w        0
    dc.l    projectedPolySource+16      ;8
    dc.l    projectedPolySource+192     ;9

;9*s,8*s,7*s
;l32
;l18
;l29

;4*s,0*s,2*s
l33 dc.w        0
    dc.l    projectedPolySource+52      ;0
    dc.l    projectedPolySource+240     ;4
;l13
l34 dc.w        0
    dc.l    projectedPolySource+64      ;2
    dc.l    projectedPolySource+240     ;4

;4*s,1*s,0*s
l35 dc.w        0
    dc.l    projectedPolySource+8       ;1
    dc.l    projectedPolySource+240     ;4
;l24
;l33

;4*s,3*s,1*s
l36 dc.w        0
    dc.l    projectedPolySource+28      ;3
    dc.l    projectedPolySource+240     ;4

verticesFraction
    dc.w    43194
verticesCurrentFraction
    dc.w    0
verticesSize
    dc.w    44

polyEdgesList
;polySource
;   ; positive X
;   dc.w    11*s,6*s,1*s    ; thus xy at 11*s offset, xy at 6*s offset and xy at 1*s offset
    dc.l    l01,l02,l03                 ;   1:  6-11,   2:  1-6,    3:  1-11
;   dc.w    11*s,8*s,6*s                
    dc.l    l04,l05,l01                 ;   4:  8-11    5:  6-8,        (1)
;   dc.w    11*s,3*s,8*s
    dc.l    l06,l07,l04                 ;   6:  3-11    7:  3-8         (4)
;   dc.w    11*s,1*s,3*s
    dc.l    l03,l08,l06                 ;       (3)     8:  1-3         (6)

;   ; negative X
;   dc.w    10*s,0*s,5*s
    dc.l    l09,l10,l11                 ;   9:  0-10    10: 0-5     11: 5-10
;   dc.w    10*s,2*s,0*s                
    dc.l    l12,l13,l09                 ;   12: 2-10    13: 0-2         (9) 
;   dc.w    10*s,7*s,2*s
    dc.l    l14,l15,l12                 ;   14: 7-10    15: 2-7         (12)
;   dc.w    10*s,5*s,7*s
    dc.l    l11,l16,l14                 ;       (11)    16: 5-7         (14)


;   ; negative Y
;   dc.w    13*s,7*s,8*s
    dc.l    l17,l18,l19                 ;   17: 7-13    18: 7-8     19: 8-13
;   dc.w    13*s,2*s,7*s
    dc.l    l20,l15,l17                 ;   20: 2-13        (15)        (17)
;   dc.w    13*s,3*s,2*s
    dc.l    l21,l22,l20                 ;   21: 3-13    22: 2-3         (20)
;   dc.w    13*s,8*s,3*s
    dc.l    l19,l07,l21                 ;       (19)        (7)         (21)

;   ; positive Y
;   dc.w    12*s,0*s,1*s
    dc.l    l23,l24,l25                 ;   23: 0-12    24: 0-1     25: 1-12
;   dc.w    12*s,5*s,0*s    
    dc.l    l26,l10,l23                 ;   26: 5-12        (10)        (23)
;   dc.w    12*s,6*s,5*s
    dc.l    l27,l28,l26                 ;   27: 6-12    28: 5-6         (26)
;   dc.w    12*s,1*s,6*s
    dc.l    l25,l02,l27                 ;       (25)        (2)         (27)

;   ; positive z plane (back)
;   dc.w    9*s,7*s,5*s
    dc.l    l29,l16,l30                 ;   29: 7-9         (16)    30: 5-9 
;   dc.w    9*s,5*s,6*s
    dc.l    l30,l28,l31                 ;       (30)        (28)    31: 6-9
;   dc.w    9*s,6*s,8*s
    dc.l    l31,l05,l32                 ;       (31)        (5)     32: 8-9
;   dc.w    9*s,8*s,7*s
    dc.l    l32,l18,l29                 ;       (32)        (18)        (29)

;   ; negative z plane (front)
;   dc.w    4*s,0*s,2*s
    dc.l    l33,l13,l34                 ;   33: 0-4         (13)    34: 2-4
;   dc.w    4*s,1*s,0*s
    dc.l    l35,l24,l33                 ;   35: 1-4         (24)        (33)
;   dc.w    4*s,3*s,1*s
    dc.l    l36,l08,l35                 ;   36: 3-4         (8)         (35)
;   dc.w    4*s,2*s,3*s
    dc.l    l34,l22,l36                 ;       (34)        (22)        (36)


;;;;;;;;;;;;; END POLYGON DATA ;;;;;;;;;;;;;;;;;;   
;;;;;;;;;;;;; TWIST + WOBBLE DATA ;;;;;;;;;;;;;;;
twister_sinetextvert:
    include     res/sinetextvert.txt
twister_sinetexthor:
    REPT 2
        include     res/sinetexthor.txt
    ENDR
twister_text_shift0
    incbin  res/shift0_size6_alt2.bin

twister_verttable
    REPT 20
        dc.l    a,c,e,g
    ENDR

twistdata
    REPT 2
totallength2    set 0
        include res/sine.txt
    ENDR

twistbin:
    incbin  gfx/twist15.bin

twistpallette   
    incbin  res/twisterpalettes.bin

    dc.w    $777,$777,$776,$667,$666,$556,$555,$445,$444,$334,$333,$223,$222,$112,$111,$001 ;0

twister_text
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "      {{ {{ {{      "
    dc.b    "      {{ {{ {{      "
    dc.b    "      {{ {{ {{      "
    dc.b    "      {{ {{ {{      "
    dc.b    "     {{  {{  {{     "      ;20
    dc.b    "   {{    {{   {{    "
    dc.b    " {{{     {{    {{{  "
    dc.b    " {{{     {{    {{{  "
    dc.b    "                    "
    dc.b    "--------------------"
    dc.b    "     greetings      "
    dc.b    "--------------------"
    dc.b    "-       505        -"
    dc.b    "-     arvenius     -"
    dc.b    "-      attle       -"
    dc.b    "-       baah       -"
    dc.b    "-      baggio      -"
    dc.b    "-    baudsurfer    -"
    dc.b    "-     blind io     -"
    dc.b    "-      bracket     -"
    dc.b    "-     britelite    -"
    dc.b    "-       cih        -"
    dc.b    "-       cyg        -"
    dc.b    "-      daniel      -"
    dc.b    "-       dbug       -"
    dc.b    "-     delta99      -"      ;40
    dc.b    "-      dma-sc      -"
    dc.b    "-       earx       -"
    dc.b    "-       evl        -"
    dc.b    "-      felice      -"
    dc.b    "-     frequent     -"
    dc.b    "-       ggn        -"
    dc.b    "-      gloky       -"
    dc.b    "-      grazey      -"
    dc.b    "-       grey       -"
    dc.b    "-       gwem       -"
    dc.b    "-      havoc       -"
    dc.b    "-      hylst       -"
    dc.b    "-      jookie      -"
    dc.b    "-      lotek       -"
    dc.b    "-     lotharek     -"
    dc.b    "-     marakaman    -"
    dc.b    "-     moondog      -"
    dc.b    "-      orion       -"
    dc.b    "-     paranoid     -" 
    dc.b    "-     poowqnp      -"
    dc.b    "-      shadow      -"
    dc.b    "-      simone      -"
    dc.b    "-     strider      -"
    dc.b    "-    stsurvivor    -"      ;60
    dc.b    "-       stu        -"
    dc.b    "-     thadoss      -"
    dc.b    "-       tomy       -"
    dc.b    "-       ukko       -"
    dc.b    "-       xia        -"
    dc.b    "-     yerzmyey     -"
    dc.b    "-     zerkman      -"
    dc.b    "-      zorro       -"
    dc.b    "--------------------"
    dc.b    "                    "
    dc.b    "      {{ {{ {{      "
    dc.b    "      {{ {{ {{      "
    dc.b    "      {{ {{ {{      "
    dc.b    "      {{ {{ {{      "
    dc.b    "     {{  {{  {{     "
    dc.b    "   {{    {{   {{    "
    dc.b    " {{{     {{    {{{  "
    dc.b    " {{{     {{    {{{  "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "      ;80
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "--------------------"
    dc.b    "stay cool stay atari"
    dc.b    "--------------------"
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "      ;100
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
    dc.b    "                    "
totalnumber_of_text_lines set 104
;;;;;;;;;;;;;;;; END TWIST + WOBBLE DATA ;;;;;;;;;;;;
;;;;;;;;;;;;;; START MOIRE DATA ;;;;;;;;;;;;;;

    include res/moirenewpath.s
    include res/moirenewpath2.s   
    even

disttable:
    include res/distvalcircle.s
    even

moirejmpsource:
    REPT 40
            dc.l    moiresource0
            dc.l    moiresource1
            dc.l    moiresource2
            dc.l    moiresource3
            dc.l    moiresource4
            dc.l    moiresource5
            dc.l    moiresource6
            dc.l    moiresource7
            dc.l    moiresource8
            dc.l    moiresource9
            dc.l    moiresource10
            dc.l    moiresource11
            dc.l    moiresource12
            dc.l    moiresource13
            dc.l    moiresource14
            dc.l    moiresource15
    ENDR

moire_y
offsetxx set 0
    REPT 800
        dc.w    offsetxx
offsetxx set offsetxx+80
    ENDR
    
moire_x
offsetttt set 0
    REPT 25
        REPT 16
            dc.w    offsetttt
        ENDR
offsetttt set offsetttt+2
    ENDR   

moiresun
    incbin  res/smallsun.1pl

moirecircle
    incbin  res/smallcirc.1pl

wobblesun
    incbin  res/wobblesun.1pl

;;;;;;;;;;; END MOIRE DATA ;;;;;;;;;;;;;;;
;;;;;;;;;;; START DRAGON PIC DATA ;;;;;;;;
dragonpic
    incbin  gfx/dragon3.pi1

greenPalette
    REPT 16
        dc.w    bg
    ENDR

blackPalette
    REPT 16
        dc.w    0
    ENDR

;;;;;;;;;;; END DRAGON PIC DATA ;;;;;;;;;;
;;;;;;;;;;; START SINDOT DATA ;;;;;;;;;;;;
credWaitCounter
    dc.w    150

credFade
    dc.w    $211        ;0
    dc.w    $221
    dc.w    $321
    dc.w    $322
    dc.w    $332
    dc.w    $432        ;10

    dc.w    $443
    dc.w    $544
    dc.w    $655
    dc.w    $666
    dc.w    $766        ;20

    dc.w    $777
    dc.w    $777
    dc.w    $666
    dc.w    $555
    dc.w    $444        ;30

    dc.w    $433
    dc.w    $432    
    dc.w    $321        ;36

    dc.w    $332
;   dc.w    $332
    dc.w    $332
    dc.w    $332

    dc.w    $322        ;80
;   dc.w    $322
    dc.w    $322
    dc.w    $322

    dc.w    $222
;   dc.w    $222        ;90
    dc.w    $222
    dc.w    $222

    dc.w    $221
;   dc.w    $221
    dc.w    $221        ;100
    dc.w    $221

    dc.w    $210
;   dc.w    $210
    dc.w    $210
    dc.w    $210        ;110



creditstypelist
    dc.l    creds_code
    dc.l    creds_graphics
    dc.l    creds_graphics
    dc.l    creds_graphics
    dc.l    creds_music


creditsState
    dc.w    -1


creditssourcelist
    dc.l    spkr
    dc.l    mod
    dc.l    jok
    dc.l    xia
    dc.l    actodi

creds_code
    include cpt/cred_imp_code_192x35.s
creds_music
    include cpt/cred_imp_msx_192x35.s
creds_graphics
    include cpt/cred_imp_graphics_192x35.s
spkr    
    include gfx/crednew_spkr_320x65_1bpl.s
mod
    include gfx/crednew_modmate_320x65_1bpl.s
jok
    include gfx/crednew_jok_320x65_1bpl.s
actodi
    include gfx/crednew_actodi_320x65_1bpl.s
xia
    include gfx/crednew_xia_320x65_1bpl.s

x_offset_430
    include res/sinedotsxx470.txt

mulperiod256
    include     res/mulperiod256.txt

y1_off60
        include res/60off.txt

y2_off39
    rept 7
            include res/y2_off39.txt
    endr

x_block_add:
x_mask_offset:
    REPT    2
val     set 0
    REPT    20
        dc.w        %1000000000000000,val   ;0
        dc.w        %0100000000000000,val   ;1
        dc.w        %0010000000000000,val   ;2
        dc.w        %0001000000000000,val   ;3
        dc.w        %0000100000000000,val   ;4
        dc.w        %0000010000000000,val   ;5
        dc.w        %0000001000000000,val   ;6
        dc.w        %0000000100000000,val   ;7
        dc.w        %0000000010000000,val   ;8
        dc.w        %0000000001000000,val   ;9
        dc.w        %0000000000100000,val   ;10
        dc.w        %0000000000010000,val   ;11
        dc.w        %0000000000001000,val   ;12
        dc.w        %0000000000000100,val   ;13
        dc.w        %0000000000000010,val   ;14
        dc.w        %0000000000000001,val   ;15
val     set val+8
    ENDR
    ENDR


;;;;;;;;;;;;; END SINDOTS DATA ;;;;;;;;;;;;
;;;;;;;;;;;;; START WORSHIP DATA ;;;;;;;;;;
worship_pic:    incbin  gfx/worship.pi1
dont_pic:       incbin  gfx/worship_dont.bin
worsh_pic:      incbin  gfx/worship_worsh.bin
the_pic:        incbin  gfx/worship_the.bin
ashes_pic:      incbin  gfx/worship_ashes.bin

worship_colors: DC.W $0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF
                DC.W $0777,$0FFF,$07FF,$0FFF,$07FF,$07FF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0F7F
                DC.W $0EEE,$0FFF,$0EFF,$0FFF,$0EFF,$0EFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FEF
                DC.W $0666,$0F7F,$067F,$0FFF,$06FF,$06FF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0F67
                DC.W $0DDD,$0FEF,$0DEF,$0FFF,$0DFF,$0DFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FDE
                DC.W $0555,$0F67,$0567,$077F,$057F,$05FF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0F77,$0F56
                DC.W $0CCC,$0FDE,$0CDE,$0EEF,$0CEF,$0CFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FEE,$0FCD
                DC.W $0444,$0F56,$0456,$0667,$046F,$047F,$07FF,$07FF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0F77,$0F66,$0745
                DC.W $0BBB,$0FCD,$0BCD,$0DDE,$0BDF,$0BEF,$0EFF,$0EFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FEE,$0FDD,$0EBC
                DC.W $0333,$0F45,$0345,$0556,$035F,$036F,$0677,$06FF,$0FFF,$0FFF,$0FFF,$0FFF,$0FF7,$0F66,$0755,$0634
                DC.W $0AAA,$0FBC,$0ABC,$0CCD,$0ACF,$0ADF,$0DEE,$0DFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFE,$0FDD,$0ECC,$0DAB
                DC.W $0222,$0F34,$0234,$0445,$0247,$025F,$0566,$057F,$077F,$07FF,$0FFF,$0FFF,$0F76,$0F55,$0644,$0523
                DC.W $0999,$0FAB,$09AB,$0BBC,$09BE,$09CF,$0CDD,$0CEF,$0EEF,$0EFF,$0FFF,$0FFF,$0FED,$0FCC,$0DBB,$0C9A
                DC.W $0111,$0723,$0123,$0334,$0136,$0147,$0455,$0467,$0667,$0677,$0FFF,$0777,$0765,$0744,$0533,$0412
                DC.W $0888,$0E9A,$089A,$0AAB,$08AD,$08BE,$0BCC,$0BDE,$0DDE,$0DEE,$0FFF,$0EEE,$0EDC,$0EBB,$0CAA,$0B89
                DC.W $00,$0612,$12,$0223,$25,$36,$0344,$0356,$0556,$0566,$0777,$0666,$0654,$0633,$0422,$0301

first_fade:     DC.W $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0888,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0111,$00,$00,$00,$00,$00
                DC.W $00,$0800,$00,$00,$00,$08,$00,$08,$08,$88,$0999,$0888,$0800,$0800,$00,$00
                DC.W $00,$0100,$00,$00,$00,$01,$00,$01,$01,$11,$0222,$0111,$0100,$0100,$00,$00
                DC.W $00,$0900,$00,$00,$08,$09,$00,$89,$0889,$0899,$0AAA,$0999,$0980,$0900,$00,$00
                DC.W $00,$0200,$00,$00,$01,$02,$00,$12,$0112,$0122,$0333,$0222,$0210,$0200,$00,$00
                DC.W $00,$0A00,$00,$00,$09,$0A,$88,$9A,$099A,$09AA,$0BBB,$0AAA,$0A98,$0A00,$0800,$00
                DC.W $00,$0300,$00,$00,$02,$03,$11,$23,$0223,$0233,$0444,$0333,$0321,$0300,$0100,$00
                DC.W $00,$0B00,$00,$08,$0A,$8B,$0899,$08AB,$0AAB,$0ABB,$0CCC,$0BBB,$0BA9,$0B88,$0900,$0800
                DC.W $00,$0400,$00,$01,$03,$14,$0122,$0134,$0334,$0344,$0555,$0444,$0432,$0411,$0200,$0100
                DC.W $00,$0C08,$08,$0889,$8B,$9C,$09AA,$09BC,$0BBC,$0BCC,$0DDD,$0CCC,$0CBA,$0C99,$0A88,$0900
                DC.W $00,$0501,$01,$0112,$14,$25,$0233,$0245,$0445,$0455,$0666,$0555,$0543,$0522,$0311,$0200
                DC.W $00,$0D89,$89,$099A,$9C,$AD,$0ABB,$0ACD,$0CCD,$0CDD,$0EEE,$0DDD,$0DCB,$0DAA,$0B99,$0A08
                DC.W $00,$0612,$12,$0223,$25,$36,$0344,$0356,$0556,$0566,$0777,$0666,$0654,$0633,$0422,$0301
                DC.W -1

last_fade:      DC.W $00,$0612,$12,$0223,$25,$36,$0344,$0356,$0556,$0566,$0777,$0666,$0654,$0633,$0422,$0301
                DC.W $0888,$0E9A,$089A,$0AAB,$08AD,$08BE,$0BCC,$0BDE,$0DDE,$0DEE,$0FFF,$0EEE,$0EDC,$0EBB,$0CAA,$0B89
                DC.W $0111,$0723,$0123,$0334,$0136,$0147,$0455,$0467,$0667,$0677,$0FFF,$0777,$0765,$0744,$0533,$0412
                DC.W $0999,$0FAB,$09AB,$0BBC,$09BE,$09CF,$0CDD,$0CEF,$0EEF,$0EFF,$0FFF,$0FFF,$0FED,$0FCC,$0DBB,$0C9A
                DC.W $0222,$0F34,$0234,$0445,$0247,$025F,$0566,$057F,$077F,$07FF,$0FFF,$0FFF,$0F76,$0F55,$0644,$0523
                DC.W $0AAA,$0FBC,$0ABC,$0CCD,$0ACF,$0ADF,$0DEE,$0DFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFE,$0FDD,$0ECC,$0DAB
                DC.W $0333,$0F45,$0345,$0556,$035F,$036F,$0677,$06FF,$0FFF,$0FFF,$0FFF,$0FFF,$0FF7,$0F66,$0755,$0634
                DC.W $0BBB,$0FCD,$0BCD,$0DDE,$0BDF,$0BEF,$0EFF,$0EFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FEE,$0FDD,$0EBC
                DC.W $0444,$0F56,$0456,$0667,$046F,$047F,$07FF,$07FF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0F77,$0F66,$0745
                DC.W $0CCC,$0FDE,$0CDE,$0EEF,$0CEF,$0CFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FEE,$0FCD
                DC.W $0555,$0F67,$0567,$077F,$057F,$05FF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0F77,$0F56
                DC.W $0DDD,$0FEF,$0DEF,$0FFF,$0DFF,$0DFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FDE
                DC.W $0666,$0F7F,$067F,$0FFF,$06FF,$06FF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0F67
                DC.W $0EEE,$0FFF,$0EFF,$0FFF,$0EFF,$0EFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FEF
                DC.W $0777,$0FFF,$07FF,$0FFF,$07FF,$07FF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0F7F
                DC.W $0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF
                DC.W 0

                DC.W $0777      ; don't delete (move.w -2(a1),$8240.w!)
fadecolors:     DC.W $0777
                DC.W $0EEE
                DC.W $0EEE
                DC.W $0EEE
                DC.W $0EEE
                DC.W $0666
                DC.W $0666
                DC.W $0666
                DC.W $0666
                DC.W $0DDD
                DC.W $0DDD
                DC.W $0DDD
                DC.W $0DDD
                DC.W $0555
                DC.W $0555
                DC.W $0555
                DC.W $0555
                DC.W $0CCC
                DC.W $0CCC
                DC.W $0CCC
                DC.W $0CCC
                DC.W $0444
                DC.W $0444
                DC.W $0444
                DC.W $0444
                DC.W $0BBB
                DC.W $0BBB
                DC.W $0BBB
                DC.W $0333
                DC.W $0333
                DC.W $0333
                DC.W $0AAA
                DC.W $0AAA
                DC.W $0AAA
                DC.W $0222
                DC.W $0222
                DC.W $0999
                DC.W $0999
                DC.W $0111
                DC.W $0111
                DC.W $0888
                DC.W $0888
                DC.W $00

                DC.W -1

scradr_table:   DC.L scr_adr2,scr_adr3,scr_adr4,scr_adr5,scr_adr1
scradr_counter: DC.W 0
flash_counter:  DC.W 3

hejdub:
    include res/hejdub.s

worshipsound:
    incbin  msx/WORSHMO2.SND
    even
;;;;;;;;;;;;; END WORSHIP DATA ;;;;;;;;;;;;
;;;;;;;;;;;;; START ENDPART DATA ;;;;;;;;;;

endpart_text_shift0
    incbin  res/shift0_size6_new2.bin

endpart_paltable: ; 16 values
    dc.l    endpal1,endpal2,endpal3,endpal4,endpal5,endpal6,endpal7,endpal8,endpal9,endpal10,endpal11,endpal12,endpal5,endpal3,endpal1,endpal11


;   0
;   1 sine
;   2 text
;   3 = 1+2 = text
;   4 fuji
;   5 = 1+4 = fuji
;   6 = 2+4 = text
;   7 = 1+2+4 = text
;   8 = dragon = bg +111
;   9 = sine on dragon = gb -111
;   10 = text on background dragon = text
;   11 = text on sine = text
;   12 = fuji on dragon = fuji
;   13 = fuji on dragon on sine = fuji
;   14 = text on dragon on fuji = text
;   15 = text on dragon on fuji on sine = text
;pal0:           DC.W $0112,$0122,$0567,$0567,$0234,$0234,$0567,$0567       ; 0 = bg
;pal2:           DC.W $0111,$0212,$0664,$0664,$0233,$0233,$0664,$0664       ; 1 = text
;pal4:           DC.W $0666,$0656,$0345,$0345,$0334,$0334,$0345,$0345       ; 2 = fuji
;pal5:           DC.W $0233,$0135,$0667,$0667,$0345,$0345,$0667,$0667       ; 3 = sine
;pal6:           DC.W $0300,$0311,$0766,$0766,$0543,$0543,$0766,$0766
; 0 background
; 1 
endpart_pals:
                    ;0    ;1    ;2   ;3    ;4    ;5    ;6    ;7    ;8    ;9     ;10   ;11   ;12   ;13   ;14   ;15
endpal1     dc.w    $0112,$0122,$0567,$0567,$0234,$0234,$0567,$0567,$0223,$0001,$0567,$0567,$0234,$0234,$0567,$0567
endpal2     dc.w    $0111,$0212,$0664,$0664,$0233,$0233,$0664,$0664,$0323,$0000,$0664,$0664,$0233,$0233,$0664,$0664
endpal3     dc.w    $0666,$0656,$0345,$0345,$0334,$0334,$0345,$0345,$0777,$0555,$0345,$0345,$0334,$0334,$0345,$0345
endpal4     dc.w    $0233,$0135,$0667,$0667,$0345,$0345,$0667,$0667,$0344,$0122,$0667,$0667,$0345,$0345,$0667,$0667
endpal5     dc.w    $0300,$0311,$0766,$0766,$0543,$0543,$0766,$0766,$0411,$0200,$0766,$0766,$0543,$0543,$0766,$0766

endpal6     dc.w    $0011,$0133,$0665,$0665,$0445,$0445,$0665,$0665,$0122,$0000,$0665,$0665,$0445,$0445,$0665,$0665
endpal7     dc.w    $0012,$0223,$0655,$0655,$0333,$0333,$0655,$0655,$0123,$0001,$0655,$0655,$0333,$0333,$0655,$0655
endpal8     dc.w    $0211,$0312,$0556,$0556,$0333,$0333,$0556,$0556,$0322,$0100,$0556,$0556,$0333,$0333,$0556,$0556
endpal9     dc.w    $0665,$0554,$0113,$0113,$0344,$0344,$0113,$0113,$0776,$0554,$0113,$0113,$0344,$0344,$0113,$0113
endpal10    dc.w    $0666,$0012,$0334,$0334,$0133,$0133,$0334,$0334,$0777,$0555,$0334,$0334,$0133,$0133,$0334,$0334
endpal11    dc.w    $0145,$0344,$0666,$0666,$0356,$0356,$0666,$0666,$0256,$0034,$0666,$0666,$0356,$0356,$0666,$0666
endpal12    dc.w    $0133,$0313,$0556,$0556,$0344,$0344,$0556,$0556,$0244,$0022,$0556,$0556,$0344,$0344,$0556,$0556

endpartyanart
    include gfx/endpartlogo.s

endmusic
        incbin  msx/gaddfix.snd
    even

x_mask_offset_left_right:
val     set 80
    REPT    20
        dc.w    %1,%1000000000000000,val    ;0
        dc.w    %11,%1100000000000000,val   ;2
        dc.w    %111,%1110000000000000,val  ;4
        dc.w    %1111,%1111000000000000,val ;6
        dc.w    %11111,%1111100000000000,val    ;8
        dc.w    %111111,%1111110000000000,val   ;10
        dc.w    %1111111,%1111111000000000,val  ;12
        dc.w    %11111111,%1111111100000000,val ;14
        dc.w    %111111111,%1111111110000000,val    ;16
        dc.w    %1111111111,%1111111111000000,val   ;18
        dc.w    %11111111111,%1111111111100000,val  ;20
        dc.w    %111111111111,%1111111111110000,val ;22
        dc.w    %1111111111111,%1111111111111000,val    ;24
        dc.w    %11111111111111,%1111111111111100,val   ;26
        dc.w    %111111111111111,%1111111111111110,val  ;28
        dc.w    %1111111111111111,%1111111111111111,val ;30
val     set val-4
    ENDR

sinvaluesmiddle
    REPT 2
        include res/sineend3.txt
    ENDR

sinvaluesmiddle3
    REPT 4
        include res/sineend5.txt
    ENDR

sinevaluesmiddleC
    REPT 6
        include res/sineend6.txt
    ENDR


sintable:
    include res/sin512.s

path
    REPT 4
val     SET 0
        REPT 512
            dc.w    val
val         SET val+2
        ENDR
    ENDR

xpath
    REPT 4
        include res/xrotpath.s
    ENDR

ypath
    REPT 2
        include res/yrotpath.s
    ENDR

genericpath:
    REPT 4
    include res/genericpath512.s
    ENDR

coordsource2
    include res/fujinew.s


;;;;;; this defines the 14 points our object is made of
coordsource:                                        ;6      4       1
; NEGATIVE Z PLANE                                                          ---     ---     ----
p0  dc.w    negsize,negsize,negsize ; (-1,-1,-1)    left,   top,    back    ;0      0       0*s
p1  dc.w    possize,negsize,negsize ; ( 1,-1,-1)    right,  top,    back    ;6      4       1*s
p2  dc.w    negsize,possize,negsize ; (-1, 1,-1)    left,   bottom, back    ;12     8       2*s
p3  dc.w    possize,possize,negsize ; ( 1, 1,-1)    right,  bottom, back    ;18     12      3*s
p4  dc.w    0,0,negsize2            ; ( 0, 0,-1)    middle, middle, back    ;24     16      4*s

; POSITIVE Z PLANE
p5  dc.w    negsize,negsize,possize ; (-1,-1, 1)    left,   top,    front   ;30     20      5*s
p6  dc.w    possize,negsize,possize ; ( 1,-1, 1)    right,  top,    front   ;36     24      6*s
p7  dc.w    negsize,possize,possize ; (-1, 1, 1)    left,   bottom, front   ;42     28      7*s
p8  dc.w    possize,possize,possize ; ( 1, 1, 1)    right,  bototm, front   ;48     32      8*s
p9  dc.w    0,0,possize2            ; ( 0, 0, 1)    middle, middle, front   ;54     36      9*s

; negative X PLANE
p10 dc.w    negsize2,0,0            ; (-1, 0, 0)    left,   middle, middle  ;60     40      10*s
; positive X plane
p11 dc.w    possize2,0,0        ;m          48              right           ;66     44      11*s
; negative Y plane
p12 dc.w    0,negsize2,0        ;l          44              down            ;72     48      12*s
; positive Y plane
p13 dc.w    0,possize2,0        ;k          40              up              ;78     52      13*s



section bss
                DS.B 4096
stack:          DS.B 2

    IFNE loadmusic
music                                   ds.l    25000
    ENDC
; double buffer for screen etc
screenpointer                           ds.l    1
screenpointer2                          ds.l    1
screenpointershifter                    ds.l    1
screenpointer2shifter                   ds.l    1
screen1:                                ds.b    44160+256
screen2:                                ds.b    44160+256
; boing screen data
flag_1stgen:                            ds.w    1
music_on_flag:                          ds.w    1
transoffsetblack:                       ds.w    1
codegen_on:                             ds.w    1
; warning screen data
warning_buf:                            DS.B 18*48      ; 16 lines a 48 bytes
this_buf:                               DS.B 18*48
demo_buf:                               DS.B 18*48
contains_buf:                           DS.B 18*48
no_buf:                                 DS.B 18*48
cute_buf:                               DS.B 18*48
animals_buf:                            DS.B 18*48
dot_buf:                                DS.B 18*48
turtle_buf:                             DS.B 41*48      ; 41 lines a 48 bytes
; dokolorz screen data
kolorz_animationdone                    ds.w    1
kolorz_animationmoved                   ds.w    1
kolorz_timerfractioncounter             ds.l    1
kolorz_timerfraction                    ds.w    1
MEMOFFSET   SET 0
clearScreenCode                         equ     preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+16012
kolorz_precalc_coltab:                  equ     preSineX+MEMOFFSET             ;12060
MEMOFFSET   SET MEMOFFSET+72360+12060     ;64250

s0data
    ds.w    6
    REPT 16
        ds.w    (2+1)*19
    ENDR
s1data
    ds.w    6
    REPT 16
        ds.w    (3+1)*46
    ENDR
s2data
    ds.w    6
    REPT 16
        ds.w    (3+1)*57
    ENDR
s3data
    ds.w    6
    REPT 16
        ds.w    (2+1)*19
    ENDR
p0data
    ds.w    6
    REPT 16
        ds.w    (3+1)*20
    ENDR
p1data
    ds.w    6
    REPT 16
        ds.w    (3+1)*56
    ENDR
p2data
    ds.w    6
    REPT 16
        ds.w    (2+1)*35
    ENDR
p3data
    ds.w    6
    REPT 16
        ds.w    (2+1)*33
    ENDR
k0data
    ds.w    6
    REPT 16
        ds.w    (1+1)*47
    ENDR
k1data
    ds.w    6
    REPT 16
        ds.w    (2+1)*29
    ENDR
k2data
    ds.w    6
    REPT 16
        ds.w    (3+1)*44
    ENDR
k3data
    ds.w    6
    REPT 16
        ds.w    (3+1)*61
    ENDR
r0data
    ds.w    6
    REPT 16
        ds.w    (3+1)*20
    ENDR
r1data
    ds.w    6
    REPT 16
        ds.w    (3+1)*56
    ENDR
r2data
    ds.w    6
    REPT 16
        ds.w    (3+1)*33
    ENDR
r3data
    ds.w    6
    REPT 16
        ds.w    (2+1)*36
    ENDR
r4data
    ds.w    6
    REPT 16
        ds.w    (2+1)*34
    ENDR
    even
kolorzhblcode                           equ     preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+16920     ;81170
filler                                  ds.w    2
kolorz_sincounter                       ds.l    1
; polygon part
divtable_calced_flag                    ds.w    1
clearrout_calced_flag                   ds.w    1
linerout_calced_flag                    ds.w    1
divtable                                equ     preSineX+MEMOFFSET     ; 45056
MEMOFFSET   SET MEMOFFSET+45056     ;126226

;       0: 1310 *4 +28  = 5268
;       1: 1306 *4 +28  = 5252
;       2: 1306 *4 +28  = 5252
;       3: 1334 *4 +28  = 5364
;       4: 1340 *4 +28  = 5388
;       5: 1342 *4 +28  = 5396
;       6: 1344 *4 +28  = 5404
;       7: 1346 *4 +28  = 5412
;       8: 1344 *4 +28  = 5404
;       9: 1342 *4 +28  - 5396
;       10: 1340 *4 +28 = 5388
;       11: 1334 *4 +28 = 5364
;       12: 1304 *4 +28 = 5244
;       13: 1306 *4 +28 = 5252
;       14: 1310 *4 +28 = 5268
;       15: 1312 *4 +28 = 5276  ----> 85328 ===> -16*28 and then 170208

block1_0                                equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+5268+80
block2_0                                equ     block1_0+xy00_1*4+2
block3_0                                equ     block2_0+xy00_2*4+2
block4_0                                equ     block3_0+xy00_3*4+2
block5_0                                equ     block4_0+xy00_4*4+2
block6_0                                equ     block5_0+xy00_5*4+2
block7_0                                equ     block6_0+xy00_6*4+2
block8_0                                equ     block7_0+xy00_7*4+2
block9_0                                equ     block8_0+xy00_8*4+2
block10_0                               equ     block9_0+xy00_9*4+2
block11_0                               equ     block10_0+xy00_10*4+2

block1_1                                equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+5252+80
block2_1                                equ     block1_1+xy01_1*4+2
block3_1                                equ     block2_1+xy01_2*4+2
block4_1                                equ     block3_1+xy01_3*4+2
block5_1                                equ     block4_1+xy01_4*4+2
block6_1                                equ     block5_1+xy01_5*4+2
block7_1                                equ     block6_1+xy01_6*4+2
block8_1                                equ     block7_1+xy01_7*4+2
block9_1                                equ     block8_1+xy01_8*4+2
block10_1                               equ     block9_1+xy01_9*4+2
block11_1                               equ     block10_1+xy01_10*4+2

block1_2                                equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+5252+80
block2_2                                equ     block1_2+xy02_1*4+2  
block3_2                                equ     block2_2+xy02_2*4+2  
block4_2                                equ     block3_2+xy02_3*4+2  
block5_2                                equ     block4_2+xy02_4*4+2  
block6_2                                equ     block5_2+xy02_5*4+2  
block7_2                                equ     block6_2+xy02_6*4+2  
block8_2                                equ     block7_2+xy02_7*4+2  
block9_2                                equ     block8_2+xy02_8*4+2  
block10_2                               equ     block9_2+xy02_9*4+2  
block11_2                               equ     block10_2+xy02_10*4+2 

block1_3                                equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+5364+80
block2_3                                equ     block1_3+xy03_1*4+2 
block3_3                                equ     block2_3+xy03_2*4+2 
block4_3                                equ     block3_3+xy03_3*4+2 
block5_3                                equ     block4_3+xy03_4*4+2 
block6_3                                equ     block5_3+xy03_5*4+2 
block7_3                                equ     block6_3+xy03_6*4+2 
block8_3                                equ     block7_3+xy03_7*4+2 
block9_3                                equ     block8_3+xy03_8*4+2 
block10_3                               equ     block9_3+xy03_9*4+2 
block11_3                               equ     block10_3+xy03_10*4+2

block1_4                                equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+5388+80
block2_4                                equ     block1_4+xy04_1*4+2 
block3_4                                equ     block2_4+xy04_2*4+2 
block4_4                                equ     block3_4+xy04_3*4+2 
block5_4                                equ     block4_4+xy04_4*4+2 
block6_4                                equ     block5_4+xy04_5*4+2 
block7_4                                equ     block6_4+xy04_6*4+2 
block8_4                                equ     block7_4+xy04_7*4+2 
block9_4                                equ     block8_4+xy04_8*4+2 
block10_4                               equ     block9_4+xy04_9*4+2 
block11_4                               equ     block10_4+xy04_10*4+2

block1_5                                equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+5396+80
block2_5                                equ     block1_5+xy05_1*4+2
block3_5                                equ     block2_5+xy05_2*4+2
block4_5                                equ     block3_5+xy05_3*4+2
block5_5                                equ     block4_5+xy05_4*4+2
block6_5                                equ     block5_5+xy05_5*4+2
block7_5                                equ     block6_5+xy05_6*4+2
block8_5                                equ     block7_5+xy05_7*4+2
block9_5                                equ     block8_5+xy05_8*4+2
block10_5                               equ     block9_5+xy05_9*4+2
block11_5                               equ     block10_5+xy05_10*4+2

block1_6                                equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+5404+80
block2_6                                equ     block1_6+xy06_1*4+2
block3_6                                equ     block2_6+xy06_2*4+2
block4_6                                equ     block3_6+xy06_3*4+2
block5_6                                equ     block4_6+xy06_4*4+2
block6_6                                equ     block5_6+xy06_5*4+2
block7_6                                equ     block6_6+xy06_6*4+2
block8_6                                equ     block7_6+xy06_7*4+2
block9_6                                equ     block8_6+xy06_8*4+2
block10_6                               equ     block9_6+xy06_9*4+2
block11_6                               equ     block10_6+xy06_10*4+2

block1_7                                equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+5412+80
block2_7                                equ     block1_7+xy07_1*4+2
block3_7                                equ     block2_7+xy07_2*4+2
block4_7                                equ     block3_7+xy07_3*4+2
block5_7                                equ     block4_7+xy07_4*4+2
block6_7                                equ     block5_7+xy07_5*4+2
block7_7                                equ     block6_7+xy07_6*4+2
block8_7                                equ     block7_7+xy07_7*4+2
block9_7                                equ     block8_7+xy07_8*4+2
block10_7                               equ     block9_7+xy07_9*4+2
block11_7                               equ     block10_7+xy07_10*4+2

block1_8                                equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+5404+80
block2_8                                equ     block1_8+xy08_1*4+2
block3_8                                equ     block2_8+xy08_2*4+2
block4_8                                equ     block3_8+xy08_3*4+2
block5_8                                equ     block4_8+xy08_4*4+2
block6_8                                equ     block5_8+xy08_5*4+2
block7_8                                equ     block6_8+xy08_6*4+2
block8_8                                equ     block7_8+xy08_7*4+2
block9_8                                equ     block8_8+xy08_8*4+2
block10_8                               equ     block9_8+xy08_9*4+2
block11_8                               equ     block10_8+xy08_10*4+2

block1_9                                equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+5396+80
block2_9                                equ     block1_9+xy09_1*4+2
block3_9                                equ     block2_9+xy09_2*4+2
block4_9                                equ     block3_9+xy09_3*4+2
block5_9                                equ     block4_9+xy09_4*4+2
block6_9                                equ     block5_9+xy09_5*4+2
block7_9                                equ     block6_9+xy09_6*4+2
block8_9                                equ     block7_9+xy09_7*4+2
block9_9                                equ     block8_9+xy09_8*4+2
block10_9                               equ     block9_9+xy09_9*4+2
block11_9                               equ     block10_9+xy09_10*4+2

block1_10                               equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+5388+80
block2_10                               equ     block1_10+xy10_1*4+2
block3_10                               equ     block2_10+xy10_2*4+2
block4_10                               equ     block3_10+xy10_3*4+2
block5_10                               equ     block4_10+xy10_4*4+2
block6_10                               equ     block5_10+xy10_5*4+2
block7_10                               equ     block6_10+xy10_6*4+2
block8_10                               equ     block7_10+xy10_7*4+2
block9_10                               equ     block8_10+xy10_8*4+2
block10_10                              equ     block9_10+xy10_9*4+2
block11_10                              equ     block10_10+xy10_10*4+2

block1_11                               equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+5364+80
block2_11                               equ     block1_11+xy11_1*4+2
block3_11                               equ     block2_11+xy11_2*4+2
block4_11                               equ     block3_11+xy11_3*4+2
block5_11                               equ     block4_11+xy11_4*4+2
block6_11                               equ     block5_11+xy11_5*4+2
block7_11                               equ     block6_11+xy11_6*4+2
block8_11                               equ     block7_11+xy11_7*4+2
block9_11                               equ     block8_11+xy11_8*4+2
block10_11                              equ     block9_11+xy11_9*4+2
block11_11                              equ     block10_11+xy11_10*4+2

block1_12                               equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+5244+80
block2_12                               equ     block1_12+xy12_1*4+2
block3_12                               equ     block2_12+xy12_2*4+2
block4_12                               equ     block3_12+xy12_3*4+2
block5_12                               equ     block4_12+xy12_4*4+2
block6_12                               equ     block5_12+xy12_5*4+2
block7_12                               equ     block6_12+xy12_6*4+2
block8_12                               equ     block7_12+xy12_7*4+2
block9_12                               equ     block8_12+xy12_8*4+2
block10_12                              equ     block9_12+xy12_9*4+2
block11_12                              equ     block10_12+xy12_10*4+2

block1_13                               equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+5252+80
block2_13                               equ     block1_13+xy13_1*4+2
block3_13                               equ     block2_13+xy13_2*4+2
block4_13                               equ     block3_13+xy13_3*4+2
block5_13                               equ     block4_13+xy13_4*4+2
block6_13                               equ     block5_13+xy13_5*4+2
block7_13                               equ     block6_13+xy13_6*4+2
block8_13                               equ     block7_13+xy13_7*4+2
block9_13                               equ     block8_13+xy13_8*4+2
block10_13                              equ     block9_13+xy13_9*4+2
block11_13                              equ     block10_13+xy13_10*4+2

block1_14                               equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+5268+80
block2_14                               equ     block1_14+xy14_1*4+2
block3_14                               equ     block2_14+xy14_2*4+2
block4_14                               equ     block3_14+xy14_3*4+2
block5_14                               equ     block4_14+xy14_4*4+2
block6_14                               equ     block5_14+xy14_5*4+2
block7_14                               equ     block6_14+xy14_6*4+2
block8_14                               equ     block7_14+xy14_7*4+2
block9_14                               equ     block8_14+xy14_8*4+2
block10_14                              equ     block9_14+xy14_9*4+2
block11_14                              equ     block10_14+xy14_10*4+2

block1_15                               equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+5276+80
block2_15                               equ     block1_15+xy15_1*4+2
block3_15                               equ     block2_15+xy15_2*4+2
block4_15                               equ     block3_15+xy15_3*4+2
block5_15                               equ     block4_15+xy15_4*4+2
block6_15                               equ     block5_15+xy15_5*4+2
block7_15                               equ     block6_15+xy15_6*4+2
block8_15                               equ     block7_15+xy15_7*4+2
block9_15                               equ     block8_15+xy15_8*4+2
block10_15                              equ     block9_15+xy15_9*4+2
block11_15                              equ     block10_15+xy15_10*4+2



;       0: 1310 *4 +28  = 5268      10508
;       1: 1306 *4 +28  = 5252      10476
;       2: 1306 *4 +28  = 5252      10476
;       3: 1334 *4 +28  = 5364      10700
;       4: 1340 *4 +28  = 5388      10748
;       5: 1342 *4 +28  = 5396      10764
;       6: 1344 *4 +28  = 5404      10780
;       7: 1346 *4 +28  = 5412      10796
;       8: 1344 *4 +28  = 5404      10780
;       9: 1342 *4 +28  - 5396      10764
;       10: 1340 *4 +28 = 5388      10748
;       11: 1334 *4 +28 = 5364      10700
;       12: 1304 *4 +28 = 5244      10460
;       13: 1306 *4 +28 = 5252      10476
;       14: 1310 *4 +28 = 5268      10508
;       15: 1312 *4 +28 = 5276      10524           ----> 85328 ===> -16*28 and then 170208

fillblock1_0                            equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+10508+160   
fillblock2_0                            equ     fillblock1_0+xy00_1*8+2
fillblock3_0                            equ     fillblock2_0+xy00_2*8+2
fillblock4_0                            equ     fillblock3_0+xy00_3*8+2
fillblock5_0                            equ     fillblock4_0+xy00_4*8+2
fillblock6_0                            equ     fillblock5_0+xy00_5*8+2
fillblock7_0                            equ     fillblock6_0+xy00_6*8+2
fillblock8_0                            equ     fillblock7_0+xy00_7*8+2
fillblock9_0                            equ     fillblock8_0+xy00_8*8+2
fillblock10_0                           equ     fillblock9_0+xy00_9*8+2
fillblock11_0                           equ     fillblock10_0+xy00_10*8+2

fillblock1_1                            equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+10476+160     
fillblock2_1                            equ     fillblock1_1+xy01_1*8+2
fillblock3_1                            equ     fillblock2_1+xy01_2*8+2
fillblock4_1                            equ     fillblock3_1+xy01_3*8+2
fillblock5_1                            equ     fillblock4_1+xy01_4*8+2
fillblock6_1                            equ     fillblock5_1+xy01_5*8+2
fillblock7_1                            equ     fillblock6_1+xy01_6*8+2
fillblock8_1                            equ     fillblock7_1+xy01_7*8+2
fillblock9_1                            equ     fillblock8_1+xy01_8*8+2
fillblock10_1                           equ     fillblock9_1+xy01_9*8+2
fillblock11_1                           equ     fillblock10_1+xy01_10*8+2

fillblock1_2                            equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+10476+160     
fillblock2_2                            equ     fillblock1_2+xy02_1*8+2
fillblock3_2                            equ     fillblock2_2+xy02_2*8+2
fillblock4_2                            equ     fillblock3_2+xy02_3*8+2
fillblock5_2                            equ     fillblock4_2+xy02_4*8+2
fillblock6_2                            equ     fillblock5_2+xy02_5*8+2
fillblock7_2                            equ     fillblock6_2+xy02_6*8+2
fillblock8_2                            equ     fillblock7_2+xy02_7*8+2
fillblock9_2                            equ     fillblock8_2+xy02_8*8+2
fillblock10_2                           equ     fillblock9_2+xy02_9*8+2
fillblock11_2                           equ     fillblock10_2+xy02_10*8+2

fillblock1_3                            equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+10700+160     
fillblock2_3                            equ     fillblock1_3+xy03_1*8+2
fillblock3_3                            equ     fillblock2_3+xy03_2*8+2
fillblock4_3                            equ     fillblock3_3+xy03_3*8+2
fillblock5_3                            equ     fillblock4_3+xy03_4*8+2
fillblock6_3                            equ     fillblock5_3+xy03_5*8+2
fillblock7_3                            equ     fillblock6_3+xy03_6*8+2
fillblock8_3                            equ     fillblock7_3+xy03_7*8+2
fillblock9_3                            equ     fillblock8_3+xy03_8*8+2
fillblock10_3                           equ     fillblock9_3+xy03_9*8+2
fillblock11_3                           equ     fillblock10_3+xy03_10*8+2

fillblock1_4                            equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+10748+160     
fillblock2_4                            equ     fillblock1_4+xy04_1*8+2
fillblock3_4                            equ     fillblock2_4+xy04_2*8+2
fillblock4_4                            equ     fillblock3_4+xy04_3*8+2
fillblock5_4                            equ     fillblock4_4+xy04_4*8+2
fillblock6_4                            equ     fillblock5_4+xy04_5*8+2
fillblock7_4                            equ     fillblock6_4+xy04_6*8+2
fillblock8_4                            equ     fillblock7_4+xy04_7*8+2
fillblock9_4                            equ     fillblock8_4+xy04_8*8+2
fillblock10_4                           equ     fillblock9_4+xy04_9*8+2
fillblock11_4                           equ     fillblock10_4+xy04_10*8+2

fillblock1_5                            equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+10764+160     
fillblock2_5                            equ     fillblock1_5+xy05_1*8+2
fillblock3_5                            equ     fillblock2_5+xy05_2*8+2
fillblock4_5                            equ     fillblock3_5+xy05_3*8+2
fillblock5_5                            equ     fillblock4_5+xy05_4*8+2
fillblock6_5                            equ     fillblock5_5+xy05_5*8+2
fillblock7_5                            equ     fillblock6_5+xy05_6*8+2
fillblock8_5                            equ     fillblock7_5+xy05_7*8+2
fillblock9_5                            equ     fillblock8_5+xy05_8*8+2
fillblock10_5                           equ     fillblock9_5+xy05_9*8+2
fillblock11_5                           equ     fillblock10_5+xy05_10*8+2
  
fillblock1_6                            equ    preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+10780+160          
fillblock2_6                            equ     fillblock1_6+xy06_1*8+2
fillblock3_6                            equ     fillblock2_6+xy06_2*8+2
fillblock4_6                            equ     fillblock3_6+xy06_3*8+2
fillblock5_6                            equ     fillblock4_6+xy06_4*8+2
fillblock6_6                            equ     fillblock5_6+xy06_5*8+2
fillblock7_6                            equ     fillblock6_6+xy06_6*8+2
fillblock8_6                            equ     fillblock7_6+xy06_7*8+2
fillblock9_6                            equ     fillblock8_6+xy06_8*8+2
fillblock10_6                           equ     fillblock9_6+xy06_9*8+2
fillblock11_6                           equ     fillblock10_6+xy06_10*8+2

fillblock1_7                            equ     preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+10796+160          
fillblock2_7                            equ     fillblock1_7+xy07_1*8+2
fillblock3_7                            equ     fillblock2_7+xy07_2*8+2
fillblock4_7                            equ     fillblock3_7+xy07_3*8+2
fillblock5_7                            equ     fillblock4_7+xy07_4*8+2
fillblock6_7                            equ     fillblock5_7+xy07_5*8+2
fillblock7_7                            equ     fillblock6_7+xy07_6*8+2
fillblock8_7                            equ     fillblock7_7+xy07_7*8+2
fillblock9_7                            equ     fillblock8_7+xy07_8*8+2
fillblock10_7                           equ     fillblock9_7+xy07_9*8+2
fillblock11_7                           equ     fillblock10_7+xy07_10*8+2

fillblock1_8                            equ     preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+10780+160  
fillblock2_8                            equ     fillblock1_8+xy08_1*8+2
fillblock3_8                            equ     fillblock2_8+xy08_2*8+2
fillblock4_8                            equ     fillblock3_8+xy08_3*8+2
fillblock5_8                            equ     fillblock4_8+xy08_4*8+2
fillblock6_8                            equ     fillblock5_8+xy08_5*8+2
fillblock7_8                            equ     fillblock6_8+xy08_6*8+2
fillblock8_8                            equ     fillblock7_8+xy08_7*8+2
fillblock9_8                            equ     fillblock8_8+xy08_8*8+2
fillblock10_8                           equ     fillblock9_8+xy08_9*8+2
fillblock11_8                           equ     fillblock10_8+xy08_10*8+2

fillblock1_9                            equ     preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+10764+160     
fillblock2_9                            equ     fillblock1_9+xy09_1*8+2
fillblock3_9                            equ     fillblock2_9+xy09_2*8+2
fillblock4_9                            equ     fillblock3_9+xy09_3*8+2
fillblock5_9                            equ     fillblock4_9+xy09_4*8+2
fillblock6_9                            equ     fillblock5_9+xy09_5*8+2
fillblock7_9                            equ     fillblock6_9+xy09_6*8+2
fillblock8_9                            equ     fillblock7_9+xy09_7*8+2
fillblock9_9                            equ     fillblock8_9+xy09_8*8+2
fillblock10_9                           equ     fillblock9_9+xy09_9*8+2
fillblock11_9                           equ     fillblock10_9+xy09_10*8+2

fillblock1_10                           equ     preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+10748+160    
fillblock2_10                           equ     fillblock1_10+xy10_1*8+2
fillblock3_10                           equ     fillblock2_10+xy10_2*8+2
fillblock4_10                           equ     fillblock3_10+xy10_3*8+2
fillblock5_10                           equ     fillblock4_10+xy10_4*8+2
fillblock6_10                           equ     fillblock5_10+xy10_5*8+2
fillblock7_10                           equ     fillblock6_10+xy10_6*8+2
fillblock8_10                           equ     fillblock7_10+xy10_7*8+2
fillblock9_10                           equ     fillblock8_10+xy10_8*8+2
fillblock10_10                          equ     fillblock9_10+xy10_9*8+2
fillblock11_10                          equ     fillblock10_10+xy10_10*8+2
     
fillblock1_11                           ds.b    xy11_1*8+2
fillblock2_11                           ds.b    xy11_2*8+2
fillblock3_11                           ds.b    xy11_3*8+2
fillblock4_11                           ds.b    xy11_4*8+2
fillblock5_11                           ds.b    xy11_5*8+2
fillblock6_11                           ds.b    xy11_6*8+2
fillblock7_11                           ds.b    xy11_7*8+2
fillblock8_11                           ds.b    xy11_8*8+2
fillblock9_11                           ds.b    xy11_9*8+2
fillblock10_11                          ds.b    xy11_10*8+2
fillblock11_11                          ds.b    xy11_11*8+4

fillblock1_12                           ds.b    xy12_1*8+2
fillblock2_12                           ds.b    xy12_2*8+2
fillblock3_12                           ds.b    xy12_3*8+2
fillblock4_12                           ds.b    xy12_4*8+2
fillblock5_12                           ds.b    xy12_5*8+2
fillblock6_12                           ds.b    xy12_6*8+2
fillblock7_12                           ds.b    xy12_7*8+2
fillblock8_12                           ds.b    xy12_8*8+2
fillblock9_12                           ds.b    xy12_9*8+2
fillblock10_12                          ds.b    xy12_10*8+2
fillblock11_12                          ds.b    xy12_11*8+4

fillblock1_13                           ds.b    xy13_1*8+2
fillblock2_13                           ds.b    xy13_2*8+2
fillblock3_13                           ds.b    xy13_3*8+2
fillblock4_13                           ds.b    xy13_4*8+2
fillblock5_13                           ds.b    xy13_5*8+2
fillblock6_13                           ds.b    xy13_6*8+2
fillblock7_13                           ds.b    xy13_7*8+2
fillblock8_13                           ds.b    xy13_8*8+2
fillblock9_13                           ds.b    xy13_9*8+2
fillblock10_13                          ds.b    xy13_10*8+2
fillblock11_13                          ds.b    xy13_11*8+4

fillblock1_14                           ds.b    xy14_1*8+2
fillblock2_14                           ds.b    xy14_2*8+2
fillblock3_14                           ds.b    xy14_3*8+2
fillblock4_14                           ds.b    xy14_4*8+2
fillblock5_14                           ds.b    xy14_5*8+2
fillblock6_14                           ds.b    xy14_6*8+2
fillblock7_14                           ds.b    xy14_7*8+2
fillblock8_14                           ds.b    xy14_8*8+2
fillblock9_14                           ds.b    xy14_9*8+2
fillblock10_14                          ds.b    xy14_10*8+2
fillblock11_14                          ds.b    xy14_11*8+4

fillblock1_15                           ds.b    xy15_1*8+2
fillblock2_15                           ds.b    xy15_2*8+2
fillblock3_15                           ds.b    xy15_3*8+2
fillblock4_15                           ds.b    xy15_4*8+2
fillblock5_15                           ds.b    xy15_5*8+2
fillblock6_15                           ds.b    xy15_6*8+2
fillblock7_15                           ds.b    xy15_7*8+2
fillblock8_15                           ds.b    xy15_8*8+2
fillblock9_15                           ds.b    xy15_9*8+2
fillblock10_15                          ds.b    xy15_10*8+2
fillblock11_15                          ds.b    xy15_11*8+4

endblock                                ds.b    1
    even
clearpointer                            ds.l    1
clearpointer2                           ds.l    1
cleardata                               ds.l    3
cleardata2                              ds.l    3
                                        ds.l    2           ; for storing of stuff
projectedPolySource                     ds.w    144
glenz                                   ds.w    1
; twister + text part
twister_addition                        ds.w    1
twister_iteration                       ds.w    1
twistpallettecounter:                   ds.w    1
;twister_text_shift                      ds.w    (92*2*8)*7 ; 10304
twister_text_shift                      equ     preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+10304     ;   136530
twister_text_shift1                     equ     twister_text_shift
twister_text_shift2                     equ     twister_text_shift1+(92*2*8)
twister_text_shift3                     equ     twister_text_shift2+(92*2*8)
twister_text_shift4                     equ     twister_text_shift3+(92*2*8)
twister_text_shift5                     equ     twister_text_shift4+(92*2*8)
twister_text_shift6                     equ     twister_text_shift5+(92*2*8)
twister_text_shift7                     equ     twister_text_shift6+(92*2*8)
;doTwisterCode                           ds.b    6030
doTwisterCode                           equ     preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+6030      ;142560
;twisterClearScreenCode                  ds.b    9614
twisterClearScreenCode                  equ     preSineX+MEMOFFSET
MEMOFFSET   SET MEMOFFSET+9614      ;152174             -----> 358082
twistdataoffset                         ds.w    1
twister_text_codes                      ds.w    20*totalnumber_of_text_lines
textoffset                              ds.w    1
twister_scrollvert                      ds.w    1
twister_horoffset                       ds.w    1
twister_vertoffset                      ds.w    1
vertoffsettableoffset                   ds.w    1
; moire
moiredistortoffset                      ds.w    1
moirepathcounter                        ds.l    1

;moiresource0                            ds.b    16000*2                         ; 16000 
moiresource0                            equ     preSineX
;moiresource1                            ds.b    16000*2                             ; 32000
moiresource1                            equ     preSineX+32000
;moiresource2                            ds.b    16000*2                             ; 48000
moiresource2                            equ     preSineX+32000*2
;moiresource3                            ds.b    16000*2                             ; 64000
moiresource3                            equ     preSineX+32000*3
;moiresource4                            ds.b    16000*2                             ; 80000
moiresource4                            equ     preSineX+32000*4
;moiresource5                            ds.b    16000*2                             ; 96000
moiresource5                            equ     preSineX+32000*5
;moiresource6                            ds.b    16000*2                             ;112000
moiresource6                            equ     preSineX+32000*6
;moiresource7                            ds.b    16000*2                             ;128000
moiresource7                            equ     preSineX+32000*7
;moiresource8                            ds.b    16000*2         ; 16000
moiresource8                            equ     preSineX+32000*8
;moiresource9                            ds.b    16000*2     ; 32000
moiresource9                            equ     preSineX+32000*9
;moiresource10                           ds.b    16000*2     ; 48000
moiresource10                           equ     preSineX+32000*10
;moiresource11                           ds.b    16000*2     ; 64000
moiresource11                           equ     preSineX+32000*11
;moiresource12                           ds.b    16000*2     ; 80000
moiresource12                           equ     preSineX+32000*12
;moiresource13                           ds.b    16000*2                             ; 16000
moiresource13                           equ     preSineX+32000*13
;moiresource14                           ds.b    16000*2                         ; 32000
moiresource14                           equ     preSineX+32000*14
;moiresource15                           ds.b    16000*2                             ; 16000
moiresource15                           equ     preSineX+32000*15
; sindots
sineDotsaddX1                           ds.l    1
sineDotsaddX2                           ds.w    1
sineDotsaddY1                           ds.w    1
sineDotsaddY2                           ds.w    1
sineDotsaddY3                           ds.w    1
sineDotsCounterX                        ds.l    1
sineDotsCounterX2                       ds.w    1
sineDotsCounterY                        ds.w    1
sineDotsCounterY2                       ds.w    1
sineDotsCounterY3                       ds.w    1
pixelpointer                            ds.l    1
pixelpointer2                           ds.l    1   
pixels                                  ds.l    number_of_pixels    ;750 * 4 = 3000
pixels2                                 ds.l    number_of_pixels    ;750 * 4 = 3000
creditsPartDone                         ds.w    1
creditsCopyPartCounter                  ds.w    1
creditspointer                          ds.w    1
credFadeCounter                         ds.w    1
credsWaiting                            ds.w    1
preSineX                                ds.w    430*256*2       ;-->    440320 bytes
preSineY                                ds.w    256*256         ;-->    131072 bytes
;preSineY                                equ     multable
                                                                ;---------> 571392

;multable                                ds.w    256*256             ;131072
multable                                equ     preSineX+MEMOFFSET             ;131072
MEMOFFSET   SET MEMOFFSET+131072        ;   283246

; worship
scr_adr1:       DS.L 1
scr_adr2:       DS.L 1
scr_adr3:       DS.L 1
scr_adr4:       DS.L 1
scr_adr5:       DS.L 1

;                DS.B 256
;screen3:        DS.B 32000
;                DS.B 256
MEMOFFSET SET 0
screen3         equ preSineX+MEMOFFSET+256
MEMOFFSET       SET MEMOFFSET+32512 

;                DS.B 256
;screen4:        DS.B 32000
;                DS.B 256
screen4         equ preSineX+MEMOFFSET+256
MEMOFFSET       SET MEMOFFSET+32512

;                DS.B 256
;screen5:        DS.B 32000
;                DS.B 256
screen5         equ preSineX+MEMOFFSET+256
MEMOFFSET       SET MEMOFFSET+32512

startline:      DS.W 1
endline:        DS.W 1
pic_start:      DS.L 1
square_start:   DS.L 1
color_flag:     DS.W 1
blockanzahl:    DS.W 1
; endpart
textOffset                              ds.w    1
clearRoute                              ds.w    1
clearRouteLineCounter                   ds.w    1
sineoffset                              ds.w    1
sineoffset2                             ds.w    1
sineoffset3                             ds.w    1
twister_text_shift0_swap                ds.b    (92*8)*7
screenOffset                            ds.w    1
endtext_prepared                        ds.w    endtextlines*40
vertices_xoff                           ds.w    1
vertices_yoff                           ds.w    1
;number_of_polygons                      ds.w    1
number_of_vertices                      ds.w    1
currentVertices:                        ds.l    1
currentStep                             ds.w    1
currentStepX                            ds.w    1
currentStepY                            ds.w    1
currentStepZ                            ds.w    1
stepSpeedX                              ds.w    1
stepSpeedY                              ds.w    1
stepSpeedZ                              ds.w    1

objectPathPointer                       ds.l    1
vertexprojection                        ds.w    3*3*max_nr_of_vertices

clearlocpointer                         ds.l    1
clearlocpointer2                        ds.l    1
clearlocs                               ds.l    max_nr_of_vertices
clearlocs2                              ds.l    max_nr_of_vertices
multable_calced_flag                    ds.w    1

; old stuff
save_pal:                               ds.w    16
save_screenadr:                         ds.l    1
save_vbl:                               ds.l    1
save_hbl:                               ds.l    1
save_ta:                                ds.l    1
save_tb:                                ds.l    1
save_tc:                                ds.l    1
save_td:                                ds.l    1
save_acia:                              ds.l    1
save_ta_delay                           ds.b    1
save_active_edge                        ds.b    1
save_inta:                              ds.b    1
save_inta_mask:                         ds.b    1
save_intb:                              ds.b    1
save_intb_mask:                         ds.b    1
save_intc:                              ds.b    1
save_intc_mask:                         ds.b    1
save_res:                               ds.b    1
save_keymode:                           ds.b    1
        even
mste_status:                            ds.w    1
reset_number_saved                      ds.l    1
reset_vector_saved                      ds.l    1

    IFNE framecount
framecounter ds.w   1
    ENDC

SegmentedLine_UpwardXMajor_GeneratedCodeOffsets
        ds.w    16*(SegmentedLine_RunLength+1)
SegmentedLine_UpwardYMajor_GeneratedCodeOffsets
        ds.w    16*(16+SegmentedLine_RunLength+16)
SegmentedLine_DownwardXMajor_GeneratedCodeOffsets
        ds.w    16*(SegmentedLine_RunLength+1)
SegmentedLine_DownwardYMajor_GeneratedCodeOffsets
        ds.w    16*(16+SegmentedLine_RunLength+16)
SegmentedLine_UpwardXMajor_GeneratedCodeBodies
        ds.l    1
SegmentedLine_UpwardYMajor_GeneratedCodeBodies
        ds.l    1
SegmentedLine_DownwardXMajor_GeneratedCodeBodies
        ds.l    1
SegmentedLine_DownwardYMajor_GeneratedCodeBodies
        ds.l    1
SegmentedLine_GeneratedCodeBuffer   equ     preSineX   ; Buffer for generated code, about 89000 bytes used in practice
SegmentedLine_ReciprocalMultiplyTable
        ds.l    321
