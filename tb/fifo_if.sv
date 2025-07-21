`ifndef FIFO_IF_SV
`define FIFO_IF_SV

interface fifo_if (input bit clk);
  logic rst;
  logic wr;
  logic rd;
  logic [15:0] wr_data;
  logic [15:0] rd_data;
  logic full;
  logic empty;

  clocking driver_cb @(posedge clk);
    output rst, wr, rd, wr_data;
    input  rd_data, full, empty;
  endclocking

  clocking monitor_cb @(posedge clk);
    input rst, wr, rd, wr_data, rd_data, full, empty;
  endclocking

  modport DRIVER (clocking driver_cb);
  modport MONITOR (clocking monitor_cb);
  modport DUT (input clk, rst, wr, rd, wr_data, output rd_data, full, empty);

endinterface

`endif
