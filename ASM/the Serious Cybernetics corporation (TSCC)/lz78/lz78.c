/*****************************************************************************
**
**                           lz78 packer v1.0
**
** Copyright (c) 1989 Mark R. Nelson
**
** lz78 data compression/expansion demonstration program.
**
** April 13, 1989
** Modifications by ray//.tSCc.  February, 2006
**
*****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <ext.h>
/*#include <io.h>*/
#include <string.h>
#include <ctype.h>

#define BITS 12						/* Setting the number of bits to 12, 13 */
#define HASHING_SHIFT BITS-8		/* or 14 affects several constants.     */
#define MAX_VALUE (1 << BITS) - 1	/* Note that MS-DOS machines need to    */
#define MAX_CODE MAX_VALUE - 1		/* compile their code in large model if */
									/* 14 bits are selected.                */
#if BITS == 14
	#define TABLE_SIZE 18041		/* The string table size needs to be a  */
#endif								/* prime number that is somewhat larger */
#if BITS == 13						/* than 2^BITS.                         */
	#define TABLE_SIZE 9029
#endif
#if BITS <= 12
	#define TABLE_SIZE 5021
#endif

#define STACK_LEN 4096


int * code_value;					/* This is the code value array        */
unsigned int * prefix_code;			/* This array holds the prefix codes   */
unsigned char * append_character;	/* This array holds the appended chars */
unsigned char decode_stack[STACK_LEN];	/* This array holds the decoded string */


unsigned char * decode_string(unsigned char * buffer,unsigned int code);
void output_code(FILE * output,unsigned int code);
int find_match(int hash_prefix,unsigned int hash_character);
int input_code(FILE * input);

/*
	This is the compression routine.  The code should be a fairly close
	match to the algorithm accompanying the article.
*/
void compress(FILE * input,FILE * output) {
	unsigned int next_code;
	unsigned int character;
	unsigned int string_code;
	unsigned int index;
	int i;
	
	/* Write original file length */
	long int flen = filelength(fileno(input));
	putc((unsigned char)(flen >> 24),output);
	putc((unsigned char)(flen >> 16),output);
	putc((unsigned char)(flen >> 8),output);
	putc((unsigned char)flen,output);			

	next_code=256;              /* Next code is the next available string code*/
	for (i=0;i<TABLE_SIZE;i++)  /* Clear out the string table before starting */
    	code_value[i]=-1;

	i=0;
	string_code=getc(input);    /* Get the first code */
	
	/*
	   This is the main loop where it all happens.  This loop runs util all of
	   the input has been exhausted.  Note that it stops adding codes to the
	   table after all of the possible codes have been defined.
	*/
	while ((character=getc(input)) != (unsigned)EOF) {
    
		if (++i==1000) {
			i=0;
			printf("*");
		}
		
		index=find_match(string_code,character);	/* See if the string is in */
		if (code_value[index] != -1)				/* the table.  If it is,   */
			string_code=code_value[index];        	/* get the code value.  If */
		else                                    	/* the string is not in the*/
		{                                       	/* table, try to add it.   */
			if (next_code <= MAX_CODE) {
				code_value[index]=next_code++;
				prefix_code[index]=string_code;
				append_character[index]=character;
			}
			output_code(output,string_code);	/* When a string is found  */
			string_code=character;				/* that is not in the table*/
		}										/* I output the last string*/
	}											/* after adding the new one*/
	
	/* End of the main loop. */
	output_code(output,string_code); /* Output the last code */
	output_code(output,MAX_VALUE);   /* Output the end of buffer code */
	output_code(output,0);           /* This code flushes the output buffer */
}


/*
	This is the hashing routine.  It tries to find a match for the prefix+char
	string in the string table.  If it finds it, the index is returned.  If
	the string is not found, the first available index in the string table is
	returned instead.
*/
int find_match(int hash_prefix,unsigned int hash_character) {
	int index;
	int offset;

	index = ((hash_character << (HASHING_SHIFT)) ^ hash_prefix);
	if (index == 0)
    	offset = 1;
	  else
    	offset = TABLE_SIZE - index;
	while (1) {
		if (code_value[index] == -1)
			return(index);
	    if (prefix_code[index] == hash_prefix && 
        	append_character[index] == hash_character)
			return(index);
		index -= offset;
		if (index < 0)
			index += TABLE_SIZE;
	}
}


/*
	This is the expansion routine.  It takes an lz78 format file, and expands
	it to an output file.  The code here should be a fairly close match to
	the algorithm in the accompanying article.
*/
void expand(FILE * input,FILE * output) {
	unsigned int next_code;
	unsigned int new_code;
	unsigned int old_code;
	int character;
	int counter;
	unsigned char * string;

	/* Skip original length */
	getc(input);
	getc(input);
	getc(input);
	getc(input);			

	next_code=256;           /* This is the next available code to define */
	counter=0;               /* Counter is used as a pacifier.            */


	old_code=input_code(input);  /* Read in the first code, initialize the */
	character=old_code;          /* character variable, and send the first */
	putc(old_code,output);       /* code to the output file                */
  
	/*
	  This is the main expansion loop.  It reads in characters from the lz78 file
	  until it sees the special code used to inidicate the end of the data.
	*/
	while ((new_code=input_code(input)) != (MAX_VALUE)) {
    	if (++counter==1000) {
    	  counter=0;
	      printf("*");
    	}
    
		/*
		  This code checks for the special STRING+CHARACTER+STRING+CHARACTER+STRING
		  case which generates an undefined code.  It handles it by decoding
		  the last code, and adding a single character to the end of the decode string.
		*/
	    if (new_code >= next_code) {
	    	*decode_stack = character;
    		string=decode_string(decode_stack+1,old_code);
	    }
		/* Otherwise we do a straight decode of the new code. */
	    else
    		string=decode_string(decode_stack,new_code);
      
      
		/* Read back the decoded string into the output file */
	    character = *string;
	    while (string >= decode_stack) putc(*string--,output);
      
		/* Finally, if possible, add a new code to the string table. */
	    if (next_code <= MAX_CODE) {
    		prefix_code[next_code] = old_code;
			append_character[next_code++] = character;
	    }
    	old_code = new_code;
	}
}


/*
	Reversely decode a string from the append table.
*/
unsigned char * decode_string(unsigned char * buffer,unsigned int code) {
	int i;

	i=0;
	while (code > 255) {
		*buffer++ = append_character[code];
		code=prefix_code[code];
		if (i++ >= MAX_CODE) {
			printf("Fatal error during code expansion.\n");
			return NULL;
		}
	}
	*buffer = code;
	return(buffer);
}


/*
	Read a variable length bitfield from the given file
*/

static int input_bit_count=0;
static unsigned long input_bit_buffer=0L;

int input_code(FILE * input) {
	unsigned int return_value;

	while (input_bit_count <= 24) {
    	input_bit_buffer |= (unsigned long) getc(input) << (24-input_bit_count);
		input_bit_count += 8;
	}
	return_value=(unsigned int)(input_bit_buffer >> (32-BITS));
	input_bit_buffer <<= BITS;
	input_bit_count -= BITS;
	return(return_value);
}


/*
	Write a variable length bitfield to the given file
*/

static int output_bit_count=0;
static unsigned long output_bit_buffer=0l;

void output_code(FILE * output,unsigned int code) {

	output_bit_buffer |= (unsigned long) code << (32-BITS-output_bit_count);
	output_bit_count += BITS;
	while (output_bit_count >= 8) {
		putc((unsigned char)(output_bit_buffer >> 24),output);
		output_bit_buffer <<= 8;
		output_bit_count -= 8;
	}
}



/*
	Main program.
*/

int main(int argc, char * argv[]) {
	FILE * infile;
	FILE * outfile;
	char *s;

	code_value=malloc(TABLE_SIZE*sizeof(unsigned int));
	prefix_code=malloc(TABLE_SIZE*sizeof(unsigned int));
	append_character=malloc(TABLE_SIZE*sizeof(unsigned char));
	if (code_value==NULL || prefix_code==NULL || append_character==NULL) {
		printf("Fatal error allocating table space!\n");
    	return 0;
	}
  
  
	printf("Ep LZ78 packer  v1.0  ½ Mark R. Nelson, ray//.tSCc. 1989, 2006 q\n\n");
	
	/* Check cdl */
	if ((argc != 4) || (s=argv[1], s[1] || strpbrk(s, "pPxX") == NULL) ) {
		printf("Useage: lz78 switch infile.ext outfile.ext\n\n");
		printf("Valid switches are:\n");
		printf("  p (compress input file)\n");
		printf("  x (extact input file)\n\n");
		return 0;
	}
	
	if ((s = argv[2], (infile  = fopen(s, "rb")) == NULL)||
	    (s = argv[3], (outfile = fopen(s, "wb")) == NULL)) {
		printf("Failed to open %s\n", s);  return 0;
	}
	if (toupper(*argv[1]) == 'P') {
		printf("Deflating %s: ", argv[2]);
		compress(infile,outfile); 
	} else {
		printf("Inflating %s: ", argv[2]);
		expand(infile,outfile);
	}
	
	printf("\nok.\n");
	fclose(infile);fclose(outfile);  
	free(code_value);
	free(prefix_code);
	free(append_character);

	return 0;
}
