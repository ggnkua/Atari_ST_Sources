{------------------------------------------------
Anwendung Parametrischer Prozeduren/Funktionen
zur Erzeugung von Prozeduradressen.

Modul mit externer Funktion Adr_Proc

(C) Rolf Darr, Oktober 1990

entwickelt mit und fÅr ST-Pascal+ V.2.08 (CCD)

------------------------------------------------}
{$I-,C-,D-,P-,R-,T-}    {kein Debugging/PrÅfungen}
{$M+}                   {Modul}
PROGRAM Modul_AdrProc;

{$E+}
FUNCTION Adr_Proc ( Parameter: Long_Integer ): Long_Integer;
  BEGIN{Adr_Proc}
    Adr_Proc:=  Parameter {silly one!!!}
  END{Adr_Proc};
{$E=}

BEGIN   {Module haben kein Hauptprogramm}
END.

