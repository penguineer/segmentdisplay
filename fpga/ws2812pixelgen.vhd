----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:10:38 04/20/2015 
-- Design Name: 	 WS2812 Pixel Generator
-- Module Name:    ws2812pixelgen - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
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

entity ws2812pixelgen is
    Port ( 
  			  -- reset the component
			  RESET : in STD_LOGIC;
			  -- Clock input
			  CLK : in STD_LOGIC;
			  
			  -- symbol acknowledge from the Symbol Generator
			  --		triggers on rising edge
			  SYMACK : in  STD_LOGIC;
			  -- The next symbol to be generated
			  SYMBOL : out STD_LOGIC_VECTOR (1 downto 0);
			  
			  -- Color Intensity red
           COLRED : in  STD_LOGIC_VECTOR (7 downto 0);
			  -- Color Intensity green
           COLGREEN : in  STD_LOGIC_VECTOR (7 downto 0);
			  -- Color Intensity blue
           COLBLUE : in  STD_LOGIC_VECTOR (7 downto 0);
			  -- Pixel color values are ready
			  -- 		triggers on rising edge
           PXIN : in  STD_LOGIC;
			  -- Request new pixel color values
           PXREQ : out  STD_LOGIC);
end ws2812pixelgen;

architecture Behavioral of ws2812pixelgen is
	-- pixel line conversion
	signal px_line : STD_LOGIC_VECTOR(23 downto 0);

	-- Stage 1: Shift register

	-- -- Pixel shift register --	
		-- current shift register output
	signal sr_q : STD_LOGIC;
		-- shift register is empty
	signal sr_empty : STD_LOGIC;
		-- shift register enable
	signal sr_enable : STD_LOGIC;
		-- load shift register
	signal sr_load : STD_LOGIC;
	
	
	-- Stage 2: Symbol provider
	
	-- -- Symbol Request handshake handling --
		-- SYMACK rising edge detection
	signal sym_ack_RE : STD_LOGIC;
	signal sym_ack_TRIG : STD_LOGIC;
	signal sym_ack_CLEAR : STD_LOGIC;

	-- no-symbol-output indicator
	signal sym_silent : STD_LOGIC;
	
	COMPONENT EdgeDetector
	PORT(
		CLK 	: IN  std_logic;
		RESET : IN  STD_LOGIC;
		SIG 	: IN  std_logic;          
		EDGE 	: OUT std_logic;
		TRIG  : out STD_LOGIC;
		CLEAR : in  STD_LOGIC;
		DIR	: in  STD_LOGIC
		);
	END COMPONENT;	

	COMPONENT ShiftPISO IS
	Generic ( WIDTH : integer );
	PORT(
		RESET : IN  std_logic;
		CLK 	: IN  std_logic;
		D 		: IN  std_logic_vector(WIDTH-1 downto 0);
		PL 	: IN  std_logic;
		SE 	: IN  std_logic;          
		Q 		: OUT std_logic;
		EMPTY : OUT std_logic
		);
	END COMPONENT;	
begin
	-- -- Pixel line conversion --
	process (COLRED, COLGREEN, COLBLUE)
	begin
		for i in 0 to 7 loop
			px_line(i) 		<= COLGREEN(7-i);
			px_line(8+i) 	<= COLRED(7-i);
			px_line(16+i)	<= COLBLUE(7-i);
		end loop;
	end process;
	
	-- Stage 1: Shift register
	shift: ShiftPISO 
	generic map(
		WIDTH => 24
	)	
	PORT MAP(
		RESET => RESET,
		CLK 	=> CLK,
		D 		=> px_line,
		Q 		=> sr_q,
		PL 	=> sr_load,
		SE 	=> sr_enable,
		EMPTY => sr_empty
	);	

	-- This signal is clocked by the Shift Register
	sr_load <= '1' when sr_empty = '1' and PXIN = '1' else '0';

	-- PXREQ port depends on the shift register
	PXREQ <= sr_empty;


	-- Stage 2: Symbol provider
	
	-- SYMACK rising-edge detection
	sym_ack_ED: EdgeDetector PORT MAP(
		CLK 	=> CLK,
		RESET => RESET,
		SIG 	=> SYMACK,
		EDGE 	=> sym_ack_RE,
		TRIG 	=> sym_ack_TRIG,
		CLEAR => sym_ack_CLEAR,
		DIR 	=> '1' -- detect rising edge
	);		
	sym_ack_CLEAR <= sr_enable;
	
	-- Shift the register when
	--		not empty
	--		and the symbol has been acknowledged by the generator
	sr_enable <= '1' when sr_empty = '0' and sym_ack_TRIG = '1' else '0';

	-- No output when
	--		the SR is empty 
	--		and no more symbols are available
	sym_silent <= '1' when sr_empty = '1' and sr_empty = '1' else '0';

	-- Convert value from color bit stream to symbol for the signal generator. 
	-- Clocking for the output comes from the shift register
	SYMBOL(1) <= '1' when sr_q = '1' and sym_silent = '0' else '0';
	SYMBOL(0) <= '1' when sr_q = '0' and sym_silent = '0' else '0';
	
end Behavioral;

