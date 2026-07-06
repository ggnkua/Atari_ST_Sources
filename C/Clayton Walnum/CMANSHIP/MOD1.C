# include <stdio.h>

main()
{
int num=5555;
char ch;

printf ( ">%d<\n", num );
printf ( ">%10d<\n", num );
printf ( ">%010d\n", num );
printf ( ">%3d<\n", num );
printf ( ">%-10d<\n", num );
printf ( ">%f<\n", 3.14159 );
printf ( ">%2.3f<\n", 3.14159 );
printf ( ">%10.4f<\n", 3.14159 );
printf ( ">%-10.4f<\n", 3.14159 );
ch = getchar();
}
