      __________        ____________      ____________      ____________
      )        /____    )       ___/______)        __/______)        __/______
     /        _____/___/___________      /        /        /        /        /
    /        /        /                 /        /        /        /        /
    \________________(_________________(_________________(_____________mcl_(

                     . tHE sIRIUS cYBERNET!CS cORPORATION .

                           . nO pROM!SES nO dEMANDS .

--------------------------------------------------------------------------------
				    mandel.prg
--------------------------------------------------------------------------------

hiya,

 here's another little quickhack that i made up for alive #12 along with my
 article describing how to perform fast mandelbrot iterations.
 so here comes a little mandelbrot fractal explorer that lets you zoom into
 the set as deep as 11 bits fixedpoint accurracy allows (i.e. not very much).

 useage should be pretty straightforward, move the cursor into position and
 click the left mouse button. the fractal will be recalculated and redrawn
 zoomed in using the selected cursor position as its new origin.
 you can repeat this process until the scale leaves the minimum fixedpoint
 range which will result in single colored vertical or horizontal lines that
 will appear instead of a fractal, you can click the right mousebutton to
 reset the view or press escape to exit.
 
 there are still some bugs remaining such as the cursor redraw after a zoom
 in but i didn't have any time to fix this, sorry.
 
 feel free to extend accurracy of the calculation, make up a julia set
 explorer or whatever, just make sure to give me some credit ;).
 
 big thanks to earx for making up the RGB SCP set last minute.

 have fun and a merry christmas etc...


 requirements/specs.:

   -TT030 or Falcon030/060
   -any RAM configuration
   -Fastram supported
   -RGB/VGA monitor



 if you have any questions or comments feel free to contact me via
 eml: ray@tscc.de
 www: http://ray.tscc.de                                         ray, dec. 2005
--------------------------------------------------------------------------------