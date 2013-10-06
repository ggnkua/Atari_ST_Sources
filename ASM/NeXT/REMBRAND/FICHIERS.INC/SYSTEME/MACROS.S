boite_alerte macro button,string
 move.w \1,int_in
 move.l \2,a0
 move langue,d0
 move.l (a0,d0.w*4),addr_in
 aes 52
 endm


getmouse macro
 move d0,-(sp)
 move mousex_118,d0
 add x_scroll,d0
 move d0,mousex
 move mousey_118,d0
 add y_scroll,d0
 move d0,mousey
 move boutons_118,mousek
 move (sp)+,d0
 endm

relache macro
; Boucle ici !
 tst boutons_118
 bne.s *-6
 clr mousek
 endm


; 0 - $36 - SHIFT droit
; 1 - $2a - SHIFT gauche
; 2 - $1d - CONTROL
; 3 - $38 - ALTERNATE
; 4 - $3a - CAPS LOCK
; 5 - $47 - CLR HOME (bouton droit)
; 6 - $52 - INSERT (bouton gauche)

getshift macro
 moveq #0,d0
 lea ‚tat_touches,a0
 tst.b (a0,$36)
 beq.s .pas_shift_droit
 bset #0,d0
.pas_shift_droit
 tst.b (a0,$2a)
 beq.s .pas_shift_gauche
 bset #1,d0
.pas_shift_gauche
 tst.b (a0,$1d)
 beq.s .pas_control
 bset #2,d0
.pas_control
 tst.b (a0,$38)
 beq.s .pas_alternate
 bset #3,d0
.pas_alternate
 tst.b (a0,$3a)
 beq.s .pas_caps_lock
 bset #4,d0
.pas_caps_lock
 tst.b (a0,$47)
 beq.s .pas_clr_home
 bset #5,d0
.pas_clr_home
 tst.b (a0,$52)
 beq.s .pas_insert
 bset #6,d0
.pas_insert
* move #-1,-(sp)		Signification des bits de D0:
* move #11,-(sp)		0 - SHIFT droit		4 - CAPS LOCK
* trap #13		1 - SHIFT gauche	5 - CLR HOME (bouton droit)
* addq #4,sp		2 - CONTROL		6 - INSERT (bouton gauche)
 endm			3 - ALTERNATE

; Test du clavier, sans attente.
; Renvoie:
; d0=code_scan
; d1=code_ascii
;
getkey macro 
 moveq #0,d0
 moveq #0,d1
 tst.b flag_touche_press‚e
 beq.s .pas_touche_press‚e
 sf flag_touche_press‚e
 move code_scan_118,d0
 moveq #0,d1
 move.b ([table_normale],d0.w),d1
 move d1,code_ascii  

.pas_touche_press‚e
 move d0,code_scan
 move d1,code_ascii
 endm

* clr code_scan
* clr code_ascii
* move #2,-(sp)
* move #1,-(sp)
* trap #13
* addq #4,sp
* tst d0
* beq .pas_de_touche
* move #2,-(sp)
* move #2,-(sp)
* trap #13
* addq #4,sp
* move d0,d1
* move d1,code_ascii
* swap d0
* move d0,code_scan

*
* Renvoie 0 si on
*
*
force_int‚rieur macro
 move.l d0,-(sp)
 move largeur_image,d0
 lsr d0
 subq #1,d0
 cmp mousex,d0
 bgt.s *+8
 move d0,mousex
 move hauteur_image,d0
 subq #1,d0
 cmp mousey,d0
 bgt.s *+8
 move d0,mousey
 move.l (sp)+,d0
 endm
 
 


 
* Pour le s‚lecteur de couleur
* 24 Octets de d‚finition
* et la couleur est d‚finie en +12
*
case_couleur macro
 dc.w \1,\2,008,008,0,-1
 dc.w 0,0
 dc.b 0,0
 dc.l routine_s‚lectionne_couleur,0
 endm

* Pour le s‚lecteur de couleur
* Permet de coder facilement une couleur. Na.
* Usage: CODE_RVB rouge vert bleu
*
code_rvb macro
 dc.w \1<<11+\2<<5+\3
 endm


;
; matrice:
; - Num‚ro outils
; - Num‚ro de fonction de l'outils
; - Adresse de l'icone … afficher dans le s‚lecteur
; - Adresse de l'icone … arborer sur le curseur
; - Adresse de la routine … ex‚cuter
; - Adresse de la chaine de caractŠre … mettre dans le formulaire
;
 rsreset
matrice_icone	rs.l 1
matrice_curseur	rs.l 1
matrice_routine	rs.l 1
matrice_texte	rs.l 1
matrice_touche	rs.b 1
matrice_special	rs.b 1
matrice_infos	rs.w 1

matrice_taille	rs.w 1

matrice_largeur=10	Au maximum, 10 outils.
matrice_hauteur=10	Au maximum, 10 sous fonctions par outils.

matrice macro
 lea ((num‚ro_\1*(matrice_taille*matrice_largeur+2))+num‚ro_\1_\2*matrice_taille+2,a0),a1
 move.l #icone_\1_\2,matrice_icone(a1)
 move.l #curseur_\1_\2,matrice_curseur(a1)
 move.l #routine_\1_\2,matrice_routine(a1)
 move.l #str_\1_\2,matrice_texte(a1)
 move.b #\3,matrice_touche(a1)
 move.b #\4,matrice_special(a1)
 move.w #\5,matrice_infos(a1)
 endm

explication_matrice								 macro

Pour chaque outil ( matrice_hauteur) on a la structure suivante:
 __________   ______________________________________________________________
( Fonction )+( Icone | Curseur | Routine | Texte | Touche | Special | Infos )* matrice_largeur
     
  Num‚ro
  de la
 fonction
  active
pour l'outil
 concern‚

 Cette organisation matricielle permet de limiter le nombre de routines de
gestion, puisque rien qu'en ayant le num‚ro de l'outil, ainsi que celui de
la fonction qui y est associ‚ on peut obtenir toutes les informations
n‚c‚ssaires au traitement de n'importe quelle action.

 endm
 