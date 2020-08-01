MODULE Char; (* SJ 26.11.94 *)

(*
 Module Character implements some procedures on type CHAR.
 *)



PROCEDURE Cap*(c: CHAR) : CHAR;
(*
 Answer the capital letter of c. German "Umlaute" are capitalized
 correctly.
 *)
 BEGIN
  CASE c OF
    "Ñ", "é": RETURN "é"
  | "î", "ô": RETURN "ô"
  | "Å", "ö": RETURN "ö"
    ELSE RETURN CAP(c);
  END;
 END Cap;


PROCEDURE IsVowel*(c: CHAR) : BOOLEAN;
(*
 Answer TRUE if c is a vowel. German "Umlaute" are recognized as vowels.
 *)
 BEGIN
  c := Cap(c);
  RETURN (c = "A") OR (c = "E") OR (c = "I") OR (c = "O") OR (c = "U")
         OR (c = "é") OR (c = "ô") OR (c = "ö")
 END IsVowel;


END Char.