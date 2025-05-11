
/* this is a sort of standard init frobule for general purpose
   c programs.  You can replace it if you want something that 
   doesn't drag in half the know universe at link time.
*/

#include <stdio.h>

FILE * stdin = NULL;
FILE * stdout = NULL;
FILE * stderr = NULL;

int _main (n_args, args, env)
int n_args;
char ** args;
char * env;		/* is this right? */
{
  int return_code;

  stdin = fdopen(0, "r");
  stdout = fdopen(1, "w");
  stderr = fdopen(2, "w+");

  return_code = main(n_args, args, env);

  fclose(stdin);
  fclose(stdout);
  fclose(stderr);

  return(return_code);
}
