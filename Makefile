LINKER_OPTIONS=-melf_i386 -T linker.ld
COMPILER_OPTIONS=-Iinclude -c -m32 -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore
OBJECTS=bin/ata.o \
 				bin/loader.o \
				bin/interrupts.o \
				bin/gdt.o \
				bin/keyboard.o \
				bin/lib.o \
				bin/kernel.o \
				bin/interrupts_c.o \
				bin/gdt_c.o \
				bin/lib_c.o

bin/kernel.bin: $(OBJECTS)
	ld $(LINKER_OPTIONS) $(OBJECTS) -o $@

bin/%.o: src/%.cpp
	g++ $(COMPILER_OPTIONS) $< -o $@

bin/%.o: src/%.asm
	nasm $< -f elf -o $@

bin/loader.o: src/loader.s
	as --32 src/loader.s -o $@

bin/mykernel.iso: bin/kernel.bin
	mkdir iso
	mkdir iso/boot
	mkdir iso/boot/grub
	cp bin/kernel.bin iso/boot/mykernel.bin
	echo "set timeout=0" >> iso/boot/grub/grub.cfg
	echo "set default=0" >> iso/boot/grub/grub.cfg
	echo 'menuentry "Falcon OS" {' >> iso/boot/grub/grub.cfg
	echo "  multiboot /boot/mykernel.bin" >> iso/boot/grub/grub.cfg
	echo "  boot" >> iso/boot/grub/grub.cfg
	echo "}" >> iso/boot/grub/grub.cfg
	grub-mkrescue --output=bin/mykernel.iso iso
	rm -rf iso

.PHONY: install
install: bin/kernel.bin
	sudo cp bin/kernel.bin /boot/mykernel.bin

.PHONY : run
run: bin/mykernel.iso
	(killall VirtualBox && sleep 1) || true
	VirtualBox --startvm "Falcon OS" &

.PHONY : clean
clean:
	rm *.log || true
	rm -rf bin 
	mkdir bin
