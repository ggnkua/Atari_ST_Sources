#include "dialog.h"
#include <osbind.h>

/*************************************************************************************************************************/
/*************************************************************************************************************************/
RO_Group *create_Group()
{
	RO_Group *object;
	object = ( RO_Group * )Malloc( sizeof( RO_Group ) );
  	if( object)
  		memset( object , 0 , sizeof( RO_Group ) );
	return object;
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
RO_Dialog *create_Dialog()
{
	RO_Dialog *object;
	object = ( RO_Dialog * )Malloc( sizeof( RO_Dialog ) );
  	if( object)
  		memset( object , 0 , sizeof( RO_Dialog ) );
	return object;
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
RO_Button *create_Button()
{
	RO_Button *object;
	object = ( RO_Button * )Malloc( sizeof( RO_Button ) );
  	if( object)
  		memset( object , 0 , sizeof( RO_Button ) );
	object->font.Id = - 1;
	object->font.Size = - 1;
	object->font.Colour = - 1;
	object->font.Effects = - 1;
	return object;
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
RO_ButtonHelp *create_ButtonHelp()
{
	RO_ButtonHelp *object;
	object = ( RO_ButtonHelp * )Malloc( sizeof( RO_ButtonHelp ) );
  	if( object)
  		memset( object , 0 , sizeof( RO_ButtonHelp ) );
	return object;
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
RO_ButtonScroll *create_ButtonScroll()
{
	RO_ButtonScroll *object;
	object = ( RO_ButtonScroll * )Malloc( sizeof( RO_ButtonScroll ) );
  	if( object)
  		memset( object , 0 , sizeof( RO_ButtonScroll ) );
	return object;

}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
RO_Icon *create_Icon()
{
	RO_Icon *object;
	object = ( RO_Icon * )Malloc( sizeof( RO_Icon ) );
  	if( object)
  		memset( object , 0 , sizeof( RO_Icon ) );
	return object;
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
RO_Image *create_Image()
{
	RO_Image *object;
	object = ( RO_Image * )Malloc( sizeof( RO_Image ) );
  	if( object)
  		memset( object , 0 , sizeof( RO_Image ) );
	return object;
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
RO_PictureListArea *create_PictureListArea()
{
	RO_PictureListArea *object;
	object = ( RO_PictureListArea * )Malloc( sizeof( RO_PictureListArea ) );
  	if( object)
  		memset( object , 0 , sizeof( RO_PictureListArea ) );
	return object;
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
RO_ScrollBar *create_ScrollBar()
{
	RO_ScrollBar *object;
	object = ( RO_ScrollBar * )Malloc( sizeof( RO_ScrollBar ) );
  	if( object)
  	{
  		memset( object , 0 , sizeof( RO_ScrollBar ) );
		object->max = 999;
		object->size = 1000;
		
	}
	return object;
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
RO_SlideBox *create_SlideBox()
{
	RO_SlideBox *object;
	object = ( RO_SlideBox * )Malloc( sizeof( RO_SlideBox ) );
  	if( object)
  		memset( object , 0 , sizeof( RO_SlideBox ) );
	return object;
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
RO_Text *create_Text()
{
	RO_Text *object;
	object = ( RO_Text * )Malloc( sizeof( RO_Text ) );
  	if( object)
  		memset( object , 0 , sizeof( RO_Text ) );
	return object;
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
RO_TextInput *create_TextInput()
{
	RO_TextInput *object;
	object = ( RO_TextInput * )Malloc( sizeof( RO_TextInput ) );
  	if( object)
  		memset( object , 0 , sizeof( RO_TextInput ) );
	return object;
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
RO_TextInputSecret *create_TextInputSecret()
{
	RO_TextInputSecret *object;
	object = ( RO_TextInputSecret * )Malloc( sizeof( RO_TextInputSecret ) );
  	if( object)
  		memset( object , 0 , sizeof( RO_TextInputSecret ) );
	return object;
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
RO_TextInputMenu *create_TextInputMenu()
{
	RO_TextInputMenu *object;
	object = ( RO_TextInputMenu * )Malloc( sizeof( RO_TextInputMenu ) );
  	if( object)
  		memset( object , 0 , sizeof( RO_TextInputMenu ) );
	return object;
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
RO_TextArea *create_TextArea()
{
	RO_TextArea *object;
	object = ( RO_TextArea * )Malloc( sizeof( RO_TextArea ) );
  	if( object)
  		memset( object , 0 , sizeof( RO_TextArea ) );
	return object;
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
RO_TextInputArea *create_TextInputArea()
{
	RO_TextInputArea *object;
	object = ( RO_TextInputArea * )Malloc( sizeof( RO_TextInputArea ) );
  	if( object)
  		memset( object , 0 , sizeof( RO_TextInputArea ) );
	return object;
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
RO_TextListArea *create_TextListArea()
{
	RO_TextListArea *object;
	object = ( RO_TextListArea * )Malloc( sizeof( RO_TextListArea ) );
  	if( object)
  		memset( object , 0 , sizeof( RO_TextListArea ) );
	return object;
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
RO_Object *create_object(int type)
{
	int datapointer = 1;
	RO_Object *object = ( RO_Object * )Malloc( sizeof( RO_Object ) );
	
	if( object )
	{
  		memset( object , 0 , sizeof( RO_Object ) );
		object->type = type;
		switch(type)
		{
			case RO_GROUP:
				object->Group = create_Group();
				break;
			case RO_BUTTON:
				object->Button = create_Button();
				break;
			case RO_SCROLLBAR:
				object->ScrollBar = create_ScrollBar();
				break;
			default:
				datapointer = 0;
				break;
		}
		if( datapointer )
		{
			if( ! object->Data )
				Mfree( object ) , object = 0;
		}
	}
	return object;
}
