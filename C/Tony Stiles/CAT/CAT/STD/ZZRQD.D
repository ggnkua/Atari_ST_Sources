 @rem ZZRQD.D - last change 30/04/91

@rem This file contains all the definitions required for the standard
     C Adventure Toolkit. This file (or a version of it) will
     always be required to make a working adventure, as the system refers
     to all these definitions internally.

@rem ********************** Required messages ********************************

@rem Yes_chars and No_chars determine the key-presses that are acceptable 
     by CONFIRM. i.e. 'Yy' for positive and 'Nn' negative.
     
@msg    Yes_chars
@msgtxt Yy
@endmsg

@msg	No_chars
@msgtxt Nn
@endmsg

@msg	Yes
@msgtxt	Yes.
@endmsg

@msg	No
@msgtxt No.
@endmsg

@msg	More
@msgtxt	<<< MORE >>>
@endmsg

@msg	Bad_load
@msgtxt Unexpected format - load aborted.
@endmsg

@msg	File_not_found
@msgtxt	I can't find that save file.
@endmsg

@msg	Get_file_name
@msgtxt	File name (up to 8 chars):
@endmsg

@msg	Disk_error
@msgtxt	Sorry! Disk error!
@endmsg

@msg	Disk_full
@msgtxt	Maybe the disk is full, or write protected?
@endmsg

@msg	Operation_complete
@msgtxt	Operation complete!
@endmsg

@msg	Play_again
@msgtxt	Would you like to play again?
@endmsg

@msg	Too_dark
@msgtxt	It's too dark to do that.
@endmsg

@msg	Deaf_ears
@msgtxt Your command falls on deaf ears.
@endmsg

@msg	Scored
@msgtxt You scored
@endmsg

@msg	In
@msgtxt in
@endmsg

@msg	Turns
@msgtxt turns.
@endmsg

@msg    Press_a_key
@msgtxt Please press a key.
@endmsg

@msg    It_contains
@msgtxt It contains:
@endmsg

@msg    Nothing
@msgtxt nothing.
@endmsg

@msg    Which_one
@msgtxt Which do you mean?
@endmsg

@msg    Be_more_specific
@msgtxt Please enter the command again, but this time be more specific.
@endmsg

@msg	Darkness
@msgtxt	Darkness!
@endmsg

@msg	Empty_hands
@msgtxt	Your hands are empty.
@endmsg

@msg	It_is_alight
@msgtxt	It's lit.
@endmsg

@msg	It_is_open
@msgtxt	It is open.
@endmsg

@msg	It_is_closed
@msgtxt	It's closed.
@endmsg

@msg	It_is_dark
@msgtxt	It's dark here!
@endmsg

@msg	It_is_locked
@msgtxt	It's locked.
@endmsg

@msg	Object_worn 
@msgtxt	You are wearing that.
@endmsg

@msg	Nothing_unusual
@msgtxt	You don't see anything unusual.
@endmsg

@msg	Noun_not_found
@msgtxt	Sorry, but I can't recognise an object in that sentence.
@endmsg

@msg	No_command
@msgtxt	Sorry, I can't find a verb in that sentence. Please try expressing
	it in a different way.
@endmsg

@msg	No_obvious_exits
@msgtxt	You don't notice any obvious exits.
@endmsg

@msg	No_path
@msgtxt	There is no path leading in that direction.
@endmsg

@msg	Object_carried
@msgtxt	You are carrying that.
@endmsg

@msg	Object_not_got
@msgtxt	You don't have that.
@endmsg

@msg	Object_not_here
@msgtxt	You can't see that here.
@endmsg

@msg	Object_not_worn
@msgtxt	You're not wearing that.
@endmsg

@msg	Obvious_exits
@msgtxt	Obvious exits are:
@endmsg

@msg	What_now
@msgtxt	What now?
@endmsg

@msg    You_are
@msgtxt You are:
@endmsg

@msg 	And
@msgtxt	and
@endmsg

@msg	You_are_carrying
@msgtxt	You are carrying:
@endmsg

@msg	You_are_wearing
@msgtxt	You are wearing:
@endmsg

@msg	You_can_see
@msgtxt	You can see:
@endmsg

@msg	No_ram_load
@msgtxt	Sorry, I can't find a game save position in memory.
@endmsg

@msg	No_ram_save
@msgtxt	Sorry, I can't allocate enough memory for a Ramsave.
@endmsg

@obj		all
@objsyn		everything
@endobj

@obj		them
@objsyn		him her it those
@endobj

@obj		me
@endobj

@obj		except
@endobj

@rem ************************** Directional verbs ***************************

@verb enter @verbsyn go go_in go_inside go_into get_into climb_in climb_into 
      get_in go_through climb_through @verbchk here @endverb
@verb down @verbsyn d climb_down climb_d go_d go_down descend @endverb
@verb east @verbsyn e go_east go_e @endverb
@verb north @verbsyn n go_n go_north @endverb
@verb northeast @verbsyn ne go_ne go_northeast @endverb
@verb northwest @verbsyn nw go_nw go_northwest @endverb
@verb south @verbsyn s go_s go_south @endverb
@verb southeast @verbsyn se go_se go_southeast @endverb
@verb southwest @verbsyn sw go_sw go_southwest @endverb
@verb up @verbsyn u get_up get_u climb_up climb_u go_u go_up ascend @endverb
@verb west @verbsyn w go_w go_west @endverb
@verb leave @endverb

@rem ******* Prepositional verb FROM, used to qualify objects in boxes *********

@verb from @verbprep @verbsyn from_out from_in out @verbchk avail @endverb
