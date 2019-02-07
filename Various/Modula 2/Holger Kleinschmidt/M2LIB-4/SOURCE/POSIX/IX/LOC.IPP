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
(* 10-Aug-96, Holger Kleinschmidt                                           *)
(****************************************************************************)

/* Die spaeter im Programm verfuegbaren Locales koennen hier eingestellt
 * werden; dazu muss nur der Wert im entsprechenden #if auf 1 statt 0
 * gesetzt werden. Das POSIX-Locale ist immer vorhanden sein, durch
 * Weglassen der anderen Locales kann aber die Programmgroesse gesenkt
 * werden.
 */

#if 1
#define __INCLUDE_DE_LOCALE__
#endif

#if 0
#define __INCLUDE_EN_LOCALE__
#endif

#if 0
#define __INCLUDE_FR_LOCALE__
#endif

#if 0
#define __INCLUDE_NL_LOCALE__
#endif



VAL_INTRINSIC
CAST_IMPORT

FROM SYSTEM IMPORT
(* PROC *) ADR;

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) UNSIGNEDWORD;

IMPORT er;

FROM types IMPORT
(* TYPE *) StrRange, StrPtr;

FROM str IMPORT
(* PROC *) strlen, strcmp, strcpy, AssignCToM2, AssignM2ToC, Token;

FROM ISOStrings IMPORT
(* TYPE *) String1,
(* PROC *) Append;

FROM args IMPORT
(* PROC *) getenv;

FROM DosSystem IMPORT
(* TYPE *) PrefLanguage,
(* PROC *) Language;

FROM LCTypes IMPORT
(* CONST*) MAXLCID, IDSEP, IDSEPLEN,
(* TYPE *) LCIdent;

IMPORT LC, LCPOSIX;
#ifdef __INCLUDE_DE_LOCALE__
IMPORT LCde;
#endif
#ifdef __INCLUDE_EN_LOCALE__
IMPORT LCen;
#endif
#ifdef __INCLUDE_FR_LOCALE__
IMPORT LCfr;
#endif
#ifdef __INCLUDE_NL_LOCALE__
IMPORT LCnl;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

VAR
  Cstr     : ARRAY [0..1] OF CHAR;
  posixstr : LCIdent;
#ifdef __INCLUDE_EN_LOCALE__
  enstr    : LCIdent;
#endif
#ifdef __INCLUDE_DE_LOCALE__
  destr    : LCIdent;
#endif
#ifdef __INCLUDE_FR_LOCALE__
  frstr    : LCIdent;
#endif
#ifdef __INCLUDE_NL_LOCALE__
  nlstr    : LCIdent;
#endif
  delim    : ARRAY [0..IDSEPLEN] OF CHAR;
  lconvrec : LConvRec;
  lcid     : LCIdent;
  lcallid  : ARRAY [0..6*MAXLCID+6] OF CHAR;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE SplitLcAllId ((* EIN/ -- *) all : StrPtr );

VAR         aidx  : StrRange;
            alen  : StrRange;
            tlen  : StrRange;
            token : StrPtr;
    __REG__ id    : StrRange;
    __REG__ last  : StrRange;

BEGIN
 aidx := 0;
 alen := VAL(StrRange,strlen(all));
 id   := 0;
 WHILE (id <= 5) & Token(all, ADR(delim), alen, aidx, tlen, token) DO
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
            s1 : String1;

BEGIN
 lcallid := "";
 s1[0]   := IDSEP;
 FOR id := 0 TO 4 DO
   Append(LC.Idents[id], lcallid);
   Append(s1, lcallid);
 END;
 Append(LC.Idents[5], lcallid);
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
           UnknownLanguage : ident := LCPOSIX.Ident;
#ifdef __INCLUDE_DE_LOCALE__
          |lFRG,lSWG : ident := LCde.Ident;
#endif
#ifdef __INCLUDE_FR_LOCALE__
          |lFRA,lSWF : ident := LCfr.Ident;
#endif
#ifdef __INCLUDE_EN_LOCALE__
          |lUSA,lUK :  ident := LCen.Ident;
#endif
#ifdef __INCLUDE_NL_LOCALE__
          |lHOL :      ident := LCnl.Ident;
#endif
         ELSE          ident := LCPOSIX.Ident;
         END;
         locale := ADR(ident);
       END;
     END;
   END;
 END;

 IF (strcmp(locale, ADR(Cstr)) = 0) OR (strcmp(locale, ADR(posixstr)) = 0) THEN
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
#ifdef __INCLUDE_DE_LOCALE__
 ELSIF (strcmp(locale, ADR(destr)) = 0) THEN
   CASE category OF
     LcCtype    : LC.Ctype    := LCde.Ctype;
    |LcCollate  :
    |LcTime     : LC.Time     := LCde.Time;
    |LcNumeric  : LC.Numeric  := LCde.Numeric;
    |LcMonetary : LC.Monetary := LCde.Monetary;
    |LcMessages : LC.Messages := LCde.Messages;
   ELSE (* LcAll *)
     LC.Ctype    := LCde.Ctype;
     LC.Time     := LCde.Time;
     LC.Numeric  := LCde.Numeric;
     LC.Monetary := LCde.Monetary;
     LC.Messages := LCde.Messages;
   END;
#endif
#ifdef __INCLUDE_EN_LOCALE__
 ELSIF (strcmp(locale, ADR(enstr)) = 0) THEN
   CASE category OF
     LcCtype    : LC.Ctype    := LCen.Ctype;
    |LcCollate  :
    |LcTime     : LC.Time     := LCen.Time;
    |LcNumeric  : LC.Numeric  := LCen.Numeric;
    |LcMonetary : LC.Monetary := LCen.Monetary;
    |LcMessages : LC.Messages := LCen.Messages;
   ELSE (* LcAll *)
     LC.Ctype    := LCen.Ctype;
     LC.Time     := LCen.Time;
     LC.Numeric  := LCen.Numeric;
     LC.Monetary := LCen.Monetary;
     LC.Messages := LCen.Messages;
   END;
#endif
#ifdef __INCLUDE_FR_LOCALE__
 ELSIF (strcmp(locale, ADR(frstr)) = 0) THEN
   CASE category OF
     LcCtype    : LC.Ctype    := LCfr.Ctype;
    |LcCollate  :
    |LcTime     : LC.Time     := LCfr.Time;
    |LcNumeric  : LC.Numeric  := LCfr.Numeric;
    |LcMonetary : LC.Monetary := LCfr.Monetary;
    |LcMessages : LC.Messages := LCfr.Messages;
   ELSE (* LcAll *)
     LC.Ctype    := LCfr.Ctype;
     LC.Time     := LCfr.Time;
     LC.Numeric  := LCfr.Numeric;
     LC.Monetary := LCfr.Monetary;
     LC.Messages := LCfr.Messages;
   END;
#endif
#ifdef __INCLUDE_NL_LOCALE__
 ELSIF (strcmp(locale, ADR(nlstr)) = 0) THEN
   CASE category OF
     LcCtype    : LC.Ctype    := LCnl.Ctype;
    |LcCollate  :
    |LcTime     : LC.Time     := LCnl.Time;
    |LcNumeric  : LC.Numeric  := LCnl.Numeric;
    |LcMonetary : LC.Monetary := LCnl.Monetary;
    |LcMessages : LC.Messages := LCnl.Messages;
   ELSE (* LcAll *)
     LC.Ctype    := LCnl.Ctype;
     LC.Time     := LCnl.Time;
     LC.Numeric  := LCnl.Numeric;
     LC.Monetary := LCnl.Monetary;
     LC.Messages := LCnl.Messages;
   END;
#endif
 ELSE
   (* Kein Name eines unterstuetzten Locales *)
   er.errno := er.EINVAL;
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
 delim    := IDSEP;
 Cstr     := "C";
 posixstr := LCPOSIX.Ident;
#ifdef __INCLUDE_EN_LOCALE__
 enstr    := LCen.Ident;
#endif
#ifdef __INCLUDE_DE_LOCALE__
 destr    := LCde.Ident;
#endif
#ifdef __INCLUDE_FR_LOCALE__
 frstr    := LCfr.Ident;
#endif
#ifdef __INCLUDE_NL_LOCALE__
 nlstr    := LCnl.Ident;
#endif
END loc.
