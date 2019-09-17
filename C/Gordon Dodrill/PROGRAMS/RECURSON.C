main()
{
int index;

   index = 8;
   count_dn(index);
}

count_dn(count)
int count;
{
   count--;
   printf("The value of the count is %d\n",count);
   if (count > 0)
      count_dn(count);
   printf("Now the count is %d\n",count);
}
