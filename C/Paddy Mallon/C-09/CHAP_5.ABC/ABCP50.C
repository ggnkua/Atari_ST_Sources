/*   ABC p50                      */
/*   for loop                     */
/*   works ok 27/11/86            */


#include <stdio.h>
int ticks = 200;
int sum,n,i;

main()
     {sum=0,n=20;
         for (i = 1;i<=n;i++)sum=sum+i;
         printf("answer = %3d\n",sum);
     delay(ticks);

     sum=0;
     for(i=n;i>=1;i--)sum+=i;
         printf("answer 2 = %3d\n",sum);
     delay(ticks);
     }
