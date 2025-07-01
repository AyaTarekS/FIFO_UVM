package test_pkg;
    import uvm_pkg::*;
    import env_pkg::*;
    import config_pkg::*;
    import sequence_pkg::*;
    `include "uvm_macros.svh"
    
    class FIFO_test extends uvm_test;
        `uvm_component_utils(FIFO_test)
        
        FIFO_env env;
        FIFO_config FIFO_cfg;
        FIFO_main_sequence seq;
        FIFO_rst_sequence rst_seq;
        FIFO_write_sequence wr_seq;
        FIFO_read_sequence rd_seq;
        
        function new(string name = "FIFO_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction
        
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            
            env = FIFO_env::type_id::create("env", this);
            FIFO_cfg = FIFO_config::type_id::create("FIFO_cfg");
            seq = FIFO_main_sequence::type_id::create("seq");
            //creating all the sequences here
            rst_seq = FIFO_rst_sequence::type_id::create("rst_seq");
            wr_seq = FIFO_write_sequence::type_id::create("wr_seq");
            rd_seq = FIFO_read_sequence::type_id::create("rd_seq");
            //getting the virtual interface from the database 
            if (!uvm_config_db#(virtual FIFO_if)::get(this, "", "FIFOvif", FIFO_cfg.vif))
                `uvm_fatal("TEST", "Unable to get virtual interface")
            //setting the configuration object for the other components
            uvm_config_db#(FIFO_config)::set(this, "*", "FIFO_vif", FIFO_cfg);
        endfunction
        
        task run_phase(uvm_phase phase);
        //there is no need for delays in the run phase 
            phase.raise_objection(this);
            //running the sequences 
            rst_seq.start(env.agent.sqr);
            `uvm_info("TEST", "Reset operation is complete", UVM_MEDIUM)

            wr_seq.start(env.agent.sqr);
            `uvm_info("TEST", "write operation only is complete", UVM_MEDIUM)

            rd_seq.start(env.agent.sqr);
            `uvm_info("TEST", "read operation only is complete", UVM_MEDIUM)

            seq.start(env.agent.sqr);
            `uvm_info("TEST", "Stimulus generation complete", UVM_MEDIUM)
            phase.drop_objection(this);
        endtask
    endclass
endpackage