


                                  - 1 -



       A.  AAAAppppppppeeeennnnddddiiiixxxx ffffoooorrrr aaaassss6666555500002222 FFFFrrrraaaannnnkkkkeeeennnnsssstttteeeeiiiinnnn AAAAsssssssseeeemmmmbbbblllleeeerrrr

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

       A.1.2.1  _D_e_f_i_n_e__W_o_r_d__D_a_t_a  The define word pseudo-operations
       generates the byte reversed (low byte, high byte)
       representation.

       A.1.2.2  _I_n_s_t_r_u_c_t_i_o_n__S_e_t__S_e_l_e_c_t_i_o_n

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
            ROCKWELL CMOS            R65C r65c
            CMOS                     65C 65c
            ROCKWELL Extended        R65 r65
            R65C00/21                21
            Standard NMOS            65













                                  - 2 -



       A.2  IIIInnnnssssttttrrrruuuuccccttttiiiioooonnnnssss

       A.2.1  _I_n_s_t_r_u_c_t_i_o_n__L_i_s_t

       Opcode   Syntax                       Selection Criteria


       ADC       '#' topexpr
       ADC       '(' topexpr ')' ',' INDEX   DIRECT INDEXY
       ADC       '(' topexpr ')'             DIRECT INSTCMOS
       ADC       '(' topexpr ',' INDEX ')'   DIRECT INDEXX
       ADC       topexpr ',' INDEX           DIRECT INDEXX
       ADC       topexpr ',' INDEX           EXTENDED INDEXX
       ADC       topexpr ',' INDEX           INDEXY
       ADC       topexpr                     DIRECT
       ADC       topexpr                     EXTENDED

       AND       '#' topexpr
       AND       '(' topexpr ')' ',' INDEX   DIRECT INDEXY
       AND       '(' topexpr ')'             DIRECT INSTCMOS
       AND       '(' topexpr ',' INDEX ')'   DIRECT INDEXX
       AND       topexpr ',' INDEX           DIRECT INDEXX
       AND       topexpr ',' INDEX           EXTENDED INDEXX
       AND       topexpr ',' INDEX           INDEXY
       AND       topexpr                     DIRECT
       AND       topexpr                     EXTENDED

       ASL       ACCUM
       ASL       topexpr ',' INDEX           DIRECT INDEXX
       ASL       topexpr ',' INDEX           EXTENDED INDEXX
       ASL       topexpr                     DIRECT
       ASL       topexpr                     EXTENDED

       BBR0      topexpr ',' topexpr         INSTROCKWELL

       BBR1      topexpr ',' topexpr         INSTROCKWELL

       BBR2      topexpr ',' topexpr         INSTROCKWELL

       BBR3      topexpr ',' topexpr         INSTROCKWELL

       BBR4      topexpr ',' topexpr         INSTROCKWELL

       BBR5      topexpr ',' topexpr         INSTROCKWELL

       BBR6      topexpr ',' topexpr         INSTROCKWELL

       BBR7      topexpr ',' topexpr         INSTROCKWELL

       BBS0      topexpr ',' topexpr         INSTROCKWELL












                                  - 3 -



       Opcode   Syntax                       Selection Criteria

       BBS1      topexpr ',' topexpr         INSTROCKWELL

       BBS2      topexpr ',' topexpr         INSTROCKWELL

       BBS3      topexpr ',' topexpr         INSTROCKWELL

       BBS4      topexpr ',' topexpr         INSTROCKWELL

       BBS5      topexpr ',' topexpr         INSTROCKWELL

       BBS6      topexpr ',' topexpr         INSTROCKWELL

       BBS7      topexpr ',' topexpr         INSTROCKWELL

       BCC       topexpr

       BCS       topexpr

       BEQ       topexpr

       BGE       topexpr

       BIT       '#' topexpr                 INSTCMOS
       BIT       topexpr ',' INDEX           DIRECT INDEXX INSTCMOS
       BIT       topexpr ',' INDEX           EXTENDED INDEXX INSTCMOS
       BIT       topexpr                     DIRECT
       BIT       topexpr                     EXTENDED

       BLT       topexpr

       BMI       topexpr

       BNE       topexpr

       BPL       topexpr

       BRA       topexpr                     INST21
       BRA       topexpr                     INSTCMOS

       BRK       '#' topexpr
       BRK

       BVC       topexpr

       BVS       topexpr

       CLC

       CLD











                                  - 4 -



       Opcode   Syntax                       Selection Criteria


       CLI

       CLV

       CMP       '#' topexpr
       CMP       '(' topexpr ')' ',' INDEX   DIRECT INDEXY
       CMP       '(' topexpr ')'             DIRECT INSTCMOS
       CMP       '(' topexpr ',' INDEX ')'   DIRECT INDEXX
       CMP       topexpr ',' INDEX           DIRECT INDEXX
       CMP       topexpr ',' INDEX           EXTENDED INDEXX
       CMP       topexpr ',' INDEX           INDEXY
       CMP       topexpr                     DIRECT
       CMP       topexpr                     EXTENDED

       CPX       '#' topexpr
       CPX       topexpr                     DIRECT
       CPX       topexpr                     EXTENDED

       CPY       '#' topexpr
       CPY       topexpr                     DIRECT
       CPY       topexpr                     EXTENDED

       DEC       ACCUM                       INSTCMOS
       DEC       topexpr ',' INDEX           DIRECT INDEXX
       DEC       topexpr ',' INDEX           EXTENDED INDEXX
       DEC       topexpr                     DIRECT
       DEC       topexpr                     EXTENDED

       DEX

       DEY

       EOR       '#' topexpr
       EOR       '(' topexpr ')' ',' INDEX   DIRECT INDEXY
       EOR       '(' topexpr ')'             DIRECT INSTCMOS
       EOR       '(' topexpr ',' INDEX ')'   DIRECT INDEXX
       EOR       topexpr ',' INDEX           DIRECT INDEXX
       EOR       topexpr ',' INDEX           EXTENDED INDEXX
       EOR       topexpr ',' INDEX           INDEXY
       EOR       topexpr                     DIRECT
       EOR       topexpr                     EXTENDED

       INC       ACCUM                       INSTCMOS
       INC       topexpr ',' INDEX           DIRECT INDEXX
       INC       topexpr ',' INDEX           EXTENDED INDEXX
       INC       topexpr                     DIRECT
       INC       topexpr                     EXTENDED












                                  - 5 -



       Opcode   Syntax                       Selection Criteria

       INX

       INY

       JMP       '(' topexpr ')'
       JMP       '(' topexpr ',' INDEX ')'   INSTCMOS INDEXX
       JMP       topexpr

       JSR       topexpr

       LDA       '#' topexpr
       LDA       '(' topexpr ')' ',' INDEX   DIRECT INDEXY
       LDA       '(' topexpr ')'             DIRECT INSTCMOS
       LDA       '(' topexpr ',' INDEX ')'   DIRECT INDEXX
       LDA       topexpr ',' INDEX           DIRECT INDEXX
       LDA       topexpr ',' INDEX           EXTENDED INDEXX
       LDA       topexpr ',' INDEX           INDEXY
       LDA       topexpr                     DIRECT
       LDA       topexpr                     EXTENDED

       LDX       '#' topexpr
       LDX       topexpr ',' INDEX           DIRECT INDEXY
       LDX       topexpr ',' INDEX           EXTENDED INDEXY
       LDX       topexpr                     DIRECT
       LDX       topexpr                     EXTENDED

       LDY       '#' topexpr
       LDY       topexpr ',' INDEX           DIRECT INDEXX
       LDY       topexpr ',' INDEX           EXTENDED INDEXX
       LDY       topexpr                     DIRECT
       LDY       topexpr                     EXTENDED

       LSR       ACCUM
       LSR       topexpr ',' INDEX           DIRECT INDEXX
       LSR       topexpr ',' INDEX           EXTENDED INDEXX
       LSR       topexpr                     DIRECT
       LSR       topexpr                     EXTENDED

       MUL                                   INST21

       NOP

       ORA       '#' topexpr
       ORA       '(' topexpr ')' ',' INDEX   DIRECT INDEXY
       ORA       '(' topexpr ')'             DIRECT INSTCMOS
       ORA       '(' topexpr ',' INDEX ')'   DIRECT INDEXX
       ORA       topexpr ',' INDEX           DIRECT INDEXX
       ORA       topexpr ',' INDEX           EXTENDED INDEXX
       ORA       topexpr ',' INDEX           INDEXY











                                  - 6 -



       Opcode   Syntax                       Selection Criteria

       ORA       topexpr                     DIRECT
       ORA       topexpr                     EXTENDED

       PHA

       PHP

       PHX                                   INST21
       PHX                                   INSTCMOS

       PHY                                   INST21
       PHY                                   INSTCMOS

       PLA

       PLP

       PLX                                   INST21
       PLX                                   INSTCMOS

       PLY                                   INST21
       PLY                                   INSTCMOS

       RMB0      topexpr                     INSTROCKWELL

       RMB1      topexpr                     INSTROCKWELL

       RMB2      topexpr                     INSTROCKWELL

       RMB3      topexpr                     INSTROCKWELL

       RMB4      topexpr                     INSTROCKWELL

       RMB5      topexpr                     INSTROCKWELL

       RMB6      topexpr                     INSTROCKWELL

       RMB7      topexpr                     INSTROCKWELL

       ROL       ACCUM
       ROL       topexpr ',' INDEX           DIRECT INDEXX
       ROL       topexpr ',' INDEX           EXTENDED INDEXX
       ROL       topexpr                     DIRECT
       ROL       topexpr                     EXTENDED

       ROR       ACCUM
       ROR       topexpr ',' INDEX           DIRECT INDEXX
       ROR       topexpr ',' INDEX           EXTENDED INDEXX
       ROR       topexpr                     DIRECT











                                  - 7 -



       Opcode   Syntax                       Selection Criteria

       ROR       topexpr                     EXTENDED

       RTI

       RTS

       SBC       '#' topexpr
       SBC       '(' topexpr ')' ',' INDEX   DIRECT INDEXY
       SBC       '(' topexpr ')'             DIRECT INSTCMOS
       SBC       '(' topexpr ',' INDEX ')'   DIRECT INDEXX
       SBC       topexpr ',' INDEX           DIRECT INDEXX
       SBC       topexpr ',' INDEX           EXTENDED INDEXX
       SBC       topexpr ',' INDEX           INDEXY
       SBC       topexpr                     DIRECT
       SBC       topexpr                     EXTENDED

       SEC

       SED

       SEI

       SMB0      topexpr                     INSTROCKWELL

       SMB1      topexpr                     INSTROCKWELL

       SMB2      topexpr                     INSTROCKWELL

       SMB3      topexpr                     INSTROCKWELL

       SMB4      topexpr                     INSTROCKWELL

       SMB5      topexpr                     INSTROCKWELL

       SMB6      topexpr                     INSTROCKWELL

       SMB7      topexpr                     INSTROCKWELL

       STA       '(' topexpr ')' ',' INDEX   DIRECT INDEXY
       STA       '(' topexpr ')'             DIRECT INSTCMOS
       STA       '(' topexpr ',' INDEX ')'   DIRECT INDEXX
       STA       topexpr ',' INDEX           DIRECT INDEXX
       STA       topexpr ',' INDEX           EXTENDED INDEXX
       STA       topexpr ',' INDEX           INDEXY
       STA       topexpr                     DIRECT
       STA       topexpr                     EXTENDED

       STX       topexpr ',' INDEX           DIRECT INDEXY
       STX       topexpr                     DIRECT











                                  - 8 -



       Opcode   Syntax                       Selection Criteria

       STX       topexpr                     EXTENDED

       STY       topexpr ',' INDEX           DIRECT INDEXX
       STY       topexpr                     DIRECT
       STY       topexpr                     EXTENDED

       STZ       topexpr ',' INDEX           DIRECT INDEXX INSTCMOS
       STZ       topexpr ',' INDEX           EXTENDED INDEXX INSTCMOS
       STZ       topexpr                     DIRECT INSTCMOS
       STZ       topexpr                     EXTENDED INSTCMOS

       TAX

       TAY

       TRB       topexpr                     DIRECT INSTCMOS
       TRB       topexpr                     EXTENDED INSTCMOS

       TSB       topexpr                     DIRECT INSTCMOS
       TSB       topexpr                     EXTENDED INSTCMOS

       TSX

       TXA

       TXS

       TYA

       A.2.2  _O_p_e_r_a_n_d_s

            ACCUM               The a or (A) reserved symbol

            INDEX               The x or y (or X or Y) reserved
                                symbols

       A.2.3  _S_e_l_e_c_t_i_o_n__C_r_i_t_e_r_i_a__K_e_y_w_o_r_d_s

            DIRECT              The instruction can use the direct
                                addressing mode. The expression
                                must have a value between 0 and 255
                                that is defined when the
                                instruction is processed in the
                                input pass.

            EXTENDED            The instruction can use the
                                extended (16 bit address) mode.













                                  - 9 -



            INDEXX              The instruction can use the X
                                index.

            INDEXY              The instruction can use the Y
                                index.

            INSTCMOS            The instruction is in the CMOS and
                                ROCKWELL CMOS instruction sets.

            INSTROCKWELL        The instruction is in the ROCKWELL,
                                ROCKWELL CMOS, and R65c00/21
                                instruction sets.

            INST21              The instruction is in the R65c00/21
                                instruction set.

       A.2.4  _A_p_o_s_t_r_o_p_h_e_s  The apostrophes in the syntax field are
       a notation used for the parser generator and are not put in
       the assembler source statement.

       A.3  NNNNooootttteeeessss

       A.3.1  _T_o_p__E_x_p_r_e_s_s_i_o_n_s  The syntax of some of the
       instructions combined with the standard expression syntax
       resulted in confusion whether an operand was an expression
       surrounded by parenthesis, or a indexed reference. To get
       around this, the expressions in these ambiguous cases were
       restricted to those forms of expression that don't have
       surrounding parenthesis at the top level.  Subexpressions
       may be parenthesized, but only if an operator seperates or
       precedes the subexpression.

            Example

            lda 47h,y       ; load absolute, y
            lda +(47h),y    ; load absolute, y
            lda (47h),y     ; load (indirect), y
            lda ((47h)),y   ; error

       A.3.2  _R_e_s_e_r_v_e_d__S_y_m_b_o_l_s

       A.3.2.1  _M_a_c_h_i_n_e__D_e_p_e_n_d_e_n_t__R_e_s_e_r_v_e_d__S_y_m_b_o_l_s  A X Y a x y

       A.3.2.2  _S_t_a_n_d_a_r_d__R_e_s_e_r_v_e_d__S_y_m_b_o_l_s  AND DEFINED EQ GE GT
       HIGH LE LOW LT MOD NE NOT OR SHL SHR XOR and defined eq ge
       gt high le low lt mod ne not or shl shr xor




















                                 CONTENTS


       A.  Appendix for as6502 Frankenstein Assembler...........  1
           A.1  Pseudo Operations...............................  1
           A.2  Instructions....................................  2
           A.3  Notes...........................................  9















































                                  - i -




