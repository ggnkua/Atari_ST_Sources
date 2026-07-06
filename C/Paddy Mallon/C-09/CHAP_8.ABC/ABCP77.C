/*  ABC p77 eg 8.2                  */
/*  CONCISENESS  (or obscurity?)    */
/*  compare the random number generator of chap 6 (style = 64.1)
     with the  functionally equivalent program below.          */

/****************
 * style = 49.3 *
 ****************/

#define maxint 32767
#define pshift 4
#define qshift 11

random(range)
     int range;
     {
          static int n=1;
          return((n=((n=n^n>>pshift)^n<<qshift)&maxint)%(range+1));
     }
