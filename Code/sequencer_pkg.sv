package sequencer_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import seqitem_pkg::*;
    
    class FIFO_sequencer extends uvm_sequencer #(FIFO_seqitem);
        `uvm_component_utils(FIFO_sequencer)
        
        function new(string name = "FIFO_sequencer", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass
endpackage