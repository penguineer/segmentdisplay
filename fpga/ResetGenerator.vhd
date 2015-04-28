----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:42:22 04/26/2015 
-- Design Name: 
-- Module Name:    ResetGenerator - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 	Generate a RESET signal
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ResetGenerator is
	-- The counter start value.
	--		Change to determine the length of the RESET signal.
	--		The counter is adapted accordingly.
	Generic ( limit : integer := 65535 );
	 
   Port (
		-- Clock input
		CLK50 	: in  STD_LOGIC;
		-- internal RESET signal
      RESET 	: out  STD_LOGIC;
		-- external reset
		--		The counter is reset while the external reset is high.
		--		The reset period starts after the external reset is released.
		RSTEXT 	: in STD_LOGIC
	);
end ResetGenerator;

architecture Behavioral of ResetGenerator is
	-- RESET is active until the counter is at zero
	signal counter : INTEGER RANGE 0 to limit := 0;
begin
	rst_count : process (CLK50)
	begin
		if rising_edge(CLK50) then
			if RSTEXT = '1' then
				counter <= 0;
			else
				if counter /= limit then
					counter <= counter + 1;
				end if;			
			end if;
		
		end if;
	end process rst_count;

	RESET <= '0' when counter = limit else '1';
end Behavioral;

