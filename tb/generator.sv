`ifndef GENERATOR_SV
`define GENERATOR_SV

class generator;
  mailbox #(transaction) gen2drv_mbx;
  int repeat_count;

  function new(mailbox #(transaction) gen2drv_mbx);
    this.gen2drv_mbx = gen2drv_mbx;
  endfunction

  task run();
    transaction trans;
    repeat (repeat_count) begin
      trans = new();
      if (!trans.randomize()) $fatal("Generator: Transaction randomization failed");
      trans.print("Generator");
      gen2drv_mbx.put(trans);
    end
  endtask
endclass

`endif
