#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <signal.h>
#include <time.h>
#include "global.h"
#include "ztype.h"
#include "patchlev.h"

FILE *outf = stdout;
FILE *inf = NULL;
char *argv0;
char **I_list;
char date_string[12], time_string[9];
int nerrs;

int sl_style = SL_NORMAL, keep_comments = 0, do_trigraphs = 0, ansi = 0, w_bad_chars = 1, w_nest_cmts = 0, f_cpp_cmts = 0;

static void usage()
{
  fprintf(stderr, "usage: %s [-Dname[=value]...] [-Uname] "
	  "[ infile [ outfile ] ]\n", argv0
  );
  exit(1);
}

static void dammit(sig)
  int sig;
{
  fatal("received signal %d", sig);
}

static void setup_signals()
{
  signal(SIGHUP, dammit);
  signal(SIGINT, dammit);
  signal(SIGQUIT, dammit);
  signal(SIGILL, dammit);
  signal(SIGTRAP, dammit);
  signal(SIGABRT, dammit);
  signal(SIGEMT, dammit);
  signal(SIGFPE, dammit);
  signal(SIGBUS, dammit);
  signal(SIGSEGV, dammit);
  signal(SIGSYS, dammit);
  signal(SIGPIPE, dammit);
  signal(SIGALRM, dammit);
  signal(SIGTERM, dammit);
}

/* add_include() -- adds |path| to the list of include directories */
static void add_include(path)
  char *path;
{
  static char **cur_I = NULL;
  static int n_I;
  ptrdiff_t dp;

  if (!cur_I)
    cur_I = I_list = (char **)mallok((n_I = 3) * sizeof (char *));

  if (cur_I - I_list == n_I) {
    dp = cur_I - I_list;
    I_list = reallok(I_list, (n_I *= 2) * sizeof (char *));

    cur_I = I_list + dp;
  }
  *cur_I++ = path;
}

/* long_option() -- parses long option |s| */
static void long_option(s)
  char *s;
{
  int yesno = 1;
  char *t;

  if (*s == 'W' || *s == 'f') {
    if (s[1] == 'n' && s[2] == 'o' && s[3] == '-') {
      yesno = 0;
      t += 4;
    } else
      t = s + 1;
    if (*s == 'W') {		/* warnings */
      if (streq(t, "bad-chars"))
	w_bad_chars = yesno;
      else if (streq(t, "nested-comments"))
	w_nest_cmts = yesno;
      else {
	error("unknown -W option:  %s", t);
	usage();
      }
    } else {			/* actions */
      if (streq(t, "c++-comments"))
	f_cpp_cmts = yesno;
      else {
	error("unknown -f option:  %s", t);
	usage();
      }
    }
  } else if (streq(s, "ansi")) {
    ansi = 1;
    do_trigraphs ^= 1;
  } else {
    error("unrecognized option -%s", s);
    usage();
  }
}

/*
   opt_define() -- handle -Dfred.  |s| points to the beginning of the token
   to #define.
*/
static void opt_define(s)
  char *s;
{
  Macro *M, *M1;
  char *t;
  unsigned int hv;
  int hmm = 0;

  hv = hash_id(s, &t);
  if (*t && *t != '=') {
    error("malformed -D option \"%s\"", s);
    return;
  }
  if (*t)
    *t++ = '\0';
  else
    t = "1";
  M1 = (Macro *)mallok(sizeof (Macro));

  M1->nargs = M1->flags = 0;
  M1->m_text = tokenize_string(t);
  if (M = lookup(s, hv)) {

    /*
       guard against re-#definition of magic tokens or previously -U'd tokens
    */
    if (M->flags & (UNDEF | MAGIC))
      hmm = 1;
    if (hmm || !macro_eq(M1, M)) {
      if (!hmm)
	error("non-identical redefinition of \"%s\"", s);
    }
    free_tlist(M1->m_text);
    free(M1);
    return;
  }
  hash_add(s, hv, M1);
}

/*
   opt_undefine() -- handle -Ufred.  |s| points to the beginning of the token
   to #undef.
*/
static void opt_undefine(s)
  char *s;
{
  Token T;
  Macro *M;
  int was_there = 0;
  unsigned int hv;

  hv = hash_id(s, NULL);
  if (M = lookup(s, hv)) {
    if (M->flags & MAGIC)
      return;
    if (M->m_text)
      free_tlist(M->m_text);
    was_there = 1;
  } else {
    M = (Macro *)mallok(sizeof (Macro));

    M->nargs = M->flags = 0;
  }
  M->m_text = NULL;
  M->flags |= UNDEF;
  if (!was_there)
    hash_add(s, hv, M);
}

/* main() -- guess... */
main(argc, argv)
  int argc;
  char **argv;
{
  int i;
  char *infnam;
  int num_Is = 3;
  char **cur_I, *incdir;
  time_t t;
  struct tm *T;

  argv0 = argv[0];
  Z_type_init();
  hash_setup();
  cond_setup();
  setup_signals();
  time(&t);
  T = localtime(&t);
  strftime(date_string, 12, "%b %d %Y", T);
  strftime(time_string, 9, "%H:%M:%S", T);
  add_include(NULL);
  for (i = 1; i < argc && *argv[i] == '-' && argv[i][1] != '\0'; i++) {
    switch (argv[i][1]) {
    case 'P':
      switch (argv[i][2]) {
      case '0':
      case '\0':
	sl_style = SL_NONE;
	break;
      case '1':
	sl_style = SL_NORMAL;
	break;
      case '2':
	sl_style = SL_LINE;
	break;
      default:
	error("bad argument '%c' to -P option", argv[i][2]);
      }
      break;
    case 'C':
      keep_comments = 1;
      break;
    case 'T':
      do_trigraphs ^= 1;
      break;
    case 'I':
      add_include(copy_filename(argv[i] + 2, 0), 0);
      break;
    case 'D':
      opt_define(argv[i] + 2);
      break;
    case 'U':
      opt_undefine(argv[i] + 2);
      break;
    case 'V':
      fprintf(stderr, "CPP -- C preprocessor v%d.%d.%d\n"
	      "(c) 1993 Hacker Ltd., all rights reserved\n",
	      CPP_VERSION, CPP_RELEASE, CPP_PATCHLEVEL);
      break;
    default:
      long_option(argv[i] + 1);
    }
  }
  hash_clean_undef();
  if (incdir = getenv("INCLUDE")) {
    char *s = incdir;
    size_t len;

    while (*s) {
      len = strcspn(s, ";,");
      add_include(copy_filename(s, len));
      s += len;
      if (*s)
	s++;
    }
  }
  add_include(NULL);
  if (argc - i > 2) {
    error("too many arguments");
    usage();
  }
  if (i < argc && !streq(argv[i], "-"))
    infnam = copy_filename(argv[i], 0);
  else
    infnam = STDIN_NAME;
  if (i + 1 < argc && (streq(argv[i + 1], "-") || !(outf = xfopen(argv[i + 1], "w"))))
    fatal("%s: cannot open output file %s", argv0, argv[i + 1]);
  process_file(infnam);
  free(infnam);
  for (cur_I = I_list + 1; *cur_I; cur_I++)
    if (*cur_I)
      free(*cur_I);
  free(I_list);
  fclose(outf);
  hash_free();
  cond_shutdown();
  tok_shutdown();
  if (nerrs > 0) {
    fprintf(stderr, "%d errors\n", nerrs);
    return 1;
  }
  return 0;
}
