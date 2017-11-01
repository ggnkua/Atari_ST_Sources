IMPLEMENTATION MODULE WConvBase;
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
(* 25-Mai-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHME: 'SIGNED' und 'UNSIGNED' koennen mittels CAST uminterpretiert
            werden, d.h. sie haben die gleiche Speichergroesse, oder CAST
            kann auch bei unterschiedlichen Groessen verwendet werden, und
            UNSIGNED ist groesser als SIGNED.
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)

VAL_INTRINSIC
CAST_IMPORT

FROM PORTAB IMPORT
(* CONST*) MINSIGNED, MAXSIGNED, MAXUNSIGNED,
(* TYPE *) UNSIGNED, SIGNED, UNSIGNEDWORD;

IMPORT types;

FROM ConvTypes IMPORT
(* TYPE *) ConvResults;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE valToStr ((* EIN/ -- *)     val    : UNSIGNED;
                    (* EIN/ -- *)     signed : BOOLEAN;
                    (* -- /AUS *) VAR size   : UNSIGNEDWORD;
                    (* -- /AUS *) VAR str    : ARRAY OF CHAR );

VAR __REG__ len    : UNSIGNEDWORD;
    __REG__ i      : UNSIGNEDWORD;
    __REG__ value  : UNSIGNEDWORD;
            digits : WholeString;

BEGIN
 signed := signed & (CAST(SIGNED,val) < VAL(SIGNED,0));
 IF signed & (CAST(SIGNED,val) # MINSIGNED) THEN
   (* Abfrage verhindert Ueberlauffehler, da MINSIGNED im Zweierkomplement
    * nicht als positive Zahl darstellbar ist und unveraendert bleibt.
    *)
   val := CAST(UNSIGNED,-CAST(SIGNED,val));
 END;

 (* Die Zahl von hinten nach vorne in String wandeln.
  * Durch die REPEAT-Schleife wird auch die Null dargestellt.
  *)
 len := 0;
 WHILE val > VAL(UNSIGNED,65535) DO
   digits[len] := CHR(VAL(UNSIGNEDWORD,val MOD VAL(UNSIGNED,10)) + VAL(UNSIGNEDWORD,ORD('0')));
   val         := val DIV VAL(UNSIGNED,10);
   INC(len);
 END;
 (* Ab hier reicht 16-Bit-Arithmetik *)
 value := VAL(UNSIGNEDWORD,val);
 REPEAT
   digits[len] := CHR(value MOD 10 + VAL(UNSIGNEDWORD,ORD('0')));
   value       := value DIV 10;
   INC(len);
 UNTIL value = 0;
 IF signed THEN
   digits[len] := '-';
   INC(len);
 END;
 size := len;

 IF len > VAL(UNSIGNEDWORD,HIGH(str)) THEN
   len := VAL(UNSIGNEDWORD,HIGH(str)) + 1;
 ELSE
   str[len] := types.EOS;
 END;

 (* Jetzt wird die Zahlendarstellung in umgekehrter Reihenfolge aus
  * dem Hilfsstring in den eigentlichen String uebertragen.
  *)

 i := 0;
 WHILE len > 0 DO
   DEC(len);
   str[i] := digits[len];
   INC(i);
 END;
END valToStr;

(*---------------------------------------------------------------------------*)

PROCEDURE strToCard ((* EIN/ -- *) VAR str     : ARRAY OF CHAR;
                     (* -- /AUS *) VAR val     : UNSIGNED;
                     (* -- /AUS *) VAR result  : ConvResults   );

CONST MaxDivBase   = LC(429496729); (* MAX(UNSIGNED) DIV 10 *)
      MaxLastDigit = LC(5);         (* MAX(UNSIGNED) MOD 10 *)

VAR __REG__ idx   : UNSIGNEDWORD;
    __REG__ value : UNSIGNED;
    __REG__ digit : CHAR;
            num   : UNSIGNED;
            tmp   : UNSIGNED;

BEGIN
 value := 0;
 val   := 0;
 idx   := 0;

 (* Fuehrende Leerzeichen tun nichts zur Sache *)
 WHILE (idx <= VAL(UNSIGNEDWORD,HIGH(str))) & (str[idx] = ' ') DO
   INC(idx);
 END;
 IF (idx > VAL(UNSIGNEDWORD,HIGH(str))) OR (str[idx] = types.EOS) THEN
   (* Nichts, ausser evtl. Leerzeichen *)
   result := strEmpty;
   RETURN;
 END;
 (* Es folgt noch mindestens ein Zeichen (str[idx]) *)

 LOOP
   (* Abbrechen, sobald der String zuende ist, oder ein Zeichen gefunden
    * wurde, das keine gueltige Ziffer ist, oder ein Ueberlauf stattfinden
    * wuerde.
    *)

   digit := str[idx];
   IF ('0' <= digit) & (digit <= '9') THEN
     num := VAL(UNSIGNED,ORD(digit) - ORD('0'));
   ELSE
     result := strWrongFormat;
     val    := value;
     RETURN;
   END;

   (* Da <value> mit jedem neuen Digit um eine Stelle erweitert wird,
    * wird fuer die Ueberlaufpruefung der bisherige <value> vor der
    * Erweiterung mit einem Zehntel des Maximalwertes verglichen;
    * wuerde nach der Erweiterung verglichen, waere der Ueberlauf
    * ja womoeglich schon passiert, und dabei koennte auch ein
    * UNSIGNEDLONG-Ueberlauf auftreten -- ein Vergleich wuerde dann
    * nur Unsinn produzieren.
    * Ist der bisherige Wert kleiner als ein Zehntel des Maximums,
    * kann kein Ueberlauf auftreten, ist der bisherige Wert gleich
    * dem Maximumszehntel, muss geprueft werden, ob das neue Digit
    * den Wert des letzten Digits des Maximums ueberschreitet.
    *)
   IF    (value < MaxDivBase)
      OR (value = MaxDivBase) & (num <= MaxLastDigit)
   THEN
     (* value := value * 10 + num; *)
     INC(value, value);
     tmp := value;
     INC(value, value);
     INC(value, value);
     INC(value, tmp);
     INC(value, num);

     INC(idx);
   ELSE (* Ueberlauf *)
     value  := MAXUNSIGNED;
     result := strOutOfRange;
     val    := value;
     RETURN;
   END;

   IF (idx > VAL(UNSIGNEDWORD,HIGH(str))) OR (str[idx] = types.EOS) THEN
     EXIT;
   END;
 END; (* LOOP *)

 result := strAllRight;
 val    := value;
END strToCard;

(*---------------------------------------------------------------------------*)

PROCEDURE strToInt ((* EIN/ -- *) VAR str     : ARRAY OF CHAR;
                    (* -- /AUS *) VAR val     : SIGNED;
                    (* -- /AUS *) VAR result  : ConvResults   );

VAR __REG__ idx          : UNSIGNEDWORD;
    __REG__ value        : UNSIGNED;
    __REG__ digit        : CHAR;
            signed       : BOOLEAN;
            maxDivBase   : UNSIGNED;
            maxLastDigit : UNSIGNED;
            num          : UNSIGNED;
            tmp          : UNSIGNED;

BEGIN
 value        := 0;
 val          := 0;
 idx          := 0;
 maxDivBase   := LC(214748364);
 maxLastDigit := LC(7);

 (* Fuehrende Leerzeichen tun nichts zur Sache *)
 WHILE (idx <= VAL(UNSIGNEDWORD,HIGH(str))) & (str[idx] = ' ') DO
   INC(idx);
 END;
 IF (idx > VAL(UNSIGNEDWORD,HIGH(str))) OR (str[idx] = types.EOS) THEN
   (* Nichts, ausser evtl. Leerzeichen *)
   result := strEmpty;
   RETURN;
 END;

 (* Moegliches Vorzeichen feststellen, bei negativer Zahl ist der
  * maximale Wert um eins groesser (im Zweierkomplement).
  *)
 digit  := str[idx];
 signed := digit = '-';
 IF digit = '+' THEN
   INC(idx);
 ELSIF signed THEN
   (* Negative Zahlen haben einen um eins groesseren
    * Wertebereich als positive Zahlen (die Null ausgenommen).
    *)
   INC(idx);
   INC(maxLastDigit);
 END;
 IF (idx > VAL(UNSIGNEDWORD,HIGH(str))) OR (str[idx] = types.EOS) THEN
   (* Hinter dem Vorzeichen ist Zahl zuende *)
   result := strWrongFormat;
   RETURN;
 END;
 (* Es folgt noch mindestens ein Zeichen (str[idx]) *)


 LOOP
   (* Abbrechen, sobald der String zuende ist, oder ein Zeichen gefunden
    * wurde, das keine gueltige Ziffer ist, oder ein Ueberlauf stattfinden
    * wuerde.
    *)

   digit := str[idx];
   IF ('0' <= digit) & (digit <= '9') THEN
     num := VAL(UNSIGNED,ORD(digit) - ORD('0'));
   ELSE
     result := strWrongFormat;
     val    := value;
     RETURN;
   END;

   (* Da <value> mit jedem neuen Digit um eine Stelle erweitert wird,
    * wird fuer die Ueberlaufpruefung der bisherige <value> vor der
    * Erweiterung mit einem Zehntel des Maximalwertes verglichen;
    * wuerde nach der Erweiterung verglichen, waere der Ueberlauf
    * ja womoeglich schon passiert, und dabei koennte auch ein
    * UNSIGNEDLONG-Ueberlauf auftreten -- ein Vergleich wuerde dann
    * nur Unsinn produzieren.
    * Ist der bisherige Wert kleiner als ein Zehntel des Maximums,
    * kann kein Ueberlauf auftreten, ist der bisherige Wert gleich
    * dem Maximumszehntel, muss geprueft werden, ob das neue Digit
    * den Wert des letzten Digits des Maximums ueberschreitet.
    *)
   IF    (value < maxDivBase)
      OR (value = maxDivBase) & (num <= maxLastDigit)
   THEN
     (* value := value * 10 + num; *)
     INC(value, value);
     tmp := value;
     INC(value, value);
     INC(value, value);
     INC(value, tmp);
     INC(value, num);

     INC(idx);
   ELSE (* Ueberlauf *)
     IF signed THEN
       val := MINSIGNED;
     ELSE
       val := MAXSIGNED;
     END;
     result := strOutOfRange;
     RETURN;
   END;

   IF (idx > VAL(UNSIGNEDWORD,HIGH(str))) OR (str[idx] = types.EOS) THEN
     EXIT;
   END;
 END; (* LOOP *)

 IF signed & (value # CAST(UNSIGNED,MINSIGNED)) THEN
   (* Wenn vor der Zahl ein '-' stand, den bisher positiven Zahlenwert
    * in einen negativen wandeln.
    * Abfrage auf MINSIGNED verhindert Ueberlauf.
    *)
   value := CAST(UNSIGNED,-CAST(SIGNED,value));
 END;
 result := strAllRight;
 val    := value;
END strToInt;

END WConvBase.

