#include "HighWire.h"
	
void
destroy_paragraph_structure(struct paragraph_item *current_paragraph)
{	
	struct paragraph_item *temp;
	
	while(current_paragraph!=0)
	{
		if(current_paragraph->item!=0)
			destroy_word_structure(current_paragraph->item);
		temp=current_paragraph->next_paragraph;
		free(current_paragraph);
		current_paragraph=temp;
	}
}


struct paragraph_item *
new_paragraph(void)
{
	struct paragraph_item *temp;
	temp=(struct paragraph_item *) malloc(sizeof(struct paragraph_item));
	temp->item=new_word();
	temp->alignment=left;
	temp->paragraph_code=none;
	temp->left_border=0;
	temp->right_border=0;
	temp->eop_space=0;
	temp->current_paragraph_height=0;
	temp->next_paragraph=0;
	return(temp);
}

	
struct paragraph_item *
add_paragraph(struct paragraph_item *current_paragraph,struct word_item *current_word,short *active_word_buffer,short *active_word,short *minimum_width,short indent)
{
	struct paragraph_item *new_paragraph;
	struct word_item *new_word;

	word_store(current_word,active_word_buffer,active_word);
	*minimum_width=current_word->word_width+indent;

	new_word=(struct word_item *) malloc(sizeof(struct word_item));
	new_word->word_width=0;
	new_word->word_height=current_word->word_height;
	new_word->word_tail_drop=current_word->word_tail_drop;
	new_word->styles.bold=current_word->styles.bold;
	new_word->styles.italic=current_word->styles.italic;
	new_word->styles.underlined=current_word->styles.underlined;
	new_word->styles.strike=current_word->styles.strike;
	new_word->styles.font=current_word->styles.font;
	new_word->styles.font_size=current_word->styles.font_size;
	new_word->space_width=current_word->space_width;
	new_word->changed.style=false;
	new_word->changed.font=false;
	new_word->changed.colour=false;
	new_word->word_code=none;
	new_word->colour=current_word->colour;
	new_word->vertical_align=current_word->vertical_align;
	new_word->link=current_word->link;
	new_word->next_word=0;
	
	new_paragraph=(struct paragraph_item *) malloc(sizeof(struct paragraph_item));
	new_paragraph->item=new_word;
	new_paragraph->alignment=current_paragraph->alignment;
	new_paragraph->paragraph_code=none;
	new_paragraph->left_border=current_paragraph->left_border;
	new_paragraph->right_border=current_paragraph->right_border;
	new_paragraph->eop_space=0;
	new_paragraph->current_paragraph_height=0;
	new_paragraph->next_paragraph=0;
	current_paragraph->next_paragraph=new_paragraph;
	return(new_paragraph);
}

