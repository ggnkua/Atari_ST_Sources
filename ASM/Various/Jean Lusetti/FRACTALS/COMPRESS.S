******************************************
* Routine de d‚compression associ‚e … la *
* Routine de compression de COMPRESS.C   *
******************************************

    .IMPORT ain, aout, asize
    .EXPORT dcompress

    
dcompress:
    MOVEM.L   D0-D3/A0-A2,-(SP) ; Sauvegarde du contexte

    MOVEQ.L    #0,D2
    MOVEQ.L    #7,D3
    LEA.L      end_cpy,A2
    MOVEQ.L    #0,D0             ; Initialise le nombre d'octets d‚compact‚s
    MOVE.L     ain,A0
    MOVE.L     aout,A1
    
bcl_dcmp:
    MOVE.B     (A0)+,D2
    TST.B      D2
    BEQ        end_dcmp
    BCLR       D3,D2
    BEQ        change
    ADD.L      D2,D0
    ADD.L      D2,A1
    BRA        bcl_dcmp
change:
    ADD.L      D2,D0
    MOVE.B     D2,D1
    NEG.B      D1
    EXT.W      D1
    JMP        (A2,D1.W*2)

end_dcmp:
    MOVE.L     D0,asize
    MOVEM.L   (SP)+,D0-D3/A0-A2 ; Restauration du contexte
    RTS                         ; Retour au programme C


    REPT 128
    MOVE.B    (A0)+,(A1)+
    ENDM
end_cpy:
    BRA       bcl_dcmp
