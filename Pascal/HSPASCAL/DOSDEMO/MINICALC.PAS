Program MiniCalc;
{$I-
  Calculator by Christen Fihl 1990,
  Example of use:   * P=22/7 ; 2+3 ; p*5 ; sin(pi*45/180)
                    * 22/7 ; P ; 2+3
}
Type Real=Double; {Choose your own precision (Single/Double/Extended}

Const NextIsError=#1; NextIsValue=#2; NextIsName=#3; NextIsEOF=#4;

Type  TStr   =     String[80];
      TSaved =     Array['A'..'Z'] of Real;

Var   xx: real;
      Saved:       TSaved;                           {26 Memory cells}
      InputLine:   TStr;
      Position,n:  Integer;                    {Position on InputLine}
      ErrPos:      Integer;
      LastPos:     Integer;
      CmdLine:     TStr;
      NextName:    TStr;       {Returned by Next when  Ch=NextIsName}
      NextVal,R:   Real;   {Value returned by Next when Ch=NextIsVal}
      Ch,LastCh:   Char;

procedure Next;                                      {Return Ch:=Last}
var p,e: integer;
procedure NextCh;
begin
  if Position<=Length(InputLine) then inc(Position);
  if Position>Length(InputLine) then Ch:=NextIsEOF
  else Ch:=UpCase(InputLine[Position]);
end;
procedure PrevCh;
begin
  dec(Position)
end;

begin {procedure Next}
  LastCh:=Ch; LastPos:=Position;
  repeat NextCh until Ch<>' ';
  ErrPos:=Position;
  case Ch of
  '0'..'9','.':                                               {Number}
    begin
      p:=Position;
      repeat NextCh until not (Ch in ['0'..'9','.']);
      if UpCase(Ch)='E' then begin                        {look for E}
        NextCh;
        if Ch in ['+','-'] then NextCh;
        while Ch in ['0'..'9'] do NextCh;
      end;
      Val(Copy(InputLine,p,Position-p),NextVal,e);
      if e<>0 then begin Position:=p+e-1; Ch:=NextIsError end;
      PrevCh; Ch:=NextIsValue;
    end;
  'A'..'Z':                                                     {Name}
    begin
      NextName:='';
      while (Ch in ['A'..'Z']) do begin NextName:=NextName+Ch; NextCh end;
      PrevCh; Ch:=NextIsName;
    end;
  end;
end;

function AddExpr: Real; FORWARD;

function Factor: Real;
function FindAndSkip(What: TStr): Boolean;
begin
  if NextName=What then begin
    Next;  FindAndSkip:=True;
  end else FindAndSkip:=False;
end;

begin
  case Ch of
  NextIsValue:
    begin
      Factor:=NextVal;
      Next;
    end;
  NextIsName:                                      {SIN(10) or SIN 10}
    begin
    {Add your own here}
      if FindAndSkip('PI')   then Factor:=PI             else 
      if FindAndSkip('SQR')  then Factor:=sqr(Factor)    else 
      if FindAndSkip('SQRT') then Factor:=sqrt(Factor)   else  
      if FindAndSkip('ABS')  then Factor:=abs(Factor)    else 
      if FindAndSkip('SIN')  then Factor:=sin(Factor)    else 
      if FindAndSkip('COS')  then Factor:=cos(Factor)    else 
      if FindAndSkip('ARCTAN') then Factor:=arctan(Factor) else  
      if FindAndSkip('LOG')  then Factor:=ln(Factor)/ln(10) else 
      if FindAndSkip('LN')   then Factor:=ln(Factor)     else 
      if FindAndSkip('EXP')  then Factor:=exp(Factor)    else   
      if FindAndSkip('MIN')  then begin          {User defined rutine}
        if Saved['X']<Saved['Y'] then Factor:=Saved['X']    {Min(x,y)}
        else                          Factor:=Saved['Y']
      end else
      if Length(NextName)=1 then begin
        Factor:=Saved[NextName[1]];
        Next;
      end else Ch:=NextIsError
    end;
  '(':                                                 {fx X=3+(4*5)}
    begin
      Next;
      Factor:=AddExpr;                               {recursiv call!}
      if Ch<>')' then Ch:=NextIsError
      else Next;
    end;
  else {Error}
    Ch:=NextIsError; Factor:=0;
  end;
end;

function SignedFactor: Real; {SignedFactor ::= (+|-| ) SignedFactor}
begin
  case Ch of
  '-': begin Next; SignedFactor:=-SignedFactor; end;
  '+': begin Next; SignedFactor:=+SignedFactor; end;
  else
    SignedFactor:=Factor;
  end;
end;

function Term: Real;         {Term ::= (^| ) SignedFactor}
var   R: Real;
begin
  R:=SignedFactor;
  while Ch='^' do begin
    Next; R:=exp(ln(R)*SignedFactor);
  end;
  Term:=R;
end;

function MulExpr: Real;      {MulExpr ::= Term (*|/| ) Term}
var   R: Real;
begin
  R:=Term;
  while Ch in ['*','/'] do begin
    Next;
    case LastCh of
    '*': R:=R*Term;
    '/': R:=R/Term;
    end;
  end;
  MulExpr:=R;
end;

function AddExpr: Real;       {AddExpr ::= MulExpr (+|-| ) MulExpr}
var   R: Real;
begin
  R:=MulExpr;
  while Ch in ['+','-'] do begin
    Next;
    case LastCh of
    '+': R:=R+MulExpr;
    '-': R:=R-MulExpr;
    end;
  end;
  AddExpr:=R;
end;

function AssignStmt: Boolean;  {AssignStmt ::= ID=AddExpr}
var ID: Char; Pos2: Integer;
begin
  AssignStmt:=False;
  if Ch=NextIsName then begin
    Pos2:=LastPos; ID:=NextName[1];
    Next; if Ch='=' then begin
      Next;
      Saved[ID]:=AddExpr;
      AssignStmt:=True;
    end else begin
      Position:=Pos2; Next;
    end;
  end;
end;

Label Exit;
begin {Main program}
  FillChar(Saved,SizeOf(Saved),0);
  writeln('MiniCalc for Atari');
  repeat
    write('* '); readln(CmdLine); if CmdLine='' then goto Exit;
    repeat
      Position:=Pos(';',CmdLine+';');
      InputLine:=Copy(CmdLine,1,Position-1);
      Delete(CmdLine,1,Position);
      Position:=0; Next;
      if (Ch<>NextIsEOF) then begin
        if not AssignStmt then begin
          R:=AddExpr;
          if Ch=NextIsEOF then begin
            write('= ');
            if abs(R)>1 then                  {Chose your own format}
              writeln(R:10:5)
            else
              if R=0 then writeln(0) else writeln(R);
          end;
        end;
        if Ch<>NextIsEOF then
          writeln(InputLine,#13#10'^ fejl':ErrPos+8);
      end;
    until (CmdLine='');
  until false;
Exit:
end.
