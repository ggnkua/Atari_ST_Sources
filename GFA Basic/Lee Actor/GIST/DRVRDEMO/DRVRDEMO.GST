/*  THIS PROGRM WILL INSTALL THE SOUND DRIVER (INTERRUPT ROUTINE),
    DEMONSTRATE SOUND EFFECTS WITH FIXED DURATIONS AND PRIORITIES
    AND SHOW TWO DIFFERENT WAYS TO TURN A SOUND OFF.  IT WILL THEN
    REMOVE THE INTERRUPT ROUTINE.  THIS OR ANY OTHER APPLICATION 
    MUST LINK TO THE APPROPRATE FILES DEPENDING ON THE COMPILER
    USED.
        
    THE SOUND DRIVER OPERATES UNDER THE 200 HZ SYSTEM TIMER
    INTERRUPRT ROUTINE.  IT IS INSTALLED BEFORE THE REGULAR SYSTEM
    AND THEREFORE EXECUTES BEFORE THE REGULAR SYSTEM INTERRUPT.

    WORD MUST BE DEFINED APPROPRIATELY DEPENDING ON COMPILER.


Snd_on  will play a sound that was created using GIST and stored
   as a C source code (see drnoise[], drwho[] and sample[] below)
   on a channel of the GI chip.
        
   Calling sequence is:
        
   snd_on(sndptr,voice,volume,pitch,priority)
        
   where:
        
   WORD    *sndptr =       the pointer to the array of parameters
                           known as sound data, e.g., drwho[].
                                
   WORD    voice   =       the voice number corresponding to the 
                           GI channel number 0, 1, or 2.  A -1 
                           tells the sound driver to use any 
                           available channel.  Any other value 
                           will have no result.
                                
   WORD    volume  =       volume of the sound (0-15) or -1 to 
                           use volume stored with sound data.
                                
   WORD    pitch   =       the pitch of the sound (1-255) 
                           corresponds to the semitone number 
                           (60 = middle C on a piano keyboard or 
                           262 Hz; 72 = one octave above; this is 
                           the same as MIDI pitch numbers).  If no 
                           pitch is specified, the nominal frequency 
                           value stored with the sound data
                           will be used.  In this case, the duration 
                           of the sound is also determined by a 
                           parameter of the sound data. If pitch is 
                           specified, the sound will remain on until 
                           a sound_off is issued.  In other words, if
                           no pitch is specified, it is considered a 
                           sound effect.  If pitch is specified, it
                           is considered a musical note with an 
                           unknown duration and must be turned off 
                           after the required duration has elapsed.
                           
   WORD    priority =      priority of the sound (0-255) where the 
                           higher the value, the higher the priority.
                           Equal values take precedence over each 
                           other.  When a sound_off is issued, the 
                           priority is reduced to zero during the
                           release phase of any sound.
                                
        
   The voice number used will be reutnred.  If no voice was 
   available, -1 is returned (NOTE:  type WORD is always returned
   except in GST which returns type int (32-bits)).
        
        
Snd_off will cause the sound to move into its release phase and
   reduce the priority to zero.  If no voice is available, a -1
   is returned.
        
   The calling sequence is:
        
   snd_off(voice)
        
   where:
        
   WORD     voice   =      the voice which is to be moved into 
                           its release phase (0, 1, or 2).  Any 
                           other value has no effect.
                                
                                
Stop_snd will cause the sound to completely stop.  No matter what
   phase the sound is in (attack, decay, sustain, or release), the
   sound will end.  Unlike snd_off, there is no release.
        
   The calling sequence is:
        
   stop_snd(voice)
        
   where:
        
   WORD     voice   =      the voice which is to be stopped (0, 
                           1 or 2).  Any other value has no 
                           effect.
                                

Get_prior will return the priority of the requested voice.  This
   routine is useful if you have a case where a snd_off might turn
   off the wrong sound.  You can call get_prior and issue the 
   snd_off only if the priority matches the original.

	The calling sequence is:

	get_prior(voice)
	
	where
	
	WORD	voice	=	   the voice whose priority is requested (0, 
                           1 or 2).  (NOTE:  type WORD is always 
                           returned except in GST which returns 
                           type int (32-bits)).
                           
                           
Init_snds will stop all chanels on the GI chip by calling stop_snd
   three times with values or 0, 1 and 2.
        
   The calling sequence is:
        
   init_snds()
        
*/

#define                 WORD    short

extern          snd_on(),snd_off(),stop_snd();
extern          install_int(),remove_int();
extern          appl_init(),appl_exit();
extern          init_snds();

WORD drnoise[] =
{
        100, 477, 31, 15, 1, 3, -16384, -1,
        -4572, 12, 0, -1, -1966, 1, -32768, 0,
        7864, 0, 1, -4080, -256, -4080, -256, 10,
        12944, 0, 0, 10, 12944, 293, -5746, -264,
        -17086, 282, 10212, -275, -15067, -264, -17086, 40,
        1, 7, -16384, 31, 0, -1, 24904, 24,
        -13107, -1, -4063, 12, 26214, -3, -31457, 10
};

WORD drwho[] =
{
        100, 477, -1, 15, 1, 3, -16384, -1,
        -4572, 12, 0, -1, -1966, 1, -32768, 0,
        7864, 0, 1, -4080, -256, -4080, -256, 10,
        12944, 0, 0, 10, 12944, 293, -5746, -264,
        -17086, 282, 10212, -275, -15067, -264, -17086, 40,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0
};

WORD sample[] =
{
        20, 52, -1, 15, 1, 15, 0, -1,
        -9830, 12, 0, -1, -1024, 1, -32768, 0,
        9830, 160, 1, -28, 360, -112, 1442, 6,
        -90, 0, 0, 1, -24716, 57, 10752, -6,
        23743, 5, -18586, -57, -24712, -6, 23743, 4,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0
};

main()

{

        WORD             chan_num;
        long    i;


     appl_init();

/*  install_int will install the interrupt routine */
        
        install_int();
        
/*  init_snds initializes all channels by stopping all sounds */
        
        init_snds();
        
/*  
        No pitch is passed.  The duration parameter is .5 seconds and 
        the release is 1 second.  The sound will be over in 1.5
        seconds.  The volume is set to 11.  This sound uses all parameters
*/
        
        printf("\n\n This sound is a sound effect...");
        printf("Press RETURN to continue ->");
        
        snd_on(drnoise,-1,15,-1,5);
        
        getchar();
        
        printf("\n\n This sound is another sound effect...");
        printf("Press RETURN to continue ->");
        
        snd_on(drwho,-1,11,-1,5);
        
        getchar();
        
        
/*
        No pitch is passed.  The sound is as before, but the volume
        is now 15.
*/
        
        printf("\n\n Again, but louder...");
        printf("Press RETURN to continue ->");
        
        snd_on(drwho,-1,15,-1,5);
        
        getchar();
        
        
/*  Because a pitch value is passed, the sound will remain on 
        until a snd_off is issued at which time the release phase
        of the sound will be initiated.
*/
        
        printf("\n\n This sound will continue indefinitely...\n");
        printf(" Press RETURN to issue a snd_off ->");
        
        chan_num = snd_on(sample,-1,-1,96,5);
        
        getchar();
        
        printf("\n\nWaiting for release...\n\n");
                
/*  get_prior can be used to only turn the sound off if it is
	the same priority as in the original call, in this case, 5
*/
	if (get_prior(chan_num) == 5)                 
      snd_off(chan_num);
        
/*    Wait to let the sound release 
*/

        for (i=0;i<300000;i++); 
        
/*  DRWHO will "steal" the channel from the initial sound played
    because it has a higher priority
*/
        printf("\n\n This sound will continue indefinitely...\n");
        printf(" Press RETURN to interrupt this sound");
        printf("\n  and play DRWHO with a higher priority ->");
        
        chan_num = snd_on(sample,-1,-1,96,5);
        
        getchar();
        
        printf("\n\nDRWHO has now taken over...\n\n");
        snd_on(drwho,chan_num,15,-1,10);
                

        for (i=0;i<300000;i++); 
        
/*  Because a pitch value is passed, the sound will remain on 
        until a stop_snd is issued at which time the sound will 
        immediately stop.
*/
        
        printf("\n This sound will continue indefinitely...");
        printf("\n Press RETURN to issue a stop_snd and exit ->");
        
        chan_num = snd_on(sample,-1,-1,96,5);
        
        getchar();
        
        stop_snd(chan_num);
        
        
/*  remove_int will remove the interrupt routine */

        remove_int();

     appl_exit();       
}

