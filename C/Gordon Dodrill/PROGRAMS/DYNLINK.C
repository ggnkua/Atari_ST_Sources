#include "stdio.h" /* this is needed only to define the NULL */
#define RECORDS 6

main()
{
struct animal {
   char name[25];       /* The animals name                         */
   char breed[25];      /* The type of animal                       */
   int age;             /* The animals age                          */
   struct animal *next; /* a pointer to another record of this type */
} *point, *start, *prior; /* this defines 3 pointers, no variables  */
int index;

                       /* the first record is always a special case */
   
   start = (struct animal *)malloc(sizeof(struct animal));
   strcpy(start->name,"General");
   strcpy(start->breed,"Mixed Breed");
   start->age = 4;
   start->next = NULL;
   prior = start;
       /* a loop can be used to fill in the rest once it is started */

   for (index = 0;index < RECORDS;index++) {
      point = (struct animal *)malloc(sizeof(struct animal));
      strcpy(point->name,"Frank");
      strcpy(point->breed,"Laborador Retriever");
      point->age = 3;
      prior->next = point;  /* point last "next" to this record */
      point->next = NULL;   /* point this "next" to NULL        */
      prior = point;        /* this is now the prior record     */
   }

       /* now print out the data described above */

   point = start;
   do {
      prior = point->next;
      printf("%s is a %s, and is %d years old.\n", point->name,
              point->breed, point->age);
      point = point->next;
   } while (prior != NULL);

       /* good programming practice dictates that we free up the */
       /* dynamically allocated space before we quit.            */

   point = start;            /* first block of group      */
   do {
      prior = point->next;   /* next block of data        */
      free(point);           /* free present block        */
      point = prior;         /* point to next             */
   } while (prior != NULL);  /* quit when next is NULL    */
}
