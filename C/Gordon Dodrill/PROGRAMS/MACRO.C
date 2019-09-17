#define WRONG(A) A*A*A      /* Wrong macro for cube */
#define CUBE(A) (A)*(A)*(A) /* Right macro for cube */
#define SQUR(A) (A)*(A)     /* Right macro for square */
#define START 1
#define STOP  9

main()
{
int i,offset;

   offset = 5;
   for (i = START;i <= STOP;i++) {
      printf("The square of %3d is %4d, and its cube is %6d\n",
              i+offset,SQUR(i+offset),CUBE(i+offset));
      printf("The wrong of  %3d is %6d\n",i+offset,WRONG(i+offset));
   }
}
