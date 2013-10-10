
        (*  TermCruncher -- Routinen zur Verarbeitung von mathe-  *
         *                  matischen AusdrÅcken und deren Be-    *
         *                  rechnung.                             *
         *                                                        *
         *  Version 0.2     V#0009                                *
         *                                                        *
         *  Written by Manuel Chakravarty     Created 07.08.1987  *)
         
DEFINITION MODULE TermCruncher;

TYPE    TermTree;       (* Baumstruktur die einen geparsten Term speichert *)
        CalcError       =(noError,divisionByZero,negSqrt,lnOfZero,arOutOfRange);

PROCEDURE ParseTerm(termStr:ARRAY OF CHAR;xAllowed,yAllowed,zAllowed:BOOLEAN;
                    VAR term:TermTree;VAR error:INTEGER);
                    
PROCEDURE CalcTerm(term:TermTree;x,y,z:REAL;VAR result:REAL;
                   VAR error:CalcError);

PROCEDURE VanishTree(VAR tree:TermTree);

PROCEDURE ReStringTerm(term:TermTree;VAR termStr:ARRAY OF CHAR);

END TermCruncher.
(* $FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$000001FC$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7A$FFFA6F7AÅ$000003ACT.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$000002B3$000002A4$000002B3$00000285$000003AC$00000159$00000442$00000000$0000042D$000002B3$00000202$0000042D$000003FF$0000042B$00000285$0000012DîÄÅ*)
