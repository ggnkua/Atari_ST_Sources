void	Do_Point_Sizes( int obj, int flag );
void	Pointer_Setup( FON_PTR cur_ptr, int defaults );
void	Sort_Points( void );
BOOLEAN	Point_Sizes_Exist( FON_PTR cur_ptr );
int	Count_Point_Sizes( void );
void	Delete_Point_Sizes( void );
void	Add_New_Point_Size( void );
void	New_Point_Size_Up_Down_Arrow( int obj );
void    Insert_New_Point_Size( void );
void	Push_Point_Size( void );
void	Default_Point_Button( void );
void	Move_Defaults_To_Font( FON_PTR ptr );
void	Point_Left_Right( int button );

int     Fsize_button( int button, WORD *msg );
int     New_Point_Size_Button( int button, WORD *msg );

extern int Point_Count;
extern int Cur_Point_Size;
extern int Old_Cur_Slit;


#define NO_DEFAULT_POINTS 0
#define DEFAULT_POINTS  1						 

