


                                  - 1 -



       A.  AAAAppppppppeeeennnnddddiiiixxxx ffffoooorrrr aaaassss1111888800005555 FFFFrrrraaaannnnkkkkeeeennnnsssstttteeeeiiiinnnn AAAAsssssssseeeemmmmbbbblllleeeerrrr

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

       Opcode   Syntax               Selection Criteria


       ADC

       ADCI      '#' expr

       ADD

       ADI       '#' expr

       AND

       ANI       '#' expr

       B1        expr

       B2        expr

       B3        expr

       B4        expr

       BCI       expr                TS1805












                                  - 2 -



       Opcode   Syntax               Selection Criteria

       BDF       expr

       BGE       expr

       BL        expr

       BM        expr

       BN1       expr

       BN2       expr

       BN3       expr

       BN4       expr

       BNF       expr

       BNQ       expr

       BNZ       expr

       BPZ       expr

       BQ        expr

       BR        expr

       BXI       expr                TS1805

       BZ        expr

       CID                           TS1805

       CIE                           TS1805

       DACI      '#' expr            TS1805

       DADC                          TS1805

       DADD                          TS1805

       DADI      '#' expr            TS1805

       DBNZ      expr ',' expr       TS1805

       DEC       expr

       DIS











                                  - 3 -



       Opcode   Syntax               Selection Criteria


       DSAV                          TS1805

       DSBI      '#' expr            TS1805

       DSM                           TS1805

       DSMB                          TS1805

       DSMI      '#' expr            TS1805

       DTC                           TS1805

       ETQ                           TS1805

       GEC                           TS1805

       GHI       expr

       GLO       expr

       IDL

       INC       expr

       INP       expr

       IRX

       LBDF      expr

       LBNF      expr

       LBNQ      expr

       LBNZ      expr

       LBQ       expr

       LBR       expr

       LBZ       expr

       LDA       expr

       LDC                           TS1805

       LDI       '#' expr












                                  - 4 -



       Opcode   Syntax               Selection Criteria

       LDN       expr

       LDX

       LDXA

       LSDF

       LSIE

       LSKP

       LSNF

       LSNQ

       LSNZ

       LSQ

       LSZ

       MARK

       NBR      expr

       NLBR     expr

       NOP

       OR

       ORI       '#' expr

       OUT       expr

       PHI       expr

       PLO       expr

       REQ

       RET

       RLDI      expr ',' '#' expr   TS1805

       RLXA      expr                TS1805

       RNX       expr                TS1805











                                  - 5 -



       Opcode   Syntax               Selection Criteria


       RSHL

       RSHR

       RSXD      expr                TS1805

       SAV

       SCAL      expr ',' expr       TS1805

       SCM1                          TS1805

       SCM2                          TS1805

       SD

       SDB

       SDBI      '#' expr

       SDI       '#' expr

       SEP       expr

       SEQ

       SEX       expr

       SHL

       SHLC

       SHR

       SHRC

       SKP

       SM

       SMB

       SMBI      '#' expr

       SMI       '#' expr

       SPM1                          TS1805












                                  - 6 -



       Opcode   Syntax               Selection Criteria

       SPM2                          TS1805

       SRET      expr                TS1805

       STM                           TS1805

       STPC                          TS1805

       STR       expr

       STXD

       XID                           TS1805

       XIE                           TS1805

       XOR

       XRI       '#' expr

       A.2.2  _S_e_l_e_c_t_i_o_n__C_r_i_t_e_r_i_a__K_e_y_w_o_r_d_s

            TS1805              Instruction is only valid for the
                                1804A/1805A/1806A instruction sets.

       A.2.3  _A_p_o_s_t_r_o_p_h_e_s  The apostrophes in the syntax field are
       a notation used for the parser generator and are not put in
       the assembler source statement.

       A.3  NNNNooootttteeeessss

       A.3.1  _I_n_s_t_r_u_c_t_i_o_n__S_e_t__S_e_l_e_c_t_i_o_n  The default is the 1805
       instruction set. To restrict the instruction set, use the -p
       1802 optional arguement on the command line, or rename or
       link the program file with a name containing the string 1802
       (or just "02").

       A.3.2  _R_e_g_i_s_t_e_r__a_n_d__P_o_r_t__e_x_p_r_e_s_s_i_o_n_s  The register and port
       numbers are specified as expressions.  For registers, the
       value must be between 0 and 15 (1 and 15 for the LDN
       instruction).  For input/output ports, the value must be
       between 1 and 7.  The value must be computable when
       processed in the first pass.  The SET and EQU statements can
       be used to setup symbols for registers and ports.  It is
       recomended that a standard include file be setup to assign a
       set of symbols (like R0 to R15) for registers.














                                  - 7 -



       A.3.3  _B_r_a_n_c_h__T_a_r_g_e_t__E_x_p_r_e_s_s_i_o_n__V_a_l_i_d_i_t_y  The "expression
       fails validity test" error message can occur if the
       destination of a short branch is not on the same page as the
       the last byte of the instruction.  The "expression exceeds
       available field width" can also occur for this case.
       Usually the validity message occurs when the destination is
       at a lower page, and the width message occurs when the
       destination is at a higher page.

       A.3.4  _I_m_m_e_d_i_a_t_e__D_a_t_a  The immediate data expressions for
       the RLDI (as well as the arithmetic and logic operations)
       are required to be on same line as the opcode.

       A.3.5  _R_e_s_e_r_v_e_d__S_y_m_b_o_l_s

       A.3.5.1  _S_t_a_n_d_a_r_d__R_e_s_e_r_v_e_d__S_y_m_b_o_l_s  AND DEFINED EQ GE GT
       HIGH LE LOW LT MOD NE NOT OR SHL SHR XOR and defined eq ge
       gt high le low lt mod ne not or shl shr xor
















































                                 CONTENTS


       A.  Appendix for as1805 Frankenstein Assembler...........  1
           A.1  Pseudo Operations...............................  1
           A.2  Instructions....................................  1
           A.3  Notes...........................................  6















































                                  - i -




