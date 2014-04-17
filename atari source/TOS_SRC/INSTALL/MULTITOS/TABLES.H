/* DEFINES
 * ================================================================
 */
typedef struct _file_node
{
     char fname[15];		/* filename or wild card 	*/
     char parameter[15]; 	/* parameter following, if any  */
}FILE_NODE;


typedef struct _title_node
{
     char      pattern[30];	/* Pattern - [FOLDER.GDOS]  */
     char      path[30];	/* Path - ie: GDOS	    */ 
     int       count;		/* Count - Num of nodes used*/
     FILE_NODE fnode[20];	/* Nodes to store FILE_NODES*/
}TITLE_NODES;

#define NUM_PATTERNS  6

void	BuildTables( void );

EXTERN TITLE_NODES Titles[];
