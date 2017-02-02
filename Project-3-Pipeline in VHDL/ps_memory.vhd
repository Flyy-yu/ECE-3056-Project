--
-- data memory component.   
--
--peiyu Wang
--ID 903006854
--change: change memory value for me to debug
Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


entity  memory is  
port(
-- 
-- inputs
--
     address, write_data    : in std_logic_vector(31 downto 0);
     MemWrite, MemRead      : in std_logic;
--
-- outputs
--
     read_data :out std_logic_vector(31 downto 0));

end memory;


architecture behavioral of memory is 
--change the memory to 0-16, make it eairer to debug
TYPE DATA_RAM IS ARRAY (0 to 31) OF STD_LOGIC_VECTOR (31 DOWNTO 0);
   SIGNAL dram: DATA_RAM := (
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
      X"00000016",
      X"00000000",
      X"00000000",
      X"00000000",
      X"4444444B",
      X"5555555B",
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
	
BEGIN 				

-- memory read operation. 
read_data <= dram(CONV_INTEGER('0' & address(6 downto 2))) when MemRead = '1'
             else X"FFFFFFFF";
                      -- leading '0' to prevent interpreting index as a
                      -- negative number (2's complement)

-- memory write operation
dram(CONV_INTEGER('0' & address(6 downto 2))) <= write_data when MemWrite = '1' 
            else dram(CONV_INTEGER('0' & address(6 downto 2)));
		 
end behavioral;

