/*IMPORTANT!!!!!  second to last line of code has return(0) this
disables ecounters!! set to return 1 to enable!!! */
#include<globals2.h>

/* This module is really the heart of the program.
    It checks for events after every turn. I.e. 
    encounters, time, food, hp,sp.

    It will call many other modlues such as:

                         encounter...etc. */

char _clock_[] = "2 clock";       /*sound sample */
char thunder[] = "2 thund";
char crow[]    = "2 crow1";

int events()
   {
/* GLOBAL variable CURRENT_SKY holds the color of the current sky. */
    
    int check;
    static int semaphore =0;
    static int raining = 0;
    static int condition = 555;      /* variable, if roll a # greater than this, then encounter! */
    static int c_twice=0;        /* set if roll > condition */

    /* Weather forecast */
    mssg_count++;  /* inc the mssg count */
    if (mssg_count == 5) {clear_it(); mssg_count=0;}
    if ( weather == 1 && !semaphore) { semaphore=1;/*turn off for now */
                          Dosound( wind_sound );
                          condition= 522; /* probability of encounter is low */}
    if (weather == 4  && !semaphore) {semaphore=1; /* set so we will not enter again, until new weather occurs */
                        raining = 1; 
                        CURRENT_SKY = 0x444;
                        Setcolor(6,0x444);  /* grey sky */
                        Dosound( rain_sound );
                        condition = 380; /* encounter is high! */}
    if (weather == 2 && !semaphore) { Dosound( quiet );}
    if (weather == 3 && !semaphore) { Dosound( quiet );}
    if (weather == 5 && !semaphore) { Dosound( quiet );}
    if (weather == 0 && !semaphore) { Dosound( quiet );}

    CURRENT_SOUND = weather;          /* get value of current sound */

    check = pos_rnd(30000);
    if( check > 29983)
    {
     check = pos_rnd(1000);
     if(check > 50)
       {
        
        Setcolor(6,change[count]);  /*chane sky back from rainy, gloomy*/
         semaphore = 0;  /* reset so we can enter a sound routine*/
         raining = 0;    /* reset so we can change sky */
         check = pos_rnd(6);      
          weather = check;  /* get the weather */
                            /* 0 = Normal, 1= Windy, 2=Cool, 3=Hot, 4=Rainy, 5 = Cold!, 6 = Overcast*/
       }
    }
    /*keep track of time */
    time++;
    if( !raining )
      Setcolor(6,change[count]);  /*change sky */

     /* check to see if your starving.. */
     if(user.hunger_thurst_status[0] > 6) user.hp--;
     if(user.hunger_thurst_status[1] > 6) user.hp--;

  
    if(time == HOUR_VALUE)
     {
      time = 0;
      clock++;  /* inc clock if == 12 reset and call invoketsr(clock) */
      if (clock == 12)
       {

        clock =1;         /* these two: clock and am_pm tell the TIME OF DAY ! */
        if (am_pm == 1) am_pm = 0; /* if pm then when clock tolls change to am */
        else am_pm = 1; /* else set to pm */
        v_gtext(handle,6,51,"A clock tolls in");
        v_gtext(handle,6,59,"the distance......");
        invoke_tsr( _clock_ );      /*play clock */
        if(CURRENT_SOUND == 1) Dosound( wind_sound );
        if(CURRENT_SOUND == 4) Dosound( rain_sound );
         
          /* reset all active spells!! */
          for(check=0;check<5;check++)
          user.current_spells_active[check] = 0;
          
          /* update hunger/thirst stats */
          user.hunger_thurst_status[0]+=2; /*hunger */
          user.hunger_thurst_status[1]+=2; /* thirst */
        
          /* if cursed... */
          if( user.user_items[16] ) user.inte--;         
       }
      count += way;
        if(count ==12 || count == 1)
       {
        if(am_pm) am_pm = 0;
       else am_pm = 1;
        }
      if(count ==MIN) {way = 1;count =1;}
      if(count ==MAX) {way =-1;count = 12;}  
     
  
     
   /*   if( !raining )
      Setcolor(6,change[count]);*/  /*change sky */
          }/* end of time == hour value */
    /* and food,hp,sp! */


   /* if raining, play thunder every once and awhile */
   if (raining)
      {
       if( (pos_rnd(1500)) > 1497)    
       {   
        invoke_tsr( thunder );      /*play  */
         Dosound( rain_sound );     /* restore rain sound */
       }
      }
   if((pos_rnd(1500)) > 1497) 
     {
       if((pos_rnd(1500)) > 1497) 
       {
        v_gtext(handle,6,11,"A crow cries in the");
        v_gtext(handle,6,19,"distance...");
        invoke_tsr( crow );      /*play */
        if(CURRENT_SOUND == 1) Dosound( wind_sound );
        if(CURRENT_SOUND == 4) Dosound( rain_sound );
       }
     }
      
      
   
       

   if( !raining) CURRENT_SKY = change[count];
    /*check for encounter! */
    check=pos_rnd(condition+10);   /*roll a 1d12....0-11*/
    
 if(char_alive ==0) game_over();      /* for mon_alive to be 0, ALL*/
 


/* CONDITION GETS LOWER W/NITE AND BAD WEATHER*/



    if(check>condition)       {
       if ( c_twice == 15 )
        {
           c_twice = 0;
           return(1);
         }
    c_twice++;   /* set. next time thru if true the encounter */ 
      } 
   
    return(0);

   }
  




/**/
compute_time()
{
if(count > 24) count = 1;

count++;

}