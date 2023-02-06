#include <stdio.h>
#include <osbind.h>

#define VBL_ISR 28

typedef void (*Vector)(void); /* a Vector is a function start addr. */

Vector install_vector(int num, Vector vector);
void do_VBL_ISR(void);
void Vbl(void);

int g_seconds;
long g_ticks;

int main(void)
{
	int i;
	Vector orig_vector = install_vector(VBL_ISR, Vbl);

	while (g_seconds < 10)
		if ((i + 1) == g_seconds)
		{
			i++;
			printf("%d\n", i);
		}

	install_vector(VBL_ISR, orig_vector);

	return 0;
}

/* routine which replaces a TOS ISR with a custom ISR: */
Vector install_vector(int num, Vector vector)
{
	Vector orig;
	Vector *vectp = (Vector *)((long)num << 2);
	long old_ssp = Super(0);

	orig = *vectp;
	*vectp = vector;

	Super(old_ssp);
	return orig;
}

void do_VBL_ISR(void)
{
	g_ticks += 1;

	if (g_ticks % 70 == 0)
		g_seconds++;
}
