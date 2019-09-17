main()
{
int truck;

   for (truck = 3;truck < 13;truck = truck + 1) {

      switch (truck) {
         case 3  : printf("The value is three\n");
                   break;
         case 4  : printf("The value is four\n");
                   break;
         case 5  :
         case 6  :
         case 7  :
         case 8  : printf("The value is between 5 and 8\n");
                   break;
         case 11 : printf("The value is eleven\n");
                   break;
         default : printf("It is one of the undefined values\n");
                   break;
      } /* end of switch */

   } /* end of for loop */
}