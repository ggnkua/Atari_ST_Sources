.EXPORT Sasm_smemcpy8, asm030_smemcpy8, Sasm_smemcpy16, asm030_smemcpy16, Sasm_smemcpy32, asm030_smemcpy32

*
*  void asm030_smemcpy8(void *dst, void *src, long nb_elems_dst, long nb_elems_src)
*                    A0          A1              D0               D1
asm030_smemcpy8:
    SWAP    D1
    DIVU.L  D0,D1

*
*  void Sasm_smemcpy8(void *dst, void *src, long nb_elems_dst, long add_src32)
*                    A0          A1              D0               D1
Sasm_smemcpy8:
    MOVE.L  D2,-(SP)
    MOVE.L  D3,-(SP)
    SWAP    D1
    TST.W   D1
    BPL.S   notneg8
    SUB.L   #$010000,D1
notneg8:
    MOVEQ.L #$0F,D3
    AND.W   D0,D3
    LSR.W   #4,D0
    NEG.W   D3
    MOVE.W  D3,D2
    ADD.W   D2,D2
    LSL.W   #2,D3
    ADD.W   D2,D3   ; D3 = D3 * 6

    MOVEQ   #0,D2   ; D2 = offset_src
    SUB.W   D1,D2
    ADD.L   D1,D2   ; pour positionner X flag

    JMP     end_loop8(PC,D3.W)
Ssmemcpy8_loop:
    REPT    16
    MOVE.B  (A1,D2.W),(A0)+   ; Code sur 2 mots
    ADDX.L  D1,D2             ; Code sur 1 mot
    ENDM
end_loop8:
    DBF     D0,Ssmemcpy8_loop
    MOVE.L  (SP)+,D3
    MOVE.L  (SP)+,D2
    RTS

*
*  void asm030_smemcpy16(void *dst, void *src, long nb_elems_dst, long nb_elems_src)
*                    A0          A1              D0               D1
asm030_smemcpy16:
    SWAP    D1
    DIVU.L  D0,D1
    MOVE.L  D2,-(SP)
    MOVE.L  D3,-(SP)
    SWAP    D1
    TST.W   D1
    BPL.S   notneg16
    SUB.L   #$010000,D1
notneg16:
    MOVEQ.L #$0F,D3
    AND.W   D0,D3
    LSR.W   #4,D0
    NEG.W   D3
    MOVE.W  D3,D2
    ADD.W   D2,D2
    LSL.W   #2,D3
    ADD.W   D2,D3   ; D3 = D3 * 6

    MOVEQ   #0,D2   ; D2 = offset_src
    SUB.W   D1,D2
    ADD.L   D1,D2   ; pour positionner X flag

    JMP     end_loop16(PC,D3.W)
s030memcpy16_loop:
    REPT    16
    MOVE.W  (A1,D2.W*2),(A0)+ ; Code sur 2 mots
    ADDX.L  D1,D2             ; Code sur 1 mot
    ENDM
end_loop16:
    DBF     D0,s030memcpy16_loop
    MOVE.L  (SP)+,D3
    MOVE.L  (SP)+,D2
    RTS

*
*  void Sasm_smemcpy16(void *dst, void *src, long nb_elems_dst, long offset_src32)
*                    A0          A1              D0               D1
Sasm_smemcpy16:
    MOVE.L  D2,-(SP)
    MOVE.L  D3,-(SP)
    MOVE.L  D1,D3   ; D3 = add_src
    MOVEQ   #0,D2   ; D2 = offset_src
    SUBQ.W  #1,D0   ; pour DBF
    BMI     end16
Ssmemcpy16_loop:
    SWAP    D2
    MOVE.W  D2,D1
    ADD.W   D1,D1
    MOVE.W  (A1,D1.W),(A0)+
    SWAP    D2
    ADD.L   D3,D2
    DBF     D0,Ssmemcpy16_loop
end16:
    MOVE.L  (SP)+,D3
    MOVE.L  (SP)+,D2
    RTS

*
*  void asm030_smemcpy32(void *dst, void *src, long nb_elems_dst, long nb_elems_src)
*                             A0          A1              D0               D1
asm030_smemcpy32:
    SWAP    D1
    DIVU.L  D0,D1
    MOVE.L  D2,-(SP)
    MOVE.L  D3,-(SP)
    SWAP    D1
    TST.W   D1
    BPL.S   notneg32
    SUB.L   #$010000,D1
notneg32:
    MOVEQ.L #$0F,D3
    AND.W   D0,D3
    LSR.W   #4,D0
    NEG.W   D3
    MOVE.W  D3,D2
    ADD.W   D2,D2
    LSL.W   #2,D3
    ADD.W   D2,D3   ; D3 = D3 * 6

    MOVEQ   #0,D2   ; D2 = offset_src
    SUB.W   D1,D2
    ADD.L   D1,D2   ; pour positionner X flag

    JMP     end_loop32(PC,D3.W)
s030memcpy32_loop:
    REPT    16
    MOVE.L  (A1,D2.W*4),(A0)+ ; Code sur 2 mots
    ADDX.L  D1,D2             ; Code sur 1 mot
    ENDM
end_loop32:
    DBF     D0,s030memcpy32_loop
    MOVE.L  (SP)+,D3
    MOVE.L  (SP)+,D2
    RTS

*
*  void Ssmemcpy32(void *dst, void *src, long nb_elems_dst, long add_src32)
*                    A0          A1              D0               D1
Sasm_smemcpy32:
    MOVE.L  D2,-(SP)
    MOVE.L  D3,-(SP)
    MOVE.L  D1,D3   ; D3 = add_src
    MOVEQ   #0,D2   ; D2 = offset_src
    SUBQ.W  #1,D0   ; pour DBF
    BMI     end32
Ssmemcpy32_loop:
    SWAP    D2
    MOVE.W  D2,D1
    LSL.W   #2,D1
    MOVE.L  (A1,D1.W),(A0)+
    SWAP    D2
    ADD.L   D3,D2
    DBF     D0,Ssmemcpy32_loop
end32:
    MOVE.L  (SP)+,D3
    MOVE.L  (SP)+,D2
    RTS
