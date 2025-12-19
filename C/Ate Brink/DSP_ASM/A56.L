%{
/*
 * Copyright (C) 1990-1992 Quinn C. Jensen
 *
 * Permission to use, copy, modify, distribute, and sell this software
 * and its documentation for any purpose is hereby granted without fee,
 * provided that the above copyright notice appear in all copies and
 * that both that copyright notice and this permission notice appear
 * in supporting documentation.  The author makes no representations
 * about the suitability of this software for any purpose.  It is
 * provided "as is" without express or implied warranty.
 *
 */
%}
%a	10000
%o	10000
%e	2000
%k	2000
%p	3000
A	[Aa]
B	[Bb]
C	[Cc]
D	[Dd]
E	[Ee]
F	[Ff]
G	[Gg]
H	[Hh]
I	[Ii]
J	[Jj]
K	[Kk]
L	[Ll]
M	[Mm]
N	[Nn]
O	[Oo]
P	[Pp]
Q	[Qq]
R	[Rr]
S	[Ss]
T	[Tt]
U	[Uu]
V	[Vv]
W	[Ww]
X	[Xx]
Y	[Yy]
Z	[Zz]
WHITE	[ \t]+
ALCHR	[_A-Za-z]
ALPHA	{ALCHR}+
NUM	[0-9]+
FRAC	("-"|"")({NUM}"."{NUM})|("."{NUM})
ALNUM	{ALCHR}[0-9A-Za-z_]*
HEXNUM	[0-9A-Fa-f]+
BW	(^|{WHITE})
%%
{WHITE}			;
\n			{curline++; RET(EOL);}
@			{RET(EOS);}
;.*$			{RET(COMMENT);}
{X}:			{RET(XMEM);}
{Y}:			{RET(YMEM);}
{L}:			{RET(LMEM);}
{P}:			{RET(PMEM);}
{A}10			{RET(A10);}
{A}			{RET(AAAA);}
{B}10			{RET(B10);}
{B}			{RET(BBBB);}
{A}{B}			{RET(AABB);}
{B}{A}			{RET(BBAA);}
{X}			{RET(XXXX);}
{Y}			{RET(YYYY);}
{S}{R}			{RET(SR);}
{M}{R}			{RET(MR);}
{C}{C}{R}		{RET(CCR);}
{O}{M}{R}		{RET(OMR);}
{S}{P}			{RET(SP);}
{S}{S}{H}		{RET(SSH);}
{S}{S}{L}		{RET(SSL);}
{L}{A}			{RET(LA);}
{L}{C}			{RET(LC);}
{A}[0-2]		{yylval.ival = atoi(&yytext[1]); RET(AREG);}
{B}[0-2]		{yylval.ival = atoi(&yytext[1]); RET(BREG);}
{M}[0-7]		{yylval.ival = atoi(&yytext[1]); RET(MREG);}
{N}[0-7]		{yylval.ival = atoi(&yytext[1]); RET(NREG);}
{R}[0-7]		{yylval.ival = atoi(&yytext[1]); RET(RREG);}
{X}[01]			{yylval.ival = atoi(&yytext[1]); RET(XREG);}
{Y}[01]			{yylval.ival = atoi(&yytext[1]); RET(YREG);}
"$"{HEXNUM}		{yylval.n.type = INT; yylval.n.val.i = strtol(&yytext[1], 0, 16); RET(CHEX);}
{FRAC}			{yylval.n.type = FLT; yylval.n.val.f = atof(yytext); RET(FRAC);}
{NUM}			{yylval.n.type = INT; yylval.n.val.i = atoi(yytext); RET(CDEC);}
{A}{B}{S}               {RET(OP_ABS);}
{A}{D}{C}               {RET(OP_ADC);}
{A}{D}{D}               {RET(OP_ADD);}
{A}{D}{D}{L}            {RET(OP_ADDL);}
{A}{D}{D}{R}            {RET(OP_ADDR);}
{A}{S}{L}               {RET(OP_ASL);}
{A}{S}{R}               {RET(OP_ASR);}
{C}{L}{R}               {RET(OP_CLR);}
{C}{M}{P}               {RET(OP_CMP);}
{C}{M}{P}{M}            {RET(OP_CMPM);}
{D}{I}{V}               {RET(OP_DIV);}
{M}{A}{C}               {RET(OP_MAC);}
{M}{A}{C}{R}            {RET(OP_MACR);}
{M}{P}{Y}               {RET(OP_MPY);}
{M}{P}{Y}{R}            {RET(OP_MPYR);}
{N}{E}{G}               {RET(OP_NEG);}
{N}{O}{R}{M}            {RET(OP_NORM);}
{R}{N}{D}               {RET(OP_RND);}
{S}{B}{C}               {RET(OP_SBC);}
{S}{U}{B}               {RET(OP_SUB);}
{S}{U}{B}{L}            {RET(OP_SUBL);}
{S}{U}{B}{R}            {RET(OP_SUBR);}
{T}{C}{C}               {yylval.cond = 0x0; RET(OP_TCC);}
{T}{H}{S}               {yylval.cond = 0x0; RET(OP_TCC);}
{T}{G}{E}               {yylval.cond = 0x1; RET(OP_TCC);}
{T}{N}{E}               {yylval.cond = 0x2; RET(OP_TCC);}
{T}{P}{L}               {yylval.cond = 0x3; RET(OP_TCC);}
{T}{N}{N}               {yylval.cond = 0x4; RET(OP_TCC);}
{T}{E}{C}               {yylval.cond = 0x5; RET(OP_TCC);}
{T}{L}{C}               {yylval.cond = 0x6; RET(OP_TCC);}
{T}{G}{T}               {yylval.cond = 0x7; RET(OP_TCC);}
{T}{C}{S}               {yylval.cond = 0x8; RET(OP_TCC);}
{T}{L}{O}               {yylval.cond = 0x8; RET(OP_TCC);}
{T}{L}{T}               {yylval.cond = 0x9; RET(OP_TCC);}
{T}{E}{Q}               {yylval.cond = 0xA; RET(OP_TCC);}
{T}{M}{I}               {yylval.cond = 0xB; RET(OP_TCC);}
{T}{N}{R}               {yylval.cond = 0xC; RET(OP_TCC);}
{T}{E}{S}               {yylval.cond = 0xD; RET(OP_TCC);}
{T}{L}{S}               {yylval.cond = 0xE; RET(OP_TCC);}
{T}{L}{E}               {yylval.cond = 0xF; RET(OP_TCC);}
{T}{F}{R}               {RET(OP_TFR);}
{T}{S}{T}               {RET(OP_TST);}
{A}{N}{D}               {RET(OP_AND);}
{A}{N}{D}{I}            {RET(OP_ANDI);}
{E}{O}{R}               {RET(OP_EOR);}
{L}{S}{L}               {RET(OP_LSL);}
{L}{S}{R}               {RET(OP_LSR);}
{N}{O}{T}               {RET(OP_NOT);}
{O}{R}                  {RET(OP_OR);}
{O}{R}{I}               {RET(OP_ORI);}
{R}{O}{L}               {RET(OP_ROL);}
{R}{O}{R}               {RET(OP_ROR);}
{B}{C}{L}{R}            {RET(OP_BCLR);}
{B}{S}{E}{T}            {RET(OP_BSET);}
{B}{C}{H}{G}            {RET(OP_BCHG);}
{B}{T}{S}{T}            {RET(OP_BTST);}
{D}{O}                  {RET(OP_DO);}
{E}{N}{D}{D}{O}         {RET(OP_ENDDO);}
{L}{U}{A}               {RET(OP_LUA);}
{M}{O}{V}{E}            {RET(OP_MOVE);}
{M}{O}{V}{E}{C}         {RET(OP_MOVEC);}
{M}{O}{V}{E}{M}         {RET(OP_MOVEM);}
{M}{O}{V}{E}{P}         {RET(OP_MOVEP);}
{I}{N}{C}{L}{U}{D}{E}   {RET(OP_INCLUDE);}
{I}{L}{L}{E}{G}{A}{L}   {RET(OP_ILLEGAL);}
{J}{C}{C}               {yylval.cond = 0x0; RET(OP_JCC);}
{J}{H}{S}               {yylval.cond = 0x0; RET(OP_JCC);}
{J}{G}{E}               {yylval.cond = 0x1; RET(OP_JCC);}
{J}{N}{E}               {yylval.cond = 0x2; RET(OP_JCC);}
{J}{P}{L}               {yylval.cond = 0x3; RET(OP_JCC);}
{J}{N}{N}               {yylval.cond = 0x4; RET(OP_JCC);}
{J}{E}{C}               {yylval.cond = 0x5; RET(OP_JCC);}
{J}{L}{C}               {yylval.cond = 0x6; RET(OP_JCC);}
{J}{G}{T}               {yylval.cond = 0x7; RET(OP_JCC);}
{J}{C}{S}               {yylval.cond = 0x8; RET(OP_JCC);}
{J}{L}{O}               {yylval.cond = 0x8; RET(OP_JCC);}
{J}{L}{T}               {yylval.cond = 0x9; RET(OP_JCC);}
{J}{E}{Q}               {yylval.cond = 0xA; RET(OP_JCC);}
{J}{M}{I}               {yylval.cond = 0xB; RET(OP_JCC);}
{J}{N}{R}               {yylval.cond = 0xC; RET(OP_JCC);}
{J}{E}{S}               {yylval.cond = 0xD; RET(OP_JCC);}
{J}{L}{S}               {yylval.cond = 0xE; RET(OP_JCC);}
{J}{L}{E}               {yylval.cond = 0xF; RET(OP_JCC);}
{J}{M}{P}               {RET(OP_JMP);}
{J}{C}{L}{R}            {RET(OP_JCLR);}
{J}{S}{E}{T}            {RET(OP_JSET);}
{J}{S}{C}{C}            {yylval.cond = 0x0; RET(OP_JSCC);}
{J}{S}{H}{S}            {yylval.cond = 0x0; RET(OP_JSCC);}
{J}{S}{G}{E}            {yylval.cond = 0x1; RET(OP_JSCC);}
{J}{S}{N}{E}            {yylval.cond = 0x2; RET(OP_JSCC);}
{J}{S}{P}{L}            {yylval.cond = 0x3; RET(OP_JSCC);}
{J}{S}{N}{N}            {yylval.cond = 0x4; RET(OP_JSCC);}
{J}{S}{E}{C}            {yylval.cond = 0x5; RET(OP_JSCC);}
{J}{S}{L}{C}            {yylval.cond = 0x6; RET(OP_JSCC);}
{J}{S}{G}{T}            {yylval.cond = 0x7; RET(OP_JSCC);}
{J}{S}{C}{S}            {yylval.cond = 0x8; RET(OP_JSCC);}
{J}{S}{L}{O}            {yylval.cond = 0x8; RET(OP_JSCC);}
{J}{S}{L}{T}            {yylval.cond = 0x9; RET(OP_JSCC);}
{J}{S}{E}{Q}            {yylval.cond = 0xA; RET(OP_JSCC);}
{J}{S}{M}{I}            {yylval.cond = 0xB; RET(OP_JSCC);}
{J}{S}{N}{R}            {yylval.cond = 0xC; RET(OP_JSCC);}
{J}{S}{E}{S}            {yylval.cond = 0xD; RET(OP_JSCC);}
{J}{S}{L}{S}            {yylval.cond = 0xE; RET(OP_JSCC);}
{J}{S}{L}{E}            {yylval.cond = 0xF; RET(OP_JSCC);}
{J}{S}{R}               {RET(OP_JSR);}
{J}{S}{C}{L}{R}         {RET(OP_JSCLR);}
{J}{S}{S}{E}{T}         {RET(OP_JSSET);}
{N}{O}{P}               {RET(OP_NOP);}
{R}{E}{P}               {RET(OP_REP);}
{R}{E}{S}{E}{T}         {RET(OP_RESET);}
{R}{T}{I}               {RET(OP_RTI);}
{R}{T}{S}               {RET(OP_RTS);}
{S}{T}{O}{P}            {RET(OP_STOP);}
{S}{W}{I}               {RET(OP_SWI);}
{W}{A}{I}{T}            {RET(OP_WAIT);}
{E}{Q}{U}               {RET(OP_EQU);}
{O}{R}{G}               {RET(OP_ORG);}
{D}{C}                  {RET(OP_DC);}
{E}{N}{D}               {RET(OP_END);}
{P}{A}{G}{E}            {RET(OP_PAGE);}
{P}{S}{E}{C}{T}         {RET(OP_PSECT);}
{A}{L}{I}{G}{N}         {RET(OP_ALIGN);}
{ALNUM}			{yylval.sval = strsave(yytext); RET(SYM);};
'\\b'			{yylval.cval = '\b'; RET(CHAR);};
'\\f'			{yylval.cval = '\f'; RET(CHAR);};
'\\n'			{yylval.cval = '\n'; RET(CHAR);};
'\\r'			{yylval.cval = '\r'; RET(CHAR);};
'\\t'			{yylval.cval = '\t'; RET(CHAR);};
'\\\\'			{yylval.cval = '\\'; RET(CHAR);};
'.'			{yylval.cval = yytext[1]; RET(CHAR);};
\".*\"			|
'..+'			{yylval.sval = (char *)fixstring(yytext);
				yylval.sval = strsave(yylval.sval);
				RET(STRING);};
"<<"			{RET(SHL);};
">>"    		{RET(SHR);};
.			{RET(yytext[0]);}
%%

#undef input
#define input() (((yytchar=yysptr>yysbuf?U(*--yysptr):lgetc(yyin))==10?(yylineno++,yytchar):yytchar)==EOF?0:yytchar)

#define INLINE 1024

char inline[INLINE], *ip = NULL;

lgetc(fp)
FILE *fp;
{
    int c;

    if(NOT ip) {
	if(NOT fgets(inline, INLINE, fp))
	    return(EOF);
	rmcr(inline);
	ip = inline;
    }
    c = *ip;

    if(ldebug) {
	printf("i='%c'(%x)", c, c);
	fflush(stdout);
    }

    switch(c) {
	case '\0':
	    c = '\n';
	    ip = NULL;
	    break;
	default:
	    ip++;
	    break;
    }
    return(c);
}
