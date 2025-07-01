import uvm_pkg::*;
`include "uvm_macros.svh"
import test_pkg::*;
import config_pkg::*;

module topmodule();
    // Clock generation
    bit clk;
    initial begin 
        clk = 0;
        forever #5 clk = ~clk; 
    end
    
    // Instance of the interface and the DUT
    FIFO_if #(.WIDTH(16), .DEPTH(8)) fif(.clk(clk));
    FIFO #(.FIFO_WIDTH(16), .FIFO_DEPTH(8)) DUT(
        .fifo_if(fif)
    );
    
    initial begin
        // Set the virtual interface in config DB
        uvm_config_db#(virtual FIFO_if)::set(null, "uvm_test_top", "FIFOvif", fif);
        run_test("FIFO_test");
    end

endmodule