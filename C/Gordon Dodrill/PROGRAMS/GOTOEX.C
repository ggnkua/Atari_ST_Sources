main()
{
int dog,cat,pig;

   goto real_start;

   some_where:
   printf("This is another line of the mess.\n");
   goto stop_it;

/* the following section is the only section with a useable goto */
   real_start:
   for(dog = 1;dog < 6;dog++) {
      for(cat = 1;cat < 6;cat++) {
         for(pig = 1;pig < 4;pig++) {
            printf("Dog = %d  Cat = %d  Pig = %d\n",dog,cat,pig);
            if ((dog + cat + pig) > 8 ) goto enough;
         };
      };
   };
   enough: printf("Those are enough animals for now.\n");
/* this is the end of the section with a useable goto statement */

   printf("\nThis is the first line out of the spaghetti code.\n");
   goto there;

   where:
   printf("This is the third line of spaghetti.\n");
   goto some_where;

   there:
   printf("This is the second line of the spaghetti code.\n");
   goto where;

   stop_it:
   printf("This is the last line of this mess.\n");

}