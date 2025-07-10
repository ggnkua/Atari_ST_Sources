IMPLEMENTATION MODULE Windows;

(* Ein einfache Anpassung der Wirth'schen Fensterroutinen an das      *)
(* Modul Textwindows von Megamax Modula 2                             *)

IMPORT TextWindows;
FROM StrConv     IMPORT CardToStr,IntToStr,StrToInt;


PROCEDURE OpenTextWindow
            (VAR u:TextWindows.Window; x,y,w,h:CARDINAL;name:ARRAY OF CHAR);
VAR success:BOOLEAN;
BEGIN
  TextWindows.Open(u,w,h,TextWindows.WQualitySet{TextWindows.titled},
           TextWindows.noHideWdw,TextWindows.noForce,name,x,y,w,h,success);
END OpenTextWindow;


PROCEDURE CloseTextWindow(u:TextWindows.Window);
BEGIN 
  TextWindows.Close(u)
END CloseTextWindow;


PROCEDURE Write(u:TextWindows.Window;ch:CHAR);
BEGIN
  TextWindows.Write(u,ch);
END Write;


PROCEDURE WriteCard(u:TextWindows.Window;x,n:CARDINAL);
BEGIN 
  TextWindows.WriteString(u,CardToStr(x,n))  
END WriteCard;


PROCEDURE ReadInt(u:TextWindows.Window;VAR x:INTEGER);
  VAR str:ARRAY [1..20] OF CHAR;
      pos:CARDINAL;
      valid:BOOLEAN;
BEGIN
  TextWindows.ReadString(u,str);
  TextWindows.WriteLn(u);
  pos:=0;
  x:=StrToInt(str,pos,valid);
  Done:=valid
END ReadInt;
  

PROCEDURE WriteInt(u:TextWindows.Window;x:INTEGER;n:CARDINAL);
BEGIN 
  TextWindows.WriteString(u,IntToStr(x,n))  
END WriteInt;


PROCEDURE Invert(u:TextWindows.Window;on:BOOLEAN);
BEGIN 
  IF on THEN
    TextWindows.Write(u,33C);
    TextWindows.Write(u,'p')
  ELSE
    TextWindows.Write(u,33C);
    TextWindows.Write(u,'q')
  END
END Invert;

PROCEDURE WriteLn(u:TextWindows.Window);
BEGIN 
  TextWindows.WriteLn(u)
END WriteLn;


PROCEDURE WriteString(u:TextWindows.Window; a:ARRAY OF CHAR);
BEGIN 
  TextWindows.WriteString(u,a);
END WriteString;


PROCEDURE ReadCard(u:TextWindows.Window;VAR x:CARDINAL);
BEGIN END ReadCard;


PROCEDURE Read(u:TextWindows.Window;ch:CHAR);
BEGIN
  TextWindows.Read(u,ch)
END Read;

END Windows.
