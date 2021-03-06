// File author is Ítalo Lima Marconato Matias
//
// Created on May 11 of 2018, at 23:24 BRT
// Last edited on July 15 of 2018, at 13:25 BRT

#ifndef __CHICAGO_DEBUG_H__
#define __CHICAGO_DEBUG_H__

#include <chicago/types.h>

Void DbgWriteCharacter(Char data);
Void DbgWriteString(Const PChar data);
Void DbgWriteInteger(UIntPtr data, UInt8 base);
Void DbgWriteFormated(Const PChar data, ...);

#endif		// __CHICAGO_DEBUG_H__
