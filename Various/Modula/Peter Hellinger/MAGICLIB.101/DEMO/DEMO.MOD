(*ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
 * Dieses Modul ist (fast) ohne nderungen auf LPR-, SPC-, MM2- und TDI-
 * Modula compilier- und ausfhrbar.
 *
 * Es bedient sich dabei der Magic-Lib von Peter Hellinger
 *
 * Das Modul fragt nach einem Dateinamen, ”ffnet die Datei und listet
 * diese mittels der GEMDOS-Funktionen auf den Bildschirm.
 *
 *______________________________________________________________________*)


MODULE Demo;

FROM SYSTEM IMPORT ADR;
(* LPR + SPC: FROM SYSTEM IMPORT LONG, SHORT; *)

IMPORT MagicBIOS, MagicXBIOS, MagicDOS, MagicAES, MagicVDI;

VAR     a, b:   ARRAY [0..255] OF CHAR;
        bool:   BOOLEAN;
        id, i:  INTEGER;
        file,h: INTEGER;
        drv:    CARDINAL;    
        buf:    ARRAY [1..1024] OF CHAR;
        size,l: LONGCARD;


PROCEDURE Length (VAR str: ARRAY OF CHAR): CARDINAL;
VAR i, h: CARDINAL;
BEGIN
 i:= 0;  h:= HIGH (str);
 WHILE (i <= h) & (str[i] # 0C) DO  INC (i);  END;
 RETURN i;
END Length;


PROCEDURE Append (substr: ARRAY OF CHAR; VAR str: ARRAY OF CHAR);
VAR i, l, l1, h: CARDINAL;
BEGIN
 h:= HIGH(str);
 l1:= Length (str);
 l:= Length (substr);
 FOR i:= 0 TO l - 1 DO  str[i+l1]:= substr[i];  END;
 IF ((l + l1) < h)  THEN str[l + l1]:= 0C;  END;
END Append;


PROCEDURE DelTail (VAR path: ARRAY OF CHAR);
VAR l: CARDINAL;
BEGIN
 l:= Length (path);
 WHILE (path[l] # '\') AND (l > 0) DO
  path[l]:= 0C;  DEC (l);
 END;
END DelTail;
 


BEGIN
 id:= MagicAES.ApplInit();
 drv:= MagicDOS.Dgetdrv ();
 a:= 'A:\*.*';  a[0]:= CHR(drv + 65);  b:= '';
 IF MagicAES.FselInput (a, b) THEN
  DelTail (a);  Append (b, a);
  file:= MagicDOS.Fopen (a, MagicDOS.Read);
  IF file < 0 THEN 
   i:= MagicAES.FormAlert (1, '[3][Fehler beim ™ffnen der Datei][ Schade ]');
  ELSE
   MagicAES.GrafMouse (MagicAES.MOFF, NIL);
   MagicDOS.Cconout (CHR(27));
   MagicDOS.Cconout ('E');
   LOOP
    size:= 1024;
    MagicDOS.Fread (file, size, ADR(buf));
    IF size = LONG(0) THEN  EXIT;  END;
    i:= 1;  h:= SHORT(size);
    REPEAT 
     MagicDOS.Cconout (buf[i]);  INC(i);
    UNTIL i = h;
   END;
  END;
  file:= MagicDOS.Fclose (file);
 END;
 MagicAES.GrafMouse (MagicAES.MON, NIL);
 i:= MagicAES.FormAlert (1, '[0][ Das wars... ][ Ok ]');
 MagicAES.ApplExit;
END Demo.

