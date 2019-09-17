PROGRAM truth_table_generator;
USES things, printer, crt;

CONST
  notc    = '!';
  andc    = '.';
  nandc   = ',';
  orc     = '+';
  norc    = '-';
  xorc    = '*';
  xnorc   = '/';


VAR
  holder, sim         : string;
  b, i, j, k, l       : boolean;
  karno               : packed array [0..3, 0..3] OF boolean;

PROCEDURE error (n  : byte;s  : string);
BEGIN
  WRITELN;
  WRITELN ('Error in evaluate, incorrect string def.');
  WRITELN ('.'+s+'.',LENGTH (s),'.',n);
  HALT;
END;

FUNCTION dand (c, d : char)  : char;
BEGIN
  IF (c='1') AND (d='1') THEN dand:='1'
    ELSE dand:='0';
END;

PROCEDURE hitletters (VAR s : string;i, j, k, l : boolean);
VAR
  n         : byte;
BEGIN
  n:=1;
  REPEAT
    n:=POS (notc, s);
    IF n<>0 THEN DELETE (s, n, 1);
    CASE s[n] OF
      'I' : IF i THEN s[n]:='0' ELSE s[n]:='1';
      'J' : IF j THEN s[n]:='0' ELSE s[n]:='1';
      'K' : IF k THEN s[n]:='0' ELSE s[n]:='1';
      'L' : IF l THEN s[n]:='0' ELSE s[n]:='1';
    END;
  UNTIL n=0;
  FOR n:=1 TO LENGTH (s)  DO
    CASE s[n] OF
      'I' : IF i THEN s[n]:='1' ELSE s[n]:='0';
      'J' : IF j THEN s[n]:='1' ELSE s[n]:='0';
      'K' : IF k THEN s[n]:='1' ELSE s[n]:='0';
      'L' : IF l THEN s[n]:='1' ELSE s[n]:='0';
    END;
END;

PROCEDURE dropin (VAR holder  : string; i, j, k, l  : boolean);
VAR
  n               : byte;
BEGIN
  n:=1;
  REPEAT
    CASE holder[n] OF
      andc    : BEGIN
                  holder [n-1]:=dand (holder [n-1], holder [n+1]);
                  DELETE (holder, n, 2);
                  DEC (n);
                END;
      nandc   : BEGIN
                  IF (holder [n-1]='0') AND (holder[n+1]='0')
                    THEN holder[n-1]:='1' ELSE holder[n-1]:='0';
                  DELETE (holder, n, 2);
                  DEC (n);
                END;
      orc     : BEGIN
                  IF (holder [n-1]='0') AND (holder[n+1]='0')
                    THEN holder[n-1]:='0' ELSE holder[n-1]:='1';
                  DELETE (holder, n, 2);
                  DEC (n);
                END;
      norc    : BEGIN
                  IF (holder [n-1]='1') AND (holder[n+1]='1')
                    THEN holder[n-1]:='0' ELSE holder[n-1]:='1';
                  DELETE (holder, n, 2);
                  DEC (n);
                END;
      xorc    : BEGIN
                  IF   ((holder [n-1]='1') AND (holder[n+1]='0'))
                    OR ((holder [n-1]='0') AND (holder[n+1]='1'))
                    THEN holder[n-1]:='1' ELSE holder[n-1]:='0';
                  DELETE (holder, n, 2);
                  DEC (n);
                END;
      xnorc   : BEGIN
                  IF   ((holder [n-1]='1') AND (holder[n+1]='0'))
                    OR ((holder [n-1]='0') AND (holder[n+1]='1'))
                    THEN holder[n-1]:='0' ELSE holder[n-1]:='1';
                  DELETE (holder, n, 2);
                  DEC (n);
                END;
      '1',
      '0'     : ;
    ELSE
      error (n, holder);
    END;
    INC (n);
  UNTIL (LENGTH (holder)=1) OR (n>LENGTH (holder));
END;

FUNCTION bool (b : boolean) : string;
BEGIN
  IF b THEN bool:='1' ELSE bool:='0';
END;

FUNCTION evaluate (i, j, k, l : boolean; holder:string): boolean;
VAR
  n, m              : byte;
  s                 : string;
BEGIN
  hitletters (holder, i, j, k, l);
  n:=LENGTH (holder);
  REPEAT
    IF holder[n]='(' THEN
    BEGIN
      m:=n;
      REPEAT
        INC (m);
      UNTIL (holder [m]=')') OR (m>LENGTH (holder));
      s:=COPY (holder, n+1, (m-n)-1);
      dropin (s, i, j, k, l);
      DELETE (holder, n, (m-n));
      holder [n]:=s[1];
    END;
    DEC (n);
  UNTIL n=0;  
  dropin (holder, i, j, k, l);
  IF LENGTH (holder)>1 THEN error (n, holder);
  CASE holder[1] OF
    '1' : evaluate:=TRUE;
    '0' : evaluate:=FALSE;
  ELSE
    error (n, holder); 
  END;
END;

PROCEDURE putinkarno (i, j, k, l, b : boolean);
VAR
  x, y        : byte;
BEGIN
  x:=0;
  y:=0;
  IF (i)       AND (j) THEN x:=2;
  IF (NOT (i)) AND (j) THEN x:=1;
  IF (NOT (j)) AND (i) THEN x:=3;
  IF (k)       AND (l) THEN y:=2;
  IF (NOT (k)) AND (l) THEN y:=1;
  IF (NOT (l)) AND (k) THEN y:=3;
  karno [x, y]:=b;
END;

PROCEDURE dotable (VAR o  : text);
VAR
  count               : byte;
  b                   : boolean;
BEGIN
  i:=FALSE;
  j:=FALSE;
  k:=FALSE;
  l:=FALSE;
  count:=0;
  WRITELN (o, '   C | I   J   K   L |  R');
  WRITELN (o, '-----+---------------+---');
  REPEAT
    WRITE (o, count :4,' |', bool (i):2, bool (j):4,bool (k):4, bool (l):4);
    b:=evaluate (i, j, k, l, holder);
    putinkarno (i, j, k, l, b);
    WRITELN (o, ' |',bool (b):3);
    INC (count);
    l:=BOOLEAN (count AND 1);
    k:=BOOLEAN ((count  DIV 2) AND 1);
    j:=BOOLEAN ((count  DIV 4) AND 1);
    i:=BOOLEAN ((count  DIV 8) AND 1);
  UNTIL (NOT (i)) AND (NOT (j)) AND (NOT (k)) AND (NOT (l));
END;

FUNCTION checkchar (VAR s  : string) : boolean;
VAR
  n             : byte;
BEGIN
  checkchar:=TRUE;
  FOR n:=1 TO LENGTH (holder) DO
  BEGIN
    IF holder[n] in ['I'..'L'] THEN
    BEGIN
      IF holder [n-1]<>notc THEN INSERT (notc, holder, n);
    END ELSE holder[n]:=UPCASE (holder[n]);
    IF holder[n] in [' ',andc, notc, orc, xorc, xnorc, nandc, norc, 'I'..'L', '(', ')', '1', '0'] THEN
      ELSE checkchar:=FALSE;
  END;
  REPEAT
    IF POS (' ', holder)<>0 THEN DELETE (holder, POS (' ', holder), 1);
  UNTIL (POS (' ', holder)=0);
  REPEAT
    n:=POS (')(', holder);
    IF n<>0 THEN INSERT ('+', holder, n+1);
  UNTIL n=0;
END;

PROCEDURE dokarno (p : boolean);
VAR
  x, y        : byte;
BEGIN
  IF p THEN
  BEGIN
    WRITELN;
    WRITELN (lst, 'KL \ IJ|  00     01     11     10');
    WRITELN (lst, '---+-----------------------------');
    WRITELN (lst, '00 | ',bool (karno [0, 0]):7, bool (karno[1, 0]):7, bool (karno[2, 0]):7, bool (karno[3, 0]):7);
    WRITELN (lst, '01 | ',bool (karno [0, 1]):7, bool (karno[1, 1]):7, bool (karno[2, 1]):7, bool (karno[3, 1]):7);
    WRITELN (lst, '11 | ',bool (karno [0, 2]):7, bool (karno[1, 2]):7, bool (karno[2, 2]):7, bool (karno[3, 2]):7);
    WRITELN (lst, '10 | ',bool (karno [0, 3]):7, bool (karno[1, 3]):7, bool (karno[2, 3]):7, bool (karno[3, 3]):7);
  END ELSE BEGIN
    GOTOXY (40, 6);
    WRITELN ('KL \ IJ|  00     01     11     10');
    GOTOXY (40, 7);
    WRITELN ('---+-----------------------------');
    GOTOXY (40, 8);
    WRITELN ('00 | ',bool (karno [0, 0]):7, bool (karno[1, 0]):7, bool (karno[2, 0]):7, bool (karno[3, 0]):7);
    GOTOXY (40, 9);
    WRITELN ('01 | ',bool (karno [0, 1]):7, bool (karno[1, 1]):7, bool (karno[2, 1]):7, bool (karno[3, 1]):7);
    GOTOXY (40, 10);
    WRITELN ('11 | ',bool (karno [0, 2]):7, bool (karno[1, 2]):7, bool (karno[2, 2]):7, bool (karno[3, 2]):7);
    GOTOXY (40, 11);
    WRITELN ('10 | ',bool (karno [0, 3]):7, bool (karno[1, 3]):7, bool (karno[2, 3]):7, bool (karno[3, 3]):7);
  END;
END;

BEGIN
  CLRSCR;
  WRITELN;
  WRITELN ('i=i j=j k=k l=l I=!i J=!j K=!k L=!l');
  WRITELN ('AND : '+andc+' OR : '+orc+
        ' XOR : '+xorc+' NOT : '+notc+
        ' NAND : '+nandc+' NOR : '+norc+' XNOR : '+xnorc
        +'  COUNTRS IJKL');
  WRITELN ('Enter Expresion :-');
  holder:=getstring (1, 5, 80, '', '', TRUE, b);
  IF NOT (checkchar (holder)) THEN WRITELN ('Incorrect definition.')
  ELSE BEGIN
    dotable (output);
    dokarno (FALSE);
{    dosim;
    GOTOXY (1, 24);
    WRITE ('Is equilivent to :- ',sim);}
    GOTOXY (50, 15);
    WRITE ('Output to printer (Y\N)');
    IF UPCASE (getchar)='Y'  THEN
    BEGIN
      WRITELN (lst, 'EXPRESION :-');
      WRITELN (lst, holder);
      dotable (lst);
      dokarno (TRUE);
    END;
  END;
  GOTOXY (50, 17);
  WRITE ('Press a key to exit');
  WRITE (getchar);
  GOTOXY (25, 1);
END.