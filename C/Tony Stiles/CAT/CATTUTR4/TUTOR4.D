@rem C Adventure Toolkit (CAT) - Tutorial #4

@rem Before reading this file, read tutor4.txt.

@rem *************************************************************************

@rem The following will print a welcome message on starting the adventure.
     The player will be set to TONY - this is duplicated from the first 
     tutorial, but that doesn't matter.

@init @pmsg(intro) @lf @lf @become(tony)

@msg 	Intro
@msgtxt	Hello, and welcome to the CAT tutorial adventure. Have fun!
@endmsg

@rem *************************************************************************

@rem The player has to put objects in the bed, in order to get a score.

     @init 
     @setcount(496,@roomno(in_bed))
     
@rem *************************************************************************

@rem By default the VOCAB command prints a list of all the available verbs.
     We're going to be difficult and block the command before it gets to 
     the logic in ZZSTD! We have to use low priority logic here because 
     we are interpreting a command from the player.

@low
@if @verbnois(vocab) @do @pmsg(sorry) @cont @endif
@lc

@msg sorry @msgtxt Sorry! @endmsg

@rem *************************************************************************

@rem And now some HIGH priority logic. Remember this happens after every turn,
     whether successful or not. 

     If the door is not locked, there is a 1 in 4 chance that Harry will
     lock it! If the player is in the same room as Harry and the door,
     we print the message 'Harry locks the door'. If the player is in the
     same room as the door, but Harry isn't here, 'Someone locks the door'.
     If it's dark, the player won't be told anything, whatever is there!

@high
@if (not @islocked(door)) and @random(4) eq 1 @do
   @lock(door)
   @if (not @isdark)
      @if @ishere(door)
         @if @ishere(harry) @do
            @pmsg(harry_locks_door)
         @else @do
            @pmsg(someone_locks_door)
         @endif
      @endif
   @endif
@endif
@lc

@msg 	Harry_locks_door
@msgtxt Harry locks the door!
@endmsg

@msg 	Someone_locks_door
@msgtxt Someone locks the door from the other side!
@endmsg

@rem *************************************************************************

@rem This hypothetical example will print 'Hello' 10 times, if the command
     'HELLO' is found. I need to use low priority logic because we are
     interpreting a command.
     
     @low 
     @if @verbnois(hello) @do
        @setcount(400,1)
        @while @count(400) le 10 @do
           @pmsg(hello)
           @addcount(400,1)
        @wend
        @cont
     @endif
     @lc
     
     @verb hello @endverb
     @msg hello @msgtxt Hello! @endmsg
     
@rem *************************************************************************

@rem I'm going to create two vases. The first is a 'fragile vase', the second
     is a broken vase. The fragile vase will start off being carried by 
     Simon. If this vase is dropped, it will be replaced with the broken one.

     We need to make sure that the command is not compound, i.e. we are
     going to allow 'PUT THE VASE IN THE BED' without it breaking!

@obj		aa_vase
@objsht		a vase
@objlng 	This vase looks valuable, AND fragile.
@objroom	In_simon
@objpnt		25
@endobj

@obj		ab_vase
@objsht		a broken vase
@objlng 	This vase WAS fragile. It is now broken!
@endobj

@low 
@if @verbnois(drop) and @nounnois(aa_vase) and (not @iscompound) and 
    (not @roomis(in_bed)) @do
   @pmsg(smash)
   @drop(aa_vase)
   @swap(aa_vase,ab_vase)
   @cont
@endif
@lc

@msg	Smash
@msgtxt S-M-A-S-H-!
@endmsg

@rem *************************************************************************

@rem Okay, let's go back to our RUB verb! If we rub the lamp, a genie pops 
     out and drops a gem. If we rub anything else, we get a nice corny message.
     We also need to make sure that the genie only appears ONCE!! Let's 
     add a touch of humour as well - what if the player rubs an active object?
     
     @low 
     @if @verbnois(rub) @do
        @if @nounnois(lamp) and @count(lamp) eq 0 @do
           @pmsg(genie_stuff)
           @toroom(@thisroom,gem)
           @setcount(lamp,1)
        @else @do
           @if @isactive(@thisobj) @do
              @pobjs(@thisobj)
              @pmsg(slaps_your_face)
           @else @do
              @pmsg(now_shiny)
           @endif
        @endif
        @cont
     @endif
     @lc
     
     @obj gem @objsht a gem @objpnt 10 @endobj

     @msg    genie_stuff
     @msgtxt POOF! A genie pops out of the lamp, curses when he sees you,
             and then pops right back in. I think he dropped something!
     @endmsg
     
     @msg    Slaps_your_face
     @msgtxt slaps your face!
     @endmsg
     
     @msg    Now_shiny
     @msgtxt Okay, it's nice and shiny now!
     @endmsg

     @rem I'm defining the genie for completeness - so when the player types
          'EXAMINE GENIE' he won't be told there is no object by that name!
          
     @obj genie @endobj
          
@rem *************************************************************************

@rem Okay, here's an example of interpreting a compound command:

     If the player tries to give the blue key to harry, he won't take it!

@if @verbnois(give) and @nounnois(blue_key) and @iscompound and 
    @cverbnois(to) and @cnounnois(harry) @do
   @pmsg(harry_doesnt_want_blue_key)
   @cont
@endif

@msg    Harry_doesnt_want_blue_key
@msgtxt Harry doesn't want the blue key!
@endmsg

@rem *************************************************************************
