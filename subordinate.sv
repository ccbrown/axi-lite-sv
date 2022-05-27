module subordinate #(
    localparam DATA_WIDTH = 32,
    localparam ADDRESS_WIDTH = 4
) (
    input  axi_aclk_in,
    input  axi_aresetn_in,
    input  [ADDRESS_WIDTH-1:0] axi_awaddr_in,
    input  [2:0] axi_awprot_in,
    input  axi_awvalid_in,
    input  [DATA_WIDTH-1:0] axi_wdata_in,
    input  [ADDRESS_WIDTH-1:0] axi_wstrb_in,
    input  axi_wvalid_in,
    input  axi_bready_in,
    input  [ADDRESS_WIDTH-1:0] axi_araddr_in,
    input  [2:0] axi_arprot_in,
    input  axi_arvalid_in,
    input  axi_rready_in,
    output axi_awready_out,
    output axi_wready_out,
    output [1:0] axi_bresp_out,
    output axi_bvalid_out,
    output axi_arready_out,
    output [DATA_WIDTH-1:0] axi_rdata_out,
    output [1:0] axi_rresp_out,
    output axi_rvalid_out
);
    reg [DATA_WIDTH-1:0] r0;
    reg [DATA_WIDTH-1:0] r1;
    reg [DATA_WIDTH-1:0] r2;
    reg [DATA_WIDTH-1:0] r3;

    reg axi_wready = 0;
    reg [1:0] axi_bresp = 2'b00;
    reg axi_bvalid = 0;
    reg axi_arready = 1;
    reg [DATA_WIDTH-1:0] axi_rdata;
    reg [1:0] axi_rresp = 2'b00;
    reg axi_rvalid = 0;

    assign axi_wready_out = axi_wready;
    assign axi_awready_out = axi_wready;
    assign axi_bresp_out = axi_bresp;
    assign axi_bvalid_out = axi_bvalid;
    assign axi_arready_out = axi_arready;
    assign axi_rdata_out = axi_rdata;
    assign axi_rresp_out = axi_rresp;
    assign axi_rvalid_out = axi_rvalid;

    always @(*)
    axi_arready <= !axi_rvalid_out;

    wire should_write;
    assign should_write = axi_wready_out && axi_wvalid_in && axi_wready_out && axi_awvalid_in;

    wire should_read;
    assign should_read = axi_arready_out && axi_arvalid_in && (!axi_rvalid_out);

    always @(posedge axi_aclk_in)
    axi_wready <= axi_aresetn_in && !axi_wready && (axi_awvalid_in && axi_wvalid_in) && (!axi_bvalid_out || axi_bready_in);

    always @(posedge axi_aclk_in)
    if (!axi_aresetn_in) begin
        axi_bvalid <= 0;
        axi_bresp  <= 2'b00;
    end else if (should_write)
        axi_bvalid <= 1;
    else if (axi_bready_in)
        axi_bvalid <= 0;

    always @(posedge axi_aclk_in)
    if (!axi_aresetn_in) begin
        axi_rvalid <= 0;
        axi_rresp <= 2'b00;
    end else if (should_read)
        axi_rvalid <= 1;
    else if (axi_rready_in)
        axi_rvalid <= 0;

	function [DATA_WIDTH-1:0] apply_wstrb;
		input [DATA_WIDTH-1:0]   prev;
		input [DATA_WIDTH-1:0]   data;
		input [DATA_WIDTH/8-1:0] wstrb;

		integer	k;
		for(k=0; k<DATA_WIDTH/8; k=k+1)
		begin
			apply_wstrb[k*8+:8] = wstrb[k] ? data[k*8+:8] : prev[k*8+:8];
		end
	endfunction

    always @(posedge axi_aclk_in)
    if (!axi_aresetn_in) begin
        r0 <= 0;
        r1 <= 0;
        r2 <= 0;
        r3 <= 0;
    end else if (should_write) begin
        case(axi_awaddr_in[3:2])
        2'd0: r0 <= apply_wstrb(r0, axi_wdata_in, axi_wstrb_in);
        2'd1: r1 <= apply_wstrb(r1, axi_wdata_in, axi_wstrb_in);
        2'd2: r2 <= apply_wstrb(r2, axi_wdata_in, axi_wstrb_in);
        2'd3: r3 <= apply_wstrb(r3, axi_wdata_in, axi_wstrb_in);
        endcase
    end

    always @(posedge axi_aclk_in)
    if (!axi_rvalid_out || axi_rready_in) begin
        case(axi_araddr_in[3:2])
        2'd0: axi_rdata <= r0;
        2'd1: axi_rdata <= r1;
        2'd2: axi_rdata <= r2;
        2'd3: axi_rdata <= r3;
        endcase
    end 

`ifdef FORMAL
	localparam F_AXIL_LGDEPTH = 4;
	wire [F_AXIL_LGDEPTH-1:0] faxil_rd_outstanding, faxil_wr_outstanding, faxil_awr_outstanding;

	faxil_slave #(
		.C_AXI_DATA_WIDTH(DATA_WIDTH),
		.C_AXI_ADDR_WIDTH(ADDRESS_WIDTH),
		.F_LGDEPTH(F_AXIL_LGDEPTH),
		.F_AXI_MAXWAIT(3),
		.F_AXI_MAXDELAY(3),
		.F_AXI_MAXRSTALL(5),
		.F_OPT_COVER_BURST(4)
	) faxil(
		.i_clk(axi_aclk_in),
        .i_axi_reset_n(axi_aresetn_in),
		.i_axi_awvalid(axi_awvalid_in),
		.i_axi_awready(axi_awready_out),
		.i_axi_awaddr(axi_awaddr_in),
		.i_axi_awprot(axi_awprot_in),
		.i_axi_wvalid(axi_wvalid_in),
		.i_axi_wready(axi_wready_out),
		.i_axi_wdata(axi_wdata_in),
		.i_axi_wstrb(axi_wstrb_in),
		.i_axi_bvalid(axi_bvalid_out),
		.i_axi_bready(axi_bready_in),
		.i_axi_bresp(axi_bresp_out),
		.i_axi_arvalid(axi_arvalid_in),
		.i_axi_arready(axi_arready_out),
		.i_axi_araddr(axi_araddr_in),
		.i_axi_arprot(axi_arprot_in),
		.i_axi_rvalid(axi_rvalid_out),
		.i_axi_rready(axi_rready_in),
		.i_axi_rdata(axi_rdata_out),
		.i_axi_rresp(axi_rresp_out),
		.f_axi_rd_outstanding(faxil_rd_outstanding),
		.f_axi_wr_outstanding(faxil_wr_outstanding),
		.f_axi_awr_outstanding(faxil_awr_outstanding)
	);

	always @(*)
    begin
		assert(faxil_wr_outstanding == (axi_bvalid_out ? 1:0));
		assert(faxil_awr_outstanding == faxil_wr_outstanding);
		assert(faxil_rd_outstanding == (axi_rvalid_out ? 1:0));
	end
`endif

endmodule
