
  Procedure Edit_Arc_Path( Typ : Integer );
  Var
    S : String;
    X : Integer;
    Ch : Char;
  Begin
    Clr_Screen;
    S := Concat( 'Old ', ArcTyp[ Typ ], ' PathName :> ', System2.A_Path[ Typ ] );
    X := (80-Length(S)) Div 2;  GotoXY( X, 4); EchoS( S );
    S := Concat( '[1] Enter New ', ArcTyp[ Typ ], ' PathName' );
    GotoXY( X, 6 );  EchoS( S  );
    GotoXY( X, 8 );  EchoS( '[2] Use File Selector' );
    GotoXY( X,10 );  EchoS( '[Return] = No Change' );
    Repeat
        Ch := Get_Char;
    Until ( Ch='1' ) or ( Ch='2' ) or ( Ord(Ch)=13 );
    S := '';
    If ( Ch='1' ) Then Begin
      S := Concat( 'New ', ArcTyp[ Typ ], ' PathName :> ' );
      GotoXY( X, 12 );  EchoS( S );
      Caps := True;  Line_In( S, 60, 1 );
    End
    Else If ( Ch='2' ) Then Get_File_Sel( 1, S );
    If (Length(S)>1) Then System2.A_Path[ Typ ] := S;
  End;

  Procedure Edit_A( Typ : Integer );
  Var
    S : String;
    X : Integer;
    Ch : Char;
  Begin
    Clr_Screen;
    S := Concat( 'Old ', ArcTyp[ Typ ], ' Add Command :> ', System2.A_Cmd[ Typ ] );
    X := (80-Length(S)) Div 2;  GotoXY( X, 4); EchoS( S );
    S := Concat( 'New ', ArcTyp[ Typ ], ' Add Command :> ' );
    GotoXY( X, 6 );  EchoS( S );
    Caps := True;  Line_In( S, 8, 0 );
    If (Length(S)>0) Then System2.A_Cmd[ Typ ] := S;
  End;

  Procedure Edit_V( Typ : Integer );
  Var
    S : String;
    X : Integer;
  Begin
    Clr_Screen;
    S := Concat( 'Old ', ArcTyp[ Typ ], ' View Command :> ', System2.V_Cmd[ Typ ] );
    X := (80-Length(S)) Div 2;  GotoXY( X, 4); EchoS( S );
    S := Concat( 'New ', ArcTyp[ Typ ], ' View Command :> ' );
    GotoXY( X, 6);  EchoS( S );
    Caps := True;  Line_In( S, 8, 0 );
    If (Length(S)>0) Then System2.V_Cmd[ Typ ] := S;
  End;

  Procedure Edit_X( Typ : Integer );
  Var
    S : String;
    X : Integer;
  Begin
    Clr_Screen;
    S := Concat( 'Old ', ArcTyp[ Typ ], ' Extract Command :> ', System2.X_Cmd[ Typ ] );
    X := (80-Length(S)) Div 2;  GotoXY( X, 4); EchoS( S );
    S := Concat( 'New ', ArcTyp[ Typ ], ' Extract Command :> ' );
    GotoXY( X, 6);  EchoS( S );
    Caps := True;  Line_In( S, 8, 0 );
    If (Length(S)>0) Then System2.X_Cmd[ Typ ] := S;
  End;

  Procedure Do_ARC( Typ : Integer );
  Var
    Ch : Char;
    C  : Integer;
  Begin
    Repeat
      Clr_Screen;
      TLine := Concat( '[A] Edit ', ArcTyp[ Typ ], ' PathName' );
      GotoXY( 26,  4 ); EchoS( TLine );
      GotoXY( 26,  6 ); EchoS( '[B] Edit Command To eXtarct' );
      GotoXY( 26,  8 ); EchoS( '[C] Edit Command To Add' );
      GotoXY( 26, 10 ); EchoS( '[D] Edit Command To View' );
      GotoXY( 25, 13 ); EchoS( 'Choice or [Return] To Exit -> ' );
      Repeat
        Ch := Get_Char;  Ch := Upper_C( Ch ); C := Ord( Ch );
      Until ( Ch In[ 'A'..'D' ] ) or ( C=13 );
      If ( Ch = 'A' ) Then Edit_Arc_Path( Typ )
      Else If ( Ch = 'B' ) Then Edit_X( Typ )
      Else If ( Ch = 'C' ) Then Edit_A( Typ )
      Else If ( Ch = 'D' ) Then Edit_V( Typ );
    Until ( C = 13 );
  End;

  Procedure Archive_Menu;
  Begin
    Clr_Screen;
    GotoXY( 30, 4 ); EchoS( '[A]  Edit ARC Options' );
    GotoXY( 30, 6 ); EchoS( '[B]  Edit ARJ Options' );
    GotoXY( 30, 8 ); EchoS( '[C]  Edit LZH Options' );
    GotoXY( 30,10 ); EchoS( '[D]  Edit ZIP Options' );
    GotoXY( 30,12 ); EchoS( '[E]  Edit ZOO Options' );
    GotoXY( 25,15 ); EchoS( 'Choice or [Return] To Exit -> ' );
  End;

  Procedure Arc_Utils;
  Var
    Ch : Char;
    C  : Integer;
  Begin
    Repeat
      Archive_Menu;
      Ch := Get_Char;  Ch := Upper_C( Ch );  C := Ord( Ch );
      Case Ch Of
        'A' : Do_Arc( 0 );
        'B' : Do_Arc( 1 );
        'C' : Do_Arc( 2 );
        'D' : Do_Arc( 3 );
        'E' : Do_Arc( 4 );
      End; {Case}
    Until ( C=13 );
  End;
