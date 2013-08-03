

Sonolumineszenz - The Full Story



 30.3.97 First official release (1.1) at Siliconvention

 31.3.97 * General cleaning up of source codes (old versions were used),
           A-v-e-n-a last part clears screen unnecessarily and all parts
           wipe more of the screen than is needed.
         * Made sure sequencer calls, and updates, were made BEFORE objects
           are drawn for first time
         * Removed lots of spurious INCBINs and DS statements!
         * Resolution setting bug in "inside" part fixed

 01.4.97 * Fixed the annoying clipping error that has bugged me for the
           last 18 months. It was a rounding error problem. This slight
           rewrite has also fixed the morphing map error too?

 08.4.97 * Smoothed out the morphing section so the normal morph doesn't
           jump suddenly. All I do is store the normals as half as
           small to stop morphing off the scale and wrapping round
           to the other side again.

 14.4.97 * Another DSP writing bug fixed. This made the system crash
           when sending DSP programs because it wrote a DSP word in
           two halves rather than all in one go


 15.4.97 * Isolated the final crashing bug to WHENEVER the DSP interrupt
           is called (and not the host port "protector" as I had suspected)
           Now I have to look through the book to find a possible way
           of fixing this...

 15.4.97 * Success! The problem was due to pipelining tricks being
           interrupted by the DSP interrupts and hence ruining the
           pipelining. The demo now appears to be very stable (it runs
           for 6 hours without a crash)


