/*
HEADER: 	;
TITLE: 		Frankenstein Cross Assemblers;
VERSION: 	2.0;
DESCRIPTION: "	Reconfigurable Cross-assembler producing Intel (TM)
		Hex format object records.  ";
FILENAME: 	fraeuni.h;
SEE-ALSO: 	frapsub.c, fraosub.c;
AUTHORS: 	Mark Zenier;
*/
/*
	description	switch case actions for unary operators for
			both the parse and output phase expression
			evaluators
*/

		case IFC_NEG:
			etop = -etop;
			break;

		case IFC_NOT:
			etop = ~ etop;
			break;

		case IFC_HIGH:
			etop = (etop >> 8) & 0xff;
			break;

		case IFC_LOW:
			etop = etop & 0xff;
			break;

