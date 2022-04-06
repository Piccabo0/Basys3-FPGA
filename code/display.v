//      显示模块        /////////////////////////////////////////////
//      clk 1Mhz，输入整数     /////////////////////////////////
module disp(
        input [31:0] val,
        input clk,
        output [3:0] bit,
        output [7:0] seg
  );
  wire r_clk;
  
  integer clk_1khz=1000;//时钟频率整数
  
  reg [31:0] register;
  reg [3:0] bit4;//第四个数码管
  reg [3:0] bit3;//第三个数码管
  reg [3:0] bit2;//第二个数码管
  reg [3:0] bit1;//第一个数码管
  reg [3:0] bit0=0;//初始化全为0；
  reg [3:0] num_select;
  wire [7:0] seg_1;
  
  
  clk_divider refresh_clk(
        .clk(clk),
        .d_val(clk_1khz),
        .d_clk(r_clk)
  );//输出是r_clk信号
  
  always@(val)
    begin
      register<=val;//输入值进行数位划分，个十百千
      bit4<=register/1000;          //千位
      bit3<=register%1000/100;      //百位
      bit2<=register%100/10;        //十位
      bit1<=register%10;            //个位
    end
  
  reg[3:0] bit_ctrl=4'b0001;//位控制初始化，共阴极数码管4‘b0001？
  always@(posedge r_clk)
    begin
        bit_ctrl<={bit_ctrl[2:0],bit_ctrl[3]};//拼接移位；
    end  
    
    assign bit=bit_ctrl;//设置哪个数码管被选用
    
    always @(bit_ctrl)
      begin
       case(bit_ctrl)
        4'b0001:num_select<=bit1;
        4'b0010:num_select<=bit2;
        4'b0100:num_select<=bit3;
        4'b1000:num_select<=bit4;
        default:num_select<=bit0;
        endcase
      end
    //调用数码管
    seg_decoder p1(
            .val(num_select),
            .out(seg)
    );
     
endmodule
