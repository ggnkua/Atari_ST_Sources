MODULE Inline; (* SJ *)

(* History :
   7.3.93 : first version
*)

IMPORT S:=SYSTEM, System, FB:=FileBuffer, FN:=Filename, NStr:=NumStr,
       Str:=Strings, Form;

CONST start = "  INLINE(";
      end   = ");  ";

VAR p : Str.ptr;
    r,w : FB.file;
    i,Word : INTEGER;
    s : ARRAY 10 OF CHAR;

BEGIN
  p := S.ADR(end); p[2] := 0DX; p[3] := 0AX;
  IF System.Basepage.Command[0] # 0X THEN
    p := S.ADR(System.Basepage.Command[1]);
    IF FB.Load(p^,r) THEN
      FN.SetExt("INL",p^);
      IF FB.Open(p^,10000H,w) THEN
        FB.ReadWord(r,Word);
        WHILE r.Ok AND w.Ok DO
          FB.WriteChars(w,start); i := 0;
          REPEAT
            NStr.LIntTo(S.LONG(Word),16,s);
            Str.Adjust(Str.RIGHT,5,"0",s);
            FB.WriteChars(w,s); FB.WriteChars(w,"H,");
            FB.ReadWord(r,Word);
            INC(i);
          UNTIL (i = 8) OR NOT r.Ok;
          FB.Seek(w,FB.relative,-1);
          FB.WriteChars(w,end);
        END;
        FB.Close(w);
        IF NOT w.Ok THEN i := Form.Alert(1,"[1][Error while writing][Cancel]") END;
      END;
    END;
  END;
END Inline.