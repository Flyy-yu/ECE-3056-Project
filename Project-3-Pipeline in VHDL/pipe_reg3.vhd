--
-- EX/MEM stage pipeline register
--
--peiyu Wang
--ID 903006854
--change : delete old branch signal
Library IEEE;
use IEEE.std_logic_1164.all;

entity pipe_reg3 is
port (ex_MemToReg, ex_RegWrite, ex_MemWrite, ex_MemRead, ex_zero: in std_logic;
      ex_alu_result, ex_register_rt : in std_logic_vector(31 downto 0);
      ex_wreg_addr :in std_logic_vector(4 downto 0);
      clk, reset : in std_logic;
	
      mem_MemToReg, mem_RegWrite, mem_MemWrite, mem_MemRead, mem_zero: out std_logic;
      mem_alu_result, mem_register_rt : out std_logic_vector(31 downto 0);
      mem_wreg_addr :out std_logic_vector(4 downto 0));
      
end pipe_reg3;


architecture behavioral of pipe_reg3 is
begin
process
begin
wait until (rising_edge(clk));
if reset ='1' then 
	mem_zero <= '0';
	
	mem_MemToReg <= '0';
	 mem_RegWrite <= '0';
	 mem_MemWrite <= '0';
	 mem_MemRead <= '0';
	 mem_alu_result <= x"00000000";
	 mem_register_rt  <= x"00000000";
	 mem_wreg_addr <= "00000";
	

else
	
	
	mem_zero <= ex_zero;
	
	mem_MemToReg <= ex_MemToReg;
	 mem_RegWrite <= ex_RegWrite;
	 mem_MemWrite <= ex_MemWrite;
	 mem_MemRead <= ex_MemRead;
	 mem_alu_result <= ex_alu_result;
	 mem_register_rt  <= ex_register_rt;
	 mem_wreg_addr <= ex_wreg_addr;
end if;

end process;
end behavioral;
