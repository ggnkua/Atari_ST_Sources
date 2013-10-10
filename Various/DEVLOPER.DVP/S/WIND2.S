;
; Fenàtre avec fonctions (agrandir,...)
; Assembleur		WIND2.S
;

gemdos         = 1


               INCLUDE 'GEM_INEX.S'

               SECTION TEXT 

main:          jsr        gem_init

; Pointeur souris "propre":

               move.w     #78,control   ;graf_mouse
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               clr.w      int_in        ;0 pour fläche
               jsr        aes

; wind_create

               move.w     #100,control
               move.w     #5,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8

               move.w     #63,int_in    ;Tout sauf fläches et ascenseurs
               move.w     #0,int_in+2   ;Taille maxi de la fenàtre (x)
               move.w     #0,int_in+4   ;(y)
               move.w     x_max,int_in+6          ;(largeur) ces valeurs sont celles
               move.w     y_max,int_in+8          ;(hauteur) du fichier include

               jsr        aes

               tst.w      int_out       ;nÇgatif? alors erreur!
               bmi        error
               move.w     int_out,whandle         ;sinon stocker comme identificateur fenàtre

; DÇfinir lignes de titre et d'info:

               move.w     #105,control  ;wind_set
               move.w     #6,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8

               move.w     whandle,int_in
               move.w     #2,int_in+2   ;2: ligne de titre
               move.l     #title,int_in+4

               jsr        aes

               move.w     #3,int_in+2   ;encore, mais avec 3 pour ligne d'info
               move.l     #info,int_in+4

               jsr        aes

; wind_open

               move.w     #101,control  ;NumÇro de fonction

               move.w     whandle,int_in          ;Handle (identificateur) de wind_create
               move.w     wx,int_in+2
               move.w     wy,int_in+4
               move.w     ww,int_in+6
               move.w     wh,int_in+8

               jsr        aes

; Effacement de la zone de travail et affichage d'un texte:

               jsr        text_out

;
;  La boucle principale commence ici:
; *** Nous attendons des Çvänements ***
;

; evnt_mesag:

loop:          move.w     #23,control
               clr.w      control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     #tampon,addr_in
               jsr        aes

; Les lignes suivantes ne sont pas träs engageantes
; Elles remplacent switch/case en C

               cmpi.w     #20,tampon    ;20: Redraw-Message
               bne.s      lab1
               jsr        text_out      ;Redessiner une fenàtre
               bra        loop

lab1:          cmpi.w     #23,tampon    ;23: Boåte plein Çcran
               bne.s      lab2
               move.w     #2,wx         ;DÇfinir une dimension maxi de la fenàtre
               move.w     #20,wy
               move.w     x_max,d0      ;Largeur et hauteur varient selon
               subq.w     #5,d0         ;la dÇfinition
               move.w     d0,ww
               move.w     y_max,d0
               subi.w     #25,d0
               move.w     d0,wh
               bra        wind_set

lab2:          cmpi.w     #27,tampon    ;27: Size-Box
               bne.s      lab3
               move.w     tampon+12,ww  ;La nouvelle taille se trouve dans le tamp
on:            
               move.w     tampon+14,wh
               bra        wind_set

lab3:          cmpi.w     #28,tampon    ;28: barre de dÇplacement
               bne.s      lab4
	       move.w     tampon+8,wx
               move.w     tampon+10,wy

wind_set:      move.w     #105,control  ;wind_set permet de paramÇtrer
               move.w     #6,control+2  ;une nouvelle taille et position
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8

               move.w     whandle,int_in          ;Fenàtre Ö paramÇtrer
               move.w     #5,int_in+2   ;5: paramÇtrage x/y/w/h
               move.w     wx,int_in+4   ;nouvelle valeur
               move.w     wy,int_in+6
               move.w     ww,int_in+8
               move.w     wh,int_in+10

               jsr        aes

lab4:          cmpi.w     #22,tampon    ;Close-Box actionnÇe?
               bne        loop          ;non, alors encore un Çvänement

; Nous pouvons maintenant fermer la fenàtre:

; wind_close:

               move.w     #102,control
               move.w     #1,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8

               move.w     whandle,int_in

               jsr        aes

; wind_delete:

               move.w     #103,control  ;Seul le numÇro de fonction doit
               jsr        aes           ;àtre modifiÇ

quit:          jsr        gem_exit

               clr.w      -(sp)
               trap       #gemdos


error:         move.w     #52,control   ;Form-Alert
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     #err_txt,addr_in        ;Chaåne de description de la boåte
               move.w     #1,int_in     ;Le premier bouton est le bouton par dÇfaut
               jsr        aes

               bra.s      quit

;
; Fin du programme principal, nous passons aux sous-programmes
;

text_out:                 ; Remplit la fenàtre de son contenu

; DÇsactiver pointeur souris

               move.w     #123,contrl   ;v_hide_c
               clr.w      contrl+2
               clr.w      contrl+4
               clr.w      contrl+6
               clr.w      contrl+8
               move.w     handle,contrl+12
               jsr        vdi

; Calcul de la zone de travail (wind_calc):

               move.w     #108,control
               move.w     #6,control+2
               move.w     #5,control+4
               clr.w      control+6
               clr.w      control+8

               move.w     #1,int_in     ;1 -> calcul de la zone de travail
               move.w     #63,int_in+2  ;CaractÇristiques de la fenàtre
               move.w     wx,int_in+4   ;Dimensions extÇrieures
               move.w     wy,int_in+6
               move.w     ww,int_in+8
               move.w     wh,int_in+10

               jsr        aes

               move.w     int_out+2,d0  ;x1 = x vient de wind_calc
               move.w     d0,x1
               move.w     int_out+4,d1  ;y1 = y vient de wind_calc
               move.w     d1,y1
               add.w      int_out+6,d0  ;x + Largeur...
               subq.w     #1,d0         ;... - 1...
               move.w     d0,x2         ;... = x2
               add.w      int_out+8,d1  ;y + Hauteur...
               subq.w     #1,d1         ;... - 1...
               move.w     d1,y2         ;... = y2

; Clipping pour activer cette zone de travail

               move.w     #129,contrl   ;Opcode de la fonction
               move.w     #2,contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               clr.w      contrl+8
               move.w     handle,contrl+12

               move.w     x1,ptsin      ;coordonnÇes de la zone de travail
               move.w     y1,ptsin+2
               move.w     x2,ptsin+4
               move.w     y2,ptsin+6
               move.w     #1,intin      ;1: Activer

               jsr        vdi

; vsf_interior (Motif de remplissage):

               move.w     #23,contrl
               clr.w      contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               move.w     #1,contrl+8
               move.w     handle,contrl+12
               clr.w      intin         ;Remplir avec couleur du fond
               jsr        vdi

; vsf_perimeter (DÇsactiver le cadre):

               move.w     #104,contrl
               clr.w      contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               move.w     #1,contrl+8
               move.w     handle,contrl+12
               clr.w      intin         ;Flag: DÇsactiver le cadre
               jsr        vdi

; v_bar (efface la zone de travail):
; (CoordonnÇes de wind_calc, doivent àtre converties de x/y/larg/haut
; en x1/y1/x2/y2.

               move.w     #11,contrl    ;Opcode pour informations
               move.w     #2,contrl+2   ;graphiques de base
               clr.w      contrl+4
               clr.w      contrl+6
               clr.w      contrl+8
               move.w     #1,contrl+10  ;NumÇro de fonction pour v_bar
               move.w     handle,contrl+12

               move.w     x1,ptsin
               move.w     y1,ptsin+2
               move.w     x2,ptsin+4
               move.w     y2,ptsin+6

               jsr        vdi

; vsf_perimeter (rÇactiver les cadres):

               move.w     #104,contrl
               clr.w      contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               move.w     #1,contrl+8
               move.w     handle,contrl+12
               move.w     #1,intin      ;Flag: activer les cadres
               jsr        vdi

; Affichage du  texte avec v_gtext

               move.w     #8,contrl
               move.w     #1,contrl+2
               clr.w      contrl+4      ;contrl+6 paramÇtrÇ en fonction
               clr.w      contrl+8      ;de la longueur du texte
               move.w     handle,contrl+12

               move.w     x1,ptsin      ;CoordonnÇes x
               addi.w     #8,ptsin

               move.w     y1,ptsin+2    ;CoordonnÇes y
               addi.w     #14,ptsin+2

               lea.l      ligne1,a0
               jsr        fix_text      ;êcriture du texte dans le tableau intin
               jsr        vdi

               addi.w     #16,ptsin+2   ;Ligne suivante
               lea.l      ligne2,a0
               jsr        fix_text
               jsr        vdi

               addi.w     #16,ptsin+2
               lea.l      ligne3,a0
               jsr        fix_text
               jsr        vdi

; DÇsactiver le clipping

               move.w     #129,contrl   ;Opcode de la fonction
               move.w     #2,contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               clr.w      contrl+8
               move.w     handle,contrl+12
               clr.w      intin         ;0: Clipping inactif
               jsr        vdi

; RÇafficher le pointeur souris

               move.w     #122,contrl   ;v_show_c
               clr.w      contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               clr.w      contrl+8
               move.w     handle,contrl+12
               move.w     #1,intin
               jsr        vdi

               rts        


fix_text:      
; Sous-programme qui Çcrit une chaåne (passer l'adresse
; Ö a0) dans le tableau intin, donne la longueur de la
; chaåne et la stocke dans contrl[3]

               clr.w      d0            ;Longueur
               clr.w      d1            ;Registre d'aide
               lea.l      intin,a1

fix_loop:      move.b     (a0)+,d1      ;Lire un octet de la chaåne cible
               tst.b      d1            ;Fin de chaåne?
               beq.s      fix_end
               move.w     d1,(a1)+      ;non, alors Çcrire comme mot
               addq.w     #1,d0         ;dans le tableau intin
               bra.s      fix_loop

fix_end:       move.w     d0,contrl+6   ;Stocker la longueur
               rts        


               SECTION DATA 

err_txt:       DC.b '[3][DÇsolÇ!|Plus de handle de fenàtre libre!][OK]',0

wx:            DC.w 20   ;Taille initiale de la fenàtre
wy:            DC.w 20
ww:            DC.w 280
wh:            DC.w 150

title:         DC.b 'WIND2.PRG',0
info:          DC.b 'Veuillez noter:',0

ligne1:        DC.b 'Salut! Voici une fenàtre de dÇmonstration!',0
ligne2:        DC.b 'Vous pouvez la dÇplacer et modifier '
               DC.b 'sa taille ',0
ligne3:        DC.b 'Quitter: clic sur la boåte de fermeture!',0


               SECTION BSS 

whandle:       DS.w 1    ;Window-Handle

x1:            DS.w 1    ;CoordonnÇes de la zone de travail
y1:            DS.w 1
x2:            DS.w 1    ;Angle !!! Pas largeur/hauteur !!!
y2:            DS.w 1

tampon:        DS.w 8    ;Les messages de l'AES arrivent ici

               END 
