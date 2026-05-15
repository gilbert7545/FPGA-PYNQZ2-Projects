module image_inverter(
input wire clk,
input wire rst_n,
input wire valid_in,
input wire [7:0] pixel_in,
output reg valid_out,
output reg [7:0] pixel_out
);
always @(posedge clk or negedge rst_n) begin
if (!rst_n) begin
pixel_out <= 8'd0;
valid_out <= 1'b0;
end else begin
if (valid_in) begin
pixel_out <= 8'd255 - pixel_in;
valid_out <= 1'b1;
end else begin
valid_out <= 1'b0;
end

end
end
endmodule


module myip_apple_v1_0_S00_AXI #
(
parameter integer C_S_AXI_DATA_WIDTH = 32,
parameter integer C_S_AXI_ADDR_WIDTH = 4
)
(
input wire S_AXI_ACLK,
input wire S_AXI_ARESETN,
input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
input wire [2 : 0] S_AXI_AWPROT,
input wire S_AXI_AWVALID,
output wire S_AXI_AWREADY,
input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
input wire S_AXI_WVALID,
output wire S_AXI_WREADY,
output wire [1 : 0] S_AXI_BRESP,
output wire S_AXI_BVALID,
input wire S_AXI_BREADY,
input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
input wire [2 : 0] S_AXI_ARPROT,
input wire S_AXI_ARVALID,
output wire S_AXI_ARREADY,
output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
output wire [1 : 0] S_AXI_RRESP,
output wire S_AXI_RVALID,
input wire S_AXI_RREADY
);
// AXI4LITE signals (boilerplate)

reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_awaddr;
reg axi_awready;
reg axi_wready;
reg [1 : 0] axi_bresp;
reg axi_bvalid;
reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_araddr;
reg axi_arready;
reg [C_S_AXI_DATA_WIDTH-1 : 0] axi_rdata;
reg [1 : 0] axi_rresp;
reg axi_rvalid;
localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
localparam integer OPT_MEM_ADDR_BITS = 1;
reg [C_S_AXI_DATA_WIDTH-1:0] reg_data_out;
reg aw_en;
// Image inverter registers and logic
reg [7:0] pixel_in_reg;
reg start_reg;
wire start_pulse;
reg start_reg_d;
wire [7:0] pixel_out_wire;
wire ready_wire;
reg [7:0] pixel_out_latched;
reg ready_latched;
// AXI4-Lite assignments
assign S_AXI_AWREADY = axi_awready;
assign S_AXI_WREADY = axi_wready;
assign S_AXI_BRESP = axi_bresp;
assign S_AXI_BVALID = axi_bvalid;
assign S_AXI_ARREADY = axi_arready;
assign S_AXI_RDATA = axi_rdata;
assign S_AXI_RRESP = axi_rresp;
assign S_AXI_RVALID = axi_rvalid;
// Write address ready

always @(posedge S_AXI_ACLK) begin
if (S_AXI_ARESETN == 1'b0) begin
axi_awready <= 1'b0;
aw_en <= 1'b1;
end else begin
if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
axi_awready <= 1'b1;
aw_en <= 1'b0;
end else if (S_AXI_BREADY && axi_bvalid) begin
aw_en <= 1'b1;
axi_awready <= 1'b0;
end else begin
axi_awready <= 1'b0;
end
end
end
always @(posedge S_AXI_ACLK) begin
if (S_AXI_ARESETN == 1'b0)
axi_awaddr <= 0;
else if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
axi_awaddr <= S_AXI_AWADDR;
end
always @(posedge S_AXI_ACLK) begin
if (S_AXI_ARESETN == 1'b0)
axi_wready <= 1'b0;
else if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en)
axi_wready <= 1'b1;
else
axi_wready <= 1'b0;
end
always @(posedge S_AXI_ACLK) begin
if (S_AXI_ARESETN == 1'b0) begin
axi_bvalid <= 0;
axi_bresp <= 2'b0;
end else begin

if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID) begin
axi_bvalid <= 1'b1;
axi_bresp <= 2'b0; // 'OKAY' response
end else if (S_AXI_BREADY && axi_bvalid) begin
axi_bvalid <= 1'b0;
end
end
end
always @(posedge S_AXI_ACLK) begin
if (S_AXI_ARESETN == 1'b0) begin
axi_arready <= 1'b0;
axi_araddr <= 0;
end else begin
if (~axi_arready && S_AXI_ARVALID) begin
axi_arready <= 1'b1;
axi_araddr <= S_AXI_ARADDR;
end else begin
axi_arready <= 1'b0;
end
end
end
always @(posedge S_AXI_ACLK) begin
if (S_AXI_ARESETN == 1'b0) begin
axi_rvalid <= 0;
axi_rresp <= 0;
end else begin
if (axi_arready && S_AXI_ARVALID && ~axi_rvalid) begin
axi_rvalid <= 1'b1;
axi_rresp <= 2'b0; // 'OKAY' response
end else if (axi_rvalid && S_AXI_RREADY) begin
axi_rvalid <= 1'b0;
end
end
end
wire slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;

wire slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;
// User logic: register write
always @(posedge S_AXI_ACLK) begin
if (!S_AXI_ARESETN)
pixel_in_reg <= 8'd0;
else if (slv_reg_wren && (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] ==
2'h0))
pixel_in_reg <= S_AXI_WDATA[7:0];
end
always @(posedge S_AXI_ACLK) begin
if (!S_AXI_ARESETN)
start_reg <= 1'b0;
else if (slv_reg_wren && (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] ==
2'h1))
start_reg <= S_AXI_WDATA[0];
else
start_reg <= 1'b0;
end
// Start pulse logic (single clock cycle pulse)
always @(posedge S_AXI_ACLK) begin
if (!S_AXI_ARESETN)
start_reg_d <= 1'b0;
else
start_reg_d <= start_reg;
end
assign start_pulse = start_reg & ~start_reg_d;
// Instantiate image_inverter
image_inverter inverter_inst (
.clk (S_AXI_ACLK),
.rst_n (S_AXI_ARESETN),
.valid_in (start_pulse),
.pixel_in (pixel_in_reg),
.valid_out (ready_wire),
.pixel_out (pixel_out_wire)

);
// Latch output and ready
always @(posedge S_AXI_ACLK) begin
if (!S_AXI_ARESETN) begin
pixel_out_latched <= 8'd0;
ready_latched <= 1'b0;
end else if (ready_wire) begin
pixel_out_latched <= pixel_out_wire;
ready_latched <= 1'b1;
end else if (start_pulse) begin
ready_latched <= 1'b0;
end
end
// Address decoding for reading registers
always @(*) begin
case (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
2'h0: reg_data_out = {24'd0, pixel_in_reg}; // Input pixel
2'h1: reg_data_out = {31'd0, start_reg}; // Start
2'h2: reg_data_out = {24'd0, pixel_out_latched}; // Output pixel
2'h3: reg_data_out = {31'd0, ready_latched}; // Ready/valid
default: reg_data_out = 32'd0;
endcase
end
// Output register or memory read data
always @(posedge S_AXI_ACLK) begin
if (S_AXI_ARESETN == 1'b0)
axi_rdata <= 0;
else if (slv_reg_rden)
axi_rdata <= reg_data_out;
end
endmodule


