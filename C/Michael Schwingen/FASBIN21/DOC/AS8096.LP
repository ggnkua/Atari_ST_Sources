


                                  - 1 -



       A.  AAAAppppppppeeeennnnddddiiiixxxx ffffoooorrrr aaaassss8888000099996666 FFFFrrrraaaannnnkkkkeeeennnnsssstttteeeeiiiinnnn AAAAsssssssseeeemmmmbbbblllleeeerrrr

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
            Reserve Memory                     DSB RESERVE RMB
            Define Byte Data                   BYTE DCB FCB
            Define String Data                 FCC STRING
            Define Character Set Translation   CHARSET
            Define Character Value             CHARDEF CHD
            Use Character Translation          CHARUSE

       A.1.2  _M_a_c_h_i_n_e__D_e_p_e_n_d_e_n_t__P_s_e_u_d_o__O_p_e_r_a_t_i_o_n_s

       A.1.2.1  _D_e_f_i_n_e__W_o_r_d__D_a_t_a_,__A_l_i_g_n_e_d

            [Label]  WORD  expression [, expression] ...
            [Label]  FDB   expression [, expression] ...
            [Label]  DCW  expression [, expression] ...

       The define word statement generates a two byte integer for
       each expression in the expression list.  There can be up to
       128 expressions on a line, more than the line length will
       allow.  The location counter is adjusted by skipping bytes
       to make the first location address divisible by 2.  The
       generated constants are in byte reversed order, with the low
       order byte first, followed by the high order byte.  The
       optional label is set to the first location of this area.

       A.1.2.2  _D_e_f_i_n_e__L_o_n_g__W_o_r_d__D_a_t_a_,__A_l_i_g_n_e_d

            [Label]  LONG  expression [, expression] ...
            [Label]  DCL  expression [, expression] ...

       The define long word statement generates a four byte integer
       for each expression in the expression list.  There can be up
       to 128 expressions on a line, more than the line length will
       allow.  The location counter is adjusted by skipping bytes
       to make the first location address divisible by 4.  The
       generated constants are in byte reversed order, with the low
       order byte first, followed by the high order bytes.  The
       optional label is set to the first location of this area.











                                  - 2 -



       A.1.2.3  _R_e_s_e_r_v_e__M_e_m_o_r_y_,__W_o_r_d__A_l_i_g_n_e_d

            [Label] DSW expression

       This statement moves the location counter forward by the
       number of bytes specified in the expression.  The location
       counter is adjusted by skipping bytes to make the first
       location address divisible by 2.  The label is set to the
       first location of this area.

       A.1.2.4  _R_e_s_e_r_v_e__M_e_m_o_r_y_,__L_o_n_g__W_o_r_d__A_l_i_g_n_e_d

            [Label] DSL expression

       This statement moves the location counter forward by the
       number of long words specified in the expression.  The
       location counter is adjusted by skipping bytes to make the
       first location address divisible by 4.  The label is set to
       the first location of this area.

       A.1.2.5  _I_n_s_t_r_u_c_t_i_o_n__S_e_t__S_e_l_e_c_t_i_o_n

            CPU string

       The instruction set can be specified in the source file with
       the CPU pseudooperation.  The string, delimited by quotes or
       apostrophes, is scanned for a substring which selects which
       instruction set is used.  When the program is invoked, this
       operation is performed on the name of the program, then the
       -p optional arguement, if any, and then any CPU statements.
       The last one selects which subset of the instructions the
       assembler will accept.  The instruction set can be changed
       at any place in the source file.

            Instruction Set          Substrings
            80c196                   19
            8096                     9

       A.2  IIIInnnnssssttttrrrruuuuccccttttiiiioooonnnnssss

       A.2.1  _I_n_s_t_r_u_c_t_i_o_n__L_i_s_t

       Opcode   Syntax                                 Selection Criteria


       ADD       expr ',' '#' expr
       ADD       expr ',' '[' expr ']'
       ADD       expr ',' expr ',' '#' expr
       ADD       expr ',' expr ',' '[' expr ']'
       ADD       expr ',' expr ',' expr '[' expr ']'   DIRECT
       ADD       expr ',' expr ',' expr '[' expr ']'   EXTENDED











                                  - 3 -



       Opcode   Syntax                                 Selection Criteria

       ADD       expr ',' expr ',' expr                DIRECT
       ADD       expr ',' expr ',' expr                EXTENDED
       ADD       expr ',' expr '[' expr ']'            DIRECT
       ADD       expr ',' expr '[' expr ']'            EXTENDED
       ADD       expr ',' expr                         DIRECT
       ADD       expr ',' expr                         EXTENDED

       ADDB      expr ',' '#' expr
       ADDB      expr ',' '[' expr ']'
       ADDB      expr ',' expr ',' '#' expr
       ADDB      expr ',' expr ',' '[' expr ']'
       ADDB      expr ',' expr ',' expr '[' expr ']'   DIRECT
       ADDB      expr ',' expr ',' expr '[' expr ']'   EXTENDED
       ADDB      expr ',' expr ',' expr                DIRECT
       ADDB      expr ',' expr ',' expr                EXTENDED
       ADDB      expr ',' expr '[' expr ']'            DIRECT
       ADDB      expr ',' expr '[' expr ']'            EXTENDED
       ADDB      expr ',' expr                         DIRECT
       ADDB      expr ',' expr                         EXTENDED

       ADDC      expr ',' '#' expr
       ADDC      expr ',' '[' expr ']'
       ADDC      expr ',' expr '[' expr ']'            DIRECT
       ADDC      expr ',' expr '[' expr ']'            EXTENDED
       ADDC      expr ',' expr                         DIRECT
       ADDC      expr ',' expr                         EXTENDED

       ADDCB     expr ',' '#' expr
       ADDCB     expr ',' '[' expr ']'
       ADDCB     expr ',' expr '[' expr ']'            DIRECT
       ADDCB     expr ',' expr '[' expr ']'            EXTENDED
       ADDCB     expr ',' expr                         DIRECT
       ADDCB     expr ',' expr                         EXTENDED

       AND       expr ',' '#' expr
       AND       expr ',' '[' expr ']'
       AND       expr ',' expr ',' '#' expr
       AND       expr ',' expr ',' '[' expr ']'
       AND       expr ',' expr ',' expr '[' expr ']'   DIRECT
       AND       expr ',' expr ',' expr '[' expr ']'   EXTENDED
       AND       expr ',' expr ',' expr                DIRECT
       AND       expr ',' expr ',' expr                EXTENDED
       AND       expr ',' expr '[' expr ']'            DIRECT
       AND       expr ',' expr '[' expr ']'            EXTENDED
       AND       expr ',' expr                         DIRECT
       AND       expr ',' expr                         EXTENDED

       ANDB      expr ',' '#' expr
       ANDB      expr ',' '[' expr ']'











                                  - 4 -



       Opcode   Syntax                                 Selection Criteria

       ANDB      expr ',' expr ',' '#' expr
       ANDB      expr ',' expr ',' '[' expr ']'
       ANDB      expr ',' expr ',' expr '[' expr ']'   DIRECT
       ANDB      expr ',' expr ',' expr '[' expr ']'   EXTENDED
       ANDB      expr ',' expr ',' expr                DIRECT
       ANDB      expr ',' expr ',' expr                EXTENDED
       ANDB      expr ',' expr '[' expr ']'            DIRECT
       ANDB      expr ',' expr '[' expr ']'            EXTENDED
       ANDB      expr ',' expr                         DIRECT
       ANDB      expr ',' expr                         EXTENDED

       BMOV      expr ',' expr                         CPU196

       BR        '[' expr ']'

       CLR       expr

       CLRB      expr

       CLRC

       CLRVT

       CMP       expr ',' '#' expr
       CMP       expr ',' '[' expr ']'
       CMP       expr ',' expr '[' expr ']'            DIRECT
       CMP       expr ',' expr '[' expr ']'            EXTENDED
       CMP       expr ',' expr                         DIRECT
       CMP       expr ',' expr                         EXTENDED

       CMPB      expr ',' '#' expr
       CMPB      expr ',' '[' expr ']'
       CMPB      expr ',' expr '[' expr ']'            DIRECT
       CMPB      expr ',' expr '[' expr ']'            EXTENDED
       CMPB      expr ',' expr                         DIRECT
       CMPB      expr ',' expr                         EXTENDED

       CMPL      expr ',' expr                         CPU196

       DEC       expr

       DECB      expr

       DI

       DIV       expr ',' '#' expr
       DIV       expr ',' '[' expr ']'
       DIV       expr ',' expr '[' expr ']'            DIRECT
       DIV       expr ',' expr '[' expr ']'            EXTENDED











                                  - 5 -



       Opcode   Syntax                                 Selection Criteria

       DIV       expr ',' expr                         DIRECT
       DIV       expr ',' expr                         EXTENDED

       DIVB      expr ',' '#' expr
       DIVB      expr ',' '[' expr ']'
       DIVB      expr ',' expr '[' expr ']'            DIRECT
       DIVB      expr ',' expr '[' expr ']'            EXTENDED
       DIVB      expr ',' expr                         DIRECT
       DIVB      expr ',' expr                         EXTENDED

       DIVU      expr ',' '#' expr
       DIVU      expr ',' '[' expr ']'
       DIVU      expr ',' expr '[' expr ']'            DIRECT
       DIVU      expr ',' expr '[' expr ']'            EXTENDED
       DIVU      expr ',' expr                         DIRECT
       DIVU      expr ',' expr                         EXTENDED

       DIVUB     expr ',' '#' expr
       DIVUB     expr ',' '[' expr ']'
       DIVUB     expr ',' expr '[' expr ']'            DIRECT
       DIVUB     expr ',' expr '[' expr ']'            EXTENDED
       DIVUB     expr ',' expr                         DIRECT
       DIVUB     expr ',' expr                         EXTENDED

       DJNZ      expr ',' expr

       DJNZW     expr ',' expr                         CPU196

       EI

       EXT       expr

       EXTB      expr

       IDLPD     '#' expr                              CPU196

       INC       expr

       INCB      expr

       JBC       expr ',' expr ',' expr

       JBS       expr ',' expr ',' expr

       JC        expr

       JE        expr

       JGE       expr











                                  - 6 -



       Opcode   Syntax                                 Selection Criteria


       JGT       expr

       JH        expr

       JLE       expr

       JLT       expr

       JNC       expr

       JNE       expr

       JNH       expr

       JNST      expr

       JNV       expr

       JNVT      expr

       JST       expr

       JV        expr

       JVT       expr

       LCALL     expr

       LD        expr ',' '#' expr
       LD        expr ',' '[' expr ']'
       LD        expr ',' expr '[' expr ']'            DIRECT
       LD        expr ',' expr '[' expr ']'            EXTENDED
       LD        expr ',' expr                         DIRECT
       LD        expr ',' expr                         EXTENDED

       LDB       expr ',' '#' expr
       LDB       expr ',' '[' expr ']'
       LDB       expr ',' expr '[' expr ']'            DIRECT
       LDB       expr ',' expr '[' expr ']'            EXTENDED
       LDB       expr ',' expr                         DIRECT
       LDB       expr ',' expr                         EXTENDED

       LDBSE     expr ',' '#' expr
       LDBSE     expr ',' '[' expr ']'
       LDBSE     expr ',' expr '[' expr ']'            DIRECT
       LDBSE     expr ',' expr '[' expr ']'            EXTENDED
       LDBSE     expr ',' expr                         DIRECT
       LDBSE     expr ',' expr                         EXTENDED











                                  - 7 -



       Opcode   Syntax                                 Selection Criteria


       LDBZE     expr ',' '#' expr
       LDBZE     expr ',' '[' expr ']'
       LDBZE     expr ',' expr '[' expr ']'            DIRECT
       LDBZE     expr ',' expr '[' expr ']'            EXTENDED
       LDBZE     expr ',' expr                         DIRECT
       LDBZE     expr ',' expr                         EXTENDED

       LJMP      expr

       MUL       expr ',' '#' expr
       MUL       expr ',' '[' expr ']'
       MUL       expr ',' expr ',' '#' expr
       MUL       expr ',' expr ',' '[' expr ']'
       MUL       expr ',' expr ',' expr '[' expr ']'   DIRECT
       MUL       expr ',' expr ',' expr '[' expr ']'   EXTENDED
       MUL       expr ',' expr ',' expr                DIRECT
       MUL       expr ',' expr ',' expr                EXTENDED
       MUL       expr ',' expr '[' expr ']'            DIRECT
       MUL       expr ',' expr '[' expr ']'            EXTENDED
       MUL       expr ',' expr                         DIRECT
       MUL       expr ',' expr                         EXTENDED

       MULB      expr ',' '#' expr
       MULB      expr ',' '[' expr ']'
       MULB      expr ',' expr ',' '#' expr
       MULB      expr ',' expr ',' '[' expr ']'
       MULB      expr ',' expr ',' expr '[' expr ']'   DIRECT
       MULB      expr ',' expr ',' expr '[' expr ']'   EXTENDED
       MULB      expr ',' expr ',' expr                DIRECT
       MULB      expr ',' expr ',' expr                EXTENDED
       MULB      expr ',' expr '[' expr ']'            DIRECT
       MULB      expr ',' expr '[' expr ']'            EXTENDED
       MULB      expr ',' expr                         DIRECT
       MULB      expr ',' expr                         EXTENDED

       MULU      expr ',' '#' expr
       MULU      expr ',' '[' expr ']'
       MULU      expr ',' expr ',' '#' expr
       MULU      expr ',' expr ',' '[' expr ']'
       MULU      expr ',' expr ',' expr '[' expr ']'   DIRECT
       MULU      expr ',' expr ',' expr '[' expr ']'   EXTENDED
       MULU      expr ',' expr ',' expr                DIRECT
       MULU      expr ',' expr ',' expr                EXTENDED
       MULU      expr ',' expr '[' expr ']'            DIRECT
       MULU      expr ',' expr '[' expr ']'            EXTENDED
       MULU      expr ',' expr                         DIRECT
       MULU      expr ',' expr                         EXTENDED












                                  - 8 -



       Opcode   Syntax                                 Selection Criteria

       MULUB     expr ',' '#' expr
       MULUB     expr ',' '[' expr ']'
       MULUB     expr ',' expr ',' '#' expr
       MULUB     expr ',' expr ',' '[' expr ']'
       MULUB     expr ',' expr ',' expr '[' expr ']'   DIRECT
       MULUB     expr ',' expr ',' expr '[' expr ']'   EXTENDED
       MULUB     expr ',' expr ',' expr                DIRECT
       MULUB     expr ',' expr ',' expr                EXTENDED
       MULUB     expr ',' expr '[' expr ']'            DIRECT
       MULUB     expr ',' expr '[' expr ']'            EXTENDED
       MULUB     expr ',' expr                         DIRECT
       MULUB     expr ',' expr                         EXTENDED

       NEG       expr

       NEGB      expr

       NOP

       NORML     expr ',' expr

       NOT       expr

       NOTB      expr

       OR        expr ',' '#' expr
       OR        expr ',' '[' expr ']'
       OR        expr ',' expr '[' expr ']'            DIRECT
       OR        expr ',' expr '[' expr ']'            EXTENDED
       OR        expr ',' expr                         DIRECT
       OR        expr ',' expr                         EXTENDED

       ORB       expr ',' '#' expr
       ORB       expr ',' '[' expr ']'
       ORB       expr ',' expr '[' expr ']'            DIRECT
       ORB       expr ',' expr '[' expr ']'            EXTENDED
       ORB       expr ',' expr                         DIRECT
       ORB       expr ',' expr                         EXTENDED

       POP       '[' expr ']'
       POP       expr '[' expr ']'                     DIRECT
       POP       expr '[' expr ']'                     EXTENDED
       POP       expr                                  DIRECT
       POP       expr                                  EXTENDED

       POPA                                            CPU196

       POPF












                                  - 9 -



       Opcode   Syntax                                 Selection Criteria

       PUSH      '#' expr
       PUSH      '[' expr ']'
       PUSH      expr '[' expr ']'                     DIRECT
       PUSH      expr '[' expr ']'                     EXTENDED
       PUSH      expr                                  DIRECT
       PUSH      expr                                  EXTENDED

       PUSHA                                           CPU196

       PUSHF

       RET

       RST

       SCALL     expr

       SETC

       SHL       expr ',' '#' expr
       SHL       expr ',' expr

       SHLB      expr ',' '#' expr
       SHLB      expr ',' expr

       SHLL      expr ',' '#' expr
       SHLL      expr ',' expr

       SHR       expr ',' '#' expr
       SHR       expr ',' expr

       SHRA      expr ',' '#' expr
       SHRA      expr ',' expr

       SHRAB     expr ',' '#' expr
       SHRAB     expr ',' expr

       SHRAL     expr ',' '#' expr
       SHRAL     expr ',' expr

       SHRB      expr ',' '#' expr
       SHRB      expr ',' expr

       SHRL      expr ',' '#' expr
       SHRL      expr ',' expr

       SJMP      expr

       SKIP      expr











                                  - 10 -



       Opcode   Syntax                                 Selection Criteria


       ST        expr ',' '[' expr ']'
       ST        expr ',' expr '[' expr ']'            DIRECT
       ST        expr ',' expr '[' expr ']'            EXTENDED
       ST        expr ',' expr                         DIRECT
       ST        expr ',' expr                         EXTENDED

       STB       expr ',' '[' expr ']'
       STB       expr ',' expr '[' expr ']'            DIRECT
       STB       expr ',' expr '[' expr ']'            EXTENDED
       STB       expr ',' expr                         DIRECT
       STB       expr ',' expr                         EXTENDED

       SUB       expr ',' '#' expr
       SUB       expr ',' '[' expr ']'
       SUB       expr ',' expr ',' '#' expr
       SUB       expr ',' expr ',' '[' expr ']'
       SUB       expr ',' expr ',' expr '[' expr ']'   DIRECT
       SUB       expr ',' expr ',' expr '[' expr ']'   EXTENDED
       SUB       expr ',' expr ',' expr                DIRECT
       SUB       expr ',' expr ',' expr                EXTENDED
       SUB       expr ',' expr '[' expr ']'            DIRECT
       SUB       expr ',' expr '[' expr ']'            EXTENDED
       SUB       expr ',' expr                         DIRECT
       SUB       expr ',' expr                         EXTENDED

       SUBB      expr ',' '#' expr
       SUBB      expr ',' '[' expr ']'
       SUBB      expr ',' expr ',' '#' expr
       SUBB      expr ',' expr ',' '[' expr ']'
       SUBB      expr ',' expr ',' expr '[' expr ']'   DIRECT
       SUBB      expr ',' expr ',' expr '[' expr ']'   EXTENDED
       SUBB      expr ',' expr ',' expr                DIRECT
       SUBB      expr ',' expr ',' expr                EXTENDED
       SUBB      expr ',' expr '[' expr ']'            DIRECT
       SUBB      expr ',' expr '[' expr ']'            EXTENDED
       SUBB      expr ',' expr                         DIRECT
       SUBB      expr ',' expr                         EXTENDED

       SUBC      expr ',' '#' expr
       SUBC      expr ',' '[' expr ']'
       SUBC      expr ',' expr '[' expr ']'            DIRECT
       SUBC      expr ',' expr '[' expr ']'            EXTENDED
       SUBC      expr ',' expr                         DIRECT
       SUBC      expr ',' expr                         EXTENDED

       SUBCB     expr ',' '#' expr
       SUBCB     expr ',' '[' expr ']'
       SUBCB     expr ',' expr '[' expr ']'            DIRECT











                                  - 11 -



       Opcode   Syntax                                 Selection Criteria

       SUBCB     expr ',' expr '[' expr ']'            EXTENDED
       SUBCB     expr ',' expr                         DIRECT
       SUBCB     expr ',' expr                         EXTENDED

       XOR       expr ',' '#' expr
       XOR       expr ',' '[' expr ']'
       XOR       expr ',' expr '[' expr ']'            DIRECT
       XOR       expr ',' expr '[' expr ']'            EXTENDED
       XOR       expr ',' expr                         DIRECT
       XOR       expr ',' expr                         EXTENDED

       XORB      expr ',' '#' expr
       XORB      expr ',' '[' expr ']'
       XORB      expr ',' expr '[' expr ']'            DIRECT
       XORB      expr ',' expr '[' expr ']'            EXTENDED
       XORB      expr ',' expr                         DIRECT
       XORB      expr ',' expr                         EXTENDED

       A.2.2  _S_e_l_e_c_t_i_o_n__C_r_i_t_e_r_i_a__K_e_y_w_o_r_d_s

            DIRECT              The instruction will be generated
                                with a short form if the last
                                operand will fit in one byte, and
                                is defined when the instruction is
                                processed in the first pass.

            EXTENDED            The instruction can be generated
                                with a long form.

            CPU196              The instruction is implemented only
                                in the 80c196.

       A.2.3  _A_p_o_s_t_r_o_p_h_e_s  The apostrophes in the syntax field are
       a notation used for the parser generator and are not put in
       the assembler source statement.

       A.3  NNNNooootttteeeessss

       A.3.1  _D_a_t_a__A_l_i_g_n_m_e_n_t  In the second pass, data address are
       checked for alignment.  If the operand field is not
       divisible by 2 for word references, or by 4 for long word
       references, the error message "expression fails validity
       test" occurs.

       A.3.2  _G_e_n_e_r_i_c__J_u_m_p_s  The assembler requires that the length
       of an instruction be able to be determined at the first
       pass, so generalized generic jumps could not be implemented.













                                  - 12 -



       A.3.3  _R_e_s_e_r_v_e_d__S_y_m_b_o_l_s

       A.3.3.1  _S_t_a_n_d_a_r_d__R_e_s_e_r_v_e_d__S_y_m_b_o_l_s  AND DEFINED EQ GE GT
       HIGH LE LOW LT MOD NE NOT OR SHL SHR XOR and defined eq ge
       gt high le low lt mod ne not or shl shr xor





























































                                 CONTENTS


       A.  Appendix for as8096 Frankenstein Assembler..........   1
           A.1  Pseudo Operations..............................   1
           A.2  Instructions...................................   2
           A.3  Notes..........................................  11















































                                  - i -




