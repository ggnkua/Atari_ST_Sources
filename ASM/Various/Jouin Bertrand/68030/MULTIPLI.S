     section text

     lea table,a0
     * a0 vaut table
     * on charge dans a0 l'adresse
     * table
     move.w #10,d0
     mulu.w #100,d0
     * et 10000 dans d0
     move.l #-1,d0
     muls.w (a0)+,d0
     * le r‚sultat sign‚ est sur 
     * 32 bits
     move.l #$FFFFFFFF,d0
     mulu.l (a0),d0
     * ici on a un  d‚passement  de 
     * capacit‚ !!
     move.l #1000000,d0
     mulu.l #1000000,d1:d0
     *  1  million  *  1  million  : 
     * r‚sultat sur 64 bits !!
     * d0 : contient le mot long de
     * poid fort

     * retour au systeme
     move.w #0,-(sp)
     * sp : l'autre nom de a7
     trap #1
     section data
table
     dc.w 10
     dc.l 100

