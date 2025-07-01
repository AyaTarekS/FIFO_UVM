package monitor_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import seqitem_pkg::*;
    
    class FIFO_monitor extends uvm_monitor;
        `uvm_component_utils(FIFO_monitor)
        
        FIFO_seqitem seq_item;
        virtual FIFO_if vif;
        //to connect the analysis port to the agent 
        uvm_analysis_port #(FIFO_seqitem) mon_ap;
        
        function new(string name = "FIFO_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            mon_ap = new("mon_ap", this);
        endfunction

        task run_phase(uvm_phase phase); 
            super.run_phase(phase);
            forever begin
                seq_item = FIFO_seqitem::type_id::create("seq_item");
                // Wait for the clock edge to sample the signals
                @(negedge vif.clk);  
                
                // Sample all signals
                seq_item.rst_n = vif.rst_n;
                seq_item.rd_en = vif.rd_en;
                seq_item.wr_en = vif.wr_en;
                seq_item.wr_ack = vif.wr_ack;
                seq_item.data_in = vif.data_in;
                seq_item.data_out = vif.data_out;
                seq_item.full = vif.full;
                seq_item.almostfull = vif.almostfull;
                seq_item.empty = vif.empty;
                seq_item.almostempty = vif.almostempty;
                seq_item.overflow = vif.overflow;
                seq_item.underflow = vif.underflow;
                //function write to write the values
                mon_ap.write(seq_item);
                `uvm_info("run_phase", seq_item.convert2string(), UVM_HIGH);
            end
        endtask
    endclass
endpackage : monitor_pkg