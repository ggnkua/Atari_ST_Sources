
#include <osbind.h>


touch_pat(pat)
char *pat;
{
char *dta;
char *title;
int i;
int f;
int time[2];

dta = (char *)Fgetdta();
title = dta+40;

time[1] = Tgetdate();
time[0] = Tgettime();
if (Fsfirst( pat, 0) >= 0)
	{
	do
		{
puts(title);
		f = Fopen(title, 1);
		if (f >= 0)
		{
		Fdatime(time, f, 1);
		Fclose(f);
		}
		}
	while (Fsnext() >= 0);
	}
}

main(argc, argv)
int argc;
char *argv[];
{
puts("touching .h");
touch_pat("*.h");
puts("touching .c");
touch_pat("*.c");
puts("touching .o");
touch_pat("*.o");
}
