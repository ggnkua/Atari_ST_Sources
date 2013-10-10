;
; Interruption par lignes de balayage: dÇmo pour moniteur monochrome
; Assembleur		HBL.S
;

gemdos         = 1
xbios          = 14
cconws         = 9
xbtimer        = 31
super          = $20
ptermres       = $31

vbl_vec        = $70
_v_bas_ad      = $44e
bcontrol       = $fffffa1b              ;Registre de contrìle timer B
bdata          = $fffffa21              ;Registre de donnÇes timer B


               SECTION TEXT 

               movea.l    4(sp),a0      ;Calcul de la mÇmoire requise
               move.l     #$100,d6
               add.l      12(a0),d6
               add.l      20(a0),d6
               add.l      28(a0),d6

; Affichage du texte sur l'Çcran:

               pea        affichage
               move.w     #cconws,-(sp)
               trap       #gemdos
               addq.l     #6,sp

               clr.l      -(sp)         ;Passage en superviseur
               move.w     #super,-(sp)
               trap       #1
               addq.l     #6,sp
               move.l     d0,d7         ;Stocker SSP

; Copie de ce texte (en pixels, pas en ASCII):

               movea.l    _v_bas_ad,a0  ;VidÇo RAM logique
               lea.l      characters,a1

               moveq.l    #15,d0        ;16 Lignes de pixels
l1:            moveq.l    #20/4-1,d1    ;20 caractäres = 5 longs mots
l2:            move.l     (a0)+,(a1)+
               dbra       d1,l2
               lea.l      60(a0),a0     ;Ligne suivante (+80-20)
               dbra       d0,l1

; Installer la routine d'interruption dans le timer B (1).
; Event-Count-Mode --> pas de diviseur. Encore arràtÇ.


               pea        routine       ;Adresse de la routine d'interruption
               move.w     #0,-(sp)      ;Registre de donnÇes
               move.w     #0,-(sp)      ;Registre de contrìle (timer encore arràtÇ)
               move.w     #1,-(sp)      ;1 pour le timer B
               move.w     #xbtimer,-(sp)
               trap       #xbios
               adda.l     #12,sp

               move.l     vbl_vec,jump+2          ;Routine VBL dans instruction de saut
               move.l     #new_vbl,vbl_vec        ;une propre routine VBL Ö cet effet

               move.l     d7,-(sp)      ;Retour en mode utilisateur
               move.w     #super,-(sp)
               trap       #gemdos
               addq.l     #6,sp

               clr.w      -(sp)         ;Pas d'erreur
               move.l     d6,-(sp)      ;Longueur du programme
               move.w     #ptermres,-(sp)         ;Garder le programme en mode rÇsident
               trap       #gemdos


routine:       movem.l    d0-d7/a0-a6,-(sp)

               clr.l      d0            ;DÇbut Çcran (physique)
               move.b     $ffff8201,d0
               asl.w      #8,d0
               move.b     $ffff8203,d0
               asl.l      #8,d0

               movea.l    d0,a0
               lea.l      110*80(a0),a0 ;Caler sur ligne 110
               movea.l    a0,a3         ;stocker

               lea.l      characters,a1
               lea.l      save,a2
               moveq.l    #15,d0        ;16 lignes de pixels

lop:           move.l     30(a0),(a2)+  ;sauver
               move.l     34(a0),(a2)+
               move.l     38(a0),(a2)+
               move.l     42(a0),(a2)+
               move.l     46(a0),(a2)+

               move.l     (a1)+,30(a0)  ;êcrire texte
               move.l     (a1)+,34(a0)
               move.l     (a1)+,38(a0)
               move.l     (a1)+,42(a0)
               move.l     (a1)+,46(a0)

               lea.l      80(a0),a0     ;Ligne suivante
               dbra       d0,lop

               lea.l      save,a1
               moveq.l    #15,d0        ;16 Lignes de pixels

lop2:          move.l     (a1)+,30(a3)  ;RÇÇcrire image
               move.l     (a1)+,34(a3)
	       move.l     (a1)+,38(a3)
               move.l     (a1)+,42(a3)
               move.l     (a1)+,46(a3)
               lea.l      80(a3),a3     ;Ligne suivante
               dbra       d0,lop2

               movem.l    (sp)+,d0-d7/a0-a6
               clr.b      bcontrol      ;Arràter le timer

               bclr       #0,$fffffa0f
               rte        


; Nouvelle routine VBL:

new_vbl:       move.b     #100,bdata    ;Lancer le timer (100 lignes)
               move.b     #8,bcontrol   ;Registre de contrìle:
jump:          jmp        $12345678     ;Retour Ö la routine VBL normale


               SECTION DATA 

affichage:     DC.b 27,'E I LIKE MICRO APP ',0


               SECTION BSS 

               EVEN 

characters:    DS.b 20*16
save:          DS.b 20*16

               END 
