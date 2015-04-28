----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:07:44 04/19/2015 
-- Design Name:    WS2812 Symbol Generator
-- Module Name:    ws2812symgen - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:    Generate symbols for the WS2812 driver
--								Symbols are generated continuously,
--								select the line pattern via symbol.
--
--								The ACK signal is used to syncronize
--								symbol flow.
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

entity ws2812symgen is
    Port ( 
		-- reset the component
		RESET : in STD_LOGIC;
	   -- 6.4 MHz clock input
		CLK6M4 : in  STD_LOGIC;
		-- Symbol output: this is the generated output signal
		OUTPUT : out STD_LOGIC;
		-- Symbol
		--   00 - output low
		--   01 - send logic low
		--   10 - send logic high
		--   11 - reset
      SYM : in STD_LOGIC_VECTOR (1 downto 0);
		-- Acknowledge symbol
		--		Generates a rising edge when a symbol has been
		--		transferred to the latch. Use this signal to
		--		synchronize symbols.
      ACK : out  STD_LOGIC
	 );
end ws2812symgen;

architecture Behavioral of ws2812symgen is
	-- clock domain synchronization
	signal sym_d : STD_LOGIC_VECTOR (1 downto 0);
		-- the 2nd sync latch is realized with the symcurrent latch 
	
	-- Flow pattern for the signal
	signal sympattern : STD_LOGIC_VECTOR (7 downto 0);

	-- Current flow pattern, this is set on step = 0
	signal symcurrent : STD_LOGIC_VECTOR (1 downto 0);
	-- signalling step
	--		the state is based on the symstep
	signal symstep : unsigned (2 downto 0);

begin
	-- synchronize SYM
	symd : process(CLK6M4, RESET)
	begin
		if RESET = '1' then
			sym_d <= (others => '0');
		elsif rising_edge(CLK6M4) then
			sym_d <= SYM;
		end if;
	end process symd;

	-- convert symbol latch to flow pattern
	pattern: process(symcurrent)
	begin
		case symcurrent is 
			when "00" =>	sympattern <= "00000000";
			when "01" =>	sympattern <= "11000000";
			when "10" =>	sympattern <= "11111000";
			when "11" =>	sympattern <= "11111111";
			when others => sympattern <= (others => 'U');
		end case;
	end process pattern;
	
	-- select OUTPUT based on step
	stepmux: process(CLK6M4, symstep, sympattern)
	begin
		if rising_edge(CLK6M4) then
			for i in 0 to 7 loop
				if symstep = i then
					OUTPUT <= sympattern(7-i);
				end if;
			end loop;
		end if;
	end process stepmux;
	
	-- cycle the symbol
	cycle: process(CLK6M4, RESET)
	begin
		if RESET = '1' then
			-- go to WS2812 reset mode -> high signal
			symcurrent <= (others => '1');
			symstep <= (others => '0');
		elsif rising_edge(CLK6M4) then
			-- symstep 0: load symbol
			if symstep = "111" then
				-- load symbol flow pattern
				symcurrent <= sym_d;
			end if;			

			-- next symstep with wrap around
			symstep <= symstep+1;			
		end if; -- CLK1M6
	end process cycle;

	-- symbol latch transfer is done on symstep = "001"
	-- RESET pulls symstep to "000" -> ACK to '0'
	ACK <= '1' when symstep = "001" else '0';
end Behavioral;

