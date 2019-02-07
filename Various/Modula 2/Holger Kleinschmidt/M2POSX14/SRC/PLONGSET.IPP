IMPLEMENTATION MODULE pLONGSET;
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
(* 18-M„r-94, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT

FROM PORTAB IMPORT
(* TYPE *) UNSIGNEDWORD, UNSIGNEDLONG, WORDSET;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

#if long_set
TYPE
  LongSetRange = [0..31];
  LongSet      = PACKEDSET OF LongSetRange;
#endif

TYPE
  SetCast = RECORD
    CASE TAG_COLON UNSIGNEDWORD OF
      0: wordset : ARRAY [0..1] OF WORDSET;
#if long_set
     |1: longset : LongSet;
#endif
    ELSE ulong   : UNSIGNEDLONG;
    END;
  END;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE MASKlong ((* EIN/ -- *)     nElems : UNSIGNEDWORD;
                    (* EIN/AUS *) VAR set    : UNSIGNEDLONG );
(*T*)
VAR cast : SetCast;

PROCEDURE mask ((* EIN/ -- *) elem : UNSIGNEDWORD ): WORDSET;
BEGIN
 CASE elem MOD 16 OF
    0: RETURN(WORDSET{0});
  | 1: RETURN(WORDSET{0..1});
  | 2: RETURN(WORDSET{0..2});
  | 3: RETURN(WORDSET{0..3});
  | 4: RETURN(WORDSET{0..4});
  | 5: RETURN(WORDSET{0..5});
  | 6: RETURN(WORDSET{0..6});
  | 7: RETURN(WORDSET{0..7});
  | 8: RETURN(WORDSET{0..8});
  | 9: RETURN(WORDSET{0..9});
  |10: RETURN(WORDSET{0..10});
  |11: RETURN(WORDSET{0..11});
  |12: RETURN(WORDSET{0..12});
  |13: RETURN(WORDSET{0..13});
  |14: RETURN(WORDSET{0..14});
  |15: RETURN(WORDSET{0..15});
 END;
END mask;

BEGIN
 IF nElems = 0 THEN
   set := 0;
 ELSE
   DEC(nElems);
   cast.ulong := set;
   IF nElems >= 16 THEN
     cast.wordset[0] := cast.wordset[0] * mask(nElems);
   ELSE
     cast.wordset[0] := WORDSET{};
     cast.wordset[1] := cast.wordset[1] * mask(nElems);
   END;
   set := cast.ulong;
 END;
END MASKlong;

(*---------------------------------------------------------------------------*)

PROCEDURE UNIONlong ((* EIN/ -- *) set1 : UNSIGNEDLONG;
                     (* EIN/ -- *) set2 : UNSIGNEDLONG ): UNSIGNEDLONG;
(*T*)
#if !long_set
VAR cast1 : SetCast;
    cast2 : SetCast;
#endif
BEGIN
#if long_set
 RETURN(CAST(UNSIGNEDLONG,CAST(LongSet,set1) + CAST(LongSet,set2)));
#else
 cast1.ulong := set1;
 cast2.ulong := set2;
 cast1.wordset[0] := cast1.wordset[0] + cast2.wordset[0];
 cast1.wordset[1] := cast1.wordset[1] + cast2.wordset[1];
 RETURN(cast1.ulong);
#endif
END UNIONlong;

(*---------------------------------------------------------------------------*)

PROCEDURE INTERSECTlong ((* EIN/ -- *) set1 : UNSIGNEDLONG;
                         (* EIN/ -- *) set2 : UNSIGNEDLONG ): UNSIGNEDLONG;
(*T*)
#if !long_set
VAR cast1 : SetCast;
    cast2 : SetCast;
#endif
BEGIN
#if long_set
 RETURN(CAST(UNSIGNEDLONG,CAST(LongSet,set1) * CAST(LongSet,set2)));
#else
 cast1.ulong := set1;
 cast2.ulong := set2;
 cast1.wordset[0] := cast1.wordset[0] * cast2.wordset[0];
 cast1.wordset[1] := cast1.wordset[1] * cast2.wordset[1];
 RETURN(cast1.ulong);
#endif
END INTERSECTlong;

(*---------------------------------------------------------------------------*)

PROCEDURE DIFFlong ((* EIN/ -- *) set1 : UNSIGNEDLONG;
                    (* EIN/ -- *) set2 : UNSIGNEDLONG ): UNSIGNEDLONG;
(*T*)
#if !long_set
VAR cast1 : SetCast;
    cast2 : SetCast;
#endif
BEGIN
#if long_set
 RETURN(CAST(UNSIGNEDLONG,CAST(LongSet,set1) - CAST(LongSet,set2)));
#else
 cast1.ulong := set1;
 cast2.ulong := set2;
 cast1.wordset[0] := cast1.wordset[0] - cast2.wordset[0];
 cast1.wordset[1] := cast1.wordset[1] - cast2.wordset[1];
 RETURN(cast1.ulong);
#endif
END DIFFlong;

(*---------------------------------------------------------------------------*)

PROCEDURE SYMDIFFlong ((* EIN/ -- *) set1 : UNSIGNEDLONG;
                       (* EIN/ -- *) set2 : UNSIGNEDLONG ): UNSIGNEDLONG;
(*T*)
#if !long_set
VAR cast1 : SetCast;
    cast2 : SetCast;
#endif
BEGIN
#if long_set
 RETURN(CAST(UNSIGNEDLONG,CAST(LongSet,set1) / CAST(LongSet,set2)));
#else
 cast1.ulong := set1;
 cast2.ulong := set2;
 cast1.wordset[0] := cast1.wordset[0] / cast2.wordset[0];
 cast1.wordset[1] := cast1.wordset[1] / cast2.wordset[1];
 RETURN(cast1.ulong);
#endif
END SYMDIFFlong;

(*---------------------------------------------------------------------------*)

PROCEDURE INCLlong ((* EIN/AUS *) VAR set  : UNSIGNEDLONG;
                    (* EIN/ -- *)     elem : UNSIGNEDWORD );
(*T*)
VAR cast : SetCast;

BEGIN
 cast.ulong := set;
#if long_set
 INCL(cast.longset, elem);
#else
 IF elem >= 16 THEN
   INCL(cast.wordset[0], elem - 16);
 ELSE
   INCL(cast.wordset[1], elem);
 END;
#endif
 set := cast.ulong;
END INCLlong;

(*---------------------------------------------------------------------------*)

PROCEDURE EXCLlong ((* EIN/AUS *) VAR set  : UNSIGNEDLONG;
                    (* EIN/ -- *)     elem : UNSIGNEDWORD );
(*T*)
VAR cast : SetCast;

BEGIN
 cast.ulong := set;
#if long_set
 EXCL(cast.longset, elem);
#else
 IF elem >= 16 THEN
   EXCL(cast.wordset[0], elem - 16);
 ELSE
   EXCL(cast.wordset[1], elem);
 END;
#endif
 set := cast.ulong;
END EXCLlong;

(*---------------------------------------------------------------------------*)

PROCEDURE INlong ((* EIN/ -- *) elem : UNSIGNEDWORD;
                  (* EIN/ -- *) set  : UNSIGNEDLONG ): BOOLEAN;
(*T*)
#if !long_set
VAR cast : SetCast;
#endif
BEGIN
#if long_set
 RETURN(elem IN CAST(LongSet,set));
#else
 cast.ulong := set;
 IF elem >= 16 THEN
   RETURN((elem - 16) IN cast.wordset[0]);
 ELSE
   RETURN(elem IN cast.wordset[1]);
 END;
#endif
END INlong;

(*---------------------------------------------------------------------------*)

PROCEDURE SUBSETlong ((* EIN/ -- *) sub : UNSIGNEDLONG;
                      (* EIN/ -- *) set : UNSIGNEDLONG ): BOOLEAN;
(*T*)
#if !long_set
VAR cast1 : SetCast;
    cast2 : SetCast;
#endif
BEGIN
#if long_set
 RETURN(CAST(LongSet,sub) <= CAST(LongSet,set));
#else
 cast1.ulong := sub;
 cast2.ulong := set;
 RETURN(    (cast1.wordset[0] <= cast2.wordset[0])
        AND (cast1.wordset[1] <= cast2.wordset[1]));
#endif
END SUBSETlong;

END pLONGSET.
