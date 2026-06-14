Program Test;

Var Multi,Divi:Real;

Procedure Rechne(Zahl1,Zahl2:Integer; Var Multiplikation,Division:Real);
(* FÅr Zahl2=0 stÅrzt dieses Unterprogramm natÅrlich ab. Verbessert es! *)
Begin
        Multiplikation:=Zahl1*Zahl2;
        Division:=Zahl1/Zahl2;
End;(*Rechne*)

Begin   (*Hauptprogramm*)
        Multi:=5;
        Divi:=5;
        Rechne(10,10,Multi,Divi);       (*Ergebnis: Multi=100; Divi=1*)
        Writeln(Multi:13:4,Divi:13:4);  (*Formatierte Zahlenausgabe*)
End.

