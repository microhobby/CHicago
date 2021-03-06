# File author is Ítalo Lima Marconato Matias
#
# Created on May 11 of 2018, at 13:14 BRT
# Last edited on October 19 of 2018, at 21:41 BRT

ARCH ?= x86
VERBOSE ?= false
DEBUG ?= false

ifeq ($(ARCH),x86)
	PREFIX ?= i686-elf-
	
	ifneq ($(SUBARCH),)
		UNSUPPORTED_ARCH := true
	endif
	
	ARCH_OBJECTS := start.s.o
	ARCH_OBJECTS += arch.c.o
	ARCH_OBJECTS += io/debug.c.o io/ide.c.o io/keyboard.c.o io/mbdisp.c.o
	ARCH_OBJECTS += io/mouse.c.o
	ARCH_OBJECTS += sys/gdt.c.o sys/idt.c.o sys/pit.c.o
	ARCH_OBJECTS += sys/process.c.o
	ARCH_OBJECTS += mm/pmm.c.o mm/vmm.c.o
	
	OBJCOPY_FORMAT := elf32-i386
	OBJCOPY_ARCH := i386
	
	LINKER_SCRIPT := link.ld
else ifeq ($(ARCH),arm)
	PREFIX ?= arm-none-eabi-
	SUBARCH ?= vexpress
	
	ARCH_OBJECTS := start.s.o
	ARCH_OBJECTS += arch.c.o
	ARCH_OBJECTS += io/debug.c.o
	
	ifeq ($(SUBARCH),vexpress)
		ARCH_AFLAGS	:= -march=armv7-a -mcpu=cortex-a15 -mfloat-abi=hard -mfpu=neon
		ARCH_CFLAGS := -march=armv7-a -mtune=cortex-a15 -mfloat-abi=hard -mfpu=neon
	else
		UNSUPPORTED_ARCH := true
	endif
	
	LINKER_SCRIPT := subarch/$(SUBARCH)/link.ld
else
	UNSUPPORTED_ARCH := true
endif

OBJECTS := main.c.o
OBJECTS += ds/list.c.o ds/stack.c.o
OBJECTS += gui/render.c.o gui/surface.c.o gui/window.c.o
OBJECTS += io/device.c.o io/display.c.o io/file.c.o
OBJECTS += io/dev/framebuffer.c.o io/dev/rawkeyboard.c.o io/dev/rawmouse.c.o io/dev/null.c.o
OBJECTS += io/dev/zero.c.o
OBJECTS += io/fs/devfs.c.o io/fs/iso9660.c.o
OBJECTS += mm/alloc.c.o mm/heap.c.o mm/pmm.c.o mm/ualloc.c.o
OBJECTS += mm/virt.c.o
OBJECTS += sys/process.c.o sys/rand.c.o sys/string.c.o

OTHER_OBJECTS := splash.bmp

ARCH_OBJECTS := $(addprefix build/arch/$(ARCH)/,$(ARCH_OBJECTS))
OBJECTS := $(addprefix build/,$(OBJECTS))
OTHER_OBJECTS := $(addsuffix .oo, $(addprefix build/,$(OTHER_OBJECTS)))
LINKER_SCRIPT := arch/$(ARCH)/$(LINKER_SCRIPT)

ifeq ($(SUBARCH),)
	KERNEL := build/chkrnl-$(ARCH)
else
	KERNEL := build/chkrnl-$(ARCH)_$(SUBARCH)
endif

ifneq ($(VERBOSE),true)
NOECHO := @
endif

all: $(KERNEL)

clean:
ifeq ($(UNSUPPORTED_ARCH),true)
	$(error Unsupported architecture $(ARCH))
endif
	$(NOECHO)rm -f $(ARCH_OBJECTS) $(OBJECTS) $(OTHER_OBJECTS) $(KERNEL)

clean-all:
ifeq ($(UNSUPPORTED_ARCH),true)
	$(error Unsupported architecture $(ARCH))
endif
	$(NOECHO)rm -rf build

remake: clean all
ifeq ($(UNSUPPORTED_ARCH),true)
	$(error Unsupported architecture $(ARCH))
endif

$(KERNEL): $(ARCH_OBJECTS) $(OBJECTS) $(OTHER_OBJECTS) $(LINKER_SCRIPT)
ifeq ($(UNSUPPORTED_ARCH),true)
	$(error Unsupported architecture $(ARCH))
endif
	$(NOECHO)echo Linking $@
	$(NOECHO)if [ ! -d $(dir $@) ]; then mkdir -p $(dir $@); fi
	$(NOECHO)$(PREFIX)gcc -T$(LINKER_SCRIPT) -ffreestanding -nostdlib -o $@ $(ARCH_OBJECTS) $(OBJECTS) $(OTHER_OBJECTS) $(ARCH_LDFLAGS) -lgcc

build/%.oo: %
ifeq ($(UNSUPPORTED_ARCH),true)
	$(error Unsupported architecture $(ARCH))
endif
	$(NOECHO)echo Compiling $<
	$(NOECHO)if [ ! -d $(dir $@) ]; then mkdir -p $(dir $@); fi
	$(NOECHO)$(PREFIX)objcopy -Ibinary -O$(OBJCOPY_FORMAT) -B$(OBJCOPY_ARCH) $< $@
	$(NOECHO)$(PREFIX)objcopy --rename-section .data=.rodata,alloc,load,readonly,data,contents $@ $@

build/%.s.o: %.s
ifeq ($(UNSUPPORTED_ARCH),true)
	$(error Unsupported architecture $(ARCH))
endif
	$(NOECHO)echo Compiling $<
	$(NOECHO)if [ ! -d $(dir $@) ]; then mkdir -p $(dir $@); fi
	$(NOECHO)$(PREFIX)as $(ARCH_AFLAGS) $< -o $@

build/%.c.o: %.c
ifeq ($(UNSUPPORTED_ARCH),true)
	$(error Unsupported architecture $(ARCH))
endif
	$(NOECHO)echo Compiling $<
	$(NOECHO)if [ ! -d $(dir $@) ]; then mkdir -p $(dir $@); fi
ifeq ($(SUBARCH),)
ifeq ($(DEBUG),yes)
	$(NOECHO)$(PREFIX)gcc -DARCH=\"$(ARCH)\" -DDEBUG -g -std=c11 -Iinclude -Iarch/$(ARCH)/include -ffreestanding -O0 -Wall -Wextra -Wno-implicit-fallthrough -Wno-pointer-to-int-cast -Wno-int-to-pointer-cast $(ARCH_CFLAGS) -c $< -o $@
else
	$(NOECHO)$(PREFIX)gcc -DARCH=\"$(ARCH)\" -std=c11 -Iinclude -Iarch/$(ARCH)/include -ffreestanding -O3 -Wall -Wextra -Wno-implicit-fallthrough -Wno-pointer-to-int-cast -Wno-int-to-pointer-cast $(ARCH_CFLAGS) -c $< -o $@
endif
else
ifeq ($(DEBUG),yes)
	$(NOECHO)$(PREFIX)gcc -DARCH=\"$(ARCH)\" -DDEBUG -g -std=c11 -Iinclude -Iarch/$(ARCH)/include -I arch/$(ARCH)/subarch/$(SUBARCH)/include -ffreestanding -O0 -Wall -Wextra -Wno-implicit-fallthrough -Wno-pointer-to-int-cast -Wno-int-to-pointer-cast $(ARCH_CFLAGS) -c $< -o $@
else
	$(NOECHO)$(PREFIX)gcc -DARCH=\"$(ARCH)\" -std=c11 -Iinclude -Iarch/$(ARCH)/include -I arch/$(ARCH)/subarch/$(SUBARCH)/include -ffreestanding -O3 -Wall -Wextra -Wno-implicit-fallthrough -Wno-pointer-to-int-cast -Wno-int-to-pointer-cast $(ARCH_CFLAGS) -c $< -o $@
endif
endif
