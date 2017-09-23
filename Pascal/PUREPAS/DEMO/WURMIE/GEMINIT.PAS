{ ------------------------------------------------------------ }
{ UNIT  GEMINIT                                                }
{ (c) 1992 Pure Software GmbH                                  }
{                                                              }
{ the unit GemInit performs all init and exit stuff needed to  }
{ execute a gem program.                                       }
{ ------------------------------------------------------------ }

unit	GemInit;

interface

{$X+}
uses	gem;

var
	vdiHandle, aesHandle : Integer;
	apID : Integer;
	workIn : workin_ARRAY;
	workOut : workout_ARRAY;
	charWidth, charHeight : Integer;
	boxWidth, boxHeight : Integer;


	function	InitGem : Boolean;
	procedure	ExitGem;


implementation

{ ------------------------------------------------------------ }
{ this procedure ends up a gem program.                        }
{ ------------------------------------------------------------ }

procedure	ExitGem;
begin
	v_clsvwk( vdiHandle );
	appl_exit;
end;


{ ------------------------------------------------------------ }
{ this function initalizes the gem. it returns true if it was  }
{ successful.                                                  }
{ ------------------------------------------------------------ }

function	InitGem : Boolean;
var
	i : Integer;
begin
	apID := appl_init;
	if apID >= 0 then
	begin
		aesHandle := graf_handle( charWidth, charHeight, boxWidth, boxHeight );
		workIn[0] := aesHandle;
		for i := 1 to workin_max - 1 do
			workIn[i] := 1;
		workIn[10] := 2;

		v_opnvwk( workIn, vdiHandle, workOut );
		if vdiHandle <= 0 then
		begin
			appl_exit;
			InitGem := False;
		end
		else
			InitGem := True;
	end
	else
		InitGem := False;
end;

end.

{ ============================================================ }
