----------------------------------------------------------------------------------
-- Company: 
-- Engineer:       Mike Field <hamster@snap.net.nz> 
-- Module Name:    led_Test - Behavioral 
-- Project Name:   miniSpartan6/test1
-- Target Devices: miniSpartan6 (XC6SLX25)
-- Description:    A first project for the miniSpartan6
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_Test is
    Port ( clk50 : in  STD_LOGIC;
           leds : inout  STD_LOGIC_VECTOR (7 downto 0);
			  sw : in STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
			  portb : in STD_LOGIC_VECTOR (11 downto 0) := "000010000001";
			  porta : out STD_LOGIC_VECTOR (11 downto 0)
			);
end led_Test;

architecture Behavioral of led_Test is
	-- global reset signal
	signal RESET_i : STD_LOGIC;
	
	-- pixel color values
	signal valRed : STD_LOGIC_VECTOR(7 downto 0);
	signal valGreen : STD_LOGIC_VECTOR(7 downto 0);
	signal valBlue : STD_LOGIC_VECTOR(7 downto 0);


   signal count : unsigned(29 downto 0) := (others => '0');
	signal CLK6M4 : STD_LOGIC;
	signal count6M4 : unsigned(2 downto 0) := (others => '0');

	-- next digit
	signal digit_i : std_logic_vector(3 downto 0);
	signal dig_Req : std_logic;
	signal dig_In : std_logic := '0';

	-- symbol acknowledged
	signal symAck : std_logic := '0';
	-- next symbol
	signal symNext : STD_LOGIC_VECTOR(1 downto 0);

	-- next pixel
	signal px_Req : STD_LOGIC;
	signal px_DIN : STD_LOGIC := '0';
	signal px_Red : STD_LOGIC_VECTOR(7 downto 0);
	signal px_Green : STD_LOGIC_VECTOR(7 downto 0);
	signal px_Blue : STD_LOGIC_VECTOR(7 downto 0);
	
		
	component ResetGenerator is
		Generic ( limit : integer );
		Port ( 
			CLK50 : in  STD_LOGIC;
			RESET : out  STD_LOGIC;
			RSTEXT 	: in STD_LOGIC
		);
	end component ResetGenerator;

	component ws2812symgen is
		Port ( 
			RESET : in STD_LOGIC;
			CLK6M4 : in  STD_LOGIC;
			OUTPUT : out STD_LOGIC;
			SYM : in  STD_LOGIC_VECTOR (1 downto 0);
			ACK : out  STD_LOGIC
		);
	end component ws2812symgen;
	
	component ws2812pixelgen is
		 Port (
			RESET : in STD_LOGIC;
			CLK : in STD_LOGIC;
			SYMACK : in  STD_LOGIC;
			SYMBOL : out STD_LOGIC_VECTOR (1 downto 0);
			COLRED : in  STD_LOGIC_VECTOR (7 downto 0);
			COLGREEN : in  STD_LOGIC_VECTOR (7 downto 0);
			COLBLUE : in  STD_LOGIC_VECTOR (7 downto 0);
			PXIN : in  STD_LOGIC;
			PXREQ : out  STD_LOGIC);
	end component ws2812pixelgen;	

	COMPONENT DigitSequencer
	PORT(
		CLK : IN std_logic;
		RESET : IN std_logic;
		DIGIT : IN std_logic_vector(3 downto 0);
		DIGITIN : IN std_logic;
		PXREQ : IN std_logic;
		COLRED : IN std_logic_vector(7 downto 0);
		COLGREEN : IN std_logic_vector(7 downto 0);
		COLBLUE : IN std_logic_vector(7 downto 0);          
		DIGITREQ : OUT std_logic;
		PXACK : OUT std_logic;
		PXRED : OUT std_logic_vector(7 downto 0);
		PXGREEN : OUT std_logic_vector(7 downto 0);
		PXBLUE : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

begin
	rstGen : ResetGenerator
		generic map(
			limit => 65535
		)
		port map(
			CLK50 => CLK50,
			RESET => RESET_i,
			RSTEXT => portb(11)
		);
		
	symDrv : ws2812symgen
		port map(
			RESET => RESET_i,
			CLK6M4 => CLK6M4,
			OUTPUT => porta(1),
			SYM => symNext,
			ACK => symAck
		);

	pxGen : ws2812pixelgen
		port map(
			RESET => RESET_i,
			CLK => CLK50,
			SYMACK => symAck,
			SYMBOL => symNext,
			COLRED => px_Red,
			COLGREEN => px_Green,
			COLBLUE => px_Blue,
			PXIN => px_DIN,
			PXREQ => px_Req
		);
	
	digit_seq: DigitSequencer PORT MAP(
		CLK => CLK50,
		RESET => RESET_i,
		DIGIT => digit_i,
		DIGITREQ => dig_Req,
		DIGITIN => dig_In,
		PXREQ => px_Req,
		PXACK => px_DIN,
		PXRED => px_Red,
		PXGREEN => px_Green,
		PXBLUE => px_Blue,
		COLRED => valRed,
		COLGREEN => valGreen,
		COLBLUE => valBlue
	);	
		
	process(clk50)
   begin
      if rising_edge(clk50) then
         count <= count+1;
         leds  <= STD_LOGIC_VECTOR(count(count'high downto count'high-7));      
      end if;
   end process;

	process(clk50)
	begin
      if rising_edge(clk50) then
         count6M4 <= count6M4+1;
			
			if count6M4(2) = '1' then
				CLK6M4 <= '1';
			else
				CLK6M4 <= '0';
			end if;
      end if;
	end process;

	-- Pixel color values depend on the switch states
	process(CLK50, RESET_i)
	begin
		if RESET_i = '1' then
			valRed	<= (others => '0');
			valGreen	<= (others => '0');
			valBlue	<= (others => '0');
		elsif rising_edge(CLK50) then
			-- SW<1> for red
			if sw(1) = '1' then
				valRed <= x"ff";
			else
				valRed <= x"00";
			end if;

			-- SW<2> for green
			if sw(2) = '1' then
				valGreen <= x"ff";
			else
				valGreen <= x"00";
			end if;

			-- SW<3> for blue
			if sw(3) = '1' then
				valBlue <= x"ff";
			else
				valBlue <= x"00";
			end if;
		end if;
	end process;


	process (clk50)
	begin
		if rising_edge(clk50) then
			if dig_Req = '1' and leds(0) = '1' then
				dig_IN <= '1';
				digit_i <= leds(5 downto 2);
			else
				dig_In <= '0';
			end if;
		end if;
	end process;



	
--	nextDigit <= sw;
	porta(0) <= RESET_i;
	-- porta(1) <= '0';
	porta(11 downto 2) <= (others => '1');
end Behavioral;