*---------------------------------------------------------------*
*     Codage du texte et sauvegarde sur disk du texte cod‚      *
*                                                               *
*        by  - Metal68 - from MEKANNIK DESTRUKTIV KOMMANDO      *
*                        le 30/09/1988                          *
*---------------------------------------------------------------*

Page1  equ  $68000

codage movea.l #message,a2
       movea.l #code,a1
       moveq   #0,d0
codag1 move.b  (a2),d0
       subi.b  #$20,d0
       move.b  (a1,d0.w),(a2)+
       cmpi.w  #$3B,d0
       bne     codag1
       
table  movea.l #Page1+112,a0
       movea.l #vecteur,a2
       moveq   #7,d0
ta2    movea.l a0,a3
       moveq   #5,d1
ta1    move.l  a0,(a2)+
       adda.l  #8,a0
       dbra    d1,ta1
       move.l  a3,a0
       adda.l  #25*160,a0
       dbra    d0,ta2

save   lea     nom,a0  
       lea     message,a1
       movea.l #vecteur-message+48*4,a2
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
              
message dc.b " "
        DC.B " M.D.K  IS PROUD TO PRESENT YOU  "
        DC.B " -  ARTURA  -           THE MEMBERS "
        DC.B "OF M.D.K ARE :    - THE CRACK -        - MOEBIUS -        "
        DC.B "- METAL68 -         - ZEBEHN -  . . . . . THIS GAME WAS"
        DC.B " CRACKED BY METAL68 ON 03.11.88 , "
        DC.B "THIS BEAUTIFUL INTRO WAS ALSO "
 DC.B "WRITTEN BY METAL68 ( HEY ! THAT'S ME AGAIN ! ). IT'S TIME FOR "
 DC.B " THE BIG GREETINGS : CYBORG AND FIGHTER ( PERHAPS SOON IN M.D.K )"
 DC.B " , KCOLLOCK , FREE BOOTER , S.C.B ( KRAPULAX AND SATANIX ) ,ST-DAN . "
 DC.B "AND NOW SPECIAL"
 DC.B " GREETINGS TO ALL MEMBERS OF  THE REPLICANTS  ( DOM-ST , ((R.AL)) ,"
        DC.B " RANK XEROX, AND SO ON ... ) A BIG HELLO TO OYA SHIVO,"
        DC.B " BO!, SPECTRE ... A VERY SPECIAL HELLO "
        DC.B " TO - TEX -  ( THANX MAD MAX FOR THESE MUSICS ) , LEVEL16 , "
        DC.B " TNT-CREW . . .     I'M SORRY , BUT I COULDN'T KEEP "
        DC.B " THE SCORE SAVING CAUSE THE SOFT PUT IT IN THE TRACK 79 ." 
        DC.B "                      "        
        DC.B "     PRESS SPACE AND ENJOY THIS GAME ....  SEE YOU SOON !!"
        DC.B "     M.D.K     04.11.88         BYE BYE                   " 
        dc.b "["
       even
        
vecteur        
