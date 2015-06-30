; --------------------------------------------------------------
;
;                  - ECRAN2 - (C) FANTOMAS 1991
;
; --------------------------------------------------------------

           opt o+

; **************
;
; INITIALISATION
;
; **************

start      move.l a7,a5
           lea pile,a7
           move.l 4(a5),a5
           move.l $c(a5),d0
           add.l $14(a5),d0
           add.l $1C(a5),d0
           add.l #$100,d0
           move.l d0,-(sp)
           move.l a5,-(sp)
           move.w #0,-(sp)
           move.w #$4A,-(sp)
           trap #1
           lea 12(a7),a7

; Mode superviseur

           clr.l -(sp)
           move.w #$20,-(sp)
           trap #1
           addq.l #6,sp
           move.l d0,oldssp

; Sauve et supprime clavier

           move.b $484,key
           clr.b $484

; Supprime souris
 
           pea stop_mouse(pc)
           move.w #0,-(sp)
           move.w #$19,-(sp)
           trap #14
           addq.l #8,sp

; Sauve palette couleurs

           move.l #$ffff8240,a0
           lea oldpal,a1
           movem.l (a0)+,d0-d7
           movem.l d0-d7,(a1)

; Nouvelle palette

          pea fond
          move.w #6,-(sp)
          trap #14
          addq.l #6,sp
            
; Sauve resolution 

           move.w #4,-(sp)
           trap #14
           addq.l #2,sp 
           move.w d0,oldrez

; Sauve adresse ecran

           move.w #2,-(sp)
           trap #14
           addq.l #2,sp
           move.l d0,oldscreen

; Cree deux ecrans

           move.l #$60000,screen1
           move.l #$67d00,screen2

; Change resolution et ecrans

           clr.w -(sp)
           move.l screen1,-(sp)
           move.l screen2,-(sp)
           move.w #5,-(sp)
           trap #14
           add.l #12,sp

; Efface les deux ecrans

           move.l screen1,a0
           move.l screen2,a1
           move.w #7999,d0
boucle1    clr.l (a0)+
           clr.l (a1)+
           dbra d0,boucle1

; Affiche le logo

           lea logo,a0
           move.l screen1,a1
           move.l screen2,a2
           lea 60*160(a1),a1
           lea 60*160(a2),a2
           move.w #2599,d0
log_loop   move.l (a0),(a1)+
           move.l (a0)+,(a2)+
           dbra d0,log_loop

; Init musique: ne passe pas sur Falcon, a changer 

;           moveq #1,d0
;           bsr music


; Init timers et synchro

           move.b $ffffa07,save_iera
           move.b $ffffa09,save_ierb
           move.b $ffffa13,save_imra
           move.b $ffffa11,savea11
           and.b #0,$ffffa07
           and.b #$40,$ffffa09
           bset #3,$ffffa17
           or.b #1,$ffffa07
           or.b #1,$ffffa13
           move.l $70,save_vbl
           move.l $120,save_hbl
           move.l $118,old118
           move.l #newkey,$118
           move.l #hbl1,$120
           move.l #vbl,$70           

; ************************
;
; INITIALISATIONS DIVERSES
;
; ************************

           move.l #distor,ondule
           move.l #text,txt_ptr
           move.l #vtext,vtxt_ptr
           move.l #ltext,ltxt_ptr
           move.l #buffer1,bufsc1
           move.l #buffer2,bufsc2

; ***************** 
;
; BOUCLE PRINCIPALE
;
; *****************

loop       cmp.b #$39,$ffffc02              ; Appui sur espace ?
           bne.s loop

; ****************
;
; FIN DU PROGRAMME
;
; ****************

; Restore timers

           move.b save_iera,$fffa07
           move.b save_ierb,$fffa09
           move.b save_imra,$fffa13
           move.b savea11,$fffffa11
           move.l save_vbl,$70
           move.l save_hbl,$120
           move.l old118,$118

; Chip sonore

           move.b #8,$ff8800
           move.b #0,$ff8802
           move.b #9,$ff8800
           move.b #0,$ff8802
           move.b #$a,$ff8800
           move.b #0,$ff8802

; Ancienne resolution et ecrans
        
           move.w oldrez,-(sp)
           move.l oldscreen,-(sp)
           move.l oldscreen,-(sp)
           move.w #5,-(sp)
           trap #14
           add.l #12,sp

; Ancienne palette
          
           lea oldpal,a0
           move.l #$ffff8240,a1
           movem.l (a0)+,d0-d7
           movem.l d0-d7,(a1)

; Retablit la souris
 
           pea go_mouse(pc)
           move.w #0,-(sp)
           move.w #$19,-(sp)
           trap #14
           addq.l #8,sp

; Retablit le clavier

           move.b key,$484

; Retour en mode user

           move.l oldssp,-(sp)
           move.w #$20,-(sp)
           trap #1
           addq.l #6,sp

; Retour au dos

           clr.w -(sp)
           trap #1

; ************
;
; LE PROGRAMME
;
; ************

vbl        clr.b conte
           lea rasters,a3
           move.b #2,$ffffa21
           move.l #hbl1,$120
           move.b #8,$ffffa1b

; -------
; Palette
; -------

	clr.w	$ff8240
           clr.l $ff8242
           clr.w $ff8246
           move.l #$5550666,$ff8252
           move.w #$777,$ff8256

; -------
; Musique
; -------

           move.l a3,-(sp)
;           bsr music+8                   
           move.l (sp)+,a3

; ----------------
; Led des lecteurs
; ----------------

           lea $ffff8800,a0
           move.b #10,(a0)
           move.b (a0),d0

           cmpi.b #14,d0
           blt.s led_off

led_on     move.b #14,(a0)
           move.b (a0),d0
           andi.b #$f9,d0
           move.b d0,2(a0)
           bra.s fin

led_off    move.b #14,(a0)
           move.b (a0),d0
           ori.b #6,d0
           move.b d0,2(a0)

; --------------------------------------------------------------
;
;                           MONTAGNES
;
; --------------------------------------------------------------

fin        add.l #2240,moun
           cmp.l #44800,moun
           bne.s blurps
           clr.l moun
 
blurps     move.l moun,d0
           lea tain,a0
           add.l d0,a0
           move.l screen1,a1
           lea 171*160(a1),a4
           lea 7*160(a1),a1
           moveq #13,d0
moon_loop  move.l (a0),(a1)
           move.l (a0)+,(a4)
           move.l (a0),8(a1)
           move.l (a0)+,8(a4)
           move.l (a0),16(a1)
           move.l (a0)+,16(a4)
           move.l (a0),24(a1)
           move.l (a0)+,24(a4)
           move.l (a0),32(a1)
           move.l (a0)+,32(a4)
           move.l (a0),40(a1)
           move.l (a0)+,40(a4)
           move.l (a0),48(a1)
           move.l (a0)+,48(a4)
           move.l (a0),56(a1)
           move.l (a0)+,56(a4)
           move.l (a0),64(a1)
           move.l (a0)+,64(a4)
           move.l (a0),72(a1)
           move.l (a0)+,72(a4)
           move.l (a0),80(a1)
           move.l (a0)+,80(a4)
           move.l (a0),88(a1)
           move.l (a0)+,88(a4)
           move.l (a0),96(a1)
           move.l (a0)+,96(a4)
           move.l (a0),104(a1)
           move.l (a0)+,104(a4)
           move.l (a0),112(a1)
           move.l (a0)+,112(a4)
           move.l (a0),120(a1)
           move.l (a0)+,120(a4)
           move.l (a0),128(a1)
           move.l (a0)+,128(a4)
           move.l (a0),136(a1)
           move.l (a0)+,136(a4)
           move.l (a0),144(a1)
           move.l (a0)+,144(a4)
           move.l (a0),152(a1)
           move.l (a0)+,152(a4)
           move.l (a0),160(a1)
           move.l (a0)+,160(a4)
           move.l (a0),168(a1)
           move.l (a0)+,168(a4)
           move.l (a0),176(a1)
           move.l (a0)+,176(a4)
           move.l (a0),184(a1)
           move.l (a0)+,184(a4)
           move.l (a0),192(a1)
           move.l (a0)+,192(a4)
           move.l (a0),200(a1)
           move.l (a0)+,200(a4)
           move.l (a0),208(a1)
           move.l (a0)+,208(a4)
           move.l (a0),216(a1)
           move.l (a0)+,216(a4)
           move.l (a0),224(a1)
           move.l (a0)+,224(a4)
           move.l (a0),232(a1)
           move.l (a0)+,232(a4)
           move.l (a0),240(a1)
           move.l (a0)+,240(a4)
           move.l (a0),248(a1)
           move.l (a0)+,248(a4)
           move.l (a0),256(a1)
           move.l (a0)+,256(a4)
           move.l (a0),264(a1)
           move.l (a0)+,264(a4)
           move.l (a0),272(a1)
           move.l (a0)+,272(a4)
           move.l (a0),280(a1)
           move.l (a0)+,280(a4)
           move.l (a0),288(a1)
           move.l (a0)+,288(a4)
           move.l (a0),296(a1)
           move.l (a0)+,296(a4)
           move.l (a0),304(a1)
           move.l (a0)+,304(a4)
           move.l (a0),312(a1)
           move.l (a0)+,312(a4)
           lea 320(a1),a1
           lea 320(a4),a4
           dbra d0,moon_loop

; -------------------
; Donn‚es & variables
; -------------------

           section bss

moun       ds.l 1

           section data

tain       incbin "C:\DEVPAC3\ECRAN2\SOURCES\MOUNTAIN.DAT"

; --------------------------------------------------------------
;
;           SCROLLTEXTS HORIZONTAUX (FONTE 32x32 1 PLAN)
;
; --------------------------------------------------------------

           section text

; ------------------------------------------
; Swappe les 2 buffers pour un scroll de 4x4
; ------------------------------------------

           move.l bufsc1,d0
           move.l bufsc2,bufsc1
           move.l d0,bufsc2

; -------------------------------
; Scroll <- de bufsc1 de 8 pixels
; -------------------------------

           move.l bufsc1,a1
           moveq #15,d0
skroll     move.b 1(a1),(a1)
           move.b 2(a1),1(a1)
           move.b 3(a1),2(a1)
           move.b 4(a1),3(a1)
           move.b 5(a1),4(a1)
           move.b 6(a1),5(a1)
           move.b 7(a1),6(a1)
           move.b 8(a1),7(a1)
           move.b 9(a1),8(a1)
           move.b 10(a1),9(a1)
           move.b 11(a1),10(a1)
           move.b 12(a1),11(a1)
           move.b 13(a1),12(a1)
           move.b 14(a1),13(a1)
           move.b 15(a1),14(a1)
           move.b 16(a1),15(a1)
           move.b 17(a1),16(a1)
           move.b 18(a1),17(a1)
           move.b 19(a1),18(a1)
           move.b 20(a1),19(a1)
           move.b 21(a1),20(a1)
           move.b 22(a1),21(a1)
           move.b 23(a1),22(a1)
           move.b 24(a1),23(a1)
           move.b 25(a1),24(a1)
           move.b 26(a1),25(a1)
           move.b 27(a1),26(a1)
           move.b 28(a1),27(a1)
           move.b 29(a1),28(a1)
           move.b 30(a1),29(a1)
           move.b 31(a1),30(a1)
           move.b 32(a1),31(a1)
           move.b 33(a1),32(a1)
           move.b 34(a1),33(a1)
           move.b 35(a1),34(a1)
           move.b 36(a1),35(a1)
           move.b 37(a1),36(a1)
           move.b 38(a1),37(a1)
           move.b 39(a1),38(a1)
           move.b 41(a1),40(a1)
           move.b 42(a1),41(a1)
           move.b 43(a1),42(a1)
           move.b 44(a1),43(a1)
           move.b 45(a1),44(a1)
           move.b 46(a1),45(a1)
           move.b 47(a1),46(a1)
           move.b 48(a1),47(a1)
           move.b 49(a1),48(a1)
           move.b 50(a1),49(a1)
           move.b 51(a1),50(a1)
           move.b 52(a1),51(a1)
           move.b 53(a1),52(a1)
           move.b 54(a1),53(a1)
           move.b 55(a1),54(a1)
           move.b 56(a1),55(a1)
           move.b 57(a1),56(a1)
           move.b 58(a1),57(a1)
           move.b 59(a1),58(a1)
           move.b 60(a1),59(a1)
           move.b 61(a1),60(a1)
           move.b 62(a1),61(a1)
           move.b 63(a1),62(a1)
           move.b 64(a1),63(a1)
           move.b 65(a1),64(a1)
           move.b 66(a1),65(a1)
           move.b 67(a1),66(a1)
           move.b 68(a1),67(a1)
           move.b 69(a1),68(a1)
           move.b 70(a1),69(a1)
           move.b 71(a1),70(a1)
           move.b 72(a1),71(a1)
           move.b 73(a1),72(a1)
           move.b 74(a1),73(a1)
           move.b 75(a1),74(a1)
           move.b 76(a1),75(a1)
           move.b 77(a1),76(a1)
           move.b 78(a1),77(a1)
           move.b 79(a1),78(a1)
           lea 80(a1),a1
           dbra d0,skroll

; --------------------------------
; Scroll <- de buffer0 de 4 pixels
; --------------------------------

           rept 4
           bsr scroll
           endr

; -----------------------------------------
; Entree des portions du caractere a droite
; -----------------------------------------

           lea buffer0,a0
           move.l bufsc1,a1
           moveq #7,d0

voui       move.b (a0),39(a1)
           move.b 6(a0),79(a1)
           move.b 12(a0),119(a1)
           move.b 18(a0),159(a1)
           lea 24(a0),a0
           lea 160(a1),a1
           dbra d0,voui

; ------------------
; Prochain caractŠre
; ------------------

           moveq #0,d0
           move.b bit,d0
           cmp.b #8,d0
           bne plusloin
           clr.b bit
           move.l txt_ptr,a0
           move.b (a0),d0
           cmp.b #255,d0
           bne.s suite
           move.l #text2,txt_ptr
           move.l txt_ptr,a0
           move.b (a0),d0
suite      addq.l #1,txt_ptr
           asl #7,d0
           lea font,a0
           add.l d0,a0
           lea buffer0,a1

; -------------------
; CaractŠre -> Buffer
; -------------------

           move.l (a0)+,2(a1)
           move.l (a0)+,8(a1)
           move.l (a0)+,14(a1)
           move.l (a0)+,20(a1)
           move.l (a0)+,26(a1)
           move.l (a0)+,32(a1)
           move.l (a0)+,38(a1)
           move.l (a0)+,44(a1)
           move.l (a0)+,50(a1)
           move.l (a0)+,56(a1)
           move.l (a0)+,62(a1)
           move.l (a0)+,68(a1)
           move.l (a0)+,74(a1)
           move.l (a0)+,80(a1)
           move.l (a0)+,86(a1)
           move.l (a0)+,92(a1)
           move.l (a0)+,98(a1)
           move.l (a0)+,104(a1)
           move.l (a0)+,110(a1)
           move.l (a0)+,116(a1)
           move.l (a0)+,122(a1)
           move.l (a0)+,128(a1)
           move.l (a0)+,134(a1)
           move.l (a0)+,140(a1)
           move.l (a0)+,146(a1)
           move.l (a0)+,152(a1)
           move.l (a0)+,158(a1)
           move.l (a0)+,164(a1)
           move.l (a0)+,170(a1)
           move.l (a0)+,176(a1)
           move.l (a0)+,182(a1)
           move.l (a0),188(a1)

plusloin   add.b #1,bit

; -------------
; Fond -> Ecran
; -------------

           move.l bufsc1,a0
           move.l screen1,a1
           lea 480(a1),a4  
           lea 26720(a1),a1

           moveq #7,d0 
loop_ligne move.w (a0),6(a1)
           move.w (a0)+,6(a4)
           move.w (a0),14(a1)
           move.w (a0)+,14(a4)
           move.w (a0),22(a1)
           move.w (a0)+,22(a4)
           move.w (a0),30(a1)
           move.w (a0)+,30(a4)
           move.w (a0),38(a1)
           move.w (a0)+,38(a4)
           move.w (a0),46(a1)
           move.w (a0)+,46(a4)
           move.w (a0),54(a1)
           move.w (a0)+,54(a4)
           move.w (a0),62(a1)
           move.w (a0)+,62(a4)
           move.w (a0),70(a1)
           move.w (a0)+,70(a4)
           move.w (a0),78(a1)
           move.w (a0)+,78(a4)
           move.w (a0),86(a1)
           move.w (a0)+,86(a4)
           move.w (a0),94(a1)
           move.w (a0)+,94(a4)
           move.w (a0),102(a1)
           move.w (a0)+,102(a4)
           move.w (a0),110(a1)
           move.w (a0)+,110(a4)
           move.w (a0),118(a1)
           move.w (a0)+,118(a4)
           move.w (a0),126(a1)
           move.w (a0)+,126(a4)
           move.w (a0),134(a1)
           move.w (a0)+,134(a4)
           move.w (a0),142(a1)
           move.w (a0)+,142(a4)
           move.w (a0),150(a1)
           move.w (a0)+,150(a4)
           move.w (a0),158(a1)
           move.w (a0)+,158(a4)
           move.w (a0),166(a1)
           move.w (a0)+,166(a4)
           move.w (a0),174(a1)
           move.w (a0)+,174(a4)
           move.w (a0),182(a1)
           move.w (a0)+,182(a4)
           move.w (a0),190(a1)
           move.w (a0)+,190(a4)
           move.w (a0),198(a1)
           move.w (a0)+,198(a4)
           move.w (a0),206(a1)
           move.w (a0)+,206(a4)
           move.w (a0),214(a1)
           move.w (a0)+,214(a4)
           move.w (a0),222(a1)
           move.w (a0)+,222(a4)
           move.w (a0),230(a1)
           move.w (a0)+,230(a4)
           move.w (a0),238(a1)
           move.w (a0)+,238(a4)
           move.w (a0),246(a1)
           move.w (a0)+,246(a4)
           move.w (a0),254(a1)
           move.w (a0)+,254(a4)
           move.w (a0),262(a1)
           move.w (a0)+,262(a4)
           move.w (a0),270(a1)
           move.w (a0)+,270(a4)
           move.w (a0),278(a1)
           move.w (a0)+,278(a4)
           move.w (a0),286(a1)
           move.w (a0)+,286(a4)
           move.w (a0),294(a1)
           move.w (a0)+,294(a4)
           move.w (a0),302(a1)
           move.w (a0)+,302(a4)
           move.w (a0),310(a1)
           move.w (a0)+,310(a4)
           move.w (a0),318(a1)
           move.w (a0)+,318(a4)
           move.w (a0),326(a1)
           move.w (a0)+,326(a4)
           move.w (a0),334(a1)
           move.w (a0)+,334(a4)
           move.w (a0),342(a1)
           move.w (a0)+,342(a4)
           move.w (a0),350(a1)
           move.w (a0)+,350(a4)
           move.w (a0),358(a1)
           move.w (a0)+,358(a4)
           move.w (a0),366(a1)
           move.w (a0)+,366(a4)
           move.w (a0),374(a1)
           move.w (a0)+,374(a4)
           move.w (a0),382(a1)
           move.w (a0)+,382(a4)
           move.w (a0),390(a1)
           move.w (a0)+,390(a4)
           move.w (a0),398(a1)
           move.w (a0)+,398(a4)
           move.w (a0),406(a1)
           move.w (a0)+,406(a4)
           move.w (a0),414(a1)
           move.w (a0)+,414(a4)
           move.w (a0),422(a1)
           move.w (a0)+,422(a4)
           move.w (a0),430(a1)
           move.w (a0)+,430(a4)
           move.w (a0),438(a1)
           move.w (a0)+,438(a4)
           move.w (a0),446(a1)
           move.w (a0)+,446(a4)
           move.w (a0),454(a1)
           move.w (a0)+,454(a4)
           move.w (a0),462(a1)
           move.w (a0)+,462(a4)
           move.w (a0),470(a1)
           move.w (a0)+,470(a4)
           move.w (a0),478(a1)
           move.w (a0)+,478(a4)
           move.w (a0),486(a1)
           move.w (a0)+,486(a4)
           move.w (a0),494(a1)
           move.w (a0)+,494(a4)
           move.w (a0),502(a1)
           move.w (a0)+,502(a4)
           move.w (a0),510(a1)
           move.w (a0)+,510(a4)
           move.w (a0),518(a1)
           move.w (a0)+,518(a4)
           move.w (a0),526(a1)
           move.w (a0)+,526(a4)
           move.w (a0),534(a1)
           move.w (a0)+,534(a4)
           move.w (a0),542(a1)
           move.w (a0)+,542(a4)
           move.w (a0),550(a1)
           move.w (a0)+,550(a4)
           move.w (a0),558(a1)
           move.w (a0)+,558(a4)
           move.w (a0),566(a1)
           move.w (a0)+,566(a4)
           move.w (a0),574(a1)
           move.w (a0)+,574(a4)
           move.w (a0),582(a1)
           move.w (a0)+,582(a4)
           move.w (a0),590(a1)
           move.w (a0)+,590(a4)
           move.w (a0),598(a1)
           move.w (a0)+,598(a4)
           move.w (a0),606(a1)
           move.w (a0)+,606(a4)
           move.w (a0),614(a1)
           move.w (a0)+,614(a4)
           move.w (a0),622(a1)
           move.w (a0)+,622(a4)
           move.w (a0),630(a1)
           move.w (a0)+,630(a4)
           move.w (a0),638(a1)
           move.w (a0)+,638(a4)
           lea 640(a1),a1
           lea 640(a4),a4
           dbra d0,loop_ligne

; *******************
; Donn‚es & Variables
; *******************

           section bss

txt_ptr    ds.l 1
bufsc1     ds.l 1
bufsc2     ds.l 1
buffer0    ds.w 96
buffer1    ds.w 20*32
buffer2    ds.w 20*32
bit        ds.b 1

           section data

text       dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44
text2      incbin "C:\DEVPAC3\ECRAN2\SOURCES\TEXT_1.DAT"
           even
font       incbin "C:\DEVPAC3\ECRAN2\SOURCES\FONT_32.DAT"

           section text

; **************
; LITTLE SCROLLS
; **************

           moveq #0,d0
           move.b lbit,d0
           cmp.b #8,d0
           bne.s plusloin3
           clr.b lbit
           move.l ltxt_ptr,a0
           move.b (a0),d0
           cmp.b #255,d0
           bne.s lsuite
           move.l #ltext,ltxt_ptr
           move.l ltxt_ptr,a0
           move.b (a0),d0
lsuite     addq.l #1,ltxt_ptr
           asl #3,d0
           lea lfont,a0
           add.l d0,a0
           lea lbuffer,a1

; --- CARACTERE -> BUFFER ---

           move.b (a0)+,(a1)
           move.b (a0)+,2(a1)
           move.b (a0)+,4(a1)
           move.b (a0)+,6(a1)
           move.b (a0)+,8(a1)
           move.b (a0)+,10(a1)
           move.b (a0)+,12(a1)

plusloin3  tst.l time
           bne.s loula

           add.l #12,ondule          
           cmp.l #lfont,ondule     
           bne.s bof               
           move.l #distor,ondule   

bof        move.l ondule,a0               
           move.l (a0)+,time
           move.l (a0)+,vite
           move.l (a0)+,type

loula      move.l vite,d1
           move.l type,a1

           subq.l #1,time
           add.b d1,lbit
           jsr (a1)
           
; --- Decale l'ecran de 8 lignes en haut ---

          move.l screen1,a0
          lea 6+39*160(a0),a1
          lea 6+48*160(a0),a0
          
          moveq #12,d0
flopy     rept 7
          move.w (a0),(a1)
          move.w 8(a0),8(a1)
          move.w 16(a0),16(a1)
          move.w 24(a0),24(a1)
          move.w 32(a0),32(a1)
          move.w 40(a0),40(a1)
          move.w 48(a0),48(a1)
          move.w 56(a0),56(a1)
          move.w 64(a0),64(a1)
          move.w 72(a0),72(a1)
          move.w 80(a0),80(a1)
          move.w 88(a0),88(a1)
          move.w 96(a0),96(a1)
          move.w 104(a0),104(a1)
          move.w 112(a0),112(a1)
          move.w 120(a0),120(a1)
          move.w 128(a0),128(a1)
          move.w 136(a0),136(a1)
          move.w 144(a0),144(a1)
          move.w 152(a0),152(a1)
          lea 160(a0),a0
          lea 160(a1),a1
          endr
          lea 320(a0),a0
          lea 320(a1),a1    
          dbra d0,flopy

; --- TRAVAIL -> ECRAN ---

           move.l screen1,a1
           lea 6+156*160(a1),a1

; --- Affiche le petit scroll du bas ---

          lea ltrav+10,a0
          moveq #6,d0
gloop     move.w (a0)+,(a1)
          move.w (a0)+,8(a1)
          move.w (a0)+,16(a1)
          move.w (a0)+,24(a1)
          move.w (a0)+,32(a1)
          move.w (a0)+,40(a1)
          move.w (a0)+,48(a1)
          move.w (a0)+,56(a1)
          move.w (a0)+,64(a1)
          move.w (a0)+,72(a1)
          move.w (a0)+,80(a1)
          move.w (a0)+,88(a1)
          move.w (a0)+,96(a1)
          move.w (a0)+,104(a1)
          move.w (a0)+,112(a1)
          move.w (a0)+,120(a1)
          move.w (a0)+,128(a1)
          move.w (a0)+,136(a1)
          move.w (a0)+,144(a1)
          move.w (a0)+,152(a1)
          lea 20(a0),a0
          lea 160(a1),a1    
          dbra d0,gloop

; ****************************
;
; DONNEES ET VARIABLES LSCROLL
;
; ****************************

           section bss

ltxt_ptr   ds.l 1
ondule     ds.l 1

time       ds.l 1
vite       ds.l 1
type       ds.l 1

ltrav      ds.w 30*7
lbuffer    ds.w 8
lbit       ds.b 1
           even
         
           section data

distor     dc.l 40,2,scroll_no,20,0,scroll_dr,20,0,scroll_ga
           dc.l 40,2,scroll_no,20,0,scroll_dr,20,0,scroll_ga

           dc.l 6,0,scroll_dr,6,0,scroll_ga,6,0,scroll_dr
           dc.l 6,0,scroll_ga,6,0,scroll_dr,6,0,scroll_ga
           dc.l 6,0,scroll_dr,6,0,scroll_ga,60,0,nothing

           dc.l 40,2,scroll_no,40,0,scroll_dr,40,0,scroll_ga
           dc.l 40,2,scroll_no,40,0,scroll_dr,40,0,scroll_ga

           dc.l 60,0,nothing,40,0,scroll_dr,60,0,nothing
           
           dc.l 2,0,scroll_ga,2,0,scroll_dr,2,0,scroll_ga
           dc.l 2,0,scroll_dr,2,0,scroll_ga,2,0,scroll_dr
           dc.l 2,0,scroll_ga,2,0,scroll_dr,2,0,scroll_ga
           dc.l 2,0,scroll_dr,2,0,scroll_ga,2,0,scroll_dr
           dc.l 2,0,scroll_ga,2,0,scroll_dr,2,0,scroll_ga
           dc.l 2,0,scroll_dr,2,0,scroll_ga,2,0,scroll_dr
           dc.l 2,0,scroll_ga,2,0,scroll_dr,2,0,scroll_ga
           dc.l 2,0,scroll_dr,2,0,scroll_ga,2,0,scroll_dr
           dc.l 2,0,scroll_ga,2,0,scroll_dr,2,0,scroll_ga
           dc.l 2,0,scroll_dr,2,0,scroll_ga,2,0,scroll_dr
           dc.l 2,0,scroll_ga,2,0,scroll_dr,2,0,scroll_ga
           dc.l 2,0,scroll_dr,2,0,scroll_ga,2,0,scroll_dr
           dc.l 2,0,scroll_ga,2,0,scroll_dr,2,0,scroll_ga
           dc.l 30,0,nothing,38,0,scroll_ga        

           dc.l 20,2,scroll_no,30,0,nothing,20,2,scroll_no
           dc.l 30,0,nothing,20,2,scroll_no,30,0,nothing
           dc.l 20,2,scroll_no,30,0,nothing,20,2,scroll_no
           dc.l 30,0,nothing,20,2,scroll_no,30,0,nothing

           dc.l 20,0,scroll_dr,20,0,scroll_ga,20,0,scroll_dr
           dc.l 20,0,scroll_ga,20,0,scroll_dr,20,0,scroll_ga
           dc.l 20,0,scroll_dr,20,0,scroll_ga,20,0,scroll_dr
           dc.l 20,0,scroll_ga,20,0,scroll_dr,20,0,scroll_ga

lfont      incbin "C:\DEVPAC3\ECRAN2\SOURCES\FONT_8X8.DAT"
ltext      incbin "C:\DEVPAC3\ECRAN2\SOURCES\TEXT_2.DAT"
           even
           section text

; --------------------------------------------------------------
;
;           SCROLLTEXTS VERTICAUX (FONTE 16x16 1 PLAN)
;
; --------------------------------------------------------------

           moveq #0,d0
           move.b vbit,d0
           cmp.b #16,d0
           bne.s plusloin2
           clr.b vbit
           move.l vtxt_ptr,a0
           move.b (a0),d0
           cmp.b #255,d0
           bne.s vsuite
           move.l #vtext2,vtxt_ptr
           move.l vtxt_ptr,a0
           move.b (a0),d0
vsuite     addq.l #1,vtxt_ptr
           asl #5,d0
           lea vfont,a0
           add.l d0,a0
           lea vbuffer,a1

; -------------------
; Caracetre -> Buffer
; -------------------

           movem.l (a0)+,d0-d7
           movem.l d0-d7,(a1)

plusloin2  add.b #1,vbit

; -------------------
; Physique -> Logique
; -------------------

           move.l screen2,a0
           move.l screen1,a1
n          set 640
           rept 195
           move.w 12+n(a0),12+n-160(a1)
           move.w 148+n(a0),148+n-160(a1)
n          set n+160
           endr

; -----------------
; Buffer -> Logique
; -----------------

           lea vbuffer,a0
           move.w (a0),12+198*160(a1)
           move.w (a0),148+198*160(a1)
           movem.l 2(a0),d0-d7
           movem.l d0-d7,(a0)

; *******************
; Donn‚es & Variables
; *******************

           section bss

vtxt_ptr   ds.l 1
vbuffer    ds.w 17
vbit       ds.b 1
           even
         
           section data

vfont      incbin "C:\DEVPAC3\ECRAN2\SOURCES\FONTCAR.DAT"
vtext      dc.b 44,44,44,44,44,44,44,44,44,44,44,44
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44
vtext2     incbin "C:\DEVPAC3\ECRAN2\SOURCES\TEXT_3.DAT"
           even

; --------------------------------------------------------------
;
;                 SWAP ECRANS LOGIQUE & PHYSIQUE
;
; --------------------------------------------------------------

           section text  
         
           move.l screen1,d0
           move.l screen2,screen1
           move.l d0,screen2

           lsr.l #8,d0
           move.w #$8200,a0
           movep.w d0,1(a0)

           rte

; ***************
;
; SOUS PROGRAMMES
;
; ***************

; --- Ce sous programme ne fait rien ! ---

nothing    rts

; --- Petit scroll a droite ---
     
scroll_dr  moveq #1,d0
one_time   lea ltrav,a0
           rept 7
           moveq #0,d2
           roxr d2
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           roxr (a0)+
           endr
           dbra d0,one_time
           rts

; --- Petit scroll a gauche ---

scroll_ga  moveq #1,d0
more_time  lea ltrav,a0
           rept 7
           moveq #0,d2
           roxl d2
           roxl 58(a0)
           roxl 56(a0)
           roxl 54(a0)
           roxl 52(a0)
           roxl 50(a0)
           roxl 48(a0)
           roxl 46(a0)
           roxl 44(a0)
           roxl 42(a0)
           roxl 40(a0)
           roxl 38(a0)
           roxl 36(a0)
           roxl 34(a0)
           roxl 32(a0)
           roxl 30(a0)
           roxl 28(a0)
           roxl 26(a0)
           roxl 24(a0)
           roxl 22(a0)
           roxl 20(a0)
           roxl 18(a0)
           roxl 16(a0)
           roxl 14(a0)
           roxl 12(a0)
           roxl 10(a0)
           roxl 8(a0)
           roxl 6(a0)
           roxl 4(a0)
           roxl 2(a0)
           roxl (a0)
           lea 60(a0),a0
           endr
           dbra d0,more_time
           rts

; --- Buffer + petit scroll a gauche ---

scroll_no  moveq #1,d0
one_more   lea ltrav,a0
           lea lbuffer,a1
           rept 7
           roxl (a1)+
           roxl 48(a0)
           roxl 46(a0)
           roxl 44(a0)
           roxl 42(a0)
           roxl 40(a0)
           roxl 38(a0)
           roxl 36(a0)
           roxl 34(a0)
           roxl 32(a0)
           roxl 30(a0)
           roxl 28(a0)
           roxl 26(a0)
           roxl 24(a0)
           roxl 22(a0)
           roxl 20(a0)
           roxl 18(a0)
           roxl 16(a0)
           roxl 14(a0)
           roxl 12(a0)
           roxl 10(a0)
           roxl 8(a0)
           roxl 6(a0)
           roxl 4(a0)
           roxl 2(a0)
           roxl (a0)
           lea 60(a0),a0
           endr
           dbra d0,one_more      
           rts

; --- Scroll de buffer0 de 4 pixels a gauche ---

scroll     lea buffer0,a0
           moveq #3,d0
r_scro     roxl 4(a0)
           roxl 2(a0)
           roxl (a0)
           roxl 10(a0)
           roxl 8(a0)
           roxl 6(a0)
           roxl 16(a0)
           roxl 14(a0)
           roxl 12(a0)
           roxl 22(a0)
           roxl 20(a0)
           roxl 18(a0)        
           roxl 28(a0)
           roxl 26(a0)
           roxl 24(a0)
           roxl 34(a0)
           roxl 32(a0)
           roxl 30(a0)
           roxl 40(a0)
           roxl 38(a0)
           roxl 36(a0)
           roxl 46(a0)
           roxl 44(a0)
           roxl 42(a0)  
           lea 48(a0),a0
           dbra d0,r_scro
           rts           

; *******
;
; RASTERS
;
; *******

; -------------------------------------
; D‚grad‚ 1Šres montagnes + scroll haut
; -------------------------------------

hbl1       add.b #1,conte
           cmp.b #14,conte
           beq.s newhbl1
           move.w (a3)+,$ff8250
           move.l (a3),$ff8248
           move.l (a3),$ff824c
           move.l (a3),$ff8258
           move.l (a3)+,$ff825c
           bclr #0,$fffffa0f
           rte
newhbl1    clr.b $fffffa1b
           move.b #8,$ffffa21
           move.l #hbl2,$120
           move.b #8,$ffffa1b 
           bclr #0,$fffffa0f
           rte

; ----------------------------
; Petits scrolls + scroll haut
; ----------------------------

hbl2       add.b #1,conte
           cmp.b #15,conte
           bne.s goto
           move.l #$7370627,$ff8242
           move.w #$516,$ff8246
           move.l #$4050000,$ff824a
           move.w #$747,$ff824e
           move.l #$7370627,$ff8252
           move.l #$5160070,$ff8256
           move.l #$4050000,$ff825a
           move.w #$747,$ff825e
goto       cmp.b #31,conte
           beq.s newhbl2
           move.w (a3)+,$ff8250
           move.w (a3)+,$ff8248
           move.w (a3)+,$ff8258
           bclr #0,$ffffa0f
           rte
newhbl2    clr.b $ffffa1b
           move.b #2,$ffffa21
           move.l #hbl3,$120
           move.b #8,$ffffa1b
           bclr #0,$ffffa0f
           rte     
      
; ------------------------------------- 
; D‚grad‚ 2Šmes montagnes + scroll haut
; -------------------------------------

hbl3       add.b #1,conte
           cmp.b #32,conte
           bne.s pasla
           clr.l $ff8242
           clr.w $ff8246
           move.l #$5550666,$ff8252
           move.w #$777,$ff8256
pasla      cmp.b #44,conte
           beq.s newhbl3
           move.w (a3)+,$ff8250
           move.l (a3),$ff8248
           move.l (a3),$ff824c
           move.l (a3),$ff8258
           move.l (a3)+,$ff825c
           bclr #0,$ffffa0f
           rte

newhbl3    clr.b $ffffa1b
           bclr #0,$ffffa0f
           rte   

newkey     move.w #$2500,sr
           bclr #6,$ffffa11
           rte

; ********************
;
; DONNEES ET VARIABLES
;
; ********************

rasters    dc.w $137,$700,$700
           dc.w $247,$710,$710
           dc.w $347,$720,$720
           dc.w $447,$730,$730
           dc.w $547,$740,$740
           dc.w $647,$750,$750
           dc.w $657,$760,$760
           dc.w $757,$770,$770
           dc.w $767,$670,$670
           dc.w $777,$570,$570
           dc.w $767,$470,$470
           dc.w $757,$370,$370
           dc.w $657,$270,$270

           dc.w $543,$170,$170
           dc.w $654,$070,$070
           dc.w $765,$170,$170
           dc.w $654,$270,$270
           dc.w $543,$370,$370
           dc.w $654,$470,$470
           dc.w $765,$570,$570
           dc.w $654,$670,$670
           dc.w $543,$770,$770
           dc.w $654,$760,$760
           dc.w $765,$750,$750
           dc.w $654,$740,$740
           dc.w $543,$730,$730
           dc.w $654,$720,$720
           dc.w $765,$710,$710
           dc.w $654,$700,$700

           dc.w $137,$700,$700
           dc.w $247,$710,$710
           dc.w $347,$720,$720
           dc.w $447,$730,$730
           dc.w $547,$740,$740
           dc.w $647,$750,$750
           dc.w $657,$760,$760
           dc.w $757,$770,$770
           dc.w $767,$670,$670
           dc.w $777,$570,$570
           dc.w $767,$470,$470
           dc.w $757,$370,$370
           dc.w $657,$270,$270
           dc.w $647,$170,$170
           dc.w $547,$070,$070
           dc.w $447,$070,$070

fond       dc.w $000,$000,$000,$000,$070,$070,$070,$070
           dc.w $770,$555,$666,$777,$070,$070,$070,$070

stop_mouse dc.b $12
go_mouse   dc.b $8

save_vbl   ds.l 1
save_hbl   ds.l 1
old118     ds.l 1
decal      ds.w 1
oldrez     ds.w 1
oldscreen  ds.l 1
oldpal     ds.w 16
screen1    ds.l 1
screen2    ds.l 1
oldssp     ds.l 1
           ds.l 128
pile       ds.l 1
key        ds.b 1
palt       ds.b 1
conte      ds.b 1
savea11    ds.b 1
save_iera  ds.b 1
save_ierb  ds.b 1
save_imra  ds.b 1
save_imrb  ds.b 1

music      incbin "C:\DEVPAC3\ECRAN2\SOURCES\AN_COOL.DAT"
logo       incbin "C:\DEVPAC3\ECRAN2\SOURCES\ESSAI.DAT"
