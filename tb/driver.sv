`ifndef DRIVER_SV
`define DRIVER_SV

class driver;
  virtual fifo_if.DRIVER vif;
  mailbox #(transaction) gen2drv_mbx;

  function new(virtual fifo_if.DRIVER vif, mailbox #(transaction) gen2drv_mbx);
    this.vif = vif;
    this.gen2drv_mbx = gen2drv_mbx;
  endfunction

  task drive_reset();
    $display("Driver: Asserting reset.");
    vif.driver_cb.rst <= 1;
    vif.driver_cb.wr  <= 0;
    vif.driver_cb.rd  <= 0;
    vif.driver_cb.wr_data <= 0;
    repeat(2) @(vif.driver_cb);
    vif.driver_cb.rst <= 0;
    $display("Driver: De-asserting reset.");
    @(vif.driver_cb);
  endtask

  task run();
    forever begin
      transaction trans;
      gen2drv_mbx.get(trans);
      
      while (vif.driver_cb.full) begin
        $display("Driver: FIFO is full, waiting...");
        @(vif.driver_cb);
      end
      
      @(vif.driver_cb);
      vif.driver_cb.wr_data <= trans.data;
      vif.driver_cb.wr      <= 1'b1;
      trans.print("Driver");
      @(vif.driver_cb);
      vif.driver_cb.wr      <= 1'b0;
    end
  endtask
endclass

`endif
