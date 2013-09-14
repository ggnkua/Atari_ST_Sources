/* This a simple C program that computes the results of three
 * different rates of inflation over a span of ten years.
 * Use this text file to learn how to use MicroEMACS commands
 * to make creating and editing text files fast, efficient, and
 * easy.
 */
#include <stdio.h>
main()
{
	int i;		/* count ten years */
	float w1, w2, w3;	/* three inflated quantities  */
	char  *msg = " %2d\t%f %f\n";  /* printf string */
	i = 0;
	w1 = 1.0;
	w2 = 1.0;
	w3 = 1.0;
	for (i = 1; i<= 10; i++) {
		w1 *= 1.07;	/*  apply inflation */
		w2 *= 1.08;
		w3 *= 1.10;
		printf (msg, i, w1, w2, w3);
	}
}
