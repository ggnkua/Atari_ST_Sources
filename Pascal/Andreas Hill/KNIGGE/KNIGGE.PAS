{$A+,S2,D-,S-,T-,P-}       { Accessory, 2 k Stack }
PROGRAM Knigge;

 {  KNIGGE.ACC                             V 1.0

    Demonstrationsprogramm  zur  Auswertung  und
    Modifikation des Tastaturpuffers

    öberwachung auf Eintippen von Schimpfwîrtern
    u.Ñ., ggf. Ausgabe einer Zurechtweisung, in-
    nerhalb  von Textverarbeitungen  Lîschen der
    Eingabe

    von Andreas Hill
    (c) MAXON Computer GmbH

    Letzte Modifikation: 20. April 1989

    Entwickelt unter CCD Pascal plus 2.0x auf ST  }

 {  Linker: ACC erstellen und PASTRIX einbinden   }

CONST {$I GEMCONST}       { div. GEM-Libraries    }
TYPE  {$I GEMTYPE}
{$I GEMSUBS}

CONST Zeilenlaenge = 255;   { Interne PufferlÑnge }
      Momentchen   = 150;   { ms Wartezeit        }

TYPE IORec_Type = PACKED RECORD
        IBuf    : LONG_INTEGER;   { Pufferzeiger  }
        IBufSiz : SHORT_INTEGER;  { PufferlÑnge   }
        IBufHd  : SHORT_INTEGER;  { Lesezeiger    }
        IBufTl  : SHORT_INTEGER;  { Schreibzeiger }
        IBufLow : SHORT_INTEGER;
        IBufHi  : SHORT_INTEGER;
        END;
     Schmutzpuffer_Typ = STRING[Zeilenlaenge];

VAR Appl          : SHORT_INTEGER;
    IORec_Adresse : LONG_INTEGER;
    IO_Record     : IORec_Type;
    Alte_Position : SHORT_INTEGER;
    Pruefzeile    : Schmutzpuffer_Typ;
    IDummy        : SHORT_INTEGER;

FUNCTION IORec (Geraet : SHORT_INTEGER)
               : LONG_INTEGER;
  XBIOS (14);

 { Folgende Deklarationen TRIXSUBS.PAS entnommen }

FUNCTION  LPeek (Adresse: LONG_INTEGER)
                : LONG_INTEGER;
  EXTERNAL;
PROCEDURE WPoke (Adresse: LONG_INTEGER;
                 Wert : SHORT_INTEGER);
  EXTERNAL;
PROCEDURE LPoke (Adresse, Wert : LONG_INTEGER);
  EXTERNAL;

PROCEDURE Evnt_Timer (Zeit : LONG_INTEGER);
VAR Msg : Message_Buffer;      { <Zeit> ms warten }
BEGIN
   IDummy := Get_Event (E_Timer, 0,0,0, Zeit,
                False, 0,0,0,0, False, 0,0,0,0,
                Msg, IDummy, IDummy,IDummy,
                IDummy,IDummy, IDummy);
END;

PROCEDURE Peek_IORec (Adresse: LONG_INTEGER;
                      VAR Rec : IORec_Type);
VAR Magic : RECORD CASE BOOLEAN OF
       False: (Adr : LONG_INTEGER);
       True : (Ptr : ^IORec_Type)
       END;
BEGIN
   Magic.Adr := Adresse;
   Rec := Magic.Ptr^;
END;

PROCEDURE Pruefzeile_leeren;
VAR i : SHORT_INTEGER;  { Vergleichszeile anfangs }
BEGIN                   {  mit Leerzeichen fÅllen }
   Pruefzeile := '';
   FOR i := 1 TO Zeilenlaenge DO
      Pruefzeile := Concat (Pruefzeile,' ');
END;

PROCEDURE Zeichen_ausgeben (Zeichen: LONG_INTEGER);
BEGIN
   Peek_IORec (IORec_Adresse, IO_Record);
   WITH IO_Record DO BEGIN
      IBufTl := IBufTl + 4; { NÑchste Schreibpos. }
      IF IBufTl >= IBufSiz THEN  { Pufferende ?   }
         IBufTl := 0;            { Dann an Anfang }
      LPoke (IBuf+IBufTl,Zeichen);    { Eintragen }
      WPoke (IORec_Adresse+8,IBufTl); { Zeiger -> }
      END;
   Evnt_Timer (Momentchen); { Kontrolle abgeben   }
END;

PROCEDURE Pruefe (Schmutz : Schmutzpuffer_Typ);
VAR Laenge, i : SHORT_INTEGER;
BEGIN
   Laenge := Length (Schmutz);   { Eingabe prÅfen }
   IF Copy(Pruefzeile,Zeilenlaenge-Laenge+1,Laenge)
       = Schmutz THEN BEGIN
      IDummy := Do_Alert ('[0][       Aktion| SAUBERER BILDSCHIRM   |  Pfui! Pfui! Pfui!|    Diese Eingabe|    wird gelîscht][ Pardon ]',1);
      Evnt_Timer (Momentchen);   { Kurz warten    }
      FOR i := 1 TO Laenge DO    { Backspaces     }
         Zeichen_ausgeben ($000E0008); { Scan/ASC }
      Write (Chr(7));            { Klingeling     }
      END;
END;

PROCEDURE Pruefliste_bearbeiten;
BEGIN               { Alles in Groûbuchstaben !!! }
   Pruefe ('MIST');
   Pruefe ('SCHEIû');
   Pruefe ('SCHEISS');
   Pruefe ('DOOF');
END;

PROCEDURE IORec_Inhalt_untersuchen;
VAR Zeichen    : LONG_INTEGER;
    ASCII_Code : SHORT_INTEGER;
BEGIN
   { IO-Record lesen }
   Peek_IORec (IORec_Adresse, IO_Record);
   WITH IO_Record DO
      { Wurde Pufferzeiger weitergesetzt ? }
      IF IBufTl <> Alte_Position THEN BEGIN
         { éltestes Zeichen lîschen }
         Delete (Pruefzeile,1,1);
         { Neues Zeichen aus Puffer lesen }
         Zeichen := LPeek (IBuf+IBufTl);
         ASCII_Code := Int (Zeichen);
         { Kleine in Groûbuchstaben umwandeln }
         IF ASCII_Code IN [97..122] THEN BEGIN
            ASCII_Code := ASCII_Code - 32;
            END;
         Pruefzeile := Concat (Pruefzeile,
                               Chr(ASCII_Code));
         { Neue Zeigerposition merken }
         Alte_Position := IBufTl;
         { Alles Verbotene bemÑkeln }
         Pruefliste_bearbeiten;
         END;
END;

PROCEDURE Ereignisverwaltung;
BEGIN
   WHILE True DO BEGIN       { Endlosschleife     }
      Evnt_Timer (50);       { Meldung alle 50 ms }
      IORec_Inhalt_untersuchen;
      END;
END;

BEGIN
   IORec_Adresse:= IORec(1); { Adresse IO-Record  }
   Pruefzeile_leeren;        { Mit Blanks fÅllen  }

   Appl := Init_GEM;         { Accessory anmelden }
   IF Appl >= 0 THEN BEGIN   { Kein MenÅeintrag   }
      Message ('  KNIGGE ist installiert');
      WriteLn ('    (c)  A. Hill  4/89');
      WriteLn;

      Ereignisverwaltung;    { Endlosschleife     }

      END;
END.
