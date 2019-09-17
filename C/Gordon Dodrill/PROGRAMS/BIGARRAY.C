char name1[] = "First Program Title";

main()
{
int index;
int stuff[12];
float weird[12];
static char name2[] = "Second Program Title";

   for (index = 0;index < 12;index++) {
      stuff[index] = index + 10;
      weird[index] = 12.0 * (index + 7);
   }

   printf("%s\n",name1);
   printf("%s\n\n",name2);
   for (index = 0;index < 12;index++)
      printf("%5d %5d %10.3f\n",index,stuff[index],weird[index]);
}
