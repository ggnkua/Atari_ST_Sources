(*$T-,$S-*)
IMPLEMENTATION MODULE UCSDStuff;

FROM SYSTEM IMPORT
       ADR,ADDRESS,CODE,SETREG,BYTE,WORD,REGISTER;

CONST D0=0; D1=1; D2=2; A1=9; A2=10;

(*..................................................*)

PROCEDURE MoveLeft(s,d:ADDRESS; bytes:CARDINAL);

VAR saddr,daddr:ADDRESS;

BEGIN
     IF bytes=0 THEN RETURN END;

     saddr:=s; daddr:=d;
     CODE(04281H);            (*     CLR.L  D1              *)
     SETREG(D1,bytes);
     SETREG(A1,saddr);
     SETREG(A2,daddr);
     CODE(05341H,             (*     SUBQ.W 1,D1           *)
          014D9H,             (* $1  MOVE.B (A1)+,(A2)+     *)
          051C9H,0FFFCH);     (*     DBRA   D1,$1           *)
END MoveLeft;

(*..................................................*)

PROCEDURE MoveRight(s,d:ADDRESS; bytes:CARDINAL);

VAR saddr,daddr:ADDRESS;

BEGIN
     IF bytes=0 THEN RETURN END;

     saddr:=s; INC(saddr,bytes);
     daddr:=d; INC(daddr,bytes);
     CODE(04281H);            (*     CLR.L  D1              *)
     SETREG(D1,bytes);
     SETREG(A1,saddr);
     SETREG(A2,daddr);
     CODE(05341H,             (*     SUBQ.W 1,D1           *)
          01521H,             (* $1  MOVE.B -(A1),-(A2)     *)
          051C9H,0FFFCH);     (*     DBRA   D1,$1           *)
END MoveRight;

(*..................................................*)

PROCEDURE FillChar(d:ADDRESS; bytes:CARDINAL; c:CHAR);

VAR daddr:ADDRESS;

BEGIN
     IF bytes=0 THEN RETURN END;

     daddr:=d;
     SETREG(D0,c);
     CODE(04281H);            (*     CLR.L  D1              *)
     SETREG(D1,bytes);
     SETREG(A2,daddr);
     CODE(05341H,             (*     SUBQ.W 1,D1      *)
          014C0H,             (* $1  MOVE.B D0,(A2)+   *)
          051C9H,0FFFCH);     (*     DBRA   D1,$1      *)
END FillChar;

(*..................................................*)

PROCEDURE Scan(dist:CARDINAL; c:CHAR; equal:BOOLEAN; d:ADDRESS):CARDINAL;

VAR bytesleft:CARDINAL;
    daddr:ADDRESS;

BEGIN
     IF dist=0 THEN RETURN(0) END;

     daddr:=d;
     CODE(04281H);            (*     CLR.L  D1              *)
     SETREG(D1,dist);
     SETREG(D0,c);
     SETREG(D2,equal);
     SETREG(A2,daddr);
     CODE(05341H,          (*    SUBQ.W 1,D1    ;*)
          0C47CH,00001H,   (*    AND.W  1,D2    ;EQUALITY TEST?       *)
          06700H,00010H,   (*    BEQ    $2       ;SKIP IF NOT          *)
          0B01AH,          (* $1 CMP.B  (A2)+,D0 ;C = STRING[A2] ?     *)
          06700H,00014H,   (*    BEQ    $3       ;EXIT IF CHAR FOUND   *)
          051C9H,0FFF8H,   (*    DBRA   D1,$1    ;LOOP FOR ALL CHARS   *)
          06000H,0000CH,   (*    BRA    $3       ;SEARCH FAILED - EXIT *)
          0B01AH,          (* $2 CMP.B  (A2)+,D0 ;C = STRING[A2]       *)
          06600H,00006H,   (*    BNE    $3       ;EXIT IF CHAR WRONG   *)
          051C9H,0FFF8H,   (*    DBRA   D1,$2    ;LOOP FOR ALL CHARS   *)
          02001H);         (* $3 MOVE.L D1,D0    ;SAVE RESULT          *)
     bytesleft := CARDINAL(REGISTER(D0));
     RETURN dist-(bytesleft+1);
END Scan;

(*..................................................*)

PROCEDURE ScanBack(dist:CARDINAL; c:CHAR; equal:BOOLEAN;d:ADDRESS):CARDINAL;

VAR bytesleft:CARDINAL;
    daddr:ADDRESS;

BEGIN
     IF dist=0 THEN RETURN(0) END;

     daddr:=d;
     CODE(04281H);         (*     CLR.L  D1              *)
     SETREG(D1,dist);
     SETREG(D0,c);
     SETREG(D2,equal);
     SETREG(A2,daddr);
     CODE(05341H,          (*    SUBQ.W 1,D1    ;  *)
          0528AH,          (*    ADDQ.L 1,A2    ;FIX PREDECREMENT     *)
          0C47CH,00001H,   (*    AND.W  1,D2    ;EQUALITY TEST?       *)
          06700H,00010H,   (*    BEQ    $2       ;SKIP IF NOT          *)
          0B022H,          (* $1 CMP.B  -(A2),D0 ;C = STRING[A2] ?     *)
          06700H,00014H,   (*    BEQ    $3       ;EXIT IF CHAR FOUND   *)
          051C9H,0FFF8H,   (*    DBRA   D1,$1    ;LOOP FOR ALL CHARS   *)
          06000H,0000CH,   (*    BRA    $3       ;SEARCH FAILED - EXIT *)
          0B022H,          (* $2 CMP.B  -(A2),D0 ;C = STRING[A2]       *)
          06600H,00006H,   (*    BNE    $3       ;EXIT IF CHAR WRONG   *)
          051C9H,0FFF8H,   (*    DBRA   D1,$2    ;LOOP FOR ALL CHARS   *)
          02001H);         (* $3 MOVE.L D1,D0    ;SAVE RESULT          *)
     bytesleft := CARDINAL(REGISTER(D0));
     RETURN dist-(bytesleft+1);
END ScanBack;

(*..................................................*)

PROCEDURE FillWord(VAR d:ARRAY OF WORD; words:CARDINAL; val:WORD);

VAR daddr:ADDRESS;

BEGIN
     IF words=0 THEN RETURN END;

     daddr:=ADR(d);
     SETREG(D0,val);
     CODE(04281H);            (*     CLR.L  D1              *)
     SETREG(D1,words);
     SETREG(A2,daddr);
     CODE(05341H,           (*     SUBQ.W 1,D1      *)
          034C0H,           (* $1  MOVE.W D0,(A2)+   *)
          051C9H,0FFFCH);   (*     DBRA   D1,$1      *)
END FillWord;

(*..................................................*)

PROCEDURE MoveWord(VAR s,d:ARRAY OF WORD; words:CARDINAL);

VAR saddr,daddr:ADDRESS;

BEGIN
     IF words=0 THEN RETURN END;

     saddr:=ADR(s); daddr:=ADR(d);
     CODE(04281H);            (*     CLR.L  D1              *)
     SETREG(D1,words);
     SETREG(A1,saddr);
     SETREG(A2,daddr);
     CODE(05341H,             (*     SUBQ.W 1,D1           *)
          034D9H,             (* $1  MOVE.W (A1)+,(A2)+     *)
          051C9H,0FFFCH);     (*     DBRA   D1,$1           *)
END MoveWord;

(*..................................................*)

PROCEDURE WordScan(words:INTEGER; c:WORD; equal:BOOLEAN;
                   VAR d:ARRAY OF WORD):INTEGER;

VAR wordsleft:INTEGER;
    daddr:ADDRESS;

BEGIN
     IF words=0 THEN RETURN(0) END;

     daddr:=ADR(d);
     CODE(04281H);         (*     CLR.L  D1              *)
     SETREG(D1,words);
     SETREG(D0,c);
     SETREG(D2,equal);
     SETREG(A2,daddr);
     CODE(0C47CH,08000H,   (*    AND.W  8000H,D2;CNT<0 = SCAN BACK    *)
          06600H,00028H,   (*    BNE    $3       ;BRANCH IF BACK       *)
          05341H,          (*    SUBQ.W 1,D1    ;DBcc WORKS STRANGELY *)
          0C47CH,00001H,   (*    AND.W  1,D2    ;EQUALITY TEST?       *)
          06700H,00010H,   (*    BEQ    $2       ;SKIP IF NOT          *)
          0B05AH,          (* $1 CMP.W  (A2)+,D0 ;C = STRING[A2] ?     *)
          06700H,0003EH,   (*    BEQ    $6       ;EXIT IF CHAR FOUND   *)
          051C9H,0FFF8H,   (*    DBRA   D1,$1    ;LOOP FOR ALL CHARS   *)
          06000H,00036H,   (*    BRA    $6       ;SEARCH FAILED - EXIT *)
          0B05AH,          (* $2 CMP.W  (A2)+,D0 ;C = STRING[A2]       *)
          06600H,00030H,   (*    BNE    $6       ;EXIT IF CHAR WRONG   *)
          051C9H,0FFF8H,   (*    DBRA   D1,$2    ;LOOP FOR ALL CHARS   *)
          06000H,00028H,   (*    BRA    $6                             *)
          0548AH,          (* $3 ADDQ.L 2,A2    ;FIX PREDECREMENT     *)
          04441H,          (*    NEG.W  D1       ;COUNT := -COUNT      *)
          05341H,          (*    SUBQ.W 1,D1    ;DBcc WORKS STRANGELY *)
          0C47CH,00001H,   (*    AND.W  1,D2    ;EQUALITY TEST?       *)
          06700H,00010H,   (*    BEQ    $5       ;SKIP IF NOT          *)
          0B062H,          (* $4 CMP.W  -(A2),D0 ;C = STRING[A2] ?     *)
          06700H,00014H,   (*    BEQ    $6       ;EXIT IF CHAR FOUND   *)
          051C9H,0FFF8H,   (*    DBRA   D1,$4    ;LOOP FOR ALL CHARS   *)
          06000H,0000CH,   (*    BRA    $6       ;SEARCH FAILED - EXIT *)
          0B062H,          (* $5 CMP.W  -(A2),D0 ;C = STRING[A2]       *)
          06600H,00006H,   (*    BNE    $6       ;EXIT IF CHAR WRONG   *)
          051C9H,0FFF8H,   (*    DBRA   D1,$5    ;LOOP FOR ALL CHARS   *)
          02001H);         (* $6 MOVE.L D1,D0    ;SAVE RESULT          *)
     wordsleft := CARDINAL(REGISTER(D0));
     RETURN words-(wordsleft+1);
END WordScan;

(*..................................................*)

END UCSDStuff.
