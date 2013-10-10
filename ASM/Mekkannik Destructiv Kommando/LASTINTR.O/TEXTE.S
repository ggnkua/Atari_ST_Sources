*---------------------------------------------------------------*
*     Codage du texte et sauvegarde sur disk du texte cod‚      *
*                                                               *
*        by  - Metal68 - from MEKANNIK DESTRUKTIV KOMMANDO      *
*                        le 30/09/1988                          *
*---------------------------------------------------------------*

codage movea.l #message,a2
       movea.l #code,a1
       movea.l #buffer,a3
       moveq   #0,d0
codag1 move.b  (a2)+,d0
cod1   subi.b  #$20,d0
       move.b  (a1,d0.w),d1
       move.b  d1,(a3)+
	addq.l #1,d1
       move.b  d1,(a3)+
cod3   cmpi.w  #$3B,d0
       bne     codag1
       
save   lea     nom,a0  
       lea     buffer,a1
       movea.l #fmess-message,a2
       move.l  a2,a3
       adda.l  a2,a2
       adda.l  a3,a2
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
leti  dc.w 0

code  dc.b 94       espace
      dc.b 52       !
      dc.b 80       "
      dc.b 94       # non
      dc.b 94       $ non
      dc.b 94       % non
      dc.b 94       & non
      dc.b 92       '
      dc.b 82       (
      dc.b 84       )
      dc.b 94       * non
      dc.b 94       + non
      dc.b 86       ,
      dc.b 88       -
      dc.b 90       .
      dc.b 94       / non
      dc.b 60,62,64,66,68,70,72,74,76,78        0-9
      dc.b 56       :
      dc.b 58       ;
      dc.b 94       < non
      dc.b 94       = non
      dc.b 94       > non
      dc.b 54       ?
      dc.b 94       @ non
      dc.b 00,02,04,06,08,10,12,14,16,18,20,22,24,26,28
      dc.b 30,32,34,36,38,40,42,44,46,48,50		a-z
      dc.b 96
            
      even
              
message dc.b " "
        DC.B " HELLO FOLKS !!!   M.D.K  PRESENTS YOU   - ACTION FIGHTER -    CRACKED "
        DC.B "BY METAL68 ON 21:04:88 ."
        DC.B "   M.D.K IS : THE CRACK  AND  METAL68          "
        DC.B " MEGA GREETINGS TO HUG , MAD , ALDO , DOM , OUTLAW ... "
        DC.B " SPECIAL GREETINGS TO  MOEBIUS, KCOLLOCK, MOUMOUNE, CYBORG,"
        DC.B " ST DAN-ELRIC-GUS FROM LES NULS , THE FREEBOOTER, STBUG, MISS GRAAL ( FROM THE FAT ), "
        dc.b ", SWEETY, SPECTRE, JCP, OUTLAW, "
        dc.b "THE ULTIMATE ( CRACKER ON IBM PC !! ) ..."
        
        DC.B " THE UNION, THE BLADERUNNERS, OXYGENE, "
        DC.B " THE REPLICANTS, TEX, 42-CREW, TCB,"
        DC.B " TNT-CREW, LEVEL 16, TBC ( ESPECIALLY DOC PROF ! ), "
        DC.B " THE OPPONENTS, THE FAT ... "
	DC.B " BIG KISSES TO KIM BASINGER, SIGOURNEY WEAVER, MARIA WHITTAKER, BRIGITTE LAHAIE ...."
	DC.B "       "
        DC.B " THAT'S ALL FOLKS !! "
        DC.B " ENJOY THIS GAME !!   SEE YOU SOON ....     - M.D.K -"
        DC.B "             "
        dc.b "["
       even
fmess

buffer