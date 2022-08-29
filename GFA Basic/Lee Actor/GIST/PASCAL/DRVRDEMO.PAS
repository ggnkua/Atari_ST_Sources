{   THIS PROGRM WILL INSTALL THE SOUND DRIVER (INTERRUPT ROUTINE),
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
   as a .SND file.

   Calling sequence is:

   snd_on(snddata,voice,volume,pitch,priority)

   where:

                   snddata :       String[112]

                   voice   :       Integer
                           the voice number corresponding to the
                           GI channel number 0, 1, or 2.  A -1
                           tells the sound driver to use any
                           available channel.  Any other value
                           will have no result.

                    volume  :      Integer
                           volume of the sound (0-15) or -1 to
                           use volume stored with sound data.

                    pitch   :      Integer
                           the pitch of the sound (1-255)
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

                    priority :     Integer
                           priority of the sound (0-255) where the
                           higher the value, the higher the priority.
                           Equal values take precedence over each
                           other.  When a sound_off is issued, the
                           priority is reduced to zero during the
                           release phase of any sound.


   The voice number used will be retunred.  If no voice was
   available, -1 is returned (NOTE:  type Integer is always
   returned).


Snd_off will cause the sound to move into its release phase and
   reduce the priority to zero.  If no voice is available, a -1
   is returned.

   The calling sequence is:

   snd_off(voice)

   where:

             voice   :         Integer
                           the voice which is to be moved into
                           its release phase (0, 1, or 2).  Any
                           other value has no effect.


Stop_snd will cause the sound to completely stop.  No matter what
   phase the sound is in (attack, decay, sustain, or release), the
   sound will end.  Unlike snd_off, there is no release.

   The calling sequence is:

   stop_snd(voice)

   where:

                voice   :      Integer
                           the voice which is to be stopped (0,
                           1 or 2).  Any other value has no
                           effect.


Get_prior will return the priority of the requested voice.  This
   routine is useful if you have a case where a snd_off might turn
   off the wrong sound.  You can call get_prior and issue the
   snd_off only if the priority matches the original.

        The calling sequence is:

        get_prior(voice)

        where

                voice   :          Integer
                           the voice whose priority is requested (0,
                           1 or 2).


Init_snds will stop all chanels on the GI chip by calling stop_snd
   three times with values or 0, 1 and 2.

   The calling sequence is:

   init_snds
}


PROGRAM File_Test ;

  CONST
    {$I gemconst}

  TYPE
    {$I gemtype}
    SndData = STRING [112] ;
    Path_Chars = PACKED ARRAY [ 1..80 ] of Char ;

  VAR
    drwho : SndData ;
    drnoise : SndData ;
    sample : SndData ;
    bytes_read : Long_Integer ;
    gem_name : Path_Chars ;
    alert : Str255 ;
    name : Str255 ;
    junk : Integer ;
    chan_num : Integer ;
    handle : Integer ;
    close_handle : Integer ;

  {$I gemsubs.pas}


  PROCEDURE install_int; C;
  PROCEDURE remove_int; C;
  FUNCTION snd_on( VAR data : SndData ; channel : Integer ;
    volume : Integer ; pitch : Integer ; priority : Integer ) : Integer; C;
  FUNCTION snd_off(channel : Integer ) : Integer; C;
  PROCEDURE stop_snd(channel : Integer ) ; C;
  PROCEDURE init_snds; C;
  FUNCTION get_prior( channel : Integer ) : Integer; C;

  FUNCTION f_open( VAR name : Path_Chars ; mode : Integer ) : Integer ;
    GEMDOS ($3d) ;

  FUNCTION f_close( handle : Integer ) : Integer ;
    GEMDOS ($3e) ;

  FUNCTION f_read( handle : Integer ; count : Long_Integer ; VAR buf :
    SndData ) : Long_Integer ;
    GEMDOS ( $3f ) ;

  PROCEDURE Make_Path( VAR ps : Str255 ; VAR cs : Path_Chars) ;

  VAR i : Integer ;

  BEGIN
    FOR i := 1 TO Length( ps ) DO
      cs[i] := ps[i] ;
    cs[ Length(ps)+1 ] := Chr(0) ;
  END ;

  PROCEDURE Get_Snd (name : Str255 ; VAR data : SndData) ;
    BEGIN
        Make_Path( name, gem_name) ;
        handle := f_open(gem_name, 0) ;
        IF handle >= 0 THEN
                BEGIN
                bytes_read := f_read(handle,112,data) ;
                close_handle := f_close(handle) ;
                END ;
        END ;

  BEGIN
    IF Init_Gem >= 0 THEN
      BEGIN
                {Load sounds into memory}
        name := 'A:\PASCAL\DRWHO.SND' ;
        Get_Snd (name,drwho);
        name := 'A:\PASCAL\DRNOISE.SND' ;
        Get_Snd (name,drnoise) ;
        name := 'A:\PASCAL\SAMPLE.SND' ;
        Get_Snd (name,sample) ;
        Make_Path( name, gem_name) ;

        {install_int will install the interrupt routine }
        install_int;

        {init_snds initializes all channels by stopping all sounds}
        init_snds;

        {No pitch is passed.  The duration parameter is .5 seconds
        and the release is 1 second.  The sound will be over in 1.5
        seconds.  The volume is set to 11.  This sound uses all
        parameters}

        junk := snd_on(drnoise,-1,15,-1,200) ;

        alert := '[1][This sound is a| sound effect...][ OK ]' ;
        junk := Do_Alert( alert, 0 ) ;

        junk := snd_on(drwho,-1,10,-1,200) ;

        alert := '[1][This sound is| another sound effect...][ OK ]' ;
        junk := Do_Alert( alert, 0 ) ;

        {No pitch is passed.  The sound is as before, but the volume
        is now 15.}

        junk := snd_on(drwho,-1,15,-1,200) ;

        alert := '[1][Again, but louder...][ OK ]' ;
        junk := Do_Alert( alert, 0 ) ;

        {Because a pitch value is passed, the sound will remain on
        until a snd_off is issued at which time the release phase
        of the sound will be initiated.}

        chan_num := snd_on(sample,-1,15,60,5) ;

        alert := '[1][This sound will continue| indefnitely...][ OK ]' ;
        junk := Do_Alert( alert, 0 ) ;

        { get_prior can be used to only turn the sound off if it is
        the same priority as in the original call, in this case, 5}
                IF get_prior(chan_num) = 5 THEN
                        junk := snd_off(chan_num) ;

        alert := '[1][Waiting for release...][ OK ]' ;
        junk := Do_Alert( alert, 0 ) ;


        {DRWHO will "steal" the channel from the initial sound played
        because it has a higher priority}

        chan_num := snd_on(sample,-1,-1,96,5);

        alert := '[2][Ready to interrupt with DRWHO...][ OK ]' ;
        junk := Do_Alert( alert, 0 ) ;

        junk := snd_on(drwho,chan_num,15,-1,10);
        alert := '[2][Ready for last demo...][ OK ]' ;
        junk := Do_Alert( alert, 0 ) ;

        chan_num := snd_on(sample,-1,-1,96,5);

        alert := '[1][This sound will continue| indefinitely...][ OK ]' ;
        junk := Do_Alert( alert, 0 ) ;

        stop_snd(chan_num);

        {remove_int will remove the interrupt routine}

        remove_int;

        Exit_Gem ;
     END ;
   END.


