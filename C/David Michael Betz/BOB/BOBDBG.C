/* bobdbg.c - debug routines */
/*
	Copyright (c) 1991, by David Michael Betz
	All rights reserved
*/

#include "bob.h"

/* instruction output formats */
#define FMT_NONE	0
#define FMT_BYTE	1
#define FMT_WORD	2
#define FMT_LIT		3

typedef struct { int ot_code; char *ot_name; int ot_fmt; } OTDEF;
OTDEF otab[] = {
{	OP_BRT,		"BRT",		FMT_WORD	},
{	OP_BRF,		"BRF",		FMT_WORD	},
{	OP_BR,		"BR",		FMT_WORD	},
{	OP_LIT,		"LIT",		FMT_LIT		},
{	OP_REF,		"REF",		FMT_LIT		},
{	OP_SET,		"SET",		FMT_LIT		},
{	OP_AREF,	"AREF",		FMT_BYTE	},
{	OP_ASET,	"ASET",		FMT_BYTE	},
{	OP_TREF, 	"TREF",		FMT_BYTE	},
{	OP_TSET,	"TSET",		FMT_BYTE	},
{	OP_MREF,	"MREF",		FMT_BYTE	},
{	OP_MSET,	"MSET",		FMT_BYTE	},
{	OP_VREF,	"VREF",		FMT_NONE	},
{	OP_VSET,	"VSET",		FMT_NONE	},
{	OP_CALL,	"CALL",		FMT_BYTE	},
{	OP_RETURN,	"RETURN",	FMT_NONE	},
{	OP_SEND,	"SEND",		FMT_BYTE	},
{	OP_TSPACE,	"TSPACE",	FMT_BYTE	},
{	OP_NIL,		"NIL",		FMT_NONE	},
{	OP_PUSH,	"PUSH",		FMT_NONE	},
{	OP_NOT,		"NOT",		FMT_NONE	},
{	OP_NEG,		"NEG",		FMT_NONE	},
{	OP_ADD,		"ADD",		FMT_NONE	},
{	OP_SUB,		"SUB",		FMT_NONE	},
{	OP_MUL,		"MUL",		FMT_NONE	},
{	OP_DIV,		"DIV",		FMT_NONE	},
{	OP_REM,		"REM",		FMT_NONE	},
{	OP_SHL,		"SHL",		FMT_NONE	},
{	OP_SHR,		"SHR",		FMT_NONE	},
{	OP_BAND,	"BAND",		FMT_NONE	},
{	OP_BOR,		"BOR",		FMT_NONE	},
{	OP_BNOT,	"BNOT",		FMT_NONE	},
{	OP_LT,		"LT",		FMT_NONE	},
{	OP_LE,		"LE",		FMT_NONE	},
{	OP_EQ,		"EQ",		FMT_NONE	},
{	OP_NE,		"NE",		FMT_NONE	},
{	OP_GE,		"GE",		FMT_NONE	},
{	OP_GT,		"GT",		FMT_NONE	},
{	OP_INC,		"INC",		FMT_NONE	},
{	OP_DEC,		"DEC",		FMT_NONE	},
{	OP_DUP2,	"DUP2",		FMT_NONE	},
{	OP_NEW,		"NEW",		FMT_NONE	},
{0,0,0}
};

/* decode_procedure - decode the instructions in a code object */
decode_procedure(code)
VALUE *code;
{
    int len,lc,n;
    
    len = strgetsize(vecgetelement(code,0));
    for (lc = 0; lc < len; lc += n)
		n = decode_instruction(code,lc);
}

/* decode_instruction - decode a single bytecode instruction */
int decode_instruction(code,lc)
VALUE *code; int lc;
{
    char name[TKNSIZE+1],buf[100];
    unsigned char *cp;
    OTDEF *op;
    int n=1;

    cp = strgetdata(vecgetelement(code,0)) + lc; /* get bytecode pointer for this instruction */

    if (valtype(vecgetelement(code,1)) == DT_CLASS)  /* show the address and opcode */
    {
		getcstring(name,sizeof(name),clgetname(vecgetelement(code,1)));
		sprintf(buf,"%s::",name);
		osputs(buf);
    }
    getcstring(name,sizeof(name),vecgetelement(code,2));
    sprintf(buf,"%s %04x %02x ",name,lc,*cp);
    osputs(buf);

    for (op = otab; op->ot_name; ++op) /* display the operands */
	if (*cp == op->ot_code) 
	{
	    switch (op->ot_fmt) 
	    {
	    case FMT_NONE:
			sprintf(buf,"      %s\n",op->ot_name);
			osputs(buf);
			break;
	    case FMT_BYTE:
			sprintf(buf,"%02x    %s %02x\n",cp[1],op->ot_name,cp[1]);
			osputs(buf);
			n += 1;
			break;
	    case FMT_WORD:
			sprintf(buf,"%02x %02x %s %02x%02x\n",cp[1],cp[2],
			op->ot_name,cp[2],cp[1]);
			osputs(buf);
			n += 2;
			break;
	    case FMT_LIT:
			sprintf(buf,"%02x    %s %02x ; ",cp[1],op->ot_name,cp[1]);
			osputs(buf);
			print1(stderr,TRUE,vecgetelement(code,cp[1]));
			osputs("\n");
			n += 1;
			break;
	    }
	    return (n);
	}
    
    sprintf(buf,"      <UNKNOWN>\n"); /* unknown opcode */
    osputs(buf);
    return (1);
}
