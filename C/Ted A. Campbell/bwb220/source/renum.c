/*-------------------------------------------------------------------*/
/* renum.c -- Renumbers a BASIC program in an ASCII file.            */
/* Originally written in HP 2000 BASIC by David Lance Robinson, 1977 */
/* Adapted to MS BASIC and translated to C 4/1995 by Jon B. Volkoff  */
/* (eidetics@cerf.net)                                               */
/*-------------------------------------------------------------------*/

#include <stdio.h>

int instr();
char *midstr1();
char *midstr2();
void binary_search(void);

int f2, l2, n, x;
int sidx[1500][2];
char rstr[255];

main(argc, argv)
   int argc;
   char *argv[];
{
   int f, d, s, p, s1, t, l, g;
   int c, f1, c1, i, f8, r, l1, l3;
   int v1, f6, l6, b, f9, x9, b1, p8, p9, a, d9;
   char pstr[255], sstr[255], f9str[255], s9str[255], tempstr[255];
   FILE *fdin, *fdout;
   int skip, bp, temp, getout, disp_msg;

   f = 1;

   if (argc > 1) strcpy(pstr, argv[1]);
   else
   {
      printf("Program in file? ");
      gets(pstr);
   }
   if (strlen(pstr) == 0) strcpy(pstr, "0.doc");

   fdin = fopen(pstr, "r");
   if (fdin == NULL)
   {
      printf("Unable to open input file\n");
      exit(1);
   }
   strcpy(f9str, pstr);

   strcpy(pstr, "editfl");
   fdout = fopen(pstr, "w");
   if (fdout == NULL)
   {
      printf("Unable to open editfl output file\n");
      exit(1);
   }

   /* Main program begins here */
   s = 0; l2 = 0; d = 0;
   f2 = 10000;
   printf ("PLEASE WAIT A FEW SECONDS!\n");
   while (fgets(pstr, 255, fdin) != NULL)
   {
      pstr[strlen(pstr) - 1] = '\0';
      p = instr(pstr, " ");
      if (p != 0 && p <= 5)
      {
         n = atoi(midstr2(pstr, 1, p));
         if (n != 0)
         {
            s++;
            sidx[s][0] = n;
            s1 = s;
            while (s1 >= 2)
            {
               s1--;
               if (sidx[s1][0] < sidx[s1 + 1][0]) break;
               if (sidx[s1][0] == sidx[s1 + 1][0])
               {
                  printf("ERROR !!! MORE THAN ONE STATEMENT FOR A ");
                  printf("STATEMENT NUMBER\n");
                  exit(1);
               }

               t = sidx[s1][0];
               sidx[s1][0] = sidx[s1 + 1][0];
               sidx[s1 + 1][0] = t;
            }
         }
      }
   }
   fclose(fdin);

   if (s == 0)
   {
      printf("NO PROGRAM IS IN THE FILE!\n");
      exit(1);
   }

   for (l = 1; l <= s; l++)
      sidx[l][1] = sidx[l][0];
   g = 1;
   disp_msg = 1;

   /*------------------------------------------------------------------------*/
   /* Find out how and what to renumber (using HP BASIC renumber parameters) */
   /* MS BASIC renumber is: RENUM (newnum) (,(oldnum) (,increment))          */
   /*------------------------------------------------------------------------*/

   while(1)
   {
      if (disp_msg == 1)
      {
         printf("RENUMBER (-starting number (,interval (,first statement ");
         printf("(,last))))\n");
         disp_msg = 0;
      }

      skip = 0;
      bp = 0;
      printf("RENUMBER-");
      gets(pstr);
      p = strlen(pstr);

      if (g == 0)
      {
         if (strlen(pstr) == 0) break;
         if (p == 0) skip = 1;
         else
         {
            t = atoi(midstr2(pstr, 1, 1));
            if (t == 0) break;
         }
      }

      if (strlen(pstr) == 0) skip = 1;

      if (skip == 0)
      {
         c = instr(pstr, ",");
         temp = 0; if (c != 0) temp = -1;
         f1 = atoi(midstr2(pstr, 1, p + temp*(p - c + 1)));
         if (f1 == 0) bp = 1;
         if (c == 0) skip = 2;
      }

      if (skip == 0 && bp == 0)
      {
         c1 = instr(midstr1(pstr, c + 1), ",") + c;
         temp = 0; if (c1 != c) temp = -1;
         i = atoi(midstr2(pstr, c + 1, p + temp*(p - c1 + 1) - c));
         if (i == 0) bp = 1;
         if (c1 == c) skip = 3;
      }

      if (skip == 0 && bp == 0)
      {
         c = instr(midstr1(pstr, c1 + 1), ",") + c1;
         temp = 0; if (c != c1) temp = -1;
         f8 = atoi(midstr2(pstr, c1 + 1, p + temp*(p - c + 1) - c1));
         if (f8 == 0) bp = 1;
         if (c == c1) skip = 4;
      }

      if (skip == 0 && bp == 0)
      {
         l = atoi(midstr1(pstr, c + 1));
         if (l == 0) bp = 1;
      }

      if (bp == 0) switch (skip)
      {
         case 1:
            f1 = 10;
            i = 10;
            f8 = 1;
            l = 99999;
            break;

         case 2:
            i = 10;
            f8 = 1;
            l = 99999;
            break;

         case 3:
            f8 = 1;
            l = 99999;
            break;

         case 4:
            l = 99999;
            break;
      }

      if (f1 < 1 || i == 0 || f8 < 1 || l < 1) bp = 1;

      if (f1 > 99999 || i > 99999 || f8 > 99999 || l > 99999 || f8 > l)
         bp = 1;

      c = 0;
      for (r = 1; r <= s; r++)
         if (sidx[r][0] >= f8 && sidx[r][0] <= l) c = c + 1;
      if (c == 0)
      {
         printf("There is nothing to renumber !!\n");
         disp_msg = 1;
      }

      /*------------------------------------*/
      /* Make list of new statement numbers */
      /*------------------------------------*/

      l1 = f1 + (c - 1)*i;
      if (l1 < 1 || l1 > 99999) bp = 1;

      x = 0; c = 0;
      if (bp == 0 && disp_msg == 0) for (r = 1; r <= s; r++)
      {
         if (sidx[r][0] < f8 || sidx[r][0] > l)
         if (sidx[r][1] >= f1 && sidx[r][1] <= l1)
         {
            printf("SEQUENCE NUMBER OVERLAP\n");
            exit(1);
         }
         else {}
         else
         {
            if (sidx[r][0] != f1 + c*i)
            {
               if (x == 0)
               {
                  if (r < f2) f2 = r;
                  x = 1;
               }

               if (r > l2) l2 = r;
            }

            sidx[r][1] = f1 + c*i;
            c++;
            l3 = r;
         }
      }

      if (bp == 0 && disp_msg == 0) g = 0;

      if (bp == 1) printf("BAD PARAMETER\n");
   }

   /*-------------------*/
   /* Start renumbering */
   /*-------------------*/

   if (l2 == 0)
   {
      printf("NOTHING RENUMBERED!\n");
      exit(1);
   }

   printf("RENUMBERING\n");
/*   for (r = 1; r <= s; r ++)
      printf("%d -> %d\n", sidx[r][0], sidx[r][1]); */

   printf("VERIFY? ");
   gets(pstr);
   v1 = 0;
   if (strcmp(midstr2(pstr, 1, 1), "N") == 0) v1 = 1;

   fdin = fopen(f9str, "r");
   if (fdin == NULL)
   {
      printf("Unable to open input file\n");
      exit(1);
   }

   f6 = sidx[f2][0];
   l6 = sidx[l2][0];

   while (fgets(pstr, 255, fdin) != NULL)
   {
      pstr[strlen(pstr) - 1] = '\0';
      b = instr(pstr, " ");
      if (b != 0)
      {
         n = atoi(midstr2(pstr, 1, b));
         if (n != 0)
         {
            if (n >= f6 && n <= l6)
            {
               binary_search();
               if (x == 0)
               {
                  strcat(rstr, midstr1(pstr, b));
                  strcpy(pstr, rstr);
                  b = instr(pstr, " ");
               }
            }
            b++;

            /*-------------------------------------------------------------*/
            /* There are differences, of course, between processing for HP */
            /* BASIC and MS BASIC.                                         */
            /*                                                             */
            /* CONVERT, PRINT USING, and MAT PRINT USING changes are not   */
            /* applicable in MS BASIC.                                     */
            /*                                                             */
            /* Had to also add capability for multiple statements here.    */
            /*-------------------------------------------------------------*/

            while(1)
            {
               if (strcmp(midstr2(pstr, b, 3), "REM") == 0 ||
               strcmp(midstr2(pstr, b, 1), "'") == 0) break;

               f9 = 0;
               skip = 0;
               for (x9 = b; x9 <= strlen(pstr); x9++)
               {
                  if ((char)(*midstr2(pstr, x9, 1)) == 34) 
                  {
                     if (f9 == 0)
                        f9 = 1;
                     else
                        f9 = 0;
                  }
                  else if (strcmp(midstr2(pstr, x9, 1), ":") == 0 &&
                  f9 == 0)
                  {
                     b1 = x9 - 1;
                     skip = 1;
                     break;
                  }
               }
               if (skip == 0) b1 = strlen(pstr);

               t = instr("GOSGOTIF ON RESRET", midstr2(pstr, b, 3));

               temp = (t + 5)/3;
               if (temp != 1)
               {
                  if (temp == 2 || temp == 3 || temp == 4 || temp == 6 ||
                  temp == 7)
                  {
                     /*-------------------------------------------------*/
                     /* Change GOSUB, GOTO, IF, RESTORE, RESUME, RETURN */
                     /* routine.                                        */
                     /* Go word by word through the statement.          */
                     /*-------------------------------------------------*/
                     getout = 0;
                     p8 = b;
                     strcpy(s9str, " ");
                  }
                  else if (temp == 5)
                  {
                     /*---------------------------------------------------*/
                     /* Change ON event/expression GOSUB/GOTO routine.    */
                     /* Find starting point appropriate to this statement */
                     /* type.                                             */
                     /*---------------------------------------------------*/
                     getout = 1;
                     for (x9 = b1; x9 >= b; x9--)
                     {
                        if (strcmp(midstr2(pstr, x9, 1), " ") == 0)
                        {
                           p8 = x9 + 1;
                           getout = 0;
                           break;
                        }
                     }

                     if (getout == 0) strcpy(s9str, ",");
                  }

                  /* Start looping here */
                  if (getout == 0) while(1)
                  {
                     f9 = 0;
                     skip = 0;
                     for (x9 = p8; x9 <= b1; x9++)
                     {
                        if ((char)(*midstr2(pstr, x9, 1)) == 34)
                        {
                           if (f9 == 0)
                              f9 = 1;
                           else
                              f9 = 0;
                        }
                        else if (strcmp(midstr2(pstr, x9, 1), s9str) == 0 &&
                        f9 == 0)
                        {
                           p9 = x9 - 1;
                           skip = 1;
                           break;
                        }
                     }
                     if (skip == 0) p9 = b1;

                     skip = 0;
                     for (x9 = p8; x9 <= p9; x9++)
                     {
                        a = (char)(*midstr2(pstr, x9, 1));
                        if (a < 48 || a > 57)
                        {
                           skip = 1;
                           break;
                        }
                     }

                     if (skip == 0)
                     {
                        /*---------------------*/
                        /* Found a line number */
                        /*---------------------*/
                        n = atoi(midstr2(pstr, p8, p9 - p8 + 1));
                        if (n != 0)
                        {
                           if (n >= f6 && n <= l6)
                           {
                              binary_search();
                              if (x == 0)
                              {
                                 if (p9 == strlen(pstr))
                                 {
                                    strcpy(tempstr, midstr2(pstr, 1, p8 - 1));
                                    strcat(tempstr, rstr);
                                    strcpy(pstr, tempstr);
                                 }
                                 else
                                 {
                                    strcpy(tempstr, midstr2(pstr, 1, p8 - 1));
                                    strcat(tempstr, rstr);
                                    strcat(tempstr, midstr1(pstr, p9 + 1));
                                    strcpy(pstr, tempstr);
                                 }

                                 /*-----------------------------------*/
                                 /* Adjust indices to account for new */
                                 /* substring length, if any.         */
                                 /*-----------------------------------*/
                                 d9 = strlen(rstr) - (p9 - p8 + 1);
                                 p9 = p9 + d9;
                                 b1 = b1 + d9;
                              }
                           }
                        }
                     }

                     p8 = p9 + 2;
                     if (p8 > b1) break;
                  }
               }

               /*--------------------------------------------------*/
               /* No more words to process in the statement, go to */
               /* next statement.                                  */
               /*--------------------------------------------------*/
               if (b1 == strlen(pstr)) break;
               b = b1 + 2;
            }
         }
      }

      fprintf(fdout, "%s\n", pstr);
      if (v1 == 0) printf("%s\n", pstr);
   }

   fclose(fdin);
   fclose(fdout);
   sprintf(tempstr, "mv editfl %s\0", f9str);
   system(tempstr);
}


int instr(astr, bstr)
   char *astr, *bstr;
{
   int p;

   p = strstr(astr, bstr);
   if (p == NULL) p = (int)(astr) - 1;
   p = p - (int)(astr) + 1;

   return p;
}


char *midstr1(astr, start)
   char *astr;
   int start;
{
   static char tempstr[255];
   char *startptr;

   strcpy(tempstr, astr);
   startptr = (char *)((long)(tempstr) + start - 1);

   return startptr;
}


char *midstr2(astr, start, len)
   char *astr;
   int start, len;
{
   static char tempstr[255];
   char *startptr, *endptr;

   strcpy(tempstr, astr);
   startptr = (char *)((long)(tempstr) + start - 1);
   endptr = (char *)((long)(tempstr) + start + len - 1);
   strcpy(endptr, "\0");

   return startptr;
}


void binary_search(void)
{
   int f5, l5, m;

   f5 = f2;
   l5 = l2 + 1;

   while(1)
   {
      m = (f5 + l5)/2;

      if (sidx[m][0] == n)
      {
         sprintf(rstr, "%d\0", sidx[m][1]);
         x = 0;
         return;
      }

      if (m == f5 || m == l5)
      {
         x = 1;
         return;
      }

      if (sidx[m][0] < n)
         f5 = m;
      else
         l5 = m;
   }
}
