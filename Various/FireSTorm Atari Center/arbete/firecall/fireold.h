#define VERSION_DATA_0_73 "FC 0.73"
typedef struct
{
  char               name[SIZE_NAME],
                     info1[SIZE_NAME],
                     info2[SIZE_NAME],
                     info3[SIZE_NAME],
                     date[13],
                     number[SIZE_NUMB];
//                     notefile[SIZE_FILE];
  int                times,
                     flags;
  long               event_num;
}PHONE_DATA_0_73;
