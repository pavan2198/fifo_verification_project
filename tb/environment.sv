`include "fifo_if.sv"
`include "transaction.sv"
`include "consumer.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

class environment;
  generator gen;
  driver    drv;
  monitor   mon;
  consumer  cons;
  scoreboard scb;

  mailbox #(transaction) gen2drv_mbx;
  mailbox #(transaction) mon2scb_mbx;
  mailbox #(transaction) cons2scb_mbx;

  virtual fifo_if fif_if;

  function new(virtual fifo_if fif_if);
    this.fif_if = fif_if;
    
    gen2drv_mbx = new();
    mon2scb_mbx = new();
    cons2scb_mbx = new();
    
    gen = new(gen2drv_mbx);
    drv = new(fif_if.DRIVER, gen2drv_mbx);
    mon = new(fif_if.MONITOR, mon2scb_mbx);
    cons = new(fif_if.DRIVER, cons2scb_mbx);
    scb = new(mon2scb_mbx, cons2scb_mbx);
  endfunction

  task pre_test();
    drv.drive_reset();
  endtask

  task test();
    fork
      gen.run();
      drv.run();
      mon.run();
      cons.run();
      scb.run();
    join_any
  endtask

  task post_test();
    wait(gen.repeat_count > 0 && (gen.repeat_count == scb.match_count));
    #100;
    $display("-------------------------------------------------");
    if (scb.mismatch_count == 0) begin
        $display("TEST PASSED: All %0d transactions matched!", scb.match_count);
    end else begin
        $error("TEST FAILED: %0d mismatches occurred.", scb.mismatch_count);
    end
    $display("-------------------------------------------------");
  endtask

  task run_test();
    pre_test();
    test();
    post_test();
  endtask
endclass
