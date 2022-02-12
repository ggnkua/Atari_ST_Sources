#define _SYSTEM
#include <lib.h>
/*
 *	Library routines for Amoeba Transactions
 *	compile with cc -c -LIB -Di8088 amoeba.c
 */

#define	AMOEBA

#include <minix/com.h>
#include <amoeba.h>
#include <amparam.h>

PRIVATE unshort Timeout = 300;	/* default timeout = 30 seconds */

PRIVATE message mess;

PUBLIC unshort trans(h1, b1, c1, h2, b2, c2)
header *h1;
bufptr b1;
unshort c1;
header *h2;
bufptr b2;
unshort c2;
{
  int r;
  Trpar params;

/* Set up parameter block */
  params.tp_par[0].p_hdr = h1;
  params.tp_par[0].p_buf = b1;
  params.tp_par[0].p_cnt = c1;
  params.tp_par[1].p_hdr = h2;
  params.tp_par[1].p_buf = b2;
  params.tp_par[1].p_cnt = c2;
  params.tp_maxloc = Timeout;

/* Set up message to send to fileserver */
  mess.m_type = AM_SYSCALL;
  mess.AM_OP = AM_TRANS;
  mess.AM_ADDRESS = (char *) &params;
  mess.AM_COUNT = sizeof params;
  if ((r = sendrec(MM, &mess)) != OK) return (r);
  return((unshort) mess.m_type);
}


PUBLIC unshort getreq(h, b, c)
header *h;
bufptr b;
unshort c;
{
  int r;
  Trpar params;

/* Set up parameter block */
  params.tp_par[0].p_hdr = h;
  params.tp_par[0].p_buf = b;
  params.tp_par[0].p_cnt = c;

/* Set up message to send to fileserver */
  mess.m_type = AM_SYSCALL;
  mess.AM_OP = AM_GETREQ;
  mess.AM_ADDRESS = (char *) &params;
  mess.AM_COUNT = sizeof params;
  if ((r = sendrec(MM, &mess)) != OK) return (r);
  return((unshort) mess.m_type);
}


PUBLIC unshort putrep(h, b, c)
header *h;
bufptr b;
unshort c;
{
  int r;
  Trpar params;

/* Set up parameter block */
  params.tp_par[0].p_hdr = h;
  params.tp_par[0].p_buf = b;
  params.tp_par[0].p_cnt = c;

/* Set up message to send to fileserver */
  mess.m_type = AM_SYSCALL;
  mess.AM_OP = AM_PUTREP;
  mess.AM_ADDRESS = (char *) &params;
  mess.AM_COUNT = sizeof params;
  if ((r = sendrec(MM, &mess)) != OK) return (r);
  return((unshort) mess.m_type);
}


PUBLIC unshort timeout(t)	/* set locate timeout in milliseconds */
unshort t;
{
  unshort oldtimeout = Timeout;

  if (t >= 0) Timeout = t;
  return (oldtimeout);
}
