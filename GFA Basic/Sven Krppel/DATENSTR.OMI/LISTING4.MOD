(**********************************************
*                 Listing 4                   *
*  BehÑltersortieren mit linearen Listen      *
*                                             *
*  Sven KrÅppel 1.1.1991, (c) MAXON Computer  *
*  geschrieben mit dem ETH-Modula 2-System    *
**********************************************)

MODULE Listing4;

FROM InOut IMPORT Write,WriteString,WriteLn;
FROM Heap IMPORT Allocate, Deallocate;

CONST MaxN=20; (* Anzahl max. zu sortierender
                  Records *)
      MinKey="A"; (* kleinster SchlÅsselwert *)
      MaxKey="Z"; (* grî·ter SchlÅsselwert  *)
      MaxLaenge=15; (* max. StringlÑnge *)

TYPE String = ARRAY [1..MaxLaenge] OF CHAR;
     KeyTyp = [MinKey..MaxKey]; (* Wertebereich
                          der SchlÅsselwerte *)
     ObjTyp = RECORD  (* Record fÅr Daten *)
                Key : KeyTyp; (* SchlÅssel *)
                Text: String;
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
     i : CARDINAL;


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
    Write(p^.Obj.Key);
    WriteString("   ");
    WriteString(p^.Obj.Text);
    WriteLn;
    p:=p^.Next;
  END(*WHILE*);
  WriteLn;
END LLAusgeben;

(*********************************************
*                                            *
*              BehÑltersortieren             *
*                                            *
*********************************************)

PROCEDURE BinSort(VAR S : STyp);

VAR B : ARRAY KeyTyp OF STyp; (* Feld mit
                                 BehÑltern *)
    p : ObjLPtr; (* Hilfszeiger *)
    i : KeyTyp;  (* Laufvariable *)

BEGIN

 (* BehÑlter lîschen *)
 FOR i:=MinKey TO MaxKey DO
   B[i].Anfang:=NIL;
   B[i].Ende:=NIL;
 END;

 (* Schlange S in BehÑlter sortieren *)
 (* Es wird jeweils der Listenanfang von S
    in einen BehÑlter einsortiert.
    LLAnhaengen zerstîrt den Next-Zeiger
    des Listenanfangs. Deshalb muû ein Zeiger
    auf das jeweils zweite Listenelement
    zwischengespeichert werden.
 *)
 WHILE S.Anfang<>NIL DO
   p:=S.Anfang^.Next; (* Zeiger auf nÑchstes
                         Element retten *)
   LLAnhaengen(B[S.Anfang^.Obj.Key],S.Anfang);
   S.Anfang:=p;
 END;

 (* BehÑlter auflîsen und sortierte
    Liste generieren
 *)
 S.Anfang:=NIL;
 S.Ende:=NIL;
 FOR i:=MinKey TO MaxKey DO
   IF B[i].Anfang<>NIL THEN (* Schlange in
      BehÑlter B[i] nicht leer => verbinden *)
      LLVerbinden(S,B[i]);
   END;
 END;
END BinSort;


(*********************************************
*  Eine lineare Liste aus einem Feld mit     *
*  Daten generieren.                         *
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
   p^.Obj.Key:=F[i].Key;
   p^.Obj.Text:=F[i].Text;
   LLAnhaengen(L,p);
 END(*FOR*);
END ErzeugeListeAusFeld;

BEGIN (* Hauptprogramm *)
  (* Feld mit Testdaten initialisieren *)
  TF[1].Key:="B"; TF[1].Text:="Bruno";
  TF[2].Key:="A"; TF[2].Text:="Anna";
  TF[3].Key:="K"; TF[3].Text:="Klaus";
  TF[4].Key:="F"; TF[4].Text:="Fritz";
  TF[5].Key:="K"; TF[5].Text:="Kuni";
  TF[6].Key:="H"; TF[6].Text:="Heike";
  TF[7].Key:="F"; TF[7].Text:="Franz";
  TF[8].Key:="Z"; TF[8].Text:="Zenzi";
  TF[9].Key:="B"; TF[9].Text:="Bernd";
  TF[10].Key:="E"; TF[10].Text:="Emil";

  N:=10;
  (* Liste mit Testdaten generieren *)
  ErzeugeListeAusFeld(TF,TL);

  LLAusgeben(TL);
  BinSort(TL); (* Liste sortieren *)
  LLAusgeben(TL);

END Listing4.

