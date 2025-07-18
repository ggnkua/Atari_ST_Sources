; DSP_MOD en accessoire ...

        ILABEL D:\MC68000\PROFIMAT.MAP\GEM.BIB

TIMER_GEM=$400

LGMOD=512*1024 ;Lg. maxi du module

        GEM_ACC

 ;Mettre une entr�e dans le menu
        LEA VIBRAX(PC),A3
        MENU_ACC A3
        MOVE D0,ACCN

        LEA FILTRE(PC),A0
        LEA MOD_CH(PC),A1
\1      MOVE.B (A0)+,(A1)+
        BNE \1

        LEA PLAYER(PC),A0
        BSR RELOGER

 ;Attendre la s�lection
ATT     LEA MB(PC),A3
        EVNT_MESS A3
        CMPI #40,(A3) ;ACCS_OPEN
        BNE ATT
        MOVE 8(A3),D0
        CMP ACCN(PC),D0
        BNE ATT

OUI: ;Ouvrir le s�lecteur de fichier
        LEA MOD_CH(PC),A3
        LEA MOD_FIC(PC),A4
        CLR.B (A4)
        LEA MSF(PC),A5
        BSR FSEL
        CMPI #1,D3
        BEQ.S \1
        BSR ONSTOP
        BRA ATT

\1      BSR ONSTOP
        FILE_OPEN #ACCES_FICHIER,#0
        MOVE D0,FIC_C
        BMI ATT
        LEA MODULE(PC),A3
        MOVE.L #LGMOD,D3
        FILE_READ FIC_C(PC),D3,A3
        CMP.L D3,D0
        BEQ ATT
        FILE_CLOSE FIC_C(PC)

        BSR ONYVA

        BRA ATT

RELOGER: ;E:A0=adresse du prog. � reloger
        MOVE.L  2(A0),D0
        ADD.L   6(A0),D0
        ADD.L   14(A0),D0
        ADDA    #28,A0
        MOVE.L  A0,D1
        MOVEA.L A0,A1
        MOVEA.L A1,A2
        ADDA.L  D0,A1
        MOVE.L  (A1)+,D0
        ADDA.L  D0,A2
        ADD.L   D1,(A2)
        MOVEQ   #0,D0
\1      MOVE.B  (A1)+,D0
        BEQ.S   \f
        CMP.B   #1,D0
        BEQ.S   \2
        ADDA    D0,A2
        ADD.L   D1,(A2)
        BRA     \1
\2      ADDA    #254,A2
        BRA     \1
\f      RTS

FSEL:
 ;E:A3=Chemin
 ;E:A4=Fichier
 ;E:A5=Info
 ;S:D3=bouton de sortie
 ;S:ACCES_FICHIER pr�t
        FILE_SELECT A3,A4,D3,A5
        CMPI #1,D3
        BNE.S \f
        LEA ACCES_FICHIER(PC),A2
        MOVEA.L A2,A0
        MOVEA.L A3,A1
\1      MOVE.B (A1)+,(A0)+
        BNE \1
        SUBQ #1,A0
   ;Couper le filtre
   ;c.a.d. apr�s le dernier '\' (S'il existe)
        MOVEQ #'\',D0
\3      CMPA.L A2,A0
        BEQ.S \2
        CMP.B -(A0),D0
        BNE \3
        ADDQ #1,A0
\2      MOVEA.L A4,A1
\4      MOVE.B (A1)+,(A0)+
        BNE \4
\f      RTS

ONYVA:  TST.B EN_COURS
        BNE.S \f
        MOVEQ #1,D0
        LEA MODULE(PC),A0
        BSR PLAYER+28 ;JOUER
        PROG_SUPER #\sp
        ST EN_COURS
\f      RTS

\sp:    MOVE.L  TIMER_GEM,SAVEAREA
        MOVE.L  #TIMER_50HZ,TIMER_GEM
        RTS

ONSTOP: TST.B EN_COURS
        BEQ.S \f
        PROG_SUPER #\sp
        BSR PLAYER+28+4 ;ARRETER
        SF EN_COURS
\f      RTS

\sp:    MOVE.L  SAVEAREA(PC),TIMER_GEM
        RTS

TIMER_50HZ:
        BSR     PLAYER+28+8 ;RAFFRAICHIR
        MOVE.L  SAVEAREA(PC),-(SP)
        RTS

PLAYER:  IBYTES 'DSP.BSW'

        _D
VIBRAX   DC.B '  ~~~ VibraX ~~~',0
FILTRE   DC.B '\*.MOD',0
MSF      DC.B 'Load a *.MOD',0
EN_COURS DC.B 0

        _M
ACCN     DS.W 1
MB       DS.W 8
MOD_CH   DS.B 256
MOD_FIC  DS.B 12+1
ACCES_FICHIER DS.B 256
FIC_C    DS.W 1
SAVEAREA DS.L 1
MODULE   DS.B LGMOD

 END
 