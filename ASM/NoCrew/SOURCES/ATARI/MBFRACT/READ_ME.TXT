
 Hello there!
 
This is two mandelbrot generators I've made as a test on my Falcon.
They aren't developed very far and there are still some tricks which will
make them much faster, especially the DSP program. If you find something
useful in these sources you may copy it, because I won't develop them
anymore (probably) and I think it's a waste only let them lie on my
harddrive. I won't be very surprised if you find bugs because I
already know several ones.

The program manual: Left mouse button will zoom, right mouse button exits
                    and the key 'e' (m68k) will enhance the accuracy,
                    which will be useful when you are zooming very much.

Please note that the 68K version uses a much faster drawing algorithm
compared to the DSP version, which uses brute force. The iteration 
loop is faster on the DSP, but it calculates all pixels which the 68K
don't. (It would be nice to see a really fast DSP code use the better
algorithm)

Fredrik Noring, March 1994.

e-mail: noring@lysator.liu.se
