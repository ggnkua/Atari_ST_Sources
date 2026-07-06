/*  ABC p78 eg 8.4                  */
/*  CONCISENESS  (or obscurity?)    */
/*  compare this with eg 8.3        */
/*  The only difference is in the identifier names  */

/****************
 * style = 63.4 *
 ****************/

#define LO 2
#define HI 1000
main()
     {     int number,sum;
          for (number= LO; number<= HI; number++)
               {  sum = factorsum(number);

                  if ( sum == number )
                           printf("%d is perfect\n",number);
                  else if (factorsum(sum)==number)
                           printf("%d an  %d are amicable\n",number,sum);
               }
     }

     
factorsum(num)
     int num;
     {    int fsum,factor;
          fsum=1;
          for (factor=2;factor<num;factor++)
               if (num%factor==0) fsum+=factor;
          return(fsum);
     }

