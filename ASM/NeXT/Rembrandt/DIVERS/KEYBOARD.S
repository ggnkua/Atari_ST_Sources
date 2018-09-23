;
; Routine clavier/souris pour Rembrandt.
;
; Doit g‚rer:
; - La souris
;   - Vitesse variable
;   - Inversion des boutons pour les gauchers
;
; - Le clavier
;   - Appui+Relachement des touches
;   - R‚p‚tition clavier
;   - Gestion des touches mortes
;   - D‚tection d'appuis multiple
;   - Combinaisons sp‚ciales (RESET...)
;
affichage=1

col2=0
col4=1
col16=2
col256=3
coltc=4

l40=0
l80=8

tv=0
vga=16
pal=32
overscan=64
st=128
interlace=256

mode=coltc+l40+tv+pal

 move.l #ecran+4,d0
 and.b #252,d0
 move.l d0,‚cran

 ifne affichage 
   move #-1,-(sp)
   move #88,-(sp)
   trap #14
   addq #4,sp
   move d0,sauve_rez
 
   move #2,-(sp)
   trap #14
   addq #2,sp
   move.l d0,sauve_physique

   move #3,-(sp)
   trap #14
   addq #2,sp
   move.l d0,sauve_logique
 
   move #mode,-(sp)
   move #3,-(sp)
   move.l ‚cran,-(sp)
   move.l ‚cran,-(sp)
   move #5,-(sp)
   trap #14
   add #14,sp
 endc
 
 pea main(pc)
 move #$26,-(sp)
 trap #14
 addq #6,sp
 
* move #1,-(sp)
* trap #1
* addq #2,sp

 ifne affichage 
   move sauve_rez,-(sp)
   move #3,-(sp)
   move.l sauve_physique,-(sp)
   move.l sauve_logique,-(sp)
   move #5,-(sp)
   trap #14
   add #14,sp
 endc
  
 clr -(sp)
 trap #1



main
 pea data_kybd
 move #3-1,-(sp)
 move #25,-(sp)
 trap #14
 addq #8,sp
 
 
 move #$2700,sr
 move.l $118.w,sauve_118
 move.l #routine_118,$118.w
 move #$2300,sr

 move #160,mousex
 move #100,mousey
 
loop
 move #37,-(sp)
 trap #14
 addq #2,sp
 
 cmp.b #$39,code_touche
 beq end_loop

 move.l ‚cran,a0
 move mousex,d0
 move x_offset,d1
 asr #2,d1
 add d1,d0
* clr x_offset
 and #255,d0
 add d0,d0
 add d0,a0
 move mousey,d0
 move y_offset,d1
 asr #2,d1
 add d1,d0
* clr y_offset
 and #127,d0
 mulu #640,d0
 add.l d0,a0

 tst boutons
 beq.s .no_draw
 move cpt,(a0)
.no_draw
 addq #8,cpt
  
* move.l #-1,$ffff9800.w
 tst.b flag_touche_press‚e
 beq.s .touche_relach‚e
 nop
* move.l #$ff000000,$ffff9800.w
.touche_relach‚e

 bra loop
end_loop
 
 move #$2700,sr
 move.l sauve_118,$118.w
 move #$2300,sr
 rts


   
routine_118
 move.l #$ff000000,$ffff9800.w
 move.l d0,-(sp)
 move.l d1,-(sp)
 move.l d2,-(sp)
 moveq #0,d0
 moveq #0,d1
debut
 move.b $fffffc00.w,d0
 btst #7,d0
 beq.s fin_2  ; -> si le bit 7 est nul,alors pas d'interrupt clavier.
 
 btst #0,d0
 beq.s fin_1  ; -> si le bit 0 est nul,alors pas d'octet en attente.

 tst.b longueur_pack
 bne.s lecture_pack 

 move.b $fffffc02.w,d1
 bmi gŠre_code_n‚gatif
 move.b d1,code_touche
 st flag_touche_press‚e
fin_1
 and.b #$20,d0
 beq.s fin_2
 move.b $fffffc02.w,d0
fin_2
 btst #4,$fffffa01.w
 beq.s debut
 bclr #6,$fffffa11.w
 move.l (sp)+,d2
 move.l (sp)+,d1
 move.l (sp)+,d0
 move.l #-1,$ffff9800.w
 rte

lecture_pack
 jsr ([routine_lecture_pack])
 subq.b #1,longueur_pack 
 bra fin_2

routine_lecture_pack	dc.l routine_dummy

routine_dummy
 move.b $fffffc02.w,d1
 rts

routine_lecture_x
 move.b $fffffc02.w,d1
 ext d1
 add d1,x_offset
 move.l #routine_lecture_y,routine_lecture_pack
 rts

routine_lecture_y
 move.b $fffffc02.w,d1
 ext d1
 add d1,y_offset
 move.l #routine_dummy,routine_lecture_pack
 rts
     
gŠre_code_n‚gatif
 cmp #$f8,d1
 beq.s gŠre_header_1
 cmp #$f9,d1
 beq.s gŠre_header_1
 cmp #$fa,d1
 beq.s gŠre_header_1
 cmp #$fb,d1
 beq.s gŠre_header_1
gŠre_code_relachement
 sf flag_touche_press‚e
 bra fin_2

gŠre_header_1
 move.b d1,num‚ro_header
 and #%11,d1
 move.b d1,boutons
 move.l #routine_lecture_x,routine_lecture_pack
 move.b #2,longueur_pack
 bra fin_2

gŠre_header_2
 move.b #3,longueur_pack
 bra fin_2
  
* f6 -> lecture m‚moire

* f7 -> souris absolue

* f8 -> souris relative
* f9 ->
* fa ->
* fb ->

* fc -> valeur de l'horloge
 
* fd ->

* fe -> joy 0
* ff -> joy 1
   
 DATA


data_kybd
 dc.b $0b,1,1,0
 

 BSS
 even
 
sauve_rez		ds.w 1 
sauve_logique		ds.l 1
sauve_physique		ds.l 1
‚cran			ds.l 1
ecran			ds.l 256000/4

sauve_118		ds.l 1

cpt			ds.w 1

mousex			ds.w 1
mousey			ds.w 1
boutons			ds.b 1

x_offset		ds.w 1
y_offset		ds.w 1

code_touche		ds.b 1
flag_touche_press‚e	ds.b 1
longueur_pack 		ds.b 1
num‚ro_header		ds.b 1

 END
 