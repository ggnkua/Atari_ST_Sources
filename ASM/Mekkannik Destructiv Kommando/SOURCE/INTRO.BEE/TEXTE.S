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
	DC.B "  M . D . K  IS PROUD TO PRESENT YOU  - ELITE -"
	DC.B "  CRACKED BY FIGHTER  ( THANX FOR THIS GOOD CRACKING )"
	DC.B "      ON THAT OCCASION,"
	DC.B " M . D . K  PRESENT YOU A NEW STYLE OF INTRO "
	DC.B ", THE FIRST USING THE SPECTRUM PICTURES ! "
	DC.B "  THIS BEAUTIFUL INTRO WAS CODED BY METAL68 FROM M.D.K "
	DC.B "... MEMBERS OF M.D.K ARE :      THE CRACK ( THE SWAPPER )"
	DC.B "      METAL68 ( ME ! PROGRAMMER AND CRACKER WHEN I HAVE TIME TO DO IT !! ) "
	DC.B "       MOEBIUS (ANOTHER GOOD SWAPPER )         "
        DC.B "  GREETINGS TO BOTH BEST GROUPS IN THE WORLD : THE UNION  AND  THE BLADE RUNNERS"
        DC.B "                    AND NOW SPECIAL GREETING TO "
	DC.B " LES NULS , THE REPLICANTS , S.T.C.S , TEX ( THANX MAD MAX FOR THIS MUSIC ) , TNT-CREW ,"
	dc.b " 42-CREW , S.C.B , BLOOD , CYBORG , FIGHTER , DOM ,  ((R.AL)) ,"
	DC.B " RANK XEROX , THE FREE BOOTER , KCOLLOCK , SPECTRE , BO! ,"
	DC.B " RATBOY , MEGA ST 2 , TSUNOO , AND ALL"
	DC.B " THE CRACKERS AND INTRO-MAKERS  . . ."
	DC.B "                 "
	DC.B " BYE BYE , SEE YOU SOON WITH ANOTHER SPECTRUM INTRO !!!"
	DC.B "        M . D . K    10:11:1988                        "
        dc.b "["
       even
fmess
