/* Output from p2c, the Pascal-to-C translator */
/* From input file "dist/examples/e.p" */


#include <p2c/p2c.h>


#define NDIGITS         1007
#define NPRINT          1000


typedef uchar digit;

typedef digit digitarray[NDIGITS + 1];


Static digit *s, *x, *t;
Static long xs, ts, i;


Static Void initinteger(x, n)
digit *x;
long n;
{
  long i;

  x[0] = n;
  for (i = 1; i <= NDIGITS; i++)
    x[i] = 0;
}


Static Void divide(x, xs, n, y, ys)
digit *x;
long xs, n;
digit *y;
long *ys;
{
  long i, c;

  c = 0;
  for (i = xs; i <= NDIGITS; i++) {
    c = c * 10 + x[i];
    y[i] = c / n;
    c %= n;
/* p2c: dist/examples/e.p, line 37:
 * Note: Using % for possibly-negative arguments [317] */
  }
  *ys = xs;
  while (*ys <= NDIGITS && y[*ys] == 0)
    (*ys)++;
}


Static Void add(s, x, xs)
digit *s, *x;
long xs;
{
  long i, c;

  c = 0;
  for (i = NDIGITS; i >= xs; i--) {
    c += s[i] + x[i];
    if (c >= 10) {
      s[i] = c - 10;
      c = 1;
    } else {
      s[i] = c;
      c = 0;
    }
  }
  i = xs;
  while (c != 0) {
    i--;
    c += s[i];
    if (c >= 10) {
      s[i] = c - 10;
      c = 1;
    } else {
      s[i] = c;
      c = 0;
    }
  }
}


Static Void sub(s, x, xs)
digit *s, *x;
long xs;
{
  long i, c;

  c = 0;
  for (i = NDIGITS; i >= xs; i--) {
    c += s[i] - x[i];
    if (c < 0) {
      s[i] = c + 10;
      c = -1;
    } else {
      s[i] = c;
      c = 0;
    }
  }
  i = xs;
  while (c != 0) {
    i--;
    c += s[i];
    if (c < 0) {
      s[i] = c + 10;
      c = -1;
    } else {
      s[i] = c;
      c = 0;
    }
  }
}


main(argc, argv)
int argc;
Char *argv[];
{
  PASCAL_MAIN(argc, argv);
  s = (digit *)Malloc(sizeof(digitarray));
  x = (digit *)Malloc(sizeof(digitarray));
  initinteger(s, 0L);
  initinteger(x, 1L);
  xs = 0;
  add(s, x, xs);
  i = 0;
  do {
    i++;
    divide(x, xs, i, x, &xs);
    add(s, x, xs);
    printf("\015Series: %5.2f%%", xs * 100.0 / (NDIGITS + 1));
  } while (xs <= NDIGITS);
  printf("\n%45se = %d.\n", "", s[0]);
  i = 0;
  for (i = 1; i <= NPRINT; i++) {
    printf("%d", s[i]);
    if (i % 1000 == 0)
      putchar('\n');
/* p2c: dist/examples/e.p, line 121:
 * Note: Using % for possibly-negative arguments [317] */
    if (i % 100 == 0)
      putchar('\n');
    else if (i % 10 == 0)
      putchar(' ');
/* p2c: dist/examples/e.p, line 122:
 * Note: Using % for possibly-negative arguments [317] */
  }
  printf("\nFinal digits: ");
  for (i = NPRINT + 1; i <= NDIGITS; i++)
    printf("%d", s[i]);
  putchar('\n');
  exit(EXIT_SUCCESS);

/* p2c: dist/examples/e.p, line 123:
 * Note: Using % for possibly-negative arguments [317] */
}



/* End. */
