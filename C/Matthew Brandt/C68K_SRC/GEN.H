 /*
 *      code generation structures and constants
 */

#define F_DREG  1       /* data register direct mode allowed */
#define F_AREG  2       /* address register direct mode allowed */
#define F_MEM   4       /* memory alterable modes allowed */
#define F_IMMED 8       /* immediate mode allowed */
#define F_ALT   7       /* alterable modes */
#define F_DALT  5       /* data alterable modes */
#define F_ALL   15      /* all modes allowed */
#define F_VOL   16      /* need volitile operand */
#define F_NOVALUE 32    /* dont need result value */

/*      addressing mode structure       */

struct amode {
        char            mode;
        char            preg;
        char            sreg;
        char            tempflag;
        int             deep;           /* stack depth on allocation */
        struct enode    *offset;
        };

/*      output code structure   */

struct ocode {
        struct ocode    *fwd, *back;
        short           opcode;
        short           length;
        struct amode    *oper1, *oper2;
        };

enum e_op {
        op_move, op_moveq, op_add, op_addi, op_addq, op_sub, op_subi,
        op_subq, op_muls, op_mulu, op_divs, op_divu, op_and, op_andi,
        op_or, op_ori, op_eor, op_asl, op_asr, op_jmp, op_jsr, op_movem,
        op_rts, op_bra, op_beq, op_bne, op_blt, op_ble, op_bgt, op_bge,
        op_bhi, op_bhs, op_blo, op_bls, op_tst, op_ext, op_lea, op_swap,
        op_neg, op_not, op_cmp, op_clr, op_link, op_unlk, op_label,
        op_pea, op_cmpi, op_dc };

enum e_am {
        am_dreg, am_areg, am_ind, am_ainc, am_adec, am_indx, am_indx2,
        am_xpc, am_direct, am_immed, am_mask, am_none, am_indx3 };

