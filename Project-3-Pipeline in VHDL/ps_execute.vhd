--
-- execution unit. only a subset of instructions are supported in this
-- model, specifically add, sub, lw, sw, beq, and, or
--
--peiyu Wang
--ID 903006854
-- change: implement data forwarding here. 
--input new signal: stay_same,rs_num and rt_num.
Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

entity execute is
port(
--
-- inputs
--  
   

     PC4 : in std_logic_vector(31 downto 0);
     register_rs, register_rt :in std_logic_vector (31 downto 0);
     fwmemdata,fwalu_result,fwmemory_data,Sign_extend :in std_logic_vector(31 downto 0);
     ALUOp: in std_logic_vector(1 downto 0);
     branchsignal,stay_same,fwmemwrite,fwMemToReg,fwRegWrite,ALUSrc, RegDst : in std_logic;
     rs_num,rt_num,fwwbreg,fwmemreg, wreg_rd, wreg_rt : in std_logic_vector(4 downto 0);

-- outputs
--
     fwregrt,A_in,B_in,alu_result, Branch_PC :out std_logic_vector(31 downto 0);
     wreg_address : out std_logic_vector(4 downto 0);
     zero: out std_logic);    
     end execute;


architecture behavioral of execute is 
signal fwwrite_data : std_logic_vector (31 downto 0);
SIGNAL Ainput, Binput	: STD_LOGIC_VECTOR( 31 DOWNTO 0 ); 
signal ALU_Internal : std_logic_vector (31 downto 0);
Signal Function_opcode : std_logic_vector (5 downto 0);

SIGNAL ALU_ctl	: STD_LOGIC_VECTOR( 2 DOWNTO 0 );

BEGIN
    -- compute the two ALU inputs
--implement data forwarding here. 
--selete different ALU input value depends on different need of forwarding.
fwwrite_data <= fwALU_result( 31 DOWNTO 0 ) 
			           WHEN ( fwMemtoReg = '0' ) 	
			           ELSE fwmemory_data;
	-- first alu input, the data will come from rs or forward from mem or wb stage.
        Ainput <=  fwwrite_data When ((fwRegWrite = '1') And (fwwbreg /= "00000")  and (not( (fwmemwrite='1') and (fwmemreg /="00000") and (fwmemreg = rs_num ) ) ) AND (fwwbreg=rs_num) ) else
			fwmemdata When ( (fwmemwrite='1') and (fwmemreg /="00000") and (fwmemreg = rs_num ) )else 
			register_rs;
				
	
	A_in <= Ainput;
			
-- second alu input, the data will come from rs or forward from mem or wb stage.
	Binput <=   
		fwwrite_data When ((fwRegWrite = '1') And (fwwbreg /= "00000") and (ALUSrc = '0') and not ( (fwmemwrite='1') and (fwmemreg /="00000") and (fwmemreg = rt_num )) and (ALUSrc = '0')  AND (fwwbreg=rt_num) ) else
		fwmemdata When ( (fwmemwrite='1') and (fwmemreg /="00000") and (fwmemreg = rt_num ) and (ALUSrc = '0') )else 
		register_rt WHEN ( ALUSrc = '0' ) else
	          Sign_extend(31 downto 0) when ALUSrc = '1' else
	         X"BBBBBBBB";
	  B_in<=Binput;       
	
	 


        fwregrt  <=
 		 fwwrite_data When ((fwRegWrite = '1') And (fwwbreg /= "00000")  and not ( (fwmemwrite='1') and (fwmemreg /="00000") and (fwmemreg = rt_num ))  AND (fwwbreg=rt_num) ) else
		fwmemdata When ( (fwmemwrite='1') and (fwmemreg /="00000") and (fwmemreg = rt_num ) )else 
		register_rt;
		
	 -- Get the function field. This will be the least significant
	 -- 6 bits of  the sign extended offset
	 
	 Function_opcode <= Sign_extend(5 downto 0);
	         
		-- Generate ALU control bits
		
	ALU_ctl( 0 ) <= ( Function_opcode( 0 ) OR Function_opcode( 3 ) ) AND ALUOp(1 );
	ALU_ctl( 1 ) <= ( NOT Function_opcode( 2 ) ) OR (NOT ALUOp( 1 ) );
	ALU_ctl( 2 ) <= ( Function_opcode( 1 ) AND ALUOp( 1 )) OR ALUOp( 0 );
		
		-- Generate Zero Flag
	Zero <= '1' WHEN ( ALU_internal = X"00000000"  )
		         ELSE '0';    	
		         
-- implement the RegDst mux
--


wreg_address <= wreg_rd when RegDst = '1' else wreg_rt;
		         			   
  ALU_result <= X"0000000" & B"000"  & ALU_internal( 31 ) 
		WHEN  ALU_ctl = "111" 
		ELSE  ALU_internal;

PROCESS ( ALU_ctl, Ainput, Binput )
	BEGIN
					-- Select ALU operation
 	CASE ALU_ctl IS
						-- ALU performs ALUresult = A_input AND B_input
		WHEN "000" 	=>	ALU_internal 	<= Ainput AND Binput; 
						-- ALU performs ALUresult = A_input OR B_input
     	WHEN "001" 	=>	ALU_internal 	<= Ainput OR Binput;
						-- ALU performs ALUresult = A_input + B_input
	 	WHEN "010" 	=>	ALU_internal 	<= Ainput + Binput;
						-- ALU performs ?
 	 	WHEN "011" 	=>	ALU_internal <= X"00000000";
						-- ALU performs ?
 	 	WHEN "100" 	=>	ALU_internal 	<= X"00000000";
						-- ALU performs ?
 	 	WHEN "101" 	=>	ALU_internal 	<=  X"00000000";
						-- ALU performs ALUresult = A_input -B_input
 	 	WHEN "110" 	=>	ALU_internal 	<= (Ainput - Binput);
						-- ALU performs SLT
  	 	WHEN "111" 	=>	ALU_internal 	<= (Ainput - Binput) ;
 	 	WHEN OTHERS	=>	ALU_internal 	<= X"FFFFFFFF" ;
  	END CASE;
  END PROCESS;

end behavioral;



