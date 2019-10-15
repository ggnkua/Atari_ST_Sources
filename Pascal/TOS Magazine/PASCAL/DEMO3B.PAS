PROGRAM DEMO3B; (* Stringprozeduren/-funktionen *)

VAR s1,s2,s3:STRING;

BEGIN
s1:='AUTO';
s2:='MOBIL';
WRITELN('Die L„nge von >',s1,'< ist ',Length(s1),'.');
WRITELN('>TO< erscheint bei >',s1,'< an Position ',POS('TO',s1));

s3:=CONCAT(s1,s2,'E');
WRITELN('CONCAT(...): ',s3);
DELETE(s3,3,2);
WRITELN('Nach DELETE: ',s3);
INSERT('DREY',s3,3);
WRITELN('Nach INSERT: ',s3);
WRITELN('COPY: ',COPY(s3,7,3));
END.
