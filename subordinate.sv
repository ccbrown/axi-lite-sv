module subordinate #(
    localparam DATA_WIDTH = 32,
    localparam ADDRESS_WIDTH = 4
) (
    input  axi_aclk_in,
    input  axi_aresetn_in,
    input  [ADDRESS_WIDTH - 1:0] axi_awaddr_in,
    input  [2:0] axi_awprot_in,
    input  axi_awvalid_in,
    input  [DATA_WIDTH - 1:0] axi_wdata_in,
    input  [ADDRESS_WIDTH - 1:0] axi_wstrb_in,
    input  axi_wvalid_in,
    input  axi_bready_in,
    input  [ADDRESS_WIDTH - 1:0] axi_araddr_in,
    input  [2:0] axi_arprot_in,
    input  axi_arvalid_in,
    input  axi_rready_in,
    output axi_awready_out,
    output axi_wready_out,
    output [1:0] axi_bresp_out,
    output axi_bvalid_out,
    output axi_arready_out,
    output [DATA_WIDTH - 1:0] axi_rdata_out,
    output [1:0] axi_rresp_out,
    output axi_rvalid_out
);
    reg axi_wready = 0;

    assign axi_wready_out = axi_wready;
    assign axi_awready_out = axi_wready;

    always @(posedge axi_aclk_in)
    axi_wready <= axi_aresetn_in && !axi_wready && (axi_awvalid_in && axi_wvalid_in) && (!axi_bvalid_out || axi_bready_in);
endmodule
