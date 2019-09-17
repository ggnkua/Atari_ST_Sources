main()
{
int pecans,apples;

   pecans = 100;
   apples = 101;
   printf("The starting values are %d %d\n",pecans,apples);

                           /* when we call "fixup"          */
   fixup(pecans,&apples);  /* we take the value of pecans   */
                           /* we take the address of apples */

   printf("The ending values are %d %d\n",pecans,apples);
}

fixup(nuts,fruit)             /* nuts is an integer value   */
int nuts,*fruit;              /* fruit points to an integer */
{
   printf("The values are %d %d\n",nuts,*fruit);
   nuts = 135;
   *fruit = 172;
   printf("The values are %d %d\n",nuts,*fruit);
}