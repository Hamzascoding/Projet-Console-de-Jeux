library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity juste_prix is
    Port ( 
        CLK     : in STD_LOGIC;
        RESET   : in STD_LOGIC;
        INPUT   : in STD_LOGIC_VECTOR(3 downto 0);
        RAND_INT: in STD_LOGIC_VECTOR(3 downto 0);
        AFFICHE : out STD_LOGIC_VECTOR(19 downto 0)
    );
end juste_prix;

architecture Behavioral of juste_prix is
    signal secret : unsigned(3 downto 0) := "0000";
    signal init_done : std_logic := '0';
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' or init_done = '0' then
                secret <= unsigned(RAND_INT);
                init_done <= '1';
            end if;
        end if;
    end process;

    process(INPUT, secret)
    begin
        if unsigned(INPUT) < secret then 
            AFFICHE <= "11111" & "11111" & "10010" & "10011"; 
        elsif unsigned(INPUT) > secret then 
            AFFICHE <= "11111" & "11111" & "10100" & "10101"; 
        else 
            AFFICHE <= "10000" & "10000" & "10000" & "10000"; 
        end if;
    end process;
end Behavioral;