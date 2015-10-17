
                     the  sirius             low-tech atari
                     cybernetics             c yb erp un ks
                     corporation ........... since 1 9 9 0!
        _    _   _  _ _____   ___________________________ _  _   _    _  
     _ ______________     /___\_____                      _____________ _
                     |.   |   /.  _____|.   /.  |.  []   |
      _ _____________|:   |   |:   |   |____|:  |:  []__/\______________ _
                     /_________________\ltk|____|_____\    //
                     - = === LZ78 - a sirius packer ==/_  _\\
                                                        \//


 hi there scene,

 here's a brief description of lz78, a superior packer than or recent package
 that came with an implementation of lz77. unlike lz77, the lz78 group of algo-
 rithms use a contsant wordbook which is build during the decoding process in-
 stead of a sliding window back into the yet decoded stream.
 this way much longer strings can be encoded than using lz77. additionally,
 variable length bitcodes are being used to store the string table references
 meaning a better ratio than you'd ever obtain with lz77 can be achieved, at
 the expense of a much lower decoding speed on the other hand.
 
 the implementation is ripped out of an old c source code to an ms-dos program,
 i've additionally included 68000/68030 ports of the decoder that have been
 optimized for size, not speed. the compression method slightly differs from
 LZW, i.e. the first 256 string symbols will not get initialized prior to the
 decoding procedure so there shouldn't be any legal issues regarding unisys'
 patent on LZW (which expired in 2003/2004 anyway, iirc).

 the reason i've released this is that i was looking for a lightweigh depacker
 giving a decent ratio without having to rely on more or less complex methods
 on the encoder side like for instance RLE+Huffman or arithmetic coding while
 finishing my image codec called BIQ that should get released very soon, too.

 obviously there has been a bit of interest on a simple depacker which has a
 better ratio than lz77 or plain RLE while still giving a small depacker (atm.
 the decoder is roughly 160 bytes large) so i've released this in a seperate
 package.

 the data format is similar to the one of lz77, one longword holding the ori-
 ginal length followed by the encoded data stream. make sure to store packed
 files on an even byte boundary when using this code on a 68000 machine.

 the provided c-source should compile with Pure C and/or GNU C (uncomment
 #include <io.h> and comment #include <ext.h> in the letter case).

 usage should be straightforward and the same as in lz77, as follows:

 	lz78 p data.bin data.l78	; Encode data.bin -> data.l78
 	lz78 x data.l78 data.bin	; Depack data.l78 -> data.bin


 for depacking use one of 'lz78_000.s' or 'lz78_030.s' depending on
 your machine's CPU:

 	lea.l	data,a0		; lz78 packed soure data
 	lea.l	output,a1	; Make sure to reserve enought space
 	bsr.w	d_lz78		; for the destination array
	...
	

 have fun, if you have any questions or bug reports please send the via the
 usual way, i.e. ray(at)tscc(dot)de or irc->#atariscne->ray_tscc

- ray//.tSCc. ---------------------------------------------------- March 2006 -