
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <stddef.h>
#include "global.h"
#include "ztype.h"

#define BASE10	1
#define BASE8	2
#define BASE16	3

#define GRANULARITY 256

extern char *next_c;

static int tok_flags = 0;
static TokenP tok_blocks, next_free_tok, pushback_list;

/*
   alloc_token() -- return space for a Token, either from the free list or
   from freshly malloc()'ed memory
*/
TokenP alloc_token()
{
  register TokenP T;
  register int i;

  if (!next_free_tok) {
    /* allocate several Token's at once for efficiency */
    T = (TokenP) mallok(GRANULARITY * sizeof (Token));

    /* the first pointer is used to chain blocks of Token's together */
    T->next = tok_blocks;
    tok_blocks = T;
    /* string the rest together to form a free list */
    for (i = 1; i < GRANULARITY; i++) {
      T[i].next = T + i + 1;
      T[i].pre_ws = T[i].txt = NULL;
    }
    T[GRANULARITY - 1].next = NULL;
    next_free_tok = T + 1;
  }
  T = next_free_tok;
  next_free_tok = T->next;
  T->hashval = T->val = T->type = T->subtype = T->flags = 0;
  T->next = NULL;
  return T;
}

/* free_token() -- return an allocated Token to the free list */
void free_token(T)
  TokenP T;
{
  T->next = NULL;
  free_tlist(T);
}

/* free_tlist() -- return a list of Token's to the free list */
void free_tlist(T)
  register TokenP T;
{
  register TokenP T1;

  for (T1 = T; T; T = T1) {
    T1 = T->next;
    free(T->pre_ws);
    T->pre_ws = NULL;
    free(T->txt);
    T->txt = NULL;
    T->next = next_free_tok;
    next_free_tok = T;
  }
}

/*
   copy_token() -- return a new Token that is a duplicate of the given token
*/
TokenP copy_token(T1)
  TokenP T1;
{
  TokenP T2 = alloc_token();

  *T2 = *T1;
  T2->pre_ws = strdup(T1->pre_ws);
  T2->txt = strdup(T1->txt);
  T2->next = NULL;
  return T2;
}

/* copy_tlist() -- create a duplicate of a list of Token's */
TokenP copy_tlist(T1)
  TokenP T1;
{
  Token head;
  TokenP T2 = &head;

  for (T2->next = NULL; T1; T1 = T1->next, T2 = T2->next)
    T2->next = copy_token(T1);
  return head.next;
}

/* tok_shutdown() -- free all space allocated for Token's */
void tok_shutdown()
{
  register TokenP T, T1;
  register int i;

  for (T1 = T = tok_blocks; T; T = T1) {
    T1 = T->next;
    for (i = 1; i < GRANULARITY; i++) {
      if (T[i].pre_ws)
	free(T[i].pre_ws);
      if (T[i].txt)
	free(T[i].txt);
    }
    free(T);
  }
}

/*
   push_tlist() -- "un-read" the list of Token's |T|; token() will return all
   of these tokens in order before reading another token from the input file
*/
void push_tlist(T)
  TokenP T;
{
  register TokenP t;

  if (!T)
    return;
  t = T;
  while (t->next)
    t = t->next;
  t->next = pushback_list;
  pushback_list = T;
}

/* mk_eof() -- makes and returns an EOF_ token */
static TokenP mk_eof()
{
  TokenP T = alloc_token();

  T->type = EOF_;
  T->pre_ws = mallok(1);
  *T->pre_ws = '\0';
  T->txt = mallok(1);
  *T->txt = '\0';
  return T;
}

/* mk_eol() -- makes and returns an EOL token */
TokenP mk_eol(s, n)
  char *s;
  int n;
{
  TokenP T = alloc_token();

  T->pre_ws = mallok(n + 1);
  strncpy(T->pre_ws, s, n);
  T->pre_ws[n] = '\0';
  T->txt = mallok(2);
  T->txt[0] = '\n';
  T->txt[1] = '\0';
  T->type == EOL;
  T->subtype = '\n';
  return T;
}

/*
   mk_stopper() -- makes and returns a STOP token.  See expand_tlist() for
   further information.
*/
TokenP mk_stopper()
{
  TokenP T = alloc_token();

  T->type = STOP;
  T->pre_ws = mallok(1);
  *T->pre_ws = '\0';
  T->txt = mallok(1);
  *T->txt = '\0';
  return T;
}

/*
   mk_unmarker() -- makes and returns a special token that informs the
   tokenizer to unmark the macro text associated with token |T|.  See
   expand() for further information.
*/
TokenP mk_unmarker(T)
  TokenP T;
{
  TokenP T1 = copy_token(T);

  T1->type = UNMARK;
  return T1;
}

/* flush_tokenizer() -- discard all Tokens pushed back by push_tlist() */
void flush_tokenizer()
{
  free_tlist(pushback_list);
  pushback_list = NULL;
}

/*
   number() -- copies from |s| into the token |T| a string of characters
   denoting an integer or floating-point constant.  Returns a pointer to the
   first uncopied character.
*/
static char *number(s, T)
  register char *s;
  TokenP T;
{
  int numtype = BASE10, fpflag = 0;
  char *t;

  T->type = NUMBER;
  if (*s == '0') {
    /* check for octal or hexadecimal constant */
    if ((s[1] == 'x' || s[1] == 'X') && isxdigit(s[2])) {
      numtype = BASE16;
      T->flags |= UNS_VAL;
    } else if (is_octal(s[1])) {
      numtype = BASE8;
      T->flags |= UNS_VAL;
    }
  }
  T->val = strtol(s, &t, 0);
  s = t;
  if (numtype != BASE10 || is_isuff(*s)) {

    /*
       if we're not in base 10, or the next characters are integer constant
       suffixes, this can't be a floating-point constant
    */
    while (is_isuff(*s)) {
      if (*s == 'u' || *s == 'U')
	T->flags |= UNS_VAL;
      s++;
    }
    return s;
  }
  /* check to see if the number is actually floating point */
  if (*s == '.') {
    fpflag = 1;
    do
      s++;
    while (isdigit(*s));
  }
  if (*s == 'e' || *s == 'E') {
    register char *t = s;

    t++;
    if (*t == '-' || *t == '+')
      t++;
    if (isdigit(*t)) {
      fpflag = 1;
      do
	t++;
      while (isdigit(*t));
      s = t;
    }
  }
  if (fpflag) {
    T->type = FP_NUM;
    if (is_fsuff(*s))
      s++;
  }
  return s;
}

/*
   char_constant() -- copy from |s| into the token |T| a string of characters
   denoting a character constant.  We do not translate escape sequences at
   this point, though we might need to
*/
static char *char_constant(s, T)
  register char *s;
  TokenP T;
{
  T->type = CHAR_CON;
  for (; *s; s++) {
    if (*s == '\'')
      return s + 1;
    if (*s == '\\')
      s++;
  }
  error("unterminated character constant");
  return s;
}

/*
   string_literal() -- copy from |s| into the token |T| a string of
   characters denoting a string literal.  We do not translate escape
   sequences at this point, though we might need to
*/
static char *string_literal(s, T)
  register char *s;
  TokenP T;
{
  T->type = STR_CON;
  for (; *s; s++) {
    if (*s == '"')
      return s + 1;
    if (*s == '\\')
      s++;
  }
  error("unterminated string literal");
  return s;
}

/*
   include_name() -- copy from |s| into the token |T| a string of characters
   denoting an #include file specifier enclosed in <>. |s| points to the
   character after the '<'.
*/
static char *include_name(s, T)
  register char *s;
  TokenP T;
{
  T->type = INC_NAM;
  for (; *s; s++) {
    if (*s == '>')
      return s + 1;
  }
  error("unterminated include file name");
}

/* set_mode() -- set the tokenizer flags to |m| */
void set_mode(m)
  int m;
{
  tok_flags = m;
}

/*
   change_mode() -- twiddle the tokenizer flags; in particular, set the flags
   specified in |raise| and clear the flags specified in |lower|
*/
void change_mode(raise, lower)
{
  tok_flags |= raise;
  tok_flags &= (~lower);
}

/* get_mode() -- return the current value of the tokenizer flags */
int get_mode()
{
  return tok_flags;
}

/*
   xlate_token() -- determines the type of the next preprocessor token in the
   string pointed to by |s|.  Information about the token found is placed in
   the Token |T|.  Returns a pointer to the first character not in the token
   read.
*/
static char *xlate_token(s, T)
  register char *s;
  TokenP T;
{
  if (is_ctoks(*s)) {
    char *t;

    T->hashval = hash_id(s, &t);
    s = t;
    T->type = ID;
    return t;
  } else if (isdigit(*s))
    return number(s, T);
  else
    switch (*s++) {
    case '.':
      T->subtype = '.';
      if (*s == '.' && s[1] == '.') {
	s += 2;
	T->type = DONT_CARE;
      } else if (isdigit(*s))
	s = number(s - 1, T);
      else
	T->type = DONT_CARE;
      break;
    case '#':
      if (*s == '#') {
	s++;
	T->type = TOK_CAT;
      } else
	T->type = POUND;
      break;
    case '&':
      T->subtype = '&';
      if (*s == '&') {
	s++;
	T->type = L_AND_OP;
      } else if (*s == '=') {
	s++;
	T->type = DONT_CARE;
      } else
	T->type = B_AND_OP;
      break;
    case '|':
      T->subtype = '|';
      if (*s == '|') {
	s++;
	T->type = L_OR_OP;
      } else if (*s == '=') {
	s++;
	T->type = DONT_CARE;
      } else
	T->type = B_OR_OP;
      break;
    case '+':
      T->subtype = '+';
      if (*s == s[-1] || *s == '=') {
	s++;
	T->type = DONT_CARE;
      } else
	T->type = ADD_OP;
      break;
    case '~':
      T->type = UNARY_OP;
      T->subtype = '~';
      break;
    case ',':
      T->type = COMMA;
      T->subtype = ',';
      break;
    case '(':
      T->type = LPAREN;
      T->subtype = '(';
      break;
    case ')':
      T->type = RPAREN;
      T->subtype = ')';
      break;
    case '!':
      T->subtype = '!';
      if (*s == '=')
	T->type = EQ_OP;
      else
	T->type = UNARY_OP;
      break;
    case '=':
      T->subtype = '=';
      if (*s == '=')
	T->type = EQ_OP;
      else
	T->type = DONT_CARE;
      break;
    case '*':
    case '/':
    case '%':
      T->subtype = s[-1];
      if (*s == '=') {
	s++;
	T->type = DONT_CARE;
      } else
	T->type = MUL_OP;
      break;
    case '^':
      T->subtype = '^';
      if (*s == '=') {
	s++;
	T->type = DONT_CARE;
      } else
	T->type = B_XOR_OP;
      break;
    case '-':
      T->subtype = '-';
      if (*s == '-' || *s == '=' || *s == '>') {
	s++;
	T->type = DONT_CARE;
      } else
	T->type = ADD_OP;
      break;
    case '<':
      if (tok_flags & INCLUDE_LINE) {
	s = include_name(s, T);
	break;
      }
      /* else fall through */
    case '>':
      T->subtype = s[-1];
      T->type = REL_OP;
      if (*s == s[-1]) {
	s++;
	T->type = SHIFT_OP;
      }
      if (*s == '=') {
	s++;
	if (T->type == REL_OP)
	  T->subtype = (T->subtype == '<' ? '(' : ')');
	else
	  T->type = DONT_CARE;
      }
      break;
    case '\'':
      s = char_constant(s, T);
      break;
    case '"':
      s = string_literal(s, T);
      break;
    case '[':
    case ']':
    case '{':
    case '}':
    case ';':
    case ':':
    case '?':
      T->type = DONT_CARE;
      break;
    default:
      T->type = UNKNOWN;
    }
  return s;
}

/* print_token() -- write token |T| to the output file */
void print_token(T)
  TokenP T;
{
  if (T->type == STOP)
    bugchk("STOP token in output stream?");
  fputs(T->pre_ws, outf);
  fputs(T->txt, outf);
  if (T->flags & TRAIL_SPC)
    fputc(' ', outf);
}

/*
   merge_tokens() -- Perform token pasting on Token's |T1| and |T2|. Returns
   the resulting token.
*/
TokenP merge_tokens(T1, T2)
  TokenP T1, T2;
{
  TokenP T = alloc_token();
  char *s, *t;

  T->pre_ws = strdup(T1->pre_ws);
  T->txt = mallok(strlen(T1->txt) + strlen(T2->txt) + 1);
  strcpy(T->txt, T1->txt);
  strcat(T->txt, T2->txt);
  t = xlate_token(T->txt, T);
  if (*t != '\0') {
    warning("Invalid token \"%s\" created by concatenation", t);
    T->type = UNKNOWN;
  }
  return T;
}

TokenP _one_token()
{
  register char *s = next_c, *t, *u;
  int n;
  TokenP T = alloc_token();

  t = suck_ws(s, &(T->pre_ws));
  if (!t || !*t) {
    T->txt = mallok(2);
    T->txt[0] = '\n';
    T->txt[1] = '\0';
    T->type = EOL;
    T->subtype = '\n';
    next_c = t;
    return T;
  }
  u = xlate_token(t, T);
  n = u - t;
  if (T->type == UNKNOWN && w_bad_chars)
    error("Unrecognized character 0x%02x='%c'", *t, *t);
  T->txt = mallok(n + 1);
  strncpy(T->txt, t, n);
  T->txt[n] = '\0';
  next_c = u;
  return T;
}

void _tokenize_line()
{
  Token head;
  TokenP T = &head;

  head.next = NULL;
  do {
    T = T->next = _one_token();
  } while (T->type != EOL);
  push_tlist(head.next);
}

TokenP token()
{
  TokenP T;
  register char *s;

  while (pushback_list) {
    T = pushback_list;
    pushback_list = T->next;
    T->next = NULL;
    if (T->type == UNMARK) {
      Macro *M;

      M = lookup(T->txt, T->hashval);
      if (!M)
	bugchk("UNMARK on non-macro token %s", T->txt);
      if (!(M->flags & MARKED))
	bugchk("UNMARK on unmarked macro %s", T->txt);
      M->flags ^= MARKED;
      free_token(T);
      continue;
    } else {
      return T;
    }
  }

  /*
     if we get to here, the pushback list is empty, and we need to read in
     another line
  */
  next_c = s = getline();
  if (!s)
    return mk_eof();
  T = _one_token();
  if (T->type == EOL) {
    return T;
  }
  if (T->type != POUND || get_mode() & SLURP)
    _tokenize_line();
  return T;
}

TokenP exp_token()
{
  TokenP T = token();
  Macro *M;

  if (T->type == ID && !(T->flags & BLUEPAINT) && (M = lookup(T->txt, T->hashval))) {
    expand(T, M);
    return exp_token();
  } else
    return T;
}
