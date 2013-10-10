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
       subi.b  #$20,d0
       move.b  (a1,d0.w),d1
       move.b  d1,(a3)+
       addq.b  #1,d1
       move.b  d1,(a3)+
       cmpi.w  #$3B,d0
       bne     codag1
       
save   lea     nom,a0  
       lea     buffer,a1
       movea.l #fmess-message,a2
       adda.l  a2,a2
       bsr creat
       rts
       
nom    dc.b "INTRO.TUT\texte.mdk",0

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
      dc.b 00,02,04,06,08,10,12,14,16,18,20,22,24,26,28,30,32
      dc.b 34,36,38,40,42,44,46,48,50       A-Z
      dc.b 96
            
      even
              
message dc.b " "
        dc.b "      WELCOME !        "
        dc.b " ZUUL PROUDLY TO PRESENT YOU - KICK OFF EXTRA TIME -"
        DC.B "  THIS GAME WAS DEALED BY FRODON (EX-STBLORD ?)"
        DC.B " . THIS INTRO WAS GIVEN BY METAL 68 (THANKS !!!)."
        DC.B " MEMBERS OF ZUUL NEW CORPORATION ARE :"
        DC.B " FRODON (A GOD, THE BEST SWAPPER), MAJOR (THE LAST GOD, PROGRAMMER), NAZGUL (A NEW SWAPPER, THE BEST PROGRAMMER),"
        DC.B " VYPER (CONTACT HIS, ON RTEL BAL MIK), BOSS (NO ! THIS THING ISN'T THE BOSS)" 
        DC.B " GOLD NINJA (A BIG SWAPPER), PUMA (CONTACT HIS, RTEL BAL PUMA !)"
        DC.B " NOW IT'S TIME FOR GREETINGS..."
        DC.B " GREETING TO : ALL MEMBERS OF EMPIRE, SNOOKER, BLACK-KNIGHT, EQUINOX, STARFIRES, LES NULS, SNAKE (OLD ZUUL, SOME NEWS ?), BEESTY (YEAH !), 007ST (CONTACT ME, FRODON !)," 
        DC.B " ALL CREWS OF THE ALLIANCE (ESPECIALLY BEGON JN !), MCA, MEDWAY-BOYS, UNION, MEGABLAST, REPLICANTS, CAREBEARS, TCB, LEVEL 16, LOST BOYS, MAD-MAX, TEX, EXIALS TITAN (YOU 'RE DEAD ? CONTACT ME !) AND ALL MY FRIENDS..."
        DC.B " OF COURSE ! HELLO TO JEAN AIMARE, PIVOINE LECHEE, TESTE D'ASPERGE SUCEE, VAMPIRE VAMPIRISEE, CROTTE DE NEZ MAGIQUE, J. DECROTTON, ETC (SUR AMIGA !)"
        DC.B " BON, SALUT A BAD CRACKER'S QUI SE FAIT MASSER PAR JACKY (HA!HA!HA!);.. BIG FUCKING TO MR BUGG (UN ROULEUR !!!), J'ATTENDS TOUJOURS IVANHOE (HA!HA!)..."
        DC.B " FUNKY (UN BATARD, ENCULE, SALAUD, UN FILS DE PUTE ET EN PLUS IL A UN AAAA...), IDEFIX (SUR RTEL, UN BATARD A 0,0001 CENTIME)"
        DC.B " NOUS RECHERCHONS DES PROGRAMMEURS, DES SWAPPERS, OU DES DIFFUSEURS QUI VOUDRAIENT BIEN SE JOINDRE A NOUS (DITES-LE SUR LA BAL MIK...), THAT'S ALL FOLKS !! "
        DC.B " ENJOY THIS GAME !! SEE YOU SOON...     - ZUUL NEW CORPORATION -     BYE...    BYE..."
        DC.B "               "
        dc.b "["
       even
fmess

buffer