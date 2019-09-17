main()
{

struct {
   char initial;    /* last name initial      */
   int age;         /* childs age             */
   int grade;       /* childs grade in school */
   } boy,girl;

   boy.initial = 'R';
   boy.age = 15;
   boy.grade = 75;

   girl.age = boy.age - 1;  /* she is one year younger */
   girl.grade = 82;
   girl.initial = 'H';

   printf("%c is %d years old and got a grade of %d\n",
           girl.initial, girl.age, girl.grade);

   printf("%c is %d years old and got a grade of %d\n",
           boy.initial, boy.age, boy.grade);
}
