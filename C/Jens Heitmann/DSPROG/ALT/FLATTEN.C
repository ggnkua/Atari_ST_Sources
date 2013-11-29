#define TAB_SIZE 20
int i, l, j, k;
int find[TAB_SIZE];
long mx[TAB_SIZE], last;

memset(find, 0, sizeof(find));
memset(mx, 0, sizeof(mx));

l = len / 2;
i = 0;
last = -1L;
while(i < l)
	{
	while(p_data[i] >= last)
		{
		last = p_data[i];
		i++;
		if (i == l)
			break;
		}
		
	for (j = 0, k = 0; j < TAB_SIZE; j++)
		if (mx[j] < mx[k])
			k = j;
			
	mx[k] = p_data[i - 1];
	find[k] = i - 1;

	while(p_data[i] <= last)
		{
		last = p_data[i];
		i++;
		if (i == l)
			break;
		}
	}
	
i = 0;
last = -1L;
while(i < l)
	{
	k = i;
	while(p_data[i] >= last)
		{
		last = p_data[i];
		i++;
		if (i == l)
			break;
		}
		
	for (j = 0; j < TAB_SIZE; j++)
		if (find[j] == i - 1)
			break;

	while(p_data[i] <= last)
		{
		last = p_data[i];
		i++;
		if (i == l)
			break;
		}

	if (j == TAB_SIZE)
		{			
		for (; k < i; k++)
			{
			p_data[k] = 0L;
			o_data[k] = 0L;
			o_data[len - k] = 0L;
			}	
		}
	}

------------

int *ids;
int i, l, l4;
int p;

ids = (int *)malloc(MAX_BLK);
if (ids)
	{
	memset(ids, 0, MAX_BLK);
	
	l = len / 2;
	for (i = 0; i < l; i++)
		ids[p_data[i] * (MAX_BLK/2) / maxp]++;
		
	i = 0;
	l4 = len * 3L / 8;
	while(l4 > 0)
		l4 -= ids[i++];
		
	for (p = 0; p < l; p++)
		if (p_data[p] * (MAX_BLK/2) / maxp < i)
			{
			p_data[p] = 0;
			o_data[p] = 0;
			o_data[len - p] = 0;
			}
	
	free(ids);
	}
	
/*int i, l;
long p;
	
p = maxp * 75 / 100;
l = len / 2;
for (i = 0; i < l; i++)
	if (p_data[i] <  p)
		{
		p_data[i] = 0;
		o_data[i] = 0;
		o_data[len - i] = 0;
		}*/