( When you just want another Forth task real fast, just load this in or
  type it in. It's easy to memorize.)
 
NEW.WINDOW MyWindow		( define a new window)
MyWindow ADD			( pop it up)

1200 1200 TERMINAL MyTask	( define a new terminal task and allocate
				  stack space)
MyWindow MyTask BUILD		( join the window and task together)

: Run 
	ACTIVATE 		( 'Activate' assigns code to a task. )
	QUIT ;			( This task will run QUIT, the word
				  that 'is' Forth.)	

MyTask Run			( start the task)
