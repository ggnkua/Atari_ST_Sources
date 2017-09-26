#define	Ftp_Quit						0x5000

#define	SocketInit_Cmd				0x5010
#define	SocketInit_Failed			0x5011
#define	SocketInit_Ok				0x5012

#define	OpenConnect_Cmd			0x5020
#define	Socket_Failed				0x5021
#define	GetHostByName				0x5022
#define	GetHostByName_Failed		0x5023
#define	Connect						0x5024
#define	Connect_Failed				0x5025
#define	OpenConnect_Ok				0x5026

#define	Login_Cmd					0x5030
#define	Login_Failed				0x5031
#define	Login_Ok						0x5032
#define	Link_Failed					0x5033

#define	Cwd_Cmd						0x5040
#define	Cwd_Failed					0x5041
#define	Cwd_Ok						0x5042

#define	Cdup_Cmd						0x5050
#define	Cdup_Failed					0x5051
#define	Cdup_Ok						0x5052

#define	Pwd_Cmd						0x5060
#define	Pwd_Failed					0x5061
#define	Pwd_Ok						0x6062

#define	List_Cmd						0x5070
#define	List_Failed					0x5071
#define	List_Ok						0x5072
#define	List_Update					0x5073
#define	List_Abort					0x5074

#define	Retr_Cmd						0x5081
#define	Retr_Failed					0x5082
#define	Retr_Ok						0x5083
#define	Retr_File_Update			0x5084
#define	Retr_File_Ok				0x5085
#define	Retr_Update					0x5086
#define	Retr_Abort					0x5087
#define	Retr_Get_Size				0x5088
#ifdef	RESUME
#define	Retr_File_Resume			0x5089
#define	Retr_File_Resume_Error	0x508a
#endif

#define	Stor_Cmd						0x5090
#define	Stor_Failed					0x5091
#define	Stor_Ok						0x5092
#define	Stor_File_Update			0x5093
#define	Stor_File_Ok				0x5094
#define	Stor_Update					0x5095
#define	Stor_Abort					0x5096

#define	Rn_Cmd						0x50a0
#define	Rn_Failed					0x50a1
#define	Rn_Ok							0x50a2
#define	Rn_Update					0x50a3
#define	Rn_File_Ok					0x50a4

#define	Dele_Cmd						0x50b0
#define	Dele_Failed					0x50b1
#define	Dele_Ok						0x50b2
#define	Dele_Update					0x50b3
#define	Dele_File_Ok				0x50b4

#define	Mkd_Cmd						0x50c0
#define	Mkd_Failed					0x50c1
#define	Mkd_Ok						0x50c2

#define	Rmd_Cmd						0x50d0
#define	Rmd_Failed					0x50d1
#define	Rmd_Ok						0x50d2
#define	Rmd_Update					0x50d3
#define	Rmd_Dir_Ok					0x50d4

#define	Abor_Cmd						0x50e0

#define	Chmod_Cmd					0x50f0
#define	Chmod_Failed				0x50f1
#define	Chmod_Ok						0x50f2
#define	Chmod_Update				0x50f3
#define	Chmod_File_Ok				0x50f4

#define	ABORT							-600
/* Flags von WorkDataStream() */
#define	GEMScriptSession			0x0001

#define	CMDPUFLEN					8192L

/*-----------------------------------------------------------------------------*/
/* Strukturdefinitionen                                                        */
/*-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
WORD	Ftp( LONG AppId );
