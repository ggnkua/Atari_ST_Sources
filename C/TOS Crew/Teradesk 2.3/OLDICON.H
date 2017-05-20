boolean load_icons(void)
{
	char *name;
	int handle, i, error;
	OBJECT *objects;
	long datasize, length;
	RSHDR *header;
	XATTR attr;

	icon_buffer = NULL;

	if ((name = xshel_find("icons.rsc", &error)) == NULL)
	{
		if (error == EFILNF)
			alert_printf(1, MICNFNF);
		else
			xform_error(error);
		return TRUE;
	}

	if ((error = (int) x_attr(0, name, &attr)) == 0)
	{
		length = attr.size + (attr.size & 0x1);
		if ((handle = x_open(name, O_DENYW | O_RDONLY)) < 0)
			error = handle;
	}

	free(name);

	if (error < 0)
	{
		alert_printf(1, MICNFNF);
		return TRUE;
	}

	if ((icon_buffer = x_alloc(length * 2L)) == NULL)
	{
		xform_error(ENSMEM);
		x_close(handle);
		return TRUE;
	}


	if (x_read(handle, length, (char *) icon_buffer + length) != length)
		goto read_error;

	x_close(handle);

	header = (RSHDR *) ((char *) icon_buffer + length);
	icons = icon_buffer;
	objects = (OBJECT *) ((char *) header + header->rsh_object);

	if ((header->rsh_nib == 0) || (header->rsh_ntree != 1) || (length <= sizeof(RSHDR)))
	{
		alert_printf(1, MICONERR);
		x_free(icon_buffer);
		return TRUE;
	}

	n_icons = 0;

	for (i = 1; i < header->rsh_nobs; i++)
	{
		if (objects[i].ob_type == G_ICON)
			icons[n_icons++] = *(ICONBLK *) ((char *) header + objects[i].ob_spec.index);
	}

	datasize = 0;

	for (i = 0; i < n_icons; i++)
		datasize += (icons[i].ib_wicon * icons[i].ib_hicon) / 4;

	icon_data = (int *) ((char *) icon_buffer + (long) n_icons * sizeof(ICONBLK));

	memcpy(icon_data, (char *) header + header->rsh_imdata, datasize);

	for (i = 0; i < n_icons; i++)
	{
		icons[i].ib_pmask = (int *) ((long) icons[i].ib_pmask + (long) icon_data - (long) header->rsh_imdata);
		icons[i].ib_pdata = (int *) ((long) icons[i].ib_pdata + (long) icon_data - (long) header->rsh_imdata);
		icons[i].ib_ptext = NULL;
		icons[i].ib_htext = 10;
	}

	x_shrink(icon_buffer, (long) n_icons * sizeof(ICONBLK) + datasize);

	return FALSE;

  read_error:
	alert_printf(1, MICNFRD);
	x_close(handle);
	if (icon_buffer != NULL)
		x_free(icon_buffer);

	return TRUE;
}