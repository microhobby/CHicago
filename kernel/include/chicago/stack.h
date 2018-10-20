// File author is Ítalo Lima Marconato Matias
//
// Created on October 12 of 2018, at 15:35 BRT
// Last edited on October 19 of 2018, at 18:19 BRT

#ifndef __CHICAGO_STACK_H__
#define __CHICAGO_STACK_H__

#include <chicago/list.h>

#define Stack List
#define PStack PList

PStack StackNew(Boolean user);
Void StackFree(PStack stack);
Boolean StackPush(PStack stack, PVoid data);
Boolean StackPushStart(PStack stack, PVoid data);
PVoid StackPop(PStack stack);
PVoid StackPopStart(PStack stack);

#endif		// __CHICAGO_STACK_H__
