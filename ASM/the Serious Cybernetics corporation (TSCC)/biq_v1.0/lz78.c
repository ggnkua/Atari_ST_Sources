#include <stdio.h>
#include <stdlib.h>
#include "defs.h"
#include "lz78.h"


void enLZ78(unsigned char * input, long len, FILE * output) {
	unsigned int next_code;
	unsigned int character;
	unsigned int string_code;
	unsigned int index;
	int i;

	/* Reserve table space */	
	code_value       = malloc(TABLE_SIZE*sizeof(unsigned int));
	prefix_code      = malloc(TABLE_SIZE*sizeof(unsigned int));
	append_character = malloc(TABLE_SIZE*sizeof(unsigned char));
	if (code_value==NULL || prefix_code==NULL || append_character==NULL) {
		printf("Failed to allocate lz78 tables.\n");
	   	return;
	}

	
	next_code=256;              /* Next code is the next available string code*/
	for (i=0;i<TABLE_SIZE;i++)  /* Clear out the string table before starting */
    	code_value[i]=-1;

	i=0;
	string_code=*input++;    /* Get the first code */
	
	/*
	   This is the main loop where it all happens.  This loop runs util all of
	   the input has been exhausted.  Note that it stops adding codes to the
	   table after all of the possible codes have been defined.
	*/
	while (--len) {
    
    	character = *input++;
    	
/*		if (++i==1000) {
			i=0;
			printf("%s");
		}*/
		
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

	/* Free up table space */	
	free(code_value);
	free(prefix_code);
	free(append_character);
}


int find_match(unsigned int hash_prefix, unsigned int hash_character) {
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


void deLZ78(FILE * input, uchar * output) {
	unsigned int next_code;
	unsigned int new_code;
	unsigned int old_code;
	int character;
	int counter;
	unsigned char * string;

	/* Reserve table space */	
	code_value       = malloc(TABLE_SIZE*sizeof(unsigned int));
	prefix_code      = malloc(TABLE_SIZE*sizeof(unsigned int));
	append_character = malloc(TABLE_SIZE*sizeof(unsigned char));
	if (code_value==NULL || prefix_code==NULL || append_character==NULL) {
		printf("Failed to allocate lz78 tables.\n");
	   	return;
	}
	
	next_code=256;		/* This is the next available code to define */
	counter=0;			/* Counter is used as a pacifier.            */


	old_code=input_code(input);		/* Read in the first code, initialize the */
	character=old_code;				/* character variable, and send the first */
	*output++ = old_code,output;	/* code to the output file                */
  
	/*
	  This is the main expansion loop.  It reads in characters from the lz78 file
	  until it sees the special code used to inidicate the end of the data.
	*/
	while ((new_code=input_code(input)) != (MAX_VALUE)) {

/*    	if (++counter==1000) {
    	  counter=0;
	      printf("*");
    	}
*/
    
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
	    while (string >= decode_stack) *output++ = *string--;
      
		/* Finally, if possible, add a new code to the string table. */
	    if (next_code <= MAX_CODE) {
    		prefix_code[next_code] = old_code;
			append_character[next_code++] = character;
	    }
    	old_code = new_code;
	}
	
	/* Free up table space */	
	free(code_value);
	free(prefix_code);
	free(append_character);
}


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


void output_code(FILE * output,unsigned int code) {

	output_bit_buffer |= (unsigned long) code << (32-BITS-output_bit_count);
	output_bit_count += BITS;
	while (output_bit_count >= 8) {
		putc((unsigned char)(output_bit_buffer >> 24),output);
		output_bit_buffer <<= 8;
		output_bit_count -= 8;
	}
}
