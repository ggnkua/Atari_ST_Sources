


                                  - 1 -



       A.  AAAAppppppppeeeennnnddddiiiixxxx ffffoooorrrr aaaassss6666888800005555 FFFFrrrraaaannnnkkkkeeeennnnsssstttteeeeiiiinnnn AAAAsssssssseeeemmmmbbbblllleeeerrrr

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

       A.1.2.1  _I_n_s_t_r_u_c_t_i_o_n__S_e_t__S_e_l_e_c_t_i_o_n

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
            68hc05                   hc HC
            146805                   4
            6305                     3
            6805                     05 l05 L05

       A.2  IIIInnnnssssttttrrrruuuuccccttttiiiioooonnnnssss

       A.2.1  _I_n_s_t_r_u_c_t_i_o_n__L_i_s_t

       Opcode   Syntax                    Selection Criteria













                                  - 2 -



       Opcode   Syntax                    Selection Criteria

       ADC       '#' expr
       ADC       expr                     DIRECT
       ADC       expr                     EXTENDED
       ADC       indexed                  INDEX0
       ADC       indexed                  INDEX1
       ADC       indexed                  INDEX2

       ADD       '#' expr
       ADD       expr                     DIRECT
       ADD       expr                     EXTENDED
       ADD       indexed                  INDEX0
       ADD       indexed                  INDEX1
       ADD       indexed                  INDEX2

       AND       '#' expr
       AND       expr                     DIRECT
       AND       expr                     EXTENDED
       AND       indexed                  INDEX0
       AND       indexed                  INDEX1
       AND       indexed                  INDEX2

       ASL       expr                     DIRECT
       ASL       indexed                  INDEX0
       ASL       indexed                  INDEX1

       ASLA

       ASLX

       ASR       expr                     DIRECT
       ASR       indexed                  INDEX0
       ASR       indexed                  INDEX1

       ASRA

       ASRX

       BCC       expr

       BCLR      expr ',' expr

       BCS       expr

       BEQ       expr

       BHCC      expr

       BHCS      expr












                                  - 3 -



       Opcode   Syntax                    Selection Criteria

       BHI       expr

       BHS       expr

       BIH       expr

       BIL       expr

       BIT       '#' expr
       BIT       expr                     DIRECT
       BIT       expr                     EXTENDED
       BIT       indexed                  INDEX0
       BIT       indexed                  INDEX1
       BIT       indexed                  INDEX2

       BLO       expr

       BLS       expr

       BMC       expr

       BMI       expr

       BMS       expr

       BNE       expr

       BPL       expr

       BRA       expr

       BRCLR     expr ',' expr ',' expr

       BRN       expr

       BRSET     expr ',' expr ',' expr

       BSET      expr ',' expr

       BSR       expr

       CLC

       CLI

       CLR       expr                     DIRECT
       CLR       indexed                  INDEX0
       CLR       indexed                  INDEX1












                                  - 4 -



       Opcode   Syntax                    Selection Criteria

       CLRA

       CLRX

       CMP       '#' expr
       CMP       expr                     DIRECT
       CMP       expr                     EXTENDED
       CMP       indexed                  INDEX0
       CMP       indexed                  INDEX1
       CMP       indexed                  INDEX2

       COM       expr                     DIRECT
       COM       indexed                  INDEX0
       COM       indexed                  INDEX1

       COMA

       COMX

       CPX       '#' expr
       CPX       expr                     DIRECT
       CPX       expr                     EXTENDED
       CPX       indexed                  INDEX0
       CPX       indexed                  INDEX1
       CPX       indexed                  INDEX2

       DAA                                INSTDAA

       DEC       expr                     DIRECT
       DEC       indexed                  INDEX0
       DEC       indexed                  INDEX1

       DECA

       DECX

       EOR       '#' expr
       EOR       expr                     DIRECT
       EOR       expr                     EXTENDED
       EOR       indexed                  INDEX0
       EOR       indexed                  INDEX1
       EOR       indexed                  INDEX2

       INC       expr                     DIRECT
       INC       indexed                  INDEX0
       INC       indexed                  INDEX1

       INCA












                                  - 5 -



       Opcode   Syntax                    Selection Criteria

       INCX

       JMP       expr                     DIRECT
       JMP       expr                     EXTENDED
       JMP       indexed                  INDEX0
       JMP       indexed                  INDEX1
       JMP       indexed                  INDEX2

       JSR       expr                     DIRECT
       JSR       expr                     EXTENDED
       JSR       indexed                  INDEX0
       JSR       indexed                  INDEX1
       JSR       indexed                  INDEX2

       LDA       '#' expr
       LDA       expr                     DIRECT
       LDA       expr                     EXTENDED
       LDA       indexed                  INDEX0
       LDA       indexed                  INDEX1
       LDA       indexed                  INDEX2

       LDX       '#' expr
       LDX       expr                     DIRECT
       LDX       expr                     EXTENDED
       LDX       indexed                  INDEX0
       LDX       indexed                  INDEX1
       LDX       indexed                  INDEX2

       LSL       expr                     DIRECT
       LSL       indexed                  INDEX0
       LSL       indexed                  INDEX1

       LSLA

       LSLX

       LSR       expr                     DIRECT
       LSR       indexed                  INDEX0
       LSR       indexed                  INDEX1

       LSRA

       LSRX

       MUL                                INSTMUL

       NEG       expr                     DIRECT
       NEG       indexed                  INDEX0
       NEG       indexed                  INDEX1











                                  - 6 -



       Opcode   Syntax                    Selection Criteria


       NEGA

       NEGX

       NOP

       ORA       '#' expr
       ORA       expr                     DIRECT
       ORA       expr                     EXTENDED
       ORA       indexed                  INDEX0
       ORA       indexed                  INDEX1
       ORA       indexed                  INDEX2

       ROL       expr                     DIRECT
       ROL       indexed                  INDEX0
       ROL       indexed                  INDEX1

       ROLA

       ROLX

       ROR       expr                     DIRECT
       ROR       indexed                  INDEX0
       ROR       indexed                  INDEX1

       RORA

       RORX

       RSP

       RTI

       RTS

       SBC       '#' expr
       SBC       expr                     DIRECT
       SBC       expr                     EXTENDED
       SBC       indexed                  INDEX0
       SBC       indexed                  INDEX1
       SBC       indexed                  INDEX2

       SEC

       SEI

       STA       expr                     DIRECT
       STA       expr                     EXTENDED











                                  - 7 -



       Opcode   Syntax                    Selection Criteria

       STA       indexed                  INDEX0
       STA       indexed                  INDEX1
       STA       indexed                  INDEX2

       STOP                               INSTSTWA

       STX       expr                     DIRECT
       STX       expr                     EXTENDED
       STX       indexed                  INDEX0
       STX       indexed                  INDEX1
       STX       indexed                  INDEX2

       SUB       '#' expr
       SUB       expr                     DIRECT
       SUB       expr                     EXTENDED
       SUB       indexed                  INDEX0
       SUB       indexed                  INDEX1
       SUB       indexed                  INDEX2

       SWI

       TAX

       TST       expr                     DIRECT
       TST       indexed                  INDEX0
       TST       indexed                  INDEX1

       TSTA

       TSTX

       TXA

       WAIT                               INSTSTWA

       A.2.2  _S_e_l_e_c_t_i_o_n__C_r_i_t_e_r_i_a__K_e_y_w_o_r_d_s

            DIRECT              The direct addressing mode can be
                                used if the expression has a value
                                between 0 and 255. The expression
                                will be treated as a two byte long
                                value if it is not defined when the
                                statement is processed in the first
                                pass.

            EXTENDED            The expression can be a 2 byte long
                                value.













                                  - 8 -



            INDEX0              The Indexed addressing mode with no
                                offset can be used.

            INDEX1              The Indexed addressing mode with a
                                one byte offset can be used.

            INDEX2              The Indexed addressing mode with
                                two byte offset can be used.

            INSTSTWA            The instruction is only available
                                in the 146805, 6305, and 68hc05
                                instruction sets.

            INSTMUL             The instruction is only available
                                in the 68hc05 instruction set.

            INSTDAA             The instruction is only available
                                in the 6305 instruction set.

       A.2.3  _A_p_o_s_t_r_o_p_h_e_s  The apostrophes in the syntax field are
       a notation used for the parser generator and are not put in
       the assembler source statement.

       A.3  NNNNooootttteeeessss

       A.3.1  _B_i_t__N_u_m_b_e_r_s  The bit number expression in the BSET,
       BCLR, BRCLR, BRSET operations has to have value defined when
       the instruction is read in the first pass.  The value must
       be between 0 and 7.

       A.3.2  _I_n_d_e_x_e_d__A_d_d_r_e_s_s_i_n_g  The indexed addressing mode is
       represented in two ways.

       First, with no offset, the form ",X" is used.

       Second, the form "expression, X" is used for both the one
       and two byte offsets modes. The expression will be treated
       as a two byte long value if it is not defined when the
       statement is processed in the first pass.

       A.3.3  _R_e_s_e_r_v_e_d__S_y_m_b_o_l_s

       A.3.3.1  _M_a_c_h_i_n_e__D_e_p_e_n_d_e_n_t__R_e_s_e_r_v_e_d__S_y_m_b_o_l_s  X x

       A.3.3.2  _S_t_a_n_d_a_r_d__R_e_s_e_r_v_e_d__S_y_m_b_o_l_s  AND DEFINED EQ GE GT
       HIGH LE LOW LT MOD NE NOT OR SHL SHR XOR and defined eq ge
       gt high le low lt mod ne not or shl shr xor



















                                 CONTENTS


       A.  Appendix for as6805 Frankenstein Assembler...........  1
           A.1  Pseudo Operations...............................  1
           A.2  Instructions....................................  1
           A.3  Notes...........................................  8















































                                  - i -




