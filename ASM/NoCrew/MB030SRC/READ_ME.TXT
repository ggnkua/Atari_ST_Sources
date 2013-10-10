
 Hi,
    this is two mandelbrot generators I've made as a test on my Falcon.
They aren't developed very far and there are still some tricks which will
make them much faster, especially with the DSP. If you find something
useful in these sources you may copy it, because I won't develop them
anymore (probably) and I think it's a waste only let them lie on my
harddrive. I won't be very surprised if you find some bugs because I
already know several ones.

The program manual: Left mouse button will zoom, right mouse button exits
                    and the key 'e' will enhance the accuracy, which will
                    be useful when you are zooming very much.

Both sources are assembled but will not work on a VGA-screen. If you only
got a VGA or simply wan't them to work on it, you'll have to change the
sources and reassemble them. Open the files 68CFMAIN.S and MBMAIN.S and
change the MODE number (at the beginning of the source). You must also
change the SCREEN_W, SCREEN_H, FRACTAL_W and FRACTAL_H and set them to
appropriate values. The resolution must in any case be "True Color".

Please note that the 68K version uses a much faster drawing algorithm
compared to the DSP version, which uses "brute force". The iteration 
loop is faster on the DSP, but it calculates all pixels which the 68K
don't. (It would be nice to see a really fast DSP code use the better
algorithm)

Fredrik Noring, March 1994.

If you would like to contact me for some reason, my address is:
 Fredrik Noring
  Spinnarev„gen 10
  S-43734 Lindome
     SWEDEN
     
     
