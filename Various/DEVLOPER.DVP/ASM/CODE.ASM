;
; Codage/dÇcodage de fichiers (DÇmo-application)
; Assembler                   CODE.ASM
;

gemdos         = 1        ;Constantes pour les routines GEMDOS
dgetdrv        = $19
fsetdta        = $1a
fopen          = $3d
fclose         = $3e
fread          = $3f
fwrite         = $40
fseek          = $42
dgetpath       = $47
malloc         = $48
mfree          = $49
fsfirst        = $4e

DIALOG         = 0        ;Constantes pour le fichier ressource
FNAME          = 3
KEY            = 5
ABB            = 7
OK             = 6


               .INCLUDE 'GEM_INEX.ASM'


               .TEXT 

main:          jsr        gem_init      ;comme d'habitude

; rsrc_load:

               move.w     #110,control
               clr.w      control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     #rscname,addr_in
               jsr        aes

               tst.w      int_out       ;Erreur?
               beq        rsc_err

; rsrc_gaddr nous donne l'adresse de la boåte de dialogue:

               move.w     #112,control
               move.w     #2,control+2
               move.w     #1,control+4
               clr.w      control+6
               move.w     #1,control+8
               clr.w      int_in        ;0 pour "recherche arbre"
               move.w     #DIALOG,int_in+2        ;Index de l'arbre
               jsr        aes
               move.l     addr_out,arbr_adr       ;RÇsultat: l'adresse

               lea.l      code,a0       ;Vider le champ d'entrÇe de la clÇ
               clr.b      (a0)
               move.w     #KEY,d0
               jsr        write_text

; Le sÇlecteur de fichier commence par un nom de chemin:
; nous devons lui en procurer un:

               clr.b      default       ;Pas de nom par dÇfaut au lancement programme
               lea.l      fsel_chem,a2

; Demande quel est le lecteur courant

               move.w     #dgetdrv,-(sp)
               trap       #gemdos
               addq.l     #2,sp
               addi.b     #'A',d0       ;RÇsultat de la fonction -> lettre
               move.b     d0,(a2)
               move.b     #':',1(a2)    ;Deux points derriäre nom lecteur

; Demander le chemin du lecteur courant

               clr.w      -(sp)         ;Lecteur courant
               pea        2(a2)
               move.w     #dgetpath,-(sp)
               trap       #gemdos
               addq.l     #8,sp

; ajouter \ et masque

               clr.w      d1            ;Passer longueur de chaåne
fsel_lp:       tst.b      0(a2,d1.w)    ;Octet nul?
               beq.s      fsel_le
               addq.w     #1,d1
               bra.s      fsel_lp

fsel_le:       move.b     #'\',0(a2,d1.w)

               lea.l      masque,a3     ;Pointeur sur *.*
fsel_l2:       move.b     (a3)+,1(a2,d1.w)
               beq.s      fsel_e2
               addq.w     #1,d1
               addq.w     #1,d2
               bra.s      fsel_l2

fsel_e2:       
mainloop:      

; Appel de la boåte de sÇlection des fichiers GEM

               move.w     #90,control   ;Opcode de la fonction
               clr.w      control+2
               move.w     #2,control+4
               move.w     #2,control+6
               clr.w      control+8

               move.l     #fsel_chem,addr_in      ;Nom de chemin prÇparÇ
               move.l     #default,addr_in+4      ;et nom de fichier par dÇfaut

               jsr        aes

               tst.w      int_out+2     ;CliquÇ sur Quitter au lieu de OK?
               beq        fsel_q        ;alors quitte
               lea.l      default,a3
               tst.b      (a3)          ;A-t-on sÇlectionnÇ un nom de fichier ?
               beq        fsel_q

; Nous devons crÇer un nom de chemin complet Ö partir du nom
; du chemin et de celui du fichier:

               lea.l      fsel_chem,a0  ;Copier pour traitement
               lea.l      chemin,a2
cpy_loop:      move.b     (a0)+,(a2)+
               bne.s      cpy_loop

fsel_l4:       cmpi.b     #'\',-(a2)    ;Chercher un backslash
               bne.s      fsel_l4

               addq.l     #1,a2         ;Laisser le backslash

fsel_l5:       move.b     (a3)+,(a2)+   ;Copier le nom du fichier
               bne.s      fsel_l5

; VÇrifier que le fichier existe bien. Nous en profitons pour
; en connaåtre la longueur:

               pea        dta_buff      ;CrÇer un tampon DTA
               move.w     #fsetdta,-(sp)
               trap       #gemdos
               addq.l     #6,sp

               clr.w      -(sp)         ;chercher des fichiers normaux
               pea        chemin        ;nom
               move.w     #fsfirst,-(sp)
               trap       #gemdos
               addq.l     #8,sp

               tst.w      d0            ;Erreur?
               bmi        error

; RÇserver de la mÇmoire pour le fichier:

               move.l     filesize,-(sp)
               move.w     #malloc,-(sp)
               trap       #gemdos
               addq.l     #6,sp
               movea.l    d0,a6         ;Stocker l'adresse
               tst.l      d0            ;pas assez de mÇmoire?
               bmi        mem_err

; Ouvrir et charger le fichier:

               move.w     #2,-(sp)      ;Ouvrir en lecture et Çcriture
               pea        chemin
               move.w     #fopen,-(sp)
               trap       #gemdos
               addq.l     #8,sp
               move.w     d0,fhandle    ;Stocker l'identificateur (handle)
               tst.w      d0            ;Erreur?
               bmi        error

               pea        (a6)          ;Adresse pour charger
               move.l     filesize,-(sp)          ;vers les octets en lecture
               move.w     fhandle,-(sp)
               move.w     #fread,-(sp)
               trap       #gemdos
               adda.l     #12,sp

; Codage du fichier:

               lea.l      chemin,a0     ;êcrire le nom du fichier dans le formulaire
               move.w     #FNAME,d0
               jsr        write_text

               jsr        show_dialog   ;Affichage de l'arbre

; form_do fait travailler Dialog:

               move.w     #50,control
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.w     #KEY,int_in   ;Champ Edit
               move.l     arbr_adr,addr_in
               jsr        aes
               move.w     int_out,bouton          ;Bouton appuyÇ

               jsr        deselect      ;Effacer l'Çtat Selected

               jsr        hide_dialog   ;Effacer la boåte de dialogue

break:         

               move.w     bouton,d0     ;Quel bouton appuyÇ?
               cmpi.w     #OK,d0
               bne        fsel_q        ;Quitte -> Fin

               lea.l      code,a0       ;Lire le code
               move.w     #KEY,d0
               jsr        read_text

               lea.l      code,a0       ;a0 a ÇtÇ dÇtruit
               tst.b      (a0)          ;A-t-on vraiment Çcrit le code?
               beq        no_code

               lea.l      (a6),a4       ;Adresse de dÇbut
               lea.l      (a6),a5
               adda.l     filesize,a5   ;Adresse de fin

code_rep:      lea.l      code,a0       ;Mot code
code_loop:     tst.b      (a0)          ;Fin du code?
               beq.s      code_rep      ;alors commencer depuis le dÇbut
               move.b     (a0)+,d0      ;Lire l'octet code
               eor.b      d0,(a4)+      ;Liaison OU eXclusif
               cmpa.l     a4,a5         ;ArrivÇ Ö la fin?
               bgt.s      code_loop     ;pas encore, alors continuer

break2:        

; RÇÇcrire le fichier:

               clr.w      -(sp)         ;Pointeur au dÇbut du fichier
               move.w     fhandle,-(sp)
               clr.l      -(sp)         ;Position relative au dÇbut du fichier
               move.w     #fseek,-(sp)
               trap       #gemdos
               adda.l     #10,sp

               pea        (a6)          ;RÇÇcrire le fichier
               move.l     filesize,-(sp)
               move.w     fhandle,-(sp)
               move.w     #fwrite,-(sp)
               trap       #gemdos
               adda.l     #12,sp

               move.w     fhandle,-(sp) ;Fermer le fichier
               move.w     #fclose,-(sp)
               trap       #gemdos
               addq.l     #4,sp

; LibÇrer l'espace mÇmoire:

               pea        (a6)
               move.w     #mfree,-(sp)
               trap       #gemdos
               addq.l     #6,sp

no_code:       bra        mainloop


mem_err:       lea.l      out_of_mem,a5 ; Afficher la boåte d'alerte
               jsr        alert
               bra        fsel_q

rsc_err:       lea.l      rsc_txt,a5
               jsr        alert
               bra        fsel_q

error:         lea.l      not_found,a5
               jsr        alert

fsel_q:        jsr        gem_exit

; rsrc_free:

               move.w     #111,control
               clr.w      control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               jsr        aes

               clr.w      -(sp)         ;Pterm0
               trap       #gemdos       ;(Fin du programme)


alert:         
; Afficher une boåte d'alerte, Chaåne dans a5.

               move.w     #52,control   ;Opcode
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.w     #1,int_in     ;Bouton par dÇfaut
               move.l     a5,addr_in    ;Chaåne descriptive
               jsr        aes
               rts        


; Sous-programmes de gestion du GEM:

show_dialog:   
; Ce sous-programme dessine un arbre objet Ö l'Çcran
; Son adresse doit se trouver dans 'arbr_adr'.

; form_center

               move.w     #54,control
               clr.w      control+2
               move.w     #5,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     arbr_adr,addr_in
               jsr        aes
               move.w     int_out+2,d4  ;Sauvegarder les coordonnÇes
               move.w     int_out+4,d5
               move.w     int_out+6,d6
               move.w     int_out+8,d7

; form_dial stocke les cadres de fenàtres, etc. (0)

               move.w     #51,control
               move.w     #9,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               clr.w      int_in        ;Sous-fonction 0
; Pas de valeur pour le petit rectangle fo_dilittlx/y/w/h
               move.w     d4,int_in+10  ;grand rectangle do_dibigx/y/w/h
               move.w     d5,int_in+12
               move.w     d6,int_in+14
               move.w     d7,int_in+16
               jsr        aes

; form_dial dessine le rectangle "zoom" (1):

               move.w     #51,control
               move.w     #9,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               move.w     #1,int_in     ;Sous-fonction 1
               move.w     d4,int_in+2   ;Dimensions du petit rectangle
               move.w     d5,int_in+4
               move.w     #1,int_in+6
               move.w     #1,int_in+8
               move.w     d4,int_in+10  ;grand rectangle do_dibigx/y/w/h
               move.w     d5,int_in+12
               move.w     d6,int_in+14
               move.w     d7,int_in+16
               jsr        aes

; Dessiner Dialog avec objc_draw:

               move.w     #42,control
               move.w     #6,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               clr.w      int_in        ;0=Commencer par dessiner l'objet racine
               move.w     #12,int_in+2  ;12 niveaux maxi (valeur arbitraire)
               move.w     d4,int_in+4
               move.w     d5,int_in+6
               move.w     d6,int_in+8
               move.w     d7,int_in+10
               move.l     arbr_adr,addr_in
               jmp        aes


hide_dialog:   
; Efface le formulaire
; Adresse de l'arbre objet Ö nouveau dans arbr_adr

; form_center

               move.w     #54,control
               clr.w      control+2
               move.w     #5,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     arbr_adr,addr_in
               jsr        aes
               move.w     int_out+2,d4  ;Stocker les coordonnÇes
               move.w     int_out+4,d5
               move.w     int_out+6,d6
               move.w     int_out+8,d7

; form_dial dessine le rectangle diminuant (2):

               move.w     #51,control
               move.w     #9,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               move.w     #2,int_in     ;Sous-fonction 2
               move.w     d4,int_in+2   ;Dimensions du petit rectangle
               move.w     d5,int_in+4
               move.w     #1,int_in+6
               move.w     #1,int_in+8
               move.w     d4,int_in+10  ;grand rectangle do_dibigx/y/w/h
               move.w     d5,int_in+12
               move.w     d6,int_in+14
               move.w     d7,int_in+16
               jsr        aes

; form_dial envoie les messages Redraw Ö la fenàtre (3)

               move.w     #51,control
               move.w     #9,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               move.w     #3,int_in     ;Sous-fonction 3
; pas de valeur pour le petit rectangle fo_dilittlx/y/w/h
               move.w     d4,int_in+10  ;grand rectangle do_dibigx/y/w/h
               move.w     d5,int_in+12
               move.w     d6,int_in+14
               move.w     d7,int_in+16
               jmp        aes


deselect:      
; Fait passer le bouton "bouton" en mode non sÇlectionnÇ
; L'arbre objet doit se trouver Ö arbr_adr

               movea.l    arbr_adr,a0
               move.w     bouton,d0     ;Index de l'objet
               mulu.w     #24,d0        ;* 24 (chaque objet fait 24 octets)
               addi.w     #10,d0        ;+10 d'offset pour ob_state
               andi.w     #-2,0(a0,d0.w)          ;Effacer l'octet 0 (selected)
               rts        


write_text:    
; êcrit la chaåne dans l'objet Text ou Edit (index dans d0)
; Chaåne dans a0, arbre objet dans arbr_adr

               movea.l    arbr_adr,a1
               mulu.w     #24,d0
               movea.l    12(a1,d0.w),a1          ;Adresse du bloc TEDINFO
               movea.l    (a1),a1       ;te_ptext contient le texte

wrt_lp:        move.b     (a0)+,(a1)+
               bne.s      wrt_lp
               rts        


read_text:     
; ComplÇment de write_text
; Passer l'adresse cible dans a0

               movea.l    arbr_adr,a1
               mulu.w     #24,d0
               movea.l    12(a1,d0.w),a1
               movea.l    (a1),a1

rd_lp:         move.b     (a1)+,(a0)+
               bne.s      rd_lp
               rts        


               .DATA 

masque:        .DC.b '*.*',0
rscname:       .DC.b 'CODE.RSC',0

not_found:     .DC.b '[3][Ce fichier est complätement|introuvable!]'
               .DC.b '[Alors?]',0

out_of_mem:    .DC.b "[3][Je n' ai pas assez|de mÇmoire pour ce|fichier!]"
               .DC.b '[Augmenter?]',0

rsc_txt:       .DC.b '[3][Je ne trouve pas|le fichier RSC!]'
               .DC.b '[Quitter]',0


               .BSS 


bouton:        .DS.w 1
arbr_adr:      .DS.l 1
fhandle:       .DS.w 1

dta_buff:      .DS.b 26   ;Tampon DTA pour Fsfirst
filesize:      .DS.l 1    ;la taille en octets est ici
               .DS.b 14   ;(le reste est rÇservÇ)

fsel_chem:     .DS.b 40
chemin:        .DS.b 40
default:       .DS.b 13
code:          .DS.b 40

               .END 
