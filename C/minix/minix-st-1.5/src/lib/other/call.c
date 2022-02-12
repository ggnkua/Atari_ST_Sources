#include <lib.h>

PUBLIC int callm1(proc, syscallnr, int1, int2, int3, ptr1, ptr2, ptr3)
int proc;			/* FS or MM */
int syscallnr;			/* which system call */
int int1;			/* first integer parameter */
int int2;			/* second integer parameter */
int int3;			/* third integer parameter */
char *ptr1;			/* pointer parameter */
char *ptr2;			/* pointer parameter */
char *ptr3;			/* pointer parameter */
{
/* Send a message and get the response.  The 'M.m_type' field of the
 * reply contains a value (>= 0) or an error code (<0). Use message format m1.
 */
  _M.m1_i1 = int1;
  _M.m1_i2 = int2;
  _M.m1_i3 = int3;
  _M.m1_p1 = ptr1;
  _M.m1_p2 = ptr2;
  _M.m1_p3 = ptr3;
  return callx(proc, syscallnr);
}


PUBLIC int callm3(proc, syscallnr, int1, name)
int proc;			/* FS or MM */
int syscallnr;			/* which system call */
int int1;			/* integer parameter */
_CONST char *name;		/* string */
{
/* This form of system call is used for those calls that contain at most
 * one integer parameter along with a string.  If the string fits in the
 * message, it is copied there.  If not, a pointer to it is passed.
 */
  register int k;
  register char *rp;
  k = len(name);
  _M.m3_i1 = k;
  _M.m3_i2 = int1;
  _M.m3_p1 = (char *) name;
  rp = &_M.m3_ca1[0];
  if (k <= M3_STRING) while (k--)
		*rp++ = *name++;
  return callx(proc, syscallnr);
}


PUBLIC int callx(proc, syscallnr)
int proc;			/* FS or MM */
int syscallnr;			/* which system call */
{
/* Send a message and get the response.  The '_M.m_type' field of the
 * reply contains a value (>= 0) or an error code (<0).
 */
  int k;

  _M.m_type = syscallnr;
  k = sendrec(proc, &_M);
  if (k != 0) return(k);	/* send itself failed */
  if (_M.m_type < 0) {
	errno = -_M.m_type;
	return(-1);
  }
  return(_M.m_type);
}


PUBLIC int len(s)
_CONST register char *s;	/* character string whose length is needed */
{
/* Return the length of a character string, including the 0 at the end. */
  register int k;

  k = 0;
  while (*s++ != 0) k++;
  return(k + 1);		/* return length including the 0-byte at end */
}
