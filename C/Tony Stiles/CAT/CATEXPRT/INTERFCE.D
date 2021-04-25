@rem Notice that each external function name is preceeded with an _
     Also, all external functions must be followed by ()

@rem When the program starts, we'll turn the mouse off.

@first
   _mseoff()

@rem When we initialise, we'll print the number of
     rooms, objects and messages in the adventure.

@init
   @pmsg(advent_has)
   @pnum(_roomcnt())
   @endchar(',')
   @pmsg(rooms)
   @pnum(_objcnt())
   @pmsg(objects)
   @pnum(_msgcnt())
   @endchar('.')
   @pmsg(messages)
   @lf

@msg     advent_has
@msgtxt  This adventure has
@endmsg

@msg     rooms
@msgtxt  rooms
@endmsg

@msg     objects
@msgtxt  objects and
@endmsg

@msg     messages
@msgtxt  messages
@endmsg

@rem Here's a ridiculous example, but what the heck!

@verb reverse_look @endverb

@low
@if @verbnois(reverse_look) @do
   _revroom(@thisroom)
   @look
   _revroom(@thisroom)
   @cont
@endif

@rem Using CAT, it is not possible to use 'freeform text', i.e. all text is 
     printed as words, and wrapped at the end of the line. This is fine
     most of the time, but occasionally you may want to print something in
     free format (a table, map etc). You can use custom C code to do this!

@verb testa @endverb

@if @verbnois(testa) @do
   _freeform()
   @cont
@endif

@rem This last example passes a room and two objects to custom C code,
     the custom code prints the OKAY message, prints the short description of
     the room and the objects, and then returns the room number of the second
     object - which is then stored in counter 376!.....
        Useless in application but good as an example!
     
@verb testb @endverb

@if @verbnois(testb) @do
   @setcount(376,_roomtest(bedroom,hat,tony))
   @pnum(@count(376))
   @cont
@endif

@rem Just before the program ends, we'll turn the mouse back on.

@last 
   _mseon()
