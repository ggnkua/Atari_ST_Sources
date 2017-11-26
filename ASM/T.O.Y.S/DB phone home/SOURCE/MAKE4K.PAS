program make4k;

uses
  dos;
  
var
  SF,DF: File;
  sn: string[80];
  buf: packed array[0..4095] of byte;
  dummy: integer;
  
begin
  if paramcount<>1 then halt(1);
  
  sn:=paramstr(1);
  
  reset(SF,sn);
  blockread(SF,buf[0],4096,dummy);
  close(SF);
  
  rewrite(DF,sn);
  blockwrite(DF,buf[0],4096,dummy);
  close(DF);
  

end.