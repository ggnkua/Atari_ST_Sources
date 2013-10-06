debug=0
;
; Routine destin‚e … simuler une bombe a‚rosol contenant de la peinture.
; Voici la m‚thode … utiliser:
;
; Soit R le rayon d'action de l'a‚rosol.
; Soit V la vitesse d'action. (Dur‚e pour passer de la couleur d'origine
; … la couleur de l'a‚rosol.
;
; - L'a‚rosol projete les points dans un cercle de rayon R.
; - Pour chaque point du cercle:
;   - Calculer la distance entre ce point et le centre du cercle.
;     [ Dý=Xý+Yý  D=û(X+Y) ]
;     Ce qui permet d'ailleur de r‚utiliser ma formule de calcul de racine
;     carr‚e en asm ! (Chouette)
;   - En d‚duire la probabilit‚ [0;1] que ce point soit touch‚ par de la
;     peinture. Il est ‚vident que les points du centre ont plus de chances
;     d'etre color‚s que ceux du pourtour ! (On prend une r‚partition
;     lin‚raire de la pulv‚risation, allant de 1 au centre, jusqu'… 0 sur
;     le pourtour.
;     [ F=1-(D/R ]
;   - Changer la couleur du point !
;
; Hum. Cette routine ne fait pas tout ca ! En fait, elle travaille de
; fa‡on homogene sur un disque de rayon variable, a une vitesse elle...
; aussi variable.
;
; Utilisation:
; - Pick-Up d'une couleur avec le bouton droit.
; - Pulv‚risation avec le bouton gauche
; - R‚glage de la taille avec [SHIFT GAUCHE] et [Alternate]
; - Changement de la vitesse avec ???? Je sais pas encore !
;
; Quelques constantes pour les modes vid‚os
;
;
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

mode=coltc+l40+tv+pal+OVERSCAN
XREZ=384
YREZ=240

 pea superviseur
 move #$26,-(sp)
 trap #14
 addq #6,sp
;
; Et quitte
; 
 clr -(sp)
 trap #1

 include E:\PROJETS\REMBRAND\FICHIERS.INC\MACROS.S

 
superviseur 
 move #%1111100000000000,couleur	Un rouge vif !
 
 move.l #ecran+4,d0
 and #-1-%11,d0
 move.l d0,‚cran

 dc.w $a000
 move.l a0,_linebase
  
 ifeq debug
;
; R‚cupŠre la r‚solution courante et l'adresse de la m‚moire
; vid‚o
;
 move #-1,-(sp)
 move #88,-(sp)
 trap #14
 addq #4,sp
 move d0,old_video
 
 move #2,-(sp)
 trap #14
 addq #2,sp
 move.l d0,old_adresse

;
; Valide ma propre r‚solution
; et mon propre ecran
; 
 move #mode,-(sp)
 move #3,-(sp)
 move.l ‚cran,-(sp)
 move.l ‚cran,-(sp)
 move #5,-(sp)
 trap #14
 add #14,sp
 endc

 bsr affichage
 
* move #7,-(sp)
* trap #1
* addq #2,sp
 
;
; Restaure tout
; 
 ifeq debug
 move old_video,-(sp)
 move #3,-(sp)
 move.l old_adresse,-(sp)
 move.l old_adresse,-(sp)
 move #5,-(sp)
 trap #14
 add #14,sp
 endc
 rts





affichage
 lea image,a0
 add tcp_main_offset(a0),a0
 add tcp_data_offset(a0),a0
 move.l ‚cran,a1
 move #128000/4,d0
.loop
 move.l (a0)+,(a1)+
 dbra d0,.loop 
 move #20,r
 
boucle
 getshift
 btst #1,d0
 beq.s .pas_zoom_out
 subq #1,r
.pas_zoom_out
 btst #3,d0
 beq.s .pas_zoom_in
 addq #1,r
.pas_zoom_in
 
 getmouse
 cmp #3,mousek
 beq .fin_affichage
 cmp #1,mousek
 bne .continue_trace
 move mousex,cx
 move mousey,cy
 bsr pssshhhhiiiittt
 bsr vsync
 bsr vsync
 bra boucle

.continue_trace
 cmp #2,mousek
 bne .pas_pick_up
 move.l ‚cran,a0
 move mousey,d0
 mulu #XREZ*2,d0
 add.l d0,a0
 add mousex,a0
 add mousex,a0
 move (a0),couleur
 bra boucle

.pas_pick_up
 move mousex,cx
 move mousey,cy
 bsr trace_cercle_fantome
 bsr attend_mouvement
 bsr vsync
 bsr trace_cercle_fantome
 bra boucle
 
.fin_affichage
 rts

 
vsync
 move #37,-(sp)
 trap #14
 addq #2,sp
 rts
 
attend_mouvement
 move.l d0,-(sp)
 move.l xy1,d0
.attend_mouvement
 getmouse
 getshift
 tst d0
 bne.s .fin_attente
 tst mousek
 bne.s .fin_attente 
 cmp.l mousexy,d0
 beq.s .attend_mouvement
.fin_attente
 move.l (sp)+,d0
 rts







pssshhhhiiiittt
 move.l ‚cran,a0

 move cy,d0
 mulu #XREZ*2,d0
 add.l d0,a0

 moveq #0,d6		D6: Xi=0
 move r,d7		D7: Yi=R

 moveq #1,d4		D4: i=2(1-R)
 sub r,d4
 add d4,d4

 moveq #0,d5		D5: Limite=0

 sf flag_trac‚
 
_1
 tst.b flag_trac‚
 bne .fin_tra‡age

 st flag_trac‚

 move d7,d0		Plot (Xi,Yi)
 mulu #XREZ*2,d0
 lea (a0,d0.l),a1	Ligne du bas...
 neg.l d0
 lea (a0,d0.l),a2	Ligne du haut !


.teste_bas
 move cy,d1
 add d7,d1
 cmp #YREZ-1,d1
 bgt .teste_haut
.trace_en_bas
 move.l a1,a6		Adresse de base
 move cx,d0	D‚but
 sub d6,d0
 move cx,d1  	Fin
 add d6,d1
 bsr trace_segment_spray


.teste_haut
 tst d7
 beq .fin_tra‡age	Une seule ligne centrale !
 move cy,d1
 sub d7,d1
 bmi .fin_tra‡age
.trace_en_haut
 move.l a2,a6		Adresse de base
 move cx,d0
 sub d6,d0
 move cx,d1  	Fin
 add d6,d1
 bsr trace_segment_spray

.fin_tra‡age

 cmp d5,d7		If YióLimite then 4
 ble _4

 tst d4
 bmi _2			If i<0 then 2
 beq _20		If i=0 then 20
 bra _3			If i>0 then 3

 
_2
 move d4,d3		D3: ë=2(i+Yi)-1
 add d7,d3
 add d3,d3
 subq #1,d3

 bpl _20		If ë>0 then 20
 bra _10		If ëó0 then 10

 
_3
 move d4,d3		D3: ë=2(i+Xi)-1
 add d6,d3
 add d3,d3
 subq #1,d3

 bpl _30		If ë>0 then 30
 bra _20		If ëó0 then 20


_10
 addq #1,d6		Xi=Xi+1

 add d6,d4		D4: i=i+2Xi+1
 add d6,d4
 addq #1,d4
 
 bra _1


_20
 addq #1,d6		Xi=Xi+1
 subq #1,d7		Yi=Yi-1
 sf flag_trac‚

 add d6,d4		D4: i=i+2Xi-2Yi+2
 add d6,d4
 sub d7,d4
 sub d7,d4
 addq #2,d4
 
 bra _1


_30
 subq #1,d7		Yi=Yi-1
 sf flag_trac‚
 sub d7,d4		D4: i=i-2Yi+1
 sub d7,d4
 addq #1,d4
 
 bra _1
 
_4
 rts





trace_segment_spray
 movem.l d0-a6,-(sp)

 tst d0			Teste la limite de gauche
 bpl .pas_x_n‚gatif
 moveq #0,d0
.pas_x_n‚gatif
 
 cmp #XREZ,d1		Teste la limite de droite
 blt .pas_x_maximum
 move #XREZ-1,d1
.pas_x_maximum

 sub d0,d1		Nombre de points … tracer
 lea (a6,d0.w*2),a5

 move couleur,d5
 move d5,d7
 and #%11111,d7		D7=bleu de la couleur a mettre
 move d5,d6
 lsr #5,d6
 and #%111111,d6	D6=vert de la couleur a mettre
 rol #5,d5
 and #%11111,d5		D5=rouge de la couleur a mettre


.trace_point   
 move (a5),d2
 move d2,d4
 and #%11111,d4		D4=bleu initial
 move d2,d3
 lsr #5,d3
 and #%111111,d3	D3=vert initial
 rol #5,d2
 and #%11111,d2		D2=rouge initial
*
 cmp d7,d4
 beq .fin_rouge
 bmi .plus_rouge
.moins_rouge
 subq #1,d4
 bra .fin_rouge 
.plus_rouge
 addq #1,d4
 bra .fin_rouge 
.fin_rouge 

 cmp d6,d3
 beq .fin_vert
 bmi .plus_vert
.moins_vert
 subq #1,d3
 bra .fin_vert 
.plus_vert
 addq #1,d3
 bra .fin_vert 
.fin_vert 

 cmp d5,d2
 beq .fin_bleu
 bmi .plus_bleu
.moins_bleu
 subq #1,d2
 bra .fin_bleu 
.plus_bleu
 addq #1,d2
 bra .fin_bleu 
.fin_bleu 

*
 ror #5,d2	Le rouge
 lsl #5,d3	Le vert
 or d4,d2
 or d3,d2
*
 move d2,(a5)+		Trace le point !
 dbra d1,.trace_point   
 movem.l (sp)+,d0-a6
 rts










trace_cercle_fantome
 move.l ‚cran,a0

 move cy,d0
 mulu #XREZ*2,d0
 add.l d0,a0

 move cx,d0
 add d0,d0
 add d0,a0		A0=Adresse du point central


 moveq #0,d6		D6: Xi=0
 move r,d7		D7: Yi=R

 moveq #1,d4		D4: i=2(1-R)
 sub r,d4
 add d4,d4

 moveq #0,d5		D5: Limite=0
 
_11
 move d7,d0		Plot (Xi,Yi)
 mulu #XREZ*2,d0
 lea (a0,d0.l),a1
 neg.l d0
 lea (a0,d0.l),a2
 move d6,d0
 add d0,d0

 move cx,d1		Cx+Rx' < 320 ???
 add d6,d1
 cmp #XREZ-1,d1
 bgt .clippe_droite 
   move cy,d1
   add d7,d1
   cmp #YREZ-1,d1
   bgt .clippe_droite_bas
     not (a1,d0.w) Bas droite
.clippe_droite_bas
   move cy,d1
   sub d7,d1
   bmi .clippe_droite_haut
     not (a2,d0.w) Haut droite
.clippe_droite_haut
.clippe_droite

 move cx,d1		Cx-Rx' > 0 ?
 sub d6,d1
 bmi .clippe_gauche
   neg.w d0
   move cy,d1
   add d7,d1
   cmp #YREZ-1,d1
   bgt .clippe_gauche_bas
     not (a1,d0.w) Bas gauche
.clippe_gauche_bas
   move cy,d1
   sub d7,d1
   bmi .clippe_gauche_haut
     not (a2,d0.w) Haut gauche
.clippe_gauche_haut
.clippe_gauche

 cmp d5,d7		If YióLimite then 4
 ble _44

 tst d4
 bmi _22			If i<0 then 2
 beq _220		If i=0 then 20
 bra _33			If i>0 then 3

 
_22
 move d4,d3		D3: ë=2(i+Yi)-1
 add d7,d3
 add d3,d3
 subq #1,d3

 bpl _220		If ë>0 then 20
 bra _110		If ëó0 then 10

 
_33
 move d4,d3		D3: ë=2(i+Xi)-1
 add d6,d3
 add d3,d3
 subq #1,d3

 bpl _330		If ë>0 then 30
 bra _220		If ëó0 then 20


_110
 addq #1,d6		Xi=Xi+1

 add d6,d4		D4: i=i+2Xi+1
 add d6,d4
 addq #1,d4
 
 bra _11


_220
 addq #1,d6		Xi=Xi+1
 subq #1,d7		Yi=Yi-1

 add d6,d4		D4: i=i+2Xi-2Yi+2
 add d6,d4
 sub d7,d4
 sub d7,d4
 addq #2,d4
 
 bra _11


_330
 subq #1,d7		Yi=Yi-1

 sub d7,d4		D4: i=i-2Yi+1
 sub d7,d4
 addq #1,d4
 
 bra _11

_44
 rts



;
; Calcul de racine carr‚e... Par la m‚thode de H‚ron.
; Impl‚mentation par Dbug II. La pr‚cision est bonne tant que l'on ne
; cherche pas … calculer une racine d'un nombre trop petit.
;
; Appeler avec le chiffre au carr‚ dans D0.l, la racine revient en D0.l
; Tous les registres sont pr‚serv‚s.
;
; Ex:
;   move.l #50000,d0
;   bsr racine_carr‚e   D0.L = 223
  
racine_carr‚e
 movem.l d1-d3,-(sp)
  
 move.l d0,d2
 mulu #875,d2
 divu.l #1000,d2		a=M*.875
 
 move.l d2,d1			X0=a

.next_it‚ration 
 move.l d1,d2			X(n+1)=X(n)
 move.l d0,d3			Quotien=M
 divu.l d1,d3			Quotien=Quotien/X(N)
 add.l d3,d2			X(n+1)=X(n+1)+Quotien
 lsr.l d2			X(n+1)=X(n+1)/2
 cmp.l d1,d2			DŠs que les deux sont ‚gaux, c'est que
 beq.s .termin‚			l'on … trouver la racine... (Aproch‚e)
 move.l d2,d1
 bra.s .next_it‚ration 
.termin‚
 move.l d1,d0
 movem.l (sp)+,d1-d3
 rts



  
 section DATA 

image		incbin "E:\AAAAAAAA.AAA\IMAGES.TCP\DREAMS.TCP

 rsreset
tcp_main_identificateur		rs.l 2
tcp_main_total_fichier		rs.l 1
tcp_main_offset			rs.w 1
tcp_main_version		rs.w 1
tcp_main_nombre_image		rs.w 1
tcp_main_longueur		rs.b 1

 rsreset
tcp_data_identificateur		rs.l 1
tcp_data_total_image		rs.l 1
tcp_data_offset			rs.w 1
tcp_data_largeur		rs.w 1
tcp_data_hauteur		rs.w 1
tcp_data_transparent		rs.w 1
tcp_data_crayon			rs.w 1
tcp_data_packing		rs.b 1
tcp_data_palette		rs.b 1
tcp_data_overscan		rs.b 1
tcp_data_double_largeur		rs.b 1
tcp_data_double_hauteur		rs.b 1
tcp_data_null			rs.b 1
tcp_data_commentaires		rs.b 175
tcp_data_longueur		rs.b 1

 section BSS

old_video	ds.w 1 
old_adresse	ds.l 1
‚cran		ds.l 1

ecran		ds.l 128000/4
		ds.l 128000/4

x	ds.w 1
y	ds.w 1
limite	ds.w 1
delta	ds.w 1

xy1
cx	ds.w 1
cy	ds.w 1
r	ds.w 1

_linebase	ds.l 1
mousexy		ds.w 1
mousex		ds.w 1
mousey		ds.w 1
mousek		ds.w 1
x_scroll	ds.w 1
y_scroll	ds.w 1
couleur		ds.w 1

flag_trac‚	ds.w 1

 end
 