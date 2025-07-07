(*****************************************************************************)
(*****************************************************************************)
(*                                                                           *)
(*  M A T H L I B   (c) 01. MÑrz 1987        TYPE - Deklarationen            *)
(*  =============   -----------------                                        *)
(*                                                                           *)
(*   MATHLIB  ist  eine   Bibliothek  mit   mathematischen   Funktionen  und *)
(*  Prozeduren.  Um  MATHLIB  verwenden  zu kînnen,  muû es in  compilierter *)
(*  Form vorliegen. NÑheres entnehmen Sie bitte der Anleitung.               *)
(*                                                                           *)
(*   Die compilierte Fassung von  MATHLIB  mit den  zugehîrigen  Dateien ist *)
(*  PUBLIC DOMAIN.   Die  Source-Code-Fassung   ist  nicht  frei  kopierbar. *)
(*  Sollten Sie MATHLIB  regelmÑûig verwenden,  so bitte ich Sie,  mir einen *)
(*  ausreichenden Betrag als Anerkennungshonorar zu senden.                  *)
(*                                                                           *)
(*  Auf die Verwendung von ST PASCAL PLUS und MATHLIB ist hinzuweisen.       *)
(*                                                                           *)
(*  Programmiersprache : Pascal (ST PASCAL PLUS von CCD, Eltville,           *)
(*                               Version 1.20)                               *)
(*  Autor              : Dietmar Rabich, Eschenweg 3, 4408 DÅlmen            *)
(*  Datum              : 01.03.1987                                          *)
(*  Version            : 2.1                                                 *)
(*                                                                           *)
(*  ------------------------------------------------------------------------ *)
(*  !!!  Informieren Sie mich  bitte unbedingt bei auftretenden Fehlern  !!! *)
(*  ------------------------------------------------------------------------ *)
(*                                                                           *)
(*  Zum Anerkennungshonorar:                                                 *)
(*                                                                           *)
(*    MATHLIB auf Diskette, mit Anleitung im                                 *)
(*     DIN A 5 - Format, ohne Source-Code    :     mindestens 30.- DM        *)
(*    MATHLIB auf Diskette, mit Anleitung im                                 *)
(*     DIN A 5 - Format, mit Source-Code                                     *)
(*     auf Papier (DIN A 5)                  :     mindestens 50.- DM        *)
(*    MATHLIB auf Diskette, mit Anleitung im                                 *)
(*     DIN A 5 - Format, mit Source-Code                                     *)
(*     auf Diskette und auf Papier (DIN A 5) :     mindestens 80.- DM        *)
(*                                                                           *)
(*    Auf Wunsch erhalten Sie Information Åber neuere Versionen.             *)
(*                                                                           *)
(*****************************************************************************)
(*****************************************************************************)

    vektor      =array [1..100] of real;
    matrix      =array [1..50,1..50] of real;
    glvektor    =array [1..50] of real;
    long_vektor =array [1..300] of real;
    dreiervektor=array [1..3] of real;
    str255      =string[255];
    dimension   =1..50;
    short_dim   =1..100;
    long_dim    =1..300;
    fktnnummer  =1..5;
    dglnummer   =1..3;
    liste_int   =array [1..300] of integer;
    liste_lint  =array [1..300] of long_integer;
    liste_real  =array [1..300] of real;
    wertetabelle=record
                   x : liste_real;
                   y : liste_real
                  end;
    complex     =record
                   re : real;
                   im : real;
                  end;
    rational    =record
                   ne : long_integer;
                   za : long_integer;
                  end;

