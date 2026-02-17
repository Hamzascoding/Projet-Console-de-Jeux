# FPGA Multi-Game Console

A VHDL project implementing a collection of four distinct mini-games on an FPGA. The system features a modular architecture with a central console manager, 7-segment display multiplexing, and pseudo-random number generation.

## 🎮 Included Games

The console features 4 games, selectable via the two leftmost switches (`SW 15` and `SW 14`).

### 1. Parity Check (Jeu Parité)
* **Select Code:** `00` (SW15=0, SW14=0)
* **Goal:** Guess if the randomly generated number (0-255) is Even or Odd.
* **Controls:**
    * `SW(0)`: Guess Even (Pair).
    * `SW(1)`: Guess Odd (Impair).
    * `BtnC`: Validate guess.
* **Display:** Shows the random number. Displays `CCCC` for correct or `FFFF` for failure.

### 2. The Price is Right (Juste Prix)
* **Select Code:** `01` (SW15=0, SW14=1)
* **Goal:** Guess the secret 4-bit number (0-15).
* **Controls:**
    * `SW(3:0)`: Enter your binary guess.
* **Display:**
    * `UP` (U): Secret number is higher.
    * `dn` (d): Secret number is lower.
    * `CCCC`: Correct guess!

### 3. GCD Calculator (Expert PGCD)
* **Select Code:** `10` (SW15=1, SW14=0)
* **Goal:** Computes the Greatest Common Divisor of two 4-bit numbers.
* **Controls:**
    * `SW(7:4)`: Input Number A.
    * `SW(3:0)`: Input Number B.
    * `RESTART`: Start Computation.
* **Display:** Shows inputs A and B in IDLE mode. Shows the Result when finished.

### 4. Memory Challenge (Jeu Mémoire)
* **Select Code:** `11` (SW15=1, SW14=1)
* **Goal:** Memorize and repeat a sequence of numbers. The sequence grows longer with every successful level.
* **Controls:**
    * `SW(3:0)`: Enter the number.
    * `BtnC`: Validate input.
* **Display:** Flashes the sequence to memorize, then waits for input.

---

## 🛠 Hardware Requirements

* **Board:** Digilent Basys3, Nexys4, or similar FPGA development board.
* **Inputs:** 16 Switches, 2 Push Buttons (Center & Restart).
* **Outputs:** 4-Digit 7-Segment Display.

## ⚙️ Technical Architecture

### Top Level (`console_jeux.vhd`)
The top-level entity acts as the operating system for the console.
* **Inputs:** Clock (100MHz), Switches, Buttons.
* **Debouncing:** Implements synchronization logic to prevent button metastability.
* **RNG:** A continuous 8-bit Linear Feedback Shift Register (LFSR) provides true randomness based on user interaction timing.
* **Display Driver:** Multiplexes the 4 active digits to drive the common-anode 7-segment display.

### Modules
| File | Description |
| :--- | :--- |
| `dec_sept_seg.vhd` | Hexadecimal decoder with custom characters (P, U, d, n). |
| `jeu_parite.vhd` | logic for parity verification and binary-to-decimal display conversion. |
| `juste_prix.vhd` | Comparator logic with real-time feedback (High/Low). |
| `expert_pgcd.vhd` | Implements Euclidean algorithm using a Finite State Machine (FSM). |
| `jeu_memoire.vhd` | FSM-based game with storage/generation of sequences. |

## 🚀 How to Run

1.  **Create Project:** Open Vivado (or your preferred ISE).
2.  **Add Sources:** Import all `.vhd` files provided in the `src/` folder.
3.  **Constraints:** Add the `.xdc` file mapping the ports to your specific board pins.
    * `CLK` -> 100MHz Oscillator
    * `SW` -> Switches 0-15
    * `SEG` -> Cathodes CA-CG
    * `AN` -> Anodes AN0-AN3
    * `btnC` -> Center Button
    * `RESTART` -> Up or Reset Button
4.  **Bitstream:** Run Synthesis, Implementation, and Generate Bitstream.
5.  **Program:** Connect your board via USB and program the device.

---
*Created by Abida Hamza Habib and Mansour Nouha*