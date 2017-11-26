program fixdbd;

uses
  dos;
  
var
  SF,DF:file;
  buf: packed array[0..401] of byte;
  sbuf: array[0..3] of word;
  sn,dn: string[80];
  dummy: integer;
  obj: integer;
  
begin
  if paramcount<>1 then halt(0);
  
  sn:=paramstr(1);
  dn:='level.dbd';
  
  reset(SF,sn);
  rewrite(DF,dn);
  
  blockread(SF,buf[0],402,dummy);
  blockwrite(DF,buf[0],402,dummy);
  
  obj:=-1;
  repeat
    obj:=obj+1;
    blockread(SF,sbuf[0],8,dummy);
    blockwrite(DF,sbuf[0],8,dummy);
  until sbuf[0]=0;

  close(SF);
  close(DF);

  writeln(obj,' objekt');
  repeat until keypressed;

end.