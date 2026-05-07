/*
 *  CONV65
 *
 *  Convert 6502 object file to S-records and Atari 8-bit binary loadfiles.
 *
 *  Synopsis:
 *	CONV65 [-z[N]] [-8] [-c] [-rADDR] [-iADDR] file[.o]
 *	 ==> file.sr (S-records)
 *	 ==> file.obj (Atari DOS loadfiles)
 *
 *    -z[N] : "for ROMs", assume base address is zero (or N)
 *    -c    : write "contiguous" blocks of zeros
 *
 *----
 *  31-Oct-1986 lmd	Hacked it up.
 *
 */

#ifdef ST
#define	CREATMASK	0
#endif
#ifdef BSD
#define	CREATMASK	0666
#endif

#define	BPL	32		/* #bytes per S-record output line */
#define	MAGIC	0xffff		/* DOS II magic number */
#define	RUN	0x2e0		/* DOS II run vector */
#define	INIT	0x2e2		/* DOS II init vector */

#define	SRECORD	0		/* generate S-records */
#define	DOS	1		/* generate Atari DOS loadfile */


char hs[] = "0123456789ABCDEFabcdef";
int debug = 0;
int format = SRECORD;
char *out_ext = ".sr";

int contflag = 0;
int runflag = 0;
char runaddr[2];
int initflag = 0;
char initaddr[2];
int zerobased = 0;
char baseaddr[2];


main(argc, argv)
     int argc;
     char **argv;
{
  int argno;
  int ifh;
  int ofh;
  char fname[128];

  
  if (argc <= 1)
    {
      printf("Usage: conv65 [-z[N]] [-8] [-c] [-rADDR] [-iADDR] file[.o]\n");
      exit(1);
    }

  baseaddr[1] = 0;
  for (argno = 1; argno < argc; ++argno)
    {
      if (*argv[argno] == '-')
	{
	  switch (argv[argno][1])
	    {
	    case '8':
	    dosformat:
	      format = DOS;
	      out_ext = ".obj";
	      break;

	    case 'r':
	    case 'R':
	      gethex(argv[argno] + 2, &runaddr[0]);
	      runflag = 1;
	      goto dosformat;

	    case 'i':
	    case 'I':
	      gethex(argv[argno] + 2, &initaddr[0]);
	      initflag = 1;
	      goto dosformat;

	    case 'x':
	    case 'X':
	      debug = 1;
	      printf("~(Debugging ON)~\n");
	      break;

	    case 'c':
	    case 'C':
	      contflag = 1;
	      break;

	    case 'z':
	    case 'Z':
	      if (argv[argno][2] != '\0')
		gethex(argv[argno] + 2, &baseaddr[0]);
	      else zerobased = 1;
	      break;

	    default:
	      printf("Unknown switch: '%c'\n", argv[argno][1]);
	      exit(1);
	      /*NOTREACHED*/
	    }
	  continue;
	}
      
      strcpy(fname, argv[argno]);
      fext(fname, ".o", 0);
      if((ifh = open(fname, 0)) == -1)
	{
	  printf("Cannot open: %s\n", fname);
	  continue;
	}

      fext(fname, out_ext, 1);
      if ((ofh = creat(fname, CREATMASK)) < 0)
	{
	  close(ifh);
	  printf("Cannot create: %s\n", fname);
	}

      conv65(ifh, ofh, format);

      if (format == DOS)
	{
	  if (initflag)
	    writedos(ofh, (long)INIT, &initaddr[0], 2);
	  if (runflag)
	    writedos(ofh, (long)RUN, &runaddr[0], 2);
	}

      close(ofh);
      close(ifh);
      runflag = 0;
      initflag = 0;
    }

}



conv65(ifh, ofh, format)
     int ifh;
     int ofh;
     int format;
{
  char buf[256];
  char pagemap[256];
  int pageno;
  long addr;
  int first_page;
  char addr_flag;
  int started;
  int last_page;
  int i;
  
  if (read(ifh, &pagemap[0], 256L) != 256L)
    error("header read error");

  /*
   *  do quick sanity check on page map;
   *  make sure entries are only '0' and '1'
   */
  for (pageno = 0; pageno < 256; ++pageno)
    if (pagemap[pageno] != 0 &&
	pagemap[pageno] != 1)
      error("bad object file (pagemap entry >= 2)");

  /*
   *  find "last" page
   */
  if (contflag)
    for (last_page = 255; last_page > 0; --last_page)
      if (pagemap[last_page] != 0) break;

  if (zerobased)
    first_page = -1;
  else first_page = baseaddr[1] & 0xff;;

  if (debug) printf("first_page = %d\n", first_page);

  started = 0;
  for (pageno = 0; pageno < 256; ++pageno)
    if (pagemap[pageno] == 0 &&
	contflag &&
	started &&
	pageno < last_page)
      {
	  for (i = 0; i < 256; ++i) buf[i] = 0;
	  goto dumpit;
      }
    else if (pagemap[pageno] == 1)
      {
	if (read(ifh, &buf[0], 256L) != 256L)
	  error("object read error");
	started = 1;
	if (first_page == -1)
	  first_page = pageno;

      dumpit:
	switch (format)
	  {
	  case SRECORD:
	    addr = (pageno - first_page) << 8;
	    writesr(ofh, addr, buf, 256);
	    break;

	  case DOS:
	    addr = pageno << 8;
	    writedos(ofh, addr, buf, 256);
	    break;
	  }
      }
}


static int dosflag = 0;

writedos(fn, addr, buf, bufsiz)
     int fn;
     long addr;
     char *buf;
     int bufsiz;
{
  static char magic[2] = {MAGIC & 0xff, MAGIC >> 8};
  char limits[4];

  if (!dosflag)
    {
      dosflag = 1;
      if (write(fn, &magic[0], 2L) != 2L)
	error("write error");
    }

  limits[0] = addr & 0xff;
  limits[1] = (addr >> 8) & 0xff;
  limits[2] = (addr + bufsiz) & 0xff;
  limits[3] = ((addr + bufsiz) >> 8) & 0xff;

  if (write(fn, &limits[0], 4L) != 4L ||
      write(fn, buf, (long)bufsiz) != (long)bufsiz)
    error("write error");

  if (runflag &&
      runaddr[0] == 0 &&
      runaddr[1] == 0)
    {
      runaddr[0] = limits[0];
      runaddr[1] = limits[1];
    }
}


writesr(fn, addr, buf, bufsiz)
     int fn;
     long addr;
     char *buf;
     int bufsiz;
{
  int i, j, chksum, a;
  char oln[256], *d;
  
  for(i = 0; i < bufsiz;)
    {
      strcpy(oln, "S1nnaaaa");
      d = oln + 8;
      chksum = 0;
      
      a = addr;
      for(j = 0; (i < bufsiz) && (j < BPL); ++j)
	{
	  chksum += (buf[i] & 0xff);
	  *d++ = hs[(buf[i] >> 4) & 0xf];
	  *d++ = hs[buf[i] & 0xf];
	  ++i;
	  ++addr;
	}
      j += 3;
      
      chksum += a & 0xff;
      chksum += (a >> 8) & 0xff;
      chksum += j;
      chksum = (~chksum) & 0xff;
      
      oln[2] = hs[(j >> 4) & 0xf];
      oln[3] = hs[j &0xf];
      oln[4] = hs[(a >> 12) & 0xf];
      oln[5] = hs[(a >> 8) & 0xf];
      oln[6] = hs[(a >> 4) & 0xf];
      oln[7] = hs[a & 0xf];
      *d++ = hs[(chksum >> 4) & 0xf];
      *d++ = hs[chksum & 0xf];
#ifdef ST
      *d++ = '\r';
#endif
      *d++ = '\n';
      *d++ = '\0';
      
      write(fn, &oln[0], (long)strlen(oln));
    }
}


error(s)
     char *s;
{
  printf("Error: %s\n", s);
  exit(1);
  /*NOTREACHED*/
}


/*
 *  Parse up to a four-digit address,
 *  stuff into buffer in 6502 format.
 *
 */
gethex(s, buf)
     char *s;
     char *buf;
{
  int i;
  int addr = 0;

  while (*s)
    {
      for (i = 0; hs[i]; ++i)
	if (hs[i] == *s)
	  break;
      if (!hs[i])
	error("bad address");
      if (i > 16)
	i -= 6;
      addr = (addr << 4) | i;
      ++s;
    }

  buf[0] = addr & 0xff;
  buf[1] = (addr >> 8) & 0xff;
}
