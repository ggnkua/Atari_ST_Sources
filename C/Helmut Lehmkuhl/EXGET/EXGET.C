/* ---------------------------------------------------------------

            Funktion exget zum einlesen von Strings
                       (C) August 1990 
                       Helmut Lehmkuhl
                       Vogelpothsweg 96
                       4600 Dortmund 50

--------------------------------------------------------------- */

#include <stdio.h>
#include <aes.h>
#include <ext.h>
#include <tos.h>
#include <ctype.h>

#define TRUE 1
#define FALSE 0


void exget(char **wort, int laenge, int dfstr, int schalter);

main()
{
  char *eing;

  printf("\033EBitte geben Sie einen String ein: ");
  eing = "Dies ist eine Probe";
  exget(&eing, 20, 1, 1);
  printf("\n\nIhre Eingabe war : %s\n", eing);
  getch();
  return(0);
}

void exget(char **wort, int laenge,int dfstr, int schalter)
{
  char y, *zwwort;
  int schleife, i, z, ende, insert;

  zwwort = *wort;
  if( dfstr == 1 )
  {
    i = 0;
    while( zwwort[i] != '\0' && i < (laenge - 1) )
    {
      putch(zwwort[i]);
      i++;
    }
    if( i < (laenge - 2) )
      laenge = i + 1;
    ende = i;
  }
  else
  {
    i = 0;
    ende = 0;
  }
  insert = FALSE;
  Cursconf(1, 0);
  Cursconf(3, 0);
  if( schalter == 1 )
  {
    printf("\033j");
    printf("\033Y\067\040     AP: %3d  AL: %3d  ML: %3d",
           i + 1, ende + 1, laenge);
    printf("\033k");
  }
  while ( (z = evnt_keybd()) != 7181 )
  {
    switch (z)
    {
      case 3592 :  /* Backspace gedr…kt */
        if( i > 0 )
        {
          if( i == ende )
          {
            printf("\b \b");
            i--;
            ende--;
            if ( i < 0 )
              i = 0;
          }
          else  /* Fall f〉 Backspace in der Mitte der Eingabe */
          {
            printf("\b \b");
            i--;
            for( schleife = i; schleife < ( ende - 1 ); schleife++)
            {
              zwwort[schleife] = zwwort[schleife+1];
              printf("%c", zwwort[schleife]);
            }
            printf(" \b");
            ende--;
            schleife = ende;
            while( schleife != i )
            {
              printf("\b");
              schleife--;
            }  /* while( schleife != i ) */
          }  /* if( i == ende ) */
        }  /* if( i > 0 ) */
        else
          printf("\a");
        break;
      case 21375 : /* Delete gedr…kt */
        if( i != ende ) /* Nur der Fall f〉 Delete in der Mitte */
        {
          printf(" \b");
          for( schleife = i; schleife < ( ende - 1 ); schleife++)
          {
            zwwort[schleife] = zwwort[schleife+1];
            printf("%c", zwwort[schleife]);
          }
          printf(" \b");
          ende--;
          schleife = ende;
          while( schleife != i )
          {
            printf("\b");
            schleife--;
          }
        } /* if( i != ende ) */
        else
          printf("\a");
        break;
      case 20992 : /* INSERT gedr…kt */
        if( insert == TRUE )
        {
          insert = FALSE;
          Cursconf(3, 0);
        }
        else
        {
          insert = TRUE;
          Cursconf(2, 0);
        }
        break;
      case 19200 : /* Pfeil links gedr…kt */
        if( i > 0 )
        {
          printf("\b");
          i--;
        }
        else
          printf("\a");
        break;
      case 19712 : /* Pfeil rechts gedr…kt */
        if( i < ende )
        {
          printf("%c", zwwort[i]);
          i++;
        }
        else
          printf("\a");
        break;
      case 18176 : /* CLR/HOME gedr…kt */
      case 19252 : /* Shift Pfeil links gedr…kt */
        /* An den Anfang des Eingabestrings springen */
        while( i > 0 )
        {
          printf("\b");
          i--;
        }
        break;
      case 18231 : /* Shift CLR/HOME gedr…kt */
      case 19766 : /* Shift Pfeil rechts gedr…kt */
        /* An das Ende des Eingabestrings springen */
        while( i < ende )
        {
          printf("%c", zwwort[i]);
          i++;
        }
        break;
      case 283 : /* ESCAPE gedr…kt */
        /* Eingabe von neuem beginnen */
        while( i < ende )
        {
          printf(" ");
          i++;
        }
        while( i > 0 )
        {
          printf("\b \b");
          i--;
        }
        ende = 0;
        break;
      default   :
        y = (char) z;
        if( isprint(y) )
        {
          if( ende < (laenge - 1) || (insert == FALSE && i != ende) )
          {
            if( insert == FALSE )
            {
              putch(y);
              zwwort[i] = y;
              if( i == ende )
                ende++;
              i++;
            }
            else /* Buchstaben in Mitte einf“en */
            {
              putch(y);
              for( schleife = ende; schleife > i; schleife--)
                zwwort[schleife] = zwwort[schleife-1];
              zwwort[i] = y;
              i++;
              ende++;
              for( schleife = i; schleife < ende; schleife++)
                printf("%c", zwwort[schleife]);
              schleife = ende;
              while( schleife != i )
              {
                printf("\b");
                schleife--;
              }
            }  /* if( insert == FALSE ) */
          }  /* if( ende < (laenge - 1) ) */
          else
            printf("\a");
        }  /* if( isprint(y) ) */
    }  /* switch (z) */
    if( schalter == 1 )
    {
      printf("\033j");
      printf("\033Y\067\040     AP: %3d  AL: %3d  ML: %3d",
             i + 1, ende + 1, laenge);
      printf("\033k");
    }
  }  /* while( (z = evnt_keybd()) != 7181 ) */
  zwwort[ende] = '\0';
  *wort = zwwort;
  if( schalter == 1 )
    printf("\033j\033Y\067\040                               \033k");
  Cursconf(0, 0);
  return;
}