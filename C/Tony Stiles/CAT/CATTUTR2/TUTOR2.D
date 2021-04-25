@rem C Adventure Toolkit (CAT) - Tutorial #2

@rem This file introduces messages, further objects, and qualified objects.

@rem **************************************************************************

@rem Now is a good time to introduce 'messages'. A message is just a piece of
     text that will appear somewhere in the adventure. A message just has a 
     name, and some text. Let's define an object that can be read (a leaflet),
     and the message that is written upon it.

@rem **************************************************************************

@msg 		leaflet_msg
@msgtxt 	There's a treasure in the blue box!
@endmsg

@obj 		leaflet
@objsht 	a leaflet
@objlng		It has something written on it.
@objroom	bedroom
@objread	leaflet_msg
@endobj

@rem **************************************************************************

@rem The MSG token tells CAT the name of the message that we are defining.

     The MSGTXT token tells CAT the text for the message.
     
     The ENDMSG token tells CAT that we have finished defining this message.
     
@rem The OBJREAD token tells CAT that the leaflet can be read, and when the 
     player reads it, the message called LEAFLET_MSG should be displayed.
     
@rem **************************************************************************

@rem An object can be wearable, or wearable AND worn. We are going to define 
     a coat that is being worn by Tony, and a pair of trousers that can be 
     worn - left in the hallway. 

@rem **************************************************************************

@obj		coat
@objsht		a coat
@objroom	in_tony
@objwgt		20
@objworn
@endobj

@obj		trousers
@objsyn		breeches jeans
@objsht		a pair of trousers
@objwgt		5
@objroom	hallway
@objwear
@endobj

@rem *************************************************************************

@rem Okay, now I'm going to introduce two qualified objects. i.e. a RED KEY
     and a BLUE KEY - where RED and BLUE are the qualifiers. You can have any
     number of objects with the same unqualified name, as long as their 
     qualifiers are unique, i.e. a red key, a blue key, a yellow key etc.
     Note however, that if you have a qualified object, you cannot have an
     unqualified object of the same name, i.e. you could not have a red key
     and a key.

     CAT will do the following if the player gives an unqualified name:
     
        If there is more than one object available with this unqualified name,
        then each of the objects will be listed and the player will be asked
        to be more specific.
        
        If there is only one object available with this unqualified name, then
        CAT will presume that this is the object the player is refering to.
        
        If there are no objects available with this unqualified name, but
        there are some in the adventure universe (i.e. in any room other than
        NOWHERE), then CAT will presume that the player is refering to the 
        first one of these it can find.

        If there are no objects in the adventure universe with this
        unqualified name, then CAT will presume that the player is refering to
        the first object of the same name that is in the NOWHERE room.
        
     Qualified objects are very easy to define, The underbar (_) separates 
     the qualifier, and the unqualified name.
     
@rem *************************************************************************

@obj		red_key
@objroom	hallway
@objsht		a red key 
@endobj

@obj		blue_key
@objroom	in_red_box
@objsht		a blue key
@endobj

@rem **************************************************************************

@rem Now, we'll define two boxes, again qualified objects. These boxes can 
     contain things, so they must have an in-room, and since they have an 
     in-room, they should also have strength. The BLUE BOX will be locked,
     and the BLUE KEY will fit the lock. The RED BOX will be closed, and the 
     RED KEY will fit its lock.
     
@rem **************************************************************************

@obj		blue_box
@objsht		a blue box
@objlck		locked
@objkey		blue_key
@objinrm	in_blue_box
@objwgt		10
@objstr		8
@objroom	bedroom
@endobj

@room in_blue_box @endroom

@obj		red_box
@objsht		a red box
@objlck		closed
@objkey		red_key
@objwgt		20
@objinrm	in_red_box
@objstr		15
@objroom	in_tony
@endobj

@room in_red_box @endroom

@rem **************************************************************************

@rem I haven't bothered giving the rooms IN_RED_BOX, or IN_BLUE_BOX a long or 
     a short description. Because players can never enter these rooms, the
     text would never be displayed.
     
@rem The OBJLCK token tells CAT the lock state of this object. Valid values
     are OPEN, CLOSED, LOCKED. Players may not enter, place anything inside,
     or remove anything from an object that is either locked, or closed.
     
@rem The OBJKEY token tells CAT which object is required to lock/unlock 
     this object. If no OBJKEY is specified for an object, the player will not
     be able to lock/unlock the object. The OBJKEY token has no effect if
     an object doesn't have OBJLCK specified.
     
@rem **************************************************************************

@rem Now, we'll put a treasure in the blue box. The OBJPNT token tells CAT how 
     many points an object is worth to the player. The player will have 50
     points added to his score when he is carrying the coin.
     
@rem **************************************************************************

@obj		coin
@objsht		a gold coin
@objpnt		50
@objroom	in_blue_box
@endobj

@rem **************************************************************************

@rem Now, we're going to define a door that leads from the hallway to the 
     bathroom (a new room). CAT will automatically ensure that doors are
     where they should be, i.e. when the player is in the hallway, the door
     will be there - when the player is in the bathroom, the door will be 
     moved to the bathroom. This is important when there is more than one
     active object in an adventure - they could be on either side of the door!

@rem **************************************************************************

@obj 		door
@objsht		a door
@objdoor 	hallway,bathroom
@objlck		closed
@objkey		blue_key
@objngt
@endobj

@room		bathroom
@roomsht	Bathroom.
@roomlng	You are in a smelly bathroom, the toilet stinks to high heaven.
@roompnt	5
@endroom

@rem *************************************************************************

@rem The OBJDOOR token tells CAT that this object is a door between the 
     hallway and the bathroom. Note the ',' between the two rooms.
     
     The OBJLCK token tells CAT that this door is closed.
     
     The OBJKEY token tells CAT that the blue key will lock/unlock this door.

     The OBJNGT token tells CAT that this cannot be moved (No GeT). It also
     means that the object cannot be dropped, if it is already carried - 
     useful for things 'attached' to the players body, like arms!
          
     We do not need to tell CAT which room the door should be in. CAT will 
     move this around automatically for us, because the object is a door!
     
@rem The bathroom does not have any paths leading from it, the player has
     to use the door. The player receives 5 points on entering the bathroom.
     
@rem *************************************************************************

@rem Now I'll show you how to hide objects. If any object is hidden, it won't
     be shown on any inventory lists or room descriptions etc, BUT the player
     can still interact with it the same way as he can any other object. Hidden
     objects will not be picked up by commands using ALL - i.e. GET ALL!

     I'm going to create a toilet in the bathroom. I'm hiding it, because it is
     already mentioned in the room description of the bathroom. I'm also going
     to put some slime, and a necklace in the toilet. The slime cannot be 
     taken, but the necklace can. 'TAKE NECKLACE FROM TOILET'.

@rem Notice that I haven't given the toilet a short description. This will 
     never be displayed because the object is hidden. I have given it a long
     description, because it could be examined.

     The OBJHIDE token tells CAT that the toilet is hidden.

@rem *************************************************************************

@obj 		toilet
@objlng		This is a very smelly toilet indeed.
@objsyn		wc loo pan
@objroom	bathroom
@objhide
@objngt
@objinrm	in_toilet
@objstr		50
@endobj

@room in_toilet @endroom

@obj		slime
@objsht		some smelly slime
@objroom	in_toilet
@objngt
@endobj

@obj		necklace
@objsht		a necklace
@objwear
@objroom	in_toilet
@objwgt		2
@objpnt		10
@endobj

@rem **************************************************************************

@rem Here's an apple, that can be eaten. The OBJEAT token tells CAT that this
     object can be eaten, and how much the players strength should be affected
     (+/-) when he eats the object. The players strength will be increased 
     by 5 when he eats the apple.
     
@rem **************************************************************************

@obj		apple
@objsht		an apple
@objroom	hallway
@objeat		5
@endobj

@rem **************************************************************************

@rem Here's a puddle of water, that can be drunk. The OBJDRINK token tells CAT
     that this object can be drunk, and how much the players strength should
     be affected (+/-) when he drinks the object. The players strength will be
     decreased by 5 when he eats the apple.

     Because the puddle cannot be moved, it will not disappear when the player
     drinks from it. The same applies to edible objects that cannot be moved.
     
@rem **************************************************************************

@obj		puddle
@objsht		a puddle of dirty water
@objsyn		water
@objlng		It doesn't look too tasty.
@objroom	hallway
@objdrink	-5
@objngt
@endobj

@rem *************************************************************************

@rem Now, I'm going to introduce another concept that may appear confusing 
     at first - dummy qualifiers. It is possible to give an object a two
     character qualifier (aa->zz). Within CAT, you must always refer to the
     object with it's qualified name, but the player will never see the 
     qualifier. This allows several objects that 'seem' to have the same name.

     CAT will regard any two character qualifier as a 'dummy' qualifier.

     For example, you may want 'a door' to appear in different rooms.
     You may define one door as AA_DOOR, and the other as AB_DOOR.

     Dummy qualifiers will only work if each of the objects with a dummy
     qualifier can NEVER be in the same room as any other object with the
     same unqualified name. If two such objects did happen to be in 
     the same room, the player would not be able to qualify them, but CAT
     would insist that the player was more specific! Uno problema!
     OBJNGT is a good way of ensuring this rule is met. 

     Dummy qualifiers can be used to get around one of the problems I mentioned
     earlier. Using dummy qualifiers, you COULD have a RED DOOR and a DOOR, as
     long as they are in different rooms. The RED door would be defined as 
     RED_DOOR, and the DOOR would be defined as AA_DOOR, XY_DOOR, BQ_DOOR etc.

@rem *************************************************************************

@rem I'm going two define two objects with dummy qualifiers... AA_BEDROOM and
     AA_HALLWAY. These objects will be placed in the BEDROOM and the HALLWAY 
     respectively, and will allow the player to 'EXAMINE THE BEDROOM' when he
     is in the bedroom, or 'EXAMINE THE HALLWAY' when he is the the hallway.

     You will see why I have qualified them in a minute. Notice that both
     objects are hidden, and cannot be moved.

@rem *************************************************************************

@obj		aa_bedroom
@objngt	
@objhide
@objroom	bedroom
@objlng		This is just an average bedroom.
@endobj

@obj		aa_hallway
@objsyn		aa_hall
@objngt	
@objhide
@objroom	hallway
@objlng		This hallway is truly magnificent.
@endobj

@rem *************************************************************************

@rem Now we'll introduce two more objects with dummy qualifiers... AB_BEDROOM
     and AB_HALLWAY. These are going to provide another way for the player to
     move between the hallway and the bedroom. I.e. from the hallway, the 
     player will be able to use 'GO BEDROOM', from the bedroom he will be 
     able to use 'GO HALLWAY', or 'GO HALL'.

     Notice that these objects cannot be moved, and they are in a different
     room to their AA_ counterparts.

     The OBJPORTAL token tells CAT that this object is a portal into another
     room - the player can enter it. Portals are like doors, except they only
     work in one direction. CAT does not sort out the location of portals.. 
     it's up to you to define where they should be placed with OBJROOM.

@rem *************************************************************************

@obj		ab_bedroom
@objngt	
@objhide
@objroom	hallway
@objportal	bedroom
@objlng		It's just an average bedroom.
@endobj

@obj		ab_hallway
@objsyn		ab_hall
@objngt	
@objhide
@objroom	bedroom
@objportal	hallway
@objlng		The hallway is truly magnificent.
@endobj
 
@rem *************************************************************************

@rem I am now going to introduce another player, Simon, and I am going to
     create a bed that is too small for Tony, but big enough for Simon.

     Note: because the bed is a portal, AND it has an in-room, a player can
     enter it, or they can place things inside it.

@rem *************************************************************************

@obj		Simon
@objsht		Simon
@objwgt		100
@objstr		75
@objplr
@objroom	hallway
@objinrm	In_simon
@endobj

@room 		In_simon
@roomsht	Carried by Simon.
@roomlng	You are being carried by Simon.
@roompth	down,carried
@endroom

@obj		Bed
@objsht		a small bed
@objroom	bedroom
@objngt
@objinrm	in_bed
@objstr		100
@objportal	in_bed
@endobj

@room		In_bed
@roomsht	In bed.
@roomlng	You are in bed.
@roompth	up,carried leave,carried
@endroom

@rem *************************************************************************

@rem I have covered player objects. Now, I'm going to introduce two new types
     of 'live' objects... Commandable objects (OBJCMD), and active objects
     (OBJACT). The current player object can issue commands to any
     'commandable' object like this 'BILL, DROP THE RED KEY'. 'Active' 
     objects are 'alive'... the player cannot control them in any way, but
     he can still interact with them.. i.e. he could give things to them.

     OBJPLR automatically selects OBJCMD and OBJACT.

     OBJCMD automatically selects OBJACT.

     If an object has any of OBJPLR, OBJCMD, or OBJACT specified, it should
     also have an in-room defined - its' inventory.

     Let's introduce a commandable character, Bob. He'll start off wearing 
     a hat. The player could issue a command such as this: 
     BOB, TAKE OFF THE HAT AND GIVE IT TO ME, THEN GO SOUTH.

     We'll also introduce Harry. He's active, but the player has no direct
     control over him.

     Because both BOB and HARRY have OBJNGT selected, neither Tony nor Simon
     will be able to carry either of them.
     
@rem *************************************************************************

@obj		Bob
@objsht		Bob
@objcmd
@objroom	Bedroom
@objngt
@objstr		50
@objinrm	In_bob
@endobj

@room    In_bob
@roomsht Carried by Bob.
@roomlng You are being carried by Bob.
@roompth down,carried
@endroom

@obj		Hat
@objsht		a hat
@objroom	In_bob
@objworn
@endobj
	
@rem *************************************************************************

@obj		Harry
@objsht		Harry
@objact
@objroom	Hallway
@objngt
@objstr		50
@objinrm	In_Harry
@endobj

@room    In_harry
@roomsht Carried by Harry.
@roomlng You are being carried by Harry.
@roompth down,carried
@endroom

@rem *************************************************************************

@rem Now, there is only one more characteristic that an object can have.
     That is a value. This can be viewed as a monetary value. OBJVAL doesn't 
     provide any default actions by CAT, but an objects value can be checked
     and changed by user logic (to be covered shortly).

     The OBJVAL token tells CAT the value of this object.

@rem *************************************************************************

@obj		note
@objsyn		fiver money
@objsht		a five pound note
@objval		5
@objroom	in_simon
@endobj

@rem *************************************************************************

@rem Review any areas of this tutorial that you have not fully understood.
 
@rem *************************************************************************
@rem ****************           End of Tutorial #2           *****************
@rem *************************************************************************
