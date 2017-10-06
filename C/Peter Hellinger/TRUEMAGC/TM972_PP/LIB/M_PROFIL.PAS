UNIT M_Profile;

INTERFACE

FUNCTION  ReadProfile (CONST name: ARRAY OF CHAR; VAR date, time: WORD): BOOLEAN;
(* Liest eine Profildatei ein. 'name' ist der vollstÑndige Pfad zur Datei.
 * Liefert TRUE, wenns geklappt hat.
 *
 * Eine Profildatei enthÑlt zB. Konfigurationsdaten oder Einstellungen
 * fÅr eine Applikation.  Um die folgenden Funktionen 'wirksam' zu 
 * machen, sollte eine gewisse Syntax innerhalb der Profildatei 
 * eingehalten werden.
 *
 * M_Profile geht von folgenden Voraussetzungen aus:
 *
 * 1. Alles was nach einem Semikolon steht wird bis zum Zeilenende
 *    ignoriert.
 *
 * 2. Alles was nach einem # steht, wird ignoriert, bis zum Zeilenende,
 *    oder bis zum nÑchsten #.  Beispiel:
 *
 *    MeinWert # Ein ziemlich doofer Name, nicht wahr? # = 33
 *
 * 3. Eine Angabe wird durch ein SchlÅsselwort eingeleitet, danach
 *    folgt das Zuweisungszeichen '=' und anschliessend der Wert.
 *    Beispiel:
 *
 *    MeinWert = 45
 *
 *    Es kînnen auch mehrere Werte in einer Zeile angegeben werden, 
 *    die einzelnen Werte mÅssen jedoch durch mindestens ein Space-Zeichen
 *    voneinander getrennt sein.
 *
 * 4. Als Werte sind Strings, Booleans und einfache Zahlen vorgesehen.
 *
 *    - Strings sind in AnfÅhrungszeichen " einzuschliessen und enthalten
 *      Texte wie zB. Pfadnamen oder dergleichen. Beispiel:
 *
 *      MeinPfad = "C:\GEM\ODER\WAS\ANDRES\"
 *
 *    - Booleans enthalten den Wert TRUE fÅr wahr oder FALSE fÅr falsch.
 *      Es wird der Text ohne AnfÅhrungsstriche erwartet. Beispiel:
 *
 *      IstEsSo = FALSE
 *
 *    - Zahlen kînnen im Bereich von -2147483647 bis +2147483647 sein.
 *      Die Angabe der Zahl wird im Dezimalsystem erwartet.
 *
 * Als Beispiel kînnen Sie auch die Datei MAGICOOK.INF betrachten, die
 * vom Cookieprogramm oder dem Magic-Kernel eingelesen wird.
 *)

FUNCTION GetValue (CONST token: ARRAY OF CHAR; VAR val: LONGINT): BOOLEAN;
(* Liest einen Wert aus der Profildatei aus. Liefert TRUE, wenn der 
 * Wert gefunden wurde.
 *
 * token = SchlÅsselwort, nachdem gesucht werden soll,
 * val =   der gefundene Wert, andernfalls UNDEFINIERT!
 *)

FUNCTION GetSV (CONST token: ARRAY OF CHAR; num: INTEGER; VAR val: ARRAY OF LONGINT): BOOLEAN;
(* 'GetSpacedValues' liest mehrere Werte aus einer Zeile der Profildatei.
 *
 * token = SchlÅsselwort, nachdem gesucht werden soll
 * num =   Anzahl der Werte die erwartet werden.
 * val =   Pufferspeicher fÅr die gelesenen Werte, wird auf -1 initialisiert
 *)

FUNCTION GetBoolean (CONST token: ARRAY OF CHAR; VAR val: BOOLEAN): BOOLEAN;
(* Liest einen Boolean aus der Profildatei. Liefert TRUE, wenn der 
 * Boolean gefunden wurde.
 *
 * token = SchlÅsselwort, nachdem gesucht werden soll,
 * val =   der gefundene Wert, andernfalls UNDEFINIERT!
 *)

FUNCTION GetString (CONST token: ARRAY OF CHAR; VAR val: ARRAY OF CHAR): BOOLEAN;
(* Liest einen String aus der Profildatei. Liefert TRUE, wenn der 
 * Boolean gefunden wurde.
 *
 * token = SchlÅsselwort, nachdem gesucht werden soll,
 * val =   der gefundene Wert, andernfalls Nullstring. Die "-Zeichen
 *         wurden bereits entfernt!
 *)

PROCEDURE FreeProfile;
(* Gibt die benutzen Datenstrukturen und -bereiche wieder frei. *)

IMPLEMENTATION

USES m_Sys;

FUNCTION ReadProfile (CONST name: ARRAY OF CHAR; VAR date, time: WORD): BOOLEAN;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (name);
 CallMagic (1200);
 ReadProfile:= BOOLEAN (App^.MagicPB^.IntOut[0]);
 date:= App^.MagicPB^.IntOut[1];
 time:= App^.MagicPB^.IntOut[2];
END (*ReadInfo*);

PROCEDURE FreeProfile;
BEGIN
 CallMagic (1204);
END (*FreeProfile*);

FUNCTION GetValue (CONST token: ARRAY OF CHAR; VAR val: LONGINT): BOOLEAN;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (token);
 CallMagic (1201);
 val:= App^.MagicPB^.LongOut[0];
 GetValue:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*GetValue*);

FUNCTION GetBoolean (CONST token: ARRAY OF CHAR; VAR val: BOOLEAN): BOOLEAN;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (token);
 CallMagic (1202);
 val:= BOOLEAN (App^.MagicPB^.IntOut[1]);
 GetBoolean:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*GetBoolean*);

FUNCTION GetString (CONST token: ARRAY OF CHAR; VAR val: ARRAY OF CHAR): BOOLEAN;
BEGIN
{$Z-}
 App^.MagicPB^.AddrIn[0]:= ADDR (token);
 App^.MagicPB^.AddrIn[1]:= ADDR (val);
 CallMagic (1203);
 GetString:= BOOLEAN (App^.MagicPB^.IntOut[0]);
{$Z+}
END (*GetString*);

FUNCTION GetSV (CONST token: ARRAY OF CHAR; num: INTEGER; VAR val: ARRAY OF LONGINT): BOOLEAN;
BEGIN
 App^.MagicPB^.IntIn[0]:= num;
 App^.MagicPB^.AddrIn[0]:= ADDR (token);
 App^.MagicPB^.AddrIn[1]:= ADDR (val);
 CallMagic (1205);
 GetSV:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*GetSV*);

END (*MLProfile*).