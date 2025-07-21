`include "environment.sv"

module testbench;
  bit clk;
  always #5 clk = ~clk;

  fifo_if fif_if(clk);
  
  fifo_design dut (fif_if);

  environment env;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, testbench);

    env = new(fif_if);
    env.gen.repeat_count = 20;
    env.run_test();
    
    #2000;
    $finish;
  end

endmodule
