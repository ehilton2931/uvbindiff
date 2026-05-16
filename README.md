# UVBinDiff
Ultraviolet Binary Diff - A reimagining of VBinDiff in D

## NOTE
While UVBinDiff is functional, its user experience is currently unfinished. That is, UVBinDiff currently does not have a man page, help message, or command palette. If you are uncomfortable with examining the source code to learn what functionality UVBinDiff supports, it is not recommended to use UVBinDiff at this time.

## License
Like the original VBinDiff, UVBinDiff is licensed under GPL v2 or later. (If you know how to make GitHub recognize v2 or later as opposed to just v2, feel free to file a PR!)

## Features
| Feature | UVBinDiff | VBinDiff |
|---|---|---|
| *n*-way diff | Up to 3 files | Up to 2 files |
| Starting address | Variable | Fixed at address 0 |
| Bytes per row | Variable | Fixed at 16 bytes per row |
| Integer width | 8-bit, 16-bit, and 32-bit data supported | Only 8-bit data supported |
| Alignedness | Unaligned and aligned data supported | Not applicable |
| Endianness | Little-endian and big-endian data supported | Not applicable |
| Signedness | Unsigned and signed data supported | Only unsigned data supported |
| Radix | Hexadecimal and decimal supported | Only hexadecimal supported |
| Character encoding | Only ASCII supported | ASCII and EBCDIC supported |
| Edit mode | Not supported | Supported |
| Find bytes | Not supported | Supported |
| Find text | Not supported | Supported |
| Goto absolute address | Not supported | Supported |
| Goto relative address | Not supported | Not supported |
| Goto next/previous difference | Next and previous difference supported | Only next difference supported |
