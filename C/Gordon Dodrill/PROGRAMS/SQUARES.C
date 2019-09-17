main()  /* This is the main program */
{
int x,y;

   for(x = 0;x <= 7;x++) {
      y = squ(x);  /* go get the value of x*x */
      printf("The square of %d is %d\n",x,y);
   }

   for (x = 0;x <= 7;++x) 
      printf("The value of %d is %d\n",x,squ(x));
}

squ(in)  /* function to get the value of in squared */
int in;
{
int square;

   square = in * in;
   return(square);  /* This sets squ() = square */
}
