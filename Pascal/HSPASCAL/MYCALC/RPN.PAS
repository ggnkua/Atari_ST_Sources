{-------------------------------------------------------------------------
                   HighSpeed Pascal GEM accessory demo

                    RPN (Reverse Polish Notation) UNIT

                      Copyright (c) 1990 by D-House I
                            All rights reserved

                      Programmed by Martin Eskildsen
-------------------------------------------------------------------------}
{$R-,S-,D+,F-}

unit RPN;

INTERFACE

const
  width         = 17;           { output field width:digits     }
  digits        =  5;
  CR            = #13;          { Carriage Return               }
  BS            = #08;          { BackSpace                     }

type
  real          = extended;     { define calculator precision   }

var
  error         : integer;              { error code            }
  inputstring   : string [width];       { input string          }

{ Enter a char in the input string or react if the char is a command
  such as '+', '-', CR etc. }
procedure CharInput(ch : char);

{ Return the value of the top of the stack (x register) }
function TopOfStack : real;

IMPLEMENTATION

type
  stacktype     = record                { this is our stack     }
                    x, y, z, t : real   { structure : four regi-}
                  end;                  { sters                 }

var
  stack         : stacktype;            { the stack             }
  lift          : boolean;              { allow pushes if true  }

function TopOfStack : real;
begin
  TopOfStack := stack.x
end;

{ Return the value of the x register, and move the y and z registers up :
    x -> return value
    y -> x
    z -> y
    t    is left alone
}
function Pop : real;
begin
  with stack do begin
    Pop := x;
    x   := y;
    y   := z;
    z   := t
  end
end;

{ Push a value onto the stack :
      z -> t
      y -> z
      x -> y
  value -> x
}
procedure Push(n : real);
begin
  with stack do begin
    t := z;
    z := y;
    y := x;
    x := n
  end
end;

{ Swap the x and y registers, and enable stack lift }
procedure SwapXY;
var temp : real;
begin
  lift    := TRUE;
  temp    := stack.x;
  stack.x := stack.y;
  stack.y := temp
end;

{ Add the x and y register }
procedure Add;
begin
  Push(Pop + Pop)  { first pop gets x reg, second pop gets y reg }
end;

{ Push(y - x) }
procedure Sub;
begin
  Push(-Pop + Pop)
end;

{ Push(x * y) }
procedure Mult;
begin
  Push(Pop * Pop)
end;

{ Push(y / x) if x <> 0.0. Otherwise return error 1 }
procedure Divide;
var n : real;
begin
  n := Pop;
  if n = 0.0 then begin
    Push(n);
    Error := 0
  end
  else Push(Pop / n)
end;

{ Insert a character in the input string, or execute command }
procedure CharInput(ch : char);

  { Add the char to the input string, provided it's not full }
  procedure AddCh;
  begin
    if length(InputString) < width then InputString := InputString + ch
  end;

  { If the input string is empty, the x register is duplicated (pushed),
    otherwise the value formed by the string is evaluated and put on the
    stack
  }
  procedure MakeValue;
  var
    value  : real;
    errpos : integer;
  begin
    if InputString = '' then Push(stack.x)      { duplicate }
    else begin
      val(InputString, value, errpos);
      if errpos <> 0 then error := 1    { error 1 should never occur }
      else begin
        if lift then Push(value) else stack.x := value;
        lift := ch <> CR;
        if not lift then Push(value)
      end;
      InputString := ''
    end
  end;

begin { CharInput }
  error := -1;
  case ch of
    '0'..'9' : AddCh;
    '.'      : if pos('.', inputString) = 0 then AddCh;
    CR       : MakeValue;
    BS       : if length(inputString) > 0
               then delete(inputString, Length(InputString), 1)
               else begin
                 stack.x := 0.0;        { clear x reg if input string }
                 lift := FALSE          { was empty, else delete char }
               end
  else
    if InputString <> '' then MakeValue;
    case ch of
      '('      : push(-Pop);    { sign inversion }
      ')'      : SwapXY;
      '+'      : Add;
      '-'      : Sub;
      '*'      : Mult;
      '/'      : Divide
    end
  end
end;

begin { of unit }
  InputString := '';
  error := -1;
  lift  := FALSE;
  with stack do begin
    x := 0.0;
    y := 0.0;
    z := 0.0;
    t := 0.0
  end
end.
