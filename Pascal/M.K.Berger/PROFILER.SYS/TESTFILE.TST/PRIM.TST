    { Profiler-Testversion zu \PROFILER.SYS\DEMOS.PAS\PRIM.PAS }  

CONST ___ = 11;
   ___2 =2;
VAR __ : INTEGER ;
VAR _ : ARRAY [1..___] OF REAL ;
VAR _2 : ARRAY [1..___2] OF REAL ;
VAR _h : STRING; 
VAR _f : TEXT;
CONST N=1000;
VAR I,K:INTEGER;
PRIM:BOOLEAN;
BEGIN FOR __:= 1 TO ___ DO _[__]:=0;  FOR __:= 1 TO ___2 DO _2[__]:=-1;  
_[2]:=1.9E+999;_[3]:=-1.9E+999;_[5]:=1.9E+999;_[6]:=-1.9E+999;
WRITE(2:4) ; 
I:=1;   _[1]:=_[1]+1;  IF I<_[2] THEN _[2]:=I;  IF I>_[3] THEN _[3]:=I;  ; 
REPEAT _[8] := _[8] + 1 ; 
I:=I+2;   _[1]:=_[1]+1;  IF I<_[2] THEN _[2]:=I;  IF I>_[3] THEN _[3]:=I;  ; 
PRIM:=TRUE;   _[7]:=_[7]+1; ; 
K:=1;   _[4]:=_[4]+1;  IF K<_[5] THEN _[5]:=K;  IF K>_[6] THEN _[6]:=K;  ; 
REPEAT _[9] := _[9] + 1 ; 
K:=K+2;   _[4]:=_[4]+1;  IF K<_[5] THEN _[5]:=K;  IF K>_[6] THEN _[6]:=K;  ; 
IF I MOD K=0
THEN BEGIN _[10] := _[10] + 1 ;  PRIM:=FALSE;   _[7]:=_[7]+1;  END  ; 
;   _[4]:=_[4]+1;  IF K<_[5] THEN _[5]:=K;  IF K>_[6] THEN _[6]:=K; 
   _[1]:=_[1]+1;  IF I<_[2] THEN _[2]:=I;  IF I>_[3] THEN _[3]:=I; UNTIL(NOT 
PRIM)OR(K>=TRUNC(SQRT(I)));   _[1]:=_[1]+1;  IF I<_[2] THEN _[2]:=I; 
 IF I>_[3] THEN _[3]:=I;    _[4]:=_[4]+1;  IF K<_[5] THEN _[5]:=K; 
 IF K>_[6] THEN _[6]:=K;    _[7]:=_[7]+1;  ; 
IF PRIM THEN BEGIN _[11] := _[11] + 1 ;  WRITE(I:4)
;   _[1]:=_[1]+1;  IF I<_[2] THEN _[2]:=I;  IF I>_[3] THEN _[3]:=I;  END ; 
   _[7]:=_[7]+1;  UNTIL I>=N;   _[1]:=_[1]+1;  IF I<_[2] THEN _[2]:=I; 
 IF I>_[3] THEN _[3]:=I; ;
;ASSIGN(_f,'\PROFILER.SYS\TESTFILE.TST\PRIM.WRT');
REWRITE(_f);
WRITELN(_f,'(c)1989mkbmeersaukleintier');
WRITELN(_f,'\PROFILER.SYS\DEMOS.PAS\PRIM.PAS');
WRITELN(_f,'ja');
WRITELN(_f,'11.0');
FOR __ := 1 TO ___ DO BEGIN 
STR(_[__],_h);
WRITELN(_f,_h); END;
CLOSE(_f);
WRITELN;WRITELN;
WRITELN('-> Profile-Testlauf beendet. Werte in \PROFILER.SYS\TESTFILE.TST\PRIM.WRT');
WRITELN('-> Bitte profile_2.prg starten. ');
END.
