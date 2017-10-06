(*----------------------------------------------------------------------*
 * MagicCookie  Zugriff auf den Cookiejar                               *
 *                                                                      *
 * Cookies sind, Ñhnlich XBRA im System global zugÑngliche Variablen.   *
 * Sie bestehen jeweils aus einem Namen (4 Byte, mîglichst ein lesbarer *
 * Text) und einem 32Bit-Wert. Sie werden vom Betriebssystem (ab TOS-   *
 * Version 1.06 oder von residenten Programmen eingetragen.             *
 *                                                                      *
 * Sie dienen dazu, eine statische Schnittstelle zu anderen Programmen  *
 * herzustellen. Wenn beispielsweise ein residentes Programm (im AUTO-  *
 * Ordner) einen Cookie anlegt, dessen Wert ein Zeiger auf einen eige-  *
 * nen Datenbereich ist, kînnen andere Programme spÑter diesen Cookie   *
 * finden und auf die Daten des residenten Programms zugreifen. Atari   *
 * hat ausserdem einige Cookies definiert, die den Rechner und die      *
 * Hardware beschreiben.                                                *
 *                                                                      *
 * VORSICHT: Wenn Sie selbst eigene Cookies eintragen wollen, mÅssen    *
 * Sie einiges mehr an Wissen darÅber haben (z.B. Atari STE TOS Release *
 * Notes vom 12.1.90). Vor allem sollten Sie Cookies nur in residenten  *
 * Programmen erzeugen, jedoch _NIEMALS_ in Accessories oder Applika-   *
 * tionen.                                                              *
 *----------------------------------------------------------------------*
 *                                                                      *
 * Hinweis fÅr die Pascal-Implementation:                               *
 * Die Funktionen erwarten als Cookie-ID einen PASCAL-String, also mit  *
 * fÅhrendem LÑngenbyte! Intern wird auf einen C-String gewandelt.      *
 *----------------------------------------------------------------------*)

UNIT Cookie;

INTERFACE

(* Von Atari definierte Cookies, die den Rechner beschreiben. *)

CONST   CPU =           '_CPU'; (* Hauptprozessor: 0, 10, 20, 30 usw. *)
        FPU =           '_FPU'; (* Mathe-Koprozessor: 0, 1, 2 im HighWord *)
        Machine =       '_MCH'; (* Rechner; HighWord: 0=ST, 1=STE, 2=TT *)
        Video =         '_VDO'; (* Video-Hardware; HighWord: 0=ST, 1=STE, 2=TT *)
        Sound =         '_SND'; (* Bits im Longword: 0: GI/Yamaha(ST), 1: DMA(TT) *)
        Switches =      '_SWI'; (* BIOS-interne Konfigurationswerte *)
        FastReadBuff =  '_FRB'; (* Adresse des 64KB-Puffers f. Disk-Treiber im TT *)
        LaserPrinter =  '_SLM'; (* Wird vom Diablo-Treiber (ab Version 1.4) gesetzt. *)
        STeFix =        '_INF'; (* Fix fÅr den Desktop.Inf-Bug im Desktop des STE. *)
        DosFlock =      '_FLK'; (* GEMDOS verfÅgt Åber Record-Locking *)
        Network =       '_NET'; (* Typ des verwendeten Netzwerks *)
        Poolfix =       '_OOL'; (* Poolfix 3 von Atari Corp *)
        Speedo =        'FSMC'; (* Speedo-GDOS ab 4.2 *)
        DayTime =       '_IDT'; (* Datums und Zeitformat *)
        HdDisk =        '_FDC'; (* Laufwerk-Konfiguration ab TOS 2.06
                                 * im 1. Word  0 =  DD-Laufwerke (720/360kB)
                                 *             1 =  HD-Laufwerke (1.44MB)
                                 *             2 =  ED-Laufwerke (2.88MB)
                                 *)

(* Andere bekannte Cookies *)

CONST   Overscan =      'OVER'; (* Autoswitch-Overscan von K.Isakovic *)
        TOS14Fix =      'TFIX'; (* Tos14Fix *)
        VDIFix =        'VFIX'; (* VDIFix-Progamm von K.Isakovic *)
        ReflexCard =    'RFLX'; (* Treiber der Reflex-Karte von OverScan GbR *)
        NVDI =          'NVDI'; (* NVDI von Bela *)
        BigScreen2 =    'BIGS'; (* Groûbildschirmsimulator von Julian Reschke *)
        VirtualScreen = 'VSCR'; (* Zeiger auf Infostruktur von Bigscreen2 *)
        Gemini =        'GMNI'; (* GEMINI, der Shareware-Desktop *)
        Mupfel =        'MUPF'; (* MUPFEL von Gereon Steffens *)
        MakeJar =       'MkJr'; (* MakeCookiejar von Thomas Schallar *)
        TTTF =          'TTTF'; (* ThirtyTwoToTwentyFour von Marcel Waldvogel *)
        FileSelector =  'FSEL'; (* Extended Fileselector z.B. Patzelbox *)
        LetemFly =      'LTMF'; (* Let'em Fly von Oliver Scheel *)
        MiNT =          'MiNT'; (* MiNT *)
        MagX =          'MagX'; (* MagX von den Behne Bros. *)
        AFnt =          'AFnt'; (* AES-Font von Hayo Schmidt *)
        Magic =         'MPRO'; (* Magic 4.00 *)

(* Zum Zerlegen des Cookiewertes ohne groûe UmstÑnde *)
TYPE    Anytype =  RECORD
                    CASE x: INTEGER OF
                     0: (ptr: POINTER);
                     1: (long: LONGINT);
                     2: (hi, lo: INTEGER);
                     3: (b4, b3, b2, b1: BYTE);
                   END;


TYPE tId = ARRAY [0..3] OF CHAR;

FUNCTION FindCookie (id: tId; VAR value: LONGINT): BOOLEAN;
(* Liefert TRUE, wenn der Cookie 'id' gefunden wird. In 'value' 
 * steht der dazugehîrige Longword-Wert, bei FALSE ist 'value' 
 * immer Null.
 *)

FUNCTION ModifyCookie (id: tId; newvalue: LONGINT): BOOLEAN;
(* Sucht den Cookie 'id' und liefert FALSE, wenn er nicht vorhanden 
 * ist. Wird er gefunden, wird 'value' als neuer Cookie-Wert einge-
 * setzt und die Funktion liefert TRUE.
 *)

FUNCTION AddCookie (id: tId; value: LONGINT): BOOLEAN;
(* Installiert einen Cookie, sucht vorher 'id' und schreibt den Wert
 * value, wenn er schon vorhanden ist.  Ist der Cookie nicht da, Wird er
 * am Ende der Cookieliste angehÑngt. ACHTUNG!!!  Wenn kein Platz mehr
 * fÅr den Cookie da ist, oder kein Jar vorhanden ist, wird KEIN NEUER
 * JAR INSTALLIERT!!!
 *)

FUNCTION DelCookie (id: tId): BOOLEAN;
(* Lîscht einen installierten Cookie. Sollte man immer machen, wenn man
 * wÑrend der Laufzeit einer Applikation einen Cookie installiert hat, und
 * nun terminieren will!!!
 *)


TYPE  Listmode = (first, next);

FUNCTION ListCookies (flag: Listmode; id: tId; 
                      VAR value: LONGINT; VAR num: INTEGER): BOOLEAN;
(* Geht die Liste aller Cookies durch. (Einmal mit first, dann mit next
 * aufrufen). Solange die Prozedur TRUE liefert, sind Cookies gefunden
 * worden. Bei FALSE sind 'id' und 'value' undefiniert!  'num' ist die
 * Nummer des Cookies in der Liste!
 *)

FUNCTION MaxCookies: INTEGER;
(* Anzahl der zur VerfÅgung stehenden Cookies *)

FUNCTION UsedCookies: INTEGER;
(* Anzahl der zur belegten Cookies *)

FUNCTION JarInstalled: BOOLEAN;
(* TRUE, wenn ein Cookiejar installiert ist. sollte ab TOS 1.06
 * immer der Fall sein...
 *)

IMPLEMENTATION

(*----------------------------------------------------------------------*
 * Int. Vers | Datum    | Name | énderung                               *
 *-----------+----------+------+----------------------------------------*
 *  1.00     | 11.04.92 |  Hp  | Modula-2 to Pascal                     *
 *  1.01     | 21.02.93 |  Hp  | Routinen zum Installieren und Lîschen  *
 *           |          |      | von Cookies implementiert              *
 *-----------+----------+------+----------------------------------------*)

USES OS;

{$I COMPOPT.INC}

CONST   MaxCooks =      1024; (* Mehr Cookies wird ja wohl keiner haben *)

TYPE    tCookie =       RECORD
                         id:  LONGINT;
                         val: LONGINT;
                        END;

TYPE    tJar =          ^Jarlist;
        Jarlist =       ARRAY [0..MaxCooks] OF tCookie;

VAR     dummy:          RECORD
                         CASE BOOLEAN OF
                          TRUE:  (str: ARRAY [0..3] OF CHAR); (* Identifier *)
                          FALSE: (lc: LONGINT);
                        END;

VAR     JarPtr:         tJar ABSOLUTE $05A0;
        Jar:            tJar;
        NoJar:          POINTER;

VAR     NullCookie:     RECORD
                         id:  LONGINT;
                         val: LONGINT;
                        END;

FUNCTION GetJar: LONGINT;
(* Muû im Supervisormode ausgefÅhrt werden! *)
BEGIN
 Jar:= JarPtr;
 GetJar:= 0;
END (*GetJar*);

FUNCTION FindCookie (id: tId; VAR value: LONGINT): BOOLEAN;
VAR c: INTEGER;
    b: BOOLEAN;
BEGIN
 b:= FALSE;
 Supexec (GetJar);
 IF Jar <> NoJar THEN BEGIN
  FOR c:= 0 TO 3 DO  dummy.str[c]:= id[c];
  c:= 0;
  WHILE NOT b DO BEGIN
   IF Jar^[c].id = dummy.lc THEN BEGIN
    value:= Jar^[c].val;  b:= TRUE;
   END ELSE IF (Jar^[c].id = 0) THEN BEGIN
    FindCookie:= FALSE;
    EXIT;
   END;
   INC (c);
  END;
 END;
 FindCookie:= b;
END (*FindCookie*);

FUNCTION ModifyCookie (id: tId; newvalue: LONGINT): BOOLEAN;
VAR c: INTEGER;
    b: BOOLEAN;
BEGIN
 b:= FALSE;
 Supexec (GetJar);
 IF Jar <> NoJar THEN BEGIN
  FOR c:= 0 TO 3 DO  dummy.str[c]:= id[c];
  c:= 0;
  WHILE (Jar^[c].id <> 0) AND NOT b DO BEGIN
   IF Jar^[c].id = dummy.lc THEN BEGIN
    Jar^[c].val:= newvalue;  b:= TRUE;
   END;
   INC (c);
  END;
 END;
 ModifyCookie:= b;
END (*ModifyCookie*);

VAR cook: INTEGER;

FUNCTION ListCookies (flag: Listmode; id: tId; 
                      VAR value: LONGINT; VAR num: INTEGER): BOOLEAN;
VAR c: INTEGER;
    ok: BOOLEAN;
BEGIN
 id[0]:= #0;  value:= 0;  ok:= FALSE;
 IF flag = first THEN BEGIN  cook:= 0;  END;
 IF cook > -1 THEN BEGIN
  Supexec (GetJar);
  IF Jar <> NoJar THEN BEGIN
   IF Jar^[cook].id <> 0 THEN BEGIN
    value:= Jar^[cook].val;  (* Den Cookie-Wert Åbertragen *)
    dummy.lc:= Jar^[cook].id;  (* den Longcard in einen String wandeln *)
    FOR c:= 0 TO 3 DO  id[c]:= dummy.str[c];
    num:= cook;
    INC (cook); (* NÑchster Cookie *)
    ok:= TRUE;
   END ELSE BEGIN
    id:= 'NULL';
    value:= Jar^[cook].val;  (* Den Cookie-Wert Åbertragen *)
    num:= cook;
    cook:= -1; (* NÑchster Cookie *)
    ok:= TRUE;
   END;
  END;
 END;
 ListCookies:= ok;
END (*ListCookies*);

FUNCTION AddCookie (id: tId; value: LONGINT): BOOLEAN;
VAR c, cc: INTEGER;
BEGIN
 IF ModifyCookie (id, value) THEN BEGIN
  AddCookie:= TRUE;  EXIT;
 END;
 Supexec (GetJar);  cc:= 0;
 (* Null-Cookie suchen *)
 WHILE Jar^[cc].id <> 0 DO  INC (cc);
 IF cc < (Jar^[cc].val - 1) THEN BEGIN (* Noch Platz *)
  (* NULL-Cookie umkopieren *)
  Jar^[cc+1].id:= Jar^[cc].id;
  Jar^[cc+1].val:= Jar^[cc].val;
  FOR c:= 0 TO 3 DO  dummy.str[c]:= id[c];
  Jar^[cc].id:= dummy.lc;
  Jar^[cc].val:= value;
  AddCookie:= TRUE;  EXIT;
 END;
 AddCookie:= FALSE;
END (*AddCookie*);

FUNCTION DelCookie (id: tId): BOOLEAN;
VAR c, cc, nc: INTEGER;
    val: LONGINT;
BEGIN
 IF NOT FindCookie (id, val) THEN BEGIN
  DelCookie:= FALSE;  EXIT;
 END;
 (* Cookie suchen *)
 FOR c:= 0 TO 3 DO  dummy.str[c]:= id[c];
 Supexec (GetJar);
 (* Den zu lîschenden Cookie suchen *)
 cc:= 0;  WHILE Jar^[cc].id <> dummy.lc DO  INC (cc);
 (* Null-Cookie suchen *)
 nc:= 0;  WHILE Jar^[nc].id <> 0 DO  INC (nc);
 WHILE cc < nc DO BEGIN
  Jar^[cc].id:= Jar^[cc+1].id;
  Jar^[cc].val:= Jar^[cc+1].val;
  INC (cc);
 END;
 DelCookie:= TRUE;
END (*DelCookie*);

FUNCTION MaxCookies: INTEGER;
VAR c: INTEGER;
    v: Anytype;
BEGIN
 c:= 0;  v.long:= 0;
 Supexec (GetJar);
 IF Jar <> NoJar THEN BEGIN
  (* Null-Cookie suchen *)
  WHILE Jar^[c].id <> 0 DO  INC (c);
  v.long:= Jar^[c].val;
 END;
 MaxCookies:= v.long;
END (*MaxCookies*);

FUNCTION UsedCookies: INTEGER;
VAR c: INTEGER;
BEGIN
 c:= 0;
 Supexec (GetJar);
 IF Jar <> NoJar THEN BEGIN
  WHILE Jar^[c].id <> 0 DO  INC (c);
 END;
 UsedCookies:= c;
END (*UsedCookies*);

FUNCTION JarInstalled: BOOLEAN;
BEGIN
 Supexec (GetJar);
 JarInstalled:= Jar <> NoJar;
END (*JarInstalled*);

BEGIN
 cook:= 0;
 NoJar:= POINTER (0);
 NullCookie.id:= 0;
 NullCookie.val:= 0;
END (*Cookie*).
