`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV

class scoreboard;
  mailbox #(transaction) mon2scb_mbx;
  mailbox #(transaction) cons2scb_mbx;

  transaction expected_q[$];
  
  int match_count = 0;
  int mismatch_count = 0;

  function new(mailbox #(transaction) mon2scb_mbx, mailbox #(transaction) cons2scb_mbx);
    this.mon2scb_mbx = mon2scb_mbx;
    this.cons2scb_mbx = cons2scb_mbx;
  endfunction

  task collect_input();
    transaction trans;
    forever begin
      mon2scb_mbx.get(trans);
      expected_q.push_back(trans);
      trans.print("Scoreboard (Expected item pushed)");
    end
  endtask
  
  task check_output();
    transaction expected_trans, actual_trans;
    forever begin
      cons2scb_mbx.get(actual_trans);
      
      if (expected_q.size() == 0) begin
        $error("SCOREBOARD FATAL: Data was read from FIFO, but none was expected!");
        mismatch_count++;
        continue;
      end
      
      expected_trans = expected_q.pop_front();
      
      if (expected_trans.data == actual_trans.data) begin
        $display("SCOREBOARD MATCH: Expected %h, Got %h", expected_trans.data, actual_trans.data);
        match_count++;
      end else begin
        $error("SCOREBOARD MISMATCH: Expected %h, Got %h", expected_trans.data, actual_trans.data);
        mismatch_count++;
      end
    end
  endtask

  task run();
    fork
      collect_input();
      check_output();
    join
  endtask

endclass

`endif
