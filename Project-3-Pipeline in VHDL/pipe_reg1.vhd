--
-- IF/ID stage pipeline register
--
--peiyu Wang
--ID 903006854
--change: add input: stay_same, if lw hazor happen, the PC and instruction will not update.
--add new signal: branch_or, if branch happen, clean the Pc and instruction value in this register.


Library IEEE;
use IEEE.std_logic_1164.all;
 

entity pipe_reg1 is
port (	if_PC4 : in std_logic_vector(31 downto 0);
	if_instruction: in std_logic_vector( 31 downto 0);
-- new signal: branch_or and stay_same,
	branch_or,stay_same,clk, reset : in std_logic;
	id_PC4 : out std_logic_vector(31 downto 0);
	id_instruction: out std_logic_vector( 31 downto 0));
end pipe_reg1;

architecture behavioral of pipe_reg1 is
begin
process
begin
wait until (rising_edge(clk));
if (reset = '1' or branch_or ='1')then 
id_PC4 <= x"00000000";
id_instruction <= x"00000000";

elsif (stay_same /='1') then
id_PC4 <= if_PC4;
id_instruction <= if_instruction;
end if;
end process;
end behavioral;
