package coverage_collector;
    import uvm_pkg::*;
    import seqitem_pkg::*;
    `include "uvm_macros.svh"
    class FIFO_coverage_collector extends uvm_component;
        `uvm_component_utils(FIFO_coverage_collector)
        uvm_analysis_export #(FIFO_seqitem) cov_export;
        uvm_tlm_analysis_fifo #(FIFO_seqitem) cov_fifo;
        FIFO_seqitem F_cvg_txn;
        covergroup fifo_cg ;
            write_en : coverpoint F_cvg_txn.wr_en;
            read_en : coverpoint F_cvg_txn.rd_en;
            uf: coverpoint F_cvg_txn.underflow;
            of: coverpoint F_cvg_txn.overflow;
            fifo_full: coverpoint F_cvg_txn.full;
            fifo_af: coverpoint F_cvg_txn.almostfull;
            fifo_empty: coverpoint F_cvg_txn.empty;
            fifo_ae: coverpoint F_cvg_txn.almostempty;
            ack: coverpoint F_cvg_txn.wr_ack;
            //cross combinations
            //write operations
            write_comb1: cross write_en , of{
                ignore_bins imp1 = binsof(of)intersect {1} && binsof(write_en)intersect {0};
            }
            write_comb2: cross write_en , fifo_full;
            write_comb3: cross write_en , fifo_af;
            write_comb4: cross write_en , ack{
                ignore_bins imp2 = binsof(ack)intersect {1} && binsof(write_en)intersect {0};
            }
            //Read operations
            read_comb1: cross read_en , uf{
                ignore_bins imp3 = binsof(uf)intersect {1} && binsof(read_en)intersect {0};
            }
            read_comb2: cross read_en , fifo_empty;
            read_comb3: cross read_en , fifo_ae;
        endgroup

        function new(string name = "FIFO_coverage_collector", uvm_component parent = null);
        super.new(name, parent);
        fifo_cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cov_export = new("cov_export", this);
        cov_fifo = new("cov_fifo", this);
    endfunction
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        cov_export.connect(cov_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            cov_fifo.get(F_cvg_txn);
            fifo_cg.sample();  // Sample the correct covergroup
        end
    endtask

    endclass
endpackage