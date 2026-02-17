library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dec_sept_seg is
    Port ( 
        code : in  STD_LOGIC_VECTOR (4 downto 0); 
        SEG  : out STD_LOGIC_VECTOR (6 downto 0)
    );
end dec_sept_seg;

architecture Behavioral of dec_sept_seg is
begin
    process(code)
    begin
        case code is
            -- NUMBERS 0-9
            when "00000" => SEG <= "1000000"; -- 0
            when "00001" => SEG <= "1111001"; -- 1
            when "00010" => SEG <= "0100100"; -- 2
            when "00011" => SEG <= "0110000"; -- 3
            when "00100" => SEG <= "0011001"; -- 4
            when "00101" => SEG <= "0010010"; -- 5
            when "00110" => SEG <= "0000010"; -- 6
            when "00111" => SEG <= "1111000"; -- 7
            when "01000" => SEG <= "0000000"; -- 8
            when "01001" => SEG <= "0010000"; -- 9
            
            -- HEXADECIMAL A-F
            when "01010" => SEG <= "0001000"; -- A 
            when "01011" => SEG <= "0000011"; -- b 
            when "01100" => SEG <= "1000110"; -- C 
            when "01101" => SEG <= "0100001"; -- d 
            when "01110" => SEG <= "0000110"; -- E 
            when "01111" => SEG <= "0001110"; -- F 

            -- ETATS
            when "10000" => SEG <= "1000110"; -- 'C' 
            when "10001" => SEG <= "0001110"; -- 'F' 
            when "10010" => SEG <= "1000001"; -- 'U' 
            when "10011" => SEG <= "0001100"; -- 'P' 
            when "10100" => SEG <= "0100001"; -- 'd' 
            when "10101" => SEG <= "0101011"; -- 'n' 
            
            -- OFF
            when others  => SEG <= "1111111"; 
        end case;
    end process;
end Behavioral;