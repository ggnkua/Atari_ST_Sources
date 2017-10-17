/*
 * Message output etc for One-Man-Unix. Includes a cut-down printf
 * to avoid the size overhead of the real one.
 */

# define	KERNEL	0	/* Internal kernal printout (output console) */
# define	INBIN	1	/* Internal Binary printout (via tty handler) */

/*
 * Panic - print message and quit cleanly.
 */
panic(messg)
char *messg;
{

	printf("%s\n", messg);
	sync();
	exit(0);
}

/*
 *	Printf: Standard formatted output routine. Internal kernal print
 *		To console directly.
 */
printf(fmt, a1, a2, a3, a4, a5)
char	*fmt;
int	a1, a2, a3, a4, a5;
{
	return print(KERNEL, fmt, a1, a2, a3, a4, a5);
}

/*
 *	Printk: Standard formatted output routine. Internal binary print
 *		Via tty handler.
 */
printk(fmt, a1, a2, a3, a4, a5)
char	*fmt;
int	a1, a2, a3, a4, a5;
{
	return print(INBIN, fmt, a1, a2, a3, a4, a5);
}

/*
 * Print: Standard formatted output routine.
 * Format specification: %f:
 *      f       one of the formats given below.
 *
 * Formats availiable:
 *      s       null terminated string.
 *      x       hex number.
 *      d       decimal number.
 */

print(type, fmt, args)
int	type;
char	*fmt;
int	args;
{
	int *ap;
	char c;

	ap = &args;
	while (1) {
		while ((c = *fmt++) != '%') {
			if (c == '\0')
				return;

			if(type == INBIN) write(1, &c, 1);
			else putchar(c);
		}

		/* format specifier encountered */
		switch (c = *fmt++) {
		case 's':
			prints(type, *ap++);
			break;

		case 'x':
			printx(type, *ap++);
			break;

		case 'd':
			printd(type, *ap++);
			break;

		default:
			if(type == INBIN) write(1, &c, 1);
			else putchar(c);
		}
	}
}

printx(type, var)
int	type;
unsigned var;
{
	char	c;

	if (var & 0xFFFFFFF0)
		printx(type, var >> 4);

	var &= 0xf;
	c = (var>9? var-10+'A': var+'0');
	if(type == INBIN) write(1, &c, 1);
	else putchar(c);
	return;
}

printd(type, val)
int	type, val;
{
	
	if (val < 0){
		val = -val;
		if(type == INBIN) write(1, "-", 1);
		else putchar('-');
	}

	return printu(type, val);
}

printu(type, val)
int	type;
unsigned val;
{
	char	c;

	if (val > 9)
		printu(type, val / 10);

	c = ('0'+ (val%10));
	if(type == INBIN) write(1, &c, 1);
	else putchar(c);
	return;
}

prints(type, str)
int	type;
char	*str;
{
	while (*str){
		if(type == INBIN) write(1, str++, 1);
		else putchar(*str++);
	}
	return;
}
