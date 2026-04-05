/*
 * bench.c
 *
 * Benchmark to stress test calling functions. Always compile fior -Os, not -O3.
 *
 *  Created on: 27.06.2014
 *	  Author: peylow
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <mint/osbind.h>

// Recursive calls.
int bench1a(int i);
int bench1b(int i) {
  if (i <= 0) {
	  i = -i;
  }
  return bench1a(i);
}
int bench1a(int i) {
  if (i == 0) {
	return bench1b(i + 1);
  } else if (i < 3000) {
	return bench1a(i + i);
  } else {
	return i;
  }
}

int bench1(int i) {
  int j, r = 0;
  do {
	for (j = 0; j < 500; j++) {
	  r += bench1a(i);
	}
  } while (i--);
  return r;
}

// Function pointers.
int bench2v(int a, int b) {
  return b != 0;
}
int bench2a(int a, int b) {
  return a + b;
}
int bench2b(int a, int b) {
  return a - b;
}
int bench2c(int a, int b) {
  return a * b;
}
int bench2d(int a, int b) {
  return a / b;
}
int bench2e(int a, int b, int f(int, int), int v(int, int)) {
  if (!v || v(a,b)) {
	return f(a,b);
  }
  return 1;
}
int bench2(int i) {
  i *= 50;
  int (*funcs[4])(int, int) = { &bench2a, &bench2b, &bench2c, &bench2d};
  int j, k, res = 0;
  do {
	for (j = 0; j < 16; j++) {
	  k = (i + (j >> 2)) & 0x3;
	  res += bench2e(i, j, funcs[k], k == 3 ? &bench2v : NULL);
	}
  } while (i--);
  return res;
}

// Compression!
int bench3b(char *c_first, char *c_last, int run_len) {
  return !(*c_last) || *c_last != *c_first || run_len == 9;
}
int bench3c(int run_len) {
  return run_len > 1;
}
char *bench3a(char *str, char *dst) {
  char *c_first = str;
  char *c_last = str;
  char *c_write = dst;
  int run_len = 0;
  while (*str) {
	++c_last;
	++run_len;
	if (bench3b(c_first, c_last, run_len)) {
	  // end of run
	  *(c_write++) = *c_first;
	  if (bench3c(run_len))
		*(c_write++) = '0' + run_len;
	  // start next run
	  run_len = 0;
	  c_first = c_last;
	}
	++str;
  }
  *c_write = 0;
  return dst;
}
int bench3(int i) {
  i *= 40;
  char *str = "hello world, lets try co compress this.";
  char dst[256];
  do {
	(void)bench3a(str, dst);
  } while (i--);
  return 1;
}

// Bubble sort
int bench4b(int doswap, char *a, char *b) {
  if (doswap) {
	char s = *a;
	*a = *b;
	*b = s;
	return 1;
  }
  return 0;
}
char bench4d(char a) {
  if (a >= 'A' && a <= 'Z') {
	return a + 32;
  }
  return a;
}
int bench4c(char a, char b) {
  return bench4d(a) > bench4d(b);
}
int bench4a(unsigned long cnt, char *str, char *dst) {
  strncpy(dst, str, cnt);
  int c, d, ret = 0;
  
  for (c = 0 ; c < ( cnt - 1 ); c++) {
	for (d = 0 ; d < cnt - c - 1; d++) {
	  ret += bench4b(bench4c(dst[d], dst[d+1]), &dst[d], &dst[d+1]);
	}
  }
  return ret;
}
int bench4(int i) {
  char *str = "The quick brown fox jumps over the lazy dog";
  char dst[256];
  do {
	(void)bench4a(strlen(str), str, dst);
  } while (i--);
  return 1;
}

int main(int argc, char *argv[])
{
  int count, i;
  time_t start = time(NULL);
  
  while (Cconis()) Cconin();
  
  if (argc >= 2) {
	count = atoi(argv[1]);
	
	for (i = 1; i <= count; i++) {
		(void)bench1(i & 0xf);
		(void)bench2(i & 0xf);
		(void)bench3(i & 0xf);
		(void)bench4(i & 0xf);
	}
	
	printf("Executed in %ld seconds.\r\n", (long)time(NULL) - start);
  } else {
	printf("Provide number of iterations\r\n");
  }
  
  
  printf("press a key to return to desktop\r\n");
  Cconin();
  
  return 0;
}

