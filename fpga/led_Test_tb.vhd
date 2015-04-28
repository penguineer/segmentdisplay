--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:51:58 04/13/2015
-- Design Name:   
-- Module Name:   /home/tux/tmp/Xilinx/WS2812_7segment_display/led_Test_tb.vhd
-- Project Name:  WS2812_7segment_display
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: led_Test
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY led_Test_tb IS
END led_Test_tb;
 
ARCHITECTURE behavior OF led_Test_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT led_Test
    PORT(
         clk50 : IN  std_logic;
         leds : INOUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk50 : std_logic := '0';

 	--Outputs
   signal leds : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk50_period : time := 20 ns;
 
BEGIN
	-- Instantiate the Unit Under Test (UUT)
   uut: led_Test PORT MAP (
          clk50 => clk50,
          leds => leds
        );

   -- Clock process definitions
   clk50_process :process
   begin
		clk50 <= '0';
		wait for clk50_period/2;
		clk50 <= '1';
		wait for clk50_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

  --    wait for clk50_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
