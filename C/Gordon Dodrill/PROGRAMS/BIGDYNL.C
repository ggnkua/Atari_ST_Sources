main()
{
struct animal {
   char name[25];
   char breed[25];
   int age;
} *pet[12], *point;   /* this defines 13 pointers, no variables */
int index;

            /* first, fill the dynamic structures with nonsense */
   for (index = 0;index < 12;index++) {
      pet[index] = (struct animal *)malloc(sizeof(struct animal));
      strcpy(pet[index]->name,"General");
      strcpy(pet[index]->breed,"Mixed Breed");
      pet[index]->age = 4;
   }

   pet[4]->age = 12;        /* these lines are simply to        */
   pet[5]->age = 15;        /*      put some nonsense data into */
   pet[6]->age = 10;        /*            a few of the fields.  */

       /* now print out the data described above */

   for (index = 0;index <12;index++) {
      point = pet[index];
      printf("%s is a %s, and is %d years old.\n", point->name,
              point->breed, point->age);
   }

       /* good programming practice dictates that we free up the */
       /* dynamically allocated space before we quit.            */

   for (index = 0;index < 12;index++)
      free(pet[index]);
}
