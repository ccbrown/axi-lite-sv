module subordinate_tb;

reg  axi_aclk = 0;
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

localparam PERIOD = 10;

always
    #(PERIOD/2) axi_aclk = !axi_aclk;

initial begin
    $dumpfile("subordinate_tb.vcd");
    $dumpvars(0, subordinate_tb);

    // RESET
    axi_aresetn <= 0;
    axi_awvalid <= 0;
    axi_awprot <= 3'b000;
    axi_wvalid <= 0;
    axi_bready <= 0;
    axi_arvalid <= 0;
    axi_arprot <= 3'b000;
    axi_rready <= 0;

    #PERIOD
    assert (!axi_awready && !axi_wready) else $fatal;
    axi_aresetn <= 1;

    // WRITES

    axi_wstrb <= 4'b1111;
    axi_awvalid <= 1;
    axi_wvalid <= 1;
    axi_bready <= 1;

    // Write to r0
    axi_awaddr <= 4'b0000;
    axi_wdata <= 32'b01010101010101010101010101010101;
    #PERIOD
    assert (axi_awready && axi_wready) else $fatal;

    // Check response
    #PERIOD
    assert (!axi_awready && !axi_wready) else $fatal;
    assert (axi_bvalid && axi_bresp == 2'b00) else $fatal;

    // Write to r1
    axi_awaddr <= 4'b0100;
    axi_wdata <= 32'b01111101010101110101010101011101;
    #PERIOD
    assert (axi_awready && axi_wready) else $fatal;

    // Check response
    #PERIOD
    assert (!axi_awready && !axi_wready) else $fatal;
    assert (axi_bvalid && axi_bresp == 2'b00) else $fatal;
    axi_awaddr <= 4'b1000;

    // Write to r2
    axi_awaddr <= 4'b1000;
    axi_wdata <= 32'b11111100000000000000000000000000;
    #PERIOD
    assert (axi_awready && axi_wready) else $fatal;

    // Check response
    #PERIOD
    assert (!axi_awready && !axi_wready) else $fatal;
    assert (axi_bvalid && axi_bresp == 2'b00) else $fatal;
    axi_awaddr <= 4'b1000;

    // Write to r3
    axi_awaddr <= 4'b1100;
    axi_wdata <= 32'b00000000000000000000000000000001;
    #PERIOD
    assert (axi_awready && axi_wready) else $fatal;

    // Check response
    #PERIOD
    assert (!axi_awready && !axi_wready) else $fatal;
    assert (axi_bvalid && axi_bresp == 2'b00) else $fatal;
    axi_awaddr <= 4'b1000;

    // Apply some backpressure && make sure the response is available until we're ready for it
    axi_bready <= 0;
    #(PERIOD*2)
    assert (axi_bvalid && axi_bresp == 2'b00) else $fatal;
    axi_bready <= 1;

    // We're done writing
    axi_awvalid <= 0;
    axi_wvalid <= 0;

    // READS

    axi_arvalid <= 1;
    axi_rready <= 1;

    // Read r0
    axi_araddr <= 4'b0000;
    #PERIOD

    assert (!axi_arready && axi_rvalid) else $fatal;
    assert (axi_rdata == 32'b01010101010101010101010101010101) else $fatal;

    #PERIOD
    assert (!axi_rvalid) else $fatal;

    // Read r1
    axi_araddr <= 4'b0100;
    #PERIOD

    assert (!axi_arready && axi_rvalid) else $fatal;
    assert (axi_rdata == 32'b01111101010101110101010101011101) else $fatal;

    #PERIOD
    assert (!axi_rvalid) else $fatal;

    // Read r2
    axi_araddr <= 4'b1000;
    #PERIOD

    assert (!axi_arready && axi_rvalid) else $fatal;
    assert (axi_rdata == 32'b11111100000000000000000000000000) else $fatal;

    #PERIOD
    assert (!axi_rvalid) else $fatal;

    // Read r3
    axi_araddr <= 4'b1100;
    #PERIOD

    assert (!axi_arready && axi_rvalid) else $fatal;
    assert (axi_rdata == 32'b00000000000000000000000000000001) else $fatal;

    #PERIOD
    assert (!axi_rvalid) else $fatal;

    // Finish
    $finish();
end

endmodule
