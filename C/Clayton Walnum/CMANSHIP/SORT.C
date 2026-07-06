#include <stdio.h>
#define MAX 10

main()
{
   int num;
   int val[MAX];
   char ch;

   num = how_many();
   get_nums(num, val);
   sort(num, val);
   output(num, val);
   while ((ch = getchar()) != '\b') ;
}

how_many()
{
   int n;

   n = MAX +1;
   while (n > MAX)
   {
      printf("How many numbers? ");
      scanf("%d", &n);
      printf("\n\n");
   }
   return(n);
}

get_nums(n, v)
int n;
int v[];
{
   int x, num;

   for (x = 0; x < n; ++x)
   {
      printf("Enter number %d: ", x+1);
      scanf("%d", &num);
      v[x] = num;
      printf("\n");
   }
   return;
}

sort(n,v)
int n;
int v[];
{
   int swtch, x, temp;

   swtch = 1;
   while (swtch == 1)
  {
      swtch = 0;
      for (x = 0; x < n - 1; ++x)
         if ( v[x] > v[x+1] )
         {
            temp = v[x];
            v[x] = v[x+1];
            v[x+1] = temp;
            swtch = 1;
         }
    }
   return;
}

output(n, v)
int n;
int v[];
{
   int x;

   printf("Sort complete!\n\n");
   for (x = 0; x <= n - 1; ++x)
      printf( "%d ", v[x] );
   printf("\n\n");
   return;
}
