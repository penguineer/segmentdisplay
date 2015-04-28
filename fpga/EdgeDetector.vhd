----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:16:21 04/27/2015 
-- Design Name: 
-- Module Name:    EdgeDetector - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Synchronized Edge detector
--
--						Warning: This detector has a two-ticks delay!
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

entity EdgeDetector is
	Port ( 
		CLK : 		in  STD_LOGIC;
		RESET : 		in  STD_LOGIC;
		-- Input signal
      SIG : 		in  STD_LOGIC;
		-- Edge
			-- pulse
		EDGE : 	out STD_LOGIC;
			-- trigger
		TRIG :		out STD_LOGIC;
		-- Trigger clear
		CLEAR :		in  STD_LOGIC := '0';
		-- direction
		--		DIR = '1'	detect rising edge
		--		DIR = '0'	detect falling edge
		-- 	keep this signal constant during the detection process
		DIR :			in STD_LOGIC := '1'
	);
	
end EdgeDetector;

architecture Behavioral of EdgeDetector is
	signal edge_i : STD_LOGIC;

	-- Stage 1: synchronization signal
	signal sig_sync : STD_LOGIC;
	-- Stage 2: compare signal
	signal sig_d : STD_LOGIC;

begin
	-- Synchronization stage 1
	sync: process (RESET, CLK)
	begin
		if RESET = '1' then
			sig_sync <= '0';
		elsif rising_edge(CLK) then
			sig_sync <= SIG;
		end if;
	end process sync;
	
	-- Synchronization stage 2
	d: process (RESET, CLK)
	begin
		if RESET = '1' then
			sig_d <= '0';
		elsif rising_edge(CLK) then
			sig_d <= sig_sync;
		end if;
	end process d;

	-- detect edge
	EDGE <= edge_i;
	edge_i  <= '1' when sig_d = not DIR and sig_sync = DIR else '0';
	
	-- trigger
	--		The CLEAR signal has precedence.
	trigger: process (RESET, CLK) 
	begin
		if RESET = '1' then
			TRIG <= '0';
		elsif rising_edge(CLK) then
			if CLEAR = '1' then
				TRIG <= '0';
			end if;
			
			if edge_i = '1' and CLEAR = '0' then
				TRIG <= '1';
			end if;
		end if;
	end process trigger;
end Behavioral;

