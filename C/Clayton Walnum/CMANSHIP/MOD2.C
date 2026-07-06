# include <stdio.h>
# define TEXT "strings"

main()
{
char ch;

printf ( ">%s<\n", "strings" );
printf ( ">%10s<\n", TEXT );
printf ( ">%-10s<\n", "strings" );
printf ( ">%10.5s<\n", TEXT );
printf ( ">%-10.5s<\n", "strings" );
ch = getchar;
}
