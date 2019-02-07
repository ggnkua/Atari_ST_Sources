IMPLEMENTATION MODULE DosText;
__IMP_SWITCHES__
__DEBUG__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
(*****************************************************************************)
(* 06-Jan-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT
PTR_ARITH_IMPORT

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR;

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) UNSIGNEDWORD, SIGNEDLONG;

FROM OSCALLS IMPORT
(* PROC *) Fseek, Fopen, Fclose, Fread;

FROM blk IMPORT
(* PROC *) memmove, memchr;

FROM types IMPORT
(* CONST*) LF, CR,
(* TYPE *) sizeT, StrPtr;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE OpenTextFile ((* EIN/ -- *)     name : StrPtr;
                        (* -- /AUS *) VAR file : TextFile );

CONST READ = 0;

BEGIN
 WITH file DO
   open     := Fopen(name, READ, handle);
   readSize := 0;
   readPos  := 0;
 END;
END OpenTextFile;

(*---------------------------------------------------------------------------*)

PROCEDURE CloseTextFile ((* EIN/AUS *) VAR file : TextFile );

VAR void : INTEGER;

BEGIN
 WITH file DO
   IF open THEN
     open := ~Fclose(handle, void);
   END;
 END;
END CloseTextFile;

(*---------------------------------------------------------------------------*)

PROCEDURE RewindTextFile ((* EIN/AUS *) VAR file : TextFile );

VAR voidB : BOOLEAN;
    voidL : SIGNEDLONG;

BEGIN
 WITH file DO
   IF open THEN
     voidB    := Fseek(0, handle, 0, voidL);
     readSize := 0;
     readPos  := 0;
   END;
 END;
END RewindTextFile;

(*---------------------------------------------------------------------------*)

PROCEDURE NextLine ((* EIN/AUS *) VAR file : TextFile;
                    (* EIN/ -- *)     size : UNSIGNEDWORD;
                    (* EIN/ -- *)     line : StrPtr;
                    (* -- /AUS *) VAR len  : UNSIGNEDWORD ): BOOLEAN;

VAR         left : UNSIGNEDWORD;
            eof  : BOOLEAN;
            lres : SIGNEDLONG;
            lf   : ADDRESS;
    __REG__ from : UNSIGNEDWORD;
    __REG__ cnt  : UNSIGNEDWORD;
    __REG__ wPos : UNSIGNEDWORD;

BEGIN
 wPos := 0;
 len  := 0;
 WITH file DO
   LOOP
     from := readPos;
     left := readSize - from;
     eof  := left = 0;
     IF eof THEN
       lf := NULL;
     ELSE
       lf := memchr(ADR(buf[from]), ORD(LF), VAL(sizeT,left));
       IF lf = NULL THEN
         cnt := left;
         INC(readPos, cnt);
       ELSE
         cnt := VAL(UNSIGNEDWORD,DIFADR(lf, ADR(buf[from])));
         INC(readPos, cnt + 1); (* + LF *)
         IF (cnt > 0) & (buf[from+cnt-1] = CR) THEN
           DEC(cnt); (* - CR *)
         END;
       END;
       INC(len, cnt);
       IF size > 0 THEN
         IF wPos + cnt >= size THEN
           cnt := (size - 1) - wPos;
         END;
         IF cnt > 0 THEN
           memmove(ADR(line^[wPos]), ADR(buf[from]), VAL(sizeT,cnt));
           INC(wPos, cnt);
         END;
       END;
     END;

     IF lf # NULL THEN
       EXIT;
     ELSE
       (* Im restlichen Puffer kein LF *)
       readPos := 0;
       IF Fread(handle, TBUFSIZE, ADR(buf), lres) THEN
         readSize := VAL(UNSIGNEDWORD,lres);
       ELSE
         readSize := 0;
       END;
       IF readSize > 0 THEN
         eof := FALSE;
       ELSE
         (* Datei zuende oder Fehler *)
         EXIT;
       END;
     END;
   END;
 END;

 IF size > 0 THEN
   line^[wPos] := 0C;
 END;
 RETURN(~eof);
END NextLine;

END DosText.
