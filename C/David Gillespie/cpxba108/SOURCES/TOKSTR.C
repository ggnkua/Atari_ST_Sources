#define TOK_STR
#include "tokstr.h"

#ifndef NUM_EL
#define NUM_EL(a) (sizeof(a)/sizeof(*a))
#endif

char *tok_strings[]=
{
    "(",")","[","]"
    ,"=","<",">","<=",">=","<>"
    ,",",";",":"
    ,"?","#"

/* Schl《selworte mit Realzahlen als Argument */
    ,"+","-","*","/","^"
/* alphanumerische Funktionen */
    ,"SQU","SQR","SQRT"
    ,"SIN","COS","TAN","ASIN","ACOS","ATAN","ARCTAN"
    ,"SINH","COSH","TANH","ASINH","ACOSH","ATANH"
    ,"LOG","LN","LD","LG"
    ,"EXP","TEN","TWO"
    ,"ABS","SGN","STR$","RCP","INT"
    ,"DMS$"
    ,"FAHRENHEIT","CELSIUS", "CEIL", "FLOOR"

/* Schl《selworte mit Intzahlen als Argument */
    ,"LABEL","NOT","FACT"
    ,"HEX$","OCT$","BIN$","CHR$"
    ,"PEEKL","PEEKW","PEEK","POKEL","POKEW","POKE"
	,"PLOT","LINE","CIRCLE","ELLIPSE"

/* Schl《selworte mit String als Argument */
    ,"VAL","ASC","LEN"
    ,"DEG","FSEL$"
	,"INBYTE","OUTBYTE"
	
/* Schl《selworte mit irgendeinem  oder ohne Argument */
    ,"REM","LET","PRINT","INPUT"
    ,"IF","END","STOP","CONTINUE","FOR","NEXT","WHILE","WEND"
    ,"GOSUB","RETURN","READ","DATA","RESTORE"
    ,"GOTOXY","ON","DIM"
    ,"LIST","RUN","NEW","LOAD","MERGE"
    ,"SAVE","BYE","DEL","RENUM"
    ,"FOPEN","FCLOSE","FINPUT","FPRINT","ERRNO"
    ,"DEGREE","GRAD","RAD","CLS","CLEAR","USING$","USING"
    ,"RAND","PI","INKEY$","MID$"
    ,"AND","OR","XOR","MOD","THEN","ELSE","TO","STEP","GOTO"
	,"TRON","TROFF"
};

#if (NUM_EL(tok_strings)<NUM_TOKS)
#line 8
#error "not enough initializers in array 'tok_strings'"
#endif

#if (NUM_EL(tok_strings)>NUM_TOKS)
#line 8
#error "too many initializers in array 'tok_strings'"
#endif

