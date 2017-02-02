--
-- instruction decode unit.
--
-- Note that this module differs from the text in the following ways
-- 1. The MemToReg Mux is implemented in this module instead of a (syntactically) 
-- different pipeline stage. 
--
--peiyu Wang
--ID 903006854
-- change: creat two new out put signal: rs_num and rt_num, represent rs and rt register value.
-- change register value from 0 to 16, its easier for me to debug
--change: implement new branch here(extra credit), include compare two register value with data forwarding.

Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


entity decode is
port(
--
-- inputs 
--	
     
     PCvalue,instruction : in std_logic_vector(31 downto 0);
     fw_alu_result,fwmemdata,memory_data, alu_result :in std_logic_vector(31 downto 0);
     ex_regw,fwmemwrite,stay_same,RegWrite, MemToReg, reset : in std_logic;
     ex_wregg,fwmemreg,wreg_address : in std_logic_vector(4 downto 0);
--
-- outputs
--    
     equal_or,branchsignal   :out  std_logic;
     register_rs, register_rt :out std_logic_vector(31 downto 0);
     Branch_PC,Sign_extend :out std_logic_vector(31 downto 0);
--new signal, rs_num and rt_num
     rs_num,rt_num,wreg_rd, wreg_rt : out std_logic_vector (4 downto 0));
end decode;


architecture behavioral of decode is 
TYPE register_file IS ARRAY ( 0 TO 31 ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );

	SIGNAL register_array: register_file := (
      X"00000000",
      X"00000001",
      X"00000002",
      X"00000003",
      X"00000004",
      X"00000005",
      X"00000006",
      X"00000007",
      X"00000008",
      X"00000009",
      X"00000010",
      X"00000011",
      X"00000012",
      X"00000013",
      X"00000014",
      X"00000015",
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000",
      X"6666666B",
      X"7777777B",
      X"000000BA",
      X"111111BA",
      X"222222BA",
      X"333333BA",
      X"444444BA",
      X"555555BA",
      X"666666BA",
      X"777777BA"
   );
	SIGNAL write_data					            : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_register_1_address,rs_add,rt_add		  : STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL read_register_2_address		  : STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL Instruction_immediate_value	: STD_LOGIC_VECTOR( 15 DOWNTO 0 );
	SIGNAL signalex,comA,comB			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL rs_val,rt_val					: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL branchh                                                 : std_logic;
	begin
	rs_num <= Instruction( 25 DOWNTO 21 );
	rs_add<= Instruction( 25 DOWNTO 21 );
	rt_num<= Instruction( 20 DOWNTO 16 );
	rt_add<= Instruction( 20 DOWNTO 16 );
    read_register_1_address 	<= Instruction( 25 DOWNTO 21 );
   	read_register_2_address 	<= Instruction( 20 DOWNTO 16 );
   Instruction_immediate_value 	<= Instruction( 15 DOWNTO 0 );
	
	-- MemToReg Mux for Writeback
	   write_data <= ALU_result( 31 DOWNTO 0 ) 
			           WHEN ( MemtoReg = '0' ) 	
			           ELSE memory_data;

	-- Sign Extend 16-bits to 32-bits
    	Sign_extend <= X"0000" & Instruction_immediate_value
		         WHEN Instruction_immediate_value(15) = '0'
		         ELSE	X"FFFF" & Instruction_immediate_value;
		
	-- Read Register 1 Operation		 

		register_rs <=  
				register_array( 
			      CONV_INTEGER( read_register_1_address ) );
	rs_val<=  
				register_array( 
			      CONV_INTEGER( read_register_1_address ) );
	-- Read Register 2 Operation		 
	   register_rt <=  
				register_array( 
			      CONV_INTEGER( read_register_2_address ) );
rt_val <=  
				register_array( 
			      CONV_INTEGER( read_register_2_address ) );
	-- Register write operation
		
		register_array( CONV_INTEGER(wreg_address)) <= write_data
		                  when RegWrite = '1' else
		                      register_array(conv_integer(wreg_address));
	
	-- move possible write destinations to execute stage                   
		wreg_rd <= instruction(15 downto 11);
      wreg_rt <= instruction(20 downto 16);
		
	signalex <=X"0000" & Instruction_immediate_value
		         WHEN Instruction_immediate_value(15) = '0'
		         ELSE	X"FFFF" & Instruction_immediate_value;


-- new branch stay here
--first get the opcode, know if there is a branch instruction
	 
	branchsignal  <=  '1'  WHEN  instruction(31 downto 26) = "000100"  ELSE '0';
	
	branchh   <=  '1'  WHEN  instruction(31 downto 26) = "000100"  ELSE '0';

-- branch address
	Branch_PC <= PCvalue + (signalex(29 downto 0) & "00");
-- first register value, with data forward from ex or mem stage
	comA <= fw_alu_result when ( (ex_regw='1') and (ex_wregg /="00000") and (rs_add/="00000")and (ex_wregg = rs_add ) )else
		fwmemdata When ( (fwmemwrite='1') and (fwmemreg /="00000") and (rs_add/="00000")and (fwmemreg = rs_add ) )else 
			rs_val;



-- second register value, with data forward from ex or mem stage
	comB <= fw_alu_result when ( (ex_regw='1') and (ex_wregg /="00000") and (rt_add/="00000")and (ex_wregg = rt_add ) )else
		fwmemdata When ( (fwmemwrite='1') and (fwmemreg /="00000") and (rt_add/="00000")and (fwmemreg = rt_add ) )else 
			rt_val;

-- result of branch, decide branch or not
		equal_or <= '1' when (comA=comB) and (branchh='1')   else
			'0';
			


end behavioral;




