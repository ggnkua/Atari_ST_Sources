#include <stdio.h>

main()
{
char ch;
int num1,num2,ans;

printf ( "Enter two numbers: " );
scanf ( "%d %d", &num1, &num2 );
ans = num1 + num2;
printf ( "\n\n" );
printf ( "The sum of %d and %d is %d.\n\n", num1, num2, ans );
printf ( "Press space bar\n" );
ch = getchar();
ch = getchar();
}
