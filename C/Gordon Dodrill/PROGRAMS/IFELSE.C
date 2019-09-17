/* This is an example of the if and the if-else statements */

main()
{
int data;

   for(data = 0;data < 10;data = data + 1) {

      if (data == 2)
         printf("Data is now equal to %d\n",data); 

      if (data < 5)
         printf("Data is now %d, which is less than 5\n",data);
      else
         printf("Data is now %d, which is greater than 4\n",data);
           
   }  /* end of for loop */
}
