;----------------------------------------------------------
;
;
;
;
;
;
;                PROtracker replay routine
;                ÿÿÿÿÿÿÿÿÿÿ ÿÿÿÿÿÿ ÿÿÿÿÿÿÿ
;                        converted
;                           by:
;
;                        ¯ Lance ®
;
;
;
;                ( TRASH - mode enabled! )
;
;
;----------------------------------------------------------
; Version 3.T
; In this new version of my PT2.2 replay routine there have
; been an major change. I have added TRASH - mode to the
; play routine. Believe me TRASH - mode is no trash at all
; (get it :-) ) and is ideal for my replay routine. TRASH -
; mode means that my replay routine creates buffers so that
; it don't harm if the replay routine and your nice 2,000
; pixels 3D ball sometimes together takes more time than
; the total rastertime ,just don't let happen to often.
; This ideal for my replay since it optimises the time it
; takes depending how many voices is active at the moment
; and how high frequency they are playing at the moment.
; For example if your nice ball is rotating on the screen
; and there sudden is a drum hit which make my replay
; routine demand more rastertime than there is available at
; the moment this replay won't sound crap or and your ball
; will not start to rotate jerky instead the routine will
; start eating of it's buffers instead. But there is only
; 8 buffers and just 8 vbl of precalcuated sound data isn't
; to small . I don't think so (please contact me if feel
; diffrent) since the replay routine is still updating the
; buffers just not fast enough. Let's say when the drumhit
; comes all buffers are filled up. Because of the drumhit
; the replay routine just 90% of time it needs. Still it
; can play for c:a 65 frames without sound distorsion
; (theoretical 69 frames) usually drumhit are shorter than
; a second. If the rastertime is exceeded for a long time
; then sound will sound real strange.If there was 16
; buffers then sound in our example will last c:a 3 sec.
; (theoretical :) the reality can be far more complex
; than my simple musicians).
; ADD : I have made a little change in the code since I
;       wrote this . I have added a constant called 
;       mt_frame_number which can be found directly
;       under my starting comments in the code.
;       It is set to 3 in the beginning which means that
;       there 8 buffers. If you change it to four you will
;       16 buffers and 5 == 32 buffers and so on so now
;       you decide for your own. The lowest you can set
;       is 1 don't try 0 and negative numbers It won't
;       work I can tell you.
;----------------------------------------------------------
; This replay is made to fit demos and democoder it's 
; purpose isn't to give the ultimate soundquality but to
; give near-top quality sound and to take as little time
; as possible. To do this I had to implent some tricks that
; not always will please the nice-to-the-system guy.
; The drawback for this code is that it sucks silicon 
; it eats memory in other words , but if you have one meg
; it should be enough (I hope) the replay also has one more
; major drawback ,some samples may sound very strange in
; this replay. It sounds that way since I have an odd way
; to calcuate the frequency which also make this replay as
; fast as it is (fast 50kHz routines usually cheats in one
; way or another).Usually the replay sounds good.
; To make more ideal for demos I have implented a function
; that the demo-coder calls to see which position the replay
; is at . Why isn't that just to read off the variables
; mt_songpos and mt_patternpos?
; Since it's a TRASH player it's not that easy.
; I will give the demo-coder to reason to time the demo with
; the music :
; 1: Demos with timing are nicer to watch and gives a more
;    proffesional impression.
; 2: If the demo-coder got himself a good musician (lucky
;    bastard) and is planning a time-consuming bit in the
;    demo then he can ask musician to use only 2 voices
;    there and using low frequencies to make my replay use
;    little time. If he is a good musician he can make it
;    sound good anyway. Then when the coder makes the demo
;    he just time it so that time-consuming bit comes at
;    the same time as the special music bit.
;    It's not hard but it's boring (XiA have made some real
;    cool 2 channels modules.
;---------------------------------------------------------
; How will I have to code to most efficiently use this
; superior TRASH - technique?
; As all good coders know there don't exist a 'best' way
; to do it but and idea is: First in your vbl rout you
; jump to mt_vbl then call your 2,000 pixel ball.
; In your main_loop outside the vbl you call the mt_update
; leaving it the time that is left of the vbl. And after
; the mt_update you call other TRASH routs with lower
; priority like depacking the next part.
;---------------------------------------------------------
; I realised that if you would like to do two frame
; things the trash mode is not ideal so I put in an 
; option to turn it off mt_trash_off and mt_trash_on to
; turn it on again.
;---------------------------------------------------------
; The part mt_music isn't my own code but ripped from 
; Amiga it is therefor not optimized , before when my 
; routines took 60%++ I thought that there was no idea but
; now I found it very irritating that it is so lame coded
; sometimes adds upto 9 rasterlines !! to my code,that is
; 10% of what my Paula emulator takes.
; If someone could offer me a good optimised PT2++ replay
; routine for the Amiga I would be very happy.
;----------------------------------------------------------
; And now a short explaination of the diffrent subroutines
; in pt_src50.s ...
; All routines shall be called with an jsr or bsr.
; mt_init         : Must be called initalises module,creates
;                   frequency codes etc. etc.
; mt_vbl          : The one you shall call first in your vbl
;                   rout or TimerA rout don't take much time
;                   unless you haven't turned trash off then
;                   it update next buffer
; mt_trash_on     : Turn on trash mode (trash mode is
;                   default).Just call it and let's TRASH :)
; mt_trash_off    : Turn trash mode off and forces update
;                   on the mt_vbl instead. Be little careful
;                   when you call these sub-routs ,don't
;                   call them from a interrupt
; mt_ask_buf_full : If all buffers are filled up then this
;                   sub-routs sets d0 = -1 else d0 = 0.
; mt_ask_position : Gives the song position in d0 and the
;                   pattern position in d1.
; mt_update       : If we are in trash mode this one update
;                   the buffers. Should NOT be called from
;                   vbl or any other interrupt. But in the
;                   main loop.Should also be given a high 
;                   priority.
; mt_end          : Call this when you are finished , don't
;                   do much but is necessary.
;----------------------------------------------------------
; Last : Please excuse my bad english ... The only language
;        I master is Machine Language(MC68000) :-)
;----------------------------------------------------------
; By the way : Have a wonderful life !!
;----------------------------------------------------------
;      - Lance / M†rten R†nge      1994/01/01
;----------------------------------------------------------
; P.S. This whole work was written in DevPac 3.00 
;      God Bless HiSoft                                 D.S
;----------------------------------------------------------