#  Stage2 Makefile
#
# Copyright (C) 2010-2011  Hector Martin "marcan" <hector@marcansoft.com>
#
# This code is licensed to you under the terms of the GNU GPL, version 2;
# see file COPYING or http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

include ../common/ppu.mak

DTC=dtc
LZMA=lzma

STUB_LDFLAGS := $(LDFLAGS) -Wl,--gc-sections -Wl,-T,uncompress/stub.ld
LDFLAGS += -Wl,--gc-sections
STUB_CFLAGS := $(CFLAGS) -Os -Wall -ffunction-sections -I. -Iuncompress/
CFLAGS += -Os -Wall -I. -ffunction-sections -fdata-sections \
	-Ilwip/src/include -Ilwip/src/include/ipv4 -Ilwip/arch/include -Ilibfdt
ASFLAGS = -D__ASSEMBLY__ -I.

DEPDIR = .deps

LWIP_OBJS = \
	$(addprefix lwip/src/core/,\
		dhcp.o init.o mem.o memp.o netif.o pbuf.o raw.o stats.o sys.o \
		tcp.o tcp_in.o tcp_out.o udp.o) \
	$(addprefix lwip/src/core/ipv4/,\
		autoip.o icmp.o ip.o ip_addr.o ip_frag.o inet_chksum.o) \
	$(addprefix lwip/src/api/,\
		tcpip.o err.o netifapi.o api_lib.o api_msg.o sockets.o) \
	lwip/src/netif/etharp.o

FDT_OBJS = $(addprefix libfdt/,\
	fdt.o fdt_ro.o fdt_rw.o fdt_strerror.o fdt_sw.o fdt_wip.o)

CORE_OBJS = main.o debug.o hvcall.o string.o printf.o device.o malloc.o \
	time.o tftp.o gelic_netif.o exceptions.o exc_vector.o mm.o netrpc.o \
	cleanup.o devtree.o kernel.o kbootconf.o network.o diskio.o ff.o \
	inflate.o crc32.o adler32.o inftrees.o zutil.o inffast.o zpipe.o \
	$(LWIP_OBJS) $(FDT_OBJS)

OBJS = start.o $(CORE_OBJS) vmlinux.o
OBJS_NATIVE = start_native.o $(CORE_OBJS) vmlinux.o

STUB_OBJS = uncompress/stub_start.o uncompress/unlzma.o

all: stage2.bin stage2_native.bin lv2_kernel.self

.PRECIOUS: stage2_raw.bin

vmlinux.o: vmlinux.dat vmlinux.S

vmlinux.bin:

stage2.bin : uncompress/stub.bin stage2_raw.lzma
	cat uncompress/stub.bin stage2_raw.lzma > $@

elf.o: elf.S stage2_native.bin
	$(PREFIX)gcc elf.S -o elf.o -nostdlib -T elf.ld
	$(PREFIX)strip -R .symtab -R .strtab elf.o

lv2_kernel.self: elf.o
	makeself lv2 355 3.55.0 05000002 1050000003000001 retail elf.o lv2_kernel.self

%.lzma: %.bin
	@echo "  LZMA      $@"
	@$(LZMA) -c $< > $@.tmp
	@dd if=$@.tmp bs=1 count=1 > $@ 2>/dev/null
	@dd if=$@.tmp bs=13 skip=1 >> $@ 2>/dev/null
	@rm $@.tmp

%.bin: %.elf
	@echo "  OBJCOPY   $@"
	@$(PREFIX)objcopy -O binary $< $@

uncompress/stub.elf: $(STUB_OBJS) uncompress/stub.ld
	@echo "  LINK      $@"
	@$(PREFIX)gcc $(STUB_LDFLAGS) -o $@ $(STUB_OBJS)

stage2_native.elf: $(OBJS_NATIVE) stage2_native.ld
	@echo "  LINK      $@"
	@$(PREFIX)gcc $(LDFLAGS) -Wl,-T,stage2_native.ld -o tmp_$@ $(OBJS_NATIVE)
	@# move everything down to zero, it will relocate itself on startup
	@# this could be done in the linker script for lma, but Sony fails and needs it for vma.
	@$(PREFIX)objcopy --adjust-vma -0xc00000 tmp_$@ $@
	@rm -f tmp_$@

stage2_raw.elf: $(OBJS) stage2.ld
	@echo "  LINK      $@"
	$(PREFIX)gcc $(LDFLAGS) -Wl,-T,stage2.ld -o $@ $(OBJS)

%.S: %.dts
	@echo "  DTC       $<"
	@$(DTC) -o $@ -O asm $<

%.o: %.S
	@echo "  ASSEMBLE  $<"
	@mkdir -p $(DEPDIR)
	@$(PREFIX)gcc $(ASFLAGS) -Wp,-MMD,$(DEPDIR)/$(*F).d,-MQ,"$@",-MP -c -o $@ $<

%.o: %.c
	@echo "  COMPILE   $<"
	@mkdir -p $(DEPDIR)
	@$(PREFIX)gcc $(CFLAGS) -Wp,-MMD,$(DEPDIR)/$(*F).d,-MQ,"$@",-MP -c -o $@ $<

clean:
	rm -rf $(DEPDIR)
	rm -f $(OBJS) *.elf *.bin *.lzma
	rm -f $(STUB_OBJS)

-include $(DEPDIR)/*

.PHONY: clean
