Program ulamtest;
Var Test, Eingabe, Zaehler :LongInt;

Function ulam(n:LongInt): LongInt;
Begin 
zaehler:=Zaehler+1;
if not odd(n)
        Then ulam:=ulam(n Div 2)
        else
        If n<>1 Then ulam:=ulam(3*n+1)
        else ulam:=1
end;

Begin
        ClrScr;
        Write('Auf welche Zahl soll das Ulamverfahren angewendet werden: ');
        Readln(Eingabe);
        zaehler:=0;
        Test:=ulam(Eingabe);
        Writeln('Anzahl der Durchl„ufe: ',zaehler,' Resultat: ',Test);
end.