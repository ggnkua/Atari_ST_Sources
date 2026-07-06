                              THE LINE_A

                The purpose of implementing the line_a Modula-2 was
       twofold. First, it wasn't implemented. And secondly, I was 
       disappointed in the slowness of anything that was being done
       through GEM.
       The functions implemented in this LINEA library are plotting,
       line drawing, locate (get pixel) and setting various attributes
       of the lines and plots.

        The files you should have are as follows :
          LINEA.DEF  ( compile this one first )
          LINEA.MOD  ( compile this one second)
          LINE_A.MOD ( demo program           )
          README.TXT

       Place the files LINEA.LNK & LINEA.SYM in your GEMLIB folder.          
      THE FUNCTIONS :

        LineAttribs(linemask,wrtmode)
          linemask-bit pattern of line.
          wrtmode- 0=write mode.
                   1=transparent.
                   2=XOR mode.
                   3=Inverse trans.  

       PlotColour(color)
         color-determines color of plot
               only bit zero is looked at in mono.

       LineColour(p1,p2,p3,p4)
         p(x)- is the plane involved.
         setting p1 to 1 would draw a black line in mono.

       Plot(x,y)
         plots a point at specifed location.

       Line(x1,y1,x2,y2)
         x1,y1- starting points of line.
         x2,y2- end point of line.

       Locate(x,y)
         This function returns the integer color value of the pixel
         located at (x,y).
         Example- color := Locate(x,y) ;

  **NOTE**
      These routines make use of registers d0-d4,d7,a0-a2 .
      Register d7 is RESERVED for the line_a variable address.           
 
*Passing note. I have included a demo program that utilizes these
   routines. When the program was originally written using the
   polyline & polymarker routines it executed in 3 min.10 secs.
   Using the LINEA it now goes in 2 min. 35 sec..

                        Jim Lorbetski   (71330,3217)
