/*****************************************************************************
*
* shell sort function for INTEGERS -  Array%()  
* For interface with GFA Basic 
* Program by John Tal of MichTron Inc.
*
*****************************************************************************/

shell(array,elements)
long array[];
int elements;
{
 int gap,i,j;
 long temp;

 for(gap = elements/2 ; gap > 0; gap /= 2)
    for(i = gap; i < elements; i++)
      for(j = i-gap; j >= 0 && array[j] > array[j + gap]; j-= gap)
      {
       temp = array[j];
       array[j] = array[j + gap];
       array[j + gap] = temp;
      }

}

