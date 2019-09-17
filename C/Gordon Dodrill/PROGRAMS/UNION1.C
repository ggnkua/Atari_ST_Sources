main()
{
union {
   int value;     /* This is the first part of the union */
   struct {
      char first;   /* These two values are the second     */
      char second;
   } half;
} number;

long index;

   for (index = 12;index < 300000;index += 35231) {
      number.value = index;
      printf("%8x %6x %6x\n",number.value, number.half.first,
              number.half.second);
   }
}
