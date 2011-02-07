#!/bin/sh
make stage2_native.bin || exit 1
powerpc64-unknown-linux-gnu-gcc elf.S -o elf.o -nostdlib -T elf.ld
powerpc64-unknown-linux-gnu-strip -R .symtab -R .strtab elf.o
~/src/ps3tools/makeself lv2 355 3.55.0 05000002 1050000003000001 retail elf.o lv2_kernel.self
echo Size is `stat -c %s lv2_kernel.self`.

