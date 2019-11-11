AUTHOR : Adrian Lovatt
PROGRAM : TURTLE.BAS
VERSION : 1.0  14/8/95
FUNCTION : Provide a set of turtle graphics commands for Basic
                   based on the LOGO commands.
VARIABLES : curx,cury,newx,newy,aspect,dir,penstate
COMMANDS : fwd(),back(),right(),left(),pup,pdown,head()
FUNCTIONS : heading


REASON :
        When I first got Basic2 I tried the spirals program from the
        manual, and was impressed by the speed of drawing, but noted
        that only two of the turtle commands were present. Anyway I 
        decided to try and write the other commands as an experiment, 
        this is the result of my work.


COMMAND LIST :

        FWD X
        Will move the turtle x pixels in the direction it is facing,
        if pup has been used then no line is drawn, otherwise a line
        x pixels long will be drawn.
        
        BACK X
        Will move the turtle x pixels away from the current direction,
        that is it moves backwards without changing direction, pup and
        pdown change the drawing action as noted below.
        
        RIGHT X
        Will turn the turtle x degrees to the right, x=90 gives a right
        angle.
        
        LEFT X
        Will turn the turtle x degrees to the left.
        
        PUP
        This is short for penup, and any movement of the turtle after
        this command will NOT draw lines, it simply allows you to
        reposition the turtle without leaving a trail.
        
        PDOWN
        This is short for pendown, any movement of the turtle after
        this command will leave a line, this is used for the actual
        drawing.

        HEAD X
        This will change the current direction to be x degrees.
        
        HEADING - FUNCTION
        This is a function that returns the current dir in degrees.

VARIABLE LIST:

        CURX,CURY
        These hold the current x,y co-ordinates of the turtle, and can
        be given new values if you want to move the turtle to a set
        location on screen without leaving a line.
        
        NEWX,NEWY
        These two are used by the routines internally and should not be
        altered by your program.
        
        DIR
        This is used internally to hold the current direction,
        note it is not in degrees and should not be altered by your
        program.
        
        PENSTATE
        This holds the current state of the pen, it is used in the
        forward and back routines to determine if a line should be
        drawn or not, the commands PUP and PDOWN alter it properly
        so you should not need to alter it within your program.
        
        ASPECT
        This is to allow the routines to run in any of the STs resolutions
        set to 1 for low and high res, but set to 2 for medium res,
        this makes the line drawing routines take account of the pixel
        shape in medium res, ie not square.


EXAMPLE

To draw a square:
fwd 50
right 90
fwd 50
right 90
fwd 50
right 90
fwd 50
right 90

This will draw a square whose height is 50 pixels.
See tutorial file for more examples.
