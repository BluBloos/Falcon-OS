# Falcon-OS 🦅 
My go at writing an operating system written in x86 assembly and C/C++.

## Features
The term "operating system" is used very loosely. In terms of user interaction, the user is able to interact with the system via a terminal interface. There are two commands.

Here's what's going on behind the scenes:

- The operating system functions as a bootable live CD, much like variuos Linux distributions 
- grub-mkresuce is used to make the .iso file
- grub loads the kernel, which does the following before handing off control to the custom terminal program
  - Sets up a program stack for use by the kernel
  - Sets up the global descriptor table
  - Sets up the interrupt descriptor table and enables interrupts

- The terminal program uses the following kernel functionality
  - Text printing to the screen via VGA text mode
  - Interrupt driven keyboard support via PS/2 controller IO ports
  
## Commands
Canonical "Hello, World!" program
```
$ hello
```
Prints out the first 10 numbers in the fibonacci sequence in hexidecimal. 
```
$ fib
```
## Build Steps
- NOTE: This project can only be built in a Linux environment, Windows users beware.

In order to run the operating system, it is preferred to sandbox it inside a virtual environment. The project is tested with the latest version of <a href="https://www.virtualbox.org/">Virtual Box</a> (Version 6.1 at the time of writing). Simply clone the project and run the following command inside the project directory
```
$ make bin/mykernel.iso
```
This will build the project and package the code into an ISO file. To run the operating system, create a new virtul machine in virtual box. Note that it is not needed to create a hard drive for the machine. Once you have created a new virtual machine, run the machine and load the ISO file into the optical drive.   
