*** ROUTINE ANIMS .FLI ***
*** (C) 1993,RAZORBACK ***

	SECTION TEXT 

                  MOVE.L    #0,-(A7)
                  MOVE.W    #$20,-(A7) 	;SUPER
                  TRAP      #1
                  ADDQ.L    #6,A7   

                  BSR       ROUT_SAVE_COLORS

                  MOVE.L    #ANIMATION,BUFFER
                  
                  MOVE.W    #-1,-(A7) 
                  MOVE.W    #$58,-(A7)
                  TRAP      #$E 
                  ADDQ.L    #4,A7 
                  MOVE.W    D0,SAUVE_RES

END_MONITOR:      MOVE.L    #ECRAN,D0 
                  LSR.L     #8,D0 
                  MOVE.B    D0,-$7DFD.W 
                  LSR.L     #8,D0 
                  MOVE.B    D0,-$7DFF.W 
                  MOVE.L    #ECRAN,D0 
                  MOVE.B    D0,-$7DF3.W 
                  MOVE.L    $70.L,SAUVE_VBL 
                  MOVE.L    #EXIT,8.L 
                  MOVE.L    #EXIT,$C.L
                  MOVE.L    #EXIT,$10.L 
                  MOVE.L    #EXIT,$14.L 
                  MOVE.L    #EXIT,$18.L 
                  MOVE.L    #EXIT,$1C.L 
                  MOVE.L    #VBL,$70.W
                   
                  BSR       READ_FLI_HEADER 

INIT_FILM:        MOVE.W    FRAMES,D0 
                  MOVE.W    D0,PAGE 
                  MOVEA.L   BUFFER,A6 
                  ADDA.L    #$80,A6 
READ_PAGE:        MOVE.W    #0,TIME 
                  BSR       READ_EXTRA_FLI_H
                  MOVE.L    SPEED,D0
SUITE_VBL:        CMP.W     TIME,D0 
                  BGT.S     SUITE_VBL 
                  CMPI.B    #$39,-$3FE.W
                  BEQ       EXIT
                  SUBQ.W    #1,PAGE 
                  TST.W     PAGE
                  BNE.S     READ_PAGE 
                  BRA.S     INIT_FILM 

EXIT:             MOVE.L    SAUVE_VBL,$70.W 

FIN:              CLR.L     -(A7)
;                 MOVE.L    OLD_SP,-(A7)
                  MOVE.W    #$20,-(A7) 	;SUPER
                  TRAP      #1
                  ADDQ.L    #6,A7 

                  MOVE.W    SAUVE_RES,-(A7) 
                  MOVE.W    #$58,-(A7)
                  TRAP      #$E 
                  ADDA.L    #4,A7 

THE_END:          CLR.W     -(A7) 	;PTERM0
                  TRAP      #1

VBL:              ADDQ.W    #1,TIME 
                  RTE 

ROUT_SAVE_COLORS: MOVE.W    #$FF,D0 
                  MOVEA.L   #-$6800,A0
                  MOVEA.L   #SAVE_COLORS,A1 
ROUT_SAVE:        MOVE.L    (A0)+,(A1)+ 
                  DBF       D0,ROUT_SAVE
                  RTS 

                  MOVE.W    #$FF,D0 
                  MOVEA.L   #-$6800,A1
                  MOVEA.L   #SAVE_COLORS,A0 
ROUT_RESTORE:     MOVE.L    (A0)+,(A1)+ 
                  DBF       D0,ROUT_RESTORE 
                  RTS 

LOAD_SIZE:        MOVE.W    #2,-(A7)
                  MOVE.L    ADR_FILENAME,-(A7)
                  MOVE.W    #$3D,-(A7) 	;FOPEN
                  TRAP      #1
                  ADDA.L    #8,A7 
                  MOVE.W    D0,D7 
                  MOVE.W    D0,SAVE_FICHIER 
                  MOVE.L    #BUFFER,-(A7) 
                  MOVE.L    #4,-(A7)
                  MOVE.W    D7,-(A7)
                  MOVE.W    #$3F,-(A7) 	;FREAD
                  TRAP      #1
                  ADDA.L    #$C,A7
                  MOVE.W    D7,-(A7)
                  MOVE.W    #$3E,-(A7) 	;FCLOSE 
                  TRAP      #1
                  ADDA.L    #4,A7 
                  RTS 

LOAD_FILE:        MOVE.W    #2,-(A7)
                  MOVE.L    ADR_FILENAME,-(A7)
                  MOVE.W    #$3D,-(A7) 	;FOPEN
                  TRAP      #1
                  ADDA.L    #8,A7 

                  MOVE.W    D0,D7 
                  MOVE.L    BUFFER,-(A7)
                  MOVE.L    SIZE,-(A7)
                  MOVE.W    D7,-(A7)
                  MOVE.W    #$3F,-(A7) 	;FREAD
                  TRAP      #1
                  ADDA.L    #$C,A7

                  MOVE.W    D7,-(A7)
                  MOVE.W    #$3E,-(A7) 	;FCLOSE 
                  TRAP      #1
                  ADDA.L    #4,A7 

                  RTS 

INIT_SIZE:        MOVEA.L   #BUFFER,A0
                  MOVEQ     #0,D0 
                  MOVE.B    3(A0),D0
                  LSL.W     #8,D0 
                  MOVE.B    2(A0),D0
                  LSL.L     #8,D0 
                  MOVE.B    1(A0),D0
                  LSL.L     #8,D0 
                  MOVE.B    (A0),D0 
                  MOVE.L    D0,SIZE 
                  RTS 

READ_FLI_HEADER:  MOVEA.L   BUFFER,A0 
                  MOVEQ     #0,D0 
                  MOVE.B    7(A0),D0
                  LSL.W     #8,D0 
                  MOVE.B    6(A0),D0
                  MOVE.W    D0,FRAMES 
                  MOVEQ     #0,D0 
                  MOVE.B    9(A0),D0
                  LSL.W     #8,D0 
                  MOVE.B    8(A0),D0
                  MOVE.W    D0,WIDTH
                  MOVEQ     #0,D0 
                  MOVE.B    11(A0),D0 
                  LSL.W     #8,D0 
                  MOVE.B    10(A0),D0 
                  MOVE.W    D0,HEIGHT 
                  MOVEQ     #0,D0 
                  MOVE.B    19(A0),D0 
                  LSL.L     #8,D0 
                  MOVE.B    18(A0),D0 
                  LSL.L     #8,D0 
                  MOVE.B    17(A0),D0 
                  LSL.W     #8,D0 
                  MOVE.B    16(A0),D0 
                  MOVE.L    D0,SPEED
                  RTS 

READ_EXTRA_FLI_H: MOVEA.L   A6,A0 
                  MOVEQ     #0,D0 
                  MOVE.B    3(A0),D0
                  LSL.L     #8,D0 
                  MOVE.B    2(A0),D0
                  LSL.L     #8,D0 
                  MOVE.B    1(A0),D0
                  LSL.L     #8,D0 
                  MOVE.B    (A0),D0 
                  MOVE.L    D0,SIZE_FRAME 
                  MOVEQ     #0,D0 
                  MOVE.B    5(A0),D0
                  LSL.W     #8,D0 
                  MOVE.B    4(A0),D0
                  MOVEQ     #0,D0 
                  MOVE.B    7(A0),D0
                  LSL.W     #8,D0 
                  MOVE.B    6(A0),D0
                  MOVE.W    D0,NBRE_SS_CHUNK
                  MOVEA.L   A6,A5 
                  ADDA.L    #$10,A5 
NEXT_CHUNK:       TST.W     NBRE_SS_CHUNK 
                  BEQ.S     END_CHUNK 
                  BSR       READ_CHUNK
                  SUBQ.W    #1,NBRE_SS_CHUNK
                  BRA.S     NEXT_CHUNK
END_CHUNK:        ADDA.L    SIZE_FRAME,A6 
                  RTS 

READ_CHUNK:       MOVEA.L   A5,A0 
                  MOVEQ     #0,D0 
                  MOVE.B    3(A0),D0
                  LSL.L     #8,D0 
                  MOVE.B    2(A0),D0
                  LSL.L     #8,D0 
                  MOVE.B    1(A0),D0
                  LSL.L     #8,D0 
                  MOVE.B    (A0),D0 
                  MOVE.L    D0,SIZE_DATA_CHUNK
                  MOVEQ     #0,D0 
                  MOVE.B    5(A0),D0
                  LSL.W     #8,D0 
                  MOVE.B    4(A0),D0
                  MOVE.W    D0,TYPE_CHUNK 
                  CMPI.W    #$B,TYPE_CHUNK
                  BEQ       READ_PALETTE
                  CMPI.W    #$C,TYPE_CHUNK
                  BEQ       READ_LC 
                  CMPI.W    #$F,TYPE_CHUNK
                  BEQ       READ_BRUN 
                  CMPI.W    #$10,TYPE_CHUNK 
                  BEQ       READ_COPY 
                  RTS 

READ_COPY:        DC.B      'A',$ED,$00,$06,'&|'
                  DC.L      BUFFER_COLOR
                  DC.B      '#',$FC,$00,$00,$00,$00 
                  DC.L      LINE_MIN
                  DC.B      '3',$FC,$00,$C8 
                  DC.L      LINE_NBRE 
                  DC.B      '"|'
                  DC.L      ECRAN 
                  DC.B      '><',$00,$C7,'<<',$01,'?' 
                  DC.B      'p',$00,$10,$18,'2',$F3,$02,$00 
                  DC.B      'Q',$CE,$FF,$F6,'Q',$CF,$FF,$EE 
                  ADDA.L    SIZE_DATA_CHUNK,A5
                  RTS 

READ_BRUN:        DC.B      'A',$ED,$00,$06,'&|'
                  DC.L      BUFFER_COLOR
                  DC.B      '#',$FC,$00,$00,$00,$00 
                  DC.L      LINE_MIN
                  DC.B      '3',$FC,$00,$C8 
                  DC.L      LINE_NBRE 
                  DC.B      '"|'
                  DC.L      ECRAN 
                  DC.B      '><',$00,$C7,'|',$00,$1C,$18
                  DC.B      'SFz',$00,$1A,$18,'J',$05 
                  DC.B      'm',$1E,'SEx',$00,$18,$18 
                  DC.B      '2',$F3,'B',$00,'Q',$CD,$FF,$FA 
                  DC.B      'Q',$CE,$FF,$E8,'Q',$CF,$FF,$DE 
                  ADDA.L    SIZE_DATA_CHUNK,A5
                  RTS 

                  DC.B      'H',$85,'DESEx',$00 
                  DC.B      $18,$18,'2',$F3,'B',$00,'Q',$CD 
                  DC.B      $FF,$F8,'`',$DC 
READ_LC:          DC.B      'A',$ED,$00,$06,'&|'
                  DC.L      BUFFER_COLOR
                  DC.B      'r',$00,'t',$00,'v',$00,$16,'(' 
                  DC.B      $00,$01,$E1,$8B,$16,$10,$C6,$FC 
                  DC.B      $02,$80,'#',$C3 
                  DC.L      LINE_MIN
                  DC.B      '~',$00,$1E,'(',$00,$03,$E1,$8F 
                  DC.B      $1E,'(',$00,$02,'SG3',$C7 
                  DC.L      LINE_NBRE 
                  DC.B      'X',$88,'"|'
                  DC.L      ECRAN 
                  DC.B      $D3,$C3 
LC_LINES:         DC.B      '|',$00,$1C,$18,'J',$06,'g"'
                  DC.B      'SF'
LC_PACK:          DC.B      'z',$00,$1A,$18,$D2,$C5,$D2,$C5 
                  DC.B      $1A,$18,'J',$05,'m,SE'
                  DC.B      'x',$00,$18,$18,'2',$F3,'B',$00 
                  DC.B      'Q',$CD,$FF,$F6 
RETOUR_LC:        DBF       D6,LC_PACK
                  ADDI.L    #$280,D3
                  MOVEA.L   #ECRAN,A1 
                  ADDA.L    D3,A1 
                  DBF       D7,LC_LINES 
                  ADDA.L    SIZE_DATA_CHUNK,A5
                  RTS 

                  EXT.W     D5
                  NEG.W     D5
                  SUBQ.W    #1,D5 
                  MOVEQ     #0,D4 
                  MOVE.B    (A0)+,D4
LC_POINTS2:       DC.B      '2',$F3 
                  CLR.B     D0
                  DBF       D5,LC_POINTS2 
                  BRA.S     RETOUR_LC 
READ_PALETTE:     MOVEA.L   #BUFFER_COLOR,A1
                  LEA       10(A0),A2 
                  MOVE.W    #$FF,D0 
INSTALLE_COLORS:  MOVEQ     #0,D1 
                  MOVEQ     #0,D2 
                  MOVE.B    (A2)+,D2
                  LSR.W     #1,D2 
                  LSL.W     #8,D2 
                  LSL.W     #3,D2 
                  MOVE.W    D2,D1 
                  MOVEQ     #0,D2 
                  MOVE.B    (A2)+,D2
                  LSR.W     #1,D2 
                  LSL.W     #6,D2 
                  OR.W      D2,D1 
                  MOVEQ     #0,D2 
                  MOVE.B    (A2)+,D2
                  LSR.W     #1,D2 
                  OR.W      D2,D1 
                  MOVE.W    D1,(A1)+
                  DBF       D0,INSTALLE_COLORS
                  ADDA.L    SIZE_DATA_CHUNK,A5
                  RTS 
	
	SECTION DATA
	
ANIMATION	INCBIN	E:\ATROCIT2.FLI
	EVEN

	SECTION BSS
SAUVE_RES:        DS.W      1 
BUFFER_COLOR:     DS.B      1024
ADR_FILENAME:     DS.L      1 
BUFFER            DS.B      8
FRAMES:           DS.W      1 
HEIGHT:           DS.W      1 
LINE_MIN:         DS.L      1 
LINE_NBRE:        DS.B      102 
NBRE_SS_CHUNK:    DS.W      1 
OLD_SP:           DS.L      1 
PAGE:             DS.W      1 
SAUVE_VBL:        DS.L      1 
SAVE_FICHIER:     DS.W      1 
SIZE:             DS.L      1 
SIZE_FRAME:       DS.B      8 
SIZE_DATA_CHUNK:  DS.L      1 
SPEED:            DS.L      1 
TIME:             DS.W      1 
TYPE_CHUNK:       DS.W      1 
WIDTH:            DS.W      1 
SAVE_SCREEN:      DS.L      1 
SAVE_COLORS:      DS.B      1024
ECRAN:            DS.B      121632
L0067:            DS.B      32968 
USTACK:           DS.L      1 
ZUEND: END
