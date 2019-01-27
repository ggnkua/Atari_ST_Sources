#if !defined(POLARSSL_CONFIG_FILE)
#include "polarssl/config.h"
#else
#include POLARSSL_CONFIG_FILE
#endif

#include "polarssl/timing_alt.h"

#include <unistd.h>
#include <sys/time.h>
#if defined(POLARSSL_SELF_TEST)
#include <signal.h>
#endif
#include <mint/sysbind.h>

int used_system = 0;
const int SYSTEM_MINT = 0;  // MiNT
const int SYSTEM_OTHER = 1; // Other than MiNT (TOS, MagiC)

void timing_set_system(int value)
{
  used_system = value;
}

struct _hr_time
{
  struct timeval start;
};

static int hardclock_init = 0;
static struct timeval tv_init;
static long time_init = 0;

unsigned long hardclock( void )
{
  if (used_system == SYSTEM_MINT)
  {
    struct timeval tv_cur;

    if( hardclock_init == 0 )
    {
      gettimeofday( &tv_init, NULL );
      hardclock_init = 1;
    }
    
    gettimeofday( &tv_cur, NULL );
    
    return( ( tv_cur.tv_sec  - tv_init.tv_sec  ) * 1000000 + ( tv_cur.tv_usec - tv_init.tv_usec ) );
  }
  else
  {
    long time_cur = 0;
    
    if( hardclock_init == 0 )
    {
      time_init = (long)Gettime();

      hardclock_init = 1;
    }

    time_cur = Gettime();

    return( ( time_cur - time_init ));
    
    /*long time_cur;
    long usp;
    
    if( hardclock_init == 0 )
    {
      usp = Super(0);
      time_init = *((long *)0x4ba);
      Super(usp);
      
      hardclock_init = 1;
    }

    usp = Super(0);
    time_cur = *((long *)0x4ba);
    Super(usp);

    return (time_init - time_cur);*/
  }
}

volatile int alarmed = 0;

unsigned long get_timer( struct hr_time *val, int reset )
{
#if defined(POLARSSL_SELF_TEST)
  unsigned long delta;
  struct timeval offset;
  struct _hr_time *t = (struct _hr_time *) val;
  
  gettimeofday( &offset, NULL );
  
  delta = ( offset.tv_sec  - t->start.tv_sec  ) * 1000 + ( offset.tv_usec - t->start.tv_usec ) / 1000;
  
  if( reset )
  {
    t->start.tv_sec  = offset.tv_sec;
    t->start.tv_usec = offset.tv_usec;
  }
  
  return( delta );
#else
  return 0;
#endif
}

#if defined(POLARSSL_SELF_TEST)
static void sighandler( int signum )
{
  alarmed = 1;
  signal( signum, sighandler );
}
#endif

void set_alarm( int seconds )
{
#if defined(POLARSSL_SELF_TEST)
  alarmed = 0;
  signal( SIGALRM, sighandler );
  alarm( seconds );
#endif
}

void m_sleep( int milliseconds )
{
#if defined(POLARSSL_SELF_TEST)
  struct timeval tv;
  
  tv.tv_sec  = milliseconds / 1000;
  tv.tv_usec = ( milliseconds % 1000 ) * 1000;
  
  select( 0, NULL, NULL, NULL, &tv );
#endif
}
