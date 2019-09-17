/****************************************************************/
/*                                                              */
/*     This is a temperature conversion program written in      */
/*      the C programming language. This program generates      */
/*      and displays a table of farenheit and centigrade        */
/*      temperatures, and lists the freezing and boiling        */
/*      of water.                                               */
/*                                                              */
/****************************************************************/

main()
{
int count;        /* a loop control variable               */
int farenheit;    /* the temperature in farenheit degrees  */
int centigrade;   /* the temperature in centigrade degrees */

   printf("Centigrade to Farenheit temperature table\n\n");

   for(count = -2;count <= 12;count = count + 1){
      centigrade = 10 * count;
      farenheit = 32 + (centigrade * 9)/5;
      printf("  C =%4d   F =%4d  ",centigrade,farenheit);
      if (centigrade == 0)
         printf(" Freezing point of water");
      if (centigrade == 100)
         printf(" Boiling point of water");
      printf("\n");
   } /* end of for loop */
}
