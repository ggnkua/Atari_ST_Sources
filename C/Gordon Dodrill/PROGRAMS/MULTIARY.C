main()
{
int i,j;
int big[8][8],huge[25][12];

   for (i = 0;i < 8;i++)
      for (j = 0;j < 8;j++)
         big[i][j] = i * j;       /* This is a multiplication table */

   for (i = 0;i < 25;i++)
      for (j = 0;j < 12;j++)
         huge[i][j] = i + j;           /* This is an addition table */

   big[2][6] = huge[24][10]*22;
   big[2][2] = 5;
   big[big[2][2]][big[2][2]] = 177;     /* this is big[5][5] = 177; */

   for (i = 0;i < 8;i++) {
      for (j = 0;j < 8;j++)
         printf("%5d ",big[i][j]);
      printf("\n");               /* newline for each increase in i */
   }
}