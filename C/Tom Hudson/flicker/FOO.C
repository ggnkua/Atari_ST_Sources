
char in[32] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18
 ,19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31};
char out[128];

main(argc, argv)
int argc;
char *argv[];
{
int inc, outc;

inc = outc = 8;
if (argc > 1)
	inc = atoi(argv[1]);
if (argc > 2)
	outc = atoi(argv[2]);

stretch(in, out, inc, outc);
print_chars(out, outc);
}

print_chars(buf, count)
char *buf;
int count;
{
int i;

for (i=0; i<count; )
	{
	printf("%3d ", buf[i]);
	i++;
	if ((i&7) == 0)
		printf("\n");
	}
printf("\n");
}
