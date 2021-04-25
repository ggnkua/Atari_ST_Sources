@rem ZZSTD.D - last change 30/06/91

@rem	This file contains the de-facto definition to provide a 'standard'
	system with the vast majority of every-day adventure processing done
	automatically. This file can be happily linked with your own definition
 	You should ensure that your logic is generated before this standard
        definition, thereby allowing this file to act as a 'trap all'.
        
        For example, your genlist file might contain:
        
        myfile1.d
        myfile2.d
        \cat\std\zzstd.d
        \cat\std\zzrqd.d

The existing logic in this file should look after itself nicely, but you are
completely free to modify it to your exact requirements. You may want to add
new processing that will be consistent across your range of adventures, or
you may like to personalise some of the messages. Alternatively, you may 
just like to use this file as a reference of some of the techniques available.

If you do change this file, make sure you take a copy, and clearly mark any
changes in your file from the original version. This will help you to reapply
your additions when I release an updated version of this file. I would suggest
that if possible, you create your own 'standard' file that complements this
one - you will then be ensured of minimum confusion when loading a new release.

@REM ***** YOU SHOULD NOT USE COUNTERS 451-499. THESE ARE RESERVED FOR THE 
@REM ***** SHIPPED STANDARD FILES. IF THEY ARE NOT USED YET, THEY MAY WELL 
@REM ***** BE USED IN THE FUTURE. 

@REM Counter 496 - score room
     Counter 497 - score not derived from objpnts.

@REM Counter 494 - temporary use
             495
             498 
             499 

@rem **************************************************************************
@rem * First, the advert: I would ask you to leave this unchanged!            *
@rem * ... advert is placed in room one  - referenced by number, not name!    *
@rem * ... I don't know what the rooms will be called in your adventure.      *
@rem **************************************************************************

@obj    advert
@objsyn	ad advertisement
@objsht an advert
@objlng It has something written on it.
@endobj

@rem move advert to room 1 at start of game.

@init @do @toroom(1,advert)

@rem I haven't used OBJREAD for the advert, because that would effectively 
     limit my message length to 255 characters. Instead, I'll handle
     READ ADVERT specifically, and print lots of short messages.

@low
@if @verbnois(read) and @nounnois(advert) @do
   @pmsg(advert_read_1)
   @pmsg(advert_read_2)
   @pmsg(advert_read_3)
   @pmsg(advert_read_4)
   @pmsg(advert_read_5)
   @pmsg(ekeys_1)
   @pmsg(ekeys_2)
   @pmsg(ekeys_3)
   @pmsg(ekeys_4)
   @pmsg(ekeys_5)
   @pmsg(advert_read_6)
   @pmsg(advert_read_7)
   @pmsg(advert_read_8)
   @pmsg(advert_read_9)
   @pmsg(advert_read_10)
   @pmsg(advert_read_11)
   @pmsg(advert_read_12)
   @pmsg(advert_read_13)
   @pmsg(advert_read_14)
   @pmsg(advert_read_15)
   @cont
@endif

@msg    advert_read_1
@msgtxt This adventure was created using the C Adventure Toolkit. All 
	adventures created with the Toolkit allow compound commands such
	as PUT THE KEY IN THE BOX. ALL can be used fully, i.e. GET ALL,
@endmsg
@msg	Advert_read_2
@msgtxt	WEAR ALL, EXAMINE ALL etc. You can refer to the previous 'group'
	of objects with THEM i.e. GET THE HAT AND THE GLOVES, THEN WEAR THEM.
	THEM is in fact a synonym for IT, and can be used equally for single
@endmsg
@msg	Advert_read_3
@msgtxt	objects, i.e. GET THE APPLE THEN EAT IT. 
	You can control any number of player characters i.e. BECOME PLAYER1, 
	BECOME PLAYER2, or you can issue commands to another player character
@endmsg
@msg	Advert_read_4
@msgtxt	that is present in the same room i.e. DICK, GET EVERYTHING. Script
	mode is supported via the commands SCRIPT and UNSCRIPT. Qualified
	objects are fully supported, i.e. GET THE GREEN KEY, DROP THE RED
@endmsg
@msg	Advert_read_5
@msgtxt	KEY. The game can be saved and restored via the commands SAVE and
	RESTORE. The command VOCAB lists all available verbs. The command 
        EXITS shows all obvious exits from the current room. Games can
        be saved and loaded from memory with RAMSAVE and RAMLOAD.
@endmsg
@msg	Advert_read_6
@msgtxt LF LF Adventures created with the Toolkit will run in any
	resolution on the Atari-ST.. WITHOUT scrolling half the text off
	the screen before you get a chance to read it!!
@endmsg
@msg	Advert_read_7
@msgtxt LF LF About the Author: Tony Stiles is a 24 year old graduate in
        nothing. He currently works as a programmer for a Life Assurance
        company. His previous work includes lots of life assurance programs; 
@endmsg
@msg	Advert_read_8
@msgtxt	none of which are standard on any 8 bit micros. He is single, he
	is not married (one does not necessarily go with the other), he has
	no children and does not live in Reading. His current boss has a degree 
@endmsg
@msg	Advert_read_9
@msgtxt in Archaeology, but that is beside the point! LF LF The CAT was 
	conceived to end my frustration that there wasn't one single Adventure
	creator on the market that did what I wanted. LF LF
@endmsg
@msg	Advert_read_10
@msgtxt	I believe the CAT system is the most powerful system available to date.
        It allows unlimited objects, player objects, rooms etc. All references
        are made by NAME, not number. CAT produces machine independant C source
@endmsg
@msg	Advert_read_11
@msgtxt code, which can then be compiled with your favourite compiler, it is 
	therefore only suitable for people with at least a working knowledge of
	the C language. Because of it's strong links with C, the system itself
@endmsg
@msg	Advert_read_12
@msgtxt	is extremely expandable, and full control is placed in the designers 
	hands. LF LF When designing CAT, my main aim was to produce a system 
	that performed all the dirty work automatically, thereby enabling the
@endmsg
@msg	Advert_read_13
@msgtxt	designer to produce stable and bug free adventures with minimum effort,
	whilst still providing full control to the designer where he needed it.
	The CAT system will work on an ST with 1/2M memory, but 1M is strongly
@endmsg
@msg	Advert_read_14
@msgtxt recommended. A double sided disk drive is essential. LF LF
	The CAT system is a Shareware product, and is available from Tony Stiles
	or your local P.D. distributor. The registration fee of 12 UK pounds
@endmsg
@msg	Advert_read_15
@msgtxt	will entitle you to support, and updates when available. LF LF
	Tony Stiles can be contacted at: LF LF 103a Ludlow Road, LF
        Itchen, LF SOUTHAMPTON, LF Hants, LF SO2 7ER, LF United Kingdom. LF
@endmsg

@msg 	ekeys_1
@msgtxt LF LF 
	You can use the following keys on the command line: LF LF
        Ctrl-A - Last Verb LF 
        Ctrl-B - Last Noun LF
        Ctrl-C - Last compound verb LF
        Ctrl-D - Last compound noun LF
        Ctrl-E - Examine LF
        Ctrl-F - Drop LF 
        Ctrl-G - Get LF
@endmsg
@msg	ekeys_2
@msgtxt	Ctrl-I - Inventory LF
        Ctrl-J - Jump LF
        Ctrl-K - Kill LF
        Ctrl-L - Look LF
        Ctrl-N - No LF
        Ctrl-O - Open LF
        Ctrl-P - Close LF
        Ctrl-Q - Quit LF
        Ctrl-R - Restore LF
@endmsg
@msg	ekeys_3
@msgtxt	Ctrl-S - Save LF
        Ctrl-T - Lock LF
        Ctrl-U - Unlock LF 
        Ctrl-V - Vocabulary LF 
        Ctrl-W - Whoami LF 
        Ctrl-X - Exits LF 
        Ctrl-Y - Yes LF
        Ctrl-Z - Copyright line LF
@endmsg
@msg	ekeys_4
@msgtxt	LF LF
	     [ - Repeat last command line LF 
             ] - Delete entire command line LF
             * - Delete one word from command line LF LF
@endmsg
@msg	ekeys_5
@msgtxt	8 - North LF
	9 - Northeast LF
	6 - East LF
        3 - SouthEast LF
	2 - South LF
	1 - SouthWest LF
        4 - West LF
        7 - NorthWest LF
        5 - Up LF
        0 - Down LF
@endmsg

@rem **************************************************************************
@rem * Keep a dynamic tag on the current score                                *
@rem **************************************************************************

@rem uses counters: 496, 497, 498, 499. Assumes that the score not obtained from
     object-points is stored in counter 497. The points room is stored in 
     counter 496 - the default for this is the in-room of the first player.

@high
@do
   @if @count(496) eq -1 @do @setcount(496,@objinrm(@cplayer)) @endif
   @setscore(@count(497))
   @setcount(498,@firstob(@count(496)))
   @setcount(499,@lastob(@count(496)))
   @while @count(498) ne -1 and @count(498) le @count(499) @do
      @if @objrm(@count(498)) eq @count(496) @do
         @addscore(@points(@count(498)))
      @endif
      @do @addcount(498,1)
   @wend
@enddo

@rem **************************************************************************
@rem * If carrying too much - drop successively until light enough!           *
@rem **************************************************************************

@high
@do @setcount(499,@carried_weight(@player))
@if @count(499) gt @strength(@player) @do
   @pmsg(You_stumble)
   @lf 
   @setcount(498,@firstob(@objinrm(@player)))
   @while @count(499) gt @strength(@player) and @count(498) ne -1
          and @count(498) le @lastob(@objinrm(@player)) @do
      @if @ismovable(@count(498)) 
        and (not @ishidden(@count(498))) 
        and @iscarried(@count(498))
        and (not @isworn(@count(498))) @do
          @drop(@count(498))
          @endchar(':')
          @pobjs(@count(498))
          @pmsg(dropped)
          @subcount(499,@weight(@count(498)))
      @endif
      @do @addcount(498,1)
   @wend
@endif

@rem **************************************************************************
@rem * Here are some standard verbs                                           *
@rem **************************************************************************

@verb verbose @verbsyn verbose_on long @endverb
@verb brief @verbsyn verbose_off short @endverb
@verb script @verbsyn script_on @endverb
@verb unscript @verbsyn script_off @endverb
@verb quit @verbsyn end_game endgame die @endverb
@verb inventory @verblgt @verbsyn invent i list @endverb
@verb look @verblgt @verbsyn l describe @endverb
@verb exits @verblgt @verbsyn x path exit paths @endverb
@verb get @verblgt @verbsyn take grab @verbchk not_carried @endverb
@verb give @verblgt @verbsyn pass hand @verbchk carried_not_worn @endverb
@verb drop @verbsyn put @verbchk carried_not_worn @endverb
@verb wear @verblgt @verbsyn put_on @verbchk carried_not_worn @endverb
@verb remove @verbsyn take_off @verbchk worn @endverb
@verb examine @verblgt @verbsyn look_at ex exam @verbchk avail_not_worn @endverb
@verb load @verbsyn restore @endverb
@verb save @verbsyn backup @endverb
@verb ramload @verbsyn rl @endverb
@verb ramsave @verbsyn rs @endverb
@verb become @verbsyn @verbchk exist @endverb
@verb whoami @verbsyn who @endverb
@verb open @verbsyn open_up @verblgt @verbchk avail_not_worn @endverb
@verb close @verblgt @verbchk avail_not_worn @endverb
@verb lock @verblgt @verbchk avail_not_worn @endverb
@verb unlock @verblgt @verbchk avail_not_worn @endverb
@verb light @verbchk avail_not_worn @verbsyn switch_on @endverb
@verb unlight @verbsyn extinguish off switch_off put_out 
      @verbchk avail_not_worn @endverb
@verb eat @verblgt @verbsyn consume swallow @verbchk avail_not_worn @endverb
@verb drink @verblgt @verbchk avail_not_worn @endverb
@verb read @verblgt @verbchk avail_not_worn @endverb
@verb hit @verblgt @verbsyn attack kill thump @verbchk avail_not_worn @endverb
@verb vocab @verbsyn verbs vocabulary @endverb
@verb empty @verblgt @verbchk carried_not_worn @endverb
@verb help @endverb
@verb weigh @verblgt @verbchk avail_not_worn @endverb

@rem **************************************************************************
@rem * Here are some standard prepositions                                    *
@rem **************************************************************************

@verb in @verbprep @verbsyn into inside through @verbchk avail_not_worn @endverb
@verb to @verbprep @verbchk avail_not_worn @endverb
@verb with @verbprep @verbsyn using @verbchk carried_not_worn @endverb
@verb on @verbprep @verbsyn onto @verblgt @verbchk avail_not_worn @endverb

@rem **************************************************************************
@rem * All the low priority stuff follows                                     *
@rem **************************************************************************
@low

@rem **************************************************************************
@rem * Inventory - simple stuff!
@rem **************************************************************************

@if @verbnois(inventory) @do
   @inventory
   @cont
@endif

@rem **************************************************************************
@rem * Look
@rem **************************************************************************

@rem LOOK IN object. The compound object must be a box (i.e. have an
     in-room). It shouldn't be locked or closed. Note: ISBOX will return 
     false if the object is active... You shouldn't be able to look in a person!
 
@if @verbnois(look) and @iscompound @do
   @if ((not @cverbnois(in)) and (not @cverbnois(on))) or 
                             (not @isbox(@thiscobj)) @do
      @pmsg(cant_do_that)
   @else
      @if @isclosed(@thiscobj) @do
         @pmsg(it_is_closed)
      @else
         @if @islocked(@thiscobj) @do
            @pmsg(it_is_locked)
         @else @do
            @pcontents(@thiscobj)
         @endif
      @endif
   @endif
   @do @cont
@endif

@rem LOOK, or LOOK object. If we have an object, (@THISOBJ NE -1), then the
     verb is forced to EXAMINE, we perform verb checking to make sure the 
     object is available and not worn, then fall through to EXAMINE logic.

     If we don't have an object, this is a simple LOOK.
 
@if @verbnois(look)
   @if @thisobj ne -1 @do
      @fverb("examine")
      @if not @check(avail_not_worn,@need_light,@thisobj) @do
         @cont
      @endif
   @else @do 
      @look
      @cont
   @endif
@endif

@rem **************************************************************************
@rem * Exits - nothing to it.
@rem **************************************************************************

@if @verbnois(exits) @do
   @pexits
   @cont
@endif

@rem **************************************************************************
@rem * Examine.
@rem **************************************************************************

@rem If the object has a long description, show it.
@rem If the object is locked, say so.
@rem If the object is closed, say so.
@rem If the object is alight, say so.
@rem If the object is a box, print contents. 
@rem If none of the above are true, say 'Nothing unusual'

@if @verbnois(examine) @do
   @setcount(498,0)
   @if @objhasl(@thisobj) @do @pobjl(@thisobj) @setcount(498,1) @endif
   @if @islocked(@thisobj) @do @pmsg(it_is_locked) @setcount(498,1) @endif
   @if @isclosed(@thisobj) @do @pmsg(it_is_closed) @setcount(498,1) @endif
   @if @islit(@thisobj) @do @pmsg(it_is_alight) @setcount(498,1) @endif
   @if @isbox(@thisobj) and (not @islocked(@thisobj))
                        and (not @isclosed(@thisobj)) @do
      @pcontents(@thisobj)
      @setcount(498,1)
   @endif
   @if @count(498) eq 0 @do @pmsg(nothing_unusual) @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Get
@rem **************************************************************************

@rem It would be nice if we could use a HERE verbchk for GET, but we can't!
     This is because we need to allow for GET object FROM object. This would
     return the message 'You don't see that here'. Instead, I've done the
     next best thing and used NOT_CARRIED as a verbchk. 
      
     Because I can't use HERE, I have to actually make sure that the object
     is here, before I allow the player to take it. 

@rem First we'll validate the request...

     If compound GET x FROM y, we need to make sure that x is a box, and
     that y is actually in x. We also need to make sure that x isn't 
     locked or closed. Remember, the ISBOX will return false, if x is a 
     player - you shouldn't be able to take an object from a player... 
     you should ask him nicely to give it to you!

     If simple GET x, we just need to make sure the object is here.
 
@if @verbnois(get)
   @if @iscompound
      @if not @cverbnois(from) @do @pmsg(cant_do_that) @cont @endif
      @if not @isbox(@thiscobj) @do @pmsg(cant_do_that) @cont @endif
      @if @islocked(@thiscobj) @do @pmsg(it_is_locked) @cont @endif
      @if @isclosed(@thiscobj) @do @pmsg(it_is_closed) @cont @endif
      @if @objrm(@thisobj) ne @objinrm(@thiscobj) @do
         @pmsg(not_in_there) @cont @endif
   @else
      @if not @ishere(@thisobj) @do @pmsg(object_not_here) @cont @endif
   @endif
@endif

@rem Now, we need to make sure that the object is movable. Again, we need to
     consider both the compound GET x from y, and the simple GET x.

     We also need to make sure that the player has enough strength to carry
     the weight of this object. The exception to this is when the player is 
     taking y from x, and he is already carrying x - this means he is also 
     already indirectly carrying y, so he can definately manage the weight!!

@if @verbnois(get) @do
   @if @ismovable(@thisobj) @do
      @if @strength(@player) lt @weight(@thisobj) + @carried_weight(@player)
         @if @iscompound and @iscarried(@thiscobj) @do
            @get(@thisobj)
            @pmsg(taken)
         @else @do
            @pmsg(too_heavy)
         @endif
      @else @do
         @get(@thisobj)
         @pmsg(taken)
      @endif
   @else @do
      @pmsg(cant_move)
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Give
@rem **************************************************************************

@rem Give x to y. We need to make sure that y is active. You shouldn't be able
     to give things to inanimate objects. We also need to ensure that 
     we can actually move x, and that x is NOT active. It is not generally
     considered normal to give your arms to someone else, and it certainly
     isn't polite to pass people around like parcels!

     One last check; is y able to manage the extra weight of x? 

@if @verbnois(give)
   @if (not @iscompound) or (not @isactive(@thiscobj))
                         or @isactive(@thisobj) or (not @cverbnois(to))
                         or (not @ismovable(@thisobj))
   @do
      @pmsg(cant_do_that)
   @else
      @if @strength(@thiscobj) lt @weight(@thisobj)
      						+ @carried_weight(@thiscobj) @do
         @pmsg(they_cannot_manage_that)
      @else @do
         @toroom(@objinrm(@thiscobj),@thisobj)
         @pmsg(okay)
      @endif
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Drop x / Put x in y
@rem **************************************************************************

@rem Compound PUT x IN/ON y - a bit complicated!
       Make sure x can be moved.
       Make sure y is a box, that is not closed nor locked, and there is room!
       Make sure that x is not equal to y - could be fatal!
       If x is active, make sure he should have been able to enter y -
                       i.e. make sure y is actually an exit (door/portal)!

@if @verbnois(drop) and @iscompound @do
   @if (not @isbox(@thiscobj))
            or ((not @cverbnois(in)) and (not @cverbnois(on))) 
            or (not @ismovable(@thisobj)) @do
      @pmsg(cant_do_that)
   @else
      @if @isclosed(@thiscobj) @do
         @pmsg(it_is_closed)
      @else
         @if @islocked(@thiscobj) @do
            @pmsg(it_is_locked)
         @else 
            @if @isactive(@thisobj) and (not @isexit(@thiscobj)) @do
               @pmsg(programmer_wont_let)
            @else @do
               @setcount(494,0)
               @setcount(495,@firstob(@objinrm(@thiscobj)))
               @setcount(498,@lastob(@objinrm(@thiscobj)))
               @while @count(495) ne -1 and @count(495) le @count(498) @do
                  @if @objrm(@count(495)) eq @objinrm(@thiscobj) and @ismovable(@count(495)) @do
                     @addcount(494,@size(@count(495)))
                  @endif
                  @do @addcount(495,1)
               @wend
               @if @count(494) + @size(@thisobj) > @strength(@thiscobj) @do
                  @pmsg(no_space)
               @else
                  @if @thisobj eq @thiscobj @do
                     @pmsg(programmer_wont_let)
                  @else @do
                     @toroom(@objinrm(@thiscobj),@thisobj)
                     @pmsg(okay)
                  @endif
               @endif
            @endif
         @endif
      @endif
   @endif
   @do @cont
@endif

@rem Simple DROP x.
        Make sure that x is movable. 

@if @verbnois(drop)
   @if (not @ismovable(@thisobj)) @do @pmsg(cant_do_that) @cont @endif
   @do 
      @drop(@thisobj)
      @pmsg(dropped)
      @cont
   @enddo
@endif

@rem **************************************************************************
@rem * Wear
@rem **************************************************************************

@rem Make sure the object can be worn.

@if @verbnois(wear) @do
   @if @iswearable(@thisobj) @do
      @wear(@thisobj)
      @pmsg(okay)
   @else @do
      @pmsg(cant_wear_that)
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Remove
@rem **************************************************************************

@rem We know from verb checking that the object is worn, so remove it!

@if @verbnois(remove) @do
   @remove(@thisobj)
   @pmsg(okay)
   @cont
@endif

@rem **************************************************************************
@rem * Enter
@rem **************************************************************************

@rem ENTER x
        Make sure x isn't locked.
        Make sure x isn't closed.
        Make sure x is an exit (door/portal).
        If x has an in-room, make sure there is room for player in in-room.

@if @verbnois(enter) @do
   @if @islocked(@thisobj) @do
      @pmsg(it_is_locked)
   @else
      @if @isclosed(@thisobj) @do
         @pmsg(it_is_closed)
      @else
         @if not @isexit(@thisobj) @do
            @pmsg(cant_do_that)
         @else
            @if @objinrm(@thisobj) ne @roomno(nowhere) @do
               @setcount(494,0)
               @setcount(495,@firstob(@objinrm(@thisobj)))
               @setcount(498,@lastob(@objinrm(@thisobj)))
               @while @count(495) ne -1 and @count(495) le @count(498) @do
                  @if @objrm(@count(495)) eq @objinrm(@thisobj) and @ismovable(@count(495)) @do
                     @addcount(494,@size(@count(495)))
                  @endif
                  @do @addcount(495,1)
               @wend
               @if (@count(494) + @size(@player) > @strength(@thisobj)) and
                   @ismovable(@player) @do
                  @pmsg(no_room_for_you)
                  @cont
               @endif
            @endif
            @enter(@thisobj)
            @look
         @endif
      @endif
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Become
@rem **************************************************************************

@rem BECOME x
      If current player is already x, say so. 
      If x is not a player, say so.
      ....otherwise, 'transmute' and look.

@if @verbnois(become) @do
   @if @playeris(@thisobj) @do
      @whoami
   @else
      @if not @isplayer(@thisobj) @do
         @pmsg(cant_become)
      @else @do
         @become(@thisobj)
         @whoami
         @look
      @endif
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Whoami
@rem **************************************************************************

@if @verbnois(whoami) @do
   @whoami
   @cont
@endif

@rem **************************************************************************
@rem * Eat
@rem **************************************************************************

@rem EAT x
     Make sure x is edible.
      If x is movable, it is zapped to r_nowhere.

@if @verbnois(eat) @do
   @if not @isedible(@thisobj) @do
      @pmsg(not_edible)
   @else @do
      @eat(@thisobj)
      @if @ismovable(@thisobj) @do
         @toroom(nowhere,@thisobj)
      @endif
      @pmsg(object_eaten)
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Drink
@rem **************************************************************************

@rem EAT x
     Make sure x is drinkable.
      If x is movable, it is zapped to nowhere.

@if @verbnois(drink) @do
   @if not @isdrinkable(@thisobj) @do
      @pmsg(not_drinkable)
   @else @do
      @drink(@thisobj)
      @if @ismovable(@thisobj) @do
         @toroom(nowhere,@thisobj)
      @endif
      @pmsg(object_drunk)
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Read
@rem **************************************************************************

@rem READ x
     If x is readable, print attached message.

@if @verbnois(read) @do
   @if not @isreadable(@thisobj) @do
      @pmsg(nothing_to_read)
   @else @do
      @read(@thisobj)
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Light
@rem **************************************************************************

@rem LIGHT x
     If x is already alight, say so.
     If x cannot be lit, say so.
     ... otherwise light it.

@if @verbnois(light) @do
   @if @islit(@thisobj) @do
      @pmsg(it_is_alight)
   @else
      @if not @islight(@thisobj) @do
         @pmsg(cant_do_that)
      @else @do
         @light(@thisobj)
         @pmsg(okay)
      @endif
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Unlight
@rem **************************************************************************

@rem UNLIGHT x
     If x is not alight, say so.
     ... otherwise light it.

@if @verbnois(unlight) @do
   @if not @islit(@thisobj) @do
      @pmsg(not_lit)
   @else @do
      @unlight(@thisobj)
      @pmsg(okay)
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Lock/unlock/open/close
@rem **************************************************************************

@rem If we're trying to open/close/unlock/lock and object with no lock, say so!

@if (@verbnois(lock) or @verbnois(unlock) or
     @verbnois(open) or @verbnois(close)) and @locktype(@thisobj) eq no_lock @do
   @pmsg(cant_do_that)
   @cont
@endif

@rem If we're trying to lock/unlock an object that has no key, complain.
     If we haven't specified a key, say What with?
     If the key doesn't fit the lock, say so!
     ... otherwise, fall through and continue

@if @verbnois(lock) or @verbnois(unlock) @do
   @if @objkey(@thisobj) eq no_key @do
      @pmsg(cant_do_that)
      @cont
   @else
      @if (not @iscompound) or (not @cverbnois(with)) @do
         @pmsg(what_with)
         @cont
      @else
         @if @thiscobj ne @objkey(@thisobj) @do
            @pmsg(it_doesnt_work)
            @cont
         @endif
      @endif
   @endif
@endif

@rem If we're trying to unlock an object that isn't locked, say so
     ...otherwise unlock it.

@if @verbnois(unlock) @do
   @if not @islocked(@thisobj) @do
      @pmsg(it_is_not_locked)
   @else @do
      @unlock(@thisobj)
      @pmsg(okay)
   @endif
   @do @cont
@endif

@rem If we're trying to lock an object that's already locked, say so
     ...otherwise unlock it.

@if @verbnois(lock) @do
   @if @islocked(@thisobj) @do
      @pmsg(it_is_locked)
   @else @do
      @lock(@thisobj)
      @pmsg(okay)
   @endif
   @do @cont
@endif

@rem If we're trying to open a locked object, say so.
     If we're trying to open an object that is already open, say so
     ...otherwise open it.

@if @verbnois(open) @do
   @if @islocked(@thisobj) @do
      @pmsg(it_is_locked)
   @else
      @if @isopen(@thisobj) @do
         @pmsg(it_is_open)
      @else @do
         @open(@thisobj)
         @pmsg(okay)
      @endif
   @endif
   @do @cont
@endif

@rem If we're trying to close an object that is locked, say so.
     If we're trying to close an object that is already closed, say so.
     ...otherwise, close it.

@if @verbnois(close) @do
   @if @islocked(@thisobj) @do
      @pmsg(it_is_locked)
   @else
      @if @isclosed(@thisobj) @do
         @pmsg(it_is_closed)
      @else @do
         @close(@thisobj)
         @pmsg(okay)
      @endif
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Empty
@rem **************************************************************************

@rem EMPTY x
     Make sure that x is a box, it is not closed, and it is not locked.
     If okay, move all items from inside x, to its' current room.

@if @verbnois(empty) @do
   @if (not @isbox(@thisobj)) @do
      @pmsg(cant_do_that)
   @else
      @if @islocked(@thisobj) @do @pmsg(it_is_locked) @cont @endif
      @if @isclosed(@thisobj) @do @pmsg(it_is_closed) @cont @endif
      @if @firstob(@objinrm(@thisobj)) eq -1 @do
         @pmsg(nothing_in_it)
      @else @do
         @pmsg(okay)
         @setcount(498,@firstob(@objinrm(@thisobj)))
         @setcount(499,@lastob(@objinrm(@thisobj)))
         @while @count(498) le @count(499) @do
            @if @objrm(@count(498)) eq @objinrm(@thisobj) @do
               @toroom(@objrm(@thisobj),@count(498))
            @endif
            @do @addcount(498,1)
         @wend
      @endif
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Hit
@rem **************************************************************************

@rem Make sure we have specified a weapon (HIT x WITH y).
     The default is a somewhat passive response! 

@if @verbnois(hit) @do
   @if (not @iscompound) or (not @cverbnois(with)) @do
      @pmsg(what_with)
   @else @do
      @pmsg(no_violence)
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Verbose
@rem **************************************************************************

@if @verbnois(verbose) @do
   @pmsg(confirm)
   @if @confirm @do
      @verbose @pmsg(verbose_on)
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Brief
@rem **************************************************************************

@if @verbnois(brief) @do
   @pmsg(confirm)
   @if @confirm @do
      @brief @pmsg(verbose_off)
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Script
@rem **************************************************************************

@if @verbnois(script) @do
   @pmsg(confirm)
   @if @confirm @do
      @script @pmsg(script_on)
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Unscript
@rem **************************************************************************

@if @verbnois(unscript) @do
   @pmsg(confirm)
   @if @confirm @do
      @unscript @pmsg(script_off)
   @endif
   @cont
@endif

@rem **************************************************************************
@rem * Quit
@rem **************************************************************************

@if @verbnois(quit) @do
   @pmsg(confirm)
   @if @confirm @do
      @endgame
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Load
@rem **************************************************************************

@if @verbnois(load) @do
   @pmsg(confirm)
   @if @confirm @do
      @load
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * RamLoad
@rem **************************************************************************

@if @verbnois(Ramload) @do
   @pmsg(confirm)
   @if @confirm @do
      @Ramload
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Save
@rem **************************************************************************

@if @verbnois(save) @do
   @pmsg(confirm)
   @if @confirm @do
      @save
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * RamSave
@rem **************************************************************************

@if @verbnois(Ramsave) @do
   @pmsg(confirm)
   @if @confirm @do
      @Ramsave
   @endif
   @do @cont
@endif

@rem **************************************************************************
@rem * Vocabulary
@rem **************************************************************************

@if @verbnois(vocab) @do
   @pmsg(verbs_accepted)
   @vocab
   @cont
@endif

@rem **************************************************************************
@rem * Help - default is not much help!
@rem **************************************************************************

@if @verbnois(help) @do
   @pmsg(no_help)
   @cont
@endif

@rem **************************************************************************
@rem * Weigh an object
@rem **************************************************************************

@if @verbnois(weigh) @do
   @if not @ismovable(@thisobj) @do
      @pmsg(cant_do_that)
   @else @do
      @pmsg(object_weighs)
      @endchar('.')
      @pval(@weight(@thisobj))
   @endif
   @cont
@endif

@rem **************************************************************************
@rem * If nothing else found, do we have a valid path?
@rem **************************************************************************

@if not @ispath(@thisverb) @do
   @pmsg(cant_do_that)
   @cont
@endif

@rem **************************************************************************
@rem * All the messages used by this file follow:                             *
@rem **************************************************************************

@msg 	Object_weighs
@msgtxt Oooh, I would guess at about
@endmsg

@msg	You_stumble
@msgtxt	You stumble and fall.
@endmsg

@msg    Nothing_in_it
@msgtxt There's nothing in it.
@endmsg

@msg 	No_help
@msgtxt Sorry, you're on your own here.
@endmsg

@msg	They_cannot_manage_that
@msgtxt	Sorry, they cannot manage the extra weight.
@endmsg

@msg	No_room_for_you
@msgtxt There is no room for you in there!
@endmsg

@msg    Programmer_wont_let
@msgtxt Sorry, the programmer won't allow that!
@endmsg

@msg	Not_in_there
@msgtxt You can't see that in there.
@endmsg

@msg	No_space
@msgtxt There is no room for that.
@endmsg

@msg	Verbs_accepted
@msgtxt The following verbs are accepted:
@endmsg

@msg	What_with
@msgtxt What with?
@endmsg

@msg	It_doesnt_work
@msgtxt	...doesn't work.
@endmsg

@msg	It_is_not_locked
@msgtxt	That isn't locked.
@endmsg

@msg	Not_lit
@msgtxt	That isn't alight.
@endmsg

@msg	Cant_become
@msgtxt	At this moment, you cannot directly control that.
@endmsg

@msg	Not_edible
@msgtxt	You can't eat that.
@endmsg

@msg	Object_eaten
@msgtxt	Chomp. chomp. chomp.
@endmsg

@msg	Not_drinkable
@msgtxt	It is quite impossible to drink that.
@endmsg

@msg	Object_drunk
@msgtxt	Slurp. slurp. slurp.
@endmsg

@msg	Nothing_to_read
@msgtxt	You can't see anything to read.
@endmsg

@msg	Taken
@msgtxt	taken.
@endmsg

@msg	Dropped
@msgtxt	dropped.
@endmsg

@msg	Okay
@msgtxt	okay.
@endmsg

@msg	Cant_wear_that
@msgtxt	You can't wear that.
@endmsg

@msg	Too_heavy
@msgtxt	You can't manage that with your current load.
@endmsg

@msg	Cant_move
@msgtxt	You can't move that.
@endmsg

@msg	Cant_do_that
@msgtxt	You can't do that.
@endmsg

@msg    Verbose_on
@msgtxt Verbose mode has been enabled.
@endmsg

@msg    Verbose_off
@msgtxt Verbose mode has been disabled.
@endmsg

@msg    Script_on
@msgtxt Script mode has been enabled.
@endmsg

@msg    Script_off
@msgtxt Script mode has been disabled.
@endmsg

@msg	No_violence
@msgtxt	I don't think violence will solve anything here!
@endmsg

@msg	Confirm
@msgtxt	Are you sure?
@endmsg

