`include "fifo_if.sv"

module fifo_design #(parameter DATA_WIDTH = 16, parameter ADDR_WIDTH = 4)
  (fifo_if.DUT fif_if);

  localparam DEPTH = 1 << ADDR_WIDTH;

  reg [DATA_WIDTH-1:0] mem [DEPTH-1:0];
  reg [ADDR_WIDTH-1:0] wr_ptr, rd_ptr;
  reg [ADDR_WIDTH:0]   status_cnt;

  assign fif_if.full = (status_cnt == DEPTH);
  assign fif_if.empty = (status_cnt == 0);
  assign fif_if.rd_data = mem[rd_ptr];

  always @(posedge fif_if.clk or posedge fif_if.rst) begin
    if (fif_if.rst) begin
      wr_ptr <= 0;
      rd_ptr <= 0;
      status_cnt <= 0;
      for (int i=0; i<DEPTH; i++)
        mem[i] <= 'x;
    end else begin
      
      logic do_write = fif_if.wr && !fif_if.full;
      logic do_read  = fif_if.rd && !fif_if.empty;
      
      if (do_write && !do_read) begin
        status_cnt <= status_cnt + 1;
      end else if (!do_write && do_read) begin
        status_cnt <= status_cnt - 1;
      end else begin
        status_cnt <= status_cnt;
      end
      
      if (do_write) begin
        mem[wr_ptr] <= fif_if.wr_data;
        wr_ptr <= wr_ptr + 1;
      end
      
      if (do_read) begin
        rd_ptr <= rd_ptr + 1;
      end
      
    end
  end
endmodule
