main()
{
int values[12];
int index;

   for (index = 0;index < 12;index++)  
      values[index] = 2 * (index + 4);

   for (index = 0;index < 12;index++)
      printf("The value at index = %2d is %3d\n",index,values[index]);

}
