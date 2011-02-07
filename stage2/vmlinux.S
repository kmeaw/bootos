.globl __vmlinux
.globl __vmlinux_end

__vmlinux:
.incbin "vmlinux.dat"
__vmlinux_end:
.space 1

