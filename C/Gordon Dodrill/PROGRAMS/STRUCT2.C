main()
{
struct {
   char initial;
   int age;
   int grade;
   } kids[12];

int index;

   for (index = 0;index < 12;index++) {
      kids[index].initial = 'A' + index;
      kids[index].age = 16;
      kids[index].grade = 84;
   }

   kids[3].age = kids[5].age = 17;
   kids[2].grade = kids[6].grade = 92;
   kids[4].grade = 57;

   for (index = 0;index < 12;index++)
      printf("%c is %d years old and got a grade of %d\n",
             kids[index].initial, kids[index].age,
             kids[index].grade);
}
