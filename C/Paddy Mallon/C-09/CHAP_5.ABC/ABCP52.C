/*  ABC p 52 eg 5.6                    */
/*  perfect numbers                    */
/*  tested and working 27/11/86        */


#define  LO 6
#define  HI 1000
int ticks = 300;
main()
     {
          int num,sum,factor;
     
          printf("  perfect numbers \n");
          for (num = LO; num<=HI; num+=2)
          { 
               sum = 1;
               for (factor=2; factor<num; factor++)
                    if ( num%factor == 0) sum+=factor;
               if ( sum == num ) printf("%4d\n",num);
          }
     delay(ticks);
     }
