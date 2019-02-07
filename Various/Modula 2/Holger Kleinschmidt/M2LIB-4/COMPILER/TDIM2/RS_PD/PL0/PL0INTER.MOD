IMPLEMENTATION MODULE PL0Interpreter;
(*$S-,$T-,$Q+*)

FROM  TextWindows IMPORT Window, Write, WriteLn, WriteCard, OpenTextWindow,
                         Done, ReadInt, SetCaret, Invert,  CloseTextWindow;

CONST FF = 14c; WINTITLE = " RESULT ";

VAR   win: Window;

PROCEDURE Interpret;
 CONST stacksize = 1000;
 VAR   p,b,t: INTEGER;                (* Program-, Base- & Stack Registers *)
       i: Instruction;                             (* instruction register *)
       s: ARRAY [0..stacksize-1] OF INTEGER;                 (* data store *)
 PROCEDURE base (l: INTEGER): INTEGER;
     VAR B: INTEGER;                   (* Find base address, l levels down.*)
   BEGIN B := b; WHILE (l > 0) DO B := s[B]; DEC (l) END; RETURN B END base;
 BEGIN Write (win, FF); WriteLn (win);
       t := 0; b := 1; p := 0; s[1] := 0; s[2] := 0; s[3] := 0;
   REPEAT i := code[p]; INC (p);
    WITH  i DO
     CASE f OF
     |0: INC (t); s[t] := a;
     |1: CASE a OF (* operators *)
         | 0: t := b -1; p := s[t+3]; b := s[t+2];                  (* Ret *)
         | 1: s[t] := -s[t];
         | 2: DEC (t); s[t] := s[t] + s[t+1];
         | 3: DEC (t); s[t] := s[t] - s[t+1];
         | 4: DEC (t); s[t] := s[t] * s[t+1];
         | 5: DEC (t); s[t] := s[t] DIV s[t+1];
         | 6: s[t] := ORD (ODD (s[t]));
         | 7:
         | 8: DEC (t); s[t] := ORD (s[t]  = s[t+1]);
         | 9: DEC (t); s[t] := ORD (s[t]  # s[t+1]);
         |10: DEC (t); s[t] := ORD (s[t] <  s[t+1]);
         |11: DEC (t); s[t] := ORD (s[t] >= s[t+1]);
         |12: DEC (t); s[t] := ORD (s[t] >  s[t+1]);
         |13: DEC (t); s[t] := ORD (s[t] <= s[t+1]);
         |14: INC (t); Write (win, ">");
              Invert  (win, TRUE);
              ReadInt (win, s[t]);
              IF ~ Done THEN p := 0 END;
              Invert  (win, FALSE);
         |15: WriteCard (win, s[t], 7); WriteLn (win); DEC (t);
         END;
     |2: INC (t); s[t] := s[base(l)+INTEGER(a)];
     |3: s[base(l)+INTEGER(a)] := s[t]; DEC (t);
     |4: (* generate new block mark *)
         s[t+1] := base (l); s[t+2] := b; s[t+3] := p; b := t +1; p := a;
     |5: t := t + INTEGER (a);
     |6: p := a;
     |7: IF (s[t] = 0) THEN p := a END; DEC (t);
     END; END (*W*);
   UNTIL (p = 0);
   END Interpret;

PROCEDURE OpenUserWindow;
 BEGIN OpenTextWindow (win, {0, 6,7, 8}, 429,161, 204,155, WINTITLE);
   SetCaret (win, TRUE); END OpenUserWindow;

PROCEDURE EndInterpreter; BEGIN CloseTextWindow (win) END EndInterpreter;

END PL0Interpreter.
