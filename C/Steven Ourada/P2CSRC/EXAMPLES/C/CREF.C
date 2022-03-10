/* Output from p2c, the Pascal-to-C translator */
/* From input file "dist/examples/cref.p" */


#include <p2c/p2c.h>


/*  linesperpage = 139;  */

#define maxnamelen      30


typedef Char str255[256];

#define k_normal        0
#define k_proc          1
#define k_var           2
#define k_const         3
#define k_type          4
#define k_strlit        5
#define k_extproc       6
#define k_kw            7
#define k_prockw        8
#define k_varkw         9
#define k_constkw       10
#define k_typekw        11
#define k_beginkw       12

typedef struct occur {
  struct occur *next;
  long lnum, fnum;
  boolean defn;
} occur;


typedef struct node {
  struct node *left, *right;
  Char name[maxnamelen + 1];
  occur *first;
  short kind;
} node;


Static FILE *f;
Static Char fn[121];
Static long fnum;
Static str255 buf, name;
Static boolean good;
Static long i, j, lnum;
Static node *np, *base;
Static occur *op;
Static short curkind, section;
Static long paren, brace;



Static Void lookup(name, np)
Char *name;
node **np;
{
  node **npp;

  if (strlen(name) > maxnamelen)
    name[maxnamelen] = '\0';
  npp = &base;
  while (*npp != NULL && strcmp((*npp)->name, name)) {
    if (strcmp(name, (*npp)->name) < 0)
      npp = &(*npp)->left;
    else
      npp = &(*npp)->right;
  }
  if (*npp != NULL) {
    *np = *npp;
    return;
  }
  *np = (node *)Malloc(sizeof(node));
  *npp = *np;
  strcpy((*np)->name, name);
  (*np)->first = NULL;
  (*np)->left = NULL;
  (*np)->right = NULL;
  (*np)->kind = k_normal;
}


Static Void kw(name_, kind)
Char *name_;
short kind;
{
  str255 name;
  node *np;

  strcpy(name, name_);
  lookup(name, &np);
  np->kind = kind;
}


Static Void cref(np, kind)
node *np;
short kind;
{
  occur *op;

  op = (occur *)Malloc(sizeof(occur));
  op->next = np->first;
  np->first = op;
  op->lnum = lnum;
  op->fnum = fnum;
  op->defn = (((1L << ((long)kind)) &
	       ((1L << ((long)k_var)) | (1L << ((long)k_type)) |
		(1L << ((long)k_const)) | (1L << ((long)k_proc)))) != 0);
  if (op->defn || kind == k_strlit ||
      kind == k_extproc && np->kind == k_normal)
    np->kind = kind;
}



Static Void traverse(np)
node *np;
{
  occur *op;
  long i;

  if (np == NULL)
    return;
  traverse(np->left);
  if ((long)np->kind < (long)k_kw) {
    switch (np->kind) {

    case k_var:
      fprintf(f, "V:");
      break;

    case k_type:
      fprintf(f, "T:");
      break;

    case k_const:
      fprintf(f, "C:");
      break;

    case k_proc:
      fprintf(f, "P:");
      break;

    case k_strlit:
      fprintf(f, "S:");
      break;

    case k_extproc:
      fprintf(f, "E:");
      break;

    case k_normal:
      fprintf(f, "X:");
      break;
    }
    fputs(np->name, f);
    i = 0;
    op = np->first;
    while (op != NULL) {
      if (i == 0) {
	fprintf(f, "\n   ");
	i = 5;
      }
      fprintf(f, " %ld/%ld", op->lnum, op->fnum);
      if (op->defn)
	putc('*', f);
      i--;
      op = op->next;
    }
    putc('\n', f);
  }
  traverse(np->right);
}



main(argc, argv)
int argc;
Char *argv[];
{
  Char STR1[256];
  Char *TEMP;
  long FORLIM;

  PASCAL_MAIN(argc, argv);
  f = NULL;
  base = NULL;
  fnum = 0;
  kw("procedure", k_prockw);
  kw("function", k_prockw);
  kw("var", k_varkw);
  kw("record", k_varkw);
  kw("type", k_typekw);
  kw("const", k_constkw);
  kw("begin", k_beginkw);
  kw("end", k_kw);
  kw("do", k_kw);
  kw("for", k_kw);
  kw("to", k_kw);
  kw("while", k_kw);
  kw("repeat", k_kw);
  kw("until", k_kw);
  kw("if", k_kw);
  kw("then", k_kw);
  kw("else", k_kw);
  kw("case", k_kw);
  kw("of", k_kw);
  kw("div", k_kw);
  kw("mod", k_kw);
  kw("nil", k_kw);
  kw("not", k_kw);
  kw("and", k_kw);
  kw("or", k_kw);
  kw("with", k_kw);
  kw("array", k_kw);
  kw("integer", k_kw);
  kw("char", k_kw);
  kw("boolean", k_kw);
  kw("true", k_kw);
  kw("false", k_kw);
  printf("\nPascal Cross Reference Utility\n\n");
  do {
    fnum++;
    printf("Name of cross-reference file #%ld? ", fnum);
    fgets(fn, 121, stdin);
    TEMP = strchr(fn, '\n');
    if (TEMP != NULL)
      *TEMP = 0;
    good = true;
    if (*fn != '\0') {
      TRY(try1);
	if (f != NULL)
	  f = freopen(fn, "r", f);
	else
	  f = fopen(fn, "r");
	if (f == NULL) {
	  P_escapecode = -10;
	  P_ioresult = FileNotFound;
	  goto _Ltry1;
	}
      RECOVER2(try1,_Ltry1);
	if (P_escapecode != -10)
	  _Escape(P_escapecode);
	good = false;
	printf("Can't read file!\n");
      ENDTRY(try1);
    } else
      good = false;
    if (good) {
      lnum = 0;
      section = k_normal;
      curkind = k_normal;
      paren = 0;
      while (!P_eof(f)) {
	lnum++;
	fgets(buf, 256, f);
	TEMP = strchr(buf, '\n');
	if (TEMP != NULL)
	  *TEMP = 0;
/* p2c: dist/examples/cref.p, line 228:
 * Note: Null character at end of sprintf control string [148] */
	strcpy(STR1, buf);
	strcpy(buf, STR1);
	i = 1;
	while (buf[i - 1] == ' ')
	  i++;
	do {
	  while (!(buf[i - 1] == '\0' || buf[i - 1] == '_' ||
		   isalnum(buf[i - 1]))) {
	    switch (buf[i - 1]) {

	    case ':':
	    case '=':
	      if (brace == 0)
		curkind = k_normal;
	      break;

	    case ';':
	      if (brace == 0)
		curkind = section;
	      break;

	    case '\'':
	      if (brace == 0) {
		i++;
		j = i;
		while ((buf[i - 1] != '\'' || buf[i] == '\'') &&
		       buf[i - 1] != '\0') {
		  if (buf[i - 1] == '\'')
		    i += 2;
		  else
		    i++;
		}
		if (buf[i - 1] == '\0')
		  i--;
		sprintf(name, "'%.*s'", (int)(i - j), buf + j - 1);
		lookup(name, &np);
		cref(np, k_strlit);
	      }
	      break;

	    case '(':
	      if (brace == 0) {
		if (buf[i] == '*') {
		  brace = 1;
		  i++;
		} else {
		  paren++;
		  curkind = k_normal;
		}
	      }
	      break;

	    case ')':
	      if (brace == 0)
		paren--;
	      break;

	    case '*':
	      if (buf[i] == ')') {
		brace = 0;
		i++;
	      }
	      break;

	    case '{':
	      brace = 1;
	      break;

	    case '}':
	      brace = 0;
	      break;
	    }
	    i++;
	  }
	  if (buf[i - 1] != '\0') {
	    j = i;
	    if (isdigit(buf[i - 1]) && i > 1 && buf[i - 2] == '-')
	      j--;
	    while (buf[i - 1] == '_' || isalnum(buf[i - 1]))
	      i++;
	    if (brace == 0) {
	      sprintf(name, "%.*s", (int)(i - j), buf + j - 1);
	      FORLIM = strlen(name);
	      for (j = 1; j <= FORLIM; j++) {
		if (isupper(buf[j - 1]))
		  buf[j - 1] += 32;
	      }
	      while (buf[i - 1] == ' ')
		i++;
	      lookup(name, &np);
	      switch (np->kind) {

	      case k_varkw:
		if (paren == 0) {
		  section = k_var;
		  curkind = section;
		}
		break;

	      case k_typekw:
		section = k_type;
		curkind = section;
		break;

	      case k_constkw:
		section = k_const;
		curkind = section;
		break;

	      case k_prockw:
		section = k_normal;
		curkind = k_proc;
		break;

	      case k_beginkw:
		section = k_normal;
		curkind = k_normal;
		break;

	      case k_kw:
		/* blank case */
		break;

	      default:
		if (curkind == k_normal && buf[i - 1] == '(')
		  cref(np, k_extproc);
		else
		  cref(np, curkind);
		break;
	      }
	    }
	  }
	} while (buf[i - 1] != '\0');
      }
      if (paren != 0)
	printf("Warning: ending paren count = %ld\n", paren);
      if (f != NULL)
	fclose(f);
      f = NULL;
    }
  } while (*fn != '\0');
  putchar('\n');
  do {
    printf("Output file name: ");
    fgets(fn, 121, stdin);
    TEMP = strchr(fn, '\n');
    if (TEMP != NULL)
      *TEMP = 0;
  } while (*fn == '\0');
  if (f != NULL)
    f = freopen(fn, "w", f);
  else
    f = fopen(fn, "w");
  if (f == NULL)
    _EscIO(FileNotFound);
  traverse(base);
  if (f != NULL)
    fclose(f);
  f = NULL;
  if (f != NULL)
    fclose(f);
  exit(EXIT_SUCCESS);
}







/* End. */
