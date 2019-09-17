main()
{
struct animal {
   char name[25];
   char breed[25];
   int age;
} *pet1, *pet2, *pet3;

   pet1 = (struct animal *)malloc(sizeof(struct animal));
   strcpy(pet1->name,"General");
   strcpy(pet1->breed,"Mixed Breed");
   pet1->age = 1;

   pet2 = pet1;   /* pet2 now points to the above data structure */

   pet1 = (struct animal *)malloc(sizeof(struct animal));
   strcpy(pet1->name,"Frank");
   strcpy(pet1->breed,"Labrador Retriever");
   pet1->age = 3;

   pet3 = (struct animal *)malloc(sizeof(struct animal))
   strcpy(pettt3->name,"Krystal");
   strcpy(pet3->breed,"German Shepherd");
   pet3->age = 4;

       /* now print out the data described above */

   printf("%s is a %s, and is %d years old.\n", pet1->name,
           pet1->breed, pet1->age);

   printf("%s is a %s, and is %d years old.\n", pet2->name,
           pet2->breed, pet2->age);

   printf("%s is a %s, and is %d years old.\n", pet3->name,
           pet3->breed, pet3->age);

   pet1 = pet3;   /* pet1 now points to the same structure that
                      pet3 points to                           */
   free(pet3);    /* this frees up one structure               */
   free(pet2);    /* this frees up one more structure          */
/* free(pet1);    this cannot be done, see explanation in text */
}
