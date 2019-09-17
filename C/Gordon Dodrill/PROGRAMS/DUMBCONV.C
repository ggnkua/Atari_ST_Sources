main()
{
int x1,x2,x3;

   printf("Centigrade to Farenheit temperature table\n\n");

   for(x1 = -2;x1 <= 12;x1 = x1 + 1){
      x3 = 10 * x1;
      x2 = 32 + (x3 * 9)/5;
      printf("  C =%4d   F =%4d  ",x3,x2);
      if (x3 == 0)
         printf(" Freezing point of water");
      if (x3 == 100)
         printf(" Boiling point of water");
      printf("\n");
   }
}
    