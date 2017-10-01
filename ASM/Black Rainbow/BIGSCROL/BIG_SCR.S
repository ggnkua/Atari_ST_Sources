; **************
;
; INITIALISATION
;
; **************

           opt o+

; --- Mode superviseur ---

           clr.l -(sp)
           move.w #$20,-(sp)
           trap #1
           addq.l #6,sp
           move.l d0,oldssp

; --- Sauve et supprime clavier ---

           move.b $484,key
           clr.b $484

; --- Supprime souris ---
 
           pea stop_mouse
           move.w #0,-(sp)
           move.w #$19,-(sp)
           trap #14
           addq.l #8,sp

; --- Sauve palette couleurs ---

           move.l #$ffff8240,a0
           lea oldpal,a1
           movem.l (a0)+,d0-d7
           movem.l d0-d7,(a1)

; --- Installe nouvelle palette ---

          pea new_pal
          move.w #6,-(sp)
          trap #14
          addq.l #6,sp
            
; --- Sauve resolution ---

           move.w #4,-(sp)
           trap #14
           addq.l #2,sp 
           move.w d0,oldrez

; --- Sauve adresse ecran ---

           move.w #2,-(sp)
           trap #14
           addq.l #2,sp
           move.l d0,oldscreen

; --- Cree deux ecrans --- 

           move.l #$70000,screen1
           move.l #$77d00,screen2

; --- Change resolution et ecrans ---

           clr.w -(sp)
           move.l screen1,-(sp)
           move.l screen2,-(sp)
           move.w #5,-(sp)
           trap #14
           add.l #12,sp

; --- Efface les deux ecrans ---

           move.l screen1,a0
           move.l screen2,a1
           move.w #9599,d0
boucle1    clr.l (a0)+
           clr.l (a1)+
           dbra d0,boucle1

; --- Init musique ---
; -> a oter sur Falcon 030
;          moveq #1,d0
;          bsr music
           
; ************************
;
; INITIALISATIONS DIVERSES
;
; ************************

           move.l #space,adr_deb
           lea space+168,a0
           move.l a0,adr_fin
           lea txt,a0
           sub.l #1,a0
           move.l a0,adr_txt

; --- Init timers et synchro ---

           move.b $fffa07,save_iera
           move.b $fffa09,save_ierb
           move.b $fffa13,save_imra
           move.b $fffa11,save_isrb
           move.b $fffa17,save_vect

           move.l $70,save_vbl
           move.l $120,save_hbl
           move.l $118,save_118

           and.b #0,$fffa07
           and.b #$40,$fffa09
           bclr.b #3,$fffa17
           or.b #1,$fffa07
           or.b #1,$fffa13
           move.l #vbl,$70           
           move.l #newkey,$118

; ***************** 
;
; BOUCLE PRINCIPALE
;
; *****************


loop       cmp.b #$39,$ffffc02
           bne.s loop

; ****************
;
; FIN DU PROGRAMME
;
; ****************


; --- Restore timers ---

           clr.b $ffffa1b
           move.b save_iera,$ffffa07
           move.b save_ierb,$ffffa09
           move.b save_imra,$ffffa13
           move.b save_isrb,$ffffa11
           move.b save_vect,$ffffa17
           move.l save_vbl,$70
           move.l save_hbl,$120
           move.l save_118,$118
           
; --- Chip sonore ---

           move.b #8,$ff8800
           move.b #0,$ff8802
           move.b #9,$ff8800
           move.b #0,$ff8802
           move.b #$a,$ff8800
           move.b #0,$ff8802

; --- Ancienne resolution et ecrans ---
        
           move.w oldrez,-(sp)
           move.l oldscreen,-(sp)
           move.l oldscreen,-(sp)
           move.w #5,-(sp)
           trap #14
           add.l #12,sp

; --- Ancienne palette ---
          
           lea oldpal,a0
           move.l #$ffff8240,a1
           movem.l (a0)+,d0-d7
           movem.l d0-d7,(a1)

; --- Retablit la souris ---
 
           pea go_mouse(pc)
           move.w #0,-(sp)
           move.w #$19,-(sp)
           trap #14
           addq.l #8,sp

; --- Retablit le clavier ---

           move.b key,$484

; --- Retour en mode USER ---

           move.l oldssp,-(sp)
           move.w #$20,-(sp)
           trap #1
           addq.l #6,sp

; --- Retour au DOS ---

           clr.w -(sp)
           trap #1


; *********
;
; PROGRAMME
;
; *********


vbl        cmp.b #$0f,$ffffc02
           bne.s pas_time
           move.w #$777,$ffff8240

pas_time   clr.b $ffffa1b
           move.b #2,$ffffa21
         
           lea rasters,a1
           move.w (a1),fst_col
           lea rasters+2,a0
           movem.l (a0)+,d0-d7/a2-a6
           movem.l d0-d7/a2-a6,(a1)
           lea 52(a1),a1
           movem.l (a0)+,d0-d7/a2-a6
           movem.l d0-d7/a2-a6,(a1)
           lea 52(a1),a1           
           movem.l (a0)+,d0-d7/a2-a6
           movem.l d0-d7/a2-a6,(a1)
           lea 52(a1),a1
           movem.l (a0)+,d0-d7/a2
           movem.l d0-d7/a2,(a1)
           lea 36(a1),a1
           move.w (a0),(a1)+
           move.w fst_col,(a1)

           lea rasters,a3
           clr.w conte
           move.l #hbl1,$120
           move.b #8,$ffffa1b
         
; --------------------------------------------------------------
;
;                MUSIQUE & LEDS DES LECTEURS 
;
; --------------------------------------------------------------

           move.l a3,-(sp)
;           bsr music+8
           move.l (sp)+,a3

           lea $ffff8800,a0
           move.b #8,(a0)
           move.b (a0),d0

           cmpi.b #14,d0
           blt.s led_off

led_on     move.b #14,(a0)
           move.b (a0),d0
           andi.b #$f9,d0
           move.b d0,2(a0)
           bra.s bas

led_off    move.b #14,(a0)
           move.b (a0),d0
           ori.b #6,d0
           move.b d0,2(a0)

; --------------------------------------------------------------
;
;                     LOGO 'BLACK RAINBOW'
;
; --------------------------------------------------------------

bas        tst.w sens
           bne.s haut
           add.w #320,decal
           cmp.w #156*160,decal      
           bne.s aff_log
           move.w #1,sens
           bra.s aff_log

haut       sub.w #320,decal
           tst.w decal
           bne.s aff_log
           clr.w sens
           
aff_log    lea logo,a0
           move.l screen1,a1
           add.w decal,a1

n          set 0
           rept 42
           move.l n+2(a0),n+26(a1)
           move.w n+6(a0),n+30(a1)
           move.l n+10(a0),n+34(a1)
           move.w n+14(a0),n+38(a1)
           move.l n+18(a0),n+42(a1)
           move.w n+22(a0),n+46(a1)
           move.l n+26(a0),n+50(a1)
           move.w n+30(a0),n+54(a1)
           move.l n+34(a0),n+58(a1)
           move.w n+38(a0),n+62(a1)
           move.l n+42(a0),n+66(a1)
           move.w n+46(a0),n+70(a1)
           move.l n+50(a0),n+74(a1)
           move.w n+54(a0),n+78(a1)
           move.l n+58(a0),n+82(a1)
           move.w n+62(a0),n+86(a1)
           move.l n+66(a0),n+90(a1)
           move.w n+70(a0),n+94(a1)
           move.l n+74(a0),n+98(a1)
           move.w n+78(a0),n+102(a1)
           move.l n+82(a0),n+106(a1)
           move.w n+86(a0),n+110(a1)
           move.l n+90(a0),n+114(a1)
           move.w n+94(a0),n+118(a1)
           move.l n+98(a0),n+122(a1)
           move.w n+102(a0),n+126(a1)
           move.l n+106(a0),n+130(a1)
           move.w n+110(a0),n+134(a1)
n          set n+160
           endr

; --------------------------------------------------------------
;
;                          SCROLLTEXT 
;
; --------------------------------------------------------------

           move.l adr_deb,a0
           move.l adr_fin,a1
           cmp.l a0,a1
           bne.s big

           add.l #1,adr_txt
           cmp.l #lettre,adr_txt
           bne.s suite
           move.l #txt,adr_txt

suite      lea calcul,a1
           lea lettre,a2
           moveq #0,d0
           move.l adr_txt,a0
           move.b (a0),d0
           add.w d0,d0
           move.w 0(a1,d0.w),d0
           add.w d0,a2
           move.l a2,adr_deb
           add.w #168,a2
           move.l a2,adr_fin
 
; --------------------------------------------------------------
;
;             'BIGSCROLL' (LETTRES DE 64*112 PIXELS)
;
; --------------------------------------------------------------

big        move.l screen1,a0
           move.l screen2,a1
           move.l adr_deb,a2

           moveq #6,d0
scroll     rept 28
           move.w 320+8(a0),320(a0)
           move.w 320+16(a0),320+8(a0)
           move.w 320+24(a0),320+16(a0)
           move.w 320+32(a0),320+24(a0)
           move.w 320+40(a0),320+32(a0)
           move.w 320+48(a0),320+40(a0)
           move.w 320+56(a0),320+48(a0)
           move.w 320+64(a0),320+56(a0)
           move.w 320+72(a0),320+64(a0)
           move.w 320+80(a0),320+72(a0)
           move.w 320+88(a0),320+80(a0)
           move.w 320+96(a0),320+88(a0)
           move.w 320+104(a0),320+96(a0)
           move.w 320+112(a0),320+104(a0)
           move.w 320+120(a0),320+112(a0)
           move.w 320+128(a0),320+120(a0)
           move.w 320+136(a0),320+128(a0)
           move.w 320+144(a0),320+136(a0)
           move.w 320+152(a0),320+144(a0)
           move.b 320+153(a1),320+152(a0)
           move.b (a2),320+153(a0)
           lea 160(a0),a0
           lea 160(a1),a1
           endr
           addq #1,a2
           dbra d0,scroll

           move.l a2,adr_deb

; -----------
; SWAP ECRANS
; -----------

perm       move.l screen1,d0
           move.l screen2,screen1
           move.l d0,screen2

           lsr.l #8,d0
           move.w #$8200,a0
           movep.w d0,1(a0)
           
           clr.w $ffff8240
           rte

; --------------------------------------------------------------
;
;                        RASTERS (TIMER B)
;
; --------------------------------------------------------------

hbl1       addq #1,conte
           cmp.w #99,conte
           beq.s fin_hbl
           move.w (a3)+,$ffff8242
           rte

fin_hbl    clr.b $ffffa1b
           rte

; -------
; Clavier
; -------

newkey     move.w #$2500,sr
           bclr #6,$ffffa11
           rte

; --------------------------------------------------------------
;
;                     DONNEES & VARIABLES
;
; --------------------------------------------------------------          

rasters    dc.w $770,$670,$570,$470,$370,$270,$170,$070
           dc.w $071,$072,$073,$074,$075,$076,$077,$067
           dc.w $057,$047,$037,$027,$017,$007,$107,$207
           dc.w $307,$407,$507,$607,$707,$706,$705,$704
           dc.w $703,$702,$701,$700,$710,$720,$730,$740
           dc.w $750,$760,$770,$670,$570,$470,$370,$270
           dc.w $170,$070,$071,$072,$073,$074,$075,$076
           dc.w $077,$067,$057,$047,$037,$027,$017,$007
           dc.w $107,$207,$307,$407,$507,$607,$707,$706
           dc.w $705,$704,$703,$702,$701,$700,$710,$720
           dc.w $730,$740,$750,$760,$770,$670,$570,$470
           dc.w $370,$270,$170,$070,$170,$270,$370,$470
           dc.w $570,$670

new_pal    dc.w $000,$777,$321,$321,$432,$432,$543,$543
           dc.w $654,$654,$777,$777,$777,$777,$777,$777

calcul     dc.w 0,168,2*168,3*168,4*168,5*168,6*168,7*168,8*168
           dc.w 9*168,10*168,11*168,12*168,13*168,14*168,15*168
           dc.w 16*168,17*168,18*168,19*168,20*168,21*168,22*168
           dc.w 23*168,24*168,25*168,26*168

stop_mouse dc.b $12
go_mouse   dc.b $8

txt        dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
           dc.b 20,21,22,23,24,25,26,26,26,26,26,26,26,26,26,26,26

lettre     dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff    ; A
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00        

           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff    ; B
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $00,$ff,$ff,$00,$ff,$ff,$00
           dc.b $00,$ff,$ff,$00,$ff,$ff,$00
           dc.b $00,$ff,$ff,$00,$ff,$ff,$00
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00   

           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff    ; C
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00   

           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff    ; D
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $00,$ff,$ff,$ff,$ff,$ff,$00
           dc.b $00,$ff,$ff,$ff,$ff,$ff,$00
           dc.b $00,$ff,$ff,$ff,$ff,$ff,$00
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00   

           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff    ; E
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00   

           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff    ; F
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00  

           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff   ; G
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$ff,$ff,$ff
           dc.b $ff,$00,$00,$ff,$ff,$ff,$ff
           dc.b $ff,$00,$00,$ff,$ff,$ff,$ff
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00   

           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff   ; H
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00   

           dc.b $ff,$00,$00,$00,$00,$00,$ff    ; I
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00   

           dc.b $00,$00,$00,$ff,$ff,$ff,$00    ; J
           dc.b $00,$00,$00,$ff,$ff,$ff,$00
           dc.b $00,$00,$00,$ff,$ff,$ff,$00
           dc.b $00,$00,$00,$ff,$00,$00,$ff
           dc.b $00,$00,$00,$ff,$00,$00,$ff
           dc.b $00,$00,$00,$ff,$00,$00,$ff
           dc.b $00,$00,$00,$ff,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$00
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$00
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$00
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00 

           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff    ; K
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$ff,$00,$ff,$00,$00
           dc.b $00,$00,$ff,$00,$ff,$00,$00
           dc.b $00,$00,$ff,$00,$ff,$00,$00
           dc.b $00,$ff,$00,$00,$00,$ff,$00
           dc.b $00,$ff,$00,$00,$00,$ff,$00
           dc.b $00,$ff,$00,$00,$00,$ff,$00
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00 

           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff    ; L
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00 

           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff    ; M
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $00,$ff,$00,$00,$00,$00,$00
           dc.b $00,$ff,$00,$00,$00,$00,$00
           dc.b $00,$ff,$00,$00,$00,$00,$00
           dc.b $00,$00,$ff,$00,$00,$00,$00
           dc.b $00,$00,$ff,$00,$00,$00,$00
           dc.b $00,$00,$ff,$00,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$ff,$00,$00,$00,$00
           dc.b $00,$00,$ff,$00,$00,$00,$00
           dc.b $00,$00,$ff,$00,$00,$00,$00
           dc.b $00,$ff,$00,$00,$00,$00,$00
           dc.b $00,$ff,$00,$00,$00,$00,$00
           dc.b $00,$ff,$00,$00,$00,$00,$00
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00 

           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff    ; N
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $00,$ff,$00,$00,$00,$00,$00
           dc.b $00,$ff,$00,$00,$00,$00,$00
           dc.b $00,$ff,$00,$00,$00,$00,$00
           dc.b $00,$00,$ff,$00,$00,$00,$00
           dc.b $00,$00,$ff,$00,$00,$00,$00
           dc.b $00,$00,$ff,$00,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$00,$ff,$00,$00
           dc.b $00,$00,$00,$00,$ff,$00,$00
           dc.b $00,$00,$00,$00,$ff,$00,$00
           dc.b $00,$00,$00,$00,$00,$ff,$00
           dc.b $00,$00,$00,$00,$00,$ff,$00
           dc.b $00,$00,$00,$00,$00,$ff,$00
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00 

           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff    ; O
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00 

           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff    ; P
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$ff,$ff,$ff,$00,$00,$00
           dc.b $ff,$ff,$ff,$ff,$00,$00,$00
           dc.b $ff,$ff,$ff,$ff,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00 

           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff    ; Q
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$ff,$00,$ff
           dc.b $ff,$00,$00,$00,$ff,$00,$ff
           dc.b $ff,$00,$00,$00,$ff,$ff,$ff
           dc.b $ff,$00,$00,$00,$00,$ff,$ff
           dc.b $ff,$00,$00,$00,$00,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00 

           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff    ; R
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$00,$00
           dc.b $ff,$00,$00,$ff,$ff,$00,$00
           dc.b $ff,$00,$00,$ff,$ff,$00,$00
           dc.b $ff,$00,$00,$ff,$ff,$00,$00
           dc.b $ff,$00,$00,$ff,$00,$ff,$00
           dc.b $ff,$00,$00,$ff,$00,$ff,$00
           dc.b $ff,$00,$00,$ff,$00,$ff,$00
           dc.b $ff,$ff,$ff,$ff,$00,$00,$ff
           dc.b $ff,$ff,$ff,$ff,$00,$00,$ff
           dc.b $ff,$ff,$ff,$ff,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00 

           dc.b $ff,$ff,$ff,$ff,$00,$00,$ff    ; S
           dc.b $ff,$ff,$ff,$ff,$00,$00,$ff
           dc.b $ff,$ff,$ff,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$ff,$ff,$ff
           dc.b $ff,$00,$00,$ff,$ff,$ff,$ff
           dc.b $ff,$00,$00,$ff,$ff,$ff,$ff
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00 

           dc.b $ff,$00,$00,$00,$00,$00,$00    ; T
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $ff,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00   

           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff    ; U
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00 

           dc.b $ff,$ff,$ff,$ff,$00,$00,$00    ; V
           dc.b $ff,$ff,$ff,$ff,$00,$00,$00
           dc.b $ff,$ff,$ff,$ff,$00,$00,$00
           dc.b $00,$00,$00,$00,$ff,$00,$00
           dc.b $00,$00,$00,$00,$ff,$00,$00
           dc.b $00,$00,$00,$00,$ff,$00,$00
           dc.b $00,$00,$00,$00,$00,$ff,$00
           dc.b $00,$00,$00,$00,$00,$ff,$00
           dc.b $00,$00,$00,$00,$00,$ff,$00
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$ff,$00
           dc.b $00,$00,$00,$00,$00,$ff,$00
           dc.b $00,$00,$00,$00,$00,$ff,$00
           dc.b $00,$00,$00,$00,$ff,$00,$00
           dc.b $00,$00,$00,$00,$ff,$00,$00
           dc.b $00,$00,$00,$00,$ff,$00,$00
           dc.b $ff,$ff,$ff,$ff,$00,$00,$00
           dc.b $ff,$ff,$ff,$ff,$00,$00,$00
           dc.b $ff,$ff,$ff,$ff,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00

           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff    ; W
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $00,$00,$00,$00,$00,$ff,$00
           dc.b $00,$00,$00,$00,$00,$ff,$00
           dc.b $00,$00,$00,$00,$00,$ff,$00
           dc.b $00,$00,$00,$00,$ff,$00,$00
           dc.b $00,$00,$00,$00,$ff,$00,$00
           dc.b $00,$00,$00,$00,$ff,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$00,$ff,$00,$00
           dc.b $00,$00,$00,$00,$ff,$00,$00
           dc.b $00,$00,$00,$00,$ff,$00,$00
           dc.b $00,$00,$00,$00,$00,$ff,$00
           dc.b $00,$00,$00,$00,$00,$ff,$00
           dc.b $00,$00,$00,$00,$00,$ff,$00
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00

           dc.b $ff,$00,$00,$00,$00,$00,$ff    ; X
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $00,$ff,$00,$00,$00,$ff,$00
           dc.b $00,$ff,$00,$00,$00,$ff,$00
           dc.b $00,$ff,$00,$00,$00,$ff,$00
           dc.b $00,$00,$ff,$00,$ff,$00,$00
           dc.b $00,$00,$ff,$00,$ff,$00,$00
           dc.b $00,$00,$ff,$00,$ff,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$ff,$00,$ff,$00,$00
           dc.b $00,$00,$ff,$00,$ff,$00,$00
           dc.b $00,$00,$ff,$00,$ff,$00,$00
           dc.b $00,$ff,$00,$00,$00,$ff,$00
           dc.b $00,$ff,$00,$00,$00,$ff,$00
           dc.b $00,$ff,$00,$00,$00,$ff,$00
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00

           dc.b $ff,$ff,$00,$00,$00,$00,$00    ; Y
           dc.b $ff,$ff,$00,$00,$00,$00,$00
           dc.b $ff,$ff,$00,$00,$00,$00,$00
           dc.b $00,$00,$ff,$00,$00,$00,$00
           dc.b $00,$00,$ff,$00,$00,$00,$00
           dc.b $00,$00,$ff,$00,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$00,$ff,$ff,$ff
           dc.b $00,$00,$00,$00,$ff,$ff,$ff
           dc.b $00,$00,$00,$00,$ff,$ff,$ff
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$00,$ff,$00,$00,$00
           dc.b $00,$00,$ff,$00,$00,$00,$00
           dc.b $00,$00,$ff,$00,$00,$00,$00
           dc.b $00,$00,$ff,$00,$00,$00,$00
           dc.b $ff,$ff,$00,$00,$00,$00,$00
           dc.b $ff,$ff,$00,$00,$00,$00,$00
           dc.b $ff,$ff,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00

           dc.b $ff,$00,$00,$00,$00,$00,$ff    ; Z
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$ff,$ff
           dc.b $ff,$00,$00,$00,$00,$ff,$ff
           dc.b $ff,$00,$00,$00,$00,$ff,$ff
           dc.b $ff,$00,$00,$00,$ff,$00,$ff
           dc.b $ff,$00,$00,$00,$ff,$00,$ff
           dc.b $ff,$00,$00,$00,$ff,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$ff
           dc.b $ff,$00,$ff,$00,$00,$00,$ff
           dc.b $ff,$00,$ff,$00,$00,$00,$ff
           dc.b $ff,$00,$ff,$00,$00,$00,$ff
           dc.b $ff,$ff,$00,$00,$00,$00,$ff
           dc.b $ff,$ff,$00,$00,$00,$00,$ff
           dc.b $ff,$ff,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00 

space      dc.b $00,$00,$00,$00,$00,$00,$00    ; [ ]
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00     
           dc.b $00,$00,$00,$00,$00,$00,$00   
           dc.b $00,$00,$00,$00,$00,$00,$00 

           even

save_hbl   ds.l 1
save_118   ds.l 1
save_vbl   ds.l 1
oldscreen  ds.l 1
adr_txt    ds.l 1
adr_deb    ds.l 1
adr_fin    ds.l 1
screen1    ds.l 1
screen2    ds.l 1
oldssp     ds.l 1

fst_col    ds.w 1
conte      ds.w 1
oldrez     ds.w 1
sens       ds.w 1
decal      ds.w 1
oldpal     ds.w 16

save_iera  ds.b 1
save_ierb  ds.b 1
save_imra  ds.b 1
save_isrb  ds.b 1
save_vect  ds.b 1
key        ds.b 1
cmptr      ds.b 1

; sur falcon 030, les zics MAD MAX ne passent pas ...

; music      incbin "M_MAX_03.DAT"
logo       incbin "BIG_LOGO.DAT"