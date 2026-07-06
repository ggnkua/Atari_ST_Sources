(*$T-*) (*$S-*)
IMPLEMENTATION MODULE BigSets;

FROM SYSTEM IMPORT BYTE;

CONST BitsPerWord=16;

(*....................................................*)

PROCEDURE EmptySet(VAR s:BYTESET);

VAR i:CARDINAL;

BEGIN
     FOR i:=0 TO MaxIndex DO s[i]:={} END;
END EmptySet;

(*....................................................*)

PROCEDURE AddSets(VAR s1,s2:BYTESET; VAR s:BYTESET);

VAR i:CARDINAL;

BEGIN
     FOR i:=0 TO MaxIndex DO s[i]:=s1[i]+s2[i] END;
END AddSets;

(*....................................................*)

PROCEDURE Incl(VAR s:BYTESET; x:BYTE);
BEGIN
     INCL(s[ORD(CHAR(x)) DIV BitsPerWord],ORD(CHAR(x)) MOD BitsPerWord);
END Incl;

(*....................................................*)

PROCEDURE Excl(VAR s:BYTESET; x:BYTE);
BEGIN
     EXCL(s[ORD(CHAR(x)) DIV BitsPerWord],ORD(CHAR(x)) MOD BitsPerWord);
END Excl;

(*....................................................*)

PROCEDURE Member(VAR s:BYTESET; x:BYTE):BOOLEAN;
BEGIN
     RETURN
       (ORD(CHAR(x)) MOD BitsPerWord) IN s[ORD(CHAR(x)) DIV BitsPerWord]; 
END Member;

(*....................................................*)

PROCEDURE Equal(VAR s1,s2:BYTESET):BOOLEAN;

VAR i:CARDINAL;

BEGIN
     FOR i:=0 TO MaxIndex DO
         IF s1[i]<>s2[i] THEN RETURN(FALSE) END;
     END;
     RETURN TRUE;
END Equal;

(*....................................................*)

PROCEDURE Subset(VAR s1,s2:BYTESET):BOOLEAN;

VAR i:CARDINAL;

BEGIN
     FOR i:=0 TO MaxIndex DO
         IF NOT (s1[i]<=s2[i]) THEN RETURN(FALSE) END;
     END;
     RETURN TRUE;
END Subset;

(*....................................................*)

END BigSets.
