/* Generated automatically by the program `genrecog'
from the machine description file `md'.  */

#include "config.h"
#include "rtl.h"
#include "insn-config.h"
#include "recog.h"

/* `recog' contains a decision tree
   that recognizes whether the rtx X0 is a valid instruction.

   recog returns -1 if the rtx is not valid.
   If the rtx is valid, recog returns a nonnegative number
   which is the insn code number for the pattern that matched.
   This is the same as the order in the machine description of
   the entry that matched.  This number can be used as an index into
   insn_templates and insn_n_operands (found in insn-output.c)
   or as an argument to output_insn_hairy (also in insn-output.c).  */

rtx recog_operand[MAX_RECOG_OPERANDS];

rtx *recog_operand_loc[MAX_RECOG_OPERANDS];

rtx *recog_dup_loc[MAX_DUP_OPERANDS];

char recog_dup_num[MAX_DUP_OPERANDS];

extern rtx recog_addr_dummy;

#define operands recog_operand

int
recog_1 (x0, insn)
     register rtx x0;
     rtx insn;
{
  register rtx x1, x2, x3, x4, x5;
  rtx x6, x7, x8, x9, x10, x11;
  int tem;
 L23:
  x1 = XEXP (x0, 1);
  if (GET_CODE (x1) == MINUS && 1)
    goto L34;
 L47:
  if (GET_CODE (x1) == MINUS && GET_MODE (x1) == DFmode && 1)
    goto L48;
  if (GET_CODE (x1) == MINUS && GET_MODE (x1) == SFmode && 1)
    goto L53;
  if (GET_CODE (x1) == ZERO_EXTRACT && 1)
    goto L58;
  if (GET_CODE (x1) == SUBREG && GET_MODE (x1) == SImode && XINT (x1, 1) == 0 && 1)
    goto L112;
  if (GET_CODE (x1) == AND && GET_MODE (x1) == SImode && 1)
    goto L118;
 L779:
  if (GET_CODE (x1) == ZERO_EXTRACT && GET_MODE (x1) == SImode && 1)
    goto L780;
  if (GET_CODE (x1) == SUBREG && GET_MODE (x1) == QImode && XINT (x1, 1) == 0 && 1)
    goto L786;
  if (GET_CODE (x1) == SUBREG && GET_MODE (x1) == HImode && XINT (x1, 1) == 0 && 1)
    goto L793;
 L8:
  if (general_operand (x1, SImode))
    { recog_operand[0] = x1; return 2; }
 L11:
  if (general_operand (x1, HImode))
    { recog_operand[0] = x1; return 3; }
 L14:
  if (general_operand (x1, QImode))
    { recog_operand[0] = x1; return 4; }
 L17:
  if (general_operand (x1, SFmode))
    { recog_operand[0] = x1; if (TARGET_68881) return 5; }
 L20:
  if (general_operand (x1, DFmode))
    { recog_operand[0] = x1; if (TARGET_68881) return 6; }
  goto ret0;
 L34:
  x2 = XEXP (x1, 0);
  if (GET_CODE (x2) == MEM && GET_MODE (x2) == QImode && 1)
    goto L35;
  if (GET_CODE (x2) == LSHIFTRT && GET_MODE (x2) == SImode && 1)
    goto L581;
  if (GET_CODE (x2) == ASHIFTRT && GET_MODE (x2) == SImode && 1)
    goto L595;
 L24:
  if (general_operand (x2, SImode))
    { recog_operand[0] = x2; goto L25; }
 L29:
  if (general_operand (x2, HImode))
    { recog_operand[0] = x2; goto L30; }
 L43:
  if (general_operand (x2, QImode))
    { recog_operand[0] = x2; goto L574; }
  goto L47;
 L35:
  x3 = XEXP (x2, 0);
  if (GET_CODE (x3) == POST_INC && GET_MODE (x3) == SImode && 1)
    goto L36;
  goto L24;
 L36:
  x4 = XEXP (x3, 0);
  if (general_operand (x4, SImode))
    { recog_operand[0] = x4; goto L37; }
  goto L24;
 L37:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == MEM && GET_MODE (x2) == QImode && 1)
    goto L38;
  x2 = XEXP (x1, 0);
  goto L24;
 L38:
  x3 = XEXP (x2, 0);
  if (GET_CODE (x3) == POST_INC && GET_MODE (x3) == SImode && 1)
    goto L39;
  x2 = XEXP (x1, 0);
  goto L24;
 L39:
  x4 = XEXP (x3, 0);
  if (general_operand (x4, SImode))
    { recog_operand[1] = x4; if (! CONSTANT_P (operands[0]) && ! CONSTANT_P (operands[1])) return 9; }
  x2 = XEXP (x1, 0);
  goto L24;
 L581:
  x3 = XEXP (x2, 0);
  if (memory_operand (x3, SImode))
    { recog_operand[0] = x3; goto L582; }
  goto L24;
 L582:
  x3 = XEXP (x2, 1);
  if (GET_CODE (x3) == CONST_INT && XINT (x3, 0) == 24 && 1)
    goto L583;
  goto L24;
 L583:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; if ((GET_CODE (operands[1]) == CONST_INT
    && (INTVAL (operands[1]) & ~0xff) == 0)) return 122; }
  x2 = XEXP (x1, 0);
  goto L24;
 L595:
  x3 = XEXP (x2, 0);
  if (memory_operand (x3, SImode))
    { recog_operand[0] = x3; goto L596; }
  goto L24;
 L596:
  x3 = XEXP (x2, 1);
  if (GET_CODE (x3) == CONST_INT && XINT (x3, 0) == 24 && 1)
    goto L597;
  goto L24;
 L597:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; if ((GET_CODE (operands[1]) == CONST_INT
    && ((INTVAL (operands[1]) + 0x80) & ~0xff) == 0)) return 124; }
  x2 = XEXP (x1, 0);
  goto L24;
 L25:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; return 7; }
  x2 = XEXP (x1, 0);
  goto L29;
 L30:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; return 8; }
  x2 = XEXP (x1, 0);
  goto L43;
 L574:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == LSHIFTRT && GET_MODE (x2) == SImode && 1)
    goto L575;
  if (GET_CODE (x2) == ASHIFTRT && GET_MODE (x2) == SImode && 1)
    goto L589;
 L44:
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; return 10; }
  goto L47;
 L575:
  x3 = XEXP (x2, 0);
  if (memory_operand (x3, SImode))
    { recog_operand[1] = x3; goto L576; }
  goto L44;
 L576:
  x3 = XEXP (x2, 1);
  if (GET_CODE (x3) == CONST_INT && XINT (x3, 0) == 24 && 1)
    if ((GET_CODE (operands[0]) == CONST_INT
    && (INTVAL (operands[0]) & ~0xff) == 0)) return 121;
  goto L44;
 L589:
  x3 = XEXP (x2, 0);
  if (memory_operand (x3, SImode))
    { recog_operand[1] = x3; goto L590; }
  goto L44;
 L590:
  x3 = XEXP (x2, 1);
  if (GET_CODE (x3) == CONST_INT && XINT (x3, 0) == 24 && 1)
    if ((GET_CODE (operands[0]) == CONST_INT
    && ((INTVAL (operands[0]) + 0x80) & ~0xff) == 0)) return 123;
  goto L44;
 L48:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, DFmode))
    { recog_operand[0] = x2; goto L49; }
  goto L8;
 L49:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, DFmode))
    { recog_operand[1] = x2; if (TARGET_68881) return 11; }
  goto L8;
 L53:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SFmode))
    { recog_operand[0] = x2; goto L54; }
  goto L8;
 L54:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SFmode))
    { recog_operand[1] = x2; if (TARGET_68881) return 12; }
  goto L8;
 L58:
  x2 = XEXP (x1, 0);
  if (nonimmediate_operand (x2, QImode))
    { recog_operand[0] = x2; goto L59; }
 L100:
  if (nonimmediate_operand (x2, HImode))
    { recog_operand[0] = x2; goto L101; }
 L66:
  if (nonimmediate_operand (x2, SImode))
    { recog_operand[0] = x2; goto L67; }
  goto L779;
 L59:
  x2 = XEXP (x1, 1);
  if (x2 == const1_rtx && 1)
    goto L60;
  x2 = XEXP (x1, 0);
  goto L100;
 L60:
  x2 = XEXP (x1, 2);
  if (GET_CODE (x2) == MINUS && GET_MODE (x2) == SImode && 1)
    goto L61;
 L96:
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; if (GET_CODE (operands[1]) == CONST_INT) return 17; }
  x2 = XEXP (x1, 0);
  goto L100;
 L61:
  x3 = XEXP (x2, 0);
  if (GET_CODE (x3) == CONST_INT && XINT (x3, 0) == 7 && 1)
    goto L78;
  goto L96;
 L78:
  x3 = XEXP (x2, 1);
  if (GET_CODE (x3) == AND && GET_MODE (x3) == SImode && 1)
    goto L79;
 L62:
  if (general_operand (x3, SImode))
    { recog_operand[1] = x3; return 13; }
  goto L96;
 L79:
  x4 = XEXP (x3, 0);
  if (general_operand (x4, SImode))
    { recog_operand[1] = x4; goto L80; }
  goto L62;
 L80:
  x4 = XEXP (x3, 1);
  if (GET_CODE (x4) == CONST_INT && XINT (x4, 0) == 7 && 1)
    return 15;
  goto L62;
 L101:
  x2 = XEXP (x1, 1);
  if (x2 == const1_rtx && 1)
    goto L102;
  x2 = XEXP (x1, 0);
  goto L66;
 L102:
  x2 = XEXP (x1, 2);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; if (GET_CODE (operands[1]) == CONST_INT) return 18; }
  x2 = XEXP (x1, 0);
  goto L66;
 L67:
  x2 = XEXP (x1, 1);
  if (x2 == const1_rtx && 1)
    goto L68;
  goto L779;
 L68:
  x2 = XEXP (x1, 2);
  if (GET_CODE (x2) == MINUS && GET_MODE (x2) == SImode && 1)
    goto L69;
 L108:
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; if (GET_CODE (operands[1]) == CONST_INT) return 19; }
  goto L779;
 L69:
  x3 = XEXP (x2, 0);
  if (GET_CODE (x3) == CONST_INT && XINT (x3, 0) == 31 && 1)
    goto L88;
  goto L108;
 L88:
  x3 = XEXP (x2, 1);
  if (GET_CODE (x3) == AND && GET_MODE (x3) == SImode && 1)
    goto L89;
 L70:
  if (general_operand (x3, SImode))
    { recog_operand[1] = x3; return 14; }
  goto L108;
 L89:
  x4 = XEXP (x3, 0);
  if (general_operand (x4, SImode))
    { recog_operand[1] = x4; goto L90; }
  goto L70;
 L90:
  x4 = XEXP (x3, 1);
  if (GET_CODE (x4) == CONST_INT && XINT (x4, 0) == 31 && 1)
    return 16;
  goto L70;
 L112:
  x2 = XEXP (x1, 0);
  if (GET_CODE (x2) == LSHIFTRT && GET_MODE (x2) == QImode && 1)
    goto L113;
  goto L8;
 L113:
  x3 = XEXP (x2, 0);
  if (nonimmediate_operand (x3, QImode))
    { recog_operand[0] = x3; goto L114; }
  goto L8;
 L114:
  x3 = XEXP (x2, 1);
  if (GET_CODE (x3) == CONST_INT && XINT (x3, 0) == 7 && 1)
    return 20;
  goto L8;
 L118:
  x2 = XEXP (x1, 0);
  if (GET_CODE (x2) == SIGN_EXTEND && GET_MODE (x2) == SImode && 1)
    goto L119;
  goto L8;
 L119:
  x3 = XEXP (x2, 0);
  if (GET_CODE (x3) == SIGN_EXTEND && GET_MODE (x3) == HImode && 1)
    goto L120;
  goto L8;
 L120:
  x4 = XEXP (x3, 0);
  if (nonimmediate_operand (x4, QImode))
    { recog_operand[0] = x4; goto L121; }
  goto L8;
 L121:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; if ((GET_CODE (operands[1]) == CONST_INT
    && (unsigned) INTVAL (operands[1]) < 0x100
    && exact_log2 (INTVAL (operands[1])) >= 0)) return 21; }
  goto L8;
 L780:
  x2 = XEXP (x1, 0);
  if (memory_operand (x2, QImode))
    { recog_operand[0] = x2; goto L781; }
 L800:
  if (nonimmediate_operand (x2, SImode))
    { recog_operand[0] = x2; goto L801; }
  goto L8;
 L781:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L782; }
  x2 = XEXP (x1, 0);
  goto L800;
 L782:
  x2 = XEXP (x1, 2);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; if (TARGET_68020 && TARGET_BITFIELD
   && GET_CODE (operands[1]) == CONST_INT) return 157; }
  x2 = XEXP (x1, 0);
  goto L800;
 L801:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L802; }
  goto L8;
 L802:
  x2 = XEXP (x1, 2);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; if (TARGET_68020 && TARGET_BITFIELD
   && GET_CODE (operands[1]) == CONST_INT) return 160; }
  goto L8;
 L786:
  x2 = XEXP (x1, 0);
  if (GET_CODE (x2) == ZERO_EXTRACT && GET_MODE (x2) == SImode && 1)
    goto L787;
  goto L8;
 L787:
  x3 = XEXP (x2, 0);
  if (memory_operand (x3, QImode))
    { recog_operand[0] = x3; goto L788; }
 L807:
  if (nonimmediate_operand (x3, SImode))
    { recog_operand[0] = x3; goto L808; }
  goto L8;
 L788:
  x3 = XEXP (x2, 1);
  if (general_operand (x3, SImode))
    { recog_operand[1] = x3; goto L789; }
  x3 = XEXP (x2, 0);
  goto L807;
 L789:
  x3 = XEXP (x2, 2);
  if (general_operand (x3, SImode))
    { recog_operand[2] = x3; if (TARGET_68020 && TARGET_BITFIELD
   && GET_CODE (operands[1]) == CONST_INT) return 158; }
  x3 = XEXP (x2, 0);
  goto L807;
 L808:
  x3 = XEXP (x2, 1);
  if (general_operand (x3, SImode))
    { recog_operand[1] = x3; goto L809; }
  goto L8;
 L809:
  x3 = XEXP (x2, 2);
  if (general_operand (x3, SImode))
    { recog_operand[2] = x3; if (TARGET_68020 && TARGET_BITFIELD
   && GET_CODE (operands[1]) == CONST_INT) return 161; }
  goto L8;
 L793:
  x2 = XEXP (x1, 0);
  if (GET_CODE (x2) == ZERO_EXTRACT && GET_MODE (x2) == SImode && 1)
    goto L794;
  goto L8;
 L794:
  x3 = XEXP (x2, 0);
  if (memory_operand (x3, QImode))
    { recog_operand[0] = x3; goto L795; }
 L814:
  if (nonimmediate_operand (x3, SImode))
    { recog_operand[0] = x3; goto L815; }
  goto L8;
 L795:
  x3 = XEXP (x2, 1);
  if (general_operand (x3, SImode))
    { recog_operand[1] = x3; goto L796; }
  x3 = XEXP (x2, 0);
  goto L814;
 L796:
  x3 = XEXP (x2, 2);
  if (general_operand (x3, SImode))
    { recog_operand[2] = x3; if (TARGET_68020 && TARGET_BITFIELD
   && GET_CODE (operands[1]) == CONST_INT) return 159; }
  x3 = XEXP (x2, 0);
  goto L814;
 L815:
  x3 = XEXP (x2, 1);
  if (general_operand (x3, SImode))
    { recog_operand[1] = x3; goto L816; }
  goto L8;
 L816:
  x3 = XEXP (x2, 2);
  if (general_operand (x3, SImode))
    { recog_operand[2] = x3; if (TARGET_68020 && TARGET_BITFIELD
   && GET_CODE (operands[1]) == CONST_INT) return 162; }
  goto L8;
 ret0: return -1;
}

int
recog_2 (x0, insn)
     register rtx x0;
     rtx insn;
{
  register rtx x1, x2, x3, x4, x5;
  rtx x6, x7, x8, x9, x10, x11;
  int tem;
 L870:
  x1 = XEXP (x0, 1);
  x2 = XEXP (x1, 0);
 switch (GET_CODE (x2))
  {
  case EQ:
  if (1)
    goto L871;
  break;
  case NE:
  if (1)
    goto L880;
  break;
  case GT:
  if (1)
    goto L889;
  break;
  case GTU:
  if (1)
    goto L898;
  break;
  case LT:
  if (1)
    goto L907;
  break;
  case LTU:
  if (1)
    goto L916;
  break;
  case GE:
  if (1)
    goto L925;
  break;
  case GEU:
  if (1)
    goto L934;
  break;
  case LE:
  if (1)
    goto L943;
  break;
  case LEU:
  if (1)
    goto L952;
  break;
  }
  goto ret0;
 L871:
  x3 = XEXP (x2, 0);
  if (x3 == cc0_rtx && 1)
    goto L872;
  goto ret0;
 L872:
  x3 = XEXP (x2, 1);
  if (x3 == const0_rtx && 1)
    goto L873;
  goto ret0;
 L873:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L874;
  if (x2 == pc_rtx && 1)
    goto L964;
  goto ret0;
 L874:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; goto L875; }
  goto ret0;
 L875:
  x2 = XEXP (x1, 2);
  if (x2 == pc_rtx && 1)
    return 173;
  goto ret0;
 L964:
  x2 = XEXP (x1, 2);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L965;
  goto ret0;
 L965:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; return 183; }
  goto ret0;
 L880:
  x3 = XEXP (x2, 0);
  if (x3 == cc0_rtx && 1)
    goto L881;
  goto ret0;
 L881:
  x3 = XEXP (x2, 1);
  if (x3 == const0_rtx && 1)
    goto L882;
  goto ret0;
 L882:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L883;
  if (x2 == pc_rtx && 1)
    goto L973;
  goto ret0;
 L883:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; goto L884; }
  goto ret0;
 L884:
  x2 = XEXP (x1, 2);
  if (x2 == pc_rtx && 1)
    return 174;
  goto ret0;
 L973:
  x2 = XEXP (x1, 2);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L974;
  goto ret0;
 L974:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; return 184; }
  goto ret0;
 L889:
  x3 = XEXP (x2, 0);
  if (x3 == cc0_rtx && 1)
    goto L890;
  goto ret0;
 L890:
  x3 = XEXP (x2, 1);
  if (x3 == const0_rtx && 1)
    goto L891;
  goto ret0;
 L891:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L892;
  if (x2 == pc_rtx && 1)
    goto L982;
  goto ret0;
 L892:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; goto L893; }
  goto ret0;
 L893:
  x2 = XEXP (x1, 2);
  if (x2 == pc_rtx && 1)
    return 175;
  goto ret0;
 L982:
  x2 = XEXP (x1, 2);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L983;
  goto ret0;
 L983:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; return 185; }
  goto ret0;
 L898:
  x3 = XEXP (x2, 0);
  if (x3 == cc0_rtx && 1)
    goto L899;
  goto ret0;
 L899:
  x3 = XEXP (x2, 1);
  if (x3 == const0_rtx && 1)
    goto L900;
  goto ret0;
 L900:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L901;
  if (x2 == pc_rtx && 1)
    goto L991;
  goto ret0;
 L901:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; goto L902; }
  goto ret0;
 L902:
  x2 = XEXP (x1, 2);
  if (x2 == pc_rtx && 1)
    return 176;
  goto ret0;
 L991:
  x2 = XEXP (x1, 2);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L992;
  goto ret0;
 L992:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; return 186; }
  goto ret0;
 L907:
  x3 = XEXP (x2, 0);
  if (x3 == cc0_rtx && 1)
    goto L908;
  goto ret0;
 L908:
  x3 = XEXP (x2, 1);
  if (x3 == const0_rtx && 1)
    goto L909;
  goto ret0;
 L909:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L910;
  if (x2 == pc_rtx && 1)
    goto L1000;
  goto ret0;
 L910:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; goto L911; }
  goto ret0;
 L911:
  x2 = XEXP (x1, 2);
  if (x2 == pc_rtx && 1)
    return 177;
  goto ret0;
 L1000:
  x2 = XEXP (x1, 2);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L1001;
  goto ret0;
 L1001:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; return 187; }
  goto ret0;
 L916:
  x3 = XEXP (x2, 0);
  if (x3 == cc0_rtx && 1)
    goto L917;
  goto ret0;
 L917:
  x3 = XEXP (x2, 1);
  if (x3 == const0_rtx && 1)
    goto L918;
  goto ret0;
 L918:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L919;
  if (x2 == pc_rtx && 1)
    goto L1009;
  goto ret0;
 L919:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; goto L920; }
  goto ret0;
 L920:
  x2 = XEXP (x1, 2);
  if (x2 == pc_rtx && 1)
    return 178;
  goto ret0;
 L1009:
  x2 = XEXP (x1, 2);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L1010;
  goto ret0;
 L1010:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; return 188; }
  goto ret0;
 L925:
  x3 = XEXP (x2, 0);
  if (x3 == cc0_rtx && 1)
    goto L926;
  goto ret0;
 L926:
  x3 = XEXP (x2, 1);
  if (x3 == const0_rtx && 1)
    goto L927;
  goto ret0;
 L927:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L928;
  if (x2 == pc_rtx && 1)
    goto L1018;
  goto ret0;
 L928:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; goto L929; }
  goto ret0;
 L929:
  x2 = XEXP (x1, 2);
  if (x2 == pc_rtx && 1)
    return 179;
  goto ret0;
 L1018:
  x2 = XEXP (x1, 2);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L1019;
  goto ret0;
 L1019:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; return 189; }
  goto ret0;
 L934:
  x3 = XEXP (x2, 0);
  if (x3 == cc0_rtx && 1)
    goto L935;
  goto ret0;
 L935:
  x3 = XEXP (x2, 1);
  if (x3 == const0_rtx && 1)
    goto L936;
  goto ret0;
 L936:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L937;
  if (x2 == pc_rtx && 1)
    goto L1027;
  goto ret0;
 L937:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; goto L938; }
  goto ret0;
 L938:
  x2 = XEXP (x1, 2);
  if (x2 == pc_rtx && 1)
    return 180;
  goto ret0;
 L1027:
  x2 = XEXP (x1, 2);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L1028;
  goto ret0;
 L1028:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; return 190; }
  goto ret0;
 L943:
  x3 = XEXP (x2, 0);
  if (x3 == cc0_rtx && 1)
    goto L944;
  goto ret0;
 L944:
  x3 = XEXP (x2, 1);
  if (x3 == const0_rtx && 1)
    goto L945;
  goto ret0;
 L945:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L946;
  if (x2 == pc_rtx && 1)
    goto L1036;
  goto ret0;
 L946:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; goto L947; }
  goto ret0;
 L947:
  x2 = XEXP (x1, 2);
  if (x2 == pc_rtx && 1)
    return 181;
  goto ret0;
 L1036:
  x2 = XEXP (x1, 2);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L1037;
  goto ret0;
 L1037:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; return 191; }
  goto ret0;
 L952:
  x3 = XEXP (x2, 0);
  if (x3 == cc0_rtx && 1)
    goto L953;
  goto ret0;
 L953:
  x3 = XEXP (x2, 1);
  if (x3 == const0_rtx && 1)
    goto L954;
  goto ret0;
 L954:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L955;
  if (x2 == pc_rtx && 1)
    goto L1045;
  goto ret0;
 L955:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; goto L956; }
  goto ret0;
 L956:
  x2 = XEXP (x1, 2);
  if (x2 == pc_rtx && 1)
    return 182;
  goto ret0;
 L1045:
  x2 = XEXP (x1, 2);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L1046;
  goto ret0;
 L1046:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[0] = x3; return 192; }
  goto ret0;
 ret0: return -1;
}

int
recog_3 (x0, insn)
     register rtx x0;
     rtx insn;
{
  register rtx x1, x2, x3, x4, x5;
  rtx x6, x7, x8, x9, x10, x11;
  int tem;
 L169:
  x1 = XEXP (x0, 1);
 switch (GET_CODE (x1))
  {
  case TRUNCATE:
  if (GET_MODE (x1) == QImode && 1)
    goto L170;
  break;
  case FIX:
  if (GET_MODE (x1) == QImode && 1)
    goto L234;
  break;
  case PLUS:
  if (GET_MODE (x1) == QImode && 1)
    goto L280;
  break;
  case MINUS:
  if (GET_MODE (x1) == QImode && 1)
    goto L323;
  break;
  case AND:
  if (GET_MODE (x1) == QImode && 1)
    goto L476;
  break;
  case IOR:
  if (GET_MODE (x1) == QImode && 1)
    goto L503;
  break;
  case XOR:
  if (GET_MODE (x1) == QImode && 1)
    goto L518;
  break;
  case NEG:
  if (GET_MODE (x1) == QImode && 1)
    goto L531;
  break;
  case NOT:
  if (GET_MODE (x1) == QImode && 1)
    goto L559;
  break;
  case ASHIFT:
  if (GET_MODE (x1) == QImode && 1)
    goto L611;
  break;
  case ASHIFTRT:
  if (GET_MODE (x1) == QImode && 1)
    goto L626;
  break;
  case LSHIFT:
  if (GET_MODE (x1) == QImode && 1)
    goto L641;
  break;
  case LSHIFTRT:
  if (GET_MODE (x1) == QImode && 1)
    goto L656;
  break;
  case ROTATE:
  if (GET_MODE (x1) == QImode && 1)
    goto L671;
  break;
  case ROTATERT:
  if (GET_MODE (x1) == QImode && 1)
    goto L686;
  break;
  case EQ:
  if (1)
    goto L820;
  break;
  case NE:
  if (1)
    goto L825;
  break;
  case GT:
  if (1)
    goto L830;
  break;
  case GTU:
  if (1)
    goto L835;
  break;
  case LT:
  if (1)
    goto L840;
  break;
  case LTU:
  if (1)
    goto L845;
  break;
  case GE:
  if (1)
    goto L850;
  break;
  case GEU:
  if (1)
    goto L855;
  break;
  case LE:
  if (1)
    goto L860;
  break;
  case LEU:
  if (1)
    goto L865;
  break;
  }
 L147:
  if (general_operand (x1, QImode))
    { recog_operand[1] = x1; return 28; }
  goto ret0;
 L170:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; return 35; }
 L174:
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; return 36; }
  goto L147;
 L234:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SFmode))
    { recog_operand[1] = x2; if (TARGET_68881) return 54; }
 L246:
  if (general_operand (x2, DFmode))
    { recog_operand[1] = x2; if (TARGET_68881) return 57; }
  goto L147;
 L280:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; goto L281; }
  goto L147;
 L281:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, QImode))
    { recog_operand[2] = x2; return 64; }
  goto L147;
 L323:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; goto L324; }
  goto L147;
 L324:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, QImode))
    { recog_operand[2] = x2; return 72; }
  goto L147;
 L476:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; goto L477; }
  goto L147;
 L477:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, QImode))
    { recog_operand[2] = x2; return 100; }
  goto L147;
 L503:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; goto L504; }
  goto L147;
 L504:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, QImode))
    { recog_operand[2] = x2; return 105; }
  goto L147;
 L518:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; goto L519; }
  goto L147;
 L519:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, QImode))
    { recog_operand[2] = x2; return 108; }
  goto L147;
 L531:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; return 111; }
  goto L147;
 L559:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; return 118; }
  goto L147;
 L611:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; goto L612; }
  goto L147;
 L612:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, QImode))
    { recog_operand[2] = x2; return 127; }
  goto L147;
 L626:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; goto L627; }
  goto L147;
 L627:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, QImode))
    { recog_operand[2] = x2; return 130; }
  goto L147;
 L641:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; goto L642; }
  goto L147;
 L642:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, QImode))
    { recog_operand[2] = x2; return 133; }
  goto L147;
 L656:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; goto L657; }
  goto L147;
 L657:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, QImode))
    { recog_operand[2] = x2; return 136; }
  goto L147;
 L671:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; goto L672; }
  goto L147;
 L672:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, QImode))
    { recog_operand[2] = x2; return 139; }
  goto L147;
 L686:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; goto L687; }
  goto L147;
 L687:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, QImode))
    { recog_operand[2] = x2; return 142; }
  goto L147;
 L820:
  x2 = XEXP (x1, 0);
  if (x2 == cc0_rtx && 1)
    goto L821;
  goto L147;
 L821:
  x2 = XEXP (x1, 1);
  if (x2 == const0_rtx && 1)
    return 163;
  goto L147;
 L825:
  x2 = XEXP (x1, 0);
  if (x2 == cc0_rtx && 1)
    goto L826;
  goto L147;
 L826:
  x2 = XEXP (x1, 1);
  if (x2 == const0_rtx && 1)
    return 164;
  goto L147;
 L830:
  x2 = XEXP (x1, 0);
  if (x2 == cc0_rtx && 1)
    goto L831;
  goto L147;
 L831:
  x2 = XEXP (x1, 1);
  if (x2 == const0_rtx && 1)
    return 165;
  goto L147;
 L835:
  x2 = XEXP (x1, 0);
  if (x2 == cc0_rtx && 1)
    goto L836;
  goto L147;
 L836:
  x2 = XEXP (x1, 1);
  if (x2 == const0_rtx && 1)
    return 166;
  goto L147;
 L840:
  x2 = XEXP (x1, 0);
  if (x2 == cc0_rtx && 1)
    goto L841;
  goto L147;
 L841:
  x2 = XEXP (x1, 1);
  if (x2 == const0_rtx && 1)
    return 167;
  goto L147;
 L845:
  x2 = XEXP (x1, 0);
  if (x2 == cc0_rtx && 1)
    goto L846;
  goto L147;
 L846:
  x2 = XEXP (x1, 1);
  if (x2 == const0_rtx && 1)
    return 168;
  goto L147;
 L850:
  x2 = XEXP (x1, 0);
  if (x2 == cc0_rtx && 1)
    goto L851;
  goto L147;
 L851:
  x2 = XEXP (x1, 1);
  if (x2 == const0_rtx && 1)
    return 169;
  goto L147;
 L855:
  x2 = XEXP (x1, 0);
  if (x2 == cc0_rtx && 1)
    goto L856;
  goto L147;
 L856:
  x2 = XEXP (x1, 1);
  if (x2 == const0_rtx && 1)
    return 170;
  goto L147;
 L860:
  x2 = XEXP (x1, 0);
  if (x2 == cc0_rtx && 1)
    goto L861;
  goto L147;
 L861:
  x2 = XEXP (x1, 1);
  if (x2 == const0_rtx && 1)
    return 171;
  goto L147;
 L865:
  x2 = XEXP (x1, 0);
  if (x2 == cc0_rtx && 1)
    goto L866;
  goto L147;
 L866:
  x2 = XEXP (x1, 1);
  if (x2 == const0_rtx && 1)
    return 172;
  goto L147;
 ret0: return -1;
}

int
recog_4 (x0, insn)
     register rtx x0;
     rtx insn;
{
  register rtx x1, x2, x3, x4, x5;
  rtx x6, x7, x8, x9, x10, x11;
  int tem;
 L177:
  x1 = XEXP (x0, 1);
 switch (GET_CODE (x1))
  {
  case TRUNCATE:
  if (GET_MODE (x1) == HImode && 1)
    goto L178;
  break;
  case SIGN_EXTEND:
  if (GET_MODE (x1) == HImode && 1)
    goto L186;
  break;
  case FIX:
  if (GET_MODE (x1) == HImode && 1)
    goto L238;
  break;
  case PLUS:
  if (GET_MODE (x1) == HImode && 1)
    goto L269;
  break;
  case MINUS:
  if (GET_MODE (x1) == HImode && 1)
    goto L312;
  break;
  case MULT:
  if (GET_MODE (x1) == HImode && 1)
    goto L344;
  break;
  case UMULT:
  if (GET_MODE (x1) == HImode && 1)
    goto L359;
  break;
  case DIV:
  if (GET_MODE (x1) == HImode && 1)
    goto L384;
  break;
  case UDIV:
  if (GET_MODE (x1) == HImode && 1)
    goto L399;
  break;
  case MOD:
  if (GET_MODE (x1) == HImode && 1)
    goto L424;
  break;
  case UMOD:
  if (GET_MODE (x1) == HImode && 1)
    goto L434;
  break;
  case AND:
  if (GET_MODE (x1) == HImode && 1)
    goto L471;
  break;
  case IOR:
  if (GET_MODE (x1) == HImode && 1)
    goto L498;
  break;
  case XOR:
  if (GET_MODE (x1) == HImode && 1)
    goto L513;
  break;
  case NEG:
  if (GET_MODE (x1) == HImode && 1)
    goto L527;
  break;
  case NOT:
  if (GET_MODE (x1) == HImode && 1)
    goto L555;
  break;
  case ASHIFT:
  if (GET_MODE (x1) == HImode && 1)
    goto L606;
  break;
  case ASHIFTRT:
  if (GET_MODE (x1) == HImode && 1)
    goto L621;
  break;
  case LSHIFT:
  if (GET_MODE (x1) == HImode && 1)
    goto L636;
  break;
  case LSHIFTRT:
  if (GET_MODE (x1) == HImode && 1)
    goto L651;
  break;
  case ROTATE:
  if (GET_MODE (x1) == HImode && 1)
    goto L666;
  break;
  case ROTATERT:
  if (GET_MODE (x1) == HImode && 1)
    goto L681;
  break;
  }
 L140:
  if (general_operand (x1, HImode))
    { recog_operand[1] = x1; return 26; }
  goto ret0;
 L178:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; return 37; }
  goto L140;
 L186:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; return 42; }
  goto L140;
 L238:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SFmode))
    { recog_operand[1] = x2; if (TARGET_68881) return 55; }
 L250:
  if (general_operand (x2, DFmode))
    { recog_operand[1] = x2; if (TARGET_68881) return 58; }
  goto L140;
 L269:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; goto L270; }
  goto L140;
 L270:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 62; }
  goto L140;
 L312:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; goto L313; }
  goto L140;
 L313:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 70; }
  goto L140;
 L344:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; goto L345; }
  goto L140;
 L345:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 76; }
  goto L140;
 L359:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; goto L360; }
  goto L140;
 L360:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 79; }
  goto L140;
 L384:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; goto L385; }
 L389:
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L390; }
  goto L140;
 L385:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 84; }
  x2 = XEXP (x1, 0);
  goto L389;
 L390:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 85; }
  goto L140;
 L399:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; goto L400; }
 L404:
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L405; }
  goto L140;
 L400:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 87; }
  x2 = XEXP (x1, 0);
  goto L404;
 L405:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 88; }
  goto L140;
 L424:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; goto L425; }
 L429:
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L430; }
  goto L140;
 L425:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 92; }
  x2 = XEXP (x1, 0);
  goto L429;
 L430:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 93; }
  goto L140;
 L434:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; goto L435; }
 L439:
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L440; }
  goto L140;
 L435:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 94; }
  x2 = XEXP (x1, 0);
  goto L439;
 L440:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 95; }
  goto L140;
 L471:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; goto L472; }
  goto L140;
 L472:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 99; }
  goto L140;
 L498:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; goto L499; }
  goto L140;
 L499:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 104; }
  goto L140;
 L513:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; goto L514; }
  goto L140;
 L514:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 107; }
  goto L140;
 L527:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; return 110; }
  goto L140;
 L555:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; return 117; }
  goto L140;
 L606:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; goto L607; }
  goto L140;
 L607:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 126; }
  goto L140;
 L621:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; goto L622; }
  goto L140;
 L622:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 129; }
  goto L140;
 L636:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; goto L637; }
  goto L140;
 L637:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 132; }
  goto L140;
 L651:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; goto L652; }
  goto L140;
 L652:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 135; }
  goto L140;
 L666:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; goto L667; }
  goto L140;
 L667:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 138; }
  goto L140;
 L681:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; goto L682; }
  goto L140;
 L682:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 141; }
  goto L140;
 ret0: return -1;
}

int
recog_5 (x0, insn)
     register rtx x0;
     rtx insn;
{
  register rtx x1, x2, x3, x4, x5;
  rtx x6, x7, x8, x9, x10, x11;
  int tem;
 L181:
  x1 = XEXP (x0, 1);
 switch (GET_CODE (x1))
  {
  case SIGN_EXTEND:
  if (GET_MODE (x1) == SImode && 1)
    goto L182;
  break;
  case FIX:
  if (GET_MODE (x1) == SImode && 1)
    goto L242;
  break;
  case PLUS:
  if (GET_MODE (x1) == SImode && 1)
    goto L258;
  break;
  case MINUS:
  if (GET_MODE (x1) == SImode && 1)
    goto L301;
  break;
  case MULT:
  if (GET_MODE (x1) == SImode && 1)
    goto L349;
  break;
  case UMULT:
  if (GET_MODE (x1) == SImode && 1)
    goto L364;
  break;
  case DIV:
  if (GET_MODE (x1) == SImode && 1)
    goto L394;
  break;
  case UDIV:
  if (GET_MODE (x1) == SImode && 1)
    goto L409;
  break;
  case AND:
  if (GET_MODE (x1) == SImode && 1)
    goto L481;
  break;
  case IOR:
  if (GET_MODE (x1) == SImode && 1)
    goto L493;
  break;
  case XOR:
  if (GET_MODE (x1) == SImode && 1)
    goto L508;
  break;
  case NEG:
  if (GET_MODE (x1) == SImode && 1)
    goto L523;
  break;
  case NOT:
  if (GET_MODE (x1) == SImode && 1)
    goto L551;
  break;
  case ASHIFTRT:
  if (GET_MODE (x1) == SImode && 1)
    goto L563;
  break;
  case LSHIFTRT:
  if (GET_MODE (x1) == SImode && 1)
    goto L568;
  break;
  case ASHIFT:
  if (GET_MODE (x1) == SImode && 1)
    goto L601;
  break;
  case LSHIFT:
  if (GET_MODE (x1) == SImode && 1)
    goto L631;
  break;
  case ROTATE:
  if (GET_MODE (x1) == SImode && 1)
    goto L661;
  break;
  case ROTATERT:
  if (GET_MODE (x1) == SImode && 1)
    goto L676;
  break;
  case ZERO_EXTRACT:
  if (GET_MODE (x1) == SImode && 1)
    goto L715;
  break;
  case SIGN_EXTRACT:
  if (GET_MODE (x1) == SImode && 1)
    goto L709;
  break;
  }
 L166:
  if (address_operand (x1, QImode))
    { recog_operand[1] = x1; return 34; }
  goto ret0;
 L182:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; return 41; }
 L190:
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; if (TARGET_68020) return 43; }
  goto L166;
 L242:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SFmode))
    { recog_operand[1] = x2; if (TARGET_68881) return 56; }
 L254:
  if (general_operand (x2, DFmode))
    { recog_operand[1] = x2; if (TARGET_68881) return 59; }
  goto L166;
 L258:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L264; }
  goto L166;
 L264:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == SIGN_EXTEND && GET_MODE (x2) == SImode && 1)
    goto L265;
 L259:
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; return 60; }
  goto L166;
 L265:
  x3 = XEXP (x2, 0);
  if (general_operand (x3, HImode))
    { recog_operand[2] = x3; return 61; }
  goto L259;
 L301:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L307; }
  goto L166;
 L307:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == SIGN_EXTEND && GET_MODE (x2) == SImode && 1)
    goto L308;
 L302:
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; return 68; }
  goto L166;
 L308:
  x3 = XEXP (x2, 0);
  if (general_operand (x3, HImode))
    { recog_operand[2] = x3; return 69; }
  goto L302;
 L349:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; goto L350; }
 L354:
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L355; }
  goto L166;
 L350:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 77; }
  x2 = XEXP (x1, 0);
  goto L354;
 L355:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; if (TARGET_68020) return 78; }
  goto L166;
 L364:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; goto L365; }
 L369:
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L370; }
  goto L166;
 L365:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[2] = x2; return 80; }
  x2 = XEXP (x1, 0);
  goto L369;
 L370:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; if (TARGET_68020) return 81; }
  goto L166;
 L394:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L395; }
  goto L166;
 L395:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; if (TARGET_68020) return 86; }
  goto L166;
 L409:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L410; }
  goto L166;
 L410:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; if (TARGET_68020) return 89; }
  goto L166;
 L481:
  x2 = XEXP (x1, 0);
  if (GET_CODE (x2) == ZERO_EXTEND && GET_MODE (x2) == SImode && 1)
    goto L482;
 L466:
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L467; }
  goto L166;
 L482:
  x3 = XEXP (x2, 0);
  if (general_operand (x3, HImode))
    { recog_operand[1] = x3; goto L483; }
 L488:
  if (general_operand (x3, QImode))
    { recog_operand[1] = x3; goto L489; }
  goto L466;
 L483:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; if (GET_CODE (operands[2]) == CONST_INT
   && (unsigned int) INTVAL (operands[2]) < (1 << GET_MODE_BITSIZE (HImode))) return 101; }
  x2 = XEXP (x1, 0);
  x3 = XEXP (x2, 0);
  goto L488;
 L489:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; if (GET_CODE (operands[2]) == CONST_INT
   && (unsigned int) INTVAL (operands[2]) < (1 << GET_MODE_BITSIZE (QImode))) return 102; }
  x2 = XEXP (x1, 0);
  goto L466;
 L467:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; return 98; }
  goto L166;
 L493:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L494; }
  goto L166;
 L494:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; return 103; }
  goto L166;
 L508:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L509; }
  goto L166;
 L509:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; return 106; }
  goto L166;
 L523:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; return 109; }
  goto L166;
 L551:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; return 116; }
  goto L166;
 L563:
  x2 = XEXP (x1, 0);
  if (memory_operand (x2, SImode))
    { recog_operand[1] = x2; goto L564; }
 L616:
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L617; }
  goto L166;
 L564:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == CONST_INT && XINT (x2, 0) == 24 && 1)
    return 119;
  x2 = XEXP (x1, 0);
  goto L616;
 L617:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; return 128; }
  goto L166;
 L568:
  x2 = XEXP (x1, 0);
  if (memory_operand (x2, SImode))
    { recog_operand[1] = x2; goto L569; }
 L646:
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L647; }
  goto L166;
 L569:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == CONST_INT && XINT (x2, 0) == 24 && 1)
    return 120;
  x2 = XEXP (x1, 0);
  goto L646;
 L647:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; return 134; }
  goto L166;
 L601:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L602; }
  goto L166;
 L602:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; return 125; }
  goto L166;
 L631:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L632; }
  goto L166;
 L632:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; return 131; }
  goto L166;
 L661:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L662; }
  goto L166;
 L662:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; return 137; }
  goto L166;
 L676:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L677; }
  goto L166;
 L677:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; return 140; }
  goto L166;
 L715:
  x2 = XEXP (x1, 0);
  if (nonimmediate_operand (x2, QImode))
    { recog_operand[1] = x2; goto L716; }
 L697:
  if (nonimmediate_operand (x2, SImode))
    { recog_operand[1] = x2; goto L698; }
  goto L166;
 L716:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; goto L717; }
  x2 = XEXP (x1, 0);
  goto L697;
 L717:
  x2 = XEXP (x1, 2);
  if (general_operand (x2, SImode))
    { recog_operand[3] = x2; if (TARGET_68020 && TARGET_BITFIELD) return 147; }
  x2 = XEXP (x1, 0);
  goto L697;
 L698:
  x2 = XEXP (x1, 1);
  if (immediate_operand (x2, SImode))
    { recog_operand[2] = x2; goto L699; }
 L757:
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; goto L758; }
  goto L166;
 L699:
  x2 = XEXP (x1, 2);
  if (immediate_operand (x2, SImode))
    { recog_operand[3] = x2; if (TARGET_68020 && TARGET_BITFIELD
   && GET_CODE (operands[2]) == CONST_INT
   && (INTVAL (operands[2]) == 8 || INTVAL (operands[2]) == 16)
   && GET_CODE (operands[3]) == CONST_INT
   && INTVAL (operands[3]) % INTVAL (operands[2]) == 0
   && (GET_CODE (operands[1]) == REG
       || ! mode_dependent_address_p (XEXP (operands[1], 0)))) return 144; }
  x2 = XEXP (x1, 1);
  goto L757;
 L758:
  x2 = XEXP (x1, 2);
  if (general_operand (x2, SImode))
    { recog_operand[3] = x2; if (TARGET_68020 && TARGET_BITFIELD) return 153; }
  goto L166;
 L709:
  x2 = XEXP (x1, 0);
  if (nonimmediate_operand (x2, QImode))
    { recog_operand[1] = x2; goto L710; }
 L703:
  if (nonimmediate_operand (x2, SImode))
    { recog_operand[1] = x2; goto L704; }
  goto L166;
 L710:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; goto L711; }
  x2 = XEXP (x1, 0);
  goto L703;
 L711:
  x2 = XEXP (x1, 2);
  if (general_operand (x2, SImode))
    { recog_operand[3] = x2; if (TARGET_68020 && TARGET_BITFIELD) return 146; }
  x2 = XEXP (x1, 0);
  goto L703;
 L704:
  x2 = XEXP (x1, 1);
  if (immediate_operand (x2, SImode))
    { recog_operand[2] = x2; goto L705; }
 L751:
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; goto L752; }
  goto L166;
 L705:
  x2 = XEXP (x1, 2);
  if (immediate_operand (x2, SImode))
    { recog_operand[3] = x2; if (TARGET_68020 && TARGET_BITFIELD
   && GET_CODE (operands[2]) == CONST_INT
   && (INTVAL (operands[2]) == 8 || INTVAL (operands[2]) == 16)
   && GET_CODE (operands[3]) == CONST_INT
   && INTVAL (operands[3]) % INTVAL (operands[2]) == 0
   && (GET_CODE (operands[1]) == REG
       || ! mode_dependent_address_p (XEXP (operands[1], 0)))) return 145; }
  x2 = XEXP (x1, 1);
  goto L751;
 L752:
  x2 = XEXP (x1, 2);
  if (general_operand (x2, SImode))
    { recog_operand[3] = x2; if (TARGET_68020 && TARGET_BITFIELD) return 152; }
  goto L166;
 ret0: return -1;
}

int
recog_6 (x0, insn)
     register rtx x0;
     rtx insn;
{
  register rtx x1, x2, x3, x4, x5;
  rtx x6, x7, x8, x9, x10, x11;
  int tem;
 L7:
  x1 = XEXP (x0, 0);
  if (x1 == cc0_rtx && 1)
    goto L23;
  if (GET_CODE (x1) == STRICT_LOW_PART && 1)
    goto L150;
  if (x1 == pc_rtx && 1)
    goto L869;
 L1102:
  if (1)
    { recog_operand[0] = x1; goto L1103; }
 L146:
 switch (GET_MODE (x1))
  {
  case QImode:
  if (general_operand (x1, QImode))
    { recog_operand[0] = x1; goto L169; }
  break;
 L139:
  case HImode:
  if (general_operand (x1, HImode))
    { recog_operand[0] = x1; goto L177; }
  break;
  case SImode:
  if (GET_CODE (x1) == ZERO_EXTRACT && 1)
    goto L720;
 L130:
  if (general_operand (x1, SImode))
    { recog_operand[0] = x1; goto L131; }
 L133:
  if (push_operand (x1, SImode))
    { recog_operand[0] = x1; goto L134; }
 L136:
  if (general_operand (x1, SImode))
    { recog_operand[0] = x1; goto L137; }
 L162:
  if (push_operand (x1, SImode))
    { recog_operand[0] = x1; goto L163; }
 L165:
  if (general_operand (x1, SImode))
    { recog_operand[0] = x1; goto L181; }
  break;
  case DImode:
  if (push_operand (x1, DImode))
    { recog_operand[0] = x1; goto L5; }
 L159:
  if (general_operand (x1, DImode))
    { recog_operand[0] = x1; goto L160; }
  break;
  case SFmode:
  if (general_operand (x1, SFmode))
    { recog_operand[0] = x1; goto L197; }
  break;
  case DFmode:
  if (push_operand (x1, DFmode))
    { recog_operand[0] = x1; goto L2; }
 L156:
  if (general_operand (x1, DFmode))
    { recog_operand[0] = x1; goto L193; }
  break;
  }
  goto ret0;
 L23:
  tem = recog_1 (x0, insn);
  if (tem >= 0) return tem;
  goto L1102;
 L150:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, QImode))
    { recog_operand[0] = x2; goto L285; }
 L143:
  if (general_operand (x2, HImode))
    { recog_operand[0] = x2; goto L274; }
  goto L1102;
 L285:
  x1 = XEXP (x0, 1);
  if (GET_CODE (x1) == PLUS && GET_MODE (x1) == QImode && 1)
    goto L286;
  if (GET_CODE (x1) == MINUS && GET_MODE (x1) == QImode && 1)
    goto L329;
 L151:
  if (general_operand (x1, QImode))
    { recog_operand[1] = x1; return 29; }
  x1 = XEXP (x0, 0);
  x2 = XEXP (x1, 0);
  goto L143;
 L286:
  x2 = XEXP (x1, 0);
  if (rtx_equal_p (x2, recog_operand[0]) && 1)
    goto L287;
  goto L151;
 L287:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; return 65; }
  goto L151;
 L329:
  x2 = XEXP (x1, 0);
  if (rtx_equal_p (x2, recog_operand[0]) && 1)
    goto L330;
  goto L151;
 L330:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; return 73; }
  goto L151;
 L274:
  x1 = XEXP (x0, 1);
  if (GET_CODE (x1) == PLUS && GET_MODE (x1) == HImode && 1)
    goto L275;
  if (GET_CODE (x1) == MINUS && GET_MODE (x1) == HImode && 1)
    goto L318;
 L144:
  if (general_operand (x1, HImode))
    { recog_operand[1] = x1; return 27; }
  x1 = XEXP (x0, 0);
  goto L1102;
 L275:
  x2 = XEXP (x1, 0);
  if (rtx_equal_p (x2, recog_operand[0]) && 1)
    goto L276;
  goto L144;
 L276:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; return 63; }
  goto L144;
 L318:
  x2 = XEXP (x1, 0);
  if (rtx_equal_p (x2, recog_operand[0]) && 1)
    goto L319;
  goto L144;
 L319:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; return 71; }
  goto L144;
 L869:
  x1 = XEXP (x0, 1);
  if (GET_CODE (x1) == IF_THEN_ELSE && 1)
    goto L870;
  if (GET_CODE (x1) == LABEL_REF && 1)
    goto L1059;
  x1 = XEXP (x0, 0);
  goto L1102;
 L870:
  tem = recog_2 (x0, insn);
  if (tem >= 0) return tem;
  x1 = XEXP (x0, 0);
  goto L1102;
 L1059:
  x2 = XEXP (x1, 0);
  if (1)
    { recog_operand[0] = x2; return 197; }
  x1 = XEXP (x0, 0);
  goto L1102;
 L1103:
  x1 = XEXP (x0, 1);
  if (GET_CODE (x1) == CALL && 1)
    goto L1104;
  x1 = XEXP (x0, 0);
  goto L146;
 L1104:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; goto L1105; }
  x1 = XEXP (x0, 0);
  goto L146;
 L1105:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; return 201; }
  x1 = XEXP (x0, 0);
  goto L146;
 L169:
  tem = recog_3 (x0, insn);
  if (tem >= 0) return tem;
  goto L139;
 L177:
  return recog_4 (x0, insn);
 L720:
  x2 = XEXP (x1, 0);
  if (nonimmediate_operand (x2, QImode))
    { recog_operand[0] = x2; goto L721; }
 L690:
  if (nonimmediate_operand (x2, SImode))
    { recog_operand[0] = x2; goto L691; }
  goto L130;
 L721:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L722; }
  x2 = XEXP (x1, 0);
  goto L690;
 L722:
  x2 = XEXP (x1, 2);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; goto L723; }
  x2 = XEXP (x1, 0);
  goto L690;
 L723:
  x1 = XEXP (x0, 1);
  if (GET_CODE (x1) == XOR && GET_MODE (x1) == SImode && 1)
    goto L724;
  if (x1 == const0_rtx && 1)
    if (TARGET_68020 && TARGET_BITFIELD) return 149;
 L740:
  if (GET_CODE (x1) == CONST_INT && XINT (x1, 0) == -1 && 1)
    if (TARGET_68020 && TARGET_BITFIELD) return 150;
 L746:
  if (general_operand (x1, SImode))
    { recog_operand[3] = x1; if (TARGET_68020 && TARGET_BITFIELD) return 151; }
  x1 = XEXP (x0, 0);
  x2 = XEXP (x1, 0);
  goto L690;
 L724:
  x2 = XEXP (x1, 0);
  if (GET_CODE (x2) == ZERO_EXTRACT && GET_MODE (x2) == SImode && 1)
    goto L725;
  goto L746;
 L725:
  x3 = XEXP (x2, 0);
  if (rtx_equal_p (x3, recog_operand[0]) && 1)
    goto L726;
  goto L746;
 L726:
  x3 = XEXP (x2, 1);
  if (rtx_equal_p (x3, recog_operand[1]) && 1)
    goto L727;
  goto L746;
 L727:
  x3 = XEXP (x2, 2);
  if (rtx_equal_p (x3, recog_operand[2]) && 1)
    goto L728;
  goto L746;
 L728:
  x2 = XEXP (x1, 1);
  if (immediate_operand (x2, VOIDmode))
    { recog_operand[3] = x2; if (TARGET_68020 && TARGET_BITFIELD
   && GET_CODE (operands[3]) == CONST_INT
   && (INTVAL (operands[3]) == -1
       || (GET_CODE (operands[1]) == CONST_INT
           && (~ INTVAL (operands[3]) & ((1 << INTVAL (operands[1]))- 1)) == 0))) return 148; }
  goto L746;
 L691:
  x2 = XEXP (x1, 1);
  if (immediate_operand (x2, SImode))
    { recog_operand[1] = x2; goto L692; }
 L762:
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L763; }
  goto L130;
 L692:
  x2 = XEXP (x1, 2);
  if (immediate_operand (x2, SImode))
    { recog_operand[2] = x2; goto L693; }
  x2 = XEXP (x1, 1);
  goto L762;
 L693:
  x1 = XEXP (x0, 1);
  if (general_operand (x1, SImode))
    { recog_operand[3] = x1; if (TARGET_68020 && TARGET_BITFIELD
   && GET_CODE (operands[1]) == CONST_INT
   && (INTVAL (operands[1]) == 8 || INTVAL (operands[1]) == 16)
   && GET_CODE (operands[2]) == CONST_INT
   && INTVAL (operands[2]) % INTVAL (operands[1]) == 0
   && (GET_CODE (operands[0]) == REG
       || ! mode_dependent_address_p (XEXP (operands[0], 0)))) return 143; }
  x1 = XEXP (x0, 0);
  x2 = XEXP (x1, 1);
  goto L762;
 L763:
  x2 = XEXP (x1, 2);
  if (general_operand (x2, SImode))
    { recog_operand[2] = x2; goto L764; }
  goto L130;
 L764:
  x1 = XEXP (x0, 1);
  if (x1 == const0_rtx && 1)
    if (TARGET_68020 && TARGET_BITFIELD) return 154;
 L770:
  if (GET_CODE (x1) == CONST_INT && XINT (x1, 0) == -1 && 1)
    if (TARGET_68020 && TARGET_BITFIELD) return 155;
 L776:
  if (general_operand (x1, SImode))
    { recog_operand[3] = x1; if (TARGET_68020 && TARGET_BITFIELD) return 156; }
  x1 = XEXP (x0, 0);
  goto L130;
 L131:
  x1 = XEXP (x0, 1);
  if (x1 == const0_rtx && 1)
    return 23;
  x1 = XEXP (x0, 0);
  goto L133;
 L134:
  x1 = XEXP (x0, 1);
  if (general_operand (x1, SImode))
    { recog_operand[1] = x1; if (GET_CODE (operands[1]) == CONST_INT
   && INTVAL (operands[1]) >= -0x8000
   && INTVAL (operands[1]) < 0x8000) return 24; }
  x1 = XEXP (x0, 0);
  goto L136;
 L137:
  x1 = XEXP (x0, 1);
  if (general_operand (x1, SImode))
    { recog_operand[1] = x1; return 25; }
  x1 = XEXP (x0, 0);
  goto L162;
 L163:
  x1 = XEXP (x0, 1);
  if (address_operand (x1, SImode))
    { recog_operand[1] = x1; return 33; }
  x1 = XEXP (x0, 0);
  goto L165;
 L181:
  return recog_5 (x0, insn);
 L5:
  x1 = XEXP (x0, 1);
  if (general_operand (x1, DImode))
    { recog_operand[1] = x1; return 1; }
  x1 = XEXP (x0, 0);
  goto L159;
 L160:
  x1 = XEXP (x0, 1);
  if (general_operand (x1, DImode))
    { recog_operand[1] = x1; return 32; }
  goto ret0;
 L197:
  x1 = XEXP (x0, 1);
 switch (GET_CODE (x1))
  {
  case FLOAT_TRUNCATE:
  if (GET_MODE (x1) == SFmode && 1)
    goto L198;
  break;
  case FLOAT:
  if (GET_MODE (x1) == SFmode && 1)
    goto L202;
  break;
  case FIX:
  if (GET_MODE (x1) == SFmode && 1)
    goto L230;
  break;
  case PLUS:
  if (GET_MODE (x1) == SFmode && 1)
    goto L296;
  break;
  case MINUS:
  if (GET_MODE (x1) == SFmode && 1)
    goto L339;
  break;
  case MULT:
  if (GET_MODE (x1) == SFmode && 1)
    goto L379;
  break;
  case DIV:
  if (GET_MODE (x1) == SFmode && 1)
    goto L419;
  break;
  case NEG:
  if (GET_MODE (x1) == SFmode && 1)
    goto L535;
  break;
  case ABS:
  if (GET_MODE (x1) == SFmode && 1)
    goto L543;
  break;
  }
 L154:
  if (general_operand (x1, SFmode))
    { recog_operand[1] = x1; return 30; }
  goto ret0;
 L198:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, DFmode))
    { recog_operand[1] = x2; if (TARGET_68881) return 45; }
  goto L154;
 L202:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; if (TARGET_68881) return 46; }
 L210:
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; if (TARGET_68881) return 48; }
 L218:
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; if (TARGET_68881) return 50; }
  goto L154;
 L230:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SFmode))
    { recog_operand[1] = x2; if (TARGET_68881) return 53; }
  goto L154;
 L296:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SFmode))
    { recog_operand[1] = x2; goto L297; }
  goto L154;
 L297:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SFmode))
    { recog_operand[2] = x2; if (TARGET_68881) return 67; }
  goto L154;
 L339:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SFmode))
    { recog_operand[1] = x2; goto L340; }
  goto L154;
 L340:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SFmode))
    { recog_operand[2] = x2; if (TARGET_68881) return 75; }
  goto L154;
 L379:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SFmode))
    { recog_operand[1] = x2; goto L380; }
  goto L154;
 L380:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SFmode))
    { recog_operand[2] = x2; if (TARGET_68881) return 83; }
  goto L154;
 L419:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SFmode))
    { recog_operand[1] = x2; goto L420; }
  goto L154;
 L420:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, SFmode))
    { recog_operand[2] = x2; if (TARGET_68881) return 91; }
  goto L154;
 L535:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SFmode))
    { recog_operand[1] = x2; if (TARGET_68881) return 112; }
  goto L154;
 L543:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SFmode))
    { recog_operand[1] = x2; if (TARGET_68881) return 114; }
  goto L154;
 L2:
  x1 = XEXP (x0, 1);
  if (general_operand (x1, DFmode))
    { recog_operand[1] = x1; return 0; }
  x1 = XEXP (x0, 0);
  goto L156;
 L193:
  x1 = XEXP (x0, 1);
 switch (GET_CODE (x1))
  {
  case FLOAT_EXTEND:
  if (GET_MODE (x1) == DFmode && 1)
    goto L194;
  break;
  case FLOAT:
  if (GET_MODE (x1) == DFmode && 1)
    goto L206;
  break;
  case FIX:
  if (GET_MODE (x1) == DFmode && 1)
    goto L226;
  break;
  case PLUS:
  if (GET_MODE (x1) == DFmode && 1)
    goto L291;
  break;
  case MINUS:
  if (GET_MODE (x1) == DFmode && 1)
    goto L334;
  break;
  case MULT:
  if (GET_MODE (x1) == DFmode && 1)
    goto L374;
  break;
  case DIV:
  if (GET_MODE (x1) == DFmode && 1)
    goto L414;
  break;
  case NEG:
  if (GET_MODE (x1) == DFmode && 1)
    goto L539;
  break;
  case ABS:
  if (GET_MODE (x1) == DFmode && 1)
    goto L547;
  break;
  }
 L157:
  if (general_operand (x1, DFmode))
    { recog_operand[1] = x1; return 31; }
  goto ret0;
 L194:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SFmode))
    { recog_operand[1] = x2; if (TARGET_68881) return 44; }
  goto L157;
 L206:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; if (TARGET_68881) return 47; }
 L214:
  if (general_operand (x2, HImode))
    { recog_operand[1] = x2; if (TARGET_68881) return 49; }
 L222:
  if (general_operand (x2, QImode))
    { recog_operand[1] = x2; if (TARGET_68881) return 51; }
  goto L157;
 L226:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, DFmode))
    { recog_operand[1] = x2; if (TARGET_68881) return 52; }
  goto L157;
 L291:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, DFmode))
    { recog_operand[1] = x2; goto L292; }
  goto L157;
 L292:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, DFmode))
    { recog_operand[2] = x2; if (TARGET_68881) return 66; }
  goto L157;
 L334:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, DFmode))
    { recog_operand[1] = x2; goto L335; }
  goto L157;
 L335:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, DFmode))
    { recog_operand[2] = x2; if (TARGET_68881) return 74; }
  goto L157;
 L374:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, DFmode))
    { recog_operand[1] = x2; goto L375; }
  goto L157;
 L375:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, DFmode))
    { recog_operand[2] = x2; if (TARGET_68881) return 82; }
  goto L157;
 L414:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, DFmode))
    { recog_operand[1] = x2; goto L415; }
  goto L157;
 L415:
  x2 = XEXP (x1, 1);
  if (general_operand (x2, DFmode))
    { recog_operand[2] = x2; if (TARGET_68881) return 90; }
  goto L157;
 L539:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, DFmode))
    { recog_operand[1] = x2; if (TARGET_68881) return 113; }
  goto L157;
 L547:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, DFmode))
    { recog_operand[1] = x2; if (TARGET_68881) return 115; }
  goto L157;
 ret0: return -1;
}

int
recog_7 (x0, insn)
     register rtx x0;
     rtx insn;
{
  register rtx x1, x2, x3, x4, x5;
  rtx x6, x7, x8, x9, x10, x11;
  int tem;
 L1049:
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 0);
  if (x2 == pc_rtx && 1)
    goto L1050;
 L124:
  if (general_operand (x2, SImode))
    { recog_operand[0] = x2; goto L444; }
  goto ret0;
 L1050:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == PLUS && GET_MODE (x2) == SImode && 1)
    goto L1051;
  if (GET_CODE (x2) == IF_THEN_ELSE && 1)
    goto L1064;
  x2 = XEXP (x1, 0);
  goto L124;
 L1051:
  x3 = XEXP (x2, 0);
  if (x3 == pc_rtx && 1)
    goto L1052;
  x2 = XEXP (x1, 0);
  goto L124;
 L1052:
  x3 = XEXP (x2, 1);
  if (general_operand (x3, HImode))
    { recog_operand[0] = x3; goto L1053; }
  x2 = XEXP (x1, 0);
  goto L124;
 L1053:
  x1 = XVECEXP (x0, 0, 1);
  if (GET_CODE (x1) == USE && 1)
    goto L1054;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 0);
  goto L124;
 L1054:
  x2 = XEXP (x1, 0);
  if (GET_CODE (x2) == LABEL_REF && 1)
    goto L1055;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 0);
  goto L124;
 L1055:
  x3 = XEXP (x2, 0);
  if (1)
    { recog_operand[1] = x3; return 196; }
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 0);
  goto L124;
 L1064:
  x3 = XEXP (x2, 0);
  if (GET_CODE (x3) == NE && 1)
    goto L1065;
  x2 = XEXP (x1, 0);
  goto L124;
 L1065:
  x4 = XEXP (x3, 0);
  if (GET_CODE (x4) == MINUS && 1)
    goto L1066;
  x2 = XEXP (x1, 0);
  goto L124;
 L1066:
  x5 = XEXP (x4, 0);
  if (GET_CODE (x5) != PLUS)
    {  x2 = XEXP (x1, 0);
    goto L124; }
  if (GET_MODE (x5) == HImode && 1)
    goto L1067;
  if (GET_MODE (x5) == SImode && 1)
    goto L1086;
  x2 = XEXP (x1, 0);
  goto L124;
 L1067:
  x6 = XEXP (x5, 0);
  if (general_operand (x6, HImode))
    { recog_operand[0] = x6; goto L1068; }
  x2 = XEXP (x1, 0);
  goto L124;
 L1068:
  x6 = XEXP (x5, 1);
  if (GET_CODE (x6) == CONST_INT && XINT (x6, 0) == -1 && 1)
    goto L1069;
  x2 = XEXP (x1, 0);
  goto L124;
 L1069:
  x5 = XEXP (x4, 1);
  if (GET_CODE (x5) == CONST_INT && XINT (x5, 0) == -1 && 1)
    goto L1070;
  x2 = XEXP (x1, 0);
  goto L124;
 L1070:
  x4 = XEXP (x3, 1);
  if (x4 == const0_rtx && 1)
    goto L1071;
  x2 = XEXP (x1, 0);
  goto L124;
 L1071:
  x3 = XEXP (x2, 1);
  if (GET_CODE (x3) == LABEL_REF && 1)
    goto L1072;
  x2 = XEXP (x1, 0);
  goto L124;
 L1072:
  x4 = XEXP (x3, 0);
  if (1)
    { recog_operand[1] = x4; goto L1073; }
  x2 = XEXP (x1, 0);
  goto L124;
 L1073:
  x3 = XEXP (x2, 2);
  if (x3 == pc_rtx && 1)
    goto L1074;
  x2 = XEXP (x1, 0);
  goto L124;
 L1074:
  x1 = XVECEXP (x0, 0, 1);
  if (GET_CODE (x1) == SET && 1)
    goto L1075;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 0);
  goto L124;
 L1075:
  x2 = XEXP (x1, 0);
  if (rtx_equal_p (x2, recog_operand[0]) && 1)
    goto L1076;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 0);
  goto L124;
 L1076:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == PLUS && GET_MODE (x2) == HImode && 1)
    goto L1077;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 0);
  goto L124;
 L1077:
  x3 = XEXP (x2, 0);
  if (rtx_equal_p (x3, recog_operand[0]) && 1)
    goto L1078;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 0);
  goto L124;
 L1078:
  x3 = XEXP (x2, 1);
  if (GET_CODE (x3) == CONST_INT && XINT (x3, 0) == -1 && 1)
    return 198;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 0);
  goto L124;
 L1086:
  x6 = XEXP (x5, 0);
  if (general_operand (x6, SImode))
    { recog_operand[0] = x6; goto L1087; }
  x2 = XEXP (x1, 0);
  goto L124;
 L1087:
  x6 = XEXP (x5, 1);
  if (GET_CODE (x6) == CONST_INT && XINT (x6, 0) == -1 && 1)
    goto L1088;
  x2 = XEXP (x1, 0);
  goto L124;
 L1088:
  x5 = XEXP (x4, 1);
  if (GET_CODE (x5) == CONST_INT && XINT (x5, 0) == -1 && 1)
    goto L1089;
  x2 = XEXP (x1, 0);
  goto L124;
 L1089:
  x4 = XEXP (x3, 1);
  if (x4 == const0_rtx && 1)
    goto L1090;
  x2 = XEXP (x1, 0);
  goto L124;
 L1090:
  x3 = XEXP (x2, 1);
  if (GET_CODE (x3) == LABEL_REF && 1)
    goto L1091;
  x2 = XEXP (x1, 0);
  goto L124;
 L1091:
  x4 = XEXP (x3, 0);
  if (1)
    { recog_operand[1] = x4; goto L1092; }
  x2 = XEXP (x1, 0);
  goto L124;
 L1092:
  x3 = XEXP (x2, 2);
  if (x3 == pc_rtx && 1)
    goto L1093;
  x2 = XEXP (x1, 0);
  goto L124;
 L1093:
  x1 = XVECEXP (x0, 0, 1);
  if (GET_CODE (x1) == SET && 1)
    goto L1094;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 0);
  goto L124;
 L1094:
  x2 = XEXP (x1, 0);
  if (rtx_equal_p (x2, recog_operand[0]) && 1)
    goto L1095;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 0);
  goto L124;
 L1095:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == PLUS && GET_MODE (x2) == SImode && 1)
    goto L1096;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 0);
  goto L124;
 L1096:
  x3 = XEXP (x2, 0);
  if (rtx_equal_p (x3, recog_operand[0]) && 1)
    goto L1097;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 0);
  goto L124;
 L1097:
  x3 = XEXP (x2, 1);
  if (GET_CODE (x3) == CONST_INT && XINT (x3, 0) == -1 && 1)
    return 199;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 0);
  goto L124;
 L444:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == DIV && GET_MODE (x2) == SImode && 1)
    goto L445;
  if (GET_CODE (x2) == UDIV && GET_MODE (x2) == SImode && 1)
    goto L456;
 L125:
  if (general_operand (x2, SImode))
    { recog_operand[1] = x2; goto L126; }
  goto ret0;
 L445:
  x3 = XEXP (x2, 0);
  if (general_operand (x3, SImode))
    { recog_operand[1] = x3; goto L446; }
  goto L125;
 L446:
  x3 = XEXP (x2, 1);
  if (general_operand (x3, SImode))
    { recog_operand[2] = x3; goto L447; }
  goto L125;
 L447:
  x1 = XVECEXP (x0, 0, 1);
  if (GET_CODE (x1) == SET && 1)
    goto L448;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 1);
  goto L125;
 L448:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SImode))
    { recog_operand[3] = x2; goto L449; }
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 1);
  goto L125;
 L449:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == MOD && GET_MODE (x2) == SImode && 1)
    goto L450;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 1);
  goto L125;
 L450:
  x3 = XEXP (x2, 0);
  if (rtx_equal_p (x3, recog_operand[1]) && 1)
    goto L451;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 1);
  goto L125;
 L451:
  x3 = XEXP (x2, 1);
  if (rtx_equal_p (x3, recog_operand[2]) && 1)
    if (TARGET_68020) return 96;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 1);
  goto L125;
 L456:
  x3 = XEXP (x2, 0);
  if (general_operand (x3, SImode))
    { recog_operand[1] = x3; goto L457; }
  goto L125;
 L457:
  x3 = XEXP (x2, 1);
  if (general_operand (x3, SImode))
    { recog_operand[2] = x3; goto L458; }
  goto L125;
 L458:
  x1 = XVECEXP (x0, 0, 1);
  if (GET_CODE (x1) == SET && 1)
    goto L459;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 1);
  goto L125;
 L459:
  x2 = XEXP (x1, 0);
  if (general_operand (x2, SImode))
    { recog_operand[3] = x2; goto L460; }
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 1);
  goto L125;
 L460:
  x2 = XEXP (x1, 1);
  if (GET_CODE (x2) == UMOD && GET_MODE (x2) == SImode && 1)
    goto L461;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 1);
  goto L125;
 L461:
  x3 = XEXP (x2, 0);
  if (rtx_equal_p (x3, recog_operand[1]) && 1)
    goto L462;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 1);
  goto L125;
 L462:
  x3 = XEXP (x2, 1);
  if (rtx_equal_p (x3, recog_operand[2]) && 1)
    if (TARGET_68020) return 97;
  x1 = XVECEXP (x0, 0, 0);
  x2 = XEXP (x1, 1);
  goto L125;
 L126:
  x1 = XVECEXP (x0, 0, 1);
  if (GET_CODE (x1) == SET && 1)
    goto L127;
  goto ret0;
 L127:
  x2 = XEXP (x1, 0);
  if (rtx_equal_p (x2, recog_operand[1]) && 1)
    goto L128;
  goto ret0;
 L128:
  x2 = XEXP (x1, 1);
  if (rtx_equal_p (x2, recog_operand[0]) && 1)
    return 22;
  goto ret0;
 ret0: return -1;
}

int
recog (x0, insn)
     register rtx x0;
     rtx insn;
{
  register rtx x1, x2, x3, x4, x5;
  rtx x6, x7, x8, x9, x10, x11;
  int tem;
 L0:
 switch (GET_CODE (x0))
  {
  case SET:
  if (1)
    goto L7;
  break;
  case PARALLEL:
  if (XVECLEN (x0, 0) == 2 && 1)
    goto L123;
  break;
  case CALL:
  if (1)
    goto L1099;
  break;
  case RETURN:
  if (1)
    return 202;
  break;
  }
  goto ret0;
 L7:
  return recog_6 (x0, insn);
 L123:
  x1 = XVECEXP (x0, 0, 0);
  if (GET_CODE (x1) == SET && 1)
    goto L1049;
  goto ret0;
 L1049:
  return recog_7 (x0, insn);
 L1099:
  x1 = XEXP (x0, 0);
  if (general_operand (x1, QImode))
    { recog_operand[0] = x1; goto L1100; }
  goto ret0;
 L1100:
  x1 = XEXP (x0, 1);
  if (general_operand (x1, SImode))
    { recog_operand[1] = x1; return 200; }
  goto ret0;
 ret0: return -1;
}
