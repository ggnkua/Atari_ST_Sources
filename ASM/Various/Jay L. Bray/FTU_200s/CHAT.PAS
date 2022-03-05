{$M+,$E+}
Program Chat;

{$I Auxsubs.Pas}
{$I Gemsubs.Pas}

Const
{$I BBS_Con.Pas}

Type
{$I BBS_Type.Pas}

Var
{$I BBS_Var.Pas}

	Procedure Write_Six( X,Y,C1,C2:Integer; S:String ); External;
	Procedure CrLf; External;
	Procedure Back_Space; External;
	Procedure Put_Console( Ch:Char ); External;
	Procedure Put_Modem( Ch:Char ); External;
	Procedure Put_Char( Ch:Char ); External;
	Procedure EchoS ( S:String ); External;
	Procedure EchoSE( S:String ); External;
	Function Carrier: Boolean; External;
	Function Bconin( Device: Integer ):Long_Integer; External;
	Function Inready( Device: Integer ):Boolean; External;

	Procedure Chat_Wrap( Var S: String; X: Integer; Var KyCnt: Integer; Md: Integer );
	Begin
		S := Concat( S, Chr(X) );
		KyCnt := KyCnt + 1;
		If X=32 Then S := '';
		If (KyCnt>=WidT-2) And (Length(S)=WidT-2) Then Begin
			CrLf;
			S:='';
			KyCnt:=0;
		End
		Else If (KyCnt>=WidT-2) And (Length(S)>0) Then Begin
			KyCnt := Length( S );
			For X := 1 to KyCnt Do Back_Space;
			CrLf;
			For X := 1 to KyCnt Do Put_Char( S[X] );
		End
		Else Begin
			If Md=1 Then Begin
				Put_Console( Chr(X) );
				Put_Modem( Chr(X) );
			End
			Else Put_Console( Chr(X) );
		End;
	End;

	Procedure Chat_Mode;
	Var
		X, I : Long_Integer;
		Temp : String[40];
		S : String;
		KyCnt : Integer;
	Begin
		Chat := True;
		Write_Six( 39,2,Blk,Wht,'         ' );
		CrLf;
		Temp := 'SysOp Entering Chat Mode...';
(*		For I := 1 to Length(Temp) Do
		 Put_Char( Temp[I] ); *)
		EchoSE( Temp );
		CrLf;
		CrLf;
		Fnct_Key := 0;
		S := '';
		KyCnt := 0;
		Repeat
		 	If Inready(Modem) And (Not Local) Then Begin
				X := Bconin( Modem );
				Put_Modem( Chr(X) );
				If X=Cr Then Begin; CrLf; S := ''; KyCnt := 0; End
				Else If (X<>Cr) And (X<>Lf) And (X<>Esc) Then Chat_Wrap( S, X, KyCnt, 0 );
			End
			Else If Inready(Console) Then Begin
 				I := Bconin( Console );
				Fnct_Key := Shr( I,16 );
				X := ( I & 65535 );
				If X=Cr Then Begin; CrLf; S := ''; KyCnt := 0; End
				Else If (X<>Cr) And (X<>Lf) And (X<>Esc) Then Chat_Wrap( S, X, KyCnt, 1 );
			End;
		Until (Fnct_Key=F5) or (Carrier=False);
		Fnct_Key := 0;
		CrLf;
		Temp := 'You Now Have Control...';
(*		For I := 1 to Length(Temp) Do
		 Put_Char( Temp[I] ); *)
		EchoSE( Temp );
		CrLf;
	End;

Begin
{ Dummy }
End.
