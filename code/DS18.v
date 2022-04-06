/*  
* module:Temperature  
* file name:Temperature.v   
*function:温度的测量,测得数值的进制转换，数码管段码位码的输出
*/ 
module DS18(
  input         clk,                    // 1MHz时钟
  //input         rst_n,                  // 异步复位
  inout         one_wire,               // One-Wire总线，单线读写通讯，采集ds18b20的输出信号
  output [15:0] temperature             // 输出温度值
);


//自动复位
 reg rst_n;
 reg [14:0]count;//计数器

 always@(posedge clk)
 begin
    if(count<15'h4000)
       begin
       rst_n<=1;
       count<=count+1;
       end
    else if(count<15'h4fff)
       begin
       rst_n<=0;
       count<=count+1;
       end
    else
       rst_n<=1;
 end

//改进版本后，直接使用分频模块分出的1MHz，优化了代码

////++++++++++++++++++++++++++++++++++++++
//// 分频器48MHz->1MHz 开始
////++++++++++++++++++++++++++++++++++++++
//reg [5:0] cnt;                         // 计数子
//
//always @ (posedge clk, negedge rst_n)
//  if (!rst_n)
//    cnt <= 0;
//  else
//    if (cnt == 47)
//      cnt <= 0;
//    else
//      cnt <= cnt + 1'b1;
//
//reg clk_1us;                            // 1MHz 时钟
//
//always @ (posedge clk, negedge rst_n)
//  if (!rst_n)
//    clk_1us <= 0;
//  else
//    if (cnt == 23)                      // 23 = 48/2 - 1
//      clk_1us <= 0;
//    else
//      clk_1us <= 1;      
//
////--------------------------------------
//// 分频器48MHz->1MHz 结束
////--------------------------------------

//延时模块的使用
//++++++++++++++++++++++++++++++++++++++
// 延时模块 开始
//++++++++++++++++++++++++++++++++++++++
reg [19:0] cnt_1us;                      // 1us延时计数子
reg cnt_1us_clear;                       // 清1us延时计数子

always @ (posedge clk)
  if (cnt_1us_clear)
    cnt_1us <= 0;
  else
    cnt_1us <= cnt_1us + 1'b1;
//--------------------------------------
// 延时模块 结束
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// DS18B20状态机 开始
//++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++
// 格雷码：消除状态转换时由多条状态信号线的传输延迟所造成的毛刺，又可以降低功耗
parameter S00     = 5'h00;
parameter S0      = 5'h01;
parameter S1      = 5'h03;
parameter S2      = 5'h02;
parameter S3      = 5'h06;
parameter S4      = 5'h07;
parameter S5      = 5'h05;
parameter S6      = 5'h04;
parameter S7      = 5'h0C;
parameter WRITE0  = 5'h0D;
parameter WRITE1  = 5'h0F;
parameter WRITE00 = 5'h0E;
parameter WRITE01 = 5'h0A;
parameter READ0   = 5'h0B;
parameter READ1   = 5'h09;
parameter READ2   = 5'h08;
parameter READ3   = 5'h18;

reg [4:0] state;                       // 状态寄存器
//-------------------------------------

reg one_wire_buf;                      // One-Wire总线 缓存寄存器

reg [15:0] temperature_buf;            // 采集到的温度值缓存器（未处理）
reg [5:0] step;                        // 子状态寄存器 0~50
reg [3:0] bit_valid;                   // 有效位  
  
always @(posedge clk, negedge rst_n)
begin
  if (!rst_n)
  begin
    one_wire_buf <= 1'bZ;
    step         <= 0;
    state        <= S00;
  end
  else
  begin
    case (state)
      S00 : begin              
              temperature_buf <= 16'h001F;
              state           <= S0;
            end
      S0 :  begin                       // 初始化
              cnt_1us_clear <= 1;
              one_wire_buf  <= 0;              
              state         <= S1;
            end
      S1 :  begin
              cnt_1us_clear <= 0;
              if (cnt_1us == 500)         // 延时500us
              begin
                cnt_1us_clear <= 1;
                one_wire_buf  <= 1'bZ;  // 释放总线
                state         <= S2;
              end 
            end
      S2 :  begin


              cnt_1us_clear <= 0;
              if (cnt_1us == 100)         // 等待100us
              begin
                cnt_1us_clear <= 1;
                state         <= S3;
              end 
            end
      S3 :  if (~one_wire)              // 若18b20拉低总线,初始化成功
              state <= S4;
            else if (one_wire)          // 否则,初始化不成功,返回S0
              state <= S0;
      S4 :  begin
              cnt_1us_clear <= 0;
              if (cnt_1us == 400)         // 再延时400us
              begin
                cnt_1us_clear <= 1;
                state         <= S5;
              end 
            end        
      S5 :  begin                       // 写数据
              if      (step == 0)       // 0xCC
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 1)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 2)
              begin                
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01; 
              end
              else if (step == 3)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;                
              end
              else if (step == 4)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 5)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 6)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;
              end
              else if (step == 7)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;
              end
              
              else if (step == 8)       // 0x44
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 9)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 10)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;
              end
              else if (step == 11)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 12)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 13)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 14)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;
                 
              end
              else if (step == 15)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              
              // 第一次写完,750ms后,跳回S0
              else if (step == 16)
              begin
                one_wire_buf <= 1'bZ;
                step         <= step + 1'b1;
                state        <= S6;                
              end
              
              // 再次置数0xCC和0xBE
              else if (step == 17)      // 0xCC
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 18)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 19)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;                
              end
              else if (step == 20)
              begin
                step  <= step + 1'b1;
                state <= WRITE01;
                one_wire_buf <= 0;
              end
              else if (step == 21)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 22)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 23)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;
              end
              else if (step == 24)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;               
              end
              
              else if (step == 25)      // 0xBE
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 26)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;                
              end
              else if (step == 27)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;                
              end
              else if (step == 28)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;                
              end
              else if (step == 29)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;
              end
              else if (step == 30)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;
              end
              else if (step == 31)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 32)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;
              end
              
              // 第二次写完,跳到S7,直接开始读数据
              else if (step == 33)
              begin
                step  <= step + 1'b1;
                state <= S7;
              end 
            end
      S6 :  begin
              cnt_1us_clear <= 0;
              if (cnt_1us == 750000 | one_wire)     // 延时750ms!!!!
              begin
                cnt_1us_clear <= 1;
                state         <= S0;    // 跳回S0,再次初始化
              end 
            end
            
      S7 :  begin                       // 读数据
              if      (step == 34)
              begin
                bit_valid    <= 0;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;
              end
              else if (step == 35)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;
              end
              else if (step == 36)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;
              end
              else if (step == 37)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;               
              end
              else if (step == 38)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;                
              end
              else if (step == 39)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;               
              end
              else if (step == 40)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;                
              end
              else if (step == 41)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;
              end
              else if (step == 42)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;                
              end
              else if (step == 43)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;
              end
              else if (step == 44)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;                
              end
              else if (step == 45)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;                
              end
              else if (step == 46)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;                
              end
              else if (step == 47)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;                
              end
              else if (step == 48)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;                
              end
              else if (step == 49)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;                
              end
              else if (step == 50)
              begin
                step  <= 0;
                state <= S0;
              end 
            end            
            
            
      //++++++++++++++++++++++++++++++++ 
      // 写状态机
      //++++++++++++++++++++++++++++++++
      WRITE0 :
            begin
              cnt_1us_clear <= 0;
              one_wire_buf  <= 0;       // 输出0             
              if (cnt_1us == 80)        // 延时80us
              begin
                cnt_1us_clear <= 1;
                one_wire_buf  <= 1'bZ;  // 释放总线，自动拉高                
                state         <= WRITE00;
              end 
            end
      WRITE00 :                         // 空状态
              state <= S5;
      WRITE01 :                         // 空状态
              state <= WRITE1;
      WRITE1 :
            begin
              cnt_1us_clear <= 0;
              one_wire_buf  <= 1'bZ;    // 输出1   释放总线，自动拉高
              if (cnt_1us == 80)        // 延时80us
              begin
                cnt_1us_clear <= 1;
                state         <= S5;
              end 
            end
      //--------------------------------
      // 写状态机结束
      //--------------------------------
      
      
      //++++++++++++++++++++++++++++++++
      // 读状态机 
      //++++++++++++++++++++++++++++++++
      READ0 : state <= READ1;           // 空延时状态
      READ1 :
            begin
              cnt_1us_clear <= 0;
              one_wire_buf  <= 1'bZ;    // 释放总线
              if (cnt_1us == 10)        // 再延时10us
              begin
                cnt_1us_clear <= 1;
                state         <= READ2;
              end 
            end
      READ2 :                           // 读取数据
            begin
              temperature_buf[bit_valid] <= one_wire;
              state                      <= READ3;
            end
      READ3 :
            begin
              cnt_1us_clear <= 0;
              if (cnt_1us == 55)        // 再延时55us
              begin
                cnt_1us_clear <= 1;
                state         <= S7;
              end 
            end
      //--------------------------------
      // 读状态机结束
      //--------------------------------
      
      
      default : state <= S00;
    endcase 
  end 
end 

assign one_wire = one_wire_buf;         // 注意双向口的使用
//--------------------------------------
// DS18B20状态机 结束
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// 对采集到的温度进行处理 开始
//++++++++++++++++++++++++++++++++++++++
wire [15:0] t_buf = temperature_buf & 16'h07FF;

assign temperature[3:0]   = (t_buf[3:0] * 10) >> 4;//输出的温度值                               // 小数点后一位
//assign temperature[7:4]   = (t_buf[7:4] >= 10) ? (t_buf[7:4] - 10) : t_buf[7:4];  // 个位
//assign temperature[11:8]  = (t_buf[7:4] >= 10) ? (t_buf[11:8] + 1) : t_buf[11:8]; // 十位
//assign temperature[15:12] = temperature_buf[12] ? 1 : 0;                          // 正负位，0正1负

//调用除法模块，将接收到的温度值转化为十进制的十位，个位
div_rill div1(  
.a(t_buf[11:4]),   
.b('d10),  
  
.shang(temperature[11:8]),//十位  
.yushu(temperature[7:4])//个位
);

//--------------------------------------
// 对采集到的温度进行处理 结束
//--------------------------------------
endmodule

