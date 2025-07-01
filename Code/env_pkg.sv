package env_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import agent_pkg::*;       
    import scoreboard_pkg::*;  
    import dri_pkg::*;
    import coverage_collector::*; 
    
    class FIFO_env extends uvm_env;
        `uvm_component_utils(FIFO_env)
        
        FIFO_agent agent;
        FIFO_coverage_collector cov;
        FIFO_scoreboard sb;
        
        function new(string name = "FIFO_env", uvm_component parent = null);
            super.new(name, parent);
        endfunction
        
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent = FIFO_agent::type_id::create("agent", this);
            cov = FIFO_coverage_collector::type_id::create("cov", this);
            sb = FIFO_scoreboard::type_id::create("sb", this);
        endfunction
        
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            // Connecting all the components together
            agent.agt_ap.connect(cov.cov_export);  // Agent to coverage
            agent.agt_ap.connect(sb.sb_fifo.analysis_export); // Agent to scoreboard 
        endfunction
    endclass
endpackage