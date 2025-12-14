(* Programm zum testen der FPU-MC68881 im Mega STE (mit LFED dem
	LineF-Emulation-Driver) unter Pure Pascal
*)

Program FPU_Test;
{$IFOPT N+}
	Type Real = Extended;
{$ENDIF}

Var	sinus, cosinus, arcustang, lauf_var : Real;
	zaehler : LongInt;

Begin
	sinus := 0; cosinus := 0; arcustang := 0;
	lauf_var := 0; zaehler := 0;
		
	While lauf_var <= 2 * Pi Do Begin
		lauf_var := lauf_var + 0.0001;
		zaehler := Succ(zaehler);
		cosinus := cos(lauf_var);
		sinus   := sin(lauf_var);
		arcustang := arctan(lauf_var);
	End;			
	WriteLn('Fr ', zaehler, ' Durchl„ufe');
	WriteLn('Inhalte der Variblen:');
	WriteLn('Cosinus     : ', cosinus);
	WriteLn('Sinus       : ', sinus); 
	WriteLn('Arcusangens : ', arcustang);
	ReadLn;
	Halt;	(* ohne diesen "Kunstgriff" gibt es einen Address Error (!?)
			   Tests haben ergeben, daž das dieses die Einzige M”glich-
			   keit ist, unter Nutzung von LFED und N+ "sauber" zu Ter-
			   minieren :-( *)
End.