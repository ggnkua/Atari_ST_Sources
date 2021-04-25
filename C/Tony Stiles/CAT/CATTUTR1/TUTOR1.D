@rem C Adventure Toolkit (CAT) - Tutorial #1

@rem This file introduces the initial concepts of the Adventure Toolkit.

@rem ***************************************************************************

@rem This is a remark line. If the CAT sees a word with an @ at the beginning
     of it, it checks to see whether it is a recognised token. @REM is one of
     the recognised tokens, and it tells CAT to ignore everything it sees until
     it recognises another token. I will be using the @REM token a lot!

@rem CAT doesn't mind how many spaces, tabs, or blank lines you leave between 
     words. It is only interested in the words themselves.

@rem You can use any ascii (printable) characters in a CAT source file.

@rem ***************************************************************************

@rem The first concept that you will need to understand is 'Rooms'. The 
     adventure world is divided into rooms. These need not actually be enclosed
     rooms in the traditional sense.. a room may be 'At the top of a tree',
     'In a field' etc.

@rem Rooms have a short description and a long description. They can be dark,
     or they can be light. There may be a number of paths leading from a room
     into another room. It is possible to award a player points the first time
     he enters a room, and it is light.

@rem We are going to define two rooms to CAT. The first room is a Hallway. It
     is dark, and there is a path leading north to the bedroom. The bedroom is
     not dark, and it obviously has a path leading south to the hallway. The 
     player will be awarded 10 points the first time he enters Hallway, when
     it isn't dark.

@rem **************************************************************************

@room 		Hallway
@roomsht	Hallway.
@roomlng	You are standing in a magnificent hallway. You can go north
		to the bedroom from here.
@roompth	north,bedroom
@roomdrk
@roompnt	10
@endroom

@room		Bedroom
@roomsht	Bedroom.
@roomlng	You are in a tiny bedroom. You can go south to the hallway 
		from here.
@roompth	south,hallway
@endroom

@rem **************************************************************************

@rem The ROOM token tells CAT the name of the room you are defining.
     Names within CAT can contain any letters of the alphabet, and the underline
     character (_). i.e. BEDROOM, MAIN_HALLWAY, X_GARDEN.

     The ROOMSHT token describes the short description for this room.

     The ROOMLNG token describes the long description for this room.

     The ROOMPTH token describes all the paths leading from this room,
     and the rooms to which they lead. Notice that you must specify the
     directional verb (NORTH/SOUTHEAST etc), immediately followed by a ','
     immediately followed by the name of the room to which the path leads. 
     A room can have many paths leading to many rooms.

     The ROOMDRK token tells CAT that this room is dark.

     The ROOMPNT token tells CAT that the player should receive a number of
     points when he first enters a room (10 points for the hallway).

     The ENDROOM token tells CAT that we have finished defining this room.

@rem *************************************************************************

@rem When the player enters a room for the first time, they will be given the
     long description of the room. When they enter it a second and subsequent
     times, they will be given the short text. The short text for the current 
     room is always shown at the top of the adventure screen. Neither the long
     nor the short room description will be given if the current room is dark
     and there is no source of light available. It is possible to make a dark
     room light, or a light room dark. (see CATMAN.TXT)

@rem *************************************************************************

@rem CAT will automatically define a special room for you. This room is called
     NOWHERE, and is used to hold objects that are not currently in the 
     adventure universe, but may be at a later point.

@rem *************************************************************************

@rem CAT places no limits on the maximum length of text... all pieces of 
     text are stored in strings. C compilers have a limit on the maximum 
     size of a string (255 for Sozobon C), it is therefore recommended that
     none of your text is longer than 255 characters. This will ensure that 
     your adventure is portable between compilers. The long and short
     descriptions of rooms are pieces of text, as are descriptions of objects
     and message texts. (i.e. anything that will be presented to the player).

     'LF' can be included in any piece of text, and it will print a linefeed
     character.

@rem *************************************************************************

@rem The next concept you will need to understand is that of the 'object'.
     Objects are the heart of adventures. Some objects are 'a huge statue',
     'a key', 'a chest', 'a door'.

     In fact, the player is a special type of object in the adventure, a
     player object! Every adventure must have at least one player object, so
     let's look at how to define one. The player can type 'BECOME x', where x
     is the name of any player object. All his commands will then be followed
     by player object x.

     CAT allows ANY NUMBER of player objects. This feature is unique to CAT - 
     any other system available only allows you to directly control ONE player.

@rem *************************************************************************

@rem Player objects must have a room attached to them (an in-room). This 
     is the room in which any objects that player is carrying will be placed.
     The definition below defines the player object Tony, and his 'in-room'.

     Player objects are presumed to be 'Active'. An active object is any 
     object that is alive. We will be covering Active objects shortly.

@rem *************************************************************************

@obj 		Tony
@objplr
@objsyn		Dude
@objsht 	Tony
@objlng 	Tony is just an average guy.
@objroom 	Bedroom
@objinrm 	In_Tony
@objwgt		125
@objstr 	100
@endobj

@room		In_tony
@roomsht	Carried by Tony.
@roomlng	You are being carried by Tony.
@roompth	down,carried
@endroom

@rem **************************************************************************

@rem The OBJ token tells CAT the name of the object you are defining.

     The OBJPLR token tells CAT that this object is a player. i.e. the player
     can BECOME TONY. 

     The OBJSYN token tells CAT that 'dude' is a Synonym for 'Tony'. The
     player can refer to the TONY object with either 'Tony', or 'Dude'. Each
     object can have many synonyms.

     The OBJSHT token describes the short text for this object.
     The short text for an object is used when listing objects, i.e. Inventory.

     The OBJLNG token describes the long text for this object.
     The long text for an object is used when examining an object etc.
     If an object has no long text, examining it will produce the standard
     message 'You don't see anything unusual.'

     The OBJROOM token tells CAT which room the object will start in.
     If an OBJROOM token is not specified, the object will start in the 
     NOWHERE room - which should not be accessible by the player.

     The OBJINRM token tells CAT the in-room for this object. I.e. when 
     objects are placed in this object, they will be in room IN_TONY. Any 
     object can have an in-room. For example, a box would have an in-room, 
     thus allowing the player to put things inside it.

     The OBJWGT token tells CAT the weight of this object.
     The default weight for an object is 1.

     The OBJSTR token tells CAT the strength of this object. This means 
     something slightly different for active objects compared to other
     objects: 

       When considering an active object, this is the maximum TOTAL weight of 
       objects he/she can carry, i.e. taking count of each object he is 
       carrying PLUS the weight of any objects contained within them!
     
       When considering a non active object, this is the maximum weight of the
       objects contained within it, NOT including the weight of any objects
       that may be within them - a simulation of volume.

     Objects without OBJSTR defined will have a strength of 0.

     The ENDOBJ token tells CAT that we have finished defining this object.

******************************************************************************

@rem The in-room for TONY needn't have been called IN_TONY. It could have been
     called TONY_INV or GOT_TONY or anything else you may like.

     The room IN_TONY has been given a long and short description, because it
     is always possible that another player object will be in this room, i.e.
     being carried by TONY!

     Notice the ROOMPTH leading DOWN from IN_TONY. The special room CARRIED
     is not really a room. It is a way of ensuring that when this path is
     taken, you will end up in the same room as TONY, without having to worry
     about where TONY actually is. You can use CARRIED as an exit from any
     room that has been defined as an in-room.

@rem *************************************************************************

@rem Now, we are going to introduce another object - the lamp. This will 
     give us some light to see in the hallway. You can define an object as 
     being a light source, or being a light source AND being lit.

     The OBJLGT token tells CAT that this object is a light source. The OBJLIT 
     token tells CAT that this object is a light source, and it is lit.

     Here's the definition for the lamp, which is lit and in the bedroom.

@rem **************************************************************************

@obj 	 lamp
@objsht  a lamp
@objlng  Just an ordinary lamp.
@objlit 
@objroom bedroom
@objwgt  10
@endobj

@rem *************************************************************************

@rem The following code ensures that TONY is the currently controlled player
     when the adventure starts, but don't worry about understanding it now.

@rem *************************************************************************

@init @become(tony)

@rem *************************************************************************

@rem Review any areas of this tutorial that you have not fully understood.
 
@rem *************************************************************************
@rem ****************           End of Tutorial #1           *****************
@rem *************************************************************************

