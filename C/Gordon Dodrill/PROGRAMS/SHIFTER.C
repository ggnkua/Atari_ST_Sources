main()
{
int small, big, index, count;

   printf("       shift left      shift right\n\n");
   small = 1;
   big = 0x4000;
   for(index = 0;index < 17;index++) {
      printf("%8d %8x %8d %8x\n",small,small,big,big);
      small = small << 1;
      big = big >> 1;
   }

   printf("\n");
   count = 2;
   small = 1;
   big = 0x4000;
   for(index = 0;index < 9;index++) {
      printf("%8d %8x %8d %8x\n",small,small,big,big);
      small = small << count;
      big = big >> count;
   }
}
