finale=0
fast=0
n_ligne=8
n_car=28
;
;  Ze Mega Strange Plasma...
;                     ...Some of Us call It ze Unnamed Effect ! 
;
;    Devenu: Le main menu r‚sident !!! (Waouhhh... !!!)
;
;                    (c) 1991,92 Dbug II
;

 ifne finale
bgt
ligne_point‚e  = ($600+12)   * 2    ---> #4.w
txt_pos        = ($600+12+2) * 4    ---> #-1.l
code_retour    = ($600+12+6) * 4
 org $5000
 endc

 opt o+,w-
 
 ifne fast
pause macro
 dcb.w \1,$4e71
 endm
 elseif
pause macro
t6 set (\1)/6
t5 set (\1-t6*6)/5
t4 set (\1-t6*6-t5*5)/4
t3 set (\1-t6*6-t5*5-t4*4)/3
t2 set (\1-t6*6-t5*5-t4*4-t3*3)/2
t1 set (\1-t6*6-t5*5-t4*4-t3*3-t2*2)
 dcb.w t6,$e188
 dcb.w t5,$ed88
 dcb.w t4,$e988  ; 
 dcb.w t3,$1090  ; move.b (a0),(a0)
 dcb.w t2,$8080  ; move.b d0,d0
 dcb.w t1,$4e71  ; nop
 endm
 endc
 
attend macro
t set \1
t set t-6
b set t/3
n set t-(b*3)
 move.w #b,d7
.boucle_tempo
 dbra d7,.boucle_tempo
 pause n
 endm

 opt o+,w-

 ifeq finale
 pea programme_principal
 move.w #$26,-(sp)
 trap #14
 addq #6,sp
 clr.w -(sp)
 trap #1
 elseif
 bsr programme_principal
 move.l code_retour,a0
 moveq #0,d0
 move.b (a0),d0
 rts
 endc
; dc.b "Tu peux pocker ici, si cela t'amuse !"
; dc.b "- ½2 Dbug II -"
 even



 
programme_principal
 move.w #$2700,sr
 bra efface_bss
retourne_la_ou_il_le_faut_sale_con
 move.l sp,sauve_ssp
 move.l usp,a0
 move.l a0,sauve_usp
 lea ma_pile,sp

;
; Sauvegardes diverses
; 
 lea $ffff8201.w,a0
 movep.w (a0),d0
 move.w d0,sauve_ecran
 movem.l $ffff8240.w,d0-d7
 movem.l d0-d7,sauve_palette
 move.b $fffffa13.w,sauve_imra
 move.b $fffffa15.w,sauve_imrb
 move.b $ffff8260.w,sauve_rez
 clr.b $fffffa13.w
 clr.b $fffffa15.w
 clr.b $ffff8260.w
 move.b #2,$ffff820a.w
 move.l $70.w,sauve_70
 move.l #routine_vbl,$70.w
;
; Quelques inits
; 
 move.l #table_distort,distort_ptr
 move.l #table_rebond,rebond_ptr
 st x_sens
 clr.l x_pos
 move.l #ecrans,txt_old
 ifeq finale
   move.l #-1,txt_pos
   move.w #4,ligne_point‚e
 endc
 tst.l txt_pos
 bpl.s .pas_la_premiŠre_fois 
 move.l #message+n_car+(n_car+1)*4,code_retour
 clr.l txt_pos
.pas_la_premiŠre_fois
 bsr affiche_logo
 bsr convertion_table
 bsr prepare_palettes
 bsr prepare_message
 bsr genere_code
 moveq #1,d0
 bsr musique
 move.w #$2300,sr

 opt o-
  
boucle_attente
 stop #$2300
;
; On affiche le message
;
 move.l txt_old,a6        ; 5
 lea buffer_message,a0    ; 3
 add.l txt_pos,a0         ; 5
 jsr routine_affiche      ; 5+4+(896*4)=3606

 attend 4288-3606  *-2703
;
; Avant tout, un border haut
;
 lea $ffff8260.w,a0
 lea $ffff820a.w,a1
 lea $ffff8240.w,a2

 moveq #0,d0
 move.b d0,(a1)
 pause 18
 moveq #2,d1
 move.b d1,(a1)

*
.sync
 move.b $ffff8209.w,d2
 beq.s .sync
 moveq #16,d3
 sub.w d2,d3
 lsl.w d3,d3
*
* 91 nops libres apres la syncro ecran
*
 pause 90
_auto_modif
 rept 6
 jsr _ligne_230
 endr
;
; Et un petit liseret !
;
 bsr liseret
 pause 50
;
; On charge les couleurs !
;
 lea palettes_plasma2,a1
 lea adresse_routines,a4
 move.l distort_ptr,a3

 moveq #121-1,d7
affiche_ligne_suivante
 exg d7,a6           ; 2
 move.w (a3)+,d1
 move.l (a4,d1.w),a5
 movem.w (a1)+,d1-d7 ; 12+4*7=12+28=40/  10 nops
 pause 4
 jsr (a5)
 exg a6,d7        ; 2
 dbra d7,affiche_ligne_suivante   ; 3
 pause 35
  
 pause 10
 bsr liseret
 pause 123
 clr.w (a2)
;
; Ici on fait des choses...
;
 lea $ffff820a.w,a1
 moveq #2,d1
 moveq #86-1,d2
*
 lea buffer_palettes_1,a3
 lea buffer_palettes_2,a5
 pause 6-3-3
 move.b d1,(a0)   
 nop
 move.b d0,(a0)   
 pause 49
*
boucle_full
 pause 40
 move.b d0,(a1)   
 move.b d1,(a1)  
 pause 13-2
 lea $ffff8240.w,a4
 move.b d1,(a0)   
 nop 
 move.b d0,(a0)  
 move.l (a3)+,(a4)+
 move.l (a3)+,(a4)+
 pause 12-10
 move.b d1,(a0)   
 nop
 move.b d0,(a0)   
 move.l (a3)+,(a4)+
 move.l (a3)+,(a4)+
 move.l (a5)+,(a4)+
 move.l (a5)+,(a4)+
 move.l (a5)+,(a4)+
 move.l (a5)+,(a4)+
 pause 49-30-3
 dbra d2,boucle_full
;
; On termine la ligne
;
 pause 36
 move.b d0,(a1)   
 move.b d1,(a1)  
 pause 13
 move.b d1,(a0)   
 nop 
 move.b d0,(a0)  
;
; Et un petit liseret !
;
 bsr liseret
 attend 120-1
;
; On re-charge les couleurs !
;
 move.l txt_old,a0     ; 5
 lea palettes_plasma,a1
 lea adresse_routines,a4
 move.l distort_ptr,a3

 moveq #99,d7
 jsr routine_efface
dernier
 attend 50
 bsr liseret
 clr.w (a2)

 opt o+

 move.l distort_ptr,a3
 lea 2(a3),a3
 tst.w 200*2(a3)
 bpl.s .ok
 lea table_distort,a3
.ok  
 move.l a3,distort_ptr
;
; Calcul des trajectoires
;
 bsr calcule_hard
 bsr musique+14
**********
 tst.b compteur_options
 beq.s pas_de_scroll
 move.l flag_options,d0
 add.l d0,txt_pos
 subq.b #1,compteur_options
pas_de_scroll

*
 move.b $fffffc02.w,d0
* cmp.b #$39,d0
* beq.s validation
 cmp.b #$1c,d0
 beq.s validation
 cmp.b #$72,d0
 beq.s validation
 bra.s pas_validation
validation
 move.l code_retour,a0
 cmp.b #-1,(a0)
 bne.s sort_boucle_attente
pas_validation
*
 tst.b compteur_options
 bne scroll_pas_fini  
 cmpi.b #$48,d0
 bne.s pas_haut
 tst.w ligne_point‚e
 beq.s pas_haut
 move.l #-n_car,flag_options
 move.b #8,compteur_options
 subq.w #1,ligne_point‚e
 sub.l #n_car+1,code_retour
pas_haut 
 cmpi.b #$50,d0
 bne.s pas_bas
 cmp.w #(longueur_message/n_car-4),ligne_point‚e
 bge.s pas_bas
 move.l #n_car,flag_options
 move.b #8,compteur_options
 addq.w #1,ligne_point‚e
 add.l #n_car+1,code_retour
pas_bas 
scroll_pas_fini
*
 bra boucle_attente

sort_boucle_attente
 move.w #$2700,sr 
 move.l sauve_70,$70.w
 move.b sauve_imra,$fffffa13.w
 move.b sauve_imrb,$fffffa15.w
 move.w sauve_ecran,d0
 lea $ffff8201.w,a0
 movep.w d0,(a0)
 move.b sauve_rez,$ffff8260.w
 movem.l sauve_palette,d0-d7
 movem.l d0-d7,$ffff8240.w
 move.l #$08000000,$ffff8800.w
 move.l #$09000000,$ffff8800.w
 move.l #$0a000000,$ffff8800.w
 move.l sauve_ssp,sp
 move.l sauve_usp,a0
 move.l a0,usp
 move.w #$2300,sr
 rts 

****************************************
*                                      *
* Ici se trouve la programme principal *
*                                      *
****************************************

 opt o-
 
routine_vbl
 rte

liseret
 move.w #$111,(a2)  ; 3
 attend 125
l2
 move.w #$222,(a2)  ; 3
 attend 125
l3
 move.w #$333,(a2)  ; 3
 attend 125
l4
 move.w #$444,(a2)  ; 3
 attend 125
l5
 move.w #$333,(a2)  ; 3
 attend 125
 move.w #$222,(a2)  ; 3
l6
 attend 125
 move.w #$111,(a2)  ; 3
 rts

; Codage du : move.w dx,(a2)
;           : $308x  ($3080-$3087)
;
routine_0
 nop
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d1,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 rts
 
routine_1
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d1,(a2)
 move.w d1,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 nop
 rts
 
routine_2
 nop
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d1,(a2)
 move.w d2,(a2)
 move.w d1,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 rts
 
routine_3
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d1,(a2)
 move.w d2,(a2)
 move.w d2,(a2)
 move.w d1,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 nop
 rts
 
routine_4
 nop
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d1,(a2)
 move.w d2,(a2)
 move.w d3,(a2)
 move.w d2,(a2)
 move.w d1,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 rts
 
routine_5
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d1,(a2)
 move.w d2,(a2)
 move.w d3,(a2)
 move.w d3,(a2)
 move.w d2,(a2)
 move.w d1,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 nop
 rts
 
routine_6
 nop
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d1,(a2)
 move.w d2,(a2)
 move.w d3,(a2)
 move.w d4,(a2)
 move.w d3,(a2)
 move.w d2,(a2)
 move.w d1,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 rts
 
routine_7
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)				
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d1,(a2)
 move.w d2,(a2)
 move.w d3,(a2)
 move.w d4,(a2)
 move.w d4,(a2)
 move.w d3,(a2)
 move.w d2,(a2)
 move.w d1,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 nop
 rts
 
routine_8
 nop
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d1,(a2)
 move.w d2,(a2)
 move.w d3,(a2)
 move.w d4,(a2)
 move.w d5,(a2)
 move.w d4,(a2)
 move.w d3,(a2)
 move.w d2,(a2)
 move.w d1,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 rts
 
routine_9
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d1,(a2)
 move.w d2,(a2)
 move.w d3,(a2)
 move.w d4,(a2)
 move.w d5,(a2)
 move.w d5,(a2)
 move.w d4,(a2)
 move.w d3,(a2)
 move.w d2,(a2)
 move.w d1,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 nop
 rts
 
routine_10
 nop
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d1,(a2)
 move.w d2,(a2)
 move.w d3,(a2)
 move.w d4,(a2)
 move.w d5,(a2)
 move.w d6,(a2)
 move.w d5,(a2)
 move.w d4,(a2)
 move.w d3,(a2)
 move.w d2,(a2)
 move.w d1,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 rts
 
routine_11
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d1,(a2)
 move.w d2,(a2)
 move.w d3,(a2)
 move.w d4,(a2)
 move.w d5,(a2)
 move.w d6,(a2)
 move.w d6,(a2)
 move.w d5,(a2)
 move.w d4,(a2)
 move.w d3,(a2)
 move.w d2,(a2)
 move.w d1,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 nop
 rts
 
routine_12
 nop
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d1,(a2)
 move.w d2,(a2)
 move.w d3,(a2)
 move.w d4,(a2)
 move.w d5,(a2)
 move.w d6,(a2)
 move.w d7,(a2)
 move.w d6,(a2)
 move.w d5,(a2)
 move.w d4,(a2)
 move.w d3,(a2)
 move.w d2,(a2)
 move.w d1,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 rts
 
routine_13
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d1,(a2)
 move.w d2,(a2)
 move.w d3,(a2)
 move.w d4,(a2)
 move.w d5,(a2)
 move.w d6,(a2)
 move.w d7,(a2)
 move.w d7,(a2)
 move.w d6,(a2)
 move.w d5,(a2)
 move.w d4,(a2)
 move.w d3,(a2)
 move.w d2,(a2)
 move.w d1,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 nop
 rts
 
routine_14
 nop
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d1,(a2)
 move.w d2,(a2)
 move.w d3,(a2)
 move.w d4,(a2)
 move.w d5,(a2)
 move.w d6,(a2)
 move.w d7,(a2)
 move.w d7,(a2)
 move.w d7,(a2)
 move.w d6,(a2)
 move.w d5,(a2)
 move.w d4,(a2)
 move.w d3,(a2)
 move.w d2,(a2)
 move.w d1,(a2)
 move.w d0,(a2)
 move.w d0,(a2)
 rts
 
routine_15
 move.w d0,(a2)
 move.w d0,(a2)
 move.w d1,(a2)
 move.w d2,(a2)
 move.w d3,(a2)
 move.w d4,(a2)
 move.w d5,(a2)
 move.w d6,(a2)
 move.w d7,(a2)
 move.w d7,(a2)
 move.w d7,(a2)
 move.w d7,(a2)
 move.w d6,(a2)
 move.w d5,(a2)
 move.w d4,(a2)
 move.w d3,(a2)
 move.w d2,(a2)
 move.w d1,(a2)
 move.w d0,(a2)
 nop
 rts
 
routine_16
 nop
 move.w d0,(a2)
 move.w d1,(a2)
 move.w d2,(a2)
 move.w d3,(a2)
 move.w d4,(a2)
 move.w d5,(a2)
 move.w d6,(a2)
 move.w d7,(a2)
 move.w d7,(a2)
 move.w d7,(a2)
 move.w d7,(a2)
 move.w d7,(a2)
 move.w d6,(a2)
 move.w d5,(a2)
 move.w d4,(a2)
 move.w d3,(a2)
 move.w d2,(a2)
 move.w d1,(a2)
 move.w d0,(a2)
 rts

 opt o+

*****************************
*****************************
*****************************

calcule_hard
;
; Le vas et vient lat‚ral
;
 move.l x_pos,d0
 tst.b x_sens
 bne.s vers_gauche
vers_droite
 subq.l #2,d0
 bne.s fin_lat‚ral
 st x_sens
 bra fin_lat‚ral

vers_gauche
 addq.l #2,d0
 cmp.l #280,d0
 blt.s fin_lat‚ral
 sf x_sens

fin_lat‚ral
 move.l d0,x_pos
 move.l d0,d3
 and.l #15,d3
 lsr.l d3
 mulu #232*160,d3
  
 move.l d0,d2
 lsr.l d2
 and.b #%11111000,d2
 
;
; Le rebonds
; 
 moveq #0,d1
 move.l rebond_ptr,a0
 move.b (a0)+,d1
 bpl.s .pas_raz_rebond
 lea table_rebond,a0
 move.b (a0)+,d1
.pas_raz_rebond
 move.l a0,rebond_ptr
 mulu #230,d1
;
; Puis le hard lui-meme
;  
 move.l #ecrans,d0
 add.l #160,d0
 add.l d1,d0      Y
 add.l d2,d0      X
 add.l d3,d0
*
 move.l d0,a6     *********** Base ‚cran !!!
 add.l #160*137-230*20+40+6,a6
 move.l a6,txt_old
*
 moveq #0,d1
 move.b d0,d1

 lea syncscro,a0
 lsl.w #4,d1
 lea 0(a0,d1.w),a0

 lea _auto_modif+2,a1
 moveq #6-1,d1
change_code
 move.l (a0)+,(a1)
 addq.w #6,a1
 dbra d1,change_code

 moveq #0,d1
 move.w (a0)+,d1
 ext.l d1        ; Die Biggest Uperhauá™štsse Gammelle
 add.l d1,d0
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

 opt o-
 
_ligne_160
 attend 119
 rts

_ligne_186
 nop
 move.b d1,(a0)
 nop
 move.b d0,(a0)
 attend 113
 rts

_ligne_204
 attend 95
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
 attend 89
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
 attend 42
 move.b d1,(a0)
a1
 attend 42
 move.b d0,(a0)
a2
 attend 31
 rts

_ligne_158
 attend 34
 move.b d0,(a1)
a3 
 attend 68
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
 attend 68
 move.b d1,(a1)
 pause 13
 rts

 opt o+
 
convertion_table
 lea syncscro_2(pc),a0
 lea syncscro,a2
 lea table_lignes(pc),a1
 moveq #127,d0
.bloc_suivant
 move.b (a0)+,d3
 swap d3
 move.b (a0)+,d3
 lsl.w #8,d3
 move.b (a0)+,d3      ; L…, on … toutes les valeurs... (3 octets)

 moveq #5,d1
.taille_suivante
 moveq #0,d2
 moveq #2,d4
.bit_suivant
 roxr.l d3
 addx.b d2,d2
 dbra d4,.bit_suivant
 add.l d2,d2
 add.l d2,d2
 move.l 0(a1,d2.w),(a2)+ 
 dbra d1,.taille_suivante
;
 moveq #0,d2         ; Puis l'offset vid‚o sur 2 bits
 roxr.l d3
 addx.b d2,d2
 roxr.l d3
 addx.b d2,d2
 cmp.b #2,d2
 bne.s .pas_negatif
 moveq #-1,d2
.pas_negatif
 move.b d2,(a2)
;
 addq.w #8,a2
 dbra d0,.bloc_suivant  
 rts

table_lignes
 dc.l _ligne_160,_ligne_186,_ligne_204,_ligne_230
 dc.l _ligne_54,_ligne_158,_ligne_184

syncscro_2 incbin syncsco.pak

*****************************
*****************************
*****************************

prepare_palettes
 lea logo_palette,a0
 lea buffer_palettes_1,a1
 moveq #16-1,d0
.fade_in
 bsr recopie_couleurs
 lea 16(a0),a0
 dbra d0,.fade_in

 lea -32(a0),a0
 moveq #58-1,d0
.no_fade
 bsr recopie_couleurs
 lea -16(a0),a0
 dbra d0,.no_fade

 moveq #16-1,d0
.fade_out
 bsr recopie_couleurs
 lea -32-16(a0),a0
 dbra d0,.fade_out

suivant
 lea logo_palette+16,a0
 lea buffer_palettes_2+16*11,a1
 moveq #16-1,d0
.fade_in
 bsr recopie_couleurs
 lea 16(a0),a0
 dbra d0,.fade_in

 lea -32(a0),a0
 moveq #58-22-1,d0
.no_fade
 bsr recopie_couleurs
 lea -16(a0),a0
 dbra d0,.no_fade

 moveq #16-1,d0
.fade_out
 bsr recopie_couleurs
 lea -32-16(a0),a0
 dbra d0,.fade_out

znortrtert
 move.w #$301,buffer_palettes_1+16*43
 move.w #$301,buffer_palettes_1+16*(43+8)
 lea buffer_palettes_2+16*43,a2
 moveq #8*8-1,d0
.fade_in
 move.w #$567,(a2)+
 dbra d0,.fade_in
 rts

recopie_couleurs
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 rts

prepare_message  
 lea message,a0
 lea buffer_message,a1
 lea fonte-8,a2
 moveq #0,d1
.lettre_suivante
 move.b (a0)+,d0
 beq .fin_codage  
; On convertit la lettre
 move.l #fonte_conv,d2
 move.l d2,a3
.cherche_encore
 cmp.b (a3)+,d0
 bne.s .cherche_encore
 sub.l d2,a3
 move.l a3,d2
 lsl.w #3,d2
 lea (a2,d2.w),a3
; On ‚crit la lettre puis on incr‚mente les position
 moveq #8-1,d2
.ligne_suivante
 move.b (a3)+,0(a1,d1.w)
 lea n_car(a1),a1
 dbra d2,.ligne_suivante
 lea -n_car*8(a1),a1
 addq.b #1,d1 
 cmp.b #n_car,d1
 blt.s .lettre_suivante
 moveq #0,d1
 lea n_car*8(a1),a1
 addq.w #1,a0
 bra.s .lettre_suivante
.fin_codage
 rts
 
******************
******************

x_offset=-32+128

affiche_logo
 lea ecrans,a2
 lea 160*167+x_offset(a2),a2
 moveq #8-1,d7
.logo_suivant
 lea logo_next,a0
 move.l a2,a1
 add.l #232*160,a2
 moveq #35-1,d6
.ligne_suivante 
 moveq #72/8-1,d5
.mot_suivant 
 move.l (a0)+,(a1)+
 move.w (a0)+,(a1)+
 clr.w (a1)+
 dbra d5,.mot_suivant
 lea 230-72(a1),a1
 dbra d6,.ligne_suivante
 dbra d7,.logo_suivant
  
predecalle_logo
 moveq #14,d5
 lea ecrans,a2
 add.l #160*167+34*230+72+8+x_offset,a2
.bloc_suivant
 move.l a2,a0
 add.l #232*160,a2
 move.l d5,d3
 moveq #16,d0
 sub.l d3,d0

 moveq #35-1,d6
.ligne_suivante
 move.w #(88/2)-1,d1
.predecalle_ligne
 move.w (a0),d4
 move.w -8(a0),d2
 lsr.w d3,d4        ; decalle de D3 rotations
 lsl.w d0,d2
 add.w d2,d4
 move.w d4,(a0)
 subq.l #2,a0
 dbra d1,.predecalle_ligne
 lea -(230-88)(a0),a0
 dbra d6,.ligne_suivante

 subq.w #2,d5
 bpl.s .bloc_suivant
 rts
 
**********************
nb_instructions=10

genere_code 
 movem.l routine_type,d5-d7
 lea routine_efface,a0
 lea routine_affiche,a1
 move.w #896-1,d0
 moveq #0,d1
 moveq #0,d2
 moveq #nb_instructions,d3
.instruction_suivante 
 move.w #$3140,(a0)+
 move.w #$3d58,(a1)+
 move.w d1,(a0)
 move.w d1,(a1)
 add.w d2,(a0)+
 add.w d2,(a1)+
 addq.b #8,d1
 cmp.b #104,d1
 ble.s .pas_fini
 moveq #0,d1
 add.w #230,d2
.pas_fini
 sub.b #1,d3
 bne.s .pas_9_pass‚s
 moveq #nb_instructions,d3
 movem.l d5-d7,(a0)
 lea 12(a0),a0
.pas_9_pass‚s
 dbra d0,.instruction_suivante
 move.w #$4e75,(a0)
 move.w #$4e75,(a1)
 rts

routine_type
 move.w (a3)+,d1
 move.l (a4,d1.w),a5
 movem.w (a1)+,d1-d7
 jsr (a5)
 
efface_bss 
 lea debut_bss,a0
 lea fin_bss,a1
efface_suivant
 clr.l (a0)+
 cmpa.l a1,a0
 bmi.s efface_suivant
 bra retourne_la_ou_il_le_faut_sale_con

 SECTION DATA

logo_next     incbin logonext.gfx
logo_palette  incbin logonext.pal
fonte         incbin 8x8.fnt
table_rebond  incbin rebond.tbl
 even
 
musique       incbin mi*.snd
 even

palettes_plasma
 rept 9
 dc.w $001,$002,$003,$004,$005,$006,$007 ; Bleu
 dc.w $001,$002,$003,$014,$015,$016,$017
 dc.w $001,$012,$013,$024,$025,$026,$027
 dc.w $001,$012,$013,$024,$035,$036,$037
 dc.w $011,$012,$023,$034,$045,$046,$047
 dc.w $011,$022,$023,$034,$045,$056,$057
 dc.w $011,$022,$033,$044,$055,$066,$067

 dc.w $011,$022,$023,$034,$045,$056,$057
 dc.w $011,$012,$023,$034,$045,$046,$047
 dc.w $001,$012,$013,$024,$035,$036,$037
 dc.w $001,$012,$013,$024,$025,$026,$027
 dc.w $001,$002,$003,$014,$015,$016,$017
 endr

palettes_plasma2
 rept 3
 dc.w $010,$020,$030,$040,$050,$060,$070 ; Vert
 dc.w $010,$020,$030,$140,$150,$160,$170
 dc.w $010,$120,$130,$240,$250,$260,$270
 dc.w $010,$120,$130,$240,$350,$360,$370
 dc.w $110,$120,$230,$340,$450,$360,$470
 dc.w $110,$220,$230,$340,$450,$460,$570
 dc.w $110,$220,$330,$440,$550,$560,$670

 dc.w $110,$220,$330,$440,$550,$660,$770 ; Jaune
 dc.w $110,$220,$330,$440,$550,$660,$760
 dc.w $110,$220,$320,$430,$540,$650,$750
 dc.w $110,$210,$320,$430,$540,$640,$740
 dc.w $100,$210,$310,$420,$530,$630,$730
 dc.w $100,$210,$310,$420,$520,$620,$720
 dc.w $100,$200,$300,$410,$510,$610,$710

 dc.w $100,$200,$300,$400,$500,$600,$700 ; Rouge
 dc.w $100,$200,$301,$401,$501,$601,$701
 dc.w $100,$201,$301,$402,$502,$602,$702
 dc.w $100,$201,$302,$402,$503,$603,$703
 dc.w $101,$201,$302,$403,$504,$604,$704
 dc.w $101,$202,$303,$403,$504,$605,$705
 dc.w $101,$202,$303,$404,$505,$606,$706

 dc.w $101,$202,$303,$404,$505,$606,$707 ; Violet
 dc.w $101,$202,$303,$404,$505,$606,$607
 dc.w $101,$202,$203,$304,$405,$506,$507
 dc.w $101,$102,$203,$304,$405,$406,$407
 dc.w $001,$102,$103,$204,$305,$306,$307
 dc.w $001,$102,$103,$204,$205,$206,$207
 dc.w $001,$002,$003,$104,$105,$106,$107

 dc.w $001,$002,$003,$004,$005,$006,$007 ; Bleu
 dc.w $001,$002,$003,$014,$015,$016,$017
 dc.w $001,$012,$013,$024,$025,$026,$027
 dc.w $001,$012,$013,$024,$035,$036,$037
 dc.w $011,$012,$023,$034,$045,$046,$047
 dc.w $011,$022,$023,$034,$045,$056,$057
 dc.w $011,$022,$033,$044,$055,$066,$067

 dc.w $011,$022,$033,$044,$055,$066,$077 ; Ciel
 dc.w $011,$022,$033,$044,$055,$066,$076
 dc.w $011,$022,$032,$043,$054,$065,$075
 dc.w $011,$021,$032,$043,$054,$064,$074
 dc.w $010,$021,$031,$042,$053,$063,$073
 dc.w $010,$021,$031,$042,$052,$062,$072
 dc.w $010,$020,$030,$041,$051,$061,$071
 endr
  
table_distort incbin distort.tbl
var set 0
 rept 17
 dc.w var*4
 dc.w var*4
var set var+1
 endr
 rept 50
 dc.w 15*4,16*4
 endr
 rept 17
var set var-1
 dc.w var*4
 endr
 dcb.w 200,0
    
adresse_routines
 dc.l routine_0
 dc.l routine_1
 dc.l routine_2
 dc.l routine_3
 dc.l routine_4
 dc.l routine_5
 dc.l routine_6
 dc.l routine_7
 dc.l routine_8
 dc.l routine_9
 dc.l routine_10
 dc.l routine_11
 dc.l routine_12
 dc.l routine_13
 dc.l routine_14
 dc.l routine_15
 dc.l routine_16

; **  **  *    *  *
; *    *  **  **  *  **
;
fonte_conv
 dc.b "ABCDEFGHIJKLMNOPQRSTUVWXYZ?½!., 0123456789-:@/\[]|_()'"

 even
  
message
 DC.B "                            ",-1
 DC.B "/__________________________\",-1
 DC.B "|                          |",-1
 DC.B "|  AND  TO SELECT SCREEN |",-1
 DC.B "|  AND RETURN TO VALIDATE  |",-1
 DC.B "|                          |",-1
 DC.B "[__________________________]",-1
 DC.B "                            ",-1
 DC.B "  -----  FIRST DISK  -----  ",-1
 DC.B " NEXT (ULTIMATE LAMER TEST) ",34
 DC.B "                            ",-1
 DC.B "  ----- SECOND  DISK -----  ",-1
 DC.B " ACF DESIGN TEAM            ",1
 DC.B " AGGRESSION                 ",2
 DC.B " CHAOTIC MOTION (FULLTRACK) ",3
 DC.B " CHAOTIC MOTION (INTERFER)  ",4
 DC.B " DELTA FORCE                ",5
 DC.B " FUTUR MINDS                ",6
 DC.B " FRAGGLE'S                  ",7
 DC.B " THE HEMOROIDS              ",8
 DC.B " LEGACY                     ",9
 DC.B " MEGABUSTERS                ",10
 DC.B " MJJ PROD                   ",11
 DC.B " MYSTIC                     ",12
 DC.B " NAOS                       ",13
 DC.B " NEWLINE                    ",14
 DC.B " NEW SYSTEM                 ",15
 DC.B " THE CAREBEARS              ",16
 DC.B " THE CORPORATION            ",17
 DC.B "                            ",-1
 DC.B "   ----- THIRD DISK -----   ",-1
 DC.B " THE STORM BROTHERS         ",18
 DC.B " AENIGMATICA                ",19
 DC.B " CHAOTIC MOTION (BOOTMAKER) ",20
 DC.B " DNT CREW                   ",21
 DC.B " FIREHAWKS                  ",22
 DC.B " FOXX                       ",23
 DC.B " NEXT (FULLBALL)            ",24
 DC.B " KROM                       ",25
 DC.B " NEXT (LEM,RSI CONVERSION)  ",26
 DC.B " NIGHT FORCE                ",27
 DC.B " THE NERVE CENTER (2 PARTS) ",28
 DC.B "                            ",-1
 DC.B "  ----- FOURTH DISK -----   ",-1
 DC.B " EXPOSE SOFTWARE - PREVIEWS ",29
 DC.B " NEXT (BUDNEXT)             ",30
 DC.B " LONEWOLF (MINES)           ",31
 DC.B " THE NERVE CENTER (3D DOTS) ",32
 DC.B " NEXT (ILLUSION)            ",33
 DC.B "                            ",-1
 DC.B "/__________________________\",-1
 DC.B "|                          |",-1
 DC.B "|        THIS MENU:        |",-1
 DC.B "|                          |",-1
 DC.B "| ORIGINAL IDEA, CODE AND  |",-1
 DC.B "|  DESIGN BY - DBUG II -   |",-1
 DC.B "|                          |",-1
 DC.B "|  NEXT LOGO WAS DRAWN BY  |",-1
 DC.B "|       - PULSAR -         |",-1
 DC.B "|                          |",-1
 DC.B "|   THIS LITTLE FONT BY    |",-1
 DC.B "|       - CHROMIX -        |",-1
 DC.B "|   FROM AN ORIGINAL BY    |",-1
 DC.B "|     - ANDI INGRAM -      |",-1
 DC.B "|    USED IN 'LEANDER'     |",-1
 DC.B "|                          |",-1
 DC.B "|  THE NICE TUNE COMPOSED  |",-1
 DC.B "|  BY - DAVID WHITTAKER -  |",-1 
 DC.B "|                          |",-1
 DC.B "|  AND LAST BUT NOT LEAST  |",-1
 DC.B "|  SOME AESTHETIC ADVICES  |",-1
 DC.B "| BY THE GUY WHO HAS CODED |",-1
 DC.B "| THE 'MINE SWEEPER' GAME. |",-1
 DC.B "| (SOME CALL HIM LONEWOLF) |",-1
 DC.B "|                          |",-1
 DC.B "[__________________________]",-1
 DC.B "                            ",-1
fin_message
 DC.B 0

longueur_message equ fin_message-message

 SECTION BSS

 even
mit
debut_bss

palette_noire ds.l 32

sauve_usp     ds.l 1
sauve_ssp     ds.l 1
sauve_a7      ds.l 1
sauve_70      ds.l 1
sauve_ecran   ds.w 1

              ds.l 200
ma_pile       ds.l 1

sauve_rez     ds.b 1
sauve_imra    ds.b 1
sauve_imrb    ds.b 1

 even

sauve_palette     ds.w 16

routine_efface    ds.l (3588+(896/nb_instructions+1)*12)/4
routine_affiche   ds.l 3588/4
ecrans            ds.l (43900*8)/4
buffer_message    ds.l longueur_message*8
buffer_palettes_1 ds.l 4*86
buffer_palettes_2 ds.l 4*86
syncscro          ds.l 4096/4

distort_ptr       ds.l 1

rebond_ptr        ds.l 1
x_pos             ds.l 1
x_sens            ds.w 1

txt_old           ds.l 1
txt_cpt           ds.l 1

 ifeq finale
ligne_point‚e     ds.w 1
txt_pos           ds.l 1
code_retour       ds.l 1
 endc
 
flag_options      ds.l 1
compteur_options  ds.w 1
 
fin_bss           ds.b 4
 end