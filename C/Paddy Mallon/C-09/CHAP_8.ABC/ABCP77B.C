/*  ABC p77 eg 8.3                  */
/*  CONCISENESS  (or obscurity?)    */
/*  compare this with eg 8.4        */
/*  The only difference is in the identifier names  */

/****************
 * style = 49.9 *
 ****************/

#define LO 2
#define HI 1000
main()
     {     int i,j;
          for (i= LO; i< HI; i++)
               {  j = sum(i);
                    if ( j == i ) printf("%d\n",i);
                    else if (sum(j)==i) printf("%d %d\n",i,j);
               }
     }

     
sum(n)
     int n;
     {    int s,f;
          s=1;
          for (f=2;f<n;f++)
               if (n%f==0) s+=f;
          return(s);
     }

