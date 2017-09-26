/*
        Copyright 1981
        Alcyon Corporation
        8474 Commerce Av.
        San Diego, Ca.  92121
*/
#define NUMSS 1 /*number of special symbols*/
#define SSRG    0       /*max symbol offset to display symbolically*/
 
#define LSTENT 12
struct symtab {
        char syname[8];
        char *syval;
};
 
 
struct {
        int hiword;
        int loword;
};
 
char *symbuf;   /*start of symbol table*/
char *esymbuf;  /*end of symbol table*/
int *symptr;
int     errflg;
/*  the following definitions must not be changed -- esp. the order */
int     symlen;
int     symct;
char    ssymbol[8];
int     ssymflg;
char *ssymval;
/* end of order dependant declarations */
char *dot;
char *tdot;
int     dotinc;
char    *sdot;          /* symbolic operand temporary dot */
int textsym;
 
 
#define TEXTS 01000
#define DATAS 02000
#define BSSS  0400
#define ABSS  03400
 
char tsym[10];
char fsymbol[10];
int seffadr, sefaflg;   /* effective address search variables */
 
 
int ssval[NUMSS];               /* special symbol values */
int instr;              /* holds instruction first word */
 
#define BYTESZ 0
#define WORDSZ 1
#define LONGSZ 2
 
/* flags for symbols */
# define SYDF   0100000         /* defined */
# define SYEQ   0040000         /* equated */
# define SYGL   0020000         /* global - entry or external */
# define SYER   0010000         /* equated register */
# define SYXR   0004000         /* external reference */
# define SYDA   0002000         /* DATA based relocatable */
# define SYTX   0001000         /* TEXT based relocatable */
# define SYBS   0000400         /* BSS based relocatable */
 
struct {                /* NOT PORTABLE !!!!!! */
        char hibyte;
        char lobyte;
};
 
#define AREG0   8
#define PC              16
 
char lbuf[40];
