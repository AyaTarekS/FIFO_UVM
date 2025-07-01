

module FIFO #(parameter FIFO_WIDTH = 8, parameter FIFO_DEPTH = 16)(FIFO_if.DUT fifo_if);

// Interface Connections
bit [FIFO_WIDTH-1:0] data_in;
bit clk, rst_n, wr_en, rd_en;

logic [FIFO_WIDTH-1:0] data_out;
logic wr_ack, overflow, full, empty, almostfull, almostempty, underflow;

assign data_in = fifo_if.data_in;
assign clk = fifo_if.clk;
assign rst_n = fifo_if.rst_n;
assign wr_en = fifo_if.wr_en;
assign rd_en = fifo_if.rd_en;

assign fifo_if.data_out = data_out;
assign fifo_if.wr_ack = wr_ack;
assign fifo_if.overflow = overflow;
assign fifo_if.full = full;
assign fifo_if.empty = empty;
assign fifo_if.almostfull = almostfull;
assign fifo_if.almostempty = almostempty;
assign fifo_if.underflow = underflow;

// Declaration of max. FIFO address
localparam max_fifo_addr = $clog2(FIFO_DEPTH); // max_fifo_addr = 3

// Declaration of Memory (FIFO)
reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

// Declaration of read & write pointers
reg [max_fifo_addr-1:0] wr_ptr, rd_ptr; // from  0 -> 7

reg [max_fifo_addr:0] count; // from 0-> 8

// Extra Bit to Distinguish between full & empty flags & it represents the fill level of the FIFO

// writing operation
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		//intialization of all registers 
		wr_ptr <= 0;
		overflow <= 0;
		wr_ack <= 0;
	end
	else if (wr_en && (count < FIFO_DEPTH)) begin
		mem[wr_ptr] <= data_in;
		wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
	end
	else begin 
		wr_ack <= 0; 
		if (full && wr_en)
			overflow <= 1;
		else
		//deassertion of overflow signal 
			overflow <= 0;
	end
end

// reading operation
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		// initialization of all registers for the reading operation
		rd_ptr <= 0;
		underflow <= 0;
	end
	else if (rd_en && (count != 0)) begin
		data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
	end
	else begin 
		if (empty && rd_en)
			underflow <= 1;
		else
			underflow <= 0;
	end
end

// always block specialized for counter signal
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		count <= 0;
	end
	else begin
		if (({wr_en, rd_en} == 2'b10) && !full) 
			count <= count + 1;
		else if (({wr_en, rd_en} == 2'b01) && !empty)
			count <= count - 1;
		else if (({wr_en, rd_en} == 2'b11) && full)      // Priority for Read operation while having full FIFO
			count <= count - 1;
		else if (({wr_en, rd_en} == 2'b11) && empty)     // Priority for Write operation with having empty FIFO
			count <= count + 1;
	end
end

// continous assignment for the combinational outputs
assign full = (count == FIFO_DEPTH)? 1 : 0;
assign empty = (count == 0)? 1 : 0;
assign almostfull = (count == FIFO_DEPTH-1)? 1 : 0; 
assign almostempty = (count == 1)? 1 : 0;

// Assertions to the DUT

`ifdef SIM

	// Assertions for Combinational Outputs
	always_comb begin
		if (!rst_n) begin
			RST_assertion : assert final (!wr_ptr && !rd_ptr && ~count && empty && !full && !almostempty && !almostfull) else $display("RST_assertion fail");
			RST_cover     : cover  final (!wr_ptr && !rd_ptr && ~count && empty && !full && !almostempty && !almostfull);
		end
		if (count == 0) begin
			EMPTY_assertion : assert (empty && !full && !almostempty && !almostfull) else $display("EMPTY_assertion fail");
			EMPTY_cover     : cover  (empty && !full && !almostempty && !almostfull);      
		end
		if (count == 1) begin
			ALMOSTEMPTY_assertion : assert (!empty && !full && almostempty && !almostfull) else $display("ALMOSTFULL_assertion fail");
			ALMOSTEMPTY_cover     : cover  (!empty && !full && almostempty && !almostfull);
		end
		if (count == FIFO_DEPTH-1) begin
			ALMOSTFULL_assertion : assert (!empty && !full && !almostempty && almostfull) else $display("ALMOSTFULL_assertion fail");
			ALMOSTFULL_cover     : cover  (!empty && !full && !almostempty && almostfull);
		end
		if (count == FIFO_DEPTH) begin
			FULL_assertion : assert (!empty && full && !almostempty && !almostfull) else $display("FULL_assertion fail");
			FULL_cover     : cover  (!empty && full && !almostempty && !almostfull);
		end
	end

	// Assertions for Overflow and Underflow
	property OVERFLOW_FIFO;
		@(posedge clk) disable iff (!rst_n) (full & wr_en) |=> (overflow);
	endproperty

	property UNDERFLOW_FIFO;
		@(posedge clk) disable iff (!rst_n) (empty && rd_en) |=> (underflow);
	endproperty

	// Assertions for wr_ack
	property WR_ACK_HIGH;
		@(posedge clk) disable iff (!rst_n) (wr_en && (count < FIFO_DEPTH) && !full) |=> (wr_ack);
	endproperty

	property WR_ACK_LOW;
		@(posedge clk) disable iff (!rst_n) (wr_en && full) |=> (!wr_ack);
	endproperty

	// Assertions for The Counter
	property COUNT_0;
		@(posedge clk) (!rst_n) |=> (count == 0);
	endproperty

	property COUNT_INC_10;
		@(posedge clk) disable iff (!rst_n) (({wr_en, rd_en} == 2'b10) && !full) |=> (count == $past(count) + 1);
	endproperty

	property COUNT_INC_01;
		@(posedge clk) disable iff (!rst_n) (({wr_en, rd_en} == 2'b01) && !empty) |=> (count == $past(count) - 1);
	endproperty

	property COUNT_INC_11_WR;
		@(posedge clk) disable iff (!rst_n) (({wr_en, rd_en} == 2'b11) && empty) |=> (count == $past(count) + 1);
	endproperty

	property COUNT_INC_11_RD;
		@(posedge clk) disable iff (!rst_n) (({wr_en, rd_en} == 2'b11) && full) |=> (count == $past(count) - 1);
	endproperty

	property COUNT_LAT;
		@(posedge clk) disable iff (!rst_n) ((({wr_en, rd_en} == 2'b01) && empty) || (({wr_en, rd_en} == 2'b10) && full)) |=> (count == $past(count));
	endproperty

	// Assertions for Pointers
	property PTR_RST;
		@(posedge clk) (!rst_n) |=> (~rd_ptr && ~wr_ptr);
	endproperty

	property RD_PTR;
		@(posedge clk) disable iff (!rst_n) (rd_en && (count != 0)) |=> (rd_ptr == ($past(rd_ptr) + 1) % FIFO_DEPTH);
	endproperty

	property WR_PTR;
		@(posedge clk) disable iff (!rst_n) (wr_en && (count < FIFO_DEPTH)) |=> (wr_ptr == ($past(wr_ptr) + 1) % FIFO_DEPTH);
	endproperty

	// Pointer wraparound assertion for write_ptr
 	property WR_PTR_wraparound;
 		@(posedge clk) disable iff (!rst_n) (wr_en && !full && (wr_ptr == FIFO_DEPTH-1)) |=> (!wr_ptr);
	endproperty

	// Pointer wraparound assertion for read_ptr
	property RD_PTR_wraparound;
 		@(posedge clk) disable iff (!rst_n) (rd_en && !empty && (rd_ptr == FIFO_DEPTH-1)) |=> (!rd_ptr);
	endproperty

	// Counter wraparound assertion
	property COUNT_wraparound;
		@(posedge clk) disable iff (!rst_n) (wr_en && (count == FIFO_DEPTH)) |=> (~count);
	endproperty

	// Pointer threshold assertion for write_ptr
	property WR_PTR_threshold;
		@(posedge clk) disable iff (!rst_n) (wr_ptr < FIFO_DEPTH);
	endproperty

	// Pointer threshold assertion for read_ptr
	property RD_PTR_threshold;
		@(posedge clk) disable iff (!rst_n) (rd_ptr < FIFO_DEPTH);
	endproperty

	// Counter threshold assertion
	property COUNT_threshold;
		@(posedge clk) disable iff (!rst_n) (count <= FIFO_DEPTH);
	endproperty

	// Assert Properties
	OVERFLOW_assertion          : assert property (OVERFLOW_FIFO)     else $display("OVERFLOW_assertion fail");
	UNDERFLOW_assertion         : assert property (UNDERFLOW_FIFO)    else $display("UNDERFLOW_assertion fail");
	WR_ACK_HIGH_assertion       : assert property (WR_ACK_HIGH)       else $display("WR_ACK_HIGH_assertion fail");
	WR_ACK_LOW_assertion        : assert property (WR_ACK_LOW)        else $display("WR_ACK_LOW_assertion fail");
	COUNTER_INC_10_assertion    : assert property (COUNT_INC_10)      else $display("COUNTER_INC_WR_assertion fail");
	COUNTER_INC_01_assertion    : assert property (COUNT_INC_01)      else $display("COUNTER_INC_WR_assertion fail");
	COUNTER_INC_11_WR_assertion : assert property (COUNT_INC_11_WR)   else $display("COUNTER_INC_WR_assertion fail");
	COUNTER_INC_11_RD_assertion : assert property (COUNT_INC_11_RD)   else $display("COUNTER_INC_WR_assertion fail");
	COUNTER_LAT_assertion       : assert property (COUNT_LAT)         else $display("COUNTER_LAT_assertion fail");
	RD_PTR_assertion            : assert property (RD_PTR)            else $display("RD_PTR_asssertion fail");
	WR_PTR_assertion            : assert property (WR_PTR)            else $display("WR_PTR_asssertion fail");
	WR_PTR_wraparound_assertion : assert property (WR_PTR_wraparound) else $display("WR_PTR_wraparound_assertion fail");
	RD_PTR_wraparound_assertion : assert property (RD_PTR_wraparound) else $display("RD_PTR_wraparound_assertion fail");
	COUNT_wraparound_assertion  : assert property (COUNT_wraparound)  else $display("COUNT_wraparound_assertion fail");
	WR_PTR_threshold_assertion  : assert property (WR_PTR_threshold)  else $display("WR_PTR_threshold_assertion fail");
	RD_PTR_threshold_assertion  : assert property (RD_PTR_threshold)  else $display("RD_PTR_threshold_assertion fail");
	COUNT_threshold_assertion   : assert property (COUNT_threshold)   else $display("COUNT_threshold_assertion fail");

	// Cover Properties
	OVERFLOW_cover          : cover property (OVERFLOW_FIFO);
	UNDERFLOW_cover         : cover property (UNDERFLOW_FIFO);
	WR_ACK_HIGH_cover       : cover property (WR_ACK_HIGH);
	WR_ACK_LOW_cover        : cover property (WR_ACK_LOW);
	COUNTER_INC_10_cover    : cover property (COUNT_INC_10);
	COUNTER_INC_01_cover    : cover property (COUNT_INC_01);
	COUNTER_INC_11_WR_cover : cover property (COUNT_INC_11_WR);
	COUNTER_INC_11_RD_cover : cover property (COUNT_INC_11_RD);
	COUNTER_LAT_cover       : cover property (COUNT_LAT);
	RD_PTR_cover            : cover property (RD_PTR);
	WR_PTR_cover            : cover property (WR_PTR);
	WR_PTR_wraparound_cover : cover property (WR_PTR_wraparound);
	RD_PTR_wraparound_cover : cover property (RD_PTR_wraparound);
	COUNT_wraparound_cover  : cover property (COUNT_wraparound);
	WR_PTR_threshold_cover  : cover property (WR_PTR_threshold);
	RD_PTR_threshold_cover  : cover property (RD_PTR_threshold);
	COUNT_threshold_cover   : cover property (COUNT_threshold);

`endif

endmodule