`ifndef CONSUMER_SV
`define CONSUMER_SV

class consumer;
  virtual fifo_if.DRIVER vif;
  mailbox #(transaction) cons2scb_mbx;

  function new(virtual fifo_if.DRIVER vif, mailbox #(transaction) cons2scb_mbx);
    this.vif = vif;
    this.cons2scb_mbx = cons2scb_mbx;
  endfunction

  task run();
    forever begin
      @(vif.driver_cb);
      
      if (!vif.driver_cb.empty) begin
        transaction trans;
        
        vif.driver_cb.rd <= 1'b1;
        
        @(vif.driver_cb);
        
        vif.driver_cb.rd <= 1'b0;
        
        trans = new();
        trans.data = vif.driver_cb.rd_data;
        cons2scb_mbx.put(trans);
        trans.print("Consumer (Read Data)");
      end
    end
  endtask
endclass

`endif
