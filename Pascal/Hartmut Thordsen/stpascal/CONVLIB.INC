{ conversion library - Copyright Hartmut Thordsen, V2.2 Dezember 1987 }

FUNCTION str_to_long_int (s : STRING; VAR x : LONG_INTEGER) : BOOLEAN;
								EXTERNAL;
FUNCTION str_to_int (s : STRING; VAR x : INTEGER) : BOOLEAN;	EXTERNAL;
FUNCTION str_to_real (s : STRING; VAR x : REAL) : BOOLEAN;	EXTERNAL;
  { Die Umwandlung eines Strings in einen numerischen Typ kann	Fehler	her-
  vorrufen. Diese Routinen sind deswegen als Funktionen  implementiert,  die
  im Fall eines Fehlers FALSE liefern, ansonsten TRUE und  den	Wert  in  x.
  Leerzeichen am Anfang und Ende des Strings werden ignoriert. }

PROCEDURE long_int_to_str (x : LONG_INTEGER; VAR s : STRING);	EXTERNAL;
PROCEDURE int_to_str (x : INTEGER; VAR s : STRING);		EXTERNAL;
PROCEDURE real_to_str (x : REAL; VAR s : STRING);		EXTERNAL;
  { Die Routinen, die einen String aus einer Zahl liefern sind als  Prozedur
  ausgelegt,  da  ihr Erfolg aužer  Frage steht und keinen Returncode erfor-
  derlich macht.
  Reals werden wie folgt zum String geformt: Die Mantisse wird als  -  ggfs.
  negative - Zahl zwischen 1 und 1000 gebildet. Sie wird  auf  alle  Stellen
  genau ausgegeben und kann je nach Wert unterschiedlich lang sein.Rundungs-
  fehler werden durch Rundung einer imagin„ren	12.  Mantissenziffer  ausge-
  glichen.  Falls  notwendig  (Exponent ungleich Null) folgt ein E und der -
  ggfs. negative - Exponent.  Dieser  wird  immer  als durch 3 teilbare Zahl
  ausgegeben, um ein besser lesbares Format zu erhalten. }

