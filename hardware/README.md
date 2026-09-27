# Hardware Implementation

The processor was implemented on a Spartan-6 FPGA board using Xilinx ISE.

A clock divider was used to slow down processor execution, allowing the Fibonacci values to be observed on the onboard LEDs.

The lower 8 bits of register R7 are connected to the LED outputs:

```verilog
assign led = RegFile[7][7:0];
```

## Add your hardware photograph

Rename your clear Spartan-6 board/output photograph to:

`spartan6_led_output.jpg`

and place it in this folder.

After uploading the image, this README can be updated to display it:

```markdown
![Spartan-6 Hardware Output](spartan6_led_output.jpg)
```
