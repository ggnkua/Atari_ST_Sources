/* Declarations for insn-output.c.
   These functions are defined in recog.c.  */

/* Operand-predicate functions.  */
int general_operand ();
int push_operand ();
int memory_operand ();
int immediate_operand ();
int register_operand ();
int address_operand ();
int nonmemory_operand ();
int nonimmediate_operand ();

int offsetable_address_p ();
rtx adj_offsetable_operand ();

/* Output a string of assembler code.
   Defined in final.c.  */
void output_asm_insn();

/* When outputting assembler code, indicates which alternative
   of the constraints was actually satisfied.  */
int which_alternative;
