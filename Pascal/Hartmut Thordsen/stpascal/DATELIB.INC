{ date library - Copyright Hartmut Thordsen, V2.2 Dezember 1987 }

{ GÅltigkeitsbereich der Routinen: 1.3.1800 bis 28.2.2100

  Die interne Codierung eines Datums fÅr die Library-Routinen erfolgt als
  REAL in der Form dd.mmyyyy . Dabei kommt es nicht auf die Exaktheit der
  Mantisse auf den nicht verwendeten Stellen an.  Lediglich  die  Rundung
  der 8. Stelle der Mantisse noch das korrekte Jahr ergeben. }

PROCEDURE dmy_date (d, m, y : INTEGER; VAR date : REAL);	EXTERNAL;
PROCEDURE date_dmy (date : REAL; VAR d, m, y : INTEGER);	EXTERNAL;
  { dmy_date gibt das als Tag, Monat und  Jahr Åbergebene  Datum  in  der
  Form	dd.mmyyyy  zurÅck;  es	erfolgt  keine	PlausibilitÑtsprÅfung der
  Åbergebenen Werte. date_dmy ist die Umkehrfunktion. }

FUNCTION sysdate_date (sdate : INTEGER) : REAL; 		EXTERNAL;
FUNCTION date_sysdate (date : REAL) : INTEGER;			EXTERNAL;
  { sysdate_date  macht aus  einem im  System  bitweise  codierten  Datum
  (siehe GEMDOS-Funktionen) ein REAL mit der Form dd.mmyyyy; die Funktion
  date_sysdate codiert das Åbergebene Real-Datum fÅr's System. }

FUNCTION get_date : REAL;					EXTERNAL;
PROCEDURE set_date (date : REAL);				EXTERNAL;
  { get_date liefert das eingestellte Systemdatum in der Form dd.mmyyyy .
  set_date setzt das Systemdatum. }

FUNCTION julian_date (greg_date : REAL) : LONG_INTEGER; 	EXTERNAL;
FUNCTION gregorian_date (jul_date : LONG_INTEGER) : REAL;	EXTERNAL;
  { julian_date gibt das Julianische  Datum,  eine  fortlaufende Zahl der
  Tage seit  Anno Domini, zurÅck. gregorian_date formt daraus wieder  das
  julianische Datum in der Form dd.mmyyyy. Die Algorithmen zur Umwandlung
  von Gregorianischem und Julianischem Datum sind adaptiert aus: Hewlett-
  Packard HP-41C Users' Library Solutions "Calendars" }

FUNCTION date_difference (date1, date2 : REAL) : INTEGER;	EXTERNAL;
FUNCTION related_date (date : REAL; offset : INTEGER) : REAL;	EXTERNAL;
  { date_difference gibt die Differenz zwischen den beiden Daten in Tagen
  zurÅck; positiv, falls  date1  das jÅngere  Datum ist,  sonst  negativ;
  0, falls Differenz auûerhalb des Bereichs fÅr INTEGER.
  related_date liefert	das Datum  des Åberg. Datums  zzgl.  offset-viele
  Tage. offset kann auch einen negativen Wert haben. }

FUNCTION weekday (date : REAL) : INTEGER;			EXTERNAL;
  { gibt den Wochentag zurÅck, 0=Sonntag, 1=Montag usw. }

PROCEDURE weekday_str (wday, width : INTEGER; VAR s : STRING);	EXTERNAL;
  { weekday_str gibt in s den Wochentag deutsch geschrieben zurÅck;  wday
  muû  einen Wert zwischen 0 und 6 haben;   es	werden	genau width viele
  Zeichen ausgegeben (praktisch width=2); bei width=0 wird der	Wochentag
  ausgeschrieben (je nach Tag variable LÑnge) }

FUNCTION day_of_year (date : REAL) : INTEGER;			EXTERNAL;
FUNCTION doy_date (doy, year : INTEGER) : REAL; 		EXTERNAL;
  { day_of_year gibt die Zahl des Tages im Jahr, also eine Zahl  zwischen
  1 und 366. doy_date ist die Umkehrfunktion und ermittelt das Datum  des
  doy-ten Tages im Jahre year in der Form dd.mmyyyy . }

FUNCTION remaining_days (date : REAL) : INTEGER;		EXTERNAL;
  { gibt die Anzahl der noch in diesem Jahr verbliebenen Tage zurÅck }

FUNCTION date_earlier (date1, date2 : REAL) : BOOLEAN;		EXTERNAL;
  { TRUE, wenn date1 Ñlter ist als date2 }

FUNCTION date_equal (date1, date2 : REAL) : BOOLEAN;		EXTERNAL;
  { TRUE, wenn date1 und date2 gleich sind.  Der  direkte  Vergleich  der
  Reals kann wegen Rundungsfehlern FALSE ergeben. }

FUNCTION date_future (date : REAL) : BOOLEAN;			EXTERNAL;
FUNCTION date_past (date : REAL) : BOOLEAN;			EXTERNAL;
  { date_future liefert TRUE, wenn date in der Zukunft	liegt,	date_past
  wenn date in der Vergangenheit liegt;  beide Funktionen geben FALSE zu-
  rÅck, wenn das Systemdatum Åbergeben wurde. }

FUNCTION date_ok (date : REAL) : BOOLEAN;			EXTERNAL;
  { date_ok liefert TRUE, wenn das  Åbergebene Datum der  Form	dd.mmyyyy
  auch tatsÑchlich einem Kalenderdatum	entspricht. Andernfalls wird  der
  Wert FALSE zurÅckgegeben. }

FUNCTION str_date (s : STRING; VAR date : REAL) : BOOLEAN;	EXTERNAL;
  { str_date erzeugt aus dem  Åbergebenen  String s  ein  Real-Datum  der
  Form dd.mmyyyy . s darf nur aus Ziffern und den Zeichen '.' und '/' be-
  stehen und muû in einem der folgenden Formate vorliegen:
	ddmmyy	     Neben den Zeichen muû  auch das Format stimmen. Aus-
	ddmmyyyy     serdem wird die PlausibilitÑt geprÅft (Ist das Datum
	dd.mm.yy     Åberhaupt ein zulÑssiges Kalenderdatum?). Wenn alles
	dd.mm.yyyy   soweit stimmt, steht das Ergebnis in date; die Funk-
	yy/mm/dd     tion hat den Wert TRUE. Bei Fehlern ist der Wert der
	yyyy/mm/dd   Funktion FALSE; date bleibt dann unverÑndert.
  Die Zeichen '.' und '/' haben Trennfunktion. D.h. bei  diesen  Formaten
  kann	die  Anzahl  der Stellen fÅr  dd, mm oder yyyy von zwei bzw. vier
  abweichen; der Wertebereich fÅr  Integer  darf  jedoch  nicht  verletzt
  werden. Auf eine Zahl kleiner 100 fuer das Jahr wird die Konstante 1900
  intern addiert. }

PROCEDURE date_str (date : REAL; width : INTEGER;
		    VAR s : STRING);				EXTERNAL;
  { erzeugt in s einen String der Laenge width mit dem Datum in  der Form
	width <= 2  :
   3 <= width <= 5  :  dd.	      Die Eintragung erfolgt linksbÅndig.
   6 <= width <= 7  :  dd.mm.
   8 <= width <= 9  :  dd.mm.yy
  10 <= width	    :  dd.mm.yyyy  }

