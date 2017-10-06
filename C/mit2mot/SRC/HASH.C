#include <stdlib.h>
#include <string.h>
#include "ytab.h"
#include "global.h"

#define HASH_SIZE 1009
#define NUMOF(a) (sizeof(a)/sizeof((a)[0]))

char *ops[] =
{
  "abcdS", "addaS", "addiS", "addqS", "addxS", "addS", "andiS", "andS",
  "aslS", "aslS", "bchgS", "bclrS", "bC", "bsetS", "bsrS", "btstS",
  "chkS", "clrS", "cmpaS", "cmpiS", "cmpmS", "cmpS", "dbC", "dbfS",
  "dbtS", "divsS", "divuS", "eoriS", "eorS", "exgS", "extS", "jmpS",
  "jsrS", "jC", "leaS", "link", "lslS", "lsrS", "moveaS", "movemS",
  "movepS", "moveqS", "moveS", "movaS", "movmS", "movpS", "movqS", "movS",
  "mulsS", "muluS", "nbcdS", "negxS", "negS", "nop", "notS", "oriS", "orS",
  "peaS", "reset", "rolS", "rorS", "roxlS", "roxrS", "rte", "rtr",
  "rts", "sC", "sfS", "sfS", "sbcdS", "stop", "subaS", "subiS",
  "subqS", "subxS", "subS", "swapS", "tasS", "trap", "trapv", "tstS",
  "unlk"
}, *ccodes[] =
{"ra", "eq", "ne", "ge", "gt", "le", "lt", "cc", "hi", "ls", "cs",
 "hs", "lo", "mi", "pl", "vc", "vs"};
Hash directives[] =
{
  {".abort",	"",		D_UNS,		0},
  {".align",	"",		D_UNS,		0},
  {".ascii",	".dc.b",	D_SLIST,	0},
  {".asciz",	".dc.b",	D_SLIST,	0},
  {".byte",	".dc.b",	D_ELIST,	0},
  {".comm",	".comm",	D_COMM,		0},
  {".data",	".data",	D_OPTINT,	0},
  {".desc",	"",		D_UNS,		0},
  {".double",	"",		D_UNS,		0},
  {".even",	".even",	D_NONE,		0},
  {".file",	"",		D_UNS,		0},
  {".line",	"",		D_UNS,		0},
  {".fill",	"",		D_UNS,		0},
  {".float",	"",		D_UNS,		0},
  {".globl",	".globl",	D_IDLIST,	0},
  {".global",	".globl",	D_IDLIST,	0},
  {".int",	".dc.l",	D_ELIST,	0},
  {".lcomm",	".ds.b",	D_LCOMM,	0},
  {".long",	".dc.l",	D_ELIST,	0},
  {".lsym",	"",		D_UNS,		0},
  {".octa",	"",		D_UNS,		0},
  {".org",	".org",		D_ORG,		0},
  {".set",	".equ",		D_COMM,		0},
  {".short",	".dc.w",	D_ELIST,	0},
  {".space",	"",		D_UNS,		0},
  {".text",	".text",	D_OPTINT,	0},
  {".word",	".dc.w",	D_ELIST,	0}
};

static Hash *htable[HASH_SIZE];

static unsigned int 
hash(s)
     register char *s;
{
  register unsigned int t = 0;

  for (; *s; s++)
    t = (t * 33 + (*s)) % HASH_SIZE;
  return t;
}

void 
mkhash(tok, map, type)
     char *tok, *map;
     int type;
{
  Hash *h, *H;
  unsigned int i;
  h = (Hash *)malloc(sizeof (Hash));

  h->htext = strdup(tok);
  h->mapto = strdup(map);
  h->htype = type;
  h->next = 0;
  i = hash(tok);
  if (!htable[i])
    htable[i] = h;
  else {
    for (H = htable[i]; H->next; H = H->next) ;
    H->next = h;
  }
}

static void 
do_S(s)
     char *s;
{
  static char buf1[12], buf2[12];
  char *s1, *s2, *s0 = s;
  int type = OP;

  for (s1 = buf1, s2 = buf2; *s != 'S';)
    *s1++ = *s2++ = *s++;
  if (*s0 == 'j' && !(s0[1] == 'm' || s0[1] == 's'))
    *buf2 = 'b';
  if (*s0 == 'm' && s0[1] == 'o') {
    if (s0[3] != 'e') {
      buf2[3] = 'e';
      s2 = buf2 + 4;
      if (s0[3] != 'S')
	*s2++ = s0[3];
    }
    if (s2[-1] == 'm')
      type = OP_MREG;
  }
  *s1 = *s2 = '\0';
  mkhash(buf1, buf2, type);
  *s2++ = '.';
  *(s1 + 1) = *(s2 + 1) = '\0';
  *s1 = *s2 = 'b';
  mkhash(buf1, buf2, type);
  *s1 = *s2 = 'w';
  mkhash(buf1, buf2, type);
  *s1 = *s2 = 'l';
  mkhash(buf1, buf2, type);
}

static void 
do_C(s)
     char *s;
{
  static char buf[12];
  int i;
  char *s1;

  for (s1 = buf; *s != 'C';)
    *s1++ = *s++;
  *(s1 + 2) = 'S';
  *(s1 + 3) = '\0';
  for (i = 0; i < NUMOF(ccodes); i++) {
    *s1 = ccodes[i][0];
    *(s1 + 1) = ccodes[i][1];
    do_S(buf);
  }
}

static void 
do_ops()
{
  int i;
  char c;

  for (i = 0; i < NUMOF(ops); i++) {
    c = ops[i][strlen(ops[i]) - 1];
    if (c == 'C')
      do_C(ops[i]);
    else if (c == 'S')
      do_S(ops[i]);
    else
      mkhash(ops[i], ops[i], OP);
  }
}

void 
init_hash()
{
  int i;
  char buf[3];

  for (i = 0; i < HASH_SIZE; i++)
    htable[i] = 0;
  for (i = 0; i < NUMOF(directives); i++)
    mkhash(directives[i].htext, directives[i].mapto, directives[i].htype);
  do_ops();
  for (buf[0] = 'd', buf[1] = '0', buf[2] = '\0'; buf[1] <= '7'; buf[1]++)
    mkhash(buf, buf, REG);
  for (buf[0] = 'a', buf[1] = '0'; buf[1] <= '7'; buf[1]++)
    mkhash(buf, buf, REG);
  mkhash("pc", "pc", REG);
  mkhash("sp", "sp", REG);
  mkhash("usp", "usp", REG);
  mkhash("sr", "sr", REG);
  mkhash("ccr", "ccr", REG);
}

int 
lookup(tag, subst)
     char *tag, *subst;
{
  Hash *h;

  for (h = htable[hash(tag)]; h; h = h->next)
    if (!strcmp(tag, h->htext)) {
      strcpy(subst, h->mapto);
      return h->htype;
    }
  return 0;
}

void 
clear_hash()
{
  Hash *h, *q;
  int i;

  for (i = 0; i < HASH_SIZE; i++)
    for (h = htable[i]; h; h = q) {
      q = h->next;
      free(h->htext);
      free(h->mapto);
      free(h);
    }
}
