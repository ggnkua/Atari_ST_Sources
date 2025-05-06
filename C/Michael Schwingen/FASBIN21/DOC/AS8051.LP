


                                  - 1 -



       A.  AAAAppppppppeeeennnnddddiiiixxxx ffffoooorrrr aaaassss8888000055551111 FFFFrrrraaaannnnkkkkeeeennnnsssstttteeeeiiiinnnn AAAAsssssssseeeemmmmbbbblllleeeerrrr

       A.1  PPPPsssseeeeuuuuddddoooo OOOOppppeeeerrrraaaattttiiiioooonnnnssss

       A.1.1  _S_t_a_n_d_a_r_d__P_s_e_u_d_o__O_p_e_r_a_t_i_o_n__M_n_e_m_o_n_i_c_s

            End                                END
            File Inclusion                     INCL INCLUDE
            If                                 IF
            Else                               ELSE
            End If                             ENDI
            Equate                             EQU
            Set                                SET
            Org                                ORG
            Reserve Memory                     RESERVE RMB
            Define Byte Data                   BYTE DB FCB
            Define Word Data                   DW FDB WORD
            Define String Data                 FCC STRING
            Define Character Set Translation   CHARSET
            Define Character Value             CHARDEF CHD
            Use Character Translation          CHARUSE

       A.1.2  _M_a_c_h_i_n_e__D_e_p_e_n_d_e_n_t__P_s_e_u_d_o__O_p_e_r_a_t_i_o_n_s

       A.1.2.1  _D_e_f_i_n_e__W_o_r_d__D_a_t_a  The Define Word Data pseudo-
       operations generate the byte reversed form for 16 bit
       constants.  The first byte is the low order half, followed
       by the high order byte.

       A.2  IIIInnnnssssttttrrrruuuuccccttttiiiioooonnnnssss

       A.2.1  _I_n_s_t_r_u_c_t_i_o_n__L_i_s_t

       Opcode   Syntax                          Selection Criteria


       ACALL    expr

       ADD      A ',' '#' expr
       ADD      A ',' '@' REG                   R01
       ADD      A ',' REG                       R07
       ADD      A ',' expr

       ADDC     A ',' '#' expr
       ADDC     A ',' '@' REG                   R01
       ADDC     A ',' REG                       R07
       ADDC     A ',' expr

       AJMP     expr

       ANL      A ',' '#' expr











                                  - 2 -



       Opcode   Syntax                          Selection Criteria

       ANL      A ',' '@' REG                   R01
       ANL      A ',' REG                       R07
       ANL      A ',' expr
       ANL      C ',' '/' bit
       ANL      C ',' '/' expr
       ANL      C ',' bit
       ANL      C ',' expr
       ANL      expr ',' '#' expr
       ANL      expr ','A

       CJNE     A ',' '#' expr ',' expr
       CJNE     A ',' expr ',' expr
       CJNE     '@' REG ',' '#' expr ',' expr   R01
       CJNE     REG ',' '#' expr ',' expr       R07

       CLR      A
       CLR      C
       CLR      bit
       CLR      expr

       CPL      A
       CPL      C
       CPL      bit
       CPL      expr

       DA       A

       DEC      '@' REG                         R01
       DEC      A
       DEC      REG                             R07
       DEC      expr

       DIV      AB

       DJNZ     REG ',' expr                    R07
       DJNZ     expr ',' expr

       INC      '@' REG                         R01
       INC      A
       INC      DPTR
       INC      REG                             R07
       INC      expr

       JB       bit ',' expr
       JB       expr ',' expr

       JBC      bit ',' expr
       JBC      expr ',' expr












                                  - 3 -



       Opcode   Syntax                          Selection Criteria

       JC       expr

       JMP      '@' A '+' DPTR

       JNB      bit ',' expr
       JNB      expr ',' expr

       JNC      expr

       JNZ      expr

       JZ       expr

       LCALL    expr

       LJMP     expr

       MOV      '@' REG ',' '#' expr            R01
       MOV      '@' REG ',' A                   R01
       MOV      '@' REG ',' expr                R01
       MOV      A ',' '#' expr
       MOV      A ',' '@' REG                   R01
       MOV      A ',' REG                       R07
       MOV      A ',' expr
       MOV      C ',' bit
       MOV      C ',' expr
       MOV      DPTR ',' '#' expr
       MOV      REG ',' A                       R07
       MOV      REG ',' '#' expr                R07
       MOV      REG ',' expr                    R07
       MOV      bit ',' C
       MOV      expr ',' '#' expr
       MOV      expr ',' '@' REG                R01
       MOV      expr ',' A
       MOV      expr ',' C
       MOV      expr ',' REG                    R07
       MOV      expr ',' expr

       MOVC     A ',' '@' A '+' DPTR
       MOVC     A ',' '@' A '+' PC

       MOVX     '@' DPTR ',' A
       MOVX     '@' REG ',' A                   R01
       MOVX     A ',' '@' DPTR
       MOVX     A ',' '@' REG                   R01

       MUL      AB

       NOP











                                  - 4 -



       Opcode   Syntax                          Selection Criteria


       ORL      A ',' '#' expr
       ORL      A ',' '@' REG                   R01
       ORL      A ',' REG                       R07
       ORL      A ',' expr
       ORL      C ',' '/' bit
       ORL      C ',' '/' expr
       ORL      C ',' bit
       ORL      C ',' expr
       ORL      expr ',' '#' expr
       ORL      expr ',' A

       POP      expr

       PUSH     expr

       RET

       RETI

       RL       A

       RLC      A

       RR       A

       RRC      A

       SETB     C
       SETB     bit
       SETB     expr

       SJMP     expr

       SUBB     A ',' '#' expr
       SUBB     A ',' '@' REG                   R01
       SUBB     A ',' REG                       R07
       SUBB     A ',' expr

       SWAP     A

       XCH      A ',' '@' REG                   R01
       XCH      A ',' REG                       R07
       XCH      A ',' expr

       XCHD     A ',' '@' REG                   R01

       XRL      A ',' '#' expr
       XRL      A ',' '@' REG                   R01











                                  - 5 -



       Opcode   Syntax                          Selection Criteria

       XRL      A ',' REG                       R07
       XRL      A ',' expr
       XRL      expr ',' '#' expr
       XRL      expr ',' A

       A.2.2  _S_e_l_e_c_t_i_o_n__C_r_i_t_e_r_i_a__K_e_y_w_o_r_d_s

            R01                 Only the reserved symbols R0 and R1
                                (or r0, r1) are acceptable as the
                                REG operand.

            R07                 All the reserved symbols R0 thru R7
                                are acceptable as the REG operand.

       A.2.3  _B_i_t__O_p_e_r_a_n_d_s  Bit Addresses can be in two forms.

       One form is "expression.constant" where expression gives an
       address for a bit addressable register and constant (in the
       range of 0 to 7) gives the bit number in the byte.
       Expression values must be either in the range of 20h to 2fh,
       or the multiples of 8 between 80h and f8h, and defined in
       the first pass.

       The second form is an symbolic expression with value between
       0 and 255.  The value of the expression is placed in the
       operand field of the instruction without modification.

       A.2.4  _A_p_o_s_t_r_o_p_h_e_s  The apostrophes in the syntax field are
       a notation used for the parser generator and are not put in
       the assembler source statement.

       A.3  NNNNooootttteeeessss

       A.3.1  _A_d_d_r_e_s_s__S_p_a_c_e_s  The Four address spaces, Program
       Memory, Internal Data Memory, Bit Numbers, and External Data
       Memory are not differentiated in the symbol table.  Which
       address space a symbol refers to is determined by the
       context of the instruction operands it appears in.

       A.3.2  _R_e_s_e_r_v_e_d__S_y_m_b_o_l_s

       A.3.2.1  _M_a_c_h_i_n_e__D_e_p_e_n_d_e_n_t__R_e_s_e_r_v_e_d__S_y_m_b_o_l_s  A AB C DPTR PC
       R0 R1 R2 R3 R4 R5 R6 R7 a ab c dptr pc r0 r1 r2 r3 r4 r5 r6
       r7

       A.3.2.2  _S_t_a_n_d_a_r_d__R_e_s_e_r_v_e_d__S_y_m_b_o_l_s  AND DEFINED EQ GE GT
       HIGH LE LOW LT MOD NE NOT OR SHL SHR XOR and defined eq ge
       gt high le low lt mod ne not or shl shr xor
















                                 CONTENTS


       A.  Appendix for as8051 Frankenstein Assembler...........  1
           A.1  Pseudo Operations...............................  1
           A.2  Instructions....................................  1
           A.3  Notes...........................................  5















































                                  - i -




