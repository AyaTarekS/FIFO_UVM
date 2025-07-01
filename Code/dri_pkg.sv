package dri_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
import config_pkg::*;
import seqitem_pkg::*;
class FIFO_dri extends uvm_driver #(FIFO_seqitem);
    `uvm_component_utils(FIFO_dri)
    virtual FIFO_if FIFO_driver_vif;
    FIFO_config driver_con;
    FIFO_seqitem seq_item;

    function new(string name = "FIFO_dri", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            seq_item = FIFO_seqitem::type_id::create("seq_item");
            //getting the next item from the sequencer
            seq_item_port.get_next_item(seq_item);
            //driving all the inputs from the sequence item to the FIFO interface
            FIFO_driver_vif.rst_n = seq_item.rst_n;
            FIFO_driver_vif.rd_en = seq_item.rd_en;
            FIFO_driver_vif.wr_en = seq_item.wr_en;
            FIFO_driver_vif.data_in = seq_item.data_in;
            //to start sampling the data from the FIFO interface
            @(negedge FIFO_driver_vif.clk);
            seq_item_port.item_done();
            `uvm_info("run_phase",seq_item.convert2string_stimulus(),UVM_HIGH);
        end
    endtask
endclass
endpackage