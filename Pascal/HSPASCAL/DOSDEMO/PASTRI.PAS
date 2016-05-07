PROGRAM PasTri; (* Pascal/S (ST) ver. 22.07.89 *)

CONST
  cols = 13;

VAR
  row : ARRAY[0..cols] OF integer;
  i,j : integer;
  max : integer;

BEGIN
  ClrScr;
  REPEAT
    REPEAT
      gotoxy(1,21);
      write('Size: (1-',cols:1,'; 0 = stop) : '); 
      ClrEol;
      read(max);
      writeln
    UNTIL (max>=0) AND (max<=cols);
    IF max>0 THEN BEGIN
      gotoxy(1,4);
      FOR i:=0 TO cols DO row[i]:=0;
      row[1]:=1;
      FOR j:=1 TO cols DO BEGIN
        IF j<=max THEN BEGIN
          FOR i:=j DOWNTO 1 DO row[i]:=row[i]+row[i-1];
          write(' ':3*(cols-j));
          FOR i:=1 TO j DO write(row[i]:6)
        END;
        ClrEol; Writeln;
      END
    END
  UNTIL max=0;
END.
