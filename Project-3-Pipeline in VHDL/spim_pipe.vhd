--
--  Top level SPIM module
--  
-- A few things to note. In this pipelined model, the mux in the last stage has
-- been removed and the signals have been run directly into the
-- decode module. This means the choice of operand
-- to store (whether from memory or the ALU output must be made inside of
-- the decode module. Hence the MemtoReg control signal must also be
-- provided to the decode module. 
--
-- As for signal naming conventions, all the signals used to connect the
-- modules are prefixed with if_, id_, ex_,  mem_ or wb_ depending in
-- the stage in which the signal is used (note: if a signal is generated in WB and 
-- used in fetch it will be prefaced with wb_). 
--
--
--peiyu Wang
--ID 903006854
--change: add new signal: rs_num(rs number),rt_num(rs number),id_rs_num,id_rt_num(let two number go though reg 2),sent : stay_same signal
-- to all require part to implement lw hazard.
--delete all the signal relate to old branch method, add new branch signal: branchsignal and equal_or,branch_or.
--data forwarding implement in execute.vhd, LW hazard implement in control.vhd, new branch implement in decode.vhd.
Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;


entity spim_pipe is 
port(Out_ID_Instr : out std_logic_vector(31 downto 0);
     Out_EX_Rs, Out_EX_Rt : out std_logic_vector(31 downto 0); 
     Out_WB_MemOut, Out_MEM_ALURes,Out_MEM_MemInData, Out_WB_ALU_Result : out std_logic_vector(31 downto 0); 
     Out_ID_PC : out std_logic_vector(31 downto 0);
     Out_EX_ALUOp : out std_logic_vector(1 downto 0);
     Out_WB_WReg : out std_logic_vector(4 downto 0);
     Out_WB_RegWrite, Out_EX_ALUSrc, Out_EX_RegDst,Out_WB_MemToReg, Out_MEM_MRead, Out_MEM_MWrite : out std_logic);
end spim_pipe;


architecture structural of spim_pipe is
    
    -- clock and reset generation
    
    
component my_clock is
port ( signal sys_clock, reset : out std_logic);
end component my_clock;
--
-- Instruction fetch unit 
--

component fetch 
port(instruction    : out std_logic_vector(31 downto 0);
	  PC_out         : out std_logic_vector (31 downto 0);
	  Branch_PC      : in std_logic_vector(31 downto 0);
	  stay_same,clock, reset, PCSource:  in std_logic);
end component;

--
-- Instruction decode 
--

component decode 
port(
     PCvalue,instruction : in std_logic_vector(31 downto 0);
     fw_alu_result,fwmemdata,memory_data, alu_result :in std_logic_vector(31 downto 0);
     ex_regw,fwmemwrite,stay_same,RegWrite, MemToReg, reset  : in std_logic;
     ex_wregg,fwmemreg,wreg_address : in std_logic_vector(4 downto 0);
     rs_num,rt_num,wreg_rd, wreg_rt: out std_logic_vector(4 downto 0);
     register_rs, register_rt :out std_logic_vector(31 downto 0);
	equal_or,branchsignal :out std_logic;
     Branch_PC,Sign_extend :out std_logic_vector(31 downto 0));
end component;

--
-- Execution unit 
--

component execute
port(


 

     PC4 : in std_logic_vector(31 downto 0);
     fwmemdata,fwalu_result,fwmemory_data,register_rs, register_rt :in std_logic_vector(31 downto 0);
     Sign_extend:in std_logic_vector(31 downto 0);
     ALUOp: in std_logic_vector(1 downto 0);
     branchsignal,stay_same,fwmemwrite,fwMemToReg,fwRegWrite,ALUSrc, RegDst : in std_logic;
     rs_num,rt_num,fwmemreg,fwwbreg,wreg_rd, wreg_rt : in std_logic_vector(4 downto 0);
    fwregrt, A_in,B_in,alu_result, branch_PC :out std_logic_vector(31 downto 0);
     wreg_address : out std_logic_vector(4 downto 0);
	 zero : out std_logic);    
end component;

--
-- Data Memory
--

component memory 
port(
     address, write_data : in std_logic_vector(31 downto 0);
     MemWrite, MemRead : in std_logic;
     read_data :out std_logic_vector(31 downto 0));
end component;
    
-- 
-- Control
--
component control
port(
	wr_address,rs_num,rt_num: in std_logic_vector(4 downto 0);
	branchsignal,ex_MemRead:in std_logic;
	opcode: in std_logic_vector(5 downto 0);
     RegDst, MemRead, MemToReg, MemWrite, Branch :out  std_logic;
    stay_same, ALUSrc, RegWrite: out std_logic;
     ALUOp: out std_logic_vector(1 downto 0));
end component;

--
-- pipeline register IF/ID
--
component pipe_reg1
port (if_PC4 : in std_logic_vector(31 downto 0);
	if_instruction: in std_logic_vector( 31 downto 0);
	branch_or,stay_same,clk, reset : in std_logic;
	id_PC4 : out std_logic_vector(31 downto 0);
	id_instruction: out std_logic_vector( 31 downto 0));

end component;

--
-- pipeline register ID/EX
--
component pipe_reg2
port (id_MemToReg, id_RegWrite, id_MemWrite, id_MemRead: in std_logic;       
      stay_same,id_ALUSrc, id_RegDst, clk, reset: in std_logic;
      id_ALUOp : in std_logic_vector(1 downto 0);
      id_PC4: in std_logic_vector(31 downto 0);
      id_register_rs, id_register_rt, id_sign_extend: in std_logic_vector(31 downto 0); 
       
      id_rs_num,id_rt_num,id_wreg_rd, id_wreg_rt : in std_logic_vector(4 downto 0);

      ex_MemToReg, ex_RegWrite, ex_MemWrite, ex_MemRead: out std_logic;
      ex_ALUSrc, ex_RegDst : out std_logic;  
      ex_ALUOp : out std_logic_vector(1 downto 0);
      ex_PC4: out  std_logic_vector(31 downto 0);
      ex_register_rs, ex_register_rt, ex_sign_extend: out std_logic_vector(31 downto 0);  
      ex_rs_num,ex_rt_num,ex_wreg_rd, ex_wreg_rt : out std_logic_vector(4 downto 0));
end component;

--
-- pipeline register EX/MEM
--

component pipe_reg3
port (ex_MemToReg, ex_RegWrite, ex_MemWrite, ex_MemRead, ex_zero: in std_logic;
      ex_alu_result, ex_register_rt: in std_logic_vector(31 downto 0);
      ex_wreg_addr :in std_logic_vector(4 downto 0);
      clk, reset : in std_logic;

      mem_MemToReg, mem_RegWrite, mem_MemWrite, mem_MemRead, mem_zero: out std_logic;
      mem_alu_result, mem_register_rt : out std_logic_vector(31 downto 0);
      mem_wreg_addr : out std_logic_vector(4 downto 0));
end component;

--
-- pipeline register MEM/WB
--
component pipe_reg4
port (mem_MemToReg, mem_RegWrite : in std_logic;
      mem_memory_data, mem_alu_result: in std_logic_vector(31 downto 0);
      mem_wreg_addr: in std_logic_vector(4 downto 0);
      clk,reset : in std_logic;

      wb_MemToReg, wb_RegWrite : out std_logic;
      wb_memory_data, wb_alu_result: out std_logic_vector(31 downto 0);
      wb_wreg_addr: out std_logic_vector(4 downto 0));
end component;

--
-- declare local signals to connect ports of components in each stage
--
-- IF
--
signal if_PC4 : std_logic_vector (31 downto 0);
signal if_instruction: std_logic_vector(31 downto 0);


--
-- ID
--

signal id_PC4  : std_logic_vector (31 downto 0);
signal id_instruction,id_Branch_PC : std_logic_vector(31 downto 0);
signal id_RegDst,id_MemRead, id_MemWrite,id_ALUSrc : std_logic;
signal id_branchsignal,id_stay_same,id_MemToReg, id_RegWrite : std_logic ;
signal id_ALUOp : std_logic_vector(1 downto 0);
signal id_register_rs, id_register_rt :std_logic_vector(31 downto 0);
signal id_Sign_extend :std_logic_vector(31 downto 0);
signal id_rs_num,id_rt_num,id_wreg_rd, id_wreg_rt : std_logic_vector(4 downto 0);
--
-- EX
--
signal ex_MemToReg, ex_RegWrite, ex_MemWrite, ex_MemRead, ex_ALUSrc, ex_zero:std_logic;
signal ex_ALUOp :std_logic_vector(1 downto 0);
signal ex_RegDst : std_logic;
signal ex_PC4 : std_logic_vector(31 downto 0);
signal ex_fwregrt,ex_A_in,ex_B_in,ex_register_rs, ex_register_rt, ex_sign_extend:std_logic_vector(31 downto 0);   
signal ex_rs_num,ex_rt_num,ex_wreg_rd, ex_wreg_rt, ex_wreg_addr: std_logic_vector(4 downto 0); 
signal ex_alu_result :std_logic_vector(31 downto 0);

-- 
-- MEM
--

signal mem_MemToReg, mem_RegWrite, mem_MemWrite, mem_MemRead, mem_zero : std_logic;
signal mem_alu_result, mem_write_data, mem_memory_data : std_logic_vector(31 downto 0);
signal mem_wreg_addr : std_logic_vector(4 downto 0);
signal mem_PCSource : std_logic;
 
--
-- WB
--

signal wb_MemToReg, wb_RegWrite :std_logic;
signal wb_memory_data, wb_alu_result: std_logic_vector(31 downto 0);
signal wb_wreg_addr: std_logic_vector(4 downto 0); 

--
-- global signals
--
signal clock, reset : std_logic;

begin
--
-- identify all signals that will show up on the trace and 
-- connnect them to internal signals on the datapath
--
-- what signals do we want to see from ID?
--
Out_ID_Instr <= id_instruction;
Out_ID_PC <= id_PC4;
--
-- signals traced from EX?
--
Out_EX_Rs <= ex_register_rs;
Out_EX_Rt <= ex_register_rt;
Out_EX_ALUSrc <= ex_ALUSrc;
Out_EX_RegDst <= ex_RegDst;
Out_EX_ALUOp <= ex_ALUOp;
--
-- signals traced from MEM?
--
Out_MEM_ALURes <= mem_alu_result;
Out_MEM_MemInData <= mem_write_data;
Out_MEM_MRead <= mem_MemRead;
Out_MEM_MWrite <= mem_MemWrite;
--
--signals traced from WB?
--
Out_WB_MemOut <= wb_memory_data;
Out_WB_ALU_Result <= wb_alu_result;
Out_WB_WReg <= wb_wreg_addr;
Out_WB_RegWrite <= wb_RegWrite;
Out_WB_MemToReg <= wb_MemToReg;



-- instantiate clock module

SCLK: my_clock 
port map(sys_clock => clock,
               reset => reset);
               
IFE: fetch    -- instantiate the fetch component

port map(

	stay_same=> id_stay_same,


PC_out => if_PC4,
         instruction => if_instruction,
         Branch_PC => id_Branch_PC,
         PCSource => mem_PCSource,
         reset =>reset,
         clock => clock);

if_id: pipe_reg1  -- instantiate the pipeline registers IF/ID
port map(clk => clock,

	stay_same=> id_stay_same,
	branch_or => mem_PCSource,
	reset => reset,
	 if_PC4 => if_PC4,
     if_instruction => if_instruction,
	 id_PC4 => id_PC4,
	 id_instruction => id_instruction);


spim_control: control -- instantiate the control component

port map(opcode => id_instruction(31 downto 26),
         RegDst => id_RegDst,

	branchsignal=>id_branchsignal, 
	rs_num => id_rs_num,
	rt_num => id_rt_num,
 	wr_address => ex_wreg_addr,
	stay_same=>id_stay_same,

	 ex_MemRead => ex_MemRead,


         MemRead => id_MemRead,
         MemToReg => id_MemToReg,
         MemWrite => id_MemWrite,
         ALUSrc => id_ALUSrc,
		 
         RegWrite => id_RegWrite,
         ALUOp => id_ALUOp);

ID: decode  -- instantiate the decode component

port map(instruction => id_instruction,
         memory_data =>wb_memory_data,
         alu_result => wb_alu_result,
	fw_alu_result=> ex_alu_result,
	branchsignal => id_branchsignal,
	stay_same=> id_stay_same,
	PCvalue =>id_PC4,
		equal_or=>mem_PCSource,

	ex_regw=>ex_RegWrite,

	ex_wregg=>ex_wreg_addr,


	fwmemdata => mem_alu_result,
	 fwmemwrite => mem_RegWrite,
	 fwmemreg => mem_wreg_addr,
	 Branch_PC =>id_Branch_PC,
         RegWrite => wb_RegWrite,
         MemToReg => wb_MemToReg,
	 	 reset => reset,
	 rs_num => id_rs_num,
	 rt_num => id_rt_num,
         register_rs => id_register_rs,
         register_rt => id_register_rt,
         Sign_extend => id_Sign_extend,
	     wreg_address => wb_wreg_addr,
	     wreg_rd => id_wreg_rd,
	     wreg_rt => id_wreg_rt);

id_ex: pipe_reg2 -- instantiate the pipeline register ID/EX
port map(clk => clock,
reset => reset, 
	 
	 id_MemToReg => id_MemToReg,
	 id_RegWrite => id_RegWrite,
	 id_MemWrite => id_MemWrite,
	 id_MemRead => id_MemRead,
	 id_ALUSrc => id_ALUSrc,
	 id_RegDst => id_RegDst,
     id_ALUOp  => id_ALUOp,
stay_same => id_stay_same,
	 id_PC4 => id_PC4,
	id_rs_num => id_rs_num,
	id_rt_num => id_rt_num,
	 id_register_rs  => id_register_rs,
	 id_register_rt  => id_register_rt,
	 id_sign_extend  => id_sign_extend,
	 id_wreg_rd  => id_wreg_rd,
	 id_wreg_rt  => id_wreg_rt,
     
     
	 ex_MemToReg => ex_MemToReg,
	 ex_RegWrite => ex_RegWrite,
	 ex_MemWrite => ex_MemWrite,
	 ex_MemRead => ex_MemRead,
	 ex_ALUSrc => ex_ALUSrc,
	 ex_RegDst => ex_RegDst,
     ex_ALUOp => ex_ALUOp,
	 ex_PC4  => ex_PC4,
	 ex_rs_num => ex_rs_num,
	ex_rt_num => ex_rt_num,
	ex_register_rs  => ex_register_rs,
	 ex_register_rt  => ex_register_rt,
	 ex_sign_extend  => ex_sign_extend,
	 ex_wreg_rd  => ex_wreg_rd,
	 ex_wreg_rt  => ex_wreg_rt);

EX: execute  -- instantiate the component EX?

port map(PC4 => ex_PC4,

	 fwmemory_data =>wb_memory_data,
         fwalu_result => wb_alu_result,
         fwRegWrite => wb_RegWrite,
         fwMemToReg => wb_MemToReg,
	 fwmemdata => mem_alu_result,
	 fwmemwrite => mem_RegWrite,
	 fwmemreg => mem_wreg_addr,
	 fwwbreg => wb_wreg_addr,
	branchsignal=> id_branchsignal,
	
	fwregrt=>ex_fwregrt,
	
	stay_same => id_stay_same,

	A_in=> ex_A_in,
	B_in=>ex_B_in,
         rs_num => ex_rs_num,
	rt_num => ex_rt_num,
	register_rs => ex_register_rs,
         register_rt => ex_register_rt,
         sign_extend => ex_sign_extend,
	     RegDst => ex_RegDst,
         ALUOp => ex_ALUOp,
         ALUSrc => ex_ALUSrc,
         alu_result => ex_alu_result,
	     wreg_rd => ex_wreg_rd,
	     wreg_rt => ex_wreg_rt,
	     wreg_address => ex_wreg_addr,
		 
		 zero => ex_zero);

ex_mem: pipe_reg3 -- instantiate the pipeline registers EX/MEM
port map(clk => clock,
reset => reset,	  

	
	ex_MemToReg => ex_MemToReg,
	 ex_RegWrite => ex_RegWrite,
	 ex_MemWrite => ex_MemWrite,
	 ex_MemRead => ex_MemRead,
	 ex_alu_result => ex_alu_result,
	 ex_register_rt  => ex_fwregrt,
	 ex_wreg_addr => ex_wreg_addr,
	 ex_zero => ex_zero,

	
	
	 mem_MemToReg => mem_MemToReg,
	 mem_RegWrite => mem_RegWrite,
	 mem_MemWrite => mem_MemWrite,
	 mem_MemRead => mem_MemRead,
	 mem_alu_result  => mem_alu_result,
	 mem_register_rt => mem_write_data,
	 mem_wreg_addr => mem_wreg_addr,
	 mem_zero => mem_zero);		 

	 
	 -- generate the branch condition for fetch
		 
	

MEM: memory -- instantiate the memory component

port map(address => mem_alu_result,
         write_data => mem_write_data,
         MemWrite =>mem_MemWrite,
         MemRead => mem_MemRead,
         read_data => mem_memory_data);


mem_wb: pipe_reg4   -- instantiate the pipeline register MEM/WB
port map(clk => clock,
	reset => reset,
	 mem_MemToReg => mem_MemToReg,
	 mem_RegWrite => mem_RegWrite,
	 mem_memory_data => mem_memory_data,
	 mem_alu_result => mem_alu_result,
 	 mem_wreg_addr => mem_wreg_addr,

	 wb_MemToReg  => wb_MemToReg,
	 wb_RegWrite => wb_RegWrite,
	 wb_memory_data  => wb_memory_data,
	 wb_alu_result => wb_alu_result,
 	 wb_wreg_addr => wb_wreg_addr);
 
end structural;


