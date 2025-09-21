PROGRAM rsc_install;
{ Demonstriert wie man Resourcen fest in Pascal einbaut. Hierzu werden
  die beiden Funktionen aus der Datei 'RSRC_CONV' hinzugelinkt. }

const
  {$I G:\include\gemconst.pas}
  
type
  {$I G:\include\gemtype.pas}
  
var
  dialog_adr:dialog_ptr;
  ex,i,rsh_nobs:integer;

  {$I G:\include\gemsubs.pas}

function make_pointer(a:dialog_ptr):pointer;
  external;
  
function rsrc_conv(mode:integer):integer;
  external;

procedure rsrc_obfix(tree:dialog_ptr;ob:integer);
var gintin:int_in_parms;
    gintout:int_out_parms;
    addrin:addr_in_parms;
    addrout:addr_out_parms;
begin
  gintin[0]:=ob;
  addrin[0]:=make_pointer(tree);
  aes_call($72,gintin,gintout,addrin,addrout);
end;


begin
  if init_gem>=0 then
  begin
    rsh_nobs:=rsrc_conv(0);  {Vektor verbiegen - RÅckgabewert ist egal}
    begin_update;   {keine Reaktion}
    rsh_nobs:=rsrc_conv(1);  {Vektor zurÅckbiegen und Resourcen anmelden}
    find_dialog(0,dialog_adr);  {Adresse von Baum 0 berechnen}
    for i:=0 to pred(rsh_nobs) do
      rsrc_obfix(dialog_adr,i);  {Koordinaten umrechnen}
    center_dialog(dialog_adr);
    ex:=do_dialog(dialog_adr,0);  {Baum 0 darstellen}
    end_dialog(dialog_adr);
    exit_gem;
  end;
end.

