				 lz77 v1.3 2k4/2k5, final version
				..................................

This archive contains an implementation of the *extremly fast decompressing* yet very effective
LZ77 algorithm, also referred to as LZSS. It is based upon the idea of encoding repeating strings
which can be looked up from a moving frame or ringbuffer during the decoding process making it
achive almost the same speed as an RLE-packer as it remains on a byte, word or longword level.
nonetheless, it's able to achieve the same/sometimes better ratios than plain huffman coding.

the algorithm's great simplicity allows to create a very smart decoder even fitting the 030's
code cache which makes it the ideal solution for animations and realtime media-decoders.

depending on your needs or to gain better compression results you can easily change the included
c/asm sources to (de)compress strings of words/longwords while now it processes strings of bytes
as in my opinion the implementation is quite intuitive.

the decoder is included in two seperate versions, for 68000 and 68030 CPUs. the commandline tool's
syntax works as follows:

 lz77 p infile.ext outfile.ext : Encode the given inputfile into 'outfile.ext'
 lz77 x infile.ext outfile.ext : Decrunch the given inputfile into 'outfile.ext'


The file format is build up as follows:

1 longword 	: original file size
1 byte		: compression tag for 8 units with each bit flagging
							0 for a literal byte to follow
							1 for an encoded string to follow

up to 8 bytes	: literal string

/

up to 8 times	: 2 bytes 'compression specifier'	1 byte : upper nibble = 
								 bits 11-8 string location

								 lower nibble =
								 length of the string - 2

							1 byte : bits 7-0 string location


  .
  .
  .


Look at the decoder for clearness. Credits have to go out to Haruhiko Okumura and Adisak Pochanayon
for developing the initial sources i tried to optimize and of course to Abraham Lempel and Jakob Ziv
for inventing this clever idea of compressing data this way :).

Thank you gwEm for helping me find the last bug!

If you have any further questions drop a line to ray@tscc.de