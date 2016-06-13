*---------------------------------------------------------------*
*     Codage du texte et sauvegarde sur disk du texte cod‚      *
*                                                               *
*        by  - Metal68 - from MEKANNIK DESTRUKTIV KOMMANDO      *
*                        le 30/09/1988                          *
*---------------------------------------------------------------*

codage movea.l #message,a2
       movea.l #code,a1
       moveq   #0,d0
codag1 move.b  (a2),d0
       subi.b  #$20,d0
       move.b  (a1,d0.w),(a2)+
       cmpi.w  #$3B,d0
       bne     codag1
       
save   lea     nom,a0  
       lea     message,a1
       movea.l #fmess-message,a2
       bsr creat
       rts
       
nom    dc.b "texte.mdk",0

       even
;      a0: adresse du nom
;      a1: adresse du buffer
;      a2: longueur

creat move.w #0,-(sp)
      move.l a0,-(sp)
      move.w #$3c,-(sp)
      trap #1
      addq.l #8,sp
      tst.w d0
      bpl writ
      clr.w -(sp)
      trap #1
writ  move.w d0,d3
      move.l a1,-(sp)
      move.l a2,-(sp)
      move.w d3,-(sp)
      move.w #$40,-(sp)
      trap #1
      adda.l #12,sp
close move.w d3,-(sp)
      move.w #$3E,-(sp)
      trap #1
      addq.l #4,sp
      rts

      
code  dc.b 46,28,47,48,49,50,51,32,34,35,46,46,27,33,26,46
      dc.b 36,37,38,39,40,41,42,43,44,45
      dc.b 29,30,46,46,46,31,46,00,01,02,03,04,05,06,07,08,09
      dc.b 10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,52
        
      even
              
message dc.b "    "
	DC.B "  Z U U L  IS PROUD TO PRESENT YOU  - A NEW GAME -"
	DC.B "  DEALED BY ZUUL  ( BOSS, THANX FOR THIS GOOD DEMO )"
	DC.B "  . GIGA GREETING ALL MEMBERS OF ZUUL : STBLORD(ME!), BOSS, NAZGUL,"
	DC.B " MAJOR, SNAKE, JC, MAVERICK, BEESTY, JOKER, FREEDY, ZELTRON"
	DC.B ", VYPER, PUMA, GOLD NINJA, 007ST,MEGABLAST"
	DC.B "  AND THE OTHERS MEMBERS OF ZUUL ..."
	DC.B "  THIS LITTLE DEMO WAS CODED BY STBLORD..."
	DC.B "    "  
	DC.B "     "
        DC.B "  GREETINGS TO BOTH BEST GROUPS IN THE WORLD : THE EMPIRE  AND  THE UNION"
        DC.B "                    AND NOW SPECIAL GREETING TO "
	DC.B " BLACK-KNIGHT, STARFIRES, LES NULS , THE REPLICANTS , TOXIC, TNT-CREW ,"
	dc.b " 42-CREW , REBELS , HAWK , YODA , ARIOCH , DOM ,  ((R.AL)) ,"
	DC.B " RANK XEROX , THE FREE BOOTER , KCOLLOCK , SPECTRE , BO! ,"
	DC.B " RATBOY , SNAKE , TSUNOO , AND ALL"
	DC.B " THE SWAPPERS, THE CRACKERS AND INTRO-MAKERS  . . ."
	DC.B "                 "
	DC.B " BYE BYE , SEE YOU SOON WITH ANOTHER INTRO !!!"
	DC.B "        Z U U L  (S T B L O R D)                        "
        dc.b "["
       even
fmess
