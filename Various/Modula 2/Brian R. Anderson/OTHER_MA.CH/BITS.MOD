DEFINITION MODULE Bits;
(* bit manipulation module *)
(* BA June 10, 1985        *)

   EXPORT QUALIFIED
      BYTE, Set, Reset, Test, ShiftLeft, ShiftRight, And, Or, Xor;

   TYPE
      BYTE = CHAR;

   PROCEDURE Set (VAR A : BYTE; bit : CARDINAL);

   PROCEDURE Reset (VAR A : BYTE; bit : CARDINAL);

   PROCEDURE Test (A : BYTE; bit : CARDINAL) : BOOLEAN;

   PROCEDURE ShiftLeft (VAR A : BYTE);

   PROCEDURE ShiftRight (VAR A : BYTE);

   PROCEDURE And (A, B : BYTE) : BYTE;

   PROCEDURE Or (A, B : BYTE) : BYTE;

   PROCEDURE Xor (A, B : BYTE) : BYTE;

END Bits.

Listing Two
IMPLEMENTATION MODULE Bits;
(* bit manipulation module *)
(* BA June 10, 1985        *)

   VAR
      cA, cB : CARDINAL;   (* cardinal value for parameters A & B *)
      bA, bB : BITSET;   (* bitset value for parameters A & B *)
      Result : BITSET;   (* result for and/or/xor *)


   PROCEDURE Set (VAR A : BYTE; bit : CARDINAL);

      BEGIN
         cA := ORD (A);   (* convert BYTE to CARDINAL *)
         bA := BITSET (cA);   (* 'coerce' CARDINAL to BITSET *)
         INCL (bA, bit MOD 8);   (* set the bit (make sure in range 0 --> 7) *)
         cA := CARDINAL (bA);   (* 'coerce BITSET back to CARDINAL *)
         A := CHR (cA);   (* convert CARDINAL back to BYTE *)         
      END Set;


   PROCEDURE Reset (VAR A : BYTE; bit : CARDINAL);

      BEGIN
         cA := ORD (A);
         bA := BITSET (cA);
         EXCL (bA, bit MOD 8);   
         cA := CARDINAL (bA);
         A := CHR (cA);         
      END Reset;


   PROCEDURE Test (A : BYTE; bit : CARDINAL) : BOOLEAN;
      
      BEGIN
         cA := ORD (A);
         bA := BITSET (cA);

         IF (bit MOD 8) IN bA THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END;
      END Test;


   PROCEDURE ShiftLeft (VAR A : BYTE);

      BEGIN
         cA := ORD (A);
         cA := cA * 2;   (* Shift Left is equivalant to Multiplication by 2 *)
         A := CHR (cA);
      END ShiftLeft;


   PROCEDURE ShiftRight (VAR A : BYTE);

      BEGIN
         cA := ORD (A);
         cA := cA DIV 2;
         A := CHR (cA);
      END ShiftRight;


   PROCEDURE And (A, B : BYTE) : BYTE;

      BEGIN
         cA := ORD (A);   (* both BYTEs must be forced to BITSET *)
         bA := BITSET (cA);
         cB := ORD (B);
         bB := BITSET (cB);

         Result := bA * bB;   (* AND the two bitsets *)

         cA := CARDINAL (Result);   (* force Result back to BYTE *)
         A := CHR (cA);
         RETURN A;
      END And;


   PROCEDURE Or (A, B : BYTE) : BYTE;

      BEGIN
         cA := ORD (A);
         bA := BITSET (cA);
         cB := ORD (B);
         bB := BITSET (cB);

         Result := bA + bB;

         cA := CARDINAL (Result);
         A := CHR (cA);
         RETURN A;
      END Or;


   PROCEDURE Xor (A, B : BYTE) : BYTE;

      BEGIN
         cA := ORD (A);
         bA := BITSET (cA);
         cB := ORD (B);
         bB := BITSET (cB);

         Result := bA / bB;

         cA := CARDINAL (Result);
         A := CHR (cA);
         RETURN A;
      END Xor;

END Bits.

Listing Three
;IMPLEMENTATION MODULE Bits;
;(* bit manipulation module *)
;(* BA June 13, 1985        *)
       NAME    ('BITS')                                        
;
       .Z80
;
;   EXPORT QUALIFIED
;      BYTE, Set, Reset, Test, ShiftLeft, ShiftRight, And, Or, Xor;
;
       PUBLIC SET, RESET, TEST, SHL, SHR, ANDB, ORB, XORB
;
;   TYPE
;      BYTE = CHAR;
;
       CSEG
;
MOD8   EQU     00000111B       ;Mask to calculate bit MOD 8
;               
;
;   PROCEDURE Set (VAR A : BYTE; bit : CARDINAL);
;
SET:   POP     IY              ;Return Address
       POP     BC              ;bit #
       EX      (SP),IY         ;BYTE's address <---> Return Address
       LD      A,MOD8          ;Make sure bit
       AND     C               ; in range 0 --> 7
       LD      B,A             ;'Safe' bit # in B                       
       XOR     A               ;Clear Accum. & CY
       CCF                     ;Set CY to make mask
       INC     B               ;Adjust count
FINDS: RLA                     ;Rotate mask 
       DJNZ    FINDS           ; until count is zero
       OR      (IY)            ;Set the bit
       LD      (IY),A          ;Return it to BYTE
       RET

;
;   PROCEDURE Reset (VAR A : BYTE; bit : CARDINAL);
;
RESET: POP     IY              ;Return Address
       POP     BC              ;bit #
       EX      (SP),IY         ;BYTE's address <---> Return Address
       LD      A,MOD8          ;Make sure bit
       AND     C               ; in range 0 --> 7
       LD      B,A             ;'Safe' bit # in B                       
       XOR     A               ;Clear Accum. & CY
       CCF                     ;Set CY to make mask
       INC     B               ;Adjust count
FINDR: RLA                     ;Rotate mask 
       DJNZ    FINDR           ; until count is zero
       CPL                     ;Invert mask
       AND     (IY)            ;Reset (clear) the bit
       LD      (IY),A          ;Return it to BYTE
       RET

;
;   PROCEDURE Test (A : BYTE; bit : CARDINAL) : BOOLEAN;
;
TRUE   EQU     00000001B       ;
                               ;
TEST:  POP     HL              ;Return Address
       POP     BC              ;bit #
       EX      (SP),HL         ;BYTE <---> Return Address
       LD      IY,0            ;Clear a Pointer
       ADD     IY,SP           ;Make Copy of Stack Pointer
       LD      A,MOD8          ;Make sure bit
       AND     C               ; in range 0 --> 7
       LD      B,A             ;'Safe' bit # in B                       
       XOR     A               ;Clear Accum. & CY
       CCF                     ;Set CY to make mask
       INC     B               ;Adjust count
FINDT: RLA                     ;Rotate mask 
       DJNZ    FINDT           ; until count is zero
       AND     L               ;Check if bit set
       JP      Z,FALSE         ;If zero, return FALSE
       LD      A,TRUE          ; else, return TRUE
FALSE: LD      (IY+2),A        ;Store function Return Value
       RET

;
;   PROCEDURE ShiftLeft (VAR A : BYTE);
;
SHL:   POP     HL              ;Return Address
       EX      (SP),HL         ;BYTE's address <---> Return Address
       SLA     (HL)            ;Shift Left (Arithmetic)
       RET

;
;   PROCEDURE ShiftRight (VAR A : BYTE);
;
SHR:   POP     HL              ;Return Address
       EX      (SP),HL         ;BYTE's address <---> Return Address
       SRL     (HL)            ;Shift Right (Logical)
       RET

;
;   PROCEDURE And (A, B : BYTE) : BYTE;
;
ANDB:  POP     HL              ;Return Address
       POP     DE              ;'B'
       EX      (SP),HL         ;'A' <---> Return Address
       LD      IY,0            ;Clear a Pointer
       ADD     IY,SP           ;Make Copy of Stack Pointer
       LD      A,L             ;Move 'A' to Accum.
       AND     E               ;And with 'B'
       LD      (IY+2),A        ;Store function return value
       RET

;
;   PROCEDURE Or (A, B : BYTE) : BYTE;
;
ORB:   POP     HL              ;Return Address
       POP     DE              ;'B'
       EX      (SP),HL         ;'A' <---> Return Address
       LD      IY,0            ;Clear a Pointer
       ADD     IY,SP           ;Make Copy of Stack Pointer
       LD      A,L             ;Move 'A' to Accum.
       OR      E               ;Or with 'B'
       LD      (IY+2),A        ;Store function return value
       RET


;
;   PROCEDURE Xor (A, B : BYTE) : BYTE;
;
XORB:  POP     HL              ;Return Address
       POP     DE              ;'B'
       EX      (SP),HL         ;'A' <---> Return Address
       LD      IY,0            ;Clear a Pointer
       ADD     IY,SP           ;Make Copy of Stack Pointer
       LD      A,L             ;Move 'A' to Accum.
       XOR     E               ;Xor with 'B'
       LD      (IY+2),A        ;Store function return value
       RET

;
;END Bits.
;
       END                     ;