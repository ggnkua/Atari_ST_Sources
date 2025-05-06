


                                  - 1 -



       A.  AAAAppppppppeeeennnnddddiiiixxxx ffffoooorrrr aaaassss7777000000000000 FFFFrrrraaaannnnkkkkeeeennnnsssstttteeeeiiiinnnn AAAAsssssssseeeemmmmbbbblllleeeerrrr

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

       A.2.1  _D_i_f_f_e_r_e_n_c_e_s__w_i_t_h__t_h_e__T_I__d_e_f_i_n_e_d__S_y_n_t_a_x





































                                  - 2 -



       TI syntax                          as7000 syntax

       op % immediate , register          op # immediate , register
       op % immed , register, jump dest   op # immed , register , jump dest
       op @ label                         op label
       op @ label ( B )                   op expr ( B )
       op *register                       op [ register ]
       movd % immed ( B ) , register      movd # immed (B), register

       Constants

       ?0101010                           %01010101
       >89ab                              $89ab
       ''''                               "'"

       Comments

       after the last operand             everything following a semicolon

       Symbols

       R0-R255                            equ with value between 0 and $ff
       R0-R255                            0 to 255, Not Recommended !
       P0-P255                            equ with value between $100 and $1ff
       P0-P255                            256 to 511, Not Recommended !


       A.2.2  _I_n_s_t_r_u_c_t_i_o_n__L_i_s_t

       Opcode   Syntax                           Selection Criteria


       ADC       '#' expr ',' expr
       ADC       '#' expr ',' expr               DSTA
       ADC       '#' expr ',' expr               DSTB
       ADC       expr ',' expr
       ADC       expr ',' expr                   DSTA
       ADC       expr ',' expr                   DSTB
       ADC       expr ',' expr                   SRCB DSTA

       ADD       '#' expr ',' expr
       ADD       '#' expr ',' expr               DSTA
       ADD       '#' expr ',' expr               DSTB
       ADD       expr ',' expr
       ADD       expr ',' expr                   DSTA
       ADD       expr ',' expr                   DSTB
       ADD       expr ',' expr                   SRCB DSTA

       AND       '#' expr ',' expr
       AND       '#' expr ',' expr               DSTA
       AND       '#' expr ',' expr               DSTB











                                  - 3 -



       Opcode   Syntax                           Selection Criteria

       AND       expr ',' expr
       AND       expr ',' expr                   DSTA
       AND       expr ',' expr                   DSTB
       AND       expr ',' expr                   SRCB DSTA

       ANDP      '#' expr ',' expr
       ANDP      expr ',' expr                   SRCA
       ANDP      expr ',' expr                   SRCB

       BR        '[' expr ']'
       BR        expr '(' REG ')'                SRCB
       BR        expr

       BTJO      '#' expr ',' expr ',' expr
       BTJO      '#' expr ',' expr ',' expr      DSTA
       BTJO      '#' expr ',' expr ',' expr      DSTB
       BTJO      expr ',' expr ',' expr
       BTJO      expr ',' expr ',' expr          DSTA
       BTJO      expr ',' expr ',' expr          DSTB
       BTJO      expr ',' expr ',' expr          SRCB DSTA

       BTJOP     '#' expr ',' expr ',' expr
       BTJOP     expr ',' expr ',' expr          SRCA
       BTJOP     expr ',' expr ',' expr          SRCB

       BTJZ      '#' expr ',' expr ',' expr
       BTJZ      '#' expr ',' expr ',' expr      DSTA
       BTJZ      '#' expr ',' expr ',' expr      DSTB
       BTJZ      expr ',' expr ',' expr
       BTJZ      expr ',' expr ',' expr          DSTA
       BTJZ      expr ',' expr ',' expr          DSTB
       BTJZ      expr ',' expr ',' expr          SRCB DSTA

       BTJZP     '#' expr ',' expr ',' expr
       BTJZP     expr ',' expr ',' expr          SRCA
       BTJZP     expr ',' expr ',' expr          SRCB

       CALL      '[' expr ']'
       CALL      expr '(' REG ')'                SRCB
       CALL      expr

       CLR       expr
       CLR       expr                            DSTA
       CLR       expr                            DSTB

       CLRC

       CMP       '#' expr ',' expr
       CMP       '#' expr ',' expr               DSTA











                                  - 4 -



       Opcode   Syntax                           Selection Criteria

       CMP       '#' expr ',' expr               DSTB
       CMP       expr ',' expr
       CMP       expr ',' expr                   DSTA
       CMP       expr ',' expr                   DSTB
       CMP       expr ',' expr                   SRCB DSTA

       CMPA      '[' expr ']'
       CMPA      expr '(' REG ')'                SRCB
       CMPA      expr

       DAC       '#' expr ',' expr
       DAC       '#' expr ',' expr               DSTA
       DAC       '#' expr ',' expr               DSTB
       DAC       expr ',' expr
       DAC       expr ',' expr                   DSTA
       DAC       expr ',' expr                   DSTB
       DAC       expr ',' expr                   SRCB DSTA

       DEC       expr
       DEC       expr                            DSTA
       DEC       expr                            DSTB

       DECD      expr
       DECD      expr                            DSTA
       DECD      expr                            DSTB

       DINT

       DJNZ      expr ',' expr
       DJNZ      expr ',' expr                   DSTA
       DJNZ      expr ',' expr                   DSTB

       DSB       '#' expr ',' expr
       DSB       '#' expr ',' expr               DSTA
       DSB       '#' expr ',' expr               DSTB
       DSB       expr ',' expr
       DSB       expr ',' expr                   DSTA
       DSB       expr ',' expr                   DSTB
       DSB       expr ',' expr                   SRCB DSTA

       EINT

       IDLE

       INC       expr
       INC       expr                            DSTA
       INC       expr                            DSTB

       INV       expr











                                  - 5 -



       Opcode   Syntax                           Selection Criteria

       INV       expr                            DSTA
       INV       expr                            DSTB

       JC        expr

       JEQ       expr

       JGE       expr

       JGT       expr

       JHS       expr

       JL        expr

       JLT       expr

       JMP       expr

       JN        expr

       JNC       expr

       JNE       expr

       JNZ       expr

       JP        expr

       JPZ       expr

       JZ        expr

       LDA       '[' expr ']'
       LDA       expr '(' REG ')'                SRCB
       LDA       expr

       LDSP

       MOV       '#' expr ',' expr
       MOV       '#' expr ',' expr               DSTA
       MOV       '#' expr ',' expr               DSTB
       MOV       expr ',' expr
       MOV       expr ',' expr                   DSTA
       MOV       expr ',' expr                   DSTB
       MOV       expr ',' expr                   SRCA
       MOV       expr ',' expr                   SRCA DSTB
       MOV       expr ',' expr                   SRCB
       MOV       expr ',' expr                   SRCB DSTA











                                  - 6 -



       Opcode   Syntax                           Selection Criteria


       MOVD      '#' expr '(' REG ')' ',' expr
       MOVD      '#' expr ',' expr
       MOVD      expr ',' expr

       MOVP      '#' expr ',' expr
       MOVP      expr ',' expr                   DSTA
       MOVP      expr ',' expr                   DSTB
       MOVP      expr ',' expr                   SRCA
       MOVP      expr ',' expr                   SRCB

       MPY       '#' expr ',' expr
       MPY       '#' expr ',' expr               DSTA
       MPY       '#' expr ',' expr               DSTB
       MPY       expr ',' expr
       MPY       expr ',' expr                   DSTA
       MPY       expr ',' expr                   DSTB
       MPY       expr ',' expr                   SRCB DSTA

       NOP

       OR        '#' expr ',' expr
       OR        '#' expr ',' expr               DSTA
       OR        '#' expr ',' expr               DSTB
       OR        expr ',' expr
       OR        expr ',' expr                   DSTA
       OR        expr ',' expr                   DSTB
       OR        expr ',' expr                   SRCB DSTA

       ORP       '#' expr ',' expr
       ORP       expr ',' expr                   SRCA
       ORP       expr ',' expr                   SRCB

       POP        STATUS
       POP       expr
       POP       expr                            DSTA
       POP       expr                            DSTB

       PUSH       STATUS
       PUSH      expr
       PUSH      expr                            DSTA
       PUSH      expr                            DSTB

       RETI

       RETS

       RL        expr
       RL        expr                            DSTA











                                  - 7 -



       Opcode   Syntax                           Selection Criteria

       RL        expr                            DSTB

       RLC       expr
       RLC       expr                            DSTA
       RLC       expr                            DSTB

       RR        expr
       RR        expr                            DSTA
       RR        expr                            DSTB

       RRC       expr
       RRC       expr                            DSTA
       RRC       expr                            DSTB

       SBB       '#' expr ',' expr
       SBB       '#' expr ',' expr               DSTA
       SBB       '#' expr ',' expr               DSTB
       SBB       expr ',' expr
       SBB       expr ',' expr                   DSTA
       SBB       expr ',' expr                   DSTB
       SBB       expr ',' expr                   SRCB DSTA

       SETC

       STA       '[' expr ']'
       STA       expr '(' REG ')'                SRCB
       STA       expr

       STSP

       SUB       '#' expr ',' expr
       SUB       '#' expr ',' expr               DSTA
       SUB       '#' expr ',' expr               DSTB
       SUB       expr ',' expr
       SUB       expr ',' expr                   DSTA
       SUB       expr ',' expr                   DSTB
       SUB       expr ',' expr                   SRCB DSTA

       SWAP      expr
       SWAP      expr                            DSTA
       SWAP      expr                            DSTB

       TRAP      expr

       TSTA

       TSTB

       XCHB      expr











                                  - 8 -



       Opcode   Syntax                           Selection Criteria

       XCHB      expr                            DSTA
       XCHB      expr                            DSTB

       XOR       '#' expr ',' expr
       XOR       '#' expr ',' expr               DSTA
       XOR       '#' expr ',' expr               DSTB
       XOR       expr ',' expr
       XOR       expr ',' expr                   DSTA
       XOR       expr ',' expr                   DSTB
       XOR       expr ',' expr                   SRCB DSTA

       XORP      '#' expr ',' expr
       XORP      expr ',' expr                   SRCA
       XORP      expr ',' expr                   SRCB

       A.2.3  _S_e_l_e_c_t_i_o_n__C_r_i_t_e_r_i_a__K_e_y_w_o_r_d_s

            DSTA                The instruction will use a short
                                form if the A register is used as
                                the destination register.

            DSTB                The instruction will use a short
                                form if the B register is used as
                                the destination register.

            SRCA                The instruction will use a short
                                form if the A register is used as
                                the source register.

            SRCB                The instruction will use a short
                                form if the B register is used as
                                the source register.

       A.2.4  _A_p_o_s_t_r_o_p_h_e_s  The apostrophes in the syntax field are
       a notation used for the parser generator and are not put in
       the assembler source statement.

       A.3  NNNNooootttteeeessss

       A.3.1  _R_e_s_e_r_v_e_d__S_y_m_b_o_l_s

       A.3.1.1  _M_a_c_h_i_n_e__D_e_p_e_n_d_e_n_t__R_e_s_e_r_v_e_d__S_y_m_b_o_l_s  A B ST a b st

       A.3.1.2  _S_t_a_n_d_a_r_d__R_e_s_e_r_v_e_d__S_y_m_b_o_l_s  AND DEFINED EQ GE GT
       HIGH LE LOW LT MOD NE NOT OR SHL SHR XOR and defined eq ge
       gt high le low lt mod ne not or shl shr xor


















                                 CONTENTS


       A.  Appendix for as7000 Frankenstein Assembler...........  1
           A.1  Pseudo Operations...............................  1
           A.2  Instructions....................................  1
           A.3  Notes...........................................  8















































                                  - i -




