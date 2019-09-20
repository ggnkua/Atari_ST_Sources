http://gfabasic.net/ (contact)
http://atari.gfabasic.net/ (get additional plugins for zview)
https://www.dev-docs.org/ (sample images, search for "samples")
Written by Lonny Puresll (12/7/2018)

PLUGIN37.GFA requires GBE 1.72/GFABASIC 3.7

Note that zView plugins do not return ready to use dithered bitmaps.
The caller must take the gfx data returned from the plugin and tranform it
into something usable. That means if you want dithered images and proper
blit'able bitmaps you are on your own.

This example assumes there's an open console to capture printed text such as
TosWin2. It should alos be ran in Falcon high color or more so the test results
can be seen correctly.

You don't have to unload the plugins. Multiple plugin can be loaded at once,
but you will have to find a way to manage multiple image_info structures.
That's beyond the scope of this example.

The bulk of this information came from studying the source code of zView.
Please contact me if you find an error or something seems unclear.

-------------------------------------------------------------------------------

Regardless of the input image file the plugins return image data in 3 possible
formats. The plugin decides which of these 3 formats will best preserve the
image quality during transfer.

The 3 image data formats:
  1) monochrome (black & white is assumed)
  2) color mapped (2 to 8 planes)
  3) 24-bit true color

The data is returned in a buffer supplied by the caller.
The size of this buffer should be: width*components
If the buffer is too small the plugin will overrun and clobber who knows what
and cause serious problems.

For the sake of clarity lets say we have a sample image in all 3 formats:
640x400

1) Monochrome:
buffer size = 640 bytes
each byte represents 1 pixel
  byte values will be 0 or 1
    0 = white
    1 = black
Palette: no (black & white is assumed)

2) Color mapped:
buffer size = 640 bytes
each byte represents 1 pixel
  byte values will range from 0 to 255
    these are indexes into the palette
    index, index, index, ...
Palette: yes

3) True color:
buffer size = 640*3 bytes
every 3 bytes represents 1 pixel (RGB order)
  byte values will range from 0 to 255
  R0 G0 B0, R1 G1 B1, R2 G2 B2, ...
Palette: no


Calling procedure:
  First LDG must be installed correctly.
  Plugins must reside in a folder called "codecs" inside the normal LDG path.
  Typical location of plugins: c:\gemsys\ldg\
    zView plugins must be at: c:\gemsys\ldg\codecs\
    Thus to references a zView plugin: "codecs\degas.ldg"

For GFA you must initialize the LDG routines since they are bindings.
Then you load the desired plugin
  Call the plugin_init() routine of the plugin (required)
  Create the image_info structure (reader_init() will update the structure)
  Set page_wanted to 0 (images have only 1 frame)
  Call reader_init() to gather information about the desired image
    See procedure codec_struct for a list of usable variables
    If the orientation flag is set the image needs to be vertically flipped
  Call reader_read() for each scan line
  Call reader_quit() to free the plugin resources
Then unload the plugin


Which image_info structure variables should be trusted? (marked with an '*')
width				*width in pixels
height				*height in pixels
components			*1 or 3
planes				1,2,4,8,15,16,24
colors				calculated colors, informational use only
orientation			*set if plugin requests image to be flipped top to bottom
page				frame count, can be ignored, unless you support loading animations
delay				frame delay, can be ignored, unless you support loading animations
num_comments		0 if no comments, informational use only
max_comments_length	only valid if num_comments > 0
indexed_color		*set if codec sent a palette (indexed color)
palette				*palette, valid if indexed_color is set (always full 24-bit RGB)
background_color	color seen in window when image is smaller than the window work area
thumbnail			never seen a codec that uses this
page_wanted			*frame to load, always 0, unless you support loading animations (passed in)
info				*describes image format, informational use only (max 39 chars)
compression			*describes compression method, informational use only (max 5 chars)
real_width			always same as width, never see thumbnails used
real_height			always same as height, never see thumbnails used

The easiest way to determine the image data format?
IF components=1
  ' mono
ELSE
  IF indexed_color
    ' color mapped
  ELSE
    ' true color
  ENDIF
ENDIF

You can't really trust 'planes'. The proof is in zview's own source code
archive. See godldg.c where it sets planes to 16, but transforms the image data
to 24-bit before sending it to zView.

In tgaldg.c planes is set to match the tga header and then 15/16-bit images are
again converted to 24-bit before being sent to zView.

If you must know the planes, my best advice is this. Planes seems to be
accurate if it's 1 to 8 only. Thus we can do this:
actual_planes=planes
IF actual_planes>8
  actual_planes=24
ENDIF
' then treat 'planes' as informational

*
