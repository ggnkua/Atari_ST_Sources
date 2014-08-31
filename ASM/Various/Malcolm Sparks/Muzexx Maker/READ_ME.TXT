                               MUZEXX MAKER

Purpose:
          Muzexx Maker is a program to write rhythms, music and sound fx 
          for games. It outputs data to be loaded by a program and passed 
          to an interrupt routine which controls the sound chip.

Loading:
          Load MUZEXX.PRG from the desktop in low resolution.

Selecting a channel:
          There are three channels available on the YM2149. These are 
          represented by the three windows to the left of the screen. They 
          are selected using <F1>,<F2> and <F3> or by the left and right 
          arrows.

Inserting a note into a channel:
          Press <insert> and then <N> at the LOOP/NOTE prompt. Then enter 
          the note number. This must be between 1 and 88 inclusive and are 
          the same as the piano key numbers. Middle C is 40, and there are 
          12 notes to an octave including sharps. Then enter the duration 
          in interrupt cycles. If you place the playing routine in the VBL 
          interrupt list then there will be 50 units to a second. Max 
          plays back at this speed.

          Now enter the envelope to be used. There are 64 envelopes 
          available. After this you are asked to enter a special para-
          meter. Enter N for Normal.
          (If you enter G for Glissando a pitch slide will occur to the 
          next note, and R signals that the note is a rest)

          After you have entered a list of notes you can scroll through 
          them using the up and down arrow keys. Notes are displayed in 
          orange test and can be deleted by pressing <delete>. Each note 
          or loop is preceeded by a silver number showing its place from 
          the start in cycles. This helps in synchronizing the three 
          channels. The current note is preceeded with a gold number.

Loops:
          Loops help to compact the song to save on memory, disk space and 
          especially time. If you wish to repeat a bar throughout a song, 
          (a rhythm perhaps), this takes very little time and the bar can 
          be altered very easily without having to go through the whole 
          song, like on my last music program.

          Loops are entered in the same way as notes. You must define a 
          block of music which can contain notes and loops (20 nested 
          loops possible). This is done by entering the start and the end 
          of the block. Now enter the number of repeats (1-99). Remember 
          that these are repeats and do not include the times when the 
          block may have been played. If you wish to have a bar played 4 
          times then enter the bar at loop the bar with 3 repeats.

          Any loop must be placed after the two references it makes since 
          the compiler only makes one pass.

New songs:
          Using the <+> and <-> keys on the keypad allow you to skip 
          between up to 10 songs in memory. These can be named by using 
          the <N> key and each name can be 12 characters. Each song can be 
          up to 105 cycles long which is over half an hour at 50 
          cycles/second. 

Envelopes:
          Volume and pitch curves can be defined easily. Press <F4> or 
          <F5> to define volume and pitch respectively. The envelopes are 
          made up in the same way as a song. <N> names the envelope.

          Draw the wave on a piece of scrap paper using straight lines. 
          Divide the wave into segments and enter them accordingly. This 
          gives greater flexibility than most synths.

          Each envelope can be up to 104 cycles long (3« minutes at VBL 
          rate). 

Inserting a volume segment:
          There are two types of volume in the sound chip- Fixed and 
          variable. Fixed is usually used since the wave effects 
          provided give quite a wide range of sounds.

          Press <insert> and make the choice of volume type.

          Then enter enter the level of the start of the segment, in this 
          case, volume (0-15). On a variable wave you must enter the wave 
          form number. This is equivalent to that in the sound chip. Usual 
          numbers are 8,10 and 12. Experiment to find the sound you want. 
          You will also have to enter a period for the wave and you may 
          wish to have a slide between this period and the successive one.

          Now enter the length of the segment in cycle time. Again, 50 is 
          usually a second. Press <N> on the WAVE FX? prompt.

          The next prompt (SLIDE IN LEVEL?) asks whether the level slides 
          in to the next level. This allows a fade in or fade out 
          producing better waveforms but costs slightly more in CPU time. 
          Now enter the frequency of the noise generator (1-31) or press 
          return is this is not applicable. The last prompt asks for the 
          mixer control parameter. You may chose to change the channel to 
          tone, noise or both. If there is no change in the mixer then 
          press return. (Remember on the first segment that tone is not 
          the default if the previous note was a noise).

Inserting a pitch segment:
          This is done in exactly the same way in the right hand window. 
          The level is usually 0 but other values cause the note to waver 
          'out of tune' if this is the desired effect. To enter a negative 
          value preceed it with a <->. Now enter the duration and press 
          <Y> for wave fx. 
          Wave fx allows a wobble in the segment. This is good for the 
          pitch but be very careful when using it on the volume envelope. 
          The wavelength is the number of cycles between a crest and a 
          trough. (I know this is scientifically wrong but it is my 
          program and I can do what I like). The amplitude is half the 
          difference in level of a crest and a trough. You may choose to 
          slide in these values to the next segment to create a more 
          bizarre sound. 
          Note. No noise parameters are entered in the pitch because they 
          are handled by the volume envelope. 

          If you want to hear the envelope at middle C, hold the right 
          hand shift button down. The envelope stops when you release the 
          button allowing you to experiment with different length notes. 
          If you have a MIDI instrument, the envelope will be played in 
          the same way when you touch a key and you have more choice of 
          pitch. If you have a pitch bend wheel, use this to bend the 
          envelope for added effect.

New envelopes:
          Using the <+> and <-> keys on the keypad allow you to skip 
          between up to 64 envelopes in memory. These can be named by 
          using the <N> key and each name can be 12 characters. If you 
          have a MIDI instrument envelopes can be selected by changing the 
          envelope on the instrument.

Playing your song:
          This is achieved by pressing F10. The song will be played from 
          the highlighted place in the active window. You may have to wait 
          for any previous cycles to be skipped.

          When you play the song you will see the cycle counter in the 
          input box showing you the number of cycles that have elapsed.

File handling:
          You can save or load songs or waves by the keys <S> and <L> or 
          output the song as a data file with the key <O>. This saves the 
          necessary information which you can use in your own programs. To 
          do this, refer to the relevant section.

          If you wish to save an entire session use functions keys F6 and 
          F7 to load and save your work under a .MEM file. This means that 
          you don't have to load up all your envelopes separately each 
          time you load the program up. This is the most convienient way 
          of saving your work. Use <S> and <L> for cutting and pasting 
          between sessions.

Termination:
          If you wish to quit, press Q and respond to the confirmation 
          prompt.

Tips:
          Make good use of the session saving option since it will save 
          you a lot of tedious loading with many envelopes.
          
          Try to build a library of different envelopes for use in your 
          songs. This saves time and is very useful when writing new 
          pieces.

          Use the cycle counter effectively for pin-pointing errors in the 
          music. 

          It is a good idea to name your songs and envelopes instead of 
          relying on just the filename. All the keyboard characters are 
          available unlike in a filename. 

          Try to use the loop facility as much as possible since it not 
          only speeds up composition but gives much smaller output files 
          and saves memory.

          Use the variable volume option with periods of 5-100 for more 
          piercing sounds and special effects in games.

          Look at the examples included on the disk to see how to use 
          loops most effectively. The noise envelopes are usually found in 
          the first channel but they can be used anywhere. However, since 
          there is only one noise generator on the YM2149 it is a good 
          idea to have rhythms on one channel. If there is an overlap of 
          noise requests the most recent command is used. 

Using your compositions in your own programs:
          This is a rather complicated procedure. Firstly you must have a 
          data file of the song which is created by pressing the O key.
          
          Near the start of your program you will need to install the 
          actual routine that plays the song as an interrupt so that you 
          can let the CPU do other things while the music is playing. This 
          routine is labelled 'Minterrupt'. This will take the form:
                    
          MOVE.L    #Minterrupt,vector address
          
          One added complication, there is a byte labelled Minuse which is 
          a bitmap (xxxxxABC) of the channels played. This is used so that 
          you can select which channels to use individually, (eg. you may 
          want to reserve one channel for just sound fx). Minterrupt will 
          clear each bit when the corresponding channel has finished. 
          Before installing the interrupt, make sure these bits are all at 
          zero, otherwise Minterrupt may start playing the system varia-
          bles!

          There is an assembler file called MUSICMOD.S on the disk which 
          you must call to start the music off. When you need to play the 
          music, place the address of the start of the music, in register 
          a0. The whole thing should look something like this:

          MOVEA.L   #My_song,a0                   Start of song data
          JSR       Mplayer                       Call preparation routine
          .
          .
          .
Mplayer   INCLUDE   "A:MUSICMOD.S"                Devpac2 include command
          .                                       (use equivalent)
          .
          .
Msong     INCBIN    "A:SONG1.MDT"                 Output file, again 
                                                  Devpac2.
           
          Incidently, there is a source code example called EXAMPLE.S 
          included on the disk. Please look at this before writing your 
          own program.
          
          Remember to read the licence details on the disk if you wish to 
          incorporate your own music in commercial programs.


