library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity expert_pgcd is
    Port ( 
        CLK        : in STD_LOGIC;
        START      : in STD_LOGIC;
        A_in       : in STD_LOGIC_VECTOR(3 downto 0);
        B_in       : in STD_LOGIC_VECTOR(3 downto 0);
        DIGITS_OUT : out STD_LOGIC_VECTOR(19 downto 0)
    );
end expert_pgcd;

architecture Behavioral of expert_pgcd is
    type state_type is (IDLE, COMPUTE, DONE);
    signal state : state_type := IDLE;
    
    signal op_a, op_b : unsigned(3 downto 0);
    signal result     : unsigned(3 downto 0);
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            case state is
                when IDLE =>
                    if START = '1' then
                        op_a <= unsigned(A_in);
                        op_b <= unsigned(B_in);
                        state <= COMPUTE;
                    end if;

                when COMPUTE =>
                    if op_a = 0 then result <= op_b; state <= DONE;
                    elsif op_b = 0 then result <= op_a; state <= DONE;
                    elsif op_a = op_b then result <= op_a; state <= DONE;
                    elsif op_a > op_b then op_a <= op_a - op_b;
                    else op_b <= op_b - op_a;
                    end if;

                when DONE =>
                    if START = '0' then state <= IDLE; end if;
            end case;
        end if;
    end process;

    process(state, result)
    begin
        if state = DONE then
            if result = 1 then 
                -- "CC" (Coprime)
                DIGITS_OUT <= "11111" & "11111" & "10000" & "10000"; 
            else 
                -- "F" and Value
                DIGITS_OUT <= "11111" & "11111" & "10001" & std_logic_vector(resize(result, 5));
            end if;
        else
            DIGITS_OUT <= (others => '1'); -- Blank
        end if;
    end process;
end Behavioral;