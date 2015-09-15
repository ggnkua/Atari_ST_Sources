{////////////////////////////////////////////////////////////////////////}
{/									/}
{/  UNI - DRUCK : Ermîglicht den Ausdruck von ASCII - Dateien auf bis	/}
{/		  zu 3 verschiedenen Druckern. Durch eine Anpassungsta- /}
{/		  belle lassen sich beliebige Drucker leicht installie- /}
{/		  ren. Dabei kînnen wahlweise auch Zeilennummern, z.B.	/}
{/		  zum Druck von Programmquellen, hinzugefÅgt werden.	/}
{/									/}
{/  Dieses PUBLIC DOMAIN Programm wurde 1987 mit ST Pascal plus von CCD /}
{/  entwickelt, 1988, 1989 und 1990 erweitert von			/}
{/						Erhard Schwartz 	/}
{/						Isaraustraûe 8		/}
{/  Version vom 19.03.1990		    D - 8192 Geretsried 1	/}
{/									/}
{/									/}
{/  énderungen am Programm ab Version : 				/}
{/									/}
{/  1.20 - Umstellung auf ST Pascal Plus Version 2.0			/}
{/  1.21 - Mehr Farbenpracht fÅr die vernachlÑssigten Color - Fans	/}
{/  2.00 - UnterstÅtzt nun auch Draft- oder NLQ- Schrift		/}
{/	 - Ausgabe nun auch Åber die serielle Schnittstelle mîglich	/}
{/	 - UnterstÅtzt nun nicht mehr nur die deutschen sondern auch	/}
{/	   alle anderen Sonderzeichen					/}
{/	 - Eigene Routinen zur Bearbeitung der Druckdatei, damit nun	/}
{/	   auch Tempus-Flieûtexte problemlos ausgedruckt werden 	/}
{/	 - Anzahl der Druckzeilen pro Seite ist frei wÑhlbar		/}
{/	 - Formfeed nach Druckende kann nun auch abgeschaltet werden	/}
{/	 - Alle Einstellungen sind Åber die Druckeranpassung vorwÑhlbar /}
{/	 - VollstÑndige Kontrolle Åber den Drucker, d.h. kein Datenver- /}
{/	   lust mehr bei Papierende, Offline etc., wenn die Unterbre-	/}
{/	   chung mehr als 15 Sekunden dauert				/}
{/  2.10 - Anfang und Ende des Drucks kann auf Seiten oder Zeilen	/}
{/	   bezogen frei gewÑhlt werden					/}
{/	 - Doppelklick bzw. Shift-, Alternate- oder Control-Taste bei	/}
{/	   PfeilkÑstchen macht bis zu 10 Schritte			/}
{/	 - Sucht nach allen Druckertreibern UNI*.PRn zuerst im		/}
{/	   aktuellen Verzeichnis					/}
{/	 - Streik bei geringer Auflîsung				/}
{/									/}
{////////////////////////////////////////////////////////////////////////}

{$U10}	{ Vorsichtshalber 10k Speicher zurÅck ans TOS	}
{$D-}	{ Ohne Debug					}
{$P-}	{ Keine öberprÅfung von Zeigern 		}
{$R-}	{ Keine UnterbereichsprÅfung			}
{$T+}	{	öberprÅfung von Heap und Stack		}

PROGRAM UNI_DRUCK_by_ERHARD_SCHWARTZ;

{$I GEM.INC}	{ GEM.INC enthÑlt die Dateien GEMCONST.PAS mit vorange- }
		{ stelltem CONST, GEMTYPE.PAS mit vorangestelltem TYPE	}
		{ sowie GEMSUBS.PAS. Warum also auf 3 Dateien verteilt, }
		{ wenns ab ST-Pascal Plus V. 2.0 auch mit einer geht ?	}

{$I TRIX.INC}	{ Gleiches Verfahren wie mit den GEM - Routinen 	}

CONST

(***********************************************)
(**					      **)
(**)	VERSION 	= '2.10';	     (**)
(**					      **)
(***********************************************)

{$I UNIDRUCK.I	}	{ Includefile aus Resource Construction }

	MUSTER		= 5;			{ Hintergrundmuster }
	TIMEOUT 	= 15;
	CONV_MIN	= #$80; 		{ Konvertierungstabelle }
	CONV_MAX	= #$FF;
	ES_BUFL 	= 512;
	D_AUFFORD	= ' Datei ...';
	RSC_DATEI	= 'UNIDRUCK.RSC';	{ Name der Resource-Datei }
	NUM_TEXT_ABST	= 4;			{ Abstand Numerierung/Text }

TYPE
	c_string_14	= PACKED ARRAY [ 1 .. 14 ] OF CHAR;

	ptr255		= ^str255;

	dta_buffer	= PACKED RECORD
				   reserved  : PACKED ARRAY [0..19] OF CHAR;
				   reserved2 : BYTE;
				   attribut  : BYTE;
				   uhrzeit   : INTEGER;
				   datum     : INTEGER;
				   laenge    : LONG_INTEGER;
				   name      : c_string_14;
				 END;

	es_buf_typ	= PACKED ARRAY [ 1.. ES_BUFL ] OF CHAR;

	es_text_typ	= RECORD
			    ch		: CHAR;
			    handle	: INTEGER;
			    len 	: LONG_INTEGER;
			    eoln	: BOOLEAN;
			    eof 	: BOOLEAN;
			    error	: INTEGER;
			    count	: LONG_INTEGER;
			    buf_ptr	: INTEGER;
			    buflen	: INTEGER;
			    bufl2	: INTEGER;
			    buf 	: es_buf_typ;
			    buf2	: es_buf_typ;
			  END; { record es_text_typ }

	es_text 	= ^es_text_typ;

	steuerseq_typ	= ( p_dummy_0,
			    p_name, p_lrand, p_init, p_exit,
			    p_pica_draft, p_pica_nlq,
			    p_elite_draft, p_elite_nlq,
			    p_schmal_draft, p_schmal_nlq,
			    p_dummy_f);

	voreinst_typ	= ( p_seitlaen,   p_tab,	 p_v_lrand,
			    p_v_device,   p_v_breite,	 p_v_quali,
			    p_v_numer,	  p_v_perf,	 p_v_uebe,
			    p_v_formf,
			    p_pica_breit, p_elite_breit, p_schmal_breit );

	aufloesung	= ( LOW_RES, MID_RES, HIGH_RES);

VAR
	t		: str255;
	mist		: INTEGER;
	m_boo		: BOOLEAN;		{ Boolscher Mist }
	device		: INTEGER;
	timer_200	: ^LONG_INTEGER;
	max_pr_name,				{ LÑnge des Druckernamens }
	max_pfad,				{ LÑnge des Pfadnamens }
	max_edit	: INTEGER;		{ LÑnge des Editfeldes }
	x, y, w, h	: INTEGER;		{ Objektkoordinaten }
	st_x, st_y,
	st_w, st_h	: INTEGER;		{ Startwerte fÅr Grow-Box }
	dl_x, dl_y,
	dl_w, dl_h	: INTEGER;		{ Maûe des Haupt-Dialogs }
	id_x, id_y,
	id_w, id_h	: INTEGER;		{ Maûe des Info-Dialogs }
	cd_x, cd_y,
	cd_w, cd_h	: INTEGER;		{ Maûe des Copyright-Dial. }

	dta		: dta_buffer;
	drive		: CHAR;
	c_path		: c_string;
	vorschlag,
	pfad		: STRING;
	q_laenge	: LONG_INTEGER;

	p_string	: ARRAY[p_dummy_0..p_dummy_f]OF ARRAY[1..3]OF ptr255;
	p_convert	: ARRAY[CONV_MIN..CONV_MAX]  OF ARRAY[1..3]OF ptr255;
	p_vor		: ARRAY[ p_seitlaen .. p_schmal_breit ]
			    OF ARRAY[ 1 .. 3 ] OF INTEGER;

	tab_weite,				{ Drucker - Parameter }
	randbreite,
	zeilenbreite,
	seitenlaenge,
	letzte_antwort,
	drucker 	: INTEGER;
	erste_zeile,
	letzte_zeile	: LONG_INTEGER;

	leer,					{ Mehrfach-EintrÑge }
	space		: ptr255;

	dl,					{ Hauptdialog }
	id,					{ Info-Dialog }
	cd		: dialog_ptr;		{ Copyright-Dialog }

	fenster,
	f_x, f_y,
	f_w, f_h	: INTEGER;		{ Fenster-Daten }
	fenstername	: window_title;


{///////  DEKLARATION DER UNTERPROGRAMME  //////////////////////////////////}

PROCEDURE drucke_zeichen ( dev: INTEGER; ch : CHAR);	BIOS	(3);
FUNCTION  drucker_bereit ( dev : INTEGER) : BOOLEAN;	BIOS	(8);
FUNCTION  kbshift ( mode : INTEGER) : INTEGER;		BIOS	(11);
FUNCTION  getres : aufloesung;				XBIOS	(4);
PROCEDURE fsetdta ( VAR dta : dta_buffer );		GEMDOS	($1A);
FUNCTION  switch_super(s:LONG_INTEGER):LONG_INTEGER;	GEMDOS	($20);


{///////   équivalent der Pascal-Prozedur "get"   //////////////////////////}

PROCEDURE es_get ( VAR f : es_text );

TYPE	dta_ptr_typ	= ^dta_buffer;

VAR	geholt	: LONG_INTEGER;

  FUNCTION f_read( h : INTEGER; cnt : LONG_INTEGER; VAR b : es_buf_typ)
					: LONG_INTEGER; 	GEMDOS($3F);
BEGIN
  WITH f^
  DO BEGIN
       IF buf_ptr >= buflen			{ Ist am Pufferende }
       THEN BEGIN
	      buf := buf2;			{ Puffer 2 nach 1 kopieren }
	      count := count + buflen;		{ bereits abgearbeitet }
	      buf_ptr := buf_ptr - buflen;	{ Zeiger zurÅcksetzen }
	      buflen := bufl2;
	      IF len > count + buflen		{ Datei nicht leergelesen }
	      THEN BEGIN			{ Puffer 2 fÅllen }
		     geholt := f_read( handle, bufl2, buf2); { Leseversuch }
		     IF geholt < 0		{ Fehler }
		     THEN BEGIN
			    error := geholt;
			    len := count + buflen;	{ Ende neu setzen }
			  END
		     ELSE IF geholt < bufl2	{ Dateiende }
			  THEN bufl2 := geholt;
		   END; { Puffer 2 neu gefÅllt }
	    END; { Puffer muûte neu eingerichtet werden }

       buf_ptr := buf_ptr + 1;		{ Zeiger erhîhen }
       IF count + buf_ptr > len 	{ letztes Zeichen }
       THEN BEGIN
	      eof := TRUE;
	      eoln := TRUE;
	    END;
       IF (buf[buf_ptr] = #$0A) AND (buf[buf_ptr+1] = #$0D)
				AND ((count + buf_ptr + 1) <= len)
       THEN BEGIN
	      buf[buf_ptr]   := #$0D;		{ Vertauschen }
	      buf[buf_ptr+1] := #$0A;
	    END;
       IF (buf[buf_ptr] = #$0D) AND (buf[buf_ptr+1] = #$0A)
				AND ((count + buf_ptr + 1) <= len)
       THEN BEGIN
	      buf_ptr := buf_ptr + 1;	{ CR Åberspringen }
	      buf[buf_ptr]   := #$0A;
	    END;
       IF buf[buf_ptr] = #$0A	      { Zeilenende }
       THEN eoln := TRUE;
       ch := buf[buf_ptr];
     END; { with }
END; { es_get }


{///////   équivalent der Pascal-Prozedur "readln"   ///////////////////////}

PROCEDURE es_readln ( VAR f : es_text);
BEGIN
  WHILE NOT ( (f^.ch = #$0A) OR f^.eof )
    DO es_get(f);				{ Lesen LF oder eof }
  IF NOT f^.eof
  THEN BEGIN
	 f^.eoln := FALSE;
	 es_get(f);
       END;
END; { es_readln }


{///////   équivalent der Pascal-Prozedur "close"   ////////////////////////}

PROCEDURE es_close ( VAR f : es_text);
  PROCEDURE f_close( h : INTEGER);				GEMDOS($3E);
BEGIN
  f_close( f^.handle);
  dispose(f);
  f := NIL;
END; { es_close }


{///////   équivalent der Pascal-Prozedur "reset"   ////////////////////////}

PROCEDURE es_reset ( VAR f : es_text; name : STRING);

TYPE	dta_ptr_typ	= ^dta_buffer;

VAR	c_path		: c_string;
	geholt		: LONG_INTEGER;
	dta_ptr 	: dta_ptr_typ;

  FUNCTION f_getdta : dta_ptr_typ;				GEMDOS($2F);
  FUNCTION f_sfirst( VAR p : c_string; att:INTEGER) : INTEGER;	GEMDOS($4E);
  FUNCTION f_open( VAR p : c_string; att : INTEGER) : INTEGER;	GEMDOS($3D);
  FUNCTION f_read( h : INTEGER; cnt : LONG_INTEGER; VAR b : es_buf_typ)
					: LONG_INTEGER; 	GEMDOS($3F);
BEGIN
  new(f);
  WITH f^ DO BEGIN			{ Voreinstellungen }
	       ch	:= ' ';
	       handle	:= -321;
	       len	:= 0;
	       eoln	:= TRUE;
	       eof	:= TRUE;
	       error	:= 0;
	       buf_ptr	:= ES_BUFL;
	       buflen	:= ES_BUFL;
	       bufl2	:= ES_BUFL;
	     END; { with }

  PtoCstr( name, c_path);
  IF f_sfirst( c_path, $00) = NO_ERROR
  THEN BEGIN
{$P-}
	 dta_ptr := f_getdta;
	 f^.len := dta_ptr^.laenge;		{ LÑnge ermitteln }
{$P=}
	 f^.handle := f_open( c_path, $00);	{ Zum Lesen îffnen }
	 IF (f^.handle > 0) AND (f^.len > 0) THEN WITH f^
	 DO BEGIN			{ Puffer 2 fÅllen }
	      eoln := FALSE;
	      eof  := FALSE;

	      geholt := f_read( handle, bufl2, buf2);	{ Leseversuch }
	      IF geholt < 0				{ Fehler }
	      THEN BEGIN
		     error := geholt;
		     len := 0;
		     eof := TRUE;
		     eoln := TRUE;
		   END
	      ELSE IF geholt < bufl2			{ Dateiende }
		   THEN bufl2 := geholt;
	      count := -buflen;
	      es_get(f);
	    END; { Datei ist geîffnet, with gilt }
       END; { Datei existiert }
END; { es_reset }

{///////   Ermittelt das aktuelle Laufwerk   ///////////////////////////////}

FUNCTION get_drive : CHAR;
  FUNCTION dgetdrv : INTEGER; GEMDOS ($19);
BEGIN get_drive := chr( dgetdrv + 65 ); END;


{//////   Ermittelt den aktuellen Pfad	 ///////////////////////////////////}

FUNCTION get_path ( VAR path : c_string ) : INTEGER;
  FUNCTION dgetpath ( VAR path:c_string; drv:INTEGER ):INTEGER; GEMDOS($47);
BEGIN
  get_path := dgetpath( path, 0);	{ 0= Pfad des aktuellen Laufwerks }
END;


{///////   Analysiert einen Dateipfad	////////////////////////////////////}

PROCEDURE analyze_path( VAR path, name, extension : STRING);
VAR	i, len, punkt : INTEGER;
BEGIN
  len	:= length( path);
  IF len = 0
  THEN BEGIN name := ''; extension := '' END	{ Leerstring als Pfad }
  ELSE BEGIN
	 i     := len;
	 punkt := 0;
	 LOOP
	   IF path[i] = '.' THEN punkt := i;
	 EXIT IF ( path[i] = '\' ) OR ( i = 1 );
	   i := i - 1;
	 END; { loop }
	 IF punkt > 0
	 THEN extension := copy( path, punkt + 1, len - punkt)
	 ELSE BEGIN
		extension := '';
		punkt := len + 1;
	      END;
	 IF i = 1 THEN i := 0;		{ gleiche ZÑhlweise garantieren }
	 name  := copy( path, i + 1, punkt - i - 1);
       END; { Pfad war vernÅnftig }
END; { analyze_path }


{///////   Wandelt einen Buchstaben in einen Groûbuchstaben um	 ///////////}

FUNCTION upcase ( ch : CHAR ) : CHAR;
BEGIN
  IF ( ch >= 'a') AND ( ch <= 'z' )
  THEN upcase := chr( ord( ch) - 32 )
  ELSE CASE ch OF
	 'Ñ'  : upcase := 'é';
	 'î'  : upcase := 'ô';
	 'Å'  : upcase := 'ö';
	 ELSE : upcase := ch;
       END; { case }
END; { upcase }


{///////   Ermittelt, ob eine Datei existiert	////////////////////////////}

FUNCTION exist( filnam : str255 ) : BOOLEAN;
VAR	c_path	: c_string;
  FUNCTION fsfirst ( VAR p : c_string; att:INTEGER) : INTEGER;	GEMDOS($4E);
BEGIN
  PtoCstr( filnam, c_path);			{ Sucht nur nach }
  exist := fsfirst( c_path, $00) = NO_ERROR;	{ 'ordentlichen' Dateien }
END; { exist }


{///   ERMITTELT DEN TEXT EINES DIALOG-OBJEKTS DER RESOURCE   //////////////}

PROCEDURE get_rsc_str( dialog:dialog_ptr; index:INTEGER; VAR pstr:str255);
VAR	i	: INTEGER;
	ptr	: ^c_string;
BEGIN
  CASE	dialog^[index].ob_type OF
	G_STRING,
	G_TITLE,
	G_BUTTON	: ptr := dialog^[index].ob_spec.str;
	G_TEXT,
	G_BOXTEXT,
	G_FTEXT,
	G_FBOXTEXT	: ptr := dialog^[index].ob_spec.info^.te_ptext;
	G_BOXCHAR	: BEGIN
			    ptr := NIL;
			    pstr[0] := #1;
			    pstr[1]:=chr(shr(dialog^[index].ob_spec.thick
						& $FF00, 8));
			  END;
	OTHERWISE	: BEGIN 		{ Objekt hat keinen Text }
			    ptr  := NIL;
			    pstr := '???';
			  END;
  END; { case }

  IF ptr <> NIL
  THEN BEGIN			{ C-String selber kopieren, da RSC auch }
	 i := -1;		{ auf ungeraden Adressen beginnen kann }
	 LOOP			{ und Routine aus PASTRIX dann streikt }
	   i := succ(i);
	 EXIT IF (ptr^[i] = #0) OR (i > MAX_C_STRING);
	   pstr[i+1] := ptr^[i];
	 END; { loop }
	 pstr[0] := chr(i);	{ LÑnge des Strings einsetzen }
       END;
END; { get_rsc_str }


{///   SETZT DEN TEXT EINES DIALOG-OBJEKTS DER RESOURCE   //////////////////}

PROCEDURE set_rsc_str( dialog : dialog_ptr; index : INTEGER; pstr : str255);
VAR	i	: INTEGER;
	ptr	: ^c_string;
BEGIN
  CASE	dialog^[index].ob_type OF
	G_STRING,
	G_TITLE,
	G_BUTTON	: ptr := dialog^[index].ob_spec.str;
	G_TEXT,
	G_BOXTEXT,
	G_FTEXT,
	G_FBOXTEXT	: ptr := dialog^[index].ob_spec.info^.te_ptext;
	G_BOXCHAR	: BEGIN
			    ptr := NIL;
			    IF pstr[0] = #0 THEN pstr[1] := #0;
			    dialog^[index].ob_spec.thick :=
				dialog^[index].ob_spec.thick
					| shl(ord(pstr[1]), 8);
			  END;
	OTHERWISE	: ptr := NIL;		{ Objekt hat keinen Text }
  END; { case }
				{ P-String selber kopieren, da RSC auch }
  IF ptr <> NIL 		{ auf ungeraden Adressen beginnen kann }
  THEN BEGIN			{ und Routine aus PASTRIX dann streikt }
	 FOR i := 1 TO length(pstr) DO
	   ptr^[i-1] := pstr[i];
	 ptr^[length(pstr)] := #0;	   { Nullbyte als Ende }
       END;
END; { set_rsc_str }


{///////  Schaltet die Radio-Buttons um  ///////////////////////////////////}

PROCEDURE switch_radio( dialog : dialog_ptr; btn1, btn2, btn3 : INTEGER;
			select : INTEGER; redraw : BOOLEAN);
VAR	btn		: ARRAY[1..3] OF INTEGER;
	i,
	state_alt,
	state_neu	: INTEGER;
BEGIN
  IF select IN [1..3]			{ Ist der Wert zulÑssig ? }
  THEN BEGIN
	 btn[1] := btn1;		{ ja, also Werte Åbernehmen }
	 btn[2] := btn2;
	 btn[3] := btn3;
	 IF btn[select] > NONE		{ nur arbeiten, wenn Objekt da ist }
	 THEN FOR i := 1 TO 3 DO
	      BEGIN
		IF btn[i] > NONE THEN
		BEGIN
		  state_alt := obj_state( dialog, btn[i]);
		  IF i = select
		  THEN state_neu := state_alt | SELECTED
		  ELSE state_neu := state_alt &~SELECTED;
		  IF state_neu <> state_alt
		  THEN obj_setstate( dialog, btn[i], state_neu, redraw);
		END; { Objekt war da }
	      END; { for }
       END; { select war auûerhalb des Bereichs }
END; { switch_radio }


{///////  FORWARD-DEKLARATIONEN  ///////////////////////////////////////////}

PROCEDURE neuer_wert( dialog : dialog_ptr;
		      welcher, wert : INTEGER; zeichnen : BOOLEAN); FORWARD;


{///////  LIEST EINE ZAHL AUS EINEM EDITFELD  //////////////////////////////}

FUNCTION lese_zahl( d : dialog_ptr; index : INTEGER;
			VAR zahl : LONG_INTEGER)	: BOOLEAN;

VAR	x, y, w, h	: INTEGER;

BEGIN
  zahl := -LONG_MAXINT; 				{ Auch als Flag }
  get_rsc_str( d, index, t);				{ String holen }
  IF length( t) > 0
  THEN BEGIN
	 readv( t, zahl);
	 writev( t, zahl : max_edit);
	 set_rsc_str( d, index, t);
	 obj_size( d, index, x, y, w, h);
	 obj_draw( d, index, NONE, x, y, w, h);
	 lese_zahl := TRUE;
       END
  ELSE lese_zahl := FALSE;

END; { lese_zahl }


{///////  ERMITTELN EINIGER STARTWERTE	////////////////////////////////////}

PROCEDURE analysiere_dialogfeld;

BEGIN
  get_rsc_str( dl, DATEINAM, t);		{ Max. LÑnge des Pfads }
  max_pfad := length(t);
  get_rsc_str( dl, LPTR1BTN, t);		{ Max. LÑnge der Dr.-Namen }
  max_pr_name := length(t);
  get_rsc_str( dl, STARTNUM, t);		{ Max. LÑnge des Editfelds }
  max_edit := length(t);

  obj_size( dl, COPYINFO, st_x, st_y, st_w, st_h);	{ Start Growbox }
END; { analysiere_dialogfeld }


{///////  INITIALISIERUNG EINIGER STARTWERTE  //////////////////////////////}

PROCEDURE initialisiere_dialogfeld;

BEGIN
  drucker	:= 1;
  tab_weite	:= p_vor[ p_tab,	drucker];
  randbreite	:= p_vor[ p_v_lrand,	drucker];
  zeilenbreite	:= p_vor[ p_pica_breit, drucker];
  seitenlaenge	:= p_vor[ p_seitlaen,	drucker];

  device := 0; (* p_vor[ p_v_device, drucker] = 2 *)	{ Centronics }
  IF p_vor[ p_v_device, drucker] = 1 THEN device := 1;	{ RS 232 }

  neuer_wert( dl, TABWEITE, tab_weite,	  FALSE);
  neuer_wert( dl, RANDBREI, randbreite,   FALSE);
  neuer_wert( dl, ZEILBREI, zeilenbreite, FALSE);
  neuer_wert( dl, SEITLAEN, seitenlaenge, FALSE);

  set_rsc_str( dl, VERSIONR, VERSION);
  set_rsc_str( id, VERSIINF, VERSION);
  set_rsc_str( cd, INFVERSI, VERSION);
  set_rsc_str( dl, DATEINAM, D_AUFFORD);

  writev( t, 1 : max_edit);			{ Edit-Felder herrichten }
  set_rsc_str( dl, STARTNUM, t);
  t := '999999999999999';				{ lauter 9er }
  t[0] := chr( max_edit);				{ LÑnge abschneiden }
  set_rsc_str( dl, ENDENUMM, t);

  switch_radio( dl, PARALLEL, SERIELLE, NONE, device + 1, FALSE);
				{ device = 0 fÅr parallel, 1 fÅr RS232 }

  switch_radio( dl, LPTR1BTN, LPTR2BTN, LPTR3BTN, 1, FALSE);
  switch_radio( dl, PICASCHR, ELITESCH, SCHMALSC, 1, FALSE);
  switch_radio( dl, NUMMERNE, NUMMERJA, NONE,	  1, FALSE);
  switch_radio( dl, PERFORJA, PERFORNE, NONE,	  1, FALSE);
  switch_radio( dl, UEBERSJA, UEBERSNE, NONE,	  2, FALSE);
  switch_radio( dl, FORMFEJA, FORMFENE, NONE,	  1, FALSE);
  switch_radio( dl, DRAFTSCH, NLQSCHRI, NONE,	  1, FALSE);
  switch_radio( dl, INSEITEN, INZEILEN, NONE,	  1, FALSE);

  drive := get_drive;
  mist	:= get_path( c_path);
  CtoPstr( c_path, vorschlag);
  vorschlag := concat( drive, ':', vorschlag, '\*.*');

  timer_200 := ptr_long_integer( $4BA); { Zeiger auf TaktzÑhler setzen }
END; { initialisiere_dialogfeld }


{///////  DRUCKERVOREINSTELLUNGEN öBERNEHMEN  //////////////////////////////}

PROCEDURE neuer_drucker( welcher_knopf : INTEGER );
BEGIN
  CASE welcher_knopf OF
    LPTR1BTN : drucker := 1;
    LPTR2BTN : drucker := 2;
    LPTR3BTN : drucker := 3;
  END; { case }
				{ eventuell Voreinstellungen Åbernehmen }
  switch_radio(dl,PICASCHR,ELITESCH,SCHMALSC,p_vor[p_v_breite,drucker],TRUE);
  switch_radio(dl,DRAFTSCH,NLQSCHRI,NONE,    p_vor[p_v_quali, drucker],TRUE);
  switch_radio(dl,NUMMERJA,NUMMERNE,NONE,    p_vor[p_v_numer, drucker],TRUE);
  switch_radio(dl,PERFORJA,PERFORNE,NONE,    p_vor[p_v_perf,  drucker],TRUE);
  switch_radio(dl,UEBERSJA,UEBERSNE,NONE,    p_vor[p_v_uebe,  drucker],TRUE);
  switch_radio(dl,FORMFEJA,FORMFENE,NONE,    p_vor[p_v_formf, drucker],TRUE);

  tab_weite	:= p_vor[ p_tab 	, drucker];
  randbreite	:= p_vor[ p_v_lrand	, drucker];
  seitenlaenge	:= p_vor[ p_seitlaen	, drucker];

  IF (obj_state( dl, PICASCHR) & SELECTED = SELECTED)
  THEN zeilenbreite  := p_vor[ p_pica_breit , drucker];
  IF (obj_state( dl, ELITESCH) & SELECTED = SELECTED)
  THEN zeilenbreite  := p_vor[ p_elite_breit , drucker];
  IF (obj_state( dl, SCHMALSC) & SELECTED = SELECTED)
  THEN zeilenbreite  := p_vor[ p_schmal_breit , drucker];


  IF p_vor[ p_v_device, drucker] = 2
  THEN device := 0				{ Centronics-Port }
  ELSE IF p_vor[ p_v_device, drucker] = 1	{ RS 232 }
       THEN device := 1;
  switch_radio( dl, PARALLEL, SERIELLE, NONE, device + 1, TRUE);
	{ Einstellung Åbernehmen; device = 0 fÅr parallel, 1 fÅr RS232 }

END; { neuer_drucker }


{///////  AUSWERTEN EINES STRINGS, DER EINE HEX-ZAHL ENTHéLT  //////////////}

FUNCTION hexstring_to_char( h : STRING; VAR wert : CHAR) : BOOLEAN;
VAR	i,
	z	: INTEGER;
	ch	: CHAR;
BEGIN { hexstring_to_char }
  z := 0;
  FOR i := 1 TO length( h)DO
  BEGIN
    ch := upcase ( h[i]);
    IF ch IN ['0'..'9']
    THEN z := 16 * z + ord( ch) - 48
    ELSE z := 16 * z + ord( ch) - 55;
  END;
  IF ( z >= 0 ) AND ( z <= 255 )
  THEN BEGIN
	 hexstring_to_char := TRUE;
	 wert := chr( z);
       END
  ELSE hexstring_to_char := FALSE;
END; { hexstring_to_char }


{///////  EINLESEN UND AUSWERTEN DER DRUCKERANPASSUNGSTABELLE  /////////////}

PROCEDURE werte_datei_aus( name : STRING; p_nr : INTEGER );
VAR	q	: TEXT;
	seq	: steuerseq_typ;
	wert	: STRING;
	str	: str255;
	n,
	i	: INTEGER;
	h	: STRING;
	ch	: CHAR;
	convert,
	stop	: BOOLEAN;
BEGIN
  reset( q, name);
  WHILE NOT eof( q)
  DO BEGIN
       i       := 0;
       h       := '';
       wert    := '';
       readln( q, str);
       IF str <> '' THEN
       REPEAT
	 i := i + 1;
	 IF str[i] IN ['0'..'9', 'a'..'f', 'A'..'F']
	 THEN BEGIN
		h := concat( h, str[i]);
	      END
	 ELSE BEGIN
		IF h <> ''
		THEN BEGIN
		       stop := NOT hexstring_to_char( h, ch);
		       IF NOT stop THEN wert := concat ( wert, ch);
		       h := '';
		     END;
	      END;
       UNTIL ( (i >= length( str)) OR stop OR
	       NOT ( str[i] IN ['0'..'9','a'..'f','A'..'F',' ',','] ) );
       IF h <> ''
       THEN BEGIN
	      stop := NOT hexstring_to_char( h, ch);
	      IF NOT stop THEN wert := concat ( wert, ch);
	    END;
       IF length( wert) >= 1
       THEN BEGIN
	      seq := p_dummy_0; 	{ Unmîglicher Startwert }
	      convert := FALSE;
	      CASE wert[1] OF
		#$00 : BEGIN		{ Namen setzen }
			 i := pos( '''', str) + 1;
			 n := length( str) - i;
			 IF n > max_pr_name THEN n := max_pr_name;
			 new( p_string[ p_name, p_nr] : n);
			 p_string[ p_name, p_nr]^ := copy( str, i, n);
			 i := pos( '''', p_string[ p_name, p_nr]^);
			 IF i > 0
			 THEN p_string[ p_name, p_nr]^[0] := chr(i-1);
		       END;
		#$05 : seq := p_lrand;
		#$1F : seq := p_init;
		#$21 : seq := p_exit;
		#$28 : seq := p_pica_draft;
		#$29 : seq := p_pica_nlq;
		#$2A : seq := p_elite_draft;
		#$2B : seq := p_elite_nlq;
		#$2C : seq := p_schmal_draft;
		#$2D : seq := p_schmal_nlq;

		#$50 : p_vor[ p_seitlaen     , p_nr] := ord( wert[2]);
		#$51 : p_vor[ p_tab	     , p_nr] := ord( wert[2]);
		#$52 : p_vor[ p_v_lrand      , p_nr] := ord( wert[2]);
		#$53 : p_vor[ p_pica_breit   , p_nr] := ord( wert[2]);
		#$54 : p_vor[ p_elite_breit  , p_nr] := ord( wert[2]);
		#$55 : p_vor[ p_schmal_breit , p_nr] := ord( wert[2]);

		#$60 : p_vor[ p_v_device     , p_nr] := ord( wert[2]);
		#$61 : p_vor[ p_v_breite     , p_nr] := ord( wert[2]);
		#$62 : p_vor[ p_v_quali      , p_nr] := ord( wert[2]);
		#$63 : p_vor[ p_v_numer      , p_nr] := ord( wert[2]);
		#$64 : p_vor[ p_v_perf	     , p_nr] := ord( wert[2]);
		#$65 : p_vor[ p_v_formf      , p_nr] := ord( wert[2]);
		#$66 : p_vor[ p_v_uebe	     , p_nr] := ord( wert[2]);

		OTHERWISE : IF (wert[1]>=CONV_MIN) AND (wert[1]<=CONV_MAX)
			    THEN convert := TRUE;
	      END; { case }

	      IF seq <> p_dummy_0	{ Steuerzeichen sind da }
	      THEN BEGIN
		     new( p_string[ seq, p_nr] : length(wert)-1);
		     p_string[ seq, p_nr]^ := copy( wert, 2,length(wert)-1);
		   END;

	      IF convert		{ Zeichenkonvertierung ist da }
	      THEN BEGIN
		     IF length(wert) > 1
		     THEN BEGIN 		{ Echte Konvertierung }
			    new( p_convert[wert[1],p_nr] : length(wert)-1 );
			    p_convert[wert[1],p_nr]^ :=
				      copy(wert,2,length(wert)-1);
			  END
		     ELSE p_convert[wert[1], p_nr] := space;	{ Space }
		   END;

	    END; { Es war mindestens ein Wert eingetragen }
     END; { while not eof }
  close( q);
					{ Kompatibel zur alten Version, }
  IF p_string  [ p_pica_nlq,   p_nr]^ = ''	{ wenn keine Angabe }
  THEN p_string[ p_pica_nlq,   p_nr] := p_string[ p_pica_draft,   p_nr];
  IF p_string  [ p_elite_nlq,  p_nr]^ = ''
  THEN p_string[ p_elite_nlq,  p_nr] := p_string[ p_elite_draft,  p_nr];
  IF p_string  [ p_schmal_nlq, p_nr]^ = ''
  THEN p_string[ p_schmal_nlq, p_nr] := p_string[ p_schmal_draft, p_nr];
END; { werte_datei_aus }


{///////  INITIALISIEREN DER DRUCKERANPASSUNGEN  ///////////////////////////}

PROCEDURE welche_drucker_sind_da;
VAR	index		: ARRAY[1..3] OF INTEGER;
	welcher 	: INTEGER;
	seq		: steuerseq_typ;
	vor_pfad,
	filnam		: STRING;
	ch		: CHAR;
BEGIN
  set_rsc_str( dl, LPTR1BTN, 'Drucker # 1');
  set_rsc_str( dl, LPTR2BTN, 'Drucker # 2');
  set_rsc_str( dl, LPTR3BTN, 'Drucker # 3');
  index[1]	:= LPTR1BTN;
  index[2]	:= LPTR2BTN;
  index[3]	:= LPTR3BTN;

  IF ( exist( 'UNI*.PR1')	    { Gibt es Treiber im Verzeichnis, }
	OR exist( 'UNI*.PR2')
	OR exist( 'UNI*.PR3') )
  THEN vor_pfad := ''			{ dann Treiber aus Verzeichnis }
  ELSE vor_pfad := 'PRINTER.UNI\';	{ ansonsten aus dem Ordner }

  FOR welcher := 3 DOWNTO 1 DO
  BEGIN
    FOR seq := p_name	TO p_schmal_nlq 	{ Erst keine Steuerzeichen }
      DO p_string[ seq, welcher] := leer;
    FOR ch  := CONV_MIN TO CONV_MAX		{ Erst das Zeichen selbst }
      DO p_convert[ ch, welcher] := NIL;

    p_vor[ p_seitlaen,	   welcher] := 65;
    p_vor[ p_tab,	   welcher] := 8;
    p_vor[ p_v_lrand,	   welcher] := 0;
    p_vor[ p_pica_breit,   welcher] := 80;
    p_vor[ p_elite_breit,  welcher] := 80;
    p_vor[ p_schmal_breit, welcher] := 80;

    p_vor[ p_v_device,	   welcher] := 2;	{ Centronics }
    p_vor[ p_v_breite,	   welcher] := 0;	{ keine énderung }
    p_vor[ p_v_quali,	   welcher] := 0;	{ keine énderung }
    p_vor[ p_v_numer,	   welcher] := 0;	{ keine énderung }
    p_vor[ p_v_perf,	   welcher] := 0;	{ keine énderung }
    p_vor[ p_v_uebe,	   welcher] := 0;	{ keine énderung }
    p_vor[ p_v_formf,	   welcher] := 0;	{ keine énderung }

    filnam := concat( vor_pfad, 'UNI*.PR', chr( welcher + 48) );
    IF exist( filnam) THEN werte_datei_aus( filnam, welcher);

    IF (p_string[ p_name, welcher]^ = '') AND (welcher = 1)
    THEN BEGIN					{ Sonderfall : }
	   t := 'ASCII';			{ kein Treiber gefunden }
	   new( p_string[ p_name, 1] : length(t));
	   p_string[ p_name, 1]^ := t;
	   new( p_convert[ 'Ñ', 1] : 1); p_convert[ 'Ñ', 1]^ := '{';
	   new( p_convert[ 'î', 1] : 1); p_convert[ 'î', 1]^ := '|';
	   new( p_convert[ 'Å', 1] : 1); p_convert[ 'Å', 1]^ := '}';
	   new( p_convert[ 'é', 1] : 1); p_convert[ 'é', 1]^ := '[';
	   new( p_convert[ 'ô', 1] : 1); p_convert[ 'ô', 1]^ := '\';
	   new( p_convert[ 'ö', 1] : 1); p_convert[ 'ö', 1]^ := ']';
	   new( p_convert[ 'û', 1] : 1); p_convert[ 'û', 1]^ := '~';
	   new( p_convert[ '›', 1] : 1); p_convert[ '›', 1]^ := '@';
	 END;

    IF p_string[ p_name, welcher]^ <> ''
    THEN BEGIN
	   set_rsc_str( dl, index[welcher],p_string[ p_name, welcher]^);
	   obj_setstate( dl, index[ welcher],( obj_state( dl,index[welcher])
			 & ~DISABLED ), FALSE);
	 END; { Druckername war angegeben }
  END; { die 3 Drucker abfragen }
END; { welche_drucker_sind_da }


{///////  ZEICHNEN EINES OBJEKTS, DAS EINEN ZAHLENWERT ENTHALTEN SOLL  /////}

PROCEDURE neuer_wert;  (* ( dialog : dialog_ptr;
			    welcher, wert : INTEGER; zeichnen : BOOLEAN); *)
VAR	wert_str : STRING;	{ Parameter sind in FORWARD-Deklaration }
BEGIN
  writev( wert_str, wert);
  set_rsc_str( dialog, welcher, wert_str);
  IF zeichnen
  THEN BEGIN
	 obj_size( dialog, welcher, x, y, w, h);
	 obj_draw( dialog, welcher, NONE, x, y, w, h);
       END; { neu gezeichnet }
END; { neuer_wert }


{///////  AUSMALEN DES FENSTERS MIT DEM HINTERGRUNDMUSTER  /////////////////}

PROCEDURE redraw_hintergrund( xc, yc, wc, hc : INTEGER);
VAR x, y, w, h : INTEGER;
BEGIN
  IF getres = HIGH_RES
  THEN paint_color( BLACK)
  ELSE paint_color( GREEN);	{ fÅr unsere Farbfreunde }
  paint_style( MUSTER);
  hide_mouse;
  first_rect( fenster, x, y, w, h);
  WHILE ( (w <> 0) OR (h <> 0) ) DO
  BEGIN 				{ Teile des Fensters sind sichtbar }
    IF rect_intersect( xc, yc, wc, hc, x, y, w, h)
    THEN BEGIN
	   set_clip( x, y, w, h);
	   paint_rect( x, y, w, h);
	 END; { ein Teil ist neu gezeichnet }
    next_rect( fenster, x, y, w, h);
  END; { sichtbare Teile }
  show_mouse;
END; { redraw_hintergrund }


{///////  ERZEUGEN EINES FENSTERS MIT MAXIMALER GRôSSE	//////////////////}

PROCEDURE unterlege_fenster;
BEGIN
  fenstername := '';		{ Eigenes groûes Fenster als Hintergrund }
				{ sonst Stîrung durch fremdes WM_REDRAW  }
  fenster := new_window( NONE, fenstername, 0, 0, 0, 0 );
  open_window ( fenster, 0, 0, 0, 0 );
  work_rect( fenster, f_x, f_y, f_w, f_h);
END; { unterlege_fenster }


{///   ERMITTELN OB MAUSKNOPF INNERHALB EINES RECHTECKS GEDRöCKT WURDE	 ///}

FUNCTION click_in_rechteck( x, y, w, h : INTEGER) : BOOLEAN;
VAR
	event,
	maus_x,
	maus_y,
	n_clicks,
	maus_status	: INTEGER;
	msg		: message_buffer;
BEGIN
  event := get_event( E_BUTTON | E_TIMER,	{ Maustaste oder Timer }
			1,			{ linke Taste erwartet }
			1,			{ drÅcken der Taste    }
			1,			{ 1 mal clicken        }
			0,			{ Timer auf 0 ms       }
			FALSE, 0, 0, 0, 0,	{ kein 1. Rechteck     }
			FALSE, 0, 0, 0, 0,	{ kein 2. Rechteck     }
			msg,			{ keine message        }
			mist,			{ keine Taste	       }
			maus_status,		{ Status der Maustaste }
			n_clicks,		{ Anzahl der clicks    }
			maus_x, 		{ x-Position der Maus  }
			maus_y, 		{ y-Position der Maus  }
			mist		);	{ Status der Tastatur  }

  IF event & E_BUTTON = E_BUTTON
  THEN click_in_rechteck := ( maus_x >= x ) AND ( maus_x <= ( x + w) ) AND
			    ( maus_y >= y ) AND ( maus_y <= ( y + h) )
  ELSE click_in_rechteck := FALSE;
END; { click_in_rechteck }


{///////  FRéGT, OB DIE DRUCKAUSGABE ABGEBROCHEN WERDEN SOLL  //////////////}

FUNCTION abbruchfrage : BOOLEAN;
VAR stop : BOOLEAN;
BEGIN
  redraw_hintergrund( f_x, f_y, f_w, f_h);
  obj_size( id, STOPBUTN, st_x, st_y, st_w, st_h);
  shrinkbox( st_x, st_y, st_w, st_h, id_x, id_y, id_w, id_h);
  writev( t, '[2][Soll die Druckausgabe wirklich| |',
		 '!!! ', ' ', ' UND UNWIDERRUFLICH ', ' ', ' !!!| |',
		 'abgebrochen werden ?][ Ja |Nein]'); { Nie mehr als 1 ' ' }
  stop := do_alert( t, 1) = 1;		{ sonst falsch, wenn komprimiert }
  growbox( st_x, st_y, st_w, st_h, id_x, id_y, id_w, id_h);
  obj_draw( id, ROOT, MAX_DEPTH, id_x, id_y, id_w, id_h);
  abbruchfrage := stop;
END; { abbruchfrage }


{///////  ERLEDIGT DIE DRUCKARBEITEN  //////////////////////////////////////}

PROCEDURE drucke_datei( erste_zeile, letzte_zeile : LONG_INTEGER);

TYPE	ch_typ		= ( CONTROL_CH, NORMAL_CH, CONV_CH);

VAR	alles_ok,
	abbruch,
	p_abbruch,
	rand_erreicht,
	numerierung,
	hand_rand,
	konvertierung,
	druck_erwuenscht,
	etwas_gedruckt	: BOOLEAN;
	ch_art		: ch_typ;
	q		: es_text;
	rand_string,
	z		: str255;
	i,
	spalte, 			{ zum MitzÑhlen der Druckposition }
	zusatz_spalte,
	blatt_rand,
	fuell_x,			{ Maûe des Schieberbereichs }
	fuell_y,
	fuell_w,
	fuell_h,
	akt_slider,
	neu_slider	: INTEGER;

	stop_x, 			{ Maûe des Abbruch-Buttons }
	stop_y,
	stop_w,
	stop_h		: INTEGER;

	zeile,				{ zum MitzÑhlen der Druckzeile }
	ueberlang	: LONG_INTEGER; { MitzÑhlen der Åberlangen Zeilen }


{~~~   Gibt einen String Zeichen fÅr Zeichen aus   ~~~~~~~~~~~~~~~~~~~~~~~~~}

  PROCEDURE out ( VAR z : str255);
  VAR	i,
	erg,
	pause	: INTEGER;
	new_sp,
	l_mist,
	timer	: LONG_INTEGER;
  BEGIN
    i := 1;
    WHILE ( ( i <= ord(z[0]) ) AND NOT p_abbruch ) DO
    BEGIN
      IF drucker_bereit( device)
      THEN BEGIN
	     drucke_zeichen( device, z[i]);
	     i := succ(i);
	   END
      ELSE BEGIN
{$P-}
	     new_sp := switch_super( 0);	{ Systemtimer im Super- }
	     timer := timer_200^ & $7FFFFFFF;	{ visormode abfragen }
	     l_mist := switch_super( new_sp);	{ Bit 15 ausgeblendet }
	     erg := 0;
	     REPEAT
	       new_sp := switch_super( 0);
	       pause := abs(timer_200^&$7FFFFFFF-timer) DIV 200;
{$P=}
	       IF pause <> letzte_antwort
	       THEN BEGIN
		      letzte_antwort := pause;
		      neuer_wert(id, LASTCHAR, letzte_antwort, TRUE);
		    END;
	       IF pause >= TIMEOUT
	       THEN erg := 1;				{ Timeout }
	       l_mist := switch_super( new_sp);

	       IF drucker_bereit(device)
	       THEN BEGIN
		      IF letzte_antwort > 0
		      THEN BEGIN
			     letzte_antwort := 0;
			     neuer_wert(id, LASTCHAR, letzte_antwort, TRUE);
			   END;
		      erg := 2; 		{ kann weiter gehen }
		    END;

	       IF (NOT abbruch) OR (letzte_antwort > 0)
	       THEN IF click_in_rechteck( stop_x, stop_y, stop_w, stop_h)
		    THEN erg := 3;		{ Mausklick }
	     UNTIL erg <> 0;
	     CASE erg OF
	       1 : BEGIN				{ Timeout }
		     writev( t, '[1][Der Drucker meldet sich|seit Åber ',
				TIMEOUT, ' Sekunden|nicht mehr !| |',
				'Wie soll es weiter gehen ?]',
				'[Weiter|Abbruch]');
		    IF do_alert(t,1) = 2
		    THEN abbruch := abbruchfrage;
		    p_abbruch := abbruch;
		   END; { Timeout ? }
	       3 : BEGIN
		     abbruch := abbruch OR abbruchfrage;	{ Abbruch ? }
		     p_abbruch := abbruch;
		   END;
	     END; { case }
	   END; { Drucker war nicht bereit }
    END; { while }
  END; { out }

{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

BEGIN
  IF obj_state( dl, PARALLEL) & SELECTED = SELECTED	{ Drucker ermitteln }
  THEN device := 0
  ELSE device := 1;
  letzte_antwort := 0;
  es_reset( q, pfad);				{ ôffnen der Quell-Datei }
  abbruch := q^.eof;
  p_abbruch := FALSE;
  IF abbruch
  THEN BEGIN
	 t := concat( '[3][Angegebene Datei| |nicht gefunden !][Abbruch]');
	 mist := do_alert( t, 1);
       END
  ELSE REPEAT
	 alles_ok := drucker_bereit( device);	{ Drucker online ? }
	 IF NOT alles_ok
	 THEN BEGIN
		t := concat( '[2][Der Drucker ist nicht|empfangsbereit !| |',
			     'Weiterdrucken ?][ Ja |Nein]');
		abbruch := ( do_alert( t, 1) = 2 );
	      END;
       UNTIL alles_ok OR abbruch;
  IF NOT abbruch			{ Initialisieren des Info-Dialogs }
  THEN BEGIN
	 obj_size( id, STOPBUTN, stop_x, stop_y, stop_w, stop_h);
	 obj_size( id, FUELLBOX, fuell_x, fuell_y, fuell_w, fuell_h);
{$P-}
	 id^[LEERANFG].ob_x := 0;	{ zunÑchst Anfang auf Null }
	 id^[LEERANFG].ob_w := 0;	{ Breite auf Null }
	 id^[SCHIEBER].ob_x := 0;	{ zunÑchst Schieber auf Null }
	 id^[SCHIEBER].ob_w := 0;	{ Breite auf Null }
	 id^[LEERENDE].ob_x := 0;	{ zunÑchst Ende auf Null }
	 id^[LEERENDE].ob_w := 0;	{ Breite auf Null }
{$P=}
	 obj_size( dl, STARTBTN, st_x, st_y, st_w, st_h);
	 growbox( st_x, st_y, st_w, st_h, id_x, id_y, id_w, id_h);
	 switch_radio( id, DRUCKBTN, STOPBUTN, NONE, 1, FALSE);

	 neuer_wert(id, LASTCHAR, letzte_antwort, FALSE);
	 obj_draw( id, ROOT, MAX_DEPTH, id_x, id_y, id_w, id_h);

	 numerierung := obj_state( dl, NUMMERJA) & SELECTED = SELECTED;
							{ Konvertierung ? }
	 konvertierung := obj_state( dl, UEBERSJA) & SELECTED = SELECTED;

	 out( p_string[ p_init, drucker]^);	{ Initialisierung senden }

	 IF p_string[ p_lrand, drucker]^ <> ''	{ Linken Rand setzen }
	 THEN BEGIN
		FOR i := 1 TO length( p_string[ p_lrand, drucker]^ ) DO
		BEGIN
		  IF p_string[ p_lrand, drucker]^[i] >= #$80
		  THEN writev( z, chr( ord(p_string[ p_lrand, drucker]^[i])
			       - $80 + randbreite) )
		  ELSE writev( z, p_string[ p_lrand, drucker]^[i] );
		  out(z);
		END;
		hand_rand := FALSE;
	      END
	 ELSE hand_rand := TRUE;

	 IF obj_state(dl,PICASCHR)&SELECTED = SELECTED	{ Pica setzen }
	 THEN BEGIN
		blatt_rand := randbreite;
		IF obj_state(dl,NLQSCHRI)&SELECTED = SELECTED	{ NLQ ? }
		THEN z := p_string[ p_pica_nlq,   drucker]^
		ELSE z := p_string[ p_pica_draft, drucker]^;
		out(z);
	      END;

	 IF obj_state(dl,ELITESCH)&SELECTED = SELECTED	{ Elite setzen	 }
	 THEN BEGIN
		blatt_rand := round( randbreite * 1.2 );
		IF obj_state(dl,NLQSCHRI)&SELECTED = SELECTED	{ NLQ ? }
		THEN z := p_string[ p_elite_nlq,   drucker]^
		ELSE z := p_string[ p_elite_draft, drucker]^;
		out(z);
	      END;

	 IF obj_state(dl,SCHMALSC)&SELECTED = SELECTED	{ Schmal setzen  }
	 THEN BEGIN
		blatt_rand := round( randbreite * 1.7 );
		IF obj_state(dl,NLQSCHRI)&SELECTED = SELECTED	{ NLQ ? }
		THEN z := p_string[ p_schmal_nlq,   drucker]^
		ELSE z := p_string[ p_schmal_draft, drucker]^;
		out(z);
	      END;

	      IF hand_rand
	      THEN BEGIN			{ Rand mit Spaces erzeugen }
		     IF blatt_rand > 0
		     THEN writev( rand_string, ' ' : blatt_rand)
		     ELSE rand_string := '';
		     IF length(rand_string) > zeilenbreite	{ eventuell }
		     THEN rand_string[0] := chr(zeilenbreite);	{ stutzen }
		   END
	      ELSE rand_string := '';		{ Rand konnte der Drucker }

	 zeile := 0;				{ Startwert ZeilenzÑhlung }
	 ueberlang := 0;			{ Startwert öberlÑnge }
	 etwas_gedruckt := FALSE;		{ Noch kein Text gedruckt }
	 akt_slider := LEERANFG;		{ Erst kein Druck }
	 WHILE NOT ( q^.eof OR abbruch ) DO	{ Solange noch was da ist }
	 BEGIN
	   zeile := zeile + 1;			{ NÑchste Zeile }
	   rand_erreicht := FALSE;
	   druck_erwuenscht := (erste_zeile <= zeile)
				AND (zeile <= letzte_zeile);
	   IF druck_erwuenscht
	   THEN BEGIN
		  IF NOT etwas_gedruckt 	{ Wechsel auf drucken }
		  THEN BEGIN
{$P-}
			 id^[SCHIEBER].ob_x := id^[LEERANFG].ob_w;
{$P=}
			 akt_slider := SCHIEBER;
		       END;
		  IF ( ((zeile - erste_zeile + 1) MOD seitenlaenge) = 1 )
			AND (zeile > erste_zeile)
			AND (obj_state( dl, PERFORJA) & SELECTED = SELECTED)
		  THEN BEGIN
			 z := #12;			{ Formfeed senden }
			 out(z);
		       END;
		  out( rand_string);	{ Eventuell Rand mit Spaces machen }

		  IF numerierung	{ HinzufÅgen der Zeilennummer }
		  THEN BEGIN
			 writev( z, zeile : 8,
				' ' : NUM_TEXT_ABST);
			 zusatz_spalte := zeilenbreite - blatt_rand;
			 IF length(z) > zusatz_spalte	{ evtl. stutzen }
			 THEN z[0] := chr(zusatz_spalte)
			 ELSE zusatz_spalte := length(z);
			 out(z);
		       END
		  ELSE zusatz_spalte := 0;
		  spalte := zusatz_spalte;

		  WHILE NOT ( q^.eoln OR abbruch ) DO
		  BEGIN 				{ Zeile drucken }
		    IF spalte < ( zeilenbreite - blatt_rand)
		    THEN BEGIN
			   IF q^.ch IN [ #$20 .. #$7E]
			   THEN ch_art := NORMAL_CH
			   ELSE IF ( q^.ch >= CONV_MIN)
					AND ( q^.ch <= CONV_MAX)
				THEN ch_art := CONV_CH
				ELSE ch_art := CONTROL_CH;
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
  CASE ch_art OF
    NORMAL_CH  : BEGIN				{ normales Zeichen drucken }
		   z := q^.ch;
		   out(z);
		 END;
    CONTROL_CH : BEGIN
		   IF q^.ch = #$9 {HT}
		   THEN BEGIN			{ Tabulator behandeln }
			  i:=tab_weite-(spalte-zusatz_spalte) MOD tab_weite;
			  IF ( spalte + i) > (zeilenbreite - blatt_rand)
			  THEN i := zeilenbreite - blatt_rand - spalte;
			  writev( z, ' ' : i);
			  out(z);
			  spalte := spalte + i - 1;
			END
		   ELSE out(space^);		{ mit Space ersetzen }
		 END;
    CONV_CH    : BEGIN
		   CASE q^.ch OF
		     'Ñ','î','Å',
		     'é','ô','ö',
		     'û','›'   : IF p_convert[q^.ch, drucker] = NIL
				 THEN z := q^.ch	{ Zeichen drucken }
				 ELSE z := p_convert[ q^.ch, drucker]^;
		     OTHERWISE : IF konvertierung
				 THEN IF p_convert[q^.ch, drucker] = NIL
				      THEN z := q^.ch	{ Zeichen drucken }
				      ELSE z := p_convert[ q^.ch, drucker]^
				 ELSE z := ' ';
		   END; { case }
		   out(z);
		 END;
   END; { case }
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
			 END   { Zeichen gedruckt, weil noch nicht am Rand }
		    ELSE rand_erreicht := TRUE;
		    es_get( q);
		    spalte := spalte + 1;
		  END; { while not Zeilenende der Quelle erreicht }
		  writev( z, #$0D, #$0A);	{ Zeilenvorschub schreiben }
		  out(z);
		  etwas_gedruckt := TRUE;		{ Es wurde gedruckt }
		  IF rand_erreicht
		  THEN ueberlang := ueberlang + 1;
		END { Druck war erwÅnscht }
	   ELSE IF etwas_gedruckt
		THEN BEGIN
{$P-}							{ Slider wechseln }
			 id^[LEERENDE].ob_x := id^[SCHIEBER].ob_x
						+ id^[SCHIEBER].ob_w;
{$P=}
			 akt_slider := LEERENDE;
		     END;
	   es_readln( q);				{ Zeilenende lesen }

	   IF NOT abbruch
	   THEN IF click_in_rechteck( stop_x, stop_y, stop_w, stop_h)
		THEN abbruch := abbruchfrage;	{ Schauen, ob Abbruch }

	   neu_slider := round ( fuell_w*(q^.count+q^.buf_ptr) / q_laenge );
{$P-}
	   IF neu_slider > (id^[akt_slider].ob_x + id^[akt_slider].ob_w)
	   THEN BEGIN				{ Schiebebalken zeichnen }
		  id^[akt_slider].ob_w := neu_slider - id^[akt_slider].ob_x;
		  obj_draw(id, akt_slider, NONE, fuell_x, fuell_y,
						fuell_w, fuell_h);
		END;
{$P=}
	   IF abbruch AND ( NOT p_abbruch)
	   THEN BEGIN
		  z := #24;	{ ASCII-Zeichen CAN Åbermitteln }
		  out(z);
		END;

	 END; { while Dateiende nicht erreicht oder Abbruch }

	 IF NOT p_abbruch
	 THEN BEGIN			{ De-Initialisierung }
		IF etwas_gedruckt
			AND (obj_state(dl,FORMFEJA) & SELECTED = SELECTED)
		THEN BEGIN
		       z := #12;	{ Formfeed schicken }
		       out(z);
		     END;
		z := p_string[ p_exit, drucker]^;
		out(z);
	      END;
	 redraw_hintergrund( f_x, f_y, f_w, f_h);
	 obj_size( dl, STARTBTN, st_x, st_y, st_w, st_h);
	 shrinkbox( st_x, st_y, st_w, st_h, id_x, id_y, id_w, id_h);
	 IF q^.error < 0		{ BIOS - Fehlermeldung }
	 THEN BEGIN
		writev( t, '[1][Das Betriebssystem meldet|',
			       'einen Fehler beim Zugriff|',
			       'auf die Druckdatei !|',
			       'Der Druck wurde deshalb|',
			       'vorzeitig abgebrochen.][ Okay ]');
		mist := do_alert( t, 1);
	      END;
	 IF ueberlang > 0
	 THEN BEGIN
		IF ueberlang = 1 THEN z := '' ELSE z := 'n';
		writev( t, '[1][Wegen ihrer öberlÑnge muûte', z,
			      '|insgesamt ', ueberlang, ' Zeile', z,
			      '|abgeschnitten werden !][ Okay ]');
		mist := do_alert( t, 1);
	      END;
	 IF NOT etwas_gedruckt
	 THEN BEGIN
		t := concat('[1][Die Druckdatei enthielt keinen|',
				'Text, der innerhalb der von|',
				'Ihnen angegebenen Grenzen lag.| |',
				'Ihr Papier bleibt also leer !][ Okay ]');
		mist := do_alert( t, 1);
	      END;
       END; { Es durfte gedruckt werden }
  es_close( q);
END; { drucke_datei }


{///////  DIALOG öBERMALEN UND SCHRUMPFEN LASSEN  //////////////////////////}

PROCEDURE verstecke_dialog;
BEGIN
  redraw_hintergrund( f_x, f_y, f_w, f_h);
  shrinkbox( st_x, st_y, st_w, st_h, dl_x, dl_y, dl_w, dl_h);
END; { verstecke_dialog }


{///////  DIALOG WACHSEN LASSEN UND NEU ZEICHNEN  //////////////////////////}

PROCEDURE zeige_dialog;
BEGIN
  growbox( st_x, st_y, st_w, st_h, dl_x, dl_y, dl_w, dl_h);
  obj_draw( dl, ROOT, MAX_DEPTH, dl_x, dl_y, dl_w, dl_h);
END; { zeige_dialog }


{///////  DATEINAMEN AUS FILE-SELECTOR-BOX ERMITTELN  //////////////////////}

PROCEDURE ermittle_datei;
VAR	file_erhalten	: BOOLEAN;
	name,
	extension,
	neu_vorschlag,
	neu_pfad	: STRING;

BEGIN
  neu_vorschlag := vorschlag;
  neu_pfad	:= '';
  file_erhalten := get_in_file( neu_vorschlag, neu_pfad);
  redraw_hintergrund( f_x, f_y, f_w, f_h);
  IF file_erhalten
  THEN BEGIN
	 fsetdta ( dta);
	 IF exist( neu_pfad)
	 THEN BEGIN
		pfad := neu_pfad;
		vorschlag := neu_vorschlag;
		q_laenge := dta.laenge;

		obj_setstate( dl, STARTBTN, ( obj_state
			     ( dl, STARTBTN) & ~DISABLED), FALSE);
		IF length( pfad) <= max_pfad
		THEN t := concat( ' ', pfad)	{ Pfad hat öberlÑnge }
		ELSE BEGIN
		       t := copy(pfad, length(pfad)-max_pfad+5, max_pfad-4);
		       t := concat(' <<< ', t);
		     END;
		set_rsc_str( dl, DATEINAM, t);

		analyze_path( pfad, name, extension);
		IF length( extension) > 0
		THEN name := concat( name, '.', extension);
		set_rsc_str( id, OUTFNAME, name);
	      END
	 ELSE BEGIN
		obj_setstate( dl, STARTBTN, ( obj_state( dl, STARTBTN)
			      | DISABLED), FALSE);
		t := '[2][Die angegebene Datei| |existiert nicht !][ OK ]';
		mist := do_alert( t, 1);
		set_rsc_str( dl, DATEINAM, D_AUFFORD);
	      END;
       END { file_erhalten }
  ELSE
    BEGIN
      obj_setstate( dl,STARTBTN, obj_state( dl, STARTBTN)|DISABLED, FALSE);
      set_rsc_str( dl, DATEINAM, D_AUFFORD);
    END;
END; { ermittle_datei }


{///////  éNDERUNG DURCH PFEILKéSTCHEN	////////////////////////////////////}

PROCEDURE wert_aenderung( d : dialog_ptr; index : INTEGER;
				VAR wert : INTEGER;
				min, max, delta : INTEGER);
VAR	versuch : INTEGER;

BEGIN
  versuch := wert + delta;
  IF versuch < min
  THEN versuch := min
  ELSE IF versuch > max
       THEN versuch := max;
  IF versuch <> wert
  THEN BEGIN
	 wert := versuch;
	 neuer_wert( d, index, wert, TRUE);
       END;
END; { wert_aenderung }


{///////  MANAGEMENT DES HAUPT-DIALOGS	////////////////////////////////////}

PROCEDURE action;

CONST	DELTA_NORM	= 1;
	DELTA_DOPL	= 10;

VAR	delta,
	rueck,
	knopf		: INTEGER;
	doppelclick	: BOOLEAN;

BEGIN { action }
  obj_size( dl, COPYINFO, st_x, st_y, st_w, st_h);	{ Growbox }
  growbox( st_x, st_y, st_w, st_h, dl_x, dl_y, dl_w, dl_h);
  show_dialog( dl);			{ Dialog zeichnen lassen }
  knopf := LPTR1BTN;			{ Zuerst Drucker Nr. 1 aktivieren }
  delta := DELTA_NORM;
  WHILE knopf <> ABBRUBTN DO
    BEGIN
{---------------------------------------------------------------------------}
CASE knopf OF
DATEINAM : BEGIN			{ Quelldatei-Button angewÑhlt }
	     obj_size( dl, DATEINAM, st_x, st_y, st_w, st_h);
	     verstecke_dialog;
	     ermittle_datei;
	     obj_setstate( dl, knopf, obj_state(dl,knopf)& ~SELECTED,FALSE);
	     zeige_dialog;
	   END;
LPTR1BTN,
LPTR2BTN,
LPTR3BTN : BEGIN			{ Drucker gewechselt }
	     neuer_drucker( knopf);
	     neuer_wert( dl, TABWEITE, tab_weite,    TRUE);
	     neuer_wert( dl, RANDBREI, randbreite,   TRUE);
	     neuer_wert( dl, ZEILBREI, zeilenbreite, TRUE);
	     neuer_wert( dl, SEITLAEN, seitenlaenge, TRUE);
	   END;
NUMMERJA : BEGIN			{ Es soll numeriert werden }
	     IF ( obj_state( dl, PICASCHR) & SELECTED = SELECTED)
		AND ( zeilenbreite < 96)
	     THEN BEGIN
		    obj_size( dl, NUMMERJA, st_x, st_y, st_w, st_h);
		    verstecke_dialog;
		    t := concat('[2][Zeilenbreite ist zu klein|fÅr ',
				'Numerierung !| |Schriftart wechseln ?]',
				'[ Ja | Nein ]');
		    IF do_alert( t, 1) = 1
		    THEN BEGIN
			   switch_radio(dl,PICASCHR,ELITESCH,NONE,2,FALSE);
			   zeilenbreite := p_vor[p_elite_breit, drucker];
			   neuer_wert( dl, ZEILBREI, zeilenbreite, FALSE);
			 END;
		    zeige_dialog;
		  END;
	   END;
NUMMERNE : BEGIN			{ Keine Numerierung erwÅnscht }
	   END;
PICASCHR : BEGIN			{ Pica-Schrift gewÑhlt }
	     zeilenbreite := p_vor[ p_pica_breit, drucker];
	     neuer_wert( dl, ZEILBREI, zeilenbreite, TRUE);
	   END;
ELITESCH : BEGIN			{ Elite-Schrift gewÑhlt }
	     zeilenbreite := p_vor[ p_elite_breit, drucker];
	     neuer_wert( dl, ZEILBREI, zeilenbreite, TRUE);
	   END;
SCHMALSC : BEGIN			{ Schmal-Schrift gewÑhlt }
	     zeilenbreite := p_vor[ p_schmal_breit, drucker];
	     neuer_wert( dl, ZEILBREI, zeilenbreite, TRUE);
	   END;

TABMINUS : wert_aenderung( dl, TABWEITE, tab_weite, 1, 50, -delta);
TABUPLUS : wert_aenderung( dl, TABWEITE, tab_weite, 1, 50,  delta);

RANDMINU : wert_aenderung( dl, RANDBREI, randbreite, 0, 999, -delta);
RANDPLUS : wert_aenderung( dl, RANDBREI, randbreite, 0, 999,  delta);

ZLBRMINU : wert_aenderung( dl, ZEILBREI, zeilenbreite, 5, 999, -delta);
ZLBRPLUS : wert_aenderung( dl, ZEILBREI, zeilenbreite, 5, 999,	delta);

SEITLMIN : wert_aenderung( dl, SEITLAEN, seitenlaenge, 1, 999, -delta);
SEITLPLU : wert_aenderung( dl, SEITLAEN, seitenlaenge, 1, 999,	delta);

COPYINFO : BEGIN			{ Copyright-Meldung }
	     obj_size( dl, COPYINFO, st_x, st_y, st_w, st_h); { Shrinkbox }
	     verstecke_dialog;
	     obj_size( cd, INFOKBTN, st_x, st_y, st_w, st_h); { fÅr Growbox }
	     growbox( st_x, st_y, st_w, st_h, cd_x, cd_y, cd_w, cd_h);
	     mist := do_dialog( cd, NONE);
	     obj_setstate( cd,mist, obj_state(cd,mist) & ~SELECTED,FALSE);
	     redraw_hintergrund( f_x, f_y, f_w, f_h);
	     shrinkbox( st_x, st_y, st_w, st_h, cd_x, cd_y, cd_w, cd_h);
	     obj_setstate( dl,knopf, obj_state(dl,knopf) & ~SELECTED,FALSE);
	     obj_size( dl, COPYINFO, st_x, st_y, st_w, st_h); { Shrinkbox }
	     zeige_dialog;
	   END;
STARTBTN : BEGIN			{ Start des Drucks }
	     m_boo := lese_zahl( dl, STARTNUM, erste_zeile);
	     m_boo := lese_zahl( dl, ENDENUMM, letzte_zeile);
	     IF (erste_zeile > 0) AND (letzte_zeile >= erste_zeile)
	     THEN BEGIN
		    IF (obj_state( dl, INSEITEN) & SELECTED = SELECTED)
		    THEN BEGIN
			   erste_zeile := ((erste_zeile-1)*seitenlaenge)+1;
			   letzte_zeile := letzte_zeile * seitenlaenge;
			 END;
		    obj_size( dl, STARTBTN, st_x, st_y, st_w, st_h);
		    verstecke_dialog;
		    drucke_datei( erste_zeile, letzte_zeile);
		    obj_size( dl, STARTBTN, st_x, st_y, st_w, st_h);
		    zeige_dialog;
		  END
	     ELSE BEGIN
		    t := concat('[1][Die Angaben fÅr Start|',
				'oder Ende des Drucks|',
				'erscheinen unsinnig !| |',
				'Bitte korrigieren !][ Okay ]');
		    mist := do_alert( t, 1);
		  END; { Fehler in den Seitenangaben }
	     obj_setstate( dl,knopf, obj_state(dl,knopf) & ~SELECTED, TRUE);
	   END;
PERFORJA,		{ Perforation Åberspringen ? }
PERFORNE,
UEBERSJA,		{ Zeichen ab CONV_MIN (127) drucken ? }
UEBERSNE,
FORMFEJA,		{ Formfeed am Ende ? }
FORMFENE,
PARALLEL,		{ Schnittstelle ? }
SERIELLE,
DRAFTSCH,		{ SchriftqualitÑt ? }
NLQSCHRI,
INSEITEN,		{ Start und Ende in Seiten/Zeilen ? }
INZEILEN : BEGIN END;

OTHERWISE: BEGIN
	     t := concat('[2][Fehler ???| |Unbekanntes Objekt !][ ??? ]');
	     mist := do_alert( t, 1);
	   END;
END; { case }
{---------------------------------------------------------------------------}

      rueck := redo_dialog( dl, STARTNUM);
      knopf := rueck & $7FFF;			{ Bit 15 ausfiltern }
      doppelclick := (knopf <> rueck) OR (kbshift(-1) & 15 > 0);
      IF doppelclick				{ Doppelklick ? }
      THEN delta := DELTA_DOPL
      ELSE delta := DELTA_NORM;

    END; { while not Abbruch }
  end_dialog( dl);
  obj_size( dl, ABBRUBTN, st_x, st_y, st_w, st_h);
  verstecke_dialog;
END; { action }


{///////  H A U P T P R O G R A M M  ///////////////////////////////////////}

BEGIN { Hauptprogramm }
  IF init_gem >= 0				{ Start ins GEM }
  THEN
  BEGIN
    IF NOT load_resource ( RSC_DATEI )		{ RSC-Datei laden }
    THEN BEGIN
	   t := concat('[3][Resource - Datei|', RSC_DATEI,
			 '|nicht gefunden !][Abbruch]');
	   mist := do_alert( t, 1);
	 END { RSC-Datei nicht gefunden }
    ELSE IF getres >= MID_RES
	 THEN BEGIN
		set_mouse( M_ARROW);

		unterlege_fenster;		{ Eigenes, groûes Fenster }
		redraw_hintergrund( f_x, f_y, f_w, f_h);	{ ausmalen }

		find_dialog( HAUPTDLG, dl);	{ Dialog-Pointer setzen }
		center_dialog( dl);		{ und Dialog zentrieren }

		find_dialog( DRUCKINF, id);
		center_dialog( id);

		find_dialog( INFODIAL, cd);
		center_dialog( cd);

		obj_size( dl, ROOT, dl_x, dl_y, dl_w, dl_h);
		obj_size( id, ROOT, id_x, id_y, id_w, id_h);
		obj_size( cd, ROOT, cd_x, cd_y, cd_w, cd_h);

		new( leer  : 1);	leer^  := '';	{ Mehrfach-EintrÑge }
		new( space : 1);	space^ := ' ';

		analysiere_dialogfeld;
		welche_drucker_sind_da; 	{ sind Druckertreiber da ? }
		initialisiere_dialogfeld;

		action; 			{ Hauptdialog fÅhren }

		close_window  ( fenster );	{ Fenster entfernen }
		delete_window ( fenster );
	      END { Alles war OK }
	 ELSE mist := do_alert( concat('[3][Das Programm lÑuft|',
			'nicht in der|niedrigen Auflîsung][Abbruch]'), 1);
    exit_gem;
  END; { init_gem erfolgreich }
END.

