{ string library - Copyright Hartmut Thordsen, V2.2 Dezember 1987 }

PROCEDURE ltrim (VAR s : STRING);				EXTERNAL;
PROCEDURE rtrim (VAR s : STRING);				EXTERNAL;
PROCEDURE trim (VAR s : STRING);				EXTERNAL;
  { Diese Prozeduren entfernen fÅhrende  Leerzeichen (ltrim), Leerzeichen
  am Ende des Strings (rtrim) oder beides (trim). }

PROCEDURE lformat (VAR s : STRING; width : INTEGER);		EXTERNAL;
PROCEDURE rformat (VAR s : STRING; width : INTEGER);		EXTERNAL;
PROCEDURE cformat (VAR s : STRING; width : INTEGER);		EXTERNAL;
  { Diese Prozeduren geben in s den  Åbergebenen String formatiert in der
  LÑnge width zurÅck. Ist s lÑnger als width,  so  wird der  Åberstehende
  Teil rechts (lformat), links (rformat) oder beidseitig (cformat)  abge-
  schnitten. Sonst wird s linksbÅndig (lformat),  rechtsbÅndig	(rformat)
  oder zentriert (cformat) entsprechend mit Leerzeichen aufgefÅllt. }

FUNCTION verify (s, in_chars : STRING) : INTEGER;		EXTERNAL;
  { verify prÅft,  ob s nur aus solchen  Zeichen  besteht,  die  auch  in
  in_chars enthalten sind. Wenn ja, wird 0 zurÅckgegeben.  Ansonsten wird
  die Position des ersten Zeichens in  s  zurÅckgegeben,   das	nicht  in
  in_chars enthalten ist. }

PROCEDURE clean_in  (VAR s : STRING; in_chars  : STRING);	EXTERNAL;
PROCEDURE clean_out (VAR s : STRING; out_chars : STRING);	EXTERNAL;
  { clean_in entfernt alle Zeichen aus s, die nicht in in_chars enthalten
  sind. clean_out entfernt alle Zeichen in s, die in out_chars	enthalten
  sind. }

FUNCTION pos_end (look, source : STRING) : INTEGER;		EXTERNAL;
  { Genau wie die standardmÑûige  pos-Funktion	liefert pos_end die Posi-
  tion	von  look innerhalb  von source. Dabei	durchsucht pos allerdings
  source von vorne, wÑhrend  pos_end source von hinten durchsucht.  Tritt
  look nur einmal  in source auf, wÅrden  beide Funktionen also denselben
  Wert liefern.  Wird  look nicht gefunden, dann wird 0 als Funktionswert
  ermittelt. }

PROCEDURE str_end (look, source : STRING; include_look : BOOLEAN;
		   VAR dest	: STRING);			EXTERNAL;
  { Diese Prozedur liefert in dest einen Teilstring am	Ende  von  source
  zurÅck. Beginnen tut dieser Teilstring mit look, wenn include_look TRUE
  war,	sonst unmittelbar hinter look. Tritt die Kette look  mehrfach  in
  source auf, so wird stets die letzte Kette im String betrachtet.  Tritt
  look	nicht in  source auf, wird ein String der LÑnge 0 zurÅckgereicht.
  Die Prozedur findet z.B. Anwendung beim  isolieren  des Dateinamens aus
  einem Pfad: source:=path, look:='\', include_look:=FALSE . }

FUNCTION str_greater (s1, s2 : STRING) : BOOLEAN;		EXTERNAL;
  { Die Funktion  liefert TRUE,  wenn s1  lexikalisch  grîûer als s2 ist.
  Dabei werden die deutschen Umlaute und esszett (Atari-interne  Darstel-
  lung) wie A, O, U bzw. S behandelt.  Kleinbuchstaben werden  wie  Groû-
  buchstaben behandelt. }

