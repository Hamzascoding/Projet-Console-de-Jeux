library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dec_sept_seg is
    Port ( 
        code : in  STD_LOGIC_VECTOR (4 downto 0); 
        seg  : out STD_LOGIC_VECTOR (6 downto 0)
    );
end dec_sept_seg;

architecture Behavioral of dec_sept_seg is
begin
    process(code)
    begin
        case code is
            -- NUMBERS 0-9
            when "00000" => seg <= "0000001"; -- 0
            when "00001" => seg <= "1001111"; -- 1
            when "00010" => seg <= "0010010"; -- 2
            when "00011" => seg <= "0000110"; -- 3
            when "00100" => seg <= "1001100"; -- 4
            when "00101" => seg <= "0100100"; -- 5
            when "00110" => seg <= "0100000"; -- 6
            when "00111" => seg <= "0001111"; -- 7
            when "01000" => seg <= "0000000"; -- 8
            when "01001" => seg <= "0000100"; -- 9
            
            -- LETTERS
            when "10000" => seg <= "1000110"; -- 'C' (Code 16)
            when "10001" => seg <= "0111000"; -- 'F' (Code 17)
            when "10010" => seg <= "1000001"; -- 'U' (Code 18)
            when "10011" => seg <= "0001100"; -- 'P' (Code 19)
            when "10100" => seg <= "0100001"; -- 'd' (Code 20)
            when "10101" => seg <= "0101011"; -- 'n' (Code 21)
            
            -- BLANK
            when others  => seg <= "1111111"; 
        end case;
    end process;
end Behavioral;