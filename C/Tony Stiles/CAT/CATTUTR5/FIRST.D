@rem FIRST.D - this file is generated FIRST (i.e. first in the genlist)

@rem *************************************************************************

@rem By default, Bob can be commanded by Tony or Simon. Let's make him ignore
     any commands that simon may give to him. 

     We use PLAYERIS to find out if the player is Bob.
     We use CPLAYERIS to find out if the commanding player is Simon.

@low 
@if @playeris(bob) and @cplayeris(simon) @do @pmsg(no_way) @stop @endif

@msg No_way @msgtxt Bob mumbles, and ignores you. @endmsg

@rem *************************************************************************

@rem Such is Bobs hatred for Simon, he won't give things to him EVEN when 
     Tony tells him to!

@low
@if @playeris(bob) and @verbnois(give) and @iscompound and @cnounnois(simon) @do
   @pmsg(Wont_give_to_simon)
   @cont
@endif

@msg 	Wont_give_to_simon
@msgtxt 'I'm not giving anything to HIM!'
@endmsg

@rem *************************************************************************

@rem Added to this, Bob won't always obey Tonys commands. There is a 33% chance
     that Bob will ignore what Tony asks him to do!

@low
@if @playeris(bob) and @random(3) eq 1 @do
   @pmsg(bob_shakes_his_head)
   @stop
@endif

@msg	Bob_shakes_his_head
@msgtxt Bob shakes his head childishly.
@endmsg

@rem *************************************************************************

@rem Why is this code in a separate file? I mentioned earlier that CAT logic
     is processed in the order it occurs. We want to check ALL commands issued
     to Bob. Because we have used low priority logic in previous 
     lessons, we need to make sure that the above logic is processed FIRST!

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
    
(Because first.d is at the top of the genlist, it will be processed first,
 and therefore any logic contained in it will be executed first.)
