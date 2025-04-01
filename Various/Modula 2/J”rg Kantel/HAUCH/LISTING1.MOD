MODULE TermTest;
FROM TermWindow IMPORT InitTerminal, OpenTerminal, CloseTerminal,
                       DeleteTerminal, Read, WriteString, WriteLn, ... ;
BEGIN
   InitTerminal;    (* Scheint auch alle n”tigen GEM- *)
   OpenTerminal     (* Anmeldungen zu erledigen       *)
   ...
   (* Jetzt die eigenen Ein- und Ausgaben *)
   ...
   CloseTerminal;
   DeleteTerminal;
END TermTest.
