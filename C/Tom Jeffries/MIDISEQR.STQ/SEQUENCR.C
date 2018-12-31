/***********************************************************************/
/*                                                                     */
/*                          A Simple Sequencer                         */
/*                                                                     */
/*          Written by Tom Jeffries for START, the ST Quarterly        */
/*                                                                     */
/*                                                                     */
/*                                                                     */
/*                     Copyright 1986 by Tom Jeffries                  */
/*                          All rights reserved                        */
/*                                                                     */
/* UNAUTHORIZED COPYING OR DISTRIBUTION OF THIS PROGRAM IS EXPRESSLY   */
/*                              FORBIDDEN                              */
/*               THIS PROGRAM IS NOT IN THE PUBLIC DOMAIN              */
/*                                                                     */
/***********************************************************************/
/*                           INCLUDE FILES                             */
/***********************************************************************/

#include <gemdefs.h>
#include <osbind.h>
#include <vdibind.h>

/***********************************************************************/
/*                            DEFINES                                  */
/***********************************************************************/

#define MIDI (3)
#define CONSOLE (2)
#define window_kind (NAME|CLOSER)
#define MAXSONG (37000L)
#define Supexec(a) xbios(38,a) /*Delete this if using Megamax Compiler */

/***********************************************************************/
/*                        GLOBAL VARIABLES                             */
/***********************************************************************/

int wi_handle, ap_id, phys_handle, ph, intin[128],work_in[11],h,w,hh,ww;
int contrl[12],ptsin[128],intout[128],ptsout[128],work_out[60];
int xdesk, ydesk, wdesk, hdesk, dum, clip[4];
int tempo, flag1, res;
long songlength;
char *notebuffer, selection[13], path[64] = "A:\*.SNG";

/***********************************************************************/
/*                            ALERT BOXES                              */
/***********************************************************************/

char alert1[] = "[3][This program does not run|in low-resolution mode.][  OK  ]";
char alert2[] = "[2][      Would you like to       ][RECORD|PLAYBACK|QUIT]";
char alert3[] = "[3][The file extension| must be '.SNG' ][  OK  ]";
char alert4[] = "[2][        Would you like to        ][LISTEN| SAVE | ERASE ]";
char alert5[] = "[3][Not enough memory][  OK  ]";
char alert6[] = "[3][You have filled the | allocated space. ][  OK  ]";
char alert7[] = "[2][  A file with that name  |already exists. Overwrite?][ YES | NO ]";

/***********************************************************************/
/***********************************************************************/
/*                                                                     */
/*                          PROGRAM CONTROL                            */
/*                                                                     */
/***********************************************************************/
/***********************************************************************/

main()
   {
        Init();                         /*open GEM workstation*/

        res = Getrez();
        if(res == 0)                    /*must be medium or hi- res*/
                form_alert(1,alert1);
        else
           {
                Openwindow();           /*open the window*/
                Titlescreen();          /*put up the credits*/
                Loop();                 /*start the show*/
           }

        Mfree(notebuffer);              /*free the space allocated*/
        wind_close(wi_handle);          /*close the window*/
        wind_delete(wi_handle);
        v_clsvwk(ph);                   /*close GEM workstation*/
        appl_exit();
   }

/***********************************************************************/
                                            /*Main program control loop*/
Loop()
   {
        int end;

        do
           {
                switch(form_alert(0,alert2))           /*options*/
                   {
                        case 1:                        /*"RECORD"*/
                                Rcordinstructions();
                                In_loop();        /*MIDI and time input*/
                                Save_options();
                                Clearscreen();
                                Titlescreen();
                                end = 0;
                                break;
                        case 2:                        /*"PLAYBACK"*/
                                Selectsong();          /*Choose a song*/
                                if(flag1 == 1) /*1 = "OK", 0 = "cancel"*/
                                   {
                                        Playbackinstructions();
                                        Loadsong(path);
                                        Playsong();
                                   }
                                Clearscreen();
                                Titlescreen();
                                end = 0;
                                break;
                        case 3:                        /*"QUIT"*/
                                end = 1;
                                break;
                   }
           }
        while(end == 0);      /*Keep looping until "Quit" is chosen*/
   }

/***********************************************************************/
                       /*after recording you can listen, save, or erase*/
Save_options()
   {
        int end;

        do
           {
                switch(form_alert(0,alert4))
                   {
                        case 1:
                                Playsong();            /*"Listen"*/
                                end = 0;
                                break;
                        case 2:
                                Selectsong();          /*"Save"*/
                                if(flag1 == 1) /*1 = "OK", 0 = "cancel"*/
                                        end = Savesong(path);
                                else
                                        end = 0;
                                break;
                        case 3:                        /*"ERASE"*/
                                end = 1;
                                break;
                   }
           }
        while(end == 0);
   }

/***********************************************************************/
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

/***********************************************************************/
                                                 /*open GEM workstation*/
Init() 
   {
        long temp;
        int i;

        ap_id = appl_init();
        ph = graf_handle(&h,&w,&hh,&ww);
        for(i = 1; i < 10; work_in[i++] = 1);
        work_in[0] = ap_id;
        work_in[10] = 2;
        v_opnvwk(work_in, &ph, work_out);
        
        temp = Malloc(MAXSONG);    /*allocate enough space for song*/
        if(temp == 0)   
                form_alert(1,alert5);    /*warn if not enough space*/
        else
                notebuffer = (char *)temp;  
   }

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
/***********************************************************************/
/*                                                                     */
/*                          NOTE                                       */
/*                                                                     */
/* The following section parses the incoming MIDI data to make it      */
/* compatible with the graphics routines in MIDIMagic. If you wish to  */
/* eliminate this code you will have to replace it with a loop that    */
/* will read the contents of the array "midi[]" into the notebuffer    */
/* array, or else put the results of the Bconin(MIDI) calls directly   */
/* into the notebuffer.                                                */
/*                                                                     */
/***********************************************************************/

/*now parse the incoming MIDI data and put it in a form the graphics
  routines in MIDIMagic can read */
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
           }
        while(time != 0);  /*until ESC is pressed or buffer is full*/

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
              time = Supexec((*pter)); /*get the time in supervisor mode*/
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
/*                            DISK I/O                                 */
/*                                                                     */
/***********************************************************************/
/***********************************************************************/
             /*Get the current drive and set the path array accordingly*/
Getpath()
   {
        int curdrive, gp;
        static char pathstring[] = "A:\*.SNG";

        curdrive = Dgetdrv();
        pathstring[0] = path[0] = curdrive + 'A';
        for(gp = 1; gp < 8; gp++)
                path[gp] = pathstring[gp];
   }

/***********************************************************************/
                               /*make sure the file extension is ".SNG"*/
Checkend()          
   {
        int ce;

        ce = Strlen(path);
        if((path[ce-3] != 'S')||(path[ce-2] != 'N')||(path[ce-1] != 'G'))
           {
                form_alert(1, alert3);
                return(0);
           }
        else
                return(1);
   }

/***********************************************************************/
                                               /*borrowed from "DOODLE"*/
Setpath()      
   {
        int ii;
        char c;

        ii = Strlen(path);
        while(ii && (((c = path[ii-1]) != '\\') && (c != ':')))
                ii--;
        path[ii] = '\0';
        Strcat(path, selection);
   }

/***********************************************************************/
                              /*From K&R; return the length of a string*/
int Strlen(p1)
char *p1;
   {
        int len;

        len = 0;
        while(*p1++)
                len++;
        return(len);
   }

/***********************************************************************/
                                    /*From K&R; concatenate two strings*/
Strcat(pd,ps)
char *pd,*ps;
   {
        while(*pd)
                pd++;
        while(*pd++ = *ps++)
                ;
   }

/***********************************************************************/
                                         /*Open, load, and close a file*/
Loadsong(song)
char *song;
   {
        int fhandle;

        fhandle = Fopen(song,0);
        Fread(fhandle, MAXSONG, notebuffer);
        Fclose(fhandle);
   }

/***********************************************************************/
                                 /*Create, open, save, and close a file*/
Savesong(song)
char *song;
   {
        int fhandle;

        if((fhandle = Fopen(song,2)) > 0)          /*see if file exists*/
           {
                if(form_alert(2,alert7) == 2)              /*overwrite?*/
                   {
                        Fclose(fhandle);              /*don't overwrite*/
                        return(0);
                   }
           }
        fhandle = Fcreate(song,0);
        Fwrite(fhandle,songlength,notebuffer);
        Fclose(fhandle);
        return(1);
   }

/***********************************************************************/
             /*Use fsel_input to get the name of a file to load or save*/
Selectsong()
   {
        int exbutton, accomplished;

        do
           {            /*keep trying until a correct choice is made or*/
                                                   /*"cancel" is chosen*/
                accomplished = 1;
                Getpath();                  /*find out the current path*/
                selection[0] = '\0';             /*no default selection*/
                fsel_input(path,selection,&exbutton);
                vs_clip(ph,0,clip);          /*reset clipping rectangle*/
                Clearscreen();
                if(exbutton)                           /* OK was chosen*/
                   {
                        Setpath();
                        Dsetpath(path);
                        if(Checkend() == 0)     /*file ext must be .SNG*/
                                accomplished = 0;
                        flag1 = 1;
                   }
                else                                /*cancel was chosen*/
                        flag1 = 0;
           }
        while(accomplished == 0);
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

        notesoff[0] = 0X80;                                  /*note off*/
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

/***********************************************************************/
/***********************************************************************/
/*                                                                     */
/*                       SCREEN  DISPLAYS                              */
/*                                                                     */
/***********************************************************************/
/***********************************************************************/
                                                        /*Open a window*/
Openwindow()
   {
        static char winame[] = "    ******    A Simple Sequencer    ******    ";

        wind_get(0,WF_WORKXYWH,&xdesk,&ydesk,&wdesk,&hdesk);
        wi_handle = wind_create(window_kind,xdesk,ydesk,wdesk,hdesk);
        wind_set(wi_handle,WF_NAME,winame,0,0);
        wind_open(wi_handle,xdesk,ydesk,wdesk,hdesk);
        clip[0] = xdesk;
        clip[1] = ydesk;
        clip[2] = wdesk;
        clip[3] = hdesk;
   }

/***********************************************************************/
                                                     /*Clear the screen*/
Clearscreen()
   {
        static int screen[] = {4,22,636,198};

        if(res == 2)                          /*for monochrome monitors*/
           {
                screen[1] = 40;
                screen[3] = 394;
           }
        graf_mouse(M_OFF,0X0L);
        vsf_interior(ph,2);
        vsf_style(ph,8);
        vsf_color(ph,0);
        v_bar(ph,screen);
        graf_mouse(M_ON,0X0L);
   }

/***********************************************************************/
                                  /*displays the title and instructions*/
Titlescreen()
   {
        graf_mouse(M_OFF,0X0L);
        vst_height(ph,6,&dum,&dum,&dum,&dum);
        vst_effects(ph,4);
        v_gtext(ph,200,30*res,"START, the ST Quarterly, Presents:");
        vst_height(ph,20,&dum,&dum,&dum,&dum);
        vst_effects(ph,32);
        v_gtext(ph,220,60*res,"A SIMPLE SEQUENCER");
        vst_height(ph,9,&dum,&dum,&dum,&dum);
        vst_effects(ph,0);
        v_gtext(ph,230,155*res,"by Tom Jeffries");
        vst_height(ph,6,&dum,&dum,&dum,&dum);
        v_gtext(ph,200,170*res,"Copyright 1986 by Tom Jeffries");
        v_gtext(ph,240,178*res,"All rights reserved");
        v_gtext(ph,150,186*res,"This program is not in the public domain.");
        v_gtext(ph,100,194*res,"Unathorized copying or publication is expressly forbidden");
        graf_mouse(M_ON,0X0L);
   }

/***********************************************************************/
                                       /*instructions for record screen*/
Rcordinstructions()   
   {
        graf_mouse(M_OFF,0X0L);
        Clearscreen();
        vst_height(ph,20,&dum,&dum,&dum,&dum);
        vst_effects(ph,16);
        v_gtext(ph,250,60*res,"RECORDING");
        vst_height(ph,6,&dum,&dum,&dum,&dum);
        vst_effects(ph,0);
        v_gtext(ph,160,140*res,"Recording will start when you begin playing.");
        v_gtext(ph,210,160*res,"Press ESC to stop recording.");
        graf_mouse(M_ON,0X0L);
   }

/***********************************************************************/
                                     /*instructions for playback screen*/
Playbackinstructions()
   {
        graf_mouse(M_OFF,0X0L);
        Clearscreen();
        v_gtext(ph,150,140*res,"Press F1 to slow down, press F2 to speed up.");
        v_gtext(ph,260,160*res,"Press ESC to stop.");
        graf_mouse(M_ON,0X0L);
   }

/***********************************************************************/
/***********************************************************************/
