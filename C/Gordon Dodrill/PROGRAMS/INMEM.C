main()
{
int numbers[5], result[5], index;
char line[80];

   numbers[0] = 74;
   numbers[1] = 18;
   numbers[2] = 33;
   numbers[3] = 30;
   numbers[4] = 97;

   sprintf(line,"%d %d      %d %d %d\n",numbers[0],numbers[1],
           numbers[2],numbers[3],numbers[4]);

   printf("%s",line);

   sscanf(line,"%d %d %d %d      %d",&result[4],&result[3],
           (result+2),(result+1),result);


   for (index = 0;index < 5;index++)
      printf("The final result is %d\n",result[index]);

}