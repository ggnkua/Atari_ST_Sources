Program Mammamia;
Var i:Integer;
Procedure Sterne;
Var i:Integer;
Begin
        for i:=1 to 80 do write('*');
        Writeln;
End; (*Mammamia*)

Function Up(W:Integer):Integer;
Begin
        UP:=W+1;
End; (*Up*)

Begin   (*Hauptprogramm*)
        Sterne;
        Write('Wert:');
        Readln(i);
        Writeln(Up(i));
        Sterne;
End.

