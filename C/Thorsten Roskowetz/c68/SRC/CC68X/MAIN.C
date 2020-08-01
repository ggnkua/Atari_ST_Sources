#include <stdio.h>
#include <string.h>
#include <support.h>
#include <unistd.h>
#include "global.h"
#include "patchlev.h"

#define CPP		"cpp"
#define CC1		"c68"
#define AS		"as68"
#define LNK		"ld"
#define RT_STARTUP	"%scrt0.o"
#define	N_LIB_FORMS	2
#define INC_ENV_VAR	"C68INC"
#define LIB_ENV_VAR	"C68LIB"
#define DEFAULT_INC	"c:\\c68\\include"
#define DEFAULT_LIB	"c:\\c68\\lib"
#define DEFAULT_EXEC	"a.out"

#define DO_PREPROCESS	0
#define DO_COMPILE	1
#define DO_ASSEMBLE	2
#define DO_LINK		3
#define UP_TO_LINK	(last_stage == DO_LINK ? DO_ASSEMBLE : last_stage)

#define LF_STARTUP	1
#define LF_MATHLIB	2
#define LF_STDCLIB	3

#define RM_INTERMED	1
#define RM_FINAL	2

#define DEFAULT_WARN_LVL	3

#ifdef __STDC__
static void usage(void);
static void rename_stage(const char *);
static void long_option(const char *);
static char *lib_name_opts(const char *, int);
static void add_lib(const char *);
static void add_lib_file(int);
static void add_input_file(const char *, int);
static void remove_temp_files(int);
static void panic_remove_temps(void);
static const char *derive_dest(const char *, int);
static void process_file(const char *, int);
#else
static void usage();
static void rename_stage();
static void long_option();
static char *lib_name_opts();
static void add_lib();
static void add_lib_file();
static void add_input_file();
static void remove_temp_files();
static void panic_remove_temps();
static char *derive_dest();
static void process_file();
#endif

static Arguments cpp_args = {0, 0, 0},
		 cc1_args = {0, 0, 0},
		 as_args = {0, 0, 0},
		 lnk_args = {0, 0, 0},
		 c_files = {0, 0, 0},
		 i_files = {0, 0, 0},
		 s_files = {0, 0, 0},
		 o_files = {0, 0, 0},
		 new_env = {0, 0, 0},
		 temp_files = {0, 0, 0};
static Arguments *passes[] = {&cpp_args, &cc1_args, &as_args, &lnk_args};
static Arguments *pass_inputs[] = {&c_files, &i_files, &s_files, &o_files};

static char const *cpp_init_args[] = {CPP, "-S", "-D__TOS__", "-D__C68__", NULL},
		  *cc1_init_args[] = {CC1, NULL},
		  *as_init_args[] = {AS, NULL},
		  *lnk_init_args[] = {LNK, NULL},
		  *cpp_ansi_args[] = {"-ansi", "-T", NULL},
#if 0
		  *fplib_args[] = {"-u", "__doprnt", "-u", "__scanf", NULL},
#endif
		  *cpp_asm_args[] = {"-P0", "-Wno-bad-chars",
				     "-Wno-bad-concat-tokens", NULL};
#define N_CPP_ASM_ARGS	3

char *argv0;
int action = 1,
    verbose = 0;

static const char *INCLUDE, *LIB, *TMPDIR, *outfnam = 0;
static int last_stage = DO_LINK,
	   fp_lib = 0,
	   debug = 0,
	   keep = 0,
	   warn_level = DEFAULT_WARN_LVL,
	   long_int = 0,
	   profile = 0,
	   ansi = 1;

static void usage()
{
  fprintf(stderr, "usage: %s {args}\n", argv0);
  exit(0);
}

static void long_option(s)
  const char *s;
{
  if (strcmp(s, "-mshort") == 0)
    long_int = 0;
  else if (strcmp(s, "-mlong") == 0)
    long_int = 1;
  else if (strcmp(s, "-ansi") == 0)
    ansi = 1;
  else if (strcmp(s, "-trad") == 0)
    ansi = 0;
  else {
    error("unrecognized option '%s'", s);
    usage();
  }
}

static void rename_stage(param)
  const char *param;
{
  static char errmsg[] = "Invalid -N argument %s";

  if (param[1] != '=') {
    error(errmsg, param);
    return;
  }
  switch (*param) {
    case 'P':
      cpp_args._args[0] = param + 2;
      return;
    case 'C':
      cc1_args._args[0] = param + 2;
      return;
    case 'A':
      as_args._args[0] = param + 2;
      return;
    case 'L':
      lnk_args._args[0] = param + 2;
      return;
    default:
      error(errmsg, param);
  }
}

static char *lib_name_opts(lnam, which)
  const char *lnam;
  int which;
{
  static char buf[128];

  switch (which) {
    case 1:
      sprintf(buf, "lib%s%s%s.a", lnam, (profile ? "p" : ""),
	      (long_int ? "32" : ""));
      return buf;
    case 2:
      sprintf(buf, "%s.%c%s", lnam, (profile ? 'p' : 'l'),
	      (long_int ? "32" : profile ? "lb" : "ib"));
      return buf;
   default:
      bugchk("lib_name_opts(%d)?", which);
      return 0;
  }
}

static void add_lib(lnam)
  const char *lnam;
{
  char *s;
  int i;

  for (i = 1; i <= N_LIB_FORMS; i++) {
    s = lib_name_opts(lnam, i);
    s = findfile(s, LIB, (char * const *)0);
    if (s)
      break;
  }
  if (s)
    add_arg(&o_files, strdup(s));
  else
    error("no corresponding library found for parameter -l%s", lnam);
}

static void add_lib_file(which)
  int which;
{
  switch (which) {
    case LF_STARTUP:
      {
	char *s = mallok(strlen(RT_STARTUP) + 1);

	sprintf(s, RT_STARTUP, (profile ? "p" : ""));
	add_arg(&o_files, s);
      }
      break;
    case LF_MATHLIB:
      add_lib("m");
      break;
    case LF_STDCLIB:
      add_lib("c");
      break;
    default:
      bugchk("add_lib_file(%d)?", which);
  }
}

static void add_input_file(fnam, stage)
  const char *fnam;
  int stage;
{
  add_arg(pass_inputs[stage], fnam);
  if (last_stage == DO_LINK && stage <= DO_ASSEMBLE)
    add_arg(&o_files, derive_dest(fnam, DO_ASSEMBLE));
}

static void remove_temp_files(state)
  int state;
{
  char const **p;

  if (temp_files.nargs == 0 || args(&temp_files) == 0 || keep)
    return;

  temp_files.nargs = 0;
  for (p = args(&temp_files); *p; p++) {
    if ((*p)[strlen(*p) - 1] == 'o' && state == RM_INTERMED) {
      args(&temp_files)[temp_files.nargs++] = *p;
    } else {
      if (verbose || !action)
	printf("rm -f %s\n", *p);
      if (action)
	unlink(*p);
      free(*p);
    }
  }
  args(&temp_files)[temp_files.nargs] = 0;
}

static void panic_remove_temps()
{
  action = 1;
  verbose = 0;
  remove_temp_files(RM_FINAL);
}

static const char *derive_dest(fnam, stage)
  const char *fnam;
  int stage;
{
  static char exts[] = {'i', 's', 'o'};
  char *s = mallok(2 + strlen(fnam) + strlen(TMPDIR));
  const char *t = strrchr(fnam, '.');

  if (!t)
    bugchk("in derive_dest():  \"%s\" has no extension", fnam);

  if (stage == last_stage && outfnam)
    return outfnam;

  sprintf(s, "%.*s.%c", (int)(t - fnam), fnam, exts[stage]);
  if (stage < last_stage && access(s, F_OK) < 0) {
    register const char **p;

    sprintf(s, "%s\\%.*s.%c", TMPDIR, (int)(t - fnam), fnam, exts[stage]);
    /* Temporary .o files might already be on the list; check to avoid
       duplicates. */
    for (p = args(&temp_files); p && *p; p++) {
      if (strcmp(*p, s) == 0)
	break;
    }
    if (!p || !*p)
      add_arg(&temp_files, s);
  }
  return s;
}

static void process_file(fnam, first_stage)
  const char *fnam;
  int first_stage;
{
  int i, cpp_asm_flag = 0;
  const char *inf = fnam;
  const char *outf;

  if (first_stage == DO_PREPROCESS) {
    const char *t = strrchr(fnam, '.');

    if (!t)
      bugchk("in process_file():  \"%s\" has no extension", fnam);
    cpp_asm_flag = ((strcmp(t + 1, "cpp") == 0) ||
		    (strcmp(t + 1, "spp") == 0));
    if (cpp_asm_flag) {
      add_args(&cpp_args, cpp_asm_args);
      if (last_stage < DO_COMPILE)
	error("-P/-E flags incompatible with input file %s", fnam);
    }
  }

  for (i = first_stage; i <= UP_TO_LINK; i++) {
    outf = derive_dest(fnam, i + (cpp_asm_flag && i == DO_PREPROCESS));
    add_arg(passes[i], inf);
    add_arg(passes[i], outf);
    run(passes[i], args(&new_env));
    remove_args(passes[i], 2);
    inf = outf;
    if (cpp_asm_flag && i == DO_PREPROCESS)
      i++;
  }
  if (cpp_asm_flag)
    remove_args(&cpp_args, N_CPP_ASM_ARGS);
#if 0
  if (last_stage == DO_LINK)
    add_arg(&o_files, outf);
#endif
  remove_temp_files(RM_INTERMED);
}

int main(argc, argv, envp)
  int argc;
  char **argv;
  char **envp;
{
  int i;
  int got_file_args = 0;
  char *s;
  const char **p;

  if (argc == 1)
    usage();
  argv0 = argv[0];
  atexit(panic_remove_temps);

  add_args(&cpp_args, cpp_init_args);
  add_args(&cc1_args, cc1_init_args);
  add_args(&as_args, as_init_args);
  add_args(&lnk_args, lnk_init_args);
  add_lib_file(LF_STARTUP);

  if (!(INCLUDE = getenv(INC_ENV_VAR)))
    INCLUDE = DEFAULT_INC;
  if (!(LIB = getenv(LIB_ENV_VAR)))
    LIB = DEFAULT_LIB;
  s = mallok(9 + strlen(INCLUDE));
  sprintf(s, "INCLUDE=%s", INCLUDE);
  add_arg(&new_env, s);
  s = mallok(5 + strlen(LIB));
  sprintf(s, "LIB=%s", LIB);
  add_arg(&new_env, s);
  add_args(&new_env, (char const * const *)envp);

  TMPDIR = getenv("TEMP");
  if (!TMPDIR)
    TMPDIR = getenv("TMP");
  if (!TMPDIR)
    TMPDIR = getenv("TMPDIR");
  if (!TMPDIR)
    TMPDIR = ".";
#ifdef __MINT__
  /* if temp dir is in Unix format, change it to DOS format so that jas
     doesn't get confused */
  if (strchr(TMPDIR, '/') != 0) {
    static char dos_tmpdir[128];

    _unx2dos(TMPDIR, dos_tmpdir);
    TMPDIR = dos_tmpdir;
  }
#endif

  for (i = 1; i < argc; i++) {
    if (argv[i][0] == '-') {
      switch(argv[i][1]) {
	case 'E':
	  outfnam = "-";
	  /* and fall through */
	case 'P':
	  last_stage = DO_PREPROCESS;
	  break;
	case 'S':
	  last_stage = DO_COMPILE;
	  break;
	case 'c':
	  last_stage = DO_ASSEMBLE;
	  break;
	case 'D':
	case 'U':
	case 'I':
	  add_arg(&cpp_args, argv[i]);
	  break;
	case 'O':
	  add_arg(&cc1_args, argv[i]);
	  break;
	case 'L':
	  add_arg(&lnk_args, argv[i]);
	  break;
	case 'N':
	  rename_stage(argv[i] + 2);
	  break;
	case 'o':
	  outfnam = argv[++i];
	  break;
	case 'l':
	  add_lib(argv[i] + 2);
	  break;
	case 'f':
	  fp_lib = 1;
	  break;
	case 'g':
	  debug = 1;
	  break;
	case 'n':
	  action = 0;
	  break;
	case 'v':
	  verbose++;
	  break;
	case 't':
	  keep = 1;
	  break;
	case 'p':
	  profile = 1;
	  break;
	case 'W':
	  {
	    char c = argv[i][2];

	    if (!c || c < '0' || c > '7' || argv[i][3]) {
	      error("invalid warning level '%s'", argv[i] + 2);
	      warn_level = DEFAULT_WARN_LVL;
	    } else
	      warn_level = c - '0';
	  }
	  break;
	case 'V':
	  fprintf(stderr, "cc68x v%d.%d.%d\n",
		  MAJOR_VERSION, MINOR_VERSION, PATCH_LEVEL);
	  break;
	default:
	  long_option(argv[i]);
      }
    } else if (argv[i][0] == '+') {
      switch (argv[i][1]) {
	case 'P':
	  add_arg(&cpp_args, argv[i] + 2);
	  break;
	case 'C':
	  add_arg(&cc1_args, argv[i] + 2);
	  break;
	case 'A':
	  add_arg(&as_args, argv[i] + 2);
	  break;
	case 'L':
	  add_arg(&lnk_args, argv[i] + 2);
	  break;
	default:
	  error("unrecognized option '%s'", argv[i]);
	  usage();
      }
    } else {
      got_file_args = 1;
      s = strrchr(argv[i], '.');
      if (!s)
	add_input_file(argv[i], DO_LINK);
      else if (s[1] == 'c' && s[2] == '\0')
	add_input_file(argv[i], DO_PREPROCESS);
      else if ((strcmp(s + 1, "cpp") == 0) ||
	       (strcmp(s + 1, "spp") == 0))
	add_input_file(argv[i], DO_PREPROCESS);
      else if (s[1] == 'i' && s[2] == '\0')
	add_input_file(argv[i], DO_COMPILE);
      else if (s[1] == 's' && s[2] == '\0')
	add_input_file(argv[i], DO_ASSEMBLE);
      else
	add_input_file(argv[i], DO_LINK);
    }
  }

  if (got_file_args == 0)
    fatal("no files specified");

#if 0
  if (fp_lib)
    add_args(&lnk_args, fplib_args);
#endif
  if (debug) {
    add_arg(&cc1_args, "-g");
    add_arg(&as_args, "-L1");
    add_arg(&lnk_args, "-t");
  }
  if (verbose > 1) {
    add_arg(&cpp_args, "-V");
    add_arg(&cc1_args, "-v");
    add_arg(&as_args, "-v");
    add_arg(&lnk_args, "-v");
  }
  if (long_int) {
    add_arg(&cc1_args, "-noshort");
  } else {
    add_arg(&cpp_args, "-D__MSHORT__");
  }
  if (ansi)
    add_args(&cpp_args, cpp_ansi_args);
  else
    add_arg(&cc1_args, "-trad");
  if (warn_level != DEFAULT_WARN_LVL) {
    static char warn_opt[] = "-warn=3";

    warn_opt[6] = (char)(warn_level + '0');
    add_arg(&cc1_args, warn_opt);
  }

  for (i = DO_PREPROCESS; i <= UP_TO_LINK; i++) {
    for (p = args(pass_inputs[i]); p && *p; p++) {
      process_file(*p, i);
    }
  }
  if (last_stage == DO_LINK) {
    if (fp_lib)
      add_lib_file(LF_MATHLIB);
    add_lib_file(LF_STDCLIB);
    add_arg(&lnk_args, "-o");
    add_arg(&lnk_args, (outfnam ? outfnam : DEFAULT_EXEC));
    add_args(&lnk_args, args(&o_files));
    run(&lnk_args, args(&new_env));
  }

  remove_temp_files(RM_FINAL);
  return 0;
}
