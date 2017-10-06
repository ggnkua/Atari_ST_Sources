void sub1 (void)
{
	long	i;

	for (i = 0; i < 100000L; i++)
		;
}

void sub2 (void)
{
	long	i;

	for (i = 0; i < 500000L; i++)
		;
}

void sub3 (void)
{
	long	i;

	for (i = 0; i < 1000000L; i++)
		;
}

void main (void)
{
	sub1 ();
	sub2 ();
	sub3 ();
}
