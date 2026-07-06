MODULE FreeRam;

FROM SYSTEM IMPORT ADDRESS;

FROM SYSCIO IMPORT Read, Write, WriteLongCard, WriteString;

FROM GEMDOS IMPORT Alloc;

VAR FreeMemory:         ADDRESS;
    ch:                 CHAR;

BEGIN (* FreeRam *)

  Alloc(LONGCARD(-1), FreeMemory);

  Write(CHR(27)); Write('E');

  WriteLongCard(LONGCARD(FreeMemory), 9);

  WriteString(' bytes free');

  Read(ch);

END FreeRam.
