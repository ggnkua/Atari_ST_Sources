#include <minix/u64.h>

unsigned long cv64ul(u64_t u64)
{
  return(u64._[1]);
}

/* this for mkfs */
u64_t cvu64(unsigned int u)
{
  u64_t u64;
  u64._[0] = 0;
  u64._[1] = (unsigned long) u;
  return(u64);
}

u64_t cvul64(unsigned long ul)
{
  u64_t u64;
  u64._[0] = 0;
  u64._[1] = ul;
  return(u64);
}

unsigned long div64u(u64_t u64, unsigned u)
{
  return(u64._[1] / (unsigned long) u);
}

int cmp64u(u64_t u64, unsigned u)
{
  return((int)(u64._[1]>(unsigned long)u - u64._[1]<(unsigned long)u));
}

u64_t mul64u(unsigned long ul, unsigned u)
{
  u64_t u64;
  u64._[0] = 0;
  u64._[1] = ul * (unsigned long) u;
  return(u64);
}

