//      计线数      ///////////////////////////////
module line_det(
    input pulse,
    input rst,
    output [31:0] num
    );
    
    reg [31:0] cnt;//计数器，统计个数
    assign num=cnt;

    always@(posedge pulse, posedge rst)
    begin
        if(rst)
            cnt<=0;
        else
            cnt<=cnt+1;//高电平+1，rst复位
    end
endmodule
