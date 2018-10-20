// File author is Ítalo Lima Marconato Matias
//
// Created on May 11 of 2018, at 13:21 BRT
// Last edited on October 19 of 2018, at 21:53 BRT

.section .multiboot

.align 4																												// Multiboot header
.long 0x1BADB002
.long (1 << 0) | (1 << 1) | (1 << 2)
.long -(0x1BADB002 + ((1 << 0) | (1 << 1) | (1 << 2)))
.long 0, 0, 0, 0, 0, 0
.long 800, 600, 32

.section .text

.extern KernelMain
.global KernelEntry
KernelEntry:
	cli																													// Clear interrupts
	
	movl $(KernelPageTable1 - 0xC0000000), %edi																			// Let's map the first 4MB
	movl $0, %esi
1:
	cmpl $0x400000, %esi																								// ... Just 4MB
	jge 2f
	
	movl %esi, %edx																										// Set the present and rw bit
	orl $0x03, %edx
	movl %edx, (%edi)
	
	addl $4096, %esi																									// Size of page is 4096 bytes
	addl $4, %edi																										// And the size of page table entries is 4 bytes
	
	loop 1b																												// Keep on looping (if we need)
2:
	movl $(KernelPageTable2 - 0xC0000000), %edi
	movl $0x400000, %esi
3:
	cmpl $0x800000, %esi																								// ... Just more 4MB
	jge 4f
	
	movl %esi, %edx																										// Set the present and rw bit
	orl $0x03, %edx
	movl %edx, (%edi)
	
	addl $4096, %esi																									// Size of page is 4096 bytes
	addl $4, %edi																										// And the size of page table entries is 4 bytes
	
	loop 3b																												// Keep on looping (if we need)
4:
	movl $(KernelPageTable3 - 0xC0000000), %edi
	movl $0x800000, %esi
5:
	cmpl $0xC00000, %esi																								// ... And more 4MB
	jge 6f
	
	movl %esi, %edx																										// Set the present and rw bit
	orl $0x03, %edx
	movl %edx, (%edi)
	
	addl $4096, %esi																									// Size of page is 4096 bytes
	addl $4, %edi																										// And the size of page table entries is 4 bytes
	
	loop 5b																												// Keep on looping (if we need)
6:
	movl $(KernelPageTable1 - 0xC0000000 + 0x03), MmKernelDirectoryInt - 0xC0000000 + 0 * 4								// Let's put the tables in the page directory
	movl $(KernelPageTable1 - 0xC0000000 + 0x03), MmKernelDirectoryInt - 0xC0000000 + 768 * 4
	movl $(KernelPageTable2 - 0xC0000000 + 0x03), MmKernelDirectoryInt - 0xC0000000 + 769 * 4
	movl $(KernelPageTable3 - 0xC0000000 + 0x03), MmKernelDirectoryInt - 0xC0000000 + 770 * 4
	movl $(MmKernelDirectoryInt - 0xC0000000 + 0x03), MmKernelDirectoryInt - 0xC0000000 + 1023 * 4
	
	movl $(MmKernelDirectoryInt - 0xC0000000), %ecx																		// Let's load our page directory
	movl %ecx, %cr3
	
	movl %cr0, %ecx																										// AND ENABLE PAGING!
	orl $0x80010001, %ecx
	movl %ecx, %cr0
	
	lea 7f, %ecx
	jmp *%ecx
7:
	movl $0, MmKernelDirectoryInt + 0																					// And remove the initial pt
	invlpg 0
	
	movl $KernelStack, %esp																								// Setup kernel stack
	
	add $0xC0000000, %ebx																								// Fix the multiboot header pointer (we still need to fix the structure, but let's do it in C)
	
	mov %eax, (MultibootHeaderMagic)
	mov %ebx, (MultibootHeaderPointer)
	
	call KernelMain																										// Go to main kernel function
8:
	pause
	jmp 8b

.global CPUIDCheck
CPUIDCheck:
	pushfl
	pop %eax
	movl %eax, %ebx
	xorl $0x200000, %eax
	pushl %eax
	popfl
	pushfl
	pop %eax
	cmp %eax, %ebx
	jnz 0f
	mov $0x00, %eax
	ret
0:
	mov $0x01, %eax
	ret

GDTPointerLimit:
	.word 0																												// GDT limit storage
GDTPointerBase:
	.int 0																												// GDT base storage

.global GDTLoad
GDTLoad:
	mov 4(%esp), %eax																									// Load base
	mov %eax, (GDTPointerBase)
	mov 8(%esp), %ax																									// Load limit
	mov %ax, (GDTPointerLimit)
	
	lgdt (GDTPointerLimit)																								// Reload GDT
	ljmp $0x08, $1f
1:
	mov $0x10, %ax																										// Reload segments
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs
	mov %ax, %ss
	
	ret

.global TSSLoad
TSSLoad:
	mov 4(%esp), %ax																									// Load the first arg into AX
	ltr %ax																												// And load AX into task state register
	ret

IDTPointerLimit:
	.word 0																												// IDT limit storage
IDTPointerBase:
	.int 0																												// IDT base storage

.global IDTLoad
IDTLoad:
	mov 4(%esp), %eax																									// Load base
	mov %eax, (IDTPointerBase)
	mov 8(%esp), %ax																									// Load limit
	mov %ax, (IDTPointerLimit)
	lidt (IDTPointerLimit)																								// Reload IDT
	ret

.macro ISR_NO_ERRCODE num
.global ISRHandler\num
ISRHandler\num:
	cli
	push $0
	push $\num
	jmp ISRCommonStub
.endm

.macro ISR_ERRCODE num
.global ISRHandler\num
ISRHandler\num:
	cli
	push $\num
	jmp ISRCommonStub
.endm

ISR_NO_ERRCODE 0
ISR_NO_ERRCODE 1
ISR_NO_ERRCODE 2
ISR_NO_ERRCODE 3
ISR_NO_ERRCODE 4
ISR_NO_ERRCODE 5
ISR_NO_ERRCODE 6
ISR_NO_ERRCODE 7
ISR_ERRCODE 8
ISR_NO_ERRCODE 9
ISR_ERRCODE 10
ISR_ERRCODE 11
ISR_ERRCODE 12
ISR_ERRCODE 13
ISR_ERRCODE 14
ISR_NO_ERRCODE 15
ISR_NO_ERRCODE 16
ISR_NO_ERRCODE 17
ISR_NO_ERRCODE 18
ISR_NO_ERRCODE 19
ISR_NO_ERRCODE 20
ISR_NO_ERRCODE 21
ISR_NO_ERRCODE 22
ISR_NO_ERRCODE 23
ISR_NO_ERRCODE 24
ISR_NO_ERRCODE 25
ISR_NO_ERRCODE 26
ISR_NO_ERRCODE 27
ISR_NO_ERRCODE 28
ISR_NO_ERRCODE 29
ISR_NO_ERRCODE 30
ISR_NO_ERRCODE 31
ISR_NO_ERRCODE 32
ISR_NO_ERRCODE 33
ISR_NO_ERRCODE 34
ISR_NO_ERRCODE 35
ISR_NO_ERRCODE 36
ISR_NO_ERRCODE 37
ISR_NO_ERRCODE 38
ISR_NO_ERRCODE 39
ISR_NO_ERRCODE 40
ISR_NO_ERRCODE 41
ISR_NO_ERRCODE 42
ISR_NO_ERRCODE 43
ISR_NO_ERRCODE 44
ISR_NO_ERRCODE 45
ISR_NO_ERRCODE 46
ISR_NO_ERRCODE 47
ISR_NO_ERRCODE 48
ISR_NO_ERRCODE 49
ISR_NO_ERRCODE 50
ISR_NO_ERRCODE 51
ISR_NO_ERRCODE 52
ISR_NO_ERRCODE 53
ISR_NO_ERRCODE 54
ISR_NO_ERRCODE 55
ISR_NO_ERRCODE 56
ISR_NO_ERRCODE 57
ISR_NO_ERRCODE 58
ISR_NO_ERRCODE 59
ISR_NO_ERRCODE 60
ISR_NO_ERRCODE 61
ISR_NO_ERRCODE 62
ISR_NO_ERRCODE 63
ISR_NO_ERRCODE 64
ISR_NO_ERRCODE 65
ISR_NO_ERRCODE 66
ISR_NO_ERRCODE 67
ISR_NO_ERRCODE 68
ISR_NO_ERRCODE 69
ISR_NO_ERRCODE 70
ISR_NO_ERRCODE 71
ISR_NO_ERRCODE 72
ISR_NO_ERRCODE 73
ISR_NO_ERRCODE 74
ISR_NO_ERRCODE 75
ISR_NO_ERRCODE 76
ISR_NO_ERRCODE 77
ISR_NO_ERRCODE 78
ISR_NO_ERRCODE 79
ISR_NO_ERRCODE 80
ISR_NO_ERRCODE 81
ISR_NO_ERRCODE 82
ISR_NO_ERRCODE 83
ISR_NO_ERRCODE 84
ISR_NO_ERRCODE 85
ISR_NO_ERRCODE 86
ISR_NO_ERRCODE 87
ISR_NO_ERRCODE 88
ISR_NO_ERRCODE 89
ISR_NO_ERRCODE 90
ISR_NO_ERRCODE 91
ISR_NO_ERRCODE 92
ISR_NO_ERRCODE 93
ISR_NO_ERRCODE 94
ISR_NO_ERRCODE 95
ISR_NO_ERRCODE 96
ISR_NO_ERRCODE 97
ISR_NO_ERRCODE 98
ISR_NO_ERRCODE 99
ISR_NO_ERRCODE 100
ISR_NO_ERRCODE 101
ISR_NO_ERRCODE 102
ISR_NO_ERRCODE 103
ISR_NO_ERRCODE 104
ISR_NO_ERRCODE 105
ISR_NO_ERRCODE 106
ISR_NO_ERRCODE 107
ISR_NO_ERRCODE 108
ISR_NO_ERRCODE 109
ISR_NO_ERRCODE 110
ISR_NO_ERRCODE 111
ISR_NO_ERRCODE 112
ISR_NO_ERRCODE 113
ISR_NO_ERRCODE 114
ISR_NO_ERRCODE 115
ISR_NO_ERRCODE 116
ISR_NO_ERRCODE 117
ISR_NO_ERRCODE 118
ISR_NO_ERRCODE 119
ISR_NO_ERRCODE 120
ISR_NO_ERRCODE 121
ISR_NO_ERRCODE 122
ISR_NO_ERRCODE 123
ISR_NO_ERRCODE 124
ISR_NO_ERRCODE 125
ISR_NO_ERRCODE 126
ISR_NO_ERRCODE 127
ISR_NO_ERRCODE 128
ISR_NO_ERRCODE 129
ISR_NO_ERRCODE 130
ISR_NO_ERRCODE 131
ISR_NO_ERRCODE 132
ISR_NO_ERRCODE 133
ISR_NO_ERRCODE 134
ISR_NO_ERRCODE 135
ISR_NO_ERRCODE 136
ISR_NO_ERRCODE 137
ISR_NO_ERRCODE 138
ISR_NO_ERRCODE 139
ISR_NO_ERRCODE 140
ISR_NO_ERRCODE 141
ISR_NO_ERRCODE 142
ISR_NO_ERRCODE 143
ISR_NO_ERRCODE 144
ISR_NO_ERRCODE 145
ISR_NO_ERRCODE 146
ISR_NO_ERRCODE 147
ISR_NO_ERRCODE 148
ISR_NO_ERRCODE 149
ISR_NO_ERRCODE 150
ISR_NO_ERRCODE 151
ISR_NO_ERRCODE 152
ISR_NO_ERRCODE 153
ISR_NO_ERRCODE 154
ISR_NO_ERRCODE 155
ISR_NO_ERRCODE 156
ISR_NO_ERRCODE 157
ISR_NO_ERRCODE 158
ISR_NO_ERRCODE 159
ISR_NO_ERRCODE 160
ISR_NO_ERRCODE 161
ISR_NO_ERRCODE 162
ISR_NO_ERRCODE 163
ISR_NO_ERRCODE 164
ISR_NO_ERRCODE 165
ISR_NO_ERRCODE 166
ISR_NO_ERRCODE 167
ISR_NO_ERRCODE 168
ISR_NO_ERRCODE 169
ISR_NO_ERRCODE 170
ISR_NO_ERRCODE 171
ISR_NO_ERRCODE 172
ISR_NO_ERRCODE 173
ISR_NO_ERRCODE 174
ISR_NO_ERRCODE 175
ISR_NO_ERRCODE 176
ISR_NO_ERRCODE 177
ISR_NO_ERRCODE 178
ISR_NO_ERRCODE 179
ISR_NO_ERRCODE 180
ISR_NO_ERRCODE 181
ISR_NO_ERRCODE 182
ISR_NO_ERRCODE 183
ISR_NO_ERRCODE 184
ISR_NO_ERRCODE 185
ISR_NO_ERRCODE 186
ISR_NO_ERRCODE 187
ISR_NO_ERRCODE 188
ISR_NO_ERRCODE 189
ISR_NO_ERRCODE 190
ISR_NO_ERRCODE 191
ISR_NO_ERRCODE 192
ISR_NO_ERRCODE 193
ISR_NO_ERRCODE 194
ISR_NO_ERRCODE 195
ISR_NO_ERRCODE 196
ISR_NO_ERRCODE 197
ISR_NO_ERRCODE 198
ISR_NO_ERRCODE 199
ISR_NO_ERRCODE 200
ISR_NO_ERRCODE 201
ISR_NO_ERRCODE 202
ISR_NO_ERRCODE 203
ISR_NO_ERRCODE 204
ISR_NO_ERRCODE 205
ISR_NO_ERRCODE 206
ISR_NO_ERRCODE 207
ISR_NO_ERRCODE 208
ISR_NO_ERRCODE 209
ISR_NO_ERRCODE 210
ISR_NO_ERRCODE 211
ISR_NO_ERRCODE 212
ISR_NO_ERRCODE 213
ISR_NO_ERRCODE 214
ISR_NO_ERRCODE 215
ISR_NO_ERRCODE 216
ISR_NO_ERRCODE 217
ISR_NO_ERRCODE 218
ISR_NO_ERRCODE 219
ISR_NO_ERRCODE 220
ISR_NO_ERRCODE 221
ISR_NO_ERRCODE 222
ISR_NO_ERRCODE 223
ISR_NO_ERRCODE 224
ISR_NO_ERRCODE 225
ISR_NO_ERRCODE 226
ISR_NO_ERRCODE 227
ISR_NO_ERRCODE 228
ISR_NO_ERRCODE 229
ISR_NO_ERRCODE 230
ISR_NO_ERRCODE 231
ISR_NO_ERRCODE 232
ISR_NO_ERRCODE 233
ISR_NO_ERRCODE 234
ISR_NO_ERRCODE 235
ISR_NO_ERRCODE 236
ISR_NO_ERRCODE 237
ISR_NO_ERRCODE 238
ISR_NO_ERRCODE 239
ISR_NO_ERRCODE 240
ISR_NO_ERRCODE 241
ISR_NO_ERRCODE 242
ISR_NO_ERRCODE 243
ISR_NO_ERRCODE 244
ISR_NO_ERRCODE 245
ISR_NO_ERRCODE 246
ISR_NO_ERRCODE 247
ISR_NO_ERRCODE 248
ISR_NO_ERRCODE 249
ISR_NO_ERRCODE 250
ISR_NO_ERRCODE 251
ISR_NO_ERRCODE 252
ISR_NO_ERRCODE 253
ISR_NO_ERRCODE 254
ISR_NO_ERRCODE 255

.extern ISRDefaultHandler
ISRCommonStub:
	push %eax
	push %ecx
	push %edx
	push %ebx
	push %ebp
	push %esi
	push %edi
	
	push %ds
	push %es
	push %fs
	push %gs
	
	mov $0x10, %ax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs
	
	push %esp
	call ISRDefaultHandler
	add $4, %esp
	
	pop %gs
	pop %fs
	pop %es
	pop %ds
	
	pop %edi
	pop %esi
	pop %ebp
	pop %ebx
	pop %edx
	pop %ecx
	pop %eax
	
	add $8, %esp
	iret

.section .data

.global MultibootHeaderMagic
.global MultibootHeaderPointer
MultibootHeaderMagic:
	.int 0
MultibootHeaderPointer:
	.int 0

.section .bss

.align 4096
.global MmKernelDirectoryInt
MmKernelDirectoryInt:
.skip 4096
KernelPageTable1:
.skip 4096
KernelPageTable2:
.skip 4096
KernelPageTable3:
.skip 4096

.align 16
.skip 8192																												// 8 KiB for kernel stack
.global KernelStack
KernelStack:
