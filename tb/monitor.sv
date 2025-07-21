`ifndef MONITOR_SV
`define MONITOR_SV

class monitor;
  virtual fifo_if.MONITOR vif;
  mailbox #(transaction) mon2scb_mbx;

  function new(virtual fifo_if.MONITOR vif, mailbox #(transaction) mon2scb_mbx);
    this.vif = vif;
    this.mon2scb_mbx = mon2scb_mbx;
  endfunction

  task run();
    transaction trans;
    forever begin
      @(vif.monitor_cb);
      
      if (vif.monitor_cb.wr && !vif.monitor_cb.full) begin
        trans = new();
        trans.data = vif.monitor_cb.wr_data;
        mon2scb_mbx.put(trans);
        trans.print("Monitor (Observed Write)");
      end
    end
  endtask
endclass

`endif
