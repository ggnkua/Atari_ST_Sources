
	Procedure Enter_Line( Var S:String; Var Word:String; Var Ch:Char;
		Var KyCnt:Integer; Var Wrap:Boolean; Temp:String );
	Label
		200;
	Var
		WrdCnt,I,CC : Integer;
	Begin
		Wrap := False;
		KyCnt := 0;
		WrdCnt := 0;
		S := '';
		Word := '';
		If ( Temp <> S ) Then Begin
			S:=Temp; KyCnt:=Length( S ); WrdCnt:=KyCnt;
		End;
		EchoS( '\r' );
		EchoS( Prompt );
		EchoS( '\b' );
		EchoS( S );
		Repeat
		200:
			Ch := Get_Char;  Cc := Ord( Ch );
			If ( Cc=Bksp ) And ( KyCnt>0 ) Then Begin
				Back_Space;
				KyCnt := KyCnt -1;
				If WrdCnt>1 Then WrdCnt := WrdCnt -1;
				S[0] := Chr( KyCnt );
				Word[0] := Chr( WrdCnt );
			End
			Else If CC>31 Then Begin
				EchoS( Ch );
				S := Concat( S, Ch );
				Word := Concat( Word, Ch );
				KyCnt := KyCnt + 1;
				WrdCnt:= WrdCnt + 1;
				If Ch=' ' Then Begin WrdCnt := 0; Word:= ''; End;
				If ( KyCnt=WidT-2 ) And ( WrdCnt<>KyCnt ) And ( WW_Toggle ) Then Begin
					For I := 1 To Length( Word ) Do Back_Space;
					S[0] := Chr( KyCnt-WrdCnt );
					Wrap := True;
				End
				Else If ( KyCnt=WidT-2 ) And ( WrdCnt=KyCnt ) And ( WW_Toggle ) Then CC := Cr
				Else If ( KyCnt=WidT-1 ) And ( WW_Toggle=False ) Then Begin
					Back_Space;
					KyCnt:=KyCnt-1;
					Goto 200;
				End;
			End
		Until ( ( Ch='/' ) And ( KyCnt=1 ) ) or ( CC=Cr ) or ( Wrap ) or ( Carrier=False );
		If Ch='/' Then Begin
			Back_Space;  Back_Space;
			EchoS( '\r(E>\b ' );
			Ch := Get_Char;  Upper_C( Ch );
		End;
	End;

	Procedure Save_Description;
	Var
		H, X : Integer;
	Begin
		H := FCreate( Desc_Path, 0 );
		If H<0 Then Show_Error( Desc_Path, H );
		For X := 1 to Msg_Ln Do Write_Ln( H, MesgL[X] );
		X := Close_File( H );
		CrLf;
	End;

	Procedure Frmt_List;
	Var I:Integer;
	Begin
		Clear_Screen;
		For I:=1 to Msg_Ln Do EchoSE( MesgL[I] );
	End;

	Procedure Delete_Desc_Line;
	Var
		I,X,Strt,Lst:Integer;
	Begin
		EchoS( 'Delete ( 1-' );
		Writev( Line,Msg_Ln );
		EchoS( Line );
		EchoS( ' ) From [1]: ' );
		I := Get_Number( Msg_Ln );
		If I <> 0 Then Begin
			If I = -1 Then Begin Strt := 1; EchoS( '1' ); End
			Else Strt := I;
			EchoS( ' To [' );
			Writev( Line,Strt );
			EchoS( Line );
			EchoS( ']: ' );
			I := Get_Number( Msg_Ln );
			If I = -1 Then Begin Lst := Strt; Writev( Line, Lst ); EchoS( Line ); End
			Else Lst := I;
			X:=Lst-( Strt-1 );  { Total # of Lines...}
			For I:=Strt to Msg_Ln Do MesgL[I] := MesgL[I+X];
			Msg_Ln := Msg_Ln - X;
		End;
		CrLf;
	End;

	Procedure List_Desc_Line( Md:Integer );
	Var
		I,Strt,Lst:Integer;
		Temp : String;
	Begin
		Strt := 1;
		Lst := Msg_Ln;
		EchoS( 'List ( 1-' );
		Writev( Line,Msg_Ln );
		EchoS( Line );
		EchoS( ' ) From [1]: ' );
		I := Get_Number( Msg_Ln );
		If I <> 0 Then Begin
			If I = -1 Then Begin Strt := 1; EchoS( '1' ); End
			Else Strt := I;
			EchoS( ' To [' );
			Writev( Line,Msg_Ln );
			EchoS( Line );
			EchoS( ']: ' );
			I := Get_Number( Msg_Ln );
			If I = -1 Then Begin Lst := Msg_Ln; Writev( Line, Lst ); EchoS( Line ); End
			Else Lst := I;
			CrLf;
			For I:=Strt to Lst Do Begin
				If Md=2 Then Writev( Temp,I:2, ': ', MesgL[I] )
					Else Temp := MesgL[I];
				If Ord( Temp[0] ) >= 79 Then Temp[0] := Chr( 79 );
				EchoSE( Temp );
			End;
		End;
	End;

	Procedure Insert_Line;
	Var
		I, X, Strt, Lst : Integer;
		Temp : String;
	Begin
		EchoS( 'Insert Before ( 1-' );
		Writev( Line,Msg_Ln );
		EchoS( Line );
		EchoS( ' ) Line [' );
		Writev( Line,Msg_Ln );
		EchoS( Line );
		EchoS( ']: ' );
		X := Get_Number( Msg_Ln );
		If ( X>0 ) And ( X<=Msg_Ln ) Then Begin
			Strt := X +1;
			Lst := Msg_Ln +1;
			For I := Lst Downto Strt Do MesgL[I] := MesgL[I-1];
			CrLf;
			CrLf;
			EchoS( ']' );
			Caps := False;
			Line_In( Temp, 78 );
			MesgL[X] := Temp;
			Msg_Ln := Msg_Ln +1;
			CrLf;
		End
		Else EchoSE( ' Aborted...' );
	End;

	Procedure Edit_Line;
	Var
		I : Integer;
		Temp,OldL : String;
	Begin
		EchoS( 'Edit Which Line ( 1-' );
		Writev( Line,Msg_Ln );
		EchoS( Line );
		EchoS( ' ) ?' );
		I := Get_Number( Msg_Ln );
		If ( I<>0 ) And ( I<=Msg_Ln ) Then Begin
			If ( I<>-1 ) And ( I<>-2 ) Then Begin
				CrLf;
				OldL := MesgL[I];
				EchoSE( ' Old Line Reads:' );
				Writev( Line,'- ',OldL );
				EchoSE( Line );
				EchoS( '+ ' );
				Caps := False;
				Line_In( Temp, 78 );
				MesgL[I] := Temp;
			End
			Else EchoSE( 'Line Unchanged...' );
		End
		Else EchoSE( 'Line Unchanged...' );
		CrLf;
	End;

	Procedure Pack_Lines;
	Var
	N,X,I : Integer;
	Ok : Boolean;
	Temp : String;
	Begin
		X := Msg_Ln;
		Repeat
			Temp := MesgL[X];
			Ok:=True;
			For I := 1 To Length( Temp ) Do If Temp[I]<>' ' Then Ok:=False;
			If ( Temp='' ) or ( Ok ) Then Begin
				For I:=X to Msg_Ln Do MesgL[I] := MesgL[I+1];
				Msg_Ln := Msg_Ln -1;
			End;
			X := X -1;
		Until X=1;
		EchoSE( 'Packing...Done' );
		CrLf;
	End;

	Procedure Show_Column_Bar;
	Begin
		Back_Space;
		Back_Space;
		Back_Space;
		If WidT=40 Then EchoSE( '\r ----\b+\r----\g1\r----\b+\r----\g2\r----\b+\r----\g3\r----\b+\r---\b' )
		Else Begin
			EchoS ( '\r ' );
			EchoS ( '----\b+\r----\g1\r----\b+\r----\g2\r----\b+\r----\g3\r----\b+\r----\g4\r' );
			EchoSE( '----\b+\r----\g5\r----\b+\r----\g6\r----\b+\r----\g7\r----\b+\r---\b' );
		End;
	End;

	Procedure Show_Desc_Help;
	Var S : String;
	Begin
		New_Line := False;
		Clear_Screen;
		CrLf; EchoSE( ' Mesage Editor Commands:' ); CrLf;

		S := '[\rA\b] Abort This Message';             Show_40( S );
		S := '[\rB\b] Begin Over Again';               Show_40( S );
		S := '[\rC\b] Display Column Bar';             Show_40( S );
		S := '[\rD\b] Delete Line(s)';                 Show_40( S );
		S := '[\rE\b] Edit A Line';                    Show_40( S );
		S := '[\rF\b] Formatted List';                 Show_40( S );
		S := '[\rI\b] Insert A Line';                  Show_40( S );
		S := '[\rL\b] List Lines (No numbers)';        Show_40( S );
		S := '[\rN\b] Line Lines (With Numbers)';      Show_40( S );
		S := '[\rP\b] Pack (Remove All Blank Lines)';  Show_40( S );
		S := '[\rR\b] Repeat Last Line';               Show_40( S );
		S := '[\rS\b] Save Message';                   Show_40( S );
		S := '[\rU\b] Save Message (Unformatted)';     Show_40( S );
		S := '[\rV\b] Video Width Change';             Show_40( S );
		S := '[\rW\b] Word Wrap Toggle (On/Off)';      Show_40( S );
		S := '[\rY\b] Change Your Prompt Char';        Show_40( S );
		S := '[\r/\b] Clear The Screen';               Show_40( S );
		S := '[\r?\b] This Help Screen';               Show_40( S );
		CrLf;
		EchoSE( 'Precede These Comnds with a Forward Slash "\r/\b" ' );
		CrLf;
	End;

	Procedure Show_Line_Status;
	Begin
		CrLf;
		If ( Msg_Ln<=19 ) Then Begin
			Msg_Ln := Msg_Ln + 1;
			MesgL[Msg_Ln] := MLin;
		End
		Else EchoSE( 'Out Of Room...' );
		If ( Msg_Ln=19 ) Then EchoSE( 'One More Line Left...' );
	End;

	Procedure Edit_Description;
	Label
		100;
	Var
		KyCnt, Strt, Lst : Integer;
		Ch : Char;
		Wrap, Done : Boolean;
		S,Word,Null : String;
	Begin
		Clear_Screen;
		Lin_No := Msg_Ln;
		WW_Toggle:=True;
100:
		SaveM := False;
		MLin :='';
		Null := '';
		Wrap := False;
		CrLf;
		EchoS ( '\r\i Press \g/\r To Enter Edit Mode, ' );
		EchoSE( '\g/S\r - Save,  \g/A\r - Abort, \g/?\r - Help\o\b' );
		CrLf;
		Show_Column_Bar;
		Repeat
			If ( Wrap ) Then Begin
				Enter_Line( MLin, Word, Ch, KyCnt, Wrap, Word );
			End
			Else If ( Wrap = False ) Then
				Enter_Line( MLin, Word, Ch, KyCnt, Wrap, Null );
			If ( KyCnt=1 ) And ( Wrap=False ) Then Begin
				Case Ch of
					'A' : Abort := True;
					'B' : Begin
									EchoS( 'Begin Over...Are You Sure? ' );
									If ( Yes_No( 'N' ) ) Then Begin
										Msg_Ln:=Lin_No;
										Clear_Screen;
										EchoSE( 'Entire Message Has Been Erased...' );
										Goto 100;
									End;
								End;
					'C' : Show_Column_Bar;
					'D' : Delete_Desc_Line;
					'E' : Edit_Line;
					'F' : Frmt_List;
					'I' : Insert_Line;
					'L' : List_Desc_Line( 1 );
					'N' : List_Desc_Line( 2 );
					'P' : Pack_Lines;
					'R' : If Msg_Ln <20 Then Begin
									EchoSE( MesgL[Msg_Ln] );
									Msg_Ln := Msg_Ln + 1;
									MesgL[Msg_Ln] := MesgL[Msg_Ln - 1];
								End;
					'S' : Begin
									EchoS( 'Saving Description...' );
									Save_Description;
									EchoSE( 'Thanks' );
									SaveM := True;
								End;
					'U' : Begin Save_Description; SaveM := True; End;
					'V' : Begin
									If WidT = 80 Then WidT := 40  Else WidT := 80;
									Writev( S, 'Video Width Now ', WidT );
									EchoSE( S );
								End;
					'W' : Begin
									If WW_Toggle = True Then WW_Toggle:=False
										Else WW_Toggle:=True;
									EchoS( 'Word Wrap Is Now ' );
									If WW_Toggle = True Then S:='On'  Else S:='Off';
									EchoSE( S );
								End;
					'Y' : Begin
									EchoS( 'Enter New Prompt Char :> ' );
									Prompt := Get_Char;
								End;
					'/' : Clear_Screen;
					'?' : Show_Desc_Help;
					Else If Ord( Ch ) = Cr Then Show_Line_Status
					Else Begin Back_Space; Back_Space; Back_Space; End;
				End; { Case }
			End
			Else Show_Line_Status;
		Until ( Abort ) or ( SaveM ) or ( Carrier=False );
	End;
