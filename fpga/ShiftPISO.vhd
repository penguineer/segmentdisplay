----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:08:58 04/29/2015 
-- Design Name: 
-- Module Name:    ShiftPISO - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 	Parallel In, Serial Out shift register
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

entity ShiftPISO is
	-- Width of the shift register
	--		Determines the number of output ports and the latch size.
	Generic ( WIDTH : integer := 16 );

	Port (
      RESET : in  STD_LOGIC;
		-- Clock Input
      CLK 	: in  STD_LOGIC;
		-- Parallel Input
		D 		: in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		-- Serial Output
      Q 		: out  STD_LOGIC;
		-- Parallel Load
		--		The Parallel Input is valid and can be loaded.
      PL 	: in  STD_LOGIC;
		-- Shift Enable
		--		Shifts the register one bit each clock cylce when high.
		SE 	: in STD_LOGIC;
		-- Indicate that the register is empty
      EMPTY : out STD_LOGIC);
end ShiftPISO;

architecture Behavioral of ShiftPISO is
	-- Shift counter to detect when the register is empty.
	signal counter : INTEGER RANGE 0 to WIDTH := 0;
	
	-- Internal register
	signal sr : STD_LOGIC_VECTOR (WIDTH-1 downto 0);

begin
	-- The output
	Q <= sr(0);

	-- The EMPTY indicator
	EMPTY <= '1' when counter = 0 else '0';

	-- Shift handling
	shift : process (RESET, CLK)
	begin
		if RESET = '1' then
			sr <= (others => '0');
			counter <= 0;
		elsif rising_edge(CLK) then
			-- Parallel Load
			if PL = '1' then
				sr <= D;
				counter <= WIDTH;
			end if;
			
			-- Shift Enable and bits are left
			if SE = '1' and counter /= 0 then
				-- shift the register
				sr <= '0' & sr(WIDTH-1 downto 1);
				
				-- decrement counter
				counter <= counter - 1;
			end if;
		end if;
	end process shift;

end Behavioral;

