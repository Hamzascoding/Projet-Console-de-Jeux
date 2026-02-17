library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity console_jeux is
    Port ( 
        CLK     : in STD_LOGIC;
        btnC    : in STD_LOGIC;
        RESTART : in STD_LOGIC;
        SW      : in STD_LOGIC_VECTOR (15 downto 0);
        SEG     : out STD_LOGIC_VECTOR (6 downto 0);
        AN      : out STD_LOGIC_VECTOR (3 downto 0)
    );
end console_jeux;

architecture Behavioral of console_jeux is

    signal nb_alea : std_logic_vector(7 downto 0);
    signal reg_lfsr : std_logic_vector(7 downto 0) := "10110011";

    signal septseg1, septseg2, septseg3, septseg4 : std_logic_vector(19 downto 0);
    signal active_digits : std_logic_vector(19 downto 0);

    signal mux_counter : unsigned(16 downto 0) := (others => '0');
    signal current_code : std_logic_vector(4 downto 0);

    signal btnC_sync      : std_logic_vector(2 downto 0) := (others => '0');
    signal btnC_pulsed    : std_logic;

    signal RESTART_sync   : std_logic_vector(2 downto 0) := (others => '0');
    signal RESTART_pulsed : std_logic;

begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            reg_lfsr <= reg_lfsr(6 downto 0) & (reg_lfsr(7) xor reg_lfsr(5) xor reg_lfsr(4) xor reg_lfsr(3));
        end if;
    end process;
    nb_alea <= reg_lfsr;


    process(CLK)
    begin
        if rising_edge(CLK) then
            btnC_sync    <= btnC_sync(1 downto 0) & btnC;
            RESTART_sync <= RESTART_sync(1 downto 0) & RESTART;
        end if;
    end process;

    btnC_pulsed    <= '1' when (btnC_sync(1) = '1' and btnC_sync(2) = '0') else '0';
    RESTART_pulsed <= '1' when (RESTART_sync(1) = '1' and RESTART_sync(2) = '0') else '0';

    -- Jeu 1: Parite
    G1: entity work.jeu_parite 
    port map (
        CLK => CLK, 
        RESET => RESTART_pulsed,
        btn_impair => SW(1), 
        btn_pair => SW(0), 
        VALIDE => btnC_pulsed,
        RAND_INT => nb_alea, 
        AFFICHE => septseg1
    );

    -- Jeu 2: Juste Prix
    G2: entity work.juste_prix 
    port map (
        CLK => CLK, 
        RESET => RESTART_pulsed, 
        INPUT => SW(3 downto 0), 
        RAND_INT => nb_alea(3 downto 0), 
        AFFICHE => septseg2
    );

    -- Jeu 3: PGCD
    G3: entity work.expert_pgcd 
    port map (
        CLK     => CLK, 
        START   => RESTART_sync(1),  
        A    => SW(7 downto 4), 
        B    => SW(3 downto 0), 
        AFFICHE => septseg3
    );
    -- Jeu 4: Memoire
    G4: entity work.jeu_memoire 
    port map (
        CLK => CLK, 
        RESET => RESTART_pulsed, 
        BTN_VALIDE => btnC_pulsed,
        INPUT => SW(3 downto 0), 
        RAND_INT => nb_alea(3 downto 0),
        AFFICHE => septseg4
    );


    process(SW(15 downto 14), septseg1, septseg2, septseg3, septseg4)
    begin
        case SW(15 downto 14) is
            when "00" => active_digits <= septseg1;
            when "01" => active_digits <= septseg2;
            when "10" => active_digits <= septseg3;
            when others => active_digits <= septseg4;
        end case;
    end process;

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
                AN <= "1110";
                current_code <= active_digits(4 downto 0);
            when "01" => 
                AN <= "1101"; 
                current_code <= active_digits(9 downto 5);
            when "10" => 
                AN <= "1011"; 
                current_code <= active_digits(14 downto 10);
            when others => 
                AN <= "0111";
                current_code <= active_digits(19 downto 15);
        end case;
    end process;

    DEC: entity work.dec_sept_seg
    port map ( code => current_code, SEG => SEG );

end Behavioral;