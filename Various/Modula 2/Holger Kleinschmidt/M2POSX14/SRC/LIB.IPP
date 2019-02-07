IMPLEMENTATION MODULE lib;
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
(* Die Funktion "rand()" ist eine direkte Umsetzung aus der GnuLib/MiNTLib.  *)
(*---------------------------------------------------------------------------*)
(* 05-Mai-94, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT
PTR_ARITH_IMPORT

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR, TSIZE;

FROM PORTAB IMPORT
(* CONST*) MAXINT, MAXUNSIGNEDLONG, MINSIGNEDLONG, MAXSIGNEDLONG,
(* TYPE *) UNSIGNEDLONG, SIGNEDLONG, UNSIGNEDWORD;

FROM ctype IMPORT
(* PROC *) todigit, tocard, toupper, isspace;

FROM types IMPORT
(* CONST*) NULL, EOS,
(* TYPE *) StrPtr, StrPPtr, sizeT, int, unsigned, long, unsignedlong;

IMPORT e;

FROM MEMBLK IMPORT
(* PROC *) memswap;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

VAR
  Seed : SIGNEDLONG;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE lfind ((* EIN/ -- *) key     : ADDRESS;
                 (* EIN/ -- *) base    : ADDRESS;
                 (* EIN/ -- *) nelems  : sizeT;
                 (* EIN/ -- *) size    : sizeT;
                 (* EIN/ -- *) compare : CompareProc  ): ADDRESS;
(*T*)
VAR last : ADDRESS;

BEGIN
 IF   (key = NULL)
   OR (base = NULL)
   OR (size = VAL(sizeT,0))
   OR (nelems = VAL(sizeT,0))
 THEN
   RETURN(NULL);
 END;

 last := ADDADR(base, (nelems - VAL(sizeT,1)) * size);

 (* Indem das letzte zu vergleichende Feldelement
  * mit dem zu suchenden ausgetauscht wird, wirkt
  * es als Endemarke fuer das Suchen.
  *)
 memswap(key, last, size);

 WHILE compare(base, last) <> 0  DO
   base := ADDADR(base, size);
 END;

 (* Das Vertauschen muss natuerlich wieder rueckgaengig gemacht werden. *)
 memswap(key, last, size);

 (* Wenn das gesamte Feld durchsucht wurde, muss noch
  * der Vergleich mit dem letzten Element erfolgen,
  * ansonsten wurde schon vorher ein Element mit dem
  * gesuchten Wert gefunden.
  *)
 IF (base = last) AND (compare(last, key) <> 0) THEN
   RETURN(NULL);
 ELSE
   RETURN(base);
 END;
END lfind;

(*---------------------------------------------------------------------------*)

PROCEDURE bsearch ((* EIN/ -- *) key     : ADDRESS;
                   (* EIN/ -- *) base    : ADDRESS;
                   (* EIN/ -- *) nelems  : sizeT;
                   (* EIN/ -- *) size    : sizeT;
                   (* EIN/ -- *) compare : CompareProc  ): ADDRESS;
(*T*)
VAR __REG__ left  : sizeT;
    __REG__ right : sizeT;
    __REG__ mid   : sizeT;

BEGIN
 IF   (key = NULL)
   OR (base = NULL)
   OR (size = VAL(sizeT,0))
   OR (nelems = VAL(sizeT,0))
 THEN
   RETURN(NULL);
 END;

 left  := 0;
 right := nelems - VAL(sizeT,1);

 WHILE left < right DO
   mid := (left + right) DIV VAL(sizeT,2);
   (* left <= mid < right *)
   IF compare(ADDADR(base, mid * size), key) < 0 THEN
     left  := mid + VAL(sizeT,1);
   ELSE
     right := mid;
   END;
 END;

 base := ADDADR(base, left * size);
 IF compare(base, key) = 0 THEN
   RETURN(base);
 ELSE
   RETURN(NULL);
 END;
END bsearch;

(*---------------------------------------------------------------------------*)

PROCEDURE qsort ((* EIN/ -- *) base    : ADDRESS;
                 (* EIN/ -- *) nelems  : sizeT;
                 (* EIN/ -- *) size    : sizeT;
                 (* EIN/ -- *) compare : CompareProc  );
(*T*)
CONST direct = LC(8);

VAR cmpP : ADDRESS;

VAR rP : ADDRESS;
    (* wird bei Selectionsort benutzt, und ist hier deklariert,
     * damit er keinen Stackplatz beim rekursiven Aufruf von "sort()"
     * belegt. Er braucht keine lokale Variable von "sort()" zu sein,
     * da er nur vom Selectionsort benutzt werden, aus dem heraus kein
     * weiterer rekursiver Aufruf mehr stattfindet.
     *)

(* Das Prinzip von Quicksort ist an sich recht einfach:

   Als erstes wird ein beliebiges Element des Feldes ausgewaehlt, dann
   werden von beiden Enden des Feldes zur Mitte hin Elemente gesucht, die
   groesser bzw. kleiner oder gleich dem Vergleichselement sind - diese
   beiden Elemente werden ausgetauscht; das Austauschen wird solange
   wiederholt, bis sich die beiden Suchzeiger ueberschneiden; In der linken
   Haelfte befinden sich dann die Elemente, die kleiner oder gleich dem
   Vergleichselement sind, in der rechten Haelfte befinden sich die Elemente,
   die groesser oder gleich dem Vergleichselement sind.
   Diese Prozedur wird jetzt mit den beiden Haelften erneut ausgefuehrt
   usw. bis die zu sortierenden Teilfelder nur noch ein Element gross sind,
   dann ist das gesamte Feld sortiert. Die wiederholte Ausfuehrung gleicher
   Taetigkeiten schreit natuerlich nach Rekursion.

   Der Aufwand:

   Den Partitionierungsvorgang kann man sich als das Suchen eines bestimmten
   Elementes, naemlich das mit dem naechstgroesseren Wert, vorstellen.
   Angenommen, das Vergleichselement ist immer das wertemaessig mittlere
   Element: in diesem Fall wird die Suche zur Binaersuche, da immer die
   Haelfte der Werte beim naechsten Suchvorgang ausgeschlossen wird. Der
   Aufwand des binaeren Suchens betraegt  O( ld( n )); da wir n Elemente
   haben, betraegt der Sortieraufwand O( n * ld( n )).
   Das waere der Idealfall.

   Im schlechtesten Fall ist das ausgewaehlte Vergleichselement immer das
   wertemaessig groesste bzw. kleinste; in diesem Fall wird die Suche zur
   linearen Suche, deren mittlerer Aufwand  n/2 betraegt; der Aufwand des
   Sortierens betraegt dann  O( n * n ). Ein Beispiel waere ein bereits
   sortiertes Feld, bei dem man als Vergleichselement immer das erste
   auswaehlt.

   Den schlechtesten Fall kann man zwar nicht ganz ausschliessen, aber
   doch sehr unwahrscheinlich machen: die einfachste Methode ist, als
   Vergleichselement das positionsmaessig mittlere zu nehmen; die
   Wahrscheinlichkeit hierbei haeufig die Extremwerte zu erwischen ist
   gering. Noch unwahrscheinlicher wird es, wenn als Vergleichselement das
   wertemaessig mittlere aus dreien genommen wird (z.B. dem positionsmaessig
   ersten, mittleren und letzten).

   Abgesehen von der Wahl des Vergleichselementes gibt es weitere
   Moeglichkeiten zur Optimierung:

    - Zuerst die kleinere Haelfte weitersortieren.
      Hierdurch betraegt die Stackbelastung nur  ~ld(n).

    - Hinter dem rekursiven Aufruf zur Sortierung der zweiten, groesseren
      Haelfte folgt kein Ausdruck, der vom Ergebnis dieses Aufrufs abhaengt;
      die Sortierung der groesseren Feldes kann deswegen iterativ geschehen.

    - Wie alle hoeheren Sortiermethoden ist auch bei Quicksort die Leistung
      bei kleinem  n  schwach, da der Verwaltungsaufwand relativ gross ist.
      Unterschreitet daher die Groesse des zu sortierenden Teilfeldes ein
      hinreichend kleines  n, kann das Feld durch eine einfachere Methode
      (direktes Einfuegen, direkte Auswahl...) zuende sortiert werden.
*)

PROCEDURE sort ((* EIN/ -- *) bot : sizeT;
                (* EIN/ -- *) top : sizeT );

VAR         left   : sizeT;
            right  : sizeT;
    __REG__ leftP  : ADDRESS;
    __REG__ rightP : ADDRESS;

BEGIN (* sort *)
 WHILE bot < top DO
   left   := bot;
   right  := top;
   leftP  := ADDADR(base, bot * size);
   rightP := ADDADR(base, top * size);

   IF top - bot < direct THEN
     (* Direktes Sortieren durch Auswaehlen.
      * 'SelectionSort' ist bei so wenigen Elementen
      * (< 10) schneller als 'InsertionSort'.
      *
      * Funktionsweise:
      * Der Reihe nach vom ersten bis zum vorletzten
      * Element wird ein Vergleichselement gewaehlt,
      * das mit allen Elementen rechts von ihm verglichen
      * wird; das Minimum und das Vergleichselement
      * werden ausgetauscht.
      *)

     WHILE DIFADR(leftP, rightP) < VAL(SIGNEDLONG,0) DO
       cmpP := leftP;
       rP   := ADDADR(leftP, size);
       WHILE DIFADR(rP, rightP) <= VAL(SIGNEDLONG,0) DO
         IF compare(rP, cmpP) < 0 THEN
           cmpP := rP;
         END;
         rP := ADDADR(rP, size);
       END; (* WHILE *)

       IF cmpP <> leftP THEN
         memswap(cmpP, leftP, size);
       END;
       leftP := ADDADR(leftP, size);
     END;
     RETURN; (* fertig *)

   ELSE

     (* Es wird kein groesserer Aufwand bei der Auswahl des
      * mittleren Elementes betrieben, da dies in den allermeisten
      * Faellen mehr Zeit kostet, als es Zeit einspart, wenn das
      * Feld wirklich so unguenstig belegt ist, dass das
      * positionsmaessig mittlere immer das Extremelement ist.
      *)

     cmpP := ADDADR(base, ((left + right) DIV VAL(sizeT,2)) * size);

     REPEAT

       (* Bei der Suche nach den auszutauschenden Elementen gibt es
        * zwei Moeglichkeiten:
        *
        *  - Vom jeweiligen Rand ausgehend wird ein Element gesucht,
        *    dass groesser/kleiner ODER GLEICH dem Vergleichselement
        *    ist. Durch die Gleichbedingung wirkt das Vergleichselement
        *    als Endemarke der Iteration, da auf jeden Fall dieses
        *    Element gefunden wird.
        *    Der Nachteil: Kommt der Wert des Vergleichselementes
        *    haufig in dem Feld vor, so finden entsprechend viele
        *    unnoetige Austauschoperationen statt.
        *
        *  - Vom jeweiligen Rand her wird ein Element gesucht, dass
        *    ECHT groesser (kleiner) als das Vergleichselement ist.
        *    Das vermeidet die unnoetigen Austauschoperationen bei
        *    Elementen, die gleich dem Vergleichselement sind;
        *    allerdings wirkt das Vergleichselement nun nicht mehr
        *    als Marke (es kann sein, dass kein Element gefunden
        *    wird, das echt groesser/kleiner als das Vergleichselement
        *    ist), sodass zusaetzlich der Laufindex als Endebedingung
        *    abgefragt werden muss.
        *
        * Es wird die erste Methode benutzt, da eine grosse Anzahl
        * von Elementen mit gleichem Schluessel sicher selten vorkommt,
        * und bei der zweiten Methode dafuer an anderer Stelle mehr
        * Aufwand getrieben werden muss.
        *)

       WHILE compare(leftP, cmpP) < 0 DO
         leftP := ADDADR(leftP, size);
         INC(left);
       END;

       WHILE compare(cmpP, rightP) < 0 DO
         rightP := SUBADR(rightP, size);
         DEC(right);
       END;

       IF left <= right THEN
         memswap(leftP, rightP, size);
         (* Falls das Vergleichselement beim Austausch beteiligt war,
          * muss auch der Zeiger auf das Vergleichselement entsprechend
          * neu gesetzt werden.
          *)
         IF cmpP = leftP THEN
           cmpP := rightP;
         ELSIF cmpP = rightP THEN
           cmpP := leftP;
         END;

         IF left < top THEN
           INC(left);
           leftP := ADDADR(leftP, size);
         END;
         IF right > bot THEN
           DEC(right);
           rightP := SUBADR(rightP, size);
         END;
       END;
     UNTIL left > right;

     (* (bot<=i<left)->(x[i]<=x[cmpP]) & (right<i<=top)->(x[i]>=x[cmpP]) *)

     IF (right - bot) < (top - left) THEN
       (* Nur das kleinere Teilfeld wird rekursiv
        * weitersortiert, das groessere wird durch
        * die darauffolgenden Zuweisungen in der
        * Schleife weiter zerlegt.
        *)
       IF bot < right THEN
         (* Rekursionsbasis: Teilfeld ist sortiert,
          * wenn es nur noch ein Element enthaelt.
          *)
         sort(bot, right);
       END;
       (* Die Elemente left von <left> sind jetzt sortiert,
        * die groessere Haelfte wird in der Schleife
        * weiterbearbeitet.
        *)
       bot := left;
     ELSE
       IF left < top THEN
         sort(left, top);
       END;
       top := right;
     END; (* IF (right ..*)

   END; (* IF (top ..*)
 END; (* WHILE *)
END sort;

BEGIN (* qsort *)
 IF   (base = NULL)
   OR (size = VAL(sizeT,0))
   OR (nelems <= VAL(sizeT,1))
 THEN
   RETURN;
 END;
 sort(0, nelems - VAL(sizeT,1));
END qsort;

(*---------------------------------------------------------------------------*)

PROCEDURE ValToStr ((* EIN/ -- *) val    : UNSIGNEDLONG;
                    (* EIN/ -- *) signed : BOOLEAN;
                    (* EIN/ -- *) base   : int;
                    (* -- /AUS *) buf    : StrPtr       );

VAR         basis  : UNSIGNEDLONG;
    __REG__ len    : UNSIGNEDWORD;
    __REG__ i      : UNSIGNEDWORD;
    __REG__ b      : StrPtr;
            sign   : BOOLEAN;
            digits : ARRAY [0..33] OF CHAR;

BEGIN
 IF (base < 2) OR (base > 36) THEN
   basis := 10;
 ELSE
   basis := VAL(UNSIGNEDLONG,base);
 END;

 sign := signed AND (base = 10) AND (CAST(SIGNEDLONG,val) < VAL(SIGNEDLONG,0));
 IF sign THEN
   IF val <> CAST(UNSIGNEDLONG,MINSIGNEDLONG) THEN
     (* Abfrage verhindert Ueberlauffehler, da MINSIGNEDLONG im
      * Zweierkomplement nicht als positive Zahl darstellbar ist
      * und unveraendert bleibt.
      *)
     val := CAST(UNSIGNEDLONG,-CAST(SIGNEDLONG,val));
   END;
 END;

 (* Die Zahl von hinten nach vorne in String wandeln;
  * durch die REPEAT-Schleife wird auch die Null
  * dargestellt.
  *)
 len := 0;
 REPEAT
   digits[len] := toupper(todigit(VAL(CARDINAL,val MOD basis)));
   val    := val DIV basis;
   INC(len);
 UNTIL val = LC(0);
 IF sign THEN
   digits[len] := '-';
   INC(len);
 END;

 (* Jetzt wird die Zahlendarstellung in umgekehrter
  * Reihenfolge aus dem Hilfsstring in den eigentlichen
  * String uebertragen. Ausserdem werden Prefix und fuehrende
  * Nullen hinzugefuegt.
  *)

 b := buf;
 IF b <> NULL THEN
   i := 0;
   WHILE len > 0 DO
     DEC(len);
     b^[i] := digits[len];
     INC(i);
   END;
   b^[i] := 0C;
 END;
END ValToStr;

(*---------------------------------------------------------------------------*)

PROCEDURE itoa ((* EIN/ -- *) n    : int;
                (* EIN/ -- *) buf  : StrPtr;
                (* EIN/ -- *) base : int    );
BEGIN
 ValToStr(CAST(UNSIGNEDLONG,VAL(SIGNEDLONG,n)), TRUE, base, buf);
END itoa;

(*---------------------------------------------------------------------------*)

PROCEDURE ltoa ((* EIN/ -- *) n    : long;
                (* EIN/ -- *) buf  : StrPtr;
                (* EIN/ -- *) base : int    );
BEGIN
 ValToStr(CAST(UNSIGNEDLONG,n), TRUE, base, buf);
END ltoa;

(*---------------------------------------------------------------------------*)

PROCEDURE ultoa ((* EIN/ -- *) n    : unsignedlong;
                 (* EIN/ -- *) buf  : StrPtr;
                 (* EIN/ -- *) base : int           );

BEGIN
 ValToStr(n, FALSE, base, buf);
END ultoa;

(*---------------------------------------------------------------------------*)

PROCEDURE StrToVal ((* EIN/ -- *)     str     : StrPtr;
                    (* EIN/ -- *)     max     : UNSIGNEDLONG;
                    (* EIN/ -- *)     basis   : int;
                    (* EIN/ -- *)     signed  : BOOLEAN;
                    (* -- /AUS *) VAR nextIdx : UNSIGNEDWORD;
                    (* -- /AUS *) VAR val     : UNSIGNEDLONG  );

VAR __REG__ idx          : UNSIGNEDWORD;
    __REG__ digit        : CHAR;
    __REG__ s            : StrPtr;
            neg          : BOOLEAN;
            maxDivBase   : UNSIGNEDLONG;
            maxLastDigit : UNSIGNEDLONG;
            num          : UNSIGNEDLONG;
            base         : UNSIGNEDLONG;

BEGIN
 val := 0;
 idx := 0;
 neg := FALSE;
 s   := str;
 IF s = NULL THEN
   nextIdx := 0;
   RETURN;
 END;

 (* Fuehrende Leerzeichen tun nichts zur Sache *)
 WHILE isspace(s^[idx]) DO
   INC(idx);
 END;

 (* Moegliches Vorzeichen feststellen, bei negativer Zahl ist der
  * maximale Wert um eins groesser (im Zweierkomplement).
  *)
 IF signed THEN
   digit := s^[idx];
   neg   := digit = '-';
   IF digit = '+' THEN
     INC(idx);
   ELSIF neg THEN
     (* Negative Zahlen haben einen um eins groesseren
      * Wertebereich als positive Zahlen (die Null ausgenommen).
      *)
     INC(idx);
     INC(max);
   END;
 END;

 digit := s^[idx];
 IF digit = 0C THEN
   (* Keine Zahl folgt => Fehler *)
   nextIdx := idx;
   RETURN;
 END;

 IF (basis < 2) OR (basis > 36) THEN
   basis := 0;
 END;
 base := VAL(UNSIGNEDLONG,basis);

 IF basis = 0 THEN
   (* Die Basis der Zahl soll aus der Zeichenfolge hervorgehen *)
   INC(idx);
   IF digit = '%' THEN
     (* Zahl in Binaerdarstellung *)
     base := 2;
   ELSIF digit = '0' THEN
     (* Zahl in Sedezimal- oder Oktaldarstellung oder einzelne Null *)
     IF toupper(s^[idx]) = 'X' THEN
       base := 16;
       INC(idx);
     ELSE
       base := 8;
     END;
   ELSIF digit = '$' THEN
     base := 16;
   ELSE
     base := 10;
     DEC(idx);
   END;

 (* Die Basis ist angegeben, zusaetzliche Angabe in Repraesentation
  * ueberlesen (Oktalnull stoert nicht).
  *)
 ELSIF (basis = 2) AND (digit = '%') THEN
   (* Binaerdarstellung *)
   INC(idx);
 ELSIF basis = 16 THEN
   (* Sedezimaldarstellung *)
   IF digit = '$' THEN
     INC(idx);
   ELSIF (digit = '0') AND (toupper(s^[idx+1]) = 'X') THEN
     INC(idx, 2);
   END;
 END;

 maxDivBase   := max DIV base;
 maxLastDigit := max MOD base;

 LOOP
   (* Abbrechen, sobald der String zuende ist, oder ein Zeichen gefunden
    * wurde, das keine gueltige Ziffer ist, oder ein Ueberlauf stattfinden
    * wuerde.
    *)
   nextIdx := idx;
   digit   := s^[idx];
   IF digit = 0C THEN
     EXIT;
   END;

   num := VAL(UNSIGNEDLONG,tocard(digit));
   IF num >= base THEN
     EXIT;
   END;

   (* Da <val> mit jedem neuen Digit um eine Stelle erweitert wird,
    * wird fuer die Ueberlaufpruefung der bisherige <val> vor der
    * Erweiterung mit einem Zehntel des Maximalwerts verglichen;
    * wuerde nach der Erweiterung verglichen, waere der Ueberlauf
    * ja womoeglich schon passiert, und dabei koennte auch ein
    * UNSIGNEDLONG-Ueberlauf auftreten -- ein Vergleich wuerde dann
    * nur Unsinn produzieren.
    * Ist der bisherige Wert kleiner als ein Zehntel des Maximums,
    * kann kein Ueberlauf auftreten, ist der bisherige Wert gleich
    * dem Maximumszehntel, muss geprueft werden, ob das neue Digit
    * den Wert des letzten Digits des Maximums ueberschreitet.
    *)
   IF    (val < maxDivBase)
      OR (val = maxDivBase) AND (num <= maxLastDigit)
   THEN
     val := val * base + num;
     INC(idx);
   ELSE (* Ueberlauf *)
     e.errno := e.ERANGE;
     IF neg AND (max <> CAST(UNSIGNEDLONG,MINSIGNEDLONG)) THEN
       val := CAST(UNSIGNEDLONG,-CAST(SIGNEDLONG,max));
     ELSE
       val := max;
     END;
     RETURN;
   END;
 END; (* LOOP *)

 IF neg AND (val <> CAST(UNSIGNEDLONG,MINSIGNEDLONG)) THEN
   (* Wenn vor der Zahl ein '-' stand und negative Zahlen erlaubt
    * sind, den bisher positiven Zahlenwert in einen negativen wandeln.
    * Abfrage auf MINSIGNEDLONG verhindert Ueberlauf.
    *)
   val := CAST(UNSIGNEDLONG,-CAST(SIGNEDLONG,val));
 END;
END StrToVal;

(*---------------------------------------------------------------------------*)

PROCEDURE strtol ((* EIN/ -- *) str  : StrPtr;
                  (* EIN/ -- *) end  : StrPPtr;
                  (* EIN/ -- *) base : int      ): long;

VAR val  : UNSIGNEDLONG;
    next : UNSIGNEDWORD;

BEGIN
 StrToVal(str, MAXSIGNEDLONG, base, TRUE, next, val);
 IF end <> NULL THEN
   end^ := ADR(str^[next]);
 END;
 RETURN(CAST(long,val));
END strtol;

(*---------------------------------------------------------------------------*)

PROCEDURE strtoul ((* EIN/ -- *) str  : StrPtr;
                   (* EIN/ -- *) end  : StrPPtr;
                   (* EIN/ -- *) base : int      ): unsignedlong;

VAR val  : UNSIGNEDLONG;
    next : UNSIGNEDWORD;

BEGIN
 StrToVal(str, MAXUNSIGNEDLONG, base, FALSE, next, val);
 IF end <> NULL THEN
   end^ := ADR(str^[next]);
 END;
 RETURN(val);
END strtoul;

(*---------------------------------------------------------------------------*)

PROCEDURE atol ((* EIN/ -- *) str : StrPtr ): long;

VAR val  : UNSIGNEDLONG;
    next : UNSIGNEDWORD;

BEGIN
 StrToVal(str, MAXSIGNEDLONG, 10, TRUE, next, val);
 RETURN(CAST(long,val));
END atol;

(*---------------------------------------------------------------------------*)

PROCEDURE atoi ((* EIN/ -- *) str : StrPtr ): int;

VAR val  : UNSIGNEDLONG;
    next : UNSIGNEDWORD;

BEGIN
 StrToVal(str, MAXINT, 10, TRUE, next, val);
 RETURN(INT(val));
END atoi;

(*---------------------------------------------------------------------------*)

PROCEDURE rand ( ): int;

CONST
  A = LIC(16807);
  M = LIC(2147483647);
  Q = LIC(127773);
  R = LIC(2836);

BEGIN
 Seed := A * (Seed MOD Q) - R * (Seed DIV Q);
 IF Seed < VAL(SIGNEDLONG,0) THEN
   INC(Seed, M);
 END;

 IF TSIZE(int) < TSIZE(SIGNEDLONG) THEN
   RETURN(VAL(int,CAST(UNSIGNEDLONG,Seed) MOD VAL(UNSIGNEDLONG,8000H)));
 ELSE
   RETURN(CAST(int,Seed));
 END;
END rand;

(*---------------------------------------------------------------------------*)

PROCEDURE srand ((* EIN/ -- *) seed : unsigned );
BEGIN
 Seed := CAST(SIGNEDLONG,VAL(UNSIGNEDLONG,seed));
END srand;

(*===========================================================================*)

BEGIN (* lib *)
 Seed := 1;
END lib.
