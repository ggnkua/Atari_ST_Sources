#include <string.h>
#include <aes.h>

#include "HighWire.h"

void
variable(char *start_symbol, char *search_string, char *out)
{
	char buffer[100],*symbol_position,*extract_position;
	short search_string_length;
	
	search_string_length=strlen(search_string);
	
	symbol_position=start_symbol;
	while(*symbol_position!=' ')
		symbol_position++;
	symbol_position++;
	
	*out='!';
	*(out+1)='\0';
	for(;;)
	{
		symbol_position=stptok(symbol_position,buffer,100," >");
		if(*buffer!='\0' && strnicmp(buffer,search_string,search_string_length)==0)
		{
			extract_position=strchr(buffer,'=');
			if(extract_position=='\0')
				*out='*';
			else
				strcpy(out,extract_position+1);
			return;
		}
		if(*symbol_position=='>')
			return;
		while(*symbol_position==' ')
			symbol_position++;
		symbol_position++;
	}
}	

short
convert_to_number(const char *text)
{
	long length_of_text,value;
	
	length_of_text=stcd_i(text,&value);
	if(*(text+length_of_text)=='%')
		value=-value;
	return(value);
}

void
word_store(struct word_item *current_word, short *active_word_buffer,short *active_word)
{
	short pts[8],string_length;

	*active_word=0;
	for(string_length=0;active_word_buffer[string_length]!=0;string_length++);
	string_length++;
	current_word->item=(short *)malloc(string_length*2);
	memcpy(current_word->item,active_word_buffer,string_length*2);
		
	vqt_f_extent16(vdi_handle,current_word->item,pts);
	current_word->word_width+=pts[2]-pts[0];
}

short
map(char symbol)
{
	if(symbol==' ')
		return(Space_Code);
	return((short)(symbol-32));
}

short
list_indent(short type)
{
	switch(type)
	{
		case 0:
			return(POINT_SIZE*2);
		case 1:
			return(POINT_SIZE*3);
		case 2:
			return(POINT_SIZE*4);
	}
	return(0);
}

short
special_char_map(short input)
{
	short output;
	
	switch(input)
	{
		case 160:
			output=Space_Code;break;
		case 161:
			output=388;break;
		case 162:
			output=128;break;
		case 163:
			output=97;break;
		case 164:			
			output=278;break;
		case 165:
			output=274;break;
		case 166:
			output=277;break;
		case 167:
			output=110;break;
		case 168:
			output=135;break;
		case 169:
			output=332;break;
		case 170:
			output=538;break;
		case 171:
			output=125;break;
		case 172:
			output=309;break;
		case 173:
			output=111;break;
		case 174:
			output=333;break;
		case 175:
			output=230;break;
		case 176:
			output=146;break;
		case 177:
			output=286;break;
		case 178:
			output=160;break;
		case 179:
			output=161;break;
		case 180:
			output=129;break;
		case 181:
			output=325;break;
		case 182:
			output=279;break;
		case 183:
			output=102;break;
		case 184:
			output=141;break;
		case 185:
			output=159;break;
		case 186:
			output=147;break;
		case 187:
			output=126;break;
		case 188:
			output=225;break;
		case 189:
			output=226;break;
		case 190:
			output=227;break;
		case 191:
			output=127;break;
		case 192:
			output=259;break;
		case 193:
			output=261;break;
		case 194:
			output=257;break;
		case 195:
			output=253;break;
		case 196:
			output=255;break;
		case 197:
			output=113;break;
		case 198:
			output=114;break;
		case 199:
			output=199;break;
		case 200:
			output=249;break;
		case 201:
			output=251;break;
		case 202:
			output=247;break;
		case 203:
			output=245;break;
		case 204:
			output=239;break;
		case 205:
			output=241;break;
		case 206:
			output=237;break;
		case 207:
			output=235;break;
		case 208:
			output=169;break;
		case 209:
			output=196;break;
		case 210:
			output=202;break;
		case 211:
			output=200;break;
		case 212:
			output=204;break;
		case 213:
			output=208;break;
		case 214:
			output=206;break;
		case 215:
			output=284;break;
		case 216:
			output=115;break;
		case 217:
			output=212;break;
		case 218:
			output=210;break;
		case 219:	
			output=214;break;
		case 220:
			output=216;break;
		case 221:
			output=224;break;
		case 222:
			output=272;break;
		case 223:
			output=121;break;
		case 224:
			output=260;break;
		case 225:
			output=262;break;
		case 226:
			output=258;break;
		case 227:
			output=254;break;
		case 228:	
			output=256;break;
		case 229:
			output=117;break;
		case 230:
			output=118;break;
		case 231:
			output=149;break;
		case 232:
			output=250;break;
		case 233:
			output=252;break;
		case 234:
			output=248;break;
		case 235:
			output=246;break;
		case 236:
			output=240;break;
		case 237:
			output=242;break;
		case 238:
			output=238;break;
		case 239:
			output=236;break;
		case 240:
			output=273;break;
		case 241:
			output=195;break;
		case 242:
			output=201;break;
		case 243:
			output=199;break;
		case 244:
			output=203;break;
		case 245:
			output=207;break;
		case 246:
			output=205;break;
		case 247:
			output=285;break;
		case 248:
			output=110;break;
		case 249:
			output=211;break;
		case 250:
			output=209;break;
		case 251:
			output=213;break;
		case 252:
			output=215;break;
		case 253:
			output=223;break;
		case 254:
			output=271;break;
		case 255:
			output=221;break;
	}
	return(output);
}
	
	
struct word_item *
list_marker(struct word_item *current_word,struct list_stack_item *current_list,short *minimum_width,short indent)
{
	short modulo=0,count,word[5],*active_word,indent_type=0;
	struct word_item *new_word;
	
	active_word=word;
	if(current_list==0)
		return(current_word);
	count=current_list->current_list_count;	
	switch(current_list->bullet_style)
	{
		case disc:
			*active_word=342;
			active_word++;
			indent_type=0;
			break;
		case square:
			*active_word=559;
			active_word++;
			indent_type=0;
			break;
		case circle:
			*active_word=353;
			active_word++;
			indent_type=0;
			break;
		case Number:
			while(count>9)
			{	count-=10;
				modulo++;}
			if(modulo!=0)
			{	*active_word=map(modulo+48);
				active_word++;}
			*active_word=map(count+48);
			active_word++;
			*active_word=14;
			active_word++;
			current_list->current_list_count++;
			indent_type=1;
			break;
		case Alpha:
			while(count>26)
			{	count-=26;
				modulo++;}
			if(modulo!=0)
			{	*active_word=map(modulo+64);
				active_word++;}
			*active_word=map(count+64);
			active_word++;
			*active_word=14;
			active_word++;
			current_list->current_list_count++;
			indent_type=1;
			break;
		case alpha:
			while(count>26)
			{	count-=26;
				modulo++;}
			if(modulo!=0)
			{	*active_word=map(modulo+96);
				active_word++;}
			*active_word=map(count+96);
			active_word++;
			*active_word=14;
			active_word++;
			current_list->current_list_count++;
			indent_type=1;
			break;
		case roman:
		case Roman:
			break;
	}
	new_word=add_word(current_word,word,active_word,minimum_width,indent);
	current_word->word_width=list_indent(indent_type);
	if(current_word->word_width+indent>*minimum_width)
		*minimum_width=current_word->word_width+indent;
	return(new_word);
}
		

struct paragraph_item
*calculate_frame(char *symbol,short *minimum_width)
{
	struct paragraph_item *start,*current_paragraph;
	struct word_item *current_word;
	struct list_stack_item *current_list,*temp_list_holder;
	struct font_step *current_font_step;
	short u,current_font_size,font_step;
	enum bool space_found=false,code_processed=false;
	char output[100],*start_symbol;
	short active_word_buffer[100],*active_word;
	short distances[5],effects[3];
	short current_indent_distance=0;
	
	start_symbol=symbol;
	if(symbol==0)
		return(new_paragraph());
	
	start=current_paragraph=new_paragraph();
	current_word=current_paragraph->item;
	active_word=active_word_buffer;
	current_list=0;
	wind_update(BEG_UPDATE);
	graf_mouse(2,0);
	wind_update(END_UPDATE);
	
	current_highlighted_link_area=0;
	
	vst_font(vdi_handle,fonts[0][0][0]);
	current_font_size=POINT_SIZE;
	current_font_step=new_step(3);
	font_step=current_font_size/current_font_step->step;
	vst_arbpt(vdi_handle,current_font_size,&u,&u,&u,&u);
	vqt_advance(vdi_handle,Space_Code,&current_word->space_width,&u,&u,&u);
	
	vqt_fontinfo(vdi_handle,&u,&u,distances,&u,effects);
	current_word->word_height=distances[3];
	current_word->word_tail_drop=distances[1];
	
	while(*symbol !='\0')
	{
		switch(*symbol)
		{
			case '<':
				code_processed=true;
				current_word=add_word(current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
				active_word=active_word_buffer;
				symbol++;
				switch(*symbol)
				{	case '\0':
						symbol--;
						break;
					case '!':
						while(*(symbol+1) != '>' && *(symbol+1) != '\0')
							symbol++;
						break;
						
					case 'a':
					case 'A':
						variable(symbol,"href",output);
						if(*output!='!')
						{
							current_word->colour=link_colour;
							current_word->changed.colour=true;
							if(*output==186 || *output=='"')
							{
								output[strlen(output)-1]='\0';
								current_word->link=new_url_link(output+1,href);
							}
							else
							{
								current_word->link=new_url_link(output,href);
							}
						}
						else
						{
							variable(symbol,"name",output);
							if(*output!='!')
							{
								if(*output==186 || *output=='"')
								{
									output[strlen(output)-1]='\0';
									current_word->link=new_url_link(output+1,name);
								}
								else
								{
									current_word->link=new_url_link(output,name);
								}
							}
						}
						break;
					case 'b':
					case 'B':
						switch(*(symbol+1))
						{
							case 'a':
							case 'A':
								variable(symbol,"size",output);
								if(*output!='!')
								{
									current_font_step=add_step(current_font_step);
									current_font_step->step=convert_to_number(output);
									current_font_size=current_font_step->step*font_step;
									current_word->styles.font_size=current_font_size;
									current_word->changed.font=true;
								}
								break;	
							case 'i':
							case 'I':
								current_word->styles.font_size=current_font_size*3/2;
								current_word->changed.font=true;
								break;
							case 'r':
							case 'R':
								current_word->word_code=br;
								break;
							case ' ':
							case '>':
								current_word->styles.bold++;
								if(current_word->styles.bold==1)
									current_word->changed.font=true;
								break;
						}
						break;
					case 'c':
					case 'C':
						switch(*(symbol+1))
						{
							case ' ':
							case '>':
							case 'e':
							case 'E':
								current_paragraph->eop_space=-current_word->word_height;
								current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
								current_word=current_paragraph->item;
								active_word=active_word_buffer;
								current_paragraph->alignment=center;
								break;
							case 'i':
							case 'I':
								current_word->styles.italic++;
								if(current_word->styles.italic==1)
									current_word->changed.font=true;
								break;
							case 'o':
							case 'O':
								current_word->styles.font=pre_font;
								current_word->changed.font=true;
								break;
						}
						break;
					case 'D':
					case 'd':
						switch(*(symbol+1))
						{
							case 'f':
							case 'F':
								current_word->styles.italic++;
								if(current_word->styles.italic==1)
									current_word->changed.font=true;
								break;
							case 'I':
							case 'i':
								switch(*(symbol+2))
								{
									case 'r':
									case 'R':
										current_paragraph->eop_space=-current_word->word_height;
										current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
										current_word=current_paragraph->item;
										active_word=active_word_buffer;
										current_paragraph->alignment=left;
										current_paragraph->left_border+=list_indent(0);
										current_indent_distance=current_paragraph->left_border;
										temp_list_holder=new_stack_list_item();
										temp_list_holder->next_stack_item=current_list;
										if(current_list!=0)
											temp_list_holder->bullet_style=(current_list->bullet_style+1) % 3;
										current_list=temp_list_holder;
										break;
									case 'v':
									case 'V':
										current_paragraph->eop_space=-current_word->word_height;
										current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
										current_word=current_paragraph->item;
										active_word=active_word_buffer;
										variable(symbol,"align",output);
										switch(*output)
										{	case 'r': case 'R': current_paragraph->alignment=right; break;
											case 'c': case 'C': current_paragraph->alignment=center; break;
											case 'l': case 'L': current_paragraph->alignment=left;break;}
										break;
								}
								break;
							case 'l':
							case 'L':
								current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
								current_word=current_paragraph->item;
								active_word=active_word_buffer;
								current_paragraph->alignment=left;
								current_paragraph->eop_space=0;
								current_paragraph->left_border+=list_indent(2);
								current_indent_distance=current_paragraph->left_border;
								break;
							case 't':
							case 'T':
								current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
								current_word=current_paragraph->item;
								active_word=active_word_buffer;
								current_paragraph->alignment=left;
								current_paragraph->eop_space=0;
								current_paragraph->left_border-=list_indent(2);
								current_indent_distance=current_paragraph->left_border;
								break;
							case 'd':
							case 'D':
								current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
								current_word=current_paragraph->item;
								active_word=active_word_buffer;
								current_paragraph->alignment=left;
								current_paragraph->left_border+=list_indent(2);
								current_indent_distance=current_paragraph->left_border;
								current_paragraph->eop_space=0;
								break;
								
						}
						break;
					case 'e':
					case 'E':
						current_word->styles.italic++;
						if(current_word->styles.italic==1)
							current_word->changed.font=true;
						break;
					case 'f':
					case 'F':
						variable(symbol,"size",output);
						if(*output!='!')
						{
							current_font_step=add_step(current_font_step);
							if(*output == '+' || *output == '-')
								current_font_step->step+=convert_to_number(output);
							else
								current_font_step->step=convert_to_number(output);
							current_font_size=current_font_step->step*font_step;
							current_word->styles.font_size=current_font_size;
							current_word->changed.font=true;
						}
						break;	
					case 'h':
					case 'H':
						switch(*(symbol+1))
						{
							case 'r':
							case 'R':
								current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
								current_word=current_paragraph->item;
								active_word=active_word_buffer;
								current_paragraph->paragraph_code=hr;
								current_paragraph->paragraph_code=hr;
								variable(symbol,"align",output);
								switch(*output)
								{
									case 'r':
									case 'R':
										current_paragraph->eop_space=2;
										break;
									case 'c':
									case 'C':
										current_paragraph->eop_space=1;
										break;
									default:
										current_paragraph->eop_space=0;
								}
								variable(symbol,"width",output);
								if(*output!='!')
									current_word->word_width=convert_to_number(output);
								else
									current_word->word_width=-66;
								variable(symbol,"size",output);
								if(*output!='!')
									current_word->word_height=convert_to_number(output);
								else
									current_word->word_height=2;
								variable(symbol,"noshade",output);
								if(*output=='*')
									current_word->word_height=-current_word->word_height;
								current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
								current_word=current_paragraph->item;
								active_word=active_word_buffer;
								break;
							case '1':
								current_paragraph->eop_space=current_font_size/2;
								current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
								current_word=current_paragraph->item;
								active_word=active_word_buffer;
								variable(symbol,"align",output);
								switch(*output)
								{	case 'r': case 'R': current_paragraph->alignment=right; break;
									case 'c': case 'C': current_paragraph->alignment=center; break;
									case 'l': case 'L': current_paragraph->alignment=left;}
								current_word->styles.font=header_font;
								current_word->styles.font_size=2*current_font_size;
								current_word->changed.font=true;
								break;
							case '2':
								current_paragraph->eop_space=current_font_size/2;
								current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
								current_word=current_paragraph->item;
								active_word=active_word_buffer;
								variable(symbol,"align",output);
								switch(*output)
								{	case 'r': case 'R': current_paragraph->alignment=right; break;
									case 'c': case 'C': current_paragraph->alignment=center; break;
									case 'l': case 'L': current_paragraph->alignment=left;}
								current_word->styles.font=header_font;
								current_word->styles.font_size=current_font_size+(current_font_size/2);
								current_word->changed.font=true;
								break;
							case '3':
								current_paragraph->eop_space=current_font_size/2;
								current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
								current_word=current_paragraph->item;
								active_word=active_word_buffer;
								variable(symbol,"align",output);
								switch(*output)
								{	case 'r': case 'R': current_paragraph->alignment=right; break;
									case 'c': case 'C': current_paragraph->alignment=center; break;
									case 'l': case 'L': current_paragraph->alignment=left;}
								current_word->styles.font=header_font;
								current_word->styles.font_size=current_font_size+(current_font_size/4);
								current_word->changed.font=true;
								break;
							case '4':
								current_paragraph->eop_space=current_font_size/2;
								current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
								current_word=current_paragraph->item;
								active_word=active_word_buffer;
								variable(symbol,"align",output);
								switch(*output)
								{	case 'r': case 'R': current_paragraph->alignment=right; break;
									case 'c': case 'C': current_paragraph->alignment=center; break;
									case 'l': case 'L': current_paragraph->alignment=left;}
								current_word->styles.font=header_font;
								current_word->styles.font_size=current_font_size;
								current_word->changed.font=true;
								break;
							case '5':
								current_paragraph->eop_space=current_font_size/2;
								current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
								current_word=current_paragraph->item;
								active_word=active_word_buffer;
								variable(symbol,"align",output);
								switch(*output)
								{	case 'r': case 'R': current_paragraph->alignment=right; break;
									case 'c': case 'C': current_paragraph->alignment=center; break;
									case 'l': case 'L': current_paragraph->alignment=left;}
								current_word->styles.font=header_font;
								current_word->styles.font_size=current_font_size-(current_font_size/5);
								current_word->changed.font=true;
								break;
							case '6':
								current_paragraph->eop_space=current_font_size/2;
								current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
								current_word=current_paragraph->item;
								active_word=active_word_buffer;
								variable(symbol,"align",output);
								switch(*output)
								{	case 'r': case 'R': current_paragraph->alignment=right; break;
									case 'c': case 'C': current_paragraph->alignment=center; break;
									case 'l': case 'L': current_paragraph->alignment=left;}
								current_word->styles.font=header_font;
								current_word->styles.font_size=current_font_size-(current_font_size/3);
								current_word->changed.font=true;
								break;
						}
						break;
					case 'i':
					case 'I':
						switch(*(symbol+1))
						{
							case ' ':
							case '>':
								current_word->styles.italic++;
								if(current_word->styles.italic==1)
									current_word->changed.font=true;
								break;
						}
						break;
						
					case 'k':
					case 'K':
						current_word->styles.font=pre_font;
						current_word->changed.font=true;
						break;
					case 'l':
					case 'L':
						switch(*(symbol+1))
						{
							case 'i':
							case 'I':
								current_word->word_code=br;
								variable(symbol,"type",output);
								switch(*output)
								{
									case 'a':
										current_list->bullet_style=alpha;
										break;
									case 'A':
										current_list->bullet_style=Alpha;
										break;
									case 'i':
										current_list->bullet_style=roman;
										break;
									case 'I':
										current_list->bullet_style=Roman;
										break;
									case '1':
										current_list->bullet_style=Number;
										break;
									case 'd':
									case 'D':
										current_list->bullet_style=disc;
										break;
									case 'c':
									case 'C':
										current_list->bullet_style=circle;
										break;
									case 's':
									case 'S':
										current_list->bullet_style=square;
										break;
								}
								variable(symbol,"value",output);
								if(*output!='!')
									current_list->current_list_count=convert_to_number(output);
								current_word->styles.font_size=2*font_step;
								current_word->changed.font=true;
								current_word=list_marker(current_word,current_list,minimum_width,current_indent_distance);
								active_word=active_word_buffer;
								current_word->styles.font_size=current_font_step->step*font_step;
								current_word->changed.font=true;
								space_found=true;
								break;
						}
						break;
					case 'm':
					case 'M':
						switch(*(symbol+2))
						{
							case 'n':
							case 'N':
								current_paragraph->eop_space=-current_word->word_height;
								current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
								current_word=current_paragraph->item;
								active_word=active_word_buffer;
								current_paragraph->alignment=left;
								current_paragraph->left_border+=list_indent(0);
								current_indent_distance=current_paragraph->left_border;
								temp_list_holder=new_stack_list_item();
								temp_list_holder->next_stack_item=current_list;
								if(current_list!=0)
									temp_list_holder->bullet_style=(current_list->bullet_style+1) % 3;
								current_list=temp_list_holder;
								break;
						}
						break;
					case 'o':
					case 'O':
						switch(*(symbol+1))
						{
							case 'l':
							case 'L':
								current_paragraph->eop_space=-current_word->word_height;
								current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
								current_word=current_paragraph->item;
								active_word=active_word_buffer;
								current_paragraph->alignment=left;
								current_paragraph->left_border+=list_indent(1);
								current_indent_distance=current_paragraph->left_border;
								temp_list_holder=new_stack_list_item();
								temp_list_holder->next_stack_item=current_list;
								current_list=temp_list_holder;
								variable(symbol,"type",output);
								switch(*output)
								{
									case 'a':
										current_list->bullet_style=alpha;
										break;
									case 'A':
										current_list->bullet_style=Alpha;
										break;
									case 'i':
										current_list->bullet_style=roman;
										break;
									case 'I':
										current_list->bullet_style=Roman;
										break;
									default:
										current_list->bullet_style=Number;
								}
								variable(symbol,"start",output);
								if(*output!='!')
									current_list->current_list_count=convert_to_number(output);
								else
									current_list->current_list_count=1;
							break;
						}
						break;
					case 'p':
					case 'P':
						switch(*(symbol+1))
						{
							case ' ':
							case '>':
								current_paragraph->eop_space=current_font_size/2;
								current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
								current_word=current_paragraph->item;
								active_word=active_word_buffer;
								variable(symbol,"align",output);
								switch(*output)
								{	case 'r': case 'R': current_paragraph->alignment=right; break;
									case 'c': case 'C': current_paragraph->alignment=center; break;
									case 'l': case 'L': current_paragraph->alignment=left;}
								break;
						}
						break;
					case 's':
					case 'S':
						switch(*(symbol+1))
						{
							case ' ':
							case '>':
								current_word->styles.strike++;
								current_word->changed.style=true;
								break;
							case 'a':
							case 'A':
								current_word->styles.font=pre_font;
								current_word->changed.font=true;
								break;
							case 'm':
							case 'M':
								current_word->styles.font_size=current_font_size*2/3;
								current_word->changed.font=true;
								break;
							case 'T':
							case 't':
								switch(*(symbol+3))
								{
									case 'I':
									case 'i':
										current_word->styles.strike++;
										current_word->changed.style=true;
										break;
									case 'o':
									case 'O':
										current_word->styles.bold++;
										if(current_word->styles.bold==1)
											current_word->changed.font=true;
										break;
								}
								break;
							case 'u':
							case 'U':
								switch(*(symbol+2))
								{
									case 'b':
									case 'B':
										current_word->styles.font_size=current_font_size*2/3;
										current_word->vertical_align=below;
										break;
									case 'P':
									case 'p':
										current_word->styles.font_size=current_font_size*2/3;
										current_word->vertical_align=above;
										break;
								}
								break;
						}
						break;
					case 't':
					case 'T':
						switch(*(symbol+1))
						{
							case 't':
							case 'T':
								current_word->styles.font=pre_font;
								current_word->changed.font=true;
								break;
							case 'i':
							case 'I':
								while(*symbol!='<' && *symbol!='\0')
									symbol++;
								break;
						}
						break;
					case 'u':
					case 'U':
						switch(*(symbol+1))
						{
							case ' ':
							case '>':
								current_word->styles.underlined++;
								current_word->changed.style=true;
								break;
							case 'l':
							case 'L':
								current_paragraph->eop_space=-current_word->word_height;
								current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
								current_word=current_paragraph->item;
								active_word=active_word_buffer;
								current_paragraph->alignment=left;
								current_paragraph->left_border+=list_indent(0);
								current_indent_distance=current_paragraph->left_border;
								temp_list_holder=new_stack_list_item();
								temp_list_holder->next_stack_item=current_list;
								variable(symbol,"type",output);
								switch(*output)
								{
									case 'S':
									case 's':
										temp_list_holder->bullet_style=square;
										break;
									case 'c':
									case 'C':
										temp_list_holder->bullet_style=circle;
										break;
									case 'd':
									case 'D':
										temp_list_holder->bullet_style=disc;
									default:
									if(current_list!=0)
										temp_list_holder->bullet_style=(current_list->bullet_style+1) % 3;
								}
								current_list=temp_list_holder;
								break;
						}
						break;
					case 'v':
					case 'V':
						current_word->styles.italic++;
						if(current_word->styles.italic==1)
							current_word->changed.font=true;
						break;
						
					// ***********************	
						
					case '/':
						symbol++;
						switch(*symbol)
						{	case '\0':
								symbol--;
								break;
							case 'a':
							case 'A':
								current_word->colour=text_colour;
								current_word->link=0;
								current_word->changed.colour=true;
								break;
							case 'b':
							case 'B':
								switch(*(symbol+1))
								{
									case 'i':
									case 'I':
										current_word->styles.font_size=current_font_size;
										current_word->changed.font=true;
										break;
									case ' ':
									case '>':
										if(current_word->styles.bold !=0)
										{
											current_word->styles.bold--;
											if(current_word->styles.bold==0)
												current_word->changed.font=true;
										}
										break;
								}
								break;
							case 'c':
							case 'C':
								switch(*(symbol+1))
								{
									case ' ':
									case '>':
									case 'e':
									case 'E':
										current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
										current_word=current_paragraph->item;
										active_word=active_word_buffer;
										current_paragraph->alignment=0;
										break;
									case 'i':
									case 'I':
										if(current_word->styles.italic!=0)
										{
											current_word->styles.italic--;
											if(current_word->styles.italic==0)
												current_word->changed.font=true;
										}
										break;
									case 'o':
									case 'O':
										current_word->styles.font=normal_font;
										current_word->changed.font=true;
										break;
								}
								break;
							case 'd':
							case 'D':
								switch(*(symbol+1))
								{
									case 'f':
									case 'F':
										if(current_word->styles.italic != 0)
										{
											current_word->styles.italic--;
											if(current_word->styles.italic==0)
												current_word->changed.font=true;
										}
										break;
									
									case 'i':
									case 'I':
										switch(*(symbol+2))
										{
											case 'r':
											case 'R':
												if(current_list!=0)
												{
													if(current_list->next_stack_item!=0)
														current_paragraph->eop_space=-(current_word->word_height);
													current_paragraph->eop_space+=current_font_size/3;
													current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
													current_word=current_paragraph->item;
													active_word=active_word_buffer;
													current_list=current_list->next_stack_item;
													current_paragraph->left_border-=list_indent(0);
													current_indent_distance=current_paragraph->left_border;
												}
												break;
											case 'v':
											case 'V':
												current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
												current_word=current_paragraph->item;
												active_word=active_word_buffer;
												current_paragraph->alignment=left;
												break;
										}
										break;
									case 'l':
									case 'L':
										current_paragraph->eop_space=current_font_size;
										current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
										current_word=current_paragraph->item;
										current_paragraph->alignment=left;
										current_paragraph->left_border-=list_indent(2);
										current_indent_distance=current_paragraph->left_border;
										break;
								}
								break;
							case 'e':
							case 'E':
								if(current_word->styles.italic != 0)
								{
									current_word->styles.italic--;
									if(current_word->styles.italic==0)
										current_word->changed.font=true;
								}
								break;
							case 'f':
							case 'F':
								current_font_step=destroy_step(current_font_step);
								current_font_size=current_font_step->step*font_step;
								current_word->styles.font_size=current_font_size;
								current_word->changed.font=true;
								break;
							case 'h':
							case 'H':
								switch(*(symbol+1))
								{
									case 't':
									case 'T':
										*(symbol+5)='\0';
										current_paragraph->eop_space=20;
										break;
									case '1':
									case '2':
									case '3':
									case '4':
									case '5':
									case '6':
										current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
										current_word=current_paragraph->item;
										active_word=active_word_buffer;
										current_paragraph->alignment=left;
										current_word->styles.font=normal_font;
										current_word->styles.font_size=current_font_size;
										current_word->changed.font=true;
										break;
								}
								break;
							case 'i':
							case 'I':
								switch(*(symbol+1))
								{
									case ' ':
									case '>':
										if(current_word->styles.italic != 0)
										{
											current_word->styles.italic--;
											if(current_word->styles.italic==0)
												current_word->changed.font=true;
										}
										break;
								}
								break;
							case 'k':
							case 'K':
								current_word->styles.font=normal_font;
								current_word->changed.font=true;
								break;
							case 'm':
							case 'M':
								switch(*(symbol+1))
								{
									case 'e':
									case 'E':
										if(current_list!=0)
										{
											if(current_list->next_stack_item!=0)
												current_paragraph->eop_space=-(current_word->word_height);
											current_paragraph->eop_space+=current_font_size/3;
											current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
											current_word=current_paragraph->item;
											active_word=active_word_buffer;
											current_list=current_list->next_stack_item;
											current_paragraph->left_border-=list_indent(0);
											current_indent_distance=current_paragraph->left_border;
										}
										break;
								}
								break;
							case 'o':
							case 'O':
								switch(*(symbol+1))
								{
									case 'l':
									case 'L':
										if(current_list!=0)
										{
											if(current_list->next_stack_item!=0)
												current_paragraph->eop_space=-(current_word->word_height);
											current_paragraph->eop_space+=current_font_size/3;
											current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
											current_word=current_paragraph->item;
											active_word=active_word_buffer;
											current_list=remove_stack_item(current_list);
											current_paragraph->left_border-=list_indent(1);
											current_indent_distance=current_paragraph->left_border;
										}
										break;
								}		
								break;
							case 's':
							case 'S':
								switch(*(symbol+1))
								{
									case ' ':
									case '>':
										if(current_word->styles.strike !=0)
											current_word->styles.strike--;
										current_word->changed.style=true;
										break;
									case 'a':
									case 'A':
										current_word->styles.font=normal_font;
										current_word->changed.font=true;
										break;
									case 'm':
									case 'M':
										current_word->styles.font_size=current_font_size;
										current_word->changed.font=true;
										break;
									case 't':
									case 'T':
									switch(*(symbol+3))
									{
										case 'i':
										case 'I':
											if(current_word->styles.strike != 0)
												current_word->styles.strike--;
											current_word->changed.style=true;
											break;
										case 'o':
										case 'O':
											if(current_word->styles.bold !=0)
											{
												current_word->styles.bold--;
												if(current_word->styles.bold==0)
													current_word->changed.font=true;
											}
											break;
									}
									break;
									case 'u':
									case 'U':
										current_word->styles.font_size=current_font_size;
										current_word->vertical_align=bottom;
										break;
								}
								break;
							case 't':
							case 'T':
								current_word->styles.font=normal_font;
								current_word->changed.font=true;
								break;
							case 'u':
							case 'U':
								switch(*(symbol+1))
								{
									case ' ':
									case '>':
										if(current_word->styles.underlined !=0)
											current_word->styles.underlined--;
										current_word->changed.style=true;
										break;
									case 'l':
									case 'L':
										if(current_list!=0)
										{
											if(current_list->next_stack_item!=0)
												current_paragraph->eop_space=-(current_word->word_height);
											current_paragraph->eop_space+=current_font_size/3;
											current_paragraph=add_paragraph(current_paragraph,current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
											current_word=current_paragraph->item;
											active_word=active_word_buffer;
											current_list=remove_stack_item(current_list);
											current_paragraph->left_border-=list_indent(0);
											current_indent_distance=current_paragraph->left_border;
										}
										break;
								}
								break;
							case 'v':
							case 'V':
								if(current_word->styles.italic != 0)
								{
									current_word->styles.italic--;
									if(current_word->styles.italic==0)
										current_word->changed.font=true;
								}
								break;
						}
						break;
				}
				if(current_word->changed.font=true)
				{	
					vst_font(vdi_handle,fonts[current_word->styles.font][current_word->styles.bold != 0][current_word->styles.italic != 0]);
					vst_arbpt(vdi_handle,current_word->styles.font_size,&u,&u,&u,&u);
					vqt_fontinfo(vdi_handle,&u,&u,distances,&u,effects);
					vqt_advance(vdi_handle,Space_Code,&current_word->space_width,&u,&u,&u);
					current_word->word_height=distances[3];
					current_word->word_tail_drop=distances[1];
				}
				symbol++;
				break;
			case 13:
			case 12:
				*symbol=32;
				symbol--;
				break;
			case '&':
				if(*(symbol+1) == '#')
				{
					output[0]=*(symbol+2);
					output[1]=*(symbol+3);
					output[2]=*(symbol+4);
					symbol+=4;
					output[3]='\0';
					*active_word=special_char_map(convert_to_number(output));
					active_word++;
				}
				else
				{
					while(*(symbol+1) != ';' && *(symbol+1) != '\0')
						symbol++;
					symbol++;
				}
				break;
			case ' ':
				if(space_found==true)
					break;
				current_word=add_word(current_word,active_word_buffer,active_word,minimum_width,current_indent_distance);
				active_word=active_word_buffer;
				space_found=true;
			default:
			if(*symbol<32)
					break;
				if(*symbol>126)
					break;
				if(*symbol!=' ')
					space_found=false;
				*active_word=map(*symbol);
				active_word++;
				
		}
		if(code_processed==true)
		{
			code_processed=false;
			while(*(symbol)!= '\0' && *(symbol)!='>')
				symbol++;
		}
		symbol++;
	}
	
	word_store(current_word,active_word_buffer,active_word);
	
	wind_update(BEG_UPDATE);
	graf_mouse(0,0);
	wind_update(END_UPDATE);
	
	free(start_symbol);
	
	*minimum_width+=5;

	return(start);
}
