library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity jeu_parite is
    Port ( 
        CLK        : in STD_LOGIC;
        RESET      : in STD_LOGIC;
        BTN_IMPAIR : in STD_LOGIC;
        BTN_PAIR   : in STD_LOGIC;
        VALIDE     : in STD_LOGIC;
        RAND_INT   : in STD_LOGIC_VECTOR(7 downto 0);
        AFFICHE    : out STD_LOGIC_VECTOR(19 downto 0)
    );
end jeu_parite;

architecture Behavioral of jeu_parite is
    type state_type is (GENERATING, SHOW, WAIT_INPUT, CHECK, RESULT);
    signal state : state_type := GENERATING;
    signal val : integer range 0 to 255;
    signal timer : integer := 0;
    signal win : std_logic := '0';
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                state <= GENERATING;
            else
                case state is
                    when GENERATING =>
                        val <= to_integer(unsigned(RAND_INT));
                        state <= SHOW;
                        timer <= 200_000_000;
                    when SHOW =>
                        if timer = 0 then state <= WAIT_INPUT; else timer <= timer - 1; end if;
                    when WAIT_INPUT =>
                        if VALIDE = '1' then state <= CHECK; end if;
                    when CHECK =>
                        if (val mod 2 = 0 and BTN_PAIR = '1') or (val mod 2 /= 0 and BTN_IMPAIR = '1') then
                            win <= '1';
                        else
                            win <= '0';
                        end if;
                        timer <= 100_000_000;
                        state <= RESULT;
                    when RESULT =>
                        if timer = 0 then state <= GENERATING; else timer <= timer - 1; end if;
                end case;
            end if;
        end if;
    end process;

    process(state, val, win)
    begin
        AFFICHE <= (others => '1'); 
        
        if state = SHOW then
            AFFICHE(19 downto 15) <= "11111";
            AFFICHE(14 downto 10) <= std_logic_vector(to_unsigned(val / 100, 5));
            AFFICHE(9 downto 5)   <= std_logic_vector(to_unsigned((val mod 100) / 10, 5));
            AFFICHE(4 downto 0)   <= std_logic_vector(to_unsigned(val mod 10, 5));
        elsif state = RESULT then
            if win = '1' then 
                AFFICHE <= "10000" & "10000" & "10000" & "10000";
            else 
                AFFICHE <= "10001" & "10001" & "10001" & "10001";
            end if;
        end if;
    end process;
end Behavioral;