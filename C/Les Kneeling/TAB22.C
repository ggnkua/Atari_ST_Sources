/* A 22-line utility for replacing tabs with spaces in files for the ST User
   disk magazine - by Les Kneeling */
#include <stdio.h>
FILE *input, *output;
main( argc, argv ) int argc; char **argv; {
if( argc != 3 ){ puts("Use TAB22 INFILE.EXT OUTFILE.EXT"); getchar(); }
else    {   input = fopen( argv[1], "br" );
            if( input != 0l ) { output = fopen( argv[2], "bw" );
                                if( output != 0l ) convert();fclose( input ); }
if( output != 0l) fclose( output ); }   
}
convert() { int out_count = 0; char offset, oc, letter;
letter = fgetc( input );
while( !feof( input ) ) {
    if( letter == 9 ){  offset = 4-(out_count%4);
                        for (oc=0; oc < offset ; oc++)  fputc( 32, output );
                        out_count += offset;    }
    else if( letter == 0x0a ){  fputc( letter, output );    out_count = 0;}
    else{   fputc( letter, output );    out_count++;    }
    if( out_count > 79 ){   fputc( 13, output );    out_count = 0;  }
    letter = fgetc( input );    }
}

