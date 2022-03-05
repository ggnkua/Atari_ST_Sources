{$S8}
Program UPDT_USR;
{$I D:\Pascal\Per_Pasc\AuxSubs.Pas}

Type

	UserAccess_Old = Packed Record
		User_Mask : Packed Array[1..32] of Long_Integer;
		Sig_Accs  : Packed Array[1..32] of Long_Integer;
		Sig_Valid : Packed Array[1..32] of Long_Integer;
		Sig_Edit  : Packed Array[1..32] of Long_Integer;
		Sig_Kill  : Packed Array[1..32] of Long_Integer;
	End;

	UserAccess_New = Packed Record
 		TSig_Accs : Long_Integer;
		User_Mask : Packed Array[1..32] of Long_Integer;
		Sig_Accs  : Packed Array[1..32] of Long_Integer;
		Sig_Valid : Packed Array[1..32] of Long_Integer;
		Sig_Edit  : Packed Array[1..32] of Long_Integer;
		Sig_Kill  : Packed Array[1..32] of Long_Integer;
	End;

Var

	UserNew : UserAccess_New;
	UserOld : UserAccess_Old;

	Function FWrite_UsrN(H:Integer; Count:Long_Integer; Var S:UserAccess_New):Long_Integer;
	Gemdos( $40 );

	Function FRead_UsrO(H:Integer; Count:Long_Integer; Var S:UserAccess_Old):Long_Integer;
	Gemdos( $3F );

	Function Fseek( Where : Long_Integer ; FHandle, Mode: Integer ):Long_Integer;
		Gemdos($42); { Mode: 0=From Start, 1=from current pos, 2=from End }	

	Procedure Make_New;
	Var
		UsrdataN : text;
		UsrdataO : text;
		I : Integer;
		X, Count : Long_Integer;
	Begin
		Reset( UsrdataO, 'ftu_data.usr' );
		Count := Fseek( 0, Handle(UsrdataO), 2);
		X := (Count Div SizeOf(UserOld));
		Close( UsrDataO );

		Rewrite( UsrdataN, 'ftu_data.us_' );
		Count := Fseek( 0, Handle(UsrdataN), 0);
		Reset( UsrdataO, 'ftu_data.usr' );
		Count := Fseek( 0, Handle(UsrdataO), 0);
		For I := 1 to X Do Begin
			Count := FRead_UsrO( handle(UsrdataO), Sizeof(UserOld), UserOld );
			UserNew.User_Mask :=	UserOld.User_Mask;
			UserNew.Sig_Accs  :=	UserOld.Sig_Accs;
			UserNew.Sig_Valid :=	UserOld.Sig_Valid;
			UserNew.Sig_Edit  :=	UserOld.Sig_Edit;
			UserNew.Sig_Kill  :=	UserOld.Sig_Kill;
			Count := FWrite_UsrN( Handle(UsrdataN), SizeOf(UserNew), UserNew );
		End;
		Close( UsrDataO );
		Close( UsrDataN );

		Rewrite( UsrdataN, 'ftu_data.ms_' );
		Count := Fseek( 0, Handle(UsrdataN), 0);
		Reset( UsrdataO, 'ftu_data.msk' );
		Count := Fseek( 0, Handle(UsrdataO), 0);
		For I := 1 to 10 Do Begin
			Count := FRead_UsrO( handle(UsrdataO), Sizeof(UserOld), UserOld );
			UserNew.User_Mask :=	UserOld.User_Mask;
			UserNew.Sig_Accs  :=	UserOld.Sig_Accs;
			UserNew.Sig_Valid :=	UserOld.Sig_Valid;
			UserNew.Sig_Edit  :=	UserOld.Sig_Edit;
			UserNew.Sig_Kill  :=	UserOld.Sig_Kill;
			Count := FWrite_UsrN( Handle(UsrdataN), SizeOf(UserNew), UserNew );
		End;
		Close( UsrDataO );
		Close( UsrDataN );
	End;

Begin									   (* Main Program Begins Here... *)
	Make_New;
End.

