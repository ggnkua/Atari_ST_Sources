/************************************************************************


	system(): Aufruf der Shell aus einem anderen Programm aus

			von Wolfram R”sler 30.5.91

***********************************************************************/
static char _M_ID_[]="@(#)system.c von wr 30.5.91";

#include <osbind.h>

#define TEST 0
#define A_shell_p ((long*)0x4f6)

int system(st)
char st[];
{
  int (*Shell)();
  long ssp;

  ssp = Super(0L);
  Shell = (int (*)())*A_shell_p;
  Super(ssp);

  if (Shell)
    return (*Shell)(st);
  else
    return -999;	/* keine Shell da... */
}

#if TEST
main()
{
  system("echo Hallo, hier ist die $LOGNAME");
  system("ver -c");
  system("echo \"^nWeiter mit ENTER\"");
  system("read");
}
#endif
