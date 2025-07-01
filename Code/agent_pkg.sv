package agent_pkg;
    import uvm_pkg::*;
    import dri_pkg::*;
    import sequencer_pkg::*;
    import seqitem_pkg::*;
    import config_pkg::*;
    import monitor_pkg::*;
    `include "uvm_macros.svh"

    class FIFO_agent extends uvm_agent;
        `uvm_component_utils(FIFO_agent)
        
        FIFO_sequencer sqr;
        FIFO_dri driver;
        FIFO_monitor monitor;
        FIFO_config FIFO_cfg;
        //analysis port for the agent to connect it to the monitor and scoreboard
        uvm_analysis_port #(FIFO_seqitem) agt_ap;

        function new(string name = "FIFO_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            
           if (!uvm_config_db#(FIFO_config)::get(this, "", "FIFO_vif", FIFO_cfg))
            `uvm_fatal("AGENT", "Config not found")
            
            // Create components using factory method
            sqr = FIFO_sequencer::type_id::create("sqr", this);
            driver = FIFO_dri::type_id::create("driver", this);
            monitor = FIFO_monitor::type_id::create("monitor", this);
            agt_ap = new("agt_ap", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            
            // Connect the interfaces to the driver and monitor
            //for the objects to transfer the data to the driver and monitor
            driver.FIFO_driver_vif = FIFO_cfg.vif;
            monitor.vif = FIFO_cfg.vif;
            
            // Connect driver to sequencer
            driver.seq_item_port.connect(sqr.seq_item_export);
            
            // Connect monitor to agent analysis port 
            monitor.mon_ap.connect(agt_ap);
        endfunction
    endclass
endpackage