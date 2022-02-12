/* get chars from rs232 and display them */

#include <stdio.h>
#include <signal.h>
#include "const.h"

#ifdef __STDC__
void cleanup(int foo)
#else
int cleanup()
#endif
{
  fprintf(stderr, "reader stopped\n");
  fflush(stderr);

  exit(0);
}

#ifdef __GNUC__
volatile
#endif
    char suspended = 0;


#ifdef __STDC__
void toggle(int foo)
#else
int toggle()
#endif
{
    suspended ^= (char)1;
}


#define NCHRS 16
char err_buf[BUFSIZ];

main()
{
  char chrs[NCHRS];
  register short i, n;
  register char *p;
  
  signal(SIGINT,  cleanup);
  signal(SIGQUIT, cleanup);
  signal(SIGTERM, cleanup);
  signal(SIGALRM, toggle);	/* writer signals us to toggle suspend */
  
  setbuf(stderr, err_buf);

  fprintf(stderr, "reader started\n");
  fflush(stderr);

  while (TRUE) {
      while(suspended)	/* while we are doing do_shell() */
	  pause();
      
      n = read(0, chrs, (int)NCHRS);
      for(p = chrs, i = n; i ; --i)
	  *p++ &= (char)0177;
      write(1, chrs, n);
  }
}
