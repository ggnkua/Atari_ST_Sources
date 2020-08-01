#include "tm-mips.h"

/* Names to predefine in the preprocessor for this target machine.  */

#undef CPP_PREDEFINES
#define CPP_PREDEFINES "-Dunix -Dmips"
#undef CPP_SPEC
#define CPP_SPEC "-Dsgi -DSVR3 -Dhost_mips -DMIPSEB -DSYSTYPE_SYSV -DLANGUAGE_C"

#define STARTFILE_SPEC  \
  "%{pg:gcrt1.o%s}%{!pg:%{p:mcrt1.o%s}%{!p:crt1.o%s}}"

#define LIB_SPEC "%{!p:%{!pg:-lc}}%{p:-lc_p}%{pg:-lc_p} crtn.o%s"

#define ASM_OUTPUT_SOURCE_FILENAME(FILE, FILENAME) \
  fprintf (FILE, "\t.file\t1 \"%s\"\n", FILENAME)

#undef ASM_OUTPUT_SOURCE_LINE
#define ASM_OUTPUT_SOURCE_LINE(file, line)              \
  { static int sym_lineno = 1;                          \
    fprintf (file, "\t.loc\t1 %d\nLM%d:\n",     \
             line, sym_lineno);         \
    sym_lineno += 1; }

#undef STACK_ARGS_ADJUST
#define STACK_ARGS_ADJUST(SIZE)                                         \
{                                                                       \
  SIZE.constant += 4;                                                   \
  if (SIZE.var)                                                         \
    {                                                                   \
      rtx size1 = ARGS_SIZE_RTX (SIZE);                                 \
      rtx rounded = gen_reg_rtx (SImode);                               \
      rtx label = gen_label_rtx ();                                     \
      emit_move_insn (rounded, size1);                                  \
      /* Needed: insns to jump to LABEL if ROUNDED is < 16.  */         \
      abort ();                                                         \
      emit_move_insn (rounded, gen_rtx (CONST_INT, VOIDmode, 16));      \
      emit_label (label);                                               \
      SIZE.constant = 0;                                                \
      SIZE.var = rounded;                                               \
    }                                                                   \
  else if (SIZE.constant < 32)                                          \
    SIZE.constant = 32;                                                 \
}

