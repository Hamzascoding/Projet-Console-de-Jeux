library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity console_jeux is
    Port ( 
        CLK  : in STD_LOGIC;
        btnC : in STD_LOGIC; -- Reset / Validate
        sw   : in STD_LOGIC_VECTOR (15 downto 0);
        seg  : out STD_LOGIC_VECTOR (6 downto 0);
        an   : out STD_LOGIC_VECTOR (3 downto 0)
    );
end console_jeux;

architecture Behavioral of console_jeux is
    -- Global Signals
    signal global_rand : std_logic_vector(7 downto 0);
    signal lfsr_reg : std_logic_vector(7 downto 0) := "10110011"; -- Seed

    -- Signals to hold output from each game
    signal digits_g1, digits_g2, digits_g3, digits_g4 : std_logic_vector(19 downto 0);
    signal active_digits : std_logic_vector(19 downto 0);
    
    -- Multiplexing
    signal mux_counter : unsigned(16 downto 0) := (others => '0');
    signal current_code : std_logic_vector(4 downto 0);

begin

    ----------------------------------------------------------------------------
    -- 1. LFSR (Random Number Generator)
    ----------------------------------------------------------------------------
    process(CLK)
    begin
        if rising_edge(CLK) then
            -- XOR Feedback taps for 8-bit LFSR
            lfsr_reg <= lfsr_reg(6 downto 0) & (lfsr_reg(7) xor lfsr_reg(5) xor lfsr_reg(4) xor lfsr_reg(3));
        end if;
    end process;
    global_rand <= lfsr_reg;

    ----------------------------------------------------------------------------
    -- 2. GAME INSTANCES
    ----------------------------------------------------------------------------
    
    -- Game 1: Parity (Select with SW 15-14 = "00")
    -- Uses SW(1) and SW(0) for inputs
    G1: entity work.jeu_parite 
    port map (
        CLK => CLK, RESET => btnC, 
        BTN_ODD => sw(1), BTN_EVEN => sw(0), VALIDE => btnC,
        RAND_INPUT => global_rand, DIGITS_OUT => digits_g1
    );

    -- Game 2: Juste Prix (Select with SW 15-14 = "01")
    -- Uses SW(3 downto 0) for inputs
    G2: entity work.juste_prix 
    port map (
        CLK => CLK, RESET => btnC, 
        PROPOSITION => sw(3 downto 0), 
        RAND_INPUT => global_rand(3 downto 0), DIGITS_OUT => digits_g2
    );

    -- Game 3: PGCD (Select with SW 15-14 = "10")
    -- Uses SW(7-4) and SW(3-0)
    G3: entity work.expert_pgcd 
    port map (
        CLK => CLK, START => btnC, 
        A_in => sw(7 downto 4), B_in => sw(3 downto 0), 
        DIGITS_OUT => digits_g3
    );

    -- Game 4: Memory (Select with SW 15-14 = "11")
    G4: entity work.jeu_memoire 
    port map (
        CLK => CLK, RESET => btnC, BTN_VALIDE => btnC,
        SWITCHES => sw(3 downto 0), RAND_INPUT => global_rand(3 downto 0),
        DIGITS_OUT => digits_g4
    );

    ----------------------------------------------------------------------------
    -- 3. MULTIPLEXER (Select which game shows on screen)
    ----------------------------------------------------------------------------
    process(sw(15 downto 14), digits_g1, digits_g2, digits_g3, digits_g4)
    begin
        case sw(15 downto 14) is
            when "00" => active_digits <= digits_g1;
            when "01" => active_digits <= digits_g2;
            when "10" => active_digits <= digits_g3;
            when others => active_digits <= digits_g4;
        end case;
    end process;

    ----------------------------------------------------------------------------
    -- 4. DISPLAY CONTROLLER
    ----------------------------------------------------------------------------
    process(CLK)
    begin
        if rising_edge(CLK) then
            mux_counter <= mux_counter + 1;
        end if;
    end process;

    process(mux_counter(16 downto 15), active_digits)
    begin
        case mux_counter(16 downto 15) is
            when "00" => 
                an <= "1110"; -- Rightmost digit
                current_code <= active_digits(4 downto 0);
            when "01" => 
                an <= "1101"; 
                current_code <= active_digits(9 downto 5);
            when "10" => 
                an <= "1011"; 
                current_code <= active_digits(14 downto 10);
            when others => 
                an <= "0111"; -- Leftmost digit
                current_code <= active_digits(19 downto 15);
        end case;
    end process;

    DEC: entity work.dec_sept_seg
    port map ( code => current_code, seg => seg );

end Behavioral;