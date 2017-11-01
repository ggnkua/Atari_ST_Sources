IMPLEMENTATION MODULE  GEMAESbase;

(*****************************************************************************)
(*                                                                           *)
(* Rekompiliertes LPR-MODULA-Originalmodul  hk, Feb-90                       *)
(*                                                                           *)
(*****************************************************************************)
(*                                                                           *)
(* Offsets der Variablen zur Modulbasis ( sedezimal ):                       *)
(*                                                                           *)
(*      AESParameters   -$34                                                 *)
(*      AESGlobal       -$52                                                 *)
(*      AESControl      -$5C                                                 *)
(*      AESIntIn        -$7E                                                 *)
(*      AESIntOut       -$8E                                                 *)
(*      AESAddrIn       -$9A                                                 *)
(*      AESAddrOut      -$A2                                                 *)
(*      AESCallResult   -$A4                                                 *)
(*                                                                           *)
(*****************************************************************************)

FROM  SYSTEM  IMPORT  (* PROC *)  SETREG, INLINE, ADR;

CONST  d0      = 0;
       d1      = 1;

       AESopcode = 200D;
       GEMtrap   = 4E42H;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE  GemCall ((* EIN/ -- *) Opcode,
                    (* EIN/ -- *) Cntrl1,
                    (* EIN/ -- *) Cntrl2,
                    (* EIN/ -- *) Cntrl3,
                    (* EIN/ -- *) Cntrl4 : INTEGER ): INTEGER;

  BEGIN
    WITH  AESControl  DO
      opcode      := Opcode;
      sizeIntIn   := Cntrl1;
      sizeIntOut  := Cntrl2;
      sizeAddrIn  := Cntrl3;
      sizeAddrOut := Cntrl4;
    END; (* WITH *)

    SETREG( d0, AESopcode );
    SETREG( d1, ADR( AESParameters ));
    INLINE( GEMtrap );

    AESCallResult := AESIntOut[ 0 ];

    RETURN( AESCallResult );

  END  GemCall;

(*---------------------------------------------------------------------------*)

PROCEDURE  IntIn2 ((* EIN/ -- *) I1,
                   (* EIN/ -- *) I2 : INTEGER );

  BEGIN
    AESIntIn[ 0 ] := I1;
    AESIntIn[ 1 ] := I2;
  END  IntIn2;

(*---------------------------------------------------------------------------*)

PROCEDURE  IntIn3 ((* EIN/ -- *) I1,
                   (* EIN/ -- *) I2,
                   (* EIN/ -- *) I3 : INTEGER );

  BEGIN
    AESIntIn[ 0 ] := I1;
    AESIntIn[ 1 ] := I2;
    AESIntIn[ 2 ] := I3;
  END  IntIn3;

(*---------------------------------------------------------------------------*)

PROCEDURE  IntIn4 ((* EIN/ -- *) I1,
                   (* EIN/ -- *) I2,
                   (* EIN/ -- *) I3,
                   (* EIN/ -- *) I4 : INTEGER );

  BEGIN
    AESIntIn[ 0 ] := I1;
    AESIntIn[ 1 ] := I2;
    AESIntIn[ 2 ] := I3;
    AESIntIn[ 3 ] := I4;
  END  IntIn4;

(*---------------------------------------------------------------------------*)

PROCEDURE  IntIn8 ((* EIN/ -- *) I1,
                   (* EIN/ -- *) I2,
                   (* EIN/ -- *) I3,
                   (* EIN/ -- *) I4,
                   (* EIN/ -- *) I5,
                   (* EIN/ -- *) I6,
                   (* EIN/ -- *) I7,
                   (* EIN/ -- *) I8 : INTEGER );

  BEGIN
    AESIntIn[ 0 ] := I1;
    AESIntIn[ 1 ] := I2;
    AESIntIn[ 2 ] := I3;
    AESIntIn[ 3 ] := I4;
    AESIntIn[ 4 ] := I5;
    AESIntIn[ 5 ] := I6;
    AESIntIn[ 6 ] := I7;
    AESIntIn[ 7 ] := I8;
  END  IntIn8;

(*---------------------------------------------------------------------------*)

PROCEDURE  IntOut2 ((* -- /AUS *) VAR I1 : INTEGER;
                    (* -- /AUS *) VAR I2 : INTEGER );

  BEGIN
    I1 := AESIntOut[ 1 ];
    I2 := AESIntOut[ 2 ];
  END  IntOut2;

(*---------------------------------------------------------------------------*)

PROCEDURE  IntOut4 ((* -- /AUS *) VAR I1 : INTEGER;
                    (* -- /AUS *) VAR I2 : INTEGER;
                    (* -- /AUS *) VAR I3 : INTEGER;
                    (* -- /AUS *) VAR I4 : INTEGER );

  BEGIN
    I1 := AESIntOut[ 1 ];
    I2 := AESIntOut[ 2 ];
    I3 := AESIntOut[ 3 ];
    I4 := AESIntOut[ 4 ];
  END  IntOut4;

(*---------------------------------------------------------------------------*)

PROCEDURE  AESError;

  CONST Alert = 52;

  VAR   errstr  : ARRAY [0..49] OF CHAR;
        Result  : INTEGER;
        ASCIIop : INTEGER;

  BEGIN
    errstr  := '[1][Error in AES Function    ][ Ignore |  HALT  ]';

    ASCIIop := AESControl.opcode;

    errstr[ 25 ] := CHR(( ASCIIop DIV 100 ) + ORD('0'));

    ASCIIop := ASCIIop MOD 100;

    errstr[ 26 ] := CHR(( ASCIIop DIV 10 ) + ORD('0'));
    errstr[ 27 ] := CHR(( ASCIIop MOD 10 ) + ORD('0'));
    errstr[ 49 ] := 0C;

    AESIntIn [ 0 ] := 1;
    AESAddrIn[ 0 ] := ADR( errstr );

    ASCIIop := AESCallResult;

    Result := GemCall( Alert, 1, 1, 1, 0 );

    IF  Result = 2  THEN
      HALT;
    END;

    AESCallResult := Result;

  END  AESError;

(*---------------------------------------------------------------------------*)


BEGIN (* GEMAESbase *)

  WITH  AESGlobal  DO
    apPTree := NIL;
    ap1Resv := 0;
    ap2Resv := 0;
    ap3Resv := 0;
    ap4Resv := 0;
  END;

  WITH  AESParameters  DO
    control := ADR( AESControl );
    global  := ADR( AESGlobal );
    intIn   := ADR( AESIntIn );
    intOut  := ADR( AESIntOut );
    addrIn  := ADR( AESAddrIn );
    addrOut := ADR( AESAddrOut );
  END;

END  GEMAESbase.
