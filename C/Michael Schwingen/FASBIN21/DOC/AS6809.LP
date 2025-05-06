


                                  - 1 -



       A.  AAAAppppppppeeeennnnddddiiiixxxx ffffoooorrrr aaaassss6666888800009999 FFFFrrrraaaannnnkkkkeeeennnnsssstttteeeeiiiinnnn AAAAsssssssseeeemmmmbbbblllleeeerrrr

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

       A.2  IIIInnnnssssttttrrrruuuuccccttttiiiioooonnnnssss

       A.2.1  _I_n_s_t_r_u_c_t_i_o_n__L_i_s_t

       Opcode   Syntax                   Selection Criteria


       ABX

       ADCA      '#' expr
       ADCA      expr                    DIRECT
       ADCA      expr                    EXTENDED
       ADCA      indexed

       ADCB      '#' expr
       ADCB      expr                    DIRECT
       ADCB      expr                    EXTENDED
       ADCB      indexed

       ADDA      '#' expr
       ADDA      expr                    DIRECT
       ADDA      expr                    EXTENDED
       ADDA      indexed

       ADDB      '#' expr
       ADDB      expr                    DIRECT
       ADDB      expr                    EXTENDED
       ADDB      indexed












                                  - 2 -



       Opcode   Syntax                   Selection Criteria

       ADDD      '#' expr
       ADDD      expr                    DIRECT
       ADDD      expr                    EXTENDED
       ADDD      indexed

       ANDA      '#' expr
       ANDA      expr                    DIRECT
       ANDA      expr                    EXTENDED
       ANDA      indexed

       ANDB      '#' expr
       ANDB      expr                    DIRECT
       ANDB      expr                    EXTENDED
       ANDB      indexed

       ANDCC     '#' expr

       ASL       expr                    DIRECT
       ASL       expr                    EXTENDED
       ASL       indexed

       ASLA

       ASLB

       ASR       expr                    DIRECT
       ASR       expr                    EXTENDED
       ASR       indexed

       ASRA

       ASRB

       BCC       expr

       BCS       expr

       BEQ       expr

       BGE       expr

       BGT       expr

       BHI       expr

       BHS       expr

       BITA      '#' expr
       BITA      expr                    DIRECT











                                  - 3 -



       Opcode   Syntax                   Selection Criteria

       BITA      expr                    EXTENDED
       BITA      indexed

       BITB      '#' expr
       BITB      expr                    DIRECT
       BITB      expr                    EXTENDED
       BITB      indexed

       BLE       expr

       BLO       expr

       BLS       expr

       BLT       expr

       BMI       expr

       BNE       expr

       BPL       expr

       BRA       expr

       BRN       expr

       BSR       expr

       BVC       expr

       BVS       expr

       CLR       expr                    DIRECT
       CLR       expr                    EXTENDED
       CLR       indexed

       CLRA

       CLRB

       CMPA      '#' expr
       CMPA      expr                    DIRECT
       CMPA      expr                    EXTENDED
       CMPA      indexed

       CMPB      '#' expr
       CMPB      expr                    DIRECT
       CMPB      expr                    EXTENDED
       CMPB      indexed











                                  - 4 -



       Opcode   Syntax                   Selection Criteria


       CMPD      '#' expr
       CMPD      expr                    DIRECT
       CMPD      expr                    EXTENDED
       CMPD      indexed

       CMPS      '#' expr
       CMPS      expr                    DIRECT
       CMPS      expr                    EXTENDED
       CMPS      indexed

       CMPU      '#' expr
       CMPU      expr                    DIRECT
       CMPU      expr                    EXTENDED
       CMPU      indexed

       CMPX      '#' expr
       CMPX      expr                    DIRECT
       CMPX      expr                    EXTENDED
       CMPX      indexed

       CMPY      '#' expr
       CMPY      expr                    DIRECT
       CMPY      expr                    EXTENDED
       CMPY      indexed

       COM       expr                    DIRECT
       COM       expr                    EXTENDED
       COM       indexed

       COMA

       COMB

       CWAI      '#' expr

       DAA

       DEC       expr                    DIRECT
       DEC       expr                    EXTENDED
       DEC       indexed

       DECA

       DECB

       EORA      '#' expr
       EORA      expr                    DIRECT
       EORA      expr                    EXTENDED











                                  - 5 -



       Opcode   Syntax                   Selection Criteria

       EORA      indexed

       EORB      '#' expr
       EORB      expr                    DIRECT
       EORB      expr                    EXTENDED
       EORB      indexed

       EXG       register ',' register

       INC       expr                    DIRECT
       INC       expr                    EXTENDED
       INC       indexed

       INCA

       INCB

       JMP       expr                    DIRECT
       JMP       expr                    EXTENDED
       JMP       indexed

       JSR       expr                    DIRECT
       JSR       expr                    EXTENDED
       JSR       indexed

       LBCC      expr

       LBCS      expr

       LBEQ      expr

       LBGE      expr

       LBGT      expr

       LBHI      expr

       LBHS      expr

       LBLE      expr

       LBLO      expr

       LBLS      expr

       LBLT      expr

       LBMI      expr












                                  - 6 -



       Opcode   Syntax                   Selection Criteria

       LBNE      expr

       LBPL      expr

       LBRA      expr

       LBRN      expr

       LBSR      expr

       LBVC      expr

       LBVS      expr

       LDA       '#' expr
       LDA       expr                    DIRECT
       LDA       expr                    EXTENDED
       LDA       indexed

       LDB       '#' expr
       LDB       expr                    DIRECT
       LDB       expr                    EXTENDED
       LDB       indexed

       LDD       '#' expr
       LDD       expr                    DIRECT
       LDD       expr                    EXTENDED
       LDD       indexed

       LDS       '#' expr
       LDS       expr                    DIRECT
       LDS       expr                    EXTENDED
       LDS       indexed

       LDU       '#' expr
       LDU       expr                    DIRECT
       LDU       expr                    EXTENDED
       LDU       indexed

       LDX       '#' expr
       LDX       expr                    DIRECT
       LDX       expr                    EXTENDED
       LDX       indexed

       LDY       '#' expr
       LDY       expr                    DIRECT
       LDY       expr                    EXTENDED
       LDY       indexed












                                  - 7 -



       Opcode   Syntax                   Selection Criteria

       LEAS      indexed

       LEAU      indexed

       LEAX      indexed

       LEAY      indexed

       LSL       expr                    DIRECT
       LSL       expr                    EXTENDED
       LSL       indexed

       LSLA

       LSLB

       LSR       expr                    DIRECT
       LSR       expr                    EXTENDED
       LSR       indexed

       LSRA

       LSRB

       MUL

       NEG       expr                    DIRECT
       NEG       expr                    EXTENDED
       NEG       indexed

       NEGA

       NEGB

       NOP

       ORA       '#' expr
       ORA       expr                    DIRECT
       ORA       expr                    EXTENDED
       ORA       indexed

       ORB       '#' expr
       ORB       expr                    DIRECT
       ORB       expr                    EXTENDED
       ORB       indexed

       ORCC      '#' expr

       PSHS      register list











                                  - 8 -



       Opcode   Syntax                   Selection Criteria


       PSHU      register list

       PULS      register list

       PULU      register list

       ROL       expr                    DIRECT
       ROL       expr                    EXTENDED
       ROL       indexed

       ROLA

       ROLB

       ROR       expr                    DIRECT
       ROR       expr                    EXTENDED
       ROR       indexed

       RORA

       RORB

       RTI

       RTS

       SBCA      '#' expr
       SBCA      expr                    DIRECT
       SBCA      expr                    EXTENDED
       SBCA      indexed

       SBCB      '#' expr
       SBCB      expr                    DIRECT
       SBCB      expr                    EXTENDED
       SBCB      indexed

       SEX

       STA       expr                    DIRECT
       STA       expr                    EXTENDED
       STA       indexed

       STB       expr                    DIRECT
       STB       expr                    EXTENDED
       STB       indexed

       STD       expr                    DIRECT
       STD       expr                    EXTENDED











                                  - 9 -



       Opcode   Syntax                   Selection Criteria

       STD       indexed

       STS       expr                    DIRECT
       STS       expr                    EXTENDED
       STS       indexed

       STU       expr                    DIRECT
       STU       expr                    EXTENDED
       STU       indexed

       STX       expr                    DIRECT
       STX       expr                    EXTENDED
       STX       indexed

       STY       expr                    DIRECT
       STY       expr                    EXTENDED
       STY       indexed

       SUBA      '#' expr
       SUBA      expr                    DIRECT
       SUBA      expr                    EXTENDED
       SUBA      indexed

       SUBB      '#' expr
       SUBB      expr                    DIRECT
       SUBB      expr                    EXTENDED
       SUBB      indexed

       SUBD      '#' expr
       SUBD      expr                    DIRECT
       SUBD      expr                    EXTENDED
       SUBD      indexed

       SWI2

       SWI3

       SWI

       SYNC

       TFR       register ',' register

       TST       expr                    DIRECT
       TST       expr                    EXTENDED
       TST       indexed

       TSTA












                                  - 10 -



       Opcode   Syntax                   Selection Criteria

       TSTB

       A.2.2  _O_p_e_r_a_n_d__T_y_p_e_s

       A.2.2.1  _r_e_g_i_s_t_e_r__l_i_s_t  The operands for the push and pull
       operations consist of a list of one or more registers
       seperated by commas.  The stack pointer associated with an
       operator will give an error if it occurs in the list.  The
       registers can be D, X, Y, U, S, PC, A, B, CC, DP and their
       lower case equivalents.  For the push and pull operations,
       the D register is an alias for the A and B registers, and
       will result in two selection bits set in the postbyte.

       A.2.2.2  _i_n_d_e_x_e_d  The indexed mode operands are in the
       forms.

            , index
            expr , index
            accumulator , index
            , index +
            , index ++
            , - index
            , -- index
            expr , PCR
            [ , index ]
            [ expr , index ]
            [ accumulator , index ]
            [ , index ++ ]
            [ , -- index ]
            [ expr , PCR ]
            [ expr ]

       Index can be any of X, Y, S, U (or their lower case
       equivalents). Accumulator can be any of A, B, D (or their
       lower case equivalents).

       The short offset forms will only be used if the expression
       in the operand has a value defined at the first pass, and
       the value is small enough to fit.  Expressions that have an
       as yet undefined value will use the 16 bit offset form.

       A.2.3  _S_e_l_e_c_t_i_o_n__C_r_i_t_e_r_i_a__K_e_y_w_o_r_d_s

            DIRECT              The instruction can use the direct
                                addressing mode. The expression
                                must have a value between 0 and 255
                                that is defined when the
                                instruction is processed in the
                                input pass.











                                  - 11 -



            EXTENDED            The instruction can use the
                                extended addressing mode.

       A.2.4  _A_p_o_s_t_r_o_p_h_e_s  The apostrophes in the syntax field are
       a notation used for the parser generator and are not put in
       the assembler source statement.

       A.3  NNNNooootttteeeessss

       A.3.1  _R_e_s_e_r_v_e_d__S_y_m_b_o_l_s

       A.3.1.1  _M_a_c_h_i_n_e__D_e_p_e_n_d_e_n_t__R_e_s_e_r_v_e_d__S_y_m_b_o_l_s  A B CC D DP PC
       PCR S U X Y a b cc d dp pc pcr s u x y

       A.3.1.2  _S_t_a_n_d_a_r_d__R_e_s_e_r_v_e_d__S_y_m_b_o_l_s  AND DEFINED EQ GE GT
       HIGH LE LOW LT MOD NE NOT OR SHL SHR XOR and defined eq ge
       gt high le low lt mod ne not or shl shr xor

















































                                 CONTENTS


       A.  Appendix for as6809 Frankenstein Assembler..........   1
           A.1  Pseudo Operations..............................   1
           A.2  Instructions...................................   1
           A.3  Notes..........................................  11















































                                  - i -




