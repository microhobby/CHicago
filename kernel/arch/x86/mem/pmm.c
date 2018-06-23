// File author is Ítalo Lima Marconato Matias
//
// Created on May 31 of 2018, at 18:45 BRT
// Last edited on June 21 of 2018, at 14:55 BRT

#define __CHICAGO_PMM__

#include <chicago/arch/multiboot.h>
#include <chicago/arch/pmm-int.h>

UInt32 PMMDumbAllocPointer = (UInt32)&KernelEnd;
PUInt32 PMMFrameMap = Null;
UInt32 PMMMemorySize = 0;
UInt32 PMMUsedFrames = 0;
UInt32 PMMMaxFrames = 0;
UInt32 KernelRealEnd = 0;

UInt32 PMMDumbAlloc(UInt32 size, Boolean align) {
	if (PMMDumbAllocPointer == (UInt32)Null) {																						// Disabled?
		return (UInt32)Null;																										// Yup!
	} else if (align) {																												// Align the pointer?
		UInt32 new = PMMDumbAllocPointer;																							// Yes (align by 0x1000, page size)
		
		if (size & 0xFFFFF000) {
			new &= 0xFFFFF000;
			new += 0x1000;
		}
		
		PMMDumbAllocPointer = new + size;
		
		return new;
	} else {
		UInt32 new = PMMDumbAllocPointer;																							// No, so just increase and return
		
		PMMDumbAllocPointer = new + size;
		
		return new;
	}
}

Int PMMFirstFreeFrame(Void) {
	for (UInt32 i = 0; i < PMMMaxFrames / 32; i++) {
		if (PMMFrameMap[i] != 0xFFFFFFFF) {
			for (Int j = 0; j < 32; j++) {
				if (!(PMMFrameMap[i] & (1 << j))) {
					return i * 4 * 8 + j;
				}
			}
		}
	}
	
	return -1;
}

UInt32 PMMAllocFrame(Void) {
	if ((PMMMaxFrames - PMMUsedFrames) <= 0) {
		return (UInt32)Null;
	}
	
	Int frame = PMMFirstFreeFrame();
	
	if (frame == -1) {
		return (UInt32)Null;
	}
	
	SET_BIT(frame);
	PMMUsedFrames++;
	
	return frame * 4096;
}

Void PMMFreeFrame(UInt32 frame) {
	CLEAR_BIT(frame / 4096);
	PMMUsedFrames--;
}

UInt32 PMMCountMemory(Void) {
	PMultibootMemoryMap mmap = (PMultibootMemoryMap)MultibootHeaderPointer->mmap_address;											// Here we're going to use the memory map for getting the memory size because mem_lower and mem_upper are obsolete
	UInt32 mmapi = 0;
	UInt32 memsize = 0;
	
	while ((UInt32)mmap < MultibootHeaderPointer->mmap_address + MultibootHeaderPointer->mmap_length) {
		if (mmap->type > 4) {																										// Valid?
			mmap->type = 2;																											// Nope, so let's set as reserved
		} else if ((mmapi > 0) && (mmap->base_low == 0)) {																			// End (before expected)?
			break;
		} else {
			if (mmap->type == 1) {																									// Add to memsize?
				memsize += mmap->length_low;																						// Yes
			}
		}
		
		mmap++;
		mmapi++;
	}
	
	return memsize;
}

Void PMMInit(Void) {
	PMMMemorySize = PMMCountMemory();																								// Get memory size BASED ON THE MEMORY MAP ENTRIES (mem_lower and mem_upper are obsolete)
	PMMMaxFrames = PMMMemorySize / 4096;
	PMMUsedFrames = PMMMaxFrames;
	
	PMMFrameMap = (PUInt32)PMMDumbAlloc(PMMMaxFrames, False);																		// Alloc the page frame allocator memory map using PMMDumbAlloc
	KernelRealEnd = PMMDumbAllocPointer;																							// This is the region just after the page frame allocator memory map
	PMMDumbAllocPointer = (UInt32)Null;																								// Break/disable the PMMDumbAlloc, now we should use MemoryAlloc/AlignedAlloc/Realloc/AlignedRealloc/ZAlloc/AlignedZAlloc/Free/AlignedFree
	
	for (UInt32 i = 0; i < PMMMaxFrames / 4; i++) {																					// TODO: Write a MemorySet function
		PMMFrameMap[i] = 0xFFFFFFFF;
	}
	
	PMultibootMemoryMap mmap = (PMultibootMemoryMap)MultibootHeaderPointer->mmap_address;
	UInt32 mmapi = 0;
	
	while ((UInt32)mmap < MultibootHeaderPointer->mmap_address + MultibootHeaderPointer->mmap_length) {
		if (mmap->type > 4) {																										// Valid?
			mmap->type = 2;																											// Nope, so let's set as reserved
		} else if ((mmapi > 0) && (mmap->base_low == 0)) {																			// End (before expected)?
			break;
		} else {
			if (mmap->type == 1) {																									// Avaliable for use?
				for (Int i = mmap->length_low / 4096, align = mmap->base_low / 4096; i > 0; i--, align++, PMMUsedFrames--) {		// Yes, so let's unset/free all the bits in this region!
					CLEAR_BIT(align);
				}
				
				SET_BIT(0);																											// If it unset the first bit of the pfmm, set it again
			}
		}
		
		mmap++;
		mmapi++;
	}
	
	{
		if (KernelRealEnd & 0xFFFFF000) {																							// Let's reserve from 0 'til the end of the memory map
			KernelRealEnd &= 0xFFFFF000;
			KernelRealEnd += 0x1000;
		}
		
		for (Int i = ((KernelRealEnd - 0xC0000000) - (((UInt32)(&KernelStart)) - 0xC0000000)) / 4096, align = (((UInt32)(&KernelStart)) - 0xC0000000) / 4096; i > 0; i--, align++, PMMUsedFrames++) {
			SET_BIT(align);
		}
	}
}
