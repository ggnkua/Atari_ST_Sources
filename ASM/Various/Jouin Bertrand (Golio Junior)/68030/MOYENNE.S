* programme de calcul de moyenne

     Section Text
     lea releve,a0
     * releve contient la liste des notes
     * pond‚r‚e
     move.w #10,d0
     * il y a 10 notes
     bsr moyenne
     * routine de calul de la moyenne
     * dans d1 : moyenne
     clr.w -(sp)
     trap #1
    
moyenne
     clr.l d1
     * d1 va contenir la suite des sommes
     clr.l d2
     * d2 va contenir le nombre de note
     subq.w #1,d0
     * on soustrait 1 … d0 pour faire d0 tour
moyenne_boucle
     * d‚but de la boucle
     move.w (0,a0),d3 
     * note dans d3
     mulu.w (2,a0),d3
     add.w d3,d1
     * d1 : somme des notes
     add.w (2,a0),d2
     * nombre des notes
     adda.w #4,a0
     * passage au couple note/pond‚ration suivant
     dbra d0,moyenne_boucle
     * ici : d1 contient la somme des notes
     *       d2 contient le Nbre de notes
     divu.w d2,d1
     * d1 (sur 32 bits)/d2 (sur 16 bits)
     rts
     Section Data
releve
     * releve du type note,coef
     dc.w 10,2
     dc.w 15,3
     dc.w 20,1
     dc.w 0,5
     dc.w 16,8
     dc.w 11,3
     dc.w 13,2
     dc.w 17,5
     dc.w 15,3
     dc.w 16,1
     * ce qui nous donne une moyenne
     * de : 418/33 soit 12.66
