#include <gembind.h>
#include <gemdefs.h>
#include <osbind.h>

#define TRUE (0 == 0)
#define FALSE (! TRUE)

extern 
int   gl_apid ;                     /* SHOULD be returned by appl_init() */

int   contrl[ 12 ] ,
      intin[ 128 ] ,
      ptsin[ 128 ] ,
      intout[ 128 ] ,
      ptsout[ 128 ] ;               /* storage wasted for idiotic bindings */

int   work_in[ 11 ] ,               /* Input to VDI parameter array */
      work_out[ 57 ] ;              /* Output from VDI parameter array */

int   gl_hchar , gl_wchar , gl_wbox , gl_hbox ,    /* system sizes */
      menu_id ,                                    /* our menu id */
      phys_handle ,                 /* physical workstation handle */
      handle ,                      /* virtual workstation handle */

      xdesk , ydesk , hdesk , wdesk ;              /* desk sizes */

      msgbuff[ 8 ] ;                /* event message buffer */

#define DEFAULT 0
#define E_APPL_INIT 1
#define E_APPL_EXIT 2
#define E_NO_MENU_ID 3
#define E_WIND_GET_DESK 4
#define E_BEGIN_WIND_UPDATE 5
#define E_V_OPNVWK 6
#define E_GRAF_SHRINKBOX 7
#define E_PROGERROR 8
#define E_END_WIND_UPDATE 9

quit( errnum )
   int errnum ;
{  switch( errnum )
   {  case E_PROGERROR :
         form_alert( 3 ,
"[3]\
[ \
| ®®®  StarWars Switcher  ¯¯¯  \
| \
|   Internal program error.    \
| \
][ Cancel ]"       ) ;
         quit( DEFAULT ) ;          /* stands for jump to default case */
      case E_GRAF_SHRINKBOX :
         form_alert( 3 ,
"[3]\
[ ®®®  StarWars Switcher  ¯¯¯  \
| \
|  Can't create any special    \
|  effects.                    \
| \
][ Cancel ]"       ) ;
         quit( DEFAULT ) ;
      case E_V_OPNVWK :
         form_alert( 3 ,
"[3]\
[ \
| ®®®  StarWars Switcher  ¯¯¯  \
| \
|   Can't open work screen.    \
| \
][ Cancel ]"       ) ;
         quit( DEFAULT ) ;
      case E_END_WIND_UPDATE :
         form_alert( 3 ,
"[3]\
[ \
| ®®®  StarWars Switcher  ¯¯¯  \
| \
|    Can't release screen.     \
| \
][ Cancel ]"       ) ;
         quit( DEFAULT ) ;
      case E_BEGIN_WIND_UPDATE :
         form_alert( 3 ,
"[3]\
[ \
| ®®®  StarWars Switcher  ¯¯¯  \
| \
|     Can't freeze screen.     \
| \
][ Cancel ]"       ) ;
         quit( DEFAULT ) ;
      case E_WIND_GET_DESK :
         form_alert( 3 ,
"[3]\
[ \
| ®®®  StarWars Switcher  ¯¯¯  \
| \
|   Can't get desktop size.    \
| \
][ Cancel ]"       ) ;
         quit( DEFAULT ) ;
      case E_NO_MENU_ID :
         form_alert( 3 ,
"[3]\
[ ®®®  StarWars Switcher  ¯¯¯  \
| \
|  Can't get into Desk menu.   \
|  ( Too many accessories? )   \
| \
][ Cancel ]"       ) ;
         quit( DEFAULT ) ;
      case E_APPL_EXIT :
         form_alert( 3 ,
"[3]\
[ ®®®  StarWars Switcher  ¯¯¯  \
| \
|  Can't exit as a GEM appli-  \
|  cation.                     \
|  Accessory deactivated.      \
][ Cancel ]"       ) ;
      default :
         do
         {  evnt_mesag( msgbuff ) ;
         }  while ( TRUE ) ;        /* accessories never end... */
      case E_APPL_INIT :
         printf(
 " ---  StarWars Switcher  --- \
\n Can't initialise as GEM application. \
\n Program ends...") ;
         exit( E_APPL_INIT ) ;      /* can't get to GEM, so try exit()... */
   }
}


open_vwork()
{  int i ;
   for( i = 0 ; i < 10 ; work_in[ i++ ] = 1 ) ;
   work_in[ 10 ] = 2 ;
   handle = phys_handle ;
   if( v_opnvwk( work_in , &handle , work_out ) == 0 )
      quit( E_V_OPNVWK ) ;
}

main()
{  appl_init() ;
   if( gl_apid == -1 )
      quit( E_APPL_INIT ) ;
   phys_handle = graf_handle( &gl_wchar , &gl_hchar , &gl_wbox , &gl_hbox ) ;
   menu_id = menu_register( gl_apid , "  StarWars Switcher" ) ;
   if( menu_id  == -1 )
      if( appl_exit() == 0 )
         quit( E_APPL_EXIT ) ;
      else
         quit( E_NO_MENU_ID ) ;
   if( wind_get( 0 , WF_WORKXYWH , &xdesk , &ydesk , &wdesk , &hdesk ) == 0 )
      quit( E_WIND_GET_DESK ) ;
   do
   {  evnt_mesag( msgbuff ) ;
      if( wind_update( BEG_UPDATE ) == 0 )
         quit( E_BEGIN_WIND_UPDATE ) ;
      if( msgbuff[ 0 ] == AC_OPEN )
         if ( msgbuff[ 4 ] == menu_id )
         {  static int fx_off = FALSE ;
            int fx_newstate ;

            open_vwork() ;
            if( graf_shrinkbox( xdesk + (wdesk - gl_wbox) >> 1 
                              , ydesk + (hdesk - gl_hbox) >> 1
                              , gl_wbox , gl_hbox
                              , xdesk , ydesk , wdesk , hdesk
                              )                 /* sample starwars effect */
                == 0
              )
               quit( E_GRAF_SHRINKBOX ) ;
            fx_newstate = form_alert( 1 , 
"[3]\
[ ®®®  Star Wars Switcher  ¯¯¯ \
|  This accessory allows you   \
|  to enable or disable GEM's  \
|  special effects at will.    \
|  21/08/88 E. v.d. Meerakker  \
][ FX ON | FX OFF ]"                ) ;

            switch( fx_newstate )
            {  case 2 :
                  fx_off = fx_off || detour() ; /* don't detour the detour */
                                                /* 'short circuit evaluation'
                                                   is a C feature
                                                */
                  if( fx_off )
                  {  if( graf_shrinkbox( xdesk + (wdesk - gl_wbox) >> 1 
                                       , ydesk + (hdesk - gl_hbox) >> 1
                                       , gl_wbox , gl_hbox
                                       , xdesk , ydesk , wdesk , hdesk
                                       )     /* this one should never show up,
                                                but I'm just checking ...
                                             */
                         == 0
                       )
                        quit( E_GRAF_SHRINKBOX ) ;
                     form_alert( 1 ,
"[1]\
[ \
| ®®®  Star Wars Switcher  ¯¯¯ \
| \
|     Special effects OFF.     \
| \
][   OK   ]"                   ) ;
                  }
                  break ;
               case 1 :
                  fx_off = fx_off && highway() ;/*go to highway from detour*/
                  if( !fx_off )
                  {  if( graf_shrinkbox( xdesk + (wdesk - gl_wbox) >> 1 
                                       , ydesk + (hdesk - gl_hbox) >> 1
                                       , gl_wbox , gl_hbox
                                       , xdesk , ydesk , wdesk , hdesk
                                       )     /* this one should always show,
                                                unless it wasn't possible to
                                                have FX in the first place;
                                                e.g. when using CPANEL++
                                             */
                         == 0
                       )
                        quit( E_GRAF_SHRINKBOX ) ;
                     form_alert( 1 ,
"[1]\
[ \
| ®®®  Star Wars Switcher  ¯¯¯ \
| \
|     Special effects  ON.     \
| \
][   OK   ]"                   ) ; 
                  }
                  break ;
               default :
                  quit( E_PROGERROR ) ;
            }
            v_clsvwk( handle ) ;
         }
      if( wind_update( END_UPDATE ) == 0 )
         quit( E_END_WIND_UPDATE ) ;
   }  while( TRUE ) ;
}

#define SSP A7
#define TRAP2 0x0088L
#define illegal dc.w 0x4AFC   /* used while testing */

int   FX_CHECK() , GEMTRAP() ;      /* labels are needed outside FXcontrol() 
                                       assembly for detour() and highway() 
                                    */
FXcontrol()                   /* Here comes the value added part of this 
                                 program:
                              */
{  asm   {
FX_CHECK:
         move.w   SR       , -( SSP )
         movem.l  D0 / A0  , -( SSP )  /* careful with registers */
         cmpi.w   #0x00C8  , D0        /* signals GEM AES trap (?) */
         beq.s    intercept
         cmpi.w   #0x00C9  , D0        /* ditto (I KNOW 0x0073 means VDI!) */
         beq.s    intercept
togem:
         movem.l  ( SSP )+ , D0 / A0
         move.w   ( SSP )+ , SR        /* restore registers */
         move.l   GEMTRAP  , -( SSP )  /* back to normal AES & VDI handler */
         rts                        /* that's all for non-FX VDI/AES calls */
intercept:
         move.l   D1       , A0        /* D1 points to Parameter Block (PB) !
                                          old DRI docs said it's D0 ...
                                       */
         movea.l  ( A0 )   , A0        /* pointer to control[] array in A0 */
         move.w   ( A0 )   , D0        /* control[ 0 ] in D0 ... */
         cmpi.w   #GRAF_GROWBOX  , D0  /* ... == graf_growbox() ? */
         beq.s    gotit                      /* gotcha! */
         cmpi.w   #GRAF_SHRINKBOX, D0  /* or == graf_shrinkbox() ? */
         beq.s    gotit                      /* gotcha! */
         cmpi.w   #FORM_DIAL     , D0  /* or == form_dial() ? */
         bne.s    togem                      /* darn , missed! */
                                       /* form_dial() : check int_in[ 0 ].
                                          the form_dial() traps are necessary
                                          because f_d calls graf_growbox and
                                          graf_shrinkbox directly (how's that
                                          for modular code? ...). Same goes 
                                          for Atari's Desktop (rumours are
                                          the Desktop must be seen as one of
                                          the dirtier applications on the ST.
                                          Can't handle the Desktop, but we
                                          can catch form_dial() ...
                                       */
         move.l   D1       , A0        /* pointer to PB in A0 */
         movea.l  8( A0 )  , A0        /* pointer to int_in[] array in A0 */
         move.w   ( A0 )   , D0        /* int_in[ 0 ] in D0 ... */
         cmpi.w   #FMD_GROW   , D0     /* ... == fmd_grow ? */
         beq.s    gotit                      /* gotcha */
         cmpi.w   #FMD_SHRINK , D0     /* or == fmd_shrink ? */
         bne.s    togem                      /* false alert */
gotit:                              /* need to fake return value : */
         move.l   D1       , A0        /* pointer to PB in A0 */
         move.l   12( A0 ) , A0        /* pointer to int_out[] in A0 */
         move.w   #1       , ( A0 )    /* int_out[ 0 ] != 0 sufficient (?) */
         movem.l  ( SSP )+ , D0 / A0
         move.w   ( SSP )+ , SR        /* restore registers */
         rte                           /* return to calling application */
GEMTRAP:
         dc.l     -1L                  /* stowage for old TRAP 2 vector */
}        }


int   detour()                /* catch all TRAP 2 (GEM AES & VDI) calls */
{  long SaveSP ;                       /* storage for user stackpointer */
   
   SaveSP = Super( 0L ) ;              /* in supervisor mode */
   *(long *)GEMTRAP = *(long *)TRAP2 ;    /* save old trap vector value */
   *(long *)TRAP2 = ( long )FX_CHECK ;    /* wedge FX_CHECK into TRAP 2 */
   Super( SaveSP ) ;                   /* back to user mode */
   return( TRUE ) ;                    /* returns new fx_off */
}

int   highway()               /* restore normal flow of GEM calls */
{  long SaveSP ;

   SaveSP = Super( 0L ) ;
   if( *(long *)TRAP2 != ( long )FX_CHECK )     /* someone's been shooting
                                                   our game!
                                                */
   {  if ( *(long *)TRAP2 != *(long *)GEMTRAP ) /* and not for repairs either
                                                */
      {  Super( SaveSP ) ;                      /* to be on the safe side */
         form_alert( 1 ,
"[2]\
[  ®®®  S.W.S.  PROBLEM  ¯¯¯   \
|  I cannot properly restore   \
|  the normal TRAP 2 vector.   \
|  - The vector has changed    \
|    since 'FX OFF' was set.   \
][ Cancel ]" ) ;
         return( TRUE ) ;              /* returns new fx_off */
      }
      else                 /* somehow TRAP2 is restored. May have been a 
                              virus watcher program or even a virus! Since
                              the TRAP2 vector already has the 'reset' value
                              we would have set, assume we are back to normal
                           */
      {  Super( SaveSP ) ;
         form_alert( 1 ,
"[1]\
[  ®®®  S.W.S.  WARNING  ¯¯¯   \
|  I cannot properly restore   \
|  the normal TRAP 2 vector.   \
|  - The vector was restored   \
|    since 'FX OFF' was set.   \
][   OK   ]" ) ;
         *(long *)GEMTRAP = -1L ;      /* kill old copy; see below */
         return( FALSE ) ;             /* returns new fx_off */
   }  }
   else
   {                                /* in super mode : */
      *(long *)TRAP2 = *(long *)GEMTRAP ;    /* restore old TRAP 2 vector */
      *(long *)GEMTRAP = -1L ;         /* kill 'old' copy; just in case
                                          someone changes TRAP 2 himself. 
                                          if -1 gets to be TRAP 2 vector 
                                          you're in BIG trouble, no doubt 
                                          about that. Being an odd address 
                                          it gives you two bombs (== address
                                          error). (I always like to be sure
                                          WHAT goes wrong if it HAS to ...)
                                       */
      Super( SaveSP ) ;             /* normal programs run in user mode ...*/
      return( FALSE ) ;                /* returns new fx_off */
}  }

