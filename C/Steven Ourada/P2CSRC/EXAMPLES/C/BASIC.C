/* Output from p2c, the Pascal-to-C translator */
/* From input file "dist/examples/basic.p" */


/*$ debug$*/



#include <p2c/p2c.h>



#define checking        true

#define varnamelen      20
#define maxdims         4




typedef Char varnamestring[varnamelen + 1];


typedef Char string255[256];

#define tokvar          0
#define toknum          1
#define tokstr          2
#define toksnerr        3
#define tokplus         4
#define tokminus        5
#define toktimes        6
#define tokdiv          7
#define tokup           8
#define toklp           9
#define tokrp           10
#define tokcomma        11
#define toksemi         12
#define tokcolon        13
#define tokeq           14
#define toklt           15
#define tokgt           16
#define tokle           17
#define tokge           18
#define tokne           19
#define tokand          20
#define tokor           21
#define tokxor          22
#define tokmod          23
#define toknot          24
#define toksqr          25
#define toksqrt         26
#define toksin          27
#define tokcos          28
#define toktan          29
#define tokarctan       30
#define toklog          31
#define tokexp          32
#define tokabs          33
#define toksgn          34
#define tokstr_         35
#define tokval          36
#define tokchr_         37
#define tokasc          38
#define toklen          39
#define tokmid_         40
#define tokpeek         41
#define tokrem          42
#define toklet          43
#define tokprint        44
#define tokinput        45
#define tokgoto         46
#define tokif           47
#define tokend          48
#define tokstop         49
#define tokfor          50
#define toknext         51
#define tokwhile        52
#define tokwend         53
#define tokgosub        54
#define tokreturn       55
#define tokread         56
#define tokdata         57
#define tokrestore      58
#define tokgotoxy       59
#define tokon           60
#define tokdim          61
#define tokpoke         62
#define toklist         63
#define tokrun          64
#define toknew          65
#define tokload         66
#define tokmerge        67
#define toksave         68
#define tokbye          69
#define tokdel          70
#define tokrenum        71
#define tokthen         72
#define tokelse         73
#define tokto           74
#define tokstep         75







typedef double numarray[];
typedef Char *strarray[];

#define forloop         0
#define whileloop       1
#define gosubloop       2


typedef struct tokenrec {
  struct tokenrec *next;
  short kind;
  union {
    struct varrec *vp;
    double num;
    Char *sp;
    Char snch;
  } UU;
} tokenrec;

typedef struct linerec {
  long num, num2;
  tokenrec *txt;
  struct linerec *next;
} linerec;

typedef struct varrec {
  varnamestring name;
  struct varrec *next;
  long dims[maxdims];
  char numdims;
  boolean stringvar;
  union {
    struct {
      double *arr;
      double *val, rv;
    } U0;
    struct {
      Char **sarr;
      Char **sval, *sv;
    } U1;
  } UU;
} varrec;

typedef struct valrec {
  boolean stringval;
  union {
    double val;
    Char *sval;
  } UU;
} valrec;

typedef struct looprec {
  struct looprec *next;
  linerec *homeline;
  tokenrec *hometok;
  short kind;
  union {
    struct {
      varrec *vp;
      double max, step;
    } U0;
  } UU;
} looprec;




Static Char *inbuf;

Static linerec *linebase;
Static varrec *varbase;
Static looprec *loopbase;

Static long curline;
Static linerec *stmtline, *dataline;
Static tokenrec *stmttok, *datatok, *buf;

Static boolean exitflag;

extern long EXCP_LINE;



/*$if not checking$
   $range off$
$end$*/











Static Void restoredata()
{
  dataline = NULL;
  datatok = NULL;
}



Static Void clearloops()
{
  looprec *l;

  while (loopbase != NULL) {
    l = loopbase->next;
    Free(loopbase);
    loopbase = l;
  }
}



Static long arraysize(v)
varrec *v;
{
  long i, j, FORLIM;

  if (v->stringvar)
    j = 4;
  else
    j = 8;
  FORLIM = v->numdims;
  for (i = 0; i < FORLIM; i++)
    j *= v->dims[i];
  return j;
}


Static Void clearvar(v)
varrec *v;
{
  if (v->numdims != 0)
    Free(v->UU.U0.arr);
  else if (v->stringvar && v->UU.U1.sv != NULL)
    Free(v->UU.U1.sv);
  v->numdims = 0;
  if (v->stringvar) {
    v->UU.U1.sv = NULL;
    v->UU.U1.sval = &v->UU.U1.sv;
  } else {
    v->UU.U0.rv = 0.0;
    v->UU.U0.val = &v->UU.U0.rv;
  }
}


Static Void clearvars()
{
  varrec *v;

  v = varbase;
  while (v != NULL) {
    clearvar(v);
    v = v->next;
  }
}



Static Char *numtostr(Result, n)
Char *Result;
double n;
{
  string255 s;
  long i;

  s[255] = '\0';
  if (n != 0 && fabs(n) < 1e-2 || fabs(n) >= 1e12) {
    sprintf(s, "% .5E", n);
    i = strlen(s) + 1;
    s[i - 1] = '\0';
/* p2c: dist/examples/basic.p, line 237:
 * Note: Modification of string length may translate incorrectly [146] */
    return strcpy(Result, s);
  } else {
    sprintf(s, "%30.10f", n);
    i = strlen(s) + 1;
    do {
      i--;
    } while (s[i - 1] == '0');
    if (s[i - 1] == '.')
      i--;
    s[i] = '\0';
/* p2c: dist/examples/basic.p, line 248:
 * Note: Modification of string length may translate incorrectly [146] */
    return strcpy(Result, strltrim(s));
  }
}


#define toklength       20


typedef long chset[9];





Static Void parse(inbuf, buf)
Char *inbuf;
tokenrec **buf;
{
  long i, j, k;
  Char token[toklength + 1];
  tokenrec *t, *tptr;
  varrec *v;
  Char ch;
  double n, d, d1;

  tptr = NULL;
  *buf = NULL;
  i = 1;
  do {
    ch = ' ';
    while (i <= strlen(inbuf) && ch == ' ') {
      ch = inbuf[i - 1];
      i++;
    }
    if (ch != ' ') {
      t = (tokenrec *)Malloc(sizeof(tokenrec));
      if (tptr == NULL)
	*buf = t;
      else
	tptr->next = t;
      tptr = t;
      t->next = NULL;
      switch (ch) {

      case '"':
      case '\'':
	t->kind = tokstr;
	t->UU.sp = (Char *)Malloc(256);
	t->UU.sp[255] = '\0';
	j = 0;
	while (i <= strlen(inbuf) && inbuf[i - 1] != ch) {
	  j++;
	  t->UU.sp[j - 1] = inbuf[i - 1];
	  i++;
	}
	t->UU.sp[j] = '\0';
/* p2c: dist/examples/basic.p, line 415:
 * Note: Modification of string length may translate incorrectly [146] */
	i++;
	break;

      case '+':
	t->kind = tokplus;
	break;

      case '-':
	t->kind = tokminus;
	break;

      case '*':
	t->kind = toktimes;
	break;

      case '/':
	t->kind = tokdiv;
	break;

      case '^':
	t->kind = tokup;
	break;

      case '(':
      case '[':
	t->kind = toklp;
	break;

      case ')':
      case ']':
	t->kind = tokrp;
	break;

      case ',':
	t->kind = tokcomma;
	break;

      case ';':
	t->kind = toksemi;
	break;

      case ':':
	t->kind = tokcolon;
	break;

      case '?':
	t->kind = tokprint;
	break;

      case '=':
	t->kind = tokeq;
	break;

      case '<':
	if (i <= strlen(inbuf) && inbuf[i - 1] == '=') {
	  t->kind = tokle;
	  i++;
	} else if (i <= strlen(inbuf) && inbuf[i - 1] == '>') {
	  t->kind = tokne;
	  i++;
	} else
	  t->kind = toklt;
	break;

      case '>':
	if (i <= strlen(inbuf) && inbuf[i - 1] == '=') {
	  t->kind = tokge;
	  i++;
	} else
	  t->kind = tokgt;
	break;

      default:
	if (isalpha(ch)) {
	  i--;
	  j = 0;
	  token[toklength] = '\0';
	  while (i <= strlen(inbuf) &&
		 (inbuf[i - 1] == '$' || inbuf[i - 1] == '_' ||
		  isalnum(inbuf[i - 1]))) {
	    if (j < toklength) {
	      j++;
	      token[j - 1] = inbuf[i - 1];
	    }
	    i++;
	  }
	  token[j] = '\0';
/* p2c: dist/examples/basic.p, line 309:
 * Note: Modification of string length may translate incorrectly [146] */
	  if (!strcmp(token, "and") || !strcmp(token, "AND"))
	    t->kind = tokand;
	  else if (!strcmp(token, "or") || !strcmp(token, "OR"))
	    t->kind = tokor;
	  else if (!strcmp(token, "xor") || !strcmp(token, "XOR"))
	    t->kind = tokxor;
	  else if (!strcmp(token, "not") || !strcmp(token, "NOT"))
	    t->kind = toknot;
	  else if (!strcmp(token, "mod") || !strcmp(token, "MOD"))
	    t->kind = tokmod;
	  else if (!strcmp(token, "sqr") || !strcmp(token, "SQR"))
	    t->kind = toksqr;
	  else if (!strcmp(token, "sqrt") || !strcmp(token, "SQRT"))
	    t->kind = toksqrt;
	  else if (!strcmp(token, "sin") || !strcmp(token, "SIN"))
	    t->kind = toksin;
	  else if (!strcmp(token, "cos") || !strcmp(token, "COS"))
	    t->kind = tokcos;
	  else if (!strcmp(token, "tan") || !strcmp(token, "TAN"))
	    t->kind = toktan;
	  else if (!strcmp(token, "arctan") || !strcmp(token, "ARCTAN"))
	    t->kind = tokarctan;
	  else if (!strcmp(token, "log") || !strcmp(token, "LOG"))
	    t->kind = toklog;
	  else if (!strcmp(token, "exp") || !strcmp(token, "EXP"))
	    t->kind = tokexp;
	  else if (!strcmp(token, "abs") || !strcmp(token, "ABS"))
	    t->kind = tokabs;
	  else if (!strcmp(token, "sgn") || !strcmp(token, "SGN"))
	    t->kind = toksgn;
	  else if (!strcmp(token, "str$") || !strcmp(token, "STR$"))
	    t->kind = tokstr_;
	  else if (!strcmp(token, "val") || !strcmp(token, "VAL"))
	    t->kind = tokval;
	  else if (!strcmp(token, "chr$") || !strcmp(token, "CHR$"))
	    t->kind = tokchr_;
	  else if (!strcmp(token, "asc") || !strcmp(token, "ASC"))
	    t->kind = tokasc;
	  else if (!strcmp(token, "len") || !strcmp(token, "LEN"))
	    t->kind = toklen;
	  else if (!strcmp(token, "mid$") || !strcmp(token, "MID$"))
	    t->kind = tokmid_;
	  else if (!strcmp(token, "peek") || !strcmp(token, "PEEK"))
	    t->kind = tokpeek;
	  else if (!strcmp(token, "let") || !strcmp(token, "LET"))
	    t->kind = toklet;
	  else if (!strcmp(token, "print") || !strcmp(token, "PRINT"))
	    t->kind = tokprint;
	  else if (!strcmp(token, "input") || !strcmp(token, "INPUT"))
	    t->kind = tokinput;
	  else if (!strcmp(token, "goto") || !strcmp(token, "GOTO"))
	    t->kind = tokgoto;
	  else if (!strcmp(token, "go to") || !strcmp(token, "GO TO"))
	    t->kind = tokgoto;
	  else if (!strcmp(token, "if") || !strcmp(token, "IF"))
	    t->kind = tokif;
	  else if (!strcmp(token, "end") || !strcmp(token, "END"))
	    t->kind = tokend;
	  else if (!strcmp(token, "stop") || !strcmp(token, "STOP"))
	    t->kind = tokstop;
	  else if (!strcmp(token, "for") || !strcmp(token, "FOR"))
	    t->kind = tokfor;
	  else if (!strcmp(token, "next") || !strcmp(token, "NEXT"))
	    t->kind = toknext;
	  else if (!strcmp(token, "while") || !strcmp(token, "WHILE"))
	    t->kind = tokwhile;
	  else if (!strcmp(token, "wend") || !strcmp(token, "WEND"))
	    t->kind = tokwend;
	  else if (!strcmp(token, "gosub") || !strcmp(token, "GOSUB"))
	    t->kind = tokgosub;
	  else if (!strcmp(token, "return") || !strcmp(token, "RETURN"))
	    t->kind = tokreturn;
	  else if (!strcmp(token, "read") || !strcmp(token, "READ"))
	    t->kind = tokread;
	  else if (!strcmp(token, "data") || !strcmp(token, "DATA"))
	    t->kind = tokdata;
	  else if (!strcmp(token, "restore") || !strcmp(token, "RESTORE"))
	    t->kind = tokrestore;
	  else if (!strcmp(token, "gotoxy") || !strcmp(token, "GOTOXY"))
	    t->kind = tokgotoxy;
	  else if (!strcmp(token, "on") || !strcmp(token, "ON"))
	    t->kind = tokon;
	  else if (!strcmp(token, "dim") || !strcmp(token, "DIM"))
	    t->kind = tokdim;
	  else if (!strcmp(token, "poke") || !strcmp(token, "POKE"))
	    t->kind = tokpoke;
	  else if (!strcmp(token, "list") || !strcmp(token, "LIST"))
	    t->kind = toklist;
	  else if (!strcmp(token, "run") || !strcmp(token, "RUN"))
	    t->kind = tokrun;
	  else if (!strcmp(token, "new") || !strcmp(token, "NEW"))
	    t->kind = toknew;
	  else if (!strcmp(token, "load") || !strcmp(token, "LOAD"))
	    t->kind = tokload;
	  else if (!strcmp(token, "merge") || !strcmp(token, "MERGE"))
	    t->kind = tokmerge;
	  else if (!strcmp(token, "save") || !strcmp(token, "SAVE"))
	    t->kind = toksave;
	  else if (!strcmp(token, "bye") || !strcmp(token, "BYE"))
	    t->kind = tokbye;
	  else if (!strcmp(token, "quit") || !strcmp(token, "QUIT"))
	    t->kind = tokbye;
	  else if (!strcmp(token, "del") || !strcmp(token, "DEL"))
	    t->kind = tokdel;
	  else if (!strcmp(token, "renum") || !strcmp(token, "RENUM"))
	    t->kind = tokrenum;
	  else if (!strcmp(token, "then") || !strcmp(token, "THEN"))
	    t->kind = tokthen;
	  else if (!strcmp(token, "else") || !strcmp(token, "ELSE"))
	    t->kind = tokelse;
	  else if (!strcmp(token, "to") || !strcmp(token, "TO"))
	    t->kind = tokto;
	  else if (!strcmp(token, "step") || !strcmp(token, "STEP"))
	    t->kind = tokstep;
	  else if (!strcmp(token, "rem") || !strcmp(token, "REM")) {
	    t->kind = tokrem;
	    t->UU.sp = (Char *)Malloc(256);
	    sprintf(t->UU.sp, "%.*s",
		    (int)(strlen(inbuf) - i + 1), inbuf + i - 1);
	    i = strlen(inbuf) + 1;
	  } else {
	    t->kind = tokvar;
	    v = varbase;
	    while (v != NULL && strcmp(v->name, token))
	      v = v->next;
	    if (v == NULL) {
	      v = (varrec *)Malloc(sizeof(varrec));
	      v->next = varbase;
	      varbase = v;
	      strcpy(v->name, token);
	      v->numdims = 0;
	      if (token[strlen(token) - 1] == '$') {
		v->stringvar = true;
		v->UU.U1.sv = NULL;
		v->UU.U1.sval = &v->UU.U1.sv;
	      } else {
		v->stringvar = false;
		v->UU.U0.rv = 0.0;
		v->UU.U0.val = &v->UU.U0.rv;
	      }
	    }
	    t->UU.vp = v;
	  }
	} else if (isdigit(ch) || ch == '.') {
	  t->kind = toknum;
	  n = 0.0;
	  d = 1.0;
	  d1 = 1.0;
	  i--;
	  while (i <= strlen(inbuf) &&
		 (isdigit(inbuf[i - 1]) || inbuf[i - 1] == '.' && d1 == 1)) {
	    if (inbuf[i - 1] == '.')
	      d1 = 10.0;
	    else {
	      n = n * 10 + inbuf[i - 1] - 48;
	      d *= d1;
	    }
	    i++;
	  }
	  n /= d;
	  if (i <= strlen(inbuf) &&
	      (inbuf[i - 1] == 'E' || inbuf[i - 1] == 'e')) {
	    i++;
	    d1 = 10.0;
	    if (i <= strlen(inbuf) &&
		(inbuf[i - 1] == '-' || inbuf[i - 1] == '+')) {
	      if (inbuf[i - 1] == '-')
		d1 = 0.1;
	      i++;
	    }
	    j = 0;
	    while (i <= strlen(inbuf) && isdigit(inbuf[i - 1])) {
	      j = j * 10 + inbuf[i - 1] - 48;
	      i++;
	    }
	    for (k = 1; k <= j; k++)
	      n *= d1;
	  }
	  t->UU.num = n;
	} else {
	  t->kind = toksnerr;
	  t->UU.snch = ch;
	}
	break;
      }
    }
  } while (i <= strlen(inbuf));
}

#undef toklength



Static Void listtokens(f, buf)
FILE *f;
tokenrec *buf;
{
  boolean ltr;
  Char STR1[256];

  ltr = false;
  while (buf != NULL) {
    if ((long)buf->kind >= toknot && (long)buf->kind <= tokrenum ||
	buf->kind == toknum || buf->kind == tokvar) {
      if (ltr)
	putc(' ', f);
      ltr = (buf->kind != toknot);
    } else
      ltr = false;
    switch (buf->kind) {

    case tokvar:
      fputs(buf->UU.vp->name, f);
      break;

    case toknum:
      fputs(numtostr(STR1, buf->UU.num), f);
      break;

    case tokstr:
      fprintf(f, "\"%s\"", buf->UU.sp);
      break;

    case toksnerr:
      fprintf(f, "{%c}", buf->UU.snch);
      break;

    case tokplus:
      putc('+', f);
      break;

    case tokminus:
      putc('-', f);
      break;

    case toktimes:
      putc('*', f);
      break;

    case tokdiv:
      putc('/', f);
      break;

    case tokup:
      putc('^', f);
      break;

    case toklp:
      putc('(', f);
      break;

    case tokrp:
      putc(')', f);
      break;

    case tokcomma:
      putc(',', f);
      break;

    case toksemi:
      putc(';', f);
      break;

    case tokcolon:
      fprintf(f, " : ");
      break;

    case tokeq:
      fprintf(f, " = ");
      break;

    case toklt:
      fprintf(f, " < ");
      break;

    case tokgt:
      fprintf(f, " > ");
      break;

    case tokle:
      fprintf(f, " <= ");
      break;

    case tokge:
      fprintf(f, " >= ");
      break;

    case tokne:
      fprintf(f, " <> ");
      break;

    case tokand:
      fprintf(f, " AND ");
      break;

    case tokor:
      fprintf(f, " OR ");
      break;

    case tokxor:
      fprintf(f, " XOR ");
      break;

    case tokmod:
      fprintf(f, " MOD ");
      break;

    case toknot:
      fprintf(f, "NOT ");
      break;

    case toksqr:
      fprintf(f, "SQR");
      break;

    case toksqrt:
      fprintf(f, "SQRT");
      break;

    case toksin:
      fprintf(f, "SIN");
      break;

    case tokcos:
      fprintf(f, "COS");
      break;

    case toktan:
      fprintf(f, "TAN");
      break;

    case tokarctan:
      fprintf(f, "ARCTAN");
      break;

    case toklog:
      fprintf(f, "LOG");
      break;

    case tokexp:
      fprintf(f, "EXP");
      break;

    case tokabs:
      fprintf(f, "ABS");
      break;

    case toksgn:
      fprintf(f, "SGN");
      break;

    case tokstr_:
      fprintf(f, "STR$");
      break;

    case tokval:
      fprintf(f, "VAL");
      break;

    case tokchr_:
      fprintf(f, "CHR$");
      break;

    case tokasc:
      fprintf(f, "ASC");
      break;

    case toklen:
      fprintf(f, "LEN");
      break;

    case tokmid_:
      fprintf(f, "MID$");
      break;

    case tokpeek:
      fprintf(f, "PEEK");
      break;

    case toklet:
      fprintf(f, "LET");
      break;

    case tokprint:
      fprintf(f, "PRINT");
      break;

    case tokinput:
      fprintf(f, "INPUT");
      break;

    case tokgoto:
      fprintf(f, "GOTO");
      break;

    case tokif:
      fprintf(f, "IF");
      break;

    case tokend:
      fprintf(f, "END");
      break;

    case tokstop:
      fprintf(f, "STOP");
      break;

    case tokfor:
      fprintf(f, "FOR");
      break;

    case toknext:
      fprintf(f, "NEXT");
      break;

    case tokwhile:
      fprintf(f, "WHILE");
      break;

    case tokwend:
      fprintf(f, "WEND");
      break;

    case tokgosub:
      fprintf(f, "GOSUB");
      break;

    case tokreturn:
      fprintf(f, "RETURN");
      break;

    case tokread:
      fprintf(f, "READ");
      break;

    case tokdata:
      fprintf(f, "DATA");
      break;

    case tokrestore:
      fprintf(f, "RESTORE");
      break;

    case tokgotoxy:
      fprintf(f, "GOTOXY");
      break;

    case tokon:
      fprintf(f, "ON");
      break;

    case tokdim:
      fprintf(f, "DIM");
      break;

    case tokpoke:
      fprintf(f, "POKE");
      break;

    case toklist:
      fprintf(f, "LIST");
      break;

    case tokrun:
      fprintf(f, "RUN");
      break;

    case toknew:
      fprintf(f, "NEW");
      break;

    case tokload:
      fprintf(f, "LOAD");
      break;

    case tokmerge:
      fprintf(f, "MERGE");
      break;

    case toksave:
      fprintf(f, "SAVE");
      break;

    case tokdel:
      fprintf(f, "DEL");
      break;

    case tokbye:
      fprintf(f, "BYE");
      break;

    case tokrenum:
      fprintf(f, "RENUM");
      break;

    case tokthen:
      fprintf(f, " THEN ");
      break;

    case tokelse:
      fprintf(f, " ELSE ");
      break;

    case tokto:
      fprintf(f, " TO ");
      break;

    case tokstep:
      fprintf(f, " STEP ");
      break;

    case tokrem:
      fprintf(f, "REM%s", buf->UU.sp);
      break;
    }
    buf = buf->next;
  }
}



Static Void disposetokens(tok)
tokenrec **tok;
{
  tokenrec *tok1;

  while (*tok != NULL) {
    tok1 = (*tok)->next;
    if ((*tok)->kind == tokrem || (*tok)->kind == tokstr)
      Free((*tok)->UU.sp);
    Free(*tok);
    *tok = tok1;
  }
}



Static Void parseinput(buf)
tokenrec **buf;
{
  linerec *l, *l0, *l1;
  Char STR1[256];

  strcpy(STR1, strltrim(inbuf));
  strcpy(inbuf, STR1);
  curline = 0;
  while (*inbuf != '\0' && isdigit(inbuf[0])) {
    curline = curline * 10 + inbuf[0] - 48;
    strcpy(inbuf, inbuf + 1);
  }
  parse(inbuf, buf);
  if (curline == 0)
    return;
  l = linebase;
  l0 = NULL;
  while (l != NULL && l->num < curline) {
    l0 = l;
    l = l->next;
  }
  if (l != NULL && l->num == curline) {
    l1 = l;
    l = l->next;
    if (l0 == NULL)
      linebase = l;
    else
      l0->next = l;
    disposetokens(&l1->txt);
    Free(l1);
  }
  if (*buf != NULL) {
    l1 = (linerec *)Malloc(sizeof(linerec));
    l1->next = l;
    if (l0 == NULL)
      linebase = l1;
    else
      l0->next = l1;
    l1->num = curline;
    l1->txt = *buf;
  }
  clearloops();
  restoredata();
}





Static Void errormsg(s)
Char *s;
{
  printf("\007%s", s);
  _Escape(42);
}


Static Void snerr()
{
  errormsg("Syntax error");
}


Static Void tmerr()
{
  errormsg("Type mismatch error");
}


Static Void badsubscr()
{
  errormsg("Bad subscript");
}


/* Local variables for exec: */
struct LOC_exec {
  boolean gotoflag, elseflag;
  tokenrec *t;
} ;

Local valrec factor PP((struct LOC_exec *LINK));
Local valrec expr PP((struct LOC_exec *LINK));

Local double realfactor(LINK)
struct LOC_exec *LINK;
{
  valrec n;

  n = factor(LINK);
  if (n.stringval)
    tmerr();
  return (n.UU.val);
}

Local Char *strfactor(LINK)
struct LOC_exec *LINK;
{
  valrec n;

  n = factor(LINK);
  if (!n.stringval)
    tmerr();
  return (n.UU.sval);
}

Local Char *stringfactor(Result, LINK)
Char *Result;
struct LOC_exec *LINK;
{
  valrec n;

  n = factor(LINK);
  if (!n.stringval)
    tmerr();
  strcpy(Result, n.UU.sval);
  Free(n.UU.sval);
  return Result;
}

Local long intfactor(LINK)
struct LOC_exec *LINK;
{
  return ((long)floor(realfactor(LINK) + 0.5));
}

Local double realexpr(LINK)
struct LOC_exec *LINK;
{
  valrec n;

  n = expr(LINK);
  if (n.stringval)
    tmerr();
  return (n.UU.val);
}

Local Char *strexpr(LINK)
struct LOC_exec *LINK;
{
  valrec n;

  n = expr(LINK);
  if (!n.stringval)
    tmerr();
  return (n.UU.sval);
}

Local Char *stringexpr(Result, LINK)
Char *Result;
struct LOC_exec *LINK;
{
  valrec n;

  n = expr(LINK);
  if (!n.stringval)
    tmerr();
  strcpy(Result, n.UU.sval);
  Free(n.UU.sval);
  return Result;
}

Local long intexpr(LINK)
struct LOC_exec *LINK;
{
  return ((long)floor(realexpr(LINK) + 0.5));
}


Local Void require(k, LINK)
short k;
struct LOC_exec *LINK;
{
  if (LINK->t == NULL || LINK->t->kind != k)
    snerr();
  LINK->t = LINK->t->next;
}


Local Void skipparen(LINK)
struct LOC_exec *LINK;
{
  do {
    if (LINK->t == NULL)
      snerr();
    if (LINK->t->kind == tokrp || LINK->t->kind == tokcomma)
      goto _L1;
    if (LINK->t->kind == toklp) {
      LINK->t = LINK->t->next;
      skipparen(LINK);
    }
    LINK->t = LINK->t->next;
  } while (true);
_L1: ;
}


Local varrec *findvar(LINK)
struct LOC_exec *LINK;
{
  varrec *v;
  long i, j, k;
  tokenrec *tok;
  long FORLIM;

  if (LINK->t == NULL || LINK->t->kind != tokvar)
    snerr();
  v = LINK->t->UU.vp;
  LINK->t = LINK->t->next;
  if (LINK->t == NULL || LINK->t->kind != toklp) {
    if (v->numdims != 0)
      badsubscr();
    return v;
  }
  if (v->numdims == 0) {
    tok = LINK->t;
    i = 0;
    j = 1;
    do {
      if (i >= maxdims)
	badsubscr();
      LINK->t = LINK->t->next;
      skipparen(LINK);
      j *= 11;
      i++;
      v->dims[i - 1] = 11;
    } while (LINK->t->kind != tokrp);
    v->numdims = i;
    if (v->stringvar) {
      v->UU.U1.sarr = (Char **)Malloc(j * 4);
      for (k = 0; k < j; k++)
	v->UU.U1.sarr[k] = NULL;
    } else {
      v->UU.U0.arr = (double *)Malloc(j * 8);
      for (k = 0; k < j; k++)
	v->UU.U0.arr[k] = 0.0;
    }
    LINK->t = tok;
  }
  k = 0;
  LINK->t = LINK->t->next;
  FORLIM = v->numdims;
  for (i = 1; i <= FORLIM; i++) {
    j = intexpr(LINK);
    if ((unsigned long)j >= v->dims[i - 1])
      badsubscr();
    k = k * v->dims[i - 1] + j;
    if (i < v->numdims)
      require(tokcomma, LINK);
  }
  require(tokrp, LINK);
  if (v->stringvar)
    v->UU.U1.sval = &v->UU.U1.sarr[k];
  else
    v->UU.U0.val = &v->UU.U0.arr[k];
  return v;
}


Local long inot(i, LINK)
long i;
struct LOC_exec *LINK;
{
  return (-i - 1);
}

Local long ixor(a, b, LINK)
long a, b;
struct LOC_exec *LINK;
{
  return ((a & (~b)) | ((~a) & b));
}


Local valrec factor(LINK)
struct LOC_exec *LINK;
{
  varrec *v;
  tokenrec *facttok;
  valrec n;
  long i, j;
  tokenrec *tok, *tok1;
  Char *s;
  union {
    long i;
    Char *c;
  } trick;
  double TEMP;
  Char STR1[256];

  if (LINK->t == NULL)
    snerr();
  facttok = LINK->t;
  LINK->t = LINK->t->next;
  n.stringval = false;
  switch (facttok->kind) {

  case toknum:
    n.UU.val = facttok->UU.num;
    break;

  case tokstr:
    n.stringval = true;
    n.UU.sval = (Char *)Malloc(256);
    strcpy(n.UU.sval, facttok->UU.sp);
    break;

  case tokvar:
    LINK->t = facttok;
    v = findvar(LINK);
    n.stringval = v->stringvar;
    if (n.stringval) {
      n.UU.sval = (Char *)Malloc(256);
      strcpy(n.UU.sval, *v->UU.U1.sval);
    } else
      n.UU.val = *v->UU.U0.val;
    break;

  case toklp:
    n = expr(LINK);
    require(tokrp, LINK);
    break;

  case tokminus:
    n.UU.val = -realfactor(LINK);
    break;

  case tokplus:
    n.UU.val = realfactor(LINK);
    break;

  case toknot:
    n.UU.val = ~intfactor(LINK);
    break;

  case toksqr:
    TEMP = realfactor(LINK);
    n.UU.val = TEMP * TEMP;
    break;

  case toksqrt:
    n.UU.val = sqrt(realfactor(LINK));
    break;

  case toksin:
    n.UU.val = sin(realfactor(LINK));
    break;

  case tokcos:
    n.UU.val = cos(realfactor(LINK));
    break;

  case toktan:
    n.UU.val = realfactor(LINK);
    n.UU.val = sin(n.UU.val) / cos(n.UU.val);
    break;

  case tokarctan:
    n.UU.val = atan(realfactor(LINK));
    break;

  case toklog:
    n.UU.val = log(realfactor(LINK));
    break;

  case tokexp:
    n.UU.val = exp(realfactor(LINK));
    break;

  case tokabs:
    n.UU.val = fabs(realfactor(LINK));
    break;

  case toksgn:
    n.UU.val = realfactor(LINK);
    n.UU.val = (n.UU.val > 0) - (n.UU.val < 0);
    break;

  case tokstr_:
    n.stringval = true;
    n.UU.sval = (Char *)Malloc(256);
    numtostr(n.UU.sval, realfactor(LINK));
    break;

  case tokval:
    s = strfactor(LINK);
    tok1 = LINK->t;
    parse(s, &LINK->t);
    tok = LINK->t;
    if (tok == NULL)
      n.UU.val = 0.0;
    else
      n = expr(LINK);
    disposetokens(&tok);
    LINK->t = tok1;
    Free(s);
    break;

  case tokchr_:
    n.stringval = true;
    n.UU.sval = (Char *)Malloc(256);
    strcpy(n.UU.sval, " ");
    n.UU.sval[0] = (Char)intfactor(LINK);
    break;

  case tokasc:
    s = strfactor(LINK);
    if (*s == '\0')
      n.UU.val = 0.0;
    else
      n.UU.val = s[0];
    Free(s);
    break;

  case tokmid_:
    n.stringval = true;
    require(toklp, LINK);
    n.UU.sval = strexpr(LINK);
    require(tokcomma, LINK);
    i = intexpr(LINK);
    if (i < 1)
      i = 1;
    j = 255;
    if (LINK->t != NULL && LINK->t->kind == tokcomma) {
      LINK->t = LINK->t->next;
      j = intexpr(LINK);
    }
    if (j > strlen(n.UU.sval) - i + 1)
      j = strlen(n.UU.sval) - i + 1;
    if (i > strlen(n.UU.sval))
      *n.UU.sval = '\0';
    else {
      sprintf(STR1, "%.*s", (int)j, n.UU.sval + i - 1);
      strcpy(n.UU.sval, STR1);
    }
    require(tokrp, LINK);
    break;

  case toklen:
    s = strfactor(LINK);
    n.UU.val = strlen(s);
    Free(s);
    break;

  case tokpeek:
/* p2c: dist/examples/basic.p, line 1029:
 * Note: Range checking is OFF [216] */
    trick.i = intfactor(LINK);
    n.UU.val = *trick.c;
/* p2c: dist/examples/basic.p, line 1032:
 * Note: Range checking is ON [216] */
    break;

  default:
    snerr();
    break;
  }
  return n;
}

Local valrec upexpr(LINK)
struct LOC_exec *LINK;
{
  valrec n, n2;

  n = factor(LINK);
  while (LINK->t != NULL && LINK->t->kind == tokup) {
    if (n.stringval)
      tmerr();
    LINK->t = LINK->t->next;
    n2 = upexpr(LINK);
    if (n2.stringval)
      tmerr();
    if (n.UU.val >= 0) {
      n.UU.val = exp(n2.UU.val * log(n.UU.val));
      continue;
    }
    if (n2.UU.val != (long)n2.UU.val)
      n.UU.val = log(n.UU.val);
    n.UU.val = exp(n2.UU.val * log(-n.UU.val));
    if (((long)n2.UU.val) & 1)
      n.UU.val = -n.UU.val;
  }
  return n;
}

Local valrec term(LINK)
struct LOC_exec *LINK;
{
  valrec n, n2;
  short k;

  n = upexpr(LINK);
  while (LINK->t != NULL && (unsigned long)LINK->t->kind < 32 &&
	 ((1L << ((long)LINK->t->kind)) & ((1L << ((long)toktimes)) |
	    (1L << ((long)tokdiv)) | (1L << ((long)tokmod)))) != 0) {
    k = LINK->t->kind;
    LINK->t = LINK->t->next;
    n2 = upexpr(LINK);
    if (n.stringval || n2.stringval)
      tmerr();
    if (k == tokmod) {
      n.UU.val = (long)floor(n.UU.val + 0.5) % (long)floor(n2.UU.val + 0.5);
/* p2c: dist/examples/basic.p, line 1078:
 * Note: Using % for possibly-negative arguments [317] */
    } else if (k == toktimes)
      n.UU.val *= n2.UU.val;
    else
      n.UU.val /= n2.UU.val;
  }
  return n;
}

Local valrec sexpr(LINK)
struct LOC_exec *LINK;
{
  valrec n, n2;
  short k;

  n = term(LINK);
  while (LINK->t != NULL && (unsigned long)LINK->t->kind < 32 &&
	 ((1L << ((long)LINK->t->kind)) &
	  ((1L << ((long)tokplus)) | (1L << ((long)tokminus)))) != 0) {
    k = LINK->t->kind;
    LINK->t = LINK->t->next;
    n2 = term(LINK);
    if (n.stringval != n2.stringval)
      tmerr();
    if (k == tokplus) {
      if (n.stringval) {
	strcat(n.UU.sval, n2.UU.sval);
	Free(n2.UU.sval);
      } else
	n.UU.val += n2.UU.val;
    } else {
      if (n.stringval)
	tmerr();
      else
	n.UU.val -= n2.UU.val;
    }
  }
  return n;
}

Local valrec relexpr(LINK)
struct LOC_exec *LINK;
{
  valrec n, n2;
  boolean f;
  short k;

  n = sexpr(LINK);
  while (LINK->t != NULL && (unsigned long)LINK->t->kind < 32 &&
	 ((1L << ((long)LINK->t->kind)) &
	  ((1L << ((long)tokne + 1)) - (1L << ((long)tokeq)))) != 0) {
    k = LINK->t->kind;
    LINK->t = LINK->t->next;
    n2 = sexpr(LINK);
    if (n.stringval != n2.stringval)
      tmerr();
    if (n.stringval) {
      f = ((!strcmp(n.UU.sval, n2.UU.sval) && (unsigned long)k < 32 &&
	    ((1L << ((long)k)) & ((1L << ((long)tokeq)) |
		  (1L << ((long)tokge)) | (1L << ((long)tokle)))) != 0) ||
	  (strcmp(n.UU.sval, n2.UU.sval) < 0 && (unsigned long)k < 32 &&
	    ((1L << ((long)k)) & ((1L << ((long)toklt)) |
		  (1L << ((long)tokle)) | (1L << ((long)tokne)))) != 0) ||
	  (strcmp(n.UU.sval, n2.UU.sval) > 0 && (unsigned long)k < 32 &&
	    ((1L << ((long)k)) & ((1L << ((long)tokgt)) |
		  (1L << ((long)tokge)) | (1L << ((long)tokne)))) != 0));
/* p2c: dist/examples/basic.p, line 2175: Note:
 * Line breaker spent 0.0+8.00 seconds, 5000 tries on line 1554 [251] */
      Free(n.UU.sval);
      Free(n2.UU.sval);
    } else
      f = ((n.UU.val == n2.UU.val && (unsigned long)k < 32 && ((1L <<
		  ((long)k)) & ((1L << ((long)tokeq)) |
		  (1L << ((long)tokge)) | (1L << ((long)tokle)))) != 0) ||
	  (n.UU.val < n2.UU.val && (unsigned long)k < 32 &&
	    ((1L << ((long)k)) & ((1L << ((long)toklt)) |
		  (1L << ((long)tokle)) | (1L << ((long)tokne)))) != 0) ||
	  (n.UU.val > n2.UU.val && (unsigned long)k < 32 &&
	    ((1L << ((long)k)) & ((1L << ((long)tokgt)) |
		  (1L << ((long)tokge)) | (1L << ((long)tokne)))) != 0));
/* p2c: dist/examples/basic.p, line 2175: Note:
 * Line breaker spent 0.0+9.00 seconds, 5000 tries on line 1568 [251] */
    n.stringval = false;
    n.UU.val = f;
  }
  return n;
}

Local valrec andexpr(LINK)
struct LOC_exec *LINK;
{
  valrec n, n2;

  n = relexpr(LINK);
  while (LINK->t != NULL && LINK->t->kind == tokand) {
    LINK->t = LINK->t->next;
    n2 = relexpr(LINK);
    if (n.stringval || n2.stringval)
      tmerr();
    n.UU.val = ((long)n.UU.val) & ((long)n2.UU.val);
  }
  return n;
}

Local valrec expr(LINK)
struct LOC_exec *LINK;
{
  valrec n, n2;
  short k;

  n = andexpr(LINK);
  while (LINK->t != NULL && (unsigned long)LINK->t->kind < 32 &&
	 ((1L << ((long)LINK->t->kind)) &
	  ((1L << ((long)tokor)) | (1L << ((long)tokxor)))) != 0) {
    k = LINK->t->kind;
    LINK->t = LINK->t->next;
    n2 = andexpr(LINK);
    if (n.stringval || n2.stringval)
      tmerr();
    if (k == tokor)
      n.UU.val = ((long)n.UU.val) | ((long)n2.UU.val);
    else
      n.UU.val = ((long)n.UU.val) ^ ((long)n2.UU.val);
  }
  return n;
}


Local Void checkextra(LINK)
struct LOC_exec *LINK;
{
  if (LINK->t != NULL)
    errormsg("Extra information on line");
}


Local boolean iseos(LINK)
struct LOC_exec *LINK;
{
  return (LINK->t == NULL || LINK->t->kind == tokelse ||
	  LINK->t->kind == tokcolon);
}


Local Void skiptoeos(LINK)
struct LOC_exec *LINK;
{
  while (!iseos(LINK))
    LINK->t = LINK->t->next;
}


Local linerec *findline(n, LINK)
long n;
struct LOC_exec *LINK;
{
  linerec *l;

  l = linebase;
  while (l != NULL && l->num != n)
    l = l->next;
  return l;
}


Local linerec *mustfindline(n, LINK)
long n;
struct LOC_exec *LINK;
{
  linerec *l;

  l = findline(n, LINK);
  if (l == NULL)
    errormsg("Undefined line");
  return l;
}


Local Void cmdend(LINK)
struct LOC_exec *LINK;
{
  stmtline = NULL;
  LINK->t = NULL;
}


Local Void cmdnew(LINK)
struct LOC_exec *LINK;
{
  Anyptr p;

  cmdend(LINK);
  clearloops();
  restoredata();
  while (linebase != NULL) {
    p = (Anyptr)linebase->next;
    disposetokens(&linebase->txt);
    Free(linebase);
    linebase = (linerec *)p;
  }
  while (varbase != NULL) {
    p = (Anyptr)varbase->next;
    if (varbase->stringvar) {
      if (*varbase->UU.U1.sval != NULL)
	Free(*varbase->UU.U1.sval);
    }
    Free(varbase);
    varbase = (varrec *)p;
  }
}


Local Void cmdlist(LINK)
struct LOC_exec *LINK;
{
  linerec *l;
  long n1, n2;

  do {
    n1 = 0;
    n2 = LONG_MAX;
    if (LINK->t != NULL && LINK->t->kind == toknum) {
      n1 = (long)LINK->t->UU.num;
      LINK->t = LINK->t->next;
      if (LINK->t == NULL || LINK->t->kind != tokminus)
	n2 = n1;
    }
    if (LINK->t != NULL && LINK->t->kind == tokminus) {
      LINK->t = LINK->t->next;
      if (LINK->t != NULL && LINK->t->kind == toknum) {
	n2 = (long)LINK->t->UU.num;
	LINK->t = LINK->t->next;
      } else
	n2 = LONG_MAX;
    }
    l = linebase;
    while (l != NULL && l->num <= n2) {
      if (l->num >= n1) {
	printf("%ld ", l->num);
	listtokens(stdout, l->txt);
	putchar('\n');
      }
      l = l->next;
    }
    if (!iseos(LINK))
      require(tokcomma, LINK);
  } while (!iseos(LINK));
}


Local Void cmdload(merging, name, LINK)
boolean merging;
Char *name;
struct LOC_exec *LINK;
{
  FILE *f;
  tokenrec *buf;
  Char STR1[256];
  Char *TEMP;

  f = NULL;
  if (!merging)
    cmdnew(LINK);
  if (f != NULL) {
    sprintf(STR1, "%s.TEXT", name);
    f = freopen(STR1, "r", f);
  } else {
    sprintf(STR1, "%s.TEXT", name);
    f = fopen(STR1, "r");
  }
  if (f == NULL)
    _EscIO(FileNotFound);
  while (fgets(inbuf, 256, f) != NULL) {
    TEMP = strchr(inbuf, '\n');
    if (TEMP != NULL)
      *TEMP = 0;
    parseinput(&buf);
    if (curline == 0) {
      printf("Bad line in file\n");
      disposetokens(&buf);
    }
  }
  if (f != NULL)
    fclose(f);
  f = NULL;
  if (f != NULL)
    fclose(f);
}


Local Void cmdrun(LINK)
struct LOC_exec *LINK;
{
  linerec *l;
  long i;
  string255 s;

  l = linebase;
  if (!iseos(LINK)) {
    if (LINK->t->kind == toknum)
      l = mustfindline(intexpr(LINK), LINK);
    else {
      stringexpr(s, LINK);
      i = 0;
      if (!iseos(LINK)) {
	require(tokcomma, LINK);
	i = intexpr(LINK);
      }
      checkextra(LINK);
      cmdload(false, s, LINK);
      if (i == 0)
	l = linebase;
      else
	l = mustfindline(i, LINK);
    }
  }
  stmtline = l;
  LINK->gotoflag = true;
  clearvars();
  clearloops();
  restoredata();
}


Local Void cmdsave(LINK)
struct LOC_exec *LINK;
{
  FILE *f;
  linerec *l;
  Char STR1[256], STR2[256];

  f = NULL;
  if (f != NULL) {
    sprintf(STR2, "%s.TEXT", stringexpr(STR1, LINK));
    f = freopen(STR2, "w", f);
  } else {
    sprintf(STR2, "%s.TEXT", stringexpr(STR1, LINK));
    f = fopen(STR2, "w");
  }
  if (f == NULL)
    _EscIO(FileNotFound);
  l = linebase;
  while (l != NULL) {
    fprintf(f, "%ld ", l->num);
    listtokens(f, l->txt);
    putc('\n', f);
    l = l->next;
  }
  if (f != NULL)
    fclose(f);
  f = NULL;
  if (f != NULL)
    fclose(f);
}


Local Void cmdbye(LINK)
struct LOC_exec *LINK;
{
  exitflag = true;
}


Local Void cmddel(LINK)
struct LOC_exec *LINK;
{
  linerec *l, *l0, *l1;
  long n1, n2;

  do {
    if (iseos(LINK))
      snerr();
    n1 = 0;
    n2 = LONG_MAX;
    if (LINK->t != NULL && LINK->t->kind == toknum) {
      n1 = (long)LINK->t->UU.num;
      LINK->t = LINK->t->next;
      if (LINK->t == NULL || LINK->t->kind != tokminus)
	n2 = n1;
    }
    if (LINK->t != NULL && LINK->t->kind == tokminus) {
      LINK->t = LINK->t->next;
      if (LINK->t != NULL && LINK->t->kind == toknum) {
	n2 = (long)LINK->t->UU.num;
	LINK->t = LINK->t->next;
      } else
	n2 = LONG_MAX;
    }
    l = linebase;
    l0 = NULL;
    while (l != NULL && l->num <= n2) {
      l1 = l->next;
      if (l->num >= n1) {
	if (l == stmtline) {
	  cmdend(LINK);
	  clearloops();
	  restoredata();
	}
	if (l0 == NULL)
	  linebase = l->next;
	else
	  l0->next = l->next;
	disposetokens(&l->txt);
	Free(l);
      } else
	l0 = l;
      l = l1;
    }
    if (!iseos(LINK))
      require(tokcomma, LINK);
  } while (!iseos(LINK));
}


Local Void cmdrenum(LINK)
struct LOC_exec *LINK;
{
  linerec *l, *l1;
  tokenrec *tok;
  long lnum, step;

  lnum = 10;
  step = 10;
  if (!iseos(LINK)) {
    lnum = intexpr(LINK);
    if (!iseos(LINK)) {
      require(tokcomma, LINK);
      step = intexpr(LINK);
    }
  }
  l = linebase;
  if (l == NULL)
    return;
  while (l != NULL) {
    l->num2 = lnum;
    lnum += step;
    l = l->next;
  }
  l = linebase;
  do {
    tok = l->txt;
    do {
      if (tok->kind == tokdel || tok->kind == tokrestore ||
	  tok->kind == toklist || tok->kind == tokrun ||
	  tok->kind == tokelse || tok->kind == tokthen ||
	  tok->kind == tokgosub || tok->kind == tokgoto) {
	while (tok->next != NULL && tok->next->kind == toknum) {
	  tok = tok->next;
	  lnum = (long)floor(tok->UU.num + 0.5);
	  l1 = linebase;
	  while (l1 != NULL && l1->num != lnum)
	    l1 = l1->next;
	  if (l1 == NULL)
	    printf("Undefined line %ld in line %ld\n", lnum, l->num2);
	  else
	    tok->UU.num = l1->num2;
	  if (tok->next != NULL && tok->next->kind == tokcomma)
	    tok = tok->next;
	}
      }
      tok = tok->next;
    } while (tok != NULL);
    l = l->next;
  } while (l != NULL);
  l = linebase;
  while (l != NULL) {
    l->num = l->num2;
    l = l->next;
  }
}


Local Void cmdprint(LINK)
struct LOC_exec *LINK;
{
  boolean semiflag;
  valrec n;
  Char STR1[256];

  semiflag = false;
  while (!iseos(LINK)) {
    semiflag = false;
    if ((unsigned long)LINK->t->kind < 32 &&
	((1L << ((long)LINK->t->kind)) &
	 ((1L << ((long)toksemi)) | (1L << ((long)tokcomma)))) != 0) {
      semiflag = true;
      LINK->t = LINK->t->next;
      continue;
    }
    n = expr(LINK);
    if (n.stringval) {
      fputs(n.UU.sval, stdout);
      Free(n.UU.sval);
    } else
      printf("%s ", numtostr(STR1, n.UU.val));
  }
  if (!semiflag)
    putchar('\n');
}


Local Void cmdinput(LINK)
struct LOC_exec *LINK;
{
  varrec *v;
  string255 s;
  tokenrec *tok, *tok0, *tok1;
  boolean strflag;

  if (LINK->t != NULL && LINK->t->kind == tokstr) {
    fputs(LINK->t->UU.sp, stdout);
    LINK->t = LINK->t->next;
    require(toksemi, LINK);
  } else
    printf("? ");
  tok = LINK->t;
  if (LINK->t == NULL || LINK->t->kind != tokvar)
    snerr();
  strflag = LINK->t->UU.vp->stringvar;
  do {
    if (LINK->t != NULL && LINK->t->kind == tokvar) {
      if (LINK->t->UU.vp->stringvar != strflag)
	snerr();
    }
    LINK->t = LINK->t->next;
  } while (!iseos(LINK));
  LINK->t = tok;
  if (strflag) {
    do {
      gets(s);
      v = findvar(LINK);
      if (*v->UU.U1.sval != NULL)
	Free(*v->UU.U1.sval);
      *v->UU.U1.sval = (Char *)Malloc(256);
      strcpy(*v->UU.U1.sval, s);
      if (!iseos(LINK)) {
	require(tokcomma, LINK);
	printf("?? ");
      }
    } while (!iseos(LINK));
    return;
  }
  gets(s);
  parse(s, &tok);
  tok0 = tok;
  do {
    v = findvar(LINK);
    while (tok == NULL) {
      printf("?? ");
      gets(s);
      disposetokens(&tok0);
      parse(s, &tok);
      tok0 = tok;
    }
    tok1 = LINK->t;
    LINK->t = tok;
    *v->UU.U0.val = realexpr(LINK);
    if (LINK->t != NULL) {
      if (LINK->t->kind == tokcomma)
	LINK->t = LINK->t->next;
      else
	snerr();
    }
    tok = LINK->t;
    LINK->t = tok1;
    if (!iseos(LINK))
      require(tokcomma, LINK);
  } while (!iseos(LINK));
  disposetokens(&tok0);
}


Local Void cmdlet(implied, LINK)
boolean implied;
struct LOC_exec *LINK;
{
  varrec *v;
  Char *old;

  if (implied)
    LINK->t = stmttok;
  v = findvar(LINK);
  require(tokeq, LINK);
  if (!v->stringvar) {
    *v->UU.U0.val = realexpr(LINK);
    return;
  }
  old = *v->UU.U1.sval;
  *v->UU.U1.sval = strexpr(LINK);
  if (old != NULL)
    Free(old);
}


Local Void cmdgoto(LINK)
struct LOC_exec *LINK;
{
  stmtline = mustfindline(intexpr(LINK), LINK);
  LINK->t = NULL;
  LINK->gotoflag = true;
}


Local Void cmdif(LINK)
struct LOC_exec *LINK;
{
  double n;
  long i;

  n = realexpr(LINK);
  require(tokthen, LINK);
  if (n == 0) {
    i = 0;
    do {
      if (LINK->t != NULL) {
	if (LINK->t->kind == tokif)
	  i++;
	if (LINK->t->kind == tokelse)
	  i--;
	LINK->t = LINK->t->next;
      }
    } while (LINK->t != NULL && i >= 0);
  }
  if (LINK->t != NULL && LINK->t->kind == toknum)
    cmdgoto(LINK);
  else
    LINK->elseflag = true;
}


Local Void cmdelse(LINK)
struct LOC_exec *LINK;
{
  LINK->t = NULL;
}


Local boolean skiploop(up, dn, LINK)
short up, dn;
struct LOC_exec *LINK;
{
  boolean Result;
  long i;
  linerec *saveline;

  saveline = stmtline;
  i = 0;
  do {
    while (LINK->t == NULL) {
      if (stmtline == NULL || stmtline->next == NULL) {
	Result = false;
	stmtline = saveline;
	goto _L1;
      }
      stmtline = stmtline->next;
      LINK->t = stmtline->txt;
    }
    if (LINK->t->kind == up)
      i++;
    if (LINK->t->kind == dn)
      i--;
    LINK->t = LINK->t->next;
  } while (i >= 0);
  Result = true;
_L1:
  return Result;
}


Local Void cmdfor(LINK)
struct LOC_exec *LINK;
{
  looprec *l, lr;
  linerec *saveline;
  long i, j;

  lr.UU.U0.vp = findvar(LINK);
  if (lr.UU.U0.vp->stringvar)
    snerr();
  require(tokeq, LINK);
  *lr.UU.U0.vp->UU.U0.val = realexpr(LINK);
  require(tokto, LINK);
  lr.UU.U0.max = realexpr(LINK);
  if (LINK->t != NULL && LINK->t->kind == tokstep) {
    LINK->t = LINK->t->next;
    lr.UU.U0.step = realexpr(LINK);
  } else
    lr.UU.U0.step = 1.0;
  lr.homeline = stmtline;
  lr.hometok = LINK->t;
  lr.kind = forloop;
  lr.next = loopbase;
  if (lr.UU.U0.step >= 0 && *lr.UU.U0.vp->UU.U0.val > lr.UU.U0.max ||
      lr.UU.U0.step <= 0 && *lr.UU.U0.vp->UU.U0.val < lr.UU.U0.max) {
    saveline = stmtline;
    i = 0;
    j = 0;
    do {
      while (LINK->t == NULL) {
	if (stmtline == NULL || stmtline->next == NULL) {
	  stmtline = saveline;
	  errormsg("FOR without NEXT");
	}
	stmtline = stmtline->next;
	LINK->t = stmtline->txt;
      }
      if (LINK->t->kind == tokfor) {
	if (LINK->t->next != NULL && LINK->t->next->kind == tokvar &&
	    LINK->t->next->UU.vp == lr.UU.U0.vp)
	  j++;
	else
	  i++;
      }
      if (LINK->t->kind == toknext) {
	if (LINK->t->next != NULL && LINK->t->next->kind == tokvar &&
	    LINK->t->next->UU.vp == lr.UU.U0.vp)
	  j--;
	else
	  i--;
      }
      LINK->t = LINK->t->next;
    } while (i >= 0 && j >= 0);
    skiptoeos(LINK);
    return;
  }
  l = (looprec *)Malloc(sizeof(looprec));
  *l = lr;
  loopbase = l;
}


Local Void cmdnext(LINK)
struct LOC_exec *LINK;
{
  varrec *v;
  boolean found;
  looprec *l, *WITH;

  if (!iseos(LINK))
    v = findvar(LINK);
  else
    v = NULL;
  do {
    if (loopbase == NULL || loopbase->kind == gosubloop)
      errormsg("NEXT without FOR");
    found = (loopbase->kind == forloop &&
	     (v == NULL || loopbase->UU.U0.vp == v));
    if (!found) {
      l = loopbase->next;
      Free(loopbase);
      loopbase = l;
    }
  } while (!found);
  WITH = loopbase;
  *WITH->UU.U0.vp->UU.U0.val += WITH->UU.U0.step;
  if ((WITH->UU.U0.step < 0 || *WITH->UU.U0.vp->UU.U0.val <= WITH->UU.U0.max) &&
      (WITH->UU.U0.step > 0 || *WITH->UU.U0.vp->UU.U0.val >= WITH->UU.U0.max)) {
    stmtline = WITH->homeline;
    LINK->t = WITH->hometok;
    return;
  }
  l = loopbase->next;
  Free(loopbase);
  loopbase = l;
}


Local Void cmdwhile(LINK)
struct LOC_exec *LINK;
{
  looprec *l;

  l = (looprec *)Malloc(sizeof(looprec));
  l->next = loopbase;
  loopbase = l;
  l->kind = whileloop;
  l->homeline = stmtline;
  l->hometok = LINK->t;
  if (iseos(LINK))
    return;
  if (realexpr(LINK) != 0)
    return;
  if (!skiploop(tokwhile, tokwend, LINK))
    errormsg("WHILE without WEND");
  l = loopbase->next;
  Free(loopbase);
  loopbase = l;
  skiptoeos(LINK);
}


Local Void cmdwend(LINK)
struct LOC_exec *LINK;
{
  tokenrec *tok;
  linerec *tokline;
  looprec *l;
  boolean found;

  do {
    if (loopbase == NULL || loopbase->kind == gosubloop)
      errormsg("WEND without WHILE");
    found = (loopbase->kind == whileloop);
    if (!found) {
      l = loopbase->next;
      Free(loopbase);
      loopbase = l;
    }
  } while (!found);
  if (!iseos(LINK)) {
    if (realexpr(LINK) != 0)
      found = false;
  }
  tok = LINK->t;
  tokline = stmtline;
  if (found) {
    stmtline = loopbase->homeline;
    LINK->t = loopbase->hometok;
    if (!iseos(LINK)) {
      if (realexpr(LINK) == 0)
	found = false;
    }
  }
  if (found)
    return;
  LINK->t = tok;
  stmtline = tokline;
  l = loopbase->next;
  Free(loopbase);
  loopbase = l;
}


Local Void cmdgosub(LINK)
struct LOC_exec *LINK;
{
  looprec *l;

  l = (looprec *)Malloc(sizeof(looprec));
  l->next = loopbase;
  loopbase = l;
  l->kind = gosubloop;
  l->homeline = stmtline;
  l->hometok = LINK->t;
  cmdgoto(LINK);
}


Local Void cmdreturn(LINK)
struct LOC_exec *LINK;
{
  looprec *l;
  boolean found;

  do {
    if (loopbase == NULL)
      errormsg("RETURN without GOSUB");
    found = (loopbase->kind == gosubloop);
    if (!found) {
      l = loopbase->next;
      Free(loopbase);
      loopbase = l;
    }
  } while (!found);
  stmtline = loopbase->homeline;
  LINK->t = loopbase->hometok;
  l = loopbase->next;
  Free(loopbase);
  loopbase = l;
  skiptoeos(LINK);
}


Local Void cmdread(LINK)
struct LOC_exec *LINK;
{
  varrec *v;
  tokenrec *tok;
  boolean found;

  do {
    v = findvar(LINK);
    tok = LINK->t;
    LINK->t = datatok;
    if (dataline == NULL) {
      dataline = linebase;
      LINK->t = dataline->txt;
    }
    if (LINK->t == NULL || LINK->t->kind != tokcomma) {
      do {
	while (LINK->t == NULL) {
	  if (dataline == NULL || dataline->next == NULL)
	    errormsg("Out of Data");
	  dataline = dataline->next;
	  LINK->t = dataline->txt;
	}
	found = (LINK->t->kind == tokdata);
	LINK->t = LINK->t->next;
      } while (!found || iseos(LINK));
    } else
      LINK->t = LINK->t->next;
    if (v->stringvar) {
      if (*v->UU.U1.sval != NULL)
	Free(*v->UU.U1.sval);
      *v->UU.U1.sval = strexpr(LINK);
    } else
      *v->UU.U0.val = realexpr(LINK);
    datatok = LINK->t;
    LINK->t = tok;
    if (!iseos(LINK))
      require(tokcomma, LINK);
  } while (!iseos(LINK));
}


Local Void cmddata(LINK)
struct LOC_exec *LINK;
{
  skiptoeos(LINK);
}


Local Void cmdrestore(LINK)
struct LOC_exec *LINK;
{
  if (iseos(LINK))
    restoredata();
  else {
    dataline = mustfindline(intexpr(LINK), LINK);
    datatok = dataline->txt;
  }
}


Local Void cmdgotoxy(LINK)
struct LOC_exec *LINK;
{
  long i;

  i = intexpr(LINK);
  require(tokcomma, LINK);
}


Local Void cmdon(LINK)
struct LOC_exec *LINK;
{
  long i;
  looprec *l;

  i = intexpr(LINK);
  if (LINK->t != NULL && LINK->t->kind == tokgosub) {
    l = (looprec *)Malloc(sizeof(looprec));
    l->next = loopbase;
    loopbase = l;
    l->kind = gosubloop;
    l->homeline = stmtline;
    l->hometok = LINK->t;
    LINK->t = LINK->t->next;
  } else
    require(tokgoto, LINK);
  if (i < 1) {
    skiptoeos(LINK);
    return;
  }
  while (i > 1 && !iseos(LINK)) {
    require(toknum, LINK);
    if (!iseos(LINK))
      require(tokcomma, LINK);
    i--;
  }
  if (!iseos(LINK))
    cmdgoto(LINK);
}


Local Void cmddim(LINK)
struct LOC_exec *LINK;
{
  long i, j, k;
  varrec *v;
  boolean done;

  do {
    if (LINK->t == NULL || LINK->t->kind != tokvar)
      snerr();
    v = LINK->t->UU.vp;
    LINK->t = LINK->t->next;
    if (v->numdims != 0)
      errormsg("Array already dimensioned");
    j = 1;
    i = 0;
    require(toklp, LINK);
    do {
      k = intexpr(LINK) + 1;
      if (k < 1)
	badsubscr();
      if (i >= maxdims)
	badsubscr();
      i++;
      v->dims[i - 1] = k;
      j *= k;
      done = (LINK->t != NULL && LINK->t->kind == tokrp);
      if (!done)
	require(tokcomma, LINK);
    } while (!done);
    LINK->t = LINK->t->next;
    v->numdims = i;
    if (v->stringvar) {
      v->UU.U1.sarr = (Char **)Malloc(j * 4);
      for (i = 0; i < j; i++)
	v->UU.U1.sarr[i] = NULL;
    } else {
      v->UU.U0.arr = (double *)Malloc(j * 8);
      for (i = 0; i < j; i++)
	v->UU.U0.arr[i] = 0.0;
    }
    if (!iseos(LINK))
      require(tokcomma, LINK);
  } while (!iseos(LINK));
}


Local Void cmdpoke(LINK)
struct LOC_exec *LINK;
{
  union {
    long i;
    Char *c;
  } trick;

/* p2c: dist/examples/basic.p, line 2073:
 * Note: Range checking is OFF [216] */
  trick.i = intexpr(LINK);
  require(tokcomma, LINK);
  *trick.c = (Char)intexpr(LINK);
/* p2c: dist/examples/basic.p, line 2077:
 * Note: Range checking is ON [216] */
}









Static Void exec()
{
  struct LOC_exec V;
  Char *ioerrmsg;
  Char STR1[256];


  TRY(try1);
    do {
      do {
	V.gotoflag = false;
	V.elseflag = false;
	while (stmttok != NULL && stmttok->kind == tokcolon)
	  stmttok = stmttok->next;
	V.t = stmttok;
	if (V.t != NULL) {
	  V.t = V.t->next;
	  switch (stmttok->kind) {

	  case tokrem:
	    /* blank case */
	    break;

	  case toklist:
	    cmdlist(&V);
	    break;

	  case tokrun:
	    cmdrun(&V);
	    break;

	  case toknew:
	    cmdnew(&V);
	    break;

	  case tokload:
	    cmdload(false, stringexpr(STR1, &V), &V);
	    break;

	  case tokmerge:
	    cmdload(true, stringexpr(STR1, &V), &V);
	    break;

	  case toksave:
	    cmdsave(&V);
	    break;

	  case tokbye:
	    cmdbye(&V);
	    break;

	  case tokdel:
	    cmddel(&V);
	    break;

	  case tokrenum:
	    cmdrenum(&V);
	    break;

	  case toklet:
	    cmdlet(false, &V);
	    break;

	  case tokvar:
	    cmdlet(true, &V);
	    break;

	  case tokprint:
	    cmdprint(&V);
	    break;

	  case tokinput:
	    cmdinput(&V);
	    break;

	  case tokgoto:
	    cmdgoto(&V);
	    break;

	  case tokif:
	    cmdif(&V);
	    break;

	  case tokelse:
	    cmdelse(&V);
	    break;

	  case tokend:
	    cmdend(&V);
	    break;

	  case tokstop:
	    P_escapecode = -20;
	    goto _Ltry1;
	    break;

	  case tokfor:
	    cmdfor(&V);
	    break;

	  case toknext:
	    cmdnext(&V);
	    break;

	  case tokwhile:
	    cmdwhile(&V);
	    break;

	  case tokwend:
	    cmdwend(&V);
	    break;

	  case tokgosub:
	    cmdgosub(&V);
	    break;

	  case tokreturn:
	    cmdreturn(&V);
	    break;

	  case tokread:
	    cmdread(&V);
	    break;

	  case tokdata:
	    cmddata(&V);
	    break;

	  case tokrestore:
	    cmdrestore(&V);
	    break;

	  case tokgotoxy:
	    cmdgotoxy(&V);
	    break;

	  case tokon:
	    cmdon(&V);
	    break;

	  case tokdim:
	    cmddim(&V);
	    break;

	  case tokpoke:
	    cmdpoke(&V);
	    break;

	  default:
	    errormsg("Illegal command");
	    break;
	  }
	}
	if (!V.elseflag && !iseos(&V))
	  checkextra(&V);
	stmttok = V.t;
      } while (V.t != NULL);
      if (stmtline != NULL) {
	if (!V.gotoflag)
	  stmtline = stmtline->next;
	if (stmtline != NULL)
	  stmttok = stmtline->txt;
      }
    } while (stmtline != NULL);
  RECOVER2(try1,_Ltry1);
    if (P_escapecode == -20)
      printf("Break");
    else if (P_escapecode != 42) {
      switch (P_escapecode) {

      case -4:
	printf("\007Integer overflow");
	break;

      case -5:
	printf("\007Divide by zero");
	break;

      case -6:
	printf("\007Real math overflow");
	break;

      case -7:
	printf("\007Real math underflow");
	break;

      case -8:
      case -19:
      case -18:
      case -17:
      case -16:
      case -15:
	printf("\007Value range error");
	break;

      case -10:
	ioerrmsg = (Char *)Malloc(256);
	sprintf(ioerrmsg, "I/O Error %d", (int)P_ioresult);
	printf("\007%s", ioerrmsg);
	Free(ioerrmsg);
	break;

      default:
	if (EXCP_LINE != -1)
	  printf("%12ld\n", EXCP_LINE);
	_Escape(P_escapecode);
	break;
      }
    }
    if (stmtline != NULL)
      printf(" in %ld", stmtline->num);
    putchar('\n');
  ENDTRY(try1);
}  /*exec*/





main(argc, argv)
int argc;
Char *argv[];
{  /*main*/
  PASCAL_MAIN(argc, argv);
  inbuf = (Char *)Malloc(256);
  linebase = NULL;
  varbase = NULL;
  loopbase = NULL;
  printf("Chipmunk BASIC 1.0\n\n");
  exitflag = false;
  do {
    TRY(try2);
      do {
	putchar('>');
	gets(inbuf);
	parseinput(&buf);
	if (curline == 0) {
	  stmtline = NULL;
	  stmttok = buf;
	  if (stmttok != NULL)
	    exec();
	  disposetokens(&buf);
	}
      } while (!(exitflag || P_eof(stdin)));
    RECOVER(try2);
      if (P_escapecode != -20)
	printf("Error %d/%d!\n", (int)P_escapecode, (int)P_ioresult);
      else
	putchar('\n');
    ENDTRY(try2);
  } while (!(exitflag || P_eof(stdin)));
  exit(EXIT_SUCCESS);
}







/* End. */
