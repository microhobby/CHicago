// File author is Ítalo Lima Marconato Matias
//
// Created on September 15 of 2018, at 13:12 BRT
// Last edited on October 19 of 2018, at 21:45 BRT

#ifndef __CHICAGO_VERSION_H__
#define __CHICAGO_VERSION_H__

#include <chicago/types.h>

#define CHICAGO_MAJOR 1
#define CHICAGO_MINOR 0
#define CHICAGO_BUILD 22
#define CHICAGO_CODENAME "Cosmos"
#define CHICAGO_ARCH ARCH
#define CHICAGO_VSTR "Version " TextifyMacro(CHICAGO_MAJOR) "." TextifyMacro(CHICAGO_MINOR) "." TextifyMacro(CHICAGO_BUILD)
#define CHICAGO_VSTR_LEN StrGetLength(CHICAGO_VSTR)

#endif		// __CHICAGO_VERSION_H__
