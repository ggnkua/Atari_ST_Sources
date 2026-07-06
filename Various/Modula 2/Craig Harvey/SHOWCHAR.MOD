MODULE Showchar; (* Shows ASCII code and character of ANY key
                   or combination from keyboard.  
              Craig Harvey, the Clear Thinking BBS 313-761-2444
                   Created with TDI Modula-2 *)

FROM InOut IMPORT Read, Write, WriteLn, WriteString, WriteCard;
FROM SYSTEM IMPORT CODE;
VAR ch : CHAR;

PROCEDURE Bconout5(ch : CHAR);
(* 
    Supplements TDI BConOut procedure which is missing final device.
                        For all characters to show, you need sixth 
    device (#5) (see ST Internals p. 246) which is not implemented
    yet in TDI M2, so use BIOS call to bconout (ST Internals p. 144). 
    I never found it specifically stated how to do a move.w #character,
    but from examples in the Abacus Machine Language book, I
    discovered you just repeat the ASCII code for the character 
    twice (once in each byte of the word) to make the immediate 
    mode source data.    
*)
VAR x [523520] : CARDINAL; (* The first byte of the 768 free bytes
                              above screen ram on 520ST. *)
                        
BEGIN
  x:= 256*ORD(ch) + ORD(ch);
  
                  (* Machine Code    Hex   Assembly Code *)
(* example for 
   single character:
  CODE(16188); (* (0011111100111100) 3F3C move.w #'A',-(sp) *)
  CODE(16705); (* (0100000101000001) 4141 [ch= 'A'  ORD('A')= 65] *)
*)
(* code for getting
  char code from 
  address of x:
*)
  CODE(16185); (* (0011111100111001) 3F39 move.w $7FD00,-(sp)     *)
  CODE(7);     (* (0000000000000111) 0007 [first word of x address] *)
  CODE(64768); (* (1111110100000000) FD00 [second word of address] *)
  CODE(16188); (* (0011111100111100) 3F3C move.w #5,-(sp) *)
  CODE(5);     (* (0000000000000101)    5 [device #5, full font dev.] *)
  CODE(16188); (* (0011111100111100) 3F3C move.w #3, -(sp) *)
  CODE(3);     (* (0000000000000011)    3 [BIOS function #3, bconout] *)
  CODE(20045); (* (0100111001001101) 4E4D trap #13 [call to BIOS] *)
  CODE(23695); (* (0101110010001111) 5C8F addq.l #6, sp [stack corr.] *)

END Bconout5;


BEGIN
  Write(CHR(27)); (* escape code; use with VT 52 control codes *)
  Write('E');  (* VT52 clear home code *)
  WriteLn; 
  WriteString('"SHOWCHAR" by Craig Harvey, Clear Thinking BBS 313-761-2444');  WriteLn;
  WriteString('   Created with TDI Modula-2.');
  WriteLn;
  WriteString("HIT KEYS OR COMBINATIONS AND SEE IT'S ASCII CODE AND ");
  WriteLn;
  WriteString("IT'S CHARACTER, INCLUDING THE CONTROL & SHFT/CNTRL ONES");
  WriteLn; WriteLn;
  WriteString('Terminate program with "@" (shift-2)');
  WriteLn;
  REPEAT
    Read(ch);
    WriteCard(ORD(ch), 1);
    Write(' ');
    Bconout5(ch);
    IF ch = ' ' THEN WriteString('[space]') END;
    WriteLn;
  UNTIL (ch = '@');
END Showchar.
