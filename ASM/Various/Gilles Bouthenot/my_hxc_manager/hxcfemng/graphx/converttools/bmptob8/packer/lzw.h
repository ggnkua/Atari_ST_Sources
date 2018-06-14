typedef unsigned char ubyte;
//typedef char byte;

typedef struct bit_file {
    ubyte *buf;
    int current_byte;
    ubyte mask;
    int rack;
    int pacifier_counter;
    int length;
} BIT_BUF;



ubyte *lzw_expand( ubyte *inputbuf, ubyte *outputbuf, int length );
ubyte *lzw_compress( ubyte *inputbuf, ubyte *outputbuf, int input_size, int *output_size );

