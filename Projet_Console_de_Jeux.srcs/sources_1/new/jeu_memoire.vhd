library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity jeu_memoire is
    Port ( 
        CLK        : in STD_LOGIC;
        RESET      : in STD_LOGIC;
        BTN_VALIDE : in STD_LOGIC;
        SWITCHES   : in STD_LOGIC_VECTOR(3 downto 0);
        RAND_INPUT : in STD_LOGIC_VECTOR(3 downto 0);
        DIGITS_OUT : out STD_LOGIC_VECTOR(19 downto 0)
    );
end jeu_memoire;

architecture Behavioral of jeu_memoire is
    type mem_array is array (0 to 15) of unsigned(3 downto 0);
    signal sequence : mem_array;
    signal current_level : integer range 1 to 16 := 1;
    signal counter : integer range 0 to 15 := 0;
    
    type state_type is (GEN, SHOW, WAIT_IN, CHECK, WIN, LOSE, NEXT_LVL);
    signal state : state_type := GEN;
    signal timer : integer := 0;
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                state <= GEN; current_level <= 1; counter <= 0;
            else
                case state is
                    when GEN =>
                        sequence(counter) <= unsigned(RAND_INPUT);
                        if counter = current_level - 1 then
                            counter <= 0; timer <= 100_000_000; state <= SHOW;
                        else
                            counter <= counter + 1;
                        end if;
                        
                    when SHOW =>
                        if timer = 0 then
                            if counter = current_level - 1 then
                                counter <= 0; state <= WAIT_IN;
                            else
                                counter <= counter + 1; timer <= 100_000_000;
                            end if;
                        else
                            timer <= timer - 1;
                        end if;
                        
                    when WAIT_IN =>
                        if BTN_VALIDE = '1' then state <= CHECK; end if;
                        
                    when CHECK =>
                        if unsigned(SWITCHES) = sequence(counter) then
                            if counter = current_level - 1 then
                                state <= WIN; timer <= 100_000_000;
                            else
                                counter <= counter + 1; state <= WAIT_IN;
                            end if;
                        else
                            state <= LOSE;
                        end if;
                        
                    when WIN =>
                        if timer = 0 then state <= NEXT_LVL; else timer <= timer - 1; end if;
                        
                    when NEXT_LVL =>
                        if current_level < 16 then current_level <= current_level + 1; end if;
                        counter <= 0; state <= GEN;
                        
                    when LOSE =>
                        -- Stay here until RESET
                end case;
            end if;
        end if;
    end process;

    process(state, sequence, counter)
    begin
        if state = SHOW then
            DIGITS_OUT <= "11111" & "11111" & "11111" & std_logic_vector(resize(sequence(counter), 5));
        elsif state = WIN then
            DIGITS_OUT <= "10000" & "10000" & "10000" & "10000"; -- CCCC
        elsif state = LOSE then
            DIGITS_OUT <= "10001" & "10001" & "10001" & "10001"; -- FFFF
        else
            DIGITS_OUT <= (others => '1');
        end if;
    end process;
end Behavioral;