;
; Deux fenˆtres simultan‚es avec fonctions
; Assembleur		WIND3.S
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
               clr.w      int_in        ;0 pour flŠche
               jsr        aes

               clr.w      d1            ;Donner la taille du bureau (0)
               move.w     #4,d2         ;Sous-fonction
               jsr        wind_get
               move.w     d1,xdesk
               move.w     d2,ydesk
               move.w     d3,wdesk
               move.w     d4,hdesk

               jsr        create_windows
               tst.w      d0            ;Erreur?
               beq.s      no_err

               move.w     #52,control   ;alors Form Alert
               move.w     #1,control+2  ;pour message d'erreur
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     #err_txt,addr_in        ;ChaŒne d‚crivant la boŒte
               move.w     #1,int_in     ;Le premier bouton est le bouton par d‚faut
               jsr        aes
               bra        quit

no_err:        lea.l      title1,a0     ;Ligne titre
               move.w     #2,d0         ;2 est la sous-fonction de wind_set
               move.w     whandle,d1    ;PremiŠre fenˆtre
               jsr        wind_set1

               lea.l      info1,a0
               move.w     #3,d0         ;3 demande la ligne d'info
               move.w     whandle,d1
               jsr        wind_set1

               lea.l      title2,a0
               move.w     #2,d0
               move.w     whandle+2,d1  ;DeuxiŠme fenˆtre
               jsr        wind_set1

               lea.l      info2,a0
               move.w     #3,d0
               move.w     whandle+2,d1
               jsr        wind_set1

; Ouverture des fenˆtres:

               clr.w      d7
               clr.w      d3
               lea.l      whandle,a5
               lea.l      wx,a4

open_lp:       move.w     #101,control  ;wind_open
               move.w     #5,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               move.w     0(a5,d7.w),int_in       ;Window handle
               move.w     0(a4,d7.w),int_in+2
               move.w     4(a4,d7.w),int_in+4
               move.w     8(a4,d7.w),int_in+6
               move.w     12(a4,d7.w),int_in+8
               jsr        aes
               jsr        output_text
               addq.w     #1,d3         ;Index pour output_text
               addq.w     #2,d7         ;Fenˆtre suivante
               cmpi.w     #4,d7         ;les deux sont d‚j… ouvertes?
               bne.s      open_lp       ;non, alors boucle

;
; *** Boucle de messages ***
;

; evnt_mesag:

loop:          move.w     #23,control
               clr.w      control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     #tampon,addr_in
               jsr        aes

; Passer l'index de la fenˆtre qui est la cause du message
; Son identificateur (handle) est dans tampon+6:
; Le r‚sultat n'est pas un index mais un offset.

               clr.w      d3
               lea.l      wx,a4         ;Coordonn‚es
               lea.l      whandle,a5    ;Handles
               lea.l      tampon,a6     ;Message
               move.w     6(a6),d2      ;Identificateur de fenˆtre de la "source"

s_lp:          cmp.w      0(a5,d3.w),d2
	       beq.s      s_found
               addq.w     #2,d3
               cmpi.w     #4,d3         ;s'agit-il bien de notre fenˆtre?
               beq        loop          ;‡a n'en a pas l'air, attendons
               bra.s      s_lp

; Les ‚vŠnements sont maintenant examin‚s/trait‚s:

s_found:       cmpi.w     #20,(a6)      ;Redraw?
               bne.s      lab0
               jsr        redraw        ;alors redessiner la zone
               bra        cont

lab0:          cmpi.w     #21,(a6)      ;Window Topped
               bne.s      lab1
               move.w     d2,d1         ;Window handle
               move.w     #10,d0        ;Fonction: amŠne la fenˆtre au premier plan
               jsr        wind_set2
               bra        cont

lab1:          cmpi.w     #22,(a6)      ;Close Box
               bne.s      lab2
               move.w     #102,control  ;wind_close
               move.w     #1,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               move.w     0(a5,d3.w),int_in       ;Handle
               jsr        aes
               move.w     #103,control  ;wind_delete
               jsr        aes           ;(pr nouveau num‚ro de fonction uniquement)
               lea.l      opened,a3     ;Fenˆtre plus ouverte
               clr.w      0(a3,d3.w)
               bra        cont

lab2:          cmpi.w     #23,(a6)      ;23: Full Box
               bne.s      lab3
               move.w     xdesk,d0      ;Param‚trer la taille maxi de la fenˆtre
               addq.w     #2,d0
               move.w     d0,0(a4,d3.w)
               move.w     ydesk,d0
               addq.w     #2,d0
               move.w     d0,4(a4,d3.w)
               move.w     wdesk,d0
               subq.w     #6,d0
               move.w     d0,8(a4,d3.w)
               move.w     hdesk,d0
               subi.w     #6,d0
               move.w     d0,12(a4,d3.w)
               bra        set

lab3:          cmpi.w     #27,(a6)      ;27: Size box
               bne.s      lab4
               move.w     12(a6),8(a4,d3.w)
               move.w     14(a6),12(a4,d3.w)
               bra        set

lab4:          cmpi.w     #28,(a6)      ;28: Move bar
               bne.s      cont
               move.w     8(a6),0(a4,d3.w)
               move.w     10(a6),4(a4,d3.w)
set:           move.w     #5,d0         ;Fonction: modifier la position
               move.w     0(a5,d3.w),d1 ;Window handle (identificateur fenˆtre)
               move.w     0(a4,d3.w),d2 ;Coordonn‚es
               move.w     8(a4,d3.w),d4
               move.w     12(a4,d3.w),d5
               move.w     4(a4,d3.w),d3 ;d3 ne peut ˆtre modifi‚ que tout-…-fait
               jsr        wind_set2     ;… la fin (c'est aussi l'offset)

cont:          
; Tester si au moins une fenˆtre est ouverte

               tst.w      opened
               bne        loop          ;ouverte, alors aller … la boucle
               tst.w      opened+2      ;2Šme fenˆtre
               bne        loop

quit:          jsr        gem_exit

               clr.w      -(sp)
               trap       #gemdos


;
; *** Sous-programmes***
;

intersect:     
; Test d'intersection de rectangles
; ParamŠtres:
;   d1-d4 -> coordonn‚es rectangle 1
;   Le rectangle 2 vient du tampon des messages
;   Son adresse doit se trouver en a6
; Affichage:
;   d0 -> 0=pas d'intersection, 1=Intersection
;   pxy: coordonn‚es VDI (pas largeur/hauteur) de
;        la section

               cmp.w      tampon+8,d1   ;x2 > x1?
               bgt        is1
               move.w     tampon+8,pxy  ;oui, alors x=x1
               bra.s      is2
is1:           move.w     d1,pxy        ;sinon x=x2

is2:           cmp.w      tampon+10,d2  ;y2 > y1?
               bgt        is3
               move.w     tampon+10,pxy+2         ;comme ci-dessus, mais pour y
               bra.s      is4
is3:           move.w     d2,pxy+2

is4:           move.w     tampon+8,d0   ;x1...
               add.w      tampon+12,d0  ;... + w1
               add.w      d3,d1         ;et x2 + w2
               cmp.w      d1,d0         ;x2+w1 < x1+w1?
               blt.s      is5
               move.w     d1,pxy+4      ;non, plus grand -> x=x1+w1
               bra.s      is6
is5:           move.w     d0,pxy+4      ;oui, alors x=x2+w2
is6:           subi.w     #1,pxy+4      ;Correction (x2=x+w-1)

               move.w     tampon+10,d0  ;y1...
               add.w      tampon+14,d0  ;... + h1
               add.w      d4,d2         ;et y2 + h2
               cmp.w      d2,d0         ;reste: comme ci-dessus
               blt        is7
               move.w     d2,pxy+6
               bra.s      is8
is7:           move.w     d0,pxy+6
is8:           subi.w     #1,pxy+6

               clr.w      d0            ;Test: intersection?
               move.w     pxy+4,d1
               cmp.w      pxy,d1        ;x2 < x1?
               blt.s      isrts         ;alors erreur
               move.w     pxy+6,d1      ;y2 < y1?
               cmp.w      pxy+2,d1      ;Erreur aussi
               blt.s      isrts
               moveq.l    #1,d0         ;sinon pas d'erreur
isrts:         rts        


redraw:        
; Redessine une fenˆtre ou une portion de fenˆtre
; Les coordonn‚es de la zone … redessiner dans le tampon
; d'‚vŠnements (+8,+10,+12,+14). Window (0/1) dans d3

               lsr.w      #1,d3         ;Convertir l'offset en index

               move.w     d3,-(sp)      ;Stocker pour usage ult‚rieur

               move.w     #107,control  ;wind_update
               move.w     #1,control+2  ;(Interdire les activit‚s souris,
               move.w     #1,control+4  ;bloquer la liste des rectangles)
               clr.w      control+6
               clr.w      control+8
               move.w     #1,int_in     ;Flag: reprendre le contr“le
               jsr        aes

               jsr        wind_calc     ;Nous avons … nouveau besoin des
               move.w     pxy,d6        ;coordonn‚es de la zone de travail
               move.w     pxy+2,d7

               move.w     tampon+6,d1   ;Premier rectangle de la liste
               move.w     #11,d2        ;Num‚ro de sous-fonction de wind_get
               jsr        wind_get

rdr_lp:        tst.w      d3            ;V‚rifier la largeur
               beq        rdr_end       ;Z‚ro, alors arrˆter

               jsr        intersect     ;sinon former une intersection
               tst.w      d0            ;Intersection?
               beq.s      rdr_lab       ;non, alors sauter

               move.w     #129,contrl   ;vs_clip
               move.w     #2,contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               clr.w      contrl+8
               move.w     handle,contrl+12
               move.w     pxy,ptsin     ;Les coordonn‚es de la zone de travail
               move.w     pxy+2,ptsin+2
               move.w     pxy+4,ptsin+4
               move.w     pxy+6,ptsin+6
               move.w     #1,intin      ;1: activer
               jsr        vdi

               move.w     d6,d4         ;coordonn‚es de l'angle sup‚rieur
               move.w     d7,d5         ;gauche (pas forc‚ment dans le rectangle)
               move.w     (sp),d3       ;Index de la fenˆtre (0/1)
               jsr        draw_text

rdr_lab:       move.w     tampon+6,d1   ;Rectangle suivant
               move.w     #12,d2
               jsr        wind_get
               bra        rdr_lp        ;et encore une fois...

rdr_end:       move.w     #129,contrl   ;Clipping d‚sactiv‚...
               move.w     #2,contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               clr.w      contrl+8
               move.w     handle,contrl+12
               clr.w      intin         ;0: Clipping d‚sactiv‚
               jsr        vdi

               addq.l     #2,sp         ;Annuler stockage de d3

               move.w     #107,control  ;wind_update
               move.w     #1,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               clr.w      int_in        ;L'AES reprend le contr“le
               jmp        aes


wind_set1:     
; ParamŠtre ligne titre ou information
; ParamŠtres:
;   d0 -> sous-fonction (2 titre/3 info)
;   d1 -> Window handle
;   a0 -> ChaŒne

               move.w     #105,control  ;wind_set
               move.w     #6,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               move.w     d1,int_in     ;Window handle
               move.w     d0,int_in+2   ;Sous-fonction
               move.l     a0,int_in+4   ;Adresse
               jmp        aes


wind_set2:     
; ParamŠtre les coordonn‚es ou ramŠne la fenˆtre au premier plan
; ParamŠtres:
;   d0 -> Sous-fonction (5 Coordonn‚es/10 Info)
;   d1 -> Window handle
;   d2-d5 -> Coordonn‚es

               move.w     #105,control  ;wind_set
               move.w     #6,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               move.w     d1,int_in     ;Identificateur de fenˆtre
               move.w     d0,int_in+2   ;Sous-fonction
               move.w     d2,int_in+4
               move.w     d3,int_in+6
               move.w     d4,int_in+8
               move.w     d5,int_in+10
               jmp        aes


create_windows:           
; window_create pour 2 fenˆtres
; R‚sultat en d0:
;    0 -> OK
;    1 -> erreur
; Identificateurs de fenˆtres dans whandle et whandle+2

               move.l     d7,-(sp)
               moveq.l    #0,d7
               lea.l      whandle,a5

cw_loop:       move.w     #100,control  ;wind_create
               move.w     #5,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               move.w     #63,int_in    ;Tout sauf flŠches et ascenseurs
               move.w     xdesk,int_in+2          ;Taille maxi de la fenˆtre (x)
               move.w     ydesk,int_in+4          ;(y)
               move.w     wdesk,int_in+6          ;(largeur)  les valeurs proviennent du
               move.w     hdesk,int_in+8          ;(hauteur)  du fichier include
               jsr        aes
               tst.w      int_out       ;n‚gatif? alors erreur!
               bmi        cw_err
               move.w     int_out,0(a5,d7.w)      ;sinon stocker comme handle de fenˆtre
               addq.l     #2,d7         ;fenˆtre suivante
               cmpi.w     #4,d7         ;d‚j… fini?
               bne.s      cw_loop
               clr.w      d0            ;pas d'erreur
               bra.s      cw_rts

cw_err:        move.w     #1,d0         ;Flag d'erreur
cw_rts:        move.l     (sp)+,d7
               rts        


draw_text:     
; Efface la zone de travail et ‚crit le texte
; ParamŠtres:
;   dans pxy (segment .bss) les coordonn‚es du rectangle
;   … effacer
;   d4,d5: Coordonn‚es x/y du coin sup‚rieur gauche du
;   texte (pas obligatoirement dans le rectangle, voir Redraw)

; D‚sactiver le pointeur de la souris

               move.w     #123,contrl   ;v_hide_c
               clr.w      contrl+2
               clr.w      contrl+4
               clr.w      contrl+6
               clr.w      contrl+8
               move.w     handle,contrl+12
               jsr        vdi

; Effacer le rectangle dans pxy:

; vsf_interior (trame de remplissage):

               move.w     #23,contrl
               clr.w      contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               move.w     #1,contrl+8
               move.w     handle,contrl+12
               clr.w      intin         ;Remplir avec la couleur du fond
               jsr        vdi

; vsf_perimeter (d‚sactiver cadre):

               move.w     #104,contrl
               clr.w      contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               move.w     #1,contrl+8
               move.w     handle,contrl+12
               clr.w      intin         ;Flag: d‚sactiver cadre
               jsr        vdi

; v_bar (efface la zone de travail):

               move.w     #11,contrl    ;Opcode pour fonctions
               move.w     #2,contrl+2   ;graphiques de base
               clr.w      contrl+4
               clr.w      contrl+6
               clr.w      contrl+8
               move.w     #1,contrl+10  ;Num‚ro de fonction pour v_bar
               move.w     handle,contrl+12
               move.w     pxy,ptsin
               move.w     pxy+2,ptsin+2
               move.w     pxy+4,ptsin+4
               move.w     pxy+6,ptsin+6
               jsr        vdi

; vsf_perimeter (r‚activer le cadre):

               move.w     #104,contrl
               clr.w      contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               move.w     #1,contrl+8
               move.w     handle,contrl+12
               move.w     #1,intin      ;Flag: activer le cadre
               jsr        vdi

; Affichage des textes avec v_gtext

               move.w     #8,contrl
               move.w     #1,contrl+2
               clr.w      contrl+4      ;contrl+6 est param‚tr‚ selon
               clr.w      contrl+8      ;la longueur du texte
               move.w     handle,contrl+12

               move.w     d4,ptsin      ;coordonn‚es x
               addi.w     #8,ptsin

               move.w     d5,ptsin+2    ;coordonn‚es y
               addi.w     #14,ptsin+2

               lea.l      ligne1,a0
               jsr        fix_text      ;crire le texte dans le tableau intin

               jsr        vdi

               addi.w     #16,ptsin+2   ;Ligne suivante
               lea.l      ligne2,a0
               jsr        fix_text
               jsr        vdi

               addi.w     #16,ptsin+2
               lea.l      ligne3,a0
               jsr        fix_text
               jsr        vdi

; R‚afficher le pointeur de la souris

               move.w     #122,contrl   ;v_show_c
               clr.w      contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               clr.w      contrl+8
               move.w     handle,contrl+12
               move.w     #1,intin
               jsr        vdi
               rts        


output_text:   
; Affiche le texte une fois au d‚but du programme
; ParamŠtres:
;   d3: fenˆtre souhait‚e (0/1)

               jsr        wind_calc     ;Calcul de la zone de travail

; Activer clipping pour cette zone de travail

               move.w     #129,contrl   ;Opcode de la fonction
               move.w     #2,contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               clr.w      contrl+8
               move.w     handle,contrl+12
               move.w     pxy,ptsin     ;Coordonn‚es (venant de wind_calc)
               move.w     pxy+2,ptsin+2
               move.w     pxy+4,ptsin+4
               move.w     pxy+6,ptsin+6
               move.w     #1,intin      ;1: activer
               jsr        vdi

               move.w     pxy,d4        ;Coin gauche sup‚rieur du texte
               move.w     pxy+2,d5
               jsr        draw_text

; D‚sactiver clipping

               move.w     #129,contrl   ;Opcode de la fonction
               move.w     #2,contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               clr.w      contrl+8
               move.w     handle,contrl+12
               clr.w      intin         ;0: clipping d‚sactiv‚
               jsr        vdi
               rts        


wind_calc:     
; Calcule la zone de travail
; ParamŠtres:
;   d3: fenˆtre souhait‚e (0/1)
; Affichage:
;   Zone en x1/y1/x2/y2 dans pxy

               movem.l    d0/d1/d3/a0,-(sp)

               lsl.w      #1,d3         ;Index * 2 comme offset
               lea.l      wx,a0         ;Adresse de base de "Array"

               move.w     #108,control  ;wind_get
               move.w     #6,control+2
               move.w     #5,control+4
               clr.w      control+6
               clr.w      control+8

               move.w     #1,int_in     ;1 -> calcul de la zone de travail
               move.w     #63,int_in+2  ;Caract‚ristiques de la fenˆtre
               move.w     0(a0,d3.w),int_in+4     ;Dimensions ext‚rieures (x)
               move.w     4(a0,d3.w),int_in+6     ;(y)
               move.w     8(a0,d3.w),int_in+8     ;(w)
               move.w     12(a0,d3.w),int_in+10   ;(h)

               jsr        aes

               move.w     int_out+2,d0  ;x1 = x de wind_calc
               move.w     d0,pxy
               move.w     int_out+4,d1  ;y1 = y de wind_calc
               move.w     d1,pxy+2
               add.w      int_out+6,d0  ;x + largeur...
               subq.w     #1,d0         ;... - 1...
               move.w     d0,pxy+4      ;... = x2
               add.w      int_out+8,d1  ;y + hauteur...
               subq.w     #1,d1         ;... - 1...
               move.w     d1,pxy+6      ;... = y2

               movem.l    (sp)+,d0/d1/d3/a0
               rts        


wind_get:      
; Retourne la liste des rectangles ou la taille du Bureau
; ParamŠtres:
;   d1: identificateur de fenˆtre (Bureau: 0)
;   d2: Fonction:
;        4: Taille de la zone de travail
;       11: Premier rectangle
;       12: Rectangle suivant
; Affichage:
;   coordonn‚es dans d1-d4

               move.w     #104,control  ;wind_get
               move.w     #2,control+2
               move.w     #5,control+4
               clr.w      control+6
               clr.w      control+8
               move.w     d1,int_in     ;identificateur de fenˆtre
               move.w     d2,int_in+2   ;Sous-fonction
               jsr        aes
               move.w     int_out+2,d1
               move.w     int_out+4,d2
               move.w     int_out+6,d3
               move.w     int_out+8,d4
               rts        


fix_text:      
; Sous-programme qui ‚crit une chaŒne (passer son adresse
; dans a0) dans le tableau intin, calcule sa longueur et
; la stocke dans contrl[3]

               clr.w      d0            ;Longueur
               clr.w      d1            ;Registre d'aide
               lea.l      intin,a1

fix_loop:      move.b     (a0)+,d1      ;lire un octet dans la chaŒne cible
               tst.b      d1            ;Fin de chaŒne?
               beq.s      fix_end
               move.w     d1,(a1)+      ;non, alors ‚crire comme mot dans
               addq.w     #1,d0         ;le tableau intin
               bra.s      fix_loop

fix_end:       move.w     d0,contrl+6   ;Stocker la longueur
               rts        


               SECTION DATA 

opened:        DC.w 1,1  ;Flag si fenˆtre ouverte

wx:            DC.w 20,50              ;Coordonn‚es de la fenˆtre
wy:            DC.w 20,50
ww:            DC.w 200,200
wh:            DC.w 120,120

title1:        DC.b 'Fenˆtre 1',0
title2:        DC.b 'Fenˆtre 2',0

info1:         DC.b 'Veuillez noter:',0
info2:         DC.b 'Veuillez ‚galement noter:',0

err_txt:       DC.b '[3][D‚sol‚!|Plus de handle fenˆtre libre!][OK]',0

ligne1:        DC.b 'Salut! Ceci est une fenˆtre de d‚monstration',0
ligne2:        DC.b 'Vous pouvez d‚placer la fenˆtre et modifier '
               DC.b 'sa taille.',0
ligne3:        DC.b 'Quitter: clic sur la boŒte de fermeture!',0


               SECTION BSS 

whandle:       DS.w 2    ;Window handles (identificateurs de fenˆtres)

xdesk:         DS.w 1    ;Coordonn‚es du bureau
ydesk:         DS.w 1
wdesk:         DS.w 1
hdesk:         DS.w 1

tampon:        DS.w 8    ;Tampon des messages

pxy:           DS.w 4    ;Coordonn‚es

               END       ;Il ‚tait bien long, n'est-pas?
