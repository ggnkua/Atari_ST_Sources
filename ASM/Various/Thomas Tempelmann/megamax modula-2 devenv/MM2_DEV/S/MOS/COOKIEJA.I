IMPLEMENTATION MODULE CookieJar;
(*$Y+,N+,L-,H+*)

FROM SYSTEM IMPORT LONGWORD, ASSEMBLER, ADDRESS;

PROCEDURE cookiePtr (): ADDRESS;
  BEGIN
    ASSEMBLER
        CLR.L   -(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        MOVE.L  D0,2(A7)
        MOVE.L  $5A0,(A3)+      ; _p_cookies holen
        TRAP    #1
        ADDQ.L  #6,A7
    END
  END cookiePtr;
  
PROCEDURE findCookie (cookie: LONGWORD);
  (* RÅckgabe des Ptrs auf den Cookie+4 in A0,wenn D0 # 0 *)
  BEGIN
    ASSEMBLER
        JSR     cookiePtr
        MOVE.L  -(A3),A0
        MOVE.L  -(A3),D1        ; cookie
        MOVE.L  A0,D0
        BNE     start
        RTS
      next
        CMP.L   D0,D1
        BEQ     ende
        ADDQ.L  #4,A0
      start
        MOVE.L  (A0)+,D0
        BNE     next
      ende
    END
  END findCookie;

PROCEDURE GetCookie (cookie: LONGWORD; VAR value: LONGWORD): BOOLEAN;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)     ; ADR (value)
        JSR     findCookie
        MOVE.L  (A7)+,A1
        TST.L   D0
        BEQ     false
        MOVE.L  (A0),(A1)
        MOVE    #1,(A3)+
        RTS
      false
        CLR.L   (A1)
        CLR.W   (A3)+
    END
  END GetCookie;

PROCEDURE ModifyCookie (cookie: LONGWORD; newvalue: LONGWORD): BOOLEAN;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)     ; newvalue
        JSR     findCookie
        MOVE.L  (A7)+,D1
        TST.L   D0
        BEQ     false
        MOVE.L  D1,(A0)
        MOVE    #1,(A3)+
        RTS
      false
        CLR.W   (A3)+
    END
  END ModifyCookie;


PROCEDURE QueryCookies (with: CookieProc);
  BEGIN
    ASSEMBLER
        JSR     cookiePtr
        MOVE.L  -(A3),A0
        MOVE.L  -(A3),-(A7)     ; with.link
        MOVE.L  -(A3),-(A7)     ; with.adr
        MOVE.L  A0,D0
        BEQ     ende
      next
        MOVE.L  (A0)+,D0
        BEQ     ende
        MOVE.L  D0,(A3)+        ; cookie
        MOVE.L  A0,(A3)+        ; ADR (value)
        MOVE.L  (A7),A1
        MOVE.L  4(A7),D2
        MOVE.L  A0,-(A7)
        JSR     (A1)
        MOVE.L  (A7)+,A0
        ADDQ.L  #4,A0
        TST.W   -(A3)
        BNE     next
      ende
        ADDQ.L  #8,A7
    END
  END QueryCookies;

END CookieJar.
