----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:54:01 04/24/2015 
-- Design Name: 
-- Module Name:    DigitSequencer - Behavioral 
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

entity DigitSequencer is
    Port ( CLK 		: in  STD_LOGIC;
			  RESET		: in STD_LOGIC;
			  -- digit
           DIGIT 		: in  STD_LOGIC_VECTOR (3 downto 0);
           DIGITREQ 	: out  STD_LOGIC;
           DIGITIN 	: in  STD_LOGIC;
			  -- pixel
           PXREQ 		: in  STD_LOGIC;
           PXACK 		: out  STD_LOGIC;
           PXRED 		: out  STD_LOGIC_VECTOR (7 downto 0);
           PXGREEN 	: out  STD_LOGIC_VECTOR (7 downto 0);
           PXBLUE 	: out  STD_LOGIC_VECTOR (7 downto 0);
			  -- color setting for active pixel
           COLRED 	: in  STD_LOGIC_VECTOR (7 downto 0);
           COLGREEN 	: in  STD_LOGIC_VECTOR (7 downto 0);
           COLBLUE 	: IN  STD_LOGIC_VECTOR (7 downto 0));
end DigitSequencer;

architecture Behavioral of DigitSequencer is
	-- digit handling
	signal digReq : STD_LOGIC;
	
	-- segment handling
	signal segments : STD_LOGIC_VECTOR (6 downto 0);
		-- current shift register output
	signal sr_q : STD_LOGIC;
		-- shift register is empty
	signal sr_empty : STD_LOGIC;
		-- shift register enable
	signal sr_enable : STD_LOGIC;
		-- load shift register
	signal sr_load : STD_LOGIC;
	
	-- pixel request handling
		-- PXREQ rising edge detection
	signal px_req_TRIG : STD_LOGIC;
	

	component HexTo7SegDecoder is
		Port ( 
			HEX : in  STD_LOGIC_VECTOR (3 downto 0);
			SEGMENTS : out  STD_LOGIC_VECTOR (6 downto 0)
		);
	end component HexTo7SegDecoder;

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
begin
	-- Stage 1: Segment encoding and shift register --

	-- Decode digit input to 7-segment
	decoder : HexTo7SegDecoder
		port map(
			HEX 		=>	DIGIT,
			SEGMENTS => segments
		);
	
	-- Shift register for the segment pixel values
	shift: ShiftPISO 
	generic map(
		WIDTH => 7
	)	
	PORT MAP(
		RESET => RESET,
		CLK 	=> CLK,
		D 		=> segments,
		Q 		=> sr_q,
		PL 	=> sr_load,
		SE 	=> sr_enable,
		EMPTY => sr_empty
	);	
	
	-- Request next digit when the SR is empty
	DIGITREQ <= sr_empty;

	-- Load next digit when empty and available.
	-- 	This signal is clocked by the Shift Register
	sr_load <= '1' when sr_empty = '1' and DIGITIN = '1' else '0';

	-- Shift the register when
	--		not empty
	--		and the pixel has been requested by the generator
	sr_enable <= '1' when sr_empty = '0' and px_req_TRIG = '1' else '0';
	
	-- Stage 2: Cycle the pixel values 
	-- 			from Shift register to pixel generator
	
	-- Color lines are black when sr_q is cleared
	--		This conversion is clocked by the sr
	PXRED 	<= (others => '0') when sr_q = '0' else COLRED;
	PXGREEN <= (others => '0') when sr_q = '0' else COLGREEN;
	PXBLUE 	<= (others => '0') when sr_q = '0' else COLBLUE;
	
	-- Detect and store rising edge on pixel request
	px_req_ED: EdgeDetector PORT MAP(
		CLK 	=> CLK,
		RESET => RESET,
		SIG 	=> PXREQ,
		TRIG 	=> px_req_TRIG,
		CLEAR => sr_enable,
		DIR 	=> '1' -- detect rising edge
	);		
	
	PXACK <= '1' when sr_empty = '0' and px_req_TRIG = '1' else '0';
	
	
end Behavioral;

