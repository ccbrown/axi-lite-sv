module subordinate_tb;

reg  axi_aclk;
reg  axi_aresetn;
reg  [3:0] axi_awaddr;
reg  [2:0] axi_awprot;
reg  axi_awvalid;
reg  [31:0] axi_wdata;
reg  [3:0] axi_wstrb;
reg  axi_wvalid;
reg  axi_bready;
reg  [3:0] axi_araddr;
reg  [2:0] axi_arprot;
reg  axi_arvalid;
reg  axi_rready;
wire axi_awready;
wire axi_wready;
wire [1:0] axi_bresp;
wire axi_bvalid;
wire axi_arready;
wire [31:0] axi_rdata;
wire [1:0] axi_rresp;
wire axi_rvalid;

subordinate s(
    .axi_aclk_in(axi_aclk),
    .axi_aresetn_in(axi_aresetn),
    .axi_awaddr_in(axi_awaddr),
    .axi_awprot_in(axi_awprot),
    .axi_awvalid_in(axi_awvalid),
    .axi_wdata_in(axi_wdata),
    .axi_wstrb_in(axi_wstrb),
    .axi_wvalid_in(axi_wvalid),
    .axi_bready_in(axi_bready),
    .axi_araddr_in(axi_araddr),
    .axi_arprot_in(axi_arprot),
    .axi_arvalid_in(axi_arvalid),
    .axi_rready_in(axi_rready),
    .axi_awready_out(axi_awready),
    .axi_wready_out(axi_wready),
    .axi_bresp_out(axi_bresp),
    .axi_bvalid_out(axi_bvalid),
    .axi_arready_out(axi_arready),
    .axi_rdata_out(axi_rdata),
    .axi_rresp_out(axi_rresp),
    .axi_rvalid_out(axi_rvalid)
);

initial begin
    // RESET
    axi_aresetn <= 0;
    axi_awvalid <= 0;
    axi_awprot <= 3'b000;
    axi_wvalid <= 0;
    axi_bready <= 0;
    axi_arvalid <= 0;
    axi_arprot <= 3'b000;
    axi_rready <= 0;

    #1
    assert (axi_awready == 0 && axi_wready == 0);
    axi_aresetn <= 1;
end

endmodule
