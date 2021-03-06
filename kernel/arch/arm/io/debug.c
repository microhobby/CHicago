// File author is Ítalo Lima Marconato Matias
//
// Created on August 11 of 2018, at 16:47 BRT
// Last edited on August 15 of 2018, at 18:24 BRT

#include <chicago/arch/mmio.h>
#include <chicago/arch/uart-int.h>

Void DbgWriteCharacter(Char c) {
	MMIOWrite(UART_BASE, c);
}

Void DbgWriteString(Const PChar data) {
	for (UInt32 i = 0; data[i] != '\0'; i++) {
		DbgWriteCharacter(data[i]);
	}
}

Void DbgWriteInteger(UIntPtr data, UInt8 base) {
	if (data == 0) {
		DbgWriteCharacter('0');
		return;
	}
	
	static Char buf[32] = { 0 };
	Int i = 30;
	
	for (; data && i; i--, data /= base) {
		buf[i] = "0123456789ABCDEF"[data % base];
	}
	
	DbgWriteString(&buf[i + 1]);
}

Void DbgWriteFormated(Const PChar data, ...) {
	VariadicList va;
	VariadicStart(va, data);											// Let's start our va list with the arguments provided by the user (if any)
	
	for (UInt32 i = 0; data[i] != '\0'; i++) {
		if (data[i] != '%') {											// It's an % (integer, string, character or other)?
			DbgWriteCharacter(data[i]);									// Nope
		} else {
			switch (data[++i]) {										// Yes! So let's parse it!
			case 's': {													// String
				DbgWriteString((PChar)VariadicArg(va, PChar));
				break;
			}
			case 'c': {													// Character
				DbgWriteCharacter((Char)VariadicArg(va, Int));
				break;
			}
			case 'd': {													// Decimal Number
				DbgWriteInteger((UIntPtr)VariadicArg(va, UIntPtr), 10);
				break;
			}
			case 'x': {													// Hexadecimal Number
				DbgWriteInteger((UIntPtr)VariadicArg(va, UIntPtr), 16);
				break;
			}
			default: {													// None of the others...
				DbgWriteCharacter(data[i]);
				break;
			}
			}
		}
	}
	
	VariadicEnd(va);
}
