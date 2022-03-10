/*=============================================================================

                              HydraCom Version 1.00

                         A sample implementation of the
                   HYDRA Bi-Directional File Transfer Protocol

                             HydraCom was written by
                   Arjen G. Lentz, LENTZ SOFTWARE-DEVELOPMENT
                  COPYRIGHT (C) 1991-1993; ALL RIGHTS RESERVED

                       The HYDRA protocol was designed by
                 Arjen G. Lentz, LENTZ SOFTWARE-DEVELOPMENT and
                             Joaquim H. Homrighausen
                  COPYRIGHT (C) 1991-1993; ALL RIGHTS RESERVED


  Revision history:
  06 Sep 1991 - (AGL) First tryout
  .. ... .... - Internal development
  11 Jan 1993 - HydraCom version 1.00, Hydra revision 001 (01 Dec 1992)


  For complete details of the Hydra and HydraCom licensing restrictions,
  please refer to the license agreements which are published in their entirety
  in HYDRACOM.C and LICENSE.DOC, and also contained in the documentation file
  HYDRACOM.DOC

  Use of this file is subject to the restrictions contained in the Hydra and
  HydraCom licensing agreements. If you do not find the text of this agreement
  in any of the aforementioned files, or if you do not have these files, you
  should immediately contact LENTZ SOFTWARE-DEVELOPMENT and/or Joaquim 
  Homrighausen at one of the addresses listed below. In no event should you
  proceed to use this file without having accepted the terms of the Hydra and
  HydraCom licensing agreements, or such other agreement as you are able to
  reach with LENTZ SOFTWARE-DEVELOMENT and Joaquim Homrighausen.


  Hydra protocol design and HydraCom driver:         Hydra protocol design:
  Arjen G. Lentz                                     Joaquim H. Homrighausen
  LENTZ SOFTWARE-DEVELOPMENT                         389, route d'Arlon
  Langegracht 7B                                     L-8011 Strassen
  3811 BT  Amersfoort                                Luxembourg
  The Netherlands
  FidoNet 2:283/512, AINEX-BBS +31-33-633916         FidoNet 2:270/17
  arjen_lentz@f512.n283.z2.fidonet.org               joho@ae.lu

  Please feel free to contact us at any time to share your comments about our
  software and/or licensing policies.

=============================================================================*/

#include "hydracom.h"                             /* need 2types.h & hydra.h */


#define H_DEBUG 1


/* HYDRA Some stuff to aid readability of the source and prevent typos ----- */
#define h_updcrc16(crc,c)  (crc16tab[(       crc ^ (c)) & 0xff] ^ ((crc >> 8) & 0x00ff))
#define h_updcrc32(crc,c)  (crc32tab[((byte) crc ^ (c)) & 0xff] ^ ((crc >> 8) & 0x00ffffffL))
#define h_crc16poly        (0x8408)
#define h_crc32poly        (0xedb88320L)
#define h_crc16test(crc)   (((crc) == 0xf0b8     ) ? 1 : 0)
#define h_crc32test(crc)   (((crc) == 0xdebb20e3L) ? 1 : 0)
#define h_uuenc(c)         (((c) & 0x3f) + '!')
#define h_uudec(c)         (((c) - '!') & 0x3f)
#define h_long1(buf)       (*((long *) (buf)))
#define h_long2(buf)       (*((long *) ((buf) + ((int) sizeof (long)))))
#define h_long3(buf)       (*((long *) ((buf) + (2 * ((int) sizeof (long))))))
typedef long               h_timer;
#define h_timer_set(t)     (time(NULL) + (t))
#define h_timer_running(t) (t != 0L)
#define h_timer_expired(t) (time(NULL) > (t))
#define h_timer_reset()    (0L)


/* HYDRA's memory ---------------------------------------------------------- */
static  boolean originator;                     /* are we the orig side?     */
static  int     batchesdone;                    /* No. HYDRA batches done    */
static  boolean hdxlink;                        /* hdx link & not orig side  */
static  dword   options;                        /* INIT options hydra_init() */
static  word    timeout;                        /* general timeout in secs   */
static  char    abortstr[] = { 24,24,24,24,24,24,24,24,8,8,8,8,8,8,8,8,8,8,0 };
static  char   *hdxmsg     = "Fallback to one-way xfer";
static  char   *pktprefix  = "";
static  char   *autostr    = "hydra\r";
static  word   *crc16tab;                       /* CRC-16 table              */
static  dword  *crc32tab;                       /* CRC-32 table              */

static  byte   *txbuf,         *rxbuf;          /* packet buffers            */
static  dword   txoptions,      rxoptions;      /* HYDRA options (INIT seq)  */
static  char    txpktprefix[H_PKTPREFIX + 1];   /* pkt prefix str they want  */
static  long    txwindow,       rxwindow;       /* window size (0=streaming) */
static  h_timer                 braindead;      /* braindead timer           */
static  byte   *txbufin;                        /* read data from disk here  */
static  byte    txlastc;                        /* last byte put in txbuf    */
static  byte                    rxdle;          /* count of received H_DLEs  */
static  byte                    rxpktformat;    /* format of pkt receiving   */
static  byte                   *rxbufptr;       /* current position in rxbuf */
static  byte                   *rxbufmax;       /* highwatermark of rxbuf    */
static  char    txfname[13],    rxfname[13];    /* fname of current files    */
static  char                   *rxpathname;     /* pointer to rx pathname    */
static  long    txftime,        rxftime;        /* file timestamp (UNIX)     */
static  long    txfsize,        rxfsize;        /* file length               */
static  int     txfd,           rxfd;           /* file handles              */
static  word                    rxpktlen;       /* length of last packet     */
static  word                    rxblklen;       /* len of last good data blk */
static  byte    txstate,        rxstate;        /* xmit/recv states          */
static  long    txpos,          rxpos;          /* current position in files */
static  word    txblklen;                       /* length of last block sent */
static  word    txmaxblklen;                    /* max block length allowed  */
static  long    txlastack;                      /* last dataack received     */
static  long    txstart,        rxstart;        /* time we started this file */
static  long    txoffset,       rxoffset;       /* offset in file we begun   */
static  h_timer txtimer,        rxtimer;        /* retry timers              */
static  word    txretries,      rxretries;      /* retry counters            */
static  long                    rxlastsync;     /* filepos last sync retry   */
static  long    txsyncid,       rxsyncid;       /* id of last resync         */
static  word    txgoodneeded;                   /* to send before larger blk */
static  word    txgoodbytes;                    /* no. sent at this blk size */

struct _h_flags {
        char  *str;
        dword  val;
};

static struct _h_flags h_flags[] = {
        { "XON", HOPT_XONXOFF },
        { "TLN", HOPT_TELENET },
        { "CTL", HOPT_CTLCHRS },
        { "HIC", HOPT_HIGHCTL },
        { "HI8", HOPT_HIGHBIT },
        { "BRK", HOPT_CANBRK  },
        { "ASC", HOPT_CANASC  },
        { "UUE", HOPT_CANUUE  },
        { "C32", HOPT_CRC32   },
        { "DEV", HOPT_DEVICE  },
        { "FPT", HOPT_FPT     },
        { NULL , 0x0L         }
};


/*---------------------------------------------------------------------------*/
static void hydra_msgdev (byte *data, word len)
{       /* text is already NUL terminated by calling func hydra_devrecv() */
        len = len;
        message(3,"*HMSGDEV: %s",data);
}/*hydra_msgdev()*/


/*---------------------------------------------------------------------------*/
static  word    devtxstate;                     /* dev xmit state            */
static  h_timer devtxtimer;                     /* dev xmit retry timer      */
static  word    devtxretries;                   /* dev xmit retry counter    */
static  long    devtxid,        devrxid;        /* id of last devdata pkt    */
static  char    devtxdev[H_FLAGLEN + 1];        /* xmit device ident flag    */
static  byte   *devtxbuf;                       /* ptr to usersupplied dbuf  */
static  word    devtxlen;                       /* len of data in xmit buf   */

struct _h_dev {
        char  *dev;
        void (*func) (byte *data, word len);
};

static  struct _h_dev h_dev[] = {
        { "MSG", hydra_msgdev },                /* internal protocol msg     */
        { "CON", NULL         },                /* text to console (chat)    */
        { "PRN", NULL         },                /* data to printer           */
        { "ERR", NULL         },                /* text to error output      */
        { NULL , NULL         }
};


/*---------------------------------------------------------------------------*/
boolean hydra_devfree (void)
{
        if (devtxstate || !(txoptions & HOPT_DEVICE) || txstate >= HTX_END)
           return (false);                      /* busy or not allowed       */
        else
           return (true);                       /* allowed to send a new pkt */
}/*hydra_devfree()*/


/*---------------------------------------------------------------------------*/
boolean hydra_devsend (char *dev, byte *data, word len)
{
        if (!dev || !data || !len || !hydra_devfree())
           return (false);

        strncpy(devtxdev,dev,H_FLAGLEN);
        devtxdev[H_FLAGLEN] = '\0';
        strupr(devtxdev);
        devtxbuf = data;
        devtxlen = (len > H_MAXBLKLEN) ? H_MAXBLKLEN : len;

        devtxid++;
        devtxtimer   = h_timer_reset();
        devtxretries = 0;
        devtxstate   = HTD_DATA;

        /* special for chat, only prolong life if our side keeps typing! */
        if (chattimer > 0L && !strcmp(devtxdev,"CON") && txstate == HTX_REND)
           braindead = h_timer_set(H_BRAINDEAD);

        return (true);
}/*hydra_devsend()*/


/*---------------------------------------------------------------------------*/
boolean hydra_devfunc (char *dev, void (*func) (byte *data, word len))
{
        register int i;

        for (i = 0; h_dev[i].dev; i++) {
            if (!strnicmp(dev,h_dev[i].dev,H_FLAGLEN)) {
               h_dev[i].func = func;
               return (true);
            }
        }

        return (false);
}/*hydra_devfunc()*/


/*---------------------------------------------------------------------------*/
static void hydra_devrecv (void)
{
        register char *p = (char *) rxbuf;
        register int   i;
        word len = rxpktlen;

        p += (int) sizeof (long);                       /* skip the id long  */
        len -= (int) sizeof (long);
        for (i = 0; h_dev[i].dev; i++) {                /* walk through devs */
            if (!strncmp(p,h_dev[i].dev,H_FLAGLEN)) {
               if (h_dev[i].func) {
                  len -= ((int) strlen(p)) + 1;         /* sub devstr len    */
                  p += ((int) strlen(p)) + 1;           /* skip devtag       */
                  p[len] = '\0';                        /* NUL terminate     */
                  (*h_dev[i].func)((byte *) p,len);     /* call output func  */
               }
               break;
            }
        }
}/*hydra_devrecv()*/


/*---------------------------------------------------------------------------*/
static void put_flags (char *buf, struct _h_flags flags[], long val)
{
        register char *p;
        register int   i;

        p = buf;
        for (i = 0; flags[i].val; i++) {
            if (val & flags[i].val) {
               if (p > buf) *p++ = ',';
               strcpy(p,flags[i].str);
               p += H_FLAGLEN;
            }
        }
        *p = '\0';
}/*put_flags()*/


/*---------------------------------------------------------------------------*/
static dword get_flags (char *buf, struct _h_flags flags[])
{
        register dword  val;
        register char  *p;
        register int    i;

        val = 0x0L;
        for (p = strtok(buf,","); p; p = strtok(NULL,",")) {
            for (i = 0; flags[i].val; i++) {
                if (!strcmp(p,flags[i].str)) {
                   val |= flags[i].val;
                   break;
                }
            }
        }

        return (val);
}/*get_flags()*/


/*---------------------------------------------------------------------------*/
static word crc16block (register byte *buf, register word len)
{
        register word crc;

        for (crc = 0xffff; len > 0; len--)
            crc = h_updcrc16(crc,*buf++);
        return (crc);
}/*crc16block()*/


/*---------------------------------------------------------------------------*/
static dword crc32block (register byte *buf, register word len)
{
        register dword crc;

        for (crc = 0xffffffffL; len > 0; len--)
            crc = h_updcrc32(crc,*buf++);
        return (crc);
}/*crc32block()*/


/*---------------------------------------------------------------------------*/
static byte *put_binbyte (register byte *p, register byte c)
{
        register byte n;

        n = c;
        if (txoptions & HOPT_HIGHCTL)
           n &= 0x7f;

        if (n == H_DLE ||
            ((txoptions & HOPT_XONXOFF) && (n == XON || n == XOFF)) ||
            ((txoptions & HOPT_TELENET) && n == '\r' && txlastc == '@') ||
            ((txoptions & HOPT_CTLCHRS) && (n < 32 || n == 127))) {
           *p++ = H_DLE;
           c ^= 0x40;
        }

        *p++ = c;
        txlastc = n;

        return (p);
}/*put_binbyte()*/


/*---------------------------------------------------------------------------*/
static void txpkt (register word len, int type)
{
        register byte *in, *out;
        register word  c, n;
        boolean crc32 = false;
        byte    format;
        static char hexdigit[] = "0123456789abcdef";

        txbufin[len++] = type;

        switch (type) {
               case HPKT_START:
               case HPKT_INIT:
               case HPKT_INITACK:
               case HPKT_END:
               case HPKT_IDLE:
                    format = HCHR_HEXPKT;
                    break;

               default:
                    /* COULD do smart format selection depending on data and options! */
                    if (txoptions & HOPT_HIGHBIT) {
                       if ((txoptions & HOPT_CTLCHRS) && (txoptions & HOPT_CANUUE))
                          format = HCHR_UUEPKT;
                       else if (txoptions & HOPT_CANASC)
                          format = HCHR_ASCPKT;
                       else
                          format = HCHR_HEXPKT;
                    }
                    else
                       format = HCHR_BINPKT;
                    break;
        }

        if (format != HCHR_HEXPKT && (txoptions & HOPT_CRC32))
           crc32 = true;

#if H_DEBUG
if (loglevel==0) {
   char *s1, *s2, *s3, *s4;

   message(0," -> PKT (format='%c'  type='%c'  crc=%d  len=%d)",
             format, type, crc32 ? 32 : 16, len - 1);

   switch (type) {
          case HPKT_START:    message(0,"    <autostr>START");
                              break;
          case HPKT_INIT:     s1 = ((char *) txbufin) + ((int) strlen((char *) txbufin)) + 1;
                              s2 = s1 + ((int) strlen(s1)) + 1;
                              s3 = s2 + ((int) strlen(s2)) + 1;
                              s4 = s3 + ((int) strlen(s3)) + 1;
                              message(0,"    INIT (appinfo='%s'  can='%s'  want='%s'  options='%s'  pktprefix='%s')",
                                      (char *) txbufin, s1, s2, s3, s4);
                              break;
          case HPKT_INITACK:  message(0,"    INITACK");
                              break;
          case HPKT_FINFO:    message(0,"    FINFO (%s)",txbufin);
                              break;
          case HPKT_FINFOACK: if (rxfd >= 0) {
                                 if (rxpos > 0L) s1 = "RES";
                                 else            s1 = "BOF";
                              }
                              else if (rxpos == -1L) s1 = "HAVE";
                              else if (rxpos == -2L) s1 = "SKIP";
                              else                   s1 = "EOB";
                              message(0,"    FINFOACK (pos=%ld %s  rxstate=%d  rxfd=%d)",
                                      rxpos,s1,rxstate,rxfd);
                              break;
          case HPKT_DATA:     message(0,"    DATA (ofs=%ld  len=%d)",
                                      intell(h_long1(txbufin)), len - 5);
                              break;
          case HPKT_DATAACK:  message(0,"    DATAACK (ofs=%ld)",
                                      intell(h_long1(txbufin)));
                              break;
          case HPKT_RPOS:     message(0,"    RPOS (pos=%ld%s  blklen=%ld  syncid=%ld)",
                                      rxpos, rxpos < 0L ? " SKIP" : "",
                                      intell(h_long2(txbufin)), rxsyncid);
                              break;
          case HPKT_EOF:      message(0,"    EOF (ofs=%ld%s)",
                                      txpos, txpos < 0L ? " SKIP" : "");
                              break;
          case HPKT_EOFACK:   message(0,"    EOFACK");
                              break;
          case HPKT_IDLE:     message(0,"    IDLE");
                              break;
          case HPKT_END:      message(0,"    END");
                              break;
          case HPKT_DEVDATA:  message(0,"    DEVDATA (id=%ld  dev='%s'  len=%u)",
                                      devtxid, devtxdev, devtxlen);
                              break;
          case HPKT_DEVDACK:  message(0,"    DEVDACK (id=%ld)",
                                      intell(h_long1(rxbuf)));
                              break;
          default:            /* This couldn't possibly happen! ;-) */
                              break;
   }
}
#endif

        if (crc32) {
           dword crc = ~crc32block(txbufin,len);

           txbufin[len++] = crc;
           txbufin[len++] = crc >> 8;
           txbufin[len++] = crc >> 16;
           txbufin[len++] = crc >> 24;
        }
        else {
           word crc = ~crc16block(txbufin,len);

           txbufin[len++] = crc;
           txbufin[len++] = crc >> 8;
        }

        in = txbufin;
        out = txbuf;
        txlastc = 0;
        *out++ = H_DLE;
        *out++ = format;

        switch (format) {
               case HCHR_HEXPKT:
                    for (; len > 0; len--, in++) {
                        if (*in & 0x80) {
                           *out++ = '\\';
                           *out++ = hexdigit[((*in) >> 4) & 0x0f];
                           *out++ = hexdigit[(*in) & 0x0f];
                        }
                        else if (*in < 32 || *in == 127) {
                           *out++ = H_DLE;
                           *out++ = (*in) ^ 0x40;
                        }
                        else if (*in == '\\') {
                           *out++ = '\\';
                           *out++ = '\\';
                        }
                        else
                           *out++ = *in;
                    }
                    break;

               case HCHR_BINPKT:
                    for (; len > 0; len--)
                        out = put_binbyte(out,*in++);
                    break;

               case HCHR_ASCPKT:
                    for (n = c = 0; len > 0; len--) {
                        c |= ((*in++) << n);
                        out = put_binbyte(out,c & 0x7f);
                        c >>= 7;
                        if (++n >= 7) {
                           out = put_binbyte(out,c & 0x7f);
                           n = c = 0;
                        }
                    }
                    if (n > 0)
                       out = put_binbyte(out,c & 0x7f);
                    break;

               case HCHR_UUEPKT:
                    for ( ; len >= 3; in += 3, len -= 3) {
                        *out++ = h_uuenc(in[0] >> 2);
                        *out++ = h_uuenc(((in[0] << 4) & 0x30) | ((in[1] >> 4) & 0x0f));
                        *out++ = h_uuenc(((in[1] << 2) & 0x3c) | ((in[2] >> 6) & 0x03));
                        *out++ = h_uuenc(in[2] & 0x3f);
                    }
                    if (len > 0) {
                       *out++ = h_uuenc(in[0] >> 2);
                       *out++ = h_uuenc(((in[0] << 4) & 0x30) | ((in[1] >> 4) & 0x0f));
                       if (len == 2)
                          *out++ = h_uuenc((in[1] << 2) & 0x3c);
                    }
                    break;
        }

        *out++ = H_DLE;
        *out++ = HCHR_PKTEND;

        if (type != HPKT_DATA && format != HCHR_BINPKT) {
           *out++ = '\r';
           *out++ = '\n';
        }

        for (in = (byte *) txpktprefix; *in; in++) {
            switch (*in) {
                   case 221: /* transmit break signal for one second */
                             break;
                   case 222: { h_timer t = h_timer_set(2);
                               while (!h_timer_expired(t))
                                     sys_idle();
                             }
                             break;
                   case 223: com_putbyte(0);
                             break;
                   default:  com_putbyte(*in);
                             break;
            }
        }

        com_putblock(txbuf,(word) (out - txbuf));
}/*txpkt()*/


/*---------------------------------------------------------------------------*/
static int rxpkt (void)
{
        register byte *p, *q;
        register int   c, n, i;

        if (keyabort())
           return (H_SYSABORT);
        if (!carrier())
           return (H_CARRIER);

        p = rxbufptr;

        while ((c = com_getbyte()) >= 0) {
              if (rxoptions & HOPT_HIGHBIT)
                 c &= 0x7f;

              n = c;
              if (rxoptions & HOPT_HIGHCTL)
                 n &= 0x7f;
              if (n != H_DLE &&
                  (((rxoptions & HOPT_XONXOFF) && (n == XON || n == XOFF)) ||
                   ((rxoptions & HOPT_CTLCHRS) && (n < 32 || n == 127))))
                 continue;

              if (rxdle || c == H_DLE) {
                 switch (c) {
                        case H_DLE:
                             if (++rxdle >= 5)
                                return (H_CANCEL);
                             break;

                        case HCHR_PKTEND:
                             rxbufptr = p;

                             switch (rxpktformat) {
                                    case HCHR_BINPKT:
                                         q = rxbufptr;
                                         break;

                                    case HCHR_HEXPKT:
                                         for (p = q = rxbuf; p < rxbufptr; p++) {
                                             if (*p == '\\' && *++p != '\\') {
                                                i = *p;
                                                n = *++p;
                                                if ((i -= '0') > 9) i -= ('a' - ':');
                                                if ((n -= '0') > 9) n -= ('a' - ':');
                                                if ((i & ~0x0f) || (n & ~0x0f)) {
                                                   i = H_NOPKT;
                                                   break;
                                                }
                                                *q++ = (i << 4) | n;
                                             }
                                             else
                                                *q++ = *p;
                                         }
                                         if (p > rxbufptr)
                                            c = H_NOPKT;
                                         break;

                                    case HCHR_ASCPKT:
                                         n = i = 0;
                                         for (p = q = rxbuf; p < rxbufptr; p++) {
                                             i |= ((*p & 0x7f) << n);
                                             if ((n += 7) >= 8) {
                                                *q++ = (byte) (i & 0xff);
                                                i >>= 8;
                                                n -= 8;
                                             }
                                         }
                                         break;

                                    case HCHR_UUEPKT:
                                         n = (int) (rxbufptr - rxbuf);
                                         for (p = q = rxbuf; n >= 4; n -= 4, p += 4) {
                                             if (p[0] <= ' ' || p[0] >= 'a' ||
                                                 p[1] <= ' ' || p[1] >= 'a' ||
                                                 p[2] <= ' ' || p[2] >= 'a') {
                                                c = H_NOPKT;
                                                break;
                                             }
                                             *q++ = (byte) ((h_uudec(p[0]) << 2) | (h_uudec(p[1]) >> 4));
                                             *q++ = (byte) ((h_uudec(p[1]) << 4) | (h_uudec(p[2]) >> 2));
                                             *q++ = (byte) ((h_uudec(p[2]) << 6) | h_uudec(p[3]));
                                         }
                                         if (n >= 2) {
                                            if (p[0] <= ' ' || p[0] >= 'a') {
                                               c = H_NOPKT;
                                               break;
                                            }
                                            *q++ = (byte) ((h_uudec(p[0]) << 2) | (h_uudec(p[1]) >> 4));
                                            if (n == 3) {
                                               if (p[0] <= ' ' || p[0] >= 'a') {
                                                  c = H_NOPKT;
                                                  break;
                                               }
                                               *q++ = (byte) ((h_uudec(p[1]) << 4) | (h_uudec(p[2]) >> 2));
                                            }
                                         }
                                         break;

                                    default:   /* This'd mean internal fluke */
#if H_DEBUG
if (loglevel==0) {
   message(0," <- <PKTEND> (pktformat='%c' dec=%d hex=%02x) ??",
             rxpktformat, rxpktformat, rxpktformat);
}
#endif
                                         c = H_NOPKT;
                                         break;
                             }

                             rxbufptr = NULL;

                             if (c == H_NOPKT)
                                break;

                             rxpktlen = (word) (q - rxbuf);
                             if (rxpktformat != HCHR_HEXPKT && (rxoptions & HOPT_CRC32)) {
                                if (rxpktlen < 5) {
                                   c = H_NOPKT;
                                   break;
                                }
                                n = h_crc32test(crc32block(rxbuf,rxpktlen));
                                rxpktlen -= (int) sizeof (long);  /* remove CRC-32 */
                             }
                             else {
                                if (rxpktlen < 3) {
                                   c = H_NOPKT;
                                   break;
                                }
                                n = h_crc16test(crc16block(rxbuf,rxpktlen));
                                rxpktlen -= (int) sizeof (word);  /* remove CRC-16 */
                             }

                             rxpktlen--;                     /* remove type  */

                             if (n) {
#if H_DEBUG
if (loglevel==0) {
   char *s1, *s2, *s3, *s4;

   message(0," <- PKT (format='%c'  type='%c'  len=%d)",
           rxpktformat, (int) rxbuf[rxpktlen], rxpktlen);

   switch (rxbuf[rxpktlen]) {
          case HPKT_START:    message(0,"    START");
                              break;
          case HPKT_INIT:     s1 = ((char *) rxbuf) + ((int) strlen((char *) rxbuf)) + 1;
                              s2 = s1 + ((int) strlen(s1)) + 1;
                              s3 = s2 + ((int) strlen(s2)) + 1;
                              s4 = s3 + ((int) strlen(s3)) + 1;
                              message(0,"    INIT (appinfo='%s'  can='%s'  want='%s'  options='%s'  pktprefix='%s')",
                                      (char *) rxbuf, s1, s2, s3, s4);
                              break;
          case HPKT_INITACK:  message(0,"    INITACK");
                              break;
          case HPKT_FINFO:    message(0,"    FINFO ('%s'  rxstate=%d)",rxbuf,rxstate);
                              break;
          case HPKT_FINFOACK: message(0,"    FINFOACK (pos=%ld  txstate=%d  txfd=%d)",
                                      intell(h_long1(rxbuf)), txstate, txfd);
                              break;
          case HPKT_DATA:     message(0,"    DATA (rxstate=%d  pos=%ld  len=%u)",
                                      rxstate, intell(h_long1(rxbuf)),
                                      (word) (rxpktlen - ((int) sizeof (long))));
                              break;
          case HPKT_DATAACK:  message(0,"    DATAACK (rxstate=%d  pos=%ld)",
                                      rxstate, intell(h_long1(rxbuf)));
                              break;
          case HPKT_RPOS:     message(0,"    RPOS (pos=%ld%s  blklen=%u->%ld  syncid=%ld%s  txstate=%d  txfd=%d)",
                                      intell(h_long1(rxbuf)),
                                      intell(h_long1(rxbuf)) < 0L ? " SKIP" : "",
                                      txblklen, intell(h_long2(rxbuf)),
                                      intell(h_long3(rxbuf)),
                                      intell(h_long3(rxbuf)) == rxsyncid ? " DUP" : "",
                                      txstate, txfd);
                              break;
          case HPKT_EOF:      message(0,"    EOF (rxstate=%d  pos=%ld%s)",
                                      rxstate, intell(h_long1(rxbuf)),
                                      intell(h_long1(rxbuf)) < 0L ? " SKIP" : "");
                              break;
          case HPKT_EOFACK:   message(0,"    EOFACK (txstate=%d)", txstate);
                              break;
          case HPKT_IDLE:     message(0,"    IDLE");
                              break;
          case HPKT_END:      message(0,"    END");
                              break;
          case HPKT_DEVDATA:  s1 = ((char *) rxbuf) + ((int) sizeof (long));
                              message(0,"    DEVDATA (id=%ld  dev=%s  len=%u",
                                      intell(h_long1(rxbuf)), s1,
                                      rxpktlen - (((int) sizeof (long)) + ((int) strlen(s1)) + 1));
                              break;
          case HPKT_DEVDACK:  message(0,"    DEVDACK (devtxstate=%d  id=%ld)",
                                      devtxstate, intell(h_long1(rxbuf)));
                              break;
          default:            message(0,"    Unkown pkttype %d (txstate=%d  rxstate=%d)",
                                      (int) rxbuf[rxpktlen], txstate, rxstate);
                              break;
   }
}
#endif
                                return ((int) rxbuf[rxpktlen]);
                             }/*goodpkt*/

#if H_DEBUG
if (loglevel==0)
   message(0," Bad CRC (format='%c'  type='%c'  len=%d)",
             rxpktformat, (int) rxbuf[rxpktlen], rxpktlen);
#endif
                             break;

                        case HCHR_BINPKT: 
                        case HCHR_HEXPKT: 
                        case HCHR_ASCPKT: 
                        case HCHR_UUEPKT:
#if H_DEBUG
if (loglevel==0)
   message(0," <- <PKTSTART> (pktformat='%c')",c);
#endif
                             rxpktformat = c;
                             p = rxbufptr = rxbuf;
                             rxdle = 0;
                             break;

                        default:
                             if (p) {
                                if (p < rxbufmax)
                                   *p++ = (byte) (c ^ 0x40);
                                else {
#if H_DEBUG
if (loglevel==0)
   message(0," <- Pkt too long - discarded");
#endif
                                   p = NULL;
                                }
                             }
                             rxdle = 0;
                             break;
                 }
              }
              else if (p) {
                 if (p < rxbufmax)
                    *p++ = (byte) c;
                 else {
#if H_DEBUG
if (loglevel==0)
   message(0," <- Pkt too long - discarded");
#endif
                    p = NULL;
                 }
              }
        }

        rxbufptr = p;

        if (h_timer_running(braindead) && h_timer_expired(braindead)) {
#if H_DEBUG
if (loglevel==0)
   message(0," <- BrainDead (timer=%08lx  time=%08lx)",
           braindead,time(NULL));
#endif
           return (H_BRAINTIME);
        }
        if (h_timer_running(txtimer) && h_timer_expired(txtimer)) {
#if H_DEBUG
if (loglevel==0)
   message(0," <- TxTimer (timer=%08lx  time=%08lx)",
           txtimer,time(NULL));
#endif
           return (H_TXTIME);
        }
        if (h_timer_running(devtxtimer) && h_timer_expired(devtxtimer)) {
#if H_DEBUG
if (loglevel==0)
   message(0," <- DevTxTimer (timer=%08lx  time=%08lx)",
           devtxtimer,time(NULL));
#endif
           return (H_DEVTXTIME);
        }

        sys_idle();
        return (H_NOPKT);
}/*rxpkt()*/


/*---------------------------------------------------------------------------*/
static void hydra_status (boolean xmit)
{
        long pos    = xmit ? txpos    : rxpos,
             fsize  = xmit ? txfsize  : rxfsize;

        hydra_gotoxy(46,xmit ? 1 : 2);
        if (pos >= fsize)
           hydra_printf("%ld/%ld (EOF)",pos,fsize);
        else {
           int left = (int) ((((fsize - pos) / 128L) * 1340L) / cur_speed);
           char *p = "";

           if (xmit) {
              if      (txstate == HTX_DATAACK) p = "ACK ";
              else if (txstate == HTX_XWAIT)   p = "WAIT ";
           }
           hydra_printf("%ld/%ld (%s%d:%02d min left)",
                        pos, fsize, p, left / 60, left % 60);
        }
        hydra_clreol();
}/*hydra_status()*/


/*---------------------------------------------------------------------------*/
static void hydra_pct (boolean xmit)
{
        long offset = xmit ? txoffset : rxoffset,
             fsize  = xmit ? txfsize  : rxfsize,
             start  = xmit ? txstart  : rxstart,
             elapsed, bytes, cps, pct;

        elapsed = time(NULL) - start;
        bytes = fsize - offset;
        if (bytes < 1024L || elapsed == 0L)
           return;
        cps = bytes / elapsed;
        pct = (cps * 1000L) / ((long) cur_speed);
        message(2,"+%s-H CPS: %ld (%ld bytes), %d:%02d min.  Eff: %ld%%",
                xmit ? "Sent" : "Rcvd", cps, bytes,
                (int) (elapsed / 60), (int) (elapsed % 60), pct);
}/*hydra_pct()*/


/*---------------------------------------------------------------------------*/
void hydra_badxfer (void)
{
        if (rxfd >= 0) {
           dos_close(rxfd);
           rxfd = -1;
           if (xfer_bad())
              message(1,"+HRECV: Bad xfer recovery-info saved");
           else
              message(0,"-HRECV: Bad xfer - file deleted");
        }
}/*hydra_badxfer()*/


/*---------------------------------------------------------------------------*/
void hydra_init (dword want_options)
{
        register word i, j;
        word  crc16;
        dword crc32;

        txbuf    = (byte *)  malloc(H_BUFLEN);
        rxbuf    = (byte *)  malloc(H_BUFLEN);
        crc16tab = (word *)  malloc(256 * ((int) sizeof (word)));
        crc32tab = (dword *) malloc(256 * ((int) sizeof (dword)));
        if (!txbuf || !rxbuf || !crc16tab || !crc32tab) {
           message(6,"!HYDRA: Can't allocate buffers!");
           endprog(2);
        }
        txbufin  = txbuf + ((H_MAXBLKLEN + H_OVERHEAD + 5) * 2);
        rxbufmax = rxbuf + H_MAXPKTLEN;

        for (i = 0; i < 256; i++) {
            crc16 = i;
            crc32 = i;
            for (j = 8; j > 0; j--) {
                if (crc16 & 1) crc16 = (crc16 >> 1) ^ h_crc16poly;
                else           crc16 >>= 1;
                if (crc32 & 1) crc32 = (crc32 >> 1) ^ h_crc32poly;
                else           crc32 >>= 1;
            }
            crc16tab[i] = crc16;
            crc32tab[i] = crc32;
        }

        batchesdone = 0;

        originator = nooriginator ? false : true;

        if (originator)
           hdxlink = false;
        else if (hdxsession)
           hdxlink = true;

        options = (want_options & HCAN_OPTIONS) & ~HUNN_OPTIONS;

        timeout = (word) (40960L / cur_speed);
        if      (timeout < H_MINTIMER) timeout = H_MINTIMER;
        else if (timeout > H_MAXTIMER) timeout = H_MAXTIMER;

        txmaxblklen = (cur_speed / 300) * 128;
        if      (txmaxblklen < 256)         txmaxblklen = 256;
        else if (txmaxblklen > H_MAXBLKLEN) txmaxblklen = H_MAXBLKLEN;

        rxblklen = txblklen = (cur_speed < 2400U) ? 256 : 512;

        txgoodbytes  = 0;
        txgoodneeded = 1024;

        txstate = HTX_DONE;

        if (!mailer)
           message(-1,"+HYDRA session (%s-directional mode)",
                      hdxlink ? "Uni" : "Bi");

#if WIN_AGL
{ byte ev   = win_maxver - 25,          /* extra lines available vertically? */
       elog = ev / 3,                   /* 1/3 of extra lines for log_win    */
       eloc = ev / 3,                   /* 1/3 of extra lines for local_win  */
       erem = ev - (elog + eloc);       /* the rest is extra for remote_win  */

        log_win = win_create(1, 1, win_maxhor, 6 + elog,
                              CUR_NONE, CON_RAW | CON_WRAP | CON_SCROLL,
                              CHR_NORMAL, KEY_RAW);
        win_setattrib(log_win,CHR_INVERSE);
        win_clreol(log_win);
        win_printf(log_win," %s v%s - COPYRIGHT (C) 1991-1993 A.G.Lentz, LENTZ SOFTWARE-DEVELOPMENT",PRGNAME,VERSION);
        win_setattrib(log_win,CHR_NORMAL);
        win_setrange(log_win,1,2,win_maxhor,6 + elog);

        file_win = win_create(1, 7 + elog, win_maxhor, 9 + elog,
                              CUR_NONE, CON_RAW, CHR_NORMAL, KEY_RAW);
        win_setattrib(file_win,CHR_INVERSE);
        win_clreol(file_win);
        win_printf(file_win," Port=%u   ComSpeed=%u   LineSpeed=%u",
                            port + 1, com_speed, cur_speed);
        win_xyputs(file_win,48,1,"Press ESC to abort Hydra session");
        win_setattrib(file_win,CHR_F_YELLOW);
        win_xyputs(file_win,2,2,"Sending  :");
        win_xyputs(file_win,2,3,"Receiving:");
        win_setattrib(file_win,CHR_NORMAL);
        win_setrange(file_win,1,2,win_maxhor,3);

        remote_win = win_create(1, 10 + elog, win_maxhor, 17 + elog + erem,
                                CUR_NONE, CON_COOKED | CON_WRAP | CON_SCROLL,
                                CHR_NORMAL, KEY_RAW);
        win_setattrib(remote_win,CHR_INVERSE);
        win_fill(remote_win,177);
        win_puts(remote_win," Remote ");
        win_setattrib(remote_win,CHR_NORMAL);
        win_setrange(remote_win,1,2,win_maxhor,8 + erem);
        win_cls(remote_win);

        local_win = win_create(1, 18 + elog + erem, win_maxhor, win_maxver,
                               CUR_NORMAL, CON_COOKED | CON_WRAP | CON_SCROLL,
                               CHR_NORMAL, KEY_RAW);
        win_setattrib(local_win,CHR_INVERSE);
        win_fill(local_win,177);
        win_puts(local_win," Local (Press Alt-C to start/end chat mode) ");
        win_setattrib(local_win,CHR_NORMAL);
        win_setrange(local_win,1,2,win_maxhor,8 + eloc);
        win_cls(local_win);

        log_first = false;

        win_settop(log_win);
        win_settop(file_win);
        win_settop(remote_win);
        win_settop(local_win);
}
#else
{ struct text_info ti;

        term_x = wherex();
        term_y = wherey();
        gettextinfo(&ti);
        window(1,1,ti.screenwidth,ti.screenheight);
        term_scr = malloc(ti.screenwidth * ti.screenheight * sizeof (word));
        gettext(1,1,ti.screenwidth,ti.screenheight,term_scr);

        clrscr();
        textbackground(LIGHTGRAY);
        textcolor(BLACK);

        gotoxy(1,1);
        clreol();
        cprintf(" %s v%s - COPYRIGHT (C) 1991-1993 A.G.Lentz, LENTZ SOFTWARE-DEVELOPMENT",PRGNAME,VERSION);

        gotoxy(1,7);
        clreol();
        cprintf(" Port=%u   ComSpeed=%u   LineSpeed=%u",
                port + 1, com_speed, cur_speed);
        gotoxy(48,7);
        cprintf("Press ESC to abort Hydra session");

        gotoxy(1,10);
        for (i = 0; i < ti.screenwidth; i++) putch(177);
        gotoxy(1,10);
        cprintf(" Remote ");

        gotoxy(1,18);
        for (i = 0; i < ti.screenwidth; i++) putch(177);
        gotoxy(1,18);
        cprintf(" Local (Press Alt-C to start/end chat mode) ");

        textbackground(BLACK);
        textcolor(YELLOW);
        gotoxy(2,8);
        cprintf("Sending  :");
        gotoxy(2,9);
        cprintf("Receiving:");

        window(1,19,80,25);
        textcolor(LIGHTGRAY);
        file_x = file_y = remote_x = remote_y = local_x = local_y = 1;
        log_y = 0;
}
#endif

        hydra_devfunc("CON",rem_chat);

        chatfill  = 0;
        chattimer = -1L;
        lasttimer = 0L;

        message(2,"+HYDRA session (%s-directional mode)",
                  hdxlink ? "Uni" : "Bi");
}/*hydra_init()*/


/*---------------------------------------------------------------------------*/
void hydra_deinit (void)
{
#if WIN_AGL
        win_settop(0);
        win_close(file_win);
        win_close(log_win);
        win_close(remote_win);
        win_close(local_win);
        file_win = 0;
#else
{ struct text_info ti;

        gettextinfo(&ti);
        window(1,1,ti.screenwidth,ti.screenheight);
        puttext(1,1,ti.screenwidth,ti.screenheight,term_scr);
        gotoxy(term_x,term_y);
        free(term_scr);
        file_x = 0;
}
#endif

        free(txbuf);
        free(rxbuf);
        free(crc16tab);
        free(crc32tab);
}/*hydra_deinit()*/


/*---------------------------------------------------------------------------*/
int hydra (char *txpathname, char *txalias)
{
        int   res;
        int   pkttype;
        char *p, *q;
        int   i;
        struct stat f;

        /*-------------------------------------------------------------------*/
        if (txstate == HTX_DONE) {
           txstate        = HTX_START;
           hydra_gotoxy(13,1);
           hydra_printf("Init");
           txoptions      = HTXI_OPTIONS;
           txpktprefix[0] = '\0';

           rxstate   = HRX_INIT;
           hydra_gotoxy(13,2);
           hydra_printf("Init");
           rxoptions = HRXI_OPTIONS;
           rxfd      = -1;
           rxdle     = 0;
           rxbufptr  = NULL;
           rxtimer   = h_timer_reset();

           devtxid    = devrxid = 0L;
           devtxtimer = h_timer_reset();
           devtxstate = HTD_DONE;

           braindead = h_timer_set(H_BRAINDEAD);
        }
        else
           txstate = HTX_FINFO;

        txtimer   = h_timer_reset();
        txretries = 0;

        /*-------------------------------------------------------------------*/
        if (txpathname) {
           stat(txpathname,&f);
           txfsize = f.st_size;
           txftime = f.st_mtime;

           if ((txfd = dos_sopen(txpathname,0)) < 0) {
              message(3,"-HSEND: Unable to open %s",txpathname);
              return (XFER_SKIP);
           }

           strupr(txpathname);
           for (p=txpathname, q=txfname; *p; p++) {
               if (*q=*p, *p=='\\' || *p==':' || *p=='/')
                  q=txfname;
               else q++;
           }
           *q = '\0';

           if (txalias)
              strupr(txalias);

           txstart  = 0L;
           txsyncid = 0L;
        }
        else {
           txfd = -1;
           strcpy(txfname,"");
        }

        /*-------------------------------------------------------------------*/
        do {
           /*----------------------------------------------------------------*/
           switch (devtxstate) {
                  /*---------------------------------------------------------*/
                  case HTD_DATA:
                       if (txstate > HTX_RINIT) {
                          h_long1(txbufin) = intell(devtxid);
                          p = ((char *) txbufin) + ((int) sizeof(long));
                          strcpy(p,devtxdev);
                          p += H_FLAGLEN + 1;
                          memcpy(p,devtxbuf,devtxlen);
                          txpkt(((int) sizeof (long)) + H_FLAGLEN + 1 + devtxlen,HPKT_DEVDATA);
                          devtxtimer = h_timer_set(timeout);
                          devtxstate = HTD_DACK;
                       }
                       break;

                  /*---------------------------------------------------------*/
                  default:
                       break;

                  /*---------------------------------------------------------*/
           }

           /*----------------------------------------------------------------*/
           switch (txstate) {
                  /*---------------------------------------------------------*/
                  case HTX_START:
                       com_putblock((byte *) autostr,(int) strlen(autostr));
                       txpkt(0,HPKT_START);
                       txtimer = h_timer_set(H_START);
                       txstate = HTX_SWAIT;
                       break;

                  /*---------------------------------------------------------*/
                  case HTX_INIT:
                       p = (char *) txbufin;
                       sprintf(p,"%08lx%s,%s %s",
                                 H_REVSTAMP,PRGNAME,VERSION,HC_OS);
                       p += ((int) strlen(p)) + 1;/* our app info & HYDRA rev. */
                       put_flags(p,h_flags,HCAN_OPTIONS);    /* what we CAN  */
                       p += ((int) strlen(p)) + 1;
                       put_flags(p,h_flags,options);         /* what we WANT */
                       p += ((int) strlen(p)) + 1;
                       sprintf(p,"%08lx%08lx",               /* TxRx windows */
                                 hydra_txwindow,hydra_rxwindow);
                       p += ((int) strlen(p)) + 1;
                       strcpy(p,pktprefix);     /* pkt prefix string we want */
                       p += ((int) strlen(p)) + 1;

                       txoptions = HTXI_OPTIONS;
                       txpkt((word) (((byte *) p) - txbufin), HPKT_INIT);
                       txoptions = rxoptions;
                       txtimer = h_timer_set(timeout / 2);
                       txstate = HTX_INITACK;
                       break;

                  /*---------------------------------------------------------*/
                  case HTX_FINFO:
                       if (txfd >= 0) {
                          if (!txretries) {
                             hydra_gotoxy(13,1);
                             hydra_printf(txfname);
                             if (txalias) {
                                hydra_gotoxy(25,1);
                                hydra_printf("  ->  %s",txalias);
                             }
                             hydra_clreol();
                             message(2,"+HSEND: %s%s%s (%ldb), %d min.",
                                     txpathname, txalias ? " -> " : "", txalias ? txalias : "",
                                     txfsize, (int) (txfsize * 10L / cur_speed + 27L) / 54L);

                             strlwr(txfname);
                          }
                          sprintf((char *) txbufin,"%08lx%08lx%08lx%08lx%08lx%s",
                                  txftime, txfsize, 0L, 0L, 0L,
                                  txalias ? txalias : txfname);
                       }
                       else {
                          if (!txretries) {
                             hydra_gotoxy(13,1);
                             hydra_printf("End of batch");
                             hydra_clreol();
                             message(1,"+HSEND: End of batch");
                          }
                          strcpy((char *) txbufin,txfname);
                       }
                       txpkt(((int) strlen((char *) txbufin)) + 1,HPKT_FINFO);
                       txtimer = h_timer_set(txretries ? timeout / 2 : timeout);
                       txstate = HTX_FINFOACK;
                       break;

                  /*---------------------------------------------------------*/
                  case HTX_XDATA:
                       if (com_outfull() > txmaxblklen)
                          break;

                       if (txpos < 0L)
                          i = -1;                                    /* Skip */
                       else {
                          h_long1(txbufin) = intell(txpos);
                          if ((i = dos_read(txfd,txbufin + ((int) sizeof (long)),txblklen)) < 0) {
                             message(6,"!HSEND: File read error");
                             dos_close(txfd);
                             txfd = -1;
                             txpos = -2L;                            /* Skip */
                          }
                       }

                       if (i > 0) {
                          txpos += i;
                          txpkt(((int) sizeof (long)) + i, HPKT_DATA);

                          if (txblklen < txmaxblklen &&
                              (txgoodbytes += i) >= txgoodneeded) {
                             txblklen <<= 1;
                             if (txblklen >= txmaxblklen) {
                                txblklen = txmaxblklen;
                                txgoodneeded = 0;
                             }
                             txgoodbytes = 0;
                          }

                          if (txwindow && (txpos >= (txlastack + txwindow))) {
                             txtimer = h_timer_set(txretries ? timeout / 2 : timeout);
                             txstate = HTX_DATAACK;
                          }

                          if (!txstart)
                             txstart = time(NULL);
                          hydra_status(true);
                          break;
                       }

                       /* fallthrough to HTX_EOF */

                  /*---------------------------------------------------------*/
                  case HTX_EOF:
                       h_long1(txbufin) = intell(txpos);
                       txpkt((int) sizeof (long),HPKT_EOF);
                       txtimer = h_timer_set(txretries ? timeout / 2 : timeout);
                       txstate = HTX_EOFACK;
                       break;

                  /*---------------------------------------------------------*/
                  case HTX_END:
                       txpkt(0,HPKT_END);
                       txpkt(0,HPKT_END);
                       txtimer = h_timer_set(timeout / 2);
                       txstate = HTX_ENDACK;
                       break;

                  /*---------------------------------------------------------*/
                  default:
                       break;

                  /*---------------------------------------------------------*/
           }

           /*----------------------------------------------------------------*/
           while (txstate && (pkttype = rxpkt()) != H_NOPKT) {
                 /*----------------------------------------------------------*/
                 switch (pkttype) {
                        /*---------------------------------------------------*/
                        case H_CARRIER:
                        case H_CANCEL:
                        case H_SYSABORT:
                        case H_BRAINTIME:
                             switch (pkttype) {
                                    case H_CARRIER:   p = "Carrier lost";          break;
                                    case H_CANCEL:    p = "Aborted by other side"; break;
                                    case H_SYSABORT:  p = "Aborted by operator";   break;
                                    case H_BRAINTIME: p = "Other end died";        break;
                             }
                             message(3,"-HYDRA: %s",p);
                             txstate = HTX_DONE;
                             res = XFER_ABORT;
                             break;

                        /*---------------------------------------------------*/
                        case H_TXTIME:
                             if (txstate == HTX_XWAIT || txstate == HTX_REND) {
                                txpkt(0,HPKT_IDLE);
                                txtimer = h_timer_set(H_IDLE);
                                break;
                             }

                             if (++txretries > H_RETRIES) {
                                message(3,"-HSEND: Too many errors");
                                txstate = HTX_DONE;
                                res = XFER_ABORT;
                                break;
                             }

                             message(0,"-HSEND: Timeout - Retry %u",txretries);

                             txtimer = h_timer_reset();

                             switch (txstate) {
                                    case HTX_SWAIT:    txstate = HTX_START; break;
                                    case HTX_INITACK:  txstate = HTX_INIT;  break;
                                    case HTX_FINFOACK: txstate = HTX_FINFO; break;
                                    case HTX_DATAACK:  txstate = HTX_XDATA; break;
                                    case HTX_EOFACK:   txstate = HTX_EOF;   break;
                                    case HTX_ENDACK:   txstate = HTX_END;   break;
                             }
                             break;

                        /*---------------------------------------------------*/
                        case H_DEVTXTIME:
                             if (++devtxretries > H_RETRIES) {
                                message(3,"-HDEVTX: Too many errors");
                                txstate = HTX_DONE;
                                res = XFER_ABORT;
                                break;
                             }

                             message(0,"-HDEVTX: Timeout - Retry %u",devtxretries);

                             devtxtimer = h_timer_reset();
                             devtxstate = HTD_DATA;
                             break;

                        /*---------------------------------------------------*/
                        case HPKT_START:
                             if (txstate == HTX_START || txstate == HTX_SWAIT) {
                                txtimer = h_timer_reset();
                                txretries = 0;
                                txstate = HTX_INIT;
                                braindead = h_timer_set(H_BRAINDEAD);
                             }
                             break;

                        /*---------------------------------------------------*/
                        case HPKT_INIT:
                             if (rxstate == HRX_INIT) {
                                p = (char *) rxbuf;
                                p += ((int) strlen(p)) + 1;
                                q = p + ((int) strlen(p)) + 1;
                                rxoptions  = options | HUNN_OPTIONS;
                                rxoptions |= get_flags(q,h_flags);
                                rxoptions &= get_flags(p,h_flags);
                                rxoptions &= HCAN_OPTIONS;
                                if (rxoptions < (options & HNEC_OPTIONS)) {
                                   message(6,"!HYDRA: Incompatible on this link");
                                   txstate = HTX_DONE;
                                   res = XFER_ABORT;
                                   break;
                                }
                                p = q + ((int) strlen(q)) + 1;
                                rxwindow = txwindow = 0L;
                                sscanf(p,"%08lx%08lx", &rxwindow,&txwindow);
                                if (rxwindow < 0L) rxwindow = 0L;
                                if (hydra_rxwindow &&
                                    (!rxwindow || hydra_rxwindow < rxwindow))
                                   rxwindow = hydra_rxwindow;
                                if (txwindow < 0L) txwindow = 0L;
                                if (hydra_txwindow &&
                                    (!txwindow || hydra_txwindow < txwindow))
                                   txwindow = hydra_txwindow;
                                p += ((int) strlen(p)) + 1;
                                strncpy(txpktprefix,p,H_PKTPREFIX);
                                txpktprefix[H_PKTPREFIX] = '\0';

                                if (!batchesdone) {
                                   long revstamp;

                                   p = (char *) rxbuf;
                                   sscanf(p,"%08lx",&revstamp);
                                   message(0,"*HYDRA: Other's HydraRev=%s",
                                           h_revdate(revstamp));
                                   p += 8;
                                   if ((q = strchr(p,',')) != NULL) *q = ' ';
                                   if ((q = strchr(p,',')) != NULL) *q = '/';
                                   message(0,"*HYDRA: Other's App.Info '%s'",p);
                                   put_flags((char *) rxbuf,h_flags,rxoptions);
                                   message(1,"*HYDRA: Using link options '%s'",rxbuf);
                                   if (txwindow || rxwindow)
                                      message(0,"*HYDRA: Window tx=%ld rx=%ld",
                                                txwindow,rxwindow);
                                }

                                chattimer = (rxoptions & HOPT_DEVICE) ? 0L : -2L;

                                txoptions = rxoptions;
                                rxstate = HRX_FINFO;
                             }

                             txpkt(0,HPKT_INITACK);
                             break;

                        /*---------------------------------------------------*/
                        case HPKT_INITACK:
                             if (txstate == HTX_INIT || txstate == HTX_INITACK) {
                                braindead = h_timer_set(H_BRAINDEAD);
                                txtimer = h_timer_reset();
                                txretries = 0;
                                txstate = HTX_RINIT;
                             }
                             break;

                        /*---------------------------------------------------*/
                        case HPKT_FINFO:
                             if (rxstate == HRX_FINFO) {
                                braindead = h_timer_set(H_BRAINDEAD);
                                if (!rxbuf[0]) {
                                   hydra_gotoxy(13,2);
                                   hydra_printf("End of batch");
                                   hydra_clreol();
                                   message(1,"*HRECV: End of batch");
                                   rxpos = 0L;
                                   rxstate = HRX_DONE;
                                   batchesdone++;
                                }
                                else {
                                   long diskfree;

                                   rxfsize = rxftime = 0L;
                                   rxfname[0] = '\0';
                                   sscanf((char *) rxbuf,"%08lx%08lx%*08lx%*08lx%*08lx%s",
                                          &rxftime, &rxfsize, rxfname);
                                   strupr(rxfname);

                                   hydra_gotoxy(13,2);
                                   hydra_printf(rxfname);
                                   hydra_clreol();

                                   rxpathname = xfer_init(rxfname,rxfsize,rxftime);

                                   diskfree = freespace(rxpathname);

                                   if (!rxpathname) {   /* Already have file */
                                      if (single_done) {
                                         hydra_gotoxy(29,2);
                                         hydra_printf("Skipping additional files");
                                         message(1,"+HRECV: Skipping additional files (file %s)",rxfname);
                                         rxpos = -2L;
                                      }
                                      else {
                                         hydra_gotoxy(29,2);
                                         hydra_printf("Already have file");
                                         message(1,"+HRECV: Already have %s",rxfname);
                                         rxpos = -1L;
                                      }
                                   }
                                   else if (rxfsize + 10240L > diskfree) {
                                      hydra_gotoxy(29,2);
                                      hydra_printf("Not enough diskspace");
                                      message(6,"!HRECV: %s not enough diskspace: %ld > %ld",
                                              rxfname, rxfsize + 10240L, diskfree);
                                      rxpos = -2L;
                                   }
                                   else {
                                      if (fexist(rxpathname)) { /* Resuming? */
                                         if ((rxfd = dos_sopen(rxpathname,0)) < 0) {
                                            message(6,"!HRECV: Unable to re-open %s",rxpathname);
                                            rxpos = -2L;
                                         }
                                      }
                                      else if ((rxfd = dos_sopen(rxpathname,1)) < 0) {
                                         message(6,"!HRECV: Unable to create %s",rxpathname);
                                         rxpos = -2L;
                                      }

                                      if (rxfd >= 0) {
                                         message(2,"+HRECV: %s (%ldb), %d min.",
                                                 rxfname, rxfsize,
                                                 (int) (rxfsize * 10L / cur_speed + 27L) / 54L);
                                         if (dos_seek(rxfd,0L,SEEK_END) < 0L) {
                                            message(6,"!HRECV: File seek error");
                                            hydra_badxfer();
                                            rxpos = -2L;
                                         }
                                         else {
                                            rxoffset = rxpos = dos_tell(rxfd);
                                            if (rxpos < 0L) {
                                               message(6,"!HRECV: File tell error");
                                               hydra_badxfer();
                                               rxpos = -2L;
                                            }
                                            else {
                                               rxstart = 0L;
                                               rxtimer = h_timer_reset();
                                               rxretries = 0;
                                               rxlastsync = 0L;
                                               rxsyncid = 0L;
                                               hydra_status(false);
                                               if (rxpos > 0L) {
                                                  hydra_gotoxy(46,2);
                                                  hydra_printf("%ld/%ld",rxpos,rxfsize);
                                                  message(1,"+HRECV: Resuming from offset %ld (%d min. to go)",
                                                          rxpos, (int) ((rxfsize - rxoffset) * 10L / cur_speed + 27L) / 54L);
                                               }
                                               rxstate = HRX_DATA;
                                            }
                                         }
                                      }
                                   }
                                }
                             }
                             else if (rxstate == HRX_DONE)
                                rxpos = (!rxbuf[0]) ? 0L : -2L;

                             h_long1(txbufin) = intell(rxpos);
                             txpkt((int) sizeof (long),HPKT_FINFOACK);
                             break;

                        /*---------------------------------------------------*/
                        case HPKT_FINFOACK:
                             if (txstate == HTX_FINFO || txstate == HTX_FINFOACK) {
                                braindead = h_timer_set(H_BRAINDEAD);
                                txretries = 0;
                                if (!txfname[0]) {
                                   txtimer = h_timer_set(H_IDLE);
                                   txstate = HTX_REND;
                                }
                                else {
                                   txtimer = h_timer_reset();
                                   txpos = intell(h_long1(rxbuf));
                                   if (txpos >= 0L) {
                                      txoffset = txpos;
                                      txlastack = txpos;
                                      hydra_status(true);
                                      if (txpos > 0L) {
                                         message(1,"+HSEND: Transmitting from offset %ld (%d min. to go)",
                                                 txpos, (int) ((txfsize - txoffset) * 10L / cur_speed + 27L) / 54L);
                                         if (dos_seek(txfd,txpos,SEEK_SET) < 0L) {
                                            message(6,"!HSEND: File seek error");
                                            dos_close(txfd);
                                            txfd = -1;
                                            txpos = -2L;
                                            txstate = HTX_EOF;
                                            break;
                                         }
                                      }
                                      txstate = HTX_XDATA;
                                   }
                                   else {
                                      dos_close(txfd);
                                      if (txpos == -1L) {
                                         hydra_gotoxy(29,1);
                                         hydra_printf("They already have file");
                                         message(1,"+HSEND: They already have %s",txfname);
                                         if (mailer)
                                            resultlog(true,txpathname,txfsize,0L);
                                         return (XFER_OK);
                                      }
                                      else {  /* (txpos < -1L) file NOT sent */
                                         hydra_gotoxy(29,1);
                                         hydra_printf("Skipping");
                                         message(1,"+HSEND: Skipping %s",txfname);
                                         return (XFER_SKIP);
                                      }
                                   }
                                }
                             }
                             break;

                        /*---------------------------------------------------*/
                        case HPKT_DATA:
                             if (rxstate == HRX_DATA) {
                                if (intell(h_long1(rxbuf)) != rxpos ||
                                    intell(h_long1(rxbuf)) < 0L) {
                                   if (intell(h_long1(rxbuf)) <= rxlastsync) {
                                      rxtimer = h_timer_reset();
                                      rxretries = 0;
                                   }
                                   rxlastsync = intell(h_long1(rxbuf));

                                   if (!h_timer_running(rxtimer) ||
                                       h_timer_expired(rxtimer)) {
                                      if (rxretries > 4) {
                                         if (txstate < HTX_REND &&
                                             !originator && !hdxlink) {
                                            hdxlink = true;
                                            rxretries = 0;
                                         }
                                      }
                                      if (++rxretries > H_RETRIES) {
                                         message(3,"-HRECV: Too many errors");
                                         txstate = HTX_DONE;
                                         res = XFER_ABORT;
                                         break;
                                      }
                                      if (rxretries == 1)
                                         rxsyncid++;

                                      rxblklen /= 2;
                                      i = rxblklen;
                                      if      (i <=  64) i =   64;
                                      else if (i <= 128) i =  128;
                                      else if (i <= 256) i =  256;
                                      else if (i <= 512) i =  512;
                                      else               i = 1024;
                                      message(0,"-HRECV: Bad pkt at %ld - Retry %u (newblklen=%u)",
                                              rxpos,rxretries,i);
                                      h_long1(txbufin) = intell(rxpos);
                                      h_long2(txbufin) = intell((long) i);
                                      h_long3(txbufin) = intell(rxsyncid);
                                      txpkt(3 * ((int) sizeof(long)),HPKT_RPOS);
                                      rxtimer = h_timer_set(timeout);
                                   }
                                }
                                else {
                                   braindead = h_timer_set(H_BRAINDEAD);
                                   rxpktlen -= (int) sizeof (long);
                                   rxblklen = rxpktlen;
                                   if (dos_write(rxfd,rxbuf + ((int) sizeof (long)),rxpktlen) < 0) {
                                      message(6,"!HRECV: File write error");
                                      hydra_badxfer();
                                      rxpos = -2L;
                                      rxretries = 1;
                                      rxsyncid++;
                                      h_long1(txbufin) = intell(rxpos);
                                      h_long2(txbufin) = intell(0L);
                                      h_long3(txbufin) = intell(rxsyncid);
                                      txpkt(3 * ((int) sizeof(long)),HPKT_RPOS);
                                      rxtimer = h_timer_set(timeout);
                                      break;
                                   }
                                   rxretries = 0;
                                   rxtimer = h_timer_reset();
                                   rxlastsync = rxpos;
                                   rxpos += rxpktlen;
                                   if (rxwindow) {
                                      h_long1(txbufin) = intell(rxpos);
                                      txpkt((int) sizeof(long),HPKT_DATAACK);
                                   }
                                   if (!rxstart)
                                      rxstart = time(NULL) -
                                                ((rxpktlen * 10) / cur_speed);
                                   hydra_status(false);
                                }/*badpkt*/
                             }/*rxstate==HRX_DATA*/
                             break;

                        /*---------------------------------------------------*/
                        case HPKT_DATAACK:
                             if (txstate == HTX_XDATA || txstate == HTX_DATAACK ||
                                 txstate == HTX_XWAIT ||
                                 txstate == HTX_EOF || txstate == HTX_EOFACK) {
                                if (txwindow && intell(h_long1(rxbuf)) > txlastack) {
                                   txlastack = intell(h_long1(rxbuf));
                                   if (txstate == HTX_DATAACK &&
                                       (txpos < (txlastack + txwindow))) {
                                      txstate = HTX_XDATA;
                                      txretries = 0;
                                      txtimer = h_timer_reset();
                                   }
                                }
                             }
                             break;

                        /*---------------------------------------------------*/
                        case HPKT_RPOS:
                             if (txstate == HTX_XDATA || txstate == HTX_DATAACK ||
                                 txstate == HTX_XWAIT ||
                                 txstate == HTX_EOF || txstate == HTX_EOFACK) {
                                if (intell(h_long3(rxbuf)) != txsyncid) {
                                   txsyncid = intell(h_long3(rxbuf));
                                   txretries = 1;
                                   txtimer = h_timer_reset();
                                   txpos = intell(h_long1(rxbuf));
                                   if (txpos < 0L) {
                                      if (txfd >= 0) {
                                         hydra_gotoxy(29,1);
                                         hydra_printf("Skipping");
                                         message(1,"+HSEND: Skipping %s",txfname);
                                         dos_close(txfd);
                                         txfd = -1;
                                         txstate = HTX_EOF;
                                      }
                                      txpos = -2L;
                                      break;
                                   }

                                   if (txblklen > intell(h_long2(rxbuf)))
                                      txblklen = (word) intell(h_long2(rxbuf));
                                   else
                                      txblklen >>= 1;
                                   if      (txblklen <=  64) txblklen =   64;
                                   else if (txblklen <= 128) txblklen =  128;
                                   else if (txblklen <= 256) txblklen =  256;
                                   else if (txblklen <= 512) txblklen =  512;
                                   else                      txblklen = 1024;
                                   txgoodbytes = 0;
                                   txgoodneeded += 1024;
                                   if (txgoodneeded > 8192)
                                      txgoodneeded = 8192;

                                   hydra_status(true);
                                   message(0,"+HSEND: Resending from offset %ld (newblklen=%u)",
                                           txpos,txblklen);
                                   if (dos_seek(txfd,txpos,SEEK_SET) < 0L) {
                                      message(6,"!HSEND: File seek error");
                                      dos_close(txfd);
                                      txfd = -1;
                                      txpos = -2L;
                                      txstate = HTX_EOF;
                                      break;
                                   }

                                   if (txstate != HTX_XWAIT)
                                      txstate = HTX_XDATA;
                                }
                                else {
                                   if (++txretries > H_RETRIES) {
                                      message(3,"-HSEND: Too many errors");
                                      txstate = HTX_DONE;
                                      res = XFER_ABORT;
                                      break;
                                   }
                                }
                             }
                             break;

                        /*---------------------------------------------------*/
                        case HPKT_EOF:
                             if (rxstate == HRX_DATA) {
                                if (intell(h_long1(rxbuf)) < 0L) {
                                   hydra_badxfer();
                                   hydra_gotoxy(29,2);
                                   hydra_printf("Skipping");
                                   hydra_clreol();
                                   message(1,"+HRECV: Skipping %s",rxfname);
                                   rxstate = HRX_FINFO;
                                   braindead = h_timer_set(H_BRAINDEAD);
                                }
                                else if (intell(h_long1(rxbuf)) != rxpos) {
                                   if (intell(h_long1(rxbuf)) <= rxlastsync) {
                                      rxtimer = h_timer_reset();
                                      rxretries = 0;
                                   }
                                   rxlastsync = intell(h_long1(rxbuf));

                                   if (!h_timer_running(rxtimer) ||
                                       h_timer_expired(rxtimer)) {
                                      if (++rxretries > H_RETRIES) {
                                         message(3,"-HRECV: Too many errors");
                                         txstate = HTX_DONE;
                                         res = XFER_ABORT;
                                         break;
                                      }
                                      if (rxretries == 1)
                                         rxsyncid++;

                                      rxblklen /= 2;
                                      i = rxblklen;
                                      if      (i <=  64) i =   64;
                                      else if (i <= 128) i =  128;
                                      else if (i <= 256) i =  256;
                                      else if (i <= 512) i =  512;
                                      else               i = 1024;
                                      message(0,"-HRECV: Bad EOF at %ld - Retry %u (newblklen=%u)",
                                              rxpos,rxretries,i);
                                      h_long1(txbufin) = intell(rxpos);
                                      h_long2(txbufin) = intell((long) i);
                                      h_long3(txbufin) = intell(rxsyncid);
                                      txpkt(3 * ((int) sizeof(long)),HPKT_RPOS);
                                      rxtimer = h_timer_set(timeout);
                                   }
                                }
                                else {
                                   rxfsize = rxpos;
                                   dos_close(rxfd);
                                   rxfd = -1;
                                   hydra_pct(false);

                                   p = xfer_okay();
                                   if (p) {
                                      hydra_gotoxy(25,2);
                                      hydra_printf("  -> %s",p);
                                      message(1,"+HRECV: Dup file renamed: %s",p);
                                   }

                                   hydra_status(false);
                                   message(1,"+Rcvd-H %s",p ? p : rxfname);
                                   resultlog(false,p ? p : rxfname,rxfsize - rxoffset,time(NULL) - rxstart);
                                   rxstate = HRX_FINFO;
                                   braindead = h_timer_set(H_BRAINDEAD);
                                }/*skip/badeof/eof*/
                             }/*rxstate==HRX_DATA*/

                             if (rxstate == HRX_FINFO)
                                txpkt(0,HPKT_EOFACK);
                             break;

                        /*---------------------------------------------------*/
                        case HPKT_EOFACK:
                             if (txstate == HTX_EOF || txstate == HTX_EOFACK) {
                                braindead = h_timer_set(H_BRAINDEAD);
                                if (txfd >= 0) {
                                   txfsize = txpos;
                                   dos_close(txfd);
                                   hydra_pct(true);
                                   resultlog(true,txpathname,txfsize - txoffset,time(NULL) - txstart);
                                   return (XFER_OK);
                                }
                                else
                                   return (XFER_SKIP);
                             }
                             break;

                        /*---------------------------------------------------*/
                        case HPKT_IDLE:
                             if (txstate == HTX_XWAIT) {
                                hdxlink = false;
                                txtimer = h_timer_reset();
                                txretries = 0;
                                txstate = HTX_XDATA;
                             }
                             else if (txstate >= HTX_FINFO && txstate < HTX_REND)
                                braindead = h_timer_set(H_BRAINDEAD);
                             break;

                        /*---------------------------------------------------*/
                        case HPKT_END:
                             /* special for chat, other side wants to quit */
                             if (chattimer > 0L && txstate == HTX_REND) {
                                chattimer = -3L;
                                break;
                             }

                             if (txstate == HTX_END || txstate == HTX_ENDACK) {
                                txpkt(0,HPKT_END);
                                txpkt(0,HPKT_END);
                                txpkt(0,HPKT_END);
                                message(1,"+HYDRA: Completed");
                                txstate = HTX_DONE;
                                res = XFER_OK;
                             }
                             break;

                        /*---------------------------------------------------*/
                        case HPKT_DEVDATA:
                             if (devrxid != intell(h_long1(rxbuf))) {
                                hydra_devrecv();
                                devrxid = intell(h_long1(rxbuf));
                             }
                             h_long1(txbufin) = intell(devrxid);
                             txpkt((int) sizeof (long),HPKT_DEVDACK);
                             break;

                        /*---------------------------------------------------*/
                        case HPKT_DEVDACK:
                             if (devtxstate && (devtxid == intell(h_long1(rxbuf)))) {
                                devtxtimer = h_timer_reset();
                                devtxstate = HTD_DONE;
                             }
                             break;

                        /*---------------------------------------------------*/
                        default:  /* unknown packet types: IGNORE, no error! */
                             break;

                        /*---------------------------------------------------*/
                 }/*switch(pkttype)*/

                 /*----------------------------------------------------------*/
                 switch (txstate) {
                        /*---------------------------------------------------*/
                        case HTX_START:
                        case HTX_SWAIT:
                             if (rxstate == HRX_FINFO) {
                                txtimer = h_timer_reset();
                                txretries = 0;
                                txstate = HTX_INIT;
                             }
                             break;

                        /*---------------------------------------------------*/
                        case HTX_RINIT:
                             if (rxstate == HRX_FINFO) {
                                txtimer = h_timer_reset();
                                txretries = 0;
                                txstate = HTX_FINFO;
                             }
                             break;

                        /*---------------------------------------------------*/
                        case HTX_XDATA:
                             if (rxstate && hdxlink) {
                                message(3,"*HYDRA: %s",hdxmsg);
                                hydra_devsend("MSG",(byte *) hdxmsg,(int) strlen(hdxmsg));

                                txtimer = h_timer_set(H_IDLE);
                                txstate = HTX_XWAIT;
                             }
                             break;

                        /*---------------------------------------------------*/
                        case HTX_XWAIT:
                             if (!rxstate) {
                                txtimer = h_timer_reset();
                                txretries = 0;
                                txstate = HTX_XDATA;
                             }
                             break;

                        /*---------------------------------------------------*/
                        case HTX_REND:
                             if (!rxstate && !devtxstate) {
                                /* special for chat, braindead will protect */
                                if (chattimer > 0L) break;
                                if (chattimer == 0L) chattimer = -3L;

                                txtimer = h_timer_reset();
                                txretries = 0;
                                txstate = HTX_END;
                             }
                             break;

                        /*---------------------------------------------------*/
                 }/*switch(txstate)*/
           }/*while(txstate&&pkttype)*/
        } while (txstate);

        if (txfd >= 0)
           dos_close(txfd);
        hydra_badxfer();

        if (res == XFER_ABORT) {
           com_dump();
           if (carrier()) {
              com_putblock((byte *) abortstr,(int) strlen(abortstr));
              com_flush();
           }
           com_purge();
        }
        else
           com_flush();

        return (res);
}/*hydra()*/


/* end of hydra.c */
