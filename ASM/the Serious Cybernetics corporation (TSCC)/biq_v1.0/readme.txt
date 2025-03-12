   ....                                                                 ....
   :  :                                                                 :  :
   :..:................the sirius cybernetics corporation...............:..:
 _____:___________________ _____________________________________________:____
 \    /    |_   \         \\         |         \         \    .    \         |
 |    ' ___/ \__|    |    ||   \_____\    |    |    |    |    _____|   \_____\
 |::  |    |::  |:: ______||::       |::  |    |::  |    |::  |    |::       |
 /_________/____\___\_    |\_________\_________\_________/_________\_____ltk_\
 =====:========== BIQ \___\ a sirius image codec =======================:=====
   ...:.................................................................:...
   :  :                                                                 :  :
   :..:                                                                 :..:


   hi,

   i'm proud to finally present you my attempt at a lightweight, lossy image-
   codec called "BIQ". the name is actually stolen from an old amiga program.
   besides being image compression utilities they have nothing in common,
   though. "BIQ" stands for blockwise image quantization and describes the
   effect of the lossy technique on the input images, i.e. the stronger they
   will get compressed the more blocking artifacts will get visible for the
   sake of improving packing ratio.

   BIQ v1.0 is able to achieve compression ratios of up to 1:80 (0.1bpp) de-
   pending on image content and the chosen quantization strength. at present
   BIQ supports 8bpp greyscale, 8bpp colormapped (!) and 24bpp RGB images.
   support for 16bpp RGB / 16bpp CrY (jaguar) is planned for the future.
   incorporating a lossy compression mode for 8bpp colormapped images is to
   my knowledge something completely unique to this codec, how it can be
   achieved will be described below.

   my main goal in programming this image codec was besides curiousity and
   the fun of it creating a lossy image compression sheme with a very small
   decoder but yet fairly efficient packing ratio. and to my satisfaction
   i believe i have succeeded in fulfilling these needs (at the moment the
   decoders are 386, 332 and 432 bytes small in the order of greyscale,
   colormapped and RGB decorders) - but sorry, i didn't want to vaunt too
   much here.
   the decoding routines are completely optimized for size so don't expect
   them to be anything near fast. also, i did not waste any time on optimi-
   zing this code for 68030+ (sic) addressing modes etc., nor did i pay too
   much attention on optimizing the code to the maximum in terms of size
   so there might still be some more bytes left to be ripped. for now the
   decoders are in a useable state, anyway.
   the 24bpp RGB version will output 16bpp RGB (565) images so they can be
   used on the falcon. please note that the workspace needed to decompress
   24bpp images will still need 3bytes per pixel which is sort of an ugly
   and temporary solution, i hope i can improve on that in the future.


   for the interested reader i have included a small technical note on how
   the compression sheme works:

   the initial image signal (2D) will be subsequentially be split into low
   and high frequency sections using two very simple filters (i.e. the haar-
   scaling and -wavelet function). on one dimensional signals imagine these
   as the discrete folding of the signal with the vectors (+1,+1) (scaling)
   and (+1,-1) (wavelet) across a short time interval of 2 taps. of course,
   an image is a two-dimensional signal so you have four possibilities of
   applying those two filters in horizontal and vertical direction (i.e.
   LL, LH, HL and HH, with L=lowpass, H=highpass). to the human eye the
   major energy will remain concentrated in the LL band so the LH, HL and
   HH bands can get quantized to remove redundant characteristics without
   completely destroying the image's context meaning strong contrasts and
   outlines will be conserved while "noisy" patterns and reliefs will get
   thrown away, usually.
   using the haar wavelet has the advantage of not being forced to use
   multiplies for your filters as obviously the coefficients are either
   +1 or -1, so that the decoder can get away without any multiplications
   which are known to be costy up to the 68030.
   this so called DWT (discrete wavelet transform) can be repeated on the
   LL band so energy will get gathered further into the upper left corner
   of the image improving upon entropy in the quantized higher frequency
   bands for encoding the output coefficients later on. just on a note:
   i'm using lz78 for compressing the obtained DWT coefficients which is
   not an entropy coder, but still due to large solid areas lz78 will
   work out well. i chose lz78 for size reasons, and some benchmarkins
   showed that it isn't any weaker than RLE+Huffman.
   as there are six subdivision steps of the original image its width and
   height dimensions will be (rather) limited to multiplies of 2^6 = 64
   pixels, but i might think about improving on this in a future release
   if there's any demand.
   i forgot to mention that the DWT can be completely reversed using the so
   called iDWT so naturally the image can be restored from the quantized
   DWT coefficients.
   additionally, as using the 2-tap haar wavelet the transform is basically
   nothing else than a 2x2 DCT "recursively" repeated on the DC band which
   explains why the codec has strong compression artifacts since there is
   no smoothing involved in expanding the four bands into the next upper
   resolution level which will of course persue into the higher scales
   during the image's reconstruction.

   the lossy mode for 8bpp color images can be obtained by using a fairly
   sophisticated idea: first the given image will be converted into 24bpp
   truecolor using its palette and then be treated (transformed+quantized)
   like a 24bpp RGB image. the result will be restored using the iDWT and
   will then be converted back into 8bpp by finding the closest matches to
   the initial palettes' colors. redundant image content has now been
   removed. finally a lossless DWT sheme will be applied to store the
   image which explains why the compression rate for 8bpp color images
   will generally be a bit weaker than for greyscale or truecolor images.


   the BIQ image format is organized as follows:

        struct {
                long ident;    /* "_BiQ" */
                word type;     /* 0x00=gray, 0x01=8bpp color, 0x02=RGB */
                word width;    /* Image dimensions in pixels */
                word height;

                byte palette[768]; /* 8-8-8 RGB palette (256 colors) if
                                      type == 0x01, otherwise this record
                                      will be omitted */
                byte dwtCoeff[];   /* LZ78 encoded stream of DWT coeffs */
        }


   all records are of course stored in bigendian order.

   the CLI conversion utility is written completely in C and i tried to keep
   the source code as readable, clean and "OOP-like" as possible, although as
   usual it turned out to become more messy than expected in the end ;).

   its usage should be rather straightforward. it accepts uncompressed 8bpp
   grayscale, 8bpp colormapped and 24bpp targa images which can be converted
   into BIQ by specifying an quantization amount of 0 (lossless) to 99
   (strongest quantization, which looks very blocky but produces very small
   images, as well):

   "biq.ttp 50 test.tga" , will compress test.tga -> test.biq with a medium
                           quantizazion strength

   "biq.ttp test.biq"    , will convert test.biq back into test.tga, WARNING:
                           biq.ttp does not ask before overwriting a file!!


   requirements for the codec:

   -an ANSI C conform compiler (Pure C, GCC should do)
   -any 68k Atari :)


   requirements for the example programs:

   -TT030/Falcon030
   -RGB/VGA
   -CT60 and Fastram support


   feel free to use this code in your 4ktros, 96ktros or whatever but please
   be kind enough to give me some credit ;).

   the various decoders can be found in the "biq_test" directory in 3 files
   called: "8bpp_gry.s" (type 0x00), "8bpp_pal.s" (type 0x01) and 
   "24bpprgb.s" (type 0x02).


   if you have any questions requests, bugreports etc. send them to me via:

   eml: ray@tscc.de
   irc: ircNet->#atariscne->ray_tscc

.. ray//.tSCc. ........................................................ 2006 ..