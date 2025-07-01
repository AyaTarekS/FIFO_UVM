package scoreboard_pkg;

import uvm_pkg::*;
import seqitem_pkg::*;
`include "uvm_macros.svh"

class FIFO_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(FIFO_scoreboard)
    // analysis port to connect the scoreboard to the agent
    uvm_analysis_port #(FIFO_seqitem) sb_ap;
    //
    uvm_tlm_analysis_fifo#(FIFO_seqitem) sb_fifo;
    FIFO_seqitem sb_item;
    
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;
    
    // Reference model outputs
    bit [FIFO_WIDTH-1:0] data_out_ref;
    bit full_ref, almostfull_ref, empty_ref, almostempty_ref;
    bit overflow_ref, underflow_ref, wr_ack_ref;
    
    // Tracking variables in reference model
    int counter;
    bit [FIFO_WIDTH-1:0] queue[$];
    int error_count = 0;
    int correct_count = 0;

    function new(string name = "FIFO_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sb_fifo = new("sb_fifo", this);
        sb_ap = new("sb_ap", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        sb_ap.connect(sb_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        logic [6:0] flags_ref, flags_dut;  // for concatenating the flags
        
        super.run_phase(phase);
        
        forever begin
            sb_fifo.get(sb_item);
            reference_model(sb_item);

            flags_ref = {wr_ack_ref, sb_item.overflow, full_ref, empty_ref, 
                        almostfull_ref, almostempty_ref, underflow_ref};
            flags_dut = {sb_item.wr_ack, sb_item.overflow, sb_item.full, 
                        sb_item.empty, sb_item.almostfull, sb_item.almostempty, 
                        sb_item.underflow};

            if((sb_item.data_out !== data_out_ref) || (flags_dut !== flags_ref)) begin
                if(sb_item.data_out !== data_out_ref) begin
                    `uvm_error("SCOREBOARD", 
                        $sformatf("Data mismatch! DUT: %0h, REF: %0h", 
                        sb_item.data_out, data_out_ref))
                end
                
                if(flags_dut !== flags_ref) begin
                    `uvm_error("SCOREBOARD", 
                        $sformatf("Flags mismatch! DUT: %07b, REF: %07b", 
                        flags_dut, flags_ref))
                end
                
                error_count++;
            end
            else begin
                correct_count++;
            end
        end
    endtask

    function void reference_model(input FIFO_seqitem obj_gold);
        // Write Operation
        if (!obj_gold.rst_n) begin
            wr_ack_ref = 0;
            full_ref = 0;
            almostfull_ref = 0;
            overflow_ref = 0;
            queue.delete();    
        end
        else if (obj_gold.wr_en && (counter < FIFO_DEPTH)) begin  
            queue.push_back(obj_gold.data_in);
            wr_ack_ref = 1;
            overflow_ref = 0;
        end
        else begin 
            wr_ack_ref = 0; 
            if (full_ref && obj_gold.wr_en)
                overflow_ref = 1;
            else
                overflow_ref = 0;
        end

        // Read Operation
        if(!obj_gold.rst_n) begin
            empty_ref = 1;
            almostempty_ref = 0;
            underflow_ref = 0;
        end
        else if (obj_gold.rd_en && counter != 0) begin   
            data_out_ref = queue.pop_front();
        end
        else begin
            if(empty_ref && obj_gold.rd_en)
                underflow_ref = 1;
            else
                underflow_ref = 0;
        end                

        // Counter Operation
        if(!obj_gold.rst_n) begin
            counter = 0;
        end
        else if (({obj_gold.wr_en, obj_gold.rd_en} == 2'b10) && !full_ref) 
            counter = counter + 1;
        else if (({obj_gold.wr_en, obj_gold.rd_en} == 2'b01) && !empty_ref)
            counter = counter - 1;
        else if (({obj_gold.wr_en, obj_gold.rd_en} == 2'b11) && full_ref)
            counter = counter - 1;
        else if (({obj_gold.wr_en, obj_gold.rd_en} == 2'b11) && empty_ref)
            counter = counter + 1;

        // Update combinational flags
        full_ref = (counter == FIFO_DEPTH);     
        empty_ref = (counter == 0);
        almostfull_ref = (counter == FIFO_DEPTH-1);         
        almostempty_ref = (counter == 1);
    endfunction 
    
    // Report phase to display the final results
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCOREBOARD", 
            $sformatf("Test Complete: %0d Correct, %0d Errors", 
            correct_count, error_count), UVM_MEDIUM);
    endfunction
endclass

endpackage