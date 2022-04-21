*******************************************************************
* ca c mon b‚b‚...je l'ameliore de jour en jour
* Dr Clone FDC Load/write System
* Last version
* LOAD/DEPACK (ATOMIK) en parallax et sous inter!!
* WRITE   (sous inter)
********************************************************************

               TEXT
SUPER          SET 1

               IFNE SUPER
          clr.l     -(A7)
          move.w    #$20,-(A7)
          trap      #1
          addq.l    #6,A7
               ENDC

START:    move      #$2700,SR           * NO MORE INTERUPTS
          move.l    #$80,$FFFA06        * ON NE GARDE KE L'inter bit 5
          move.l    #$80,$FFFA12
          bset      #3,$FFFA17          * SOFTWARE END OF INTERUPT
          move.l    #NEW_VBL,$70.w      * INSTAL NEW VBL
          move.l    #DR_CLONE,$80.w     * ROUTINE EN TRAP #$0
          lea       START(PC),A7        * FIXE UNE ADRESSE POUR LA PILE
          stop      #$2300

* Boucle principale et appel des routines

MAIN:     moveq     #0,D0
          move.b    $FFFC02,D0
          cmpi.b    #$39,D0             * BARRE D'espace POUR D‚MARRER
          beq.s     EXE_SEQ
          bra.s     MAIN                * PAS TOUCHE F1

*****************************************************************************

EXE_SEQ:  lea       $08.w,A0            * ADR DU TABLEAU
          move.l    #SEEK_00,(A0)       * AU D‚BUT DU DISK (PISTE 00)
          move.l    #SEEKXX,4(A0)       * SEEK
          move.l    #READ_WRITE_S,8(A0) * READ SECTORS
          move.l    #THE_END_MY,12(A0)  * FIN
          trap      #$00                * APPEL
          bsr       DEPACK
          bsr       RELOC
CRAZY2:   bra.s     CRAZY2
          movea.l   SAFE_ADRL(PC),A0
          jmp       (A0)

******************************************************************************

FDC_INIT: movem.l   D0-A6,SAVE_REG
          movem.l   FDC_TABLE(PC),D0-A6 * MARCEL ENVOIE LA SAUCE..
          tst.w     42(A1)              * PASSE MOI LE BEURRE
          beq.s     OK_I_READ
          swap      D0                  * ON SWAP LES REGISTRES
          swap      D1                  * PAS BESOIN DE CHANGER KOIKECESOIT DANS LES ROUTINES
          swap      D2                  * DR CLONE ...ALIAS MEGA-FEINTE!
          swap      D3
OK_I_READ:move.l    A5,$7B18(A0)        * VECTEUR D'inter
          rts

DR_CLONE: move      #$2700,SR           * MASQUE INTERS
          bsr.s     FDC_INIT            * INIT REGISTRES
          move.l    2(A7),(A6)
          move.l    24(A1),46(A1)       * ON SAUVE L'adresse de chargement
          move.w    #$FF,32(A1)         * INIT LE 'track-counter' INTERNE
          move.w    #$2700,(A7)         * PAS D'inter pendant la s‚quence
          move.l    $08.w,2(A7)         * 1ERE ROUTINE … EXECUTER
          bsr       CALCUL_ADR_FIN      * CALCUL ADR DE FIN
          bsr       SET_DMA             * MET LE DMA … L'adresse voulue
          swap      D7
          move.w    12(A1),D7           * FACE DE D‚PART
          add.w     D7,D7
          add.w     D7,D7               * D7 * 4
          move.l    0(A1,D7.w),$01FC(A0) * S‚LECTIONNE LA FACE..LA TIT LED S'allume!
          swap      D7
          move.w    #1,36(A1)           * FDC OQP
          move.w    #1,38(A1)           * S‚QUENCE EN COURS
          rte                           * CASSOS

VBL_ROUT: rts

NEW_VBL:  move      #$2700,SR
          bsr       VBL_ROUT
          bsr.s     FDC_INIT
          move.l    2(A7),(A6)
          move.w    (A7),6(A6)
          tst.w     36(A1)              * ACCES DISK?
          bne.s     VBL_LBL1            * OUI SUITE DE LA VBL
          tst.w     38(A1)              * PAS D'acces,s‚quence finie?
          bne.s     NEW_SEQ
          move.w    (A0),D7
          btst      #7,D7
          bne.s     BYE
          move.l    (A1),$01FC(A0)
BYE:      addq.l    #6,A7
          jmp       (A4)
NEW_SEQ:  addi.l    #$04,SEND_+2
          bsr       CALCUL_ADR_FIN
          bsr.s     SET_DMA
SEND_:    move.l    $08,2(A7)
          move.w    #$2700,(A7)
          move.w    #1,36(A1)
          rte
VBL_LBL1: move.l    #TST_SYNC,2(A7)
          move.w    #$2700,(A7)
          rte
TST_SYNC: btst      #5,$73FD(A0)        * ICI C UN PEU DELIRE...
          bne.s     FOLL1
          subq.l    #6,A7
          bclr      #7,$7409(A0)
          bra.s     SIMULIT

FDC_BIT5: move      #$2700,SR
          bsr       FDC_INIT
          move.l    2(A7),(A6)          * SAUVE ADR SUR LA PILE
          move.w    (A7),6(A6)
SIMULIT:  move.w    #1,36(A1)
          bclr      #7,$740D(A0)
          addq.l    #6,A7
FOLL0:    jmp       $00
FOLL1:    movem.l   SAVE_REG(PC),D0-A6  * REMET REGISTRES
ADR_R:    move.l    #$00,-(A7)
THE_SR:   move.w    #$00,-(A7)
          rte                           * RETOUR AU PROG PRINCIPAL

SET_DMA:  move.b    27(A1),9(A0)
          move.b    26(A1),7(A0)
          move.b    25(A1),5(A0)
          rts

SEEK_00:  move.l    4(A2),(A3)          * TST_TRACK00 EN FIN DE COMMANDE
          move.w    D0,2(A0)            * SELECT COMMAND REGISTER
          divu      D7,D7               * TEMPO
          move.w    D5,(A0)             * COMMANDE STEP OUT
          jmp       (A4)                * RETOUR AU PRG PRINCIPAL
TST_TRACK00:
          swap      D7
          move.w    (A0),D7
          andi.w    #$04,D7
          bne       FINISHED            * BIT POSITIONN‚ ALORS OK!!(ON EST SUR LA PISTE 00)
          swap      D7
          subq.w    #1,32(A1)           * COMPTEUR -1
          beq.s     NO_TR00             * NUL ,ALORS ERREUR
          bra.s     SEEK_00             * PAS NUL ET PAS BIT 3 ,ALORS ON RECOMMENCE
NO_TR00:  reset

SEEKXX:   move.l    12(A2),(A3)         * PROCHAINE INTER
          move.w    D0,2(A0)            * COMMAND
          divu      D7,D7
          swap      D5
          move.w    D5,(A0)
          swap      D5
          jmp       (A4)
SEEKXX_2: move.w    D4,2(A0)
          divu      D7,D7
          swap      D7
          move.w    (A0),D7
          andi.w    #$FF,D7             * ...
          cmp.w     14(A1),D7           * TEST
          beq       FINISHED            * OUI ALORS SUITE
          swap      D7
          move.l    8(A2),(A3)
          bra.s     STEP

READ_WRITE_S:
          move.l    16(A2),(A3)         * TEST APRŠS L'inter
          bsr.s     SET_DMA
          move.w    D3,2(A0)            * DMA IN/OUT/IN
          swap      D3
          move.w    D3,2(A0)
          swap      D3
          move.w    D3,2(A0)
          move.w    #$01,(A0)           * 512 BYTES/SECTEUR
          divu      D7,D7
          move.w    D4,2(A0)            * SELECT SECREG
          divu      D7,D7
          move.w    16(A1),(A0)         * ‚CRIT AVEC STARTSECTOR
          divu      D7,D7
          move.w    D0,2(A0)
          divu      D7,D7
          move.w    D1,(A0)             * COMMAND READ A SECTOR
          jmp       (A4)                * ON SE KAS
CHANGE:   move.w    #1,16(A1)
          move.w    12(A1),D7           * FACE HANDLE DANS D6
          neg.w     D7                  * - FACE
          addq.w    #3,D7               * - FACE+3 ->NOUVELLE FACE
          move.w    D7,12(A1)           * GARDE
          lsl.w     #2,D7               * 4*FACE --> OFFSET POUR VALEUR
          move.l    0(A1,D7.w),$01FC(A0)
          neg.w     D7                  * -4*FACE
          add.w     #10,D7              * +10
          jmp       0(PC,D7.w)          * JMP --> READ SECTORS(SI ON EST PASS‚ SUR LA 2)/STEP SI ON EST SUR LA 1
          swap      D7                  * PASSE FACE 2
          bra.s     READ_WRITE_S
          move.l    20(A2),(A3)         * PASSE FACE 1
STEP:     move.w    D0,2(A0)
          divu      D7,D7
          move.w    D6,(A0)
          jmp       (A4)                * BYE BYE
LET_TST:  swap      D7
          move.b    5(A0),25(A1)
          movep.w   7(A0),D7
          move.w    D7,26(A1)
          movea.l   28(A1),A5
          cmpa.l    24(A1),A5           * TEST
          ble.s     FINISHED            * N‚GATIF ALORS THE END
          move.w    16(A1),D7           * SECTEUR EN COURS DANS D7
          cmp.w     18(A1),D7           * TEST FIN DE PISTE
          beq.s     CHANGE              * OUI ALORS CHANGE DE FACE OU (DE PISTE ET DE FACE)
          swap      D7
          addi.w    #1,16(A1)
          bra       READ_WRITE_S        * ON LIT LE SECTEUR SUIVANT

CALCUL_ADR_FIN:
          move.l    D7,-(A7)
          move.l    24(A1),D7           * ADRL
          add.l     20(A1),D7           * + NB BYTES
          move.l    D7,28(A1)           * ADR_FIN = ADR DE FIN DE CHARGEMENT
          move.l    (A7)+,D7
          rts

THE_END_MY:
          move.w    #$4E75,SYNC
          clr.w     38(A1)
FINISHED: clr.w     36(A1)
          jmp       (A4)

* Routine de decompactage ATOMIK 3.3
* By Altair from VMAX/MCS
* Modifi‚e par Dr Clone (Synchro DMA - D‚compactage lin‚aire)
* Les fichiers doivent etre packes avec le ATOMIK packer 3.3
* et traites avec un mini-prg ki inverse les donn‚es...
* 1er octet <--> octet n
* '
* octet p   <--> octet n-p+1
*
* octet n   <--> octet 1
* Inversion d'un fichier compact‚
* Atomik V3.3
*

DEPACK:   movea.l   SAFE_ADRL(PC),A0

SYNC_1:   cmpi.l    #"ATOM",(A0)
          bne.s     SYNC_1
          tst.l     4(A0)
          beq.s     SYNC_1
          tst.l     8(A0)
          beq.s     SYNC_1
          addq.l    #4,A0

          move.l    (A0)+,D5
          move.l    (A0)+,D0
          movea.l   A0,A6               * ADR DEBUT DATA PACK
          lea       0(A0,D0.l),A0       * A0 = ADR DE FIN DATA PACK

          move.l    A0,-(A7)
          move.b    1(A7),$FF8201
          move.b    2(A7),$FF8203
          move.b    3(A7),$FF820D
          movea.l   (A7)+,A0

          lea       0(A0,D5.l),A5
          bsr       SYNC
          move.b    (A6)+,D7
          bra       MAKE_JNK

TABLUS:   lea       TABLUS_TABLE(PC),A4
          moveq     #1,D6
          bsr.s     GET_BIT2
          bra.s     TABLUS2
DECRUNCH:
          moveq     #6,D6
TAKE_LENGHT:
          add.b     D7,D7
          beq.s     .EMPTY1
.CONT_COPY:
          dbcc      D6,TAKE_LENGHT
          bcs.s     .NEXT_COD
          moveq     #6,D5
          sub.w     D6,D5
          bra.s     .DO_COPY
.NEXT_COD:
          moveq     #3,D6
          bsr.s     GET_BIT2
          beq.s     .NEXT_COD1
          addq.w    #6,D5
          bra.s     .DO_COPY
.NEXT_COD1:
          moveq     #7,D6
          bsr.s     GET_BIT2
          beq.s     .NEXT_COD2
          add.w     #15+6,D5
          bra.s     .DO_COPY
.EMPTY1:  bsr       SYNC
          move.b    (A6)+,D7
          addx.b    D7,D7
          bra.s     .CONT_COPY
.NEXT_COD2:
          moveq     #13,D6
          bsr.s     GET_BIT2
          add.w     #255+15+6,D5
.DO_COPY:
          move.w    D5,-(A7)
          bne.s     BIGGER
          lea       DECRUN_TABLE2(PC),A4
          moveq     #2,D6
          bsr.s     GET_BIT2
          cmp.w     #5,D5
          blt.s     CONTUS
          addq.w    #2,A7
          subq.w    #6,D5
          bgt.s     TABLUS
          movea.l   A5,A4
          blt.s     .FIRST4
          addq.w    #4,A4
.FIRST4:
          moveq     #1,D6
          bsr.s     GET_BIT2
TABLUS2:
          move.b    0(A4,D5.w),-(A5)
          bra.s     MAKE_JNK
GET_BIT2:
          clr.w     D5
.GET_BITS:
          add.b     D7,D7
          beq.s     .EMPTY
.CONT:    addx.w    D5,D5
          dbra      D6,.GET_BITS
          tst.w     D5
          rts
.EMPTY:   bsr       SYNC
          move.b    (A6)+,D7
          addx.b    D7,D7
          bra.s     .CONT
BIGGER:   lea       DECRUN_TABLE(PC),A4
CONT:     moveq     #2,D6
          bsr.s     GET_BIT2
CONTUS:   move.w    D5,D4
          move.b    14(A4,D4.w),D6
          ext.w     D6
          bsr.s     GET_BIT2
          add.w     D4,D4
          beq.s     .FIRST
          add.w     -2(A4,D4.w),D5
.FIRST:   lea       1(A5,D5.w),A4
          move.w    (A7)+,D5
          move.b    -(A4),-(A5)
.COPY_SAME:
          move.b    -(A4),-(A5)
          dbra      D5,.COPY_SAME
MAKE_JNK:
          moveq     #11,D6
          moveq     #11,D5
TAKE_JNK:
          add.b     D7,D7
          beq.s     EMPTY
CONT_JNK:
          dbcc      D6,TAKE_JNK
          bcs.s     NEXT_COD
          sub.w     D6,D5
          bra.s     COPY_JNK1
NEXT_COD:
          moveq     #7,D6
          bsr.s     GET_BIT2
          beq.s     NEXT_COD1
          addq.w    #8,D5
          addq.w    #3,D5
          bra.s     COPY_JNK1
NEXT_COD1:
          moveq     #2,D6
          bsr.s     GET_BIT2
          swap      D5
          moveq     #15,D6
          bsr.s     GET_BIT2
          addq.l    #8,D5
          addq.l    #3,D5
COPY_JNK1:
          subq.w    #1,D5
          bmi.s     .END_WORD
          moveq     #1,D6
          swap      D6
.COPY_JNK:
          bsr       SYNC
          move.b    (A6)+,-(A5)
          dbra      D5,.COPY_JNK
          sub.l     D6,D5
          bpl.s     .COPY_JNK
.END_WORD:
          cmpa.l    A6,A0
.DECRUNCH:
          bne       DECRUNCH
          cmp.b     #$80,D7
          bne.s     .DECRUNCH
NO_CRUNCHED:
          rts
EMPTY:    bsr       SYNC
          move.b    (A6)+,D7
          addx.b    D7,D7
          bra.s     CONT_JNK
SYNC:     lea       $FF8609,A1
          clr.l     -(A7)
          move.b    4(A1),3(A7)
          move.b    2(A1),2(A7)
          move.b    (A1),1(A7)
          movea.l   (A7)+,A1
          cmpa.l    A6,A1
          ble.s     SYNC
          rts

DECRUN_TABLE:
               DC.W 32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
               DC.W 32+64+256+512+1024+2048,96+256+512+1024+2048+4096
               DC.B 4,5,7,8,9,10,11,12
DECRUN_TABLE2:
               DC.W 32,32+64,32+64+128,32+64+128+256
               DC.W 32+64+128+256+512,32+64+128+256+512*2
               DC.W 32+64+128+256+512*3
               DC.B 4,5,6,7,8,8
TABLUS_TABLE:
               DC.B $60,$20,$10,$08

*****************************************************************************

RELOC:    movea.l   SAFE_ADRL(PC),A0
          lea       $1C(A0),A5          * A5=D‚BUT DU PRG
          cmpi.w    #$601A,(A0)+        * EST-CE UN PROG?
          bne.s     LET_EXE             * NON ALORS QUIT
          move.w    #$4E71,CRAZY2
          move.l    A5,D7               * D7=OFFSET DE RELOCATION
          move.l    (A0)+,D0            * LONGUEUR TEXT
          add.l     (A0)+,D0            * +DATA
          addq.w    #4,A0               * BSS (ON S'en fout car on n'EST PAS SOUS GEM)
          add.l     (A0)+,D0            * +LONGUEUR TABLE SYMBOLE
          lea       0(A5,D0.l),A0       * A0 POINTE SUR TABLEAU DE RELOC
          move.l    (A0)+,D0            * 1ER LONGWORD … RELOGER
          beq.s     LET_EXE             * NUL ALORS ‚XECUTION
          lea       0(A5,D0.l),A5       * SINON POINTE SUR 1ERE VALEUR … RELOGER
          add.l     D7,(A5)             * ON RELOGE
R_0:      moveq     #0,D1               * NETTOIE D1
          move.b    (A0)+,D1            * DISTANCE POUR PROCHAINE VALEUR … RELOGER
          beq.s     LET_EXE             * FIN DU TABLEAU=>‚XECUTION
          cmpi.b    #1,D1               * SI D1=1 ALORS DISTANCE >254 OCTETS
          bne.s     R_1
          lea       $FE(A5),A5          * A5+254
          bra.s     R_0                 * BOUCLE
R_1:      adda.w    D1,A5               * A5 POINTE SUR VALEUR
          add.l     D7,(A5)             * RELOGE
          bra.s     R_0                 * BOUCLE
LET_EXE:  rts

*****************************************************************************

NOSIDE:        DC.L $0E0E0707 * D‚SELECTION 0(A1)
SIDE0:         DC.L $0E0E0505 * FACE 0 4(A1)
SIDE1:         DC.L $0E0E0404 * FACE 1 8(A1)
SIDE:          DC.W $01 * FACE DE D‚PART 12(A1)
TRACK:         DC.W $01 * PISTE DE D‚PART 14(A1)
SSEC:          DC.W $01 * SECTEUR DE D‚PART 16(A1)
NSEC:          DC.W $09 * NBRE DE SECTEURS PAR PISTE 18(A1)
SIZE:          DC.L $253F * NB OCTETS … TRANSFERER 20(A1)
ADRL:          DC.L PRG_END * ADR DU TRANSFERT 24(A1)
ADR_FIN:       DC.L 0 * 28(A1)
TRKCOUNT:      DC.W 0 * 32(A1)
OFFS:          DC.W 0 * OFFSET 34(A1)
FDCREADY:      DC.W 0 * 36(A1)
END_SEQ:       DC.W 0 * 38(A1)

DEPACKING:     DC.W 1 * DONN‚ES COMPACT‚ES? 40(A1)
WRITE:         DC.W 0 * ON ‚CRIT? 42(A1)
PROG:          DC.W 0 * C UN PROGRAMME? 44(A1)
SAFE_ADRL:     DC.L 0 * 46(A1)
SCREEN_ADR:    DC.L 0

FDC_TABLE:     DC.L $01800080 * MOTS DE COMMANDE   D0
               DC.L $A80088 * WRITE/READ SECTORS D1
               DC.L $F800E8 * WRITE/READ TRACK   D2
               DC.L $01900090 * SELECT DMA W/R     D3
               DC.L $01840084 * SELECT SEC REG FOR WRITE/READ  D4
               DC.L $C00071 * READ ADDRESS/STEP OUT D5
               DC.L $51 * STEP IN           D6
               DC.L $010001 * POUR LA DIVISION (TEMPORISATION) D7
               DC.L $FFFF8604 * DMA ADR           A0
               DC.L NOSIDE * A1
               DC.L ADR_TAB * A2
               DC.L FOLL0+2 * A3
               DC.L FOLL1 * A4
               DC.L FDC_BIT5
               DC.L ADR_R+2
ADR_TAB:
               DC.L SEEK_00 * +0
               DC.L TST_TRACK00 * +4
               DC.L SEEKXX * +8
               DC.L SEEKXX_2 * +12
               DC.L LET_TST * +16
               DC.L READ_WRITE_S * +20
               DC.L 0
SAVE_REG:      REPT 16
               DC.L 0
               ENDR

PRG_END:
               BSS
               DS.L 30000


               END
