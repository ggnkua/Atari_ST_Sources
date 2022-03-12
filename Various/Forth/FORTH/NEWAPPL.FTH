( NewAppl.fth)
( Here's just about the fastest way to write an entire application. Note
  that you don't have to give the window a TITLE. The key to writing
  applications in Mach1 is defining a top word that will initialize your
  system and then start it running.)

NEW.WINDOW MyWindow		( define a new window)
" Greetings" MyWindow TITLE	( give window a title )
1200 1200 TERMINAL MyTask	( define a new terminal task)

: Greetings 			( this is what the application does)
	BEGIN 			( it just prints out 'hi' like an)
		." Hi!" 	( idiot until someone hits a key.)
		CR 		( Then it will exit ('BYE') to the)
	?TERMINAL 		( desktop)
	UNTIL 
	BYE ;


: TopWord			( Since TopWord will be the top word,)
				( it's responsible for initializing)
				( the system and then starting up:)
				( INITIALIZE)
	MyWindow ADD		( pop window up)
	MyWindow MyTask BUILD	( join the window and task together)
				( START-UP)
				( 'ACTIVATE' is used in a definition (only!) )
				( to assign the word-to-run to a task.)
	MyTask ACTIVATE Greetings ;			


CR
.( To turnkey this, type 'Turnkey TopWord FastApp')

( 'Turnkey' makes a new application call 'FastApp.PRG' and tells it to
  run 'TopWord' when it boots.)