      __________        ____________      ____________      ____________
      )        /____    )       ___/______)        __/______)        __/______
     /        _____/___/___________      /        /        /        /        /
    /        /        /                 /        /        /        /        /
    \________________(_________________(_________________(_____________mcl_(

                     . tHE sIRIUS cYBERNET!CS cORPORATION .

                           . nO pROM!SES nO dEMANDS .

--------------------------------------------------------------------------------
				cryview.ttp
--------------------------------------------------------------------------------

hiya,

 here's a little quickhack i've made up according to an article for alive #12
 describing how to emulate a 16bpp truecolor CRY mode (orginally known from the
 Atari jaguar) on the Atari TT by using a simple interlacing sheme.

 the provided programs enable you to convert 24bpp TGA images of arbitrary size
 and view the 16bpp CRY result on any Atari TT, large images will get rescaled
 to fit the virtual 320x240 px. resolution.
 
 commandline usage:

 'tga2cry.ttp infile[.tga] outfile[.cry]'

 'cryview.ttp infile.cry'

 '+'/'-' : adjust gamma to possibly reduce the flicker a bit on you monitor.
 '*'     : toggle between 8bpp greyscale and and interlaced 16bpp CrY mode.

 assemles with hisoft devpac / GNU C. have fun...

 requirements/specs.:

   -TT030
   -any RAM configuration
   -Fastram supported
   -VGA monitor




 if you have any questions or comments feel free to contact me via
 eml: ray@tscc.de
 www: http://ray.tscc.de                                         ray, dec. 2005
--------------------------------------------------------------------------------