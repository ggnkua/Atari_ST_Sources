/* ---------------------------------------------------------------
   								  Demo zur Exget-Routine
            
  Autor: Helmut Lehmkuhl, Vogelpothsweg 96, 4600 Dortmund 50
  								(c) 1992 MAXON Computer GmbH
--------------------------------------------------------------- */

#include <stdio.h>
#include <ext.h>
#include <tos.h>
#include"exget.h"


main()
{
  char *eing;

  printf("\033EBitte geben Sie einen String ein: ");
  eing = "Dies ist eine Probe";
  exget(&eing, 20, 1, 1);
  printf("\n\nIhre Eingabe war : %s\n", eing);
  getch();
  Crawcin();
  return(0);
}

