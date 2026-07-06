LISTING ELEVEN
IMPLEMENTATION MODULE LongNumbers;            
(* Routines to handle HEX digits for the X68000 cross assembler. *)
(* All but LongPut and LongWrite are limited to 8 digit numbers. *)

   FROM Files IMPORT
      FILE;

   IMPORT Files;   (* Write *)

   IMPORT Terminal;   (* Write *)

(*---
(* These objects are declared in the DEFINITION MODULE *)

   CONST
      DIGITS = 8;
      BASE = 16;

   TYPE
      LONG = ARRAY [1..DIGITS] OF INTEGER;
                                                    ---*)              

   CONST
      Zero = 30H;
      Nine = 39H;
      hexA = 41H;
      hexF = 46H;



   PROCEDURE LongClear (VAR A : LONG);
   (* Sets A to Zero *)

      VAR
         i : CARDINAL;

      BEGIN
         FOR i := 1 TO DIGITS DO
            A[i] := 0;
         END;
      END LongClear;



   PROCEDURE LongAdd (A, B : LONG; VAR Result : LONG);
   (* Add two LONGs, giving Result *)

      VAR
         Carry : INTEGER;
         i : CARDINAL;

      BEGIN
         Carry := 0;
         FOR i := 1 TO DIGITS DO
            Result[i] := (A[i] + Carry) + B[i];
            IF Result[i] >= BASE THEN
               Result[i] := Result[i] - BASE;
               Carry := 1;
            ELSE
               Carry := 0;
            END;
         END;
      END LongAdd;



   PROCEDURE LongSub (A, B : LONG; VAR Result : LONG);
   (* Subtract two LONGs (A - B), giving Result *)

      VAR
         Borrow : INTEGER;
         i : CARDINAL;

      BEGIN
         Borrow := 0;
         FOR i := 1 TO DIGITS DO
            Result[i] := (A[i] - Borrow) - B[i];
            IF Result[i] < 0 THEN
               Result[i] := Result[i] + BASE;
               Borrow := 1;
            ELSE
               Borrow := 0;
            END;
         END;
      END LongSub;



   PROCEDURE CardToLong (n : CARDINAL; VAR A : LONG);
   (* Converts CARDINALs to LONGs *)

      VAR
         i : CARDINAL;

      BEGIN
         LongClear (A);

         i := 1;
         REPEAT
            A[i] := n MOD BASE;
            INC (i);
            n := n DIV BASE;
         UNTIL n = 0;
      END CardToLong;



   PROCEDURE LongToCard (A : LONG; VAR n : CARDINAL) : BOOLEAN;
   (* Converts LONG TO CARDINAL, returns FALSE if conversion impossible *)
      BEGIN
         n := (A[4] * 4096) + (A[3] * 256) + (A[2] * 16) + A[1];
         RETURN ((A[5] = 0) AND (A[6] = 0) AND (A[7] = 0) AND (A[8] = 0));
      END LongToCard;



   PROCEDURE LongToInt (A : LONG; VAR n : INTEGER) : BOOLEAN;
   (* Converts LONG to INTEGER, returns FALSE if conversion impossible *)

      VAR
         TempC : CARDINAL;
         Neg : BOOLEAN;

      BEGIN
         IF (A[5] = 0) AND (A[6] = 0) AND (A[7] = 0) AND (A[8] = 0) THEN
            Neg := FALSE;
         ELSIF (A[5] = 15) AND (A[6] = 15) AND (A[7] = 15) AND (A[8] = 15) THEN
            Neg := TRUE;
         ELSE
            RETURN FALSE;   (* Out of INTEGER range *)
         END;
      
         TempC := (A[4] * 4096) + (A[3] * 256) + (A[2] * 16) + A[1];
         IF ((TempC <= 32767) AND (NOT Neg)) OR ((TempC > 32767) AND Neg) THEN
            n := INTEGER (TempC);
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END;
      END LongToInt;



   PROCEDURE LongInc (VAR A : LONG; n : CARDINAL);
   (* Increment LONG by n *)

      VAR
         T : LONG;

      BEGIN
         CardToLong (n, T);
         LongAdd (A, T, A);
      END LongInc;



   PROCEDURE LongDec (VAR A : LONG; n : CARDINAL);
   (* Decrement LONG by n *)

      VAR
         T : LONG;

      BEGIN
         CardToLong (n, T);
         LongSub (A, T, A);
      END LongDec;



   PROCEDURE LongCompare (A, B : LONG) : INTEGER;
   (* Returns: 0 if A = B, -1 if A < B, +1 if A > B *)

      VAR
         i : CARDINAL;

      BEGIN
         i := DIGITS;
         WHILE (i > 0) AND (A[i] = B[i]) DO
            DEC (i);
         END;
         
         IF i = 0 THEN
            RETURN 0;
         ELSIF A[i] < B[i] THEN
            RETURN -1;
         ELSIF A[i] > B[i] THEN
            RETURN +1;
         ELSE
            (* Impossible! *)
         END;
      END LongCompare;



   PROCEDURE GetDigit (n : INTEGER) : CHAR;
   (* Function returning HEX character corresponding to digit *) 

      BEGIN
         IF (n >= 0) AND (n <= 9) THEN
            RETURN CHR (CARDINAL (n) + Zero);
         ELSIF (n >= 10) AND (n <= 15) THEN
            RETURN CHR ((CARDINAL (n) - 10) + hexA);
         ELSE
            RETURN '*';
         END;
      END GetDigit;



   PROCEDURE LongPut (f : FILE; A : ARRAY OF INTEGER; Size : CARDINAL);
   (* Put LONG number in FILE f *)
   
      VAR
         i : CARDINAL;
   
      BEGIN
         IF Size = 0 THEN
            RETURN;
         END;

         DEC (Size);   (* adjust for zero-based array *)
         IF Size > HIGH (A) THEN
            Size := HIGH (A);
         END;

         FOR i := Size TO 0 BY -1 DO
            Files.Write (f, GetDigit (A[i]));
         END;
      END LongPut;



   PROCEDURE LongWrite (A : ARRAY OF INTEGER; Size : CARDINAL);
   (* Write LONG number to console screen *)

      VAR
         i : CARDINAL;
   
      BEGIN
         IF Size = 0 THEN
            RETURN;
         END;

         DEC (Size);
         IF Size > HIGH (A) THEN
            Size := HIGH (A);
         END;

         FOR i := Size TO 0 BY -1 DO
            Terminal.Write (GetDigit (A[i]));
         END;
      END LongWrite;



   PROCEDURE IsHEX (c : CHAR) : BOOLEAN;
   (* checks if c is one of 0..9, A..F *)
   
      VAR
         C : CARDINAL;

      BEGIN
         C := ORD (CAP (c));
      
         RETURN (((C >= Zero) AND (C <= Nine)) OR
                 ((C >= hexA) AND (C <= hexF)));
      END IsHEX;


   
   PROCEDURE GetHEX (c : CHAR) : INTEGER;
   (* returns HEX value of character *)

      VAR
         C : CARDINAL;

      BEGIN
         C := ORD (CAP (c));
         IF C < hexA THEN
            RETURN INTEGER (C - Zero);
         ELSE
            RETURN 10 + INTEGER (C - hexA);
         END;
      END GetHEX;



   PROCEDURE StringToLong (S : ARRAY OF CHAR; VAR A : LONG) : BOOLEAN;
   (* Converts a string (in HEX) into a LONG *)

      VAR
         i, j : CARDINAL;

      BEGIN
         LongClear (A);

         IF S[0] # '$' THEN
            RETURN FALSE;   (* not a HEX string *)
         ELSE
            j := 1;
            WHILE (IsHEX (S[j])) AND (j <= DIGITS) DO
               INC (j);
            END;     

            DEC (j);   (* gone too far, so back up one *)
            i := 1;
            WHILE j > 0 DO
               A[i] := GetHEX (S[j]);
               INC (i);   DEC (j);
            END;       

            RETURN (i > 1);
         END;
      END StringToLong;



   PROCEDURE AddrBoundL (VAR A : LONG);
   (* Forces A to a long word boundary *)
      BEGIN
         WHILE NOT (CARDINAL (A[1]) IN {0, 4, 8, 12}) DO
            LongInc (A, 1);
         END;
      END AddrBoundL;



   PROCEDURE AddrBoundW (VAR A : LONG);
   (* Forces A to a word boundary *)
      BEGIN
         WHILE NOT (CARDINAL (A[1]) IN {0, 2, 4, 6, 8, 10, 12, 14}) DO
            LongInc (A, 1);
         END;
      END AddrBoundW;

END LongNumbers.
----------------------------------------
LISTING TWELVE
IMPLEMENTATION MODULE CmdLin2;
(* Parses command line - returns pointer to an array of pointer to strings *)

   FROM SYSTEM IMPORT
      ADDRESS, ADR;


   CONST
      MAXARGS = 5;


   VAR
      CommandLine[80H] : ARRAY [0..7FH] OF CHAR;
      Arguments : ARRAY [0..MAXARGS - 1] OF ADDRESS;


   PROCEDURE ReadCmdLin (VAR ArgC : CARDINAL; VAR ArgV : ADDRESS);
   (* Gives count of items in command line, and an array of pointer to them *)

      VAR
         i, C : CARDINAL;

      BEGIN
         IF ORD (CommandLine[0]) = 0 THEN
            ArgC := 0;   (* Nothing in Command Tail Buffer *)
            ArgV := NIL;
         ELSE
            i := 1;   C := 0;

            LOOP
               WHILE CommandLine[i] = ' ' DO   (* Skip Blanks *)
                  INC (i);
               END;
      
               IF CommandLine[i] = 0C THEN   (* end of tail buffer *)
                  EXIT;
               ELSE
                  Arguments[C] := ADR (CommandLine[i]);
                  INC (C);
                  IF C = MAXARGS THEN
                     EXIT;
                  END;
               END;

               WHILE CommandLine[i] # ' ' DO   (* Advance to next Argument *)
                  INC (i);
                  IF CommandLine[i] = 0C THEN
                     EXIT;
                  END;
               END;

               CommandLine[i] := 0C;   (* Terminate Argument *)
               INC (i);
            END;   (* LOOP *)

            CommandLine[0] := 0C;   (* Command Tail must only be used once *)
            ArgC := C;
            ArgV := ADR (Arguments);      
         END;
      END ReadCmdLin;

END CmdLin2.
----------------------------------------
LISITNG THIRTEEN
IMPLEMENTATION MODULE Parser;
(* Reads the Source file, and splits each *)
(* line into Label, OpCode & Operand(s).  *)

   FROM Strings IMPORT
      STRING;

   FROM Files IMPORT
      FILE, EOF, Read;

   FROM ErrorX68 IMPORT
      ErrorType, Error;

   IMPORT ASCII;


(*---
(* These objects are declared in the DEFINITION MODULE *)
   CONST
      TokenSize = 8;
      OperandSize = 20;

   TYPE
      TOKEN = ARRAY [0..TokenSize] OF CHAR;
      OPERAND = ARRAY [0..OperandSize] OF CHAR;

   VAR
      OpLoc, SrcLoc, DestLoc : CARDINAL;   (* location of line parts *)
      Line : STRING;
      LineCount : CARDINAL;
                                                                  ---*)


   PROCEDURE GetLine (f : FILE; VAR EndFile : BOOLEAN);
   (* Inputs a Line -- up to 80 characters ending in cr/lf -- from a file. *)

      CONST
         MAXLINE = 80;

      VAR
         i : CARDINAL;
         ch : CHAR;

      PROCEDURE Get (VAR c : CHAR) : CHAR;
         BEGIN
            IF NOT EOF (f) THEN
               Read (f, c);
               RETURN c;
            ELSE
               EndFile := TRUE;
            END;
         END Get;
      
      BEGIN   (* GetLine *)
         EndFile := FALSE;

         i := 0;
         WHILE (i < MAXLINE) AND (Get (ch) # ASCII.lf) AND (NOT EndFile) DO
            Line[i] := ch;
            INC (i);
         END;
         
         IF Line[i - 1] = ASCII.cr THEN   (* Strip cr/lf - terminate with 0C *)
            Line[i - 1] := 0C;
         ELSE
            Line[i] := 0C;
         END;

         INC (LineCount);
      END GetLine;


   
   PROCEDURE SplitLine (VAR Label, OpCode : TOKEN; 
                        VAR SrcOp, DestOp : OPERAND);
   (* Separates TOKENs & OPERANDs from Line. *)

      CONST
         Quote = 47C;
         StringMAX = 12;
      
      VAR
         i, j : CARDINAL;
         ParCnt : INTEGER;   (* Tracks open parentheses *)
         c : CHAR;
         InQuotes : BOOLEAN;

      PROCEDURE Cap (ch : CHAR) : CHAR;
         BEGIN
            IF InQuotes THEN
               RETURN (ch);
            ELSE
               RETURN CAP (ch);
            END;
         END Cap;

      PROCEDURE White (ch : CHAR) : BOOLEAN;
         BEGIN
            RETURN ((ch = ASCII.ht) OR (ch = ' '));
         END White;

      PROCEDURE Delimiter (ch : CHAR) : BOOLEAN;
         BEGIN
            RETURN ((NOT InQuotes) AND 
                   ((ch = ASCII.ht) OR (ch = ' ') OR (ch = 0C)));
         END Delimiter;

      PROCEDURE OpDelimiter (ch : CHAR) : BOOLEAN;
         BEGIN
            RETURN ((NOT InQuotes) AND (ch = ',') AND (ParCnt = 0));
         END OpDelimiter;

      PROCEDURE Done (ch : CHAR) : BOOLEAN;
      (* look for start of comment or NULL terminator *)
         BEGIN
            RETURN ((ch = ';') OR (ch = 0C) OR ((ch = '*') AND (i = 0)));
         END Done;

   
      BEGIN   (* SplitLine *)
         i := 0;
         InQuotes := FALSE;

         IF Done (Line[i]) THEN   (* look for blank or all-comment line *)
            RETURN;
         END;

         IF White (Line[i]) THEN
            INC (i);
            WHILE White (Line[i]) DO
               INC (i);   (* Skip spaces & tabs *)
            END;
         ELSE   (* Found a Label *)
            j := 0;
            c := Line[i];
            WHILE (NOT Delimiter (c)) AND (j < TokenSize) DO
               Label[j] := CAP (c);
               INC (i);   INC (j);
               c := Line[i];
            END;
            Label[j] := 0C;   (* terminate Label string *)
            IF j = TokenSize THEN
               Error (i, TooLong);
            END;
            WHILE NOT Delimiter (Line[i]) DO 
               INC (i);   (* Skip remainder of Too-Long Token *)
            END;
         END;

         WHILE White (Line[i]) DO
            INC (i);
         END;

         IF Done (Line[i]) THEN
            RETURN;
         ELSE   (* Found an OpCode *)
            OpLoc := i;
            j := 0;
            c := Line[i];
            WHILE (NOT Delimiter (c)) AND (j < TokenSize) DO
               OpCode[j] := CAP (c);
               INC (i);   INC (j);
               c := Line[i];
            END;
            OpCode[j] := 0C;  
            IF j = TokenSize THEN
               Error (i, TooLong);
            END;
            WHILE NOT Delimiter (Line[i]) DO 
               INC (i);   (* Skip remainder of Too-Long Token *)
            END;
         END;

         WHILE White (Line[i]) DO
            INC (i);
         END;

         IF Done (Line[i]) THEN
            RETURN;
         ELSE   (* Found 1st Operand *)
            SrcLoc := i;
            j := 0;
            ParCnt := 0;
            c := Line[i];
            IF c = Quote THEN   (* String Constant *)
               SrcOp[j] := c;   
               INC (i);   INC (j);
               REPEAT
                  c := Line[i];
                  SrcOp[j] := c;
                  INC (i);   INC (j);
               UNTIL (c = Quote) OR (j > StringMAX) OR (c = 0C);
               SrcOp[j] := 0C;
               IF j > StringMAX THEN
                  Error (i, TooLong);
               END;
               RETURN;  (* second operand not allowed after string constant *)
            ELSE   (* Normal Operand *)
               WHILE (NOT Delimiter (c)) 
                AND (NOT OpDelimiter (c)) 
                 AND (j < OperandSize) DO
                  IF c = Quote THEN
                     InQuotes := NOT InQuotes;   (* Toggle Switch *)
                  END;
                  IF NOT InQuotes THEN
                     IF c = '(' THEN
                        INC (ParCnt);
                     END;
                     IF c = ')' THEN
                        DEC (ParCnt);
                     END;
                  END;
                  SrcOp[j] := Cap (c);   (* Switched CAP function *)
                  INC (i);   INC (j);
                  c := Line[i];
               END;
               SrcOp[j] := 0C;
               IF j = OperandSize THEN
                  Error (i, TooLong);
               END;
            END;
            WHILE (NOT Delimiter (Line[i])) AND (NOT OpDelimiter (Line[i])) DO 
               INC (i);   (* Skip remainder of Too-Long Operand *)
            END;
         END;

         IF NOT OpDelimiter (Line[i]) THEN
            RETURN;   (* because only one OPERAND *)
         ELSE   (* Found 2nd Operand *)
            INC (i);   (* Skip OpDelimiter (comma) *)
            DestLoc := i;
            j := 0;
            c := Line[i];
            WHILE (NOT Delimiter (c)) AND (j < OperandSize) DO
               DestOp[j] := CAP (c);
               INC (i);   INC (j);
               c := Line[i];
            END;
            DestOp[j] := 0C;
            IF j = OperandSize THEN
               Error (i, TooLong);
            END;
         END;
      END SplitLine;



   PROCEDURE LineParts (f : FILE; VAR EndFile : BOOLEAN;
                        VAR Label, OpCode : TOKEN; 
                        VAR SrcOp, DestOp : OPERAND);
   (* Reads line, breaks into tokens, on-passes to symbol & code generators *)

      BEGIN
         Line := "";
         GetLine (f, EndFile);   (* read a line from the file *)

         Label := "";   OpCode := "";   SrcOp := "";   DestOp := "";
         IF EndFile THEN
            Error (0, EndErr);
         ELSE
            SplitLine (Label, OpCode, SrcOp, DestOp);
         END;
      END LineParts;   



BEGIN   (* MODULE Initialization *)
   OpLoc := 0;   SrcLoc := 0;   DestLoc := 0;   LineCount := 0; 
END Parser.
----------------------------------------
LISTING FOURTEEN
IMPLEMENTATION MODULE SymbolTable;
(* Initializes symbol table.  Maintains list of all labels, *)
(* along with their values.  Provides access to the list.   *)

   FROM LongNumbers IMPORT
      LONG, LongClear;

   FROM Parser IMPORT
      TOKEN;

   FROM Strings IMPORT
      CompareStr;


   CONST
      MAXSYM = 500;   (* Maximum entries in Symbol Table *)


   TYPE
      SYMBOL = RECORD
                  Name : TOKEN;
                  Value : LONG;
               END;

   VAR
      SymTab : ARRAY [1..MAXSYM] OF SYMBOL;
      Next : CARDINAL;   (* Array index into next entry in Symbol Table *)
      Top : INTEGER;   (* Last used array position as seen by Sort *)



   PROCEDURE FillSymTab (Label : TOKEN; Value : LONG; VAR Full : BOOLEAN);
   (* Add a symbol to the table *)
      BEGIN
         IF Next <= MAXSYM THEN
            SymTab[Next].Name := Label;
            SymTab[Next].Value := Value;
            INC (Next);
            Full := FALSE;
         ELSE
            Full := TRUE;
         END;
      END FillSymTab;



   PROCEDURE SortSymTab (VAR NumSyms : CARDINAL);
   (* Sort symbols into alphabetical order *)

      VAR
         i, j, gap : INTEGER;   (* Shell Sort causes j to go negative *)
         Temp : SYMBOL;

      PROCEDURE Swap;
         BEGIN
            Temp := SymTab[j];
            SymTab[j] := SymTab[j + gap];
            SymTab[j + gap] := Temp;
         END Swap;

      BEGIN   (* Sort *)
         Top := Next - 1;

         gap := (Top + 1) DIV 2;
         WHILE gap > 0 DO
            i := gap;
            WHILE i <= Top DO
               j := i - gap;
               WHILE j >= 1 DO
                  IF CompareStr (SymTab[j].Name, SymTab[j + gap].Name) > 0 THEN
                     Swap;
                  END;
                  j := j - gap;
               END;
               INC (i);
            END;
            gap := gap DIV 2;
         END;

         NumSyms := Top;
      END SortSymTab;



   PROCEDURE ReadSymTab (LABEL : ARRAY OF CHAR; 
                         VAR Value : LONG; VAR Duplicate : BOOLEAN) : BOOLEAN;
   (* Passes Value of Label to calling program -- returns FALSE if the *)
   (* Label is not defined.  Also checks for Multiply Defined Symbols  *)

      CONST
         GoLower = -1;
         GoHigher = +1;

      VAR
         i, j, mid : INTEGER;
         Search : INTEGER;
         Found : BOOLEAN;
         c : CHAR;
         Label : TOKEN;         

      BEGIN
         LongClear (Value);
         Duplicate := FALSE;

         i := 0;
         REPEAT
            c := LABEL[i];
            Label[i] := c;
            INC (i);
         UNTIL (c = 0C) OR (i > 8);

         IF c # 0C THEN   (* Operand label too long --> Undefined *)
            RETURN FALSE;
         END;

         i := 1;
         j := Top;
         Found := FALSE;

         REPEAT   (* Binary search *)
            mid := (i + j) DIV 2;
            Search := CompareStr (Label, SymTab[mid].Name);

            IF Search = GoLower THEN
               j := mid - 1;
            ELSIF Search = GoHigher THEN
               i := mid + 1;
            ELSE   (* Got It! *)
               Found := TRUE;
            END;
         UNTIL (j < i) OR Found;

         IF Found THEN
            IF mid > 1 THEN
               IF CompareStr (SymTab[mid].Name, SymTab[mid - 1].Name) = 0 THEN
                  Duplicate := TRUE;   (* Multiply Defined Symbol *)
               END;
            END;
            IF mid < Top THEN
               IF CompareStr (SymTab[mid].Name, SymTab[mid + 1].Name) = 0 THEN
                  Duplicate := TRUE;   (* Multiply Defined Symbol *)
               END;
            END;

            Value := SymTab[mid].Value;
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END;
      END ReadSymTab;



   PROCEDURE ListSymTab (i : CARDINAL; VAR Label : TOKEN; VAR Value : LONG);
   (* Returns the i-th item in the symbol table *)
      BEGIN
         IF i < Next THEN
            Label := SymTab[i].Name;
            Value := SymTab[i].Value;
         END;
      END ListSymTab;
      


BEGIN   (* MODULE Initialization *)
   FOR Next := 1 TO MAXSYM DO
      SymTab[Next].Name := "";
      LongClear (SymTab[Next].Value);
   END;

   Top := 0;
   Next := 1;
END SymbolTable.
----------------------------------------
LISTING FIFTEEN
IMPLEMENTATION MODULE OperationCodes;
(* Initializes lookup table for Mnemonic OpCodes.  Searches the table *)
(* and returns the bit pattern along with address mode information.   *)

   FROM Files IMPORT
      FILE, FileState, Open, ReadRec, Close;

   FROM Terminal IMPORT
      WriteString, WriteLn;

   FROM Strings IMPORT
      STRING, CompareStr;

   FROM Parser IMPORT
      TOKEN;

   FROM ErrorX68 IMPORT
      ErrorType, Error;


   CONST
      FIRST = 1;       (* First 68000 OpCode *)
      LAST = 118;      (* Last 68000 OpCode *)


(*---
(* These objects are declared in the DEFINITION MODULE *)

   TYPE
      ModeTypeA = (RegMem3,      (* 0 = Register, 1 = Memory *)
                   Ry02,         (* Register Rx -- Bits 0-2 *)
                   Rx911,        (* Register Ry -- Bits 9-11 *)
                   Data911,      (* Immediate Data -- Bits 9-11 *)
                   CntR911,      (* Count Register or Immediate Data *)
                   Brnch,        (* Relative Branch *)
                   DecBr,        (* Decrement and Branch *)
                   Data03,       (* Used for VECT only *)
                   Data07,       (* MOVEQ *)
                   OpM68D,       (* Data *)
                   OpM68A,       (* Address *)
                   OpM68C,       (* Compare *)
                   OpM68X,       (* XOR *)
                   OpM68S,       (* Sign Extension *)
                   OpM68R,       (* Register/Memory *)    
                   OpM37);       (* Exchange Registers *)
                   
      ModeTypeB = (Bit811,       (* BIT operations - bits 8/11 as switch *)
                   Size67,       (* 00 = Byte, 01 = Word, 10 = Long *)
                   Size6,        (* 0 = Word, 1 = Long *)
                   Size1213A,    (* 01 = Byte, 11 = Word, 10 = Long *)
                   Size1213,     (* 11 = Word, 10 = Long *)
                   Exten,        (* OpCode extension required *)
                   EA05a,        (* Effective Address - ALL *)
                   EA05b,        (* Less 1 *)
                   EA05c,        (* Less 1, 11 *)
                   EA05d,        (* Less 9, 10, 11 *)
                   EA05e,        (* Less 1, 9, 10, 11 *)
                   EA05f,        (* Less 0, 1, 3, 4, 11 *)
                   EA05x,        (* Dual mode - OR/AND *)
                   EA05y,        (* Dual mode - ADD/SUB *)
                   EA05z,        (* Dual mode - MOVEM *)
                   EA611);       (* Used only by MOVE *)
                   
      ModeA = SET OF ModeTypeA;
      ModeB = SET OF ModeTypeB;

                                                            ---*)
   TYPE
      TableRecord = RECORD
                       Mnemonic : TOKEN;
                       Op : BITSET;
                       AddrModeA : ModeA;
                       AddrModeB : ModeB;
                    END;


   VAR
      Table68K : ARRAY [FIRST..LAST] OF TableRecord;
      i : CARDINAL;   (* index variable for initializing Table68K *)
      f : FILE;


   PROCEDURE Instructions (MnemonSym : TOKEN; 
                           OpLoc : CARDINAL; VAR Op : BITSET; 
                           VAR AddrModeA : ModeA; VAR AddrModeB : ModeB);
   (* Uses lookup table to find addressing mode & bit pattern of opcode. *)

      CONST
         GoLower = -1;
         GoHigher = +1;

      VAR
         Top, Bottom, Look : CARDINAL;   (* index to Op-code table *)
         Found : BOOLEAN;
         Search : INTEGER;

      BEGIN
         Bottom := FIRST;
         Top := LAST;
         Found := FALSE;
         
         REPEAT   (* Binary Search *)
            Look := (Bottom + Top) DIV 2;
            Search := CompareStr (MnemonSym, Table68K[Look].Mnemonic);
           
            IF Search = GoLower THEN
               Top := Look - 1;
            ELSIF Search = GoHigher THEN
               Bottom := Look + 1;
            ELSE   (* Got It! *)
               Found := TRUE;
            END;
         UNTIL (Top < Bottom) OR Found;

         IF Found THEN
            (* Return the instruction, mode, and address restristictions *)
            Op := Table68K[Look].Op;
            AddrModeA := Table68K[Look].AddrModeA;
            AddrModeB := Table68K[Look].AddrModeB;
         ELSE
            Error (OpLoc, NoCode);
         END;
      END Instructions;


BEGIN   (* MODULE Initialization *)
   IF Open (f, "OPCODE.DAT") # FileOK THEN
      WriteString ("Can't Find 'OPCODE.DAT'.");
      WriteLn;
      HALT;
   END;

   FOR i := FIRST TO LAST DO
      ReadRec (f, Table68K[i]);
   END;

   IF Close (f) # FileOK THEN
      (* Don't worry about it! *)
   END;
END OperationCodes.
----------------------------------------
LISTING SIXTEEN
MODULE InitOperationCodes;
(* Module to construct the file containing the Operation Code Data Table *)

   FROM Files IMPORT
      FILE, FileState, Create, WriteRec, Close;

   FROM Terminal IMPORT
      WriteString, WriteLn;

   FROM Parser IMPORT
      TOKEN;


   CONST
      FIRST = 1;
      LAST = 118;

   TYPE
      ModeTypeA = (RegMem3,      (* 0 = Register, 1 = Memory *)
                   Ry02,         (* Register Rx -- Bits 0-2 *)
                   Rx911,        (* Register Ry -- Bits 9-11 *)
                   Data911,      (* Immediate Data -- Bits 9-11 *)
                   CntR911,      (* Count Register or Immediate Data *)
                   Brnch,        (* Relative Branch *)
                   DecBr,        (* Decrement and Branch *)
                   Data03,       (* Used for VECT only *)
                   Data07,       (* Branch & MOVEQ *)
                   OpM68D,       (* Data *)
                   OpM68A,       (* Address *)
                   OpM68C,       (* Compare *)
                   OpM68X,       (* XOR *)
                   OpM68S,       (* Sign Extension *)
                   OpM68R,       (* Register/Memory *)    
                   OpM37);       (* Exchange Registers *)
                   
      ModeTypeB = (Bit811,       (* BIT operations - bits 8/11 as switch *)
                   Size67,       (* 00 = Byte, 01 = Word, 10 = Long *)
                   Size6,        (* 0 = Word, 1 = Long *)
                   Size1213A,    (* 01 = Byte, 11 = Word, 10 = Long *)
                   Size1213,     (* 11 = Word, 10 = Long *)
                   Exten,        (* OpCode extension required *)
                   EA05a,        (* Effective Address - ALL *)
                   EA05b,        (* Less 1 *)
                   EA05c,        (* Less 1, 11 *)
                   EA05d,        (* Less 9, 10, 11 *)
                   EA05e,        (* Less 1, 9, 10, 11 *)
                   EA05f,        (* Less 0, 1, 3, 4, 11 *)
                   EA05x,        (* Dual mode - OR/AND *)
                   EA05y,        (* Dual mode - ADD/SUB *)
                   EA05z,        (* Dual mode - MOVEM *)
                   EA611);       (* Used only by MOVE *)
                   
      ModeA = SET OF ModeTypeA;
      ModeB = SET OF ModeTypeB;

      TableRecord = RECORD
                       Mnemonic : TOKEN;
                       Op : BITSET;
                       AddrModeA : ModeA;
                       AddrModeB : ModeB;
                    END;


   VAR
      Table68K : ARRAY [FIRST..LAST] OF TableRecord;
      i : CARDINAL;   (* index variable for initializing Table68K *)
      f : FILE;   (* "OPCODE.DAT" *)

   
BEGIN
   i := 1;
   WITH Table68K[i] DO
      Mnemonic := "ABCD";
      Op := {15, 14, 8};
      AddrModeA := ModeA{Rx911, RegMem3, Ry02};
      AddrModeB := ModeB{};
   END;

   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "ADD";
      Op := {15, 14, 12};
      AddrModeA := ModeA{OpM68D};
      AddrModeB := ModeB{EA05y};
   END;

   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "ADDA";
      Op := {15, 14, 12};
      AddrModeA := ModeA{OpM68A};
      AddrModeB := ModeB{EA05a};
   END;

         
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "ADDI";
      Op := {10, 9};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{Size67, EA05e, Exten};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "ADDQ";
      Op := {14, 12};
      AddrModeA := ModeA{Data911};
      AddrModeB := ModeB{Size67, EA05d};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "ADDX";
      Op := {15, 14, 12, 8};
      AddrModeA := ModeA{RegMem3, Rx911, Ry02};
      AddrModeB := ModeB{Size67};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "AND";
      Op := {15, 14};
      AddrModeA := ModeA{OpM68D};
      AddrModeB := ModeB{EA05x};
   END;
   
   INC (i);             
   WITH Table68K[i] DO
      Mnemonic := "ANDI";
      Op := {9};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e, Size67, Exten};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "ASL";
      Op := {15, 14, 13, 8};
      AddrModeA := ModeA{CntR911};
      AddrModeB := ModeB{};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "ASR";
      Op := {15, 14, 13};
      AddrModeA := ModeA{CntR911};
      AddrModeB := ModeB{};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "BCC";
      Op := {14, 13, 10};
      AddrModeA := ModeA{Brnch};
      AddrModeB := ModeB{};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "BCHG";
      Op := {6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e, Exten, Bit811};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "BCLR";
      Op := {7};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e, Exten, Bit811};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "BCS";
      Op := {14, 13, 10, 8};
      AddrModeA := ModeA{Brnch};
      AddrModeB := ModeB{};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "BEQ";
      Op := {14, 13, 10, 9, 8};
      AddrModeA := ModeA{Brnch};
      AddrModeB := ModeB{};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "BGE";
      Op := {14, 13, 11, 10};
      AddrModeA := ModeA{Brnch};
      AddrModeB := ModeB{};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "BGT";
      Op := {14, 13, 11, 10, 9};
      AddrModeA := ModeA{Brnch};
      AddrModeB := ModeB{};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "BHI";
      Op := {14, 13, 9};
      AddrModeA := ModeA{Brnch};
      AddrModeB := ModeB{};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "BLE";
      Op := {14, 13, 11, 10, 9, 8};
      AddrModeA := ModeA{Brnch};
      AddrModeB := ModeB{};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "BLS";
      Op := {14, 13, 9, 8};
      AddrModeA := ModeA{Brnch};
      AddrModeB := ModeB{};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "BLT";
      Op := {14, 13, 11, 10, 8};
      AddrModeA := ModeA{Brnch};
      AddrModeB := ModeB{};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "BMI";
      Op := {14, 13, 11, 9, 8};
      AddrModeA := ModeA{Brnch};
      AddrModeB := ModeB{};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "BNE";
      Op := {14, 13, 10, 9};
      AddrModeA := ModeA{Brnch};
      AddrModeB := ModeB{};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "BPL";
      Op := {14, 13, 11, 9};
      AddrModeA := ModeA{Brnch};
      AddrModeB := ModeB{};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "BRA";
      Op := {14, 13};
      AddrModeA := ModeA{Brnch};
      AddrModeB := ModeB{};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "BSET";
      Op := {7, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e, Exten, Bit811};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "BSR";
      Op := {14, 13, 8};
      AddrModeA := ModeA{Brnch};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "BTST";
      Op := {};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05c, Exten, Bit811};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "BVC";
      Op := {14, 13, 11};
      AddrModeA := ModeA{Brnch};
      AddrModeB := ModeB{};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "BVS";
      Op := {14, 13, 11, 8};
      AddrModeA := ModeA{Brnch};
      AddrModeB := ModeB{};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "CHK";
      Op := {14, 8, 7};
      AddrModeA := ModeA{Rx911};
      AddrModeB := ModeB{EA05b};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "CLR";
      Op := {14, 9};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{Size67, EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "CMP";
      Op := {15, 13, 12};
      AddrModeA := ModeA{OpM68C};
      AddrModeB := ModeB{EA05a};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "CMPA";
      Op := {15, 13, 12};
      AddrModeA := ModeA{OpM68A};
      AddrModeB := ModeB{EA05a};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "CMPI";
      Op := {11, 10};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{Size67, EA05e, Exten};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "CMPM";
      Op := {15, 13, 12, 8, 3};
      AddrModeA := ModeA{Rx911, Ry02};
      AddrModeB := ModeB{Size67};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "DBCC";
      Op := {14, 12, 10, 7, 6, 3};
      AddrModeA := ModeA{DecBr};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "DBCS";
      Op := {14, 12, 10, 8, 7, 6, 3};
      AddrModeA := ModeA{DecBr};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "DBEQ";
      Op := {14, 12, 10, 9, 8, 7, 6, 3};
      AddrModeA := ModeA{DecBr};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "DBF";
      Op := {14, 12, 8, 7, 6, 3};
      AddrModeA := ModeA{DecBr};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "DBGE";
      Op := {14, 12, 11, 10, 7, 6, 3};
      AddrModeA := ModeA{DecBr};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "DBGT";
      Op := {14, 12, 11, 10, 9, 7, 6, 3};
      AddrModeA := ModeA{DecBr};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "DBHI";
      Op := {14, 12, 9, 7, 6, 3};
      AddrModeA := ModeA{DecBr};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "DBLE";
      Op := {14, 12, 11, 10, 9, 8, 7, 6, 3};
      AddrModeA := ModeA{DecBr};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "DBLS";
      Op := {14, 12, 9, 8, 7, 6, 3};
      AddrModeA := ModeA{DecBr};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "DBLT";
      Op := {14, 12, 11, 10, 8, 7, 6, 3};
      AddrModeA := ModeA{DecBr};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "DBMI";
      Op := {14, 12, 11, 9, 8, 7, 6, 3};
      AddrModeA := ModeA{DecBr};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "DBNE";
      Op := {14, 12, 10, 9, 7, 6, 3};
      AddrModeA := ModeA{DecBr};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "DBPL";
      Op := {14, 12, 11, 9, 7, 6, 3};
      AddrModeA := ModeA{DecBr};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "DBRA";
      Op := {14, 12, 8, 7, 6, 3};
      AddrModeA := ModeA{DecBr};
      AddrModeB := ModeB{};
   END;

   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "DBT";
      Op := {14, 12, 7, 6, 3};
      AddrModeA := ModeA{DecBr};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "DBVC";
      Op := {14, 12, 11, 7, 6, 3};
      AddrModeA := ModeA{DecBr};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "DBVS";
      Op := {14, 12, 11, 8, 7, 6, 3};
      AddrModeA := ModeA{DecBr};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "DIVS";
      Op := {15, 8, 7, 6};
      AddrModeA := ModeA{Rx911};
      AddrModeB := ModeB{EA05b};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "DIVU";
      Op := {15, 7, 6};
      AddrModeA := ModeA{Rx911};
      AddrModeB := ModeB{EA05b};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "EOR";
      Op := {15, 13, 12};
      AddrModeA := ModeA{OpM68X};
      AddrModeB := ModeB{EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "EORI";
      Op := {11, 9};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{Size67, EA05e, Exten};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "EXG";
      Op := {15, 14, 8};
      AddrModeA := ModeA{OpM37};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "EXT";
      Op := {14, 11};
      AddrModeA := ModeA{OpM68S};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "ILLEGAL";
      Op := {14, 11, 9, 7, 6, 5, 4, 3, 2};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "JMP";
      Op := {14, 11, 10, 9, 7, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05f};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "JSR";
      Op := {14, 11, 10, 9, 7};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05f};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "LEA";
      Op := {14, 8, 7, 6};
      AddrModeA := ModeA{Rx911};
      AddrModeB := ModeB{EA05f};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "LINK";
      Op := {14, 11, 10, 9, 6, 4};
      AddrModeA := ModeA{Ry02};
      AddrModeB := ModeB{Exten};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "LSL";
      Op := {15, 14, 13, 9, 8, 3};
      AddrModeA := ModeA{CntR911};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "LSR";
      Op := {15, 14, 13, 9, 3};
      AddrModeA := ModeA{CntR911};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "MOVE"; 
      Op := {};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{Size1213A, EA611};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "MOVEA";
      Op := {6};
      AddrModeA := ModeA{Rx911};
      AddrModeB := ModeB{Size1213, EA05a};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "MOVEM";
      Op := {14, 11, 7};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{Size6, EA05z, Exten};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "MOVEP";
      Op := {3};
      AddrModeA := ModeA{OpM68R};
      AddrModeB := ModeB{Exten};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "MOVEQ";
      Op := {14, 13, 12};
      AddrModeA := ModeA{Data07};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "MULS";
      Op := {15, 14, 8, 7, 6};
      AddrModeA := ModeA{Rx911};
      AddrModeB := ModeB{EA05b};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "MULU";
      Op := {15, 14, 7, 6};
      AddrModeA := ModeA{Rx911};
      AddrModeB := ModeB{EA05b};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "NBCD";
      Op := {14, 11};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e};
   END;
   
   INC (i);            
   WITH Table68K[i] DO
      Mnemonic := "NEG";
      Op := {14, 10};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{Size67, EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "NEGX";
      Op := {14};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{Size67, EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "NOP";
      Op := {14, 11, 10, 9, 6, 5, 4, 0};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "NOT";
      Op := {14, 10, 9};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{Size67, EA05e};
   END;
   
   INC (i);            
   WITH Table68K[i] DO
      Mnemonic := "OR";
      Op := {15};
      AddrModeA := ModeA{OpM68D};
      AddrModeB := ModeB{EA05x};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "ORI";
      Op := {};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{Size67, EA05e, Exten};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "PEA";
      Op := {14, 11, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05f};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "RESET";
      Op := {14, 11, 10, 9, 6, 5, 4};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "ROL";
      Op := {15, 14, 13, 10, 9, 8, 4, 3};
      AddrModeA := ModeA{CntR911};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "ROR";
      Op := {15, 14, 13, 10, 9, 4, 3};
      AddrModeA := ModeA{CntR911};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "ROXL";
      Op := {15, 14, 13, 10, 8, 4};
      AddrModeA := ModeA{CntR911};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "ROXR";
      Op := {15, 14, 13, 10, 4};
      AddrModeA := ModeA{CntR911};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "RTE";
      Op := {14, 11, 10, 9, 6, 5, 4, 1, 0};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "RTR";
      Op := {14, 11, 10, 9, 6, 5, 4, 2, 1, 0};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "RTS";
      Op := {14, 11, 10, 9, 6, 5, 4, 2, 0};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SBCD";
      Op := {15, 8};
      AddrModeA := ModeA{Rx911, RegMem3, Ry02};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SCC";
      Op := {14, 12, 10, 7, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SCS";
      Op := {14, 12, 10, 8, 7, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SEQ";
      Op := {14, 12, 10, 9, 8, 7, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SF";
      Op := {14, 12, 8, 7, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SGE";
      Op := {14, 12, 11, 10, 7, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SGT";
      Op := {14, 12, 11, 10, 9, 7, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SHI";
      Op := {14, 12, 9, 7, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SLE";
      Op := {14, 12, 11, 10, 9, 8, 7, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SLS";
      Op := {14, 12, 9, 8, 7, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SLT";
      Op := {14, 12, 11, 10, 8, 7, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SMI";
      Op := {14, 12, 11, 9, 8, 7, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SNE";
      Op := {14, 12, 10, 9, 7, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SPL";
      Op := {14, 12, 11, 9, 7, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "ST";
      Op := {14, 12, 7, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "STOP";
      Op := {14, 11, 10, 9, 6, 5, 4, 1};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{Exten};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SUB";
      Op := {15, 12};
      AddrModeA := ModeA{OpM68D};
      AddrModeB := ModeB{EA05y};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SUBA";
      Op := {15, 12};
      AddrModeA := ModeA{OpM68A};
      AddrModeB := ModeB{EA05a};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SUBI";
      Op := {10};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{Size67, EA05e, Exten};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SUBQ";
      Op := {14, 12, 8};
      AddrModeA := ModeA{Data911};
      AddrModeB := ModeB{Size67, EA05d};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SUBX";
      Op := {15, 12, 8};
      AddrModeA := ModeA{Rx911, RegMem3, Ry02};
      AddrModeB := ModeB{Size67};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SVC";
      Op := {14, 12, 11, 7, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SVS";
      Op := {14, 12, 11, 8, 7, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "SWAP";
      Op := {14, 11, 6};
      AddrModeA := ModeA{Ry02};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "TAS";
      Op := {14, 11, 9, 7, 6};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "TRAP";
      Op := {14, 11, 10, 9, 6};
      AddrModeA := ModeA{Data03};
      AddrModeB := ModeB{};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "TRAPV";
      Op := {14, 11, 10, 9, 6, 5, 4, 2, 1};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{};
   END;
   
   INC (i);
   WITH Table68K[i] DO
      Mnemonic := "TST";
      Op := {14, 11, 9};
      AddrModeA := ModeA{};
      AddrModeB := ModeB{Size67, EA05e};
   END;
   
   INC (i);         
   WITH Table68K[i] DO
      Mnemonic := "UNLK";
      Op := {14, 11, 10, 9, 6, 4, 3};
      AddrModeA := ModeA{Ry02};
      AddrModeB := ModeB{};
   END;

   IF Create (f, "OPCODE.DAT") # FileOK THEN
      WriteString ("Unable to create OpCode File.");
      WriteLn;
      HALT;
   END;

   FOR i := FIRST TO LAST DO
      WriteRec (f, Table68K[i]);
   END;

   IF Close (f) # FileOK THEN
      WriteString ("Unable to close OpCode File.");
      WriteLn;
   END;
END InitOperationCodes.

----------------------------------------
                        




