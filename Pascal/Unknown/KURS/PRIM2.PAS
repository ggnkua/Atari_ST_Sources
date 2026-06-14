Program Primsuche;
Const Obergrenze=1000;  (*Zahl der zu suchenden Primzahlen*)
Var
        Feld:Array(.1..Obergrenze.)of Long_Integer;
        Zaehler:0..Obergrenze;
        Wert:Long_Integer;
Function Prim(Zahl:Long_Integer):Boolean;
Var Zaehler:Long_Integer;
        Ergo:Boolean;
Begin
        Ergo:=True;
        Zaehler:=2;
        While (Ergo)and(Zaehler<=Zahl Div 2)do Begin
        (*Alle m”glichen Teiler untersuchen*)
                Ergo:=(Zahl Mod Zaehler)<>0;    (*Geht Teilen ohne Rest?*)
                Zaehler:=Succ(Zaehler);
        End;
        Prim:=Ergo;
End;(*Prim*)

Begin
        Writeln('Ich rechne');
        Zaehler:=0;             (*Z„hlt die gefundenen Primzahlen*)
        Wert:=2;                        (*erster zu untersuchender Wert*)
        While Zaehler<Obergrenze do Begin
                Writeln(Zaehler:5);
                If Prim(Wert) then Begin
                        Zaehler:=Zaehler +1;
                        Feld(.Zaehler.):=Wert;        (*Primzahl merken*)
                End;
                Wert:=Succ(Wert);               (*n„chste Zahl prfen*);
        End;(*1000 Primzahlen suchen*);
        Writeln('Die Liste der ersten ',Obergrenze,' Primzahlen:');
        For Zaehler:=1 to Obergrenze do writeln(Feld(.Zaehler.):8);
End.

