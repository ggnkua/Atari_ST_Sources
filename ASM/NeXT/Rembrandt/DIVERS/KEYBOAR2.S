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
 move #8-1,-(sp)
 move #25,-(sp)
 trap #14
 addq #8,sp
 
 
 move #$2700,sr
 move.l $70.w,sauve_70
 move.l $118.w,sauve_118
 move.l #routine_70,$70.w
 move.l #routine_118,$118.w
 move #$2300,sr

loop
 move #37,-(sp)
 trap #14
 addq #2,sp
 
 cmp.b #$39,code_touche
 beq end_loop

 move.l ‚cran,a0
 move mousex,d0
 add d0,d0
 add d0,a0
 move mousey,d0
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
 move.l sauve_70,$70.w
 move.l sauve_118,$118.w
 move #$2300,sr

 pea data_kybd_2
 move #1-1,-(sp)
 move #25,-(sp)
 trap #14
 addq #8,sp

 rts


routine_70
 move.b #$0d,$fffffc02.w
 jmp ([sauve_70]) 

sauve_70	ds.l 1
   
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

routine_lecture_b
 move.b $fffffc02.w,d1
 and #3,d1
 move.b d1,boutons
 move.l #routine_lecture_x1,routine_lecture_pack
 rts

routine_lecture_x1
 move.b $fffffc02.w,mousex
 move.l #routine_lecture_x2,routine_lecture_pack
 rts

routine_lecture_x2
 move.b $fffffc02.w,mousex+1
 move.l #routine_lecture_y1,routine_lecture_pack
 rts

routine_lecture_y1
 move.b $fffffc02.w,mousey
 move.l #routine_lecture_y2,routine_lecture_pack
 rts

routine_lecture_y2
 move.b $fffffc02.w,mousey+1
 move.l #routine_dummy,routine_lecture_pack
 rts
     
gŠre_code_n‚gatif
 cmp #$f7,d1
 beq.s gŠre_header_1
gŠre_code_relachement
 sf flag_touche_press‚e
 bra fin_2

gŠre_header_1
 move.l #routine_lecture_b,routine_lecture_pack
 move.b #5,longueur_pack
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

 even
 dc.b 0
data_kybd
 dc.b 9
 dc.w 319
 dc.w 199
 dc.b $0c
 dc.b 3
 dc.b 3
 
data_kybd_2
 dc.b 8
 

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

code_touche		ds.b 1
flag_touche_press‚e	ds.b 1
longueur_pack 		ds.b 1
num‚ro_header		ds.b 1

 END
 