package config_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class FIFO_config extends uvm_object;
    `uvm_object_utils(FIFO_config)
    virtual FIFO_if vif;
    function new(string name = "FIFO_config");
        super.new(name); //any one can make the object so i am not interested in the parent any more
    endfunction

endclass
endpackage