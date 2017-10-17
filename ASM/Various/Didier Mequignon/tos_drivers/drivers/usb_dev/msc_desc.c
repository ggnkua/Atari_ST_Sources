/*
 * File msc_desc.c
 * Purpose:	Descriptors for Mass Storage
 */

#include "usb.h"
#include "msc.h"

#ifdef USB_DEVICE
#ifdef NETWORK
#ifdef LWIP

/* Structure for Mass Storage Interface Type */
typedef struct {
	USB_DEVICE_DESC device_desc;
	USB_CONFIG_DESC config_desc;
	USB_INTERFACE_DESC interface_desc;
	USB_ENDPOINT_DESC bulk_in_desc;
	USB_ENDPOINT_DESC bulk_out_desc;
} DESCRIPTOR_STRUCT;

uint8 string_desc[] = { 
	4, STRING, 0x09, 0x04, /* Unicode: English US */
	20, STRING, 'F',0,'r',0,'e',0,'e',0,'s',0,'c',0,'a',0,'l',0,'e',0,
	54, STRING, 'M',0,'C',0,'F',0,'5',0,'4',0,'8',0,'5',0,' ',0,
	            'C',0,'o',0,'l',0,'d',0,'F',0,'i',0,'r',0,'e',0,' ',0,
	            'P',0,'r',0,'o',0,'c',0,'e',0,'s',0,'s',0,'o',0,'r',0,
	26, STRING, 'S',0,'e',0,'l',0,'f',0,'-',0,'p',0,'o',0,'w',0,'e',0,'r',0,'e',0,'d',0,
	14, STRING, 'M',0,'e',0,'m',0,'o',0,'r',0,'y',0
};

/* Initialize the descriptors */
#if 1
uint8 Descriptors[] =
{
	/* Device Descriptor */
	/* bLength */             18,
	/* bDescriptorType */      DEVICE,
	/* bcdUSBL */           0x10,
	/* bcdUSBH */           0x01, /* USB 1.10 */
	/* bDeviceClass */         0,
	/* bDeviceSubClass */      0,
	/* bDeviceProtocol */      0,
	/* bMaxPacketSize0 */     64, /* 8, 16, 32 or 64 */
	/* idVendorL */         0xA2,
	/* idVendorH */         0x15, /* arbitrary */
	/* idProductL */        0x85,
	/* idProductH */        0x54, /* arbitrary */
	/* bcdDeviceL */           0,
	/* bcdDeviceH */           1, /* arbitrary */
	/* iManufacturern */       1, /* fist string */
	/* iProduct */             2, /* second string */
	/* iSerialNumber */        0,
	/* bNumConfigurations */   1,

	/* Configuration Descriptor */
	/* bLength */              9,
	/* bDescriptorType */      CONFIGURATION,
	/* wTotalLengthL */       32,
	/* wTotalLengthH */        0,
	/* bNumInterfaces */       1,
	/* bConfigurationValue */  1, /* This is configuration #1 */
	/* iConfiguration */       3, /* third string */
	/* bmAttributes */         SELF_POWERED, /* | REMOTE_WAKEUP works only on devices with date code XXX0632 or later */
	/* maxPower */             0,

	/* Interface Descriptor */
	/* bLength */              9,
	/* bDescriptorType */      INTERFACE,
	/* bInterfaceNumber */     0, /* This is interface #0 */
	/* bAlternateSetting */    0,
	/* bNumEndpoints */        2,
	/* bInterfaceClass */      MASS_STORAGE_INTERFACE,
	/* bInterfaceSubClass */   MSC_SUBCLASS_SCSI,
	/* bInterfaceProtocol */   MSC_PROTOCOL_BULK_ONLY,
	/* iInterface */			     4, /* fourth string */
	
	/* Endpoint BULK_IN Descriptor */
	/* bLength */              7,
	/* bDescriptorType */      ENDPOINT,
	/* bEndpointAddress */     (1 | IN), /* This is endpoint #1 */
	/* bmAttributes */         BULK,
	/* wMaxPacketSizeL */   0x40, /* 64 */
	/* wMaxPacketSizeH */   0x00,
	/* bInterval */            0,	

	/* Endpoint BULK_OUT Descriptor */
	/* bLength */              7,
	/* bDescriptorType */      ENDPOINT,
	/* bEndpointAddress */     (2 | OUT), /* This is endpoint #2 */
	/* bmAttributes */         BULK,
	/* wMaxPacketSizeL */   0x40, /*64 */
	/* wMaxPacketSizeH */   0x00,
	/* bInterval */            0
};

uint8 DescriptorsHS[] =
{
	/* Device Descriptor */
	/* bLength */             18,
	/* bDescriptorType */      DEVICE,
	/* bcdUSBL */           0x00,
	/* bcdUSBH */           0x02, /* USB 2.0 */
	/* bDeviceClass */         0,
	/* bDeviceSubClass */      0,
	/* bDeviceProtocol */      0,
	/* bMaxPacketSize0 */     64, /* 8, 16, 32 or 64 */
	/* idVendorL */         0xA2,
	/* idVendorH */         0x15, /* arbitrary */
	/* idProductL */        0x85,
	/* idProductH */        0x54, /* arbitrary */
	/* bcdDeviceL */           0,
	/* bcdDeviceH */           1, /* arbitrary */
	/* iManufacturern */       1, /* fist string */
	/* iProduct */             2, /* second string */
	/* iSerialNumber */        0,
	/* bNumConfigurations */   1,

	/* Configuration Descriptor */
	/* bLength */              9,
	/* bDescriptorType */      CONFIGURATION,
	/* wTotalLengthL */       32,
	/* wTotalLengthH */        0,
	/* bNumInterfaces */       1,
	/* bConfigurationValue */  1, /* This is configuration #1 */
	/* iConfiguration */       3, /* third string */
	/* bmAttributes */         SELF_POWERED, /* | REMOTE_WAKEUP works only on devices with date code XXX0632 or later */
	/* maxPower */             0,

	/* Interface Descriptor */
	/* bLength */              9,
	/* bDescriptorType */      INTERFACE,
	/* bInterfaceNumber */     0, /* This is interface #0 */
	/* bAlternateSetting */    0,
	/* bNumEndpoints */        2,
	/* bInterfaceClass */      MASS_STORAGE_INTERFACE,
	/* bInterfaceSubClass */   MSC_SUBCLASS_SCSI,
	/* bInterfaceProtocol */   MSC_PROTOCOL_BULK_ONLY,
	/* iInterface */			     4, /* fourth string */
	
	/* Endpoint BULK_IN Descriptor */
	/* bLength */              7,
	/* bDescriptorType */      ENDPOINT,
	/* bEndpointAddress */     (1 | IN), /* This is endpoint #1 */
	/* bmAttributes */         BULK,
	/* wMaxPacketSizeL */   0x00, /* 512 */
	/* wMaxPacketSizeH */   0x02,
	/* bInterval */            0,	

	/* Endpoint BULK_OUT Descriptor */
	/* bLength */              7,
	/* bDescriptorType */      ENDPOINT,
	/* bEndpointAddress */     (2 | OUT), /* This is endpoint #2 */
	/* bmAttributes */         BULK,
	/* wMaxPacketSizeL */   0x00, /* 512 */
	/* wMaxPacketSizeH */   0x02,
	/* bInterval */            0
};

#else

DESCRIPTOR_STRUCT Descriptors =
{
	/* Device Descriptor */
	{
	/* bLength */              sizeof(USB_DEVICE_DESC),
	/* bDescriptorType */      DEVICE,
	/* bcdUSBL */           0x10,
	/* bcdUSBH */           0x01, /* USB 1.10 */
	/* bDeviceClass */         0,
	/* bDeviceSubClass */      0,
	/* bDeviceProtocol */      0,
	/* bMaxPacketSize0 */     64, /* 8, 16, 32 or 64 */
	/* idVendorL */         0xA2,
	/* idVendorH */         0x15, /* arbitrary */
	/* idProductL */        0x85,
	/* idProductH */        0x54, /* arbitrary */
	/* bcdDeviceL */           0,
	/* bcdDeviceH */           1, /* arbitrary */
	/* iManufacturern */       1, /* first string */
	/* iProduct */             2, /* second string */
	/* iSerialNumber */        0,
	/* bNumConfigurations */   1
	},

	/* Configuration Descriptor */
	{
	/* bLength */              sizeof(USB_CONFIG_DESC),
	/* bDescriptorType */      CONFIGURATION,
	/* wTotalLengthL */        (sizeof(DESCRIPTOR_STRUCT) - sizeof(USB_DEVICE_DESC)) & 0x00FF,
	/* wTotalLengthH */        (sizeof(DESCRIPTOR_STRUCT) - sizeof(USB_DEVICE_DESC)) >> 8,
	/* bNumInterfaces */       1,
	/* bConfigurationValue */  1, /* This is configuration #1 */
	/* iConfiguration */       3, /* third string */
	/* bmAttributes */         SELF_POWERED, /* | REMOTE_WAKEUP works only on devices with date code XXX0632 or later */
	/* maxPower */             0
	},

	/* Interface Descriptor */
	{
	/* bLength */              sizeof(USB_INTERFACE_DESC),
	/* bDescriptorType */      INTERFACE,
	/* bInterfaceNumber */     0, /* This is interface #0 */
	/* bAlternateSetting */    0,
	/* bNumEndpoints */        2,
	/* bInterfaceClass */      MASS_STORAGE_INTERFACE,
	/* bInterfaceSubClass */   MSC_SUBCLASS_SCSI,
	/* bInterfaceProtocol */   MSC_PROTOCOL_BULK_ONLY,
	/* iInterface */           4  /* fourth string */
	},

	/* Endpoint BULK_IN Descriptor */
	{
	/* bLength */              sizeof(USB_ENDPOINT_DESC),
	/* bDescriptorType */      ENDPOINT,
	/* bEndpointAddress */     (1 | IN), /* This is endpoint #1 */
	/* bmAttributes */         BULK,
	/* wMaxPacketSizeL */   0x40, /* 64 */
	/* wMaxPacketSizeH */   0x00,
	/* bInterval */            0	
	},

	/* Endpoint BULK_OUT Descriptor */
	{
	/* bLength */              sizeof(USB_ENDPOINT_DESC),
	/* bDescriptorType */      ENDPOINT,
	/* bEndpointAddress */     (2 | OUT), /* This is endpoint #2 */
	/* bmAttributes */         BULK,
	/* wMaxPacketSizeL */   0x40, /* 64 */
	/* wMaxPacketSizeH */   0x00,
	/* bInterval */            0
	}
};

DESCRIPTOR_STRUCT DescriptorsHS =
{
	/* Device Descriptor */
	{
	/* bLength */              sizeof(USB_DEVICE_DESC),
	/* bDescriptorType */      DEVICE,
	/* bcdUSBL */           0x00,
	/* bcdUSBH */           0x02, /* USB 2.0 */
	/* bDeviceClass */         0,
	/* bDeviceSubClass */      0,
	/* bDeviceProtocol */      0,
	/* bMaxPacketSize0 */     64, /* 8, 16, 32 or 64 */
	/* idVendorL */         0xA2,
	/* idVendorH */         0x15, /* arbitrary */
	/* idProductL */        0x85,
	/* idProductH */        0x54, /* arbitrary */
	/* bcdDeviceL */           0,
	/* bcdDeviceH */           1, /* arbitrary */
	/* iManufacturern */       1, /* first string */
	/* iProduct */             2, /* second string */
	/* iSerialNumber */        0,
	/* bNumConfigurations */   1
	},

	/* Configuration Descriptor */
	{
	/* bLength */              sizeof(USB_CONFIG_DESC),
	/* bDescriptorType */      CONFIGURATION,
	/* wTotalLengthL */        (sizeof(DESCRIPTOR_STRUCT) - sizeof(USB_DEVICE_DESC)) & 0x00FF,
	/* wTotalLengthH */        (sizeof(DESCRIPTOR_STRUCT) - sizeof(USB_DEVICE_DESC)) >> 8,
	/* bNumInterfaces */       1,
	/* bConfigurationValue */  1, /* This is configuration #1 */
	/* iConfiguration */       3, /* third string */
	/* bmAttributes */         SELF_POWERED, /* | REMOTE_WAKEUP works only on devices with date code XXX0632 or later */
	/* maxPower */             0
	},

	/* Interface Descriptor */
	{
	/* bLength */              sizeof(USB_INTERFACE_DESC),
	/* bDescriptorType */      INTERFACE,
	/* bInterfaceNumber */     0, /* This is interface #0 */
	/* bAlternateSetting */    0,
	/* bNumEndpoints */        2,
	/* bInterfaceClass */      MASS_STORAGE_INTERFACE,
	/* bInterfaceSubClass */   MSC_SUBCLASS_SCSI,
	/* bInterfaceProtocol */   MSC_PROTOCOL_BULK_ONLY,
	/* iInterface */           4  /* fourth string */
	},

	/* Endpoint BULK_IN Descriptor */
	{
	/* bLength */              sizeof(USB_ENDPOINT_DESC),
	/* bDescriptorType */      ENDPOINT,
	/* bEndpointAddress */     (1 | IN), /* This is endpoint #1 */
	/* bmAttributes */         BULK,
	/* wMaxPacketSizeL */   0x00, /* 512 */
	/* wMaxPacketSizeH */   0x02,
	/* bInterval */            0	
	},

	/* Endpoint BULK_OUT Descriptor */
	{
	/* bLength */              sizeof(USB_ENDPOINT_DESC),
	/* bDescriptorType */      ENDPOINT,
	/* bEndpointAddress */     (2 | OUT), /* This is endpoint #2 */
	/* bmAttributes */         BULK,
	/* wMaxPacketSizeL */   0x00, /* 512 */
	/* wMaxPacketSizeH */   0x02,
	/* bInterval */            0
	}
};

#endif

uint32 usb_get_desc_size(void)
{
	return(sizeof(Descriptors));
}

#endif /* LWIP */
#endif /* NETWORK */
#endif /* USB_DEVICE */
