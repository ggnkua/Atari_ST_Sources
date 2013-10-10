                          A very fast root-routine!

This  C-Sources  show  the  way to the fastes root-routine as described in the
article  in  this  McDisk.   I found this routines in the german paper-mag C`T
1/90.  The routine was developed by Otto Peter.  If you need a root-routine in
assembler, risk a look at the other sources on this Disk.

The different sources show the optimition in 5 steps.  Just take the last one,
cause it`s the fastes!



#define N_BITS 32
#define MAX_BIT ((N_BITS + 1) / 2 - 1)

unsigned long int sqrt_1(x)
  unsigned long int x;
  {
  register int i;
  register unsigned long int m, r, root;

  root = 0;  m = 1 << MAX_BIT
  for (i = MAX_BIT;  i >= 0;  i--)
    {
    r = root + m;
    if (r * r <= X) root = r;
    m >>= 1;                                /* same as  m = m/2 */
    }
  return root;
  }


unsigned long int sqrt_2(x)
  unsigned long int x;
  {
  register long int i;
  register unsigned long int m, r2, root;
  unsigned long int root2;

  root2 = root = 0;  m = 1 << MAX_BIT;
  for (i = MAX_BIT;  i >= 0;  i--)
    {
    r2 = root2 + (root << i + 1)  +  (1 << i + i);
    if (r2 <= X)
      {
      root2 = r2;  root += m;
      }
    m >>= 1;
    }
  return root;
  }


unsigned long int sqrt_3(x)
  unsigned long int x;
  {
  register unsigned long int m2, r2, xroot, root2;
  int i;

  root2 = xroot = 0;  m2 = 1 << MAX_BIT * 2;
  for (i = MAX_BIT;  i >= 0;  i--)
    {
    r2 = root2 + xroot + m2;
    xroot >>= 1;
    if (r2 <= X)
      {
      root2 = r2;  xroot += m2;
      }
    m2 >>= 2;
    }
  return xroot;
  }


unsigned long int sqrt_4(x)
  unsigned long int x;
  {
  register unsigned long int xroot, m2, x2;

  xroot = 0;  m2 = 1 << MAX_BIT * 2;
  do
    {
    x2 = xroot + m2;
    xroot >>= 1;
    if (x2 <= X)
      {
      x -= x2;  xroot += m2;
      }
    }
  while (m2 >>= 2);
  return xroot;
  }


unsigned long int sqrt_5(x)
  unsigned long int x;
  {
  register unsigned long int xroot, m2, x2;

  xroot = 0;  m2 = 1 << MAX_BIT * 2;
  do
    {
    x2 = xroot + m2;
    xroot >>= 1;
    if (x2 <= X)
      {
      x -= x2;  xroot += m2;
      }
    }
  while (m2 >>= 2);
  if (xroot < x) return xroot + 1;
  return xroot;
  }


