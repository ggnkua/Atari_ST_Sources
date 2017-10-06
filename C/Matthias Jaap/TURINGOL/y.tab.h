#define TAI 257
#define IF 258
#define THEN 259
#define GOTO 260
#define MOVE 261
#define PRINT 262
#define DIR 263
#define ONESQUARE 264
#define IDENT 265
#define COLON 266
#define COMMA 267
#define DQUOTE 268
#define LBRACE 269
#define PERIOD 270
#define RBRACE 271
#define SEMICOLON 272
typedef union {
	STNode *st;
	SymNode *sym;
	char *id;
	int dir;
} YYSTYPE;
extern YYSTYPE yylval;
