@rem LAST.D - this file is generated LAST (i.e. last in the genlist)

@rem *************************************************************************

@rem ZZSTD has some processing to recalculate the score, from object points 
     plus counter 497. We need to test the score somewhere to see if the 
     player has completed the adventure. If we place this logic before ZZSTD
     processing, then the player will need to take an extra turn before the
     game ends - so we should ideally place it AFTER ZZSTD processing.

     @high 
     @if @score eq 210 @do
        @pmsg(well_done)
        @endgame
     @endif

     @msg    Well_done
     @msgtxt Well done, you have completed the tutorial adventure. LF
     @endmsg

@rem *************************************************************************

@rem Remember that fragile vase? We break it if the player drops it manually..
     but what if it is dropped automatically (ZZSTD has some logic to drop 
     objects until weight carried <= strength of player). 
     We should break the vase if it is dropped automatically - we need to do
     this after the ZZSTD processing.

     (it's okay for the vase to be in the bed!)

     @high
     @if @ishere(aa_vase) and (not @roomis(in_bed)) @do
        @swap(aa_vase,ab_vase)
        @pmsg(vase_broken)
     @endif
   
     @msg    Vase_broken
     @msgtxt Whoops - I think the vase has broken!
     @endmsg

******************************************************************************

@rem Why is this code in a separate file? I mentioned earlier that CAT logic
     is processed in the order it occurs. We want to perform the above logic
     AFTER all of the standard logic in ZZSTD.

     The genlist in this case is:

     first.d
     \cattutr1\tutor1.d 
     \cattutr2\tutor2.d
     \cattutr3\tutor3.d
     \cattutr4\tutor4.d
     tutor5.d
     \cat\std\zzstd.d
     \cat\std\zzrqd.d
     last.d
    
(Because last.d is at the bottom of the genlist, it will be processed last,
 and therefore any logic contained in it will be executed last.)
