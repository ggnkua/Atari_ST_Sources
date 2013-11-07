{  Computer dependent routines for RAVE
	(C) Martin Liesen 1991-92

	For more information see the main RAVE source code.

	All part of this source code is strictly forbidden to copy without
	the written premission of Martin Liesen
}

{  Computer specific constants }

Const
	Brain_mode: Array[0..1] of String[8]= ('Wingmute','Carbon  ');

{  Global variabels within Computer dependet file }

Var	orgi_mode:	Integer;		{ Screen mode when started program }
		hint_nr:		Shortint;

{	Here goes local function / procedures  }

Procedure No_Cursor;
Var	reg:	Registers;
Begin
	reg.AX:=$0100;		{	No Cursor }
	reg.Ch:=32;
	reg.Cl:=32;
	Intr(16,reg);
End;



{   Here goes all the proc / functions which might be called from RAVE }

Procedure Start_IO;
Begin
	Orgi_mode:=LastMode;
	TextMode(CO40);
	No_Cursor;
End;

Procedure End_IO;
Begin
	TextMode(Orgi_mode);
End;


{  Here goes Global routines }

Procedure Setup;
Var	line:		Shortint;
		key:		Char;
		esc:		Boolean;
Begin
	hint_nr:=0;
	line:=2;

	Window(1,1,40,25);
	TextAttr:=$1F;
	ClrScr;
	WriteLn('RAVE - development V1.0');
	WriteLn('(C) Martin Liesen 1991-92');
	WriteLn('ออออออออออออออออออออออออออออออออออออออออ');
	Window(1,4,40,25);
	TextAttr:=$3F;
	ClrScr;
	Window(8,7,31,14);
	TextAttr:=$1F;
	ClrScr;
	Repeat
		GotoXY(2,2);
		If line=0 Then TextAttr:=$3F Else textAttr:=$17;
		WriteLn('Player 1 is : ',brain_mode[pl[1]^.brain]);
		GotoXY(2,3);
		If line=1 Then TextAttr:=$3F Else textAttr:=$17;
		WriteLn('Player 2 is : ',brain_mode[pl[2]^.brain]);
		GotoXY(2,5);
		If line=2 Then TextAttr:=$3F Else textAttr:=$17;
		WriteLn('Start game            ');
		GotoXY(2,7);
		If line=3 Then TextAttr:=$3F Else textAttr:=$17;
		WriteLn('Quit Rave             ');
		Repeat
		Until Keypressed;
		key:=Readkey;
		If key=Chr(0) Then Begin
			key:=Readkey;
			esc:=True;
		End Else esc:=False;
		If (esc=True) and (key='P') Then
			Inc(line,1);
		If (esc=True) and (key='H') Then
			Dec(line,1);
		If line>3 Then Dec(line,4);
		If (esc=False) and (key=chr(13)) and (line<2) Then Begin
			Inc(pl[line+1]^.brain,1);
			If pl[line+1]^.brain>1 Then Dec(pl[line+1]^.brain,2);
		End;

		If line<0 Then Inc(line,4);
	Until (line>1) and (key=chr(13));
	If line=3 Then
		Prog_end:=True;
End;

Procedure Can_not_move(player:Shortint);
Var	win1,win2	:Integer;
		attr			:Integer;
Begin
	win1:=Windmin;
	win2:=Windmax;
	attr:=Textattr;
	Window(1,25,40,25);
	TextAttr:=$4F;
	ClrScr;
	Write('Player ',player,' can''t play round  <Space>');
	Repeat
	Until ReadKey=' ';
	ClrScr;
	Windmin:=win1;
	Windmax:=win2;
	Textattr:=attr;
End;


Procedure Game_ended(map_addr:Pointer);
Const	yesno: Array[0..1] of Integer = ($4F,$40);
Var	map:	^map_t;
		key:	Char;
		esc:	Boolean;
		pos:	Shortint;	{ 0=Yes 1=No }
Begin
	pos:=0;
	Window(1,25,40,25);
	TextAttr:=$4F;
	ClrScr;
	Repeat
		GotoXY(1,1);
		Textattr:=$4C;
		Write('Game ended, quit ? ');
		TextAttr:=yesno[pos];
		Write('Yes ');
		TextAttr:=yesno[(not pos) and 1];
		Write('No  ');
		Repeat
		Until Keypressed;
		key:=Readkey;
		If key=chr(0) Then Begin
			esc:=True;
			key:=Readkey;
		End Else esc:=False;
		pos:=(not pos) and 1;
	Until key=chr(13);
	pos:=(not pos) and 1;
	If pos=0 Then Prog_end:=True;
End;

Procedure Init_screen;
Var
	x		:Shortint;
Begin
	Window(1,4,40,25);
	TextAttr:=$3F;
	ClrScr;

	Window(2,5,11,15);
	TextAttr:=$19;
	Write(' abcdefgh ');
	For x:=1 to 8 Do
		Write(Chr(48+8-x),'        ',Chr(48+8-x));
	Write(' abcdefgh ');
	Window(2,5,11,14);

End;

Procedure Draw_map(map_addr:Pointer);
Var	map	:^map_t;
		x,y	:ShortInt;
Begin
	map:=map_addr;
	For x:=0 to 7 Do
		For y:=0 to 7 Do Begin
			If Odd(x+y) Then
				Textattr:=$60
			Else
				Textattr:=$40;
			GotoXY(x+2,y+2);
			If map^[x,y]=Empty Then
				Write(' ')
			Else If map^[x,y]=White Then Begin
					Inc(Textattr,$f);
					Write('þ');
				End Else Begin
					Write('þ');
				End;

		End;
End;


Function Human_input(var pos:pos_t; map_addr:Pointer;player:Shortint):Shortint;
Var	key:	Char;
		esc:	Boolean;
		map:	^map_t;
		pos2,
		pos3:	pos_t;
		count:Shortint;
Begin
	map:=map_addr;
	Human_input:=0;
	GotoXY(pos.x+2,pos.y+2);
	If Pos_possible(player,pos,map_addr) Then Textattr:=$22
	Else Textattr:=$33;
	If map^[pos.x,pos.y]=White Then Textattr:=Textattr or  $0F;
	If map^[pos.x,pos.y]=Black Then Textattr:=Textattr and $F0;
	Write('þ');


	If Keypressed=True Then Begin
		key:=Readkey;
		If key=Char(0) Then Begin
			key:=Readkey;
			esc:=True;
		End Else esc:=False;
		If esc=true Then Begin
			Case key of
				'M':	Inc(pos.x,1);
				'K':	Dec(pos.x,1);
				'P':	Inc(pos.y,1);
				'H':	Dec(pos.y,1);
				Else Begin
					GotoXY(1,1);
					Write(key);
				End;
			End;
			If pos.x<0 Then Inc(pos.x,8);
			If pos.y<0 Then Inc(pos.y,8);
			If pos.x>7 Then Dec(pos.x,8);
			If pos.y>7 Then Dec(pos.y,8);
			Draw_map(map_addr);
		End Else Begin
			If (key='H') or (key='h') Then Begin
				Inc(hint_nr,1);
				count:=0;
				For pos2.y:=0 To 7 Do
					For pos2.x:=0 To 7 Do
						If Pos_possible(player,pos2,map_addr) Then Begin
							If (count=0) or (count=hint_nr) Then
								pos3:=pos2;
							Inc(count,1);
						End;
				If hint_nr>=count Then hint_nr:=0;
				Draw_map(map_addr);
				pos:=pos3;
			End;
			If key=chr(27) Then
				Human_input:=5;
			If key=chr(13) Then
				If Pos_possible(player,pos,map_addr) Then
					Human_input:=1;
		End;
	End;
End;