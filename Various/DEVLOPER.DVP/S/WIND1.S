;
; Ouvrir et fermer une fenˆtre
; Assembleur		WIND1.S
;

gemdos         = 1
crawcin        = 7


               INCLUDE 'GEM_INEX.S'

               SECTION TEXT 

main:          jsr        gem_init

; wind_create

               move.w     #100,control
               move.w     #5,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8

               move.w     #4095,int_in  ;tous les organes de commande
               move.w     #20,int_in+2  ;Taille maxi de la fenˆtre (x)
               move.w     #20,int_in+4  ;(y)
               move.w     #280,int_in+6 ;(Largeur)
               move.w     #150,int_in+8 ;(Hauteur)

               jsr        aes

               tst.w      int_out       ;n‚gatif? Alors erreur!
               bmi        error
               move.w     int_out,whandle         ;sinon stocker comme handle de la fenˆtre

; wind_open

               move.w     #101,control  ;Num‚ro de fonction
               move.w     whandle,int_in          ;Handle de wind_create

; Toutes les autres valeurs ‚tant identiques … celles de wind_create,
; elles sont encore dans le tableau des paramŠtres!

               jsr        aes

; Calcul de la zone de travail (wind_calc):

               move.w     #108,control
               move.w     #6,control+2
               move.w     #5,control+4
               clr.w      control+6
               clr.w      control+8

               move.w     #1,int_in     ;1 -> Calcul zone de travail
               move.w     #4095,int_in+2          ;Caract‚ristiques de la fenˆtre
               move.w     #20,int_in+4  ;Dimensions ext‚rieures
               move.w     #20,int_in+6
               move.w     #280,int_in+8
               move.w     #150,int_in+10

               jsr        aes

; Les coordonn‚es r‚sultant de la manipulation peuvent
; ˆtre laiss‚es dans le tableau AES pour l'‚tape suivante
; (effacement de la zone de travail)

; vsf_interior (motifrempl):

               move.w     #23,contrl
               clr.w      contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               move.w     #1,contrl+8
               move.w     handle,contrl+12
               clr.w      intin         ;Remplir avec couleur de fond
               jsr        vdi

; vsf_perimeter (d‚sactiver le cadre):

               move.w     #104,contrl
               clr.w      contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               move.w     #1,contrl+8
               move.w     handle,contrl+12
               clr.w      intin         ;Flag: d‚sactiver le cadre
               jsr        vdi

; v_bar (efface la zone de travail):
; (Les coordonn‚es de wind_calc doivent ˆtre converties de
;  x/y/largeur/hauteur en x1/y1/x2/y2).

               move.w     #11,contrl    ;Opcode des fonctions graphiques
               move.w     #2,contrl+2   ;de base
               clr.w      contrl+4
               clr.w      contrl+6
               clr.w      contrl+8
               move.w     #1,contrl+10  ;Num‚ro de fonction de v_bar
               move.w     handle,contrl+12

break:         

               move.w     int_out+2,d0  ;x1 = x dans wind_calc
               move.w     d0,ptsin
               move.w     int_out+4,d1  ;y1 = y dans wind_calc
               move.w     d1,ptsin+2
               add.w      int_out+6,d0  ;x + largeur...
               subq.w     #1,d0         ;... - 1...
               move.w     d0,ptsin+4    ;... = x2
               add.w      int_out+8,d1  ;y + hauteur...
               subq.w     #1,d1         ;... - 1...
               move.w     d1,ptsin+6    ;... = y2

               jsr        vdi

; vsf_perimeter (r‚activer cadres):

               move.w     #104,contrl
	       clr.w      contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               move.w     #1,contrl+8
               move.w     handle,contrl+12
               move.w     #1,intin      ;Drapeau: activer cadre
               jsr        vdi

; Attendre appui touche:

               move.w     #crawcin,-(sp)
               trap       #gemdos
               addq.l     #2,sp

; wind_close:

               move.w     #102,control
               move.w     #1,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8

               move.w     whandle,int_in

               jsr        aes

; wind_delete:

               move.w     #103,control  ;Seul le num‚ro de fonction
               jsr        aes           ;doit ˆtre modifi‚

quit:          jsr        gem_exit

               clr.w      -(sp)
               trap       #gemdos


error:         move.w     #52,control   ;Form-Alert
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     #err_txt,addr_in        ;ChaŒne d‚crivant la boŒte
               move.w     #1,int_in     ;le premier bouton est le bouton par d‚faut
               jsr        aes

               bra.s      quit


               SECTION DATA 

err_txt:       DC.b "[3][D‚sol‚!|Plus d'identificateur de fenˆtre libre!][OK]",0


               SECTION BSS 

whandle:       DS.w 1

               END 
