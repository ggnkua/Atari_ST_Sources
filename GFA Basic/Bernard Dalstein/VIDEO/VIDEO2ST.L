
;********************************
;* num�riser une s�quence video *
;*    code: (c) rafale 1995     *
;********************************

;**************************************************
;** ATTENTION: l'instruction "move.b $FB00xx,yy" **
;** envoie sur la carte d'acquisition la donn�e  **
;** "xx", � partir d'une astuce "hard".le regis- **
;** -tre "yy" re�oit une valeur al�atoire, sans  **
;** importance pour le programme.                **
;**                                              **
;** la carte utilise un port d'entr�e/sortie sur **
;** 8 bits connect� sur le port cartouche:       **
;** ==> sortie: move.b $FB00xx,D2 (ou D1, etc..) **
;** ==> entr�e: move.b $FA0001,D1 (ou D2, etc..) **
;**************************************************

;  r�cup�ration des variables
; ----------------------------

   ;adresse de base du buffer (RAM de l'atari)
        move.l 4(SP),A1

   ;initialisation compteur pixel (ex:210 pixels)
        clr.l  D5
        move.w 8(SP),D5
        add #1,D5

   ;initialisation compteur ligne (ex:128 lignes)
        move.l #0,A2
        move.w 10(SP),D4

   ;mise hors GEL de la RAM VIDEO (au cas ou la carte
   ;n'est pas en mode "acquisition" actuellement)
        move.b $FB0040,D2

   ;attente de fin de trame (le bit d7 correspond �
   ;l'information "image pr�te � transf�rer" si d7 = 1)
wait1   move.b $FA0001,D1
        cmpi.b #128,D1
        blt    wait1

   ;activation du mode GEL (� faire d�s que d(in)7 = 1)
   ;� partir de l�, le bit d(out)7 doit rester � 1
   ;pendant tout le transfert de l'image !!!
        move.b $FB00C0,D2

   ;temporisation (1 ms?) (pour stabiliser l'�lectronique
   ;de la carte avant de lancer le transfert des pixels)
tempo   move.w #1000,D1
boucl   sub       #1,D1
        bne    boucl


   ;RAZ des compteurs ligne et pixel de la RAM Vid�o externe
   ;(c'est une RAM s�quentielle)
        move.b $FB0082,D2 ;raz pixel
        move.b $FB0080,D2
        move.b $FB0084,D2 ;raz ligne
        move.b $FB0080,D2

   ;d�caler 7 pixels � chaque ligne (version 192 � 210 pixels/ligne)
   ;le d�but de la RAM contient des infos issues de la cam�ra qui
   ;n'ont rien � voir avec l'image (niveau de r�f�rence du noir)
   ;comme ce param�tre d�pend de la fr�quence d'horloge et de la
   ;m�moire utilis�e, il doit etre de pr�f�rence param�trable !!

suite   move.b $FB0081,D2
        move.b $FB0080,D2
        move.b $FB0081,D2
        move.b $FB0080,D2
        move.b $FB0081,D2
        move.b $FB0080,D2
        move.b $FB0081,D2    ;(le couper/coller, c'est moins classe
        move.b $FB0080,D2    ;qu'une boucle, mais � 3 heures du mat'
        move.b $FB0081,D2    ;�a d�foule un peu !!!!)
        move.b $FB0080,D2
        move.b $FB0081,D2
        move.b $FB0080,D2
        move.b $FB0081,D2
        move.b $FB0080,D2
        move.l D5,D3       ;transfert du nombre de pixels/ligne dans D3

   ;lecture data --> D1
retour  move.b $FA0001,D1
        lsl    #2,D1

   ;stockage data --> buff(n)
   ;+ incr�mentation du pointeur sur le buffer de l'atari
        move.b D1,(A1)
        add    #1,A1   ;il existe peut-etre l'adressage
                       ;auto-incr�ment� ?

   ;horloge pixel
        move.b $FB0081,D2    ;on se d�place dans la RAM
        move.b $FB0080,D2    ;de la carte vid�o externe

 ;d�cr. compteur de pixels
 ;et comparer avec valeur finale (0!)
        sub    #1,D3         ;
        bne    retour

 ;incrementation des lignes deux fois sur la RAM 210x128

        move.b $FB0082,D2    ;la capacit� de la RAM externe ne permet
        move.b $FB0080,D2    ;de ne m�moriser qu'une ligne sur deux
        move.b $FB0082,D2    ;d�livr�e par la cam�ra vid�o. Avec la RAM
        move.b $FB0080,D2    ;de 420x288, on incr. 1 fois seulement car
                             ;la RAM stocke toutes les lignes

 ;d�cr. compteur de lignes
 ;et comparer avec valeur finale
        sub    #1,D4
        bne    suite

 ;suppression GEL et retour au PRG
        move.b $FB0040,D2
        rts  ; good bye !
        end

 