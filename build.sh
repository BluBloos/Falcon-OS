#!/bin/bash

echo "Assembling..."
nasm bootloader.asm -f elf -o bin/bootloader.o
nasm kernel.asm -f elf -o bin/kernel.o
echo "Done"

echo "Linking..."
ld -m elf_i386 -T linker.ld bin/bootloader.o bin/kernel.o -o bin/output.o
objcopy bin/output.o -O binary bin/kernel.bin
echo "Done"

#make the iso file
echo "Creating ISO image"
mkdir iso
genisoimage -V "Falcon OS" -o bin/falcon.iso -G bin/kernel.bin iso
rm -R iso
echo "Done"
