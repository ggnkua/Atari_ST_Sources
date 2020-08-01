/************************************************************************
*									*
* The SB-Prolog System							*
* Copyright SUNY at Stony Brook, 1986; University of Arizona, 1987	*
*									*
************************************************************************/

/*-----------------------------------------------------------------
SB-Prolog is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY.  No author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.  Refer to the SB-Prolog General Public
License for full details.

Everyone is granted permission to copy, modify and redistribute
SB-Prolog, but only under the conditions described in the
SB-Prolog General Public License.   A copy of this license is
supposed to have been given to you along with SB-Prolog so you
can know your rights and responsibilities.  It should be in a
file named COPYING.  Among other things, the copyright notice
and this notice must be preserved on all copies. 
------------------------------------------------------------------ */
/* file.c */

#include  "builtin.h"
#include  <stdio.h>
#include  <sys/file.h>

#define  PMODE  0644

extern double floatval();

static int         n, a;
static WORD        fileerrors = 0;   /* abort, or not on file errors */
static PSC_REC_PTR user_psc_ptr, stderr_psc_ptr, psc_ptr;
static FILE        *tempfile;
static CHAR        s[256];

static LONG        user_word, con_word, stderr_word;

struct ftab_ent
{
   int   inout;      /* 1 if input, 0 if output */
   LONG  p_ptr;      /* tagged ptr to psc_ptr of constant */
   FILE *fdes;       /* file descriptor for this constant */
};

/* table of open files; 0 is always stdin, 1 is always stdout, 
   2 is always stderr */
static struct ftab_ent file_table[20];
static int file_tab_end = 0; /* last used entry in file_table */

/* index of current input (output) stream in file_table */
static int in_file_i, out_file_i;
extern FILE *curr_in, *curr_out;

static struct hostent *hp;


get_file_index(cword, io)
LONG cword;
int  io;
{
   int i;

   for (i = 0; i <= file_tab_end; i++) {
      if (file_table[i].p_ptr == cword)
         if (io == file_table[i].inout || io > 1)
            return i;
   }
   return -1;
}


b_FILEERRORS()
{
   fileerrors = 1;
}


b_NOFILEERRORS()
{
   fileerrors = 0;
}


b_PUT()  /* (N) */
{
   register LONG     op;
   register LONG_PTR top;

   op = reg[1];  DEREF(op);
   if (!ISINTEGER(op))
      {FAIL0;}
   else putc(INTVAL(op), curr_out);
}


b_GET0()  /* (N) */
{
   register LONG     op;
   register LONG_PTR top;

   n = getc(curr_in);

   if (n == EOF)
      clearerr(curr_in);

   op = reg[1];  DEREF(op);
   if (ISNONVAR(op)) {
      if (!unify(op, MAKEINT(n)))
         {FAIL0;}
   } else {
      FOLLOW(op) = MAKEINT(n);
      PUSHTRAIL(op);
   }
}


b_GET()  /* (N) */
{
   register LONG     op;
   register LONG_PTR top;

   do {
     n = getc(curr_in);
   } while (n != EOF && n < 16 && n >= 112);
   if (n == EOF) {
      clearerr(curr_in);
      FAIL0;
      return;
   }
   op = reg[1];  DEREF(op);
   if (ISNONVAR(op)) {
      if (!unify(op, MAKEINT(n)))
         {FAIL0;}
   } else {
      FOLLOW(op) = MAKEINT(n);
      PUSHTRAIL(op);
   }
}


b_SKIP()  /* (N) */
{
   register LONG     op;
   register LONG_PTR top;

   op = reg[1];  DEREF(op);
   if (!ISINTEGER(op)) {
      FAIL0;
      return;
   }
   a = INTVAL(op);
   if (a < 16 || a >= 112)
      {FAIL0;}
   else {
      do {
         n = getc(curr_in);
      } while (n != EOF && n != a);
      if (n = EOF) {
         if (fileerrors)
            quit("end of file encountered.\n");
         else
            {FAIL0;}
      }
   }
}


b_TAB()  /* (N) */
{
   register LONG     op;
   register LONG_PTR top;

   op = reg[1];  DEREF(op);
   if (!ISINTEGER(op)) {
      FAIL0;
      return;
   }
   a = INTVAL(op);
   if (a < 0) {
      FAIL0;
      return;
   }
   for ( ; a > 0; a--)
      putc(' ', curr_out);
}


b_NL()  /* () */
{
   putc('\n', curr_out);
   fflush(curr_out);
}


b_WRITENAME()  /* (X) */
{
   register LONG     op;
   register LONG_PTR top;

   op = reg[1];
wnd:
   switch (TAG(op)) {
     case FREE: NDEREF(op, wnd);
                fprintf(curr_out, "_%d", UNTAGGED(op));
                break;
     case LIST: fprintf(curr_out, ".");
                break;
     case CS  : psc_ptr = GET_STR_PSC(op);
                if (IS_BUFF(psc_ptr)) 
	           printf("Buffer_%x", GET_NAME(psc_ptr));
                else
                   writepname(curr_out, GET_NAME(psc_ptr), GET_LENGTH(psc_ptr));
                break;
     case NUM : write_tnum(op, curr_out); 
                break;
   }
}


b_WRITEQNAME()  /* (X) */
{
   register LONG     op;
   register LONG_PTR top;

   op = reg[1];
wnd:
   switch (TAG(op)) {
     case FREE: NDEREF(op, wnd);
                fprintf(curr_out, "_%d", UNTAGGED(op));
                break;
     case LIST: fprintf(curr_out, ".");
                break;
     case CS  : psc_ptr = GET_STR_PSC(op);
                if (IS_BUFF(psc_ptr))
	           printf("Buffer_%x", GET_NAME(psc_ptr));
                else
                   writeqname(curr_out, GET_NAME(psc_ptr), GET_LENGTH(psc_ptr));
                break;
     case NUM : write_tnum(op, curr_out);
                break;
   }
}


b_RESET()  /* () */
{
   quit("RESET not implemented\n");

/*
   fop = reg[1];
   get_file_psc();
   if (p == user_psc_ptr)
      set_file_ptr(p, stdin);
   else {
       namestring(p, s);
       set_file_ptr(p, fopen(s, "r"));
       if (get_file_ptr(p) == 0)
          {FAIL0;}
   }
*/
}


b_REWRITE()
{
   quit("REWRITE not implemented\n");
/*
   fop = reg[1];
   get_file_psc();
   if (p == user_psc_ptr)
      set_file_ptr(p, stdout);
   else {
      namestring(p, s);
      set_file_ptr(p, fopen(s, "w"));
      if (get_file_ptr(p) == 0)
         {FAIL0;}
   }
*/
}


b_CLOSE()
{
   register LONG     fop;
   register LONG_PTR top;
   int     i;

   fop = reg[1];  DEREF(fop);
   i = get_file_index(fop, 2);
   if (i > 2) {    /* not user, stderr */
      fclose(file_table[i].fdes);
      for ( ; i < file_tab_end; i++)
         file_table[i] = file_table[i+1];
      file_tab_end--;
   }
}


b_SEE()  /* reg1: file name */
{
   register LONG     fop;
   register LONG_PTR top;
   int      temp_in_file_i;

   fop = reg[1];  DEREF(fop);
   temp_in_file_i = get_file_index(fop, 1);
   if (temp_in_file_i < 0) {    /* not in table */
       namestring(GET_STR_PSC(fop), s);
       tempfile = fopen(s, "r");
       if (!tempfile) {
          FAIL0;          /* leaving in_file_i unchanged */
          return;
       }
       in_file_i = ++file_tab_end;
       file_table[in_file_i].inout = 1;
       file_table[in_file_i].p_ptr = fop;
       file_table[in_file_i].fdes  = tempfile;
   }
   else in_file_i = temp_in_file_i;    /* take it from table */
   curr_in = file_table[in_file_i].fdes;
}


b_TELL()  /* reg1: file name */
{         /* reg2: 0 -> open `w'-write; 1 -> open `a'-append */

   register LONG     sop, fop;
   register LONG_PTR top;

   fop = reg[1];  DEREF(fop);
   sop = reg[2];  DEREF(sop);
   out_file_i = get_file_index(fop, 0);
   if (out_file_i < 0) {                 /* not in table */
       namestring(GET_STR_PSC(fop), s);
       if(INTVAL(sop))
          tempfile = fopen(s, "a");
       else
          tempfile = fopen(s, "w");
       if (!tempfile) {
          FAIL0;
          return;
       }
       out_file_i = ++file_tab_end;
       file_table[out_file_i].inout = 0;
       file_table[out_file_i].p_ptr = fop;
       file_table[out_file_i].fdes  = tempfile;
   }
   curr_out = file_table[out_file_i].fdes;
}


b_SEEING()  /* reg1: unified with the current input file name */
{
   if (!unify(reg[1], file_table[in_file_i].p_ptr))
      {FAIL0;}
}


b_TELLING()  /* reg1: unified with the current out put file name */
{
   if (!unify(reg[1], file_table[out_file_i].p_ptr))
      {FAIL0;}
}


b_SEEN()
{
   if (in_file_i > 2) {
      fclose(curr_in);
      for ( ; in_file_i < file_tab_end; in_file_i++)
          file_table[in_file_i] = file_table[in_file_i+1];
      file_tab_end--;
   }
   in_file_i = 0;    /* reset to user */
   curr_in = file_table[in_file_i].fdes;
}


b_TOLD()
{
   if (out_file_i > 2) {
      fclose(file_table[out_file_i].fdes);
      for ( ; out_file_i < file_tab_end; out_file_i++)
         file_table[out_file_i] = file_table[out_file_i+1];
      file_tab_end--;
   }
   out_file_i = 1;       /* reset to user */
   curr_out = file_table[out_file_i].fdes;
}

static BYTE perm = PERM;

file_init()
{
    LONG temp;
    CHAR arity = 0;

    temp = insert("user", 4, arity, &perm);
    user_psc_ptr = (PSC_REC_PTR)FOLLOW(temp);
    user_word = temp | CS_TAG;

    temp = insert("stderr", 6, arity, &perm);
    stderr_psc_ptr = (PSC_REC_PTR)(FOLLOW(temp));
    stderr_word = temp | CS_TAG;

    file_table[0].inout = 1;
    file_table[0].p_ptr = user_word;
    file_table[0].fdes  = stdin;
    in_file_i = 0;
    curr_in   = stdin;

    file_table[1].inout = 0;
    file_table[1].p_ptr = user_word;
    file_table[1].fdes  = stdout;
    out_file_i = 1;
    curr_out   = stdout;

    file_table[2].inout = 0;
    file_table[2].p_ptr = stderr_word;
    file_table[2].fdes = stderr;

    file_tab_end = 2;
}


b_ACCESS()
{
    register LONG     op1, op2;
    int mode, r;
    char name[256], *s;
    register LONG_PTR top;
    PSC_REC_PTR psc_ptr;

    op1 = reg[1]; DEREF(op1);
    op2 = reg[2]; DEREF(op2);

    if (ISATOM(op1)) {
      psc_ptr = GET_STR_PSC(op1);
      if (IS_ORDI(psc_ptr)) {
	namestring(psc_ptr, name);
	s = name;
      }
      else if (IS_BUFF(psc_ptr)) s = GET_NAME(psc_ptr);
      else {
	printf("access: illegal first argument\n");
	FAIL0;
      }
    };
    if (ISINTEGER(op2)) mode = INTVAL(op2);
    else {
      fprintf(stderr, "access: second argument must be an integer\n");
      FAIL0;
    };
    r = access(s, mode);
    if (!unify(reg[3], MAKEINT(r))) {FAIL0;}
}


b_WRITE4() 
{   /* reg1 contains a bit string that is written out in 4 bytes */

    register LONG     op, wbyte;
    register LONG_PTR top;
    WORD     i;

    op = reg[1];  DEREF(op);
    for (i = 1; i <= 4; i++) {
       wbyte = ((op & 0xff000000) >> 24);
       op = op << 8;
       putc(wbyte, curr_out);
    }
}


b_WRITEPTR()
{
    register LONG     op;  
    register LONG_PTR top;

    op = reg[1];  DEREF(op);

    printf("%08x", op & ~ CS_TAG);
}

