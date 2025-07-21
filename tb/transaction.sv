`ifndef TRANSACTION_SV
`define TRANSACTION_SV

class transaction;
  rand bit [15:0] data;

  function void print(string tag = "Transaction");
    $display("[%s] Data: %h", tag, data);
  endfunction
endclass

`endif
