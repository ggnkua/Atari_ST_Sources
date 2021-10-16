
; Coded by Questor of Inter (cooooooool!)
; Das letzte Zeichen einer Seite wird nicht beachtet...
; FFFFFFFFFFFFFUUUUUUUUUUUUUUUUUCCCCCCCCCCCCCCCCCKKKKKKKKKKKKKKKK!!!!!!!!!!!!!!
                PATH 'E:\STAX_DEN.TRO\'

anz_stars       EQU 231         ;231
anz_game        EQU 71          ;131
speed           EQU 0
clear           EQU 1           ; 1 = Bildschirm lîschen
cheat           EQU 0           ; 0 = Cheat aus    1 = Cheat an
                OPT D-          ; Symboltabelle an....

max_schuû_player EQU 16
max_schuû_enemy EQU 16

max_end_enemy   EQU 16
max_e_enemy     EQU 16
max_enemy       EQU 16
schuû_player_vx EQU 5

                >PART 'Strukturen'
                RSRESET
enemy_x1:       RS.W 1
enemy_y1:       RS.W 1
enemy_energie:  RS.W 1
enemy_pointer:  RS.L 1
enemy_rout:     RS.L 1
enemy_schuû_c:  RS.W 1
enemy_schuû_f:  RS.W 1
ins_enemy:      RS.W 0

                RSRESET
e_enemy_x1:     RS.W 1
e_enemy_y1:     RS.W 1
e_enemy_x2:     RS.W 1
e_enemy_y2:     RS.W 1
e_enemy_sh_x:   RS.W 1          ; X-Koo, von wo er schieût...
e_enemy_sh_y:   RS.W 1
e_enemy_sh_f:   RS.W 1          ; Schuû-Flag, damit SchÅsse verteilter
e_enemy_energie:RS.W 1
ins_e_enemy:    RS.W 0

                RSRESET
schuû_enemy_y:  RS.W 1
schuû_enemy_x:  RS.W 1
schuû_enemy_d:  RS.W 1
schuû_enemy_f:  RS.W 1
schuû_enemy_vx: RS.W 1
ins_schuû_enemy:RS.W 1

                RSRESET
schuû_player_y: RS.W 1
schuû_player_x: RS.W 1
ins_schuû_player:RS.W 0
                ENDPART
                >PART 'Flysettings'
                RSRESET
type:           RS.W 1
restexy:        RS.W 2
deltaxy:        RS.W 2
addiert:        RS.W 2
addiert_rest:   RS.L 1
char:           RS.W 1
phase:          RS.W 1
laenge:         RS.W 0
                ENDPART
                >PART 'Init'
                bsr     start
                jmp     $00000400.w

_rte:           rte
start:          move.l  #_rte,$00000070.w
                move.l  #_rte,$00000068.w
                move.l  #_rte,$00000120.w
                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4
                moveq   #0,D5
                moveq   #0,D6
                moveq   #0,D7
                movem.l D0-D7,$FFFF8240.w

                move.b  #$03,$FFFFFC00.w
                move.b  #$96,$FFFFFC00.w
                moveq   #$12,D0
                bsr     _sendIKBD
                moveq   #$15,D0         ; Joy aus...
                bsr     _sendIKBD

                jsr     shift_blase
                jsr     shift_sprites
                bsr     game_init

                lea     form_start,A0
                lea     form_ende,A1
init_form:      cmpa.l  A0,A1
                beq.s   ende_init_form
                move.w  (A0)+,D0
                move.w  (A0)+,D1
                bmi.s   init_form
                lsl.w   #5,D1
                move.w  D1,D2
                add.w   D1,D1
                add.w   D1,D1
                add.w   D2,D1
                move.w  D1,-2(A0)
                bra.s   init_form
ende_init_form:
                move.w  #0,game_flag    ; Game erstmal ausschalten

                move.l  $00000120.w,old120
                move.l  $00000118.w,old118
                move.l  #_rte,$00000118.w
                bclr    #3,$FFFFFA17.w  ;      AOI
                move.b  $FFFFFA07.w,old07
                move.b  $FFFFFA09.w,old09
                move.b  $FFFFFA13.w,old13
                move.b  $FFFFFA15.w,old15
                clr.b   $FFFFFA07.w
                clr.b   $FFFFFA09.w
                move.b  #-1,$FFFFFA13.w
                move.b  #-1,$FFFFFA15.w

                lea     $FFFF8201.w,A0
                movep.w 0(A0),D0
                move.w  D0,oldscreen
                move.l  #screen_base,D0
                clr.b   D0
                move.l  D0,screen1
                move.l  D0,D1
                add.l   #32000+100*256,D1
                move.l  D1,screen2

                lea     clearbuf1,A0
                movea.l screen1,A1
                adda.l  #29*160,A1
                move.w  #anz_stars-1,D0
                lea     clearbuf2,A2
fillclearstar:  move.l  A1,(A0)+
                move.l  A1,(A2)+
                dbra    D0,fillclearstar

                lea     screen160add1,A0
                lea     screen160add2,A1
                move.l  screen1,D0
                move.l  screen2,D1
                add.l   #29*160,D0
                add.l   #29*160,D1
                move.w  #200-1,D2
fill1:          add.l   D0,(A0)+
                add.l   D1,(A1)+
                dbra    D2,fill1

                movea.l screen1,A0
                movea.l screen2,A1
                adda.l  #230*160,A0
                adda.l  #230*160,A1
                lea     inter,A2
                move.w  #(50*160)/4-2,D0
copy_inter:     move.l  (A2),(A0)+
                move.l  (A2)+,(A1)+
                dbra    D0,copy_inter

                movea.l screen1,A0
                movea.l screen2,A1
                adda.l  #8,A0
                adda.l  #8,A1
                lea     questie,A2
                move.w  #(29*160)/4-2,D0
copy_questie:   move.l  (A2),(A0)+
                move.l  (A2)+,(A1)+
                dbra    D0,copy_questie

                movea.l screen1,A0
                movea.l screen2,A1
                lea     160(A0),A0
                lea     160(A1),A1
                move.l  #%00000000000000110000000000000011,D0
                move.l  #%11000000000000001100000000000000,D1
                move.w  #280-1,D2
init_balken:    move.l  D0,8(A0)
                move.l  D0,8+4(A0)
                move.l  D1,144(A0)
                move.l  D1,144+4(A0)
                move.l  D0,8(A1)
                move.l  D0,8+4(A1)
                move.l  D1,144(A1)
                move.l  D1,144+4(A1)
                lea     160(A0),A0
                lea     160(A1),A1
                dbra    D2,init_balken

                movea.l screen1,A0
                adda.l  #160*100+40,A0
                move.l  A0,sprite_save1
                move.l  A0,sprite_save2

                bsr     L0009
                move.l  $00000070.w,oldvbl

                move.l  #sync_vbl,$00000070.w
                move.b  $FFFF8260.w,oldres
                clr.w   sync_wert
waitvbl:        tst.w   sync_wert
                beq.s   waitvbl
                clr.b   $FFFF8260.w

                clr.b   $FFFFFA1B.w     ; Timer B abschalten
                bset    #0,$FFFFFA07.w  ; aber zulassen

                moveq   #9-1,D7
                moveq   #0,D6
                lea     charset0,A1
initloop2:      lea     charset,A0
                move.w  #640-1,D0       ; Anzahl der Zeichen pro Zeichensatz
initloop1:      moveq   #0,D1
                move.b  (A0)+,D1
                lsl.w   D6,D1
                move.w  D1,(A1)+
                dbra    D0,initloop1
                addq.w  #1,D6
                dbra    D7,initloop2

                lea     charset1,A0
                lea     charset9,A1
                move.w  #4480-1,D7
initloop3:      moveq   #0,D0
                move.w  (A0)+,D0
                lsl.l   #8,D0
                move.l  D0,(A1)+
                dbra    D7,initloop3

                lea     char_struktur,A0
                moveq   #32-1,D7
                moveq   #0,D0
init_loop:      move.w  D0,type(A0)
                move.l  D0,deltaxy(A0)
                move.w  #160,addiert(A0)
                move.w  #100,addiert+2(A0)
                move.l  D0,addiert_rest(A0)
                move.w  #(' '-32)*16,char(A0)
                move.w  D7,phase(A0)
                lea     laenge(A0),A0
                dbra    D7,init_loop

                lea     res_adr,A0
                lea     res_adr2,A1
                movea.l screen1,A2
                adda.l  #160*100+40,A2
                moveq   #32-1,D0
init_res:       move.l  A2,(A0)+
                move.l  A2,(A1)+
                dbra    D0,init_res

                lea     char_struktur,A6
                moveq   #160,D0
                moveq   #100,D1
;                bsr     newchar

                movem.l pal(PC),D0-D7
                movem.l D0-D7,$FFFF8240.w

                ENDPART
                >PART 'Main-Rout'

                jsr     musix
                move.l  #newvbl,$00000070.w
                move.w  #-1,ende_flag
endlos:         move.b  $FFFFFC02.w,D0
                cmp.b   #$39,D0
                beq     ende_dentro     ; Ende
                cmp.b   #98,D0          ; Help ?
                bne     no_2help
                tst.w   game_flag       ; schon gesetzt ?
                bne     no_2help
                not.w   game_flag
                move.w  D0,-(SP)
                movem.l game_palette,D0-D7
                movem.l D0-D7,unten_pal
                movem.l pal,D0-D7
                movem.l D0-D7,questie_pal
                move.w  (SP)+,D0
                move.l  #32*160,scr_patch+2 ; um 32 Pixel nach unten veschieben
                move.w  #199-30,patchr2+2 ; Raster nach oben verschieben
                move.l  #raster_versch,patchr1+2 ; neue Routine

                moveq   #-1,D0
                movea.l screen2,A0
                adda.l  #285*160,A0
                move.w  D0,(A0)
                move.w  D0,160(A0)
                move.w  D0,320(A0)
                move.w  D0,480(A0)
                move.w  D0,640(A0)
                move.w  D0,800(A0)
                move.w  D0,960(A0)
                move.w  D0,1120(A0)
                move.w  D0,8(A0)
                move.w  D0,168(A0)
                move.w  D0,328(A0)
                move.w  D0,488(A0)
                move.w  D0,648(A0)
                move.w  D0,808(A0)
                move.w  D0,968(A0)
                move.w  D0,1128(A0)

                moveq   #-1,D0
                movea.l screen1,A0
                adda.l  #285*160,A0
                move.w  D0,(A0)
                move.w  D0,160(A0)
                move.w  D0,320(A0)
                move.w  D0,480(A0)
                move.w  D0,640(A0)
                move.w  D0,800(A0)
                move.w  D0,960(A0)
                move.w  D0,1120(A0)
                move.w  D0,8(A0)
                move.w  D0,168(A0)
                move.w  D0,328(A0)
                move.w  D0,488(A0)
                move.w  D0,648(A0)
                move.w  D0,808(A0)
                move.w  D0,968(A0)
                move.w  D0,1128(A0)

                movea.l screen1,A0
                movea.l screen2,A1
                adda.l  #231*160,A0
                adda.l  #231*160,A1
                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4
                moveq   #0,D5
                moveq   #0,D6
                moveq   #0,D7
                movem.l D0-D7,-(A0)
                movem.l D0-D7,-(A1)
                movem.l D0-D7,-(A0)
                movem.l D0-D7,-(A1)
                movem.l D0-D7,-(A0)
                movem.l D0-D7,-(A1)
                movem.l D0-D7,-(A0)
                movem.l D0-D7,-(A1)
                movem.l D0-D7,-(A0)
                movem.l D0-D7,-(A1)


no_2help:       tst.w   ende_flag
                beq.s   ende_dentro
                tst.w   game_flag
                beq     endlos

                move.b  #0,joydata
                cmp.b   #72,D0          ; Pfeil nach oben
                bne.s   no_up
                bset    #0,joydata
no_up:          cmp.b   #75,D0          ; Pfeil links
                bne.s   no_left
                bset    #2,joydata
no_left:        cmp.b   #77,D0          ; Pfeil rechts
                bne.s   no_right
                bset    #3,joydata
no_right:       cmp.b   #80,D0          ; Pfeil unten
                bne.s   no_down
                bset    #1,joydata
no_down:        cmp.b   #28,D0          ; Return ?
                bne.s   no_return
                bset    #7,joydata
no_return:      bsr     game            ; wartet auch auf VBL !!!!!!!
                bra     endlos

ende_dentro:    jsr     musix+4
                move.l  #sync_vbl,$00000070.w
                clr.w   sync_wert
waitvbl2:       tst.w   sync_wert
                beq.s   waitvbl2
                move.w  oldscreen,D0
                lea     $FFFF8201.w,A0
                movep.w D0,0(A0)
                move.b  oldres(PC),$FFFF8260.w

                move.b  old07,$FFFFFA07.w
                move.b  old09,$FFFFFA09.w
                move.b  old13,$FFFFFA13.w
                move.b  old15,$FFFFFA15.w

                move.l  oldvbl(PC),$00000070.w
                move.l  old120,$00000120.w
                move.l  old118,$00000118.w
                rts
raster_move:    DS.W 1
oldsp:          DS.L 1
oldvbl:         DS.L 1
old120:         DS.L 1
old118:         DS.L 1
oldres:         DS.W 1
old07:          DS.B 1
old09:          DS.B 1
old13:          DS.B 1
old15:          DS.B 1
sync_vbl:       addq.w  #1,sync_wert
                rte
sync_wert:      DS.W 1
screen_flag:    DS.B 1
                EVEN
                ENDPART
                >PART 'VBL'
newvbl:         move    #$2700,SR
                clr.b   $FFFFFA1B.w

                move.l  screen1,D0      ; 16
                move.l  screen2,screen1 ; 36
                move.l  D0,screen2      ; 20

                move.l  screen2,D0      ; 16
scr_patch:      add.l   #0,D0           ; 16
                lsr.l   #8,D0           ; 22
                lea     $FFFF8201.w,A0  ; 8
                movep.w D0,0(A0)        ; 16

                movem.l questie_pal,D0-D6 ;     20+8n = 76
                movem.l D0-D6,$FFFF8240.w ;     12+8n = 68
                move.w  questie_pal+14*2,$FFFF825C.w ;  24

; *************************************************
                btst    #0,screen_flag  ; 16
                beq.s   res2_cl         ; jump:12   not: 8
                lea     res_adr2,A0     ; 12
                bra.s   clear_chars     ; 12
res2_cl:        lea     res_adr,A0      ; 12
                nop
                nop
clear_chars:
                moveq   #0,D0           ; 4
                REPT 32
                movea.l (A0)+,A1        ; 12
                move.w  D0,(A1)         ; 8
                move.w  D0,8(A1)        ; 12*15
                move.w  D0,160(A1)
                move.w  D0,168(A1)
                move.w  D0,320(A1)
                move.w  D0,328(A1)
                move.w  D0,480(A1)
                move.w  D0,488(A1)
                move.w  D0,640(A1)
                move.w  D0,648(A1)
                move.w  D0,800(A1)
                move.w  D0,808(A1)
                move.w  D0,960(A1)
                move.w  D0,968(A1)
                move.w  D0,1120(A1)
                move.w  D0,1128(A1)
                ENDR

; *************************************************

                movea.l sprite_save1(PC),A0 ; Sprite lîschen       16
                moveq   #0,D0           ;                          4
.off            SET 0
                REPT 16
                move.l  D0,.off(A0)     ;                          16
                move.l  D0,.off+8(A0)   ;                          16
.off            SET .off+160
                ENDR

                movea.l sprite_save2(PC),A0 ; Sprite lîschen       16
                moveq   #0,D0           ;                          4
.off            SET 0
                REPT 16
                move.l  D0,.off(A0)     ;                          16
                move.l  D0,.off+8(A0)   ;                          16
.off            SET .off+160
                ENDR

                REPT 4086-1613-133-4 ; 4295
                nop                     ; 17180 Tkz
                ENDR

                clr.b   $FFFF820A.w
                REPT 10
                nop                     ; 40 Tkz
                ENDR
                move.b  #2,$FFFF820A.w
                move    #$2100,SR
                movem.l D0-A6,-(SP)

                clr.b   $FFFFFA1B.w
                move.l  #raster_questie,$00000120.w
                move.b  #29,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w

                move.l  #raster,$00000068.w
                move.w  #tab-raster,D0
                add.w   raster_move(PC),D0
                move.w  D0,raster+2

                addq.w  #1,_vblz
                movea.l screen2,A1
                adda.l  #231*160,A1
                move.l  A1,screen

                lea     tab(PC),A0
                adda.w  raster_move(PC),A0
                move.w  (A0),$FFFF8240+30.w
                addq.w  #2,raster_move
                cmpi.w  #anz_farben*2,raster_move
                blo.s   no_new_raster
                move.w  #0,raster_move
no_new_raster:
                bchg    #0,screen_flag
                beq.s   screen1_rout
                lea     clearbuf2,A0
                bra.s   c1lear
screen1_rout:   lea     clearbuf1,A0
c1lear:         moveq   #0,D1

                tst.w   game_flag
                bne     game_on
                REPT (anz_stars/7)-1
                movem.l (A0)+,A1-A6
                move.l  D1,(A1)
                move.l  D1,24(A1)
                move.l  D1,-24(A1)
                move.l  D1,(A2)
                move.l  D1,24(A2)
                move.l  D1,-24(A2)
                move.l  D1,(A3)
                move.l  D1,24(A3)
                move.l  D1,-24(A3)
                move.l  D1,(A4)
                move.l  D1,24(A4)
                move.l  D1,-24(A4)
                move.l  D1,(A5)
                move.l  D1,24(A5)
                move.l  D1,-24(A5)
                move.l  D1,(A6)
                move.l  D1,24(A6)
                move.l  D1,-24(A6)
                ENDR
                bra     ende_cl_star
game_on:        REPT (anz_game/7)-1
                movem.l (A0)+,A1-A6
                move.l  D1,(A1)
                move.l  D1,24(A1)
                move.l  D1,-24(A1)
                move.l  D1,(A2)
                move.l  D1,24(A2)
                move.l  D1,-24(A2)
                move.l  D1,(A3)
                move.l  D1,24(A3)
                move.l  D1,-24(A3)
                move.l  D1,(A4)
                move.l  D1,24(A4)
                move.l  D1,-24(A4)
                move.l  D1,(A5)
                move.l  D1,24(A5)
                move.l  D1,-24(A5)
                move.l  D1,(A6)
                move.l  D1,24(A6)
                move.l  D1,-24(A6)
                ENDR
ende_cl_star:
                movem.l (A0),A1-A6
                move.l  D1,(A1)
                move.l  D1,24(A1)
                move.l  D1,-24(A1)
                move.l  D1,(A2)
                move.l  D1,24(A2)
                move.l  D1,-24(A2)
                move.l  D1,(A3)
                move.l  D1,24(A3)
                move.l  D1,-24(A3)
                move.l  D1,(A4)
                move.l  D1,24(A4)
                move.l  D1,-24(A4)
                move.l  D1,(A5)
                move.l  D1,24(A5)
                move.l  D1,-24(A5)
                move.l  D1,(A6)
                move.l  D1,24(A6)
                move.l  D1,-24(A6)

                movea.l blasen_1_1,A0
                move.w  (A0)+,D0
                move.w  (A0)+,D1
                addq.w  #4,A0
                cmpa.l  #ende_koo,A0
                blt.s   nix_new_w12
                suba.w  #ende_koo-blasen_koo,A0
nix_new_w12:    move.l  A0,blasen_1_1

                movea.l blasen_1,A0
                add.w   (A0)+,D0
                add.w   (A0)+,D1
                addq.w  #8,A0
                cmpa.l  #ende_koo,A0
                blt.s   nix_new_w1
                suba.w  #ende_koo-blasen_koo,A0
nix_new_w1:     move.l  A0,blasen_1
                add.w   #160-7,D0
                add.w   #100,D1

                btst    #0,fly_flag
                beq.s   no11_set1
                move.w  D0,start_fly_x+2
                move.w  D1,start_fly_y+2
no11_set1:
                lea     sprite_save1,A1
                movea.l screen1,A0
                adda.l  #29*160,A0
                bsr     set_sprite

                movea.l blasen_2_1,A0
                move.w  (A0)+,D0
                move.w  (A0)+,D1
                addq.w  #8,A0
                cmpa.l  #ende_koo,A0
                blt.s   nix_new_w21
                suba.w  #ende_koo-blasen_koo,A0
nix_new_w21:    move.l  A0,blasen_2_1

                movea.l blasen_2,A0
                add.w   (A0)+,D0
                add.w   (A0)+,D1
                addq.w  #4,A0
                cmpa.l  #ende_koo,A0
                blt.s   nix_new_w2
                suba.w  #ende_koo-blasen_koo,A0
nix_new_w2:     move.l  A0,blasen_2
                add.w   #160-7,D0
                add.w   #100,D1

                bchg    #0,fly_flag
                bne.s   set22222
                move.w  D0,start_fly_x+2
                move.w  D1,start_fly_y+2
set22222:
                lea     sprite_save2,A1
                movea.l screen1,A0
                adda.l  #29*160,A0
                bsr     set_sprite_or

                move.b  $FFFFFC02.w,D0  ; ******

                bsr     L0011

                tst.w   clear_text_flag
                beq.s   fly
                subq.w  #1,fly_verz
                bne.s   fly
                move.w  #1,fly_verz
                move.w  clear_command,D0
                lea     clear_rout_tab,A0
                movea.l 0(A0,D0.w),A0
                jsr     (A0)
                bra.s   no_fly
fly:            bsr     flychars
no_fly:
                IF speed=1
                move.w  #$0707,$FFFF8240.w
                ENDC
                move.b  $FFFFFC02.w,D0  ; ******
                jsr     musix+8
                move.b  $FFFFFC02.w,D0  ; ******
                IF speed=1
                move.w  #$0700,$FFFF8240.w
                ENDC
                movem.l (SP)+,D0-A6
                move.w  #$2100,(SP)
                rte
fly_flag:       DS.W 1
sprite_save1:   DS.L 1
sprite_save2:   DS.L 1
fly_verz:       DC.W 1
oldsr:          DS.W 1
oldstack:       DS.L 1
pal:            DC.W $0000,$0222,$0444,$0777,$0003,$0003,$0003,$0003
                DC.W $0007,$0007,$0007,$0007,$0007,$0007,$0007,$0700
clear_sprite_adr:DS.L 2
                ENDPART
                >PART 'Raster'
raster:         move.w  tab(PC),$FFFF8240+30.w
                addq.w  #2,raster+2
                rte
raster_questie: clr.b   $FFFFFA1B.w
                pea     (A1)
                pea     (A0)
                lea     pal,A0
                lea     $FFFF8240.w,A1
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.w  (A0),(A1)
                movem.l (SP)+,A0-A1
patchr1:        move.l  #raster_unten,$00000120.w
patchr2:        move.b  #199,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                rte

raster_versch:  movem.l A0-A1,-(SP)
                lea     unten_pal,A0
                lea     $FFFF8240.w,A1
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.w  (A0),(A1)
                movem.l (SP)+,A0-A1
                clr.b   $FFFFFA1B.w
                move.b  #30,$FFFFFA21.w
                move.l  #raster_unten,$00000120.w
                move.b  #8,$FFFFFA1B.w
                rte

raster_unten:   movem.l D0/A0,-(SP)
                lea     $FFFFFA21.w,A0
                move.b  (A0),D0
wait_unten:     cmp.b   (A0),D0
                beq.s   wait_unten
                clr.b   $FFFF820A.w
                moveq   #3,D0
wait_unten2:    nop
                dbra    D0,wait_unten2
                move.b  #2,$FFFF820A.w
                pea     (A1)
                lea     unten_pal,A0
                lea     $FFFF8240.w,A1
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.w  (A0),(A1)
                movea.l (SP)+,A1

                movem.l (SP)+,D0/A0
                rte

wait:           move.b  $FFFF8209.w,D0
                beq.s   wait
                not.b   D0
                lsl.b   D0,D0


anz_farben      EQU 345
tab:            DC.W $0101,$0000,$0101,$0101,$0202,$0101,$0202,$0202,$0303,$0202,$0303,$0303,$0404
                DC.W $0303,$0404,$0404,$0404,$0505,$0404,$0505,$0505,$0606,$0505,$0606,$0606,$0707
                DC.W $0606,$0707,$0707,$0716,$0707,$0716,$0716,$0725,$0716,$0725,$0725,$0734,$0725
                DC.W $0734,$0734,$0743,$0734,$0743,$0743,$0752,$0743,$0752,$0752,$0761,$0752,$0761
                DC.W $0761,$0770,$0761,$0770,$0770,$0760,$0770,$0760,$0760,$0750,$0760,$0750,$0750
                DC.W $0740,$0750,$0740,$0740,$0730,$0740,$0730,$0730,$0720,$0730,$0720,$0720,$0710
                DC.W $0720,$0710,$0710,$0700,$0710,$0700,$0700,$0701,$0700,$0701,$0701,$0702,$0701
                DC.W $0702,$0702,$0703,$0702,$0703,$0703,$0704,$0703,$0704,$0704,$0705,$0704,$0705
                DC.W $0705,$0706,$0706,$0707,$0706,$0707,$0707,$0607,$0707,$0607,$0607,$0507,$0607
                DC.W $0507,$0507,$0407,$0507,$0407,$0407,$0307,$0407,$0307,$0307,$0207,$0307,$0207
                DC.W $0207,$0107,$0207,$0107,$0107,$0007,$0107,$0007,$0007,$0006,$0007,$0006,$0006
                DC.W $0005,$0006,$0005,$0005,$0004,$0005,$0004,$0004,$0003,$0004,$0003,$0003,$0002
                DC.W $0003,$0002,$0002,$0001,$0002,$0001,$0001,$0000,$0001
                DC.W $0000,$0001,$0000,$0001,$0001,$0001,$0001,$0001,$0002,$0001,$0002
                DC.W $0002,$0002,$0002,$0002,$0003,$0002,$0003,$0003,$0003,$0003,$0003,$0004
                DC.W $0003,$0004,$0004,$0004,$0004,$0004,$0005,$0004,$0005,$0005,$0005
                DC.W $0005,$0005,$0006,$0005,$0006,$0006,$0006,$0006,$0006,$0116,$0006
                DC.W $0116,$0116,$0116,$0116,$0116,$0226,$0116,$0226,$0226,$0226,$0226,$0226
                DC.W $0336,$0226,$0336,$0336,$0336,$0336,$0336,$0446,$0336,$0446,$0446
                DC.W $0446,$0446,$0446,$0556,$0446,$0556,$0556,$0556,$0556,$0556,$0666
                DC.W $0556,$0666,$0666,$0666,$0666,$0666,$0776,$0666,$0776,$0776,$0776,$0776
                DC.W $0776,$0775,$0776,$0775,$0775,$0775,$0775,$0775,$0774,$0775,$0774
                DC.W $0774,$0774,$0774,$0774,$0773,$0774,$0773,$0773,$0773,$0773,$0773,$0772
                DC.W $0773,$0772,$0772,$0772,$0772,$0772,$0771,$0772,$0771,$0771,$0771
                DC.W $0771,$0771,$0770,$0771,$0770,$0770,$0770,$0770,$0770,$0750,$0770
                DC.W $0750,$0750,$0750,$0750,$0750,$0740,$0750,$0740,$0740,$0740,$0740,$0740
                DC.W $0630,$0740,$0630,$0630,$0630,$0630,$0630,$0520,$0630,$0520,$0520
                DC.W $0520,$0520,$0520,$0410,$0520,$0410,$0410,$0410,$0410,$0410,$0300
                DC.W $0410,$0300,$0300,$0300,$0300,$0300,$0200,$0300,$0200,$0100

                DC.W $0101,$0000,$0101,$0101,$0202,$0101,$0202,$0202,$0303,$0202,$0303,$0303,$0404
                DC.W $0303,$0404,$0404,$0404,$0505,$0404,$0505,$0505,$0606,$0505,$0606,$0606,$0707
                DC.W $0606,$0707,$0707,$0716,$0707,$0716,$0716,$0725,$0716,$0725,$0725,$0734,$0725
                DC.W $0734,$0734,$0743,$0734,$0743,$0743,$0752,$0743,$0752,$0752,$0761,$0752,$0761
                DC.W $0761,$0770,$0761,$0770,$0770,$0760,$0770,$0760,$0760,$0750,$0760,$0750,$0750
                DC.W $0740,$0750,$0740,$0740,$0730,$0740,$0730,$0730,$0720,$0730,$0720,$0720,$0710
                DC.W $0720,$0710,$0710,$0700,$0710,$0700,$0700,$0701,$0700,$0701,$0701,$0702,$0701
                DC.W $0702,$0702,$0703,$0702,$0703,$0703,$0704,$0703,$0704,$0704,$0705,$0704,$0705
                DC.W $0705,$0706,$0706,$0707,$0706,$0707,$0707,$0607,$0707,$0607,$0607,$0507,$0607
                DC.W $0507,$0507,$0407,$0507,$0407,$0407,$0307,$0407,$0307,$0307,$0207,$0307,$0207
                DC.W $0207,$0107,$0207,$0107,$0107,$0007,$0107,$0007,$0007,$0006,$0007,$0006,$0006
                DC.W $0005,$0006,$0005,$0005,$0004,$0005,$0004,$0004,$0003,$0004,$0003,$0003,$0002
                DC.W $0003,$0002,$0002,$0001,$0002,$0001,$0001,$0000,$0001
                DC.W $0000,$0001,$0000,$0001,$0001,$0001,$0001,$0001,$0002,$0001,$0002
                DC.W $0002,$0002,$0002,$0002,$0003,$0002,$0003,$0003,$0003,$0003,$0003,$0004
                DC.W $0003,$0004,$0004,$0004,$0004,$0004,$0005,$0004,$0005,$0005,$0005
                DC.W $0005,$0005,$0006,$0005,$0006,$0006,$0006,$0006,$0006,$0116,$0006
                DC.W $0116,$0116,$0116,$0116,$0116,$0226,$0116,$0226,$0226,$0226,$0226,$0226
                DC.W $0336,$0226,$0336,$0336,$0336,$0336,$0336,$0446,$0336,$0446,$0446
                DC.W $0446,$0446,$0446,$0556,$0446,$0556,$0556,$0556,$0556,$0556,$0666
                DC.W $0556,$0666,$0666,$0666,$0666,$0666,$0776,$0666,$0776,$0776,$0776,$0776
                DC.W $0776,$0775,$0776,$0775,$0775,$0775,$0775,$0775,$0774,$0775,$0774
                DC.W $0774,$0774,$0774,$0774,$0773,$0774,$0773,$0773,$0773,$0773,$0773,$0772
                DC.W $0773,$0772,$0772,$0772,$0772,$0772,$0771,$0772,$0771,$0771,$0771
                DC.W $0771,$0771,$0770,$0771,$0770,$0770,$0770,$0770,$0770,$0750,$0770
                DC.W $0750,$0750,$0750,$0750,$0750,$0740,$0750,$0740,$0740,$0740,$0740,$0740
                DC.W $0630,$0740,$0630,$0630,$0630,$0630,$0630,$0520,$0630,$0520,$0520
                DC.W $0520,$0520,$0520,$0410,$0520,$0410,$0410,$0410,$0410,$0410,$0300
                DC.W $0410,$0300,$0300,$0300,$0300,$0300,$0200,$0300,$0200,$0100

                IFNE 0
                DC.W $0200,$0200,$0300,$0200,$0300,$0300,$0400,$0300,$0400,$0400,$0500
                DC.W $0600,$0600,$0700,$0600,$0720,$0720,$0720,$0730,$0730,$0740,$0730
                DC.W $0740,$0740,$0750,$0740,$0750,$0750,$0760,$0750,$0760,$0760,$0770
                DC.W $0670,$0670,$0770,$0670,$0570,$0570,$0670,$0570,$0470,$0470,$0570
                DC.W $0470,$0470,$0570,$0470,$0360,$0360,$0370,$0360,$0250,$0250,$0260,$0250
                DC.W $0240,$0240,$0250,$0240,$0130,$0130,$0140,$0130,$0020,$0030,$0020,$0020
                DC.W $0022,$0022,$0023,$0022,$0023,$0023,$0024,$0023,$0024,$0024,$0025,$0024
                DC.W $0025,$0025,$0026,$0025,$0026,$0026,$0026,$0027,$0026,$0007,$0007,270,$0007
                ENDC

                ENDPART
                >PART 'Sterneinit.'
L0009:          lea     init_tab,A0
                moveq   #0,D1
L000A:          move.w  #-128,D0
L000B:          move.w  D0,D2
                muls    #50,D2
                move.l  D2,D3
                tst.w   D1
                beq.s   L000C
                divs    D1,D3
L000C:          add.w   #160,D3
                cmp.w   #320,D3         ; wenn X-Koo > 320
                blt.s   L001522         ; dann nicht zeichnen
                moveq   #-1,D3
                bra.s   speichern
L001522:        cmp.w   #100-16,D3
                bhi.s   no_i1
                moveq   #-1,D3
                bra.s   speichern

no_i1:          cmp.w   #320-100+16,D3
                blo.s   speichern
                moveq   #-1,D3
speichern:      move.w  D3,(A0)+
                addq.w  #1,D0
                cmp.w   #128,D0
                bne.s   L000B
                addq.w  #1,D1
                cmp.w   #128,D1
                bne.s   L000A

                lea     init_tab2,A0
                moveq   #0,D1
L000A2:         move.w  #-128,D0
L000B2:         move.w  D0,D2
                muls    #50,D2
                move.l  D2,D3
                tst.w   D1
                beq.s   L000C2
                divs    D1,D3
L000C2:         add.w   #100,D3
                cmp.w   #200,D3
                blt.s   L000C22
                moveq   #-1,D3
L000C22:        add.w   D3,D3
                add.w   D3,D3
                move.w  D3,(A0)+
                addq.w  #1,D0
                cmp.w   #128,D0
                bne.s   L000B2
                addq.w  #1,D1
                cmp.w   #128,D1
                bne.s   L000A2

                move.w  #anz_stars-1,D0
                lea     star_tab,A0     ; Sterne mit Zufallswerten init.
                move.l  #-$0808080C,D1
                move.l  #-$0DE0AC07,D2
L000D:          bsr.s   zufall
                move.w  D1,D3
                andi.w  #$01FE,D3       ; begrenzen
                move.w  D3,(A0)+        ; und speichern
                bsr.s   zufall
                move.w  D1,D3
                andi.w  #$01FE,D3
                move.w  D3,(A0)+
                bsr.s   zufall
                move.w  D1,D3
                andi.w  #$00FE,D3
                move.w  D3,(A0)+
                dbra    D0,L000D
                rts
zufall:         add.l   D1,D2
                addi.l  #$00FF8201,D2
                eor.l   D2,D1
                swap    D1
                rol.l   D0,D1
                rol.l   #1,D2
                add.l   D2,D1
                rts
                ENDPART
                >PART 'Starfield'
winkel:         DC.W 0,0,0
LLL1:           DS.W 1
L0011:          lea     init_tab,A0
                lea     init_tab2,A6
                lea     star_tab,A1
                btst    #0,screen_flag
                beq.s   rout1
                lea     clearbuf1,A4
                lea     screen160add1(PC),A5
                bra.s   weiter_nach_screen
rout1:          lea     clearbuf2,A4
                lea     screen160add2(PC),A5
weiter_nach_screen:
                tst.w   game_flag
                bne.s   weniger
                move.w  #anz_stars-1,D0
                bra.s   we_we
weniger:        move.w  #anz_game-1,D0
we_we:
                movem.w winkel(PC),D1-D3
                move.l  #$000001FE,D7
star_loop:      movem.w (A1)+,D4-D6     ; Koo holen
                add.w   D1,D4           ; und Bewegung ausfuehren
                add.w   D2,D5
                add.w   D3,D6

                and.w   D7,D4           ; begrenzen und nur gerade Werte
                and.w   D7,D5
                andi.w  #254,D6

                lsl.w   #8,D6           ; Z-Koo*256
                add.w   D6,D4           ; X-Koo + (Z-Koo*256)
                add.w   D6,D5           ; Y-Koo + (Z-Koo*256)
                move.w  0(A0,D4.l),D4   ; und Wert aus Tabelle holen
                blt.s   nix_draw        ; X-Koo < 0 dann nicht zeichnen
                move.w  0(A6,D5.l),D5
                blt.s   nix_draw        ; Y-Koo < 0 dann nicht zeichnen

                movea.l 0(A5,D5.w),A3

                move.w  D4,D5           ; X-Koo retten
                and.w   #-$0010,D4
                lsr.w   #1,D4
                adda.w  D4,A3           ; und auf 16'er Position bringen

                and.w   #$000F,D5       ; und auf 16 begrenzen
                move.l  A3,(A4)+        ; Screenadresse zum lîschen retten

                add.w   D5,D5
                add.w   D5,D5
                move.l  plot_tab(PC,D5.w),D5

                sub.w   #85*256,D6
                bcs.s   star1
                sub.w   #85*256,D6
                bcs.s   star2

                or.w    D5,(A3)
                or.w    D5,24(A3)
                or.w    D5,-24(A3)
                dbra    D0,star_loop
                bra.s   ende_star

star2:          or.w    D5,2(A3)
                or.w    D5,26(A3)
                or.w    D5,-22(A3)
                dbra    D0,star_loop
                bra.s   ende_star

star1:          or.l    D5,(A3)
                or.l    D5,24(A3)
                or.l    D5,-24(A3)
nix_draw:       dbra    D0,star_loop
                bra.s   ende_star
plot_tab:       DC.W %1000000000000000,%1000000000000000
                DC.W %0100000000000000,%0100000000000000
                DC.W %0010000000000000,%0010000000000000
                DC.W %0001000000000000,%0001000000000000
                DC.W %0000100000000000,%0000100000000000
                DC.W %0000010000000000,%0000010000000000
                DC.W %0000001000000000,%0000001000000000
                DC.W %0000000100000000,%0000000100000000
                DC.W %0000000010000000,%0000000010000000
                DC.W %0000000001000000,%0000000001000000
                DC.W %0000000000100000,%0000000000100000
                DC.W %0000000000010000,%0000000000010000
                DC.W %0000000000001000,%0000000000001000
                DC.W %0000000000000100,%0000000000000100
                DC.W %0000000000000010,%0000000000000010
                DC.W %0000000000000001,%0000000000000001
ende_star:
winkel1:        addi.w  #0,winkel       ; Bewegung X
winkel2:        addi.w  #0,winkel+2     ; Bewegung Y
winkel3:        addi.w  #-4,winkel+4    ; Bewegung Z
                andi.w  #510,winkel
                andi.w  #510,winkel+2
                andi.w  #254,winkel+4
                rts
screen160add1:
.zaehler        SET 0
                REPT 200
                DC.L .zaehler
.zaehler        SET .zaehler+160
                ENDR
screen160add2:
.zaehler        SET 0
                REPT 200
                DC.L .zaehler
.zaehler        SET .zaehler+160
                ENDR
                ENDPART
                >PART 'Flying Chars'
flychars:       lea     char_struktur,A6
                btst    #0,screen_flag
                beq.s   res2
                lea     res_adr,A5
                bra.s   weiter_res
res2:           lea     res_adr2,A5
weiter_res:     moveq   #32-1,D7
print_loop:     movea.l screen2,A4
                adda.w  #30*160+4,A4
                tst.w   phase(A6)
                bne.s   no_other_plane
; *******************************
                addq.w  #2,A4
                move.w  type(A6),D0
                lea     type_add_tab2(PC),A0
                adda.w  0(A0,D0.w),A0
                jsr     (A0)
                movea.l screen1,A4
                adda.w  #30*160+4+2,A4
                move.w  type(A6),D0
                lea     type_add_tab(PC),A0
                adda.w  0(A0,D0.w),A0
                jsr     (A0)
                bra.s   no_draw_normal
; *******************************
no_other_plane: move.w  type(A6),D0
                lea     type_add_tab(PC),A0
                adda.w  0(A0,D0.w),A0
                jsr     (A0)
no_draw_normal: subq.w  #1,phase(A6)
                bpl     no_new_char
                move.l  #leer,-4(A5)
                movea.l text_pointer(PC),A0
                tst.b   1(A0)
                bpl.s   no_new_text
                lea     text(PC),A0
no_new_text:    move.w  curx(PC),D2
                move.w  cury(PC),D3
                addq.w  #1,curx
                cmpi.w  #320/8-5,curx
                bne     no_new_line
                move.w  #5,curx
                addq.w  #1,cury
                cmpi.w  #200/8-1,cury
                bne.s   no_new_line

                tst.w   space_text
                beq.s   clear_jump
                subq.w  #1,space_text
                move.w  #320/8-5-1,curx
                subq.w  #1,cury
                moveq   #100,D0
                moveq   #100,D1
                moveq   #100,D2
                moveq   #100,D3
                pea     (A0)            ; Textzeiger speichern
                lea     leer_space(PC),A0
                bsr     newchar
                movea.l (SP)+,A0
                bra     no_new_char
clear_jump:     move.w  #32*20,space_text ; !!!!!!!!!!!!!
                move.w  #1,cury
                move.w  #5,curx
                pea     (A0)
                movea.l text_pointer,A0
                addq.w  #1,A0
                tst.b   (A0)
                bpl.s   no_new_text2
                lea     text(PC),A0
no_new_text2:   move.l  A0,text_pointer
                movea.l (SP)+,A0
                bsr     clear_text
                bra.s   no_new_char

no_new_line:    tst.w   clear_text_flag
                bmi.s   no_new_char_le
                lsl.w   #3,D2
                lsl.w   #3,D3
start_fly_x:    move.w  #160,D0
start_fly_y:    move.w  #100,D1
                add.w   #4,D0
                add.w   #4,D1
                bsr     newchar
                move.l  A0,text_pointer
                bra.s   no_new_char

no_new_char_le: move.w  D2,curx
                move.w  D3,cury
                moveq   #100,D0
                moveq   #100,D1
                moveq   #100,D2
                moveq   #100,D3
                pea     (A0)            ; Textzeiger speichern
                lea     leer_space(PC),A0
                bsr     newchar
                movea.l (SP)+,A0

no_new_char:    lea     laenge(A6),A6
                dbra    D7,print_loop
ende_aus:       rts
leer_space:     DC.B "                   "
                EVEN
; ************************************************
type_add_tab:   DC.W type1-type_add_tab
                DC.W type2-type_add_tab
                DC.W type3-type_add_tab
                DC.W type4-type_add_tab
type_add_tab2:  DC.W type1_2-type_add_tab2
                DC.W type2_2-type_add_tab2
                DC.W type3_2-type_add_tab2
                DC.W type4_2-type_add_tab2
space_text:     DC.W 32
text_pointer:   DC.L text

; HIER KôNNT IHR IRDENDWO EUREN TEXT REINKLATSCHEN. IHR MöûT ABER BEACHTEN
; DAS IHR MIT DEN SEITEN NACHHER WIEDER öBEREINSTIMMT!!!
; FALLS IHR NOCH ENGLISCH-FEHLER FINDET (UND DAS WERDET IHR SICHER !!)
; DANN BITTE KORRIGIEREN...

; X = 30
; Y = 23
text:           DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "        HELLO THERE !!!       "
                DC.B "                              "
                DC.B " THIS IS THE GREETINGS-SCREEN "
                DC.B " OF OUR LITTLE PARTY-DEMO.... "
                DC.B "                              "
                DC.B "...AND THIS IS ALSO THE GUEST-"
                DC.B "SCREEN BY QUESTOR OF INTER !!!"
                DC.B "                              "
                DC.B "WELL, THIS IS MATT NOW WRITING"
                DC.B "THE FIRST PAGES IN THIS TEXT.."
                DC.B "                              "
                DC.B "VERY SOON YOU WILL SEE FOR THE"
                DC.B "2ND TIME IN HISTORY A COMPLETE"
                DC.B "STAX GREETS-LIST, BUT JUST LET"
                DC.B "ME TELL YOU SOME QUICK THINGS "
                DC.B "BEFORE....                    "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "



                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "AFTER THIS TEXT (CALL IT STAX-"
                DC.B "TEXT) THERE WILL COME ANOTHER "
                DC.B "ONE WHICH WAS TYPED BY INTER.."
                DC.B "                              "
                DC.B " SINCE THIS IS A STAX-DEMO I  "
                DC.B "WANNA POINT OUT THAT STAX HAS "
                DC.B "  NOTHING TO DO WITH ALL THE  "
                DC.B "     TEXT FROM INTER...       "
                DC.B "                              "
                DC.B "AND TO MAKE IT CLEAR, WE HAVE "
                DC.B "ESPECIALLY NOTHING TO DO WITH "
                DC.B "      THEIR GREETINGS...      "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "BUT NOW LETS BEGIN THE GREETS,"
                DC.B "     GET A COKE AND WEAP'EM..."
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "




                DC.B "                              "
                DC.B "                              "
                DC.B "MEGA PLATINUM COMPLIMENTS ARE "
                DC.B "GOING TO FOLLOWING PEOPLE...  "
                DC.B "                              "
                DC.B "                              "
                DC.B "      ALL MEMBERS OF NPG      "
                DC.B "                              "
                DC.B "      ALL MEMBERS OF TTK      "
                DC.B "                              "
                DC.B "     ALL MEMBERS OF INTER     "
                DC.B "                              "
                DC.B "      BREAKPOINT SOFTWARE     "
                DC.B "                              "
                DC.B "         DARREN LOMAX         "
                DC.B "                              "
                DC.B "      BANANA JOE IN KONGO     "
                DC.B "                              "
                DC.B "            MIRAGE            "
                DC.B "                              "
                DC.B "   ALL MEMBERS OF TIGERSOFT   "
                DC.B "                              "
                DC.B "                              "



                DC.B "        GREETINGS TO:         "
                DC.B "                              "
                DC.B "THE ADMIRABLES (NIRVANA,STURM)"
                DC.B "AMBASSADORS    (DIGITAL BRAIN)"
                DC.B "ANIMAL MINE      (ALL MEMBERS)"
                DC.B "AURA                     (BDC)"
                DC.B "BIZONIA                       "
                DC.B "BREAKPOINT SOFTWARE      (JON)"
                DC.B "CHANNEL 5                     "
                DC.B "CHANNEL 38                    "
                DC.B "CHARON                        "
                DC.B "CRAZY GANG            (ROBERT)"
                DC.B "CROSSBONES           (THE FOX)"
                DC.B "CYCLONES             (MR.COKE)"
                DC.B "DARREN LOMAX                  "
                DC.B "D.B.A.          (BONUS,TRONIC)"
                DC.B "DETONATORS (H-CL,BEWEISE,NOFX)"
                DC.B "DIAMOND DESIGN          (DRAX)"
                DC.B "DNT-CREW               (FLIPS)"
                DC.B "DULL                 (XTC ONE)"
                DC.B "ETERNITY            (DARKMIND)"
                DC.B "FAA                           "
                DC.B "                              "

                DC.B "FREESTYLE CREW        (SMILEY)"
                DC.B "GELLY SOFT INC.          (ROB)"
                DC.B "HEMOROIDS            (JURI 17)"
                DC.B "INTER                (QUESTOR)"
                DC.B "KRUZ                   (GOZER)"
                DC.B "LAZER  (PHOTON,ST NINJA,PETER)"
                DC.B "LENSH MOB                (DOC)"
                DC.B "MIK                           "
                DC.B "MR.COOL                       "
                DC.B "NEW TREND   (MR.BOND,LIG LURY)"
                DC.B "NEWLINE             (TIN,JURI)"
                DC.B "NPG     (CARNERA,APOLLO,JARON)"
                DC.B "PAULO SIMOES                  "
                DC.B "PERCY                         "
                DC.B "P.O.V.                (M.S.D.)"
                DC.B "PSYCHONOMIX   (CORPSE GRINDER)"
                DC.B "REDLITE                  (DAN)"
                DC.B "REPLICANTS        (LITTLE GUY)"
                DC.B "RISK (DANNY O.,SEPP JO,MC FLY)"
                DC.B "SENTRY              (ISO,XLR8)"
                DC.B "STF                   (FLAYER)"
                DC.B "STRANGER              (FREDDY)"
                DC.B "                              "

                DC.B "SYNERGY           (WINGLEADER)"
                DC.B "SYNDICATE             (SLAYER)"
                DC.B "                              "
                DC.B "                              "
                DC.B "TDD                  (INTEGER)"
                DC.B "TESLA UNIT        (JOCKE,KIRI)"
                DC.B "T'PAU                         "
                DC.B "THE MANIAC                    "
                DC.B "TTK            (SPITT,MIK,TPM)"
                DC.B "THE NAPALM SOLDIERS     (HAWK)"
                DC.B "TRINITY                       "
                DC.B "TRSI                          "
                DC.B "THE SILENT NOISE       (DIGIT)"
                DC.B "TTG                (DOMINATOR)"
                DC.B "                              "
                DC.B "                              "
                DC.B "  AND OF COURSE BIG HELLO TO  "
                DC.B "     YOU READING THIS !!!     "
                DC.B "                              "
                DC.B "IF YOU WANT TO HAVE YOUR NAME "
                DC.B "BEING MENTIONED NEXT TIME JUST"
                DC.B "WRITE US A LETTER OR POSTCARD."
                DC.B "                              "



                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "  SO THIS IS ALL FOR THE      "
                DC.B "    STAX GREETINGS....        "
                DC.B "                              "
                DC.B "    IT FOLLOWS THE VERY       "
                DC.B "        NICE BUT CHAOTIC      "
                DC.B "             TEXT BY INTER... "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "OHH.. I FORGOT !!!   QUESTOR  "
                DC.B "OF INTER ASKED US TO REMOVE   "
                DC.B "HIS ENGLISH MISTAKES IN THE   "
                DC.B "SOON COMING TEXT.........     "
                DC.B "                              "
                DC.B " OF COURSE WE HAVE NOT SO HAVE"
                DC.B "    A SPECIAL LOOK AT IT...   "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "


                DC.B "                              "
                DC.B " HI GUYS, THIS IS INTER BACK  "
                DC.B " ON THE STAGE TO DESTROY THE  "
                DC.B " WHOLE FUCKING WORLD......... "
                DC.B "                              "
                DC.B " I AM SO TYRED OF DEBUGGING,  "
                DC.B " I DESTROY THE WHOLE WORLD AND"
                DC.B " I HAVEN'T TO DEBUGG ANY      "
                DC.B " PROGRAMM....  (YEAHHHH)      "
                DC.B " THIS SCREEN WAS DAMNED TO    "
                DC.B " CODE (ESPEZIALLY THE JOY-    "
                DC.B " ROUT, BECAUSE THE KEYBOARD-  "
                DC.B " PROCESSOR IS A BIG SHIT !!!!)"
                DC.B " AT THIS TIME THE PROGRAMM    "
                DC.B " DOESN'T WORK CORRECTLY....   "
                DC.B " AAAAAAARRRRRGGGGGHHHHHH..... "
                DC.B "                              "
                DC.B " OK OK OK YOU MAY HAVE        "
                DC.B " NOTICED THAT I BROGHT        "
                DC.B " QUESTOR TO THE LUNATIC       "
                DC.B " ASYLUM.                      "
                DC.B " NOW SOMETHING MORE SERIONS,  "
                DC.B " THE LONG AWAITED GREETINGS.  "

                DC.B " ANIMAL MINE                  "
                DC.B "  ESPEZZIALLY TO ZAXX: THANX  "
                DC.B "  FOR YOUR HELP. IT'S ALWAYS  "
                DC.B "  NICE TO MEET YOU.......     "
                DC.B " ARCAY OF TMF                 "
                DC.B "  HEY, GUY, WAHT'S GOING ON ? "
                DC.B "  THANX FOR YOUR SOFTWARE.... "
                DC.B "  P.S.: WELCOME IN INTER!!!!! "
                DC.B " BITMASTER                    "
                DC.B "  THANX FOR YOUR HELP WITH THE"
                DC.B "  DSP-STUFF AND THE FALCON-   "
                DC.B "  REGISTERS...                "
                DC.B " NEW TREND                    "
                DC.B "  LIG LURY AND MR. BOND:      "
                DC.B "  THE 680XX-CONVENTION WAS    "
                DC.B "  VERY FUNNY...               "
                DC.B " STALLION OF AURA             "
                DC.B "  HOPE YOU ORGANIZE IN EASTERN"
                DC.B "  1994 A PARTY, THE LAST WAS  "
                DC.B "  VERY FUNNY!!!               "
                DC.B " CHRIS OF AURA                "
                DC.B "  THANX FOR YOUR HELP WITH THE"
                DC.B "  DSP-STUFF.                  "

                DC.B " BDC OF AURA                  "
                DC.B "  THANX FOR YOUR 3D-HELP! IT  "
                DC.B "  WAS NICE TO MEET YOU ON THE "
                DC.B "  680XX-PARTY...              "
                DC.B "  AUF DER PARTY STAND ICH GANZ"
                DC.B "  SCHOEN AUF DER LEITUNG MIT  "
                DC.B "  DEM 3D-LOESCHEN....         "
                DC.B " INTEGER OF TDD               "
                DC.B "  HEY GUY, IT'S ALWAYS VERY   "
                DC.B "  FUNNY TO MEET YOU!! HOPE WE "
                DC.B "  WILL MEET IN THE NEAR FUTURE"
                DC.B " AGENT T OF CREAM             "
                DC.B "  I HOPE YOUR DENTRO WILL BE  "
                DC.B "  READY SOON.                 "
                DC.B " CARNERA OF NPG               "
                DC.B "  THANX FOR THE GRAFIX!! (HEY,"
                DC.B "  DAS LIED IST EINFACH GEIL!! "
                DC.B "  (ICH HOFFE, DU WEIST WAS ICH"
                DC.B "  MEINE))...                  "
                DC.B " THE INNOVATOR OF NEWLINE     "
                DC.B "  HI, THANX FOR YOUR HELP WITH"
                DC.B "  THE 3D-ROUTS. HOPE TO MEET  "
                DC.B "  YOU AGAIN...                "


                DC.B " JARON OF NPG                 "
                DC.B "  I HOPE YOUR GAME WILL BECOME"
                DC.B "  GREAT!                      "
                DC.B " (ICH HOFFE, DEIN SCHLAFSACK  "
                DC.B " IST NUN WIEDER ENTMAUST...)  "
                DC.B " MATT OF STAX                 "
                DC.B "  SSAATTAANN !!!!!!!!         "
                DC.B "  COOOOOOOOOOOOOOOOL !!!!!!   "
                DC.B " MIKE OF STAX                 "
                DC.B "  SORRRRRY FOR NOT SENDING    "
                DC.B "  THIS SCREEN AT THE RIGHT    "
                DC.B "  TIME...                     "
                DC.B " TYAN OF STAX                 "
                DC.B "  TTEEKKKKNNOO !!!!!!!!!      "
                DC.B " DUX OF STAX                  "
                DC.B "  THANX FOR SENDING THE STUFF."
                DC.B " TARZAN BOY OF STAX           "
                DC.B "  MANY THANX FOR THE MUSIXS!! "
                DC.B " LAZER-TEAM                   "
                DC.B "  THANX FOR SENDING YOUR      "
                DC.B "  FALCON-DENTRO. IT'S REALLY  "
                DC.B "  FANTASTIX.........          "
                DC.B "                              "

                DC.B " NOW TO THE GENERAL GREETINGS:"
                DC.B "                              "
                DC.B " ALL MEMBERS OF ANIMAL MINE   "
                DC.B "                              "
                DC.B " ALL MEMBERS OF NEW TREND     "
                DC.B "                              "
                DC.B " ALL MEMBER OF AURA           "
                DC.B "                              "
                DC.B " ALL MEMBERS OF LIGHT         "
                DC.B "                              "
                DC.B " ALL MEMBERS OF PSYCHONOMIX   "
                DC.B "  (HEY METALLIX, WRITE TO ME!)"
                DC.B "                              "
                DC.B " ALL MEMBERS OF RISK          "
                DC.B "                              "
                DC.B " CHAOS OF SANITY              "
                DC.B "                              "
                DC.B " ALL MEMBERS OF ECG           "
                DC.B "                              "
                DC.B " ALL MEMBERS OF WHITE STATUS  "
                DC.B "                              "
                DC.B "  ALL OTHERS I HAVE FORGOTTEN "
                DC.B "      (SORRRRRRRY...!)        "

                DC.B " AND NOW TO A SHORT EXEPTION  "
                DC.B " FOR A SPECIAL MESSAGE TO:    "
                DC.B "                              "
                DC.B "       INTEGER OF TDD         "
                DC.B "                              "
                DC.B " HEY, ICH HABE GERADE DEINEN  "
                DC.B " BRIEF BEKOMMEN UND HIER KOMMT"
                DC.B " NOCH EIN BISCHEN TEXT...     "
                DC.B " EXTRA NUR FUER DICH!!!!!!!!! "
                DC.B "                              "
                DC.B " SOBALD EINE PARTY IST, SAGE  "
                DC.B " ICH DIR BESCHEID. DANN KANN  "
                DC.B " ICH MAL WIEDER DEINE FAHR-   "
                DC.B " KUENSTE BEGUTACHTEN...       "
                DC.B "(O-TON AUF DER 68XXX-PARTY DER"
                DC.B "ORGANISATOREN: DER MC DONALD  "
                DC.B "IST NUR EIN PAAR METER WEITER!"
                DC.B " FUER ALLE DIE NICHT DA WAREN:"
                DC.B " ES WAREN DANN ZUM SCHLUSS CA "
                DC.B " 55 MINUTEN ZUM LAUFEN!!!!!!) "
                DC.B " SO NIELS, JETZT WUENSCHE ICH "
                DC.B " DIR NOCH ALLES GUTE.(UND SAUF"
                DC.B " NET ZUVIEL!)     TSCHAU      "


                DC.B " OK GUYS, QUESTOR BACK FROM   "
                DC.B " THE LUNATIC ASYLUM. IN THIS  "
                DC.B " SCREEN IS A HIDDEN FEATURE   "
                DC.B " AND AT THE END OF THE TEXT IS"
                DC.B " THE KEY TO ACTIVATE IT. BUT  "
                DC.B " DON'T EXPECT TOO MUCH,       "
                DC.B " BECAUSE I RAN OUT OF TIME    "
                DC.B " (ICH WEIS, DASS DAS EINE     "
                DC.B " GLOEDE AUSREDE IST, ABER ES  "
                DC.B " STIMMT (LEIDER) !!!!!!!!!!!) "
                DC.B "                              "
                DC.B " TRY IN THE HIDDEN FEATURE THE"
                DC.B " FOLLOWING KEYS:              "
                DC.B " CURSOR UP, DOWN, RIGHT AND   "
                DC.B " LEFT AND FINALY THE RETURN-  "
                DC.B " KEY.                         "
                DC.B " I HOPE YOU LIKE THIS LITTLE  "
                DC.B " FEATURE. IT WAS CODED IN 4   "
                DC.B " DAYS WITHOUT THE JOY-ROUT.   "
                DC.B " BUT BECAUSE THE JOY-ROUT DID "
                DC.B " NOT WORK, I INLCUDED ONLY A  "
                DC.B " KEYBOARD-STEERING (SORRY!)   "
                DC.B "                              "

                DC.B " NOW TO THE GUNSLINGER-TEXT:  "
                DC.B " OK, QUESTOR TOLD ME TO WRITE "
                DC.B " A BACKGROUND STORY FOR HIS   "
                DC.B " LITTLE SHOOT'EM UP GAME IN   "
                DC.B " THE LOWER BORDER. EH...LET'S "
                DC.B " THINK A BIT...AH,YES:ONCE    "
                DC.B " UPON  A  TIME THERE  WAS  A  "
                DC.B " CUTE LITTLE SLIMY GREEN ALIEN"
                DC.B " GIRL NAMED QWERTZUIOP. ON A  "
                DC.B " WARM SUMMER EVENING SHE SAT  "
                DC.B " WITH HER BOYFRIEND,THE BIG   "
                DC.B " SLIMY YELLOW ASDFGHJKL IN A  "
                DC.B " BAR NEAR SQUORNSHELLY ZETA.  "
                DC.B " THEY WERE PEACEFULLY SIPPING "
                DC.B " THEIR FAVOURITE DRINK,HYDRO- "
                DC.B " CHLORIC ACID ON-THE-ROCKS,   "
                DC.B " WHEN SUDDENLY THERE WAS A    "
                DC.B " HUGE BLUE FLASH,AND A STRANGE"
                DC.B " PINK CREATURE WITH BLACK FUR "
                DC.B " AND TWO PINK POINTED EARS ON "
                DC.B " ITS HEAD APPEARED IN THE BAR."
                DC.B " ALL THE GUESTS WERE TOTALLY  "
                DC.B "                              "

                DC.B " SHOCKED, BUT THE PINK MONSTER"
                DC.B " JUST PULLED OUT A BIG BAG,   "
                DC.B " WALKED TOWARDS THE FRIGHTENED"
                DC.B " ASDFGHJKL, GRABBED HIM AND   "
                DC.B " THREW HIN INTO HIS BAG. THEN "
                DC.B " HE SPOKE STRANGE UGLY WORDS  "
                DC.B " INTO A LITTLE BLACK BOX. THE "
                DC.B " WORDS SOUNDED LILKE ' I'VE   "
                DC.B " GOT ONE OF THEM,CAPTAIN. THEY"
                DC.B " ARE REALLY FASCINATING. NOW  "
                DC.B " PLEASE TELL SCOTTY TO BEAM ME"
                DC.B " UP.' THEN THERE WAS ANOTHER  "
                DC.B " BLUE FLASH AND THE MONSTER   "
                DC.B " VANISHED AGAIN-TOGETHER WITH "
                DC.B " THE POOR ASDFGHJKL ! AT FIRST"
                DC.B " QWERTZUIOP   WAS    TOTALLY  "
                DC.B " SHOCKED, AND  SHE    BEGAN   "
                DC.B " TO WEEP BIG GREEN PLASMA     "
                DC.B " TEARS. BUT THEN SHE STOOD UP "
                DC.B " AND SHOUTED 'REVENGE ! I WILL"
                DC.B " COME AND RESCUE YOU,MY DEAR  "
                DC.B " ASDFGHJKL !' WITH THESE WORDS"
                DC.B "                              "

                DC.B " SHE LEFT AND WALKED TO HER   "
                DC.B " UNCLE YXCVBNM,WHO WAS A GREAT"
                DC.B " WISE MAN. SHE ASKED HIM HOW  "
                DC.B " SHE COULD FOLLOW THE PINK    "
                DC.B " MONSTER. HER UNCLE SAID TO   "
                DC.B " HER:'YOU NEED A SPACESHIP,MY "
                DC.B " DEAR. PERHAPS WE CAN REPAIR  "
                DC.B " THE OLD   SPACESHIP     THAT "
                DC.B " CRUSHED ON OUR PLANET 4563467"
                DC.B " YEARS, 8 MONTHS AND 23 DAYS  "
                DC.B " AGO. I THINK IT WAS AT 11AM, "
                DC.B " BUT I CAN'T REMEMBER EXACTLY."
                DC.B " GOOD LUCK, AND  MAY  MTV BE  "
                DC.B " WITH YOU....' AND QWERTZUIOP "
                DC.B " SET FORTH ON A LONG JOURNEY  "
                DC.B " AND WALKED MANY FEETS(7894767"
                DC.B " 74365667,TO BE EXACTLY)UNTIL "
                DC.B " SHE FOUND THE WRECK OF THE   "
                DC.B " ANCIENT SPACESHIP VOYAGER    "
                DC.B " THAT THE GODS HAD SENT TO    "
                DC.B " THEM MANY YEARS AGO. SHE     "
                DC.B " CHANGED THE FUSE (SICHERUNG) "
                DC.B "                              "

                DC.B " NO.B23,FILLED IN 654 LITERS  "
                DC.B " DIESEL, STARTED THE ENGINE   "
                DC.B " AND WROARRRRRRRRRRRRRRRRRRR  "
                DC.B " RRRRRRRRRRRRRRRRRRRRRRRRRRR  "
                DC.B " RRRRRR.........SHE FLEW AWAY "
                DC.B " TO DEFEAT HER ENEMYS........ "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B " CREDITS:                     "
                DC.B " CODE :  QUESTOR OF INTER     "
                DC.B " GRAFIX:                      "
                DC.B "   LOGOS:   CARNERA OF NPG    "
                DC.B "   CHARSET: SAMURAI OF INTER  "
                DC.B "   GAMEGFX: SAMURAI OF INTER  "
                DC.B "            QUESTOR OF INTER  "
                DC.B "            GUNSLINGER        "
                DC.B " MUSIX:  TARZAN BOY OF STAX   "
                DC.B " STORY:  GUNSLINGER           "
                DC.B "                              "

                DC.B " AND NOW TO THE LONG-AWAITED  "
                DC.B " KEY:       IT IS THE ......  "
                DC.B " NOOOO, THIS IS TOO EASY..... "
                DC.B " TAKE THE FIGURE HEX 1F AND   "
                DC.B " ADD DEC 21. TAKE THE RESULT  "
                DC.B " AND SUB OCT 25. NOW MULTIPLIZ"
                DC.B " THE FIGURE WITH DEC 12. FROM "
                DC.B " THE RESULT OF THIS TERM SUB  "
                DC.B " HEX 320 AND ADD 22.          "
                DC.B "                              "
                DC.B " ALL RIGHT ?                  "
                DC.B "                              "
                DC.B " NOW YOU HAVE ONLY TO SUB DEC "
                DC.B " 72 OF THIS FIGURE.           "
                DC.B "                              "
                DC.B " NOW COUNT THE FIGURE FROM THE"
                DC.B " TOP OF YOUR COMPUTER-KEYBOARD"
                DC.B " AND PRESS THE FIGURED KEY.   "
                DC.B " GOT IT ?!?!?                 "
                DC.B " YES ?                        "
                DC.B " HAVE FUN!!!!!!               "
                DC.B "        BYE, QUESTOR OF INTER "
                DC.B " P.S.:IT HAS A END-ENEMY, TOO!"

                DC.B " ",-1     ; ENDE (NICHT VERéNDERN!!)

; hier genau 1 Bildschirmseite, wobei das letze Zeichen einer Seite
; nicht beachtet wird; ich wÅrde die Seite kopieren, und mit öberschreiben
; reinschreiben...
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "
                DC.B "                              "


                EVEN
curx:           DC.W 5
cury:           DC.W 1
; IN: a6 - Strukturadresse a0 - Stringadresse   d0,d1 - AnfangsXY d2,d3 - ZielXY
                ENDPART
                >PART 'NewChar'
newchar:        movem.w D0-D1,addiert(A6)
                moveq   #0,D4
                cmp.w   D0,D2
                bgt.s   no_set1
                bset    #1,D4
                exg     D0,D2
no_set1:        cmp.w   D1,D3
                bgt.s   no_set2
                bset    #0,D4
                exg     D1,D3
no_set2:        add.w   D4,D4
                move.w  D4,type(A6)
                sub.w   D0,D2
                sub.w   D1,D3
                move.w  D2,D4
                move.w  D3,D5
                lsr.w   #5,D4
                lsr.w   #5,D5
                and.w   #$001F,D2
                and.w   #$001F,D3
                movem.w D4-D5,deltaxy(A6)
                movem.w D2-D3,restexy(A6)
                moveq   #0,D0
                move.l  D0,addiert_rest(A6)
                move.w  #31,phase(A6)
                move.b  (A0)+,D0
                subi.w  #32,D0
                lsl.w   #4,D0
                move.w  D0,char(A6)
                rts
                ENDPART
clear_text:     >PART '3&4 Plane lîschen'
                movem.l A0-A1,-(SP)
                movea.l screen1,A0
                movea.l screen2,A1
                adda.l  #30*160+4+4-24,A0
                adda.l  #30*160+4+4-24,A1
                move.l  A0,clear_adr1
                move.l  A1,clear_adr2
                move.w  #-1,clear_text_flag
                move.w  #0,clear_command
                move.w  #0,clear_parameter
                move.w  #33,fly_verz
                movem.l (SP)+,A0-A1
                rts
clear_adr1:     DS.L 1
clear_adr2:     DS.L 1
clear_command:  DS.W 1
clear_text_flag:DC.W 0
clear_parameter:DC.W 0
ende_clear:     clr.w   clear_text_flag
                rts
clear_rout_tab: DC.L clear1
clear1:         addq.w  #1,clear_parameter
                cmpi.w  #209-10,clear_parameter
                beq.s   ende_clear

                movea.l clear_adr1,A0
                movea.l clear_adr2,A1
                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4
                moveq   #0,D5
                moveq   #0,D6
                moveq   #0,D7
                lea     160(A0),A0
                lea     160(A1),A1
                move.l  A0,clear_adr1
                move.l  A1,clear_adr2
                movem.l D0-D3,-(A0)
                movem.l D0-D3,-(A1)
                REPT 4
                movem.l D1-D7,-(A0)
                movem.l D1-D7,-(A1)
                ENDR
                move.l  #%00000000000000110000000000000011,D1
                move.l  D1,-(A0)
                move.l  D1,-(A0)
                move.l  D1,-(A1)
                move.l  D1,-(A1)
                rts
                ENDPART
                >PART 'Flying-Chars'
type1:          movem.w addiert(A6),D0-D1
                movem.w deltaxy(A6),D2-D3
                add.w   D2,D0
                add.w   D3,D1
                movem.w restexy(A6),D2-D3
                movem.w addiert_rest(A6),D4-D5
                add.w   D2,D4
                add.w   D3,D5
                movem.w D4-D5,addiert_rest(A6)
                movem.w D0-D1,addiert(A6)
                lsr.w   #5,D4
                lsr.w   #5,D5
                add.w   D4,D0
                add.w   D5,D1

                lsl.w   #5,D1
                move.w  D1,D6
                add.w   D1,D1
                add.w   D1,D1
                add.w   D6,D1

                lea     0(A4,D1.w),A3
                move.w  D0,D6
                and.w   #-$0010,D6
                lsr.w   #1,D6
                lea     0(A3,D6.w),A3
                move.l  A3,(A5)+
                and.w   #$000F,D0
                add.w   D0,D0
                lea     print_routs(PC),A1
                adda.w  0(A1,D0.w),A1
                move.w  char(A6),D1
                jsr     (A1)
                rts
type2:          movem.w addiert(A6),D0-D1
                movem.w deltaxy(A6),D2-D3
                add.w   D2,D0
                sub.w   D3,D1
                movem.w restexy(A6),D2-D3
                movem.w addiert_rest(A6),D4-D5
                add.w   D2,D4
                add.w   D3,D5
                movem.w D4-D5,addiert_rest(A6)
                movem.w D0-D1,addiert(A6)
                lsr.w   #5,D4
                lsr.w   #5,D5
                add.w   D4,D0
                sub.w   D5,D1

                lsl.w   #5,D1
                move.w  D1,D6
                add.w   D1,D1
                add.w   D1,D1
                add.w   D6,D1

                lea     0(A4,D1.w),A3
                move.w  D0,D6
                and.w   #-$0010,D6
                lsr.w   #1,D6
                lea     0(A3,D6.w),A3
                move.l  A3,(A5)+
                and.w   #$000F,D0
                add.w   D0,D0
                lea     print_routs(PC),A1
                adda.w  0(A1,D0.w),A1
                move.w  char(A6),D1
                jsr     (A1)
                rts
type3:          movem.w addiert(A6),D0-D1
                movem.w deltaxy(A6),D2-D3
                sub.w   D2,D0
                add.w   D3,D1
                movem.w restexy(A6),D2-D3
                movem.w addiert_rest(A6),D4-D5
                add.w   D2,D4
                add.w   D3,D5
                movem.w D4-D5,addiert_rest(A6)
                movem.w D0-D1,addiert(A6)
                lsr.w   #5,D4
                lsr.w   #5,D5
                sub.w   D4,D0
                add.w   D5,D1

                lsl.w   #5,D1
                move.w  D1,D6
                add.w   D1,D1
                add.w   D1,D1
                add.w   D6,D1

                lea     0(A4,D1.w),A3
                move.w  D0,D6
                and.w   #-$0010,D6
                lsr.w   #1,D6
                lea     0(A3,D6.w),A3
                move.l  A3,(A5)+
                and.w   #$000F,D0
                add.w   D0,D0
                lea     print_routs(PC),A1
                adda.w  0(A1,D0.w),A1
                move.w  char(A6),D1
                jsr     (A1)
                rts
type4:          movem.w addiert(A6),D0-D1
                movem.w deltaxy(A6),D2-D3
                sub.w   D2,D0
                sub.w   D3,D1
                movem.w restexy(A6),D2-D3
                movem.w addiert_rest(A6),D4-D5
                add.w   D2,D4
                add.w   D3,D5
                movem.w D4-D5,addiert_rest(A6)
                movem.w D0-D1,addiert(A6)
                lsr.w   #5,D4
                lsr.w   #5,D5
                sub.w   D4,D0
                sub.w   D5,D1

                lsl.w   #5,D1
                move.w  D1,D6
                add.w   D1,D1
                add.w   D1,D1
                add.w   D6,D1

                lea     0(A4,D1.w),A3
                move.w  D0,D6
                and.w   #-$0010,D6
                lsr.w   #1,D6
                lea     0(A3,D6.w),A3
                move.l  A3,(A5)+
                and.w   #$000F,D0
                add.w   D0,D0
                lea     print_routs(PC),A1
                adda.w  0(A1,D0.w),A1
                move.w  char(A6),D1
                jsr     (A1)
                rts
; ******************************************************************
type1_2:        movem.w addiert(A6),D0-D1
                movem.w deltaxy(A6),D2-D3
                add.w   D2,D0
                add.w   D3,D1
                movem.w restexy(A6),D2-D3
                movem.w addiert_rest(A6),D4-D5
                add.w   D2,D4
                add.w   D3,D5
                lsr.w   #5,D4
                lsr.w   #5,D5
                add.w   D4,D0
                add.w   D5,D1

                lsl.w   #5,D1
                move.w  D1,D6
                add.w   D1,D1
                add.w   D1,D1
                add.w   D6,D1

                lea     0(A4,D1.w),A3
                move.w  D0,D6
                and.w   #-$0010,D6
                lsr.w   #1,D6
                lea     0(A3,D6.w),A3
                and.w   #$000F,D0
                add.w   D0,D0
                lea     print_routs(PC),A1
                adda.w  0(A1,D0.w),A1
                move.w  char(A6),D1
                jsr     (A1)
                rts
type2_2:        movem.w addiert(A6),D0-D1
                movem.w deltaxy(A6),D2-D3
                add.w   D2,D0
                sub.w   D3,D1
                movem.w restexy(A6),D2-D3
                movem.w addiert_rest(A6),D4-D5
                add.w   D2,D4
                add.w   D3,D5
                lsr.w   #5,D4
                lsr.w   #5,D5
                add.w   D4,D0
                sub.w   D5,D1

                lsl.w   #5,D1
                move.w  D1,D6
                add.w   D1,D1
                add.w   D1,D1
                add.w   D6,D1

                lea     0(A4,D1.w),A3
                move.w  D0,D6
                and.w   #-$0010,D6
                lsr.w   #1,D6
                lea     0(A3,D6.w),A3
                and.w   #$000F,D0
                add.w   D0,D0
                lea     print_routs(PC),A1
                adda.w  0(A1,D0.w),A1
                move.w  char(A6),D1
                jsr     (A1)
                rts
type3_2:        movem.w addiert(A6),D0-D1
                movem.w deltaxy(A6),D2-D3
                sub.w   D2,D0
                add.w   D3,D1
                movem.w restexy(A6),D2-D3
                movem.w addiert_rest(A6),D4-D5
                add.w   D2,D4
                add.w   D3,D5
                lsr.w   #5,D4
                lsr.w   #5,D5
                sub.w   D4,D0
                add.w   D5,D1

                lsl.w   #5,D1
                move.w  D1,D6
                add.w   D1,D1
                add.w   D1,D1
                add.w   D6,D1

                lea     0(A4,D1.w),A3
                move.w  D0,D6
                and.w   #-$0010,D6
                lsr.w   #1,D6
                lea     0(A3,D6.w),A3
                and.w   #$000F,D0
                add.w   D0,D0
                lea     print_routs(PC),A1
                adda.w  0(A1,D0.w),A1
                move.w  char(A6),D1
                jsr     (A1)
                rts
type4_2:        movem.w addiert(A6),D0-D1
                movem.w deltaxy(A6),D2-D3
                sub.w   D2,D0
                sub.w   D3,D1
                movem.w restexy(A6),D2-D3
                movem.w addiert_rest(A6),D4-D5
                add.w   D2,D4
                add.w   D3,D5
                lsr.w   #5,D4
                lsr.w   #5,D5
                sub.w   D4,D0
                sub.w   D5,D1

                lsl.w   #5,D1
                move.w  D1,D6
                add.w   D1,D1
                add.w   D1,D1
                add.w   D6,D1

                lea     0(A4,D1.w),A3
                move.w  D0,D6
                and.w   #-$0010,D6
                lsr.w   #1,D6
                lea     0(A3,D6.w),A3
                and.w   #$000F,D0
                add.w   D0,D0
                lea     print_routs(PC),A1
                adda.w  0(A1,D0.w),A1
                move.w  char(A6),D1
                jsr     (A1)
                rts

                ENDPART
                >PART 'Print-Routine'
; Der Print-Routine Åbergibt man in a0 einen Zeiger auf den Text
;                                in a3 die Screenposition
; Es werden D0-D6/A2/A4 verÑndert
print_routs:    DC.W print8-print_routs
                DC.W print7-print_routs
                DC.W print6-print_routs
                DC.W print5-print_routs
                DC.W print4-print_routs
                DC.W print3-print_routs
                DC.W print2-print_routs
                DC.W print1-print_routs
                DC.W print0-print_routs
                DC.W print15-print_routs
                DC.W print14-print_routs
                DC.W print13-print_routs
                DC.W print12-print_routs
                DC.W print11-print_routs
                DC.W print10-print_routs
                DC.W print9-print_routs

print0:         lea     charset0,A2
                bra.s   print1_7
print1:         lea     charset1,A2
                bra.s   print1_7
print2:         lea     charset2,A2
                bra.s   print1_7
print3:         lea     charset3,A2
                bra.s   print1_7
print4:         lea     charset4,A2
                bra.s   print1_7
print5:         lea     charset5,A2
                bra.s   print1_7
print6:         lea     charset6,A2
                bra.s   print1_7
print7:         lea     charset7,A2
                bra.s   print1_7
print8:         lea     charset8,A2
print1_7:       lea     0(A2,D1.w),A4   ; im Zeichensatz Adresse holen
                movem.w (A4),D0-D6
                or.w    D0,(A3)
                or.w    D1,160(A3)
                or.w    D2,320(A3)
                or.w    D3,480(A3)
                or.w    D4,640(A3)
                or.w    D5,800(A3)
                or.w    D6,960(A3)
                rts
print9:         lea     charset9,A2
                bra.s   print9_15
print10:        lea     charset10,A2
                bra.s   print9_15
print11:        lea     charset11,A2
                bra.s   print9_15
print12:        lea     charset12,A2
                bra.s   print9_15
print13:        lea     charset13,A2
                bra.s   print9_15
print14:        lea     charset14,A2
                bra.s   print9_15
print15:        lea     charset15,A2
print9_15:      add.w   D1,D1
                lea     0(A2,D1.w),A4
                movem.w (A4)+,D0-D6
                or.w    D0,(A3)
                or.w    D1,8(A3)
                or.w    D2,160(A3)
                or.w    D3,168(A3)
                or.w    D4,320(A3)
                or.w    D5,328(A3)
                or.w    D6,480(A3)
                movem.w (A4),D0-D6
                or.w    D0,488(A3)
                or.w    D1,640(A3)
                or.w    D2,648(A3)
                or.w    D3,800(A3)
                or.w    D4,808(A3)
                or.w    D5,960(A3)
                or.w    D6,968(A3)
                rts
                ENDPART
game:           >PART 'auf VBL warten'
                IF speed=1
                clr.w   $FFFF8240.w
                ENDC
                move.w  _vblz,D0
wait_main:      cmp.w   _vblz,D0
                beq.s   wait_main
                clr.w   $FFFF8240.w
                IF speed=1
                move.w  #$0040,$FFFF8240.w
                ENDC
                ENDPART
                >PART 'Screen lîschen'
                IF clear=1
                movea.l screen,A0
                lea     50*160(A0),A0
                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4
                moveq   #0,D5
                moveq   #0,D6
                moveq   #0,D7
                movea.l D0,A1
                movea.l D0,A2
                movea.l D0,A3
                movea.l D0,A4
                movea.l D0,A5
                movea.l D0,A6
                REPT 142
                movem.l D0-D7/A1-A6,-(A0) ; 56 Bytes lîschen
                ENDR
                movem.l D0-D7/A1-A4,-(A0)
                ENDC
                IF speed=1
                move.w  #$0004,$FFFF8240.w
                ENDC
                ENDPART
                clr.w   kol_player_flag
                tst.l   vbl_rout
                beq.s   no_vbl_rout

                lea     e_enemy,A0
                moveq   #max_e_enemy-1,D0
search_e_e:     tst.w   (A0)
                bpl.s   found
                lea     ins_e_enemy(A0),A0
                dbra    D0,search_e_e

                move.l  #0,vbl_rout
                move.l  #0,end_enemy_rout
                move.w  #0,signal_flag
                bra.s   no_vbl_rout

found:          movea.l vbl_rout,A0
                jsr     (A0)
no_vbl_rout:
; ************************ Joystickroutine
                >PART
                btst    #0,joydata
                beq.s   no_oben
                tst.w   player_y
                beq.s   no_oben
                subi.w  #160,player_y
no_oben:        btst    #1,joydata
                beq.s   no_unten
                cmpi.w  #(50-6)*160,player_y
                beq.s   no_unten
                addi.w  #160,player_y
no_unten:       btst    #2,joydata
                beq.s   no_links
                tst.w   player_x
                beq.s   no_links
                subq.w  #1,player_x
no_links:       btst    #3,joydata
                beq.s   no_rechts
                cmpi.w  #320-14,player_x
                beq.s   no_rechts
                addq.w  #1,player_x
no_rechts:      btst    #7,joydata
                beq.s   no_fire2
                tst.w   schuû_flag
                bne.s   no_fire

                moveq   #max_schuû_player-1,D0
                lea     schuû_player,A0
s_f_sch_pl:     tst.w   (A0)
                bmi.s   yeah
                addq.w  #ins_schuû_player,A0
                dbra    D0,s_f_sch_pl
                bra.s   no_fire2

yeah:           move.w  player_y,D0
                add.w   #3*160,D0
                move.w  D0,(A0)+        ; Y-Koo
                move.w  player_x,D0
                add.w   #13,D0
                move.w  D0,(A0)+        ; X-Koo
                move.w  #-1,schuû_flag
                bra.s   no_fire
no_fire2:       clr.w   schuû_flag
no_fire:
                ENDPART
; ************************ Player zeichnen
                >PART
                move.w  player_x,D0
                move.w  player_y,D1
                bsr     set_player
                ENDPART
                tst.l   end_enemy_rout
                beq.s   no_end_enemy
                movea.l end_enemy_rout,A0
                jmp     (A0)
no_end_enemy:
; ************************ Player-SchÅûe bearbeiten
                >PART
                lea     schuû_player,A0
                moveq   #max_schuû_player-1,D7
sch_pl_loop:    move.w  (A0),D0         ; Y-Koo !!!!!!!!!
                bmi.s   next_schuû_pl
                addq.w  #schuû_player_vx,2(A0)
                move.w  2(A0),D1        ; X-Koo !!!!!!!!!

                cmp.w   #317,D1
                bge.s   clear_schuû_pl

                lea     enemy,A1
                moveq   #max_enemy-1,D2
search_en_plsch:move.w  (A1),D3         ; X-Koo vom Gegner
                bmi.s   no_kol1
                move.w  2(A1),D4

                cmp.w   D1,D3
                bgt.s   no_kol1
                cmp.w   D0,D4
                bgt.s   no_kol1
                addq.w  #8,D3
                add.w   #8*160,D4
                cmp.w   D1,D3
                blt.s   no_kol1
                cmp.w   D0,D4
                blt.s   no_kol1

                subq.w  #1,enemy_energie(A1)
                bne.s   clear_schuû_pl
                move.l  #-1,(A1)        ; Gegner lîschen
                bra.s   clear_schuû_pl  ; und aus Schleife...
no_kol1:        adda.w  #ins_enemy,A1
                dbra    D2,search_en_plsch
                bra.s   ende_search_plsch

clear_schuû_pl: move.w  #-1,(A0)        ; Player-Schuû lîschen
                bra.s   next_schuû_pl
ende_search_plsch:
                bsr     set_plsh

next_schuû_pl:  adda.w  #ins_schuû_player,A0
                dbra    D7,sch_pl_loop
                ENDPART
; ************************ Formations-Routine
                >PART
                tst.w   signal_flag
                bne     ende_form

                tst.l   form_pause
                beq.s   form_ok
                subq.l  #1,form_pause
                bra     ende_form

form_ok:        movea.l form_pointer,A0
                move.w  (A0)+,D0
                cmp.w   #1,D0
                bne.s   nix_ende_form
                lea     formationen,A0
                move.w  (A0)+,D0
nix_ende_form:  cmp.w   #2,D0
                bne.s   no_pause
                moveq   #0,D0
                move.w  (A0)+,D0
                move.l  D0,form_pause
                move.l  A0,form_pointer
                bra.s   ende_form
no_pause:       cmp.w   #3,D0
                bne.s   no_enemy

                lea     enemy,A1
                moveq   #max_enemy-1,D0
search_enemy:   tst.w   (A1)
                bmi.s   enemy_free
                lea     ins_enemy(A1),A1
                dbra    D0,search_enemy
                move.l  A0,form_pointer
                bra.s   ende_form

enemy_free:     movea.l (A0)+,A2        ; Pointer
                move.w  (A2)+,(A1)+
                move.w  (A2)+,(A1)+
                move.w  (A0)+,(A1)+
                move.l  A2,(A1)+
                move.l  (A0)+,(A1)+
                move.w  (A0)+,(A1)
                move.l  A0,form_pointer
                bra.s   ende_form
no_enemy:       cmp.w   #4,D0
                bne.s   no_rout
                movea.l (A0)+,A1
                move.l  A0,form_pointer
                jsr     end_enemy
                bra     ende_form
no_rout:

ende_form:
                ENDPART
; ************************ Gegner bearbeiten
                >PART
                lea     enemy,A0
                moveq   #max_enemy-1,D7
                move.w  player_x,D2
                move.w  player_y,D3
                move.w  D2,D4           ; Playerkoo fÅr Kollisionsabfrage
                move.w  D3,D5
                add.w   #11,D4          ; GROûZöGIG !!!!!!!!!!!!!!!!
                add.w   #6*160,D5
                movea.w D3,A4
                lea     4*160(A4),A4    ; zum Schuû-setzen

set_en_loop:    tst.w   (A0)            ; X1
                bmi     next_enemy
                movea.l enemy_pointer(A0),A1
                move.w  (A1)+,D0        ; neues X
                move.w  (A1)+,D1        ; neues Y
                tst.w   (A1)
                bpl.s   nix_ende_bahn
                move.w  #-1,(A0)
                bra     next_enemy
nix_ende_bahn:  move.l  A1,enemy_pointer(A0)

                cmp.w   D4,D0
                bgt.s   nix_kol_enemy
                cmp.w   D5,D1
                bgt.s   nix_kol_enemy
                move.w  D0,D6
                addq.w  #8,D6
                cmp.w   D2,D6
                blt.s   nix_kol_enemy
                move.w  D1,D6
                add.w   #8*160,D6
                cmp.w   D3,D6
                blt.s   nix_kol_enemy
                move.w  #-1,kol_player_flag
                subq.w  #1,enemy_energie(A0)
                bne     next_enemy
                move.w  #-1,(A0)
                bra     next_enemy
nix_kol_enemy:  move.w  D0,(A0)         ; und Koo speichern
                move.w  D1,2(A0)

                tst.w   enemy_schuû_c(A0)
                beq     no_schuû_enemy

                bchg    #0,enemy_schuû_f(A0)
                beq.s   no_schuû_enemy
                bchg    #1,enemy_schuû_f(A0)
                beq.s   no_schuû_enemy
                bchg    #2,enemy_schuû_f(A0)
                beq.s   no_schuû_enemy

                movea.w D1,A5
                cmp.w   A5,D3           ; Player in Schuû-Bereich ?
                blt.s   no_schuû_enemy
                lea     8*160(A5),A5
                cmp.w   A5,D3
                bgt.s   no_schuû_enemy

                subq.w  #1,enemy_schuû_c(A0)

                lea     schuû_enemy,A1
                moveq   #max_schuû_enemy-1,D6
search_en_sch:  tst.w   (A1)
                bmi.s   found_en_sch
                lea     ins_schuû_enemy(A1),A1
                dbra    D6,search_en_sch
                bra.s   no_schuû_enemy
found_en_sch:
                lea     -4*160(A5),A5
                move.w  A5,(A1)+
                move.w  D0,(A1)+
                move.w  D0,D6
                and.w   #$000F,D6
                add.w   D6,D6
                move.w  pix_tab(PC,D6.w),(A1)+

                cmpi.l  #set_boot,enemy_rout(A0)
                sne     (A1)
                move.w  #2,2(A1)        ; Geschwindigkeit vom Schuû !!!!!!!!!
                bra.s   no_schuû_enemy

pix_tab:        DC.W %1000000000000000
                DC.W %0100000000000000
                DC.W %0010000000000000
                DC.W %0001000000000000
                DC.W %0000100000000000
                DC.W %0000010000000000
                DC.W %0000001000000000
                DC.W %0000000100000000
                DC.W %0000000010000000
                DC.W %0000000001000000
                DC.W %0000000000100000
                DC.W %0000000000010000
                DC.W %0000000000001000
                DC.W %0000000000000100
                DC.W %0000000000000010
                DC.W %0000000000000001

no_schuû_enemy: movea.l enemy_rout(A0),A3
                jsr     (A3)
next_enemy:     lea     ins_enemy(A0),A0
                dbra    D7,set_en_loop
                ENDPART
ende_end_enemy:
; ************************ Gegner-SchÅûe bearbeiten
                >PART
                lea     schuû_enemy,A0
                moveq   #max_schuû_enemy-1,D7
                move.w  player_x,D2
                move.w  player_y,D3
                move.w  D2,D4           ; Playerkoo fÅr Kollisionsabfrage
                move.w  D3,D5
                add.w   #11,D4          ; GROûZöGIG !!!!!!!!!!!!!!!!
                add.w   #6*160,D5
sch_enemy_loop: move.w  (A0),D0         ; Y-Koo !!!!!!!!!!!!!!
                bmi.s   next_enemy_schuû
                move.w  schuû_enemy_vx(A0),D1
                sub.w   D1,2(A0)
                move.w  2(A0),D1        ; X-Koo !!!!!!!!!!!!!!
                bmi.s   clear_enemy_sch

                cmp.w   D4,D1
                bgt.s   nix_sch_enemy
                cmp.w   D5,D0
                bgt.s   nix_sch_enemy
                cmp.w   D2,D1
                blt.s   nix_sch_enemy
                cmp.w   D3,D0
                blt.s   nix_sch_enemy
                move.w  #-1,kol_player_flag ; Kollision mit Player...
clear_enemy_sch:move.w  #-1,(A0)
                bra.s   next_enemy_schuû
nix_sch_enemy:
                movea.l screen,A1
                adda.w  D0,A1           ; Screen-Adr. + Y-Pos
                and.w   #-$0010,D1
                lsr.w   #1,D1
                adda.w  D1,A1
                move.w  4(A0),D0
                move.w  schuû_enemy_vx(A0),D6
                rol.w   D6,D0
                move.w  D0,4(A0)
                not.w   D0
                and.w   D0,(A1)
                and.w   D0,2(A1)
                and.w   D0,4(A1)
                and.w   D0,6(A1)
                not.w   D0
                tst.b   schuû_enemy_f(A0)
                beq.s   no_set_4
                or.w    D0,6(A1)
no_set_4:       or.w    D0,2(A1)

next_enemy_schuû:lea    ins_schuû_enemy(A0),A0
                dbra    D7,sch_enemy_loop
                ENDPART
; ************************ Energie bearbeiten
                >PART
                tst.w   kol_player_flag
                beq     nix_balken
                move.l  energie,D0
                IF cheat=0
                add.l   D0,D0
                ELSE
                not.w   $FFFF8240.w
                ENDC
                beq     game_over
                move.l  D0,energie
                movea.l screen1,A0
                adda.l  #285*160,A0
                swap    D0
                move.w  D0,(A0)
                move.w  D0,160(A0)
                move.w  D0,320(A0)
                move.w  D0,480(A0)
                move.w  D0,640(A0)
                move.w  D0,800(A0)
                move.w  D0,960(A0)
                move.w  D0,1120(A0)
                swap    D0
                move.w  D0,8(A0)
                move.w  D0,168(A0)
                move.w  D0,328(A0)
                move.w  D0,488(A0)
                move.w  D0,648(A0)
                move.w  D0,808(A0)
                move.w  D0,968(A0)
                move.w  D0,1128(A0)

                movea.l screen2,A0
                adda.l  #285*160,A0
                swap    D0
                move.w  D0,(A0)
                move.w  D0,160(A0)
                move.w  D0,320(A0)
                move.w  D0,480(A0)
                move.w  D0,640(A0)
                move.w  D0,800(A0)
                move.w  D0,960(A0)
                move.w  D0,1120(A0)
                swap    D0
                move.w  D0,8(A0)
                move.w  D0,168(A0)
                move.w  D0,328(A0)
                move.w  D0,488(A0)
                move.w  D0,648(A0)
                move.w  D0,808(A0)
                move.w  D0,968(A0)
                move.w  D0,1128(A0)

nix_balken:
                ENDPART
; ************************ ENDE-MAIN
                rts
game_over:      addq.w  #4,SP           ; RÅcksprungadresse vom Stack
                bra     ende_dentro
; ************************ UNTERROUTINEN
_sendIKBD:      pea     (A0)
                lea     $FFFFFC00.w,A0
_waitready:     btst    #1,(A0)
                beq.s   _waitready
                move.b  D0,2(A0)
                movea.l (SP)+,A0
                rts
; *********************************************************************
game_init:      >PART 'Game init'
                move.l  #-1,energie
                move.w  #16,player_x
                move.w  #(50/2)*160,player_y
                move.l  #formationen,form_pointer
                move.l  #0,form_pause
                move.l  #0,vbl_rout
                move.l  #0,end_enemy_rout
                move.w  #0,signal_flag


                lea     schuû_player,A0
                move.w  #max_schuû_player*ins_schuû_player-1,D0
clear_sch_pl:   move.b  #-1,(A0)+
                dbra    D0,clear_sch_pl

                lea     enemy,A0
                move.w  #max_enemy*ins_enemy-1,D0
clear_enemy:    move.b  #-1,(A0)+
                dbra    D0,clear_enemy

                lea     schuû_enemy,A0
                move.w  #max_schuû_enemy*ins_schuû_enemy-1,D0
clear_sch_en:   move.b  #-1,(A0)+
                dbra    D0,clear_sch_en
                rts
                ENDPART
; ************************ End-Gegner1 init...
                >PART
noch_was_da:    subq.l  #6,form_pointer
                rts
end_enemy:      lea     enemy,A0
                moveq   #max_enemy-1,D0
e_e_s_e:        tst.w   (A0)
                bpl.s   noch_was_da
                lea     ins_enemy(A0),A0
                dbra    D0,e_e_s_e

                lea     schuû_enemy,A0
                moveq   #max_schuû_enemy-1,D0
e_e_s_s_e:      tst.w   (A0)
                bpl.s   noch_was_da
                lea     ins_schuû_enemy(A0),A0
                dbra    D0,e_e_s_s_e

                lea     e_enemy+(max_e_enemy*ins_e_enemy),A0
                move.w  #((max_e_enemy*ins_e_enemy)/(4*7))-1,D0
                moveq   #-1,D1
                moveq   #-1,D2
                moveq   #-1,D3
                moveq   #-1,D4
                moveq   #-1,D5
                moveq   #-1,D6
                moveq   #-1,D7
init_e_e:       movem.l D1-D7,-(A0)
                dbra    D0,init_e_e

                move.l  (A1)+,vbl_rout
                move.w  (A1)+,geschw_e_e+2
                move.l  #e_enemy1,end_enemy_rout
                move.w  (A1)+,D0
                subq.w  #1,D0
                lea     e_enemy,A0
set_e_e:        move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                move.w  #0,(A0)+
                move.w  (A1)+,(A0)+
                dbra    D0,set_e_e

                rts
                ENDPART

                >PART 'End-Gegner 1 Daten'
end_enemy1:     DC.L draw_e_e_1 ; Zeichenroutine
                DC.W 8          ; Schuû-VX
                DC.W 4          ; Anzahl der Test-Rechtecke
; dc.w X1,Y1*160,X2,Y2*160,Schuû-X,Schuû-Y*160,Energie
                DC.W 289,9*160,311,15*160,288,12*160,20
                DC.W 289,34*160,311,40*160,288,37*160,20
                DC.W 304,22*160,310,24*160,304,23*160,10
                DC.W 304,46*160,310,48*160,304,47*160,10

draw_e_e_1:     lea     gfx_end_enemy1,A0
                movea.l screen,A1
                lea     160-16(A1),A1

                movem.l (A0)+,D0-D7
                movem.l D0-D3,(A1)
                movem.l D4-D7,160(A1)
.off            SET 320
                REPT 24
                movem.l (A0)+,D0-D7
                movem.l D0-D3,.off(A1)
                movem.l D4-D7,.off+160(A1)
.off            SET .off+320
                ENDR
                rts
                ENDPART
; ************************ End-Gegner bearbeiten
                >PART
e_enemy1:       lea     e_enemy,A0
                moveq   #max_e_enemy-1,D7
                move.w  player_x,D2
                move.w  player_y,D3
                move.w  D2,D4           ; Playerkoo fÅr Kollisionsabfrage
                move.w  D3,D5
                add.w   #11,D4          ; GROûZöGIG !!!!!!!!!!!!!!!!
                add.w   #6*160,D5
                movea.l #0,A3
                movea.w D3,A3
                lea     4*160(A3),A3

e_set_en_loop:  move.w  (A0),D0         ; X-Koo
                bmi     e_next_enemy
                move.w  e_enemy_y1(A0),D1
                cmp.w   D4,D0
                bgt.s   e_nix_kol_enemy
                cmp.w   D5,D1
                bgt.s   e_nix_kol_enemy
                move.w  e_enemy_x2(A0),D6
                cmp.w   D2,D6
                blt.s   e_nix_kol_enemy
                move.w  e_enemy_y2(A0),D6
                cmp.w   D3,D6
                blt.s   e_nix_kol_enemy
                move.w  #-1,kol_player_flag
                subq.w  #1,e_enemy_energie(A0)
                bne.s   e_next_enemy
                move.w  #-1,(A0)
                bra.s   e_next_enemy
e_nix_kol_enemy:
                bchg    #0,e_enemy_sh_f(A0) ; End-Gegner-Schuû
                beq.s   e_no_schuû_enemy ;    verzîgern...
                bchg    #1,e_enemy_sh_f(A0)
                beq.s   e_no_schuû_enemy

                cmpa.w  e_enemy_y1(A0),A3
                blt.s   e_no_schuû_enemy
                cmpa.w  e_enemy_y2(A0),A3
                bgt.s   e_no_schuû_enemy

                lea     schuû_enemy,A1
                moveq   #max_schuû_enemy-1,D6
e_search_en_sch:tst.w   (A1)
                bmi.s   e_found_en_sch
                lea     ins_schuû_enemy(A1),A1
                dbra    D6,e_search_en_sch
                bra.s   e_no_schuû_enemy
e_found_en_sch:
                move.w  e_enemy_sh_y(A0),(A1)+
                move.w  e_enemy_sh_x(A0),D0
                move.w  D0,(A1)+
                move.w  D0,D6
                and.w   #$000F,D6
                add.w   D6,D6
                move.w  e_pix_tab(PC,D6.w),(A1)+
                move.w  #0,(A1)
geschw_e_e:     move.w  #2,2(A1)        ; Geschwindigkeit vom Schuû !!!!!!!!!
                bra.s   e_no_schuû_enemy

e_pix_tab:      DC.W %1000000000000000
                DC.W %0100000000000000
                DC.W %0010000000000000
                DC.W %0001000000000000
                DC.W %0000100000000000
                DC.W %0000010000000000
                DC.W %0000001000000000
                DC.W %0000000100000000
                DC.W %0000000010000000
                DC.W %0000000001000000
                DC.W %0000000000100000
                DC.W %0000000000010000
                DC.W %0000000000001000
                DC.W %0000000000000100
                DC.W %0000000000000010
                DC.W %0000000000000001

e_no_schuû_enemy:
e_next_enemy:   lea     ins_e_enemy(A0),A0
                dbra    D7,e_set_en_loop
                ENDPART
; ************************ Player-SchÅûe bearbeiten (bei End-Gegner)
                >PART
                lea     schuû_player,A0
                moveq   #max_schuû_player-1,D7
e_sch_pl_loop:  move.w  (A0),D0         ; Y-Koo !!!!!!!!!
                bmi.s   e_next_schuû_pl
                addq.w  #schuû_player_vx,2(A0)
                move.w  2(A0),D1        ; X-Koo !!!!!!!!!

                cmp.w   #317,D1
                bge.s   e_clear_schuû_pl

                lea     e_enemy,A1
                moveq   #max_e_enemy-1,D2
e_search_en_plsch:move.w (A1),D3        ; X-Koo vom Gegner
                bmi.s   e_no_kol1
                move.w  e_enemy_y1(A1),D4

                cmp.w   D1,D3
                bgt.s   e_no_kol1
                cmp.w   D0,D4
                bgt.s   e_no_kol1
                move.w  e_enemy_x2(A1),D3
                move.w  e_enemy_y2(A1),D4
                cmp.w   D1,D3
                blt.s   e_no_kol1
                cmp.w   D0,D4
                blt.s   e_no_kol1

                subq.w  #1,e_enemy_energie(A1)
                bne.s   e_clear_schuû_pl
                move.w  #-1,(A1)        ; Gegner lîschen
                bra.s   e_clear_schuû_pl ; und aus Schleife...
e_no_kol1:      adda.w  #ins_e_enemy,A1
                dbra    D2,e_search_en_plsch
                bra.s   e_ende_search_plsch

e_clear_schuû_pl:move.w #-1,(A0)        ; Player-Schuû lîschen
                bra.s   e_next_schuû_pl
e_ende_search_plsch:
                bsr     set_plsh

e_next_schuû_pl:adda.w  #ins_schuû_player,A0
                dbra    D7,e_sch_pl_loop
                ENDPART
                bra     ende_end_enemy

set_sprite:     >PART 'Spriteroutine'
                move.w  D0,D3
                and.w   #$000F,D3       ; Shift ausrechnen
                moveq   #15,D2
                sub.w   D3,D2
                and.w   #-$0010,D0
                lsr.w   #1,D0
                adda.w  D0,A0
                lsl.w   #5,D1
                move.w  D1,D0
                add.w   D1,D1
                add.w   D1,D1
                add.w   D0,D1
                adda.w  D1,A0           ; Screenadresse ausrechnen
                move.l  A0,(A1)+

                lea     blasenshifts,A1
                lsl.w   #7,D2
                adda.w  D2,A1

                movem.l (A1)+,D0-D7
                move.l  D0,(A0)
                move.l  D1,8(A0)
                move.l  D2,160(A0)
                move.l  D3,168(A0)
                move.l  D4,320(A0)
                move.l  D5,328(A0)
                move.l  D6,480(A0)
                move.l  D7,488(A0)
                movem.l (A1)+,D0-D7
                move.l  D0,640(A0)
                move.l  D1,648(A0)
                move.l  D2,800(A0)
                move.l  D3,808(A0)
                move.l  D4,960(A0)
                move.l  D5,968(A0)
                move.l  D6,1120(A0)
                move.l  D7,1128(A0)
                movem.l (A1)+,D0-D7
                move.l  D0,1280(A0)
                move.l  D1,1288(A0)
                move.l  D2,1440(A0)
                move.l  D3,1448(A0)
                move.l  D4,1600(A0)
                move.l  D5,1608(A0)
                move.l  D6,1760(A0)
                move.l  D7,1768(A0)
                movem.l (A1),D0-D7
                move.l  D0,1920(A0)
                move.l  D1,1928(A0)
                move.l  D2,2080(A0)
                move.l  D3,2088(A0)
                move.l  D4,2240(A0)
                move.l  D5,2248(A0)
                move.l  D6,2400(A0)
                move.l  D7,2408(A0)
                rts
                ENDPART
set_sprite_or:  >PART 'Spriteroutine'
                move.w  D0,D3
                and.w   #$000F,D3       ; Shift ausrechnen
                moveq   #15,D2
                sub.w   D3,D2
                and.w   #-$0010,D0
                lsr.w   #1,D0
                adda.w  D0,A0
                lsl.w   #5,D1
                move.w  D1,D0
                add.w   D1,D1
                add.w   D1,D1
                add.w   D0,D1
                adda.w  D1,A0           ; Screenadresse ausrechnen
                move.l  A0,(A1)+

                lea     blasenshifts,A1
                lsl.w   #7,D2
                adda.w  D2,A1

                movem.l (A1)+,D0-D7
                or.l    D0,(A0)
                or.l    D1,8(A0)
                or.l    D2,160(A0)
                or.l    D3,168(A0)
                or.l    D4,320(A0)
                or.l    D5,328(A0)
                or.l    D6,480(A0)
                or.l    D7,488(A0)
                movem.l (A1)+,D0-D7
                or.l    D0,640(A0)
                or.l    D1,648(A0)
                or.l    D2,800(A0)
                or.l    D3,808(A0)
                or.l    D4,960(A0)
                or.l    D5,968(A0)
                or.l    D6,1120(A0)
                or.l    D7,1128(A0)
                movem.l (A1)+,D0-D7
                or.l    D0,1280(A0)
                or.l    D1,1288(A0)
                or.l    D2,1440(A0)
                or.l    D3,1448(A0)
                or.l    D4,1600(A0)
                or.l    D5,1608(A0)
                or.l    D6,1760(A0)
                or.l    D7,1768(A0)
                movem.l (A1),D0-D7
                or.l    D0,1920(A0)
                or.l    D1,1928(A0)
                or.l    D2,2080(A0)
                or.l    D3,2088(A0)
                or.l    D4,2240(A0)
                or.l    D5,2248(A0)
                or.l    D6,2400(A0)
                or.l    D7,2408(A0)
                rts
                ENDPART
newkey:         >PART 'Tastaturroutine'
                btst    #7,$FFFFFC00.w
                beq.s   ende_key
                move.l  D0,-(SP)
                tst.w   tast_flag
                bne.s   noch_da
                move.b  $FFFFFC02.w,D0
                cmp.b   #98,D0
                bne.s   no_help
                not.w   game_flag
no_help:        cmp.b   #$39,D0
                bne.s   no_space
                move.w  #0,ende_flag
no_space:       cmp.b   #$FF,D0
                bne.s   no_joy
                move.w  #-1,tast_flag
no_joy:         move.l  (SP)+,D0
ende_key:       bclr    #3,$FFFFFA17.w
                bset    #6,$FFFFFA15.w
                move.l  #newkey,$00000118.w
                rte
noch_da:        moveq   #0,D0
                move.b  $FFFFFC02.w,D0
                move.w  D0,joydata
                clr.w   tast_flag
                move.l  (SP)+,D0
                bclr    #3,$FFFFFA17.w
                bset    #6,$FFFFFA15.w
                move.l  #newkey,$00000118.w
                rte
tast_flag:      DC.W 0
                ENDPART
; *********************************************************************
; ************************ Sprites Shiften
                >PART
shift_sprites:  lea     gfx_player_shift,A0
                moveq   #16-1,D0
shift_pl1:      lea     gfx_player,A1
                moveq   #6-1,D1         ; Hîhe
shift_pl2:      movem.w (A1)+,D2-D5
                move.w  D2,D6
                or.w    D3,D6
                or.w    D4,D6
                move.w  D6,(A0)+
                move.w  D6,(A0)+        ; Maske doppelt reinschreiben

                movem.w D2-D4,(A0)
                addq.w  #6,A0

                move.l  #0,(A0)+        ; fÅr Maske
                move.l  #0,(A0)+
                move.w  #0,(A0)+
                dbra    D1,shift_pl2
                dbra    D0,shift_pl1

                lea     gfx_player_shift,A0
                moveq   #0,D0
shift_pl3:      moveq   #6-1,D1         ; Zeilen
shift_pl4:      moveq   #0,D2
                move.w  (A0),D2
                swap    D2
                lsr.l   D0,D2
                not.l   D2
                move.w  D2,10(A0)
                move.w  D2,12(A0)
                swap    D2
                move.w  D2,(A0)
                move.w  D2,2(A0)

                moveq   #0,D2
                move.w  4(A0),D2
                swap    D2
                lsr.l   D0,D2
                move.w  D2,14(A0)
                swap    D2
                move.w  D2,4(A0)

                moveq   #0,D2
                move.w  6(A0),D2
                swap    D2
                lsr.l   D0,D2
                move.w  D2,16(A0)
                swap    D2
                move.w  D2,6(A0)

                moveq   #0,D2
                move.w  8(A0),D2
                swap    D2
                lsr.l   D0,D2
                move.w  D2,18(A0)
                swap    D2
                move.w  D2,8(A0)

                lea     20(A0),A0
                dbra    D1,shift_pl4
                addq.w  #1,D0
                cmp.w   #16,D0
                bne.s   shift_pl3

; ***********************************************

                lea     gfx_kugel_shift1,A1
                moveq   #8-1,D0         ; Shiftanzahl
sh_kugel1:      moveq   #8-1,D1         ; Zeilen
                lea     gfx_kugel,A0
sh_kugel2:      movem.w (A0)+,D2-D5
                move.w  D2,D6
                or.w    D3,D6
;                or.w    D4,D6          ; die 3. Plane wird nicht gebraucht
                or.w    D5,D6
                move.w  D6,(A1)+
                move.w  D6,(A1)+

                move.w  D2,(A1)+
                move.w  D3,(A1)+
;                move.w  D4,(A1)+
                move.w  D5,(A1)+
                dbra    D1,sh_kugel2
                dbra    D0,sh_kugel1

                lea     gfx_kugel_shift1,A0
                moveq   #0,D0
sh_kugel3:      moveq   #8-1,D1
sh_kugel4:      move.w  (A0),D2
                lsr.w   D0,D2
                not.w   D2
                move.w  D2,(A0)+
                move.w  D2,(A0)+

                REPT 3
                move.w  (A0),D2
                lsr.w   D0,D2
                move.w  D2,(A0)+
                ENDR
                dbra    D1,sh_kugel4
                addq.w  #1,D0
                cmp.w   #8,D0
                bne.s   sh_kugel3

                lea     gfx_kugel_shift1,A0
                lea     gfx_kugel_shift2,A1
                moveq   #8-1,D0
sh_kugel5:      moveq   #8-1,D1
sh_kugel6:      move.b  (A0),(A1)+
                move.b  (A0),(A1)+
                move.b  (A0),(A1)+
                move.b  (A0),(A1)+

                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+

                move.b  4(A0),(A1)+
                move.b  6(A0),(A1)+
                move.b  #0,(A1)+
                move.b  8(A0),(A1)+

                move.b  5(A0),(A1)+
                move.b  7(A0),(A1)+
                move.b  #0,(A1)+
                move.b  9(A0),(A1)+

                lea     10(A0),A0
                dbra    D1,sh_kugel6
                dbra    D0,sh_kugel5

; *********************************

                lea     gfx_boot_shift1,A1
                moveq   #8-1,D0         ; Shiftanzahl
sh_boot1:       moveq   #7-1,D1         ; Zeilen
                lea     gfx_boot,A0
sh_boot2:       movem.w (A0)+,D2-D5
                move.w  D2,D6
                or.w    D3,D6
;                or.w    D4,D6          ; die 3. Plane wird nicht gebraucht
;                or.w    D5,D6
                move.w  D6,(A1)+
                move.w  D6,(A1)+

                move.w  D2,(A1)+
                move.w  D3,(A1)+
;                move.w  D4,(A1)+
;                move.w  D5,(A1)+
                dbra    D1,sh_boot2
                dbra    D0,sh_boot1

                lea     gfx_boot_shift1,A0
                moveq   #0,D0
sh_boot3:       moveq   #7-1,D1
sh_boot4:       move.w  (A0),D2
                lsr.w   D0,D2
                not.w   D2
                move.w  D2,(A0)+
                move.w  D2,(A0)+

                REPT 2
                move.w  (A0),D2
                lsr.w   D0,D2
                move.w  D2,(A0)+
                ENDR
                dbra    D1,sh_boot4
                addq.w  #1,D0
                cmp.w   #8,D0
                bne.s   sh_boot3

                lea     gfx_boot_shift1,A0
                lea     gfx_boot_shift2,A1
                moveq   #8-1,D0
sh_boot5:       moveq   #7-1,D1
sh_boot6:       move.b  (A0),(A1)+
                move.b  (A0),(A1)+
                move.b  (A0),(A1)+
                move.b  (A0),(A1)+

                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+

                move.b  4(A0),(A1)+
                move.b  6(A0),(A1)+
                move.b  #0,(A1)+
                move.b  #0,(A1)+

                move.b  5(A0),(A1)+
                move.b  7(A0),(A1)+
                move.b  #0,(A1)+
                move.b  #0,(A1)+

                lea     8(A0),A0
                dbra    D1,sh_boot6
                dbra    D0,sh_boot5

; *****************************************

                lea     gfx_plsh_shift1,A1
                moveq   #8-1,D0         ; Shiftanzahl
sh_plsh1:
                moveq   #3-1,D1         ; Zeilen
                lea     gfx_plsh,A0
sh_plsh2:       movem.w (A0)+,D2-D5
                move.w  D2,D6
                or.w    D3,D6
                or.w    D4,D6           ; die 3. Plane wird nicht gebraucht
;                or.w    D5,D6
                move.w  D6,(A1)+
                move.w  D6,(A1)+

                move.w  D2,(A1)+
                move.w  D3,(A1)+
                move.w  D4,(A1)+
;                move.w  D5,(A1)+
                dbra    D1,sh_plsh2
                dbra    D0,sh_plsh1

                lea     gfx_plsh_shift1,A0
                moveq   #0,D0
sh_plsh3:       moveq   #3-1,D1
sh_plsh4:       move.w  (A0),D2
                lsr.w   D0,D2
                not.w   D2
                move.w  D2,(A0)+
                move.w  D2,(A0)+

                REPT 3
                move.w  (A0),D2
                lsr.w   D0,D2
                move.w  D2,(A0)+
                ENDR
                dbra    D1,sh_plsh4
                addq.w  #1,D0
                cmp.w   #8,D0
                bne.s   sh_plsh3

                lea     gfx_plsh_shift1,A0
                lea     gfx_plsh_shift2,A1
                moveq   #8-1,D0
sh_plsh5:       moveq   #3-1,D1
sh_plsh6:       move.b  (A0),(A1)+
                move.b  (A0),(A1)+
                move.b  (A0),(A1)+
                move.b  (A0),(A1)+

                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+

                move.b  4(A0),(A1)+
                move.b  6(A0),(A1)+
                move.b  8(A0),(A1)+
                move.b  #0,(A1)+

                move.b  5(A0),(A1)+
                move.b  7(A0),(A1)+
                move.b  9(A0),(A1)+
                move.b  #0,(A1)+

                lea     10(A0),A0
                dbra    D1,sh_plsh6
                dbra    D0,sh_plsh5
; *************************************
                lea     gfx_pac_shift1,A1
                moveq   #8-1,D0         ; Shiftanzahl
sh_pac1:        moveq   #8-1,D1         ; Zeilen
                lea     gfx_pac,A0
sh_pac2:        movem.w (A0)+,D2-D5
                move.w  D2,D6
                or.w    D3,D6
                or.w    D4,D6           ; die 3. Plane wird nicht gebraucht
;                or.w    D5,D6
                move.w  D6,(A1)+
                move.w  D6,(A1)+

                move.w  D2,(A1)+
                move.w  D3,(A1)+
                move.w  D4,(A1)+
;                move.w  D5,(A1)+
                dbra    D1,sh_pac2
                dbra    D0,sh_pac1

                lea     gfx_pac_shift1,A0
                moveq   #0,D0
sh_pac3:        moveq   #8-1,D1
sh_pac4:        move.w  (A0),D2
                lsr.w   D0,D2
                not.w   D2
                move.w  D2,(A0)+
                move.w  D2,(A0)+

                REPT 3
                move.w  (A0),D2
                lsr.w   D0,D2
                move.w  D2,(A0)+
                ENDR
                dbra    D1,sh_pac4
                addq.w  #1,D0
                cmp.w   #8,D0
                bne.s   sh_pac3

                lea     gfx_pac_shift1,A0
                lea     gfx_pac_shift2,A1
                moveq   #8-1,D0
sh_pac5:        moveq   #8-1,D1
sh_pac6:        move.b  (A0),(A1)+
                move.b  (A0),(A1)+
                move.b  (A0),(A1)+
                move.b  (A0),(A1)+

                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+

                move.b  4(A0),(A1)+
                move.b  6(A0),(A1)+
                move.b  8(A0),(A1)+
                move.b  #0,(A1)+

                move.b  5(A0),(A1)+
                move.b  7(A0),(A1)+
                move.b  9(A0),(A1)+
                move.b  #0,(A1)+

                lea     10(A0),A0
                dbra    D1,sh_pac6
                dbra    D0,sh_pac5

; *********************************
                lea     gfx_raum1_shift1,A1
                moveq   #8-1,D0         ; Shiftanzahl
sh_raum11:      moveq   #6-1,D1         ; Zeilen
                lea     gfx_raum1,A0
sh_raum12:      movem.w (A0)+,D2-D5
                move.w  D2,D6
                or.w    D3,D6
                or.w    D4,D6           ; die 3. Plane wird nicht gebraucht
;                or.w    D5,D6
                move.w  D6,(A1)+
                move.w  D6,(A1)+

                move.w  D2,(A1)+
                move.w  D3,(A1)+
                move.w  D4,(A1)+
;                move.w  D5,(A1)+
                dbra    D1,sh_raum12
                dbra    D0,sh_raum11

                lea     gfx_raum1_shift1,A0
                moveq   #0,D0
sh_raum13:      moveq   #6-1,D1
sh_raum14:      move.w  (A0),D2
                lsr.w   D0,D2
                not.w   D2
                move.w  D2,(A0)+
                move.w  D2,(A0)+

                REPT 3
                move.w  (A0),D2
                lsr.w   D0,D2
                move.w  D2,(A0)+
                ENDR
                dbra    D1,sh_raum14
                addq.w  #1,D0
                cmp.w   #8,D0
                bne.s   sh_raum13

                lea     gfx_raum1_shift1,A0
                lea     gfx_raum1_shift2,A1
                moveq   #8-1,D0
sh_raum15:      moveq   #6-1,D1
sh_raum16:      move.b  (A0),(A1)+
                move.b  (A0),(A1)+
                move.b  (A0),(A1)+
                move.b  (A0),(A1)+

                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+

                move.b  4(A0),(A1)+
                move.b  6(A0),(A1)+
                move.b  8(A0),(A1)+
                move.b  #0,(A1)+

                move.b  5(A0),(A1)+
                move.b  7(A0),(A1)+
                move.b  9(A0),(A1)+
                move.b  #0,(A1)+

                lea     10(A0),A0
                dbra    D1,sh_raum16
                dbra    D0,sh_raum15

; *********************************
                lea     gfx_raum2_shift1,A1
                moveq   #8-1,D0         ; Shiftanzahl
sh_raum21:      moveq   #5-1,D1         ; Zeilen
                lea     gfx_raum2,A0
sh_raum22:      movem.w (A0)+,D2-D5
                move.w  D2,D6
                or.w    D3,D6
                or.w    D4,D6           ; die 3. Plane wird nicht gebraucht
;                or.w    D5,D6
                move.w  D6,(A1)+
                move.w  D6,(A1)+

                move.w  D2,(A1)+
                move.w  D3,(A1)+
                move.w  D4,(A1)+
;                move.w  D5,(A1)+
                dbra    D1,sh_raum22
                dbra    D0,sh_raum21

                lea     gfx_raum2_shift1,A0
                moveq   #0,D0
sh_raum23:      moveq   #5-1,D1
sh_raum24:      move.w  (A0),D2
                lsr.w   D0,D2
                not.w   D2
                move.w  D2,(A0)+
                move.w  D2,(A0)+

                REPT 3
                move.w  (A0),D2
                lsr.w   D0,D2
                move.w  D2,(A0)+
                ENDR
                dbra    D1,sh_raum24
                addq.w  #1,D0
                cmp.w   #8,D0
                bne.s   sh_raum23

                lea     gfx_raum2_shift1,A0
                lea     gfx_raum2_shift2,A1
                moveq   #8-1,D0
sh_raum25:      moveq   #5-1,D1
sh_raum26:      move.b  (A0),(A1)+
                move.b  (A0),(A1)+
                move.b  (A0),(A1)+
                move.b  (A0),(A1)+

                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+

                move.b  4(A0),(A1)+
                move.b  6(A0),(A1)+
                move.b  8(A0),(A1)+
                move.b  #0,(A1)+

                move.b  5(A0),(A1)+
                move.b  7(A0),(A1)+
                move.b  9(A0),(A1)+
                move.b  #0,(A1)+

                lea     10(A0),A0
                dbra    D1,sh_raum26
                dbra    D0,sh_raum25

; *********************************
                lea     gfx_raum3_shift1,A1
                moveq   #8-1,D0         ; Shiftanzahl
sh_raum31:      moveq   #5-1,D1         ; Zeilen
                lea     gfx_raum3,A0
sh_raum32:      movem.w (A0)+,D2-D5
                move.w  D2,D6
                or.w    D3,D6
                or.w    D4,D6           ; die 3. Plane wird nicht gebraucht
;                or.w    D5,D6
                move.w  D6,(A1)+
                move.w  D6,(A1)+

                move.w  D2,(A1)+
                move.w  D3,(A1)+
                move.w  D4,(A1)+
;                move.w  D5,(A1)+
                dbra    D1,sh_raum32
                dbra    D0,sh_raum31

                lea     gfx_raum3_shift1,A0
                moveq   #0,D0
sh_raum33:      moveq   #5-1,D1
sh_raum34:      move.w  (A0),D2
                lsr.w   D0,D2
                not.w   D2
                move.w  D2,(A0)+
                move.w  D2,(A0)+

                REPT 3
                move.w  (A0),D2
                lsr.w   D0,D2
                move.w  D2,(A0)+
                ENDR
                dbra    D1,sh_raum34
                addq.w  #1,D0
                cmp.w   #8,D0
                bne.s   sh_raum33

                lea     gfx_raum3_shift1,A0
                lea     gfx_raum3_shift2,A1
                moveq   #8-1,D0
sh_raum35:      moveq   #5-1,D1
sh_raum36:      move.b  (A0),(A1)+
                move.b  (A0),(A1)+
                move.b  (A0),(A1)+
                move.b  (A0),(A1)+

                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+

                move.b  4(A0),(A1)+
                move.b  6(A0),(A1)+
                move.b  8(A0),(A1)+
                move.b  #0,(A1)+

                move.b  5(A0),(A1)+
                move.b  7(A0),(A1)+
                move.b  9(A0),(A1)+
                move.b  #0,(A1)+

                lea     10(A0),A0
                dbra    D1,sh_raum36
                dbra    D0,sh_raum35

; *********************************
                lea     gfx_disk_shift1,A1
                moveq   #8-1,D0         ; Shiftanzahl
sh_disk1:       moveq   #8-1,D1         ; Zeilen
                lea     gfx_disk,A0
sh_disk2:       movem.w (A0)+,D2-D5
                move.w  D2,D6
                or.w    D3,D6
                or.w    D4,D6           ; die 3. Plane wird nicht gebraucht
                or.w    D5,D6
                move.w  D6,(A1)+
                move.w  D6,(A1)+

                move.w  D2,(A1)+
                move.w  D3,(A1)+
                move.w  D4,(A1)+
                move.w  D5,(A1)+
                dbra    D1,sh_disk2
                dbra    D0,sh_disk1

                lea     gfx_disk_shift1,A0
                moveq   #0,D0
sh_disk3:       moveq   #8-1,D1
sh_disk4:       move.w  (A0),D2
                lsr.w   D0,D2
                not.w   D2
                move.w  D2,(A0)+
                move.w  D2,(A0)+

                REPT 4
                move.w  (A0),D2
                lsr.w   D0,D2
                move.w  D2,(A0)+
                ENDR
                dbra    D1,sh_disk4
                addq.w  #1,D0
                cmp.w   #8,D0
                bne.s   sh_disk3

                lea     gfx_disk_shift1,A0
                lea     gfx_disk_shift2,A1
                moveq   #8-1,D0
sh_disk5:       moveq   #8-1,D1
sh_disk6:       move.b  (A0),(A1)+
                move.b  (A0),(A1)+
                move.b  (A0),(A1)+
                move.b  (A0),(A1)+

                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+

                move.b  4(A0),(A1)+
                move.b  6(A0),(A1)+
                move.b  8(A0),(A1)+
                move.b  10(A0),(A1)+

                move.b  5(A0),(A1)+
                move.b  7(A0),(A1)+
                move.b  9(A0),(A1)+
                move.b  11(A0),(A1)+

                lea     12(A0),A0
                dbra    D1,sh_disk6
                dbra    D0,sh_disk5

; *******************************

                lea     gfx_kla_shift1,A1
                moveq   #8-1,D0         ; Shiftanzahl
sh_kla1:        moveq   #7-1,D1         ; Zeilen
                lea     gfx_kla,A0
sh_kla2:        movem.w (A0)+,D2-D5
                move.w  D2,D6
                or.w    D3,D6
;                or.w    D4,D6          ; die 3. Plane wird nicht gebraucht
                or.w    D5,D6
                move.w  D6,(A1)+
                move.w  D6,(A1)+

                move.w  D2,(A1)+
                move.w  D3,(A1)+
;                move.w  D4,(A1)+
                move.w  D5,(A1)+
                dbra    D1,sh_kla2
                dbra    D0,sh_kla1

                lea     gfx_kla_shift1,A0
                moveq   #0,D0
sh_kla3:        moveq   #7-1,D1
sh_kla4:        move.w  (A0),D2
                lsr.w   D0,D2
                not.w   D2
                move.w  D2,(A0)+
                move.w  D2,(A0)+

                REPT 3
                move.w  (A0),D2
                lsr.w   D0,D2
                move.w  D2,(A0)+
                ENDR
                dbra    D1,sh_kla4
                addq.w  #1,D0
                cmp.w   #8,D0
                bne.s   sh_kla3

                lea     gfx_kla_shift1,A0
                lea     gfx_kla_shift2,A1
                moveq   #8-1,D0
sh_kla5:        moveq   #7-1,D1
sh_kla6:        move.b  (A0),(A1)+
                move.b  (A0),(A1)+
                move.b  (A0),(A1)+
                move.b  (A0),(A1)+

                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+
                move.b  1(A0),(A1)+

                move.b  4(A0),(A1)+
                move.b  6(A0),(A1)+
                move.b  #0,(A1)+
                move.b  8(A0),(A1)+

                move.b  5(A0),(A1)+
                move.b  7(A0),(A1)+
                move.b  #0,(A1)+
                move.b  9(A0),(A1)+

                lea     10(A0),A0
                dbra    D1,sh_kla6
                dbra    D0,sh_kla5

                rts
                ENDPART
; ************************ Sprites Zeichnen
                >PART
set_player:     movea.l screen,A0
                adda.w  D1,A0
                move.w  D0,D1
                and.w   #-$0010,D0
                lsr.w   #1,D0
                adda.w  D0,A0

                lea     gfx_player_shift,A1
                and.w   #$000F,D1
                mulu    #120,D1
                adda.w  D1,A1

                REPT 6
                move.l  (A1)+,D0
                and.l   D0,(A0)
                and.l   D0,4(A0)
                move.l  (A1)+,D0
                or.l    D0,(A0)
                move.w  (A1)+,D0
                or.w    D0,4(A0)

                move.l  (A1)+,D0
                and.l   D0,8(A0)
                and.l   D0,12(A0)
                move.l  (A1)+,D0
                or.l    D0,8(A0)
                move.w  (A1)+,D0
                or.w    D0,12(A0)
                lea     160(A0),A0
                ENDR
                rts
set_kugel:      movem.l D0-D1/A0-A1,-(SP)
                movea.l screen,A0
                adda.w  D1,A0
                move.w  D0,D1
                and.w   #$FFF0,D1
                lsr.w   #1,D1
                adda.w  D1,A0
                and.w   #$000F,D0
                cmp.w   #8,D0
                bge     set_kugel_word
                lea     gfx_kugel_shift1,A1
                mulu    #80,D0
                adda.w  D0,A1

                REPT 8
                move.l  (A1)+,D0
                and.l   D0,(A0)
                and.l   D0,4(A0)
                move.l  (A1)+,D0
                or.l    D0,(A0)
                move.w  (A1)+,D0
                or.w    D0,6(A0)
                lea     160(A0),A0
                ENDR
                movem.l (SP)+,D0-D1/A0-A1
                rts
set_kugel_word: lea     gfx_kugel_shift2,A1
                subq.w  #8,D0
                mulu    #128,D0
                adda.w  D0,A1

                REPT 8
                movep.l 1(A0),D0
                movep.l 8(A0),D1
                and.l   (A1)+,D0
                and.l   (A1)+,D1
                or.l    (A1)+,D0
                or.l    (A1)+,D1
                movep.l D0,1(A0)
                movep.l D1,8(A0)
                lea     160(A0),A0
                ENDR
                movem.l (SP)+,D0-D1/A0-A1
                rts

set_boot:       movem.l D0-D1/A0-A1,-(SP)
                movea.l screen,A0
                adda.w  D1,A0
                move.w  D0,D1
                and.w   #$FFF0,D1
                lsr.w   #1,D1
                adda.w  D1,A0
                and.w   #$000F,D0
                cmp.w   #8,D0
                bge     set_boot_word
                lea     gfx_boot_shift1,A1
                mulu    #56,D0
                adda.w  D0,A1

                REPT 7
                move.l  (A1)+,D0
                and.l   D0,(A0)
                and.l   D0,4(A0)
                move.l  (A1)+,D0
                or.l    D0,(A0)
                lea     160(A0),A0
                ENDR
                movem.l (SP)+,D0-D1/A0-A1
                rts
set_boot_word:  lea     gfx_boot_shift2,A1
                subq.w  #8,D0
                mulu    #112,D0
                adda.w  D0,A1

                REPT 7
                movep.l 1(A0),D0
                movep.l 8(A0),D1
                and.l   (A1)+,D0
                and.l   (A1)+,D1
                or.l    (A1)+,D0
                or.l    (A1)+,D1
                movep.l D0,1(A0)
                movep.l D1,8(A0)
                lea     160(A0),A0
                ENDR
                movem.l (SP)+,D0-D1/A0-A1
                rts

set_pac:        movem.l D0-D1/A0-A1,-(SP)
                movea.l screen,A0
                adda.w  D1,A0
                move.w  D0,D1
                and.w   #$FFF0,D1
                lsr.w   #1,D1
                adda.w  D1,A0
                and.w   #$000F,D0
                cmp.w   #8,D0
                bge     set_pac_word
                lea     gfx_pac_shift1,A1
                mulu    #80,D0
                adda.w  D0,A1

                REPT 8
                move.l  (A1)+,D0
                and.l   D0,(A0)
                and.l   D0,4(A0)
                move.l  (A1)+,D0
                or.l    D0,(A0)
                move.w  (A1)+,D0
                or.w    D0,4(A0)
                lea     160(A0),A0
                ENDR
                movem.l (SP)+,D0-D1/A0-A1
                rts
set_pac_word:   lea     gfx_pac_shift2,A1
                subq.w  #8,D0
                mulu    #128,D0
                adda.w  D0,A1

                REPT 8
                movep.l 1(A0),D0
                movep.l 8(A0),D1
                and.l   (A1)+,D0
                and.l   (A1)+,D1
                or.l    (A1)+,D0
                or.l    (A1)+,D1
                movep.l D0,1(A0)
                movep.l D1,8(A0)
                lea     160(A0),A0
                ENDR
                movem.l (SP)+,D0-D1/A0-A1
                rts

set_raum1:      movem.l D0-D1/A0-A1,-(SP)
                movea.l screen,A0
                lea     160(A0),A0
                adda.w  D1,A0
                move.w  D0,D1
                and.w   #$FFF0,D1
                lsr.w   #1,D1
                adda.w  D1,A0
                and.w   #$000F,D0
                cmp.w   #8,D0
                bge     set_raum1_word
                lea     gfx_raum1_shift1,A1
                mulu    #10*6,D0
                adda.w  D0,A1

                REPT 6
                move.l  (A1)+,D0
                and.l   D0,(A0)
                and.l   D0,4(A0)
                move.l  (A1)+,D0
                or.l    D0,(A0)
                move.w  (A1)+,D0
                or.w    D0,4(A0)
                lea     160(A0),A0
                ENDR
                movem.l (SP)+,D0-D1/A0-A1
                rts
set_raum1_word: lea     gfx_raum1_shift2,A1
                subq.w  #8,D0
                mulu    #16*6,D0
                adda.w  D0,A1

                REPT 6
                movep.l 1(A0),D0
                movep.l 8(A0),D1
                and.l   (A1)+,D0
                and.l   (A1)+,D1
                or.l    (A1)+,D0
                or.l    (A1)+,D1
                movep.l D0,1(A0)
                movep.l D1,8(A0)
                lea     160(A0),A0
                ENDR
                movem.l (SP)+,D0-D1/A0-A1
                rts

set_raum2:      movem.l D0-D1/A0-A1,-(SP)
                movea.l screen,A0
                lea     160(A0),A0
                adda.w  D1,A0
                move.w  D0,D1
                and.w   #$FFF0,D1
                lsr.w   #1,D1
                adda.w  D1,A0
                and.w   #$000F,D0
                cmp.w   #8,D0
                bge     set_raum2_word
                lea     gfx_raum2_shift1,A1
                mulu    #10*5,D0
                adda.w  D0,A1

                REPT 5
                move.l  (A1)+,D0
                and.l   D0,(A0)
                and.l   D0,4(A0)
                move.l  (A1)+,D0
                or.l    D0,(A0)
                move.w  (A1)+,D0
                or.w    D0,4(A0)
                lea     160(A0),A0
                ENDR
                movem.l (SP)+,D0-D1/A0-A1
                rts
set_raum2_word: lea     gfx_raum2_shift2,A1
                subq.w  #8,D0
                mulu    #16*5,D0
                adda.w  D0,A1

                REPT 5
                movep.l 1(A0),D0
                movep.l 8(A0),D1
                and.l   (A1)+,D0
                and.l   (A1)+,D1
                or.l    (A1)+,D0
                or.l    (A1)+,D1
                movep.l D0,1(A0)
                movep.l D1,8(A0)
                lea     160(A0),A0
                ENDR
                movem.l (SP)+,D0-D1/A0-A1
                rts

set_raum3:      movem.l D0-D1/A0-A1,-(SP)
                movea.l screen,A0
                lea     160(A0),A0
                adda.w  D1,A0
                move.w  D0,D1
                and.w   #$FFF0,D1
                lsr.w   #1,D1
                adda.w  D1,A0
                and.w   #$000F,D0
                cmp.w   #8,D0
                bge     set_raum3_word
                lea     gfx_raum3_shift1,A1
                mulu    #10*5,D0
                adda.w  D0,A1

                REPT 5
                move.l  (A1)+,D0
                and.l   D0,(A0)
                and.l   D0,4(A0)
                move.l  (A1)+,D0
                or.l    D0,(A0)
                move.w  (A1)+,D0
                or.w    D0,4(A0)
                lea     160(A0),A0
                ENDR
                movem.l (SP)+,D0-D1/A0-A1
                rts
set_raum3_word: lea     gfx_raum3_shift2,A1
                subq.w  #8,D0
                mulu    #16*5,D0
                adda.w  D0,A1

                REPT 5
                movep.l 1(A0),D0
                movep.l 8(A0),D1
                and.l   (A1)+,D0
                and.l   (A1)+,D1
                or.l    (A1)+,D0
                or.l    (A1)+,D1
                movep.l D0,1(A0)
                movep.l D1,8(A0)
                lea     160(A0),A0
                ENDR
                movem.l (SP)+,D0-D1/A0-A1
                rts

set_disk:       movem.l D0-D1/A0-A1,-(SP)
                movea.l screen,A0
                adda.w  D1,A0
                move.w  D0,D1
                and.w   #$FFF0,D1
                lsr.w   #1,D1
                adda.w  D1,A0
                and.w   #$000F,D0
                cmp.w   #8,D0
                bge     set_disk_word
                lea     gfx_disk_shift1,A1
                mulu    #12*8,D0
                adda.w  D0,A1

                REPT 8
                move.l  (A1)+,D0
                and.l   D0,(A0)
                and.l   D0,4(A0)
                move.l  (A1)+,D0
                or.l    D0,(A0)
                move.l  (A1)+,D0
                or.l    D0,4(A0)
                lea     160(A0),A0
                ENDR
                movem.l (SP)+,D0-D1/A0-A1
                rts
set_disk_word:  lea     gfx_disk_shift2,A1
                subq.w  #8,D0
                mulu    #16*8,D0
                adda.w  D0,A1

                REPT 8
                movep.l 1(A0),D0
                movep.l 8(A0),D1
                and.l   (A1)+,D0
                and.l   (A1)+,D1
                or.l    (A1)+,D0
                or.l    (A1)+,D1
                movep.l D0,1(A0)
                movep.l D1,8(A0)
                lea     160(A0),A0
                ENDR
                movem.l (SP)+,D0-D1/A0-A1
                rts

set_kla:        movem.l D0-D1/A0-A1,-(SP)
                movea.l screen,A0
                adda.w  D1,A0
                move.w  D0,D1
                and.w   #$FFF0,D1
                lsr.w   #1,D1
                adda.w  D1,A0
                and.w   #$000F,D0
                cmp.w   #8,D0
                bge     set_kla_word
                lea     gfx_kla_shift1,A1
                mulu    #70,D0
                adda.w  D0,A1

                REPT 7
                move.l  (A1)+,D0
                and.l   D0,(A0)
                and.l   D0,4(A0)
                move.l  (A1)+,D0
                or.l    D0,(A0)
                move.w  (A1)+,D0
                or.w    D0,6(A0)
                lea     160(A0),A0
                ENDR
                movem.l (SP)+,D0-D1/A0-A1
                rts
set_kla_word:   lea     gfx_kla_shift2,A1
                subq.w  #8,D0
                mulu    #16*7,D0
                adda.w  D0,A1

                REPT 7
                movep.l 1(A0),D0
                movep.l 8(A0),D1
                and.l   (A1)+,D0
                and.l   (A1)+,D1
                or.l    (A1)+,D0
                or.l    (A1)+,D1
                movep.l D0,1(A0)
                movep.l D1,8(A0)
                lea     160(A0),A0
                ENDR
                movem.l (SP)+,D0-D1/A0-A1
                rts

; HIER SIND DIE KOO VERTAUSCHT !!!!!!!!!
set_plsh:       movem.l D0-D1/A0-A1,-(SP)
                movea.l screen,A0
                adda.w  D0,A0
                move.w  D1,D0
                and.w   #$FFF0,D1
                lsr.w   #1,D1
                adda.w  D1,A0
                and.w   #$000F,D0
                cmp.w   #8,D0
                bge     set_plsh_word
                lea     gfx_plsh_shift1,A1
                mulu    #10*3,D0
                adda.w  D0,A1

                REPT 3
                move.l  (A1)+,D0
                and.l   D0,(A0)
                and.l   D0,4(A0)
                move.l  (A1)+,D0
                or.l    D0,(A0)
                move.w  (A1)+,D0
                or.w    D0,4(A0)
                lea     160(A0),A0
                ENDR

                movem.l (SP)+,D0-D1/A0-A1
                rts
set_plsh_word:  lea     gfx_plsh_shift2,A1
                subq.w  #8,D0
                mulu    #16*3,D0
                adda.w  D0,A1

                REPT 3
                movep.l 1(A0),D0
                movep.l 8(A0),D1
                and.l   (A1)+,D0
                and.l   (A1)+,D1
                or.l    (A1)+,D0
                or.l    (A1)+,D1
                movep.l D0,1(A0)
                movep.l D1,8(A0)
                lea     160(A0),A0
                ENDR

                movem.l (SP)+,D0-D1/A0-A1
                rts

                ENDPART
; ************************ GRAFIKEN + PALETTEN
                >PART
game_palette:   DC.W $0000,$0777,$0444,$0222,$0700,$0730,$0750,$0760
                DC.W $0303,$0505,$0706,$0060,$0030,$0500,$0300,$0200

gfx_player:     DC.W $03C0,$0240,$0000,$0000 ; Erledigt
                DC.W $03E0,$1820,$3800,$0000
                DC.W $0FF0,$3C90,$FC00,$0000
                DC.W $0EB8,$3C08,$FD40,$0000
                DC.W $03FC,$18A4,$38A0,$0000
                DC.W $03FC,$0200,$0000,$0000

gfx_kugel:      DC.W $0000,$0000,$0000,$3C00 ; Erledigt
                DC.W $2000,$0000,$0000,$7E00
                DC.W $5200,$2000,$0000,$FF00
                DC.W $2000,$0200,$0000,$FF00
                DC.W $0400,$0200,$0000,$FF00
                DC.W $0A00,$0400,$0000,$FF00
                DC.W $2600,$1800,$0000,$7E00
                DC.W $0000,$0000,$0000,$3C00

gfx_boot:       DC.W $0C00,$0C00,$0000,$0000 ; Erledigt
                DC.W $1E00,$1E00,$0000,$0000
                DC.W $1200,$1E00,$0000,$0000
                DC.W $7F00,$7F00,$0000,$0000
                DC.W $D500,$FF00,$0000,$0000
                DC.W $FF00,$FF00,$0000,$0000
                DC.W $3E00,$3E00,$0000,$0000

gfx_plsh:       DC.W $4000,$0000,$4000,$0000 ; Erledigt
                DC.W $E000,$4000,$E000,$0000
                DC.W $4000,$0000,$4000,$0000

gfx_disk:       DC.W $FF00,$0000,$8100,$8100 ; Erledigt
                DC.W $FF00,$3400,$8100,$8100
                DC.W $FF00,$0800,$8100,$8100
                DC.W $FF00,$0000,$C300,$C300
                DC.W $FF00,$0000,$FF00,$FF00
                DC.W $C300,$3C00,$C300,$C300
                DC.W $D300,$2C00,$D300,$D300
                DC.W $C300,$3C00,$C300,$C300

gfx_pac:        DC.W $0000,$3C00,$3C00,$0000 ; Erledigt
                DC.W $0000,$4E00,$4E00,$0000
                DC.W $0000,$FF00,$FF00,$0000
                DC.W $0200,$7700,$7700,$0000
                DC.W $0200,$0F00,$0F00,$0000
                DC.W $0400,$FF00,$FF00,$0000
                DC.W $1800,$7E00,$7E00,$0000
                DC.W $0000,$3C00,$3C00,$0000

gfx_kla:        DC.W $7800,$0000,$0000,$7800 ; Erledigt
                DC.W $8000,$4000,$0000,$CC00
                DC.W $5000,$8000,$0000,$DC00
                DC.W $5000,$8000,$0000,$D400
                DC.W $5000,$8000,$0000,$DC00
                DC.W $8000,$4000,$0000,$C000
                DC.W $7800,$0000,$0000,$7C00

gfx_raum1:      DC.W $0700,$0800,$0000,$0000 ; Erledigt
                DC.W $3A00,$4500,$0700,$0000
                DC.W $FF00,$0000,$0000,$0000
                DC.W $FF00,$0000,$0000,$0000
                DC.W $3A00,$4500,$0700,$0000
                DC.W $0700,$0800,$0000,$0000

gfx_raum2:      DC.W $0700,$1800,$1F00,$0000 ; Erledigt
                DC.W $0000,$7C00,$7C00,$0000
                DC.W $FF00,$0000,$0700,$0000
                DC.W $0000,$7C00,$7C00,$0000
                DC.W $0700,$1800,$1F00,$0000

gfx_raum3:      DC.W $0600,$0800,$0000,$0000 ; Erledigt
                DC.W $3A00,$4400,$0400,$0000
                DC.W $AC00,$5200,$DE00,$0000
                DC.W $3A00,$4400,$0400,$0000
                DC.W $0600,$0800,$0000,$0000

gfx_end_enemy1: DC.W $0000,$0000,$0000,$0000,$82AE,$7EAE,$0151,$01FF ; Erledigt
                DC.W $0000,$0000,$0000,$0000,$7E20,$FE20,$01DF,$01FF
                DC.W $0000,$0000,$0000,$0000,$71EF,$FFEF,$0010,$01FF
                DC.W $0000,$0000,$0000,$0000,$A808,$A808,$57F7,$FFFF
                DC.W $0000,$0000,$0000,$0000,$AFFB,$AFFB,$5004,$FFFF
                DC.W $0000,$0000,$0000,$0000,$A00A,$A00A,$5FF5,$FFFF
                DC.W $0000,$0000,$0000,$0000,$BFEA,$BFEA,$4015,$FFFF
                DC.W $0000,$0000,$0000,$0000,$A02A,$A02A,$5FD5,$FFFF
                DC.W $0000,$0000,$0000,$0000,$AFAB,$AFAB,$5054,$FFFF
                DC.W $003F,$0000,$0000,$0000,$FFA8,$01A8,$0057,$01FF
                DC.W $0040,$003F,$0000,$0000,$00AF,$FFAF,$0050,$00FF
                DC.W $7EFF,$0180,$0000,$0000,$FFA0,$00A0,$005F,$00FF
                DC.W $4080,$3FFF,$0000,$0000,$00AF,$FFAF,$0050,$00FF
                DC.W $3FBF,$7FFF,$0000,$0000,$FFA8,$FFA8,$0057,$00FF
                DC.W $0000,$007F,$0000,$0000,$00AA,$FFAA,$0055,$00FF
                DC.W $003F,$003F,$0000,$0000,$FEAA,$FEAA,$0155,$01FF
                DC.W $0000,$0000,$0000,$0000,$AAAA,$AAAA,$5555,$FFFF
                DC.W $0000,$0000,$0000,$0000,$AAEA,$AAEA,$5515,$FFFF
                DC.W $0000,$0000,$0000,$0000,$AA0A,$AA0A,$55F5,$FFFF
                DC.W $0000,$0000,$0000,$0000,$ABFB,$ABFB,$5404,$FFFF
                DC.W $0000,$0000,$0000,$0000,$A822,$A822,$57DD,$FFFF
                DC.W $0000,$0000,$0000,$0000,$ABAE,$ABAE,$5451,$FFFF
                DC.W $0000,$0000,$0000,$0000,$83A0,$7FA0,$005F,$01FF
                DC.W $0000,$0000,$0000,$0000,$7FBE,$FFBE,$0041,$01FF
                DC.W $0000,$0000,$0000,$0000,$7182,$FF82,$007D,$01FF
                DC.W $0000,$0000,$0000,$0000,$ABFA,$ABFA,$5405,$FFFF
                DC.W $0000,$0000,$0000,$0000,$A80A,$A80A,$57F5,$FFFF
                DC.W $0000,$0000,$0000,$0000,$AFEA,$AFEA,$5015,$FFFF
                DC.W $0000,$0000,$0000,$0000,$A021,$A01F,$5FC0,$FFC0
                DC.W $0000,$0000,$0000,$0000,$BF9F,$BFBF,$4040,$FFC0
                DC.W $0000,$0000,$0000,$0000,$809F,$80BF,$7F40,$FFC0
                DC.W $0000,$0000,$0000,$0000,$FE9F,$FEBF,$0140,$FFC0
                DC.W $0000,$0000,$0000,$0000,$80B8,$80BF,$7F40,$FFC0
                DC.W $0000,$0000,$0000,$0000,$BFAA,$BFAA,$4055,$FFFF
                DC.W $003F,$0000,$0000,$0000,$FE2A,$002A,$01D5,$01FF
                DC.W $0040,$003F,$0000,$0000,$00EA,$FFEA,$0015,$00FF
                DC.W $7EFF,$0180,$0000,$0000,$FF0A,$000A,$00F5,$00FF
                DC.W $4080,$3FFF,$0000,$0000,$00FB,$FFFB,$0004,$00FF
                DC.W $3FBF,$7FFF,$0000,$0000,$FF00,$FF00,$00FF,$00FF
                DC.W $0000,$007F,$0000,$0000,$00BF,$FFBF,$0040,$00FF
                DC.W $003F,$003F,$0000,$0000,$FFA0,$FFA0,$005F,$01FF
                DC.W $0000,$0000,$0000,$0000,$AFAF,$AFAF,$5050,$FFFF
                DC.W $0000,$0000,$0000,$0000,$A028,$A028,$5FD7,$FFFF
                DC.W $0000,$0000,$0000,$0000,$AFEE,$AFEE,$5011,$FFFF
                DC.W $0000,$0000,$0000,$0000,$A802,$A802,$57FD,$FFFF
                DC.W $0000,$0000,$0000,$0000,$ABFA,$ABFA,$5405,$FFFF
                DC.W $0000,$0000,$0000,$0000,$820A,$7E0A,$01F5,$01FF
                DC.W $0000,$0000,$0000,$0000,$7EEA,$FEEA,$0115,$01FF
                DC.W $0000,$0000,$0000,$0000,$70AA,$FEAA,$0155,$01FF
                DC.W $0000,$0000,$0000,$0000,$AAAA,$AAAA,$5555,$FFFF


                ENDPART
; ************************ FORMATIONEN
                >PART
; 1    = Ende der Tabelle
; 2    = Pause              : Pausen-Wert ( wir mal 16 genommen )
; 3    = Gegner
;                             pointer.l
;                             energie.w
;                             gegner-rout.
;                             Anzahl der SchÅûe, die der Gegner abgeben kann
ende            EQU 1
pause           EQU 2
gegner          EQU 3
end_gegner      EQU 4
; Gegner:                  set_kugel, set_boot, set_pac, set_raum1
;                          set_raum2, set_raum3, set_disk, set_kla
formationen:
                DC.W gegner
                DC.L form1
                DC.W 1
                DC.L set_kugel
                DC.W 1
                DC.W pause,10
                DC.W gegner
                DC.L form1
                DC.W 1
                DC.L set_kugel
                DC.W 1
                DC.W pause,10
                DC.W gegner
                DC.L form1
                DC.W 1
                DC.L set_kugel
                DC.W 1
                DC.W pause,10
                DC.W gegner
                DC.L form1
                DC.W 1
                DC.L set_kugel
                DC.W 1
                DC.W pause,10
                DC.W gegner
                DC.L form1
                DC.W 1
                DC.L set_kugel
                DC.W 1
                DC.W pause,5*50

                DC.W gegner
                DC.L form2
                DC.W 1
                DC.L set_boot
                DC.W 2
                DC.W pause,10
                DC.W gegner
                DC.L form2
                DC.W 1
                DC.L set_boot
                DC.W 2
                DC.W pause,10
                DC.W gegner
                DC.L form2
                DC.W 1
                DC.L set_boot
                DC.W 2
                DC.W pause,10
                DC.W gegner
                DC.L form2
                DC.W 1
                DC.L set_boot
                DC.W 2
                DC.W pause,10
                DC.W gegner
                DC.L form2
                DC.W 1
                DC.L set_boot
                DC.W 2
                DC.W pause,5*50

                DC.W gegner
                DC.L form3
                DC.W 1
                DC.L set_pac
                DC.W 2
                DC.W pause,10
                DC.W gegner
                DC.L form3
                DC.W 1
                DC.L set_pac
                DC.W 2
                DC.W pause,10
                DC.W gegner
                DC.L form3
                DC.W 1
                DC.L set_pac
                DC.W 2
                DC.W pause,10
                DC.W gegner
                DC.L form3
                DC.W 1
                DC.L set_pac
                DC.W 2
                DC.W pause,10
                DC.W gegner
                DC.L form3
                DC.W 1
                DC.L set_pac
                DC.W 2
                DC.W pause,5*60

                DC.W gegner
                DC.L form4
                DC.W 1
                DC.L set_raum1
                DC.W 3
                DC.W pause,10
                DC.W gegner
                DC.L form4
                DC.W 1
                DC.L set_raum1
                DC.W 3
                DC.W pause,10
                DC.W gegner
                DC.L form4
                DC.W 1
                DC.L set_raum1
                DC.W 3
                DC.W pause,10
                DC.W gegner
                DC.L form4
                DC.W 1
                DC.L set_raum1
                DC.W 3
                DC.W pause,10
                DC.W gegner
                DC.L form4
                DC.W 1
                DC.L set_raum1
                DC.W 3
                DC.W pause,5*60

                DC.W gegner
                DC.L form5
                DC.W 2
                DC.L set_raum2
                DC.W 3
                DC.W pause,10
                DC.W gegner
                DC.L form5
                DC.W 2
                DC.L set_raum2
                DC.W 3
                DC.W pause,10
                DC.W gegner
                DC.L form5
                DC.W 2
                DC.L set_raum2
                DC.W 3
                DC.W pause,10
                DC.W gegner
                DC.L form5
                DC.W 2
                DC.L set_raum2
                DC.W 3
                DC.W pause,10
                DC.W gegner
                DC.L form5
                DC.W 2
                DC.L set_raum2
                DC.W 3
                DC.W pause,5*60

                DC.W gegner
                DC.L form6
                DC.W 2
                DC.L set_raum3
                DC.W 3
                DC.W pause,10
                DC.W gegner
                DC.L form6
                DC.W 2
                DC.L set_raum3
                DC.W 3
                DC.W pause,10
                DC.W gegner
                DC.L form6
                DC.W 2
                DC.L set_raum3
                DC.W 3
                DC.W pause,10
                DC.W gegner
                DC.L form6
                DC.W 2
                DC.L set_raum3
                DC.W 3
                DC.W pause,10
                DC.W gegner
                DC.L form6
                DC.W 2
                DC.L set_raum3
                DC.W 3
                DC.W pause,5*60

                DC.W gegner
                DC.L form6
                DC.W 2
                DC.L set_disk
                DC.W 4
                DC.W pause,10
                DC.W gegner
                DC.L form6
                DC.W 2
                DC.L set_disk
                DC.W 4
                DC.W pause,10
                DC.W gegner
                DC.L form6
                DC.W 2
                DC.L set_disk
                DC.W 4
                DC.W pause,10
                DC.W gegner
                DC.L form6
                DC.W 2
                DC.L set_disk
                DC.W 4
                DC.W pause,10
                DC.W gegner
                DC.L form6
                DC.W 2
                DC.L set_disk
                DC.W 4
                DC.W pause,5*60

                DC.W gegner
                DC.L form7
                DC.W 2
                DC.L set_kla
                DC.W 4
                DC.W pause,10
                DC.W gegner
                DC.L form7
                DC.W 2
                DC.L set_kla
                DC.W 4
                DC.W pause,10
                DC.W gegner
                DC.L form7
                DC.W 2
                DC.L set_kla
                DC.W 4
                DC.W pause,10
                DC.W gegner
                DC.L form7
                DC.W 2
                DC.L set_kla
                DC.W 4
                DC.W pause,10
                DC.W gegner
                DC.L form7
                DC.W 2
                DC.L set_kla
                DC.W 4
                DC.W pause,5*60

                DC.W gegner
                DC.L form8
                DC.W 2
                DC.L set_kla
                DC.W 4
                DC.W pause,10
                DC.W gegner
                DC.L form8
                DC.W 2
                DC.L set_disk
                DC.W 4
                DC.W pause,10
                DC.W gegner
                DC.L form8
                DC.W 2
                DC.L set_kugel
                DC.W 4
                DC.W pause,10
                DC.W gegner
                DC.L form8
                DC.W 2
                DC.L set_boot
                DC.W 4
                DC.W pause,10
                DC.W gegner
                DC.L form8
                DC.W 2
                DC.L set_raum1
                DC.W 4
                DC.W pause,5*60

                DC.W gegner
                DC.L form9
                DC.W 2
                DC.L set_raum1
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form9
                DC.W 2
                DC.L set_pac
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form9
                DC.W 2
                DC.L set_disk
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form9
                DC.W 2
                DC.L set_kla
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form9
                DC.W 2
                DC.L set_raum3
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form9
                DC.W 2
                DC.L set_kugel
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form9
                DC.W 2
                DC.L set_raum1
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form9
                DC.W 2
                DC.L set_boot
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form9
                DC.W 2
                DC.L set_disk
                DC.W 6
                DC.W pause,5*60

                DC.W gegner
                DC.L form9
                DC.W 2
                DC.L set_disk
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form9
                DC.W 2
                DC.L set_disk
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form9
                DC.W 2
                DC.L set_disk
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form9
                DC.W 2
                DC.L set_disk
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form9
                DC.W 2
                DC.L set_disk
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form9
                DC.W 2
                DC.L set_disk
                DC.W 6
                DC.W pause,5*60

                DC.W gegner
                DC.L form10
                DC.W 3
                DC.L set_kla
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form10
                DC.W 3
                DC.L set_kla
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form10
                DC.W 3
                DC.L set_kla
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form10
                DC.W 3
                DC.L set_kla
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form10
                DC.W 3
                DC.L set_kla
                DC.W 6
                DC.W pause,5*60

                DC.W gegner
                DC.L form3
                DC.W 1
                DC.L set_disk
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form5
                DC.W 1
                DC.L set_raum2
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form8
                DC.W 1
                DC.L set_kugel
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form10
                DC.W 1
                DC.L set_pac
                DC.W 6
                DC.W pause,10
                DC.W gegner
                DC.L form6
                DC.W 1
                DC.L set_boot
                DC.W 6
                DC.W pause,10

                DC.W pause,5*60

                DC.W gegner
                DC.L form1
                DC.W 2
                DC.L set_disk
                DC.W 8
                DC.W pause,10
                DC.W gegner
                DC.L form6
                DC.W 2
                DC.L set_raum2
                DC.W 8
                DC.W pause,10
                DC.W gegner
                DC.L form2
                DC.W 2
                DC.L set_kugel
                DC.W 8
                DC.W pause,10
                DC.W gegner
                DC.L form10
                DC.W 2
                DC.L set_pac
                DC.W 8
                DC.W pause,10
                DC.W gegner
                DC.L form3
                DC.W 2
                DC.L set_boot
                DC.W 8
                DC.W pause,10

                DC.W pause,5*60

                DC.W gegner
                DC.L form8
                DC.W 3
                DC.L set_disk
                DC.W 10
                DC.W pause,10
                DC.W gegner
                DC.L form3
                DC.W 3
                DC.L set_raum2
                DC.W 10
                DC.W pause,10
                DC.W gegner
                DC.L form9
                DC.W 3
                DC.L set_kugel
                DC.W 10
                DC.W pause,10
                DC.W gegner
                DC.L form4
                DC.W 3
                DC.L set_pac
                DC.W 10
                DC.W pause,10
                DC.W gegner
                DC.L form7
                DC.W 3
                DC.L set_boot
                DC.W 10
                DC.W pause,10

                DC.W end_gegner
                DC.L end_enemy1


                DC.W pause,50

                DC.W 1          ; Ende ; wieder von vorne
form_start:
form1:          DC.W 314,0,312,0,310,0,307,0
                DC.W 305,1,301,1,298,1,295,1,293,2
                DC.W 290,2,288,2,285,2,284,2,282,2
                DC.W 280,2,279,2,277,2,276,2,275,2
                DC.W 273,3,272,3,270,3,269,3,267,4
                DC.W 266,4,264,4,262,5,260,5,259,6
                DC.W 256,6,254,6,252,6,250,7,247,7
                DC.W 245,7,243,8,240,8,238,8,236,9
                DC.W 233,9,231,9,229,9,227,10,225,10
                DC.W 223,11,221,11,220,11,218,12,217,13
                DC.W 215,13,214,14,212,14,211,15,210,16
                DC.W 209,16,208,17,208,18,207,19,207,20
                DC.W 206,20,206,21,206,22,206,23,206,23
                DC.W 206,24,206,25,207,25,207,26,208,27
                DC.W 208,27,209,27,209,27,210,28,211,28
                DC.W 212,28,213,28,214,28,215,28,217,29
                DC.W 218,29,220,29,222,29,223,30,225,30
                DC.W 227,30,229,31,231,31,233,31,235,32
                DC.W 236,32,238,32,239,32,240,32,242,32
                DC.W 243,32,244,32,246,32,247,32,249,33
                DC.W 250,33,251,33,253,33,255,33,256,33
                DC.W 258,33,260,33,261,33,263,33,265,34
                DC.W 266,34,268,34,269,34,271,34,273,34
                DC.W 274,34,276,34,277,34,279,34,281,35
                DC.W 282,35,284,35,285,35,287,35,288,35
                DC.W 290,35,291,35,292,35,293,35,295,36
                DC.W 296,36,296,36,297,36,298,36,299,37
                DC.W 300,37,301,37,302,37,303,37,305,38
                DC.W 306,38,308,38,309,38,311,38,312,38
                DC.W -1,-1
form2:          DC.W 296,0
                DC.W 293,0,291,0,288,0,286,0,284,1
                DC.W 282,1,280,2,278,2,276,3,275,4
                DC.W 273,4,271,5,269,6,266,6,264,7
                DC.W 262,8,260,9,258,9,256,10,254,11
                DC.W 251,11,249,11,247,12,245,12,243,13
                DC.W 241,13,239,13,237,14,235,14,234,15
                DC.W 232,15,231,16,229,16,228,17,227,18
                DC.W 226,19,225,19,224,20,223,21,222,22
                DC.W 220,22,219,23,217,23,216,24,214,25
                DC.W 213,25,211,26,210,26,208,27,207,28
                DC.W 205,28,203,29,202,29,200,30,199,31
                DC.W 197,31,196,32,195,32,193,33,192,34
                DC.W 190,34,188,34,187,35,185,35,184,36
                DC.W 182,36,181,36,179,37,178,37,177,38
                DC.W 175,38,174,38,173,39,171,39,170,39
                DC.W 169,40,167,40,165,40,163,40,162,41
                DC.W 159,41,157,41,154,41,152,40,149,40
                DC.W 147,40,144,40,142,40,140,40,138,40
                DC.W 136,39,134,39,133,39,131,39,130,39
                DC.W 129,39,128,38,127,38,126,38,125,38
                DC.W 123,37,122,37,121,36,119,36,118,35
                DC.W 117,34,115,34,114,33,112,32,111,32
                DC.W 109,31,107,30,106,29,105,29,103,28
                DC.W 102,27,101,27,99,26,98,25,98,25
                DC.W 97,24,96,23,95,22,95,22,95,21
                DC.W 94,20,94,19,94,18,94,17,95,17
                DC.W 95,16,95,15,96,14,96,13,97,12
                DC.W 97,11,98,10,98,9,99,8,100,8
                DC.W 100,7,101,6,101,6,102,6,102,5
                DC.W 103,5,103,5,104,5,105,5,106,5
                DC.W 106,4,107,4,108,4,110,4,111,3
                DC.W 112,3,113,3,114,3,115,3,117,3
                DC.W 118,2,119,2,120,2,121,2,122,2
                DC.W 123,2,124,2,125,2,126,2,127,3
                DC.W 127,3,128,3,129,3,130,4,131,4
                DC.W 132,5,133,5,134,6,134,6,136,7
                DC.W 137,7,138,7,139,8,140,9,141,9
                DC.W 142,10,144,10,145,11,146,12,148,13
                DC.W 149,13,150,14,151,15,153,16,154,17
                DC.W 155,18,156,19,158,20,159,21,161,22
                DC.W 162,22,163,23,165,23,166,24,168,24
                DC.W 169,25,170,25,172,26,173,26,175,27
                DC.W 176,27,177,28,178,28,179,29,181,29
                DC.W 182,30,183,30,184,31,185,31,187,32
                DC.W 188,32,189,32,190,32,192,32,193,32
                DC.W 195,32,196,32,198,32,199,32,201,33
                DC.W 202,33,204,33,205,33,207,33,208,33
                DC.W 210,33,211,34,213,34,214,34,216,35
                DC.W 217,35,218,35,220,35,221,36,222,36
                DC.W 224,36,225,37,226,37,227,37,229,38
                DC.W 230,38,231,38,232,38,233,39,233,39
                DC.W 234,39,235,39,236,39,237,40,239,40
                DC.W 240,39,241,39,242,39,243,39,245,38
                DC.W 246,38,247,38,249,37,250,37,252,37
                DC.W 253,36,254,36,256,35,257,35,258,35
                DC.W 260,35,261,34,262,34,263,34,265,34
                DC.W 266,33,267,33,268,33,269,32,270,32
                DC.W 271,32,273,31,274,31,275,31,277,31
                DC.W 278,30,279,30,281,29,282,29,284,29
                DC.W 286,28,287,28,289,27,290,27,292,27
                DC.W 293,26,294,25,295,25,296,24,298,24
                DC.W 299,23,300,23,301,22,302,21,304,21
                DC.W 305,20,306,19,308,18,309,18,310,17
                DC.W 311,17
                DC.W -1,-1
form3:          DC.W 311,4,309,4
                DC.W 307,3,304,3,302,2,299,2,297,1
                DC.W 294,1,292,1,290,1,288,1,286,1
                DC.W 284,1,282,1,280,1,278,1,276,2
                DC.W 273,2,271,1,268,1,266,1,263,1
                DC.W 261,1,258,1,256,1,254,1,253,2
                DC.W 251,2,250,2,249,2,248,3,247,3
                DC.W 247,4,246,4,245,5,244,5,244,6
                DC.W 242,6,241,6,240,7,238,7,236,8
                DC.W 235,8,233,9,231,9,230,10,229,11
                DC.W 227,11,226,12,225,12,224,13,223,13
                DC.W 222,14,221,15,220,15,219,16,218,17
                DC.W 216,17,215,18,213,18,211,19,210,20
                DC.W 208,20,206,21,205,22,203,23,202,24
                DC.W 200,24,199,25,197,26,196,27,195,28
                DC.W 193,29,192,30,190,31,188,32,187,33
                DC.W 184,33,182,34,180,34,177,35,175,36
                DC.W 172,36,169,36,166,37,163,37,161,38
                DC.W 158,38,155,38,152,38,149,39,146,39
                DC.W 143,39,141,39,138,39,135,39,133,39
                DC.W 130,38,127,38,125,37,123,37,120,36
                DC.W 118,36,116,35,114,35,113,34,112,34
                DC.W 110,33,109,32,109,32,108,31,108,30
                DC.W 107,29,107,29,107,28,107,27,107,26
                DC.W 106,24,106,23,106,21,106,20,107,18
                DC.W 107,17,107,15,107,14,108,13,109,12
                DC.W 109,10,110,9,111,9,112,8,114,7
                DC.W 115,6,116,6,118,5,120,5,122,5
                DC.W 123,4,125,4,127,3,129,3,131,3
                DC.W 133,2,135,2,137,2,139,2,141,2
                DC.W 142,1,144,1,145,1,147,1,148,2
                DC.W 149,2,151,2,152,3,153,3,155,4
                DC.W 156,4,157,5,158,6,159,6,160,7
                DC.W 161,8,162,9,163,10,164,11,165,12
                DC.W 165,12,165,13,165,14,165,15,165,15
                DC.W 165,16,165,17,165,18,164,19,164,20
                DC.W 163,20,162,21,161,22,161,23,160,24
                DC.W 159,25,158,26,157,27,156,28,156,29
                DC.W 155,29,154,30,153,30,152,31,151,31
                DC.W 150,31,149,32,147,32,146,32,145,33
                DC.W 143,33,141,33,139,34,138,34,136,35
                DC.W 134,35,132,35,131,36,129,36,128,37
                DC.W 126,37,125,37,124,37,123,37,122,37
                DC.W 121,37,120,37,118,37,117,38,116,38
                DC.W 114,37,112,37,110,37,108,37,106,37
                DC.W 104,37,102,37,99,37,97,37,96,38
                DC.W 94,38,92,38,91,38,89,38,88,38
                DC.W 86,38,85,38,83,38,82,38,81,39
                DC.W 79,39,77,39,75,39,74,39,72,39
                DC.W 70,39,68,39,66,39,64,39,63,39
                DC.W 61,38,59,38,57,38,56,37,54,37
                DC.W 53,36,52,36,50,35,49,34,48,34
                DC.W 46,33,45,32,44,31,42,30,41,29
                DC.W 40,28,38,27,37,26,35,25,34,25
                DC.W 32,24,30,23,28,23,26,22,23,21
                DC.W 21,21,19,20,17,20,15,19,14,19
                DC.W 12,18,10,17,9,16,8,15,7,15
                DC.W 6,14,5,13,5,13,5,13,5,13
                DC.W -1,-1
form4:          DC.W 1,35,2,35,3,35,5,35,7,35
                DC.W 9,35,11,35,14,35,16,35,19,35
                DC.W 21,34,23,34,25,34,26,34,28,34
                DC.W 29,33,31,33,32,32,33,32,35,32
                DC.W 36,31,37,30,38,30,39,29,40,28
                DC.W 41,28,42,27,43,26,44,25,45,25
                DC.W 45,24,46,23,47,22,48,21,49,20
                DC.W 50,19,51,18,52,17,53,16,55,15
                DC.W 56,13,57,12,58,11,59,10,60,9
                DC.W 61,8,62,8,64,7,65,7,67,7
                DC.W 68,7,70,7,71,7,73,8,74,8
                DC.W 76,9,78,10,79,11,80,12,82,14
                DC.W 83,15,83,16,84,17,85,18,86,19
                DC.W 86,21,87,22,87,23,88,24,89,26
                DC.W 89,27,90,28,91,29,92,30,93,31
                DC.W 94,32,95,33,96,33,97,34,99,35
                DC.W 100,35,101,35,102,36,103,36,105,36
                DC.W 106,36,107,36,109,36,110,36,112,36
                DC.W 113,35,114,35,116,35,117,35,119,34
                DC.W 120,34,122,34,123,34,125,34,127,34
                DC.W 128,33,130,33,131,33,133,33,134,33
                DC.W 136,33,138,34,140,34,141,34,144,34
                DC.W 146,33,148,33,150,33,153,33,155,33
                DC.W 157,33,160,32,162,32,164,32,167,32
                DC.W 169,31,170,31,172,30,174,30,176,30
                DC.W 177,29,179,29,180,28,182,28,184,28
                DC.W 185,27,187,27,188,26,190,26,191,25
                DC.W 193,25,194,24,195,24,196,23,198,23
                DC.W 199,22,199,21,200,20,201,20,201,19
                DC.W 202,18,202,17,202,16,203,15,203,15
                DC.W 202,14,202,13,202,12,201,11,200,10
                DC.W 199,10,198,9,197,8,196,8,195,8
                DC.W 193,7,191,7,190,7,188,7,186,7
                DC.W 184,7,182,7,180,7,178,7,176,7
                DC.W 173,6,171,6,169,6,167,6,165,6
                DC.W 164,6,162,6,160,6,158,6,157,7
                DC.W 155,7,153,7,152,7,150,7,149,8
                DC.W 148,8,146,9,145,9,144,9,143,10
                DC.W 141,10,140,10,139,10,138,11,137,11
                DC.W 135,11,134,11,133,12,132,12,131,13
                DC.W 129,13,128,13,127,14,125,15,124,15
                DC.W 123,16,121,17,120,17,119,18,118,19
                DC.W 116,19,115,20,114,20,113,21,111,21
                DC.W 110,22,108,23,107,23,105,24,104,25
                DC.W 102,25,100,26,98,27,95,27,93,28
                DC.W 91,28,89,29,87,30,85,30,84,31
                DC.W 82,31,81,31,79,31,78,31,77,31
                DC.W 76,31,75,31,73,31,72,31,71,31
                DC.W 69,30,67,30,65,29,63,29,61,28
                DC.W 59,27,57,27,55,26,53,25,52,25
                DC.W 50,24,48,23,47,22,45,21,44,20
                DC.W 42,19,41,19,39,18,38,17,37,17
                DC.W 35,16,33,15,32,15,30,15,28,14
                DC.W 26,14,24,13,22,13,20,12,18,12
                DC.W 15,11,13,10,10,9,8,8,6,8
                DC.W 4,7,2,6,1,6,0,6,0,6
                DC.W -1,-1
form5:          DC.W 313,37,311,36,310,35,309,35
                DC.W 307,34,305,33,304,33,302,32,300,31
                DC.W 298,31,296,30,294,30,292,29,291,29
                DC.W 289,28,286,27,284,27,283,26,281,26
                DC.W 279,25,277,24,275,24,273,23,272,23
                DC.W 270,22,268,21,267,21,266,20,264,19
                DC.W 263,18,262,18,260,17,259,16,258,16
                DC.W 256,15,255,14,253,13,251,13,250,12
                DC.W 248,11,247,10,245,10,244,9,243,9
                DC.W 241,8,240,7,239,7,237,7,236,6
                DC.W 235,6,233,5,232,5,230,5,228,5
                DC.W 225,4,222,4,220,4,217,4,214,3
                DC.W 211,3,208,3,205,3,203,3,201,4
                DC.W 198,4,197,4,195,4,194,5,192,5
                DC.W 191,5,190,6,189,6,188,6,187,7
                DC.W 185,7,184,7,182,7,181,7,179,7
                DC.W 178,8,176,8,175,8,173,8,172,9
                DC.W 170,9,169,9,167,10,166,10,165,11
                DC.W 163,11,162,12,161,13,160,14,159,14
                DC.W 157,15,156,16,155,17,154,19,153,20
                DC.W 152,21,152,22,151,23,151,24,151,25
                DC.W 151,25,151,26,151,27,152,27,152,28
                DC.W 153,28,154,29,155,30,156,30,157,31
                DC.W 157,31,158,32,159,32,160,32,161,33
                DC.W 162,33,163,34,164,34,165,34,166,35
                DC.W 166,35,167,35,167,35,168,35,169,34
                DC.W 169,34,170,34,171,33,172,33,173,33
                DC.W 173,32,175,31,176,31,177,30,178,29
                DC.W 179,28,180,27,182,26,183,25,184,25
                DC.W 184,23,185,22,186,21,186,20,187,20
                DC.W 188,19,188,18,189,17,190,16,191,16
                DC.W 191,15,192,15,194,14,195,14,196,14
                DC.W 198,14,199,14,200,14,202,14,204,15
                DC.W 205,15,207,15,208,16,210,17,211,17
                DC.W 212,18,214,19,215,20,216,21,217,22
                DC.W 217,22,218,23,218,24,218,25,218,26
                DC.W 218,27,218,28,218,29,218,30,218,31
                DC.W 217,31,217,32,217,33,217,34,216,35
                DC.W 216,35,215,36,215,36,214,37,214,38
                DC.W 213,38,212,38,211,39,210,39,208,39
                DC.W 207,39,206,39,205,39,204,39,203,40
                DC.W 201,40,200,40,199,39,198,39,197,39
                DC.W 196,39,195,39,194,39,193,39,192,40
                DC.W 190,40,189,40,188,40,187,40,186,40
                DC.W 185,40,183,40,182,40,181,40,180,41
                DC.W 178,41,177,41,176,41,174,40,173,40
                DC.W 172,40,171,40,170,40,169,40,169,40
                DC.W 168,39,167,39,167,39,167,38,166,38
                DC.W 166,37,165,37,165,36,164,36,164,36
                DC.W 163,35,162,34,160,34,159,33,158,33
                DC.W 156,32,155,32,154,31,153,30,152,30
                DC.W 151,29,150,28,149,27,148,26,147,26
                DC.W 147,25,146,24,145,23,144,22,144,22
                DC.W 143,21,141,20,140,19,139,18,138,18
                DC.W 137,17,135,16,134,15,133,14,132,14
                DC.W 130,13,129,12,128,11,127,10,126,9
                DC.W 125,8,123,7,122,6,121,5,120,5
                DC.W 118,4,116,3,115,3,113,3,111,3
                DC.W 110,2,108,2,106,2,104,2,103,3
                DC.W 101,3,99,3,97,3,96,3,94,4
                DC.W 93,4,91,4,90,5,89,5,88,6
                DC.W 87,6,86,7,85,7,84,8,83,8
                DC.W 83,9,82,10,81,10,80,11,80,12
                DC.W 79,12,77,13,76,13,75,14,74,14
                DC.W 73,15,71,15,70,16,69,16,68,17
                DC.W 66,17,65,17,64,18,63,18,62,18
                DC.W 61,19,60,19,59,20,58,20,57,21
                DC.W 55,21,54,21,53,22,52,22,51,23
                DC.W 50,23,49,24,48,24,47,25,46,26
                DC.W 44,26,43,27,42,27,41,28,40,28
                DC.W 39,29,38,29,37,30,36,30,35,31
                DC.W 33,31,32,31,31,31,30,32,29,32
                DC.W 28,32,27,32,26,32,25,32,24,33
                DC.W 22,33,21,33,20,33,19,33,17,33
                DC.W 16,33,15,34,13,34,12,34,11,35
                DC.W 9,35,7,35,6,36,4,36,3,36
                DC.W 2,37,1,37,0,37,0,37,0,38
                DC.W -1,-1
form6:          DC.W 311,39
                DC.W 309,38,307,38,305,37,303,37,302,37
                DC.W 300,36,298,35,297,35,296,34,294,34
                DC.W 293,33,292,32,290,32,289,31,288,31
                DC.W 286,30,284,29,282,29,280,28,278,27
                DC.W 276,27,274,26,272,26,270,25,269,25
                DC.W 267,24,265,23,264,23,262,22,261,22
                DC.W 259,21,258,21,256,20,254,19,253,19
                DC.W 250,18,248,17,246,16,244,15,241,14
                DC.W 239,13,237,12,234,11,232,10,231,10
                DC.W 229,9,227,8,226,7,224,7,223,6
                DC.W 221,6,219,5,217,5,215,5,213,5
                DC.W 210,4,206,4,203,4,199,4,195,4
                DC.W 191,4,187,4,182,4,178,4,174,5
                DC.W 169,4,165,4,161,4,157,4,153,4
                DC.W 149,4,146,4,142,4,139,4,137,4
                DC.W 134,3,132,3,129,3,127,3,126,3
                DC.W 124,3,122,2,120,2,118,2,117,3
                DC.W 114,3,112,3,110,3,108,3,106,4
                DC.W 104,4,102,4,100,4,98,4,97,5
                DC.W 95,5,94,5,93,4,92,4,90,4
                DC.W 89,4,88,4,86,4,85,4,83,5
                DC.W 80,5,77,5,75,5,71,6,68,6
                DC.W 65,7,62,7,59,8,56,8,54,9
                DC.W 51,9,49,9,47,9,46,10,44,10
                DC.W 43,10,41,11,40,11,39,11,38,12
                DC.W 36,12,35,12,33,13,32,13,31,14
                DC.W 29,15,28,15,27,16,26,17,25,18
                DC.W 23,18,23,19,22,20,21,21,21,21
                DC.W 20,22,20,23,20,24,19,25,20,26
                DC.W 20,26,20,27,21,28,21,29,22,30
                DC.W 23,31,23,31,24,32,25,33,27,34
                DC.W 28,34,29,35,30,35,31,36,33,36
                DC.W 34,36,35,37,37,37,38,37,40,38
                DC.W 41,38,42,38,44,38,45,38,47,38
                DC.W 48,38,50,38,51,38,53,38,55,39
                DC.W 56,39,58,39,60,39,62,39,64,39
                DC.W 66,39,68,39,70,39,72,39,74,39
                DC.W 75,38,77,38,79,38,81,38,83,38
                DC.W 85,38,87,38,89,38,91,38,93,38
                DC.W 94,37,96,38,98,38,100,38,102,38
                DC.W 104,38,107,38,109,38,111,38,113,39
                DC.W 114,39,116,39,118,39,120,39,122,39
                DC.W 124,39,126,39,128,39,130,39,132,40
                DC.W 133,39,135,39,137,39,139,39,141,39
                DC.W 143,39,144,39,146,38,148,38,150,38
                DC.W 151,37,153,37,154,36,156,36,157,35
                DC.W 159,35,160,34,162,33,163,33,165,33
                DC.W 166,32,167,32,168,31,170,31,171,30
                DC.W 172,30,173,29,174,29,175,28,177,28
                DC.W 177,27,178,26,179,25,180,24,181,23
                DC.W 182,22,182,21,183,20,183,19,184,18
                DC.W 184,16,184,15,184,14,184,14,184,13
                DC.W 183,12,183,11,183,11,182,10,182,10
                DC.W 181,9,180,9,179,9,178,9,178,8
                DC.W 177,8,175,8,174,8,173,8,172,8
                DC.W 170,7,168,7,167,6,165,6,163,5
                DC.W 161,4,159,4,157,3,155,3,153,3
                DC.W 150,2,148,2,145,2,143,2,141,2
                DC.W 138,2,136,2,134,2,132,2,130,2
                DC.W 128,3,126,3,124,3,122,4,121,4
                DC.W 119,4,117,4,116,5,114,5,112,5
                DC.W 109,4,107,4,104,4,102,3,99,3
                DC.W 97,3,94,2,92,2,90,2,88,2
                DC.W 86,1,84,1,82,1,81,1,79,2
                DC.W 78,2,76,2,75,2,73,2,72,3
                DC.W 70,3,67,3,65,3,63,3,60,3
                DC.W 58,3,56,3,54,3,51,4,50,4
                DC.W 48,3,46,3,45,3,43,3,42,3
                DC.W 41,3,40,4,38,4,37,4,36,5
                DC.W 34,5,32,6,30,6,29,7,27,8
                DC.W 25,9,23,10,21,10,19,11,18,12
                DC.W 16,12,14,12,13,12,11,12,10,12
                DC.W 9,13,8,13,6,13,5,14,5,14
                DC.W 4,15,3,17,2,18,1,19,1,21
                DC.W 0,22,0,23,0,24,0,24,0,25
                DC.W -1,-1
form7:          DC.W 313,3,312,4,311,4,310,5,310,6
                DC.W 309,6,308,6,307,7,307,7,306,8
                DC.W 306,9,305,9,304,10,304,11,304,12
                DC.W 303,12,303,13,302,14,302,15,301,16
                DC.W 301,18,301,19,300,20,300,21,300,23
                DC.W 299,24,299,25,298,26,298,28,297,29
                DC.W 297,30,296,31,296,32,295,33,295,34
                DC.W 294,34,293,35,292,35,291,35,290,36
                DC.W 289,36,288,36,288,36,287,36,286,37
                DC.W 284,37,283,37,282,37,281,37,280,38
                DC.W 279,38,278,38,277,38,276,38,276,38
                DC.W 275,37,274,37,273,36,272,35,271,34
                DC.W 270,33,269,33,268,32,267,31,267,30
                DC.W 266,28,265,27,264,26,263,25,262,24
                DC.W 261,23,260,22,259,21,258,20,257,19
                DC.W 255,17,254,16,253,14,252,13,251,12
                DC.W 250,10,249,9,248,8,247,6,246,6
                DC.W 244,5,243,4,241,3,240,3,239,3
                DC.W 237,2,236,2,234,2,233,2,232,3
                DC.W 230,3,229,3,228,3,227,4,225,4
                DC.W 224,5,223,6,222,6,221,7,221,8
                DC.W 220,8,219,9,218,10,217,10,217,11
                DC.W 216,12,216,12,215,13,215,14,215,15
                DC.W 214,15,214,16,214,16,213,17,213,18
                DC.W 213,18,213,19,212,20,212,21,212,22
                DC.W 211,22,210,23,210,24,209,25,209,26
                DC.W 208,27,207,28,207,29,206,30,206,31
                DC.W 205,31,204,32,204,32,203,33,203,33
                DC.W 202,33,202,34,201,34,200,34,200,35
                DC.W 199,35,198,35,197,35,195,35,194,35
                DC.W 193,36,191,36,190,36,188,36,187,37
                DC.W 185,37,183,37,181,37,179,38,177,38
                DC.W 175,38,173,38,171,38,169,38,167,38
                DC.W 164,37,162,37,161,36,159,35,157,35
                DC.W 155,34,153,33,151,33,149,32,148,32
                DC.W 146,31,144,31,142,31,140,31,139,31
                DC.W 137,31,136,31,134,31,133,31,132,32
                DC.W 130,32,129,32,128,32,127,32,126,32
                DC.W 125,33,124,33,123,33,122,33,121,34
                DC.W 119,34,118,34,116,34,115,35,113,35
                DC.W 111,35,110,35,108,35,106,35,105,36
                DC.W 103,35,101,35,99,35,98,35,96,35
                DC.W 94,34,93,34,91,33,90,32,89,32
                DC.W 87,31,86,29,85,28,84,27,83,26
                DC.W 82,24,81,23,80,21,79,20,79,19
                DC.W 78,17,77,16,77,14,76,13,76,12
                DC.W 75,11,75,9,75,8,75,7,75,6
                DC.W 75,6,75,5,75,4,76,4,76,3
                DC.W 77,3,78,2,78,2,79,2,81,2
                DC.W 82,1,83,1,84,1,86,1,87,1
                DC.W 89,1,90,1,92,1,93,1,95,2
                DC.W 96,2,97,2,99,3,100,3,102,4
                DC.W 103,4,104,5,106,5,107,6,109,7
                DC.W 110,7,111,7,113,8,114,8,115,9
                DC.W 117,9,118,9,120,10,121,10,123,11
                DC.W 124,11,126,11,127,12,129,12,130,12
                DC.W 132,13,134,13,135,14,137,14,139,15
                DC.W 140,15,142,15,144,16,145,17,147,17
                DC.W 149,18,151,18,153,19,155,20,157,21
                DC.W 158,21,160,22,162,23,164,24,166,24
                DC.W 167,25,169,26,170,26,170,27,171,28
                DC.W 170,28,170,28,169,28,167,29,166,29
                DC.W 164,29,162,29,159,29,157,29,155,29
                DC.W 152,28,149,28,147,28,144,28,141,28
                DC.W 138,27,136,27,133,27,131,27,129,27
                DC.W 126,26,124,26,122,26,120,26,118,25
                DC.W 116,25,114,25,113,24,111,24,109,24
                DC.W 106,23,104,22,102,22,100,21,97,20
                DC.W 95,19,93,18,90,18,88,17,86,17
                DC.W 83,16,81,16,79,15,77,15,74,14
                DC.W 72,14,70,14,68,13,66,13,64,13
                DC.W 61,12,59,11,56,11,54,10,52,9
                DC.W 49,8,47,8,45,7,43,6,41,6
                DC.W 38,5,36,4,35,4,33,4,31,3
                DC.W 29,3,27,3,25,3,23,3,21,3
                DC.W 18,3,16,3,14,3,11,3,9,3
                DC.W 7,3,6,3,5,3,4,3,4,4
                DC.W -1,-1
form8:          DC.W 0,38,0,38,1,38,3,38,4,38
                DC.W 6,37,8,37,9,36,11,36,13,36
                DC.W 14,35,15,34,16,34,17,33,18,33
                DC.W 19,32,20,31,21,31,22,30,24,30
                DC.W 25,29,26,28,28,28,30,27,32,26
                DC.W 34,26,36,25,38,25,40,24,42,24
                DC.W 43,23,45,23,47,22,49,22,51,21
                DC.W 53,21,55,20,57,20,59,19,61,19
                DC.W 62,18,64,17,66,16,69,15,71,14
                DC.W 73,13,75,12,77,11,79,10,81,10
                DC.W 82,9,84,8,86,8,88,8,90,8
                DC.W 92,7,94,7,96,7,97,7,100,7
                DC.W 102,6,104,6,106,5,108,5,110,5
                DC.W 112,4,114,4,117,4,119,4,121,4
                DC.W 122,4,124,4,126,4,127,4,129,4
                DC.W 130,5,131,5,132,6,134,6,135,6
                DC.W 135,7,136,7,137,8,138,8,138,8
                DC.W 139,9,139,9,140,10,140,10,141,11
                DC.W 141,11,141,12,142,12,142,13,143,14
                DC.W 143,14,144,15,145,16,146,17,147,19
                DC.W 147,20,149,21,150,22,151,24,152,25
                DC.W 153,26,155,28,156,29,157,30,159,32
                DC.W 160,33,161,34,162,34,163,35,164,36
                DC.W 165,37,166,37,167,38,168,38,169,39
                DC.W 169,39,170,39,172,39,173,40,174,40
                DC.W 175,40,176,40,178,40,179,40,181,40
                DC.W 182,39,184,39,186,39,187,38,189,38
                DC.W 191,37,192,37,193,36,195,36,196,36
                DC.W 196,35,197,35,197,34,197,34,197,33
                DC.W 197,33,197,32,197,32,197,31,198,31
                DC.W 198,30,198,29,199,29,199,28,200,27
                DC.W 201,26,201,26,202,25,202,24,203,23
                DC.W 203,21,203,20,203,19,203,17,203,16
                DC.W 203,15,203,14,204,12,204,11,206,11
                DC.W 207,10,209,9,211,9,213,8,215,8
                DC.W 218,7,220,7,222,7,224,7,227,7
                DC.W 228,6,230,6,231,6,233,5,234,5
                DC.W 235,5,236,4,238,4,239,4,241,4
                DC.W 242,3,244,3,246,3,248,3,250,3
                DC.W 252,3,255,3,257,3,259,3,261,4
                DC.W 262,4,264,4,265,4,267,5,268,5
                DC.W 270,5,271,6,272,6,273,7,275,8
                DC.W 276,8,277,9,278,10,280,11,281,11
                DC.W 282,12,284,13,285,14,286,15,288,16
                DC.W 289,16,290,17,291,18,292,18,293,19
                DC.W 294,20,296,20,297,21,298,22,299,23
                DC.W 299,23,300,24,301,25,302,26,303,26
                DC.W 303,27,304,28,304,29,304,30,305,31
                DC.W 305,31,305,32,304,33,304,34,304,34
                DC.W 303,35,303,36,303,36,302,37,302,38
                DC.W 301,38,300,39,300,39,299,39,299,40
                DC.W 298,40,297,40,296,40,295,40,294,41
                DC.W 292,40,291,40,289,40,287,40,286,40
                DC.W 284,39,282,39,281,38,280,37,279,37
                DC.W 278,36,277,35,276,34,276,33,276,32
                DC.W 275,31,275,30,275,28,275,27,276,27
                DC.W 276,26,276,25,276,24,276,23,276,22
                DC.W 276,22,276,21,276,20,276,19,276,19
                DC.W 275,18,275,17,275,16,275,15,275,14
                DC.W 275,13,275,12,276,11,276,10,277,10
                DC.W 277,9,278,8,279,7,280,6,281,5
                DC.W 282,5,284,4,285,3,286,3,287,2
                DC.W 287,2,288,2,289,2,289,1,290,1
                DC.W 290,1,291,1,292,1,292,1,294,1
                DC.W 295,0,296,0,298,0,299,0,301,0
                DC.W 302,0,304,0,305,1,306,1,308,2
                DC.W 308,2,309,3,309,4,310,5,310,6
                DC.W 310,7,309,8,309,9,308,10,308,11
                DC.W 307,11,306,12,304,12,303,13,302,13
                DC.W 300,14,299,14,297,15,295,15,294,16
                DC.W 292,16,290,16,288,17,286,17,284,18
                DC.W 282,18,281,19,279,20,277,20,276,21
                DC.W 274,21,273,21,271,22,270,22,269,23
                DC.W 267,23,266,24,265,24,264,25,263,26
                DC.W 261,26,260,27,258,28,257,29,255,29
                DC.W 254,30,253,31,251,32,250,33,249,34
                DC.W 247,34,246,35,245,35,244,36,242,36
                DC.W 241,37,240,37,239,37,238,37,237,38
                DC.W 235,38,234,38,233,38,231,38,230,38
                DC.W 228,38,227,38,225,38,224,38,223,38
                DC.W 221,37,220,37,218,37,217,37,215,37
                DC.W 214,37,212,36,211,36,209,35,208,35
                DC.W 206,34,204,33,203,32,201,31,200,30
                DC.W 198,28,197,27,196,26,195,25,194,25
                DC.W 193,24,192,23,191,23,190,22,189,22
                DC.W 189,21,188,21,188,20,187,20,187,20
                DC.W 186,19,185,18,184,18,184,17,183,16
                DC.W 182,15,181,14,180,13,179,12,179,12
                DC.W 177,11,176,10,175,9,174,8,173,7
                DC.W 172,6,170,6,169,5,168,5,167,5
                DC.W 165,4,164,5,162,5,161,5,159,6
                DC.W 158,6,156,7,155,7,153,8,152,9
                DC.W 150,9,148,10,147,10,145,10,144,11
                DC.W 142,11,141,11,139,12,138,12,137,13
                DC.W 135,13,134,13,133,14,132,14,131,14
                DC.W 130,15,129,15,128,16,127,17,126,18
                DC.W 124,18,123,19,121,20,120,21,118,22
                DC.W 117,23,115,25,114,26,112,27,111,28
                DC.W 109,28,108,29,106,30,105,31,104,31
                DC.W 103,32,102,32,101,33,100,33,99,34
                DC.W 97,34,96,34,96,35,95,35,94,35
                DC.W 93,35,92,36,91,36,90,36,89,37
                DC.W 87,37,86,37,85,37,84,38,83,38
                DC.W 82,38,81,38,80,38,79,38,78,39
                DC.W 76,39,76,39,75,38,74,38,73,38
                DC.W 72,38,71,37,70,37,69,36,69,36
                DC.W 68,35,67,34,66,33,65,31,64,30
                DC.W 63,29,63,28,62,27,61,26,61,26
                DC.W 60,25,59,24,59,24,58,24,58,23
                DC.W 57,23,57,23,56,22,56,22,56,22
                DC.W 55,21,55,20,54,19,54,19,53,18
                DC.W 53,17,52,16,51,15,51,14,50,14
                DC.W 48,13,47,12,45,11,44,11,42,10
                DC.W 40,10,39,9,37,9,35,8,34,8
                DC.W 32,7,30,6,29,6,27,5,26,5
                DC.W 25,4,23,4,22,3,21,3,20,3
                DC.W 18,2,17,2,16,2,15,2,13,2
                DC.W 12,3,11,3,10,3,9,3,8,4
                DC.W 6,4,5,4,4,4,3,5,2,5
                DC.W 1,5,0,5,0,5,0,5,0,6
                DC.W -1,-1
form9:          DC.W 0,4,1,4,2,4,4,4,6,4
                DC.W 8,4,10,4,12,4,14,4,17,5
                DC.W 18,5,20,5,22,5,23,6,24,6
                DC.W 25,6,27,7,28,7,29,7,30,8
                DC.W 32,8,34,8,35,8,37,9,39,9
                DC.W 40,9,42,10,44,10,46,10,48,11
                DC.W 49,11,51,11,52,11,54,12,55,12
                DC.W 57,12,58,13,60,13,62,13,64,14
                DC.W 65,14,67,14,69,14,71,15,74,15
                DC.W 76,15,78,16,80,16,82,16,85,17
                DC.W 87,17,89,17,91,17,93,18,95,18
                DC.W 97,19,100,19,102,20,104,20,107,21
                DC.W 109,21,111,22,114,22,116,23,119,23
                DC.W 122,24,124,25,127,25,129,26,132,27
                DC.W 134,27,136,28,138,28,141,29,143,29
                DC.W 145,29,147,30,149,30,151,30,154,31
                DC.W 156,31,158,31,160,31,162,31,164,31
                DC.W 167,31,169,31,171,31,174,31,177,31
                DC.W 179,30,182,30,184,30,187,29,190,29
                DC.W 192,29,194,28,196,28,198,27,200,27
                DC.W 201,26,202,25,202,25,203,24,203,23
                DC.W 203,23,203,22,203,21,203,20,203,20
                DC.W 202,19,202,18,202,17,202,16,202,16
                DC.W 202,15,202,14,202,14,202,13,202,13
                DC.W 201,12,200,11,200,11,199,11,198,10
                DC.W 198,10,197,10,196,10,195,10,195,10
                DC.W 194,10,193,10,193,10,192,10,192,10
                DC.W 192,11,191,11,191,12,191,12,191,13
                DC.W 190,13,190,14,190,14,190,15,190,15
                DC.W 190,16,190,16,190,17,190,17,191,18
                DC.W 191,18,191,18,191,18,192,19,192,19
                DC.W 193,19,194,19,195,19,195,19,197,19
                DC.W 198,18,199,18,200,17,201,17,201,17
                DC.W 202,16,202,16,201,15,200,15,199,15
                DC.W 196,14,193,14,189,14,185,14,180,14
                DC.W 175,14,169,14,163,14,158,14,152,14
                DC.W 145,13,139,13,133,13,127,13,121,13
                DC.W 115,13,109,13,103,13,97,13,90,14
                DC.W 85,14,79,14,73,14,68,14,63,14
                DC.W 58,14,53,14,50,15,46,15,44,16
                DC.W 41,16,40,17,39,17,38,18,38,19
                DC.W 38,20,39,21,39,21,39,22,40,23
                DC.W 40,23,40,23,40,24,39,24,39,24
                DC.W 39,24,38,25,38,25,37,25,37,26
                DC.W 36,26,35,26,34,27,34,27,33,28
                DC.W 32,28,31,28,30,29,29,29,29,30
                DC.W 28,30,27,30,26,30,25,30,24,30
                DC.W 23,31,22,31,21,31,20,31,20,32
                DC.W 19,32,18,32,17,33,16,33,15,34
                DC.W 14,34,13,35,12,35,11,35,10,36
                DC.W 8,36,7,36,5,36,4,36,3,36
                DC.W 2,36,1,36,0,36,0,36,0,36
                DC.W -1,-1
form10:         DC.W 0,2,2,2,5,3,9,3,14,4
                DC.W 19,5,25,6,30,7,35,8,40,10
                DC.W 43,10,47,11,50,12,52,13,54,14
                DC.W 56,15,58,16,60,16,62,17,64,19
                DC.W 66,20,68,21,70,22,73,24,76,25
                DC.W 79,26,82,27,85,29,89,30,93,31
                DC.W 96,31,100,32,104,32,108,32,112,33
                DC.W 116,33,121,33,125,33,129,33,134,34
                DC.W 138,34,142,34,146,34,150,35,154,35
                DC.W 158,35,162,35,165,35,169,34,172,34
                DC.W 174,32,177,31,179,30,181,28,183,26
                DC.W 185,24,187,22,189,20,191,18,193,17
                DC.W 195,15,197,13,199,12,202,11,204,9
                DC.W 207,8,211,7,214,7,218,6,223,6
                DC.W 227,5,232,5,237,5,242,4,247,5
                DC.W 253,5,257,5,262,5,266,6,270,7
                DC.W 272,7,275,8,277,9,278,10,279,11
                DC.W 280,12,280,13,281,14,281,15,281,17
                DC.W 280,17,280,18,280,19,279,20,279,21
                DC.W 278,22,278,22,278,23,277,23,277,24
                DC.W 276,24,275,24,275,24,274,24,274,24
                DC.W 273,25,272,25,272,25,271,25,270,25
                DC.W 268,24,267,24,266,24,264,24,263,24
                DC.W 262,24,260,24,259,24,258,24,258,24
                DC.W 257,23,257,23,256,23,256,22,256,22
                DC.W 256,21,257,21,257,20,257,20,258,20
                DC.W 258,19,258,19,258,18,259,18,259,18
                DC.W 260,17,260,17,260,17,261,17,262,17
                DC.W 262,16,263,16,264,16,264,16,265,16
                DC.W 266,16,267,16,267,16,268,16,269,16
                DC.W 269,15,269,15,270,15,270,16,270,16
                DC.W 270,16,270,16,270,16,271,16,271,17
                DC.W 270,17,270,17,270,18,270,18,270,19
                DC.W 270,19,270,19,270,20,270,20,270,21
                DC.W 269,21,269,21,269,21,269,21,269,21
                DC.W 268,21,268,21,268,21,267,21,267,22
                DC.W 266,22,265,22,264,22,264,22,263,22
                DC.W 262,22,261,22,261,22,260,22,260,22
                DC.W 259,21,259,21,258,20,258,20,258,19
                DC.W 258,19,258,18,258,18,258,17,259,17
                DC.W 259,16,259,15,259,15,259,15,259,14
                DC.W 260,14,260,13,261,13,261,13,262,13
                DC.W 262,12,263,12,263,12,264,11,265,11
                DC.W 266,11,266,11,267,11,268,11,269,11
                DC.W 269,10,270,10,270,10,271,11,271,11
                DC.W 272,11,272,11,273,12,274,12,275,13
                DC.W 275,13,276,14,278,15,279,15,280,16
                DC.W 281,17,282,18,283,18,284,19,285,20
                DC.W 285,20,286,20,286,20,286,21,286,21
                DC.W 286,21,285,21,285,21,284,21,283,22
                DC.W 281,22,280,22,278,22,276,23,274,23
                DC.W 272,23,270,24,269,24,267,24,266,24
                DC.W 264,23,263,23,262,22,261,21,261,21
                DC.W 260,20,259,20,258,19,258,19,257,19
                DC.W 255,20,254,21,253,22,251,23,249,24
                DC.W 248,25,246,26,244,27,242,29,241,30
                DC.W 239,30,237,31,235,31,233,32,231,32
                DC.W 228,32,226,32,223,32,220,32,217,33
                DC.W 213,33,209,33,204,33,200,33,195,33
                DC.W 190,33,186,33,181,33,177,33,174,33
                DC.W 170,32,167,31,164,30,161,29,159,28
                DC.W 156,26,154,25,151,23,148,22,146,21
                DC.W 142,19,139,18,135,16,132,15,128,14
                DC.W 124,14,120,13,117,12,113,12,110,13
                DC.W 106,13,103,14,100,15,97,16,94,17
                DC.W 91,18,88,20,85,21,82,22,80,24
                DC.W 77,25,74,26,71,26,68,27,65,28
                DC.W 62,28,59,29,56,30,54,30,52,31
                DC.W 49,31,47,31,45,32,43,32,41,33
                DC.W 38,33,36,34,33,34,31,34,28,35
                DC.W 24,35,20,35,17,35,13,35,9,35
                DC.W 6,35,3,35,1,35,0,35,0,35
                DC.W -1,-1
form_ende:
                ENDPART

                >PART 'Shift Sprite'
shift_blase:    lea     blasenshifts,A0
                moveq   #16-1,D0        ; erstmal Blase so kopieren mit Platz
sh_copy1:       lea     blase(PC),A1    ; zum shiften
                moveq   #16-1,D1
sh_copy2:       move.l  (A1)+,(A0)+     ; Grafik kopieren       1 & 2 Plane
                move.l  (A1)+,(A0)+     ; Leerworte kopieren
                dbra    D1,sh_copy2
                dbra    D0,sh_copy1

                lea     blasenshifts,A0
                moveq   #0,D0           ; gleich mit 1 Shift anfangen
                moveq   #16-1,D2        ; SpritezÑhler
shift_loop:     moveq   #16-1,D3        ; ZielenzÑhler
shift_loop2:    moveq   #0,D1
                move.w  (A0),D1
                lsl.l   D0,D1
                move.w  D1,4(A0)
                swap    D1
                move.w  D1,(A0)

                moveq   #0,D1
                move.w  2(A0),D1
                lsl.l   D0,D1
                move.w  D1,6(A0)
                swap    D1
                move.w  D1,2(A0)

                lea     8(A0),A0        ; 1 Zeile weiter
                dbra    D3,shift_loop2
                addq.w  #1,D0
                dbra    D2,shift_loop
                rts
                ENDPART
charset:        IBYTES 'CHARSET.WAN'
                >PART 'Grafiken & Musix'
questie_pal:    DC.W $0000,$0203,$0313,$0423,$0533,$0653,$0673,$0664
                DC.W $0454,$0244,$0035,$0025,$0015,$0004,$0643,$0644
unten_pal:      DC.W $0000,$0200,$0320,$0430,$0543,$0654,$0643,$0600
                DC.W $0730,$0750,$0500,$0400,$0740,$0720,$0300,$0777
questie:        IBYTES 'QUESTIE.IMG'
inter:          IBYTES 'INTER.IMG'
blase:          IBYTES 'BLASE.IMG'
musix:          IBYTES '*.THK'
                ENDPART
                >PART 'Blasenbewegung&Variablen'
                EVEN
blasen_koo:     IBYTES 'WAVE.DAT'
ende_koo:
blasen_1:       DC.L blasen_koo
blasen_2:       DC.L blasen_koo+4*50
blasen_1_1:     DC.L blasen_koo+4*190
blasen_2_1:     DC.L blasen_koo+4*130
                ENDPART
                >PART 'BSS'
                BSS
_vblz:          DS.L 1
joydata:        DS.W 1
ende_flag:      DS.W 1
                DS.L 10
game_flag:      DS.W 1
                DS.L 10
anzahl_stars:   DS.W 1
star_tab:       DS.W anz_stars*3
clearbuf1:      DS.L anz_stars+1
clearbuf2:      DS.L anz_stars+1
init_tab:       DS.W 32768
init_tab2:      DS.W 32768
oldscreen:      DS.W 1
screen1:        DS.L 1
screen2:        DS.L 1
char_struktur:  DS.B laenge*33
res_adr:        DS.L 32
res_adr2:       DS.L 32
charset0:       DS.B 1280
charset1:       DS.B 1280
charset2:       DS.B 1280
charset3:       DS.B 1280
charset4:       DS.B 1280
charset5:       DS.B 1280
charset6:       DS.B 1280
charset7:       DS.B 1280
charset8:       DS.B 1280
charset9:       DS.B 1280*2
charset10:      DS.B 1280*2
charset11:      DS.B 1280*2
charset12:      DS.B 1280*2
charset13:      DS.B 1280*2
charset14:      DS.B 1280*2
charset15:      DS.B 1280*2
leer:           DS.B 160*10
blasenshifts:   DS.B 8*16*16

                DS.B 100
screen:         DS.L 1
schuû_flag:     DS.W 1
energie:        DS.L 1
player_x:       DS.W 1
player_y:       DS.W 1
kol_player_flag:DS.W 1
form_pointer:   DS.L 1
form_pause:     DS.L 1
vbl_rout:       DS.L 1
end_enemy_rout: DS.L 1
signal_flag:    DS.W 1
schuû_player:   DS.B max_schuû_player*ins_schuû_player
schuû_enemy:    DS.B max_schuû_enemy*ins_schuû_enemy
enemy:          DS.B max_enemy*ins_enemy
                DS.B 100        ; Sicherheitsbuffer
e_enemy:        DS.B max_e_enemy*ins_e_enemy
                DS.B 100        ; Sicherheitsbuffer
gfx_player_shift:DS.B 10*2*6*16 ; Platz fÅr geshiftete Grafik...
gfx_kugel_shift1:DS.B 10*8*8
gfx_kugel_shift2:DS.B 16*8*8
gfx_boot_shift1:DS.B 8*7*8
gfx_boot_shift2:DS.B 16*7*8
gfx_plsh_shift1:DS.B 10*3*8
gfx_plsh_shift2:DS.B 16*3*8
gfx_pac_shift1: DS.B 10*8*8
gfx_pac_shift2: DS.B 16*8*8
gfx_raum1_shift1:DS.B 10*6*8
gfx_raum1_shift2:DS.B 16*6*8
gfx_raum2_shift1:DS.B 10*5*8
gfx_raum2_shift2:DS.B 16*5*8
gfx_raum3_shift1:DS.B 10*5*8
gfx_raum3_shift2:DS.B 16*5*8
gfx_disk_shift1:DS.B 12*8*8
gfx_disk_shift2:DS.B 16*8*8
gfx_kla_shift1: DS.B 10*7*8
gfx_kla_shift2: DS.B 16*7*8

                DS.B 256
screen_base:    DS.B 32000
                DS.B 25700
                DS.B 32256
                DS.B 25700
                ENDPART
                END
