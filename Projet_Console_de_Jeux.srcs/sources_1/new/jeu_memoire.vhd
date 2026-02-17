library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity jeu_memoire is
    Port ( 
        CLK        : in STD_LOGIC;
        RESET      : in STD_LOGIC;
        BTN_VALIDE : in STD_LOGIC;
        INPUT      : in STD_LOGIC_VECTOR(3 downto 0);
        RAND_INT   : in STD_LOGIC_VECTOR(3 downto 0);
        AFFICHE    : out STD_LOGIC_VECTOR(19 downto 0)
    );
end jeu_memoire;

architecture Behavioral of jeu_memoire is
    
    signal lfsr_reg : std_logic_vector(15 downto 0);
    signal seed_reg : std_logic_vector(15 downto 0);
    
    signal current_level : integer range 1 to 16 := 1;
    signal counter : integer range 0 to 15 := 0;
    
    type state_type is (GENERATING, SHOW, WAIT_INPUT, CHECK, WIN, LOSE, NEXT_LVL);
    signal state : state_type := GENERATING;
    signal timer : integer := 0;

    function next_lfsr(current : std_logic_vector(15 downto 0)) return std_logic_vector is
        variable feedback : std_logic;
    begin
        feedback := current(15) xor current(13) xor current(12) xor current(10);
        return current(14 downto 0) & feedback;
    end function;

begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                state <= GENERATING; 
                current_level <= 1; 
                counter <= 0;
                lfsr_reg <= (others => '0');
                seed_reg <= (others => '0');
            else
                case state is
                    when GENERATING =>
                        seed_reg <= RAND_INT & not RAND_INT & RAND_INT & "1010"; 
                        lfsr_reg <= RAND_INT & not RAND_INT & RAND_INT & "1010";
                        
                        counter <= 0; 
                        timer <= 100_000_000; 
                        state <= SHOW;
                        
                    when SHOW =>
                        if timer = 0 then
                            lfsr_reg <= next_lfsr(lfsr_reg); 
                            
                            if counter = current_level - 1 then
                                counter <= 0; 
                                state <= WAIT_INPUT;
                                lfsr_reg <= seed_reg; 
                            else
                                counter <= counter + 1; 
                                timer <= 100_000_000;
                            end if;
                        else
                            timer <= timer - 1;
                        end if;
                        
                    when WAIT_INPUT =>
                        if BTN_VALIDE = '1' then state <= CHECK; end if;
                        
                    when CHECK =>
                        if unsigned(INPUT) = unsigned(lfsr_reg(3 downto 0)) then
                            if counter = current_level - 1 then
                                state <= WIN; 
                                timer <= 100_000_000;
                            else
                                lfsr_reg <= next_lfsr(lfsr_reg); 
                                counter <= counter + 1; 
                                state <= WAIT_INPUT;
                            end if;
                        else
                            state <= LOSE;
                        end if;
                        
                    when WIN =>
                        if timer = 0 then state <= NEXT_LVL; else timer <= timer - 1; end if;
                        
                    when NEXT_LVL =>
                        if current_level < 16 then current_level <= current_level + 1; end if;
                        counter <= 0; 
                        state <= GENERATING;
                        
                    when LOSE =>
                        -- rien faire
                end case;
            end if;
        end if;
    end process;

    process(state, lfsr_reg)
    begin
        if state = SHOW then
            AFFICHE <= "11111" & "11111" & "11111" & std_logic_vector(resize(unsigned(lfsr_reg(3 downto 0)), 5));
        elsif state = WIN then
            AFFICHE <= "10000" & "10000" & "10000" & "10000";
        elsif state = LOSE then
            AFFICHE <= "10001" & "10001" & "10001" & "10001";
        else
            AFFICHE <= (others => '1');
        end if;
    end process;
end Behavioral;