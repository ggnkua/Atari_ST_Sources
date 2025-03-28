...
FROM SYSTEM IMPORT BYTE, WORD, VAL ;
...

TYPE WordByte = RECORD CASE : BOOLEAN OF
                         FALSE : w: WORD;
                       | TRUE  : b: ARRAY[0..1] OF BYTE;
                END END;

...

PROCEDURE Low(w:WORD):WORD;
VAR t: WordByte;
BEGIN
  t.w:=w;
  RETURN VAL(CARDINAL,t.b[1])
END Low;

PROCEDURE High(w:WORD):WORD;
VAR t: WordByte;
BEGIN
  t.w:=w;
  RETURN VAL(CARDINAL,t.b[0])
END High;

...




