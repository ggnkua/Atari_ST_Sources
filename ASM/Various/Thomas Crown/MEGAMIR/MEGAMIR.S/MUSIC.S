
* Source pour jouer les musiques rippe‚s avec Megamir.


 dc.w $a00a              * Out souris
 
 clr.l -(sp)             * Vide la pile utilisateur
 move #32,-(sp)          * Gemdos 32 (supervisor)
 trap #1                 * Interruption 1
 addq.l #6,sp            * R‚tablit la pile
 
 move.l #text,-(sp)      * Adresse sur la pile
 move #9,-(sp)           * Gemdos 9 (‚criture de caracteres)
 trap #1                 * Interruption 1
 addq.l #6,sp            * R‚tablit la pile
                         
 move.l $4d2.w,-(sp)     * Sauve $4d2.w 

 lea zikos,a0            * Pointe zik 
 moveq #1,d0             * Zik: Il peut y en avoir plusieurs... 1,2,3,4,5
 jsr (a0)                * Init zik
 lea $8(a0),a0           * $8: Mad Max  ;  $2: Count Zero
 move.l a0,$4d2.w        * Play zik

 move #7,-(sp)           * Gemdos 7 (lecture d'un caractŠre)
 trap #1                 * Interruption 1
 addq.l #2,sp            * R‚tablit la pile

 move.l (sp)+,$4d2.w     * R‚tablit $4d2.w (stop musique)

 move #32,-(sp)          *
 trap #1                 * On revient en utilisateur
 addq.l #6,sp            * 
 
 clr.l -(sp)             *
 trap #1                 * Retour bureau
 
zikos:incbin "a:\ZIKOS.BIN"           * Ici le fichier binaire !
text:dc.b "Megamir / Thomas Crown ",$00  
 
 