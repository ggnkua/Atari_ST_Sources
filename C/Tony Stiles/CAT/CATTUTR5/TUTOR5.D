@rem C Adventure Toolkit (CAT) - Tutorial #5

@rem This last tutorial demonstrates some tricks.
     Before reading this tutorial, have a look at FIRST.D and LAST.D

@rem *************************************************************************

@rem After CAT has completed all low priority logic without being stopped
     (i.e. the STOP logic token has not been encountered) - THEN it will go 
     on to see if the verb matches a ROOMPTH for the current room. If it 
     does, then the player will be moved to the new room.

     If you want to sometimes 'block' players from taking a certain, path
     you must block it in the low priority logic using the STOP logic token.
     THE CONT logic token will not work!

     In this example, Harry will occasionally block the player from using
     'North' go get from the hallway to the bathroom. Remember...........
     YOU MUST USE STOP, or CAT will continue and allow you to take the path
     anyway!

     @low 
     @if @roomis(hallway) and @verbnois(north) and @random(5) eq 1 @do
        @pmsg(harry_wont_let_you_past)
        @stop
     @endif

     @msg 	Harry_wont_let_you_past
     @msgtxt	Harry stands in your way!
     @endmsg

@rem *************************************************************************

@rem I'm going to create another layer to the house, and the stairs between
     the two floors.

@obj 		aa_stairs
@objsyn		aa_stair
@objsht         a flight of stairs going down
@objroom	hallway
@objngt
@objportal	downstairs_hallway
@endobj

@obj 		ab_stairs
@objsyn		ab_stair
@objsht         a flight of stairs going up
@objroom	downstairs_hallway
@objngt
@objportal	hallway
@endobj

@room		Downstairs_hallway
@roomsht	Downstairs hallway.
@roomlng	You are in the downstairs hallway.
@roompth	east,lounge north,kitchen
@endroom

@room		Lounge
@roomsht	Lounge.
@roomlng	You are in the lounge.
@roompth	west,downstairs_hallway north,dining_room
@endroom

@room		Dining_room
@roomsht	Dining room.
@roomlng	You are in the dining room.
@roompth	west,kitchen south,lounge
@endroom

@room		Kitchen
@roomsht	Kitchen.
@roomlng	You are in the kitchen.
@roompth	east,dining_room south,downstairs_hallway
@endroom

@rem *************************************************************************

@rem Now, let's animate Bob a touch more. We'll give him a random chance of 
     walking around rooms, taking the 'obvious exits' - i.e. ROOMPTHs.
     We could make Bob do whatever we wanted - he could be a real character!

     If the player is Bob, he's already following a command, so leave him be.
     If the player isn't Bob, we'll animate him. First of all, we have to save
     the current player (in counter 450). Then we say we want to control Bob-
     from now on Bob is the current player. Now we come up with a random number
     between 1 and 6, corresponding to North,East,South,West,Up,Down - we store
     this number in counter 449. Now we check to see if the path corresponding
     to counter 449 is a valid path. If it is, then we'll move Bob (I have used
     TOROOM rather than GOTO so we don't get a room description). If Bob is 
     moving from the room of the player (counter 450), then print a message 
     'Bob leaves to the ...'. If Bob is moving into the room of the player
     (counter 450), then print a message 'Bob enters from the ...'.
     Last of all, we need to restore control to the original player (count 450)

     Note up/down relate to climbing either ab_stairs or aa_stairs.

@high
@if (not @playeris(bob)) @do
   @setcount(450,@player)
   @setcount(449,@random(6))
   @control(bob)
   @if @count(449) eq 1 and @verbpath(north) ne -1 @do
      @if @ishere(@count(450)) and (not @isdark) @do
         @pmsg(bob_goes_north)
      @endif
      @toroom(@verbpath(north),@player)
      @if @ishere(@count(450)) and (not @isdark) @do
         @pmsg(bob_enters_from_south)
      @endif
   @endif
   @if @count(449) eq 2 and @verbpath(east) ne -1 @do
      @if @ishere(@count(450)) and (not @isdark) @do
         @pmsg(bob_goes_east)
      @endif
      @toroom(@verbpath(east),@player)
      @if @ishere(@count(450)) and (not @isdark) @do
         @pmsg(bob_enters_from_west)
      @endif
   @endif
   @if @count(449) eq 3 and @verbpath(south) ne -1 @do
      @if @ishere(@count(450)) and (not @isdark) @do
         @pmsg(bob_goes_south)
      @endif
      @toroom(@verbpath(south),@player)
      @if @ishere(@count(450)) and (not @isdark) @do
         @pmsg(bob_enters_from_north)
      @endif
   @endif
   @if @count(449) eq 4 and @verbpath(west) ne -1 @do
      @if @ishere(@count(450)) and (not @isdark) @do
         @pmsg(bob_goes_west)
      @endif
      @toroom(@verbpath(west),@player)
      @if @ishere(@count(450)) and (not @isdark) @do
         @pmsg(bob_enters_from_east)
      @endif
   @endif
   @if @count(449) eq 5 and @ishere(ab_stairs) @do
      @if @ishere(@count(450)) and (not @isdark) @do
         @pmsg(bob_goes_up)
      @endif
      @enter(ab_stairs)
      @if @ishere(@count(450)) and (not @isdark) @do
         @pmsg(bob_enters_from_down)
      @endif
   @endif
   @if @count(449) eq 6 and @ishere(aa_stairs) @do
      @if @ishere(@count(450)) and (not @isdark) @do
         @pmsg(bob_goes_down)
      @endif
      @enter(aa_stairs)
      @if @ishere(@count(450)) and (not @isdark) @do
         @pmsg(bob_enters_from_up)
      @endif
   @endif
   @control(@count(450))
@endif

@msg 	Bob_goes_north
@msgtxt Bob goes north.
@endmsg

@msg	Bob_enters_from_north
@msgtxt Bob enters from the north.
@endmsg

@msg 	Bob_goes_east
@msgtxt Bob goes east.
@endmsg

@msg	Bob_enters_from_east
@msgtxt Bob enters from the east.
@endmsg

@msg 	Bob_goes_south
@msgtxt Bob goes south.
@endmsg

@msg	Bob_enters_from_south
@msgtxt Bob enters from the south.
@endmsg

@msg 	Bob_goes_west
@msgtxt Bob goes west.
@endmsg

@msg	Bob_enters_from_west
@msgtxt Bob enters from the west.
@endmsg

@msg 	Bob_goes_up
@msgtxt Bob goes up the stairs.
@endmsg

@msg	Bob_enters_from_up
@msgtxt Bob comes down the stairs.
@endmsg

@msg 	Bob_goes_down
@msgtxt Bob goes down the stairs.
@endmsg

@msg	Bob_enters_from_down
@msgtxt Bob comes up the stairs.
@endmsg

@rem *************************************************************************

@rem I am now going to introduce Molly - she lives in the kitchen. When she
     sees Bob, she will give him the key to the cupboard (the iron key).
     Otherwise, she'll get on with a random mundane task!

@obj 		Molly
@objsht		Molly
@objlng		Molly is the kitchen maid.
@objroom	Kitchen
@objngt
@objact
@objstr		40
@objinrm	In_molly
@endobj

@room In_molly @endroom

@obj		Cupboard
@objsht		a cupboard
@objlck		locked
@objkey		iron_key
@objroom	Kitchen
@objinrm	In_cupboard
@objngt
@objstr		60
@endobj

@room In_cupboard @endroom

@obj 		Iron_key
@objsht		an iron key
@endobj

@obj		ladle
@objsht		a golden ladle
@objpnt		50
@objwgt		5
@objroom	in_cupboard
@endobj

@rem Note: I am referencing the messages Molly_task_[1-4] indirectly, 
     by number. I find the number of Molly_task_1. I know that Molly_task_2
     is equal to Molly_task_1 + 1, because one occurs after the other!

@high
@if @iswith(molly,bob) and @count(molly) eq 0 @do
   @setcount(molly,1)
   @toroom(@objinrm(bob),iron_key)
   @if @playeris(bob) @do
      @pmsg(molly_gives_key_to_you)
   @else
      @if @ishere(molly) @do
         @pmsg(molly_gives_key_to_bob)
      @endif
   @endif
@else @do
   @if @ishere(molly) @do
      @setcount(450,@random(4))
      @addcount(450,@msgno(molly_task_1))
      @subcount(450,1)
      @pmsg(@count(450))
   @endif
@endif

@msg 	Molly_gives_key_to_you
@msgtxt	Molly pats you on the head, and gives you an iron key.
@endmsg

@msg	Molly_gives_key_to_bob
@msgtxt Molly pats Bob on the head, and gives him something.
@endmsg

@msg	Molly_task_1
@msgtxt Molly kneads some bread.
@endmsg

@msg	Molly_task_2
@msgtxt	Molly washes some dishes.
@endmsg

@msg	Molly_task_3
@msgtxt	Molly washes the windows.
@endmsg

@msg	Molly_task_4
@msgtxt	Molly cleans the floor.
@endmsg

@rem *************************************************************************

@rem Now, I'm going to be a bit sneaky! I'll create a hidden object 'floor'
     in the kitchen. When the player examines it the first time, he won't 
     find anything BUT if he examines it a second time then he will find a 
     tiny diamond! If he examines it more than twice he will be told there
     is nothing else!

     (I'll also create bread, and dishes for completeness)

@obj 		floor
@objhide
@objngt
@objroom	Kitchen
@endobj

@obj 		bread
@objhide
@objngt
@objroom	Kitchen
@endobj

@obj 		dishes
@objsyn		dish
@objhide
@objngt
@objroom	Kitchen
@endobj

@obj		diamond
@objsht 	a tiny diamond
@objlng		No wonder you missed this... it really is tiny!
@objpnt		20
@endobj

@rem Notice, the first time we examine the floor, we just add one to the 
    counter and then fall through to the default logic in ZZSTD 'nothing'.

@low 
@if @verbnois(examine) and @nounnois(floor) @do
   @addcount(@thisobj,1)
   @if @count(@thisobj) eq 2 @do
      @pmsg(found_diamond)
      @toroom(@thisroom,diamond)
      @cont
   @endif
   @if @count(@thisobj) gt 2 @do
      @pmsg(nothing_else_here)
      @cont
   @endif
@endif

@msg 	found_diamond
@msgtxt Oh look, there is something here after all, you have just found a 
        tiny diamond.
@endmsg

@msg	Nothing_else_here
@msgtxt No, there isn't anything else.
@endmsg

@rem *************************************************************************

@rem What about the window that Molly is cleaning? Let's create it now,
     but it will be hidden. The window is actually a doorway between the  
     kitchen and garden, where the player will find a golden gnome!

@obj 		windows
@objsyn		window
@objhide
@objngt
@objdoor	kitchen,garden
@objlck		closed
@endobj

@room		garden
@roomsht	Garden.
@roomlng	You are in a beautiful, and well tended garden.
@roompth	leave,carried
@endroom

@obj		gnome
@objsht		a golden gnome
@objroom	garden
@objpnt		30
@objwgt		20
@endobj

@rem Some atmosphere here I think!

@high
@if @isopen(windows) and @roomis(kitchen) @do @pmsg(draught) @endif

@msg 	draught 
@msgtxt A gentle draught blows in through the window.
@endmsg

@rem Good old Molly might shut the window.

@if @isopen(windows) and @random(3) eq 1 @do
   @close(windows)
   @if @ishere(windows) @do
      @pmsg(molly_closes_window)
   @endif
@endif

@msg 	Molly_closes_window
@msgtxt Molly tuts and closes the window.
@endmsg

@rem *************************************************************************

@rem Another nail in the coffin.... Once Bob has the iron key.... he might
     give it to Harry - and then the player can never get it back!!!!!!!

     You can see we have built inter-relationships between the characters
     in this adventure. They can happily go about their business without 
     the player knowing anything. The possibilities are endless!

     The scenario now is... Bob goes to see Molly to get the key, he then
                            goes and gives the key to Harry!

@high 
@if @iswith(bob,harry) and @iscarriedby(iron_key,bob) and @random(2) @do
   @toroom(@objinrm(harry),iron_key)
   @if @ishere(bob) and (not @isdark) @do
      @pmsg(bob_gives_key_to_harry)
   @endif
@endif

@msg 	Bob_gives_key_to_harry
@msgtxt	Bob gives something to harry.
@endmsg

@rem *************************************************************************

@rem One more trick, we'll give the lampp a limited lifespan.
     It can be alight for 30 turns. 
     
     @high 
     @if @islit(lamp) @do
        @addcount(200,1)
        @if @count(200) eq 30 @do
           @unlight(lamp)
           @if @isavail(lamp) @do
              @pmsg(lamp_goes_out)
           @endif
        @endif
     @endif

     @low
     @if @verbnois(light) and @nounnois(lamp) and @count(200) eq 30 @do
        @pmsg(no_fuel)
        @cont
     @endif

     @msg	lamp_goes_out
     @msgtxt    Phut! The lamp goes out!
     @endmsg

     @msg  	No_fuel
     @msgtxt    Sorry, there is no fuel left!
     @endmsg

@rem *************************************************************************
@rem ****************           End of Tutorial #5           *****************
@rem *************************************************************************

@rem Okay, we have covered a lot of ground - but we haven't covered all of 
     the features of CAT. I hope that by now, you have enough of an overview
     of CAT to experiment with your own adventures. Remember that there is 
     a cross reference manual in CATMAN.TXT, and that the program CATHELP
     is a very useful method of quickly scanning the manual by keyword.

     It might be a good idea to generate this tutorial now so that you
     get an idea of the processing involved.


     Cheerio, and thanks for attending!

	Tony



