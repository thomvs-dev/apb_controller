module bridge_tb();

  reg hclk, hresetn, hselapb, hwrite;
  reg [1:0] htrans;
  reg [31:0] haddr, hwdata;
  reg [31:0] prdata;

  wire hresp, hready;
  wire [31:0] hrdata;
  wire psel, penable, pwrite;
  wire [31:0] paddr, pwdata;


  bridge dut (
    hclk, hresetn, hselapb, hwrite,
    htrans, haddr,
    hwdata,
    prdata,
    paddr, pwdata,
    psel, penable, pwrite,
    hresp, hready,
    hrdata
  );


  initial hclk = 0;
  always #10 hclk = ~hclk;


  task reset_dut;
    begin
      hresetn = 1'b0;
      @(negedge hclk);
      hresetn = 1'b1;
    end
  endtask


  initial begin

    hselapb = 0;
    hwrite  = 0;
    htrans  = 2'b00;
    haddr   = 32'b0;
    hwdata  = 32'b0;
    prdata  = 32'b0;

    reset_dut();


    @(negedge hclk);
    hselapb = 1'b1;
    hwrite  = 1'b0;
    htrans  = 2'b10;          
    haddr   = 32'h0000_0020;

    
    @(posedge penable);
    prdata = 32'h0000_0028;

    @(negedge hclk);
    hselapb = 1'b0;
    htrans  = 2'b00;

    #40;


    @(negedge hclk);
    hselapb = 1'b1;
    hwrite  = 1'b1;
    htrans  = 2'b10;
    haddr   = 32'h0000_0040;
    hwdata  = 32'hDEAD_BEEF;

    @(negedge hclk);
    hselapb = 1'b0;
    htrans  = 2'b00;

    #100;
    $finish;
  end

endmodule
