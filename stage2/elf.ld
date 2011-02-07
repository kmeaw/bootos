OUTPUT_FORMAT("elf64-powerpc")
OUTPUT_ARCH(powerpc:common64)

ENTRY(_entry)

PHDRS {
	text		PT_LOAD FLAGS(5);
	data		PT_LOAD FLAGS(6);
}

SECTIONS {
	. = 0x8000000000000000;
	_entry = 0x8000000000000100;
	.text : {
		*(.text)
		*(.text.*)
	} :text = 0x10000

	.data : {
		*(.data)
		*(.data.*)
		*(.sdata)
		*(.sdata.*)
	}
}
