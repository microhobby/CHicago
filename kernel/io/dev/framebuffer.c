// File author is Ítalo Lima Marconato Matias
//
// Created on July 18 of 2018, at 22:24 BRT
// Last edited on October 15 of 2018, at 10:59 BRT

#include <chicago/debug.h>
#include <chicago/device.h>
#include <chicago/display.h>
#include <chicago/string.h>

Boolean FrameBufferDeviceRead(PDevice dev, UIntPtr off, UIntPtr len, PUInt8 buf) {
	(Void)dev;																												// Avoid compiler's unused parameter warning
	
	if ((off + len) >= (DispGetWidth() * DispGetHeight() * 4)) {															// Too high address?
		return False;																										// Yes!
	} else {
		StrCopyMemory(buf, (PVoid)(DispGetFrameBuffer() + off), len);														// No, so let's read from the real framebuffer!
		return True;
	}
}

Boolean FrameBufferDeviceWrite(PDevice dev, UIntPtr off, UIntPtr len, PUInt8 buf) {
	(Void)dev;																												// Avoid compiler's unused parameter warning
	
	if ((off + len) >= (DispGetWidth() * DispGetHeight() * 4)) {															// Too high address?
		return False;																										// Yes...
	} else {
		StrCopyMemory((PVoid)(DispGetFrameBuffer() + off), buf, len);														// No, so let's write to the real framebuffer!
		return True;
	}
}

Boolean FrameBufferDeviceControl(PDevice dev, UIntPtr cmd, PUInt8 ibuf, PUInt8 obuf) {
	(Void)dev; (Void)ibuf;																									// Avoid compiler's unused parameter warning
	
	PUIntPtr out = (PUIntPtr)obuf;
	
	if (cmd == 0) {																											// Get width?
		*out = DispGetWidth();
	} else if (cmd == 1) {																									// Get height?
		*out = DispGetHeight();
	} else {
		return False;																										// ...
	}
	
	return True;
}

Void FrameBufferDeviceInit(Void) {
	if (!FsAddDevice("FrameBuffer", Null, FrameBufferDeviceRead, FrameBufferDeviceWrite, FrameBufferDeviceControl)) {		// Let's add ourself
		DbgWriteFormated("PANIC! Failed to add the FrameBuffer device\r\n");												// Failed
		while (1) ;
	}
}
