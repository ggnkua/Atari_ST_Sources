main()
{
struct {
   char initial;
   int age;
   int grade;
   } kids[12],*point;

int index;

   for (index = 0;index < 12;index++) {
      point = kids + index;
      point->initial = 'A' + index;
      point->age = 16;
      point->grade = 84;
   }

   kids[3].age = kids[5].age = 17;
   kids[2].grade = kids[6].grade = 92;
   kids[4].grade = 57;

   for (index = 0;index < 12;index++) {
      point = kids + index;
      printf("%c is %d years old and got a grade of %d\n",
             (*point).initial, kids[index].age,
             point->grade);
   }
}
