; **************
;
; INITIALISATION
;
; **************

           opt o+

           section text
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

; ----------------
; Mode superviseur
; ----------------

           clr.l -(sp)
           move.w #$20,-(sp)
           trap #1
           addq.l #6,sp
           move.l d0,oldssp

; -------------------------
; Sauve et supprime clavier
; -------------------------

           move.b $484,key
           clr.b $484

; ---------------
; Supprime souris
; ---------------
 
           pea stop_mouse(pc)
           move.w #0,-(sp)
           move.w #$19,-(sp)
           trap #14
           addq.l #8,sp

; -------------
; Sauve palette
; -------------

           move.l #$ffff8240,a0
           lea oldpal,a1
           movem.l (a0)+,d0-d7
           movem.l d0-d7,(a1)

; ----
; Fade
; ----
           move.w #$777,d6
           moveq.w #6,d1
fade       move.w #60000,d2
           sub.w #$111,d6
           move.w d6,$ff8240
boukl      dbra d2,boukl
           move.w #37,-(sp)
           trap #14
           addq.l #2,sp
           dbra d1,fade

; ----------------
; Nouvelle palette
; ----------------

           pea logo+2
           move.w #6,-(sp)
           trap #14
           addq.l #6,sp
            
; ----------------
; Sauve resolution 
; ----------------

           move.w #4,-(sp)
           trap #14
           addq.l #2,sp 
           move.w d0,oldrez

; -------------------
; Sauve adresse ecran
; -------------------

           move.w #2,-(sp)
           trap #14
           addq.l #2,sp
           move.l d0,oldscreen

; ----------------
; Cree deux ecrans
; ----------------

           move.l #$60000,screen1
           move.l #$67d00,screen2

; ---------------------------
; Change resolution et ecrans
; ---------------------------

           clr.w -(sp)
           move.l screen1,-(sp)
           move.l screen2,-(sp)
           move.w #5,-(sp)
           trap #14
           add.l #12,sp

; ----------------------
; Efface les deux ecrans
; ----------------------

           move.l screen1,a0
           move.l screen2,a1
           move.w #7999,d0

boucle     clr.l (a0)+
           clr.l (a1)+
           dbra d0,boucle

; ----------------------------
; Affiche logo 'BLACK RAINBOW'
; ----------------------------

          lea logo+34,a0
          move.l screen1,a1
          move.l screen2,a2    
          move.w #2919,d0
ici       move.l (a0),(a1)+
          move.l (a0),(a2)+
          clr.l (a0)+
          dbra d0,ici
          
; ------------
; Init musique
; ------------

           moveq #1,d0
           bsr music

; ----------------------
; Init timers et synchro
; ----------------------

           move.b $fffa07,save_iera
           move.b $fffa09,save_ierb
           move.b $fffa11,savea11
           move.b $fffa13,save_imra
           move.l $70,save_vbl
           move.l $118,old118
           move.l $120,save_hbl
           and.b #0,$fffa07
           and.b #$40,$fffa09
           bset #3,$fffa17
           move.l #hbl1,$120
           move.l #newkey,$118
           move.l #vbl,$70           
           or.b #1,$fffa07
           or.b #1,$fffa13

; --------------
; Inits diverses
; --------------

           move.l #font,adresse
           move.l #fonte01,palette
           move.l #buffer+34*64,adr

           move.l #dist,michel
           move.l #text,txt_ptr
           move.l #text,txt_deb
           move.w #40,bligne2
           move.w #80,bligne3

           move.l adresse,a0
           move.l adr,a1

           move.w #16*32-1,d0
bouc       move.l (a0)+,(a1)+
           dbra d0,bouc
           
; ********************* 
; *                   *
; * BOUCLE PRINCIPALE *
; *                   *
; *********************

loop       tst.b vbl_state
           beq.s loop
           clr.b vbl_state

; *******
;
; Palette
;
; *******
      
           lea logo+2,a0
           lea $ff8240,a1
           movem.l (a0)+,d0-d7
           movem.l d0-d7,(a1)

; *******
;
; MUSIQUE
;
; *******

           movem.l a3/a6,-(sp)
           bsr music_exec                   
           movem.l (sp)+,a3/a6

; ****************
;
; LED DES LECTEURS
;
; ****************

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

; ***********
;
; CHOIX FONTE 
;
; ***********

fin        cmp.b #0,dummy
           bne pastest

; --------
; Test bas
; --------

           cmp.b #$50,$ffffc02
           bne.s testhaut
           cmp.b #15,nbrfont
           beq.s testhaut
           add.b #1,nbrfont
           add.l #64*32,adresse
           add.l #28,palette
           move.b #1,dummy

; ---------
; Test haut
; ---------

testhaut   cmp.b #$48,$ffffc02
           bne.s pastest
           cmp.b #0,nbrfont
           beq.s pastest
           sub.b #1,nbrfont
           sub.l #64*32,adresse
           sub.l #28,palette
           move.b #1,dummy 

; -----------
; Autre fonte 
; -----------           

pastest    cmp.b #1,dummy
           bne plusloin

           cmp.b #34,bas
           beq.s monte
           add.b #1,bas
           sub.l #64,adr
           bra plusloin

monte      cmp.b #0,haut
           bne parla1
           move.l adresse,a0
           move.l adr,a1
           add.l #34*64,a1
           move.w #7,d0
encore     rept 4
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           endr
           dbra d0,encore
      
           move.l palette,a0
           lea raster1,a1
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+

parla1     cmp.b #34,haut
           beq.s raz
           add.b #1,haut
           add.l #64,adr
           bra.s plusloin

raz        clr.b bas
           clr.b haut
           clr.b dummy

plusloin   move.l adr,a0
           move.l screen1,a1
           add.l #48+92*160,a1   
           bsr fontaff

; ********
;
; Cubes 3D
;
; ********

           lea cube,a0
           move.l screen1,a1
           add.w #96*160,a1
           lea 144(a1),a2
           add.w #400,dcub
           cmp.w #5600,dcub
           bne.s youp
           clr.w dcub
youp       move.w dcub,d0
           add.w d0,a0
           move.w #24,d0
cubeloop   movem.l (a0)+,d1-d4
           movem.l d1-d4,(a1)        
           movem.l d1-d4,(a2)        
           lea 160(a1),a1
           lea 160(a2),a2
           dbra d0,cubeloop

; **********
;
; SCROLLTEXT
;
; **********

; ----------
; Caracteres
; ----------

           moveq #0,d0
           move.b bit,d0
           cmp.b #16,d0
           bne.s plus
           clr.b bit
           move.l txt_ptr,a0
           move.b (a0),d0
           cmp.b #255,d0
           bne.s suite
           move.l txt_deb,txt_ptr
           move.l txt_ptr,a0
           move.b (a0),d0
suite      addq.l #1,txt_ptr
           asl #5,d0

; -------------------
; Caractere -> Buffer
; -------------------

           lea fontcar,a0
           add.l d0,a0
           lea logo+34+24*160,a1
           move.l (a0),(a1)
           move.l 4(a0),4(a1)
           move.l 8(a0),8(a1)
           move.l 12(a0),12(a1)
           move.l 16(a0),16(a1)
           move.l 20(a0),20(a1)
           move.l 24(a0),24(a1)
           move.l 28(a0),28(a1)

plus       add.b #2,bit

; ------------------------
; Scroll buffer -> travail
; ------------------------

           lea logo+34+24*160,a1
           lea (a1),a0
           lea logo+4*160+34,a4
           lea (a4),a2
           move.w #15,d0  

scroll     roxl (a1)+  
           roxl 152(a4)
           roxl 144(a4)
           roxl 136(a4)
           roxl 128(a4)
           roxl 120(a4)
           roxl 112(a4)
           roxl 104(a4)  
           roxl 96(a4)   
           roxl 88(a4)
           roxl 80(a4)
           roxl 72(a4)
           roxl 64(a4)
           roxl 56(a4)
           roxl 48(a4)
           roxl 40(a4)
           roxl 32(a4)
           roxl 24(a4)
           roxl 16(a4)
           roxl 8(a4)
           roxl (a4)
           lea 160(a4),a4
           dbra d0,scroll

           move.w #15,d0
scroll1    roxl (a0)+  
           roxl 152(a2)
           roxl 144(a2)
           roxl 136(a2)
           roxl 128(a2)
           roxl 120(a2)
           roxl 112(a2)
           roxl 104(a2)  
           roxl 96(a2)   
           roxl 88(a2)
           roxl 80(a2)
           roxl 72(a2)
           roxl 64(a2)
           roxl 56(a2)
           roxl 48(a2)
           roxl 40(a2)
           roxl 32(a2)
           roxl 24(a2)
           roxl 16(a2)
           roxl 8(a2)
           roxl (a2)
           lea 160(a2),a2
           dbra d0,scroll1

; ------------
; Coor40 -> +2
; ------------
  
           lea coor40+2,a0
           lea coor40,a1
           move.w #78,d0
tutu       move.w (a0)+,(a1)+
           dbra d0,tutu

           
           move.l michel,a0
           lea 4(a0),a0
           cmp.l #text,a0
           bne.s labas
           move.l #dist,a0
labas      move.l a0,michel
           move.w (a0),d0
           lea coor40+78,a0
           move.w d0,(a0)

; ----------------
; Travail -> ecran
; ----------------

           lea logo+34,a2
           lea coor40,a0
           move.l screen1,a1
           add.w #138*160,a1
           move.w #19,d0
           
loop_ligne move.w (a0)+,d1
           add.w d1,a1
           move.b (a2),(a1)
           move.b 160(a2),160(a1)
           move.b 320(a2),320(a1)
           move.b 480(a2),480(a1)
           move.b 640(a2),640(a1)
           move.b 800(a2),800(a1)
           move.b 960(a2),960(a1)
           move.b 1120(a2),1120(a1)
           move.b 1280(a2),1280(a1)
           move.b 1440(a2),1440(a1)
           move.b 1600(a2),1600(a1)
           move.b 1760(a2),1760(a1)
           move.b 1920(a2),1920(a1)
           move.b 2080(a2),2080(a1)
           move.b 2240(a2),2240(a1)
           move.b 2400(a2),2400(a1)
           move.b 2560(a2),2560(a1)
           move.b 2720(a2),2720(a1)
           move.b 2880(a2),2880(a1)
           move.b 3040(a2),3040(a1)
           move.b 3200(a2),3200(a1)
           move.b 3360(a2),3360(a1)
           sub.w d1,a1
           move.w (a0)+,d1
           add.w d1,a1
           move.b 1(a2),1(a1)
           move.b 161(a2),161(a1)
           move.b 321(a2),321(a1)
           move.b 481(a2),481(a1)
           move.b 641(a2),641(a1)
           move.b 801(a2),801(a1)
           move.b 961(a2),961(a1)
           move.b 1121(a2),1121(a1)
           move.b 1281(a2),1281(a1)
           move.b 1441(a2),1441(a1)
           move.b 1601(a2),1601(a1)
           move.b 1761(a2),1761(a1)
           move.b 1921(a2),1921(a1)
           move.b 2081(a2),2081(a1)
           move.b 2241(a2),2241(a1)
           move.b 2401(a2),2401(a1)
           move.b 2561(a2),2561(a1)
           move.b 2721(a2),2721(a1)
           move.b 2881(a2),2881(a1)
           move.b 3041(a2),3041(a1)
           move.b 3201(a2),3201(a1)
           move.b 3361(a2),3361(a1)
           sub.w d1,a1
           lea 8(a1),a1
           lea 8(a2),a2
           dbra d0,loop_ligne
         
; ********************
;
; DONNEES ET VARIABLES
;
; ********************

           section bss
txt_deb    ds.l 1
txt_ptr    ds.l 1
michel     ds.l 1
bit        ds.b 1          

           section data
coor40     dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
           dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
           dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
           dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
dist       incbin "FONTDISC\DIST.DAT"
text       incbin "FONTDISC\TEXTE.DAT"
           even
fontcar    incbin "FONTDISC\FONTCAR.DAT"
logo       incbin "FONTDISC\LOGO.DAT"

; ***************
;
; SWAPPING ECRANS
;
; ***************

           section text
           move.l screen1,d0
           move.l screen2,d1
           move.l d0,screen2
           move.l d1,screen1

           lsr.l #8,d0
           move.w #$8200,a0
           movep.w d0,1(a0)

           cmp.b #$39,$ffffc02              ; Appui sur espace ?
           bne loop

; ****************
;
; FIN DU PROGRAMME
;
; ****************

           
; --------------
; Restore timers
; --------------
           clr.b $ffffa1b
           bclr #0,$ffffa0f

           move.b savea11,$fffa11
           move.b save_iera,$fffa07
           move.b save_ierb,$fffa09
           move.b save_imra,$fffa13
           move.l save_vbl,$70
           move.l old118,$118
           move.l save_hbl,$120

; -----------
; Chip sonore
; -----------

           move.b #8,$ff8800
           move.b #0,$ff8802
           move.b #9,$ff8800
           move.b #0,$ff8802
           move.b #$a,$ff8800
           move.b #0,$ff8802

; -------------------
; Resolution et ecran
; -------------------
        
           move.w oldrez,-(sp)
           move.l oldscreen,-(sp)
           move.l oldscreen,-(sp)
           move.w #5,-(sp)
           trap #14
           add.l #12,sp

; -------
; Palette
; -------          

           lea oldpal,a0
           move.l #$ffff8240,a1
           movem.l (a0)+,d0-d7
           movem.l d0-d7,(a1)

; ------
; Souris
; ------
 
           pea go_mouse(pc)
           move.w #0,-(sp)
           move.w #$19,-(sp)
           trap #14
           addq.l #8,sp

; -------
; Clavier
; -------

           move.b key,$484

; ---------
; USER mode
; ---------

           move.l oldssp,-(sp)
           move.w #$20,-(sp)
           trap #1
           addq.l #6,sp

; -------------
; Retour au dos
; -------------

           clr.w -(sp)
           trap #1

; *******************
; *                 *
; * SOUS PROGRAMMES *
; *                 *
; *******************


; -------------
; Affiche fonte
; -------------

fontaff    move.w #7,d0

ligne      rept 4
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           lea 96(a1),a1
           endr
           dbra d0,ligne
           rts

; **********************   
; *                    *
; * SYNCHRO ET RASTERS *
; *                    *
; ********************** 

vbl        move.b #1,vbl_state
           clr.b cmptr

           lea barre1,a0
           lea barre2,a1
           lea barre3,a2
           lea rasters,a3
           lea toto,a6

           clr.l (a6)
           clr.l 4(a6)
           clr.l 8(a6)
           clr.l 12(a6)
           clr.l 16(a6)
           clr.l 20(a6)
           clr.l 24(a6)
           clr.l 28(a6)
           clr.l 32(a6)
           clr.l 36(a6)
           clr.l 40(a6)
           clr.l 44(a6)
           clr.l 48(a6)
           clr.l 52(a6)
           clr.l 56(a6)
           clr.l 60(a6)
           clr.l 64(a6)
           clr.l 68(a6)
           clr.l 72(a6)
           clr.l 76(a6)
           clr.l 80(a6)
           clr.l 84(a6)
           clr.l 88(a6)
           clr.l 92(a6)
           clr.l 96(a6)
           clr.l 100(a6)
           clr.l 104(a6)
           clr.l 108(a6)

; -------
; Barre 1
; -------

           cmp.b #1,sbarre1
           bne.s pouet1

           sub.w #2,bligne1
           cmp.w #0,bligne1
           bne.s pasvaleur1
           clr.b sbarre1

pouet1     add.w #2,bligne1
           cmp.w #92,bligne1
           bne.s pasvaleur1
           move.b #1,sbarre1

pasvaleur1 move.w bligne1,d0
           move.l (a0),0(a6,d0.w)
           move.l 4(a0),4(a6,d0.w)
           move.l 8(a0),8(a6,d0.w)
           move.l 12(a0),12(a6,d0.w)
           move.w 16(a0),16(a6,d0.w)

; -------
; Barre 2
; -------

           cmp.b #1,sbarre2
           bne.s pouet2

           sub.w #2,bligne2
           cmp.w #0,bligne2
           bne.s pasvaleur2
           clr.b sbarre2

pouet2     add.w #2,bligne2
           cmp.w #92,bligne2
           bne.s pasvaleur2
           move.b #1,sbarre2

pasvaleur2 move.w bligne2,d0
           move.l (a1),0(a6,d0.w)
           move.l 4(a1),4(a6,d0.w)
           move.l 8(a1),8(a6,d0.w)
           move.l 12(a1),12(a6,d0.w)
           move.w 16(a1),16(a6,d0.w)

; -------
; Barre 3
; -------

           cmp.b #1,sbarre3
           bne.s pouet3

           sub.w #2,bligne3
           cmp.w #0,bligne3
           bne.s pasvaleur3
           clr.b sbarre3

pouet3     add.w #2,bligne3
           cmp.w #92,bligne3
           bne.s pasvaleur3
           move.b #1,sbarre3

pasvaleur3 move.w bligne3,d0
           move.l (a2),0(a6,d0.w)
           move.l 4(a2),4(a6,d0.w)
           move.l 8(a2),8(a6,d0.w)
           move.l 12(a2),12(a6,d0.w)
           move.w 16(a2),16(a6,d0.w)

           move.b #74,$fffffa21         
           move.l #hbl1,$120
           move.b #8,$fffffa1b           ; Demarre le TIMER B
           rte

; ********************
;
; Donnees et variables
;
; ********************

           section data
barre1     dc.w $722,$733,$744,$755,$777,$755,$744
           dc.w $733,$722
barre3     dc.w $034,$045,$056,$067,$777,$067,$056
           dc.w $045,$034
barre2     dc.w $333,$444,$555,$666,$777,$666,$555
           dc.w $444,$333
           section bss
bligne1    ds.w 1
bligne2    ds.w 1
bligne3    ds.w 1
sbarre1    ds.b 1
sbarre2    ds.b 1
sbarre3    ds.b 1
           even

; -------
; Timer B
; -------

           section text
hbl1       move.b #0,$fffffa1b           ; Stoppe TIMER B
           move.b #1,$fffffa21           ; Data register=1
           move.l #hbl2,$120
           move.b #8,$fffffa1b           ; Demmare TIMER B
           bclr #0,$fffffa0f
           rte

hbl2       add.b #1,cmptr
           cmp.b #17,cmptr
           beq.s newhbl
           move.w (a3)+,$ff8240
           bclr #0,$fffffa0f
           rte
          
newhbl     move.b #0,cmptr
           move.b #0,$fffffa1b
           move.l #hbl3,$120
           move.b #8,$fffffa1b
           bclr #0,$fffffa0f
           rte
           
hbl3       move.l (a3)+,$ff8242
           move.l (a3)+,$ff8246
           move.l (a3)+,$ff824a
           move.l (a3)+,$ff824e
           move.l (a3)+,$ff8252
           move.l (a3)+,$ff8256
           move.l (a3)+,$ff825a
           move.b #0,$fffffa1b
           move.l #hbl4,$120
           move.b #31,$fffffa21
           move.b #8,$fffffa1b           
           bclr #0,$fffffa0f
           rte

hbl4       move.b #0,$fffffa1b
           move.l #hbl5,$120
           move.b #1,$fffffa21
           move.b #8,$fffffa1b
           bclr #0,$fffffa0f
           rte

hbl5       add.b #1,cmptr
           cmp.b #18,cmptr
           beq.s newhbl3
           move.w (a3)+,$ff8240
           bclr #0,$fffffa0f
           rte
 
newhbl3    move.b #0,$fffffa1b
           move.b #0,cmptr
           move.l #hbl6,$120
           move.b #8,$fffffa1b           
           bclr #0,$fffffa0f
           rte

hbl6       add.b #1,cmptr
           cmp.b #57,cmptr
           beq.s newhbl4
           move.w (a3)+,$ff8242
           move.w (a6)+,$ff8240
           bclr #0,$fffffa0f
           rte

newhbl4    move.b #0,$fffffa1b
           bclr #0,$fffffa0f
           rte

newkey     move.w #$2500,sr
           bclr #6,$fffffa11
           rte

; ********************
;
; DONNEES ET VARIABLES
;
; ********************

; ------------------
; Raster et palettes
; ------------------

rasters    dc.w $001,$002,$003,$004,$005,$006,$007,$007
           dc.w $006,$005,$004,$003,$002,$001,$000,$000

raster1    dc.w $250,$777,$666,$555,$444,$333,$222
           dc.w $111,$235,$225,$024,$114,$003,$002

           dc.w $000,$000,$001,$002,$003,$004,$005,$006
           dc.w $007,$007,$006,$005,$004,$003,$002,$001
           dc.w $000

           dc.w $100,$200,$300,$400,$500,$600,$700,$710
           dc.w $720,$730,$740,$750,$760,$770,$771,$772
           dc.w $773,$774,$775,$776,$777,$767,$757,$747
           dc.w $737,$727,$717,$707,$617,$527,$437,$347
           dc.w $257,$167,$077,$076,$075,$074,$073,$072
           dc.w $071,$070,$170,$270,$370,$470,$570,$670
           dc.w $770,$760,$750,$740,$730,$720,$710,$700

; ---------------
; Palettes fontes
; ---------------

fonte01    dc.w $250,$777,$666,$555,$444,$333,$222
           dc.w $111,$235,$225,$024,$114,$003,$002
           dc.w $111,$222,$333,$444,$555,$666,$777
           dc.w $250,$250,$250,$250,$250,$250,$250
           dc.w $577,$467,$356,$245,$134,$123,$400
           dc.w $250,$250,$250,$250,$250,$250,$250
           dc.w $420,$531,$542,$652,$653,$663,$664
           dc.w $001,$002,$003,$004,$005,$006,$007
           dc.w $250,$777,$655,$433,$554,$443,$250
           dc.w $250,$250,$250,$250,$220,$110,$211
           dc.w $300,$400,$510,$520,$630,$640,$750
           dc.w $250,$250,$250,$250,$250,$250,$250
           dc.w $250,$250,$250,$250,$250,$250,$250
           dc.w $250,$250,$250,$656,$545,$434,$323
           dc.w $250,$250,$250,$250,$250,$250,$250
           dc.w $250,$446,$113,$224,$335,$557,$250
           dc.w $112,$223,$334,$445,$556,$667,$777
           dc.w $000,$250,$250,$250,$250,$250,$250
           dc.w $250,$250,$250,$250,$250,$250,$250
           dc.w $250,$111,$222,$333,$444,$555,$666
           dc.w $222,$333,$444,$555,$666,$777,$250
           dc.w $250,$250,$250,$250,$250,$250,$250
           dc.w $200,$300,$410,$520,$630,$740,$752
           dc.w $250,$250,$250,$250,$250,$250,$250
           dc.w $100,$200,$300,$400,$500,$600,$700
           dc.w $250,$250,$250,$250,$250,$250,$223
           dc.w $213,$010,$020,$030,$040,$325,$431
           dc.w $541,$543,$643,$653,$546,$764,$250
           dc.w $211,$322,$433,$544,$655,$766,$777
           dc.w $002,$003,$114,$224,$335,$445,$556
           dc.w $250,$250,$250,$250,$250,$250,$250
           dc.w $000,$111,$222,$333,$444,$555,$666

key        ds.b 1
           even
save_vbl   ds.l 1
old118     ds.l 1
oldscreen  ds.l 1
screen1    ds.l 1
screen2    ds.l 1
adresse    ds.l 1
adr        ds.l 1
palette    ds.l 1

save_hbl   ds.l 1
oldssp     ds.l 1
           ds.l 128
pile       ds.l 1

buffer     ds.w 132*16
toto       ds.w 56
oldrez     ds.w 1
oldpal     ds.w 16
dcub       ds.w 1

vbl_state  ds.b 1
cmptr      ds.b 1
dummy      ds.b 1
haut       ds.b 1
bas        ds.b 1
nbrfont    ds.b 1
savea11    ds.b 1
save_iera  ds.b 1
save_ierb  ds.b 1
save_imra  ds.b 1
stop_mouse dc.b $12
go_mouse   dc.b $8 
           even

music      incbin "FONTDISC\MAX.DAT"
cube       incbin "FONTDISC\CUBE1.DAT"
music_exec equ music+8
font       incbin "FONTDISC\FONT.DAT"

