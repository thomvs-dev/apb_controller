module apb_controller(
    input hclk,
    input hresetn,
    input valid,
    input hwrite,
    input hwritereg,
    input [31:0] haddr1,
    input [31:0] haddr2,
    input [31:0] hwdata1,
    input [31:0] hwdata2,
    input [31:0] haddr,
    input [31:0] hwdata,
    input [2:0] tempselx,

    output reg pwrite,
    output reg penable,
    output reg [2:0] pselx,
    output reg hreadyout,
    output reg [31:0] pwdata,
    output reg [31:0] paddr
);

parameter st_idle = 3'b000,
          st_wait = 3'b001,
          st_write = 3'b010,
          st_writep = 3'b011,
          st_wenablep = 3'b100,
          st_wenable = 3'b101,
          st_read = 3'b110,
          st_renable = 3'b111;

reg [2:0] state, next_state;
reg [31:0] paddr_temp, pwdata_temp;
reg penable_temp, pwrite_temp, hreadyout_temp;
reg [2:0] pselx_temp;

always @(posedge hclk) begin
    if(!hresetn)
        state <= st_idle;
    else
        state <= next_state;
end

always @(*) begin
    case(state)
        st_idle: begin
            if(valid==1'b1 && hwrite==1'b1)
                next_state = st_wait;
            else if(valid==1'b1 && hwrite==1'b0)
                next_state = st_read;
            else
                next_state = st_idle;
        end

        st_wait: begin
            if(valid==1'b1)
                next_state = st_writep;
            else
                next_state = st_write;
        end

        st_writep:   next_state = st_wenablep;

        st_write: begin
            if(valid==1'b1)
                next_state = st_wenablep;
            else
                next_state = st_wenable;
        end

        st_wenablep: begin
            if((valid==1'b1) && hwritereg)
                next_state = st_writep;
            else if(~hwritereg)
                next_state = st_read;
            else if(valid==1'b0)
                next_state = st_write;
            else
                next_state = st_wenablep;
        end

        st_wenable: begin
            if((valid==1'b1) && ~hwrite)
                next_state = st_read;
            else if(valid==1'b0)
                next_state = st_idle;
            else
                next_state = st_wenable;
        end

        st_read: next_state = st_renable;

        st_renable: begin
            if((valid==1'b1) && ~hwrite)
                next_state = st_read;
            else if((valid==1'b1) && hwrite)
                next_state = st_wait;
            else if(~valid)
                next_state = st_idle;
            else
                next_state = st_renable;
        end

        default: next_state = st_idle;
    endcase
end

always @(*) begin
    paddr_temp = 32'd0;
    pwdata_temp = 32'd0;
    penable_temp = 1'b0;
    pwrite_temp = 1'b0;
    pselx_temp = 3'd0;
    hreadyout_temp  = 1'b1;

    case(state)
        st_wait: begin
            paddr_temp = haddr1;
            pwdata_temp = hwdata1;
            pwrite_temp = 1'b1;
            pselx_temp = tempselx;
            hreadyout_temp = 1'b0;
        end

        st_wenable: begin
            paddr_temp = haddr2;
            pwdata_temp = hwdata2;
            hreadyout_temp = 1'b0;
        end

        st_read: begin
            paddr_temp = haddr;
            pwrite_temp = 1'b0;
        end
    endcase
end

always @(posedge hclk) begin
    if(!hresetn) begin
        paddr <= 0;
        pwdata <= 0;
        penable <= 0;
        pwrite <= 0;
        pselx <= 0;
        hreadyout <= 1;
    end else begin
        paddr <= paddr_temp;
        pwdata <= pwdata_temp;
        penable <= penable_temp;
        pwrite <= pwrite_temp;
        pselx <= pselx_temp;
        hreadyout <= hreadyout_temp;
    end
end

endmodule
