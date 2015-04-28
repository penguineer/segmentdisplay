----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:35:01 04/24/2015 
-- Design Name: 
-- Module Name:    HexTo7SegDecoder - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity HexTo7SegDecoder is
    Port ( HEX : in  STD_LOGIC_VECTOR (3 downto 0);
           SEGMENTS : out  STD_LOGIC_VECTOR (6 downto 0));
end HexTo7SegDecoder;

architecture Behavioral of HexTo7SegDecoder is

begin
	process (HEX)
	begin
		case HEX is 
			when "0000" =>	SEGMENTS <= "1110111";
			when "0001" =>	SEGMENTS <= "1000100";
			when "0010" =>	SEGMENTS <= "1101011";
			when "0011" =>	SEGMENTS <= "1101110";
			when "0100" =>	SEGMENTS <= "1011100";
			when "0101" =>	SEGMENTS <= "0111110";
			when "0110" =>	SEGMENTS <= "0111111";
			when "0111" =>	SEGMENTS <= "1100100";
			when "1000" =>	SEGMENTS <= "1111111";
			when "1001" =>	SEGMENTS <= "1111110";
			when "1010" =>	SEGMENTS <= "1111101";
			when "1011" =>	SEGMENTS <= "0011111";
			when "1100" =>	SEGMENTS <= "0110011";
			when "1101" =>	SEGMENTS <= "1001111";
			when "1110" =>	SEGMENTS <= "0111011";
			when "1111" =>	SEGMENTS <= "0111001";
			when others => SEGMENTS <= "1010101";
		end case;		
	end process;
end Behavioral;

