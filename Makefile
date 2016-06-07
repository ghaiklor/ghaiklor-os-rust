# Define variables
ARCH ?= x86_64
TARGET ?= $(ARCH)-unknown-linux-gnu
RUST_OS := target/$(TARGET)/debug/libghaiklor_os_rust.a
KERNEL := build/kernel-$(ARCH).bin
ISO := build/os-$(ARCH).iso

LINKER_SCRIPT := src/arch/$(ARCH)/linker.ld
GRUB_CFG := src/arch/$(ARCH)/grub.cfg

ASM_SOURCE_FILES := $(shell find src/arch/$(ARCH) -name '*.asm')
ASM_OBJECT_FILES := $(patsubst src/arch/$(ARCH)/%.asm, build/arch/$(ARCH)/%.o, $(ASM_SOURCE_FILES))

ASM = nasm
LD = ld

ifeq ($(shell uname -s),Darwin)
	LD = x86_64-elf-ld
endif

all: iso

clean:
	cargo clean
	rm -rf build

run: $(ISO)
	qemu-system-x86_64 -cdrom $(ISO)

iso: $(ISO)

cargo:
	cargo build --target $(TARGET)

# Make bootable ISO image from kernel and Grub configuration
$(ISO): $(KERNEL) $(GRUB_CFG)
	mkdir -p build/isofiles/boot/grub
	cp $(KERNEL) build/isofiles/boot/kernel.bin
	cp $(GRUB_CFG) build/isofiles/boot/grub
	grub-mkrescue -o $(ISO) build/isofiles
	rm -rf build/isofiles

# Link all object files and compile kernel.bin
$(KERNEL): cargo $(RUST_OS) $(ASM_OBJECT_FILES) $(LINKER_SCRIPT)
	$(LD) -n --gc-sections -o $(KERNEL) -T $(LINKER_SCRIPT) $(ASM_OBJECT_FILES) $(RUST_OS)

# Compile our assembly files
build/arch/$(ARCH)/%.o: src/arch/$(ARCH)/%.asm
	mkdir -p $(shell dirname $@)
	$(ASM) -f elf64 -o $@ $<
