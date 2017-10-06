
typedef union  {
    int ival;
    double fval;
    struct ent *ent;
    struct enode *enode;
    char *sval;
} YYSTYPE;
extern YYSTYPE yylval;
# define STRING 257
# define NUMBER 258
# define FNUMBER 259
# define WORD 260
# define COL 261
# define S_FORMAT 262
# define S_LABEL 263
# define S_LEFTSTRING 264
# define S_RIGHTSTRING 265
# define S_GET 266
# define S_PUT 267
# define S_MERGE 268
# define S_LET 269
# define S_WRITE 270
# define S_TBL 271
# define S_PROGLET 272
# define S_COPY 273
# define S_SHOW 274
# define K_FIXED 275
# define K_SUM 276
# define K_PROD 277
# define K_AVE 278
