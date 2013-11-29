****************************
*------- PACKBITS.S -------*
* Routine de d‚compression *
****************************

    .EXPORT pbits_dcmps, pbits_idcmps
    .IMPORT pbadr_in, pbadr_out
    .IMPORT pbnb_plan, pbnb_pixel, pbnb_ligne, pbmot_larg


pbits_dcmps:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    SUBI.W    #1,pbnb_ligne
    MOVEQ.L   #0,D0
    MOVEQ.L   #0,D6
    MOVE.W    pbnb_pixel,D0
    DIVU.W    #8,D0
    MOVE.W    D0,D6
    SWAP      D0
    TST.W     D0
    BEQ       reste_nul
    ADDQ.W    #1,D6
reste_nul:
    MOVEQ.L   #0,D0
    MOVE.W    pbnb_plan,D0
    MULU.W    D0,D6             ; Nombre d'octets par ligne
    MOVE.L    pbadr_in,A2
    
    MOVEQ.L   #0,D7
    MOVE.W    pbnb_plan,D7
    MOVE.W    D7,D5
    SUBQ.W    #1,D7
    ADD.L     D7,D7

    SWAP      D7
    MOVE.W    pbnb_ligne,D4
    MOVE.L    pbadr_out,A4
    MOVE.L    A4,A3
    
start_plan:
    MOVE.L    A3,A0
    CLR       D3
    CLR       D0

decompresse_ligne:
    CMP.W     pbnb_pixel,D3
    BGE       fin_ligne
    CLR.W     D1
    MOVE.B    (A2)+,D1
    BGE       take_bytes
    CMPI.B    #-128,D1
    BNE       copy_bytes
    BRA       decompresse_ligne   ; Si No Operation

***************************************
* On recopie 1-x fois l'octet suivant *
***************************************
copy_bytes:
    MOVE.B    (A2)+,D2
    EXT.W     D1
    NEG.W     D1
    MOVE.L    A2,A5
loop_pr1:
    MOVE.B    D2,(A3)+
    ADDQ      #8,D3
    ADDA.W    D7,A3
    SWAP      D7
    DBF       D1,loop_pr1
    BRA       decompresse_ligne
    
********************************
* Cas o— l'on prend x+1 octets *
********************************
take_bytes:
    MOVE.B    (A2)+,(A3)+
    ADDQ      #8,D3
    ADDA.W    D7,A3
    SWAP      D7
    DBF       D1,take_bytes
    BRA       decompresse_ligne
    
fin_ligne:
    TST.W     D7
    BEQ       ici_d7
    SWAP      D7
ici_d7:
    SUBI.W    #1,D5
    BEQ       fin_plan
    
    ADDQ.L    #2,A4
    MOVE.L    A4,A3
    CLR.W     D3
    BRA       decompresse_ligne
    
fin_plan:
    MOVE.W    pbnb_plan,D5
    MOVEQ.L   #0,D2
    MOVE.W    pbmot_larg,D2
    ADD.L     D2,D2
    ADD.L     D2,pbadr_out
    MOVE.L    pbadr_out,A4
    MOVE.L    A4,A3
    
    SUBI      #1,D4
    BPL       start_plan
    
retour:
    MOVEM.L   (SP)+,D0-D7/A0-A6 ; Restauration du contexte
    RTS                         ; Retour au programme C


pbits_idcmps:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    MOVEQ.L   #0,D0
    MOVEQ.L   #0,D1
    MOVE.W    pbnb_ligne,D0
    MOVE.W    pbnb_pixel,D1
    MULU.W    D1,D0             ; Nombre de points aprŠs d‚compactage

    MOVE.L    pbadr_in,A0
    MOVE.L    pbadr_out,A1
    MOVEQ.L   #0,D1
iloop:
    TST.L     D0
    BLE       iretour
    MOVEQ.L   #0,D1
    MOVE.B    (A0)+,D1
    BGE       itake_bytes
    CMPI.B    #-128,D1
    BNE       icopy_bytes
    BRA       iloop
    
iretour:
    MOVEM.L   (SP)+,D0-D7/A0-A6 ; Restauration du contexte
    RTS                         ; Retour au programme C

***************************************
* On recopie 1-x fois l'octet suivant *
***************************************
icopy_bytes:
    MOVE.B    (A0)+,D2
    EXT.W     D1
    NEG.W     D1
    SUB.L     D1,D0
iloop_pr1:
    MOVE.B    D2,(A1)+
    DBF       D1,iloop_pr1
    BRA       iloop
    
********************************
* Cas o— l'on prend x+1 octets *
********************************
itake_bytes:
    SUB.L     D1,D0
itloop:
    MOVE.B    (A0)+,(A1)+
    DBF       D1,itloop
    BRA       iloop
