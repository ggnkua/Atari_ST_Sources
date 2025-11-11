/* function declarations */
#include "proto.h"

/* global variables */
extern int        Rows, Columns, Nonnuls, Sum;
extern double     Extrad;
extern double     *Pcol; /* [Rows+1] */
extern nstring    Probname;
extern int        Totnum, Classnr, Linenr;
extern short      Bounds, Ranges, Verbose, Debug, Show_results;
extern unsigned   Cur_eta_size;
extern double     *Eta_value;
extern int        *Eta_rownr;

extern matrec     *Mat;
extern double     *Upbo, *Lowbo;
extern nstring    *Names;
extern int        *Cend;
extern double     *Rh;
extern short      *Relat;

extern short      *Chsign;
extern int        *Endetacol;
extern int        *Rend, *Bas;
extern double     *Rhs; 
extern int        *Colno;
extern short      *Basis, *Lower;

extern double     *Solution, *Best_solution, *Orig_rh, *Orig_upbo, *Orig_lowbo;
extern short      *Must_be_int;
extern matrec     *Orig_mat;
extern int        Level;

extern intrec     *First_int;

   /* external variables for yy_trans and the yacc parser */
extern int        yylineno;
extern int        yyleng;
extern int        Lin_term_count;
extern int        Sign;
extern char       yytext[];

extern hashelem   *Hash_tab[HASH_SIZE];
extern rside      *First_rside;
extern short      Ignore_decl;

extern tmp_store_struct tmp_store;

