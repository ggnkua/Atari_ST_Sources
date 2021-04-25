@rem C Adventure Toolkit (CAT) - Tutorial #3

@rem This file introduces verbs.

@rem *************************************************************************

@rem Now, I'm going to introduce verbs. CAT has lots of verbs already defined
     for you in the ZZRQD and ZZSTD definition files, but you may want to 
     create more that are specific to your adventure. Consider the following:

@rem *************************************************************************

@verb 		Rub
@verbsyn	Shine Polish
@verblgt
@verbchk	Avail_not_worn
@endverb

@rem *************************************************************************

@rem The VERB token tells CAT the name of the verb we are about to define.

     The VERBSYN token describes some synonyms for the verb RUB. e.g.
     RUB LAMP, SHINE LAMP, and POLISH LAMP are all the same.

     The VERBLGT token tells CAT that it must be light for the player to 
     successfully use this verb. If the player uses this verb when it is 
     dark, he will get a standard message 'It's too dark to do that.'

     The VERBCHK token tells CAT that the verb RUB must refer to an object, and 
     that object must be available (in the current room, or carried), and
     not worn. If the player uses the command 'RUB' without any object, 
     he will be told that he must specify an object. If he tries to RUB 
     something that he is wearing, or is not available, then he will be 
     given an appropriate message 'You're wearing that' or 'That's not here'.

     Only one VERBCHK can be specified for each object. Valid VERBCHKs are:

        NO_CHECK         - no checking is performed, an object is not required.
        HERE             - an object is required, and it must be here
                           (in the same room as the player).
        CARRIED_NOT_WORN - an object is required, it must be carried but
                           it must not be worn.
        WORN             - an object is required, and it must be worn.
        AVAIL            - an object is required, it must be available 
                           (in the same room as the player, or carried).
        AVAIL_NOT_WORN   - an object is required, it must be available 
                           (in the same room as the player, or carried), and
                           not worn.
        CARRIED          - an object is required, and it must be carried.
        NOT_CARRIED      - an object is required, it must not be carried.
        EXIST            - an object is required, and it must exist.

     If no VERBCHK is selected, the default is NO_CHECK

     You will notice that worn objects still count as being carried.

@rem *************************************************************************

@rem When used properly, the VERBLGT and VERBCHK tokens can provide nearly all
     of your validity checking - gone are the days when your logic has to 
     specifically check out the details of each object that the player refers
     to! This is a VERY powerful feature of CAT, and will eliminate many hours
     of consistency debugging!

@rem *************************************************************************

@rem Okay, now you know how to allow simple two word commands, but what about
     things like: GIVE THE HAT TO TONY. We can break this command into four 
     distinct parts: the verb (GIVE), the object (HAT), the compound verb (TO),
     and the compound object (TONY).

     If CAT wasn't told otherwise, it would interpret the above command as
     TWO commands i.e. 'GIVE HAT' and 'TO TONY' - this obviously doesn't make
     sense, so we need a way to tell CAT that 'TO' is a compound verb. We use
     the VERBPREP (prepositioner verb) token to do this. Consider the following
     extract from ZZSTD: 

@rem *************************************************************************

NOTE: THESE ARE NOT REAL DEFINITIONS - THERE IS NO @ AT THE START OF THE TOKENS.

verb     give
verblgt 
verbsyn  pass hand
verbchk  carried_not_worn
endverb

verb 	 to 
verbprep 
verbchk  avail_not_worn
endverb

@rem ignore the underbars (_) after the tokens - I have added these so that
     CAT doesn't recognise the tokens, or the 'GIVE' and 'TO' verbs would be
     processed twice (once here, and once in ZZSTD).

@rem *************************************************************************

@rem You will note that both the 'GIVE' and the 'TO' verbs have a VERBCHK
     defined. If the command 'GIVE THE HAT TO TONY' was given by the player,
     CAT would automatically perform the following checks:

     Make sure it isn't dark           (from VERBLGT defined on GIVE)
     Make sure the HAT is carried
     Make sure the HAT is not worn
     Make sure TONY is carried, or here
     Make sure TONY is not worn

     The command would only be passed to CAT logic if all of the above tests 
     pass successfully, otherwise an appropriate message will be displayed
     and CAT will wait for another command from the player.
 
@rem *************************************************************************

@rem Now I'm going to show you another extract from ZZSTD, Consider the verbs
     WEAR and REMOVE. It would be nice if the player could use any of the 
     following:
                WEAR HAT
                PUT ON THE HAT
                REMOVE THE HAT
                TAKE OFF HAT

     We are talking about TWO WORD verbs, i.e. 'PUT ON' is a synonym for 'WEAR'
     as 'TAKE OFF' is a synonym for 'REMOVE'. These are very easy to define 
     within CAT - we use an underbar to separate the two words:

@rem *************************************************************************

NOTE: THESE ARE NOT REAL DEFINITIONS - THERE IS NO @ AT THE START OF THE TOKENS.

verb	  wear
verblgt
verbsyn   put_on
verbchk   carried_not_worn
endverb

verb      remove
verbsyn   take_off
verbchk   worn
endverb

@rem *************************************************************************

@rem CAT uses each verbs VERBCHK to intelligently handle ALL. E.g.

     RUB ALL          - would rub all objects that are available, not worn. 
     WEAR ALL         - would wear all objects that are carried, but not worn.
     GIVE ALL TO TONY - would give all objects that are carried, but not worn
                        to Tony.

     Consider you are in a room. There is a lamp here. You are carrying a 
     coat and wearing a pair of gloves. 

     'RUB ALL' would generate the commands:

        RUB LAMP
        RUB COAT

     'WEAR ALL' would generate the commands:

        WEAR COAT

     'GIVE ALL TO TONY' would generate the command:
     
        GIVE COAT TO TONY

@rem *************************************************************************

@rem We have defined the verb 'RUB' in this tutorial. We haven't yet provided
     any logic to process this verb, this will be covered in tutorial 4.

@rem *************************************************************************

@rem Review any areas of this tutorial that you have not fully understood.
 
     Take a look at \CAT\STD\ZZSTD.D and \CAT\STD\ZZRQD.D, to see the 
     definitions of all the standard verbs. Try to understand what they are
     doing - it should all click into place fairly quickly!

     Note in particular the definition for GET. This is a 'funny' - we should
     be able to give it a VERBCHK of HERE. We can't do this, or we would 
     block commands like 'TAKE THE KEY FROM THE BOX'...... because the key
     isn't here (it's in the box), verbchecking would block the command.
     Instead, we have to use NOT_CARRIED, and use CAT logic to make sure that
     the object is here before we actually GET it!

@rem *************************************************************************
@rem ****************           End of Tutorial #3           *****************
@rem *************************************************************************

