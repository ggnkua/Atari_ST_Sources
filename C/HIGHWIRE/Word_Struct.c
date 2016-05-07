#include "HighWire.h"

void
destroy_word_structure(struct word_item *current_word)
{	
	struct word_item *temp;
	
	while(current_word!=0)
	{
		if(current_word->item!=0)
			free(current_word->item);
		if(current_word->link!=0)
			free(current_word->link);
		temp=current_word->next_word;
		free(current_word);
		current_word=temp;
	}
}


struct word_item *
new_word(void)
{
	struct word_item *temp;
	temp=(struct word_item *) malloc(sizeof(struct word_item));
	temp->item=0;
	temp->styles.bold=0;
	temp->styles.italic=0;
	temp->styles.underlined=0;
	temp->styles.strike=0;
	temp->styles.font=normal_font;
	temp->styles.font_size=POINT_SIZE;
	temp->changed.font=true;
	temp->changed.style=true;
	temp->changed.colour=true;
	temp->word_code=none;
	temp->word_width=0;
	temp->word_height=0;
	temp->word_tail_drop=0;
	temp->space_width=0;
	temp->colour=text_colour;
	temp->link=0;
	temp->next_word=0;
	temp->vertical_align=bottom;
	return(temp);
}


struct word_item *
add_word(struct word_item *current_word,short *active_word_buffer, short *active_word, short *minimum_width,short indent)
{
	struct word_item *new;
	
	word_store(current_word,active_word_buffer,active_word);
	*minimum_width=current_word->word_width+indent;
	
	new=new_word();
	new->word_width=0;
	new->word_height=current_word->word_height;
	new->word_tail_drop=current_word->word_tail_drop;
	new->styles.bold=current_word->styles.bold;
	new->styles.italic=current_word->styles.italic;
	new->styles.underlined=current_word->styles.underlined;
	new->styles.strike=current_word->styles.strike;
	new->styles.font=current_word->styles.font;
	new->styles.font_size=current_word->styles.font_size;
	new->space_width=current_word->space_width;
	new->changed.style=false;
	new->changed.font=false;
	new->changed.colour=false;
	new->word_code=none;
	new->colour=current_word->colour;
	new->vertical_align=current_word->vertical_align;
	new->link=current_word->link;
	new->next_word=0;
	current_word->next_word=new;
	return(new);
}

