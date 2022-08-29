/*8.2.2  THE MIDIALL Program written in Megamax C programming Language */

/* ---------------- MIDI Main program in Megamax-C ----------------- */
#include <osbind.h>                
#include <geminit.h>               /* First load those things that */
#include <stdio.h>                /*  will be used for this run.  */

#define cls() printf("\33E");      /*  Clear the screen            */

extern long bios ();               /* Other necessary definitions  */
extern long gemdos ();
extern long systime();    /*  Used when references are made to local */
                          /* system time                    */
int midikan,status,pitch,velocity;            /* MIDI Parameters    */ 
int sndx, sfield [900];       /* Index + Feld for the  Sequencer    */

char *tonname [12] = {"c","c#","d","d#","e","f","f#","g","g#","a","a#","b"};
                                  /* List  for the names of the notes     */

main ()                           /* Begining of the Main program  */
{
 int germ=0,c=-1, id;
 id = appl_init();
 printf("Appl ID = %d \n",id);
 openwork();
 cls(); 
 setups();                /* Set up the Global variables     */
 while (germ!=-1)          /*   when germ is -1 quit           */
  {
   printf("\n 1  Communications Demo\n");  /* Main Menu: Here the various */
   printf(" 2  Chord  Demo\n");            /* features of the Demo are to */
   printf(" 3  Sequencer - Record \n");    /* be selected.                */
   printf(" 4  Sequencer - RePlay\n");
   printf(" 5  MIDI Commands\n\n\n");
   printf(" 6  Return to the desktop\n\n\n");
   printf(" Please select the desired function number and hit return: ");
   c=-1;
   while(c!=0)
   {
    if(c<1||c>5)
    {
     scanf("%d",&c);    /* Input with standard input function settings */
    }
    switch (c)       /* Internal menu for selecting the function calls */
    {  
     case 1:   talker();   c=0;  break;         /* Communications demo  */
     case 2:   chord();    c=0;  break;         /* Chord demo           */
     case 3:   record();   c=0;  break;         /* Recorder demo        */
     case 4:   playback(); c=0;  break;         /* RePlay demo          */
     case 5:   command();  c=0;  break;         /* MIDI command demo    */
     case 6:   germ=-1;     c=0;  break;         
     default:              c=0;  break;
    }                                     /* End of the switch   */
   }                                     /* End  while(c)       */
  }                                     /* End  while(germ)     */
closework();
appl_exit();
}                               /* End of the Main program   */
/* === Here are the routines that support the MIDI program.  === */
command()                         /*  MIDI Command Menu                 */
{                                 /* This is the second largest         */
 int i=0;                         /* selection Menu                     */
 int Yin=-1;
 cls();                           /* Clear the screen                   */
 while (i!=1)
 {
  printf("MIDI-Command Menu\n");
  printf("MIDI-Channel(1)    Sound(2)        Song-Select(3)    All notes off(4)\n");
  printf("\n");
  printf("Local on(5)      Local off(6)    Master Tune(7)    Reset(8)\n");
  printf("\n");
  printf("Omni on(9)       Omni off(10)    Poly on(11)       Mono on(12)\n");
  printf("\n");
  printf("Select (0) to return to main menu!\n\n\n");
  printf("Please select the desired function number and hit return : ");
  Yin=-1;
  while (Yin!=0)
   {
    if(Yin<0||Yin>12)
     {
       scanf("%d",&Yin);          /* Await input                        */
     }
    switch(Yin)                   /* Jump to the selelcted function     */
     {
      case  0: i=1;                break;
      case  1: kanal();     Yin=0; break;
      case  2: msound();    Yin=0; break;
      case  3: select();    Yin=0; break;
      case  4: allnoteoff();Yin=0; break;
      case  5: locoon();    Yin=0; break;
      case  6: locooff();   Yin=0; break;
      case  7: tune();      Yin=0; break;
      case  8: reset();     Yin=0; break;
      case  9: omnion();    Yin=0; break;
      case 10: omnioff();   Yin=0; break;
      case 11: polyon();    Yin=0; break;
      case 12: monoon();    Yin=0; break;
      default:              Yin=0; break;
     }                                          /* End switch     */
   }                                           /* End while(Yin) */
 }                                            /* End  while(i)  */
 cls();
}                           /* End of the internal Menu command()  */
wait(secs)
int secs; 
{ 
 int tsecs;
 while(secs--)
   for(tsecs=0; tsecs<60; tsecs++) 
       Vsync();
}
/*=================================================================*/
/*-----  Here are a number of functions that may be useful,   -----*/
/*----    in programs that you may develop in the future.      ----*/
/*-----------------------------------------------------------------*/

setups()                  /* Global variable insertion             */
{
   int i;                 /* Funktion index (Internal)             */
   midikan=1;
   pitch = 0;              /* Actual tone frequency                */
   velocity = 0;          /* Actual amplifier volume               */
   sndx = 0;             /* Index for the Sequencer (sfield[index]) */

   for (i = 0; i <= 899; ++i)
      sfield [i] = 0;                  /*     Zero the Sequencer     */
}
/*-----------------------------------------------------------------*/
long systime ()                            /* Timer value report   */
{
   long l, *p, stack;
   p = (long*)0x4baL;           /* Pointer to  200 Hz System Timer */   
/*   stack = gemdos (0x20, 0L);    Turn on the  Supervisor Mode    */                  
   l = *p;                      /* Copy the timer value            */        
/*   gemdos (0x20, stack);         Return to User Mode             */                      
   return   (l);                /* Return the Timer Value          */               
}
/*-----------------------------------------------------------------*/
constat ()                          /* Key board status report     */
{return ( (int) bios (1, 2) );}
/*-----------------------------------------------------------------*/
midiout (c)                         /* Send one byte to MIDI-OUT   */
int c;
{bios (3, 3, c);}
/*-----------------------------------------------------------------*/
midistat ()                         /* Report the MIDI-IN Status   */
{return ( (int) bios (1, 3) );}
/*-----------------------------------------------------------------*/
midiin ()                           /* Get a byte from the MIDI-IN */
{return ( (int) (bios (2, 3) & 0xff) );}
/*-----------------------------------------------------------------*/
midiflush ()                              /* Clear the MIDI-Buffer */
{while (midistat () )   midiin ();}
/*-----------------------------------------------------------------*/
silent ()                                        /* All_Notes_Off  */
{midiout(175+midikan);midiout(123);midiout(0);}

/*---------------- End of the General Function set-----------------*/
/*=================================================================*/
/*---Here are the routines that will be selected from the menues --*/

talker()                 /* Communications Demo with report text  */
{
   int c = 0;                   /* Define the necessary local vars */
   int n = 0;
   int i = 0;

cls();                                         /* Clear the Screen */
   printf("\n\n    Communications-Demo\n\n"); /* Text to the screen */
   printf("  The keys A-Z play notes on the Synthesizer,\n\n");
   printf("  Reports from the synthesizer are shown on the screen!\n\n");
   printf("  Terminate with the return key.\n\n");

   midiflush ();       

   c = 0;
   while (c != ' ')                    /* while other than a space */
   {
      if (constat () )                         /* any other key stroke  */
      {  c = (bios(2,2)&0xff);                 /* Recognize the number  */
         n = c;
         midiout(128);                        /* Next sense a  NOTE_OFF */
         midiout(i);                       /* After that the note plays */
         midiout(0);                    /* so long as no other new note */
                                                     /* arrives         */

         if (n >= 33 && n <= 126)            /* ASCII-Code of the Taste */
         {  
           midiout(144);                     
           midiout(n);                     /* convert to tone frequency */
           midiout(64);
           i = n;                  /* Send the tone instead of NOTE_OFF */
         }
      }

/* Here is the second part of the routine that identifies tones coming  */
/* in the MIDI-IN. To assure that both parts of the routine are well    */
/* controlled it allows a sort of tone recognition game to be played.   */
/* Depress a key on the computer keyboard, ascertain the correct tone   */
/* Frequency. Attempt now, to find the right key on the Synthesizer     */
/* keyboard for that same note.                                         */ 
 
      if (midistat () )                  /* If a Byte is in the MIDI-IN */
      { status=midiin(); 
        if (status==144)                /* and If the status is NOTE-ON */
        {pitch=midiin();                 /* recognize the frequency     */
         velocity=midiin();             /* and get the amplifer setting */
         shownote();}                   /* and show them on the screen. */
      }
   }
   silent ();                            /* Send out an  All_Notes_Off */
   cls();
}                                                      /* End Function */

/* That is the end of the communications function. A support fcn follows,*/
/* that measures the octave no. and the frequency of the note in MIDI-IN */
/* and outputs the MIDI-no, octave and note. (Sort of like a Sequencer.) */

shownote ()                          /* Show the Note on the screen */
{
 int oktav,oktave,ton;
 oktav=(int)(pitch/12);           /* Compute the Octave (divide by 12) */
 oktave=(int)oktav-2;            /* and subtract 2, so that it agrees   */
 ton=pitch-(oktav*12);          /* Recognize the note in the last Octave */
                               /* The variable ton is needed in order    */
/* that we can locate the right name in the Array tonname. There all of  */
/* the names of the sequence are carried, also the tone number means     */
/* in one Octave exactly the Name in the Array (e.g.the note 'D' is the  */
/* third Tone in an Oktave and it is also the third entry in the Array   */
/* TONNAME[ton] ). */

/* Everything will be put out on the screen. The lines shown on the     */
/* Monitor will be scrolled off the top of the screen.  Each line will  */
/* naturally slide up to top and dissapear rather slowly.  You will     */
/* know how to get out of the program as the instructions will be       */
/* written on screen each time a new program is started.                */
 
 printf("Terminate with the spacebar\n");
 printf("MIDI-Number: %d   Octave: %d   Tonename: %s\n",pitch,oktave,tonname[ton]);
}                                     
/*--------------------Here is where the function ends---------------------*/

chord()                              /* Play a chord  */
{
cls();
   printf("    Play a Chord\n");
   printf("    Terminate: Press any key\n\n");

   midiflush ();                                  
                                                  
   while (! constat () ) /* As long as a number comes in from the kbd   */
   {  if (midistat () )  /*  and if there is at least one byte on MIDI  */             
      { status=midiin();                  /* Fetch the BYTE and         */
        if (status==144||status==128)     /* if its NOTE_ON or NOTE_OFF */
         {  pitch=midiin();                         /* Read the pitch   */
            velocity=midiin();                      /* Read the Ampli   */
            putchord (4);                  /* and play additional tones */
            putchord (7);                 /* with offsets of 4, 7, and  */
            putchord (12);                      /* 12 half-tones        */
         }
      }
   }

   silent ();                                   /*  Send  All_Notes_Off */ 
   cls();
}
/* In opposition to this same program in GFA Basic, the request that    */
/* lets you input new Offset-Tones while the Program is running does    */
/* not exist.  It is left as an exercise to the C programmers to add    */
/* that feature. Only through your own programming efforts will you     */
/* how to use the MIDI; experiment with the Program, it will help you.  */
/* The BASIC-Program is almost identical with this C-Listing, if you    */
/* can't get it to work, take a look over there.                        */ 

/*----------------------Support Functions for Output--------------------*/

putchord (offset)           /* Play the tone and the given off-set tone */
int offset;                                 /* Fetch the Off-Set value  */
{
   midiout (status);                            /* Get the Status word  */
   midiout (pitch + offset);      /* Add the offset and the Fundametnal */
   midiout (velocity);                        /* Use the same Amplitude */

/* Since the same amplitude (Velocity) value is used for the add-ons    */
/* the offset tones are at that same level as the original note.        */
/* An interesting effect can be created by setting the offset tones to  */
/* maximum amplitude, even when the fundamental is very quiet.          */
/* To do this simply set the velocity word to 128 instead of the input  */
/* value.  It would be interesting to see what would happen if we allow */
/* the velocity to change on command, or even randomly.  Try that.      */
/* If you also allow the offset frequency to change with respect to the */
/* fundamental tone, or let the extra tones be randomly selected, you   */
/* find that most of the random Composer program is finished.           */
 
}
/*---------------------------End  of the Function-----------------------*/         
/*----------------------------------------------------------------------*/
/*-------------------Here comes the MINI-MIDI-SEQUENCER-----------------*/

record()                         /* Input function for the Sequencer    */
{
 int x=0,dummy=0;
 long starttime= 0L;
 cls();
   printf("    Sequencer Input\n");
   printf("    To Quit, Hit a Key\n\n");

  midiflush ();  
  sndx = 0;     

 while(dummy==0&&!constat())      /* Wait for the first tone or quit.   */   
 {
  if(midistat())                  /* If there is a tone in the MIDI IN  */
  x=midiin(); 
  if (x==144)                     /* and if it is NOTE_ON               */
   { 
    sfield[0]=144;                  /* Status reader                      */
    sfield[1]=midiin();             /* Tonhoehe reader                    */
    sndx=2;
    starttime=systime();          /* Measure the time for the duration  */
    dummy=1;
   }
 }                               /* End for the first tone              */

 while(sndx<=890&&!constat())   /* The next tones are run in a loop    */
 {                               /* that waits at least until there is  */
  x=midiin();                    /* a NOTE_OFF for the first tone has   */
  if(x==144||x==128)             /* to come                             */
   {
   sfield[sndx+1]=x;                       /* Like we said before */
   sfield[sndx+2]=midiin();
   sfield[sndx]=systime()-starttime;
   starttime=systime();
   sndx+=3;                              /* Increment the Index        */
   }               /* If the field index has gone to at least 4 and     */
                   /* also we have sfield[i+3]=midiin(); The Amplitude    */
                   /* can be shown with it. When this routine is used   */
                   /* with the Funktion play() The specific value       */
                   /* has to be input.                                  */
 }                                                 /* End  while Feld */
}                                                      /* End  record */

playback()                         /* Play back the record() Sequenz */
{ 
 long starttime=0L;
 int dummy=0;
 sndx=0;
 cls();
  printf("    Repeat\n");
  printf("    To Stop Hit any Key!\n\n");

 midiflush ();   

 while(!constat()&&sndx<=890)    /* As long as no key is hit          */
  {
                                  /* If the Sequencer is to be synch'd */
                                  /* with other devices, like a Drum   */
                                  /* Machine or an Effects Generator   */
                                  /* Then you need to put a command    */
                                  /* for the Syncronization right here!*/                            

  midiout(sfield[sndx]);           /* Simply read the Output Field      */
  midiout(sfield[sndx+1]);
  midiout(64);                    /* Replaces 64 with  sfield[index+2]   */
                                  /* if the whole thing should react   */
                                  /* to the amplifier.                 */
                                  /* Don't forget that the  Index is   */  
                                  /* to be incermented by +=4          */

  starttime=systime();            /* Timer call for tone length        */
  while(systime()-starttime<sfield[sndx+2]) /* compare with             */
                                           /* the stored value, and    */
   {dummy++;}                              /* wait until there isn't   */
                                           /* any difference           */
  sndx+=3;                             /* then read the next value    */
  }                                                      /* End  while */
}                                                     /* End  Playback */

/* Normally a  Sequencer offer a multitude of possibilities, to        */
/* work on the Music after it is recorded.  In this case you will find */
/* a couple of surprises, on how expandable the MINI-MIDI-SEQUENCER is.*/
/* As the music is quantified, the timing data must be put in an array */
/* of fixed locations. Changing the Tempo of a recorded piece is easy  */
/* to do by adding an offset value to the timing data, simply put a    */
/* offset value into each timing data field in the record, try it.     */
/* Step-by-Step-Editing is also very easy to do with the record.       */
/* Display the values of the Sequencer fields on the monitor and       */
/* program an input dunction, that replaces the input data values      */
/* directly on the screen. Since all of the data is interger numbers   */
/* the whole thing can be done with a value simple Move statement.     */
/* Naturally this Edit Feature would be a lot nicer if it was done     */
/* using a graphic representation of the data.  However, when you get  */
/* that far along perhaps you might want to think about marketing      */
/* the whole package as full fledged Music Editing Software?           */  

/*=====================================================================*/
/*---------Now come the support routines for the MIDI Commands---------*/
/*---------------------------------------------------------------------*/

kanal()                                   /* Select the MIDI Channel  */
{
cls();
printf("The Actual MIDI Channel is:%d\n",midikan);
printf("Please input the MIDI Channel Number: ");
scanf("%d",&midikan);                 

/* In case the selection is not logical, revert to MIDI Channel = 1   */

if(midikan<1||midikan>16)
 {printf("That MIDI Channel is not possible\n");midikan=1;}

evnt_timer(1000,0);        /* Wait while the guy reads the message.   */
cls();
}
/*-----------------------------------------------------------------*/
msound()                       /* Pick a Sound Number  */
{
 int soun;
  cls();
 printf("Please Input the new Sound Number:");
  scanf("%d",&soun);
  bios(3,3,191+midikan);   /* As you know, the Channel/Voice command */
                           /* is dependent on the installed MIDI     */
                           /* channel, therefore * + midikan         */ 

  bios(3,3,soun-1);     /* Computer always start counting at 0       */
                        /* and the synthesizer make no exceptions.   */
  cls();
} 
/*-----------------------------------------------------------------*/
select()       /* There are no new Program techniques down here      */
{
 int sel;                       
 cls();
  printf("Please enter the song number:");
  scanf("%d",&sel);
  bios(3,3,243);
  bios(3,3,sel); 
 cls();
}
/*-----------------------------------------------------------------*/
allnoteoff()             
{ bios(3,3,175+midikan);           /* Yes, yes the MIDI Channel ! */
  bios(3,3,123);
  bios(3,3,0); 
 cls();
}
/*-----------------------------------------------------------------*/
locooff()
{ bios(3,3,176);            /* From here on all routines are fixed! */
  bios(3,3,122);                /* to MIDI Channel 1 .             */
  bios(3,3,0);
 cls();
}
/*-----------------------------------------------------------------*/
locoon()
{ bios(3,3,176);
  bios(3,3,122);
  bios(3,3,127); 
 cls();
}
/*-----------------------------------------------------------------*/
tune()
{ bios(3,3,246);cls(); }
/*-----------------------------------------------------------------*/
sensing()
{ bios(3,3,254);cls(); }
/*-----------------------------------------------------------------*/
midistart()
{ bios(3,3,250);cls(); }
/*-----------------------------------------------------------------*/
midicontinue()
{ bios(3,3,251);cls(); }
/*-----------------------------------------------------------------*/
midistop()
{ bios(3,3,252);cls(); }
/*-----------------------------------------------------------------*/
reset()
{ bios(3,3,255);cls(); }
/*-----------------------------------------------------------------*/
omnion()
{ bios(3,3,176);
  bios(3,3,125);
  bios(3,3,0); 
 cls();
}
/*-----------------------------------------------------------------*/
omnioff()
{ bios(3,3,176);
  bios(3,3,124);
  bios(3,3,0); 
 cls();
}
/*-----------------------------------------------------------------*/
polyon()
{ bios(3,3,176);
  bios(3,3,127);
  bios(3,3,0); 
 cls();
}
/*-----------------------------------------------------------------*/
monoon()
{ bios(3,3,176);
  bios(3,3,126);
  bios(3,3,8);
 cls();
}
/*---------------------End of the Program listings---------------------*/
/*=====================================================================*/
