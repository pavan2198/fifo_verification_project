# fifo_verification_project
sync_fifo_verification
# My FIFO Design Project

This is the project for my SoC Design Lab, where I built and tested a 16-bit synchronous FIFO.

I wrote the FIFO RTL in Verilog. Then I built a modular testbench in SystemVerilog to verify it. The main point was to practice setting up a real verification environment and testing the common FIFO scenarios.

---

## About the FIFO

It's a pretty standard synchronous FIFO. Everything happens on the `posedge clk`.

-   **Data Width:** 16 bits
-   **Depth:** 16 locations (since `ADDR_WIDTH` is 4)
-   **I/O Ports:** It has the usual ports, listed below.

| Port       | I/O    | Description                                    |
| :--------- | :----- | :--------------------------------------------- |
| `clk`      | Input  | The clock.                                     |
| `rst`      | Input  | Resets the pointers and makes the FIFO empty.  |
| `wr`       | Input  | Write enable.                                  |
| `rd`       | Input  | Read enable.                                   |
| `wr_data`  | Input  | The 16-bit data you want to write.             |
| `rd_data`  | Output | The 16-bit data that comes out.                |
| `full`     | Output | Goes high when you can't write anymore.        |
| `empty`    | Output | Goes high when there's nothing left to read.   |

---

## The Verification Plan

I set up the testbench to check 3 main things. The whole environment is self-checking, so the scoreboard will throw an error if the data read out doesn't match what was written in.

#### 1. Backpressure Checks

This is to make sure the `full` and `empty` signals work right and the FIFO doesn't break when it's pushed to its limits.

-   **Test Full:** I fill the FIFO all the way up and check that the `full` signal goes high. Then I try to do one more write, and my testbench makes sure the FIFO correctly ignores it (doesn't overwrite data).
-   **Test Empty:** After that, I read everything out until the `empty` signal goes high. Then I try to do one more read to make sure it doesn't give me garbage data.

#### 2. Simultaneous Reads and Writes

This test just hammers the FIFO with reads and writes at the same time to see if it can handle it. This is a good test for throughput. The idea is that for every clock cycle, one piece of data goes in and another comes out. The scoreboard running in the background makes sure the data isn't getting mixed up.

#### 3. Error Cases

This is basically a more direct check of the backpressure stuff.

-   **Write when full / Read when empty:** I created specific tests to try and write when the `full` flag is high, and read when the `empty` flag is high. The main goal here is to check the internal pointers and make sure they don't get corrupted and start pointing to the wrong memory locations. My `consumer` and `driver` in the testbench respect these flags, so if the simulation runs without them getting stuck or the scoreboard complaining, it means the design is handling these cases correctly.

---

## How to Run This

#### On EDA Playground
1.  Put `design.sv` in the **Design** window (left).
2.  Put all the other `.sv` files (the testbench stuff) in the **Testbench** window (right).
3.  Pick a simulator like Questa.
4.  Check the **"Open EPWave after run"** box so you can see the waveform.
5.  Hit Run.

#### On my machine
If you have Modelsim/Questa, you can just use a simple `.do` script to run this.

```tcl
# run.do
vlog *.sv
vsim testbench
add wave -r /*
run -all```
And then run from the command line: `vsim -c -do run.do`
