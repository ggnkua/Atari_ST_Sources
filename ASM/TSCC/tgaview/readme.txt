--------------------------------------------------------------------------------
				tgaview.ttp
--------------------------------------------------------------------------------

hiya,

  this is a little example trying to show how interlacing, a (slow) 1*1 c2p and
  tga-file processing can be implemented to anyone who's interested.

  assembled as a ttp-program this can be used to view 24bit uncompressed targa
  files in an interlaced 12bit mode on any 16/32Bit ATARI machine *except for
  the Falcon030* where it doesn't work correctly as it has not been adapted.
  you can try running the tool from an ST compatible mode there, but the colors
  will look inverted, sorry.
  on machines with a 9bit color DAC (i.e. ST/MST) it uses adapted gradients in
  order to achieve the full 4096 colors as available on other machines, as well.
  though, the colors won't look as clean as on an STE/MSTE/TT030 there, but
  still it is a 12bit mode.

 how to use:

  double-click from your desktop and enter the name of your picture (retaining
  the .tga extension !), you can also drag&drop your image onto tgaview.ttp if
  supported by your OS, of course.
  tgaview will then check the file-type and the image's size. if everything is
  ok i'll attempt loading it. hit a key to view the image now. the image's size
  may not exceed 320x480 pixels. pictures that are higher than 200 pixels can
  be scrolled vertically by using the cursor keys. press escape to return to
  the desktop.

  the source assembles with hisoft's devpac.

 requirements/specs.:

   -ST/MST/MSTE/TT030
   -any RAM configuration
   -fastram support
   -RGB/VGA monitors


 enjoy,
  ray//.tSCc.


 email:	ray@atari.org
 hp:	http://ray.atari.org
--------------------------------------------------------------------------------