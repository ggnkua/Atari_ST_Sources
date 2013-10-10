DEFINITION MODULE Lists;
(*$H+*)

(*
 * Allgemeine Listenverwaltung.
 *
 * Nach 'ADTLists' aus: Dal Cin, Lutz, Risse: Programmierung in Modula-2.
 *
 * Erstellt 22.3.87, TT
 *)

(* ----------------------------------------------------------------------------

    Listen allgemein erlauben, mehrere Datenfelder nacheinander in belie-
    biger Anzahl anzulegen und selektiv wieder zu entfernen. Im Gegensatz
    dazu besteht eine Tabelle aus einem einmalig anfangs zu definierenden
    Speicherbereich, in dem die Daten abgelegt werden und das Ein- oder
    AusfÅgen nur durch aufwendiges Umkopieren mîglich ist. Bei Listen wird
    immer nur soviel Speicher belegt, wie Datenfelder benîtigt werden.

    Die Verwaltung von Listen ist im Vergleich zu Tabellen aufwendiger.
    Dieses Modul bietet dafÅr komfortable Funktionen.

    Eine Liste wird Åber eine Variable der Type 'List' angelegt und ver-
    waltet. öber sie werden alle Elemente der Liste verkettet. Ist die
    Liste leer, existiert nur das Wurzel-Element, das zur internen Ver-
    waltung dient. Auf die Wurzel kann das Anwenderprogramm nicht zugrei-
    fen. Wird die Liste um neue Elemente erweitert, sind alle Elemente
    ringweise verkettet. Gestartet wird Åblicherweise bei der Wurzel.
    Von dort aus kann jedes Element schrittweise im Kreis erreicht werden.
    Am Ende wird wieder die Wurzel erreicht. Da die Liste intern mit
    Zeigern verkettet wird, ist 'List' als ein Record mit zwei Zeigern
    auf eine interne Datenstruktur definiert. Das Record-Element
    'List.root' zeigt immer auf die Wurzel der Liste, 'List.current' zeigt
    auf das gerade bearbeitete Element der Liste. 'List.user' kann vom
    Anwenderprogramm verwendet werden, um 'current' zeitweise darin zu
    sichern und rÅckzuspeichern. 'List.user' wird von diesen Funktionen
    nur Anfangs beim Erzeugen einer Liste mit 'CreateList' auf 'root'
    gesetzt, danach nicht mehr verÑndert, es sei denn, beim Lîschen eines
    Elements ('RemoveEntry') war 'current' = 'user'. Dann wird 'user', wie
    'current', auf den VorgÑnger gesetzt.

    Da Modula-2 keine generischen Datenstukturen kennt, mu·, um beliebige
    Daten als Liste verwalten zu kînnen, das Anwenderprogramm die Daten
    selbst anlegen (z.B. mit NEW oder ALLOCATE). Die Listenfunktionen
    speichern nur die Adressen (Zeiger auf) die Daten. Bei Entfernen
    eines Elements mu· daher nicht nur das Element aus der Liste wieder
    entfernt werden (mit einer Funktion dieses Moduls) sondern auch der
    Speicher fÅr das Datum wieder freigegeben werden (z.B. mit DISPOSE
    oder DEALLOCATE).

    Hinweis
    -------

    In einigen Modulen des MOS werden Listen verwendet (z.B. in 'Paths',
    'Loader'). Dabei werden diese Listen in der Regel durch einen
    neuen TYPE definiert, welcher wiederum exportiert wird (z.B in
    'Paths':  "TYPE  PathList = List (* OF PathEntry *)"). Hinter
    den Definitionen erscheint dann in Klammern "OF" mit einer anderen
    Type. Dies bedeutet, daû alle Listenelemente Åber diese Type
    angesprochen werden mÅssen. So sind beispielsweise Funktionsergebnisse,
    wie 'NextEntry' (Lists-Funktion, s.u.), die ja normalerweise einen
    beliebigen ADDRESS-Typen darstellen, hier als 'PathEntry' zu verwenden
    ('PathEntry' ist beispielsweise ein "POINTER TO PathStr"), damit
    der korrekte Zugriff auf die Listenelemente gewÑhrleistet ist.


    Beispiel
    --------

    Ein Liste wird erzeugt und darin drei Daten eingefÅgt, ausgegeben,
    dann ein Element gelîscht und wieder alle Elemente ausgegeben.
    Am Ende wird die gesamte Liste entfernt.


    MODULE ListDemo;

    IMPORT InOut, Lists, Strings;

    FROM SYSTEM IMPORT ADDRESS, ADR;

    FROM Storage IMPORT ALLOCATE, DEALLOCATE;

    TYPE DataStr = ARRAY [0..20] OF CHAR;
         DatenType = RECORD
                       (* beliebige Datendefinition *)
                       no: CARDINAL;
                       s: DataStr
                     END;

         Element = POINTER TO DatenType;

    VAR myList: Lists.List;
        error: BOOLEAN;

    PROCEDURE stop (s: ARRAY OF CHAR);               (* Fehleranzeige *)
      VAR c: CHAR;
      BEGIN InOut.WriteString (s); InOut.Read (c); InOut.WriteLn END stop;

    PROCEDURE insElem (no: CARDINAL; s: ARRAY OF CHAR); (* Elem. anfÅgen *)
      VAR elem: Element; ok: BOOLEAN;
      BEGIN
        NEW (elem);                                  (* Speicher anfordern *)
        elem^.no:= no;                               (* Daten eintragen *)
        Strings.Assign (s, elem^.s, ok);
        Lists.InsertEntry (myList, elem, error); (* Elem. in Liste eintragen *)
        IF error THEN stop ('Kein Speicher') END
      END insElem;

    PROCEDURE showElems;                           (* Alle Elemente anzeigen *)
      VAR elem: Element;
      BEGIN
        Lists.ResetList (myList);               (* Liste auf Anfang (Wurzel) *)
        InOut.WriteString ('Alle Daten:');
        InOut.WriteLn;
        REPEAT
          elem:= Lists.NextEntry (myList);           (* NÑchstes Elem. holen *)
          IF elem <> NIL THEN                        (* Wenn nicht Wurzel... *)
            InOut.WriteString ('no: ');
            InOut.WriteCard (elem^.no, 0);
            InOut.WriteString (', s: ');
            InOut.WriteString (elem^.s);             (* ... dann ausgeben    *)
            InOut.WriteLn
          END
        UNTIL elem = NIL  (* oder: "UNTIL List.LastEntry (myList)" *)
      END showElems;

    PROCEDURE checkElem (elem, txt: ADDRESS): BOOLEAN;
      VAR elem0: Element; txt0: POINTER TO DataStr;
      BEGIN                                               (* Elemente prÅfen *)
        elem0:= elem; txt0:= txt;
        RETURN Strings.StrEqual (elem0^.s, txt0^)
                                        (* Vergl. aktuelles 's' mit Suchtext *)
      END checkElem;

    PROCEDURE search (txt: DataStr);             (* Sucht bestimmtes Element *)
      VAR found: BOOLEAN;
      BEGIN
        Lists.ScanEntries (myList, Lists.forward, checkElem, ADR (txt), found);
          (* Hiermit wird, wenn 'checkElem' fÅndig wird, 'current' auf *)
          (* das gefundene Element gesetzt.                            *)
        IF NOT found THEN stop ('Nicht gefunden.') END
      END search;

    PROCEDURE removeElem;
      VAR elem: Element;
      BEGIN
        elem:= Lists.CurrentEntry (myList); (* Akt. Element ermitteln *)
        DISPOSE (elem);                     (* Speicher v. Element freigeben *)
        Lists.RemoveEntry (myList, error);  (* Element aus Liste entfernen *)
      END removeElem;

    PROCEDURE removeAllElems;                   (* Alle Elemente freigeben *)
      BEGIN
        Lists.ResetList (myList);
        WHILE Lists.NextEntry (myList) <> NIL DO removeElem END;
      END removeAllElems;

    VAR c: CHAR;

    BEGIN
      Lists.CreateList (myList, error);               (* Liste anlegen *)
      IF error THEN stop ('Kein Speicher') END;
      insElem (1, 'Eins');                            (* Daten anfÅgen *)
      insElem (2, 'Zwei');
      insElem (3, 'Drei');
      showElems;                                  (* Alle Elemente zeigen *)
      search ('Zwei');                            (* Elem. m. 'Zwei' suchen *)
      removeElem;                                 (* Dies Element entfernen *)
      showElems;                                  (* Alle Elemente zeigen *)
      removeAllElems;                             (* Alle Elemente entfernen *)
      Lists.DeleteList (myList, error);           (* Liste entfernen *)
      IF error THEN stop ('Liste nicht leer !') END;
      InOut.Read (c)
    END ListDemo.

---------------------------------------------------------------------------- *)

FROM SYSTEM IMPORT ADDRESS;

TYPE    LCarrier;

        List = RECORD
                 current: LCarrier;
                 root   : LCarrier;
                 user   : LCarrier
               END;

        LCondProc = PROCEDURE ( (* entry: *) ADDRESS,
                                (* info : *) ADDRESS ): BOOLEAN;

        LDir = ( forward,  (* vorwÑrts  *)
                 backward  (* rÅckwÑrts *) );

PROCEDURE InitList ( VAR l: List );
  (*
   * Initialisiert die Liste 'l', sodaû sie definierte Werte
   * enthÑlt (hierbei wird nicht, wie bei CreateList, eine Liste
   * angelegt, lediglich wird ein Grundzustand hergestellt)
   * Diese Funktion ist nur notwendig, wenn schon auf die Liste
   * mit anderen Lists-Funktionen zugegriffen werden kann, bevor
   * sie mit 'CreateList' angelegt wird.
   *)

PROCEDURE CreateList ( VAR list: List; VAR error: BOOLEAN );
  (*
   * Erzeugt neue, leere Liste.
   * 'error':= "Kein Speicher mehr frei"
   *)

PROCEDURE DeleteList ( VAR list: List; VAR error: BOOLEAN );
  (*
   * Entfernt leere Liste.
   * 'error':= "Liste ist nicht leer"
   *)

PROCEDURE ResetList ( VAR list: List );
  (*
   * Ernennt die Wurzel (list.root) zum aktuellen Eintrag.
   *)

PROCEDURE ListEmpty ( VAR list: List ): BOOLEAN;
  (*
   * Liefert TRUE, wenn die Liste leer ist, also keine EintrÑge hat.
   *)

PROCEDURE InsertEntry ( VAR list: List; entry: ADDRESS; VAR error: BOOLEAN );
  (*
   * FÅgt Eintrag hinter an aktueller Position ein; 'list.current' wird auf
   * neuen Eintrag gesetzt.
   * 'error':= "Kein Speicher mehr frei"
   *)

PROCEDURE RemoveEntry ( VAR list: List; VAR error: BOOLEAN );
  (*
   * Entfernt aktuellen Eintrag. 'current' wird auf VorgÑnger gesetzt.
   * 'error':= "list.current zeigt auf Wurzel (=list.root)"
   *)

PROCEDURE AppendEntry ( VAR list: List; entry: ADDRESS; VAR error: BOOLEAN );
  (*
   * FÅgt Eintrag am Listenende an; 'list.current' bleibt unverÑndert.
   * 'error':= "Kein Speicher mehr frei"
   *)

PROCEDURE CurrentEntry ( VAR list: List ): ADDRESS;
  (*
   * Liefert aktuellen Eintrag; liefert NIL, wenn 'current'='root'.
   *)

PROCEDURE NextEntry ( VAR list: List ): ADDRESS;
  (*
   * Liefert nÑchsten Eintrag, setzt 'current' darauf; liefert NIL, wenn
   * 'current'='root'.
   *)

PROCEDURE PrevEntry ( VAR list: List ): ADDRESS;
  (*
   * Liefert vorigen Eintrag, setzt 'current' darauf; liefert NIL, wenn
   * 'current'='root'.
   *)

PROCEDURE FindEntry ( VAR list: List; entry: ADDRESS; VAR found: BOOLEAN );
  (*
   * Durchsucht ganze Liste nach einem Eintrag in VorwÑrtsrichtung.
   * FÑngt dabei hinter dem aktuellen Eintrag an.
   * Wird der Eintrag gefunden, zeigt 'list.current' darauf. Sonst wird
   * 'list.current' auf die Wurzel gesetzt (wie bei ResetList).
   * 'found':= "Eintrag gefunden"
   *)

PROCEDURE ScanEntries ( VAR list: List; dir: LDir;
                        cond: LCondProc; info: ADDRESS;
                        VAR found: BOOLEAN );
  (*
   * Durchsucht die Liste in der gewÅnschten Reihenfolge ('dir'), beginnend
   * beim nÑchsten Eintrag (wie 'NextEntry').
   * Dabei wird jedesmal die Prozedur 'cond' aufgerufen und ihr der aktuelle
   * Eintrag Åbergeben. Diese Prozedur kann dann entscheiden, ob weitergesucht
   * werden soll, indem sie FALSE (weiter) oder TRUE (gefunden, abbrechen)
   * zurÅckgibt. Ihr kann, z.B. als Zeiger auf einen Vergleichswert, in 'info'
   * ein Pointer Åbergeben werden.
   * Die an 'cond' Åbergebene Protedur darf lokal sein!
   * 'found':= "Eintrag gefunden ('cond' lieferte TRUE)"
   *)

PROCEDURE EndOfList ( VAR list: List ): BOOLEAN;
  (*
   * Liefert TRUE, wenn 'current' = 'root' ist, also wenn der aktuelle
   * Eintrag die Wurzel ist.
   *)

PROCEDURE NoOfEntries ( VAR list: List ): CARDINAL;
  (*
   * Liefert Anzahl der vorhandenen EintrÑge.
   *)

PROCEDURE FirstEntry ( VAR list: List ): BOOLEAN;
  (*
   * Liefert TRUE, wenn der VorgÑnger die Wurzel ist.
   *)

PROCEDURE LastEntry ( VAR list: List ): BOOLEAN;
  (*
   * Liefert TRUE, wenn der Nachfolger die Wurzel ist.
   *)

PROCEDURE SysCreateList ( VAR list: List; VAR error: BOOLEAN );

END Lists.
