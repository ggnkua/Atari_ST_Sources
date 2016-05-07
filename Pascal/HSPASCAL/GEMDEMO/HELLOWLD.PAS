program HelloWld;

Uses GemAES;

var Button,n: integer;
    CStr: String[50];

begin
  n:=appl_init;
  if n<>-1 then begin
    
    CStr:='[3][  Hello|  World][ Ok |Cancel]'#0;
    Button:=form_alert(1,CStr[1]);
    
    appl_exit;
    write('Thanks for pressing: ');
    if Button=1 then writeln('Ok') else writeln('Cancel');
  end;
end.
