(* Tastaturpuffer per Accessory fÅllen *)
(* (c)1992 by MAXON-Computer           *)
(* Autor: Rainer Esser                 *)

{$M 4,4,10,20}
PROGRAM ausgabe_demo;
 
uses stpascal,dos,bios,gemdecl,gemaes; 
 
type
  str255=string[255];
 
VAR 
   menu_id,ap_id:integer;
   name,kette:str255;

PROCEDURE tastatur(ausgabe:str255;zeit:integer);
TYPE
  puffer=RECORD
    ibuf:longint;
    ibufsiz:integer;
    ibufhd:integer;
    ibuftl:integer;
    ibuflow:integer;
    ibufhi:integer;
  END;
  zeiger=^puffer;
VAR 
  t,i,event,dummy,timer:integer;
  aus:longint;
  zeiger1:^puffer;
  feld:ARRAY[0..158] OF longint;
  msg:array_8;
  p:^longint;
    
PROCEDURE tabelle;
BEGIN
  feld[0]:=$030000;
  feld[1]:=$1E0001;
  feld[2]:=$300002;
  feld[3]:=$2E0003;
  feld[4]:=$200004;
  feld[5]:=$120005;
  feld[6]:=$210006;
  feld[7]:=$220007;
  feld[8]:=$230008;
  feld[9]:=$170009;
  feld[10]:=$24000A;
  feld[11]:=$25000B;
  feld[12]:=$26000C;
  feld[13]:=$1C000D;
  feld[14]:=$31000E;
  feld[15]:=$18000F;
  feld[16]:=$190010;
  feld[17]:=$100011;
  feld[18]:=$130012;
  feld[19]:=$1F0013;
  feld[20]:=$140014;
  feld[21]:=$160015;
  feld[22]:=$2F0016;
  feld[23]:=$110017;
  feld[24]:=$2D0018;
  feld[25]:=$150019;
  feld[26]:=$2C001A;
  feld[27]:=$1A001B;
  feld[28]:=$28001C;
  feld[29]:=$1B001D;
  feld[30]:=$07001E;
  feld[31]:=$07001E;
  feld[32]:=$390020;
  feld[33]:=$020021;
  feld[34]:=$280022;
  feld[35]:=$040023;
  feld[36]:=$050024;
  feld[37]:=$060025;
  feld[38]:=$080026;
  feld[39]:=$280027;
  feld[40]:=$0A0028;
  feld[41]:=$0B0029;
  feld[42]:=$09002A;
  feld[43]:=$0D002B;
  feld[44]:=$33002C;
  feld[45]:=$0C002D;
  feld[46]:=$34002E;
  feld[47]:=$35002F;
  feld[48]:=$0B0030;
  feld[49]:=$020031;
  feld[50]:=$030032;
  feld[51]:=$040033;
  feld[52]:=$050034;
  feld[53]:=$060035;
  feld[54]:=$070036;
  feld[55]:=$080037;
  feld[56]:=$090038;
  feld[57]:=$0A0039;
  feld[58]:=$27003A;
  feld[59]:=$27003B;
  feld[60]:=$33003C;
  feld[61]:=$0D003D;
  feld[62]:=$34003E;
  feld[63]:=$35003F;
  feld[64]:=$030040;
  feld[65]:=$1E0041;
  feld[66]:=$300042;
  feld[67]:=$2E0043;
  feld[68]:=$200044;
  feld[69]:=$120045;
  feld[70]:=$210046;
  feld[71]:=$220047;
  feld[72]:=$230048;
  feld[73]:=$170049;
  feld[74]:=$24004A;
  feld[75]:=$25004B;
  feld[76]:=$26004C;
  feld[77]:=$32004D;
  feld[78]:=$31004E;
  feld[79]:=$18004F;
  feld[80]:=$190050;
  feld[81]:=$100051;
  feld[82]:=$130052;
  feld[83]:=$1F0053;
  feld[84]:=$140054;
  feld[85]:=$160055;
  feld[86]:=$2F0056;
  feld[87]:=$110057;
  feld[88]:=$2D0058;
  feld[89]:=$150059;
  feld[90]:=$2C005A;
  feld[91]:=$1A005B;
  feld[92]:=$2B005C;
  feld[93]:=$1B005D;
  feld[94]:=$07005E;
  feld[95]:=$0C005F;
  feld[96]:=$290060;
  feld[97]:=$1E0061;
  feld[98]:=$300062;
  feld[99]:=$2E0063;
  feld[100]:=$200064;
  feld[101]:=$120065;
  feld[102]:=$210066;
  feld[103]:=$220067;
  feld[104]:=$230068;
  feld[105]:=$170069;
  feld[106]:=$24006A;
  feld[107]:=$25006B;
  feld[108]:=$26006C;
  feld[109]:=$32006D;
  feld[110]:=$31006E;
  feld[111]:=$18006F;
  feld[112]:=$190070;
  feld[113]:=$100071;
  feld[114]:=$130072;
  feld[115]:=$1F0073;
  feld[116]:=$140074;
  feld[117]:=$160075;
  feld[118]:=$2F0076;
  feld[119]:=$110077;
  feld[120]:=$2D0078;
  feld[121]:=$150079;
  feld[122]:=$2C007A;
  feld[123]:=$1A007B;
  feld[124]:=$2B007C;
  feld[125]:=$1B007D;
  feld[126]:=$29007E;
  feld[127]:=$0E007F;
  feld[129]:=$030081;
  feld[132]:=$1B0084;
  feld[142]:=$1B008E;
  feld[148]:=$1A0094;
  feld[153]:=$1B0099;
  feld[154]:=$03009A;
  feld[158]:=$35009E
END;
  
BEGIN
  tabelle;
  zeiger1:=iorec(1);
  ausgabe:=concat(ausgabe,chr(13));
  timer:=100;
    evnt_timer(loword(timer),hiword(timer));
  FOR i:=1 TO length(ausgabe) DO
   BEGIN
     t:=ord(ausgabe[i]);
     aus:=feld[t];
     p:=ptr(zeiger1^.ibuf);
     p^:=aus;
     zeiger1^.ibuftl:=0;
     zeiger1^.ibufhd:=zeiger1^.ibufsiz;
     timer:=zeit*25;
     evnt_timer(loword(timer),hiword(timer));
  END
END;
  
  PROCEDURE clipboard(zeichenkette:str255);
   VAR 
      i,fehler:integer;
      drv,drv1:byte;
      pfad1,pfad2:string;
       rec:searchrec;  
       pfad:c_string;
         
  PROCEDURE clip_schreiben;
  VAR
  pfad3:str255;
  pfad:c_string;
  lauf:char;
  sp:pointer;
  p:^integer;
  drive:byte;
  boot:integer;
  
  BEGIN
    sp:=super(nil);
    new(p);
    p:=ptr($446);
    boot:=p^;
    dispose(p);
    p:=nil;
    sp:=super(sp);
    drv:=getdrive;
    lauf:=chr(boot+65);
    pfad3:=':\CLIPBRD\';
    pfad3:=concat(lauf,pfad3);
    pfad1:=pfad3;
    ptocstr(pfad3,pfad);
    drive:=boot;
    setdrive(drive);
    delete(pfad3,length(pfad3),1);
    delete(pfad3,1,2);
    {$I+}
    mkdir(pfad3);
    fehler:=doserror;
    {$I-}
    IF fehler=-36 THEN fehler:=0;
    if fehler<>(-13) then scrp_write(pfad);
    setdrive(drv);
END;
  
  PROCEDURE datei_schreiben;
  VAR aus:c_string;
      pfad3:string;
      fhandle:file;
      laenge,dummy,i:integer;
  
  BEGIN
    pfad3:='SCRAP.TXT';
    pfad3:=concat(pfad1,pfad3);
    rewrite(fhandle,pfad3);
    laenge:=length(zeichenkette);
    for i:=1 to length(zeichenkette) do aus[i-1]:=zeichenkette[i];
    aus[i]:=chr(0);
    blockwrite(fhandle,aus,laenge,dummy);
    close(fhandle);
end;  
  
  PROCEDURE datei_loeschen;
  VAR s:integer;
      str:string;
  
  BEGIN
    s:=0;
   REPEAT
     str:=rec.name;
     str:=concat(pfad1,str);
     erase(str);
    findnext(rec);
    s:=doserror;
   UNTIL s<0;
   i:=(-1)
  END;
  
  
  BEGIN
    fehler:=0;
    scrp_read(pfad);
    ctopstr(pfad,pfad1);
    IF length(pfad1)<=0 THEN clip_schreiben;   {kein Pfad gefunden}
    IF fehler>=0 THEN
     BEGIN
       if length(pfad1)>0 THEN
        BEGIN
          drv:=getdrive;
          IF pfad1[length(pfad1)]<>'\' THEN pfad1:=concat(pfad1,'\');
          pfad2:=pfad1;
          drv1:=ord(pfad1[1])-65;
          setdrive(drv1);
          delete(pfad2,1,2);
          pfad2:=concat(pfad2,'SCRAP.*');
          {$I+}
          findfirst(pfad2,$3F,rec); {Nach Dateien im Clipboard suchen}
          i:=doserror;
          {$I-}
          IF i=0 THEN datei_loeschen;
          IF (i<0) AND (i<>-13) THEN datei_schreiben;
          setdrive(drv);
        end;
      end;  
   END;

procedure test;
var 
  aus:str255;

begin
  aus:='Dies ist ein Probetext fÅr die Ausgabe Åber Tastatur und Clipboard';
  tastatur(aus,2);
  clipboard(aus);
end;



PROCEDURE event_loop;
VAR
 event,dummy:integer;
 msg:array_8;
  
BEGIN
  WHILE true DO
   BEGIN
    evnt_mesag(msg);
    IF (msg[0]=ac_open) AND (msg[4]=menu_id) THEN test;
  END
END;
  
BEGIN
  ap_id:=appl_init;
  IF ap_id>=0 THEN
   BEGIN
    name:='  Ausgabe De Luxe'#0;
    menu_id:=menu_register(ap_id,name[1]);
    event_loop;
  END
end. 
  

   