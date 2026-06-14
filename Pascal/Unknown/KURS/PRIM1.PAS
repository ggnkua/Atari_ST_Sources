Program Primzahltest;
Var Eingabe:Long_Integer;       (*Nur ganze Zahlen k”nnen Primzahlen sein*)
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
        Loop
                Write('Zu untersuchende Zahl eingeben: ');
                Readln(Eingabe);
        Exit if Eingabe<=0;             (*Nur positive Zahlen auswerten*)
                If Prim(Eingabe)then
                        Writeln(Eingabe:8,' ist eine Primzahl.')
                else
                        Writeln(Eingabe:8,' ist keine Primzahl.');
                Writeln;
        End;(*Loop*)
End.

