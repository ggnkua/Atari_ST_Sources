;
;Postchargement d'un programme et lancement diff‚r‚ avec Pexec
;Assembleur          PEXEC2.ASM
;

gemdos         = 1

crawcin        = 7
cconws         = 9
mshrink        = $4a
pexec          = $4b

               .TEXT 

               movea.l    4(sp),a5      ;Donner de l'espace m‚moire
               move.l     12(a5),d0     ;Longueur du code
               add.l      20(a5),d0     ;+ Longueur du segment donn‚es
               add.l      28(a5),d0     ;+ Longueur du segment BSS +
               addi.l     #$1100,d0     ;Basepage (256 Bytes)+ pile (4KB)

               move.l     d0,d1         ;Longueur plus
               add.l      a5,d1         ;Adresse
               andi.l     #-2,d1        ;(arrondie)
               movea.l    d1,sp         ;Donne le pointeur de la pile

               move.l     d0,-(sp)      ;Longueur de l'espace m‚moire n‚cessaire
               move.l     a5,-(sp)      ;Adresse de la zone m‚moire
               clr.w      -(sp)         ;Octet "dummy" sans importance
               move.w     #mshrink,-(sp)
               trap       #gemdos
               adda.l     #12,sp

               pea        text1         ;Affiche le message
               move.w     #cconws,-(sp)
               trap       #gemdos
               addq.l     #6,sp

               pea        environ       ;Postchargement du programme
               pea        params
               pea        filename
               move.w     #3,-(sp)      ;3 -> charger le programme et
               move.w     #pexec,-(sp)  ;retourner l'adresse
               trap       #gemdos
               adda.l     #16,sp

               tst.l      d0            ;Erreur?
               bmi.s      error         ;alors afficher message...
               move.l     d0,start_adr  ;sinon stocker adresse

               pea        text2         ;Afficher: le programme est
               move.w     #cconws,-(sp) ;prˆt … ˆtre lanc‚
               trap       #gemdos
               addq.l     #6,sp

               move.w     #crawcin,-(sp)          ;Attendre appui touche...
               trap       #gemdos
               addq.l     #2,sp

               clr.l      -(sp)         ;Lancer le programme maintenant
               move.l     start_adr,-(sp)         ;Nous avons appris l'adresse
               clr.l      -(sp)         ;du premier appel Pexec
               move.w     #4,-(sp)      ;4 -> Lancer le programme
               move.w     #pexec,-(sp)
               trap       #gemdos
               adda.l     #16,sp

               pea        text3         ;encore un message...
               bra.s      fin

error:         pea        errtext       ;Afficher message d'erreur
fin:           move.w     #cconws,-(sp)
               trap       #gemdos
               addq.l     #6,sp

               move.w     #crawcin,-(sp)          ;Attendre appui touche...
               trap       #gemdos
               addq.l     #2,sp

               clr.w      -(sp)         ;... et quitter le programme
               trap       #gemdos

               .DATA 

text1:         .DC.b 'Ceci est le programme appelant.',13,10,10,0
text2:         .DC.b 'Programme charg‚. Taper une touche pour le lancer',13,10,10,0
text3:         .DC.b 'Revoici le premier programme!',13,10,10,0
errtext:       .DC.b "Une erreur s'est produite!!!",13,10,10,0
filename:      .DC.b 'NOMPRG.TOS',0
params:        .DC.b 0    ;aucun paramŠtre et
environ:       .DC.b 0    ;aucun environnement

               .BSS 

start_adr:     .DS.l 1

               .END 
