(**********************************************
*                 Listing 9                   *
*   Radixsort fÅr Zeichenketten-Sortierung    *
*        Sortierung nach ASCII-Werten         *
*                                             *
*  Sven KrÅppel  (c) MAXON Computer 1991      *
*  geschrieben mit dem ETH-Modula 2-System    *
**********************************************)

MODULE Listing9;

FROM InOut IMPORT Write,WriteString,WriteLn;
FROM Heap IMPORT Allocate, Deallocate;
FROM Strings IMPORT Length;

CONST MaxN=100; (* Anzahl max. zu sortierender
                  Records *)
      MinKey="0"; (* kleinster SchlÅsselwert *)
      MaxKey="û"; (* grî·ter SchlÅsselwert  *)
      MaxLaenge=15; (* max. StringlÑnge *)

TYPE String = ARRAY [1..MaxLaenge] OF CHAR;
     KeyTyp = [MinKey..MaxKey]; (* Wertebereich
                          der SchlÅsselwerte *)
     ObjTyp = RECORD  (* Record fÅr Daten *)
                Wort : String; (* Wîrter *)
                (* <weitere Infokomponenten> *)
              END;
     ObjFTyp= ARRAY [1..MaxN] OF ObjTyp;
     ObjLPtr= POINTER TO ObjLTyp;
     ObjLTyp= RECORD (* Schlangenelement *)
                 Obj  : ObjTyp;
                 Next : ObjLPtr;
               END;
     STyp   = RECORD (* Schlangen-, Listentyp*)
                Anfang : ObjLPtr;
                Ende   : ObjLPtr;
              END;

VAR  N : CARDINAL; (* Anzahl zu sortierender
                      Records *)
    TF : ObjFTyp;  (* Feld mit Testdaten *)
    TL : STyp;     (* Liste mit Testdaten *)
     p : ObjLPtr;  (* Hilfszeiger *)
     i : CARDINAL; (* Laufvariable *)


(*********************************************
*  Element an eine lineare Liste anhÑngen    *
*  Dies entspricht dem EinfÅgen in eine      *
*  Schlange                                  *
*********************************************)

PROCEDURE LLAnhaengen(VAR L:STyp; P:ObjLPtr);
(* Element, auf das 'P' zeigt, an die lineare
   Liste 'L' hÑngen. Diese Operation ent-
   spricht dem EinfÅgen in eine Schlange.
*)
BEGIN
  IF P <> NIL THEN
    P^.Next:=NIL;   (* neues Listenende
                       markieren *)
    IF L.Anfang=NIL THEN (* Liste ist leer *)
       L.Anfang:=P;
    ELSE (* Liste war nicht leer *)
       L.Ende^.Next:=P;(* Element anhÑngen,
                          auf das P zeigt *)
    END;
    L.Ende:=P;  (* Zeiger auf das
                   Listenende umbiegen *)
  END (* IF *)
END LLAnhaengen;

(*********************************************
*  Zwei Listen verbinden                     *
*********************************************)

PROCEDURE LLVerbinden(VAR L1, L2: STyp);
(* Liste 'L2' wird an Liste 'L1' gehÑngt. Die
   Ergebnisliste ist 'L1'.
*)
BEGIN
IF L1.Anfang=NIL THEN (* 1. Liste ist leer *)
   L1:=L2;
ELSIF L2.Anfang<>NIL THEN (* 2. Liste nicht
                             leer *)
   L1.Ende^.Next:=L2.Anfang; (* verbinden *)
   L1.Ende:=L2.Ende
END;
END LLVerbinden;

(*********************************************
*  Liste ausgeben                            *
*********************************************)

PROCEDURE LLAusgeben(L : STyp);
VAR p : ObjLPtr;
BEGIN
  p:=L.Anfang;
  WHILE p<>NIL DO
    WriteString(p^.Obj.Wort);
    WriteLn;
    p:=p^.Next;
  END(*WHILE*);
  WriteLn;
END LLAusgeben;


(*********************************************
*                                            *
*             Radix-Sortierung               *
*                                            *
* Die Prozedur RadixSort enthÑlt mehrere     *
* lokale Prozeduren.                         *
*********************************************)

PROCEDURE RadixSort(VAR S : STyp);

VAR B : ARRAY KeyTyp OF STyp; (* Feld mit
                                 BehÑltern *)
    L : ARRAY [0..MaxLaenge] OF STyp; (* Feld
                        mit BehÑltern fÅr die
                        LÑngensortierung *)
    CharNr : CARDINAL; (* Position des Zeichens,
                          das als SchlÅssel be-
                          nutzt wird *)

(*********************************************
*          lokale Prozeduren                 *
*********************************************)


(***********  LÑngen-Sortierung *************)

PROCEDURE LaengenSort(VAR S : STyp);
(* Die Prozedur sortiert die Strings der
   Schlange S bezÅglich der WortlÑnge
   in die BehÑlter L. Die BehÑlter speichern
   nach dem Aufruf die Schlangen der entspre-
   chenden WortlÑnge. Sie werden nicht aufge-
   lîst. S ist nach dem Aufruf undefiniert,
   da die Schlange S nicht mehr existiert.
*)
VAR p : ObjLPtr;  (* Hilfszeiger *)
    i : CARDINAL; (* Laufvariable *)

BEGIN
 (* BehÑlter L lîschen *)
 FOR i:=0 TO MaxLaenge DO
   L[i].Anfang:=NIL;
   L[i].Ende:=NIL;
 END;

 (* S in die BehÑlter sortieren *)
 (* nÑhere ErlÑuterungen bei Binsort() *)
 WHILE S.Anfang<>NIL DO
   p:=S.Anfang^.Next; (* Zeiger auf nÑchstes
                         Element retten *)
   LLAnhaengen(L[Length(S.Anfang^.Obj.Wort)],
               S.Anfang);
   S.Anfang:=p;
 END;
END LaengenSort;


(********* BehÑlter B initialisieren ********)
PROCEDURE BInit(MinCh, MaxCh : KeyTyp);
VAR i : KeyTyp;
BEGIN
 FOR i:=MinKey TO MaxKey DO
   B[i].Anfang:=NIL;
   B[i].Ende:=NIL;
 END;
END BInit;


(***********  BehÑltersortieren *************)

PROCEDURE BinSort(VAR S : STyp;
                      CharNr : CARDINAL);
(* Die Prozedur sortiert die Strings der
   Schlange S bezÅglich des CharNr-ten Zeichens
   in die BehÑlter B.
*)
VAR p : ObjLPtr; (* Hilfszeiger *)
    Char,        (* Hilfsvariable *)
    MinChar, MaxChar, (* kleinstes bzw. grîûtes
                      aufgetretenes Zeichen *)
    i : KeyTyp;  (* Laufvariable *)

BEGIN

 (* Schlange S in BehÑlter sortieren *)
 (* Es wird jeweils der Listenanfang von S
    in einen BehÑlter einsortiert.
    LLAnhaengen zerstîrt den Next-Zeiger
    des Listenanfangs. Deshalb muû ein Zeiger
    auf das jeweils zweite Listenelement
    zwischengespeichert werden.
 *)
 MinChar:=MaxKey; (* beginne mit dem    *)
 MaxChar:=MinKey; (* schlechtesten Fall *)
 WHILE S.Anfang<>NIL DO
   p:=S.Anfang^.Next; (* Zeiger auf nÑchstes
                         Element retten *)
   Char:=S.Anfang^.Obj.Wort[CharNr];
   IF Char<MinChar THEN MinChar:=Char END;
   IF Char>MaxChar THEN MaxChar:=Char END;
   LLAnhaengen(B[Char], S.Anfang);
   S.Anfang:=p;
 END;

 (* BehÑlter auflîsen und sortierte
    Liste generieren. Dabei werden die
    BehÑlter gelîscht.
 *)
 S.Anfang:=NIL;
 S.Ende:=NIL;
 FOR i:=MinKey TO MaxKey DO
   IF B[i].Anfang<>NIL THEN (* Schlange in
      BehÑlter B[i] nicht leer => verbinden *)
      LLVerbinden(S,B[i]);
      B[i].Anfang:=NIL;
      B[i].Ende:=NIL;
   END;
 END;
END BinSort;


(*********************************************
*      Hauptprozedur : RadixSort             *
*********************************************)

BEGIN (* RadixSort *)
  LaengenSort(S);

  BInit(MinKey, MaxKey);
  FOR CharNr:=MaxLaenge TO 1 BY -1 DO
    IF L[CharNr].Anfang # L[CharNr].Ende THEN
      (* nur sortieren, wenn die Schlange mehr
         als ein Wort enthÑlt *)
      BinSort(L[CharNr], CharNr);
    END;
    LLVerbinden(L[CharNr-1], L[CharNr]);
  END(*FOR*);
  S.Anfang:=L[0].Anfang;
  S.Ende:=L[0].Ende;
END RadixSort;


(*********************************************
*           Testliste generieren             *
*********************************************)

PROCEDURE ErzeugeListeAusFeld(F : ObjFTyp;
          VAR L : STyp);
(* Die Liste L wird zurÅckgegeben *)
VAR p : ObjLPtr; (* Hilfszeiger *)
    i : CARDINAL;
BEGIN
 L.Anfang:=NIL;
 L.Ende:=NIL;
 FOR i:=1 TO N DO
   Allocate(p,SIZE(ObjLTyp));
   p^.Obj.Wort:=F[i].Wort;
   LLAnhaengen(L,p);
 END(*FOR*);
END ErzeugeListeAusFeld;

BEGIN (* Hauptprogramm *)
  (* Feld mit Testdaten initialisieren *)
  TF[1].Wort:="Bruno";
  TF[2].Wort:="Anna";
  TF[3].Wort:="Klaus";
  TF[4].Wort:="Fritz";
  TF[5].Wort:="Kunigunde";
  TF[6].Wort:="Ira";
  TF[7].Wort:="Franz";
  TF[8].Wort:="Susanne";
  TF[9].Wort:="Bernd";
  TF[10].Wort:="Emil";

  N:=10;
  (* Liste mit Testdaten generieren *)
  ErzeugeListeAusFeld(TF,TL);

  LLAusgeben(TL);
  RadixSort(TL); (* Liste sortieren *)
  LLAusgeben(TL);

END Listing9.


