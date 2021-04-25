{=============================================================================}
{                    H.PAS : Hilfesystem, hier fuer GULAM                     }
{                                                                             }
{                    (c) Dirk Donath                                          }
{                        Vogelpothsweg 20                                     }
{                        4600 Dortmund 1                                      }
{=============================================================================}

program h;

var
  s : string;

{=============================================================================}

procedure in_grossbuchstaben(var text : string);

var 
  i : integer;

begin
  for i := 1 to length(text) do
    if (('a' <= text[i]) and (text[i] <= 'z')) then
      text[i] := chr(ord(text[i]) - 32);
end;  { in_grossbuchstaben }

{=============================================================================}

function IO_result : integer; external;

procedure hilf(name_HLPdatei : string; stichwort : string);

{ Durchsucht die Hilfedatei "name_HLPdatei" nach dem String "#stichwort" und
  gibt den darauf folgenden Text bis zum Endezeichen "#" aus }
  
var
  HLPdatei : text;
  s        : string;
  
begin
  reset(HLPdatei,name_HLPdatei);
  if (IO_result <> 0) then 
    begin
      writeln('*** No help available ***');
      halt;
    end;
  while ((not EOF(HLPdatei)) and (s <> concat('#',stichwort))) do
    readln(HLPdatei,s);
  if EOF(HLPdatei) then
    begin
      writeln('*** No help available ***');
      close(HLPdatei);
      halt;
    end;
  write(chr(27),'E');  
  loop
    readln(HLPdatei,s);
    exit if (s = '#');
    writeln(s);
  end;
  close(HLPdatei);
end;  { hilf }

{=============================================================================}

begin  { Hauptprogramm }
  write('Gulam Interactive Help System');
  write('                                  (c) D.Donath 1988');
  if (cmd_args > 0) then
    begin
      cmd_getarg(1,s);
      in_grossbuchstaben(s);
      if (s = 'MSOFF')    then s := 'MSON';
      if (s = 'POKEW')    then s := 'PEEKW';
      if (s = 'TEEXIT')   then s := 'TE';
      if (s = 'UNSETENV') then s := 'UNSET';
      if (s = 'COPY')     then s := 'CP';
      if (s = 'DIR')      then s := 'LS';
      if (s = 'TYPE')     then s := 'MORE';
      if (s = 'DEL')      then s := 'RM';
      if (s = 'ENDWHILE') then s := 'WHILE';
      hilf('GULAM.HLP',s);
    end
  else
    hilf('GULAM.HLP','COMMANDS');
end.  { hilfe }
      
{=============================================================================}
    
  


