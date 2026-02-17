library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity expert_pgcd is
    Port ( 
        CLK     : in STD_LOGIC;
        START   : in STD_LOGIC;
        A       : in STD_LOGIC_VECTOR(3 downto 0);
        B       : in STD_LOGIC_VECTOR(3 downto 0);
        AFFICHE : out STD_LOGIC_VECTOR(19 downto 0)
    );
end expert_pgcd;

architecture Behavioral of expert_pgcd is
    type state_type is (IDLE, COMPUTING, DONE);
    signal state : state_type := IDLE;
    
    signal temp_a, temp_b : unsigned(3 downto 0) := (others => '0');
    signal result         : unsigned(3 downto 0) := (others => '0');
begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            case state is
                when IDLE =>
                    if START = '1' then
                        temp_a <= unsigned(A);
                        temp_b <= unsigned(B);
                        state <= COMPUTING;
                    end if;

                when COMPUTING =>
                    if temp_a = 0 then 
                        result <= temp_b; 
                        state <= DONE;
                    elsif temp_b = 0 then 
                        result <= temp_a; 
                        state <= DONE;
                    elsif temp_a = temp_b then 
                        result <= temp_a; 
                        state <= DONE;
                    elsif temp_a > temp_b then 
                        temp_a <= temp_a - temp_b;
                    else 
                        temp_b <= temp_b - temp_a;
                    end if;

                when DONE =>
                    if START = '0' then 
                        state <= IDLE; 
                    end if;
            end case;
        end if;
    end process;

    process(state, result, A, B)
    begin
        if state = DONE then
            if result = 1 then 
                AFFICHE <= "11111" & "11111" & "10000" & "10000"; 
            else 
                AFFICHE <= "11111" & "11111" & "10001" & std_logic_vector(resize(result, 5));
            end if;
        elsif state = IDLE then
            AFFICHE <= "11111" & ("0" & A) & "11111" & ("0" & B);
        else
            AFFICHE <= (others => '1');
        end if;
    end process;
end Behavioral;