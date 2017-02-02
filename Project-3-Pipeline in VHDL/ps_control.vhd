--
-- control unit. simply implements the truth table for a small set of
-- instructions 
--
--
--peiyu Wang
--ID 903006854
-- change: implement lw hazor detector here, if memread ='1', and rs or rt value of next instruction equal to perivous lw rd value, sent a 
-- signal call: Stay_same out. At the same time, let all the control signal equal to 0. 
Library IEEE;
use IEEE.std_logic_1164.all;

entity control is
port(
	wr_address,rs_num,rt_num: in std_logic_vector(4 downto 0);
	branchsignal,ex_MemRead:in std_logic;
	opcode: in std_logic_vector(5 downto 0);
     RegDst, MemRead, MemToReg, MemWrite :out  std_logic;
     stay_same,ALUSrc, RegWrite, Branch: out std_logic;
     ALUOp: out std_logic_vector(1 downto 0));
end control;

architecture behavioral of control is

signal rformat, lw, sw, beq,same:std_logic; -- define local signals
				    -- corresponding to instruction
				    -- type 
 begin 
--
-- recognize opcode for each instruction type
-- these variable should be inferred as wires	 

	rformat 	<=  '1'  WHEN  Opcode = "000000"  ELSE '0';
	Lw          <=  '1'  WHEN  Opcode = "100011"  ELSE '0';
 	Sw          <=  '1'  WHEN  Opcode = "101011"  ELSE '0';
   	

--
-- implement each output signal as the column of the truth
-- table  which defines the control
--
-- new signal: stay_same
stay_same  <= '1' when ((ex_MemRead= '1' ) and (rs_num /= "00000")and ( rs_num = wr_address) )else
		'0';
same<= '1' when ((ex_MemRead= '1' ) and  ( rs_num = wr_address ) )else
		'0';



-- if lw hazard happen, set all the control value to 0
RegDst <= '0' when (same= '1')or (branchsignal='1')  else
	rformat;
ALUSrc <= '0' when (same= '1')or (branchsignal='1') else
	(lw or sw) ;

MemToReg <= '0' when (same= '1')or (branchsignal='1')  else 
		lw ;
RegWrite <= '0' when (same= '1')or (branchsignal='1')  else
		(rformat or lw);
MemRead <= '0' when (same= '1')or (branchsignal='1')  else
lw ;
MemWrite <= '0' when (same= '1')or (branchsignal='1')  else
sw;	   


ALUOp(1 downto 0) <= '0'&'0' when same= '1' else
		 rformat & '0'; -- note the use of the concatenation operator
				     -- to form  2 bit signal

end behavioral;
