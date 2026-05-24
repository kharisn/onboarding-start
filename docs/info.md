<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements an SPI peripheral that receives configuration
commands and uses them to control 16 output pins via PWM signals.

## Inputs

- ui[0]: SCLK - SPI Clock
- ui[1]: COPI - SPI Data In
- ui[2]: nCS - Chip Select (active low)

## Outputs

- uo[0-7]: Output pins 0-7
- uio[0-7]: Output pins 8-15

## Register Map

- 0x00: Output enable for uo_out[7:0]
- 0x01: Output enable for uio_out[7:0]
- 0x02: PWM enable for uo_out[7:0]
- 0x03: PWM enable for uio_out[7:0]
- 0x04: PWM duty cycle (0x00=0%, 0xFF=100%)

## How to test

Explain how to use your project

## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
