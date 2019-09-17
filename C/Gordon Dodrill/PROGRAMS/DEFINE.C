#define START  0  /* Starting point of loop */
#define ENDING 9  /* Ending point of loop */
#define MAX(A,B)  ((A)>(B)?(A):(B))  /* Max macro definition */
#define MIN(A,B)  ((A)>(B)?(B):(A))  /* Min macro definition */ 

main()
{
int index,mn,mx;
int count = 5;

   for (index = START;index <= ENDING;index++) {
      mx = MAX(index,count);
      mn = MIN(index,count);
      printf("Max is %d and min is %d\n",mx,mn);
   }
}
