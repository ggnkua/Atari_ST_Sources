/************************************************************************


	system(): Aufruf der Shell aus einem anderen Programm aus

			von Wolfram R”sler 30.5.91

***********************************************************************/
static char _M_ID_[]="@(#)system.c von wr 30.5.91";

#include <osbind.h>

#define TEST 0
#define A_shell_p ((long*)0x4f6)

#ifdef __TURBOC__
#define CDECL cdecl
#endif

int system(st)
char *st;		/* Kommandozeile oder NULL	*/
{
  int CDECL (*Shell)();
  long ssp;

  ssp = Super(0L);
  Shell = (int (*)())*A_shell_p;
  Super(ssp);

  if (st)
  {
    if (Shell)
      return (*Shell)(st);
    else
      return -999;	/* keine Shell da... */
  }
  else	/* Testen, ob Shell installiert */
    return Shell!=0;
}

#if TEST
main()
{
  system("echo Hallo, hier ist die Okami-Shell");
  system("ver -c");
  system("echo \"^nWeiter mit ENTER\"");
  system("read");
}
#endif
