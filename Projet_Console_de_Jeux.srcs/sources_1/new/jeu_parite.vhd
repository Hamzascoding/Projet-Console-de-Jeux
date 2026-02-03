library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity jeu_parite is
    Port ( 
        CLK        : in STD_LOGIC;
        RESET      : in STD_LOGIC;
        BTN_ODD    : in STD_LOGIC;
        BTN_EVEN   : in STD_LOGIC;
        VALIDE     : in STD_LOGIC;
        RAND_INPUT : in STD_LOGIC_VECTOR(7 downto 0);
        DIGITS_OUT : out STD_LOGIC_VECTOR(19 downto 0)
    );
end jeu_parite;

architecture Behavioral of jeu_parite is
    type state_type is (GEN, SHOW, WAIT_IN, CHECK, RESULT);
    signal state : state_type := GEN;
    signal val : integer range 0 to 255;
    signal timer : integer := 0;
    signal win : std_logic := '0';
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                state <= GEN;
            else
                case state is
                    when GEN =>
                        val <= to_integer(unsigned(RAND_INPUT));
                        state <= SHOW;
                        timer <= 200_000_000; -- 2 seconds
                    when SHOW =>
                        if timer = 0 then state <= WAIT_IN; else timer <= timer - 1; end if;
                    when WAIT_IN =>
                        if VALIDE = '1' then state <= CHECK; end if;
                    when CHECK =>
                        if (val mod 2 = 0 and BTN_EVEN = '1') or (val mod 2 /= 0 and BTN_ODD = '1') then
                            win <= '1';
                        else
                            win <= '0';
                        end if;
                        timer <= 100_000_000; -- Show result for 1 sec
                        state <= RESULT;
                    when RESULT =>
                        if timer = 0 then state <= GEN; else timer <= timer - 1; end if;
                end case;
            end if;
        end if;
    end process;

    -- Output Logic
    process(state, val, win)
    begin
        -- Default Blank
        DIGITS_OUT <= (others => '1'); 
        
        if state = SHOW then
            -- Show Number (Hundreds, Tens, Units)
            DIGITS_OUT(19 downto 15) <= "11111"; -- Blank
            DIGITS_OUT(14 downto 10) <= std_logic_vector(to_unsigned(val / 100, 5));
            DIGITS_OUT(9 downto 5)   <= std_logic_vector(to_unsigned((val mod 100) / 10, 5));
            DIGITS_OUT(4 downto 0)   <= std_logic_vector(to_unsigned(val mod 10, 5));
        elsif state = RESULT then
            if win = '1' then 
                DIGITS_OUT <= "10000" & "10000" & "10000" & "10000"; -- CCCC
            else 
                DIGITS_OUT <= "10001" & "10001" & "10001" & "10001"; -- FFFF
            end if;
        end if;
    end process;
end Behavioral;