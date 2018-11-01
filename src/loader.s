.set MAGIC, 0x1BADB002
.set FLAGS, (1<<0 | 1<<1)
.set CHECKSUM, -(MAGIC + FLAGS)

.section .multiboot
  .align 4
  .long MAGIC
  .long FLAGS
  .long CHECKSUM

.section .text
.extern Kernel
.global loader

loader:
  mov $kernel_stack, %esp
  call Kernel

loader_stop:
  hlt
  jmp loader_stop

# note the bss section is where statically allocated variables go
.section .bss
.space 2*1024*1024
kernel_stack:
