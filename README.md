
![Screen Recording 2022-03-02 at 8 29 42 AM](https://user-images.githubusercontent.com/38915815/156371295-d5505f12-caea-42b8-a043-93c5b217eed9.gif)

# Falcon-OS 🦅 
My go at writing an operating system - written in x86 assembly and C/C++.

The term "operating system" is used very loosely. There is a terminal, and there exists two commands. That's it.

## Commands
Canonical "Hello, World!" program

```bash
hello
```
Prints out the first 10 numbers of the fibonacci sequence in hexadecimal. 

```bash
fib
```

# Steps for Building

This project can only be built in a Linux environment - Windows and macOS users beware.

When building this project, I run Ubuntu 20.04.3 in VirtualBox. The OS is built as a binary that is then loaded via grub. 

I am unsure if the project will work when running Ubuntu as a native host. My best guess is that this should work as well.

Start by cloning the repo and installing the necessary tools for building the OS.

```bash
sudo apt-get install make nasm
```

To build and install the OS binary, run make

```
make install
```

To run the OS, it will depend on the configuration of your Ubuntu install. We run the OS by selecting "Falcon OS" as a menu option in grub. On a default Ubuntu install, the grub menu is disabled.

## Enabling the grub menu

The following instructions are in reference to this stack exchange discussion: https://askubuntu.com/questions/182248/why-is-grub-menu-not-shown-when-starting-my-computer


Open /etc/default/grub

```
sudo nano /etc/default/grub
```

Comment out the lines "GRUB_TIMEOUT_STYLE=hidden" and "GRUB_TIMEOUT=0". Also uncomment "GRUB_TERMINAL=console".

Write to the file with ctrl+o and close nano with ctrl+x.

Finally, we must insert a menu entry for our OS into grub.cfg. Run make install again.

```
make install
```

Simply reboot your computer (or the VirtualBox VM), then select "Falcon OS" from the menu.

# Features

- grub loads the kernel, which does the following before handing off control to the custom terminal program
  - Sets up a program stack
  - Sets up the global descriptor table
  - Sets up the interrupt descriptor table and enables interrupts

- The terminal program uses the following kernel functionality
  - Text printing to the screen via VGA text mode
  - Interrupt driven keyboard support via PS/2 controller IO ports
  


