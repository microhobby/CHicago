// File author is Ítalo Lima Marconato Matias
//
// Created on July 15 of 2018, at 13:19 BRT
// Last edited on July 15 of 2018, at 20:31 BRT

#include <chicago/debug.h>
#include <chicago/device.h>
#include <chicago/string.h>

Boolean ZeroDeviceRead(PDevice dev, UIntPtr off, UIntPtr len, PUInt8 buf) {
	(Void)dev; (Void)off;														// Avoid compiler's unused parameter warning
	StrSetMemory(buf, 0, len);													// Just fill the buffer with zeroes (this is what Zero device does)
	return True;																// Always return True
}

Boolean ZeroDeviceWrite(PDevice dev, UIntPtr off, UIntPtr len, PUInt8 buf) {
	(Void)dev; (Void)off; (Void)len; (Void)buf;									// Avoid compiler's unused parameter warning
	return True;																// Always return True
}

Void ZeroDeviceInit(Void) {
	if (!FsAddDevice("Zero", Null, ZeroDeviceRead, ZeroDeviceWrite)) {			// Let's add ourself
		DbgWriteFormated("[Kernel] Failed to add Zero device\r\n");				// Failed...
	}
}