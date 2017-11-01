{ time library - Copyright Hartmut Thordsen, V2.2 Dezember 1987 }

{ Die interne Codierung einer Zeit fÅr die Library-Routinen  erfolgt  als
  REAL in der Form hh.mmss . Negative Werte sind zulÑssig. Es kommt nicht
  auf die Exaktheit der Mantisse auf den nicht	verwendeten  Stellen  an.
  Vielmehr muû lediglich die Rundung der 6. Stelle der Mantisse noch  die
  korrekten Sekunden ergeben. }

PROCEDURE hms_time (h, m, s : INTEGER; VAR t : REAL);		EXTERNAL;
PROCEDURE time_hms (t : REAL; VAR h, m, s : INTEGER);		EXTERNAL;
  { hms_time gibt die mit Stunden, Minuten und Sekunden  Åbergebene  Zeit
  in der Form hh.mmss zurueck; es erfolgt keine PlausibilitÑtsprÅfung der
  Åbergebenen Werte. time_hms ist die Umkehrfunktion. Negative Vorzeichen
  der  Åbergebenen  Werte  werden ignoriert; die Ergebniswerte sind stets
  positiv. }

FUNCTION systime_time (stime : INTEGER) : REAL; 		EXTERNAL;
FUNCTION time_systime (time : REAL) : INTEGER;			EXTERNAL;
  { systime_time macht aus einer im System bitweise codierten Zeit (siehe
  GEMDOS-Funktionen) ein REAL mit der Form hh.mmss . Die Funktion  time_-
  systime codiert das Åbergebene Real-Datum fÅr's System. }

FUNCTION get_time : REAL;					EXTERNAL;
PROCEDURE set_time (time : REAL);				EXTERNAL;
  { get_time liefert die eingestellte Systemzeit in der Form hh.mmss .
  set_time setzt die Systemzeit. }

FUNCTION time_dec (time : REAL) : REAL; 			EXTERNAL;
FUNCTION dec_time (dec : REAL) : REAL;				EXTERNAL;
  { time_dec erzeugt aus der  Åbergebenen Zeit der Form hh.mmss eine  De-
  zimalzahl, d.h. die Minuten und Sekunden werden  als	gebrochener  Teil
  einer Stunde auf den Nachkommastellen berechnet.  dec_time ist die  Um-
  kehrfunktion. }

FUNCTION add_time (time1, time2 : REAL) : REAL; 		EXTERNAL;
FUNCTION sub_time (time1, time2 : REAL) : REAL; 		EXTERNAL;
  { add_time liefert die Summe der beiden Zeiten in der Form hh.mmss  als
  Funktionswert; sub_time hat time1 - time2 als Ergebnis. }

FUNCTION time_ok (time : REAL) : BOOLEAN;			EXTERNAL;
  { time_ok liefert TRUE, wenn die  Åbergebene Zeit der Form hh.mmss auch
  einer Zeit entspricht, d.h. mm und ss mÅssen	zwischen 0 und 59 liegen.
  Andernfalls wird der Wert FALSE zurÅckgegeben. Der Wert fÅr die Stunden
  ist beliebig, kann also auch grîûer als 23 sein. }

FUNCTION str_time (s : STRING; VAR time : REAL) : BOOLEAN;	EXTERNAL;
  { str_time erzeugt aus dem  Åbergebenen  String s  eine Real-Zeit   der
  Form hh.mmss . s darf nur aus Ziffern und den Zeichen  ':' und  '.' be-
  stehen und muû in einem der folgenden Formate vorliegen:
	hhmm	     Neben den Zeichen muû  auch das Format stimmen. Aus-
	hh:mm	     serdem wird die PlausibilitÑt  geprÅft  (siehe  auch
	hhmmss	     time_ok). Wenn alles stimmt, steht das  Ergebnis  in
	hh:mm:ss     time; die Funktion hat den Wert  TRUE.  Bei  Fehlern
	mm.ss	     ist der Wert der Funktion FALSE;  time  bleibt  dann
		     unverÑndert.
  Die Zeichen '.' und ':' haben Trennfunktion. D.h. bei  diesen  Formaten
  kann die Anzahl der Stellen fÅr  hh, mm oder ss von zwei abweichen; der
  Wertebereich fÅr Integer darf jedoch nicht verletzt werden. }

PROCEDURE time_str (time : REAL; width : INTEGER; VAR s : STRING);
								EXTERNAL;
  { erzeugt in s einen String der LÑnge width mit der Zeit in der Form
	width <= 1  :
   2 <= width <= 4  :  hh	   Die Zeit wird linksbÅndig eingetragen.
   5 <= width <= 7  :  hh:mm
   8 <= width	    :  hh:mm:ss  }

