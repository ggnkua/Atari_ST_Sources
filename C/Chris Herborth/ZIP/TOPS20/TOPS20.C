/*---------------------------------------------------------------------------

  tops20.c

  TOPS20-specific routines for use with Info-ZIP's UnZip 5.1 and later.

  Contains:  mapattr()
             close_outfile()
             version()
             upper()
             enquote()
             dequote()
             fnlegal()

  (not yet ported:  do_wild(), mapname(), checkdir(), ...)

  ---------------------------------------------------------------------------*/


#include "unzip.h"


/**********************/
/* Function mapattr() */
/**********************/

int mapattr()      /* just like Unix except no umask() */
{
    ulg  tmp = crec.external_file_attributes;

    switch (pInfo->hostnum) {
        case UNIX_:
        case VMS_:
            pInfo->file_attr = (unsigned)(tmp >> 16);
            break;
        case AMIGA_:
            tmp = (unsigned)(tmp>>1 & 7);   /* Amiga RWE bits */
            pInfo->file_attr = (unsigned)(tmp<<6 | tmp<<3 | tmp);
            break;
        case FS_FAT_:   /* MSDOS half of attributes should always be correct */
        case FS_HPFS_:
        case FS_NTFS_:
        case MAC_:
        case ATARI_:
        case TOPS20_:
        default:
            tmp = !(tmp & 1) << 1;   /* read-only bit --> write perms bits */
            pInfo->file_attr = (unsigned)(0444 | tmp<<6 | tmp<<3 | tmp);
            break;
#if 0
        case ATARI_:
        case TOPS20_:
        default:
            pInfo->file_attr = 0666;
            break;
#endif
    } /* end switch (host-OS-created-by) */

    return 0;

} /* end function mapattr() */





/****************************/
/* Function close_outfile() */
/****************************/

void close_outfile()
{
#   define JSYS_CLASS           0070000000000
#   define FLD(val,mask)        (((unsigned)(val)*((mask)&(-(mask))))&(mask))
#   define _DEFJS(name,class)   (FLD(class,JSYS_CLASS) | (monsym(name)&0777777))
#   define IDTIM                _DEFJS("IDTIM%", 1)
#   define SFTAD                _DEFJS("SFTAD%", 0)
#   define YRBASE               1900
    int ablock[5], tblock[2];
    int yr, mo, dy, hh, mm, ss;
    char temp[100];
    unsigned tad;


    /* dissect the date */
    yr = ((lrec.last_mod_file_date >> 9) & 0x7f) + (1980 - YRBASE);
    mo = (lrec.last_mod_file_date >> 5) & 0x0f;
    dy = lrec.last_mod_file_date & 0x1f;

    /* dissect the time */
    hh = (lrec.last_mod_file_time >> 11) & 0x1f;
    mm = (lrec.last_mod_file_time >> 5) & 0x3f;
    ss = (lrec.last_mod_file_time & 0x1f) * 2;
    
    sprintf(temp, "%02d/%02d/%02d %02d:%02d:%02d", mo, dy, yr, hh, mm, ss);

    ablock[1] = (int)(temp - 1);
    ablock[2] = 0;
    if (!jsys(IDTIM, ablock)) {
        fprintf(stderr, "error:  IDTIM failure for %s\n", filename);
        fclose(outfile);
        return;
    }

    tad = ablock[2];
    tblock[0] = tad;
    tblock[1] = tad;
    tblock[2] = -1;

    ablock[1] = fcntl(fileno(outfile), F_GETSYSFD, 0); /* _uffd[outfd]->uf_ch */
    ablock[2] = (int) tblock;
    ablock[3] = 3;
    if (!jsys(SFTAD, ablock))
        fprintf(stderr, "error:  can't set the time for %s\n", filename);

    fclose(outfile);

} /* end function close_outfile() */





#ifndef SFX

/************************/
/*  Function version()  */
/************************/

void version()
{
#if 0
    char buf[40];
#endif

    printf(LoadFarString(CompiledWith),

#ifdef __GNUC__
      "gcc ", __VERSION__,
#else
#  if 0
      "cc ", (sprintf(buf, " version %d", _RELEASE), buf),
#  else
#  ifdef __COMPILER_KCC__
      "KCC", "",
#  else
      "unknown compiler", "",
#  endif
#  endif
#endif

      "TOPS-20",

#if defined(foobar) || defined(FOOBAR)
      " (Foo BAR)",   /* OS version or hardware */
#else
      "",
#endif /* Foo BAR */

#ifdef __DATE__
      " on ", __DATE__
#else
      "", ""
#endif
      );

} /* end function version() */

#endif /* !SFX */





/**********************/
/*  Function upper()  */
/**********************/

int upper(s)        /* returns s in uppercase */
    char *s;        /* string to be uppercased */
{
    for (;  *s;  ++s)
        *s = toupper(*s);
}





/************************/
/*  Function enquote()  */
/************************/

int enquote(s)      /* calls dequote(s) to normalize string, then */
    char *s;        /*  inserts ^Vs before otherwise illegal characters */
{                   /*  in s, assuming that s is a TOPS-20 filename */
    char d[100];
    char *p, *q;
    char c;

    if (s && *s) {
        dequote(s);
        p = s - 1;
        q = d - 1;
        while (c = *++p) {
            if (!fnlegal(c))
                *++q = '\026';
            *++q = c;
        }
        *++q = '\0';
        strcpy(s, d);
    }
    return 0;
}





/************************/
/*  Function dequote()  */
/************************/

int dequote(s)        /* returns s without ^Vs */
    char *s;          /* string to be dequoted */
{
    char d[100];
    char *p, *q;
    int c;

    if (s && *s) {
        p = s - 1;
        q = d - 1;
        while (c = *++p)
            if (c != '\026')
                *++q = c;
        *++q = '\0';
        strcpy(s, d);
    }
    return 0;
}





/************************/
/*  Function fnlegal()  */
/************************/

int fnlegal(c)         /* returns TRUE if c is a member of the */
    char c;            /*  legal character set for filenames */
{
    char *q;
    static char *legals = {"$%**-<>>AZ[[]]__az"};

    q = legals;
    while (*q)
        if (c < *q++)
            break;
        else if (c <= *q++)
            return TRUE;

    return FALSE;
}
