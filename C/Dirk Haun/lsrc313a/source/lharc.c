/*  @(#)lharc.c 3.13a, -dh- 25.10.1997
 *
 *  Autoren:
 *  --------
 *  Haruyasu Yoshizaki (1988-1989)
 *  Christian Grunenberg, Andreas Mandel (1994)
 *  Dirk Haun (1996/97)
 */


/*  Activate a workaround for a bug in MagiCMac up to 1.2.7:
 *  after a call of Fdatime(), Fclose() will return an error,
 *  so we don't check the return code then.
 */
#define MM_KLUDGE

#ifdef __SHELL__
# define get_env(v) (shell ? NULL : getenv(v))
#else
# define get_env(v) getenv(v)
#endif

#include "lharc.h"
#include <fcntl.h>
#include <setjmp.h>

extern unsigned int InqMagX(void);

#ifdef GERMAN
# include "usageger.h"
#else
# include "usageeng.h"
#endif

#define rename(o,n) Frename(0,o,n)

static uchar *errmes[] =
{
 M_UNKNOWNERR, M_INVCMDERR, M_MANYPATERR, M_NOARCNMERR, M_NOFNERR,
 M_NOARCERR, M_RENAMEERR, M_MKTMPERR, M_DUPFNERR, M_TOOMANYERR,
 M_TOOLONGERR, M_NOFILEERR, M_MKFILEERR, M_RDERR, M_WTERR, M_MEMOVRERR,
 M_INVSWERR, M_CTRLBRK, M_NOMATCHERR, M_COPYERR, M_NOTLZH, M_OVERWT,
 M_MKDIR, M_MKDIRERR, M_CRCERR, M_RDONLY
};

static _DTA _dta;
static int file2, args, c_err, skipped, cmd, cmdupdate, cmdlist, oldtos;
static int _gemdos=SUCCS, Nfile, fbfiles, found, sfx;
static long arcpos0, arcpos1, lastarcpos, lastarclen, nextarcpos, nextoffset, arclen, maxlen, old_afx, buffer_cnt;
static long act_len, file_len, o_handle=-1, i_handle=-1, o_dev=-1, i_dev=-1, crypt_size;
static uchar act_dir[MAXPATH], basedir[MAXPATH], workdir[MAXPATH], incldir[MAXPATH], inclpath[MAXPATH];
static uchar *unpack="*.ZOO,*.ZIP,*.AR[CJ],*.LZ[HS],*.LHA,*.T[GA]Z,*.GIF,*.GZ,*.JPG,*.HPK";
static uchar *bbuf, *ebuf, *fbuf, *fbnxt, *o_dir, print_buf[1536];
static ulong fblft, fbmax;
static filebuf *fblast;

static uchar SystemId, back_1, back_2;
static int patno, exno, maxblk=64, UnixFile, wild_arc, multi_arc, all;
static int fn_name=12, pt_name=128, Case=_PC_CASECONV, min_len, garbage, Device;

uchar *buf=text_buf; /* -> lha5.s */

uchar compress, method=5, buffered, *buffer_last; /* auch in hufst.s */
long bsize; /* auch in hufst.s */
int outfile; /* auch in hufst.s */
uchar obj; /* auch in test_afx.s */
uchar has_crc; /* auch in decodold.s */
uchar *infname; /* auch in util.s */
long bufsize; /* auch in decode5.s */
int errorlevel; /* auch in decode5.s */

static int hdr_len, header_len, ignfile;
static uchar *pager, *com_name, *buffer_start;
static uchar base, pnt='.';
static uchar FlgMethod=5, copying, ptitel, pargs;

#ifndef __SHELL__
uchar pack;
#endif

static uchar flg_l, flg_o, flg_5, flg_U=1, flg_w,   flg_chk, flg_r,
             flg_p, flg_x, flg_m, flg_a,   flg_c,            flg_t,
             flg_v, flg_h, flg_i, flg_f,   flg_z,   flg_e,   flg_d,
             flg_g, flg_j,        flg_s,   flg_L=2, flg_S,   flg_R,
             flg_B, flg_A, flg_W, flg_X,   flg_K,            flg_D,
             flg_F, flg_O;
uchar flg_q, /* -> decode5.s */
      flg_n, /* -> util.s */
      flg_Y; /* -> hufst.s */

static char flg_4, flg_I, flg_k=-1, flg_N, flg_u;
static uchar flg_unpacked, flg_arc, flg_backup;

/* freie Switches: EGHJQTVZ */

static const uchar swi[] = "lo5UwCrpxmacntvhifzedgjqsLSRBAWXKYDFO"  /* Switches aus swipos[] */
                           "ybuk4PMNI";   /* fÅr die gibt's eine Sonderbehandlung in getsw() */
static uchar *swipos[] = {
 &flg_l, &flg_o, &flg_5, &flg_U, &flg_w, &flg_chk, &flg_r,
 &flg_p, &flg_x, &flg_m, &flg_a, &flg_c, &flg_n,   &flg_t,
 &flg_v, &flg_h, &flg_i, &flg_f, &flg_z, &flg_e,   &flg_d,
 &flg_g, &flg_j, &flg_q, &flg_s, &flg_L, &flg_S,   &flg_R,
 &flg_B, &flg_A, &flg_W, &flg_X, &flg_K, &flg_Y,   &flg_D,
 &flg_F, &flg_O
};

#define SWI_CNT 37

static LzHead Hdr1, Hdr2;
static _DOSTIME arcstamp, newer;

uchar *buffer_gen, /* auch in test_afx.s */
      *buffer_3, /* auch in decodold.s */
       backup2[MAXPATH], pathname[MAXPATH], key_word[256], *key; /* auch in hufst.s */
static uchar arcname[MAXPATH], backup1[MAXPATH];
static uchar filename[MAXPATH], dosfilename[MAXPATH], matchfilename[MAXPATH], comment[MAXCOMMENT+256];
static uchar buffer[(BUFFERSIZ+128+32)*3], *buffer_1;
static uchar travel_wild[MAX_PAT], *exclude_file[MAX_EXCLD], fileregbuf[FILEBUFSIZ], *fileptr;
static uchar *travel_path[MAX_PAT], travel_rel[MAX_PAT];
static int patcnt[MAX_PAT], travel_len[MAX_PAT], travel_file[MAX_PAT], arc_file[MAX_ARC];

#if defined(BETA) && !defined(__SHELL__)
  long timer;
# define INIT_TIMER timer=clock()
# define EXIT_TIMER timer=clock() - timer; sprintf(print_buf," Time : %ld ms ",(timer*5)); Print(1)
#else
# define INIT_TIMER
# define EXIT_TIMER
#endif

#ifdef __SHELL__

long dir_handle[40];
int dirs;

extern void DialIndicator(int);
extern void make_info(int show,SELECT *sel);
extern void FrozenMsg(int);
extern void SetMsg(uchar *);
extern int OverWrMsg(uchar *);
extern void ErrorAlert(uchar *);
extern void set_crypt(void);

static void skip(uchar *,uchar *,int);

extern int command, drv_lines, overwr_all, execute, idx, ainf_changed;
extern jmp_buf errorjmp;
extern SELECT drv_sel;
extern _DOSTIME arc_time;

extern uchar *view_mem, arc_comment[];
extern long view_length, alert_buf;

extern filebuf *arc_buf, *drv_files[];
filebuf *next_buf, *last_buf;

int cmd_found = FAULT;
long searchpos;
uchar shell, stop;

#endif /* __SHELL__ */

static char wait_for_key(int newline);

static clock_t now;

static void getnow(void)
{
  now=*((unsigned long *) 0x4baL);
}

static clock_t clock(void)
{
  (void) Supexec(getnow);
  return (now);
}

#define  A      16807L
#define  M   2147483647L
#define  Q       127773L
#define  R         2836L

static long _lseed;

static int temp(void)
{
  _lseed=A * ((_lseed % Q) + R) - R * (_lseed / Q);

  if (_lseed<0)
    _lseed+=M;

  return((int) _lseed & 4095);
}

static void fdelete(uchar *path,int attr)
{
  if (attr & FA_DIR)
    return;
  if (attr & FA_RDONLY)
    Fattrib(path,1,0);
  Fdelete(path);
}

static int multi_wild(uchar *file)
{
  return (flg_W<2 && strchr(file,',')!=NULL);
}

static int wildcard(uchar *file)
{
  if (!flg_W && strpbrk(file,"*?[]@|^"))
    return(SUCCS);
  else
    return(FAULT);
}

static int sseek(FILE *file,long pos,long offset)
{
  if (pos>=arclen)
  {
    fseek(file,0l,SEEK_END);
    return(-1);
  }
  else if (offset)
    return(fseek(file,offset,SEEK_CUR));
  else
    return(0);
}

void print(uchar *p,int nl)
{
  if (!flg_q)
  {
    uchar string[2048];

    if (p)
      p=stpcpy(string,p);
    else
      p=string;

    for (;--nl>=0;)
      p=stpcpy(p,"\r\n");
    Cconws(string);
  }
}

static void Print(int nl)
{
  print(print_buf,nl);
}

void pager_print(int pg)
{
  if (cmd!='P' || flg_v<2)
  {
    if (pager)
      fputs(print_buf,file3);

    if (!flg_q && (!pager || pg))
      Print(0);
  }
}

void message(uchar *p,uchar *q)
{
  sprintf(print_buf,"%s: %s",p,q);
  print(print_buf,1);
}

static void show_usage(int stop)
{
  int i, l, lines;
  char key, *cp;

  if(stop && !isatty(1))
    stop=0; /* don't stop if stdout is redirected */

  if(stop)
  {
    cp=getenv("LINES");
    if(cp)
    {
      lines=atoi(cp);
      if(lines<5)
        lines=25-2;
      else
        lines-=2;
    }
    else
      lines=25-2;
  }
  else
    lines=-1;

  for(i=0,l=(stop ? 3 : 1);usage[i];i++,l++)
  {
    print(usage[i],1);
    if(l==lines)
    {
      key=wait_for_key(0);
      print("\r\033l\r",0);
      if(key=='Q')
      {
        flg_h=0;
        break;
      }
      l=1;
    }
  }
}

static void convert_comment(void)
{
  register uchar c, com[MAXCOMMENT+256],
          *dst=com, *src=comment;

  comment[MAXCOMMENT-1]='\0';

  while ((c=*src++)!='\0')
  {
    if (c=='\n' && src[0]!='\r' && src[-2]!='\r')
      *dst++='\r';
    *dst++=c;
  }

  *dst='\0';

  strcpy(comment,com);
}

static int slash (register uchar *path, int set)
{
  if (path && *path)
  {
    while (*path++);
    path-= 2;

    if (*path != '\\')
    {
      if (set > 0)
      {
        *++path = '\\';
        *++path = '\0';
      }
      else
      {
        return (SUCCS);
      }
    }
    else if (set == 0)
    {
      *path = '\0';
    }
  }

  return(FAULT);
}

static uchar _proc_str[]= "\r         : %3d%% (%Nld/%Nld)";
static uchar _frozen_str[]="\r\033l\r         : %Nld -> %Nld (%3d%%) ";

void proc_ind(void)
{
  if ((act_len+=blocksize)>=file_len || blkcnt<=0)
    sprintf(print_buf,_proc_str,100,file_len,file_len);
  else
    sprintf(print_buf,_proc_str,(int) ((act_len*100l)/file_len),act_len,file_len);
  Print(0);
}

#ifdef __SHELL__
void copy_to_view(uchar *mem,long length)
{
  if (view_mem>NULL && view_length>0)
  {
    if (length>view_length)
      length = view_length;
    memcpy(view_mem,mem,length);
    view_mem += length;
    view_length -= length;
  }
}
#endif

int decrypt(long offset)
{
  if (Hdr1.crypted && crypt_size>0)
  {
    register long len=file1->_cnt+offset;

    if (len>crypt_size)
      len=crypt_size;
    code(file1->_ptr-offset,len);
    crypt_size-=len;
  }

  if (offset)
    return(*file1->_base);
  else
    return(0);
}

static int arc_ext(uchar *x)
{
  if (x==NULL)
    return(FAULT);
  else
    x++;

  if (stricmp("LZH",x) && stricmp("LHA",x) && stricmp("LZS",x) && stricmp("SFX",x))
    return(FAULT);
  else
    return(SUCCS);
}

static int path_conf (uchar *path, int mode)
{
  register uchar dir[MAXPATH];
  register long conf;

  if (backpath (strcpy (dir, path)) > dir)
  {
    conf = pathconf (dir, mode);
    if (conf == -34L) /* path not found */
      conf = pathconf (act_dir, mode);
  }
  else
    conf = pathconf (act_dir, mode);

  return ((conf > 32767) ? 32767 : (int) conf);
}

static int case_sensitive(uchar *path)
{
  if (path_conf(path,-1)<_PC_CASE)
    return(_PC_CASECONV);
  else
    return(path_conf(path,_PC_CASE));
}

/*
int rename (uchar *old, uchar *new)
{
  uchar newname[MAXPATH], realname[MAXPATH];

  if (Freadlink (MAXPATH, realname, old) == 0)
  {
    if (strncmp (old, new, strlen (new) - strlen (get_fname (new))) == 0)
    {
      backpath (strcpy (newname, realname));
      strcat (newname, get_fname (new));
    }
    old = realname;
    new = newname;
  }

  return (Frename (0, old, new));
}
*/

void follow_link (uchar *name)
{
  uchar realname[MAXPATH];

  if (Freadlink (MAXPATH, realname, name) == 0)
  {
    strcpy (name, realname);
  }
}

static char wait_for_key(int newline)
{
  char key;

#ifdef __SHELL__
  if (!shell && flg_h && i_handle<0 && o_handle<0)
#else
  if (flg_h && i_handle<0 && o_handle<0)
#endif
  {
    print(M_PRESSKEY,0);

    fflush(stdin);
    key=(char)toupper((int)getch());

    if (newline)
      print(NULL,1);
  }

  return(key);
}

static void lha_exit(void)
{
#ifdef __SHELL__
  Fsetdta(&_dta);

  while (--dirs>=0)
    Dclosedir(dir_handle[dirs]);
  dirs = 0;

  if (fbuf)
  {
    Mfree(fbuf);
    fbuf=NULL;
  }

  if (bbuf)
  {
    Mfree(bbuf);
    bbuf=NULL;
  }

  if (ebuf)
  {
    Mfree(ebuf);
    ebuf=NULL;
  }

  buffer_gen=(uchar *) (((long) (buffer+16)) & (~15l));
#endif

  if (i_handle>=0)
  {
    if (i_dev>=0)
      Fforce(0,(int) i_dev);
    Fclose((int) i_handle);
  }

  if (o_handle>=0)
  {
    if (o_dev>=0)
      Fforce(1,(int) o_dev);
    Fclose((int) o_handle);
  }

  if (flg_K)
  {
    register long time=clock()+(CLK_TCK>>2);

    for (flg_K<<=2;flg_K>0;flg_K--)
    {
      while (clock()<time);
      time+=(CLK_TCK>>2);
      Cconout(7);
    }
  }

  cmdupdate = copying = 0;

#ifdef __SHELL__
  if (!shell)
#endif
  {
    if(isatty(1))
      wait_for_key(1);
    exit(errorlevel);
  }
#ifdef __SHELL__
  else
  {
    flg_n = 4;
    longjmp(errorjmp,-1);
  }
#endif
}

void error(int errcode,uchar *p,int err)
{
  if (err && old_afx)
    afxonoff(old_afx);

  if (p==backup2)
  {
    if (flg_w)
    #ifdef GERMAN
      p = "temp. Archiv";
    #else
      p = "temp. archive";
    #endif
    else
      p = arcname;
  }

#ifdef __SHELL__
  if (!shell)
#endif
  {
    fflush(stdout);
    print(NULL,1);
  }

  if (copying)
  {
  #ifdef __SHELL__
    if (shell)
    {
      if (execute)
      {
        if (err)
          ErrorAlert(M_COPYERR);
        else
          SetMsg(M_COPYERR);
      }
    }
    else
  #endif
      print(M_COPYERR,1);
    close_file(file1);
    Fdelete(arcname);
  }

  if (errcode>=0)
  {
  #ifdef __SHELL__
    if (shell)
    {
      if (execute && !copying)
      {
        if (p)
          sprintf(print_buf,"%s %s",errmes[errcode],p);
        else
          strcpy(print_buf,errmes[errcode]);

        if (errcode==WTERR)
          #ifdef GERMAN
            strcat(print_buf," (Disk voll?)");
          #else
            strcat(print_buf," (Disk full?)");
          #endif

        if (err)
          ErrorAlert(print_buf);
        else
          SetMsg(print_buf);
      }
    }
    else
  #endif
    if (p)
      message(errmes[errcode],p);
    else
      print(errmes[errcode],1);
  }

  if (file3 && file3!=stdout)
  {
    close_file(file3);

    if (copying && err && !Device && (back_2 || cmd=='C'))
    {
      register uchar path[MAXPATH];

      strcpy(backpath(strcpy(path,backup2)),get_fname(arcname));
      rename(backup2,path);
    }
    else if ((err || cmd=='E') && !cmdupdate && cmd!='C')
      Fdelete(pathname);
  }

  if (err)
  {
    if (file1)
    {
      close_file(file1);
      if (!Device && back_1)
        rename(backup1,arcname);
    }

    if (file2)
    {
      close(file2);
      file2=0;

      if (!Device && (back_2 || cmd=='C'))
        Fdelete(backup2);
    }
  }

  switch (errcode)
  {
    case MEMOVRERR:
      errorlevel|=512;
      break;
    case RDERR:
    case RDONLY:
      errorlevel|=8;
      break;
    case WTERR:
      errorlevel|=4;
      break;
    case RENAMEERR:
    case MKDIRERR:
      errorlevel|=16;
      break;
    case MKFILEERR:
    case MKTMPERR:
      errorlevel|=32;
      break;
    case NOFILEERR:
    case NOFNERR:
      errorlevel|=256;
      break;
    case NOARCERR:
    case NOARCNMERR:
      errorlevel|=128;
  }

  if (copying)
    errorlevel|=32;

  if (err==SUCCS)
    lha_exit();
}

FILE *e_fopen (uchar *fname, uchar *buffer, uchar *mode, int errID, int err)
{
  register FILE *f;

  if ((f = fopen (fname, mode)) == NULL)
  {
    if (errno == EACCES)
      error (RDONLY, fname, err);
    else if (errno)
      error (errID, fname, err);
  }
  else if (buffer)
    setvbuf (f, buffer, _IOFBF, bsize);

  return (f);
}

uint get_key(uchar *keys)
{
  register uchar key;

  fflush(stdin);
  do
  {
    key=(uchar) toupper((int) getch());
    #ifdef GERMAN
      if (key=='J')
        key='Y';
    #endif
  } while (!strchr(keys,key));

  #ifdef GERMAN
    print_buf[0]=key=='Y' ? 'J' : key;
  #else
    print_buf[0]=key;
  #endif
  print_buf[1]='\0';
  Print(1);

  return(key);
}

void ShipOut(void)
{
  ship++;
  shipout();
  ship=0;
}

void tstpat(void)
{
  register int i;

#ifdef __SHELL__
  if (shell)
    return;
#endif

  if (!Nfile)
  {
    print(M_NOFILEERR,1);
    errorlevel|=256;
    return;
  }

  for (i=patno;--i>=0;)
    if (!patcnt[i] && !travel_wild[i])
    {
      message(M_NOMATCHERR,&fileregbuf[travel_file[i]]);
      errorlevel|=256;
    }
}

void sethdr(uchar *fn,uint attr,_DOSTIME *time,LzHead *h,int name)
{
  register uchar *id;
  register uint l;

  memset(h,0,sizeof(LzHead));

  l=(uint) strlen(fn);
  if (name==SUCCS && flg_x==2 && *fn!='\\')
  {
    h->Fname[1]='\\';
    memcpy(h->Fname+2,fn,l++);
  }
  else
    memcpy(h->Fname+1,fn,l);

  if ((attr & FA_DIR) && (h->Fname[l]!='\\'))
    h->Fname[++l]='\\';

  h->Fname[0]=l;
  h->Attr=(flg_backup) ? (attr & (~FA_CHANGED)) : attr;
  h->Ftime=*time;
  h->HeadSiz=l;

  if (file3)
  {
    h->OrgSiz=textsize=Fseek(0l,fileno(file3),SEEK_END);
    Fseek(0l,fileno(file3),SEEK_SET);
  }
  else
    h->OrgSiz=textsize=0;

  method=FlgMethod;
  codesize=compsize=0;

  if (attr & FA_DIR)
    id="-lhd-";
  else if (cmd=='C')
    id="-afx-";
  else if (!method)
    id="-lz5-";
  else if (method==1)
    id="-lh1-";
  else if (method==5)
    id="-lh5-";
  else
    id="-lz4-";

  memcpy(h->HeadID,id,5);
}

uint make_ext(uchar *dest,uchar *source,uchar id,int last)
{
  register uint len;

  if ((len=(uint) strlen(source))>0)
  {
    if (last)
      len+=4;
    else
      len+=3;

    *dest++=(uchar) (len&0xff);
    *dest++=(uchar) (len>>8);
    *dest++=id;

    while (*source!='\0')
      *dest++=*source++;

    if (last)
      *dest++=0xff;
  }

  return(len);
}

void wthdr(LzHead *h,int make,int unpck)
{
  register uchar *ptr, *s, *n=h->Fname+1;
  register uint len=0;
  register int lev=flg_k;
  register ulong size;
  register _DOSTIME time;

  if (lev<=0 && (comment[0]!='\0' || flg_s || (flg_Y && h->OrgSiz>0)))
    lev=1;
  else if (lev<0)
    lev=0;

  if (make)
  {
    if ((h->Level=lev)==1)
      h->HeadSiz+=25;
    else
      h->HeadSiz+=22;

    if (lev && flg_s)
    {
      register uchar c,s='\\';

      ptr=n;
      while ((c=*ptr++)!='\0')
        if (c==s)
          ptr[-1]='/';
    }
    else
      yen2slash(n);

    if (lev)
    {
      if (lev<2)
        s=n+h->Fname[0]+3;
      else
      {
        uchar path[MAXPATH];

        strncpy(path,n,h->Fname[0]);
        path[h->Fname[0]]='\0';

        len+=make_ext(&h->Fname[3],s=get_fname(path),0x01,FAULT);

        if (s>path)
        {
          register uchar c;
          *s='\0';

          ptr=path;
          while ((c=*ptr++)!='\0')
            if (c=='\\' || c=='/')
              ptr[-1]='\xff';

          if (ptr[-2]==(uchar) '\xff')
            ptr[-2]='\0';

          len+=make_ext(&h->Fname[len+3],path,0x02,SUCCS);
        }

        s=&h->Fname[len+3];
      }

      if (h->Attr!=0x20 || lev==2)
      {
        len+=5;
        *s++=5;
        *s++='\0';
        *s++=0x40;
        *s++=h->Attr;
        *s++='\0';
      }

      if (h->OrgSiz>0 && flg_Y)
      {
        len+=4;
        *s++=4;
        *s++='\0';
        *s++=0x20;
        *s++=1;
      }

      if (*comment)
      {
        register uint off=make_ext(s,comment,0x3f,SUCCS);
        len+=off;
        s+=off;
      }

      *s++='\0';
      *s++='\0';
    }

    hdr_len=len;
  }
  else
    len=hdr_len;

  if (lev<2)
  {
    if (lev==1)
      h->PacSiz+=len;
    ptr=n+h->Fname[0];
  }
  else
    ptr=h->Fname;

  *ptr++=(uchar) (crc&0xff);
  *ptr++=(uchar) (crc>>8);

  if (lev>0)
  {
    if (flg_s)
      *ptr=flg_s;
    else
      *ptr='a';
    h->Attr=0x20;
  }

  if (lev<2)
  {
    len+=h->HeadSiz;
    h->HeadChk=mksum(h,h->HeadSiz+1);
    len+=2;
  }
  else
  {
    len+=26;
    h->HeadSiz=(uchar) (len&0xff);
    h->HeadChk=(uchar) (len>>8);
  }

  size=header_len=len;

  if (unpck)
    size+=h->OrgSiz;
  else
    size+=(h->OrgSiz>>1);

  ilong(&h->PacSiz);
  ilong(&h->OrgSiz);

  time=h->Ftime;
  if (lev<2)
    ITIME(h->Ftime);
  else
    dos_2_unixtime((void *) &h->Ftime);

  if (make)
  {
    if (outrec.cnt<=(len+1024) || (bsize>size && outrec.cnt<=size))
      ShipOut();

    buffer_start=outrec.ptr;
    buffer_last=(outrec.ptr+=len);
    buffer_cnt=(outrec.cnt-=len);
    buffered=1;
  }

  ptr=((uchar *) h)+8;
  if (buffered)
  {
    memcpy(buffer_start,ptr-8,7);
    memcpy(buffer_start+7,ptr,len-7);
  }
  else
  {
    register long pos = Fseek(0l,file2,SEEK_CUR);

    Fseek(arcpos0-pos,file2,SEEK_CUR);
    memcpy(ptr-1,ptr,len-7);
    write(file2,h,len);
    memcpy(ptr,ptr-1,len-7);
    Fseek(pos-(arcpos0+len),file2,SEEK_CUR);
  }

  arcpos1=arcpos0+len;

  ilong(&h->PacSiz);
  ilong(&h->OrgSiz);
  h->Ftime=time;
}

void unix2dos(uchar *unx,int rel)
{
  register uchar c, *u=unx, *d=u;

  yen2slash(unx);
  if (!strncmp(u,"\\dev\\",5))
  {
    u+=5;

    if (u[0]!='\0' && (u[1]=='\0' || u[1]=='\\'))
    {
      if (rel)
        u++;
      else
      {
        *d++=*u++;
        *d++=':';
      }
    }
  }
  else if (!strncmp(u,"\\pipe\\",6))
    u+=6;

  while ((c=*u++)!='\0')
  {
    if (rel && c==':' && ((d>&unx[1] && d[-2]=='\\') || (d==&unx[1])))
      d=unx;
    else
      *d++=c;
  }

  *d++='\0';
}

void yen2slash(uchar *p)
{
  register uchar c, s, *d=p;

  s='/';
  while ((c=*p++)!='\0')
    if (c==s)
      p[-1]='\\';

  s='\\';
  while ((c=*d++)!='\0')
    if (c==s && *d==s)
    {
      d--;
      strcpy(d,d+1);
    }
}

void strcnv(uchar *str,int flag)
{
  if (flag && flg_s)
    strlwr(str);
  else
    strupr(str);
}

int fnamecmp(uchar *f1,uchar *f2,int Case)
{
  if (flg_S==2 || (!flg_S && Case!=_PC_CASESENS))
    return(stricmp(f1,f2));
  else
    return(strcmp(f1,f2));
}

static int matchpattern(register uchar *s,register uchar *p)
{
  register uchar s_c, p_c;
  register int matched, reverse;

  for (;(p_c=*p++)!='\0';)
  {
    s_c=*s++;

    switch (p_c)
    {
      case '@':
        if (s_c!=*p++)
          return(FAULT);
        break;
      case '?':
        if (s_c=='\0')
          return(FAULT);
        break;
      case '*':
        if (s_c=='\0')
          return((*p=='\0') ? SUCCS :FAULT);
        else
        {
          if (*p!='\0')
          {
            s--;
            while (!matchpattern(s,p))
              if (*++s=='\0')
                return(FAULT);
          }
          return(SUCCS);
        }
      case '[':
        matched=FAULT;

        if (*p=='^')
        {
          reverse=SUCCS;
          p++;
        }
        else
          reverse=FAULT;

        for (; (p_c=*p++)!='\0' && p_c!=']';)
        {
          if (p_c=='-')
          {
            if (s_c<=*p++ && s_c>=p[-3])
              matched=SUCCS;
          }
          else if (p_c=='@' && s_c==*p++)
            matched=SUCCS;
          else if (s_c==p_c && p_c!='|')
            matched=SUCCS;
        }

        if (matched==reverse)
          return(FAULT);

        break;
      default:
        if (s_c!=p_c)
          return(FAULT);
        break;
    }
  }

  return(*s=='\0');
}

static int chk_wild(uchar *fname,uchar *fspec,int Wild,int Case)
{
  if (*fspec)
  {
    register uchar *p=fspec;

    if (*p++=='*' && (*p=='\0' || (*p++=='.' && *p++=='*' && *p++=='\0')))
      return(SUCCS);
    else
    {
      register uchar wc[64], fn[64];
      register int res=0, len=(int) strlen(fspec);

      if (flg_S==2 || (!flg_S && Case!=_PC_CASESENS))
      {
        Case=FAULT;
        strupr(strcpy(fn,fname));
      }
      else
        Case=SUCCS;

      p=(Wild==2) ? fspec : strtok(fspec,", ");
      while (p)
      {
        if (*p!='\0')
        {
          if (Wild)
            res=(!fnamecmp(fname,p,Case));
          else if (Case)
            res=matchpattern(fname,p);
          else
          {
            strupr(strcpy(wc,p));
            res=matchpattern(fn,wc);
          }
        }

        if (res)
        {
          if (Wild<2)
          {
            while (*p++);
            if ((long) ((--p)-fspec)<len)
              *p=',';
          }

          return(SUCCS);
        }
        else if (Wild==2)
          break;
        else if ((p=strtok(NULL,", "))!=NULL)
          p[-1]=',';
      }
    }
  }

  return(FAULT);
}

void fnamecnv (uchar *dest, int conv)
{
  int sens = Case;

  yen2slash (dest);
  if (conv < 0)
  {
    sens = case_sensitive (dest);
  }
  else if (conv > 0)
  {
    TruncFile (dest);
  }

  if (!flg_S && (sens == _PC_CASECONV))
  {
    strcnv (dest, cmdupdate);
  }
}

#define SECS_PER_MIN  (60L)
#define SECS_PER_HOUR (3600L)
#define SECS_PER_DAY  (86400L)
#define SECS_PER_YEAR (31536000L)
#define SECS_PER_LEAPYEAR (SECS_PER_DAY + SECS_PER_YEAR)

static int days_per_mth[12] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

void unix_2_dostime(void *t)
{
  register _DOSTIME *dostime=(_DOSTIME *) t;
  register long time=*((long *) t);
  register int year, mday, mon;
  int hour, min, sec;

  year = 70;
  while (time>=SECS_PER_YEAR)
  {
    if ((year&3)==0)
    {
      if (time<SECS_PER_LEAPYEAR)
        break;
      else
        time -= SECS_PER_LEAPYEAR;
    }
    else
      time -= SECS_PER_YEAR;
    year++;
  }

  mday = (int)(time/SECS_PER_DAY);
  days_per_mth[1] = (year&3) ? 28 : 29;
  for (mon = 0; mday >= days_per_mth[mon]; mon++)
    mday -= days_per_mth[mon];
  mday++;

  time = time % SECS_PER_DAY;
  hour = (int) (time/SECS_PER_HOUR);
  time = time % SECS_PER_HOUR;
  min = (int) (time/SECS_PER_MIN);
  sec = (int) (time%SECS_PER_MIN);

  if (year>=80)
    year-=80;
  else
    year=0;
  dostime->time=(uint) ((hour<<11)|(min<<5)|(sec>>1));
  dostime->date=(uint) ((year<<9)|(mon<<5)|mday);
}

void dos_2_unixtime(void *time)
{
  register _DOSTIME *dostime=(_DOSTIME *) time;
  register uint val;
  register struct tm tm, *t=&tm;

  val=dostime->time;
  t->tm_sec=(val&31)<<1;
  t->tm_min=(val>>=5)&63;
  t->tm_hour=val>>=6;

  val=dostime->date;
  t->tm_mday=val&31;
  t->tm_mon=(val>>=5)&15;
  t->tm_year=(val>>=4)+80;

  *((time_t *) time)=mktime(t);
  ilong((ulong *) time);
}

static int gethdr(FILE *arc,LzHead *h)
{
  uchar exthdr[MAXEXT], fname[MAXPATH];
  register uchar *p;
  register uint extsize;
  register int length, unix;
  register long pos, read;

#ifdef __SHELL__
  if (!cmdupdate && !flg_d && (stop || (command && searchpos<0)))
    return (FAULT);
#endif

  _gethdr:
  *comment='\0';
  lastarcpos=nextarcpos;
  memset(h,0,sizeof(LzHead));

  if (fread((uchar *) h,7,1,arc)!=1 || fread((uchar *) h+8,14,1,arc)!=1)
    goto no_hdr;

  if (h->Level>2)
    goto no_hdr;
  else if (h->Level==2)
    h->HeadSiz=HDRSIZ2;
  else if (h->HeadSiz<MINHDR || h->HeadSiz>sizeof(LzHead))
    goto no_hdr;

  read=h->HeadSiz+2;

  if (fread((uchar *) h+22,read-21,1,arc)!=1)
    goto no_hdr;

  ilong(&h->PacSiz);
  ilong(&h->OrgSiz);

  lastarclen=read+h->PacSiz;
  pos=lastarcpos+read;

  if (h->Level<2)
    ITIME(h->Ftime);
  else
  {
    ilong((ulong *) &h->Ftime);
    unix_2_dostime((void *) &h->Ftime);
  }
  h->Mtime=h->Ftime;

  if (h->Level<2)
  {
    register int i;

    if (mksum(h,h->HeadSiz)!=h->HeadChk && mksum(h,h->HeadSiz+1)!=h->HeadChk)
      goto no_hdr;

    length=h->Fname[0];
    strncpy(filename,&h->Fname[1],length);
    filename[length]='\0';

    i=(int) strlen(filename);
    p=&h->Fname[i+1];
    if ((i=length-i)>0)
    {
      while (--i>=0)
        if (*p++>=' ')
        {
          strncpy(comment,--p,++i);
          comment[i]='\0';
          break;
        }
    }

    length++;
  }
  else
  {
    filename[0]='\0';
    length=0;
  }

  p=h->Fname+length;
  h->crc=(uint) *p++;
  h->crc|=(uint) (*p++<<8);
  SystemId=*p++;

  has_crc=(flg_chk) ? FAULT : SUCCS;

  switch(h->HeadSiz-length)
  {
    case (HDRSIZ0-1-2):
      has_crc=FAULT;
    case (HDRSIZ0-1):
      h->Level=0;
      break;
    default:
      if (h->Level==0)
      {
        if (SystemId==EXTEND_UNIX || SystemId==EXTEND_OS68K)
        {
          memcpy(&h->Mtime,p+1,4);
          ilong((ulong *) &h->Mtime);
          unix_2_dostime((void *) &h->Mtime);
        }
        else
          h->Level++;
      }
      break;
  }

  if (h->Level>0)
  {
    extsize=(uint) *p++;
    extsize|=(uint) (*p++<<8);

    while (extsize>0)
    {
      pos+=extsize;
      length=extsize-2;
      if (extsize>=MAXEXT)
      {
        if (sseek(arc,pos-2,length))
          goto no_hdr;
      }
      else if (fread(exthdr,length,1,arc)!=1)
        goto no_hdr;
      else
      {
        length--;
        switch (exthdr[0])
        {
          case 0:   /* common header */
            break;
          case 1:   /* filename header */
          case 2:   /* pathname header */
            if (length>=pt_name)
              break;

            strncpy(fname,&exthdr[1],length);
            fname[length]='\0';

            while ((p=strchr(fname,'\xff'))!=NULL)
              *p = '\\';
            length = (int) strlen(fname);

            if (exthdr[0]==1)
            {
              p=get_fname(filename);
              if (((int) (p - filename) + length)<pt_name)
                strcpy(p,fname);
            }
            else if (((int) strlen(filename) + length + 1)<pt_name)
            {
              if (fname[length-1]!='\\' && fname[length-1]!='/')
                strcat(fname,"\\");

              strcat(fname,filename);
              strcpy(filename,fname);
            }
            break;
          case 0x20:
            h->crypted=exthdr[1];
            break;
          case 0x3f:  /* comment */
            strncpy(comment,&exthdr[1],length);
            comment[length]='\0';
            if ((p=strchr(comment,'\xff'))!=NULL)
              *p='\0';
            break;
          case 0x40:  /* file attribute */
            h->Attr=exthdr[1];
            break;
          case 0x50:  /* permission */
          case 0x51:  /* gid and uid */
          case 0x52:  /* group name */
          case 0x53:  /* user name */
            break;
          case 0x54:  /* last modified time */
            memcpy(&h->Mtime,&exthdr[1],4);
            ilong((ulong *) &h->Mtime);
            unix_2_dostime((void *) &h->Mtime);
            break;
          }
      }

      read+=extsize;
      if (h->Level<2)
        h->PacSiz-=extsize;
      else
        lastarclen+=extsize;

      extsize=getc(arc);
      extsize+=(uint) getc(arc)<<8;
    }
  }

  convert_comment();

  if ((unix=strchr("UXHK",SystemId) || strchr(filename,'/'))!=0)
    flg_s=SystemId;

  unix2dos(filename,1);

  if (filename[0] && filename[1]==':')
    strcpy(filename,filename+2);

  while (!strncmp(filename,".\\",2))
    strcpy(filename,filename+1);

  while (!strncmp(filename,"..\\",3))
    strcpy(filename,filename+2);

  if (flg_x==3)
    while (filename[0]=='\\')
      strcpy(filename,filename+1);

  if (slash(strcpy(matchfilename,filename),-1)==FAULT)
  {
    slash(matchfilename,0);
    h->Attr=FA_DIR;
  }
  else if (tstID(h->HeadID)==6)
    h->Attr=FA_DIR;
  else
    h->Attr&=0x2f;

  if (h->Attr & FA_DIR)
  {
    if (h->Attr!=FA_DIR)
      h->Attr&=~FA_DIR;
    else
    {
      h->OrgSiz=h->PacSiz=0;
      lastarclen=read;
    }
  }

  nextarcpos=lastarcpos+lastarclen;
  if (nextarcpos>arclen)
    nextarcpos=arclen;
  else
    nextoffset=lastarclen-read;

#ifdef __SHELL__
  if (command)
  {
    if (lastarcpos==searchpos)
    {
      register filebuf *f=next_buf;

      cmd_found=SUCCS;
      last_buf=next_buf;
      searchpos=-1;

      while ((f=f->next)!=NULL)
      {
        if ((f->flag & (FA_SELECTED|FA_EDITED)) && f->seek_pos>=0)
        {
          next_buf=f;
          searchpos=f->seek_pos;
          break;
        }
      }

      if (!cmdupdate && !flg_d)
      {
        nextoffset+=searchpos-nextarcpos;
        nextarcpos=searchpos;
      }
    }
    else
      cmd_found = FAULT;
  }
#endif

  fnamecnv (strcpy (dosfilename, matchfilename), 1);
  UnixFile = strcmp (get_fname (dosfilename), get_fname (matchfilename));

  if (!unix && !UnixFile && (Case != _PC_CASECONV) && !flg_S)
  {
    strupr (strcpy (fname, dosfilename));
    if (strcmp (fname, dosfilename) == 0)
      strlwr (dosfilename);
  }

  if (!cmdlist && !flg_S && (Case == _PC_CASECONV))
    strcnv (matchfilename, FAULT);

  if (!ferror(arc))
  {
    found++;
    return(SUCCS);
  }

  no_hdr:
  if (ferror(arc))
        error(RDERR,infname,FAULT);
  else if (lastarcpos<(arclen-16))
  {
    if (search_lzh(arc,-1)>0)
    {
    #ifdef __SHELL__
      if (shell)
        SetMsg("Garbage found and skipped");
      else
    #endif
      #ifdef GERMAN
        print(" Zerstîrte Daten gefunden und Åberlesen",1);
      #else
        print(" Garbage found and skipped",1);
      #endif

      garbage++;
      errorlevel|=1024;
      goto _gethdr;
    }
    else if (!sfx && ((arclen & (~255l)) || lastarcpos<(arclen-1024) || !found))
    {
      #ifdef GERMAN
        sprintf(print_buf," öberflÅssige Daten am Archivende (%ld Bytes)",arclen-lastarcpos);
      #else
        sprintf(print_buf," Garbage found at the archive-end (%ld bytes)",arclen-lastarcpos);
      #endif

    #ifdef __SHELL__
      if (shell)
        ErrorAlert(print_buf);
      else
    #endif
        Print(1);
      errorlevel|=2048;
    }
  }

  return(FAULT);
}

int matchpat(uchar *p,register int pat,register int attr)
{
  register uchar c, *q, *name, path[MAXPATH];
  register int i, k, wild, retcode=FAULT;

#ifdef __SHELL__
  if (shell && pat<0)
  {
    if (stop)
      return(FAULT);
    else
      return(cmd_found && (last_buf->flag & FA_SELECTED));
  }
#endif

  if (*p=='\0')
    return(FAULT);

  if (attr & FA_DIR)
  {
    if (flg_f<2)
    {
      Nfile++;
      return(SUCCS);
    }
  }
  else if (flg_f==3)
    return(FAULT);

  name=get_fname(p);
  backpath(strcpy(path,p));

  for (i=(pat>=0) ? (pat+1) : patno;--i>=0;)
  {
    wild=(flg_W) ? flg_W : !travel_file[i];

    if (flg_p)
    {
      if (fnamecmp(path,travel_path[i],Case))
        continue;
    }
    else if ((k=travel_len[i])>0)
    {
      q=&path[k];
      c=*q;
      *q='\0';
      k=fnamecmp(path,travel_path[i],Case);
      *q=c;

      if (k)
        continue;
    }

    if (all || chk_wild(name,&fileregbuf[travel_file[i]],wild,Case))
    {
      for (k=exno;--k>=0;)
        if (chk_wild(name,exclude_file[k],0,Case))
          break;

      if (k<0)
      {
        if (pat<0)
        {
          patcnt[i]++;
          retcode=SUCCS;
        }
        else
          return(SUCCS);
      }
    }

    if (pat>=0)
      break;
  }

  if (retcode)
    Nfile++;

  return(retcode);
}

static uint ratio(ulong a,ulong b)
{
  register int i;

  if (!b)
    return(1000);

  for (i=0; i<3 && a<0x19999999L; i++)
    a*=10;
  for (;i<3;i++)
    b/=10;
  a+=b/2;
  return((uint) (a/b));
}

static void get_mem(void)
{
  if (!fbuf)
  {
    if ((fbmax=((long) Malloc(-1L)))>160000L && flg_L<2)
      fbmax>>=1;
    fbuf=fbnxt=Malloc(fbmax);

    if (!fbuf)
      error(MEMOVRERR,NULL,SUCCS);

    *((long *) fbuf)=0l;
    fblft=(fbmax-=256)-4;
    fbnxt+=4;
    fblast=(filebuf *) fbuf;
  }
}

void regfile(uchar *p,uchar *q,_DTA *file,uchar *f)
{
  register uchar *s;
  register filebuf *f0, *f1;
  register int attr, len;
  register uchar ch;

  attr=(oldtos) ? file->dta_attribute^FA_CHANGED : file->dta_attribute;
  if (attr & FA_DIR)
    attr=FA_DIR;
  else
  {
    if (flg_arc && !(attr & FA_CHANGED))
      return;
    else if (flg_j && file->dta_size==0)
      return;
    else if (maxlen>0 && file->dta_size>maxlen)
      return;
    else if (cmd=='C' && file->dta_size<=min_len)
      return;
  }

  if (strstr(f,TEMPFILE))
    return;

  get_mem();
  f1=(filebuf *) fbnxt;
  strcpy(s=stpcpy(f1->dir,p),f);

  if (o_dir && !fnamecmp(f1->dir,o_dir,Case))
    return;

  f1->time.time=file->dta_time;
  f1->time.date=file->dta_date;

  if (flg_N && FTimeToULong(&newer)>FTimeToULong(&f1->time))
    return;

  f1->next=NULL;
  f1->fpos=s-(uchar *) f1;
  f1->cpos=flg_x ? ((q-p)+f1->dir-(uchar *) f1) : f1->fpos;
  f1->attr=attr;
  if((attr&FA_DIR) && flg_d && !flg_f) /* Dir-Eintrag fÅr "move" */
  {
    f1->flag=FA_DONE;
    fbfiles--;
  }
  else
    f1->flag=0;
  f1->Case=Case;
  f1->cluster=min_len;
#ifdef __SHELL__
  f1->unpacked=file->dta_size;
#endif

  if (patno>1 || !flg_x)
  {
    f=(uchar *) f1+f1->fpos;
    f0=(filebuf *) fbuf;
    ch=*f;

    while ((f0=f0->next)!=NULL)
    {
      p=(uchar *) f0+f0->fpos;
      if (ch==*p && !strcmp(f,p) && !strcmp((uchar *) f0+f0->cpos,(uchar *) f1+f1->cpos))
        return;
    }
  }

  if (fblft<sizeof(filebuf))
  {
    ignfile++;
    return;
  }

#ifdef __SHELL__
  if (shell)
  {
    if (attr & FA_DIR)
      drv_sel.dirs++;
    else
    {
      drv_sel.files++;
      drv_sel.bytes+=file->dta_size;
    }
  }
#endif
  len=(int) (strlen(f1->dir)+(f1->dir-(uchar *) f1))+1;
  len+=len & 1;

  fblast->next=fbnxt;

  fblast=(filebuf *) fbnxt;
  fblft-=len;
  fbnxt+=len;
  fbfiles++;

  if (flg_n!=1 && !(fbfiles & 15))
  {
    sprintf(print_buf,"\b\b\b\b%4d",fbfiles);
    Print(0);
  }
}

void regfreshen(uchar *p,int attr)
{
  register filebuf *f1;
  register int len;

  get_mem();
  if (fblft<sizeof(filebuf))
    return;

  f1=(filebuf *) fbnxt;
  f1->next=NULL;
  strcpy(f1->dir,p);
  f1->attr=attr;

  len=(int) (strlen(f1->dir)+(f1->dir-(uchar *) f1))+1;
  len+=len & 1;

  fblast->next=fbnxt;
  fblast=(filebuf *) fbnxt;
  fblft-=len;
  fbnxt+=len;
}

static int read_attr (uchar *path, _DTA *dta)
{
  XATTR xattr;
  long ok;

  ok = Fxattr (0, path, (uchar*) &xattr);

  if (ok != -32L)
  {
   dta->dta_time = xattr.mtime;
   dta->dta_date = xattr.mdate;
   dta->dta_size = xattr.size;
   dta->dta_attribute = xattr.attr;
  }
  else
  {
    ok = Fsfirst (path, 0xBF);
  }

  return ((int) ok);
}

static int Attrib (uchar *p)
{
  register int ok;

  ok = read_attr (p, &_dta);

  if (!ok)
  {
    return (_dta.dta_attribute & 0x3f);
  }
  else
  {
    return (0xF000);
  }
}

static int tst_fname(uchar *fname)
{
  register uchar c, s=' ';

  if (fname[0]=='\0')
    return (FAULT);
  else if (fname[0]!='.' || (fname[1]!='\0' && (fname[1]!='.' || fname[2]!='\0')))
  {
    while ((c=*fname++)!='\0')
    {
      if (c<s)
        return (FAULT);
    }
    return (SUCCS);
  }
  else
    return (FAULT);
}

static void add_dir(uchar *p)
{
 char buf[MAXPATH];
 _DTA x;

 x.dta_attribute=FA_DIR;
 strcpy(buf,p);
 backpath(buf);
 buf[strlen(buf)-1]='\0';
 if(strchr(buf,'\\')==0L)
   regfile("","",&x,buf);
 else
 {
   p=backpath(buf);
   regfile(buf,buf,&x,p);
 }
}

static void travel(uchar *p,uchar *q,int pat)
{
  _DTA dta, *old;
  register _DTA *d=&dta;
  register int done, compare, filesys;
  register long handle, buf[MAXPATH>>2];
  register uchar *s, *name;

  static level=0;

  filesys=(_gemdos || (!flg_S && Case==_PC_CASECONV));
  compare=(!flg_S && Case==_PC_CASEINSENS);

  if (!_gemdos)
  {
    name=(uchar *) &buf[1];

    if (*p!='\0')
      handle=Dopendir(p,0);
    else
      handle=Dopendir(act_dir,0);

    if ((handle&0xff000000l)==0xff000000l)
      return;
    else
      done=(int) Dreaddir(MAXPATH,handle,(uchar *) buf);

  #ifdef __SHELL__
    dir_handle[dirs]=handle;
    dirs++;
  #endif
  }
  else
  {
    name=d->dta_name;

    strcat(p,"*.*");

    old=Fgetdta();
    Fsetdta(d);
    done=Fsfirst(p,0xbf);
  }

  s=backpath(p);

  while (!done)
  {
    if (tst_fname(name))
    {
      if (!_gemdos)
      {
        strcpy(s,name);
        read_attr(p,d);
      }

      if ((!flg_a && (d->dta_attribute & (FA_HIDDEN|FA_SYSTEM))) || (d->dta_attribute & FA_LABEL))
        goto travel_next;
      else
      {
        if (filesys)
          strcnv(name,SUCCS);

        if (d->dta_attribute & FA_DIR)
        {
          if (flg_f>1)
          {
            strcpy(s,name);
            if (compare)
              strcnv(s,SUCCS);

            if (matchpat(p,pat,FA_DIR))
            {
              *s='\0';
              regfile(p,q,d,name);
            }
          }
          else if ((flg_f || flg_d) && travel_wild[pat])
          {
            *s='\0';
            regfile(p,q,d,name);
          }

          if (flg_r && travel_wild[pat])
          {
            strcpy(stpcpy(s,name),"\\");

            if (strlen(p)>=pt_name)
              message(M_TOOLONGERR,p);
            else
            {
            #ifdef __SHELL__
              register int old=fbfiles;
            #endif
              level++;
              travel(p,q,pat);
              level--;
            #ifdef __SHELL__
              if (shell && old==fbfiles)
              {
                *s='\0';
                regfile(p,q,d,name);
              }
            #endif
            }
          }
        }
        else if (flg_f<3)
        {
          strcpy(s,name);
          if (compare)
            strcnv(s,SUCCS);

          if (matchpat(p,pat,0))
          {
            *s='\0';
            regfile(p,q,d,name);
          }
        }
      }
    }

    travel_next:

    if (_gemdos)
      done=Fsnext();
    else
      done=(int) Dreaddir(MAXPATH,handle,(uchar *) buf);
    *s='\0';
  }

  if(level==0 && !flg_f && flg_d) /* Verzeichnis aufnehmen, fÅr "move" */
    add_dir(p);

  if (_gemdos)
    Fsetdta(old);
  else
  {
    Dclosedir(handle);
  #ifdef __SHELL__
    dirs--;
  #endif
  }
}

static int drive(uchar *path,uchar **p)
{
  register int drv;

  if (path[0] && path[1]==':')
  {
    drv=toupper(path[0]);
    path+=2;
  }
  else
  {
    path=act_dir;

    if (path[0] && path[1]==':')
    {
      drv=toupper(path[0]);
      path+=2;
    }
    else
      drv=Dgetdrv()+'A';
  }

  if (drv=='U')
  {
    if (path[0]=='\\' && path[1] && path[2]=='\\')
    {
      drv=toupper(path[1]);
      path+=2;
    }
  }

  if (p)
    *p=path;
  return(drv-'A');
}

void mklist(void)
{
  register _BPB *bpb;
  register uchar path[MAXPATH], *rel;
  register int i, new=0;

#ifdef __SHELL__
  register _DTA dta;
  register filebuf *file;
  register int last=-1,max=(shell) ? drv_lines : patno;

  SetMsg("Searching files...");

  fbfiles=Nfile=0;
  for (i=0;i<max;i++)
#else
  fbfiles=Nfile=0;
  for (i=0;i<patno;i++)
#endif
  {
  #ifdef __SHELL__
    file = drv_files[i];

    if (shell)
    {
      if (!(file->flag & FA_SELECTED))
        continue;
    }
    else
  #endif
    {
      #ifdef GERMAN
        sprintf(print_buf,"\r Suchmuster : (%d/%d), Dateien gefunden : %4d",i+1,patno,Nfile);
      #else
        sprintf(print_buf,"\r Pattern : (%d/%d), Files matched : %4d",i+1,patno,Nfile);
      #endif
      Print(0);
    }

  #ifdef __SHELL__
    if (shell)
    {
      new = (file->attr & FA_DIR);
      rel=strcpy(path,file->name+2);
      if (new)
        slash(path,1);
    }
    else
  #endif
    {
      rel = travel_path[i];
      if (!i)
        new=SUCCS;
      else
        new=fnamecmp(path,rel,_PC_CASESENS);

      rel=strcpy(path,rel);

      if (cmd=='C' && new && (bpb=Getbpb(drive(path,NULL)))!=NULL)
        min_len=bpb->clsizb;
      else
        min_len=1024;

    #ifdef __SHELL__
      if (flg_X)
    #else
      if (pack || flg_X)
    #endif
        rel+=strlen(path);
      else if (travel_rel[i])
        rel+=travel_rel[i];
      else
      {
        if (*rel && rel[1]==':')
          rel+=2;

        if (*rel=='\\' && flg_x==3)
          rel++;

        if (!strncmp(rel,".\\",2))
          rel+=2;
        else if (!strncmp(rel,"..\\",3))
          rel+=3;
      }
    }

  #ifdef __SHELL__
    if ((shell) ? (new || last) : new)
    {
      last = new;
  #else
    if (new)
    {
  #endif
      pt_name=path_conf(path,_PC_PATH_MAX);
      if (pt_name<=0 || pt_name>MAXPATH)
        pt_name=MAXPATH;
      Case=case_sensitive(path);

      _gemdos=(path_conf(path,_PC_NAME_MAX)==12 && Case==_PC_CASECONV);
    }

  #ifdef __SHELL__
    if (shell)
    {
      if (new && flg_r)
        travel(path,rel,0);

      if (!new || (fbfiles==Nfile))
      {
        rel="";
        if (new)
          strcpy(path,file->name+2);
        if (_gemdos || Case==_PC_CASECONV)
          strcnv(path,SUCCS);
        dta.dta_time=file->time.time;
        dta.dta_date=file->time.date;
        dta.dta_size=file->unpacked;
        dta.dta_attribute=file->attr;
        regfile(rel,rel,&dta,path);
      }
    }
    else
  #endif
    {
      travel(path,rel,i);
      patcnt[i]=fbfiles-Nfile;
    }
    Nfile=fbfiles;
  }

  Mshrink(fbuf,fbmax-fblft+32);

#ifdef __SHELL__
  if (shell)
  {
    make_info(1,&drv_sel);
    if (ignfile)
    {
      stop=SUCCS;
      sprintf(print_buf,"File table overflow, %d file(s) ignored! Use minimal or medium memory-usage!",ignfile);
      ErrorAlert(print_buf);
      error(-1,NULL,SUCCS);
    }
  }
  else
#endif
  {
    if (ignfile)
    #ifdef GERMAN
      sprintf(print_buf,"\b\b\b\b%4d\r\nDatei-Tabelle voll, %d Datei(en) ignoriert",ignfile);
    #else
      sprintf(print_buf,"\b\b\b\b%4d\r\nFile table overflow, %d file(s) ignored",ignfile);
    #endif
    else
      sprintf(print_buf,"\b\b\b\b%4d",Nfile);
    Print(2);
  }
}

void blkdisp(long len,uchar *s,uchar *fname,uchar *comment)
{
  uchar buf[256];
  register int i;
  static const long _proc_size[] =
  {
    1000000L,
    10000000L,
    100000000L,
    1000000000L
  };


  blocksize=(N*2);
  blkcnt=(int) ((len+blocksize-1)/blocksize);

  for (i=0;i<(sizeof(_proc_size)>>2);i++)
    if (len<_proc_size[i])
      break;

  _frozen_str[16]=_frozen_str[24]=(i+'6');
  file_len=len;
  act_len=0;

  if (comment && *comment && flg_x && (cmd!='P' || pager))
  {
    print(fname,1);
    fname=NULL;

    print(comment,1);
  }

  if (!flg_n)
  {
    register uchar pind[MAXPATH],*p=pind,c=pnt;

    if (blkcnt>maxblk)
    {
      blkcnt=maxblk;
      blocksize=len/maxblk;
    }
    else if (!blkcnt)
      blkcnt++;

    for (i=blkcnt;--i>=0;)
      *p++=c;
    *p='\0';

    if (fname)
      sprintf(buf,"%s\r\n %s :    %s\r %s :    ",fname,s,pind,s);
    else
      sprintf(buf," %s :    %s\r %s :    ",s,pind,s);
    print(buf,0);
  }
  else if (flg_n==1)
  {
    if (fname)
      print(fname,1);
  }
  else if (flg_n==2)
  {
    memcpy(_proc_str+2,s,8);
    _proc_str[20]=_proc_str[25]=_frozen_str[16];

    if (fname)
    {
      uchar ind[40];

      strcpy(stpcpy(ind,"%s\r\n"),_proc_str+1);
      sprintf(buf,ind,fname,0,0l,len);
    }
    else
      sprintf(buf,_proc_str+1,0,0l,len);
    print(buf,0);
  }
  else if (flg_n==3)
  {
    if (fname)
      sprintf(buf,"%s\r\n %s:   -\b",fname,s);
    else
      sprintf(buf," %s:   -\b",s);
    print(buf,0);
    RotInd=1;
  }
#ifdef __SHELL__
  else if (flg_n==4)
    DialIndicator(0);
#endif
}

static void MakeBuffers(void)
{
  register long buf, len=0;

  if (ebuf==NULL)
  {
    if (cmdupdate && !flg_u && FlgMethod==5)
    {
      if ((buf=(long) Malloc(ENCODE5))!=0L)
      {
        ebuf=(uchar *) buf;
        buf=(buf+=63) & (~15L);

        memset(ebuf,0,ENCODE5);

        text=(uchar *) buf;
        level=(uint *) (buf+=TEXT);
        childcount=&level[1];
        position=(short *) (buf+=LEVEL);
        parent=(short *) (buf+=POSITION);
        prev=(short *) (buf+=PARENT);
        next=(short *) (buf+=PREV);
      }
      else
        error(MEMOVRERR,NULL,SUCCS);
    }
    else if (FlgMethod!=5 || !cmdupdate)
    {
      if ((buf=(long) Malloc(ENCODE))!=0L)
      {
        ebuf=(uchar *) buf;
        buf=(buf+=63) & (~15L);

        memset(ebuf,0,ENCODE);

        lson=(int *) buf;
        rson=(int *) (buf+=LSON);
        dad=(int *) (buf+=RSON);
      }
      else
        error(MEMOVRERR,NULL,SUCCS);
    }
  }

  if (!flg_L)
  {
    len=((long) Malloc(-1L)/6) & (~8191l);
    if (len>MAXBUFFER)
      len=MAXBUFFER;
  }
  else if (flg_L==2)
  {
  #ifdef __SHELL__
    if (shell)
      len=(((long) Malloc(-1L)-120000L-alert_buf)/3) & (~8191l);
    else
  #endif
      len=(((long) Malloc(-1L)-120000L)/3) & (~8191l);
    if (len>MAXBUFFERL2)
      len=MAXBUFFERL2;
  }

  if (len<=BUFFERSIZ || (buf=(long) Malloc(((len+=128)*3)+128))==0L)
  {
    buf=(long) buffer;
    len=BUFFERSIZ+128;
  }
  else
    bbuf=(uchar *) buf;

  buffer_gen=(uchar *) ((buf+16) & (~15l));
  buffer_1=buffer_gen+len;
  buffer_3=buffer_1+len;
  bsize=len-128;
}

static void copyfile(FILE *Source,FILE *Dest,uchar *outfname,long size,int crcflg,int bufflg)
{
  register uchar *ptr;
  register long n, block;

  if (crcflg)
    crc=0;

  if (!crcflg || blocksize>bsize || flg_n==1)
    block=bsize;
  else
    block=blocksize;

  if (bufflg)
    ptr=outrec.ptr;
  else
    ptr=buffer_gen;

  while (size>0)
  {
    n=block>size ? size : block;

    if (bufflg && (outrec.cnt-n)<0)
    {
      ShipOut();
      ptr=outrec.ptr;
    }

    if (fread(ptr,n,1,Source)!=1)
      error(RDERR,infname,SUCCS);

    if (crcflg)
    {
      if (!flg_chk)
        block_crc(n,ptr);
      code(ptr,n);
      ProcInd();
    }

    if (Dest)
    {
      if (fwrite(ptr,n,1,Dest)!=1)
        error(WTERR,outfname,SUCCS);
    }
    else if (bufflg)
    {
      outrec.ptr=(ptr+=n);

      if ((outrec.cnt-=n)<=0)
      {
        ShipOut();
        ptr=outrec.ptr;
      }
    }

    size-=n;
  }

  if (ferror(Source))
    error(RDERR,infname,SUCCS);
}

void freeze(uchar *p,int attr,int file,int Case)
{
  register int unpck=flg_u;
  register long arcpos;

  crc=ship=0;

  if (!unpck && flg_U && !flg_5 && !compress && chk_wild(get_fname(p),unpack,0,Case))
    unpck=SUCCS;

  if (flg_t && FTimeToULong(&arcstamp)<FTimeToULong(&Hdr2.Ftime))
    arcstamp=Hdr2.Ftime;

  if (file>0)
  {
    if (attr & FA_DIR)
    #ifdef GERMAN
      sprintf(print_buf,"(%d/%d): %s: Verzeichnis",file,Nfile,p);
    #else
      sprintf(print_buf,"(%d/%d): %s: Directory",file,Nfile,p);
    #endif
    else
      sprintf(print_buf,"(%d/%d): %s",file,Nfile,p);
  }
  else if (attr & FA_DIR)
    #ifdef GERMAN
      sprintf(print_buf,"%s: Verzeichnis",p);
    #else
      sprintf(print_buf,"%s: Directory",p);
    #endif
  else
    strcpy(print_buf,p);

  infname=p;

  if (flg_e)
  {
    Print(1);
    get_comment(stdin);
    blkdisp(Hdr2.OrgSiz,(unpck || (attr & FA_DIR)) ? "Storing " : "Freezing",NULL,NULL);
  }
  else
    blkdisp(Hdr2.OrgSiz,(unpck || (attr & FA_DIR)) ? "Storing " : "Freezing",print_buf,NULL);

  if (attr & FA_DIR)
  {
    Hdr2.PacSiz=Hdr2.OrgSiz=0;
    wthdr(&Hdr2,SUCCS,SUCCS);
    arcpos0=arcpos1;
    ProcInd();
  }
  else
  {
    if (!unpck || cmd!='C')
      wthdr(&Hdr2,SUCCS,unpck);

    origsize=textsize=Hdr2.OrgSiz;
    codesize=compsize=0;

    key=key_word;
    if (unpck)
      codesize=textsize+1;
    else if (method==0)
      EncodeOld();
    else if (method==1)
    {
      ProcInd();
      memset(hfreq,0,(long) (&text_buf[16384]-(uchar *) hfreq));
      Encode();
    }
    else if (method==5)
    {
      init_encode5();
      encode5();
      codesize=compsize;
    }


    if (cmd=='C' && ((origsize+min_len-1)/min_len)<=((codesize+header_len+min_len-1)/min_len))
    {
      flg_unpacked=1;

      while ((long) origsize>0)
        {
          ProcInd();
          origsize-=blocksize;
        }

      Hdr2.PacSiz=Hdr2.OrgSiz;
      goto _freeze_end;
    }
    else if (!compress && codesize>=origsize)
    {
      flg_unpacked=1;

      arcpos=arcpos1+Hdr2.OrgSiz;
      Hdr2.PacSiz=Hdr2.OrgSiz;

      if (flg_4)
        memcpy(Hdr2.HeadID,"-lz4-",5);
      else
        memcpy(Hdr2.HeadID,"-lh0-",5);

      if (!unpck)
      {
        if (buffered)
        {
          outrec.ptr=buffer_last;
          outrec.cnt=buffer_cnt;
        }
        else
        {
          OpenOut(&outrec,buffer_gen);
          Fseek(arcpos1,file2,SEEK_SET);
        }

        fseek(file3,0l,SEEK_SET);
      }

      copyfile(file3,NULL,backup2,Hdr2.OrgSiz,1,1);
    }
    else
    {
      arcpos=arcpos1+codesize;
      Hdr2.PacSiz=codesize;
      flg_unpacked=0;
    }

    wthdr(&Hdr2,FAULT,FAULT);
    arcpos0=arcpos;
  }

  _freeze_end:

#ifdef __SHELL__
  if (shell)
    FrozenMsg(flg_unpacked || (attr & FA_DIR));
  else
#endif
  if (flg_n!=1)
  {
    memcpy(_frozen_str+5,(flg_unpacked || (attr & FA_DIR)) ? "Stored:   " : "Frozen:   ",10);
    sprintf(print_buf,_frozen_str,Hdr2.OrgSiz,Hdr2.PacSiz,ratio(Hdr2.PacSiz,Hdr2.OrgSiz)/10);
    Print(1);
  }

  *comment='\0';
}

void get_comment(FILE *f)
{
  register int len;
  register uchar *q, *input=comment;

  if (f==stdin)
    print(M_COMMENT,1);

  while (fgets(input,255,f))
  {
    if ((q=strchr(input,'\r'))!=NULL || (q=strchr(input,'\n'))!=NULL)
      *q='\0';

    if ((len=(int) strlen(input))>0 || f!=stdin)
    {
      input+=len;
      if (!flg_s)
        *input++='\r';
      *input++='\n';

      if ((int) (input-comment)>=MAXCOMMENT)
        break;
    }
    else
      break;
  }

  if (input>comment)
  {
    comment[MAXCOMMENT-1]='\0';

    if (flg_s)
      input[-1]='\0';
    else
      input[-2]='\0';
  }
  else
    *comment='\0';
}

void archive_comment(void)
{
#ifdef __SHELL__
  if (shell)
    strcpy(comment,arc_comment);
  else
#endif
  if (com_name)
  {
    register FILE *f;

    if ((f=fopen(com_name,"r"))!=NULL)
    {
      get_comment(f);
      fclose(f);
    }
  }
  else
    get_comment(stdin);

  if (*comment)
  {
    arcpos0=(long) stpcpy(stpcpy(outrec.ptr,COM_ID),comment) - (long) outrec.ptr +1l;
    outrec.ptr+=arcpos0;
    outrec.cnt-=arcpos0;
    *comment='\0';
  }
}

#ifdef __SHELL__
void free_commem(void)
{
  if (shell && cmd_found && (last_buf->flag & FA_COMALLOC))
    free(last_buf->comment);
}
#endif

void copyold(void)
{
  infname=arcname;
  if (flg_t && FTimeToULong(&arcstamp)<FTimeToULong(&Hdr1.Ftime))
    arcstamp=Hdr1.Ftime;
  fseek(file1,lastarcpos,SEEK_SET);
  copyfile(file1,NULL,backup2,lastarclen,0,1);
  arcpos0+=lastarclen;
#ifdef __SHELL__
  free_commem();
#endif
}

static int execappend (void)
{
  register filebuf *f0;
  register uchar   *q;
  int               found, update, in_arc;
  int               cnt = 0, old = 0, file = 1;

  f0 = (filebuf*) fbuf;
  in_arc = (file1) ? gethdr (file1, &Hdr1) : FAULT;

  for (;;)
  {
    update = found = FAULT;

    if (in_arc)
    {
      f0 = (filebuf*) fbuf;
      q = get_fname (matchfilename);

    #ifdef __SHELL__
      if (!stop)
    #endif
      while ((f0 = f0->next) != NULL)
      {
        if (!(f0->flag & FA_DONE) && fnamecmp ((uchar*) f0 + f0->fpos, q, f0->Case) == 0)
        {
          if (flg_I)
          {
            strcpy (stpcpy (inclpath, incldir), (uchar*) f0 + f0->cpos);
            if (!flg_S && (f0->Case == _PC_CASECONV))
              strcnv (inclpath, SUCCS);
          }

          if (fnamecmp((flg_I) ? inclpath : (uchar*) f0 + f0->cpos, matchfilename, f0->Case) == 0)
          {
            found = SUCCS;
            if (!flg_A)
              update = SUCCS;
            f0->flag |= FA_DONE;
            break;
          }
        }
      }
    }
    else
    {
    #ifdef __SHELL__
      if (stop)
        break;
    #endif
      while ((f0 = f0->next) != NULL)
      {
        if (!(f0->flag & FA_DONE))
        {
          if (flg_I)
          {
            strcpy (stpcpy (inclpath, incldir), (uchar*) f0 + f0->cpos);
            if (!flg_S && (f0->Case == _PC_CASECONV))
              strcnv (inclpath, SUCCS);
          }

          f0->flag |= FA_DONE;
          update = SUCCS;
          break;
        }
      }

      if (!f0)
        break;
    }

  #ifdef __SHELL__
    if (shell && (update || found))
    {
      infname = f0->dir;
      Hdr2.OrgSiz = f0->unpacked;
      Hdr2.Attr = f0->attr;
    }
  #endif

    if (update && (!in_arc || flg_c || (FTimeToULong (&Hdr1.Ftime) < FTimeToULong (&f0->time))))
    {
      if (f0->attr & FA_DIR)
        file3=NULL;
      else if ((file3 = e_fopen (f0->dir, buffer_3, "rb", RDERR, FAULT)) == NULL)
      {
      #ifdef __SHELL__
        if (shell)
          DialIndicator (1);
      #endif
        goto _skip_file;
      }

      sethdr ((flg_I) ? inclpath : (uchar*) f0 + f0->cpos, f0->attr, &f0->time, &Hdr2, SUCCS);
      freeze (f0->dir, f0->attr, file, f0->Case);
      close_file (file3);
      cnt++;

      if (in_arc)
        sseek(file1, nextarcpos, nextoffset);
    }
    else
    {
      if ((old != file) && (file <= Nfile))
      {
      #ifdef __SHELL__
        if (shell)
        {
          if (found)
            skip (infname, (flg_A) ? "File already exists" : "New or same file exists", 0);
        }
        else
      #endif
        {
          sprintf (print_buf, "(%d/%d):\r", file, Nfile);
          Print (0);
          old = file;
        }
      }

      _skip_file:
      if (in_arc)
      {
        if (flg_D && !found)
        {
          sseek (file1, nextarcpos, nextoffset);
          cnt++;
        }
        else
          copyold ();
      }
    }

    if (in_arc && (in_arc = gethdr (file1, &Hdr1)) == FAULT)
      f0 = (filebuf*) fbuf;

    if (update)
      file++;
  }

  return (cnt);
}

void delfile(void)
{
  register int attr, new_attr;
  register filebuf *f0;

  if (!fbuf || !(flg_d || flg_backup))
    return;

#ifdef __SHELL__
  if (shell)
    SetMsg((flg_d) ? "Deleting original files..." : "Clearing archive bits...");
  else
#endif
  #ifdef GERMAN
    print((flg_d) ? "Lîsche Original-Dateien..." : "Lîsche Archiv-Bits...",1);
  #else
    print((flg_d) ? "Deleting original files..." : "Clearing archive bits...",1);
  #endif

  f0=(filebuf *) fbuf;
  while ((f0=f0->next)!=NULL)
  {
    attr = f0->attr;
    if (!(attr & FA_DIR))
    {
      if (flg_d)
        fdelete(f0->dir,attr);
      else
      {
        new_attr=attr & (~FA_CHANGED);
        if (attr!=new_attr)
          Fattrib(f0->dir,1,(oldtos) ? new_attr^FA_CHANGED : new_attr);
      }
    }
  }

  /*  Jetzt versuchen wir noch, die Ordner zu lîschen.
   *  Der Einfachheit halber ignorieren wir den RÅckgabewert
   *  von Ddelete(), es kînnten ja noch Files drin sein.
   */
  if(flg_d)
  {
    f0=(filebuf *) fbuf;
    while ((f0=f0->next)!=NULL)
    {
      attr = f0->attr;
      if (attr & FA_DIR)
        Ddelete(f0->dir);
    }
  }
}

int search_lzh(FILE *input,int mode)
{
  register long len, pos;

  if (mode<0)
  {
    fflush(input);
    pos=lastarcpos+MINHDR;
    fseek(input,pos,SEEK_SET);
  }
  else
    arcpos0=arcpos1=nextarcpos=lastarcpos=pos=0;

  _cont_search:
#ifdef __SHELL__
  if (command && mode>=0)
  {
    register filebuf *f=arc_buf;

    searchpos=-1;
    while ((f=f->next)!=NULL)
      if ((f->flag & (FA_SELECTED|FA_EDITED)) && f->seek_pos>=0)
      {
        next_buf=f;
        searchpos=f->seek_pos;

        if (mode==1)
        {
          fseek(input,nextarcpos=searchpos,SEEK_SET);
          return(1);
        }
        else
          break;
      }

  }
#endif

  if (mode>=0)
    sfx=0;

  if ((len=Fread(fileno(input),1024l*10,text_buf))>5)
  {
    register uchar *ptr=text_buf, *last=ptr+len-5, c, s='-';

    if (mode>=0)
    {
      arcpos0=Fseek(0l,fileno(input),SEEK_CUR)-len;
      arclen=Fseek(0l,fileno(input),SEEK_END);
      Fseek(arcpos0,fileno(input),SEEK_SET);
      arcpos0=0;
    }

    for (;ptr<last;ptr++)
      if (*ptr==s && ptr[4]==s)
      {
        c=ptr[1];
        if (c=='l' || c=='L' || c=='a' || c=='A')
        {
          if (ptr>=(text_buf+2))
          {
            if (flg_z && (mode==0 || mode==2))
              archive_comment();

            fseek(input,nextarcpos=pos+((ptr-2)-text_buf),SEEK_SET);
            return(1);
          }
        }
        else if (c=='c' && ptr[2]=='o' && ptr[3]=='m' && mode>=0)
        {
          if (!flg_z && (mode==0 || mode==2))
          {
            arcpos0=(long) stpcpy(outrec.ptr,ptr) - (long) outrec.ptr + 1l;
            outrec.ptr+=arcpos0;
            outrec.cnt-=arcpos0;
          }

          strncpy(comment,ptr+=5,MAXCOMMENT);
          convert_comment();

          if (mode>0)
          {
            sprintf(print_buf,"\r\n%s\r\n\r\n",comment);
            pager_print(0);

            if (!pager && (cmd!='P' || flg_v<2))
              wait_for_key(1);
          }

          ptr+=strlen(ptr);
        }
      }
      else if (*ptr=='S' && ptr[1]=='F' && ptr[2]=='X')
      {
        ptr+=3;
        sfx++;
      }
  }

  if (mode>=0)
  {
    error(NOFILEERR,arcname,(mode>0) ? 128 : SUCCS);
    if (mode>0 && len<5)
      return (-1);
  }
  else if (len>5 && (pos+=len)<arclen)
  {
    Fseek(pos,fileno(input),SEEK_SET);
    goto _cont_search;
  }

  return(0);
}

static int openarc1(long size,uchar *buffer)
{
  int search;

  if ((file1=e_fopen(infname=arcname,NULL,"rb",NOARCERR,FAULT))!=NULL)
  {
    if ((search=search_lzh(file1,1))>0)
    {
      if (buffer!=NULL)
        setvbuf(file1,buffer,_IOFBF,size);
      INIT_TIMER;
    }
    else
      close_file(file1);
    return(search);
  }
  else
    return(-2);
}

void get_tempname(uchar *path)
{
  register uchar *ext;

  strcat(path,TEMPFILE);
  ext=path+strlen(path);

  do
  {
    sprintf(ext,"%X",temp());
  } while (Attrib(path)>=0);
}

void openbackup1(void)
{
  back_1++;

  backpath(strcpy(backup1,arcname));
  get_tempname(backup1);

  if (rename(infname=arcname,backup1))
    error(RENAMEERR,arcname,SUCCS);

  file1=e_fopen(backup1,buffer_1,"rb",WTERR,SUCCS);
  arclen=Fseek(0l,fileno(file1),SEEK_END);
  Fseek(0l,fileno(file1),SEEK_SET);
  found=0;
}

void openbackup2(void)
{
  back_2++;

  if (Device)
    strcpy(backup2,arcname);
  else
  {
    if (flg_w)
      strcpy(backup2,workdir);
    else
      backpath(strcpy(backup2,arcname));
    get_tempname(backup2);
  }

  arcpos0=errno=0;
  file2=creat(backup2,0666);
  if (errno==EACCES)
    error(RDONLY,backup2,SUCCS);
  else if (errno)
    error(MKTMPERR,backup2,SUCCS);

  *((long *) &arcstamp)=0l;

  outfile=file2;
  OpenOut(&outrec,buffer_gen);
  INIT_TIMER;
}

static void set_time(int handle)
{
  if (flg_t)
    Fdatime(&arcstamp,handle,1);
#ifdef __SHELL__
  else if (shell && ainf_changed)
    Fdatime(&arc_time,handle,1);
#endif
}

void endofupdate(int cnt)
{
  if (file1)
  {
    set_time(fileno(file1));
    fclose(file1);
  }

  tstpat();

#ifdef __SHELL__
  if (cnt || ainf_changed)
#else
  if (cnt)
#endif
  {
    if (file1)
    {
      if (flg_B)
      {
        register uchar bakname[MAXPATH],*f;

        strcpy(bakname,arcname);
        if ((f=strrchr(get_fname(bakname),'.'))!=NULL && (arc_ext(f) || f[1]=='\0'))
          strcpy(f,".BAK");
        else
          strcat(bakname,".BAK");
        Fdelete(bakname);
        rename(backup1,bakname);
      }
      else
        Fdelete(backup1);
      file1=NULL;
    }

    if (arcpos0)
    {
      buf_putc(0);
      ShipOut();

      if (!Device)
      {
        register int flag = SUCCS;

        set_time(file2);
#ifdef MM_KLUDGE
        close(file2);
#else
        if (close(file2))
          error(WTERR,backup2,SUCCS);
#endif
        file2=0;

        if (flg_w==0 || drive(arcname,NULL)==drive(backup2,NULL))
          flag=rename(backup2,arcname);

        if (flag)
        {
        #ifdef __SHELL__
          if (shell)
            SetMsg("Copying temp to archive...");
          else
        #endif
          #ifdef GERMAN
            print("Kopiere temporÑres Archiv...",1);
          #else
            print("Copying temp to archive...",1);
          #endif

          file1=e_fopen(arcname,buffer_1,"wb",MKFILEERR,SUCCS);
          file3=e_fopen(backup2,buffer_3,"rb",0,FAULT);

          copying++;

          copyfile(file3,file1,arcname,arcpos0+1,0,0);
          if (fflush(file1))
            error(WTERR,arcname,SUCCS);

          set_time(fileno(file1));
#ifdef MM_KLUDGE
          fclose(file1);
#else
          if (fclose(file1))
            error(WTERR,backup2,SUCCS);
#endif

          copying=0;

          close_file(file3);
          Fdelete(backup2);
        }
      }
      else
        close(file2);
    }
    else
    {
      close(file2);

      if (!Device)
        Fdelete(backup2);
    }
  }
  else
  {
    close(file2);

    if (!Device)
    {
      Fdelete(backup2);
      rename(backup1,arcname);
    }
  }

  file1=NULL;
  file2=0;
}

void append(void)
{
  register int cnt;

  if (Device)
    file1=NULL;
  else if ((file1=fopen(arcname,"rb"))!=NULL)
  {
    close_file(file1);
    openbackup1();
  }

  mklist();
  if (!Nfile)
    error(NOFILEERR,NULL,SUCCS);

  if (flg_u && !flg_n)
    flg_n++;

  if (file1)
    message("Updating archive",arcname);
  else if (Device)
    message("Freeze/Store to",arcname);
  else
    message("Creating archive",arcname);

  openbackup2();
  if (file1)
    search_lzh(file1,0);
  else if (flg_z)
    archive_comment();

  cnt=execappend();
  endofupdate(cnt);
  delfile();
}

void pack_afx(void)
{
  register filebuf *f0;
  register int file=1, tst;
  register uchar *x;

  flg_x=3;
  old_afx=afxonoff(0L);

  mklist();
  if (!Nfile)
    error(NOFILEERR,NULL,SUCCS);

  FlgMethod=flg_x=0;
  f0=(filebuf *) fbuf;

  while ((f0=f0->next)!=NULL)
  {
    if ((x=strrchr(get_fname(f0->dir),'.'))!=NULL && (!stricmp(x,".O") || !stricmp(x,".LIB")))
      obj=SUCCS;
    else
      obj=FAULT;

    if ((tst=test_afx(f0->dir))==0)
    {
      if ((file3=e_fopen(f0->dir,buffer_3,"rb",RDERR,FAULT))!=NULL)
      {
        strcpy(backpath(strcpy(backup2,f0->dir)),"__temp__.lzs");

        errno=0;
        file2=creat(backup2,0666);
        if (errno==0)
        {
          outfile=file2;
          OpenOut(&outrec,buffer_gen);

          arcpos0=buffered=ship=0;
          min_len=f0->cluster;
          sethdr((uchar *) f0+f0->fpos,f0->attr,&f0->time,&Hdr2,SUCCS);
          freeze(f0->dir,f0->attr,file,f0->Case);

          if (!flg_unpacked)
          {
            if (buffered)
              ShipOut();
            Fdatime(&f0->time,file2,1);
          }

          close(file2);
          file2=0;

          close_file(file3);

          if (!flg_unpacked)
          {
            register int attr=f0->attr;

            fdelete(f0->dir,attr);

            if (rename(backup2,f0->dir))
              error(RENAMEERR,f0->dir,FAULT);
            else
            {
              if (flg_backup)
                attr &= ~FA_CHANGED;
              Fattrib(f0->dir,1,(oldtos) ? attr^FA_CHANGED : attr);
            }
          }
          else
            Fdelete(backup2);
        }
        else
        {
          close_file(file3);

          if (errno==EACCES)
            error(RDONLY,backup2,FAULT);
          else if (errno)
            error(MKTMPERR,backup2,FAULT);
        }
      }
    }
    else
    {
      register uchar *m;

      switch (tst)
      {
        case 1:
          #ifdef GERMAN
            m="Datei bereits im AFX-Format";
          #else
            m="Already in AFX-format";
          #endif
          break;
        case 2:
          #ifdef GERMAN
            m="Datei bereits im LHarc-Format";
          #else
            m="Already in LHarc-format";
          #endif
          break;
        case 3:
          #ifdef GERMAN
            m="Programm-Datei";
          #else
            m="Program-file";
          #endif
          break;
        default:
          #ifdef GERMAN
            m="Kann Datei nicht lesen";
          #else
            m="Read-Error";
          #endif
      }

      sprintf(print_buf,"(%d/%d): %s\r\n %s",file,Nfile,f0->dir,m);
      Print(1);
    }
    file++;
  }

  if (old_afx)
  {
    afxonoff(old_afx);
    old_afx=0;
  }
}

void make_fullpath(uchar *path)
{
  register uchar *p=stpcpy(path,basedir);

  if (flg_x)
  {
    if (dosfilename[0]=='\\')
    {
      p=path;
      if (*p && (p[1] == ':'))
      {
        if (toupper(*p)=='U' && p[2]=='\\' && p[3] && p[4]=='\\')
          p+=4;
        else
          p+=2;
      }
    }

    strcpy(p,dosfilename);
  }
  else
    strcpy(p,get_fname(dosfilename));
}

void freshen(void)
{
  _DOSTIME time;
  register uchar path[MAXPATH];
  register long ok;
  register int cnt=0, attr;

  Case=_PC_CASECONV;

  openbackup1();
  message("Freshening archive",arcname);

  openbackup2();
  search_lzh(file1,0);

  while (gethdr(file1,&Hdr1))
  {
  #ifdef __SHELL__
    if (command==4)
      copyold();
    else
  #endif
    {
      if (matchpat(matchfilename,-1,Hdr1.Attr))
      {
        ok=SUCCS;
        if (!(Hdr1.Attr & FA_DIR))
        {
          make_fullpath(path);
          ok=read_attr(path,&_dta);

          time.time=_dta.dta_time;
          time.date=_dta.dta_date;
          attr=_dta.dta_attribute;
          if (oldtos)
            attr ^= FA_CHANGED;

          if (!ok)
          {
            if (flg_d || flg_backup)
              regfreshen(path,attr);

            if ((flg_c || (FTimeToULong(&Hdr1.Ftime)<FTimeToULong(&time))) && (file3=fopen(path,"rb"))!=NULL)
            {
              sethdr(filename,attr,&time,&Hdr2,FAULT);
              freeze(path,attr,-1,1);
              close_file(file3);
              cnt++;
              sseek(file1,nextarcpos,nextoffset);
              continue;
            }
        #ifdef __SHELL__
            else
              skip(filename,"New or same file exists",0);
        #endif
          }
        }
      #ifdef __SHELL__
        if (command && ok)
          DialIndicator(1);
      #endif
      }

      copyold();
    }
  }

  endofupdate(cnt);
#ifdef __SHELL__
  if (command!=4)
#endif
  delfile();
}

static void skip(uchar *fname,uchar *msg,int plus)
{
#ifdef __SHELL__
  if (shell)
  {
    uchar name[MAXPATH];

    skipped++;
    slash(strcpy(name,fname),0);
    sprintf(print_buf,"Skipped %s: %s",get_fname(name),msg);
    DialIndicator(1);
    if (idx)
      SetMsg(print_buf);
  }
  else
#endif
  {
    sprintf(print_buf,"Skipped %s: %s",fname,msg);
    Print(1);
    skipped+=plus;
  }
}

int tstdir(uchar *name,int flag)
{
  register uchar yn, *p, path[MAXPATH];
  register int attr;

  if (!flag && flg_R && UnixFile)
  {
    sprintf(print_buf,"%s (%s):\r\n%s",name,get_fname(filename),M_ENTERNEW);
    Print(0);
    gets(path);

    if (path[0]!='\0')
    {
      strcpy(backpath(name),get_fname(path));
      fnamecnv(name,0);
    }
  }

Again:
  if (flag || flg_x)
  {
    if (flag>=0 && base>0)
      p=&name[base];
    else
    {
      p=name;
      if (*p && (p[1] == ':'))
      {
        p+=2;

        if (toupper(p[-2])=='U' && p[0]=='\\' && p[1] && p[2]=='\\')
          p+=2;
      }
    }

    if (*p=='\\')
      p++;

    if (flag>=0)
      yn=(flg_m>0 && flg_m<3) ? 'Y' : 'N';
    else
      yn='Y';

    while ((p=strchr(p,'\\'))!=NULL)
    {
      *p='\0';
      attr=Attrib(name);
      if (attr<0)
      {
        if (yn=='N')
        {
          sprintf(print_buf,"%s:\r\n%s",name,M_MKDIR);
          Print(0);

          if ((yn=get_key("YNA"))=='N')
            return(FAULT);
          else if (yn=='A')
          {
            flg_m=(flg_m) ? 1 : 2;
            yn='Y';
          }
        }

        if (Dcreate(name))
        {
          error(MKDIRERR,name,(flag<0) ? SUCCS : FAULT);
          return(FAULT);
        }
      }
      else if (!(attr & FA_DIR))
      {
        error(MKDIRERR,name,(flag<0) ? SUCCS : FAULT);
        return(FAULT);
      }
      *p++='\\';
    }
  }

  if (!flag)
  {
    if ((attr=Attrib(name))>=0)
    {
      if ((attr & FA_DIR) && !UnixFile)
      {
        skip(name,"Object with same name exists",0);
        return(FAULT);
      }
      else if ((!UnixFile || (flg_m & 0x01)) && !flg_c && (((ulong) _dta.dta_date<<16)|(uint) _dta.dta_time)>=FTimeToULong(&Hdr1.Ftime))
      {
        skip(name,"New or same file exists",0);
        return(FAULT);
      }
    #ifdef __SHELL__
      else if (shell)
      {
        if (!overwr_all)
          switch (OverWrMsg(name))
          {
            case -1:
              if (!stop)
                skip(name,"New or same file exists",0);
              return(FAULT);
            case 0:
              fnamecnv(name,0);
              goto Again;
          }
      }
    #endif
      else if ((flg_m & 0x01)==0)
      {
        if (UnixFile)
          sprintf(print_buf,"%s (%s):\r\n%s",name,get_fname(filename),M_OVERWT);
        else
          sprintf(print_buf,"%s:\r\n%s",name,M_OVERWT);
        Print(0);

        if ((yn=get_key("YNRA"))=='R')
        {
          print(M_ENTERNEW,0);
          gets(path);

          if (path[0]!='\0')
          {
            strcpy(backpath(name),get_fname(path));
            fnamecnv(name,0);
            goto Again;
          }
          else
            return(FAULT);
        }
        else if (yn=='N')
          return(FAULT);
        else if (yn=='A')
          flg_m=(flg_m) ? 1 : 3;
      }

      if (attr & FA_RDONLY)
      {
        if (attr!=Hdr1.Attr)
        {
          skip(name,M_RDONLY,0);
          return(FAULT);
        }
        else
          Fattrib(name,1,attr ^ FA_RDONLY);
      }
    }
  }

  return(SUCCS);
}

int tstID(uchar *h)
{
  static uchar IDpat[7][6]={"lz4","lz5","lh0","lh1","lh5","afx","lhd"};

  if (h[0]!='-' || h[4]!='-')
    return(-1);
  else
  {
    register int m=6;

    strlwr(++h);
    while (m>=0 && memcmp(h,IDpat[m],3))
      m--;

    return((m==5) ? 1 : m);
  }
}

static char *five_plus_three(char *to,char *from)
{
  int i;
  char *cp, *wp, *point;

  memset(to,0,13);
  cp=from;
  wp=to;
  point=strrchr(from,'.');
  if(point==0L) /* kein Punkt? */
  {
    if(strlen(from)>8) /* mehr als 8 Zeichen? -> 5+3 */
    {
      for(i=0;i<5;i++) *wp++=*cp++;
      cp=from+strlen(from)-3;
      for(i=0;i<3;i++) *wp++=*cp++;
    }
    else while(*cp) *wp++=*cp++; /* max. 8 -> umkopieren */
  }
  else if(point-cp>=8) /* mehr als 8 Zeichen vor dem Punkt */
  {
    for(i=0;i<5 && *cp;i++)
      if(*cp=='.') { *wp++='_'; cp++; }
      else *wp++=*cp++;
    cp=point-3;
    for(i=0;i<3 && *cp;i++)
      if(*cp=='.') { *wp++='_'; cp++; }
      else *wp++=*cp++;
  }
  else /* max. 8 Zeichen vor dem Punkt -> umkopieren */
  {
    for(i=0;i<8 && *cp && cp!=point;i++)
      if(*cp=='.') { *wp++='_'; cp++; }
      else *wp++=*cp++;
  }
  if(point) /* Extension (inkl. Punkt) */
  {
    cp=point;
    for(i=0;i<4 && *cp;i++)
      *wp++=*cp++;
  }
  cp=to;
  while(*cp)
    if(*cp>32 && *cp!=':' && *cp!='?' && *cp!='*') *cp++=toupper(*cp);
    else *cp++='_';
  return(to);
}

uchar *Trunc1File(uchar *s,uchar *d)
{
  register int l=(int) strlen(s);
  register uchar c, *t;

  if (_gemdos) /* Gemdos-Filesystem? */
  {
    if(flg_F) /* 5+3-Regel */
    {
      five_plus_three(d,s);
      d+=strlen(d);
    }
    else /* erste acht Buchstaben */
    {
      register i, j, k, m;

      for (c='.',t=&s[i=l];--i>=0;)
        if (*--t==c)
          break;

      m=(i<0) ? l : i;
      for (j=k=0,t=s;j<=7;j++)
      {
        c=*t++;
        if ((i>0 && k++>i) || c=='\0' || j>=m)
          break;

        if (c>32 && c!='.' && c!=':' && c!='*' && c!='?')
          *d++=c;
        else
          j--;
      }

      if (i>=0)
        for (t=&s[i],j=4;--j>=0;)
        {
          if ((c=*t++)>32)
          {
            if (c!=':' && c!='*' && c!='?')
              *d++=c;
          }
          else if (c=='\0')
            break;
        }
    }
  }
  else
  {
    strcpy(d,s);

    if (l<=fn_name)
      d+=l;
    else if ((t=strrchr(s,'.'))!=NULL && t>s)
    {
      l-=(int) (t-s);
      l=fn_name-l;
      if (d[l-1]=='.')
        l--;

      strcpy(d+l,t);
      d+=fn_name;
    }
    else
      d+=fn_name;
  }

  *d='\0';
  return(d);
}

void TruncFile(uchar *s)
{
  uchar file[MAXPATH], dest[MAXPATH];
  register uchar c, *f=file, *d=dest, *s1=s;

  *d='\0';
  while ((c=*s++)!='\0')
  {
    if (c=='\\' || c==':')
    {
      *d='\0';
      f=Trunc1File(dest,f);
      *f++=c;
      *f='\0';
      d=dest;
    }
    else
      *d++=c;
  }

  *d='\0';
  f=Trunc1File(dest,f);
  strcpy(s1,file);
}

int extract(void)
{
  register uchar *p, *q;
  register int m, succs, cnt=0;

  sprintf(print_buf,"Extract from: %s\r\n",arcname);
  pager_print(1);

#ifdef __SHELL__
  if (!shell && all && exno==0)
#else
  if (all && exno==0)
#endif
    flg_d=0;

  if (flg_d)
  {
    flg_t = 0;
  #ifdef __SHELL__
    if (!shell)
  #endif
      flg_z=0;
    openbackup1();
    openbackup2();
    if (search_lzh(file1,2)<=0)
    {
      close_file(file1);
      close(file2);
      file2=0;
      Fdelete(backup2);
      rename(backup1,arcname);
      return(0);
    }
  }
  else if (openarc1(bsize,buffer_1)<=0)
    return(0);

  while (gethdr(file1,&Hdr1))
  {
    succs=FAULT;
    if (matchpat(matchfilename,-1,Hdr1.Attr))
    {
      if (cmd=='E')
        make_fullpath(pathname);

    #ifdef __SHELL__
      if (shell && Hdr1.crypted && !flg_Y)
        set_crypt();
    #endif

      if ((m=tstID(Hdr1.HeadID))<0)
        skip(filename,"Unknown method",1);
      else if (cmd=='E' && maxlen>0 && Hdr1.OrgSiz>maxlen)
        skip(filename,"File too long",1);
      else if (cmd=='E' && !flg_a && (Hdr1.Attr & (FA_HIDDEN|FA_SYSTEM)))
        skip(filename,"Hidden/System file",1);
      else if (Hdr1.crypted && !flg_Y)
        skip(filename,"Encrypted file",1);
      else if (Hdr1.Attr & FA_DIR)
      {
        if (cmd=='E' && flg_x>0 && (succs=tstdir(strcat(pathname,"\\"),1))!=0)
        {
          cnt++;
          if (UnixFile)
            #ifdef GERMAN
              sprintf(print_buf,"%s (%s): Verzeichnis",pathname,filename);
            #else
              sprintf(print_buf,"%s (%s): Directory",pathname,filename);
            #endif
          else
            #ifdef GERMAN
              sprintf(print_buf,"%s: Verzeichnis",pathname);
            #else
              sprintf(print_buf,"%s: Directory",pathname);
            #endif

          blkdisp(0l,"Melted  ",print_buf,comment);
          ProcInd();

          if (flg_n!=1)
            print(NULL,1);

          if (flg_d)
            message("Deleting",filename);
        }
        else
          #ifdef GERMAN
            skip(filename,"Verzeichnis",0);
          #else
            skip(filename,"Directory",0);
          #endif
      }
      else if (cmd!='E' || tstdir(pathname,0))
      {
        textsize=Hdr1.OrgSiz;
        crypt_size=codesize=Hdr1.PacSiz;
        key=key_word;

        cnt++;
        crc=0;

        p="Melting ";
        q="Melted ";

        switch(cmd)
        {
          case 'E':
            if (UnixFile)
            {
              sprintf(print_buf,"%s (%s)",pathname,filename);
              blkdisp(textsize,p,print_buf,comment);
            }
            else
              blkdisp(textsize,p,pathname,comment);

            if ((file3=e_fopen(pathname,buffer_3,"wb",WTERR,FAULT))==NULL)
              goto _extract_next;
            break;
          case 'T':
            q="Tested ";
            blkdisp(textsize,"Testing ",filename,comment);
            file3=NULL;
            break;
          case 'P':
            sprintf(print_buf,"<<< %s >>>\r\n\r\n",filename);
            pager_print(0);
            blkdisp(textsize,p,(pager) ? filename : NULL,comment);
            break;
        }

        if (file3==stdout)
          flg_n=1;

        succs=SUCCS;

        switch(m)
        {
          case 1:
          case 3:
            if (cmd=='P')
              fflush(file3);
            decrypt(0);
            if (m==1)
              DecodeOld();
            else
              Decode();
            break;
          case 4:
            decrypt(0);
            succs=decode_lh5(textsize,bufsize=codesize);
            #ifdef __SHELL__
              if (shell && !succs)
              {
                uchar msg[256];

                strcpy(stpcpy(msg,get_fname(filename)),": Bad Table");
                SetMsg(msg);
              }
            #endif
            break;
          default:
            copyfile(file1,file3,pathname,Hdr1.OrgSiz,1,0);
        }

        crypt_size = -1;

        if (cmd=='E')
        {
          if (fflush(file3))
            error(WTERR,pathname,SUCCS);

          if ((!flg_i || flg_i==3) && succs)
            Fdatime(&Hdr1.Ftime,fileno(file3),1);

#ifdef MM_KLUDGE
          fclose(file3);
#else
          if (fclose(file3))
            error(WTERR,pathname,SUCCS);
#endif

          if (!succs)
            Fdelete(pathname);
          else if ((!flg_i || flg_i==2) && (Hdr1.Attr!=FA_CHANGED))
            Fattrib(pathname,1,(oldtos) ? (Hdr1.Attr^FA_CHANGED) : Hdr1.Attr);

          file3=NULL;
        }
        else if (cmd=='P')
        {
          if (file3==stdout)
            fflush(file3);
          strcpy(print_buf,"\r\n");
          pager_print(0);
        }

        if (succs)
        {
          if (has_crc && Hdr1.crc!=crc)
          {
            errorlevel|=2;
            succs=FAULT;
            c_err++;

            if (cmd=='P')
              print(NULL,1);

          #ifdef __SHELL__
            if (shell)
            {
              uchar msg[256];

              strcpy(stpcpy(msg,get_fname(filename)),": CRC error");
              SetMsg(msg);
            }
            else
          #endif
            #ifdef GERMAN
              print("\r PrÅfsummen-Fehler ",1);
            #else
              print("\r CRC error ",1);
            #endif
          }
          else if (cmd!='P' || pager)
          {
            if (flg_n!=1)
            {
              sprintf(print_buf,"\r %s",q);
              Print(1);
            }

            if (flg_d)
              message("Deleting",filename);
          }
        }
      }
    }

    _extract_next:
    if (succs==FAULT && flg_d)
      copyold();
    else
    {
    #ifdef __SHELL__
      if (flg_d)
        free_commem();
    #endif
      fseek(file1,nextarcpos,SEEK_SET);
    }
  }

  print(NULL,1);

  if (bad_tab)
  {
    sprintf(print_buf,"Bad Tables   :%5d",bad_tab);
    Print(1);
  }

  if (c_err)
  {
    sprintf(print_buf,"CRC errors   :%5d",c_err);
    Print(1);
  }

  if (skipped)
  {
    sprintf(print_buf,"Skipped files:%5d",skipped);
    Print(1);
  }

  if (garbage)
  {
    sprintf(print_buf,"Crashed files:%5d",garbage);
    Print(1);
  }

  if (flg_d)
    endofupdate(cnt);
  else
    close_file(file1);

  return(cnt);
}

void delete(void)
{
  register int cnt=0;

#ifdef __SHELL__
  if (!shell)
#endif
  if (!patno)
    error(NOFNERR,NULL,SUCCS);

  Case=_PC_CASECONV;

  flg_t=0;
  openbackup1();
  message("Updating archive",arcname);

  openbackup2();
  search_lzh(file1,0);

  while (gethdr(file1,&Hdr1))
  {
    if (matchpat(matchfilename,-1,Hdr1.Attr))
    {
  #ifdef __SHELL__
      if (command)
      {
        DialIndicator(1);
        free_commem();
      }
  #endif
      message("Deleting",filename);
      sseek(file1,nextarcpos,nextoffset);
      cnt++;
    }
    else
      copyold();
  }

  endofupdate(cnt);
}

static uchar *sysid(char ID)
{
  switch(ID)
  {
    case 'M':
      return("MS-DOS");
    case '2':
      return("OS/2");
    case '9':
      return("OS9");
    case 'K':
      return("OS/68K");
    case '3':
      return("OS/386");
    case 'H':
      return("HUMAN");
    case 'U':
      return("UNIX");
    case 'C':
      return("CP/M");
    case 'm':
      return("Macintosh");
    case 'R':
      return("Runser");
    case 'A':
      return("Amiga/Atari");
    case 'a':
      return("Atari");
    case 'F':
      return("FLEX-OS");
    case 'X':
      return("XOSK");
    case 'T':
      return("TOWNSOS");
    default:
    #ifdef __SHELL__
      if (shell)
        return("Unknown system");
      else
    #endif
        return("");
  }
}

static void make_attr(uchar *buf,int attr)
{
  static uchar Attr[7]="rhs-da";
  register int i, j, k;

  if (!(attr & FA_DIR))
    buf[3]='w';

  for (i=0,j=1;i<6;i++,j<<=1)
    if (attr & j)
    {
      k=Attr[i];
      if (i<=2)
        buf[3-i]=k;
      else
        buf[0]=k;
    }
}

int list(void)
{
  register uchar *p, buf[120];
  register ftime *tim=(ftime *) &Hdr1.Ftime;
  register int i;
  register uint rt;
  ulong Osize, Psize;
  int Fno, Dno;
  static const uchar *list_format="               %8lu %8lu %3d.%1d%% %2d-%02d-%02d %2d:%02d:%02d ---- -   - %04X  [%d]";
  static const uchar *list_end   ="-------------- -------- -------- ------ -------- --------\r\n";

  Case=_PC_CASECONV;
  Osize=Psize=Fno=Dno=0;

  #ifdef GERMAN
    sprintf(print_buf,"Inhalt von: %s\r\n",arcname);
  #else
    sprintf(print_buf,"Listing of archive: %s\r\n",arcname);
  #endif
  pager_print(1);

  if (openarc1((drive(arcname,NULL)<2) ? 8192L : 1024L,buffer_1)<=0)
    return(0);

  if (flg_x<3)
    #ifdef GERMAN
      sprintf(print_buf,"\r\n Name          Original Gepackt  Rate   Datum    Zeit     Attr Typ   CRC  Level\r\n-------------- -------- -------- ------ -------- -------- ---- ----- ---- -----\r\n");
    #else
      sprintf(print_buf,"\r\n Name          Original Packed   Ratio  Date     Time     Attr Type  CRC  Level\r\n-------------- -------- -------- ------ -------- -------- ---- ----- ---- -----\r\n");
    #endif
  else
    sprintf(print_buf,"\r\n Name\r\n--------------\r\n");
  pager_print(0);

  while (gethdr(file1,&Hdr1))
  {
    if (matchpat(matchfilename,-1,Hdr1.Attr))
    {
      if (flg_x<3)
      {
        rt=ratio(Hdr1.PacSiz,Hdr1.OrgSiz);
        sprintf(buf,list_format,Hdr1.OrgSiz,Hdr1.PacSiz,rt/10,rt%10,(tim->year+80)%100,tim->mon,
            tim->day,tim->hour,tim->min,tim->sec*2,Hdr1.crc,Hdr1.Level);
        memcpy(&buf[63],Hdr1.HeadID,5);
        make_attr(&buf[58],Hdr1.Attr);

        if (flg_x)
        {
          p=sysid(SystemId);
          memcpy(buf,p,strlen(p));
          #ifdef GERMAN
            if (flg_x!=2 && *comment!='\0')
              sprintf(print_buf,Hdr1.crypted ? "%s (verschlÅsselt)\r\n%s\r\n%s\r\n" : "%s\r\n%s\r\n%s\r\n",filename,comment,buf);
            else
              sprintf(print_buf,Hdr1.crypted ? "%s (verschlÅsselt)\r\n%s\r\n" : "%s\r\n%s\r\n",filename,buf);
          #else
            if (flg_x!=2 && *comment!='\0')
              sprintf(print_buf,Hdr1.crypted ? "%s (encrypted)\r\n%s\r\n%s\r\n" : "%s\r\n%s\r\n%s\r\n",filename,comment,buf);
            else
              sprintf(print_buf,Hdr1.crypted ? "%s (encrypted)\r\n%s\r\n" : "%s\r\n%s\r\n",filename,buf);
          #endif
          pager_print(0);
        }
        else
        {
          slash(filename,0);
          if ((p=get_fname(filename))>filename)
            buf[0]='+';

          if ((i=(int) strlen(p))>13)
          {
            buf[13]='>';
            i=12;
          }

          memcpy(buf+1,p,i);
          strcpy(stpcpy(print_buf,buf),"\r\n");
          pager_print(0);
        }

        Osize+=Hdr1.OrgSiz;
        Psize+=Hdr1.PacSiz;
      }
      else
      {
        sprintf(print_buf,"%s\r\n",filename);
        pager_print(0);
      }

      if (Hdr1.Attr & FA_DIR)
        Dno++;
      else
        Fno++;
    }
    sseek(file1,nextarcpos,nextoffset);
  }

  if (Fno || Dno)
  {
    if (flg_x<3)
    {
      strcpy(print_buf,list_end);
      pager_print(0);

      rt=ratio(Psize, Osize);
      Fdatime(&arcstamp,fileno(file1),0);
      tim=(ftime *) &arcstamp;

      #ifdef GERMAN
        sprintf(print_buf," %4d Dateien, %8lu %8lu %3d.%1d%% %2d-%02d-%02d %2d:%02d:%02d\r\n %4d Verzeichnisse\r\n",
            Fno, Osize, Psize, rt / 10, rt % 10,(tim->year + 80) % 100, tim->mon,
            tim->day, tim->hour, tim->min, tim->sec * 2,Dno);
      #else
        sprintf(print_buf," %4d files,   %8lu %8lu %3d.%1d%% %2d-%02d-%02d %2d:%02d:%02d\r\n %4d directories\r\n",
            Fno, Osize, Psize, rt / 10, rt % 10,(tim->year + 80) % 100, tim->mon,
            tim->day, tim->hour, tim->min, tim->sec * 2,Dno);
      #endif
    }
    else
      #ifdef GERMAN
        sprintf(print_buf,"--------------\r\n  %3d Dateien,\r\n  %3d Verzeichnisse\r\n",Fno,Dno);
      #else
        sprintf(print_buf,"--------------\r\n  %3d files,\r\n  %3d directories\r\n",Fno,Dno);
      #endif
  }
  else
    #ifdef GERMAN
      sprintf(print_buf,"  Keine Datei\r\n");
    #else
      sprintf(print_buf,"  No file\r\n");
    #endif

  pager_print(0);
  close_file(file1);

  return(Fno+Dno);
}

void getsw(uchar *p)
{
  register uchar s, *q;
  register int i;

  while ((s=*p++)!='\0')
  {
    q=strchr(swi,s);
    if (q)
    {
      if ((i=(int) (q-swi))<SWI_CNT)
      {
        if (*p=='+')
        {
          *swipos[i]=1;
          p++;
        }
        else if (*p=='-')
        {
          *swipos[i]=0;
          p++;
        }
        else if (*p>='0' && *p<='3')
          *swipos[i]=*p++ - '0';
        else
          *swipos[i]=1;
      }

      if (flg_q>1)
      {
        print(NULL,1);
        ptitel++;
        flg_q=0;
      }

      if (s=='v')
      {
        if (cmd=='P' && flg_v==3)
          flg_q++;

        if ((cmd=='P' || cmd=='L' || cmd=='V') && *p)
        {
          if (!flg_v)
            flg_v++;
          pager=p;
          flg_L=1;
        }
        break;
      }
      else if (s=='M')
      {
        if (isdigit(*p))
          maxlen=strtol(p,NULL,10)<<10;
        else
          maxlen=0;
        break;
      }
      else if (s=='Y')
      {
        if (*p)
        {
          register int len=(int) strlen(p);

          i=len;
          q=stpcpy(key_word,p);
          while ((i+=len)<256)
            q=stpcpy(q,p);

          flg_Y++;
          compress++;
          FlgMethod=5;
          flg_5=2;
          flg_u=0;
        }
        else
          flg_Y=0;
        break;
      }
      else if (s=='N')
      {
        for (i=6;--i>=0;)
          if (!isdigit(*p++))
            break;

        if (i<0)
        {
          register ftime *t=(ftime *) &newer;

          flg_N++;

          p-=6;
          t->day=(*p++-'0')*10 + (*p++-'0');
          t->mon=((*p++-'0')*10 + (*p++-'0'));
          t->year=((*p++-'0')*10 + (*p++-'0'));
          if (t->year>=80)
            t->year-=80;
        }
        else
          flg_N=0;
        break;
      }
      else if (s=='w')
      {
        if (*p)
        {
          flg_w++;
          strcpy(workdir,p);
        }
        break;
      }
      else if (s=='I')
      {
          if (*p)
          {
            flg_I++;
          flg_x++;
          slash(strcpy(incldir,p),1);
        }
        break;
      }
      else if (s=='U')
      {
        if (*p)
        {
          flg_U++;
          unpack=p;
        }
        break;
      }
      else if (s=='P')
      {
        if (*p)
          star=*p++;
        if (*p)
          pnt=*p++;
        break;
      }
      else if (s=='s')
      {
        if (flg_k<=0)
          flg_k=1;
      }
      else if (s=='z')
      {
        if (*p)
        {
          com_name=p;
          flg_z++;
        }
        break;
      }
      else if (s=='r' || s=='X')
      {
        if (!flg_x)
          flg_x=3;
      }
      else if (s=='A')
        flg_D=0;
      else if (s=='D')
        flg_A=0;
      else if (s=='y')
        flg_arc++;
      else if (s=='b')
        flg_backup++;
      else if (s=='k')
      {
        if (*p>='0' && *p<='2')
          flg_k=*p++ - '0';
        else
          flg_k=0;

        if (!flg_k)
          flg_e=flg_z=flg_s=flg_Y=compress=0;
      }
      else if (s=='5')
      {
        compress=flg_u=0;
        if (flg_5==2 || flg_Y)
          compress++;
        FlgMethod=5;
      }
      else if (s=='l')
      {
        compress=FlgMethod=flg_5=flg_u=0;
        flg_4++;
        if (flg_l==2 || flg_Y)
          compress++;
      }
      else if (s=='o')
      {
        compress=flg_5=flg_u=0;
        if (flg_o==2 || flg_Y)
          compress++;
        FlgMethod=1;
      }
      else if (s=='u')
      {
        compress=flg_5=flg_4=flg_Y=0;
        flg_u=1;
      }
      else if (s=='4')
      {
        compress=flg_5=flg_Y=0;
        flg_u=flg_4=1;
      }
    }
  #ifndef __SHELL__
    else if (s=='?')
    {
      if (!ptitel)
      {
        print(title_x,1);
        ptitel=1;
      }
/*
      print(use_1,1);
      print(use_2,1);
      print(use_3,1);
*/
      show_usage(0);
    }
  #endif
    else if (s!='-' && s!='+')
      break;
  }

  if (flg_q)
  {
    flg_n=flg_m=1;
    flg_e=flg_z=flg_h=flg_R=0;
  }
  else if (i_handle>0)
  {
    flg_m=1;
    flg_R=0;
  }

  if (flg_u && !flg_n)
    flg_n++;

  if (flg_I && flg_x)
    flg_x=3;

  if (flg_s)
    flg_s='U';
}

int tstsw(uchar *p)
{
  register uchar s, *q;
  register int i;

  while ((s=*p++)!='\0')
  {
    q=strchr(swi,s);
    if (q)
    {
      if (((int) (q-swi))<SWI_CNT)
        if (*p=='+' || *p=='-' || (*p>='0' && *p<='3'))
          p++;

      if (s=='w' || s=='z' || s=='U' || s=='Y' || s=='I' || s=='v')
        return(SUCCS);
      else if (s=='M')
        return(isdigit(*p));
      else if (s=='N')
      {
        for (i=6;--i>=0;)
          if (!isdigit(*p++))
            return(FAULT);
        return(SUCCS);
      }
      else if (s=='P')
      {
        if (*p)
          p++;
        if (*p)
          p++;
        return((*p!='\0') ? FAULT : SUCCS);
      }
      else if (s=='k')
      {
        if (*p>='0' && *p<='2')
          p++;
      }
    }
    else if (s!='?')
      return(FAULT);
  }

  return(SUCCS);
}

void executecmd(void)
{
  register int cnt;

  INIT_TIMER;
  arcpos0=back_1=back_2=found=bad_tab=c_err=skipped=garbage=ignfile=buffered=ship=0;

  base=strlen(basedir);

  switch(cmd)
  {
    case 'M':
      flg_d=1;
    case 'A':
      flg_c=1;
    case 'U':
      flg_chk=0;
      if (cmd=='U')
        flg_A=0;
      append();
      break;
    case 'C':
      flg_X=flg_f=flg_e=flg_z=flg_d=flg_u=flg_4=flg_5=flg_I=flg_x=flg_Y=compress=0;
      if (flg_k==2)
        flg_k=0;
      pack_afx();
      break;
    case 'R':
    case 'F':
      flg_chk=flg_f=0;
      freshen();
      break;
    case 'V':
      if (!flg_x)
        flg_x++;
    case 'L':
      flg_chk=0;
      if (pager==NULL)
      {
        file3=stdout;
        list();
        break;
      }
    case 'P':
      if (pager==NULL)
      {
        file3=stdout;
        setvbuf(stdout,buffer_3,_IOFBF,BUFFERSIZ);
        flg_n=1;
        extract();
        fflush(stdout);
      }
      else
      {
        if (flg_w)
          strcpy(pathname,workdir);
        else
          backpath(strcpy(pathname,arcname));
        get_tempname(pathname);

        file3=e_fopen(pathname,buffer_3,"wb",MKTMPERR,SUCCS);
        if (cmd=='P')
          cnt=extract();
        else
          cnt=list();
        if (fclose(file3))
          error(WTERR,pathname,SUCCS);
        file3=NULL;

        if (cnt)
        {
          uchar buffer[127]="*";
          strncat(buffer,pathname,125);
          Pexec(0,pager,buffer,NULL);
        }

        Fdelete(pathname);
      }
      break;
    case 'X':
      flg_x=3;
      cmd='E';
    case 'T':
    case 'E':
      flg_v=0;
      extract();
      break;
    case 'D':
      flg_chk=0;
      if (!flg_f)
        flg_f=2;
      delete();
      break;
    case 'S':
      #ifdef GERMAN
        print("Selbst-extrahierende Files: NOCH NICHT IMPLEMENTIERT!\7",1);
      #else
        print("Self-Extracting-Files: NOT YET IMPLEMENTED!\7",1);
      #endif
      errorlevel|=64;
      lha_exit();
  }

  EXIT_TIMER;
  print(NULL,1);
}

void OneNewFile (uchar *p)
{
  register uchar *s;
  register int len;

  if ((s = strpbrk(p, "\n")) != NULL)
  {
    *s='\0';
  }

  if ((len = (int) strlen (p) - 1) < 0)
  {
    return;
  }

  if (!patno && !base && !cmdlist && (p[len] == '\\' || p[len] == ':') && !flg_O)
  {
    slash (strcpy (basedir, p), 1);
    base++;
  }
  else if ((*p != EXCLUDE) && (*p != '~'))
  {
    if (patno>=MAX_PAT || (fileptr-fileregbuf+strlen(get_fname(p)))>=(FILEBUFSIZ-1))
    {
      message(M_FILETAB,p);
    }
    else
    {
      travel_file[patno] = travel_rel[patno] = 0;

      while (((s=strstr(p,"\\;"))!=NULL || (s=strstr(p,";\\"))!=NULL))
      {
        if (*s=='\\')
          s++;
        strcpy(s,s+1);
        if (*s=='\\')
          s++;
        travel_rel[patno]=s-p;
      }

      strcpy (fileptr, s = get_fname (p));
      *s = '\0';

      if (*fileptr == '\0')
      {
        travel_wild[patno] = SUCCS;

        if (slash (p, -1))
        {
          register uchar path[MAXPATH];

          slash(strcpy(path,p),1);
          if ((p=strdup(path))==NULL)
            error(MEMOVRERR,NULL,SUCCS);
        }
      }
      else if (flg_W<2 && patno>0 && travel_rel[patno]==travel_rel[patno-1] && !fnamecmp(p,travel_path[patno-1],_PC_CASESENS))
      {
        if (travel_file[patno-1]>0)
        {
          travel_wild[patno-1]|=wildcard(fileptr);
          fileptr[-1]=',';
          while (*fileptr++);
        }
        return;
      }
      else
      {
        travel_file[patno]=(int) (fileptr-fileregbuf);
        travel_wild[patno]=wildcard(fileptr);
        while (*fileptr++);
      }

      travel_path[patno]=p;
      travel_len[patno++]=(int) strlen(p);
    }
  }
  else if (*++p!='\0')
  {
    if (exno>=MAX_EXCLD)
      message(M_FILETAB,p);
    else
      exclude_file[exno++]=get_fname(p);
  }
}

void newfile(uchar *p)
{
  if ((*p == '&') || (*p == FILE_LIST))
  {
    register FILE *f;

    if (p[1]=='-' && p[2]=='\0')
      f=stdin;
    else
      f=fopen(p+1,"r");

    if (f!=NULL)
    {
      register uchar file[MAXPATH],*space;

      if (f==stdin)
        print(M_PATH,1);

      while (fgets(file,MAXPATH-1,f))
      {
        space=file;
        while (*space==' ')
          space++;
        strcpy(file,space);

        space=strchr(file,' ');
        if (space)
          *space=0;

        fnamecnv(file,-1);
        if (file[0]=='&')
        {
          if (strcmp("&-",file))
            newfile(file);
        }
        else if (file[0]!='\r' && file[0]!='\n')
        {
          if ((space=strdup(file))==NULL)
            error(MEMOVRERR,NULL,SUCCS);
          print(space,1);
          OneNewFile(space);
        }
        else if (f==stdin)
          break;
      }

      if (f!=stdin)
        close_file(f);
    }
  }
  else
  {
    OneNewFile (p);
  }
}

void InitTree(void)
{
  register int i, *p, nil_2=NIL<<1;

  p=dad;
  for (i=N;--i>=0;)
    *p++=nil_2;

  p=&rson[N+1];
  for (i=256;--i>=0;)
    *p++=nil_2;
}

void EncodeOld(void)
{
  register uchar code_buf[34], *code=code_buf, *ptr, *tbuf=text_buf;
  register int i, r, s=0, m=N-1, c, last_match_length;
  ulong printcount;
  uchar mask=1;
  int len;
  extern int match_position, match_length; /* in hufst.s */

  printcount=textsize=0;
  InitTree();

  *code++=0;
  for (i=r=(N-F),ptr=tbuf;--i>=0;)
    *ptr++=' ';

  for (i=0;i<F && (c=crc_getc(file3))!=EOF;i++)
    *ptr++=c;

  textsize=(len=i);
  if (!textsize)
    return;

  for (i=1;i<=F;i++)
    InsertONode(r - i);
  InsertONode(r);

  do
  {
    if (match_length>len)
      match_length=len;

    if (match_length <=THRESHOLD)
    {
      match_length=1;
      code_buf[0]|=mask;
      *code++=tbuf[r];
    }
    else
    {
      *code++=(uchar) match_position;
      *code++=(uchar) (((match_position >> 4) & 0xf0) | (match_length - (THRESHOLD + 1)));
    }

    if (!(mask<<=1))
    {
      i=(int) (code - code_buf);
      ptr=(code=code_buf);

      while (--i>=0)
        buf_putc(*ptr++);

      *code++=0;
      mask=1;
    }

    last_match_length=match_length;
    for (i=0;i<last_match_length && (c=crc_getc(file3))!=EOF;i++)
    {
      DeleteONode(s);
      tbuf[s]=c;
      if (s < F - 1)
        tbuf[s + N]=c;
      s=(++s) & m;
      r=(++r) & m;
      InsertONode(r);
    }

    if ((textsize+=i)>printcount)
    {
      ProcInd();
      printcount+=blocksize;
    }

    while (i<last_match_length)
    {
      DeleteONode(s);
      s=(++s) & m;
      r=(++r) & m;
      if (--len)
        InsertONode(r);
      i++;
    }
  } while (len>0);

  if ((i=(int) (code - code_buf))>1)
  {
    ptr=code_buf;
    while (--i>=0)
      buf_putc(*ptr++);
  }

  shipout();
}

int fread_crc(uchar *p,int n,FILE *f)
{
  n=(int) fread(p,1,n,f);
  if (ferror(f))
    error(RDERR,infname,SUCCS);
  block_crc(n,p);
  return(n);
}

void make_buf(FILE *file,long len)
{
  register long cnt = file->_cnt;
  register uchar *pos;
  extern long _read(int,void *,unsigned long);

  if (cnt<bufsize && cnt<len)
  {
    if (cnt>0)
      memcpy(file->_base,file->_ptr,cnt);
    else
      cnt = 0;
    pos = &file->_base[cnt];
    len = file->_bsiz-cnt;
    cnt = _read(fileno(file),pos,len);
    if (cnt>0)
    {
      file->_cnt += cnt;
      if (Hdr1.crypted && crypt_size>0)
      {
        if (cnt>crypt_size)
          cnt=crypt_size;
        code(pos,cnt);
        crypt_size-=cnt;
      }
    }
    else
      file->_flag |= _IOEOF;
    file->_ptr = file->_base;
  }
}

void print_title(uchar **argv)
{
  #ifndef BETA
  register uchar *env;
  #endif

  if (!ptitel)
  {
    print(title,1);
    ptitel++;
  }

  #ifdef BETA
  if (!pargs)
  #else
  if (!pargs && (env=get_env("LHARCPAR"))!=NULL && atoi(env))
  #endif
  {
    register int i;

    pargs++;
    #ifdef GERMAN
      print("Argumente:",1);
    #else
      print("Arguments:",1);
    #endif

    for (i=1;i<args;i++)
    {
      sprintf(print_buf,"'%s'",argv[i]);
      Print(1);
    }

    print(NULL,1);
  }
}

static uchar *get_ext (void)
{
  if (case_sensitive (arcname) != _PC_CASESENS)
#ifdef __SHELL__
    return ((cmdupdate || shell || flg_W) ? ".LZH" : ".L[HZ][HAS]");
  else
    return ((cmdupdate || shell || flg_W) ? ".lzh" : ".l[hz][has]");
#else
    return ((cmdupdate || flg_W) ? ".LZH" : ".L[HZ][HAS]");
  else
    return ((cmdupdate || flg_W) ? ".lzh" : ".l[hz][has]");
#endif
}

uchar *device(uchar *name)
{
  if (name[3]==':')
    name[3]='\0';

  if (!stricmp(name,"PRN") || !stricmp(name,"PRT"))
    return("PRN:");
  else if (!stricmp(name,"AUX"))
    return("AUX:");
  else if (!stricmp(name,"CON"))
    return("CON:");
  else
  {
    fnamecnv(name,-1);
    return(name);
  }
}

int unified_drv(uchar *fname)
{
  register uchar buf[MAXPATH],*path;

  if (__mint || InqMagX()>=0x0300)
  {
    if (get_fname(fname)==fname)
      path=act_dir;
    else
      path=fname;

    if (path[0]=='\0' || path[1]!=':')
    {
      buf[0]=Dgetdrv()+'a';
      buf[1]=':';
      if (path[0]!='\\')
      {
        buf[2]='\\';
        strcpy(buf+3,path);
      }
      else
        strcpy(buf+2,path);
    }
    else
      strcpy(buf,path);

    strupr(buf);

    if (buf[0]=='U')
    {
      if (!strncmp(buf+3,"DEV\\",4))
        return(1);
      else if (!strncmp(buf+3,"SHM\\",4) || !strncmp(buf+3,"PROC\\",5) || !strncmp(buf+3,"PIPE\\",5))
        return(-1);
    }
  }

  return(0);
}

void ioredirect(int argc,uchar **argv)
{
  register uchar c, *p;
  register int i;

  for (i=0;i<argc;i++)
  {
    p=*argv++;

    if ((c=*p++)=='>' && o_handle<0)
    {
      if (!args)
        args=i;

      if (*p=='>')
      {
        if ((o_handle=Fopen(o_dir=device(++p),1))>=0)
        {
          o_dev=Fdup(1);
          Fseek(0l,(int) o_handle,SEEK_END);
          Fforce(1,(int) o_handle);
          continue;
        }
      }

      if ((o_handle=Fcreate(o_dir=device(p),0))>=0)
      {
        o_dev=Fdup(1);
        Fforce(1,(int) o_handle);
      }
    }
    else if (c=='<' && i_handle<0)
    {
      if (!args)
        args=i;

      if ((i_handle=Fopen(p,0))>=0)
      {
        i_dev=Fdup(0);
        Fforce(0,(int) i_handle);
        flg_m=1;
      }
    }
  }
}

static void init_lharc(void)
{
  register uchar *env;
  register int c;

  if ((env=get_env("COLUMNS"))!=NULL)
  {
    maxblk=atoi(env) - 16;
    if (maxblk<24)
      maxblk=24;
  }

  _lseed=clock();

  mkcrc();
  Fsetdta(&_dta);

  stdout->_flag |= _IOBIN;

  if (__mint)
    oldtos=0;
  else
  {
    register uint vers=Sversion();

    vers=(vers<<8) | (vers>>8);
    oldtos=(vers<0x0014);
  }

  buffer_gen=(uchar *) (((long) (buffer+16)) & (~15l));

  env=upper;
  for (c=0;c<256;c++)
    if (c>='a' && c<='z')
      *env++=c^32;
    else if (c=='Å')
      *env++='ö';
    else if (c=='î')
      *env++='ô';
    else if (c=='Ñ')
      *env++='é';
    else
      *env++=c;

  getcwd(act_dir,MAXPATH);
  unix2dos(act_dir,0);
  slash(act_dir,1);
  fnamecnv(act_dir,-1);
}

#ifndef __SHELL__
void main(int argc,uchar **argv)
#else
void argvmain(int argc,uchar **argv)
#endif
{
  register uchar *p, *q, *env, *env9, **old_argv=argv;

#ifndef __SHELL__
  init_lharc();
  ioredirect(argc,argv);
#else
  if (!shell)
    ioredirect(argc,argv);
#endif
  if (args)
    argc=args;
  else
    args=argc;

  argc--;
#ifndef __SHELL__
  if (argc<=0)
  {
    flg_h++;
    print(title_x,1);
/*
    print(use_1,1);
    wait_for_key(0);
    print(use_2,1);
    wait_for_key(0);
    print(use_3,1);
*/
    show_usage(1);
  }
  else
#endif
  {
    Fsetdta(&_dta);

    fileptr=fileregbuf;
    *fileptr++='*';
    *fileptr++='\0';

    arcname[0]='\0';

    argv++;
    argc--;
    cmd=toupper(*(p=*argv++));

#ifndef __SHELL__
    if ((p[1] != '\0') || (strchr ("EXTDLVAUMFPRSC", cmd) == NULL) || !argc)
    {
      register uchar dir[MAXPATH];
      register int compr;

      fnamecnv (p, -1);
      if ((q = strstr(p, "*.*")) > NULL)
      {
        if (q==p)
          p=strcpy(dir,act_dir);
        else
          *q='\0';
      }
      slash (p, 0);

      if (Attrib (p) & FA_DIR)
      {
        compr = 1;
      }
      else
      {
        switch (test_afx (p))
        {
          case 3:
            {
              register uchar *b=buffer_gen;

              q=b+2048l;
              compr=1;

              while (b<q)
              {
                if (!strncmp(b,"SFX",3))
                  goto _extract;
                else if (*b++=='-' && b[3]=='-' && (*b=='a' || *b=='A' || *b=='l' || *b=='L'))
                  break;
              }
            }
            break;
          case 2:
            _extract:
            compr=0;
            break;
          default:
            compr=1;
        }
      }

      if ((strpbrk (get_fname (p), "*?") == NULL) && compr)
      {
        cmd = 'U';
        pack++;
        cmdupdate = SUCCS;

        strcpy (arcname, p);
        if ((p[1] == ':') && (p[2] == '\0')) /* ganzes Laufwerk */
        {
          arcname[2] = '\\';
          arcname[3] = toupper (*p);
          arcname[4] = '\0';
          strcat (arcname, get_ext ());
          q = 0L;
        }
        else
        {
          follow_link (p);
          strcpy (arcname, p);
          p = get_fname (p);
          if ((q = strrchr (p, '.')) != NULL)
          {
            *q = '\0';
          }
          strcpy (stpcpy (backpath (arcname), p), get_ext ());
        }

        if (q)
        {
          *q='.';
        }
      }
      else
      {
        cmd = 'X';
        flg_g++;
        backpath (strcpy (basedir, p));
        base++;
        pack += 2;
      }

      flg_x=3;
      flg_m++;
      argc++;
      argv--;
    }
#endif

    cmdupdate = (strchr ("AUMFRD", cmd) != NULL);
    cmdlist = (strchr ("AUMC", cmd) != NULL);

    if ((env=get_env("TMP"))!=NULL || (env=get_env("TMPDIR"))!=NULL || (env=get_env("ARCTEMP"))!=NULL)
    {
      flg_w++;
      strcpy(workdir,env);
    }

    if ((env = get_env ("LHARCDIR")) != NULL)
    {
      slash (strcpy (basedir, env), 1);
    }

    if ((env=get_env("UNPACKED"))!=NULL)
    {
      flg_U++;
      unpack=env;
    }

    if ((env=get_env("LHARC"))!=NULL || (env=get_env("LHA"))!=NULL)
    {
      for (p=env;*p;p++)
        if (*p==' ' || *p=='\x08')
          *p=0;
      env9=p;
      p=env;
      while (p<env9)
      {
        while (!*p)
          p++;
        if (*p=='-' || *p=='/')
          p++;
        getsw(p);
        while (*p)
          p++;
      }
    }

    if ((cmd == 'C') || arcname[0])
    {
      patno = 0;
    }
    else
    {
      patno = -1;
    }

    while (argc--)
    {
      p = *argv++;
      if (*p == '-')
      {
        getsw (++p);
        continue;
      }
      else if ((*p == '/') && (patno < 0) && tstsw (p + 1))
      {
        if (cmdupdate && (wildcard (get_fname (p + 1)) || multi_wild (p + 1)))
        {
          getsw (++p);
          continue;
        }
        else if (((q = strrchr (get_fname (p), '.')) == NULL) || arc_ext (q) == FAULT)
        {
          getsw (++p);
          continue;
        }
      }

      print_title (old_argv);
      fnamecnv (p, -1);

      if (patno < 0)
      {
        strcpy (arcname, p);
        follow_link (arcname);
        p = get_fname (arcname);

        if (*p=='\0' || (Device=unified_drv(arcname))<0)
          error(NOARCNMERR,NULL,SUCCS);

        multi_arc=multi_wild(p);

        if (cmdupdate && (strpbrk(p,"*?") || multi_arc))
          error(NOARCNMERR,arcname,SUCCS);

        if (!multi_arc && !Device)
        {
          if ((q=strrchr(p,'.'))==NULL)
            strcat(arcname,get_ext());
          else if (q[1]=='\0')
            strcpy(q,get_ext());
          else if (flg_m!=1 && cmdupdate && arc_ext(q)==FAULT)
          {
            sprintf(print_buf,M_NOTLZH,get_fname(arcname));
            Print(0);

            if (get_key("YN")=='N')
            {
              errorlevel|=128;
              lha_exit();
            }
          }
        }

        wild_arc = wildcard (p) | multi_arc;
        patno++;
      }
    #ifdef __SHELL__
      else
    #else
      else if (pack < 2)
    #endif
      {
      #ifndef __SHELL__
        if (pack)
        {
          slash (p, 0);

          if (strstr (p, "*.*") != NULL)
          {
            flg_r++;
          }
          else if (Attrib (p) & FA_DIR)
          {
            register uchar path[MAXPATH];

            flg_r++;
            slash (strcpy (path, p), 1);
            if ((p = strdup (path)) == NULL)
            {
              error(MEMOVRERR, NULL, SUCCS);
            }
          }
        }
      #endif
        newfile (p);
      }
    }

  #ifndef __SHELL__
    if (args>2 && pack==1)
      pack=0;
    else if (pack==2)
      pack=0;
  #endif

    print_title(old_argv);

    if (patno < 0)
    {
      error (NOARCNMERR, NULL, SUCCS);
    }
    else if (!patno && (cmd != 'D'))
    {
      travel_path[0] = "";
      travel_len[0] = travel_file[0] = travel_rel[0] = 0;
      travel_wild[0] = all = SUCCS;
      patno++;
      flg_p = 0;
    }

    fn_name=path_conf(basedir,_PC_NAME_MAX);
    if (fn_name>64)
      fn_name=64;
    else if (fn_name<=0)
      fn_name=12;

    pt_name=path_conf(basedir,_PC_PATH_MAX);
    if (pt_name<=0 || pt_name>MAXPATH)
      pt_name=MAXPATH;
    Case=case_sensitive(basedir);

    unix2dos(workdir,0);
    slash(workdir,1);
    fnamecnv(workdir,-1);

    if (flg_w && (cmdupdate || cmd=='P' || flg_d))
      tstdir(workdir,-1);

    if (Device)
    {
      if (strchr("AMUEXTPLV",cmd)==NULL)
        error(NOARCERR,arcname,SUCCS);
      else if (strchr("EXTP",cmd))
        flg_d=0;
      flg_w=0;
    }

    MakeBuffers();

    if (cmdupdate || cmd=='C')
      executecmd();
    else
    {
      register uchar *f, *p, *q, arc[MAXPATH];
      register long handle, buf[MAXPATH>>2];
      register int done, cnt=0, len, compare, Case;

      _gemdos=(path_conf(arcname,_PC_NAME_MAX)==12 && case_sensitive(arcname)==_PC_CASECONV);

      if (!_gemdos)
      {
        backpath(strcpy(arc,arcname));

        if (arc[0]!='\0')
          handle=Dopendir(arc,0);
        else
          handle=Dopendir(act_dir,0);

        if ((handle&0xff000000l)==0xff000000l)
          error(NOARCERR,arcname,SUCCS);
        else
          done=(int) Dreaddir(MAXPATH,handle,(uchar *) buf);
        f=(uchar *) &buf[1];
      }
      else
      {
        strcpy(arc,arcname);
        if (wild_arc)
          strcpy(backpath(arc),"*.*");
        done=Fsfirst(arc,0x07);
        f=_dta.dta_name;
      }

      Case=case_sensitive(arcname);
      compare=(_gemdos || (!flg_S && Case!=_PC_CASESENS));
      q=get_fname(arcname);
      p=backpath(arc);

      while(!done)
      {
        strcpy(p,f);
        if (compare)
          strcnv(p,SUCCS);

        if (tst_fname(f) && ((_gemdos && wild_arc==FAULT) || chk_wild(p,q,flg_W,Case)))
        {
          if (o_dir && !fnamecmp(p,o_dir,_PC_CASESENS))
            goto arc_next;

          strcpy(p,f);

          if (!_gemdos)
          {
            read_attr(arc,&_dta);
            if (_dta.dta_attribute & (FA_LABEL|FA_DIR))
              goto arc_next;
          }

          if (cnt<MAX_ARC)
          {
            len=(int) strlen(f)+1;
            if ((fileptr-fileregbuf+len)>=(FILEBUFSIZ-1))
              message(M_FILETAB,f);
            else
            {
              strcpy(fileptr,f);
              arc_file[cnt++]=(int) (fileptr-fileregbuf);
              fileptr+=len;
            }
          }
          else
            message(M_FILETAB,f);
        }

        arc_next:
        if (_gemdos)
          done=Fsnext();
        else
          done=(int) Dreaddir(MAXPATH,handle,(uchar *) buf);
      }

      if (!_gemdos)
        Dclosedir(handle);

      if (!cnt)
        error(NOARCERR,arcname,SUCCS);
      else
      {
        #ifdef GERMAN
          sprintf(print_buf," Archive gefunden: %d",cnt);
        #else
          sprintf(print_buf," Archives matched: %d",cnt);
        #endif
        Print(1);

        _gemdos=(fn_name==12 && Case==_PC_CASECONV);
        q=basedir+strlen(basedir);

        while(--cnt>=0)
        {
          f=&fileregbuf[arc_file[cnt]];
          strcpy(backpath(arcname),f);
          if (cmd=='X' || cmd=='E')
          {
            if (flg_g && (p=strrchr(f,'.'))!=NULL)
            {
              *p='\0';
              strcpy(stpcpy(q,f),"\\");
              tstdir(basedir,-1);
            }
            else if(!flg_O)
              tstdir(basedir,-1);

          }

          executecmd();
        }
      }

      if (cmd!='L' && cmd!='V')
        tstpat();
    }
  }

  lha_exit();
}
