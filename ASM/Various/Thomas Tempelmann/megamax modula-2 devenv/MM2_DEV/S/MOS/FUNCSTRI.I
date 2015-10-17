IMPLEMENTATION MODULE FuncStrings;
(*$Y+,N+,L-*)

(*
  18.06.88  TT : Ersterstellung
  29.06.88  TT : NamensÑnderungen
  13.08.88  TT : UpStr/LowStr Åber Tabelle
*)

FROM SYSTEM IMPORT ASSEMBLER;
IMPORT Strings;

VAR valid: BOOLEAN;


PROCEDURE BlankDel ( REF source: ARRAY OF CHAR ): String;
  BEGIN
    ASSEMBLER
        MOVE    -(A3),D0
        MOVE.L  -(A3),A0
        MOVE.L  A3,A1
        ADDA.W  #80,A3
        MOVEQ   #79,D2
      L SUBQ    #1,D0
        BCS     E
        MOVE.B  (A0)+,D1
        BEQ     E
        CMPI.B  #9,D1           ; TAB
        BEQ     L
        CMPI.B  #' ',D1
        BEQ     L
        MOVE.B  D1,(A1)+
        SUBQ.W  #1,D2
        BCC     L
      E CLR.B   (A1)
    END
  END BlankDel;

PROCEDURE LeadBlankDel ( REF source: ARRAY OF CHAR ): String;
  BEGIN
    ASSEMBLER
        MOVE.L  D3,-(A7)
        MOVE    -(A3),D0
        ADDQ    #1,D0
        MOVE.L  -(A3),A0
        MOVE.L  A3,A1
        ADDA.W  #80,A3
        MOVEQ   #79,D2
        MOVEQ   #1,D3

        SUBQ    #1,D0
        BCS     E
        MOVE.B  (A0)+,D1
        BEQ     E
        CMPI.B  #9,D1           ; TAB
        BEQ     L
        CMPI.B  #' ',D1
        BEQ     L
        MOVEQ   #0,D3

      L SUBQ    #1,D0
        BCS     E
        MOVE.B  (A0)+,D1
        BEQ     E
        TST     D3
        BEQ     N
        CMPI.B  #9,D1           ; TAB
        BEQ     L
        CMPI.B  #' ',D1
        BEQ     L
        MOVEQ   #0,D3
      N MOVE.B  D1,(A1)+
        SUBQ.W  #1,D2
        BCC     L
      E CLR.B   (A1)
        MOVE.L  (A7)+,D3
    END
  END LeadBlankDel;

PROCEDURE TrailBlankDel ( REF source: ARRAY OF CHAR ): String;
  BEGIN
    ASSEMBLER
        MOVE    -(A3),D0
        ADDQ    #1,D0
        MOVE.L  -(A3),A0
        MOVE.L  A3,A1
        MOVE.L  A1,A2
        ADDA.W  #80,A3
        MOVEQ   #79,D2
        
      L SUBQ    #1,D0
        BCS     E
        MOVE.B  (A0)+,D1
        BEQ     E
        CMPI.B  #9,D1           ; TAB
        BEQ     L
        CMPI.B  #' ',D1
        BEQ     L
        MOVE.B  D1,(A1)+
        MOVE.L  A1,A2
        SUBQ.W  #1,D2
        BCC     L
      E CLR.B   (A2)
    END
  END TrailBlankDel;


PROCEDURE Str ( REF source : ARRAY OF CHAR): String;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0
        MOVE.L  -(A3),A0
        MOVE.L  A3,A1
        ADDA.W  #80,A3
        MOVEQ   #79,D1
        CMP.W   D0,D1           ; kleineren der beiden High-Werte
        BLS     L
        MOVE    D0,D1
      L MOVE.B  (A0)+,(A1)+
        DBEQ    D1,L
        CLR.B   (A1)+
      E
    END
  END Str;

PROCEDURE ConcStr ( REF first, second: ARRAY OF CHAR ): String;
  BEGIN
    ASSEMBLER
        LEA     -12(A3),A0
        MOVE.L  A0,(A3)+
        MOVE.W  #79,(A3)+
        MOVE.L  #valid,(A3)+
        JSR     Strings.Concat
        ADDA.W  #80,A3
    END
  END ConcStr;

PROCEDURE CopyStr ( REF source : ARRAY OF CHAR;
                    pos    : INTEGER;
                    len    : INTEGER ): String;
  BEGIN
    ASSEMBLER
        LEA     -10(A3),A0
        MOVE.L  A0,(A3)+
        MOVE.W  #79,(A3)+
        MOVE.L  #valid,(A3)+
        JSR     Strings.Copy
        ADDA.W  #80,A3
    END
  END CopyStr;

PROCEDURE UpStr ( REF source: ARRAY OF CHAR ): String;
  BEGIN
    ASSEMBLER
        MOVE    -(A3),D1
        MOVE.L  -(A3),A0
        MOVE.L  A3,A1
        ADDA.W  #80,A3
        MOVEQ   #79,D2
        LEA     tab(PC),A2
        CLR     D0
l       MOVE.B  (A0)+,D0
        BEQ     e
        MOVE.B  0(A2,D0.W),(A1)+
        SUBQ.W  #1,D1
        DBCS    D2,l
e       CLR.B   (A1)+
        RTS

tab:    DC.B $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
        DC.B $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F
        DC.B ' ','!','"','#','$','%','&',$27,'(',')','*','+',',','-','.','/'
        DC.B '0','1','2','3','4','5','6','7','8','9',':',';','<','=','>','?'
        DC.B '@','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O'
        DC.B 'P','Q','R','S','T','U','V','W','X','Y','Z','[','\',']','^','_'
        DC.B '`','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O'
        DC.B 'P','Q','R','S','T','U','V','W','X','Y','Z','{','|','}','~',''
        DC.B 'Ä','ö','ê','A','é','∂','è','Ä','E','E','E','I','I','I','é','è'
        DC.B 'ê','í','í','O','ô','O','U','U','ò','ô','ö','õ','ú','ù','û','ü'
        DC.B 'A','I','O','U','•','•','¶','ß','®','©','™','´','¨','≠','Æ','Ø'
        DC.B '∑','∏','≤','≤','µ','µ','∂','∑','∏','π','∫','ª','º','Ω','æ','ø'
        DC.B '¡','¡','¬','√','ƒ','≈','∆','«','»','…',' ','À','Ã','Õ','Œ','œ'
        DC.B '–','—','“','”','‘','’','÷','◊','ÿ','Ÿ','⁄','€','‹','›','ﬁ','ﬂ'
        DC.B '‡','·','‚','„','‰','Â','Ê','Á','Ë','È','Í','Î','Ï','Ì','Ó','Ô'
        DC.B '','Ò','Ú','Û','Ù','ı','ˆ','˜','¯','˘','˙','˚','¸','˝','˛','ˇ'
    END
  END UpStr;

PROCEDURE LowStr ( REF source: ARRAY OF CHAR ): String;
  BEGIN
    ASSEMBLER
        MOVE    -(A3),D1
        MOVE.L  -(A3),A0
        MOVE.L  A3,A1
        ADDA.W  #80,A3
        MOVEQ   #79,D2
        LEA     tab(PC),A2
        CLR     D0
l       MOVE.B  (A0)+,D0
        BEQ     e
        MOVE.B  0(A2,D0.W),(A1)+
        SUBQ.W  #1,D1
        DBCS    D2,l
e       CLR.B   (A1)+
        RTS

tab     DC.B $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
        DC.B $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F
        DC.B ' ','!','"','#','$','%','&',$27,'(',')','*','+',',','-','.','/'
        DC.B '0','1','2','3','4','5','6','7','8','9',':',';','<','=','>','?'
        DC.B '@','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o'
        DC.B 'p','q','r','s','t','u','v','w','x','y','z','[','\',']','^','_'
        DC.B '`','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o'
        DC.B 'p','q','r','s','t','u','v','w','x','y','z','{','|','}','~',''
        DC.B 'á','Å','Ç','É','Ñ','Ö','Ü','á','à','â','ä','ã','å','ç','Ñ','Ü'
        DC.B 'Ç','ë','ë','ì','î','ï','ñ','ó','ò','î','Å','õ','ú','ù','û','ü'
        DC.B '†','°','¢','£','§','§','¶','ß','®','©','™','´','¨','≠','Æ','Ø'
        DC.B '∞','±','≥','≥','¥','¥','Ö','∞','±','π','∫','ª','º','Ω','æ','ø'
        DC.B '¿','¿','¬','√','ƒ','≈','∆','«','»','…',' ','À','Ã','Õ','Œ','œ'
        DC.B '–','—','“','”','‘','’','÷','◊','ÿ','Ÿ','⁄','€','‹','›','ﬁ','ﬂ'
        DC.B '‡','·','‚','„','‰','Â','Ê','Á','Ë','È','Í','Î','Ï','Ì','Ó','Ô'
        DC.B '','Ò','Ú','Û','Ù','ı','ˆ','˜','¯','˘','˙','˚','¸','˝','˛','ˇ'
    END
  END LowStr;

PROCEDURE EatSpc ( REF source: ARRAY OF CHAR ): String;
  BEGIN
    ASSEMBLER
        MOVE    -(A3),D0
        MOVE.L  -(A3),A0
        MOVE.L  A3,A1
        ADDA.W  #80,A3
        MOVEQ   #79,D2
      L MOVE.B  (A0)+,D1
        BEQ     E
        CMPI.B  #' ',D1
        BEQ     C
        MOVE.B  D1,(A1)+
        SUBQ.W  #1,D2
        BCS     E
      C DBRA    D0,L
      E CLR.B   (A1)
    END
  END EatSpc;


PROCEDURE DelStr ( REF source : ARRAY OF CHAR;
                   pos    : INTEGER;
                   len    : INTEGER ): String;
  BEGIN
    ASSEMBLER
        MOVE.L  D4,-(A7)
        MOVE.W  -(A3),D0        ; len
        MOVE.W  -(A3),D1        ; pos
        MOVE.W  -(A3),D2        ; high
        MOVE.L  -(A3),A0        ; source
        MOVE.L  A3,A1
        ADDA.W  #80,A3
        MOVEQ   #79,D4
        TST.W   D1
        BPL     C
        ADD.W   D1,D0
        CLR     D1
      C ; D1: start, D0: anzahl
        BRA     D
      L MOVE.B  (A0)+,(A1)+     ; source kopieren
        BEQ     E
        SUBQ.W  #1,D4
        BCS     E
        SUBQ.W  #1,D2
        BCS     E
      D DBRA    D1,L            ; pos
        ; jetzt 'len' Zeichen Åberspringen
      M SUBQ.W  #1,D0
        TST.W   D0
        BMI     L               ; wieder source kopieren
        TST.B   (A0)+
        BEQ     E
        SUBQ.W  #1,D2
        BCS     E
        BRA     M
      E CLR.B   (A1)
        MOVE.L  (A7)+,D4
    END
  END DelStr;

PROCEDURE InsStr ( REF this : ARRAY OF CHAR;
                   at   : INTEGER;
                   REF into : ARRAY OF CHAR ): String;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0        ; high (into)
        MOVE.L  -(A3),A0        ; into
        MOVE.W  -(A3),D2        ; at
        MOVE.W  -(A3),D1        ; high (this)
        MOVE.L  -(A3),A1        ; this
        MOVE.L  A3,A2
        ADDA.W  #80,A3
        MOVEQ   #79,D4
      O ADDQ.W  #1,D0
        TST.W   D2
        BPL     P
        ADDQ    #1,D2
        TST.B   (A1)+
        DBEQ    D1,O
        MOVEQ   #-1,D2
      L SUBQ.W  #1,D0
        BCS     E
        MOVE.B  (A0)+,(A2)+     ; Bereich vor 'at' kopieren
        BEQ     E
        SUBQ    #1,D4
        BCS     E
      P DBRA    D2,L
      C MOVE.B  (A1)+,(A2)+     ; 'this' kopieren
        BEQ     R
        SUBQ    #1,D4
        DBCS    D1,C
        BCC     L
        BRA     E
      R SUBQ.L  #1,A2
        BRA     L
      E CLR.B   (A2)
    END
  END InsStr;

END FuncStrings.

(* $FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$0000064A$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFF6BD6A$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191Ä$00001A0CT.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$000004D1$000000CE$00000029$000008EB$FFEE2C3C$FFEE2C3C$0000002C$FFEA6820$FFEA6820$00001A0C$00001BEA$00002012$00002064$000004D2$000005D9$000004EB®ÄÄ*)
