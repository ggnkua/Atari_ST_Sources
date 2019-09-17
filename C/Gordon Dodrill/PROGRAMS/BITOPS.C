main()
{
char mask;
char number[6];
char and,or,xor,inv,index;

   number[0] = 0X00;
   number[1] = 0X11;
   number[2] = 0X22;
   number[3] = 0X44;
   number[4] = 0X88;
   number[5] = 0XFF;

   printf(" nmbr  mask   and    or   xor   inv\n");
   mask = 0X0F;
   for (index = 0;index <= 5;index++) {
      and = mask & number[index];
      or = mask | number[index];
      xor = mask ^ number[index];
      inv = ~number[index];
      printf("%5x %5x %5x %5x %5x %5x\n",number[index],
              mask,and,or,xor,inv);
   }

   printf("\n");
   mask = 0X22;
   for (index = 0;index <= 5;index++) {
      and = mask & number[index];
      or = mask | number[index];
      xor = mask ^ number[index];
      inv = ~number[index];
      printf("%5x %5x %5x %5x %5x %5x\n",number[index],
              mask,and,or,xor,inv);
   }
}