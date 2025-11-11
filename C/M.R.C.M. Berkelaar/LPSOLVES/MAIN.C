#include <signal.h>
#include "defines.h"
#include "globals.h"
#include "patchlev.h"

/* declare all global variables here */
int        Rows, Columns, Nonnuls, Sum;
double     Extrad;
double     *Pcol;
nstring	   Probname;
int	   Totnum, Classnr, Linenr;
short	   Bounds, Ranges, Verbose, Debug, Show_results;
unsigned   Cur_eta_size;
double     *Eta_value;
int        *Eta_rownr;

/* Variables which contain the original problem statement */
matrec     *Mat; /* initial problem matrix */
double     *Upbo, *Lowbo; /* bounds on variables */
nstring    *Names; /* contains the names of rows and columns */
int        *Cend; /* Column start indexes in Mat */
double     *Rh; /* Right hand side of original problem */
short      *Relat; /* Relational operators of original problem */

tmp_store_struct tmp_store;
rside      *First_rside;
hashelem   *Hash_tab[HASH_SIZE];

/* Variables which are used during solving */
short      *Chsign; /* tells which row was multiplied by -1 before solving */
int        *Endetacol; /* Column start indexes in Eta */
int        *Rend, *Bas; /* ?? */
double     *Rhs; /* right hand side of Eta ?? */
int        *Colno; /* ?? */
short      *Basis, *Lower; /* ?? */

/* New variables for mixed integer solving */
double     *Solution, *Best_solution; /* to store solutions */
short      *Must_be_int; /* indicates whether variable should be int */
matrec     *Orig_mat; /* To store original version of Mat */
double     *Orig_upbo; /* To store original version of Upbo */
double     *Orig_lowbo; /* To store original version of Lowbo */
double     *Orig_rh; /* To store original version of Rh */
int        Level; /* the recursion level of solve */
intrec     *First_int;
short      Ignore_decl;

short is_int(double value)
{
  double tmp;

  tmp = value - floor(value);
  if(tmp < EPSILON)
    return(1);
  if((tmp > 0.5) && ((1.0 - tmp) < EPSILON))
    return(1);
  return(0);
}

void allocate_globals(void)
{
  Sum = Rows + Columns;
  Cur_eta_size = ETA_START_SIZE;

  CALLOC(Eta_value, Cur_eta_size, double);
  CALLOC(Eta_rownr, Cur_eta_size, int);
  CALLOC(Pcol, Rows + 2, double);
  CALLOC(Cend, Columns + 2, int); /* column boundaries in Mat */
  CALLOC(Endetacol, Sum + 2, int);
  CALLOC(Rend, Rows + 2, int);
  CALLOC(Bas, Rows + 2, int);
  CALLOC(Lowbo, Sum + 2, double);
  CALLOC(Orig_lowbo, Sum + 2, double);
  CALLOC(Upbo, Sum + 2, double);
  CALLOC(Orig_upbo, Sum + 2, double);
  CALLOC(Names, Sum + 2, nstring);
  CALLOC(Rh, Rows + 2, double); /* rhs for Mat */
  CALLOC(Orig_rh, Rows + 2, double); /* rhs for Mat */
  CALLOC(Rhs, Rows + 2, double);
  CALLOC(Colno, Nonnuls + 2, int);
  CALLOC(Mat, Nonnuls + 1, matrec); /* (initial) problem matrix */
  CALLOC(Orig_mat, Nonnuls + 1, matrec); /* (initial) problem matrix */
  CALLOC(Relat, Rows + 2, short);
  CALLOC(Basis, Sum + 2, short);
  CALLOC(Lower, Sum + 2, short);
  CALLOC(Chsign, Rows + 2, short);

  CALLOC(Solution, Sum + 1, double);
  CALLOC(Best_solution, Sum + 1, double);
  CALLOC(Must_be_int, Columns + 1, short);
} /* allocate_globals */


void signal_handler(int sig)
{
  fprintf(stderr, "Caught signal %d, will print intermediate result\n", sig);
  print_solution(stderr, Best_solution);
}


int  main (int argc, char *argv[])
{
  int i, failure;
  double obj_bound = -INFINITE;

  for(i = 1; i < argc; i++)
    {
      if(strcmp(argv[i], "-v") == 0)
	Verbose = TRUE;
      else if(strcmp(argv[i], "-d") == 0)
	Debug = TRUE;
      else if(strcmp(argv[i], "-i") == 0)
	Show_results = TRUE;
      else if(strcmp(argv[i], "-b") == 0)
	obj_bound = atof(argv[++i]);
      else if(strcmp(argv[i], "-h") == 0)
	{
	  printf("Usage of %s version %s:\n", argv[0], PATCHLEVEL);
	  printf("%s [-v] [-d] [-h] [-b <bound>] [-i] \"<\" <input_file>\n",
		 argv[0]);
	  printf("-h:\t\tprints this message\n");
	  printf("-v:\t\tverbose mode, gives flow through the program\n");
	  printf("-d:\t\tdebug mode, all intermediate results are printed,\n\t\tand the branch-and-bound decisions\n");
	  printf("-b <bound>:\tspecify a lower limit for the value of the objective function\n\t\tto the program. If close enough, may speed up the calculations.\n");
	  printf("-i:\t\tprint all intermediate valid solutions. Can give you useful\n\t\tsolutions even if the total run time is too long\n");
	  exit(0);
	}
      else
	fprintf(stderr, "Unrecognized command line option %s, ignored\n",
		argv[i]);
    }
  /* construct basic problem */
  yyparse();
  Rows--; /* @!? MB */
  allocate_globals();
  readinput(Cend, Orig_rh, Relat, Orig_lowbo, Orig_upbo, Orig_mat, Names); 


  /* from now on, catch interrupt signal to print best solution sofar */
  signal(SIGINT, signal_handler);

  /* solve it */
  Best_solution[0] = obj_bound; /* lower bound of objective function */
  failure = solve(Orig_upbo, Orig_lowbo);

  /* print result */
  if(!failure)
    print_solution(stdout, Best_solution);
  else
    fprintf(stderr, "No solution.\n");

  return (0);
} /* main */
