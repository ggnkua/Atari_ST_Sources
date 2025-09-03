
#include <stdio.h>
#include <osbind.h>
/* #include <strings.h>	*/
#include <obdefs.h>
#include <gemdefs.h>
#include "dx.h"
#include "dxed.h"

#define CONSOLE (2)
#define MAXSONG (3700L)

extern int midi_ch;

int tempo, flag1;
long songlength;
char *notebuffer = NULL;
char selection[13];
char alert6[] = "[3][You have filled the | allocated space. ][  OK  ]";
char alert5[] = "[3][Not enough memory][  OK  ]";
char alert4[] = "[1][You are about to | record.  Press ESC | to stop.][ OK ]";

/***********************************************************************/
/***********************************************************************/
/*                                                                     */
/*                INCOMING MIDI DATA ("RECORD")                        */
/*                                                                     */
/***********************************************************************/
/***********************************************************************/
/*main input loop*/
In_loop()
{
	long In_timer(), time;
	register long basetime, i, notelength; /*register variables are faster*/
	register char midi[50];
	int a,b,c;

	form_alert(1,alert4);
	init_seq();
	notebuffer[56] = 36;                       /*set the base tempo*/
	notebuffer[64] = 255;                 /*start with a short rest*/
	notebuffer[65] = 20;
	i = 66L;                           /*offset to first MIDI value*/

	while(Bconstat(MIDI) != 0)                  /*flush MIDI buffer*/
		Bconin(MIDI);

	basetime = In_timer();                   /*get a starting value*/

	do 
	{ 
		for(c = 0; Bconstat(MIDI) != 0; c++)   /*get MIDI input*/
			midi[c] = (char)Bconin(MIDI);
		if(midi[0] == 0) /*get rid of leading 0 caused by turning on*/
			a = 1;    /*a CZ-101 after "RECORD" is selected*/
		else
			a = 0;

	/*
		now parse the incoming MIDI data and put it 
		in a form the graphics
		routines in MIDIMagic can read
	*/
		while(a < c )
		{
			if(midi[a] < 0 || midi[a] > 127)  /*status byte*/
			{
				for(b = 0; b < 3; b++)  /*take it as is*/
				{
					if(a < c)
						*(notebuffer+i++)=midi[a++];
					else  /*make sure there are enough #'s*/
						*(notebuffer+i++)=(char)Bconin(MIDI);
				}
			}
			else /*if running status add $90 before first byte*/
			{
				*(notebuffer + i++) = -112;
				for(b = 0; b < 2; b++)
				{
					if(a < c)
						*(notebuffer+i++)=midi[a++];
					else
						*(notebuffer+i++)=(char)Bconin(MIDI);
				}
			}
		}

/***********************************************************************/
/*                 End of parsing section                              */
/***********************************************************************/

		time = In_timer();   /*wait for next event and get time*/
		if(time != 0)
		{
			*(notebuffer + i++) = 255;       
			notelength = (time - basetime)/4; /*note length*/
			if(notelength == 0)
				i--;
			else
			{            
				while(notelength > 127) /*no negative values*/
				{
					*(notebuffer + i++) = 127;
					*(notebuffer + i++) = 255;
					notelength -= 127;
				}
				*(notebuffer + i++) = (char)notelength;
				basetime = time;     /*reset for next note*/
			}
			if(i >= MAXSONG-10)/*check to make sure piece is not*/
			{               /*too long for allocated space*/
				form_alert(1,alert6);
				time = 0;
			}
		}
	}while(time != 0);  /*until ESC is pressed or buffer is full*/

	*(notebuffer + i++) = 255;            /*end  of song marker*/
	*(notebuffer + i++) = 255;
	*(notebuffer + i++) = 255;
	songlength = i;                        /*return the song length*/
}

/***********************************************************************/
             /*Waits for MIDI event or ESC, returns 200Hz clock if MIDI*/
long In_timer()
   {                  
        long (*pter)(), Getclick(), time;
        int end;

        pter = Getclick;                  /*set up the function pointer*/

        for(end = 0; Bconstat(MIDI) == 0 && !end;  )/*check for MIDI or*/
                end = Checkkeyboard();                 /*keyboard input*/

        if(end)             /*if user has pressed ESC return a 0 to the*/
                return(0L);                          /*calling function*/
        else           /*otherwise return the value in the 200 Hz timer*/
           {
              /*time = Supexec((*pter));*//*get the time in supervisor mode*/
			time = Supexec(Getclick);
              return(time);
           }
   }

/***********************************************************************/
                           /*reads the 200Hz click from supervisor mode*/
long Getclick()                   
   {                /*Location $04BA give the current 200Hz click value*/
     static long time = 0X4BA; /*It is in protected space so it must be*/
                                          /*accessed in supervisor mode*/
     return(*((long *)time));
   }

/***********************************************************************/
/***********************************************************************/
/*                                                                     */
/*                OUTGOING MIDI DATA ("PLAYBACK")                      */
/*                                                                     */
/***********************************************************************/
/***********************************************************************/

       /*Play the song in notebuffer at the tempo set in notebuffer[56]*/
Playsong()
   {
        static int m = 0, ps;
        unsigned int pi, end;
        char midistring[200];
        register long n;

        while(Bconstat(CONSOLE) != 0)           /*flush keyboard buffer*/
                Bconin(CONSOLE);

        n = 64;                               /*first byte of song data*/
        tempo = notebuffer[56];                      
        for(end = 0; end == 0; )
           {
                while (!end && *(notebuffer + n) != -1)/*get MIDI bytes*/
                                midistring[m++] = *(notebuffer + (n++));
                if (m != 0)                                 /*send them*/
                        Midiws(m-1, midistring);
                if (!end && *(notebuffer + (++n)) != -1) /*check for EOF FFFF*/
                   {
                        for(ps = 0; !end && ps < *(notebuffer + n); ps++)
                          {
                                end = Checkkeyboard();
                                Out_timer();/*wait one standard interval*/
                                m = 0;
                          }
                   }
                else                                  /*if EOF ($FF FF)*/
                   {
                        end = 1;
                        Allnotesoff();                 /*shut off synth*/
                   }
                m = 0;
                n++;
           }
   }    

/***********************************************************************/
                   /*shuts off all possible notes to avoid "hung notes"*/
Allnotesoff()
   {
        char notesoff[3];
        int ai, aj;

        notesoff[0] = 0X80 | midi_ch;                                  /*note off*/
        notesoff[2] = 0;                                  /*velocity 0 */
        for(ai = 0; ai < 128; ai++)        /*loop through all the notes*/
           {    
                notesoff[1] = ai;
                Midiws(2,notesoff);                   /*send the string*/
                for(aj = 0; aj < 500; aj++);          /*wait just a bit*/
           }
   }

/***********************************************************************/
                                     /*timing loop for Playsong routine*/
/*This can be replaced with a more sophisticated interrupt timer*/
/*I do not recommend using the GEM evnt_timer for this purpose*/
Out_timer()
   {
        int ti, th;

        for(ti = 0; ti < tempo; ti++)
                for(th = 0; th < 75; th++);
   }

init_seq()
{
	long temp;

	if(notebuffer == NULL)
	{
		temp = Malloc(MAXSONG);    /*allocate enough space for song*/
		if(temp == 0)   
			form_alert(1,alert5);    /*warn if not enough space*/
		else
			notebuffer = (char *)temp; 
	} 
}

exit_seq()
{
	if (notebuffer != NULL)
		Mfree(notebuffer);
}

/*monitor the keyboard for ESC, F1, or F2*/
Checkkeyboard()                      
   {
        long keycode;
        int end;

        if(Bconstat(CONSOLE) != 0)
           {
                keycode = Bconin(CONSOLE);
                keycode >>= 16;              /*we just want high word*/
                if(keycode == 0X3BL)                                      /*F1*/
                   {
                        tempo++;
                        if (tempo == 500)    /*check bouandaries*/
                                tempo = 499;
                        return(0);
                   }
                else if(keycode == 0X3CL)                                 /*F2*/
                   {
                        tempo--;
                        if(tempo == 0)       /*check bouandaries*/
                                tempo = 1;
                        return(0);
                   }
                else if(keycode == 0X01L)    /*escape*/
                   {
                        end = 1;
                        Allnotesoff();       /*shut off synth*/ 
                        return(1);
                   }
                else
                        return(0);
           }
        else
                return(0);                   /*no keys pressed*/
   }
