main()
{
char line_of_char[80];
int index = 0;

   strcpy(line_of_char,"This is a string.\n");

   forward_and_backwards(line_of_char,index);

}

forward_and_backward(line_of_char,index)
char line_of_char[];
int index;
{
   if (line_of_char[index]) {
      printf("%c",line_of_char[index]);
      index++;
      forward_and_backward_call(line_of_char,index);
   }
   printf("%c",line_of_char[index]);
}
