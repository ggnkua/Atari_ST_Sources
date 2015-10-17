Gruppe: Persînliche
ID  : P22205@K2
Wg. : Case-Insensitive Funktionen
Von : Dirk Steins @ K2 (Fr, 14.01.94 19:27)
An  : Thomas Tempelmann @ M
 
Hi Thomas, hier sind zwei Case-Insensitive Funktionen fÅr Strings:

(* FÅr Case-Insensitive Stringvergleiche *)
PROCEDURE StrIequal (REF s1, s2 : ARRAY OF CHAR): BOOLEAN;
BEGIN
  ASSEMBLER
        MOVE    -(A3),D0
        MOVE.L  -(A3),A0
        MOVE.W  -(A3),D1
        MOVE.L  -(A3),A1
        LEA     tab(PC),A2
        CLR.W   D2

l       MOVE.B  (A0)+,D2
        BEQ.S   equ1
        SWAP    D1
        CLR.W   D1
        MOVE.B  0(A2,D2.W),D2
        MOVE.B  (A1)+,D1
        CMP.B   0(A2,D1.W),D2
        BNE.S   ne
        SWAP    D1
        SUBQ.W  #1,D0
        BCS.S   e
        DBRA    D1,l

        ; str1 zu Ende, str0 aber nicht
        TST.B   (A0)+
        BEQ.S   equ0
        BRA.S   ne

equ1    ; str0 zu Ende, str1 prÅfen
        TST.B   (A1)+
        BEQ     equ0

ne      CLR     D0
        RTS

e       ; str0 zu Ende, str1 prÅfen
        TST.W   D1
        BEQ.S   equ0
        TST.B   (A1)+
        BNE.S   ne

equ0    MOVE    #1,D0
        RTS

  tab:  DC.B $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
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
        DC.B '‡','û','‚','„','‰','Â','Ê','Á','Ë','È','Í','Î','Ï','Ì','Ó','Ô'
        DC.B '','Ò','Ú','Û','Ù','ı','ˆ','˜','¯','˘','˙','˚','¸','˝','˛','ˇ'
  END
END StrIequal;

PROCEDURE StrICompare (REF str0,str1: ARRAY OF CHAR) : MagicStrings.Relation;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0    ; HIGH (str1)
        MOVE.L  -(A3),A0    ; ADR (str1)
        MOVE.W  -(A3),D1    ; HIGH (str0)
        MOVE.L  -(A3),A1    ; ADR (str0)
        CLR.W   D2
        LEA     tab(PC),A2

l       MOVE.B  (A0)+,D2
        BEQ.S   equ1
        MOVE.B  0(A2,D2.W),D2
        SWAP    D1
        CLR.W   D1
        MOVE.B  (A1)+,D1
        CMP.B   0(A2,D1.W),D2
        BNE.S   ne
        SWAP    D1
        SUBQ.W  #1,D0
        BCS.S   e
        DBRA    D1,l

        ; str1 zu Ende, str0 aber nicht
        TST.B   (A0)+
        BEQ.S   equ0
        BRA.S   hi

equ1    ; str0 zu Ende, str1 prÅfen
        TST.B   (A1)+
        BEQ.S   equ0
        BRA.S   low

ne      MOVE.B  0(A2,D2.W),D1
        MOVE.B  -(A1),D0
        CMP.B   0(A2,D0.W),D1
        BHI.S   hi
        BCS.S   low
        CMP.B   D0,D2   ; wenn Umlaute gleich, dann ASCII-Wert vergleichen
        BHI.S   hi
        BRA.S   low

e       ; str0 zu Ende, str1 prÅfen
        TST.W   D1
        BEQ.S   equ0
        TST.B   (A1)+
        BNE.S   low

equ0    MOVE    #MagicStrings.equal,D0
        BRA.S   end
hi      MOVE    #MagicStrings.less,D0
        BRA.S   end
low     MOVE    #MagicStrings.greater,D0
end     RTS

tab     DC.B    $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
        DC.B    $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F
        DC.B    $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F
        DC.B    $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F
        DC.B    $40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F
        DC.B    $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$5B,$5C,$5D,$5E,$5F

        DC.B    $60,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F
        DC.B    $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$7B,$7C,$7D,$7E,$7F

        DC.B    'C','U','E','A','A','A','A','C','E','E','E','I','I','I','A','A'
        DC.B    'E','A','A','O','O','O','U','U','Y','O','U',$9B,$9C,$9D,'s',$9F
        DC.B    'A','I','I','U','N','N','A','O',$A8,$A9,$AA,$AB,$AC,$AD,$AE,$AF
        DC.B    'A','O','O','O','O','O','A','A','O',$B9,$BA,$BB,$BC,$BD,$BE,$BF
        DC.B    'I','I',$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF
        DC.B    $D0,$D1,$D2,$D3,$D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF
        DC.B    $E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7,$E8,$E9,$EA,$EB,$EC,$ED,$EE,$EF
        DC.B    $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7,$F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF
    END
  END StrICompare;

Die Funktion StrICompare macht einen Case-insensitiven Compare, und StrIequal
macht halt einen Case-Insensitiven Vergleich. Die RÅckgabewerte sind im Moment
die von der MagicLib, aber das anzupassen ist ja Kinderkram. Auûerdem geht die
ErgebnisrÅckgabe im Moment Åber D0, das muût Du dann noch an A3 anpassen.

Wenn Du Dich wunderst, warum da D1 geswapt wird: Das wird doppelt verwendet,
zweimal fÅr Worte. Ich hatte eigentlich mal D3 dafÅr verwendet (und natÅrlich
auch gesichert und restauriert), aber damit hat mir irgendwas ab und zu D3
zerstîrt und damit die Vergleiche zunichte gemacht! Ich habe keine Ahnung,
woran das lag, aber so funktioniert es wenigstens!

 Gruû, Dirk
