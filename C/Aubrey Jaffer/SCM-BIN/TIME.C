/* Scheme implementation intended for JACAL.
   Copyright (C) 1990, 1991, 1992 Aubrey Jaffer.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 1, or (at your option)
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

The author can be reached at jaffer@ai.mit.edu or
Aubrey Jaffer, 84 Pleasant St., Wakefield MA 01880
*/

#include <stdio.h>
#include "scm.h"

#if (__TURBOC__==1)
/* Needed for TURBOC V1.0 */
#define LACK_FTIME
#define LACK_TIMES
#undef MSDOS
#endif

#ifdef STDC_HEADERS
# include <time.h>
# ifdef sun
#  include <sys/types.h>
#  include <sys/times.h>
# endif
# ifdef nosve
#  include <sys/types.h>
#  include <sys/times.h>
# endif
#else
# ifdef SVR2
#  include <time.h>
# else
#  include <sys/time.h>
# endif
# include <sys/types.h>
# include <sys/times.h>
#endif

/* Define this if your system lacks ftime(). */
/* #define LACK_FTIME */
/* Define this if your system lacks times(). */
/* #define LACK_TIMES */
#ifdef THINK_C
# define LACK_FTIME
# define LACK_TIMES
# define CLK_TCK 60
#endif
#ifdef SVR2
# define LACK_FTIME
#endif
#ifdef nosve
# define LACK_FTIME
#endif
#ifdef GNUDOS
# define LACK_FTIME
# define LACK_TIMES
#endif
#ifdef atarist
# define LACK_FTIME
# define LACK_TIMES
#endif
#ifdef MSDOS
# include <sys\types.h>
# include <sys\timeb.h>
#endif
#ifndef LACK_FTIME
# ifdef unix
#  include <sys/timeb.h>
# endif
#endif

#ifdef CLK_TCK
# define CLKTCK CLK_TCK
# ifdef CLOCKS_PER_SEC
#  ifdef unix
#   include <sys/times.h>
#   define LACK_CLOCK
    /* This is because clock() might be POSIX rather than ANSI.
       This occurs on HP-UX machines */
#  endif
# endif
#else
# define LACK_CLOCK
# ifdef AMIGA
#  include <stddef.h>
#  define LACK_TIMES
#  define LACK_FTIME
#  define CLKTCK 1000
# else
#  define CLKTCK 60
# endif
#endif

#ifdef __STDC__
#define timet time_t
#else
#define timet long
#endif

#ifdef LACK_CLOCK
# ifdef LACK_TIMES
#  ifdef AMIGA
/* From: "Fred Bayer" <bayerf@lan.informatik.tu-muenchen.de> */
#   ifdef AZTEC_C		/* AZTEC_C */
#    include <devices/timer.h>
long mytime()
{
        long sec,mic,mili=0;
        struct timerequest *timermsg;
        struct MsgPort *timerport;
        if(!(timerport = (struct MsgPort *)CreatePort(0,0))){
        lputs("No mem for port.\n",STREAM(def_outp));
                return mili;
        }
        if(!(timermsg = (struct timerequest *)
                 CreateExtIO(timerport,sizeof(struct timerequest)))){
                lputs("No mem for timerequest.\n",STREAM(def_outp));
                DeletePort(timermsg->tr_node.io_Message.mn_ReplyPort);
        return mili;
        }
        if(!(OpenDevice(TIMERNAME,UNIT_MICROHZ,timermsg,0))){
                timermsg->tr_node.io_Command = TR_GETSYSTIME;
                timermsg->tr_node.io_Flags = 0;
                DoIO(timermsg);
                sec = timermsg->tr_time.tv_secs;
                mic = timermsg->tr_time.tv_micro;
                mili = sec*1000+mic/1000;
                CloseDevice(timermsg);
        }
        else lputs("No Timer available.\n",STREAM(def_outp));
        DeletePort(timermsg->tr_node.io_Message.mn_ReplyPort);
        DeleteExtIO(timermsg);
        return mili ;
}
#   else			/* this is for SAS/C */
long mytime()
{
   unsigned int cl[2];
   timer(cl);
   return(cl[0]*1000+cl[1]/1000);
}
#   endif /* AZTEC_C */
#  else /* AMIGA */
#   define mytime() ((time(0L) - your_base) * CLKTCK)
#  endif /* AMIGA */
# else /* LACK_TIMES */
long mytime()
{
  struct tms time_buffer;
  times(&time_buffer);
  return time_buffer.tms_utime + time_buffer.tms_stime;
}
# endif /* LACK_TIMES */
#else /* LACK_CLOCK */
# define mytime clock
#endif /* LACK_CLOCK */

#ifdef LACK_FTIME
# ifdef AMIGA
SCM your_time()
{
  return MAKINUM(mytime());
}
# else
timet your_base;
SCM your_time()
{
	return MAKINUM((time(0L) - your_base) * (int)CLKTCK);
}
# endif /* AMIGA */
#else /* LACK_FTIME */
struct timeb your_base;
SCM your_time()
{
	struct timeb time_buffer;
	long tmp;
	ftime(&time_buffer);
	time_buffer.time -= your_base.time;
	tmp = time_buffer.millitm - your_base.millitm;
	tmp = time_buffer.time*1000L + tmp;
	tmp *= CLKTCK;
	tmp /= 1000;
	return MAKINUM(tmp);
}
#endif /* LACK_FTIME */

long my_base=0;
SCM my_time()
{
  return MAKINUM(mytime()-my_base);
}

#ifndef STDC_HEADERS
struct tm *localtime();
#endif
SCM dcdtime()
{
  int i=sizeof(struct tm)/sizeof(int);
  SCM ans=make_vector(MAKINUM((long)i),UNDEFINED);
  timet timv=time(0L);
  struct tm *tmptr=localtime(&timv);
  while(i--) VELTS(ans)[i]=MAKINUM((long)(((int *)tmptr)[i]));
  return ans;
}

SCM get_univ_time()
{
  timet timv=time(0L);
#ifdef STDC_HEADERS
  timv = mktime(gmtime(&timv));
#endif
  return MAKINUM(timv);
}

static char s_dcdunivtime[]="decode-universal-time";
SCM dcdunivtime(ut)
     SCM ut;
{
  timet timv=INUM((unsigned long)ut);
  ASSERT(INUMP(ut),ut,ARG1,s_dcdunivtime);
  {
    int i=sizeof(struct tm)/sizeof(int);
    SCM ans=make_vector(MAKINUM((long)i),UNDEFINED);
    struct tm *tmptr=localtime(&timv);
    while(i--) VELTS(ans)[i]=MAKINUM((long)(((int *)tmptr)[i]));
    return ans;
  }
}

long time_in_msec(x)
     long x;
{
  if (CLKTCK==60) return (x*50)/3;
  else return x*(long)(1000/CLKTCK);
}

static iproc subr0s[]={
	{"get-internal-run-time",my_time},
	{"get-internal-real-time",your_time},
	{"get-decoded-time",dcdtime},
	{"get-universal-time",get_univ_time},
	{0,0}};

SCM sym_itups = BOOL_F;

void init_time()
{
	sym_itups=sysintern("internal-time-units-per-second");
	VCELL(sym_itups)=MAKINUM((long)CLKTCK);
#ifdef LACK_FTIME
# ifndef AMIGA
	time(&your_base);
# endif
#else
	ftime(&your_base);
#endif
	my_base = mytime();
	init_iprocs(subr0s, tc7_subr_0);
	make_subr(s_dcdunivtime, tc7_subr_1, dcdunivtime);
}
