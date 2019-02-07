IMPLEMENTATION MODULE loc;
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
(****************************************************************************)
(* 27-Mai-94, Holger Kleinschmidt                                           *)
(****************************************************************************)

VAL_INTRINSIC


FROM SYSTEM IMPORT
(* PROC *) ADR;

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) UNSIGNEDWORD;

IMPORT e;

FROM types IMPORT
(* TYPE *) StrRange, StrPtr;

FROM cstr IMPORT
(* PROC *) strcmp, strcpy, AssignCToM2, AssignM2ToC, Token;

FROM pSTRING IMPORT
(* PROC *) APPEND, APPENDCHR;

FROM cmdline IMPORT
(* PROC *) getenv;

FROM DosSystem IMPORT
(* TYPE *) PrefLanguage,
(* PROC *) Language;

FROM LCTypes IMPORT
(* CONST*) MAXLCID, IDSEP,
(* TYPE *) LCIdent;

IMPORT LC, LCPOSIX, LCusa, LCgerman;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

VAR
  Cstr      : ARRAY [0..1] OF CHAR;
  posixstr  : LCIdent;
  germanstr : LCIdent;
  usastr    : LCIdent;
  delim     : ARRAY [0..1] OF CHAR;

  lconvrec : LConvRec;
  lcid     : LCIdent;
  lcallid  : ARRAY [0..6*MAXLCID+6] OF CHAR;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE SplitLcAllId ((* EIN/ -- *) all : StrPtr );

VAR         idx   : StrRange;
            l1    : StrRange;
            l2    : StrRange;
            tlen  : StrRange;
            token : StrPtr;
    __REG__ id    : StrRange;
    __REG__ last  : StrRange;

BEGIN
 idx := 0;
 l1  := 0;
 id  := 0;
 WHILE (id <= 5) AND Token(all, ADR(delim), idx, l1, l2, tlen, token) DO
   IF tlen = 0 THEN
     LC.Idents[id] := "";
   ELSE
     AssignCToM2(token, tlen, LC.Idents[id]);
   END;
   last := id;
   INC(id);
 END;
 WHILE id <= 5 DO
   LC.Idents[id] := LC.Idents[last];
   INC(id);
 END;
END SplitLcAllId;

(*---------------------------------------------------------------------------*)

PROCEDURE MakeLcAllId;

VAR __REG__ id : StrRange;

BEGIN
 lcallid := "";
 FOR id := 0 TO 4 DO
   APPEND(LC.Idents[id], lcallid);
   APPENDCHR(IDSEP, lcallid);
 END;
 APPEND(LC.Idents[5], lcallid);
END MakeLcAllId;

(*---------------------------------------------------------------------------*)

PROCEDURE setlocale ((* EIN/ -- *) category : LcType;
                     (* EIN/ -- *) locale   : StrPtr ): StrPtr;

VAR ident : LCIdent;

BEGIN
 IF locale = NULL THEN
   (* Nur Name des augenblicklichen Locales erfragen *)
   IF category <= LcMessages THEN
     lcid := LC.Idents[VAL(UNSIGNEDWORD,category)];
     RETURN(ADR(lcid));
   ELSE
     MakeLcAllId;
     RETURN(ADR(lcallid));
   END;
 END;

 IF locale^[0] = 0C THEN
   (* Locale soll dem Environment entnommen werden *)
   locale := getenv("LC_ALL");
   IF (locale = NULL) OR (locale^[0] = 0C) THEN
     (* LC_ALL undefiniert, fuer <category> zustaendige Environmentvariable
      * testen.
      *)
     CASE category OF
       LcCtype    : locale := getenv("LC_CTYPE");
      |LcCollate  : locale := getenv("LC_COLLATE");
      |LcTime     : locale := getenv("LC_TIME");
      |LcNumeric  : locale := getenv("LC_NUMERIC");
      |LcMonetary : locale := getenv("LC_MONETARY");
      |LcMessages : locale := getenv("LC_MESSAGES");
     ELSE           locale := NULL;
     END;
     IF (locale = NULL) OR (locale^[0] = 0C) THEN
       (* Weder LC_ALL noch die fuer <category> zustaendige Variable
        * definiert, als letzte Moeglichkeit LANG testen.
        *)
       locale := getenv("LANG");
       IF (locale = NULL) OR (locale^[0] = 0C) THEN
         (* Aus dem Environment laesst sich nichts ermitteln, also
          * Defaultwerte verwenden.
          *)
         CASE Language() OF
           lFRG : ident := LCgerman.Ident;
          |lUSA : ident := LCusa.Ident;
         ELSE     ident := LCPOSIX.Ident;
         END;
         locale := ADR(ident);
       END;
     END;
   END;
 END;

 IF    (strcmp(locale, ADR(Cstr)) = 0)
    OR (strcmp(locale, ADR(posixstr)) = 0)
 THEN
   CASE category OF
     LcCtype    : LC.Ctype    := LCPOSIX.Ctype;
    |LcCollate  :
    |LcTime     : LC.Time     := LCPOSIX.Time;
    |LcNumeric  : LC.Numeric  := LCPOSIX.Numeric;
    |LcMonetary : LC.Monetary := LCPOSIX.Monetary;
    |LcMessages : LC.Messages := LCPOSIX.Messages;
   ELSE (* LcAll *)
     LC.Ctype    := LCPOSIX.Ctype;
     LC.Time     := LCPOSIX.Time;
     LC.Numeric  := LCPOSIX.Numeric;
     LC.Monetary := LCPOSIX.Monetary;
     LC.Messages := LCPOSIX.Messages;
   END;
 ELSIF (strcmp(locale, ADR(germanstr)) = 0) THEN
   CASE category OF
     LcCtype    : LC.Ctype    := LCgerman.Ctype;
    |LcCollate  :
    |LcTime     : LC.Time     := LCgerman.Time;
    |LcNumeric  : LC.Numeric  := LCgerman.Numeric;
    |LcMonetary : LC.Monetary := LCgerman.Monetary;
    |LcMessages : LC.Messages := LCgerman.Messages;
   ELSE (* LcAll *)
     LC.Ctype    := LCgerman.Ctype;
     LC.Time     := LCgerman.Time;
     LC.Numeric  := LCgerman.Numeric;
     LC.Monetary := LCgerman.Monetary;
     LC.Messages := LCgerman.Messages;
   END;
 ELSIF (strcmp(locale, ADR(usastr)) = 0) THEN
   CASE category OF
     LcCtype    : LC.Ctype    := LCusa.Ctype;
    |LcCollate  :
    |LcTime     : LC.Time     := LCusa.Time;
    |LcNumeric  : LC.Numeric  := LCusa.Numeric;
    |LcMonetary : LC.Monetary := LCusa.Monetary;
    |LcMessages : LC.Messages := LCusa.Messages;
   ELSE (* LcAll *)
     LC.Ctype    := LCusa.Ctype;
     LC.Time     := LCusa.Time;
     LC.Numeric  := LCusa.Numeric;
     LC.Monetary := LCusa.Monetary;
     LC.Messages := LCusa.Messages;
   END;
 ELSE
   (* Kein Name eines unterstuetzten Locales *)
   e.errno := e.EINVAL;
   RETURN(NULL);
 END;

 IF category <= LcMessages THEN
   AssignCToM2(locale, 0, lcid);
   LC.Idents[VAL(UNSIGNEDWORD,category)] := lcid;
   RETURN(ADR(lcid));
 ELSE
   SplitLcAllId(locale);
   MakeLcAllId;
   RETURN(ADR(lcallid));
 END;
END setlocale;

(*---------------------------------------------------------------------------*)

PROCEDURE localeconv ( ): LConvPtr;
BEGIN
 WITH lconvrec DO
 grouping := LC.Numeric^.grouping;
 WITH LC.Numeric^ DO
   decimalPoint    := decimalpoint;
   thousandsSep    := thousandssep;
 END;

 WITH LC.Monetary^ DO
   intCurrSymbol   := intcurrsymbol;
   currencySymbol  := currencysymbol;
   monDecimalPoint := mondecimalpoint;
   monThousandsSep := monthousandssep;
   monGrouping     := mongrouping;
   positiveSign    := positivesign;
   negativeSign    := negativesign;

   intFracDigits   := intfracdigits;
   fracDigits      := fracdigits;
   pCsPrecedes     := pcsprecedes;
   pSepBySpace     := psepbyspace;
   nCsPrecedes     := ncsprecedes;
   nSepBySpace     := nsepbyspace;
   pSignPosn       := psignposn;
   nSignPosn       := nsignposn;
 END;
 END;
 RETURN(ADR(lconvrec));
END localeconv;

(*===========================================================================*)

BEGIN (* loc *)
 delim     := IDSEP;
 Cstr      := "C";
 posixstr  := LCPOSIX.Ident;
 germanstr := LCgerman.Ident;
 usastr    := LCusa.Ident;
END loc.
