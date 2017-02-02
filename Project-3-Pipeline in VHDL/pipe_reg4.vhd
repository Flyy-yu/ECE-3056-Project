--
-- Mem/WB stage pipeline register
--
--peiyu Wang
--ID 903006854
--change: delete old branch signal
Library IEEE;
use IEEE.std_logic_1164.all;

entity pipe_reg4 is
port (mem_MemToReg, mem_RegWrite : in std_logic;
      mem_memory_data, mem_alu_result: in std_logic_vector(31 downto 0);
      mem_wreg_addr: in std_logic_vector(4 downto 0);
      clk,reset : in std_logic;

      wb_MemToReg, wb_RegWrite : out std_logic;
      wb_memory_data, wb_alu_result: out std_logic_vector(31 downto 0);
      wb_wreg_addr: out std_logic_vector(4 downto 0));
end pipe_reg4;

architecture behavioral of pipe_reg4 is
begin
process
begin
wait until (rising_edge(clk));
if reset = '1'  then 
         wb_MemToReg <= '0';
	 wb_RegWrite <=  '0';
	 wb_memory_data <=  x"00000000";
	 wb_alu_result <=  x"00000000";
 	 wb_wreg_addr <= "00000";

else 
	 
         wb_MemToReg <= mem_MemToReg;
	 wb_RegWrite <=  mem_RegWrite;
	 wb_memory_data <=  mem_memory_data;
	 wb_alu_result <=  mem_alu_result;
 	 wb_wreg_addr <= mem_wreg_addr;
end if;
end process;
end behavioral;
