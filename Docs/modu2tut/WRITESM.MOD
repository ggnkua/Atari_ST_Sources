MODULE WriteSm;

FROM InOut IMPORT WriteLn, WriteString;

BEGIN

   WriteString("This line will be displayed on the monitor.");
   WriteLn;
   WriteString('This line will be displayed too.');
   WriteLn;
   WriteString("This will all be ");
   WriteString('on one line.');
   WriteLn;
   WriteString('She said, "I ');
   WriteString("don't ");
   WriteString('like dogs."');
   WriteLn;

END WriteSm.
