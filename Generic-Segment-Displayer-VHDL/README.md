# Generic-Segment-Displayer-VHDL

### What each input means:

- `Clk_frequency` – Frequency of the input clock (in Hertz).
- `Digit_count` – Number of digits on the display.
- `Refresh_cycle_hz` – Refresh rate of the display (in Hertz).
- `Segment_count` – Number of segments per digit.
- `Active` – Logic level used by the display (`0` = active low, `1` = active high).
- `Seven_seg_info` – Combined information for all digits to display.
- `Clk` – Clock signal.
- `Rst` – Reset signal.
- `Current_digit` – Currently active digit (used in multiplexing).
- `Digit_selection` – Digit select line output (decoder-controlled).

---

### 🎥 Live Demonstration:

https://github.com/user-attachments/assets/308b1768-c6b7-412d-ab96-9bbed5c79ecc

<sub>Note: Shifting logic not included in Generic-Segment-Displayer code. It's implemented in the test file.</sub>
