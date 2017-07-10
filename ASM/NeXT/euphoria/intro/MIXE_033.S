offset_ste=-3
;
;
;          Ecran de s‚lection pour ®Euphoria¯
;
;          Ainsi, que les meilleurs scores...
;
;             (c) 1991 Dbug II from NEXT
;

pause macro
 dcb.w \1,$4e71
 endm

scroll_bloc_1 macro             ; transfere 56 octets a la fois en 118 nops
 movem.l (a0)+,d0-d7/a2-a7      ; 12+(8+6)*8 = 12+112 = 124 = 31 nops
 movem.l d0-d7/a2-a7,-4-56(a0)  : 12+(8+6)*8 = 12+112 = 124 = 31 nops
 move.l d0,var(a1)              ; (8+6)*16 = 224 = 56 nops
var set var+8
 move.l d1,var(a1)
var set var+8
 move.l d2,var(a1)
var set var+8
 move.l d3,var(a1)
var set var+8
 move.l d4,var(a1)
var set var+8
 move.l d5,var(a1)
var set var+8
 move.l d6,var(a1)
var set var+8
 move.l d7,var(a1)
var set var+8
 move.l a2,var(a1)
var set var+8
 move.l a3,var(a1)
var set var+8
 move.l a4,var(a1)
var set var+8
 move.l a5,var(a1)
var set var+8
 move.l a6,var(a1)  ; 16/4 nops
var set var+8
 move.l a7,var(a1)  ; 16/4
var set var+8
 endm

 opt o+,w-

offset_ecran = 8 
nop      = $4e71
attente  = 20*50
n        = 22
y_tetes  = 87
y_message= 100
y_joueurs= 140
y_control= 160+6
y_infos  = 185+5
y_scroll = 230+12-3-3

 jmp efface_bss
retourne_la_ou_il_le_faut_sale_con

 pea programme_principal
 move.w #$26,-(sp)
 trap #14
 addq #6,sp

 clr.w -(sp)
 trap #1



 
programme_principal
 move.w #$2700,sr
 move.l usp,a0
 move.l a0,sauve_usp
 move.l sp,sauve_sp
 lea ma_pile,sp
 movem.l $ffff8240.w,d0-d7
 movem.l d0-d7,sauve_palette

 clr.l $ffff8240.w
 
 move.l #ecrans,d0
 sf d0
 add.l #256,d0
 move.l d0,ecran
 lsr.l #8,d0
 lea $ffff8201.w,a0
 move.b (a0),sauve_8201
 move.b 2(a0),sauve_8203
 movep.w d0,0(a0)

 move.l ecran,joueur_1_ecran
 move.l ecran,joueur_2_ecran
 move.l #on_saute,joueur_1_ptr
 move.l #on_saute,joueur_2_ptr
 move.w #0,joueur_1            ;  0/Joueur actif
 move.w #1,joueur_flag_1       ;  1/rebondir
 move.w #1,joueur_2            ;  1/Joueur inactif
 move.w #-1,joueur_flag_2      ; -1/immobile
 move.l #32+sprites+1248*0,sprite_1
 move.l #32+sprites+1248*9,sprite_2
 move.w #0,joueur_stade_1
 move.w #4,joueur_stade_2

 move.l #superbe_degrade,raster_ptr_1        ; Les Player Rasters...
 move.l #superbe_degrade+12,raster_ptr_2     ; Les Player Rasters...

 move.l #ligne_couleur,ligne_ptr_1
 move.l #ligne_couleur+32,ligne_ptr_2
 
 move.l #fonte_16,lettre_lue
 move.l #texte_1,pos_scroll
 move.w #3,cpt_scroll
 move.l #position_1,pos_1
 move.l #position_2,pos_2
 move.l #position_3,pos_3
 move.l #position_4,pos_4
 
 move.l #distort,pos_distort
 move.l #zbong,pos_zbong
 lea zbong,a0
 move.l ecran,a1
 add.l (a0),a1
 move.l a1,old_zbong

;
; L…, on s'occupe des initialisations des mode de controle.
;
initialise_controllers
 move.l #manettes,acontroler_1
 move.l #manettes+72,acontroler_2
 move.l #0,controler_1
 move.l #1,controler_2
 lea raster_1,a0
 move.l controler_1,d0
 mulu #18,d0
 lea 0(a0,d0.w),a1
 move.l controler_2,d0
 mulu #18,d0
 lea 0(a0,d0.w),a2
 lea rasters_change,a0
 moveq #8,d0
.change_rasters
 move.w (a1)+,(a0)+
 move.w (a2)+,(a0)+
 dbra d0,.change_rasters
    
 move.l #table_offset_y,fonds_y_ptr

 clr.w flag_sortie
 clr.w flag_exit
 
 jsr convertion_table

 jsr init_read_note
 jsr predecalle_logo 
 jsr prepare_ecran_1
 jsr prepare_joysticks 
 
 move.w #$2700,sr
 move.b #8,$ffff8800.w
 move.b #0,$ffff8802.w
 move.b #9,$ffff8800.w
 move.b #0,$ffff8802.w
 move.b #10,$ffff8800.w
 move.b #0,$ffff8802.w

 move.b $ffff8260.w,sauve_rez
 move.b $fffffa07.w,sauve_iera
 move.b $fffffa09.w,sauve_ierb
 move.b $fffffa0f.w,sauve_isra
 move.b $fffffa11.w,sauve_isrb
 move.b $fffffa13.w,sauve_imra
 move.b $fffffa15.w,sauve_imrb
 move.b $fffffa17.w,sauve_vr
 move.b $fffffa19.w,sauve_tacr
 move.b $fffffa1f.w,sauve_tadr
 clr.b $fffffa13.w
 clr.b $fffffa15.w
 clr.b $ffff8260.w
 move.b #2,$ffff820a.w
 move.l $70.w,sauve_70
 move.l #routine_vbl_1,$70.w
 move.l $134.w,sauve_134
 move.l #routine_timer_a,$134.w
 move.w #$2300,sr
 
boucle_attente_1
 tst.w flag_sortie
 bne sort_boucle
 tst.w flag_exit
 beq boucle_attente_1

 jsr prepare_ecran_2
 moveq #30,d0
.attend_entre 
 stop #$2300
 dbra d0,.attend_entre
 move.l #routine_vbl_2,$70.w
boucle_attente_2
 tst.w flag_sortie
 bne sort_boucle
 tst.w flag_exit
 beq boucle_attente_2

 move.l #ecrans,d0
 sf d0
 add.l #256,d0
 move.l d0,ecran
 lsr.l #8,d0
 lea $ffff8201.w,a0
 movep.w d0,0(a0)
 jsr prepare_ecran_1
 moveq #40,d0
.attend_entre 
 stop #$2300
 dbra d0,.attend_entre
 move.l #routine_vbl_1,$70.w
 bra boucle_attente_1
  
sort_boucle

restore_ecran
 move.w #$2700,sr
 move.l #vbl_choc,$70.w
 move.w #$2300,sr
 stop #$2300
 move.b sauve_rez,$ffff8260.w
 lea $ffff8201.w,a0
 move.b sauve_8201,(a0)
 move.b sauve_8203,2(a0)
 movem.l sauve_palette,d0-d7
 movem.l d0-d7,$ffff8240.w
 move.b #2,$ffff820a.w
 stop #$2300
 stop #$2300
 move.b #0,$ffff820a.w
 stop #$2300
 stop #$2300
 move.b #2,$ffff820a.w
 
 move.l sauve_70,$70.w
 move.l sauve_134,$134.w
 move.b sauve_iera,$fffffa07.w
 move.b sauve_ierb,$fffffa09.w
 move.b sauve_isra,$fffffa0f.w
 move.b sauve_isrb,$fffffa11.w
 move.b sauve_imra,$fffffa13.w
 move.b sauve_imrb,$fffffa15.w
 move.b sauve_vr,$fffffa17.w
 move.b sauve_tacr,$fffffa19.w
 move.b sauve_tadr,$fffffa1f.w
 move.b sauve_rez,$ffff8260.w
 move.w #$2300,sr
 jsr coupe_son
 jsr stoppe_joysticks 

 move.w #$2700,sr
 move.l sauve_sp,sp
 move.l sauve_usp,a0
 move.l a0,usp
 move.w #$2300,sr
 rts 

vbl_choc
 rte
 
coupe_son
 lea $ffff8800.w,a0
 move.l #$07ff0800,d0
 movep.l d0,(a0)
 move.l #$09000a00,d0
 movep.l d0,(a0)
 rts

routine_timer_a
 rte

vbl_jonction
 movem.l d0-a6,-(sp)
 movem.l palette_noire,d0-d7
 clr.w flag_exit
 movem.l d0-d7,$ffff8240.w
 jsr music
 move.b #9,$ffff8800.w
 movem.l (sp)+,d0-a6
 rte

routine_timer_digidrum 
 move.l a0,-(sp)
 move.l usp,a0
 move.b (a0)+,$ffff8802.w
 move.l a0,usp
 move.l (sp)+,a0
 rte
  
****************************************
*                                      *
* Ici se trouve la programme principal *
*                                      *
****************************************

 opt o-

fonds_clair
 move.l fondu_2_ptr,a0
 movem.l (a0)+,d0-d7
 movem.l d0-d7,sprites
 move.l a0,fondu_2_ptr
 move.l fondu_1_ptr,a0
 movem.l (a0)+,d0-d7
 movem.l d0-d7,palette
 move.l a0,fondu_1_ptr
 cmp.l #fondu_1+32*16,a0
 bmi .pas_fini_fondu
 sub.l #32,fondu_1_ptr
 sub.l #32,fondu_2_ptr
 move.l #fonds_stable,_auto_fondu+2
.pas_fini_fondu 
 rte

fonds_stable
 rte

fonds_sombre
 move.l fondu_2_ptr,a0
 movem.l (a0),d0-d7
 movem.l d0-d7,sprites
 sub.l #32,a0
 move.l a0,fondu_2_ptr
 move.l fondu_1_ptr,a0
 movem.l (a0),d0-d7
 movem.l d0-d7,palette
 sub.l #32,a0
 move.l a0,fondu_1_ptr
 cmp.l #fondu_1,a0
 bpl .pas_fini_fondu
 move.l #fonds_stable,_auto_fondu+2
 move.w #1,flag_exit
 move.l #vbl_jonction,$70.w
 move.b #%00100000,$fffffa07.w
 move.b #%00100000,$fffffa13.w
 clr.b $fffffa09.w
 clr.b $fffffa15.w
 bclr #3,$fffffa17.w
 clr.b $fffffa19.w
 move.l #routine_timer_digidrum,$134.w
 move.b #$64,$fffffa1f.w
 move.b #1,$fffffa19.w
.pas_fini_fondu 
 rte
   
routine_vbl
 move.w #$2700,sr
 move.l a7,sauve_a7    ; 20

 move usp,a6
 move.b (a6)+,$ffff8802.w  ; 6
 move a6,usp
;
;  L…, je scrolle le texte en bas de l'‚cran
;
;  ATTENTION !!! 
;  ---------------> Affichage et scrolling simultan‚... 
;
 move.l pos_1,a0                ; 20
 move.l ecran,a1                ; 20
 adda.l #-offset_ecran+160+230*y_scroll-70,a1    ; 6+2 (!) 
var set 0
flag set 2
 rept 16
 scroll_bloc_1         ; 472 = 118 nops
 scroll_bloc_1         ; 472 = 118 nops
 move.l (a0)+,-8(a0)   ; 24  = 6 nops  ==> 242 nops
var set var+6
flag set flag-1 
 ifeq flag
flag set 2
 move usp,a6
 move.b (a6)+,$ffff8802.w  ; 6
 move a6,usp
 endc
 endr                  ; 242x16 ==> 3872 nops+5+5+2 = 3884 nops


;
;
; On affiche le mode de controle du joueur 1
;
;
 move.l acontroler_1,a0     ; 20
 move.l ecran,a1	            ; 20
 add.l #-offset_ecran+160+24+4+230*y_control,a1  ; 12
var set 0
 rept 9
 move.w (a0)+,var(a1)       ; 16
 move.w (a0)+,var+8(a1)     ; 16
 move.w (a0)+,var+16(a1)    ; 16
 move.w (a0)+,var+24(a1)    ; 16 -> 16x4 = 64x9 = 576
var set var+230             ; 576+20+20+12= 636 / 157 nops
 endr





;
;
; On affiche le mode de controle du joueur 2
;
;
 move.l acontroler_2,a0      ; 20
 move.l ecran,a1	            ; 20
 add.l #-offset_ecran+160+160+4+230*y_control,a1 ; 12
var set 0
 rept 9
 move.w (a0)+,var(a1)       ; 16
 move.w (a0)+,var+8(a1)     ; 16
 move.w (a0)+,var+16(a1)    ; 16
 move.w (a0)+,var+24(a1)    ; 16 -> 16x4 = 64x9 = 576
var set var+230             ; 576+20+20+8= 636 / 157 nops
 endr
 
 lea $ffff8260.w,a0    ; 8 resolution 
 lea $ffff820a.w,a1    ; 8 frequence
 lea $ffff8240.w,a2    ; 8 palette

 moveq #0,d0           ; 4        

 pause 404-157-157-4-2-(8*7)-7-7 ; -> 4283   (reste 92)

 move usp,a6
 move.b (a6)+,$ffff8802.w  ; 6
 move a6,usp

 move.b d0,(a1)
 pause 18
 moveq #2,d1
 move.b d1,(a1)
 
 moveq #16,d2
attend_syncro
 move.b $ffff8209.w,d3   ; syncro
 beq.s attend_syncro
 sub.b d3,d2
 lsl.b d2,d3

;
; Change la premiere palette
;
 movem.l palette,d2-d7/a3-a4 
 movem.l d2-d7/a3-a4,$ffff8240.w    ; 20+12+128=160/40
 pause 89-40-22-17
;
;
; Ici, on affiche le logo qui rebondit
;
;
 
 move.l ecran,a7      ; 20	
 move.l pos_zbong,a2 ; 20
 tst.l (a2)          ; 4+8=12
 bne .pas_raz_zbong  ; 12 
.ya_raz_zbong
 lea zbong,a2        ; 12
 bra.s .affiche_logo ; 12

.pas_raz_zbong
 pause 6

.affiche_logo        ; ==> 88 / 22 nops

 add.l (a2)+,a7         ; 6+8 => 16
 move.l a7,old_zbong    ; 20
 move.l a2,pos_zbong    ; 20
 move.l pos_distort,a2  ; 20; lea buf_x15,a2         ; 12 ==> 68 / 17 nops
var set 0
var_2 set 0

flag set 3
 rept 13
 lea buf_x15+var_2,a3  ; 12
var_2 set var_2+72
 dcb.w 5-3,nop
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
flag set flag-1
 ifne flag
 pause 89-4-34
 elseif
 move.b (a6)+,$ffff8802.w
flag set 3
 pause 89-4-34-5
 endc
 add.l (a2)+,a3
 movem.l (a3)+,d2-d6/a4-a5     ; 12+(8x7) ; 68
 movem.l d2-d6/a4-a5,var(a7)   ; 12+(8x7) ; 68 -> 136/34 nops
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 11
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
flag set flag-1
 ifne flag
 pause 89-34-22
 elseif
 move.b (a6)+,$ffff8802.w
flag set 3
 pause 89-34-22-5
 endc
 movem.l (a3)+,d2-d6/a4-a5        ; 12+(8x7) ; 68
 movem.l d2-d6/a4-a5,var+28(a7)   ; 12+(8x7) ; 68 -> 136/34 nops
 movem.l (a3)+,d2-d5              ; 12+(8x4) ; 44
 movem.l d2-d5,var+56(a7)         ; 12+(8x4) ; 44 -> 88/22 nops
var set var+230
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b  d1,(a0)
 nop 
 move.b d0,(a0)
 pause 6
 endr

 pause 5
 move.b d1,(a0)
 pause 2
 move.b d0,(a0)
 move.l sprite_1,a2
 move.l sprite_2,a3
 move.l joueur_1_ecran,a4
 move.l joueur_2_ecran,a5
 pause 89-5-5-5-5
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 6

var set 0
 rept 52
 pause 5
 move.b d1,(a0)
 pause 2
 move.b d0,(a0)
 movem.l (a2)+,d2-d7
 movem.l d2-d7,-offset_ecran+160+032+230*y_tetes+var(a4)
 movem.l (a3)+,d2-d7
 movem.l d2-d7,-offset_ecran+160+168+230*y_tetes+var(a5)
var set var+230 
 pause 89-30-30
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 6
 endr
 
*
 moveq #(2-1)-1,d2 ; 8
.boucle_2
 pause 4
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.b (a6)+,$ffff8802.w
 pause 89-5
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 11
*
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 pause 89
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 11
*
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 pause 89
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 4
 dbra d2,.boucle_2
****************
;
; Le 2eme changement de palette
;
 pause 3
 move.b d1,(a0)
 pause 2
 move.b d0,(a0)
 movem.l sprites,d2-d7/a2-a3
 movem.l d2-d7/a2-a3,$ffff8240.w     ; 20+12+128=160/40
 pause 89-40
 move.b d0,(a1)
 move.b d1,(a1)
 lea rasters,a2   ; 3
 pause 13-3
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 7

 moveq #(17+1)-1,d2 ; 8
.boucle_22
 pause 3
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.b (a6)+,$ffff8802.w
 pause 89-5
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 11
*
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 pause 89
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 11
*
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 pause 89
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 5
 dbra d2,.boucle_22
****************

;
; Change la 3eme palette
;
 pause 2
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.b (a6)+,$ffff8802.w
 movem.l palette,d2-d7/a3-a4 
 movem.l d2-d7/a3-a4,$ffff8240.w    ; 20+12+128=160/40
 pause 89-5-40
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 9

 moveq #24-1,d2 ; 8
.boucle_222
 nop
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.b (a6)+,$ffff8802.w
 move.w (a2)+,$ffff8248.w          ; Ici sont les ‡RASTERS‡ !!! 
 pause 89-5-4-39-4-20
 move.w #$640,$ffff8248.w  ; 16/4 nops
 pause 25+20
 move.w (a2)+,$ffff8248.w          ; Ici sont les ‡RASTERS‡ !!! 
 pause 10
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 11
*
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.w (a2)+,$ffff8248.w          ; Ici sont les ‡RASTERS‡ !!! 
 pause 89-4-39-4-20
 move.w #$640,$ffff8248.w  ; 16/4 nops
 pause 25+20
 move.w (a2)+,$ffff8248.w          ; Ici sont les ‡RASTERS‡ !!! 
 pause 10
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 11
*
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.w (a2)+,$ffff8248.w          ; Ici sont les ‡RASTERS‡ !!! 
 pause 89-4-39-4-20
 move.w #$640,$ffff8248.w  ; 16/4 nops
 pause 25+20
 move.w (a2)+,$ffff8248.w          ; Ici sont les ‡RASTERS‡ !!! 
 pause 10
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 7
 dbra d2,.boucle_222
****************

 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 pause 89
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 11
 
* Ici, on fout le bord bas une 1ere fois

 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 pause 89
 move.b d0,(a1)
 nop
 move.b d1,(a1)
 pause 9
 move.b d0,(a1)
 nop
 move.b d1,(a0)
 nop 
 move.b d0,(a0)

 pause 11
 move.b d1,(a0)
 move.b d1,(a1)
 move.b d0,(a0)
 move.b (a6)+,$ffff8802.w
 pause 89-5
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)

 pause 5
 moveq #3,d2
.boucle_3 
 pause 5
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.b (a6)+,$ffff8802.w
 pause 89-5
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 11
*
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 pause 89
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 11
*
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 pause 89
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 3
 dbra d2,.boucle_3

 pause 4
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.b (a6)+,$ffff8802.w
 pause 89-5
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 11
*
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 pause 89
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 11
 
* Ici, on fout le bord bas une seconde fois

 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 pause 89
 move.b d0,(a1)
 nop
 move.b d1,(a1)
 pause 9
 move.b d0,(a1)
 nop
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 
 pause 11
 move.b d1,(a0)
 move.b d1,(a1)
 move.b d0,(a0)
 move.b (a6)+,$ffff8802.w
 move.l ligne_ptr_2,a2 ; 20/5
 lea $ffff8240.w,a3    ; 8/2
 pause 89-5-5-2
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
*
 pause 11
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 pause 89
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 11
*
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 pause 89
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 11
*
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.b (a6)+,$ffff8802.w
 pause 89-5
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 7

*** ============> 128 nops entre les deux ***
 rept 42
 move.w (a2)+,(a3)  ; 12/3 nops
 endr
 move.w d0,(a3) ; 8
***
 moveq #6,d2
.boucle_5
 pause 3
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 pause 89
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 11
*
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 pause 89
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 11
*
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.b (a6)+,$ffff8802.w
 pause 89-5
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 5
 dbra d2,.boucle_5

 move.l ligne_ptr_2,a2 ; 20
 lea $ffff8240.w,a3    ; 8
 rept 43
 move.w (a2)+,(a3)  ; 12/3 nops
 endr
 clr.w (a3)
yurk
   
 opt o+,w-

;
; L…, on s'occupe des rasters sur les "PLAYER #n"
;
rasters_pour_joueur_1
 move.l raster_ptr_1,a0
 move.w (a0)+,d0
 tst.w 9*2(a0)
 bpl .pas_encore_fini
 move.l #superbe_degrade,a0
.pas_encore_fini
 move.l a0,raster_ptr_1

rasters_pour_joueur_2
 move.l raster_ptr_2,a1
 move.w (a1)+,d0
 tst.w 9*2(a1)
 bpl .pas_encore_fini
 move.l #superbe_degrade,a1
.pas_encore_fini
 move.l a1,raster_ptr_2
 lea rasters_player,a2
 rept 9
 move.w (a0)+,(a2)+
 move.w (a1)+,(a2)+
 endr
  
;
; L…, la gestion des 2 liserets de couleurs sur le scroll
;
 move.l ligne_ptr_1,a0
 cmp.w #-1,44*2(a0)
 bne pas_raz_ligne_1
 lea ligne_couleur,a0
pas_raz_ligne_1
 addq #2,a0
 move.l a0,ligne_ptr_1

 move.l ligne_ptr_2,a0
 cmp.w #-1,44*2(a0)
 bne pas_raz_ligne_2
 lea ligne_couleur,a0
pas_raz_ligne_2 
 addq #2,a0
 move.l a0,ligne_ptr_2

;
; Le distort du logo "press fire"
; 
 move.l pos_distort,a0
 tst.l 14*4(a0)
 bpl.s pas_reset
 lea distort,a0 
pas_reset
 lea 4(a0),a0
 move.l a0,pos_distort
 
;
;
; Ici, effacement de l'ancien emplacement du logo
;  ®Press fire¯ qui rebondit...
;
;
efface_le_logo_ki_bounce
 moveq #0,d2
 moveq #0,d3
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
 move.l d2,a3
 move.l d2,a4           ; 4x8 -->  32 cycles
 move.l d2,a5           ; 4x8 -->  32 cycles
 move.l old_zbong,a6           ; 20  ==> 52
 
var set 0
 rept 13
 movem.l d2-d7/a3-a5,var(a6)      ; 12+64
 movem.l d2-d7/a3-a5,var+36(a6)   ; 12+64 => 152x14 ==> 2128+88 = 2216
var set var+230                   : --> 554 nops
 endr
 move.b (a6)+,$ffff8802.w

;
; L…, la gestion du texte central
; 
 jmp affiche_texte
fin_texte

 move.b (a6)+,$ffff8802.w

;
; Et ici, celle des 4 buffers pour le scroll en bas.
; 
gere_les_buffers_de_scroll
 move.w cpt_scroll,d0
 addq.w #1,d0
 and.w #%11,d0
 move.w d0,cpt_scroll
 lsl #2,d0
 lea table_scrolling,a0
 move.l 0(a0,d0.w),a0
 jmp (a0)
continue_vbl
 movem.l pos_1,d0-d3
 movem.l d0-d3,pos_2
 move.l d3,pos_1

;
; L…, on fait rebondir les sprites
;  1:saute
;  0:derniere fois
; -1:bouge pas !  
;
fait_rebondir_les_sprites
 move.l ecran,a0
 tst.w joueur_flag_1
 bmi .bouge_pas 
 move.l joueur_1_ptr,a1
 move.w (a1)+,d0
 bpl .pas_fini
 lea on_saute,a1
 move.w (a1)+,d0
 tst.w joueur_flag_1
 bne .pas_fini
 move.w #-1,joueur_flag_1 
.pas_fini
 move.l a1,joueur_1_ptr
 sub.w d0,a0
.bouge_pas
 move.l a0,joueur_1_ecran
et_puis_le_deuxieme
 move.l ecran,a0
 tst.w joueur_flag_2
 bmi .bouge_pas 
 move.l joueur_2_ptr,a1
 move.w (a1)+,d0
 bpl .pas_fini
 lea on_saute,a1
 move.w (a1)+,d0
 tst.w joueur_flag_2
 bne .pas_fini
 move.w #-1,joueur_flag_2
.pas_fini
 move.l a1,joueur_2_ptr
 sub.w d0,a0
.bouge_pas
 move.l a0,joueur_2_ecran

;
; Ici, je gere l'animation du sprite (gai ou triste)
;
anime_sprite_1
 tst.w joueur_1
 bne .est_inactif
 tst.w joueur_stade_1
 beq fin_anime_sprite_1
 sub.w #1,joueur_stade_1  ; Mobile et pas encore gai: on continue...
 sub.l #1248,sprite_1
 bra fin_anime_sprite_1
.est_inactif
 cmp.w #4,joueur_stade_1
 beq fin_anime_sprite_1
 add.w #1,joueur_stade_1
 add.l #1248,sprite_1
fin_anime_sprite_1

anime_sprite_2
 tst.w joueur_2
 bne .est_inactif
 tst.w joueur_stade_2
 beq fin_anime_sprite_2
 sub.w #1,joueur_stade_2  ; Mobile et pas encore gai: on continue...
 sub.l #1248,sprite_2
 bra fin_anime_sprite_2
.est_inactif
 cmp.w #4,joueur_stade_2
 beq fin_anime_sprite_2
 add.w #1,joueur_stade_2
 add.l #1248,sprite_2
fin_anime_sprite_2
   
fin_vbl    
 move.l sauve_a7,a7

  ***************************************
 ***                                   ***
*** Ici, gestion des ‚venements clavier ***
 ***                                   ***
  ***************************************

 move.b $fffffc02.w,d0
 cmp.b #$62,d0
 beq __help_1

duree=10
 tst.l wait
 beq fini
 sub.l #1,wait
 bne znorte
fini

 cmp.b #$02,d0       **** 1
 bne.s .pas_change_joueur_1
 move.l #duree,wait
 move.w #1,d1
 eor.w #1,joueur_1
 tst.w joueur_1
 beq.s .pas_inactif_joueur_1
 moveq #0,d1
.pas_inactif_joueur_1 
 move.w d1,joueur_flag_1
.pas_change_joueur_1 

 cmp.b #$03,d0       **** 2
 bne.s .pas_change_joueur_2
 move.l #duree,wait
 move.w #1,d1
 eor.w #1,joueur_2
 tst.w joueur_2
 beq.s .pas_inactif_joueur_2
 moveq #0,d1
.pas_inactif_joueur_2 
 move.w d1,joueur_flag_2
.pas_change_joueur_2

 cmp.b #$3b,d0       **** F1
 bne.s pas_znort
et_re
 move.l #duree,wait
 addq.l #1,controler_1
 add.l #72,acontroler_1
 cmp.l #3,controler_1
 bne znort
 move.l #0,controler_1
 move.l #manettes,acontroler_1
znort
 move.l controler_1,d1
 cmp.l controler_2,d1
 beq et_re 
* On change les rasters
 lea raster_1,a0
 mulu #18,d1
 add.w d1,a0
 lea rasters_change,a1
 moveq #8,d0
.change_rasters
 move.w (a0)+,(a1)
 lea 4(a1),a1
 dbra d0,.change_rasters

pas_znort

 cmp.b #$3c,d0       **** F2
 bne.s pas_znorte
et_ret
 move.l #duree,wait
 addq.l #1,controler_2
 add.l #72,acontroler_2
 cmp.l #3,controler_2
 bne znorte
 move.l #0,controler_2
 move.l #manettes,acontroler_2
znorte
 move.l controler_2,d1
 cmp.l controler_1,d1
 beq et_ret 
* On change les rasters
 lea raster_1,a0
 mulu #18,d1
 add.w d1,a0
 lea rasters_change,a1
 moveq #8,d0
.change_rasters
 move.w (a0)+,2(a1)
 lea 4(a1),a1
 dbra d0,.change_rasters

pas_znorte
 cmp.b #$23,d0   ; H -> Hi-Scores
 bne pas_h
 move.l #fonds_sombre,_auto_fondu+2
pas_h 
 cmpi.b #$39,d0      **** Espace
 bne .pas_space
 move.w #1,flag_sortie
 bra .fin_test
.pas_space
 cmpi.b #$74,d0      **** Bouton gauche
 bne .pas_joystick_1
 move.w #2,flag_sortie
 bra .fin_test
.pas_joystick_1
 cmpi.b #$75,d0      **** Bouton droit
 bne .pas_joystick_2
 move.w #3,flag_sortie
.pas_joystick_2
.fin_test

;
; Enfin, la suite !!! (musique & Cie)
;
 jsr music
 move.b #9,$ffff8800.w
 move usp,a6
 lea 104-10(a6),a6
 move a6,usp
_auto_fondu
 jmp fonds_clair
 rte

__help_1
 move.b #2,$ffff820a.w
 move.b #0,$ffff8260.w
 move.l #__help_vbl_1,$70.w
 rte

__help_vbl_1 
 cmp.b #$61,$fffffc02.w
 beq.s routine_vbl_1
 rte
  
routine_vbl_1
 move.b #2,$ffff820a.w
 move.b #0,$ffff8260.w
 move.l #routine_vbl,$70.w
 movem.l fondu_1,d0-d7
 movem.l d0-d7,palette
 movem.l fondu_2,d0-d7
 movem.l d0-d7,sprites
 jsr music
 move.l #fonds_clair,_auto_fondu+2
 move.l #fondu_1,fondu_1_ptr
 move.l #fondu_2,fondu_2_ptr
 sf $fffffa19.w
 rte

 opt o-
 
routine_vbl_2_bis
 move.w #$2700,sr
******************
 move.b #%00100000,$fffffa07.w
 move.b #%00100000,$fffffa13.w
 clr.b $fffffa09.w
 clr.b $fffffa15.w
 bclr #3,$fffffa17.w
 clr.b $fffffa19.w
 move.l #routine_timer_a,$134.w
 move.b #51,$fffffa1f.w   ; Data
 move.b #%110,$fffffa19.w  ; Control On, le timer d‚marre
 opt o+,w-
******************
****************** Temps variable autoris‚
******************
******************
******************
 move.l a7,sauve_a7
   
 jsr music
 move.b #9,$ffff8800.w
 move usp,a6
 move.l a6,a3
 lea 104(a3),a3
 move.l a3,usp
 move.b (a6)+,$ffff8802.w  ; 16/4 nops

 movem.l palette_noire,d0-d7
 movem.l d0-d7,$ffff8240.w
 
 moveq #0,d0
 lea couleurs,a3
 move.l fonds_y_ptr,a0
 move.w (a0)+,d0
 cmp.w #-1,d0
 bne .pas_raz_couleurs
 lea table_offset_y,a0
 move.w (a0)+,d0
.pas_raz_couleurs   
 move.l a0,fonds_y_ptr
 add.l d0,a3

 rept 8
 move.b (a6)+,$ffff8802.w  ; 16/4 nops
 pause 128*3-5
 endr
   
******************
****************** Temps fixe obligatoire
******************
******************
 opt o-
 stop #$2300
 clr.b $fffffa19.w
 clr.b $fffffa07.w
 move.b (a6)+,$ffff8802.w   ; 16/4 nops
 pause 54-2-3-5+offset_ste  ; Faire la compensation pour tous les STs...
 lea $ffff8260.w,a0    ; 8 resolution 
 lea $ffff820a.w,a1    ; 8 frequence
 lea $ffff8240.w,a2    ; 8 palette
 moveq #0,d0           ; 4        
 move.b d0,(a1)  ; il faut 4283 nops, en plus des initialisations
 pause 18
 moveq #2,d1
 move.b d1,(a1)
 
 moveq #16,d2
.attend_syncro
 move.b $ffff8209.w,d3   ; syncro
 beq.s .attend_syncro
 sub.b d3,d2
 lsl.b d2,d3

*
* 91 nops libres apres la syncro ecran
*
 pause 91-5
 move.b (a6)+,$ffff8802.w  ; 16/4 nops
_auto_modif
 rept 6
 jsr _ligne_230
 endr

 pause 5-5
 move.b (a6)+,$ffff8802.w  ; 16/4 nops
 move.b d1,(a0)
 pause 2
 move.b d0,(a0)
 pause 89-13-11-2-4-4
 movem.l palette+16,d7/a4-a5/a7  ; 20+4*8=52/13
 movem.l (a3)+,d3-d6             ; 12+4*8=44/11
 lea 16(a3),a3
 move.l a5,24(a2)
 move.l a7,28(a2)
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13-4-4-4
 move.l d7,16(a2)
 move.l a4,20(a2)
 move.l d6,12(a2)  ; 4
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 move.l d3,(a2)   ; 3
 move.l d4,4(a2)  ; 4

 pause 9-7
 moveq #67,d2 ; 8
.boucle_1
 pause 1
 move.b d1,(a0)
 pause 2
 move.b d0,(a0)
 move.b (a6)+,$ffff8802.w  ; 16/4 nops
 move.l d5,8(a2)
 movem.l (a3)+,d3-d6        ; 12+8*4=44/11
 lea 16(a3),a3
 pause 89-5-11-4-2
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13-4
 move.l d6,12(a2)  ; 4
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 move.l d3,(a2)   ; 3
 move.l d4,4(a2)  ; 4
*
 pause 11-7
 move.b d1,(a0)
 pause 2
 move.b d0,(a0)
 move.l d5,8(a2)
 movem.l (a3)+,d3-d6        ; 12+8*4=44/11
 lea 16(a3),a3
 pause 89-11-4-2
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13-4
 move.l d6,12(a2)  ; 4
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 move.l d3,(a2)   ; 3
 move.l d4,4(a2)  ; 4
*
 pause 11-7
 move.b d1,(a0)
 pause 2
 move.b d0,(a0)
 move.l d5,8(a2)
 movem.l (a3)+,d3-d6        ; 12+8*4=44/11
 lea 16(a3),a3
 pause 89-11-4-2
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13-4
 move.l d6,12(a2)  ; 4
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 move.l d3,(a2)   ; 3
 move.l d4,4(a2)  ; 4
 dbra d2,.boucle_1

* Ici, on fout le bord bas une 1ere fois
 
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.l d5,8(a2)
 movem.l (a3)+,d3-d6        ; 12+8*4=44/11
 lea 16(a3),a3
 pause 89-11-4-2
 move.b d0,(a1)
 nop
 move.b d1,(a1)
 pause 9-4
 move.l d6,12(a2)  ; 4
 move.b d0,(a1)
 nop
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 11-7
 move.l d3,(a2)   ; 3
 move.l d4,4(a2)  ; 4

 move.b d1,(a0)
 move.b d1,(a1)
 move.b d0,(a0)
 move.l d5,8(a2)
 movem.l (a3)+,d3-d6        ; 12+8*4=44/11
 lea 16(a3),a3
 pause 89-11-4-2
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13-4-5
 move.b (a6)+,$ffff8802.w  ; 16/4 nops
 move.l d6,12(a2)  ; 4
 move.b d1,(a0)
 nop 
 move.b d0,(a0)

 pause 9-7
 move.l d3,(a2)   ; 3
 move.l d4,4(a2)  ; 4
 moveq #3,d2
.boucle_3 
*
 pause 1
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.l d5,8(a2)
 move.b (a6)+,$ffff8802.w
 movem.l (a3)+,d3-d6        ; 12+8*4=44/11
 lea 16(a3),a3
 pause 89-5-11-4-2
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13-4
 move.l d6,12(a2)  ; 4
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 move.l d3,(a2)   ; 3
 move.l d4,4(a2)  ; 4
*
 pause 11-7
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.l d5,8(a2)
 movem.l (a3)+,d3-d6        ; 12+8*4=44/11
 lea 16(a3),a3
 pause 89-11-4-2
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13-4
 move.l d6,12(a2)  ; 4
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 move.l d3,(a2)   ; 3
 move.l d4,4(a2)  ; 4
*
 pause 11-7
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.l d5,8(a2)
 movem.l (a3)+,d3-d6        ; 12+8*4=44/11
 lea 16(a3),a3
 pause 89-11-4-2
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13-4
 move.l d6,12(a2)  ; 4
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 move.l d3,(a2)   ; 3
 move.l d4,4(a2)  ; 4
 dbra d2,.boucle_3

*****
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.l d5,8(a2)
 move.b (a6)+,$ffff8802.w
 movem.l (a3)+,d3-d6        ; 12+8*4=44/11
 lea 16(a3),a3
 pause 89-5-11-4-2
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13-4
 move.l d6,12(a2)  ; 4
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 move.l d3,(a2)   ; 3
 move.l d4,4(a2)  ; 4
*
 pause 11-7
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.l d5,8(a2)
 movem.l (a3)+,d3-d6        ; 12+8*4=44/11
 lea 16(a3),a3
 pause 89-11-4-2
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13-4
 move.l d6,12(a2)  ; 4
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 move.l d3,(a2)   ; 3
 move.l d4,4(a2)  ; 4
 pause 11-7
  
* Ici, on fout le bord bas une seconde fois

 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.l d5,8(a2)
 movem.l (a3)+,d3-d6        ; 12+8*4=44/11
 lea 16(a3),a3
 pause 89-11-4-2
 move.b d0,(a1)
 nop
 move.b d1,(a1)
 pause 9-4
 move.l d6,12(a2)  ; 4
 move.b d0,(a1)
 nop
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 
 pause 11-7
 move.l d3,(a2)   ; 3
 move.l d4,4(a2)  ; 4
 move.b d1,(a0)
 move.b d1,(a1)
 move.b d0,(a0)
 move.l d5,8(a2)
 movem.l (a3)+,d3-d6        ; 12+8*4=44/11
 lea 16(a3),a3
 pause 89-11-4-2
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13-4-5
 move.b (a6)+,$ffff8802.w  ; 16/4 nops
 move.l d6,12(a2)  ; 4
 move.b d1,(a0)
 nop 
 move.b d0,(a0)

 pause 10-7
 move.l d3,(a2)   ; 3
 move.l d4,4(a2)  ; 4
 moveq #13+1,d2
.boucle_4
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.l d5,8(a2)
 move.b (a6)+,$ffff8802.w
 movem.l (a3)+,d3-d6        ; 12+8*4=44/11
 lea 16(a3),a3
 pause 89-5-11-4-2
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13-4
 move.l d6,12(a2)  ; 4
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 move.l d3,(a2)   ; 3
 move.l d4,4(a2)  ; 4
*
 pause 11-7
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.l d5,8(a2)
 movem.l (a3)+,d3-d6        ; 12+8*4=44/11
 lea 16(a3),a3
 pause 89-11-4-2
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13-4
 move.l d6,12(a2)  ; 4
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 move.l d3,(a2)   ; 3
 move.l d4,4(a2)  ; 4
*
 pause 11-7
 move.b d1,(a0)
 nop
 nop
 move.b d0,(a0)
 move.l d5,8(a2)
 movem.l (a3)+,d3-d6        ; 12+8*4=44/11
 lea 16(a3),a3
 pause 89-11-4-2
 move.b d0,(a1)
 move.b d1,(a1)
 pause 13-4
 move.l d6,12(a2)  ; 4
 move.b d1,(a0)
 nop 
 move.b d0,(a0)
 pause 8-7
 move.l d3,(a2)   ; 3
 move.l d4,4(a2)  ; 4
 dbra d2,.boucle_4

 move.l sauve_a7,a7

 jsr calcule_hard

 move.b $fffffc02.w,d0
 cmp.b #$62,d0
 beq __help_2
 cmpi.b #$39,d0
 bne .pas_space
 move.w #1,flag_sortie
 bra .fin_test
.pas_space
 cmpi.b #$74,d0
 bne .pas_joystick_1
 move.w #2,flag_sortie
 bra .fin_test
.pas_joystick_1
 cmpi.b #$75,d0
 bne .pas_joystick_2
 move.w #3,flag_sortie
.pas_joystick_2
.fin_test

***********
 move.b (a6)+,$ffff8802.w  ; 16/4 nops
_auto_fondu_2
 jmp fonds_clair_2
 rte

__help_2
 move.b #2,$ffff820a.w
 move.b #0,$ffff8260.w
 move.l #__help_vbl_2,$70.w
 rte

__help_vbl_2
 cmp.b #$61,$fffffc02.w
 beq.s routine_vbl_2
 rte

routine_vbl_2
 move.b #2,$ffff820a.w
 move.b #0,$ffff8260.w
 move.l #routine_vbl_2_bis,$70.w
 movem.l fondu_1,d0-d7
 movem.l d0-d7,palette
 jsr music
 move.l #table_deplace,position_ptr
 move.l #fonds_clair_2,_auto_fondu_2+2
 move.l #fondu_1,fondu_1_ptr
 sf $fffffa19.w
 rte

fonds_clair_2
 move.l fondu_1_ptr,a0
 movem.l (a0)+,d0-d7
 movem.l d4-d7,palette+16
 move.l a0,fondu_1_ptr
 cmp.l #fondu_1+32*16,a0
 bmi .pas_fini_fondu
 sub.l #32,fondu_1_ptr
 move.l #fonds_stable,_auto_fondu_2+2
.pas_fini_fondu 
 rte

fonds_stable_2
 rte

fonds_sombre_2
 move.l fondu_1_ptr,a0
 movem.l (a0),d0-d7
 movem.l d4-d7,palette+16
 sub.l #32,a0
 move.l a0,fondu_1_ptr
 cmp.l #fondu_1,a0
 bpl .pas_fini_fondu
 move.l #fonds_stable,_auto_fondu_2+2
 move.w #1,flag_exit
 move.l #vbl_jonction,$70.w
 move.b #%00100000,$fffffa07.w
 move.b #%00100000,$fffffa13.w
 clr.b $fffffa09.w
 clr.b $fffffa15.w
 bclr #3,$fffffa17.w
 clr.b $fffffa19.w
 move.l #routine_timer_digidrum,$134.w
 move.b #$64,$fffffa1f.w
 move.b #1,$fffffa19.w
.pas_fini_fondu 
 rte

*****************************

numero_texte = 0

effacer_texte
 cmp.l #1,buffer_flag
 bne recopier_buffer
 move.l ecran_pos,a1
var set 0
 rept 88/4
 move.l #0,var(a1)
var set var+4
 endr
 add.l #230,ecran_pos
 add.l #1,y_buffer
 cmp.l #70,y_buffer
 bne .azer
 move.l #2,buffer_flag
 move.l ecran,ecran_pos
 add.l #-offset_ecran+160+64+230*y_message,ecran_pos
 move.l #0,y_buffer
.azer 
 jmp fin_texte
 
recopier_buffer
 cmp.l #2,buffer_flag
 bne attendre_pause
 move.l buffer_pos,a0
 move.l ecran_pos,a1
var set 0
 rept 88/4
 move.l var(a0),var(a1)
var set var+4
 endr
 add.l #88,buffer_pos
 add.l #230,ecran_pos
 add.l #1,y_buffer
 cmp.l #70,y_buffer
 bne .azer
 move.l #3,buffer_flag
.azer 
 jmp fin_texte

attendre_pause
 add.l #1,wait_2
 cmp.l #50*5,wait_2
 bne .azer
 move.l #0,buffer_flag
 move.l #0,wait_2
.azer 
 jmp fin_texte
  
affiche_texte
 tst.l buffer_flag
 bne effacer_texte
 move.l pos_texte_2,a6
 move.l adresse_texte_2,a1
 lea fonte_8,a0
 moveq #0,d1
 move.b (a6)+,d1
 lsl.l #5,d1
 add.l d1,a0
 lea fonte_8,a5
 moveq #0,d1
 move.b (a6)+,d1
 lsl.l #5,d1
 add.l d1,a5
var2 set 0
 rept 8
var set 0
 move.b (a0)+,var+var2(a1)
 move.b (a5)+,var+1+var2(a1)
var set var+2
 move.b (a0)+,var+var2(a1)
 move.b (a5)+,var+1+var2(a1)
var set var+2
 move.b (a0)+,var+var2(a1)
 move.b (a5)+,var+1+var2(a1)
var set var+2
 move.b (a0)+,var+var2(a1)
 move.b (a5)+,var+1+var2(a1)
var set var+2
var2 set var2+88
 endr
 
 add.l #8,adresse_texte_2
 add.l #2,pos_texte_2

 add.l #1,x_texte
 cmp.l #11,x_texte
 bne .arg
 move.l #0,x_texte
 add.l #88*9,adresse_texte_2
 add.l #1,y_texte
 cmp.l #7,y_texte
 bne .arg
 move.l #0,y_texte
 move.l #buffer_texte,adresse_texte_2
 add.l #1,z_texte
 move.l #1,buffer_flag
 move.l #buffer_texte,buffer_pos
 move.l ecran,ecran_pos
 add.l #-offset_ecran+160+64+230*y_message,ecran_pos
 move.l #0,y_buffer
 cmp.l #5,z_texte
 bne .arg
 move.l #0,z_texte
 move.l #texte_2+numero_texte*(22*7),pos_texte_2
.arg 
 jmp fin_texte
 
*****************************

scrolling_1
 move.l lettre_lue,a0
var set 0
 lea position_1+112-4,a1
 rept 16
 move.l (a0)+,var(a1)
var set var+112+4
 endr
 jmp continue_vbl

scrolling_2
 move.l lettre_lue,a0
var set 0
 lea position_2+112-4,a1
 moveq #0,d1
 rept 16
 move.w (a0)+,d0
 lsr.w #4,d0 
 move.b d1,var+1(a1)
 or.w d0,var(a1)
 move.w (a0)+,d0
 lsr.w #4,d0 
 move.b d1,var+3(a1)
 or.w d0,var+2(a1)
 move.b 1-4(a0),d0
 lsl.b #4,d0
 move.b d0,var+4(a1)
 move.b 3-4(a0),d0
 lsl.b #4,d0
 move.b d0,var+6(a1)
var set var+112+4
 endr
 jmp continue_vbl

scrolling_3
 moveq #0,d0
 move.l pos_scroll,a0
 move.b (a0)+,d0
 bpl .pas_raz_scroll
 move.l #fonds_sombre,_auto_fondu+2
 lea texte_1,a0    ; 12
 move.b (a0)+,d0   ; 8
.pas_raz_scroll
 move.l a0,pos_scroll
 lsl.w #6,d0
 lea fonte_16,a0
 lea (a0,d0),a0
 move.l a0,lettre_lue
var set 0
 lea position_3+112-4,a1
 rept 16
 move.b (a0)+,var+1(a1)
 move.b (a0)+,var+4(a1)
 move.b (a0)+,var+3(a1)
 move.b (a0)+,var+6(a1)
var set var+112+4
 endr
 jmp continue_vbl

scrolling_4
 move.l lettre_lue,a0
var set 0
 lea position_4+112-4,a1
 rept 16
 move.b (a0),d0
 lsr.b #4,d0
 or.b d0,var+1(a1)
 move.b 2(a0),d0
 lsr.b #4,d0
 or.b d0,var+3(a1)
 move.w (a0)+,d0
 lsl.w #4,d0
 move.w d0,var+4(a1)
 move.w (a0)+,d0
 lsl.w #4,d0
 move.w d0,var+6(a1)
var set var+112+4
 endr
 jmp continue_vbl





prepare_ecran_1 
 move.l ecran,a0
 move.w #64000/4-1,d0
clear
 clr.l (a0)+
 dbra d0,clear 

;
; On affiche le logo... (Tres b“ !)
;
affiche_logo
 lea logo,a0
 move.l ecran,a1	
 lea -offset_ecran+160+32(a1),a1
 moveq #93,d0
.ligne_suivante
 rept 160/4
 move.l (a0)+,(a1)+
 endr
 lea 230-160(a1),a1
 dbra d0,.ligne_suivante

;
; Et puis les 2 joueurs
;
affiche_joueur_1
 lea joueurs,a0
 move.l ecran,a1	
 lea -offset_ecran+160+24+230*y_joueurs(a1),a1
 move.w #12,d0
.ligne_suivante
 rept 40/4
 move.l (a0)+,(a1)+
 endr
 lea 230-40(a1),a1
 dbra d0,.ligne_suivante

affiche_joueur_2
 move.l ecran,a1	
 lea -offset_ecran+160+160+230*y_joueurs(a1),a1
 move.w #12,d0
.ligne_suivante
 rept 40/4
 move.l (a0)+,(a1)+
 endr
 lea 230-40(a1),a1
 dbra d0,.ligne_suivante

init_texte
 move.l #texte_2+numero_texte*(22*7),pos_texte_2
 move.l #buffer_texte,adresse_texte_2
 move.l #0,x_texte
 move.l #0,y_texte
 move.l #0,buffer_flag

affiche_infos
 lea texte_3,a6
 move.l ecran,a1
 add.l #-offset_ecran+160+24+230*y_infos,a1
 move.l ecran,a2
 add.l #-offset_ecran+160+160+230*y_infos,a2
 moveq #3,d3
.ligne_suivante 
 moveq #4,d2
.lettre_suivante
 lea fonte_8,a0
 moveq #0,d1
 move.b (a6)+,d1
 lsl.l #5,d1
 add.l d1,a0
 lea fonte_8,a5
 moveq #0,d1
 move.b (a6)+,d1
 lsl.l #5,d1
 add.l d1,a5
var2 set 0
 rept 8
var set 0
 move.b (a0),var+var2(a1)
 move.b (a0)+,var+var2(a2)
 move.b (a5),var+1+var2(a1)
 move.b (a5)+,var+1+var2(a2)
var set var+2
 move.b (a0),var+var2(a1)
 move.b (a0)+,var+var2(a2)
 move.b (a5),var+1+var2(a1)
 move.b (a5)+,var+1+var2(a2)
var set var+2
 move.b (a0),var+var2(a1)
 move.b (a0)+,var+var2(a2)
 move.b (a5),var+1+var2(a1)
 move.b (a5)+,var+1+var2(a2)
var set var+2
 move.b (a0),var+var2(a1)
 move.b (a0)+,var+var2(a2)
 move.b (a5),var+1+var2(a1)
 move.b (a5)+,var+1+var2(a2)
var set var+2
var2 set var2+230
 endr
 lea 8(a1),a1
 lea 8(a2),a2
 dbra d2,.lettre_suivante
 lea -8*5+230*10(a1),a1
 lea -8*5+230*10(a2),a2
 dbra d3,.ligne_suivante
 rts

prepare_ecran_2
 move.l ecran,a0
 lea 160(a0),a0
 move.w #%0101010101010101,d0
 move.w #%0011001100110011,d1
 move.w #%0000111100001111,d2
 move.w #%0000000000000000,d3
 move.w #686-1,d7
.make_fonds_1
 moveq #25,d6
.make_fonds_2
 move.w d0,(a0)+
 move.w d1,(a0)+
 move.w d2,(a0)+
 move.w d3,(a0)+
 dbra d6,.make_fonds_2
 lea 22(a0),a0
 dbra d7,.make_fonds_1

;
; On affiche le logo... (Tres b“ !)
;
affiche_logo_euphoria
 lea logo,a0
 move.l ecran,a1	
 lea 160+32(a1),a1
 moveq #93,d7
.ligne_suivante
 moveq #19,d6
.octet_suivant
 move.w (a0),d0
 or.w 2(a0),d0
 or.w 4(a0),d0
 or.w 6(a0),d0
 move.w d0,d1
 swap d1
 move.w d0,d1
 not.l d1
 move.l #%01010101010101010011001100110011,d0
 and.l d1,d0
 or.l (a0)+,d0
 move.l d0,(a1)+
 move.l #%00001111000011110000000000000000,d0
 and.l d1,d0
 or.l (a0)+,d0
 move.l d0,(a1)+
 dbra d6,.octet_suivant
 lea 230-160(a1),a1
 dbra d7,.ligne_suivante

affiche_message
nlettre=46
 lea texte,a3
 move.l ecran,a1	
 lea 160+16+230*100(a1),a1

 moveq #56,d0
.ligne_suivante

 moveq #(nlettre/2)-1,d2
.lettre_suivante
 lea fonte_8,a0
 moveq #0,d1
 move.b (a3)+,d1
 lsl.l #5,d1
 add.l d1,a0

 lea fonte_8,a4
 moveq #0,d1
 move.b (a3)+,d1
 lsl.l #5,d1
 add.l d1,a4

 moveq #7,d3
.range   
 move.b (a0),d7
 or.b 1(a0),d7
 or.b 2(a0),d7
 or.b 3(a0),d7
 lsl.w #8,d7
 move.b (a4),d7
 or.b 1(a4),d7
 or.b 2(a4),d7
 or.b 3(a4),d7
 not.w d7
 move.w d7,d6
 swap d7
 move.w d6,d7

 move.b (a0)+,d6
 lsl.l #8,d6
 move.b (a4)+,d6
 lsl.l #8,d6 
 move.b (a0)+,d6
 lsl.l #8,d6
 move.b (a4)+,d6
 move.l #%01010101010101010011001100110011,d5
 and.l d7,d5
 or.l d6,d5
 move.l d5,(a1)

 move.b (a0)+,d6
 lsl.l #8,d6
 move.b (a4)+,d6
 lsl.l #8,d6 
 move.b (a0)+,d6
 lsl.l #8,d6
 move.b (a4)+,d6
 move.l #%00001111000011110000000000000000,d5
 and.l d7,d5
 or.l d6,d5
 move.l d5,4(a1)

 lea 230(a1),a1
 dbra d3,.range
 lea 8-230*8(a1),a1
 dbra d2,.lettre_suivante
 lea 230*10-(nlettre/2)*8(a1),a1
 dbra d0,.ligne_suivante
 rts

predecalle_logo
 lea buf_x15,a1
 moveq #15,d7
.logo_suivant
 lea joueurs+(40*13*2),a0
 moveq #12,d6
.ligne_suivante 
 moveq #15,d5
.mot_suivant 
 move.l (a0)+,(a1)+
 dbra d5,.mot_suivant
 move.l #0,(a1)+
 move.l #0,(a1)+
 dbra d6,.ligne_suivante
 dbra d7,.logo_suivant

 moveq #15,d5
 lea fin_x15,a0
.bloc_suivant
 move.l d5,d3
 moveq #16,d0
 sub.l d3,d0
 move.l #(936/2)-1-1-1-1,d1 ; 5808
.predecalle_bloc
 move.w (a0),d4
 move.w -8(a0),d2
 lsr.w d3,d4        ; decalle de D3 rotations
 lsl.w d0,d2
  add.w d2,d4
 move.w d4,(a0)
 subq.l #2,a0
 dbra d1,.predecalle_bloc
 dbra d5,.bloc_suivant
 rts

efface_bss 
 lea debut_bss,a0
 lea fin_bss,a1
 moveq #0,d0
efface_suivant
 move.l d0,(a0)+
 cmp.l a1,a0
 bmi efface_suivant
 jmp retourne_la_ou_il_le_faut_sale_con

stoppe_joysticks
 move.w sr,d7
 move.w #$2700,sr
 lea $fffffc00.w,a0

.attend_libre_1
 btst.b #1,(a0)
 beq .attend_libre_1
 move.b #7,2(a0)

.attend_libre_2
 btst.b #1,(a0)
 beq .attend_libre_2
 move.b #%1,2(a0)

envoie_mode_souris_on
.attend_libre
 btst.b #1,(a0)
 beq .attend_libre
 move.b #8,2(a0)

 move.w d7,sr
 rts
  
prepare_joysticks
 move.w sr,d7
 move.w #$2700,sr
 lea $fffffc00.w,a0

envoie_mode_souris_off
.attend_libre
 btst.b #1,(a0)
 beq .attend_libre
 move.b #8,2(a0)

envoie_entete
.attend_libre
 btst.b #1,(a0)
 beq .attend_libre
 move.b #7,2(a0)

envoie_donne
.attend_libre
 btst.b #1,(a0)
 beq .attend_libre
 move.b #%100,2(a0)

 move.w d7,sr
 rts

*****************************
*****************************
*****************************

calcule_hard
 move.l position_ptr,a1
 move.l (a1)+,d1
 bpl .pas_fin_table
 move.l #fonds_sombre,_auto_fondu_2+2
 lea table_deplace,a1
 move.l (a1)+,d1
.pas_fin_table 
 move.l a1,position_ptr
 move.l ecran,d0
 add.l d1,d0 
 sub.l #8*5,d0
 moveq #0,d1
 move.b d0,d1
 lea syncscro,a0
 lsl.w #4,d1
 lea 0(a0,d1.w),a0
 lea _auto_modif+2,a1
var set 0
 rept 6
 move.l (a0)+,var(a1)
var set var+6 
 endr
 add.w (a0)+,d0
 lsr.l #8,d0
 lea $ffff8201.w,a0
 movep.w d0,(a0)
 rts
 
memo macro
 Format de sauvegarde:
 128 blocs de 32 octets (de 0 … 256 par pas de 2)

 32 octets r‚partis ainsi:
    --> 6.l de 0 … 5
          0 ==> Ligne 160 : 0
          1 ==> Ligne 186 : 26
          2 ==> Ligne 204 : 44
          3 ==> Ligne 230 : 70
          4 ==> Ligne  54 : -106
          5 ==> Ligne 158 : -2
          6 ==> Ligne 184 : 24
    --> 1.w offset x256 … ajouter sur la m‚moire ‚cran
    --> 1.w ==> 0
    --> 1.l ==> 0
    
 endm

; Note: Le JSR prends 5 nops et le RTS 4 nops

_ligne_160
 pause 119
 rts

_ligne_186
 nop
 move.b d1,(a0)
 nop
 move.b d0,(a0)
 pause 113
 rts

_ligne_204
 pause 95
 move.b d0,(a1)
 nop
 move.b d1,(a1)
 pause 12
 move.b d1,(a0)
 nop
 move.b d0,(a0)
 pause 2
 rts

_ligne_230
 nop
 move.b d1,(a0)   
 nop
 move.b d0,(a0)   
 pause 89
 move.b d0,(a1)   
 nop
 move.b d1,(a1)  
 pause 13-1
 move.b d1,(a0)   
 nop 
 move.b d0,(a0)  
 pause 2
 rts

_ligne_54
 pause 42
 move.b d1,(a0)
 pause 42
 move.b d0,(a0)
 pause 31
 rts

_ligne_158
 pause 34
 move.b d0,(a1)
 pause 68
 move.b d1,(a1)
 pause 13
 rts

_ligne_184
 nop
 move.b d1,(a0)
 nop
 move.b d0,(a0)
 pause 28
 move.b d0,(a1)
 pause 68
 move.b d1,(a1)
 pause 13
 rts

convertion_table
 lea syncscro(pc),a0
 lea table_lignes(pc),a1
 moveq #127,d0
.bloc_suivant
 moveq #5,d1
.taille_suivante
 move.l (a0),d2
 add.l d2,d2
 add.l d2,d2
 move.l 0(a1,d2.w),(a0)+ 
 dbra d1,.taille_suivante
 lea 8(a0),a0
 dbra d0,.bloc_suivant  
 rts

table_lignes
 dc.l _ligne_160,_ligne_186,_ligne_204,_ligne_230
 dc.l _ligne_54,_ligne_158,_ligne_184

syncscro incbin data\syncscro.tbl

*****************************
*****************************
*****************************

 include data\fulldigi.s
  
 SECTION DATA

fondu_1      incbin data\palettes.dat
fondu_2      incbin data\sprites.pal
palette      incbin data\presente.pal
logo         incbin data\euphoria.gfx
joueurs      incbin data\players.gfx
manettes     incbin data\control.gfx
sprites      incbin data\sprites.gfx
fonte_16     incbin data\2bp16x16.fnt
fonte_8      incbin data\2bp8x8.fnt
zbong        incbin data\zbong.tbl
distort      incbin data\distort.tbl
texte_1      incbin data\scroll.txt
texte_2      incbin data\scroll2.txt
texte_3      incbin data\infos.txt
texte          incbin data\texte.txt
couleurs       incbin data\motif.dat
table_offset_y incbin data\deplace.tbl
table_deplace  incbin data\movement.tbl

 even
 
table_scrolling
 dc.l scrolling_1 
 dc.l scrolling_2 
 dc.l scrolling_3
 dc.l scrolling_4

ligne_couleur
 dcb.w 80,$007
 dc.w $017,$027,$037,$047,$057,$067,$077
 dc.w $177,$277,$377,$477,$577,$677,$777
 dc.w $776,$775,$774,$773,$772,$771,$770
 dc.w $670,$570,$470,$370,$270,$170,$070
 dc.w $061,$052,$043,$034,$025,$016,$007
 dcb.w 80,$007
 dc.w -1

rasters
 dcb.l 4,$7700770
rasters_player
 dcb.l 9,$0070500
 dcb.l 15,$7700770
 
rasters_change
 dcb.l  9,$00700007
 dcb.l 61,$06400640

raster_1 dc.w $033,$044,$055,$066,$077,$066,$055,$044,$033     
raster_2 dc.w $330,$440,$550,$660,$770,$660,$550,$440,$330     
raster_3 dc.w $303,$404,$505,$606,$707,$606,$505,$404,$303     

on_saute
 dc.w 230*0
 dc.w 230*2
 dc.w 230*3
 dc.w 230*4
 dc.w 230*5,230*5
 dc.w 230*6,230*6
 dc.w 230*7,230*7,230*7
 dc.w 230*8,230*8,230*8,230*8
 dc.w 230*9,230*9,230*9,230*9,230*9,230*9
 dc.w 230*8,230*8,230*8,230*8
 dc.w 230*7,230*7,230*7
 dc.w 230*6,230*6
 dc.w 230*5,230*5
 dc.w 230*4
 dc.w 230*3
 dc.w 230*2
 dc.w -1

superbe_degrade
 dc.w $700,$710,$720,$730,$740,$750,$760,$770
 dc.w $771,$772,$773,$774,$775,$776,$777
 dc.w $676,$575,$474,$373,$272,$171,$070
 dc.w $071,$072,$073,$074,$075,$076,$077
 dc.w $067,$057,$047,$037,$027,$017,$007
 dc.w $107,$207,$307,$407,$507,$607,$707
 dc.w $706,$705,$704,$703,$702,$701
 dc.w $700,$710,$720,$730,$740,$750,$760,$770
 dc.w -1

 SECTION BSS

even

debut_bss

palette_noire   ds.w 16

sauve_palette   ds.w 16

                ds.l 1
position_1      ds.l (112+4)*16/4
                ds.l 1
position_2      ds.l (112+4)*16/4
                ds.l 1
position_3      ds.l (112+4)*16/4
                ds.l 1
position_4      ds.l (112+4)*16/4
                ds.l 1

ecrans          ds.l 160000/4

offset          ds.l 1

;
fonds_y_ptr     ds.l 1
position_ptr    ds.l 1
;

buffer_texte    ds.l (11*8*8*7)/4+10000

                ds.l 2
buf_x15         ds.l (72*13*16)/4
fin_x15         ds.l 2

ecran           ds.l 1

;
lettre_lue      ds.l 1
pos_scroll      ds.l 1
cpt_scroll      ds.l 1
pos_1           ds.l 1
pos_2           ds.l 1
pos_3           ds.l 1
pos_4           ds.l 1
pos_xxx         ds.l 1
;

;
pos_zbong       ds.l 1
old_zbong       ds.l 1
pos_distort     ds.l 1
;

;
acontroler_1    ds.l 1
acontroler_2    ds.l 1
controler_1     ds.l 1
controler_2     ds.l 1
;

;
flag_sortie     ds.w 1
flag_exit       ds.w 1
fondu_1_ptr     ds.l 1
fondu_2_ptr     ds.l 1
;

;
ligne_ptr_1     ds.l 1
ligne_ptr_2     ds.l 1
;

;
joueur_stade_1  ds.w 1
joueur_stade_2  ds.w 1
joueur_flag_1   ds.w 1
joueur_flag_2   ds.w 1
joueur_1_ecran  ds.l 1
joueur_2_ecran  ds.l 1
joueur_1_ptr    ds.l 1
joueur_2_ptr    ds.l 1
joueur_1        ds.w 1
joueur_2        ds.w 1
sprite_1        ds.l 1
sprite_2        ds.l 1
;

;
raster_ptr_1    ds.l 1
raster_ptr_2    ds.l 1
;
 
 even

pos_texte_2       ds.l 1
adresse_texte_2   ds.l 1
x_texte           ds.l 1
y_texte           ds.l 1
z_texte           ds.l 1
buffer_flag       ds.l 1
buffer_pos        ds.l 1
y_buffer          ds.l 1
ecran_pos         ds.l 1

wait              ds.l 1
wait_2            ds.l 1

sauve_70        ds.l 1
sauve_134       ds.l 1
sauve_sp        ds.l 1
sauve_usp       ds.l 1
sauve_a7        ds.l 1

                ds.l 50
ma_pile         ds.l 1

sauve_rez       ds.b 1
sauve_iera      ds.b 1
sauve_ierb      ds.b 1
sauve_isra      ds.b 1
sauve_isrb      ds.b 1
sauve_imra      ds.b 1
sauve_imrb      ds.b 1
sauve_8201      ds.b 1
sauve_8203      ds.b 1
sauve_vr        ds.b 1
sauve_tacr      ds.b 1
sauve_tadr      ds.b 1

fin_bss           ds.l 2
 
 end
