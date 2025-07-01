package seqitem_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    parameter MAXPOS = 7;
    parameter MAXNEG = -8;
    parameter ZERO = 0;
    typedef enum bit [2:0] {OR , XOR , ADD , MULT , SHIFT , ROTATE , INVALID_6 , INVALID_7} opcode_e;
    class FIFO_seqitem extends uvm_sequence_item;
    `uvm_object_utils(FIFO_seqitem)
    parameter WIDTH = 16;
    parameter DEPTH = 8;
    parameter max_fifo_addr = $clog2(DEPTH);
    
    rand logic [WIDTH-1:0] data_in;
    rand logic rst_n, wr_en, rd_en;

    // Outputs
    logic [WIDTH-1:0] data_out;
    logic underflow, overflow;
    logic full, empty, almostfull, almostempty, wr_ack;
    
    // Distribution variables
    int RD_EN_ON_DIST = 30;
    int WR_EN_ON_DIST = 70;
    
    // Constraints
    constraint reset_c {
        rst_n dist {0 := 2, 1 := 98};  // 2% chance of reset
    }
    
    constraint write_en_c {
        wr_en dist {1 := WR_EN_ON_DIST, 0 := 100-WR_EN_ON_DIST};
    }
    
    constraint read_en_c {
        rd_en dist {1 := RD_EN_ON_DIST, 0 := 100-RD_EN_ON_DIST};
    }
    // constraints for the read and write enable signals separately
       constraint read_only_c{
        rd_en == 1;
        wr_en == 0; rst_n == 1;
    }
    constraint write_only_c{
        rd_en == 0;
        wr_en == 1; rst_n == 1;
    }

    
    
    function new(string name = "FIFO_seqitem");
        super.new(name);
    endfunction
    
    function string convert2string();
        return $sformatf("data_in=%0h, rst_n=%0b, wr_en=%0b, rd_en=%0b, data_out=%0h, " +
                         "wr_ack=%0b, overflow=%0b, full=%0b, empty=%0b, " +
                         "almostfull=%0b, almostempty=%0b, underflow=%0b",
                         data_in, rst_n, wr_en, rd_en, data_out,
                         wr_ack, overflow, full, empty,
                         almostfull, almostempty, underflow);
    endfunction
    
    function string convert2string_stimulus();
        return $sformatf("data_in=%0h, rst_n=%0b, wr_en=%0b, rd_en=%0b",
                        data_in, rst_n, wr_en, rd_en);
    endfunction
endclass
endpackage