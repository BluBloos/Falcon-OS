#!/bin/bash

COMPILER_OPTIONS="-c -m32 -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore"

echo "Killing Virtual Box"
(killall VirtualBox && sleep 1) || true

echo "Compiling..."
g++ $COMPILER_OPTIONS lib.cpp -o bin/lib.o
g++ $COMPILER_OPTIONS interrupts.cpp -o bin/interrupts.o
g++ $COMPILER_OPTIONS gdt.cpp -o bin/gdt.o
echo "Done"

echo "Assembling..."
nasm keyboard.asm -f elf -o bin/keyboard.o
nasm kernel.asm -f elf -o bin/kernel.o
nasm interrupts.asm -f elf -o bin/interruptsasm.o
nasm gdt.asm -f elf -o bin/gdtasm.o
as --32 grub/loader.s -o bin/grub/loader.o
echo "Done"

echo "Linking..."
ld -melf_i386 -T grub/linker.ld bin/grub/loader.o bin/interruptsasm.o bin/gdtasm.o bin/keyboard.o bin/lib.o bin/kernel.o bin/interrupts.o bin/gdt.o -o bin/grub/kernel.bin
echo "Done"

echo "Installing..."
sudo cp bin/grub/kernel.bin /boot/mykernel.bin
echo "Done"

echo "Creating ISO image"
mkdir iso
mkdir iso/boot
mkdir iso/boot/grub
cp bin/grub/kernel.bin iso/boot/mykernel.bin
echo "set timeout=0" >> iso/boot/grub/grub.cfg
echo "set default=0" >> iso/boot/grub/grub.cfg
echo 'menuentry "Falcon OS" {' >> iso/boot/grub/grub.cfg
echo "  multiboot /boot/mykernel.bin" >> iso/boot/grub/grub.cfg
echo "  boot" >> iso/boot/grub/grub.cfg
echo "}" >> iso/boot/grub/grub.cfg
grub-mkrescue --output=bin/grub/mykernel.iso iso
rm -rf iso
echo "Done"

echo "Starting Virtual Box..."
VirtualBox --startvm "Falcon OS" &
