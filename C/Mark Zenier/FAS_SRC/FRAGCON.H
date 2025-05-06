/*
HEADER: 	;
TITLE: 		Frankenstein Cross Assemblers;
VERSION: 	2.0;
DESCRIPTION: "	Reconfigurable Cross-assembler producing Intel (TM)
		Hex format object records.

		constants used in intermediate file code generation
		as the expression node operation value and the polish
		expression operation  ";
FILENAME: 	fragcon.h;
SEE-ALSO: 	frapsub.c, fraosub.c, as*.y;
AUTHORS: 	Mark Zenier;
*/

#define IG_START	'['
#define IG_END		']'
#define IG_CPCON	'#'
#define IG_CPEXPR	'='
#define IG_ERROR	'X'

#define IGP_DEFINED	'U'
#define IGP_CONSTANT	'V'

#define IFC_NEG		'_'
#define IFC_NOT		'N'
#define IFC_HIGH	'H'
#define IFC_LOW		'Z'
#define IFC_MUL		'*'
#define IFC_DIV		'/'
#define IFC_ADD		'+'
#define IFC_SUB		'-'
#define IFC_MOD		'%'
#define IFC_SHL		'{'
#define IFC_SHR		'}'
#define IFC_AND		'&'
#define IFC_OR		'|'
#define IFC_XOR		'^'
#define IFC_GT		'>'
#define IFC_GE		'G'
#define IFC_LT		'<'
#define IFC_LE		'L'
#define IFC_NE		'?'
#define IFC_EQ		'='
#define IFC_SYMB	'S'
#define IFC_PROGCTR	'P'
#define IFC_CURRLOC	'Q'
#define IFC_LOAD	'.'
#define IFC_CLR		'$'
#define IFC_CLRALL	'X'
#define IFC_POP		'!'
#define IFC_DUP		'~'
#define IFC_EMU8	';'
#define IFC_EMS7	'r'
#define IFC_EM16	'x'
#define IFC_EMBR16	'y'
#define IFC_WIDTH	'W'
#define IFC_SWIDTH	'R'
#define IFC_IWIDTH	'I'
#define IFC_TESTERR	'T'

#define PCCASE_BIN	1
#define PCCASE_UN	2
#define PCCASE_DEF	3
#define PCCASE_SYMB	4
#define PCCASE_CONS	5
#define PCCASE_PROGC	6

