# SHA-256 in TL-Verilog

A hardware implementation of the SHA-256 cryptographic hash algorithm
using TL-Verilog and Makerchip.

The design implements SHA-256 message preprocessing, message scheduling,
the 64-round compression function, and generation of the final 256-bit
digest.

## TL-Verilog

**TL-Verilog (Transaction-Level Verilog)** extends Verilog with a
transaction-based, pipeline-oriented design methodology.

Its key feature is timing abstraction: pipeline stages and timing can
be described directly in the design, while implementation details such
as staging flip-flops and signal plumbing are generated automatically.

This makes RTL more concise and makes it easier to change pipeline timing
without manually restructuring the associated registers and logic.

Compared with traditional Verilog, TL-Verilog reduces the amount of
explicit pipeline and timing management required, allowing the focus to
remain on the hardware behavior and its pipeline structure.

## SHA-256

SHA-256 takes an input message and produces a 256-bit hash.

The implementation includes:
* Message padding
* Splitting the message into 512-bit blocks
* Creating the 64-word message schedule
* 64 SHA-256 compression rounds
* `Ch` and `Maj` functions
* Small sigma functions
* Big sigma functions
* SHA-256 round constants
* Initial hash values
* Support for multiple message blocks
* 256-bit hash output


