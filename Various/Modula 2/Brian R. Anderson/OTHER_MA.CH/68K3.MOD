
Listing 17

IMPLEMENTATION MODULE CodeGenerator;
(* Uses information supplied by Parser, OperationCodes, *)
(* and SyntaxAnalyzer to produce the object code.       *)

   FROM Strings IMPORT
      Length, CompareStr;

   FROM SymbolTable IMPORT
      FillSymTab, ReadSymTab;

   FROM Parser IMPORT
      TOKEN, OPERAND, OpLoc, SrcLoc, DestLoc;

   FROM LongNumbers IMPORT
      LONG, LongAdd, LongSub, LongInc, LongDec, 
      LongClear, CardToLong, LongToCard, LongToInt,
      LongCompare, AddrBoundW, AddrBoundL;

   FROM OperationCodes IMPORT
      ModeTypeA, ModeTypeB, ModeA, ModeB, Instructions;

   FROM ErrorX68 IMPORT
      ErrorType, Error;

   FROM SyntaxAnalyzer IMPORT
      OpMode, Xtype, SizeType, OpConfig, Src, Dest, 
      Size, Op, AddrModeA, AddrModeB, InstSize,
      GetValue, GetSize, GetInstModeSize, GetOperand, GetMultReg;


   CONST
      JMP = {14, 11, 10, 9, 7, 6};
      JSR = {14, 11, 10, 9, 7};
      RTE = {14, 11, 10, 9, 6, 5, 4, 1, 0};
      RTR = {14, 11, 10, 9, 6, 5, 4, 2, 1, 0};
      RTS = {14, 11, 10, 9, 6, 5, 4, 2, 0};
      TRAPV = {14, 11, 10, 9, 6, 5, 4, 2, 1};
      STOP = {14, 11, 10, 9, 6, 5, 4, 1};
      LINK = {14, 11, 10, 9, 6, 4};
      SWAP = {14, 11, 6};
      UNLK = {14, 11, 10, 9, 6, 4, 3};
      Quote = 47C;


   VAR
   (*---     
      (* Defined in DEFINITION MODULE *)
      LZero, AddrCnt : LONG;
      Pass2 : BOOLEAN;                 
                                       ---*)
      AddrAdv : LONG;
      TempL : LONG;     (* Temporary variables *)
      TempI : INTEGER;
      TempC : CARDINAL;
      BrValue : LONG;   (* Used to calculate relative branches *)
      RevBr : BOOLEAN;



   PROCEDURE BuildSymTable (VAR AddrCnt : LONG;
                            Label, OpCode : TOKEN; SrcOp, DestOp : OPERAND);
   (* Builds symbol table from symbolic information of Source File *)

      VAR
         Value : LONG;
         Full : BOOLEAN;
         PseudoOp : BOOLEAN;

      BEGIN
         Value := LZero;
         AddrAdv := LZero;
         InstSize := 0;
         PseudoOp := FALSE;
         Size := S0;

         IF Length (OpCode) = 0 THEN
            RETURN;   (* Nothing added to symbol table, AddrCnt not changed *)
         END;

         GetSize (OpCode, Size);
  
         IF CompareStr (OpCode, "ORG") = 0 THEN
            GetValue (SrcOp, AddrCnt);
            AddrBoundW (AddrCnt);
            Value := AddrCnt;
            PseudoOp := TRUE;
         ELSIF CompareStr (OpCode, "EQU") = 0 THEN
            GetValue (SrcOp, Value);
            PseudoOp := TRUE;
         ELSIF CompareStr (OpCode, "DC") = 0 THEN
            CASE Size OF
               Word  :  AddrBoundW (AddrCnt);
            |  Long  :  AddrBoundL (AddrCnt);
            |  Byte  :  ;
            END;

            IF SrcOp[0] = Quote THEN   (* String Constant *)
               TempC := Length (SrcOp);
               IF TempC > 2 THEN
                  InstSize := TempC - 2;
               END;
            ELSE
               InstSize := ORD (Size);
            END;    
            CardToLong (InstSize, AddrAdv);
            Value := AddrCnt;
            PseudoOp := TRUE;
         ELSIF CompareStr (OpCode, "DS") = 0 THEN
            GetValue (SrcOp, AddrAdv);
            Value := AddrCnt;
            PseudoOp := TRUE;
         ELSIF CompareStr (OpCode, "EVEN") = 0 THEN
            AddrBoundW (AddrCnt);
            Value := AddrCnt;
            PseudoOp := TRUE;
         ELSIF CompareStr (OpCode, "END") = 0 THEN
            PseudoOp := TRUE;
         ELSE
            Value := AddrCnt;
         END;

         IF Length (Label) # 0 THEN
            FillSymTab (Label, Value, Full);
            IF Full THEN
               Error (0, SymFull);
            END;
         END;

         IF NOT PseudoOp THEN
            Instructions (OpCode, OpLoc, Op, AddrModeA, AddrModeB);       

            AddrBoundW (AddrCnt);
            Src.Loc := SrcLoc;   Dest.Loc := DestLoc;
            GetOperand (SrcOp, Src);
            GetOperand (DestOp, Dest);
            InstSize := 2;   (* minimum size of instruction *)

            IF Brnch IN AddrModeA THEN
               IF Size # Byte THEN
                  INC (InstSize, 2);
               END;
            ELSIF DecBr IN AddrModeA THEN
               INC (InstSize, 2);
            ELSE   
               IF (Op = JMP) OR (Op = JSR) THEN   (* Allows for 'JMP.S' *)
                  IF (Size = Byte) AND (Src.Mode = AbsL) THEN
                     Src.Mode := AbsW;
                  END;
               END;

               TempC := GetInstModeSize (Src.Mode, Size, InstSize);
               TempC := GetInstModeSize (Dest.Mode, Size, InstSize);
            END;

            IF (Src.Mode = Imm) AND 
             ((Data911 IN AddrModeA) OR (Data03 IN AddrModeA) OR
              (Data07 IN AddrModeA) OR (CntR911 IN AddrModeA)) THEN
               (* Quick instruction *)
               InstSize := 2;
            END;
            CardToLong (InstSize, AddrAdv);   
         END;
      END BuildSymTable;



   PROCEDURE MergeModes (VAR SrcOp, DestOp : OPERAND;
                         VAR ObjOp, ObjSrc, ObjDest : LONG;
                         VAR nO,    nS,     nD      : CARDINAL);
   (*  Uses information from Instructions & GetOperand (among others)  *)
   (*  to complete calculation of Object Code.                         *)
   (*  Op, AddrModeA, AddrModeB, Size, and Src & Dest records are all  *)
   (*  Global variables imported from the SyntaxAnalyzer MODULE.       *)

      CONST
         (* BITSETs of the modes MISSING from effective address modes  *)
          ea = {};                 (* Effective addressing - all modes *)
         dea = {1};                (* Data effective addressing        *)
         mea = {1, 0};             (* Memory effective addressing      *)
         cea = {11, 4, 3, 1, 0};   (* Control effective addressing     *)
         aea = {11, 10, 9};        (* Alterable effective addressing   *)
         xxx = {15, 14, 13};       (* extra modes: CCR/SR/USP          *)
         (* 2 "AND" masks to turn off switch bits for shift/rotate *)
         Off910 = {15, 14, 13, 12, 11, 8, 7, 6, 5, 4, 3, 2, 1, 0};
         Off34 = {15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 2, 1, 0};

      VAR
         M : CARDINAL;
         i : CARDINAL;
         Ext : BITSET;      (* Bit pattern for instruction extension word *)
         ExtL : LONG;
         Xext : BITSET;
         Quick : BOOLEAN;


      PROCEDURE OperExt (VAR EA : OpConfig);
      (* Calculate Operand Extension word, and check range of Operands *)

         VAR
            GoodCard, GoodInt : BOOLEAN;

         BEGIN
            GoodCard := LongToCard (EA.Value, TempC);
            GoodInt := LongToInt (EA.Value, TempI);

            CASE EA.Mode OF
               AbsL     :  ;   (* No range checking needed *)
            |  AbsW     :  IF NOT GoodCard THEN
                              Error (EA.Loc, SizeErr);
                           END;
            |  ARDisp,  
               PCDisp   :  IF NOT GoodInt THEN
                              Error (EA.Loc, SizeErr);
                           END;
            |  ARDisX,
               PCDisX   :  IF (TempI < -128) OR (TempI > 127) THEN
                              Error (EA.Loc, SizeErr);
                           END;
                           Xext := BITSET (EA.Xn * 4096);
                           IF EA.X = Areg THEN
                              Xext := Xext + {15};
                           END;
                           IF EA.Xsize = Long THEN
                              Xext := Xext + {11};
                           END;
                           CardToLong (CARDINAL (Xext), TempL);
                           EA.Value[3] := TempL[3];
                           EA.Value[4] := TempL[4];
            |  Imm      :  IF Size = Long THEN
                              (* No range check needed *)
                           ELSE
                              IF GoodInt THEN
                                 IF Size = Byte THEN
                                    IF (TempI < -128) OR (TempI > 127) THEN
                                       Error (EA.Loc, SizeErr);
                                    END;
                                 END;
                              ELSE
                                 Error (EA.Loc, SizeErr);
                              END;
                           END;
            ELSE
               (* No Action *)
            END;
         END OperExt;

      PROCEDURE EffAdr (VAR EA : OpConfig; Bad : BITSET);
      (* adds effective address field to Op (BITSET representing opcode) *)

         VAR
            M : CARDINAL;
            i : CARDINAL;
            Xext : BITSET;

         BEGIN
            M := ORD (EA.Mode);

            IF M IN Bad THEN
               Error (EA.Loc, ModeErr);
               RETURN;
            ELSIF M > 11 THEN
               RETURN;
            ELSIF M < 7 THEN
               Op := Op + BITSET (M * 8) + BITSET (EA.Rn);
            ELSE   (*    7  <=  M  <=  11   *)
               Op := Op + {5, 4, 3} + BITSET (M - 7);
            END;

            OperExt (EA);
         END EffAdr;

      BEGIN   (* MergeModes *)
         ExtL := LZero;
         Quick := FALSE;

         (* Check for 5 special cases first *)

         IF (Op = RTE) OR (Op = RTR) OR (Op = RTS) OR (Op = TRAPV) THEN
            IF Src.Mode # Null THEN
               Error (SrcLoc, OperErr);
            END;
         END;

         IF Op = STOP THEN
            IF (Src.Mode # Imm) OR (Dest.Mode # Null) THEN
               Error (SrcLoc, OperErr);
            END;
         END;

         IF Op = LINK THEN
            Op := Op + BITSET (Src.Rn);
            IF (Src.Mode # ARDir) OR (Dest.Mode # Imm) THEN
               Error (SrcLoc, ModeErr);
            END;
         END;

         IF Op = SWAP THEN
            IF EA05f IN AddrModeB THEN
               (* Ignore, this is PEA instruction! *)
            ELSE
               Op := Op + BITSET (Src.Rn);
               IF (Src.Mode # DReg) OR (Dest.Mode # Null) THEN
                  Error (SrcLoc, OperErr);
               END;
            END;
         END;

         IF Op = UNLK THEN
            Op := Op + BITSET (Src.Rn);
            IF (Src.Mode # ARDir) OR (Dest.Mode # Null) THEN
               Error (SrcLoc, OperErr);
            END;
         END;

         (* Now do generalized address modes *)

         IF (Ry02 IN AddrModeA) AND (Rx911 IN AddrModeA) THEN
            Op := Op + BITSET (Src.Rn) + BITSET (Dest.Rn * 512);
            (* Now do some error checking! *)
            IF RegMem3 IN AddrModeA THEN
               IF Src.Mode = DReg THEN
                  IF Dest.Mode # DReg THEN
                     Error (DestLoc, ModeErr);
                  END;
               ELSIF Src.Mode = ARPre THEN
                  Op := Op + {3};
                  IF Dest.Mode # ARPre THEN
                     Error (DestLoc, ModeErr);
                  END;
               ELSE
                  Error (SrcLoc, OperErr);
               END;
            ELSE
               IF Src.Mode = ARPost THEN
                  IF Dest.Mode # ARPost THEN
                     Error (DestLoc, ModeErr);
                  END;
               ELSE
                  Error (SrcLoc, OperErr);
               END;
            END;
         END;

         IF Data911 IN AddrModeA THEN
            Quick := TRUE;
            IF Src.Mode = Imm THEN
               IF LongToInt (Src.Value, TempI) 
                AND (TempI > 0)
                 AND (TempI <= 8) THEN
                  IF TempI < 8 THEN   (* Data of 8 is coded as 000 *)
                     Op := Op + BITSET (TempI * 512);
                  END;
               ELSE
                  Error (SrcLoc, SizeErr);
               END;
            ELSE
               Error (SrcLoc, OperErr);
            END;
         END;

         IF CntR911 IN AddrModeA THEN
            (* Only Shift/Rotate use this *)
            IF Dest.Mode = DReg THEN
               Op := (Op * Off910) + BITSET (Dest.Rn);
               CASE Size OF
                  Byte : ;
               |  Word : Op := Op + {6};
               |  Long : Op := Op + {7};
               END;
               IF Src.Mode = DReg THEN
                  Op := Op + {5} + BITSET (Src.Rn * 512);               
               ELSIF Src.Mode = Imm THEN
                  Quick := TRUE; 
                  (* Range Check *)
                  IF LongToInt (Src.Value, TempI) 
                   AND (TempI > 0)
                    AND (TempI <= 8) THEN
                     IF TempI < 8 THEN   (* Data of 8 is coded as 000 *)
                        Op := Op + BITSET (TempI * 512);
                     END;
                  ELSE
                     Error (SrcLoc, SizeErr);
                  END;
               ELSE
                  Error (SrcLoc, OperErr);
               END;                    
            ELSIF Dest.Mode = Null THEN
               Op := (Op * Off34) + {7, 6};
               EffAdr (Src, (mea + aea));
            ELSE
               Error (SrcLoc, OperErr);
            END;
         END;

         IF Data03 IN AddrModeA THEN
            Quick := TRUE;
            IF Src.Mode = Imm THEN
               IF LongToInt (Src.Value, TempI)
                AND (TempI >= 0)
                 AND (TempI < 16) THEN
                  Op := Op + BITSET (TempI);
               ELSE
                  Error (SrcLoc, SizeErr);
               END;
            ELSE
               Error (SrcLoc, OperErr);
            END;
         END;

         IF Data07 IN AddrModeA THEN
            Quick := TRUE;
            IF (Src.Mode = Imm) AND (Dest.Mode = DReg) THEN
               IF LongToInt (Src.Value, TempI) 
                AND (TempI >= -128) 
                 AND (TempI <= 127) THEN
                  Op := Op + (BITSET (TempI) * {7, 6, 5, 4, 3, 2, 1, 0}) 
                           + BITSET (Dest.Rn * 512);
               ELSE
                  Error (SrcLoc, SizeErr);
               END;
            ELSE
               Error (SrcLoc, OperErr);
            END;
         END;

         IF OpM68D IN AddrModeA THEN
            IF Dest.Mode = DReg THEN
               Op := Op + BITSET (Dest.Rn * 512);
               IF (Src.Mode = ARDir) AND (Size = Byte) THEN
                  Error (SrcLoc, SizeErr);
               END;
            ELSE   (* Assume Src.Mode = DReg -- Error trapped elsewhere *)
               Op := Op + BITSET (Src.Rn * 512);
               Op := Op + {8};
            END;

            CASE Size OF
               Byte : ;
            |  Word : Op := Op + {6};
            |  Long : Op := Op + {7};
            END;
         END;

         IF OpM68A IN AddrModeA THEN
            IF Dest.Mode = ARDir THEN
               Op := Op + BITSET (Dest.Rn * 512);
            ELSE
               Error (DestLoc, ModeErr);
            END;

            CASE Size OF
               Byte : Error (OpLoc, SizeErr);
            |  Word : Op := Op + {7, 6};
            |  Long : Op := Op + {8, 7, 6};
            END;
         END;

         IF OpM68C IN AddrModeA THEN
            IF Dest.Mode = DReg THEN
               Op := Op + BITSET (Dest.Rn * 512);
            ELSE
               Error (DestLoc, ModeErr);
            END;
            
            CASE Size OF
               Byte : IF Src.Mode = ARDir THEN
                         Error (OpLoc, SizeErr);
                      END;
            |  Word : Op := Op + {6};
            |  Long : Op := Op + {7};
            END;
         END;

         IF OpM68X IN AddrModeA THEN
            IF Src.Mode = DReg THEN
               Op := Op + BITSET (Src.Rn * 512);
            ELSE
               Error (SrcLoc, ModeErr);
            END;

            CASE Size OF
               Byte : Op := Op + {8};
            |  Word : Op := Op + {8, 6};
            |  Long : Op := Op + {8, 7};
            END;
         END;

         IF OpM68S IN AddrModeA THEN
            IF Src.Mode = DReg THEN
               Op := Op + BITSET (Src.Rn);
            ELSE
               Error (SrcLoc, ModeErr);
            END;

            CASE Size OF
               Byte : Error (OpLoc, SizeErr);
            |  Word : Op := Op + {7};
            |  Long :   Op := Op + {7, 6};
            END;
         END;

         IF OpM68R IN AddrModeA THEN
            IF (Src.Mode = DReg) AND (Dest.Mode = ARDisp) THEN
               CASE Size OF
                  Byte : Error (OpLoc, SizeErr);
               |  Word : Op := Op + {8, 7};
               |  Long : Op := Op + {8, 7, 6};
               END;
               Op := Op + BITSET (Src.Rn * 512) + BITSET (Dest.Rn);
            ELSIF (Src.Mode = ARDisp) AND (Dest.Mode = DReg) THEN
               CASE Size OF
                  Byte : Error (OpLoc, SizeErr);
               |  Word : Op := Op + {8};
               |  Long : Op := Op + {8, 6};
               END;
               Op := Op + BITSET (Src.Rn) + BITSET (Dest.Rn * 512);
            ELSE
               Error (SrcLoc, ModeErr);
            END;
         END;

         IF OpM37 IN AddrModeA THEN
            IF (Src.Mode = DReg) AND (Dest.Mode = DReg) THEN
               Op := Op + {6} + BITSET (Src.Rn * 512) + BITSET (Dest.Rn);
            ELSIF (Src.Mode = ARDir) AND (Dest.Mode = ARDir) THEN
               Op := Op + {6, 3} + BITSET (Src.Rn * 512) + BITSET (Dest.Rn);
            ELSIF (Src.Mode = ARDir) AND (Dest.Mode = DReg) THEN
               Op := Op + {7, 3} + BITSET (Dest.Rn * 512) + BITSET (Src.Rn);
            ELSIF (Src.Mode = DReg) AND (Dest.Mode = ARDir) THEN
               Op := Op + {7, 3} + BITSET (Src.Rn * 512) + BITSET (Dest.Rn);
            ELSE
               Error (SrcLoc, ModeErr);
            END;
         END;

         IF Bit811 IN AddrModeB THEN
            IF Src.Mode = DReg THEN
               Op := Op + {8} + BITSET (Src.Rn * 512);
            ELSIF Src.Mode = Imm THEN
               Op := Op + {11};
            ELSE
               Error (SrcLoc, ModeErr);
            END;
         END;

         IF Size67 IN AddrModeB THEN
            CASE Size OF
               Byte : ;(* No action -- bits already 0's *)
            |  Word : Op := Op + {6};
            |  Long : Op := Op + {7};
            END;
         END;

         IF Size6 IN AddrModeB THEN
            CASE Size OF
               Byte : Error (OpLoc, SizeErr);
            |  Word : (* No Action -- BIT is already 0 *)
            |  Long : Op := Op + {6};
            END;
         END;

         IF Size1213A IN AddrModeB THEN
            CASE Size OF
               Byte : Op := Op + {12};
            |  Word : Op := Op + {13, 12};
            |  Long : Op := Op + {13};
            END;
         END;

         IF Size1213 IN AddrModeB THEN
            Op := Op + BITSET (Dest.Rn * 512);
            CASE Size OF
               Byte : Error (OpLoc, SizeErr);
            |  Word : Op := Op + {13, 12};
            |  Long : Op := Op + {13};
            END;
         END;

         IF EA05a IN AddrModeB THEN
            IF (Dest.Mode = DReg) OR (Dest.Mode = ARDir) THEN
               EffAdr (Src, ea);
            ELSE
               Error (DestLoc, ModeErr);
            END;
         END;

         IF EA05b IN AddrModeB THEN
            IF Dest.Mode = DReg THEN
               EffAdr (Src, dea);
               Op := Op + BITSET (Dest.Rn * 512);
            ELSE
               Err (DestLoc, ModddeErr);
            END;
         END;

         IF EA05c IN AddrModeB THEN
            EffAdr (Dest, {11, 1});
         END;

         IF EA05d IN AddrModeB THEN
            EffAdr (Dest, aea);
            IF (Dest.Mode = ARDir) AND (Size = Byte) THEN
               Error (OpLoc, SizeErr);
            END;
         END;

         IF EA05e IN AddrModeB THEN
            IF Dest.Mode = Null THEN
               EffAdr (Src, (dea + aea));
            ELSIF (Src.Mode = Imm) OR (Src.Mode = DReg) THEN
               EffAdr (Dest, (dea + aea));
            ELSE
               Error (SrcLoc, ModeErr);
            END;
         END;

         IF EA05f IN AddrModeB THEN   (* LEA & PEA / JMP & JSR *)
            EffAdr (Src, cea);
            IF Rx911 IN AddrModeA THEN
               IF Dest.Mode = ARDir THEN
                  Op := Op + BITSET (Dest.Rn * 512);
               ELSE
                  Error (DestLoc, ModeErr);
               END;
            ELSE
               IF Dest.Mode # Null THEN
                  Error (DestLoc, OperErr);
               END;
            END;
         END;

         IF EA05x IN AddrModeB THEN
            IF Dest.Mode = DReg THEN
               EffAdr (Src, dea);
            ELSIF Src.Mode = DReg THEN
               EffAdr (Dest, mea + aea);               
            ELSE
               Error (SrcLoc, OperErr);
            END;
         END;

         IF EA05y IN AddrModeB THEN
            IF Dest.Mode = DReg THEN
               EffAdr (Src, ea);
               IF (Src.Mode = ARDir) AND (Size = Byte) THEN
                  Error (OpLoc, SizeErr);
               END;
            ELSIF Src.Mode = DReg THEN
               EffAdr (Dest, (mea + aea));               
            ELSE
               Error (SrcLoc, ModeErr);
            END;
         END;

         IF EA05z IN AddrModeB THEN
            IF Src.Mode = MultiM THEN
               EffAdr (Dest, (mea + aea + {3}));
               GetMultReg (SrcOp, (Dest.Mode = ARPre), SrcLoc, Ext);
            ELSIF Dest.Mode = MultiM THEN
               EffAdr (Src, (mea + {11, 4}));
               GetMultReg (DestOp, (Src.Mode = ARPre), DestLoc, Ext);
               Op := Op + {10};   (* set direction *)
            ELSE
               Error (SrcLoc, OperErr);
            END;

            INC (nO, 4);   (* extension is part of OpCode *)
            INC (InstSize, 2);
            CardToLong (CARDINAL (Ext), ExtL);
         END;

         IF EA611 IN AddrModeB THEN
            IF Dest.Mode = CCR THEN
               Op := {14, 10, 7, 6};
               EffAdr (Src, dea);               
            ELSIF Dest.Mode = SR THEN
               Op := {14, 10, 9, 7, 6};
               EffAdr (Src, dea);               
            ELSIF Src.Mode = SR THEN
               Op := {14, 7, 6};
               EffAdr (Dest, dea + aea);               
            ELSIF Dest.Mode = USP THEN
               Op := {14, 11, 10, 9, 6, 5};
               IF Src.Mode = ARDir THEN
                  Op := Op + BITSET (Src.Rn);
               ELSE
                  Error (SrcLoc, ModeErr);
               END;
            ELSIF Src.Mode = USP THEN
               Op := {14, 11, 10, 9, 6, 5, 3};
               IF Dest.Mode = ARDir THEN
                  Op := Op + BITSET (Dest.Rn);
               ELSE
                  Error (DestLoc, ModeErr);
               END;
            ELSE
               EffAdr (Src, (ea + xxx));
               IF (Size = Byte) AND (Src.Mode = ARDir) THEN
                  Error (SrcLoc, SizeErr);
               END;

               M := ORD (Dest.Mode);
               IF (M IN (dea + aea)) OR (M > 11) THEN
                  Error (DestLoc, ModeErr);
               ELSIF M < 7 THEN
                  Op := Op + BITSET (M * 64) + BITSET (Dest.Rn * 512);
               ELSE   (*  7  <=  M  <=  11  *)
                  Op := Op + {8, 7, 6} + BITSET ((M - 7) * 512);
               END;

               OperExt (Dest);
            END;
         END;

         IF (Dest.Mode = CCR) AND (Src.Mode = Imm) THEN
            IF (Size67 IN AddrModeB) 
             AND (EA05e IN AddrModeB) 
              AND (Exten IN AddrModeB) THEN
               IF 10 IN Op THEN   (* NOT ANDI/EORI/ORI *)
                  Error (DestLoc, ModeErr);
               ELSE
                  Op := Op * {15, 14, 13, 12, 11, 10, 9, 8};   (* AND mask *)
                  Op := Op + {5, 4, 3, 2};                     (*  OR mask *)
               END;
            END;
         END;

         IF (Dest.Mode = SR) AND (Src.Mode = Imm) THEN
            IF (Size67 IN AddrModeB) 
             AND (EA05e IN AddrModeB) 
              AND (Exten IN AddrModeB) THEN
               IF 10 IN Op THEN   (* NOT ANDI/EORI/ORI *)
                  Error (DestLoc, ModeErr);
               ELSE
                  Op := Op * {15, 14, 13, 12, 11, 10, 9, 8};   (* AND mask *)
                  Op := Op + {6, 5, 4, 3, 2};                  (*  OR mask *)
               END;
            END;
         END;

         CardToLong (CARDINAL (Op), ObjOp);
         INC (InstSize, 2);
         INC (nO, 4);
         IF nO > 4 THEN
            FOR i := 1 TO 4 DO   (* move ObjOp -- make room for extension *)
               ObjOp[i + 4] := ObjOp[i];
               ObjOp[i] := ExtL[i];
            END;
         END;

         nS := GetInstModeSize (Src.Mode, Size, InstSize);
         ObjSrc := Src.Value;
         nD := GetInstModeSize (Dest.Mode, Size, InstSize);
         ObjDest := Dest.Value;

         IF Quick THEN
            InstSize := 2;
            nS := 0;   nD := 0;
         END;
         CardToLong (InstSize, AddrAdv);
   
      END MergeModes;



   TYPE
      DirType = (None, Org, Equ, DC, DS, Even, End);

   PROCEDURE ObjDir (OpCode : TOKEN; SrcOp : OPERAND; Size : SizeType;
                     VAR AddrCnt, ObjOp, ObjSrc, ObjDest : LONG;
                     VAR   nA,      nO,    nS,     nD    : CARDINAL) : DirType;
   (* Generates Object Code for Assembler Directives *)

      VAR
         Dir : DirType;
         i, j : CARDINAL;
         LongString : ARRAY [1..20] OF INTEGER;

      BEGIN
         AddrAdv := LZero;

         IF CompareStr (OpCode, "ORG") = 0 THEN
            GetValue (SrcOp, AddrCnt);
            AddrBoundW (AddrCnt);
            Dir := Org;
         ELSIF CompareStr (OpCode, "EQU") = 0 THEN
            GetValue (SrcOp, ObjSrc);
            nS := 8;
            Dir := Equ;
         ELSIF CompareStr (OpCode, "DC") = 0 THEN
            CASE Size OF
               Word  :  AddrBoundW (AddrCnt);
            |  Long  :  AddrBoundL (AddrCnt);
            |  Byte  :  ;
            END;
            
            IF SrcOp[0] = Quote THEN   (* String constant *)
               TempC := Length (SrcOp);
               IF TempC > 2 THEN
                  InstSize := TempC - 2;   (* Don't count the Quotes *)
               END;
                  
               i := 1;   j := 20;
               WHILE i <= InstSize DO   (* Change from ASCII to LONG *)
                  CardToLong (ORD (SrcOp[i]), TempL);
                  LongString[j] := TempL[2];
                  LongString[j - 1] := TempL[1];
                  INC (i);   DEC (j, 2);
               END;

               i := 1;   INC (j);
               WHILE j <= 20 DO   (* Left Justify String *)
                  LongString[i] := LongString[j];
                  INC (i);   INC (j);
               END;

               DEC (i);
               WHILE i > 16 DO   (* Transfer 2 bytes to OpCode *)
                  ObjOp[i - 16] := LongString[i];
                  INC (nO);   DEC (i);
               END;

               WHILE i > 8 DO   (* Transfer 4 bytes to Source Operand *)
                  ObjSrc[i - 8] := LongString[i];
                  INC (nS);   DEC (i);
               END;
                                             
               WHILE i > 0 DO   (* Transfer 4 bytes to Destination Operand *)
                  ObjDest[i] := LongString[i];
                  INC (nD);   DEC (i);
               END;

               IF SrcOp[InstSize + 1] # Quote THEN
                  Error ((SrcLoc + InstSize + 1), OperErr);
               END;
            ELSE   (* not a string constant *)
               GetValue (SrcOp, ObjSrc);
               InstSize := ORD (Size);
               nS := InstSize * 2;
            END;
            CardToLong (InstSize, AddrAdv);
            nA := 6;
            Dir := DC;
         ELSIF CompareStr (OpCode, "DS") = 0 THEN
            GetValue (SrcOp, AddrAdv);
            nA := 6;   nS := 2;   ObjSrc := LZero;
            Dir := DS;
         ELSIF CompareStr (OpCode, "EVEN") = 0 THEN
            AddrBoundW (AddrCnt);
            Dir := Even;
         ELSIF CompareStr (OpCode, "END") = 0 THEN
            nA := 6;
            Dir := End;
         ELSE
            Dir := None;
         END;

         RETURN (Dir);
      END ObjDir;



   PROCEDURE AdvAddrCnt (VAR AddrCnt : LONG);
   (* Advances the address counter based on the length of the instruction *)
      BEGIN
         LongAdd (AddrCnt, AddrAdv, AddrCnt);
      END AdvAddrCnt;



   PROCEDURE GetObjectCode (Label, OpCode : TOKEN;
                            SrcOp, DestOp : OPERAND;
                            VAR AddrCnt, ObjOp, ObjSrc, ObjDest : LONG;
                            VAR   nA,      nO,    nS,     nD    : CARDINAL);
   (* Determines the object code for the operation as well as the operands *)
   (* Returns each (up to 3 fields), along with the length of each.        *) 

      VAR
         Dummy : BOOLEAN;
         Dir : DirType;

      BEGIN
         AddrAdv := LZero;
         InstSize := 0;
         nA := 0;   nO := 0;   nS := 0;   nD := 0;

         IF Length (OpCode) = 0 THEN
            (* ensure no code generated *)
            RETURN;
         END;
         
         GetSize (OpCode, Size);

         Dir := ObjDir (OpCode, SrcOp, Size,
                        AddrCnt, ObjOp, ObjSrc, ObjDest,
                          nA,      nO,    nS,     nD    );

         IF (Length (Label) # 0) AND (Dir # Equ) THEN
         (* Check for phase error *)
            Dummy := ReadSymTab (Label, TempL, Dummy);
            IF LongCompare (TempL, AddrCnt) # 0 THEN
               Error (0, Phase);
            END;
         END;

         IF Dir = None THEN   (* Instruction *)
            AddrBoundW (AddrCnt);   
         ELSE
            RETURN;
         END;

         Instructions (OpCode, OpLoc, O AddrModeA, AddddrModeB);       
         Src.Loc := SrcLoc;   Dest.Loc := DestLoc;  
         GetOperand (SrcOp, Src);   (* Src & Dest are RECORDS *)
         GetOperand (DestOp, Dest);

         IF DecBr IN AddrModeA THEN   (* Decrement & Branch *)
            IF Src.Mode # DReg THEN
               Error (SrcLoc, ModeErr);
            END;

            BrValue := Dest.Value;
            TempL := AddrCnt;
            TempC := 32767;   (* Maximum Branch *)
            LongInc (TempL, 2);   (* move past instruction for Rel Adr Calc *)

            IF LongCompare (BrValue, TempL) < 0 THEN
               RevBr := TRUE;
               LongSub (TempL, BrValue, BrValue);
               INC (TempC);   (* can branch 1 farther in reverse *)
            ELSE
               RevBr := FALSE;
               LongSub (BrValue, TempL, BrValue);
            END;

            CardToLong (TempC, TempL);   (* Maximum Branch distance *)

            IF LongCompare (BrValue, TempL) > 0 THEN
               Error (DestLoc, BraErr);
            END;
            IF RevBr THEN   (* Make Negative *)
               LongSub (LZero, BrValue, BrValue)
            END;

            CardToLong (4, AddrAdv);
            nA := 6;   nO := 4;   nS := 4;  
            CardToLong (CARDINAL (Op + BITSET (Src.Rn)), ObjOp);
            ObjSrc := BrValue;
            RETURN;
         END;

         IF Brnch IN AddrModeA THEN   (* Branch *)
            BrValue := Src.Value;   (* Destination of Branch *)
            TempL := AddrCnt;
            LongInc (TempL, 2);

            IF Size # Byte THEN   (* Byte Size ---> Short Branch *)
               TempC := 32767;   (* Set maximum branch distance *)
            ELSE                  
               TempC := 127;
            END;

            CASE LongCompare (BrValue, TempL) OF
               -1 :  (* Reverse Branch *)
                     RevBr := TRUE;
                     INC (TempC);   (* can branch 1 farther in reverse *)
                     LongSub (TempL, BrValue, BrValue);
            |  +1 :  (* Forward Branch *)
                     RevBr := FALSE;
                     LongSub (BrValue, TempL, BrValue);
            |   0 :  IF Size = Byte THEN
                        Error (SrcLoc, BraErr);
                     END;
            END;
         
            CardToLong (TempC, TempL);

            IF LongCompare (BrValue, TempL) > 0 THEN
               Error (SrcLoc, BraErr);
            END;

            IF RevBr THEN
               LongSub (LZero, BrValue, BrValue);   (* Make negative *)
            END;

            IF Size # Byte THEN
               InstSize := 4;
               nS := 4;
               ObjSrc := BrValue; 
            ELSE
               InstSize := 2;
               Dummy := LongToInt (BrValue, TempI);
               Op := Op + (BITSET (TempI) * {7, 6, 5, 4, 3, 2, 1, 0});
            END;

            nA := 6;   nO := 4;
            CardToLong (InstSize, AddrAdv);
            CardToLong (CARDINAL (Op), ObjOp);
            RETURN;
         END;

         nA := 6;
         IF (Op = JMP) OR (Op = JSR) THEN   (* Allows for 'JMP.S' *)
            IF (Size = Byte) AND (Src.Mode = AbsL) THEN
               Src.Mode := AbsW;
            END;
         END;
         MergeModes (SrcOp, DestOp, ObjOp, ObjSrc, ObjDest, nO, nS, nD);

      END GetObjectCode;


BEGIN   (* MODULE Initialization *)
   LongClear (LZero);   (* Used as a constant *)
   AddrCnt := LZero;
   Pass2 := FALSE;
END CodeGenerator.


****

Listing 18

IMPLEMENTATION MODULE SyntaxAnalyzer;
(* Analyzes the operands to provide information for CodeGenerator *)

   FROM Conversions IMPORT
      StrToCard;

   FROM Strings IMPORT
      Length;
      
   FROM LongNumbers IMPORT
      LONG, LongAdd, LongSub, CardToLong, StringToLong;

   FROM SymbolTable IMPORT
      SortSymTab, ReadSymTab;
   
   FROM ErrorX68 IMPORT
      ErrorType, Error;

   FROM Parser IMPORT
      OPERAND, SrcLoc;

   FROM CodeGenerator IMPORT
      LZero, AddrCnt, Pass2;   (* BOOLEAN Switch *)


   CONST
      Zero = 30H;   (* The Ordinal value of the Character '0' *)
      Seven = 37H;   (* The Ordinal value of the Character '7' *)
      Quote = 47C;

(*---
   TYPE
      OpMode = (DReg,      (* Data Register *)
                ARDir,     (* Address Register Direct *)
                ARInd,     (* Address Register Indirect *)
                ARPost,    (* Address Register with Post-Increment *)
                ARPre,     (* Address Register with Pre-Decrement *)
                ARDisp,    (* Address Register with Displacement *)
                ARDisX,    (* Address Register with Disp. & Index *)
                AbsW,      (* Absolute Word (16-bit Address) *)
                AbsL,      (* Absolute Word (32-bit Address) *)
                PCDisp,    (* Program Counter Relative, with Displacement *)
                PCDisX,    (* Program Counter Relative, with Disp. & Index *)
                Imm,       (* Immediate *)
                MultiM,    (* Multiple Register Move *)
                SR,        (* Status Register *)
                CCR,       (* Condition Code Register *)
                USP,       (* User's Stack Pointer *)
                Null);     (* Error Condition, or Operand missing *)

      Xtype = (X0, Dreg, Areg);
      SizeType = (S0, Byte, Word, S3, Long);

      OpConfig = RECORD                 (* OPERAND CONFIGURATION *)
                    Mode : OpMode;
                    Value : LONG;
                    Loc : CARDINAL;     (* Location of Operand on line *)
                    Rn : CARDINAL;      (* Register number *)
                    Xn : CARDINAL;      (* Index Reg. nbr. *)
                    Xsize : SizeType;   (* size of Index *)
                    X : Xtype;          (* Is index Data or Address reg? *)
                 END;


   VAR
      Size : SizeType;       (* size for OpCode *)  
      AbsSize : SizeType;    (* size of operand (Absolute only) *)
      InstSize : CARDINAL;   (* Size of instruction, including operands *)
      AddrModeA : ModeA;     (* Addressing modes for this instruction *)
      AddrModeB : ModeB;     (*               ditto                   *)
      Op : BITSET;           (* Raw bit pattern for OpCode *)
      Src, Dest : OpConfig;
                                                                      ---*)


   PROCEDURE CalcValue (Operand : OPERAND; VAR Value : LONG);
   (* Calculates left and right values for GetValue *)

      VAR
         Full : BOOLEAN;
         Neg : BOOLEAN;
         Dup : BOOLEAN;
         Num : CARDINAL;
         NumSyms : CARDINAL;

      BEGIN
         IF Operand[0] = '-' THEN
            Neg := TRUE;
            Operand[0] := '0';
         ELSE
            Neg := FALSE;
         END;

         IF StrToCard (Operand, Num) THEN   
            (* It is a number *)
            CardToLong (Num, Value);
            IF Neg THEN
               LongSub (LZero, Value, Value);
            END;
         ELSIF StringToLong (Operand, Value) THEN   
            (* It is a HEX number *)
         ELSIF (Operand[0] = Quote) AND (Operand[2] = Quote) THEN
            CardToLong (ORD (Operand[1]), Value);
         ELSIF (Length (Operand) = 1) AND (Operand[0] = '*') THEN
            Value := AddrCnt;
         ELSE   
            (* It is a label, but may be undefined! *)
            IF NOT Pass2 THEN
               SortSymTab (NumSyms);
            END;
            IF NOT ReadSymTab (Operand, Value, Dup) THEN
               Error (SrcLoc, Undef);
            END;
            IF Dup THEN
               Error (SrcLoc, SymDup);
            END;
         END;
      END CalcValue;



   PROCEDURE GetValue (Operand : OPERAND; VAR Value : LONG);
   (* determines value of operand (in Decimal, HEX, or via Symbol Table) *)

      VAR
         TempOp : OPERAND;
         TempVal : LONG;
         c, op : CHAR;
         i, j : CARDINAL;
         InQuotes : BOOLEAN;

      BEGIN
         i := 0;   
         Value := LZero;
         InQuotes := FALSE;
         op := '+';
         REPEAT
            j := 0;
            LOOP
               c := Operand[i];
               TempOp[j] := c;
               IF c = Quote THEN
                  InQuotes := NOT InQuotes;
               END;
               INC (i);   INC (j);
               IF c = 0C THEN
                  EXIT;
               END;
               IF (c = '+') AND (NOT InQuotes) THEN
                  EXIT;
               END;
               IF (c = '-') AND (i > 1) AND (NOT InQuotes) THEN
                  EXIT;
               END;
            END;
            TempOp[j - 1] := 0C;   (* in case c is +/- *)
            CalcValue (TempOp, TempVal);
            IF op = '-' THEN
               LongSub (Value, TempVal, Value);
            ELSE
               LongAdd (Value, TempVal, Value);
            END;
            op := c;
         UNTIL op = 0C;
      END GetValue;



   PROCEDURE GetSize (VAR Symbol : ARRAY OF CHAR; VAR Size : SizeType);
   (* determines size of opcode/operand: Byte, Word, Long *)

      VAR
         i : CARDINAL;
         c : CHAR;

      BEGIN
         i := 0;
         REPEAT
            c := Symbol[i];
            INC (i);
         UNTIL (c = 0C) OR (c = '.');

         IF c = 0C THEN
            Size := Word;   (* Default to size Word = 16 bits *)
         ELSE
            c := Symbol[i];   (* Record size extension *)
            Symbol[i - 1] := 0C;   (* Chop size extension off *)
            IF (c = 'B') OR (c = 'S') THEN   (* Byte or Short Branch/Jump *)
               Size := Byte;
            ELSIF c = 'L' THEN
               Size := Long;
            ELSE
               Size := Word;   (* Default size *)
            END;
         END;
      END GetSize;



   PROCEDURE GetAbsSize (VAR Symbol : ARRAY OF CHAR; VAR AbsSize : SizeType);
   (* determines size of operand: Word or Long *)

      VAR
         i : CARDINAL;
         c : CHAR;
         ParCnt : INTEGER;

      BEGIN
         ParCnt := 0;
         i := 0;
         REPEAT
            c := Symbol[i];
            IF c = '(' THEN
               INC (ParCnt);
            END;
            IF c = ')' THEN
               DEC (ParCnt);
            END;
            INC (i);
         UNTIL (c = 0C) OR ((c = '.') AND (ParCnt = 0));

         IF c = 0C THEN
            AbsSize := Long;
         ELSE
            c := Symbol[i];   (* Record size extension *)
            Symbol[i - 1] := 0C;   (* Chop size extension off *)
            IF (c = 'W') OR (c = 'S') THEN
               AbsSize := Word;
            ELSE
               AbsSize := Long;
            END;
         END;
      END GetAbsSize;



   PROCEDURE GetInstModeSize (Mode : OpMode; Size : SizeType;
                              VAR InstSize : CARDINAL) : CARDINAL;
   (* Determines the size for the various instruction modes.    *)

      VAR
         n : CARDINAL;

      BEGIN
         CASE Mode OF
            ARDisp,
            ARDisX,
            PCDisp,
            PCDisX,
            AbsW     :  n := 2;
         |  AbsL     :  n := 4;
         |  MultiM   :  IF Pass2 THEN
                           n := 0;   (* accounted for by code generator *)
                        ELSE
                           n := 2;
                        END;
         |  Imm      :  IF Size = Long THEN
                           n := 4;
                        ELSE
                           n := 2;
                        END;
         ELSE
                        n := 0;
         END;

         INC (InstSize, n);
         RETURN (n * 2);
      END GetInstModeSize;



   PROCEDURE GetOperand (Oper : OPERAND; VAR Op : OpConfig);  
   (* Finds mode and value for source or destination operand *)

      VAR
         ch : CHAR;
         C : CARDINAL;   (* holds the ordinal value of a charcter *)
         i, j : CARDINAL;
         Len : CARDINAL;   (* Calculated Length of Oper *)
         TempOp : OPERAND;
         MultFlag : BOOLEAN;

      BEGIN
         Op.Mode := Null;   Op.X := X0;
         Len := Length (Oper);

         IF Len = 0 THEN
            RETURN;   
         END;

         GetAbsSize (Oper, AbsSize);

         IF Oper[0] = '#' THEN   (* Immediate *)
            IF Pass2 THEN
               i := 0;
               REPEAT
                  INC (i);
                  Oper[i - 1] := Oper[i];
               UNTIL Oper[i] = 0C;
               GetValue (Oper, Op.Value);
            END;
            Op.Mode := Imm;
            RETURN;
         END;

         IF Len = 2 THEN   (* possible Addr or Data Register *)
            C := ORD (Oper[1]);
            IF (Oper[0] = 'S') AND (Oper[1] = 'R') THEN
               (* Status Register *)
               Op.Mode := SR;
               RETURN;
            ELSIF (Oper[0] = 'S') AND (Oper[1] = 'P') THEN
               (* Stack Pointer *)
               Op.Mode := ARDir;
               Op.Rn := 7;
               RETURN;
            ELSIF (C >= Zero) AND (C <= Seven) THEN   
               (* Looks Like an Addr or Data Reg *)
               IF Oper[0] = 'A' THEN   (* Address Register *)
                  Op.Mode := ARDir;
                  Op.Rn := C - Zero;
                  RETURN;
               ELSIF Oper[0] = 'D' THEN   (* Data Register *)
                  Op.Mode := DReg;
                  Op.Rn := C - Zero;
                  RETURN;
               ELSE
                  (* may be a label -- ignore for now *)
               END;
            ELSE
               (* may be a label -- ignore for now *)
            END;
         END;

         IF Len = 3 THEN
            IF (Oper[0] = 'C') AND (Oper[1] = 'C') AND (Oper[2] = 'R') THEN
               (* Condition Code Register *)
               Op.Mode := CCR;
               RETURN;
            ELSIF (Oper[0] = 'U') AND (Oper[1] = 'S') AND (Oper[2] = 'P') THEN
               (* User's Stack Pointer *)
               Op.Mode := USP;
               RETURN;
            ELSE
               (* may be a label -- ignore for now *)
            END;
         END;

         IF (Len = 4) AND (Oper[0] = '(') AND (Oper[3] = ')') THEN
            IF (Oper[1] = 'S') AND (Oper[2] = 'P') THEN
               Op.Mode := ARInd;
               Op.Rn := 7;
               RETURN;
            ELSIF Oper[1] = 'A' THEN
               C := ORD (Oper[2]);
               IF (C >= Zero) AND (C <= Seven) THEN
                  Op.Mode := ARInd;
                  Op.Rn := C - Zero;
                  RETURN;
               ELSE
                  Error (Op.Loc, SizeErr);
                  RETURN;
               END;   
            ELSE
               Error (Op.Loc, AddrErr);
               RETURN;
            END;
         END;
          
         IF (Len = 5) AND (Oper[0] = '(')
          AND (Oper[3] = ')') AND (Oper[4] = '+') THEN
           (* Address Indirect with Post Inc *)
            IF (Oper[1] = 'S') AND (Oper[2] = 'P') THEN
               (* System Stack Pointer *)
               Op.Mode := ARPost;
               Op.Rn := 7;
               RETURN
            ELSIF Oper[1] = 'A' THEN
               C := ORD (Oper[2]);
               IF (C >= Zero) AND (C <= Seven) THEN
                  Op.Mode := ARPost;
                  Op.Rn := C - Zero;
                  RETURN;
               ELSE
                  Error (Op.Loc, SizeErr);
                  RETURN;
               END;   
            ELSE
               Error (Op.Loc, AddrErr);
               RETURN;
            END;
         END;

         IF (Len = 5) AND (Oper[0] = '-') 
          AND (Oper[1] = '(') AND (Oper[4] = ')') THEN
            IF (Oper[2] = 'S') AND (Oper[3] = 'P') THEN
               (* System Stack Pointer *)
               Op.Mode := ARPre;
               Op.Rn := 7;
               RETURN;
            ELSIF Oper[2] = 'A' THEN
               C := ORD (Oper[3]);
               IF (C >= Zero) AND (C <= Seven) THEN
                  Op.Mode := ARPre;
                  Op.Rn := C - Zero;
                  RETURN;
               ELSE
                  Error (Op.Loc, SizeErr);
                  RETURN;
               END;
            ELSE
               Error (Op.Loc, AddrErr);
               RETURN;
            END;
         END;

         (* Try to split off displacement (if present) *)
         i := 0;
         ch := Oper[i];
         WHILE (ch # '(') AND (ch # 0C) DO   (* move to TempOp *)
            TempOp[i] := ch;
            INC (i);
            ch := Oper[i];
         END;
         TempOp[i] := 0C;   (* Displacement (it it exists) now in TempOp *)

         IF ch = '(' THEN   (* looks like a displacement mode *)
            IF Pass2 THEN
               GetValue (TempOp, Op.Value);   (* Value of Disp. *)
            END;
            j := 0;
            REPEAT   (* put rest of operand (eg. (An,Xi) in TempOp *)
               ch := Oper[i];
               TempOp[j] := ch;
               INC (i);   INC (j);
            UNTIL ch = 0C;
            IF Length (TempOp) > 4 THEN   (* Index may be present *)
               i := 4;   (* Index starts at 4 *)
               j := 0;
               REPEAT                       (* put Xi in Oper *)
                  ch := TempOp[i];
                  Oper[j] := ch;
                  INC (i);   INC (j);
               UNTIL ch = 0C;

               IF Oper[j - 2] = ')' THEN
                  Oper[j - 2] := 0C;
               ELSE
                  Error (Op.Loc, AddrErr);
                  RETURN;
               END;

               GetSize (Oper, Op.Xsize);
               IF Op.Xsize = Byte THEN
                  Error (Op.Loc, SizeErr);
                  RETURN;
               END;

               C := ORD (Oper[1]);
               IF (Oper[0] = 'S') AND (Oper[1] = 'P') THEN
                  (* Stack Pointer *)
                  Op.X := Areg;
                  Op.Xn := 7;
               ELSIF Oper[0] = 'A' THEN
                  IF (C >= Zero) AND (C <= Seven) THEN
                     Op.X := Areg;
                     Op.Xn := C - Zero;
                  ELSE
                     Error (Op.Loc, SizeErr);
                     RETURN;
                  END;
               ELSIF Oper[0] = 'D' THEN
                  IF (C >= Zero) AND (C <= Seven) THEN
                     Op.X := Dreg;
                     Op.Xn := C - Zero;
                  ELSE
                     Error (Op.Loc, SizeErr);
                     RETURN;
                  END;
               ELSE
                  Error (Op.Loc, AddrErr);
                  RETURN;
               END;

               IF (TempOp[1] = 'P') AND (TempOp[2] = 'C') THEN
                  Op.Mode :=PCDisX;
                  RETURN;    
               ELSIF (TempOp[1] = 'S') AND (TempOp[2] = 'P') THEN
                  (* Stack Pointer *)
                  Op.Rn := 7;
                  Op.Mode := ARDisX;
                  RETURN;
               ELSIF TempOp[1] = 'A' THEN
                  C := ORD (TempOp[2]);
                  IF (C >= Zero) AND (C <= Seven) THEN
                     Op.Rn := C - Zero;
                     Op.Mode := ARDisX;
                     RETURN;
                  ELSE
                     Error (Op.Loc, SizeErr);
                     RETURN;
                  END;
               ELSE
                  Error (Op.Loc, AddrErr);
                  RETURN;
               END;
            ELSE   (* No Index *)
               IF (TempOp[1] = 'P') AND (TempOp[2] = 'C') THEN
                  Op.Mode := PCDisp;
                  RETURN;    
               ELSIF (TempOp[1] = 'S') AND (TempOp[2] = 'P') THEN
                  (* Stack Pointer *)
                  Op.Mode := ARDisp;
                  Op.Rn := 7;                                                
                  RETURN;  
               ELSIF TempOp[1] = 'A' THEN
                  C := ORD (TempOp[2]);
                  IF (C >= Zero) AND (C <= Seven) THEN
                     Op.Rn := C - Zero;
                     Op.Mode := ARDisp;
                     RETURN;
                  ELSE
                     Error (Op.Loc, SizeErr);
                     RETURN;
                  END;
               ELSE
                  Error (Op.Loc, AddrErr);
                  RETURN;
               END;
            END;
         END;

         (* Check to see if this could be a register list for MOVEM: *)
         i := 0;
         MultFlag := FALSE;
         LOOP
            ch := Oper[i];   INC (i);
            IF ch = 0C THEN
               MultFlag := FALSE;
               EXIT;
            END;
            IF (ch = 'A') OR (ch = 'D') THEN
               ch := Oper[i];   INC (i);   C := ORD (ch);
               IF ch = 0C THEN
                  MultFlag := FALSE;
                  EXIT;
               END;
               IF (C >= Zero) AND (C <= Seven) THEN
                  ch := Oper[i];   INC (i);  
                  IF ch = 0C THEN
                     EXIT
                  END;
                  IF (ch = '/') OR (ch = '-') THEN
                     MultFlag := TRUE;
                  END;
               ELSE
                  MultFlag := FALSE;
                  EXIT;
               END;
            ELSE
               MultFlag := FALSE;
               EXIT;
            END;
         END;
         IF MultFlag THEN
            Op.Mode := MultiM;
            RETURN;
         END;

         (* Must be absolute mode! *)
         IF Pass2 THEN
            GetValue (Oper, Op.Value);
         END;
         IF AbsSize = Word THEN
            Op.Mode := AbsW;
         ELSE
            Op.Mode := AbsL;
         END;
      END GetOperand;



   PROCEDURE GetMultReg (Oper : OPERAND; PreDec : BOOLEAN;
                         Loc : CARDINAL; VAR MultExt : BITSET);
   (* Builds a BITSET marking each register used in a MOVEM instruction *)

      TYPE
         MReg = (D0, D1, D2, D3, D4, D5, D6, D7, 
                 A0, A1, A2, A3, A4, A5, A6, A7);

      VAR
         i, j : CARDINAL;
         ch : CHAR;
         C : CARDINAL;   (* ORD value of ch *)
         T1, T2 : MReg;   (* Temporary variables for registers *)
         RegStack : ARRAY [0..15] OF MReg;   (* Holds specified registers *)
         SP : CARDINAL;   (* Pointer for Register Stack *)
         RegType : (D, A, Nil);
         Range : BOOLEAN;
         
      BEGIN
         SP := 0;
         Range := FALSE;
         RegType := Nil;
         i := 0;

         ch := Oper[i];
         WHILE ch # 0C DO
            IF SP > 15 THEN
               Error (Loc, SizeErr);
               RETURN;
            END;

            C := ORD (ch);
            IF ch = 'A' THEN
               IF RegType = Nil THEN
                  RegType := A;
               ELSE
                  Error (Loc, OperErr);
                  RETURN;
               END;
            ELSIF ch = 'D' THEN
               IF RegType = Nil THEN
                  RegType := D;
               ELSE
                  Error (Loc, OperErr);
                  RETURN;
               END;
            ELSIF (C >= Zero) AND (C <= Seven) THEN
               IF RegType # Nil THEN
                  T2 := VAL (MReg, (ORD (RegType) * 8) + (C - Zero));
                  IF Range THEN
                     Range := FALSE;
                     T1 := RegStack[SP - 1];   (* retreive 1st Reg in range *)
                     FOR j := (ORD (T1) + 1) TO ORD (T2) DO
                        RegStack[SP] := VAL (MReg, j);
                        INC (SP);
                     END;
                  ELSE
                     RegStack[SP] := T2;
                     INC (SP);
                  END;
               ELSE
                  Error (Loc, OperErr);
                  RETURN;
               END;
            ELSIF ch = '-' THEN
               IF (Range = FALSE) AND (RegType # Nil) AND (i > 0) THEN
                  RegType := Nil;
                  Range := TRUE;
               ELSE
                  Error (Loc, OperErr);
                  RETURN;
               END;
            ELSIF ch = '/' THEN
               IF (Range = FALSE) AND (RegType # Nil) AND (i > 0) THEN
                  RegType := Nil;
               ELSE
                  Error (Loc, OperErr);
                  RETURN;
               END;
            ELSE
               Error (Loc, OperErr);
               RETURN;
            END;
            
            INC (i);
            ch := Oper[i];
         END;

         MultExt := {};
         FOR j := 0 TO SP - 1 DO
            C := ORD (RegStack[j]);
            IF PreDec THEN
               C := 15 - C;
            END;
            INCL (MultExt, C);
         END;
      END GetMultReg;

END SyntaxAnalyzer.

****

Listing 19

IMPLEMENTATION MODULE Listing;
(* Creates a program listing, including Addresses, Code & Source. *)

   FROM Files IMPORT
      FILE, Write;

   FROM LongNumbers IMPORT
      LONG, LongPut;

   FROM Parser IMPORT
      TOKEN, Line;

   FROM SymbolTable IMPORT
      ListSymTab;

   FROM Conversions IMPORT
      CardToStr;

   IMPORT ASCII;

      
   CONST
      LnMAX = 55;


   VAR
      LnCnt : CARDINAL;   (* counts number of lines per page *)
      PgCnt : CARDINAL;   (* count of page numbers *)



   PROCEDURE WriteStrF (f : FILE; Str : ARRAY OF CHAR);
   (* Writes a string to the file *)

      VAR
         i : CARDINAL;

      BEGIN
         i := 0;
         WHILE Str[i] # 0C DO
            Write (f, Str[i]);
            INC (i);
         END;
      END WriteStrF;



   PROCEDURE CheckPage (f : FILE);
   (* Checks if end of page reached yet -- if so, advances to next page. *)

      VAR
         i : CARDINAL;
         PgCntStr : ARRAY [0..6] OF CHAR;
      
      BEGIN
         INC (LnCnt);
         IF LnCnt >= LnMAX THEN
            LnCnt := 1;
            INC (PgCnt);
            Write (f, ASCII.ff);   (* Form Feed for new page *)
            IF CardToStr (PgCnt, PgCntStr) THEN   (* Print New Page Number *)
               FOR i := 1 TO 60 DO
                  Write (f, ' ');
               END;

               WriteStrF (f, "Page ");
               WriteStrF (f, PgCntStr);
            END;
            FOR i := 1 TO 3 DO
               Write (f, ASCII.cr);
               Write (f, ASCII.lf);
            END;
         END;
      END CheckPage;



   PROCEDURE StartListing (f : FILE);
   (* Sign on messages for listing file -- initialize *)
      BEGIN
         Write (f, ASCII.ff);   (* Start on a clean page *)

         WriteStrF (f, "                 68000 Cross Assembler");
         Write (f, ASCII.cr);
         Write (f, ASCII.lf);

         WriteStrF (f, "         Copyright (c) 1985 by Brian R. Anderson");
         Write (f, ASCII.cr);
         Write (f, ASCII.lf);

         Write (f, ASCII.cr);
         Write (f, ASCII.lf);

         LnCnt := 1;
         PgCnt := 1;
      END StartListing;



   PROCEDURE WriteListLine (f : FILE;
                            AddrCnt, ObjOp, ObjSrc, ObjDest : LONG;
                               nA,     nO,    nS,     nD    : CARDINAL);
   (* Writes one line to the Listing file, Including Object Code *)

      CONST
         ObjMAX = 30;

      VAR
         i : CARDINAL;

      BEGIN
         IF nA = 0 THEN   (* nA is always either 0 or 6.  Address field = 8 *)
            FOR i := 1 TO 8 DO
               Write (f, ' ');
            END;
         ELSE
            LongPut (f, AddrCnt, 6);
            Write (f, ' ');   
            Write (f, ' ');
         END;
         LongPut (f, ObjOp, nO);   
         LongPut (f, ObjSrc, nS);  
         LongPut (f, ObjDest, nD); 
         i := 8 + nO + nS + nD;
         WHILE i < ObjMAX DO
            Write (f, ' ');
            INC (i);
         END;

         WriteStrF (f, Line);
         Write (f, ASCII.cr);
         Write (f, ASCII.lf);
         
         CheckPage (f);

      END WriteListLine;



   PROCEDURE WriteSymTab (f : FILE; NumSym : CARDINAL);
   (* Lists symbol table in alphabetical order *)

      VAR
         Label : TOKEN;
         Value : LONG;
         i : CARDINAL;

      BEGIN
         LnCnt := 1;
         INC (PgCnt);

         WriteStrF (f, "             * * *  Symbolic Reference Table  * * *");
         FOR i := 1 TO 3 DO
            Write (f, ASCII.cr);
            Write (f, ASCII.lf);
         END;

         FOR i := 1 TO NumSym DO
            ListSymTab (i, Label, Value);
            WriteStrF (f, Label);
            WriteStrF (f, "  :  ");
            LongPut (f, Value, 8);
            Write (f, ASCII.cr);
            Write (f, ASCII.lf);
            CheckPage (f);
         END; 

         Write (f, ASCII.ff);
      END WriteSymTab;

END Listing.

****

Lisiting 20

IMPLEMENTATION MODULE Srecord;
(* Creates Motorola S-records of program:        *)
(*    S0 = header record,                        *)
(*    S2 = code/data records (24 bit address),   *)
(*    S8 = termination record (24 bit address).  *)

   FROM Files IMPORT
      FILE, Write;

   FROM Strings IMPORT
      Length;

   FROM LongNumbers IMPORT
      LONG, LongAdd, LongSub, LongInc, LongDec, LongClear, 
      LongCompare, CardToLong, LongPut;

   IMPORT ASCII;


   CONST
      CountMAX = 16;
      SrecMAX = CountMAX * 2;
      XrecMAX = SrecMAX;


   VAR
      StartAddr : LONG;   (* address that record starts on *)
      TempAddr : LONG;    (* running address of where we are now *)
      CheckSum : LONG;
      Count : CARDINAL;   (* count of HEX-pairs in S-record *)
      Sdata : ARRAY [1..SrecMAX] OF INTEGER;   (* S-record data, HEX digits *)
      Sindex : CARDINAL;   (* index for Sdata array *)
      Xdata : ARRAY [1..XrecMAX] OF INTEGER;   (* Overflow for Sdata *)
      Xindex : CARDINAL;   (* index for Xdata array *)
      Boundary : BOOLEAN;   (* marks Address MOD 16 boundary of S-record *)
      LZero : LONG;   (* used as a constant = 0 *)



   PROCEDURE Complement;   (* CheckSum *)
      BEGIN
         LongSub (LZero, CheckSum, CheckSum);   (* 2's Complement *)
         LongDec (CheckSum, 1);   (* Make it 1's Complement *)
      END Complement;


      
   PROCEDURE AppendSdata (Data : LONG; n : CARDINAL) : BOOLEAN;
   (* Transfers data to Sdata, and updates Count & CheckSum. *)
   (*    If no room: Data goes to Xdata & FALSE returned.    *)

      VAR
         T : LONG;   (* temporary -- used only as a 2 digit HEX number *)

      BEGIN
         T := LZero;

         WHILE (n # 0) AND (Count # CountMAX) AND (NOT Boundary) DO
            Sdata[Sindex] := Data[n];
            Sdata[Sindex - 1] := Data[n - 1];

            T[2] := Data[n];   T[1] := Data[n - 1];
            LongAdd (T, CheckSum, CheckSum);

            DEC (n, 2);
            DEC (Sindex, 2);
            INC (Count);

            LongInc (TempAddr, 1);
            IF TempAddr[1] = 0 THEN   (* i.e., TempAddr MOD 16 = 0 *)
               Boundary := TRUE;
            END;
         END;
   
         IF (Count = CountMAX) OR (Boundary) THEN
            WHILE n > 0 DO   (* Add Data to Xdata (in reverse) *)
               INC (Xindex);
               Xdata[Xindex] := Data[n];
               DEC (n);
            END;

            RETURN FALSE;   (* Sdata is full *)
         ELSE
            RETURN TRUE;
         END;         
      END AppendSdata;



   PROCEDURE DumpSdata (f : FILE);
   (* Writes an S2 record to the file *)
      
      VAR
         T : LONG;   (* temporary -- used to output Count & CheckSum *)
         i, j : CARDINAL;

      BEGIN
         IF Count = 0 THEN
            RETURN;   (* nothing to dump *)
         END;

         Write (f, 'S');
         Write (f, '2');
         
         CardToLong (Count + 4, T);   (* extra for Address & Checksum *)
         LongPut (f, T, 2);
         LongAdd (T, CheckSum, CheckSum);   (* Add Count to CheckSum *)

         LongPut (f, StartAddr, 6);
         (* Add Address to CheckSum *)
         T := LZero;
         T[1] := StartAddr[1];   T[2] := StartAddr[2];
         LongAdd (T, CheckSum, CheckSum);
         T[1] := StartAddr[3];   T[2] := StartAddr[4];
         LongAdd (T, CheckSum, CheckSum);
         T[1] := StartAddr[5];   T[2] := StartAddr[6];
         LongAdd (T, CheckSum, CheckSum);
         
         IF Count < CountMAX THEN   (* adjust short record -- shuffle down *)
            j := 1;
            FOR i := Sindex + 1 TO SrecMAX DO
               Sdata[j] := Sdata[i];
               INC (j);
            END;
         END;
         LongPut (f, Sdata, Count * 2);   (* S-record Code/Data *)

         Complement; (* CheckSum *)
         LongPut (f, CheckSum, 2);

         Write (f, ASCII.cr);
         Write (f, ASCII.lf);

         LongInc (StartAddr, Count);
         Sindex := SrecMAX;
         Count := 0;
         Boundary := FALSE;
         CheckSum := LZero;
      END DumpSdata;



   PROCEDURE GetXdata;
   (* Transfer Xdata into new Sdata line -- N.B.: Xdata stored in reverse *)

      VAR
         i : CARDINAL;
         T : LONG;

      BEGIN
         i := 1;
         T := LZero;

         (* No need for either of the tests (CountMAX or Boundary)   *)
         (* used in AppendSdata.  GetXdata is only ever called       *)
         (* after DumpSdata and is therefore only putting (up to 20) *)
         (* HEX digits in an empty buffer (which could hold 32).     *)
         WHILE i < Xindex DO
            Sdata[Sindex] := Xdata[i];   
            Sdata[Sindex - 1] := Xdata[i + 1];
            T[2] := Sdata[Sindex];   T[1] := Sdata[Sindex - 1];   
            LongAdd (T, CheckSum, CheckSum);
            INC (i, 2);
            DEC (Sindex, 2);
            INC (Count);
            LongInc (TempAddr, 1);
         END;

         Xindex := 0;            
      END GetXdata;



   PROCEDURE StartSrec (f : FILE; SourceFN : ARRAY OF CHAR);
   (* Writes S0 record (HEADER) and initializes *)
      
      VAR
         T : LONG;   (* temporary *)
         i : CARDINAL;

      BEGIN
         Write (f, 'S');
         Write (f, '0');

         CheckSum := LZero;
         Count := Length (SourceFN) + 3;   (* extra for Address & Checksum *)
         CardToLong (Count, T);
         LongPut (f, T, 2);
         LongAdd (T, CheckSum, CheckSum);
         
         LongPut (f, LZero, 4);   (* Address is 4 digit, all zero, for S0 *)

         i := 0;
         WHILE SourceFN[i] # 0C DO
            CardToLong (ORD (SourceFN[i]), T);
            LongAdd (T, CheckSum, CheckSum);
            LongPut (f, T, 2);
            INC (i);
         END;
         
         Complement;   (* CheckSum *)
         LongPut (f, CheckSum, 2);

         Write (f, ASCII.cr);
         Write (f, ASCII.lf);

         Sindex := SrecMAX;
         Xindex := 0;
         Count := 0;
         Boundary := FALSE;
         CheckSum := LZero;
         StartAddr := LZero;
         TempAddr := LZero;
      END StartSrec;



   PROCEDURE WriteSrecLine (f : FILE; 
                            AddrCnt, ObjOp, ObjSrc, ObjDest : LONG;
                               nA,     nO,    nS,     nD    : CARDINAL);
   (* Collects Object Code -- Writes an S2 record to file if line is full *)

      VAR
         dummy : BOOLEAN;
      
      BEGIN
         IF nA = 0 THEN
            RETURN;   (* Nothing to add to S-record *)
         END;

         IF Xindex # 0 THEN
            GetXdata;   (* transfers Xdata into Sdata *)
         END;

         IF LongCompare (AddrCnt, TempAddr) # 0 THEN
            DumpSdata (f);
         END;

         IF Count = 0 THEN
            StartAddr := AddrCnt;
            TempAddr := AddrCnt;
         END;
      
         dummy := AppendSdata (ObjOp, nO);
         dummy := AppendSdata (ObjSrc, nS);
         IF NOT AppendSdata (ObjDest, nD) THEN
            DumpSdata (f);
         END;
      END WriteSrecLine;



   PROCEDURE EndSrec (f : FILE);
   (* Finishes off any left-over (Partial) S2 line, *)
   (* and then writes S8 record (TRAILER)           *)
      BEGIN
         IF Xindex # 0 THEN
            GetXdata;
         END;
         DumpSdata (f);
         
         Write (f, 'S');   (* Fixed format for S8 record *)
         Write (f, '8');
         Write (f, '0');
         Write (f, '4');
         Write (f, '0');
         Write (f, '0');
         Write (f, '0');
         Write (f, '0');
         Write (f, '0');
         Write (f, '0');
         Write (f, 'F');
         Write (f, 'C');
         Write (f, ASCII.cr);
         Write (f, ASCII.lf);
         Write (f, ASCII.cr);
         Write (f, ASCII.lf);
      END EndSrec;

BEGIN   (* Initialization *)
   LongClear (LZero);
END Srecord.

****

Listing 21
IMPLEMENTATION MODULE ErrorX68;
(* Displays error messages for X68000 cross assembler *)

   FROM Terminal IMPORT
      WriteString, WriteLn;

   IMPORT Terminal;   (* for Read/Write *)

   FROM Files IMPORT
      FILE;

   IMPORT Files;   (* for Write *)

   FROM Strings IMPORT
      Length;

   FROM Conversions IMPORT
      CardToStr;

   IMPORT ASCII;

   FROM Parser IMPORT
      Line, LineCount;


(*---
   TYPE
      ErrorType = (Dummy, TooLong, NoCode, SymDup, Undef, SymFull, Phase,
                   ModeErr, OperErr, BraErr, AddrErr, SizeErr, EndErr);

   VAR
      ErrorCount : CARDINAL;
                                                                  ---*)

   VAR
      FirstTime : BOOLEAN;



   PROCEDURE FileWriteString (f : FILE; VAR Str : ARRAY OF CHAR);

      VAR
         i : CARDINAL;

      BEGIN
         i := 0;
         WHILE Str[i] # 0C DO
            Files.Write (f, Str[i]);
            INC (i);
         END;
      END FileWriteString;



   PROCEDURE Error (Pos : CARDINAL; ErrorNbr : ErrorType);
   (* Displays Error #ErrorNbr, then waits for any key to continue *)

      VAR
         i : CARDINAL;
         c : CHAR;
         CntStr : ARRAY [0..6] OF CHAR;
         dummy : BOOLEAN;

      BEGIN
         WriteLn;
         dummy := CardToStr (LineCount, CntStr);
         WriteString (CntStr);
         WriteString ("   ");
         WriteString (Line);   WriteLn;

         (* Make up for LineCnt so ^ in right spot *)
         FOR i := 1 TO Length (CntStr) DO
            Terminal.Write (' ');
         END;
         WriteString ("   ");

         IF Pos > 0 THEN
            FOR i := 1 TO Pos DO
               Terminal.Write (' ');
            END;
            Terminal.Write ('^');   WriteLn;
         END;
         
         CASE ErrorNbr OF
            TooLong : WriteString ("Identifier too long -- Truncated!");
         |  NoCode  : WriteString ("No such op-code.");
         |  SymDup  : WriteString ("Duplicate Symbol.");
         |  Undef   : WriteString ("Undefined Symbol.");
         |  SymFull : WriteString ("Symbol Table Full -- Maximum = 500!");
                      WriteLn;
                      WriteString ("Program Terminated.");   WriteLn;
                      HALT;
         |  Phase   : WriteString ("Pass 1/Pass 2 Address Count Mis-Match.");
         |  ModeErr : WriteString ("This addressing mode not allowed here.");
         |  OperErr : WriteString ("Error in operand format.");
         |  BraErr  : WriteString ("Error in relative branch.");
         |  AddrErr : WriteString ("Address mode error.");
         |  SizeErr : WriteString ("Operand size error.");
         |  EndErr  : WriteString ("Missing END Pseudo-Op.");
         ELSE
            WriteString ("Unknown Error.");
         END;
         WriteLn; 

         IF FirstTime THEN
            WriteString ("Hit any key to continue.... ");
            Terminal.Read (c);   
            WriteLn;
            FirstTime := FALSE;
         ELSE
            Terminal.Read (c);
         END;
         
         INC (ErrorCount);
         IF ErrorCount > 500 THEN
            WriteString ("Too many errors!");   WriteLn;
            WriteString ("Program Terminated.");   WriteLn;
            HALT;
         END;
      END Error;



   PROCEDURE WriteErrorCount (f : FILE);
   (* Error count output to Console & Listing file *)

      VAR
         CntStr : ARRAY [0..6] OF CHAR;
         Msg0 : ARRAY [0..25] OF CHAR;
         Msg1 : ARRAY [0..10] OF CHAR;
         Msg2 : ARRAY [0..20] OF CHAR;
         dummy : BOOLEAN;

      BEGIN
         Msg0 := "--->   END OF ASSEMBLY";
         Msg1 := "--->   ";
         Msg2 := " ASSEMBLY ERROR(S).";
         dummy := CardToStr (ErrorCount, CntStr);
            
         (* Messages to console *)
         WriteLn;
         WriteLn;
         WriteString (Msg0);   WriteLn;
         WriteString (Msg1);
         WriteString (CntStr);
         WriteString (Msg2);
         WriteLn;

         (* Messages to listing file *)
         Files.Write (f, ASCII.cr);   
         Files.Write (f, ASCII.lf);
         Files.Write (f, ASCII.cr);   
         Files.Write (f, ASCII.lf);

         FileWriteString (f, Msg0);
         Files.Write (f, ASCII.cr);   
         Files.Write (f, ASCII.lf);

         FileWriteString (f, Msg1);
         FileWriteString (f, CntStr);
         FileWriteString (f, Msg2);
         Files.Write (f, ASCII.cr);   
         Files.Write (f, ASCII.lf);

         Files.Write (f, ASCII.ff);   (* feed up next page *)
      END WriteErrorCount;


BEGIN   (* MODULE Initialization *)
   FirstTime := TRUE;
   ErrorCount := 0;
END ErrorX68.

***********************END LISTINGS*********************************

