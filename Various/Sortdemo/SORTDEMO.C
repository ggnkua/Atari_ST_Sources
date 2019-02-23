/* C version of Selection Sort */
#include stdin
#define MAXSIZE 20

main()
{
   int x,Numbers[MAXSIZE],SortedNumbers[MAXSIZE];
   
   for (x=0; x < MAXSIZE; x++)
      Numbers[x] = RandomNumber(200);  /* create array of random values */
   SelectSort(&Numbers,&SortedNumbers);
   printf("\n     UNSORTED ARRAY       SORTED ARRAY\n");
   for (x=0; x < MAXSIZE; x++)
      printf("       %3d       %3d\n",Numbers[x],SortedNumbers[x]);
}

/* Selection Sort */
void SelectSort(Numbers,SortedNumbers)
int *Numbers,*SortedNumbers;
{
   int x,y,temp;
   
   for (x=0; x < MAXSIZE; x++)
      SortedNumbers[x] = Numbers[x];   /* copy original array */
   for (x=0; x < MAXSIZE-1; x++) {     /* do the sort         */
      for (y=x+1; y < MAXSIZE; y++) {
         if (SortedNumbers[x] > SortedNumbers[y]) {
            temp = SortedNumbers[x];
            SortedNumbers[x] = SortedNumbers[y];
            SortedNumbers[y] = temp;
         }
      }
   }
}