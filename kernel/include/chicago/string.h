// File author is Ítalo Lima Marconato Matias
//
// Created on July 15 of 2018, at 20:03 BRT
// Last edited on July 28 of 2018, at 22:41 BRT

#ifndef __CHICAGO_STRING_H__
#define __CHICAGO_STRING_H__

#include <chicago/types.h>

PVoid StrCopyMemory(PVoid dest, PVoid src, UIntPtr count);
PVoid StrSetMemory(PVoid dest, UInt8 val, UIntPtr count);
Boolean StrCompareMemory(PVoid m1, PVoid m2, UIntPtr count);
UIntPtr StrGetLength(PChar str);
Boolean StrCompare(PChar dest, PChar src);
PChar StrCopy(PChar dest, PChar src);
Void StrConcatenate(PChar dest, PChar src);
PChar StrTokenize(PChar str, PChar delim);
PChar StrDuplicate(PChar str);

#endif		// __CHICAGO_STRING_H__
