IMPLEMENTATION MODULE BigSets;
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
(* Jun-90 / 17-Dez-94, Holger Kleinschmidt                                   *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT

FROM PORTAB IMPORT
(* TYPE *) UNSIGNEDWORD, WORDSET, WORDSETRANGE;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  WORDSETSIZE = 16;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE toMask ((* EIN/ -- *) elem : CARDINAL ): WORDSET;
BEGIN
 CASE elem MOD WORDSETSIZE OF
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
END toMask;

(*---------------------------------------------------------------------------*)

PROCEDURE fromMask ((* EIN/ -- *) elem : CARDINAL ): WORDSET;
BEGIN
 CASE elem MOD WORDSETSIZE OF
    0: RETURN(WORDSET{0..15});
  | 1: RETURN(WORDSET{1..15});
  | 2: RETURN(WORDSET{2..15});
  | 3: RETURN(WORDSET{3..15});
  | 4: RETURN(WORDSET{4..15});
  | 5: RETURN(WORDSET{5..15});
  | 6: RETURN(WORDSET{6..15});
  | 7: RETURN(WORDSET{7..15});
  | 8: RETURN(WORDSET{8..15});
  | 9: RETURN(WORDSET{9..15});
  |10: RETURN(WORDSET{10..15});
  |11: RETURN(WORDSET{11..15});
  |12: RETURN(WORDSET{12..15});
  |13: RETURN(WORDSET{13..15});
  |14: RETURN(WORDSET{14..15});
  |15: RETURN(WORDSET{15});
 END;
END fromMask;

(*---------------------------------------------------------------------------*)

PROCEDURE Assign ((* EIN/ -- *) VAR src : ARRAY OF WORDSET;
                  (* -- /AUS *) VAR dst : ARRAY OF WORDSET );

VAR __REG__ idx : UNSIGNEDWORD;
    __REG__ max : UNSIGNEDWORD;

BEGIN
 IF HIGH(dst) > HIGH(src) THEN
   max := VAL(UNSIGNEDWORD,HIGH(src));
 ELSE
   max := VAL(UNSIGNEDWORD,HIGH(dst));
 END;
 FOR idx := 0 TO max DO
   dst[idx] := src[idx];
 END;
 IF HIGH(dst) > HIGH(src) THEN
   FOR idx := max + 1 TO VAL(UNSIGNEDWORD,HIGH(dst)) DO
     dst[idx] := WORDSET{};
   END;
 END;
END Assign;

(*---------------------------------------------------------------------------*)

PROCEDURE Mask ((* EIN/ -- *)     nElems : CARDINAL;
                (* EIN/AUS *) VAR set    : ARRAY OF WORDSET );

VAR __REG__ mask : WORDSET;
    __REG__ idx  : UNSIGNEDWORD;
    __REG__ last : UNSIGNEDWORD;

BEGIN
 IF nElems = 0 THEN
   last := 0;
   mask := WORDSET{};
 ELSE
   DEC(nElems);
   last := VAL(UNSIGNEDWORD,nElems DIV WORDSETSIZE);
   mask := toMask(nElems);
 END;
 FOR idx := last + 1 TO VAL(UNSIGNEDWORD,HIGH(set)) DO
   set[idx] := WORDSET{};
 END;
 IF last <= VAL(UNSIGNEDWORD,HIGH(set)) THEN
   set[last] := set[last] * mask;
 END;
END Mask;

(*---------------------------------------------------------------------------*)

PROCEDURE Clear ((* -- /AUS *) VAR set : ARRAY OF WORDSET );

VAR __REG__ idx : UNSIGNEDWORD;

BEGIN
 FOR idx := 0 TO VAL(UNSIGNEDWORD,HIGH(set)) DO
   set[idx] := WORDSET{};
 END
END Clear;

(*---------------------------------------------------------------------------*)

PROCEDURE Fill ((* -- /AUS *) VAR set : ARRAY OF WORDSET );

VAR __REG__ idx : UNSIGNEDWORD;

BEGIN
 FOR idx := 0 TO VAL(UNSIGNEDWORD,HIGH(set)) DO
   set[idx] := WORDSET{0..15};
 END
END Fill;

(*---------------------------------------------------------------------------*)

PROCEDURE IsEmpty ((* EIN/ -- *) VAR set : ARRAY OF WORDSET ): BOOLEAN;

VAR __REG__ idx : UNSIGNEDWORD;
    __REG__ tmp : WORDSET;

BEGIN
 idx := 0;
 tmp := set[VAL(UNSIGNEDWORD,HIGH(set))];
 set[VAL(UNSIGNEDWORD,HIGH(set))] := WORDSET{0..15};
 WHILE set[idx] = WORDSET{} DO
   INC(idx);
 END;
 set[VAL(UNSIGNEDWORD,HIGH(set))] := tmp;

 IF idx = VAL(UNSIGNEDWORD,HIGH(set)) THEN
   RETURN(tmp = WORDSET{});
 ELSE
   RETURN(FALSE);
 END;
END IsEmpty;

(*---------------------------------------------------------------------------*)

PROCEDURE IsFull ((* EIN/ -- *) VAR set : ARRAY OF WORDSET ): BOOLEAN;

VAR __REG__ idx : UNSIGNEDWORD;
    __REG__ tmp : WORDSET;

BEGIN
 idx := 0;
 tmp := set[VAL(UNSIGNEDWORD,HIGH(set))];
 set[VAL(UNSIGNEDWORD,HIGH(set))] := WORDSET{};
 WHILE set[idx] = WORDSET{0..15} DO
   INC(idx);
 END;
 set[VAL(UNSIGNEDWORD,HIGH(set))] := tmp;

 IF idx = VAL(UNSIGNEDWORD,HIGH(set)) THEN
   RETURN(tmp = WORDSET{0..15});
 ELSE
   RETURN(FALSE);
 END;
END IsFull;

(*---------------------------------------------------------------------------*)

PROCEDURE Complement ((* EIN/ -- *) VAR set  : ARRAY OF WORDSET;
                      (* -- /AUS *) VAR cset : ARRAY OF WORDSET );

VAR __REG__ idx : UNSIGNEDWORD;
    __REG__ max : UNSIGNEDWORD;

BEGIN
 IF HIGH(cset) > HIGH(set) THEN
   max := VAL(UNSIGNEDWORD,HIGH(set));
 ELSE
   max := VAL(UNSIGNEDWORD,HIGH(cset));
 END;
 FOR idx := 0 TO max DO
   cset[idx] := set[idx] / WORDSET{0..15};
 END;
 IF HIGH(cset) > HIGH(set) THEN
   FOR idx := max + 1 TO VAL(UNSIGNEDWORD,HIGH(cset)) DO
     cset[idx] := WORDSET{0..15};
   END;
 END;
END Complement;

(*---------------------------------------------------------------------------*)

PROCEDURE Card ((* EIN/ -- *) VAR set : ARRAY OF WORDSET ): CARDINAL;

(* Der Algorithmus zum bestimmen der Kardinalitaet ist aus:

   The ModulaTor Volume 2, Number 9
 *)

VAR __REG__ elems : CARDINAL;
    __REG__ word  : UNSIGNEDWORD;
    __REG__ idx   : UNSIGNEDWORD;

BEGIN
 elems := 0;
 FOR idx := 0 TO VAL(UNSIGNEDWORD,HIGH(set)) DO
   word := CAST(UNSIGNEDWORD,set[idx]);
   WHILE word # 0 DO
     INC(elems);
     word := CAST(UNSIGNEDWORD,   CAST(WORDSET,word)
                                * CAST(WORDSET,VAL(UNSIGNEDWORD,word - 1)));
   END;
 END;
 RETURN(elems);
END Card;

(*---------------------------------------------------------------------------*)

PROCEDURE IsElement ((* EIN/ -- *)     elem : CARDINAL;
                     (* EIN/ -- *) VAR set  : ARRAY OF WORDSET ): BOOLEAN;

VAR __REG__ idx : UNSIGNEDWORD;

BEGIN
 idx := VAL(UNSIGNEDWORD,elem DIV WORDSETSIZE);
 RETURN(    (idx <= VAL(UNSIGNEDWORD,HIGH(set)))
        & (VAL(WORDSETRANGE,elem MOD WORDSETSIZE) IN set[idx]));
END IsElement;

(*---------------------------------------------------------------------------*)

PROCEDURE Include ((* EIN/ -- *)     elem : CARDINAL;
                   (* EIN/AUS *) VAR set  : ARRAY OF WORDSET );

VAR __REG__ idx : UNSIGNEDWORD;

BEGIN
 idx := VAL(UNSIGNEDWORD,elem DIV WORDSETSIZE);
 IF idx <= VAL(UNSIGNEDWORD,HIGH(set)) THEN
   INCL(set[idx], VAL(WORDSETRANGE,elem MOD WORDSETSIZE));
 END;
END Include;

(*---------------------------------------------------------------------------*)

PROCEDURE Exclude ((* EIN/ -- *)     elem : CARDINAL;
                   (* EIN/AUS *) VAR set  : ARRAY OF WORDSET );

VAR __REG__ idx : UNSIGNEDWORD;

BEGIN
 idx := VAL(UNSIGNEDWORD,elem DIV WORDSETSIZE);
 IF idx <= VAL(UNSIGNEDWORD,HIGH(set)) THEN
   EXCL(set[idx], VAL(WORDSETRANGE,elem MOD WORDSETSIZE));
 END;
END Exclude;

(*---------------------------------------------------------------------------*)

PROCEDURE IncludeRange ((* EIN/ -- *)     from : CARDINAL;
                        (* EIN/ -- *)     to   : CARDINAL;
                        (* EIN/AUS *) VAR set  : ARRAY OF WORDSET );

VAR __REG__ fIdx  : UNSIGNEDWORD;
    __REG__ tIdx  : UNSIGNEDWORD;
    __REG__ fMask : WORDSET;
    __REG__ tMask : WORDSET;

BEGIN
 IF to >= VAL(CARDINAL,HIGH(set) + 1) * WORDSETSIZE THEN
   to := VAL(CARDINAL,HIGH(set) + 1) * WORDSETSIZE - 1;
 END;
 IF from <= to THEN
   fIdx  := VAL(UNSIGNEDWORD,from DIV WORDSETSIZE);
   tIdx  := VAL(UNSIGNEDWORD,to   DIV WORDSETSIZE);
   fMask := fromMask(from);
   tMask := toMask(to);

   IF fIdx = tIdx THEN
     set[fIdx] := set[fIdx] + (fMask * tMask);
   ELSE
     set[fIdx] := set[fIdx] + fMask;
     set[tIdx] := set[tIdx] + tMask;
     FOR fIdx := fIdx + 1 TO tIdx - 1 DO
       set[fIdx] := WORDSET{0..15};
     END;
   END;
 END;
END IncludeRange;

(*---------------------------------------------------------------------------*)

PROCEDURE ExcludeRange ((* EIN/ -- *)     from : CARDINAL;
                        (* EIN/ -- *)     to   : CARDINAL;
                        (* EIN/AUS *) VAR set  : ARRAY OF WORDSET );

VAR __REG__ fIdx  : UNSIGNEDWORD;
    __REG__ tIdx  : UNSIGNEDWORD;
    __REG__ fMask : WORDSET;
    __REG__ tMask : WORDSET;

BEGIN
 IF to >= VAL(CARDINAL,HIGH(set) + 1) * WORDSETSIZE THEN
   to := VAL(CARDINAL,HIGH(set) + 1) * WORDSETSIZE - 1;
 END;
 IF from <= to THEN
   fIdx  := VAL(UNSIGNEDWORD,from DIV WORDSETSIZE);
   tIdx  := VAL(UNSIGNEDWORD,to   DIV WORDSETSIZE);
   fMask := fromMask(from) / WORDSET{0..15}; (* alle Bits invertieren *)
   tMask := toMask(to) / WORDSET{0..15};

   IF fIdx = tIdx THEN
     set[fIdx] := set[fIdx] * (fMask + tMask);
   ELSE
     set[fIdx] := set[fIdx] * fMask;
     set[tIdx] := set[tIdx] * tMask;
     FOR fIdx := fIdx + 1 TO tIdx - 1 DO
       set[fIdx] := WORDSET{};
     END;
   END;
 END;
END ExcludeRange;

(*---------------------------------------------------------------------------*)

PROCEDURE Union ((* EIN/ -- *) VAR set1 : ARRAY OF WORDSET;
                 (* EIN/ -- *) VAR set2 : ARRAY OF WORDSET;
                 (* -- /AUS *) VAR uset : ARRAY OF WORDSET );

VAR __REG__ idx  : UNSIGNEDWORD;
    __REG__ max  : UNSIGNEDWORD;
    __REG__ max2 : UNSIGNEDWORD;

BEGIN
 IF HIGH(set1) > HIGH(set2) THEN
   max := VAL(UNSIGNEDWORD,HIGH(set2));
 ELSE
   max := VAL(UNSIGNEDWORD,HIGH(set1));
 END;
 IF VAL(UNSIGNEDWORD,HIGH(uset)) < max THEN
   max := VAL(UNSIGNEDWORD,HIGH(uset));
 END;

 FOR idx := 0 TO max DO
   uset[idx] := set1[idx] + set2[idx];
 END;

 IF max < VAL(UNSIGNEDWORD,HIGH(uset)) THEN
   IF max < VAL(UNSIGNEDWORD,HIGH(set1)) THEN
     IF HIGH(set1) < HIGH(uset) THEN
       max2 := VAL(UNSIGNEDWORD,HIGH(set1));
     ELSE
       max2 := VAL(UNSIGNEDWORD,HIGH(uset));
     END;
     FOR idx := max + 1 TO max2 DO
       uset[idx] := set1[idx];
     END;
   ELSIF max < VAL(UNSIGNEDWORD,HIGH(set2)) THEN
     IF HIGH(set2) < HIGH(uset) THEN
       max2 := VAL(UNSIGNEDWORD,HIGH(set2));
     ELSE
       max2 := VAL(UNSIGNEDWORD,HIGH(uset));
     END;
     FOR idx := max + 1 TO max2 DO
       uset[idx] := set2[idx];
     END;
   END;
   FOR idx := max2 + 1 TO VAL(UNSIGNEDWORD,HIGH(uset)) DO
     uset[idx] := WORDSET{};
   END;
 END;
END Union;

(*---------------------------------------------------------------------------*)

PROCEDURE Intersection ((* EIN/ -- *) VAR set1 : ARRAY OF WORDSET;
                        (* EIN/ -- *) VAR set2 : ARRAY OF WORDSET;
                        (* -- /AUS *) VAR iset : ARRAY OF WORDSET );

VAR __REG__ idx  : UNSIGNEDWORD;
    __REG__ max  : UNSIGNEDWORD;
    __REG__ max2 : UNSIGNEDWORD;

BEGIN
 IF HIGH(set1) > HIGH(set2) THEN
   max := VAL(UNSIGNEDWORD,HIGH(set2));
 ELSE
   max := VAL(UNSIGNEDWORD,HIGH(set1));
 END;
 IF VAL(UNSIGNEDWORD,HIGH(iset)) < max THEN
   max := VAL(UNSIGNEDWORD,HIGH(iset));
 END;

 FOR idx := 0 TO max DO
   iset[idx] := set1[idx] * set2[idx];
 END;

 FOR idx := max + 1 TO VAL(UNSIGNEDWORD,HIGH(iset)) DO
   iset[idx] := WORDSET{};
 END;
END Intersection;

(*---------------------------------------------------------------------------*)

PROCEDURE Difference ((* EIN/ -- *) VAR set1 : ARRAY OF WORDSET;
                      (* EIN/ -- *) VAR set2 : ARRAY OF WORDSET;
                      (* -- /AUS *) VAR dset : ARRAY OF WORDSET );

VAR __REG__ idx  : UNSIGNEDWORD;
    __REG__ max  : UNSIGNEDWORD;
    __REG__ max2 : UNSIGNEDWORD;

BEGIN
 IF HIGH(set1) > HIGH(set2) THEN
   max := VAL(UNSIGNEDWORD,HIGH(set2));
 ELSE
   max := VAL(UNSIGNEDWORD,HIGH(set1));
 END;
 IF VAL(UNSIGNEDWORD,HIGH(dset)) < max THEN
   max := VAL(UNSIGNEDWORD,HIGH(dset));
 END;

 FOR idx := 0 TO max DO
   dset[idx] := set1[idx] - set2[idx];
 END;

 IF max < VAL(UNSIGNEDWORD,HIGH(dset)) THEN
   IF max < VAL(UNSIGNEDWORD,HIGH(set1)) THEN
     IF HIGH(set1) < HIGH(dset) THEN
       max2 := VAL(UNSIGNEDWORD,HIGH(set1));
     ELSE
       max2 := VAL(UNSIGNEDWORD,HIGH(dset));
     END;
     FOR idx := max + 1 TO max2 DO
       dset[idx] := set1[idx];
     END;
   ELSE
     max2 := max;
   END;
   FOR idx := max2 + 1 TO VAL(UNSIGNEDWORD,HIGH(dset)) DO
     dset[idx] := WORDSET{};
   END;
 END;
END Difference;

(*---------------------------------------------------------------------------*)

PROCEDURE SymmetricDiff ((* EIN/ -- *) VAR set1  : ARRAY OF WORDSET;
                         (* EIN/ -- *) VAR set2  : ARRAY OF WORDSET;
                         (* -- /AUS *) VAR sdset : ARRAY OF WORDSET );

VAR __REG__ idx  : UNSIGNEDWORD;
    __REG__ max  : UNSIGNEDWORD;
    __REG__ max2 : UNSIGNEDWORD;

BEGIN
 IF HIGH(set1) > HIGH(set2) THEN
   max := VAL(UNSIGNEDWORD,HIGH(set2));
 ELSE
   max := VAL(UNSIGNEDWORD,HIGH(set1));
 END;
 IF VAL(UNSIGNEDWORD,HIGH(sdset)) < max THEN
   max := VAL(UNSIGNEDWORD,HIGH(sdset));
 END;

 FOR idx := 0 TO max DO
   sdset[idx] := set1[idx] / set2[idx];
 END;

 IF max < VAL(UNSIGNEDWORD,HIGH(sdset)) THEN
   IF max < VAL(UNSIGNEDWORD,HIGH(set1)) THEN
     IF HIGH(set1) < HIGH(sdset) THEN
       max2 := VAL(UNSIGNEDWORD,HIGH(set1));
     ELSE
       max2 := VAL(UNSIGNEDWORD,HIGH(sdset));
     END;
     FOR idx := max + 1 TO max2 DO
       sdset[idx] := set1[idx];
     END;
   ELSIF max < VAL(UNSIGNEDWORD,HIGH(set2)) THEN
     IF HIGH(set2) < HIGH(sdset) THEN
       max2 := VAL(UNSIGNEDWORD,HIGH(set2));
     ELSE
       max2 := VAL(UNSIGNEDWORD,HIGH(sdset));
     END;
     FOR idx := max + 1 TO max2 DO
       sdset[idx] := set2[idx];
     END;
   END;
   FOR idx := max2 + 1 TO VAL(UNSIGNEDWORD,HIGH(sdset)) DO
     sdset[idx] := WORDSET{};
   END;
 END;
END SymmetricDiff;

(*---------------------------------------------------------------------------*)

PROCEDURE Equal ((* EIN/ -- *) VAR set1 : ARRAY OF WORDSET;
                 (* EIN/ -- *) VAR set2 : ARRAY OF WORDSET ): BOOLEAN;

VAR __REG__ idx : UNSIGNEDWORD;
    __REG__ max : UNSIGNEDWORD;

BEGIN
 IF HIGH(set1) > HIGH(set2) THEN
   max := VAL(UNSIGNEDWORD,HIGH(set2));
 ELSE
   max := VAL(UNSIGNEDWORD,HIGH(set1));
 END;

 idx := 0;
 WHILE (idx <= max) & (set1[idx] = set2[idx]) DO
   INC(idx);
 END;

 IF idx <= max THEN
   RETURN(FALSE);
 ELSIF HIGH(set1) > HIGH(set2) THEN
   FOR idx := max + 1 TO VAL(UNSIGNEDWORD,HIGH(set1)) DO
     IF set1[idx] # WORDSET{} THEN
       RETURN(FALSE);
     END;
   END;
   RETURN(TRUE);
 ELSE (* HIGH(set1) <= HIGH(set2) *)
   FOR idx := max + 1 TO VAL(UNSIGNEDWORD,HIGH(set2)) DO
     IF set2[idx] # WORDSET{} THEN
       RETURN(FALSE);
     END;
   END;
   RETURN(TRUE);
 END;
END Equal;

(*---------------------------------------------------------------------------*)

PROCEDURE IsSubset ((* EIN/ -- *) VAR set1 : ARRAY OF WORDSET;
                    (* EIN/ -- *) VAR set2 : ARRAY OF WORDSET ): BOOLEAN;

VAR __REG__ idx : UNSIGNEDWORD;
    __REG__ max : UNSIGNEDWORD;

BEGIN
 IF HIGH(set1) > HIGH(set2) THEN
   max := VAL(UNSIGNEDWORD,HIGH(set2));
 ELSE
   max := VAL(UNSIGNEDWORD,HIGH(set1));
 END;

 idx := 0;
 WHILE (idx <= max) & (set1[idx] <= set2[idx]) DO
   INC(idx);
 END;

 IF idx <= max THEN
   RETURN(FALSE);
 ELSIF HIGH(set1) > HIGH(set2) THEN
   FOR idx := max + 1 TO VAL(UNSIGNEDWORD,HIGH(set1)) DO
     IF set1[idx] # WORDSET{} THEN
       RETURN(FALSE);
     END;
   END;
   RETURN(TRUE);
 ELSE (* HIGH(set1) <= HIGH(set2) *)
   RETURN(TRUE);
 END;
END IsSubset;

(*---------------------------------------------------------------------------*)

PROCEDURE IsProperSubset
   ((* EIN/ -- *) VAR set1 : ARRAY OF WORDSET;
    (* EIN/ -- *) VAR set2 : ARRAY OF WORDSET ): BOOLEAN;

VAR __REG__ idx  : UNSIGNEDWORD;
    __REG__ max  : UNSIGNEDWORD;
    __REG__ diff : BOOLEAN;

BEGIN
 IF HIGH(set1) > HIGH(set2) THEN
   max := VAL(UNSIGNEDWORD,HIGH(set2));
 ELSE
   max := VAL(UNSIGNEDWORD,HIGH(set1));
 END;

 diff := FALSE;
 idx  := 0;
 WHILE (idx <= max) & (set1[idx] <= set2[idx]) DO
   (* <set1> und <set2> sind unterschiedlich, wenn mindestens eine
    * Teil-WORDSET unterschiedlich ist.
    *)
   diff := diff OR (set1[idx] # set2[idx]);
   INC(idx);
 END;

 IF idx <= max THEN
   RETURN(FALSE);
 ELSIF HIGH(set1) > HIGH(set2) THEN
   IF ~diff THEN
     RETURN(FALSE);
   END;
   FOR idx := max + 1 TO VAL(UNSIGNEDWORD,HIGH(set1)) DO
     IF set1[idx] # WORDSET{} THEN
       RETURN(FALSE);
     END;
   END;
   RETURN(TRUE);
 ELSE (* HIGH(set1) <= HIGH(set2) *)
   FOR idx := max + 1 TO VAL(UNSIGNEDWORD,HIGH(set2)) DO
     IF set2[idx] # WORDSET{} THEN
       RETURN(TRUE);
     END;
   END;
   RETURN(diff);
 END;
END IsProperSubset;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteSet ((* EIN/ -- *) VAR set   : ARRAY OF WORDSET;
                    (* EIN/ -- *)     write : WriteChar        );

CONST CR = 15C;
      LF = 12C;

VAR __REG__ idx  : UNSIGNEDWORD;
    __REG__ elem : WORDSETRANGE;

BEGIN
 FOR idx := 0 TO VAL(UNSIGNEDWORD,HIGH(set))  DO
   FOR elem := 0 TO WORDSETSIZE - 1 DO
     IF elem IN set[idx] THEN
       write('1');
     ELSE
       write('0');
     END;
   END;
   write('|');

   (* Pro Zeile vier WORDSETs ausgeben *)
   IF (idx + 1) MOD 4 = 0 THEN
     write(CR);
     write(LF);
   END;
 END;
END WriteSet;

END BigSets.

