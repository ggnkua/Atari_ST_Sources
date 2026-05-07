extern int pagelen;
extern int glob_flag;
extern int lsym_flag;
extern int sbra_flag;


#define NAMELIST struct _namelist
NAMELIST
{
  char *n_name;
  int n_flag;
};

#define	N_VALUE	0x0001		/* get value for symbol */
#define	N_NONO	0x0002		/* don't allow "NO" prefix */


/*
 *  Handle list of switches
 *
 */
static int (*sw_func)();	/* -> handler function */
static struct namelist *nametab; /* -> keyword table */

static switchlist(nametab, func)
     struct namelist *nametab;
     int (*func)();
{
  int switch1();

  sw_func = func;
  namelist = nametab;
  symlist(switch1);
}


static switch1(name)
     char *name;
{
  register char *s;
  register int i;
  register namelist *nlist;
  VALUE eval;
  int no_flag;			/* 1, got "no" in front of keyword */

  /*
   * convert option name to lowercase
   */
  for (s = name; *s; ++s)
    *s = tolower(*s);

  /*
   * rip off first two letters if they're "NO"
   */
  no_flag = 0;
  if (*name == 'n' &&
      name[1] == 'o')
    {
      name += 2;
      no_flag = 1;
    }

  /* find the symbol */
  nlist = namelist;
  for (i = 0; (s = nlist->n_name) != NULL; ++i)
    if (!strcmp(name, s))
      {
	if (no_flag &&
	    (nlist->n_flag & N_NONO))
	  return error("misuse of 'no'");
	if (nlist->n_flag & N_VALUE)
	  {
	    if (*tok++ != '=')
	      return error("missing '='");
	    if (abs_expr(&eval) != OK)
	      return ERROR;
	  }
	return (*sw_func)(i, no_flag, eval);
      }

  return errors("unknown option: '%s'", name);
}


/*
 *  .opt --- handle assembler options
 *
 */
struct namelist opt_name[] =
{
  {"pagesize", N_VALUE|N_NONO},
  {"autoglob", 0},
  {"short", 0},
  {"local", 0},
  NULL
};


d_opt()
{
  int opt1();

  switchlist(&opt_names[0], opt1);
}


opt1(nameno, no_flag, eval)
     int nameno;
     int no_flag;
     VALUE eval;
{
  switch (nameno)
    {
    case 0:			/* pagesize=N */
      pagelen = eval;
      break;

    case 1:			/* [no]autoglob */
      glob_flag = !no_flag;
      break;

    case 2:			/* [no]short */
      sbra_flag = !no_flag;
      break;

    case 3:			/* [no]locals */
      lsym_flag = !no_flag;
      break;
    }

  return OK;
}


/*
 *  .list / .nlist
 *  Enable/disable listing of various objects
 *
 */
NAMELIST list_list[] =
{
  {"code", 0},			/* source lines */
  {"include", 0},		/* include files */
  {"sym", 0},			/* symbols at end of listing */
  {"mac", 0},			/* macro expansion */
  {"cond", 0},			/* dead conditional code */
  {NULL, 0}
};

static int nlist;

