interface FIFO_if (input logic clk);
    parameter WIDTH = 16;
    parameter DEPTH = 8;
    bit [WIDTH-1:0] data_in;
    bit rst_n , wr_en , rd_en ;
    bit underflow , overflow , wr_ack;
    bit [WIDTH-1:0] data_out;
    bit full , empty , almostfull , almostempty ;

    modport DUT (input data_in , rst_n , clk , wr_en , rd_en , output data_out , full , almostempty , almostfull , empty , overflow , underflow , wr_ack);
endinterface