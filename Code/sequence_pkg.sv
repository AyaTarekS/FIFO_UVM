package sequence_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import seqitem_pkg::*;
    
    class FIFO_rst_sequence extends uvm_sequence #(FIFO_seqitem);
        `uvm_object_utils(FIFO_rst_sequence)  // Fixed typo in macro
        FIFO_seqitem seq_item;
        
        function new(string name = "FIFO_rst_sequence");
            super.new(name);
        endfunction
        //to run the sequence and start the item
        task body();
            seq_item = FIFO_seqitem::type_id::create("seq_item");
            start_item(seq_item);
            seq_item.rst_n = 0;
            finish_item(seq_item);
        endtask
    endclass
    // making sure the reset enable is asserted
    class FIFO_write_sequence extends uvm_sequence #(FIFO_seqitem);
        `uvm_object_utils(FIFO_write_sequence)  
        FIFO_seqitem seq_item;
        function new(string name = "FIFO_write_sequence");
            super.new(name);
        endfunction
        task body();
            repeat(1000)begin
                seq_item = FIFO_seqitem::type_id::create("seq_item");
                seq_item.constraint_mode(0);
                seq_item.write_only_c.constraint_mode(1);
                start_item(seq_item);
                assert(seq_item.randomize());
                finish_item(seq_item);
            end
        endtask
    endclass

    class FIFO_read_sequence extends uvm_sequence #(FIFO_seqitem);
        `uvm_object_utils(FIFO_read_sequence)  
        FIFO_seqitem seq_item;
        function new(string name = "FIFO_read_sequence");
            super.new(name);
        endfunction //new()
        task body();
            repeat(1000)begin
                seq_item = FIFO_seqitem::type_id::create("seq_item");
                seq_item.write_only_c.constraint_mode(0);
                seq_item.read_only_c.constraint_mode(1);
                start_item(seq_item);
                assert(seq_item.randomize());
                finish_item(seq_item);
            end
        endtask
    endclass
    class FIFO_main_sequence extends uvm_sequence #(FIFO_seqitem);
        `uvm_object_utils(FIFO_main_sequence)
        FIFO_seqitem seq_item;
        function new(string name = "FIFO_main_sequence");
            super.new(name);
        endfunction
        
        task body();
            repeat(1000) begin
                seq_item = FIFO_seqitem::type_id::create("seq_item");
                seq_item.constraint_mode(1);
                seq_item.read_only_c.constraint_mode(0);
                seq_item.write_only_c.constraint_mode(0);
                start_item(seq_item);
                seq_item.rst_n = 1;
                assert(seq_item.randomize());
                finish_item(seq_item);
            end
        endtask
    endclass
    

    
endpackage